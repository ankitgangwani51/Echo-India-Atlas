/******************************************************************************
@author         Swati Mathur
@date           24 May 2018
@description    Batch Class For Export Requested Readings Process   
Revision(s)		AT-4888, Checkmarks issues.
				2 March 2019 Echo: Dependra Singh -> AT-5525 
*******************************************************************************/
global class LoBt_ExportRequestedReadings extends GlBt_BatchProcess implements Database.Batchable<sObject>,Database.Stateful {
    
    private static LoBt_ExportRequestedReadingsHelper.ContainerWrapper objContainerWrapper ;
    private static List<string> readingRequestFields;
    static{
        readingRequestFields = new List<string>();
        readingRequestFields.add(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME); 
        readingRequestFields.add(GlUt_APIConstantsReadingRequest.READBYDATEAPINAME);
        readingRequestFields.add(GlUt_APIConstantsReadingRequest.CREATEDDATEAPINAME);
        readingRequestFields.add(GlUt_APIConstantsReadingRequest.READCOMMENTSAPINAME);
        readingRequestFields.add(GlUt_APIConstantsReadingRequest.READREASONAPINAME);
        readingRequestFields.add(GlUt_APIConstantsReadingRequest.STATUSAPINAME);
        readingRequestFields.add(GlUt_APIConstantsReadingRequest.SPTOLOCATION);
        readingRequestFields.add(GlUt_APIConstantsReadingRequest.SPTODEPOTNAME);
        readingRequestFields.add(GlUt_APIConstantsReadingRequest.SPTOBOOKNAME);
        readingRequestFields.add(GlUt_APIConstantsReadingRequest.SPTOBOOKTOREADTIMETABLE);
        readingRequestFields.add(GlUt_APIConstantsReadingRequest.SPTOWALKORDER);
        readingRequestFields.add(GlUt_APIConstantsReadingRequest.SPTOVOIDLOCATION);
        readingRequestFields.add(GlUt_APIConstantsReadingRequest.SPTODEVICELOCATION);
        readingRequestFields.add(GlUt_APIConstantsReadingRequest.SPTOGEOLOCATION);
        readingRequestFields.add(GlUt_APIConstantsReadingRequest.SPTOSPECIALINSTRUCTION);
        readingRequestFields.add(GlUt_APIConstantsReadingRequest.SPTOTARGETREADDATE);               
    }
    
    private static List<string> csvHeaderFields;
    static{
        csvHeaderFields = new List<string>();
        csvHeaderFields.add(LoBt_Constants.DEVICEREFERENCE); 
        csvHeaderFields.add(LoBt_Constants.ACCOUNTNAME);
        csvHeaderFields.add(LoBt_Constants.LOCATIONSUPPLYADDRESS);
        csvHeaderFields.add(LoBt_Constants.DEPOT);
        csvHeaderFields.add(LoBt_Constants.BOOKNUMBER);
        csvHeaderFields.add(LoBt_Constants.WALKORDER);
        csvHeaderFields.add(LoBt_Constants.VOIDS);
        csvHeaderFields.add(LoBt_Constants.MANUFACTURER);
        csvHeaderFields.add(LoBt_Constants.SERIALNUMBER);
        csvHeaderFields.add(LoBt_Constants.DEVICELOCATION);
        csvHeaderFields.add(LoBt_Constants.GEOLOCATION);
        csvHeaderFields.add(LoBt_Constants.SPECIALINSTRUCTION);
        csvHeaderFields.add(LoBt_Constants.LASTREADING);
        csvHeaderFields.add(LoBt_Constants.LASTREADINGDATE);
        csvHeaderFields.add(LoBt_Constants.LASTREADINGMETHOD);
        csvHeaderFields.add(LoBt_Constants.LASTACTUALREADING);
        csvHeaderFields.add(LoBt_Constants.LASTACTUALREADINGDATE);
        csvHeaderFields.add(LoBt_Constants.EXPECTEDCONSUMPTIONHIGH);
        csvHeaderFields.add(LoBt_Constants.EXPECTEDCONSUMPTIONLOW);
        csvHeaderFields.add(LoBt_Constants.READREASON);
        csvHeaderFields.add(LoBt_Constants.READBYDATE);
        csvHeaderFields.add(LoBt_Constants.COMMENTS);
        csvHeaderFields.add(LoBt_Constants.TARGETREADINGDATE);
        csvHeaderFields.add(LoBt_Constants.READPERIODID);
    }        
    global static String sQuery;
    global String csvFileString = '';
    global BatchRequestQueue__c batchRequestQueue;
    global List<ReadingRequest__c> lstRR  = new List<ReadingRequest__c>();
    global Integer totalNumberOfSupplyPointExtracted = 0 ;
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           24 MAY 2018
    @description    Override GlBt_BatchProcess method as per Batch framework.
    *******************************************************************************/
    global override void Initialise(BatchRequestQueue__c brq){
        this.batchRequestQueue = brq ;
    }
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           24 MAY 2018
    @description    Batch's start method
    ******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //AT-3204 Starts Here
        LoBt_ExportRequestedReadingsHelper.changeBRQStatus(batchRequestQueue.Id,LoBt_Constants.BRQPROCESSINGSTATUS);
        //AT-3204 Ends Here
        String dateTimeFormat = DateTime.now().format('yyyy-MM-dd\'T\'23:59:59\'Z\'');//2 March 2019 Echo: Dependra Singh -> AT-5525 
        sQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(readingRequestFields,','), 
            GlUt_APIConstantsReadingRequest.READINGREQUESTAPINAME +' WHERE ' + 
            GlUt_APIConstantsReadingRequest.CREATEDDATEAPINAME + ' <= '+ dateTimeFormat + ' AND ' +
            GlUt_APIConstantsReadingRequest.STATUSAPINAME + ' = \''+ LoBt_Constants.READINGREQUESTNEWSTATUS +'\' '}); 
        for(String fieldName : csvHeaderFields){
            csvFileString = csvFileString + ',' + fieldName.replace(',','');
        } 
        csvFileString = csvFileString.replaceFirst(',','') + '\n';       
        return Database.getQueryLocator(sQuery);        
    }
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           24 MAY 2018
    @description    Batch's execute method
    *******************************************************************************/
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        system.debug('scope====='+scope);
        try{
            List<ReadingRequest__c> lstReadingRequest = (List<ReadingRequest__c>) scope;
            lstRR.addAll(lstReadingRequest);
            objContainerWrapper = LoBt_ExportRequestedReadingsHelper.getCSVRecords(lstReadingRequest,csvFileString,totalNumberOfSupplyPointExtracted);
            csvFileString = objContainerWrapper.csvFileString;
            totalNumberOfSupplyPointExtracted = objContainerWrapper.totalNumberOfSupplyPointExtracted;
        }
        catch (exception e){
            GlUt_Logger.logException(e);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }        
    }
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           24 May 2018
    @description    Batch's final method
    *******************************************************************************/    
    global void finish(Database.BatchableContext bc){
        Savepoint sp = Database.setSavepoint();
        try{
            //Fetch the Library name for environmental setting meta data.
            if(string.isNotBlank(csvFileString)){
                String requestedReadingExportLibraryName='';
                /*for (EnvironmentSettings__mdt env : [select RequestedReadingExportLibrary__c 
                                                     from EnvironmentSettings__mdt LIMIT 1]){
                                                         requestedReadingExportLibraryName = env.RequestedReadingExportLibrary__c;
                                                     } */
                EnvironmentSettings__mdt mdtEnvSetting = GlUt_CustomMetaDataUtility.getEnviromentSettingDetails(GlUt_Constants.ENVIROMENTSETTINGREQUESTEDREADINGEXPORTQUERY);
                if (mdtEnvSetting != null && string.isNotBlank(mdtEnvSetting.RequestedReadingExportLibrary__c)) {
                    requestedReadingExportLibraryName = mdtEnvSetting.RequestedReadingExportLibrary__c;
                }
                
                //csv file format
                string name =  System.Label.LoBt_RequestedReadingsExportFilePrefix+'_'+ DateTime.now().format(LoBt_Constants.DATETIMEFORMAT) +LoBt_Constants.CSVFILEEXTENSION;
                //Save the data in content files as a csv.
                Id contentDocumentId =  GlUt_ContentDocument.saveLinkedDocument(
                                                                                batchRequestQueue.Id,
                                                                                requestedReadingExportLibraryName,
                                                                                name,
                                                                                name,
                                                                                LoBt_Constants.SHARE_TYPE,
                                                                                blob.valueOf(csvFileString));
                
                //txt file format
                string exportFileName = System.Label.LoBt_RequestedReadingsExportSummaryPrefix+'_'+ DateTime.now().format(LoBt_Constants.DATETIMEFORMAT) + LoBt_Constants.TXTFILEEXTENSION;
                String txtContent = LoBt_Constants.TOTALNUMBEROFSUPPLYPOINTEXTRACTED + totalNumberOfSupplyPointExtracted +'\n';
                
                //Save the data in content file as txt.
                Id cdId =GlUt_ContentDocument.saveLinkedDocument(
                                                                batchRequestQueue.Id,
                                                                requestedReadingExportLibraryName,
                                                                exportFileName,
                                                                exportFileName,
                                                                LoBt_Constants.SHARE_TYPE,
                                                                blob.valueOf(txtContent));   
                
                if(contentDocumentId != null && cdId != null){
                    //Change the Reading Status to exported.
                    LoBt_ExportRequestedReadingsHelper.changeReadingRequestStatus(lstRR);
                    //Change the BRQ Status to Completed.
                    //AT-3204 
                    LoBt_ExportRequestedReadingsHelper.changeBRQStatus(batchRequestQueue.Id,LoBt_Constants.BRQSTATUS);
                    
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
    
}