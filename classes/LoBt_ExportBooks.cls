/******************************************************************************
@author         Echo: Amit K.
@date           21 May 2018
@description    Batch class to export books and save the content in the form of txt and .csv file.
Revision(s)		AT-4888, Checkmarks issues.
*******************************************************************************/
global with sharing class LoBt_ExportBooks extends GlBt_BatchProcess implements Database.Batchable<sObject>,Database.Stateful   {
    private static final String CLASS_NAME = 'LoBt_ExportBooks';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static List<string> supplyPointFields;
    private static LoBt_ExportBooksHelper.ContainerWrapper oContainerWrapper ;
    global Id readPeriod;
    static{
        supplyPointFields = new List<string>();
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.NAMEAPINAME); 
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.BOOKAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.LOCATIONRELAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.DEPOTRELAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.BOOKRELAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.WALKORDERAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.VOIDLOCATIONAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.DEVICELOCATIONAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.GEOLOCATIONAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.SPECIALINSTRUCTIONAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.TARGETREADDATEAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.BOOKDEPOTRELAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.ADVICEAPINAME); //AT-3538
        
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
        csvHeaderFields.add(LoBt_Constants.Advice); //AT-3538
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
    
    global String csvFileString = '';
    global List<SupplyPoint__c> spList = new List<SupplyPoint__c>();
    global BatchRequestQueue__c batchRequestQueue;
    global static string sQuery;
    global Integer totalNumberOfBookExtracted = 0 ;
    global Map<Id,Integer> mapOfBook2SupplyPointSize = new Map<Id,Integer>();
    global Map<Id,Book__c> mapOfBookId2Book = new Map<Id,Book__c>();
    /******************************************************************************
    @author         Echo: Amit K.
    @date           21 MAY 2018
    @description    Override GlBt_BatchProcess method as per Batch framework.
    *******************************************************************************/
    global override void Initialise(BatchRequestQueue__c brq){
        this.batchRequestQueue = brq ;
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           21 MAY 2018
    @description    Batch's start method
    *******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        //AT-3204 Starts Here
        LoBt_ExportBooksHelper.changeBRQStatus(batchRequestQueue.Id,LoBt_Constants.BRQPROCESSINGSTATUS);
        //AT-3204 Ends Here
        LoPr_BookExportParameters objBookExportParameters;
        //Parse batch request queue paramter field.
        
        objBookExportParameters = LoPr_BookExportParameters.parse(batchRequestQueue.Parameters__c);
        List<Id> bookIds = objBookExportParameters.booksToExport;
        readPeriod = objBookExportParameters.periodID;
        
        if(!bookIds.isEmpty()){
            //Fetch the supply point on the basis parse book ids.
            sQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(supplyPointFields,','), 
                GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME +' WHERE ' + 
                GlUt_APIConstantsSupplyPoint.BOOKAPINAME + ' IN:bookIds'});
        }
        //Create CSV Header string.
        for(String fieldName : csvHeaderFields){
            csvFileString = csvFileString + ',' + fieldName.replace(',','');
        } 
        csvFileString = csvFileString.replaceFirst(',','') + '\n';
        
        return Database.getQueryLocator(sQuery);
        
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           21 MAY 2018
    @description    Batch's execute method
    *******************************************************************************/
    global void execute(Database.BatchableContext bc, List<sObject> scope){ 
        try{          
            List<SupplyPoint__c> supplyPointList = (List<SupplyPoint__c>) scope; 
            //Hold the extracted supplypoint in stateful variable.
            spList.addAll(supplyPointList);
            //Fetch the csv data in the form of string.
            oContainerWrapper = LoBt_ExportBooksHelper.getCSVRecords(supplyPointList,csvFileString,readPeriod,totalNumberOfBookExtracted,mapOfBook2SupplyPointSize);
            //Hold the extracted data in stateful global variables.
            csvFileString = oContainerWrapper.csvFileString;
            mapOfBook2SupplyPointSize = oContainerWrapper.mapOfBook2SupplyPointSize;
            totalNumberOfBookExtracted = oContainerWrapper.totalNumberOfBookExtracted;
            mapOfBookId2Book =  oContainerWrapper.mapOfBookId2Book;
        }
        catch (exception e){
            GlUt_Logger.logException(e);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    } 
    /******************************************************************************
    @author         Echo: Amit K.
    @date           21 May 2018
    @description    Batch's final method
    *******************************************************************************/
    global void finish(Database.BatchableContext bc){
        Savepoint sp = Database.setSavepoint();
        try{ 
            //Fetch the Library name for environmental setting meta data.
            if(string.isNotBlank(csvFileString)){
                String MeterBookLibraryName='';
                /*for (EnvironmentSettings__mdt env : [select ExportBooksLibrary__c 
                                                     from EnvironmentSettings__mdt LIMIT 1]) {
                                                         
                                                         MeterBookLibraryName = env.ExportBooksLibrary__c;
                                                     }*/
                
                EnvironmentSettings__mdt mdtEnvSetting = GlUt_CustomMetaDataUtility.getEnviromentSettingDetails(GlUt_Constants.ENVIROMENTSETTINGEXPORTLIBRARYQUERY);
                if (mdtEnvSetting != null && string.isNotBlank(mdtEnvSetting.ExportBooksLibrary__c)) {
                    MeterBookLibraryName = mdtEnvSetting.ExportBooksLibrary__c;
                }
                //csv file format
                string name = System.Label.LoBt_ExportFilePrefix+'_' +DateTime.now().format(GlUt_Constants.DATE_TIME_FORMAT) + GlUt_Constants.FILE_EXTENSION_CSV; 
                //Save the data in content files as a csv.
                Id contentDocumentId =  GlUt_ContentDocument.saveLinkedDocument(batchRequestQueue.Id, MeterBookLibraryName, name, name, LoBt_Constants.SHARE_TYPE, blob.valueOf(csvFileString));
                //txt file format
                string exportFileName = System.Label.LoBt_ExportFileSummaryPrefix+'_' +DateTime.now().format(GlUt_Constants.DATE_TIME_FORMAT) + GlUt_Constants.REPORT_FILE_EXTENSION;
                String txtContent =''  ;
                txtContent = LoBt_Constants.TOTALNUMBEROFBOOKEXTRACTED+ totalNumberOfBookExtracted +' \n '+LoBt_Constants.TOTALNUMBEROFSUPPLYPOINTEXTRACTPERBOOK+' \n ' ;
                for(Id bookId: mapOfBook2SupplyPointSize.keySet()){
                    txtContent = txtContent + LoBt_Constants.BOOKNAME +' '+mapOfBookId2Book.get(bookId).Name +' '+LoBt_Constants.NUMBEROFSUPPLYPOINT+ mapOfBook2SupplyPointSize.get(bookId) + ' \n ';
                }
                System.debug(DEBUG+'*****txtContent'+txtContent);
                //Save the data in content file as txt.
                Id cdId =  GlUt_ContentDocument.saveLinkedDocument(batchRequestQueue.Id, MeterBookLibraryName, exportFileName, exportFileName, LoBt_Constants.SHARE_TYPE, blob.valueOf(txtContent));
                if(contentDocumentId != null && cdId != null){
                    //Change the Reading Status to exported.
                    LoBt_ExportBooksHelper.changeReadingRequestStatus(spList);
                    //Change the BRQ Status to Completed.
                    //AT-3204 Starts Here
                    LoBt_ExportBooksHelper.changeBRQStatus(batchRequestQueue.Id,LoBt_Constants.BRQSTATUS);
                    //AT-3204 Ends Here
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