/******************************************************************************
@author         Echo: Amit K.
@date           20 June 2018
@description    Handler for Instalment trigger
                AT-4891/2 Code Check Marx Changes for FLS INSERT/UPDATE
*******************************************************************************/
public with sharing class GlUt_DirectDebitRequestHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_DirectDebitRequestHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    List<Payment__c> newPaymentList;
    
    /******************************************************************************
    @author         Echo: Amit K.
    @date           20 June 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {
        try {            
            if (inputParam.isInsert && inputParam.isAfter) {
            }
            
            if (inputParam.isUpdate && inputParam.isAfter) {
                // Allocate Newely Created Payment to DDR.
                allocatePaymentToDirectDebitRequest(inputParam.newlist, inputParam.oldmap);
            }
            
            if (inputParam.isDelete && inputParam.isBefore) {
            }
            
            if (inputParam.isDelete && inputParam.isAfter) {
            }
            
        } catch (exception e) {

            GlUt_Logger.logException(e);
            
        }
        finally {
            // insert the new payment records 
            if(newPaymentList != null && !newPaymentList.isEmpty()) {
                newPaymentList = (List<Payment__c>) GlUt_FieldSecurity.cleanseFields(newPaymentList, false); //AT-4891 Code Check Marx Changes Starts/Ends Here.
                insert newPaymentList;
            }
            // Reset the active function to null in case this class was first in stack
            // this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         Echo: Amit K.
    @date           20 June 2018
    @param          List<SObject> newlist - trigger.new
    @param          Map<Id, SObject> oldMap - trigger.oldMap
    @description    Allocate Newely Created Payment to Direct Debit Request record.
    *******************************************************************************/
    private void allocatePaymentToDirectDebitRequest(List<SObject> newlist, Map<Id, SObject> oldMap) {
        
        newPaymentList = new List<Payment__c>();
        Set<Id> directDebitRequestIds = new Set<Id>();
        for(DirectDebitRequest__c ddr : (List<DirectDebitRequest__c>) newlist) {
            if(ddr.Status__c == PyBt_Constants.DIRECT_DEBIT_REQUEST_STATUS_CONFIRMED && ddr.Status__c != ((DirectDebitRequest__c) oldMap.get(ddr.Id)).Status__c) {
                directDebitRequestIds.add(ddr.Id);
            }
        }
        List<DirectDebitRequest__c> directDebitRequestList = new List<DirectDebitRequest__c>();
        if(!directDebitRequestIds.isEmpty()){
           directDebitRequestList = [select Id,
                                     BillingContract__c,
                                     Instalment__r.InstalmentAmountDue__c,
                                     Instalment__r.InstalmentDueDate__c,
                                     BillingContract__r.AccountName__c from DirectDebitRequest__c where Id In:directDebitRequestIds];
        }
        if(!directDebitRequestList.isEmpty()){
            for(DirectDebitRequest__c ddr: directDebitRequestList){
                //Create New Payment record from Direct Debit request record having Status = Confirmed.
                Payment__c objPayment = new Payment__c();
                objPayment.Amount__c = ddr.Instalment__r.InstalmentAmountDue__c;
                objPayment.PaymentDate__c = ddr.Instalment__r.InstalmentDueDate__c;
                objPayment.DirectDebitRequest__c = ddr.Id;
                objPayment.BillingContract__c = ddr.BillingContract__c;
                objPayment.Account__c = ddr.BillingContract__r.AccountName__c; 
                objPayment.PaymentMethod__c = PyBt_Constants.PAYMENT_METHOD_TYPE_DIRECTDEBIT; //AT-3120 Starts/ends Here
                newPaymentList.add(objPayment);
            }
        }
               
        System.debug(DEBUG+ '*****newPaymentList ' + newPaymentList);
    }
}