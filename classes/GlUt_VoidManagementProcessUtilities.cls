/******************************************************************************
@author    		Accenture: Patrick Dixon
@date      		30 Nov 2017
@description 	Class for VoidManagementProcess (record) utilities
*******************************************************************************/
public with sharing class GlUt_VoidManagementProcessUtilities {
    
	private static final String CLASS_NAME = 'GlUt_VoidManagementProcessUtilities';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
	
	/******************************************************************************
	@author    		Accenture: Patrick Dixon
	@date      		30 Nov 2017
	@param			Id - location Id
	@param			Date - the activation date for the process
	@param			Boolean - true for a household account
	@return			Id - the void contract Id
	@description 	Creates a void management process record for the location
	*******************************************************************************/
	public static Id createVoidManagementProcess(Id locationId, Date activationDate, Boolean isHH) {
	
		String profile = isHH ? System.Label.GlAp_VoidManagementProfileHH : System.Label.GlAp_VoidManagementProfileNHH;
		VoidManagementProcess__c newProcess = new VoidManagementProcess__c(
															CurrentStage__c	= System.Label.GlAp_VoidManagementProcessStageStage1, 
															CurrentStageDateTime__c = datetime.now(), 
															Evaluate__c	= false, 
															NextStage__c = System.Label.GlAp_VoidManagementProcessStageOccupationForm, 
															NextStageDateTime__c = null, 
															Predict__c = false, 	
															PredictedStage__c = null, 
															ProcessComplete__c = false, 
															VoidActivationDate__c = activationDate, 
															VoidLocation__c	= locationId, 
															VoidManagementProfile__c = profile 
														);
		
		// insert the record
		newProcess = (VoidManagementProcess__c) GlUt_FieldSecurity.cleanseFields(newProcess, false);
		insert newProcess;

		return newProcess.Id;
	}
}