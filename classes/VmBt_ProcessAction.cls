/******************************************************************************
@author      	Echo: Vivek Sethi
@date      		22-Nov-2017
@description	Schedulable, Batchable Class To Execute Void Management Actions Step
@revision       MT- Added the logic to form the Void Management Actions list based on their
                action type and also changed the name of the called classes.
*******************************************************************************/

global with sharing class VmBt_ProcessAction implements Schedulable, Database.Batchable<sObject>{
     private static List<String> queryFields;
    static{
        queryFields = new List<string>();
        queryFields.add(GlUt_APIConstantsVoidManagementAction.PARAMETERSAPINAME); 
    }
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           03 july 2018
    @description    This method implement SchedulableContext to schedule batch job.
    *******************************************************************************/
    global void execute(SchedulableContext sc){
        // Call Start method...
        Database.executeBatch(this);           
    }
   /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           03 july 2018
    @description    Batch's start method
    *******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, ' + GlUt_APIConstantsVoidManagementAction.ACTIONAPINAME + ' FROM ' + 
                                        GlUt_APIConstantsVoidManagementAction.VOIDMANAGEMENTACTIONAPINAME + ' WHERE ' + 
                                        GlUt_APIConstantsVoidManagementAction.PROCESSEDAPINAME + ' = FALSE');
    }
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           03 july 2018
    @description    Batch's execute method
    *******************************************************************************/
    global void execute(Database.BatchableContext bc, List<VoidManagementAction__c> scope){
        List<Id> sendLetterList = new List<Id>();

        //MT - Logic to form the Void Management Actions list based on their action type
        for(VoidManagementAction__c vmActionRec: scope){
            if(vmActionRec.Action__c == VmBt_Constants.SENDVOIDMGMTVISITNOTICE || 
               vmActionRec.Action__c == VmBt_Constants.SENDVOIDMGMTVISITNOTIFICATION || 
               vmActionRec.Action__c == VmBt_Constants.SENDOCCUPATIONFORM) {                   
                sendLetterList.add(vmActionRec.Id);                  
            } 
        }
        GlUt_CreateLetter.sendLetter(sendLetterList,GlUt_APIConstantsVoidManagementAction.VOIDMANAGEMENTACTIONAPINAME,queryFields);
    }    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           03 july 2018
    @description    Batch's final method
    *******************************************************************************/   
    global void finish(Database.BatchableContext bc){
        
    }    
    
}