/******************************************************************************
@author         Echo: Ankit Gangwani
@date           07 June 2018
@description    Class is used to 
Revision(s)		AT-4888, Checkmarks issues.
*******************************************************************************/
global with sharing class LoBt_ScheduledEstimates extends GlBt_BatchProcess implements Database.Batchable<sObject>,Database.Stateful {
    
    global static string sQuery;
    global Integer estimatedSPCount = 0;
    global static List<string> cronJobDetailsFields;
    global static List<string> cronTriggerFields;
    global BatchRequestQueue__c batchRequestQueue;
    global Set<Id> estimateReadPeriodIds 							= new Set<Id>();
    global Map<Id,Id> mapOfSPId2DeviceId 							= new Map<Id,Id>();
    global Map<Id,Id> mapOfDepotId2AreaId 							= new Map<Id,Id>();
    global Map<Id,Device__c> mapOfDeviceId2Device 					= new Map<Id,Device__c>();
    global Map<Id,List<Reading__c>> mapOfDeviceId2Reading 			= new Map<Id,List<Reading__c>>();
    global Map<Id,List<AverageDailyUsage__c>> spdId2ADUListMap 		= new Map<Id,List<AverageDailyUsage__c>>(); 
    global Map<Id,ReadPeriod__c> mapOfReadPeriodId2ReadPeriod 		= new Map<Id,ReadPeriod__c>();   
    global Map<Id,SupplyPointDevice__c> mapOfSupplyPointId2SPD 		= new Map<Id,SupplyPointDevice__c>();
    global Map<Id,ReadingMode__c> mapOfBook2EstimateReadingMode 	= new Map<Id,ReadingMode__c>();
    global Map<Id,ReadingMode__c> mapOfArea2EstimateReadingMode 	= new Map<Id,ReadingMode__c>();    
    global Map<Id,ReadingMode__c> mapOfDepot2EstimateReadingMode 	= new Map<Id,ReadingMode__c>();
    global Map<Id, List<SupplyPoint__c>> BookId2SupplyPointListMap 	= new Map<Id,List<SupplyPoint__c>>();   
    global Map<Id, List<SupplyPoint__c>> AreaId2SupplyPointListMap 	= new Map<Id,List<SupplyPoint__c>>();   
    global Map<Id, List<SupplyPoint__c>> DepotId2SupplyPointListMap = new Map<Id,List<SupplyPoint__c>>();
    global Map<Id,Area__c> mapOfAreaId2AreaDetails		 			= new Map<Id,Area__c>();
    global Map<Id,Book__c> mapOfBookId2BookDetails		 			= new Map<Id,Book__c>();
    global Map<Id,Depot__c> mapOfDepotId2DepotDetails	 			= new Map<Id,Depot__c>();
    global Map<Id,SupplyPoint__c> mapOfSupplyPointId2SupplyPointDetails = new Map<Id,SupplyPoint__c>();
    global Map<Id,String> mapOfDeviceId2FormulaValue 				= new Map<Id,String>();
   
    global List<BatchError__c> batchErrorList = new List<BatchError__c>();
    
    private static List<string> supplyPointFields;
    static{
        //Get Fields from the Supply Point Object
        supplyPointFields = new List<string>();
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.NAMEAPINAME); 
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.BOOKAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.LOCATIONRELAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.LOCATIONADDRESSAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.DEPOTRELAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.BOOKRELAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.WALKORDERAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.DEVICELOCATIONAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.GEOLOCATIONAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.SPECIALINSTRUCTIONAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.TARGETREADDATEAPINAME);
    
        //Get Fields from the CronJobDetails Object
        cronJobDetailsFields = new List<string>();
        cronJobDetailsFields.add(GlUt_APIConstantsCronJobDetail.ID);
        cronJobDetailsFields.add(GlUt_APIConstantsCronJobDetail.NAMEAPINAME);
        
        //Get Fields from the CronTrigger Object
        cronTriggerFields = new List<string>();
        cronTriggerFields.add(GlUt_APIConstantsCronTrigger.ID);
        cronTriggerFields.add(GlUt_APIConstantsCronTrigger.NEXTFIRETIMEAPINAME);
        cronTriggerFields.add(GlUt_APIConstantsCronTrigger.PREVIOUSFIRETIMEAPINAME);
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           07-06-2018
    @description    Override GlBt_BatchProcess method as per Batch framework.
    *******************************************************************************/
    global override void Initialise(BatchRequestQueue__c brq){
        
        this.batchRequestQueue = brq;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        //AT-3204 Starts Here
        LoBt_ExportBooksHelper.changeBRQStatus(batchRequestQueue.Id,LoBt_Constants.BRQPROCESSINGSTATUS);
        //AT-3204 Ends Here
        //get Last Run job Details for check Estimate Date 
        //String whereClause = 'WHERE Name = \'Schedule Estimate\'';
        String whereClause = 'WHERE Name = \'' + System.Label.LoAp_ScheduleEstimate + '\'';
        List<CronTrigger> cronTriggerList = new List<CronTrigger>();
        List<CronJobDetail> cronJobDetailList = (List<CronJobDetail>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsCronJobDetail.CronJobDetailAPINAME,
                                                                                                         cronJobDetailsFields,
                                                                                                         whereClause);
        if(!cronJobDetailList.isEmpty()){
            cronTriggerList = (List<CronTrigger>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsCronTrigger.CronTriggerAPINAME,
                                                                                     cronTriggerFields,
                                                                                     cronJobDetailList[0].Id,
                                                                                     GlUt_APIConstantsCronJobDetail.CronJobDetailIdAPINAME);
            
        }  
        
        List<ReadingMode__c> readingModeEstimateList = new List<ReadingMode__c>();
        //get Reading Mode records where mode = 'Estimate' and Estimate date <= Todays and Estimate date >= Last Run Date
        if(!cronTriggerList.isEmpty()){
            DateTime lastRunDT = cronTriggerList[0].PreviousFireTime;
            Date lastRun = date.today();
            if(lastRunDT != null){
                lastRun = date.newinstance(lastRunDT.year(), lastRunDT.month(), lastRunDT.day());
            }
            readingModeEstimateList = [SELECT Id, 
                                       Name,
                                       Book__c,
                                       Depot__c,
                                       Area__c,
                                       ReadPeriod__c,
                                       EstimateDate__c, 
                                       CreatedDate 
                                       FROM ReadingMode__c
                                       WHERE Mode__c = :CuAp_Constants.ESTIMATE 
                                       AND EstimateDate__c <= :Date.today() 
                                       AND EstimateDate__c >= :lastRun];
        }
      
        // using the set<Id> update the values of reading period to the set 
        for(ReadingMode__c objRM : readingModeEstimateList){
            estimateReadPeriodIds.add(objRM.ReadPeriod__c);
            if(objRM.Book__c != null){
                mapOfBook2EstimateReadingMode.put(objRM.Book__c,objRM); 	// Book Id - Reading Mode (Estimated)
            }            
            else if(objRM.Depot__c != null){
                mapOfDepot2EstimateReadingMode.put(objRM.Depot__c,objRM); 	// Depot Id - Reading Mode (Estimated)
            }
            else if(objRM.Area__c != null){
                mapOfArea2EstimateReadingMode.put(objRM.Area__c,objRM); 	// Area Id - Reading Mode (Estimated)
            }         
        }
        
        // Get all the Area detils by Area Id from Map mapOfArea2EstimateReadingMode
        List<Area__c> areaList = [SELECT
                                 Id,
                                 Name
                                 FROM Area__c
                                 WHERE Id=:mapOfArea2EstimateReadingMode.keySet()];
        for(Area__c objArea: areaList){
            mapOfAreaId2AreaDetails.put(objArea.Id,objArea);
        }
        
        // Get all the Book detils by Book Id from Map mapOfBook2EstimateReadingMode
        List<Book__c> bookList = [SELECT
                                 Id,
                                 Name
                                 FROM Book__c
                                 WHERE Id=:mapOfBook2EstimateReadingMode.keySet()];
        for(Book__c objBook: bookList){
            mapOfBookId2BookDetails.put(objBook.Id,objBook);
        }
        
        // Get all the Depot detils by Depot Id from Map mapOfDepot2EstimateReadingMode
        List<Depot__c> depotList = [SELECT 
                                   Id,
                                   Name 
                                   FROM Depot__c
                                   WHERE Id = :mapOfDepot2EstimateReadingMode.keySet()];
        for(Depot__c objDepot: depotList){
            mapOfDepotId2DepotDetails.put(objDepot.Id,objDepot);
        }
        
        List<ReadingMode__c> readingModeActualList = new List<ReadingMode__c>();
        
        if(!estimateReadPeriodIds.isEmpty()){
            readingModeActualList = [SELECT Id, 
                                     Area__c,
                                     Book__c,
                                     Depot__c
                                     FROM ReadingMode__c 
                                     WHERE Mode__c = :System.Label.LoBt_ActualLabel
                                     AND ReadPeriod__c IN :estimateReadPeriodIds];                
        }
        
        //Area, Book and Depot to Reading Mode Map
        Map<Id,Id> mapOfBook2ActualReadingMode 	= new Map<Id,Id>();
        Map<Id,Id> mapOfDepot2ActualReadingMode = new Map<Id,Id>();
        Map<Id,Id> mapOfArea2ActualReadingMode	= new Map<Id,Id>();
        for(ReadingMode__c objRM : readingModeActualList){
            if(objRM.Area__c != null){
                mapOfArea2ActualReadingMode.put(objRM.Area__c,objRM.Id);
            }
            else if(objRM.Book__c != null){
                mapOfBook2ActualReadingMode.put(objRM.Book__c,objRM.Id);
            }
            else if(objRM.Depot__c != null){
                mapOfDepot2ActualReadingMode.put(objRM.Depot__c,objRM.Id);
            }            
        }
        // RM --> Area --> Depot --> SP
        Set<Id> depotIdsViaArea = new Set<Id>();
        List<Depot__c > depotListByAreaId = [SELECT Id,
                                     Area__c
                                     FROM Depot__c 
                                     WHERE Area__c IN: mapOfArea2EstimateReadingMode.keySet()];
       
        for(Depot__c objDepot : depotListByAreaId){
            depotIdsViaArea.add(objDepot.Id);
            mapOfDepotId2AreaId.put(objDepot.Id,objDepot.Area__c);
        }
        
        List<SupplyPoint__c >supplyPointEstimateModeList = [SELECT Id, 
                                                            Name,
                                                            Book__c,
                                                            Depot__c,
                                                            ExcludeFromEstimation__c
                                                            FROM SupplyPoint__c 
                                                            WHERE (Book__c IN: mapOfBook2EstimateReadingMode.keySet() OR 
                                                                   Depot__c IN: mapOfDepot2EstimateReadingMode.keySet() OR
                                                                   Depot__c IN: depotIdsViaArea)];
        
        //Fetch Scheduled Read associated with S.P for current period of Reading Mode
        Map<Id,ScheduledRead__c> mapOfReadPeriod2ScheduledRead = new Map<Id,ScheduledRead__c>(); //Even though one Read period Can have multiple Schedule Read but we need only one to flag whether SR exist for S.P or not
        
        List<ScheduledRead__c> scheduleReadList = [SELECT Id,
                                                   ReadPeriod__c
                                                   FROM ScheduledRead__c 
                                                   WHERE ReadPeriod__c IN:estimateReadPeriodIds]; // Fetch SR for estimated Reading Mode having Read Period
        for(ScheduledRead__c sr: scheduleReadList){
            mapOfReadPeriod2ScheduledRead.put(sr.ReadPeriod__c,sr);
        }
      
            
        //Map<Id,Id> mapOfSPId2DeviceId = new Map<Id,Id>();
        if(!supplyPointEstimateModeList.isEmpty()){
            List<SupplyPointDevice__c> spdList = [SELECT Id,
                                                  Device__c,
                                                  SupplyPoint__c
                                                  FROM SupplyPointDevice__c 
                                                  WHERE SupplyPoint__c IN:supplyPointEstimateModeList AND Active__c = True];
            
            for(SupplyPointDevice__c spd : spdList){
                mapOfSPId2DeviceId.put(spd.SupplyPoint__c,spd.Device__c);
                mapOfSupplyPointId2SPD.put(spd.SupplyPoint__c,spd);
            }
            
            List<AverageDailyUsage__c> lstADU = [select Id,
                                               AverageDailyUsage__c,
                                               SupplyPointDevice__c,
                                               StartDate__c,
                                               EndDate__c
                                               from AverageDailyUsage__c
                                               where SupplyPointDevice__c = :mapOfSupplyPointId2SPD.values()];
            
            for(AverageDailyUsage__c objADU :lstADU){
                if(!spdId2ADUListMap.containsKey(objADU.SupplyPointDevice__c)){
                    spdId2ADUListMap.put(objADU.SupplyPointDevice__c, new List<AverageDailyUsage__c>());
                }       
                spdId2ADUListMap.get(objADU.SupplyPointDevice__c).add(objADU);                        
            }
        }
     
        List<Reading__c> billableReadingList = [SELECT Id,
                                                ReadingDate__c,
                                                BillableType__c,
                                                ActualDeviceReading__c,
                                                Device__c
                                                FROM Reading__c 
                                                WHERE BillableType__c = :System.Label.BlIn_BillCalculationTypeBillable
                                                AND Device__c IN: mapOfSPId2DeviceId.values()
                                                ORDER BY ReadingDate__c DESC];
        
        for(Reading__c reading: billableReadingList){
            if(!mapOfDeviceId2Reading.containsKey(reading.Device__c)){
                mapOfDeviceId2Reading.put(reading.Device__c,new List<Reading__c>());
            }
            mapOfDeviceId2Reading.get(reading.Device__c).add(reading);
        }

        List<Device__c> deviceList = [SELECT Id,
                                      Digit__c,
                                      SerialNo__c
                                      FROM Device__c 
                                      WHERE Id IN :mapOfDeviceId2Reading.keySet()];
        for(Device__c objDevice : deviceList){
            mapOfDeviceId2Device.put(objDevice.Id,objDevice);
        }
        
        List<ReadPeriod__c> readPeriodList = [SELECT Id,
                                              ReadStart__c,
                                              ReadEnd__c
                                              FROM ReadPeriod__c 
                                              WHERE Id IN:estimateReadPeriodIds];
        
        //Map<Id,ReadPeriod__c> mapOfReadPeriodId2ReadPeriod = new Map<Id,ReadPeriod__c>();
        for(ReadPeriod__c rp: readPeriodList){
            mapOfReadPeriodId2ReadPeriod.put(rp.Id,rp);
        }
        
        Map<Id,SupplyPoint__c> spToExclude = new Map<Id,SupplyPoint__c>();
        for(SupplyPoint__c  objSp: supplyPointEstimateModeList){
            // If the Area is at estimate level then check Book and Depot with Actual level
            if(mapOfDepotId2AreaId.containsKey(objSp.Depot__c)){
                Id areaId = mapOfDepotId2AreaId.get(objSp.Depot__c);
                if(mapOfArea2EstimateReadingMode.containsKey(areaId)){
                    if(mapOfDepot2ActualReadingMode.containsKey(objSp.Depot__c) || mapOfBook2ActualReadingMode.containsKey(objSp.Book__c)){
                        spToExclude.put(objSp.Id,objSp);
                        createBatchError(batchRequestQueue.Id, mapOfArea2EstimateReadingMode.get(areaId).Id,System.Label.LoBt_EstimateAtArealevel);  //AT-3082
                    }
                }
            }            
            
            // if the depot is at estimate level then check the book with Actual level
            if(mapOfDepot2EstimateReadingMode.containsKey(objSp.Depot__c)){
                if(mapOfBook2ActualReadingMode.containsKey(objSp.Book__c)){
                    spToExclude.put(objSp.Id,objSp);
                    createBatchError(batchRequestQueue.Id,  mapOfDepot2EstimateReadingMode.get(objSp.Depot__c).Id, System.Label.LoBt_EstimateAtDepotLevel);  //AT-3082
                }
            }            
            
            // SP --> Book --> RM --> RP
            if(mapOfBook2EstimateReadingMode.containsKey(objSp.Book__c)){
                Id readPeriodId = mapOfBook2EstimateReadingMode.get(objSp.Book__c).ReadPeriod__c;
                if(!mapOfReadPeriod2ScheduledRead.isEmpty() && mapOfReadPeriod2ScheduledRead.containsKey(readPeriodId)){
                    spToExclude.put(objSp.Id,objSp);
                     //Scheduled reading is associated with the Supply Point  for the Current Period
                    createBatchError(batchRequestQueue.Id,  objSp.Id,System.Label.LoBt_SchdReadingWithSP);  //AT-3082
                }
            }
            
            
            // SP --> Depot --> RM --> RP
            if(mapOfDepot2EstimateReadingMode.containsKey(objSp.Depot__c)){
                Id readPeriodId = mapOfDepot2EstimateReadingMode.get(objSp.Depot__c).ReadPeriod__c;
                if(!mapOfReadPeriod2ScheduledRead.isEmpty() && mapOfReadPeriod2ScheduledRead.containsKey(readPeriodId)){
                    spToExclude.put(objSp.Id,objSp);
                    createBatchError(batchRequestQueue.Id,  objSp.Id,System.Label.LoBt_SchdReadingWithSP);  //AT-3082
                }
            }
            
            // SP --> Depot --> Area --> RM --> RP
            if(mapOfDepotId2AreaId.containsKey(objSp.Depot__c)){
                Id areaId = mapOfDepotId2AreaId.get(objSp.Depot__c);
                if(mapOfArea2EstimateReadingMode.containsKey(areaId)){
                    Id readPeriodId = mapOfArea2EstimateReadingMode.get(areaId).ReadPeriod__c;
                    if(!mapOfReadPeriod2ScheduledRead.isEmpty() && mapOfReadPeriod2ScheduledRead.containsKey(readPeriodId)){
                        spToExclude.put(objSp.Id,objSp);
                         //Scheduled reading is associated with the Supply Point  for the Current Period
                        createBatchError(batchRequestQueue.Id,  objSp.Id,System.Label.LoBt_SchdReadingWithSP);  //AT-3082
                    }
                } 
            }
            //Check if there is already a Billable reading associated with the Supply Point for the Current Period.
            if(mapOfSPId2DeviceId.containsKey(objSp.Id)){
                if(mapOfDeviceId2Reading.containsKey(mapOfSPId2DeviceId.get(objSp.Id))){
                    List<Reading__c> readingList =  mapOfDeviceId2Reading.get(mapOfSPId2DeviceId.get(objSp.Id));
                    Id readPeriodId;
                    // SP --> Book --> RM --> RP
                    if(objSp.Book__c != null && mapOfBook2EstimateReadingMode.containsKey(objSp.Book__c)){
                        readPeriodId = mapOfBook2EstimateReadingMode.get(objSp.Book__c).ReadPeriod__c;
                    }
                    // SP --> Depot --> RM --> RP
                    if(readPeriodId == null && objSp.Depot__c != null){
                        if(mapOfDepot2EstimateReadingMode.containsKey(objSp.Depot__c))
                            readPeriodId = mapOfDepot2EstimateReadingMode.get(objSp.Depot__c).ReadPeriod__c;
                        if(readPeriodId == null){
                            // SP --> Depot --> Area --> RM --> RP
                            if(mapOfDepotId2AreaId.containsKey(objSp.Depot__c)){
                                Id areaId = mapOfDepotId2AreaId.get(objSp.Depot__c);
                                if(mapOfArea2EstimateReadingMode.containsKey(areaId)){
                                    readPeriodId = mapOfArea2EstimateReadingMode.get(areaId).ReadPeriod__c;
                                }
                            }
                        }
                    } 
                    
                    if(readPeriodId != null && readingList != null){
                        for(Reading__c Reading : readingList){
                           
                            if(Reading.ReadingDate__c >= mapOfReadPeriodId2ReadPeriod.get(readPeriodId).ReadStart__c && 
                               Reading.ReadingDate__c <= mapOfReadPeriodId2ReadPeriod.get(readPeriodId).ReadEnd__c){
                                   spToExclude.put(objSp.Id,objSp);
                                   createBatchError(batchRequestQueue.Id,  objSp.Id,System.Label.LoBt_BillableReadingWithSP);  //AT-3082
                                   break;
                               }
                        }
                    } 
                }
            }
            else{
                // Exclude the Supply Point if not associated with the device
                spToExclude.put(objSp.Id,objSp);
                createBatchError(batchRequestQueue.Id,  objSp.Id,  System.Label.LoBt_DeviceNotFound);  //AT-3082
            }
            
            //Supply Point marked as Exclude from Estimation
            if(objSp.ExcludeFromEstimation__c){
                spToExclude.put(objSp.Id,objSp);
                createBatchError(batchRequestQueue.Id,  objSp.Id,System.Label.LoBt_SPExcludedEstimation);  //AT-3082
            }
        }
        
        //Get Final List of Supply Points
        Set<Id> spListToEstimate = new Set<Id>();
        for(SupplyPoint__c allSP: supplyPointEstimateModeList){
            if(!spToExclude.containsKey(allSP.Id)){
                spListToEstimate.add(allSP.Id);
            }
        }
        
        //Fetch the supply point on the basis parse book ids.
        sQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(supplyPointFields,','), 
            GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME +' WHERE ' + 
            GlUt_APIConstantsSupplyPoint.Id + ' IN:spListToEstimate'});
        return Database.getQueryLocator(sQuery);
    } 
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){        
        List<SupplyPoint__c> supplyPointList = (List<SupplyPoint__c>) scope;
        Id deviceId;
        Id areaId;
        ReadingMode__c objRM;
        ReadingMode__c finalReadingMode;
        Reading__c readingPriorToEstimate;
        Decimal aduOnEstimateDate;
        Integer formulaResult;
        ReadPeriod__c objRP;
        Date readingModeEstimateDate;
        DateTime createdDate;
        String averageDailyUsage;
        String estimatedString;
        Boolean tripped = false;
        Map<Id,ReadingMode__c> mapOfDeviceId2ReadingMode = new Map<Id,ReadingMode__c>();
        
        List<Reading__c> readingsToInsert = new List<Reading__c>();
        List<ScheduledRead__c> scheduleReadToInsert = new List<ScheduledRead__c>();
        
        for(SupplyPoint__c objSP: supplyPointList){
            
            if(!mapOfSupplyPointId2SupplyPointDetails.containsKey(objSP.Id))
                mapOfSupplyPointId2SupplyPointDetails.put(objSP.Id, objSP);
            
            // Reset the variable to prevent previous updated values used in the next iteration.
            estimatedString = '';
            areaId = null;
            createdDate = null;
            readingModeEstimateDate = null;
            deviceId = null;
            readingPriorToEstimate = null;
            finalReadingMode = null;
            tripped = false;
            
            // SP --> Book --> RM --> RP
            if(mapOfBook2EstimateReadingMode.containsKey(objSP.Book__c)){
                objRM = mapOfBook2EstimateReadingMode.get(objSP.Book__c);
                if(mapOfReadPeriodId2ReadPeriod.containsKey(objRM.ReadPeriod__c)){
                    objRP = mapOfReadPeriodId2ReadPeriod.get(objRM.ReadPeriod__c);
                    if(objRP.ReadStart__c <= objRM.EstimateDate__c && objRP.ReadEnd__c >= objRM.EstimateDate__c){
                        readingModeEstimateDate = objRM.EstimateDate__c;
                        createdDate = mapOfBook2EstimateReadingMode.get(objSP.Book__c).CreatedDate;
                        estimatedString = System.Label.LoBt_BookLabel;
                        finalReadingMode = objRM; // for device and Reading mode mapping
                        
                    }
                }
            }
            
            // SP --> Deopt --> RM --> RP
            if(mapOfDepot2EstimateReadingMode.containsKey(objSP.Depot__c)){
                objRM = mapOfDepot2EstimateReadingMode.get(objSP.Depot__c);
                if(mapOfReadPeriodId2ReadPeriod.containsKey(objRM.ReadPeriod__c)){
                    objRP = mapOfReadPeriodId2ReadPeriod.get(objRM.ReadPeriod__c);
                    if(createdDate == null || (objRP.ReadStart__c <= objRM.EstimateDate__c && objRP.ReadEnd__c >= objRM.EstimateDate__c && objRM.CreatedDate > createdDate)){
                        readingModeEstimateDate = objRM.EstimateDate__c;
                        createdDate = mapOfDepot2EstimateReadingMode.get(objSP.Depot__c).CreatedDate;
                        estimatedString = System.Label.LoBt_DepotLabel;
                        finalReadingMode = objRM; // for device and Reading mode mapping
                        
                    }
                }
            }
            
            // SP --> Depot --> Area --> RM --> RP
            if(mapOfDepotId2AreaId.containsKey(objSP.Depot__c)){
                areaId = mapOfDepotId2AreaId.get(objSP.Depot__c);
                if(mapOfArea2EstimateReadingMode.containsKey(areaId)){
                    objRM = mapOfArea2EstimateReadingMode.get(areaId);
                    if(mapOfReadPeriodId2ReadPeriod.containsKey(objRM.ReadPeriod__c)){
                        objRP = mapOfReadPeriodId2ReadPeriod.get(objRM.ReadPeriod__c);
                        if(createdDate == null || (objRP.ReadStart__c <= objRM.EstimateDate__c && objRP.ReadEnd__c >= objRM.EstimateDate__c && objRM.CreatedDate > createdDate)){
                            readingModeEstimateDate = objRM.EstimateDate__c;
                            createdDate = mapOfArea2EstimateReadingMode.get(areaId).CreatedDate;
                            estimatedString = System.Label.LoBt_AreaLabel;
                            finalReadingMode = objRM; // for device and Reading mode mapping
                        }
                    }
                }
            }
            
            // SP --> Device --> Reading
            if(mapOfSPId2DeviceId.containsKey(objSP.Id) && readingModeEstimateDate != null){
                deviceId = mapOfSPId2DeviceId.get(objSP.Id);
                if(mapOfDeviceId2Reading.containsKey(deviceId)){
                    for(Reading__c objReading : mapOfDeviceId2Reading.get(deviceId)){
                        mapOfDeviceId2ReadingMode.put(deviceId,finalReadingMode);                        
                        if(objReading.ReadingDate__c < readingModeEstimateDate){
                            readingPriorToEstimate = objReading;
                            break;
                        }
                    }
                }
            } 
           
            // SP --> SPD --> ADU            
            if(mapOfSupplyPointId2SPD.containsKey(objSP.Id)){
                Id supplyPointDevice = mapOfSupplyPointId2SPD.get(objSP.Id).Id;
                if(spdId2ADUListMap.containsKey(supplyPointDevice)){
                    for(AverageDailyUsage__c objADU :spdId2ADUListMap.get(supplyPointDevice)){
                        if (objADU.StartDate__c <= readingModeEstimateDate && (objADU.EndDate__c == null || objADU.EndDate__c >= readingModeEstimateDate)){
                            aduOnEstimateDate = objADU.AverageDailyUsage__c;
                            break;
                        }
                    
                    }
                }
            } 

            if(readingPriorToEstimate == null) {
                if(mapOfSupplyPointId2SPD.containsKey(objSP.Id))
                    createBatchError(batchRequestQueue.Id, mapOfSupplyPointId2SPD.get(objSP.Id).Id, System.Label.LoBt_ReadingNotFoundPrior);  //AT-3082
            }

            
            if(aduOnEstimateDate == null) {
                if(mapOfSupplyPointId2SPD.containsKey(objSP.Id))
                    createBatchError(batchRequestQueue.Id, mapOfSupplyPointId2SPD.get(objSP.Id).Id,System.Label.LoAp_ADUInvalid);  //AT-3082
            }
            
            // Formula
            if(readingModeEstimateDate != null && aduOnEstimateDate != null && readingPriorToEstimate != null){
                Integer daysDiff = readingPriorToEstimate.ReadingDate__c.daysBetween(readingModeEstimateDate);
                formulaResult = Integer.valueOf((Integer.valueOf(readingPriorToEstimate.ActualDeviceReading__c) + daysDiff * aduOnEstimateDate).setScale(2));
                averageDailyUsage = String.valueOf(formulaResult);

                
                if(averageDailyUsage.length() != mapOfDeviceId2Device.get(deviceId).Digit__c){
                    Integer digitDiff = Integer.valueOf(mapOfDeviceId2Device.get(deviceId).Digit__c) - averageDailyUsage.length();
                    if (digitDiff > 0) {
                        for(Integer i = 0; i < digitDiff; i++){
                            averageDailyUsage = '0' + averageDailyUsage;
                        }
                    }
                    else{
                        averageDailyUsage = averageDailyUsage.right(Integer.valueOf(mapOfDeviceId2Device.get(deviceId).Digit__c));
                        tripped = true;
                    }
                }
                
                //Create a Reading Record associated with the Device and Supply Point
                if(!mapOfDeviceId2FormulaValue.containsKey(deviceId))
                    mapOfDeviceId2FormulaValue.put(deviceId,averageDailyUsage);
                
                Reading__c objReading = new Reading__c();
                objReading.Device__c = deviceId;
                objReading.ActualDeviceReading__c = averageDailyUsage;
                objReading.ReadingDate__c = System.today();                                
                objReading.Tripped__c = tripped; 
                objReading.ReadingSource__c = LoBt_Constants.COMPANYREADING;
                objReading.ReadingMethod__c = LoBt_Constants.SYSTEMESTIMATED;
                objReading.ReadingType__c = LoBt_Constants.READINGTYPEREGULAR;
                readingsToInsert.add(objReading);
                
                if(estimatedString == System.Label.LoBt_BookLabel){
                    if(!BookId2SupplyPointListMap.containsKey(objSP.Book__c)){
                        BookId2SupplyPointListMap.put(objSP.Book__c,new List<SupplyPoint__c>());
                    }
                    BookId2SupplyPointListMap.get(objSP.Book__c).add(objSP);
                }
                else if(estimatedString == System.Label.LoBt_DepotLabel){
                    if(!DepotId2SupplyPointListMap.containsKey(objSP.Depot__c)){
                        DepotId2SupplyPointListMap.put(objSP.Depot__c,new List<SupplyPoint__c>());
                    }
                    DepotId2SupplyPointListMap.get(objSP.Depot__c).add(objSP);
                }
                else if(estimatedString == System.Label.LoBt_AreaLabel && areaId != null){
                    if(!AreaId2SupplyPointListMap.containsKey(areaId)){
                        AreaId2SupplyPointListMap.put(areaId,new List<SupplyPoint__c>());
                    }
                    AreaId2SupplyPointListMap.get(areaId).add(objSP);
                }
            }            
        }
        
        if(!readingsToInsert.isEmpty())
            readingsToInsert = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(readingsToInsert, false);
            insert readingsToInsert;
        
        
        if(!readingsToInsert.isEmpty()){
            for(Reading__c objReading : readingsToInsert){
                //Create a Scheduled reading against the associated Read Period, Reading Mode and Reading - Schedule Estimates
                ScheduledRead__c objSR = new ScheduledRead__c();
                objSR.ReadPeriod__c = mapOfDeviceId2ReadingMode.get(objReading.Device__c).ReadPeriod__c;
                objSR.ReadingMode__c = mapOfDeviceId2ReadingMode.get(objReading.Device__c).Id;
                objSR.Reading__c = objReading.Id;
                objSR.Type__c = System.Label.LoBt_ScheduledLabel;
                scheduleReadToInsert.add(objSR);
            }
            scheduleReadToInsert = (List<ScheduledRead__c>) GlUt_FieldSecurity.cleanseFields(scheduleReadToInsert, false);
            insert scheduleReadToInsert;
        }
    }    
    
    global void finish(Database.BatchableContext bc){
        Savepoint sp = Database.setSavepoint();
        try{ 
            Integer iCount = 1;
            if(BookId2SupplyPointListMap.size() > 0 || DepotId2SupplyPointListMap.size() > 0 || AreaId2SupplyPointListMap.size() > 0){
                //Fetch the Library name for environmental setting meta data.
                String MeterBookLibraryName;
                /*for (EnvironmentSettings__mdt env : [SELECT ExportBooksLibrary__c 
                                                     FROM EnvironmentSettings__mdt LIMIT 1]) {
                                                         MeterBookLibraryName = env.ExportBooksLibrary__c;
                                                     }*/
                
                
               EnvironmentSettings__mdt mdtEnvSetting = GlUt_CustomMetaDataUtility.getEnviromentSettingDetails(GlUt_Constants.ENVIROMENTSETTINGBOOKIMPORTQUERY);
                if (mdtEnvSetting != null && string.isNotBlank(mdtEnvSetting.ExportBooksLibrary__c)) {
                    MeterBookLibraryName = mdtEnvSetting.ExportBooksLibrary__c;
                }
               /* Datetime systemToday = System.now();
                String timeZone = UserInfo.getTimeZone().getID();
                String todate = systemToday.format('yyyy-MM-dd hh:mm:ss',timeZone);*/
                
                string exportFileName =  System.Label.LoBt_ExportFilePrefix+'_'+System.now().format('yyyy-MM-dd hh:mm:ss',UserInfo.getTimeZone().getID()) +'.txt';
                String txtContent = '';
                for(Id bookId: BookId2SupplyPointListMap.keySet()){
                    
                    txtContent = LoBt_Constants.BOOKNAME + mapOfBookId2BookDetails.get(bookId).Name + ', ' + 
                        LoBt_Constants.TOTALSUPPLYPOINTS + BookId2SupplyPointListMap.get(bookId).size() + '\n';
                    
                    for(SupplyPoint__c objSP : BookId2SupplyPointListMap.get(bookId)){
                        txtContent = txtContent + LoBt_Constants.SUPPLYPOINT + String.valueOf(iCount) + ': ' + 
                            mapOfSupplyPointId2SupplyPointDetails.get(objSP.Id).Name + ', ' + 
                            mapOfSupplyPointId2SupplyPointDetails.get(objSP.Id).Location__r.Address__c + ', ' + 
                            mapOfDeviceId2Device.get(mapOfSPId2DeviceId.get(objSP.Id)).SerialNo__c + ', ' + 
                            mapOfDeviceId2FormulaValue.get(mapOfSPId2DeviceId.get(objSP.Id)) + '\n';
                        iCount = iCount + 1;
                    }
                    
                } 
                iCount = 1;
                txtContent = txtContent + '\n';
                for(Id depotId: DepotId2SupplyPointListMap.keySet()){                    
                    
                    txtContent = txtContent + LoBt_Constants.DEPOTNAME + mapOfDepotId2DepotDetails.get(depotId).Name + ', ' + 
                        LoBt_Constants.TOTALSUPPLYPOINTS + DepotId2SupplyPointListMap.get(depotId).size() + '\n';
                    
                    for(SupplyPoint__c objSP : DepotId2SupplyPointListMap.get(depotId)){
                        txtContent = txtContent + LoBt_Constants.SUPPLYPOINT + String.valueOf(iCount) + ': ' + 
                            mapOfSupplyPointId2SupplyPointDetails.get(objSP.Id).Name + ', ' + 
                            mapOfSupplyPointId2SupplyPointDetails.get(objSP.Id).Location__r.Address__c + ', ' + 
                            mapOfDeviceId2Device.get(mapOfSPId2DeviceId.get(objSP.Id)).SerialNo__c + ', ' + 
                            mapOfDeviceId2FormulaValue.get(mapOfSPId2DeviceId.get(objSP.Id)) + '\n';
                        iCount = iCount + 1;
                    }
                } 
                iCount = 1;
                txtContent = txtContent + '\n';
                for(Id areaId: AreaId2SupplyPointListMap.keySet()){
                    
                    txtContent = txtContent + LoBt_Constants.AREANAME + mapOfAreaId2AreaDetails.get(areaId).Name + ', ' + 
                        LoBt_Constants.TOTALSUPPLYPOINTS + AreaId2SupplyPointListMap.get(areaId).size() + '\n';
                    
                    for(SupplyPoint__c objSP : AreaId2SupplyPointListMap.get(areaId)){
                        txtContent = txtContent + LoBt_Constants.SUPPLYPOINT + String.valueOf(iCount) + ': ' + 
                            mapOfSupplyPointId2SupplyPointDetails.get(objSP.Id).Name + ', ' + 
                            mapOfSupplyPointId2SupplyPointDetails.get(objSP.Id).Location__r.Address__c + ', ' + 
                            mapOfDeviceId2Device.get(mapOfSPId2DeviceId.get(objSP.Id)).SerialNo__c + ', ' + 
                            mapOfDeviceId2FormulaValue.get(mapOfSPId2DeviceId.get(objSP.Id)) + '\n';
                        iCount = iCount + 1;
                    }                
                } 
                
                //Save the data in content file as txt.
                Id cdId =  GlUt_ContentDocument.saveLinkedDocument(batchRequestQueue.Id, MeterBookLibraryName, exportFileName, exportFileName, LoBt_Constants.SHARE_TYPE, blob.valueOf(txtContent));
                //if(cdId != null){
                    //Change the BRQ Status to Completed
                    //AT-3204 Starts Here
                    //AT-3204 Ends Here
                //}
            }
            
            if(batchErrorList != null && !batchErrorList.isEmpty())
                insert batchErrorList;
            
             LoBt_ExportBooksHelper.changeBRQStatus(batchRequestQueue.Id,LoBt_Constants.BRQSTATUS);
        }
        catch (exception e){
            GlUt_Logger.logException(e);
            Database.rollback(sp);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    } 
    
    
    /******************************************************************************
  	@author         Echo: Vivek Sethi   #AT-3082
	@date           25 March 2019
    @param          BatchRequestQueue__c batchRequestQueue
    @return         BatchError__c
    @description    create Batch Error record
	*******************************************************************************/
    public void createBatchError(Id BatchRequestQueueId, Id FailureRecordId, String ErrorDetails){        
        //create a Batch Error record 
        BatchError__c objBatchError;
        objBatchError = new BatchError__c(BatchRequestQueue__c = BatchRequestQueueId, 
                                          ErrorDetails__c =  ErrorDetails, 
                                          OperatingRecordId__c = FailureRecordId);
        batchErrorList.add(objBatchError); 
    }
     /******************************************************************************
    @author         Echo:Dependra Singh
    @date           11 Mar 2019
    @description    Method is used to set custom meta data  type data for Enviroment Setting.
    *******************************************************************************/
    /*private static EnvironmentSettings__mdt getEnviromentSettingDetails(){
        List<EnvironmentSettings__mdt> mdts = new  List<EnvironmentSettings__mdt>();
        if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap != null && GlUt_CustomMetaDataUtility.customMetadataRecordsMap.keyset().size()  > 0){
            if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap.containsKey(GlUt_Constants.ENVIROMENTSETTINGBOOKIMPORTQUERY)){
                mdts = (List<EnvironmentSettings__mdt>)GlUt_CustomMetaDataUtility.customMetadataRecordsMap.get(GlUt_Constants.ENVIROMENTSETTINGBOOKIMPORTQUERY);  
            }
            return mdts[0];
        }else{
            mdts = (List<EnvironmentSettings__mdt>) new GlUt_CustomMetaDataUtility().getCustomMetadataRecords(GlUt_Constants.ENVIROMENTSETTINGEXPORTLIBRARYQUERY);
            return mdts[0];
        }
    }*/
}