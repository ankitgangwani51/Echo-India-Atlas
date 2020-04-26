/******************************************************************************
@author      	Echo: Gopal Gupta
@date      		07-Feb-2018
@description	Class for the Average Daily Usage calculation
Modified		22/3/2018 Neha R - Modified to create ADU by DADU in Move In,
				18/04/2018 Neha R - Modified code for Actual reading only accepted 
				by ADU calculation AT-2269
@revesion       Updated By Echo: Dependra Singh - 13-03-2018, Added new method for Meta data types.
*******************************************************************************/
public with sharing class BlUt_ADUCalculation{
	
    /**********************************************************************************************
    @author         Echo: Gopal Gupta
    @date           07-Feb-2018
    @param          spdList - list of SupplyPointDevice__c records
    @description	calculate and update ADU for the given supply point device records 
    **********************************************************************************************/    
    public static void calculateADU(Map<Id,Date> deviceIdMap, Date ownerMoveInDate){     //AT-5598
        Set<Id> deviceSizeIdSet                                   = new Set<Id>();
        Map<Id,AverageDailyUsage__c> aduMap                       = new Map<Id,AverageDailyUsage__c>();  //AT-5073
        Map<Id,List<Reading__c>> deviceReadingMap                 = new Map<Id,List<Reading__c>>();
        Map<Id,List<SupplyPointDevice__c>> deviceSPDMap           = new Map<Id,List<SupplyPointDevice__c>>();
        Map<Id,String> locationId2AccountTypeMap                  = new Map<Id,String>(); 
		Map<Id,Id> spdId2LocationIdMap                            = new Map<Id,Id>(); 
		Map<Id,Integer> locationId2NumActiveLocOccMap             = new Map<Id,Integer>();
        Map<Id,AverageDailyUsage__c> spdAvgDlyUseMap              = new Map<Id,AverageDailyUsage__c>(); 
        Map<String,DefaultAverageDailyUsage__c> daduMap           = new Map<String,DefaultAverageDailyUsage__c>();
        Map<String,DefaultAverageDailyUsage__c> numOfOcc2DaduMap  = new Map<String,DefaultAverageDailyUsage__c>();        
        Map<Id,Date> deviceId2VoidLocStartDateMap                 = new Map<Id,Date>();
        Map<Id,List<Reading__c>> deviceActualReadingMap           = new Map<Id,List<Reading__c>>();
        Map<Id,Decimal> deviceDigitMap 							  = new Map<Id,Decimal>();				// AT-3416 Core 8b
        Map<Id,Id> spdIdwithDeviceMap                            = new Map<Id,Id>(); 					// AT-3949
		        
        // AT-5073 Started...        
        Map<Id,Id> spwithDeviceIdMap                              = new Map<Id,Id>();                
        Boolean isCalculateRollingADU                             = false; 
        
        // if(GlUt_RegionUtility.getAURegionCustomSetting()){   // make rolling ADU generic under AT-5368
        // Rolling Daily Usages Metadata
      
        //metadataRDU = [SELECT Id,UseRollingAverage__c FROM RollingDailyUsage__mdt LIMIT 1];
       
        // }
        //AT-5073 End...
        // Added By Echo: Dependra Singh - 12-03-2018
       
       system.debug('1***deviceIdMap....' + deviceIdMap);
        
        RollingDailyUsage__mdt metadataRDU = getRollingDailyUsageSetting();
        if(metadataRDU != null && metadataRDU.UseRollingAverage__c){
            isCalculateRollingADU = true;  
        }
        
        system.debug('2***isCalculateRollingADU....' + isCalculateRollingADU);
        
        for (Device__c device : [SELECT Id,DeviceType__c,DeviceType__r.DeviceSize__c,Digit__c,	 				// Digit__c -> AT-3416 Core 8b
                                 (SELECT Id,ActualDeviceReading__c,ReadingDate__c,EffectiveDeviceReading__c,ReadingType__c,ReadingMethod__c,Leak__c,Tripped__c,BillableType__c FROM Readings__r WHERE BillableType__c =: GlUt_Constants.BILLABLE ORDER BY ReadingDate__c DESC, CreatedDate DESC), //AT-3174  Tripped__c-> AT-3416 Core 8b
                                 (SELECT Id,SupplyPoint__c,SupplyPoint__r.SupplyPointUsageType__c,SupplyPoint__r.Location__c,SupplyPoint__r.Location__r.VoidLocation__c,SupplyPoint__r.Location__r.VoidStartDate__c,Device__r.DeviceType__c,Device__r.DeviceType__r.DeviceSize__c FROM SupplyPointDevices__r WHERE RemovalDate__c = NULL AND InstallationDate__c <= TODAY LIMIT 1)   // AT-5073
                                 FROM Device__c WHERE Id IN :deviceIdMap.keySet()]){                                    
        	if(device.DeviceType__c != null && device.DeviceType__r.DeviceSize__c != null){
            	deviceSizeIdSet.add(device.DeviceType__r.DeviceSize__c);
            }
                                     
            deviceReadingMap.put(device.Id,device.Readings__r);
            deviceDigitMap.put(device.Id,device.Digit__c);    // AT-3416 Core 8b
                        
            // Code to find Actual Billable reading 
            List<Reading__c> actualReadingList = new List<Reading__c>();
            for(Reading__c objRead : device.Readings__r){
                
                if (objRead.ReadingMethod__c == GlUt_Constants.ACTUAL &&
                    (deviceIdMap.get(device.Id) == null || (deviceIdMap.get(device.Id) != null && objRead.ReadingDate__c <= deviceIdMap.get(device.Id) )) )    //AT-3949          
                    actualReadingList.add(objRead);
                
                if(objRead.ReadingType__c == GlUt_Constants.MOVEIN)
                    break;    
            }
            deviceActualReadingMap.put(device.Id,actualReadingList);
                
            deviceSPDMap.put(device.Id,device.SupplyPointDevices__r);
            for(SupplyPointDevice__c spd : device.SupplyPointDevices__r){ 
                
                if(deviceIdMap.get(device.Id) != null && !spdIdwithDeviceMap.containsKey(spd.Id))   //AT-3949
                	spdIdwithDeviceMap.put(spd.Id,device.Id);
                
                if(spd.SupplyPoint__r.Location__c != null){
					spdId2LocationIdMap.put(spd.Id,spd.SupplyPoint__r.Location__c);                                
					if(spd.SupplyPoint__r.Location__r.VoidLocation__c == true) 
                    	deviceId2VoidLocStartDateMap.put(device.Id,spd.SupplyPoint__r.Location__r.VoidStartDate__c); 
                }
                
                if(!spwithDeviceIdMap.containsKey(spd.SupplyPoint__c)){  // AT-5073
                    spwithDeviceIdMap.put(spd.SupplyPoint__c,device.Id);   
                }
                
			}
        }
        
        system.debug('3***deviceActualReadingMap ' + deviceActualReadingMap);
        system.debug('4***deviceId2VoidLocStartDateMap ' + deviceId2VoidLocStartDateMap);
        system.debug('5***spdId2LocationIdMap ' + spdId2LocationIdMap); 
        system.debug('6***deviceReadingMap ' + deviceReadingMap);
       
        Map<Id, List<AverageDailyUsage__c>> allADUonDeviceMap = new Map<Id, List<AverageDailyUsage__c>>();  //AT-5073
        //find latest AverageDailyUse record and update its End date
        if(spdId2LocationIdMap.keySet().size() > 0){
            for(AverageDailyUsage__c objAdu : [SELECT Id,SupplyPointDevice__c,SupplyPointDevice__r.SupplyPoint__c,EndDate__c,StartDate__c,Invalid__c,Account__c 
                                               FROM AverageDailyUsage__c 
                                               WHERE SupplyPointDevice__c IN :spdId2LocationIdMap.keySet() ORDER BY CreatedDate DESC]){
                if(!spdAvgDlyUseMap.containsKey(objAdu.SupplyPointDevice__c)){     //AT-3949                    
                    if(spdIdwithDeviceMap.containsKey(objAdu.SupplyPointDevice__c)){     //AT-3949
                        system.debug('50505051......deviceIdMap.get(spdIdwithDeviceMap.get(objAdu.SupplyPointDevice__c)) ' + deviceIdMap.get(spdIdwithDeviceMap.get(objAdu.SupplyPointDevice__c)));
                         if(objAdu.StartDate__c == deviceIdMap.get(spdIdwithDeviceMap.get(objAdu.SupplyPointDevice__c)) || objAdu.StartDate__c == deviceIdMap.get(spdIdwithDeviceMap.get(objAdu.SupplyPointDevice__c)) + 1){
                            spdAvgDlyUseMap.put(objAdu.SupplyPointDevice__c,objAdu);
                        }
                    }else{
                        objAdu.EndDate__c = System.today();   
                        spdAvgDlyUseMap.put(objAdu.SupplyPointDevice__c,objAdu); 
                    }
                }
                //AT-5073 start...
                if(isCalculateRollingADU && spwithDeviceIdMap.containsKey(objAdu.SupplyPointDevice__r.SupplyPoint__c)){
                    Id deviceId = spwithDeviceIdMap.get(objAdu.SupplyPointDevice__r.SupplyPoint__c);
                    if(!allADUonDeviceMap.containsKey(deviceId))
                        allADUonDeviceMap.put(deviceId, new List<AverageDailyUsage__c>{});
                    
                    allADUonDeviceMap.get(deviceId).add(objAdu);                        
                }
                //AT-5073 end...                
            }
            system.debug('7***spdAvgDlyUseMap ' + spdAvgDlyUseMap);
            system.debug('8***allADUonDeviceMap ' + allADUonDeviceMap);
            
            Map<Id,String> locationOcc2OccType = new Map<Id,String>();     //AT-5598
            for(LocationOccupant__c locOccupant : [SELECT Id,Location__c,Active__c,Account__r.RecordType.Name,Location__r.NumberOfOccupiers__c,OccupancyType__c  FROM LocationOccupant__c 
                                                   WHERE Location__c IN :spdId2LocationIdMap.values() AND Active__c = True AND Primary__c = True ORDER BY CreatedDate DESC ]){      // AT-5598 
                if(!locationOcc2OccType.containsKey(locOccupant.Location__c) || 
                   (locationOcc2OccType.containsKey(locOccupant.Location__c) && locationOcc2OccType.get(locOccupant.Location__c) != Label.CuAp_AUMoveInOccType)){    // AT-5598 if location occupier tenant is available                                                                           
                    locationId2AccountTypeMap.put(locOccupant.Location__c,locOccupant.Account__r.RecordType.Name); 
                    locationId2NumActiveLocOccMap.put(locOccupant.Location__c,Integer.valueOf(locOccupant.Location__r.NumberOfOccupiers__c));
                    locationOcc2OccType.put(locOccupant.Location__c,locOccupant.OccupancyType__c);
                }
            }
            
            system.debug('9***locationId2AccountTypeMap ' + locationId2AccountTypeMap);
            system.debug('10***locationId2NumActiveLocOccMap ' + locationId2NumActiveLocOccMap);            
        }
        if(deviceSizeIdSet.size() > 0){
            for(DefaultAverageDailyUsage__c dadu : [SELECT Id,AverageDailyUsage__c,DeviceSize__c,StartDate__c,EndDate__c,NumberofOccupiers__c,SupplyPointUsageType__c 
                                                    FROM DefaultAverageDailyUsage__c WHERE DeviceSize__c IN :deviceSizeIdSet AND EndDate__c = NULL]){
                                                        
                                                        if((dadu.SupplyPointUsageType__c != null && dadu.NumberofOccupiers__c == null) || (dadu.SupplyPointUsageType__c == null && dadu.NumberofOccupiers__c == null)){
                                                            daduMap.put(dadu.DeviceSize__c + ',' + dadu.SupplyPointUsageType__c ,dadu);
                                                        }      
                                                        if((dadu.NumberofOccupiers__c != null && dadu.SupplyPointUsageType__c == null) || (dadu.NumberofOccupiers__c == null && dadu.SupplyPointUsageType__c == null)){
                                                            numOfOcc2DaduMap.put(dadu.DeviceSize__c + ',' + String.valueOf(dadu.NumberofOccupiers__c),dadu); 
                                                        }                                  
                                                    }
        }  
        
        system.debug('11***daduMap ' + daduMap);
        system.debug('12***numOfOcc2DaduMap ' + numOfOcc2DaduMap);
                    
        // AT-5073 start...	        
        // Account where Device belongs
        Map<Id, Id> accountBelongsToDevice = new Map<Id, Id>();
        Map<Id,Reading__c> lastDeviceReading = new Map<Id,Reading__c>();
        if(isCalculateRollingADU){
            Map<Id,String> service2OccType = new Map<Id,String>();  // AT-5598
            for(Service__c objService : [SELECT Id,BillingContract__c,BillingContract__r.AccountName__c,SupplyPoint__c,OccupancyType__c 
                                         FROM Service__c 
                                         WHERE SupplyPoint__c IN: spwithDeviceIdMap.keySet() 
                                         AND (ServiceEndDate__c = null OR ServiceEndDate__c >= :system.today())]){
                if(!accountBelongsToDevice.containsKey(spwithDeviceIdMap.get(objService.SupplyPoint__c)) ||
                   (service2OccType.containsKey(spwithDeviceIdMap.get(objService.SupplyPoint__c)) && service2OccType.get(spwithDeviceIdMap.get(objService.SupplyPoint__c)) != Label.CuAp_AUMoveInOccType)){    // AT-5598
                    service2OccType.put(spwithDeviceIdMap.get(objService.SupplyPoint__c),objService.OccupancyType__c);     // AT-5598  
                    accountBelongsToDevice.put(spwithDeviceIdMap.get(objService.SupplyPoint__c), objService.BillingContract__r.AccountName__c);   
                }
        	}           
            lastDeviceReading = getlastYearReading(deviceIdMap, deviceReadingMap, accountBelongsToDevice, allADUonDeviceMap);
        }
        
        system.debug('13***accountBelongsToDevice ' + accountBelongsToDevice);
        system.debug('14***lastDeviceReading ' + lastDeviceReading);
        // AT-5073 end...
        for (Id deviceId : deviceReadingMap.keySet()){           
                  
            if(deviceSPDMap.get(deviceId).size() > 0 && deviceReadingMap.get(deviceId).size() > 0 && deviceId2VoidLocStartDateMap.containsKey(deviceId) && ownerMoveInDate == null){ // Move-out Reading  
                system.debug('15***');
                 if(spdAvgDlyUseMap.containsKey(deviceSPDMap.get(deviceId)[0].Id)){
                        spdAvgDlyUseMap.get(deviceSPDMap.get(deviceId)[0].Id).EndDate__c = deviceReadingMap.get(deviceId)[0].ReadingDate__c - 1  ; // Commented under AT-3877... deviceId2VoidLocStartDateMap.get(deviceId) - 1 ;  //End date of existing ADU is Move-out Reading Date                     	
                }
                
                aduMap.put(deviceId, new AverageDailyUsage__c(AverageDailyUsage__c=0, StartDate__c = deviceReadingMap.get(deviceId)[0].ReadingDate__c , SupplyPointDevice__c=deviceSPDMap.get(deviceId)[0].Id, Reading__c = deviceReadingMap.get(deviceId)[0].Id));  // AT-3877 replaced voidstartdate with reading date
                
            }else if(deviceSPDMap.get(deviceId).size() > 0 && deviceReadingMap.get(deviceId).size() > 1 && deviceReadingMap.get(deviceId)[0].ReadingType__c != GlUt_Constants.MOVEIN 
                     && deviceReadingMap.get(deviceId)[0].ReadingMethod__c == GlUt_Constants.ACTUAL && deviceActualReadingMap.get(deviceId).size() > 1
                     && ownerMoveInDate == null){ // two billable readings found 
                Decimal readingDiff;
                Date startDate;
              
                         system.debug('8001.....deviceActualReadingMap.get(deviceId)[0] ' + deviceActualReadingMap.get(deviceId)[0]);
                         system.debug('8002.....deviceActualReadingMap.get(deviceId)[1] ' + deviceActualReadingMap.get(deviceId)[1]);
                if(deviceActualReadingMap.get(deviceId)[0].Leak__c == false){
                    
                    // AT-3416 Core 8b Start...
                    Decimal latestReading = Decimal.valueOf(deviceActualReadingMap.get(deviceId)[0].ActualDeviceReading__c);
                    Decimal lastReading = Decimal.valueOf(deviceActualReadingMap.get(deviceId)[1].ActualDeviceReading__c); 
                    
                    if(deviceActualReadingMap.get(deviceId)[0].Tripped__c == true || (lastReading > latestReading)){ 
                        String maxPossibleReading = '';
                        for(Integer i = 0; i < deviceDigitMap.get(deviceId); i++){
                            maxPossibleReading = maxPossibleReading + '9' ;
                        }                       
                        //(maximum possible reading (based on number of digits) - last billable actual reading) + new billable actual reading + 1
                        readingDiff = (Decimal.valueOf(maxPossibleReading) - lastReading) + latestReading + 1;
                    }
                    else{
                		readingDiff = latestReading - lastReading;
                    }                    
                    // AT-3416 Core 8b End...
                    
                    startDate = deviceActualReadingMap.get(deviceId)[0].ReadingDate__c + 1;   // Start Date of new ADU is day after the new Reading Date
                    
                    if(spdAvgDlyUseMap.containsKey(deviceSPDMap.get(deviceId)[0].Id)){
                        spdAvgDlyUseMap.get(deviceSPDMap.get(deviceId)[0].Id).EndDate__c = deviceActualReadingMap.get(deviceId)[0].ReadingDate__c;  //End date of existing ADU is Reading Date                     	
                	}                   
                    
                } else { // a leak record found
                    //AT-5539 start...
                    Decimal latestEffReading = Decimal.valueOf(deviceActualReadingMap.get(deviceId)[0].EffectiveDeviceReading__c);
                    Decimal lastActualReading = Decimal.valueOf(deviceActualReadingMap.get(deviceId)[1].ActualDeviceReading__c); 
                    
                    if(deviceActualReadingMap.get(deviceId)[0].Tripped__c == true ){ 
                        String maxPossibleReading = '';
                        for(Integer i = 0; i < deviceDigitMap.get(deviceId); i++){
                            maxPossibleReading = maxPossibleReading + '9' ;
                        }                       
                        //(maximum possible reading (based on number of digits) - last billable actual reading) + new billable actual reading + 1
                        readingDiff = (Decimal.valueOf(maxPossibleReading) - lastActualReading) + latestEffReading + 1;
                    }
                    else{
                		readingDiff = latestEffReading - lastActualReading;
                    } 
                    
                	//readingDiff = Decimal.valueOf(deviceActualReadingMap.get(deviceId)[0].EffectiveDeviceReading__c) - Decimal.valueOf(deviceActualReadingMap.get(deviceId)[1].ActualDeviceReading__c);   
                	//AT-5539 ends...
                	 
                	startDate = deviceActualReadingMap.get(deviceId)[0].ReadingDate__c;   
                    if(deviceIdMap.get(deviceId) == null)   //AT-3949
                        spdAvgDlyUseMap.get(deviceSPDMap.get(deviceId)[0].Id).EndDate__c = startDate; 
                    spdAvgDlyUseMap.get(deviceSPDMap.get(deviceId)[0].Id).Invalid__c = true;   //AT-3555
                }
                   
                Date previousReadingDate = deviceActualReadingMap.get(deviceId)[1].ReadingDate__c;
                Date latestReadingDate = deviceActualReadingMap.get(deviceId)[0].ReadingDate__c;
                Integer daysDiff = previousReadingDate.daysBetween(latestReadingDate); 
                        
                daysDiff = daysDiff == 0 ? 1 : daysDiff;
                Decimal avgReading = readingDiff / daysDiff;  
                         system.debug('4545......spdAvgDlyUseMap ' + spdAvgDlyUseMap);
                         system.debug('4546...deviceSPDMap ' + deviceSPDMap);
                         system.debug('4547....deviceId ' + deviceId);
                if(deviceIdMap.get(deviceId) == null)   //AT-3949
                	aduMap.put(deviceId,new AverageDailyUsage__c(AverageDailyUsage__c=avgReading.setScale(2), StartDate__c=startDate, SupplyPointDevice__c=deviceSPDMap.get(deviceId)[0].Id, Reading__c = deviceReadingMap.get(deviceId)[0].Id)); // AT-2270
                else if(spdAvgDlyUseMap.containsKey(deviceSPDMap.get(deviceId)[0].Id)){            //AT-3949
                    system.debug('45654.....');
                    spdAvgDlyUseMap.get(deviceSPDMap.get(deviceId)[0].Id).AverageDailyUsage__c = avgReading.setScale(2);
                    spdAvgDlyUseMap.get(deviceSPDMap.get(deviceId)[0].Id).StartDate__c = startDate;
                }
            } else if (deviceSPDMap.get(deviceId).size() > 0 ){ // calculation using DADU
               system.debug('96969696');
                for(SupplyPointDevice__c spd : deviceSPDMap.get(deviceId)){
                   
                    if(spdId2LocationIdMap.get(spd.Id) != null && locationId2AccountTypeMap.get(spdId2LocationIdMap.get(spd.Id)) != null){
                        Date oldADUendDate;
                        Date newADUstartDate;
                        // AU Owner MoveIn AT-5598
                        if(ownerMoveInDate != null){
                            oldADUendDate = ownerMoveInDate;
                            newADUstartDate = ownerMoveInDate + 1;
                        } else{
                            if (deviceReadingMap.get(deviceId).size() > 1 && deviceReadingMap.get(deviceId)[1].ReadingType__c == GlUt_Constants.MOVEOUT){
                                oldADUendDate = deviceReadingMap.get(deviceId)[1].ReadingDate__c;
                            }  
                            else if(deviceReadingMap.get(deviceId).size() > 0){
                                oldADUendDate = deviceReadingMap.get(deviceId)[0].ReadingDate__c - 1;
                            }
                            // AT-5598
                            newADUstartDate = deviceReadingMap.get(deviceId)[0].ReadingDate__c;
                        }
                        
                        system.debug('oldADUendDate...' + oldADUendDate);
                        system.debug('newADUstartDate...' + newADUstartDate);
                        if(locationId2AccountTypeMap.get(spdId2LocationIdMap.get(spd.Id)) == GlUt_AccountUtilities.NHH_ACCOUNT){ //commercial customer                          
                            if(spd.SupplyPoint__r.SupplyPointUsageType__c != null && spd.Device__r.DeviceType__c != null && spd.Device__r.DeviceType__r.DeviceSize__c !=null ){                                
                                if(daduMap.containsKey(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + spd.SupplyPoint__r.SupplyPointUsageType__c)
                                   && deviceReadingMap.get(deviceId).size() > 0
                                   && daduMap.get(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + spd.SupplyPoint__r.SupplyPointUsageType__c).StartDate__c <= deviceReadingMap.get(deviceId)[0].ReadingDate__c){
                                       
                                       DefaultAverageDailyUsage__c dadu = daduMap.get(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + spd.SupplyPoint__r.SupplyPointUsageType__c);
                                       if(isCalculateRollingADU)   // AT-5073
                                           aduMap.put(deviceId, new AverageDailyUsage__c(RollingDailyUsage__c=(dadu.AverageDailyUsage__c).setScale(2), Account__c=accountBelongsToDevice.get(deviceId), AverageDailyUsage__c = (dadu.AverageDailyUsage__c).setScale(2), StartDate__c = newADUstartDate, SupplyPointDevice__c = spd.Id, Reading__c = deviceReadingMap.get(deviceId)[0].Id));   // AT-2270
                                       else    
                                       		aduMap.put(deviceId, new AverageDailyUsage__c(AverageDailyUsage__c = (dadu.AverageDailyUsage__c).setScale(2), StartDate__c = newADUstartDate, SupplyPointDevice__c = spd.Id, Reading__c = deviceReadingMap.get(deviceId)[0].Id));   // AT-2270
                                       
                                       if(spdAvgDlyUseMap.containsKey(deviceSPDMap.get(deviceId)[0].Id)){
                                       		spdAvgDlyUseMap.get(deviceSPDMap.get(deviceId)[0].Id).EndDate__c = oldADUendDate;
                                       }
                                       
                                   }else if(daduMap.containsKey(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + null)
                                            && deviceReadingMap.get(deviceId).size() > 0
                                            && daduMap.get(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + null).StartDate__c <= deviceReadingMap.get(deviceId)[0].ReadingDate__c){                                                                                       
                                       DefaultAverageDailyUsage__c dadu = daduMap.get(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + null);
                                       if(isCalculateRollingADU)    // AT-5073
                                           aduMap.put(deviceId, new AverageDailyUsage__c(RollingDailyUsage__c=(dadu.AverageDailyUsage__c).setScale(2), Account__c=accountBelongsToDevice.get(deviceId), AverageDailyUsage__c = (dadu.AverageDailyUsage__c).setScale(2), StartDate__c = newADUstartDate, SupplyPointDevice__c = spd.Id, Reading__c = deviceReadingMap.get(deviceId)[0].Id));  // AT-2270
                                       else         
                                       	   aduMap.put(deviceId, new AverageDailyUsage__c(AverageDailyUsage__c=(dadu.AverageDailyUsage__c).setScale(2), StartDate__c = newADUstartDate, SupplyPointDevice__c = spd.Id, Reading__c = deviceReadingMap.get(deviceId)[0].Id));  // AT-2270
                                       if(spdAvgDlyUseMap.containsKey(deviceSPDMap.get(deviceId)[0].Id)){
                                       		spdAvgDlyUseMap.get(deviceSPDMap.get(deviceId)[0].Id).EndDate__c = oldADUendDate;
                                       }
                                   }  	
                            }
                          
                        } else if(locationId2AccountTypeMap.get(spdId2LocationIdMap.get(spd.Id)) == GlUt_AccountUtilities.HH_ACCOUNT){ // domestic customer                            
                            if(locationId2NumActiveLocOccMap.get(spdId2LocationIdMap.get(spd.Id)) != null){
                                
                                if(numOfOcc2DaduMap.containsKey(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + String.valueOf(locationId2NumActiveLocOccMap.get(spdId2LocationIdMap.get(spd.Id))))
                                   && deviceReadingMap.get(deviceId).size() > 0
                                   && numOfOcc2DaduMap.get(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + String.valueOf(locationId2NumActiveLocOccMap.get(spdId2LocationIdMap.get(spd.Id)))).StartDate__c <= deviceReadingMap.get(deviceId)[0].ReadingDate__c ){                                      
                               
                                    DefaultAverageDailyUsage__c dadu = numOfOcc2DaduMap.get(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + locationId2NumActiveLocOccMap.get(spdId2LocationIdMap.get(spd.Id)));
                                    if(isCalculateRollingADU)    // AT-5073
                                     	aduMap.put(deviceId, new AverageDailyUsage__c(RollingDailyUsage__c=(dadu.AverageDailyUsage__c).setScale(2), Account__c=accountBelongsToDevice.get(deviceId), AverageDailyUsage__c = (dadu.AverageDailyUsage__c).setScale(2), StartDate__c = newADUstartDate, SupplyPointDevice__c = spd.Id, Reading__c = deviceReadingMap.get(deviceId)[0].Id));  // AT-2270   
                                    else
                                    	aduMap.put(deviceId, new AverageDailyUsage__c(AverageDailyUsage__c = (dadu.AverageDailyUsage__c).setScale(2), StartDate__c = newADUstartDate, SupplyPointDevice__c = spd.Id, Reading__c = deviceReadingMap.get(deviceId)[0].Id));  // AT-2270
                                    if(spdAvgDlyUseMap.containsKey(deviceSPDMap.get(deviceId)[0].Id)){                                      
                                    	spdAvgDlyUseMap.get(deviceSPDMap.get(deviceId)[0].Id).EndDate__c = oldADUendDate;
                                    }
                                       
                                }else if(numOfOcc2DaduMap.containsKey(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + null)
                                         && deviceReadingMap.get(deviceId).size() > 0
                                   && numOfOcc2DaduMap.get(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + null).StartDate__c <= deviceReadingMap.get(deviceId)[0].ReadingDate__c ){
                                    
                                       DefaultAverageDailyUsage__c dadu = numOfOcc2DaduMap.get(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + null);
                                       if(isCalculateRollingADU)    // AT-5073
                                        	aduMap.put(deviceId, new AverageDailyUsage__c(RollingDailyUsage__c=(dadu.AverageDailyUsage__c).setScale(2), Account__c=accountBelongsToDevice.get(deviceId), AverageDailyUsage__c = (dadu.AverageDailyUsage__c).setScale(2), StartDate__c = newADUstartDate, SupplyPointDevice__c = spd.Id, Reading__c = deviceReadingMap.get(deviceId)[0].Id));  // AT-2270    
                                       else    
                                       		aduMap.put(deviceId, new AverageDailyUsage__c(AverageDailyUsage__c = (dadu.AverageDailyUsage__c).setScale(2), StartDate__c = newADUstartDate, SupplyPointDevice__c = spd.Id, Reading__c = deviceReadingMap.get(deviceId)[0].Id));  // AT-2270
                                       if(spdAvgDlyUseMap.containsKey(deviceSPDMap.get(deviceId)[0].Id)){                                          
                                       		spdAvgDlyUseMap.get(deviceSPDMap.get(deviceId)[0].Id).EndDate__c = oldADUendDate;
                                       }
                                }
                            } 
                        }
					}                
                }
            }
            
            system.debug('1111...isCalculateRollingADU...' + isCalculateRollingADU + '...aduMap.containsKey(deviceId) ' + aduMap.containsKey(deviceId) + '...deviceIdMap.get(deviceId) != null...' + deviceIdMap.get(deviceId) != null);
            // AT-5073 RollingDailyUsages logic
            if(isCalculateRollingADU && ((aduMap.containsKey(deviceId) && deviceReadingMap.get(deviceId)[0].ReadingType__c != GlUt_Constants.MOVEIN) || deviceIdMap.get(deviceId) != null)){               
                 system.debug('1111');
                if(!accountBelongsToDevice.containsKey(deviceId)){    //no Account present
                    aduMap.get(deviceId).RollingDailyUsage__c = 0.00;
                    system.debug('22');
                }
                 
                else if(lastDeviceReading.containsKey(deviceId) && deviceActualReadingMap.get(deviceId).size() > 1){        // RDU for two readings
                    Date latestReadingDate = deviceActualReadingMap.get(deviceId)[0].ReadingDate__c;
                    Date lastYearReadingDate = lastDeviceReading.get(deviceId).ReadingDate__c;                    
                    Integer daysDiff = lastYearReadingDate.daysBetween(latestReadingDate);
                    daysDiff = daysDiff == 0 ? 1 : daysDiff;
                
                    
                    Decimal readingDiff;
                    //Leak
                    if(deviceActualReadingMap.get(deviceId)[0].Leak__c)
                   		readingDiff = Decimal.valueOf(deviceActualReadingMap.get(deviceId)[0].EffectiveDeviceReading__c) - Decimal.valueOf(lastDeviceReading.get(deviceId).ActualDeviceReading__c);
                    else
                        readingDiff = Decimal.valueOf(deviceActualReadingMap.get(deviceId)[0].ActualDeviceReading__c) - Decimal.valueOf(lastDeviceReading.get(deviceId).ActualDeviceReading__c);
                   
                    Decimal rdu = readingDiff / daysDiff; 
                    if(deviceIdMap.get(deviceId) == null){
                        aduMap.get(deviceId).RollingDailyUsage__c = rdu.setScale(2);
                        aduMap.get(deviceId).Account__c=accountBelongsToDevice.get(deviceId);
                        system.debug('444'  +  aduMap.get(deviceId).RollingDailyUsage__c );
                    }else if(spdAvgDlyUseMap.containsKey(deviceSPDMap.get(deviceId)[0].Id)){                             
                        spdAvgDlyUseMap.get(deviceSPDMap.get(deviceId)[0].Id).RollingDailyUsage__c = rdu.setScale(2);
                        spdAvgDlyUseMap.get(deviceSPDMap.get(deviceId)[0].Id).Account__c= accountBelongsToDevice.get(deviceId);  
                        system.debug('555'  +  spdAvgDlyUseMap.get(deviceSPDMap.get(deviceId)[0].Id).RollingDailyUsage__c );
                    }
                    
                       system.debug('666');
                }
                else{                                                // RDU by DADU
                    for(SupplyPointDevice__c spd : deviceSPDMap.get(deviceId)){   
                        system.debug('777');
                        if(locationId2AccountTypeMap.get(spdId2LocationIdMap.get(spd.Id)) == GlUt_AccountUtilities.NHH_ACCOUNT){ //commercial customer  
                            system.debug('77.77777' );
                            if(spd.SupplyPoint__r.SupplyPointUsageType__c != null && spd.Device__r.DeviceType__c != null && spd.Device__r.DeviceType__r.DeviceSize__c !=null ){                                
                                if(daduMap.containsKey(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + spd.SupplyPoint__r.SupplyPointUsageType__c)
                                   && deviceReadingMap.get(deviceId).size() > 0
                                   && daduMap.get(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + spd.SupplyPoint__r.SupplyPointUsageType__c).StartDate__c <= deviceReadingMap.get(deviceId)[0].ReadingDate__c){
                                       DefaultAverageDailyUsage__c dadu = daduMap.get(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + spd.SupplyPoint__r.SupplyPointUsageType__c);
                                       aduMap.get(deviceId).RollingDailyUsage__c = (dadu.AverageDailyUsage__c).setScale(2);
                                       aduMap.get(deviceId).Account__c=accountBelongsToDevice.get(deviceId);
                                       
                                         system.debug('888'  +   aduMap.get(deviceId).RollingDailyUsage__c);
                                   }else if(daduMap.containsKey(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + null)
                                            && deviceReadingMap.get(deviceId).size() > 0
                                            && daduMap.get(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + null).StartDate__c <= deviceReadingMap.get(deviceId)[0].ReadingDate__c){                                                                                       
                                       DefaultAverageDailyUsage__c dadu = daduMap.get(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + null);
                                       aduMap.get(deviceId).RollingDailyUsage__c = (dadu.AverageDailyUsage__c).setScale(2);
                                       aduMap.get(deviceId).Account__c=accountBelongsToDevice.get(deviceId);
                                                  system.debug('999'  +   aduMap.get(deviceId).RollingDailyUsage__c);
                                   }  	
                            }                          
                        } else if(locationId2AccountTypeMap.get(spdId2LocationIdMap.get(spd.Id)) == GlUt_AccountUtilities.HH_ACCOUNT){ // domestic customer	
                                 system.debug('99.888' );
                            if(locationId2NumActiveLocOccMap.get(spdId2LocationIdMap.get(spd.Id)) != null){                                
                                if(numOfOcc2DaduMap.containsKey(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + String.valueOf(locationId2NumActiveLocOccMap.get(spdId2LocationIdMap.get(spd.Id))))
                                   && deviceReadingMap.get(deviceId).size() > 0
                                   && numOfOcc2DaduMap.get(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + String.valueOf(locationId2NumActiveLocOccMap.get(spdId2LocationIdMap.get(spd.Id)))).StartDate__c <= deviceReadingMap.get(deviceId)[0].ReadingDate__c ){                                      
                                    DefaultAverageDailyUsage__c dadu = numOfOcc2DaduMap.get(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + locationId2NumActiveLocOccMap.get(spdId2LocationIdMap.get(spd.Id)));
                                    aduMap.get(deviceId).RollingDailyUsage__c = (dadu.AverageDailyUsage__c).setScale(2);
                                    aduMap.get(deviceId).Account__c=accountBelongsToDevice.get(deviceId);
                                          system.debug('10000'  +    aduMap.get(deviceId).RollingDailyUsage__c);
                                       
                                }else if(numOfOcc2DaduMap.containsKey(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + null)
                                         && deviceReadingMap.get(deviceId).size() > 0
                                   && numOfOcc2DaduMap.get(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + null).StartDate__c <= deviceReadingMap.get(deviceId)[0].ReadingDate__c ){
                                       DefaultAverageDailyUsage__c dadu = numOfOcc2DaduMap.get(spd.Device__r.DeviceType__r.DeviceSize__c + ',' + null);
                                       aduMap.get(deviceId).RollingDailyUsage__c = (dadu.AverageDailyUsage__c).setScale(2);
                                       aduMap.get(deviceId).Account__c=accountBelongsToDevice.get(deviceId);
                                          system.debug('11111'  +   aduMap.get(deviceId).RollingDailyUsage__c);
                                }
                            } 
                        }  // end of else if
					}                
                }
            }            
        }
            
        List<AverageDailyUsage__c> aduList = new List<AverageDailyUsage__c>(); 
        aduList = aduMap.values();    
        if(spdAvgDlyUseMap.size() > 0){
            aduList.addAll(spdAvgDlyUseMap.values()); //AT-5288 Starts/Ends here
        }   
        if(!aduList.isEmpty()){
            aduList = (List<AverageDailyUsage__c>) GlUt_FieldSecurity.cleanseFields(aduList, false);	
            Database.upsert(aduList); 
        }
    }
    /******************************************************************************
    @author         Echo:Dependra Singh
    @date           13 Mar 2019
    @description    Method is used to set custom meta data  type data for Rolling Daily Usage Setting
    *******************************************************************************/
    private static RollingDailyUsage__mdt getRollingDailyUsageSetting(){
        List<RollingDailyUsage__mdt> mdts = new  List<RollingDailyUsage__mdt>();
        if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap != null && GlUt_CustomMetaDataUtility.customMetadataRecordsMap.keyset().size()  > 0){
            if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap.containsKey(GlUt_Constants.ROLLINGDAILYUSAGEQUERY)){
                mdts = (List<RollingDailyUsage__mdt>)GlUt_CustomMetaDataUtility.customMetadataRecordsMap.get(GlUt_Constants.ROLLINGDAILYUSAGEQUERY);  
            }
        }else{
            mdts = (List<RollingDailyUsage__mdt>) new GlUt_CustomMetaDataUtility().getCustomMetadataRecords(GlUt_Constants.ROLLINGDAILYUSAGEQUERY);
        }
		if(!mdts.isEmpty()){
            return mdts[0];
        }else{
            return null;
        }
    }
 	/**********************************************************************************************
    @author         Echo: Neha R.
    @date           
    @param          
    @description    Last reading calculation
    **********************************************************************************************/    
    public static Map<Id,Reading__c> getlastYearReading(Map<Id,Date> deviceIdMap, Map<Id,List<Reading__c>> allExistingReadingOnDevice, Map<Id,Id> accountBelongsToDevice, Map<Id,List<AverageDailyUsage__c>> allADUonDeviceMap ){
        Map<Id,Reading__c> lastDeviceReading = new Map<Id,Reading__c>(); 
        
        for(Id deviceId: deviceIdMap.keySet()){
            // calculate last reading date by subtracted a year from the date and 31 days added.
            Date latestReadingDate = allExistingReadingOnDevice.get(deviceId)[0].ReadingDate__c;
            Date lastYearReadingDate = latestReadingDate.addYears(-1);   // (deviceIdMap.get(deviceId)).addYears(-1);
            lastYearReadingDate = lastYearReadingDate.addDays(31);
                               
            // reading prior to the lastYearReadingDate 
            for(Reading__c objReading: allExistingReadingOnDevice.get(deviceId)){                
                if(objReading.ReadingDate__c <= lastYearReadingDate && objReading.ReadingMethod__c == GlUt_Constants.ACTUAL &&   
                   objReading.BillableType__c == GlUt_Constants.BILLABLE && allADUonDeviceMap.containsKey(deviceId)){                                        
                    for(AverageDailyUsage__c objADU: allADUonDeviceMap.get(deviceId)){
                        if((objADU.StartDate__c == objReading.ReadingDate__c || objADU.StartDate__c == objReading.ReadingDate__c + 1) && accountBelongsToDevice.get(deviceId) == objADU.Account__c){  //belongs to same account                          
                            lastDeviceReading.put(deviceId, objReading);
                            break;
                        }
                    }
                }
                if(lastDeviceReading.containsKey(deviceId)) 
                    break;
            }
            
            
            //if sufficient readings have not been found, find any actual readings that exist after the date 
            if(!lastDeviceReading.containsKey(deviceId)){
                               
                Integer listSize = allExistingReadingOnDevice.get(deviceId).size() ;
                for(Integer i = listSize - 1 ; i >= 0 ; i--){             
                    Reading__c objReading = allExistingReadingOnDevice.get(deviceId)[i];  
                    if(objReading.ReadingDate__c != latestReadingDate && objReading.ReadingDate__c >= lastYearReadingDate && 
                       objReading.ReadingMethod__c == GlUt_Constants.ACTUAL &&  objReading.BillableType__c == GlUt_Constants.BILLABLE && allADUonDeviceMap.containsKey(deviceId)){
                        for(AverageDailyUsage__c objADU: allADUonDeviceMap.get(deviceId)){                          
                            if((objADU.StartDate__c == objReading.ReadingDate__c || objADU.StartDate__c == objReading.ReadingDate__c + 1) && accountBelongsToDevice.get(deviceId) == objADU.Account__c){  //belongs to same account                          
                                lastDeviceReading.put(deviceId, objReading);
                                break;
                            }
                        }
                    }
                   
                    if(lastDeviceReading.containsKey(deviceId)) 
                        break;                                   
                } 
            }
        }        
       
        return lastDeviceReading;
    }
   
}