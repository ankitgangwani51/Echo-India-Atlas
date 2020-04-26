/******************************************************************************
@author         Echo: Tarun Gupta
@date           27 June 2018
@description:   Refund Transfer utility class works in Batch mode(Bulkify)
@group          Utility
@Revisions -    24/07/18, Tarun, AT-3121 , Made changes to make the amount as negative while creating the refund record.
                AT-4891/2 Code Check Marx Changes for FLS INSERT/UPDATE
*******************************************************************************/
public class GlBt_RefundTransferCreditUtility {
    
    private static final String CLASS_NAME = 'GlBt_RefundTransferCreditUtility';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static final Id PAYMENTRECORDTYPEONPAYMENT = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(PyAp_Constants.PAYMENT).getRecordTypeId();
    private static final Id REFUNDRECORDTYPEONPAYMENT = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(PyAp_Constants.REFUND).getRecordTypeId();
    
    // List of payment field string.
    private static final List<String> paymentListFields = new List<String> {
            GlUt_APIConstantsPayments.PAYMENTDATEAPINAME,
            GlUt_APIConstantsPayments.CREDITAMOUNTAPINAME,
            GlUt_APIConstantsPayments.RECORDTYPEAPINAME,
            GlUt_APIConstantsPayments.AMOUNTAPINAME,
            GlUt_APIConstantsPayments.BILLALLOCATIONSTATUSAPINAME,
            GlUt_APIConstantsPayments.PAYMENTMETHODAPINAME,
            GlUt_APIConstantsPayments.INSTALAMTUNALLOCATEDAPINAME,
            GlUt_APIConstantsPayments.AMENDMENTREASONAPINAME,
            GlUt_APIConstantsPayments.BILLAMTUNALLOCATEDAPINAME,
            GlUt_APIConstantsPayments.REVERSEDAMOUNTAPINAME,
            GlUt_APIConstantsPayments.CONTRACTAPINAME
            };
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           27-June-2018
    @param          Set<Id>
    @description    This method is used to get exsiting payments. 
                    To get existing payment flow which is in use. {Payment -> Contract}
    *******************************************************************************/ 
    public static List<Payment__c> getExistingPaymnts(Set<Id> setContractIds) {
        
        
        List<Payment__c> paymentsList = new List<Payment__c>();
        Id paymentBTRecordTypeId = PAYMENTRECORDTYPEONPAYMENT;                               
        
        // if payment id size id greater than 0 then fetching payment list where credit amount is greater than 0 and ordering it by payment date.
        if (setContractIds.size() > 0) {
            paymentsList = (List<Payment__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPayments.PAYMENTAPINAME, 
                                                                                    paymentListFields, 
                                                                                    paymentBTRecordTypeId, 
                                                                                    'RecordTypeId', 
                                                                                  String.format('  {0} IN {1} AND {2} > 0 ORDER BY {3}', 
                                                                                    //String.format(' Id IN {0} AND {1} > 0 ORDER BY {2}', 
                                                                                        new List<String>{
                                                                                            GlUt_APIConstantsPayments.CONTRACTAPINAME, 
                                                                                            GlUt_FieldSecurity.IdsToString(setContractIds), 
                                                                                            GlUt_APIConstantsPayments.CREDITAMOUNTAPINAME, 
                                                                                            GlUt_APIConstantsPayments.PAYMENTDATEAPINAME}));
        }
        system.debug(DEBUG + 'paymentsList: ' + paymentsList);
        return paymentsList;
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           27-June-2018
    @param          Set<Id>
    @description    This method is used to get exsiting payments. 
                    To get existing payment flow which is in use. {Payment -> Contract}
    @Revisions -    24/07/18, Tarun, AT-3121 , Made changes to make the amount as negative while creating the refund record.
    *******************************************************************************/
    
    public static void creditRefund(List<Payment__c> listNewPayment, List<Payment__c> existingPaymentList) {       
        
        
        Map<Id,Decimal> mapContractId2PaymentAmount = new Map<Id,Decimal>();
        List<Payment__c> listNewPaymentToInsert = new List<Payment__c>(); //AT-3121
        
        for(Payment__c objNewPay : listNewPayment){
            
            if(!mapContractId2PaymentAmount.containskey(objNewPay.BillingContract__c)){
                mapContractId2PaymentAmount.put(objNewPay.BillingContract__c,objNewPay.Amount__c);
            }
            
            //AT-3121 - Starts Here
            Payment__c objNewPaymentWithNegativeAmt = new Payment__c();
            objNewPaymentWithNegativeAmt = objNewPay;
            objNewPaymentWithNegativeAmt.Amount__c = objNewPay.Amount__c * -1;
            
            listNewPaymentToInsert.add(objNewPaymentWithNegativeAmt);
            
            //AT-3121 - Ends Here
        }
        
        system.debug('mapContractId2PaymentAmount---'+ mapContractId2PaymentAmount);
        
        //Ammendment in existing payments
        if(!existingPaymentList.isEmpty()){
            
            for (integer i = 0; i <= existingPaymentList.size() - 1; i++) {
                
                Decimal creditAmountToRefund = 0.0;
                
                if(mapContractId2PaymentAmount.containskey(existingPaymentList[i].BillingContract__c)){
                    creditAmountToRefund = mapContractId2PaymentAmount.get(existingPaymentList[i].BillingContract__c);
                }
                
                system.debug('creditAmountToRefund---'+ creditAmountToRefund);
                
                if (existingPaymentList[i].CreditAmount__c != null && existingPaymentList[i].CreditAmount__c > 0 && creditAmountToRefund > 0) {
                    if (creditAmountToRefund >= existingPaymentList[i].CreditAmount__c) {
                        creditAmountToRefund = creditAmountToRefund - existingPaymentList[i].CreditAmount__c;
                        existingPaymentList[i].ReversedAmount__c = existingPaymentList[i].CreditAmount__c;
                        existingPaymentList[i].CreditAmount__c = 0.00;
                        existingPaymentList[i].BillAmountUnallocated__c = 0.00;
                        existingPaymentList[i].InstalmentAmountUnallocated__c = 0.00;
                        existingPaymentList[i].BillAllocationStatus__c = PyAp_Constants.FULLYALLOCATED; 
                        existingPaymentList[i].InstalmentAllocationStatus__c = PyAp_Constants.FULLYALLOCATED;
                        existingPaymentList[i].AmendmentReason__c = PyAp_Constants.REFUND;
                        
                    } else {
                        existingPaymentList[i].CreditAmount__c = existingPaymentList[i].CreditAmount__c - creditAmountToRefund;
                        if (existingPaymentList[i].ReversedAmount__c != null) {
                            existingPaymentList[i].ReversedAmount__c = existingPaymentList[i].ReversedAmount__c + creditAmountToRefund;
                        } else {
                            existingPaymentList[i].ReversedAmount__c = creditAmountToRefund;
                        }
                        if (existingPaymentList[i].BillAmountUnallocated__c != null ) {
                            existingPaymentList[i].BillAmountUnallocated__c = existingPaymentList[i].BillAmountUnallocated__c - creditAmountToRefund;
                        } else {
                            existingPaymentList[i].BillAmountUnallocated__c = creditAmountToRefund;
                        }
                        if (existingPaymentList[i].InstalmentAmountUnallocated__c != null ) {
                            existingPaymentList[i].InstalmentAmountUnallocated__c = existingPaymentList[i].InstalmentAmountUnallocated__c - creditAmountToRefund;
                        } else {
                            existingPaymentList[i].InstalmentAmountUnallocated__c = creditAmountToRefund;
                        }
                        existingPaymentList[i].BillAllocationStatus__c = PyAp_Constants.PARTIALLYALLOCATED;
                        existingPaymentList[i].InstalmentAllocationStatus__c = PyAp_Constants.PARTIALLYALLOCATED;
                        existingPaymentList[i].AmendmentReason__c = PyAp_Constants.REFUND;
                        creditAmountToRefund = 0.00;
                    }
                }
            } 
        }
        
        system.debug(DEBUG + 'existingPaymentList: ' + existingPaymentList);
        
        
        if(!listNewPaymentToInsert.isEmpty()) {
            listNewPaymentToInsert = (List<Payment__c>) GlUt_FieldSecurity.cleanseFields(listNewPaymentToInsert, false); //AT-4891 Code Check Marx Changes Starts/Ends Here.
            insert listNewPaymentToInsert; //AT-3121
        }
        if(!existingPaymentList.isEmpty()) {
            existingPaymentList = (List<Payment__c>) GlUt_FieldSecurity.cleanseFields(existingPaymentList, false); //AT-4892 Code Check Marx Changes Starts/Ends Here.
            update existingPaymentList;
        }
        
        // Payment Association between new payment Refund record and existing payment
        createPaymentAssosiation(listNewPaymentToInsert, existingPaymentList);
    } 
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           27-June-2018
    @param          Payment__c, List<Payment__c> 
    @description    This method is used to create payment association record between old and new payments 
    when doing refund and credit transfer.
    *******************************************************************************/ 
    public  static void createPaymentAssosiation(List<Payment__c> listNewPayment, List<Payment__c> existingPaymentList) {
        
        List<PaymentAssociation__c> paymentAssocistionList = new List<PaymentAssociation__c>();
        
        Map<Id,Payment__c> mapContractId2Payment = new Map<Id,Payment__c>();
        
        for (Payment__c objPaymentNew : listNewPayment) {
            if(!mapContractId2Payment.containsKey(objPaymentNew.BillingContract__c)){
                mapContractId2Payment.put(objPaymentNew.BillingContract__c, objPaymentNew);
            }
        }
        
        
        for (Payment__c objPayment : existingPaymentList) {
            PaymentAssociation__c objPaymentAssociation = new PaymentAssociation__c();
            objPaymentAssociation.OriginalPayment__c = objPayment.id;
            //objPaymentAssociation.TransferredRefundedPayment__c = objNewPayment.id;
            objPaymentAssociation.TransferredRefundedPayment__c = mapContractId2Payment.get(objPayment.BillingContract__c).Id;
            paymentAssocistionList.add(objPaymentAssociation);
        }
        
        system.debug('paymentAssocistionList---'+ paymentAssocistionList);
        if (!paymentAssocistionList.isEmpty()) {
            paymentAssocistionList = (List<PaymentAssociation__c>) GlUt_FieldSecurity.cleanseFields(paymentAssocistionList, false); //AT-4891 Code Check Marx Changes Starts/Ends Here.
            insert paymentAssocistionList;
        }
    }

}