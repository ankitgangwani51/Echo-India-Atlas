/******************************************************************************
@author         Echo: Tarun Gupta
@date           13 Dec 2018
@description    Class for Rural License utilities
@Revisions		AT-5390
@Revisions		AT-5372,5498,5382
*******************************************************************************/
public with sharing class GlUt_LicenseUtility {   
    private static final String CLASS_NAME = 'GlUt_LicenseUtility';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static final Id RuralOutletRecTypeId = Schema.SObjectType.SupplyPoint__c.getRecordTypeInfosByName().get(GlUt_APIConstantsSupplyPoint.RECORDTYPEOUTLETTYPE).getRecordTypeId(); //AT-2916
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           13 Dec 2018
    @param          List<RuralLicense__c> ruralLicensesToActivate
    @description    Activates a License so it can be Billed, creates Services and Service Items
    *******************************************************************************/
    public static void activateLicenses(List<RuralLicense__c> ruralLicensesToActivate) {
        WrapRuralLicense objWrapnew = new WrapRuralLicense();
        Savepoint sp = Database.setSavepoint();
        try {
            objWrapnew = getRuralLicenseDetails(ruralLicensesToActivate);
            
            List<Service__c> listServicesToInsert = createServiceAgainstSP(objWrapnew.mapSupplyPointIdToLocationId,objWrapnew.mapLocationIdToRuralLicenseId,objWrapnew.mapLicenseIdToContractId,objWrapnew.mapSPId2AvailService);
            listServicesToInsert = (List<Service__c>) GlUt_FieldSecurity.cleanseFields(listServicesToInsert, false);
            
            if (!listServicesToInsert.isEmpty()) insert listServicesToInsert;
            Map<Id,Id> mapAvailServiceIdtoNewServiceId = getServiceToAvailableService(listServicesToInsert);
            
            List<ServiceItem__c> listServiceItemsToInsert = createServiceItemsAgainstBundleItems(objWrapnew,mapAvailServiceIdtoNewServiceId);
            listServiceItemsToInsert = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(listServiceItemsToInsert, false);
            if (!listServiceItemsToInsert.isEmpty()) insert listServiceItemsToInsert;
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }  finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           13 Dec 2018
    @param          List<RuralLicense__c> ruralLicensesToCancel
    @description    Cancel Licenses , ends Service Items
    *******************************************************************************/
    public static void cancelLicenses(List<RuralLicense__c> ruralLicensesToCancel) {
        
        Set<Id> setBillingContractIds = new Set<Id>();
        Map<Id,RuralLicense__c> mapRuralLicenseIdToRuralLicenseObj = new Map<Id,RuralLicense__c>();
        Map<Id,Id> mapLocationIdToRuralLicenseId = new Map<Id,Id>();
        Map<Id,Id> mapSupplyPointIdToLocationId = new Map<Id,Id>();
        Map<Id,Id> mapServiceIdToSupplyPointId = new Map<Id,Id>();
        Map<Id,Id> mapServiceItemIdToServiceId = new Map<Id,Id>();
        List<ServiceItem__c> listServiceItems = new List<ServiceItem__c>();
        List<ServiceItem__c> listServiceItemsToUpdate = new List<ServiceItem__c>();
        List<ServiceItem__c> listOutletInfraServiceItems = new List<ServiceItem__c>();
        Map<Id,Id> mapServiceItemId2RuralLicenseId = new Map<Id,Id>();
        
        Savepoint sp = Database.setSavepoint();
        try {
            for(RuralLicense__c objRuralLicense : ruralLicensesToCancel){
                setBillingContractIds.add(objRuralLicense.BillingContract__c);
                if(!mapRuralLicenseIdToRuralLicenseObj.containsKey(objRuralLicense.Id)){
                    mapRuralLicenseIdToRuralLicenseObj.put(objRuralLicense.Id, objRuralLicense);
                }
            }
            //Infrastructure and outlet charges are linked to Rural Entitlement.
            listOutletInfraServiceItems = [SELECT Id,Name,StartDate__c,EndDate__c,Invalid__c,Service__c,RuralEntitlement__r.RuralLicense__c,Ended__c
                                           FROM ServiceItem__c 
                                           WHERE RuralEntitlement__c IN: 
                                           [SELECT Id FROM RuralEntitlement__c 
                                            WHERE RuralLicense__c IN: mapRuralLicenseIdToRuralLicenseObj.keyset()
                                            AND Active__c = true]];
            for(ServiceItem__c objServiceItems : listOutletInfraServiceItems){
                if(!mapServiceItemId2RuralLicenseId.containsKey(objServiceItems.Id))
                    mapServiceItemId2RuralLicenseId.put(objServiceItems.Id, objServiceItems.RuralEntitlement__r.RuralLicense__c);
            }
            for(ServiceItem__c objServiceItems : listOutletInfraServiceItems){
                if(mapRuralLicenseIdToRuralLicenseObj.containsKey(mapServiceItemId2RuralLicenseId.get(objServiceItems.Id))){
                    RuralLicense__c objRuralLicense = mapRuralLicenseIdToRuralLicenseObj.get(mapServiceItemId2RuralLicenseId.get(objServiceItems.Id));
                    Date licenseCancelledDate =  objRuralLicense.CancelledDate__c ;
                    if(objServiceItems.StartDate__c < licenseCancelledDate && (objServiceItems.EndDate__c == null || objServiceItems.EndDate__c > licenseCancelledDate)){
                        objServiceItems.EndDate__c = licenseCancelledDate;
                        objServiceItems.Ended__c = true;
                        listServiceItemsToUpdate.add(objServiceItems);
                    }
                    else if(objServiceItems.StartDate__c == licenseCancelledDate){
                        objServiceItems.Invalid__c = true;
                        listServiceItemsToUpdate.add(objServiceItems);
                    }
                }
            }
            
            for(Location__c objLocation : [SELECT Id,Name,RuralLicense__c FROM Location__c WHERE RuralLicense__c IN: mapRuralLicenseIdToRuralLicenseObj.keyset()]){
                if(!mapLocationIdToRuralLicenseId.containsKey(objLocation.Id)){
                    mapLocationIdToRuralLicenseId.put(objLocation.Id, objLocation.RuralLicense__c);
                }
            }
            for(SupplyPoint__c objSupplyPoint : [SELECT Id,Name,Location__c FROM SupplyPoint__c WHERE Location__c IN: mapLocationIdToRuralLicenseId.keyset() AND RecordTypeId =: RuralOutletRecTypeId ]){
                if(!mapSupplyPointIdToLocationId.containsKey(objSupplyPoint.Id)){
                    mapSupplyPointIdToLocationId.put(objSupplyPoint.Id, objSupplyPoint.Location__c);
                }
            }
            for(Service__c objService : [SELECT Id,SupplyPoint__c FROM Service__c WHERE BillingContract__c IN : setBillingContractIds AND SupplyPoint__c IN : mapSupplyPointIdToLocationId.keySet()]){
                if(!mapServiceIdToSupplyPointId.containsKey(objService.Id)){
                    mapServiceIdToSupplyPointId.put(objService.Id, objService.SupplyPoint__c);
                }
            }
            listServiceItems = [SELECT Id,Name,StartDate__c,EndDate__c,Invalid__c,Service__c,Ended__c FROM ServiceItem__c WHERE Service__c IN: mapServiceIdToSupplyPointId.keyset()];
            
            for(ServiceItem__c objServiceItem : listServiceItems){
                if(!mapServiceItemIdToServiceId.containsKey(objServiceItem.Id)){
                    mapServiceItemIdToServiceId.put(objServiceItem.Id, objServiceItem.Service__c);
                }
            }
            for(ServiceItem__c objSI : listServiceItems){
                if(mapServiceItemIdToServiceId.containsKey(objSI.Id)){
                    Id serviceId = mapServiceItemIdToServiceId.get(objSI.Id);
                    if(mapServiceIdToSupplyPointId.containsKey(serviceId)){
                        Id supplyPointId = mapServiceIdToSupplyPointId.get(serviceId);
                        if(mapSupplyPointIdToLocationId.containsKey(supplyPointId)){
                            Id locationId = mapSupplyPointIdToLocationId.get(supplyPointId);
                            if(mapLocationIdToRuralLicenseId.containsKey(locationId)){
                                Id ruralLicenseId = mapLocationIdToRuralLicenseId.get(locationId);
                                if(mapRuralLicenseIdToRuralLicenseObj.containsKey(ruralLicenseId)){
                                    RuralLicense__c objRuralLicense = mapRuralLicenseIdToRuralLicenseObj.get(ruralLicenseId);
                                    Date licenseCancelledDate =  objRuralLicense.CancelledDate__c ;
                                    if(objSI.StartDate__c < licenseCancelledDate && (objSI.EndDate__c == null || objSI.EndDate__c > licenseCancelledDate)){
                                        objSI.EndDate__c = licenseCancelledDate;
                                        objSI.Ended__c = true;
                                        listServiceItemsToUpdate.add(objSI);
                                    }
                                    else if(objSI.StartDate__c == licenseCancelledDate){
                                        objSI.Invalid__c = true;
                                        listServiceItemsToUpdate.add(objSI);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            listServiceItemsToUpdate = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(listServiceItemsToUpdate, false);
            if (!listServiceItemsToUpdate.isEmpty()) update listServiceItemsToUpdate;
        } catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }  finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           13 Dec 2018
    @param          List<RuralLicense__c> ruralLicensesToActivate
    @return         Wrapper WrapRuralLicense
    @description    Get all license related details linked to all RuralLicense__c records
    *******************************************************************************/
    public static WrapRuralLicense getRuralLicenseDetails(List<RuralLicense__c> ruralLicensesToActivate) {
        Map<Id,RuralLicense__c> mapRuralLicenseIdToRuralLicenseObj = new Map<Id,RuralLicense__c>();
        Map<Id,Id> mapRuralLicenseIdToContractId = new Map<Id,Id>();
        Map<Id,Id> mapLocationIdToRuralLicenseId = new Map<Id,Id>();
        Map<Id,Id> mapSupplyPointIdToLocationId = new Map<Id,Id>();
        Map<Id,Id> mapAvailServiceIdToSupplyPointId = new Map<Id,Id>();
        Map<Id,List<AvailableService__c>> mapSPId2AvailService = new Map<Id,List<AvailableService__c>>();
        Set<Id> setAvailServiceIds = new Set<Id>();
        List<List<AvailableService__c>> listAvailServices = new List<List<AvailableService__c>>();
        WrapRuralLicense objWrapnew = new WrapRuralLicense();
        for(RuralLicense__c objRuralLicense : ruralLicensesToActivate){
            
            // Can remove this map (later)
            if(!mapRuralLicenseIdToContractId.containsKey(objRuralLicense.Id)){
                mapRuralLicenseIdToContractId.put(objRuralLicense.Id, objRuralLicense.BillingContract__c);
            }
            // Keep this one.
            if(!mapRuralLicenseIdToRuralLicenseObj.containsKey(objRuralLicense.Id)){
                mapRuralLicenseIdToRuralLicenseObj.put(objRuralLicense.Id, objRuralLicense);
            }
        }
        for(Location__c objLocation : [SELECT Id,Name,RuralLicense__c FROM Location__c WHERE RuralLicense__c IN: mapRuralLicenseIdToRuralLicenseObj.keyset()]){
            if(!mapLocationIdToRuralLicenseId.containsKey(objLocation.Id)){
                mapLocationIdToRuralLicenseId.put(objLocation.Id, objLocation.RuralLicense__c);
            }
        }
        for(SupplyPoint__c objSupplyPoint : [SELECT Id,Name,Location__c FROM SupplyPoint__c WHERE Location__c IN: mapLocationIdToRuralLicenseId.keyset() AND RecordTypeId =: RuralOutletRecTypeId ]){
            if(!mapSupplyPointIdToLocationId.containsKey(objSupplyPoint.Id)){
                mapSupplyPointIdToLocationId.put(objSupplyPoint.Id, objSupplyPoint.Location__c);
            }
        }
        for(AvailableService__c objAvailService : [SELECT Id,Name,SupplyPoint__c,ServiceType__c FROM AvailableService__c WHERE SupplyPoint__c IN: mapSupplyPointIdToLocationId.Keyset()]){
            if(!mapSPId2AvailService.containsKey(objAvailService.SupplyPoint__c)){
                mapSPId2AvailService.put(objAvailService.SupplyPoint__c,new List <AvailableService__c>());
            }
            mapSPId2AvailService.get(objAvailService.SupplyPoint__c).add(objAvailService);
            
            if(!mapAvailServiceIdToSupplyPointId.containsKey(objAvailService.Id)){
                mapAvailServiceIdToSupplyPointId.put(objAvailService.Id, objAvailService.SupplyPoint__c);
            }
        }
        listAvailServices = mapSPId2AvailService.values();
        for(List<AvailableService__c> objListAS: listAvailServices){
            for(AvailableService__c objAS : objListAS){
                setAvailServiceIds.add(objAS.Id);
            }
        }
        Map<Id, AvailableBundle__c> mapAvailabelBundleById = new Map<Id, AvailableBundle__c>([SELECT Id,Name,AvailableService__c,Bundle__c,
                                                                                              AvailableService__r.SupplyPoint__c,AvailableService__r.SupplyPoint__r.Location__c,
                                                                                              AvailableService__r.SupplyPoint__r.Location__r.RuralLicense__c 
                                                                                              FROM AvailableBundle__c 
                                                                                              WHERE AvailableService__c IN: setAvailServiceIds]);     
        
        Map<Id, List<AvailableServiceItem__c>> mapListofASIByAvailableBundleId = new Map<Id, List<AvailableServiceItem__c>>();
        if(mapAvailabelBundleById != null && mapAvailabelBundleById.size() > 0){
            
            
            for(AvailableServiceItem__c objASI : [Select Id, AvailableBundle__c,AvailableBundle__r.AvailableService__c,BundleItem__c,StartDate__c, 
                                                  EndDate__c,ServiceItemType__c 
                                                  FROM AvailableServiceItem__c 
                                                  WHERE AvailableBundle__c IN : mapAvailabelBundleById.keySet()]){
                                                      if(mapAvailServiceIdToSupplyPointId.containsKey(objASI.AvailableBundle__r.AvailableService__c)){
                                                          if(mapAvailServiceIdToSupplyPointId.get(objASI.AvailableBundle__r.AvailableService__c) != null && 
                                                             mapSupplyPointIdToLocationId.containsKey(mapAvailServiceIdToSupplyPointId.get(objASI.AvailableBundle__r.AvailableService__c))){
                                                                 if(mapSupplyPointIdToLocationId.get(mapAvailServiceIdToSupplyPointId.get(objASI.AvailableBundle__r.AvailableService__c)) != null && 
                                                                    mapLocationIdToRuralLicenseId.containsKey(mapSupplyPointIdToLocationId.get(mapAvailServiceIdToSupplyPointId.get(objASI.AvailableBundle__r.AvailableService__c)))){
                                                                        Id ruralLicenseId = mapLocationIdToRuralLicenseId.get(mapSupplyPointIdToLocationId.get(mapAvailServiceIdToSupplyPointId.get(objASI.AvailableBundle__r.AvailableService__c)));
                                                                        if(ruralLicenseId != null && mapRuralLicenseIdToRuralLicenseObj.containsKey(ruralLicenseId)){
                                                                            
                                                                            RuralLicense__c objRuralLicesnse = mapRuralLicenseIdToRuralLicenseObj.get(ruralLicenseId);
                                                                            if(objRuralLicesnse != null && (objRuralLicesnse.StartDate__c <= objASI.EndDate__c || objASI.EndDate__c == null)){
                                                                                if(!mapListofASIByAvailableBundleId.containsKey(objASI.AvailableBundle__c)){
                                                                                    mapListofASIByAvailableBundleId.put(objASI.AvailableBundle__c,new List <AvailableServiceItem__c>());
                                                                                }
                                                                                mapListofASIByAvailableBundleId.get(objASI.AvailableBundle__c).add(objASI);
                                                                            }
                                                                        }
                                                                    }
                                                             }
                                                      }
                                                  }
        }       
        objWrapnew.mapAvailabelBundleById= mapAvailabelBundleById;
        objWrapnew.mapListofASIByAvailableBundleId = mapListofASIByAvailableBundleId;
        objWrapnew.mapRuralLicenseIdToRuralLicenseObj = mapRuralLicenseIdToRuralLicenseObj;
        objWrapnew.mapLicenseIdToContractId = mapRuralLicenseIdToContractId;
        objWrapnew.mapLocationIdToRuralLicenseId = mapLocationIdToRuralLicenseId;
        objWrapnew.mapSupplyPointIdToLocationId = mapSupplyPointIdToLocationId;
        objWrapnew.mapAvailServiceIdToSupplyPointId = mapAvailServiceIdToSupplyPointId;
        objWrapnew.mapSPId2AvailService = mapSPId2AvailService;
        return objWrapnew;
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           13 Dec 2018
    @param          none
    @return         none
    @description    wrapper class to hold the rural license record
    *******************************************************************************/
    public class WrapRuralLicense{        
        public Map<Id,RuralLicense__c> mapRuralLicenseIdToRuralLicenseObj; 
        public Map<Id,AvailableBundle__c> mapAvailabelBundleById; 
        public Map<Id, List<AvailableServiceItem__c>> mapListofASIByAvailableBundleId; 
        public Map<Id,Id> mapLicenseIdToContractId; 
        public Map<Id,Id> mapLocationIdToRuralLicenseId;
        public Map<Id,Id> mapSupplyPointIdToLocationId;
        public Map<Id,Id> mapAvailServiceIdToSupplyPointId;
        public Map<Id,List<AvailableService__c>> mapSPId2AvailService;
        
        public WrapRuralLicense(){
            this.mapRuralLicenseIdToRuralLicenseObj = new Map<Id,RuralLicense__c>();
            this.mapAvailabelBundleById = new Map<Id,AvailableBundle__c>();
            this.mapLicenseIdToContractId = new Map<Id,Id>();
            this.mapLocationIdToRuralLicenseId = new Map<Id,Id>();
            this.mapSupplyPointIdToLocationId = new Map<Id,Id>();
            this.mapAvailServiceIdToSupplyPointId = new Map<Id,Id>();
            this.mapSPId2AvailService = new Map<Id,List<AvailableService__c>>();
        } 
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           13 Dec 2018
    @param          Map<Id,Id> mapSupplyPointIdToLocationId,Map<Id,Id> mapLocationIdToRuralLicenseId,Map<Id,Id> mapRuralLicenseIdToContractId
    @return         List<Service__c>
    @description    Create service against SP
    *******************************************************************************/
    public static List<Service__c> createServiceAgainstSP(Map<Id,Id> mapSupplyPointIdToLocationId, Map<Id,Id> mapLocationIdToRuralLicenseId, Map<Id,Id> mapRuralLicenseIdToContractId, Map<Id,List<AvailableService__c>> mapSPId2AvailService) {
        
        List<Service__c> listServicesToInsert = new List<Service__c>();
        
        for(Id objSupplyPointId : mapSupplyPointIdToLocationId.Keyset()){
            Service__c objNewService = new Service__c();
            objNewService.AvailableService__c = mapSPId2AvailService.get(objSupplyPointId)[0].Id;
            objNewService.BillingContract__c = mapRuralLicenseIdToContractId.get(mapLocationIdToRuralLicenseId.get(mapSupplyPointIdToLocationId.get(objSupplyPointId)));
            objNewService.OccupancyType__c = Label.CuAp_AUMoveInOccTypeOwner;
            objNewService.ServiceType__c = mapSPId2AvailService.get(objSupplyPointId)[0].ServiceType__c;
            objNewService.SupplyPoint__c = objSupplyPointId;
            listServicesToInsert.add(objNewService);
        }
        return listServicesToInsert;
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           13 Dec 2018
    @param          Map<Id,Id> mapSupplyPointIdToLocationId,Map<Id,Id> mapLocationIdToRuralLicenseId,Map<Id,Id> mapRuralLicenseIdToContractId
    @return         List<Service__c>
    @description    Create service Items against bundle items
    *******************************************************************************/
    public static List<ServiceItem__c> createServiceItemsAgainstBundleItems(WrapRuralLicense objWrapnew, Map<Id,Id> mapAvailServiceIdtoNewServiceId) {
        List<ServiceItem__c> listServiceItemsToInsert = new List<ServiceItem__c>();
        for(Id objABId : objWrapnew.mapListofASIByAvailableBundleId.keySet()){
            Id newServiceId;
            if(objWrapnew.mapAvailabelBundleById.containsKey(objABId)){
                Id availServiceId = objWrapnew.mapAvailabelBundleById.get(objABId).AvailableService__c;
                if(mapAvailServiceIdtoNewServiceId.containsKey(availServiceId)){
                    newServiceId = mapAvailServiceIdtoNewServiceId.get(availServiceId);
                }
                if(objWrapnew.mapAvailServiceIdToSupplyPointId.containsKey(availServiceId)){
                    Id supplyPointId =  objWrapnew.mapAvailServiceIdToSupplyPointId.get(availServiceId);
                    if(objWrapnew.mapSupplyPointIdToLocationId.containsKey(supplyPointId)){
                        Id locationId = objWrapnew.mapSupplyPointIdToLocationId.get(supplyPointId);
                        if(newServiceId != null && objWrapnew.mapLocationIdToRuralLicenseId.containsKey(locationId)){
                            Id ruralLicenseId = objWrapnew.mapLocationIdToRuralLicenseId.get(locationId);
                            if(objWrapnew.mapRuralLicenseIdToRuralLicenseObj.containsKey(ruralLicenseId)){
                                if(objWrapnew.mapListofASIByAvailableBundleId.get(objABId) != null && objWrapnew.mapListofASIByAvailableBundleId.get(objABId).size() > 0){
                                    for(AvailableServiceItem__c objASI : objWrapnew.mapListofASIByAvailableBundleId.get(objABId)){
                                        ServiceItem__c objServiceItem = new ServiceItem__c();
                                        objServiceItem.Service__c = newServiceId;
                                        objServiceItem.ServiceItemType__c = objASI.ServiceItemType__c;
                                        objServiceItem.StartDate__c = objWrapnew.mapRuralLicenseIdToRuralLicenseObj.get(ruralLicenseId).StartDate__c;
                                        objServiceItem.AvailableServiceItem__c = objASI.Id;
                                        listServiceItemsToInsert.add(objServiceItem);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return listServiceItemsToInsert;
    }
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           13 Dec 2018
    @param          List<Service__c> listServicesToInsert
    @return         Map<Id,Id> avail bundle records linked to AS
    @description    Get AS records linked to all services
    *******************************************************************************/
    public static Map<Id,Id> getServiceToAvailableService(List<Service__c> listServicesToInsert) {
        
        Map<Id,Id> mapAvailServiceIdtoNewServiceId = new Map<Id,Id>();
        
        for(Service__c objService : listServicesToInsert){
            if(!mapAvailServiceIdtoNewServiceId.containsKey(objService.AvailableService__c)){
                mapAvailServiceIdtoNewServiceId.put(objService.AvailableService__c,objService.Id);
            }
        }
        return mapAvailServiceIdtoNewServiceId;
    }    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           25 Mar 2019
    @param          RuralLicense__c objNewRuralLicense,RuralEntitlement__c objNewRuralEntitlement,Date transferredLicenseEndDate,String contractToTransferID
    @return         Void
    @description    Create OutletCharge__c\InfrastructureCharge__c\HeadworkInfrastructureCharge__c service\Items linked to the Rural license
    *******************************************************************************/
    public static void createServiceAndSILinkedToLicenseBulkified(List<RuralLicense__c> listNewRuralLicenses,Map<Id,Date> mapLicenseId2TransferredLicenseEndDate,Map<Id,String> mapLicenseId2contractToTransferID,Map<Id,RuralEntitlement__c> mapLicenseId2OldEntitlementObject) {
        Set<Id> setServiceItemTypes = new Set<Id>();
        Map<Id,Id> mapServiceItemTypeId2ServiceTypeId = new Map<Id,Id>();
        Map<String,Service__c> mapUniqueKey2ServiceObj = new Map<String,Service__c>();
        Map<String,List<ServiceItem__c>> mapUniqueKey2ListOfServiceItemObj = new Map<String,List<ServiceItem__c>>();
        Map<String,RuralEntitlement__c> mapUniqueKey2NewRuralEntitlement = new Map<String,RuralEntitlement__c>();
        Map<String,String> mapSITUniqueKey2LicenseKey = new Map<String,String>();
        Map<Id,Decimal> mapOfRuralEntitlementIdToBaseVolumeWithTransfers = new Map<Id,Decimal>(); 
        List<ServiceItem__c> listServiceItemToInsert = new List<ServiceItem__c>();
        
        for(RuralLicense__c objNewRuralLicense: listNewRuralLicenses){
            if(objNewRuralLicense.OutletCharge__c != null)
                setServiceItemTypes.add(objNewRuralLicense.OutletCharge__c);
            if(objNewRuralLicense.InfrastructureCharge__c != null)
                setServiceItemTypes.add(objNewRuralLicense.InfrastructureCharge__c);
            if(objNewRuralLicense.HeadworkInfrastructureCharge__c != null)
                setServiceItemTypes.add(objNewRuralLicense.HeadworkInfrastructureCharge__c);
        }
        if(setServiceItemTypes.size() > 0){
            for(ServiceItemType__c objSIT : [SELECT Id,Name,ServiceItemFamily__c, ServiceItemFamily__r.ServiceType__c
                                             FROM ServiceItemType__c
                                             WHERE Id IN : setServiceItemTypes]){
                                                 if(!mapServiceItemTypeId2ServiceTypeId.containsKey(objSIT.Id))
                                                     mapServiceItemTypeId2ServiceTypeId.put(objSIT.Id, objSIT.ServiceItemFamily__r.ServiceType__c);
                                             }
        }
        for(RuralLicense__c objNewRuralLicense: listNewRuralLicenses){
            String uniqueKey = String.valueOf(objNewRuralLicense.Id) + '-' + mapLicenseId2contractToTransferID.get(objNewRuralLicense.Id);            
            RuralEntitlement__c objNewEntitlement = new RuralEntitlement__c();
            objNewEntitlement.StartDate__c = objNewRuralLicense.StartDate__c;
            objNewEntitlement.Active__c = true;
            objNewEntitlement.SeasonalAllocation__c = 100;
            objNewEntitlement.RuralLicense__c = objNewRuralLicense.Id;
            if(mapLicenseId2OldEntitlementObject != null && !mapLicenseId2OldEntitlementObject.isEmpty() && mapLicenseId2OldEntitlementObject.containsKey(objNewRuralLicense.Id)){
                objNewEntitlement.TransferFromEntitlement__c = mapLicenseId2OldEntitlementObject.get(objNewRuralLicense.Id).Id;
                objNewEntitlement.TransferFromRemainingVolume__c = mapLicenseId2OldEntitlementObject.get(objNewRuralLicense.Id).RemainingVolume__c;
            }
            if(!mapUniqueKey2NewRuralEntitlement.containsKey(uniqueKey))
                mapUniqueKey2NewRuralEntitlement.put(uniqueKey,objNewEntitlement);
            if(objNewRuralLicense.OutletCharge__c != null){
                String strUniqueValue = uniqueKey + '-' + String.valueOf(mapServiceItemTypeId2ServiceTypeId.get(objNewRuralLicense.OutletCharge__c));
                if(!mapUniqueKey2ServiceObj.containsKey(strUniqueValue))
                    mapUniqueKey2ServiceObj.put(strUniqueValue,createServiceNew(mapServiceItemTypeId2ServiceTypeId.get(objNewRuralLicense.OutletCharge__c),mapLicenseId2contractToTransferID.get(objNewRuralLicense.Id)));
                if(!mapUniqueKey2ListOfServiceItemObj.containsKey(strUniqueValue))
                    mapUniqueKey2ListOfServiceItemObj.put(strUniqueValue,new List<ServiceItem__c>());
                mapUniqueKey2ListOfServiceItemObj.get(strUniqueValue).add(createServiceItemNew(objNewRuralLicense.OutletCharge__c, objNewRuralLicense, mapLicenseId2TransferredLicenseEndDate.get(objNewRuralLicense.Id), true));
                if(!mapSITUniqueKey2LicenseKey.containsKey(strUniqueValue))
                    mapSITUniqueKey2LicenseKey.put(strUniqueValue,uniqueKey);
            }
            if(objNewRuralLicense.InfrastructureCharge__c != null){
                String strUniqueValue = uniqueKey + '-' + String.valueOf(mapServiceItemTypeId2ServiceTypeId.get(objNewRuralLicense.InfrastructureCharge__c));
                if(!mapUniqueKey2ServiceObj.containsKey(strUniqueValue))
                    mapUniqueKey2ServiceObj.put(strUniqueValue,createServiceNew(mapServiceItemTypeId2ServiceTypeId.get(objNewRuralLicense.InfrastructureCharge__c),mapLicenseId2contractToTransferID.get(objNewRuralLicense.Id)));
                if(!mapUniqueKey2ListOfServiceItemObj.containsKey(strUniqueValue))
                    mapUniqueKey2ListOfServiceItemObj.put(strUniqueValue,new List<ServiceItem__c>());
                mapUniqueKey2ListOfServiceItemObj.get(strUniqueValue).add(createServiceItemNew(objNewRuralLicense.InfrastructureCharge__c, objNewRuralLicense, mapLicenseId2TransferredLicenseEndDate.get(objNewRuralLicense.Id), false));
                if(!mapSITUniqueKey2LicenseKey.containsKey(strUniqueValue))
                    mapSITUniqueKey2LicenseKey.put(strUniqueValue,uniqueKey);
            }
            if(objNewRuralLicense.HeadworkInfrastructureCharge__c != null){
                String strUniqueValue = uniqueKey + '-' + String.valueOf(mapServiceItemTypeId2ServiceTypeId.get(objNewRuralLicense.HeadworkInfrastructureCharge__c));
                if(!mapUniqueKey2ServiceObj.containsKey(strUniqueValue))
                    mapUniqueKey2ServiceObj.put(strUniqueValue,createServiceNew(mapServiceItemTypeId2ServiceTypeId.get(objNewRuralLicense.HeadworkInfrastructureCharge__c),mapLicenseId2contractToTransferID.get(objNewRuralLicense.Id)));
                if(!mapUniqueKey2ListOfServiceItemObj.containsKey(strUniqueValue))
                    mapUniqueKey2ListOfServiceItemObj.put(strUniqueValue,new List<ServiceItem__c>());
                mapUniqueKey2ListOfServiceItemObj.get(strUniqueValue).add(createServiceItemNew(objNewRuralLicense.HeadworkInfrastructureCharge__c, objNewRuralLicense, mapLicenseId2TransferredLicenseEndDate.get(objNewRuralLicense.Id), false));
                if(!mapSITUniqueKey2LicenseKey.containsKey(strUniqueValue))
                    mapSITUniqueKey2LicenseKey.put(strUniqueValue,uniqueKey);
            }
        }
        if(!mapUniqueKey2NewRuralEntitlement.isEmpty()){
            GlUt_FieldSecurity.createMapAfterCleanse(mapUniqueKey2NewRuralEntitlement);
            
            for(RuralEntitlement__c ruralEnt : [SELECT Id, BaseVolumewithTransfers__c FROM RuralEntitlement__c WHERE Id IN: mapUniqueKey2NewRuralEntitlement.values()]){
                if(!mapOfRuralEntitlementIdToBaseVolumeWithTransfers.containsKey(ruralEnt.Id)){
                    mapOfRuralEntitlementIdToBaseVolumeWithTransfers.put(ruralEnt.Id,ruralEnt.BaseVolumewithTransfers__c);
                }
            }
            
        }
        if(!mapUniqueKey2ServiceObj.isEmpty()){
            GlUt_FieldSecurity.createMapAfterCleanse(mapUniqueKey2ServiceObj);
            if(!mapUniqueKey2ListOfServiceItemObj.isEmpty()){
                for(String strKey : mapUniqueKey2ListOfServiceItemObj.keyset()){
                    for(ServiceItem__c objServiceItemToInsert :mapUniqueKey2ListOfServiceItemObj.get(strKey)){
                        objServiceItemToInsert.Service__c = mapUniqueKey2ServiceObj.get(strKey).Id;                    
                        objServiceItemToInsert.RuralEntitlement__c = mapUniqueKey2NewRuralEntitlement.get(mapSITUniqueKey2LicenseKey.get(strKey)).Id;
                        // For outlet, the quantity should be same. For Infra and headInfra, it should be BaseVolumewithTransfers__c/1000
                        objServiceItemToInsert.Quantity__c = objServiceItemToInsert.Quantity__c != null ? objServiceItemToInsert.Quantity__c : mapOfRuralEntitlementIdToBaseVolumeWithTransfers.get(mapUniqueKey2NewRuralEntitlement.get(mapSITUniqueKey2LicenseKey.get(strKey)).Id)/1000;
                        listServiceItemToInsert.add(objServiceItemToInsert);
                    }
                }
            }
        }
        if(!listServiceItemToInsert.isEmpty()){
            listServiceItemToInsert = (List<ServiceItem__c>)GlUt_FieldSecurity.cleanseFields(listServiceItemToInsert, false);
            if(!listServiceItemToInsert.isEmpty())
                insert listServiceItemToInsert;
        }
    }
    /******************************************************************************
    @author         Tarun Gupta
    @date           25 Mar 2019
    @param          String ruralServiceType, String contractToTransferID
	@return			Id of newly created service
    @description    This method returns the Id of newly created service
    *******************************************************************************/
    public static Service__c createServiceNew(String ruralServiceType, String contractToTransferID){        
        Service__c objService = new Service__c();
        objService.BillingContract__c = Id.ValueOf(contractToTransferID);
        objService.ServiceType__c = ruralServiceType;
        return objService;
    }
    /******************************************************************************
    @author         Tarun Gupta
    @date           25 Mar 2019
	@param          Id service Id, Id service Item Type Id, Id entitlement Id, RuralLicense__c, Date transferred License EndDate, Decimal baseVolumentWithTransfer, Boolean outletServiceItemType
    @return         ServiceItem__c
    @description    This method returns the object of service Item to Insert
    *******************************************************************************/
    public static ServiceItem__c createServiceItemNew(Id serviceItemTypeId, RuralLicense__c objNewRuralLicense, Date transferredLicenseEndDate, Boolean outletServiceItemType) {
        ServiceItem__c objServiceItem = new ServiceItem__c();
        objServiceItem.ServiceItemType__c = serviceItemTypeId;
        objServiceItem.StartDate__c = transferredLicenseEndDate;
        if(outletServiceItemType)
            objServiceItem.Quantity__c = objNewRuralLicense.TotalChargeableOutlets__c;
        return objServiceItem;
    }
}