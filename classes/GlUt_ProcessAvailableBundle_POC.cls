/***************************************************************************************************
@author        Echo : Dependra Singh
@date          29-Nov-2017
@description:  This is helper class used to process available bundle logic. 
@group         Utility
Revision(s)    12-Jan-2018 New Scenarios, Dependra , As per document shared by ANDY
Revision(s)    24-May-2018 T Gupta , AT-2671 , Removed Active check from Device as in single transaction the formula field was not calculated. Active SPD check seems enough.
@revisions	   Echo: Sudhir -> AT-1675 - AT-3072(Core 7b): Update Process Available Bundle Class
*******************************************************************************************************/
public with sharing class GlUt_ProcessAvailableBundle_POC {
    // Variable declaration
    private static final String CLASS_NAME = 'GlUt_ProcessAvailableBundle';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    // End variable declaration
    
 //Wrapper Class to manage the Available Bundle Data   
    public class GlUt_AvailableBundleDataWrapper {
      public  Map<Id,AvailableBundle__c> mapAvailableBundleById {get; set;}
      public  Map<Id,Id> mapAvailableServiceByAvailableBundle {get; set;}
      public  Map<Id,Id> mapSupplyPointByAvailableBundle {get; set;}
      Set<Id> bundlesIds {get; set;}
      public GlUt_AvailableBundleDataWrapper(){
          this.mapAvailableBundleById = new Map<Id,AvailableBundle__c>();
          this.mapAvailableServiceByAvailableBundle = new Map<Id,Id>();
          this.mapSupplyPointByAvailableBundle =new Map<Id,Id>();
          this.bundlesIds= new Set<Id>();
      }
    }
 // Wrapper is used to manage the Bundle and Bundle Item Data
    public class GlUt_BundleItemDataWrapper{
      public  Map<Id,List<BundleItem__c>> mapBundlesItemsByBundle {get; set;}
      Set<Id> serviceItemFamilyIds {get; set;}
      Set<Id> serviceItemTypeIds {get; set;}
      public GlUt_BundleItemDataWrapper(){
          this.mapBundlesItemsByBundle = new Map<Id,List<BundleItem__c>>();
          this.serviceItemFamilyIds= new Set<Id>();
          this.serviceItemTypeIds= new Set<Id>();
      }
    }
    
    /**********************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-July-2018
    @param         none
    @return        none
	@group		   Wrapper class
    @description   GlUt_ProcessAvailableBundleWrapper: AT-3072: Create Bundle Wrapper Class
    **********************************************************************************************/

    public class GlUt_ProcessAvailableBundleWrapper{
      	public AvailableBundle__c availableBundle {get; set;}			//The available bundle that needs to have the associated available service items re-evaluated
      	public Date effectiveDate {get; set;}							//The effective Date for the bundle reevaluation
      	public SupplyPointDevice__c supplyPointDevice {get; set;}		//If the reevaluation is a result of a change to a Supply Point Device record, it will be included as a parameter
      	public SupplyPointBand__c supplyPointBand {get; set;}			//If the reevaluation is a result of a change to a Supply Point Band record it will be included as a parameter
        public GlUt_ProcessAvailableBundleWrapper() {
            availableBundle = new AvailableBundle__c() ;
            effectiveDate = null ;
            supplyPointDevice = new SupplyPointDevice__c() ;
            supplyPointBand = new SupplyPointBand__c() ;
        }
    }
    
    /**********************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-July-2018
    @param         set<Id> SetAvailableBundleIds
    @return        map<Id, Id> mapAvailableBundleId2SupplyPointId
	@group		   method
    @description   getMapAvailableBundleId2SupplyPointId method: AT-3073: Returns Map of Available Bundle Id => Supply Point Id
    **********************************************************************************************/

    private static map<Id, Id> getMapAvailableBundleId2SupplyPointId(set<Id> SetAvailableBundleIds) {	// Map of Available Bundle Id => Supply Point Id
        map<Id, Id> mapAvailableBundleId2SupplyPointId = new map<Id, Id>() ;
        if(!SetAvailableBundleIds.isEmpty()) {
            for(AvailableBundle__c ab : [SELECT Id, AvailableService__r.SupplyPoint__c FROM AvailableBundle__c WHERE Id IN: SetAvailableBundleIds]) {
                mapAvailableBundleId2SupplyPointId.put(ab.Id, ab.AvailableService__r.SupplyPoint__c) ;
            } 
        }   
        system.debug(DEBUG + ' getMapAvailableBundleId2SupplyPointId-mapAvailableBundleId2SupplyPointId=> '+ mapAvailableBundleId2SupplyPointId);
        return mapAvailableBundleId2SupplyPointId ;
    }
    
    /**********************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-July-2018
    @param         set<Id> setSupplyPointIds
    @return        map<Id, list<SupplypointDevice__c>> mapSupplyPointId2ListSpd
	@group		   method
    @description   getMapSupplyPointId2ListSpd method: AT-3073: Returns Map of Supply Point Id => List of Spd
    **********************************************************************************************/

    private static map<Id, list<SupplypointDevice__c>> getMapSupplyPointId2ListSpd(set<Id> setSupplyPointIds) { // Map of Supply Point Id => List of Spd
        map<Id, list<SupplypointDevice__c>> mapSupplyPointId2ListSpd = new map<Id, list<SupplypointDevice__c>>() ;
        if(!setSupplyPointIds.isEmpty()) {
            for(SupplypointDevice__c spd : [SELECT Id, SupplyPoint__c, InstallationDate__c, RemovalDate__c FROM SupplypointDevice__c WHERE SupplyPoint__c IN: setSupplyPointIds]) {
                if(!mapSupplyPointId2ListSpd.containsKey(spd.SupplyPoint__c)) {
                    mapSupplyPointId2ListSpd.put(spd.SupplyPoint__c, new list<SupplypointDevice__c> {spd}) ;
                } else {
                    mapSupplyPointId2ListSpd.get(spd.SupplyPoint__c).add(spd) ;
                }
            } 
        }   
        system.debug(DEBUG + ' getMapSupplyPointId2ListSpd-mapSupplyPointId2ListSpd=> '+ mapSupplyPointId2ListSpd);
        return mapSupplyPointId2ListSpd ;
    }
    
    /**********************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-July-2018
    @param         set<Id> setSupplyPointIds
    @return        map<Id, list<SupplypointBand__c>> mapSupplyPointId2ListSpb
	@group		   method
    @description   getMapSupplyPointId2ListSpb method: AT-3073: Returns Map of Supply Point Id => List of Spb
    **********************************************************************************************/

    private static map<Id, list<SupplypointBand__c>> getMapSupplyPointId2ListSpb(set<Id> setSupplyPointIds) {   // Map of Supply Point Id => List of Spb
        map<Id, list<SupplypointBand__c>> mapSupplyPointId2ListSpb = new map<Id, list<SupplypointBand__c>>() ;
        if(!setSupplyPointIds.isEmpty()) {
            for(SupplypointBand__c spb : [SELECT Id, SupplyPoint__c, StartDate__c, EndDate__c FROM SupplypointBand__c WHERE SupplyPoint__c IN: setSupplyPointIds]) {
                if(!mapSupplyPointId2ListSpb.containsKey(spb.SupplyPoint__c)) {
                    mapSupplyPointId2ListSpb.put(spb.SupplyPoint__c, new list<SupplypointBand__c> {spb}) ;
                } else {
                    mapSupplyPointId2ListSpb.get(spb.SupplyPoint__c).add(spb) ;
                }
            } 
        }   
        system.debug(DEBUG + ' getMapSupplyPointId2ListSpb-mapSupplyPointId2ListSpb=> '+ mapSupplyPointId2ListSpb);
        return mapSupplyPointId2ListSpb ;
    }
    
    /**********************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-July-2018
    @param         list<SupplypointDevice__c> listSpd
    @return        map<Id, String> mapSpdId2DeviceSize
	@group		   method
    @description   getMapSpdId2DeviceSize method: AT-3073: Returns Map of Supply Point Device Id => DeviceSize
    **********************************************************************************************/
    
    private static map<Id, String> getMapSpdId2DeviceSize(list<SupplypointDevice__c> listSpd) {		// get Map of Supply Point Device Id => DeviceSize
        map<Id, String> mapSpdId2DeviceSize = new map<Id, String>() ;
        if(!listSpd.isEmpty()) {
            set<Id> setSpdIds = new set<Id>() ;
            for(SupplypointDevice__c spd : listSpd) {
                setSpdIds.add(spd.Id) ;
            }
            for(SupplypointDevice__c spd : [SELECT Id, Device__r.DeviceType__r.DeviceSize__c FROM SupplypointDevice__c WHERE Id IN: setSpdIds]) {
                mapSpdId2DeviceSize.put(spd.Id, spd.Device__r.DeviceType__r.DeviceSize__c) ;
            }
        }
        system.debug(DEBUG + ' getMapSpdId2DeviceSize-mapSpdId2DeviceSize=> '+ mapSpdId2DeviceSize);
        return mapSpdId2DeviceSize ;
    }
    
    /**********************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-July-2018
    @param         list<SupplypointBand__c> listSpb
    @return        map<Id, String> mapSpbId2BandType
	@group		   method
    @description   getMapSpbId2BandType method: AT-3073: Returns Map of Supply Point Band Id => BandType
    **********************************************************************************************/
    
    private static map<Id, String> getMapSpbId2BandType(list<SupplypointBand__c> listSpb) {		// get Map of Supply Point Band Id => BandType
        map<Id, String> mapSpbId2BandType = new map<Id, String>() ;
        if(!listSpb.isEmpty()) {
            set<Id> setSpbIds = new set<Id>() ;
            for(SupplypointBand__c spb : listSpb) {
                setSpbIds.add(spb.Id) ;
            }
            for(SupplypointBand__c spb : [SELECT Id, BandType__c FROM SupplypointBand__c WHERE Id IN: setSpbIds]) {
                mapSpbId2BandType.put(spb.Id, spb.BandType__c) ;
            }
        }
        system.debug(DEBUG + ' getMapSpbId2BandType-mapSpbId2BandType=> '+ mapSpbId2BandType);
        return mapSpbId2BandType ;
    }
    
    /**********************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-July-2018
    @param         set<Id> setAsiIds
    @return        map<Id, list<ServiceItem__c>> mapAsiId2ListServiceItemObj
	@group		   method
    @description   getMapAsiId2ListServiceItemObj method: AT-3073: Returns map of AvailableServiceItem Id => List of Service Item Obj
    **********************************************************************************************/
    
    private static map<Id, list<ServiceItem__c>> getMapAsiId2ListServiceItemObj(set<Id> setAsiIds) {	//returns map of AvailableServiceItem Id => List of Service Item Obj
        map<Id, list<ServiceItem__c>> mapAsiId2ListServiceItemObj = new map<Id, list<ServiceItem__c>>() ;
        for(ServiceItem__c si : [SELECT Id, StartDate__c, EndDate__c, AvailableServiceItem__c FROM ServiceItem__c WHERE AvailableServiceItem__c IN: setAsiIds]) {
            if(si.AvailableServiceItem__c != null) {
                if(!mapAsiId2ListServiceItemObj.containsKey(si.AvailableServiceItem__c)) {
                    mapAsiId2ListServiceItemObj.put(si.AvailableServiceItem__c, new list<ServiceItem__c> {si}) ;
                } else {
                    mapAsiId2ListServiceItemObj.get(si.AvailableServiceItem__c).add(si) ;
                }
            }
        }
        system.debug(DEBUG + ' getMapAsiId2ListServiceItemObj-mapAsiId2ListServiceItemObj=> '+ mapAsiId2ListServiceItemObj);
        return mapAsiId2ListServiceItemObj ;
    }
    
    //class-level variables 
    private static map<Id, Id> mapBundleItemId2ServiceItemFamilyId ;	// map Bundle Item Id => Service Item Family Id
    private static map<Id, Id> mapBundleItemId2ServiceItemTypeId ;		// map Bundle Item Id => Service Item Type Id
    private static map<Id, set<Id>> mapBundleId2SetBundleItemIds ;		// map Bundle Id => Set of Bundle Item Ids
    
    /**********************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-July-2018
    @param         set<Id> setBundleIds
    @return        map<Id, list<BundleItem__c>> mapBundleId2ListBundleItem
	@group		   method
    @description   getMapBundleId2ListBundleItem method: AT-3073: Returns Map of BundleId => List of BundleItem 
    **********************************************************************************************/
    
	private static map<Id, list<BundleItem__c>> getMapBundleId2ListBundleItem(set<Id> setBundleIds) {	//get Map of BundleId => List of BundleItem 
		map<Id, list<BundleItem__c>> mapBundleId2ListBundleItem ;
        if(!setBundleIds.isEmpty()) {
            
            mapBundleId2ListBundleItem = new map<Id, list<BundleItem__c>>() ;
            mapBundleItemId2ServiceItemFamilyId = new map<Id, Id>() ;
            mapBundleItemId2ServiceItemTypeId = new map<Id, Id>() ;
            mapBundleId2SetBundleItemIds = new map<Id, set<Id>>() ;
            mapABId2SetSITIds = new map<Id, set<Id>> () ;
            
            for(BundleItem__c bi : [SELECT Id, ServiceItemFamily__c, ServiceItemType__c, Bundle__c FROM BundleItem__c
                                    WHERE Bundle__c IN: setBundleIds]) {
            	if(!mapBundleId2ListBundleItem.containsKey(bi.Bundle__c))	{
                    mapBundleId2ListBundleItem.put(bi.Bundle__c, new list<BundleItem__c> {bi}) ;
                }  else {
                    mapBundleId2ListBundleItem.get(bi.Bundle__c).add(bi) ;
                }  
                // map Bundle Id => Set of Bundle Item Ids
                if(!mapBundleId2SetBundleItemIds.containsKey(bi.Bundle__c))	{
                    mapBundleId2SetBundleItemIds.put(bi.Bundle__c, new set<Id> {bi.Id}) ;
                }  else {
                    mapBundleId2SetBundleItemIds.get(bi.Bundle__c).add(bi.Id) ;
                } 
                // map of Bundle Ids => ServiceItemType Ids
               if(bi.ServiceItemType__c != null) {
                   if(!mapABId2SetSITIds.containsKey(bi.Bundle__c)) {
                         mapABId2SetSITIds.put(bi.Bundle__c, new set<Id> {bi.ServiceItemType__c}) ;
                  }  else {
                       mapABId2SetSITIds.get(bi.Bundle__c).add(bi.ServiceItemType__c) ;
                  } 
              }
                                         
                mapBundleItemId2ServiceItemFamilyId.put(bi.Id, bi.ServiceItemFamily__c) ;
                mapBundleItemId2ServiceItemTypeId.put(bi.Id, bi.ServiceItemType__c) ;                        
        	}
        }
        system.debug(DEBUG + ' getMapAvailableBundleId2ListAvailableServiceItem-mapABId2SetSITIds=> '+ mapABId2SetSITIds);
        system.debug(DEBUG + ' getMapBundleId2ListBundleItem-mapBundleId2SetBundleItemIds=> '+ mapBundleId2SetBundleItemIds);
        system.debug(DEBUG + ' getMapBundleId2ListBundleItem-mapBundleItemId2ServiceItemFamilyId=> '+ mapBundleItemId2ServiceItemFamilyId);
        system.debug(DEBUG + ' getMapBundleId2ListBundleItem-mapBundleItemId2ServiceItemTypeId=> '+ mapBundleItemId2ServiceItemTypeId);
        system.debug(DEBUG + ' getMapBundleId2ListBundleItem-mapBundleId2ListBundleItem=> '+ mapBundleId2ListBundleItem);
        return mapBundleId2ListBundleItem ;
	}
    
    /**********************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-July-2018
    @param         map<Id, Id> mapBundleItemId2ServiceItemFamilyId
    @return        map<Id, list<ServiceItemType__c>> mapServiceItemFamilyId2ListServiceItemType
	@group		   method
    @description   getMapServiceItemFamilyId2ListServiceItemType method: AT-3073: Returns Map of ServiceItemFamilyId => List of ServiceItemTypes
    **********************************************************************************************/
    static map<Id, set<Id>> mapSif2SetSitIds ;
    
    private static map<Id, list<ServiceItemType__c>> getMapServiceItemFamilyId2ListServiceItemType(map<Id, Id> mapBundleItemId2ServiceItemFamilyId) {	//get Map of ServiceItemFamilyId => List of ServiceItemTypes
        map<Id, list<ServiceItemType__c>> mapServiceItemFamilyId2ListServiceItemType = new map<Id, list<ServiceItemType__c>>() ;
        mapSif2SetSitIds = new map<Id, set<Id>>() ;
        if(!mapBundleItemId2ServiceItemFamilyId.isEmpty() && !mapBundleItemId2ServiceItemFamilyId.values().isEmpty()) {
            for(ServiceItemType__c sit : [SELECT Id, ServiceItemFamily__c, BandType__c, BandType__r.Name, DeviceSize__c, DeviceSize__r.Name FROM ServiceItemType__c
                                          WHERE ServiceItemFamily__c IN: mapBundleItemId2ServiceItemFamilyId.values()]) {
                if(!mapServiceItemFamilyId2ListServiceItemType.containsKey(sit.ServiceItemFamily__c)) {
                    mapServiceItemFamilyId2ListServiceItemType.put(sit.ServiceItemFamily__c, new list<ServiceItemType__c> {sit}) ;
                } else {
                    mapServiceItemFamilyId2ListServiceItemType.get(sit.ServiceItemFamily__c).add(sit) ;
                }
                if(!mapSif2SetSitIds.containsKey(sit.ServiceItemFamily__c)) {
                    mapSif2SetSitIds.put(sit.ServiceItemFamily__c, new set<Id> {sit.Id}) ;
                } else {
                    mapSif2SetSitIds.get(sit.ServiceItemFamily__c).add(sit.Id) ;
                }
            }
        }
        system.debug(DEBUG + ' getMapServiceItemFamilyId2ListServiceItemType-mapSif2SetSitIds=> '+ mapSif2SetSitIds);
        system.debug(DEBUG + ' getMapServiceItemFamilyId2ListServiceItemType-mapServiceItemFamilyId2ListServiceItemType=> '+ mapServiceItemFamilyId2ListServiceItemType);
    	return mapServiceItemFamilyId2ListServiceItemType ;
    }
    
    /**********************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-July-2018
    @param         set<Id> setAvailableBundleIds
    @return        map<Id, list<AvailableServiceItem__c>> mapAvailableBundleId2ListAvailableServiceItem
	@group		   method
    @description   getMapAvailableBundleId2ListAvailableServiceItem method: AT-3073: Returns map of Available Bundle Id => List of Available Service Item
    **********************************************************************************************/
	static map<Id, list<AvailableServiceItem__c>> mapServiceItemTypeId2ListAvailableSI ;    
    private static map<Id, list<AvailableServiceItem__c>> getMapAvailableBundleId2ListAvailableServiceItem(set<Id> setAvailableBundleIds) {	//map of Available Bundle Id => List of Available Service Item
        map<Id, list<AvailableServiceItem__c>> mapAvailableBundleId2ListAvailableServiceItem ;
        if(!setAvailableBundleIds.isEmpty()) {
            mapAvailableBundleId2ListAvailableServiceItem = new map<Id, list<AvailableServiceItem__c>>() ;
            
            mapServiceItemTypeId2ListAvailableSI = new map<Id, list<AvailableServiceItem__c>>() ;
            for(AvailableServiceItem__c asiObj : [SELECT Id, StartDate__c, BundleItem__c, EndDate__c, AvailableBundle__c, ServiceItemType__c FROM AvailableServiceItem__c 
                                                  WHERE AvailableBundle__c IN: setAvailableBundleIds]) {
                if(asiObj.AvailableBundle__c != null) {
                    if(!mapAvailableBundleId2ListAvailableServiceItem.containsKey(asiObj.AvailableBundle__c)) {
                        mapAvailableBundleId2ListAvailableServiceItem.put(asiObj.AvailableBundle__c, new list<AvailableServiceItem__c> {asiObj}) ;
                    } else {
                        mapAvailableBundleId2ListAvailableServiceItem.get(asiObj.AvailableBundle__c).add(asiObj) ;
                    }                                          
                }
                if(asiObj.ServiceItemType__c != null) {
                    if(!mapServiceItemTypeId2ListAvailableSI.containsKey(asiObj.ServiceItemType__c)) {
                        mapServiceItemTypeId2ListAvailableSI.put(asiObj.ServiceItemType__c, new list<AvailableServiceItem__c> {asiObj}) ;
                    }  else {
                        mapServiceItemTypeId2ListAvailableSI.get(asiObj.ServiceItemType__c).add(asiObj) ;
                    }   
                    
                }
            }
        }
        
        system.debug(DEBUG + ' getMapAvailableBundleId2ListAvailableServiceItem-mapServiceItemTypeId2ListAvailableSI=> '+ mapServiceItemTypeId2ListAvailableSI);
        system.debug(DEBUG + ' getMapAvailableBundleId2ListAvailableServiceItem-mapAvailableBundleId2ListAvailableServiceItem=> '+ mapAvailableBundleId2ListAvailableServiceItem);
        return mapAvailableBundleId2ListAvailableServiceItem ;
    }
    
    /**********************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-July-2018
    @param         set<Id> setAvailableServiceItemIds
    @return        map<Id, list<ServiceItem__c>> mapAvailableServiceItemId2ListServiceItem
	@group		   method
    @description   getMapAvailableServiceItemId2ListServiceItem method: AT-3073: Returns map of AvailableServiceItem Id => List of Service Items
    **********************************************************************************************/
    
    private static map<Id, list<ServiceItem__c>> getMapAvailableServiceItemId2ListServiceItem(set<Id> setAvailableServiceItemIds) {	//map of AvailableServiceItem Id => List of Service Items
        map<Id, list<ServiceItem__c>> mapAvailableServiceItemId2ListServiceItem ;
        if(!setAvailableServiceItemIds.isEmpty()) {
            mapServiceId2ListServiceItem = new map<Id, list<ServiceItem__c>>() ;	// map of Service Id => List of Service Items
            mapAvailableServiceItemId2ListServiceItem = new map<Id, list<ServiceItem__c>>() ;	
            for(ServiceItem__c si : [SELECT Id, StartDate__c, EndDate__c, Service__c, ServiceItemType__c, AvailableServiceItem__c FROM ServiceItem__c 
                                     WHERE AvailableServiceItem__c IN: setAvailableServiceItemIds]) {
                if(!mapAvailableServiceItemId2ListServiceItem.containsKey(si.AvailableServiceItem__c)) {
                    mapAvailableServiceItemId2ListServiceItem.put(si.AvailableServiceItem__c, new list<ServiceItem__c> {si}) ;
                } else {
                    mapAvailableServiceItemId2ListServiceItem.get(si.AvailableServiceItem__c).add(si) ;
                }
                if(!mapServiceId2ListServiceItem.containsKey(si.Service__c)) {
                    mapServiceId2ListServiceItem.put(si.Service__c, new list<ServiceItem__c> {si}) ;
                } else {
                    mapServiceId2ListServiceItem.get(si.Service__c).add(si) ;
                }
            }
        }
        system.debug(DEBUG + ' getMapAvailableServiceItemId2ListServiceItem-mapAvailableServiceItemId2ListServiceItem=> '+ mapAvailableServiceItemId2ListServiceItem);
        system.debug(DEBUG + ' getMapAvailableServiceItemId2ListServiceItem-mapServiceId2ListServiceItem=> '+ mapServiceId2ListServiceItem);
        return mapAvailableServiceItemId2ListServiceItem ;
    }
    
    private static map<Id, Id> getMapAvailableServiceId2ActiveServiceId(set<Id> setWrapperAvailableServiceIds) {
        map<Id, Id> mapAvailableServiceId2ActiveServiceId ;
        if(!setWrapperAvailableServiceIds.isEmpty()) {
            mapAvailableServiceId2ActiveServiceId = new map<Id, Id>() ;
            for(Service__c service : [SELECT Id, ServiceStartDate__c, ServiceEndDate__c,AvailableService__c FROM Service__c WHERE AvailableService__c IN:setWrapperAvailableServiceIds]) {
                if(service.ServiceStartDate__c != null && (service.ServiceEndDate__c == null || service.ServiceEndDate__c >= System.today())) {
                    mapAvailableServiceId2ActiveServiceId.put(service.AvailableService__c, service.Id) ;
                }
            }
        }
        
        return mapAvailableServiceId2ActiveServiceId ;
    }
    
    private static map<Id, list<ServiceItem__c>> getMapActiveServiceId2ListServiceItem(list<Id> listActiveServiceIds) {
        //map<Id, list<ServiceItem__c>> mapActiveServiceId2ListServiceItem ;
        if(!listActiveServiceIds.isEmpty()) {
            mapActiveServiceId2ListServiceItem = new map<Id, list<ServiceItem__c>>() ;
            for(ServiceItem__c sItem : [SELECT Id, Service__c, StartDate__c, EndDate__c, ServiceItemType__c FROM ServiceItem__c WHERE Service__c IN: listActiveServiceIds]) {
                if(!mapActiveServiceId2ListServiceItem.containsKey(sItem.Service__c)) {
                    mapActiveServiceId2ListServiceItem.put(sItem.Service__c, new list<ServiceItem__c> {sItem}) ;
                } else {
                    mapActiveServiceId2ListServiceItem.get(sItem.Service__c).add(sItem) ;
                }
            }
        }
        system.debug('mapActiveServiceId2ListServiceItem=> '+ mapActiveServiceId2ListServiceItem);
        return mapActiveServiceId2ListServiceItem ;
    }
    
    //class-level variables 
    private static map<Id, Id> mapWrapperAbId2SupplyPointDeviceId ;					// map of Wrapper Available Bundle Id => Supply Point Device Id
    private static map<Id, Id> mapWrapperAbId2SupplyPointBandId ;					// map of Wrapper Available Bundle Id => Supply Point Band Id
    private static map<Id, list<ServiceItem__c>> mapServiceId2ListServiceItem ;		// map of Service Id => List of Service Items
    static map<Id, Id> mapAvailableServiceId2ActiveServiceId ;
    static map<Id, list<ServiceItem__c>> mapActiveServiceId2ListServiceItem ;
    static map<Id, set<Id>> mapABId2SetSITIds ;
    
    /**********************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          24-July-2018
    @param         map<Id, GlUt_ProcessAvailableBundleWrapper> mapAvailableBundleId2Wrapper
    @return        void
	@group		   method
    @description   processAvailableBundleChange method: AT-3073: used to process map of AvailableBundleId=>GlUt_ProcessAvailableBundleWrapper instance
    **********************************************************************************************/
    
    public static void processAvailableBundleChange(map<Id, GlUt_ProcessAvailableBundleWrapper> mapAvailableBundleId2Wrapper) {
        system.debug('processAvailableBundleChange-mapAvailableBundleId2Wrapper=> ' + mapAvailableBundleId2Wrapper);
        //STEP 1: Retrive all the data sets/maps which will be referenced in below code - this is to prevent SOQL inside for loop
        
        map<Id, Id> mapAvailableBundleId2SupplyPointId ;					//map of AvailableBundle Id => SupplyPoint Id
        map<Id, list<SupplypointDevice__c>> mapSupplyPointId2ListSpd ;		//map of SupplyPoint Id => list of Supply Point Devices
        map<Id, list<SupplypointBand__c>> mapSupplyPointId2ListSpb ;		//map of SupplyPoint Id => list of Supply Point Bands
        map<Id, String> mapSpdId2DeviceSize ;								//map of SupplyPointDevice Id => Device Size
        map<Id, String> mapSpbId2BandType ;									//map of SupplyPointBand Id => Band Type
		map<Id, list<AvailableServiceItem__c>> mapSpdId2ListAsiObj ;		//map of SupplyPointDevice Id => List of AvailableServiceItem Obj
        map<Id, list<AvailableServiceItem__c>> mapSpbId2ListAsiObj ;		//map of SupplyPointBand Id => List of AvailableServiceItem Obj
        map<Id, list<ServiceItem__c>> mapAsiId2ListServiceItemObj ;			//map of AvailableServiceItem   Id => List of ServiceItem Obj
        map<Id, list<BundleItem__c>> mapBundleId2ListBundleItem ; 			// map of BundleId => List of BundleItem
        map<Id, list<ServiceItemType__c>> mapServiceItemFamilyId2ListServiceItemType ;			//map of ServiceItemFamily Id => List of ServiceItemType
        map<Id, list<AvailableServiceItem__c>> mapAvailableBundleId2ListAvailableServiceItem ;  //map of Available Bundle Id => List of Available Service Item
        map<Id, list<ServiceItem__c>> mapAvailableServiceItemId2ListServiceItem ; 				//map of AvailableServiceItemId => List of Service Items
        map<Id, set<Id>> mapAbId2SetRelatedSIT ;	// map Available Bundle Id => Set of related Service Item Types
        //Initialization of method-level variables
        map<Id, Id> mapAvailableBundleId2BundleId = new map<Id, Id>() ;	// map of AvailableBundle Id => associated Bundle Id
        mapAbId2SetRelatedSIT = new map<Id, set<Id>> () ;
        
        //Initialization of class-level variables
        mapWrapperAbId2SupplyPointDeviceId = new map<Id, Id>() ;		// map of wrapper Abailable Bundle Id => Supply Point Device Id
        mapWrapperAbId2SupplyPointBandId = new map<Id, Id>() ;			// map of wrapper Abailable Bundle Id => Supply Point Band Id
        
        //map of AvailableBundle Id => SupplyPoint Id
        if(!mapAvailableBundleId2Wrapper.isEmpty()) {
            mapAvailableBundleId2SupplyPointId = getMapAvailableBundleId2SupplyPointId(mapAvailableBundleId2Wrapper.keySet()) ;
            //map of Available Bundle Id => List of Available Service Items
            mapAvailableBundleId2ListAvailableServiceItem = getMapAvailableBundleId2ListAvailableServiceItem(mapAvailableBundleId2Wrapper.keySet()) ;
            //map of Available Service Item Id => List of Service Items
            if(mapAvailableBundleId2ListAvailableServiceItem != null && !mapAvailableBundleId2ListAvailableServiceItem.values().isEmpty()) {
                set<Id> setAvailableServiceItemIds = new set<Id>() ;
                for(list<AvailableServiceItem__c> listASI : mapAvailableBundleId2ListAvailableServiceItem.values()) {
                    for(AvailableServiceItem__c asi : listASI) {
                        setAvailableServiceItemIds.add(asi.Id) ;
                    }
                }
                //map of AvailableServiceItemId => List of Service Items
                mapAvailableServiceItemId2ListServiceItem = getMapAvailableServiceItemId2ListServiceItem(setAvailableServiceItemIds) ;
                system.debug(DEBUG + ' processAvailableBundleChange-mapAvailableServiceItemId2ListServiceItem=> '+ mapAvailableServiceItemId2ListServiceItem);
            }
            
        }
        //map of SupplyPoint Id => list of Supply Point Devices
        if(mapAvailableBundleId2SupplyPointId != null && !mapAvailableBundleId2SupplyPointId.isEmpty() && !mapAvailableBundleId2SupplyPointId.values().isEmpty()) {
            set<Id> setSupplyPointIdIds = new set<Id>() ;
            for(Id supplyPointIdId : mapAvailableBundleId2SupplyPointId.values()) {
                setSupplyPointIdIds.add(supplyPointIdId) ;
            }
            mapSupplyPointId2ListSpd = getMapSupplyPointId2ListSpd(setSupplyPointIdIds) ;	 //map of SupplyPoint Id => list of Supply Point Devices
            mapSupplyPointId2ListSpb = getMapSupplyPointId2ListSpb(setSupplyPointIdIds) ;	 //map of SupplyPoint Id => list of Supply Point Bands
            system.debug(DEBUG + ' processAvailableBundleChange-mapSupplyPointId2ListSpd=> '+ mapSupplyPointId2ListSpd);
            system.debug(DEBUG + ' processAvailableBundleChange-mapSupplyPointId2ListSpb=> '+ mapSupplyPointId2ListSpb);
        }
        //map of SupplyPoint Id => list of Supply Point Bands
        /*
        if(mapAvailableBundleId2SupplyPointId != null && !mapAvailableBundleId2SupplyPointId.isEmpty() && !mapAvailableBundleId2SupplyPointId.values().isEmpty()) {
            set<Id> setSupplyPointIdIds = new set<Id>() ;
            for(Id supplyPointIdId : mapAvailableBundleId2SupplyPointId.values()) {
                setSupplyPointIdIds.add(supplyPointIdId) ;
            }
            mapSupplyPointId2ListSpb = getMapSupplyPointId2ListSpb(mapAvailableBundleId2Wrapper.keySet()) ;
        }
		*/
        //map of SupplyPointDevice Id => Device Size
        if(mapSupplyPointId2ListSpd != null && !mapSupplyPointId2ListSpd.isEmpty() && !mapSupplyPointId2ListSpd.values().isEmpty()) {
            list<SupplyPointDevice__c> listSpd = new list<SupplyPointDevice__c>() ;
            for(list<SupplyPointDevice__c> spdList : mapSupplyPointId2ListSpd.values()) {
                for(SupplyPointDevice__c spd : spdList) {
                    listSpd.add(spd) ;
                }
            }
            mapSpdId2DeviceSize = getMapSpdId2DeviceSize(listSpd) ;
            system.debug(DEBUG + ' processAvailableBundleChange-mapSpdId2DeviceSize=> '+ mapSpdId2DeviceSize);
        }
        //map of SupplyPointBand Id => Band Type
        if(mapSupplyPointId2ListSpb != null && !mapSupplyPointId2ListSpb.isEmpty() && !mapSupplyPointId2ListSpb.values().isEmpty()) {
            list<SupplyPointBand__c> listSpb = new list<SupplyPointBand__c>() ;
            for(list<SupplyPointBand__c> spbList : mapSupplyPointId2ListSpb.values()) {
                for(SupplyPointBand__c spb : spbList) {
                    listSpb.add(spb) ;
                }
            }
            mapSpbId2BandType = getMapSpbId2BandType(listSpb) ;
            system.debug(DEBUG + ' processAvailableBundleChange-mapSpbId2BandType=> '+ mapSpbId2BandType);
        }
        
        
        
        //map variables/placeholders to be referenced below
        map<Id, SupplyPointDevice__c> mapAvailableBundleId2SpdObj = new map<Id, SupplyPointDevice__c>() ;
        map<Id, SupplyPointBand__c> mapAvailableBundleId2SpbObj = new map<Id, SupplyPointBand__c>() ;
        set<Id> setWrapperAvailableServiceIds = new set<Id>() ;
        
        //For each of the entries in the mapAvailableBundleId2Wrapper - 
        for(String availableBundleId : mapAvailableBundleId2Wrapper.keySet()) {
            //Retrieve the bundle associated to the Available Bundle 
            mapAvailableBundleId2BundleId.put(availableBundleId, mapAvailableBundleId2Wrapper.get(availableBundleId).availableBundle.Bundle__c) ;
            if(mapAvailableBundleId2Wrapper.get(availableBundleId) != null && mapAvailableBundleId2Wrapper.get(availableBundleId).SupplyPointDevice != null) {
                //Get map of Wrapper Available Bundle Id => SupplyPointDevice Id
                mapWrapperAbId2SupplyPointDeviceId.put(availableBundleId, mapAvailableBundleId2Wrapper.get(availableBundleId).SupplyPointDevice.Id) ;
            }
            system.debug(DEBUG + ' processAvailableBundleChange-mapWrapperAbId2SupplyPointDeviceId=> '+ mapWrapperAbId2SupplyPointDeviceId); 
            if(mapAvailableBundleId2Wrapper.get(availableBundleId) != null && mapAvailableBundleId2Wrapper.get(availableBundleId).SupplyPointBand != null) {
                //Get map of Wrapper Available Bundle Id => SupplyPointBand Id
                mapWrapperAbId2SupplyPointBandId.put(availableBundleId, mapAvailableBundleId2Wrapper.get(availableBundleId).SupplyPointBand.Id) ;
            }
            system.debug(DEBUG + ' processAvailableBundleChange-mapWrapperAbId2SupplyPointBandId=> '+ mapWrapperAbId2SupplyPointBandId); 
            if(mapAvailableBundleId2Wrapper.get(availableBundleId).availableBundle.AvailableService__c != null) {
                setWrapperAvailableServiceIds.add(mapAvailableBundleId2Wrapper.get(availableBundleId).availableBundle.AvailableService__c) ;
            }
            system.debug(DEBUG + ' processAvailableBundleChange-setWrapperAvailableServiceIds=> '+ setWrapperAvailableServiceIds); 
        }
        if(!setWrapperAvailableServiceIds.isEmpty()) {
            mapAvailableServiceId2ActiveServiceId = new map<Id, Id>() ;
            mapAvailableServiceId2ActiveServiceId = getMapAvailableServiceId2ActiveServiceId(setWrapperAvailableServiceIds) ;
            system.debug(DEBUG + ' processAvailableBundleChange-mapAvailableServiceId2ActiveServiceId=> '+ mapAvailableServiceId2ActiveServiceId); 
            if(!mapAvailableServiceId2ActiveServiceId.values().isEmpty()) {
                //mapActiveServiceId2ListServiceItem = new map<Id, list<ServiceItem__c>>() ;
                
                mapActiveServiceId2ListServiceItem = getMapActiveServiceId2ListServiceItem(mapAvailableServiceId2ActiveServiceId.values()) ;	//
            }
            system.debug(DEBUG + ' processAvailableBundleChange-mapActiveServiceId2ListServiceItem=> '+ mapActiveServiceId2ListServiceItem); 
        }
        //map of Available Bundle Id => List of Bundle Ids
        if(!mapAvailableBundleId2BundleId.values().isEmpty()) {
            set<Id> setBundleIds = new set<Id>() ;
            setBundleIds.addAll(mapAvailableBundleId2BundleId.values()) ;
            mapBundleId2ListBundleItem = getMapBundleId2ListBundleItem(setBundleIds) ;
            system.debug(DEBUG + ' processAvailableBundleChange-mapBundleId2ListBundleItem=> '+ mapBundleId2ListBundleItem); 
        }
        //map of Service Item Family Id => List of Service Item Type
        if(mapBundleItemId2ServiceItemFamilyId != null && !mapBundleItemId2ServiceItemFamilyId.values().isEmpty()) {
            mapServiceItemFamilyId2ListServiceItemType = getMapServiceItemFamilyId2ListServiceItemType(mapBundleItemId2ServiceItemFamilyId) ;
            system.debug(DEBUG + ' processAvailableBundleChange-mapServiceItemFamilyId2ListServiceItemType=> '+ mapServiceItemFamilyId2ListServiceItemType); 
        }
        
        
        //map of Supply Point Device Id => List of Available Service Item Obj
        if(!mapAvailableBundleId2Wrapper.isEmpty() && !mapWrapperAbId2SupplyPointDeviceId.values().isEmpty()) {
            mapSpdId2ListAsiObj = new map<Id, list<AvailableServiceItem__c>>() ;
            //Find the Available Service Item linked to the Available Bundle and Supply Point Device -> Can there be 1:m(Supply Point Device:Available Service Item) records	??
            for(AvailableServiceItem__c asiObj : [SELECT Id, StartDate__c, EndDate__c, SupplyPointDevice__c FROM AvailableServiceItem__c 
                                                  WHERE AvailableBundle__c IN: mapAvailableBundleId2Wrapper.keySet()  
                                                  AND SupplyPointDevice__c IN: mapWrapperAbId2SupplyPointDeviceId.values()]) {
                 if(asiObj.SupplyPointDevice__c != null) {
                       if(!mapSpdId2ListAsiObj.containsKey(asiObj.SupplyPointDevice__c))	{
                           mapSpdId2ListAsiObj.put(asiObj.SupplyPointDevice__c, new list<AvailableServiceItem__c> {asiObj}) ;
                       }	else {
                           mapSpdId2ListAsiObj.get(asiObj.SupplyPointDevice__c).add(asiObj) ;
                       }                                   
                 }
        	}
            system.debug(DEBUG + ' processAvailableBundleChange-mapSpdId2ListAsiObj=> '+ mapSpdId2ListAsiObj); 
        }
        
        //map of Available Service Item Id => List of Service Item Obj
        if(mapSpdId2ListAsiObj != null && !mapSpdId2ListAsiObj.values().isEmpty()) {
            set<Id> setAvailableServiceItemIds = new set<Id>() ;
            for(list<AvailableServiceItem__c> asiList : mapSpdId2ListAsiObj.values()) {
                for(AvailableServiceItem__c asi : asiList) {
                    setAvailableServiceItemIds.add(asi.Id) ;
                }
            }
            if(!setAvailableServiceItemIds.isEmpty()) {
                mapAsiId2ListServiceItemObj = getMapAsiId2ListServiceItemObj(setAvailableServiceItemIds) ;
                system.debug(DEBUG + ' processAvailableBundleChange-mapAsiId2ListServiceItemObj=> '+ mapAsiId2ListServiceItemObj); 
            }
        }
        
        //map of SupplyPointBand Id => List of AvailableServiceItem Obj
        if(!mapAvailableBundleId2Wrapper.isEmpty() && !mapWrapperAbId2SupplyPointBandId.values().isEmpty()) {
            mapSpbId2ListAsiObj = new map<Id, list<AvailableServiceItem__c>>() ;
            //Find the Available Service Item linked to the Available Bundle and Supply Point Device -> Can there be 1:m(SPD:ASI) records	??
            for(AvailableServiceItem__c asiObj : [SELECT Id, StartDate__c, EndDate__c, SupplyPointBand__c FROM AvailableServiceItem__c 
                                                  WHERE AvailableBundle__c IN: mapAvailableBundleId2Wrapper.keySet()  
                                                  AND SupplyPointBand__c IN: mapWrapperAbId2SupplyPointBandId.values()]) {
                 if(asiObj.SupplyPointBand__c != null) {
                     if(!mapSpbId2ListAsiObj.containsKey(asiObj.SupplyPointBand__c))	{
                         mapSpbId2ListAsiObj.put(asiObj.SupplyPointBand__c, new list<AvailableServiceItem__c> {asiObj}) ;
                     }	else {
                         mapSpbId2ListAsiObj.get(asiObj.SupplyPointBand__c).add(asiObj) ;
                     }                                 
                 }
                 
        	}
            system.debug(DEBUG + ' processAvailableBundleChange-mapSpbId2ListAsiObj=> '+ mapSpbId2ListAsiObj); 
        }
        //map of objects to insert or update
        map<Id, AvailableServiceItem__c> mapUpdatedAvailableServiceItem = new map<Id, AvailableServiceItem__c>() ;
        map<Id, ServiceItem__c> mapUpdatedServiceItem = new map<Id, ServiceItem__c>() ;
        list<AvailableServiceItem__c> listNewAvailableServiceItem = new list<AvailableServiceItem__c>() ;
        list<ServiceItem__c> listNewServiceItem = new list<ServiceItem__c>() ;
            
        //STEP 2: Iterate for each of the entries in the mapAvailableBundleId2Wrapper
        
        for(String availableBundleId : mapAvailableBundleId2Wrapper.keySet()) {
            
            GlUt_ProcessAvailableBundleWrapper abWrapper = mapAvailableBundleId2Wrapper.get(availableBundleId) ;
            //Set the effectiveDate to the Effective Date in the associated wrapper class
            Date effectiveDate = abWrapper.effectiveDate ;
            system.debug('Wrapper effectiveDate=> ' + effectiveDate) ;
            
            if(abWrapper != null) {
                
                //*Sub-Step: #1*-> Check if the associated Wrapper Class includes a Supply Point Device
                
                String deviceSize = '' ;
                system.debug('abWrapper.supplyPointDevice=> ' + abWrapper.supplyPointDevice);
                if(abWrapper.supplyPointDevice.Id != null) {	//if the associated Wrapper Class includes a Supply Point Device
                    //1.1-> Retrieve the Device Size associated with the Supply Point Device via the Device and Device Type
                    String spdId = abWrapper.supplyPointDevice.Id ;
                    deviceSize = mapSpdId2DeviceSize != null && mapSpdId2DeviceSize.containsKey(spdId) ? mapSpdId2DeviceSize.get(spdId) : null ;
                    mapAvailableBundleId2SpdObj.put(availableBundleId, abWrapper.supplyPointDevice) ;		//Supply Point Device is found
                } else {	//if the associated Wrapper Class does NOT include a Supply Point Device
                    //1.2-> Retrieve the Device Size associated to the Supply Point for this bundle
                    system.debug(DEBUG + ' processAvailableBundleChange-mapAvailableBundleId2SupplyPointId=> '+ mapAvailableBundleId2SupplyPointId) ;
                    if(mapAvailableBundleId2SupplyPointId != null && !mapAvailableBundleId2SupplyPointId.isEmpty() && mapAvailableBundleId2SupplyPointId.containsKey(availableBundleId)) {
                        String supplyPointId = mapAvailableBundleId2SupplyPointId.get(availableBundleId) ;
                        if(!String.isBlank(supplyPointId)) {
                            system.debug(DEBUG + ' processAvailableBundleChange-mapSupplyPointId2ListSpd=> '+ mapSupplyPointId2ListSpd) ;
                            if(mapSupplyPointId2ListSpd != null && !mapSupplyPointId2ListSpd.isEmpty() && mapSupplyPointId2ListSpd.containsKey(supplyPointId)) {
                                list<SupplyPointDevice__c> listSupplyPointDevice = mapSupplyPointId2ListSpd.get(supplyPointId) ;
                                system.debug(DEBUG + ' processAvailableBundleChange-listSupplyPointDevice=> '+ listSupplyPointDevice) ;
                                if(listSupplyPointDevice != null) {
                                    for(SupplyPointDevice__c spd : listSupplyPointDevice) {
                                        system.debug(DEBUG + ' processAvailableBundleChange-effectiveDate=> '+ effectiveDate) ;
                                        system.debug(DEBUG + ' processAvailableBundleChange-spd=> '+ spd) ;
                                        //look for Supply Point Device associated where StartDate <= effectiveDate and EndDate > effectiveDate
                                        if(spd.InstallationDate__c <= effectiveDate && (spd.RemovalDate__c == null || spd.RemovalDate__c > effectiveDate)) {
                                            //Get Supply Point Device -> Device -> Device Type -> Device Size
                                            mapAvailableBundleId2SpdObj.put(availableBundleId, spd) ;		//Supply Point Device is found	//can this be 1:m
                                            //Retrieve the Device Size associated with the Supply Point Device via the Device and Device Type
                                            deviceSize = mapSpdId2DeviceSize != null && mapSpdId2DeviceSize.containsKey(spd.Id) ? mapSpdId2DeviceSize.get(spd.Id) : null ;
                                        	system.debug(DEBUG + ' processAvailableBundleChange-deviceSize=> '+ deviceSize);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    system.debug(DEBUG + ' processAvailableBundleChange-deviceSize=> '+ deviceSize);
                }
                
                //*Sub-Step: #2*-> If the Wrapper Supply Point Device is populated
                
                system.debug(DEBUG + ' processAvailableBundleChange-mapAvailableBundleId2SpdObj=> '+ mapAvailableBundleId2SpdObj);
                if(abWrapper.supplyPointDevice.Id != null) {  
                    system.debug(DEBUG + ' processAvailableBundleChange-mapSpdId2ListAsiObj=> '+ mapSpdId2ListAsiObj) ;
                    //if(mapSpdId2ListAsiObj != null && !mapSpdId2ListAsiObj.isEmpty() && mapSpdId2ListAsiObj.containsKey(abWrapper.supplyPointDevice.Id)) {
                        //Find the Available Service Item linked to the Available Bundle and Supply Point Device
                        list<AvailableServiceItem__c> asiList = mapSpdId2ListAsiObj.get(abWrapper.supplyPointDevice.Id) != null ? mapSpdId2ListAsiObj.get(abWrapper.supplyPointDevice.Id) : null ;
                        system.debug(DEBUG + ' processAvailableBundleChange-asiList=> '+ asiList) ;
                        //If an Available Service Item is found
                        if(asiList != null && !asiList.isEmpty()) {  //Old SPD - Since there are ASIs available for them
                            //Update the Available Service Item Start/End Date to match the Supply Point Device Start/End Date
                            for(AvailableServiceItem__c asiObj : asiList) {
                                asiObj.StartDate__c = abWrapper.supplyPointDevice.InstallationDate__c ;
                                asiObj.EndDate__c = abWrapper.supplyPointDevice.RemovalDate__c ;
                                //store into a list for update -> To Do**
                                mapUpdatedAvailableServiceItem.put(asiObj.Id, asiObj) ;		// used map so as to maintain uniqueness
                                system.debug(DEBUG + 'mapUpdatedAvailableServiceItem=> ' + mapUpdatedAvailableServiceItem.values());
                                //After updating the Available Service Item query for any Service Items where the Start Date < Available Service Item Start date 
                                //OR End Date > Available Service Item End Date OR End Date = Null
                                system.debug(DEBUG + ' processAvailableBundleChange-mapAsiId2ListServiceItemObj=> '+ mapAsiId2ListServiceItemObj) ;
                                if(mapAsiId2ListServiceItemObj != null && !mapAsiId2ListServiceItemObj.isEmpty()) {
                                    if(mapAsiId2ListServiceItemObj.containsKey(asiObj.Id)) {
                                        list<ServiceItem__c> listSI = mapAsiId2ListServiceItemObj.get(asiObj.Id) ;
                                        system.debug(DEBUG + ' processAvailableBundleChange-listSI=> '+ listSI) ;
                                        if(listSI != null && !listSI.isEmpty()) {
                                            for(ServiceItem__c sItem : listSI) {
                                                //query for any Service Items where the Start Date < Available Service Item Start date 
                                                //OR End Date > Available Service Item End Date OR End Date = Null
                                                if(sItem.StartDate__c < asiObj.StartDate__c) {
                                                    //Update the Service Item dates 
                                                    sItem.StartDate__c = asiObj.StartDate__c ;
                                                }
                                                if(sItem.EndDate__c > asiObj.EndDate__c || sItem.EndDate__c == null) {
                                                    sItem.EndDate__c = asiObj.EndDate__c ;
                                                }
                                                //store into a list for update -> To Do**
                                                mapUpdatedServiceItem.put(sItem.Id, sItem) ;
                                                system.debug(DEBUG + 'mapUpdatedServiceItem=> ' + mapUpdatedServiceItem.values());
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        //New SPD - Since there are NO ASIs available for them
                        else if (mapBundleId2ListBundleItem != null && mapBundleId2ListBundleItem.containsKey(abWrapper.AvailableBundle.Bundle__c)) {
                            system.debug(DEBUG + ' mapBundleId2ListBundleItem=> '+ mapBundleId2ListBundleItem);
                            list<BundleItem__c> listBI = mapBundleId2ListBundleItem.get(abWrapper.AvailableBundle.Bundle__c) ;
                            system.debug(DEBUG + ' listBI=> '+ listBI);
                            if(listBI != null && !listBI.isEmpty()) {
                                for(BundleItem__c bi : listBI) {
                                    if(bi.ServiceItemType__c != null) {
                                        AvailableServiceItem__c asiObj = new AvailableServiceItem__c() ;
                                        asiObj.ServiceItemType__c = bi.ServiceItemType__c ;
                                        asiObj.AvailableBundle__c = availableBundleId ;
                                        asiObj.StartDate__c = effectiveDate ;
                                        asiObj.BundleItem__c = bi.Id ;
                                        asiObj.SupplyPointDevice__c = abWrapper.supplyPointDevice.Id ;
                                        //store AvailableServiceItem in a list to insert later
                                        listNewAvailableServiceItem.add(asiObj) ;
                                    
                                    
                                    system.debug(DEBUG + '5->listNewAvailableServiceItem=> ' + listNewAvailableServiceItem);
                                    String asiKey = bi.ServiceItemType__c + '-' + availableBundleId ;
                                    system.debug(DEBUG + ' mapAvailableServiceId2ActiveServiceId=> '+ mapAvailableServiceId2ActiveServiceId);
                                    if(mapAvailableServiceId2ActiveServiceId.containsKey(abWrapper.availableBundle.AvailableService__c)) {
                                        String serviceId = mapAvailableServiceId2ActiveServiceId.get(abWrapper.availableBundle.AvailableService__c) ;
                                        system.debug(DEBUG + '5->serviceId=> ' + serviceId);
                                        if(String.isNotBlank(serviceId)) {
                                            if(mapActiveServiceId2ListServiceItem.containsKey(serviceId)) {
                                                system.debug(DEBUG + '5->mapActiveServiceId2ListServiceItem=> ' + mapActiveServiceId2ListServiceItem);
                                                list<ServiceItem__c> listServiceItem = mapActiveServiceId2ListServiceItem.get(serviceId) ;
                                                system.debug(DEBUG + '5->listServiceItem=> ' + listServiceItem);
                                                if(listServiceItem != null && !listServiceItem.isEmpty()) {
                                                    //String AvailableServiceItem, String AvailableServiceId, String ServiceItemType, Date effectiveDate, list<ServiceItem__c> listServiceItem
                                                    createServiceItem(asiKey, serviceId, bi.ServiceItemType__c, effectiveDate, listServiceItem, listNewServiceItem) ;
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                                }
                            }
                        }
                    //}
                }
                
                //*Sub-Step: #3*-> Check if the associated Wrapper Class includes a Supply Point Band
                
                String bandType = '' ;
                system.debug('abWrapper.supplyPointBand=> ' + abWrapper.supplyPointBand);
                system.debug('mapSpbId2BandType=> ' + mapSpbId2BandType);
                if(abWrapper.supplyPointBand.Id != null) {	//if the associated Wrapper Class includes a Supply Point Band
                    //3.1-> Retrieve the Band Type associated with the Supply Point Band
                    String spbId = abWrapper.supplyPointBand.Id ;
                    bandType = mapSpdId2DeviceSize != null && mapSpbId2BandType.containsKey(spbId) ? mapSpbId2BandType.get(spbId) : null ;
                    mapAvailableBundleId2SpbObj.put(availableBundleId, abWrapper.supplyPointBand) ;		//Supply Point Band is found
                } else {	//if the associated Wrapper Class does NOT include a Supply Point Band
                    //3.2-> Retrieve the band type associated to the Supply Point for this bundle
                    if(mapAvailableBundleId2SupplyPointId != null && !mapAvailableBundleId2SupplyPointId.isEmpty() && mapAvailableBundleId2SupplyPointId.containsKey(availableBundleId)) {
                        String supplyPointId = mapAvailableBundleId2SupplyPointId.get(availableBundleId) ;
                        if(!String.isBlank(supplyPointId)) {
                            if(mapSupplyPointId2ListSpb != null && !mapSupplyPointId2ListSpb.isEmpty() && mapSupplyPointId2ListSpb.containsKey(supplyPointId)) {
                                list<SupplyPointBand__c> listSupplyPointBand = mapSupplyPointId2ListSpb.get(supplyPointId) ;
                                system.debug(DEBUG + ' processAvailableBundleChange-listSupplyPointBand=> '+ listSupplyPointBand) ;
                                if(listSupplyPointBand != null) {
                                    for(SupplyPointBand__c spb : listSupplyPointBand) {
                                        //look for Supply Point Band associated where StartDate <= effectiveDate and EndDate > effectiveDate
                                        if(spb.StartDate__c <= effectiveDate && (spb.EndDate__c == null || spb.EndDate__c > effectiveDate)) {
                                            //Get Supply Point Band -> Band Type -> Name
                                            mapAvailableBundleId2SpbObj.put(availableBundleId, spb) ;		//Supply Point Band is found
                                            //Retrieve the band type associated to the Supply Point for this bundle
                                            bandType = mapSpbId2BandType != null && mapSpbId2BandType.containsKey(spb.Id) ? mapSpbId2BandType.get(spb.Id) : null ;
                                            system.debug(DEBUG + ' processAvailableBundleChange-bandType=> '+ bandType);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    system.debug(DEBUG + ' processAvailableBundleChange-bandType=> '+ bandType);
                }
                
                //*Sub-Step: #4*-> If the Wrapper Supply Point Band is populated
                
                system.debug(DEBUG + ' processAvailableBundleChange-mapAvailableBundleId2SpbObj=> '+ mapAvailableBundleId2SpbObj);
                system.debug(DEBUG + ' abWrapper.supplyPointBand.Id=> '+ abWrapper.supplyPointBand.Id);
                system.debug(DEBUG + ' mapSpbId2ListAsiObj=> '+ mapSpbId2ListAsiObj);
                
                
                if(abWrapper.supplyPointBand.Id != null) {  
                    //if(mapSpbId2ListAsiObj != null && !mapSpbId2ListAsiObj.isEmpty() && mapSpbId2ListAsiObj.containsKey(abWrapper.supplyPointBand.Id)) {
                        system.debug(DEBUG + ' processAvailableBundleChange-mapSpbId2ListAsiObj=> '+ mapSpbId2ListAsiObj);
                        //Find the Available Service Item linked to the Available Bundle and Supply Point Device
                        list<AvailableServiceItem__c> asiList = mapSpbId2ListAsiObj.get(abWrapper.supplyPointBand.Id) != null ? mapSpbId2ListAsiObj.get(abWrapper.supplyPointBand.Id) : null ;
                        system.debug(DEBUG + ' asiList=> '+ asiList);
                        //If an Available Service Item is found
                        if(asiList != null && !asiList.isEmpty()) {  //Old SPB - Since there are ASIs available for them
                            //Update the Available Service Item Start/End Date to match the Supply Point Device Start/End Date
                            for(AvailableServiceItem__c asiObj : asiList) {
                                asiObj.StartDate__c = abWrapper.supplyPointBand.StartDate__c ;
                                asiObj.EndDate__c = abWrapper.supplyPointBand.EndDate__c ;
                                //store into a list for update -> To Do**
                                mapUpdatedAvailableServiceItem.put(asiObj.Id, asiObj) ;
                                system.debug(DEBUG + 'mapUpdatedAvailableServiceItem=> ' + mapUpdatedAvailableServiceItem.values());
                                //After updating the Available Service Item query for any Service Items 
                                //where the Start Date < Available Service Item Start date 
                                //OR End Date > Available Service Item End Date OR End Date = Null
                                if(mapAsiId2ListServiceItemObj != null && !mapAsiId2ListServiceItemObj.isEmpty()) {
                                    if(mapAsiId2ListServiceItemObj.containsKey(asiObj.Id)) {
                                        list<ServiceItem__c> listSI = mapAsiId2ListServiceItemObj.get(asiObj.Id) ;
                                        system.debug(DEBUG + ' listSI=> '+ listSI);
                                        if(listSI != null && !listSI.isEmpty()) {
                                            for(ServiceItem__c sItem : listSI) {
                                                //query for any Service Items where the Start Date < Available Service Item Start date 
                                                //OR End Date > Available Service Item End Date OR End Date = Null
                                                if(sItem.StartDate__c < asiObj.StartDate__c) {
                                                    //Update the Service Item dates 
                                                    sItem.StartDate__c = asiObj.StartDate__c ;
                                                }
                                                if(sItem.EndDate__c > asiObj.EndDate__c || sItem.EndDate__c == null) {
                                                    sItem.EndDate__c = asiObj.EndDate__c ;
                                                }
                                                //store into a list for update -> To Do**
                                                mapUpdatedServiceItem.put(sItem.Id, sItem) ;
                                                system.debug(DEBUG + 'mapUpdatedServiceItem=> ' + mapUpdatedServiceItem.values());
                                            }
                                        }
                                    }
                                }
                            }
                        } else //New SPB - Since there are NO ASIs available for them
                            if (mapBundleId2ListBundleItem != null && mapBundleId2ListBundleItem.containsKey(abWrapper.AvailableBundle.Bundle__c)) {
                            system.debug(DEBUG + ' mapBundleId2ListBundleItem=> '+ mapBundleId2ListBundleItem);
                            list<BundleItem__c> listBI = mapBundleId2ListBundleItem.get(abWrapper.AvailableBundle.Bundle__c) ;
                            system.debug(DEBUG + ' listBI=> '+ listBI);
                            if(listBI != null && !listBI.isEmpty()) {
                                for(BundleItem__c bi : listBI) {
                                    if(bi.ServiceItemType__c != null) {
                                        AvailableServiceItem__c asiObj = new AvailableServiceItem__c() ;
                                        asiObj.ServiceItemType__c = bi.ServiceItemType__c ;
                                        asiObj.AvailableBundle__c = availableBundleId ;
                                        asiObj.StartDate__c = effectiveDate ;
                                        asiObj.BundleItem__c = bi.Id ;
                                        asiObj.SupplyPointBand__c = abWrapper.supplyPointBand.Id ;
                                        //store AvailableServiceItem in a list to insert later
                                        listNewAvailableServiceItem.add(asiObj) ;
                                        system.debug(DEBUG + '5->listNewAvailableServiceItem=> ' + listNewAvailableServiceItem);
                                        String asiKey = bi.ServiceItemType__c + '-' + availableBundleId ;
                                        system.debug(DEBUG + ' mapAvailableServiceId2ActiveServiceId=> '+ mapAvailableServiceId2ActiveServiceId);
                                        if(mapAvailableServiceId2ActiveServiceId.containsKey(abWrapper.availableBundle.AvailableService__c)) {
                                            String serviceId = mapAvailableServiceId2ActiveServiceId.get(abWrapper.availableBundle.AvailableService__c) ;
                                            system.debug(DEBUG + '5->serviceId=> ' + serviceId);
                                            if(String.isNotBlank(serviceId)) {
                                                if(mapActiveServiceId2ListServiceItem.containsKey(serviceId)) {
                                                    system.debug(DEBUG + '5->mapActiveServiceId2ListServiceItem=> ' + mapActiveServiceId2ListServiceItem);
                                                    list<ServiceItem__c> listServiceItem = mapActiveServiceId2ListServiceItem.get(serviceId) ;
                                                    system.debug(DEBUG + '5->listServiceItem=> ' + listServiceItem);
                                                    if(listServiceItem != null && !listServiceItem.isEmpty()) {
                                                        //String AvailableServiceItem, String AvailableServiceId, String ServiceItemType, Date effectiveDate, list<ServiceItem__c> listServiceItem
                                                        createServiceItem(asiKey, serviceId, bi.ServiceItemType__c, effectiveDate, listServiceItem, listNewServiceItem) ;
                                                    }
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    //}
                }
                
                //*Sub-Step: #5*-> Retrieve the bundle for associated to the Available Bundle 
                
            	String bundleId = abWrapper.availableBundle.Bundle__c ;
                
                system.debug(DEBUG + '5->wrapper bundleId=> ' + bundleId);
                system.debug(DEBUG + '5->deviceSize=> ' + deviceSize);
                system.debug(DEBUG + '5->mapBundleId2ListBundleItem=> ' + mapBundleId2ListBundleItem); 
                system.debug(DEBUG + '5->mapABId2SetSITIds=> ' + mapABId2SetSITIds); 
                
                if(!String.isBlank(bundleId) && ! + mapBundleId2ListBundleItem.isEmpty() && mapBundleId2ListBundleItem.containsKey(bundleId)) {
                    
                    list<BundleItem__c> listBI = mapBundleId2ListBundleItem.get(bundleId) ;
                    system.debug(DEBUG + '5->listBI=> ' + listBI);
                    set<Id> setIncomingSIT = mapABId2SetSITIds.get(bundleId) ;
                    system.debug('setIncomingSIT=> ' + setIncomingSIT);
                    set<Id> setOldServiceItemTypeOnASI = new set<Id>() ;	//old ASI
                    
                    list<AvailableServiceItem__c> listExistingAvailableServiceItem ;
                        if(mapAvailableBundleId2ListAvailableServiceItem != null && !mapAvailableBundleId2ListAvailableServiceItem.isEmpty()) 
                        		listExistingAvailableServiceItem = mapAvailableBundleId2ListAvailableServiceItem.get(availableBundleId) ;
                    
                    if(listExistingAvailableServiceItem != null && !listExistingAvailableServiceItem.isEmpty()) {
                        for(AvailableServiceItem__c asiObj : listExistingAvailableServiceItem) {
                            system.debug('asiObj.ServiceItemType= ' + asiObj.ServiceItemType__c);
                            if((asiObj.EndDate__c == null || asiObj.EndDate__c > effectiveDate)) {
                                setOldServiceItemTypeOnASI.add(asiObj.ServiceItemType__c) ;
                            }
                        }
                    }
                    system.debug('setOldServiceItemTypeOnASI=> ' + setOldServiceItemTypeOnASI);
                    
                    //Finding Old/New SIT based on Incoming SITs
                    for(BundleItem__c bi : listBI) {
                        system.debug('bi.ServiceItemType=> ' + bi.ServiceItemType__c);
                        system.debug('ServiceItemFamily=> ' + bi.ServiceItemFamily__c);
                        
                        if(bi.ServiceItemType__c != null) { 
                            if(setOldServiceItemTypeOnASI.contains(bi.ServiceItemType__c)) {
                                // Then end the corresponding ASI
                                if(mapAvailableBundleId2ListAvailableServiceItem != null && !mapAvailableBundleId2ListAvailableServiceItem.isEmpty()) {
                                        list<AvailableServiceItem__c> listAvailableServiceItem = mapAvailableBundleId2ListAvailableServiceItem.get(availableBundleId) ;
                                        if(listAvailableServiceItem != null && !listAvailableServiceItem.isEmpty()) {
                                            for(AvailableServiceItem__c asiObj : listAvailableServiceItem) {
                                                if((asiObj.EndDate__c == null || asiObj.EndDate__c > effectiveDate) && !setIncomingSIT.contains(asiObj.ServiceItemType__c)) {
                                                    //setOldSIT.add(asiObj.ServiceItemType__c) ;
                                                    //Set Available Service Item End Date = effectiveDate - 1
                                                    asiObj.EndDate__c = effectiveDate - 1 ;
                                                    //update Available Service Item record
                                                    mapUpdatedAvailableServiceItem.put(asiObj.Id, asiObj) ;
                                                    system.debug(DEBUG + '6.1->mapUpdatedAvailableServiceItem=> ' + mapUpdatedAvailableServiceItem.values());
                                                    //6.1.1* -> Find any attached Service Items that are still active and set End Date = effectiveDate - 1
                                                    system.debug(DEBUG + '6.1->mapAvailableServiceItemId2ListServiceItem=> ' + mapAvailableServiceItemId2ListServiceItem);
                                                    if(mapAvailableServiceItemId2ListServiceItem != null && !mapAvailableServiceItemId2ListServiceItem.isEmpty()) {
                                                        if(mapAvailableServiceItemId2ListServiceItem.containsKey(asiObj.Id)) {
                                                            //6.1.2* -> Find any attached Service Items that are still active
                                                            list<ServiceItem__c> listSI = mapAvailableServiceItemId2ListServiceItem.get(asiObj.Id) ;
                                                            if(listSI != null && !listSI.isEmpty()) {
                                                                for(ServiceItem__c sItem : listSI) {
                                                                    //Find any attached Service Items that are still active
                                                                    if(sItem.StartDate__c != null && (sItem.EndDate__c == null ||sItem.EndDate__c <= asiObj.EndDate__c)) {	
                                                                        sItem.EndDate__c = effectiveDate - 1  ;
                                                                        //Store in a list to update later 
                                                                        mapUpdatedServiceItem.put(sItem.Id, sItem) ;
                                                                        system.debug(DEBUG + '6.1->mapUpdatedServiceItem=> ' + mapUpdatedServiceItem.values());
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                // Keep it as-is
                                            }
                                            
                                        }
                                }
                                //list<AvailableServiceItem__c> listASI = mapServiceItemTypeId2ListAvailableSI
                            } 
                            else {
                                //End date & Then create
                                system.debug(DEBUG + '6.1->mapAvailableBundleId2ListAvailableServiceItem=> ' + mapAvailableBundleId2ListAvailableServiceItem);
                                if(mapAvailableBundleId2ListAvailableServiceItem != null && !mapAvailableBundleId2ListAvailableServiceItem.isEmpty()) {
                                    list<AvailableServiceItem__c> listAvailableServiceItem = mapAvailableBundleId2ListAvailableServiceItem.get(availableBundleId) ;
                                    system.debug(DEBUG + '6.1->listAvailableServiceItem=> ' + listAvailableServiceItem);    
                                    if(listAvailableServiceItem != null && !listAvailableServiceItem.isEmpty()) {
                                            for(AvailableServiceItem__c asiObj : listAvailableServiceItem) {
                                                system.debug(DEBUG + '6.1->asiObj.ServiceItemType__c=> ' + asiObj.ServiceItemType__c);    
                                                system.debug(DEBUG + '6.1->setIncomingSIT=> ' + setIncomingSIT);    
                                                if((asiObj.EndDate__c == null || asiObj.EndDate__c > effectiveDate) && !setIncomingSIT.contains(asiObj.ServiceItemType__c)) {
                                                    //setOldSIT.add(asiObj.ServiceItemType__c) ;
                                                    //Set Available Service Item End Date = effectiveDate - 1
                                                    asiObj.EndDate__c = effectiveDate - 1 ;
                                                    //update Available Service Item record
                                                    mapUpdatedAvailableServiceItem.put(asiObj.Id, asiObj) ;
                                                    system.debug(DEBUG + '6.1->mapUpdatedAvailableServiceItem=> ' + mapUpdatedAvailableServiceItem.values());
                                                    //6.1.1* -> Find any attached Service Items that are still active and set End Date = effectiveDate - 1
                                                    system.debug(DEBUG + '6.1->mapAvailableServiceItemId2ListServiceItem=> ' + mapAvailableServiceItemId2ListServiceItem);
                                                    if(mapAvailableServiceItemId2ListServiceItem != null && !mapAvailableServiceItemId2ListServiceItem.isEmpty()) {
                                                        if(mapAvailableServiceItemId2ListServiceItem.containsKey(asiObj.Id)) {
                                                            //6.1.2* -> Find any attached Service Items that are still active
                                                            list<ServiceItem__c> listSI = mapAvailableServiceItemId2ListServiceItem.get(asiObj.Id) ;
                                                            if(listSI != null && !listSI.isEmpty()) {
                                                                for(ServiceItem__c sItem : listSI) {
                                                                    //Find any attached Service Items that are still active
                                                                    if(sItem.StartDate__c != null && (sItem.EndDate__c == null ||sItem.EndDate__c <= asiObj.EndDate__c)) {	
                                                                        sItem.EndDate__c = effectiveDate - 1  ;
                                                                        //Store in a list to update later 
                                                                        mapUpdatedServiceItem.put(sItem.Id, sItem) ;
                                                                        system.debug(DEBUG + '6.1->mapUpdatedServiceItem=> ' + mapUpdatedServiceItem.values());
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                // Keep it as-is
                                            }
                                            
                                        }
                                }
                                system.debug(DEBUG + '6.1->Create New AvailableServiceItem ');    
                                system.debug(DEBUG + '6.1->effectiveDate=' + effectiveDate);    
                                //add the Service item Type as an Available Service Item under the Available Bundle with a Start Date = effectiveDate
                                AvailableServiceItem__c asiObj = new AvailableServiceItem__c() ;
                                asiObj.ServiceItemType__c = bi.ServiceItemType__c ;
                                asiObj.AvailableBundle__c = availableBundleId ;
                                asiObj.StartDate__c = effectiveDate ;
                                asiObj.BundleItem__c = bi.Id ;
                                //store AvailableServiceItem in a list to insert later
                                listNewAvailableServiceItem.add(asiObj) ;
                                system.debug(DEBUG + '5->listNewAvailableServiceItem=> ' + listNewAvailableServiceItem);
                                String asiKey = bi.ServiceItemType__c + '-' + availableBundleId ;
                                if(mapAvailableServiceId2ActiveServiceId.containsKey(abWrapper.availableBundle.AvailableService__c)) {
                                    String serviceId = mapAvailableServiceId2ActiveServiceId.get(abWrapper.availableBundle.AvailableService__c) ;
                                    system.debug(DEBUG + '5->serviceId=> ' + serviceId);
                                    if(String.isNotBlank(serviceId)) {
                                        if(mapActiveServiceId2ListServiceItem.containsKey(serviceId)) {
                                            system.debug(DEBUG + '5->mapActiveServiceId2ListServiceItem=> ' + mapActiveServiceId2ListServiceItem);
                                            list<ServiceItem__c> listServiceItem = mapActiveServiceId2ListServiceItem.get(serviceId) ;
                                            system.debug(DEBUG + '5->listServiceItem=> ' + listServiceItem);
                                            if(listServiceItem != null && !listServiceItem.isEmpty()) {
                                                //String AvailableServiceItem, String AvailableServiceId, String ServiceItemType, Date effectiveDate, list<ServiceItem__c> listServiceItem
                                                createServiceItem(asiKey, serviceId, bi.ServiceItemType__c, effectiveDate, listServiceItem, listNewServiceItem) ;
                                            }
                                        }
                                        
                                    }
                                }
                            }
                        }  else if(bi.ServiceItemFamily__c != null) {	//If the Service Item Family is populated
                                //query related children Service Items Types under the Service Item Family 
                                //for the Device Size found in the first step
                                system.debug('mapSif2SetSitIds= ' + mapSif2SetSitIds);
                                system.debug('bi.ServiceItemFamily= ' + bi.ServiceItemFamily__c);
                                
                                set<Id> setSIT = mapSif2SetSitIds.get(bi.ServiceItemFamily__c) ;
                                system.debug('setSIT=> ' + setSIT) ;
                                list<ServiceItemType__c> listSIT = mapServiceItemFamilyId2ListServiceItemType.get(bi.ServiceItemFamily__c) ;
                                system.debug('listSIT=> ' + listSIT) ;
                                set<Id> setOldSIT = new set<Id>() ;
                                
                                if(setSIT != null && !setSIT.isEmpty()) {
                                    //Finding old ASI
                                    if(mapAvailableBundleId2ListAvailableServiceItem != null && !mapAvailableBundleId2ListAvailableServiceItem.isEmpty()) {
                                        list<AvailableServiceItem__c> listAvailableServiceItem = mapAvailableBundleId2ListAvailableServiceItem.get(availableBundleId) ;
                                        if(listAvailableServiceItem != null && !listAvailableServiceItem.isEmpty()) {
                                            for(AvailableServiceItem__c asiObj : listAvailableServiceItem) {
                                                system.debug('asiObj.ServiceItemType= ' + asiObj.ServiceItemType__c);
                                                if((asiObj.EndDate__c == null || asiObj.EndDate__c > effectiveDate) && !setSIT.contains(asiObj.ServiceItemType__c)) {
                                                    setOldSIT.add(asiObj.ServiceItemType__c) ;
                                                    //Set Available Service Item End Date = effectiveDate - 1
                                                    asiObj.EndDate__c = effectiveDate - 1 ;
                                                    //update Available Service Item record
                                                    mapUpdatedAvailableServiceItem.put(asiObj.Id, asiObj) ;
                                                    system.debug(DEBUG + '6.1->mapUpdatedAvailableServiceItem=> ' + mapUpdatedAvailableServiceItem.values());
                                                    //6.1.1* -> Find any attached Service Items that are still active and set End Date = effectiveDate - 1
                                                    system.debug(DEBUG + '6.1->mapAvailableServiceItemId2ListServiceItem=> ' + mapAvailableServiceItemId2ListServiceItem);
                                                    if(mapAvailableServiceItemId2ListServiceItem != null && !mapAvailableServiceItemId2ListServiceItem.isEmpty()) {
                                                        if(mapAvailableServiceItemId2ListServiceItem.containsKey(asiObj.Id)) {
                                                            //6.1.2* -> Find any attached Service Items that are still active
                                                            list<ServiceItem__c> listSI = mapAvailableServiceItemId2ListServiceItem.get(asiObj.Id) ;
                                                            if(listSI != null && !listSI.isEmpty()) {
                                                                for(ServiceItem__c sItem : listSI) {
                                                                    //Find any attached Service Items that are still active
                                                                    if(sItem.StartDate__c != null && (sItem.EndDate__c == null ||sItem.EndDate__c <= asiObj.EndDate__c)) {	
                                                                        sItem.EndDate__c = effectiveDate - 1  ;
                                                                        //Store in a list to update later 
                                                                        mapUpdatedServiceItem.put(sItem.Id, sItem) ;
                                                                        system.debug(DEBUG + '6.1->mapUpdatedServiceItem=> ' + mapUpdatedServiceItem.values());
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                //SIT matched
                                                
                                            }
                                        }
                                    }
                                        
                                    for(ServiceItemType__c sit : listSIT) {
                                        system.debug(DEBUG + '5->sit=> ' + sit);
                                        //if DeviceSize on a Service Item Type is found
                                        system.debug('sit.DeviceSize=> ' + sit.DeviceSize__c);
                                        system.debug('sit.BandType=> ' + sit.BandType__c);
                                        system.debug(DEBUG + '5->mapAvailableBundleId2SpdObj=> ' + mapAvailableBundleId2SpdObj);
                                        system.debug(DEBUG + '5->setOldSIT=> ' + setOldSIT);
                                        system.debug(DEBUG + '5->sit.Id=> ' + sit.Id);
                                        
                                        if(setOldSIT.isEmpty() || !setOldSIT.contains(sit.Id)) {	//START: New SIT in the incoming Bundle item
                                            system.debug('sit.DeviceSize=> ' + sit.DeviceSize__c);
                                            system.debug('sit.BandType=> ' + sit.BandType__c);
                                            system.debug('deviceSize=> ' + deviceSize);
                                            system.debug('bandType=> ' + bandType);
                                            if(sit.DeviceSize__c != null && String.isNotBlank(deviceSize) && sit.DeviceSize__c == deviceSize) {	// Device Id - To check??
                                                //1. Add the returned Service Item Type as an Available Service Item under the Available Bundle
                                                AvailableServiceItem__c asiObj = new AvailableServiceItem__c() ;
                                                asiObj.ServiceItemType__c = sit.Id ;
                                                asiObj.BundleItem__c = bi.Id ;
                                                asiObj.AvailableBundle__c = availableBundleId ;
                                                asiObj.StartDate__c = effectiveDate ;
                                                //2. Link the Available Service Item Type to the related Supply Point Device found in the first step
                                                system.debug(DEBUG + '5->mapAvailableBundleId2SpdObj=> ' + mapAvailableBundleId2SpdObj);
                                                asiObj.SupplyPointDevice__c = mapAvailableBundleId2SpdObj != null && mapAvailableBundleId2SpdObj.containsKey(availableBundleId)
                                                    ? mapAvailableBundleId2SpdObj.get(availableBundleId).Id : null ;
                                                String asiKey = sit.Id + '-' + availableBundleId ;
                                                //store AvailableServiceItem in a list to insert later 
                                                listNewAvailableServiceItem.add(asiObj) ;
                                                system.debug(DEBUG + '5->listNewAvailableServiceItem=> ' + listNewAvailableServiceItem);
                                                system.debug(DEBUG + '5->abWrapper.availableBundle.AvailableService=> ' + abWrapper.availableBundle.AvailableService__c);
                                                system.debug(DEBUG + '5->mapAvailableServiceId2ActiveServiceId=> ' + mapAvailableServiceId2ActiveServiceId);
                                                //String AvailableServiceItem, String AvailableServiceId, String ServiceItemType, Date effectiveDate
                                                
                                                if(mapAvailableServiceId2ActiveServiceId.containsKey(abWrapper.availableBundle.AvailableService__c)) {
                                                    String serviceId = mapAvailableServiceId2ActiveServiceId.get(abWrapper.availableBundle.AvailableService__c) ;
                                                    system.debug(DEBUG + '5->serviceId=> ' + serviceId);
                                                    if(String.isNotBlank(serviceId)) {
                                                        if(mapActiveServiceId2ListServiceItem.containsKey(serviceId)) {
                                                            list<ServiceItem__c> listServiceItem = mapActiveServiceId2ListServiceItem.get(serviceId) ;
                                                            system.debug(DEBUG + '5->listServiceItem=> ' + listServiceItem);
                                                            if(listServiceItem != null && !listServiceItem.isEmpty()) {
                                                                //String AvailableServiceItem, String AvailableServiceId, String ServiceItemType, Date effectiveDate, list<ServiceItem__c> listServiceItem
                                                                createServiceItem(asiKey, serviceId, sit.Id, effectiveDate, listServiceItem, listNewServiceItem) ;
                                                            }
                                                        }
                                                        
                                                    }
                                                }
                                            } // END: deviceSize - check ends
                                            
                                            //if BandType on a Service Item Type is found
                                            
                                            else if(sit.BandType__c != null && String.isNotBlank(bandType) && sit.BandType__c == bandType) { 	// Band Type Id - To check??
                                                //1. Add the returned Service Item Type as an Available Service Item under the Available Bundle
                                                AvailableServiceItem__c asiObj = new AvailableServiceItem__c() ;
                                                asiObj.ServiceItemType__c = sit.Id ;
                                                asiObj.BundleItem__c = bi.Id ;
                                                asiObj.AvailableBundle__c = availableBundleId ;
                                                asiObj.StartDate__c = effectiveDate ;
                                                //2. Link the Available Service Item Type to the related Supply Point Band found in the first step
                                                system.debug(DEBUG + '5->mapAvailableBundleId2SpbObj=> ' + mapAvailableBundleId2SpbObj);
                                                asiObj.SupplyPointBand__c = mapAvailableBundleId2SpbObj != null && mapAvailableBundleId2SpbObj.containsKey(availableBundleId)
                                                    ? mapAvailableBundleId2SpbObj.get(availableBundleId).Id : null ;
                                                String asiKey = sit.Id + '-' + availableBundleId ;
                                                //store AvailableServiceItem in a list to insert later 
                                                listNewAvailableServiceItem.add(asiObj) ;
                                                system.debug(DEBUG + '5->listNewAvailableServiceItem=> ' + listNewAvailableServiceItem);
                                                if(mapAvailableServiceId2ActiveServiceId.containsKey(abWrapper.availableBundle.AvailableService__c)) {
                                                    String serviceId = mapAvailableServiceId2ActiveServiceId.get(abWrapper.availableBundle.AvailableService__c) ;
                                                    if(String.isNotBlank(serviceId)) {
                                                        if(mapActiveServiceId2ListServiceItem.containsKey(serviceId)) {
                                                            list<ServiceItem__c> listServiceItem = mapActiveServiceId2ListServiceItem.get(serviceId) ;
                                                            if(listServiceItem != null && !listServiceItem.isEmpty()) {
                                                                //String AvailableServiceItem, String AvailableServiceId, String ServiceItemType, Date effectiveDate, list<ServiceItem__c> listServiceItem
                                                                createServiceItem(asiKey, serviceId, sit.Id, effectiveDate, listServiceItem, listNewServiceItem) ;
                                                            }
                                                        }
                                                        
                                                    }
                                                }
                                            } // END: bandType - check ends
                                        } // END: New SIT in the incoming Bundle item
                                    } //End: Iteration for each ServiceItemType under a BundleItem ServiceItemFamily
                                }
                            } 
                        
                    }
                }
               
            }
        }
        
        system.debug(DEBUG + 'mapUpdatedAvailableServiceItem=> ' + mapUpdatedAvailableServiceItem.values());
        system.debug(DEBUG + 'mapUpdatedServiceItem=> ' + mapUpdatedServiceItem.values());
        system.debug(DEBUG + 'listNewAvailableServiceItem=> ' + listNewAvailableServiceItem);
		system.debug(DEBUG + 'listNewServiceItem=> ' + listNewServiceItem); 
        
        //for now, keeping separate DMLs -> will use list of SObject for single DML if required.
        if(!mapUpdatedAvailableServiceItem.values().isEmpty()) {
            Database.update(mapUpdatedAvailableServiceItem.values()) ;
        }
        if(!mapUpdatedServiceItem.values().isEmpty()) {
            Database.update(mapUpdatedServiceItem.values()) ;
        }
        map<String, Id> mapKey2AsiId ;
        if(!listNewAvailableServiceItem.isEmpty()) {
            mapKey2AsiId = new map<String, Id>() ;
            Database.insert(listNewAvailableServiceItem) ;
            for(AvailableServiceItem__c asi : listNewAvailableServiceItem) {
                mapKey2AsiId.put(asi.ServiceItemType__c + '-' + asi.AvailableBundle__c, asi.Id) ;
            }
            system.debug(DEBUG + 'Last-mapKey2AsiId=> ' + mapKey2AsiId);
        }
        
        if(!listNewServiceItem.isEmpty()) {
            for(String availableBundleId : mapAvailableBundleId2Wrapper.keySet()) {
                for(ServiceItem__c si : listNewServiceItem) {
                    String key = si.ServiceItemType__c + '-' + availableBundleId ;
                    system.debug(DEBUG + 'Last-SI-key=> ' + key);
                    si.AvailableServiceItem__c = mapKey2AsiId.containsKey(key) ? mapKey2AsiId.get(key) : null ;
                }
            }
            system.debug(DEBUG + 'Last-listNewServiceItem=> ' + listNewServiceItem);
            Database.insert(listNewServiceItem) ;
        }
        
        
        system.debug(DEBUG + 'mapUpdatedAvailableServiceItem=> ' + mapUpdatedAvailableServiceItem.values());
        system.debug(DEBUG + 'mapUpdatedServiceItem=> ' + mapUpdatedServiceItem.values());
        system.debug(DEBUG + 'listNewAvailableServiceItem=> ' + listNewAvailableServiceItem);
		system.debug(DEBUG + 'listNewServiceItem=> ' + listNewServiceItem);        
    }
    
    private static void createServiceItem(String AvailableServiceItemKey, String AvailableServiceId, String ServiceItemType, Date effectiveDate, list<ServiceItem__c> listServiceItem, list<ServiceItem__c> listNewServiceItem) {
        Boolean activeServiceItemExist = false ;
        Date maxEndDate = null ;
        Date tempEndDate = null ;
        for(ServiceItem__c sItem : listServiceItem) {
            activeServiceItemExist = sItem.ServiceItemType__c == ServiceItemType && sItem.StartDate__c < effectiveDate && sItem.EndDate__c >= effectiveDate ;
            if(activeServiceItemExist) break ;
            tempEndDate = sItem.EndDate__c ;
            if(sItem.EndDate__c == null) {
                maxEndDate = null ;
                break ;
            } else {
                maxEndDate = tempEndDate >= maxEndDate ? tempEndDate : maxEndDate ;
            }
        }
        system.debug(DEBUG + '6.2-maxEndDate=> ' + maxEndDate);
        if(!activeServiceItemExist) {
            ServiceItem__c newSItem = new ServiceItem__c() ;
            newSItem.Service__c = AvailableServiceId  ;
            newSItem.ServiceItemType__c =  ServiceItemType ;
            //newSItem.AvailableServiceItem__c = AvailableServiceItem ;
            newSItem.StartDate__c = effectiveDate ;
            newSItem.EndDate__c = maxEndDate ;
            //Store in a list to insert later
            listNewServiceItem.add(newSItem) ;
            system.debug(DEBUG + '6.2->Not-activeServiceItemExist-listNewServiceItem=> ' + listNewServiceItem);
            
        } else {
            
        }
    }
        
 /**********************************************************************************************
@author        Echo: Dependra Singh
@date          12- Jan-2018
@param         List<Id> Takes the list of available bundles as an input.
@return        GlUt_AvailableBundleDataWrapper class
@description   This method is used to create Available bundle Wrapper.
**********************************************************************************************/    
 private GlUt_AvailableBundleDataWrapper createAvailableBundleWrapperData(List<AvailableBundle__c> availableBundleList){
    //For each available bundles
    GlUt_AvailableBundleDataWrapper objAvailableBundleWrap = new GlUt_AvailableBundleDataWrapper();
    for (AvailableBundle__c objAvailableBundle: availableBundleList) {

        //If bundle is not null in available bundle then add it in set of bundle 
        // Retrieve the bundle for associated to the Available Bundle 
        if (objAvailableBundle.Bundle__c != null) {
            objAvailableBundleWrap.bundlesIds.add(objAvailableBundle.Bundle__c);
            //Creating map to get bundle by available bundle.
            if (!objAvailableBundleWrap.mapAvailableBundleById.containsKey(objAvailableBundle.id)) {
                objAvailableBundleWrap.mapAvailableBundleById.put(objAvailableBundle.id, objAvailableBundle);
            }
        }
        // If available service not null.
        if (objAvailableBundle.AvailableService__c != null) {
        	//Creating map to get available service  by available bundle.
            if (!objAvailableBundleWrap.mapAvailableServiceByAvailableBundle.containsKey(objAvailableBundle.id)) {
                objAvailableBundleWrap.mapAvailableServiceByAvailableBundle.put(objAvailableBundle.id, objAvailableBundle.AvailableService__c);
            }
        }

        //If supply point not null in available service then add in set of supply point
        if (objAvailableBundle.AvailableService__r.SupplyPoint__c != null) {
            //Creating map to get supplypoint by available bundle.
            if (!objAvailableBundleWrap.mapSupplyPointByAvailableBundle.containsKey(objAvailableBundle.Id)) {
                objAvailableBundleWrap.mapSupplyPointByAvailableBundle.put(objAvailableBundle.Id, objAvailableBundle.AvailableService__r.SupplyPoint__c);
            }
        }
    }
    return objAvailableBundleWrap;
 }
 /**********************************************************************************************
@author        Echo: Dependra Singh
@date          12- Jan-2018
@param         List<Id> Takes the list of available service ids as an input.
@return        Map<Id,Id>                  
@description   This method is used to create map of Service by Available Service.
**********************************************************************************************/   
 private Map<Id,Id> createMapOfServiceByAvailableService(List<Id> availableServiceIds){
     Map<Id,Id> mapServiceByAvailableService = new Map<Id,Id>();
     for (Service__c objService: [SELECT Id, 
                                 AvailableService__c, 
                                 ServiceEndDate__c, 
                                 ServiceStartDate__c 
                                 FROM Service__c 
                                 WHERE AvailableService__c IN: availableServiceIds 
                                 AND (ServiceEndDate__c >= TODAY 
                                 OR ServiceEndDate__c = null) 
                                 AND(ServiceStartDate__c < TODAY)]) {
        if (!mapServiceByAvailableService.containsKey(objService.AvailableService__c)) {
            mapServiceByAvailableService.put(objService.AvailableService__c, objService.id);
        }
    }
    return mapServiceByAvailableService;
 }
/**********************************************************************************************
@author        Echo: Dependra Singh
@date          12- Jan-2018
@param         Set<Id> Takes the set of bundles ids as an input.
@return        GlUt_BundleItemDataWrapper                              
@description   This method is used to create wrapper of Bundle and Bundle Item .
**********************************************************************************************/  
 private GlUt_BundleItemDataWrapper createBundleItemByBundleMap(Set<Id> bundlesIds){
     GlUt_BundleItemDataWrapper objBundleItemDataWrapper = new GlUt_BundleItemDataWrapper();
     List<BundleItem__c> bundleItemsList = [SELECT Id, 
											  Bundle__c, 
											  ServiceItemFamily__c, 
											  ServiceItemType__c
											// ServiceItemType__r.DeviceType__c 
											  FROM BundleItem__c 
											  WHERE Bundle__c IN: bundlesIds];
    if (!bundleItemsList.isEmpty()) {
        for (BundleItem__c objBundleItem: bundleItemsList) {
            if (objBundleItem.ServiceItemFamily__c != null) {
                objBundleItemDataWrapper.serviceItemFamilyIds.add(objBundleItem.ServiceItemFamily__c);

            }
            if (objBundleItem.ServiceItemType__c != null) {
               objBundleItemDataWrapper.serviceItemTypeIds.add(objBundleItem.ServiceItemType__c);
            }
            if (!objBundleItemDataWrapper.mapBundlesItemsByBundle.containsKey(objBundleItem.Bundle__c)) {
                objBundleItemDataWrapper.mapBundlesItemsByBundle.put(objBundleItem.Bundle__c, new List < BundleItem__c > ());
                objBundleItemDataWrapper.mapBundlesItemsByBundle.get(objBundleItem.Bundle__c).add(objBundleItem);
            } else {
                objBundleItemDataWrapper.mapBundlesItemsByBundle.get(objBundleItem.Bundle__c).add(objBundleItem);
            }
        }
    }
    return objBundleItemDataWrapper;
 }
 /**********************************************************************************************
@author        Echo: Dependra Singh
@date          12- Jan-2018
@param         Set<Id> Takes the set of supplyPoints ids as an input.
@return        Map<Id,Id>                  
@description   This method is used to create map of Device Type By Supply Point
**********************************************************************************************/    
//Commented by Dependra for device size changes
 /*private Map<Id,Id> createDeviceTypeBySupplyPoint(Set<Id> supplyPointsIds){
    Map<Id,Id> mapDeviceTypeBySupplyPoint = new Map<Id,Id>();
    //for each supply point device
    for (SupplyPointDevice__c objSupplyPointDevice: [SELECT Id, 
                                                     SupplyPoint__c, 
                                                     Device__c, 
                                                     Device__r.DeviceType__c, 
                                                     Device__r.Active__c, 
                                                     Active__c 
                                                     FROM SupplyPointDevice__c 
                                                     WHERE SupplyPoint__c IN: supplyPointsIds 
                                                     AND Active__c = true 
                                                     AND Device__r.Active__c = true]) {

            // Creating map to get device type by supply point.
            if (!mapDeviceTypeBySupplyPoint.containsKey(objSupplyPointDevice.SupplyPoint__c)) {
                mapDeviceTypeBySupplyPoint.put(objSupplyPointDevice.SupplyPoint__c, objSupplyPointDevice.Device__r.DeviceType__c);
            }
    }
    return mapDeviceTypeBySupplyPoint;
 }*/

/**********************************************************************************************
@author        Echo: Dependra Singh
@date          14- Feb-2018
@param         Set<Id> Takes the set of supplyPoints ids as an input.
@return        Map<Id,Id>                  
@description   This method is used to create map of Device size By Supply Point(Device Size Changes.)
Revision(s)    24-May-2018 T Gupta , AT-2671 , Removed Active check from Device as in single transaction the formula field was not calculated. Active SPD check seems enough.
**********************************************************************************************/    
    private Map<Id,Id> createDeviceSizeBySupplyPoint(Set<Id> supplyPointsIds){
        Map<Id,Id> mapDeviceSizeByDeviceType = new Map<Id,Id>();
        //for each supply point device
        /*List<SupplyPointDevice__c> lstSupplyPointDevice = [SELECT Id, 
                                                           SupplyPoint__c, 
                                                           Device__c, 
                                                           Device__r.DeviceType__c, 
                                                           Device__r.DeviceType__r.DeviceSize__c, 
                                                           Device__r.Active__c, 
                                                           Active__c 
                                                           FROM SupplyPointDevice__c 
                                                           WHERE SupplyPoint__c IN: supplyPointsIds 
                                                           AND Active__c = true 
                                                           AND Device__r.Active__c = true];*/
        
        List<SupplyPointDevice__c> lstSupplyPointDevice = [SELECT Id, 
                                                            SupplyPoint__c, 
                                                            Device__c, 
                                                            Device__r.DeviceType__c, 
                                                            Device__r.DeviceType__r.DeviceSize__c, 
                                                            Device__r.Active__c, 
                                                            Active__c 
                                                            FROM SupplyPointDevice__c 
                                                            WHERE SupplyPoint__c IN: supplyPointsIds 
                                                            AND Active__c = true ];
        if(lstSupplyPointDevice != null && lstSupplyPointDevice.size() > 0){
            for (SupplyPointDevice__c objSupplyPointDevice: lstSupplyPointDevice) {
                // Creating map to get device size by supply point.
                if (!mapDeviceSizeByDeviceType.containsKey(objSupplyPointDevice.SupplyPoint__c)) {
                    mapDeviceSizeByDeviceType.put(objSupplyPointDevice.SupplyPoint__c, objSupplyPointDevice.Device__r.DeviceType__r.DeviceSize__c);
                }
            }
        }
        return mapDeviceSizeByDeviceType;
    }

/**********************************************************************************************
@author        Echo: Dependra Singh
@date          29-Nov-2017
@param         List<Id> Takes the list of available bundles ids as an input.
@return        void
@description   This method is used to invoke method FROM trigger
**********************************************************************************************/  
private  Map<Id,List<ServiceItem__c>> createMapServiceItemByServiceId(Set<Id> setServiceIds){
    Map<Id,List<ServiceItem__c>> mapServiceItemsByServiceId = new Map<Id,List<ServiceItem__c>>();
    //for each supply point device
    List<ServiceItem__c> lstServiceItems =[SELECT Id, 
                                          AvailableServiceItem__c,
                                          EndDate__c,
                                          Service__c,
                                          ServiceItemType__c,
                                          StartDate__c
                                          FROM ServiceItem__c 
                                          WHERE Service__c IN :setServiceIds
                                          AND (EndDate__c = null OR EndDate__c > TODAY)];
    for(ServiceItem__c objServiceItem : lstServiceItems)    {
        if(!mapServiceItemsByServiceId.containsKey(objServiceItem.Service__c)){
           mapServiceItemsByServiceId.put(objServiceItem.Service__c, new List<ServiceItem__c>());
           mapServiceItemsByServiceId.get(objServiceItem.Service__c).add(objServiceItem);
        }else{
           mapServiceItemsByServiceId.get(objServiceItem.Service__c).add(objServiceItem);
        }
    }                                 
    return mapServiceItemsByServiceId;
}
/**********************************************************************************************
@author        Echo: Dependra Singh
@date          29-Nov-2017
@param         List<Id> Takes the list of available bundles ids as an input.
@return        void
@description   This method is used to return already created service items
**********************************************************************************************/  
private  set<Id> createAlreadyCreatedServiceItemSet(Set<Id> serviceItemTypeIds, List<Id> availableBundleIds){
    Set<Id> alreadyCreatedServiceItemTypeIds= new Set<Id>();
    //for each Available service item 
    for (AvailableServiceItem__c availableServiceItem: [SELECT Id, 
                                                        ServiceItemType__c, 
                                                        BundleItem__c, 
                                                        AvailableBundle__c, 
                                                        StartDate__c, 
                                                        EndDate__c 
                                                        FROM AvailableServiceItem__c 
                                                        WHERE ServiceItemType__c IN: serviceItemTypeIds 
                                                        AND AvailableBundle__c IN: availableBundleIds
                                                        AND (EndDate__c = null OR EndDate__c > TODAY) ]) {
                                                            
                                                            
        if(availableServiceItem.ServiceItemType__c != null)                                                    
        	alreadyCreatedServiceItemTypeIds.add(availableServiceItem.ServiceItemType__c);                                             
    }
    return alreadyCreatedServiceItemTypeIds;
}
/**********************************************************************************************
@author        Echo: Dependra Singh
@date          29-Nov-2017
@param         List<Id> Takes the list of available bundles ids as an input.
@return        void
@description   This method is used to return already created service items
**********************************************************************************************/  
private   Map<Id,List<AvailableServiceItem__c>> createMapASIByAvailableBundle(List<Id> availableBundleIds){
    Map<Id,List<AvailableServiceItem__c>> mapASIByAvailableBundle = new Map<Id,List<AvailableServiceItem__c>>();
    for (AvailableServiceItem__c availableServiceItem1: [SELECT Id, 
                                                        ServiceItemType__c, 
                                                        BundleItem__c, 
                                                        AvailableBundle__c, 
                                                        StartDate__c, 
                                                        EndDate__c 
                                                        FROM AvailableServiceItem__c 
                                                        WHERE  AvailableBundle__c IN: availableBundleIds]) {
        // Map of Available Service Item By Available bundle.
        if (!mapASIByAvailableBundle.containsKey(availableServiceItem1.AvailableBundle__c)) {
            mapASIByAvailableBundle.put(availableServiceItem1.AvailableBundle__c, new List < AvailableServiceItem__c > ());
            mapASIByAvailableBundle.get(availableServiceItem1.AvailableBundle__c).add(availableServiceItem1);
        } else {
            mapASIByAvailableBundle.get(availableServiceItem1.AvailableBundle__c).add(availableServiceItem1);
        }
    }
    return mapASIByAvailableBundle;
}
/**********************************************************************************************
@author        Echo: Dependra Singh
@date          29-Nov-2017
@param         Id bundleItemId
@param         Id availableBundleId
@param         Id serviceItemId
@return        AvailableServiceItem__c
@description   This method is used to Create available service item
**********************************************************************************************/  
private AvailableServiceItem__c createAvailableServiceItem(Id bundleItemId, Id availableBundleId, Id serviceItemId, Date effectiveDate){
    AvailableServiceItem__c objASIType = new AvailableServiceItem__c();
    objASIType.BundleItem__c = bundleItemId;
    objASIType.AvailableBundle__c = availableBundleid;
    objASIType.ServiceItemType__c = serviceItemId;
    //objASIType.StartDate__c = System.today();  //Sudhir: Added after Andy's suggestion
    objASIType.StartDate__c = effectiveDate ;	// //Sudhir: Added after Andy's suggestion
    return objASIType;
} 

/**********************************************************************************************
@author        Echo: Dependra Singh
@date          29-Nov-2017
@param         List<Id> Takes the list of available bundles ids as an input.
@return        void
@description   This method is used to invoke method FROM trigger
Revision(s)    12-Jan-2018 New Scenarios , As per document shared by ANDY
**********************************************************************************************/ 
    
 public void processAvailableBundle(List < Id > availableBundleListIds) {
   
   // Start Variable Initialization    
   Set<Id> supplyPointsIds = new Set<Id>();
  // Set<Id> deviceTypeIds = new Set<Id>();
   Set<Id> deviceSizeIds = new Set<Id>();
   Set<Id> availableServiceIds = new Set<Id>();
   Set<Id> setServiceIds = new Set<Id>();
   Set<Id> availableServiceItemsAlreadyCreated = new Set<Id>();
   
   List<AvailableBundle__c > availableBundleList = new List<AvailableBundle__c>();
   List<ServiceItemType__c> serviceItemTypeList = new List<ServiceItemType__c>();
   List<AvailableServiceItem__c> availableServiceItemUpdateList = new List<AvailableServiceItem__c>();
   List<AvailableServiceItem__c> availableServiceItemAddList = new List<AvailableServiceItem__c>();
   List<ServiceItem__c> serviceItemNewList = new List<ServiceItem__c>();
   List<ServiceItem__c> serviceItemUpdateList = new List<ServiceItem__c>();
   
   Map<Id,Id> mapServiceByAvailableService = new Map<Id,Id>();
  // Map<Id,Id> mapDeviceTypeBySupplyPoint = new Map<Id,Id>();
   Map<Id,Id> mapDeviceSizeBySupplyPoint = new Map<Id,Id>();
   Map<Id,List<AvailableServiceItem__c>> mapASIByAvailableBundle = new Map<Id,List<AvailableServiceItem__c>>();
   Map<Id,List<ServiceItemType__c >> mapServiceItemTypeByFamily = new Map<Id,List<ServiceItemType__c>>();
   Map<Id,List<ServiceItem__c>> mapServiceItemsByServiceId = new Map<Id,List<ServiceItem__c>>();

   // End Variable Initialization
    // If available bundle set , size is greater than 0
    if (availableBundleListIds.size() > 0) {
           //Get List of all available bundles.
        availableBundleList = [SELECT Id, 
                               AvailableService__c, 
                               Bundle__c, 
                               LastBundleChangeDate__c,		//Sudhir: Added after Andy's suggestion
                               AvailableService__r.SupplyPoint__c 
                               FROM AvailableBundle__c 
                               WHERE Id IN: availableBundleListIds];
        
        // Creating available bundle data wrapper to set the values in variables.
        GlUt_AvailableBundleDataWrapper objAvailableBundleWrapper = this.createAvailableBundleWrapperData(availableBundleList);
        
        // Assigning values in the set of available services
        if(objAvailableBundleWrapper.mapAvailableServiceByAvailableBundle.values().size() >0){
			mapServiceByAvailableService = createMapOfServiceByAvailableService(objAvailableBundleWrapper.mapAvailableServiceByAvailableBundle.values());
        }
        
        // Assigning values in the set of supply point.
        if(objAvailableBundleWrapper.mapSupplyPointByAvailableBundle.values().size() >0){
            supplyPointsIds.addAll(objAvailableBundleWrapper.mapSupplyPointByAvailableBundle.values());
        }
        
        // Checking if services key set size is greater than 0 
        if(mapServiceByAvailableService.keySet().size() > 0) {
            // Creating set of services id
            setServiceIds.addAll(mapServiceByAvailableService.values());
        }
        // Creating map of service item  list by service id which is attached with available service.
        if(setServiceIds.size()> 0){
           mapServiceItemsByServiceId = createMapServiceItemByServiceId(setServiceIds);              
        }
		
		// Changes for device size by Dependra Singh- Date - 14-feb-2018
		
        /*if (supplyPointsIds.size() > 0) {
            mapDeviceTypeBySupplyPoint = createDeviceTypeBySupplyPoint(supplyPointsIds);
            if(mapDeviceTypeBySupplyPoint.values().size() >0){
                 deviceTypeIds.addAll(mapDeviceTypeBySupplyPoint.values());
            }
        }*/
		if (supplyPointsIds.size() > 0) {
            mapDeviceSizeBySupplyPoint = createDeviceSizeBySupplyPoint(supplyPointsIds);
            
            if(mapDeviceSizeBySupplyPoint.values().size() >0){
                 deviceSizeIds.addAll(mapDeviceSizeBySupplyPoint.values());
            }
        }
		
        GlUt_BundleItemDataWrapper objBundleItemDataWrap = new GlUt_BundleItemDataWrapper();
        
        if (objAvailableBundleWrapper.bundlesIds.size() > 0) {
            objBundleItemDataWrap = createBundleItemByBundleMap(objAvailableBundleWrapper.bundlesIds);
        }
        if (objBundleItemDataWrap.serviceItemFamilyIds.size() > 0) {
            serviceItemTypeList = [SELECT Id, 
                                  ServiceItemFamily__c, 
                                  //DeviceType__c,
                                   DeviceSize__c
                                  FROM ServiceItemType__c 
                                  WHERE ServiceItemFamily__c IN: objBundleItemDataWrap.serviceItemFamilyIds 
                                  AND DeviceSize__c IN: deviceSizeIds];

            for (ServiceItemType__c serviceItemType: serviceItemTypeList) {
                objBundleItemDataWrap.serviceItemTypeIds.add(serviceItemType.Id);
                if (!mapServiceItemTypeByFamily.containsKey(serviceItemType.ServiceItemFamily__c)) {
                    mapServiceItemTypeByFamily.put(serviceItemType.ServiceItemFamily__c, new List < ServiceItemType__c > ());
                    mapServiceItemTypeByFamily.get(serviceItemType.ServiceItemFamily__c).add(serviceItemType);
                } else {
                    mapServiceItemTypeByFamily.get(serviceItemType.ServiceItemFamily__c).add(serviceItemType);
                }
                
            }
        }
        // Create available service item set which is already created. 
        if (objBundleItemDataWrap.serviceItemTypeIds.size() > 0) {
            availableServiceItemsAlreadyCreated = createAlreadyCreatedServiceItemSet(objBundleItemDataWrap.serviceItemTypeIds, availableBundleListIds);
        }
        
        // Creating map of available service item by available bundle.
        mapASIByAvailableBundle = createMapASIByAvailableBundle(availableBundleListIds);
        
        Set<Id> availbleServiceItemIds = new Set<Id>();    
        for (AvailableBundle__c objAvailableBundle: availableBundleList) {
            
            if (objAvailableBundleWrapper.mapAvailableBundleById.containsKey(objAvailableBundle.id)) {
                if (objBundleItemDataWrap.mapBundlesItemsByBundle.containsKey(objAvailableBundleWrapper.mapAvailableBundleById.get(objAvailableBundle.id).Bundle__c)) {
                        //Loop through each of the bundle items  
					for (BundleItem__c objBundleItm: objBundleItemDataWrap.mapBundlesItemsByBundle.get(objAvailableBundleWrapper.mapAvailableBundleById.get(objAvailableBundle.id).Bundle__c)) {
						//Service item type found on bundle item
						if (objBundleItm.ServiceItemType__c != null) {
						   // if (!availableSIByServiceItemTypeMap.containsKey(objBundleItm.ServiceItemType__c)) {
							if (!availableServiceItemsAlreadyCreated.contains(objBundleItm.ServiceItemType__c)) {
								// Add the returned Service Item Type as an Available Service Item under the Available Bundle.  
								// //Sudhir: Added date parameter after Andy's suggestion
								availableServiceItemAddList.add(createAvailableServiceItem(objBundleItm.id,objAvailableBundle.id,objBundleItm.ServiceItemType__c, objAvailableBundle.LastBundleChangeDate__c));
							}
                            
						} else {
							//if the Service Item Family is populated 
							if (objBundleItm.ServiceItemFamily__c != null) {

								if (mapServiceItemTypeByFamily.containsKey(objBundleItm.ServiceItemFamily__c)) {
									//query related children Service Items Types under the Service Item Family (We are doin git using map)
									for (ServiceItemType__c objServcItemType: mapServiceItemTypeByFamily.get(objBundleItm.ServiceItemFamily__c)) {

										//If there was a previous available Service Item then  adding all available service items in set.
										//if (!availableSIByServiceItemTypeMap.containsKey(objBundleItm.ServiceItemType__c)) {
										if (!availableServiceItemsAlreadyCreated.contains(objServcItemType.id)) {
											//for the Device Type found
											if (objServcItemType.DeviceSize__c == mapDeviceSizeBySupplyPoint.get(objAvailableBundleWrapper.mapSupplyPointByAvailableBundle.get(objAvailableBundle.Id))) {
												// Add the returned Service Item Type as an Available Service Item under the Available Bundle.  
												// //Sudhir: Added date parameter after Andy's suggestion  
                                                availableServiceItemAddList.add(createAvailableServiceItem(objBundleItm.id,objAvailableBundle.id,objServcItemType.id, objAvailableBundle.LastBundleChangeDate__c));
											}
										}
									}
								}
							}
						}
					}
					if(mapASIByAvailableBundle.containsKey(objAvailableBundle.id)){
						List<AvailableServiceItem__c>  availableServiceItemLst = mapASIByAvailableBundle.get(objAvailableBundle.id);
						if(!availableServiceItemLst.isEmpty()){
							for(AvailableServiceItem__c objASI : availableServiceItemLst){
								if(!objBundleItemDataWrap.serviceItemTypeIds.contains(objASI.ServiceItemType__c)){
									objASI.EndDate__c = System.today().addDays(-1);
									availableServiceItemUpdateList.add(objASI);
								}
							}
						}
					}
                }
            }
        }       
        //  Creating and inserting list of new available service items 
        if (availableServiceItemAddList.size() > 0) {
            //insert availableServiceItemAddList;
            for(AvailableServiceItem__c objAvailableServiceItem : availableServiceItemAddList){
                if(mapASIByAvailableBundle.containsKey(objAvailableServiceItem.AvailableBundle__c)){
                    if(mapASIByAvailableBundle.get(objAvailableServiceItem.AvailableBundle__c).size() >0){
                         ServiceItem__c objNewSI = new ServiceItem__c();
                         objNewSI.AvailableServiceItem__c = objAvailableServiceItem.id;
                         objNewSI.ServiceItemType__c = objAvailableServiceItem.ServiceItemType__c;
                         objNewSI.StartDate__c = system.today();
                         if (objAvailableBundleWrapper.mapAvailableServiceByAvailableBundle.containsKey(objAvailableServiceItem.AvailableBundle__c) && mapServiceByAvailableService.containsKey(objAvailableBundleWrapper.mapAvailableServiceByAvailableBundle.get(objAvailableServiceItem.AvailableBundle__c))) {
                            objNewSI.Service__c = mapServiceByAvailableService.get(objAvailableBundleWrapper.mapAvailableServiceByAvailableBundle.get(objAvailableServiceItem.AvailableBundle__c));
                            serviceItemNewList.add(objNewSI);
                        }
                    }
                }
            }
            /*
            if(!serviceItemNewList.isEmpty())
                insert serviceItemNewList; 
			*/
        }
        // Update list of available service items  
        
        if (availableServiceItemUpdateList.size() > 0) {
            //update availableServiceItemUpdateList;
            
            for(AvailableServiceItem__c objAvailableSIUpdate : availableServiceItemUpdateList){
               if (objAvailableBundleWrapper.mapAvailableServiceByAvailableBundle.containsKey(objAvailableSIUpdate.AvailableBundle__c) && mapServiceByAvailableService.containsKey(objAvailableBundleWrapper.mapAvailableServiceByAvailableBundle.get(objAvailableSIUpdate.AvailableBundle__c))) {
                    if(mapServiceItemsByServiceId.containsKey( mapServiceByAvailableService.get(objAvailableBundleWrapper.mapAvailableServiceByAvailableBundle.get(objAvailableSIUpdate.AvailableBundle__c))) && mapServiceItemsByServiceId.get( mapServiceByAvailableService.get(objAvailableBundleWrapper.mapAvailableServiceByAvailableBundle.get(objAvailableSIUpdate.AvailableBundle__c))).size() > 0 ){
                        for(ServiceItem__c  objSIForUpdate : mapServiceItemsByServiceId.get( mapServiceByAvailableService.get(objAvailableBundleWrapper.mapAvailableServiceByAvailableBundle.get(objAvailableSIUpdate.AvailableBundle__c)))){
                            if(objSIForUpdate.AvailableServiceItem__c == objAvailableSIUpdate.id && objSIForUpdate.ServiceItemType__c == objAvailableSIUpdate.ServiceItemType__c){
                                objSIForUpdate.EndDate__c = system.today().addDays(-1);
                                serviceItemUpdateList.add(objSIForUpdate);
                            }
                        }
                    }
                }
             }
            /*
            if(!serviceItemUpdateList.isEmpty()) 
                update serviceItemUpdateList;
			*/
         }
      }
   }   
}