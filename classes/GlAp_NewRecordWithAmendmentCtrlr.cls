/******************************************************************************
@author         Echo: Patrick Dixon
@date           26 Feb 2018
@description    Component controller for new record with amendment lightning component
@Revisions      Tarun,14-06-18,AT-2658,Added conditions to avoid Invalid readings
*******************************************************************************/
public with sharing class GlAp_NewRecordWithAmendmentCtrlr {
    
    private static final String CLASS_NAME = 'GlAp_NewRecordWithAmendmentCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           26 Feb 2018
    @param          String - the api name of the object
    @param          String - json string of new record object
    @param          List<String> - json string of records to amend objects
    @param          String - the api name of the 'amendedBy' field for the object
    @param          String selectedRecord - Last good record.
    @return         Id - the new record Id
    @description    inserts the new record and updates the records it amends
    *******************************************************************************/
    @AuraEnabled
    public static Id saveRecords(String objectName, String newRecordObject, String selectedRecords, String amendedByFieldName, String selectedRecord) {
        //Changes for AT-5193 Starts Here
        SObject selectRecord;
        if(string.isNotBlank(selectedRecord))
            selectRecord = (SObject) System.JSON.deserialize(selectedRecord, Type.forName(objectName));
        //Changes for AT-5193 Ends Here
        SObject newRecord = (SObject) System.JSON.deserialize(newRecordObject, Type.forName(objectName));
        List<SObject> recordsToAmend = (List<SObject>) System.JSON.deserialize(selectedRecords, Type.forName('List<' + objectName + '>'));
        set<Id> recordIds = new set<Id>();
        if(recordsToAmend != null && !recordsToAmend.isEmpty()){
            for(SObject objRecord  : recordsToAmend){
                recordIds.add(objRecord.Id);
            }
        }
        Savepoint sp = Database.setSavepoint();
        try {
            // save the new record
            newRecord = GlUt_FieldSecurity.cleanseFields(newRecord, false);
            /*Changes for AU2 AT-4513 Starts Here */
            if(objectName == GlUt_APIConstantsRuralGrossConsumption.RURALGROSSCONSUMPTIONAPINAME){
                //Fetch supplypoint id from record being inserted.
                Id supplyPointId = (Id)newRecord.get(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME);
                if(supplyPointId != null){
                    Set<Id> supplyPointIdSet = new Set<Id>();
                    supplyPointIdSet.add(supplyPointId);
                    List<String> queryFields = new List<String>();
                    queryFields.add(GlUt_APIConstantsSupplyPoint.RURALLICENCEAPINAME); 
                    queryFields.add(GlUt_APIConstantsSupplyPoint.RURALOUTLETBILLINGTYPEAPINAME); 
                    //Fetch supply point on the basis of supply point id.
                    List<SupplyPoint__c> supplyPointList = (List<SupplyPoint__c>) GlUt_RuralBillingUtilities.fetchSupplyPoint(queryFields,GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,supplyPointIdSet,'Id','', '','');
                    if(!supplyPointList.isEmpty()){
                        Set<Id> licenceIdSet = new Set<Id>();
                        licenceIdSet.add(supplyPointList[0].Location__r.RuralLicense__c);
                        //Fetch Active rural entitlement on the basis of licence Id.
                        List<RuralEntitlement__c> ruralEntitlementList = GlUt_RuralBillingUtilities.getActiveRuralEntitlement(licenceIdSet);
                        if(ruralEntitlementList != null){
                            //Assign rural entitlement for the record being inserted.
                            newRecord.put(GlUt_APIConstantsRuralGrossConsumption.RURALENTITLEMENTAPINAME,ruralEntitlementList[0].Id);
                            //Assign Rural out let billing type for the record being inserted.
                            newRecord.put(GlUt_APIConstantsRuralGrossConsumption.TYPEAPINAME,supplyPointList[0].RuralOutLetBillingType__c);
                        }
                    }
                }
            }
            /*Changes for AU2 AT-4513 Ends Here */
            insert newRecord;
            
            // if there are amended records
            if (recordsToAmend != null && recordsToAmend.size() > 0) {
           		/*String queryString = 'select Id, ' + amendedByFieldName + ' from ' + objectName + ' where Id in :recordsToAmend';
                system.debug('queryString'    +  queryString);
                
                // add the amended by link to the new record
                recordsToAmend = Database.query(queryString);*/
                string filterStatement = 'WHERE Id IN' + GlUt_FieldSecurity.IdsToString(recordIds);
                recordsToAmend = (List<SObject>)GlAp_LightningDataAccess.getRecords(objectName, new List<String>{amendedByFieldName},filterStatement);
                for (SObject amendedRecord : recordsToAmend) {
                    amendedRecord.put(amendedByFieldName, newRecord.Id);
                }
        
                // and save them
                if (!recordsToAmend.isEmpty()) {
                    recordsToAmend = (List<SObject>) GlUt_FieldSecurity.cleanseFields(recordsToAmend, false);
                    update recordsToAmend;                  
                }
                
                // AT-2929, if sub supply reading is amended then auto amend the main supply reading
                if(objectName == GlUt_APIConstantsReading.READINGAPINAME){
                	if(GlUt_RegionUtility.getAURegionCustomSetting()){
                        //Changes for AT-5193 Starts Here
                        List<RuralGrossConsumption__c> rgcList = [Select Id from RuralGrossConsumption__c where Reading__c=:newRecord.Id Limit 1];
                        if(rgcList != null && rgcList.size() >0 && selectRecord != null){
                            rgcList[0].StartDate__c = Date.valueOf(selectRecord.get(GlUt_APIConstantsReading.READINGDATEAPINAME));
                            rgcList[0].EndDate__c = Date.valueOf(newRecord.get(GlUt_APIConstantsReading.READINGDATEAPINAME));
                            rgcList[0].Consumption__c = Integer.valueOf(newRecord.get(GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME)) - Integer.valueOf(selectRecord.get(GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME));
                            rgcList[0] = (RuralGrossConsumption__c)GlUt_FieldSecurity.cleanseFields(rgcList[0], false);
                            update rgcList[0];
                        }
                        //Changes for AT-5193 Ends Here
                    }
                    Reading__c subReadingAmendRec = (Reading__c) newRecord;
                    Set<Id> supplyPointIds = new Set<Id>();
                    for (SupplyPointDevice__c supplyPointDevice : [SELECT Id, 
                                                                   Device__c, 
                                                                   SupplyPoint__c 
                                                                   FROM SupplyPointDevice__c 
                                                                   WHERE Device__c = :subReadingAmendRec.Device__c //AT-3174
                                                                   AND Active__c = TRUE]) {
                        supplyPointIds.add(supplyPointDevice.SupplyPoint__c);                   
                    }
                    
                    Set<Id> sprMainSPId = new Set<Id>();
                    for(SupplyPointRelationship__c objSPR : [SELECT Id,
                                                             MainSupply__c
                                                             FROM SupplyPointRelationship__c
                                                             WHERE SubSupply__c IN: supplyPointIds
                                                             AND StartDate__c <= :subReadingAmendRec.ReadingDate__c
                                                             AND (EndDate__c > :subReadingAmendRec.ReadingDate__c
                                                             OR EndDate__c = null)]){
                        sprMainSPId.add(objSPR.MainSupply__c);                                                     
                    }
                    
                    if(sprMainSPId.size() > 0){ 
                        Reading__c readingToAmend;
                        Reading__c readingAmended;
                        for (Reading__c reading : [SELECT Id,ActualDeviceReading__c,EffectiveDeviceReading__c,ReadingDate__c,Device__c,//AT-3174
                                                   Billed__c,BillableType__c,ReadingMethod__c,ReadingSource__c,ReadingType__c,AmendedByReading__c
                                                   FROM Reading__c 
                                                   WHERE Device__c IN (SELECT Device__c //AT-3174
                                                                                FROM SupplyPointDevice__c
                                                                                WHERE SupplyPoint__c IN: sprMainSPId
                                                                                AND Active__c = true)                                                     
                                                     ORDER BY ReadingDate__c DESC LIMIT 1]){ 
                                                        
                            if(reading.Billed__c && reading.BillableType__c == System.Label.CuAp_ReadingBillableTypeBillable){
                                readingAmended = reading;
                                readingToAmend = new Reading__c(); 
                                readingToAmend.ActualDeviceReading__c = reading.ActualDeviceReading__c;
                                readingToAmend.EffectiveDeviceReading__c = reading.EffectiveDeviceReading__c;
                                readingToAmend.Device__c = reading.Device__c;//AT-3174
                                readingToAmend.BillableType__c = reading.BillableType__c;
                                readingToAmend.ReadingMethod__c = reading.ReadingMethod__c;
                                readingToAmend.ReadingSource__c = reading.ReadingSource__c;
                                readingToAmend.ReadingType__c = System.Label.CuAp_ReadingReadingTypeRegular;
                                readingToAmend.ReadingDate__c = Date.today();                               
                            }               
                        }          
                        
                        if(readingAmended != null && readingToAmend != null){
                            
                            readingAmended.BillableType__c = GlUt_Constants.INVALID_BILLABLETYPE;   // AT-4192
                            readingAmended = (Reading__c)GlUt_FieldSecurity.cleanseFields(readingAmended, false);
                            update readingAmended;    // AT-4192
                            readingToAmend = (Reading__c)GlUt_FieldSecurity.cleanseFields(readingToAmend, false);
                            insert readingToAmend;      
                            readingAmended.AmendedByReading__c = readingToAmend.Id;
                            update readingAmended;                            
                        }                        
                    }
                }
            }
            return newRecord.Id;
            
        } catch (exception e) {
             //Changed by Dependra 
            //Added check for FIELD_CUSTOM_VALIDATION_EXCEPTION to return user friendly error.//
            String errorMsg = GlUt_Logger.getActualErrorMessage(e.getMessage());
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            throw new AuraHandledException(errorMsg);
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /**********************************************************************************************
    @author         Echo: Vivek AT-3412
    @date           27-Apr-2018
    @param          Id - the device Id
    @return         List<Reading__c> - readings for the device
    @description    validate Consumption Threshold
    @Revisions      
    **********************************************************************************************/    
    @AuraEnabled
    public static String validateConsumptionThreshold(String objectName , Id deviceId, String newReading , String lastReadingRecord) {
        AverageDailyUsage__c aduObj;
        ReadTimetableThresholds__c rtTableThresholdObj;
        SObject newRecord = (SObject) System.JSON.deserialize(newReading, Type.forName(objectName));
        Reading__c latestBillableReadingObj ;
        
       
        if(lastReadingRecord != null && lastReadingRecord != '') {
            SObject lastRecord = (SObject) System.JSON.deserialize(lastReadingRecord, Type.forName(objectName));
            latestBillableReadingObj = new Reading__c();
            latestBillableReadingObj =  (Reading__c) lastRecord;
        }
        Reading__c ReadingObj = (Reading__c) newRecord;
        //if a Latest Billable Reading cannot be found, save the Reading without further validation. 
        if(latestBillableReadingObj  == null)
            return  GlUt_Constants.NOERROR;
      
        SupplyPointDevice__c spdObj = getSupplyPointDevice(deviceId, ReadingObj.ReadingDate__c);
        //If Supply Point Device cannot be found that is Active as of the Reading Date.
        if(spdObj == null)
            return  GlUt_Constants.SPDINACTIVE;   
        
        if(spdObj.SupplyPoint__r.Book__c == null)  //AT-3828   fixed under AT-3854   skip validation for supply points that are not linked to a book  
            return  GlUt_Constants.NOERROR;

        aduObj = getAverageDailyUsage(spdObj.Id , ReadingObj.ReadingDate__c);
    
        //If an ADU cannot be found that is Active as of the Reading Date.
        if(aduObj == null)
            return  GlUt_Constants.ADUINACTIVE;
      
        // AT-5013 start...
        Integer newReadingMonth = (ReadingObj.ReadingDate__c).month();
        Map<Integer,String> monthsMap = new Map<Integer, String>{1 => 'January' , 2 => 'February' ,3 => 'March' ,4 => 'April' , 5 => 'May' ,
            													 6 => 'June' , 7=> 'July' , 8 => 'August' , 9 => 'September' ,
            													 10 => 'October' , 11=> 'November' ,12 => 'December'};  
        // AT-5013 end...
        if(aduObj.AverageDailyUsage__c != null)    
            rtTableThresholdObj = GlUt_ReadingUtilities.getReadTimetableThresholds(spdObj.Id, aduObj.AverageDailyUsage__c, monthsMap.get(newReadingMonth));     //AT-5013 //AT-5014 
        
        // it will pass only when Threshold where Daily Usage Threshold Start <= ADU and Daily Usage Threshold End >= ADU 
        if(rtTableThresholdObj == null)
            return GlUt_Constants.READTIMETABLETHRESHOLDINVALID;
      
        //if the Latest Billable Reading found. 
        Integer daysDiff = latestBillableReadingObj.ReadingDate__c.daysBetween(ReadingObj.ReadingDate__c); 
        // Estimated Calculation = Average Daily Usage * (Days Between Last Reading Date and Calculation Date)  
        Decimal estimateConsumption = aduObj.AverageDailyUsage__c * daysDiff ;
        
        // AT-3415 core 8b start...
        Integer newActualReading = Integer.valueOf(ReadingObj.ActualDeviceReading__c);
        if(ReadingObj.Tripped__c == true){ 
            // Modified under AT-3887
           
            String maxReading = '' ;            
            for(Integer i=0; i<spdObj.Device__r.Digit__c ; i++){
                maxReading = maxReading + '9';                
            }           
            // Reading Value = Maximum reading on device + current tripped reading + 1
            newActualReading = Integer.valueOf(maxReading) + Integer.valueOf(ReadingObj.ActualDeviceReading__c) + 1;
        }
        // AT-3415 core 8b end...
 
        //Latest Billable Reading + (Estimated Consumption / 100 * Lower Threshold Percentage)
        Decimal lowerThresholdValue = Decimal.valueOf(latestBillableReadingObj.ActualDeviceReading__c) + estimateConsumption/100 * rtTableThresholdObj.AcceptablePercentageVarianceBelow__c;
        
        
        //Upper Threshold Value = Latest Billable Reading + (Estimated Consumption / 100 * Upper Threshold Percentage)
        Decimal upperThresholdValue = Decimal.valueOf(latestBillableReadingObj.ActualDeviceReading__c) + estimateConsumption/100 * rtTableThresholdObj.AcceptablePercentageVarianceAbove__c;
        
        system.debug('upperThresholdValue  '   +  upperThresholdValue);
         system.debug('lowerThresholdValue  '   +  lowerThresholdValue);+
            system.debug('latest reading'   +  Decimal.valueOf(latestBillableReadingObj.ActualDeviceReading__c) );
        
        
        List<readingUpload__c> readingUploadList = new List<readingUpload__c>();
        //Error Reading has been rejected because it falls outside expected consumption thresholds 
        if((newActualReading < Integer.valueOf(lowerThresholdValue))){  // AT-3415 core 8b  
            //Error “Reading has been rejected because it falls outside expected consumption thresholds” 
            
            readingUpload__c readingUploadObj = new readingUpload__c();
            readingUploadObj.DeviceReference__c = deviceId;
            readingUploadObj.ReadingDate__c = ReadingObj.ReadingDate__c; 
            readingUploadObj.Reading__c = ReadingObj.Id;
            readingUploadObj.ReadingValue__c = ReadingObj.ActualDeviceReading__c;
            readingUploadObj.ReadSource__c = ReadingObj.ReadingSource__c;
            readingUploadObj.ReadingMethod__c =  ReadingObj.ReadingMethod__c ;
            readingUploadObj.ReadingType__c = ReadingObj.ReadingType__c;
            readingUploadObj.Reader__c =    ReadingObj.Reader__c;
            readingUploadObj.Manufacturer__c  =  spdObj.Device__r.DeviceType__r.Manufacturer__c;
            readingUploadObj.SerialNumber__c = spdObj.Device__r.SerialNo__c;
            readingUploadObj.Billable__c = ReadingObj.Billed__c;
            readingUploadObj.ReadingStatus__c = GlUt_Constants.ERROR;
            readingUploadObj.RejectionReason__c = LoBt_ErrorConstants.THRESHOLD_OUTSIDE;
            readingUploadList.add(readingUploadObj);
            
            readingUploadList = GlUt_FieldSecurity.cleanseFields(readingUploadList , true);
            insert readingUploadList ;
           
        }
        if(newActualReading < Integer.valueOf(lowerThresholdValue)) //AT-3854
            return GlUt_Constants.READINGREJECTED;
        else if(newActualReading  > Integer.valueOf(upperThresholdValue))
            return GlUt_Constants.READINGREJECTEDUPPER;   //AT-3854
        else
            return  GlUt_Constants.NOERROR;
    }
    
     /******************************************************************************
    @author         Echo: Vivek Sethi AT-3412
    @date           23 Aug 2018
    @param          deviceId , ReadingDate__c
    @return         Active SupplyPointDevice__c
    @description    Fetch the Supply Point Device on the basis of deviceId and Reading Date.
    *******************************************************************************/
    public static SupplyPointDevice__c getSupplyPointDevice(Id deviceId , Date readingDate ){
        List<SupplyPointDevice__c> spdList = [select Id, 
                                       Device__c,
                                       Device__r.Digit__c,
                                       Device__r.Name,
                                       Device__r.DeviceType__r.Manufacturer__c,
                                       Device__r.SerialNo__c,
                                       SupplyPoint__r.Book__c,   //AT-3828   fixed under AT-3854   skip validation for supply points that are not linked to a book  
                                       SupplyPoint__c 
                                       from SupplyPointDevice__c 
                                       where Device__c = :deviceId 
                                       AND Active__c = True 
                                       AND InstallationDate__c <=: readingDate LIMIT 1]; 
        if(!spdList.isEmpty() && spdList != null)
            return spdList[0];
        else
            return null;
    }
    
    /******************************************************************************
    @author         Echo: Vivek Sethi AT-3412
    @date           23 Aug 2018
    @param          SupplyPointDevice__c, ReadingDate__c
    @return         AverageDailyUsage__c
    @description    Fetch ADU records on the basis of SPD.
    *******************************************************************************/
    public static AverageDailyUsage__c getAverageDailyUsage(Id supplyPointDevice , Date readingDate){
        List<AverageDailyUsage__c> aduList =  [select Id,
                                               StartDate__c,
                                               EndDate__c,
                                               SupplyPointDevice__c,
                                               AverageDailyUsage__c
                                               from AverageDailyUsage__c 
                                               where SupplyPointDevice__c =:supplyPointDevice 
                                               and StartDate__c <=: readingDate
                                               and (EndDate__c = null or EndDate__c >=: readingDate) limit 1 ];
        
        
        if(!aduList.isEmpty() && aduList != null)
            return aduList[0];
        else
            return null;
    } 
      
    
    
    /**********************************************************************************************
    @author         Echo: Swati
    @date           27-Apr-2018
    @param          Id - the device Id
    @return         List<Reading__c> - readings for the device
    @description    returns the readings for a device
    @Revisions      Tarun,14-06-18,AT-2658,Added conditions to avoid Invalid readings
    **********************************************************************************************/    
    @AuraEnabled
    public static List<Reading__c> fetchDeviceReadings(Id deviceId) { 
        
        List<String> readingFields = new List<String>{
                                                    GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME, 
                                                    GlUt_APIConstantsReading.READINGDATEAPINAME                                                        
                                                    };  
        
        return (List<Reading__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME, 
                                                                      readingFields, 
                                                                      deviceId, 
                                                                      GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME, 
                                                                      GlUt_APIConstantsReading.BILLABLETYPEAPINAME + ' != \'' + Label.CuAp_ReadingBillableTypeInvalid + '\'' , //AT-2658
                                                                      'ORDER BY ' + GlUt_APIConstantsReading.READINGDATEAPINAME + ' DESC');                                           

    }
}