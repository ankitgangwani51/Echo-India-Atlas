/*****************************************************************************************************************************
@author         Echo: Sudhir Kumar (SK)
@date           25 Jan 2019
@description    AT-4767, AT-5049, AT-5050: As a System I want to be able to accept uploaded Service Locations from a batch file
@revision		SK: AT-5608: "Available Bundles" records not created through location import batch process
******************************************************************************************************************************/

global with sharing class LoBt_LocationImport extends GlBt_BatchProcess implements Database.Batchable<sObject>, Database.Stateful {
	
    private Id batchRequestQueueId;
    private map<Id, LocationUpload__c> mapValidLocationUpload ;
    private list<batchError__c> listBatchError ;
    private map<Id, Location> mapLocationUploadId2LocationWrapper ;
    private map<String, Bundle__c> mapBundleName2BundleObj ;
    private map<Id, list<BatchError__c>> mapLocationUploadId2listBatchError ;
    private set<Id> setInvalidLocationUpload ;	//used to mark LocationUpload record as Invalid when inner validation fails
    private static final String CRLF = '\r\n' ;
    private map<String, String> mapSupplyPointUsageType2Id ;
	private Integer numLocationsCreated		= 0 ;
    private Integer locationCount 			= 0 ;
    private Integer supplyPointCount 		= 0 ;
    private Integer availableServiceCount 	= 0 ;
    private Integer availableBundleCount 	= 0 ;
    private map<Id, BatchError__c> mapLocationUploadId2BatchError ;
    list<LocationUpload__c> listProcessedLocationUpload ;
    
    private static list<String> listLocationUploadFields = new list<String> {
        GlUt_APIConstantsLocationImport.CITY_APINAME,
        GlUt_APIConstantsLocationImport.POSTAL_CODE_APINAME, 
        GlUt_APIConstantsLocationImport.STATE_APINAME,
        GlUt_APIConstantsLocationImport.STREET_APINAME,
        GlUt_APIConstantsLocationImport.LOCATION_TYPE_APINAME,
        GlUt_APIConstantsLocationImport.COUNTRY_APINAME, 
        GlUt_APIConstantsLocationImport.PROCESSED_APINAME,
        GlUt_APIConstantsLocationImport.BUILDDATE_APINAME, 
        GlUt_APIConstantsLocationImport.SUPPLY_POINT_USAGE_TYPE_APINAME,
        GlUt_APIConstantsLocationImport.VOID_PROFILE_APINAME,
        GlUt_APIConstantsLocationImport.LOCATION_SUB_TYPE_APINAME,
            
        GlUt_APIConstantsLocationImport.SERVICE_TYPE1_APINAME,
        GlUt_APIConstantsLocationImport.SERVICE_TYPE2_APINAME,
        GlUt_APIConstantsLocationImport.DIVISION_SERVICE_1_APINAME,
        GlUt_APIConstantsLocationImport.DIVISION_SERVICE_2_APINAME,
        GlUt_APIConstantsLocationImport.WHOLESALER_SERVICE_1_APINAME,
        GlUt_APIConstantsLocationImport.WHOLESALER_SERVICE_2_APINAME,
            
        GlUt_APIConstantsLocationImport.SPECIAL_INSTRUCTIONS_APINAME,
        GlUt_APIConstantsLocationImport.SERVICE_1_AVAILABLEBUNDLE_APINAME,
        GlUt_APIConstantsLocationImport.SERVICE_2_AVAILABLEBUNDLE_APINAME,
        GlUt_APIConstantsLocationImport.GEOLOCATION_LATITUDE_APINAME,
        GlUt_APIConstantsLocationImport.GEOLOCATION_LONGITUDE_APINAME
    } ;
        
    /******************************************************************************
	@author    		Echo: Sudhir Kumar
	@date      		25 Jan 2019
	@param			BatchRequestQueue__c brq	
	@return			Void
	@description 	override method of GlBt_BatchProcess to store BatchRequestQueue Id
	*******************************************************************************/        
    global override void Initialise(BatchRequestQueue__c brq) {  
        this.batchRequestQueueId = brq.Id;
    }
    
    /******************************************************************************
	@author    		Echo: Sudhir Kumar
	@date      		25 Jan 2019
	@param			List<ContentDocumentLink> cdlList	
	@return			Void
	@description 	override method of GlBt_BatchProcess to retrieve Content Version List data and insert records
					in BatchError & LocationUpload accordingly
	*******************************************************************************/
    global override List<BatchError__c> FileImport(List<ContentDocumentLink> cdlList) {  
        List<BatchError__c> listBatchError = new List<BatchError__c>();
        
        return listBatchError ;
    }
    /******************************************************************************
	@author    		Echo: Sudhir Kumar
	@date      		25 Jan 2019
	@param			Database.BatchableContext bc	
	@return			Database.QueryLocator
	@description 	method to start batch process
	*******************************************************************************/
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //Update BRQ status to 'Processing'
        LoBt_ExportRequestedReadingsHelper.changeBRQStatus(this.batchRequestQueueId,LoBt_Constants.BRQPROCESSINGSTATUS) ;       
        mapValidLocationUpload = new map<Id, LocationUpload__c>() ;
        listBatchError = new list<batchError__c>() ;    
        mapLocationUploadId2LocationWrapper = new map<Id, Location>() ;   
        mapBundleName2BundleObj = new map<String, Bundle__c>() ;
        mapLocationUploadId2listBatchError = new map<Id, list<BatchError__c>>() ;
        setInvalidLocationUpload = new set<Id>() ;
        mapLocationUploadId2BatchError = new map<Id, BatchError__c>() ;
        listProcessedLocationUpload = new list<LocationUpload__c>() ;
        
        String queryString = ' SELECT Id, ' + String.join(listLocationUploadFields, ', ') 
            					+ ' FROM ' + GlUt_APIConstantsLocationImport.LOCATION_UPLOAD_APINAME 
            					+ ' WHERE ' 
            					+ GlUt_APIConstantsLocationImport.PROCESSED_APINAME + ' = false ' ; 
        return Database.getQueryLocator(queryString) ;
    }
    /******************************************************************************
	@author    		Echo: Sudhir Kumar
	@date      		25 Jan 2019
	@param			Database.BatchableContext bc, List<LocationUpload__c> listLocationUpload
	@return			Database.QueryLocator
	@description 	method to execute batch process
					//1. If any of the following values are missing from the Location Upload record, create an error detailing each of the missing field(s).
                    //2. If initial validation has successfully passed, create a Location record with the following values.
                    //3. Create a SupplyPoint record linked to the Location with the following values.
                    //4. If the "LocationUlpoad.Service1" is populated, Create an Available Service record linked to the Supply Point with the following values.
                    //4.1.	If the bundle detailed in LocationUpload.Service1AvailableBundle__c field is a valid bundle, 
                    //			Create an Available Bundle detailed within the LocationUpload.Service1AvailableBundle__field, linked to the Available Service.
                    //		Else Create an Error – Invalid Bundle
                    //5. If the LocationUlpoad.Service2 is populated, Create an Available Service record linked to the Supply Point with the following values.
                    //5.1.	If the bundle detailed in LocationUpload.Service1AvailableBundle__c field is a valid bundle,
                    //			Create an Available Bundle detailed within the LocationUpload.Service2AvailableBundle__field, linked to the Available Service.
                    //		Else Create an Error – Invalid Bundle
                    //6. Once a Location Upload record has been processed, assign the "LocationUpload.processed__c" checkbox to True.
	*******************************************************************************/
    
    global void execute(Database.BatchableContext bc, List<LocationUpload__c> listLocationUpload) {
        list<Location__c> listValidWrapperLocation 			= new list<Location__c>() ;
        list<SupplyPoint__c> listValidWrapperSupplyPoint 	= new list<SupplyPoint__c>() ;
        list<String> listValidLocationUploadIds				= new list<String>() ;
        list<AvailableService__c> listValidWrapperAvailableService			= new list<AvailableService__c>() ; 
        list<AvailableBundle__c> listValidWrapperAvailableBundle			= new list<AvailableBundle__c>() ;
        list<AvailableServiceItem__c> listValidWrapperAvailableServiceItem 	= new list<AvailableServiceItem__c>() ;
        set<Id> setProcessedLocationUploadIds = new set<Id>() ;
        try {
            if(listLocationUpload != null && !listLocationUpload.isEmpty()) {
                //Get map of LocationUpload Id => valid Bundle Id
                mapBundleName2BundleObj  = getValidBundleMap(this, listLocationUpload) ;
                system.debug('LoBt_LocationImport-mapBundleName2BundleObj=> ' + mapBundleName2BundleObj) ;
                //Get map of valid LocationUpload
                mapValidLocationUpload = getValidLocationUpload(this, listLocationUpload) ;
                system.debug('LoBt_LocationImport-mapValidLocationUpload=> ' + mapValidLocationUpload) ;
                if(!mapValidLocationUpload.isEmpty()) {
                    for(String locationUploadId : mapValidLocationUpload.keySet()) {
                        //Prepare map of LocationUpload Id => Location wrapper
                        LocationUpload__c locationUpload = mapValidLocationUpload.get(locationUploadId) ;
                        if(locationUpload != null) {
                            //listLocationWrapper.add(new Location(this, locationUpload)) ;
                            mapLocationUploadId2LocationWrapper.put(locationUploadId, new Location(this, locationUpload)) ;
                        }
                    }
                    system.debug('LoBt_LocationImport-mapLocationUploadId2LocationWrapper=> ' + mapLocationUploadId2LocationWrapper) ;
                    //DML (Insert operation) begins..
                    
                    //*********** 1. Insert "Location__c" *********** 
                    
                    for(Id locationUploadId : mapLocationUploadId2LocationWrapper.keySet()) {
                        system.debug('Location-locationUploadId=> ' + locationUploadId);
                        system.debug('Location-setInvalidLocationUpload=> ' + setInvalidLocationUpload);
                        if(!setInvalidLocationUpload.contains(locationUploadId)) {
                            Location locationWrapper = mapLocationUploadId2LocationWrapper.get(locationUploadId) ;
                            system.debug('Location-locationWrapper.objLocation=> ' + locationWrapper.objLocation);
                            listValidWrapperLocation.add(locationWrapper.objLocation) ;
                            listValidLocationUploadIds.add(locationUploadId) ;
                            //listValidWrapperSupplyPoint.add(supplyPointWrapper.objSupplyPoint) ;
                        } else {
                            mapLocationUploadId2LocationWrapper.remove(locationUploadId) ;	// Now, INVALID LocationUpload records are removed from "mapLocationUploadId2LocationWrapper"
                        }
                    }
                    system.debug('LoBt_LocationImport-listValidWrapperLocation=> ' + listValidWrapperLocation) ;
                    listValidWrapperLocation = GlUt_FieldSecurity.cleanseFields(listValidWrapperLocation, false) ;
                    Database.saveResult[] listInsertLocationResult = Database.insert(listValidWrapperLocation, false) ;
                    system.debug('LoBt_LocationImport-listInsertLocationResult=> ' + listInsertLocationResult) ;
                    for(Integer i = 0; i < listInsertLocationResult.size(); i++) {
                        if(!listInsertLocationResult[i].isSuccess()) {
                            listBatchError.add(getBatchErrorInstance(this, listValidLocationUploadIds[i], listInsertLocationResult[i].getErrors()[0].getMessage())) ;
                			setInvalidLocationUpload.add(listValidLocationUploadIds[i]) ;
                            //mapValidLocationUpload.remove(listValidLocationUploadIds[i]) ;
                        } else {
                            numLocationsCreated++ ;
                        }
                    }
                    system.debug('LoBt_LocationImport-setInvalidLocationUpload2222=> ' + setInvalidLocationUpload) ;
                    locationCount = listInsertLocationResult.size() ;
                    system.debug('LoBt_LocationImport-locationCount=> ' + locationCount) ;
                    // Now, mapLocationUploadId2LocationWrapper contains ONLY VALID LocationUpload records
                    system.debug('LoBt_LocationImport-mapLocationUploadId2LocationWrapper=> ' + mapLocationUploadId2LocationWrapper) ;
                    
                    //*********** 2. Insert "SupplyPoint__c"  *********** 		
                    
                    Integer locationCounter = 0 ;
                    for(Id locationUploadId : mapLocationUploadId2LocationWrapper.keySet()) {
                        if(!setInvalidLocationUpload.contains(locationUploadId) && locationCounter < listInsertLocationResult.size()) { 
                            if(listInsertLocationResult[locationCounter].isSuccess()) {
                                SupplyPoint supplyPointWrapper 	= mapLocationUploadId2LocationWrapper.get(locationUploadId).SupplyPoint ;
                                system.debug('Supply Point-supplyPointWrapper=> ' + supplyPointWrapper);
                                SupplyPoint__c supplyPointObj 	= supplyPointWrapper.objSupplyPoint ;
                                supplyPointObj.Location__c 		= listInsertLocationResult[locationCounter].getId() ;
                                listValidWrapperSupplyPoint.add(supplyPointObj) ;
                            } else {
                                system.debug('Supply Point-mapValidLocationUpload-Before=> ' + locationUploadId);
                                mapValidLocationUpload.remove(locationUploadId) ;
                            }
                        } 
                        locationCounter ++ ;
                    }
                    system.debug('LoBt_LocationImport-listValidWrapperSupplyPoint=> ' + listValidWrapperSupplyPoint) ;
                    listValidWrapperSupplyPoint = GlUt_FieldSecurity.cleanseFields(listValidWrapperSupplyPoint, false) ;
                    Database.saveResult[] listInsertSupplyPointResult = Database.insert(listValidWrapperSupplyPoint, false) ;
                    system.debug('LoBt_LocationImport-listInsertSupplyPointResult=> ' + listInsertSupplyPointResult) ;
                    supplyPointCount = listInsertSupplyPointResult.size() ;
                    system.debug('LoBt_LocationImport-supplyPointCount=> ' + supplyPointCount) ;
                    system.debug('LoBt_LocationImport-mapLocationUploadId2LocationWrapper=> ' + mapLocationUploadId2LocationWrapper) ;
                    
                    //*********** 3. Insert "AvailableService__c" ***********  
                    
                    Integer supplyPointCounter = 0 ;
                    for(Id locationUploadId : mapLocationUploadId2LocationWrapper.keySet()) {                        
                        if(!setInvalidLocationUpload.contains(locationUploadId) && supplyPointCounter < listInsertLocationResult.size() && listInsertLocationResult[supplyPointCounter].isSuccess() 
                           && supplyPointCounter < listInsertSupplyPointResult.size()) {
                               if(listInsertSupplyPointResult[supplyPointCounter].isSuccess()) {
                                   AvailableService availableServiceWrapper1 = mapLocationUploadId2LocationWrapper.get(locationUploadId).SupplyPoint.availableService1 ;
                                   //If the LocationUpload.Service1 is populated
                                   if(mapValidLocationUpload.get(locationUploadId).ServiceType1__c != null && availableServiceWrapper1 != null && availableServiceWrapper1.objAvailableService1 != null) {
                                       availableServiceWrapper1.objAvailableService1.SupplyPoint__c 		= listInsertSupplyPointResult[supplyPointCounter].getId() ;
                                       listValidWrapperAvailableService.add(availableServiceWrapper1.objAvailableService1) ;
                                   }
                                   //If the LocationUpload.Service2 is populated
                                   AvailableService availableServiceWrapper2 = mapLocationUploadId2LocationWrapper.get(locationUploadId).SupplyPoint.availableService2 ;
                                   //If the LocationUpload.Service1 is populated
                                   if(mapValidLocationUpload.get(locationUploadId).ServiceType2__c != null && availableServiceWrapper2 != null && availableServiceWrapper2.objAvailableService2 != null) {
                                       availableServiceWrapper2.objAvailableService2.SupplyPoint__c 	= listInsertSupplyPointResult[supplyPointCounter].getId() ;
                                       listValidWrapperAvailableService.add(availableServiceWrapper2.objAvailableService2) ;
                                   } 
                               } else {
                                   mapValidLocationUpload.remove(locationUploadId) ;
                               }
                           } 
                        supplyPointCounter ++ ;
                    }
                    system.debug('LoBt_LocationImport-listValidWrapperAvailableService=> ' + listValidWrapperAvailableService) ;
                    listValidWrapperAvailableService = GlUt_FieldSecurity.cleanseFields(listValidWrapperAvailableService, false) ;
                    Database.saveResult[] listInsertAvailableServiceResult = Database.insert(listValidWrapperAvailableService, false) ;
                    system.debug('LoBt_LocationImport-listInsertAvailableServiceResult=> ' + listInsertAvailableServiceResult) ;
                    availableServiceCount = listInsertAvailableServiceResult.size() ;
                    system.debug('LoBt_LocationImport-availableServiceCount=> ' + availableServiceCount) ;
                    system.debug('LoBt_LocationImport-mapLocationUploadId2LocationWrapper=> ' + mapLocationUploadId2LocationWrapper) ;
                    
                    //*********** 4. Insert "AvailableBundle__c" *********** 
                    
                    Integer availableServiceCounter = 0 ;
                    locationCounter = 0 ;
                    supplyPointCounter = 0 ;
                    for(Id locationUploadId : mapLocationUploadId2LocationWrapper.keySet()) {
                        if(!setInvalidLocationUpload.contains(locationUploadId) && locationCounter < listInsertLocationResult.size() && listInsertLocationResult[locationCounter].isSuccess() 
                           && supplyPointCounter < listInsertSupplyPointResult.size() && listInsertSupplyPointResult[supplyPointCounter].isSuccess()) {
                               if(mapValidLocationUpload.containsKey(locationUploadId) && mapValidLocationUpload.get(locationUploadId).ServiceType1__c != null) { //3
                                   if(availableServiceCounter < listInsertAvailableServiceResult.size()) { //1
                                       if(listInsertAvailableServiceResult[availableServiceCounter].isSuccess()) {
                                           AvailableBundle availableBundleWrapper1 	= mapLocationUploadId2LocationWrapper.get(locationUploadId).SupplyPoint.availableService1.AvailableBundle1 ;
                                           system.debug('AvailableBundle-availableBundleWrapper1=> ' + availableBundleWrapper1) ;
                                           if(availableBundleWrapper1 != null) {
                                               AvailableBundle__c availableBundleObj1 	= availableBundleWrapper1.objAvailableBundle1 ;
                                               availableBundleObj1.AvailableService__c 	= listInsertAvailableServiceResult[availableServiceCounter].getId() ;
                                               listValidWrapperAvailableBundle.add(availableBundleObj1) ;
                                           }
                                           availableServiceCounter++ ;
                                       } else {
                                           mapValidLocationUpload.remove(locationUploadId) ;
                                       }  
                                   }
                               }
                               if(mapValidLocationUpload.containsKey(locationUploadId) && mapValidLocationUpload.get(locationUploadId).ServiceType2__c != null) { //4
                                   if(availableServiceCounter < listInsertAvailableServiceResult.size()) { //2 
                                       if(listInsertAvailableServiceResult[availableServiceCounter].isSuccess()) {
                                           AvailableBundle availableBundleWrapper2 	= mapLocationUploadId2LocationWrapper.get(locationUploadId).SupplyPoint.availableService2.AvailableBundle2 ;
                                           system.debug('AvailableBundle-availableBundleWrapper2=> ' + availableBundleWrapper2) ;
                                           if(availableBundleWrapper2 != null ) {
                                               AvailableBundle__c availableBundleObj2 	= availableBundleWrapper2.objAvailableBundle2 ;
                                               availableBundleObj2.AvailableService__c 	= listInsertAvailableServiceResult[availableServiceCounter].getId() ;
                                               listValidWrapperAvailableBundle.add(availableBundleObj2) ;
                                           }
                                           availableServiceCounter++ ;
                                       } else {
                                           mapValidLocationUpload.remove(locationUploadId) ;
                                       }
                                   }   
                               }
                           }
                        
                        supplyPointCounter++ ;
                        locationCounter++ ;
                    }
                    system.debug('LoBt_LocationImport-listValidWrapperAvailableBundle=> ' + listValidWrapperAvailableBundle) ;
                    listValidWrapperAvailableBundle = GlUt_FieldSecurity.cleanseFields(listValidWrapperAvailableBundle, false) ;
                    Database.saveResult[] listInsertAvailableBundleResult = Database.insert(listValidWrapperAvailableBundle, false) ;
                    system.debug('LoBt_LocationImport-listInsertAvailableBundleResult=> ' + listInsertAvailableBundleResult) ;
                    availableBundleCount = listInsertAvailableBundleResult.size() ;
                    system.debug('LoBt_LocationImport-availableBundleCount=> ' + availableBundleCount) ;
                }
                system.debug('LoBt_LocationImport-mapLocationUploadId2BatchError=> ' + mapLocationUploadId2BatchError) ;
                
				//*********** 6. Insert Batch Error list *********** 
				
				list<BatchError__c> listInsertBatchError = (list<BatchError__c>) GlUt_FieldSecurity.cleanseFields(mapLocationUploadId2BatchError.values(), false) ;
                system.debug('LoBt_LocationImport-listInsertBatchError=> ' + listInsertBatchError) ;                
				Database.SaveResult[] listInsertBatchErrorResult = Database.insert(listInsertBatchError) ;
				list<Id> listLocationUploadIds = new list<Id>() ;
				listLocationUploadIds.addAll(mapLocationUploadId2BatchError.keySet()) ;
                system.debug('LoBt_LocationImport-listLocationUploadIds=> ' + listLocationUploadIds) ;
				map<Id, Id> mapLocationUploadId2BatchErrorId = new map<Id, Id>() ;
				Integer batchErrorCounter = 0 ;
				for(Database.SaveResult batchErrorResult : listInsertBatchErrorResult) {
					if(batchErrorResult.isSuccess()) {
						mapLocationUploadId2BatchErrorId.put(listLocationUploadIds[batchErrorCounter], batchErrorResult.getId()) ;
					}
					batchErrorCounter ++ ;
				}
				system.debug('LoBt_LocationImport-mapLocationUploadId2BatchErrorId=> ' + mapLocationUploadId2BatchErrorId) ;	
                
				//*********** 7. Update LocationUpload record to "Processed" *********** 
				
				
                system.debug('Final-listLocationUpload=> ' + listLocationUpload);
                system.debug('Final-mapValidLocationUpload=> ' + mapValidLocationUpload);
				for(LocationUpload__c locationUpload : listLocationUpload) {
                    if(mapValidLocationUpload.containsKey(locationUpload.Id)) { //7
                        if (mapLocationUploadId2BatchErrorId.containsKey(locationUpload.Id)) {
                            locationUpload.BatchError__c = mapLocationUploadId2BatchErrorId.get(locationUpload.Id) ;
                            locationUpload.Processed__c = false ;
                        } else {
                            locationUpload.Processed__c = true ;
                        	locationUpload.BatchError__c = null ;
                        }
                    } else {
                        locationUpload.BatchError__c = mapLocationUploadId2BatchErrorId.get(locationUpload.Id) ;
                    }
                    
					listProcessedLocationUpload.add(locationUpload) ;
				}
                system.debug('LoBt_LocationImport-listProcessedLocationUpload=> ' + listProcessedLocationUpload) ;
                listProcessedLocationUpload = (list<LocationUpload__c>) GlUt_FieldSecurity.cleanseFields(listProcessedLocationUpload, false) ;
				Database.update(listProcessedLocationUpload) ;
            }
        } catch(Exception ex) {
            GlUt_Logger.logException(ex);
            GlUt_Logger.writeLogsToDatabase() ;
        }
    }
    /******************************************************************************
	@author    		Echo: Sudhir Kumar
	@date      		30 Jan 2019
	@param			List<LocationUpload__c> listLocationUpload
	@return			map<String, Bundle__c>
	@description 	"getValidBundleMap" method to Get map of LocationUpload Id => valid Bundle Id
	*******************************************************************************/
    private static map<String, Bundle__c> getValidBundleMap(LoBt_LocationImport locationImport, List<LocationUpload__c> listLocationUpload) {
        set<String> setBundleNames = new set<String>() ;
        map<String, Bundle__c> tempMapBundleName2BundleObj  = new map<String, Bundle__c>() ;
        set<String> setSupplyPointUsageTypes = new set<String>() ;	//sk
        locationImport.mapSupplyPointUsageType2Id = new map<String, String>() ;	//sk
        
        for(LocationUpload__c locUpload : listLocationUpload) {
            if(locUpload.Service1AvailableBundle__c != null) setBundleNames.add(locUpload.Service1AvailableBundle__c.trim()) ; //sk
            if(locUpload.Service2AvailableBundle__c != null) setBundleNames.add(locUpload.Service2AvailableBundle__c.trim()) ; //sk
            if(locUpload.SupplyPointUsageType__c != null) setSupplyPointUsageTypes.add(locUpload.SupplyPointUsageType__c) ;
        }
        //sk Supply Point Usage Type
        if(!setSupplyPointUsageTypes.isEmpty()) {
            for(SupplyPointUsageType__c sputObj : [SELECT Id, Name FROM SupplyPointUsageType__c WHERE Name IN: setSupplyPointUsageTypes]) {
                locationImport.mapSupplyPointUsageType2Id.put(sputObj.Name, sputObj.Id) ;
            }
        }
        if(!setBundleNames.isEmpty()) {
            list<Bundle__c> listBundle = [SELECT Id, Name, ServiceType__c, (SELECT Id, ServiceItemType__c FROM BundleItems__r) FROM Bundle__c WHERE Name IN: setBundleNames] ;
            for(Bundle__c bundle : listBundle) {
                tempMapBundleName2BundleObj.put(bundle.Name, bundle) ;
            }
        }
        return tempMapBundleName2BundleObj ;
    }
    
    /******************************************************************************
	@author    		Echo: Sudhir Kumar
	@date      		30 Jan 2019
	@param			LoBt_LocationImport locationImport, List<LocationUpload__c> listLocationUpload, list<batchError__c> listBatchError, String brqId
	@return			map<Id, LocationUpload__c>
	@description 	"getValidLocationUpload" method to Get map of valid LocationUpload
	*******************************************************************************/
    private  map<Id, LocationUpload__c> getValidLocationUpload(LoBt_LocationImport locationImport, List<LocationUpload__c> listLocationUpload) {
        map<Id, LocationUpload__c> tempMapValidLocationUpload = new map<Id, LocationUpload__c>() ;
        set<Id> setServiceIds = new set<Id>() ;
        
        for(LocationUpload__c locationUpload : listLocationUpload) {
            list<String> listMissingFields = new list<String>() ;
            Boolean isValid = true ;
            if(String.isBlank(locationUpload.City__c)) {
                isValid = false ;
                listMissingFields.add(LoBt_Constants.MISSING_CITY) ;
            }
            if(String.isBlank(locationUpload.PostalCode__c)) {
                isValid = false ;
                listMissingFields.add(LoBt_Constants.MISSING_POSTALCODE) ;
            }
            if(String.isBlank(locationUpload.State__c)) {
                isValid = false ;
                listMissingFields.add(LoBt_Constants.MISSING_STATE) ;
            }
            if(String.isBlank(locationUpload.Street__c)) {
                isValid = false ;
                listMissingFields.add(LoBt_Constants.MISSING_STREET) ;
            }
            if(String.isBlank(locationUpload.LocationType__c)) {
                isValid = false ;
                listMissingFields.add(LoBt_Constants.MISSING_LOCATION_TYPE) ;
            }
            if(locationUpload.BuildDate__c == null) {
                isValid = false ;
                listMissingFields.add(LoBt_Constants.MISSING_BUILD_DATE) ;
            }
            if(String.isBlank(locationUpload.SupplyPointUsageType__c)) {
                isValid = false ;
                listMissingFields.add(LoBt_Constants.MISSING_SUPPLYPOINT_USAGE_TYPE) ;
            }
            system.debug('isValid=> ' + isValid);
            if(isValid) {
                tempMapValidLocationUpload.put(locationUpload.Id, locationUpload) ;
            } else {
                locationImport.listBatchError.add(getBatchErrorInstance(locationImport, locationUpload.Id, LoBt_Constants.MISSING + String.join(listMissingFields, ', '))) ;
                locationImport.setInvalidLocationUpload.add(locationUpload.Id) ;
            } 
            if(locationUpload.ServiceType1__c != null) {
                setServiceIds.add(locationUpload.ServiceType1__c) ;
            }
            if(locationUpload.ServiceType2__c != null) {
                setServiceIds.add(locationUpload.ServiceType2__c) ;
            }
        }
        system.debug('setServiceIds=> ' + setServiceIds);
        system.debug('tempMapValidLocationUpload=> ' + tempMapValidLocationUpload);
        system.debug('locationImport.setInvalidLocationUpload=> ' + locationImport.setInvalidLocationUpload);
        return tempMapValidLocationUpload ;
    }
    
    /******************************************************************************
	@author    		Echo: Sudhir Kumar
	@date      		30 Jan 2019
	@param			LoBt_LocationImport locationImport, LocationUpload__c objLocationUpload
	@return			Location wrapper
	@description 	Location container class
	*******************************************************************************/
    private class Location {
        private String LocationUploadId ;
        private Location__c objLocation ;
        private SupplyPoint SupplyPoint ;
        Location(LoBt_LocationImport locationImport, LocationUpload__c objLocationUpload) {
            LocationUploadId = objLocationUpload.Id ;
            objLocation = new Location__c(BuildDate__c 			= objLocationUpload.BuildDate__c ,
                                          City__c 				= objLocationUpload.City__c ,
                                          Country__c 			= objLocationUpload.Country__c ,
                                          PostalCode__c 		= objLocationUpload.PostalCode__c ,
                                          State__c 				= objLocationUpload.State__c ,
                                          Street__c 			= objLocationUpload.Street__c ,
                                          LocationType__c		= objLocationUpload.LocationType__c ,
                                          LocationSubType__c	= objLocationUpload.LocationSubType__c ,                                                    
                                          VoidStartDate__c 		= objLocationUpload.BuildDate__c ,                                                 
                                          VoidManagementProfile__c = objLocationUpload.VoidProfile__c) ;
            SupplyPoint = new SupplyPoint(locationImport, objLocationUpload) ;    
        }
    }
    /******************************************************************************
	@author    		Echo: Sudhir Kumar
	@date      		30 Jan 2019
	@param			LoBt_LocationImport locationImport, LocationUpload__c objLocationUpload
	@return			SupplyPoint wrapper
	@description 	SupplyPoint container class
	*******************************************************************************/
    private class SupplyPoint {
        private SupplyPoint__c objSupplyPoint ;
        private AvailableService availableService1 ;
        private AvailableService availableService2 ;
        SupplyPoint(LoBt_LocationImport locationImport, LocationUpload__c objLocationUpload) {
            objSupplyPoint = new SupplyPoint__c(Measured__c = False,
                                               Geolocation__latitude__s = objLocationUpload.Geolocation__latitude__s,
                                               Geolocation__longitude__s = objLocationUpload.Geolocation__longitude__s,
                                               SpecialInstructions__c = objLocationUpload.SpecialInstructions__c,
                                               RecordTypeId = GlUt_APIConstantsSupplyPoint.STANDARD_SUPPLYPOINT_RECORDTYPEID
                                               ) ;
            if(objLocationUpload.SupplyPointUsageType__c != null && locationImport.mapSupplyPointUsageType2Id.containsKey(objLocationUpload.SupplyPointUsageType__c)) {	//sk
                objSupplyPoint.SupplyPointUsageType__c = locationImport.mapSupplyPointUsageType2Id.get(objLocationUpload.SupplyPointUsageType__c) ;
            }
            if(objLocationUpload.ServiceType1__c != null) {
                availableService1 	= new AvailableService(locationImport, objLocationUpload, true, false) ;
            }
            if(objLocationUpload.ServiceType2__c != null) {
                availableService2 	= new AvailableService(locationImport, objLocationUpload, false, true) ;
            }
        }
    }
    /******************************************************************************
	@author    		Echo: Sudhir Kumar
	@date      		30 Jan 2019
	@param			LoBt_LocationImport locationImport, LocationUpload__c objLocationUpload, Boolean service1, Boolean service2
	@return			AvailableService wrapper
	@description 	AvailableService container class
	*******************************************************************************/
    private class AvailableService {
        private AvailableService__c objAvailableService1 ;
        private AvailableService__c objAvailableService2 ;
        private AvailableBundle AvailableBundle1 ;
        private AvailableBundle AvailableBundle2 ;
        AvailableService(LoBt_LocationImport locationImport, LocationUpload__c objLocationUpload, Boolean serviceType1, Boolean serviceType2) {
			if(serviceType1) {
                objAvailableService1 				= new AvailableService__c() ;
                objAvailableService1.Active__c 		= True ;
                objAvailableService1.ServiceType__c = objLocationUpload.ServiceType1__c ;
                objAvailableService1.Division__c 	= objLocationUpload.DivisionService1__c ;
                objAvailableService1.Wholesalers__c = objLocationUpload.WholesalerService1__c ;
                objAvailableService1.Default__c 	= True ;
                
                Boolean isValidBundle = true ;
                if(objLocationUpload.Service1AvailableBundle__c != null) {	
                    if(locationImport.mapBundleName2BundleObj.containsKey(objLocationUpload.Service1AvailableBundle__c)) {
                        Bundle__c bundle = locationImport.mapBundleName2BundleObj.get(objLocationUpload.Service1AvailableBundle__c) ;
                        if(bundle != null && bundle.ServiceType__c == objLocationUpload.ServiceType1__c) {
                            AvailableBundle1 = new AvailableBundle(locationImport, objLocationUpload, bundle, serviceType1, serviceType2) ;
                        } else {
                            isValidBundle = false ;
                        }
                    } else {
                        isValidBundle = false ;
                    }
                }
                if(!isValidBundle) {
                    //Batch error
                    locationImport.listBatchError.add(getBatchErrorInstance(locationImport, objLocationUpload.Id, System.Label.LoBt_InvalidBundle1Error)) ;
                    locationImport.setInvalidLocationUpload.add(objLocationUpload.Id) ; 
                }
           }
           if(serviceType2) {
               objAvailableService2 					= new AvailableService__c() ;
               objAvailableService2.Active__c 		= True ;
               objAvailableService2.ServiceType__c 	= objLocationUpload.ServiceType2__c ;
               objAvailableService2.Division__c 		= objLocationUpload.DivisionService2__c ;
               objAvailableService2.Wholesalers__c 	= objLocationUpload.WholesalerService2__c ;
               objAvailableService2.Default__c 		= True ;
               
               Boolean isValidBundle = true ;
               if(objLocationUpload.Service2AvailableBundle__c != null) {	
                   if(locationImport.mapBundleName2BundleObj.containsKey(objLocationUpload.Service2AvailableBundle__c)) {
                       Bundle__c bundle = locationImport.mapBundleName2BundleObj.get(objLocationUpload.Service2AvailableBundle__c) ;
                       if(bundle != null && bundle.ServiceType__c == objLocationUpload.ServiceType2__c) {
                           AvailableBundle2 = new AvailableBundle(locationImport, objLocationUpload, bundle, serviceType1, serviceType2) ;
                       }  else {
                           isValidBundle = false ;
                       }
                   } else {
                       isValidBundle = false ;
                   }
               }  
               if(!isValidBundle)  {
                   //Batch error
                   locationImport.listBatchError.add(getBatchErrorInstance(locationImport, objLocationUpload.Id, System.Label.LoBt_InvalidBundle2Error)) ;
                   locationImport.setInvalidLocationUpload.add(objLocationUpload.Id) ; 
               }
            }
        }
    }
    /******************************************************************************
	@author    		Echo: Sudhir Kumar
	@date      		30 Jan 2019
	@param			LoBt_LocationImport locationImport, LocationUpload__c objLocationUpload, Bundle__c bundle
	@return			AvailableBundle wrapper
	@description 	AvailableBundle container class
	*******************************************************************************/
    private class AvailableBundle {
        private AvailableBundle__c objAvailableBundle1 ;
        private AvailableBundle__c objAvailableBundle2 ;
        //AvailableServiceItems - This will be created thru "GlUt_AvailableBundleHandler"
        AvailableBundle(LoBt_LocationImport locationImport, LocationUpload__c objLocationUpload, Bundle__c bundle, Boolean serviceType1, Boolean serviceType2) {
            if(serviceType1) {
                objAvailableBundle1 = new AvailableBundle__c() ;
                objAvailableBundle1.Bundle__c = bundle.Id ;
                objAvailableBundle1.LastBundleChangeDate__c = objLocationUpload.BuildDate__c ;
            }
            if(serviceType2) {
                objAvailableBundle2 = new AvailableBundle__c() ;
                objAvailableBundle2.Bundle__c = bundle.Id ;
                objAvailableBundle2.LastBundleChangeDate__c = objLocationUpload.BuildDate__c ;
            }
        }
    }
    
	/******************************************************************************
	@author    		Echo: Sudhir Kumar
	@date      		30 Jan 2019
	@param			LocationUpload__c objLocationUpload, String batchErrorMessage, String brqId
	@return			AvailableServiceItem wrapper
	@description 	"getBatchErrorInstance" method return BatchError__c instance
	*******************************************************************************/
    private static BatchError__c getBatchErrorInstance(LoBt_LocationImport locationImport, Id objLocationUploadId, String batchErrorMessage) {
        BatchError__c batchErrorObj = new BatchError__c(BatchRequestQueue__c = locationImport.batchRequestQueueId, ErrorDetails__c = batchErrorMessage,
                                                        BatchRequestOperation__c= LoBt_Constants.BATCH_REQUEST_OPERATION_TYPE,
                                                        BatchRequestType__c = LoBt_Constants.LOCATION_IMPORT_LIBRARY,OperatingRecordId__c = objLocationUploadId) ;
        locationImport.mapLocationUploadId2BatchError.put(objLocationUploadId, batchErrorObj) ;
        return batchErrorObj ;
    }
    /******************************************************************************
	@author    		Echo: Sudhir Kumar
	@date      		25 Jan 2019
	@param			Database.BatchableContext bc
	@return			Database.QueryLocator
	@description 	method to finish batch process
	*******************************************************************************/
    
    global void finish(Database.BatchableContext bc) {
        //1. Write the import file report to the Location Import Content Library, the report should include the total number of: - 
        //		* Location Records Created. 
        //		* Supply Point Records Created. 
        //		* Available Service Records Created 
        //		* Available Bundle Records Created 
        //		* The total number of Errors.
        //2. Create ContentDocumentLink records to link the file to the Batch Request Queue 
        //3. Update the Batch Request Queue Status with ‘Completed’.
        try {
            String filename = LoBt_Constants.LOCATION_IMPORT_LIBRARY + System.now().format(GlUt_AWSConstants.DATETIMEFORMAT) + GlUt_AWSConstants.REPORT_FILE_EXTENSION;
            // create the report file
            String report 	= 'Number of Locations created: ' + String.valueOf(numLocationsCreated) + CRLF ;
            report 			+= 'Number of Supply Point processed: ' + String.valueOf(supplyPointCount) + CRLF ;
            report 			+= 'Number of Available Service processed: ' + String.valueOf(availableServiceCount) + CRLF ;
            report 			+= 'Number of Available Bundle processed: ' + String.valueOf(availableBundleCount) + CRLF ;
            report 			+= 'Number of Batch Errors: ' + String.valueOf(listBatchError.size()) + CRLF ;
            // write the report file and link it to the Batch Request Queue
            Id reportId ;           
            if(batchRequestQueueId != null) {  
                reportId = GlUt_ContentDocument.saveLinkedDocument(batchRequestQueueId, LoBt_Constants.LOCATION_IMPORT_LIBRARY, filename, filename, GlUt_AWSConstants.SHARE_TYPE, Blob.valueOf(report));
                BatchRequestQueue__c brq = [SELECT Id, Status__c FROM BatchRequestQueue__c WHERE Id =: batchRequestQueueId];
                    if(brq != null && brq.Status__c != Label.GlUt_BatchRequestQueueStatusErrors){
                        brq.Status__c 	= Label.GlUt_BatchRequestQueueStatusCompleted;
                        brq 			= (BatchRequestQueue__c) GlUt_FieldSecurity.cleanseFields(brq, false); 
                        update brq;
                    }
            }
        } catch(Exception ex) {
            GlUt_Logger.writeLogsToDatabase() ;
        }
    }
}