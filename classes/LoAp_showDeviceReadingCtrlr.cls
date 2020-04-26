/******************************************************************************
@author         Echo: Amit K.
@date           30 Nov 2017
@description    Component controller for ShowDeviceReading lightning component
*******************************************************************************/
public with sharing class LoAp_showDeviceReadingCtrlr { 
    private static List<string> readingFields;
    private static List<string> billItemFields;
    private static List<string> queryBillItemFields;
    private static List<string> queryServiceItemFamilyFields;
    public static string  ALGOTYPE = CuAp_Constants.MEASUREDBILLING;
    private static final String CLASS_NAME = 'LoAp_ShowDeviceReadingCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    static{
        readingFields = new List<string>();
        readingFields.add(CuAp_Constants.READDATE); 
        readingFields.add(CuAp_Constants.OBJECTNAME);
        readingFields.add(CuAp_Constants.READMETHOD);
        readingFields.add(CuAp_Constants.READTYPE);
        readingFields.add(CuAp_Constants.BILLABLETYPE);
        readingFields.add(CuAp_Constants.BILLED);
    }
    static{
        billItemFields = new List<string>();
        //billItemFields.add(CuAp_Constants.GROSSCONSUMPTION); AT-2159
        billItemFields.add(CuAp_Constants.NETCONSUMPTION);
    }
    static{
        queryBillItemFields = new List<string>();
        //queryBillItemFields.add(CuAp_Constants.GROSSCONSUMPTION); AT-2159
        queryBillItemFields.add(CuAp_Constants.NETCONSUMPTION);
        queryBillItemFields.add(CuAp_Constants.OBJECTNAME);
        queryBillItemFields.add(CuAp_Constants.BILLSERVICETYPETOSERVICETYPE);
    }
    static{
        queryServiceItemFamilyFields = new List<string>();
        queryServiceItemFamilyFields.add(CuAp_Constants.ALGORITHMTYPE);
        queryServiceItemFamilyFields.add(CuAp_Constants.AVAILSERVICETYPE);
        
    }
    
    /**********************************************************************************************
    @author         Echo: Amit K.
    @date           30 Nov 2017
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the fields that are to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveReadingFieldPropDetails(string readingType) {
        //Get the field properties for the reading object
        List<GLAp_FieldProps> deviceProps = GlAp_LightningDataAccess.getObjectsFieldProperties(BlAp_Constants.READINGAPINAME, readingFields);
        List<GLAp_FieldProps> billItemProps = GlAp_LightningDataAccess.getObjectsFieldProperties(BlAp_Constants.BILLITEMAPINAME, billItemFields);
        
        //Want to make all of the  reading fields readonly   
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG );
            for(GLAp_FieldProps fldProp : deviceProps){
                fldProp.isEditable = false;
                if(string.isNotBlank(readingType) && readingType == System.Label.LoAp_ReadingType){
                    if(fldProp.fieldName != CuAp_Constants.BILLABLETYPE){
                        fldPropList.add(fldProp);
                    }
                }
                else{
                    fldPropList.add(fldProp); 
                }
            }
            for(GLAp_FieldProps fldProp : billItemProps){
                fldProp.isEditable = false;
                fldPropList.add(fldProp);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return fldPropList;
    }
    
    /**********************************************************************************************
    @author         Echo: Amit K.
    @date           30-Nov-2017
    @param          string deviceId,string readingType
    @return         List<BlAp_CombinedRecord>
    @description    This method takes the deviceId and readingType to return all associated reading details.
    @revision       MT 07-Mar-2018 Use the field from constant class
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveDeviceReadings(string deviceId,string readingType) {
        
        //Collection and Variable Declarations.
        List<BlAp_CombinedRecord>  readingComList = new List<BlAp_CombinedRecord>();
        List<Reading__c>  readingList = new List<Reading__c>();
        List<BillItem__c>  billItemList = new List<BillItem__c>();
        List<ServiceItemFamily__c>  serviceItemFamilyList = new List<ServiceItemFamily__c>();
        Map<Id,List<BillItem__c>> mapofReadingIdToBillItems = new Map<Id,List<BillItem__c>>();
        Map<Id,Id> mapofBillItemIdToServiceTypeId = new Map<Id,Id>();
        Map<Id,ServiceItemFamily__c> mapofServiceTypeIdToServiceItemFamily = new Map<Id,ServiceItemFamily__c>();
        List<Id> serviceTypeId = new List<Id>();
        string sOQLQuery ='';
        try {
            if(string.isNotBlank(deviceId) && deviceId != null) {
                //Clayton Review: Sudhir commented Dynamic SOQL codes and used GlAp_LightningDataAccess.
                String filterStatement = ' WHERE ' + GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME + ' =\''+String.escapeSingleQuotes(deviceId)+'\'' ;
                //sOQLQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(readingFields,','), BlAp_Constants.READINGAPINAME +' WHERE ' + GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME + ' =\''+String.escapeSingleQuotes(deviceId)+'\''});
                if(string.isNotBlank(readingType) && readingType == System.Label.LoAp_ReadingType){
                    filterStatement += appendConditions(CuAp_Constants.BILLABLETYPE,readingType); 
                }
                else{
                    filterStatement += appendConditions('',''); 
                }
                //readingList = Database.query(sOQLQuery);
                readingList = (List<Reading__c>) GlAp_LightningDataAccess.getRecords( BlAp_Constants.READINGAPINAME, 
                                                                                      readingFields, 
                                                                                     filterStatement) ;
                // Check the security on the Reading fields
                //readingList = GlUt_FieldSecurity.cleanseFields(readingList, readingFields, true); 
                readingList = GlUt_FieldSecurity.cleanseFields(readingList, true);
            }
            if(!readingList.isEmpty()){
                sOQLQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(queryBillItemFields,','), BlAp_Constants.BILLITEMAPINAME +' WHERE ' + GlUt_APIConstantsBillItem.READINGAPINAME +' IN :readingList'});
                billItemList = Database.query(sOQLQuery);
                // Check the security on the BillItem fields
                //billItemList = GlUt_FieldSecurity.cleanseFields(billItemList, queryBillItemFields, true); 
                billItemList = GlUt_FieldSecurity.cleanseFields(billItemList, true); 
            }
            //Create the map of Reading having Bill Items.
            //Create the map of Bill Items id and Bill item-->Service Type id.
            for(BillItem__c bi:billItemList){
                if(!mapofReadingIdToBillItems.containsKey(bi.Reading__c)){
                    mapofReadingIdToBillItems.put(bi.Reading__c, new List<BillItem__c>()); 
                }
                mapofReadingIdToBillItems.get(bi.Reading__c).add(bi);
                if(bi.BillServiceType__r.ServiceType__c!=null){
                    mapofBillItemIdToServiceTypeId.put(bi.Id,bi.BillServiceType__r.ServiceType__c);
                }
            }
            if(!mapofBillItemIdToServiceTypeId.isEmpty()){
                serviceTypeId = mapofBillItemIdToServiceTypeId.values();
            }
            if(!serviceTypeId.isEmpty()){
                sOQLQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(queryServiceItemFamilyFields,','), GlUt_ApiConstantsServiceItemFamily.SRVCITEMFMLYAPINAME +' WHERE ' + GlUt_ApiConstantsServiceItemFamily.SERVICETYPEAPINAME + ' IN :serviceTypeId AND ' + GlUt_ApiConstantsServiceItemFamily.ALGORITHMTYPEAPINAME + ' =:ALGOTYPE'});
                serviceItemFamilyList = Database.query(sOQLQuery);
                // Check the security on the BillItem fields
                //serviceItemFamilyList = GlUt_FieldSecurity.cleanseFields(serviceItemFamilyList, queryServiceItemFamilyFields, true); 
                serviceItemFamilyList = GlUt_FieldSecurity.cleanseFields(serviceItemFamilyList, true);
            }
            //Create the map of Service Type and Service Item Family. 
            for(ServiceItemFamily__c sif:serviceItemFamilyList){
                if(sif.ServiceType__c!=null){
                    mapofServiceTypeIdToServiceItemFamily.put(sif.ServiceType__c,sif);
                }
            }
            for(Reading__c objReading : readingList ){   
                BlAp_CombinedRecord objReadingCom = new BlAp_CombinedRecord();            
                objReadingCom.uniqueId=objReading.Id;
                objReadingCom.isSelected = false;
                objReadingCom.objectMap = new Map<string, sObject>();
                //Create a map of Reading related field values
                objReadingCom.objectMap.put(BlAp_Constants.READINGAPINAME, objReading); 
                // find the first Bill Item for the reading where Service Item Family having Algorithm field value as Measured Billing.
                if(mapofReadingIdToBillItems.get(objReading.Id) != null){
                    List<BillItem__c> billItems = mapofReadingIdToBillItems.get(objReading.Id);
                    for(BillItem__c bi:billItems){
                        if(mapofBillItemIdToServiceTypeId.get(bi.Id)!=null){
                            Id sTypeId = mapofBillItemIdToServiceTypeId.get(bi.Id);
                            if(mapofServiceTypeIdToServiceItemFamily.get(sTypeId)!=null){
                                //Create a map of Bill Items related field values
                                objReadingCom.objectMap.put(BlAp_Constants.BILLITEMAPINAME, bi);
                                break;
                            }
                        }
                    }
                }  
                readingComList.add(objReadingCom);
                
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        system.debug(JSON.serialize(readingComList));
        return readingComList;
    }
   
    /******************************************************************************
    @author         Echo: Amit K.
    @date           30-Nov-2017
    @param          String - apiname of the field
    @param          String - value to match
    @return         String - 'AND' clause to append to query
    @description    Builds a 'AND' clause to append to a query
    @revision       MT 07-Mar-2018 Use the field from constant class
    *******************************************************************************/
    private static String appendConditions(string fieldName, string fieldVal) {
        String retVal;
        if(string.isNotBlank(fieldVal) && string.isNotBlank(fieldName))
        retVal = ' AND ' + fieldName + ' =\''+fieldVal+'\'' + ' ORDER BY ' + GlUt_APIConstantsReading.READINGDATEAPINAME + ' DESC' ;
        else
        retVal = ' ORDER BY ' + GlUt_APIConstantsReading.READINGDATEAPINAME + ' DESC' ;    
        return retVal;
    }
}