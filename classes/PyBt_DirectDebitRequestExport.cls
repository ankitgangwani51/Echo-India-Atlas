/******************************************************************************
    @author         Echo: Amit K.
    @date           19 June 2018
    @description    Batch class to create Direct Debit Request having Due Instalment on Contract
*******************************************************************************/
global with sharing class PyBt_DirectDebitRequestExport extends GlBt_BatchProcess  implements Database.Batchable<sObject>,Database.Stateful {
    private static final String CLASS_NAME = 'PyBt_DirectDebitRequest';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static List<string> instalmentFields;
    static{
        instalmentFields = new List<string>();
        instalmentFields.add(GlUt_APIConstantsInstalment.INSTALMENTAMOUNTDUEAPINAME); 
        instalmentFields.add(GlUt_APIConstantsInstalment.INSTALMENTAMOUNTOUTSTANDING);
        instalmentFields.add(GlUt_APIConstantsInstalment.INSTALMENTDUEDATEAPINAME);
        instalmentFields.add(GlUt_APIConstantsInstalment.CONTRACTORDERRELAPINAME);
        
    }
    private static List<string> directDebitRequestStatus;
    static{
        directDebitRequestStatus = new List<string>();
        directDebitRequestStatus.add(PyBt_Constants.DIRECT_DEBIT_REQUEST_STATUS_PENDING); 
        directDebitRequestStatus.add(PyBt_Constants.DIRECT_DEBIT_REQUEST_STATUS_CONFIRMED);
    }
    global Date requestDate;
    global BatchRequestQueue__c batchRequestQueue;
    global static string sQuery;
 
    /******************************************************************************
    @author         Echo: Amit K.
    @date           19 JUNE 2018
    @description    Override GlBt_BatchProcess method as per Batch framework.
    *******************************************************************************/
    global override void Initialise(BatchRequestQueue__c brq){
        this.batchRequestQueue = brq ;
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           19 JUNE 2018
    @description    Batch's start method
   *******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        //Update Batch Request Queue to Completed.
        //AT-3204 Starts Here
        BatchRequestQueue__c brq = [SELECT Id,Status__c FROM BatchRequestQueue__c WHERE Id=:batchRequestQueue.Id Limit 1];			
        brq.Status__c = GlUt_Constants.BATCH_REQUEST_QUEUE_STATUS_PROCESSING;
        update brq;
        //AT-3204 Ends Here
        PyPr_DirectDebitRequestParameters objDirectDebitRequestParamters;
        //Parse batch request queue paramter field.
        
        objDirectDebitRequestParamters = PyPr_DirectDebitRequestParameters.parse(batchRequestQueue.Parameters__c);
        requestDate = objDirectDebitRequestParamters.requestDate;
        List<Instalment__c> lstInstalment = new List<Instalment__c>();
        List<Instalment__c> finalInstalmentList = new List<Instalment__c>();
        Map<Id,Id> mapOfInstalmentId2DDRId = new Map<Id,Id>();
        if(requestDate != null){
            //Fetch the INSTALMENT on the basis of requested date,Instalment Amount Outstanding and Payment method Type = Direct Debit
            lstInstalment = [SELECT Id,
                             InstalmentDueDate__c,
                             InstalmentAmountOutstanding__c,
                             PaymentPlan__r.BillingContract__c FROM Instalment__c WHERE InstalmentDueDate__c <=: requestDate //AT-3174
                             AND InstalmentAmountOutstanding__c > 0
                             AND PaymentPlan__r.BillingContract__r.PaymentMethodType__r.Name =: PyBt_Constants.PAYMENT_METHOD_TYPE_DIRECTDEBIT//AT-3174
                             AND PaymentPlan__r.Active__c = True]; //Add an Extra Condition as per AT-3159 Starts Here and Ends here.
        }
       // If list of instalment not empty
        if(!lstInstalment.isEmpty()){
            //Fetch the DDR records on the basis of Due Installment and Status = 'Pending','Confirmed'
            for(DirectDebitRequest__c objDDR : [SELECT Id,
                                                Instalment__c,
                                                BillingContract__c FROM DirectDebitRequest__c 
                                                WHERE Instalment__c IN: lstInstalment AND Status__c IN:directDebitRequestStatus]){
                                                mapOfInstalmentId2DDRId.put(objDDR.Instalment__c,objDDR.Id);// map of Due Instalment Id having List of DDR ID with Status = 'Pending','Confirmed'
                                                }
            // Create final list of installment
            for(Instalment__c objInstalment : lstInstalment){
                if(!mapOfInstalmentId2DDRId.containsKey(objInstalment.Id))
                    finalInstalmentList.add(objInstalment); // Get the final list of installment which don't have DDR record having Status = PENDING OR CONFIRMED
            }
        }
        sQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(instalmentFields,','), 
            GlUt_APIConstantsInstalment.INSTALMENTAPINAME +' Where Id IN: finalInstalmentList'
            });
        return Database.getQueryLocator(sQuery);
        
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           19 JUNE 2018
    @description    Batch's execute method
    *******************************************************************************/
    global void execute(Database.BatchableContext bc, List<sObject> scope){ 
        try{          
            List<DirectDebitRequest__c> directDebitRequestList = new List<DirectDebitRequest__c>();
            Map<Id,Id> mapOfContractIdToDDRId = new Map<Id,Id>();
            Map<Id,Boolean> mapOfContractIdToBankRequest = new Map<Id,Boolean>();
            List<Instalment__c> instalmentList = (List<Instalment__c>) scope; 
            Map<Id,Id> mapOfInstalmentId2ContractSpecificDDRId = new Map<Id,Id>(); 
            //Fetch Direct Debit Request having Contract Associated with them with specific instalments.
            for(DirectDebitRequest__c ddr: [SELECT Id,Instalment__c,BillingContract__c FROM DirectDebitRequest__c 
                                            WHERE Instalment__c IN: instalmentList AND BillingContract__c != null]){ // order by need to add, AT-4912
                mapOfInstalmentId2ContractSpecificDDRId.put(ddr.Instalment__c,ddr.Id); // Map of Instalment Id having Contract specific DD Request.
                //AT-4912
                mapOfContractIdToDDRId.put(ddr.BillingContract__c, ddr.Id); 
            }
            
            directDebitRequestList = [SELECT Id, BillingContract__c, BillingContract__r.BankAccountDetails__c,
                                     BankAccountDetails__c FROM DirectDebitRequest__c
                                      WHERE Id=:mapOfContractIdToDDRId.values()
                                      AND BillingContract__c=:mapOfContractIdToDDRId.keySet()
                                      AND Status__c=:PyBt_Constants.DIRECT_DEBIT_REQUEST_STATUS_CONFIRMED];
            
            if(!directDebitRequestList.isEmpty() && directDebitRequestList.size() > 0){
                for(DirectDebitRequest__c ddr : directDebitRequestList){
                    if(ddr.BillingContract__r.BankAccountDetails__c == ddr.BankAccountDetails__c){
                        if(!mapOfContractIdToBankRequest.containsKey(ddr.BillingContract__c))
                            mapOfContractIdToBankRequest.put(ddr.BillingContract__c,false);
                    }
                }
            }
            
            List<DirectDebitRequest__c> newListDDR = new List<DirectDebitRequest__c>();
            if(instalmentList != null && !instalmentList.isEmpty()){
                for(Instalment__c objInstalment : instalmentList){
                    Boolean contractFirstRequest = true;
                    //Check if we already have contract specific DDRequest.
                    if(mapOfInstalmentId2ContractSpecificDDRId.containsKey(objInstalment.Id)){
                        contractFirstRequest = false;
                    }
                    DirectDebitRequest__c objDDR = new DirectDebitRequest__c();
                    objDDR.BillingContract__c = objInstalment.PaymentPlan__r.BillingContract__c; //AT-3174
                    objDDR.Instalment__c = objInstalment.Id;
                    objDDR.FirstRequestForBankAccount__c = mapOfContractIdToBankRequest.containsKey(objInstalment.PaymentPlan__r.BillingContract__c) ? mapOfContractIdToBankRequest.get(objInstalment.PaymentPlan__r.BillingContract__c) : true;
                    //Need to update the DDR.BankAccount from Contract.BankAccount, AT-4912
                    // If there is no DD Request having Contract Associated with it.
                    if(contractFirstRequest)
                        objDDR.TransactionCode__c = PyBt_Constants.DIRECT_DEBIT_REQUEST_TRANSACTION_CODE_01;
                    else
                        objDDR.TransactionCode__c = PyBt_Constants.DIRECT_DEBIT_REQUEST_TRANSACTION_CODE_17;
                    objDDR.ZeroMarker__c = PyBt_Constants.DIRECT_DEBIT_REQUEST_ZERO_MARKER;
                    objDDR.Status__c = PyBt_Constants.DIRECT_DEBIT_REQUEST_STATUS_PENDING;
                    objDDR.RequestDate__c = objInstalment.InstalmentDueDate__c;
                    newListDDR.add(objDDR);
                }
            }
            //Create Direct Debit Request With Status = Pending
            if(!newListDDR.isEmpty()){
                //Partial Insertion
                newListDDR = (List<DirectDebitRequest__c>) GlUt_FieldSecurity.cleanseFields(newListDDR, false);
                Database.insert(newListDDR,false);
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
            //Update Batch Request Queue to Completed.
            BatchRequestQueue__c brq = [SELECT Id,Status__c FROM BatchRequestQueue__c WHERE Id=:batchRequestQueue.Id Limit 1];			
            brq.Status__c = GlUt_Constants.BATCH_REQUEST_QUEUE_STATUS_COMPLETED;
            brq = (BatchRequestQueue__c) GlUt_FieldSecurity.cleanseFields(brq, false);
            update brq;
        }
        catch (exception e){
            GlUt_Logger.logException(e);
            Database.rollback(sp);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
}