/******************************************************************************
@author         Echo: Dependra Singh
@date           18 Dec 2018
@description    Class is used to 
*******************************************************************************/
global with sharing class CuBt_ConcessionExport extends GlBt_BatchProcess implements Database.Batchable<sObject>,Database.Stateful {
    global static string sQuery;
    global BatchRequestQueue__c batchRequestQueue;
    private static List<string> supplyPointsFields;
    global Set<Id> setBookIds;
    global Integer totalNumberOfBooksExtracted = 0 ;
    global string xmlString ='';
    static{
        supplyPointsFields = new List<string>();
        supplyPointsFields.add(GlUt_APIConstantsSupplyPoint.BOOKAPINAME); 
        supplyPointsFields.add(GlUt_APIConstantsSupplyPoint.LOCATIONAPINAME);
        
    }
  /******************************************************************************
    @author         Echo: Dependra Singh
    @date           18 Dec 2018
    @description    Override GlBt_BatchProcess method as per Batch framework.
    *******************************************************************************/
    global override void Initialise(BatchRequestQueue__c brq){
        this.batchRequestQueue = brq;
    }
	   /******************************************************************************
    @author         Echo: Dependra Singh
    @date           8 Dec 2018
    @description    Batch's start method
   *******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        //Update Batch Request Queue to Processing.
        BatchRequestQueue__c brq = [SELECT Id,Status__c FROM BatchRequestQueue__c WHERE Id=:batchRequestQueue.Id Limit 1];			
        brq.Status__c = GlUt_Constants.BATCH_REQUEST_QUEUE_STATUS_PROCESSING;
        update brq;
        setBookIds = new Set<Id>();
        // Extract information from the Batch Process Queue for use in the batch process.
        // The Parameters Field should be serialised into a new instance of  CuUt_ConcessionExportParameters
        CuPr_ConcessionExportParameters objConcessionExportParameters;
        //Parse batch request queue paramter field.
        objConcessionExportParameters = CuPr_ConcessionExportParameters.parse(batchRequestQueue.Parameters__c);
        if(objConcessionExportParameters.booksToExport != null && !objConcessionExportParameters.booksToExport.isEmpty()){
            setBookIds.addAll(objConcessionExportParameters.booksToExport);
        }
        totalNumberOfBooksExtracted = setBookIds.size();
        sQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(supplyPointsFields,','), 
            GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME +' Where '+ GlUt_APIConstantsSupplyPoint.BOOKAPINAME + ' IN: setBookIds'
            });
        return Database.getQueryLocator(sQuery);        
    }
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           8 Dec 2018
    @description    Batch's execute method
    *******************************************************************************/
    global void execute(Database.BatchableContext bc, List<sObject> scope){    
        set<Id> setLocationIds = new set<Id>();
        set<Id> setAccountIds = new set<Id>();
        try{          
            if(scope != null && !scope.isEmpty()){
                for(SupplyPoint__c objSupplyPoint : (List<SupplyPoint__c>)scope){
                    if(objSupplyPoint.Location__c != null){
                        setLocationIds.add(objSupplyPoint.Location__c);
                    }	
                }
            }
            List<LocationOccupant__c> lstLocationOccupant = [SELECT Id, Account__c , Location__c 
                                                             FROM LocationOccupant__c 
                                                             WHERE Location__c IN : setLocationIds and Active__c= true];
            if(lstLocationOccupant != null && !lstLocationOccupant.isEmpty()){
                for(LocationOccupant__c objLocationOccupant : lstLocationOccupant){
                    setAccountIds.add(objLocationOccupant.Account__c);
                }
            }
            if(setAccountIds.size() > 0){
                List<Concession__c> concessionList = [SELECT Id, Account__c,PostCode__c,ConsentDate__c,CRN__c,EndDate__c,
                                                      StartDate__c,Type__c,Validated__c,ValidationDate__c,ConfirmDate__c 
                                                      FROM Concession__c WHERE Account__c IN :setAccountIds 
                                                      AND ConsentDate__c != null AND CRN__c != null];
                if(concessionList != null && !concessionList.isEmpty()){
                    CuUt_ConcessionXMLContainer objConcessionExp = new CuUt_ConcessionXMLContainer(concessionList);
                    xmlString += objConcessionExp.XML;
                }
            }
        }
        catch (exception e){
            GlUt_Logger.logException(e);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
   /******************************************************************************
    @author         Echo: Dependra Singh
    @date           8 Dec 2018
    @description    Batch's final method
   *******************************************************************************/
    global void finish(Database.BatchableContext bc){
        Savepoint sp = Database.setSavepoint();
        try{
            //xmlString=  '<BatchRequest004> <header> <system>CCS</system> <timestamp>20070915144800</timestamp> <userId>ANZ-001</userId> <senderOrgCrn>999999999T</senderOrgCrn> <recverOrgCrn>123456789A</recverOrgCrn> <senderAbn>12345678999</senderAbn> <recverAbn>29468422437 </recverAbn> <batchInfo>This can be used for free text</batchInfo> </header> <statusRqst id="1"> <crn>999999999L</crn> <cnfrmDate>20070915</cnfrmDate> <pcode>2900</pcode> <scndryCrn>111111111A</scndryCrn> </statusRqst> </BatchRequest004> ';
            if(string.isNotBlank(xmlString)){
                EnvironmentSettings__mdt mdtEnviromentSetting = GlUt_CustomMetaDataUtility.getEnviromentSettingDetails(GlUt_Constants.ENVSETTINGCONCESSIONEXPORTQUERY);
                String requestedConcessionExportLibraryName=mdtEnviromentSetting.ConcessionExportLibrary__c;
                string baseName = System.Label.CuBt_ConcessionExportFilePrefix + DateTime.now().format(LoBt_Constants.DATEFORMAT);
                string nextTitle = getNextTitelName(baseName);
                string name =  nextTitle +LoBt_Constants.XMLFILEEXTENSION;
                //Save the data in content files as a csv.
                Id contentDocumentId =  GlUt_ContentDocument.saveLinkedDocument(batchRequestQueue.Id,
                                                                                requestedConcessionExportLibraryName,
                                                                                name,
                                                                                name,
                                                                                LoBt_Constants.SHARE_TYPE,
                                                                                blob.valueOf(xmlString));
                
                // We need to change the file name in future - Max 8 character
                string exportFileName = nextTitle + LoBt_Constants.TXTFILEEXTENSION;
                String txtContent = LoBt_Constants.FILENAME +   name  +'\n';
                txtContent += LoBt_Constants.TOTALNUMBEROFBOOKEXTRACTED + totalNumberOfBooksExtracted +'\n';
                //Save the data in content file as txt.
                Id cdId =GlUt_ContentDocument.saveLinkedDocument(batchRequestQueue.Id,
                                                                 requestedConcessionExportLibraryName,
                                                                 exportFileName,
                                                                 exportFileName,
                                                                 LoBt_Constants.SHARE_TYPE,
                                                                 blob.valueOf(txtContent));   
                
                if(contentDocumentId != null && cdId != null){
                    //Update Batch Request Queue to Completed.
                    BatchRequestQueue__c brq = [SELECT Id,Status__c FROM BatchRequestQueue__c WHERE Id=:batchRequestQueue.Id Limit 1];			
                    brq.Status__c = GlUt_Constants.BATCH_REQUEST_QUEUE_STATUS_COMPLETED;
                    brq = (BatchRequestQueue__c) GlUt_FieldSecurity.cleanseFields(brq, false);
                    update brq;
                }
            }
        }
        catch (exception e){
            GlUt_Logger.logException(e);
            Database.rollback(sp);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           26 Apr 2019
	@param 			string baseName
	@return 		string String
    @description    Method is used to get the next title name  of file (As per standard of centerlink-Max 8 character)
					Centerlink Shared Specific format- CYYMMDD +  1=a , 2=b ....
    *******************************************************************************/  
    public static String getNextTitelName(String baseName) {
        string returnString ='';
        string filter ='\'%' + baseName  + '%\'';
        List<String> lstTitles = new List<String>();
        string queryContentVersion = 'Select Id, Title from ContentVersion where Title Like '+  filter;
        List<ContentVersion> lstContentVersion =Database.query(queryContentVersion);      
        if(lstContentVersion != null && !lstContentVersion.isEmpty()){
            for(ContentVersion objContentVersion : lstContentVersion){
                string title = objContentVersion.Title;
                if(title.contains('.')){
                    List<string> lstString = title.split('\\.');
                    if(lstString != null && lstString.size() >0){
                        lstTitles.add(lstString[0]); 
                    } 
                }
            }
        }else{
            returnString = baseName + LoAp_Constants.FIRSTCHARACTER;
        }
        if(!lstTitles.isEmpty()){
            lstTitles.sort();
            string strLastTitle  = lstTitles[lstTitles.size()-1];
            if(string.isNotBlank(strLastTitle)){
                returnString = baseName + getNextChar(strLastTitle.Substring(strLastTitle.length()-1,strLastTitle.length()));
            }
        }
        return returnString;
    }
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           26 Apr 2019
	@param 			string baseName
	@return 		string String
    @description    Centerlink Shared Specific format- CYYMMDD +  1=a , 2=b .... 
					So Method is used to get the next characer using old character
    *******************************************************************************/  
    public static String getNextChar(String oldChar) {
        String key = 'ABCDEFGHIJKLMNOPQRSTUVWXYZAabcdefghijklmnopqrstuvwxyza';
        Integer index = key.indexOfChar(oldChar.charAt(0));
        return index == -1? null: key.substring(index+1, index+2);
    }
}