/******************************************************************************
@author         Echo: Neha R.
@date           22 June 2018
@description    Component controller for Leak Reading Recording lightning component
*******************************************************************************/
public class LoAp_LeakRecordingCtrlr {

    private static final String CLASS_NAME = 'LoAp_LeakRecordingCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
  
    private static List<String> readingFieldsList;    
    static{
    	readingFieldsList = new List<String>();         
        readingFieldsList.add(GlUt_APIConstantsReading.READINGAPINAME);
        readingFieldsList.add(GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME);
        readingFieldsList.add(GlUt_APIConstantsReading.READINGDATEAPINAME);
        readingFieldsList.add(GlUt_APIConstantsReading.EFFDEVICEREADINGAPINAME);
        readingFieldsList.add(GlUt_APIConstantsReading.LEAKAPINAME);
        readingFieldsList.add(GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME);
        readingFieldsList.add(GlUt_APIConstantsReading.READINGMETHODAPINAME);  
        readingFieldsList.add(GlUt_APIConstantsReading.BILLEDAPINAME);
        readingFieldsList.add(GlUt_APIConstantsReading.BILLABLETYPEAPINAME);
        readingFieldsList.add(GlUt_APIConstantsReading.TRIPPEDAPINAME);    // AT-5539
    }
    
    private static List<String> spdFieldsList;    
    static{
    	spdFieldsList = new List<String>();         
        spdFieldsList.add(GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME);
        spdFieldsList.add(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME);       
    }
    
    private static List<String> sprFieldsList;    
    static{
    	sprFieldsList = new List<String>();         
        sprFieldsList.add(GlUt_APIConstantsSupplyPointRelationship.SUBSUPPLYAPINAME);
        sprFieldsList.add(GlUt_APIConstantsSupplyPointRelationship.STARTDATEAPINAME);    
        sprFieldsList.add(GlUt_APIConstantsSupplyPointRelationship.ENDDATEAPINAME);        
    }
    
    private static List<String> deviceFieldsList;     // AT-3415 core 8b 
    static{
        deviceFieldsList = new List<String>();         
        deviceFieldsList.add(GlUt_APIConstantsDevice.DIGITSAPINAME);
        deviceFieldsList.add(GlUt_APIConstantsDevice.SERIALNOAPINAME);                   
    }
    /**********************************************************************************************
    @author         Echo:Amit K.
    @date           01 Nov 2018
    @return         Id recordId
    @description    Method to fetch the reading status i.e Invalid or Billable. 
    **********************************************************************************************/
    @AuraEnabled
    public static Boolean getReadingStatus(Id recordId) {
        Boolean readingStatus = true;
        try {
            List<Reading__c> readingList = new List<Reading__c>(); 
            String queryFilter = ' WHERE Id = \'' + recordId + '\'';
            /* Clayton Review: Sudhir commented dynamic query codes and used LightningDataAccess
            string queryString = String.format('select {0} from {1}', new List<String>{String.join(readingFieldsList, ', '),GlUt_APIConstantsReading.READINGAPINAME});
            queryString = queryString + queryFilter ;
            readingList = Database.query(queryString);
			*/
            readingList = (List<Reading__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME, 
                                                                                 readingFieldsList,
                                                                                 queryFilter) ;
            if(!readingList.isEmpty()){
                for(Reading__c objReading: readingList){
                    if(objReading.BillableType__c == LoAp_Constants.BILLABLETYPEINVALID){
                        readingStatus = false;
                        break;
                    }
                }
            }
        }catch(exception e){ 
            GlUt_Logger.logException(e);                         
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
            return readingStatus;
    }
    /**********************************************************************************************
    @author         Echo: Neha R.
    @date           21 June 2018
    @return         String
    @description    Method to return list of all active Users 
    **********************************************************************************************/
    @AuraEnabled
    public static ContainerWrapper updateLeakReading(Id recordId, String sObjectName,String effDeviceReading) {
        ContainerWrapper returnContainer;
		Reading__c currentReadingObj = new Reading__c();
        SupplyPointDevice__c activeSPDOnDevice = new SupplyPointDevice__c(); 
        List<String> deviceSubSupplyList = new List<String>();
        List<String> subDeviceList = new List<String>();
        Integer sumOfSubDevicesConsumption = 0 ;
       
        if(sObjectName == GlUt_APIConstantsReading.READINGAPINAME){
            try {
                
                // Reading Record...
                List<Reading__c> readingList = new List<Reading__c>(); 
                //Clayton Review: Sudhir added escapeSingleQuotes
                String queryFilter = ' WHERE Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
                /*
                string queryString = String.format('select {0} from {1}', new List<String>{String.join(readingFieldsList, ', '),GlUt_APIConstantsReading.READINGAPINAME});
                queryString = queryString + queryFilter ;
                readingList = Database.query(queryString);
                */
                readingList = (List<Reading__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME, 
                                                                                 readingFieldsList,
                                                                                 queryFilter) ;
                for(Reading__c objReading: readingList) {
                    currentReadingObj = objReading;
                    break;
                }
               
                if (currentReadingObj != null){ 
                    // AT-3415...core 8b start...
                    // Device degit validation                    
                    List<Device__c> deviceList = new List<Device__c>();                    
                    queryFilter = ' WHERE Id = \'' + currentReadingObj.Device__c  + '\' LIMIT 1';
                    /*
                    queryString = String.format('select {0} from {1}', new List<String>{String.join(deviceFieldsList, ', '),GlUt_APIConstantsDevice.DEVICEAPINAME});
                    queryString = queryString + queryFilter ;
                    deviceList = Database.query(queryString);
                    */
                    deviceList = (List<Device__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDevice.DEVICEAPINAME, 
                                                                                 deviceFieldsList,
                                                                                 queryFilter) ;
                    for(Device__c objDevice : deviceList){                     
                        if(objDevice != null && effDeviceReading.length() > objDevice.Digit__c ) {
                            returnContainer = new ContainerWrapper(Label.CuAp_ValidateDigits + ' ' + objDevice.SerialNo__c + ' '  + Label.CuAp_ReadingDigitError + ' ' + objDevice.Digit__c + ' ' + Label.GlUt_EffDeviceReadingInvalid, null);
                            return returnContainer;
                        } 
                    }
                    // AT-3415...core 8b end...
                    
                    if(currentReadingObj.ReadingMethod__c != GlUt_Constants.TOPUP){
                        // Effective Device Validation...
                        
                        // Supply Point Device/Supply Point on Current Reading Device
                        List<SupplyPointDevice__c> spdList = new List<SupplyPointDevice__c>();
                        queryFilter = ' WHERE ' +  GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME + ' = TRUE ' + 
                                       ' AND '  +  GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME + ' = \'' + currentReadingObj.Device__c + '\'';
                        /*
                        queryString = String.format('select {0} from {1}', new List<String>{String.join(spdFieldsList, ', '),GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME});
                        queryString = queryString + queryFilter ;
                        spdList = Database.query(queryString);
                        */
                        spdList = (List<SupplyPointDevice__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, 
                                                                                 spdFieldsList,
                                                                                 queryFilter) ;
                        for(SupplyPointDevice__c objSPD: spdList){
                            activeSPDOnDevice = objSPD;
                            break;
                        }
                        
                        // Check Current SupplyPoint is Main in Supply Point Relationship
                        List<SupplyPointRelationship__c> sprList = new List<SupplyPointRelationship__c>();
                        List<string> readingDateString = String.valueOf(currentReadingObj.ReadingDate__c).split(' ');
                        
                        queryFilter = ' WHERE '+  GlUt_APIConstantsSupplyPointRelationship.MAINSUPPLYAPINAME + ' = \'' + activeSPDOnDevice.SupplyPoint__c + '\'' +
                                      ' AND ' + GlUt_APIConstantsSupplyPointRelationship.STARTDATEAPINAME + ' <= ' + readingDateString[0] +
                                      ' AND (' + GlUt_APIConstantsSupplyPointRelationship.ENDDATEAPINAME + ' >= ' + readingDateString[0] + 
                                      ' OR ' + GlUt_APIConstantsSupplyPointRelationship.ENDDATEAPINAME + ' = null)' ; 
                        /*
                        queryString = String.format('select {0} from {1}', new List<String>{String.join(sprFieldsList, ', '),GlUt_APIConstantsSupplyPointRelationship.SUPPLYPOINTRELATIONSHIPAPINAME});
                        queryString = queryString + queryFilter ;
                        sprList = Database.query(queryString);
                        */
                        sprList = (List<SupplyPointRelationship__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointRelationship.SUPPLYPOINTRELATIONSHIPAPINAME, 
                                                                                 sprFieldsList,
                                                                                 queryFilter) ;
                        for(SupplyPointRelationship__c objSPR: sprList){
                            deviceSubSupplyList.add('\'' + String.valueOf(objSPR.SubSupply__c) + '\'');                                                                                     
                        }
                        
                        // If current device is Main... 
                        if (deviceSubSupplyList.size() > 0){
                            
                            // Set of device link to Sub Supply Point                   
                            queryFilter = ' WHERE '+  GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME + ' = TRUE ' + 
                                          ' AND ' + GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME + ' IN '+ deviceSubSupplyList; 
                            spdList.clear();
                            /*
                            queryString = String.format('select {0} from {1}', new List<String>{String.join(spdFieldsList, ', '),GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME});
                            queryString = queryString + queryFilter ;
                            spdList = Database.query(queryString);
                            */
                            spdList = (List<SupplyPointDevice__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, 
                                                                                 spdFieldsList,
                                                                                 queryFilter) ;
                            for(SupplyPointDevice__c objSPD: spdList){
                                subDeviceList.add('\'' + String.valueOf(objSPD.Device__c) + '\'');
                            } 
                            
                            if(subDeviceList.size() > 0){
                                Set<Id> deviceReadingAddedSet = new Set<Id>();
                                // Last billable reading on sub                         
                                queryFilter = ' WHERE '+  GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME + ' IN ' + subDeviceList + 
                                              ' AND ' + GlUt_APIConstantsReading.BILLABLETYPEAPINAME + ' = \'' + GlUt_Constants.BILLABLE + '\' ' + 
                                              ' AND ' + GlUt_APIConstantsReading.READINGMETHODAPINAME + ' != \'' + GlUt_Constants.TOPUP + '\''+ 
                                              ' ORDER BY ' +  GlUt_APIConstantsReading.READINGDATEAPINAME  + ' DESC'; 
                                readingList.clear();
                                /*
                                queryString = String.format('select {0} from {1}', new List<String>{String.join(readingFieldsList, ', '),GlUt_APIConstantsReading.READINGAPINAME});
                                queryString = queryString + queryFilter ;
                                readingList = Database.query(queryString);
                                */
                                readingList = (List<Reading__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME, 
                                                                                 readingFieldsList,
                                                                                 queryFilter) ;
                                for(Reading__c objReading : readingList){                                
                                    if(! deviceReadingAddedSet.contains(objReading.Device__c)){
                                        sumOfSubDevicesConsumption = sumOfSubDevicesConsumption + Integer.valueOf(objReading.ActualDeviceReading__c);
                                        deviceReadingAddedSet.add(objReading.Device__c);
                                    }
                                }
                            }
                        }
                        
                        // Consumption Exist on Sub Devices
                        if (sumOfSubDevicesConsumption > 0){
                            Integer currentActualDeviceReading = Integer.valueOf(currentReadingObj.ActualDeviceReading__c);
                            Integer currentEffDeviceReading = Integer.valueOf(effDeviceReading);                        
                            Integer calculatedEffDeviceReading = currentActualDeviceReading - sumOfSubDevicesConsumption;                        
                            if(calculatedEffDeviceReading < currentEffDeviceReading){
                                // Total of Sub consumption is greater than the ActualReading value of the Main
                                returnContainer = new ContainerWrapper(Label.GuAp_NoRecordUpdated + ' ' + Label.GlUt_EffDeviceReadingInvalid, null);
                                return returnContainer;
                            }
                        } 
                	}
                    currentReadingObj.Leak__c = true;
                    Reading__c newReading = new Reading__c();
                    system.debug('5012.....currentReadingObj ' + currentReadingObj);
                    if(currentReadingObj.Billed__c){
                       newReading = currentReadingObj.clone(false, false, false, false);
                       newReading.Leak__c = true;
                       newReading.EffectiveDeviceReading__c = effDeviceReading;
                       newReading.Billed__c = false;
                       //AT-5539 start...
                       currentReadingObj.BillableType__c = GlUt_Constants.INVALID_BILLABLETYPE;  
                       currentReadingObj = (Reading__c)GlUt_FieldSecurity.cleanseFields(currentReadingObj, false);
                       Database.update(currentReadingObj);
                       // AT-5539 end...
                       newReading = (Reading__c) GlUt_FieldSecurity.cleanseFields(newReading, false);
                       Database.insert(newReading);
                        system.debug('5013....newReading ' + newReading);
                       currentReadingObj.AmendedByReading__c = newReading.Id;
                        
                    }else{
                        List<AverageDailyUsage__c> updateADUList = new List<AverageDailyUsage__c>();
                        currentReadingObj.EffectiveDeviceReading__c = effDeviceReading;
                    }
                    currentReadingObj = (Reading__c) GlUt_FieldSecurity.cleanseFields(currentReadingObj, false);
                    Database.update(currentReadingObj);
                    // record successfull
                    returnContainer = new ContainerWrapper(Label.GuAp_RecordSuccessfullyUpdatedMsg, newReading.Id);
                    
                    system.debug('5014.....' + [select Id, Billed__c from Reading__c where Id =: newReading.Id limit 1]);
                    return returnContainer;
                } 
            }catch(exception e){ 
                GlUt_Logger.logException(e);                         
            }
            finally {
                GlUt_Logger.writeLogsToDatabase();
            }
        }
         returnContainer = new ContainerWrapper(Label.GuAp_NoRecordUpdated, null);
         return returnContainer;
        
    }
    /**********************************************************************************************
    @author         Echo: Amit K.
    @date           01 Nov 2018
    @return         NA
    @description    Wrapper class for holding success/error reason messages and finalReading Id in case of reading amendments.
    **********************************************************************************************/
    public class ContainerWrapper {
        @AuraEnabled public String message; 
        @AuraEnabled public Id finalReadingId;
        
        public ContainerWrapper(String message, Id finalReadingId){
            this.message = message;
            this.finalReadingId = finalReadingId;
        }
    }
        
}