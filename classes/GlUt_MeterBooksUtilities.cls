/******************************************************************************
@author    		Echo: Amit K.
@date      		10 May 2018
@description 	Class for Meter Books utilities
@Revisions		N/A
*******************************************************************************/
public with sharing class GlUt_MeterBooksUtilities {
    private static final String CLASS_NAME = 'GlUt_MeterBooksUtilities';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    public static List<sObject> getRecordsFromIds(List<Id> Ids, List<String> Fields, string objectName,string parentField){
        List<sObject> recordList = new List<sObject>();
        if(!Ids.isEmpty()){
            recordList = (List<sObject>) GlAp_LightningDataAccess.getRecords(objectName, 
                                                                             Fields,
                                                                             String.format('WHERE {0} IN {1}',new List<String>{parentField,GlUt_FieldSecurity.IdsToString(Ids)})
                                                                            );
            
            System.debug(DEBUG+'*****recordList'+recordList);
        }
        return recordList;
    }
    /**********************************************************************************************
    @author      : Echo:Amit K.
    @date        : 08 May 2018
    @params      : List<Book__c> bookList, List<String> depotFields
    @return      : List<Depot__c>
    @description : This method returns Depots associated with Books. 
    **********************************************************************************************/
    public static List<Depot__c> getDepotFromBooks(List<Book__c> bookList, List<String> depotFields){
        List<Depot__c> depotList = new List<Depot__c>();
        List<Id> depotIds = new List<Id>();
        for(Book__c b : bookList){
            depotIds.add(b.Depot__c);
        }
        if(!depotIds.isEmpty()){
            depotList = (List<Depot__c>)GlUt_MeterBooksUtilities.getRecordsFromIds(depotIds,depotFields,GlUt_APIConstantsDepot.DEPOTAPINAME,GlUt_APIConstantsDepot.Id);
        }
        return depotList;
    }
    /**********************************************************************************************
    @author      : Echo:Amit K.
    @date        : 08 May 2018
    @params      : List<Depot__c> depotList, List<String> areaFields
    @return      : List<Area__c>
    @description : This method returns Area associated with Depots. 
    **********************************************************************************************/
    public static List<Area__c> getAreaFromDepots(List<Depot__c> depotList, List<String> areaFields){
        List<Area__c> areaList = new List<Area__c>();
        List<Id> areaIds = new List<Id>();
        for(Depot__c d: depotList){
            areaIds.add(d.Area__c);
        }
        if(!areaIds.isEmpty()){
            areaList = (List<Area__c>)GlUt_MeterBooksUtilities.getRecordsFromIds(areaIds,areaFields,GlUt_APIConstantsArea.AREAAPINAME,GlUt_APIConstantsArea.Id);
        }
        return areaList;
    }
    /**********************************************************************************************
    @author      : Echo:Amit K.
    @date        : 08 May 2018
    @params      : List<Id> periodIds, List<String> readingPeriodFields,List<String> bookFields
    @return      : List<Book__c>
    @description : This method returns Books associated with read periods. 
    **********************************************************************************************/
    public static List<Book__c> getBooksFromReadPeriods(List<Id> periodIds, List<String> readingPeriodFields,List<String> bookFields){
        List<Book__c> bookList = new List<Book__c>();
        List<ReadPeriod__c> readPeriodList = new List<ReadPeriod__c>();
        readPeriodList = GlUt_MeterBooksUtilities.getRecordsFromIds(periodIds,readingPeriodFields,GlUt_APIConstantsReadPeriod.READPERIODAPINAME,GlUt_APIConstantsReadingMode.ID);
        
        System.debug(DEBUG+'******readPeriodList'+readPeriodList);
        List<Id> readTimeTableIds = new List<Id>();
        for(ReadPeriod__c rp:readPeriodList){
            readTimeTableIds.add(rp.ReadTimeTable__c);
        }
        if(!readTimeTableIds.isEmpty()){
            bookList = (List<Book__c>)GlUt_MeterBooksUtilities.getRecordsFromIds(readTimeTableIds,bookFields,GlUt_APIConstantsBook.BOOKAPINAME,GlUt_APIConstantsBook.READTIMETABLEAPINAME);
        }
        System.debug(DEBUG+'******bookList'+bookList);
        return bookList;
    }
    /**********************************************************************************************
    @author      : Echo:Amit K.
    @date        : 08 May 2018
    @params      : List<String> readingPeriodFields,List<Book__c> selectedBooks,List<String> scheduledReadFields
    @return      : Map<Id,Integer>
    @description : This method returns Number of Reads per Book. 
    **********************************************************************************************/
    public static Map<Id,Integer> getNumberOfReadFromBook(List<String> readingPeriodFields,List<Book__c> selectedBooks,List<String> scheduledReadFields){
        List<Book__c> bookList = new List<Book__c>();
        List<ReadPeriod__c> readPeriodList = new List<ReadPeriod__c>();
        List<ScheduledRead__c> scheduledReadList = new List<ScheduledRead__c>();
        List<Id> timetableIds = new List<Id>();
        Map<Id,Integer> mapOfBookId2NumberOfRead = new Map<Id,Integer>();
        Map<Id,List<Id>> mapOfBookId2ScheduleReadId = new Map<Id,List<Id>>();
        Map<Id,Id> mapOfBookId2ReadTimeTableId = new Map<Id,Id>();
        Map<Id,List<Id>> mapOfReadTimeTable2ReadingPeriodId = new Map<Id,List<Id>>();
        Map<Id,List<Id>> mapOfReadPeriodId2ScheduledId = new Map<Id,List<Id>>();
        try{ 
            for(Book__c b: selectedBooks){
                timetableIds.add(b.ReadTimetable__c);
                mapOfBookId2ReadTimeTableId.put(b.Id,b.ReadTimetable__c); // map Of Book having Read Time Table
            }
            System.debug(DEBUG+'*****mapOfBookId2ReadTimeTableId'+mapOfBookId2ReadTimeTableId);
            readPeriodList = GlUt_MeterBooksUtilities.getRecordsFromIds(timetableIds,readingPeriodFields,GlUt_APIConstantsReadPeriod.READPERIODAPINAME,GlUt_APIConstantsReadPeriod.READTIMETABLEAPINAME);
            System.debug(DEBUG+'*****readPeriodList'+readPeriodList);
            if(!readPeriodList.isEmpty()){
                List<Id> readPeriodIds = new List<Id>();
                for(ReadPeriod__c rp: readPeriodList){
                    readPeriodIds.add(rp.Id);
                    if(!mapOfReadTimeTable2ReadingPeriodId.containsKey(rp.ReadTimetable__c)){
                        mapOfReadTimeTable2ReadingPeriodId.put(rp.ReadTimetable__c,new List<Id>());
                    }
                    mapOfReadTimeTable2ReadingPeriodId.get(rp.ReadTimetable__c).add(rp.id);  // map of Read Time Table having List of Reading Periods.
                }
                System.debug(DEBUG+'*****mapOfReadTimeTable2ReadingPeriodId'+mapOfReadTimeTable2ReadingPeriodId);
                //Fetch the Schedule Read on the basis of read periods.
                scheduledReadList =  GlUt_MeterBooksUtilities.getRecordsFromIds(readPeriodIds,scheduledReadFields,GlUt_APIConstantsScheduledRead.SCHEDULEDREADAPINAME,GlUt_APIConstantsScheduledRead.READPERIODAPINAME);
                System.debug(DEBUG+'*****scheduledReadList'+scheduledReadList);
                if(!scheduledReadList.isEmpty()){
                    for(ScheduledRead__c sch: scheduledReadList){
                        if (!mapOfReadPeriodId2ScheduledId.containsKey(sch.ReadPeriod__c)) {
                            mapOfReadPeriodId2ScheduledId.put(sch.ReadPeriod__c,new List<Id>());
                        }
                        mapOfReadPeriodId2ScheduledId.get(sch.ReadPeriod__c).add(sch.id); // map of Read Period having List Schedule Reads.
                    }
                }
                System.debug(DEBUG+'*****mapOfReadPeriodId2ScheduledId'+mapOfReadPeriodId2ScheduledId);
                Map<Id,List<Id>> mapOfTimeTableId2ScheduleId = new Map<Id,List<Id>>();
                for(Id bookId: mapOfBookId2ReadTimeTableId.keySet()){
                    Id readTimeTableId = mapOfBookId2ReadTimeTableId.get(bookId);
                    List<Id> periodId = mapOfReadTimeTable2ReadingPeriodId.get(readTimeTableId);
                    List<Id> scheduleReadIds = new List<Id>();
                    for(Id ids: periodId){
                        if(mapOfReadPeriodId2ScheduledId.containsKey(ids))
                            scheduleReadIds.addAll(mapOfReadPeriodId2ScheduledId.get(ids));
                    }
                    if(!scheduleReadIds.isEmpty())
                        mapOfBookId2ScheduleReadId.put(bookId,scheduleReadIds);  // map of Book having Schedule Read Id.
                }
                System.debug(DEBUG+'*****mapOfBookId2ScheduleReadId'+mapOfBookId2ScheduleReadId);
                if(!mapOfBookId2ScheduleReadId.isEmpty()){
                    for(Id bookId: mapOfBookId2ScheduleReadId.keySet()){
                        Integer size = mapOfBookId2ScheduleReadId.get(bookId).size();
                        mapOfBookId2NumberOfRead.put(bookId,size); // map of Book having Number of Schedule Reads.
                    }
                }
            }
            System.debug(DEBUG+'*****mapOfBookId2NumberOfRead'+mapOfBookId2NumberOfRead);
        }
        catch (exception e){
            GlUt_Logger.logException(e);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return mapOfBookId2NumberOfRead;
    }
    /**********************************************************************************************
    @author      : Echo:Amit K.
    @date        : 19 July 2018
    @params      : Id readingPeriodId,List<String> readPeriodFields
    @return      : ReadPeriod__c
    @description : This method returns Read Period Record on the basis of read period Id. 
    **********************************************************************************************/
    //Changes for AT-3040 Starts Here
    public static ReadPeriod__c getReadPeriod(Id readingPeriodId,List<String> readPeriodFields) {
        try {
            String filterStatement = 'WHERE ID =' + '\'' + readingPeriodId + '\''+' Limit 1';
            List<ReadPeriod__c> lstReadingPeriod =  GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReadPeriod.READPERIODAPINAME,
                                                                                       readPeriodFields,
                                                                                       filterStatement);
            if(lstReadingPeriod != null && !lstReadingPeriod.isEmpty())
                return lstReadingPeriod[0];
            else
                return null;
           
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }   
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    //Changes for AT-3040 Ends Here
}