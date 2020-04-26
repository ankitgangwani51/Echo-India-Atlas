/******************************************************************************
@author         Neha Rajput
@date           15 May 2018
@description    Reading Import Batch Process
Revision(s)		AT-4888, Checkmarks issues.
*******************************************************************************/
global class LoBt_ReadingImport extends GlBt_BatchProcess implements Database.Batchable<sObject>, Database.Stateful  {
    
 	global Id batchRequestQueueId;
    global Integer newReadingRecordsCreated;
    global Integer rejectedReadingUploadRecords;
         
    private static final Integer NUM_OF_FIELD = 16;  // AT-5209
    
    /******************************************************************************
	@author    		Echo: Neha R.
	@date      		21 May 2018
	@param			BatchRequestQueue__c brq	
	@return			Void
	@description 	override method of GlBt_BatchProcess to store BatchRequestQueue Id in batchRequestQueueId variable
	*******************************************************************************/        
    global override void Initialise(BatchRequestQueue__c brq){        
        this.batchRequestQueueId = brq.Id;
    }
    
    /******************************************************************************
	@author    		Echo: Neha R.
	@date      		21 May 2018
	@param			List<ContentDocumentLink> cdlList	
	@return			Void
	@description 	override method of GlBt_BatchProcess to retrieve content VersionList data and insert records
					in BatchError & ReadingUpload Accordingly
	*******************************************************************************/
    global override List<BatchError__c> FileImport(List<ContentDocumentLink> cdlList){          
        
        List<BatchError__c> batchErrorList = new List<BatchError__c>();
        List<Id> ContentDocumentIdList = new List<Id>(); 
        
        // ContentDcoumentLink records associated with the Batch Request Queues
        List<ContentDocumentLink> cdlBRQList = [SELECT Id, ContentDocumentId
                                                FROM ContentDocumentLink
                                                WHERE Id IN: cdlList 
                                                AND LinkedEntityId =: this.batchRequestQueueId];                  
       
        // Get ContentDocument ID associated with ContentDcoumentLink           
        for(ContentDocumentLink objCDL : cdlBRQList){
            ContentDocumentIdList.add(objCDL.ContentDocumentId);            
        } 
        
        //ContentDocument records of csv extension
        List<ContentDocument> conDocList = [SELECT Id
                                            FROM ContentDocument
                                            WHERE Id IN: ContentDocumentIdList 
                                            AND FileType =: GlUt_Constants.FILEEXTENSIONCSV ];       
        
        // Retrieve the CSV file data from ContentVersion 
        List<ContentVersion> conVersionList = [SELECT Id, VersionData          
                                               FROM ContentVersion
                                               WHERE ContentDocumentId IN: conDocList];
        
        if (conVersionList.size() > 0){
            // Iterate file to create Reading Upload ‘staging’ or Batch Error record 
            batchErrorList = readingFileData(conVersionList , this.batchRequestQueueId); 
        }
        return batchErrorList;
    }
    
    /******************************************************************************
	@author    		Echo: Neha R.
	@date      		21 May 2018
	@param			List<ContentVersion> conVersionList	
	@return			Void
	@description 	Methos to iterate file to create Reading Upload ‘staging’ or Batch Error record
	*******************************************************************************/
 	private List<BatchError__c> readingFileData(List<ContentVersion> conVersionList, Id brqID){ 
        
        Blob blobfileData;
        String fileData;        
        List<List<BatchError__c>> listOfbatchErrorList = new List<List<BatchError__c>>();         
        List<List<ReadingUpload__c>> listOfreadingUploadList = new List<List<ReadingUpload__c>>();
            
        For(ContentVersion objCV : conVersionList){ 
            
            // local list to store records file by file
            List<BatchError__c> batchErrorList = new List<BatchError__c>();
        	List<ReadingUpload__c> readingUploadList = new List<ReadingUpload__c>();
            
            // file data to String format            
            blobfileData = objCV.VersionData;
            fileData = blobfileData.toString();         
            
            // Get all file lines
            List<String> totalfileDataLines = fileData.split('\n');
            
            // Retrieve per Line data of a file
            for(Integer lineno=0; lineno<totalfileDataLines.size(); lineno++){ 
                List<String> lineData = totalfileDataLines[lineno].split(',');
                
                BatchError__c objBatchError = validateFileData(lineData, String.valueOf(lineno + 1), brqID);
               
                // If Error occur
                if (objBatchError != null){ 
                    batchErrorList.add(objBatchError); 
                }else{               
                    // add  Reading Upload record in readingUploadList if no error occur 
                    if(batchErrorList.size() == 0 || listOfbatchErrorList.size() == 0){
                        ReadingUpload__c objReadingUpload = new ReadingUpload__c();                        
                        objReadingUpload.DeviceReference__c=lineData[0];
                        if (lineData[1] != '') 
                        	objReadingUpload.ReadingDate__c=Date.valueOf(lineData[1]);
                            
                        objReadingUpload.ReadingValue__c =lineData[2];
                        objReadingUpload.ReadSource__c=lineData[3];
                        objReadingUpload.ReadingMethod__c=lineData[4];
                        objReadingUpload.Reader__c=lineData[5];
                        objReadingUpload.Remarks__c=lineData[6];
                        objReadingUpload.Manufacturer__c=lineData[7];
                        objReadingUpload.SerialNumber__c=lineData[8];
                        objReadingUpload.SkipCodeName__c=lineData[9];
                        
                        if (lineData[10] != null && lineData[10] != '')
                        	objReadingUpload.Billable__c=Boolean.valueOf(lineData[10]);
                            
                        if (lineData[11] != null && lineData[11] != '')   
                        	objReadingUpload.NewWalkOrder__c=Integer.valueOf(lineData[11]);
                            
                        //objReadingUpload.ReadPeriodId__c=lineData[12];
                        String sObjName = '';
                        if(lineData[12] == '' || lineData[12] == null){
                            batchErrorList.add(new BatchError__c(BatchRequestQueue__c = brqId,
                                                                 ErrorDetails__c = LoBt_ErrorConstants.READINGPERIOD_MISSING,
                                                                 BatchRequestOperation__c=GlUt_Constants.BATCHPROCESSOPERATION,
                                                                 BatchRequestType__c = GlUt_Constants.BRTYPEMETERBOOK)); 
                            continue;
                        }else{
                            Id readPeriodId = (Id)lineData[12];
                            sObjName = readPeriodId.getSObjectType().getDescribe().getName();
                            if(sObjName == GlUt_APIConstantsReadPeriod.READPERIODAPINAME)
                                objReadingUpload.ReadPeriod__c = lineData[12];
                            else{
                                batchErrorList.add(new BatchError__c(BatchRequestQueue__c = brqId,
                                                                     ErrorDetails__c = LoBt_ErrorConstants.READINGPERIOD_INVALID ,
                                                                     BatchRequestOperation__c=GlUt_Constants.BATCHPROCESSOPERATION,
                                                                     BatchRequestType__c = GlUt_Constants.BRTYPEMETERBOOK)); 
                                continue;
                            }
                        }
                        
                        //objReadingUpload.ReadTimetableId__c=lineData[13];
                        sObjName = '';
                        if(lineData[13] == '' || lineData[13] == null){
                            batchErrorList.add(new BatchError__c(BatchRequestQueue__c = brqId,
                                                                 ErrorDetails__c = LoBt_ErrorConstants.READTIMETABLE_MISSING,
                                                                 BatchRequestOperation__c=GlUt_Constants.BATCHPROCESSOPERATION,
                                                                 BatchRequestType__c = GlUt_Constants.BRTYPEMETERBOOK)); 
                            continue;
                        }else{
                            Id readTimeTableId = (Id)lineData[13];
                            sObjName = readTimeTableId.getSObjectType().getDescribe().getName();
                            if(sObjName == GlUt_APIConstantsReadTimeTable.READTIMETABLEAPINAME)
                                objReadingUpload.ReadTimetable__c = lineData[13];
                            else{
                                batchErrorList.add(new BatchError__c(BatchRequestQueue__c = brqId,
                                                                     ErrorDetails__c = LoBt_ErrorConstants.READINGTIMETABLE_INVALID,
                                                                     BatchRequestOperation__c=GlUt_Constants.BATCHPROCESSOPERATION,
                                                                     BatchRequestType__c = GlUt_Constants.BRTYPEMETERBOOK)); 
                                continue;
                            }
                        }
                        
                        if(lineData[14] != null && lineData[14] != '')   //AT-5209
                        objReadingUpload.Advice__c = lineData[14];  
                     
                        if (lineData[15] != null && lineData[15] != '')     //AT-5209
                        	objReadingUpload.Tripped__c=Boolean.valueOf(lineData[15]);
                        
                        objReadingUpload.BatchRequestQueue__c = brqID;
                       
                        readingUploadList.add(objReadingUpload);
                    }
                }
            } //End of a file data
            if (batchErrorList.size() > 0) 
                listOfbatchErrorList.add(batchErrorList);
            else 
				listOfreadingUploadList.add(readingUploadList); 
            
        } // End of all file data
        
        // Batch error created...
        if(listOfbatchErrorList.size() > 0){
        	List<BatchError__c> batchErrorList = new List<BatchError__c>();
            for(List<BatchError__c> beList :listOfbatchErrorList){
                for(BatchError__c objBE: beList){
                    batchErrorList.add(objBE);
                }                
            }
            batchErrorList = (List<BatchError__c>) GlUt_FieldSecurity.cleanseFields(batchErrorList, false);
            insert(batchErrorList);  
           
            // update Batch Request Queue Status
            BatchRequestQueue__c objBRQ = [SELECT Id, Status__c
                                           FROM BatchRequestQueue__c
                                           WHERE ID =: brqID];
            objBRQ.Status__c = GlUt_Constants.ERRORS; 	//'Errors';
            objBRQ  = (BatchRequestQueue__c) GlUt_FieldSecurity.cleanseFields(objBRQ, false);
            database.update(objBRQ);             
           
            return batchErrorList;
            
        }else{ // ReadingUpload record created
            List<ReadingUpload__c> ReadingUploadList = new List<ReadingUpload__c>();
            for(List<ReadingUpload__c> ruList : listOfreadingUploadList){
                for(ReadingUpload__c objRU: ruList){
                    ReadingUploadList.add(objRU);
                }                
            }
          
            ReadingUploadList = (List<ReadingUpload__c>) GlUt_FieldSecurity.cleanseFields(ReadingUploadList, false);
            insert(ReadingUploadList);
            
            // update Batch Request Queue Status
            BatchRequestQueue__c objBRQ = [SELECT Id, Status__c
                                           FROM BatchRequestQueue__c
                                           WHERE ID =: brqID];
            objBRQ.Status__c = GlUt_Constants.INITIALISED;  //'Initialised';
            objBRQ  = (BatchRequestQueue__c) GlUt_FieldSecurity.cleanseFields(objBRQ, false);
            database.update(objBRQ);
            
        } 
        return null;
    }
    
   /******************************************************************************
	@author    		Echo: Neha R.
	@date      		21 May 2018
	@param			List<ContentDocumentLink> cdlList	
	@return			Void
	@description 	method to validate imported fields 
	*******************************************************************************/
    private BatchError__c validateFileData(List<String> lineData, String lineno, Id brqID){ 
        
        Date readingDate;       
        Integer newWalkOrder;  
        
        // number of fields in a Line
        if(lineData.size() != NUM_OF_FIELD)
        {
            return(new BatchError__c(BatchRequestQueue__c = brqID,ErrorDetails__c = LoBt_ErrorConstants.NUMOFFIELD + lineno,BatchRequestOperation__c= GlUt_Constants.BATCHPROCESSOPERATION,BatchRequestType__c = GlUt_Constants.BRTYPEMETERBOOK));                      
        } 
        
        //Data Type validations...
        try{
            // Reading date 
            if(lineData[1] != null && lineData[1] != '' ){
            	readingDate = Date.valueOf(lineData[1]);
            }
        }catch(Exception e){                
            return(new BatchError__c(BatchRequestQueue__c = brqId,ErrorDetails__c = LoBt_ErrorConstants.READINGDATE_INVALID + lineno,BatchRequestOperation__c=GlUt_Constants.BATCHPROCESSOPERATION,BatchRequestType__c = GlUt_Constants.BRTYPEMETERBOOK));                               
        } 
      
        try{
            // New Walk Order (Integer)
            if (lineData[11] != null && lineData[11] != '')                
            	newWalkOrder = Integer.valueOf(lineData[11]);				            
        }catch(Exception e){                
            return(new BatchError__c(BatchRequestQueue__c = brqId,ErrorDetails__c = LoBt_ErrorConstants.WALKORDER_INVALID + lineno,BatchRequestOperation__c=GlUt_Constants.BATCHPROCESSOPERATION,BatchRequestType__c = GlUt_Constants.BRTYPEMETERBOOK));                               
        }    
        
        try{
            // Billable Field (Boolean)
            if(lineData[10] != '' && lineData[10].toLowerCase() != 'true' && lineData[10].toLowerCase() != 'false'){
                TypeException e = new TypeException();    				
            	throw e; 
            }
        }catch(Exception e){                
            return(new BatchError__c(BatchRequestQueue__c = brqId,ErrorDetails__c = LoBt_ErrorConstants.BILLABLE_INVALID + lineno,BatchRequestOperation__c=GlUt_Constants.BATCHPROCESSOPERATION,BatchRequestType__c = GlUt_Constants.BRTYPEMETERBOOK));                               
        } 
            
        //AT-5209
        //Advice        
        try{
            if(lineData[14] != ''){ 
                // Get all Value of ReadingSource picklist values of Reading field
                List<String> adviceMultiPicklistList = new List<String>();
                Schema.DescribeFieldResult readingUploadAdviceField = ReadingUpload__c.Advice__c.getDescribe();
                for(Schema.PicklistEntry objPickList: readingUploadAdviceField.getPicklistValues()){
                    adviceMultiPicklistList.add(objPickList.getValue());
                }                
                List<String> adviceList = lineData[14].split(';');                
                for(String adviceValue : adviceList){                    
                    if(!adviceMultiPicklistList.contains(adviceValue)){
                        TypeException e = new TypeException();    				
                        throw e; 
                    }
                }
            }
        }catch(Exception e){                
            return(new BatchError__c(BatchRequestQueue__c = brqId,ErrorDetails__c = LoBt_ErrorConstants.ADVICE_INVALID + lineno,BatchRequestOperation__c=GlUt_Constants.BATCHPROCESSOPERATION,BatchRequestType__c = GlUt_Constants.BRTYPEMETERBOOK));                               
        }     

		// tripped
        try{            
            if(!lineData[15].isAlphanumeric()){                
                String lastchar = lineData[15].substring( lineData[15].length() - 1 );                
                if(!lastchar.isAlphanumeric()){
                    // remove Last character
                    lineData[15] = lineData[15].substring(0, lineData[15].length() - 1);
                }
            }
                        
            // Tripped (Boolean)
            if(lineData[15] != '' && lineData[15].toLowerCase() != 'true' && lineData[15].toLowerCase() != 'false'){               
                TypeException e = new TypeException();    				
            	throw e; 
            }
        }catch(Exception e){                
            return(new BatchError__c(BatchRequestQueue__c = brqId,ErrorDetails__c = LoBt_ErrorConstants.TRIPPED_INVALID + lineno,BatchRequestOperation__c=GlUt_Constants.BATCHPROCESSOPERATION,BatchRequestType__c = GlUt_Constants.BRTYPEMETERBOOK));                               
        } 
    	return null;
    }
    
    /******************************************************************************
	@author    		Echo: Neha R.
	@date      		21 May 2018
	@param			Database.BatchableContext bc	
	@return			Database.QueryLocator
	@description 	method to start batch process
	*******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {  
        //AT-3204 Starts Here
        LoBt_ExportRequestedReadingsHelper.changeBRQStatus(this.batchRequestQueueId,LoBt_Constants.BRQPROCESSINGSTATUS);
        //AT-3204 Ends Here
		String sQuery = 'SELECT Id, '  + 
            			GlUt_APIConstantsReadingUpload.MANUFACTURERAPINAME + ',' +
                        GlUt_APIConstantsReadingUpload.SERIALNOAPINAME + ',' +
                        GlUt_APIConstantsReadingUpload.DEVICEREFERENCEAPINAME + ',' +
                        GlUt_APIConstantsReadingUpload.READINGDATEAPINAME + ',' +
                        GlUt_APIConstantsReadingUpload.READINGVALUEAPINAME + ',' + 			//AT-2443
                        GlUt_APIConstantsReadingUpload.READINGMETHODAPINAME + ',' +
                        GlUt_APIConstantsReadingUpload.READSOURCEAPINAME + ',' +
                        GlUt_APIConstantsReadingUpload.READINGTYPEAPINAME + ',' +
                        GlUt_APIConstantsReadingUpload.BILLABLEAPINAME + ',' +                        
                        GlUt_APIConstantsReadingUpload.TRIPPEDAPINAME + ',' +
                        GlUt_APIConstantsReadingUpload.SKIPCODENAMEAPINAME + ',' +
                        GlUt_APIConstantsReadingUpload.REMARKAPINAME + ',' +
                        GlUt_APIConstantsReadingUpload.READINGSTATUSAPINAME + ',' +
                        GlUt_APIConstantsReadingUpload.NEWWALKORDERAPINAME + ',' +
                        GlUt_APIConstantsReadingUpload.READERAPINAME + ',' +
                        GlUt_APIConstantsBatchRequestQueue.BATCHREQQUEUEAPINAME + ',' + 
                        GlUt_APIConstantsBatchError.BATCHERRORAPINAME + ',' +
                        GlUt_APIConstantsReadingUpload.AVERAGEDAILYUSAGEAPINAME + ',' + 
           				GlUt_APIConstantsReadingUpload.READTTTHRESHOLDAPINAME + ',' +
                        GlUt_APIConstantsReadingUpload.READTIMETABLEAPINAME + ',' +
            			GlUt_APIConstantsReadingUpload.READPERIODIDAPINAME + ',' +
            			GlUt_APIConstantsReadingUpload.READPERIODLOOKUPAPINAME + ',' +  // CLB-18, Ankit, 03/04/2019
            			GlUt_APIConstantsReadingUpload.READTIMETABLELOOKUPAPINAME + ',' + // CLB-18, Ankit, 03/04/2019
						GlUt_APIConstantsReadingUpload.ADVICEAPINAME  +     //AT-5209                    
                        ' FROM ' + GlUt_APIConstantsReadingUpload.READINGUPLOADEAPINAME + 
            			' WHERE ' + GlUt_APIConstantsBatchRequestQueue.BATCHREQQUEUEAPINAME + ' =  \'' + this.batchRequestQueueId + '\''; 
        return Database.getQueryLocator(sQuery);
    }
    
    /******************************************************************************
	@author    		Echo: Neha R.
	@date      		21 May 2018
	@param			Database.BatchableContext bc	
	@return			Database.QueryLocator
	@description 	method to start batch process
	*******************************************************************************/    
    global void execute(Database.BatchableContext bc, List<ReadingUpload__c> readingUploadRecords){

        Set<String> ruSkipCodeNameSet = new Set<String>();
        Map<Id,String> readingUploadErroredMap = new Map<Id,String>();
        Map<Id,String> ruManufacturerSNoMap = new Map<Id,String>();
        Map<Id,String> ruManufacturerMap = new Map<Id,String>();
        Map<Id,String> ruSerialNoMap = new Map<Id,String>();
        Map<Id,Date> ruReadingDateMap = new Map<Id,Date>();
        Map<Id,String> ruReadingMap = new Map<Id,String>();
        Map<Id,String> ruSkipCodeNameMap = new Map<Id,String>();
        Map<Id,Boolean> ruTrippedMap = new Map<Id,Boolean>();
        Map<Id,String> deviceSNoManufacturerMap = new Map<Id,String>();
        Map<Id,Id> deviceReadingUploadMap = new Map<Id,Id>();
        Map<Id,Id> readingUploadDeviceMap = new Map<Id,Id>();
        Map<Id,String> spdDeviceSNOManufactureMap = new Map<Id,String>();
        Map<Id,Id> deviceSPDMap = new Map<Id,Id>();
        Map<Id,Id> deviceSupplyPointMap = new Map<Id,Id>();
        Map<Id,Id> spdReadTimetableMap = new Map<Id,Id>();         
        Map<Id,Id> readingUploadBookMap = new Map<Id,Id>();
        Map<Id,Id> readingUploadDepotMap = new Map<Id,Id>();
        Map<Id,Id> readingUploadAreaMap = new Map<Id,Id>();
        Map<Id,reading__c> deviceLatestReadingMap = new  Map<Id,reading__c>();
        Map<Id,Decimal> deviceActualConsumptionMap = new Map<Id,decimal>();
        Map<Id,Date> spdActiveReadingDateMap = new Map<Id,Date>();
        Map<Id,AverageDailyUsage__c> spdActiveADU = new Map<Id,AverageDailyUsage__c>(); 
        Map<Id,ReadTimetableThresholds__c> spdActiveReadTTThreshold = new Map<Id,ReadTimetableThresholds__c>();
        Map<Id,Decimal> deviceEstimatedconsumptionMap = new Map<Id,decimal>();
        Map<Id,Decimal> deviceEstimateReadingMap = new Map<Id,decimal>();
        Map<Id,SkipCode__c> readinguploadSkipCodeMap = new Map<Id,SkipCode__c>();
        Map<Id,Id> readingUploadIDAduMAP = new Map<Id,Id>();
        Map<Id,Id> ruReadTTThresholdsMAP = new Map<Id,Id>();
        Map<Id,Id> ruReadingModeMap = new Map<Id,Id>();  
        
        // CLB-18, Ankit, 03/04/2019
        Set<Id> setOfReadPeriodIds = new Set<Id>(); 						
        Map<Id,Id> mapOfReadPeriodIdToReadTimeTableId = new Map<Id,Id>(); 				
        Map<Id,List<ReadingMode__c>> mapOfReadingModeIdToRecord = new Map<Id,List<ReadingMode__c>>(); 
        
        
        // Get all Value of ReadingSource picklist values of Reading field
        List<String> readingSourceList = new List<String>();
        Schema.DescribeFieldResult readingSouceField = Reading__c.ReadingSource__c.getDescribe();
        for(Schema.PicklistEntry objPickList: readingSouceField.getPicklistValues()){
            readingSourceList.add(objPickList.getValue());
        } 
        
        // Get all Value of ReadingMethod picklist values of Reading field
        List<String> readingMethodList = new List<String>();
        Schema.DescribeFieldResult readingMethodField = Reading__c.ReadingMethod__c.getDescribe();
        for(Schema.PicklistEntry objPickList: readingMethodField.getPicklistValues()){
            readingMethodList.add(objPickList.getValue());
        } 
        
        // Get all Value of Manufacturer picklist values of Device Type
        List<String> manufacturerList = new List<String>();
        Schema.DescribeFieldResult manufacturerField = DeviceType__c.Manufacturer__c.getDescribe();
        for(Schema.PicklistEntry objPickList: manufacturerField.getPicklistValues()){
            manufacturerList.add(objPickList.getValue());
        } 
        
        newReadingRecordsCreated = 0;
        rejectedReadingUploadRecords = 0;               
        
        // CLB-18, Ankit, 03/04/2019
        for(ReadingUpload__c objReadingUpload : readingUploadRecords){
            if(objReadingUpload.ReadPeriod__c != null)
                setOfReadPeriodIds.add(objReadingUpload.ReadPeriod__c); 
        }
        
        if(setOfReadPeriodIds.size() > 0){
            for(ReadPeriod__c objReadPeriod : [SELECT Id, ReadTimeTable__c FROM ReadPeriod__c WHERE Id IN: setOfReadPeriodIds]){
                if(!mapOfReadPeriodIdToReadTimeTableId.containsKey(objReadPeriod.Id))
                    mapOfReadPeriodIdToReadTimeTableId.put(objReadPeriod.Id,objReadPeriod.ReadTimetable__c);
            }
            
            for(ReadingMode__c objReadingMode : [SELECT Id, Book__c, Depot__c, Area__c, ReadPeriod__c FROM ReadingMode__c WHERE ReadPeriod__c IN: setOfReadPeriodIds]){
                if(!mapOfReadingModeIdToRecord.containsKey(objReadingMode.ReadPeriod__c)){
                    mapOfReadingModeIdToRecord.put(objReadingMode.ReadPeriod__c, new list<ReadingMode__c> {objReadingMode}) ;
                }else{
                    mapOfReadingModeIdToRecord.get(objReadingMode.ReadPeriod__c).add(objReadingMode) ;
                }    
            }
        }
        
        for(ReadingUpload__c objReadingUpload : readingUploadRecords){
            
            // Basic Validation.....
            // Error...Reading Date
            if(objReadingUpload.ReadingDate__c == null){
                if (!readingUploadErroredMap.containsKey(objReadingUpload.Id))
                	readingUploadErroredMap.put(objReadingUpload.Id, LoBt_ErrorConstants.READING_DATE_MISSING);
                continue;                
            }
            
            // Error...Reading
            if(objReadingUpload.ReadingValue__c  == null || objReadingUpload.ReadingValue__c  == ''){
                
                if(objReadingUpload.SkipCodeName__c != null){
                    ruSkipCodeNameMap.put(objReadingUpload.Id, objReadingUpload.SkipCodeName__c);
                    ruSkipCodeNameSet.add(objReadingUpload.SkipCodeName__c);
                } 
                else{
                    if(!readingUploadErroredMap.containsKey(objReadingUpload.Id))
                        readingUploadErroredMap.put(objReadingUpload.Id,LoBt_ErrorConstants.SKIPCODEORREADINGMISSING);
                    continue;
                }               
            }
            
            // Error...Read Source
            if(objReadingUpload.ReadSource__c == null || objReadingUpload.ReadSource__c == ''){
                if (!readingUploadErroredMap.containsKey(objReadingUpload.Id))
                	readingUploadErroredMap.put(objReadingUpload.Id, LoBt_ErrorConstants.READSOURCE_MISSING);
                continue;                
            }
            
            // Error...Reading Method
            if(objReadingUpload.ReadingMethod__c == null || objReadingUpload.ReadingMethod__c == ''){
                if (!readingUploadErroredMap.containsKey(objReadingUpload.Id))
                	readingUploadErroredMap.put(objReadingUpload.Id, LoBt_ErrorConstants.READINGMETHOD_MISSING);
                continue;                
            }
           		
            // ERROR...Invalid Manufacturer
            if(objReadingUpload.Manufacturer__c == null || objReadingUpload.Manufacturer__c == '' ||
              (objReadingUpload.Manufacturer__c != null && (!manufacturerList.contains(objReadingUpload.Manufacturer__c)))){                
                if (!readingUploadErroredMap.containsKey(objReadingUpload.Id))
                	readingUploadErroredMap.put(objReadingUpload.Id, LoBt_ErrorConstants.MANUFACTURER_INVALID);
                continue;
            }
          
            // ERROR...Invalid Serial Number
            if(objReadingUpload.SerialNumber__c == null || objReadingUpload.SerialNumber__c == '' ){                
                if (!readingUploadErroredMap.containsKey(objReadingUpload.Id))
                	readingUploadErroredMap.put(objReadingUpload.Id, LoBt_ErrorConstants.SERIALNO_INVALID);
                continue;
            }
            
            // Error...Billable
            if(objReadingUpload.Billable__c == null){
                if (!readingUploadErroredMap.containsKey(objReadingUpload.Id))
                	readingUploadErroredMap.put(objReadingUpload.Id, LoBt_ErrorConstants.BILLABLE_MISSING);
                continue;                
            }
            
            // ERROR...Invalid Reading Source
            if(objReadingUpload.ReadSource__c != null && objReadingUpload.ReadSource__c != '' && (!readingSourceList.contains(objReadingUpload.ReadSource__c)) ){               
                if (!readingUploadErroredMap.containsKey(objReadingUpload.Id))
                	readingUploadErroredMap.put(objReadingUpload.Id, LoBt_ErrorConstants.READINGSOURCE_INVALID);
                continue;
            }
            
            // ERROR...Invalid Reading Method
            if(objReadingUpload.ReadingMethod__c != null && objReadingUpload.ReadingMethod__c != '' && (!readingMethodList.contains(objReadingUpload.ReadingMethod__c)) ){
                // Invalid Setup
                if (!readingUploadErroredMap.containsKey(objReadingUpload.Id))
                	readingUploadErroredMap.put(objReadingUpload.Id, LoBt_ErrorConstants.READINGMETHOD_INVALID);
                continue;
            }
            
            // CLB-18, Ankit, 03/04/2019
            if(mapOfReadPeriodIdToReadTimeTableId.containsKey(objReadingUpload.ReadPeriod__c)){
                if(objReadingUpload.ReadTimetable__c != mapOfReadPeriodIdToReadTimeTableId.get(objReadingUpload.ReadPeriod__c)){
                    if(!readingUploadErroredMap.containsKey(objReadingUpload.Id))
                        readingUploadErroredMap.put(objReadingUpload.Id, LoBt_ErrorConstants.READTIMETABLENOTMATCHED);
                    continue;
                }
            }
            
            //Error...Tripped 
            if(objReadingUpload.Tripped__c == null ){
                // Invalid Setup
                if (!readingUploadErroredMap.containsKey(objReadingUpload.Id))
                	readingUploadErroredMap.put(objReadingUpload.Id, LoBt_ErrorConstants.TRIPPED_MISSING);
                continue;
            }
            
            // end of basic validations...
             
            // Reading Upload with device manufacturer and serial no Map
            ruManufacturerSNoMap.put(objReadingUpload.Id, objReadingUpload.Manufacturer__c + objReadingUpload.SerialNumber__c);
            
            // Reading Upload with Manufacturer Map 
            ruManufacturerMap.put(objReadingUpload.Id, objReadingUpload.Manufacturer__c);
            
            // Reading Upload with Serial No Map 
            ruSerialNoMap.put(objReadingUpload.Id, objReadingUpload.SerialNumber__c);       
                 
            // Reading Upload with ReadingDate Map
            ruReadingDateMap.put(objReadingUpload.Id, objReadingUpload.ReadingDate__c);
            
            // Reading Upload with New Reading Map
            if(objReadingUpload.ReadingValue__c != null && objReadingUpload.ReadingValue__c  != '')
                ruReadingMap.put(objReadingUpload.Id, objReadingUpload.ReadingValue__c );
            
            // Reading Upload and Tripped Map
            ruTrippedMap.put(objReadingUpload.Id, objReadingUpload.Tripped__c); 
            
            if(objReadingUpload.SkipCodeName__c != null){
                ruSkipCodeNameMap.put(objReadingUpload.Id, objReadingUpload.SkipCodeName__c);
                ruSkipCodeNameSet.add(objReadingUpload.SkipCodeName__c);
            } 
            
        }
        
        //ReadingUpload Manufacturer and Serial Number to retrieve the associated Device
        for(Device__c objDevice : [SELECT Id,SerialNumberandManufacturer__c,
                                   (SELECT Id,ActualDeviceReading__c,ReadingDate__c,ReadingType__c,ReadingMethod__c,Reading__c FROM Readings__r WHERE BillableType__c =: GlUt_Constants.BILLABLE ORDER BY ReadingDate__c DESC),//AT-3174
                                   (SELECT Id,SupplyPoint__c,SupplyPoint__r.Depot__c,SupplyPoint__r.Depot__r.Area__c,SupplyPoint__r.Book__c,SupplyPoint__r.Book__r.ReadTimetable__c FROM SupplyPointDevices__r WHERE Active__c =: TRUE LIMIT 1)                                    
                                   FROM Device__c 
                                   WHERE SerialNumberandManufacturer__c IN: ruManufacturerSNoMap.values()]) {
                     
            deviceSNoManufacturerMap.put(objDevice.Id, objDevice.SerialNumberandManufacturer__c);
                                      
            // Map deviceId with ReadingUploadId
            for(Id readingUploadID : ruManufacturerSNoMap.keySet()){        
                if (objDevice.SerialNumberandManufacturer__c == ruManufacturerSNoMap.get(readingUploadID)){
                    deviceReadingUploadMap.put(objDevice.Id, readingUploadID);
                    readingUploadDeviceMap.put(readingUploadID,objDevice.Id);
                }
            }                         
        
            // ERROR...no active Supply point available
            if(objDevice.SupplyPointDevices__r.size() == 0){
                if (!readingUploadErroredMap.containsKey(deviceReadingUploadMap.get(objDevice.Id)))
                	readingUploadErroredMap.put(deviceReadingUploadMap.get(objDevice.Id), LoBt_ErrorConstants.NOACTIVESUPPLYPOINT );  
                continue;
            } 
                                       
            // Retrieve SupplyPointDevice Details                             
            for(SupplyPointDevice__c objSPD : objDevice.SupplyPointDevices__r){
                
                spdDeviceSNOManufactureMap.put(objSPD.Id, objDevice.SerialNumberandManufacturer__c);
                deviceSPDMap.put(objDevice.Id, objSPD.Id);
                
                // ERROR...Active Supply Point associated with Device
                if(objSPD.SupplyPoint__c == null){
                    if (!readingUploadErroredMap.containsKey(deviceReadingUploadMap.get(objDevice.Id)))
                    	readingUploadErroredMap.put(deviceReadingUploadMap.get(objDevice.Id), LoBt_ErrorConstants.NOACTIVESUPPLYPOINT);
                   // errorDeviceSet.add(objDevice.Id);
                    continue;
                }
                else
                    deviceSupplyPointMap.put(objDevice.id, objSPD.SupplyPoint__c);
                
                // If Supply Point associated with a Book
            	if(objSPD.supplyPoint__r.Book__r != null){
                	spdReadTimetableMap.put(objSPD.Id, objSPD.SupplyPoint__r.Book__r.ReadTimetable__c);
                    readingUploadBookMap.put(deviceReadingUploadMap.get(objDevice.Id), objSPD.supplyPoint__r.Book__c);
            	} 
              
                // If Depot associated with Supply Point associated
                if(objSPD.SupplyPoint__r.Depot__c != null){
                    readingUploadDepotMap.put(deviceReadingUploadMap.get(objDevice.Id), objSPD.supplyPoint__r.Depot__c);
                    
                    if(objSPD.SupplyPoint__r.Depot__r.Area__c != null)
                        readingUploadAreaMap.put(deviceReadingUploadMap.get(objDevice.Id), objSPD.supplyPoint__r.Depot__r.Area__c);                        
               }               
            }                                      
            
            Boolean zeroConsTest = false;
            // Reading Details 
            for(Reading__c objReading : objDevice.Readings__r){//AT-3174
                // Device Latest Billable Reading Less than New Reading Date
                if(objReading.ReadingDate__c < ruReadingDateMap.get(deviceReadingUploadMap.get(objDevice.Id))){
                    deviceLatestReadingMap.put(objDevice.Id, objReading); 
                    // Error...New reading is less than the Previous Reading and the Reading is not flagged as ‘Tripped’. create Error  
                    if(ruReadingMap.containsKey(deviceReadingUploadMap.get(objDevice.Id))){
                        if(Decimal.valueOf(ruReadingMap.get(deviceReadingUploadMap.get(objDevice.Id))) < objReading.Reading__c && 
                           ruTrippedMap.get(deviceReadingUploadMap.get(objDevice.Id)) == false){
                               if (!readingUploadErroredMap.containsKey(deviceReadingUploadMap.get(objDevice.Id)))
                                   readingUploadErroredMap.put(deviceReadingUploadMap.get(objDevice.Id), LoBt_ErrorConstants.READINGLESS);
                               //errorDeviceSet.add(objDevice.Id);
                               break;
                           }
                        
                        //CLB-19 Start... Zero Consumption                       
                        if(GlUt_RegionUtility.getAURegionCustomSetting() && !zeroConsTest){
                            // add last reading into zeroConsReadTestLst
                            zeroConsTest = true;                            
                            if((Decimal.valueOf(ruReadingMap.get(deviceReadingUploadMap.get(objDevice.Id))) <= Decimal.valueOf(objReading.ActualDeviceReading__c)) &&
                                !ruTrippedMap.get(deviceReadingUploadMap.get(objDevice.Id))  ) {
                                readingUploadErroredMap.put(deviceReadingUploadMap.get(objDevice.Id), LoBt_ErrorConstants.ZERO_CONSUMPTION);
                                break;
                            }
                        }
                        //CLB-19 End... Zero Consumption
                        deviceActualConsumptionMap.put(objDevice.Id, Decimal.valueOf(ruReadingMap.get(deviceReadingUploadMap.get(objDevice.Id))) );  //AT-4105
                        break; 
                    }
			    }
            }  
        }
        
        // Records where Manufacturer & serial no not valid
        for(Id objReadingUploadId: ruManufacturerSNoMap.keySet()){            
            // Device found by manufacturer + serial no
            if(readingUploadDeviceMap.containsKey(objReadingUploadId)){
                ruManufacturerMap.remove(objReadingUploadId);
                ruSerialNoMap.remove(objReadingUploadId);
            }            
        }   
        
        for(Device__c objDevice : [SELECT Id, SerialNo__c, DeviceType__r.Manufacturer__c
                                   FROM Device__c 
                                   WHERE SerialNo__c IN: ruSerialNoMap.values()]) {                                       
        	for(Id objReadingUploadId: ruSerialNoMap.keySet()){
                // If SerialNo exist...
                if(ruSerialNoMap.get(objReadingUploadId) == objDevice.SerialNo__c) 
                    ruSerialNoMap.remove(objReadingUploadId);
            }                          
        }
        
        for(Id objReadingUploadId: ruManufacturerMap.keySet()){
            // Meter manufacturer no valid
            if(!ruSerialNoMap.containsKey(objReadingUploadId)){
                if (!readingUploadErroredMap.containsKey(objReadingUploadId))
                    readingUploadErroredMap.put(objReadingUploadId, LoBt_ErrorConstants.MANUFACTURER_INVALID);
            }else{ // serial no not valid
              	if (!readingUploadErroredMap.containsKey(objReadingUploadId))
                    readingUploadErroredMap.put(objReadingUploadId, LoBt_ErrorConstants.SERIALNO_INVALID);               
            }                
        }
        
        // Map SPD with NEW reading date 
        for(Id spdID: spdDeviceSNOManufactureMap.keySet()){            
            for(Id readingUploadID: ruManufacturerSNoMap.keySet()){                 
                // serial manufacturer same...
                if(ruManufacturerSNoMap.get(readingUploadID) == spdDeviceSNOManufactureMap.get(spdID)){
                    spdActiveReadingDateMap.put(spdID, ruReadingDateMap.get(readingUploadID));
                }
            }
        }
        
        //Retrieve ADU as of new Reading Date 
        for(AverageDailyUsage__c objADU: [SELECT Id, StartDate__c, EndDate__c, SupplyPointDevice__c,AverageDailyUsage__c 
                                          FROM AverageDailyUsage__c 
                                          WHERE SupplyPointDevice__c IN: spdDeviceSNOManufactureMap.keySet()]){                
            if(spdActiveReadingDateMap.containsKey(objADU.SupplyPointDevice__c) && 
               objADU.StartDate__c <= spdActiveReadingDateMap.get(objADU.SupplyPointDevice__c) &&
               (objADU.EndDate__c == null || objADU.EndDate__c >= spdActiveReadingDateMap.get(objADU.SupplyPointDevice__c))){   //AT-4105
               spdActiveADU.put(objADU.SupplyPointDevice__c, objADU);
               
               // Map of readingupload Id with ADU
               for(Id readingUploadID: ruManufacturerSNoMap.keySet()){
                   if(ruManufacturerSNoMap.get(readingUploadID) == spdDeviceSNOManufactureMap.get(objADU.SupplyPointDevice__c)){
                   		readingUploadIDAduMAP.put(readingUploadID, objADU.Id);
                    }
               }   
            }            
        } 
        
        // Read Timetable Threshold appropriate for the ADU retrieved        
        for(ReadTimetableThresholds__c objReadTimetableThresholds : [SELECT ReadTimetable__c, DailyUsageThresholdStart__c, DailyUsageThresholdEnd__c,ThresholdMonths__c,  //AT-5017
                                                                     AcceptablePercentageVarianceBelow__c, AcceptablePercentageVarianceAbove__c
                                                                     FROM ReadTimetableThresholds__c
                                                                     WHERE ReadTimetable__c IN: spdReadTimetableMap.values()]){
        	 for(Id spdId : spdActiveADU.keySet()){
                AverageDailyUsage__c objADU = spdActiveADU.get(spdId);             
                 //AT-5017  start...
                 Integer newReadingMonth = 0;
                 Map<Integer,String> monthsMap = new Map<Integer, String>{1 => 'January' , 2 => 'February' ,3 => 'March' ,4 => 'April' , 5 => 'May' ,
                     													  6 => 'June' , 7=> 'July' , 8 => 'August' , 9 => 'September' ,
                     													  10 => 'October' , 11=> 'November' ,12 => 'December'}; 
                 List<String> thresholdMonths = new List<String>();
                 if(GlUt_RegionUtility.getAURegionCustomSetting()){
                     for(Id deviceId : deviceSPDMap.keySet()){
                         if(spdId == deviceSPDMap.get(deviceId)){
                             date readingdate = ruReadingDateMap.get(deviceReadingUploadMap.get(deviceId));
                             newReadingMonth = readingdate.month();
                         }
                     }                    
                     if(objReadTimetableThresholds.ThresholdMonths__c != null)
                     	thresholdMonths = objReadTimetableThresholds.ThresholdMonths__c.split(';');
                 } 
                 //AT-5017  end...
                if(spdReadTimetableMap.get(spdId) == objReadTimetableThresholds.ReadTimetable__c &&  // house hold check is missing...
                       spdActiveADU.containsKey(spdId) && 
                       objReadTimetableThresholds.DailyUsageThresholdStart__c <= spdActiveADU.get(spdId).AverageDailyUsage__c &&
                       objReadTimetableThresholds.DailyUsageThresholdEnd__c >= spdActiveADU.get(spdId).AverageDailyUsage__c ){
                           
                    if(!GlUt_RegionUtility.getAURegionCustomSetting() ||
                       (GlUt_RegionUtility.getAURegionCustomSetting() && thresholdMonths.contains(monthsMap.get(newReadingMonth)))){   // AT-5017
                	spdActiveReadTTThreshold.put(spdId, objReadTimetableThresholds) ;
                    // Map of readingupload Id with ReadTimetableThresholds
                    for(Id readingUploadID: ruManufacturerSNoMap.keySet()){                                 
                    	if(ruManufacturerSNoMap.get(readingUploadID) == spdDeviceSNOManufactureMap.get(spdId)){
                        	ruReadTTThresholdsMAP.put(readingUploadID, objReadTimetableThresholds.Id);
                        }
                    } 
                }
            }             
        }      
        }      
        // Calculate Threshold Value only if previous reading found
        for(Id deviceID : deviceLatestReadingMap.keySet()){          
            for(Id readingUploadID: ruReadingDateMap.keySet()){               
                
                // active perform on same device
                if(ruManufacturerSNoMap.get(readingUploadID) == deviceSNoManufacturerMap.get(deviceID)){                    
                    Decimal latestBillableReading = deviceLatestReadingMap.get(deviceID).Reading__c;
                    Date latestBillableReadingDate = deviceLatestReadingMap.get(deviceID).ReadingDate__c;
                    Date calculationDate = ruReadingDateMap.get(readingUploadID);
                    Integer daysDiff = latestBillableReadingDate.daysBetween(calculationDate);
                                        
                    //ADU Available
                    if(spdActiveADU.containsKey(deviceSPDMap.get(deviceID))){
                        // Estimated Calculation = Average Daily Usage * (Days Between Last Reading Date and Calculation Date)
                        Decimal estimateConsumption = spdActiveADU.get(deviceSPDMap.get(deviceID)).AverageDailyUsage__c * daysDiff ;
                        deviceEstimatedconsumptionMap.put(deviceID, estimateConsumption);
                                               
                        //ReadTimeTableThreshold exist appropriate for the ADU
                        if(spdActiveReadTTThreshold.containsKey(deviceSPDMap.get(deviceID))){
                            //Latest Billable Reading + (Estimated Consumption / 100 * Lower Threshold Percentage)
                            Decimal lowerThresholdValue = latestBillableReading + estimateConsumption/100 * spdActiveReadTTThreshold.get(deviceSPDMap.get(deviceID)).AcceptablePercentageVarianceBelow__c;
                            
                            //Upper Threshold Value = Latest Billable Reading + (Estimated Consumption / 100 * Upper Threshold Percentage)
                            Decimal upperThresholdValue = latestBillableReading + estimateConsumption/100 * spdActiveReadTTThreshold.get(deviceSPDMap.get(deviceID)).AcceptablePercentageVarianceAbove__c;
                          
                            // Error...actual consumption is lower than the Lower Threshold Value, or greater than the Upper Threshold Value
                            if(deviceActualConsumptionMap.get(deviceID) < lowerThresholdValue || deviceActualConsumptionMap.get(deviceID) > upperThresholdValue){
                                if (!readingUploadErroredMap.containsKey(readingUploadID))
                                    readingUploadErroredMap.put(readingUploadID, LoBt_ErrorConstants.THRESHOLD_OUTSIDE);
                               // errorDeviceSet.add(deviceID);
                            }
                        } else {
                            if (!readingUploadErroredMap.containsKey(readingUploadID))
                                readingUploadErroredMap.put(readingUploadID, System.Label.LoAp_ReadTimetableThresholdInvalid); 
                        }
                    } else {
                        if (!readingUploadErroredMap.containsKey(readingUploadID))
                            readingUploadErroredMap.put(readingUploadID, System.Label.LoAp_ADUNotFound);
                    } 
                }                
            } 
        }      
      
        // validate Skip Code        
        for(SkipCode__c objSkipCode: [SELECT Name,CreateEstimate__c,CreateError__c 
                                      FROM SkipCode__c 
                                      WHERE Name IN: ruSkipCodeNameSet]){
                                       
        	for(Id readingUploadId: ruSkipCodeNameMap.keySet()){               
                if(ruSkipCodeNameMap.get(readingUploadId) == objSkipCode.Name){
                    Id deviceIdValue;
                    for(Id deviceID: deviceSNoManufacturerMap.keySet()){
                        if(deviceSNoManufacturerMap.get(deviceID) == ruManufacturerSNoMap.get(readingUploadId)) {
                            deviceIdValue = deviceID;
                            break;
                        }
                    }
                    
                    if(deviceIdValue != null){
                        //Reading is an Error
                        if(objSkipCode.CreateError__c){
                            if(!readingUploadErroredMap.containsKey(readingUploadID))
                                readingUploadErroredMap.put(readingUploadID, LoBt_ErrorConstants.SKIP_CODE_ERROR);
                          //  errorDeviceSet.add(deviceIdValue);                         
                        }else if(objSkipCode.CreateEstimate__c){
                            if(deviceEstimatedconsumptionMap.containsKey(deviceIdValue)){
                                if(deviceLatestReadingMap.containsKey(deviceIdValue))
                                    deviceEstimateReadingMap.put(deviceIdValue, deviceLatestReadingMap.get(deviceIdValue).Reading__c + deviceEstimatedconsumptionMap.get(deviceIdValue));
                                else
                                    deviceEstimateReadingMap.put(deviceIdValue, deviceEstimatedconsumptionMap.get(deviceIdValue));
                            }else{
                                if(!readingUploadErroredMap.containsKey(readingUploadID))
                                    readingUploadErroredMap.put(readingUploadID, LoBt_ErrorConstants.NOESTIMATECONSUMPTION);
                            }
                        }                    
                        readinguploadSkipCodeMap.put(readingUploadId,objSkipCode);
                    } 
                }
            }
        }        
       
        // Reading Mode Validation         
        for(ReadingUpload__c objReadingUpload : readingUploadRecords){
            boolean recordExist = false;
            if(mapOfReadingModeIdToRecord.size() > 0){
                for(ReadingMode__c objReadingMode : mapOfReadingModeIdToRecord.get(objReadingUpload.ReadPeriod__c)){                   
                    if((objReadingMode.Book__c != null && readingUploadBookMap.containsKey(objReadingUpload.Id) && objReadingMode.Book__c == readingUploadBookMap.get(objReadingUpload.Id)) ||
                       (objReadingMode.Depot__c != null && readingUploadDepotMap.containsKey(objReadingUpload.Id) && objReadingMode.Depot__c == readingUploadDepotMap.get(objReadingUpload.Id)) ||
                       (objReadingMode.Area__c != null && readingUploadAreaMap.containsKey(objReadingUpload.Id) && objReadingMode.Area__c == readingUploadAreaMap.get(objReadingUpload.Id)) ){
                           recordExist = true;
                           ruReadingModeMap.put(objReadingUpload.Id,objReadingMode.Id); 
                           break;
                       }                    
                }
            }
            if (recordExist == false){
                if(!readingUploadErroredMap.containsKey(objReadingUpload.Id))
                    readingUploadErroredMap.put(objReadingUpload.Id, LoBt_ErrorConstants.NOREADINGMODE);
            }
        } 
                
        // reading exist in system
        for(Reading__c objReading : [SELECT Id,ReadingDate__c,Device__c 
                                     FROM Reading__c 
                                     WHERE Device__c IN: readingUploadDeviceMap.values()]){
            // Reading exist for correcponding device 
            if(objReading.ReadingDate__c == ruReadingDateMap.get(deviceReadingUploadMap.get(objReading.Device__c))){
                if(!readingUploadErroredMap.containsKey(deviceReadingUploadMap.get(objReading.Device__c)))
                    readingUploadErroredMap.put(deviceReadingUploadMap.get(objReading.Device__c), LoBt_ErrorConstants.READINGEXIST);                             
            }
            
        }
      
        //AT-5209
        //get all Supply Point Details
        Map<Id, SupplyPoint__c> deviceSupplyPointObjMap = new Map<Id, SupplyPoint__c>();
        for(SupplyPoint__c objSP: [SELECT Id,Advice__c
                                  FROM SupplyPoint__c
                                   WHERE Id IN: deviceSupplyPointMap.values()]){
            for(Id deviceId: deviceSupplyPointMap.keySet()){
                if(deviceSupplyPointMap.get(deviceId) == objSP.Id){
                    deviceSupplyPointObjMap.put(deviceId, objSP);
                    break;
                }
            }                                      
        }
      
        List<ReadingUpload__c> updatedReadingUploadList  = new List<ReadingUpload__c>();    
        //AT-2443 changes....
       	Integer errorRecord = 0;
		Integer readingRecord = 0;
        List<BatchError__c> batchErrorList = new List<BatchError__c>();
        Map<Id,Integer> readingUploadIdWithErrorIndexMap = new Map<Id,Integer>();
        List<Reading__c> readingRecordList = new List<Reading__c>();
        Map<Id,Integer> readingUploadIdWithReadingIndexMap = new Map<Id,Integer>();
        List<SupplyPoint__c> updatedSupplyPointsList = new List<SupplyPoint__c>();
            
        //AT-2443 changes end...
        for(ReadingUpload__c objReadingUpload : readingUploadRecords){           
                        
            // create Batch Error records
            if (readingUploadErroredMap.containsKey(objReadingUpload.Id)){ 
                rejectedReadingUploadRecords = rejectedReadingUploadRecords + 1; 
                
                BatchError__c objBatchError = new BatchError__c();
                objBatchError.ErrorDetails__c = readingUploadErroredMap.get(objReadingUpload.Id); 
                objBatchError.BatchRequestQueue__c = this.batchRequestQueueId;
                objBatchError.BatchRequestOperation__c = GlUt_Constants.BATCHPROCESSOPERATION;
				objBatchError.BatchRequestType__c = GlUt_Constants.BRTYPEMETERBOOK;
                
                //AT-2443 changes start...
                batchErrorList.add(objBatchError);
                readingUploadIdWithErrorIndexMap.put(objReadingUpload.Id, errorRecord);
                errorRecord = errorRecord + 1;    
                //AT-2443 changes end...
                
                //Insert objBatchError;				// AT-2443 changes
                // Link Reading Upload to Batch Error & update status
              /*  objReadingUpload.RejectionReason__c = objBatchError.ErrorDetails__c;
                objReadingUpload.BatchError__c = objBatchError.Id;
                objReadingUpload.AverageDailyUsage__c = readingUploadIDAduMAP.containsKey(objReadingUpload.Id) ? readingUploadIDAduMAP.get(objReadingUpload.Id): null ;
                objReadingUpload.ReadTimetableThreshold__c = ruReadTTThresholdsMAP.containsKey(objReadingUpload.Id) ? ruReadTTThresholdsMAP.get(objReadingUpload.Id) : null ;
                objReadingUpload.SkipCode__c = readinguploadSkipCodeMap.containsKey(objReadingUpload.Id) ? readinguploadSkipCodeMap.get(objReadingUpload.Id).Id : null ;
                objReadingUpload.ReadingStatus__c = 'Error'; */
                
            }else{               
                newReadingRecordsCreated = newReadingRecordsCreated + 1;
                
                // create a new Reading record
                Reading__c objReading = new Reading__c();
                objReading.Device__c = readingUploadDeviceMap.get(objReadingUpload.Id);
                objReading.ReadingDate__c = objReadingUpload.ReadingDate__c;
                objReading.Reader__c = objReadingUpload.Reader__c;
                objReading.ReaderRemarks__c = objReadingUpload.Remarks__c;
                objReading.ReadingType__c = GlUt_Constants.REGULAR;  //'Regular';
                
                // if skip code estimated
                if (readinguploadSkipCodeMap.containsKey(objReadingUpload.Id) && 
                    readinguploadSkipCodeMap.get(objReadingUpload.Id).CreateEstimate__c && 
                    deviceEstimateReadingMap.containsKey(readingUploadDeviceMap.get(objReadingUpload.Id)))
                    objReading.ActualDeviceReading__c = String.valueOf(Integer.valueOf(deviceEstimateReadingMap.get(readingUploadDeviceMap.get(objReadingUpload.Id))));
                else
                    objReading.ActualDeviceReading__c = ruReadingMap.get(objReadingUpload.Id);
                
                if (objReadingUpload.ReadSource__c != null || objReadingUpload.ReadSource__c != '') 
                	objReading.ReadingSource__c = objReadingUpload.ReadSource__c;                
                if (objReadingUpload.ReadingMethod__c != null || objReadingUpload.ReadingMethod__c != '') 
                	objReading.ReadingMethod__c = objReadingUpload.ReadingMethod__c; 
                if(ruTrippedMap.get(objReadingUpload.Id) == true)  
                    objReading.Tripped__c = true;
           
                //AT-2443 changes start...
                readingRecordList.add(objReading);
                readingUploadIdWithReadingIndexMap.put(objReadingUpload.Id, readingRecord);
                readingRecord = readingRecord + 1;
                //AT-2443 changes end...
                
                //AT-5209
                
                if(deviceSupplyPointObjMap.containsKey(readingUploadDeviceMap.get(objReadingUpload.Id))){
                    SupplyPoint__c spObj = deviceSupplyPointObjMap.get(readingUploadDeviceMap.get(objReadingUpload.Id));
                    spObj.Advice__c = objReadingUpload.Advice__c;
                    updatedSupplyPointsList.add(spObj);                                                 
                }
                    
               /* insert objReading;
               
                // Create a Scheduled Reading record and associated with the Reading, Reading Mode and Read Period
                ScheduledRead__c objScheduleRead;
            	if(objReading.Id != null){
                    objScheduleRead = new ScheduledRead__c();
                    objScheduleRead.Reading__c = objReading.Id;
                    objScheduleRead.ReadPeriod__c = objReadingUpload.ReadPeriodId__c;
                    objScheduleRead.ReadingMode__c = ruReadingModeMap.get(objReadingUpload.Id); 
                    insert objScheduleRead;
                }
                
                objReadingUpload.ReadingL__c = objReading.Id;               
                objReadingUpload.AverageDailyUsage__c = readingUploadIDAduMAP.containsKey(objReadingUpload.Id) ? readingUploadIDAduMAP.get(objReadingUpload.Id): null;
                objReadingUpload.ReadTimetableThreshold__c = ruReadTTThresholdsMAP.containsKey(objReadingUpload.Id) ? ruReadTTThresholdsMAP.get(objReadingUpload.Id): null;
                objReadingUpload.SkipCode__c = readinguploadSkipCodeMap.containsKey(objReadingUpload.Id) ? readinguploadSkipCodeMap.get(objReadingUpload.Id).Id: null;
                objReadingUpload.ReadingStatus__c = 'Processed';
				*/
            }             
            
           // updatedReadingUploadList.add(objReadingUpload);            
        }
        
        //AT-2443 changes Start...
        // insert batch error records
        if(batchErrorList.size() > 0){
            batchErrorList = (List<BatchError__c>) GlUt_FieldSecurity.cleanseFields(batchErrorList, false);
            database.insert(batchErrorList);
        }
           
           
        //insert reading records
        if(readingRecordList.size() > 0){
            readingRecordList = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(readingRecordList, false);
            database.insert(readingRecordList);
        }
        
        //update SupplyPoint records
        if(updatedSupplyPointsList.size() > 0){
            updatedSupplyPointsList = (List<SupplyPoint__c>) GlUt_FieldSecurity.cleanseFields(updatedSupplyPointsList, false);
            database.update(updatedSupplyPointsList);
        }                                                              
        List<ScheduledRead__c> scheduledReadList = new List<ScheduledRead__c>();       
        for(ReadingUpload__c objReadingUpload : readingUploadRecords){ 
            // Linked error record to reading upload record
            if(readingUploadIdWithErrorIndexMap.containsKey(objReadingUpload.Id)){
                objReadingUpload.RejectionReason__c = batchErrorList[readingUploadIdWithErrorIndexMap.get(objReadingUpload.Id)].ErrorDetails__c;
                objReadingUpload.BatchError__c = batchErrorList[readingUploadIdWithErrorIndexMap.get(objReadingUpload.Id)].Id;
                objReadingUpload.AverageDailyUsage__c = readingUploadIDAduMAP.containsKey(objReadingUpload.Id) ? readingUploadIDAduMAP.get(objReadingUpload.Id): null ;
                objReadingUpload.ReadTimetableThreshold__c = ruReadTTThresholdsMAP.containsKey(objReadingUpload.Id) ? ruReadTTThresholdsMAP.get(objReadingUpload.Id) : null ;
                objReadingUpload.SkipCode__c = readinguploadSkipCodeMap.containsKey(objReadingUpload.Id) ? readinguploadSkipCodeMap.get(objReadingUpload.Id).Id : null ;
                objReadingUpload.ReadingStatus__c = GlUt_Constants.ERROR; //'Error';
                
            }else if(readingUploadIdWithReadingIndexMap.containsKey(objReadingUpload.Id)){ 
                // Create a Scheduled Reading record and associated with the Reading, Reading Mode and Read Period
                ScheduledRead__c objScheduleRead;                
            	if(readingRecordList[readingUploadIdWithReadingIndexMap.get(objReadingUpload.Id)].Id != null){
                    objScheduleRead = new ScheduledRead__c();
                    objScheduleRead.Reading__c = readingRecordList[readingUploadIdWithReadingIndexMap.get(objReadingUpload.Id)].Id;
                    objScheduleRead.ReadPeriod__c = objReadingUpload.ReadPeriod__c; // CLB-18, Ankit Gangwani
                    objScheduleRead.ReadingMode__c = ruReadingModeMap.get(objReadingUpload.Id); 
                    scheduledReadList.add(objScheduleRead);
                }       
                
                objReadingUpload.Reading__c = readingRecordList[readingUploadIdWithReadingIndexMap.get(objReadingUpload.Id)].Id;		               
                objReadingUpload.AverageDailyUsage__c = readingUploadIDAduMAP.containsKey(objReadingUpload.Id) ? readingUploadIDAduMAP.get(objReadingUpload.Id): null;
                objReadingUpload.ReadTimetableThreshold__c = ruReadTTThresholdsMAP.containsKey(objReadingUpload.Id) ? ruReadTTThresholdsMAP.get(objReadingUpload.Id): null;
                objReadingUpload.SkipCode__c = readinguploadSkipCodeMap.containsKey(objReadingUpload.Id) ? readinguploadSkipCodeMap.get(objReadingUpload.Id).Id: null;
                objReadingUpload.ReadingStatus__c = GlUt_Constants.PROCESSED;  // 'Processed';
                
            }
            updatedReadingUploadList.add(objReadingUpload);            
        }        
        
        if(scheduledReadList.size() > 0) {
            scheduledReadList = (List<ScheduledRead__c>) GlUt_FieldSecurity.cleanseFields(scheduledReadList, false);
            database.insert(scheduledReadList);            
        }
        if(updatedReadingUploadList.size() > 0) {
            updatedReadingUploadList = (List<ReadingUpload__c>) GlUt_FieldSecurity.cleanseFields(updatedReadingUploadList, false);
            database.update(updatedReadingUploadList);
        }                   
    }
    
    /******************************************************************************
	@author    		Echo: Neha R.
	@date      		21 May 2018
	@param			Database.BatchableContext bc	
	@return			Database.QueryLocator
	@description 	Method create new file tell number of record created and 
					number of record rejected
	*******************************************************************************/  
    global void finish(Database.BatchableContext bc){
        String fileData = 'The total number of Readings Created ' + String.valueOf(newReadingRecordsCreated) + '\r\n' + 
            		      'The total number of Errors           ' + String.valueOf(rejectedReadingUploadRecords);

        String meterBookLibraryName='';
        EnvironmentSettings__mdt mdtEnvSetting = GlUt_CustomMetaDataUtility.getEnviromentSettingDetails(GlUt_Constants.ENVIROMENTSETTINGBOOKIMPORTQUERY);
        if (mdtEnvSetting != null && string.isNotBlank(mdtEnvSetting.BooksImport__c)) {
            meterBookLibraryName = mdtEnvSetting.BooksImport__c;
        }
        String fileName = System.Label.LoBt_ImportFilePrefix + '_' + System.today().format() + GlUt_Constants.REPORT_FILE_EXTENSION;  //'.txt';
        Id contentDocumentId = GlUt_ContentDocument.saveLinkedDocument(this.batchRequestQueueId, meterBookLibraryName, fileName, fileName, LoBt_Constants.SHARE_TYPE, blob.valueOf(fileData));
        // Batch Request Queue Status with ‘Completed'        
        BatchRequestQueue__c objBRQ = [SELECT SendEmailNotification__c , NotificationUser__c , Status__c FROM BatchRequestQueue__c WHERE Id =: this.batchRequestQueueId LIMIT 1];            
        objBRQ.Status__c = GlUt_Constants.COMPLETED; //'Completed'; 
        objBRQ.SendEmailNotification__c = true;                                   
        objBRQ.NotificationUser__c = UserInfo.getUserId(); 
        objBRQ  = (BatchRequestQueue__c) GlUt_FieldSecurity.cleanseFields(objBRQ, false);
        database.update(objBRQ);
    }  
}