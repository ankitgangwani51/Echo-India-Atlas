/******************************************************************************
@author         Echo: Ankit Gangwani
@date           17 July 2018
@description    Component controller for Manage Stepped Tariff wizard
@Revision	 	AT-3951, Tarun - Modified as per security review
*******************************************************************************/
public class BlAp_SteppedTariffWizardCtrlr {
    
    public static WizardObject wizObject;
    
    private static final String CLASS_NAME = 'BlAp_SteppedTariffWizardCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    public class WizardObject {
        
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           17 July 2018
    @description    Wrapper class for Wizard variables
    *******************************************************************************/
	/*
	Screen	wizardprop element name			type
	==============================================================================
	Base:
			recordId					Id	
			contractId					Id		

	WS1:
			wizardType					String = Add new step tariff/Modify Existing Step tariffs	

	WS2:
			serviceType:				String = from screen		
			steppedTariff:				SteppedTariffService__C
												ServiceType__c = from screen
												RenewalMonths__c = from screen
												StartDate__c = from screen
												EndDate__c = from screen

	WS3:
			steppedTariffServices:		List<SteppedTariffService__C>
												SteppedTairrf = from WS2
												EndDate__c = from screen
												StartDate__c = from screen
	
	WS4:
			steppedTariffId: 			Id = from screen (on select of record)
			steppedTariff:				SteppedTariffService__C
												ServiceType__c = from screen
												StartDate__c = from screen
												EndDate__c = from screen
	
	WS5:
			steppedTariffServices:		List<SteppedTariffService__C>
												SteppedTairrf = from WS2
												EndDate__c = from screen
												StartDate__c = from screen
	*/		
        @TestVisible private Id recordId;
        @TestVisible private Id contractId;
        @TestVisible private Id steppedTariffId;
        @TestVisible private String wizardType;
        @TestVisible private String serviceType;
        @TestVisible private SteppedTariff__c steppedTariff;
        @TestVisible private List<SteppedTariffService__c> steppedTariffServices;
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           17 July 2018
    @param          String - wizardprop
    @description    Updates the wizard properties
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
    @author         Echo: Ankit Gangwani
    @date           17 July 2018
    @param          String - wizardprop
    @description    Updates the wizard properties
    *******************************************************************************/
    public static void UpdateWizardProperties(String wizardprop) {
        
        // strip out all the SObject type references from the json
        wizardprop = wizardprop.replaceAll('"sobjectType":"(.*?)"(,|[^}]*)', '');
        // and deserialise it
        wizObject = (WizardObject)System.JSON.deserializeStrict(wizardprop, WizardObject.class);       
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           17 July 2018
    @param          String - json string of object wizardprop
    @return         Id - SteppedTariff Id
    @description    Method called by wizard to complete the stepped tariff and stepped tariff services records.
    *******************************************************************************/
    @AuraEnabled
    public static Id createSteppedTairffAndServices(String wizardprop) { 
        Savepoint sp = Database.setSavepoint();
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
            // build the wizard object from the wizard properties
            UpdateWizardProperties(wizardprop); 
            // Create new stepped tariff record
            if(wizObject.steppedTariff!=null) {                
                wizObject.steppedTariff = (SteppedTariff__c) GlUt_FieldSecurity.cleanseFields(wizObject.steppedTariff, false);
                insert wizObject.steppedTariff;
            }
            
            // Create new stepped tariff services record associated with stepped tariff record
            if(wizObject.steppedTariffServices!=null) {                
                for(Integer i=0;i<wizObject.steppedTariffServices.size();i++){
                    wizObject.steppedTariffServices[i].SteppedTariff__c = wizObject.steppedTariff.Id;
                } 
                wizObject.steppedTariffServices = (List<SteppedTariffService__c>) GlUt_FieldSecurity.cleanseFields(wizObject.steppedTariffServices, false);
                insert wizObject.steppedTariffServices;
            }
            return wizObject.steppedTariff.Id;
        }
        catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            System.debug('exception = '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }  finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           17 July 2018
    @param          String - json string of object wizardprop
    @return         Id - SteppedTariff Id
    @description    Method called by wizard to update the stepped tariff services records.
    *******************************************************************************/
    @AuraEnabled
    public static Id updateSteppedTairffServices(String wizardprop) { 
        Savepoint sp = Database.setSavepoint();
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
            // build the wizard object from the wizard properties
            UpdateWizardProperties(wizardprop); 
            
            // Update stepped tariff services records
            if(wizObject.steppedTariffServices!=null) {                
                wizObject.steppedTariffServices = (List<SteppedTariffService__c>) GlUt_FieldSecurity.cleanseFields(wizObject.steppedTariffServices, false);               
                update wizObject.steppedTariffServices;
            }            
            return wizObject.steppedTariffServices[0].SteppedTariff__c;
        }
        catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            System.debug('exception = '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }  finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
}