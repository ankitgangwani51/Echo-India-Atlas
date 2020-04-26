/******************************************************************************
@author         Echo: Tarun Gupta
@date           26 Oct 2018
@description    Class for AU Contract utilities
@Revisions		AT-3494, Modified to add SI start date  
*******************************************************************************/
public with sharing class GlUt_AUContractUtilities {
    
    private static final String CLASS_NAME = 'GlUt_AUContractUtilities';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           26 Oct 2018
    @param          Set<Id> - device Ids
    @return         Map<Id, Id> - map of supply point device Ids keyed on service type Id
    @description    Builds a map of the supply point device Ids keyed on service type Id 
    for the devices, so that we can match a device/reading to the correct service
    *******************************************************************************/
    private static Map<Id, Id> BuildSupplyPointDeviceMap(Set<Id> deviceIds) {
        
        Map<Id, Id> supplyPointDeviceMap = new Map<Id, Id>();
        for (SupplyPointDeviceService__c supplyPointDeviceService : [select Id, 
                                                                     ServiceType__c, 
                                                                     SupplyPointDevice__c 
                                                                     from SupplyPointDeviceService__c
                                                                     where SupplyPointDevice__r.Device__c in :deviceIds]) {
                                                                         
                                                                         supplyPointDeviceMap.put(supplyPointDeviceService.ServiceType__c, supplyPointDeviceService.SupplyPointDevice__c);
                                                                     }
        
        return supplyPointDeviceMap;
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           26 Oct 2018
    @param          List<Reading__c> - readings
    @return         Map<Id, Id> - map of reading Ids keyed on service type Id
    @description    Builds a map of the move in reading Ids keyed on service type Id, 
    so that we can match a device/reading to the correct service
    *******************************************************************************/
    private static Map<Id, Id> BuildReadingsMap(List<Reading__c> readings) {
        
        Map<Id, Id> readingsMap = new Map<Id, Id>();
        if (readings != null) {
            for (Reading__c reading : readings) {
                if (reading.ReadingType__c == System.Label.GlAp_ReadingReadingTypeMoveInActive) {
                    readingsMap.put(reading.Device__c, reading.Id);
                }
            }
        }
        
        return readingsMap;
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           26 Oct 2018
    @param          List<Id> - supply point device Ids
    @return         Map<Id, Id> - map of device Ids keyed on supply point device Id
    @description    Builds a map of the device Ids keyed on supply point device Id, 
    so that we can match a device/reading to the correct service
    *******************************************************************************/
    private static Map<Id, Id> BuildDeviceMap(List<Id> supplyPointDeviceIds) {
        
        Map<Id, Id> deviceMap = new Map<Id, Id>();      // map of device Ids keyed on supply point device Id
        for (SupplyPointDevice__c supplyPointDevice : [select Id, 
                                                       Device__c
                                                       from SupplyPointDevice__c
                                                       where Id in :supplyPointDeviceIds]) {
                                                           
                                                           deviceMap.put(supplyPointDevice.Id, supplyPointDevice.Device__c);
                                                       }
        return deviceMap;
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           26 Oct 2018
    @param          Id - contract Id
    @param          Date - start date of the contract
    @param          List<AvailableService__c> - list of the services to supply
    @param          List<AvailableBundle__c> - list of the available bundles
    @param          List<AvailableServiceItem__c> - list of the service items to supply
    @param          List<ServiceItemType__c> - list of sundry items to supply
    @param          List<Reading__c> - list of the move in readings
    @return         Boolean - success
    @description    Adds services and service items to a contract
	*******************************************************************************/
    public static Boolean AddServiceItemsToContract(Id accountId,Id contractId,Date startDate, List<BlAp_CombinedRecord> listAvailService2StartDate  ,List<AvailableBundle__c> availableBundles,List<AvailableServiceItem__c> suppliedServiceItems,List<ServiceItemType__c> selectedSundryItems,List<Reading__c> moveInReadings,String occType) { //AT-4038
        
        List<AvailableService__c> suppliedServices = new List<AvailableService__c>();
        Map<Id,Date> mapAvailServiceId2ServiceItemStartDate = new Map<Id,Date>();
        Set<Id> supplyPointIds = new Set<Id>();
        for(BlAp_CombinedRecord objCombinedRec : listAvailService2StartDate){
            AvailableService__c objAvailServ = (AvailableService__c)objCombinedRec.objectMap.get(GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME);
            ServiceItem__c objServiceItem = (ServiceItem__c)objCombinedRec.objectMap.get(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME);
            suppliedServices.add(objAvailServ);
            if(!mapAvailServiceId2ServiceItemStartDate.containsKey(objAvailServ.Id)){
                mapAvailServiceId2ServiceItemStartDate.put(objAvailServ.Id, Date.valueOf(objServiceItem.StartDate__c));
            }
			//AT-4998 - Added By Dependra Singh - AU3 Changes
			if(objAvailServ.SupplyPoint__c != null){
				supplyPointIds.add(objAvailServ.SupplyPoint__c);
			}
        }
        /*Changes for CLB-128 Starts Here*/
        Map<Id,List<AvailableServiceItem__c>> mapOfAvailableServiceId2AvailableServiceItemList = new Map<Id,List<AvailableServiceItem__c>>();
        List<AvailableServiceItem__c> availableServiceItemList = [Select Id,ServiceItemType__c,AvailableBundle__r.AvailableService__c from AvailableServiceItem__c Where AvailableBundle__r.AvailableService__c In: suppliedServices];
        Set<Id> serviceItemTypeIdSet = new Set<Id>();
        for(AvailableServiceItem__c aServiceItem: availableServiceItemList){
            if (!mapOfAvailableServiceId2AvailableServiceItemList.containsKey(aServiceItem.AvailableBundle__r.AvailableService__c)) {
                    mapOfAvailableServiceId2AvailableServiceItemList.put(aServiceItem.AvailableBundle__r.AvailableService__c, new List<AvailableServiceItem__c>()); 
                }
                mapOfAvailableServiceId2AvailableServiceItemList.get(aServiceItem.AvailableBundle__r.AvailableService__c).add(aServiceItem); 
            serviceItemTypeIdSet.add(aServiceItem.ServiceItemType__c);
        }
        Map<Id,ServiceItemType__c> mapServiceItemTypeId2ServiceItemType = new Map<Id,ServiceItemType__c>([Select Id,Owner__c,Tenant__c,Landlord__c from ServiceItemType__c Where Id In: serviceItemTypeIdSet]);
        /*Changes for CLB-128 Ends Here*/
        // build some maps to relate the move in reading on a device to a service type for a supply point
        Map<Id, Id> moveInReadingsMap = BuildReadingsMap(moveInReadings);       // map of move in reading Ids keyed on device Id        
        Map<Id, Id> supplyPointDeviceMap = BuildSupplyPointDeviceMap(moveInReadingsMap.keySet());       // map of supply point device Ids keyed on service type Id
        Map<Id, Id> deviceMap = BuildDeviceMap(supplyPointDeviceMap.values());      // map of device Ids keyed on supply point device Id
        List<TariffLimit__c> tariffLimitList = CheckActiveTariffLimit(accountId, startDate);
        
        Boolean isTariffLimit = false;     
        List<Group__c> existingLinkedGroupList = new  List<Group__c>();
        //   AT-3236 - Chnaged By Dependra Singh                                             
        if(tariffLimitList != null && tariffLimitList.size() > 0){
            isTariffLimit = true;      
            //Find the existing Group linked to the Tariff Limit  
            existingLinkedGroupList = [SELECT Id, TariffLimit__c FROM Group__c WHERE TariffLimit__c =: tariffLimitList[0].Id];
        }
        // add the services
        List<Service__c> servicesToInsert = new List<Service__c>();
        for (AvailableService__c availableService : suppliedServices) {
            // get the move in reading Id for the service using the service type
            Id supplyPointDeviceId = supplyPointDeviceMap.get(availableService.ServiceType__c);
            Id deviceId = deviceMap.get(supplyPointDeviceId);
            Id moveInReadingId = moveInReadingsMap.get(deviceId);
            /*Changes for CLB-128 Starts Here*/
            if(mapOfAvailableServiceId2AvailableServiceItemList.containsKey(availableService.Id)){
                List<AvailableServiceItem__c> aServiceItemList = mapOfAvailableServiceId2AvailableServiceItemList.get(availableService.Id);
                if(aServiceItemList != null){
                    for(AvailableServiceItem__c aServiceItem: aServiceItemList){
                        if(mapServiceItemTypeId2ServiceItemType.containsKey(aServiceItem.ServiceItemType__c) && mapServiceItemTypeId2ServiceItemType.get(aServiceItem.ServiceItemType__c).get(occType + '__c') == true){
                            // create a new service
                            servicesToInsert.add(new Service__c(
                                BillingContract__c = contractId, 
                                AvailableService__c = availableService.Id, 
                                ServiceType__c = availableService.ServiceType__c, 
                                SupplyPoint__c = availableService.SupplyPoint__c, 
                                Reading__c = moveInReadingId,
                                OccupancyType__c = occType //AT-4038
                            ));
                            break;
                        }
                    }
                }
            }
        }
        /*Changes for CLB-128 Ends Here*/
        // add a sundry service if there are sundry service items to add
        Id sundryServiceTypeId;
        
        if (!selectedSundryItems.isEmpty()) {
            
            // get the sundry service type Id
            for (ServiceType__c serviceType : [select Id 
                                               from ServiceType__c 
                                               where Name = :CuAp_Constants.SERVICE_TYPE_SUNDRY]) {
                                                   sundryServiceTypeId = serviceType.Id;
                                               }
            
            // create a new sundry service
            servicesToInsert.add(new Service__c(
                BillingContract__c = contractId, 
                ServiceType__c = sundryServiceTypeId,
                OccupancyType__c = occType //AT-4038
            ));         
        }
        
        
        servicesToInsert = (List<Service__c>) GlUt_FieldSecurity.cleanseFields(servicesToInsert, false);
        insert servicesToInsert;
        
        // build maps to link service items to services
        Map<Id, Service__c> servicesToInsertMap = new Map<Id, Service__c>();     // map of services keyed on available service Id
        Id sundryServiceId;     // sundry service Id
        for (Service__c service : servicesToInsert) {
            servicesToInsertMap.put(service.AvailableService__c, service);
            // get the sundry service Id (if one was added)
            if (service.ServiceType__c == sundryServiceTypeId) {
                sundryServiceId = service.Id;
            }
        }
        Map<Id, AvailableBundle__c> availableBundleByIdMap = new Map<Id, AvailableBundle__c>();
        Map<Id, Id> availableBundleMap = new Map<Id, Id>();     // map of available service Ids keyed on available bundle Id
        for(AvailableBundle__c availableBundle : availableBundles) {
            availableBundleMap.put(availableBundle.Id, availableBundle.AvailableService__c);
            if(!availableBundleByIdMap.containsKey(availableBundle.Id)){
                availableBundleByIdMap.put(availableBundle.Id, availableBundle);
            }
        }
        
        // add the service items
        List<ServiceItem__c> serviceItemsToInsert = new List<ServiceItem__c>();
        List<ServiceItem__c> serviceItemsToLinkGrpItemToInsert = new List<ServiceItem__c>();
        //For each of the Available Service Items retrieved 
        
        Set<Id> setServiceItemType = new Set<Id>();
        for (AvailableServiceItem__c availableServiceItem : suppliedServiceItems) {
            if(availableServiceItem.ServiceItemType__c != null)
                setServiceItemType.add(availableServiceItem.ServiceItemType__c);
        }
        
        Map<Id,ServiceItemType__c> mapServiceItemTypeId2ServiceItemTypeObj = new Map<Id,ServiceItemType__c>([SELECT Id,Name,Owner__c,Tenant__c,Landlord__c FROM ServiceItemType__c WHERE Id IN: setServiceItemType]);
        
        for (AvailableServiceItem__c availableServiceItem : suppliedServiceItems) {
            Date billItemStartDate;
            if(mapServiceItemTypeId2ServiceItemTypeObj.keyset().size() > 0 && 
               mapServiceItemTypeId2ServiceItemTypeObj.containsKey(availableServiceItem.ServiceItemType__c) &&
               mapServiceItemTypeId2ServiceItemTypeObj.get(availableServiceItem.ServiceItemType__c).get(occType + '__c') == true){
                   
                   // get the service from the map using the available bundle's available service
                   Service__c service = servicesToInsertMap.get(availableBundleMap.get(availableServiceItem.AvailableBundle__c));
                   AvailableBundle__c objAvailableBundle = availableBundleByIdMap.get(availableServiceItem.AvailableBundle__c);
                   if(mapAvailServiceId2ServiceItemStartDate.keySet().size() > 0 && mapAvailServiceId2ServiceItemStartDate.containsKey(objAvailableBundle.AvailableService__c)){
                       billItemStartDate = mapAvailServiceId2ServiceItemStartDate.get(objAvailableBundle.AvailableService__c);
                   }
                   //If Available Bundle is marked as a Tariff Limit Bundle
                   if(isTariffLimit == true && objAvailableBundle != null && objAvailableBundle.TariffLimit__c == true){
                       // create a new service item
                       serviceItemsToLinkGrpItemToInsert.add(new ServiceItem__c(
                           Service__c = service.Id, 
                           AvailableServiceItem__c = availableServiceItem.Id, 
                           ServiceItemType__c = availableServiceItem.ServiceItemType__c, 
                           StartDate__c = billItemStartDate != null ? billItemStartDate : startDate,
                           EndDate__c = tariffLimitList.size() > 0 ? tariffLimitList[0].EndDate__c:null      
                       ));
                       
                   }else{
                       // create a new service item
                       ServiceItem__c objServiceItm = new ServiceItem__c();
                       objServiceItm.Service__c = service.Id;
                       objServiceItm.AvailableServiceItem__c = availableServiceItem.Id;
                       objServiceItm.ServiceItemType__c =availableServiceItem.ServiceItemType__c;
                       objServiceItm.StartDate__c = billItemStartDate != null ? billItemStartDate : startDate ;                       
                       serviceItemsToInsert.add(objServiceItm);
                   }
               }
        }      
        // add any sundry service items
        Set<Id> setSundrySIT = new Set<Id>();
        Map<Id,ServiceItemType__c> mapSITypeId2SITSundry; 
        if(selectedSundryItems != null && !selectedSundryItems.isEmpty()){
            for(ServiceItemType__c objSundrySIT :selectedSundryItems){
                setSundrySIT.add(objSundrySIT.Id);
            }
            if(setSundrySIT.size() > 0){
                mapSITypeId2SITSundry= new Map<Id,ServiceItemType__c>([SELECT Id,Name,Owner__c,Tenant__c,Landlord__c FROM ServiceItemType__c WHERE Id IN: setSundrySIT]);
            }   
        }
        for (ServiceItemType__c serviceItemType : selectedSundryItems) {
            
            if(mapSITypeId2SITSundry.keyset().size() > 0 &&
               mapSITypeId2SITSundry.containsKey(serviceItemType.Id) &&
               mapSITypeId2SITSundry.get(serviceItemType.Id).get(occType + '__c') == true){
                   
                   serviceItemsToInsert.add(new ServiceItem__c(
                       Service__c = sundryServiceId, 
                       ServiceItemType__c = serviceItemType.Id, 
                       StartDate__c = startDate 
                   ));
               }
        }
        if(serviceItemsToInsert.size() > 0){
            serviceItemsToInsert = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(serviceItemsToInsert, false);
            insert serviceItemsToInsert;
        }
        if(serviceItemsToLinkGrpItemToInsert.size() > 0){
            serviceItemsToLinkGrpItemToInsert = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(serviceItemsToLinkGrpItemToInsert, false);
            insert serviceItemsToLinkGrpItemToInsert;
            //Create a Group Item to link the Service item to the existing Group
            List<GroupItem__c> groupItemList = new List<GroupItem__c>();
            for(ServiceItem__c objServiceItem : serviceItemsToLinkGrpItemToInsert){
                GroupItem__c objGroupItm = new GroupItem__c();
                objGroupItm.ServiceItem__c = objServiceItem.Id;
                if(existingLinkedGroupList[0].id != null){
                    objGroupItm.Group__c = existingLinkedGroupList[0].id;
                    groupItemList.add(objGroupItm);
                }
            }
            if(groupItemList.size() > 0){
                insert groupItemList;
            }
        }
        return true;
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           26 Oct 2018
    @param          Id - accountId
    @param          Date - strMoveInDate
    @return         boolean
    @description    If the Account being moved into a Location has an active Tariff Limit associated, 
    where the Limit Start Date is <= Move in Date and the Limit End Date is > Move In Date or Null
    *******************************************************************************/ 
    public static List<TariffLimit__c> CheckActiveTariffLimit(Id accountId, Date moveInDate){
        List<TariffLimit__c> tariffLimitList  = new List<TariffLimit__c>();
        if(accountId != null  && moveInDate != null){
            tariffLimitList = [SELECT Id,Name,Account__c,EndDate__c,StartDate__c,Status__c 
                               FROM TariffLimit__c WHERE Account__c =: accountId 
                               AND StartDate__c <=: moveInDate AND (EndDate__c >: moveInDate OR EndDate__c = null)];
        }
        return tariffLimitList;
    }
    
    
    
}