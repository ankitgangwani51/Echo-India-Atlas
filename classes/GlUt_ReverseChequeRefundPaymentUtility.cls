/******************************************************************************
@author         Echo: Amit K.
@date           28 March 2019
@description    Utility class used by process builder for Reverse Cheque Refund Payment 
*******************************************************************************/
public with sharing class GlUt_ReverseChequeRefundPaymentUtility { 
    /**********************************************************************************************
    @author         Echo: Amit K.
    @date           28-Mar-2019
    @param          List<Payment__c> paymentList
    @return         void
    @description    This method is used to create Reverse Cheque Refund Payment and
                    payment association Record 
    **********************************************************************************************/
    @InvocableMethod(label='CreateReverseChequeRefundPayment' description='Create Reverse Cheque Refund Payment and payment association Record.')
    public static void CreateReverseChequeRefundPayment(List<Payment__c> paymentList) {
        Map<Id, Payment__c>newPaymentToOldPaymentMap = new Map<Id,Payment__c>();
        List<PaymentAssociation__c> paymentAssociationList = new  List<PaymentAssociation__c>();
        for(Payment__c payObj : paymentList) {
            Payment__c  newReverseChequeRefundPayment = new Payment__c(); 
            Decimal amount = payObj.Amount__c;
            newReverseChequeRefundPayment.Amount__c = amount * -1; 
            newReverseChequeRefundPayment.BillingContract__c = payObj.BillingContract__c;
            newReverseChequeRefundPayment.PaymentDate__c = System.today();
            newReverseChequeRefundPayment.Account__c = payObj.Account__c;
            newReverseChequeRefundPayment.AmendmentReason__c = GlUt_Constants.AMENDMENT_REASON_FAILED_CHEQUE; 
            newReverseChequeRefundPayment.CreditAmount__c = amount * -1;
            newPaymentToOldPaymentMap.put(payObj.Id,newReverseChequeRefundPayment);   
        }
        if(!newPaymentToOldPaymentMap.isEmpty()) {
            List<Payment__c> lstPayment = (List<Payment__c>) GlUt_FieldSecurity.cleanseFields(newPaymentToOldPaymentMap.values(), false);
            insert lstPayment;
            for(Payment__c objPayment : paymentList) {
                //Creating Payment Association record
                if(newPaymentToOldPaymentMap.containsKey(objPayment.Id)){
                    PaymentAssociation__c paymentAssociationObj = new PaymentAssociation__c();
                    paymentAssociationObj.OriginalPayment__c = objPayment.Id;
                    paymentAssociationObj.TransferredRefundedPayment__c = newPaymentToOldPaymentMap.get(objPayment.Id).Id;
                    paymentAssociationList.add(paymentAssociationObj);
                }
            }
            if (!paymentAssociationList.isEmpty()) {
                paymentAssociationList = (List<PaymentAssociation__c>) GlUt_FieldSecurity.cleanseFields(paymentAssociationList, false);
                insert paymentAssociationList;
            }
            
        }
    }
}