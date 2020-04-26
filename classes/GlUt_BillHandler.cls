/******************************************************************************
@author         Accenture: Patrick Dixon
@date           21 Sep 2017
@description    Handler for Bill trigger
@Revisions      31-May-2018 Tarun , AT-2482 , To Update associated BillEvent records to processed & To update Balance Snapshot.
@Revisions      07-June-2018 Tarun , AT-2732 , To Update NextScheduledBillDate on contract.
@Revisions		03-Aug-2018, AT-3257 , If Transferred Contract field value is changed from null, then create two BT records for new and old contract
                AT-4891/2 Code Check Marx Changes for FLS INSERT/UPDATE
*******************************************************************************/
public with sharing class GlUt_BillHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_BillHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    // Maps of the related records that will be updated by this trigger
    Map<Id, BillingContract__c> contractsToUpdate;
    Map<Id, BillCalculation__c> billCalculationsToUpdate;
    
    Map<Id, BillEvent__c> billEventsToUpdate;
    Map<Id, Balance__c> balancesToUpdate;
    Map<Id, BalanceTransaction__c> balanceTransactionsToUpdate;
    
    List<BalanceTransaction__c> listTransferBillBalanceTransaction;
    
    private static final String BTRecordTypeIdBillTransfer = Schema.SObjectType.BalanceTransaction__c.getRecordTypeInfosByName().get('Bill Transfer').getRecordTypeId();
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           21 Sep 2017
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void MainEntry(GlUt_TriggerHandlerObj inputParam) {
        
        // initialise related records maps
        contractsToUpdate = new Map<Id, BillingContract__c>();
        billCalculationsToUpdate = new Map<Id, BillCalculation__c>();
        billEventsToUpdate = new Map<Id, BillEvent__c>();
        balancesToUpdate = new Map<Id, Balance__c>();
		balanceTransactionsToUpdate = new Map<Id, BalanceTransaction__c>();
        listTransferBillBalanceTransaction = new List<BalanceTransaction__c>();
        
        try {           
            /* This is a Heroku mastered object so we shouldn't be modifying any fields on it */
            /* Therfore before Insert/Update triggers not required */
            if (inputParam.isInsert && inputParam.isAfter) {

                // update fields on related records
                updateRelatedRecords(inputParam.newmap);
                updateBillEventRecords(inputParam.newmap);
            }
            if (inputParam.isUpdate && inputParam.isAfter) {
                
                updateBalanceSnapshot(inputParam.newlist, inputParam.oldmap);		// AT-2482
                updateBalanceTransactions(inputParam.newlist, inputParam.oldmap);
                //createBalanceTransactions(inputParam.newlist, inputParam.oldmap);//AT-4053- Commented By Dependra
            }
            if (inputParam.isDelete && inputParam.isBefore) {
            }
            if (inputParam.isDelete && inputParam.isAfter) {
            }
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            GlUt_Logger.writeLogsToDatabase();
            
        }
        
        finally {
            
            // update the related records
            //AT-4891/2 Code Check Marx Changes Starts Here.
            if (!contractsToUpdate.isEmpty()){
                List<BillingContract__c> billingContractsToUpdateList = new  List<BillingContract__c>();
                billingContractsToUpdateList = (List<BillingContract__c>) GlUt_FieldSecurity.cleanseFields(contractsToUpdate.values(), false); 
                update billingContractsToUpdateList;
            }
            if (!billCalculationsToUpdate.isEmpty()){
                List<BillCalculation__c> billCalcToUpdateList = new  List<BillCalculation__c>();
                billCalcToUpdateList = (List<BillCalculation__c>) GlUt_FieldSecurity.cleanseFields(billCalculationsToUpdate.values(), false); 
                update billCalcToUpdateList;
            } 
            if (!billEventsToUpdate.isEmpty()){
                List<BillEvent__c> billEventsToUpdateList = new  List<BillEvent__c>();
                billEventsToUpdateList = (List<BillEvent__c>) GlUt_FieldSecurity.cleanseFields(billEventsToUpdate.values(), false); 
                update billEventsToUpdateList;
            } 
            if (!balancesToUpdate.isEmpty()){
                 List<Balance__c> balancesToUpdateList = new  List<Balance__c>();
                 balancesToUpdateList = (List<Balance__c>) GlUt_FieldSecurity.cleanseFields(balancesToUpdate.values(), false); 
                 update balancesToUpdateList;
            }
            if (!balanceTransactionsToUpdate.isEmpty()){
                 List<BalanceTransaction__c> balanceTransactionsToUpdateList = new  List<BalanceTransaction__c>();
                 balanceTransactionsToUpdateList = (List<BalanceTransaction__c>) GlUt_FieldSecurity.cleanseFields(balanceTransactionsToUpdate.values(), false); 
                 update balanceTransactionsToUpdateList;
            }             
            
            if(!listTransferBillBalanceTransaction.isEmpty()){
                listTransferBillBalanceTransaction = (List<BalanceTransaction__c>) GlUt_FieldSecurity.cleanseFields(listTransferBillBalanceTransaction, false); 
                insert listTransferBillBalanceTransaction;
            } 
            //AT-4891/2 Code Check Marx Changes Ends Here.
            // Reset the active function to null in case this class was first in stack
            // this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            
        }
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           21 Sep 2017
    @param          Map<Id, SObject> - newMap
    @description    Updates LastBillCalculationDate on BillingContract__c and
                    Status = 'Completed' on BillCalculation for new Bills inserted
    @Revisions      07-June-2018 Tarun , AT-2732 , To Update NextScheduledBillDate on contract.
                    15-March-2019 Amit K.,UL-502 (Unmeasured Billing)
    *******************************************************************************/
    public void updateRelatedRecords(Map<Id, SObject> newMap) {
        
        List<Id> billCalculationIdsToUpdate = new List<Id>();       // list of related bill calculation Ids
        //Map<Id, Date> contractNextScheduledBillDateMap = new Map<Id, Date>();        // map of NextScheduledBillDate__c keyed on contract Id
        Boolean updateContractFlag = false;
        //UL-502 Starts Here
        Map<Id,Bill__c> mapOfBillingContractId2Bill = new Map<Id,Bill__c>();
        //Map<Id, Date> contractBillDateMap = new Map<Id, Date>();        // map of bill dates keyed on contract Id
        // get the related contract and bill calculation records
        for (Bill__c bill : (List<Bill__c>)newMap.values()) {
            mapOfBillingContractId2Bill.put(bill.BillingContract__c, bill);
            //contractBillDateMap.put(bill.BillingContract__c, bill.BillDate__c);
            
            billCalculationIdsToUpdate.add(bill.BillCalculation__c);
            
            //AT-2732
            /*if(bill.NextScheduledBillDate__c != null){
                if(!contractNextScheduledBillDateMap.containsKey(bill.BillingContract__c)){
                    contractNextScheduledBillDateMap.put(bill.BillingContract__c,bill.NextScheduledBillDate__c);
                }
                
            }*/
            //UL-502 Ends Here           
        }
        // for each related contract
        for (BillingContract__c contract : [select Id, 
                                            LastBillCalculationDate__c,
                                            AnnualBillDate__c,
                                            NextScheduledBillDate__c
                                     from BillingContract__c
                                     where Id in :mapOfBillingContractId2Bill.keySet()]) {
            //AT-2732                             
            updateContractFlag = false;                                         
                                         
            // if the new bill date is more recent than the last bill calculation date, update it
            if (contract.LastBillCalculationDate__c == null || contract.LastBillCalculationDate__c < mapOfBillingContractId2Bill.get(contract.Id).BillDate__c) {
                contract.LastBillCalculationDate__c = mapOfBillingContractId2Bill.get(contract.Id).BillDate__c;
                
                //AT-2732
                updateContractFlag = true;
            }
              
            //AT-2732  Starts Here 
            //UL-502 Starts Here                                      
            if (mapOfBillingContractId2Bill.get(contract.Id).NextScheduledBillDate__c != null) {   
                contract.NextScheduledBillDate__c = mapOfBillingContractId2Bill.get(contract.Id).NextScheduledBillDate__c;
                
                updateContractFlag = true;
            } 
            
            if(contract.AnnualBillDate__c != null && mapOfBillingContractId2Bill.get(contract.Id).AnnualBill__c && mapOfBillingContractId2Bill.get(contract.Id).BillType__c == GlUt_Constants.NORMAL){
                contract.AnnualBillDate__c = null;
                updateContractFlag = true;
            } 
            //UL-502 Ends Here
            // and add it to the update map
            if (updateContractFlag) {
                contractsToUpdate.put(contract.Id, contract); 
            }
                                         
        }
        
        if(!billCalculationIdsToUpdate.isEmpty()){            
            // for each related bill calculation
            for (BillCalculation__c billCalculation : [select Id, 
                                                       Status__c
                                                       from BillCalculation__c
                                                       where Id in :billCalculationIdsToUpdate]) {
                                                           
                                                           // ensure the bill calculation status is 'Completed'                             
                                                           billCalculation.Status__c = Label.BlIn_BillCalculationStatusCompleted;                        
                                                           billCalculationsToUpdate.put(billCalculation.Id, billCalculation);
                                                           
                                                       }
        }
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           31 May 2018
    @param          Map<Id, SObject> - newMap
    @description    AT-2482 , Updates associated BillEvent records to processed 
                    AND To update Balance Snapshot on Balance object.
    *******************************************************************************/
    public void updateBillEventRecords(Map<Id, SObject> newMap) {
        
        List<Id> billEventIdsToUpdate = new List<Id>();       // list of related bill event Ids
        
        // get the related contract and bill calculation records
        for (Bill__c bill : (List<Bill__c>)newMap.values()) {
            billEventIdsToUpdate.add(bill.BillEvent__c);
        }
        
        system.debug(DEBUG + 'billEventIdsToUpdate: ' + billEventIdsToUpdate);
        
        if(!billEventIdsToUpdate.isEmpty()){
            
            for (BillEvent__c objBillEvent : [SELECT Id, 
                                              Name,
                                              Status__c 
                                              FROM BillEvent__c
                                              WHERE Id IN :billEventIdsToUpdate]){
                                                  
                                                  system.debug(DEBUG + 'objBillEvent: ' + objBillEvent);                                             
                                                  
                                                  objBillEvent.Status__c = GlUt_APIConstantsBillEvent.PROCESSEDBILLEVENTSTATUS;  // 'Processed';
                                                  billEventsToUpdate.put(objBillEvent.Id, objBillEvent);  
                                              }
        }
        
        system.debug(DEBUG + 'billEventsToUpdate: ' + billEventsToUpdate);
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           08 June 2018
    @param          List<SObject> newlist, Map<Id, SObject> oldMap
    @description    AT-2482 : Update balance snapshot on Balance object
    *******************************************************************************/ 
    public void updateBalanceSnapshot(List<SObject> newlist, Map<Id, SObject> oldmap) {
        
        Map<Id, Bill__c> billOldMap =  (Map<Id, Bill__c>) oldmap ;
        Set<Id> billIdsSet = new Set<Id>();       // list of Bill Ids to get Balance
        Set<Id> balanceIdsSet = new Set<Id>();
        
        for (Bill__c objBill : (List<Bill__c>) newlist) {
            
            if (objBill.PrintXml__c && !billOldMap.get(objBill.Id).PrintXml__c) {
                billIdsSet.add(objBill.Id) ;
            } 
        }
        
        if (!billIdsSet.isEmpty()) {
            
            for (Bill__c objBill : [SELECT Id, BillingContract__r.Balance__c FROM Bill__c WHERE Id IN : billIdsSet]) {
                balanceIdsSet.add(objBill.BillingContract__r.Balance__c);
            }
            
        }
        
        system.debug(DEBUG + 'balanceIdsSet: ' + balanceIdsSet);
        
        if(balanceIdsSet.size() > 0){
            
            for (Balance__c objBalance : [SELECT Id, 
                                          Name,
                                          Balance__c,
                                          BalanceSnapshot__c
                                          FROM Balance__c
                                          WHERE Id IN :balanceIdsSet]) {
                                              
                                              objBalance.BalanceSnapshot__c = objBalance.Balance__c;
                                              balancesToUpdate.put(objBalance.Id, objBalance);  
                                          }
        }
        
        system.debug(DEBUG + 'balancesToUpdate: ' + balancesToUpdate);
    }
    
    /******************************************************************************
    @author			Echo: Patrick Dixon
    @date           04 Jul 2018
    @param          List<SObject> newlist, Map<Id, SObject> oldMap
    @description    Update balance transaction records when a Pending Bill is no longer the current bill
	@Revisions 		AT-3257 , Made changes as now BT will be linked to Bill instead of Bill Item
    *******************************************************************************/ 
    public void updateBalanceTransactions(List<SObject> newlist, Map<Id, SObject> oldmap) {
        
        // build a list of bill that have changed pending state
        Set<Id> billIds = new Set<Id>();
        for (Bill__c bill : (List<Bill__c>) newlist) {
            
            // was current pending bill but is now not
            if (!bill.LatestPendingBill__c && ((Map<Id, Bill__c>) oldmap).get(bill.Id).LatestPendingBill__c) {
                billIds.add(bill.Id) ;
            } 
        }
        
        // clear the associated balance transactions flag
        if(billIds.size() > 0){
            for (BalanceTransaction__c balanceTransaction : [select Id, 
                                                             CurrentPendingBill__c
                                                             from BalanceTransaction__c
                                                             // AT-3275 Start
                                                             where Bill__c in :billIds]) {    
                                                                 // AT-3275 End
                                                                 balanceTransaction.CurrentPendingBill__c = false;
                                                                 balanceTransactionsToUpdate.put(balanceTransaction.Id, balanceTransaction);  
                                                             }
        }
        
        system.debug(DEBUG + 'balanceTransactionsToUpdate: ' + balanceTransactionsToUpdate);
    }
    
    /******************************************************************************
    @author			Echo: Tarun Gupta
    @date           03 Aug 2018
    @param          List<SObject> newlist, Map<Id, SObject> oldMap
    @description    AT-3257 , If Transferred Contract field value is changed from null, then create two BT records for new and old contract
					Commented BY Dependra 26 Oct 2018 AT-4053 The changes made to the Bill Handler to create the Bill Transfer Balance Transaction need to be removed 
    *******************************************************************************/ 
   /* public void createBalanceTransactions(List<SObject> newlist, Map<Id, SObject> oldmap) {
        
        Set<Id> billIds = new Set<Id>();
        for (Bill__c bill : (List<Bill__c>) newlist) {
            
            // TransferredFromBillingContract__c of old and new is not same
            //if (bill.TransferredFromBillingContract__c != null && ((Map<Id, Bill__c>) oldmap).get(bill.Id).TransferredFromBillingContract__c == null) {
            if (bill.TransferredFromContract__c != ((Map<Id, Bill__c>) oldmap).get(bill.Id).TransferredFromContract__c) {    
                billIds.add(bill.Id) ;
            } 
        }
        
        system.debug('billIds---'+ billIds);
        
        if(billIds.size() > 0){
            
            for(Bill__c objBill : [SELECT Id,Name,
                                   BillingContract__c,BillingContract__r.Balance__c,
                                   TransferredFromContract__c,TransferredFromContract__r.Balance__c,
                                   TotalAmountOutstanding__c 
                                   FROM Bill__c WHERE ID IN :billIds]){
                
                BalanceTransaction__c objBTFromContract = new BalanceTransaction__c();
                objBTFromContract.Bill__c = objBill.Id;
                objBTFromContract.Balance__c = objBill.BillingContract__r.Balance__c;
                objBTFromContract.RecordTypeId = BTRecordTypeIdBillTransfer;
                objBTFromContract.BillAmount__c = objBill.TotalAmountOutstanding__c;
                objBTFromContract.CurrentPendingBill__c = false;
                                       
                listTransferBillBalanceTransaction.add(objBTFromContract);
                                       
                BalanceTransaction__c objBT2Contract = new BalanceTransaction__c();
                objBT2Contract.Bill__c = objBill.Id;
                objBT2Contract.Balance__c = objBill.TransferredFromContract__r.Balance__c;
                objBT2Contract.RecordTypeId = BTRecordTypeIdBillTransfer;
                objBT2Contract.BillAmount__c = objBill.TotalAmountOutstanding__c * -1;
                objBT2Contract.CurrentPendingBill__c = false;
                                       
				listTransferBillBalanceTransaction.add(objBT2Contract);                                       
            }
            
            system.debug('listTransferBillBalanceTransaction---'+ listTransferBillBalanceTransaction);
        }
    }*/
    
}