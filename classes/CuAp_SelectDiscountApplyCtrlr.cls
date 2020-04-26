/******************************************************************************
@author      	Echo:Amit K.
@date      		09-Jan-2018
@description	Component controller for Select Discount to Apply.
Revision(s)		08 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
				AT-3657, 28 Nov 2011, Modified the code for concession logic
*******************************************************************************/
public with sharing class CuAp_SelectDiscountApplyCtrlr {

    private static final String CLASS_NAME = 'CuAp_SelectDiscountApplyCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    private static List<string> serviceItemFields;
    private static List<string> discountTypeItemFields;
    private static List<string> discountTypeFields;
    private static List<String> concessionFields;
    public static Set<Id> concessionIdsSet;
    static{
        serviceItemFields = new List<string>();
        serviceItemFields.add(CuAp_Constants.SRVITEMTYPE);
    }
    
    static{
        discountTypeItemFields = new List<string>();
        discountTypeItemFields.add(GlUt_APIConstantsDiscounts.DISCOUNTTYPEAPINAME); 
        discountTypeItemFields.add(CuAp_Constants.SRVITEMTYPE);        
    }
    
    static{
        discountTypeFields = new List<string>();
        discountTypeFields.add(GlUt_APIConstantsDiscounts.DISCOUNTTYPENAMEAPINAME);        
        discountTypeFields.add(GlUt_APIConstantsDiscounts.RECURRINGAPINAME);
        discountTypeFields.add(GlUt_APIConstantsDiscounts.RECURRINGFREQUENCYAPINAME); 
        discountTypeFields.add(GlUt_APIConstantsDiscounts.CANBEOVERRIDDENAPINAME);
        discountTypeFields.add(GlUt_APIConstantsDiscounts.STARTDATEAPINAME);    /*AT-2107*/
    }
    
    static{
        concessionFields = new List<String>();
        concessionFields.add(GlUt_APIConstantsConcession.PRIMARYACCOUNTAPINAME);
        concessionFields.add(GlUt_APIConstantsConcession.CONSENTDATEAPINAME);
        concessionFields.add(GlUt_APIConstantsConcession.NONPRIMARYACCOUNTAPINAME);
        concessionFields.add(GlUt_APIConstantsConcession.TYPEAPINAME);
        concessionFields.add(GlUt_APIConstantsConcession.VALIDATEDAPINAME);
    }
    
    /**********************************************************************************************
	@author         Echo: Amit K.
	@date           10 Jan 2018
	@param			Contract Id
	@return         instance of wrapper class; this will contain discount type information,
	field properties and discount type information.
	@description	This method will collect the required details in wrapper and send it to helper
	@revisions		AT-3657, 28 Nov 2011,
					Modified the code to add the concession and Discount Type Record Type value into the wrapper
	**********************************************************************************************/
    @AuraEnabled
    Public static ContainerWrapper getInfoToDisplay(string contractId,string sKeyValue,string sOperation,string sfilterOn){        
        //instance of wrapper class
        ContainerWrapper resultContainer = new ContainerWrapper(); 
        List<Id> concessions = new List<Id>();
        try {
            //call to method to get field properties
            resultContainer.fieldPropList = getDiscountTypeFieldProps(sfilterOn);
            //call to method to get discount type details
            concessionIdsSet = new Set<Id>();
            resultContainer.discountList = getDiscountTypesOnContract(contractId,sKeyValue,sOperation,sfilterOn,concessionIdsSet);
            concessions.addAll(concessionIdsSet);
            resultContainer.discountTypeRecordType = sfilterOn;
            resultContainer.concessions  = concessions;
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return resultContainer;
        
    }
    
    /**********************************************************************************************
	@author         Echo: Amit K.
	@date           10 Jan 2018
	@return         List<GLAp_FieldProps>
	@description    This method returns the field properties for each of the fields that are to be displayed on the screen
	@revisions 		AT-3657, 28 Nov 2011,
					Modified the code to display the table dynamically based on Discount Type Record Type
	**********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> getDiscountTypeFieldProps(String sfilterOn) {    
        //Get the field properties for Discount Type object
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        try {
            if(sfilterOn == System.Label.CuAp_BillToBillDiscount){
                discountTypeFields.add(GlUt_APIConstantsDiscountType.DISCOUNTPERDAYAPINAME);
                discountTypeFields.add(GlUt_APIConstantsDiscountType.MAXDISCOUNTPERSERVICEITEMAPINAME);
                discountTypeFields.add(GlUt_APIConstantsDiscountType.TOPUPAPINAME);
            }
            if(sfilterOn == System.Label.CuAp_PercentageDiscount)
                discountTypeFields.add(GlUt_APIConstantsDiscountType.PERCENTAGEDISCOUNTAPINAME);
            if(sfilterOn == System.Label.CuAp_FixedDiscount)
                discountTypeFields.add(GlUt_APIConstantsDiscountType.FIXEDDISCOUNTAPINAME);
            
            List<GLAp_FieldProps> discountTypeProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDiscounts.DISCOUNTTYPEAPINAME, discountTypeFields);
            //Want to make all of the Discount Type fields readonly   
            for(GLAp_FieldProps fldProp : discountTypeProps){
                if(fldProp.fieldName == GlUt_APIConstantsDiscountType.FIXEDDISCOUNTAPINAME){
                    fldProp.fieldLabel = CuAp_Constants.FIXEDDISCOUNTAMOUNTLABEL;                
                }
                fldProp.isEditable = false;
                if(fldProp.fieldName != GlUt_APIConstantsDiscounts.STARTDATEAPINAME)  /*AT-2107*/
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
	@date           10 Jan 2018
	@return         Map<String,List<String>>
	@description    get the picklist options of Discount Type field of the Discount object.
	@revisions		AT-3657, Modified the method to get the discount types from Record Types
	**********************************************************************************************/ 
    @AuraEnabled
    public static Map<Id,String> picklistvaluesnew(){  
        Map<String,List<String>> mapWrapper = new Map<String,List<String>>();
        Map<Id,String> mapOfRecordTypeIdToName = new Map<Id,String>(); 
        List<RecordType> recordTypes = new List<RecordType>();
        try {
            
            recordTypes = (List<RecordType>) GlAp_LightningDataAccess.getRecords('RecordType',
                                                                                 new List<String>{LoAp_Constants.Id,'Name'},
                                                                                 'WHERE sObjectType = ' + '\'' + GlUt_APIConstantsDiscountType.DISCOUNTTYPEAPINAME + '\'');
            
            for(RecordType rt : recordTypes){
                if(!mapOfRecordTypeIdToName.containsKey(rt.Id))
                    mapOfRecordTypeIdToName.put(rt.Id, rt.Name);
            }            
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return mapOfRecordTypeIdToName;        
    }
    
    /******************************************************************************
	@author         Echo: Amit K.
	@date           09-Jan-2018
	@param          none
	@return         List<BlAp_CombinedRecord>
	@description    Get the Discount Type records on the basis of contract id.
	@revisions		AT-3657, 28 Nov 2011,
					Modify the code for the concessions for Bill To Bill Discount Type Record Type
	*******************************************************************************/
    public static List<BlAp_CombinedRecord> getDiscountTypesOnContract(string contractId, string sKeyValue, string sOperation, string sfilterOn, Set<Id> concessionIdsSet) {

        Boolean NFP = false;
        List<ServiceItem__c> lstServiceItem = new List<ServiceItem__c>();
        List<BlAp_CombinedRecord> discountTypeComList = new List<BlAp_CombinedRecord>();
        List<DiscountTypeItem__c> lstDiscountItemType = new List<DiscountTypeItem__c>();
        List<DiscountType__c> lstDiscountType = new List<DiscountType__c>();
        Set<Id> discountTypeId = new Set<Id>();
        Set<Id> serviceItemTypeId = new Set<Id>();
        
        try {
            if (String.isNotBlank(contractId)) {
                if(sfilterOn == System.Label.CuAp_BillToBillDiscount)
                    NFP = validateConcessions(contractId, concessionIdsSet);                
                
                lstServiceItem = (List<ServiceItem__c>) GlAp_LightningDataAccess.getRecords(BlAp_Constants.SERVICEITEMNAME, 
                                                                                            serviceItemFields, 
                                                                                            contractId, 
                                                                                            GlUt_APIConstantsService.SERVICERELAPINAME + '.' + GlUt_APIConstantsContracts.CONTRACTAPINAME);
                if(!lstServiceItem.isEmpty()){
                    for (ServiceItem__c si : lstServiceItem) {
                        if (si.ServiceItemType__c != null) {
                            serviceItemTypeId.add(si.ServiceItemType__c);
                        }
                    }
                }
            }
            if (!serviceItemTypeId.isEmpty()) {
                lstDiscountItemType = (List<DiscountTypeItem__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDiscounts.DISCOUNTTYPEITEMAPINAME, 
                                                                                                      discountTypeItemFields, 
                                                                                                      String.format('WHERE {0} IN {1}', 
                                                                                                                    new List<String>{
                                                                                                                        GlUt_APIConstantsServiceItem.SERVICEITEMTYPEAPINAME, 
                                                                                                                            GlUt_FieldSecurity.IdsToString(serviceItemTypeId)}));
            }
            if(!lstDiscountItemType.isEmpty()){
                for (DiscountTypeItem__c dit : lstDiscountItemType) {
                    if (dit.DiscountType__c != null) {
                        discountTypeId.add(dit.DiscountType__c);
                    }
                }
            }
            if (!discountTypeId.isEmpty()) {
                String filterStatements = '';
                
                if (String.isNotBlank(sfilterOn) && sfilterOn != null) {
                    String fieldAPI;
                    String recordTypeId;
                    if(sfilterOn == System.Label.CuAp_BillToBillDiscount){
                        fieldAPI = GlUt_APIConstantsDiscountType.DISCOUNTPERDAYAPINAME; 
                        recordTypeId = Schema.SObjectType.DiscountType__c.getRecordTypeInfosByName().get(System.Label.CuAp_BillToBillDiscount).getRecordTypeId();                        
                    }
                    if(sfilterOn == System.Label.CuAp_PercentageDiscount){
                        fieldAPI = GlUt_APIConstantsDiscountType.PERCENTAGEDISCOUNTAPINAME;
                        recordTypeId = Schema.SObjectType.DiscountType__c.getRecordTypeInfosByName().get(System.Label.CuAp_PercentageDiscount).getRecordTypeId();
                    }
                    if(sfilterOn == System.Label.CuAp_FixedDiscount){
                        fieldAPI = GlUt_APIConstantsDiscountType.FIXEDDISCOUNTAPINAME;
                        recordTypeId = Schema.SObjectType.DiscountType__c.getRecordTypeInfosByName().get(System.Label.CuAp_FixedDiscount).getRecordTypeId();
                    }
                    if(String.isNotBlank(sKeyValue) && sKeyValue != null && String.isNotBlank(sOperation) && sOperation != null){
                        sKeyValue = sKeyValue.trim();
                        
                        // AT- , 12-July-2018
                        if(sOperation == System.Label.CuAp_FilterOperationEquals)
                            filterStatements += fieldAPI + ' = ' + Integer.valueOf(sKeyValue);
                        else if(sOperation == System.Label.CuAp_FilterOperationGreaterThan)
                            filterStatements += fieldAPI + ' > ' + Integer.valueOf(sKeyValue);
                        else if(sOperation == System.Label.CuAp_FilterOperationLessThan)
                            filterStatements += fieldAPI + ' < ' + Integer.valueOf(sKeyValue);
                        
                        filterStatements += GlUt_FieldSecurity.appendSearchClause(GlUt_APIConstantsDiscountType.RECORDTYPEAPINAME, recordTypeId, CuAp_Constants.OPERATIONEQUALS, false);
                    }
                    else
                        filterStatements += GlUt_FieldSecurity.appendSearchClause(GlUt_APIConstantsDiscountType.RECORDTYPEAPINAME, recordTypeId, CuAp_Constants.OPERATIONEQUALS, true);
                    
                    if(sfilterOn == System.Label.CuAp_BillToBillDiscount){                                                
                        filterStatements += ' AND ' + GlUt_APIConstantsDiscountType.NFPAPINAME + ' = ' + NFP;
                    }
                    filterStatements += ' AND ' + GlUt_APIConstantsDiscountType.ACTIVEAPINAME + ' = true';
                }
                
                lstDiscountType = (List<DiscountType__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDiscounts.DISCOUNTTYPEAPINAME, 
                                                                                              discountTypeFields, 
                                                                                              'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(discountTypeId) 
                                                                                              + (filterStatements != '' ? ' AND ' + filterStatements : ''));
            }
            
            for (DiscountType__c dt: lstDiscountType){
                BlAp_CombinedRecord objDiscountTypeCom = new BlAp_CombinedRecord();            
                objDiscountTypeCom.uniqueId = dt.Id;
                objDiscountTypeCom.isSelected = false;
                objDiscountTypeCom.objectMap = new Map<string, sObject>();
                
                //Create a map of Discount Type related field values
                objDiscountTypeCom.objectMap.put(GlUt_APIConstantsDiscounts.DISCOUNTTYPEAPINAME, dt);
                discountTypeComList.add(objDiscountTypeCom);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        system.debug(JSON.serialize(discountTypeComList));
        return discountTypeComList;
        
    }
     
    /**********************************************************************************************
	@author         Echo: Ankit Gangwani
	@date           21 Nov 2018
	@return         Boolean (NFP)
	@description    AT-3657, 28 Nov 2011,
					validate concessions for discounts and returning NFP for the associated Account
	**********************************************************************************************/    
    private static Boolean validateConcessions(String contractId, Set<Id> concessionIdsSet){  
        List<BillingContract__c> contract;
        List<Discount__c> discountLists = new List<Discount__c>();
        List<Concession__c> concessionLists = new List<Concession__c>();
        Boolean NFP = false;
      
        contract = (List<BillingContract__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsContracts.CONTRACTAPINAME,
                                                                            new List<String>{LoAp_Constants.Id,
                                                                                GlUt_APIConstantsContracts.CUSTOMERAPINAME,
                                                                                GlUt_APIConstantsContracts.RELATED_ACCOUNT + '.' + GlUt_APIConstantsAccount.NFPAPINAME},
                                                                            'WHERE ' + LoAp_Constants.Id + ' = ' + '\'' + contractId + '\'');
        
        if(contract != null && contract[0].Id != null && contract[0].AccountName__c != null){
            NFP = contract[0].AccountName__r.NFP__c;
            System.debug('NFP = '+NFP);
            
            String filterStats = ' WHERE (' + GlUt_APIConstantsConcession.PRIMARYACCOUNTAPINAME + ' = ' + '\'' + contract[0].AccountName__c + '\' OR ' + 
                GlUt_APIConstantsConcession.NONPRIMARYACCOUNTAPINAME + ' = ' + '\'' + contract[0].AccountName__c + '\') AND ' + 
                GlUt_APIConstantsConcession.VALIDATEDAPINAME + ' = TRUE AND ' + 
                GlUt_APIConstantsConcession.CONSENTDATEAPINAME + ' != NULL ';
            
            concessionLists = (List<Concession__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsConcession.CONCESSIONAPINAME,
                                                                                             concessionFields,
                                                                                             filterStats);
            if(!concessionLists.isEmpty()){
                for(Concession__c objCon : concessionLists){
                    concessionIdsSet.add(objCon.Id);
                }
            }
            
            if(concessionIdsSet.size() > 0){
                
                String discountFilter = ' WHERE ' + GlUt_APIConstantsConcession.CONCESSIONAPINAME + ' IN ' + GlUt_FieldSecurity.IdsToString(concessionIdsSet)
                    + ' AND ' + GlUt_APIConstantsDiscounts.AMENDDEDBYDISCOUNTAPINAME + ' = NULL';
                
                discountLists = (List<Discount__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDiscounts.DISCOUNTAPINAME,                                                                                        
                                                                                       new List<String>{LoAp_Constants.Id,
                                                                                           GlUt_APIConstantsConcession.CONCESSIONAPINAME,
                                                                                           GlUt_APIConstantsDiscounts.AMENDDEDBYDISCOUNTAPINAME},
                                                                                       discountFilter);   
            }
            if(!discountLists.isEmpty()){
                for(Discount__c discount : discountLists){
                    if(discount.Concession__c != null && concessionIdsSet.contains(discount.Concession__c)){
                        concessionIdsSet.remove(discount.Concession__c);
                    }
                }
            }
        }
        return NFP;
    }
    
    /******************************************************************************
	@author      	Echo: Amit K.
	@date      		10 Jan 2018
	@param			none
	@return			none
	@description	Wrapper Class to hold Discount Type details, field properties and Discount Type details
	which will be returned to helper
	@revision		AT-3657, 28 Nov 2011,
					Added 2 parameter, String discountTypeRecordType and List<Id> concessions
	*******************************************************************************/
    public class ContainerWrapper {
        @AuraEnabled public List<GLAp_FieldProps> fieldPropList; 
        @AuraEnabled public List<BlAp_CombinedRecord> discountList;
        @AuraEnabled public String discountTypeRecordType;
        @AuraEnabled public List<Id> concessions;
    }    
}