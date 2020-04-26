/******************************************************************************
@author         Echo: Swati Mathur
@date           29 May 2018
@description    Helper Class for Book Export Batch class(LoBt_SweepUpEstimates)
*******************************************************************************/
public with sharing class LoBt_SweepUpEstimatesHelper {    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           29 May 2018
    @param          List<SupplyPoint__c> SPsToEstimate, 
					Set<Id> setPeriodsToEstimate, 
                    List<Id> lstBookIds, 
                    Map<Id, List<SupplyPoint__c>> BookId2SupplyPointListMap
    @return         ContainerWrapper
    @description    method to execute main logic of batch execute method
    *******************************************************************************/
    public static ContainerWrapper executeMainLogic(List<SupplyPoint__c> SPsToEstimate, Set<Id> setPeriodsToEstimate, List<Id> lstBookIds, Map<Id, List<SupplyPoint__c>> BookId2SupplyPointListMap) {
        List<SupplyPoint__c> SupplyPointsToEstimate = new List<SupplyPoint__c>();
        Map<Id,ScheduledRead__c> supplyPointId2ScheduledReadMap = new Map<Id,ScheduledRead__c>();            
        Map<Id,ScheduledRead__c> readPeriodId2ScheduledReadMap = new Map<Id,ScheduledRead__c>(); 
        Map<Id,List<SupplyPoint__c>> readTimetableId2SupplyPointListMap = new Map<Id,List<SupplyPoint__c>>();
        Map<SupplyPoint__c,ReadPeriod__c> supplyPiont2readPeriodMap = new Map<SupplyPoint__c,ReadPeriod__c>();
        ContainerWrapper wrapper = new ContainerWrapper();

        
        try{
            for(ScheduledRead__c sr :[Select Id,
                                      ReadPeriod__c
                                      from ScheduledRead__c
                                      where ReadPeriod__c IN :setPeriodsToEstimate]){
                readPeriodId2ScheduledReadMap.put(sr.ReadPeriod__c,sr);
            }      
            
            
            for(SupplyPoint__c sp :SPsToEstimate){
                if(!readTimetableId2SupplyPointListMap.containsKey(sp.Book__r.ReadTimetable__c)){
                    readTimetableId2SupplyPointListMap.put(sp.Book__r.ReadTimetable__c, new List<SupplyPoint__c>());
                }       
                readTimetableId2SupplyPointListMap.get(sp.Book__r.ReadTimetable__c).add(sp); 
            }     
            
            List<ReadPeriod__c> lstReadPeriod = [Select Id,
                                                 ReadTimetable__c
                                                 from ReadPeriod__c
                                                 Where Id IN :setPeriodsToEstimate
                                                 and ReadTimetable__c IN :readTimetableId2SupplyPointListMap.keySet()]; 
            
            for(ReadPeriod__c rp : lstReadPeriod){
                if(readTimetableId2SupplyPointListMap.containsKey(rp.ReadTimetable__c)){
                    List<SupplyPoint__c> splist = readTimetableId2SupplyPointListMap.get(rp.ReadTimetable__c);                    
                    for(SupplyPoint__c sp :splist){
                        supplyPiont2readPeriodMap.put(sp,rp);
                    }
                }
            }
  
            for(SupplyPoint__c sp :SPsToEstimate){
                if(supplyPiont2readPeriodMap.containsKey(sp)){
                    ReadPeriod__c  objreadperiod = supplyPiont2readPeriodMap.get(sp);
                    if(readPeriodId2ScheduledReadMap.containsKey(objreadperiod.Id)){
                        ScheduledRead__c objScheduledRead = readPeriodId2ScheduledReadMap.get(objreadperiod.Id);
                        supplyPointId2ScheduledReadMap.put(sp.Id,objScheduledRead);
                    } 
                }
            }
         
            //Iterate through SPsToEstimate and for each Supply Point check to see if there is an associated ScheduledRead.
            for(SupplyPoint__c sp :SPsToEstimate){ 
                //If a Scheduled Reading does not exist for the associated Read Period and if the Supply Point is not marked as ‘Exclude From Estimate’   //ExcludeFromEstimation__c                  
                if(!supplyPointId2ScheduledReadMap.containsKey(sp.Id) && sp.ExcludeFromEstimation__c == false){
                    //add the Supply Point to SupplyPointsToEstimate
                    SupplyPointsToEstimate.add(sp);  
                }
            }
            
               system.debug('SupplyPointsToEstimate  '   +  SupplyPointsToEstimate);
            Map<Id,SupplyPointDevice__c> mapOfSupplyPointId2SPD = new Map<Id,SupplyPointDevice__c>();
            Map<Id,Reading__c> mapOfDeviceId2LastReadingByDate = new Map<Id,Reading__c>();
            Map<Id,List<AverageDailyUsage__c>> spdId2ADUListMap = new Map<Id,List<AverageDailyUsage__c>>();
            Map<Id,ReadingMode__c> readPeriodId2ReadingModeMap = new Map<Id,ReadingMode__c>();
            
            if(!SupplyPointsToEstimate.isEmpty()){
                List<SupplyPointDevice__c> spdList = [select Id,
                                                      Device__c,
                                                      Device__r.Digit__c,
                                                      SupplyPoint__c 
                                                      from SupplyPointDevice__c 
                                                      where SupplyPoint__c IN :SupplyPointsToEstimate AND Active__c = True];
                if(!spdList.isEmpty()){                    
                    Set<Id> deviceIds = new Set<Id>();
                    for(SupplyPointDevice__c spd: spdList){
                        mapOfSupplyPointId2SPD.put(spd.SupplyPoint__c,spd);
                        deviceIds.add(spd.Device__c);
                    }        
                    
                  
                    List<Reading__c> readingList = [select Id,
                                                    ReadingDate__c,
                                                    ActualDeviceReading__c,
                                                    Device__c
                                                    from Reading__c
                                                    where Device__c = :deviceIds 
                                                    ORDER BY ReadingDate__c DESC];
                    if(!readingList.isEmpty()){
                        for(Reading__c r: readingList){
                            if(!mapOfDeviceId2LastReadingByDate.containsKey(r.Device__c)){
                                mapOfDeviceId2LastReadingByDate.put(r.Device__c,r);
                            }
                        }
                    }    
                
                                   
                    List<ReadingMode__c> lstBookReadingMode = [select Id,
                                                               EstimateDate__c,
                                                               Book__c,
                                                               ReadPeriod__c
                                                               from ReadingMode__c 
                                                               where Book__c IN :lstBookIds];                
                    for(ReadingMode__c rm :lstBookReadingMode){
                       readPeriodId2ReadingModeMap.put(rm.ReadPeriod__c, rm);                        
                    }
                    
                     
                    List<AverageDailyUsage__c> lstADU = [select Id,
                                                       AverageDailyUsage__c,
                                                       SupplyPointDevice__c,
                                                       StartDate__c,
                                                       EndDate__c
                                                       from AverageDailyUsage__c
                                                       where SupplyPointDevice__c = :spdList];
                    
                    for(AverageDailyUsage__c adu :lstADU){
                        if(!spdId2ADUListMap.containsKey(adu.SupplyPointDevice__c)){
                            spdId2ADUListMap.put(adu.SupplyPointDevice__c, new List<AverageDailyUsage__c>());
                        }       
                        spdId2ADUListMap.get(adu.SupplyPointDevice__c).add(adu);                        
                    }
                }
            }

      
            List<Reading__c> readingsToInsert = new List<Reading__c>();
            List<ScheduledRead__c> scheduledReadsToInsert = new List<ScheduledRead__c>();
            List<ReadingMode__c> lstReadPeriodReadingMode = new List<ReadingMode__c>();
            
            Reading__c lastReading;
            Decimal aduOnEstimateDate;
        
            Date bookEstimateDate;
            String readingValue;
            Boolean tripped;
           
            for(SupplyPoint__c objSPToEstimate :SupplyPointsToEstimate){                
                readingValue = '';                
                bookEstimateDate = null;
                aduOnEstimateDate = 0.0;
                tripped = false;
                
                if(mapOfSupplyPointId2SPD.containsKey(objSPToEstimate.Id) && mapOfSupplyPointId2SPD.get(objSPToEstimate.Id)!= null){                    
                    SupplyPointDevice__c spd =  mapOfSupplyPointId2SPD.get(objSPToEstimate.Id);
                    
                    if(mapOfDeviceId2LastReadingByDate.containsKey(spd.Device__c) && spdId2ADUListMap.containsKey(spd.Id)){
                        //Find Last Reading Date for the supply point
                        
                        lastReading = mapOfDeviceId2LastReadingByDate.get(spd.Device__c);                        
                        //Find Estimate Date on Book of supply point
                        if(readPeriodId2ReadingModeMap.containsKey(supplyPiont2readPeriodMap.get(objSPToEstimate).Id)){
                            bookEstimateDate = readPeriodId2ReadingModeMap.get(supplyPiont2readPeriodMap.get(objSPToEstimate).Id).EstimateDate__c;                        
                            //Find Average Daily Usage that applies on Estimate Date on Book                        
                            for(AverageDailyUsage__c objADU :spdId2ADUListMap.get(spd.Id)){
                                if(objADU.StartDate__c <= bookEstimateDate){
                                    if(objADU.EndDate__c== null || objADU.EndDate__c >= bookEstimateDate){
                                        aduOnEstimateDate = objADU.AverageDailyUsage__c;
                                    }
                                }                                
                            }
                            //Estimate a new reading for the Device associated with the Supply Point using the following formula 
                            //(Estimate Date on Book – Last Reading Date) * Average Daily Usage that applies on Estimate Date on Book               
                            if(lastReading != null && bookEstimateDate != null && aduOnEstimateDate != null){
                                Integer daysDiff = lastReading.ReadingDate__c.daysBetween(bookEstimateDate);
                                String lastReadingValue =  lastReading.ActualDeviceReading__c; 
                                readingValue = String.valueOf(Integer.valueOf(lastReadingValue) + (daysDiff * aduOnEstimateDate).round());
                                //If digits of estimated reading is less than device digits
                                if(readingValue.length() != spd.Device__r.Digit__c){
                                    Integer digitDiff = Integer.valueOf(spd.Device__r.Digit__c - readingValue.length());
                                    if (digitDiff > 0) {
                                        for(Integer i = 0; i < digitDiff; i++){
                                            readingValue = '0' + readingValue;
                                        }
                                    }
                                    else{
                                        readingValue = readingValue.right(Integer.valueOf(spd.Device__r.Digit__c));
                                        tripped = true;
                                    }
                                    
                                }
                            }
                          
                            if(readingValue!= null && readingValue != ''){
                                //Create a Reading with this value against the Device    
                                Reading__c  objReading  = new Reading__c(ReadingDate__c = System.today(),
                                                                         Device__c= spd.Device__c,
                                                                         Tripped__c = tripped,
                                                                         ReadingSource__c = LoBt_Constants.COMPANYREADING,
                                                                         ReadingMethod__c = LoBt_Constants.SYSTEMESTIMATED,
                                                                         ReadingType__c = LoBt_Constants.READINGTYPEREGULAR,
                                                                         ActualDeviceReading__c= readingValue);
                                readingsToInsert.add(objReading);  
                                //Create a Scheduled reading against the associated Reading Mode and Period,  Type – Sweep Up Estimate 
                                ScheduledRead__c objScheduledRead = new ScheduledRead__c(ReadPeriod__c= supplyPiont2readPeriodMap.get(objSPToEstimate).Id,
                                                                                         Type__c = LoBt_Constants.SWEEPUPTYPE,
                                                                                         ReadingMode__c = readPeriodId2ReadingModeMap.get(supplyPiont2readPeriodMap.get(objSPToEstimate).Id).Id);
                                scheduledReadsToInsert.add(objScheduledRead);                            
                                //Count the Number of Books Estimated and Supply Points Estimated per Book               
                                if(!BookId2SupplyPointListMap.containsKey(objSPToEstimate.Book__c)){
                                    BookId2SupplyPointListMap.put(objSPToEstimate.Book__c,new List<SupplyPoint__c>());
                                }
                                BookId2SupplyPointListMap.get(objSPToEstimate.Book__c).add(objSPToEstimate);
                            }
                        }              
                    }   
                }
            }
            
            wrapper.readingsToInsert = readingsToInsert;
            wrapper.scheduledReadsToInsert = scheduledReadsToInsert;
            wrapper.BookId2SupplyPointListMap = BookId2SupplyPointListMap;                     
        } 
        catch (exception e){
            GlUt_Logger.logException(e);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }    
        return wrapper;
    }
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           29 May 2018
    @description    Wrapper Class 
    *******************************************************************************/
    public class ContainerWrapper {
        public List<Reading__c> readingsToInsert; 
        public List<ScheduledRead__c> scheduledReadsToInsert;
        public Map<Id, List<SupplyPoint__c>> BookId2SupplyPointListMap;
    }
    
   /******************************************************************************
    @author         Echo: Swati Mathur
    @date           29 May 2018
    @param          Set<Id> setPeriodsToEstimate
    @return         BatchRequestQueue__c
    @description    Update the ReadPeriod SweepUpComplete field to True
    *******************************************************************************/
    public static List<ReadPeriod__c> updateReadPeriods(Set<Id> setPeriodsToEstimate){        
        List<ReadPeriod__c> lstReadPeriods = [select Id,
                                              SweepUpComplete__c
                                              from ReadPeriod__c 
                                              where Id IN :setPeriodsToEstimate];  
        for(ReadPeriod__c rp :lstReadPeriods){
            rp.SweepUpComplete__c = True;
        }
        if(!lstReadPeriods.isEmpty()){  
            lstReadPeriods = (List<ReadPeriod__c>) GlUt_FieldSecurity.cleanseFields(lstReadPeriods, false);
            update lstReadPeriods;
        }
        return lstReadPeriods;
    }    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           29 May 2018
    @param          BatchRequestQueue__c batchRequestQueue
    @return         BatchError__c
    @description    create Batch Error record
    *******************************************************************************/
    public static BatchError__c createBatchError(BatchRequestQueue__c batchRequestQueue ){        
        //create a Batch Error record 
        BatchError__c objBatchError = new BatchError__c(BatchRequestQueue__c = batchRequestQueue.Id, ErrorDetails__c = LoBt_Constants.INVALIDPARAMETERSERROR);
        objBatchError  = (BatchError__c) GlUt_FieldSecurity.cleanseFields(objBatchError, false);
        insert objBatchError;
        //update the Batch Request Queue Status to ‘Error’
        updateBRQ(new list<BatchRequestQueue__c> {batchRequestQueue},LoBt_Constants.BRQSTATUSERRORS);         // Checkmarx: bulkify
        return objBatchError;
    }
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           29 May 2018
    @param          BatchRequestQueue__c batchRequestQueue , String Status
    @return         BatchRequestQueue__c
    @description    create Batch Error record
    *******************************************************************************/
    public static list<BatchRequestQueue__c> updateBRQ(list<BatchRequestQueue__c> batchRequestQueueList , String Status){ // Checkmarx: bulkify
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
        if(!listBatchRequestQueueToUpdate.isEmpty()){
            listBatchRequestQueueToUpdate = (List<BatchRequestQueue__c>) GlUt_FieldSecurity.cleanseFields(listBatchRequestQueueToUpdate, false);
            update listBatchRequestQueueToUpdate ;
        }
       
        return listBatchRequestQueueToUpdate ;
    }
    /* Checkmarx
    public static BatchRequestQueue__c updateBRQ(BatchRequestQueue__c batchRequestQueue , String Status){	
        BatchRequestQueue__c objBRQ = [Select id,Status__c from BatchRequestQueue__c where Id = :batchRequestQueue.Id]; //SOQL is not required as BRQ is coming from BRQ Trigger context
        objBRQ.Status__c = Status;
        update objBRQ; 
        return objBRQ;
    }
	*/
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           29 May 2018
    @param          
    @return         List<Id> lstReadPeriodIds
    @description    scheduled Sweep Up
    *******************************************************************************/
    public static List<Id> scheduledSweepUp(){ 
        List<Id> lstReadPeriodIds = new List<Id>();
        //Query for Set<Id> PeriodsToEstimate Read Period records where Sweep Up Complete = false and Reading End Date <= Todays Date            
            List<ReadPeriod__c> lstReadPeriod = [Select Id
                                                 from ReadPeriod__c
                                                 Where SweepUpComplete__c = false
                                                 and ReadEnd__c <= :System.today()]; 
            
            List<ReadingMode__c> lstPeriodReadingMode = [Select Id,
                                                         EstimateDate__c,
                                                         Book__c,
                                                         ReadPeriod__c
                                                         from ReadingMode__c 
                                                         where ReadPeriod__c IN :lstReadPeriod
                                                         and Book__c!= null
                                                         and EstimateDate__c != null];
            
            for(ReadingMode__c rm : lstPeriodReadingMode){
                lstReadPeriodIds.add(rm.ReadPeriod__c);
            }
            return lstReadPeriodIds ;          
    }    
    
}