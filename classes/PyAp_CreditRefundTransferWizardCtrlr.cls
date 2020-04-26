/******************************************************************************
@author         Echo: Dependra Singh
@date           02 Feb 2018
@description    Wizard Component controller for Refund and transfer credit calling from Balance object.
*******************************************************************************/
public with sharing class PyAp_CreditRefundTransferWizardCtrlr{
    
    private static final String CLASS_NAME = 'PyAp_CreditRefundTransferWizardCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static List<String> contractListFields;
    private static List<String> balanceFieldList;
    private static List<String> paymntPlanTypeFields;
    private static List<String> paymentFields;
    
    
    static{
        contractListFields = new List<String>();
        contractListFields.add(GlUt_APIConstantsContracts.CUSTOMERAPINAME);
        contractListFields.add(GlUt_APIConstantsContracts.STATUSAPINAME);
        contractListFields.add(GlUt_APIConstantsContracts.BALANCEAPINAME);
        contractListFields.add( GlUt_APIConstantsContracts.CURRENTPAYMENTPLANTYPE);
    }
    
    // List of balances field string.    
    static{  
        balanceFieldList = new List<String>();
        balanceFieldList.add(GlUt_APIConstantsBalances.BALANCEAMOUNTAPINAME);
        balanceFieldList.add(GlUt_APIConstantsBalances.TOTALREFUNDAMOUNTAPINAME);
        balanceFieldList.add(GlUt_APIConstantsBalances.ACCOUNTAPINAME);
    }
    static{
        paymentFields = new List<String>();
        paymentFields.add(GlUt_APIConstantsPayments.RECORDTYPEAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.AMOUNTAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.REFUNDSTATUSAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.CONTRACTAPINAME);
    }
       static{  
        paymntPlanTypeFields = new List<String>();
      //  paymntPlanTypeFields.add(GlUt_APIConstantsBalances.BALANCEAMOUNTAPINAME);
      //  paymntPlanTypeFields.add(GlUt_APIConstantsBalances.TOTALREFUNDAMOUNTAPINAME);
        paymntPlanTypeFields.add(GlUt_APIConstantsPaymentPlanType.PLANTYPEAPINAME);        
    }                 
    //New object of wrapper class.                     
    private static WizardObject wizObject;
    
    /******************************************************************************
	@author         Echo: Dependra Singh
	@date           02 Feb 2018
	@description    Wrapper class for Wizard variables
	*******************************************************************************/
    /*
	Screen  wizardprop element name         type
	==============================================================================
	Base
	recordId                        Id (the Id of the host page record)
	objPayment                      New Payment Record details From screen 
	contractId                      Contract Id - Related to balance
	isCreditTransfer                Boolean to check credit transfer operation
	isCreditRefund                  Boolean to check credit refund operation
	*/  
	
    @TestVisible 
    private class WizardObject {
        @TestVisible private Id recordId;
        @TestVisible private Boolean isCreditTransfer;
        @TestVisible private Boolean isCreditRefund;
        @TestVisible private Boolean isCreditWriteOff;
        @TestVisible private Payment__c objPayment;
        @TestVisible private Id contractId;
    }
    
    /******************************************************************************
	@author         Echo: Dependra Singh
	@date           02 Feb 2018
	@param          String - wizardprop
	@return         void
	@description    Updates the wizard properties
	*******************************************************************************/
    public static void updateWizardProperties(String wizardprop) {
        
        // strip out all the SObject type references from the json
        wizardprop = wizardprop.replaceAll('"sobjectType":"(.*?)"(,|[^}]*)', '');
        // and deserialise it
        wizObject = (WizardObject)System.JSON.deserialize(wizardprop, WizardObject.class);
    }
    
    /******************************************************************************
	@author         Echo: Dependra Singh
	@date           02 Feb 2018
	@param          String (Balance Id as string)
	@return         Id (It will return contract Id)
	@description    Method is used by CredRefundTransfer Wizard component to Get Contract id
	*******************************************************************************/
    @AuraEnabled
    public static Id getContractId(String strBalanceId) {
        try {	
			List<BillingContract__c> contracts = (List<BillingContract__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsContracts.CONTRACTAPINAME, 
																									contractListFields, 
																									strBalanceId, 
																									GlUt_APIConstantsContracts.BALANCEAPINAME);
			for (BillingContract__c contract : contracts) {
				return contract.Id;
			}
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return null;
    }
     
    /******************************************************************************
	@author         Echo: Dependra Singh
	@date           02 Feb 2018
	@param          Id - account Id
	@return         Map<String, Boolean> - map of status keyed on the status name
	@description    Method called by the Component to determine any status required for navigation
	*******************************************************************************/
    @AuraEnabled
    public static Map<String, Boolean> wizardStatus(String wizardprop) {

        try {
            // build the wizard object from the wizard properties
            UpdateWizardProperties(wizardprop);
            Map<String, Boolean> status = new Map<String, Boolean>();
            if (wizObject.contractId != null) {
				BillingContract__c contract = (BillingContract__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsContracts.CONTRACTAPINAME, 
																						wizObject.contractId, 
																						contractListFields);
                if (contract.Id != null && contract.CurrentPaymentPlanType__c != null) {                   
                    
			        PaymentPlanType__c paymentPlanType = (PaymentPlanType__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsPaymentPlanType.PAYMENTPLANTYPEAPINAME, 
								        																		contract.CurrentPaymentPlanType__c, 
																												paymntPlanTypeFields);
                    
                    if (paymentPlanType != null && paymentPlanType.Id != null) {               
                        status.put(PyAp_Constants.BUDGETPLAN, (paymentPlanType.PlanType__c == PyAp_Constants.BUDGETPLAN));
                    }                   
                }
            }
            return status;
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
	@author         Echo: Dependra Singh
	@date           02 Feb 2018
	@param          String - json string of object wizardprop
	@return         Id - Id of the 
	@description    Method called by wizard to complete the Payment Process. 
					We are callling two process from this method based on condition. 
					(1) - Credit Refund processs
					(2) - Credit Transfer process.
	*******************************************************************************/
    @AuraEnabled
    public static Id creditRefundTransfer(String wizardprop) {
        Savepoint sp = Database.setSavepoint();
        try {
            // build the wizard object from the wizard properties
            UpdateWizardProperties(wizardprop); 
            //public PaymentPlan__c paymentPlanRecord
            if (wizObject.contractId  != null && wizObject.objPayment != null ) {
                BillingContract__c contract = (BillingContract__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsContracts.CONTRACTAPINAME, wizObject.contractId,contractListFields);
                if(wizObject.isCreditWriteOff != null && wizObject.isCreditWriteOff){
                    Balance__c objBalance =  GlUt_BalanceUtilities.getBalance(Id.ValueOf(wizObject.contractId),contractListFields,balanceFieldList);
                    if(objBalance != null)
                        PyAp_RefundTransferCreditUtility.ProcessCreditWriteOff(Id.ValueOf(wizObject.contractId),objBalance);// AU3 Changes- Dependra Singh
                }
                else{
                    system.debug('contract.Id======'+contract.Id);
                    system.debug('wizObject.isCreditRefund======'+wizObject.isCreditRefund);
                    if (contract.Id != null) {
                        if (wizObject.isCreditRefund){
                            PyAp_RefundTransferCreditUtility.refundCredit(wizObject.objPayment, contract);
                        } else if (wizObject.isCreditTransfer) {
                            if (wizObject.objPayment != null) {
                                PyAp_RefundTransferCreditUtility.transferCredit(wizObject.objPayment, contract);
                            }
                        }
                    }
                }
            }              
            return wizObject.recordId;
        } catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    /**********************************************************************************************
    @author      : Echo: Dependra
    @date        : 02-Feb-2018
    @params      : Id- ContractId
    @return      : String (returns balance amount as string values )
    @description : This method is used to get balance amount, balance which is associated with contract.
    **********************************************************************************************/
    @AuraEnabled
    public static BalanceWrapper getCreditDetails(Id contractId){
        BalanceWrapper objBalanceTransfer = new BalanceWrapper();
        try {
            objBalanceTransfer.totalCreditAmount =  GlUt_BalanceUtilities.getBalanceAmount(Id.ValueOf(contractId),contractListFields,balanceFieldList);
            objBalanceTransfer.alreadyRequestedCreditAmount = fetchAlreadyRequestedRefundAmount(Id.valueOf(contractId));
            
            objBalanceTransfer.isInActiveWithDebt = IsShowCreditWriteOff(Id.valueOf(contractId));
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return objBalanceTransfer;
    } 
    /**********************************************************************************************
    @author      : Echo: Dependra Singh
    @date        : 04-02-2019
    @params      : Id- ContractId
	@return 	 : decimal 
    @description : This method is used to get already requested amount for refund.
    **********************************************************************************************/
    
    public static boolean IsShowCreditWriteOff(Id contractId){
        boolean isInActiveWithDebt = false;
        BillingContract__c objContract = (BillingContract__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsContracts.CONTRACTAPINAME, contractId,contractListFields);
        if(objContract != null && string.isNotBlank(objContract.Status__c)){
            if(system.label.GlAp_ContractStatusInactiveWithCredit == objContract.Status__c){
                isInActiveWithDebt = true;
            }
        }
        return isInActiveWithDebt;
    }
    
    /**********************************************************************************************
    @author      : Echo: Dependra
    @date        : 30-11-2018
    @params      : Id- ContractId
	@return 	 : decimal 
    @description : This method is used to get already requested amount for refund.
    **********************************************************************************************/
    public static decimal fetchAlreadyRequestedRefundAmount(Id contractId){
        decimal alreadyRequestedAmount = 0.00;
        Id REFUNDRECORDTYPEONPAYMENT = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(PyAp_Constants.REFUND).getRecordTypeId();
        Set<Id> contractIds = new Set<Id>();
        if(contractId != null){
            contractIds.add(contractId);
        }
        List<Payment__c> paymentList = (List<Payment__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPayments.PAYMENTAPINAME, 
                                                                                              paymentFields, 
                                                                                              REFUNDRECORDTYPEONPAYMENT, 
                                                                                              GlUt_APIConstantsPayments.RECORDTYPEAPINAME, 
                                                                                              String.format(' {0} IN {1}', 
                                                                                                            new List<String>{
                                                                                                                GlUt_APIConstantsPayments.CONTRACTAPINAME, 
                                                                                                                    GlUt_FieldSecurity.IdsToString(contractIds)}));
        if(paymentList != null && !paymentList.isEmpty()){
            for(Payment__c objPayment : paymentList){
                if(objPayment.RefundStatus__c == PyAp_Constants.REQUESTED_REFUND_STATUS && objPayment.Amount__c != null){
                    alreadyRequestedAmount += objPayment.Amount__c*-1;
                }
            }
        }
        return alreadyRequestedAmount;	 	
    }
    /**********************************************************************************************
    @author      : Echo: Dependra
    @date        : 30-11-2018
    @description : This class is used to get the credit and already requested amount.
    **********************************************************************************************/
    public class BalanceWrapper{
        @AuraEnabled
        public decimal totalCreditAmount;
        @AuraEnabled
        public decimal alreadyRequestedCreditAmount;
        @AuraEnabled
        public boolean isInActiveWithDebt;
        public BalanceWrapper(){
            isInActiveWithDebt = false;
        }
    }
}