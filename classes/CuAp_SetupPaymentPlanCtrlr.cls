/******************************************************************************
@author         Echo: Tarun Gupta
@date           03-Jan-2018
@description    Component controller for Setting up payment plan
@Revisions      19-Apr-2018 Tarun , AT-2266 , Removed End Date reference.
                08 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
                06 June 2018, AT-2449 Tarun - Modified to adjust Instalments for contract Renewal Date in calculatePaymentPlan method
                04 July 2018, 2935,Tarun - Modified to fix in case the books on SP is null
				16 Apr 2019 , AT-5545 and code optimization
*******************************************************************************/
public with sharing class CuAp_SetupPaymentPlanCtrlr {
    
    private static final String CLASS_NAME = 'CuAp_SetupPaymentPlanCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static List<String> payMethodTypeFieldList;
    private static List<String> payMethodFieldList;
    private static List<String> availPaymentFieldList;
    private static List<String> paymentPlanFieldList;
    private static List<String> availPaymentDayFieldList;
    private static List<String> paymentPlanTypeFieldsList;
    private static List<String> contractFields;
    private static List<String> paymentPlanTypeFields;
    private static List<String> paymentPlanTypeFieldsNew;
    private static List<String> contractListFields;
    private static List<String> balanceFieldList;
    static{
        //Get Fields from the PMT Object
        payMethodTypeFieldList = new List<String>();
        payMethodTypeFieldList.add(GlUt_APIConstantsPaymentMethodType.NAMEAPINAME);
    }
    static{
        //Get Fields from the PM Object
        payMethodFieldList = new List<String>();
        payMethodFieldList.add(GlUt_APIConstantsPaymentMethod.NAMEAPINAME);
        payMethodFieldList.add(GlUt_APIConstantsPaymentMethod.PAYMETHODTYPEAPINAME);
        payMethodFieldList.add(GlUt_APIConstantsPaymentMethod.PAYPLANTYPEAPINAME);
    }
    static{
        //Get Fields from the AP Object
        availPaymentFieldList = new List<String>();
        availPaymentFieldList.add(GlUt_APIConstantsAvailPaymentDays.DAYOFMONTHAPINAME);
        availPaymentFieldList.add(GlUt_APIConstantsAvailPaymentDays.DAYOFWEEKAPINAME);
        availPaymentFieldList.add(GlUt_APIConstantsAvailPaymentDays.PAYMENTMETHODTYPEAPINAME);
    }
    static{
        //Get Fields from the PP Object
        paymentPlanFieldList = new List<String>();
        paymentPlanFieldList.add(GlUt_APIConstantsPaymentPlan.PAYMENTPLANSTARTDATEAPINAME);
        paymentPlanFieldList.add(GlUt_APIConstantsPaymentPlan.PAYMENTPLANTOTALAPINAME);
    }
    static{
        //Get Fields from the APD Object
        availPaymentDayFieldList = new List<String>();
        availPaymentDayFieldList.add(GlUt_APIConstantsAvailPaymentDays.DAYOFMONTHAPINAME);
        availPaymentDayFieldList.add(GlUt_APIConstantsAvailPaymentDays.DAYOFWEEKAPINAME);
    } 
    static{
        //Get Fields from the PMT Object
        paymentPlanTypeFieldsList = new List<String>();
        paymentPlanTypeFieldsList.add(GlUt_APIConstantsPaymentPlanType.MAXNUMINSTALAPINAME);
    }
    static{
        //Get Fields from the BC Object
        contractFields = new List<String>();
        contractFields.add(GlUt_APIConstantsContracts.CONTRACTENDDATEAPINAME);
        contractFields.add(GlUt_APIConstantsContracts.ELIGIBLEFORBUDGETAPINAME);
        contractFields.add(GlUt_APIConstantsContracts.DAYOFMONTHAPINAME);
        contractFields.add(GlUt_APIConstantsContracts.DAYOFWEEKAPINAME);
        contractFields.add(GlUt_APIConstantsContracts.PAYMENTMETHODTYPEAPINAME);
        contractFields.add(GlUt_APIConstantsContracts.CURRENTPAYMENTPLANTYPE);
        contractFields.add(GlUt_APIConstantsContracts.PAYPLANRENEWALDATEAPINAME);
        contractFields.add(GlUt_APIConstantsContracts.BUDGETPLANONHOLDAPINAME);
    }
    static{
        //Get Fields from the BC Object
        paymentPlanTypeFields = new List<String>();
        paymentPlanTypeFields.add(GlUt_APIConstantsPaymentPlanType.NAMEAPINAME);
        paymentPlanTypeFields.add(GlUt_APIConstantsPaymentPlanType.PLANTYPEAPINAME);
        paymentPlanTypeFields.add(GlUt_APIConstantsPaymentPlanType.PAYMENTFREQAPINAME);
        paymentPlanTypeFields.add(GlUt_APIConstantsPaymentPlanType.MAXNUMINSTALAPINAME);
        paymentPlanTypeFields.add(GlUt_APIConstantsPaymentPlanType.FINALPAYMENTPLANAPINAME);
        paymentPlanTypeFields.add(GlUt_APIConstantsPaymentPlanType.DAYSNOTICEAPINAME);
        paymentPlanTypeFields.add(GlUt_APIConstantsPaymentPlanType.UNMEASUREDAPINAME);
        paymentPlanTypeFields.add(GlUt_APIConstantsPaymentPlanType.SPECIALAPINAME);
    }
    static{
        //Get Fields from the PPT Object
        paymentPlanTypeFieldsNew = new List<String>();
        paymentPlanTypeFieldsNew.add(GlUt_APIConstantsPaymentPlanType.NAMEAPINAME);
    } 
    static{
        //Get Fields from the BC Object
        contractListFields = new List<String>();
        contractListFields.add(GlUt_APIConstantsContracts.CUSTOMERAPINAME);
        contractListFields.add(GlUt_APIConstantsContracts.STATUSAPINAME);
        contractListFields.add(GlUt_APIConstantsContracts.BALANCEAPINAME);
    }
    static{
        //Get Fields from the PPT Object
        balanceFieldList = new List<String>();
        balanceFieldList.add(GlUt_APIConstantsBalances.BALANCEAMOUNTAPINAME);
        balanceFieldList.add(GlUt_APIConstantsBalances.TOTALREFUNDAMOUNTAPINAME);
    }
    /******************************************************************************
    @author         Tarun Gupta
    @date           15 Apr 2019
    @description    This wrapper class is used to diaplay information on page. 
    *******************************************************************************/
	public class paymentPlanContainerWrapper{
        @AuraEnabled
        public List<List<GlAp_FieldProps>> twoColFormattedList;
        @AuraEnabled
        public Map<String,String> mapContractDetails;
        @AuraEnabled
        public List<WrapPaymentPlanType> lstPPTWrapper;
        @AuraEnabled
        public List<WrapPaymentMethodType> lstPMTWrapper;
        
        public paymentPlanContainerWrapper(){
            this.twoColFormattedList = new List<List<GlAp_FieldProps>>();
            this.mapContractDetails = new Map<String,String>();
            this.lstPPTWrapper = new List<WrapPaymentPlanType>();
            this.lstPMTWrapper = new List<WrapPaymentMethodType>();
        }
    }
   /******************************************************************************
    @author         Tarun Gupta
    @date           15 Apr 2019
	@parameters		String recordId
    @return         PP Details wrapper class
    @description    This method is used to display page information.
    *******************************************************************************/
	@AuraEnabled
    public static paymentPlanContainerWrapper getInfoToDisplay(Id contractId) { 
        paymentPlanContainerWrapper objWrapper = new paymentPlanContainerWrapper();
        if(contractId != null ){
            objWrapper.twoColFormattedList 	= retrievePaymentPlanFields();
            objWrapper.mapContractDetails 	= getContractDetails(contractId);
            objWrapper.lstPPTWrapper		= serverPaymentPlanType();
            objWrapper.lstPMTWrapper 		= serverPaymentMethod();
        }
        return objWrapper;
	}
    /**********************************************************************************************
    @author      : Echo: Tarun Gupta
    @date        : 01-Mar-2018
    @params      : None
    @return      : List<List<GLAp_FieldProps>>
    @description : This method returns back Payment Plan related fields as List 
                   This change is done to cater name spaces changes

    **********************************************************************************************/   
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrievePaymentPlanFields() {
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            List<GLAp_FieldProps> lstPaymentMethodTypeFields = new List<GLAp_FieldProps>();
            List<GLAp_FieldProps> lstPaymentPlanTypeFields = new List<GLAp_FieldProps>();
            List<GLAp_FieldProps> lstAvailPaymentDayFields = new List<GLAp_FieldProps>();
            List<GLAp_FieldProps> lstPaymentPlanFields = new List<GLAp_FieldProps>();
            List<GLAp_FieldProps> lstPaymentPlanTypeFieldsNew = new List<GLAp_FieldProps>();
            
            lstPaymentMethodTypeFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsPaymentMethodType.PAYMENTMETHODTYPEAPINAME, payMethodTypeFieldList);
            lstPaymentPlanTypeFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsPaymentPlanType.PAYMENTPLANTYPEAPINAME, paymentPlanTypeFieldsNew); 
            
            for(integer i=0; i< lstPaymentPlanTypeFields.size() ; i++){
                lstPaymentMethodTypeFields.add(lstPaymentPlanTypeFields[i]);
            }
            lstAvailPaymentDayFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsAvailPaymentDays.AVAILPAYMENTDAYAPINAME, availPaymentDayFieldList);
            
            for(integer i=0; i< lstAvailPaymentDayFields.size() ; i++){
                lstPaymentMethodTypeFields.add(lstAvailPaymentDayFields[i]);
            }
            lstPaymentPlanFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsPaymentPlan.PAYMENTPLANAPINAME, paymentPlanFieldList);
            
            for(integer i=0; i< lstPaymentPlanFields.size() ; i++){
                lstPaymentMethodTypeFields.add(lstPaymentPlanFields[i]);
            }
            lstPaymentPlanTypeFieldsNew = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsPaymentPlanType.PAYMENTPLANTYPEAPINAME, paymentPlanTypeFieldsList);
            for(integer i=0; i< lstPaymentPlanTypeFieldsNew.size() ; i++){
                lstPaymentMethodTypeFields.add(lstPaymentPlanTypeFieldsNew[i]);
            }
            GLAp_FieldProps spProp = new GLAp_FieldProps();
            spProp.isFLSVisible = true;
            spProp.isEncrypted  = false;
            spProp.isEditable   = true;
            spProp.isRequired   = false;
            spProp.fieldName    = GlUt_APIConstantsPaymentPlan.PAYMENTPLANENDDATELABEL;
            spProp.fieldLabel   = Label.CuAp_PayPlanEndDate;
            spProp.fieldType    = 'date';
            spProp.buttonField = false;
            spProp.transformField = true; 
            spProp.parentObject = GlUt_APIConstantsPaymentPlan.PAYMENTPLANAPINAME;
            lstPaymentMethodTypeFields.add(spProp);
            
            for(GLAp_FieldProps locProp: lstPaymentMethodTypeFields){
               
                if(locProp.fieldName == GlUt_APIConstantsPaymentPlan.PAYMENTPLANSTARTDATEAPINAME){
                    locProp.changeEvent = true;
                }
                if(locProp.fieldName == GlUt_APIConstantsPaymentPlan.PAYMENTPLANTOTALAPINAME){
                    locProp.showLabel = true;
                    locProp.isEditable = false;
                    locProp.fieldLabel = Label.CuAp_PPTotalSumOfInstal;
                }
                if(locProp.fieldName == GlUt_APIConstantsAvailPaymentDays.DAYOFMONTHAPINAME){
                    locProp.fieldType = 'select';
                    locProp.fieldLabel = Label.PyAp_PaymentDateLabel;
                    locProp.changeEvent = true;
                }
                if(locProp.fieldName == GlUt_APIConstantsAvailPaymentDays.DAYOFWEEKAPINAME){
                    locProp.fieldType = 'select';
                    locProp.fieldLabel = Label.PyAp_PaymentDayLabel;
                    locProp.changeEvent = true;
                }
                if(locProp.parentObject == GlUt_APIConstantsPaymentMethodType.PAYMENTMETHODTYPEAPINAME){
                    locProp.fieldType = 'select';
                    locProp.fieldLabel = Label.PyAp_PaymentMethodLabel;
                    locProp.isRequired = true;
                    locProp.changeEvent = true;
                }
                if(locProp.parentObject == GlUt_APIConstantsPaymentPlanType.PAYMENTPLANTYPEAPINAME && locProp.fieldName == GlUt_APIConstantsPaymentPlanType.NAMEAPINAME){
                    locProp.fieldType = 'select';
                    locProp.fieldLabel = Label.PyAp_PaymentPlanTypeLabel;
                    locProp.isRequired = true;
                    locProp.changeEvent = true;
                }
                if(locProp.parentObject == GlUt_APIConstantsPaymentPlanType.PAYMENTPLANTYPEAPINAME && locProp.fieldName == GlUt_APIConstantsPaymentPlanType.MAXNUMINSTALAPINAME){
                    locProp.fieldLabel = Label.PyAp_NumOfInstalments;
                    locProp.isRequired = true;
                }
            }
            for(integer i=0; i < lstPaymentMethodTypeFields.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(lstPaymentMethodTypeFields[i]);
                
                if(secondEntryIndex < lstPaymentMethodTypeFields.size()){
                    lstEntry.add(lstPaymentMethodTypeFields[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
            }
            return twoColFormattedList;
            
         } catch (exception e) {
             GlUt_Logger.logException(e);
             throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }    
    /**********************************************************************************************
    @author      : Echo: Tarun
    @date        : 03-Jan-2018
    @return      : List<WrapPaymentMethodType>
    @params      : None
    @description : This method returns all the payment Method type records and associated avail payment day & Payment method records
    **********************************************************************************************/
    @AuraEnabled
    public static List<WrapPaymentMethodType> serverPaymentMethod(){          
        
        //Wrapper class to set values
        List<WrapPaymentMethodType> lstPMTWrapper = new List<WrapPaymentMethodType>();
        List<PaymentMethodType__c> lstPayMethodType = new List<PaymentMethodType__c>(); 
        
        try{
            //Query to find all Payment Method type records
            lstPayMethodType = (List<PaymentMethodType__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPaymentMethodType.PAYMENTMETHODTYPEAPINAME, 
                                                                                                payMethodTypeFieldList);
            Map<Id, PaymentMethodType__c> mapPaymentMethodType = new Map<Id, PaymentMethodType__c>();
            
            if (lstPayMethodType.size() > 0) {
                
                for (PaymentMethodType__c objPMT : lstPayMethodType) {
                    if (!mapPaymentMethodType.containsKey(objPMT.Id)) {
                        mapPaymentMethodType.put(objPMT.Id, objPMT);
                    }   
                }
                 
                Map<Id, List<PaymentMethod__c>> mapPaymentMethod = new Map<Id, List<PaymentMethod__c>>();
                List<PaymentMethod__c> lstPaymentMethod = new List<PaymentMethod__c>();
                lstPaymentMethod = (List<PaymentMethod__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPaymentMethod.PAYMENTMETHODAPINAME, 
                                                                                                payMethodFieldList, 
                                                                                                String.format('WHERE {0} IN {1}', 
                                                                                                    new List<String>{
                                                                                                        GlUt_APIConstantsPaymentMethod.PAYMETHODTYPEAPINAME, 
                                                                                                        GlUt_FieldSecurity.IdsToString(mapPaymentMethodType.keySet())}));
                
                if(lstPaymentMethod.size() > 0){
                    
                    for(PaymentMethod__c objPaymentMethod : lstPaymentMethod){
                        if(!mapPaymentMethod.containsKey(objPaymentMethod.PaymentMethodType__c)){
                            mapPaymentMethod.put(objPaymentMethod.PaymentMethodType__c, new List<PaymentMethod__c>());
                            mapPaymentMethod.get(objPaymentMethod.PaymentMethodType__c).add(objPaymentMethod);
                        }
                        else{
                            mapPaymentMethod.get(objPaymentMethod.PaymentMethodType__c).add(objPaymentMethod); 
                        }
                    }
                }
                
                Map<Id,List<AvailablePaymentDay__c>> mapAvailDaysList = new Map<Id,List<AvailablePaymentDay__c>>();
                List<AvailablePaymentDay__c> lstAvailpaymentDays = new List<AvailablePaymentDay__c>();
                lstAvailpaymentDays = (List<AvailablePaymentDay__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAvailPaymentDays.AVAILPAYMENTDAYAPINAME, 
                                                                                                        availPaymentFieldList, 
                                                                                                        String.format('WHERE {0} IN {1}', 
                                                                                                            new List<String>{
                                                                                                                GlUt_APIConstantsAvailPaymentDays.PAYMENTMETHODTYPEAPINAME, 
                                                                                                                GlUt_FieldSecurity.IdsToString(mapPaymentMethodType.keySet())}));

                if (lstAvailpaymentDays.size() > 0) {
                    for (AvailablePaymentDay__c objAvailPayDays : lstAvailpaymentDays) {
                        if (!mapAvailDaysList.containsKey(objAvailPayDays.PaymentMethodType__c)) {
                            mapAvailDaysList.put(objAvailPayDays.PaymentMethodType__c, new List<AvailablePaymentDay__c>());
                            mapAvailDaysList.get(objAvailPayDays.PaymentMethodType__c).add(objAvailPayDays);
                        }
                        else {
                            mapAvailDaysList.get(objAvailPayDays.PaymentMethodType__c).add(objAvailPayDays); 
                        }
                    }
                }
                
                for (Id objid : mapPaymentMethod.keySet()) {
                    WrapPaymentMethodType objWrapnew = new WrapPaymentMethodType();
                    if (mapPaymentMethodType.containsKey(objid)) {
                        objWrapnew.objPaymentMethodType = mapPaymentMethodType.get(objid);
                        if (mapPaymentMethod.containsKey(objid)) {
                            objWrapnew.lstPaymentMethod = mapPaymentMethod.get(objid);
                        }
                        if (mapAvailDaysList.containsKey(objid)) {
                            objWrapnew.lstAvailPaymentDays = mapAvailDaysList.get(objid);
                        }
                        
                        lstPMTWrapper.add(objWrapnew);
                    }
                }
            }
            
            return lstPMTWrapper;  
            
        } catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           12-Feb-2017
    @param          none
    @return         none
    @description    wrapper class to hold the Payment method Type and corresponding List of payment method and list of Avail payment day
    *******************************************************************************/
    public class WrapPaymentMethodType{
        
        @AuraEnabled public PaymentMethodType__c objPaymentMethodType;                
        @AuraEnabled public List<PaymentMethod__c> lstPaymentMethod;
        @AuraEnabled public List<AvailablePaymentDay__c> lstAvailPaymentDays;
        
        public WrapPaymentMethodType(){
            this.objPaymentMethodType = new PaymentMethodType__c();             
            this.lstPaymentMethod = new List<PaymentMethod__c>();
            this.lstAvailPaymentDays = new List<AvailablePaymentDay__c>();
        } 
    }
    
    /**********************************************************************************************
    @author      : Echo: Tarun
    @date        : 03-Jan-2018
    @return      : List<String>
    @params      : Id contractId
    @description : This method returns the contract details
    **********************************************************************************************/
    @AuraEnabled
    public static Map<String,String> getContractDetails(Id contractId){
        
        String finalPlan = 'false';        
        String eligibleForBudgetPlan = 'false';
        
        Map<String,String> mapContractDetails = new Map<String,String>();
        BillingContract__c contract;
        
        try {
             GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
            //Query to find the Contract detail record
            contract = (BillingContract__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsContracts.CONTRACTAPINAME, 
                                                                        contractId, 
                                                                        contractFields);
            if (contract.Id != null) {
                if (contract.ContractEndDate__c <= system.today()) {
                    finalPlan = 'true';                
                } 
                if (contract.CurrentPaymentPlanType__c != null) {
                    Id currentPlan = contract.CurrentPaymentPlanType__c;
                    PaymentPlanType__c paymentPlanType;
                    paymentPlanType = (PaymentPlanType__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsPaymentPlanType.PAYMENTPLANTYPEAPINAME, 
                                                                                                currentPlan, 
                                                                                                paymentPlanTypeFieldsNew);
                    if (paymentPlanType.Id != null) {
                        mapContractDetails.put(GlUt_APIConstantsContracts.CURRENTPAYMENTPLANTYPE, paymentPlanType.Name);
                    }
                }
                if (contract.PaymentPlanRenewalDate__c != null) {
                    mapContractDetails.put(GlUt_APIConstantsContracts.PAYPLANRENEWALDATEAPINAME, String.valueOf(contract.PaymentPlanRenewalDate__c));
                }
                if (contract.PaymentMethodType__c != null) {
                    Id currentMethod = contract.PaymentMethodType__c;
                    PaymentMethodType__c paymentMethodType;
                    paymentMethodType = (PaymentMethodType__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsPaymentMethodType.PAYMENTMETHODTYPEAPINAME, 
                                                                                                currentMethod, 
                                                                                                payMethodTypeFieldList);
                    
                    if (paymentMethodType.Id != null) {
                        mapContractDetails.put(GlUt_APIConstantsPaymentMethod.PAYMETHODTYPEAPINAME, paymentMethodType.Name);
                    }
                }
                if (contract.DayOfMonth__c != null) {
                    String dayOfMonth = contract.DayOfMonth__c;
                    mapContractDetails.put(GlUt_APIConstantsContracts.DAYOFMONTHAPINAME, dayOfMonth);
                }
                if (contract.DayOfWeek__c != null) {
                    String dayOfWeek = contract.DayOfWeek__c;
                    mapContractDetails.put(GlUt_APIConstantsContracts.DAYOFWEEKAPINAME, dayOfWeek);
                }
                eligibleForBudgetPlan = (contract.EligibleforBudgetPlan__c) ? 'true' : 'false';
                mapContractDetails.put(GlUt_APIConstantsContracts.BUDGETPLANONHOLDAPINAME, String.valueOf(contract.BudgetPlanHold__c));
            }
            mapContractDetails.put(GlUt_APIConstantsPaymentPlanType.FINALPAYMENTPLANAPINAME, finalPlan);
            mapContractDetails.put(GlUt_APIConstantsContracts.ELIGIBLEFORBUDGETAPINAME, eligibleForBudgetPlan);
                        
            String unMeasured = '';
            Set<Id> supplyPointIdSet = new Set<Id>();
            for (Service__c service : [SELECT Supplypoint__c 
                                            FROM Service__c 
                                            WHERE BillingContract__c = :contractId]) {
                supplyPointIdSet.add(service.Supplypoint__c);
            }
            for (SupplyPointDevice__c objSPD : [SELECT Active__c FROM SupplyPointDevice__c WHERE SupplyPoint__c IN: supplyPointIdSet]) {
                if (objSPD.Active__c) {
                    unMeasured = 'false';
                    break;
                }
            }
            mapContractDetails.put(GlUt_APIConstantsPaymentPlanType.UNMEASUREDAPINAME, unMeasured);
            return mapContractDetails;
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
    @author      : Echo: Tarun
    @date        : 03-Jan-2018
    @return      : List<String>
    @params      : None
    @description : This method returns all the payment plan type records and associated Payment method records
    **********************************************************************************************/
    @AuraEnabled
    public static List<WrapPaymentPlanType> serverPaymentPlanType(){
               
        //Wrapper class to set values
        List<WrapPaymentPlanType> lstPPTWrapper = new List<WrapPaymentPlanType>();
        
        List<PaymentPlanType__c> lstPPTypeQuery = new List<PaymentPlanType__c>();
        
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
            lstPPTypeQuery = (List<PaymentPlanType__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPaymentPlanType.PAYMENTPLANTYPEAPINAME, 
                                                                                            paymentPlanTypeFields, 
                                                                                            'WHERE ' + GlUt_APIConstantsPaymentPlan.ACTIVEAPINAME + ' = true');

            if (lstPPTypeQuery.size() > 0) {

                Map<Id, PaymentPlanType__c> mapPPT = new Map<Id, PaymentPlanType__c>();
                for (PaymentPlanType__c objPPT : lstPPTypeQuery) {
                    
                    if (!mapPPT.containsKey(objPPT.Id)) {
                        mapPPT.put(objPPT.Id, objPPT);
                    }
                }
                
                List<PaymentMethod__c> lstPaymentMethod = new List<PaymentMethod__c>();                
                lstPaymentMethod = (List<PaymentMethod__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPaymentMethod.PAYMENTMETHODAPINAME, 
                                                                                                payMethodFieldList, 
                                                                                                String.format('WHERE {0} IN {1}', 
                                                                                                    new List<String>{
                                                                                                        GlUt_APIConstantsPaymentMethod.PAYPLANTYPEAPINAME, 
                                                                                                        GlUt_FieldSecurity.IdsToString(mapPPT.keySet())}));

                if (lstPaymentMethod.size() > 0) {
                    
                    Map<Id, List<PaymentMethod__c>> mapPaymentList = new Map<Id, List<PaymentMethod__c>>();
                    for (PaymentMethod__c objPaymentMethod : lstPaymentMethod) {
                        
                        if (!mapPaymentList.containsKey(objPaymentMethod.PaymentPlanType__c)) {
                            mapPaymentList.put(objPaymentMethod.PaymentPlanType__c, new List<PaymentMethod__c>());
                            mapPaymentList.get(objPaymentMethod.PaymentPlanType__c).add(objPaymentMethod);
                        }
                        else {
                            mapPaymentList.get(objPaymentMethod.PaymentPlanType__c).add(objPaymentMethod); 
                        }
                    }
                    
                    for (Id objid : mapPaymentList.keySet()) {
                        WrapPaymentPlanType objWrapnew = new WrapPaymentPlanType();
                        if (mapPPT.containsKey(objid)) {
                            objWrapnew.objPaymentPlanType = mapPPT.get(objid);
                            if (mapPaymentList.containsKey(objid)) {
                                objWrapnew.lstPaymentMethod = mapPaymentList.get(objid);
                                
                                lstPPTWrapper.add(objWrapnew);
                            }
                        }
                    }
                    
                }
            }
            
            return lstPPTWrapper;
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           12-Feb-2017
    @param          none
    @return         none
    @description    wrapper class to hold the Payment Plan Type and corresponding List of payment method
    *******************************************************************************/
    public class WrapPaymentPlanType{
        
        @AuraEnabled public PaymentPlanType__c objPaymentPlanType;                
        @AuraEnabled public List<PaymentMethod__c> lstPaymentMethod; 
        
        public WrapPaymentPlanType(){
            this.objPaymentPlanType = new PaymentPlanType__c();             
            this.lstPaymentMethod = new List<PaymentMethod__c>();
        } 
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           24 Jan 2018
    @param          Contract__c - the contract including fields: Id, CurrentPaymentPlanType__c, DayOfWeek__c, DayOfMonth__c
    @param          BillingContract__c contract, Integer numberOfInstalments, String planStartDate
    @return         PpUt_PaymentPlanPackage - wrapper containing the plan and instalments
    @description    returns the Instalment Records in a PpUt_PaymentPlanPackage wrapper
    *******************************************************************************/
    @AuraEnabled
    public static PpUt_PaymentPlanPackage calculatePaymentPlan(BillingContract__c contract, Integer numberOfInstalments, String planStartDate, String creditRefund, String planEndDate) {
        Date planStartDateNew;
        Date planEndDateNew;
        
        if (String.isNotBlank(planStartDate)) {
            planStartDateNew = Date.valueOf(planStartDate);
        }
        if (String.isNotBlank(planEndDate)) {
            planEndDateNew = Date.valueOf(planEndDate);
        }
        String strBalanceAmount = getBalanceAmount(contract.Id,contractListFields,balanceFieldList,creditRefund);
        try {
            PpUt_PaymentPlanPackage instalmentDetails = PpUt_PaymentPlanUtilities.calculatePlan(contract, decimal.valueOf(strBalanceAmount), Integer.valueOf(numberOfInstalments), planStartDateNew, planEndDateNew);
            //At- 2449
            if(instalmentDetails.paymentPlanType != null && instalmentDetails.paymentPlanType.PlanType__c == Label.CuAp_PaymentPlanTypePlanTypeBudgetPlan){
                List<Book__c> bookList = new List<Book__c>();
                GlUt_UpdateBudgetRenewals.WrapPaymentPlanInstalments wrapClass = new GlUt_UpdateBudgetRenewals.WrapPaymentPlanInstalments();
                wrapClass = GlUt_UpdateBudgetRenewals.amendPPInstalments(instalmentDetails.paymentPlan.BillingContract__c,instalmentDetails.planStartDate,instalmentDetails.paymentPlanType,instalmentDetails.instalments, bookList, instalmentDetails.planEndDate);  // AT-3174 
                if(wrapClass != null){
                    if(instalmentDetails.instalments.size() > 0 && wrapClass.lstInstalmentsToBeAdded != null && wrapClass.lstInstalmentsToBeAdded.size() > 0){
                        instalmentDetails.instalments.clear();
                        instalmentDetails.instalments.addall(wrapClass.lstInstalmentsToBeAdded);
                        Integer numberOfNormalInstalments = 0;
                        for(Instalment__c objInstalment :wrapClass.lstInstalmentsToBeAdded){
                            if(objInstalment.Type__c == Label.CuAp_InstalmentTypeNormal){
                                numberOfNormalInstalments += 1;
                            }
                        }
                        instalmentDetails.numberOfInstalments = numberOfNormalInstalments;
                    }
                    if(wrapClass.contractRenewalDate != null){
                        instalmentDetails.planRenewalDate = wrapClass.contractRenewalDate;
                    }
                }
            }
            return instalmentDetails;
            
        } catch (exception e) {
            system.debug('Here finally **'+ e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           13 Feb 2018
    @param          contractId - the contract Id, CurrentPaymentPlanType__c, DayOfWeek__c, DayOfMonth__c
    @param          List - list of contract fields
    @param          List - list of balance fields
    @return         String of Balance Amount
    @description    returns the Balance Amount
    *******************************************************************************/
    public static String getBalanceAmount(Id contractId, List<String> contractListFields, List<String> balanceFieldList, String creditRefund) {
        String strBalanceAmount = '0.0';
        if (contractId != null) {
            BillingContract__c contract = (BillingContract__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsContracts.CONTRACTAPINAME, 
                                                                                                  contractId, 
                                                                                                  contractListFields);
            if (contract.Balance__c != null) {
                Balance__c balance = (Balance__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsBalances.BALANCEAPINAME,
                                                                                     contract.Balance__c,  
                                                                                     balanceFieldList);
                if(String.isNotBlank(creditRefund) && creditRefund != null && creditRefund == 'false' && balance.Balance__c != null){
                    strBalanceAmount = String.valueOf(balance.Balance__c);
                }
                else if (balance.Balance__c != null && balance.Balance__c > 0) {
                    strBalanceAmount = String.valueOf(balance.Balance__c);
                }
            }
        }
        return strBalanceAmount;
    }
    
}