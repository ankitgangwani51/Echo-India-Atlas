/***************************************************************************************************
@author        Echo : Dependra Singh
@date          31-Jan-2018
@description:  This class used to process Create payments and update original payments for refund and credit transfer. 
@group         Utility(Payment Object)

Revisions       10 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
				09- 10- 2018 Dependra Singh Changes during security review 	- AT-3940
*******************************************************************************************************/
public with sharing class PyAp_RefundTransferCreditUtility {
    
    private static final String CLASS_NAME = 'PyAp_RefundTransferCreditUtility';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static final Id PAYMENTRECORDTYPEONPAYMENT = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(PyAp_Constants.PAYMENT).getRecordTypeId();
    private static final Id REFUNDRECORDTYPEONPAYMENT = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(PyAp_Constants.REFUND).getRecordTypeId();
    private static final Id RETUTRNSRECORDTYPEONPAYMENT = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(PyAp_Constants.RETURNTRNASFER).getRecordTypeId();
    private static final Id PAYMENTRECORDTYPEOBLNCTRNS = Schema.SObjectType.BalanceTransaction__c.getRecordTypeInfosByName().get(PyAp_Constants.PAYMENT).getRecordTypeId();
    //09- 10- 2018 Dependra Singh Changes during security review 	- AT-3940
       
    /******************************************************************************
    @author         Echo: Dependra
    @date           31-Jan-2018
    @param          Payment__c objNewPayment(Payment object)
					BillingContract__c objContract(Contract Object)
    @description    This method is used to create refund payment record and handling two types of mode
                    (1)-Single Payment in Credit Scenario
                    (2)-Multiple Payment in Credit Scenario
    *******************************************************************************/
    public static void refundCredit(Payment__c objNewPayment, BillingContract__c objContract) {
        if (objContract.Id != null) {
            List<Payment__c> existingPaymentList = getExistingPaymnts(objContract.Id);
            system.debug('existingPaymentList======'+existingPaymentList);
             system.debug('objContract======'+objContract);
              system.debug('objNewPayment======'+objNewPayment);
            if (!existingPaymentList.isEmpty() && objNewPayment != null) {
                creditRefund(objNewPayment, existingPaymentList, objContract);
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Dependra
    @date           31-Jan-2018
    @param          Payment__c objNewPayment(Payment object)
					BillingContract__c objContract(Contract Object)
    @description    There method will be able to refund the credit on a Contract to a Customer, 
                    or to assign the credit to another Customer and/or Contract. 
    *******************************************************************************/    
    public static void transferCredit(Payment__c objNewPayment, BillingContract__c objContract) {
        if (objContract.Id != null && objContract.AccountName__c != null) {
            List<Payment__c> existingPaymentList = getExistingPaymnts(objContract.Id);
            if (!existingPaymentList.isEmpty() && objNewPayment != null) {
                creditTransfer(objNewPayment, existingPaymentList, objContract);
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Dependra
    @date           31-Jan-2018
    @param          Payment__c objNewPayment, 
                    List<Payment__c> existingPaymentList, 
                    BillingContract__c objContract
    @description    This methd is used to create new payment Refund record when "Single or Multiple Payment in Credit Scenario".
                    Also udating existing payment.
    *******************************************************************************/ 
    private static void creditRefund(Payment__c objNewPayment, List<Payment__c> existingPaymentList, BillingContract__c objContract) {
        
        Decimal creditAmountToRefund = objNewPayment.Amount__c;
        objNewPayment.Amount__c = creditAmountToRefund * -1 ;
        objNewPayment.BillingContract__c = objContract.Id;
        objNewPayment.RecordTypeId = REFUNDRECORDTYPEONPAYMENT;
        objNewPayment.Account__c = objContract.AccountName__c;
        objNewPayment.PaymentDate__c= system.today(); 
        Account objAccount = [Select RecordtypeId from Account Where Id =:objContract.AccountName__c];
        string accRecordTypeName = Schema.SObjectType.Account.getRecordTypeInfosById().get(objAccount.RecordtypeId).getname();
        
        if (string.isNotBlank(objNewPayment.NameofRefundAccount__c) 
            || string.isNotBlank(objNewPayment.BankAccountNumber__c)
            || string.isNotBlank(objNewPayment.BankAccountSortCode__c)
            || objNewPayment.BankAccountDetail__c != null ){
                objNewPayment.PaymentMethod__c =PyAp_Constants.DIRECTCREDIT;
                
            } else {
                objNewPayment.PaymentMethod__c =PyAp_Constants.CHEQUE;         
                GlUt_CorrespondenceHandler.CreateCorrespondence(PyAp_Constants.REMITTANCEADVICE, objContract.AccountName__c, objContract.Id, null,null,null, accRecordTypeName);
            }
        //Ammendment in existing payments
        // AU3 Changes- Dependra Singh
        existingPaymentList = AmendExistingPayments(existingPaymentList,creditAmountToRefund,PyAp_Constants.REFUND,false);
        objNewPayment = (Payment__c) GlUt_FieldSecurity.cleanseFields(objNewPayment, false);
        system.debug('objNewPayment======'+objNewPayment);
        insert objNewPayment;
        system.debug('objNewPayment1======'+objNewPayment);
        if(objNewPayment.Id != null){
            Payment__c objPayment = [SELECT Id , RefundStatus__c FROM Payment__c WHERE ID= : objNewPayment.Id LIMIT 1];
            if(objPayment.RefundStatus__c == PyAp_Constants.APPROVED_PAYMENT){
                existingPaymentList = (List<Payment__c>) GlUt_FieldSecurity.cleanseFields(existingPaymentList, false);
                update existingPaymentList;
                system.debug('existingPaymentList======'+existingPaymentList);
                // Payment Association between new payment Refund record and existing payment
            }
        }
        createPaymentAssosiation(objNewPayment, existingPaymentList);
    } 
    
    /******************************************************************************
    @author         Echo: Dependra
    @date           31-Jan-2018
    @param          Payment__c objNewPayment, 
                    List<Payment__c> existingPaymentList, 
                    BillingContract__c objContract
    @description    This method is used to create new payment record and Return transfer when "Single or Multiple Payment in Credit Transfer".
                    Also udating existing payment.
    *******************************************************************************/ 
    private static void creditTransfer(Payment__c objNewPayment, List<Payment__c> existingPaymentList, BillingContract__c objContract) {
        
        List<Payment__c> existingPaymentUpdateList = new List<Payment__c>();
        List<Payment__c> newpaymentList = new List<Payment__c>();
        
        Decimal creditAmountToTransfer = objNewPayment.Amount__c;
        Boolean doNotPrint = objNewPayment.DoNotPrint__c;  // AT-4898
        //New Payment records saving through  UI 
        objNewPayment.RecordTypeId = PAYMENTRECORDTYPEONPAYMENT;
        objNewPayment.PaymentDate__c = system.today();
        objNewPayment.PaymentMethod__c =PyAp_Constants.CASH;
        
        //Create Refund transfer payment.
        Payment__c objPaymentCreditTransfer= GlUt_PaymentUtilities.CreatePayment(RETUTRNSRECORDTYPEONPAYMENT,objContract.AccountName__c,objContract.Id,system.today(), 
                                                                                 creditAmountToTransfer*-1,'',false,doNotPrint,PyAp_Constants.YES);
        newpaymentList.add(objPaymentCreditTransfer);
        newpaymentList.add(objNewPayment);
        
        //Ammmendment in existing payments
        // AU3 Changes- Dependra Singh
        existingPaymentList = AmendExistingPayments(existingPaymentList,creditAmountToTransfer,PyAp_Constants.CREDITTRANSFER,doNotPrint);
        existingPaymentList = (List<Payment__c>) GlUt_FieldSecurity.cleanseFields(existingPaymentList, false);
        update existingPaymentList;
        
        if (!newpaymentList.isEmpty()) {
            newpaymentList =  (List<Payment__c>) GlUt_FieldSecurity.cleanseFields(newpaymentList, false);
            insert newpaymentList;
            //if (newpaymentList[1] != null) PaUt_ProcessPaymentAllocation.allocatePayment(new set<Id> {newpaymentList[1].Id}) ; // Sudhir: AT-2111
        }
        Map<Id, Schema.RecordTypeInfo> paymentRecordTypeMap = Payment__c.sObjectType.getDescribe().getRecordTypeInfosById();
        List<Payment__c> lstPaymentReturn = new List<Payment__c>(); 
        for (Payment__c objPaymentAss : newpaymentList) {
            if (paymentRecordTypeMap.get(objPaymentAss.recordTypeID).getName().containsIgnoreCase(PyAp_Constants.RETURNTRNASFER)) {
                
                // Payment Association between return transfer payment and existing payment
                lstPaymentReturn.add(objPaymentAss);
                createPaymentAssosiation(objPaymentAss,existingPaymentList);
                
            } else if (paymentRecordTypeMap.get(objPaymentAss.recordTypeID).getName().containsIgnoreCase(PyAp_Constants.PAYMENT)) {
                
                    // Payment Association between New payment(Record Type - Transfer) and another New payemnt (record Type- Payment)
                    createPaymentAssosiation(objPaymentAss,lstPaymentReturn);
            }
        }
    }     
    
    /******************************************************************************
    @author         Echo: Dependra
    @date           31-Jan-2018
    @param          Payment__c objNewPayment, 
					List<Payment__c> existingPaymentList
    @description    This method is used to create payment association record between old and new payments 
    when doing refund and credit transfer.
    *******************************************************************************/ 
    private static void createPaymentAssosiation(Payment__c objNewPayment, List<Payment__c> existingPaymentList) {
        
        List<PaymentAssociation__c> paymentAssocistionList = new List<PaymentAssociation__c>();
        for (Payment__c objPayment : existingPaymentList) {
            PaymentAssociation__c objPaymentAssociation = new PaymentAssociation__c();
            objPaymentAssociation.OriginalPayment__c = objPayment.id;
            objPaymentAssociation.TransferredRefundedPayment__c = objNewPayment.id;
            paymentAssocistionList.add(objPaymentAssociation);
        }
        if (!paymentAssocistionList.isEmpty()) {
            paymentAssocistionList =  (List<PaymentAssociation__c>) GlUt_FieldSecurity.cleanseFields(paymentAssocistionList, false);
            insert paymentAssocistionList;
        }
    }   
    
    /******************************************************************************
    @author         Echo: Dependra
    @date           31-Jan-2018
    @param          Id contractId
    @description    This method is used to get exsiting payments. 
                    To get existing payment flow which is in use. {Contract-> Balance-> Balance transaction -> Payment}
    @revision       MT 07-Mar-2018 Use the field from constant class
    *******************************************************************************/ 
    private static List<Payment__c> getExistingPaymnts(Id contractId) {
        
        List<BalanceTransaction__c> balanceTransactionList = new List<BalanceTransaction__c>();
        List<Payment__c> paymentsList = new List<Payment__c>();
        Id paymentBTRecordTypeId = PAYMENTRECORDTYPEOBLNCTRNS;
        Id paymentBTRecordTypeId2 = PAYMENTRECORDTYPEONPAYMENT;
        Set<Id> balanceIds = new Set<Id>();
        if(contractId != null){
            // Fetching contract by passing contract id to get the balances. 
            BillingContract__c contract = [SELECT Id, AccountName__c, Status__c, Balance__c FROM BillingContract__c WHERE Id =: contractId LIMIT 1];
            if (contract.Id != null) {
                balanceIds.add(contract.Balance__c);
            } 
        }
        // If balance id size is greater than 0 then fetching balance transaction where balances in set.
        if (balanceIds.size() > 0) {
            //Changed during security review.AT-3940
            balanceTransactionList =[SELECT Id, Amount__c,Balance__c, Payment__c,RecordTypeId FROM BalanceTransaction__c 
                                     WHERE Balance__c IN : balanceIds AND RecordTypeId =: paymentBTRecordTypeId];
           
        }
        // Looping over balance tra=nsaction to get payment ids.   
        Set<Id> paymentsIds = new Set<Id>();
        if (balanceTransactionList.size() > 0) {
            for (BalanceTransaction__c objBalanceTran : balanceTransactionList) {
                
                if(objBalanceTran.Payment__c != null) // AT-2290, Fixed it as a part of this defect as it was adding null to list
                    paymentsIds.add(objBalanceTran.Payment__c); 
            }
        }
        // if payment id size id greater than 0 then fetching payment list where credit amount is greater than 0 and ordering it by payment date.
        if (paymentsIds.size() > 0) {
            //Changed during security review.AT-3940
            paymentsList = [SELECT Id, CreditAmount__c, RecordTypeId,Amount__c, BillAllocationStatus__c,PaymentMethod__c, InstalmentAmountUnallocated__c, 
                            AmendmentReason__c, ReversedAmount__c, BillAmountUnallocated__c FROM Payment__c 
                            WHERE  ID IN: paymentsIds AND RecordTypeId=: paymentBTRecordTypeId2 AND CreditAmount__c > 0  ORDER BY PaymentDate__c];
        }
        return paymentsList;
    }
    /******************************************************************************
    @author         Echo: Dependra
    @date           05-Feb-2019
    @param          Id contractId,Balance__c objBalance
	@Description	Method is used to process credit write Off.
   					// AU3 Changes- Dependra Singh
    *******************************************************************************/ 
    public static void ProcessCreditWriteOff(Id contractId, Balance__c objBalance){
        Decimal creditWriteOffAmount = objBalance.Balance__c *-1;
        
        if(contractId != null){
            List<Payment__c> existingPaymentList = getExistingPaymnts(contractId);
            Payment__c objPayment = CreateCreditWriteOffPayment(contractId,objBalance);
            objPayment = (Payment__c)GlUt_FieldSecurity.cleanseFields(objPayment, false);
            insert objPayment;
            //Ammmendment in existing payments
            existingPaymentList = AmendExistingPayments(existingPaymentList,creditWriteOffAmount,PyAp_Constants.CREDITWRITEOFF,false);
            existingPaymentList = (List<Payment__c>) GlUt_FieldSecurity.cleanseFields(existingPaymentList, false);
            
            update existingPaymentList;
            // Payment Association between New payment and existing payment.
            createPaymentAssosiation(objPayment,existingPaymentList);
            
        }
    }
    /******************************************************************************
    @author         Echo: Dependra
    @date           05-Feb-2019
    @param          Id contractId,Balance__c objBalance
	@Description 	Method is used to create credit writeoff payment record.
	// AU3 Changes- Dependra Singh	
    *******************************************************************************/ 
    private  static Payment__c CreateCreditWriteOffPayment(Id contractId, Balance__c objBalance){
        Payment__c objPayment= GlUt_PaymentUtilities.CreatePayment(RETUTRNSRECORDTYPEONPAYMENT,objBalance.Account__c,contractId,system.today(), objBalance.Balance__c,
                                                                   PyAp_Constants.CASH,true,false,'');
        //Start: AT-5406
        objPayment.PaymentMethod__c 	= '' ;
        objPayment.CreditWriteOff__c 	= true ;
        //End: AT-5406
        return objPayment;
    }
    /******************************************************************************
    @author         Echo: Dependra
    @date           05-Feb-2019
    @param          Id contractId,Balance__c objBalance
	@Description 	Common method to update the existing payments		
	// AU3 Changes- Dependra Singh	
    *******************************************************************************/ 
    private static List<Payment__c> AmendExistingPayments(List<Payment__c> existingPaymentList, Decimal creditAmount, string strAmendmentReason, boolean isPrint){
        if(existingPaymentList != null && existingPaymentList.size() > 0){
            for (integer i = 0; i <= existingPaymentList.size() - 1; i++) {
                if (existingPaymentList[i].CreditAmount__c != null &&  existingPaymentList[i].CreditAmount__c > 0 && creditAmount > 0) {
                    
                    if (creditAmount >= existingPaymentList[i].CreditAmount__c) {
                        creditAmount = creditAmount - existingPaymentList[i].CreditAmount__c;
                        if(existingPaymentList[i].ReversedAmount__c != null) {
                            existingPaymentList[i].ReversedAmount__c += existingPaymentList[i].CreditAmount__c;
                        } else {
                            existingPaymentList[i].ReversedAmount__c = existingPaymentList[i].CreditAmount__c;
                        }
                        existingPaymentList[i].CreditAmount__c = 0.00; 
                        existingPaymentList[i].BillAmountUnallocated__c = 0.00; 
                        existingPaymentList[i].InstalmentAmountUnallocated__c = 0.00; 
                        existingPaymentList[i].BillAllocationStatus__c = PyAp_Constants.FULLYALLOCATED;          
                        existingPaymentList[i].InstalmentAllocationStatus__c = PyAp_Constants.FULLYALLOCATED;    
                        existingPaymentList[i].AmendmentReason__c = strAmendmentReason;
                        //existingPaymentList[i].PaymentMethod__c = PyAp_Constants.CASH;
                        
                    } else {
						system.debug('existingPaymentList[i].CreditAmount__c==='+existingPaymentList[i].CreditAmount__c);
						system.debug('creditAmount==='+creditAmount);
                        existingPaymentList[i].CreditAmount__c = existingPaymentList[i].CreditAmount__c - creditAmount;
                        if (existingPaymentList[i].ReversedAmount__c != null) {
                            existingPaymentList[i].ReversedAmount__c = existingPaymentList[i].ReversedAmount__c + creditAmount;
                        } else {
                            existingPaymentList[i].ReversedAmount__c = creditAmount;
                        }
                        if (existingPaymentList[i].BillAmountUnallocated__c != null) {
                            existingPaymentList[i].BillAmountUnallocated__c = existingPaymentList[i].BillAmountUnallocated__c - creditAmount;
                        } else {
                            existingPaymentList[i].BillAmountUnallocated__c = creditAmount;
                        }
                        
                        if (existingPaymentList[i].InstalmentAmountUnallocated__c != null) {
                            existingPaymentList[i].InstalmentAmountUnallocated__c =existingPaymentList[i].InstalmentAmountUnallocated__c - creditAmount;
                        } else {
                            existingPaymentList[i].InstalmentAmountUnallocated__c = creditAmount;
                        }
                        
                        existingPaymentList[i].BillAllocationStatus__c  = PyAp_Constants.PARTIALLYALLOCATED;
                        existingPaymentList[i].InstalmentAllocationStatus__c  = PyAp_Constants.PARTIALLYALLOCATED;
                        existingPaymentList[i].AmendmentReason__c =strAmendmentReason;
                        //existingPaymentList[i].PaymentMethod__c = PyAp_Constants.CASH;
                        creditAmount= 0.00; 
                    }                
                    existingPaymentList[i].DoNotPrint__c = isPrint;           
                }
            }
        }
        return existingPaymentList;
    }
}