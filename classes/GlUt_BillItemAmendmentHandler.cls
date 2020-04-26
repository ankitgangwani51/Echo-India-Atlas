/******************************************************************************
@author         Echo: Dependra Singh
@date           20 mar 2018
@description    Handler for Payment Allocation trigger
*******************************************************************************/
public with sharing class GlUt_BillItemAmendmentHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_BillItemAmendmentHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           20 mar 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void MainEntry(GlUt_TriggerHandlerObj inputParam) {
                
        try {
            // TO-DO Logger.Push('MainEntry', 'GlUt_AmendmentHandler');
            
            if (inputParam.isInsert && inputParam.isAfter) {
                CallFinancialControlDispatcher(inputParam);                
              
            }
            
            if (inputParam.isUpdate && inputParam.isAfter) {
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
    @date           20 mar 2018
    @param          GlUt_TriggerHandlerObj inputParam
    @description    Call financial control dispatcher
    *******************************************************************************/
    public void CallFinancialControlDispatcher(GlUt_TriggerHandlerObj inputParam) {
        FcUt_CentralDispatcher.Main(inputParam);
    }
}