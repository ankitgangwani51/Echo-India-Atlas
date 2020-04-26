/******************************************************************************
@author         Echo: Vivek Sethi
@date           07 Dev 2018
@description    Wrapper class for Renewal Batch Process
@revision(s)    
*******************************************************************************/
public with sharing class LoBt_EntitlementRenewalWrapper {
    public Integer SeasonalAllocation; 
    public Date RenewalDate ;
    
    /**********************************************************************************************
  	@author      : Echo: Vivek Sethi
	@date        : 07 Dev 2018
    @params      : String json
    @return      : LoBt_EntitlementRenewalWrapper
    @description : This method is used to Deserialize the parse JSON string.
    **********************************************************************************************/
    public static LoBt_EntitlementRenewalWrapper parse(String json) {
        return (LoBt_EntitlementRenewalWrapper) System.JSON.deserialize(json, LoBt_EntitlementRenewalWrapper.class);
    }
}