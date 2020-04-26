/***************************************************************************************************
@author        Echo : Dependra Singh
@date          29-Nov-2017
@description:  This is helper class used by SupplyPointDevice object trigger  
@group         TriggerHelper
Revision(s)    Echo: Sudhir Kumar -> AT-3076 (Core 7b): Update Supply Point Device Trigger Handler  on Date Change
Revision(s)	   Echo: Sudhir Kumar -> AT-3754, AT-3747 - Core CC
*******************************************************************************************************/
public with sharing class GlUt_SupplyPointDeviceHandler extends GlUt_TriggerHandlerBase {

    // Variable declaration
    private static final String CLASS_NAME = 'GlUt_SupplyPointDeviceHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private map<Id, Boolean> mapSpdId2IsChangedByStartDate ;
    private map<Id, Boolean> mapSpdId2IsChangedByEndDate ;
    private map<Id, SupplyPointDevice__c> mapOldSpdId2SpdObj ;
    private map<Id, list<SupplyPointDevice__c>> mapSupplyPointId2ListNewSpdObj ;
    private map<Id, list<SupplyPointDevice__c>> mapSupplyPointId2ListOldSpdObj ;
    // End variable declaration
    
    /**********************************************************************************************
	@author        Echo: Dependra Singh
	@date          29-Nov-2017
	@param         GlUt_TriggerHandlerObj inputParam
	@return        void
	@description   This method is used to invoke method from trigger
	Revision(s)    Echo: Sudhir Kumar -> AT-3076(Core 7b): Update Supply Point Device Trigger Handler
    Revision(s)    Echo: Amit Kumar -> AT-4508(AU2): Update Supply Point Device Trigger Handler
	**********************************************************************************************/
    public override void MainEntry(GlUt_TriggerHandlerObj inputParam) {
        try {
            
            if (inputParam.isInsert && inputParam.isBefore) {
                if(GlUt_RegionUtility.getAURegionCustomSetting())
                    validDeviceType(inputParam.newlist,null); //(AT-4508)
            }
            if (inputParam.isInsert && inputParam.isAfter) {
            	//processAvailableBundles(inputParam.newMap);
                system.debug('After INSERT Context-Calling processSupplyPointDeviceDateChange=> ');
              	processSupplyPointDeviceDateChange(inputParam.newmap, inputParam.oldmap) ;	// AT-3076
                eligibleForBudgetPlan(inputParam.newlist, inputParam.oldmap);  // AT-3283
            }
            if (inputParam.isUpdate && inputParam.isBefore) {
                validateDeviceRemoval(inputParam.newlist, inputParam.oldmap);
                if(GlUt_RegionUtility.getAURegionCustomSetting())
                    validDeviceType(inputParam.newlist, inputParam.oldmap); //(AT-4508)
            }
            if (inputParam.isUpdate && inputParam.isAfter) {
            	//processAvailableBundles(inputParam.newMap);
                system.debug('After UPDATE Context-Calling processSupplyPointDeviceDateChange=> ');
                processSupplyPointDeviceDateChange(inputParam.newmap, inputParam.oldmap) ;	// AT-3076
                eligibleForBudgetPlan(inputParam.newlist, inputParam.oldmap); // AT-3283
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

        } finally {
            //Reset the active function to null in case this class was first in stack
            //this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();
        }
        
    }
	
    /**********************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-July-2018
    @param         set<Id> setSupplyPointIds
    @return        map<Id, list<AvailableBundle__c>>
    @description   AT-3076: This method returns MapSupplyPointId2ListAvailableBundleObj - In case of New SPD
    **********************************************************************************************/
    map<Id, AvailableBundle__c> mapAvailableBundleId2AvailableBundle ;
    private map<Id, list<AvailableBundle__c>> getMapSupplyPointId2ListAvailableBundleObj(set<Id> setSupplyPointIds) {		
        	map<Id, list<AvailableBundle__c>> mapSupplyPointId2ListAvailableBundleObj ;
        	system.debug('setSupplyPointIds=> ' + setSupplyPointIds);
            if(setSupplyPointIds != null && !setSupplyPointIds.isEmpty()) {
                mapSupplyPointId2ListAvailableBundleObj = new map<Id, list<AvailableBundle__c>>() ;
                mapAvailableBundleId2AvailableBundle = new map<Id, AvailableBundle__c>() ;
                //Get related Available Bundle object on a Supply Point
                for(AvailableBundle__c abObj : [SELECT Id, Bundle__c, 
                                                Bundle__r.Name,  //AT-3174
                                                LastBundleChangeDate__c, AvailableService__r.SupplyPoint__c FROM AvailableBundle__c 
                                                WHERE AvailableService__r.SupplyPoint__c IN: setSupplyPointIds]) {
                	if(!mapSupplyPointId2ListAvailableBundleObj.containsKey(abObj.AvailableService__r.SupplyPoint__c)) {
                        mapSupplyPointId2ListAvailableBundleObj.put(abObj.AvailableService__r.SupplyPoint__c, new list<AvailableBundle__c> {abObj}) ;
                    } else {
                        mapSupplyPointId2ListAvailableBundleObj.get(abObj.AvailableService__r.SupplyPoint__c).add(abObj) ;
                    }	
                    mapAvailableBundleId2AvailableBundle.put(abObj.Id,abObj) ;	                                
                }
            }
            system.debug(DEBUG + 'mapSupplyPointId2ListAvailableBundleObj=> ' + mapSupplyPointId2ListAvailableBundleObj) ;
        	system.debug(DEBUG + 'getMapAvailableBundleId2AvailableBundle=> ' + mapAvailableBundleId2AvailableBundle) ;
            return mapSupplyPointId2ListAvailableBundleObj ;
    }
    
    /**********************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-July-2018
    @param         set<Id> setSpdIds
    @return        map<Id, set<Id>>
    @description   AT-3076: This method returns MapSpdId2SetAvailableBundleId - In case of existing SPD
    **********************************************************************************************/
    
    private map<Id, set<Id>> getMapSpdId2SetAvailableBundleId(set<Id> setSpdIds) {		
        map<Id, set<Id>> mapSpdId2SetAvailableBundleId ;
        if(setSpdIds != null && !setSpdIds.isEmpty()) {
            system.debug(DEBUG + 'mapSpdId2IsChangedByEndDate=> ' + mapSpdId2IsChangedByEndDate) ;
            system.debug(DEBUG + 'mapSpdId2IsChangedByStartDate=> ' + mapSpdId2IsChangedByStartDate) ;
            mapSpdId2SetAvailableBundleId = new map<Id, set<Id>>() ;
            for(AvailableServiceItem__c asiObj : [SELECT Id, AvailableBundle__c, SupplyPointDevice__c, StartDate__c, EndDate__c FROM AvailableServiceItem__c
                                                  WHERE SupplyPointDevice__c IN: setSpdIds]) {
            	//By SPD start date**
            	system.debug(DEBUG + 'asiObj=> ' + asiObj) ;                                   
                if(asiObj.SupplyPointDevice__c != null && mapSpdId2IsChangedByStartDate.containsKey(asiObj.SupplyPointDevice__c)) {
                    SupplyPointDevice__c spdObj = mapOldSpdId2SpdObj.get(asiObj.SupplyPointDevice__c) ;
                    //For each Available Service Item associated with the Supply Point Device where Start Date < Supply Point Device Installation Date 
                    //And End Date > Supply Point Device Installation Date
                    if(asiObj.SupplyPointDevice__c != null && asiObj.StartDate__c < spdObj.InstallationDate__c && (asiObj.EndDate__c == null || asiObj.EndDate__c > spdObj.InstallationDate__c)) {
                        if(!mapSpdId2SetAvailableBundleId.containsKey(asiObj.SupplyPointDevice__c)) {
                            mapSpdId2SetAvailableBundleId.put(asiObj.SupplyPointDevice__c, new set<Id> {asiObj.AvailableBundle__c}) ;
                        } else {
                            mapSpdId2SetAvailableBundleId.get(asiObj.SupplyPointDevice__c).add(asiObj.AvailableBundle__c) ;
                        }
                    }
                }	
                //By SPD end date**
                if(asiObj.SupplyPointDevice__c != null && mapSpdId2IsChangedByEndDate.containsKey(asiObj.SupplyPointDevice__c)) {
                    SupplyPointDevice__c spdObj = mapOldSpdId2SpdObj.get(asiObj.SupplyPointDevice__c) ;
                    //For each Available Service Item associated with the Supply Point Device where Installation Date < Supply Point Device  Removal Date 
                    //And End Date = NULL or  End Date > Supply Point Device Removal Date
                    if(asiObj.SupplyPointDevice__c != null && asiObj.StartDate__c < spdObj.RemovalDate__c && (asiObj.EndDate__c == null || asiObj.EndDate__c  > spdObj.RemovalDate__c)) {
                        if(!mapSpdId2SetAvailableBundleId.containsKey(asiObj.SupplyPointDevice__c)) {
                            mapSpdId2SetAvailableBundleId.put(asiObj.SupplyPointDevice__c, new set<Id> {asiObj.AvailableBundle__c}) ;
                        } else {
                            mapSpdId2SetAvailableBundleId.get(asiObj.SupplyPointDevice__c).add(asiObj.AvailableBundle__c) ;
                        }
                    }
                }	                                     
            }
        }
        system.debug(DEBUG + 'mapSpdId2SetAvailableBundleId=> ' + mapSpdId2SetAvailableBundleId) ;
        return mapSpdId2SetAvailableBundleId ;
    }
    
    /**********************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          16-July-2018
    @param         map<Id, SObject> mapNewSupplyPointDevice, map<Id, SObject> mapOldSupplyPointDevice
    @return        void
    @description   AT-3076: This method is used to process Supply Point Device if the Supply Point Device End Date has changed, 
				            set the effectiveDate to the Supply Point Device End Date
    **********************************************************************************************/
    
    
    public void processSupplyPointDeviceDateChange(map<Id, SObject> mapNewSupplyPointDevice, map<Id, SObject> mapOldSupplyPointDevice) {
        system.debug(DEBUG + ' CALLED processSupplyPointDeviceDateChange method=> ');
        system.debug(DEBUG + 'processSupplyPointDeviceDateChange-mapNewSupplyPointDevice=> ' + mapNewSupplyPointDevice);
        system.debug(DEBUG + 'processSupplyPointDeviceDateChange-mapOldSupplyPointDevice=> ' + mapOldSupplyPointDevice);
        
        mapOldSpdId2SpdObj = new map<Id, SupplyPointDevice__c>() ;
        mapSupplyPointId2ListNewSpdObj = new map<Id, list<SupplyPointDevice__c>>() ;
        mapSupplyPointId2ListOldSpdObj = new map<Id, list<SupplyPointDevice__c>>() ;
        
        mapSpdId2IsChangedByStartDate = new map<Id, Boolean>() ;
        mapSpdId2IsChangedByEndDate = new map<Id, Boolean>() ;
        
        
        List<SupplyPointDevice__c> listNewSupplyPointDevice = (List<SupplyPointDevice__c>) mapNewSupplyPointDevice.values() ;
        map<Id, GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper> mapOfBundlesToProcess = new  map<Id, GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper>() ;
        
        if(mapOldSupplyPointDevice != null) {		// After update context - "Old* SupplyPointDevice records"
            for(SupplyPointDevice__c supplyPointDevice : listNewSupplyPointDevice) {
                if(!mapSupplyPointId2ListOldSpdObj.containsKey(supplyPointDevice.SupplyPoint__c)) {
                        mapSupplyPointId2ListOldSpdObj.put(supplyPointDevice.SupplyPoint__c, new list<SupplyPointDevice__c> {supplyPointDevice}) ;
                    } else {
                        mapSupplyPointId2ListOldSpdObj.get(supplyPointDevice.SupplyPoint__c).add(supplyPointDevice) ;
                    }
                //Supply Point Device End Date has changed
                if(supplyPointDevice.RemovalDate__c != ((SupplyPointDevice__c) mapOldSupplyPointDevice.get(supplyPointDevice.Id)).RemovalDate__c) {
                    mapOldSpdId2SpdObj.put(supplyPointDevice.Id, supplyPointDevice) ;
                    mapSpdId2IsChangedByEndDate.put(supplyPointDevice.Id, true) ;
                }
                //Supply Point Device Start Date has changed and the End Date has not
                if(supplyPointDevice.InstallationDate__c != ((SupplyPointDevice__c) mapOldSupplyPointDevice.get(supplyPointDevice.Id)).InstallationDate__c
                  	&& supplyPointDevice.RemovalDate__c == ((SupplyPointDevice__c) mapOldSupplyPointDevice.get(supplyPointDevice.Id)).RemovalDate__c) {
                       mapOldSpdId2SpdObj.put(supplyPointDevice.Id, supplyPointDevice) ;
                       mapSpdId2IsChangedByStartDate.put(supplyPointDevice.Id, true) ;
                  }
            }
        } else {	// After insert context - "New* SupplyPointDevice records"
            for(SupplyPointDevice__c supplyPointDevice : listNewSupplyPointDevice) {
                    if(!mapSupplyPointId2ListNewSpdObj.containsKey(supplyPointDevice.SupplyPoint__c)) {
                        mapSupplyPointId2ListNewSpdObj.put(supplyPointDevice.SupplyPoint__c, new list<SupplyPointDevice__c> {supplyPointDevice}) ;
                    } else {
                        mapSupplyPointId2ListNewSpdObj.get(supplyPointDevice.SupplyPoint__c).add(supplyPointDevice) ;
                    }
                mapSpdId2IsChangedByStartDate.put(supplyPointDevice.Id, true) ;
            }
        }
        system.debug(DEBUG + 'processSupplyPointDeviceDateChange-OLD-mapOldSpdId2SpdObj=> ' + mapOldSpdId2SpdObj);
        system.debug(DEBUG + 'processSupplyPointDeviceDateChange-NEW-mapSupplyPointId2ListNewSpdObj=> ' + mapSupplyPointId2ListNewSpdObj);
        system.debug(DEBUG + 'processSupplyPointDeviceDateChange--mapSpdId2IsChangedByEndDate=> ' + mapSpdId2IsChangedByEndDate);
        system.debug(DEBUG + 'processSupplyPointDeviceDateChange-mapSpdId2IsChangedByStartDate=> ' + mapSpdId2IsChangedByStartDate);
        
        //process new Supply Point Devices
        if(!mapSupplyPointId2ListNewSpdObj.isEmpty()) {
            map<Id, list<AvailableBundle__c>> mapSupplyPointId2ListAvailableBundleObj = getMapSupplyPointId2ListAvailableBundleObj(mapSupplyPointId2ListNewSpdObj.keySet()) ;
            system.debug(DEBUG + 'processSupplyPointDeviceDateChange-mapSupplyPointId2ListAvailableBundleObj=> ' + mapSupplyPointId2ListAvailableBundleObj);
            if(mapSupplyPointId2ListAvailableBundleObj != null && !mapSupplyPointId2ListAvailableBundleObj.isEmpty()) {
                //1. for each Supply Point
                for(String supplyPointId : mapSupplyPointId2ListNewSpdObj.keySet()) {
                    list<SupplyPointDevice__c> listSupplyPointDevice = mapSupplyPointId2ListNewSpdObj.get(supplyPointId) ;
                    system.debug(DEBUG + 'processSupplyPointDeviceDateChange-listSupplyPointDevice=> ' + listSupplyPointDevice);
                    list<AvailableBundle__c> listAvailableBundle = mapSupplyPointId2ListAvailableBundleObj.get(supplyPointId) ;
                    system.debug(DEBUG + 'processSupplyPointDeviceDateChange-listAvailableBundle=> ' + listAvailableBundle);
                    if(listSupplyPointDevice != null && !listSupplyPointDevice.isEmpty()) {
                        //2. for each Supply Point Device
                        for(SupplyPointDevice__c spd : listSupplyPointDevice) {
                            if(listAvailableBundle != null && !listAvailableBundle.isEmpty()) {
                                ////3. for each Available Bundle
                                for(AvailableBundle__c ab : listAvailableBundle) {
                                    //create a new Instance of GlUt_ProcessAvailableBundleWrapper with the Available Bundle and Supply Point Device and effectiveDate parameters set
                                    GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper availableBundleWrapper = new GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper() ;
                                    availableBundleWrapper.availableBundle = ab ;
                                    availableBundleWrapper.supplyPointDevice = spd ;
                                    availableBundleWrapper.effectiveDate = spd.InstallationDate__c ;  // set the effectiveDate to the Supply Point Device End Date
                                    //Add the instance to mapOfBundlesToProcess
                                    mapOfBundlesToProcess.put(ab.Id, availableBundleWrapper) ;
                                    system.debug(DEBUG + 'processSupplyPointDeviceDateChange-NEW-mapOfBundlesToProcess=> ' + mapOfBundlesToProcess);
                                }
                            }
                        }
                    }
                }
            }
        }
        
		//process old/existing Supply Point Devices
        if(!mapOldSpdId2SpdObj.isEmpty()) {
            system.debug(DEBUG + 'processSupplyPointDeviceDateChange-mapOldSpdId2SpdObj=> ' + mapOldSpdId2SpdObj);
            system.debug(DEBUG + 'processSupplyPointDeviceDateChange-mapSpdId2IsChangedByStartDate=> ' + mapSpdId2IsChangedByStartDate);
            system.debug(DEBUG + 'processSupplyPointDeviceDateChange-mapSpdId2IsChangedByEndDate=> ' + mapSpdId2IsChangedByEndDate);
            map<Id, set<Id>> mapSpdId2SetAvailableBundleId =  getMapSpdId2SetAvailableBundleId(mapOldSpdId2SpdObj.keySet()) ;
            system.debug(DEBUG + 'processSupplyPointDeviceDateChange-mapSpdId2SetAvailableBundleId=> ' + mapSpdId2SetAvailableBundleId);
            if(!mapSupplyPointId2ListOldSpdObj.isEmpty()) {
            	map<Id, list<AvailableBundle__c>> mapSupplyPointId2ListAvailableBundleObj = getMapSupplyPointId2ListAvailableBundleObj(mapSupplyPointId2ListOldSpdObj.keySet()) ;
            }
            system.debug(DEBUG + 'processSupplyPointDeviceDateChange-mapAvailableBundleId2AvailableBundle=> ' + mapAvailableBundleId2AvailableBundle);
            if(mapSpdId2SetAvailableBundleId != null && !mapSpdId2SetAvailableBundleId.isEmpty()) {
                for(String spdId : mapSpdId2SetAvailableBundleId.keySet()) {
                    set<Id> setAvailableBundleId = mapSpdId2SetAvailableBundleId.get(spdId) ;
                    system.debug(DEBUG + 'processSupplyPointDeviceDateChange-setAvailableBundleId=> ' + setAvailableBundleId);
                    if(setAvailableBundleId != null && !setAvailableBundleId.isEmpty()) {
                        for(String abId : setAvailableBundleId) {
                            AvailableBundle__c ab = mapAvailableBundleId2AvailableBundle != null && mapAvailableBundleId2AvailableBundle.containsKey(abId) 
                                																  ? mapAvailableBundleId2AvailableBundle.get(abId) : null;
                            //create a new Instance of GlUt_ProcessAvailableBundleWrapper with the Available Bundle and Supply Point Device and effectiveDate parameters set
                            GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper availableBundleWrapper = new GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper() ;
                            availableBundleWrapper.availableBundle = ab ;
                            availableBundleWrapper.supplyPointDevice = mapOldSpdId2SpdObj.get(spdId) ;
                            // If the Supply Point Device Removal Date has changed, set the effectiveDate to the Supply Point Device Removal Date
                            if(mapSpdId2IsChangedByEndDate.containsKey(spdId)) {
                                availableBundleWrapper.effectiveDate = mapOldSpdId2SpdObj.get(spdId).RemovalDate__c ;		
                            }
                            //If the Supply Point Device Installation Date has changed and the Removal Date has not, 
                            //	set the effectiveDate to the Supply Point Device Installation Date
                            if(mapSpdId2IsChangedByStartDate.containsKey(spdId)) {
                                availableBundleWrapper.effectiveDate = mapOldSpdId2SpdObj.get(spdId).InstallationDate__c ;
                            }
                            //Add the instance to mapOfBundlesToProcess
                            mapOfBundlesToProcess.put(ab.Id, availableBundleWrapper) ;
                            system.debug(DEBUG + 'processSupplyPointDeviceDateChange-OLD-mapOfBundlesToProcess=> ' + mapOfBundlesToProcess);
                        }
                    }
                }
            }
        }
        
        system.debug(DEBUG + 'processSupplyPointDeviceDateChange-mapOfBundlesToProcess=> ' + mapOfBundlesToProcess);
        
        //Now, call the GlUt_ProcessAvailableBundle class passing mapOfBundlesToProcess
        if(!mapOfBundlesToProcess.isEmpty()) {
            GlUt_ProcessAvailableBundle.processAvailableBundleChange(mapOfBundlesToProcess) ;
        }
    }
  
    
    /**********************************************************************************************
	@author        Echo: Vivek Sethi  AT-3140
	@date          12-July-2018
	@param         List<SupplyPointDevice__c> newlist
	@return        void
	@description   This method is used to validate Agreed Volume for a Device is available for bill TE so that TE bill can be calculated
	**********************************************************************************************/
    public void validateDeviceRemoval(List<SupplyPointDevice__c> newlist , Map <ID, SObject > oldMap) {
        
        Date oldRemovalDate;
        List<Id> sPDFinalTEList =  new List<Id>();
        List<SupplyPointDevice__c> sPDFinalList =  new List<SupplyPointDevice__c>(); // AT-3283
        List<SupplyPointDevice__c> uncheckEligibleForBudgetPlanList =  new List<SupplyPointDevice__c>();
        Map<Id,Id> serviceToSPDMap = new Map<Id, Id>();
        Map<Id,Id>  serviceItemtoSPDMap  = new Map<Id, Id>();
        Map<Id, Id> supplyPointToSPDMap = new Map<Id, Id>();
        Map<Id, Id> sPDToAgreedVolumeMap = new Map<Id, Id>();
        List<SupplyPointDevice__c> checkEligibleForBudgetPlanResetList =  new List<SupplyPointDevice__c>();   // AT-3283 
      
        for(SupplyPointDevice__c sPDObj : newlist) {
            oldRemovalDate = ((SupplyPointDevice__c)oldMap.get(sPDObj.id)).RemovalDate__c; 
            //Validate if TE Device is checked and removal date is changed from null to some value for the updated SPD record.
            if (sPDObj.TEDevice__c == True && oldRemovalDate == null &&  (sPDObj.RemovalDate__c != oldRemovalDate))
                sPDFinalTEList.add(sPDObj.Id);
            if(sPDObj.TEDevice__c == False && oldRemovalDate == null &&  (sPDObj.RemovalDate__c != oldRemovalDate))   // AT-3283
                sPDFinalList.add(sPDObj);  										     								 // AT-3283
        }
        if(sPDFinalTEList != null) {
            for(SupplyPointDevice__c sPDObj : [Select Id, SupplyPoint__c from SupplyPointDevice__c 
                                               where Id in:sPDFinalTEList]) 
            {
                supplyPointToSPDMap.put(sPDObj.SupplyPoint__c , sPDObj.Id);
            }
            
            if(!supplyPointToSPDMap.isEmpty()) {
                //find the Service record with the 'Trade Effluent' ServiceType.Name record.
                for(service__c serviceObj :  [Select Id , supplyPoint__c  from service__c 
                                              where supplyPoint__c in: supplyPointToSPDMap.keySet() 
                                              AND ServiceType__r.Name =: GlUt_Constants.TESERVICELBL]) 
                {
                    serviceToSPDMap.put(serviceObj.Id,supplyPointToSPDMap.get(serviceObj.supplyPoint__c));
                }
                
                if(!serviceToSPDMap.isEmpty()) {
                    for(ServiceItem__c serviceItemObj :  [Select Id, Service__c, DischargeAgreement__c  from serviceItem__c 
                                                          WHERE  Service__c  IN  : serviceToSPDMap.keySet()])
                    {
                        serviceItemtoSPDMap.put(serviceItemObj.DischargeAgreement__c,serviceToSPDMap.get(serviceItemObj.Service__c));
                    }
                }
                if(!serviceItemtoSPDMap.isEmpty()) {
                    for(AgreedVolume__c agreedVolumeObj : [select Id, DischargeAgreement__c from AgreedVolume__c 
                                                           where DischargeAgreement__c in: serviceItemtoSPDMap.keySet()
                                                           and (EndDate__c =: null or EndDate__c >: System.today())
                                                           and AgreedVolume__c >: 0.00])
                    {
                        sPDToAgreedVolumeMap.put(serviceItemtoSPDMap.get(agreedVolumeObj.DischargeAgreement__c), agreedVolumeObj.Id);
                    }
                    for(SupplyPointDevice__c sPDObj : newlist) {
                        if(!sPDToAgreedVolumeMap.containsKey(sPDObj.Id))     //You cannot unlink this device without the Agreed Volume on the Discharge Agreement
                            sPDObj.addError(system.label.GlUt_SPDAgreedVolumeError);
                        else   // AT-3283
                            uncheckEligibleForBudgetPlanList.add(sPDObj);   // AT-3283
                    }

                    if(uncheckEligibleForBudgetPlanList != null)    // AT-3283
                        uncheckEligibleForBudgetPlanOnContract(uncheckEligibleForBudgetPlanList);   // AT-3283
                    
                }
            }
        }
        if(sPDFinalList != null) {
            uncheckEligibleForBudgetPlanOnContract(sPDFinalList);
        }
    }
    
    /**********************************************************************************************
	@author        Echo: Vivek Sethi  AT-3283
	@date          12-July-2018
	@param         List<SupplyPointDevice__c> newlist
	@return        void
	@description   if there is any active Supply Point Devices from the Supply Points then set "Eligible for Budget plan" to true. 
	**********************************************************************************************/
    public void eligibleForBudgetPlan(List<SupplyPointDevice__c> newlist , Map <ID, SObject > oldMap) {
        
        Boolean sPDActive;   
        List<Id> supplyPointList =  new List<Id>();
        Set<Id> contractSet =  new Set<Id>();
        List<BillingContract__c> eligibleForBudgetPlanList = new List<BillingContract__c>();
        List<Id> measuredSupplyPointList =  new List<Id>();
        
        for(SupplyPointDevice__c sPDObj : newlist) {
            if(oldMap != null)
                sPDActive = ((SupplyPointDevice__c)oldMap.get(sPDObj.Id)).Active__c; 
            // Check if any Supply Point Device is active. 
            if ((oldMap != null && sPDObj.Active__c == True && sPDObj.Active__c != sPDActive && sPDObj.SupplyPoint__c != null) || (oldMap == null && sPDObj.Active__c == True && sPDObj.SupplyPoint__c != null))
                supplyPointList.add(sPDObj.SupplyPoint__c);
        }
        
        //Retrieving Measured Supply Point
        if(supplyPointList != null && !supplyPointList.isEmpty()) {
            for(SupplyPoint__c sPObj : [SELECT Id FROM SupplyPoint__c WHERE Id IN: supplyPointList AND Measured__c = TRUE]) {
                measuredSupplyPointList.add(sPObj.Id);  
            }
        }
        
        //Retrieving active Services 
        if(measuredSupplyPointList != null && !measuredSupplyPointList.isEmpty()) {
            for(Service__c serviceObj : [SELECT Id, BillingContract__c FROM Service__c WHERE SupplyPoint__c IN: measuredSupplyPointList 
                                         AND (ServiceEndDate__c = NULL OR ServiceEndDate__c >=: System.today())])
            {
                contractSet.add(serviceObj.BillingContract__c);
            }
        }
        
       //Check if there is any active Supply Point Devices from the above Supply Points. If Yes, set "Eligible for Budget plan" to true. 
        if(contractSet != null && !contractSet.isEmpty()) {
            for(BillingContract__c contractObj : [SELECT Id, EligibleforBudgetPlan__c FROM BillingContract__c WHERE Id IN: contractSet]) {
                if(contractObj.EligibleforBudgetPlan__c == false)  {
                    contractObj.EligibleforBudgetPlan__c  = true;
                    eligibleForBudgetPlanList.add(contractObj);
                }
            }
        }
        if(eligibleForBudgetPlanList != null && !eligibleForBudgetPlanList.isEmpty()){
            eligibleForBudgetPlanList = (List<BillingContract__c>) GlUt_FieldSecurity.cleanseFields(eligibleForBudgetPlanList, false);
            update eligibleForBudgetPlanList;
        }
            
    }
    
    /**********************************************************************************************
	@author        Echo: Vivek Sethi  AT-3283
	@date          12-July-2018
	@param         List<SupplyPointDevice__c> newlist

	@description   If Supply Point Device is removed and if there's any other active supply point device on the contract, if not, set "Eligible for Budget plan" on contract to false. 
	**********************************************************************************************/
    public void uncheckEligibleForBudgetPlanOnContract(List<SupplyPointDevice__c> supplyPointDeviceList ) {
       
        List<Id> supplyPointList = new List<Id>();
        Set<Id> billingContractSet = new Set<Id>();
        List<Id> contractEligibleForBudgPlanList = new List<Id>();
        Map<Id,Id> serviceSP2ContractMap = new Map<Id,Id>();
        Map<Id,Id> serviceMeasuredSP2ContractMap = new Map<Id,Id>();
        List<BillingContract__c> billingContractBPFlagResetList = new List<BillingContract__c>();
        
        for(SupplyPointDevice__c sPDObj : supplyPointDeviceList) {
            if(sPDObj.SupplyPoint__c != null)
                supplyPointList.add(sPDObj.SupplyPoint__c);
        }
        //Retrieving Billing Contract from its Active Service using Supply Point
        if(supplyPointList != null && !supplyPointList.isEmpty()) {
            for(service__c serviceObj :  [SELECT Id ,  supplyPoint__c ,BillingContract__c 
                                          FROM service__c 
                                          WHERE supplyPoint__c IN: supplyPointList
                                          AND (ServiceEndDate__c = NULL OR ServiceEndDate__c >=: System.today())]) 
            {
                billingContractSet.add(serviceObj.BillingContract__c);
            } 
        }
        //Retrieving all the other Active Services on that Billing Contract
        if(billingContractSet != null && !billingContractSet.isEmpty()) {
            for(service__c serviceObj :  [SELECT Id ,  supplyPoint__c ,BillingContract__c 
                                          FROM service__c 
                                          WHERE BillingContract__c in: billingContractSet 
                                          AND  supplyPoint__c NOT IN: supplyPointList
                                          AND (ServiceEndDate__c = NULL OR ServiceEndDate__c >=: System.today())]) 
            {
                serviceSP2ContractMap.put(serviceObj.SupplyPoint__c,serviceObj.BillingContract__c);                 
            } 
        }
        //Retrieving all the measured linked Supply Points from the above Services
        if(!serviceSP2ContractMap.isEmpty()) {
            for(SupplyPoint__c supplyPointObj : [SELECT Id 
                                                 FROM SupplyPoint__c 
                                                 WHERE Measured__c = TRUE 
                                                 AND Id IN : serviceSP2ContractMap.keySet()]) 
            {
                if(serviceSP2ContractMap.containsKey(supplyPointObj.Id)) 
                    serviceMeasuredSP2ContractMap.put(supplyPointObj.Id ,serviceSP2ContractMap.get(supplyPointObj.Id));
            }
        }
        // Check if there is any other active Supply Point Devices on the Supply Points. 
        if(!serviceMeasuredSP2ContractMap.isEmpty()) {
            for(SupplyPointDevice__c supplyPointObj : [SELECT Id , SupplyPoint__c
                                                       FROM SupplyPointDevice__c 
                                                       WHERE Active__c = TRUE 
                                                       AND SupplyPoint__c IN : serviceMeasuredSP2ContractMap.keySet()]) 
            {
                contractEligibleForBudgPlanList.add(serviceMeasuredSP2ContractMap.get(supplyPointObj.SupplyPoint__c));
            }
        }
        if(billingContractSet != null && !billingContractSet.isEmpty()) {
            // If there's any other active supply point device on the contract, if not, set it to FALSE.
            for(BillingContract__c billingContractObj : [SELECT Id, EligibleforBudgetPlan__c FROM BillingContract__c WHERE Id IN:billingContractSet]) {
                if(contractEligibleForBudgPlanList == null || (contractEligibleForBudgPlanList != null && !contractEligibleForBudgPlanList.contains(billingContractObj.Id))) {
                    billingContractObj.EligibleforBudgetPlan__c = false;
                    billingContractBPFlagResetList.add(billingContractObj);
                }
            }
        }
        if(billingContractBPFlagResetList != null){
            billingContractBPFlagResetList = (List<BillingContract__c>) GlUt_FieldSecurity.cleanseFields(billingContractBPFlagResetList, false);
            update billingContractBPFlagResetList;
        }
        
    }
    /******************************************************************************
	@author    		Echo: Amit K.(AT-4508)
	@date      		11 Dec 2018
	@param			List<SupplyPointDevice__c> newlist, Map<Id,sObject> oldmap
	@return			void
	@description	check valid device type for rural channel associated supply point device
                    and device type of the device associated with supply point device.
	*******************************************************************************/
    public void validDeviceType(List<SupplyPointDevice__c> newlist, Map<Id,sObject> oldmap) {
        Map<Id,Id> mapOfSupplyPointId2DeviceId = new Map<Id,Id>();  // Map of Sp Id having Device Id.
        for(SupplyPointDevice__c spd: newlist){
            //get only those SPD which is active and there is a change in Active field value.
            if(spd.Active__c == true && (oldmap == null || (oldmap != null && spd.Active__c != ((SupplyPointDevice__c) oldMap.get(spd.Id)).Active__c)))
               mapOfSupplyPointId2DeviceId.put(spd.SupplyPoint__c,spd.Device__c);
        }
        if(!mapOfSupplyPointId2DeviceId.isEmpty()){
            Map<Id,Id> mapOfSupplyPointId2RuralChannelId = new Map<Id,Id>(); 
            //Fetch record type Id of SP having record type name as Rural OutLet.
            Id supplyPointRecordTypeId = Schema.SObjectType.SupplyPoint__c.getRecordTypeInfosByName().get(GlUt_Constants.RURALOUTLETRECORDTYPE).getRecordTypeId(); 
            //Fetch Sp on the basis of selected Sp.
            Set<Id> supplyPointIdSet = new Set<Id>();
            supplyPointIdSet.addAll(mapOfSupplyPointId2DeviceId.keySet());
            List<String> queryFields = new List<String>(); 
            queryFields.add(GlUt_APIConstantsSupplyPoint.RURALCHANNELAPINAME); 
            List<SupplyPoint__c> spList = (List<SupplyPoint__c>) GlUt_RuralBillingUtilities.fetchSupplyPoint(queryFields,GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,supplyPointIdSet,'Id','','',supplyPointRecordTypeId);
            if(spList != null && !spList.isEmpty()){
                for(SupplyPoint__c sp: spList){
                    if(sp.RuralChannel__c != null){
                        mapOfSupplyPointId2RuralChannelId.put(sp.Id,sp.RuralChannel__c); // Map of Sp Id and channel associated with it.
                    }
                }
            }
            if(!mapOfSupplyPointId2RuralChannelId.isEmpty()){
                Map<Id,String> mapOfDeviceId2DeviceTypeName = new Map<Id,String>();
                // Fetch device type name on the basis of device associated with SPD.
                for(Device__c device : [Select Id,
                                        DeviceType__r.Name
                                        from Device__c Where Id In: mapOfSupplyPointId2DeviceId.values()]){
                                            mapOfDeviceId2DeviceTypeName.put(device.Id,device.DeviceType__r.Name);
                                        }
                Map<Id,RuralChannel__c> mapOfRuralChannelId2DeviceType = new  Map<Id,RuralChannel__c>(); // map of rural channel with device type associated with it.
                Set<Id> ruralChannelIdSet = new Set<Id>();
                ruralChannelIdSet.addAll(mapOfSupplyPointId2RuralChannelId.values());
                //Fetch rural channel record on the basis of channel Ids.
                List<RuralChannel__c> ruralChannelList = GlUt_RuralBillingUtilities.getRuralChannel(ruralChannelIdSet);
                if(ruralChannelList != null && !ruralChannelList.isEmpty()){
                    for(RuralChannel__c ruralChannel : ruralChannelList){
                        mapOfRuralChannelId2DeviceType.put(ruralChannel.Id,ruralChannel);
                    }
                }
                //Check Device type of device associated with SPD and rural channel device type associated with SPD.
                for(SupplyPointDevice__c spd: newlist){
                    if(mapOfDeviceId2DeviceTypeName.get(spd.Device__c) != null && mapOfSupplyPointId2RuralChannelId.get(spd.SupplyPoint__c) != null 
                       && mapOfRuralChannelId2DeviceType.get(mapOfSupplyPointId2RuralChannelId.get(spd.SupplyPoint__c)).ValidDeviceTypes__c != null){
                           String deviceTypeName = mapOfDeviceId2DeviceTypeName.get(spd.Device__c); 
                           String ruralChannelDeviceTypeName = mapOfRuralChannelId2DeviceType.get(mapOfSupplyPointId2RuralChannelId.get(spd.SupplyPoint__c)).ValidDeviceTypes__c;
                           if(!ruralChannelDeviceTypeName.contains(deviceTypeName)){
                               spd.addError(System.Label.GlUt_DeviceTypeMismatch);
                           }
                       }
                }
            }
        }
    }
}