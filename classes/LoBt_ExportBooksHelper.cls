/******************************************************************************
@author         Echo: Amit K.
@date           21 May 2018
@description    Helper Class for Book Export Batch class(LoBt_ExportBooks)
*******************************************************************************/
public with sharing class LoBt_ExportBooksHelper {
    private static final String CLASS_NAME = 'LoBt_ExportBooksHelper';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    /******************************************************************************
	@author    		Echo: Amit K.
	@date      		21 May 2018
	@param			List<SupplyPoint__c> lstSupplyPoint
	@param			String csvFileString 
	@param			Id readPeriod
	@param			Integer totalNumberOfBookExtracted
    @param          Map<Id,Integer> mapOfBook2SupplyPointSize
	@return			ContainerWrapper
	@description 	Wrapper Class to hold the csv data.
	*******************************************************************************/
    public static ContainerWrapper getCSVRecords(List<SupplyPoint__c> lstSupplyPoint,String csvFileString,Id readPeriod,Integer totalNumberOfBookExtracted,Map<Id,Integer> mapOfBook2SupplyPointSize) {
        Map<Id,SupplyPoint__c> mapOfSupplyPointIdId2SupplyPoint = new Map<Id,SupplyPoint__c>();
        Map<Id,Reading__c> mapOfDeviceId2FirstReadingByDate = new Map<Id,Reading__c>();
        Map<Id,Reading__c> mapOfDeviceId2FirstActualReadingByDate = new Map<Id,Reading__c>();
        Map<Id,String> mapOfSupplyPointId2Book = new Map<Id,String>();
        Map<Id,SupplyPointDevice__c> mapOfSupplyPointId2SupplyPointDevice = new Map<Id,SupplyPointDevice__c>();
        Map<Id,Service__c> mapOfSupplyPointId2Service = new Map<Id,Service__c>();
        List<SupplyPointDevice__c> spdList;
        ContainerWrapper wrapper = new ContainerWrapper();
        CalculatingThresholdWrapper thresholdCalcWrapper = new CalculatingThresholdWrapper();
        try{ 
            if(!lstSupplyPoint.isEmpty()){
                thresholdCalcWrapper = getThreshHoldValues(readPeriod,lstSupplyPoint);
                List<Service__c> lstService = new List<Service__c>();
                lstService = getServiceList(lstSupplyPoint);
                if(!lstService.isEmpty()){
                    for(Service__c s: lstService){
                        if(!mapOfSupplyPointId2Service.containsKey(s.SupplyPoint__c))
                            mapOfSupplyPointId2Service.put(s.SupplyPoint__c,s);
                    }
                }
                spdList = getSupplyPointDeviceList(lstSupplyPoint);
                for(SupplyPoint__c sp: lstSupplyPoint){
                    mapOfSupplyPointId2Book.put(sp.Id,sp.Book__r.Name);
                }
                if(!spdList.isEmpty()){
                    Set<Id> deviceIds = new Set<Id>();
                    for(SupplyPointDevice__c spd: spdList){
                        mapOfSupplyPointId2SupplyPointDevice.put(spd.SupplyPoint__c,spd);
                        deviceIds.add(spd.Device__c);
                    }
                    if(!deviceIds.isEmpty()){
                        List<Reading__c> readingList = getReadingList(deviceIds);
                        if(!readingList.isEmpty()){
                            for(Reading__c r: readingList){
                                if(!mapOfDeviceId2FirstReadingByDate.containsKey(r.Device__c)){
                                    mapOfDeviceId2FirstReadingByDate.put(r.Device__c,r);
                                }
                            }
                        }
                        List<Reading__c> actualReadingList = getActualReadingList(deviceIds);
                        if(!actualReadingList.isEmpty()){
                            for(Reading__c r: actualReadingList){
                                if(!mapOfDeviceId2FirstActualReadingByDate.containsKey(r.Device__c)){
                                    mapOfDeviceId2FirstActualReadingByDate.put(r.Device__c,r);
                                }
                            }
                        }
                    }
                }
                Map<Id,List<Id>> mapOfBook2SupplyPointId = new Map<Id,List<Id>>();
                String fileRow = '';
                for(SupplyPoint__c sp: lstSupplyPoint){
                    if (!mapOfBook2SupplyPointId.containsKey(sp.Book__c)) {
                        mapOfBook2SupplyPointId.put(sp.Book__c,new List<Id>());
                    }
                    mapOfBook2SupplyPointId.get(sp.Book__c).add(sp.id);
                    fileRow = '';
                    //Device Reference
                    if(mapOfSupplyPointId2SupplyPointDevice.containsKey(sp.Id)){
                        SupplyPointDevice__c spd =  mapOfSupplyPointId2SupplyPointDevice.get(sp.Id);
                        fileRow = fileRow +','+ spd.Device__r.Name;
                    }else{
                        fileRow = fileRow +',';
                    }
                    if(mapOfSupplyPointId2Service.containsKey(sp.Id)){
                        //Account Name
                        Service__c service = mapOfSupplyPointId2Service.get(sp.Id);
                        fileRow = fileRow +','+service.BillingContract__r.AccountName__r.Name;
                    }else{
                        fileRow = fileRow +',';
                    }
                    //Location Supply Address
                    fileRow = fileRow +','+ sp.Location__r.Name;
                    //Depot
                    fileRow = fileRow +','+ sp.Book__r.Depot__r.Name;
                    //Book
                    fileRow = fileRow +','+ sp.Book__r.Name;
                    //Walk Order
                    fileRow = fileRow +','+ sp.WalkOrder__c;
                    //Void
                    fileRow = fileRow +','+ sp.Location__r.VoidLocation__c;
                    //Manufacturer
                    if(mapOfSupplyPointId2SupplyPointDevice.containsKey(sp.Id)){
                        SupplyPointDevice__c spd =  mapOfSupplyPointId2SupplyPointDevice.get(sp.Id);
                        fileRow = fileRow +','+ spd.Device__r.DeviceType__r.Manufacturer__c;
                        //Serial Number
                        fileRow = fileRow +','+ spd.Device__r.SerialNo__c;
                    }else{
                        fileRow =  createEmptyFileRow(fileRow,2);
                    }
                    //Device Location
                    fileRow = fileRow +','+ sp.DeviceLocation__c;
                    //Geo Location
                    fileRow = fileRow +','+ sp.Geolocation__c;
                    //Special Instruction
                    fileRow = fileRow +','+ sp.SpecialInstructions__c;
                    //Advice
                    fileRow = fileRow +','+ sp.Advice__c; //AT-3538
                    if(mapOfSupplyPointId2SupplyPointDevice.containsKey(sp.Id)){
                        SupplyPointDevice__c spd =  mapOfSupplyPointId2SupplyPointDevice.get(sp.Id);
                        if(mapOfDeviceId2FirstReadingByDate.containsKey(spd.Device__c)){
                            Reading__c firstReadingDate = mapOfDeviceId2FirstReadingByDate.get(spd.Device__c);
                            //Last Reading
                            fileRow = fileRow +','+ firstReadingDate.ActualDeviceReading__c;
                            //Last Reading Date
                            fileRow = fileRow +','+ firstReadingDate.ReadingDate__c;
                            //Last Reading Method
                            fileRow = fileRow +','+ firstReadingDate.ReadingMethod__c;
                            if(mapOfDeviceId2FirstActualReadingByDate.containsKey(spd.Device__c)){
                                Reading__c firstActualReadingDate =  mapOfDeviceId2FirstActualReadingByDate.get(spd.Device__c);
                                //Last Actual Reading
                                fileRow = fileRow +','+ firstActualReadingDate.ActualDeviceReading__c;
                                //Last Actual Reading Date
                                fileRow = fileRow +','+ firstActualReadingDate.ReadingDate__c;
                            }else{
                                fileRow =  createEmptyFileRow(fileRow,2);
                            }
                        }else{
                            fileRow =  createEmptyFileRow(fileRow,5);
                        }
                    }else{
                        fileRow =  createEmptyFileRow(fileRow,5);
                    }
                    //Expected Consumption High
                    if(thresholdCalcWrapper.mapOfSPId2UpperThresholdValues != null && thresholdCalcWrapper.mapOfSPId2UpperThresholdValues.containsKey(sp.Id)){
                        fileRow = fileRow +','+ thresholdCalcWrapper.mapOfSPId2UpperThresholdValues.get(sp.Id);
                    }else{
                        fileRow = fileRow +',';
                    }
                    //Expected Consumption Low
                    if(thresholdCalcWrapper.mapOfSPId2LowerThresholdValues != null && thresholdCalcWrapper.mapOfSPId2LowerThresholdValues.containsKey(sp.Id)){
                        fileRow = fileRow +','+ thresholdCalcWrapper.mapOfSPId2LowerThresholdValues.get(sp.Id);
                    }else{
                        fileRow = fileRow +',';
                    }
                    //Read Reason (Requested Read)
                    fileRow = fileRow +',';
                    //Read By Date (Requested Read)
                    fileRow = fileRow +',';
                    //Comments (Requested Read)
                    fileRow = fileRow +',';
                    //Target Reading Date
                    fileRow = fileRow +','+ sp.TargetReadDate__c;
                    //Read Period Id
                    fileRow = fileRow +','+ readPeriod;
                    fileRow = fileRow.replaceFirst(',','');
                    csvFileString = csvFileString + fileRow + '\n';
                }
                if(!mapOfBook2SupplyPointId.isEmpty()){
                    for(Id bookId: mapOfBook2SupplyPointId.keySet()){
                        Integer Size = mapOfBook2SupplyPointId.get(bookId).size();
                        if (!mapOfBook2SupplyPointSize.containsKey(bookId)) {
                            mapOfBook2SupplyPointSize.put(bookId,Size);
                        }
                        else{
                            Size = Size + mapOfBook2SupplyPointSize.get(bookId);
                            mapOfBook2SupplyPointSize.put(bookId,Size);
                        }
                    }
                }
                wrapper.mapOfBookId2Book = getBookName(mapOfBook2SupplyPointSize);
            }
            wrapper.csvFileString = csvFileString;
            wrapper.totalNumberOfBookExtracted = mapOfBook2SupplyPointSize.size();
            wrapper.mapOfBook2SupplyPointSize = mapOfBook2SupplyPointSize;
        }
        catch (exception e){
            GlUt_Logger.logException(e);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return wrapper;
    }
    /******************************************************************************
	@author    		Echo: Dependra Singh
	@date      		10 Oct 2018
	@description 	Methos is used to create 
	*******************************************************************************/
    private static string createEmptyFileRow(string fileRow, Integer num){
        for(integer i =0; i < num ; i++){
            fileRow = fileRow +',';
        }
        return fileRow;
    }
    /******************************************************************************
	@author    		Echo: Amit K.
	@date      		21 May 2018
	@description 	Wrapper Class to hold the csv string,Total Number of Book Extracted and SupplyPoint Extracted per Book data.
	*******************************************************************************/
    public class ContainerWrapper {
        public String csvFileString; 
        public Integer totalNumberOfBookExtracted;
        public Map<Id,Integer> mapOfBook2SupplyPointSize;
        public Map<Id,Book__c> mapOfBookId2Book;
    }
    
    /******************************************************************************
	@author    		Echo: Amit K.
	@date      		21 May 2018
	@param			Set<Id> deviceIds
	@return			List<Reading__c>
	@description 	Fetch the Actual Reading on the basis of Device Ids
	*******************************************************************************/
    public static Map<Id,Book__c> getBookName(Map<Id,Integer> mapOfBook2SupplyPointSize){
        Map<Id,Book__c> bookMap = new Map<Id,Book__c>([select Id,
                                                       Name     
                                                       from Book__c where Id IN :mapOfBook2SupplyPointSize.keySet()]);
        return bookMap;
    }
    /******************************************************************************
	@author    		Echo: Amit K.
	@date      		21 May 2018
	@param			Set<Id> deviceIds
	@return			List<Reading__c>
	@description 	Fetch the Actual Reading on the basis of Device Ids
	*******************************************************************************/
    public static List<Reading__c> getActualReadingList(Set<Id> deviceIds){
        
        List<Reading__c> actualReadingList = [select Id,
                                              Device__r.Name,
                                              Device__c,
                                              ActualDeviceReading__c,
                                              ReadingDate__c,
                                              ReadingMethod__c
                                              from Reading__c where Device__c IN :deviceIds AND ReadingMethod__c =: LoBt_Constants.READINGMETHOD ORDER BY ReadingDate__c DESC];
        return actualReadingList;
    }
    /******************************************************************************
	@author    		Echo: Amit K.
	@date      		21 May 2018
	@param			Set<Id> deviceIds
	@return			List<Reading__c>
	@description 	Fetch the Readings on the basis of device Ids.
	*******************************************************************************/
    public static List<Reading__c> getReadingList(Set<Id> deviceIds){
        List<Reading__c> readingList = [select Id,
                                        Device__r.Name,
                                        ActualDeviceReading__c,
                                        ReadingDate__c,
                                        ReadingMethod__c,
                                        Device__c 
                                        from Reading__c where Device__c IN :deviceIds ORDER BY ReadingDate__c DESC];
        return readingList;
    }
    /******************************************************************************
	@author    		Echo: Amit K.
	@date      		21 May 2018
	@param			List<SupplyPoint__c> lstSupplyPoint
	@return			List<SupplyPointDevice__c>
	@description 	Fetch the Supply Point Device on the basis of supply Point.
	*******************************************************************************/
    public static List<SupplyPointDevice__c> getSupplyPointDeviceList(List<SupplyPoint__c> lstSupplyPoint){
        List<SupplyPointDevice__c> spdList = [select Id, 
                                              Device__c,
                                              Device__r.Name,
                                              Device__r.DeviceType__r.Manufacturer__c,
                                              Device__r.SerialNo__c,
                                              SupplyPoint__c 
                                              from SupplyPointDevice__c where SupplyPoint__c IN :lstSupplyPoint AND Active__c = True];
        
        return spdList;
    }
    /******************************************************************************
	@author    		Echo: Amit K.
	@date      		21 May 2018
	@param			List<SupplyPoint__c> lstSupplyPoint
	@return			List<Service__c>
	@description 	Fetch the service records on the basis of Supply Point.
	*******************************************************************************/
    public static List<Service__c> getServiceList(List<SupplyPoint__c> lstSupplyPoint){
        List<Service__c> lstService = [select Id, 
                                       BillingContract__r.AccountName__r.Name,
                                       SupplyPoint__c 
                                       from Service__c where SupplyPoint__c IN :lstSupplyPoint AND ServiceEndDate__c = NULL ORDER BY CreatedDate DESC];
        
        return lstService;
    }
    /******************************************************************************
	@author    		Echo: Amit K.
	@date      		21 May 2018
	@param			List<SupplyPoint__c> lstSupplyPoint
	@return			List<ReadingRequest__c>
	@description 	Fetch the reading request on the basis of supply point.
	*******************************************************************************/
    public static List<ReadingRequest__c> changeReadingRequestStatus(List<SupplyPoint__c> lstSupplyPoint){
        List<ReadingRequest__c> lstReadingRequest = [select Id, 
                                                     Status__c
                                                     from ReadingRequest__c where SupplyPoint__c IN :lstSupplyPoint AND Status__c=:LoBt_Constants.READINGREQUESTNEWSTATUS];
        if(!lstReadingRequest.isEmpty()){
            for(ReadingRequest__c rr: lstReadingRequest){
                rr.Status__c = LoBt_Constants.READINGREQUESTEXPORTEDSTATUS;
            }
            lstReadingRequest = (List<ReadingRequest__c>) GlUt_FieldSecurity.cleanseFields(lstReadingRequest, false);
            update lstReadingRequest;
        }
        return lstReadingRequest;
    }
    /******************************************************************************
	@author    		Echo: Amit K.
	@date      		21 May 2018
	@param			Id brqId
	@return			BatchRequestQueue__c
	@description 	Change the BRQ status to Complete.
	*******************************************************************************/
   public static BatchRequestQueue__c changeBRQStatus(Id brqId,String status){//AT-3204 Starts Here
       BatchRequestQueue__c brq = [select Id,
                                   Status__c
                                   from BatchRequestQueue__c where Id=: brqId];
       brq.Status__c = status;//AT-3204 Ends Here
       brq  = (BatchRequestQueue__c) GlUt_FieldSecurity.cleanseFields(brq, false);
       update brq;
       return brq;
    }
    /******************************************************************************
    @author    		Echo: Amit K.
    @date      		21 May 2018
    @param			ReadPeriod__c rpEndDateAsCalcDate,Set<Id> deviceIds
    @return			List<Reading__c>
    @description 	Fetch the latest Billable Reading on the basis of Read Period end
                    Date and Device Ids.
    *******************************************************************************/
    public static List<Reading__c> getLatestBillableReading(ReadPeriod__c rpEndDateAsCalcDate,Set<Id> deviceIds){
        List<Reading__c> latestBillableReadingList = [select Id,
                                                      Device__r.Name,
                                                      ActualDeviceReading__c,
                                                      ReadingDate__c,
                                                      ReadingMethod__c,
                                                      Device__c,
                                                      Reading__c
                                                      from Reading__c where Device__c IN :deviceIds AND BillableType__c =: GlUt_Constants.BILLABLE AND ReadingDate__c <: rpEndDateAsCalcDate.ReadEnd__c ORDER BY ReadingDate__c DESC];
        return latestBillableReadingList;     
    }
    /******************************************************************************
    @author    		Echo: Amit K.
    @date      		21 May 2018
    @param			Map<Id,SupplyPointDevice__c> mapOfSupplyPointId2SPD
    @return			List<AverageDailyUsage__c>
    @description 	Fetch ADU records on the basis of SPD.
    *******************************************************************************/
    public static List<AverageDailyUsage__c> getAverageDailyUsage(Map<Id,SupplyPointDevice__c> mapOfSupplyPointId2SPD){
        
        List<AverageDailyUsage__c> aduList =  [select Id,
                                              StartDate__c,
                                              EndDate__c,
                                              SupplyPointDevice__c,
                                              AverageDailyUsage__c
                                              from AverageDailyUsage__c where SupplyPointDevice__c IN:mapOfSupplyPointId2SPD.values()];
        return aduList;
    } 
    /******************************************************************************
    @author    		Echo: Amit K.
    @date      		21 May 2018
    @param			ReadPeriod__c rpEndDateAsCalcDate
    @return			List<ReadTimetableThresholds__c>
    @description 	Fetch readtimetablethreshold records on the basis of Readperiod TimeTable
    *******************************************************************************/
    public static List<ReadTimetableThresholds__c> getReadTimetableThresholds(ReadPeriod__c rpEndDateAsCalcDate){
        
        List<ReadTimetableThresholds__c> rtTableThresholdList = [SELECT ReadTimetable__c,
                                                                 DailyUsageThresholdStart__c,
                                                                 DailyUsageThresholdEnd__c,
                                                                 AcceptablePercentageVarianceBelow__c,
                                                                 AcceptablePercentageVarianceAbove__c,
                                                                 ThresholdMonths__c   //AT-5015
                                                                 FROM ReadTimetableThresholds__c
                                                                 WHERE ReadTimetable__c =: rpEndDateAsCalcDate.ReadTimetable__c];
        return rtTableThresholdList;
    }
    /******************************************************************************
    @author    		Echo: Amit K.
    @date      		21 May 2018
    @param			Id readPeriod
    @return			ReadPeriod__c
    @description 	Fetch read period details on the basis of read period Id.
    *******************************************************************************/
    public static ReadPeriod__c getReadPeriodReacord(Id readPeriod){
        
        ReadPeriod__c rpEndDateAsCalcDate = [select Id,
                                             ReadEnd__c,
                                             ReadTimetable__c
                                             from ReadPeriod__c where Id=:readPeriod];
        return rpEndDateAsCalcDate;
    }
    /******************************************************************************
    @author    		Echo: Amit K.
    @date      		21 May 2018
    @description 	Wrapper Class to Hold the Lower and Higher Threshold Value.
    *******************************************************************************/
    public class CalculatingThresholdWrapper {
        public Map<Id,Decimal> mapOfSPId2LowerThresholdValues = new Map<Id,Decimal>(); 
        public Map<Id,Decimal> mapOfSPId2UpperThresholdValues = new Map<Id,Decimal>();
    }
    /******************************************************************************
    @author    		Echo: Amit K.
    @date      		21 May 2018
    @param			Id readPeriod,List<SupplyPoint__c> lstSupplyPoint
    @return			CalculatingThresholdWrapper
    @description 	Fetch the threshold Values on the basis of read priod and Supply Point.
    *******************************************************************************/
    public static CalculatingThresholdWrapper getThreshHoldValues(Id readPeriod,List<SupplyPoint__c> lstSupplyPoint){
        CalculatingThresholdWrapper ctWrapper = new CalculatingThresholdWrapper();
        Map<Id,SupplyPointDevice__c> mapOfSupplyPointId2SPD = new Map<Id,SupplyPointDevice__c>();
        Map<Id,AverageDailyUsage__c> mapOfSPDId2ActiveADU = new Map<Id,AverageDailyUsage__c>();
        Map<Id,ReadTimetableThresholds__c> mapOfSPDId2ReadTimeTableThresHold = new Map<Id,ReadTimetableThresholds__c>();
        try{
            //Fetch the Read end date as Calculation Date on the basis of Read Period Id.
            ReadPeriod__c rpEndDateAsCalcDate = getReadPeriodReacord(readPeriod);
            if(rpEndDateAsCalcDate != null){
                Set<Id> deviceIds = new Set<Id>();
                List<SupplyPointDevice__c> spdList = LoBt_ExportBooksHelper.getSupplyPointDeviceList(lstSupplyPoint);
                for(SupplyPointDevice__c spd: spdList){
                    mapOfSupplyPointId2SPD.put(spd.SupplyPoint__c,spd);
                    deviceIds.add(spd.Device__c);
                }
                //Fetch ADU record on the basis of SPD.
                if(!mapOfSupplyPointId2SPD.isEmpty()){
                    //get Adu list
                    List<AverageDailyUsage__c> aduList = getAverageDailyUsage(mapOfSupplyPointId2SPD);
                    for(AverageDailyUsage__c adu: aduList){
                        if(adu.StartDate__c <= rpEndDateAsCalcDate.ReadEnd__c){
                            if(adu.EndDate__c == null || adu.EndDate__c >= rpEndDateAsCalcDate.ReadEnd__c){
                                mapOfSPDId2ActiveADU.put(adu.SupplyPointDevice__c,adu); // Map of SPD to Active ADU record.
                            }
                        }
                    }
                }
                //Fetch Read Time Table Threshold on the basis of read period end date as Calculation Date.
                List<ReadTimetableThresholds__c> rtTableThresholdList = getReadTimetableThresholds(rpEndDateAsCalcDate);
                if(!rtTableThresholdList.isEmpty() && !mapOfSPDId2ActiveADU.isEmpty()){
                    // AT-5015 start...                    
                    Map<Integer,String> monthsMap = new Map<Integer, String>{1 => 'January' , 2 => 'February' ,3 => 'March' ,4 => 'April' , 5 => 'May' ,
                                                                             6 => 'June' , 7 => 'July' , 8 => 'August' , 9 => 'September' ,
                                                                             10 => 'October' , 11=> 'November' ,12 => 'December'}; 
                    String exportReadingMonth = monthsMap.get((system.today()).month());    //the readingMonth will be todays date (the date of the export)                                                      
                    // AT-5015 end...                    
                    for(ReadTimetableThresholds__c rtTableThreshold : rtTableThresholdList){
                        for(Id spdId: mapOfSPDId2ActiveADU.keySet()){
                            List<String> thresholdMonths = new List<String>();
                            if(GlUt_RegionUtility.getAURegionCustomSetting() && rtTableThreshold.ThresholdMonths__c != null){
                                thresholdMonths = rtTableThreshold.ThresholdMonths__c.split(';');
                            }
                           
                            AverageDailyUsage__c adu = mapOfSPDId2ActiveADU.get(spdId);
                            if(rtTableThreshold.DailyUsageThresholdStart__c <= adu.AverageDailyUsage__c && rtTableThreshold.DailyUsageThresholdEnd__c >= adu.AverageDailyUsage__c &&
                              ((GlUt_RegionUtility.getAURegionCustomSetting() && thresholdMonths.contains(exportReadingMonth)) ||    // AT-5015
                               (!GlUt_RegionUtility.getAURegionCustomSetting()) )  ){                                                // AT-5015
                                mapOfSPDId2ReadTimeTableThresHold.put(spdId,rtTableThreshold); // map Of SPD to RT Table Threshold
                            }
                        }
                    }
                } 
                // Fetch latest Billable Reading List.
                List<Reading__c> latestBillableReadingList = getLatestBillableReading(rpEndDateAsCalcDate,deviceIds);
                Map<Id,Reading__c> mapOfDeviceId2LatestReading = new Map<Id,Reading__c>();
                if(!latestBillableReadingList.isEmpty()){
                    for(Reading__c LatestReading: latestBillableReadingList){
                        if(!mapOfDeviceId2LatestReading.containsKey(LatestReading.Device__c)){
                            mapOfDeviceId2LatestReading.put(LatestReading.Device__c,LatestReading); // map Of Device to Latest Reading.
                        }
                    }
                }
                //Fetch the upper and Lower Threshold for SupplyPoints
                for(SupplyPoint__c sp: lstSupplyPoint){
                    if(mapOfSupplyPointId2SPD.containsKey(sp.Id)){
                        SupplyPointDevice__c spd = mapOfSupplyPointId2SPD.get(sp.Id);
                        if(mapOfDeviceId2LatestReading.containsKey(spd.Device__c)){
                            Decimal latestBillableReading = mapOfDeviceId2LatestReading.get(spd.Device__c).Reading__c;
                            Date latestBillableReadingDate = mapOfDeviceId2LatestReading.get(spd.Device__c).ReadingDate__c;
                            Date calculationDate = rpEndDateAsCalcDate.ReadEnd__c;
                            Integer daysDiff = latestBillableReadingDate.daysBetween(calculationDate);
                            if(!mapOfSPDId2ActiveADU.isEmpty() && !mapOfSPDId2ReadTimeTableThresHold.isEmpty() 
                               && mapOfSPDId2ActiveADU.containsKey(spd.Id) && mapOfSPDId2ReadTimeTableThresHold.containsKey(spd.Id)){
                                   // Estimated Calculation = Average Daily Usage * (Days Between Last Reading Date and Calculation Date)  
                                   Decimal estimateConsumption = mapOfSPDId2ActiveADU.get(spd.Id).AverageDailyUsage__c * daysDiff ;
                                   
                                   //Latest Billable Reading + (Estimated Consumption / 100 * Lower Threshold Percentage)
                                   Decimal lowerThresholdValue = latestBillableReading + estimateConsumption/100 * mapOfSPDId2ReadTimeTableThresHold.get(spd.Id).AcceptablePercentageVarianceBelow__c;
                                   
                                   //Upper Threshold Value = Latest Billable Reading + (Estimated Consumption / 100 * Upper Threshold Percentage)
                                   Decimal upperThresholdValue = latestBillableReading + estimateConsumption/100 * mapOfSPDId2ReadTimeTableThresHold.get(spd.Id).AcceptablePercentageVarianceAbove__c;
                                   ctWrapper.mapOfSPId2LowerThresholdValues.put(sp.Id,lowerThresholdValue);
                                   ctWrapper.mapOfSPId2UpperThresholdValues.put(sp.Id,upperThresholdValue);
                               } 
                        }
                    }
                }
            }
        }
        catch (exception e){
            GlUt_Logger.logException(e);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return ctWrapper;
    }
}