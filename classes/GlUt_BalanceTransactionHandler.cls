/******************************************************************************
@author         Echo: Dependra Singh
@date           20 Dec 2018
@description    Handler for TariffLimit  trigger
*******************************************************************************/
public with sharing class GlUt_BalanceTransactionHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_BalanceTransactionHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           20 Dec 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void MainEntry(GlUt_TriggerHandlerObj inputParam) {
        try {
            if (inputParam.isInsert && inputParam.isAfter)  {
            }
            if (inputParam.isUpdate && inputParam.isAfter)  {
            }
            if (inputParam.isInsert && inputParam.isBefore) {
            }
            if (inputParam.isUpdate && inputParam.isBefore) {
            }
            if (inputParam.isDelete && inputParam.isBefore) {
            }
            if (inputParam.isDelete && inputParam.isAfter)  {
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
    @date           20 Dec 2018
    @param          GlUt_TriggerHandlerObj inputParam
    @description    
    *******************************************************************************/

   
}