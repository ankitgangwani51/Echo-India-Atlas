public class GlUt_PaymentAllocationQueueUtilities {
    /**********************************************************************************************
    @author        Echo: AmitK.
    @date          07-Aug-2018
    @param         Id billItemId, String operation 
    @return        PaymentAllocationQueue__c
    @description   Create New Payment Allocation Queue record.
    **********************************************************************************************/ 
    public static PaymentAllocationQueue__c buildPaymentAllocationQueue(Id billItemId,string status, String operation) {
        PaymentAllocationQueue__c paymentAllocationQueue = new PaymentAllocationQueue__c();
        paymentAllocationQueue.BillItem__c = billItemId; 
        paymentAllocationQueue.Status__c = status;
        paymentAllocationQueue.Operation__c = operation; 
        return paymentAllocationQueue;
    } 
    /**********************************************************************************************
    @author        Echo: AmitK.
    @date          07-Aug-2018
    @param         Set<Id> billItemIds, String filterStatements,List<String> paymentAllocationQueueFields 
    @return        List<PaymentAllocationQueue__c> 
    @description   fetch Payment Allocation Queue record on the basis of Bill Items.
    **********************************************************************************************/ 
    public static List<PaymentAllocationQueue__c> getPaymentAllocationQueueFromBillItem(Set<Id> billItemIds, String filterStatements,List<String> paymentAllocationQueueFields) {
        string queryString = String.format('select {0} from {1}', new List<String>{String.join(paymentAllocationQueueFields, ', '),GlUt_APIConstantsPaymentAllocationQueue.PAYMENTALLOCATIONQUEUEAPINAME});
        queryString = queryString +' WHERE '+ GlUt_APIConstantsPaymentAllocationQueue.BILLITEMAPINAME +' IN: billItemIds';
        queryString = (string.isBlank(filterStatements)) ? queryString : queryString + ' ' + filterStatements;
        return Database.query(queryString);
    } 
    
}