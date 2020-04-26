/******************************************************************************
    @author         Echo: Amit K.
    @date           21 JUNE 2018
    @description    Batch class to change status of all Bank Account Change records where Status not equal to ‘Processed’
*******************************************************************************/

global with sharing class PyBt_BankAccountChangeProcessActions  extends GlBt_BatchProcess implements Database.Batchable<sObject>,Database.Stateful   {
    private static final String CLASS_NAME = 'PyBt_BankAccountChangeProcessActions';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static List<string> bankAccountChangeFields;
    static{
        bankAccountChangeFields = new List<string>();
        bankAccountChangeFields.add(GlUt_APIConstantsBankAccountChange.STATUSAPINAME); 
    }
    
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
        
        sQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(bankAccountChangeFields,','), 
            GlUt_APIConstantsBankAccountChange.BANKACCOUNTCHANGEAPINAME +' WHERE ' + 
            GlUt_APIConstantsBankAccountChange.STATUSAPINAME +' != \'' + PyBt_Constants.BANK_ACCOUNT_ACTION_PROCESSED + '\''
            });
        try{   
            List<BatchRequestQueue__c> brqList = [Select Id,Status__c from BatchRequestQueue__c where Id=:batchRequestQueue.Id Limit 1];
            if(!brqList.isEmpty()) {
                brqList[0].Status__c = GlUt_Constants.BATCH_REQUEST_QUEUE_STATUS_PROCESSING;
                brqList = (List<BatchRequestQueue__c>) GlUt_FieldSecurity.cleanseFields(brqList, false);
                update brqList;
            }
        } catch (exception e){
            GlUt_Logger.logException(e);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return Database.getQueryLocator(sQuery);
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           21 JUNE 2018
    @description    Batch's execute method
    *******************************************************************************/
    global void execute(Database.BatchableContext bc, List<sObject> scope){ 
        try{          
            List<BankAccountChange__c> bankAccountChangeList = (List<BankAccountChange__c>) scope; 
            for(BankAccountChange__c bankAccountChangeObject: bankAccountChangeList){
                bankAccountChangeObject.Status__c = PyBt_Constants.DIRECT_DEBIT_REQUEST_STATUS_PENDING;
            }
            if(!bankAccountChangeList.isEmpty()){
                bankAccountChangeList = (List<BankAccountChange__c>) GlUt_FieldSecurity.cleanseFields(bankAccountChangeList, false);
                update bankAccountChangeList;
            }
        }
        catch (exception e){
            GlUt_Logger.logException(e);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    } 
    /******************************************************************************
    @author         Echo: Amit K.
    @date           21 May 2018
    @description    Batch's final method
    *******************************************************************************/
    global void finish(Database.BatchableContext bc){
        Savepoint sp = Database.setSavepoint();
        try{
            List<BatchRequestQueue__c> brqList = [Select Id,Status__c from BatchRequestQueue__c where Id=:batchRequestQueue.Id Limit 1];	
            if(!brqList.isEmpty())
            {
                brqList[0].Status__c = GlUt_Constants.BATCH_REQUEST_QUEUE_STATUS_COMPLETED;
                brqList = (List<BatchRequestQueue__c>) GlUt_FieldSecurity.cleanseFields(brqList, false);
                update brqList;
            }
        }
        catch (exception e){
            GlUt_Logger.logException(e);
            Database.rollback(sp);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
}