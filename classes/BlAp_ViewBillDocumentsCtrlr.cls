/****************************************************************************************************************************
@author         Echo: Tarun\Dependra
@date           28-May-2018
@description    Component Controller to view all documents that have been linked to the Bill, including the Data and Print XMLs as well as the PDF. 
@revision		Echo: Sudhir Kumar AT-3889 : Access Denied error after clicking View Button for Bill PDF under Bill Documents
@revision		Echo: Sudhir Kumar AT-4095(AU1) : Making this component reusable for other object types
*****************************************************************************************************************************/
public with sharing class BlAp_ViewBillDocumentsCtrlr {
    
    private static final String CLASS_NAME = 'BlAp_ViewBillDocumentsCtrlr'; 
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static FINAL List<String> billFieldList = new List<String> { 
        GlUt_APIConstantsBill.BILLDATEAPINAME,
		GlUt_APIConstantsBill.BILLEDAMOUNTAPINAME
		};
			
	private static FINAL List<String> contractFieldList = new List<String> { // AT-3889
		GlUt_APIConstantsContracts.CUSTOMERAPINAME
		};
	/**********************************************************************************************
	@author         Echo: Tarun\Dependra
	@date           28-May-2018
	@return         List<GLAp_FieldProps>
	@description    This method returns the field properties for each of the fields that are to be displayed on the screen
	**********************************************************************************************/ 
	@AuraEnabled
	public static List<GLAp_FieldProps> retrieveBillPropDetails() {
		List<GLAp_FieldProps> billProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsBill.BILLAPINAME, billFieldList);
		
		// Create transform field Document Name
		GLAp_FieldProps docName = new GLAp_FieldProps();
		docName.isFLSVisible = true;
		docName.isEncrypted = false;
		docName.isEditable = false;
		docName.isRequired = false;
		docName.fieldName = BlAp_Constants.DOCUMENTNAME;
		docName.fieldLabel =  System.Label.BlAp_Document_Name;
		docName.fieldType = 'text';
		docName.transformField = true; //Indicates this is a Transfrom and NOT a DB field
		docName.parentObject = GlUt_APIConstantsBill.BILLAPINAME; //Attach to Bill for display
		
		GLAp_FieldProps billPdfLink = new GLAp_FieldProps();
		billPdfLink.isFLSVisible = true;
		billPdfLink.isEncrypted = false;
		billPdfLink.isEditable = false;
		billPdfLink.isRequired = false;
		billPdfLink.fieldName = BlAp_Constants.BILLLINK;
		billPdfLink.fieldLabel = System.Label.BlAp_View;
		billPdfLink.fieldType = 'url';
		billPdfLink.buttonField = true;
		billPdfLink.transformField = true; //Indicates this is a Transfrom and NOT a DB field
		billPdfLink.parentObject = GlUt_APIConstantsBill.BILLAPINAME; //Attach to Bill for display
		
		List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
		
		fldPropList.add(docName); 
		fldPropList.add(billPdfLink); 
		return fldPropList;
	}
    
    /******************************************************************************
	@author         Echo: Tarun\Dependra
	@date           28-May-2018
	@param          Id billId
	@return         List<BlAp_CombinedRecord> 
	@description    This method is used to get all user bill documents by passing bill id
	@revision		Echo: Sudhir Kumar - AT-3889
	@revision		Echo: Sudhir Kumar AT-4095(AU1)
	*******************************************************************************/
    static String strDataXML ='';
    static String strPrintXML ='';
    static String strBillPDF ='';
    static String strStatementPDF ='';
    static Id contractId ;
    static Id accountId ;
    static map<String, SObject> mapObject ;
    static Id currentRecordId ;
    static List<String> lstdocument ;
    
    @AuraEnabled
    public static List<BlAp_CombinedRecord> getUserBills(Id objectRecordId) {
        String strBucketName ;
        currentRecordId = objectRecordId ;
        lstdocument = new List<String>();
        List<BlAp_CombinedRecord> docsList = new List<BlAp_CombinedRecord>();
        List<String> queryFields = new List<String>();
        queryFields.add('Id');
        //queryFields.add(GlUt_APIConstantsBill.BILLNUMBERAPINAME); //Sudhir AU1
        queryFields.add(GlUt_APIConstantsBill.CONTRACTNUMBERAPINAME);
        //queryFields.add(GlUt_APIConstantsBill.ACCOUNTAPINAME);
        queryFields.add(GlUt_APIConstantsBill.DATAXMLAPINAME);
        
        queryFields.add(GlUt_APIConstantsBill.PRINTXMLAPINAME);
        
        String objectAPIWithNamespace = objectRecordId.getSObjectType().getDescribe().getName() ;
        system.debug('objectAPIWithNamespace= ' + objectAPIWithNamespace);
        if(objectAPIWithNamespace.equals(GlUt_AWSConstants.BILL_OBJECT)) {
        	queryFields.add(GlUt_APIConstantsBill.BILLPDFAPINAME);
        } else if(objectAPIWithNamespace.equals(GlUt_AWSConstants.INFORMATION_STATEMENT_OBJECT)) {
        	queryFields.add(GlUt_APIConstantsInformationStatement.STATEMENTPDFAPINAME);    
        }	
        mapObject = new map<String, SObject>() ;
        List<SObject> listSObject = (List<SObject>) GlAp_LightningDataAccess.getRecords(objectAPIWithNamespace, 
                                                                                        queryFields, 
                                                                                        String.valueOf(objectRecordId), 
                                                                                        'Id');
        
        system.debug('listSObject= ' + listSObject);
        if(listSObject != null && !listSObject.isEmpty()) {
            mapObject.put(objectAPIWithNamespace, listSObject[0]) ;
            lstdocument = prepareFileNames(mapObject) ;            
        }
        system.debug('lstdocument= ' + lstdocument);
        Integer iCount = 0;    
        try {
			for(String objDoc : lstdocument) {          
				iCount += 1;
				String strResource = '';
				if(objDoc == GlUt_AWSConstants.DATAXML){
					strResource = strDataXML;
					strBucketName = GlUt_AWSConstants.DATAXMLSS3BUCKET;
				}
				else 
					if(objDoc == GlUt_AWSConstants.PRINTXML){
						strResource = strPrintXML;
						strBucketName = GlUt_AWSConstants.PRINTXMLBUCKET;
					}
				else 
					if(objDoc == GlUt_AWSConstants.BILLPDF){
						strResource = strBillPDF;
						strBucketName = GlUt_AWSConstants.BILLPDFBUCKET;
					}
                else 
					if(objDoc == GlUt_AWSConstants.STATEMENTPDF){
						strResource = strStatementPDF;
						strBucketName = GlUt_AWSConstants.BILLPDFBUCKET;
					}
				if(string.isNotBlank(strBucketName) && string.isNotBlank(strResource)){
					GlUt_AWSS3ViewFiles awsS3Service = new GlUt_AWSS3ViewFiles(strBucketName,strResource) ;
					list<GlUt_AWSS3ViewFiles.BucketFileWrapper> lstBucketsWrapper = awsS3Service.getCloudFrontSignedURL(strResource) ;
					BlAp_CombinedRecord documentObj = new BlAp_CombinedRecord(); 
					documentObj.uniqueId            = String.valueOf(iCount);
					documentObj.isSelected          = false;
					documentObj.transformFieldMap = new Map<String, Map<String, String>>();
					Map<String,String> transFormFieldMap2 = new Map<String,String>();
					transFormFieldMap2.put(BlAp_Constants.DOCUMENTNAME, objDoc);
					transFormFieldMap2.put(BlAp_Constants.BILLLINK, lstBucketsWrapper[0].signedUrl);
					documentObj.transFormFieldMap.put(GlUt_APIConstantsBill.BILLAPINAME, transFormFieldMap2);
					docsList.add(documentObj);
				}
			}
    	} catch (Exception oException) {
            GlUt_Logger.logException(oException);
            throw new AuraHandledException('Error: ' + oException.getMessage());
            } finally {   
            GlUt_Logger.writeLogsToDatabase();
            } 
        
        return docsList;
        
    }
    /******************************************************************************
	@author         Echo: Sudhir Kumar
	@date           06-Nov-2018
	@param          Boolean isDataXml, Boolean isPrintXml, Boolean isPdf
	@return         void
	@description    This method is used to prepare AWS file names
	 				Echo: Sudhir Kumar AT-4095(AU1)
	*******************************************************************************/
    
    private static void getFileNames(Boolean isDataXml, Boolean isPrintXml, Boolean isPdf, Boolean isStatementPdf) {
        if(isDataXml){
            strDataXML  =  String.valueOf(accountId) + '/' + String.valueOf(contractId) + '/data_'  + String.valueOf(currentRecordId) + '.xml';
            lstdocument.add(GlUt_AWSConstants.DATAXML);
        }
        if(isPrintXml){
            strPrintXML =  String.valueOf(accountId) + '/' + String.valueOf(contractId) + '/print_' + String.valueOf(currentRecordId) + '.xml';
            lstdocument.add(GlUt_AWSConstants.PRINTXML);
        }
        if(isPdf) {
            strBillPDF  =  String.valueOf(accountId) + '/' + String.valueOf(contractId) + '/bill_'  + String.valueOf(currentRecordId) + '.pdf';
            lstdocument.add(GlUt_AWSConstants.BILLPDF);
        }
        if(isStatementPdf) {
            strStatementPDF  =  String.valueOf(accountId) + '/' + String.valueOf(contractId) + '/statement_'  + String.valueOf(currentRecordId) + '.pdf';
            lstdocument.add(GlUt_AWSConstants.STATEMENTPDF);
        }
    }
    /******************************************************************************
	@author         Echo: Sudhir Kumar
	@date           06-Nov-2018
	@param          map<String, SObject> mapObject
	@return         List<String> listDocuments
	@description    This method is used to prepare list of Documents to display on the component
	 				Echo: Sudhir Kumar AT-4095(AU1)
	*******************************************************************************/
    
    private static List<String> prepareFileNames(map<String, SObject> mapObject) {
        Boolean isDataXml = false ;
        Boolean isPrintXml = false ;
        Boolean isBillPdf = false ;
        Boolean isStatementPdf = false ;
        Bill__c bill = null ;
        InformationStatement__c infoStmt = null ;
        system.debug('mapObject= ' + mapObject);
        
        for(String objectName : mapObject.keySet()) {
            if(objectName.equals('Bill__c')) {
                bill = (Bill__c) mapObject.get(objectName) ;
                contractId = bill.BillingContract__c ;
                isDataXml  = bill.DataXml__c ;
                isPrintXml = bill.PrintXml__c ;
                isBillPdf	   = bill.BillPdf__c ;
            } else if(objectName.equals('InformationStatement__c')) {
                infoStmt   			= (InformationStatement__c) mapObject.get(objectName) ; 
                contractId 			= infoStmt.BillingContract__c ;
                isDataXml  			= infoStmt.DataXml__c ;
                isPrintXml 			= infoStmt.PrintXml__c ;
                isStatementPdf	    = infoStmt.StatementPdf__c ;
            }	
        }
        
        system.debug('contractId= ' + contractId);
        if(String.isNotBlank(contractId)) {
            // START: AT-3889 CoreMisc
            list<BillingContract__c> listBillingContract = 
                (list<BillingContract__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsContracts.CONTRACTAPINAME,
                                                                               contractFieldList,
                                                                               contractId,
                                                                               'Id'
                                                                              ) ;	
            system.debug('listBillingContract= ' + listBillingContract);	
            if(listBillingContract != null && !listBillingContract.isEmpty()) {
                accountId = listBillingContract[0].AccountName__c;
                getFileNames(isDataXml, isPrintXml, isBillPdf, isStatementPdf) ;
                // END: AT-3889 CoreMisc
                
            }
        }
        system.debug('strDataXML = ' + strDataXML) ;
        system.debug('strPrintXML = ' + strPrintXML) ;
        system.debug('strBillPDF = ' + strBillPDF) ;
        return lstdocument ;
    }
}