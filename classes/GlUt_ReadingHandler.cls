/***************************************************************************************************
@author        Accenture : Manish Singh
@date          04-Sep-2017
@description:  This is helper class used by Reading object trigger  
@group         TriggerHelper
Revision(s)    Shivangi Gaur - 23-10-2017 - Updated formula for "readingDifference" variable after data type of ActualDeviceReading__c is
changed from number to text.
Shivangi Gaur - 20-12-2017 - Incorporated review comments on AT-458 dated 19-Dec-2017 for code indentation and braces after if.
Shivangi Gaur - 21-12-2017 - Incorporated review comments on AT-458 dated 20-Dec-2017.
Echo - Gopal Gupta - 7 Feb 2018 - Incorporated the changes of AT-1354 Jira Story
Echo - Mohit Tayal - 20 Mar 2018 - Incorporated the changes of AT-2142 Jira Story
Echo - Neha Rajput - 04 Apr 2018 - Call ADU-calculation logic in move-in and move-out if reading type is not Actual AT-2272
Echo - Neha Rajput - 25 June 2018 - Update for Main & Sub logic AT-2928
Echo- Neha Rajput -  01 Aug 2018 - Update to handle sub logic AT-3171
*******************************************************************************************************/
public with sharing class GlUt_ReadingHandler extends GlUt_TriggerHandlerBase {
    // Variable declaration
    private static final String CLASS_NAME = 'GlUt_ReadingHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    // End variable declaration
    // AU2 - (AT-4483) Starts Here
     List<RuralGrossConsumption__c> newRuralGrossConsumptionList; // List of new rural gross cosnumptions
     List<RuralGrossConsumption__c> amendedRuralGrossConsumptionList; // List of amended Rural Gross consumptions.
    // AU2 - (AT-4483) Ends Here
    /**********************************************************************************************
	@author        Accenture: Manish Singh
	@date          04-Sep-2017
	@param         GlUt_TriggerHandlerObj inputParam
	@return        void
	@description   This method is used to invoke method from trigger
	**********************************************************************************************/
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {
        try {   
            if (inputParam.isInsert && inputParam.isBefore) {                
                // call for adding leading zeroes method
                addLeadingZeros(inputParam.newlist);                
                // call for updating Tripped status
                trippedStatus(inputParam.newlist);				//AT-3677 Core CC               
				// call to handle Main supply point reading
                beforeMainSubRel(inputParam.newlist, null);		//AT-3305 core 7a (rename function name and passing parameter)
            }
            if (inputParam.isInsert && inputParam.isAfter) {               
                // call for average daily uses calculations 
                calAvgDailyUses(inputParam.newlist, null);  // AT-3949                 
				// call to handle Sub supply point reading
                afterMainSubRel(inputParam.newlist, null);    //AT-3305 core 7a (rename function name and passing parameter)   
                 if(GlUt_RegionUtility.getAURegionCustomSetting())
                    createRuralGrossConsumption(inputParam.newlist); // AU2 - (AT-4483)
            }
            if (inputParam.isUpdate && inputParam.isBefore) {
                // call for adding leading zeroes methods
                addLeadingZeros(inputParam.newlist);  
                //call for updating Tripped status
                trippedStatus(inputParam.newlist); 			//AT-3677 Core CC
                // call to handle Main supply point reading ha
                beforeMainSubRel(inputParam.newlist, inputParam.oldmap); 	//AT-3305 core 7a
            }
            if (inputParam.isUpdate && inputParam.isAfter) {                 
                afterMainSubRel(inputParam.newlist, inputParam.oldmap); 	//AT-3305 core 7a
                // call for average daily uses calculations 
                calAvgDailyUses(inputParam.newlist, inputParam.oldmap);  // AT-3949
                if(GlUt_RegionUtility.getAURegionCustomSetting())
                    amendRuralGrossConsumption(inputParam.newlist, inputParam.oldmap); // AU2 - (AT-4483)
            }
            if (inputParam.isDelete && inputParam.isBefore) {
                
            }
            if (inputParam.isDelete && inputParam.isAfter) {
                
            }
        } catch (Exception ex) {
            system.debug('Line Number:=' + ex.getLineNumber());
            GlUt_Logger.logException(ex);

        } finally {
        	// AU2 - (AT-4483) Starts Here
            // insert the new rural gross consumption records 
            if(newRuralGrossConsumptionList != null && !newRuralGrossConsumptionList.isEmpty()) {
                insert newRuralGrossConsumptionList;
            }
            // amend the rural gross consumption records 
            if(amendedRuralGrossConsumptionList != null && !amendedRuralGrossConsumptionList.isEmpty()) {
                update amendedRuralGrossConsumptionList;
            }
            // AU2 - (AT-4483) Ends Here
            //Reset the active function to null in case this class was first in stack
            //this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();

        }
        
    }
    /**********************************************************************************************
	@author        Echo: Amit K. 
	@date          11-Dec-2018
	@param         List<Reading__c> newlist
	@return        void
	@description   This method is used to create rural gross consumption when reading 
                   gets inserted in system. AU2 - (AT-4483)
	**********************************************************************************************/
    private void createRuralGrossConsumption(List<Reading__c> newlist) {
        Set<Id> deviceIdSet = new Set<Id>(); // Collection of device Ids.
        Set<Id> readingIdSet = new Set<Id>();
        Map<Id,Id> mapOfReadingId2DeviceId = new Map<Id,Id>();
        newRuralGrossConsumptionList = new List<RuralGrossConsumption__c>(); // List of newely created Rural Gross consumptions.
        //Fetch the device associated with Reading records.
        for(Reading__c reading : newlist){
            if(reading.Device__c != null)
                mapOfReadingId2DeviceId.put(reading.Id,reading.Device__c);
        }
        if(!mapOfReadingId2DeviceId.isEmpty()){
            Map<Id,Reading__c> mapOfDeviceId2LastBilledReading = new Map<Id,Reading__c>();
            //Fetch last billable reading on the basis of device and which is not yet amended.
            for(Reading__c reading : [Select Id,
                                      Device__c,
                                      ActualDeviceReading__c,
                                      ReadingDate__c
                                      from Reading__c where Device__c In: mapOfReadingId2DeviceId.values()
                                      AND Id NOT In: mapOfReadingId2DeviceId.keySet() AND BillableType__c =: GlUt_Constants.BILLABLE 
                                      AND AmendedByReading__c = null ORDER BY ReadingDate__c DESC]){
                                          if(!mapOfDeviceId2LastBilledReading.containsKey(reading.Device__c)){
                                              mapOfDeviceId2LastBilledReading.put(reading.Device__c,reading); // collection of device having last billable reading.
                                          }
                                      }
            if(!mapOfDeviceId2LastBilledReading.isEmpty()){
                Map<Id,Id> mapOfDeviceId2SupplyPointId = new Map<Id,Id>();
                Set<Id> supplyPointIdSet = new Set<Id>();
                //Fetch the Supply point devices on the basis of device that are associated with inserted reading and are active.
                for(SupplyPointDevice__c spd : [Select Id,
                                                SupplyPoint__c,
                                                Device__c
                                                from SupplyPointDevice__c where Device__c In: mapOfReadingId2DeviceId.values() AND Active__c =: True]){ 
                                                    supplyPointIdSet.add(spd.SupplyPoint__c);
                                                    mapOfDeviceId2SupplyPointId.put(spd.Device__c,spd.SupplyPoint__c); //device can be associated with only one S.P at perticular time.
                                                }
                if(!supplyPointIdSet.isEmpty()){
                    // Rural outlet type record type Id.
                    Id supplyPointRecordTypeId = Schema.SObjectType.SupplyPoint__c.getRecordTypeInfosByName().get(GlUt_Constants.RURALOUTLETRECORDTYPE).getRecordTypeId();
                    //Fetch supply points on the basis of record type.
                    List<String> queryFields = new List<String>();
                    queryFields.add(GlUt_APIConstantsSupplyPoint.RURALLICENCEAPINAME);  
                    List<SupplyPoint__c> supplyPointList = (List<SupplyPoint__c>) GlUt_RuralBillingUtilities.fetchSupplyPoint(queryFields,GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,supplyPointIdSet,'Id',GlUt_APIConstantsSupplyPoint.RURALOUTLETBILLINGTYPEAPINAME, GlUt_Constants.RURALGROSSCONSUMPTION_TYPE_METERED,supplyPointRecordTypeId);
                    if(!supplyPointList.isEmpty()){
                        Set<Id> supplyPointLicenceIds = new Set<Id>();
                        Map<Id,SupplyPoint__c> mapOfSupplyPointId2SupplyPoint = new Map<Id,SupplyPoint__c>();
                        for(SupplyPoint__c sp: supplyPointList){
                            if(sp.Location__r.RuralLicense__c != null){
                                mapOfSupplyPointId2SupplyPoint.put(sp.Id,sp); // Map of Supply point having Supply point information.
                                supplyPointLicenceIds.add(sp.Location__r.RuralLicense__c);//Set of licences that are associated from Supply point location.
                            }
                        }
                        if(!supplyPointLicenceIds.isEmpty()){
                           //Fetch rural entitlement that are associated with Supply point licence and are active.
                            Map<Id,Id> mapOfRuralLicenceId2RuralEntitlementId = GlUt_RuralBillingUtilities.getMapOfRuralLicenceHavingEntitlementId(supplyPointLicenceIds);
                            for(Reading__c reading : newlist){
                                if(!mapOfDeviceId2SupplyPointId.isEmpty() && !mapOfSupplyPointId2SupplyPoint.isEmpty() && !mapOfDeviceId2LastBilledReading.isEmpty() && mapOfRuralLicenceId2RuralEntitlementId != null
                                   && mapOfDeviceId2LastBilledReading.get(reading.Device__c) != null && mapOfDeviceId2SupplyPointId.get(reading.Device__c) != null
                                   && mapOfSupplyPointId2SupplyPoint.get(mapOfDeviceId2SupplyPointId.get(reading.Device__c)) != null
                                   && mapOfRuralLicenceId2RuralEntitlementId.get(mapOfSupplyPointId2SupplyPoint.get(mapOfDeviceId2SupplyPointId.get(reading.Device__c)).Location__r.RuralLicense__c) != null){
                                       RuralGrossConsumption__c ruralGrossConsumption = new RuralGrossConsumption__c();
                                       ruralGrossConsumption.Reading__c = reading.Id;
                                       ruralGrossConsumption.Consumption__c = Integer.valueOf(reading.ActualDeviceReading__c) - Integer.valueOf(mapOfDeviceId2LastBilledReading.get(reading.Device__c).ActualDeviceReading__c); // Reading value - last billed reading value.
                                       ruralGrossConsumption.StartDate__c = mapOfDeviceId2LastBilledReading.get(reading.Device__c).ReadingDate__c + 1; // Start date should be next day of last billed reading date.
                                       ruralGrossConsumption.EndDate__c = reading.ReadingDate__c;
                                       ruralGrossConsumption.Type__c = GlUt_Constants.RURALGROSSCONSUMPTION_TYPE_METERED;
                                       ruralGrossConsumption.Invalid__c = false;
                                       ruralGrossConsumption.SupplyPoint__c = mapOfDeviceId2SupplyPointId.get(reading.Device__c);
                                       ruralGrossConsumption.RuralEntitlement__c = mapOfRuralLicenceId2RuralEntitlementId.get(mapOfSupplyPointId2SupplyPoint.get(ruralGrossConsumption.SupplyPoint__c).Location__r.RuralLicense__c);
                                       newRuralGrossConsumptionList.add(ruralGrossConsumption);//New list of rural gross consumption that needs to be inserted.
                                   }
                            }
                        }
                    }
                }
            }
        }
    }
    /**********************************************************************************************
	@author        Echo: Amit K.
	@date          11-Dec-2018
	@param         List<Reading__c> newlist, Map<Id,sObject> oldmap
	@return        void
	@description   This method is used to amend rural gross consumption when reading 
                   gets amended in system. AU2 - (AT-4483)
	**********************************************************************************************/
    private void amendRuralGrossConsumption(List<Reading__c> newlist, Map<Id,sObject> oldmap) {
        amendedRuralGrossConsumptionList = new List<RuralGrossConsumption__c>(); // List of amended Rural Gross consumptions.
        Set<Id> amendedReadingIdSet = new Set<Id>();// Amended Reading collections.
        Set<Id> readingIdSet = new Set<Id>(); // latest reading collections.
        Map<Id,Id> mapOfAmendedReading2NewReadingId = new Map<Id,Id>(); // map of amended reading having latest reading .
        for(Reading__c reading : newlist){
            if(oldmap != null && reading.AmendedByReading__c != null && reading.AmendedByReading__c != ((Reading__c) oldMap.get(reading.Id)).AmendedByReading__c){
                readingIdSet.add(reading.AmendedByReading__c); //latest Readings
                mapOfAmendedReading2NewReadingId.put(reading.Id,reading.AmendedByReading__c);
                amendedReadingIdSet.add(reading.Id); //Amended reading
            }
        }
        if(!readingIdSet.isEmpty() &&  !mapOfAmendedReading2NewReadingId.isEmpty() && !amendedReadingIdSet.isEmpty()){
            //Fetch rural gross consumption records on the basis of normal reading.
            List<RuralGrossConsumption__c> ruralGrossConsumptionList = GlUt_RuralBillingUtilities.getRuralGrossConsumptionFromReading(readingIdSet);
            if(ruralGrossConsumptionList != null & !ruralGrossConsumptionList.isEmpty()){
                Map<Id,Id> mapOfNewReadingId2NewRuralGrossConsumptionId = new Map<Id,Id>();
                    for(RuralGrossConsumption__c ruralGrossConsumption : ruralGrossConsumptionList){
                        mapOfNewReadingId2NewRuralGrossConsumptionId.put(ruralGrossConsumption.Reading__c,ruralGrossConsumption.Id); // map of latest reading having latest rural gross consumption
                }   
                //Fetch amended rural gross consumption records on the basis of amended readings.
                List<RuralGrossConsumption__c> amendRuralGrossConsumptionList = GlUt_RuralBillingUtilities.getRuralGrossConsumptionFromReading(amendedReadingIdSet);
                if(amendRuralGrossConsumptionList != null && !amendRuralGrossConsumptionList.isEmpty() && !mapOfNewReadingId2NewRuralGrossConsumptionId.isEmpty()){
                    for(RuralGrossConsumption__c amendRuralGrossConsumption: amendRuralGrossConsumptionList){
                        if(mapOfAmendedReading2NewReadingId.get(amendRuralGrossConsumption.Reading__c) != null && mapOfNewReadingId2NewRuralGrossConsumptionId.get(mapOfAmendedReading2NewReadingId.get(amendRuralGrossConsumption.Reading__c)) != null){
                            amendRuralGrossConsumption.Invalid__c = true; // mark rural gross consumption invalid
                            amendRuralGrossConsumption.AmendedBy__c = mapOfNewReadingId2NewRuralGrossConsumptionId.get(mapOfAmendedReading2NewReadingId.get(amendRuralGrossConsumption.Reading__c));// amend rural gross consumption with new one.
                            amendedRuralGrossConsumptionList.add(amendRuralGrossConsumption); //updated list of rural gross consumption records.
                        }
                    } 
                }
            }
        }
    }
    /**********************************************************************************************
	@author        Accenture: Manish Singh
	@date          05-Sep-2017
	@param         Trigger.new
	@return        void
	@description   This method is used to calculate daily uses for device
	@revision      Echo - Gopal Gupta - 7 Feb 2018 - Incorporated the changes of AT-1354 Jira Story
	@revision      Echo - Mohit Tayal - 03 April 2018 - Incorporated the changes of AT-1998 Jira Story
	@revision      Echo - Neha Rajput - 10 Dec 2018 - create ADU in case of leak 
	**********************************************************************************************/
    private void calAvgDailyUses(List<Reading__c> newlist, Map<Id,sObject> oldmap) {         
        
        Map<Id,Date> deviceIdMap = new Map<Id,Date> ();
        for (Reading__c reading : newlist) {
            //Added the check for reading method should be Actual to create ADU    
            // AT-3122                  
            Reading__c oldReading = new Reading__c();            
            if(oldmap != null) 
            	oldReading = (Reading__c)oldmap.get(reading.Id);  
            if( ((oldmap != null && oldReading.EffectiveReading__c != reading.EffectiveReading__c && reading.Leak__c) || oldmap == null) &&  // AT-3949
                ((reading.ReadingMethod__c == GlUt_Constants.ACTUAL && reading.BillableType__c == GlUt_Constants.BILLABLE && 
                reading.ReadingType__c != System.Label.CuAp_ServiceTransferStart && reading.ReadingType__c != System.Label.CuAp_ServiceTransferEnd) || 
                reading.ReadingType__c == GlUt_Constants.MOVEIN || reading.ReadingType__c == GlUt_Constants.MOVEOUT)){   // AT-4271
                if(oldmap != null)
                	deviceIdMap.put(reading.Device__c, reading.ReadingDate__c);
                else
                	deviceIdMap.put(reading.Device__c, null);
            }
        }
        if(!deviceIdMap.isEmpty()){            
            BlUt_ADUCalculation.calculateADU(deviceIdMap, null); //AT-5598
        }
    }
    
    /**********************************************************************************************
	@author        ECHO: Mohit Tayal
	@date          20-Mar-2018
	@param         Trigger.new
	@return        void
	@description   This method is used to adding leading zeroes for actual device reading field 
	while inserting and updating reading
	@revision      
	**********************************************************************************************/
    private void addLeadingZeros(List<Reading__c> newlist) {
        
        Set<Id> deviceIdSet = new Set<Id>();
       
        for(Reading__c reading : newlist){           
            if(reading.Device__c != null){
                deviceIdSet.add(reading.Device__c);
            }
        }
        
        Map<Id,Device__c> deviceIdRecordMap = new Map<Id,Device__c>([SELECT Id, Digit__c FROM Device__c WHERE Id = :deviceIdSet]);
        
        for(Reading__c reading : newlist) {
            if(deviceIdRecordMap.containsKey(reading.Device__c)){
                if(reading.ActualDeviceReading__c.length() < deviceIdRecordMap.get(reading.Device__c).Digit__c){
                    Integer digitDiff = Integer.valueOf(deviceIdRecordMap.get(reading.Device__c).Digit__c) - reading.ActualDeviceReading__c.length();
                    for(Integer i = 0; i < digitDiff; i++){
                        reading.ActualDeviceReading__c = '0' + reading.ActualDeviceReading__c;
                    }
                }
            }
        }
    }
    
    /**********************************************************************************************
	@author        ECHO: Neha Rajput
	@date          20-June-2018
	@param         Trigger.new
	@return        void
	@description   This method for Main meter
	@revision      
	**********************************************************************************************/	
    private void beforeMainSubRel(List<Reading__c> newlist, Map<Id,sObject> oldmap) {	// AT-3305 core 7a 
        
        Map<Id,List<Reading__c>> listOfReadingOnDeviceMap = new Map<Id,List<Reading__c>>();
         
        // Device Linked to Reading...
        for(Reading__c objReading: newlist){
            
            // AT-3305 core 7a Start...
            Boolean billableTypeUpdated = false;  
            if(oldmap != null){
            	Reading__c oldReadingValue = (Reading__c)oldmap.get(objReading.id);
                if(objReading.BillableType__c == GlUt_Constants.BILLABLE && oldReadingValue.BillableType__c == GlUt_Constants.NONBILLABLE){
                    billableTypeUpdated = true;
                }            	
            } 
            // AT-3305 core 7a  end...
            if(objReading.ReadingMethod__c != GlUt_Constants.TOPUP && ((oldmap != null && billableTypeUpdated) || oldmap == null)){		// AT-3305 core 7a 
                if(listOfReadingOnDeviceMap.containsKey(objReading.Device__c)){         
                    listOfReadingOnDeviceMap.get(objReading.Device__c).add(objReading);
                }else{
                    listOfReadingOnDeviceMap.put(objReading.Device__c, new List<Reading__c>{objReading});
                }
            }            
        }
        
		if(listOfReadingOnDeviceMap.size() > 0){
           List<Reading__c> updatedMainSPReadingList = new List<Reading__c>();  
            system.debug('301....beforeMainSubRel');
           updatedMainSPReadingList = updateMainDevice(listOfReadingOnDeviceMap, null, GlUt_Constants.MAIN_DEVICE);  // AT-3171 Core8a(passed 2nd parameter null) + + AT-3676 Core cc (3rd parameter)
        }      
    }
	
    /**********************************************************************************************
	@author        ECHO: Neha Rajput
	@date          20-June-2018
	@param         Trigger.new
	@return        void
	@description   This method for Sub meter
	@revision      
	**********************************************************************************************/    
    private void afterMainSubRel(List<Reading__c> newlist, Map<Id,sObject> oldmap) {	// AT-3305 core 7a 
        
        Map<Id, Id> activeSPOnDeviceMap = new Map<Id, Id>();
        Map<Id, Date> latestBilledReadingOnSPMap = new Map<Id, Date>();       
        Map<Id, Set<Id>> mainSupplyToSubSupplySetMap = new Map<Id, Set<Id>>();
        Map<Id, List<Reading__c>> currentSubSupplyToReadingMap = new Map<Id, List<Reading__c>>();       
        Map<Id,List<Reading__c>> listOfReadingOnDeviceMap = new Map<Id,List<Reading__c>>();
        Map<Id,List<Reading__c>> listOfReadingOnDeviceNewMap = new Map<Id,List<Reading__c>>();
        Map<Reading__c,Id> validSubDeviceReadingMap = new Map<Reading__c,Id>();    // AT-3171 Core8a
        
        Set<Id> allSubSupplySet = new Set<Id>();       
        Set<Id> validMainSupplySet = new Set<Id>(); 
        Set<Id> validMainDeviceSet = new Set<Id>();
		
        ReadingWrapper objWrapper = new ReadingWrapper();
		
        // Device Linked to Reading...
        for(Reading__c objReading: newlist){
            
            // AT-3305 core 7a Start...
            Boolean billableTypeUpdated = false;  
            if(oldmap != null){
            	Reading__c oldReadingValue = (Reading__c)oldmap.get(objReading.id);
                if(objReading.BillableType__c == GlUt_Constants.BILLABLE && oldReadingValue.BillableType__c == GlUt_Constants.NONBILLABLE){
                    billableTypeUpdated = true;
                }            	
            } 
            // AT-3305 core 7a  end...
          
            if(objReading.ReadingMethod__c != GlUt_Constants.TOPUP && ((oldmap != null && billableTypeUpdated) || oldmap == null) ){ // AT-3305 core 7a 
                if(listOfReadingOnDeviceNewMap.containsKey(objReading.Device__c)){         
                    listOfReadingOnDeviceNewMap.get(objReading.Device__c).add(objReading);
                }else{
                    listOfReadingOnDeviceNewMap.put(objReading.Device__c, new List<Reading__c>{objReading});
                }
            }
        }   
        
        if(listOfReadingOnDeviceNewMap.size() > 0){             
            objWrapper = identifySupplyPointRelationship(listOfReadingOnDeviceNewMap);
            activeSPOnDeviceMap = objWrapper.activeSPOnDeviceMap.clone();
            latestBilledReadingOnSPMap = objWrapper.latestBilledReadingOnSPMap.clone();
            mainSupplyToSubSupplySetMap = objWrapper.mainSupplyToSubSupplySetMap.clone();           
            for(Set<Id> subSupplyset: mainSupplyToSubSupplySetMap.values()){
                for(Id subSupplyId: subSupplyset){
                    allSubSupplySet.add(subSupplyId);
                }
            }
            
            for(Reading__c objReading: newlist){ 
                if (objReading.BillableType__c == GlUt_Constants.BILLABLE &&
                    objReading.ReadingMethod__c != GlUt_Constants.TOPUP &&
                    activeSPOnDeviceMap.containsKey(objReading.Device__c) &&
                    allSubSupplySet.contains(activeSPOnDeviceMap.get(objReading.Device__c))){                    
                    if(currentSubSupplyToReadingMap.containsKey(activeSPOnDeviceMap.get(objReading.Device__c))){
                        currentSubSupplyToReadingMap.get(activeSPOnDeviceMap.get(objReading.Device__c)).add(objReading);
                    }else{
                        currentSubSupplyToReadingMap.put(activeSPOnDeviceMap.get(objReading.Device__c), new List<Reading__c>{objReading});                
                    }                    
                }     
            } 
            
            if(currentSubSupplyToReadingMap.size() > 0){            
                // get immediate Main of all valid Sub with latest non billed reading
                for(SupplyPointRelationship__c objSPR: [SELECT Id,MainSupply__c,SubSupply__c,EndDate__c,StartDate__c
                                                        FROM SupplyPointRelationship__c
                                                        WHERE SubSupply__c IN: currentSubSupplyToReadingMap.keySet()]){
                                                            
                    for(Reading__c objReading: currentSubSupplyToReadingMap.get(objSPR.SubSupply__c)){
                        if(objSPR.StartDate__c <= objReading.ReadingDate__c && 
                          (objSPR.EndDate__c > objReading.ReadingDate__c || objSPR.EndDate__c == null)){
                            if(!validMainSupplySet.contains(objSPR.MainSupply__c)){         
                                validMainSupplySet.add(objSPR.MainSupply__c);
                            } 
                            validSubDeviceReadingMap.put(objReading,objSPR.MainSupply__c);   // AT-3171 Core8a
                       }
                   }                                       
                }
                for(SupplyPointDevice__c objSPD : [SELECT Device__c,SupplyPoint__c 
                                                  FROM SupplyPointDevice__c
                                                  WHERE SupplyPoint__c IN: validMainSupplySet
                                                  AND Active__c = TRUE]){
                                                  
                    validMainDeviceSet.add(objSPD.Device__c);      
                    // AT-3171 Core8a... start
                    for(Reading__c subReadingObject: validSubDeviceReadingMap.keySet()){
                        if(validSubDeviceReadingMap.get(subReadingObject) == objSPD.SupplyPoint__c){
                            validSubDeviceReadingMap.put(subReadingObject,objSPD.Device__c);
                        }                                  
                    }
                    // AT-3171 Core8a... end
                }
                
                // Last Non-Billed reading of main 
                if(validMainSupplySet.size() > 0 ){                
                    Set<Id> deviceReadingAlreadyChecked = new Set<Id>();
                    for(Reading__c objReading: [SELECT ReadingDate__c,
                                                       Device__c,
                                                	   Tripped__c,      // AT-3676 Core cc
                                                       ActualDeviceReading__c,
                                                       BillableType__c,
                                                       Billed__c,
                                                       ReadingMethod__c,
                                                	   ReadingType__c
                                                FROM Reading__c 
                                                WHERE Device__c IN: validMainDeviceSet ORDER BY ReadingDate__c DESC]){
                                                   
                        if((!deviceReadingAlreadyChecked.contains(objReading.Device__c)) &&
                            // objReading.BillableType__c == GlUt_Constants.BILLABLE &&
                            objReading.Billed__c == false &&
                            objReading.ReadingMethod__c != GlUt_Constants.TOPUP){
                                                           
                            if(listOfReadingOnDeviceMap.containsKey(objReading.Device__c)){         
                                listOfReadingOnDeviceMap.get(objReading.Device__c).add(objReading);
                            }else{
                                listOfReadingOnDeviceMap.put(objReading.Device__c, new List<Reading__c>{objReading});                
                            } 
                        }                   
                        deviceReadingAlreadyChecked.add(objReading.Device__c);
                    }
                }            
               
                if(listOfReadingOnDeviceMap.size() > 0){  
                    List<Reading__c> updatedMainSPReadingList = new List<Reading__c>();
                    system.debug('302...afterMainSubRel ');
                    updatedMainSPReadingList = updateMainDevice(listOfReadingOnDeviceMap, validSubDeviceReadingMap, GlUt_Constants.SUB_DEVICE );    // AT-3171 Core8a + AT-3676 Core cc(added 3rd parameter)                 
                    if(updatedMainSPReadingList.size() > 0 ){
                        updatedMainSPReadingList = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(updatedMainSPReadingList, false);
                        database.update(updatedMainSPReadingList); 
                    }
                }
            }
        }
    }    
    
    /**********************************************************************************************
	@author        ECHO: Neha Rajput
	@date          20-June-2018
	@param         Trigger.new
	@return        void
	@description   This method for Main meter
	@revision      passed a new parameter validSubDeviceReadingMap // AT-3171 Core8a
	**********************************************************************************************/   
    private List<Reading__c> updateMainDevice(Map<Id,List<Reading__c>> listOfReadingOnDeviceMap, Map<Reading__c,Id> validSubDeviceReadingMap, String deviceType) {
        
        Map<Id, Id> activeSPOnDeviceMap = new Map<Id, Id>();
        Map<Id, Date> latestBilledReadingOnSPMap = new Map<Id, Date>();       
        Map<Id, Set<Id>> mainSupplyToSubSupplySetMap = new Map<Id, Set<Id>>();
        Map<Id, Reading__c> latestBilledReadOnSubSPMap = new Map<Id, Reading__c>();
        Map<Id, Id> activeSubSPOnDeviceMap = new Map<Id, Id>();        
        Map<Id, Reading__c> lastBillableReadingOnMainDeviceMap = new Map<Id, Reading__c>();
        Map<Id, List<Reading__c>> existingBillableReadOnSubSPMap1 = new Map<Id, List<Reading__c>>();
        
        Set<Id> allSubSupplySet = new Set<Id>();
        Set<Id> allMainSupplySet = new Set<Id>();
        List<Reading__c> updatedMainSPReadingList = new List<Reading__c>();
        
        system.debug('800...listOfReadingOnDeviceMap ' + listOfReadingOnDeviceMap + '...validSubDeviceReadingMap...' + validSubDeviceReadingMap + '...deviceType...' + deviceType);
            
        ReadingWrapper objWrapper = new ReadingWrapper();                
        if(listOfReadingOnDeviceMap.size() > 0){
            objWrapper = identifySupplyPointRelationship(listOfReadingOnDeviceMap);             
            activeSPOnDeviceMap = objWrapper.activeSPOnDeviceMap.clone();
            latestBilledReadingOnSPMap = objWrapper.latestBilledReadingOnSPMap.clone();
            mainSupplyToSubSupplySetMap = objWrapper.mainSupplyToSubSupplySetMap.clone();
           
            system.debug('801....activeSPOnDeviceMap ' + activeSPOnDeviceMap);
            system.debug('802....latestBilledReadingOnSPMap ' + latestBilledReadingOnSPMap);
            system.debug('803...mainSupplyToSubSupplySetMap ' + mainSupplyToSubSupplySetMap);
            
            // Identify Device is Main or Sub
            for(Id deviceId: listOfReadingOnDeviceMap.keySet()){
                // Supply point on device is main supply
                if(activeSPOnDeviceMap.containsKey(deviceId) &&
                   mainSupplyToSubSupplySetMap.containsKey(activeSPOnDeviceMap.get(deviceId))){
                    allMainSupplySet.add(deviceId);
                    // Set of all sub supply point
                    for(Id subSupplyId: mainSupplyToSubSupplySetMap.get(activeSPOnDeviceMap.get(deviceId))){
                        allSubSupplySet.add(subSupplyId);
                    }    
                }
            }
            
            // Get Device Digit
            Map<Id,Device__c> deviceIdRecordMap = new Map<Id,Device__c>([SELECT Id, Digit__c, AllowNegativeConsumption__c FROM Device__c WHERE Id = :listOfReadingOnDeviceMap.keySet()]);  //CLB-39
          
            system.debug('804...allSubSupplySet ' + allSubSupplySet + '...allMainSupplySet...' + allMainSupplySet);
            
            if(allSubSupplySet.size() > 0){                
                // get all Device link to sub supply point
                for(SupplyPointDevice__c objSPD : [SELECT Device__c,SupplyPoint__c 
                                                   FROM SupplyPointDevice__c
                                                   WHERE SupplyPoint__c IN: allSubSupplySet                                                                                                    
                                                   AND Active__c = TRUE]){                                                 
                   	activeSubSPOnDeviceMap.put(objSPD.Device__c,objSPD.SupplyPoint__c);
                }
                                                       
                objWrapper.activeSubSPOnDeviceMap = activeSubSPOnDeviceMap.clone(); 
                
                for(Reading__c objReading: [SELECT ReadingDate__c,Device__c,ActualDeviceReading__c,Device__r.Digit__c,Tripped__c, 		//AT-3676 Core CC
                                            MainSubConsumptionDifference__c  		//CLB-39
                                            FROM Reading__c 
                                            WHERE (Device__c IN: activeSubSPOnDeviceMap.keySet() OR
                                                   Device__c IN: allMainSupplySet)   // AT- 3676
                                            AND BillableType__c = :GlUt_Constants.BILLABLE                                              
                                            AND ReadingMethod__c != :GlUt_Constants.TOPUP ORDER BY ReadingDate__c DESC]){ 
                
                    // Last billable reading on main device  AT-3676...
                    if(allMainSupplySet.contains(objReading.Device__c) && listOfReadingOnDeviceMap.containsKey(objReading.Device__c)){
                        List<Reading__c> comingMainDeviceReading = listOfReadingOnDeviceMap.get(objReading.Device__c); 
                       
                       
                        for(Reading__c objread : comingMainDeviceReading){
                            if(objRead.Id != objReading.Id && !lastBillableReadingOnMainDeviceMap.containsKey(objReading.Device__c))
                                lastBillableReadingOnMainDeviceMap.put(objReading.Device__c,objReading);                              
                        }
                    }
                                                
                    if(activeSubSPOnDeviceMap.containsKey(objReading.Device__c)){                            
                        // New Changes try
                        if(!existingBillableReadOnSubSPMap1.containsKey(activeSubSPOnDeviceMap.get(objReading.Device__c))){                        
                            existingBillableReadOnSubSPMap1.put(activeSubSPOnDeviceMap.get(objReading.Device__c),new List<Reading__c>{objReading});
                            
                        }else if(existingBillableReadOnSubSPMap1.get(activeSubSPOnDeviceMap.get(objReading.Device__c)).size() < 2){  // Sub Device last two billable reading
                            List<Reading__c> subBillableReadList = new List<Reading__c>();
                            subBillableReadList = existingBillableReadOnSubSPMap1.get(activeSubSPOnDeviceMap.get(objReading.Device__c));
                            subBillableReadList.add(objReading);
                            existingBillableReadOnSubSPMap1.put(activeSubSPOnDeviceMap.get(objReading.Device__c),subBillableReadList );
                        } 
                    }
                }
              
                // Check Billable and Non Billable type of reading of main device
                for(Id mainDeviceId: allMainSupplySet){
					                  
                    List<Reading__c> readingList = new List<Reading__c>();
                    readingList = listOfReadingOnDeviceMap.get(mainDeviceId);
                    Integer VarCalcEffectiveReading = 0;
                    // for each reading...
                    for(Reading__c objMainDeviceReading: readingList){
                        
                        Set<Id> subSupplyIdSet = mainSupplyToSubSupplySetMap.get(activeSPOnDeviceMap.get(objMainDeviceReading.Device__c));
                        Date latestBilledDateOnMain = latestBilledReadingOnSPMap.get(activeSPOnDeviceMap.get(objMainDeviceReading.Device__c));
                        Integer sumOfSubReading = 0;
                        Boolean readingbillable = true;                           
                        Integer sumOfSubConsumption = 0;
                        for(Id objSubSupply: subSupplyIdSet){
                            
                            Integer latestSubDeviceReading = 0;
                            system.debug('805...existingBillableReadOnSubSPMap1....' + existingBillableReadOnSubSPMap1);
                            system.debug('806...latestBilledDateOnMain ' + latestBilledDateOnMain);                         
                            system.debug('809...objMainDeviceReading ' + objMainDeviceReading);
                            
                            // Billable reading not avaiable on sub                                
                            if((!existingBillableReadOnSubSPMap1.containsKey(objSubSupply)) || 
                               (existingBillableReadOnSubSPMap1.get(objSubSupply)[0].ReadingDate__c < latestBilledDateOnMain && deviceType == GlUt_Constants.SUB_DEVICE) || 
                               (existingBillableReadOnSubSPMap1.get(objSubSupply)[0].ReadingDate__c <= latestBilledDateOnMain && deviceType == GlUt_Constants.MAIN_DEVICE)){  //AT-3305 + AT-3676
                                objMainDeviceReading.BillableType__c = GlUt_Constants.NONBILLABLE;
                                readingbillable = false;                                 
                            }
                            
                           system.debug('810...readingbillable ' + readingbillable);
                            
                            //AT-3676 Core CC start...  
                            if(existingBillableReadOnSubSPMap1.containsKey(objSubSupply)){                         
                                if(existingBillableReadOnSubSPMap1.get(objSubSupply)[0].Tripped__c){
                                    String maxReadingOnDevice = '';
                                    for(Integer i=0; i<existingBillableReadOnSubSPMap1.get(objSubSupply)[0].Device__r.Digit__c; i++){
                                        maxReadingOnDevice = maxReadingOnDevice + '9';
                                    }   
                                    latestSubDeviceReading = Integer.valueOf(maxReadingOnDevice) + Integer.valueOf(existingBillableReadOnSubSPMap1.get(objSubSupply)[0].ActualDeviceReading__c) + 1;                               
                                }else{  //AT-3676 Core CC end...
                                    latestSubDeviceReading = Integer.valueOf(existingBillableReadOnSubSPMap1.get(objSubSupply)[0].ActualDeviceReading__c); 
                                }                                                       
                                if(existingBillableReadOnSubSPMap1.get(objSubSupply).size() == 2){
                                    // CLB-39 start
                                    Integer latestsubMainSubDiff = 0;
                                    if(existingBillableReadOnSubSPMap1.get(objSubSupply)[0].MainSubConsumptionDifference__c != null)
                                        latestsubMainSubDiff = Integer.valueOf(existingBillableReadOnSubSPMap1.get(objSubSupply)[0].MainSubConsumptionDifference__c);
                                    sumOfSubConsumption = sumOfSubConsumption + (latestSubDeviceReading - Integer.valueOf(existingBillableReadOnSubSPMap1.get(objSubSupply)[1].ActualDeviceReading__c)) - latestsubMainSubDiff;
                                     // CLB-39 end 
                                }
                                else
                                    sumOfSubConsumption = sumOfSubConsumption + latestSubDeviceReading;
                            }
                        } 
                        
                        system.debug('111....sumOfSubConsumption ' + sumOfSubConsumption);
                        
                        //AT-3676 Core CC Start...
                        Integer mainDeviceReading = 0;
                        if(objMainDeviceReading.Tripped__c){                            
                            String maxReadingOnDevice = '';
                            Integer noOfDigitInMainDevice = Integer.valueOf(deviceIdRecordMap.get(objMainDeviceReading.Device__c).Digit__c);
                            for(Integer i=0; i < noOfDigitInMainDevice; i++){
                                maxReadingOnDevice = maxReadingOnDevice + '9';
                            }                            
                            mainDeviceReading = (Integer.valueOf(maxReadingOnDevice) + Integer.valueOf(objMainDeviceReading.ActualDeviceReading__c)) + 1 ;
                            
                        }else{
							mainDeviceReading = Integer.valueOf(objMainDeviceReading.ActualDeviceReading__c);                            
                        }
                        system.debug('113....mainDeviceReading ' + mainDeviceReading);
                        
                        VarCalcEffectiveReading = mainDeviceReading - sumOfSubConsumption; // CLB-39 
                       
                        system.debug('112...VarCalcEffectiveReading...' + VarCalcEffectiveReading);
                        //CLB-39 relocate Start...
                        Integer mainDeviceConsumption;
                        if(lastBillableReadingOnMainDeviceMap.containsKey(objMainDeviceReading.Device__c)){
                            mainDeviceConsumption = VarCalcEffectiveReading - Integer.valueOf(lastBillableReadingOnMainDeviceMap.get(objMainDeviceReading.Device__c).ActualDeviceReading__c); // CLB-39 
                        }else{
                            mainDeviceConsumption = VarCalcEffectiveReading;
                        }
                        
                        system.debug('113...mainDeviceConsumption...' + mainDeviceConsumption + '...readingbillable...' + readingbillable);
                        //CLB-39 relocate end...
                        if(readingbillable == true){                              
                            if(GlUt_RegionUtility.getAURegionCustomSetting()){   //CLB-39 start...
                            	Integer calculatedEffReading = 0;   
                                
                                Integer lastReadingMainSubCons;
                                if (lastBillableReadingOnMainDeviceMap.get(objMainDeviceReading.Device__c).MainSubConsumptionDifference__c == null) 
                                   lastReadingMainSubCons = 0;
                                else
                                   lastReadingMainSubCons = Integer.valueOf(lastBillableReadingOnMainDeviceMap.get(objMainDeviceReading.Device__c).MainSubConsumptionDifference__c);
                                
                                // VarCalcEffectiveReading = ObjCurrReading.ActualDeviceReading__c - VarSumSubConsumption + ObjLastReading.MainSubDifference__c
                                //calculatedEffReading = mainDeviceReading - sumOfSubConsumption + Integer.valueOf(lastBillableReadingOnMainDeviceMap.get(objMainDeviceReading.Device__c).MainSubConsumptionDifference__c); 
                                calculatedEffReading = mainDeviceReading - sumOfSubConsumption; 
                               system.debug('114...calculatedEffReading...' + calculatedEffReading);
                                objMainDeviceReading.BillableType__c = GlUt_Constants.BILLABLE;                          
                                //CLB-39 start...
                                if (mainDeviceConsumption <= 0)
                                    objMainDeviceReading.EffectiveDeviceReading__c = String.valueOf(lastBillableReadingOnMainDeviceMap.get(objMainDeviceReading.Device__c).ActualDeviceReading__c);
                                else
                                    objMainDeviceReading.EffectiveDeviceReading__c = String.valueOf(calculatedEffReading); 
                                
                                system.debug('115...objMainDeviceReading.EffectiveDeviceReading__c...' + objMainDeviceReading.EffectiveDeviceReading__c);
                                //ObjCurrReading.MainSubDifference__c = VarCalcEffectiveReading – ObjCurrReading.EffectiveDeviceReading__c
                                objMainDeviceReading.MainSubConsumptionDifference__c = Decimal.valueOf(calculatedEffReading - Integer.valueOf(objMainDeviceReading.EffectiveDeviceReading__c) );  
                                system.debug('116...objMainDeviceReading.MainSubConsumptionDifference__c...' + objMainDeviceReading.MainSubConsumptionDifference__c + '...calculatedEffReading...' + calculatedEffReading);
                            }else{   //CLB-39 end...                              
                                objMainDeviceReading.BillableType__c = GlUt_Constants.BILLABLE;                          
                                objMainDeviceReading.EffectiveDeviceReading__c = String.valueOf(mainDeviceReading - sumOfSubConsumption);  // AT-3676
                            }
                        }
                         /*Integer mainDeviceConsumption;
                        if(lastBillableReadingOnMainDeviceMap.containsKey(objMainDeviceReading.Device__c)){
                            mainDeviceConsumption = mainDeviceReading - Integer.valueOf(lastBillableReadingOnMainDeviceMap.get(objMainDeviceReading.Device__c).ActualDeviceReading__c);
                        }else{
                            mainDeviceConsumption = mainDeviceReading;
                        }*/
                        // AT-3676 end... 
                        
                        Boolean allowNegativeConsumption;
                        if(GlUt_RegionUtility.getAURegionCustomSetting()){
                            if (deviceIdRecordMap.get(objMainDeviceReading.Device__c).AllowNegativeConsumption__c == null)
                        		allowNegativeConsumption = false;
                            else
                                allowNegativeConsumption = deviceIdRecordMap.get(objMainDeviceReading.Device__c).AllowNegativeConsumption__c;
                        }	

                        if(objMainDeviceReading.BillableType__c == GlUt_Constants.BILLABLE && mainDeviceConsumption < 0 && 
                           ((GlUt_RegionUtility.getAURegionCustomSetting() && !allowNegativeConsumption) || !GlUt_RegionUtility.getAURegionCustomSetting() ))   {   // AT-3676   // CLB-39
                            // AT-3171 Core8a... Start
                            Boolean subDeviceReading = false;
                          
                            if(validSubDeviceReadingMap != null){                                 
                                for(Reading__c objSubDeviceReading: validSubDeviceReadingMap.keySet()){
                                    if(validSubDeviceReadingMap.get(objSubDeviceReading) == objMainDeviceReading.Device__c){                                        
                                        subDeviceReading = true;
                                        objSubDeviceReading.addError(Label.GlUt_EffDeviceReadingInvalid); 
                                    }
                                }
                            }                                                        
                            if(subDeviceReading == false)   // AT-3171 Core8a... End
                            	objMainDeviceReading.addError(Label.GlUt_EffDeviceReadingInvalid);                          
                        }
                        lastBillableReadingOnMainDeviceMap.put(objMainDeviceReading.Device__c,objMainDeviceReading);
                        updatedMainSPReadingList.add(objMainDeviceReading);  
                        
                    }
                }
            }
        }
	
        return updatedMainSPReadingList; 
    } 
    
    /**********************************************************************************************
	@author        ECHO: Neha Rajput
	@date          20-June-2018
	@param         Trigger.new
	@return        void
	@description   This method used to identify Main and Sub SupplyPoint relationship
	@revision      
	**********************************************************************************************/ 
    private ReadingWrapper identifySupplyPointRelationship(Map<Id,List<Reading__c>> listOfReadingOnDeviceMap) {
        
        Map<Id, Id> activeSPOnDeviceMap = new Map<Id, Id>();
        Map<Id, Id> deviceLinkToActiveSPMap = new Map<Id, Id>();
        Map<Id, Date> latestBilledReadingOnSPMap = new Map<Id, Date>();        
        Map<Id, Set<Id>> mainSupplyToSubSupplySetMap = new Map<Id, Set<Id>>();             
        
        Set<Id> nonBilledReadingSPSet = new Set<Id>();

        // Active Supply Point Link to the Device
        for(Device__c objDevice: [SELECT Id,
                                  (SELECT SupplyPoint__c FROM SupplyPointDevices__r WHERE Active__c = TRUE),
                                  (SELECT ReadingDate__c FROM Readings__r WHERE Billed__c = TRUE AND ReadingMethod__c != :GlUt_Constants.TOPUP ORDER BY ReadingDate__c DESC LIMIT 1)//AT-3174
                                  FROM Device__c
                                  WHERE Id IN: listOfReadingOnDeviceMap.keySet()]){             
                                  
            for(SupplyPointDevice__c objSPD: objDevice.SupplyPointDevices__r){    
                activeSPOnDeviceMap.put(objDevice.Id,objSPD.SupplyPoint__c);     
                deviceLinkToActiveSPMap.put(objSPD.SupplyPoint__c, objDevice.Id);  
            }
                                      
            // Last Billed Reading on Device
            for(Reading__c objReading: objDevice.Readings__r){//AT-3174
                latestBilledReadingOnSPMap.put(activeSPOnDeviceMap.get(objDevice.Id),objReading.ReadingDate__c);                          
            }
                                      
            // If Last Billed Reading NOT available on Device
            if (! latestBilledReadingOnSPMap.containsKey(activeSPOnDeviceMap.get(objDevice.Id))){
                nonBilledReadingSPSet.add(activeSPOnDeviceMap.get(objDevice.Id));                            
            }  
        }
       
        // Contract start Date for if last Billed Reading NOT available on Device        
        for(SupplyPoint__c objSupplyPoint: [SELECT Id,
                                            (SELECT Id, BillingContract__r.ContractStartDate__c
                                             FROM Services__r 
                                             WHERE ServiceEndDate__c =: null 
                                             OR ServiceEndDate__c >: System.today())
                                            FROM SupplyPoint__c
                                            WHERE Id IN: nonBilledReadingSPSet]){
                                             
            for(Service__c objService: objSupplyPoint.Services__r){
                if(!latestBilledReadingOnSPMap.containsKey(objSupplyPoint.Id)){
                    latestBilledReadingOnSPMap.put(objSupplyPoint.Id,objService.BillingContract__r.ContractStartDate__c);
                }
            }
        }
       
        // Main & Sub Relationship
        for(SupplyPointRelationship__c objSPR: [SELECT Id,MainSupply__c,SubSupply__c,EndDate__c,StartDate__c
                                                FROM SupplyPointRelationship__c
                                                WHERE MainSupply__c IN: deviceLinkToActiveSPMap.keySet()
                                                OR SubSupply__c IN: deviceLinkToActiveSPMap.keySet() ]){  
                                                             
            if(listOfReadingOnDeviceMap.containsKey(deviceLinkToActiveSPMap.get(objSPR.MainSupply__c)) ||
                listOfReadingOnDeviceMap.containsKey(deviceLinkToActiveSPMap.get(objSPR.SubSupply__c))) {
                List<Reading__c> readingList = new List<Reading__c>();
                                                           
                if(listOfReadingOnDeviceMap.containsKey(deviceLinkToActiveSPMap.get(objSPR.MainSupply__c)))
                    readingList = listOfReadingOnDeviceMap.get(deviceLinkToActiveSPMap.get(objSPR.MainSupply__c));
                else
                    readingList = listOfReadingOnDeviceMap.get(deviceLinkToActiveSPMap.get(objSPR.SubSupply__c)); 
                                                           
                for(Reading__c objReading: readingList){
                    if(objSPR.StartDate__c <= objReading.ReadingDate__c && 
                      (objSPR.EndDate__c > objReading.ReadingDate__c || objSPR.EndDate__c == null)){
						  
                        if(mainSupplyToSubSupplySetMap.containsKey(objSPR.MainSupply__c)){         
                            mainSupplyToSubSupplySetMap.get(objSPR.MainSupply__c).add(objSPR.SubSupply__c);
                        }else{
                            mainSupplyToSubSupplySetMap.put(objSPR.MainSupply__c, new Set<Id>{objSPR.SubSupply__c} );
                        }  
                    }
                }
            } 
        }        
        ReadingWrapper objWrapper = new ReadingWrapper();
        objWrapper.activeSPOnDeviceMap = activeSPOnDeviceMap.clone();
        objWrapper.latestBilledReadingOnSPMap = latestBilledReadingOnSPMap.clone();
        objWrapper.mainSupplyToSubSupplySetMap = mainSupplyToSubSupplySetMap.clone();
        
        return objWrapper;        
    } 
    
    /**********************************************************************************************
	@author        ECHO: Neha Rajput
	@date          14-Sep-2018
	@param         Trigger.new
	@return        void
	@description   This method 
	@revision      
	//AT-3677 Core CC
	**********************************************************************************************/ 
    private void trippedStatus(List<Reading__c> newlist){
      
        List<Id> deviceIdList = new List<Id>();        
        // Create a list non-tripped Billable reading 
        for(Reading__c objReading: newlist){            
            if(!objReading.Tripped__c && objReading.BillableType__c == GlUt_Constants.BILLABLE)
                deviceIdList.add(objReading.Device__c);                            
        }       
     
        if(deviceIdList.size() > 0){
            Map<Id,Reading__c> lastTrippedReadingMap = new Map<Id,Reading__c>();            
            for(Reading__c objReading : [SELECT Device__c,Tripped__c,BillableType__c 
                                         FROM Reading__c 
                                         WHERE Device__c IN: deviceIdList 
                                         AND Tripped__c = true ORDER BY ReadingDate__c DESC]){
                                             
                // Last Tripped reading on device
                if(!lastTrippedReadingMap.containsKey(objReading.Device__c)){
                    lastTrippedReadingMap.put(objReading.Device__c, objReading);               
                }
            }
            
            for(Reading__c objReading: newlist){
                // last tripped reading is non-billable and latest reading is Billable                
                if(deviceIdList.contains(objReading.Device__c) && lastTrippedReadingMap.containsKey(objReading.Device__c) && lastTrippedReadingMap.get(objReading.Device__c).BillableType__c == GlUt_Constants.NONBILLABLE)
                   objReading.Tripped__c = true;               
            }
        } 
        
    }
    
    /**********************************************************************************************
	@author        ECHO: Neha Rajput
	@date          20-June-2018
	@param         Trigger.new
	@return        void
	@description   Wrapper class
	@revision      
	**********************************************************************************************/
    public class ReadingWrapper {
        public Map<Id, Id> activeSPOnDeviceMap; 
        public Map<Id, Date> latestBilledReadingOnSPMap;
        public Map<Id, Set<Id>> mainSupplyToSubSupplySetMap; 
        public Map<Id, Id> activeSubSPOnDeviceMap;
    }
}