/******************************************************************************
@author         Echo : Ankit Gangwani
@date           07 August 2018
@description    Component controller for manage service effective Date
******************************************************************************/
public class CuAp_ManageServiceEffectiveDateCtrlr {
    
    @TestVisible private static List<string> availableServiceList;
    
    private static final String CLASS_NAME = 'CuAp_ManageServiceEffectiveDateCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    static{
        availableServiceList = new List<String>();
        availableServiceList.add(LoAp_Constants.Id);
        availableServiceList.add(GlUt_APIConstantsService.SERVICESTARTDATEAPINAME);
        availableServiceList.add(GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME);
        
    }
    
    /**********************************************************************************************
    @author         Echo : Ankit Gangwani
    @date           07 August 2018
    @return         List<GLAp_FieldProps>
    @description    This method returns the services records based on available service ids
    **********************************************************************************************/
    @AuraEnabled
    public static List<Service__c> retrieveServiceFromAvailServices(List<AvailableService__c> availableServiceTransfers){
        
        Set<Id> availableserviceIds = new Set<Id>();        
        for(AvailableService__c objAS : availableServiceTransfers){
            availableserviceIds.add(objAS.Id);
        }
        
        /*List<Service__c> serviceList = [SELECT Id, ServiceStartDate__c, AvailableService__c FROM Service__c WHERE AvailableService__c = :availableServiceIds];*/
        List<Service__c> serviceList = (List<Service__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsService.SERVICEAPINAME,
                                                                                              new List<String>{LoAp_Constants.Id,
                                                                                                  GlUt_APIConstantsService.SERVICESTARTDATEAPINAME,
                                                                                                  GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME},
                                                                                              'WHERE ' + GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME + 
                                                                                              ' IN ' + GlUt_FieldSecurity.IdsToString(availableServiceIds)); 
        if(!serviceList.isEmpty())
            return serviceList;
        else
            return null;
    }
}