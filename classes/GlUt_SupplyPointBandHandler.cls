/************************************************************************************************************
@author         Echo: Amit K.
@date           20 June 2018
@description:   This is handler class for Supply Point Band Trigger.
Revision(s):    Echo: Sudhir Kumar - AT-3077(Core 7b) -> Update Supply Point Band Trigger Handler on Date Change
Revision(s):    Echo: Sudhir Kumar -> AT-3719 - Core CC
**************************************************************************************************************/
public class GlUt_SupplyPointBandHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_SupplyPointBandHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private map<Id, Boolean> mapSpbId2IsChangedByStartDate ;
    private map<Id, Boolean> mapSpbId2IsChangedByEndDate ;
    private map<Id, SupplyPointBand__c> mapOldSpbId2SpbObj ;
    private map<Id, list<SupplyPointBand__c>> mapSupplyPointId2ListSpbObj ;
    
    /******************************************************************************
    @author         Echo: Amit K.
    @date           20 June 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    @revision       Echo: Sudhir Kumar - 17 July 2018
    @description    AT-3077(Core 7b) -> Update Supply Point Band Trigger Handler on Date Change
    *******************************************************************************/
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {
        try {            
            if (inputParam.isInsert && inputParam.isBefore) {
                // update the supplypoint band
                ValidateSupplyPointBand(inputParam.newlist,null);
            }
            if (inputParam.isUpdate && inputParam.isBefore) {
                // update the supplypoint band
                ValidateSupplyPointBand(inputParam.newlist,inputParam.oldmap);
            }
            if (inputParam.isInsert && inputParam.isAfter) {
                processSupplyPointBandDateChange(inputParam.newmap, inputParam.oldmap) ;    // AT-3077
            }
            if (inputParam.isUpdate && inputParam.isAfter) {
                processSupplyPointBandDateChange(inputParam.newmap, inputParam.oldmap) ;    // AT-3077
            }
            if (inputParam.isDelete && inputParam.isBefore) {
                
            }
            if (inputParam.isDelete && inputParam.isAfter) {
            }
        } catch (exception e) {

            GlUt_Logger.logException(e);
        }
        finally {
            // Reset the active function to null in case this class was first in stack
            // this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /**********************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-July-2018
    @param         set<Id> setSupplyPointIds
    @return        map<Id, list<AvailableBundle__c>>
    @description   AT-3076: This method returns MapSupplyPointId2ListAvailableBundleObj - In case of New Spb(Supply Point Band)
    **********************************************************************************************/
    map<Id, AvailableBundle__c> mapAvailableBundleId2AvailableBundle ;
    private map<Id, list<AvailableBundle__c>> getMapSupplyPointId2ListAvailableBundleObj(set<Id> setSupplyPointIds) {       
            map<Id, list<AvailableBundle__c>> mapSupplyPointId2ListAvailableBundleObj ;
            if(setSupplyPointIds != null && !setSupplyPointIds.isEmpty()) {
                mapSupplyPointId2ListAvailableBundleObj = new map<Id, list<AvailableBundle__c>>() ;
                mapAvailableBundleId2AvailableBundle = new map<Id, AvailableBundle__c>() ;
                //Get related Available Bundle object on a Supply Point
                for(AvailableBundle__c abObj : [SELECT Id, Bundle__c, 
                                                Bundle__r.Name, //AT-3174
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

            return mapSupplyPointId2ListAvailableBundleObj ;
    }
    
    
    /**********************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-July-2018
    @param         set<Id> setSpbIds
    @return        map<Id, set<Id>>
    @description   AT-3076: This method returns MapSpbId2SetAvailableBundleId - In case of existing Spb
    **********************************************************************************************/
    
    private map<Id, set<Id>> getMapSpbId2SetAvailableBundleId(set<Id> setSpbIds) {      
        map<Id, set<Id>> mapSpbId2SetAvailableBundleId ;
        if(setSpbIds != null && !setSpbIds.isEmpty()) {

            mapSpbId2SetAvailableBundleId = new map<Id, set<Id>>() ;
            for(AvailableServiceItem__c asiObj : [SELECT Id, AvailableBundle__c, StartDate__c, EndDate__c, SupplyPointBand__c FROM AvailableServiceItem__c
                                                  WHERE SupplyPointBand__c IN: setSpbIds]) {
                                      
                                                      
                //By Spb start date**
                if(mapSpbId2IsChangedByStartDate.containsKey(asiObj.SupplyPointBand__c)) {
                    SupplyPointBand__c SpbObj = mapOldSpbId2SpbObj.get(asiObj.SupplyPointBand__c) ;
                    //For each Available Service Item associated with the Supply Point Band where Start Date < Supply Point Band Start Date 
                    //And End Date > Supply Point Band Start Date
                    if(asiObj.SupplyPointBand__c != null && asiObj.StartDate__c < SpbObj.StartDate__c && (asiObj.EndDate__c == null || asiObj.EndDate__c > SpbObj.StartDate__c)) {
                        if(!mapSpbId2SetAvailableBundleId.containsKey(asiObj.SupplyPointBand__c)) {
                            mapSpbId2SetAvailableBundleId.put(asiObj.SupplyPointBand__c, new set<Id> {asiObj.AvailableBundle__c}) ;
                        } else {
                            mapSpbId2SetAvailableBundleId.get(asiObj.SupplyPointBand__c).add(asiObj.AvailableBundle__c) ;
                        }
                    }
                }   
                //By Spb end date**
                if(mapSpbId2IsChangedByEndDate.containsKey(asiObj.SupplyPointBand__c)) {
                    SupplyPointBand__c SpbObj = mapOldSpbId2SpbObj.get(asiObj.SupplyPointBand__c) ;
                    //For each Available Service Item associated with the Supply Point Band where Start Date < Supply Point Device End Date 
                    //And End Date = NULL or  End Date > Supply Point Device End Date
                    if(asiObj.SupplyPointBand__c != null && asiObj.StartDate__c < SpbObj.EndDate__c && (asiObj.EndDate__c == null || asiObj.EndDate__c  > SpbObj.EndDate__c)) {
                        if(!mapSpbId2SetAvailableBundleId.containsKey(asiObj.SupplyPointBand__c)) {
                            mapSpbId2SetAvailableBundleId.put(asiObj.SupplyPointBand__c, new set<Id> {asiObj.AvailableBundle__c}) ;
                        } else {
                            mapSpbId2SetAvailableBundleId.get(asiObj.SupplyPointBand__c).add(asiObj.AvailableBundle__c) ;
                        }
                    }
                }                                        
            }
        }
        return mapSpbId2SetAvailableBundleId ;
    }
    
    /**********************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          16-July-2018
    @param         map<Id, SObject> mapNewSupplyPointBand, map<Id, SObject> mapOldSupplyPointBand
    @return        void
    @description   AT-3076: This method is used to process Supply Point Band if the Supply Point Band End Date has changed, 
                            set the effectiveDate to the Supply Point Band End Date
    **********************************************************************************************/
    
    public void processSupplyPointBandDateChange(map<Id, SObject> mapNewSupplyPointBand, map<Id, SObject> mapOldSupplyPointBand) {
 
        mapOldSpbId2SpbObj = new map<Id, SupplyPointBand__c>() ;
        mapSupplyPointId2ListSpbObj = new map<Id, list<SupplyPointBand__c>>() ;
        
        mapSpbId2IsChangedByStartDate = new map<Id, Boolean>() ;
        mapSpbId2IsChangedByEndDate = new map<Id, Boolean>() ;
        
        
        List<SupplyPointBand__c> listNewSupplyPointBand = (List<SupplyPointBand__c>) mapNewSupplyPointBand.values() ;
        map<Id, GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper> mapOfBundlesToProcess = new  map<Id, GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper>() ;
        
        if(mapOldSupplyPointBand != null) {     // After update context - "Old* SupplyPointBand records"
            for(SupplyPointBand__c supplyPointBand : listNewSupplyPointBand) {
                //Supply Point Band End Date has changed
                if(supplyPointBand.EndDate__c != ((SupplyPointBand__c) mapOldSupplyPointBand.get(supplyPointBand.Id)).EndDate__c) {
                    mapOldSpbId2SpbObj.put(supplyPointBand.Id, supplyPointBand) ;
                    mapSpbId2IsChangedByEndDate.put(supplyPointBand.Id, true) ;
                }
                //Supply Point Band Start Date has changed and the End Date has not
                if(supplyPointBand.StartDate__c != ((SupplyPointBand__c) mapOldSupplyPointBand.get(supplyPointBand.Id)).StartDate__c
                    && supplyPointBand.EndDate__c == ((SupplyPointBand__c) mapOldSupplyPointBand.get(supplyPointBand.Id)).EndDate__c) {
                       mapOldSpbId2SpbObj.put(supplyPointBand.Id, supplyPointBand) ;
                       mapSpbId2IsChangedByStartDate.put(supplyPointBand.Id, true) ;
                  }
                if(!mapSupplyPointId2ListSpbObj.containsKey(supplyPointBand.SupplyPoint__c)) {
                    mapSupplyPointId2ListSpbObj.put(supplyPointBand.SupplyPoint__c, new list<SupplyPointBand__c> {supplyPointBand}) ;
                } else {
                    mapSupplyPointId2ListSpbObj.get(supplyPointBand.SupplyPoint__c).add(supplyPointBand) ;
                }
            }

        } else {    // After insert context - "New* SupplyPointBand records"
            for(SupplyPointBand__c supplyPointBand : listNewSupplyPointBand) {
                    if(!mapSupplyPointId2ListSpbObj.containsKey(supplyPointBand.SupplyPoint__c)) {
                        mapSupplyPointId2ListSpbObj.put(supplyPointBand.SupplyPoint__c, new list<SupplyPointBand__c> {supplyPointBand}) ;
                    } else {
                        mapSupplyPointId2ListSpbObj.get(supplyPointBand.SupplyPoint__c).add(supplyPointBand) ;
                    }
                    mapSpbId2IsChangedByStartDate.put(supplyPointBand.Id, true) ;
            }
        }
        
        //process new Supply Point Bands
        if(!mapSupplyPointId2ListSpbObj.isEmpty()) {
            map<Id, list<AvailableBundle__c>> mapSupplyPointId2ListAvailableBundleObj = getMapSupplyPointId2ListAvailableBundleObj(mapSupplyPointId2ListSpbObj.keySet()) ;
            if(mapSupplyPointId2ListAvailableBundleObj != null && !mapSupplyPointId2ListAvailableBundleObj.isEmpty()) {
                //1. for each Supply Point
                for(String supplyPointId : mapSupplyPointId2ListSpbObj.keySet()) {
                    list<SupplyPointBand__c> listSupplyPointBand = mapSupplyPointId2ListSpbObj.get(supplyPointId) ;
                    list<AvailableBundle__c> listAvailableBundle = mapSupplyPointId2ListAvailableBundleObj.get(supplyPointId) ;
                    if(listSupplyPointBand != null && !listSupplyPointBand.isEmpty()) {
                        //2. for each Supply Point Band
                        for(SupplyPointBand__c Spb : listSupplyPointBand) {
                            if(listAvailableBundle != null && !listAvailableBundle.isEmpty()) {
                                ////3. for each Available Bundle
                                for(AvailableBundle__c ab : listAvailableBundle) {
                                    //create a new Instance of GlUt_ProcessAvailableBundleWrapper with the Available Bundle and Supply Point Band and effectiveDate parameters set
                                    GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper availableBundleWrapper = new GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper() ;
                                    availableBundleWrapper.availableBundle = ab ;
                                    availableBundleWrapper.supplyPointBand = Spb ;
                                    availableBundleWrapper.effectiveDate = Spb.StartDate__c ;  // set the effectiveDate to the Supply Point Band Start Date
                                    //Add the instance to mapOfBundlesToProcess
                                    mapOfBundlesToProcess.put(ab.Id, availableBundleWrapper) ;
                                }
                            }
                        }
                    }
                }
            }
            
        }
        
        //process old/existing Supply Point Bands
        if(!mapOldSpbId2SpbObj.isEmpty()) {
            map<Id, set<Id>> mapSpbId2SetAvailableBundleId =  getMapSpbId2SetAvailableBundleId(mapOldSpbId2SpbObj.keySet()) ;
            map<Id, list<AvailableBundle__c>> mapSupplyPointId2ListAvailableBundleObj = getMapSupplyPointId2ListAvailableBundleObj(mapSupplyPointId2ListSpbObj.keySet()) ;
           
            if(mapSpbId2SetAvailableBundleId != null && !mapSpbId2SetAvailableBundleId.isEmpty()) {
                for(String SpbId : mapSpbId2SetAvailableBundleId.keySet()) {
                    set<Id> setAvailableBundleId = mapSpbId2SetAvailableBundleId.get(SpbId) ;
                    if(setAvailableBundleId != null && !setAvailableBundleId.isEmpty()) {
                        for(String abId : setAvailableBundleId) {
                            AvailableBundle__c ab = mapAvailableBundleId2AvailableBundle != null && mapAvailableBundleId2AvailableBundle.containsKey(abId) 
                                                                                                  ? mapAvailableBundleId2AvailableBundle.get(abId) : null;
                            //create a new Instance of GlUt_ProcessAvailableBundleWrapper with the Available Bundle and Supply Point Band and effectiveDate parameters set
                            GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper availableBundleWrapper = new GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper() ;
                            availableBundleWrapper.availableBundle = ab ;
                            availableBundleWrapper.supplyPointBand = mapOldSpbId2SpbObj.get(SpbId) ;
                            // If the Supply Point Band Removal Date has changed, set the effectiveDate to the Supply Point Band Removal Date
                            if(mapSpbId2IsChangedByEndDate.containsKey(SpbId)) {
                                availableBundleWrapper.effectiveDate = mapOldSpbId2SpbObj.get(SpbId).EndDate__c ;       
                            }
                            //If the Supply Point Band Installation Date has changed and the Removal Date has not, 
                            //  set the effectiveDate to the Supply Point Band Installation Date
                            if(mapSpbId2IsChangedByStartDate.containsKey(SpbId)) {
                                availableBundleWrapper.effectiveDate = mapOldSpbId2SpbObj.get(SpbId).StartDate__c ;
                            }
                            //Add the instance to mapOfBundlesToProcess
                            mapOfBundlesToProcess.put(ab.Id, availableBundleWrapper) ;
                        }
                    }
                }
            }
        }
        
        
        System.debug('Ank-mapOfBundlesToProcess = '+mapOfBundlesToProcess);
        //Now, call the GlUt_ProcessAvailableBundle class passing mapOfBundlesToProcess
        if(!mapOfBundlesToProcess.isEmpty()) {
            GlUt_ProcessAvailableBundle.processAvailableBundleChange(mapOfBundlesToProcess) ;
        }
    }
    
   /******************************************************************************
    @author         Echo: Amit K.
    @date           12 July 2018
    @param          List<SObject> newlist - trigger.new,Map<Id, SObject> oldMap
    @description    Validating the Supply Point Band records.
    *******************************************************************************/
    private void ValidateSupplyPointBand(List<SObject> newlist,Map<Id, SObject> oldMap) {
        Set<Id> supplyPointIds = new Set<Id>();
        Set<Id> supplyPointBandTypeIds = new Set<Id>();
        Set<Id> existingSupplyPointBandIds = new Set<Id>();
         Map<Id, List<sObject>> mapOfId2ExistingSobjectRecords = new Map<Id, List<sObject>>();
        for(SupplyPointBand__c spb : (List<SupplyPointBand__c>) newlist) {
            if(spb.BandType__c != null)
                supplyPointBandTypeIds.add(spb.BandType__c);// Set of Supply Point Band Types
            if(spb.SupplyPoint__c != null)
                supplyPointIds.add(spb.SupplyPoint__c);
            if(oldMap != null)
                existingSupplyPointBandIds.add(spb.Id);
        }
        if(!supplyPointBandTypeIds.isEmpty()){
            Map<Id,BandType__c> mapOfBandTypeId2BandType = new Map<Id,BandType__c>([SELECT Id,
                                                                                    LowerValue__c,
                                                                                    UpperValue__c
                                                                                    FROM BandType__c 
                                                                                    WHERE Id IN:supplyPointBandTypeIds]); //Fetch the band type records on the basis of band Ids.
            
            if(!supplyPointIds.isEmpty()){
                List<String> queryFields = new  List<String>();
                queryFields.add(GlUt_APIConstantsSupplyPointBand.SUPPLYPOINTBANDID);
                queryFields.add(GlUt_APIConstantsSupplyPointBand.BANDTYPEAPINAME);
                queryFields.add(GlUt_APIConstantsSupplyPointBand.BANDVALUEAPINAME);
                queryFields.add(GlUt_APIConstantsSupplyPointBand.STARTDATEAPINAME);
                queryFields.add(GlUt_APIConstantsSupplyPointBand.ENDDATEAPINAME);
                queryFields.add(GlUt_APIConstantsSupplyPointBand.SUPPLYPOINTAPINAME);
                
                List<SupplyPointBand__c> existingSupplyPointBands = (List<SupplyPointBand__c>) GlUt_RestrictDatesOverlapUtilities.getExistingRecords(queryFields,GlUt_APIConstantsSupplyPointBand.SUPPLYPOINTBANDAPINAME,supplyPointIds,existingSupplyPointBandIds,GlUt_APIConstantsSupplyPointBand.SUPPLYPOINTAPINAME);
                if(existingSupplyPointBands != null && !existingSupplyPointBands.isEmpty()){
                    for(SupplyPointBand__c existingSupplyPointBand : existingSupplyPointBands){
                        if (!mapOfId2ExistingSobjectRecords.containsKey(existingSupplyPointBand.SupplyPoint__c)) {
                            mapOfId2ExistingSobjectRecords.put(existingSupplyPointBand.SupplyPoint__c, new List<sObject>()); 
                        }
                        mapOfId2ExistingSobjectRecords.get(existingSupplyPointBand.SupplyPoint__c).add(existingSupplyPointBand);
                    }   
                } 
                Map<Integer,sObject> mapOfInsertingUniqueId2sObject = new  Map<Integer,sObject>();
                Integer count = 0;
                for(SupplyPointBand__c newspb : (List<SupplyPointBand__c>) newlist) {
                    count = count + 1;//Increase the count for custom unique Id.
                    mapOfInsertingUniqueId2sObject.put(count,newspb); // Map of Inserting Custom Id having SPB Record.
                    //Comparison b/w supply point band value with Band type lower and upper values associated with supply point band.
                    if(newspb.BandType__c != null && string.isNotBlank(newspb.BandValue__c) 
                       && !mapOfBandTypeId2BandType.isEmpty() && mapOfBandTypeId2BandType.containsKey(newspb.BandType__c) &&
                       (Integer.valueOf(newspb.BandValue__c) < Integer.valueOf(mapOfBandTypeId2BandType.get(newspb.BandType__c).LowerValue__c)
                        || Integer.valueOf(newspb.BandValue__c) > Integer.valueOf(mapOfBandTypeId2BandType.get(newspb.BandType__c).UpperValue__c))){
                            newspb.addError(System.Label.GlUt_BandLimitException); //Band Limit Exception
                        }
                    if(mapOfId2ExistingSobjectRecords != null && !mapOfId2ExistingSobjectRecords.isEmpty())
                        GlUt_RestrictDatesOverlapUtilities.OverlapLogic(newspb,mapOfId2ExistingSobjectRecords, GlUt_APIConstantsSupplyPointBand.SUPPLYPOINTAPINAME,System.Label.Glut_BandsOverlapException);
                }
                if(!mapOfInsertingUniqueId2sObject.isEmpty()){
                    GlUt_RestrictDatesOverlapUtilities.SelfSetRecordCheckOverlapLogic(mapOfInsertingUniqueId2sObject,GlUt_APIConstantsSupplyPointBand.SUPPLYPOINTAPINAME, System.Label.Glut_BandsOverlapException);
                }
            }
        }
    }
      
}