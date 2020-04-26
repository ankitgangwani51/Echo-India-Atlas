/******************************************************************************
@author         Echo: Amit K.
@date           04 July 2018
@description    Bank Account Action Process Action batch for processing the records.
*******************************************************************************/
global with sharing class PyBt_ProcessActions  extends GlBt_BatchProcess implements Database.Batchable<sObject>,Database.Stateful   {
    private static final String CLASS_NAME = 'PyBt_ProcessActions';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static List<string> bankAccountActionFields;
    static{
        bankAccountActionFields = new List<string>();
        bankAccountActionFields.add(GlUt_APIConstantsBankAccountAction.ACTIONAPINAME);
        bankAccountActionFields.add(GlUt_APIConstantsBankAccountAction.PARAMETERAPINAME);
        bankAccountActionFields.add(GlUt_APIConstantsBankAccountAction.STATUSAPINAME);
        bankAccountActionFields.add(GlUt_APIConstantsBankAccountAction.BILLINGCONTRACTRELAPINAME);
        bankAccountActionFields.add(GlUt_APIConstantsBankAccountAction.BANKSORTCODERELAPINAME);
        bankAccountActionFields.add(GlUt_APIConstantsBankAccountAction.NAMEONACCOUNTRELAPINAME);
        bankAccountActionFields.add(GlUt_APIConstantsBankAccountAction.BANKACCOUNTNUMBERRELAPINAME);
        bankAccountActionFields.add(GlUt_APIConstantsBankAccountAction.CUSTOMERNAMERELAPINAME);
        bankAccountActionFields.add(GlUt_APIConstantsBankAccountAction.BANKACCOUNTCHANGEAPINAME);
        bankAccountActionFields.add(GlUt_APIConstantsBankAccountAction.BANKACCOUNTDETAILSRELAPINAME);
        bankAccountActionFields.add(GlUt_APIConstantsBankAccountAction.DIRECTDEBITRETURNAPINAME);
        bankAccountActionFields.add(GlUt_APIConstantsBankAccountAction.DIRECTDEBITREQUESTRELAPINAME);
        bankAccountActionFields.add(GlUt_APIConstantsBankAccountAction.PAYMENTRELAPINAME);
        bankAccountActionFields.add(GlUt_APIConstantsBankAccountAction.DIRECTDEBITRETURNCONTRACTRELAPINAME);
        bankAccountActionFields.add(GlUt_APIConstantsBankAccountAction.DIRECTDEBITRETURNCONTRACTBALANCERELAPINAME);
        bankAccountActionFields.add(GlUt_APIConstantsBankAccountAction.BANKACCOUNTCHANGECONTRACTBALANCERELAPINAME);
        bankAccountActionFields.add(GlUt_APIConstantsBankAccountAction.DIRECTDEBITRETURNCONTRACTCUSTOMERNAMERELAPINAME);
        bankAccountActionFields.add(GlUt_APIConstantsBankAccountAction.ACCOUNTNAMERELAPINAME); //AT-3124 starts/Ends here
    }
  
    global Date requestDate;
    global BatchRequestQueue__c batchRequestQueue;
    global static string sQuery;
 
    /******************************************************************************
    @author         Echo: Amit K.
    @date           21 JUNE 2018
    @description    Override GlBt_BatchProcess method as per Batch framework.
    *******************************************************************************/
    global override void Initialise(BatchRequestQueue__c brq){
        this.batchRequestQueue = brq ;
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           21 JUNE 2018
    @description    Batch's start method
   *******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        	//Query formation to fetch the Bank Account Action records.	
		    sQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(bankAccountActionFields,','), 
                     GlUt_APIConstantsBankAccountAction.BANKACCOUNTACTIONAPINAME +' WHERE ' + 
                     GlUt_APIConstantsBankAccountAction.STATUSAPINAME + ' != \'' + PyBt_Constants.BANK_ACCOUNT_ACTION_PROCESSED + '\''+ ' Order By CreatedDate'
					  });
        return Database.getQueryLocator(sQuery);
        
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           21 JUNE 2018
    @description    Batch's execute method
    *******************************************************************************/
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        Savepoint sp = Database.setSavepoint();
        try{          
            List<BankAccountAction__c> bankAccountActionList = (List<BankAccountAction__c>) scope; 
            System.debug(DEBUG +'****bankAccountActionList'+bankAccountActionList);
            //Change Payment Plan Bank Account Action Record List
			List<BankAccountAction__c> changePaymentPlanList     = new List<BankAccountAction__c>();
            //Create Correspondence Bank Account Action Record List
			List<BankAccountAction__c> createCorrespondenceList	 = new List<BankAccountAction__c>();
            //Update Bank Details Bank Account Action Record List
			List<BankAccountAction__c> updateBankDetailsList	 = new List<BankAccountAction__c>();
            //Return Payment Bank Account Action Record List
			List<BankAccountAction__c> returnPaymentList         = new List<BankAccountAction__c>();
            for(BankAccountAction__c objBankAccountAction : bankAccountActionList){
                if(objBankAccountAction.Action__c == PyBt_Constants.BANK_ACCOUNT_ACTION_CHANGE_PAYMEMENT_PLAN){
                    changePaymentPlanList.add(objBankAccountAction);
                }else if(objBankAccountAction.Action__c == PyBt_Constants.BANK_ACCOUNT_ACTION_CREATE_CORRESPONDENCE){
                    createCorrespondenceList.add(objBankAccountAction);
                }else if(objBankAccountAction.Action__c == PyBt_Constants.BANK_ACCOUNT_ACTION_UPDATE_BANK_DETAILS){
                    updateBankDetailsList.add(objBankAccountAction);
                }else if(objBankAccountAction.Action__c == PyBt_Constants.BANK_ACCOUNT_ACTION_RETURN_PAYMENT){
                    returnPaymentList.add(objBankAccountAction);
                }
            }
            //Call DrUt_ChangePaymentPlan Class
            if(!changePaymentPlanList.isEmpty()){
				DrUt_ChangePaymentPlan.changePaymentPlan(changePaymentPlanList);
			}
            //Call GlUt_CorrespondenceHandler Class
			if(!createCorrespondenceList.isEmpty()){
                List<GlUt_CorrespondenceHandler.ContainerWrapper> wrapperList = new List<GlUt_CorrespondenceHandler.ContainerWrapper>();
                for(BankAccountAction__c records :  createCorrespondenceList){
                    //Billing Contract will be always mandatory on Bank Account Change and Direct Debit Return.
                    //AT-3124 Starts Here
                    if(records.BankAccountChange__c != null){
                        wrapperList.add(new GlUt_CorrespondenceHandler.ContainerWrapper(records.BankAccountChange__r.BillingContract__r.AccountName__c, records.Id, records.Parameters__c,null,null));
                    }
                    else if(records.DirectDebitReturn__c != null){
                        wrapperList.add(new GlUt_CorrespondenceHandler.ContainerWrapper(records.DirectDebitReturn__r.BillingContract__r.AccountName__c, records.Id, records.Parameters__c,null,null));
                    }
                    //AT-3124 Ends Here
                }
                if(!wrapperList.isEmpty()){
                    List<GlUt_CorrespondenceHandler.ContainerWrapper> wrapperStatusList = new List<GlUt_CorrespondenceHandler.ContainerWrapper>();
                    //Processed Record with Status.
                    wrapperStatusList =  GlUt_CorrespondenceHandler.CreateCorrespondence(wrapperList);
                    Map<Id,String> mapOfBankAccountActionRecordId2Status = new Map<Id,String>(); // Map of Bank Account Action record Id having Actual Status.
                    for(GlUt_CorrespondenceHandler.ContainerWrapper values: wrapperStatusList){
                        mapOfBankAccountActionRecordId2Status.put(values.recordId,values.Status);
                    }
                    if(!mapOfBankAccountActionRecordId2Status.isEmpty()){
                        List<BankAccountAction__c> changeBAAStatusList = new List<BankAccountAction__c>();
                        for(BankAccountAction__c records :  createCorrespondenceList){
                            if(mapOfBankAccountActionRecordId2Status.containsKey(records.Id)){
                                records.Status__c = mapOfBankAccountActionRecordId2Status.get(records.Id);
                                changeBAAStatusList.add(records);
                            }
                        }
                        //Update record status to Processed.
                        if(!changeBAAStatusList.isEmpty()){
                            DataBase.update(changeBAAStatusList);
                        }
                    }
                }
            }
            //Call PyBt_ChangeBankDetails Class
			if(!updateBankDetailsList.isEmpty()){
                PyBt_ChangeBankDetails.updateBankDetails(updateBankDetailsList);
			}
            //Call PyBt_ReturnPayment Class
			if(!returnPaymentList.isEmpty()){
                PyBt_ReturnPayment.returnPayment(returnPaymentList);
			}
           
        }
        catch (exception e){
            Database.rollback(sp);
            GlUt_Logger.logException(e);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    } 
   /******************************************************************************
    @author         Echo: Amit K.
    @date           21 June 2018
    @description    Batch's final method
   *******************************************************************************/
    global void finish(Database.BatchableContext bc){
        Savepoint sp = Database.setSavepoint();
        try{
            // In future we have use of this code. 
            //Change the BRQ status to Completed --> Uncommented this code once batch framework comes in to picture.
            /* BatchRequestQueue__c brq = [Select Id,Status__c from BatchRequestQueue__c where Id=:batchRequestQueue.Id Limit 1];			
            brq.Status__c = GlUt_Constants.BATCH_REQUEST_QUEUE_STATUS_COMPLETED;
			update brq;*/
        }
        catch (exception e){
            GlUt_Logger.logException(e);
            Database.rollback(sp);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
}