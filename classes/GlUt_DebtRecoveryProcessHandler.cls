/******************************************************************************
@author         Echo: Dependra Singh (Echo)
@date           20 Feb 2018
@description    Handler for DebtRecoveryProcess trigger
*******************************************************************************/
public with sharing class GlUt_DebtRecoveryProcessHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_DebtRecoveryProcessHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author         Echo: Dependra Singh (Echo)
    @date           20 Feb 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {
        try {
            if (inputParam.isInsert && inputParam.isAfter) {
                updateDebtRecoveryProcessOnContract(inputParam.newmap, inputParam.oldmap);
            }
            if (inputParam.isInsert && inputParam.isBefore) {
    
            }
            if (inputParam.isUpdate && inputParam.isAfter) {
                updateDebtRecoveryProcessOnContract(inputParam.newmap, inputParam.oldmap);
            }
            if (inputParam.isUpdate && inputParam.isBefore) {

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
    @date           22 Feb 2018
    @param          Map<Id,sObject> newmap, Map<Id,sObject> oldmap
    @description    Create debt recovery record to update the contract with the current debt recovery process (for aged debt reporting)
                    (1)-IF NEW -Set the ‘Running Debt Recovery Process’ lookup field on Contract to the current Debt Recovery Process record.
                    (2)-IF UPDATE -IF ‘Process Complete’ flag is ‘True’ 
                            (a)-Check if ‘Running Debt Recovery Process’ lookup field on Contract is the same as current Debt Recovery Process 
                            (b)-If yes, clear ‘Running Debt Recovery Process’ lookup field 
                    (3) IF ‘Process Complete’ flag is ‘False’ 
                        Do nothing   
    @return         void
    *******************************************************************************/
    
       private void updateDebtRecoveryProcessOnContract(Map<Id,sObject> newmap, Map<Id,sObject> oldmap) {           
           Map<Id,Id> debtRecoveryProcessByContractId = new Map<Id,Id>();
           Map<Id,Id> existingDebtRecoveryProcessByContractId = new Map<Id,Id>();
           Set<Id> contractIds = new Set<Id>(); 
           List<BillingContract__c> contractListToUpdate = new List<BillingContract__c>();
           
           if(oldmap !=null){
             for(DebtRecoveryProcess__c objDebtRecoveryProcess : (List<DebtRecoveryProcess__c>)newMap.values()) {
                if(objDebtRecoveryProcess.BillingContract__c != null && objDebtRecoveryProcess.ProcessComplete__c == true && (DebtRecoveryProcess__c)oldmap.get(objDebtRecoveryProcess.Id) != null){
                    DebtRecoveryProcess__c objDebtRecoveryProcessOld = (DebtRecoveryProcess__c)oldmap.get(objDebtRecoveryProcess.Id);
                    if(!existingDebtRecoveryProcessByContractId.containsKey(objDebtRecoveryProcess.BillingContract__c) && objDebtRecoveryProcessOld.ProcessComplete__c == false){
                        existingDebtRecoveryProcessByContractId.put(objDebtRecoveryProcess.BillingContract__c,objDebtRecoveryProcess.Id);
                    }
                }
             } 
           }else{
               for (DebtRecoveryProcess__c objDebtRecoveryProcess : (List<DebtRecoveryProcess__c>)newMap.values()) {
                if(objDebtRecoveryProcess.BillingContract__c != null && objDebtRecoveryProcess.ProcessComplete__c == false){
                    if(!debtRecoveryProcessByContractId.containsKey(objDebtRecoveryProcess.BillingContract__c)){
                        debtRecoveryProcessByContractId.put(objDebtRecoveryProcess.BillingContract__c, objDebtRecoveryProcess.Id);
                    }
                 }
              }
           }
           if(debtRecoveryProcessByContractId.keyset().size() >0){
               for(BillingContract__c objContract : [SELECT Id,CurrentDebtRecoveryProcess__c FROM BillingContract__c WHERE ID IN: debtRecoveryProcessByContractId.keyset()]){
                   objContract.CurrentDebtRecoveryProcess__c = debtRecoveryProcessByContractId.get(objContract.Id);
                   contractListToUpdate.add(objContract);
               }
           }
           if(existingDebtRecoveryProcessByContractId.keyset().size() >0){
               for(BillingContract__c objContractNew : [SELECT Id,CurrentDebtRecoveryProcess__c FROM BillingContract__c WHERE ID IN: existingDebtRecoveryProcessByContractId.keyset()]){
                   if(existingDebtRecoveryProcessByContractId.containsKey(objContractNew.Id) && objContractNew.CurrentDebtRecoveryProcess__c == existingDebtRecoveryProcessByContractId.get(objContractNew.Id)){
                         objContractNew.CurrentDebtRecoveryProcess__c = null;
                   }
                   contractListToUpdate.add(objContractNew);
               }
           }
           
           if(!contractListToUpdate.isEmpty()){
               contractListToUpdate = (List<BillingContract__c>) GlUt_FieldSecurity.cleanseFields(contractListToUpdate, false);
               update contractListToUpdate;
           }
       }
}