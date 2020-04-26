/******************************************************************************
@author         Echo: Ankit Gangwani
@date           31 Dec 2018
@description    Class is used to Extract xml data and create new 
				concession validation record based on CRN provided in xml file
*******************************************************************************/
global with sharing class CuBt_ConcessionImport extends GlBt_BatchProcess implements Database.Batchable<sObject>,Database.Stateful {
    
    global static string sQuery;
    global Integer numberOfConcessionValidationCreated = 0;
    global Integer numberOfErrors = 0;
    global BatchRequestQueue__c batchRequestQueue;
    global class ConcessionImportXMLTagsWrapper {
        private String statusRespId;
        private String crn; 
        private String mtchCode;
        private String cnfrmDate;
        private String pcc;
        private String hcc;
        private String shc;
        private String lic;
        private String entStartDate;        
        private String entEndDate;
        private String deceased;
        private String blind;
        private String over70;
        private String war;
        private String inst;
        private String pcode;
        private String numChild;
        private String scndryCrn;
        private String pymt;
        private String maxRate;
        private String rateThold;
        private String rateRatio;
        private String otherPayments;
    }
    
    global List<BatchError__c> batchErrorList 					= new List<BatchError__c>();
    global Map<String,String> mapOfStatusResponseNumberToCRN 	= new Map<String,String>();
    global Map<String,String> mapOfHCCPickListData 				= new Map<String,String>();
    global Map<String,String> mapOfLICPickListData 				= new Map<String,String>();
    global Map<String,String> mapOfSHCPickListData 				= new Map<String,String>();
    global Map<String,String> mapOfPCCPickListData 				= new Map<String,String>();
    global Map<String,String> mapOfPCODEPickListData 			= new Map<String,String>();
    global Map<String,String> pickListDataMap 					= new Map<String,String>();
    global Map<String,String> mapOfMatchCodeToDescription 		= new Map<String,String>();
    global Map<String,List<ConcessionImportXMLTagsWrapper>> mapOfStatusRespIdToListOfStatusRespWrapper = new Map<String,List<ConcessionImportXMLTagsWrapper>>();
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           31 Dec 2018
    @description    Override GlBt_BatchProcess method as per Batch framework.
    *******************************************************************************/
    global override void Initialise(BatchRequestQueue__c brq){
        this.batchRequestQueue = brq;
    }
    
    /******************************************************************************
	@author    		Echo: Ankit Gangwani
	@date      		31 Dec 2018
	@param			List<ContentDocumentLink> cdlList	
	@return			Void
	@description 	override method of GlBt_BatchProcess to retrieve content VersionList data and insert records
					in BatchError & ReadingUpload Accordingly
	*******************************************************************************/
    global override List<BatchError__c> FileImport(List<ContentDocumentLink> cdlList){          
        
        List<BatchError__c> batchErrorList = new List<BatchError__c>();
        List<Id> ContentDocumentIdList = new List<Id>(); 
        
        // ContentDcoumentLink records associated with the Batch Request Queues
        // Get ContentDocument ID associated with ContentDcoumentLink           
        for(ContentDocumentLink objCDL : [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE Id IN: cdlList  AND LinkedEntityId =: batchRequestQueue.Id]){
            ContentDocumentIdList.add(objCDL.ContentDocumentId);            
        } 
        
        //ContentDocument records of csv extension
        List<ContentDocument> conDocList = [SELECT Id FROM ContentDocument WHERE Id IN: ContentDocumentIdList AND FileType =:GlUt_Constants.FILEEXTENSIONXML];       
        
        // Retrieve the CSV file data from ContentVersion 
        List<ContentVersion> conVersionList = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId IN: conDocList];
        
        if (conVersionList.size() > 0){            
            // update Batch Request Queue Status
            BatchRequestQueue__c objBRQ = [SELECT Id, Status__c FROM BatchRequestQueue__c WHERE ID =: batchRequestQueue.Id LIMIT 1];
            objBRQ.Status__c = GlUt_Constants.INITIALISED; 
            database.update(objBRQ);
        }
        else{
            // update Batch Request Queue Status
            BatchRequestQueue__c objBRQ = [SELECT Id, Status__c FROM BatchRequestQueue__c WHERE ID =: batchRequestQueue.Id LIMIT 1];
            objBRQ.Status__c = GlUt_Constants.ERRORS; 	
            database.update(objBRQ); 
        }
        return batchErrorList;
    }
	
    /******************************************************************************
	@author    		Echo: Ankit Gangwani
	@date      		31 Dec 2018
	@param		    None
	@return			Void
	@description 	Get all the picklist labels/values from Concession Validatio API fields
	*******************************************************************************/
    private void getPickListValuesIntoList(){
        
        // Health Care Card
        Schema.DescribeFieldResult hccResult = ConcessionValidation__c.HCC__c.getDescribe();
        List<Schema.PicklistEntry> hcc = hccResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : hcc){
            mapOfHCCPickListData.put(pickListVal.getLabel(),pickListVal.getValue());
        }   
        
        // Seniors Health Card
        Schema.DescribeFieldResult shcResult = ConcessionValidation__c.SHC__c.getDescribe();
        List<Schema.PicklistEntry> shc = shcResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : shc){
            mapOfSHCPickListData.put(pickListVal.getLabel(),pickListVal.getValue());
        }   
        
        // Low Income Card
        Schema.DescribeFieldResult licResult = ConcessionValidation__c.LIC__c.getDescribe();
        List<Schema.PicklistEntry> lic = licResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : lic){
            mapOfLICPickListData.put(pickListVal.getLabel(),pickListVal.getValue());
        }   
        
        // Pensioner Concession Card
        Schema.DescribeFieldResult pccResult = ConcessionValidation__c.PCC__c.getDescribe();
        List<Schema.PicklistEntry> pcc = pccResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : pcc){
            mapOfPCCPickListData.put(pickListVal.getLabel(),pickListVal.getValue());
        }   
        
        // Post Code
        Schema.DescribeFieldResult pcodeResult = ConcessionValidation__c.PostCode__c.getDescribe();
        List<Schema.PicklistEntry> pcode = pcodeResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : pcode){
            mapOfPCODEPickListData.put(pickListVal.getLabel(),pickListVal.getValue());
        }
    }
    
    /******************************************************************************
	@author    		Echo: Ankit Gangwani
	@date      		31 Dec 2018
	@param			List<ContentVersion> conVersionList, Id brqID
	@return			Void
	@description 	validate the XML data and build mapOfStatusRespIdToListOfStatusRespWrapper 
					and batchErrorList
	*******************************************************************************/
 	private void readingXMLData(List<ContentVersion> conVersionList, Id brqID){ 
        
        Blob blobfileData;
        String fileData;
        Map<String,String> mapOfStatusRespIdToTags = new Map<String,String>();
        getPickListValuesIntoList();
        for(ContentVersion objCV : conVersionList){ 
            
            blobfileData = objCV.VersionData;
            fileData = blobfileData.toString(); 
            
            // Get all file lines
            List<String> totalfileDataLines = fileData.split('\n');
            
            // Retrieve per Line data of a file            
            for(Integer lineno=0; lineno<totalfileDataLines.size(); lineno++){                 
                if(totalfileDataLines[lineno].indexOf('<statusResp') > -1){ 
                    String statusRespId = totalfileDataLines[lineno].substringBetween('<statusResp id="','">');  
                    if(statusRespId != null){
                        String tags = fileData.substringBetween('<statusResp id="' + statusRespId + '">', '</statusResp>');
                        mapOfStatusRespIdToTags.put(statusRespId,tags);
                    }
                }
            }            
            
            if(mapOfStatusRespIdToTags.size() > 0){
                for(String responseID : mapOfStatusRespIdToTags.keySet()){
                    String responseData = mapOfStatusRespIdToTags.get(responseID);
                    List<String> statusRespData = responseData.split('\n');
                    buildMapOfStatusResponseWrapper(statusRespData, responseID);
                }                
            }
        } // End of all file data        
    }
    
    /******************************************************************************
	@author    		Echo: Ankit Gangwani
	@date      		31 Dec 2018
	@param			List<String> statusRespData
	@return			Void	
	*******************************************************************************/
    private void createBatchErrorRecord(String errorDetails){
        numberOfErrors = numberOfErrors + 1;
        BatchError__c batchError = new BatchError__c();
        batchError.BatchRequestQueue__c = batchRequestQueue.Id;
        batchError.ErrorDetails__c = errorDetails;
        batchError.BatchRequestOperation__c=GlUt_Constants.BATCHPROCESSOPERATION;
        batchError.BatchRequestType__c = GlUt_Constants.BRTYPECONCESSION;
        batchErrorList.add(batchError);
    }

    /******************************************************************************
	@author    		Echo: Ankit Gangwani
	@date      		31 Dec 2018
	@param			List<String> statusRespData
	@return			Void	
	*******************************************************************************/
 	private void buildMapOfStatusResponseWrapper(List<String> statusRespData, String responseID){
        
        ConcessionImportXMLTagsWrapper response = new ConcessionImportXMLTagsWrapper();
        for(Integer lineNo=0;lineNo<statusRespData.size();lineNo++){
            if(statusRespData[lineNo].indexOf(CuBt_ConcessionXMLTagConstants.CRN_OPEN) > -1){ 
                response.crn = statusRespData[lineNo].substringBetween(CuBt_ConcessionXMLTagConstants.CRN_OPEN,
                                                                       CuBt_ConcessionXMLTagConstants.CRN_CLOSE); 
            }
            
            if(statusRespData[lineNo].indexOf(CuBt_ConcessionXMLTagConstants.MATCHCODE_OPEN) > -1){
                response.mtchCode = statusRespData[lineNo].substringBetween(CuBt_ConcessionXMLTagConstants.MATCHCODE_OPEN,
                                                                            CuBt_ConcessionXMLTagConstants.MATCHCODE_CLOSE);
                if(response.mtchCode != '2'){
                    response.crn = null;
                    String errorDescription = '';
                    if(mapOfMatchCodeToDescription.containsKey(response.mtchCode)){
                        errorDescription = mapOfMatchCodeToDescription.get(response.mtchCode);
                    }else{
                        errorDescription = System.Label.CuBt_InvalidMatchCode;
                    }              
                    createBatchErrorRecord(errorDescription);
                    break;
                }
                
            }
            
            
            if(statusRespData[lineNo].indexOf(CuBt_ConcessionXMLTagConstants.NUMCHILD_OPEN) > -1){
                response.numChild = statusRespData[lineNo].substringBetween(CuBt_ConcessionXMLTagConstants.NUMCHILD_OPEN,
                                                                            CuBt_ConcessionXMLTagConstants.NUMCHILD_CLOSE);
            }
            
            if(statusRespData[lineNo].indexOf(CuBt_ConcessionXMLTagConstants.PCODE_OPEN) > -1){ 
                response.pcode = statusRespData[lineNo].substringBetween(CuBt_ConcessionXMLTagConstants.PCODE_OPEN,
                                                                         CuBt_ConcessionXMLTagConstants.PCODE_CLOSE);
                if(response.pcode != null && response.pcode != ''){
                    if(pickListDataMap.containsKey(response.pcode)){
                        response.pcode = pickListDataMap.get(response.pcode);
                        if(mapOfPCODEPickListData.containsKey(response.pcode)){
                            response.pcode = mapOfPCODEPickListData.get(response.pcode);
                        }
                        else{
                            response.crn = null;
                            createBatchErrorRecord(System.Label.CuBt_PostCodeInvalid +statusRespData[lineNo].trim());
                            break;                            
                        }
                            
                    }else{
                        response.crn = null;
                        createBatchErrorRecord(System.Label.CuBt_PostCodeInvalid+statusRespData[lineNo].trim());
                        break;
                    }
                }
            }
            
            if(statusRespData[lineNo].indexOf(CuBt_ConcessionXMLTagConstants.CONFIRMDATE_OPEN) > -1){ 
                Date confirmDate;
                response.cnfrmDate = statusRespData[lineNo].substringBetween(CuBt_ConcessionXMLTagConstants.CONFIRMDATE_OPEN,
                                                                             CuBt_ConcessionXMLTagConstants.CONFIRMDATE_CLOSE);
                try{
                    // Confirm Date
                    if(response.cnfrmDate != null && response.cnfrmDate != '' ){
                        confirmDate = Date.valueOf(response.cnfrmDate);
                    }
                }catch(Exception e){  
                    response.crn = null;    
                    createBatchErrorRecord(System.Label.CuBt_ConfirmDateInvalid+response.cnfrmDate);                                    
                    break;
                } 
            }
            
            if(statusRespData[lineNo].indexOf(CuBt_ConcessionXMLTagConstants.PCC_OPEN) > -1){ 
                response.pcc = statusRespData[lineNo].substringBetween(CuBt_ConcessionXMLTagConstants.PCC_OPEN,
                                                                       CuBt_ConcessionXMLTagConstants.PCC_CLOSE);
                if(response.pcc != null && response.pcc != ''){
                    if(pickListDataMap.containsKey(response.pcc)){
                        response.pcc = pickListDataMap.get(response.pcc);
                        if(mapOfPCCPickListData.containsKey(response.pcc))
                            response.pcc = mapOfPCCPickListData.get(response.pcc);
                        else{
                            response.crn = null;
                            createBatchErrorRecord(System.Label.CuBt_PCCInvalid+statusRespData[lineNo].trim());
                            break;                            
                        }
                            
                    }else{
                        response.crn = null;
                        createBatchErrorRecord(System.Label.CuBt_PCCInvalid+statusRespData[lineNo].trim());
                        break;
                    }
                }
            }
            
            if(statusRespData[lineNo].indexOf(CuBt_ConcessionXMLTagConstants.HCC_OPEN) > -1){ 
                response.hcc = statusRespData[lineNo].substringBetween(CuBt_ConcessionXMLTagConstants.HCC_OPEN,
                                                                       CuBt_ConcessionXMLTagConstants.HCC_CLOSE);
                if(response.hcc != null && response.hcc != ''){
                    if(pickListDataMap.containsKey(response.hcc)){
                        response.hcc = pickListDataMap.get(response.hcc);
                        if(mapOfHCCPickListData.containsKey(response.hcc))
                            response.hcc = mapOfHCCPickListData.get(response.hcc);
                        else{
                            response.crn = null;
                            createBatchErrorRecord(System.Label.CuBt_HCCInvalid+statusRespData[lineNo].trim());
                            break;                            
                        }
                        
                    }else{
                        response.crn = null;
                        createBatchErrorRecord(System.Label.CuBt_HCCInvalid+statusRespData[lineNo].trim());
                        break;
                    }
                }
            }
            
            if(statusRespData[lineNo].indexOf(CuBt_ConcessionXMLTagConstants.SHC_OPEN) > -1){ 
                response.shc = statusRespData[lineNo].substringBetween(CuBt_ConcessionXMLTagConstants.SHC_OPEN,
                                                                       CuBt_ConcessionXMLTagConstants.SHC_CLOSE);
                if(response.shc != null && response.shc != ''){
                    if(pickListDataMap.containsKey(response.shc)){
                        response.shc = pickListDataMap.get(response.shc);
                        if(mapOfSHCPickListData.containsKey(response.shc))
                            response.shc = mapOfSHCPickListData.get(response.shc);
                        else{
                            response.crn = null;
                            createBatchErrorRecord(System.Label.CuBt_SHCInvalid+statusRespData[lineNo].trim());
                            break;                            
                        }
                        
                    }else{
                        response.crn = null;
                        createBatchErrorRecord(System.Label.CuBt_SHCInvalid+statusRespData[lineNo].trim());
                        break;
                    }
                }
            }
            
            if(statusRespData[lineNo].indexOf(CuBt_ConcessionXMLTagConstants.LIC_OPEN) > -1){ 
                response.lic = statusRespData[lineNo].substringBetween(CuBt_ConcessionXMLTagConstants.LIC_OPEN,
                                                                       CuBt_ConcessionXMLTagConstants.LIC_CLOSE);
                if(response.lic != null && response.lic != ''){
                    if(pickListDataMap.containsKey(response.lic)){
                        response.lic = pickListDataMap.get(response.lic);
                        if(mapOfLICPickListData.containsKey(response.lic))
                            response.lic = mapOfLICPickListData.get(response.lic);
                        else{
                            response.crn = null;
                            createBatchErrorRecord(System.Label.CuBt_LICInvalid+statusRespData[lineNo].trim());
                            break;                            
                        }
                        
                    }else{
                        response.crn = null;
                        createBatchErrorRecord(System.Label.CuBt_LICInvalid+statusRespData[lineNo].trim());
                        break;
                    }
                }
            }
            
            if(statusRespData[lineNo].indexOf(CuBt_ConcessionXMLTagConstants.ENTSTARTDATE_OPEN) > -1){ 
                response.entStartDate = statusRespData[lineNo].substringBetween(CuBt_ConcessionXMLTagConstants.ENTSTARTDATE_OPEN,
                                                                                CuBt_ConcessionXMLTagConstants.ENTSTARTDATE_CLOSE);
            }
            
            if(statusRespData[lineNo].indexOf(CuBt_ConcessionXMLTagConstants.ENTENDDATE_OPEN) > -1){ 
                response.entEndDate = statusRespData[lineNo].substringBetween(CuBt_ConcessionXMLTagConstants.ENTENDDATE_OPEN,
                                                                              CuBt_ConcessionXMLTagConstants.ENTENDDATE_CLOSE);
            }
            
            if(statusRespData[lineNo].indexOf(CuBt_ConcessionXMLTagConstants.DECEASED_OPEN) > -1){ 
                response.deceased = statusRespData[lineNo].substringBetween(CuBt_ConcessionXMLTagConstants.DECEASED_OPEN,
                                                                            CuBt_ConcessionXMLTagConstants.DECEASED_CLOSE);
            }
            
            if(statusRespData[lineNo].indexOf(CuBt_ConcessionXMLTagConstants.BLIND_OPEN) > -1){ 
                response.blind = statusRespData[lineNo].substringBetween(CuBt_ConcessionXMLTagConstants.BLIND_OPEN,
                                                                         CuBt_ConcessionXMLTagConstants.BLIND_CLOSE);
            }
            
            if(statusRespData[lineNo].indexOf(CuBt_ConcessionXMLTagConstants.OVER70_OPEN) > -1){ 
                response.over70 = statusRespData[lineNo].substringBetween(CuBt_ConcessionXMLTagConstants.OVER70_OPEN,
                                                                          CuBt_ConcessionXMLTagConstants.OVER70_CLOSE);
            }
            
            if(statusRespData[lineNo].indexOf(CuBt_ConcessionXMLTagConstants.WAR_OPEN) > -1){ 
                response.war = statusRespData[lineNo].substringBetween(CuBt_ConcessionXMLTagConstants.WAR_OPEN,
                                                                       CuBt_ConcessionXMLTagConstants.WAR_CLOSE);
            }
            
            if(statusRespData[lineNo].indexOf(CuBt_ConcessionXMLTagConstants.INST_OPEN) > -1){ 
                response.inst = statusRespData[lineNo].substringBetween(CuBt_ConcessionXMLTagConstants.INST_OPEN,
                                                                        CuBt_ConcessionXMLTagConstants.INST_CLOSE);
            }
            
            if(statusRespData[lineNo].indexOf(CuBt_ConcessionXMLTagConstants.SECONDARYCRN_OPEN) > -1){ 
                response.scndryCrn = statusRespData[lineNo].substringBetween(CuBt_ConcessionXMLTagConstants.SECONDARYCRN_OPEN,
                                                                             CuBt_ConcessionXMLTagConstants.SECONDARYCRN_CLOSE);
            }
            
            if(statusRespData[lineNo].indexOf(CuBt_ConcessionXMLTagConstants.MAXRATE_OPEN) > -1){ 
                response.maxRate = statusRespData[lineNo].substringBetween(CuBt_ConcessionXMLTagConstants.MAXRATE_OPEN,
                                                                           CuBt_ConcessionXMLTagConstants.MAXRATE_CLOSE);
            }
            
            if(statusRespData[lineNo].indexOf(CuBt_ConcessionXMLTagConstants.RATETHOLD_OPEN) > -1){ 
                response.rateThold = statusRespData[lineNo].substringBetween(CuBt_ConcessionXMLTagConstants.RATETHOLD_OPEN,
                                                                             CuBt_ConcessionXMLTagConstants.RATETHOLD_CLOSE);
            }
            
            if(statusRespData[lineNo].indexOf(CuBt_ConcessionXMLTagConstants.RATERATIO_OPEN) > -1){ 
                response.rateRatio = statusRespData[lineNo].substringBetween(CuBt_ConcessionXMLTagConstants.RATERATIO_OPEN,
                                                                             CuBt_ConcessionXMLTagConstants.RATERATIO_CLOSE);
            } 
        }     
        if(response.crn != null && !mapOfStatusResponseNumberToCRN.containsKey(responseID)){
            mapOfStatusResponseNumberToCRN.put(responseID, response.crn);                    
        }
        
        if(response.crn != null){
            if(!mapOfStatusRespIdToListOfStatusRespWrapper.containsKey(response.crn)){
                mapOfStatusRespIdToListOfStatusRespWrapper.put(response.crn,new List<ConcessionImportXMLTagsWrapper>());
            }
            mapOfStatusRespIdToListOfStatusRespWrapper.get(response.crn).add(response);
        }        
    }   
       
    /******************************************************************************
	@author    		Echo: Ankit Gangwani
	@date      		31 Dec 2018
	@param			ConcessionImportXMLTagsWrapper response, Concession__c con
	@return			ConcessionValidation__c	
	*******************************************************************************/
 	private ConcessionValidation__c createConcessionValidation(ConcessionImportXMLTagsWrapper response, Concession__c con){ 
        numberOfConcessionValidationCreated = numberOfConcessionValidationCreated + 1;
        ConcessionValidation__c conValidate = new ConcessionValidation__c();
        conValidate.ConfirmDate__c = con.ConfirmDate__c != null ? con.ConfirmDate__c : null;
        conValidate.PCC__c = response.pcc != null ? response.pcc : null;
        conValidate.HCC__c = response.hcc != null ? response.hcc : null;
        conValidate.SHC__c = response.shc != null ? response.shc : null;
        conValidate.LIC__c = response.lic != null ? response.lic : null;
        conValidate.Deceased__c = response.deceased != null ? (response.deceased == 'True' ? True : False) : false;
        conValidate.PostCode__c = response.pcode != null ? response.pcode : null;
        conValidate.Concession__c = con.Id;
        return conValidate;        
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           31 Dec 2018
    @description    Batch's start method
					Retrieve the XML file data and iterate through it 
					and query the Concessions record using the CRN number from the XML data
   *******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        Boolean performStart = false;
        String sQuery = '';
        List<Id> ContentDocumentIdList = new List<Id>(); 
        
        // ContentDcoumentLink records associated with the Batch Request Queues
        // Get ContentDocument ID associated with ContentDcoumentLink           
        for(ContentDocumentLink objCDL : [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE /*Id IN: cdlList  AND */ LinkedEntityId =: batchRequestQueue.Id]){
            ContentDocumentIdList.add(objCDL.ContentDocumentId);            
        } 
        
        //ContentDocument records of csv extension
        List<ContentDocument> conDocList = [SELECT Id FROM ContentDocument WHERE Id IN: ContentDocumentIdList AND FileType =:GlUt_Constants.FILEEXTENSIONXML];       
        
        // Retrieve the CSV file data from ContentVersion 
        List<ContentVersion> conVersionList = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId IN: conDocList];
        
        // Build the map for incoming picklist values in xml file
        pickListDataMap.put('Y'	,System.Label.GlAp_Yes);
        pickListDataMap.put('N'	,System.Label.GlAp_No);
        pickListDataMap.put('UC',System.Label.CuBt_UnableToConfirm);
        pickListDataMap.put('NP',System.Label.CuBt_NotProvided);
        
        //get the custom metadata for match code values
        for(CentrelinkBATMatchCodes__mdt matchCode : [SELECT MatchCode__c, Description__c FROM CentrelinkBATMatchCodes__mdt]){
            mapOfMatchCodeToDescription.put(matchCode.MatchCode__c, matchCode.Description__c);            
        }
        
        if(conVersionList.size() > 0){                        
            readingXMLData(conVersionList , batchRequestQueue.Id); 
            
            // create batch error record if xml data not correct 
            if(!batchErrorList.isEmpty()){
                Database.insert(batchErrorList);
            }
        }       
       
        List<String> crnLists = new List<String>();
        crnLists.addAll(mapOfStatusRespIdToListOfStatusRespWrapper.keySet());
        
        String crns = '(\'' + String.join(crnLists, '\', \'') + '\')';
        sQuery = 'SELECT Id, '  + 
            GlUt_APIConstantsConcession.CRNAPINAME + ',' +
            GlUt_APIConstantsConcession.CONFIRMDATEAPINAME + 
            ' FROM ' + GlUt_APIConstantsConcession.CONCESSIONAPINAME + 
            ' WHERE ' + GlUt_APIConstantsConcession.CRNAPINAME + ' IN ' +crns;
        return Database.getQueryLocator(sQuery);        
    }
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           31 Dec 2018
    @description    Batch's execute method
					Create the Concession Validation Record link this to BRQ and update the Concessions record.
    *******************************************************************************/
    global void execute(Database.BatchableContext bc, List<Concession__c> concessionLists){ 
        try{
            Boolean recordAdded = false;
            List<ConcessionValidation__c> newConcessionValidationLists = new List<ConcessionValidation__c>();
            if(concessionLists != null && !concessionLists.isEmpty()){
                for(Concession__c con : concessionLists){
                    recordAdded = false;                    
                    for(ConcessionImportXMLTagsWrapper response : mapOfStatusRespIdToListOfStatusRespWrapper.get(con.CRN__c)){
                        if(response.cnfrmDate != null && con.ConfirmDate__c != null && con.ConfirmDate__c == Date.valueOf(response.cnfrmDate)){
                            recordAdded = true;
                            newConcessionValidationLists.add(createConcessionValidation(response, con));
                        }                        
                    }                    
                }
            }            
            if(!newConcessionValidationLists.isEmpty())
                Database.insert(newConcessionValidationLists);
        }
        catch (exception e){
            GlUt_Logger.logException(e);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        } 
    } 
   /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           31 Dec 2018
    @description    Batch's final method
   *******************************************************************************/
    global void finish(Database.BatchableContext bc){
        Savepoint sp = Database.setSavepoint();
        try{
            String fileData = 'Total number of Concession Validation Created: ' + String.valueOf(numberOfConcessionValidationCreated) + '\r\n' + 
                			  'Total number of Errors: ' + String.valueOf(numberOfErrors);
            
            
            EnvironmentSettings__mdt mdtEnviromentSetting = GlUt_CustomMetaDataUtility.getEnviromentSettingDetails(GlUt_Constants.ENVIROMENTSETTINGCONCESSIONIMPORTQUERY);
            String concessionImportLibraryName=mdtEnviromentSetting.ConcessionImport__c;
           /*String concessionImportLibraryName;
            for(EnvironmentSettings__mdt env : [SELECT ConcessionImport__c FROM EnvironmentSettings__mdt LIMIT 1]){
                concessionImportLibraryName = env.ConcessionImport__c;
            }*/
            
            String fileName = System.Label.CuBt_ConcessionImport + '_' + System.today().format() + GlUt_Constants.REPORT_FILE_EXTENSION;  //'.txt';
            Id contentDocumentId = GlUt_ContentDocument.saveLinkedDocument(batchRequestQueue.Id, concessionImportLibraryName, fileName, fileName, LoBt_Constants.SHARE_TYPE, blob.valueOf(fileData));
            
			//Update Batch Request Queue to Completed.
            BatchRequestQueue__c brq = [SELECT Id,Status__c FROM BatchRequestQueue__c WHERE Id=:batchRequestQueue.Id Limit 1];			
            brq.Status__c = GlUt_Constants.BATCH_REQUEST_QUEUE_STATUS_COMPLETED;
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