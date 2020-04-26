/******************************************************************************
@author         Echo: Amit K.
@date           08 May 2018
@description    Component controller for Select Book to export lightning component
*******************************************************************************/
public with sharing class GlAp_SelectBookCtrlr {
    private static final String CLASS_NAME = 'GlAp_SelectBookCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static List<string> bookFields;
    static{
        bookFields = new List<string>();
        bookFields.add(GlUt_APIConstantsBook.NAME);
        bookFields.add(GlUt_APIConstantsBook.ID);
        bookFields.add(GlUt_APIConstantsBook.DEPOTAPINAME);
        bookFields.add(GlUt_APIConstantsBook.READTIMETABLEAPINAME);
    }
    private static List<string> readingModeFields;
    static{
        readingModeFields = new List<string>();
        readingModeFields.add(GlUt_APIConstantsReadingMode.NAME);
        readingModeFields.add(GlUt_APIConstantsReadingMode.ID);
        readingModeFields.add(GlUt_APIConstantsReadingMode.DEPOTAPINAME);
        readingModeFields.add(GlUt_APIConstantsReadingMode.AREAAPINAME);
        readingModeFields.add(GlUt_APIConstantsReadingMode.BOOKAPINAME);
        readingModeFields.add(GlUt_APIConstantsReadingMode.ESTIMATEDATEAPINAME);
    }
    private static List<string> readingPeriodFields;
    static{
        readingPeriodFields = new List<string>();
        readingPeriodFields.add(GlUt_APIConstantsReadPeriod.ID);
        readingPeriodFields.add(GlUt_APIConstantsReadPeriod.READTIMETABLEAPINAME);
    }
    private static List<string> depotFields;
    static{
        depotFields = new List<string>();
        depotFields.add(GlUt_APIConstantsDepot.ID);
        depotFields.add(GlUt_APIConstantsDepot.NAME);
        depotFields.add(GlUt_APIConstantsDepot.AREAAPINAME);
    }
    private static List<string> areaFields;
    static{
        areaFields = new List<string>();
        areaFields.add(GlUt_APIConstantsArea.ID);
        areaFields.add(GlUt_APIConstantsArea.NAME);
    }
    private static List<string> spFields;
    static{
        spFields = new List<string>();
        spFields.add(GlUt_APIConstantsSupplyPoint.BOOKAPINAME);
    }
    private static List<string> scheduledReadFields;
    static{
        scheduledReadFields = new List<string>();
        scheduledReadFields.add(GlUt_APIConstantsScheduledRead.Id);
        scheduledReadFields.add(GlUt_APIConstantsScheduledRead.READPERIODAPINAME);
    }
    /**********************************************************************************************
    @author      : Echo:Amit K.
    @date        : 08 May 2018
    @params      : None
    @return      : List<GLAp_FieldProps>
    @description : This method returns back Book,Depot,Area and Transform fields as List. 
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveBookPropDetails() {
        try {
            List<GLAp_FieldProps> bookProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsBook.BOOKAPINAME, bookFields);
            List<GLAp_FieldProps> depotProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDepot.DepotAPINAME, depotFields);
            List<GLAp_FieldProps> areaProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsArea.AreaAPINAME, areaFields);
            //Create Transform Field for Number of SupplyPoint having parent object Supply Point.
            GLAp_FieldProps spProp = new GLAp_FieldProps();
            spProp.isFLSVisible = true;
            spProp.isEncrypted  = false;
            spProp.isEditable   = false;
            spProp.isRequired   = false;
            spProp.fieldName    = GlUt_Constants.NUMBEROFSUPPLYPOINT;
            spProp.fieldLabel   = GlUt_Constants.NUMBEROFSUPPLYPOINT;
            spProp.fieldType    = GlUt_Constants.TEXT;
            spProp.transformField = true; 
            spProp.parentObject = GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME; 
            
            GLAp_FieldProps spPropNumberRead = new GLAp_FieldProps();
            spPropNumberRead.isFLSVisible = true;
            spPropNumberRead.isEncrypted  = false;
            spPropNumberRead.isEditable   = false;
            spPropNumberRead.isRequired   = false;
            spPropNumberRead.fieldName    = GlUt_Constants.NUMBEROFREAD;
            spPropNumberRead.fieldLabel   = GlUt_Constants.NUMBEROFREAD;
            spPropNumberRead.fieldType    = GlUt_Constants.TEXT;
            spPropNumberRead.transformField = true; 
            spPropNumberRead.parentObject = GlUt_APIConstantsBook.BOOKAPINAME;
            
            List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
            for (GLAp_FieldProps fldProp : bookProps) {
                if (fldProp.fieldName == GlUt_APIConstantsBook.NAME) {
                    fldProp.isEditable = false;
                    fldPropList.add(fldProp); 
                }
            }
            for (GLAp_FieldProps fldProp : depotProps) {
                if (fldProp.fieldName == GlUt_APIConstantsDepot.NAME) {
                    fldProp.isEditable = false;
                    fldPropList.add(fldProp); 
                }
            }
            for (GLAp_FieldProps fldProp : areaProps) {
                if (fldProp.fieldName == GlUt_APIConstantsArea.NAME) {
                    fldProp.isEditable = false;
                    fldPropList.add(fldProp); 
                }
            }
            //Add transform field to the property list
            fldPropList.add(spProp);
            fldPropList.add(spPropNumberRead);
            return fldPropList;
        }
        catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 08 May 2018
    @return      : List<BlAp_CombinedRecord>
    @param       : List<Id> periodIds,string screenName
    @description : This method returns the BlAp_CombinedRecord with list of --, and it's unique-ids, isSelected
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> getBooks(List<Id> periodIds,string screenName){
        List<BlAp_CombinedRecord>  bookCombinedList = new List<BlAp_CombinedRecord>();
        List<Book__c> bookList = new List<Book__c>();
        List<Depot__c> depotList = new List<Depot__c>();
        List<Book__c> SelectableBooksList = new List<Book__c>();
        List<ReadPeriod__c> readPeriodList = new List<ReadPeriod__c>();
        List<ReadingMode__c> readingModeList = new List<ReadingMode__c>();
        List<Area__c> areaList = new List<Area__c>();
        Map<Id, ReadingMode__c> mapOfAreaId2ReadingMode = new Map<Id, ReadingMode__c>(); // map of area  Id having reading mode object record.
        Map<Id, ReadingMode__c> mapOfDepotId2ReadingMode = new Map<Id, ReadingMode__c>(); // map of depot Id having reading mode object record.
        Map<Id, ReadingMode__c> mapOfBookId2ReadingMode = new Map<Id, ReadingMode__c>(); // map of book  Id having reading mode object record.
        
        Map<Id,Area__c> mapOfAreaId2Area = new Map<Id,Area__c>();
        Map<Id,Depot__c> mapOfDepotId2Depot = new Map<Id,Depot__c>();
        Savepoint sPoint = Database.setSavepoint();
        try{ 
            if(!periodIds.isEmpty()){
                //Fetch Books on the basis of Period Id.
                bookList = GlUt_MeterBooksUtilities.getBooksFromReadPeriods(periodIds,readingPeriodFields,bookFields);
                //Fetch Depots on the basis of Books 
                if(!bookList.isEmpty()){
                    depotList = GlUt_MeterBooksUtilities.getDepotFromBooks(bookList,depotFields);
                }
                //Fetch Area on the basis of Depots.
                if(!depotList.isEmpty())
                    areaList  = GlUt_MeterBooksUtilities.getAreaFromDepots(depotList,areaFields);
                for(Depot__c d: depotList){
                    mapOfDepotId2Depot.put(d.Id,d); // map of Depot Id to Depot
                }
                for(Area__c a: areaList){
                    mapOfAreaId2Area.put(a.Id,a); // map Of Area Id to Area
                }
                List<Id> bookIds = new List<Id>();
                //If this controller is being used from Book Export Request component then below logic will come in to picture.
                if(screenName == GlUt_Constants.BOOKEXPORT){                 
                    readingModeList = (List<ReadingMode__c>)GlUt_MeterBooksUtilities.getRecordsFromIds(periodIds,readingModeFields,GlUt_APIConstantsReadingMode.READINGMODEAPINAME,GlUt_APIConstantsReadingMode.READPERIODAPINAME);                    
                    for(ReadingMode__c rm: readingModeList){
                        if(rm.Book__c != null)
                            mapOfBookId2ReadingMode.put(rm.Book__c,rm);
                        if(rm.Depot__c != null)
                            mapOfDepotId2ReadingMode.put(rm.Depot__c,rm);
                        if(rm.Area__c != null)
                            mapOfAreaId2ReadingMode.put(rm.Area__c,rm);
                    }
                    //Fetch the Selected Book whose estimation Date !=null
                    for(Book__c b: bookList){
                        if(!mapOfBookId2ReadingMode.isEmpty() || !mapOfDepotId2ReadingMode.isEmpty() || !mapOfAreaId2ReadingMode.isEmpty()){
                            //If estimation date of book is present then move to next book.                           
                            if(!mapOfBookId2ReadingMode.isEmpty()  && mapOfBookId2ReadingMode.containsKey(b.Id) &&  mapOfBookId2ReadingMode.get(b.Id).EstimateDate__c != null){                               
                                continue; //If estimation date of book is not present then add the book in to select book list and move to next book.
                            }else if(!mapOfBookId2ReadingMode.isEmpty()  && mapOfBookId2ReadingMode.containsKey(b.Id) &&  mapOfBookId2ReadingMode.get(b.Id).EstimateDate__c == null){
                                bookIds.add(b.Id);
                                SelectableBooksList.add(b);
                                continue;
                            }//If Depot under perticular book is present and Depot exist in reading mode and estimation date is present then move to next record.                            
                            if(!mapOfDepotId2ReadingMode.isEmpty() && b.Depot__c != null && mapOfDepotId2ReadingMode.containsKey(b.Depot__c) && mapOfDepotId2ReadingMode.get(b.Depot__c).EstimateDate__c != null){  // AT-4187                                
                                continue; //If Depot under perticular book is present and Depot exist in reading mode and estimation date is not present then move to next record and add the book in selection list.   
                            }else if(!mapOfDepotId2ReadingMode.isEmpty() && b.Depot__c != null && mapOfDepotId2ReadingMode.containsKey(b.Depot__c) && mapOfDepotId2ReadingMode.get(b.Depot__c).EstimateDate__c == null){  //AT-4187
                                bookIds.add(b.Id);
                                SelectableBooksList.add(b);
                                continue;   
                            }//If Area for perticular Depot is present in reading mode and estimation date is present then move to next record else add to book selection list.
                            if(!mapOfAreaId2ReadingMode.isEmpty() && mapOfDepotId2Depot.containsKey(b.Depot__c) 
                               && mapOfDepotId2Depot.get(b.Depot__c).Area__c != null && mapOfAreaId2ReadingMode.containsKey(mapOfDepotId2Depot.get(b.Depot__c).Area__c)
                               && mapOfAreaId2ReadingMode.get(mapOfDepotId2Depot.get(b.Depot__c).Area__c).EstimateDate__c != null){
                                   continue;    
                               }else if(!mapOfAreaId2ReadingMode.isEmpty() && mapOfDepotId2Depot.containsKey(b.Depot__c) 
                                        && mapOfDepotId2Depot.get(b.Depot__c).Area__c != null && mapOfAreaId2ReadingMode.containsKey(mapOfDepotId2Depot.get(b.Depot__c).Area__c)
                                        && mapOfAreaId2ReadingMode.get(mapOfDepotId2Depot.get(b.Depot__c).Area__c).EstimateDate__c == null){
                                            bookIds.add(b.Id);
                                            SelectableBooksList.add(b);
                                            continue;  
                                        }
                        }
                    }
                }else{//From other components fetch all the books.
                    for(Book__c b: bookList){
                        bookIds.add(b.Id);
                        SelectableBooksList.add(b);
                    }
                }
                List<SupplyPoint__c> supplyPointList = new List<SupplyPoint__c>();
                //Fetch Supply Point on the basis of Book Ids.
                if(!bookIds.isEmpty()){
                    supplyPointList = (List<SupplyPoint__c>)GlUt_MeterBooksUtilities.getRecordsFromIds(bookIds,spFields,GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,GlUt_APIConstantsBook.BOOKAPINAME);
                }
                Map<Id,List<SupplyPoint__c>> mapOfBookId2NumberOfSupplyPoint = new Map<Id,List<SupplyPoint__c>>();
                if(supplyPointList != null && !supplyPointList.isEmpty()){
                    for(SupplyPoint__c sp: supplyPointList){
                        if (!mapOfBookId2NumberOfSupplyPoint.containsKey(sp.Book__c)) {
                            mapOfBookId2NumberOfSupplyPoint.put(sp.Book__c, new List<SupplyPoint__c>()); 
                        }
                        mapOfBookId2NumberOfSupplyPoint.get(sp.Book__c).add(sp); // Map of Number of Supply Point per Book.
                    }
                }
                //Fetch Number of Read per Book
                Map<Id,Integer> mapOfBookId2NumberOfRead = new Map<Id,Integer>();
                mapOfBookId2NumberOfRead = GlUt_MeterBooksUtilities.getNumberOfReadFromBook(readingPeriodFields,SelectableBooksList,scheduledReadFields);
                for (Book__c book: SelectableBooksList){
                    BlAp_CombinedRecord objBookCom = new BlAp_CombinedRecord(); 
                    if(mapOfDepotId2Depot.containsKey(book.Depot__c)){
                        objBookCom.uniqueId = book.Id;
                        objBookCom.isSelected = false;
                        objBookCom.objectMap = new Map<string, sObject>();
                        //Create a map of book related field values
                        objBookCom.objectMap.put(GlUt_APIConstantsBook.BOOKAPINAME, book);
                        Integer count = 0;
                        if(mapOfBookId2NumberOfSupplyPoint.containsKey(book.Id)){
                            for(SupplyPoint__c sp: mapOfBookId2NumberOfSupplyPoint.get(book.Id)){
                                count = count + 1;
                            }
                        }
                        //Add in transform list fields
                        Map<string, string> transFormFieldMap = new Map<string, string>();
                        transFormFieldMap.put(GlUt_Constants.NUMBEROFSUPPLYPOINT,(count > 0) ? string.valueof(count) : '0');
                        
                        objBookCom.transformFieldMap = new Map<string,Map<string, string>>();
                        objBookCom.transformFieldMap.put(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, transFormFieldMap);
                        //Add in transform list fields
                        Map<string, string> transFormFieldMap2 = new Map<string, string>();
                        Integer num = 0;
                        if(mapOfBookId2NumberOfRead.containsKey(book.Id))
                            num = mapOfBookId2NumberOfRead.get(book.Id);
                        transFormFieldMap2.put(GlUt_Constants.NUMBEROFREAD, num > 0 ? string.valueof(num) : '0');
                        objBookCom.transFormFieldMap.put(GlUt_APIConstantsBook.BOOKAPINAME, transFormFieldMap2);                        
                        Depot__c depot = mapOfDepotId2Depot.get(book.Depot__c);
                        objBookCom.objectMap.put(GlUt_APIConstantsDepot.DepotAPINAME, depot);
                        if(mapOfAreaId2Area.containsKey(depot.Area__c))
                            objBookCom.objectMap.put(GlUt_APIConstantsArea.AreaAPINAME, mapOfAreaId2Area.get(depot.Area__c));
                    }
                    bookCombinedList.add(objBookCom);
                }
                system.debug(DEBUG + JSON.serialize(bookCombinedList));
            }
        }
        catch (exception e){
            GlUt_Logger.logException(e);
            Database.rollback(sPoint);
            throw new AuraHandledException(e.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return bookCombinedList;
    }
    
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 08 May 2018
    @return      : ContainerWrapper
    @parameter   : List<Id> periodIds
    @description : This is a wrapper class include the List of Unique Depot and Area Names,Combined List
                   records,FieldProperty Details.
    **********************************************************************************************/
    @AuraEnabled
    public static ContainerWrapper getInfoToDisplay(List<Id> periodIds,string screenName){
        //instance of wrapper class
        ContainerWrapper resultContainer = new ContainerWrapper(); 
        //call to method to get field properties
        resultContainer.fieldPropList = retrieveBookPropDetails();
        //Call Method to get the Book Details
        resultContainer.combinedList = getBooks(periodIds,screenName);
        return resultContainer;
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 08 May 2018
    @return      : ContainerWrapper
    @description : This is a wrapper class include the List of Unique Depot and Area Names,Combined List
                   records,FieldProperty Details.
    **********************************************************************************************/
    public class ContainerWrapper {
        @AuraEnabled public List<GLAp_FieldProps> fieldPropList; 
        @AuraEnabled public List<BlAp_CombinedRecord> combinedList;
    }

}