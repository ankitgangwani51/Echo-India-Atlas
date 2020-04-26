/******************************************************************************
@author        Accenture: Manish Singh
@date          07 Dec 2017
@description   Class for GlUt_ReadingUtilities 
*******************************************************************************/
public with sharing class GlUt_ReadingUtilities {
  private static final String CLASS_NAME = 'GlUt_ReadingUtilities';
  private static final String DEBUG = '[' + CLASS_NAME + '] ';
  
  /******************************************************************************
  @author        Accenture: Manish Singh
  @date          07 Dec 2017
  @param      
  @return      Decimal estimated reading between that date
  @description  return estimated reading to be added to previous reading for the given dates
  *******************************************************************************/
  public static double hasActiveContract(String suplyPointDevice, String startDate, String endDate ) {
    double  estimateReading = 0;
    integer daysDifference =0;
    integer i =0;
    Date startDay = Date.valueof(startDate);
    Date endDay = Date.valueof(endDate);
    daysDifference = startDay.daysBetween(endDay);
    List<AverageDailyUsage__c> listDailyUses = new List<AverageDailyUsage__c>();
    listDailyUses = [SELECT Id, StartDate__c, AverageDailyUsage__c, SupplyPointDevice__c, EndDate__c FROM AverageDailyUsage__c where SupplyPointDevice__c =:suplyPointDevice
        order by  EndDate__c desc LIMIT 1];
    if(listDailyUses.size() > 0){
        estimateReading  = listDailyUses[i].AverageDailyUsage__c*daysDifference ;
        return estimateReading  ;
    } 
    return null;  
  }
    
    /**********************************************************************************************
	@author         Echo: Vivek AT-3855
	@date           10-Oct-2018
	@param          Id supplyPointdeviceId , Integer lastReading , Integer currentReading , Date LastReadingDate , Date CurrentReadingDate)
	@return         Boolean 
	@description    validate Consumption Threshold
	@Revisions      
	**********************************************************************************************/   
    @AuraEnabled
    public static String validateConsumptionThreshold(Id supplyPointdeviceId , Integer lastReading , Integer currentReading , Date LastReadingDate , Date CurrentReadingDate) {
        
        AverageDailyUsage__c aduObj;
        ReadTimetableThresholds__c rtTableThresholdObj;
        aduObj = getAverageDailyUsage(supplyPointdeviceId , CurrentReadingDate);
        
        if(aduObj == null)
            return  GlUt_Constants.ADUINACTIVE;
        
        // AT-5014 start...
        Integer newReadingMonth = CurrentReadingDate.month();
        Map<Integer,String> monthsMap = new Map<Integer, String>{1 => 'January' , 2 => 'February' ,3 => 'March' ,4 => 'April' , 5 => 'May' ,
            													 6 => 'June' , 7=> 'July' , 8 => 'August' , 9 => 'September' ,
            													 10 => 'October' , 11=> 'November' ,12 => 'December'};  
        // AT-5014 end...
        
        if(aduObj.AverageDailyUsage__c != null)    
            rtTableThresholdObj = getReadTimetableThresholds(supplyPointdeviceId , aduObj.AverageDailyUsage__c, monthsMap.get(newReadingMonth));    // AT-5014
        
        if(rtTableThresholdObj == null)
            return GlUt_Constants.READTIMETABLETHRESHOLDINVALID;
        
        Integer daysDiff = LastReadingDate.daysBetween(CurrentReadingDate); 
        Decimal estimateConsumption = aduObj.AverageDailyUsage__c * daysDiff ;
        
        //Latest Billable Reading + (Estimated Consumption / 100 * Lower Threshold Percentage)
        Decimal lowerThresholdValue = Decimal.valueOf(lastReading) + estimateConsumption/100 * rtTableThresholdObj.AcceptablePercentageVarianceBelow__c;
        
        //Upper Threshold Value = Latest Billable Reading + (Estimated Consumption / 100 * Upper Threshold Percentage)
        Decimal upperThresholdValue = Decimal.valueOf(lastReading) + estimateConsumption/100 * rtTableThresholdObj.AcceptablePercentageVarianceAbove__c;
       
        if(currentReading > Integer.valueOf(upperThresholdValue)) 
              return GlUt_Constants.READINGREJECTEDUPPER;   
        
        return  GlUt_Constants.NOERROR;
    }
    
    /******************************************************************************
	@author         Echo: Vivek AT-3855
	@date           10-Oct-2018
    @param          SupplyPointDevice__c, ReadingDate__c
    @return         AverageDailyUsage__c
    @description    Fetch ADU records on the basis of SPD.
    *******************************************************************************/
    public static AverageDailyUsage__c getAverageDailyUsage(Id supplyPointDevice , Date readingDate){
        List<AverageDailyUsage__c> aduList =  [select Id,
                                               StartDate__c,
                                               EndDate__c,
                                               SupplyPointDevice__c,
                                               AverageDailyUsage__c
                                               from AverageDailyUsage__c 
                                               where SupplyPointDevice__c =:supplyPointDevice 
                                               and StartDate__c <=: readingDate
                                               and (EndDate__c = null or EndDate__c >=: readingDate) limit 1 ];
        
        
        if(aduList != null && !aduList.isEmpty())
            return aduList[0];
        else
            return null;
    } 
    
    /******************************************************************************
	@author         Echo: Vivek AT-3855
	@date           10-Oct-2018
    @param          SupplyPointDevice__c, averageDailyUsage
    @return         ReadTimetableThresholds__c 
    @description    Fetch ReadTimetableThresholds records on the basis of SPD.
					added new param currentReadingMonth  AT-5014
    *******************************************************************************/
    public static ReadTimetableThresholds__c getReadTimetableThresholds(Id supplyPointDevice , decimal averageDailyUsage, String currentReadingMonth){
        List<ReadTimetableThresholds__c> rtTableThresholdList = new  List<ReadTimetableThresholds__c>();
        List<SupplyPointDevice__c> spdList = [SELECT Id ,
                                              SupplyPoint__r.Book__r.ReadTimeTable__c 
                                              FROM SupplyPointDevice__c  WHERE Id =: supplyPointDevice LIMIT 1 ]; 
    
        if(spdList != null && !spdList.isEmpty() && spdList[0].SupplyPoint__r.Book__r.ReadTimeTable__c != null) {
            // AT-5014 start...
            for(ReadTimetableThresholds__c objRTTT: [SELECT ReadTimetable__c,ThresholdMonths__c,
                                                     AcceptablePercentageVarianceBelow__c,
                                                     AcceptablePercentageVarianceAbove__c
                                                     FROM ReadTimetableThresholds__c
                                                     WHERE ReadTimetable__c =: spdList[0].SupplyPoint__r.Book__r.ReadTimeTable__c 
                                                     AND DailyUsageThresholdStart__c <=: averageDailyUsage 
                                                     AND DailyUsageThresholdEnd__c >=: averageDailyUsage]){
            	if(GlUt_RegionUtility.getAURegionCustomSetting() && objRTTT.ThresholdMonths__c != null){
                    List<String> thresholdMonths = objRTTT.ThresholdMonths__c.split(';');
                   	if(thresholdMonths.contains(currentReadingMonth)){
                        rtTableThresholdList.add(objRTTT);
                        break;
                    }
                }else if(!GlUt_RegionUtility.getAURegionCustomSetting()){
                	rtTableThresholdList.add(objRTTT);
                    break;
                }
            } 
        }      
        if(rtTableThresholdList != null && !rtTableThresholdList.isEmpty())
            return rtTableThresholdList[0];                                      
        else
            return null;
    }  
}