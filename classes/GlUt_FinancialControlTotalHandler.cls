/******************************************************************************
@author         Echo: Tarun Gupta
@date           29 mar 2018
@description    Handler for Financial Control Total trigger
*******************************************************************************/
public with sharing class GlUt_FinancialControlTotalHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_FinancialControlTotalHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           29 mar 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void MainEntry(GlUt_TriggerHandlerObj inputParam) {
                
        try {
            // TO-DO Logger.Push('MainEntry', 'GlUt_FinancialControlTotalHandler');
            
            if (inputParam.isInsert && inputParam.isAfter) {
                //createFinancialControlAssociation(inputParam.newlist);
            }
            
            if (inputParam.isUpdate && inputParam.isAfter) {
            }
            
            if (inputParam.isDelete && inputParam.isBefore) {
            }
            
            if (inputParam.isDelete && inputParam.isAfter) {
            }
            
        } catch (exception e) {
            // TO-DO Logger.debugException(e);
        }
        
        finally {
                        
            // Reset the active function to null in case this class was first in stack
            // this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            // TO-DO Logger.pop();
        }
    }
    
}