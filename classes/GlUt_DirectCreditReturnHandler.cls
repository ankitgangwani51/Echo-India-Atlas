/******************************************************************************
@author         Echo: Vivek Sethi
@date           21 June 2018
@description    Handler for Direct Credit Return  Trigger 
*******************************************************************************/
public with sharing class GlUt_DirectCreditReturnHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'PyAp_DirectCreditReturnHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           21 June 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void MainEntry(GlUt_TriggerHandlerObj inputParam) {
        try {
            if (inputParam.isInsert && inputParam.isBefore) {
                createReturnPayments(inputParam.newlist);
            }
            if (inputParam.isInsert && inputParam.isAfter) {
            }
            if (inputParam.isUpdate && inputParam.isBefore) {
                createReturnPayments(inputParam.newlist);
            }
            if (inputParam.isUpdate && inputParam.isAfter) {
                
            }
            if (inputParam.isDelete && inputParam.isBefore) {
                
            }
            if (inputParam.isDelete && inputParam.isAfter) {
                
            }
        } catch (Exception ex) {
            system.debug('Line Number:=' + ex.getLineNumber());
            system.debug('Line Number:=' + ex.getMessage());
            system.debug('Line Number:=' + ex.getStackTraceString());
            GlUt_Logger.logException(ex);
        } finally {
            //Reset the active function to null in case this class was first in stack
            //this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();
            
        }
    }
    
    /******************************************************************************
    @author         ECHO: Vivek Sethi
    @date           21 June 2018
    @param          List<DirectCreditReturn__c> DirectCreditReturnList
    @description    Create a Return Payment If Payment Record type is 'refund' and if Payment Record Type is 'Goodwill'  export status as 'Error'
    @return         void
    *******************************************************************************/
    public void createReturnPayments(List<DirectCreditReturn__c> newlist) {
        
        List<DirectCreditReturn__c> DirectCreditReturnUpdateList = new List<DirectCreditReturn__c>();
        List<Payment__c>  paymentToUpdateList = new List<Payment__c>();
       
        List<Payment__c> createNegativePaymentsList = new List<Payment__c>();
        Map<Id,Payment__c> mapOfContractId2Payment = new Map<Id,Payment__c>();
        Map<Id, DirectCreditReturn__c>  directCreditReturnContractIdMap = new Map<Id, DirectCreditReturn__c>();
        //AT-4415 Changes starts here
        for(DirectCreditReturn__c directCreditObj : newlist) {
            if(directCreditObj.Status__c != GlUt_Constants.DIRECT_CREDIT_STATUS_PROCESSED){
                directCreditObj.Status__c = GlUt_Constants.DIRECT_CREDIT_STATUS_PROCESSED;
                directCreditReturnContractIdMap.put(directCreditObj.BillingContract__c, directCreditObj);
            }
        }
        system.debug('directCreditReturnContractIdMap====='+directCreditReturnContractIdMap);

        if(!directCreditReturnContractIdMap.isEmpty()) {
            for(Payment__c paymentObj :  [Select Id, Amount__c, BankAccountNumber__c,
                                          BankAccountDetail__c,  BillingContract__c, Account__c,  RecordType.Name , RefundExportStatus__c, AmendmentReason__c  from Payment__c 
                                          where BillingContract__c IN: directCreditReturnContractIdMap.keySet() 
                                          and RecordType.name IN ('Refund', 'Goodwill') order by CreatedDate desc]) 
            { 
                if(!mapOfContractId2Payment.containsKey(paymentObj.BillingContract__c))
                    mapOfContractId2Payment.put(paymentObj.BillingContract__c,paymentObj);
            }
            for(Payment__c paymentObj : mapOfContractId2Payment.values()) {
                if ((paymentObj.RecordType.name == GlUt_Constants.PAYMENT_RECORDTYPE_REFUND  || paymentObj.RecordType.name == GlUt_Constants.PAYMENT_RECORDTYPE_GOODWILL)
                    && (paymentObj.BankAccountNumber__c != null || paymentObj.BankAccountDetail__c != null)
                    && (paymentObj.Amount__c == directCreditReturnContractIdMap.get(paymentObj.BillingContract__c).Amount__c )) 
                {
                    if(paymentObj.RecordType.Name == GlUt_Constants.PAYMENT_RECORDTYPE_REFUND) {
                        //Update its original payment 
                        paymentObj.AmendmentReason__c = System.Label.PyAp_ReturnPaymentAmendReason;
                        paymentObj.ReversedAmount__c = paymentObj.Amount__c;
                        paymentObj.PaymentTransferReason__c = GlUt_Constants.DIRECT_CREDIT_RETURN;
                        //Create Payment list to create its negative payment
                        createNegativePaymentsList.add(paymentObj);
                        paymentToUpdateList.add(paymentObj);
                    }
                    else {   // 'Goodwill'
                        //Marking  the original Payment Refund Export Status as ‘Error’ 
                        paymentObj.RefundExportStatus__c =  GlUt_Constants.REFUND_EXPORT_STATUS_ERROR; 
                        paymentToUpdateList.add(paymentObj);
                    }
                }
                else {  
                    // if Payment Cannot be found then Updating its Direct Credit Return Status to Error
                    DirectCreditReturn__c directcreditReturnObj = directCreditReturnContractIdMap.get(paymentObj.BillingContract__c);
                    if(directcreditReturnObj != null) {
                        directcreditReturnObj.Status__c = GlUt_Constants.REFUND_EXPORT_STATUS_ERROR;
                        //DirectCreditReturnUpdateList.add(directcreditReturnObj);
                    }
                }
            }
            system.debug('paymentToUpdateList====='+paymentToUpdateList);
            //If payments does not exists then change the Direct Credit Return status to Error
            for(DirectCreditReturn__c directcreditReturnObj : directCreditReturnContractIdMap.values()) {
                if(!mapOfContractId2Payment.containsKey(directcreditReturnObj.BillingContract__c)) {
                    directcreditReturnObj.Status__c = GlUt_Constants.REFUND_EXPORT_STATUS_ERROR;
                    //DirectCreditReturnUpdateList.add(directcreditReturnObj);
                }
            }

            // Update by Dependra - 04-01-2019 - Checkmarks Review Changes
            if (!paymentToUpdateList.isEmpty()) {
                paymentToUpdateList = (List<Payment__c>) GlUt_FieldSecurity.cleanseFields(paymentToUpdateList, false);
                upsert paymentToUpdateList;
                if(!createNegativePaymentsList.isEmpty()) {  //Creating New Negative Payment record  
                    GlUt_ReturnPaymentUtilities.CreateNewNegativePayment(createNegativePaymentsList , GlUt_Constants.DIRECT_CREDIT);     //AT-3189 
                }
            }
            /* if(!DirectCreditReturnUpdateList.isEmpty())
                    update DirectCreditReturnUpdateList;*/
            //AT-4415 Changes Ends here
        }
    }
    
}