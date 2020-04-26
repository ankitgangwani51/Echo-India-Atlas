/******************************************************************************
@author      	Echo: Vivek Sethi
@date      		22-Nov-2017
@description	Schedulable, Batchable Class To Execute Debt. Recovery Actions Step
@revision       MT - Added code to change payment plan for the Debt Recovery Action records 
                of type 'Change Payment Plan'
                MT - 01 Feb 2018 Added code to change the Disconnection Status field of 
                supply point as 'To Be Disconnected' if the AllowDisconnection field of is
                true for the Debt Recovery Action records of type 'Mark For Disconnection'
                MT - 02 Feb 2018 AT - 1270 to update the debt recovery profile field of 
                contract with the value present in the parameter field of the debt recovery
                action.
*******************************************************************************/

	global with sharing class  DrBt_ProcessAction implements Schedulable, Database.Batchable<sObject>{
    private static List<String> queryFields;
    static{
        queryFields = new List<string>();
        queryFields.add(GlUt_APIConstantsDebtRecoveryAction.PARAMETERSAPINAME); 
    }
    /******************************************************************************
    @author         Sudhir Kumar
    @date           10 Oct 2018
	@param			SchedulableContext sc
    @description    excecute method for Schedulable interface
					AT-3971 - Dynamic SOQL for DrBt_ProcessAction - Added Header (Security Review)
    *******************************************************************************/	
    global void execute(SchedulableContext sc){
        // Call Start method...
        Database.executeBatch(this);           
    }   
    /******************************************************************************
    @author         Sudhir Kumar
    @date           10 Oct 2018
	@param			Database.BatchableContext bc
    @description    start method for Batchable interface
					AT-3971 - Dynamic SOQL for DrBt_ProcessAction - Added Header (Security Review)
							- Replaced Dynamic SOQL with static SOQL and using getQuery of getQueryLocator.
    *******************************************************************************/	
    global Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([SELECT Id, Action__c,Parameters__c ,DebtRecoveryProcess__r.BillingContract__c 
                                         FROM DebtRecoveryAction__c 
                                         WHERE Id= 'a1D1v00000AaJGxEAN' /*Processed__c = false*/]) ;
    } 
    /******************************************************************************
    @author         Sudhir Kumar
    @date           10 Oct 2018
	@param			Database.BatchableContext bc, List<DebtRecoveryAction__c> scope
    @description    execute method for Batchable interface
					AT-3971 - Dynamic SOQL for DrBt_ProcessAction - Added Header (Security Review)
    *******************************************************************************/	
    global void execute(Database.BatchableContext bc, List<DebtRecoveryAction__c> scope){
        
        System.debug('300.1 scope == '+scope);
        List<Id> sendLetterList = new List<Id>();
        List<Id> addSIList = new List<Id>();
        List<Id> generateBillList = new List<Id>();
        List<Id> changeRecoveryProfileList = new List<Id>();
        //List<Id> changePaymentPlanList = new List<Id>(); // Commented By Dependra - 13-11-2018
        List<DebtRecoveryAction__c> changePaymentPlan = new List<DebtRecoveryAction__c>();
        List<Id> markForDisconnectionList = new List<Id>();
        for(DebtRecoveryAction__c drActionRec: scope)
        {
            if(drActionRec.Action__c == DrBt_Constants.SENDRMNDRLETTER || 
               drActionRec.Action__c == DrBt_Constants.SENDDISCONNOTICE || 
               drActionRec.Action__c == DrBt_Constants.SENDLETTER) {                   
                sendLetterList.add(drActionRec.Id);                
            } else if (drActionRec.Action__c == DrBt_Constants.ADDADDTNALSERVICES) {
                addSIList.add(drActionRec.Id);                
            } else if (drActionRec.Action__c == DrBt_Constants.CALCULATEBILL) {
                generateBillList.add(drActionRec.Id);               
            } else if (drActionRec.Action__c == DrBt_Constants.CHANGRECOVRYPROFILE) {
                //creatinglist  Debt Recovery Action records of type 'Change Recovery Profile'
                changeRecoveryProfileList.add(drActionRec.Id);               
            }else if(drActionRec.Action__c == DrBt_Constants.CHANGEPAYMENTPLAN){
                //creating list of Debt Recovery Action records type 'Change Payment Plan' 
                // Chnaged By Dependra - 13-11-2018 - 
                changePaymentPlan.add(drActionRec);
            } else if(drActionRec.Action__c == DrBt_Constants.MARKFFORDISCONCTION){
                //creating list of Debt Recovery Action records type 'Mark For Disconnection' 
                markForDisconnectionList.add(drActionRec.Id);
            }
        }
        
        // added validation to call the class if their related list size is greater than zero
        if(sendLetterList.size() > 0){
            GlUt_CreateLetter.sendLetter(sendLetterList,GlUt_APIConstantsDebtRecoveryAction.DEBTRECOVERYACTIONAPINAME,queryFields);
        }
        if(addSIList.size() > 0){
            DrUt_AddServiceItems.addServiceItem(addSIList); 
        }
        if(generateBillList.size() > 0){
            DrUt_GenerateBill.generateBill(generateBillList);  //Generate Bill
        }
        if(changeRecoveryProfileList.size() > 0){
            //processing Debt Recovery Action records of type 'Change Recovery Profile'
            DrUt_UpdateRecoveryProfile.updateRecoveryProfile(changeRecoveryProfileList);
        }
        System.debug('300.2 changePaymentPlan == '+changePaymentPlan);
        // Chnaged By Dependra - 13-11-2018 - 
        if(changePaymentPlan.size() > 0){
            //processing Debt Recovery Action records of type 'Change Payment Plan' 
            DrUt_ChangePaymentPlan.updatePayment(changePaymentPlan);
        }
        if(markForDisconnectionList.size() > 0){
            //MT - 01 Feb 2018 processing Debt Recovery Action records of type 'Mark For Disconnection'
            DrUt_MarkForDisconnection.markForDisconnection(markForDisconnectionList);
        }
    }    
    /******************************************************************************
    @author         Sudhir Kumar
    @date           10 Oct 2018
	@param			Database.BatchableContext bc
    @description    finish method for Batchable interface
					AT-3971 - Dynamic SOQL for DrBt_ProcessAction - Added Header (Security Review)
    *******************************************************************************/	
    global void finish(Database.BatchableContext bc){
        
    }    
    
}