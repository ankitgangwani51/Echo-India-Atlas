/******************************************************************************
@author         Accenture: Pratyush Kumar (Accenture)
@date           16 Jan 2018
@description    Handler for Payment trigger
@revisions:     2 July 2018: Echo: Sudhir Kumar -> AT-2873(Core 7a)
*******************************************************************************/
public with sharing class GlUt_PaymentHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_PaymentHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static Map<Id, Id> paymentRecordTypeToBalanceRecordTypeMap;
    private static Map<Id, String> paymentRecordTypeMap; 
    private static Map<Id, String> balanceRecordTypeMap;
    private static String GoodwillPaymentRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(PyAp_Constants.GOODWILL_PAYMENT_RECORD_TYPE).getRecordTypeId() ; //AT-2873(Core 7a)
    private static String PaymentRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(PyAp_Constants.PAYMENT).getRecordTypeId() ;  //AT-2873(Core 7a)
    private static String RefundRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(PyAp_Constants.REFUND).getRecordTypeId() ;  
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    @revision       MT - 16/05/2018 Added associatePaymentToAccount method in the before 
                    insert logic
    *******************************************************************************/
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {
        try {
            if (inputParam.isInsert && inputParam.isBefore) {
                //calling associatePaymentToAccount method
                //Added some before insert assignment & validation rules -> AT-2873(Core 7a)
                associatePaymentToAccount((List<Payment__c>) inputParam.newlist);
                if(GlUt_RegionUtility.getAURegionCustomSetting()){
                    setInstalmentAmountBasedOnPaymentMethod((List<Payment__c>) inputParam.newlist, null);
                }
            }
            if (inputParam.isInsert && inputParam.isAfter) {
                // creates Payment Allocation records when Payments are created   
                createPaymentAllocations((List<Payment__c>) inputParam.newlist);
                createBalanceTransactions((List<Payment__c>) inputParam.newlist);
                CallFinancialControlDispatcher(inputParam);  // --- Swati; 26 Mar 2018
            }
            if (inputParam.isUpdate && inputParam.isBefore) {       // AT-2873 (Core 7a)
                paymentValidation((List<Payment__c>) inputParam.newlist, (Map<Id, Payment__c>) inputParam.oldmap) ;
                validateSuspensePayment((List<Payment__c>) inputParam.newlist, (Map<Id, Payment__c>) inputParam.oldmap, inputParam) ;
                if(GlUt_RegionUtility.getAURegionCustomSetting()){
                    setInstalmentAmountBasedOnPaymentMethod((List<Payment__c>)inputParam.newlist,(Map<Id, Payment__c>) inputParam.oldmap);
                }
            }
            if (inputParam.isUpdate && inputParam.isAfter) {
                // updates Payment Allocation records when Payments are updated
                createApprovedGoodwillPayment((List<Payment__c>) inputParam.newlist, (Map<Id, Payment__c>) inputParam.oldmap) ;    // AT-2873 (Core 7a)
                updatePaymentAllocations((List<Payment__c>) inputParam.newlist, (Map<Id, Payment__c>) inputParam.oldmap);
                CallFinancialControlDispatcher(inputParam);  // --- Swati; 26 Mar 2018
                validateSuspensePayment((List<Payment__c>) inputParam.newlist, (Map<Id, Payment__c>) inputParam.oldmap, inputParam) ;
                createBalanceTransactionOnRefundApproved((List<Payment__c>) inputParam.newlist, (Map<Id, Payment__c>) inputParam.oldmap) ;
            }            
            if (inputParam.isDelete && inputParam.isBefore) {
            }
            
            if (inputParam.isDelete && inputParam.isAfter) {
            }
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }

        finally {
            
            // Reset the active function to null in case this class was first in stack
            // this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           14 Jan 2018
    @param          List<Payment__c> paymentList, 
					Map<Id, Payment__c> oldMap
    @description    If the Payment Method on the Payment is not equal to the Billing Contract->Payment Method Type->Name; 
					set the Instalment Amount Unallocated to 0.
    *******************************************************************************/ 
    private void setInstalmentAmountBasedOnPaymentMethod(List<Payment__c> paymentList, Map<Id, Payment__c> oldMap) {
        set<Id> setContractIds = new set<Id>();
        Map<Id, String> mapPaymentMethodNameByContractId = new Map<Id, String>();
        list<Payment__c> listApprovedPayment = new list<Payment__c>() ;
        List<BillingContract__c> lstBiilingContract ;
        Map<Id, Payment__c> mapApprovedRefundByContractId  = new Map<Id, Payment__c>();
        Map<Id,List<Payment__c>> mapContractIdToListExistingPayment = new Map<Id,List<Payment__c>>();
        for(Payment__c payment : paymentList) {
            if(payment.BillingContract__c != null && payment.RecordTypeId == PaymentRecordTypeId ) {
                setContractIds.add(payment.BillingContract__c);
            }
        }
        if(setContractIds.size() > 0){
            lstBiilingContract = [Select Id,PaymentMethodType__r.Name FROM BillingContract__c WHERE ID IN :  setContractIds];
        }	
        if(lstBiilingContract != null && !lstBiilingContract.isEmpty()){
            for(BillingContract__c objContract : lstBiilingContract){
                if(!mapPaymentMethodNameByContractId.containsKey(objContract.Id)){
                    mapPaymentMethodNameByContractId.put(objContract.Id, objContract.PaymentMethodType__r.Name);
                }
            }
        }
        for(Payment__c payment : paymentList) {
            if(payment.BillingContract__c != null  && payment.RecordTypeId == PaymentRecordTypeId){
                if(mapPaymentMethodNameByContractId.containsKey(payment.BillingContract__c)){
                    if(payment.PaymentMethod__c != mapPaymentMethodNameByContractId.get(payment.BillingContract__c)){
                        payment.InstalmentAmountUnallocated__c = 0 ;
                    }
                }
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           20 Dec 2018
    @param          List<Payment__c> paymentList, 
					Map<Id, Payment__c> oldMap
    @description    We are creating balance transaction records on creating of refund records gets approved.
    *******************************************************************************/
    private void createBalanceTransactionOnRefundApproved(List<Payment__c> paymentList, Map<Id, Payment__c> oldMap) {
        set<Id> setContractIds = new set<Id>();
        list<Payment__c> listApprovedPayment = new list<Payment__c>() ;
        Map<Id, Payment__c> mapApprovedRefundByContractId  = new Map<Id, Payment__c>();
        Map<Id,List<Payment__c>> mapContractIdToListExistingPayment = new Map<Id,List<Payment__c>>();
        if(oldMap != null){
            for(Payment__c payment : paymentList) {
                Payment__c objOldPayment = oldMap.get(payment.Id);
                if(payment.BillingContract__c != null && payment.RecordTypeId == RefundRecordTypeId && 
                   payment.RefundStatus__c == PyAp_Constants.APPROVED_PAYMENT  && objOldPayment.RefundStatus__c ==PyAp_Constants.REQUESTED_REFUND_STATUS ) {
                       listApprovedPayment.add(payment) ;
                       setContractIds.add(payment.BillingContract__c);
                       if(!mapApprovedRefundByContractId.containsKey(payment.BillingContract__c)){
                           mapApprovedRefundByContractId.put(payment.BillingContract__c, payment);
                       }
                   }
            }
            if(setContractIds.size()  > 0){
                List<Payment__c> listExistingPayment =  GlBt_RefundTransferCreditUtility.getExistingPaymnts(setContractIds);
                if(listExistingPayment != null && !listExistingPayment.isEmpty()){
                    for(Payment__c objExistingPayment : listExistingPayment){
                        if(!mapContractIdToListExistingPayment.containsKey(objExistingPayment.BillingContract__c))  {
                            mapContractIdToListExistingPayment.put(objExistingPayment.BillingContract__c, new List<Payment__c>());
                        } 
                        mapContractIdToListExistingPayment.get(objExistingPayment.BillingContract__c).add(objExistingPayment);
                    }
                } 
            }
            if(mapContractIdToListExistingPayment.keyset().size() > 0 && mapApprovedRefundByContractId.keySet().size() > 0){
                updateExistingPaymentOnRefundApproved(mapApprovedRefundByContractId,mapContractIdToListExistingPayment);
            }
            
            if(Trigger.isAfter && Trigger.isUpdate && !listApprovedPayment.isEmpty()) {
                createBalanceTransactions(listApprovedPayment);
            }
        }
    }
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           20 Dec 2018
    @param          Map<Id, Payment__c> mapApprovedRefundByContractId, 
					Map<Id,List<Payment__c>> mapContractIdToListExistingPayment
    @description    Method is used to update the existing payments records when payment get approved with Refund recordtype.
					Basically it is used to update (Amount Unallocated to Bill , mount Unallocated to Instalment,Credit Amount, Reversed Amount)
					
    *******************************************************************************/
    private void updateExistingPaymentOnRefundApproved(Map<Id, Payment__c> mapApprovedRefundByContractId, Map<Id,List<Payment__c>> mapContractIdToListExistingPayment){
        List<Payment__c> lstExisitingPaymentToUpdate = new List<Payment__c>();
        for(Id objContractId : mapContractIdToListExistingPayment.keySet()){
            decimal creditAmount=0.0;
            if(mapApprovedRefundByContractId.containsKey(objContractId)){
                creditAmount = mapApprovedRefundByContractId.get(objContractId).Amount__c*-1;
            }
            if(mapContractIdToListExistingPayment.containsKey(objContractId)){
                list<Payment__c> existingPaymentList = mapContractIdToListExistingPayment.get(objContractId);            
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
                            existingPaymentList[i].AmendmentReason__c = PyAp_Constants.REFUND;
                        } else {
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
                            existingPaymentList[i].AmendmentReason__c =PyAp_Constants.REFUND;
                            creditAmount= 0.00; 
                        }
                    }
                    lstExisitingPaymentToUpdate.add(existingPaymentList[i]);
                }
            }
        }
        if(!lstExisitingPaymentToUpdate.isEmpty()){
            lstExisitingPaymentToUpdate = (List<Payment__c>) GlUt_FieldSecurity.cleanseFields(lstExisitingPaymentToUpdate, false);
            update lstExisitingPaymentToUpdate;
        }
    }
    
    //Suspense payment - Check
    private void validateSuspensePayment(List<Payment__c> listUpdatePayment, Map<Id, Payment__c> mapUpdateOldPayment, GlUt_TriggerHandlerObj inputParam) {
        list<Payment__c> listSuspendedPayment = new list<Payment__c>() ;
        for(Payment__c payment : listUpdatePayment) {
            if(mapUpdateOldPayment.get(payment.Id).BillingContract__c == null && payment.BillingContract__c != null) {
                listSuspendedPayment.add(payment) ;
            }
        }
        if(Trigger.isBefore && Trigger.isUpdate && !listSuspendedPayment.isEmpty()) {
            associatePaymentToAccount(listSuspendedPayment) ;
        }
        if(Trigger.isAfter && Trigger.isUpdate && !listSuspendedPayment.isEmpty()) {
            createPaymentAllocations(listSuspendedPayment);
            createBalanceTransactions(listSuspendedPayment);
            CallFinancialControlDispatcher(inputParam); 
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar 
    @date           4 July 2018
    @param          List<Payment__c> listBeforeUpdatePayment, Map<Id, Payment__c> mapBeforeUpdateOldPayment
    @description    AT-2873(Core 7a): 
                    1. If the Payment has a Billing Contract associated but not an Account, set the Account on Payment equal to the Account associated with the Contract.
                    2. If Old Contract Id is not Null it is not permitted to change the Contract
    @return         void
    ******************************************************************************/
    
    private void paymentValidation(List<Payment__c> listBeforeUpdatePayment, Map<Id, Payment__c> mapBeforeUpdateOldPayment) {
        set<Id> setContractId = new set<Id>() ;     
        map<Id, Id> mapContractId2AccountId = new map<Id, Id>() ;   
        for(Payment__c payment : listBeforeUpdatePayment) { 
            if(payment.BillingContract__c != null) setContractId.add(payment.BillingContract__c) ;
        }
        for(BillingContract__c contract : [SELECT Id, AccountName__c FROM BillingContract__c WHERE Id IN: setContractId]) {
            if(contract.AccountName__c != Null)
                mapContractId2AccountId.put(contract.Id, contract.AccountName__c) ;
        }
        
        for(Payment__c paymentObj : listBeforeUpdatePayment) {
            if(paymentObj.BillingContract__c != null && paymentObj.Account__c == null && !mapContractId2AccountId.isEmpty() && mapContractId2AccountId.containsKey(paymentObj.BillingContract__c)) {
                paymentObj.Account__c = mapContractId2AccountId.get(paymentObj.BillingContract__c) ;    
            }
            if(mapBeforeUpdateOldPayment.get(paymentObj.Id).BillingContract__c != null && paymentObj.BillingContract__c != null 
                                                                             && paymentObj.BillingContract__c != mapBeforeUpdateOldPayment.get(paymentObj.Id).BillingContract__c) {
                paymentObj.BillingContract__c.addError(System.Label.PyAp_PaymentContractChangeValidation) ;
            }
        }
    }
        
        
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           17 Jan 2018
    @param          List<Payment__c> paymentList
    @description    Invoked when payments are created: Payment Allocation records are created 
                    and Balance Transaction record is inserted
    @return         void
    *******************************************************************************/
    public void createPaymentAllocations(List<Payment__c> paymentList) {        // Sudhir: method from private --> public
        Set<Id> paymentIdSet = (new Map<Id, Payment__c>(paymentList)).keySet();
        PaUt_ProcessPaymentAllocation.mode = PaUt_ProcessPaymentAllocation.ALLMODE;
        List<PaymentAllocation__c> paymentAllocations = PaUt_ProcessPaymentAllocation.allocatePayment(paymentIdSet);
        
        //The trigger will also create an entry (Balance Transaction record) for the Balance Transaction object linked to the Payment. 
        //createBalanceTransactions(paymentList, paymentAllocations); 
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           17 Jan 2018
    @param          List<Payment__c> paymentList
    @description    Invoked when payments are created for payments, refunds or returns 
                    Creates Balance Transaction records
    @return         void
    *******************************************************************************/
    public void createBalanceTransactions(List<Payment__c> paymentList) {       // Sudhir: method from private --> public
        Set<Id> contractIdSet = new Set<Id>();
        
        paymentRecordTypeToBalanceRecordTypeMap = getPaymentRecordTypeToBalanceRecordTypeMap();
        //Map<Id, Payment__c> paymentsWithContractMap = new Map<Id, Payment__c>();
        
        for(Payment__c payment : paymentList) {
            if(payment.RecordTypeId != null && payment.BillingContract__c != null) {// && paymentRecordTypeMap.containsKey(payment.RecordTypeId)
                //&& (paymentRecordTypeMap.get(payment.RecordTypeId) == GlUt_Constants.PAYMENT_RECORDTYPE_REFUND || paymentRecordTypeMap.get(payment.RecordTypeId) == GlUt_Constants.BALANCE_RECORDTYPE_RETURNTRANSFER)) {
            
                    contractIdSet.add(payment.BillingContract__c);
                    //paymentsWithContractMap.put(payment.Id, payment);
            }
        }
        
        Map<Id, Payment__c> paymentsMap = new Map<Id, Payment__c> (paymentList);
        Map<Id, Id> paymentIdToBalanceIdMap = getPaymentIdToBalanceMap(paymentsMap, contractIdSet);
        
        if(paymentIdToBalanceIdMap.keySet().isEmpty()) {
            return;
        }
        
        // It will create an entry for the Balance Transaction object for the Balance associated to the Payment
        List<BalanceTransaction__c> balanceTransactionList = buildBalanceTransactions(paymentIdToBalanceIdMap, paymentsMap);
        if(!balanceTransactionList.isEmpty()) {
            balanceTransactionList= (List<BalanceTransaction__c>) GlUt_FieldSecurity.cleanseFields(balanceTransactionList, false);
            insert balanceTransactionList;
        } 
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           13 Feb 2018
    @description    builds and returns a map of Payment Id to Balance Id so that this
                    can be used when building Balance Transactions
    @return         Map<Id, Id>
    *******************************************************************************/
    
    private Map<Id, Id> getPaymentIdToBalanceMap(Map<Id, Payment__c> paymentsMap, Set<Id> contractIdSet) {
        Map<Id, Id> paymentIdToBalanceIdMap = new Map<Id, Id>();
        
        Map<Id, BillingContract__c> contractIdWithBalance = getContractsMap(contractIdSet);
                
        for(Payment__c payment : paymentsMap.values()) {    
            if(payment.BillingContract__c != null && contractIdWithBalance.containsKey(payment.BillingContract__c) // AT-2873 Notes: Null check on contract already exists
               && contractIdWithBalance.get(payment.BillingContract__c).Balance__c != null
               && (paymentIdToBalanceIdMap.keySet() == null || paymentIdToBalanceIdMap.keySet().isEmpty() 
                   || !paymentIdToBalanceIdMap.containsKey(payment.Id))) {
                       
                       if(payment.RecordTypeId == RefundRecordTypeId){
                           if(payment.RefundStatus__c != PyAp_Constants.REQUESTED_REFUND_STATUS){
                               paymentIdToBalanceIdMap.put(payment.Id, contractIdWithBalance.get(payment.BillingContract__c).Balance__c);
                           }
                       }else{
                           paymentIdToBalanceIdMap.put(payment.Id, contractIdWithBalance.get(payment.BillingContract__c).Balance__c); 
                       }  
                   }
        }
        return paymentIdToBalanceIdMap;
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar 
    @date           3 July 2018
    @param          List<Payment__c> listPayment, Map<Id, Payment__c> mapOldPayment
    @description    AT-2873(Core 7a): For Goodwill Payments where the Goodwill type is ‘Payment’, the approval of the Refund will set the Refund Status to ‘Approved’ and 
                    this should trigger the creation of the second Payment record. 
                    So here, such second payments only should take part in the current payment allocation logic.
    @return         void
    ******************************************************************************/

    private void createApprovedGoodwillPayment(List<Payment__c> listPayment, Map<Id, Payment__c> mapOldPayment) {
        map<Id, Payment__c> mapApprovedGoodwillPayment = new map<Id, Payment__c>() ;
        try {
            for(Payment__c payment : listPayment) {
                if(payment.RecordTypeId == GoodwillPaymentRecordTypeId && 
                                                                       payment.GoodwillType__c == PyAp_Constants.PAYMENT
                                                                       &&
                                                                       payment.RefundStatus__c == PyAp_Constants.APPROVED_PAYMENT
                                                                       && payment.RefundStatus__c != mapOldPayment.get(payment.Id).RefundStatus__c) {
                    mapApprovedGoodwillPayment.put(payment.Id, payment) ;
                }
            }
            
            if(!mapApprovedGoodwillPayment.isEmpty()) {
                list<Payment__c> listNewApprovedGoodwillPayment = new list<Payment__c>() ;
                for(Id paymentId : mapApprovedGoodwillPayment.keySet()) {
                    Payment__c originalGoodwillPayment = mapApprovedGoodwillPayment.get(paymentId) ;
                        Payment__c payment = new Payment__c() ;
                        //payment.CreditAmount__c = -originalGoodwillPayment.Amount__c ;
                        payment.Amount__c = -originalGoodwillPayment.Amount__c ;
                        payment.RecordTypeId = PaymentRecordTypeId ;
                        payment.Account__c = originalGoodwillPayment.Account__c ;
                        payment.BillingContract__c = originalGoodwillPayment.BillingContract__c ;
                        payment.PaymentDate__c = System.today() ;   
                        payment.BillAmountUnallocated__c = -originalGoodwillPayment.Amount__c ;
                        payment.BillAllocationStatus__c = PyAp_Constants.UNALLOCATED_PAYMENT_STATUS ;
                        payment.InstalmentAmountUnallocated__c = -originalGoodwillPayment.Amount__c ;
                        payment.InstalmentAllocationStatus__c = PyAp_Constants.UNALLOCATED_PAYMENT_STATUS ;
                        payment.RelatedPayment__c = originalGoodwillPayment.Id ;
                        payment.PaymentMethod__c = '';   //AT-3189
                    listNewApprovedGoodwillPayment.add(payment) ;
                }
                if(!listNewApprovedGoodwillPayment.isEmpty()) {
                    listNewApprovedGoodwillPayment= (List<Payment__c>) GlUt_FieldSecurity.cleanseFields(listNewApprovedGoodwillPayment, false);
                    Database.insert(listNewApprovedGoodwillPayment) ;
                }               
            }
        } catch(Exception ex) {
            GlUt_Logger.logException(ex) ;
            GlUt_Logger.writeLogsToDatabase() ;
        }
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           17 Jan 2018
    @param          List<Payment__c> paymentList, Map<Id, Payment__c> oldPaymentMap
    @description    Invoked when payments are updated: Returns an error when amount field is updated
                    and payment allocations are reversed if ReversedAmount__c is updated
    @return         List<PaymentAllocation__c>
    @revision       AT-2062 - Echo: Sudhir Kumar - 19 Apr 2018
    @revision       Echo: Sudhir Kumar
                    AT-2290: Incorrect value gets displayed in "Amount Allocated to Instalment" field on Payment record, when Refund process or Transfer Credit process completes successfully.
                    Root Cause: Payment Allocation was happening in case of Reversed Amount change as well.
    @revision		Echo: Sudhir Kumar - CoreMisc AT-2111 & AT-2290 bug fixes : Unallocate only when AmendmentReason is NOT Credit Refund AND Credit Transfer    
    *******************************************************************************/
    private void updatePaymentAllocations(List<Payment__c> paymentList, Map<Id, Payment__c> oldPaymentMap) {
        Set<Id> payAllocReverseIdSet = new Set<Id>();
        Set<Id> payAllocReverseWithInstalmentIdSet = new Set<Id>();
        List<Payment__c> paymentUpdateList = new List<Payment__c>();
        Set<Id> paymentIdSet = new Set<Id>();
        
        for(Payment__c payment : paymentList) {
            
            if(payment.Amount__c != oldPaymentMap.get(payment.Id).Amount__c) {
                // Use Custom Labels and confirm error message
                payment.addError(System.Label.GlUt_PaymentAmendmentErrorMessage);
            } else if(payment.ReversedAmount__c != oldPaymentMap.get(payment.Id).ReversedAmount__c) {
                if(payment.AmendmentReason__c != PyAp_Constants.REFUND && payment.AmendmentReason__c != PyAp_Constants.CREDITTRANSFER) {
                    if(payment.ReversedAmount__c == payment.Amount__c) {
                        payAllocReverseIdSet.add(payment.Id);
                        //paymentIdSet.add(payment.Id);             // AT-2062 : Sudhir
                     } else if (payment.ReversedAmount__c < payment.Amount__c) {
                        payAllocReverseWithInstalmentIdSet.add(payment.Id);
                    }
                } 
            }
        }
        
        // reverse all payment allocation records
        List<PaymentAllocation__c> paymentAllocations = reversePaymentAllocations(payAllocReverseIdSet, payAllocReverseWithInstalmentIdSet);
        
        //if(paymentAllocations == null || paymentAllocations.isEmpty()) {
        //    return;
        //}
        
        // CONFIRM: do we need to actually execute the update or not if there's no records updted above? 
        /* THE BLOW COMMENTED CODE MAY NOT BE REQUIRED AT ALL  - Commented as a part of AT-2290
        if(!paymentUpdateList.isEmpty()) {
            update paymentUpdateList; // Need to think about moving this stuff to finally block
        }
        */
        if(!paymentIdSet.isEmpty()) {
            // calling allocatePayment method with the paymentId set
            // This will update the instalment and Bill allocation fields, credit fields etc. on the Payment record, 
            // and also return a list of Payment allocation records.
           
            PaUt_ProcessPaymentAllocation.mode = PaUt_ProcessPaymentAllocation.ALLMODE;
            List<PaymentAllocation__c> payAllocList = PaUt_ProcessPaymentAllocation.allocatePayment(paymentIdSet);
            
            // CONFIRM - if we need to do anything here?
            //An update should be performed on the set of Payment passed to the class method and the returned list of Payment allocation records inserted. 
            // (This will likely only create new instalment allocation records for the second condition
            //  – the new Payment allocation records are picked up in the ‘After Create Scenario’ as a new Payment record is created for transfer).
            
        }
        
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           17 Jan 2018
    @param          Set<Id> payAllocReverseIdSet, Set<Id> payAllocReverseWithInstalmentIdSet
    @description    Updates the related Payment allocations to 'Reversed' status
    @return         List<PaymentAllocation__c>
    *******************************************************************************/
    private List<PaymentAllocation__c> reversePaymentAllocations(Set<Id> payAllocReverseIdSet, Set<Id> payAllocReverseWithInstalmentIdSet) {
        List<PaymentAllocation__c> paymentAllocationList; 
        if(!payAllocReverseIdSet.isEmpty() && !payAllocReverseWithInstalmentIdSet.isEmpty()) {
             paymentAllocationList = [SELECT Id, Status__c
                                      FROM PaymentAllocation__c
                                      WHERE (Status__c != :GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_REVERSED 
                                        AND ((Payment__c IN :payAllocReverseIdSet)
                                            OR (Payment__c IN :payAllocReverseWithInstalmentIdSet 
                                                AND Instalment__c != NULL)))];
        } else if(!payAllocReverseIdSet.isEmpty() && payAllocReverseWithInstalmentIdSet.isEmpty()) {
            paymentAllocationList = [SELECT Id, Status__c
                                      FROM PaymentAllocation__c
                                      WHERE Payment__c IN :payAllocReverseIdSet
                                      AND Status__c != :GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_REVERSED];
        } else if(payAllocReverseIdSet.isEmpty() && !payAllocReverseWithInstalmentIdSet.isEmpty()) {
            paymentAllocationList = [SELECT Id, Status__c
                                      FROM PaymentAllocation__c
                                      WHERE Payment__c IN :payAllocReverseWithInstalmentIdSet 
                                      AND Instalment__c != NULL
                                      AND Status__c != :GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_REVERSED];
        }
        
        if(paymentAllocationList == null || paymentAllocationList.isEmpty()) {
            return null;
        }
        
        for(PaymentAllocation__c paymentAllocation : paymentAllocationList) {
            paymentAllocation.Status__c = GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_REVERSED;
        }
        if(paymentAllocationList != null && !paymentAllocationList.isEmpty()){
            paymentAllocationList= (List<PaymentAllocation__c>) GlUt_FieldSecurity.cleanseFields(paymentAllocationList, false);
            update paymentAllocationList;
        }
         // Need to move this operation in the finally block
        return  paymentAllocationList;
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           17 Jan 2018
    @param          Map<Id, Id> paymentIdToBalanceIdMap, Map<Id, Payment__c> paymentsMap
    @description    builds and returns Balance Transaction list which needs to be inserted
    @return         List<BalanceTransaction__c>
    @revision       Echo: Sudhir Kumar - AT-2873 (Core 7a)
                    Balance Transaction record will NOT be created for Goodwill Payments as the Customers Balance should not change.
    *******************************************************************************/
    private List<BalanceTransaction__c> buildBalanceTransactions(Map<Id, Id> paymentIdToBalanceIdMap, Map<Id, Payment__c> paymentsMap) {
        List<BalanceTransaction__c> balanceTransactionList = new List<BalanceTransaction__c>();
        
        paymentRecordTypeToBalanceRecordTypeMap = getPaymentRecordTypeToBalanceRecordTypeMap();
        Map<String, String> balanceRTToTypeMap = new Map<String, String>();
        for(String recordTypeName : balanceRecordTypeMap.values()) {
            if(recordTypeName == GlUt_Constants.BALANCE_RECORDTYPE_RETURNTRANSFER){
                balanceRTToTypeMap.put(recordTypeName, GlUt_Constants.BALANCE_TYPE_RETURNTRANSFER);
            } else {
                balanceRTToTypeMap.put(recordTypeName, recordTypeName);
            }
        }
        
        for(Id paymentId : paymentIdToBalanceIdMap.keySet()) {
            String recordTypeName = paymentRecordTypeMap.get(paymentsMap.get(paymentId).RecordTypeId);
            if(paymentRecordTypeToBalanceRecordTypeMap.containsKey(paymentsMap.get(paymentId).RecordTypeId)) {      //AT-2873 (Core 7a) - This excludes Goodwill record type Payment
                BalanceTransaction__c balanceTransaction = new BalanceTransaction__c(Payment__c = paymentId, Balance__c = paymentIdToBalanceIdMap.get(paymentId));
                balanceTransaction.Amount__c = paymentsMap.get(paymentId).Amount__c;  
                balanceTransaction.RecordTypeId = paymentRecordTypeToBalanceRecordTypeMap.get(paymentsMap.get(paymentId).RecordTypeId);
                //balanceTransaction.Type__c = balanceRTToTypeMap.get(recordTypeName); -- AT-3174
                String bTRecordTypeName = Schema.SObjectType.BalanceTransaction__c.getRecordTypeInfosById().get(balanceTransaction.RecordTypeId).getname(); //AT-3174
                
                if(bTRecordTypeName == GlUt_Constants.BALANCE_TYPE_REFUND) {                              //AT-3174
                    balanceTransaction.RefundAmount__c = paymentsMap.get(paymentId).Amount__c; 
                } else if(bTRecordTypeName == GlUt_Constants.BALANCE_TYPE_RETURNTRANSFER) {               //AT-3174
                    balanceTransaction.ReturnTransferAmount__c = paymentsMap.get(paymentId).Amount__c;
                } else if(bTRecordTypeName == GlUt_Constants.BALANCE_TYPE_PAYMENT) {                      //AT-3174
                    balanceTransaction.PaymentAmount__c = paymentsMap.get(paymentId).Amount__c;
                }
                balanceTransactionList.add(balanceTransaction);
            }
        }
        
        return balanceTransactionList;
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           13 Feb 2018
    @description    sets paymentRecordTypeToBalanceRecordTypeMap 
                    and builds balanceRecordTypeMap and  paymentRecordTypeMap
    @return         Map<Id, Id>
    @revision       Echo: Sudhir Kumar: AT-2873 (Core 7a)
                    Balance Transaction record will NOT be created for Goodwill Payments as the Customers Balance should not change. 
    *******************************************************************************/
    private Map<Id, Id> getPaymentRecordTypeToBalanceRecordTypeMap() {
        if(paymentRecordTypeToBalanceRecordTypeMap != null) {
            return paymentRecordTypeToBalanceRecordTypeMap;
        }
        
        List<RecordType> recordTypeList = [SELECT Id, DeveloperName, SobjectType FROM RecordType 
                                           WHERE IsActive = true 
                                                 AND (SobjectType = :GlUt_Constants.BALANCETRANSACTION_SOBJECT_APINAME OR SobjectType = :GlUt_Constants.PAYMENT_SOBJECT_APINAME)];
        
        paymentRecordTypeToBalanceRecordTypeMap = new Map<Id, Id>();
        balanceRecordTypeMap = new Map<Id, String>();
        paymentRecordTypeMap = new Map<Id, String>();
        
        for(RecordType recordTypeObj : recordTypeList) {
            
            if(recordTypeObj.SobjectType == GlUt_Constants.PAYMENT_SOBJECT_APINAME && recordTypeObj.DeveloperName != PyAp_Constants.GOODWILL_PAYMENT_RECORD_TYPE) { //AT-2873 (Core 7a) - This excludes Goodwill record type Payment
                paymentRecordTypeMap.put(recordTypeObj.Id, recordTypeObj.DeveloperName);
                
            } else if(recordTypeObj.SobjectType == GlUt_Constants.BALANCETRANSACTION_SOBJECT_APINAME) {
                balanceRecordTypeMap.put(recordTypeObj.Id, recordTypeObj.DeveloperName);
                
            }
        }
        
        for(Id paymentRecordTypeId : paymentRecordTypeMap.keySet()) {
            for(Id balanceRecordTypeId : balanceRecordTypeMap.keySet()) {
                if(paymentRecordTypeMap.get(paymentRecordTypeId) == balanceRecordTypeMap.get(balanceRecordTypeId)) {
                    paymentRecordTypeToBalanceRecordTypeMap.put(paymentRecordTypeId, balanceRecordTypeId);
                }
            }
        }
               
        return paymentRecordTypeToBalanceRecordTypeMap;
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           17 Jan 2018
    @param          Set<Id> contractIdSet
    @description    Method to return Contracts by Map<Id, BillingContract__c>
    @return         Map<Id, BillingContract__c>
    *******************************************************************************/
    private Map<Id, BillingContract__c> getContractsMap(Set<Id> contractIdSet) {
        return new Map<Id, BillingContract__c>([SELECT Id, Balance__c 
                                         FROM BillingContract__c
                                         WHERE Id IN :contractIdSet]);
    }

    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           20 mar 2018
    @param          GlUt_TriggerHandlerObj inputParam
    @description    Call financial control dispatcher
    *******************************************************************************/
    public void CallFinancialControlDispatcher(GlUt_TriggerHandlerObj inputParam) {
        FcUt_CentralDispatcher.Main(inputParam);
    }
    
    /******************************************************************************
    @author         ECHO: Mohit Tayal
    @date           16 May 2018
    @param          List<Payment__c> paymentList
    @description    Invoked when payments are done on contracts and account is not
                    associated with the payment
    @return         void
    @revision       Echo:Sudhir Kumar -> AT-2873 (Core 7a)
                    1. If the Payment does not have anassociated Contract, the Payment should have a Credit Amount of 0.
                    2. If the Payment has a Billing Contract associated but not an Account, set the Account on Payment equal to the Account associated with the Contract.
                    3. If the Payment is marked as ‘Do Not Allocate to Instalments’ set Instalment Amount Unallocated to 0 to ensure that this Payment is not allocated against Instalment records
    *******************************************************************************/
    public void associatePaymentToAccount(List<Payment__c> paymentList) {
        
        Map<Id,Id> contractIdAccountIdMap = new Map<Id,Id>();
        Map<Id,BillingContract__c> mapContractId2Record = new Map<Id,BillingContract__c>(); //AT-3800
        List<BillingContract__c> updateBillingContractRecord = new List<BillingContract__c>(); //AT-3800
        
        // Start: AT-2873
        set<Id> setContractId = new set<Id>() ;           
        for(Payment__c payment : paymentList) { 
            if(payment.BillingContract__c != null) setContractId.add(payment.BillingContract__c) ;
        }
        for(BillingContract__c contract : [SELECT Id, AccountName__c, LastPaymentDate__c  FROM BillingContract__c WHERE Id IN: setContractId]) {  // AT-3800          
            mapContractId2Record.put(contract.Id, contract); // AT-3800
        }
        // End: AT-2873
        //fetching the contratcs associated eith the payments to be inserted          
        for(Payment__c objPayment : paymentList)
        {
            if(objPayment.Account__c == null && objPayment.BillingContract__c != null){
                contractIdAccountIdMap.put(objPayment.BillingContract__c,null);
            }
            //Start: AT-2873
            if(objPayment.BillingContract__c == null) { 
                objPayment.CreditAmount__c = 0.0 ;
            }
            if(objPayment.BillingContract__c != null && objPayment.Account__c == null) {                  
                objPayment.Account__c = mapContractId2Record.get(objPayment.BillingContract__c).AccountName__c ;  // AT-3800 Review Comments
            }
                    
            if(objPayment.BillingContract__c != null && objPayment.Account__c != mapContractId2Record.get(objPayment.BillingContract__c).AccountName__c ) {
                objPayment.Account__c.addError(System.Label.PyAp_PaymentContractAccountValidation) ;
            }
            if(objPayment.DoNotAllocatetoInstalments__c) {
                objPayment.InstalmentAmountUnallocated__c = 0 ;
            }   
            // End: AT-2873
            //Start... AT-3800                  
            string recordtypename = Schema.SObjectType.Payment__c.getRecordTypeInfosById().get(objPayment.RecordTypeId).getname();         
            if(recordtypename == GlUt_Constants.OBJ_PAYMENT && 
               objPayment.BillingContract__c != null &&
              (mapContractId2Record.get(objPayment.BillingContract__c).LastPaymentDate__c == null || 
               objPayment.PaymentDate__c > mapContractId2Record.get(objPayment.BillingContract__c).LastPaymentDate__c) ){
                   BillingContract__c billingContract = mapContractId2Record.get(objPayment.BillingContract__c);
                   billingContract.LastPaymentDate__c = objPayment.PaymentDate__c;
                   updateBillingContractRecord.add(billingContract);
            } //End...AT-3800
        }
        
        if(!contractIdAccountIdMap.keySet().isEmpty()){
            List<BillingContract__c> lstContract = [SELECT Id, AccountName__c FROM BillingContract__c WHERE Id IN :contractIdAccountIdMap.keySet()];
            
            //creating map for contract id and it's account
            for(BillingContract__c objContract : lstContract){
                if(contractIdAccountIdMap.containsKey(objContract.Id)){
                    contractIdAccountIdMap.put(objContract.Id,objContract.AccountName__c);
                }
            }
            
            //assigning account on payment
            for(Payment__c objPayment : paymentList){
                if(objPayment.BillingContract__c != null && contractIdAccountIdMap.containsKey(objPayment.BillingContract__c)){
                    objPayment.Account__c = contractIdAccountIdMap.get(objPayment.BillingContract__c);
                }
            }
        }
        // AT-3800
        if(updateBillingContractRecord.size() > 0) {
            updateBillingContractRecord= (List<BillingContract__c>) GlUt_FieldSecurity.cleanseFields(updateBillingContractRecord, false);
            database.update(updateBillingContractRecord);
        }
        
    }

}