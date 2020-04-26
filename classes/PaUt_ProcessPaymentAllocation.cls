/******************************************************************************
@author         Accenture: Pratyush Kumar (Accenture)
@date           16 Jan 2018
@description    Class to process Payment Allocations
@Revisions      11-June-2018,Tarun Gupta,AT-2720,Made changes to round the amount allocated
@Revisions      11-June-2018,Tarun Gupta,AT-2495,Made changes to make sure Payment is not allocated to Pending Bill
@Revisions      13-June-2018,Tarun Gupta,AT-2702,Made changes to use Bill Item start date instead of bill date
@revisions:     2 July 2018: Echo: Sudhir Kumar -> AT-2873(Core 7a)insert
*******************************************************************************/
public with sharing class PaUt_ProcessPaymentAllocation {
    
    public static String mode; // not sure if mode needs to be here
    private static final String UPDATEMAPVAL = 'Update';
    public static final String ALLMODE = 'All';
    private static final String INSTALMENTSMODE = 'Instalments';
    private static final String BILLITEMSMODE = 'BillItems';
    // AT-4014, get the Settlement Record Type Id from BalanceTransaction__c object for Payment Allocation Routine
    private static Id settlementRecordTypeId = Schema.SObjectType.BalanceTransaction__c.getRecordTypeInfosByName().get(PyAp_Constants.SETTLEMENTPAYMENT).getRecordTypeId();

    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Map<Id, String> instalmentIds
    @description    This method processes payment allocations for Instalments 
    *******************************************************************************/
    public static void processInstalment(Map<Id, String> instalmentIds) {
        Set<Id> updatedInstalmentsIds = new Set<Id>();
        //Set<Id> createdInstalmentsIds = new Set<Id>();
        //populateInstalmentIdSets(updatedInstalmentsIds, createdInstalmentsIds, instalmentIds);
        for(Id instalmentId : instalmentIds.keySet()) {
            if(instalmentIds.get(instalmentId) == UPDATEMAPVAL) {
                updatedInstalmentsIds.add(instalmentId);
            }// else if(instalmentIds.get(instalmentId) == 'Create') {
            //    createdInstalmentsIds.add(instalmentId);
            //}
            // Don't think we need to populate the createdInstalmentsIds set as we are not doing anything specific for them
            // so just keeping the updated ones for now
        }
        System.debug('Total Number of SOQL Queries allowed in this apex code context 3: ' +  Limits.getQueries());
        handleInstalmentUpdates(updatedInstalmentsIds);
        System.debug('Total Number of SOQL Queries allowed in this apex code context 4: ' +  Limits.getQueries());
        
        handleAllInstalments(instalmentIds.keySet());
        
        System.debug('Total Number of SOQL Queries allowed in this apex code context 5: ' +  Limits.getQueries());
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Map<Id, String> billIds
    @description    This method processes payment allocations for Bill Items 
    *******************************************************************************/
    public static void processBill(Map<Id, String> billIds) {
        
        system.debug('processBill ***');
		system.debug('SK-PaUt_ProcessPaymentAllocation-billIds= ' + billIds);
        // Query to get all related bill items and bill & their contracts
        List<BillItem__c> billItemList = getBillItemsByIds(billIds.keySet());
        
        //Build a set for of all of the amended bill items (those which are the parent of another bill item)
        // For the non amended bill items, also add the Bill Item’s parent Contract to a set
        Set<Id> amendedBillItemIdSet = new Set<Id>();
        Set<Id> amendedBillItemContractIdSet = new Set<Id>();
        Set<Id> nonAmendedBillItemContractIdSet = new Set<Id>();
		// AT-4014, Initialised the set for Payment Locations 
        Set<Id> nonAmendedBillItemLocationIdSet = new Set<Id>();
        // build Amended and Normal Bill Items
        if(!billItemList.isEmpty()) {
            for(BillItem__c billItem : billItemList) {
                if(billItem.BillItem__c != null) {
                    amendedBillItemIdSet.add(billItem.BillItem__c);
                    amendedBillItemContractIdSet.add(billItem.BillItem__r.Bill__r.BillingContract__c);
                } else if(billItem.Bill__r.BillingContract__c != null) {
                    nonAmendedBillItemContractIdSet.add(billItem.Bill__r.BillingContract__c);                    
                    if(billItem.SupplyPoint__c != null && billItem.SupplyPoint__r.Location__c != null){
                        nonAmendedBillItemLocationIdSet.add(billItem.SupplyPoint__r.Location__c);
                    }
                }
            }
        }
        
        Map<Id, Payment__c> paymentIdMap = new Map<Id, Payment__c>();
        System.debug('*****amendedBillItemIdSet'+amendedBillItemIdSet);
        System.debug('*****amendedBillItemContractIdSet'+amendedBillItemContractIdSet);
        system.debug('SK-PaUt_ProcessPaymentAllocation-nonAmendedBillItemLocationIdSet= ' + nonAmendedBillItemLocationIdSet);
        if(!amendedBillItemIdSet.isEmpty()) {
            // Query for all Payment allocation records that are associated with the amended bill items
            /*Changes for AT-2493 Starts here*/
            List<PaymentAllocation__c> reversePayAllocList = getPayAllocsForBillItems(amendedBillItemIdSet);
            /*Changes for AT-2493 Ends here*/
            System.debug('****reversePayAllocList'+reversePayAllocList);
            if(!reversePayAllocList.isEmpty()) {
                // update the status of all related Payment Allocations to 'Reversed'
                reversePaymentAllocsWithRelatedPayments(reversePayAllocList);
                // CONFIRM: Check whether it needs to be amendedBillItemContractIdSet or nonAmendedBillItemContractIdSet
                paymentIdMap = getPaymentsMapByContractIds(amendedBillItemContractIdSet);
                //paymentIdMap = getPaymentsMapByContractIds(nonAmendedBillItemContractIdSet);
                
                
            }
        } 
        System.debug('*****nonAmendedBillItemContractIdSet'+nonAmendedBillItemContractIdSet);
        System.debug('Total Number of SOQL Queries allowed in this apex code context 1: ' +  Limits.getQueries());
        
        if(!nonAmendedBillItemContractIdSet.isEmpty()) {
            Map<Id, Payment__c> paymentRetrievedMap = getPaymentsMapByContractIds(nonAmendedBillItemContractIdSet);
            if(paymentRetrievedMap.keySet() != null && !paymentRetrievedMap.keySet().isEmpty()) {
                for(Payment__c paymentObj : paymentRetrievedMap.values()) {
                    paymentIdMap.put(paymentObj.id, paymentObj);    
                }   
            }
        }
        
        // AT-4014, get all the Payment records related to Location
        if(!nonAmendedBillItemLocationIdSet.isEmpty()){
            Map<Id,Payment__c> paymentRetrievedMap = getPaymentsMapByLocationIds(nonAmendedBillItemLocationIdSet);
            if(paymentRetrievedMap.keySet() != null && !paymentRetrievedMap.keySet().isEmpty()) {
                for(Payment__c paymentObj : paymentRetrievedMap.values()) {
                    if(!paymentIdMap.containsKey(paymentObj.id)){
                        paymentIdMap.put(paymentObj.id, paymentObj); 
                    }
                }   
            }            
        }
        System.debug('*****paymentIdMap'+paymentIdMap);
        if(paymentIdMap.keySet() != null && !paymentIdMap.keySet().isEmpty()) {
            // call AllocatePayment with the set of Payment ids and the set the mode to ‘All’
            mode = ALLMODE;
            List<PaymentAllocation__c> paymentAllocatedList = allocatePayment(paymentIdMap.keySet());
        }
        
        System.debug('Total Number of SOQL Queries allowed in this apex code context 2: ' +  Limits.getQueries());
        
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Set<Id> paymentIds
    @description    This method processes payment allocations for Payments 
    @return         List<PaymentAllocation__c>
    *******************************************************************************/
    public static List<PaymentAllocation__c> allocatePayment(Set<Id> paymentIds) {
        List<PaymentAllocation__c> paymentAllocationInsertList = new List<PaymentAllocation__c>();
        Map<Id, Instalment__c> updateInstalmentMap = new Map<Id, Instalment__c>();
        Map<Id, BillItem__c> updateBillItemMap = new Map<Id, BillItem__c>();
        Map<Id, List<Payment__c>> contractIdToPaymentsMap = new Map<Id, List<Payment__c>>();
	
	// AT-4014, Map for Payment Allocation Amounts associated with Contract ID
        Map<Id, Map<Id,Decimal>> mapOfContractIdToPaymentsAllocatedMap = new Map<Id, Map<Id,Decimal>>();
	
	// AT-4014, Map for Contract ID => Balance ID 
        Map<Id,Id> mapOfContractIdToBalanceId = new Map<Id,Id>();
	
        // AT-4014, Map for Location ID => Payments
        Map<Id, List<Payment__c>> locationIdToPaymentsMap = new Map<Id, List<Payment__C>>();
        
        System.debug('Total Number of SOQL Queries allowed in this apex code context 6: ' +  Limits.getQueries());
        System.debug('mode == '+mode);
        // check whether mode is {All, BillItems, Instalments} 
        if(mode == ALLMODE || mode == BILLITEMSMODE) {
            // bill items allocations
            List<Payment__c> paymentList = getPaymentsForBillItems(paymentIds);
            System.debug('****paymentList'+paymentList);
            Set<Id> contractIdSet = new Set<Id>();
            
            Set<Id> locationIdSet = new Set<Id>(); // AT-4014
            buildContractIdToPaymentsMap(contractIdToPaymentsMap, locationIdToPaymentsMap, paymentList, contractIdSet, locationIdSet); // added a parameter to pass locationIdToPaymentMap and location id set - AT-3523
            System.debug('locationIdToPaymentsMap === '+locationIdToPaymentsMap);
            System.debug('locationIdSet === '+locationIdSet);
            List<PaymentAllocation__c> paymentAllocationList = new List<PaymentAllocation__c>();
            Map<Id, BillItem__c> updatedBillItemMap = new Map<Id, BillItem__c>();
            System.debug('****contractIdSet'+contractIdSet+'*****contractIdToPaymentsMap'+contractIdToPaymentsMap);
            // build contractIdToBillItemMap map
            Map<Id, List<BillItem__c>> contractIdToBillItemMap = buildContractIdToBillItemsMap(contractIdSet,mapOfContractIdToBalanceId);
            System.debug('contractIdToBillItemMap = '+contractIdToBillItemMap);
            Map<Id, List<BillItem__c>> locationIdToBillItemMap = buildLocationIdToBillItemsMap(locationIdSet,mapOfContractIdToBalanceId);
            System.debug('locationIdToBillItemMap === '+locationIdToBillItemMap);
            // Perform Payment Allocation Routine and allocate category items
            performPaymentAllocationRoutineForBillItems(contractIdToBillItemMap,contractIdToPaymentsMap,locationIdToBillItemMap,locationIdToPaymentsMap,paymentAllocationInsertList,updateBillItemMap,mapOfContractIdToPaymentsAllocatedMap); 
            system.debug('contractIdToPaymentsMap:: ' + contractIdToPaymentsMap);
            system.debug('paymentAllocationInsertList:: ' + paymentAllocationInsertList);
            system.debug('updateBillItemMap:: ' + updateBillItemMap);
            
        }
        
        System.debug('Total Number of SOQL Queries allowed in this apex code context 7: ' +  Limits.getQueries());
        
        if(mode == ALLMODE || mode == INSTALMENTSMODE) {
            // Instalments allocations
            List<PaymentAllocation__c> paymentAllocationsList = new List<PaymentAllocation__c>();
            Map<Id, Instalment__c> updatedInstalmentMap = new Map<Id, Instalment__c>();
            
            List<Payment__c> paymentList = getPaymentsForInstalments(paymentIds);
            system.debug('paymentList2:: ' + paymentList);
            Set<Id> contractIdSet = new Set<Id>();
            buildContractIdToPaymentsMap(contractIdToPaymentsMap, null, paymentList, contractIdSet, null);
            
            // Perform Payment Allocation Routine and allocate category items for all Instalments
            if(!contractIdSet.isEmpty()) {
                performPaymentAllocationRoutineForInstalments(contractIdSet, contractIdToPaymentsMap, paymentAllocationInsertList, updateInstalmentMap);
            }
            system.debug('contractIdSet:: ' + contractIdSet);
            system.debug('contractIdToPaymentsMap:: ' + contractIdToPaymentsMap);
            system.debug('paymentAllocationInsertList2:: ' + paymentAllocationInsertList);
            system.debug('updateInstalmentMap2:: ' + updateInstalmentMap);
        }  
        
        System.debug('Total Number of SOQL Queries allowed in this apex code context: 8 ' +  Limits.getQueries());
        // All DML Operations related to Instalment and Bill Item Allocations
        if(!paymentAllocationInsertList.isEmpty()) {
            // Inserting Payment Allocations
            paymentAllocationInsertList = (List<PaymentAllocation__c>) GlUt_FieldSecurity.cleanseFields(paymentAllocationInsertList, false);
            insert paymentAllocationInsertList;
            List<Payment__c> paymentUpdateList = new List<Payment__c>();
            if(!contractIdToPaymentsMap.values().isEmpty()) {                
                // Building the Payment Update List and updating the fields like Credit Amount, Bill Amount 
                // and Instalments - Allocated, Unallocated amd Allocation Status
                for(List<Payment__c> paymentList : contractIdToPaymentsMap.values()) {
                    paymentUpdateList.addAll(paymentList);
                }
            }
            
            // AT-3523, Update the payment lists
            if(!locationIdToPaymentsMap.values().isEmpty()) {                
                // Building the Payment Update List and updating the fields as Credit Amount, Bill Amount 
                // and Instalments - Allocated, Unallocated amd Allocation Status
                for(List<Payment__c> paymentList : locationIdToPaymentsMap.values()) {
                    paymentUpdateList.addAll(paymentList);
                }				
            }
            
            if(paymentUpdateList.size() > 0){
                paymentUpdateList = (List<Payment__c>) GlUt_FieldSecurity.cleanseFields(paymentUpdateList, false);
                update paymentUpdateList;
            }
            // Updating Bill Items with fields likes Amount Paid etc.
            if(!updateBillItemMap.values().isEmpty()) {
				List<BillItem__c> billItemUpdateList = (List<BillItem__c>) GlUt_FieldSecurity.cleanseFields(updateBillItemMap.values(), false);
                update billItemUpdateList;
            }
            // Updating Bill Items with fields likes Sum of Amount Allocated etc.
            if(!updateInstalmentMap.values().isEmpty()) {
                List<Instalment__c>  lstUpdateInstalmets = (List<Instalment__c>) GlUt_FieldSecurity.cleanseFields(updateInstalmentMap.values(), false);
                update lstUpdateInstalmets;
            }
            
        }
        
        System.debug('Total Number of SOQL Queries allowed in this apex code context 9: ' +  Limits.getQueries());
        if(!mapOfContractIdToPaymentsAllocatedMap.isEmpty() && mapOfContractIdToPaymentsAllocatedMap.KeySet().size() > 0){
            List<BalanceTransaction__c> newBalanceTransactionLists = buildBalanceTransactionList(mapOfContractIdToPaymentsAllocatedMap,mapOfContractIdToBalanceId);
            if(newBalanceTransactionLists != null && !newBalanceTransactionLists.isEmpty()){
				newBalanceTransactionLists = (List<BalanceTransaction__c>) GlUt_FieldSecurity.cleanseFields(newBalanceTransactionLists, false);
                insert newBalanceTransactionLists;
            }
        }
        
        return paymentAllocationInsertList;
    }
    
    
    /******************************************************************************
    @author         Echo : Ankit Gangwani
    @date           01 Nov 2018
    @param          Map<Id, Map<Id,Decimal>> mapOfContractIdToPaymentsAllocatedMap
					Map<Id,Decimal> mapOfContractIdToBalanceId
    @description    This method will build the Balance Transactions for each Contract Allocated
    @return         List<BalanceTransaction__c>
    *******************************************************************************/
    private static List<BalanceTransaction__c> buildBalanceTransactionList(Map<Id, Map<Id,Decimal>> mapOfContractIdToPaymentsAllocatedMap, Map<Id,Id> mapOfContractIdToBalanceId) {  
        List<BalanceTransaction__c> balanceTransactionLists = new List<BalanceTransaction__c>();
        for(Id contractId : mapOfContractIdToPaymentsAllocatedMap.KeySet()){
            Map<Id,Decimal> mapOfPaymentToAmountAllocatedMap = mapOfContractIdToPaymentsAllocatedMap.get(contractId);
            for(Id paymentId : mapOfPaymentToAmountAllocatedMap.KeySet()){
                BalanceTransaction__c objBalanceTransaction = new BalanceTransaction__c();
                objBalanceTransaction.Balance__c = mapOfContractIdToBalanceId.containsKey(contractId) ? mapOfContractIdToBalanceId.get(contractId) : null;
                objBalanceTransaction.Amount__c = mapOfPaymentToAmountAllocatedMap.get(paymentId);
                objBalanceTransaction.Payment__c = paymentId; 
                objBalanceTransaction.RecordTypeId = settlementRecordTypeId;
                balanceTransactionLists.add(objBalanceTransaction);
            }
        }
        return balanceTransactionLists;
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          List<PaymentAllocation__c> reversePayAllocList
    @description    This method processes the payment allocations reversals for Payments 
                    and sets the Status of Payment Allocations to 'Reverse'
    @return         void
    *******************************************************************************/
    private static void reversePaymentAllocsWithRelatedPayments(List<PaymentAllocation__c> reversePayAllocList) {
        
        // map with Payment Id as key and List of related Payment Allocations as values
        Map<Id, List<PaymentAllocation__c>> paymentIdToPayAllocsMap = new Map<Id, List<PaymentAllocation__c>>();
        
        // setting the Status of Payment Allocations to 'Reverse'
        for(PaymentAllocation__c paymentAllocation : reversePayAllocList) {
            paymentAllocation.Status__c = GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_REVERSED;
            
            if(paymentIdToPayAllocsMap.keySet() == null || paymentIdToPayAllocsMap.keySet().isEmpty() || !paymentIdToPayAllocsMap.containsKey(paymentAllocation.Payment__c)) {
                paymentIdToPayAllocsMap.put(paymentAllocation.Payment__c, new List<PaymentAllocation__c>{paymentAllocation});
            } else if(paymentIdToPayAllocsMap.containsKey(paymentAllocation.Payment__c)) {
                paymentIdToPayAllocsMap.get(paymentAllocation.Payment__c).add(paymentAllocation);
            }
        }
        
        List<Payment__c> paymentList = getPaymentListToUpdateOnAmountReversal(paymentIdToPayAllocsMap);
        reversePayAllocList = (List<PaymentAllocation__c>) GlUt_FieldSecurity.cleanseFields(reversePayAllocList, false);
        // updating the status of all Payment Allocations
        update reversePayAllocList;
        
        // updating the Instalment Unallocated Amounts on Payments
        if(!paymentList.isEmpty()) {
			paymentList = (List<Payment__c>) GlUt_FieldSecurity.cleanseFields(paymentList, false);
            update paymentList;
        }
    }
    
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Set<Id> contractIdSet
                    Map<Id, List<Payment__c>> contractIdToPaymentsMap 
                    List<PaymentAllocation__c> paymentAllocationInsertList
                    Map<Id, Instalment__c> updateInstalmentMap
                    
    @description    Method to perform Payment Allocation Routine for Instalments 
    @return         void
    @revision       Echo: Sudhir Kumar
                    AT-2290: Incorrect value gets displayed in "Amount Allocated to Instalment" field on Payment record, when Refund process or Transfer Credit process completes successfully.
                    Root Cause: Reversed Amount in case of Credit Refund/Transfer were not taken into consideration.
                    
    *******************************************************************************/
    private static void performPaymentAllocationRoutineForInstalments(Set<Id> contractIdSet, Map<Id, List<Payment__c>> contractIdToPaymentsMap, 
                                                                      List<PaymentAllocation__c> paymentAllocationInsertList, 
                                                                      Map<Id, Instalment__c> updateInstalmentMap) {
          
          List<Instalment__c> instalmentList = getInstalmentsByContractsIds(contractIdSet);
          system.debug('instalmentList:: ' + instalmentList);
          for(Instalment__c instalment : instalmentList) {
              if(instalment.PaymentPlan__r.BillingContract__c == null || !contractIdToPaymentsMap.containsKey(instalment.PaymentPlan__r.BillingContract__c)) {//AT-3174
                  continue;
              }
              Decimal installOutstanding = instalment.InstalmentAmountOutstanding__c;
              system.debug('installOutstanding:: ' + installOutstanding);
              for(Payment__c payment : contractIdToPaymentsMap.get(instalment.PaymentPlan__r.BillingContract__c)) {//AT-3174
                  
                  if(payment.InstalmentAmountUnallocated__c == null) {
                      payment.InstalmentAmountUnallocated__c = payment.Amount__c ;
                  }
                  if(payment.InstalmentAllocationAmount__c == null) {
                      payment.InstalmentAllocationAmount__c = 0;
                  }
                  
                  system.debug('payment.InstalmentAmountUnallocated__c:: ' + payment.InstalmentAmountUnallocated__c);
                  
                  Decimal paymentInstallUnallocated = (payment.InstalmentAmountUnallocated__c == null || payment.InstalmentAmountUnallocated__c == 0.00) ? payment.Amount__c  : payment.InstalmentAmountUnallocated__c; 
                  
                  system.debug('paymentInstallUnallocated:: ' + paymentInstallUnallocated);
                  
                  if(installOutstanding <= paymentInstallUnallocated) {
                      // add payment allocations to paymentAllocationInsertList
                      PaymentAllocation__c paymentAllocation = buildPaymentAllocation(instalment.Id, null, payment.Id, installOutstanding, GlUt_Constants.PAYMENTALLOCATION_ALLOCATIONSTATUS_ALLOCATED);
                      paymentAllocationInsertList.add(paymentAllocation);
                      
                      payment.InstalmentAmountUnallocated__c = paymentInstallUnallocated -  installOutstanding ; 
                      payment.InstalmentAllocationAmount__c = payment.Amount__c -  payment.InstalmentAmountUnallocated__c ;
                      
                      
                      if(payment.InstalmentAmountUnallocated__c == 0) {
                          payment.InstalmentAllocationStatus__c = GlUt_Constants.PAYMENTALLOCATION_INSTALMENTALLOCATIONSTATUS_FULLY;
                      } else {
                          payment.InstalmentAllocationStatus__c = GlUt_Constants.PAYMENTALLOCATION_INSTALMENTALLOCATIONSTATUS_PARTIALLY;
                      }
                     
                      // AmountOutstanding__c is a formula field and hence setting the value for InstalmentAmountDue__c
                      if(instalment.SumofAllocatedPayment__c == null) {
                          instalment.SumofAllocatedPayment__c = 0;
                      }
                      system.debug('instalment.SumofAllocatedPayment__c:: ' + instalment.SumofAllocatedPayment__c);
                      
                      if(updateInstalmentMap.keySet().isEmpty() || !updateInstalmentMap.containsKey(instalment.Id)) {
                          //    updateInstalmentMap.put(instalment.Id, new Instalment__c(Id=instalment.Id, AmountOutstanding__c = 0);
                          updateInstalmentMap.put(instalment.Id, new Instalment__c(Id=instalment.Id, SumofAllocatedPayment__c = instalment.SumofAllocatedPayment__c + installOutstanding));
                      } else if(!updateInstalmentMap.keySet().isEmpty() && updateInstalmentMap.containsKey(instalment.Id)) {
                          //    updateInstalmentMap.get(instalment.Id).AmountOutstanding__c = 0;
                          Decimal existingAllocationAmount = updateInstalmentMap.get(instalment.Id).SumofAllocatedPayment__c;
                          updateInstalmentMap.get(instalment.Id).SumofAllocatedPayment__c = existingAllocationAmount + installOutstanding;
                      }
                  } else if(installOutstanding > paymentInstallUnallocated) {
                      // add payment allocations to paymentAllocationInsertList and use amount as paymentInstallUnallocated
                      PaymentAllocation__c paymentAllocation = buildPaymentAllocation(instalment.Id, null, payment.Id, paymentInstallUnallocated, GlUt_Constants.PAYMENTALLOCATION_ALLOCATIONSTATUS_ALLOCATED);
                      paymentAllocationInsertList.add(paymentAllocation);
                      
                      payment.InstalmentAmountUnallocated__c = 0; // always set to 0
                      payment.InstalmentAllocationAmount__c = payment.Amount__c ;
                      
                      // Commented the following code as per discussion with Pratyush - Swati Mathur --22-Feb-2018
                      /*
                      if(payment.InstalmentAmountUnallocated__c == 0) {
                          payment.InstalmentAllocationStatus__c = GlUt_Constants.PAYMENTALLOCATION_INSTALMENTALLOCATIONSTATUS_FULLY;
                      } else {
                          payment.InstalmentAllocationStatus__c = GlUt_Constants.PAYMENTALLOCATION_INSTALMENTALLOCATIONSTATUS_PARTIALLY;
                      }
                      */                      
                      payment.InstalmentAllocationStatus__c = GlUt_Constants.PAYMENTALLOCATION_INSTALMENTALLOCATIONSTATUS_FULLY;
                      
                      // AmountOutstanding__c is a formula field and hence setting the value for InstalmentAmountDue__c
                      if(instalment.SumofAllocatedPayment__c == null) {
                          instalment.SumofAllocatedPayment__c = 0;
                      }
                      
                      if(updateInstalmentMap.keySet() == null || updateInstalmentMap.keySet().isEmpty() || !updateInstalmentMap.containsKey(instalment.Id)) {
                          //    updateInstalmentMap.put(instalment.Id, new Instalment__c(Id=instalment.Id, AmountOutstanding__c = (installOutstanding - paymentInstallUnallocated));
                          updateInstalmentMap.put(instalment.Id, new Instalment__c(Id=instalment.Id, SumofAllocatedPayment__c = instalment.SumofAllocatedPayment__c + paymentInstallUnallocated));
                      } else if(!updateInstalmentMap.keySet().isEmpty() && updateInstalmentMap.containsKey(instalment.Id)) {
                          //    updateInstalmentMap.get(instalment.Id).AmountOutstanding__c = (installOutstanding - paymentInstallUnallocated);
                          Decimal existingAllocationAmount = updateInstalmentMap.get(instalment.Id).SumofAllocatedPayment__c;
                          updateInstalmentMap.get(instalment.Id).SumofAllocatedPayment__c = existingAllocationAmount + paymentInstallUnallocated;
                      }
                   }
                  
              }
          }
          
      }
    
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Id instalmentId, Id billItemId, Id paymentId, Decimal amountAllocated, String status
    @description    Method to build Payment Allocation Object
    @return         PaymentAllocation__c
    *******************************************************************************/
    private static PaymentAllocation__c buildPaymentAllocation(Id instalmentId, Id billItemId, Id paymentId, Decimal amountAllocated, String status) {
        PaymentAllocation__c paymentAllocation = new PaymentAllocation__c();
        paymentAllocation.Instalment__c = instalmentId;
        paymentAllocation.BillItem__c = billItemId;
        paymentAllocation.Payment__c = paymentId;
        paymentAllocation.AmountAllocated__c = amountallocated;
        paymentAllocation.Status__c = status;
        paymentAllocation.Active__c = true;
        
        return paymentAllocation;
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Set<Id> contractIdSet
    @description    Method to get Instalments by Contract Ids
    @return         List<Instalment__c>
    @revision       Echo: Sudhir - AT-2268: Added "PaymentPlan__r.Active__c = True" in the SOQL
    **********************************************************************************/
    private static List<Instalment__c> getInstalmentsByContractsIds(Set<Id> contractIdSet) {
        return [SELECT Id, InstalmentDueDate__c, InstalmentAmountOutstanding__c, InstalmentNumber__c, PaymentPlan__r.BillingContract__c, SumofAllocatedPayment__c //AT-3174
                FROM Instalment__c 
                WHERE PaymentPlan__r.BillingContract__c IN :contractIdSet AND InstalmentAmountOutstanding__c > 0  AND PaymentPlan__r.Active__c = True   // AT-2268 //AT-3174
                ORDER BY InstalmentDueDate__c ASC NULLS LAST];
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Map<Id, List<BillItem__c>> contractIdToBillItemMap, 
                    Map<Id, List<BillItem__c>> billIdToBillItemsMap, 
                    Map<String, List<BillItem__c>> categoryToBillItemMap
                    
    @description    Method to build Set<String> of Category Set and other related
                    maps like billIdToBillItemMap and categoryToBillItemMap 
    @return         Set<String>  
    
    *******************************************************************************/
    private static Set<String> buildCategorySetAndBillIdToBillItemMap(Map<Id, List<BillItem__c>> contractOrLocationIdToBillItemMap, 
                                                                      Map<Id, List<BillItem__c>> billIdToBillItemsMap, 
                                                                      Map<String, List<BillItem__c>> categoryToBillItemMap,
                                                                      Set<String> categorySet) {
                                                                     
        //Set<String> categorySet = new Set<String>();
        system.debug('contractOrLocationIdToBillItemMap:: ' + contractOrLocationIdToBillItemMap) ;
        system.debug('billIdToBillItemsMap:: ' + billIdToBillItemsMap) ;
        system.debug('categoryToBillItemMap:: ' + categoryToBillItemMap) ;
                                                                     
        for(List<BillItem__c> billItems : contractOrLocationIdToBillItemMap.values()) {
            for(BillItem__c billItem : billItems) {
                
                system.debug('billIdToBillItemsMap.keySet()=='+ billIdToBillItemsMap.keySet());
                system.debug('billIdToBillItemsMap.keySet().isEmpty()=='+ billIdToBillItemsMap.keySet().isEmpty());
                system.debug('billIdToBillItemsMap.containsKey(billItem.Bill__c)=='+ billIdToBillItemsMap.containsKey(billItem.Bill__c));
                // building a map of Bill Id and their list of Bill Items 
                //if(billIdToBillItemsMap.keySet() == null && billIdToBillItemsMap.keySet().isEmpty() && !billIdToBillItemsMap.containsKey(billItem.Bill__c)) { // replaced OR with And
                if(billIdToBillItemsMap != null){
                    if(!billIdToBillItemsMap.containsKey(billItem.Bill__c)) {   // replaced OR with And    
                        billIdToBillItemsMap.put(billItem.Bill__c, new List<BillItem__c> {billItem});
                    } else if(billIdToBillItemsMap.containsKey(billItem.Bill__c)) {
                        billIdToBillItemsMap.get(billItem.Bill__c).add(billItem);
                    }
                }
                system.debug('billIdToBillItemsMap-2:: ' + billIdToBillItemsMap) ;
                // Building a map of category and all Bill Items within the category
                String categoryName = billItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostCategory__c;
                system.debug('categoryName-2:: ' + categoryName) ;
                if(String.isNotBlank(categoryName)) {
                    
                    if(categoryToBillItemMap.keySet() == null || categoryToBillItemMap.keySet().isEmpty() || !categoryToBillItemMap.containsKey(categoryName)) {
                        categoryToBillItemMap.put(categoryName, new List<BillItem__c>{billItem});
                    } else if(categoryToBillItemMap.containsKey(categoryName)) {
                        categoryToBillItemMap.get(categoryName).add(billItem);
                    }
                    system.debug('categoryToBillItemMap-2:: ' + categoryToBillItemMap) ;
                    // Bill items are ordered by category first, then Bill date, 
                    // then those those items which are amended by Bill date, then by posting priority
                    categorySet.add(categoryName);
                }
            }
        }
        
        return categorySet;
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           15 Feb 2018
    @param          List<String> categoryOrderedList, 
                    Map<String, List<BillItem__c>> categoryToBillItemMap, 
                    Map<String, List<Map<String, List<BillItem__c>>>> billIdToCatMap
                    
    @description    Method to build Map<String, List<Map<String, List<BillItem__c>>>> 
                    which holds bill ids as key and the related list of categories 
                    and their related Bill Items as values 
    @return         void  
    *******************************************************************************/
    private static void buildBillIdToCategoryMap(List<String> categoryOrderedList, 
                                                 Map<String, List<BillItem__c>> categoryToBillItemMap, 
                                                 Map<Id, List<Map<String, List<BillItem__c>>>> billIdToCatMap) {
                                                     
        // Iterating through the categories which sorted in ascending order
        for(String category : categoryOrderedList) {
            // based on the categories, we're retrieving the related bill items
            for(BillItem__c billItem : categoryToBillItemMap.get(category)) {
                
                if(billIdToCatMap.keySet() == null || billIdToCatMap.keySet().isEmpty() || !billIdToCatMap.containsKey(billItem.Bill__c)) {
                    
                    Map<String, List<BillItem__c>> catTobillItemEntryMap = new Map<String, List<BillItem__c>>();
                    catTobillItemEntryMap.put(category, new List<BillItem__c>{billItem});
                    billIdToCatMap.put(billItem.Bill__c, new List<Map<String, List<BillItem__c>>>{catTobillItemEntryMap});
                    
                } else if(billIdToCatMap.keySet() != null && !billIdToCatMap.keySet().isEmpty() && billIdToCatMap.containsKey(billItem.Bill__c)) {
                    
                    for(Map<String, List<BillItem__c>> billIdToCatEntryMap : billIdToCatMap.get(billItem.Bill__c)) {
                        if(billIdToCatEntryMap.containsKey(category)) {
                            billIdToCatEntryMap.get(category).add(billItem);
                        } else if(!billIdToCatEntryMap.containsKey(category)){
                            
                            Map<String, List<BillItem__c>> catTobillItemEntryMap = new Map<String, List<BillItem__c>>();
                            catTobillItemEntryMap.put(category, new List<BillItem__c>{billItem});
                            billIdToCatMap.get(billItem.Bill__c).add(catTobillItemEntryMap);
                        }
                        
                    }
                }
            }
        }
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Map<Id, List<BillItem__c>> contractIdToBillItemMap
                    Map<Id, List<Payment__c>> contractIdToPaymentsMap
                    List<PaymentAllocation__c> paymentAllocationInsertList
                    Map<Id, BillItem__c> updateBillItemMap
    @description    Method to perform Payment Allocation Routine for Bill Items
    @return         void
    *******************************************************************************/    
    private static void performPaymentAllocationRoutineForBillItems(Map<Id, List<BillItem__c>> contractIdToBillItemMap, Map<Id, List<Payment__c>> contractIdToPaymentsMap, Map<Id, List<BillItem__c>> locationIdToBillItemMap, Map<Id, List<Payment__c>> locationIdToPaymentsMap, List<PaymentAllocation__c> paymentAllocationInsertList, Map<Id, BillItem__c> updateBillItemMap, Map<Id,Map<Id,Decimal>> mapOfContractIdToPaymentsAllocatedMap) {
        
        // Map of Bill Id and list of Bill Items
        Map<Id, List<BillItem__c>> billIdToBillItemsMap = new Map<Id, List<BillItem__c>>();
        // Map of Bill Id as key for a list of map of (category names as key with list of bill items)
        Map<Id, List<Map<String, List<BillItem__c>>>> billIdToCatMap = new Map<Id, List<Map<String, List<BillItem__c>>>>(); 
        // Map of Category and their related Bill Items
        Map<String, List<BillItem__c>> categoryToBillItemMap = new Map<String, List<BillItem__c>>();
        
        // Setting this to Set<String> as Category field on Service Item Family is a Text field 
        Set<String> categorySet = new Set<String>();
        buildCategorySetAndBillIdToBillItemMap(contractIdToBillItemMap, billIdToBillItemsMap, categoryToBillItemMap, categorySet);
        
        // AT-4014, build maps billIdToBillItemsMap, categoryToBillItemMap and categorySet        
        buildCategorySetAndBillIdToBillItemMap(locationIdToBillItemMap, billIdToBillItemsMap, categoryToBillItemMap, categorySet);
                                                                        
        // Ordering the categories from lowest to highest 
        List<String> categoryOrderedList = new List<String>(categorySet);
        categoryOrderedList.sort();
        System.debug('categoryOrderedList--'+ categoryOrderedList);
        // Iterating through the categories and their bill Items to build a map of bill ids with
        // their catories and related bill items
        buildBillIdToCategoryMap(categoryOrderedList, categoryToBillItemMap, billIdToCatMap);
        // for all category entries, pass the value to allocateCategoryItems
        if(billIdToCatMap.values() != null && !billIdToCatMap.values().isEmpty()) {
            
            // map of all bill items related to the payment with outstanding amount > 0
            Map<Id, BillItem__c> billItemMap = new Map<Id, BillItem__c>();
            for(String category : categoryOrderedList) {
                // list of all bill items that needs to be allocated
                List<BillItem__c> billItemList = buildBillItemList(category, billItemMap, billIdToCatMap);
                System.debug('*****billItemList'+billItemList)   ;                
                // Sort all Bill Items based on Bill Dates
                Map<Date, List<BillItem__c>> billItemListByBillDateMap = allocateBillItemsByBillDate(billItemList);
                Set<Date> billDateSet = billItemListByBillDateMap.keySet();
                List<Date> billDateList = new List<Date>(billDateSet);
                billDateList.sort();
                // allocated bill items by category and bill dates
                for(Date billDate : billDateList) {
                    allocateCategoryItems(billItemListByBillDateMap.get(billDate), contractIdToPaymentsMap, locationIdToPaymentsMap, paymentAllocationInsertList, updateBillItemMap, mapOfContractIdToPaymentsAllocatedMap);
                }
                system.debug('paymentAllocationInsertList3:: ' + paymentAllocationInsertList) ;
                system.debug('updateBillItemMap3:: ' + updateBillItemMap) ;
            }
            
        }
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           15 Feb 2018
    @param          String category, 
                    Map<Id, BillItem__c> billItemMap, 
                    Map<Id, List<Map<String, List<BillItem__c>>>> billIdToCatMap
    @description    Method to build a sorted list of bill items for the category 
                    that needs to be allocated
    @return         List<BillItem__c>
    *******************************************************************************/
    private static List<BillItem__c> buildBillItemList(String category, 
                                          Map<Id, BillItem__c> billItemMap, 
                                          Map<Id, List<Map<String, List<BillItem__c>>>> billIdToCatMap) {
        
        List<BillItem__c> billItemList = new List<BillItem__c>();
        
        for(List<Map<String, List<BillItem__c>>> catToBillList :  billIdToCatMap.values()) {
            for(Map<String, List<BillItem__c>> catToBillListMapEntry : catToBillList) {
                if(catToBillListMapEntry.containsKey(category)) {
                    for(BillItem__c billItem : catToBillListMapEntry.get(category)) {
                        // Condition is to ensure there isn't duplicate bill items in billItemList list
                        if(billItemMap.keySet() == null || billItemMap.keySet().isEmpty() || !billItemMap.containsKey(billItem.Id)) {
                            billItemMap.put(billItem.Id, billItem);
                            billItemList.add(billItem);
                        }
                    }
                }
            }
        }
        
        return billItemList;
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          List<BillItem__c> billItemList
    @description    Method to allocate Bill Items by date
    @return         Map<Date, List<BillItem__c>>
    *******************************************************************************/
    private static Map<Date, List<BillItem__c>> allocateBillItemsByBillDate(List<BillItem__c> billItemList) {
        Map<Date, List<BillItem__c>> billItemDateListMap = new Map<Date, List<BillItem__c>>();
        getSortedBillItemByBillDate(billItemList, billItemDateListMap);
        
        return billItemDateListMap;
    }
    
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          List<BillItem__c> billItemList
                    Map<Id, List<Payment__c>> contractIdToPaymentsMap
                    List<PaymentAllocation__c> paymentAllocationInsertList
                    Map<Id, BillItem__c> updateBillItemMap
    @description    Method to allocate Category Items
    @return         void
    @Revisions      13-June-2018,Tarun Gupta,AT-2495,Made changes to use List of Bill Item in case of amendment
    *******************************************************************************/
    
    // The list of Bill Items will all relate to a particular Bill and category, which therefore 
    // fulfils the first ordering by category and Bill date. The next step within this set of Bill Items
    // is to allocate Payment to the amended Bill Items in date order and posting priority, and then the normal 
    // Bill Items in posting priority)
    private static void allocateCategoryItems(List<BillItem__c> billItemList, Map<Id, List<Payment__c>> contractIdToPaymentsMap, Map<Id, List<Payment__c>> locationIdToPaymentsMap, List<PaymentAllocation__c> paymentAllocationInsertList, Map<Id, BillItem__c> updateBillItemMap, Map<Id,Map<Id,Decimal>> mapOfContractIdToPaymentsAllocatedMap) {
        system.debug('paymentAllocationInsertList4:: ' + paymentAllocationInsertList);
        List<BillItem__c> amendedBillItemList = new List<BillItem__c>();
        List<BillItem__c> normalBillItemList = new List<BillItem__c>();
        
        system.debug('billItemList ***'+ billItemList);
        system.debug('contractIdToPaymentsMap ***'+ contractIdToPaymentsMap);
        system.debug('paymentAllocationInsertList ***'+ paymentAllocationInsertList);
        system.debug('updateBillItemMap ***'+ updateBillItemMap);
        
        for(BillItem__c billItem : billItemList) {
            if(billItem.BillItem__c != null) {
                amendedBillItemList.add(billItem);
            } else if(!billItem.ReplacedbyNewBillItems__c){ //AT-2493 Starts/Ends here.
                normalBillItemList.add(billItem);
            }
        }
        
        system.debug('amendedBillItemList ***'+ amendedBillItemList);
        system.debug('normalBillItemList ***'+ normalBillItemList);
        system.debug('billItemList4:: ' + billItemList);
        // sort it based on date & posting priority
        if(!amendedBillItemList.isEmpty()) {
            Set<Date> amendedDateSet = new Set<Date>();
            //Map<Date, BillItem__c> amendedBillItemDateMap = new Map<Date, BillItem__c>();
            Map<Date, List<BillItem__c>> amendedBillItemDateMap = new Map<Date, List<BillItem__c>>();
            for(BillItem__c amendedBillItem : amendedBillItemList) {
                //amendedBillItemDateMap.put(amendedBillItem.Bill__r.BillDate__c, amendedBillItem);
                //amendedDateSet.add(amendedBillItem.Bill__r.BillDate__c);
                
                if (!amendedBillItemDateMap.containsKey(amendedBillItem.StartDate__c)) {
                    amendedBillItemDateMap.put(amendedBillItem.StartDate__c, new List <BillItem__c> ());
                }
                amendedBillItemDateMap.get(amendedBillItem.StartDate__c).add(amendedBillItem);
                
                //amendedBillItemDateMap.put(amendedBillItem.StartDate__c, amendedBillItem);
                amendedDateSet.add(amendedBillItem.StartDate__c);
            }
            
            system.debug('amendedBillItemDateMap ***'+ amendedBillItemDateMap);
            system.debug('amendedDateSet ***'+ amendedDateSet);
            
            // sorting the list in ascending order
            List<Date> amendedDateList = new List<Date>(amendedDateSet);
            amendedDateList.sort();
            
            system.debug('amendedDateList ***'+ amendedDateList);
            
            // building a list of sorted amended bill items by dates
            List<BillItem__c> sortedAmendedbillItems = new List<BillItem__c>();
            for(Date amendedDate : amendedDateList) {
                if(!amendedBillItemDateMap.keySet().isEmpty() && amendedBillItemDateMap.containsKey(amendedDate)) {
                    sortedAmendedbillItems.addall(amendedBillItemDateMap.get(amendedDate));
                }
            }
            
            system.debug('sortedAmendedbillItems ***'+ sortedAmendedbillItems);
            
            if(!sortedAmendedbillItems.isEmpty()) {
                allocatePostingPriorityItems(sortedAmendedbillItems, contractIdToPaymentsMap, locationIdToPaymentsMap, paymentAllocationInsertList, updateBillItemMap, mapOfContractIdToPaymentsAllocatedMap);
            }
            system.debug('paymentAllocationInsertList5:: ' + paymentAllocationInsertList);
        }
        if(!normalBillItemList.isEmpty()) {
            allocatePostingPriorityItems(normalBillItemList, contractIdToPaymentsMap, locationIdToPaymentsMap, paymentAllocationInsertList, updateBillItemMap, mapOfContractIdToPaymentsAllocatedMap);
        }
        system.debug('paymentAllocationInsertList5:: ' + paymentAllocationInsertList);
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Feb 2018
    @param          List<BillItem__c> sortedBillItemsByPostingPriority
    @description    Method to build PostingPriorityBillItemOutstandingMap
                    that stores total outstanding amount of all bill items grouped by priority
    @return         Map<String, Decimal>
    *******************************************************************************/
    private static Map<String, Decimal> getPostingPriorityBillItemOutstandingMap(List<BillItem__c> sortedBillItemsByPostingPriority) {
        // map to store total outstanding amount of all bill items grouped by priority
        Map<String, Decimal> postingPriorityBillItemOutstandingAmountMap = new Map<String, Decimal>();
        Boolean isInitialStep = true;
        Decimal cumulativeBillOutstandingAmount = 0;
        // holds the current priority that is currently evalutated
        String currentPriority;
        
        for(Integer i=0; i<sortedBillItemsByPostingPriority.size(); i++) {
            
            
            BillItem__c billItem = sortedBillItemsByPostingPriority[i];
            BillItem__c nextBillItem;
            // gets the next bill item as we need to compare the priority of the current and the next bill items
            if(i < (sortedBillItemsByPostingPriority.size() - 1)) {
                nextBillItem = sortedBillItemsByPostingPriority[i+1];
            } else {
                nextBillItem = null;
            }
            // Current outstanding amount of the bill item
            Decimal currentOutstandingAmt = billItem.AmountOutstanding__c != null ? billItem.AmountOutstanding__c : 0.0;
            
            // Condition to check if this is the 1st bill item of the current priority
            // Comparing PaymentPostPriority__c of current and next bill item. 
            // If it's not equal, we build a map of priority as key and cumulative outstanding amount as value.    
            if(isInitialStep && nextBillItem != null) {
                // assign the current outstanding amount
                cumulativeBillOutstandingAmount = currentOutstandingAmt;
                currentPriority = billItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostPriority__c;
                isInitialStep = false;
                if(billItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostPriority__c != nextBillItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostPriority__c) {
                    postingPriorityBillItemOutstandingAmountMap.put(currentPriority, cumulativeBillOutstandingAmount);
                    cumulativeBillOutstandingAmount = 0;
                    isInitialStep = true;
                }
                
            } else if( nextBillItem != null 
                        && billItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostPriority__c == nextBillItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostPriority__c) {
                
                // if there are more bill items for the current priority then keep on adding the outstanding amount until there's a bill item of new priority
                cumulativeBillOutstandingAmount += currentOutstandingAmt;
            } else if( nextBillItem == null 
                        || billItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostPriority__c != nextBillItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostPriority__c) {
                
                // if there are no more bill items for the current priority then add the total outstanding amount to the postingPriorityBillItemOutstandingAmountMap map
                if(isInitialStep) {
                    cumulativeBillOutstandingAmount = currentOutstandingAmt;
                    currentPriority = billItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostPriority__c;
                } else {
                    cumulativeBillOutstandingAmount += currentOutstandingAmt;
                }
                
                if(currentPriority == null && nextBillItem == null) {
                    currentPriority = billItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostPriority__c;
                }
                if(postingPriorityBillItemOutstandingAmountMap.keySet() == null || postingPriorityBillItemOutstandingAmountMap.keySet().isEmpty() || !postingPriorityBillItemOutstandingAmountMap.containsKey(currentPriority)) {
                    postingPriorityBillItemOutstandingAmountMap.put(currentPriority, cumulativeBillOutstandingAmount);
                    cumulativeBillOutstandingAmount = 0;
                }
                isInitialStep = true;
                
            }
        }
        
        return postingPriorityBillItemOutstandingAmountMap;
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          List<BillItem__c> billItemList
                    Map<Id, List<Payment__c>> contractIdToPaymentsMap
                    List<PaymentAllocation__c> paymentAllocationInsertList
                    Map<Id, BillItem__c> updateBillItemMap
    @description    Method to allocate Posting Priority Items
    @return         void
    @Revisions      11-June-2018,Tarun Gupta,AT-2720,Made changes to round the amount allocated
    *******************************************************************************/
    private static void allocatePostingPriorityItems(List<BillItem__c> billItemList, Map<Id, List<Payment__c>> contractIdToPaymentsMap, Map<Id, List<Payment__c>> locationIdToPaymentsMap, List<PaymentAllocation__c> paymentAllocationInsertList, Map<Id, BillItem__c> updateBillItemMap, Map<Id,Map<Id,Decimal>> mapOfContractIdToPaymentsAllocatedMap) {
        
        system.debug('billItemList in allocatePostingPriorityItems ***'+ billItemList);
        system.debug('contractIdToPaymentsMap in allocatePostingPriorityItems ***'+ contractIdToPaymentsMap);
        system.debug('paymentAllocationInsertList in allocatePostingPriorityItems ***'+ paymentAllocationInsertList);
        system.debug('updateBillItemMap in allocatePostingPriorityItems ***'+ updateBillItemMap);
        
        List<BillItem__c> sortedBillItemsByPostingPriority = getSortedBillItemByPostingPriority(billItemList);
        
        system.debug('sortedBillItemsByPostingPriority in allocatePostingPriorityItems ***'+ sortedBillItemsByPostingPriority);
        
        if(sortedBillItemsByPostingPriority.isEmpty()) {
            return; 
        }
        
        // map to store total outstanding amount of all bill items grouped by priority
        Map<String, Decimal> postingPriorityBillItemOutstandingAmountMap = getPostingPriorityBillItemOutstandingMap(sortedBillItemsByPostingPriority);
        
        system.debug('postingPriorityBillItemOutstandingAmountMap***'+ postingPriorityBillItemOutstandingAmountMap);
        
        Map<Id, Decimal> paymentAllocatedAmountUpdateMap = new Map<Id, Decimal>();
        // amount already allocated for all bill items of the same category and bill date
        Decimal amountAlreadyAllocated = 0;
        // holds the current priority that is currently evalutated
        String currentPriority = null;
        // holds the last priority that was evaluated
        String lastPriority = null;
        
        Map<String, Decimal> priorityAmountAllocatedMap = new Map<String, Decimal>();
        Map<String, Decimal> priorityChangedBilledAmount = new Map<String, Decimal>();
        Map<String, Payment__c> billItemPaymentIdProcessingMap = new Map<String, Payment__c>();
        
        Boolean isPriorityChanged = false;
        
        Integer intBillItemCount = 0;  //AT-2720
        
        for(BillItem__c billItem : billItemList) {
            
            system.debug('billItem Object ***'+ billItem);
            
            intBillItemCount += 1; //AT-2720
            
            // setting the last priority to the priority that was previously evaluated
            lastPriority = currentPriority;
            currentPriority = billItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostPriority__c;
            
            system.debug('currentPriority ***'+ currentPriority);
            system.debug('lastPriority ***'+ lastPriority);
            
            if(!postingPriorityBillItemOutstandingAmountMap.keySet().isEmpty() && postingPriorityBillItemOutstandingAmountMap.containsKey(currentPriority)) {
                
                Decimal currentCumulativeBillOutstandingAmount = postingPriorityBillItemOutstandingAmountMap.get(currentPriority);
                
                system.debug('currentCumulativeBillOutstandingAmount***'+ currentCumulativeBillOutstandingAmount);
                
                // Commented the following code as per discussion with Pratyush - Swati Mathur --22-Feb-2018
                /*
                Decimal cumulativeBillItemsAtPriorityPaidOff = 0;
                Decimal currentBillOutstandingDiff = (currentCumulativeBillOutstandingAmount - cumulativeBillItemsAtPriorityPaidOff);
                */
                
                Decimal currentBillOutstandingDiff = currentCumulativeBillOutstandingAmount;
                Decimal amountPaid = billItem.AmountPaid__c != null ? billItem.AmountPaid__c : 0.00;
                
                system.debug('currentBillOutstandingDiff***'+ currentBillOutstandingDiff);
                system.debug('amountPaid***'+ amountPaid);
                
                
                // AT-4014, payment list assignment on the basis of Contract first then location ID
                List<Payment__c> paymentLists = new List<Payment__c>();
                if(billItem.Bill__r.BillingContract__c != null && contractIdToPaymentsMap.containsKey(billItem.Bill__r.BillingContract__c)){
                    paymentLists = contractIdToPaymentsMap.get(billItem.Bill__r.BillingContract__c);                    
                }
                else if(locationIdToPaymentsMap.containsKey(billItem.SupplyPoint__r.Location__c)){
                    paymentLists = locationIdToPaymentsMap.get(billItem.SupplyPoint__r.Location__c);
                }
                
                Map<Id,Decimal> mapOfPaymentToAmountAllocatedMap = new Map<Id,Decimal>();
                for(Payment__c payment : paymentLists) {
                    
                    system.debug('payment Object ****'+ payment);
                    
                    // setting the amount unallocated and allocated fields if they are null
                    if(payment.BillAmountUnallocated__c == null) {
                        payment.BillAmountUnallocated__c = payment.Amount__c;
                    }
                    
                    if(payment.BillAllocationAmount__c == null) {
                        payment.BillAllocationAmount__c = 0;
                    }
                    
                    Decimal billUnalocAmount = payment.BillAmountUnallocated__c;
                    
                    system.debug('billUnalocAmount ***'+ billUnalocAmount);
                    
                    // if there's a change in the priority then we needs to subtract the already allocated amount from billUnalocAmount
                    if((lastPriority != null && lastPriority != currentPriority)) {    
                        Decimal alreadyAllocatedAmountsAcrossPriorities = 0;
                        for(String billItemPriority : priorityAmountAllocatedMap.keySet()) {
                            if(billItemPriority != currentPriority) {
                                Decimal lastAllocatedAmount = priorityAmountAllocatedMap.get(billItemPriority);
                                alreadyAllocatedAmountsAcrossPriorities += lastAllocatedAmount;
                            }
                        }
                        
                        system.debug('alreadyAllocatedAmountsAcrossPriorities ***'+ alreadyAllocatedAmountsAcrossPriorities);
                        isPriorityChanged = true;
                        billUnalocAmount = billUnalocAmount - alreadyAllocatedAmountsAcrossPriorities;
                        system.debug('billUnalocAmount 222***'+ billUnalocAmount);
                            
                        // setting the map of priority and the new billUnalocAmount if there's a change in the priority
                        priorityChangedBilledAmount.put(currentPriority, billUnalocAmount);
                        
                    } else if(isPriorityChanged && !priorityChangedBilledAmount.keySet().isEmpty() && priorityChangedBilledAmount.containsKey(currentPriority)) {
                    // if there has been a change in the priority and there are more bill items from the new priority
                    // then we need to set the billUnalocAmount to the priorityChangedBilledAmount of the current priority
                    
                        billUnalocAmount = priorityChangedBilledAmount.get(currentPriority);
                    }
                    
                    system.debug('billUnalocAmount 3333***'+ billUnalocAmount);
                    system.debug('currentBillOutstandingDiff 3333***'+ currentBillOutstandingDiff);
                    
                    // if bill unallocated amount is greater than the current bill outstanding amount
                    // then we need to set the Payment allocation's amount to the bill item's outstanding amount
                    if(billUnalocAmount != 0 && billUnalocAmount >= currentBillOutstandingDiff) {
                        
                        Decimal amountBilled = (billItem.AmountOutstanding__c != null && billItem.AmountOutstanding__c != 0) ? billItem.AmountOutstanding__c : billItem.NetBilledAmount__c;
                        system.debug('amountBilled inside ***'+ amountBilled);
                        
                        if(payment.Location__c != null){
                            if(!mapOfPaymentToAmountAllocatedMap.containsKey(payment.Id)){
                                mapOfPaymentToAmountAllocatedMap.put(payment.Id,amountBilled);
                            }
                        }
                        // building payment allocations with bill item's outstanding amount
                        PaymentAllocation__c paymentAllocation = buildPaymentAllocation(null, billItem.Id, payment.Id, amountBilled, GlUt_Constants.PAYMENTALLOCATION_ALLOCATIONSTATUS_ALLOCATED);
                        paymentAllocationInsertList.add(paymentAllocation);
                        billItemPaymentIdProcessingMap.put(String.valueOf(billItem.Id) + String.valueOf(payment.Id), payment);
                        
                        // setting the priorityAmountAllocatedMap to the amount that has been billed for each priority
                        if(priorityAmountAllocatedMap.keySet() == null || priorityAmountAllocatedMap.keySet().isEmpty() || !priorityAmountAllocatedMap.containsKey(currentPriority)) {
                            priorityAmountAllocatedMap.put(currentPriority, amountBilled);
                        } else if(priorityAmountAllocatedMap.containsKey(currentPriority)) {
                            Decimal totalBilledAmount = priorityAmountAllocatedMap.get(currentPriority) + amountBilled;
                            priorityAmountAllocatedMap.put(currentPriority, totalBilledAmount);
                        }
                        
                        // Set Bill Item's AmountPaid__c so that billItem.AmountOutstanding__c (formula field) is set to 0
                        amountPaid += amountBilled;
                        if(updateBillItemMap.keySet().isEmpty() || !updateBillItemMap.containsKey(billItem.Id)) {
                            updateBillItemMap.put(billItem.Id, new BillItem__c(Id=billItem.Id, AmountPaid__c = amountPaid));
                        } else if(!updateBillItemMap.keySet().isEmpty() && updateBillItemMap.containsKey(billItem.Id)) {
                            updateBillItemMap.get(billItem.Id).AmountPaid__c = amountPaid;
                        }
                        system.debug('billUnalocAmount:: ' + billUnalocAmount) ;
                        system.debug('amountBilled:: ' + amountBilled) ;
                        system.debug('amountAlreadyAllocated:: ' + amountAlreadyAllocated) ;
                        
                        Decimal paidAmountDiff = billUnalocAmount - (amountBilled + amountAlreadyAllocated); 
                        
                        if(lastPriority != null && lastPriority != currentPriority) {
                            //add already allocated amounts to paidAmountDiff if there's a change in the priority
                            Decimal alreadyAllocatedAmountsAcrossPriorities = 0;
                            for(String billItemPriority : priorityAmountAllocatedMap.keySet()) {
                                if(billItemPriority != currentPriority) {
                                    Decimal lastAllocatedAmount = priorityAmountAllocatedMap.get(billItemPriority);
                                    alreadyAllocatedAmountsAcrossPriorities += lastAllocatedAmount;
                                }
                            }
                            paidAmountDiff += alreadyAllocatedAmountsAcrossPriorities;
                        } else if(isPriorityChanged && !priorityChangedBilledAmount.keySet().isEmpty() && priorityChangedBilledAmount.containsKey(currentPriority)) {
                            //add already last allocated amounts to paidAmountDiff if there was a change in the priority 
                            Decimal alreadyAllocatedAmountsAcrossPriorities = 0;
                            for(String billItemPriority : priorityAmountAllocatedMap.keySet()) {
                                if(billItemPriority != currentPriority) {
                                    Decimal lastAllocatedAmount = priorityAmountAllocatedMap.get(billItemPriority);
                                    alreadyAllocatedAmountsAcrossPriorities += lastAllocatedAmount;
                                }
                            }
                            paidAmountDiff += alreadyAllocatedAmountsAcrossPriorities;
                            
                        }
                        system.debug('paidAmountDiff:: ' + paidAmountDiff) ;
                        // checking by adding setScale as it doesn't work well if the difference is like 0.00000001
                        if(paidAmountDiff.setScale(2) == 0) { 
                            // Check if it's GlUt_Constants.PAYMENTALLOCATION_STATUS_FULLY or just 'Full' - CONFIRM
                            payment.BillAllocationStatus__c = GlUt_Constants.PAYMENTALLOCATION_BILLALLOCATIONSTATUS_FULLY; // Check if it's GlUt_Constants.PAYMENTALLOCATION_STATUS_FULLY or just 'Full' - CONFIRM
                        } else {
                            payment.BillAllocationStatus__c = GlUt_Constants.PAYMENTALLOCATION_BILLALLOCATIONSTATUS_PARTIALLY; // Check if it's 'Partially Allocated' or just 'Partial' - CONFIRM
                        }
                        
                        // Commented the following code as per discussion with Pratyush - Swati Mathur --22-Feb-2018
                        /*
                        // setting cumulativeBillItemsAtPriorityPaidOff amount
                        cumulativeBillItemsAtPriorityPaidOff = cumulativeBillItemsAtPriorityPaidOff + amountBilled;
                        */
                        // setting the amount already allocated to the amount billed value
                        amountAlreadyAllocated += amountBilled;
                        
                        
                    } else if(billUnalocAmount != 0 && billUnalocAmount < currentBillOutstandingDiff) {
                        
                        system.debug('billItem.AmountOutstanding__c222***'+ billItem.AmountOutstanding__c);
                        system.debug('billUnalocAmount***'+ billUnalocAmount);
                        system.debug('currentBillOutstandingDiff***'+ currentBillOutstandingDiff);
                        system.debug('amountAlreadyAllocated***'+ amountAlreadyAllocated);
                        system.debug('intBillItemCount---'+ intBillItemCount);
                        system.debug('billItemList.size()---'+ billItemList.size());
                        
                        Decimal amountallocated;
                        
                        //AT-2720 Starts Here
                        if(intBillItemCount == billItemList.size()){
                            amountallocated = billUnalocAmount - amountAlreadyAllocated;
                        }
                        else{
                            // the amount is apportioned for the bill item and then allocated
                            amountallocated = billItem.AmountOutstanding__c * (billUnalocAmount / currentBillOutstandingDiff);
                            amountallocated = amountallocated.setScale(2, RoundingMode.HALF_UP); //AT-2720
                        }     
                        //AT-2720 Ends Here
                        system.debug('amountallocated***'+ amountallocated);
                        
                        
                        if(payment.Location__c != null){
                            if(!mapOfPaymentToAmountAllocatedMap.containsKey(payment.Id)){
                                mapOfPaymentToAmountAllocatedMap.put(payment.Id,amountallocated);
                            }
                        }
                        
                        PaymentAllocation__c paymentAllocation = buildPaymentAllocation(null, billItem.Id, payment.Id, amountallocated, GlUt_Constants.PAYMENTALLOCATION_ALLOCATIONSTATUS_ALLOCATED);
                        paymentAllocationInsertList.add(paymentAllocation);
                        
                        billItemPaymentIdProcessingMap.put(String.valueOf(billItem.Id) + String.valueOf(payment.Id), payment);
                        
                        if(priorityAmountAllocatedMap.keySet() == null || priorityAmountAllocatedMap.keySet().isEmpty() || !priorityAmountAllocatedMap.containsKey(currentPriority)) {
                            priorityAmountAllocatedMap.put(currentPriority, amountallocated);
                        } else if(priorityAmountAllocatedMap.containsKey(currentPriority)) {
                            Decimal totalBilledAmount = priorityAmountAllocatedMap.get(currentPriority) + amountallocated;
                            priorityAmountAllocatedMap.put(currentPriority, totalBilledAmount);
                        }
                        
                        // Need to check if AmountOutstanding__c is editable on BillItem - CONFIRM
                        // Changing the logic to set AmountOutstanding__c field, and instead setting AmountPaid__c field
                        // as AmountOutstanding__c is a formula field
                        if(updateBillItemMap.keySet().isEmpty() || !updateBillItemMap.containsKey(billItem.Id)) {
                            Decimal billItemAmountPaid = billItem.AmountPaid__c != null ? billItem.AmountPaid__c : 0.00;
                            updateBillItemMap.put(billItem.Id, new BillItem__c(Id=billItem.Id, AmountPaid__c = (billItemAmountPaid + amountallocated)));
                        } else if(!updateBillItemMap.keySet().isEmpty() && updateBillItemMap.containsKey(billItem.Id)) {
                            updateBillItemMap.get(billItem.Id).AmountPaid__c = (updateBillItemMap.get(billItem.Id).AmountPaid__c + amountallocated);
                        }
                        
                        Decimal paidAmountDiff = billUnalocAmount - (amountallocated + amountAlreadyAllocated);
                        
                        if(lastPriority != null && lastPriority != currentPriority) {
                            //add already allocated amounts to paidAmountDiff
                            Decimal alreadyAllocatedAmountsAcrossPriorities = 0;
                            for(String billItemPriority : priorityAmountAllocatedMap.keySet()) {
                                if(billItemPriority != currentPriority) {
                                    Decimal lastAllocatedAmount = priorityAmountAllocatedMap.get(billItemPriority);
                                    alreadyAllocatedAmountsAcrossPriorities += lastAllocatedAmount;
                                }
                            }
                            paidAmountDiff += alreadyAllocatedAmountsAcrossPriorities;
                        } else if(isPriorityChanged && !priorityChangedBilledAmount.keySet().isEmpty() && priorityChangedBilledAmount.containsKey(currentPriority)) {
                            //add already allocated amounts to paidAmountDiff
                            Decimal alreadyAllocatedAmountsAcrossPriorities = 0;
                            for(String billItemPriority : priorityAmountAllocatedMap.keySet()) {
                                if(billItemPriority != currentPriority) {
                                    Decimal lastAllocatedAmount = priorityAmountAllocatedMap.get(billItemPriority);
                                    alreadyAllocatedAmountsAcrossPriorities += lastAllocatedAmount;
                                }
                            }
                            paidAmountDiff += alreadyAllocatedAmountsAcrossPriorities;
                            
                        }
                        
                        // checking paidAmountDiff value after setting the scale
                        // as it doesn't work well if the difference is like 0.00000001
                        if(paidAmountDiff.setScale(2) == 0) {
                            payment.BillAllocationStatus__c = GlUt_Constants.PAYMENTALLOCATION_BILLALLOCATIONSTATUS_FULLY; 
                        } else {
                            payment.BillAllocationStatus__c = GlUt_Constants.PAYMENTALLOCATION_BILLALLOCATIONSTATUS_PARTIALLY; 
                        }
                        
                       // Commented the following code as per discussion with Pratyush - Swati Mathur --22-Feb-2018
                        /*
                        // setting cumulativeBillItemsAtPriorityPaidOff amount
                        cumulativeBillItemsAtPriorityPaidOff = cumulativeBillItemsAtPriorityPaidOff + amountallocated;
                        */
                        // setting amountAlreadyAllocated amount to the amount allocated above
                        amountAlreadyAllocated += amountallocated;
                    }
                }
                if(!mapOfPaymentToAmountAllocatedMap.isEmpty() && mapOfPaymentToAmountAllocatedMap.keySet().size() > 0){
                    mapOfContractIdToPaymentsAllocatedMap.put(billItem.Bill__r.BillingContract__c, mapOfPaymentToAmountAllocatedMap);
                }
            }
        }
        setBillAttributesOnPayments(billItemPaymentIdProcessingMap, contractIdToPaymentsMap, locationIdToPaymentsMap, paymentAllocationInsertList);
        
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Map<String, Payment__c> billItemPaymentIdProcessingMap, 
                    Map<Id, List<Payment__c>> contractIdToPaymentsMap, 
                    List<PaymentAllocation__c> paymentAllocationInsertList
    @description    Method to set Bill Items attributes on Payments after allocation
    @return         void
    *******************************************************************************/
    private static void setBillAttributesOnPayments(Map<String, Payment__c> billItemPaymentIdProcessingMap, Map<Id, List<Payment__c>> contractIdToPaymentsMap, Map<Id, List<Payment__c>> locationIdToPaymentsMap, List<PaymentAllocation__c> paymentAllocationInsertList) {
        
        // map of payment id to amount allocated for payment
        Map<Id, Decimal> paymenIdToAllocationAmountMap = new Map<Id, Decimal>();
        for(PaymentAllocation__c paymentAllocation : paymentAllocationInsertList) {
            if(billItemPaymentIdProcessingMap.containsKey(String.valueOf(paymentAllocation.BillItem__c) + String.valueOf(paymentAllocation.Payment__c))) {
                if(paymenIdToAllocationAmountMap.keySet() == null || paymenIdToAllocationAmountMap.keySet().isEmpty() || !paymenIdToAllocationAmountMap.containsKey(paymentAllocation.Payment__c)) {
                    paymenIdToAllocationAmountMap.put(paymentAllocation.Payment__c, paymentAllocation.AmountAllocated__c);
                } else if(paymenIdToAllocationAmountMap.containsKey(paymentAllocation.Payment__c)) {
                    Decimal amntAllocated = paymentAllocation.AmountAllocated__c + paymenIdToAllocationAmountMap.get(paymentAllocation.Payment__c);
                    paymenIdToAllocationAmountMap.put(paymentAllocation.Payment__c, amntAllocated);
                }    
            }
        }
        
        // Setting payment attributes - BillAllocationAmount__c, CreditAmount__c and BillAmountUnallocated__c
        for(List<Payment__c> paymentList : contractIdToPaymentsMap.values()) {
            settlementPayments(paymentList, paymenIdToAllocationAmountMap);                        
        }
        for(List<Payment__c> paymentList : locationIdToPaymentsMap.values()) {
            settlementPayments(paymentList, paymenIdToAllocationAmountMap);
        }
                                                        
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           29 Oct 2018
    @param          List<Payment__c> paymentList
    @description    AT-3523, Method to update BillAllocationAmount__c, CreditAmount__c and BillAmountUnallocated__c
					on the basis of Payment List by Contract or Location
    @return         void
    *******************************************************************************/
    private static void settlementPayments(List<Payment__c> paymentList, Map<Id, Decimal> paymenIdToAllocationAmountMap) {
        for(Payment__c payment : paymentList) {
            system.debug('payment========'+payment);
            system.debug('paymenIdToAllocationAmountMap========'+paymenIdToAllocationAmountMap);
            if(!paymenIdToAllocationAmountMap.keySet().isEmpty() && paymenIdToAllocationAmountMap.containsKey(payment.Id)) {
                Decimal billAllocatedAmount = payment.BillAllocationAmount__c != null ? payment.BillAllocationAmount__c : 0.00;
                Decimal billUnallocatedAmount = payment.BillAmountUnallocated__c != null && payment.BillAmountUnallocated__c != 0 ? payment.BillAmountUnallocated__c : payment.Amount__c;
                system.debug('billUnallocatedAmount========'+billUnallocatedAmount);
                system.debug('billAllocatedAmount========'+billAllocatedAmount);
                // check if bill has been fully allocated or not
                if(payment.BillAllocationStatus__c != GlUt_Constants.PAYMENTALLOCATION_BILLALLOCATIONSTATUS_FULLY) {
                    payment.BillAllocationAmount__c = billAllocatedAmount + paymenIdToAllocationAmountMap.get(payment.Id);
                    payment.BillAmountUnallocated__c = billUnallocatedAmount - paymenIdToAllocationAmountMap.get(payment.Id);
                } else {
                    payment.BillAllocationAmount__c = payment.Amount__c;
                    payment.BillAmountUnallocated__c = 0;
                }
                payment.CreditAmount__c = payment.BillAmountUnallocated__c;                
            }
        }
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          List<BillItem__c> billItemList
    @description    Method to get Sorted Bill Items by Posting Priority
    @return         List<BillItem__c>
    *******************************************************************************/
    private static List<BillItem__c> getSortedBillItemByPostingPriority(List<BillItem__c> billItemList) {
        Set<String> postingPrioritySet = new Set<String>();
        Map<String, List<BillItem__c>> billItemPriorityToBillItemsMap = new Map<String, List<BillItem__c>>();
        
        for(BillItem__c billItem : billItemList) {
            String postingPriority = billItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostPriority__c;
            if(billItemPriorityToBillItemsMap.keySet().isEmpty() || !billItemPriorityToBillItemsMap.containsKey(postingPriority)) {            
                billItemPriorityToBillItemsMap.put(postingPriority, new List<BillItem__c>{billItem});
            } else if(!billItemPriorityToBillItemsMap.keySet().isEmpty() && billItemPriorityToBillItemsMap.containsKey(postingPriority)){
                billItemPriorityToBillItemsMap.get(postingPriority).add(billItem);
            }
            
            postingPrioritySet.add(postingPriority);
        }
        
        // sorting the list in ascending order
        List<String> postingPriorityList = new List<String>(postingPrioritySet);
        postingPriorityList.sort();
        
        // building a list of sorted amended bill items by dates
        List<BillItem__c> sortedBillItemsByPostingPriority = new List<BillItem__c>();
        for(String postingPriority : postingPriorityList) {
            if(!billItemPriorityToBillItemsMap.keySet().isEmpty() && billItemPriorityToBillItemsMap.containsKey(postingPriority)) {
                sortedBillItemsByPostingPriority.addAll(billItemPriorityToBillItemsMap.get(postingPriority));
            }
        }
        
        return sortedBillItemsByPostingPriority;
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          List<BillItem__c> billItemList, Map<Date, List<BillItem__c>> billItemPriorityToBillItemsMap
    @description    Method to get Sorted Bill Items by Bill Date
    @return         void
    *******************************************************************************/
    private static void getSortedBillItemByBillDate(List<BillItem__c> billItemList, Map<Date, List<BillItem__c>> billItemPriorityToBillItemsMap) {
        Set<Date> billDateSet = new Set<Date>();
        
        for(BillItem__c billItem : billItemList) {
            //Date billDate = billItem.Bill__r.BillDate__c;
            Date billDate = billItem.StartDate__c; //AT-2702
            /*Changes for AT-2493 Starts here */
            /*
            if(billItemPriorityToBillItemsMap.keySet().isEmpty() || !billItemPriorityToBillItemsMap.containsKey(billDate)) {            
                billItemPriorityToBillItemsMap.put(billDate, new List<BillItem__c>{billItem});
            } else if(!billItemPriorityToBillItemsMap.keySet().isEmpty() && billItemPriorityToBillItemsMap.containsKey(billDate)){
                billItemPriorityToBillItemsMap.get(billDate).add(billItem);
            }*/
            if(!billItemPriorityToBillItemsMap.containsKey(billDate)) {
                billItemPriorityToBillItemsMap.put(billDate, new List<BillItem__c>{}); 	//AT-4363 - removed billItem from list
            }
            billItemPriorityToBillItemsMap.get(billDate).add(billItem);
            /*Changes for AT-2493 Ends here */
            billDateSet.add(billDate);
        }
        
        // sorting the list in ascending order
        List<Date> billDateList = new List<Date>(billDateSet);
        billDateList.sort();
        
        // building a list of sorted amended bill items by dates
        List<BillItem__c> sortedBillItemsByDate = new List<BillItem__c>();
        for(Date billDate : billDateList) {
            if(!billItemPriorityToBillItemsMap.keySet().isEmpty() && billItemPriorityToBillItemsMap.containsKey(billDate)) {
                sortedBillItemsByDate.addAll(billItemPriorityToBillItemsMap.get(billDate));
            }
        }
        
        billItemList = sortedBillItemsByDate;
        
        //return sortedBillItemsByDate;
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Set<Id> contractIdSet
    @description    Method to build Contract Id to Bill Items Map
    @return         Map<Id, List<BillItem__c>>
    *******************************************************************************/
    private static Map<Id, List<BillItem__c>> buildContractIdToBillItemsMap(Set<Id> contractIdSet, Map<Id,Id> mapOfContractIdToBalanceId) {
        // build contractIdToBillItemMap map
        Map<Id, List<BillItem__c>> contractIdToBillItemMap = new Map<Id, List<BillItem__c>>();
        List<BillItem__c> billItemListByContractIds = getBillItemsByContractIds(contractIdSet);
        system.debug('billItemListByContractIds:: ' + billItemListByContractIds) ;
        for(BillItem__c billItem : billItemListByContractIds) {
            
            if(!mapOfContractIdToBalanceId.containsKey(billItem.Bill__r.BillingContract__c)){
                mapOfContractIdToBalanceId.put(billItem.Bill__r.BillingContract__c,billItem.Bill__r.BillingContract__r.Balance__c);
            }
            /*Changes for AT-2493 Starts here*/
            /*
            if(contractIdToBillItemMap.keySet().isEmpty() && !contractIdToBillItemMap.containsKey(billItem.Bill__r.BillingContract__c)) {   // replaced Or with And
                contractIdToBillItemMap.put(billItem.Bill__r.BillingContract__c, new List<BillItem__c>{billItem});
            } else if(!contractIdToBillItemMap.keySet().isEmpty() && contractIdToBillItemMap.containsKey(billItem.Bill__r.BillingContract__c)) {
                contractIdToBillItemMap.get(billItem.Bill__r.BillingContract__c).add(billItem);
            } 
			*/
            if(!contractIdToBillItemMap.containsKey(billItem.Bill__r.BillingContract__c)) {
                contractIdToBillItemMap.put(billItem.Bill__r.BillingContract__c, new List<BillItem__c>{}); 	//AT-4363 - removed billItem from list
            }
            contractIdToBillItemMap.get(billItem.Bill__r.BillingContract__c).add(billItem);
            /*Changes for AT-2493 Ends here*/
        }
        system.debug('contractIdToBillItemMap:: ' + contractIdToBillItemMap) ;
        return contractIdToBillItemMap;
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           29 Oct 2018
    @param          Set<Id> locationIdSet
    @description    AT-3523, Method to build Location Id to Bill Items Map
    @return         Map<Id, List<BillItem__c>>
    *******************************************************************************/
    private static Map<Id, List<BillItem__c>> buildLocationIdToBillItemsMap(Set<Id> locationIdSet, Map<Id,Id> mapOfContractIdToBalanceId) {
        // build locationIdToBillItemMap map
        
        Map<Id, List<BillItem__c>> locationIdToBillItemMap = new Map<Id, List<BillItem__c>>();
        List<BillItem__c> billItemListByLocationsIds = getBillItemsByLocationIds(locationIdSet);
        system.debug('billItemListByLocationsIds:: ' + billItemListByLocationsIds) ;
        for(BillItem__c billItem : billItemListByLocationsIds) {
            
            if(!mapOfContractIdToBalanceId.containsKey(billItem.Bill__r.BillingContract__c)){
                mapOfContractIdToBalanceId.put(billItem.Bill__r.BillingContract__c,billItem.Bill__r.BillingContract__r.Balance__c);
            }
            
            if(locationIdToBillItemMap.keySet().isEmpty() && !locationIdToBillItemMap.containsKey(billItem.SupplyPoint__r.Location__c)) {   
                locationIdToBillItemMap.put(billItem.SupplyPoint__r.Location__c, new List<BillItem__c>{billItem});
            } else if(!locationIdToBillItemMap.keySet().isEmpty() && locationIdToBillItemMap.containsKey(billItem.SupplyPoint__r.Location__c)) {
                locationIdToBillItemMap.get(billItem.SupplyPoint__r.Location__c).add(billItem);
            } 
        }
        return locationIdToBillItemMap;
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Map<Id, List<Payment__c>> contractIdToPaymentsMap, List<Payment__c> paymentList, Set<Id> contractIdSet
    @description    Method to build Contract Id to Payments Map
    @return         Map<Id, List<Payment__c>>
    *******************************************************************************/
    private static Map<Id, List<Payment__c>> buildContractIdToPaymentsMap(Map<Id, List<Payment__c>> contractIdToPaymentsMap, Map<Id, List<Payment__c>> locationIdToPaymentsMap, List<Payment__c> paymentList, Set<Id> contractIdSet, Set<Id> locationIdSet) {
        //if(contractIdToPaymentsMap.keySet() != null && !contractIdToPaymentsMap.keySet().isEmpty()) {
        //    return contractIdToPaymentsMap;
        //}
        Map<String, Payment__c> contractPaymentIdMap = new Map<String, Payment__c>();
        if(contractIdToPaymentsMap.keySet() != null && !contractIdToPaymentsMap.keySet().isEmpty()) {
            for(Id contractId : contractIdToPaymentsMap.keySet()) {
                for(Payment__c paymentObj : contractIdToPaymentsMap.get(contractId)) {
                    contractPaymentIdMap.put(String.valueOf(contractId) + String.valueOf(paymentObj.Id), paymentObj);
                }
            }
        }

        // AT-3523, build locationPaymentIdMap to prevent duplicacy
        Map<String, Payment__c> locationPaymentIdMap = new Map<String, Payment__c>();
        if(locationPaymentIdMap.keySet() != null && !locationPaymentIdMap.keySet().isEmpty()) {
            for(Id locationId : locationPaymentIdMap.keySet()) {
                for(Payment__c paymentObj : contractIdToPaymentsMap.get(locationId)) {
                    locationPaymentIdMap.put(String.valueOf(locationId) + String.valueOf(paymentObj.Id), paymentObj);
                }
            }
        }
        
        for(Payment__c payment : paymentList) {
            if(payment.BillingContract__c != null) {
                contractIdSet.add(payment.BillingContract__c);
                // build contractIdToPaymentsMap map
                if(contractIdToPaymentsMap.keySet().isEmpty() || !contractIdToPaymentsMap.containsKey(payment.BillingContract__c)) {
                    contractIdToPaymentsMap.put(payment.BillingContract__c, new List<Payment__c>{payment});
                    contractPaymentIdMap.put(String.valueOf(payment.BillingContract__c) + String.valueOf(payment.Id), payment);
                } else if(!contractIdToPaymentsMap.keySet().isEmpty() && contractIdToPaymentsMap.containsKey(payment.BillingContract__c)) {
                    if(contractPaymentIdMap.keySet() == null || contractPaymentIdMap.keySet().isEmpty() 
                       || !contractPaymentIdMap.containsKey(String.valueOf(payment.BillingContract__c) + String.valueOf(payment.Id))) {
                           contractIdToPaymentsMap.get(payment.BillingContract__c).add(payment);
                       }
                } 
            }            
            else if(payment.Location__c != null){ // AT-3523, build locationIdToPaymentsMap and locationIdSet
                if(locationIdSet != null){
                    locationIdSet.add(payment.Location__c);                
                    if(locationIdToPaymentsMap.keySet().isEmpty() || !locationIdToPaymentsMap.containsKey(payment.Location__c)) {
                        locationIdToPaymentsMap.put(payment.Location__c, new List<Payment__c>{payment});
                        locationPaymentIdMap.put(String.valueOf(payment.Location__c) + String.valueOf(payment.Id), payment);
                    } else if(!locationIdToPaymentsMap.keySet().isEmpty() && locationIdToPaymentsMap.containsKey(payment.Location__c)) {
                        if(locationPaymentIdMap.keySet() == null || locationPaymentIdMap.keySet().isEmpty() 
                           || !locationPaymentIdMap.containsKey(String.valueOf(payment.Location__c) + String.valueOf(payment.Id))) {
                               locationIdToPaymentsMap.get(payment.Location__c).add(payment);
                           }
                    } 
                }
            }            
        }
        return contractIdToPaymentsMap;
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Set<Id> instalmentIdSet
    @description    Method to handle all instalments and their allocations
    @return         void
    *******************************************************************************/
    private static void handleAllInstalments(Set<Id> instalmentIdSet) {//Map<Id, String> instalmentIds) {
        // check if the instalment has been created or updated
        //Set<Id> updatedInstalmentIdSet = checkInsertedOrUpdatedInstalments(instalmentIds);
        //Set<Id> instalmentIdSet = instalmentIds.keySet();
        //Query for all related payment allocation records for the above updated Instalment Ids
        if(!instalmentIdSet.isEmpty()) {
            List<PaymentPlan__c> paymentPlanList = getPaymentPlansForInstalments(instalmentIdSet);
            // update the status of all related Payment Allocations to 'Reversed'
            if(!paymentPlanList.isEmpty()) {
                
                Set<Id> contractIdSet = new Set<Id>();
                for(PaymentPlan__c paymentPlan : paymentPlanList) {
                    contractIdSet.add(paymentPlan.BillingContract__c);//AT-3174
                }
                // map with Payment Id as key and payments as values
                Map<Id, Payment__c> paymentsMap = getPaymentsMapByContractIds(contractIdSet);
                mode = INSTALMENTSMODE;
                // call AllocatePayment with the set of Payment ids and the set the mode to ‘Instalments’
                List<PaymentAllocation__c> paymentAllocatedList = allocatePayment(paymentsMap.keySet());
                
            }
        }
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Set<Id> updatedInstalmentIdSet
    @description    Method to handle all instalments that have been updated
    @return         void
    *******************************************************************************/
    private static void handleInstalmentUpdates(Set<Id> updatedInstalmentIdSet) {//Map<Id, String> instalmentIds) {
        // check if the instalment has been updated - Instalment Amount or Date has been changed
        //Set<Id> updatedInstalmentIdSet = checkUpdatedInstalments(instalmentIds);
        //Set<Id> updatedInstalmentIdSet = instalmentIds.keySet();
        //Query for all related payment allocation records for the above updated Instalment Ids
        if(!updatedInstalmentIdSet.isEmpty()) {
            List<PaymentAllocation__c> reversePayAllocList = getPayAllocsForInstalments(updatedInstalmentIdSet);
            // update the status of all related Payment Allocations to 'Reversed'
            if(!reversePayAllocList.isEmpty()) {
                // map with Payment Id as key and List of related Payment Allocations as values
                Map<Id, List<PaymentAllocation__c>> paymentIdToPayAllocsMap = new Map<Id, List<PaymentAllocation__c>>();
                
                for(PaymentAllocation__c paymentAllocation : reversePayAllocList) {
                    paymentAllocation.Status__c = GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_REVERSED;
                    
                    if(paymentIdToPayAllocsMap.keySet() == null || paymentIdToPayAllocsMap.keySet().isEmpty() || !paymentIdToPayAllocsMap.containsKey(paymentAllocation.Payment__c)) {
                        paymentIdToPayAllocsMap.put(paymentAllocation.Payment__c, new List<PaymentAllocation__c>{paymentAllocation});
                    } else if(paymentIdToPayAllocsMap.containsKey(paymentAllocation.Payment__c)) {
                        paymentIdToPayAllocsMap.get(paymentAllocation.Payment__c).add(paymentAllocation);
                    }
                }
                
                // get a list of payments where Instalment Unallocated Amount needs to be updated
                List<Payment__c> paymentList = getPaymentListToUpdateOnInstalmentUpdate(paymentIdToPayAllocsMap);
                
                reversePayAllocList = (List<PaymentAllocation__c>) GlUt_FieldSecurity.cleanseFields(reversePayAllocList, false);
                // updating the status of all Payment Allocations
                update reversePayAllocList;
				
                system.debug('reversePayAllocList:: ' + reversePayAllocList) ;
                // updating the Instalment Unallocated Amounts on Payments
                if(!paymentList.isEmpty()) {
					paymentList = (List<Payment__c>) GlUt_FieldSecurity.cleanseFields(paymentList, false);
                    update paymentList;
                }
                
            }
        }
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Map<Id, List<PaymentAllocation__c>> paymentIdToPayAllocsMap
    @description    returns Payment list which needs to be updated when Instalments are updated
    @return         List<Payment__c>
    @usedby         handleInstalmentUpdates() method
    *******************************************************************************/
    
    private static List<Payment__c> getPaymentListToUpdateOnInstalmentUpdate(Map<Id, List<PaymentAllocation__c>> paymentIdToPayAllocsMap) {
        List<Payment__c> paymentUpdateList = new List<Payment__c>();
        
        Map<Id, Decimal> paymentIdToUnallocatedInstalmentAmtMap = new Map<Id, Decimal>();
        for(Id paymentId : paymentIdToPayAllocsMap.keySet()) {
            for(PaymentAllocation__c paymentAllocation : paymentIdToPayAllocsMap.get(paymentId)) {
                if(paymentIdToUnallocatedInstalmentAmtMap.keySet().isEmpty() || !paymentIdToUnallocatedInstalmentAmtMap.containsKey(paymentId)) {
                    paymentIdToUnallocatedInstalmentAmtMap.put(paymentId, paymentAllocation.AmountAllocated__c);
                } else if(paymentIdToUnallocatedInstalmentAmtMap.containsKey(paymentId)){
                    Decimal allocatedAmount = paymentIdToUnallocatedInstalmentAmtMap.get(paymentId) + paymentAllocation.AmountAllocated__c;
                    paymentIdToUnallocatedInstalmentAmtMap.remove(paymentId);
                    // sum up InstalmentUnallocatedAmount__c field for the payment Id
                    paymentIdToUnallocatedInstalmentAmtMap.put(paymentId, allocatedAmount);
                }
            }
            
        }
        
        List<Payment__c> paymentList = getPaymentsByIds(paymentIdToPayAllocsMap.keySet());
        for(Payment__c payment : paymentList) {
            if(!paymentIdToUnallocatedInstalmentAmtMap.keySet().isEmpty() && paymentIdToUnallocatedInstalmentAmtMap.containsKey(payment.Id)) {
                paymentUpdateList.add(new Payment__c(Id = payment.Id, 
                                                     InstalmentAmountUnallocated__c = paymentIdToUnallocatedInstalmentAmtMap.get(payment.Id),
                                                     InstalmentAllocationAmount__c = payment.Amount__c - paymentIdToUnallocatedInstalmentAmtMap.get(payment.Id)));
            }
        }
        return paymentUpdateList; 
    }
    
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Map<Id, List<PaymentAllocation__c>> paymentIdToPayAllocsMap
    @description    returns Payment list which needs to be revesed when amount reversal criteria is met.
    @return         List<Payment__c>
    @usedby         processBill() method
    *******************************************************************************/
    private static List<Payment__c> getPaymentListToUpdateOnAmountReversal(Map<Id, List<PaymentAllocation__c>> paymentIdToPayAllocsMap) {
        List<Payment__c> paymentUpdateList = new List<Payment__c>();
        
        Map<Id, Decimal> paymentIdToUnallocatedInstalmentAmtMap = new Map<Id, Decimal>();
        for(Id paymentId : paymentIdToPayAllocsMap.keySet()) {
            for(PaymentAllocation__c paymentAllocation : paymentIdToPayAllocsMap.get(paymentId)) {
                if(paymentIdToUnallocatedInstalmentAmtMap.keySet().isEmpty() || !paymentIdToUnallocatedInstalmentAmtMap.containsKey(paymentId)) {
                    paymentIdToUnallocatedInstalmentAmtMap.put(paymentId, paymentAllocation.AmountAllocated__c);
                } else if(paymentIdToUnallocatedInstalmentAmtMap.containsKey(paymentId)){
                    Decimal allocatedAmount = paymentIdToUnallocatedInstalmentAmtMap.get(paymentId) + paymentAllocation.AmountAllocated__c;
                    paymentIdToUnallocatedInstalmentAmtMap.remove(paymentId);
                    // sum up InstalmentUnallocatedAmount__c field for the payment Id
                    paymentIdToUnallocatedInstalmentAmtMap.put(paymentId, allocatedAmount);
                }
            }
            
        }
        
        List<Payment__c> paymentList = getPaymentsByIds(paymentIdToPayAllocsMap.keySet());
        // setting the Bill Amount allocated and and unallocated fields on payment
        for(Payment__c payment : paymentList) {
            if(!paymentIdToUnallocatedInstalmentAmtMap.keySet().isEmpty() && paymentIdToUnallocatedInstalmentAmtMap.containsKey(payment.Id)) {
                /*Changes for AT-2493 Starts here*/
                paymentUpdateList.add(new Payment__c(Id = payment.Id, 
                                                     BillAmountUnallocated__c = paymentIdToUnallocatedInstalmentAmtMap.get(payment.Id),
                                                     BillAllocationStatus__c =  (payment.Amount__c - paymentIdToUnallocatedInstalmentAmtMap.get(payment.Id)) > 0 ? GlUt_Constants.PAYMENTALLOCATION_BILLALLOCATIONSTATUS_PARTIALLY : GlUt_Constants.PAYMENTALLOCATION_BILLALLOCATIONSTATUS_NONE,
                                                     BillAllocationAmount__c =  payment.Amount__c - paymentIdToUnallocatedInstalmentAmtMap.get(payment.Id)));
              /*Changes for AT-2493 Ends here*/
            } 
        }
        return paymentUpdateList;
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Set<Id> paymentIdSet
    @description    returns all Payments by Payment Ids, ordered by Payment Date in ascending order 
    @return         List<Payment__c>
    @revision       Echo: Sudhir Kumar
                    AT-2873: For Goodwill Payment, the allocation related fields will not be populated and no allocation will be effected. 
                         -> In the current code, Goodill record type is not being fetched and hence no processAllocation will happen for them.
                         -> Once the goodwill payment is approved, the 2nd Payment with recordtype as 'Payment' will undergo processAllocation.
    *******************************************************************************/
    private static List<Payment__c> getPaymentsForBillItems(Set<Id> paymentIdSet) {
        // AT-3523, retrieve the Location__c field from Payment__c object
        return [SELECT Id, BillingContract__c, 
                Location__c,
                InstalmentAllocationAmount__c,
                InstalmentAmountUnallocated__c, 
                BillAmountUnallocated__c,
                BillAllocationAmount__c,
                Amount__c,
                CreditAmount__c
                FROM Payment__c
                WHERE Id IN :paymentIdSet AND BillAllocationStatus__c != :GlUt_Constants.PAYMENTALLOCATION_BILLALLOCATIONSTATUS_FULLY 
                AND RecordType.DeveloperName = :GlUt_Constants.PAYMENT_RECORDTYPE_PAYMENT 
                ORDER BY PaymentDate__c ASC NULLS LAST];
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Set<Id> paymentIdSet
    @description    returns all Payments by Payment Ids, ordered by Payment Date in ascending order 
    @return         List<Payment__c>
    @revision       Echo: Sudhir Kumar
                    AT-2873: (1). If the Payment is marked as ‘Do Not Allocate to Instalments’, set Instalment Amount Unallocated to 0 
                    to ensure that this Payment is not allocated against Instalment records.
                    (2). For Goodwill Payment, the allocation related fields will not be populated and no allocation will be effected. 
                         -> In the current code, Goodill record type is not being fetched and hence no processAllocation will happen for them.
                         -> Once the goodwill payment is approved, the 2nd Payment with recordtype as 'Payment' will undergo processAllocation.
    *******************************************************************************/
    private static List<Payment__c> getPaymentsForInstalments(Set<Id> paymentIdSet) {
        return [SELECT Id, BillingContract__c, Location__c, InstalmentAllocationAmount__c, InstalmentAmountUnallocated__c, BillAmountUnallocated__c, BillAllocationAmount__c, Amount__c, 
                CreditAmount__c, DoNotAllocatetoInstalments__c  // AT-2873
                
                FROM Payment__c
                WHERE Id IN :paymentIdSet AND InstalmentAllocationStatus__c != :GlUt_Constants.PAYMENTALLOCATION_BILLALLOCATIONSTATUS_FULLY
                AND RecordType.DeveloperName = :GlUt_Constants.PAYMENT_RECORDTYPE_PAYMENT
                AND DoNotAllocatetoInstalments__c = false   // AT-2873
                ORDER BY PaymentDate__c ASC NULLS LAST];
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Set<Id> paymentIdSet
    @description    returns all Bill Items by Contact Ids, ordered by Bill Date in ascending order 
    @return         List<Payment__c>
    *******************************************************************************/
    private static List<BillItem__c> getBillItemsByContractIds(Set<Id> contractIdSet) {
        //return [SELECT Id, BillItem__c, Bill__c, Bill__r.BillingContract__c, Bill__r.BillDate__c, ServiceItem__c,  // PostingPriority__c Field doesn't exist
        return [SELECT Id, BillItem__c, Bill__c, Bill__r.BillingContract__c, SupplyPoint__c, SupplyPoint__r.Location__c, Bill__r.BillingContract__r.Balance__c, StartDate__c, ServiceItem__c,          
                ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostPriority__c,
                ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostCategory__c,
                AmountOutstanding__c, AmountPaid__c, NetBilledAmount__c,ReplacedbyNewBillItems__c //AT-2493 Starts/Ends here
                FROM BillItem__c
                WHERE Bill__r.BillingContract__c IN :contractIdSet AND AmountOutstanding__c > 0
                AND Bill__r.BillType__c = 'Normal' //AT-2495
                ORDER BY Bill__r.BillingContract__c ASC, // Need to check if we need this sorting
                //ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostCategory__c ASC NULLS LAST, Bill__r.BillDate__c ASC NULLS LAST, ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostPriority__c ASC NULLS LAST];
                ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostCategory__c ASC NULLS LAST, StartDate__c ASC NULLS LAST, ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostPriority__c ASC NULLS LAST]; //AT-2702
    }
    
    /******************************************************************************
    @author         Echo : Ankit Gangwani
    @date           29 Oct 2018
    @param          Set<Id> locationIdSet
    @description    AT-3523, returns all Bill Items by Location Ids, ordered by Bill Date in ascending order 
    @return         List<BillItem__c>
    *******************************************************************************/
    private static List<BillItem__c> getBillItemsByLocationIds(Set<Id> locationIdSet) {
        return [SELECT Id, BillItem__c, Bill__c, Bill__r.BillingContract__c, Bill__r.BillingContract__r.Balance__c, SupplyPoint__r.Location__c, StartDate__c, ServiceItem__c,          
                ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostPriority__c,
                ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostCategory__c,
                AmountOutstanding__c, AmountPaid__c, NetBilledAmount__c,ReplacedbyNewBillItems__c // AT-5261, Added ReplacedbyNewBillItems__c field related to AT-2493
                FROM BillItem__c
                WHERE SupplyPoint__r.Location__c IN :locationIdSet AND AmountOutstanding__c > 0
                AND Bill__r.BillType__c = 'Normal' //AT-2495
                ORDER BY Bill__r.BillingContract__c ASC, // Need to check if we need this sorting
                ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostCategory__c ASC NULLS LAST, StartDate__c ASC NULLS LAST, ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.PaymentPostPriority__c ASC NULLS LAST]; //AT-2702
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Set<Id> instalmentIdSet
    @description    returns all Payment Allocations related to the Instalments where the Status needs to be Reversed 
    @return         List<PaymentAllocation__c>
    *******************************************************************************/
    private static List<PaymentAllocation__c> getPayAllocsForInstalments(Set<Id> instalmentIdSet) {
        return [SELECT Id, Status__c, Payment__c, AmountAllocated__c, Instalment__c, Instalment__r.SumofAllocatedPayment__c
                FROM PaymentAllocation__c
                WHERE Instalment__c IN :instalmentIdSet
                AND Status__c != :GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_REVERSED
                AND Payment__r.RecordType.DeveloperName = :GlUt_Constants.PAYMENT_RECORDTYPE_PAYMENT];
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Set<Id> billItemIdSet
    @description    returns all Payment Allocations related to the Bill Items where the Status needs to be Reversed 
    @return         List<PaymentAllocation__c>
    *******************************************************************************/
    private static List<PaymentAllocation__c> getPayAllocsForBillItems(Set<Id> billItemIdSet) {
        return [SELECT Id, Status__c, Payment__c, AmountAllocated__c, BillItem__c 
                FROM PaymentAllocation__c
                WHERE BillItem__c IN :billItemIdSet
                AND Status__c != :GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_REVERSED
                AND Payment__r.RecordType.DeveloperName = :GlUt_Constants.PAYMENT_RECORDTYPE_PAYMENT];
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Set<Id> paymentIdSet
    @description    returns all Payments with BillAmountUnallocated, filtered down by payment ids 
    @return         List<Payment__c>
    *******************************************************************************/
    private static List<Payment__c> getPaymentsByIds(Set<Id> paymentIdSet) {
        return [SELECT Id, BillAmountUnallocated__c, BillAllocationAmount__c, InstalmentAmountUnallocated__c, InstalmentAllocationAmount__c, Amount__c, CreditAmount__c
                FROM Payment__c
                WHERE Id IN :paymentIdSet AND RecordType.DeveloperName = :GlUt_Constants.PAYMENT_RECORDTYPE_PAYMENT];
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Set<Id> billIdSet
    @description    returns all Bill Items, Amended Bill Items (Parent) and the associated Contracts, filtered down by bill ids 
    @return         List<BillItem__c>
    *******************************************************************************/
    private static List<BillItem__c> getBillItemsByIds(Set<Id> billIdSet) {
        //return [SELECT Id, BillItem__c, BillItem__r.Bill__c, Bill__c, Bill__r.BillingContract__c, Bill__r.BillDate__c, BillItem__r.Bill__r.BillingContract__c, NetBilledAmount__c, AmountOutstanding__c, AmountPaid__c
        return [SELECT Id, BillItem__c, BillItem__r.Bill__c, Bill__c, Bill__r.BillingContract__c, SupplyPoint__c, SupplyPoint__r.Location__c, StartDate__c, BillItem__r.Bill__r.BillingContract__c, NetBilledAmount__c, AmountOutstanding__c, AmountPaid__c         //AT-2702
                FROM BillItem__c
                WHERE Id IN :billIdSet AND ServiceItem__r.Service__r.SupplyPoint__r.Disputed__c = false];//Added extra condition for Disputed S.P as per AT-3248 starts/Ends Here.
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Set<Id> contractIdSet
    @description    returns the payments map where InstalmentAmountUnallocated__c > 0 or 
                    BillAmountUnallocated__c > 0, and filter it by BillingContract__c
                    ordered by Payment Date ascending 
    @return         Map<Id, Payment__c>
    *******************************************************************************/
    private static Map<Id, Payment__c> getPaymentsMapByContractIds(Set<Id> contractIdSet) {
        
        return new Map<Id, Payment__c>([SELECT Id, InstalmentAmountUnallocated__c, BillAmountUnallocated__c, BillAllocationAmount__c, InstalmentAllocationAmount__c, Amount__c, CreditAmount__c
                                        FROM Payment__c
                                        // where the ‘Instalment Amount Unallocated’ > 0 or the ‘Bill Unallocated Amount’ related to the set of Contract ids 
                                        WHERE ((InstalmentAmountUnallocated__c > 0 OR BillAmountUnallocated__c > 0) AND BillingContract__c IN :contractIdSet)
                                        AND RecordType.DeveloperName = :GlUt_Constants.PAYMENT_RECORDTYPE_PAYMENT
                                        ORDER BY PaymentDate__c ASC NULLS LAST]); // Old payments first - confirm if it's ascending or descending order
    }
    
    /******************************************************************************
    @author         Echo : Ankit Gangwani
    @date           01 Nov 2018
    @param          Set<Id> locationIdSet
    @description    returns the payments map where InstalmentAmountUnallocated__c > 0 or 
                    BillAmountUnallocated__c > 0, and filter it by Location__c
                    ordered by Payment Date ascending 
    @return         Map<Id, Payment__c>
    *******************************************************************************/
    private static Map<Id, Payment__c> getPaymentsMapByLocationIds(Set<Id> locationIdSet) {
        
        return new Map<Id, Payment__c>([SELECT Id, 
                                        InstalmentAmountUnallocated__c, 
                                        BillAmountUnallocated__c, 
                                        BillAllocationAmount__c,
                                        InstalmentAllocationAmount__c,
                                        Amount__c, 
                                        CreditAmount__c
                                        FROM Payment__c
                                        WHERE ((InstalmentAmountUnallocated__c > 0 OR BillAmountUnallocated__c > 0) AND Location__c IN :locationIdSet)
                                        AND RecordType.DeveloperName = :GlUt_Constants.PAYMENT_RECORDTYPE_PAYMENT
                                        ORDER BY PaymentDate__c ASC NULLS LAST]); // Old payments first - confirm if it's ascending or descending order
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           16 Jan 2018
    @param          Set<Id> instalmentIdSet
    @description    returns all Payment Plans with their Contracts, who are associated to the Instalments 
    @return         List<PaymentPlan__c>
    *******************************************************************************/
    private static List<PaymentPlan__c> getPaymentPlansForInstalments(Set<Id> instalmentIdSet) {
        
        return [SELECT Id, BillingContract__c //AT-3174
                FROM PaymentPlan__c
                WHERE Id IN (SELECT PaymentPlan__c
                             FROM Instalment__c 
                             WHERE Id IN :instalmentIdSet)
                AND BillingContract__c != NULL]; //AT-3174
        
    }  
}