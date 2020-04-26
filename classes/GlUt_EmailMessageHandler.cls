/******************************************************************************
@author         Swati Mathur
@date           23 Feb 2018
@description    Handler for EmailMessage trigger
*******************************************************************************/
public with sharing class GlUt_EmailMessageHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_EmailMessageHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
      
    /******************************************************************************
    @author         Swati Mathur
    @date           23 Feb 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {
        
        system.debug('run***'+inputParam);

        try {
            if (inputParam.isInsert && inputParam.isBefore ) {
            }
            
            if (inputParam.isInsert && inputParam.isAfter) {

                //call to CreateLetterPdfRequest
                //
                system.debug('CreateLetterPdfRequest  ');
                CreateLetterPdfRequest(inputParam.newmap);
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
    
    /**********************************************************************************************
    @author         Swati Mathur
    @date           23 Feb 2018
    @param          Map<Id, SObject> newMap) - map of new records keyed on Id
    @description    This method calls the PrintedLetter utility class only where an EmailMessage
                    should be for a Printed Letter
    **********************************************************************************************/ 
    public void CreateLetterPdfRequest(Map<Id, SObject> newMap) {          
                        
        List<Id> lstEmailMessageIds = new List<Id>();  
        
        // Checking trigger map is not null and size greater than zero
        if (newMap != null && newMap.keySet().size() > 0) {
            lstEmailMessageIds.addAll(newMap.keySet());
        }
        // Checking list Email Message size greater than zero 
        if (!lstEmailMessageIds.isEmpty()) {
            Map<Id, String> ActivityIdToHtmlBodyMap = new Map<Id, String>();
            ConfigureTemplate__c configureTemplate = ConfigureTemplate__c.getOrgDefaults();        
            for(EmailMessage objEmailMes: [SELECT 
	                                           ToAddress,
	                                           ActivityId,
	                                           HtmlBody
                                           FROM EmailMessage
                                           WHERE Id IN :lstEmailMessageIds
                                           AND ToAddress = :configureTemplate.PrintedLetterEmailAddress__c]) { 
                                               
               ActivityIdToHtmlBodyMap.put(objEmailMes.ActivityId, objEmailMes.HtmlBody);              
                                           
          } 
            
            system.debug('ActivityIdToHtmlBodyMap  '   +  ActivityIdToHtmlBodyMap);
            // call to PrintedLetter utility class 
            if (!ActivityIdToHtmlBodyMap.isEmpty()) {
				LtUt_PrintedLetter obj = new LtUt_PrintedLetter(ActivityIdToHtmlBodyMap);
            }
        }        
    }        
    
}