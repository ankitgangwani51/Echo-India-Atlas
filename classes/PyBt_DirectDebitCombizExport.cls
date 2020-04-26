/******************************************************************************
@author         Echo: Ankit Gangwani
@date           01 Feb 2019
@description    PyBt_DirectDebitCombizExport class 
				will export all the Direct Debit records
*******************************************************************************/
global with sharing class PyBt_DirectDebitCombizExport extends GlBt_BatchProcess implements Database.Batchable<sObject>, Database.Stateful {
    
    private static string sQuery;
    private Integer totalRecordProcessed = 0;
    private Decimal totalCreditAmount = 0.0; 
    private Decimal totalDebitAmount = 0.0; 
    private BatchRequestQueue__c batchRequestQueue;
    private String headerRecordStr; 		//containing header record data.
    private String detailRecordsStr; 		//containing detailed record data. 
    private String trailerRecordStr; 		//containing trailer record data
    private String balancingDetailRecord; 	//containing balancing detail record data
    
    private static List<String> directDebitFields;
	private CombizInterface__mdt mtdCombiz = new CombizInterface__mdt();
    private Map<Id,String> mapOfDirectDebitRequestIdToRecordsStr = new Map<Id,String>();
    static{
        directDebitFields = new List<String>();
        directDebitFields.add(GlUt_APIConstantsDirectDebitRequest.STATUSAPINMAE);
        directDebitFields.add(GlUt_APIConstantsDirectDebitRequest.FIRSTREQUESTBANKACCOUNTAPINAME);
        directDebitFields.add(GlUt_APIConstantsDirectDebitRequest.CREATEDDATEAPINAME);         
        directDebitFields.add(GlUt_APIConstantsDirectDebitRequest.BANKACCOUNTDETAILSSORTCODEAPINAME); 
        directDebitFields.add(GlUt_APIConstantsDirectDebitRequest.BANKACCOUNTDETAILSBANKACCOUNTNUMBERAPINAME); 
        directDebitFields.add(GlUt_APIConstantsDirectDebitRequest.INSTALMENTINSTALMENTAMOUNTDUEAPINAME); 
        directDebitFields.add(GlUt_APIConstantsDirectDebitRequest.BANKACCOUNTDETAILSNAMEAPINAME); 
        directDebitFields.add(GlUt_APIConstantsDirectDebitRequest.BANKACCOUNTDETAILSACCOUNTNAMEAPINAME); 
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           01 Feb 2019
    @description    Override GlBt_BatchProcess method as per Batch framework.
    *******************************************************************************/
    global override void Initialise(BatchRequestQueue__c brq){
        this.batchRequestQueue = brq;
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           01 Feb 2019
    @description   	This method will query all Payment (Refunds) Records and pass to the execute method for processing
   *******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {        
        // Update the Batch Request Queue status to "Processing"
        updateBRQ(new list<BatchRequestQueue__c> {batchRequestQueue},LoBt_Constants.BRQPROCESSINGSTATUS);
        /*getCustomDataforCombizInterface();
        if(!combizLists.isEmpty() && !directDebitFields.contains(combizLists[0].RefundLodgementReference__c))
            directDebitFields.add(combizLists[0].RefundLodgementReference__c);
		*/
        mtdCombiz  = GlUt_CustomMetaDataUtility.getCustomDataforCombizInterface(PyBt_Constants.COMBIZMETADATAQUERY);
        if(mtdCombiz != null && !directDebitFields.contains(mtdCombiz.RefundLodgementReference__c)){
            directDebitFields.add(mtdCombiz.RefundLodgementReference__c);
        }
        buildHeaderString();
        
        //Get all the Direct Debit Records
        sQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(directDebitFields,',') + ',' +
            GlUt_APIConstantsBankAccountDetails.BANKACCOUNTDETAILSAPINAME +',' + 
            GlUt_APIConstantsInstalment.INSTALMENTAPINAME, 
            GlUt_APIConstantsDirectDebitRequest.DIRECTDEBITREQUESTAPINAME +
            ' WHERE ' + GlUt_APIConstantsDirectDebitRequest.STATUSAPINMAE 		+ ' = \'' + PyBt_Constants.DIRECT_DEBIT_REQUEST_STATUS_PENDING + '\'' + 
            ' AND ' + GlUt_APIConstantsDirectDebitRequest.CREATEDDATEAPINAME 	+ ' = TODAY '});
        System.debug('sQuery = '+sQuery);
        return Database.getQueryLocator(sQuery);        
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           01 Feb 2019
    @description    This method will prepare the text file for all the payment (Refund) records
    *******************************************************************************/
    global void execute(Database.BatchableContext bc, List<SObject> scope){ 
        try{
            List<DirectDebitRequest__c> directDebitRequestLists = (List<DirectDebitRequest__c>) scope;
            Set<Id> ddrToUpdate = new Set<Id>();
            List<DirectDebitRequest__c> ddrListToUpdate = new List<DirectDebitRequest__c>();
            // Prepare the detailRecordsStr data AND updtae the Status to 'Confirmed'
            if(!directDebitRequestLists.isEmpty() && directDebitRequestLists.size() > 0){
                for(DirectDebitRequest__c objDDR : directDebitRequestLists){
                    totalRecordProcessed = totalRecordProcessed + 1;
                    totalCreditAmount = totalCreditAmount + objDDR.Instalment__r.InstalmentAmountDue__c;
                    buildDetailedRecordString(objDDR);
                    ddrToUpdate.add(objDDR.Id);                    
                }
            }    
            if(!ddrToUpdate.isEmpty() && ddrToUpdate.size() > 0){
                for(DirectDebitRequest__c ddr : [SELECT Id, Status__c FROM DirectDebitRequest__c WHERE Id IN:ddrToUpdate]){
                    ddr.Status__c = PyBt_Constants.DIRECT_DEBIT_REQUEST_STATUS_CONFIRMED;
                    ddrListToUpdate.add(ddr);
                }
                if(!ddrListToUpdate.isEmpty() && ddrListToUpdate.size() > 0){
                    ddrListToUpdate = (List<DirectDebitRequest__c>)GlUt_FieldSecurity.cleanseFields(ddrListToUpdate, false);
                    Database.update(ddrListToUpdate);
                }
            } 
        }
        catch (exception e){
            updateBRQ(new list<BatchRequestQueue__c> {batchRequestQueue},LoBt_Constants.BRQSTATUSERRORS);
            GlUt_Logger.logException(e);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        } 
    } 
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           01 Feb 2019
    @description    This method will link the text file with the batch request queue record
   *******************************************************************************/
    global void finish(Database.BatchableContext bc){
        Savepoint sp = Database.setSavepoint();
        try{      
            buildBalanceDetailRecord();
            buildTrailerRecord();            
            
            String fileData = headerRecordStr + '\r\n';
            if(mapOfDirectDebitRequestIdToRecordsStr.size() > 0 && mapOfDirectDebitRequestIdToRecordsStr.keySet().size() > 0){
                for(Id ddrId : mapOfDirectDebitRequestIdToRecordsStr.keySet()){
                    String getDetailedRecordData = mapOfDirectDebitRequestIdToRecordsStr.get(ddrId);
                    fileData = fileData + getDetailedRecordData + '\r\n';
                }
            }
            
            fileData = fileData + balancingDetailRecord + '\r\n';
            fileData = fileData + trailerRecordStr;
            
            DateTime currentDateTime = System.now();
            String formattedPDate = currentDateTime.format('ddMMyyyyhhmmss'); 
            String fileName = PyBt_Constants.COMBIZ_DIRECT_DEBIT + '_' + formattedPDate + GlUt_Constants.ABA_FILE_EXTENSION;  //'.aba';
            
            if(headerRecordStr.length() > 0 && mapOfDirectDebitRequestIdToRecordsStr.size() > 0 && balancingDetailRecord.length() > 0 && trailerRecordStr.length() > 0){
                Id contentDocumentId = GlUt_ContentDocument.saveLinkedDocument(batchRequestQueue.Id, PyBt_Constants.DIRECT_DEBIT_COMBIZ_EXPORT, fileName, fileName, LoBt_Constants.SHARE_TYPE, blob.valueOf(fileData));
                updateBRQ(new list<BatchRequestQueue__c> {batchRequestQueue},LoBt_Constants.BRQSTATUS);
            }else
                updateBRQ(new list<BatchRequestQueue__c> {batchRequestQueue},LoBt_Constants.BRQSTATUSERRORS);
        }
        catch (exception e){
            updateBRQ(new list<BatchRequestQueue__c> {batchRequestQueue},LoBt_Constants.BRQSTATUSERRORS);
            GlUt_Logger.logException(e);
            Database.rollback(sp);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }

    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           05 Feb 2019
    @description    Preapre the data with right padding and concatenate with string
    *******************************************************************************/
    public String buildRightPad(String sData, Integer padding, String spaceOrZero, String concatenate, Boolean isSubstring, Integer toSubstring){
        if(isSubstring) sData += concatenate.length() > toSubstring ? concatenate.substring(0,toSubstring) : concatenate;
        else sData += concatenate;
        return sData.rightPad(padding,spaceOrZero);
    }    
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           01 Feb 2019
    @description    Preapre the Header String Data (headerRecordStr)
	------------------------------------------
	Field					Position	Length
	------------------------------------------
	Record Type				0-1			1
	Reel Sequence Number	19-20		2
	User Bank 				21-23		3
	User Name 				31-56		26
	User Number 			57-62		6
	Description of Entries 	63-74		12
	Processing Date 		75-80		6
	*******************************************************************************/
    public void buildHeaderString(){
        try{
            if(mtdCombiz != null) {
                String formattedPDate = System.now().addDays(Integer.valueOf(mtdCombiz.ProcessingDays__c)).format('ddMMyy');      
                headerRecordStr = '0';  // Record Type
                headerRecordStr = buildRightPad(headerRecordStr,18,PyBt_Constants.SPACE,'',false,0);
                headerRecordStr = buildRightPad(headerRecordStr,20,PyBt_Constants.SPACE,'01',false,0); // Reel Sequence Number
                headerRecordStr = buildRightPad(headerRecordStr,30,PyBt_Constants.SPACE,mtdCombiz.UserBank__c,false,0); // User Bank
                headerRecordStr = buildRightPad(headerRecordStr,56,PyBt_Constants.SPACE,mtdCombiz.UserName__c,true,26); // User Name
                headerRecordStr = buildRightPad(headerRecordStr,62,PyBt_Constants.SPACE,mtdCombiz.UserNumber__c,true,6); // User Number
                headerRecordStr = buildRightPad(headerRecordStr,74,PyBt_Constants.SPACE,System.Label.PyAp_DirectDebit,false,0); // Direct Debit
                headerRecordStr = buildRightPad(headerRecordStr,80,PyBt_Constants.SPACE,formattedPDate,false,0); // Processing Date 
            }
        }catch (exception e){
            updateBRQ(new list<BatchRequestQueue__c> {batchRequestQueue},LoBt_Constants.BRQSTATUSERRORS);
            GlUt_Logger.logException(e);           
        } 
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           01 Feb 2019
    @description    Preapre the Detailed String Data (detailRecordsStr)
	-------------------------------------------------------
	Field								Position	Length
	-------------------------------------------------------
	Record Type							0-1			1
	Customer Branch Number 				2-8			7
	Customer Account Number				9-17		9
	Indicator 							18			1
	Transaction Code					19-20		2
	Amount				 				21-30		10
	Title of the Account to be debited  31-62 		32
	Lodgement Reference					63-80		18
	Branch Number						81-87		7
	Trace BSB							88-96		9
	Name of Remitter					97-112		16
	Withholding Tax						113-120		8
	*******************************************************************************/
    public void buildDetailedRecordString(DirectDebitRequest__c ddr){
        detailRecordsStr = '';
        detailRecordsStr = '1'; //Record Type
        
        if(ddr.BankAccountDetails__c != null && ddr.BankAccountDetails__r.BankAccountSortCode__c != null)
            detailRecordsStr = buildRightPad(detailRecordsStr,8,PyBt_Constants.SPACE, ddr.BankAccountDetails__r.BankAccountSortCode__c,true,7); // Customer Branch Number
        else detailRecordsStr = buildRightPad(detailRecordsStr,8,PyBt_Constants.SPACE,'',false,0); 
        
        if(ddr.BankAccountDetails__c != null && ddr.BankAccountDetails__r.BankAccountNumber__c != null)
            detailRecordsStr = buildRightPad(detailRecordsStr,17,PyBt_Constants.SPACE, ddr.BankAccountDetails__r.BankAccountNumber__c,true,9);// Customer Account Number
        else detailRecordsStr = buildRightPad(detailRecordsStr,17,PyBt_Constants.SPACE,'',false,0);
        
        detailRecordsStr = buildRightPad(detailRecordsStr,18,PyBt_Constants.SPACE,ddr.FirstRequestForBankAccount__c ? 'N' : ' ',false,0); // Indicator
        detailRecordsStr = buildRightPad(detailRecordsStr,20,PyBt_Constants.SPACE,'13',false,0); // Transaction Code
        
        String instalmentAmount = String.valueOf(ddr.Instalment__r.InstalmentAmountDue__c).replaceAll('[.-]','').leftPad(10,PyBt_Constants.ZERO);
        detailRecordsStr = buildRightPad(detailRecordsStr,30,PyBt_Constants.SPACE,instalmentAmount,false,0); // Amount
        
        if(ddr.BankAccountDetails__c != null && ddr.BankAccountDetails__r.Account__r.Name != null)
            detailRecordsStr = buildRightPad(detailRecordsStr,62,PyBt_Constants.SPACE,ddr.BankAccountDetails__r.Account__r.Name,true,32); // Title of the Account to be debited
        else detailRecordsStr = buildRightPad(detailRecordsStr,62,PyBt_Constants.SPACE,'',false,0);
    
        if(mtdCombiz != null) {
            String lodgeValue = String.valueOf(ddr.get(mtdCombiz.RefundLodgementReference__c));
            if(lodgeValue != null) detailRecordsStr = buildRightPad(detailRecordsStr,80,PyBt_Constants.SPACE,lodgeValue,true,18); // Lodgement Reference
            else detailRecordsStr = buildRightPad(detailRecordsStr,62,PyBt_Constants.SPACE,'',false,0);
            
            detailRecordsStr = buildRightPad(detailRecordsStr,87,PyBt_Constants.SPACE,mtdCombiz.BankBranch__c,true,7); // Branch Number
            detailRecordsStr = buildRightPad(detailRecordsStr,96,PyBt_Constants.SPACE,mtdCombiz.BankAccount__c,true,9); // Trace BSB
            detailRecordsStr = buildRightPad(detailRecordsStr,112,PyBt_Constants.SPACE,mtdCombiz.UserName__c,true,16); // Name of Remitter
        }
        detailRecordsStr = buildRightPad(detailRecordsStr,120,PyBt_Constants.ZERO,'',false,0); // Withholding Tax
        // build map to hold the detail record string
        if(!mapOfDirectDebitRequestIdToRecordsStr.containsKey(ddr.Id)){
            mapOfDirectDebitRequestIdToRecordsStr.put(ddr.Id,detailRecordsStr);
        }
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           01 Feb 2019
    @description    Preapre the Balancing Detailed Record String Data (balancingDetailRecord)
	-------------------------------------------------------
	Field								Position	Length
	-------------------------------------------------------
	Record Type							0-1			1
	Customer Branch Number 				2-8			7
	Customer Account Number				9-17		9
	Indicator 							18			1
	Transaction Code					19-20		2
	Amount				 				21-30		10
	Title of the Account to be debited  31-62 		32
	Lodgement Reference					63-80		18
	Branch Number						81-87		7
	Trace BSB							88-96		9
	Name of Remitter					97-112		16
	Withholding Tax						113-120		8
	*******************************************************************************/
    public void buildBalanceDetailRecord(){
        if(mtdCombiz != null) {
            String totalAmount 		= String.valueOf(totalDebitAmount).replaceAll('[.-]','').leftPad(10,PyBt_Constants.ZERO); // Amount
            String formattedPDate 	= 'DD-' + System.now().format('ddMMyyyyhhmmss'); 
            balancingDetailRecord 	= '1'; //Record Type
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,8,PyBt_Constants.SPACE,mtdCombiz.BankBranch__c,true,7); // Customer Branch Number
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,17,PyBt_Constants.SPACE,mtdCombiz.BankAccount__c,true,9); // Customer Account Number
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,18,PyBt_Constants.SPACE,'',false,0); // Indicator
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,20,PyBt_Constants.SPACE,'50',false,0); // Transaction Code
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,30,PyBt_Constants.SPACE,totalAmount,false,0);
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,62,PyBt_Constants.SPACE,mtdCombiz.UserName__c,true,32); // Title of the Account to be debited
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,80,PyBt_Constants.SPACE,formattedPDate,false,0); // Lodgement Reference
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,87,PyBt_Constants.SPACE,mtdCombiz.BankBranch__c,true,7); // Branch Number
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,96,PyBt_Constants.SPACE,mtdCombiz.BankAccount__c,true,9); //  Trace BSB
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,112,PyBt_Constants.SPACE,mtdCombiz.UserName__c,true,16); // Name of Remitter
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,120,PyBt_Constants.ZERO,'',false,0); // Withholding Tax
        }
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           01 Feb 2019
    @description    Prepare Trailer String Record data (trailerRecordStr)
	--------------------------------------
	Field   			Position  	Length  
	--------------------------------------
	Record Type 		1			1
	Branch Number 		2-8 		7
	File Net Total  	21-30  		10
	File Credit Total 	31-40		10
	File Debit Total 	41-50 		10
	Total Records 		75-80 		6
	*******************************************************************************/
    public void buildTrailerRecord(){
        String fileNetTotal = String.valueOf(totalCreditAmount - totalCreditAmount).replaceAll('[.-]','').leftPad(10,PyBt_Constants.ZERO);
        String totalCredit = String.valueOf(totalCreditAmount).replaceAll('[.-]','').leftPad(10,PyBt_Constants.ZERO);
        String totalRecords = String.valueOf(totalRecordProcessed).leftPad(6,PyBt_Constants.ZERO);
        
        trailerRecordStr = '7'; //Record Type
        trailerRecordStr = buildRightPad(trailerRecordStr,20,PyBt_Constants.SPACE,'999-999',false,0); //Branch Number 
        trailerRecordStr = buildRightPad(trailerRecordStr,30,PyBt_Constants.SPACE,fileNetTotal,false,0); //File Net Total (Total Debit Amount - Total Credit Amount (Always 0))
        trailerRecordStr = buildRightPad(trailerRecordStr,40,PyBt_Constants.SPACE,totalCredit,false,0); //File Credit Total        
        trailerRecordStr = buildRightPad(trailerRecordStr,74,PyBt_Constants.SPACE,totalCredit,false,0); //File Debit Total
        trailerRecordStr = buildRightPad(trailerRecordStr,80,PyBt_Constants.SPACE,totalRecords,false,0); //Total Records
    }    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           01 Feb 2019
    @description    updateBRQ - Update Batch Request Queue Status
   *******************************************************************************/
    public static list<BatchRequestQueue__c> updateBRQ(list<BatchRequestQueue__c> batchRequestQueueList , String Status){
        //SOQL is required here in order to prevent "Record is Read-only" during batch context
        set<Id> setBRQIds = new set<Id>() ;
        list<BatchRequestQueue__c> listBatchRequestQueueToUpdate = new list<BatchRequestQueue__c>() ;
        for(BatchRequestQueue__c brq : batchRequestQueueList) {
            setBRQIds.add(brq.Id) ;
        }
        for(BatchRequestQueue__c brq :  [Select id,Status__c from BatchRequestQueue__c where Id IN: setBRQIds]) {
            brq.Status__c = Status ;
            listBatchRequestQueueToUpdate.add(brq) ;
        }
        if(!listBatchRequestQueueToUpdate.isEmpty() && listBatchRequestQueueToUpdate.size() > 0){
            listBatchRequestQueueToUpdate = (List<BatchRequestQueue__c>)GlUt_FieldSecurity.cleanseFields(listBatchRequestQueueToUpdate,false);
            update listBatchRequestQueueToUpdate;
        }
        return listBatchRequestQueueToUpdate;
    }
}