/******************************************************************************
@author    		Accenture: Patrick Dixon
@date      		07 Dec 2017
@description 	Controller for Suppression Indicator Component
*******************************************************************************/
public with sharing class CuAp_SuppressionIndicatorComponentCtrlr {
    
	private static final String CLASS_NAME = 'CuAp_SuppressionIndicatorComponentCtrlr';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
	
	/******************************************************************************
	@author    		Accenture: Patrick Dixon
	@date      		07 Dec 2017
	@param          String - the record type api name
	@param          Id - record Id
	@return         String - suppression status YES/NO/PARTIALLY
	@description    Checks if the record is suppressed or not.
	*******************************************************************************/
    @AuraEnabled
    public static String getSuppressionStatus(String sObjectName, Id recordId) {
        try {
            GlUt_Logger.logDebug(DEBUG);
            // call the appropriate method based on the record type name
            if (sObjectName == 'Account') {
                return GlUt_SuppressionUtilities.getAccountSuppressionStatus(recordId);
                
            } else if (sObjectName == GlUt_APIConstantsContracts.CONTRACTAPINAME) {
                return GlUt_SuppressionUtilities.isContractSuppressed(recordId) 
                    ? GlUt_Constants.SUPPRESSED_YES 
                    : GlUt_Constants.SUPPRESSED_NO;
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return null;
    }
}