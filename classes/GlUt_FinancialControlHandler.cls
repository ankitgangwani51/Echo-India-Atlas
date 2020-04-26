/******************************************************************************
@author         Echo: Dependra Singh
@date           20 mar 2018
@description    Handler for Financial Control trigger
*******************************************************************************/
public with sharing class GlUt_FinancialControlHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_FinancialControlHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           20 mar 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void MainEntry(GlUt_TriggerHandlerObj inputParam) {
                
        try {
            
            if (inputParam.isInsert && inputParam.isAfter) {
                ProcessFinancialControlTotal(inputParam.newlist);
            }
            
            if (inputParam.isUpdate && inputParam.isAfter) {
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
    @author         Echo: Dependra Singh
    @date           20 mar 2018
    @param          Map<Id, SObject> - newMap
    @param          Map<Id, SObject> - oldMap
    @description    
    *******************************************************************************/
    public void CallFinancialControlDispatcher(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           23 mar 2018
    @param          Map<Id, SObject> - newMap
    @param          Map<Id, SObject> - oldMap
    @description    
    *******************************************************************************/
    public void ProcessFinancialControlTotal(List<SObject> newlist) {
        
        GlUt_FinancialControlTotal.FinancialTotalEffective(newlist);
        
        
        
    }
}