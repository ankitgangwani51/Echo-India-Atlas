/******************************************************************************
@author        Accenture: vivek chauhan
@date          15 Dec 2017
@description   Component controller for Agreed Rate Wizard wizard
@Revisions	   AT-3987,Tarun , modified class name as per security review changes
*******************************************************************************/
public with sharing class CuAp_ManageAggRateWizardCtrlr {

  private static final String CLASS_NAME = 'CuAp_ManageAggRateWizardCtrlr';
  private static final String DEBUG = '[' + CLASS_NAME + '] ';

  private static WizardObject wizObject;

  
    /******************************************************************************
    @author         Accenture : vivek chauhan
    @date           20 Nov 2017
    @description    Wrapper class for Wizard variables
    *******************************************************************************/
	private class WizardObject {

		private Id recordId;
		private Id contractId;
	}
    
    /******************************************************************************
	@author			Accenture : Vivek chauhan
	@date			14 Dec 2017
	@param			String - wizardprop
	@description	Updates the wizard properties
	*******************************************************************************/
    @AuraEnabled
	public static void WizardStatus(String wizardprop) {
    
        try {
            GlUt_Logger.logDebug(DEBUG);
            // build the wizard object from the wizard properties
            UpdateWizardProperties(wizardprop);
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
	@author			Accenture: Vivek Chauhan
	@date			14 Dec 2017
	@param			String - wizardprop
	@description	Updates the wizard properties
	*******************************************************************************/
	public static void UpdateWizardProperties(String wizardprop) {
    
		// strip out all the SObject type references from the json
		wizardprop = wizardprop.replaceAll('"sobjectType":"(.*?)"(,|[^}]*)', '');
    
		// and deserialise it
		wizObject = (WizardObject)System.JSON.deserializeStrict(wizardprop, WizardObject.class);
	}
  
    /******************************************************************************
    @author         Accenture : vivek chauhan
    @date           20 Nov 2017
	@param			String customerId
	@return			List<BlAp_CombinedRecord>
    @description    Get active contract
    *******************************************************************************/
	@AuraEnabled
	public static List<BlAp_CombinedRecord> getActiveContracts(String customerId) {
        List<BlAp_CombinedRecord> activeContractList;
        try {
            GlUt_Logger.logDebug(DEBUG);
            activeContractList = CuAp_SelectContractPageCtrlr.retrieveContracts(customerId);
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return activeContractList;
    }
    
}