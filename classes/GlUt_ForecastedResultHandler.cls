/******************************************************************************
@author         Echo: Tarun Gupta
@date           20 June 2018
@description    Handler for Forecasted Result Trigger
*******************************************************************************/
public with sharing class GlUt_ForecastedResultHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_ForecastedResultHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           20 June 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {        
        
        try {
            
            if (inputParam.isInsert && inputParam.isAfter) {
                renewBudgetPaymentPlan(inputParam.newList);                
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
    @author         Echo: Tarun Gupta
    @date           20 June 2018
    @param          Map<Id, SObject> - objectMap
    @description    This will call payment plan utility class to create a new budget renewal
    *******************************************************************************/
    public void renewBudgetPaymentPlan(List<SObject> newList) {
        
        List<ForecastedResult__c> listForecastedResult = (List<ForecastedResult__c>)newList;
        
        if (!listForecastedResult.isEmpty()) {
            PpUt_PaymentPlanUtilities.calculatePlans(listForecastedResult);
        }
    }
    
}