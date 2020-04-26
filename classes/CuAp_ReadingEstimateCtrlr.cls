/******************************************************************************
@author         Echo: Patrick Dixon
@date           12 Feb 2018
@description    Component controller for reading estimate lightning component

@Revision(s)   22-05-2018 AT-2658 Tarun Gupta , Made changes to take latest date before the provided date. 
@Revision(s)   14-06-2018 AT-2658 Tarun Gupta , Made changes to take ADU betwen the the provided date. 
*******************************************************************************/
public with sharing class CuAp_ReadingEstimateCtrlr {
    
    private static final String CLASS_NAME = 'CuAp_ReadingEstimateCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
          
    /**********************************************************************************************
    @author         Echo: Gopal Gupta
    @date           07-Feb-2018
    @param          Id - device id to be passed in from the screen
    @param          String - reading date to be passed in from the screen
    @return			estimated reading record
	@description	create an estimated reading  
					Modified estimate logic as per AT-5370
    **********************************************************************************************/    
    @AuraEnabled
    public static Reading__c createEstimatedReading(Id deviceId, String readingDate) {

        system.debug('CuAp_ReadingEstimateCtrlr..........deviceId ' + deviceId + 'readingDate ' + readingDate);
        
		Reading__c estimatedReading = new Reading__c();
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG); 
            
            Date currentReading = Date.valueOf(readingDate);
            // build a map of the supply point devices to get the set of Ids
            Map<Id, SupplyPointDevice__c> supplyPointDeviceMap = new Map<Id, SupplyPointDevice__c>(
											            							[SELECT Id 
											            							FROM SupplyPointDevice__c 
											            							WHERE Device__c = :deviceId 
											            								AND RemovalDate__c = NULL 
											            								AND InstallationDate__c <= :currentReading LIMIT 1]
											            							);
			// get the last billable reading value and date for the device
			List<Reading__c> allReadingonDeviceLst = new List<Reading__c>();
            allReadingonDeviceLst = [SELECT Id, 
                                     Reading__c, 
                                     ReadingDate__c,
                                     Leak__c
                                     FROM Reading__c 
                                     WHERE Device__c = :deviceId 
                                     AND BillableType__c = :Label.CuAp_ReadingBillableTypeBillable 
                                     AND ReadingDate__c <=: Date.valueOf(readingDate) 
                                     ORDER BY ReadingDate__c DESC, CreatedDate DESC];
                       
            // get current reading month            		
			Integer currentReadingMonth = currentReading.month();
            Integer currentReadingYear = currentReading.year();
            
            // get reading for ADU 
            Map<Id,Reading__c> readingForADUMap = new Map<Id, Reading__c>();
            Boolean lastYearReading = false;
           
            for(Reading__c reading: allReadingonDeviceLst){
                // get all last year non leak same month readings
                if(reading.ReadingDate__c.month() == currentReadingmonth && 
                   reading.ReadingDate__c.year() + 1 == currentReadingYear && 
                   !reading.Leak__c){
                    readingForADUMap.put(reading.Id, reading);
                    lastYearReading = true;
                }
            }
            
            if(readingForADUMap.isEmpty() && !allReadingonDeviceLst.isEmpty()){
                // get last reading for ADU(rolling ADU) calculation 
                readingForADUMap.put(allReadingonDeviceLst[0].Id,allReadingonDeviceLst[0]);                
            }
            
            if(!readingForADUMap.isEmpty()){
               
                List<AverageDailyUsage__c> validADULst = new List<AverageDailyUsage__c>();
                Decimal AverageDailyUsage;
                // if readingForADUMap contains last year month reading                
                if(lastYearReading){
                    Integer totalADU = 0;
                    Decimal sumADU = 0.0;      
                    system.debug('501A....supplyPointDeviceMap ' + supplyPointDeviceMap);
                    for(AverageDailyUsage__c aduObj: [SELECT Id, 
                                                      AverageDailyUsage__c 
                                                      FROM AverageDailyUsage__c 
                                                      WHERE SupplyPointDevice__c IN :supplyPointDeviceMap.keySet()                                                  
                                                      AND Reading__c IN: readingForADUMap.keySet()]){                         
                         totalADU = totalADU + 1;
                         sumADU = sumADU + aduObj.AverageDailyUsage__c;
                         system.debug('502A.....sumADU ' + sumADU );
                    }
                 
                    // mean of average Daily Usage
                    if (totalADU > 1)
                    	AverageDailyUsage = sumADU.divide(totalADU,2); //AverageDailyUsage/totalADU
                   
                    system.debug('502....AverageDailyUsage ' + AverageDailyUsage + '....readingForADUMap...' + readingForADUMap);
                    // if no ADU exist in last year reading
                    if(AverageDailyUsage == null && !allReadingonDeviceLst.isEmpty()){
                        // get last reading for ADU(rolling ADU) calculation 
                        readingForADUMap.put(allReadingonDeviceLst[0].Id,allReadingonDeviceLst[0]); 
                        system.debug('502C....readingForADUMap ' + readingForADUMap);
                        
                        for(AverageDailyUsage__c aduObj: [SELECT Id, 
                                                          AverageDailyUsage__c, 
                                                          RollingDailyUsage__c
                                                          FROM AverageDailyUsage__c 
                                                          WHERE SupplyPointDevice__c IN :supplyPointDeviceMap.keySet()                                                  
                                                          AND (Reading__c IN: readingForADUMap.keySet() OR EndDate__c = NULL)]){                         
                         	AverageDailyUsage = aduObj.RollingDailyUsage__c;
                                                              system.debug('502D....AverageDailyUsage ' + AverageDailyUsage);
                         }
                    }
                    system.debug('503.......AverageDailyUsage ' + AverageDailyUsage);
                }else{                    
                    for(AverageDailyUsage__c aduObj: [SELECT Id, 
                                                      AverageDailyUsage__c, 
                                                      RollingDailyUsage__c
                                                      FROM AverageDailyUsage__c 
                                                      WHERE SupplyPointDevice__c IN :supplyPointDeviceMap.keySet()                                                  
                                                      AND (Reading__c IN: readingForADUMap.keySet() OR EndDate__c = NULL)]){                         
                         AverageDailyUsage = aduObj.RollingDailyUsage__c;
                    }
                    system.debug('504......AverageDailyUsage ' + AverageDailyUsage);
                }                
                             
                Decimal lastReadingValue;
                Date lastReadingDate;
                
                if(!allReadingonDeviceLst.isEmpty()){
                    lastReadingValue = allReadingonDeviceLst[0].Reading__c;
                    lastReadingDate = allReadingonDeviceLst[0].ReadingDate__c;
                }
                
                system.debug('501......deviceId'  + deviceId + '...lastReadingValue...' + lastReadingValue + '...lastReadingDate...' + lastReadingDate + '...AverageDailyUsage...' + AverageDailyUsage);
                if (deviceId != null && lastReadingValue != null && lastReadingDate != null && AverageDailyUsage != null) {
                    Decimal multiplier = 1;
                    
                    // get the device details
                    Integer deviceDigits;
                    String unitOfMeasure;
                    for (Device__c device : [SELECT Id, 
                                             Digit__c, 
                                             DeviceType__c, 
                                             DeviceType__r.Multiplier__c, 
                                             DeviceType__r.UnitOfMeasure__c 
                                             FROM Device__c 
                                             WHERE Id = :deviceId]) {
    
                        deviceDigits = Integer.valueOf(device.Digit__c);
                        if (device.DeviceType__c != null) {
                            if (device.DeviceType__r.Multiplier__c != null) {
                                multiplier = device.DeviceType__r.Multiplier__c;
                            }
                            if (device.DeviceType__r.UnitOfMeasure__c != null) {
                                unitOfMeasure = device.DeviceType__r.UnitOfMeasure__c;
                            }
                        }
                    }
                
                    // calculate the estimate using the ADU
                    Integer daysDifference = lastReadingDate.daysBetween(Date.valueOf(readingDate));
                    Decimal consumption = (daysDifference * AverageDailyUsage);
                    System.debug(DEBUG + 'daysDifference: ' + daysDifference);
                    System.debug(DEBUG + 'consumption: ' + consumption);
                    
                    multiplier = (unitOfMeasure == Label.CuAp_DeviceTypeUnitOfMeasureImperialUKGallons) ? multiplier / (1000 * 0.22) : multiplier;
                    String newReading = String.valueOf(Integer.valueOf(((lastReadingValue + consumption) / multiplier).setScale(2)));
                    System.debug(DEBUG + 'lastReadingValue: ' + lastReadingValue);
                    System.debug(DEBUG + 'multiplier: ' + multiplier);
                    System.debug(DEBUG + 'newReading: ' + newReading);
                    
                    //AT-3419 core 8b...Start
                    //Maximum Possible Reading
                    String maxPossibleReading = '';
                    for(Integer i = 0; i < deviceDigits; i++){
                        maxPossibleReading = maxPossibleReading + '9' ;
                    } 
                    
                    if(Decimal.valueOf(maxPossibleReading) < Decimal.valueOf(newReading)){
                        //New Estimated Reading = [Estimated Consumption] - [Maximum Possible Reading - Previous reading] - 1 
                        newReading = String.valueOf(Integer.valueOf((consumption - (Decimal.valueOf(maxPossibleReading) - lastReadingValue) - 1).setScale(2)));                                      
                        estimatedReading.Tripped__c = true;
                    } 
                    //AT-3419 core 8b...End   
                             
                    /* GG - this code should be removed once the ReadingMustNotBeGreaterThanDeviceDigits validation rule is not required */
                    // pad/truncate the reading digits to match the number expected
                    if (newReading.length() != deviceDigits) {
                        Integer digitDifference = deviceDigits - newReading.length();
                        if (digitDifference > 0) {
                            for (Integer i = 0; i < digitDifference; i++) {
                                newReading = '0' + newReading;
                            }                            
                        } else {                        
                            newReading = newReading.right(deviceDigits);
                        }
                    }
                  
                    estimatedReading.Device__c = deviceId;
                    estimatedReading.ReadingDate__c = Date.valueOf(readingDate);
                    estimatedReading.BillableType__c = Label.CuAp_ReadingBillableTypeBillable;
                    estimatedReading.ReadingMethod__c = Label.CuAp_ReadingReadingMethodSystemEstimated;
                    estimatedReading.ReadingSource__c = Label.CuAp_ReadingReadingSourceAgentEntered;
                    estimatedReading.ActualDeviceReading__c = newReading;
                    
                    estimatedReading = (Reading__c) GlUt_FieldSecurity.cleanseFields(estimatedReading, false);         
                }
            }
			
        } catch (Exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return estimatedReading;
    }
        
    /**********************************************************************************************
    @author         Echo: Gopal Gupta
    @date           07-Feb-2018
    @param          Id - device id to be passed in from the screen
    @param          String - reading date to be passed in from the screen
    @return			estimated reading record
	@description	create an estimated reading    
					old estimate logic

    **********************************************************************************************/    
   /* @AuraEnabled
    public static Reading__c createEstimatedReading(Id deviceId, String readingDate) {

        system.debug('CuAp_ReadingEstimateCtrlr..........deviceId ' + deviceId + 'readingDate ' + readingDate);
		Reading__c estimatedReading = new Reading__c();
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
            // build a map of the supply point devices to get the set of Ids
            Map<Id, SupplyPointDevice__c> supplyPointDeviceMap = new Map<Id, SupplyPointDevice__c>(
											            							[SELECT Id 
											            							FROM SupplyPointDevice__c 
											            							WHERE Device__c = :deviceId 
											            								AND RemovalDate__c = NULL 
											            								AND InstallationDate__c <= :Date.valueOf(readingDate) LIMIT 1]
											            							);
			
			// get the last billable reading value and date for the device
			Decimal lastReadingValue;
			Date lastReadingDate;
            for (Reading__c reading : [SELECT Id, 
                                       Reading__c, 
                                       ReadingDate__c 
                                       FROM Reading__c 
                                       WHERE Device__c = :deviceId 
                                       AND BillableType__c = :Label.CuAp_ReadingBillableTypeBillable 
                                       AND ReadingDate__c <=: Date.valueOf(readingDate) //AT-2658
                                       ORDER BY ReadingDate__c DESC LIMIT 1]) {
        									
        		lastReadingValue = reading.Reading__c;
        		lastReadingDate = reading.ReadingDate__c;
			}
			
            system.debug('02......lastReadingValue ' + lastReadingValue);
            system.debug('03......lastReadingDate ' + lastReadingDate);
            system.debug('04.........supplyPointDeviceMap.keySet() ' + supplyPointDeviceMap.keySet());
            
			// get the ADU
			Decimal AverageDailyUsage;
            for (AverageDailyUsage__c ADU : [SELECT Id, 
                                             AverageDailyUsage__c 
                                             FROM AverageDailyUsage__c 
                                             WHERE SupplyPointDevice__c IN :supplyPointDeviceMap.keySet() 
                                         //  AND EndDate__c = NULL   //AT-2658
                                             AND StartDate__c <=: Date.valueOf(readingDate)            //AT-2658
                                             AND (EndDate__c = NULL OR EndDate__c >= : Date.valueOf(readingDate)) LIMIT 1]) { //AT-2658
        									
        		AverageDailyUsage = ADU.AverageDailyUsage__c;
			} 
			
            system.debug('04....AverageDailyUsage ' + AverageDailyUsage);
            
            if (deviceId != null && lastReadingValue != null && lastReadingDate != null && AverageDailyUsage != null) {
                Decimal multiplier = 1;
                
				// get the device details
	            Integer deviceDigits;
	            String unitOfMeasure;
                for (Device__c device : [SELECT Id, 
                                         Digit__c, 
                                         DeviceType__c, 
                                         DeviceType__r.Multiplier__c, 
                                         DeviceType__r.UnitOfMeasure__c 
                                         FROM Device__c 
                                         WHERE Id = :deviceId]) {

	            	deviceDigits = Integer.valueOf(device.Digit__c);
                    if (device.DeviceType__c != null) {
                    	if (device.DeviceType__r.Multiplier__c != null) {
	            			multiplier = device.DeviceType__r.Multiplier__c;
                    	}
                    	if (device.DeviceType__r.UnitOfMeasure__c != null) {
	            			unitOfMeasure = device.DeviceType__r.UnitOfMeasure__c;
                    	}
                    }
	            }
            
            	// calculate the estimate using the ADU
                Integer daysDifference = lastReadingDate.daysBetween(Date.valueOf(readingDate));
                Decimal consumption = (daysDifference * AverageDailyUsage);
                System.debug(DEBUG + 'daysDifference: ' + daysDifference);
                System.debug(DEBUG + 'consumption: ' + consumption);
                
                multiplier = (unitOfMeasure == Label.CuAp_DeviceTypeUnitOfMeasureImperialUKGallons) ? multiplier / (1000 * 0.22) : multiplier;
                String newReading = String.valueOf(Integer.valueOf(((lastReadingValue + consumption) / multiplier).setScale(2)));
                System.debug(DEBUG + 'lastReadingValue: ' + lastReadingValue);
                System.debug(DEBUG + 'multiplier: ' + multiplier);
                System.debug(DEBUG + 'newReading: ' + newReading);
                
                //AT-3419 core 8b...Start
                //Maximum Possible Reading
                String maxPossibleReading = '';
                for(Integer i = 0; i < deviceDigits; i++){
                    maxPossibleReading = maxPossibleReading + '9' ;
                } 
                
                if(Decimal.valueOf(maxPossibleReading) < Decimal.valueOf(newReading)){
                    //New Estimated Reading = [Estimated Consumption] - [Maximum Possible Reading - Previous reading] - 1 
                    newReading = String.valueOf(Integer.valueOf((consumption - (Decimal.valueOf(maxPossibleReading) - lastReadingValue) - 1).setScale(2)));                                      
                    estimatedReading.Tripped__c = true;
                } 
                //AT-3419 core 8b...End   
                         
                // GG - this code should be removed once the ReadingMustNotBeGreaterThanDeviceDigits validation rule is not required 
                // pad/truncate the reading digits to match the number expected
                if (newReading.length() != deviceDigits) {
                    Integer digitDifference = deviceDigits - newReading.length();
                    if (digitDifference > 0) {
                        for (Integer i = 0; i < digitDifference; i++) {
                            newReading = '0' + newReading;
                        }
                        
                    } else {                        
                        newReading = newReading.right(deviceDigits);
                    }
                }
              
                estimatedReading.Device__c = deviceId;
                estimatedReading.ReadingDate__c = Date.valueOf(readingDate);
                estimatedReading.BillableType__c = Label.CuAp_ReadingBillableTypeBillable;
                estimatedReading.ReadingMethod__c = Label.CuAp_ReadingReadingMethodSystemEstimated;
                estimatedReading.ReadingSource__c = Label.CuAp_ReadingReadingSourceAgentEntered;
                estimatedReading.ActualDeviceReading__c = newReading;
                
                estimatedReading = (Reading__c) GlUt_FieldSecurity.cleanseFields(estimatedReading, false);         
			}
			
        } catch (Exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return estimatedReading;
    }
    */
    
}