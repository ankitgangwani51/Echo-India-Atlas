/******************************************************************************
@author    		Echo: Tarun Gupta
@date      		22-June-2018
@description 	Utility class to get business days
*******************************************************************************/
public class GlUt_BusinessDays {
    
    private List<Boolean> businessDay = new Boolean[7];
    private Date knownSunday = date.newInstance(1900, 02, 18);
    private List<Holiday> holidays = new List<Holiday>();
    private List<Date> listWeekDates = new List<Date>();
    
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		22-June-2018
    @description 	Constructor creates businessDay array
    *******************************************************************************/
    public GlUt_BusinessDays() {
        
        holidays=[Select StartTimeInMinutes, Name, ActivityDate From Holiday Limit 50000]; /*AT-4374, Clayton Code Review Starts/Ends Here */
        
        BusinessHours bh = [Select
                            SundayStartTime, MondayStartTime, TuesdayStartTime,
                            WednesdayStartTime, ThursdayStartTime, FridayStartTime,
                            SaturdayStartTime
                            From BusinessHours 
                            Where IsDefault=true];
        
        businessDay[0] = (bh.SundayStartTime != null);
        businessDay[1] = (bh.MondayStartTime != null);
        businessDay[2] = (bh.TuesdayStartTime != null);
        businessDay[3] = (bh.WednesdayStartTime != null);
        businessDay[4] = (bh.ThursdayStartTime != null);
        businessDay[5] = (bh.FridayStartTime != null);
        businessDay[6] = (bh.SaturdayStartTime != null);                
    }
    
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		22-June-2018
    @description 	Method to calculate business days
    @params			Pass startdate and number of days notice
    @return			Date - It will return date 
    *******************************************************************************/    
    public Date addBusinessDays(Date startDate, Integer numberOfDays){
        Date returnDate = startDate;
        
        //Get last Date
        for (integer x = 0; x < numberOfDays; x++){
            returnDate = nextBusinessDay(returnDate);
        }
        
        //Prepare count of holidays from selected dates above
        if(!listWeekDates.isEmpty()){
            Integer iCountHolidays = 0;
            for(Date objDate : listWeekDates){
                
                if(checkifWorkDay(objDate)){
                    iCountHolidays += 1;
                }
            }
            
            //Add number of days to last date based on holidays
            if(iCountHolidays != 0){
                for (Integer x = 0; x < iCountHolidays; x++){
                    returnDate = nextBusinessDay(listWeekDates[listWeekDates.size() - 1]);
                }
            }
        }
        
        return returnDate;
    }
    
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		22-June-2018
    @description 	Returns back the next available business day
    *******************************************************************************/
    public Date nextBusinessDay(Date d){
        
        Integer i = Math.mod(this.knownSunday.daysBetween(d),7);
        Date returnDate = d;
        
        do {
            returnDate = returnDate.addDays(1);            
            i++;
        } while (!businessDay[Math.mod(i, 7)]);
        
        listWeekDates.add(returnDate);
        
        return returnDate;
    }
    
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		22-June-2018
    @description 	Returns Boolean if its a holiday
    *******************************************************************************/
    public boolean checkIfWorkDay(Date sentDate){        
        
        Boolean isHoliday = false;
        
        for(Holiday hday:holidays){      
            if(hday.ActivityDate == sentDate){
                isHoliday = true;                
            }           
            
            if(isHoliday)
                break;
        }
        return isHoliday;
    }
    
}