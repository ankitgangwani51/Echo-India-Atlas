/******************************************************************************
@author         Accenture: Pratyush Kumar (Accenture)
@date           16 Jan 2018
@description    Handler for Instalment trigger
*******************************************************************************/
public with sharing class GlUt_InstalmentHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_InstalmentHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    List<PaymentAllocationQueue__c> paymentAllocationQueueList;
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           17 Jan 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {
        paymentAllocationQueueList = new List<PaymentAllocationQueue__c>(); 
        
        try {            
            if (inputParam.isInsert && inputParam.isAfter) {
                // creates Payment Allocation Queue records when Instalments are created
                createPaymentAllocationQueues(inputParam.newlist, null);
            }
            
            if (inputParam.isUpdate && inputParam.isAfter) {
                // creates Payment Allocation Queue records when Instalments haven't been processed
                 createPaymentAllocationQueues(inputParam.newlist, inputParam.oldmap);
                 updateDebtRecoveryInstalmentAmountDue((Map<Id,Instalment__c>) inputParam.oldmap, (Map<Id,Instalment__c>) inputParam.newmap);

            }
            
            if (inputParam.isDelete && inputParam.isBefore) {
            }
            
            if (inputParam.isDelete && inputParam.isAfter) {
            }
            
        } catch (exception e) {

            GlUt_Logger.logException(e);
        }

        finally {
            
            // insert the related payment allocation queue records 
            if (!paymentAllocationQueueList.isEmpty()) {
                paymentAllocationQueueList = (List<PaymentAllocationQueue__c>) GlUt_FieldSecurity.cleanseFields(paymentAllocationQueueList, false);
                insert paymentAllocationQueueList;
            }
            
            // Reset the active function to null in case this class was first in stack
            // this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar
    @date           17 Jan 2018
    @param          List<SObject> newlist - trigger.new
    @param          Map<Id, SObject> oldMap - trigger.oldMap
    @description    Inserts/Updates the related Payment Allocation Queue records 
                    when Instalments are inserted/updated
    *******************************************************************************/
    private void createPaymentAllocationQueues(List<SObject> newlist, Map<Id, SObject> oldMap) {
        Boolean isInsert = (oldmap == null);
        paymentAllocationQueueList = new List<PaymentAllocationQueue__c>(); 
        Set<Id> instalmentIdSet = new Set<Id>();
        for (Instalment__c instalment : (List<Instalment__c>) newlist) {
            if (isInsert) {
                paymentAllocationQueueList.add(buildPaymentAllocationQueue(instalment.Id, GlUt_Constants.PAYMENTALLOCATIONQUEUE_OPERATION_INSERT));

            } else if (instalment.InstalmentAmountDue__c != ((Instalment__c) oldMap.get(instalment.Id)).InstalmentAmountDue__c
                         || instalment.SumofAllocatedPayment__c != ((Instalment__c) oldMap.get(instalment.Id)).SumofAllocatedPayment__c
                         || instalment.InstalmentDueDate__c != ((Instalment__c) oldMap.get(instalment.Id)).InstalmentDueDate__c) {
               // CONFIRM - if this needs to be executed when Instalment Amount or Date has changed?
               instalmentIdSet.add(instalment.Id);
            }
        }
        
        if (!isInsert && !instalmentIdSet.isEmpty()) {
            buildPaymentAllocationQueueListForUpdate(paymentAllocationQueueList, instalmentIdSet, newlist, isInsert);
        }
        
        System.debug('paymentAllocationQueueList: ' + paymentAllocationQueueList);        
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           17 Jan 2018
    @param          List<PaymentAllocationQueue__c> paymentAllocationQueueList
    @param          Set<Id> instalmentIdSet
    @param          List<SObject> newlist
    @param          Boolean isInsert
    @description    This method builds the Payment Allocation Queue List for Update Operation
    *******************************************************************************/
    private void buildPaymentAllocationQueueListForUpdate(List<PaymentAllocationQueue__c> paymentAllocationQueueList,
                                                          Set<Id> instalmentIdSet,
                                                          List<SObject> newlist,
                                                          Boolean isInsert) {
       if (!instalmentIdSet.isEmpty()) {
           List<PaymentAllocationQueue__c> existingPaymentAllocationQueueList = [SELECT Id, Instalment__c, Status__c, Operation__c
                                                                                 FROM PaymentAllocationQueue__c
                                                                                 WHERE Instalment__c IN :instalmentIdSet
                                                                                 AND Status__c = :GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_PROCESSSED];
           
			Map<Id, PaymentAllocationQueue__c> instalmentIdToPaymentAllcMap = new Map<Id, PaymentAllocationQueue__c>();                                              
			for (PaymentAllocationQueue__c existingPaymentAllocationQueue : existingPaymentAllocationQueueList) {
				if (instalmentIdToPaymentAllcMap.keySet() == null 
               			|| instalmentIdToPaymentAllcMap.keySet().isEmpty() 
               			|| !instalmentIdToPaymentAllcMap.containsKey(existingPaymentAllocationQueue.Instalment__c)) {
					instalmentIdToPaymentAllcMap.put(existingPaymentAllocationQueue.Instalment__c, existingPaymentAllocationQueue);
				}
			}
           
			for (Instalment__c instalment : (List<Instalment__c>) newlist) {
				if (!isInsert && (instalmentIdToPaymentAllcMap.keySet() == null 
						|| instalmentIdToPaymentAllcMap.keySet().isEmpty() 
            			|| !instalmentIdToPaymentAllcMap.containsKey(instalment.Id))) {
					paymentAllocationQueueList.add(buildPaymentAllocationQueue(instalment.Id, GlUt_Constants.PAYMENTALLOCATIONQUEUE_OPERATION_UPDATE));
            	}
        	}
		}
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar (Accenture)
    @date           17 Jan 2018
    @param          Id instalmentId 
	@param          String operation
    @description    This method builds the Payment Allocation Queue object
    *******************************************************************************/
    private PaymentAllocationQueue__c buildPaymentAllocationQueue(Id instalmentId, String operation) {
        PaymentAllocationQueue__c paymentAllocationQueue = new PaymentAllocationQueue__c();
        paymentAllocationQueue.Instalment__c = instalmentId; // need to also check scenario when there's bill item amendments?
        paymentAllocationQueue.Status__c = GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_NEW;
        paymentAllocationQueue.Operation__c = operation; // Need to check if it will always be 'Insert'
        
        return paymentAllocationQueue;
    } 
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           21 Aug 2018
    @param          Map<Id,Instalment__c> oldMap map of object old values
                    Map<Id,Instalment__c> newMap map of object new values
	@return         null
    @description    AT - 3429 monitor the changes done in sum of allocated payment field or 
                    instalment amount due field of instalment in update context
    *******************************************************************************/
    private void updateDebtRecoveryInstalmentAmountDue(Map<Id,Instalment__c> oldMap, Map<Id,Instalment__c> newMap){
        Map<Id,Instalment__c> mapOfInstalmentIdToRecord = new Map<Id,Instalment__c>();
        
        system.debug('oldMap***'+ oldMap);
        system.debug('newMap***'+ newMap);
        
        if(oldMap != Null && !oldMap.keySet().isEmpty() && newMap != Null && !newMap.keySet().isEmpty()){
            for(Instalment__c objInstalment : newMap.values()){
                if(oldMap.get(objInstalment.Id).SumofAllocatedPayment__c != objInstalment.SumofAllocatedPayment__c || 
                   oldMap.get(objInstalment.Id).InstalmentAmountDue__c != objInstalment.InstalmentAmountDue__c){
                       mapOfInstalmentIdToRecord.put(objInstalment.Id,objInstalment);
                }
            }
        }
        
        system.debug('mapOfInstalmentIdToRecord***'+ mapOfInstalmentIdToRecord);
        
        if(!mapOfInstalmentIdToRecord.isEmpty()){
            List<DebtRecoveryInstalment__c> lstDebtRecoveryInstalment = new List<DebtRecoveryInstalment__c>();
            for(DebtRecoveryInstalment__c objDebtRecoveryInstalment : [SELECT Id, Instalment__c, InstalmentAmountDue__c FROM DebtRecoveryInstalment__c WHERE Instalment__c IN :mapOfInstalmentIdToRecord.keySet()]){
                if(mapOfInstalmentIdToRecord != Null && !mapOfInstalmentIdToRecord.keySet().isEmpty() && mapOfInstalmentIdToRecord.containsKey(objDebtRecoveryInstalment.Instalment__c)){
                    if(mapOfInstalmentIdToRecord.get(objDebtRecoveryInstalment.Instalment__c).SumofAllocatedPayment__c != Null){
                           objDebtRecoveryInstalment.InstalmentAmountDue__c = mapOfInstalmentIdToRecord.get(objDebtRecoveryInstalment.Instalment__c).InstalmentAmountDue__c    //AT-4112
                                                                              - mapOfInstalmentIdToRecord.get(objDebtRecoveryInstalment.Instalment__c).SumofAllocatedPayment__c;
                           lstDebtRecoveryInstalment.add(objDebtRecoveryInstalment);
                       }
                }
            }
            system.debug('lstDebtRecoveryInstalment***'+ lstDebtRecoveryInstalment);
            if(!lstDebtRecoveryInstalment.isEmpty()){
                lstDebtRecoveryInstalment  = (List<DebtRecoveryInstalment__c>) GlUt_FieldSecurity.cleanseFields(lstDebtRecoveryInstalment, false);
                Database.update(lstDebtRecoveryInstalment);
            }
                
        }
    }
}