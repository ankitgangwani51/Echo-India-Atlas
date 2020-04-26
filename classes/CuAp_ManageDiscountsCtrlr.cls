/************************************************************************************************************
@author      : Echo: Ankit Gangwani
@date        : 25 Jan 2018
@description : CuAp_ManageDiscountsCtrlr class is used to display disount and allocation to bill items records
Revision(s)     03 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
**************************************************************************************************************/

public with sharing class CuAp_ManageDiscountsCtrlr {
    
    private static List<string> discountFields;
    private static List<String> discountTypeFields;
    private static List<string> servcItmFields;
    private static List<String> discountSingleField;
    private static final String CLASS_NAME = 'CuAp_ManageDiscountsCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
 
    static{
        //Get Fields from the Discount Object
        discountFields = new List<string>();
        discountFields.add(GlUt_APIConstantsDiscountType.DISCOUNTTYPEAPINAME);
        discountFields.add(GlUt_APIConstantsDiscounts.STARTDATEAPINAME);
        discountFields.add(GlUt_APIConstantsDiscounts.ENDDATEAPINAME);
        discountFields.add(GlUt_APIConstantsDiscounts.BASEDISCOUNTAMOUNTAPINAME);
        discountFields.add(GlUt_APIConstantsDiscounts.BASEPERCENRAGEDISCOUNTAPINAME);
        discountFields.add(GlUt_APIConstantsDiscounts.BASEDAILYDISCOUNTAMOUNTAPINAME);
        discountFields.add(GlUt_APIConstantsDiscounts.OVERRIDDENPERCENTAGEAPINAME);
        discountFields.add(GlUt_APIConstantsDiscounts.OVERRIDDENAMOUNTAPINAME);
        discountFields.add(GlUt_APIConstantsDiscounts.OVERRIDDENDAILYDISCOUNTAPINAME);
        discountFields.add(GlUt_APIConstantsDiscounts.CONCESSIONAPINAME);
        
        // Get fields from the Discount Type Object
        discountTypeFields = new List<String>();
        discountTypeFields.add(GlUt_APIConstantsDiscountType.MAXDISCOUNTPERSERVICEITEMAPINAME);
        discountTypeFields.add(GlUt_APIConstantsDiscountType.TOPUPAPINAME);
        discountTypeFields.add(GlUt_APIConstantsDiscountType.RECURRINGFREQUENCYAPINAME);
        discountTypeFields.add(GlUt_APIConstantsDiscountType.TYPEAPINAME);
        discountTypeFields.add(GlUt_APIConstantsDiscountType.RECURRINGAPINAME);
        discountTypeFields.add(GlUt_APIConstantsDiscountType.CANBEOVERRIDDENAPINAME);
        discountTypeFields.add(GlUt_APIConstantsDiscountType.DISCOUNTTYPENAMEAPINAME);
        discountTypeFields.add(GlUt_APIConstantsDiscounts.STARTDATEAPINAME);   /*AT-2107 */
        discountTypeFields.add(GlUt_APIConstantsDiscountType.RECORDTYPEAPINAME);
        
        
                               
        // Get fields from the Service Item Object
        servcItmFields = new List<String>();
        servcItmFields.add(GlUt_APIConstantsServiceItem.LOCATIONAPINAME);
        servcItmFields.add(GlUt_APIConstantsServiceItem.SUPPLYPOINTAPINAME);
        servcItmFields.add(GlUt_APIConstantsServiceItem.SERVICETYPEAPINAME);
        servcItmFields.add(GlUt_APIConstantsServiceItem.SERVICEITEMTYPEAPINAME);
    }
    
    /**********************************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 25 Jan 2018
    @return      : List<GLAp_FieldProps>
    @description : This method returns the field properties for each of the fields that are
    to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveDiscountPropDetails() {
        
        List<GLAp_FieldProps> allFieldProp = new List<GLAp_FieldProps>();        
        try {
            // Create a Override Discount Field 
            GLAp_FieldProps overDiscButton = new GLAp_FieldProps();
            overDiscButton.isFLSVisible = true;
            overDiscButton.isEncrypted = false;
            overDiscButton.isEditable = true;
            overDiscButton.isRequired = false;
            overDiscButton.fieldName = CuAp_Constants.OVERRIDEDISCOUNT;
            overDiscButton.fieldLabel = CuAp_Constants.OVERRIDEDISCOUNTLABEL;
            overDiscButton.fieldType = 'number';
            overDiscButton.buttonField = false;
            overDiscButton.parentObject = GlUt_APIConstantsDiscounts.DISCOUNTAPINAME;
            
            // Create a Old Start Date field
            GLAp_FieldProps oldStartObj = new GLAp_FieldProps();
            oldStartObj.isFLSVisible = false;
            oldStartObj.isEncrypted = false;
            oldStartObj.isEditable = false;
            oldStartObj.isRequired = false;
            oldStartObj.fieldName = CuAp_Constants.OLDSTARTDATEAPINAME;
            oldStartObj.fieldLabel = CuAp_Constants.OLDSTARTDATELABEL;
            oldStartObj.fieldType = 'text';
            oldStartObj.buttonField = false;
            oldStartObj.parentObject = GlUt_APIConstantsDiscounts.DISCOUNTAPINAME;
            
            // Create a Record Type field
            GLAp_FieldProps recordType = new GLAp_FieldProps();
            recordType.isFLSVisible = false;
            recordType.isEncrypted = false;
            recordType.isEditable = false;
            recordType.isRequired = false;
            recordType.fieldName = CuAp_Constants.RECORDTYPEAPINAME;
            recordType.fieldLabel = CuAp_Constants.RECORDTYPELABEL;
            recordType.fieldType = 'text';
            recordType.buttonField = false;
            recordType.parentObject = GlUt_APIConstantsDiscounts.DISCOUNTAPINAME;
            
            //Get the field properties for the Discount Type object
            List<GLAp_FieldProps> discountTypeFieldProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDiscountType.DISCOUNTTYPEAPINAME, discountTypeFields); 
            
            //Get the field properties for the Discount object
            List<GLAp_FieldProps> discountFieldProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDiscounts.DISCOUNTAPINAME, discountFields); 
            
            for(GLAp_FieldProps discountProps: discountFieldProps){
                
                if(discountProps.fieldName == GlUt_APIConstantsDiscountType.DISCOUNTTYPEAPINAME){
                    discountProps.fieldLabel = CuAp_Constants.DISCOUNTTYPELABEL;
                    discountProps.isEditable = false;
                    allFieldProp.add(discountProps);
                }
                
                if(discountProps.fieldName == GlUt_APIConstantsDiscounts.BASEPERCENRAGEDISCOUNTAPINAME){
                    discountProps.fieldLabel = CuAp_Constants.PERCENTAGEDISCOUNTLABEL;
                    discountProps.isEditable = false;
                    allFieldProp.add(discountProps);
                }
                
                if(discountProps.fieldName == GlUt_APIConstantsDiscounts.BASEDISCOUNTAMOUNTAPINAME){
                    discountProps.fieldLabel = CuAp_Constants.FIXEDDISCOUNTLABEL;
                    discountProps.isEditable = false;
                    allFieldProp.add(discountProps);
                }
                
                 if(discountProps.fieldName == GlUt_APIConstantsDiscounts.BASEDAILYDISCOUNTAMOUNTAPINAME){
                    discountProps.fieldLabel = 'Bill To Bill Discount';
                    discountProps.isEditable = false;
                    allFieldProp.add(discountProps);
                }
            }
            
            for(GLAp_FieldProps discountTypeProps: discountTypeFieldProps){
               
                if(discountTypeProps.fieldName == GlUt_APIConstantsDiscountType.RECURRINGFREQUENCYAPINAME){
                    discountTypeProps.fieldLabel = CuAp_Constants.FREQUENCYLABEL;
                    discountTypeProps.isEditable = false;
                    allFieldProp.add(discountTypeProps);
                }
            }
            
            // Added override discount field to be displayed 
            allFieldProp.add(overDiscButton);
            
            for(GLAp_FieldProps discountProps: discountFieldProps){
                
                if(discountProps.fieldName == GlUt_APIConstantsDiscounts.STARTDATEAPINAME){                
                    allFieldProp.add(discountProps);
                }
                
                if(discountProps.fieldName == GlUt_APIConstantsDiscounts.ENDDATEAPINAME){                
                    allFieldProp.add(discountProps);
                }            
            }    
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return allFieldProp; 
    }
    
    /**********************************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 25 Jan 2018
    @param       : String ContractId
    @return      : List<BlAp_CombinedRecord>
    @description : This method returns the BlAp_CombinedRecord with list of Discount, Disocunt Type, unique-ids, isSelected and readOnlyFields
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveDiscountTypeRecords(String ContractId){
        List<BlAp_CombinedRecord> discountTypeCombinedList = new List<BlAp_CombinedRecord>();
        Map<Id,String> mapOfRecordTypeIdToName = new Map<Id,String>(); 
        List<RecordType> recordTypes = new List<RecordType>();
        
        try {
            Set<Id> discTypeIdSet = new Set<Id>();
            
            recordTypes = [SELECT Id,
                           Name 
                           FROM RecordType
                           WHERE sObjectType =:GlUt_APIConstantsDiscountType.DISCOUNTTYPEAPINAME];
            
            
            for(RecordType rt : recordTypes){
                if(!mapOfRecordTypeIdToName.containsKey(rt.Id))
                    mapOfRecordTypeIdToName.put(rt.Id, rt.Name);
            }

            if (string.isNotBlank(ContractId) && ContractId != null) {
                
                List<Discount__c> lstDiscounts = (List<Discount__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDiscounts.DISCOUNTAPINAME, 
                                                                                                         discountFields, 
                                                                                                         ContractId, 
                                                                                                         GlUt_APIConstantsContracts.CONTRACTAPINAME, 
                                                                                                         GlUt_APIConstantsDiscounts.AMENDDEDBYDISCOUNTAPINAME + ' = null');
                
                System.debug('100.1 lstDiscounts == '+lstDiscounts);
                // Prepare a set for Discount Type Ids through discount records
                for (Discount__c objDisc : lstDiscounts) {                
                    discTypeIdSet.add(objDisc.DiscountType__c);
                }             
                
                // Get the associated Discount Type records using the discTypeIds list Ids
                List<DiscountType__c> lstDiscType = (List<DiscountType__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDiscountType.DISCOUNTTYPEAPINAME, 
                                                                                                                discountTypeFields,
                                                                                                                'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(discTypeIdSet)); 
                
                Map<Id,DiscountType__c> mapDiscType = new Map<Id,DiscountType__c>();
                
                for(DiscountType__c objDiscType: lstDiscType){
                    mapDiscType.put(objDiscType.Id, objDiscType);
                }
                
                // Prepare the combined record list to display on screen
                for(Discount__c objDiscount : lstDiscounts ){
                    String rtName;
                    Id rtId = mapDiscType.containsKey(objDiscount.DiscountType__c) ? mapDiscType.get(objDiscount.DiscountType__c).RecordTypeId : null;
                    if(rtID != null)
                        rtName = mapOfRecordTypeIdToName.containsKey(rtID) ? mapOfRecordTypeIdToName.get(rtID) : '';
                    
                    BlAp_CombinedRecord objBlap = new BlAp_CombinedRecord(); 
                    objBlap.uniqueId = objDiscount.Id;
                    objBlap.isSelected = false; // Changes for AT-3448 Starts/Ends here
                    objBlap.objectMap = new Map<string, sObject>();
                    objBlap.readOnlyFields = new Map<string, boolean>();                                    
                    objBlap.objectMap.put(GlUt_APIConstantsDiscounts.DISCOUNTAPINAME, objDiscount);
                    objBlap.objectMap.put(GlUt_APIConstantsDiscountType.DISCOUNTTYPEAPINAME, mapDiscType.get(objDiscount.DiscountType__c));
                    Map<string, string> transFormFieldMap = new Map<string, string>();
                    transFormFieldMap.put(CuAp_Constants.OLDSTARTDATE, String.valueOf(objDiscount.StartDate__c));
                    transformFieldMap.put(CuAp_Constants.RECORDTYPEAPINAME,rtName);
                    objBlap.transformFieldMap = new Map<string,Map<string, string>>();
                    objBlap.transformFieldMap.put(GlUt_APIConstantsDiscounts.DISCOUNTAPINAME, transFormFieldMap); 
                    discountTypeCombinedList.add(objBlap);
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }

        return discountTypeCombinedList;        
    }
    
    /**********************************************************************************************
    @author      : Echo : Ankit Gangwani
    @date        : 25 Jan 2018
    @return      : List<GLAp_FieldProps>
    @description : This method returns the field properties for each of the fields that are
    to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveBillItemsfieldList(){
        
        List<GLAp_FieldProps> addBillItemsFieldProps = new List<GLAp_FieldProps>();
        
        //Get the field properties for the Service Item object
        List<GLAp_FieldProps> serviceItemFieldProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME, servcItmFields); 
        try {
         
            //Transform Field for Location 
            GLAp_FieldProps locProp = new GLAp_FieldProps();
            locProp.isFLSVisible = false;
            locProp.isEncrypted  = false;
            locProp.isEditable   = true;
            locProp.isRequired   = false;
            locProp.fieldName    = GlUt_APIConstantsServiceItem.LOCATIONAPINAME;
            locProp.fieldLabel   = CuAp_Constants.LOCATIONAPINAMELABEL;
            locProp.fieldType    = LoAp_Constants.TEXT;
            locProp.transformField = true; 
            locProp.parentObject = GlUt_APIConstantsServiceItem.LOCATIONAPINAME;
            addBillItemsFieldProps.add(locProp);
            
           //Transform Field for SupplyPoint
            GLAp_FieldProps spProp = new GLAp_FieldProps();
            spProp.isFLSVisible = false;
            spProp.isEncrypted  = false;
            spProp.isEditable   = true;
            spProp.isRequired   = false;
            spProp.fieldName    = GlUt_APIConstantsServiceItem.SUPPLYPOINTAPINAME;
            spProp.fieldLabel   = CuAp_Constants.SUPPLYPOINTNAMELABEL;
            spProp.fieldType    = LoAp_Constants.TEXT;
            spProp.transformField = true; 
            spProp.parentObject = GlUt_APIConstantsServiceItem.SUPPLYPOINTAPINAME;
            addBillItemsFieldProps.add(spProp);
            //Transform Field for ServiceType
            GLAp_FieldProps sTypeProp = new GLAp_FieldProps();
            sTypeProp.isFLSVisible = false;
            sTypeProp.isEncrypted  = false;
            sTypeProp.isEditable   = true;
            sTypeProp.isRequired   = false;
            sTypeProp.fieldName    = GlUt_APIConstantsServiceItem.SERVICETYPEAPINAME;
            sTypeProp.fieldLabel   = CuAp_Constants.SERVICETYPELABEL;
            sTypeProp.fieldType    = LoAp_Constants.TEXT;
            sTypeProp.transformField = true; 
            sTypeProp.parentObject = GlUt_APIConstantsServiceItem.SERVICETYPEAPINAME;
            addBillItemsFieldProps.add(sTypeProp);
            //Transform Field for ServiceItemType
            GLAp_FieldProps sItemTypeProp = new GLAp_FieldProps();
            sItemTypeProp.isFLSVisible = false;
            sItemTypeProp.isEncrypted  = false;
            sItemTypeProp.isEditable   = true;
            sItemTypeProp.isRequired   = false;
            sItemTypeProp.fieldName    = GlUt_APIConstantsServiceItem.SERVICEITEMTYPEAPINAME;
            sItemTypeProp.fieldLabel   = CuAp_Constants.SERVICEITEMTYPELABEL;
            sItemTypeProp.fieldType    = LoAp_Constants.TEXT;
            sItemTypeProp.transformField = true; 
            sItemTypeProp.parentObject = GlUt_APIConstantsServiceItem.SERVICEITEMTYPEAPINAME;
            addBillItemsFieldProps.add(sItemTypeProp);
            //Get the field properties for the Discount Type object
            List<GLAp_FieldProps> discountTypeFieldProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDiscountType.DISCOUNTTYPEAPINAME,discountTypeFields);
            for(GLAp_FieldProps objProp: discountTypeFieldProps){            
                if(objProp.fieldName == GlUt_APIConstantsDiscountType.DISCOUNTTYPENAMEAPINAME){
                    objProp.fieldLabel = CuAp_Constants.DISCOUNTTYPELABEL;
                    addBillItemsFieldProps.add(objProp);
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return addBillItemsFieldProps;
    }
    
    /**********************************************************************************************
    @author      : Echo : Ankit Gangwani
    @date        : 25 Jan 2018
    @param       : String DiscountId
    @return      : List<BlAp_CombinedRecord>
    @description : This method returns the BlAp_CombinedRecord with list of Service Items, Disocunt Type, unique-ids, isSelected and readOnlyFields
    @revision    : Echo: Sudhir - AT-3966: Replaced Dynamic SOQL with static SOQL for CuAp_ManageDiscountsCtrlr (Security Review)
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveBillItemsrecordList(String DiscountId) {
        List<BlAp_CombinedRecord> billItemsRecordCombinedList = new List<BlAp_CombinedRecord>();
        
        Set<Id> setForContractId = new Set<Id>();
        try {
            GlUt_Logger.logDebug(DEBUG);
            if (string.isNotBlank(DiscountId) && DiscountId != null) {
                
                Id DiscountTypeID;
                Id ContractID;
                /*
                String soqlQuery ='';            
                soqlQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,' + GlUt_APIConstantsContracts.CONTRACTAPINAME + ',' + GlUt_APIConstantsDiscountType.DISCOUNTTYPEAPINAME, 
                    GlUt_APIConstantsDiscounts.DISCOUNTAPINAME + ' WHERE Id' + ' =\'' + String.escapeSingleQuotes(DiscountId) + '\' LIMIT 1'});            
                List<Discount__c> lstDiscounts = Database.query(soqlQuery);    
                */
                //Sudhir - AT-3966: Replaced Dynamic SOQL with static SOQL for CuAp_ManageDiscountsCtrlr (Security Review)
                List<Discount__c> lstDiscounts =  [SELECT Id, BillingContract__c, DiscountType__c FROM Discount__c WHERE Id =: DiscountId LIMIT 1] ;  // AT-3966
                // Prepare variables for Contract ID and Discount Type ID through Discount records
                for(Discount__c objDiscount: lstDiscounts){
                    DiscountTypeID = objDiscount.DiscountType__c ;
                    ContractID = objDiscount.BillingContract__c ;
                }
                
                // Get Discount Type Name through Discount Type Id
                /*
                soqlQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Name', GlUt_APIConstantsDiscountType.DISCOUNTTYPEAPINAME
                    + ' WHERE Id' + ' =\'' + String.escapeSingleQuotes(DiscountTypeID) + '\''});
                DiscountType__c discountTypeName = Database.query(soqlQuery);
                */
                //Sudhir - AT-3966: Replaced Dynamic SOQL with static SOQL for CuAp_ManageDiscountsCtrlr (Security Review)
                list<DiscountType__c> discountTypeNameList = [SELECT Name FROM DiscountType__c WHERE Id =: DiscountTypeID] ; // AT-3966
                // Get Service Records through Contract Id
                /*
                soqlQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id', GlUt_APIConstantsService.SERVICEAPINAME
                    + ' WHERE ' + GlUt_APIConstantsContracts.CONTRACTAPINAME + ' =\'' + String.escapeSingleQuotes(ContractID) + '\''});
                List<Service__c> lstServices = Database.query(soqlQuery);
                */
                //Sudhir - AT-3966: Replaced Dynamic SOQL with static SOQL for CuAp_ManageDiscountsCtrlr (Security Review)
                List<Service__c> lstServices =  [SELECT Id FROM  Service__c WHERE BillingContract__c =: ContractID] ; // AT-3966
                // Prepare a set of service Id through service records
                Set<Id> setServicesId = new Set<Id>();
                for(Service__c objService: lstServices){
                    setServicesId.add(objService.Id);
                }
                /*
                soqlQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,' + GlUt_APIConstantsServiceItem.SERVICEITEMTYPEAPINAME, 
                    GlUt_APIConstantsDiscountTypeItem.DISCOUNTTYPEITEMAPINAME + ' WHERE ' + GlUt_APIConstantsDiscountType.DISCOUNTTYPEAPINAME 
                    + ' =\'' + String.escapeSingleQuotes(DiscountTypeID) + '\' AND ' + GlUt_APIConstantsServiceItem.SERVICEITEMTYPEAPINAME + '!= null'});
                List<DiscountTypeitem__c> lstDiscountTypeItem = Database.query(soqlQuery);
                */
                //Sudhir - AT-3966: Replaced Dynamic SOQL with static SOQL for CuAp_ManageDiscountsCtrlr (Security Review)
                List<DiscountTypeitem__c> lstDiscountTypeItem = [SELECT Id, ServiceItemType__c FROM DiscountTypeitem__c WHERE DiscountType__c =: DiscountTypeID AND ServiceItemType__c != null] ;   // AT-3966
                // Prepare a set of Service Item Type Ids through Discount Type Item records
                Set<Id> setServItemType = new Set<Id>();
                for(DiscountTypeitem__c objDiscTypeItem : lstDiscountTypeItem){
                    setServItemType.add(objDiscTypeItem.ServiceItemType__c);
                }
                
                List<ServiceItem__c> lstServiceItems = (List<ServiceItem__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME, 
                                                                                                                  servcItmFields,
                                                                                                                  String.format('WHERE {0} IN {1} AND {2} IN {3}', 
                                                                                                                                new List<String>{
                                                                                                                                    GlUt_APIConstantsService.SERVICEAPINAME, 
                                                                                                                                        GlUt_FieldSecurity.IdsToString(setServicesId),
                                                                                                                                        GlUt_APIConstantsServiceItem.SERVICEITEMTYPEAPINAME, 
                                                                                                                                        GlUt_FieldSecurity.IdsToString(setServItemType)}));
              
                // Changes for AT-3448 Starts here
                Map<Id,String> mapOfServiceItemTypeId2ServiceItemTypeName = new Map<Id,String>();
                Map<Id,Id> mapOfServiceItemId2ServiceItemTypeId = new Map<Id,Id>();
                Map<Id,ServiceItem__c> mapOfServiceItemId2ServiceItem = new Map<Id,ServiceItem__c>();
                for(ServiceItem__c sItems: lstServiceItems){
                    mapOfServiceItemId2ServiceItemTypeId.put(sItems.Id,sItems.ServiceItemType__c);
                    mapOfServiceItemId2ServiceItem.put(sItems.Id,sItems);
                }
                mapOfServiceItemTypeId2ServiceItemTypeName = GlAp_LightningDataAccess.getRecordName(mapOfServiceItemId2ServiceItemTypeId.values());
                for (ServiceItem__c serItemObj : lstServiceItems) {                
                    BlAp_CombinedRecord DiscServItemComb = new BlAp_CombinedRecord();            
                    DiscServItemComb.uniqueId       = serItemObj.Id;
                    DiscServItemComb.isSelected     = false;
                    DiscServItemComb.readOnlyFields = new Map<string, boolean>();
                    DiscServItemComb.objectMap      = new Map<string, sObject>();
                    DiscServItemComb.transformFieldMap = new Map<String,Map<String,String>>();
                    
                    Map<String,String> LocationTransformFieldMap = new Map<String,String>();
                    LocationTransformFieldMap.put(GlUt_APIConstantsServiceItem.LOCATIONAPINAME,mapOfServiceItemId2ServiceItem.get(serItemObj.Id).Location__c);
                    DiscServItemComb.transformFieldMap.put(GlUt_APIConstantsServiceItem.LOCATIONAPINAME,LocationTransformFieldMap);
                    
                    Map<String,String> SupplyPointTransformFieldMap = new Map<String,String>();
                    SupplyPointTransformFieldMap.put(GlUt_APIConstantsServiceItem.SUPPLYPOINTAPINAME,mapOfServiceItemId2ServiceItem.get(serItemObj.Id).Supply_Point__c);
                    DiscServItemComb.transformFieldMap.put(GlUt_APIConstantsServiceItem.SUPPLYPOINTAPINAME,SupplyPointTransformFieldMap);
                    
                    Map<String,String> ServiceTypeTransformFieldMap = new Map<String,String>();
                    ServiceTypeTransformFieldMap.put(GlUt_APIConstantsServiceItem.SERVICETYPEAPINAME,mapOfServiceItemId2ServiceItem.get(serItemObj.Id).ServiceType__c);
                    DiscServItemComb.transformFieldMap.put(GlUt_APIConstantsServiceItem.SERVICETYPEAPINAME,ServiceTypeTransformFieldMap);
                    
                    Map<String,String> ServiceItemTypeTransformFieldMap = new Map<String,String>();
                    ServiceItemTypeTransformFieldMap.put(GlUt_APIConstantsServiceItem.SERVICEITEMTYPEAPINAME,mapOfServiceItemTypeId2ServiceItemTypeName.get(mapOfServiceItemId2ServiceItemTypeId.get(serItemObj.Id)));
                    DiscServItemComb.transformFieldMap.put(GlUt_APIConstantsServiceItem.SERVICEITEMTYPEAPINAME,ServiceItemTypeTransformFieldMap);
                    if(discountTypeNameList != null && !discountTypeNameList.isEmpty()) // AT-3966
                        DiscServItemComb.objectMap.put(GlUt_APIConstantsDiscountType.DISCOUNTTYPEAPINAME, discountTypeNameList[0]);    // AT-3966
                    billItemsRecordCombinedList.add(DiscServItemComb);
                    // Changes for AT-3448 Ends here
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return billItemsRecordCombinedList;
    }    
}