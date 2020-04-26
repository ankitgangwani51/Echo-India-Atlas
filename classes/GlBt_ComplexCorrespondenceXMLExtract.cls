/******************************************************************************
@author         Echo: Patrick Dixon
@date           29 May 2018
@description    Batch class for complex correspondence
*******************************************************************************/
global  with sharing class GlBt_ComplexCorrespondenceXMLExtract extends GlBt_BatchProcess implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    
    global static final String CLASS_NAME = 'GlBt_ComplexCorrespondenceXMLExtract';
    global static final String DEBUG = '[' + CLASS_NAME + '] ';
    global static final String CRLF = '\r\n';
    
	global String batchRequestQueueId;
	global Set<Id> contractIds;		// set of contract Ids for which data has been extracted

    /******************************************************************************
	@author         Echo: Patrick Dixon
	@date           29 May 2018
    @param          BatchRequestQueue__c batchRequest
	@description    Initialises the batch job
	*******************************************************************************/
    global override void initialise(BatchRequestQueue__c batchRequestQueue) {
    	
    	// initialise the set of contract Ids for the report
		contractIds = new Set<Id>();

    	// local copy of the Batch Request Queue Id to update status etc
    	batchRequestQueueId = batchRequestQueue.Id;
    }
    
    /******************************************************************************
	@author         Echo: Patrick Dixon
	@date           29 May 2018
    @param          Database.BatchableContext BC
    @return			Database.QueryLocator
	@description    Initialises the batch job
	*******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        // MT - 22-08-2018 Start of AT-3410 Fix the query
        List<String> lstPDFRequest = new List<String>{
            'Id',
            GlUt_APIConstantsPDFRequest.ACCOUNT,
            GlUt_APIConstantsPDFRequest.CONTACT,
            GlUt_APIConstantsPDFRequest.CONTRACT,
            GlUt_APIConstantsPDFRequest.SOURCE_TYPE,
            GlUt_APIConstantsPDFRequest.STATUS,
            GlUt_APIConstantsPDFRequest.CORRESPONDENCE_TYPE,
            GlUt_APIConstantsPDFRequest.RELATED_ACCOUNT + '.' + GlUt_APIConstantsAccount.RECORD_TYPE_ID,
            GlUt_APIConstantsPDFRequest.RELATED_CONTRACT + '.' + GlUt_APIConstantsContracts.PAYMENTMETHODTYPEAPINAME,
            GlUt_APIConstantsPDFRequest.RELATED_CONTRACT + '.' + GlUt_APIConstantsContracts.CURRENTPAYMENTPLANTYPE
        };
    	//Id test = 'a1b1v000002yyPtAAI';
        
        String listFilter = GlUt_APIConstantsPDFRequest.SOURCE_TYPE + ' = \'' + Label.GlUt_PDFRequestSourceTypeDataTransferXML + '\' AND ' + GlUt_APIConstantsPDFRequest.STATUS +
                            ' = \'' + Label.GlUt_PDFRequestStatusPending + '\'';
        //listFilter += ' AND Id  ' + ' = \'' + test + '\'' ;
        system.debug('listFilter***'+ listFilter);
		// build the query
        String query = String.format('SELECT {0} FROM {1} WHERE {2}', new List<String>{String.join(lstPDFRequest, ','),GlUt_APIConstantsPDFRequest.OBJECTAPINAME,listFilter}) ;
        // End of AT-3410
        
		// Update the Batch Request Queue Status to ‘Processing’
		for (BatchRequestQueue__c batchRequestQueue : [select Id from BatchRequestQueue__c where Id = :batchRequestQueueId]) {
            batchRequestQueue.Status__c = Label.GlUt_BatchRequestQueueStatusProcessing;
            batchRequestQueue  = (BatchRequestQueue__c) GlUt_FieldSecurity.cleanseFields(batchRequestQueue, false);
            update batchRequestQueue;
            break;
		}

		return Database.getQueryLocator(query);    	
    }
    
    /******************************************************************************
	@author         Echo: Patrick Dixon
	@date           29 May 2018
    @param          Database.BatchableContext BC
    @param			List<SObject> scope
	@description    Initialises the batch job
	*******************************************************************************/
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
    	
		Boolean error = true;
		HttpResponse response;
		try {
			
			// extract all the data and generate the XML document
	    	GlUt_ComplexCorrespondenceDataContainer batchData = new GlUt_ComplexCorrespondenceDataContainer((List<PDFRequest__c>) scope);
	
	    	// setup the Amazon S3 Transfer XML Bucket
			GlUt_AWSS3AddFileToBucket addFileS3Service = new GlUt_AWSS3AddFileToBucket(GlUt_AWSConstants.ECHODATATRANSFERXMLS3BUCKET);
	        addFileS3Service.payloadXml = batchData.XML;
	        addFileS3Service.resourceName = GlUt_AWSConstants.DATATRANSFERXMLFILENAME 
	        							+ DateTime.now().format(GlUt_AWSConstants.DATETIMEFORMAT) 
	        							+  GlUt_AWSConstants.XMLFILEEXTENSION;  

			// make the callout to write the document to the bucket
	        response = addFileS3Service.addFileToBucket();
	        
	        // good response
	        if (response != null && response.getStatusCode() == 200) {
	        
		    	// update the status of each request to ‘Extracted’ 
		    	for (PDFRequest__c pdfRequest : (List<PDFRequest__c>) scope) {
		    		pdfRequest.Status__c = Label.GlUt_PDFRequestStatusExtracted;
                    if(pdfRequest.BillingContract__c != Null)
		    		    contractIds.add(pdfRequest.BillingContract__c);
                }
                scope = (List<PDFRequest__c>) GlUt_FieldSecurity.cleanseFields(scope, false);
                update scope;
		    	error = false;
	        }
	        
		} catch(System.CalloutException e) {
            system.debug('Exception : ' +e.getStackTraceString());
			GlUt_Logger.logDebug(DEBUG + 'CALLOUT ERROR: ' + response);
            GlUt_Logger.logException(e);
            

        } catch(System.DmlException e) {
			GlUt_Logger.logDebug(DEBUG + 'DML ERROR: ' + scope);
            GlUt_Logger.logException(e);

        } finally {
        	
			// handle error response
        	if (error) {
        	
				// create a Batch Error record linked to the Batch Request Queue detailing the upload error
	            BatchError__c batchError = new BatchError__c(
											                BatchRequestOperation__c = Label.GlUt_BatchErrorOperationProcess,
											                ErrorDetails__c = 'Error: ' + response.getBody() + ' . ' + response.toString(),
											                BatchRequestQueue__c = batchRequestQueueId,
											                OperatingRecordType__c = CLASS_NAME 
	            											);
	            											
				// set the Batch Request Queue Status to ‘Errors’
				for (BatchRequestQueue__c batchRequestQueue : [select Id, 
																	Status__c 
																from BatchRequestQueue__c 
																where Id = :batchRequestQueueId]) {
					batchRequestQueue.Status__c = Label.GlUt_BatchRequestQueueStatusErrors;
                    batchRequestQueue  = (BatchRequestQueue__c) GlUt_FieldSecurity.cleanseFields(batchRequestQueue, false);
					update batchRequestQueue;
					break;
				}
        	}
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
	@author         Echo: Patrick Dixon
	@date           29 May 2018
    @param          Database.BatchableContext BC
	@description    Initialises the batch job
	*******************************************************************************/
    global void finish(Database.BatchableContext BC) {

		// create the report file
		if (contractIds != null && !contractIds.isEmpty()) {
			Integer numberOfContracts = contractIds.size();
				
			String report = 'Number of contracts extracted: ' + String.valueOf(numberOfContracts) + CRLF;
			report += 'List of contract Ids: ' + CRLF;
			for (Id contractId : contractIds) {
				report += contractId + CRLF;
			}
			
	    	// write the report file and link it to the Batch Request Queue
			System.debug(DEBUG + 'INSERTING DOCUMENT');
			String reportFilename = GlUt_AWSConstants.CORRESPONDENCE_XML_REPORT_FILE_NAME  
        							+ DateTime.now().format(GlUt_AWSConstants.DATETIMEFORMAT) 
        							+  GlUt_AWSConstants.REPORT_FILE_EXTENSION;  

			Id reportId;
			reportId = GlUt_ContentDocument.saveLinkedDocument(batchRequestQueueId, 'PDFExportLibrary', reportFilename, reportFilename, Blob.valueOf(report));
		}		

		// update the Batch Request Queue status to ‘Completed’
		for (BatchRequestQueue__c batchRequestQueue : [select Id, 
															Status__c 
														from BatchRequestQueue__c 
														where Id = :batchRequestQueueId]) {
												
			// only 'Completed' if no error			
			if (batchRequestQueue.Status__c != Label.GlUt_BatchRequestQueueStatusErrors) {
				batchRequestQueue.Status__c = Label.GlUt_BatchRequestQueueStatusCompleted;
                batchRequestQueue  = (BatchRequestQueue__c) GlUt_FieldSecurity.cleanseFields(batchRequestQueue, false);
				update batchRequestQueue;
			}
			break;
		}
    }
    
}