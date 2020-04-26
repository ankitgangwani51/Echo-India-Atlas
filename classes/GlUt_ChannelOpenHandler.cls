public with Sharing class GlUt_ChannelOpenHandler extends GlUt_TriggerHandlerBase {
    // Variable declaration
    private static final String CLASS_NAME = 'GlUt_ChannelOpenHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    // End variable declaration
     List<RuralGrossConsumption__c> newRuralGrossConsumptionList;
    /**********************************************************************************************
	@author        Echo: Amit K.
	@date          07-Dec-2018
	@param         GlUt_TriggerHandlerObj inputParam
	@return        void
	@description   This method is used to invoke method from trigger
	**********************************************************************************************/
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {
        try {   
            if (inputParam.isInsert && inputParam.isBefore) {
                ValidateOpenChannelPeriod(inputParam.newlist,null);
            }
            if (inputParam.isInsert && inputParam.isAfter) { 
                createRuralGrossConsumption(inputParam.newlist,inputParam.oldmap);
            }
            if (inputParam.isUpdate && inputParam.isBefore) {
                ValidateOpenChannelPeriod(inputParam.newlist,inputParam.oldmap);
            }
            if (inputParam.isUpdate && inputParam.isAfter) {   
               createRuralGrossConsumption(inputParam.newlist,inputParam.oldmap);
            }
            if (inputParam.isDelete && inputParam.isBefore) {
                
            }
            if (inputParam.isDelete && inputParam.isAfter) {
                
            }
        } catch (Exception ex) {
            system.debug('Line Number:=' + ex.getLineNumber());
            GlUt_Logger.logException(ex);

        } finally {
            // insert the new payment records 
            if(newRuralGrossConsumptionList != null && !newRuralGrossConsumptionList.isEmpty()) {
                insert newRuralGrossConsumptionList;
            }
            //Reset the active function to null in case this class was first in stack
            //this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();
           
        }
        
    }
    /**********************************************************************************************
	@author        Echo: Amit K.
	@date          11-Dec-2018
	@param         List<ChannelOpen__c> newlist, Map<Id,sObject> oldmap
	@return        void
	@description   This method is used to create rural gross consumption when channel open record 
                   gets created in system having end date.
	**********************************************************************************************/
    private void createRuralGrossConsumption(List<ChannelOpen__c> newlist, Map<Id,sObject> oldmap) {
        Map<Id,Decimal> mapOfRuralChannelId2UncontrollerDailyVol = new Map<Id,Decimal>(); // Map of rural channel having uncontrolled Volume.
        Set<Id> ruralChannelIdSet = new Set<Id>(); // Set of rural channel Id.
        newRuralGrossConsumptionList = new List<RuralGrossConsumption__c>(); // List of newely created Rural Gross consumptions.
        for(ChannelOpen__c channelOpen : newlist){
            //Check if rural channel is associated and End date is getting changed for open channel.
            if(channelOpen.RuralChannel__c != null && channelOpen.EndDate__c != null && (oldMap == null || (oldMap != null && channelOpen.EndDate__c != ((ChannelOpen__c) oldMap.get(channelOpen.Id)).EndDate__c)))
                ruralChannelIdSet.add(channelOpen.RuralChannel__c);
        }
        if(!ruralChannelIdSet.isEmpty()){
            //Fetch the rural channel uncontrolled volume on the basis of open channel.
            List<RuralChannel__c> listRuralChannel = GlUt_RuralBillingUtilities.getRuralChannel(ruralChannelIdSet);
            if(!listRuralChannel.isEmpty()){
                for(RuralChannel__c ruralChannel: listRuralChannel){
                    mapOfRuralChannelId2UncontrollerDailyVol.put(ruralChannel.Id,ruralChannel.UncontrolledDailyVolume__c); //Create map of rural channel having Uncontrolled Daily Volume.
                }
            }
            if(!mapOfRuralChannelId2UncontrollerDailyVol.isEmpty()){
                Map<Id,SupplyPoint__c> mapOfSupplyPointId2SupplyPoint = new Map<Id,SupplyPoint__c>();
                Set<Id> supplyPointLicenceIds = new Set<Id>();
                Set<Id> channelIdSet = new Set<Id>();
                channelIdSet.addAll(mapOfRuralChannelId2UncontrollerDailyVol.keySet());
                //Fetch supply points of rural outlet billing type = Uncontrolled having rural channel associated with open channel.
                List<String> queryFields = new List<String>();
                queryFields.add(GlUt_APIConstantsSupplyPoint.RURALCHANNELAPINAME);
                queryFields.add(GlUt_APIConstantsSupplyPoint.RURALLICENCEAPINAME);
                Id supplyPointRecordTypeId = Schema.SObjectType.SupplyPoint__c.getRecordTypeInfosByName().get(GlUt_Constants.RURALOUTLETRECORDTYPE).getRecordTypeId();
                List<SupplyPoint__c> supplyPointList = GlUt_RuralBillingUtilities.fetchSupplyPoint(queryFields,GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,channelIdSet,GlUt_APIConstantsSupplyPoint.RURALCHANNELAPINAME,GlUt_APIConstantsSupplyPoint.RURALOUTLETBILLINGTYPEAPINAME,GlUt_Constants.RURALOUTLET_BILLINGTYPE_UNCONTROLLED,supplyPointRecordTypeId);
                if(!supplyPointList.isEmpty()){ 
                    for(SupplyPoint__c sp : supplyPointList){
                        if(sp.Location__r.RuralLicense__c != null && sp.RuralChannel__c != null){
                            mapOfSupplyPointId2SupplyPoint.put(sp.Id,sp); // Map of Supply point having Supply point information.
                            supplyPointLicenceIds.add(sp.Location__r.RuralLicense__c);//Set of licences that are associated from Supply point location.
                        }
                    }
                }
                if(mapOfSupplyPointId2SupplyPoint.values().size() > 0 && !supplyPointLicenceIds.isEmpty()){
                    Map<Id,Id> mapOfRuralLicenceId2RuralEntitlementId = new Map<Id,Id>();
                    //Fetch rural entitlement that are associated with Supply point licence and are active.
                    mapOfRuralLicenceId2RuralEntitlementId = GlUt_RuralBillingUtilities.getMapOfRuralLicenceHavingEntitlementId(supplyPointLicenceIds);
                    for(Id spId : mapOfSupplyPointId2SupplyPoint.keySet()){
                        for(ChannelOpen__c channelOpen : newlist){
                            if(mapOfSupplyPointId2SupplyPoint.get(spId).RuralChannel__c != null 
                               && mapOfSupplyPointId2SupplyPoint.get(spId).Location__r.RuralLicense__c != null && mapOfRuralLicenceId2RuralEntitlementId != null
                               && !mapOfRuralLicenceId2RuralEntitlementId.isEmpty() && mapOfRuralLicenceId2RuralEntitlementId.get(mapOfSupplyPointId2SupplyPoint.get(spId).Location__r.RuralLicense__c) != null){
                                   //Create new Rural Gross consumption records based on open channel and rural entitlement and supply point.
                                   //open channel having associated Rural channel should match with channel associated with supply point having rural outlet type uncontrolled.
                                   if(channelOpen.RuralChannel__c != null && channelOpen.RuralChannel__c == mapOfSupplyPointId2SupplyPoint.get(spId).RuralChannel__c){
                                       RuralGrossConsumption__c ruralGrossConsumption = new RuralGrossConsumption__c();
                                       ruralGrossConsumption.StartDate__c = channelOpen.StartDate__c;
                                       ruralGrossConsumption.EndDate__c = channelOpen.EndDate__c;
                                       ruralGrossConsumption.SupplyPoint__c = spId;
                                       ruralGrossConsumption.RuralEntitlement__c = mapOfRuralLicenceId2RuralEntitlementId.get(mapOfSupplyPointId2SupplyPoint.get(spId).Location__r.RuralLicense__c);
                                       ruralGrossConsumption.Type__c = GlUt_Constants.RURALOUTLET_BILLINGTYPE_UNCONTROLLED;
                                       ruralGrossConsumption.ChannelOpen__c = channelOpen.Id;
                                       ruralGrossConsumption.Consumption__c  = channelOpen.OpenDays__c * mapOfRuralChannelId2UncontrollerDailyVol.get(channelOpen.RuralChannel__c); //Calculate the consumption value on Gross Consumption
                                       newRuralGrossConsumptionList.add(ruralGrossConsumption); 
                                   }
                               }
                        }
                    }
                }
            }
        }
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           18 Dec 2018
    @param          List<SObject> newlist - trigger.new,Map<Id, SObject> oldMap
    @description    Validating the open Channel records.
    *******************************************************************************/
    private void ValidateOpenChannelPeriod(List<SObject> newlist,Map<Id, SObject> oldMap) {
        Set<Id> ruralChannelIds = new Set<Id>();
        Set<Id> existingOpenChannelIds = new Set<Id>();
        Map<Id, List<sObject>> mapOfId2ExistingSobjectRecords = new Map<Id, List<sObject>>();
        for(ChannelOpen__c openChannel : (List<ChannelOpen__c>) newlist) {
            if(openChannel.RuralChannel__c != null)
                ruralChannelIds.add(openChannel.RuralChannel__c); // Rural channel Id Set
            if(oldMap != null)
                existingOpenChannelIds.add(openChannel.Id); // Open Channel Id Set
        }
        if(!ruralChannelIds.isEmpty()){
            List<String> queryFields = new  List<String>();
            queryFields.add(GlUt_APIConstantsChannelOpen.STARTDATEAPINAME);
            queryFields.add(GlUt_APIConstantsChannelOpen.ENDDATEAPINAME);
            queryFields.add(GlUt_APIConstantsChannelOpen.RURALCHANNELAPINAME);
            //Fetch existing open channels on the basis of rural channel Id. 
            List<ChannelOpen__c> existingOpenChannels = (List<ChannelOpen__c>) GlUt_RestrictDatesOverlapUtilities.getExistingRecords(queryFields,GlUt_APIConstantsChannelOpen.OBJECTAPINAME,ruralChannelIds,existingOpenChannelIds,GlUt_APIConstantsChannelOpen.RURALCHANNELAPINAME);
            if(existingOpenChannels != null && !existingOpenChannels.isEmpty()){
                for(ChannelOpen__c existingOpenChannel : existingOpenChannels){
                    if (!mapOfId2ExistingSobjectRecords.containsKey(existingOpenChannel.RuralChannel__c)) {
                        mapOfId2ExistingSobjectRecords.put(existingOpenChannel.RuralChannel__c, new List<sObject>()); 
                    }
                    mapOfId2ExistingSobjectRecords.get(existingOpenChannel.RuralChannel__c).add(existingOpenChannel); // Map of rural channel having Open channels
                }   
            }
            Map<Integer,sObject> mapOfInsertingUniqueId2sObject = new  Map<Integer,sObject>();
            Integer count = 0;
            for(ChannelOpen__c channelOpen : (List<ChannelOpen__c>) newlist) {
                count = count + 1;//Increase the count for custom unique Id.
                mapOfInsertingUniqueId2sObject.put(count,channelOpen); // Map of Inserting Custom Id having channel open Record.
                if(mapOfId2ExistingSobjectRecords != null && !mapOfId2ExistingSobjectRecords.isEmpty())//Call Restrict Date overlap Utilities
                    GlUt_RestrictDatesOverlapUtilities.OverlapLogicForDateTime(channelOpen,mapOfId2ExistingSobjectRecords, GlUt_APIConstantsChannelOpen.RURALCHANNELAPINAME,System.Label.GlUt_ChannelOpenPeriodOverlapException);    // AT-5293
            }
            if(!mapOfInsertingUniqueId2sObject.isEmpty()){
                GlUt_RestrictDatesOverlapUtilities.SelfSetRecordCheckOverlapLogicForDateTime(mapOfInsertingUniqueId2sObject,GlUt_APIConstantsChannelOpen.RURALCHANNELAPINAME, System.Label.GlUt_ChannelOpenPeriodOverlapException);  // AT-5293
            }
        }
    }
}