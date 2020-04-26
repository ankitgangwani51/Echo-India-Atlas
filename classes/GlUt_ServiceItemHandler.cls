/***************************************************************************************************
@author         Echo : Dependra Singh
@date           10-Jan-2018
@description    This is helper class used by Service Item object trigger  
@group          TriggerHelper
Revision(s)   
*******************************************************************************************************/
public with sharing class GlUt_ServiceItemHandler extends GlUt_TriggerHandlerBase{

    private static final String CLASS_NAME = 'GlUt_ServiceItemHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    // Variable declaration
    
    // End variable declaration
    
    /**********************************************************************************************
    @author         Echo: Dependra Singh
    @date           10-Jan-2018
    @param          GlUt_TriggerHandlerObj inputParam
    @return         void
    @description    This method is used to invoke method from trigger
    **********************************************************************************************/
    public override void  MainEntry(GlUt_TriggerHandlerObj inputParam) {
        try {
            if (inputParam.isInsert && inputParam.isBefore) {
                preventDuplicateServiceItem(inputParam.newlist);
                updateDischargeFactor(inputParam.newlist);
            }
            if (inputParam.isInsert && inputParam.isAfter) {
                //Start of AT - 2766
                createSupplyPointAllowance(inputParam.newmap);
                //End of AT - 2766
            }
            if (inputParam.isUpdate && inputParam.isBefore) {
                preventDuplicateServiceItem(inputParam.newlist);
                createDuplicateServiceItem(inputParam.newmap, inputParam.oldMap, inputParam.isBefore);  // AT-4907
            }
            if (inputParam.isUpdate && inputParam.isAfter) {
                createDuplicateServiceItem(inputParam.newmap, inputParam.oldMap, false);  // AT-4907
            }  
            if (inputParam.isDelete && inputParam.isBefore) {
                
            }
            if (inputParam.isDelete && inputParam.isAfter) {
                
            }  
        }
        catch (Exception ex) {
            system.debug(DEBUG + 'Line Number: ' + ex.getLineNumber());
            system.debug(DEBUG + 'Error Message: ' + ex.getMessage());
            system.debug(DEBUG + 'Stack Trace: ' + ex.getStackTraceString());
            GlUt_Logger.logException(ex);
            GlUt_Logger.writeLogsToDatabase();
            
        }

        finally {   
            //Reset the active function to null in case this class was first in stack
            //this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
           
        }
    
    }
    
    /**********************************************************************************************
    @author         Echo: Dependra Singh
    @date           10-Jan-2018
    @param          Map<Id, SObject> newMap
    @description    This method is used to to prevent duplicate service item.
    Revision(s)     10 Jan 2018, P Dixon - added Id check to prevent updates from failing
    **********************************************************************************************/ 
    public void preventDuplicateServiceItem(List<SObject> newlist) {
        //Start  Initializing variables    
        set<Id> serviceIds = new set<Id>();
        set<Id> availableServiceItemIds = new set<Id>();
        set<Id> serviceItemTypeIds = new set<Id>();
        Map<Id,Id> mapOfServiceIdToSPId = new Map<Id,Id>();        
        Map<Id, SupplyPoint__c>  mapSupplyPointById;        
        Map<Id, String> uniqueCombinationMap = new Map<Id, String>();
        //End Initializing variables 

        // Checking if list is not empty   
        if (!newlist.isEmpty()) {
            
            for (ServiceItem__c objServiceItem : (List<ServiceItem__c>)newlist) {
                
                if (objServiceItem.Service__c != null) {
                    serviceIds.add(objServiceItem.Service__c);
                }
                if (objServiceItem.AvailableServiceItem__c != null) {
                    availableServiceItemIds.add(objServiceItem.AvailableServiceItem__c);
                }
                if (objServiceItem.ServiceItemType__c != null) {
                    serviceItemTypeIds.add(objServiceItem.ServiceItemType__c); 
                }
            }            
            
            if(serviceIds.size() > 0 && availableServiceItemIds.size() > 0 && serviceItemTypeIds.size() > 0){
                // Creating unique combination.
                for (ServiceItem__c objServiceItemExisting : [SELECT Id,Service__c,AvailableServiceItem__c,ServiceItemType__c 
                                                              FROM ServiceItem__c 
                                                              WHERE Service__c in :serviceIds 
                                                              AND AvailableServiceItem__c in :availableServiceItemIds 
                                                              AND ServiceItemType__c in :serviceItemTypeIds]) {
                                                                  
                                                                  String uniqueCombination;                                              
                                                                  if (objServiceItemExisting.AvailableServiceItem__c != null && objServiceItemExisting.ServiceItemType__c != null) {
                                                                      uniqueCombination = string.valueOf(objServiceItemExisting.Service__c)
                                                                          + string.valueOf(objServiceItemExisting.AvailableServiceItem__c) 
                                                                          + string.valueOf(objServiceItemExisting.ServiceItemType__c);
                                                                      
                                                                      uniqueCombinationMap.put(objServiceItemExisting.Id, uniqueCombination);
                                                                  }
                                                              }
            }
            
            // convert list to set
            Set<String> uniqueCombinations = new Set<String>();
            uniqueCombinations.addAll(uniqueCombinationMap.values());
            
            // Prevent creation if a different record with the same combination already exist.
            for (ServiceItem__c objServiceItemNew : (List<ServiceItem__c>)newlist) {
                
                if (objServiceItemNew.AvailableServiceItem__c != null && objServiceItemNew.ServiceItemType__c != null) {
                   String uniqueCombination;
                    uniqueCombination = String.valueOf(objServiceItemNew.Service__c)
                                                + String.valueOf(objServiceItemNew.AvailableServiceItem__c) 
                                                + String.valueOf(objServiceItemNew.ServiceItemType__c);
                                                    
                    if ((!uniqueCombinationMap.keySet().contains(objServiceItemNew.Id) || uniqueCombinationMap.get(objServiceItemNew.Id) != uniqueCombination)
                            && uniqueCombinations.contains(uniqueCombination)) {
                    //As discussed with Gopal edited the below error to proceed the development of Activate AvailableBundle                                 
                        //objServiceItemNew.addError(System.Label.GlUt_ServiceItemDuplicateMessage);
                    }
                }
            }
        }
    }
    
    /**********************************************************************************************
    @author         Echo: Mohit Tayal
    @date           26-June-2018
    @param          Map<Id, SObject> newMap
    @description    AT - 2766 This method is used to to create new supply point allowance.
    Revision(s)     
    **********************************************************************************************/ 
    public void createSupplyPointAllowance(Map<Id,sObject> newMap) {
        Set<Id> setOfServiceItemFamily = new Set<Id>();
        Set<Id> setOfSupplyPointUsageType = new Set<Id>();
        Map<Id,ServiceItem__c> mapOfServiceItemFamilyIdToServiceItem = new Map<Id,ServiceItem__c>();
        for(ServiceItem__c objServiceItem : [SELECT Id, StartDate__c, Service__r.SupplyPoint__c, 
                                                    ServiceItemType__r.ServiceItemFamily__c, Service__r.SupplyPoint__r.SupplyPointUsageType__c 
                                             FROM ServiceItem__c 
                                             WHERE Id IN :newMap.keySet()]){
            if(objServiceItem.ServiceItemType__r.ServiceItemFamily__c != null)
                setOfServiceItemFamily.add(objServiceItem.ServiceItemType__r.ServiceItemFamily__c);
            if(objServiceItem.Service__r.SupplyPoint__r.SupplyPointUsageType__c != null)
                setOfSupplyPointUsageType.add(objServiceItem.Service__r.SupplyPoint__r.SupplyPointUsageType__c);
            if(objServiceItem.ServiceItemType__r.ServiceItemFamily__c != null)
                mapOfServiceItemFamilyIdToServiceItem.put(objServiceItem.ServiceItemType__r.ServiceItemFamily__c,objServiceItem);
        }
               
        if(!setOfServiceItemFamily.isEmpty() && !setOfSupplyPointUsageType.isEmpty()){
            List<SupplyPointAllowance__c> lstSupplyPointAllowance = new List<SupplyPointAllowance__c>();
        
            for(AllowanceType__c objAllowanceType : [SELECT Id, AllowancePriority__c, 
                                                      AllowanceAmount__c, StartDate__c,  
                                                      Type__c, ServiceItemFamily__c 
                                                      FROM AllowanceType__c 
                                                      WHERE Active__c = TRUE 
                                                      AND ServiceItemFamily__c IN :setOfServiceItemFamily
                                                      AND SupplyPointUsageType__c IN :setOfSupplyPointUsageType]){
                                                          
                if(objAllowanceType != null && mapOfServiceItemFamilyIdToServiceItem.containsKey(objAllowanceType.ServiceItemFamily__c)){
                    ServiceItem__c objServiceItem = mapOfServiceItemFamilyIdToServiceItem.get(objAllowanceType.ServiceItemFamily__c);
                    SupplyPointAllowance__c objSupplyPointAllowance = new SupplyPointAllowance__c();
                    objSupplyPointAllowance.AllowanceAmount__c = objAllowanceType.AllowanceAmount__c; 
                    objSupplyPointAllowance.AllowancePriority__c = objAllowanceType.AllowancePriority__c;
                    objSupplyPointAllowance.ServiceItem__c = objServiceItem.Id;
                    objSupplyPointAllowance.AllowanceType__c = objAllowanceType.Id;
                    objSupplyPointAllowance.Type__c = objAllowanceType.Type__c;
                    objSupplyPointAllowance.StartDate__c = (objAllowanceType.StartDate__c > objServiceItem.StartDate__c ? objAllowanceType.StartDate__c : objServiceItem.StartDate__c);
                    objSupplyPointAllowance.SupplyPoint__c = objServiceItem.Service__r.SupplyPoint__c;
                    lstSupplyPointAllowance.add(objSupplyPointAllowance);
                }
            }
            if(lstSupplyPointAllowance != null && !lstSupplyPointAllowance.isEmpty()){
                lstSupplyPointAllowance = (List<SupplyPointAllowance__c>) GlUt_FieldSecurity.cleanseFields(lstSupplyPointAllowance, false);
                Database.insert(lstSupplyPointAllowance);
            }
        }
    }
    
    /**********************************************************************************************
    @author        Neha R. 
    @date          16 Jan 2019 
    @param         Map<Id, SObject> newMap, Map<Id,sObject> oldMap, Boolean isBefore
    @description   Method to create/Update Service item on the basis of suspend end date  
    **********************************************************************************************/ 
    public void createDuplicateServiceItem(Map<Id, SObject> newMap, Map<Id,sObject> oldMap, Boolean isBefore) {
        
        List<ServiceItem__c> newCreatedSIList = new List<ServiceItem__c>();
        List<Id> serviceIdList = new List<Id>();
         
        for(ServiceItem__c newServiceItem : (List<ServiceItem__c>)newMap.values()){ 
            
            // old Service Item Values...
            ServiceItem__c oldServiceItem = (ServiceItem__c)oldMap.get(newServiceItem.Id);
            
            //Before Trigger: If old Suspend end date was not blank and not equal to New Suspend End date
            if(isBefore){
                if(oldServiceItem.SuspendEndDate__c != null && newServiceItem.SuspendEndDate__c != oldServiceItem.SuspendEndDate__c)
                    serviceIdList.add(newServiceItem.Service__c);                
            }else{    // After trigger...
                
                //If old Suspend End date was blank and New Suspend End field has a date 
                if(oldServiceItem.SuspendEndDate__c == null && newServiceItem.SuspendEndDate__c != null){
                    ServiceItem__c objServiceItem = new ServiceItem__c();
                    objServiceItem = newServiceItem.clone();
                    objServiceItem.StartDate__c = newServiceItem.SuspendEndDate__c + 1 ;
                    objServiceItem.EndDate__c = newServiceItem.EndDateResume__c ;
                    objServiceItem.SuspendEndDate__c = null;
                    objServiceItem.EndDateResume__c = null;
                    newCreatedSIList.add(objServiceItem);
                }
            }
        }
       
        if(!newCreatedSIList.isEmpty()){
            database.insert(newCreatedSIList);            
        }
          
        if(isBefore && !serviceIdList.isEmpty()){
            Map<Id,List<ServiceItem__c>> ServiceIdOfexistingSIRecords = new Map<Id,List<ServiceItem__c>>();
            
            // Listed all Service Item on Service
            for(ServiceItem__c objServiceItem: [SELECT Id,Service__c,StartDate__c,SuspendEndDate__c
                                                FROM ServiceItem__c
                                                WHERE Service__c IN: serviceIdList]){
                if(ServiceIdOfexistingSIRecords.containsKey(objServiceItem.Service__c)){
                    ServiceIdOfexistingSIRecords.get(objServiceItem.Service__c).add(objServiceItem);                    
                }else{
                    ServiceIdOfexistingSIRecords.put(objServiceItem.Service__c,new List<ServiceItem__c>{objServiceItem});
                }                                                    
            }
            List<ServiceItem__c> updatedSIList = new List<ServiceItem__c>();
            if(!ServiceIdOfexistingSIRecords.isEmpty()){
                for(ServiceItem__c oldServiceItem : (List<ServiceItem__c>)oldMap.values()){
                    for(ServiceItem__c existingServiceItem : ServiceIdOfexistingSIRecords.get(oldServiceItem.Service__c)){
                        if(existingServiceItem.StartDate__c == oldServiceItem.SuspendEndDate__c + 1 && existingServiceItem.Id != oldServiceItem.Id ){
                            ServiceItem__c newServiceitem = (ServiceItem__c)newMap.get(oldServiceItem.Id);
                            existingServiceItem.StartDate__c = newServiceitem.SuspendEndDate__c + 1;
                            updatedSIList.add(existingServiceItem);
                        }                        
                    }
                }                
            }
            if(!updatedSIList.isEmpty()){
                updatedSIList = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(updatedSIList, false);// CLB-125- Issues identified by Clayton- 08-04-2019
                database.update(updatedSIList);
            }
        }      
    }
    
    /**********************************************************************************************
    @author         Echo: Ankit Gangwani
    @date           15-04-2019
    @param          Map<Id, SObject> newMap
    @description    This method is used to to Update Discharge factor from Supply Point Usage Type.
    **********************************************************************************************/ 
    public void updateDischargeFactor(List<SObject> newlist) {
        set<Id> serviceIds = new set<Id>();
        Map<Id,Id> mapOfServiceIdToSPId = new Map<Id,Id>(); 
        Map<Id, SupplyPoint__c>  mapSupplyPointById;    
        
        // Checking if list is not empty   
        if (!newlist.isEmpty()) {
            for (ServiceItem__c objServiceItem : (List<ServiceItem__c>)newlist) {
                if (objServiceItem.Service__c != null) {
                    serviceIds.add(objServiceItem.Service__c);
                }
            }
            
            if(serviceIds.size() > 0){
                for(Service__c objService : [SELECT Id, SupplyPoint__c FROM Service__c WHERE Id IN :serviceIds]){
                    if(objService.SupplyPoint__c != null){
                        if(!mapOfServiceIdToSPId.containsKey(objService.Id))
                            mapOfServiceIdToSPId.put(objService.Id,objService.SupplyPoint__c);                        
                    }
                    
                }
                
                if(mapOfServiceIdToSPId.size() > 0){
                    mapSupplyPointById = new Map<Id, SupplyPoint__c>([Select Id,SupplyPointUsageType__r.DischargeFactor__c 
                                                                      FROM SupplyPoint__c 
                                                                      WHERE Id IN  :mapOfServiceIdToSPId.values() 
                                                                      AND SupplyPointUsageType__r.DischargeFactor__c != null]);
                }
            }
            
            for (ServiceItem__c objServiceItemNew : (List<ServiceItem__c>)newlist) {                
                if(mapOfServiceIdToSPId.containsKey(objServiceItemNew.Service__c) && 
                   mapSupplyPointById != null && mapSupplyPointById.containsKey(mapOfServiceIdToSPId.get(objServiceItemNew.Service__c))){
                        objServiceItemNew.DischargeFactor__c = mapSupplyPointById.get(mapOfServiceIdToSPId.get(objServiceItemNew.Service__c)).SupplyPointUsageType__r.DischargeFactor__c;                     
                }
            }
        }
    }
}