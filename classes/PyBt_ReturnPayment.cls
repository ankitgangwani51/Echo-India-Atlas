/******************************************************************************
@author         Echo: Amit K.
@date           26-June-2018
@description    Class to return the payments associated with Direct Debit Return records.  
*******************************************************************************/
public with sharing class PyBt_ReturnPayment {
    private static final String CLASS_NAME = 'PyBt_ReturnPayment';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    
    /******************************************************************************
    @author         Echo: Amit K.
    @date           26-June-2018
	@param			List<BankAccountAction__c> bankAccountActionList
    @description    Method is used return payemnt and update the banck account status.
    *******************************************************************************/
    public static void returnPayment(List<BankAccountAction__c> bankAccountActionList) {
        List<BankAccountAction__c> updateBankAccountActionList = new List<BankAccountAction__c>();
        Set<Id> paymentIds = new Set<Id>();
        List<Payment__c> paymentList = new List<Payment__c>();
        Savepoint sp = Database.setSavepoint();
        try {
            for(BankAccountAction__c bankAccountAction: bankAccountActionList){
                //Find the bank account action records that are associated with Direct Debit return having payment record AND Direct Debit request.
                if(bankAccountAction.DirectDebitReturn__c != null
                   && bankAccountAction.DirectDebitReturn__r.DirectDebitRequest__c != null 
                   && bankAccountAction.DirectDebitReturn__r.Payment__c != null){
                       paymentIds.add(bankAccountAction.DirectDebitReturn__r.Payment__c); // Set of payement Ids.
                       bankAccountAction.Status__c = PyBt_Constants.BANK_ACCOUNT_ACTION_PROCESSED;
                       updateBankAccountActionList.add(bankAccountAction);
                   }else{
                       bankAccountAction.Status__c = PyBt_Constants.BANK_ACCOUNT_ACTION_ERROR;
                       updateBankAccountActionList.add(bankAccountAction);
                   }
            }
            System.debug(DEBUG+'*****updateBankAccountActionList'+updateBankAccountActionList);
            if(!updateBankAccountActionList.isEmpty()){
                Database.update(updateBankAccountActionList); // Update the bank account action status.
            }
            System.debug(DEBUG+'*****paymentIds'+paymentIds);   
            if(!paymentIds.isEmpty()){
                paymentList = [select Id,
                               Amount__c,
                               BillingContract__c,
                               Account__c
                               from Payment__c where Id In:paymentIds]; // Fetch the Payment record on the basis of payment Ids.
            }
            System.debug(DEBUG+'*****paymentList'+paymentList);
            /*Changes for AT-4237 Starts here */
            if(!paymentList.isEmpty()) {  //AT-3189  Passed extra Payment Method parameter to GlUt_ReturnPaymentUtilities.CreateNewNegativePayment
                GlUt_ReturnPaymentUtilities.CreateNewNegativePayment(paymentList, PyBt_Constants.PAYMENT_METHOD_TYPE_DIRECTDEBIT); // Call return payment utility in order to return the payment.
                for(Payment__c originalPayment : paymentList){
                    originalPayment.ReversedAmount__c = originalPayment.Amount__c;
                    originalPayment.AmendmentReason__c = System.Label.PyAp_ReturnPaymentAmendReason;
                }
                Database.update(paymentList);
            }
            /*Changes for AT-4237 Ends here */
        }
        catch (exception e) {
            Database.rollback(sp);
            GlUt_Logger.logException(e);
            System.debug(DEBUG + 'Error == ' + e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
}