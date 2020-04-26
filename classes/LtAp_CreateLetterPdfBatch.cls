/******************************************************************************
    @author         Echo: Amit K.
    @date           22 Feb 2018
    @description    Batch class to call Heroku webservice for each records present 
                    in CreateLetterPdfRequest object that are not market as Processed
                    in order to save PDF in salesforce content libraries
*******************************************************************************/
public with sharing class LtAp_CreateLetterPdfBatch extends GlBt_BatchProcess
									   implements Schedulable, Database.Batchable<sObject>,Database.AllowsCallouts{
    private final String query;
    private static List<string> createLetterPDFRequestFields;
    private static final String CLASS_NAME = 'LtAp_CreateLetterPdfBatch';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    public String batchRequestQueueId;
    static{
        //MT - 01/06/2018 AT - 2467 added some fields required in data transfer xml
        createLetterPDFRequestFields = new List<string>();
        createLetterPDFRequestFields.add(GlUt_APIConstantsCreateLetterPDFRequests.HTMLBODYAPINAME); 
        createLetterPDFRequestFields.add(GlUt_APIConstantsCreateLetterPDFRequests.ACCOUNTAPINAME);
        createLetterPDFRequestFields.add(GlUt_APIConstantsCreateLetterPDFRequests.CONTACTAPINAME);
        createLetterPDFRequestFields.add(GlUt_APIConstantsCreateLetterPDFRequests.CONTRACTAPINAME);
        createLetterPDFRequestFields.add(GlUt_APIConstantsCreateLetterPDFRequests.SOURCETYPEAPINAME);
        createLetterPDFRequestFields.add(GlUt_APIConstantsCreateLetterPDFRequests.STATUSAPINAME);
    }
                                           
    public override void initialise(BatchRequestQueue__c batchRequestQueue) {
        // local copy of the Batch Request Queue Id to update status etc
         batchRequestQueueId = batchRequestQueue.Id;
    }
                                           
    /******************************************************************************
    @author         Echo: Amit K.
    @date           22 Feb 2018
    @description    Constructor to set Query string
    *******************************************************************************/
    public LtAp_CreateLetterPdfBatch() {
        query = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(createLetterPDFRequestFields,','), 
                GlUt_APIConstantsCreateLetterPDFRequests.PDFREQUESTAPINAME +' WHERE ' +  
                GlUt_APIConstantsCreateLetterPDFRequests.STATUSAPINAME + ' = \'' + LtBt_Constants.PENDINGPDFSTATUS + '\' AND ' +
                GlUt_APIConstantsCreateLetterPDFRequests.SOURCETYPEAPINAME + ' = \'' + LtBt_Constants.HTMLPDFSOURCETYPE + '\''
                });
    }
   /******************************************************************************
    @author         Echo: Amit K.
    @date           22 Feb 2018
    @description    Scheduler's execute method
   *******************************************************************************/
    public void execute(SchedulableContext sc) {
        database.executebatch(this, 50);   // maximun limit of batch size for webservice callout(100).AT - 2467 changed the batch size from 60 to 50
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           22 Feb 2018
    @description    Batch's start method
   *******************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           22 Feb 2018
    @description    Batch's execute method
    @revision       MT - 01/06/2018 AT - 2467 implemented the new logic to create the 
                    xml file from the PDFRequest records and than storing the data xml 
                    file in the S3 bucket. 
   *******************************************************************************/
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<PDFRequest__c> createLetterRequestList = (List<PDFRequest__c>) scope;
        try{
            // START of AT-2467
            if(createLetterRequestList != null){
                // calling the createXml method to create the data xml
                String xmlString = createXml(createLetterRequestList);
                if(String.isNotBlank(xmlString)){
                    HttpResponse response;
                    //Initializing the variables of GlUt_AWSS3AddFileToBucket with the data xml and file name
                    GlUt_AWSS3AddFileToBucket addFileS3Service = new GlUt_AWSS3AddFileToBucket(GlUt_AWSConstants.ECHODATATRANSFERXMLS3BUCKET) ;	// GlUt_AWSConstants.DATATRANSFERXMLS3BUCKET
                    addFileS3Service.payloadXml = xmlString.unescapeHtml4();
                    addFileS3Service.resourceName =  LtBt_Constants.FILENAMECORRESPONDENCE + DateTime.now().format(LtBt_Constants.DATETIMEFORMAT) + LtBt_Constants.XMLFILEEXTENSION ;
                    //adding the file to S3 bucket
                    response = addFileS3Service.addFileToBucket();
                    if(response != null && response.getStatusCode() == 200) {
                        //if file gets uploaded to S3 bucket than assigning to status field
                        for(PDFRequest__c objPDFRequest : createLetterRequestList){
                            objPDFRequest.Status__c = LtBt_Constants.COMPLETEDPDFSTATUS;
                        }
                        //updating the PDFRequest records
                        Database.update(createLetterRequestList);
                    }else{
                        system.debug('response = ' +response);
                    }
                }
            }  
            // END of AT - 2467 
        }
        catch(System.CalloutException e){
            GlUt_Logger.logException(e);
            //Logger.debugException(ex);
            System.debug('CALLOUT ERROR:'+ e.getMessage());
        }
        catch(System.DmlException e){
            GlUt_Logger.logException(e);
            //Logger.debugException(e);
            System.debug('DML ERROR:'+ e.getMessage());
        }
        finally{
            GlUt_Logger.writeLogsToDatabase();
        }
    }
  
    /******************************************************************************
    @author         Echo: Amit K.
    @date           22 Feb 2018
    @description    Batch's final method which is empty
   *******************************************************************************/
    public void finish(Database.BatchableContext BC){
   
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           01 Jun 2018
    @param          List<PDFRequest__c> createLetterRequestList
    @return         String - xml string
    @description    this method is used to create the xml
   *******************************************************************************/
    private static String createXml(List<PDFRequest__c> createLetterRequestList){
        String createdXml;
        if(!createLetterRequestList.isEmpty()){
            XmlStreamWriter xmlw = new XmlStreamWriter();
            xmlw.writeStartDocument(LtBt_Constants.XMLENCODING, null);
            xmlw.writeStartElement(null, LtBt_Constants.PDFREQUESTSTAG, null);
            for(PDFRequest__c objPDFRequest: createLetterRequestList){
                xmlw.writeStartElement(null, LtBt_Constants.PDFREQUESTTAG, null);
                addChildElementAndText(xmlw, 'Id', objPDFRequest.Id);
                addChildElementAndText(xmlw, LtBt_Constants.SOURCETYPETAG, objPDFRequest.SourceType__c);
                addChildElementAndText(xmlw, LtBt_Constants.ACCOUNTTAG, objPDFRequest.Account__c);
                addChildElementAndText(xmlw, LtBt_Constants.CONTRACTTAG, objPDFRequest.BillingContract__c);
                addChildElementAndText(xmlw, LtBt_Constants.CONTACTTAG, objPDFRequest.Contact__c);
                addChildElementAndText(xmlw, LtBt_Constants.HTMLBODYTAG, objPDFRequest.HtmlBody__c);
                xmlw.writeEndElement(); 
            }
            xmlw.writeEndElement();
            xmlw.writeEndDocument();
            createdXml = xmlw.getXmlString();
            xmlw.close();
        }
        return createdXml;
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           01 Jun 2018
    @param          XmlStreamWriter w - instance of Xmlstreamwriter 
                    string nodeName - Name of the xml node
                    object nodeValue - Value of the xml node
    @return         String - xml string
    @description    this method is used to add a child in xml
   *******************************************************************************/
    private static void addChildElementAndText(XmlStreamWriter w, string nodeName, object nodeValue){
        string stringVal = '';
        if(nodeValue != null){
            if(nodeValue instanceof string){
                stringVal = (string)nodeValue;
            }
            else if (nodeValue instanceof Decimal){
                stringVal = ((Decimal)nodeValue).format();
            }
            else if (nodeValue instanceof Integer){
                stringVal = ((Integer)nodeValue).format();
            }
            else if (nodeValue instanceof Date){
                stringVal = ((Date)nodeValue).format();
            }
            else if (nodeValue instanceof DateTime){
                stringVal = ((DateTime)nodeValue).format();
            }
        }
        w.writeStartElement(null, nodeName, null);
        w.writeCharacters(stringVal);
        w.writeEndElement();  
    }
}