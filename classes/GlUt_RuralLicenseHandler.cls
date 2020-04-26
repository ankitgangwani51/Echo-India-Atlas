/******************************************************************************
@author         Echo: Tarun Gupta
@date           17 Dec 2018
@description    Handler for Rural License trigger
@Revisions		AT-5372,5498,5382
@Revisions		CLB-41,CLB-156
*******************************************************************************/
public with sharing class GlUt_RuralLicenseHandler extends GlUt_TriggerHandlerBase { 
    
    private static final String CLASS_NAME = 'GlUt_RuralLicenseHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static final Id RuralOutletRecTypeId = Schema.SObjectType.SupplyPoint__c.getRecordTypeInfosByName().get(GlUt_APIConstantsSupplyPoint.RECORDTYPEOUTLETTYPE).getRecordTypeId(); 
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           17 Dec 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {
        try {
            if (inputParam.isUpdate && inputParam.isAfter) {
                checkLicenseStatusAfterUpdate(inputParam.newMap,inputParam.oldMap);
            }
            if (inputParam.isUpdate && inputParam.isBefore) {
                checkLicenseStatusBeforeUpdate(inputParam.newMap,inputParam.oldMap);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            // Reset the active function to null in case this class was first in stack
            // this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();
            // TO-DO Logger.pop();
        }
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           17 Dec 2018
    @param          List<RuralLicense__c> newList , Map<Id,RuralLicense__c> oldMap
    @description    Checks if the status is changed from pending to active and if there is no location linked, then return error, else update TotalOutlets__c and channel on rural license
    @return         void
    *******************************************************************************/
    private void checkLicenseStatusBeforeUpdate(Map<Id,sObject> newMap,Map<Id,sObject> oldMap) {
        
        Map<Id,List<Id>> mapLicenseIdToListLocationIds = new Map<Id,List<Id>>();
        Map<Id,List<SupplyPoint__c>> mapLocationIdToListSPIds = new Map<Id,List<SupplyPoint__c>>();
        Map<Id,Id> mapLocationIdToRuralLicenseId = new Map<Id,Id>();
        
        if(newMap != null && !newMap.values().isEmpty() ){            
            for(Location__c objLocation : [SELECT Id,Name,RuralLicense__c 
                                           FROM Location__c 
                                           WHERE RuralLicense__c IN: newMap.keyset()]){
                if(objLocation.RuralLicense__c != null){
                    if(!mapLicenseIdToListLocationIds.containsKey(objLocation.RuralLicense__c)){
                        mapLicenseIdToListLocationIds.put(objLocation.RuralLicense__c,new List <Id>());
                    }
                    mapLicenseIdToListLocationIds.get(objLocation.RuralLicense__c).add(objLocation.Id);
                }
                if(!mapLocationIdToRuralLicenseId.containsKey(objLocation.Id))
                    mapLocationIdToRuralLicenseId.put(objLocation.Id, objLocation.RuralLicense__c);
            }
            for(SupplyPoint__c objSupplyPoint : [SELECT Id,Name,Location__c,RuralChannel__c,RuralChannel__r.Name,Book__c 
                                                 FROM SupplyPoint__c 
                                                 WHERE Location__c IN: mapLocationIdToRuralLicenseId.keyset() AND RecordTypeId =: RuralOutletRecTypeId ]){
                if(!mapLocationIdToListSPIds.containsKey(objSupplyPoint.Location__c))
                    mapLocationIdToListSPIds.put(objSupplyPoint.Location__c,new List <SupplyPoint__c>());
                mapLocationIdToListSPIds.get(objSupplyPoint.Location__c).add(objSupplyPoint);
                                                 }
            
            // Fetching Rural License
            for(RuralLicense__c objLicense : (List<RuralLicense__c>)newMap.values()){
                Integer numberOfOutlets = 0;
                String channels = '';
                Id bookId;
                if(oldMap != null && oldMap.keyset().size() > 0){
                    String oldLicenseStatus = ((RuralLicense__c) oldMap.get(objLicense.Id)).Status__c;
                    if(objLicense.Status__c == Label.BlAp_RuralLicenseStatusActive && oldLicenseStatus == Label.BlAp_RuralLicenseStatusPending){
                           if(!mapLicenseIdToListLocationIds.containsKey(objLicense.Id)){
                               objLicense.addError(Label.BlAp_RuralLicenseWithNoLocation);
                           }
                           else{
                               List<Id> listLocationIds = mapLicenseIdToListLocationIds.get(objLicense.Id);
                               for(Id objLocationId : listLocationIds){
                                   if(mapLocationIdToListSPIds.containsKey(objLocationId)){
                                       numberOfOutlets += Integer.valueOf(mapLocationIdToListSPIds.get(objLocationId).size());
                                   }
                                   for(SupplyPoint__c objSP : mapLocationIdToListSPIds.get(objLocationId)){
                                       if(objSP.RuralChannel__r.Name != null){
                                           if(channels == '')
                                               channels = objSP.RuralChannel__r.Name;
                                           else
                                               channels = channels + '\r\n' + objSP.RuralChannel__r.Name;
                                       }
                                       //Assigning book of first SP
                                       if(objSP.Book__c != null && bookId == null)
                                           bookId = objSP.Book__c;
                                   }
                               }
                               objLicense.TotalOutlets__c = numberOfOutlets;
                               objLicense.Channels__c = channels;
                               objLicense.Book__c = bookId;
                           }
                       }
                }
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           17 Dec 2018
    @param          List<RuralLicense__c> newList , Map<Id,RuralLicense__c> oldMap
    @description    Checks if the status is changed from pending to active and if there is no location linked, then return error, else update TotalOutlets__c and channel on rural license
    @return         void
    *******************************************************************************/
    private void checkLicenseStatusAfterUpdate(Map<Id,sObject> newMap,Map<Id,sObject> oldMap) {
        
        List<RuralLicense__c> listActivatedLicenses = new List<RuralLicense__c>();
        List<RuralLicense__c> listCancelledLicenses = new List<RuralLicense__c>();
        if(newMap != null && !newMap.values().isEmpty() ){
            for(RuralLicense__c objLicense : (List<RuralLicense__c>)newMap.values()){
                if(oldMap != null && oldMap.keyset().size() > 0){
                    String oldLicenseStatus = ((RuralLicense__c) oldMap.get(objLicense.Id)).Status__c;
                    if(objLicense.Status__c == Label.BlAp_RuralLicenseStatusActive && oldLicenseStatus == Label.BlAp_RuralLicenseStatusPending){
                        listActivatedLicenses.add(objLicense);
                    }
                    if((objLicense.Status__c == Label.BlAp_RuralLicenseStatusCancel && oldLicenseStatus == Label.BlAp_RuralLicenseStatusActive) ||
                      (objLicense.Status__c == Label.BlAp_LicenseTransferStatusTransferred && oldLicenseStatus == Label.BlAp_RuralLicenseStatusActive)){
                        listCancelledLicenses.add(objLicense);
                    }
                }
            }
        }
        if(!listActivatedLicenses.isEmpty()){
            createServices(listActivatedLicenses);
            GlUt_LicenseUtility.activateLicenses(listActivatedLicenses);
        }
        if(!listCancelledLicenses.isEmpty()){
            GlUt_LicenseUtility.cancelLicenses(listCancelledLicenses);
        }
    }
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		13 Dec 2018
    @param			List<RuralLicense__c> ruralLicensesToActivate
    @return			List<RuralEntitlement__c>
    @description 	Create Rural Entitlement against License
    *******************************************************************************/
    public static void createServices(List<RuralLicense__c> ruralLicensesToActivate) {
        Map<Id,Date> mapLicenseId2TransferredLicenseEndDate = new Map<Id,Date>();
        Map<Id,String> mapLicenseId2contractToTransferID = new Map<Id,String>();
        for(RuralLicense__c objRuralLicense : ruralLicensesToActivate){
            if(!mapLicenseId2TransferredLicenseEndDate.containsKey(objRuralLicense.Id))
                mapLicenseId2TransferredLicenseEndDate.put(objRuralLicense.Id, objRuralLicense.StartDate__c);
            if(!mapLicenseId2contractToTransferID.containsKey(objRuralLicense.Id))
                mapLicenseId2contractToTransferID.put(objRuralLicense.Id, objRuralLicense.BillingContract__c);
        }
        GlUt_LicenseUtility.createServiceAndSILinkedToLicenseBulkified(ruralLicensesToActivate, mapLicenseId2TransferredLicenseEndDate,mapLicenseId2contractToTransferID,null);
    }
}