/************************************************************************************************************
@author         Echo: Amit K.
@date           20 Sep 2018
@description:   This is handler class for Chanrge Basis Trigger.
Revision(s):    
**************************************************************************************************************/
public class GlUt_ChargeBasisHandler extends GlUt_TriggerHandlerBase {
    
        public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {
        try {            
            if (inputParam.isInsert && inputParam.isBefore) {
                ValidateChargeBasis(inputParam.newlist,null);
            }
            if (inputParam.isUpdate && inputParam.isBefore) {
                ValidateChargeBasis(inputParam.newlist,inputParam.oldmap);               
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
    /******************************************************************************
    @author         Echo: Amit K.
    @date           20 Sep 2018
    @param          List<SObject> newlist - trigger.new,Map<Id, SObject> oldMap
    @description    Validating the charge basis records.
    *******************************************************************************/
    private void ValidateChargeBasis(List<SObject> newlist,Map<Id, SObject> oldMap) {
        Set<Id> availableServiceIds = new Set<Id>();
        Set<Id> existingChargeBasisIds = new Set<Id>();
         Map<Id, List<sObject>> mapOfId2ExistingSobjectRecords = new Map<Id, List<sObject>>();
        for(ChargeBasis__c newChargeBasis : (List<ChargeBasis__c>) newlist) {
            if(newChargeBasis.AvailableService__c != null)
                availableServiceIds.add(newChargeBasis.AvailableService__c);
            if(oldMap != null)
                existingChargeBasisIds.add(newChargeBasis.Id);
        }
        if(!availableServiceIds.isEmpty()){
            List<String> queryFields = new  List<String>();
            queryFields.add(GlUt_APIConstantsChargeBasis.STARTDATEAPINAME);
            queryFields.add(GlUt_APIConstantsChargeBasis.ENDDATEAPINAME);
            queryFields.add(GlUt_APIConstantsChargeBasis.AVAILABLESERVICEAPINAME);
            
            List<ChargeBasis__c> existingChargeBasis = (List<ChargeBasis__c>) GlUt_RestrictDatesOverlapUtilities.getExistingRecords(queryFields,GlUt_APIConstantsChargeBasis.OBJECTAPINAME,availableServiceIds,existingChargeBasisIds, GlUt_APIConstantsChargeBasis.AVAILABLESERVICEAPINAME);
            if(existingChargeBasis != null && !existingChargeBasis.isEmpty()){
                for(ChargeBasis__c existingCb : existingChargeBasis){
                    if (!mapOfId2ExistingSobjectRecords.containsKey(existingCb.AvailableService__c)) {
                        mapOfId2ExistingSobjectRecords.put(existingCb.AvailableService__c, new List<sObject>()); 
                    }
                    mapOfId2ExistingSobjectRecords.get(existingCb.AvailableService__c).add(existingCb);
                }   
            }
            
            Map<Integer,sObject> mapOfInsertingUniqueId2sObject = new  Map<Integer,sObject>();
            Integer count = 0;
            for(ChargeBasis__c newChargeBasis : (List<ChargeBasis__c>) newlist){
                count = count + 1;//Increase the count for custom unique Id.
                mapOfInsertingUniqueId2sObject.put(count,newChargeBasis); // Map of Inserting Custom Id having CB Record.
                if(mapOfId2ExistingSobjectRecords != null && !mapOfId2ExistingSobjectRecords.isEmpty()) 
                    GlUt_RestrictDatesOverlapUtilities.OverlapLogic(newChargeBasis,mapOfId2ExistingSobjectRecords, GlUt_APIConstantsChargeBasis.AVAILABLESERVICEAPINAME,System.Label.GlUt_ChargeBasisOverLapException);
            }
            if(!mapOfInsertingUniqueId2sObject.isEmpty()){
                GlUt_RestrictDatesOverlapUtilities.SelfSetRecordCheckOverlapLogic(mapOfInsertingUniqueId2sObject,GlUt_APIConstantsChargeBasis.AVAILABLESERVICEAPINAME, System.Label.GlUt_ChargeBasisOverLapException);
            }
        }
    }

}