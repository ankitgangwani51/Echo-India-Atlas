/******************************************************************************
@author         Echo: Mohit Tayal
@date           27 Aug 2018
@description    Handler for Debt Recovery Instalment trigger
@Revision		AT-5524(Included 4112 fix as well)
*******************************************************************************/
public with sharing class GlUt_DebtRecoveryInstalmentHandler extends GlUt_TriggerHandlerBase{

    private static final String CLASS_NAME = 'GlUt_DebtRecoveryInstalmentHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           27 Aug 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void MainEntry(GlUt_TriggerHandlerObj inputParam) {
                
        try {
            
            if (inputParam.isInsert && inputParam.isBefore) {
                updateDebtRecoveryInstalmentAmountDue((List<DebtRecoveryInstalment__c>)inputParam.newlist);
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
    @author         Echo: Mohit Tayal
    @date           27 Aug 2018
    @param          Map<Id,Instalment__c> newMap map of object new values
	@return         null
    @description    AT - 3429 assigns the value in InstalmentAmountDue__c field of 
                    DebtRecoveryInstalment object
    *******************************************************************************/
    private void updateDebtRecoveryInstalmentAmountDue(List<DebtRecoveryInstalment__c> newList){
        Map<Id,Instalment__c> mapOfInstalmentIdToRecord = new Map<Id,Instalment__c>();
        
        if(newList != Null && !newList.isEmpty()){
            for(DebtRecoveryInstalment__c objDebtRecoveryInstalment : newList){
                mapOfInstalmentIdToRecord.put(objDebtRecoveryInstalment.Instalment__c, new Instalment__c());
            }
        }
        
        if(!mapOfInstalmentIdToRecord.isEmpty()){
            mapOfInstalmentIdToRecord = new Map<Id,Instalment__c>([SELECT Id, SumofAllocatedPayment__c, InstalmentAmountDue__c, InstalmentAmountOutstanding__c FROM Instalment__c WHERE 
                                                                   Id IN :mapOfInstalmentIdToRecord.keySet()]);
            
            for(DebtRecoveryInstalment__c objDebtRecoveryInstalment : newList){
                if(!mapOfInstalmentIdToRecord.keySet().isEmpty() && mapOfInstalmentIdToRecord.containsKey(objDebtRecoveryInstalment.Instalment__c)){
                    if(mapOfInstalmentIdToRecord.get(objDebtRecoveryInstalment.Instalment__c).InstalmentAmountOutstanding__c != Null &&
                       mapOfInstalmentIdToRecord.get(objDebtRecoveryInstalment.Instalment__c).SumofAllocatedPayment__c != Null){
                           objDebtRecoveryInstalment.InstalmentAmountDue__c = mapOfInstalmentIdToRecord.get(objDebtRecoveryInstalment.Instalment__c).InstalmentAmountDue__c 
                                                                              - mapOfInstalmentIdToRecord.get(objDebtRecoveryInstalment.Instalment__c).SumofAllocatedPayment__c;
                       }
                }
            }
        }
    }
}