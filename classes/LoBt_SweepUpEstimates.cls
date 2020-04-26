/******************************************************************************
    @author         Echo: Swati Mathur
    @date           29 May 2018
    @description    Batch class to export books and save the content in the form of txt and .csv file.
	Revision(s)		AT-4888, Checkmarks issues.
*******************************************************************************/
global with sharing class LoBt_SweepUpEstimates extends GlBt_BatchProcess implements Database.Batchable<sObject>,Database.Stateful{
    
    private static final String CLASS_NAME = 'LoBt_SweepUpEstimates';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    global Id readPeriod;
    global List<Id> lstBookIds = new List<Id>();
    global static string sQuery;
    global Set<Id> setPeriodsToEstimate = new Set<Id>();
    global BatchRequestQueue__c batchRequestQueue;
    global Map<Id, List<SupplyPoint__c>> BookId2SupplyPointListMap = new Map<Id, List<SupplyPoint__c>>();   
    
    private static List<string> supplyPointFields;
    static{
        supplyPointFields = new List<string>();
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.BOOKAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.BOOKREADTIMETABLERAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.EXCLUDEFROMESTIMATIONAPINAME);        
    }    
    private static List<string> bookFields;
    static{
        bookFields = new List<string>();
        bookFields.add(GlUt_APIConstantsBook.ID); 
    }
    private static List<string> readPeriodFields;
    static{
        readPeriodFields = new List<string>();
        readPeriodFields.add(GlUt_APIConstantsReadPeriod.READTIMETABLEAPINAME); 
    }
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           29 May 2018
    @description    Override GlBt_BatchProcess method as per Batch framework.
    *******************************************************************************/
    global override void Initialise(BatchRequestQueue__c brq){
        this.batchRequestQueue = brq;
    }
    /******************************************************************************
    @author         Echo: Swati Mathur
	@date           29 May 2018
    @description    Batch's start method
   *******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //AT-3204 Starts Here
        LoBt_SweepUpEstimatesHelper.updateBRQ(new list<BatchRequestQueue__c> {batchRequestQueue}, LoBt_Constants.BRQPROCESSINGSTATUS);	//checkmarx: bulkify
        //AT-3204 Ends Here
        Boolean scheduledSweepUp = false; 
        String executionMode;
        Id readPeriodId;
        LoPr_SweepUpParameters objSweepUpEstimate;
        List<Id> bookIds;       
        
        if(batchRequestQueue.Parameters__c == null){ //Assume this is a scheduled Sweep up
            List<Id> lstReadPeriodIds = LoBt_SweepUpEstimatesHelper.scheduledSweepUp();
            //Retrieve all Books related to the Period Id List
            if(!lstReadPeriodIds.isEmpty()){
                List<Book__c> lstBook = GlUt_MeterBooksUtilities.getBooksFromReadPeriods(lstReadPeriodIds, readPeriodFields, bookFields);
                for(Book__c b : lstBook){
                    lstBookIds.add(b.Id);        
                } 
                setPeriodsToEstimate.addAll(lstReadPeriodIds);
            }
        }
        else{
            objSweepUpEstimate = LoPr_SweepUpParameters.parse(batchRequestQueue.Parameters__c);
            executionMode = objSweepUpEstimate.ExecutionMode;
            readPeriodId = objSweepUpEstimate.periodID;
            bookIds = objSweepUpEstimate.booksToEstimate;
            
            if(objSweepUpEstimate == null || executionMode == null || readPeriodId == null || bookIds.isEmpty()){
                LoBt_SweepUpEstimatesHelper.createBatchError(batchRequestQueue);
            }
            else{
                lstBookIds.addAll(bookIds);
                setPeriodsToEstimate.add(readPeriodId);
            }
        }        
        
        //Retrieve List<SupplyPoint> SPsToEstimate related to the Set<id> of Books from the previous step        
        sQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(supplyPointFields,','), 
            GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME +' WHERE ' + 
            GlUt_APIConstantsSupplyPoint.BOOKAPINAME + ' IN:lstBookIds'}); 
                
        return Database.getQueryLocator(sQuery);
    }
    /******************************************************************************
    @author         Echo: Swati Mathur
	@date           29 May 2018
    @description    Batch's execute method
    *******************************************************************************/
    global void execute(Database.BatchableContext bc, List<sObject> scope){ 
        try{ 
            List<SupplyPoint__c> SPsToEstimate = (List<SupplyPoint__c>) scope;
            
			LoBt_SweepUpEstimatesHelper.ContainerWrapper objContainerWrapper =  new LoBt_SweepUpEstimatesHelper.ContainerWrapper();
			objContainerWrapper = LoBt_SweepUpEstimatesHelper.executeMainLogic(SPsToEstimate,setPeriodsToEstimate,lstBookIds,BookId2SupplyPointListMap);
            List<Reading__c> readingsToInsert = objContainerWrapper.readingsToInsert;
            List<ScheduledRead__c> scheduledReadsToInsert = objContainerWrapper.scheduledReadsToInsert;
            BookId2SupplyPointListMap = objContainerWrapper.BookId2SupplyPointListMap;
		
            if(!readingsToInsert.isEmpty() && !scheduledReadsToInsert.isEmpty()){
                Insert readingsToInsert; 
                Insert scheduledReadsToInsert;
                //Mark Period as Estimated
                LoBt_SweepUpEstimatesHelper.updateReadPeriods(setPeriodsToEstimate);
            }
            
        }
        catch (exception e){
            GlUt_Logger.logException(e);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
   /******************************************************************************l
    @author         Echo: Swati Mathur
	@date           29 May 2018
    @description    Batch's final method
   *******************************************************************************/
    global void finish(Database.BatchableContext bc){
        Savepoint sp = Database.setSavepoint();
        try{
            
            //Fetch the Library name for environmental setting meta data.
            String MeterBookLibraryName;
            for (EnvironmentSettings__mdt env : [select ExportBooksLibrary__c 
                                                 from EnvironmentSettings__mdt LIMIT 1]) {
                                                     MeterBookLibraryName = env.ExportBooksLibrary__c;
                                                 }
            
            //export file report
            string exportFileName =  System.Label.LoBt_ExportFileSummaryPrefix +'_'+DateTime.now().format(LoBt_Constants.DATETIMEFORMAT)+ LoBt_Constants.TXTFILEEXTENSION;
            String txtContent =''  ;
            txtContent = LoBt_Constants.TOTALNUMBEROFBOOKEXTRACTED+ BookId2SupplyPointListMap.size() +' \n '+LoBt_Constants.TOTALNUMBEROFSUPPLYPOINTEXTRACTPERBOOK+' \n ' ;
            for(Id bookId: BookId2SupplyPointListMap.keySet()){
                txtContent = txtContent+LoBt_Constants.BOOKNAME +' '+bookId+' '+LoBt_Constants.NUMBEROFSUPPLYPOINT+ BookId2SupplyPointListMap.get(bookId).size() + ' \n ';
            } 
            //Save the data in content file as txt.
            Id cdId =  GlUt_ContentDocument.saveLinkedDocument(batchRequestQueue.Id, MeterBookLibraryName, exportFileName, exportFileName, LoBt_Constants.SHARE_TYPE, blob.valueOf(txtContent));
            if(cdId != null){
                //Change the BRQ Status to Completed
                LoBt_SweepUpEstimatesHelper.updateBRQ(new list<BatchRequestQueue__c> {batchRequestQueue}, LoBt_Constants.BRQSTATUS); //checkmarx: bulkify
            }            
        }
        catch (exception e){
            GlUt_Logger.logException(e);
            Database.rollback(sp);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
}