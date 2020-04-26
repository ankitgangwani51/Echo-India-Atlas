/******************************************************************************
@author         Echo: Sudhir Kumar
@date           5 June 2018
@description    Batch class for Bill Data Transfer XML Extract
@revision		Echo: Sudhir - AT-3950 Dynamic SOQL for BlBt_BillDataTransferXMLExtract  (Security Review)
                AT-4891/2 Code Check Marx Changes for FLS INSERT/UPDATE
*******************************************************************************/

global  with sharing class BlBt_BillDataTransferXMLExtract extends GlBt_BatchProcess 
                                             implements 
                                             Schedulable,
                                             Database.Batchable<SObject>, 
                                             Database.Stateful,
                                             Database.AllowsCallouts    {
    
    global static final String CLASS_NAME = 'BlBt_BillDataTransferXMLExtract';
    global static final String DEBUG = '[' + CLASS_NAME + '] ';
    global static final String CRLF = '\r\n';
    global static final Integer  BATCHSIZE =  50 ;
    
    global String batchRequestQueueId;
    global Set<Id> extractContracts =  new Set<Id>();   // set of contract Ids for which data has been extracted                                             
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           10 Oct 2018
    @param          SchedulableContext SC
    @return         void
    @description    Makes this batch schedulable
	@revision		AT-3950: Added method header
    *******************************************************************************/
    global void execute(SchedulableContext SC) {	// so that it could be scheduled from Salesforce standard UI
        
        Database.executeBatch(new BlBt_BillDataTransferXMLExtract(), BATCHSIZE) ;
    }
        
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           5 June 2018
    @param          BatchRequestQueue__c batchRequest
    @description    Initialises the batch job
    *******************************************************************************/
    global override void initialise(BatchRequestQueue__c batchRequestQueue) {	// so that it could be scheduled from BRQ - Batch framework
        
        // Initialise Contract
        extractContracts = new Set<Id>();
        // local copy of the Batch Request Queue Id to update status etc
        batchRequestQueueId = batchRequestQueue.Id;
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           5 June 2018
    @param          Database.BatchableContext BC
    @return         Database.QueryLocator
    @description    Initialises the batch job
    *******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString;
        // Added By Dependra AU1- AT-4047       
        queryString= String.format('SELECT {0} FROM {1}' , new List<String> {'Id, ' + String.join(BlUt_BillXMLContainer.billFieldList , ',') , GlUt_APIConstantsBill.BILLAPINAME   // AU1: AT-4098
            + ' WHERE ' + GlUt_APIConstantsBill.DATAXMLAPINAME +  ' = false' 
            + ' AND '+ GlUt_APIConstantsBill.BILL_TYPE + ' = \''+ BlBt_Constants.BILL_TYPE_NORMAL  + '\''
            + ' AND '+ GlUt_APIConstantsBill.PRINTXMLAPINAME + ' = false'
            + ' AND '+ GlUt_APIConstantsBill.DONOTPRINTAPINAME + ' = false'
            + ' ORDER By BillDate__c Desc '});
        SYSTEM.debug('queryString '   + queryString);
        
        return Database.getQueryLocator(queryString) ;  
        
    }
                                                 
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           5 June 2018
    @param          Database.BatchableContext BC
    @param          List<SObject> scope
    @description    Initialises the batch job
	@revision		Echo:Sudhir - // AU1: AT-4098
    *******************************************************************************/
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        try {
            system.debug('scope====='+scope);
            HttpResponse httpResponse ;
            List<Bill__c> billList = (List<Bill__c>) scope ;
            map<Id, Balance__c> mapContractId2ContractBalance = new map<Id, Balance__c>() ;        
            //BlUt_BillXMLContainer dataTransferXmlExt = new BlUt_BillXMLContainer(billList); // XML formation process starts here // AU1: AT-4098
            BlUt_BillXMLContainer dataTransferXmlExt = new BlUt_BillXMLContainer(); // XML formation process starts here // AU1: AT-4098
            string xmlDocString = dataTransferXmlExt.getDataTransferXmlString(billList) ; // AU1: AT-4098
            System.debug('xmlDocString = '+xmlDocString);
            if(String.isNotBlank(xmlDocString)) {
                GlUt_AWSS3AddFileToBucket addFileS3Service = new GlUt_AWSS3AddFileToBucket(GlUt_AWSConstants.ECHODATATRANSFERXMLS3BUCKET) ;   
                addFileS3Service.payloadXml = xmlDocString.unescapeHtml4() ;
                addFileS3Service.resourceName =  GlUt_AWSConstants.DATA_TRANSFER_XML_FILE_NAME + 
                                                 DateTime.now().format(GlUt_AWSConstants.DATETIMEFORMAT) +  
                                                 GlUt_AWSConstants.XMLFILEEXTENSION ;
                httpResponse = addFileS3Service.addFileToBucket() ;  
            }
            if(httpResponse != null && httpResponse.getStatusCode() != 200 && batchRequestQueueId != null) {
                BatchError__c batchError = new BatchError__c(
                    BatchRequestOperation__c = BlBt_Constants.BATCHREQUESTOPERATION ,
                    ErrorDetails__c = 'Body= ' + httpResponse.getBody() + ' . ' + httpResponse.toString() ,
                    BatchRequestQueue__c = batchRequestQueueId ,
                    OperatingRecordType__c = BlBt_Constants.OPERATINGRECORDTYPE 
                ) ;
            } else if(httpResponse.getStatusCode() == 200) {
                for(Bill__c oBill : billList) {
                    
                    if(!mapContractId2ContractBalance.containsKey(oBill.BillingContract__c)) {
                        Balance__c oBalance = new Balance__c(Id = oBill.BillingContract__r.Balance__c, BalanceSnapshot__c = oBill.BillingContract__r.ContractBalance__c);
                        mapContractId2ContractBalance.put(oBill.BillingContract__c, oBalance) ;
                        extractContracts.add(oBill.BillingContract__c) ;
                    }                    
                }
                if(!mapContractId2ContractBalance.values().isEmpty()) {
                    List<Balance__c> contractBalanceList = (List<Balance__c>) GlUt_FieldSecurity.cleanseFields(mapContractId2ContractBalance.values(), false); //AT-4892 Code Check Marx Changes Starts/Ends Here.
                    Database.update(contractBalanceList) ;
                }
            }
            
        } catch(Exception oException) {
            GlUt_Logger.logDebug(DEBUG + 'Executing execute method');
            GlUt_Logger.logException(oException);
            GlUt_Logger.writeLogsToDatabase();
        } finally {
            //GlUt_Logger.writeLogsToDatabase();
        }
        
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           11 June 2018
    @param          Database.BatchableContext BC
    @description    post batch processing logic
    *******************************************************************************/
                                                 
    global void finish(Database.BatchableContext BC) {
        
        try {
            String filename = GlUt_AWSConstants.DATA_TRANSFER_XML_BATCH_REPORT + 
                              System.now().format(GlUt_AWSConstants.DATETIMEFORMAT) + 
                              GlUt_AWSConstants.REPORT_FILE_EXTENSION;
            // create the report file
            Integer numberOfContracts = extractContracts.size();
            String report = 'Number of contracts extracted: ' + String.valueOf(numberOfContracts) + CRLF;
            report += 'List of contract Ids: ' + CRLF;
            for (Id contractId : extractContracts) {
                report += contractId + CRLF;
            }
            // write the report file and link it to the Batch Request Queue
            Id reportId;           
            if(batchRequestQueueId != null) {   // execute only when this batch is invoked from BRQ batch framework
                reportId = GlUt_ContentDocument.saveLinkedDocument(batchRequestQueueId, GlUt_AWSConstants.DATA_TRANSFER_XML_WORKSPACE, filename, filename, GlUt_AWSConstants.SHARE_TYPE, Blob.valueOf(report));
                // Update the Batch Request Queue Status to ‘Completed’
                /*AT-4373 Clayton Code Review Starts Here*/
                BatchRequestQueue__c brq = [SELECT Id, Status__c FROM BatchRequestQueue__c WHERE Id =: batchRequestQueueId];
                    if(brq != null && brq.Status__c != Label.GlUt_BatchRequestQueueStatusErrors){
                        brq.Status__c = Label.GlUt_BatchRequestQueueStatusCompleted;
                        brq = (BatchRequestQueue__c) GlUt_FieldSecurity.cleanseFields(brq, false); //AT-4892 Code Check Marx Changes Starts/Ends Here.
                        update brq;
                    }
                
               /* for(BatchRequestQueue__c brq : [SELECT Id, Status__c FROM BatchRequestQueue__c WHERE Id =: batchRequestQueueId]) {
                    if (brq.Status__c != Label.GlUt_BatchRequestQueueStatusErrors) {
                        brq.Status__c = Label.GlUt_BatchRequestQueueStatusCompleted;
                        update brq;
                    } 
                }*/
                /*AT-4373 Clayton Code Review Ends Here*/
            }
                                             
        } catch(Exception oException) {
            GlUt_Logger.logException(oException);
        } finally {
            GlUt_Logger.writeLogsToDatabase();
        }
    }  
                                           
}