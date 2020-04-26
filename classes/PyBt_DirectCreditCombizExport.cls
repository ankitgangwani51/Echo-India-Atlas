/******************************************************************************
@author         Echo: Ankit Gangwani
@date           29 Jan 2019
@description    PyBt_DirectCreditCombizExport class 
				will export all the payment (Refund) records
*******************************************************************************/
global with sharing class PyBt_DirectCreditCombizExport extends GlBt_BatchProcess implements Database.Batchable<sObject>, Database.Stateful {
    
    private static string sQuery;
    private Integer totalRecordProcessed = 0;
    private Decimal totalCreditAmount = 0.0; 
    private BatchRequestQueue__c batchRequestQueue;
    private String headerRecordStr; 		//containing header record data.
    private String detailRecordsStr; 		//containing detailed record data. 
    private String trailerRecordStr; 		//containing trailer record data
    private String balancingDetailRecord; 	//containing balancing detail record data
    
    private static List<String> paymentFields;
    private CombizInterface__mdt mtdCombiz = new CombizInterface__mdt();
    private Map<Id,String> mapOfPaymentIdToDetailRecordsStr = new Map<Id,String>();
    static{
        paymentFields = new List<String>();
        paymentFields.add(GlUt_APIConstantsPayments.RECORDTYPEAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.REFUNDEXPORTSTATUSAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.REFUNDAPPROVEDDATEAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.BANKACCOUNTDETAILAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.TRANSFERREDAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.BANKACCOUNTNOAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.BANKACCSORTCODEAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.ACCOUNTAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.AMOUNTAPINAME);        
        paymentFields.add(GlUt_APIConstantsPayments.BANKACCOUNTDETAILSBANKACCOUNTNUMBERAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.BANKACCOUNTDETAILSSORTCODEAPINAMEAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.BANKACCOUNTDETAILSNAMEAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.ACCOUNTNAMEAPINAME);
        
    }
    private static String RefundRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(PyAp_Constants.REFUND).getRecordTypeId() ; 
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           29 Jan 2019
    @description    Override GlBt_BatchProcess method as per Batch framework.
    *******************************************************************************/
    global override void Initialise(BatchRequestQueue__c brq){
        this.batchRequestQueue = brq;
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           25 Jan 2019
    @description   	This method will query all Payment (Refunds) Records and pass to the execute method for processing
   *******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {        
        // Update the Batch Request Queue status to "Processing"
        updateBRQ(new list<BatchRequestQueue__c> {batchRequestQueue},LoBt_Constants.BRQPROCESSINGSTATUS);
        
        mtdCombiz  =GlUt_CustomMetaDataUtility.getCustomDataforCombizInterface(PyBt_Constants.COMBIZMETADATAQUERY);
        if(mtdCombiz != null && !paymentFields.contains(mtdCombiz.RefundLodgementReference__c))  //Condev deployment fix
            paymentFields.add(mtdCombiz.RefundLodgementReference__c);
        buildHeaderString();
        //Get all the Payment Records
        sQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(paymentFields,','), 
            GlUt_APIConstantsPayments.PAYMENTAPINAME +
            ' WHERE ' + GlUt_APIConstantsPayments.RECORDTYPEAPINAME 		+ ' = \'' + RefundRecordTypeId + '\'' + 
            ' AND '	+ GlUt_APIConstantsPayments.REFUNDEXPORTSTATUSAPINAME 	+ ' = \'' + PyBt_Constants.REFUND_EXPORT_STATUS_READY + '\'' + 
            ' AND ' + GlUt_APIConstantsPayments.REFUNDAPPROVEDDATEAPINAME 	+ ' = TODAY ' + 
            ' AND ' + GlUt_APIConstantsPayments.TRANSFERREDAPINAME 			+ ' = \'' + PyBt_Constants.TRANSFERRED_STATUS_NO + '\'' });
        system.debug('sQuery = '+sQuery);
        return Database.getQueryLocator(sQuery);        
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           29 Jan 2019
    @description    This method will prepare the text file for all the payment (Refund) records
    *******************************************************************************/
    global void execute(Database.BatchableContext bc, List<SObject> scope){ 
        try{
            system.debug('scope = '+scope);
            List<Payment__c> paymentListToUpdate = new List<Payment__c>();
            List<Payment__c> paymentLists = new List<Payment__c>();
            if(scope != null && scope.size() > 0){                
                for(Payment__c payment : (List<Payment__c>) scope){
                    //Either Bank Account Number OR Bank Account Details is present to be proceed in the payment record
                    if(payment.BankAccountNumber__c != null || payment.BankAccountDetail__c != null){
                        paymentLists.add(payment);
                    }                    
                }
            }       
            
            // Prepare the detailRecordsStr data AND updtae the Refund Export Status to 'Processed'
            if(!paymentLists.isEmpty() && paymentLists.size() > 0){
                for(Payment__c payment : paymentLists){
                    totalRecordProcessed = totalRecordProcessed + 1;
                    totalCreditAmount = totalCreditAmount + payment.Amount__c;
                    buildDetailedRecordString(payment);
                    payment.RefundExportStatus__c = GlUt_Constants.PROCESSED;
                    paymentListToUpdate.add(payment);
                }
            }    
            if(!paymentListToUpdate.isEmpty() && paymentListToUpdate.size() > 0){
                paymentListToUpdate = (List<Payment__c>) GlUt_FieldSecurity.cleanseFields(paymentListToUpdate,false);
                Database.update(paymentListToUpdate);
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
    @date           29 Jan 2019
    @description    This method will link the text file with the batch request queue record
   *******************************************************************************/
    global void finish(Database.BatchableContext bc){
        Savepoint sp = Database.setSavepoint();
        try{      
            buildBalanceDetailRecord();
            buildTrailerRecord();            
            
            String fileData = headerRecordStr + '\r\n';
            if(mapOfPaymentIdToDetailRecordsStr.size() > 0 && mapOfPaymentIdToDetailRecordsStr.keySet().size() > 0){
                for(Id paymentId : mapOfPaymentIdToDetailRecordsStr.keySet()){
                    String getDetailedRecordData = mapOfPaymentIdToDetailRecordsStr.get(paymentId);
                    fileData = fileData + getDetailedRecordData + '\r\n';
                }
            }
            
            fileData = fileData + balancingDetailRecord + '\r\n';
            fileData = fileData + trailerRecordStr;
            
            DateTime currentDateTime = System.now();
            String formattedPDate = currentDateTime.format('ddMMyyyyhhmmss'); 
            String fileName = PyBt_Constants.COMBIZ_REFUND + '_' + formattedPDate + GlUt_Constants.ABA_FILE_EXTENSION;  //'.aba';
            
            if(headerRecordStr.length() > 0 && mapOfPaymentIdToDetailRecordsStr.size() > 0 && balancingDetailRecord.length() > 0 && trailerRecordStr.length() > 0){
                Id contentDocumentId = GlUt_ContentDocument.saveLinkedDocument(batchRequestQueue.Id, PyBt_Constants.DIRECT_CREDIT_COMBIZ_EXPORT, fileName, fileName, LoBt_Constants.SHARE_TYPE, blob.valueOf(fileData));
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
    @date           29 Jan 2019
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
            if(mtdCombiz != null){
                DateTime processingDate = System.now().addDays(Integer.valueOf(mtdCombiz.ProcessingDays__c));
                headerRecordStr = '0';             
                headerRecordStr = buildRightPad(headerRecordStr,18,PyBt_Constants.SPACE,'', false, 0); // Record Type
                headerRecordStr = buildRightPad(headerRecordStr,18,PyBt_Constants.SPACE,'01',false, 0); // Reel Sequence Number
                headerRecordStr = buildRightPad(headerRecordStr,30,PyBt_Constants.SPACE,mtdCombiz.UserBank__c,false,0); // User Bank
                headerRecordStr = buildRightPad(headerRecordStr,56,PyBt_Constants.SPACE,mtdCombiz.UserName__c,true,26); // User Name
                headerRecordStr = buildRightPad(headerRecordStr,62,PyBt_Constants.SPACE,mtdCombiz.UserNumber__c,true,6); // User Number
                headerRecordStr = buildRightPad(headerRecordStr,74,PyBt_Constants.SPACE,System.Label.PyAp_DirectDebit,false,0); // Direct Debit
                headerRecordStr = buildRightPad(headerRecordStr,80,PyBt_Constants.SPACE,processingDate.format('ddMMyy'),false,0);  // Processing Date 
            }
            
        }catch (exception e){
            updateBRQ(new list<BatchRequestQueue__c> {batchRequestQueue},LoBt_Constants.BRQSTATUSERRORS);
            GlUt_Logger.logException(e);           
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           29 Jan 2019
    @description    Preapre the Detailed String Data (detailRecordsStr)
	-------------------------------------------------------
	Field								Position	Length
	-------------------------------------------------------
	Record Type							0-1			1
	Customer Branch Number 				2-8			7
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
    public void buildDetailedRecordString(Payment__c payment){
        detailRecordsStr = '';
        detailRecordsStr = '1'; //Record Type
        
        if(payment.BankAccountDetail__c != null) detailRecordsStr = buildRightPad(detailRecordsStr,8,PyBt_Constants.SPACE,payment.BankAccountDetail__r.BankAccountSortCode__c,true,7); // Customer Branch Number
        else if(payment.BankAccountSortCode__c != null) detailRecordsStr = buildRightPad(detailRecordsStr,8,PyBt_Constants.SPACE,payment.BankAccountSortCode__c,true,7); // Customer Branch Number
        
        if(payment.BankAccountDetail__c != null) detailRecordsStr = buildRightPad(detailRecordsStr,17,PyBt_Constants.SPACE,payment.BankAccountDetail__r.BankAccountNumber__c,true,9); // Customer Account Number
        else if(payment.BankAccountNumber__c != null) detailRecordsStr = buildRightPad(detailRecordsStr,17,PyBt_Constants.SPACE,payment.BankAccountNumber__c,true,9); // Customer Account Number
        
        detailRecordsStr = buildRightPad(detailRecordsStr,18,PyBt_Constants.SPACE,'',false,0); // Indicator
        detailRecordsStr = buildRightPad(detailRecordsStr,20,PyBt_Constants.SPACE,'50',false,0); // Transaction Code
        
        String amountLeadsZero = String.valueOf(payment.Amount__c).replaceAll('[.-]','').leftPad(10,PyBt_Constants.ZERO);
        detailRecordsStr = buildRightPad(detailRecordsStr,30,PyBt_Constants.SPACE,amountLeadsZero,false,0); // Amount
        
        if(payment.BankAccountDetail__c != null) detailRecordsStr = buildRightPad(detailRecordsStr,62,PyBt_Constants.SPACE,payment.BankAccountDetail__r.Name,true,32); // Title of the Account to be debited
        else if(payment.Account__c != null) detailRecordsStr = buildRightPad(detailRecordsStr,62,PyBt_Constants.SPACE,payment.Account__r.Name,true,32); // Title of the Account to be debited
        
        if(mtdCombiz!= null){   
            String lodgeValue = String.valueOf(payment.get(mtdCombiz.RefundLodgementReference__c)); 
            if(lodgeValue != null) detailRecordsStr = buildRightPad(detailRecordsStr,80,PyBt_Constants.SPACE,lodgeValue,true,18); // Lodgement Reference
            else detailRecordsStr = buildRightPad(detailRecordsStr,80,PyBt_Constants.SPACE,'',false,0); // Lodgement Reference
            
            detailRecordsStr = buildRightPad(detailRecordsStr,87,PyBt_Constants.SPACE,mtdCombiz.BankBranch__c,true,7); // Branch Number
            detailRecordsStr = buildRightPad(detailRecordsStr,96,PyBt_Constants.SPACE,mtdCombiz.BankAccount__c,true,9); // Trace BSB
            detailRecordsStr = buildRightPad(detailRecordsStr,112,PyBt_Constants.SPACE,mtdCombiz.UserName__c,true,16); // Name of Remitter
    	}
        detailRecordsStr = buildRightPad(detailRecordsStr,120,PyBt_Constants.ZERO,'',false,0); // Withholding Tax
        
        // build map to hold the detail record string
        if(!mapOfPaymentIdToDetailRecordsStr.containsKey(payment.Id)){
            mapOfPaymentIdToDetailRecordsStr.put(payment.Id,detailRecordsStr);
        }
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           29 Jan 2019
    @description    Preapre the Balancing Detailed Record String Data (balancingDetailRecord)
	-------------------------------------------------------
	Field								Position	Length
	-------------------------------------------------------
	Record Type							0-1			1
	Customer Branch Number 				2-8			7
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
       
        if(mtdCombiz != null){
            String formattedPDate 	= 'DD-' + System.now().format('dd-MM-yyyy');  // Lodgement Reference
            String totalAmount 		= String.valueOf(totalCreditAmount).replaceAll('[.-]','').leftPad(10,PyBt_Constants.ZERO); // Amount
            balancingDetailRecord 	= '1'; //Record Type
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,8,PyBt_Constants.SPACE,mtdCombiz.BankBranch__c,true,7); // Customer Branch Number
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,17,PyBt_Constants.SPACE,mtdCombiz.BankAccount__c,true,9); // Customer Account Number
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,18,PyBt_Constants.SPACE,'',false,0); // Indicator
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,20,PyBt_Constants.SPACE,'50',false,0); // Transaction Code
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,30,PyBt_Constants.SPACE,totalAmount,false,0); // Amount
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,62,PyBt_Constants.SPACE,mtdCombiz.UserName__c,true,32); // Title of the Account to be debited
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,80,PyBt_Constants.SPACE,formattedPDate,false,0); // Lodgement Reference
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,87,PyBt_Constants.SPACE,mtdCombiz.BankBranch__c,true,7); // Branch Number
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,96,PyBt_Constants.SPACE,mtdCombiz.BankAccount__c,true,9); // Trace BSB
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,112,PyBt_Constants.SPACE,mtdCombiz.UserName__c,true,16); // Name of Remitter
            balancingDetailRecord 	= buildRightPad(balancingDetailRecord,120,PyBt_Constants.ZERO,'',false,0); // Withholding Tax
        }
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           29 Jan 2019
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
        trailerRecordStr = buildRightPad(trailerRecordStr,30,PyBt_Constants.SPACE,fileNetTotal,false,0); //File Net Total (Total De
        trailerRecordStr = buildRightPad(trailerRecordStr,40,PyBt_Constants.SPACE,totalCredit,false,0); //File Credit Total        
        trailerRecordStr = buildRightPad(trailerRecordStr,74,PyBt_Constants.SPACE,totalCredit,false,0); //File Debit Total, Debit == Credit
        trailerRecordStr = buildRightPad(trailerRecordStr,80,PyBt_Constants.SPACE,totalRecords,false,0); //Total Records
    }
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           25 Jan 2019
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
            update listBatchRequestQueueToUpdate ;    
        }
        return listBatchRequestQueueToUpdate ;
    }
}