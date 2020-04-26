/******************************************************************************
@author         Echo: Vivek Sethi
@date           22-Nov-2017
@param          objIdList -> list of Ids of Object 
                objName -> Object Name; VoidManagementProcess__c or DebtRecoveryProcess__c
@return     
@description    Schedulable, Batchable Class To Execute Void Management Actions Step
@revision(s)    SM - 30-Nov-2017, Created Generic Code for Send Letter Method and added email sending functionality
                MT - Changed the logic from single email message to mass email message and also changed the where 
                clause of the query for fetching the VoidManagementAction__c or DebtRecoveryAction__c records
*******************************************************************************/
public without sharing class GlUt_CreateLetter {
    
    public static void sendLetter(List<Id> objIdList, String objName,List<String> queryFields){               
        
        if(objIdList.size() > 0){
            String sOQLQuery = '';
             sOQLQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id, Name, '+ String.join(queryFields,','), objName + ' WHERE Id IN :objIdList'});
            List<sObject> qryResultList =  Database.query(sOQLQuery);
            if(qryResultList.size() > 0){
                sendEmail(qryresultlist, objName);
            }
        }
    }
    
	/******************************************************************************
	@author         Echo: Swati Mathur
	@date           30-Nov-2017
	@param          recordList -> list of Ids of Object 
	                objName -> Object Name; VoidManagementAction__c or DebtRecoveryAction__c
	@return     
	@description    Method is used to send the emails
	@revision(s)    MT- Changed the logic for mass emailing
	*******************************************************************************/
    
    public static void sendEmail(List<sObject> recordList, String objName){     
        
        List<VoidManagementAction__c> voidMangActionList = new List<VoidManagementAction__c>();
        List<DebtRecoveryAction__c> debtRecActionList = new List<DebtRecoveryAction__c>();
        
        for(sObject qryResultObj : recordList){  
            
            if (objName == GlUt_APIConstantsVoidManagementAction.VOIDMANAGEMENTACTIONAPINAME){                
                VoidManagementAction__c vmObj = (VoidManagementAction__c)qryResultObj;
                vmObj.Processed__c = True;
                voidMangActionList.add(vmObj);
            }
            else{
                DebtRecoveryAction__c drObj = (DebtRecoveryAction__c)qryResultObj;
                drObj.Processed__c = True;
                debtRecActionList.add(drObj);
            }
        }
        
       /* String testResultBody = '<p>Hi '+ UserInfo.getName() + ',</p>';        
        testResultBody += '<p>This email is fired as part of ' + objName + '.&nbsp;</p>';
        testResultBody += '<p>Action Name = ' + actionName + '</p>' ;
        testResultBody += '<p>Parameters = ' + parameters + '</p> <br/>' ;
        testResultBody += '<p> Thanks </p>' ;*/
        
        Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
            
        List<Id> targetIds = new List<Id>();
        targetIds.add(UserInfo.getUserId());
        
        List<EmailTemplate> emailTemp = [Select Id from EmailTemplate where DeveloperName =: GlUt_Constants.SALESVOIDMANAGEMENTEMAIL limit 1];
        
        if(!emailTemp.isEmpty()){
        
	        mail.setTargetObjectIds(targetIds);  
	        mail.setSenderDisplayName(GlUt_Constants.ATLASSUPPORT);                
	       // mail.setSubject(objName + ' Email');
	        mail.setSaveAsActivity(false);
	        mail.setTemplateId(emailTemp[0].Id);
	        
	        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.MassEmailMessage[] { mail });
	        
	        if (results[0].isSuccess()) {
	            System.debug('The email was sent successfully.'); 
	        } else {
	            System.debug('The email failed to send: ' + results[0].errors[0].message);   
	        }
        }
        
        if (objName == GlUt_APIConstantsVoidManagementAction.VOIDMANAGEMENTACTIONAPINAME){        
            voidMangActionList = (List<VoidManagementAction__c>) GlUt_FieldSecurity.cleanseFields(voidMangActionList, false);
            update voidMangActionList;
        }
        else{
            debtRecActionList = (List<DebtRecoveryAction__c>) GlUt_FieldSecurity.cleanseFields(debtRecActionList, false);
            update debtRecActionList;
        }       
        
    }
}