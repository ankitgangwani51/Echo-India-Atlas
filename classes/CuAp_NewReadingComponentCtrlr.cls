/******************************************************************************
@author         Echo: Patrick Dixon
@date           15 Feb 2018
@description    Component controller for new reading lightning component

@revision(s)        
*******************************************************************************/
public with sharing class CuAp_NewReadingComponentCtrlr {
    
    private static final String CLASS_NAME = 'CuAp_NewReadingComponentCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static WizardObject wizObject;

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           15 Feb 2018
    @description    Wrapper class for Wizard variables
    *******************************************************************************/
    @TestVisible
    private class WizardObject {
        public Id deviceId;
        public Reading__c newReading;
		public List<Reading__c> amendReadings;
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           15 Feb 2018
    @param          String - json string of object wizardprop
    @description    Updates the wizard properties
    *******************************************************************************/
    public static void updateWizardProperties(String wizardprop) {
        
        // strip out all the SObject type references from the json
        wizardprop = wizardprop.replaceAll('"sobjectType":"(.*?)"(,|[^}]*)', '');
        
        // and deserialise it
        wizObject = (WizardObject)System.JSON.deserialize(wizardprop, WizardObject.class);
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           12 Feb 2018
    @param          String - json string of object wizardprop
    @return         Id - the new reading Id
    @description    inserts the new reading and updates the readings it amends
    *******************************************************************************/
    @AuraEnabled
    public static Id saveReadings(String wizardprop) {
        updateWizardProperties(wizardprop);

        Savepoint sp = Database.setSavepoint();
        try {
            if(wizObject.newReading != null){
                wizObject.newReading = (Reading__c) GlUt_FieldSecurity.cleanseFields(wizObject.newReading, false);
                // save the new reading
                insert wizObject.newReading;
            }
            // if there are amended readings
            if (wizObject.amendReadings != null) {
            	
				// add the amended by link to the new reading
	            for (Reading__c amendedReading : wizObject.amendReadings) {
	            	if (amendedReading.AmendedByReading__c == null) {		// ignore readings already amended
	                	amendedReading.AmendedByReading__c = wizObject.newReading.Id;
	            	}
	            }
	    
                // and save them
                if (!wizObject.amendReadings.isEmpty()) {
                    wizObject.amendReadings = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(wizObject.amendReadings, false);
                    update wizObject.amendReadings;
                }
            }
            return wizObject.newReading.Id;
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
            
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
}