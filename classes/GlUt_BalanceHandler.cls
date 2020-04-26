/******************************************************************************
@author         Echo: Patrick Dixon
@date           15 Feb 2018
@description    Handler for Balance trigger

*******************************************************************************/
public with sharing class GlUt_BalanceHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_BalanceHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           15 Feb 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void MainEntry(GlUt_TriggerHandlerObj inputParam) {
                
        try {
           
            // TO-DO Logger.Push('MainEntry', 'GlUt_AccountHandler');
            system.debug('GlUt_BalanceHandler****');
            
            if (inputParam.isInsert && inputParam.isAfter) {
                // update payment plans
                calculateNewPaymentPlans(inputParam.newmap, inputParam.oldmap);
            }
            
            if (inputParam.isUpdate && inputParam.isAfter) {
                // update payment plans
                calculateNewPaymentPlans(inputParam.newmap, inputParam.oldmap);
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
                        
            // Reset the active function to null in case this class was first in stack
            // this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            
        }
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           15 Feb 2018
    @param          Map<Id, SObject> - newMap
    @param          Map<Id, SObject> - oldMap
    @description    calculate new payment plans for the new bills
    *******************************************************************************/
    public void calculateNewPaymentPlans(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        List<Instalment__c> instalmentListNew = new List<Instalment__c>();
        
        system.debug(DEBUG + 'Updated/Created Balances : '+ newMap.values());
        system.debug('oldMap***'+ oldMap);
        
        // build a set of balance Ids where the bill item amounts have been updated
        Set<Id> balanceIds = new Set<Id>();
        List<BillingContract__c> contracts = new List<BillingContract__c>();
        
        for (Balance__c balance : (List<Balance__c>)newMap.values()) {
            
            if(oldMap != null && oldMap.keyset().size() > 0){
                
                // AT-3275
                if ((!oldMap.keySet().contains(balance.Id) && balance.TotalBillAmount__c != 0)
                    || balance.TotalBillAmount__c != ((Balance__c)oldMap.get(balance.Id)).TotalBillAmount__c)
                {
                    
                    balanceIds.add(balance.Id);
                }
            }
        }
        
        system.debug('balanceIds***'+ balanceIds);
        
        if(balanceIds.size() > 0){
            
            // use it to build a list of contracts with new bills that have current active instalment/pay in full plan types in place
            contracts = [select  Id, 
                                 AccountName__c, 
                                 CurrentPaymentPlanType__c, 
                                 Balance__c, 
                                 PaymentPlanRenewalDate__c, 
                                 DayOfWeek__c, 
                                 DayOfMonth__c,
                         		 BillingAddress__c
                         FROM BillingContract__c
                         WHERE Balance__c in :balanceIds
                         AND CurrentPaymentPlanType__r.PlanType__c != :Label.CuAp_PaymentPlanTypePlanTypeBudgetPlan 
                         AND CurrentPaymentPlanType__r.Active__c = true];
        }
                                        
        // calculate new payment plans for these contracts
        if (!contracts.isEmpty()) PpUt_PaymentPlanUtilities.calculatePlans(contracts);
    }
}