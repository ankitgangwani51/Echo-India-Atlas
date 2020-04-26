/******************************************************************************
@author    		Echo: Tarun Gupta
@date      		24 Oct 2018
@description 	Class for ServiceItem utilities
@Revisions		13 Feb 2019 , Tarun , AT-5170,5171 
@Revisions		AT-5326
@Revisions		AT-5387
*******************************************************************************/
public with sharing class GlUt_AUServiceItemUtilities {
    
    private static final String CLASS_NAME = 'GlUt_AUServiceItemUtilities';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		24 Oct 2018
    @param			Id - location Id
    @param			Date - the end date for the service items
    @param			Boolean - true for a household account
    @description 	Ends all the active service items at a location 
    If all service items on a contract are ended it will also end the contract
    *******************************************************************************/
    public static Set<Id> endTenantServiceItemAtSupplyAtLocation(Id locationId, Date endDate, String occType) {
        
        Set<Id> contractIds = new Set<Id>();
        // end date all the service items on the contract
        List<ServiceItem__c> serviceItemsToEndDate = new List<ServiceItem__c>();
        
        for (ServiceItem__c serviceItem : [SELECT Id, StartDate__c, EndDate__c, ServiceItemType__c, Invalid__c, Service__r.BillingContract__c, Ended__c, ServiceItemType__r.Tenant__c, Service__r.OccupancyType__c
                                           FROM ServiceItem__c 
                                           WHERE Service__r.Supplypoint__r.Location__c = :locationId 
                                           AND StartDate__c <=: endDate
                                           AND (EndDate__c = null OR EndDate__c >: endDate )]) {
                                               if(occType == Label.CuAp_AUMoveInOccType && serviceItem.ServiceItemType__r.Tenant__c && serviceItem.Service__r.OccupancyType__c == Label.CuAp_AUMoveInOccType){
                                                   if(serviceItem.StartDate__c == endDate){
                                                       serviceItem.Invalid__c = true;
                                                   }
                                                   serviceItem.EndDate__c = endDate;
                                                   serviceItem.Ended__c = true;
                                                   contractIds.add(serviceItem.Service__r.BillingContract__c);
                                                   serviceItemsToEndDate.add(serviceItem);
                                               }
                                           }
        // update the service items
        serviceItemsToEndDate = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(serviceItemsToEndDate, false);
        if (!serviceItemsToEndDate.isEmpty()) update serviceItemsToEndDate;
        
        return contractIds;
    }
    
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		24 Oct 2018
    @param			Id - location Id
    @param			Date - the end date for the service items
    @param			Boolean - true for a household account
    @description 	Ends all the active service items at a location 
    If all service items on a contract are ended it will also end the contract
    *******************************************************************************/
    public static Set<Id> endOwnerServiceItemAtSupplyAtLocation(Id locationId, Date endDate) {
        
        Map<Id,String> mapServiceId2ServiceOccType = new Map<Id,String>();
        Set<Id> contractIds = new Set<Id>();
        
        // end date all the service items on the contract
        List<ServiceItem__c> serviceItemsToEndDate = new List<ServiceItem__c>();
        
        for (ServiceItem__c serviceItem : [SELECT Id, StartDate__c, EndDate__c, ServiceItemType__c, Invalid__c, Service__r.OccupancyType__c,ServiceItemType__r.Landlord__c,Service__r.BillingContract__c, Ended__c
                                           FROM ServiceItem__c 
                                           WHERE Service__r.Supplypoint__r.Location__c = :locationId 
                                           AND StartDate__c <=: endDate
                                           AND (EndDate__c = null OR EndDate__c >: endDate)]) {
                                               if(!serviceItem.ServiceItemType__r.Landlord__c){
                                                   serviceItem.EndDate__c = endDate;
                                                   serviceItem.Ended__c = true;
                                                   if(serviceItem.StartDate__c == endDate){
                                                       serviceItem.Invalid__c = true;
                                                   }
                                                   contractIds.add(serviceItem.Service__r.BillingContract__c);
                                                   serviceItemsToEndDate.add(serviceItem);
                                               }
                                               else{
                                                   //serviceItem.Service__r.OccupancyType__c = 'Landlord';
                                                   if(!mapServiceId2ServiceOccType.containsKey(serviceItem.Service__c))
                                                       mapServiceId2ServiceOccType.put(serviceItem.Service__c, Label.CuAp_AUMoveInOccTypeLandlord);
                                               }
                                           }
        // update the service items
        serviceItemsToEndDate = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(serviceItemsToEndDate, false);
        if (!serviceItemsToEndDate.isEmpty()) update serviceItemsToEndDate;
        
        if(mapServiceId2ServiceOccType.keySet().size() > 0){
            List<Service__c> listService = new List<Service__c>();
            listService = [SELECT Id,Name,OccupancyType__c
                           FROM Service__c
                           WHERE Id IN :mapServiceId2ServiceOccType.keySet()];
            
            for(Service__c objService : listService){
                objService.OccupancyType__c = Label.CuAp_AUMoveInOccTypeLandlord;
            }
            // update the service items
            if(!listService.isEmpty()){
                listService = (List<Service__c>) GlUt_FieldSecurity.cleanseFields(listService, false);
                if (!listService.isEmpty()) update listService;
            }
        }
        return contractIds;
    }
    
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		24 Oct 2018
    @param			Id - location Id
    @param			Date - the end date for the service items
    @param			Boolean - true for a household account
    @description 	Ends all the active service items at a location 
    If all service items on a contract are ended it will also end the contract
    *******************************************************************************/
    public static Map<Id,Date> endOwnerAndLandlordServiceItemAtLocation(Id locationId, Date endDate, String occType) {
        Date lastBillItemEndDate;
        Id previousOccupantContractId;
        Map<Id,Date> mapPreviousOccContract2LastBillItemEndDate = new Map<Id,Date>();
        
        List<ServiceItem__c> serviceItemsToEndDate = new List<ServiceItem__c>();
        List<ServiceItem__c> listServiceItems = new List<ServiceItem__c>();
        List<BillItem__c> listBillItems = new List<BillItem__c>();
        Set<Id> setServiceItemId = new Set<Id>();
        listServiceItems = [SELECT Id, StartDate__c, EndDate__c, ServiceItemType__c, Invalid__c, Service__r.OccupancyType__c, Service__r.BillingContract__c, Ended__c,
                            ServiceItemType__r.Owner__c , ServiceItemType__r.Landlord__c
                            FROM ServiceItem__c 
                            WHERE Service__r.Supplypoint__r.Location__c = :locationId 
                            AND StartDate__c <=: endDate
                            AND (EndDate__c = null OR EndDate__c >: endDate)
                            AND (ServiceItemType__r.Owner__c = true OR ServiceItemType__r.Landlord__c = true)
                            AND (Service__r.OccupancyType__c = :Label.CuAp_AUMoveInOccTypeLandlord OR Service__r.OccupancyType__c = :Label.CuAp_AUMoveInOccTypeOwner) ];
        
        system.debug('listServiceItems**'+ listServiceItems);
        for(ServiceItem__c objSI : listServiceItems){
            setServiceItemId.add(objSI.Id);
        }
        
        if(setServiceItemId.size() > 0){
            listBillItems = [SELECT Id,Name,EndDate__c
                             FROM BillItem__c
                             WHERE ServiceItem__c IN :setServiceItemId 
                             AND EndDate__c <= :endDate ORDER BY EndDate__c DESC];
            
            system.debug('listBillItems**'+listBillItems);
            if(!listBillItems.isEmpty()){
                lastBillItemEndDate = listBillItems[0].EndDate__c;
                for(ServiceItem__c objSI : listServiceItems){
                    if(objSI.StartDate__c == lastBillItemEndDate){
                        objSI.Invalid__c = true;
                    }
                    if(lastBillItemEndDate > objSI.StartDate__c){
                        objSI.EndDate__c = lastBillItemEndDate;
                        objSI.Ended__c = true;
                    }
                    else{
                        //objSI.EndDate__c = lastBillItemEndDate;
                        //objSI.Ended__c = true;
                        objSI.Invalid__c = true;
                    }
                    serviceItemsToEndDate.add(objSI);
                    previousOccupantContractId = objSI.Service__r.BillingContract__c;
                }
            }
            else{
                for(ServiceItem__c serviceItem : listServiceItems){
                    if(serviceItem.ServiceItemType__r.Owner__c || serviceItem.ServiceItemType__r.Landlord__c){
                        if(serviceItem.StartDate__c == endDate){
                            serviceItem.Invalid__c = true;
                        }
                        serviceItem.EndDate__c = endDate;
                        serviceItem.Ended__c = true;
                        serviceItemsToEndDate.add(serviceItem);
                    }
                }
            }
        }
        system.debug('serviceItemsToEndDate**'+ serviceItemsToEndDate);
        // update the service items
        serviceItemsToEndDate = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(serviceItemsToEndDate, false);
        if (!serviceItemsToEndDate.isEmpty()) update serviceItemsToEndDate;
        mapPreviousOccContract2LastBillItemEndDate.put(previousOccupantContractId,lastBillItemEndDate);
        return mapPreviousOccContract2LastBillItemEndDate;
    }
    
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		24 Oct 2018
    @param			Id - location Id
    @param			Date - the end date for the service items
    @param			Boolean - true for a household account
    @description 	Ends all the active service items at a location 
    If all service items on a contract are ended it will also end the contract
    *******************************************************************************/
    public static Set<Id> endServiceItemNotRelatedToOwner(Id locationId, Date endDate) {
        
        // end date all the service items on the contract
        List<ServiceItem__c> serviceItemsToEndDate = new List<ServiceItem__c>();
        Set<Id> setLandlordServices = new Set<Id>();
        for (ServiceItem__c serviceItem : [SELECT Id, StartDate__c, EndDate__c, Invalid__c, Service__c,ServiceItemType__r.Tenant__c, Service__r.OccupancyType__c, Ended__c
                                           FROM ServiceItem__c 
                                           WHERE Service__r.Supplypoint__r.Location__c = :locationId 
                                           AND StartDate__c <=: endDate
                                           AND (EndDate__c = null OR EndDate__c >: endDate )]) {
                                               //End Tenant services
                                               if(serviceItem.ServiceItemType__r.Tenant__c && serviceItem.Service__r.OccupancyType__c == Label.CuAp_AUMoveInOccType){
                                                   if(serviceItem.StartDate__c == endDate){
                                                       serviceItem.Invalid__c = true;
                                                   }
                                                   serviceItem.EndDate__c = endDate;
                                                   serviceItem.Ended__c = true;
                                                   serviceItemsToEndDate.add(serviceItem);
                                               }
                                               else{
                                                   //These should ideally be landlord services
                                                   //serviceItem.Service__r.OccupancyType__c = 'Owner';
                                                   setLandlordServices.add(serviceItem.Service__c);
                                               }
                                           }
        // update the service items
        serviceItemsToEndDate = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(serviceItemsToEndDate, false);
        if (!serviceItemsToEndDate.isEmpty()) update serviceItemsToEndDate;
        if(setLandlordServices.size() > 0){
            List<Service__c> listService = new List<Service__c>();
            listService = [SELECT Id,Name,OccupancyType__c
                           FROM Service__c
                           WHERE Id IN :setLandlordServices];
            for(Service__c objService : listService){
                objService.OccupancyType__c = Label.CuAp_AUMoveInOccTypeOwner;
            }
            // update the service items
            if(!listService.isEmpty()){
                listService = (List<Service__c>) GlUt_FieldSecurity.cleanseFields(listService, false);
                if (!listService.isEmpty()) update listService;
            }
        }
        return setLandlordServices;
    }
    
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		24 Oct 2018
    @param			Id - location Id
    @param			Date - the end date for the service items
    @param			Boolean - true for a household account
    @description 	Ends all the active service items at a location 
    If all service items on a contract are ended it will also end the contract
    *******************************************************************************/
    public static void addServiceItemRelatedToOwner(Id locationId, Date endDate, Id serviceId) {
        // end date all the service items on the contract
        List<ServiceItem__c> serviceItemsToInsert = new List<ServiceItem__c>();
        
        for (ServiceItem__c serviceItem : [SELECT Id, StartDate__c, EndDate__c, AvailableServiceItem__c,  ServiceItemType__c, Invalid__c, Service__c, ServiceItemType__r.Owner__c, ServiceItemType__r.Tenant__c, Service__r.OccupancyType__c, Ended__c
                                           FROM ServiceItem__c 
                                           WHERE Service__r.Supplypoint__r.Location__c = :locationId 
                                           AND StartDate__c <: endDate
                                           AND (EndDate__c = null OR EndDate__c >= : endDate )]) {
                                               //Get Measured\Volumetric SI's
                                               if(serviceItem.ServiceItemType__r.Owner__c && serviceItem.ServiceItemType__r.Tenant__c && serviceId != null){
                                                   
                                                   ServiceItem__c ObjNewServiceItem = new ServiceItem__c();
                                                   ObjNewServiceItem.StartDate__c = endDate.addDays(1);
                                                   //ObjNewServiceItem.EndDate__c = serviceItem.EndDate__c;
                                                   ObjNewServiceItem.Service__c = serviceId;
                                                   ObjNewServiceItem.ServiceItemType__c = serviceItem.ServiceItemType__c;
                                                   ObjNewServiceItem.AvailableServiceItem__c = serviceItem.AvailableServiceItem__c;
                                                   serviceItemsToInsert.add(ObjNewServiceItem);
                                               }
                                           }
        // insert the service items
        serviceItemsToInsert = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(serviceItemsToInsert, false);
        if (!serviceItemsToInsert.isEmpty()) insert serviceItemsToInsert;
    }
}