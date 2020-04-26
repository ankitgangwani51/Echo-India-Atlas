/******************************************************************************
@author         Accenture: Patrick Dixon
@date           03 Oct 2017
@description    Component controller for Heroku authentication token lightning component
*******************************************************************************/
public with sharing class BlAp_AuthenticationTokenComponentCtrlr {

	public static final String CLASS_NAME = 'BlAp_AuthenticationTokenComponentCtrlr';
	public static final String DEBUG = '[' + CLASS_NAME + '] ';

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           03 Oct 2017
    @param          String - token
    @return			Boolean - success
    @description    Saves the token in the protected custom setting
    *******************************************************************************/
    @AuraEnabled
    public static Boolean updateToken(String token) {
        
        try {

            // retrieve Heroku authentication protected custom setting		
            HerokuSecurity__c security;
            /*AT-4374 Clayton Security review changes starts here */
            for (HerokuSecurity__c securityOld : [select AuthenticationToken__c 
                                                  from HerokuSecurity__c Limit 1]) {
                                                      security = securityOld;
                                                      break;
                                                  }
            /*AT-4374 Clayton Security review changes Ends here */
            
            // update it using the new value
            System.debug(DEBUG + 'old token ' + security.AuthenticationToken__c); // Debug Added
            security.AuthenticationToken__c = token;
            //			update security;
            System.debug(DEBUG + 'new token ' + token);
            return true;
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());

        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
}