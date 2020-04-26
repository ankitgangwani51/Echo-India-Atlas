/******************************************************************************
@author         Amit K.
@date           20-Feb-2019
@description    Utility class used to segregate the code on the basis of Region(AT-5296)
*******************************************************************************/
public with sharing class GlUt_RegionUtility {
    private static Region__c objRegionSettings = Region__c.getOrgDefaults();
     
    /**********************************************************************************************
    @author      : ECHO: Amit K.
    @date        : 20-Feb-2019
    @Param       : NA
    @return      : Boolean
    @description : Method used to segregate the AU specific code. 
    **********************************************************************************************/
    public static Boolean getAURegionCustomSetting() {
        
        return objRegionSettings.AU__c; 
    }
    /**********************************************************************************************
    @author      : ECHO: Amit K.
    @date        : 20-Feb-2019
    @Param       : NA
    @return      : Boolean
    @description : Method used to segregate the UK specific code. 
    **********************************************************************************************/
    public static Boolean getUKRegionCustomSetting() {
        
        return objRegionSettings.UK__c; 
    }
    /**********************************************************************************************
    @author      : ECHO: Amit K.
    @date        : 20-Feb-2019
    @Param       : NA
    @return      : Boolean
    @description : Method used to segregate the US specific code. 
    **********************************************************************************************/
    public static Boolean getUSRegionCustomSetting() {
        
        return objRegionSettings.US__c; 
    }
    

}