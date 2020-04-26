/******************************************************************************
@author         Echo: Dependra Singh
@date           16-Jan-2019
@description    Component controller for Split Suspense Payment Lightning Component 
*******************************************************************************/
public with sharing class PyAp_SplitSuspensePaymentCtrlr {
    // Variables
    private static final Id PAYMENTRECORDTYPEONPAYMENT = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(PyAp_Constants.PAYMENT).getRecordTypeId();
    private static List<String> paymentFields;
    private static List<String> accountFields;
    static{
        // Get fields from the Payment object
        paymentFields = new List<String>();
        paymentFields.add(GlUt_APIConstantsPayments.NAMEAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.PAYMENTDATEAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.PAYMENTMETHODAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.AMOUNTAPINAME);    }
    static{
        // Get fields from the Payment object
        accountFields = new List<String>();
        accountFields.add(GlUt_APIConstantsAccount.ACCOUNTNAMEAPINAME);
    }
    /**********************************************************************************************
    @author         Echo: Dependra Singh
    @date           16-Jan-2019
    @return         List<List<GLAp_FieldProps>>
    @description    This method returns the field properties for each of the fields that are to be displayed on the screen
    **********************************************************************************************/    
    @AuraEnabled
    public static List<List<GLAp_FieldProps>> retrievePaymentFieldPropDetails() {
        // List of fieldprops to return
        List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
        List<GLAp_FieldProps> paymentProps = new List<GLAp_FieldProps>();
        // Get the field properties for the Payment object
        for(GLAp_FieldProps fldProp : GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsPayments.PAYMENTAPINAME, paymentFields)){
            
            if(fldProp.fieldName == GlUt_APIConstantsPayments.NAMEAPINAME){
                fldProp.fieldLabel = PyAp_Constants.PAYMENTNUMBER;
                fldProp.editMode = false;
                fldProp.isEditable = false;
                fldProp.showLabel = true;
            }
            if(fldProp.fieldName == GlUt_APIConstantsPayments.AMOUNTAPINAME){
                fldProp.fieldLabel = PyAp_Constants.ORIGINALAMOUNT;
                fldProp.editMode = false;
                fldProp.isEditable = false;
                fldProp.showLabel = true;
            }
            if(fldProp.fieldName == GlUt_APIConstantsPayments.PAYMENTDATEAPINAME){
                fldProp.editMode = false;
                fldProp.isEditable = false;
                fldProp.showLabel = true;
            }
            if(fldProp.fieldName == GlUt_APIConstantsPayments.PAYMENTMETHODAPINAME){
                fldProp.editMode = false;
                fldProp.isEditable = false;
                fldProp.showLabel = true;
            }
            paymentProps.add(fldProp);
        }
        // Add transferred Field in Field Prop
        GLAp_FieldProps paymentTransProp = CreateFieldProp(true,true,false,false,false,false,Label.PyAp_TransferredAmount,
                                                           PyAp_Constants.TRANSFERREDAMOUNT,'number',true,GlUt_APIConstantsPayments.PAYMENTAPINAME);
        paymentProps.add(paymentTransProp);
        
        // Add transferred Field in Field Prop
        GLAp_FieldProps paymentTransProp1 = CreateFieldProp(true,true,false,false,false,false,Label.PyAp_RemaningAmount,
                                                            PyAp_Constants.REMANINGAMOUNT,'number',true,GlUt_APIConstantsPayments.PAYMENTAPINAME);
        paymentProps.add(paymentTransProp1);
        
        for(integer i=0; i < paymentProps.size(); i = i+2){
            List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
            integer secondEntryIndex = i+1;
            lstEntry.add(paymentProps[i]);
            
            if(secondEntryIndex < paymentProps.size()){
                lstEntry.add(paymentProps[secondEntryIndex]);   
            }
            twoColFormattedList.add(lstEntry);
        }
        return twoColFormattedList;
    } 
    /**********************************************************************************************
    @author      : Echo : Dependra Singh
    @date        : 17 Jan 2019
    @return      : GLAp_FieldProps
	@param		 : boolean isFLSVisible, boolean showLabel, boolean isEncrypted, boolean isEditable, 
				   boolean isRequired, boolean editMode, string fieldName, string fieldLabel, 
				   string fieldType, boolean transformField, string parentObject
    @description : Method id used to create Field Prop object 
    **********************************************************************************************/
    public static GLAp_FieldProps CreateFieldProp(boolean isFLSVisible, boolean showLabel, boolean isEncrypted, boolean isEditable, 
                                                  boolean isRequired, boolean editMode, string fieldName, string fieldLabel, 
                                                  string fieldType, boolean transformField, string parentObject){
                                                      GLAp_FieldProps objFieldProp = new GLAp_FieldProps();
                                                      objFieldProp.isFLSVisible = isFLSVisible;
                                                      objFieldProp.showLabel = showLabel;
                                                      objFieldProp.isEncrypted = isEncrypted;
                                                      objFieldProp.isEditable = isEditable;
                                                      objFieldProp.isRequired = isRequired;
                                                      objFieldProp.editMode = editMode;
                                                      objFieldProp.fieldName =  fieldName;
                                                      objFieldProp.fieldLabel = fieldLabel;
                                                      objFieldProp.fieldType = fieldType;
                                                      objFieldProp.transformField = transformField;
                                                      objFieldProp.parentObject = parentObject;
                                                      return objFieldProp;
                                                  }
    /**********************************************************************************************
    @author      : Echo : Dependra Singh
    @date        : 17 Jan 2019
    @description : This is a wrapper class Combined List records,FieldProperty Details.
    **********************************************************************************************/
    public class ContainerWrapper {
        @AuraEnabled public List<List<GlAp_FieldProps>> fieldPropList;
        @AuraEnabled public Payment__c objPaymnt;
        @AuraEnabled public boolean isShowCmp;
        public ContainerWrapper(){
            fieldPropList = new List<List<GlAp_FieldProps>>();
            objPaymnt= new Payment__c();
            isShowCmp = false;
        }
    }
    /**********************************************************************************************
    @author      : Echo : Dependra Singh
    @date        : 17 Jan 2019
    @return      : ContainerWrapper
    @description : Method is used to show information in lighting page using wrapper class.
    **********************************************************************************************/
    @AuraEnabled
    public static ContainerWrapper getInfoToDisplay(string paymentId){
        try{
            ContainerWrapper resultContainer = new ContainerWrapper();
            resultContainer.fieldPropList = retrievePaymentFieldPropDetails();
            resultContainer.objPaymnt = (Payment__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsPayments.PAYMENTAPINAME,paymentId,paymentFields);
            resultContainer.isShowCmp = IsShowComponent(paymentId);
            return resultContainer;
        }
        catch (exception e) {
            String errorMsg = GlUt_Logger.getActualErrorMessage(e.getMessage());
            GlUt_Logger.logException(e);
            throw new AuraHandledException(errorMsg);
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    /**********************************************************************************************
    @author      : Echo: Dependra
    @date        : 21-Jan-2019
    @params      : String
    @return      : Payment
    @description : Component will be added to the Billing Actions Component 
				   where the Payment does not have a Contract or Account associated 
				   and is not an Invalid Suspense Payment
    **********************************************************************************************/   
    public static boolean IsShowComponent(String paymentId) {
        boolean isShowComponent= false;
        Payment__c objPayment;
        paymentFields.add(GlUt_APIConstantsPayments.CONTRACTAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.ACCOUNTAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.INVALIDSUSPENSEAPINAME);
        if (String.isNotBlank(paymentId)) {
            objPayment = (Payment__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsPayments.PAYMENTAPINAME,paymentId,paymentFields);
            if(objPayment != null){
                if(string.isBlank(objPayment.BillingContract__c) && string.isBlank(objPayment.Account__c) && !objPayment.InvalidSuspense__c){
                    isShowComponent =true;
                }
            }                                                                                     
        }
        return isShowComponent;
    }
    /**********************************************************************************************
    @author      : Echo: Dependra
    @date        : 22-Jan-2019
    @params      : String
    @return      : Payment
    @description : Wrapper class for table 
    **********************************************************************************************/   
    public class SplitPaymentsWrapper {
        @AuraEnabled public BillingContract__c objBillingContract;
        @AuraEnabled public Payment__c paymentObj;
        @AuraEnabled public string strAccountName;
        @AuraEnabled public String displayFields;
        @AuraEnabled public List<String> conFieldValues;
    }
    /******************************************************************************
    @author      : Echo: Dependra
    @date        : 22-Jan-2019
    @return      : SplitPaymentsWrapper
    @description : This method adds a split payment row in the component
    *******************************************************************************/
    @AuraEnabled
    public static SplitPaymentsWrapper AddMoreRows() {
        SplitPaymentsWrapper paymentObjWrap = new SplitPaymentsWrapper();        
        try {
            paymentObjWrap.objBillingContract = new BillingContract__c();
            paymentObjWrap.paymentObj = new Payment__c();
            paymentObjWrap.displayFields = PyAp_Constants.CONTRACTDISPLAYFIELDS;
            paymentObjWrap.conFieldValues = new List<String>();
            paymentObjWrap.strAccountName= '';
            for(String fld : paymentObjWrap.displayFields.split(',')){
                paymentObjWrap.conFieldValues.add('');
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return paymentObjWrap;
    }
    /******************************************************************************
    @author      : Echo: Dependra
    @date        : 24-Jan-2019
    @return      : string AccountName
    @description : Get Account record By Account Id
    *******************************************************************************/
    @AuraEnabled
    public static string  getAccountNameById(string accountRecordId){
        string strAccountName = '';
        if(accountRecordId != null){
            Account objAccount = (Account) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsAccount.ACCOUNTAPINAME,accountRecordId,accountFields);
            if(objAccount != null){
                strAccountName =  objAccount.Name;
            }
        }
        return strAccountName;
    }
    /******************************************************************************
    @author      : Echo: Dependra
    @date        : 22-Jan-2019
    @return      : SplitPaymentsWrapper
    @description : This method adds a split payment row in the component
    *******************************************************************************/
    public static void  UpdateOriginalSuspensePayment(string recordId){
        // Update the original Suspense Payment , Invalid Suspense Payment = true
        if(recordId != null){
            Payment__c objPayment = [Select Id, InvalidSuspense__c, Amount__c,ReversedAmount__c FROM Payment__c WHERE ID =: recordId LIMIT 1];
            objPayment.InvalidSuspense__c = true;
            objPayment.ReversedAmount__c = objPayment.Amount__c;
            objPayment  = (Payment__c) GlUt_FieldSecurity.cleanseFields(objPayment, false);
            update objPayment;
        }
    }
    
    /******************************************************************************
    @author      : Echo: Dependra Singh
    @date        : 22-Jan-2019
    @return      : boolean
    @description : Method is used to save data.
    *******************************************************************************/
    @AuraEnabled
    public static boolean SaveSplitPaymentsData(string jsonString) {
        Savepoint sp = Database.setSavepoint();
        boolean isSuccess = false;
        try {
            List<Payment__c> splitPaymentList = new  List<Payment__c>();
            Payment__c originalPayment; 
            if(string.isNotBlank(jsonString)){
                PyAp_SplitPaymentWrapper objSplitPayment = PyAp_SplitPaymentWrapper.parse(jsonString);
                if(objSplitPayment.objPayment != null){
                    originalPayment = objSplitPayment.objPayment;
                    UpdateOriginalSuspensePayment(originalPayment.Id);
                }
                if(objSplitPayment.records != null && !objSplitPayment.records.isEmpty()){
                    for(PyAp_SplitPaymentWrapper.cls_records objSplitPaymentRecord  : objSplitPayment.records){
                        if(objSplitPaymentRecord.objBillingContract != null && originalPayment != null){
                            Payment__c objPayment = createSplitPayment(objSplitPaymentRecord.objBillingContract,originalPayment,PAYMENTRECORDTYPEONPAYMENT,
                                                                       objSplitPaymentRecord.paymentObj.Amount__c, false);
                            splitPaymentList.add(objPayment);
                        }
                        
                    }
                    if(objSplitPayment.remaningAmount != null && decimal.valueOf(objSplitPayment.remaningAmount)> 0){
                        if(originalPayment !=  null){
                            Payment__c objPayment = createSplitPayment(null,originalPayment,PAYMENTRECORDTYPEONPAYMENT,objSplitPayment.remaningAmount, true);
                            splitPaymentList.add(objPayment);
                        }
                    }
                }
                if(!splitPaymentList.isEmpty()){
                    splitPaymentList  = (List<Payment__c>) GlUt_FieldSecurity.cleanseFields(splitPaymentList, false);
                    insert splitPaymentList;
                    // Create Payment Assocication.
                    createPaymentAssosiation(originalPayment, splitPaymentList);
                    isSuccess = true;
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return isSuccess;
    }
    /******************************************************************************
    @author      : Echo: Dependra Singh
    @date        : 22-Jan-2019
    @return      : Payment__c
    @description : Method is used to create payments records
    *******************************************************************************/
    public static Payment__c  createSplitPayment(BillingContract__c objBillingContract, Payment__c objPayment, Id paymentRecordTypeId, decimal paymentAmount, boolean isRemaning){
        Payment__c objNewSplitPayment = new Payment__c();
        if(!isRemaning){
            objNewSplitPayment.BillingContract__c = objBillingContract.Id;
            objNewSplitPayment.Account__c = objBillingContract.AccountName__c;
        }
        objNewSplitPayment.PaymentMethod__c = objPayment.PaymentMethod__c;
        objNewSplitPayment.PaymentDate__c = objPayment.PaymentDate__c;
        objNewSplitPayment.RecordTypeId = paymentRecordTypeId;
        objNewSplitPayment.Amount__c = paymentAmount;
        return objNewSplitPayment;
    }
    
    /******************************************************************************
    @author      : Echo: Dependra Singh
    @date        : 22-Jan-2019
    @return      : 
    @description : Method is used to create payment association record.
    *******************************************************************************/
    public static void createPaymentAssosiation(Payment__c objOldPayment, List<Payment__c> newPaymentList) {
        List<PaymentAssociation__c> paymentAssocistionList = new List<PaymentAssociation__c>();
        for (Payment__c objPayment : newPaymentList) {
            PaymentAssociation__c objPaymentAssociation = new PaymentAssociation__c();
            objPaymentAssociation.OriginalPayment__c = objPayment.id;
            objPaymentAssociation.TransferredRefundedPayment__c =  objOldPayment.id;
            paymentAssocistionList.add(objPaymentAssociation);
        }
        if (!paymentAssocistionList.isEmpty()) {
            paymentAssocistionList =  (List<PaymentAssociation__c>) GlUt_FieldSecurity.cleanseFields(paymentAssocistionList, false);
            insert paymentAssocistionList;
        }
    }   
    
}