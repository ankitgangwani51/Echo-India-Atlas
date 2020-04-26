/******************************************************************************
    @author         Echo: Vivek Sethi
    @date           03 july 2018
    @description    Batch class to change status of  All Direct Debit Return records where Status not equal to ‘Processed’
*******************************************************************************/

global with sharing class PyBt_DirectDebitReturnProcess  extends GlBt_BatchProcess implements Database.Batchable<sObject>,Database.Stateful   {
    private static final String CLASS_NAME = 'PyBt_DirectDebitReturnProcess';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static List<string> directDebitReturnFields;
    static{
        directDebitReturnFields = new List<string>();
        directDebitReturnFields.add(GlUt_APIConstantsDirectDebitReturn.STATUSAPINAME); 
    }
    
    global BatchRequestQueue__c batchRequestQueue;
    global static string sQuery;
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           03 july 2018
    @description    Override GlBt_BatchProcess method as per Batch framework.
    *******************************************************************************/
    global override void Initialise(BatchRequestQueue__c brq){
        this.batchRequestQueue = brq ;
    }
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           03 july 2018
    @description    Batch's start method
    *******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        
        sQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(directDebitReturnFields,','), 
            GlUt_APIConstantsDirectDebitReturn.DIRECTDEBITRETURNAPINAME +' WHERE ' + 
            GlUt_APIConstantsDirectDebitReturn.STATUSAPINAME +' != \'' + PyBt_Constants.DIRECT_DEBIT_RETURN_PROCESSED + '\''
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
    @author         Echo: Vivek Sethi
    @date           03 july 2018
    @description    Batch's execute method
    *******************************************************************************/
    global void execute(Database.BatchableContext bc, List<sObject> scope){ 
        try{          
            List<DirectDebitReturn__c> directDebitReturnList = (List<DirectDebitReturn__c>) scope; 
            for(DirectDebitReturn__c directDebitReturnObject: directDebitReturnList){
                directDebitReturnObject.Status__c = PyBt_Constants.DIRECT_DEBIT_REQUEST_STATUS_PENDING;
            }
            if(!directDebitReturnList.isEmpty()){
                directDebitReturnList = (List<DirectDebitReturn__c>) GlUt_FieldSecurity.cleanseFields(directDebitReturnList, false);
                update directDebitReturnList;
            }
            
        }
        catch (exception e){
            system.debug('Here in except *** ');
            GlUt_Logger.logException(e);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    } 
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           03 july 2018
    @description    Batch's final method
    *******************************************************************************/
    global void finish(Database.BatchableContext bc){
        Savepoint sp = Database.setSavepoint();
        try{
            List<BatchRequestQueue__c> brqList = [Select Id,Status__c from BatchRequestQueue__c where Id=:batchRequestQueue.Id Limit 1];	
            if(!brqList.isEmpty()){
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