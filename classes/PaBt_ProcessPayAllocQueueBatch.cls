/******************************************************************************
@author         Accenture: Pratyush Kumar (Accenture)
@date           16 Jan 2018
@description    Batch class to process instalments and bills from the  
				Payment Allocation Queue and allocate payments
@revesion		AT-2719 - fix - implemented Database.Stateful to the batch
*******************************************************************************/
global with sharing class PaBt_ProcessPayAllocQueueBatch implements Schedulable, Database.Batchable<sObject>, Database.Stateful{
    private final String query;
    global Map<Id, String> instalmentIdMap = new Map<Id, String>();
    global Map<Id, String> billItemIdMap = new Map<Id, String>();
    /******************************************************************************
@author         Accenture: Pratyush Kumar (Accenture)
@date           12 Feb 2018
@description    Constructor to set Query string
*******************************************************************************/
    global PaBt_ProcessPayAllocQueueBatch() {
        /*query = 'SELECT Id, Instalment__c, Instalment__r.InstalmentAmountOutstanding__c, Payment__c, BillItem__c, BillItem__r.AmountOutstanding__c, Operation__c'
                    + ' FROM PaymentAllocationQueue__c'
                    + ' WHERE ((Instalment__c != null AND Instalment__r.InstalmentAmountOutstanding__c > 0) OR (BillItem__c != null AND BillItem__r.AmountOutstanding__c > 0))'
                    + ' ORDER BY CreatedDate ASC, Instalment__c ASC NULLS LAST, BillItem__c ASC NULLS LAST, Payment__c ASC NULLS LAST';*/
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           12 Feb 2018
    @description    Scheduler's execute method
    *******************************************************************************/
    global void execute(SchedulableContext sc) {
        database.executebatch(this, 200);
    }
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)

    @date           12 Feb 2018
    @description    Batch's start method
    *******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        system.debug(' results : '+ [SELECT Id, Instalment__c, Instalment__r.InstalmentAmountOutstanding__c, Payment__c, BillItem__c, 
                                         BillItem__r.AmountOutstanding__c, Operation__c FROM PaymentAllocationQueue__c
                                         WHERE ((Instalment__c != null AND Instalment__r.InstalmentAmountOutstanding__c > 0) OR 
                                                (BillItem__c != null AND BillItem__r.AmountOutstanding__c > 0)) ORDER BY CreatedDate ASC, 
                                         Instalment__c ASC NULLS LAST, BillItem__c ASC NULLS LAST, Payment__c ASC NULLS LAST] );
        return Database.getQueryLocator([SELECT Id, Instalment__c, Instalment__r.InstalmentAmountOutstanding__c, Payment__c, BillItem__c, 
                                         BillItem__r.AmountOutstanding__c, Operation__c FROM PaymentAllocationQueue__c
                                         WHERE ((Instalment__c != null AND Instalment__r.InstalmentAmountOutstanding__c > 0) OR 
                                                (BillItem__c != null AND BillItem__r.AmountOutstanding__c > 0)) ORDER BY CreatedDate ASC, 
                                         Instalment__c ASC NULLS LAST, BillItem__c ASC NULLS LAST, Payment__c ASC NULLS LAST]);
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           12 Feb 2018
    @description    Batch's execute method
    Creates a Map of all Bill Items and Instalments that needs to
    be processed and allocated
	*******************************************************************************/
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug('SK-PaBt_ProcessPayAllocQueueBatch-scope= ' + scope);
        // get all the payment allocation queue records which haven't been processed
        List<PaymentAllocationQueue__c> paymentAllocationList = (List<PaymentAllocationQueue__c>) scope;
        //AT-2719 -- removed instalmentIdMap,billItemIdMap declaration as part of fix
        for(PaymentAllocationQueue__c paymentAllocation : paymentAllocationList) {
            String operation = paymentAllocation.Operation__c == null ? GlUt_Constants.PAYMENTALLOCATIONQUEUE_OPERATION_INSERT : paymentAllocation.Operation__c;
            
            if(paymentAllocation.Instalment__c != null && paymentAllocation.Instalment__r.InstalmentAmountOutstanding__c > 0
               && (instalmentIdMap.keySet() == null || instalmentIdMap.keySet().isEmpty() || !instalmentIdMap.containsKey(paymentAllocation.Instalment__c))) {
                   
                   instalmentIdMap.put(paymentAllocation.Instalment__c, operation);
               }
            
            if(paymentAllocation.BillItem__c != null && paymentAllocation.BillItem__r.AmountOutstanding__c > 0
               && (billItemIdMap.keySet() == null || billItemIdMap.keySet().isEmpty() || !billItemIdMap.containsKey(paymentAllocation.BillItem__c))) {
                   
                   billItemIdMap.put(paymentAllocation.BillItem__c, operation);
               }
        }
        system.debug('SK-PaBt_ProcessPayAllocQueueBatch-billItemIdMap= ' + billItemIdMap);
        system.debug('SK-PaBt_ProcessPayAllocQueueBatch-instalmentIdMap= ' + instalmentIdMap);
        if(!billItemIdMap.keySet().isEmpty()) {
            PaUt_ProcessPaymentAllocation.processBill(billItemIdMap);
        }
        
        if(!instalmentIdMap.keySet().isEmpty()) {
            PaUt_ProcessPaymentAllocation.processInstalment(instalmentIdMap);
        }
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           12 Feb 2018
    @description    Batch's final method which is empty
    *******************************************************************************/
    global void finish(Database.BatchableContext BC){
        
    }
}