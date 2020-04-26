/******************************************************************************
@author         Echo: Swati Mathur
@date           29 May 2018
@description    Helper Class for Requested Readings Export Batch class(LoBt_ExportRequestedReadings)
*******************************************************************************/
public with sharing class LoBt_ExportRequestedReadingsHelper {
    /******************************************************************************
	@author    		Echo: Swati Mathur
	@date      		29 May 2018
	@param			List<ReadingRequest__c> lstReadingRequest
	@param			String csvFileString 
	@param			Integer totalNumberOfSupplyPointExtracted
	@return			ContainerWrapper
	@description 	method to create csv records 
	*******************************************************************************/
    public static ContainerWrapper getCSVRecords(List<ReadingRequest__c> lstReadingRequest,String csvFileString,Integer totalNumberOfSupplyPointExtracted) {        
        ContainerWrapper wrapper = new ContainerWrapper();
        CalculatingThresholdWrapper thresholdCalcWrapper = new CalculatingThresholdWrapper();
        Map<Id,Id> mapOfReadingReqId2SupplyPointId = new Map<Id,Id>();  
        Map<Id,Service__c> mapOfSupplyPointId2Service = new Map<Id,Service__c>();
        Map<Id,SupplyPointDevice__c> mapOfSupplyPointId2SupplyPointDevice = new Map<Id,SupplyPointDevice__c>();
        Map<Id,Reading__c> mapOfDeviceId2FirstReadingByDate = new Map<Id,Reading__c>();
        Map<Id,Reading__c> mapOfDeviceId2FirstActualReadingByDate = new Map<Id,Reading__c>();
        Set<Id> setSupplyPointId = new Set<Id>();
        
        try{
            if(!lstReadingRequest.isEmpty()){
                
                for(ReadingRequest__c objReadingReq: lstReadingRequest){
                    mapOfReadingReqId2SupplyPointId.put(objReadingReq.Id, objReadingReq.SupplyPoint__c);                    
                }            
                List<Id> lstSupplyPointId = mapOfReadingReqId2SupplyPointId.values();
                thresholdCalcWrapper = getThreshHoldValues(lstReadingRequest, mapOfReadingReqId2SupplyPointId, lstSupplyPointId);
                setSupplyPointId.addAll(lstSupplyPointId);
                
                if(!lstSupplyPointId.isEmpty()){                
                    List<Service__c> lstService = getServiceList(lstSupplyPointId);
                    if(!lstService.isEmpty()){
                        for(Service__c obj: lstService){
                            if(!mapOfSupplyPointId2Service.containsKey(obj.SupplyPoint__c))
                                mapOfSupplyPointId2Service.put(obj.SupplyPoint__c,obj);
                        }
                    }                
                    List<SupplyPointDevice__c> spdList = getSupplyPointDeviceList(lstSupplyPointId);
                    if(!spdList.isEmpty()){
                        Set<Id> deviceIds = new Set<Id>();
                        for(SupplyPointDevice__c spd: spdList){
                            mapOfSupplyPointId2SupplyPointDevice.put(spd.SupplyPoint__c,spd);
                            deviceIds.add(spd.Device__c);
                        }
                        if(!deviceIds.isEmpty()){
                            List<Reading__c> readingList = getReadingList(deviceIds);
                            if(!readingList.isEmpty()){
                                for(Reading__c objreading: readingList){
                                    if(!mapOfDeviceId2FirstReadingByDate.containsKey(objreading.Device__c)){
                                        mapOfDeviceId2FirstReadingByDate.put(objreading.Device__c,objreading);
                                    }
                                }
                            }
                            List<Reading__c> actualReadingList = getActualReadingList(deviceIds);
                            if(!actualReadingList.isEmpty()){
                                for(Reading__c objreading: actualReadingList){
                                    if(!mapOfDeviceId2FirstActualReadingByDate.containsKey(objreading.Device__c)){
                                        mapOfDeviceId2FirstActualReadingByDate.put(objreading.Device__c,objreading);
                                    }
                                }
                            }
                        }
                    }
                }
                
                String fileRow = ''; 
                //iterate over ReadingRequest list to add to csv file
                for(ReadingRequest__c RR: lstReadingRequest){   
                    fileRow = '';
                    Id supplyPointId;
                    if(mapOfReadingReqId2SupplyPointId.containsKey(RR.Id)){
                        supplyPointId = mapOfReadingReqId2SupplyPointId.get(RR.Id);
                    }
                    
                    //Device Reference
                    if(supplyPointId != null && mapOfSupplyPointId2SupplyPointDevice.containsKey(supplyPointId)){
                        SupplyPointDevice__c spd =  mapOfSupplyPointId2SupplyPointDevice.get(supplyPointId);
                        fileRow = fileRow +','+ spd.Device__r.Name;
                    }else{
                        fileRow = fileRow +',';
                    }                
                    //Account Name
                    if(supplyPointId != null && mapOfSupplyPointId2Service.containsKey(supplyPointId)){                        
                        Service__c service = mapOfSupplyPointId2Service.get(supplyPointId);
                        fileRow = fileRow +','+service.BillingContract__r.AccountName__r.Name;
                    }else{
                        fileRow = fileRow +',';
                    }                
                    //Location Supply Address
                    fileRow = fileRow +','+ RR.SupplyPoint__r.Location__r.Name;
                    //Depot
                    fileRow = fileRow +','+ RR.SupplyPoint__r.Depot__r.Name;
                    //Book
                    fileRow = fileRow +','+ RR.SupplyPoint__r.Book__r.Name;
                    //Walk Order
                    fileRow = fileRow +','+ RR.SupplyPoint__r.WalkOrder__c;
                    //Void
                    fileRow = fileRow +','+ RR.SupplyPoint__r.Location__r.VoidLocation__c;
                    //Manufacturer
                    if(supplyPointId != null && mapOfSupplyPointId2SupplyPointDevice.containsKey(supplyPointId)){
                        SupplyPointDevice__c spd =  mapOfSupplyPointId2SupplyPointDevice.get(supplyPointId);
                        fileRow = fileRow +','+ spd.Device__r.DeviceType__r.Manufacturer__c;
                        //Serial Number
                        fileRow = fileRow +','+ spd.Device__r.SerialNo__c;
                    }else{
                        fileRow = fileRow +',';
                        fileRow = fileRow +',';
                    }
                    //Device Location
                    fileRow = fileRow +','+ RR.SupplyPoint__r.DeviceLocation__c;
                    //Geo Location
                    fileRow = fileRow +','+ RR.SupplyPoint__r.Geolocation__c;
                    //Special Instruction
                    fileRow = fileRow +','+ RR.SupplyPoint__r.SpecialInstructions__c;
                    
                    if(supplyPointId != null && mapOfSupplyPointId2SupplyPointDevice.containsKey(supplyPointId)){
                        SupplyPointDevice__c spd =  mapOfSupplyPointId2SupplyPointDevice.get(supplyPointId);
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
                            //Changed by dependra 
                            fileRow =  createEmptyFileRow(fileRow,5);
 
                        }
                    }else{
                        fileRow =  createEmptyFileRow(fileRow,5);
                    }
                    //Expected Consumption High
                    if(thresholdCalcWrapper.mapOfRRId2UpperThresholdValues != null && thresholdCalcWrapper.mapOfRRId2UpperThresholdValues.containsKey(RR.Id)){
                        fileRow = fileRow +','+ thresholdCalcWrapper.mapOfRRId2UpperThresholdValues.get(RR.Id);
                    }else{
                        fileRow = fileRow +',';
                    }
                    //Expected Consumption Low
                    if(thresholdCalcWrapper.mapOfRRId2LowerThresholdValues != null && thresholdCalcWrapper.mapOfRRId2LowerThresholdValues.containsKey(RR.Id)){
                        fileRow = fileRow +','+ thresholdCalcWrapper.mapOfRRId2LowerThresholdValues.get(RR.Id);
                    }else{
                        fileRow = fileRow +',';
                    }
                    //Read Reason 
                    fileRow = fileRow +',' + RR.ReadReason__c ;
                    //Read By Date 
                    fileRow = fileRow +','+ RR.ReadbyDate__c ;
                    //Comments 
                    fileRow = fileRow +','+ RR.ReadComments__c ;
                    //Target Reading Date
                    fileRow = fileRow +','+ RR.SupplyPoint__r.TargetReadDate__c;
                    //Read Period Id
                    fileRow = fileRow +',';
                    
                    fileRow = fileRow.replaceFirst(',','');
                    csvFileString = csvFileString + fileRow + '\n';
                }
            }            
            wrapper.csvFileString = csvFileString;
            wrapper.totalNumberOfSupplyPointExtracted = totalNumberOfSupplyPointExtracted + setSupplyPointId.size();
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
	@author    		Echo: Swati Mathur
	@date      		29 May 2018
	@description 	Wrapper Class 
	*******************************************************************************/
    public class ContainerWrapper {
        public String csvFileString; 
        public Integer totalNumberOfSupplyPointExtracted;
    }
    /******************************************************************************
	@author    		Echo: Swati Mathur
	@date      		29 May 2018
	@param			Set<Id> deviceIds
	@return			List<Reading__c>
	@description 	Fetch the Actual Reading on the basis of Device Ids
	*******************************************************************************/
    public static List<Reading__c> getActualReadingList(Set<Id> deviceIds){        
        List<Reading__c> actualReadingList = [select Id,
                                              Device__r.Name,//AT-3174
                                              Device__c,//AT-3174
                                              ActualDeviceReading__c,
                                              ReadingDate__c,
                                              ReadingMethod__c
                                              from Reading__c where Device__c IN :deviceIds AND ReadingMethod__c = 'Actual' ORDER BY ReadingDate__c DESC];
        return actualReadingList;
    }
    /******************************************************************************
	@author    		Echo: Swati Mathur
	@date      		29 May 2018
	@param			Set<Id> deviceIds
	@return			List<Reading__c>
	@description 	Fetch the Readings on the basis of device Ids.
	*******************************************************************************/
    public static List<Reading__c> getReadingList(Set<Id> deviceIds){
        List<Reading__c> readingList = [select Id,
                                        Device__r.Name,//AT-3174
                                        ActualDeviceReading__c,
                                        ReadingDate__c,
                                        ReadingMethod__c,
                                        Device__c //AT-3174
                                        from Reading__c where Device__c IN :deviceIds ORDER BY ReadingDate__c DESC];
        return readingList;
    }
    /******************************************************************************
	@author    		Echo: Swati Mathur
	@date      		29 May 2018
	@param			List<Id> lstSupplyPointId
	@return			List<SupplyPointDevice__c>
	@description 	Fetch the Supply Point Device on the basis of supply Point Id.
	*******************************************************************************/
    public static List<SupplyPointDevice__c> getSupplyPointDeviceList(List<Id> lstSupplyPointId){
        List<SupplyPointDevice__c> spdList = [select Id, 
                                              Device__c,
                                              Device__r.Name,
                                              Device__r.DeviceType__r.Manufacturer__c,
                                              Device__r.SerialNo__c,
                                              SupplyPoint__c 
                                              from SupplyPointDevice__c where SupplyPoint__c IN :lstSupplyPointId AND Active__c = True];
        
        return spdList;
    }
    /******************************************************************************
	@author    		Echo: Swati Mathur
	@date      		29 May 2018
	@param			List<Id> lstSupplyPointId
	@return			List<Service__c>
	@description 	Fetch the service records on the basis of Supply Point Id.
	*******************************************************************************/
    public static List<Service__c> getServiceList(List<Id> lstSupplyPointId){
        List<Service__c> lstService = [select Id, 
                                       BillingContract__r.AccountName__r.Name,
                                       SupplyPoint__c 
                                       from Service__c where SupplyPoint__c IN :lstSupplyPointId AND ServiceEndDate__c = NULL ORDER BY CreatedDate DESC];
        
        return lstService;
    }
    /******************************************************************************
	@author    		Echo: Swati Mathur
	@date      		29 May 2018
	@param			List<ReadingRequest__c> lstReadingRequest
	@return			List<ReadingRequest__c>
	@description 	Fetch the reading request and update status
	*******************************************************************************/
    public static List<ReadingRequest__c> changeReadingRequestStatus(List<ReadingRequest__c> lstReadingRequest){
        List<ReadingRequest__c> rrUpdatedList = new   List<ReadingRequest__c>();
        if(!lstReadingRequest.isEmpty()){
            for(ReadingRequest__c rr: [Select Id, Status__c from ReadingRequest__c where Id in:lstReadingRequest]){
                rr.Status__c = LoBt_Constants.READINGREQUESTEXPORTEDSTATUS;
                rrUpdatedList.add(rr);
            }
            rrUpdatedList = (List<ReadingRequest__c>) GlUt_FieldSecurity.cleanseFields(rrUpdatedList, false);
            update rrUpdatedList;
        }
        return rrUpdatedList;
    }
    /******************************************************************************
	@author    		Echo: Swati Mathur
	@date      		29 May 2018
	@param			Id brqId
	@return			BatchRequestQueue__c
	@description 	Change the BRQ status to Complete.
	*******************************************************************************/
    public static BatchRequestQueue__c changeBRQStatus(Id brqId,String status){  //AT-3204 Starts Here
        try{
            BatchRequestQueue__c brq = [select Id,
                                        Status__c
                                        from BatchRequestQueue__c where Id=: brqId];
            brq.Status__c = status;//AT-3204 Ends Here
            brq  = (BatchRequestQueue__c) GlUt_FieldSecurity.cleanseFields(brq, false);
            update brq;
            return brq;
        }
        catch (exception e){
            GlUt_Logger.logException(e);
            return null;
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }   
    }
    /******************************************************************************
    @author    		Echo: Swati Mathur
	@date      		29 May 2018
    @param			ReadPeriod__c rpEndDateAsCalcDate,Set<Id> deviceIds
    @return			List<Reading__c>
    @description 	Fetch the latest Billable Reading on the basis of Read Period end
                    Date and Device Ids.
    *******************************************************************************/
    public static List<Reading__c> getBillableReadings(Set<Id> deviceIds){
        List<Reading__c> latestBillableReadingList = [select Id,
                                                      Device__r.Name, //AT-3174
                                                      ActualDeviceReading__c,
                                                      ReadingDate__c,
                                                      ReadingMethod__c,
                                                      Device__c,//AT-3174
                                                      Reading__c
                                                      from Reading__c where Device__c IN :deviceIds AND BillableType__c =: GlUt_Constants.BILLABLE ORDER BY ReadingDate__c DESC];
        return latestBillableReadingList;     
    }
    /******************************************************************************
    @author    		Echo: Swati Mathur
	@date      		04 June 2018
    @param			Map<Id,SupplyPointDevice__c> mapOfSupplyPointId2SPD
    @return			List<AverageDailyUsage__c>
    @description 	Fetch ADU records on the basis of SPD.
    *******************************************************************************/
    public static List<AverageDailyUsage__c> getAverageDailyUsage(Map<Id,SupplyPointDevice__c> mapOfSupplyPointId2SPD){
        
        List<AverageDailyUsage__c> aduList =  [select Id,
                                              StartDate__c,
                                              EndDate__c,
                                              SupplyPointDevice__c,
                                              SupplyPointDevice__r.SupplyPoint__c,
                                              SupplyPointDevice__r.SupplyPoint__r.Location__r.LocationType__c,//CLB-118 Starts/Ends Here
                                              AverageDailyUsage__c
                                              from AverageDailyUsage__c where SupplyPointDevice__c IN:mapOfSupplyPointId2SPD.values()];
        return aduList;
    } 
    /******************************************************************************
    @author    		Echo: Swati Mathur
	@date      		04 June 2018
    @param			ReadPeriod__c rpEndDateAsCalcDate
    @return			List<ReadTimetableThresholds__c>
    @description 	Fetch readtimetablethreshold records on the basis of Readperiod TimeTable
    *******************************************************************************/
    public static List<ReadTimetableThresholds__c> getReadTimetableThresholds(List<Id> readTimetableIds){
        
        List<ReadTimetableThresholds__c> rtTableThresholdList = [SELECT ReadTimetable__c,
                                                                 DailyUsageThresholdStart__c,
                                                                 DailyUsageThresholdEnd__c,
                                                                 AcceptablePercentageVarianceBelow__c,
                                                                 AcceptablePercentageVarianceAbove__c,
                                                                 ThresholdMonths__c, //AT-5016
                                                                 AccountType__c//CLB-118 Starts/Ends Here
                                                                 FROM ReadTimetableThresholds__c
                                                                 WHERE ReadTimetable__c IN: readTimetableIds];
        return rtTableThresholdList;
    }
    /******************************************************************************
    @author    		Echo: Swati Mathur
	@date      		04 June 2018
    @description 	Wrapper Class to Hold the Lower and Higher Threshold Value.
    *******************************************************************************/
    public class CalculatingThresholdWrapper {
        public Map<Id,Decimal> mapOfRRId2LowerThresholdValues = new Map<Id,Decimal>(); 
        public Map<Id,Decimal> mapOfRRId2UpperThresholdValues = new Map<Id,Decimal>();
    }
    /******************************************************************************
    @author    		Echo: Swati Mathur
	@date      		04 June 2018
    @param			List<ReadingRequest__c> lstReadingRequest, 
                    Map<Id,Id> mapOfReadingReqId2SupplyPointId
                    List<Id> lstSupplyPointId
    @return			CalculatingThresholdWrapper
    @description 	Fetch the threshold Values 
    *******************************************************************************/
    public static CalculatingThresholdWrapper getThreshHoldValues(List<ReadingRequest__c> lstReadingRequest, Map<Id,Id> mapOfReadingReqId2SupplyPointId , List<Id> lstSupplyPointId){
        CalculatingThresholdWrapper ctWrapper = new CalculatingThresholdWrapper();
        Map<Id,List<AverageDailyUsage__c>> mapOfSupplyPointId2ADUList = new Map<Id,List<AverageDailyUsage__c>>(); 
        Map<Id,SupplyPointDevice__c> mapOfSupplyPointId2SPD = new Map<Id,SupplyPointDevice__c>();
        Map<Id,AverageDailyUsage__c> mapOfReadingReqId2ActiveADU = new Map<Id,AverageDailyUsage__c>(); 
        Map<Id,ReadTimetableThresholds__c> mapOfReadingReqId2RTThresholds = new Map<Id,ReadTimetableThresholds__c>();
        Map<Id,Reading__c> mapOfReadingReqId2LatestBillableReading = new Map<Id,Reading__c>();
        Map<Id,Date> mapOfReadingReqId2ReadByDate = new Map<Id,Date>();
        Map<Id,Id> mapOfReadingReqId2ReadTimetableId = new Map<Id,Id>();
        Map<Id,List<ReadTimetableThresholds__c>> mapOfRTId2rtThresholdList = new Map<Id,List<ReadTimetableThresholds__c>>();
        Map<Id,List<Reading__c>> mapOfDeviceId2ReadingList = new Map<Id,List<Reading__c>>();        
        
        try{                
            for(ReadingRequest__c objReadingReq: lstReadingRequest){                    
                mapOfReadingReqId2ReadByDate.put(objReadingReq.Id, objReadingReq.ReadbyDate__c);
                if(objReadingReq.SupplyPoint__r.Book__r.ReadTimetable__c != null){
                  mapOfReadingReqId2ReadTimetableId.put(objReadingReq.Id,objReadingReq.SupplyPoint__r.Book__r.ReadTimetable__c);
                }
            }
            
			if(!lstReadingRequest.isEmpty()){
				Set<Id> deviceIds = new Set<Id>();
                List<SupplyPointDevice__c> spdList = LoBt_ExportRequestedReadingsHelper.getSupplyPointDeviceList(lstSupplyPointId);
                for(SupplyPointDevice__c spd: spdList){
                    mapOfSupplyPointId2SPD.put(spd.SupplyPoint__c,spd);
                    deviceIds.add(spd.Device__c);
                }                
				//Fetch ADU record on the basis of SPD.
                if(!mapOfSupplyPointId2SPD.isEmpty()){
                    //get Adu list
                    List<AverageDailyUsage__c> aduList = getAverageDailyUsage(mapOfSupplyPointId2SPD);
                     
                    for(AverageDailyUsage__c adu: aduList){						
                        if(!mapOfSupplyPointId2ADUList.containsKey(adu.SupplyPointDevice__r.SupplyPoint__c)){
                            mapOfSupplyPointId2ADUList.put(adu.SupplyPointDevice__r.SupplyPoint__c, new List<AverageDailyUsage__c>());
                        }
                        mapOfSupplyPointId2ADUList.get(adu.SupplyPointDevice__r.SupplyPoint__c).add(adu);                        
                    }
                    for (Id rrId : mapOfReadingReqId2SupplyPointId.keySet()){
                        if(!mapOfSupplyPointId2ADUList.isEmpty() && mapOfReadingReqId2ReadByDate.containsKey(rrId) && mapOfReadingReqId2ReadByDate.get(rrId) != null &&
                           mapOfReadingReqId2SupplyPointId.containsKey(rrId) && mapOfReadingReqId2SupplyPointId.get(rrId) != null){
                               Date rpReadByDateAsCalcDate  = mapOfReadingReqId2ReadByDate.get(rrId);
                               if(mapOfSupplyPointId2ADUList.containsKey(mapOfReadingReqId2SupplyPointId.get(rrId)) &&
                                  mapOfSupplyPointId2ADUList.get(mapOfReadingReqId2SupplyPointId.get(rrId)) != null){
                                   List<AverageDailyUsage__c> spAduList = mapOfSupplyPointId2ADUList.get(mapOfReadingReqId2SupplyPointId.get(rrId));
                                   for(AverageDailyUsage__c adu: spAduList){ //End date check 
                                       if(adu.StartDate__c <= rpReadByDateAsCalcDate){
                                           if(adu.EndDate__c== null || adu.EndDate__c >= rpReadByDateAsCalcDate){
                                                mapOfReadingReqId2ActiveADU.put(rrId,adu); 
                                           }
                                       }
                                   }
                               }
                           }
                    }
                    
                }
                //Fetch Read Time Table Threshold on the basis of read period end date as Calculation Date.
                if(!mapOfReadingReqId2ReadTimetableId.isEmpty()){
                    List<ReadTimetableThresholds__c> rtThresholdList = getReadTimetableThresholds(mapOfReadingReqId2ReadTimetableId.Values());
                    if(rtThresholdList != null && rtThresholdList.size() > 0){
                        for(ReadTimetableThresholds__c rtThreshold : rtThresholdList){	
                            if(!mapOfRTId2rtThresholdList.containsKey(rtThreshold.ReadTimetable__c)){
                                mapOfRTId2rtThresholdList.put(rtThreshold.ReadTimetable__c, new List<ReadTimetableThresholds__c>());
                            }		
                            mapOfRTId2rtThresholdList.get(rtThreshold.ReadTimetable__c).add(rtThreshold);
                        }
                    }
                    // AT-5016
                    Map<Integer,String> monthsMap = new Map<Integer, String>{1 => 'January' , 2 => 'February' ,3 => 'March' ,4 => 'April' , 5 => 'May' ,
                                                                             6 => 'June' , 7 => 'July' , 8 => 'August' , 9 => 'September' ,
                                                                             10 => 'October' , 11=> 'November' ,12 => 'December'};     
                    for(Id rrId: mapOfReadingReqId2ReadTimetableId.keySet()){
                        Integer exportReadingMonth = mapOfReadingReqId2ReadByDate.get(rrId).month();  // AT-5016                        
                        if(!mapOfReadingReqId2ActiveADU.isEmpty() && !mapOfRTId2rtThresholdList.isEmpty() &&
                           mapOfReadingReqId2ReadTimetableId.containsKey(rrId) && mapOfReadingReqId2ReadTimetableId.get(rrId) != null){
                            for(ReadTimetableThresholds__c rtThreshold : mapOfRTId2rtThresholdList.get(mapOfReadingReqId2ReadTimetableId.get(rrId))){
                                List<String> thresholdMonths = new List<String>();    //  AT-5016
                                if(GlUt_RegionUtility.getAURegionCustomSetting() && rtThreshold.ThresholdMonths__c != null){ // AT-5016
                                    thresholdMonths = rtThreshold.ThresholdMonths__c.split(';');
                                }
                                //CLB-118 Starts/Ends Here
                                if(mapOfReadingReqId2ActiveADU.get(rrId).SupplyPointDevice__r.SupplyPoint__r.Location__r.LocationType__c != null && rtThreshold.AccountType__c == mapOfReadingReqId2ActiveADU.get(rrId).SupplyPointDevice__r.SupplyPoint__r.Location__r.LocationType__c){                                
                                    AverageDailyUsage__c adu = mapOfReadingReqId2ActiveADU.get(rrId);
                                    if(rtThreshold.DailyUsageThresholdStart__c <= adu.AverageDailyUsage__c && rtThreshold.DailyUsageThresholdEnd__c >= adu.AverageDailyUsage__c &&
                                       ((GlUt_RegionUtility.getAURegionCustomSetting() && thresholdMonths.contains(monthsMap.get(exportReadingMonth))) ||    // AT-5016
                                        (!GlUt_RegionUtility.getAURegionCustomSetting()) ) ){
                                            mapOfReadingReqId2RTThresholds.put(rrId,rtThreshold); 
                                        }
                                }
                            }
                        }
                    }  
                }
                // Fetch latest Billable Reading List
                List<Reading__c> billableReadingsList = getBillableReadings(deviceIds);
                for(Reading__c r : billableReadingsList){
                    if(!mapOfDeviceId2ReadingList.containsKey(r.Device__c)){
                         mapOfDeviceId2ReadingList.put(r.Device__c, new List<Reading__c>());
                        }		
                      mapOfDeviceId2ReadingList.get(r.Device__c).add(r);
                }
                 
                for (Id rrId : mapOfReadingReqId2SupplyPointId.keySet()){
                    if(!mapOfDeviceId2ReadingList.isEmpty() && !mapOfSupplyPointId2SPD.isEmpty()){
                        SupplyPointDevice__c spd = mapOfSupplyPointId2SPD.get(mapOfReadingReqId2SupplyPointId.get(rrId));
                        if(spd!= null){
                            List<Reading__c> billableReadingsforDevice = mapOfDeviceId2ReadingList.get(spd.Device__c);
                            for(Reading__c billableReading : billableReadingsforDevice){
                                if(!mapOfReadingReqId2LatestBillableReading.containsKey(rrId) && billableReading.ReadingDate__c < mapOfReadingReqId2ReadByDate.get(rrId)){
                                    mapOfReadingReqId2LatestBillableReading.put(rrId,billableReading);
                                }
                            }
                        }
                    }
                }
                Decimal lowerThresholdValue = 0.0;
                Decimal upperThresholdValue = 0.0;
                //Fetch the upper and Lower Threshold for Reading Requests
                for(ReadingRequest__c objRR: lstReadingRequest){
                    if(mapOfReadingReqId2ReadTimetableId.containsKey(objRR.Id) && mapOfReadingReqId2ReadTimetableId.get(objRR.Id) != null &&
                       mapOfReadingReqId2LatestBillableReading.containsKey(objRR.Id) && mapOfReadingReqId2LatestBillableReading.get(objRR.Id) != null &&
                       mapOfReadingReqId2ReadByDate.containsKey(objRR.Id) && mapOfReadingReqId2ReadByDate.get(objRR.Id) != null &&
                       mapOfReadingReqId2ActiveADU.containsKey(objRR.Id) && mapOfReadingReqId2ActiveADU.get(objRR.Id) != null && 
                       mapOfReadingReqId2RTThresholds.containsKey(objRR.Id) && mapOfReadingReqId2RTThresholds.get(objRR.Id) != null){
                           
                           Decimal latestBillableReading = mapOfReadingReqId2LatestBillableReading.get(objRR.Id).Reading__c;
                           Date latestBillableReadingDate = mapOfReadingReqId2LatestBillableReading.get(objRR.Id).ReadingDate__c;
                           
                           Date calculationDate = mapOfReadingReqId2ReadByDate.get(objRR.Id);
                           Integer daysDiff = latestBillableReadingDate.daysBetween(calculationDate);
                              
                           // Estimated Calculation = Average Daily Usage * (Days Between Last Reading Date and Calculation Date)  
                           Decimal estimateConsumption = mapOfReadingReqId2ActiveADU.get(objRR.Id).AverageDailyUsage__c * daysDiff;  
                           //Lower Threshold Value = Latest Billable Reading + (Estimated Consumption / 100 * Lower Threshold Percentage)
                           lowerThresholdValue = latestBillableReading + (estimateConsumption/100 * mapOfReadingReqId2RTThresholds.get(objRR.Id).AcceptablePercentageVarianceBelow__c);
                           //Upper Threshold Value = Latest Billable Reading + (Estimated Consumption / 100 * Upper Threshold Percentage)
                           upperThresholdValue = latestBillableReading + (estimateConsumption/100 * mapOfReadingReqId2RTThresholds.get(objRR.Id).AcceptablePercentageVarianceAbove__c); 
                         }
                    ctWrapper.mapOfRRId2LowerThresholdValues.put(objRR.Id,lowerThresholdValue);
                    ctWrapper.mapOfRRId2UpperThresholdValues.put(objRR.Id,upperThresholdValue);
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