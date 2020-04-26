/******************************************************************************
@author         Echo: Vivek Sethi
@date           12 July 2018
@description    Handler for Service Trigger 
*******************************************************************************/
public with sharing class GlUt_ServiceHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_ServiceHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';


    /******************************************************************************
	@author         Echo: Vivek Sethi
	@date           12 July 2018
	@param          GlUt_TriggerHandlerObj - inputParam
	@description    This method handles the initial invocation of the trigger
	*******************************************************************************/
    public override void MainEntry(GlUt_TriggerHandlerObj inputParam) {
        try {
            if (inputParam.isInsert && inputParam.isBefore) {
               volumePercentage(inputParam.newlist, inputParam.oldmap);
            }
            if (inputParam.isInsert && inputParam.isAfter) {
            }
            if (inputParam.isUpdate && inputParam.isBefore) {
               volumePercentage(inputParam.newlist, inputParam.oldmap);
            }
            if (inputParam.isUpdate && inputParam.isAfter) {
                volumePercentageAmendments(inputParam.newlist, inputParam.oldmap);    //AT-3454
            }
            if (inputParam.isDelete && inputParam.isBefore) {
                
            }
            if (inputParam.isDelete && inputParam.isAfter) {
                
            }
        } catch (Exception ex) {
            system.debug('Line Number:=' + ex.getLineNumber());
            system.debug('Line Number:=' + ex.getMessage());
            system.debug('Line Number:=' + ex.getStackTraceString());
            GlUt_Logger.logException(ex);
            GlUt_Logger.writeLogsToDatabase();
            
        } finally {
            //Reset the active function to null in case this class was first in stack
            //this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            
            
        }
    }
    /**********************************************************************************************
    @author         Echo: Amit K.
    @date           28-Mar-2019
    @param          GlUt_TriggerHandlerObj inputParam
    @return         void
    @description    This method overides the InProgressEntry in the base class. This is 
                    only necessary where special handling is required in the event that a trigger
                    causes another trigger to fire and subsequnet invocation is supressed
    **********************************************************************************************/
    public override void inProgressEntry(GlUt_TriggerHandlerObj inputParam) {   
        if (inputParam.TriggerObject == GlUt_Constants.OBJSERVICE) {  
            //Suppress recursion
        } else { //Otherwise invoke the default version of the tigger
            //Running standard trigger
            super.InProgressEntry(inputParam);
        }
    }
    /******************************************************************************
	@author         ECHO: Vivek Sethi
	@date           12 July 2018
	@param          List<Service__c> newlist
	@description    Volume percentage for the Trade Effluent and validating its total Volume Percentage
	@return         void
    @Revision       Echo: Amit K. (Sanity Issue SIT005)
    *******************************************************************************/
    public void volumePercentage(List<Service__c> newlist , Map<Id, Sobject> oldMap) {
   
        Map<Id,String> serviceServiceTypeNameMap = new Map<Id,String>();
        Map<Id,Decimal> volumePercentageTEMap = new Map<Id,Decimal>();
        Map<Id,Decimal> volumePercentageSewMap = new Map<Id,Decimal>();
        List<Id> serviceServiceTypeList = new List<Id>();
        List<Service__c> serviceupdatelist = new List<Service__c>(); 

        for(Service__c serviceObj : newlist) {
            if(oldMap != null){   //Only in Update scenario
                Service__c oldService = (Service__c)oldMap.get(serviceObj.ID);
                if(serviceObj.VolumePercentage__c != null && oldService.VolumePercentage__c != serviceObj.VolumePercentage__c){//Execute trigger only when VolumePercentage is updated
                    if(serviceObj.VolumePercentage__c > 100 || serviceObj.VolumePercentage__c < 0) {   //AT-3881  fixed under AT-3885
                        serviceObj.addError(System.Label.GlUt_VolumePercentageRange);
                    } 
                    serviceServiceTypeList.add(serviceObj.ServiceType__c); 
                } 
            }else{//Only in before insert scenario
            	if(serviceObj.VolumePercentage__c > 100 || serviceObj.VolumePercentage__c < 0) {   //AT-3881  fixed under AT-3885
                    serviceObj.addError(System.Label.GlUt_VolumePercentageRange);
                }
                serviceServiceTypeList.add(serviceObj.ServiceType__c); 
            }
        }
        if(!serviceServiceTypeList.isEmpty()){
            for(ServiceType__c serviceTypeObj : [SELECT Id, Name FROM ServiceType__c WHERE Id IN: serviceServiceTypeList]) {
                serviceServiceTypeNameMap.put(serviceTypeObj.Id, serviceTypeObj.name);   
            }
            
            for(Service__c serviceObj : newlist){
                //Creating Map for Sewerage Service
                if(serviceServiceTypeNameMap.containsKey(serviceObj.ServiceType__c) && serviceServiceTypeNameMap.get(serviceObj.ServiceType__c) ==   GlUt_Constants.SEWSERVICELBL){
                    if(serviceObj.VolumePercentage__c != null){
                         volumePercentageSewMap.put(serviceObj.SupplyPoint__c , serviceObj.VolumePercentage__c);
                    } else if(oldMap == null && serviceObj.VolumePercentage__c == NULL){
                        serviceObj.VolumePercentage__c = 100; // AT-3885 Initially if there is no volume percentage while creating the services then making it to 100%
                    	volumePercentageSewMap.put(serviceObj.SupplyPoint__c , serviceObj.VolumePercentage__c);
                    }
                }
                //Creating Map for TE Service
                if(serviceServiceTypeNameMap.containsKey(serviceObj.ServiceType__c) && serviceServiceTypeNameMap.get(serviceObj.ServiceType__c) ==  GlUt_Constants.TESERVICELBL){
                    if(serviceObj.VolumePercentage__c != null){
                        volumePercentageTEMap.put(serviceObj.SupplyPoint__c , serviceObj.VolumePercentage__c);
                    } else if(oldMap == null && serviceObj.VolumePercentage__c == NULL){
                        serviceObj.VolumePercentage__c = 100; // AT-3885 Initially if there is no volume percentage while creating the services then making it to 100%
                    	volumePercentageTEMap.put(serviceObj.SupplyPoint__c , serviceObj.VolumePercentage__c);
                    }
                }
            }
            
            if(!volumePercentageSewMap.isEmpty() &&  !volumePercentageTEMap.isEmpty()) 
            {
                for(Service__c serviceObj : newlist) {
                    if(volumePercentageSewMap.containsKey(serviceObj.SupplyPoint__c) == volumePercentageTEMap.containsKey(serviceObj.SupplyPoint__c)) {
                        if(serviceServiceTypeNameMap.containsKey(serviceObj.ServiceType__c) && (serviceServiceTypeNameMap.get(serviceObj.ServiceType__c) ==  GlUt_Constants.TESERVICELBL))
                            serviceObj.VolumePercentage__c = 100 - volumePercentageSewMap.get(serviceObj.SupplyPoint__c);    //Adjusting TE service Volume Percentage = (100 - SEW Service Volume Percentage)
                    }
                }
            }
            
            if(!volumePercentageSewMap.isEmpty()){
                Map<Id,Decimal> validateExistingServiceVolPercentageMap = new Map<Id,Decimal>();
                Map<Id,Decimal> newServiceVolumePercentageMap = new Map<Id,Decimal>();
                Map<Id,Id> serviceSupplyPointeWithIdMap = new Map<Id,Id>();
                
                for(Service__c serviceObj :  [SELECT Id, SupplyPoint__c , VolumePercentage__c FROM Service__c 
                                              WHERE  SupplyPoint__c  IN: volumePercentageSewMap.keySet() 
                                              AND ServiceType__r.Name =: GlUt_Constants.TESERVICELBL]){ //Trade Effluent  
                    
                    if(!validateExistingServiceVolPercentageMap.containsKey(serviceObj.SupplyPoint__c)) {
                        validateExistingServiceVolPercentageMap.put(serviceObj.SupplyPoint__c, serviceObj.VolumePercentage__c);
                        newServiceVolumePercentageMap.put(serviceObj.SupplyPoint__c,volumePercentageSewMap.get(serviceObj.SupplyPoint__c));
                        serviceSupplyPointeWithIdMap.put(serviceObj.SupplyPoint__c,serviceObj.Id);
                    }
                }
                if(!validateExistingServiceVolPercentageMap.isEmpty() && !newServiceVolumePercentageMap.isEmpty() && !serviceSupplyPointeWithIdMap.isEmpty())
                    serviceupdatelist =  validateExistingVolumePercentage(validateExistingServiceVolPercentageMap, newServiceVolumePercentageMap, serviceSupplyPointeWithIdMap);
            }
            
            if(!volumePercentageTEMap.isEmpty()) {
                Map<Id,Decimal> validateExistingServiceVolPercentageMap = new Map<Id,Decimal>();
                Map<Id,Decimal> newServiceVolumePercentageMap = new Map<Id,Decimal>();
                Map<Id,Id> serviceSupplyPointeWithIdMap = new Map<Id,Id>();
                
                for(Service__c serviceObj :  [SELECT Id, SupplyPoint__c  , VolumePercentage__c FROM Service__c 
                                              WHERE  SupplyPoint__c  IN: volumePercentageTEMap.keySet() 
                                              AND ServiceType__r.Name =: GlUt_Constants.SEWSERVICELBL]){  //Sewerage
                    if(!validateExistingServiceVolPercentageMap.containsKey(serviceObj.SupplyPoint__c)) {
                        validateExistingServiceVolPercentageMap.put(serviceObj.SupplyPoint__c, serviceObj.VolumePercentage__c);
                        newServiceVolumePercentageMap.put(serviceObj.SupplyPoint__c,volumePercentageTEMap.get(serviceObj.SupplyPoint__c));
                        serviceSupplyPointeWithIdMap.put(serviceObj.SupplyPoint__c,serviceObj.Id);
                    }
                }
                if(!validateExistingServiceVolPercentageMap.isEmpty() && !newServiceVolumePercentageMap.isEmpty() && !serviceSupplyPointeWithIdMap.isEmpty())
                    serviceupdatelist = validateExistingVolumePercentage(validateExistingServiceVolPercentageMap, newServiceVolumePercentageMap , serviceSupplyPointeWithIdMap);
            }
            
            if(serviceupdatelist != null){
                serviceupdatelist = (List<Service__c>) GlUt_FieldSecurity.cleanseFields(serviceupdatelist, false);
                update serviceupdatelist;
            }
        }
    }
    
    /******************************************************************************
	@author         ECHO: Vivek Sethi
	@date           12 July 2018
	@param          Map<Id,Decimal> validateExistingServiceVolPercentageMap, Map<Id,Decimal> newServiceVolumePercentageMap ,Map<Id,Id>  serviceSupplyPointeWithIdMap
	@description    Volume percentage for the Trade Effluent and validating its total Volume Percentage 
 					for both the services is not exceeding the 100% at one Supply Point. Vice versa for the Trade Effluent service. 
	@return         void
	*******************************************************************************/      
    public List<Service__c>  validateExistingVolumePercentage(Map<Id,Decimal> validateExistingServiceVolPercentageMap, Map<Id,Decimal> newServiceVolumePercentageMap ,Map<Id,Id>  serviceSupplyPointeWithIdMap) {
        List<Service__c> serviceupdatelist = new List<Service__c>(); 
        Map<Id, Decimal> volumePercentageUpdateMap = new  Map<Id, Decimal>();
        decimal newVolumePercentage;
        for(Id supplyPoint : validateExistingServiceVolPercentageMap.keySet()) {
        	decimal existingVolPercentage = validateExistingServiceVolPercentageMap.get(supplyPoint) == NULL ? 0 : validateExistingServiceVolPercentageMap.get(supplyPoint);  //AT-3885
        	decimal newVolPercentage = newServiceVolumePercentageMap.get(supplyPoint) == NULL ? 0 : newServiceVolumePercentageMap.get(supplyPoint);  //AT-3885
            if(existingVolPercentage + newVolPercentage != 100) {  //AT-3885
                newVolumePercentage = 100 - newVolPercentage;   //AT-3885
                volumePercentageUpdateMap.put(serviceSupplyPointeWithIdMap.get(supplyPoint),newVolumePercentage);
            }
        }
        if(!volumePercentageUpdateMap.isEmpty()) {
            for(Service__c  serviceobj : [SELECT Id, VolumePercentage__c  FROM Service__c WHERE Id IN: volumePercentageUpdateMap.keyset()]) {
                serviceobj.VolumePercentage__c =  volumePercentageUpdateMap.get(serviceobj.Id);
                serviceupdatelist.add(serviceobj) ;
            }
        }
        return serviceupdatelist;
    }
    
    /******************************************************************************
	@author         ECHO: Vivek Sethi  AT-3454
	@date           14 Sep 2018
	@param          List<Id> Service Id
	@description    Whenever volume percentage of any (Sewerage or TE) services is changed and
                    if there is a bill generated for the service then existing service item will be ended,
					and a new service item for each services item will be created for both the services.  
	@return         void
    @Revision       Echo: Amit K. (Sanity Issue SIT005)
	*******************************************************************************/      
    public void  volumePercentageAmendments(List<Service__c> newlist , Map<Id, Sobject> oldMap) {
        
        List<Id> serviceItemWithServiceVolPercUpdatedIdList = new List<Id>();
        List<Id> ServiceItemsWithBills = new List<Id>();
        List<ServiceItem__c> serviceItemToUpdatedList  = new  List<ServiceItem__c>();
        Map<String, ServiceItem__c> serviceItemToNewServiceItemMap = new Map<String,ServiceItem__c>();
        Map<Id,String> serviceServiceTypeNameMap = new Map<Id,String>();
        List<Id> serviceServiceTypeList = new List<Id>();
      
        for(Service__c serviceObj : newlist){
            Service__c oldService = (Service__c)oldMap.get(serviceObj.ID);
            if(serviceObj.VolumePercentage__c != null && oldService.VolumePercentage__c != serviceObj.VolumePercentage__c)   //Execute trigger only when VolumePercentage is updated 
                serviceServiceTypeList.add(serviceObj.ServiceType__c);  
        }
        if(!serviceServiceTypeList.isEmpty()){
            for(ServiceType__c serviceTypeObj : [SELECT Id, Name FROM ServiceType__c WHERE Id IN: serviceServiceTypeList]) {
                serviceServiceTypeNameMap.put(serviceTypeObj.Id, serviceTypeObj.name);   
            }
            Set<Id> serviceIdSet = new Set<Id>();
            Map<Id,Id> mapOfSupplyPointId2TEServiceId = new Map<Id,Id>();
            Map<Id,Id> mapOfSupplyPointId2SEWServiceId = new Map<Id,Id>();
            for(Service__c serviceObj : newlist) {
                //Collecting  Service Items for Sewerage Service
                if(serviceServiceTypeNameMap.get(serviceObj.ServiceType__c) ==   GlUt_Constants.SEWSERVICELBL){
                    mapOfSupplyPointId2SEWServiceId.put(serviceObj.SupplyPoint__c,serviceObj.Id);
                }
                //Collecting  Service Items for TE Services
                if(serviceServiceTypeNameMap.get(serviceObj.ServiceType__c) ==  GlUt_Constants.TESERVICELBL){
                    mapOfSupplyPointId2TEServiceId.put(serviceObj.SupplyPoint__c,serviceObj.Id);
                }
               
            }
            if(!mapOfSupplyPointId2SEWServiceId.isEmpty()){
                for(Service__c serviceObj :  [SELECT Id, SupplyPoint__c , VolumePercentage__c FROM Service__c 
                                          WHERE  SupplyPoint__c  IN: mapOfSupplyPointId2SEWServiceId.keySet() 
                                              AND ServiceType__r.Name =: GlUt_Constants.TESERVICELBL]){
                                              serviceIdSet.add(serviceObj.Id);    
                                              } //Trade Effluent Service Id 
                serviceIdSet.addAll(mapOfSupplyPointId2SEWServiceId.values());
            
            }
            if(!mapOfSupplyPointId2TEServiceId.isEmpty()){
                for(Service__c serviceObj :  [SELECT Id, SupplyPoint__c , VolumePercentage__c FROM Service__c 
                                          WHERE  SupplyPoint__c  IN: mapOfSupplyPointId2TEServiceId.keySet() 
                                              AND ServiceType__r.Name =: GlUt_Constants.SEWSERVICELBL]){
                                              serviceIdSet.add(serviceObj.Id);    
                                              } //Sewerage Service Id
                serviceIdSet.addAll(mapOfSupplyPointId2TEServiceId.values());
            }
            if(!serviceIdSet.isEmpty()){
                for(ServiceItem__c serviceItemList :[SELECT Id FROM  ServiceItem__c
                                                     WHERE Service__c In: serviceIdSet
                                                     AND AmendedByServiceItem__c = null]){
                    serviceItemWithServiceVolPercUpdatedIdList.add(serviceItemList.Id);
                }
            }
        }
      
        //Check if there is any Bill generated (checking by considering its Bill Items) */
        if(!serviceItemWithServiceVolPercUpdatedIdList.isEmpty()) {
            for(BillItem__c billItemObj : [SELECT Id , ServiceItem__c FROM BillItem__c WHERE ServiceItem__c IN: serviceItemWithServiceVolPercUpdatedIdList]) {
                ServiceItemsWithBills.add(billItemObj.ServiceItem__c);
            }
        }
        if(!ServiceItemsWithBills.isEmpty()){
            for(ServiceItem__c  serviceItemObject : [SELECT Id,
                                                     AvailableServiceItem__c,
                                                     DischargeAgreement__c,
                                                     EndDate__c,
                                                     Quantity__c,
                                                     Service__c,
                                                     ServiceItemType__c,
                                                     ServiceType__c,
                                                     StartDate__c
                                                     FROM ServiceItem__c WHERE Id IN: ServiceItemsWithBills]){
                                                         //Creating new Service Item ;
                                                         ServiceItem__c newServiceItemObj = new ServiceItem__c();
                                                         newServiceItemObj = serviceItemObject.clone(false);
                                                         serviceItemToNewServiceItemMap.put(string.valueOf(serviceItemObject.Id),newServiceItemObj); 
                                                     }
            if(!serviceItemToNewServiceItemMap.isEmpty()) {
                GlUt_FieldSecurity.createMapAfterCleanse(serviceItemToNewServiceItemMap);
                // AmendedByServiceItem__c reference to new service item
                for(ServiceItem__c  serviceItemObject : [SELECT Id,
                                                         AmendedByServiceItem__c
                                                         FROM ServiceItem__c WHERE Id IN: ServiceItemsWithBills]){
                    serviceItemObject.AmendedByServiceItem__c = serviceItemToNewServiceItemMap.get(string.valueOf(serviceItemObject.Id)).Id;
                    serviceItemToUpdatedList.add(serviceItemObject);
                }
            }
            
            if(!serviceItemToUpdatedList.isEmpty()) {
                serviceItemToUpdatedList = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(serviceItemToUpdatedList, false);
                update serviceItemToUpdatedList;
            }
        }
        
    }
}