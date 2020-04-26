/******************************************************************************
@author         Echo: Ankit Gangwani
@date           22-May-2018
@description    Component controller for Setting up payment plan
@revesion       Changes by Dependra Singh - Security Review - 20-09-2018 - AT-3746
*******************************************************************************/
public with sharing class LoAp_ManageReadingImportCtrlr {
    
    private static final String CLASS_NAME = 'LoAp_ManageReadingImportCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static List<String> readingUploadList;
    private static List<String> readingList;
    private static List<String> deviceList;
    private static List<String> supplyPointDeviceList;
    private static List<String> supplyPointList;
    private static List<String> locationList;
    private static String COMPANY_REQUEST = System.Label.LoAp_CompanyRequestLabel;
    private static Decimal lastReading;
    private static String ReadingThresholdErrorValue;  //AT-3855
    
    
    Static{
        //Get Fields from the Reading Upload Object
        readingUploadList = new List<string>();
        readingUploadList.add(GlUt_APIConstantsReadingUpload.SERIALNOAPINAME);
        readingUploadList.add(GlUt_APIConstantsReadingUpload.MANUFACTURERAPINAME);
        readingUploadList.add(GlUt_APIConstantsReadingUpload.DEVICEREFERENCEAPINAME);
        readingUploadList.add(GlUt_APIConstantsReadingUpload.READINGDATEAPINAME);
        readingUploadList.add(GlUt_APIConstantsReadingUpload.READINGVALUEAPINAME);  //AT - 3174        
        readingUploadList.add(GlUt_APIConstantsReadingUpload.READINGMETHODAPINAME);  
        readingUploadList.add(GlUt_APIConstantsReadingUpload.READSOURCEAPINAME); 
        readingUploadList.add(GlUt_APIConstantsReadingUpload.REJECTIONREASONAPINAME); 
        readingUploadList.add(GlUt_APIConstantsReadingUpload.READINGTYPEAPINAME); 
        readingUploadList.add(GlUt_APIConstantsReadingUpload.BILLABLEAPINAME);
     //   readingUploadList.add(GlUt_APIConstantsReadingUpload.PROCESSEDAPINAME);        
        readingUploadList.add(GlUt_APIConstantsReadingUpload.READPERIODIDAPINAME);
        readingUploadList.add(GlUt_APIConstantsReadingUpload.CHECKSITOLERANCEAPINAME); // UL-21, Ankit, 21/02/2019
        readingUploadList.add(GlUt_APIConstantsReadingUpload.READINGSTATUSAPINAME); // CLB-18, Ankit, 01/04/2019
        readingUploadList.add(GlUt_APIConstantsReadingUpload.TRIPPEDAPINAME); // SIT005 Readiness, Gopal Gupta, 05/04/2019
        
        //Get Fields from the Device Object
        deviceList = new List<String>();
        deviceList.add(GlUt_APIConstantsDevice.ID);
        deviceList.add(GlUt_APIConstantsDevice.DIGITSAPINAME);
        
        //Get Fields from the Supply Point Device Object
        supplyPointDeviceList = new List<String>();
        supplyPointDeviceList.add(GlUt_APIConstantsSupplyPointDevice.Id);
        supplyPointDeviceList.add(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME);
        supplyPointDeviceList.add(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTBOOKAPINAME);   //AT-3855
    
        
        //Get Fields from the Supply Point Object
        supplyPointList = new List<String>();
        supplyPointList.add(GlUt_APIConstantsSupplyPoint.ID);
        supplyPointList.add(GlUt_APIConstantsLocation.LOCATIONAPINAME);
        
        //Get Fields from the Location Object
        locationList = new List<String>();
        locationlist.add(GlUt_APIConstantsLocation.LOCATIONID);
        locationlist.add(GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME);
    }
    
    /**********************************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 22-May-2018
    @params      : None
    @return      : List<List<GLAp_FieldProps>>
    @description : This method returns back Reading Upload related fields as List 
    **********************************************************************************************/   
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrieveReadingUploadFields() {
        try {
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            List<GLAp_FieldProps> locReadingUploadList = new List<GLAp_FieldProps>();
            List<GLAp_FieldProps> readingUploadList = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReadingUpload.READINGUPLOADEAPINAME, readingUploadList);
            List<GLAp_FieldProps> locationList      = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsLocation.LOCATIONAPINAME, locationlist); 
            
            for(GLAp_FieldProps locRead: readingUploadList){
                
                locRead.isEditable = false;
                if(locRead.fieldName == GlUt_APIConstantsReadingUpload.SERIALNOAPINAME){
                    locRead.fieldLabel = CuAp_Constants.DEVICESETIALNUMBER;
                    locReadingUploadList.add(locRead);
                }
                
                if(locRead.fieldName == GlUt_APIConstantsReadingUpload.MANUFACTURERAPINAME){
                    locRead.fieldLabel = CuAp_Constants.DEVICEMANUFACTURER;
                    locReadingUploadList.add(locRead);
                }     
                
                if(locRead.fieldName == GlUt_APIConstantsReadingUpload.DEVICEREFERENCEAPINAME){
                    locReadingUploadList.add(locRead);
                }  
                
                if(locRead.fieldName == GlUt_APIConstantsReadingUpload.READINGDATEAPINAME){
                    locReadingUploadList.add(locRead);
                }  
                
                if(locRead.fieldName == GlUt_APIConstantsReadingUpload.READINGVALUEAPINAME){ //AT - 3174
                    locReadingUploadList.add(locRead);
                }  
                
                if(locRead.fieldName == GlUt_APIConstantsReadingUpload.READINGMETHODAPINAME){
                    locReadingUploadList.add(locRead);
                }  
                
                if(locRead.fieldName == GlUt_APIConstantsReadingUpload.READSOURCEAPINAME){
                    locReadingUploadList.add(locRead);
                }  
                
                if(locRead.fieldName == GlUt_APIConstantsReadingUpload.REJECTIONREASONAPINAME){
                    locReadingUploadList.add(locRead);
                }  
                if(locRead.fieldName == GlUt_APIConstantsReadingUpload.READINGTYPEAPINAME){
                    locReadingUploadList.add(locRead);
                }             
            }
            
            for(GLAp_FieldProps locProp: locationList){
                locProp.isEditable = false;
                if(locProp.fieldName == GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME){
                    locReadingUploadList.add(locProp);
                }
            }
            
            GLAp_FieldProps overrideReading = new GLAp_FieldProps();
            overrideReading.isFLSVisible = true;
            overrideReading.isEditable = true;
            overrideReading.editMode = true;
            overrideReading.fieldName = CuAp_Constants.OVERRIDEREADINGAPINAME;
            overrideReading.fieldLabel = CuAp_Constants.OVERRIDEFIELDLABEL;
            overrideReading.fieldType = 'checkbox';
            overrideReading.changeEvent = true;
            overrideReading.parentObject = GlUt_APIConstantsReading.READINGAPINAME;            
            locReadingUploadList.add(overrideReading);
            
            GLAp_FieldProps overrideValue = new GLAp_FieldProps();
            overrideValue.isFLSVisible = true;
            overrideValue.isEncrypted = false;
            overrideValue.isEditable = true;
            overrideValue.isRequired = false;
            overrideValue.fieldName = CuAp_Constants.OVERRIDEVALUEAPINAME;
            overrideValue.fieldLabel = CuAp_Constants.OVERRIDEVALUELABEL;
            overrideValue.fieldType = 'number';            
            overrideValue.parentObject = GlUt_APIConstantsReading.READINGAPINAME;
            locReadingUploadList.add(overrideValue);
            
            GLAp_FieldProps requestReading = new GLAp_FieldProps();
            requestReading.isFLSVisible = true;
            requestReading.isEncrypted = false;
            requestReading.isEditable = true;
            requestReading.isRequired = false;
            requestReading.fieldName = CuAp_Constants.REQUESTREADINGAPINAME;
            requestReading.fieldLabel = CuAp_Constants.REQUESTREADINGLABEL;
            requestReading.fieldType = 'checkbox'; 
            requestReading.changeEvent = true;
            requestReading.parentObject = GlUt_APIConstantsReading.READINGAPINAME;
            locReadingUploadList.add(requestReading);
            
            GLAp_FieldProps requestedDate = new GLAp_FieldProps();
            requestedDate.isFLSVisible = true;
            requestedDate.isEncrypted = false;
            requestedDate.isEditable = true;
            requestedDate.editMode = true;
            requestedDate.isRequired = false;
            requestedDate.fieldName = CuAp_Constants.REQUESTEDDATEAPINAME;
            requestedDate.fieldLabel = CuAp_Constants.REQUESTEDDATELABEL;
            requestedDate.fieldType = 'date';            
            requestedDate.parentObject = GlUt_APIConstantsReading.READINGAPINAME;
            locReadingUploadList.add(requestedDate);
            
            //AT-3855
            GLAp_FieldProps requestHighReading = new GLAp_FieldProps();
            requestHighReading.isFLSVisible = true;
            requestHighReading.isEncrypted = false;
            requestHighReading.isEditable = true;
            requestHighReading.isRequired = false;
            requestHighReading.fieldName = CuAp_Constants.HIGHREADINGAPINAME; 
            requestHighReading.fieldLabel = CuAp_Constants.HIGHREADINGAPINAME;
            requestHighReading.fieldType = 'checkbox'; 
            requestHighReading.changeEvent = true;
            requestHighReading.parentObject = GlUt_APIConstantsReading.READINGAPINAME;
            locReadingUploadList.add(requestHighReading);
            
            //UL-21, Ankit, 21/02/2019
            for(GLAp_FieldProps locRead: readingUploadList){                                
                if(locRead.fieldName == GlUt_APIConstantsReadingUpload.CHECKSITOLERANCEAPINAME){
                    locRead.isEditable = true;
                    locRead.fieldLabel = CuAp_Constants.CHECKBILLINGTOLERANCE;
                    locReadingUploadList.add(locRead);
                }
            }
            for(integer i=0; i < locReadingUploadList.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(locReadingUploadList[i]);
                
                if(secondEntryIndex < locReadingUploadList.size()){
                    lstEntry.add(locReadingUploadList[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
            }
            return twoColFormattedList;
        } 
        catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } 
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }  
    } 
    
    /**********************************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 22-May-2018
    @param       : String readingUploadValues, String overrideValue, 
                   Id deviceId, Id readingUploadId, Id supplyPointId, 
                   String mode  
    @return      : Boolean
    @description : This methodis used to save reding records.
    **********************************************************************************************/
    @AuraEnabled
    public static String saveReadingRecord(String readingUploadValues, String overrideValue, Id deviceId, Id readingUploadId, Id supplyPointId, String mode , Boolean highreading , Id supplyPointDeviceId, Boolean checkBillingTolerance){
        try{            
            String errorValue;    //AT-3855
            ReadingUpload__c objReadingUpload = (ReadingUpload__c)JSON.deserialize(readingUploadValues, ReadingUpload__c.class);        
            // This is not override so we need to update the actual device reading same as reading..
            if(mode == System.Label.LoAp_Accept)
                overrideValue = objReadingUpload.ReadingValue__c ;
            if(deviceId != null){
                Id readingModeId = getReadingMode(objReadingUpload.ReadPeriodId__c, supplyPointId);
                if(readingModeId != null) { 
                    errorValue = createReadingRecord(deviceId, overrideValue, objReadingUpload, readingModeId, readingUploadId , supplyPointDeviceId , highreading, checkBillingTolerance);                                
                }
            }     
            return errorValue;
        } 
        catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } 
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }  
    }
    
    /**********************************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 22-May-2018
    @param       : String readingUploadValues, String overrideValue, 
                   Id deviceId, Id readingUploadId, Id supplyPointId, 
                   String amendedByFieldName, String selectedRecord
    @return      : Map<String,String>
    @description : Method is used to create and amend reading records.
    **********************************************************************************************/
    @AuraEnabled
    public static Map<String,String> saveAmendPrevious(String readingUploadValues, String overrideValue, Id deviceId, Id readingUploadId, Id supplyPointId, String amendedByFieldName, String selectedRecord , Boolean highreading , Id supplyPointDeviceId, Boolean checkBillingTolerance){
        try {
            Reading__c newRecord = (Reading__c) System.JSON.deserialize(selectedRecord, Type.forName(GlUt_APIConstantsReading.READINGAPINAME));        
            
            Map<String,String> mapIds = new Map<String,String>();
            
            String strDate = string.valueOf(newRecord.ReadingDate__c);
            List<string> lstString = strDate.split(' ');
            List<Reading__c> readingListToAmend = new List<Reading__c>();       
            
            // Need to add the logic for generate an Amendment Bill
            Boolean isSuccess = false;
            ReadingUpload__c objReadingUpload = (ReadingUpload__c)JSON.deserialize(readingUploadValues, ReadingUpload__c.class);        
            
            // This is not override so we need to update the actual device reading same as reading..
            overrideValue = objReadingUpload.ReadingValue__c ;
            if(deviceId != null){
                if(newRecord != null && supplyPointdeviceId != null && highReading == false)   //AT-3855 skip Threshold validation for supply points that are not linked to a book  
                {    
                    String errorValue = GlUt_ReadingUtilities.validateConsumptionThreshold(supplyPointdeviceId, Integer.valueOf(newRecord.Reading__c), Integer.valueOf(overrideValue),  newRecord.ReadingDate__c , objReadingUpload.ReadingDate__c);
                    if(errorValue != GlUt_Constants.NOERROR) {
                        mapIds.put(GlUt_Constants.ERROR,errorValue);
                        return mapIds;
                    }
                }
                Id readingModeId = getReadingMode(objReadingUpload.ReadPeriodId__c, supplyPointId);
                if(readingModeId != null){
                    Reading__c objReading = new Reading__c();
                    objReading.Device__c = deviceId;
                    objReading.ActualDeviceReading__c = overrideValue;
                    objReading.ReadingDate__c = objReadingUpload.ReadingDate__c;
                    objReading.ReadingMethod__c = objReadingUpload.ReadingMethod__c;
                    objReading.ReadingSource__c = objReadingUpload.ReadSource__c;
                    objReading.ReadingType__c = LoAp_Constants.Regular;
                    objReading.Tripped__c = objReadingUpload.Tripped__c; // SIT005 Readiness, Gopal Gupta, 05/04/2019
                    objReading.HighReading__c = highreading;   //AT-3855
                    objReading.CheckServiceItemTolerance__c = checkBillingTolerance; // UL-21, Ankit, 21/02/2019
                    objReading.BillableType__c = (objReadingUpload.Billable__c ? LoAp_Constants.Billable : LoAp_Constants.NonBillable);
                    
                    objReading = (Reading__c)GlUt_FieldSecurity.cleanseFields(objReading, false); 
                    insert objReading; 
                    
                    ScheduledRead__c objScheduleRead;
                    if(objReading.Id != null){
                        mapIds.put(LoAp_Constants.readingId, objReading.Id);
                        /* Clayton Review - Sudhir commented dynamic query codes and used GlAp_LightningDataAccess and escapeSingleQuotes
                        String queryString = 'SELECT Id, ' + GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME + ',' + amendedByFieldName + 
                            ' FROM ' + GlUt_APIConstantsReading.READINGAPINAME + ' WHERE Id != \'' + objReading.Id + '\'' + 
                            ' AND ' + GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME + ' = \'' + String.escapeSingleQuotes(deviceId) + '\'' + 	// Clayton Review: Sudhir added escapeSingleQuotes
                            ' AND ' + GlUt_APIConstantsReading.BILLABLETYPEAPINAME + ' != \'' + System.Label.CuAp_ReadingBillableTypeInvalid + '\'' + 
                            ' AND ' + GlUt_APIConstantsReading.READINGDATEAPINAME + ' > ' + lstString[0];
                
                        readingListToAmend = Database.query(queryString);
						*/
                       
                        String filterSttement = ' WHERE Id != \'' + objReading.Id + '\'' + 
                            ' AND ' + GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME + ' = \'' + String.escapeSingleQuotes(deviceId) + '\'' + 
                            ' AND ' + GlUt_APIConstantsReading.BILLABLETYPEAPINAME + ' != \'' + System.Label.CuAp_ReadingBillableTypeInvalid + '\'' + 
                            ' AND ' + GlUt_APIConstantsReading.READINGDATEAPINAME + ' > ' + lstString[0] ;
                        readingListToAmend = (List<Reading__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME, 
                                                                                                      new list<String> {GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME, 
                                                                                                          amendedByFieldName},
                                                                                                      filterSttement) ;
                       
                        mapIds.put(LoAp_Constants.amendListSize, String.valueOf(readingListToAmend.size()));
                        if(!readingListToAmend.isEmpty()){
                            for(Reading__c objAmendReading : readingListToAmend){
                                objAmendReading.AmendedByReading__c = objReading.Id;
                            }
                            readingListToAmend = (List<Reading__c>)GlUt_FieldSecurity.cleanseFields(readingListToAmend, false);
                            update readingListToAmend;
                        }
                        objScheduleRead = new ScheduledRead__c();
                        objScheduleRead.Reading__c = objReading.Id;
                        objScheduleRead.ReadPeriod__c = objReadingUpload.ReadPeriodId__c;
                        objScheduleRead.ReadingMode__c = readingModeId; 
                        objScheduleRead = (ScheduledRead__c)GlUt_FieldSecurity.cleanseFields(objScheduleRead, false); 
                        insert objScheduleRead;                
                    }
                    
                    ReadingUpload__c currentReadingUpload = (ReadingUpload__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsReadingUpload.READINGUPLOADEAPINAME,
                                                                                                                  readingUploadId, 
                                                                                                                  readingUploadList);
                    if(currentReadingUpload.Id != null){
                        currentReadingUpload.ReadingValue__c  = overrideValue;
                        //currentReadingUpload.Processed__c = true;
                        currentReadingUpload.ReadingStatus__c = GlUt_Constants.PROCESSED; // CLB-18, Ankit, 01/04/2019
                        currentReadingUpload.CheckServiceItemTolerance__c = checkBillingTolerance; //UL-21, Ankit, 21/02/2019  
                        currentReadingUpload = (ReadingUpload__c)GlUt_FieldSecurity.cleanseFields(currentReadingUpload, false);
                        update currentReadingUpload;
                    }
                    if(objReading.Id != null && objScheduleRead.Id != null && currentReadingUpload.ReadingStatus__c == GlUt_Constants.PROCESSED && currentReadingUpload.Id != null){
                        mapIds.put(LoAp_Constants.scheduleReadId,objScheduleRead.Id);
                        //mapIds.put(LoAp_Constants.processed,String.valueOf(currentReadingUpload.Processed__c));
                        mapIds.put(LoAp_Constants.processed,currentReadingUpload.ReadingStatus__c); //CLB-18, Ankit, 01/04/2019
                    }
                }
            }     
            return mapIds; 
        } 
        catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } 
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }  
    }
    
    /**********************************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 22-May-2018
    @param       : String requestedDate, Id supplyPointId
    @return      : Boolean
    @description : This method returns the contract details
    **********************************************************************************************/
    @AuraEnabled
    public static Boolean saveRequestRead(String requestedDate, Id supplyPointId){
        try {
            Boolean isSuccess = false;
            if(supplyPointId != null){
                ReadingRequest__c objRR = new ReadingRequest__c();
                objRR.SupplyPoint__c = supplyPointId;
                objRR.ReadReason__c = COMPANY_REQUEST;
                objRR.Status__c = LoAp_Constants.NewLabel;
                objRR.ReadbyDate__c = Date.valueOf(requestedDate);
                objRR = (ReadingRequest__c)GlUt_FieldSecurity.cleanseFields(objRR, false);
                insert objRR;
                
                if(objRR.Id != null)
                    isSuccess = true;
                else
                    isSuccess = false;
            }
            else
                isSuccess = false;
            
            return isSuccess;
        } 
        catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } 
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }  
    }   
    
    /**********************************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 22-May-201
    @param       : Id readingUploadId
    @return      : Map<String,String>
    @description : This method returns of reading upload, location and device fields.
    **********************************************************************************************/
    @AuraEnabled
    public static Map<String,String> getReadingUploadDetails(Id readingUploadId){
        
        try {
            Map<String,String> mapReadingUploadDetails = new Map<String,String>();
            ReadingUpload__c objReadingUpload;
            String whereClause;
            objReadingUpload = (ReadingUpload__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsReadingUpload.READINGUPLOADEAPINAME,
                                                                                     readingUploadId, 
                                                                                     readingUploadList);
            
            if(objReadingUpload.Id != null){
                mapReadingUploadDetails.put(GlUt_APIConstantsReadingUpload.SERIALNOAPINAME,         objReadingUpload.SerialNumber__c);
                mapReadingUploadDetails.put(GlUt_APIConstantsReadingUpload.MANUFACTURERAPINAME,     objReadingUpload.Manufacturer__c);
                mapReadingUploadDetails.put(GlUt_APIConstantsReadingUpload.DEVICEREFERENCEAPINAME,  objReadingUpload.DeviceReference__c);
                mapReadingUploadDetails.put(GlUt_APIConstantsReadingUpload.READINGDATEAPINAME,      String.valueOf(objReadingUpload.ReadingDate__c));
                mapReadingUploadDetails.put(GlUt_APIConstantsReadingUpload.READINGVALUEAPINAME,     objReadingUpload.ReadingValue__c );  //AT - 3174
                mapReadingUploadDetails.put(GlUt_APIConstantsReadingUpload.READINGMETHODAPINAME,    objReadingUpload.ReadingMethod__c);
                mapReadingUploadDetails.put(GlUt_APIConstantsReadingUpload.READSOURCEAPINAME,       objReadingUpload.ReadSource__c);
                mapReadingUploadDetails.put(GlUt_APIConstantsReadingUpload.REJECTIONREASONAPINAME,  objReadingUpload.RejectionReason__c);
                mapReadingUploadDetails.put(GlUt_APIConstantsReadingUpload.READINGTYPEAPINAME,      objReadingUpload.ReadingType__c);
                mapReadingUploadDetails.put(GlUt_APIConstantsReadingUpload.BILLABLEAPINAME,         String.valueOf(objReadingUpload.Billable__c));
                mapReadingUploadDetails.put(GlUt_APIConstantsReadingUpload.READPERIODIDAPINAME,     String.valueOf(objReadingUpload.ReadPeriodId__c));
                //mapReadingUploadDetails.put(GlUt_APIConstantsReadingUpload.PROCESSEDAPINAME,        String.valueOf(objReadingUpload.Processed__c));
                mapReadingUploadDetails.put(GlUt_APIConstantsReadingUpload.CHECKSITOLERANCEAPINAME, String.valueOf(objReadingUpload.CheckServiceItemTolerance__c)); // UL-21, Ankit, 21/02/2019
                mapReadingUploadDetails.put(GlUt_APIConstantsReadingUpload.READINGSTATUSAPINAME, 	objReadingUpload.ReadingStatus__c); // CLB-18, Ankit, 01/04/2019
                mapReadingUploadDetails.put(GlUt_APIConstantsReadingUpload.TRIPPEDAPINAME,        	String.valueOf(objReadingUpload.Tripped__c)); // SIT005 Readiness, Gopal Gupta, 05/04/2019
                
				
                whereClause = ' WHERE ' + GlUt_APIConstantsDeviceType.MANUFACTUREAPINAME + ' = \'' + objReadingUpload.Manufacturer__c + '\''; 
                /* Clayton Review - Sudhir commented dynamic query codes and used GlAp_LightningDataAccess
                String soqlDeviceTypeQuery ='';                     
                soqlDeviceTypeQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id ', 
                    GlUt_APIConstantsDeviceType.DEVICETYPEAPINAME + whereClause});
                
                // get all the reading upload records 
                List<DeviceType__c> deviceTypeList = Database.query(soqlDeviceTypeQuery);   
				*/
                //Not including 'Id' in the fieldList as GlUt_FieldSecurity.cleanseFields(..) adds it
                
                List<DeviceType__c> deviceTypeList = (List<DeviceType__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDeviceType.DEVICETYPEAPINAME,
                                                                                                               new list<String> {GlUt_APIConstantsDeviceType.ID},
                                                                                                               whereClause) ;
                
                Set<Id> deviceTypeIdSet = new Set<Id>(); 
                if(deviceTypeList != null && !deviceTypeList.isEmpty()){
                    for(DeviceType__c objDT : deviceTypeList){
                        deviceTypeIdSet.add(objDT.Id);
                    }
                }
                
                if(!deviceTypeIdSet.isEmpty()){
                    whereClause = String.format('WHERE {0} IN {1}',new List<String>{GlUt_APIConstantsDeviceType.DEVICETYPEAPINAME,GlUt_FieldSecurity.IdsToString(deviceTypeIdSet)});
                    whereClause = whereClause + ' AND ' + GlUt_APIConstantsDevice.SERIALNOAPINAME + ' = \'' + objReadingUpload.SerialNumber__c + '\'';
                    List<Device__c> listDevice = GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDevice.DEVICEAPINAME, 
                                                                                     deviceList,
                                                                                     whereClause);   
                    if(listDevice != null && !listDevice.isEmpty()){
                        mapReadingUploadDetails.put(LoAp_Constants.DeviceId,listDevice[0].Id);
                        lastReading = getLatestReading(listDevice[0].Id);
                        mapReadingUploadDetails.put(LoAp_Constants.lastReading,String.valueOf(lastReading));
                        mapReadingUploadDetails.put(LoAp_Constants.DeviceDigit,String.valueOf(listDevice[0].Digit__c));
                        
                        whereClause = 'WHERE ' + GlUt_APIConstantsDevice.DEVICEAPINAME + ' = \'' + listDevice[0].Id + '\'';
                        whereClause = whereClause + ' AND ' + GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME + ' = TRUE ';
                        List<SupplyPointDevice__c> listSPD = GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, 
                                                                                                 supplyPointDeviceList,
                                                                                                 whereClause);
                        
                        if(!listSPD.isEmpty()){
                            
                           
                            if(listSPD[0].SupplyPoint__c != null){   
                                if(listSPD[0].SupplyPoint__r.Book__c != null)  //skip Threshold validation for supply points that are not linked to a book  
                                    mapReadingUploadDetails.put(LoAp_Constants.SupplyPointDeviceId,listSPD[0].Id); 
                                else
                                    mapReadingUploadDetails.put(LoAp_Constants.SupplyPointDeviceId,NULL);
                                
                                /*  AT-3855  */
                                SupplyPoint__c objSP = (SupplyPoint__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,
                                                                                                           listSPD[0].SupplyPoint__c, 
                                                                                                           supplyPointList);
                                if(objSP.Id != null && objSP.Location__c != null){
                                    mapReadingUploadDetails.put(LoAp_Constants.supplyPointId,objSP.Id);
                                    Location__c objLocation = (Location__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsLocation.LOCATIONAPINAME,
                                                                                                               objSP.Location__c, 
                                                                                                               locationList);
                                    if(objLocation.Id != null){
                                        mapReadingUploadDetails.put(GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME, objLocation.Address__c); 
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }    
            return mapReadingUploadDetails;
        } 
        catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } 
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }  
    }
    
    /**********************************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 22-May-2018
    @param       : Id readingUploadReadPerioidId, Id supplyPointId
    @return      : Id
    @description : This method used to get reading mode id by paasing reading upload period id and supply point id.
    **********************************************************************************************/
    @AuraEnabled
    public static Id getReadingMode(Id readingUploadReadPerioidId, Id supplyPointId){
        try{
            Id readingModeId;
            Depot__c objDepot = new Depot__c(); 
            List<ReadingMode__c> objReadingMode = new List<ReadingMode__c>(); 
            
            if(supplyPointId != null){
                //Clayton Review: Sudhir commented and used GlAp_LightningDataAccess to enforce CRUD/FLS
                //SupplyPoint__c objSP = [SELECT Id, Book__c, Depot__c FROM SupplyPoint__c WHERE Id = :supplyPointId];
                SupplyPoint__c objSP = (SupplyPoint__c) GlAp_LightningDataAccess.getRecordByIdAndFieldList(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,
                                                                                                           supplyPointId,
                                                                                                           new list<String> {GlUt_APIConstantsSupplyPoint.BOOKAPINAME, GlUt_APIConstantsDepot.DEPOTAPINAME}) ;
                if(objSP.Depot__c != null){
                    //Clayton Review: Sudhir commented and used GlAp_LightningDataAccess to enforce CRUD/FLS
                    //objDepot = [SELECT Id, Area__c FROM Depot__c WHERE Id = :objSP.Depot__c];
                    objDepot = (Depot__c) GlAp_LightningDataAccess.getRecordByIdAndFieldList(GlUt_APIConstantsDepot.DEPOTAPINAME,
                                                                                             objSP.Depot__c,
                                                                                             new list<String> {GlUt_APIConstantsDepot.AREAAPINAME, GlUt_APIConstantsDepot.DEPOTAPINAME}) ;
                }
                if(readingUploadReadPerioidId != null) {
                    //Clayton Review: Sudhir commented and used GlAp_LightningDataAccess to enforce CRUD/FLS                    
                    /*
                    objReadingMode = [SELECT Id 
                    FROM ReadingMode__c 
                    WHERE ReadPeriod__c = :readingUploadReadPerioidId 
                    AND ((Book__c != null AND Book__c = :objSP.Book__c)
                    OR (Depot__c != null AND Depot__c = :objSP.Depot__c)
                    OR (Area__c != null AND Area__c = :objDepot.Area__c)) LIMIT 1];
                    */
                    /*String filterStatement = ' WHERE (' + 
                        '(Book__c  != ' + null + ' AND Book__c = ' + '\'' + objSP.Book__c + '\'' + ')' + 
                        'OR' +
                        '(Depot__c != ' + null + ' AND Depot__c = \'' + objSP.Depot__c + '\'' + ')' +
                        'OR' + 
                        '(Area__c != ' + null + ' AND Area__c = \'' +  objDepot.Area__c + '\'' + ')'  +
                        ')' ;*/
                    
                    String filterStatement = ' WHERE ' ;
                    if (objSP.Book__c != null)
                        filterStatement +=  ' Book__c = ' + '\'' + objSP.Book__c + '\'';
                    if (objSP.Depot__c != null)
                        filterStatement +=  ' OR Depot__c = \'' + objSP.Depot__c + '\'';
                    if (objDepot.Area__c != null)
                        filterStatement +=  ' OR Area__c = \'' + objDepot.Area__c + '\'';
                    
                    objReadingMode = (List<ReadingMode__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReadingMode.READINGMODEAPINAME,
                                                                                                new list<String> {'Id'},
                                                                                                filterStatement) ;
                    if(objReadingMode != null && !objReadingMode.isEmpty())
                        readingModeId = objReadingMode[0].Id;
                    else
                        readingModeId = null;
                }
            }
            return readingModeId;
        } 
        catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } 
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }  
        
    } 
    
    /**********************************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 22-May-2018
    @param       : Id deviceId, String overrideValue, ReadingUpload__c objReadingUpload, Id readingModeId, Id readingUploadId
    @return      : Map<String,String>
    @description : This method is used to create reading records by passing some parameter.
    **********************************************************************************************/
    @AuraEnabled
    public static String createReadingRecord(Id deviceId, String overrideValue, ReadingUpload__c objReadingUpload, Id readingModeId, Id readingUploadId, Id supplyPointdeviceId , Boolean highReading, Boolean checkBillingTolerance) {
        
        try{
            String errorValue;
            
            /*  AT-3855   */
            Reading__c objLatestReadings = getLastReadingValues(deviceId, objReadingUpload.ReadingDate__c);
            if(objLatestReadings != null && supplyPointdeviceId != null && highReading == false)   //skip Threshold validation for supply points that are not linked to a book  
            {    
                errorValue = GlUt_ReadingUtilities.validateConsumptionThreshold(supplyPointdeviceId, Integer.valueOf(objLatestReadings.Reading__c), Integer.valueOf(overrideValue),  objLatestReadings.ReadingDate__c , objReadingUpload.ReadingDate__c);
                if(errorValue != GlUt_Constants.NOERROR)
                    return errorValue;
            }
            /*  AT-3855   */
            // Need to confirm the validation for devide digits
            Reading__c objReading = new Reading__c();
            objReading.Device__c = deviceId;
            objReading.ActualDeviceReading__c = overrideValue;
            objReading.ReadingDate__c   =   objReadingUpload.ReadingDate__c;
            objReading.ReadingMethod__c = objReadingUpload.ReadingMethod__c;
            objReading.ReadingSource__c = objReadingUpload.ReadSource__c;
            objReading.ReadingType__c = LoAp_Constants.Regular;
            objReading.HighReading__c = highReading; //AT-3855
            objReading.Tripped__c = objReadingUpload.Tripped__c; // SIT005 Readiness, Gopal Gupta, 05/04/2019
            objReading.CheckServiceItemTolerance__c = checkBillingTolerance; //UL-21, Ankit, 21/02/2019
            objReading.BillableType__c = (objReadingUpload.Billable__c ? LoAp_Constants.Billable : LoAp_Constants.NonBillable);
            objReading = (Reading__c)GlUt_FieldSecurity.cleanseFields(objReading, false); 
            insert objReading; 
            
            ScheduledRead__c objScheduleRead;
            if(objReading.Id != null){
                objScheduleRead = new ScheduledRead__c();
                objScheduleRead.Reading__c = objReading.Id;
                objScheduleRead.ReadPeriod__c = objReadingUpload.ReadPeriodId__c;
                objScheduleRead.ReadingMode__c = readingModeId; 
                objScheduleRead = (ScheduledRead__c)GlUt_FieldSecurity.cleanseFields(objScheduleRead, false); 
                insert objScheduleRead;                
            }       
            /* Clayton Review: Sudhir commented dynamic query code and used LightningDataAccess and escapeSingleQuotes
            String soqlQuery ='';            
            soqlQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,' + 
            String.join(readingUploadList,','), 
            GlUt_APIConstantsReadingUpload.READINGUPLOADEAPINAME + ' WHERE Id = \'' + readingUploadId + '\''});
            // get reading upload records using query string.
            List<ReadingUpload__c> readingUploads = Database.query(soqlQuery);
            */
            String filterStatement = ' WHERE Id = \'' + String.escapeSingleQuotes(readingUploadId) + '\'' ;
            List<ReadingUpload__c> readingUploads = (List<ReadingUpload__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReadingUpload.READINGUPLOADEAPINAME,
                                                                                                                 readingUploadList,
                                                                                                                 filterStatement) ;
            
            if(readingUploads != null && !readingUploads.isEmpty()){
                if(readingUploads[0].Id != null){
                    readingUploads[0].ReadingValue__c  = overrideValue;
                    //readingUploads[0].Processed__c = true;
                    readingUploads[0].ReadingStatus__c = GlUt_Constants.PROCESSED; // CLB-18, Ankit, 01/04/2019
                    readingUploads[0].CheckServiceItemTolerance__c = checkBillingTolerance; //UL-21, Ankit, 21/02/2019                     
                    readingUploads = (List<ReadingUpload__c>)GlUt_FieldSecurity.cleanseFields(readingUploads, false);
                    update readingUploads;
                }
                if(objReading.Id != null && objScheduleRead.Id != null && readingUploads[0].ReadingStatus__c == GlUt_Constants.PROCESSED)
                    errorValue = GlUt_Constants.NOERROR;
                else
                    errorValue = GlUt_Constants.ERROR;
            }else{
                errorValue = GlUt_Constants.ERROR;
            }
            return errorValue;
        } 
        catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } 
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }  
    }
    
    /**********************************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 22-May-2018
    @param       : Id deviceId
    @return      : Map<String,String>
    @description : Method is used to get the latest reading.
    **********************************************************************************************/
    @AuraEnabled
    public static Decimal getLatestReading(Id deviceId){
        try{
            //Reading__c objReading = [SELECT Id, ReadingDate__c, Reading__c FROM Reading__c WHERE Device__c = :deviceId ORDER BY ReadingDate__c DESC LIMIT 1];
            //Clayton Review: Sudhir commented static soql and used GlAp_LightningDataAccess and escapeSingleQuotes
            String filterStatement = ' WHERE Device__c = \'' +  String.escapeSingleQuotes(deviceId) + '\'' + ' ORDER BY ReadingDate__c DESC LIMIT 1 ' ;
            List<Reading__c> objReadingList = (List<Reading__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME,
                                                                                     new list<String> {GlUt_APIConstantsReading.READINGDATEAPINAME, GlUt_APIConstantsReading.READINGFIELDAPINAME},
                                                                                     filterStatement) ;
            if(objReadingList[0] != null)
                return objReadingList[0].Reading__c;
            else
                return null;
        }
        catch (Exception e){
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally{
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /**********************************************************************************************
    @author      : Echo: Vivek Sethi AT-3855
    @date        : 10-oCT-2018
    @param       : Id deviceId
    @return      : Map<String,String>
    @description : Method is used to get the latest reading.
    **********************************************************************************************/
    @AuraEnabled
    public Static Reading__c  getLastReadingValues(Id deviceId , Date currentReadingDate){
        try{
            List<Reading__c> listReading = new List<Reading__c>();            
            String filterStatement = ' WHERE ' + GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME + ' = \'' + String.escapeSingleQuotes(deviceId) + '\'';
            filterStatement = filterStatement + ' AND ' + GlUt_APIConstantsReading.READINGDATEAPINAME + ' < ' + currentReadingDate ; 
            filterStatement = filterStatement + ' AND ' + GlUt_APIConstantsReading.BILLABLETYPEAPINAME + ' != ' + System.Label.CuAp_ReadingBillableTypeInvalid ; 
            filterStatement = filterStatement + ' ORDER BY ' + GlUt_APIConstantsReading.READINGDATEAPINAME + ' DESC LIMIT 1 '; 
            listReading = (List<Reading__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME, 
                                                                              readingList, 
                                                                              filterStatement);
            if(!listReading.isEmpty() && listReading[0] != null)
                return listReading[0];
            else
                return null;
        }
        catch (Exception e){
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally{
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    
    
}