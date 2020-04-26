/******************************************************************************
@author         Echo: Mohit Tayal
@date           19 July 2018
@description    Class is used to activate new or existing bundles.
@revesion 		Changes by Dependra Singh - Security Review - 20-09-2018 - AT-3749
@revision		Echo: Sudhir Kumar AT-3736 : System doesn't create a new set of Service items for the Bundle that is being made active.
*******************************************************************************/
public with sharing class GlUt_ActivateAvailableBundle {
    private static final String CLASS_NAME = 'GlUt_ActivateAvailableBundle';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           19 July 2018
    @param          Map<Id,GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper>
                    map of available bundle Id to GlUt_ProcessAvailableBundle wrapper
    @return         
    @description    ends the service items and also create service Items 
    *******************************************************************************/
    public static void activateAvailableBundle(Map<Id, GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper> mapOfAvailableBundleIdToWrapper){
        try{
            
            System.debug('mapOfAvailableBundleIdToWrapper = '+mapOfAvailableBundleIdToWrapper);
            if(mapOfAvailableBundleIdToWrapper != Null){
                Set<Id> setOfAvailableServiceIds = new Set<Id>();
                Set<Id> setOfServiceItemIds = new Set<Id>();
                List<ServiceItem__c> lstServiceItem  = new List<ServiceItem__c>();
                 List<ServiceItem__c> lstServiceItem1  = new List<ServiceItem__c>();
                for(AvailableBundle__c objAvailableBundle : [SELECT Id, AvailableService__c FROM AvailableBundle__c WHERE Id IN :mapOfAvailableBundleIdToWrapper.keySet()]){
                    GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper objWrapper = mapOfAvailableBundleIdToWrapper.get(objAvailableBundle.Id);
                    objWrapper.availableBundle = objAvailableBundle;
                } 
                
                //extracting available services associated with the available bundle
                for(GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper objWrapper : mapOfAvailableBundleIdToWrapper.values()){
                    if(objWrapper.availableBundle.AvailableService__c != Null){
                        setOfAvailableServiceIds.add(objWrapper.availableBundle.AvailableService__c);
                    }
                }
                
                System.debug('setOfAvailableServiceIds= '+setOfAvailableServiceIds);
                if(!setOfAvailableServiceIds.isEmpty()){
                    //extracting the services associated with the availabe services 
                    Map<Id,List<Service__c>> mapOfAvailableServiceIdToServiceRecord = new Map<Id,List<Service__c>>();
                    for(Service__c objService : [SELECT Id, ServiceStartDate__c, ServiceEndDate__c, AvailableService__c FROM Service__c WHERE AvailableService__c IN :setOfAvailableServiceIds]){
                        if(!mapOfAvailableServiceIdToServiceRecord.containsKey(objService.AvailableService__c))
                            mapOfAvailableServiceIdToServiceRecord.put(objService.AvailableService__c, new List<Service__c>());
                        mapOfAvailableServiceIdToServiceRecord.get(objService.AvailableService__c).add(objService);
                    }
                    System.debug('mapOfAvailableServiceIdToServiceRecord = '+mapOfAvailableServiceIdToServiceRecord);
                    if(mapOfAvailableServiceIdToServiceRecord != Null){
                        //creating a set of the active services from the above found services
                        Set<Id> setOfServiceIds = new Set<Id>();
                        for(GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper objWrapper : mapOfAvailableBundleIdToWrapper.values()){
                            if(objWrapper.availableBundle.AvailableService__c != Null && mapOfAvailableServiceIdToServiceRecord.containsKey(objWrapper.availableBundle.AvailableService__c)){
                                for(Service__c objService : mapOfAvailableServiceIdToServiceRecord.get(objWrapper.availableBundle.AvailableService__c)){
                                    if(objService.ServiceStartDate__c <= objWrapper.effectiveDate && (objService.ServiceEndDate__c == NULL || objService.ServiceEndDate__c > objWrapper.effectiveDate)){
                                        setOfServiceIds.add(objService.Id);
                                    }
                                }
                            }
                        }
                        System.debug('setOfServiceIds = '+setOfServiceIds);
                        if(!setOfServiceIds.isEmpty()){
                            Map<Id,List<ServiceItem__c>> mapOfAvailableServiceIdToServiceItemRecord = new Map<Id,List<ServiceItem__c>>();
                            //exracting the service items linked to the above active services and creating a map of available services Ids to list of service items
                            for(ServiceItem__c objServiceItem : [SELECT AvailableServiceItem__r.AvailableBundle__c, StartDate__c, EndDate__c, Service__c, Service__r.AvailableService__c FROM ServiceItem__c WHERE Service__c IN :setOfServiceIds]){
                                setOfServiceItemIds.add(objServiceItem.Id);
                                if(objServiceItem.Service__r.AvailableService__c != null){
                                    if(!mapOfAvailableServiceIdToServiceItemRecord.containsKey(objServiceItem.Service__r.AvailableService__c))
                                        mapOfAvailableServiceIdToServiceItemRecord.put(objServiceItem.Service__r.AvailableService__c, new List<ServiceItem__c>());
                                    mapOfAvailableServiceIdToServiceItemRecord.get(objServiceItem.Service__r.AvailableService__c).add(objServiceItem);
                                }
                            }
                            System.debug('setOfServiceItemIds = '+setOfServiceItemIds);
                            System.debug('mapOfAvailableServiceIdToServiceItemRecord = '+mapOfAvailableServiceIdToServiceItemRecord);
                            if(!setOfServiceItemIds.isEmpty() && mapOfAvailableServiceIdToServiceItemRecord != Null){
                                //Changes for UL-171 Starts Here
                                Map<Id,Id> groupIdByServiceItem = new Map<Id,Id>();
                                groupIdByServiceItem = getServiceItemOfTypeTariffLimit(setOfServiceItemIds);
                                System.debug('groupIdByServiceItem = '+groupIdByServiceItem);
                                //ending the service items if the available bundle of available service item is not same to the current available bundle
                                for(GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper objWrapper : mapOfAvailableBundleIdToWrapper.values()){
                                    if(objWrapper.availableBundle.AvailableService__c != Null && mapOfAvailableServiceIdToServiceItemRecord.containsKey(objWrapper.availableBundle.AvailableService__c)){
                                        for(ServiceItem__c objServiceItem : mapOfAvailableServiceIdToServiceItemRecord.get(objWrapper.availableBundle.AvailableService__c)){
                                            if(objServiceItem.StartDate__c <= objWrapper.effectiveDate && (objServiceItem.EndDate__c == NULL || objServiceItem.EndDate__c > objWrapper.effectiveDate)){
                                                if(objServiceItem.AvailableServiceItem__r.AvailableBundle__c != objWrapper.availableBundle.Id){
                                                    if(!groupIdByServiceItem.containsKey(objServiceItem.Id)){
                                                        objServiceItem.EndDate__c = objWrapper.effectiveDate - 1;
                                                        // AT-3892, AT-3896
                                                        if(objServiceItem.EndDate__c != null){
                                                            objServiceItem.Ended__c = true;
                                                        }
                                                        lstServiceItem.add(objServiceItem); 
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                System.debug('lstServiceItem = '+lstServiceItem);
                            }
                        }
                    }
                }
                //setting the map of available bundle id and its related available service items 
                Map<Id,List<AvailableServiceItem__c>> mapOfAvailableBundleIdToListAvailableServiceItem = new Map<Id,List<AvailableServiceItem__c>>();
                Set<Id> setOfAvailableServiceItemId = new Set<Id>();
                Set<Id> setOfServiceItemTypeId = new Set<Id>(); // AT-4035
                Map<Id,ServiceItemType__c> mapOfServiceItemTypeId2ServiceItemTypeRecord = new Map<Id,ServiceItemType__c>();
                for(AvailableServiceItem__c objAvailableServiceItem : [SELECT ServiceItemType__c, AvailableBundle__c, AvailableBundle__r.AvailableService__c FROM AvailableServiceItem__c WHERE AvailableBundle__c IN :mapOfAvailableBundleIdToWrapper.keySet()]){
                    if(!mapOfAvailableBundleIdToListAvailableServiceItem.containsKey(objAvailableServiceItem.AvailableBundle__c))
                        mapOfAvailableBundleIdToListAvailableServiceItem.put(objAvailableServiceItem.AvailableBundle__c, new List<AvailableServiceItem__c>());
                    mapOfAvailableBundleIdToListAvailableServiceItem.get(objAvailableServiceItem.AvailableBundle__c).add(objAvailableServiceItem);
                    setOfAvailableServiceItemId.add(objAvailableServiceItem.Id);
                    
                    // AT-4035
                    if(objAvailableServiceItem.ServiceItemType__c != null){
                        setOfServiceItemTypeId.add(objAvailableServiceItem.ServiceItemType__c);
                    }
                }
                System.debug('setOfAvailableServiceItemId = '+setOfAvailableServiceItemId);
                System.debug('setOfServiceItemTypeId = '+setOfServiceItemTypeId);
                System.debug('mapOfAvailableBundleIdToListAvailableServiceItem = '+mapOfAvailableBundleIdToListAvailableServiceItem);
                // AT-4035
                if(!setOfServiceItemTypeId.isEmpty()){
                    for(ServiceItemType__c objServiceItemType : [SELECT Id, Tenant__c, Landlord__c, Owner__c FROM ServiceItemType__c WHERE Id IN :setOfServiceItemTypeId]){
                        if(!mapOfServiceItemTypeId2ServiceItemTypeRecord.containsKey(objServiceItemType.Id)){
                            mapOfServiceItemTypeId2ServiceItemTypeRecord.put(objServiceItemType.Id, objServiceItemType);
                        }
                    }                    
                }
                System.debug('mapOfServiceItemTypeId2ServiceItemTypeRecord = '+mapOfServiceItemTypeId2ServiceItemTypeRecord);
                if(!setOfAvailableServiceItemId.isEmpty() && mapOfAvailableBundleIdToListAvailableServiceItem != Null){
                    //Getting Active Service Id corresponding to an Available Service
					map<Id, Id> mapAvailableServiceId2ActiveServiceId = GlUt_ProcessAvailableBundle.getMapAvailableServiceId2ActiveServiceId(setOfAvailableServiceIds) ;
                    //setting the map of available service item id found above and it's related service items
                    Map<Id,String> mapOfServiceId2OccupancyType = new Map<Id,String>();
                    Map<Id,List<ServiceItem__c>> mapOfAvailableServiceItemIdToServiceItemRecord = new Map<Id,List<ServiceItem__c>>();
                    for(ServiceItem__c objServiceItem : [SELECT ServiceItemType__c, AvailableServiceItem__c, StartDate__c, EndDate__c, Service__c, Service__r.OccupancyType__c FROM ServiceItem__c WHERE AvailableServiceItem__c IN :setOfAvailableServiceItemId]){
                        if(!mapOfAvailableServiceItemIdToServiceItemRecord.containsKey(objServiceItem.AvailableServiceItem__c))
                            mapOfAvailableServiceItemIdToServiceItemRecord.put(objServiceItem.AvailableServiceItem__c, new List<ServiceItem__c>());
                        mapOfAvailableServiceItemIdToServiceItemRecord.get(objServiceItem.AvailableServiceItem__c).add(objServiceItem);
                        
                        // AT-4035
                        if(!mapOfServiceId2OccupancyType.containsKey(objServiceItem.Service__c)){
                            mapOfServiceId2OccupancyType.put(objServiceItem.Service__c, objServiceItem.Service__r.OccupancyType__c);
                        }
                    }
                    String occupancyType = '';
                    Boolean createServiceItem = False;
                    if(mapOfAvailableServiceItemIdToServiceItemRecord != Null){
                        //creating the new service items
                        for(GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper objWrapper : mapOfAvailableBundleIdToWrapper.values()){
                            Date effectiveDate = objWrapper.effectiveDate;
                            if(mapOfAvailableBundleIdToListAvailableServiceItem.containsKey(objWrapper.availableBundle.Id)){
                                for(AvailableServiceItem__c objAvailableServiceItem : mapOfAvailableBundleIdToListAvailableServiceItem.get(objWrapper.availableBundle.Id)){
                                    if(mapOfAvailableServiceItemIdToServiceItemRecord.containsKey(objAvailableServiceItem.Id)){
                                        for(ServiceItem__c objServiceItem : mapOfAvailableServiceItemIdToServiceItemRecord.get(objAvailableServiceItem.Id)){
                                            //Sudhir: Core Misc. - added first null check : AT-3738 & AT-3736
                                            if(!(objServiceItem != null && objServiceItem.ServiceItemType__c == objAvailableServiceItem.ServiceItemType__c && 
                                                 objServiceItem.StartDate__c <= effectiveDate 
                                                 && (objServiceItem.EndDate__c == Null || objServiceItem.EndDate__c >= effectiveDate))){	// CoreMisc null check on SI
                                                     
                                                     // AT-4035
                                                     if(objServiceItem.Service__c != null && mapOfServiceId2OccupancyType.containsKey(objServiceItem.Service__c)){                                        
                                                         if(mapOfServiceId2OccupancyType.get(objServiceItem.Service__c) != null && 
                                                            mapOfServiceItemTypeId2ServiceItemTypeRecord.containsKey(objAvailableServiceItem.ServiceItemType__c)){
                                                             ServiceItemType__c recServiceItemType = mapOfServiceItemTypeId2ServiceItemTypeRecord.get(objAvailableServiceItem.ServiceItemType__c);                                                             
                                                             if(recServiceItemType.get(mapOfServiceId2OccupancyType.get(objServiceItem.Service__c) + '__c') == TRUE){ // Ex: Owner__c, Landlord__c, Tenant__c 
                                                                 ServiceItem__c newServiceItem = createServiceItem(objAvailableServiceItem, effectiveDate) ;
																 newServiceItem.Service__c = objServiceItem.Service__c ;
                                                                 lstServiceItem1.add(newServiceItem) ;
                                                             }
                                                         }
                                                     }
                                                 }
                                        }
                                    } else {
                                        if(mapAvailableServiceId2ActiveServiceId != null && mapAvailableServiceId2ActiveServiceId.containsKey(objAvailableServiceItem.AvailableBundle__r.AvailableService__c)) {
                                            ServiceItem__c newServiceItem = createServiceItem(objAvailableServiceItem, effectiveDate) ;
                                            newServiceItem.Service__c = mapAvailableServiceId2ActiveServiceId.get(objAvailableServiceItem.AvailableBundle__r.AvailableService__c) ;
                                            lstServiceItem1.add(newServiceItem);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                //Changes by Dependra Singh - Security Review - 21-09-2018 - AT-3749
                if(lstServiceItem != Null && !lstServiceItem.isEmpty()){
                    List<ServiceItem__c> lstServiceItemToUpsert  = (List<ServiceItem__c>)GlUt_FieldSecurity.cleanseFields(lstServiceItem, false); 
                    Database.update(lstServiceItemToUpsert);                    
                }
                if(lstServiceItem1 != Null && !lstServiceItem1.isEmpty()){
                    List<ServiceItem__c> lstServiceItemToUpsert1  = (List<ServiceItem__c>)GlUt_FieldSecurity.cleanseFields(lstServiceItem1, false); 
                    Database.insert(lstServiceItemToUpsert1);                    
                }
            }   
        }
        catch(Exception e){
            System.debug('Error : ' +e.getMessage());
        }    
    }  
    
    private static ServiceItem__c createServiceItem(AvailableServiceItem__c objAvailableServiceItem, Date effectiveDate) {
		ServiceItem__c newServiceItem = new ServiceItem__c(AvailableServiceItem__c = objAvailableServiceItem.Id, 
														   ServiceItemType__c = objAvailableServiceItem.ServiceItemType__c, 
														   StartDate__c = effectiveDate);
		return newServiceItem ;												   
	}
    /******************************************************************************
    @author         Echo: Amit K.
    @date           06 March 2019
    @param          Set<Id> setOfServiceItemIds
    @return         Map<Id,Id> - groupIdByServiceItem
    @description    fetch Service items belongs to Tariff Limit.
    *******************************************************************************/
    public static Map<Id,Id> getServiceItemOfTypeTariffLimit(Set<Id> setOfServiceItemIds) {
        //Do not end any Service Items that have a Group associated. 
        Map<Id,Id> groupIdByServiceItem = new Map<Id,Id>();
        //Changes for UL-171 Starts Here
        List<GroupType__c> tariffLimitGroupTypeList = [Select Id from GroupType__c Where Name =:GlUt_Constants.GROUPTYPE_NAME_TARIFFLIMIT Limit 1]; 
        List<GroupItem__c> groupItemList = new List<GroupItem__c>();
        if(tariffLimitGroupTypeList != null && tariffLimitGroupTypeList.size() > 0)
            groupItemList = [Select Id, Group__c, ServiceItem__c from GroupItem__c where ServiceItem__c IN: setOfServiceItemIds AND Group__r.GroupType__c =: tariffLimitGroupTypeList[0].Id];
        //Changes for UL-171 Ends Here
        if(groupItemList != null && groupItemList.size() > 0){
            for(GroupItem__c objGrpItem : groupItemList){
                if(!groupIdByServiceItem.containsKey(objGrpItem.ServiceItem__c) && objGrpItem.Group__c != null) {
                    groupIdByServiceItem.put(objGrpItem.ServiceItem__c, objGrpItem.Group__c);
                }
            }
        }
        return groupIdByServiceItem;
    }
}