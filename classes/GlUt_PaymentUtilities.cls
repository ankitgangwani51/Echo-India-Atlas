/******************************************************************************
@author    		Echo: Tarun Gupta
@date      		23 Feb 2018
@description 	Class for Payment utilities
*******************************************************************************/
public with sharing class GlUt_PaymentUtilities {
    
    private static final String CLASS_NAME = 'GlUt_PaymentUtilities';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
	@author    		Echo: Tarun Gupta
	@date      		23 Feb 2018
	@param			Map<Id, SObject> - objectMap
	@description 	Locate all payments against the same contract as new payment plan where record type = Payment and Amount Unallocated to Instalment > 0
					For each of these payments mark Amount Unallocated to Installment = 0 and Instalment Allocation Status = "fully allocated"
	*******************************************************************************/
	public void updatePaymentUnAllocAmount(Map<Id, SObject> objectMap) {
        
        List<Id> contractIds = new List<Id>();
        
        // build a list of the related contract Ids
        for (PaymentPlan__c paymentPlan : (List<PaymentPlan__c>)objectMap.values()) {
            contractIds.add(paymentPlan.BillingContract__c); //AT-3174
        }
        
        Id paymentRecordId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
        
        List<Payment__c> updatedPaymentList = new List<Payment__c>();
        
        List<Payment__c> lstPayments = [SELECT Id,
                                       		   Name,
                                       		   InstalmentAllocationStatus__c,
                                       		   InstalmentAmountUnallocated__c
                                        FROM Payment__c
                                        WHERE BillingContract__c in :contractIds
                                       	AND InstalmentAmountUnallocated__c > 0
                                        AND RecordTypeId =: paymentRecordId ];
        
        for(Payment__c objPayment : lstPayments){
            objPayment.InstalmentAmountUnallocated__c = 0;
            objPayment.InstalmentAllocationStatus__c = PyAp_Constants.FULLYALLOCATED;
            
            updatedPaymentList.add(objPayment);
        }
        if(!updatedPaymentList.isEmpty()) {
            updatedPaymentList = (List<Payment__c>) GlUt_FieldSecurity.cleanseFields(updatedPaymentList, false);
            update updatedPaymentList;
        }
    }
    /******************************************************************************
	@author    		Echo: Dependra Singh
	@date      		06 Feb 2019
	@param			Id recordTypeId, Id accountId, Id contractId, Date paymentDate,decimal amount,
                                    string paymentMethod, boolean isCreditWriteOff, 
                                    boolean isDoNotPrint, string strTransferred 
    @return			Payment__c
	@description 	Method is used to create payment based on certain parameter.
	*******************************************************************************/
   	
    public static Payment__c CreatePayment(Id recordTypeId, Id accountId, Id contractId, Date paymentDate,decimal amount,string paymentMethod, boolean isCreditWriteOff, 
                                           boolean isDoNotPrint, string strTransferred  ) {
           Payment__c objPayment = new Payment__c();
           objPayment.RecordTypeId = recordTypeId;
           objPayment.Account__c= accountId;
           objPayment.BillingContract__c = contractId;
           if(string.isNotBlank(strTransferred)){
               objPayment.Transferred__c= strTransferred;
           }
           objPayment.PaymentDate__c = paymentDate;
           objPayment.Amount__c = amount;
           objPayment.DoNotPrint__c = isDoNotPrint; 
           objPayment.CreditWriteOff__c = isCreditWriteOff;
           objPayment.PaymentMethod__c =paymentMethod;
           return objPayment;
       }
}