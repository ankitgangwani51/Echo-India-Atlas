/******************************************************************************
@author      	Echo: Gopal Gupta
@date      		06-Nov-2017
@description	Component controller for Additional Biller wizard page
*******************************************************************************/
public with sharing class CuAp_AdditionalBillerPageCtrlr {
    
    private static List<String> occupancyTypeOptions;
    
    private static final String CLASS_NAME = 'CuAp_AdditionalBillerPageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    /******************************************************************************
	@author      	Echo: Gopal Gupta
	@date      		06-Nov-2017
	@param			none
	@return			List<String> - returns the list of picklist values and set in an attribute in the component
	@description	get the picklist options of Occupancy Type field of the Location Occupant object
	*******************************************************************************/
    private static List<String> getOccupancyTypeOptions() {
    	if (occupancyTypeOptions == null) {
	        occupancyTypeOptions = new List<String>();
	        List<GlAp_FieldProps> fldProps = GlUt_FieldSecurity.getFieldPropertiesObject(CuAp_Constants.LOCATIONOCCUPANTAPI, 
	        																			new List<String>{CuAp_Constants.OCCUPANCYTYPEAPI});
	        for (GlAp_FieldProps fp : fldProps) {
	            if (fp.isFLSVisible) {
	                occupancyTypeOptions.addAll(fp.pickListEntries.Values());
	                if (occupancyTypeOptions.size() > 0 && occupancyTypeOptions.get(0) == '')
						occupancyTypeOptions.remove(0);
	            }
	        }
    	}
        return occupancyTypeOptions;
    }
    
    /******************************************************************************
	@author      	Echo: Gopal Gupta
	@date      		06-Nov-2017
	@return			BillerInfo
	@description	This method adds a biller row in the component
	*******************************************************************************/
    @AuraEnabled
    public static BillerInfo addBiller() {
        BillerInfo billerInfoObj = new BillerInfo();
        
        try {
            billerInfoObj.acc = new Account();
            billerInfoObj.locOcc = new LocationOccupant__c();
            billerInfoObj.occTypeOptions = getOccupancyTypeOptions();
            billerInfoObj.displayFields = CuAp_Constants.ACCDISPLAYFIELDS;
            billerInfoObj.accFieldValues = new List<String>();
            for(String fld : billerInfoObj.displayFields.split(',')){
                billerInfoObj.accFieldValues.add('');
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return billerInfoObj;
    }
    
    /******************************************************************************
	@author      	Echo: Gopal Gupta
	@date      		06-Nov-2017
	@param			none
	@return			none
	@description	wrapper class to hold the biller information
	*******************************************************************************/
    public class BillerInfo {
        @AuraEnabled public Account acc;
        @AuraEnabled public LocationOccupant__c locOcc;
        @AuraEnabled public List<String> occTypeOptions;
        @AuraEnabled public String displayFields;
        @AuraEnabled public List<String> accFieldValues;
        @AuraEnabled public String occTypeValue;
    }
}