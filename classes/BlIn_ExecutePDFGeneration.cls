/******************************************************************************
@author         Accenture: Patrick Dixon
@date           08 Sep 2017
@description    Class for PDF callout
@revision		Echo: Sudhir Kumar - AT-3889 (Core Misc) Getting Component Error Message on Bill screen while opening Bill PDF
@revision		Echo: Sudhir Kumar - AT-4098 Generate PDF action
*******************************************************************************/
public with sharing class BlIn_ExecutePDFGeneration {
    
    private static final String CLASS_NAME = 'BlIn_ExecutePDFGeneration';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           16 Nov 2018
    @param          String currentObjectName
    @return         String - containerName
    @description    HEROKU callout to generate a PDF
	*******************************************************************************/
    // AU1: AT-4098
    private static String getXmlContainerName(String currentObjectName) {	
        String prefix = '' ;
        String suffix = GlUt_AWSConstants.PDF_CONTAINER_SUFFIX ;
        String containerName = '' ;
        if(currentObjectName.equals(GlUt_AWSConstants.BILL_OBJECT)) { 
            prefix = GlUt_AWSConstants.BILL_PDF_CONTAINER_PREFIX ;
        } else if(currentObjectName.equals(GlUt_AWSConstants.INFORMATION_STATEMENT_OBJECT)) { 
            prefix = GlUt_AWSConstants.INFORMATION_STATEMENT_PDF_CONTAINER_PREFIX ;
            
        } 
        currentObjectName = currentObjectName.remove(GlUt_NamespacePrefix.getNamespacePrefix());
        return containerName = prefix + currentObjectName.remove('__c') + suffix ; 
        
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           08 Sep 2017
    @param          Id - bill Id
    @param          String - PDF template name
    @return         Id - attachment Id
    @description    HEROKU callout to generate a PDF
    @revision		Echo: Sudhir: AU1 AT-4098: Generic Approach - Generate PDF action
	*******************************************************************************/
    public static String ExecutePDF(Id recordId) { // AU1 AT-4098
        try {
            String PDFId ;
            Date latestPrintedBillDate;
            Set<Id> billCalculationIds = new Set<Id>();
            // prepare the bill data 
            if(recordId != null){
                String currentObjectName = recordId.getSObjectType().getDescribe().getName() ; // AU1 AT-4098
                String containerName = getXmlContainerName(currentObjectName) ;
                List<SObject> sobjectList  ;
                String filterCriteria =' Id = :recordId' ; 
                //AT-4047
                 /* if(currentObjectName.equals(GlUt_AWSConstants.BILL_OBJECT)) {
                    // Query to get the contract from Bill record.
                  //AT-4047 - Update Transfer XML generation for Bills - Dependra Singh(30 Oct 2018)
                    Bill__c objBillForContract = [Select Id, BillingContract__c,BillCalculation__c FROM Bill__c WHERE Id =:recordId LIMIT 1];
                    if(objBillForContract != null){
                        if(objBillForContract.BillingContract__c != null){
                            
                            List<Bill__c> billList = [SELECT Id, Name, PrintXml__c,PrintDate__c,BillType__c 
                                                      FROM Bill__c WHERE BillingContract__c =:objBillForContract.BillingContract__c 
                                                      AND BillType__c =: BlBt_Constants.BILL_TYPE_NORMAL 
                                                      AND PrintXml__c = true AND PrintDate__c != null ORDER BY PrintDate__c DESC];
                            if(billList != null && !billList.isEmpty()){
                                latestPrintedBillDate  = billList[0].PrintDate__c;
                            }
                        } 
                    }
                    System.debug('latestPrintedBillDate = '+latestPrintedBillDate);
                    if(latestPrintedBillDate != null){
                        List<BillTransfer__c> billTransferList = [SELECT Id, BillCalculation__c, CreatedDate FROM BillTransfer__c WHERE CreatedDate >: latestPrintedBillDate];
                        if(billTransferList != null && !billTransferList.isEmpty()){
                            for(BillTransfer__c objBillTransfer : billTransferList){
                                if(objBillTransfer.BillCalculation__c != null){
                                    billCalculationIds.add(objBillTransfer.BillCalculation__c);
                                }
                            }
                        }
                    } 
                  filterCriteria =  'Id = :recordId' + ' OR '+ GlUt_APIConstantsBill.BILLCALCULATIONAPINAME + ' IN : billCalculationIds' ;
                    filterCriteria =  'Id = :recordId' ;    
                } else if(currentObjectName.equals(GlUt_AWSConstants.INFORMATION_STATEMENT_OBJECT)) {
                    //SOQL string on Info Stmt object - To use field List
                    filterCriteria =  'Id = :recordId' ; 
                }*/
                
                if(String.isNotBlank(containerName)) {
                    String xmlDocString = '' ;
                    String queryString = '' ;
                    Type t = Type.forName(GlUt_NamespacePrefix.getNamespacePrefix() , containerName) ;
                    GlUt_DataTransferXmlInterface xmlRouter = (GlUt_DataTransferXmlInterface) t.newInstance() ;
                    if(String.isNotBlank(filterCriteria)) queryString = xmlRouter.getQueryString(recordId, filterCriteria) ;		//Get query string
                    if(String.isNotBlank(queryString))  sobjectList = Database.query(queryString) ;
                    if(sobjectList != null && !sobjectList.isEmpty()) xmlDocString = xmlRouter.getDataTransferXmlString(sobjectList) ;	//Get xml string
                    system.debug('Sudhir xmlDocString=> ' + xmlDocString);
                    if(String.isNotBlank(xmlDocString)){
                        // make the callout
                        HttpResponse response = BlUt_HerokuWebservices.makeCallout(BlUt_HerokuWebservices.PDF_GENERATION, 5000, 'application/xml', xmlDocString);
                        system.debug('response= ' + response);
                        system.debug('response body= ' + response.getBody());
                        // handle response
                        if (response.getStatusCode() == 200 && response.getBody() != null) {
                            GlUt_TransferXMLResponseContainer herokuResponse = GlUt_TransferXMLResponseContainer.parse(response.getBody()) ;
                            system.debug('herokuResponse=> ' + herokuResponse);
                            Boolean processed = GlUt_TransferXMLResponseContainer.processResponse(herokuResponse, sobjectList[0]) ;
                            system.debug('processed=> ' + processed);
                            if(processed) {
                                PDFId = getSignedUrl(recordId, true);  // AU1 AT-4098
                            }
                        } else {
                            System.debug(DEBUG + 'Error response: ' + response.getStatusCode() + ' Status = ' + response.getStatus() + ' Body = ' + response.getBody());
                            //throw new AuraHandledException(Label.BlAp_PDFGenerationRequestError + response.getBody());
                            return (Label.BlAp_PDFGenerationRequestError + ' ' + response.getBody()) ;
                        }
                    }
                }
            }
            System.debug('PDFId = '+PDFId);
            return PDFId;  
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         ECHO: Mohit Tayal
    @date           12 June 2018
    @param          Id - bill Id 
    @param          Boolean - GeneratePDF 
    @return         String - signedUrl of PDF document
    @description    Generating amazon signed Url
    @revision		Echo: Sudhir Kumar - AT-3889 (Core Misc) Getting Component Error Message on Bill screen while opening Bill PDF
    @revision		Echo: Sudhir Kumar - AT-3954 - Dynamic SOQL for BlIn_ExecutePDFGeneration (Security Review)
    @revision		Echo: Sudhir: AU1 AT-4098: Generic Approach - Generate PDF action
    *******************************************************************************/
    public static String getSignedUrl(Id recordId, Boolean generatePdf) {
        String PDFUrl = '' ;
        String fileName = '' ;
        String currentObjectName = recordId.getSObjectType().getDescribe().getName() ;
        system.debug('Sudhir-currentObjectName= ' + currentObjectName) ;
        if(currentObjectName.equals(GlUt_APIConstantsBill.BILLAPINAME)) {
            //SOQL on Bill object to prepare file name  - To check on applying dynamic query here??
            List<Bill__c> listBill = [SELECT Id, BillingContract__c, Account__c, BillPDF__c, BillingContract__r.AccountName__c FROM Bill__c WHERE Id =: recordId] ; 
            system.debug('listBill***'+ listBill);
            if(listBill != null && !listBill.isEmpty() && (listBill[0].BillPDF__c || generatePdf))   //Sudhir: AT-3889
                fileName = listBill[0].BillingContract__r.AccountName__c + '/' + listBill[0].BillingContract__c + '/bill_' + recordId + GlUt_AWSConstants.PDF_FILE_EXTENSION; //AT-3174 //Sudhir: AT-3889
            
        } else if(currentObjectName.equals(GlUt_APIConstantsInformationStatement.OBJECTAPINAME)) {
            //SOQL on Info Stmt object to prepare file name 
            List<InformationStatement__c> listInfoStatement = [SELECT Id, BillingContract__c, StatementPDF__c, BillingContract__r.AccountName__c FROM InformationStatement__c WHERE Id =: recordId] ; 
            if(listInfoStatement != null && !listInfoStatement.isEmpty() && listInfoStatement[0].StatementPDF__c)   //Sudhir: AT-3889
                fileName = listInfoStatement[0].BillingContract__r.AccountName__c + '/' + listInfoStatement[0].BillingContract__c + '/statement_' + recordId + GlUt_AWSConstants.PDF_FILE_EXTENSION; //AT-3174 //Sudhir: AT-3889
        }
        if(String.isNotBlank(fileName)) {      
            GlUt_AWSS3ViewFiles viewPDF = new GlUt_AWSS3ViewFiles(GlUt_AWSConstants.ECHOPDFCORRESPONDENCEBUCKET,fileName);
            List<GlUt_AWSS3ViewFiles.BucketFileWrapper> listBucketFileWrapper = viewPDF.getCloudFrontSignedURL(fileName);
            PDFUrl = listBucketFileWrapper[0].signedUrl;
        }
        system.debug('Sudhir-PDFUrl= ' + PDFUrl) ;
        return PDFUrl;
    }
}