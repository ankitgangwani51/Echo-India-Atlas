/******************************************************************************
@author         Tarun Gupta 
@date           17 Sep 2018
@description      
*******************************************************************************/
public with sharing class CuAp_CustMoveAmendReviewCtrlr {
    
    private static final String CLASS_NAME = 'CuAp_CustMoveAmendReviewCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static final List<String> deviceFields = new List<string>{
                                                          GlUt_APIConstantsDevice.SERIALNOAPINAME
                                                          };
    
	private static final List<String> readingFields = new List<string>{
                                                          GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME,
                                                          GlUt_APIConstantsReading.READINGMETHODAPINAME,
                                                          GlUt_APIConstantsReading.READINGDATEAPINAME    
                                                          };
                                                                      
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 03 Jan 2018
    @return      : List<GLAp_FieldProps>
    @description : This method returns the field properties for each of the fields that are
    to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveReadingPropDetails() {
        
        try{
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
            List<GLAp_FieldProps> allFieldProp = new List<GLAp_FieldProps>();
            
            //Get the field properties for the Instalment object
            List<GLAp_FieldProps> readinFieldProp = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReading.READINGAPINAME, readingFields); 
            List<GLAp_FieldProps> deviceFieldProp = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDevice.DEVICEAPINAME, deviceFields); 
            
            readinFieldProp.addAll(deviceFieldProp);
            
            for(GLAp_FieldProps readingObject: readinFieldProp){
                
                readingObject.isEditable = false;
                
                if(readingObject.fieldName == GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME){
                   // readingObject.isEditable = true;
                }
                
                if(readingObject.fieldName == GlUt_APIConstantsReading.READINGMETHODAPINAME){
                   // readingObject.isEditable = true;
                }
                
                allFieldProp.add(readingObject);
            } 
            return allFieldProp;
        }
        catch(Exception e){
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    /**********************************************************************************************
    @author      : Echo : Swati
    @date        : 20 09 2018
    @return      : List<GLAp_FieldProps>
    @description : This method returns the field properties for each of the fields that are
    to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveReadingRecords(List<Reading__c> readingsList) {
        
        List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
        
        try{
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);      
            Set<Id> deviceIds = new Set<Id>(); 
            
            if(readingsList != null){
                
                for (Reading__c objReading: readingsList){
                    deviceIds.add(objReading.Device__c);
                }
                
                String filterStatement = 'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(deviceIds); 
                
                List<Device__c> lstDevice =  GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDevice.DEVICEAPINAME, 
                                                                                 deviceFields,
                                                                                 filterStatement);
                Map<Id,Device__c> deviceMap = new Map<Id,Device__c>(lstDevice); 
                
                for (Reading__c objReading: readingsList){
                    BlAp_CombinedRecord record = new BlAp_CombinedRecord();            
                    record.uniqueId = objReading.Id;
                    record.isSelected = false;                
                    record.objectMap = new Map<String, sObject>();
                    record.objectMap.put(GlUt_APIConstantsReading.READINGAPINAME, objReading);  
                    record.objectMap.put(GlUt_APIConstantsDevice.DEVICEAPINAME, deviceMap.get(objReading.Device__c));
                    records.add(record);
                }
            }
            return records;
            
        }
        catch(Exception e){
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
}