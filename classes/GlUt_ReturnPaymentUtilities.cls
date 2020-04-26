/******************************************************************************
@author         Echo: Vivek Sethi
@date			25 June 2018
@description:   Return Payment Plan utility class
@group          Utility
Revision(s)     
*******************************************************************************/
public with sharing class GlUt_ReturnPaymentUtilities {
    
    /******************************************************************************
	@author         Echo: Vivek Sethi
	@date           25 June 2018
	@param          List<Payment__c> paymentList
	@return         
	@description    Creates New Negative Payment instance
	*******************************************************************************/
    public static void CreateNewNegativePayment(List<Payment__c> paymentList , String paymentMethod) {
        
        ID recordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(System.Label.PyAp_ReturnTransferPaymentRecordType).getRecordTypeId();
        Map<Id, Payment__c>newPaymentToOldPaymentMap = new Map<Id,Payment__c>();
        List<PaymentAssociation__c> paymentAssociationList = new  List<PaymentAssociation__c>();
        for(Payment__c payObj : paymentList) {
            Payment__c  newNegativePayment = new Payment__c(); 
            //AT-4415 Changes starts here
            Decimal amount = payObj.Amount__c;
            newNegativePayment.Amount__c = amount * -1; 
            //AT-4415 Changes Ends here
            newNegativePayment.BillingContract__c = payObj.BillingContract__c;
            newNegativePayment.PaymentDate__c = System.today();
            newNegativePayment.Account__c = payObj.Account__c;
            newNegativePayment.RecordTypeId = recordTypeId; 
            newNegativePayment.Transferred__c = System.Label.PyAp_ReturnPaymentTransferred;
            newNegativePayment.PaymentMethod__c =   paymentMethod ;   //AT-3189
            newPaymentToOldPaymentMap.put(payObj.Id,newNegativePayment);   
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