/******************************************************************************
@author         Echo: Dependra Singh
@date           1 Aug 2018
@description    Handler for TariffLimit  trigger
*******************************************************************************/
public with sharing class GlUt_TariffLimitHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_TariffLimitHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    List<ServiceItem__c> serviceItemUpdateList ;
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           1 Aug 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void MainEntry(GlUt_TriggerHandlerObj inputParam) {
        serviceItemUpdateList = new List<ServiceItem__c>();
        try {
            if (inputParam.isInsert && inputParam.isAfter)  {
                InsertOrUpdateServiceItemGrpAndGrpItem(inputParam.newMap, inputParam.oldMap);
            }
            if (inputParam.isUpdate && inputParam.isAfter)  {
                InsertOrUpdateServiceItemGrpAndGrpItem(inputParam.newMap, inputParam.oldMap);
            }
            if (inputParam.isInsert && inputParam.isBefore) {
                PreventToCreateTariffLimitIfCriteriaNotMatch(inputParam.newlist, null);
            }
            if (inputParam.isUpdate && inputParam.isBefore) {
                PreventToCreateTariffLimitIfCriteriaNotMatch(inputParam.newlist, inputParam.oldMap);
            }
            if (inputParam.isDelete && inputParam.isBefore) {
            }
            if (inputParam.isDelete && inputParam.isAfter)  {
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            // Reset the active function to null in case this class was first in stack
            // this indicates that the trigger has finished firing so it no longer needs to control flow
            if(serviceItemUpdateList.size() > 0){
                serviceItemUpdateList = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(serviceItemUpdateList, false);
                update serviceItemUpdateList;
            }
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           1 Aug 2018
    @param          GlUt_TriggerHandlerObj inputParam
    @description    
    *******************************************************************************/
    private void PreventToCreateTariffLimitIfCriteriaNotMatch(List<SObject> newlist, map<Id, SObject> oldMap) {
        Date earliestStartDate; 
        set<Id> setAccountId = new set<Id>();
        List<TariffLimit__c> tariffLimitList ;
        List<Service__c> lstServices = new  List<Service__c>();
        Map<Id, List<AvailableBundle__c>> listOfAvailableBundleByAsIdMap;
        set<Id> availableServiceTariffIds = new set<Id>(); 
        WrapperServicesByContract objWrapper;
        Map<Id, List<TariffLimit__c>> existingTariffLimitByAccIdMap = new Map<Id, List<TariffLimit__c>>();
        Map<Integer,sObject> mapOfInsertingUniqueId2sObject = new  Map<Integer,sObject>();
        Map<Id,Date> mapOfTariffLmtStartDateByAccId = new  Map<Id,Date>();
        Set<Id> existingTariffIds = new Set<Id>();
        Integer count = 0; 
            //For each Tariff Limit within the Trigger scope: 
            for(TariffLimit__c objNewTariffLimit : (List<TariffLimit__c>)newlist){
                if(oldMap != null){
                    existingTariffIds.add(objNewTariffLimit.Id);
                }
                //Add the associated Account to a set of Account Ids 
                if(objNewTariffLimit.Account__c  != null){
                    setAccountId.add(objNewTariffLimit.Account__c);
                    // map to check latest end date of tariff limit for a particular account.
                    if(!mapOfTariffLmtStartDateByAccId.containsKey(objNewTariffLimit.Account__c)){
                        mapOfTariffLmtStartDateByAccId.put(objNewTariffLimit.Account__c, objNewTariffLimit.StartDate__c);
                    }else{
                        Date objStartDate = mapOfTariffLmtStartDateByAccId.get(objNewTariffLimit.Account__c);
                        if(objStartDate != null && objStartDate > objNewTariffLimit.StartDate__c){
                            mapOfTariffLmtStartDateByAccId.put(objNewTariffLimit.Account__c, objNewTariffLimit.StartDate__c);
                        }
                    }
                } 
                count = count + 1;//Increase the count for custom unique Id.
                mapOfInsertingUniqueId2sObject.put(count,objNewTariffLimit); // Map of Inserting Custom Id having Tariff Limit Record.
            }
            
            //Query for all related Tariff Limit records with a Start Date greater than or equal to the Earliest Start Date and an End Date less than or equal to the Latest End Date 
            if(setAccountId.size() > 0 ){
                List<String> queryFields = new  List<String>();
                queryFields.add(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME);
                queryFields.add(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME);
                queryFields.add(GlUt_APIConstantsTariffLimit.ACCOUNTAPINAME);
                tariffLimitList = (List<TariffLimit__c>) GlUt_RestrictDatesOverlapUtilities.getExistingRecords(queryFields,GlUt_APIConstantsTariffLimit.OBJECTAPINAME,setAccountId,existingTariffIds, GlUt_APIConstantsTariffLimit.ACCOUNTAPINAME);
                if(tariffLimitList != null && !tariffLimitList.isEmpty()){
                    for(TariffLimit__c objTariffLmt : tariffLimitList){
                        if(!existingTariffLimitByAccIdMap.containsKey(objTariffLmt.Account__c)) {
                            existingTariffLimitByAccIdMap.put(objTariffLmt.Account__c, new List<TariffLimit__c>())  ;
                            existingTariffLimitByAccIdMap.get(objTariffLmt.Account__c).add(objTariffLmt);
                        }else{
                            existingTariffLimitByAccIdMap.get(objTariffLmt.Account__c).add(objTariffLmt);
                        }
                    }   
                }
                //Query for each of the Active Services linked to Contracts related to the Accounts, 
                //an Active Service is a Service where the Start Date is <= Tariff Limit Start Date and the End Date is Null or > Tariff Limit Start Date
                objWrapper = getActiveServices(setAccountId,mapOfTariffLmtStartDateByAccId); 
                if(objWrapper != null && objWrapper.availableServicesIds != null && objWrapper.availableServicesIds.size() > 0){
                    listOfAvailableBundleByAsIdMap = new Map<Id, List<AvailableBundle__c>> ();
                    //Query for each of the Available Bundles marked as a Tariff Limit Bundle related to the Service via Available Bundle -> Available Service -> Service
                    List<AvailableBundle__c> avaiableBundleList = [SELECT ID, Bundle__c, Bundle__r.TariffLimit__c, AvailableService__c // AT-3280
                                                                   FROM AvailableBundle__c 
                                                                   WHERE AvailableService__c IN : objWrapper.availableServicesIds];                                              
                    if(avaiableBundleList != null && !avaiableBundleList.isEmpty()){
                        for(AvailableBundle__c objAvaiableBundle : avaiableBundleList){ 
                            if(objAvaiableBundle.Bundle__r.TariffLimit__c){
                                availableServiceTariffIds.add(objAvaiableBundle.AvailableService__c);
                            }
                        }
                    }
                }
            }
            // Iterate through the records returned from the Query using each record as currentTariffLimit 
            for(TariffLimit__c objNewTariffLimit :(List<TariffLimit__c>)newlist){
                if(existingTariffLimitByAccIdMap != null && !existingTariffLimitByAccIdMap.isEmpty())
                    GlUt_RestrictDatesOverlapUtilities.OverlapLogic(objNewTariffLimit,existingTariffLimitByAccIdMap, GlUt_APIConstantsChargeBasis.AVAILABLESERVICEAPINAME,System.Label.GlAp_TariffLimitDatesCanNotOverlap);
                 //If there are No Available Bundles marked as a Tariff Limit Bundle related to any of the active Services,
                // then add an error ‘No Tariff Limit Bundles linked to the Services for this Account’ and do not save that record. 
                if(objNewTariffLimit.Account__c != null){
                    if(objWrapper.contractByAccountIdMap != null && objWrapper.contractByAccountIdMap.containsKey(objNewTariffLimit.Account__c)){
                        Id contractId = objWrapper.contractByAccountIdMap.get(objNewTariffLimit.Account__c);
                        if(contractId != null && objWrapper.listOfServicesByContactIdMap != null && objWrapper.listOfServicesByContactIdMap.containsKey(contractId)){
                            for(Service__c objService : objWrapper.listOfServicesByContactIdMap.get(contractId)){
                                if(!availableServiceTariffIds.contains(objService.AvailableService__c)){
                                    objNewTariffLimit.addError(System.Label.GlAp_NoTariffLimitBundlesLinkedToServicesForAccount);
                                }
                            }
                        }
                    }else{
                        objNewTariffLimit.addError(System.Label.GlAp_NoTariffLimitBundlesLinkedToServicesForAccount);
                    }
                }
            }
            if(!mapOfInsertingUniqueId2sObject.isEmpty()){
                GlUt_RestrictDatesOverlapUtilities.SelfSetRecordCheckOverlapLogic(mapOfInsertingUniqueId2sObject,GlUt_APIConstantsTariffLimit.ACCOUNTAPINAME,System.Label.GlAp_TariffLimitDatesCanNotOverlap);
            }	 
    }   

    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           1 Aug 2018
    @param          set<Id> accountIdSet
                    Date earliestStartDate
                    Date latestEndDate
    @description    
    *******************************************************************************/
    private WrapperServicesByContract  getActiveServices(set<Id> accountIdSet, Map<Id, Date> mapOfTariffLmtStartDateByAccId){
        WrapperServicesByContract objWrapper = new WrapperServicesByContract();
        List<Service__c> servicesList = new  List<Service__c>();
        Map<Id, BillingContract__c> contractMap = new Map<Id, BillingContract__c>([Select Id, Name, Status__c, AccountName__c 
                                                                                   FROM BillingContract__c WHERE Status__c =: GlUt_APIConstantsContracts.STATUS_ACTIVE  
                                                                                   AND AccountName__c IN :accountIdSet]);
        for(Id objId : contractMap.keySet())    {
            BillingContract__c objContract = contractMap.get(objId);
            if(objContract.AccountName__c != null){
                if(!objWrapper.contractByAccountIdMap.containsKey(objContract.AccountName__c)){
                    objWrapper.contractByAccountIdMap.put(objContract.AccountName__c, objId);
                }
            }
        }
        if(contractMap.keyset().size() > 0){
            servicesList  =[Select Id, BillingContract__c,BillingContract__r.AccountName__c,ServiceStartDate__c, ServiceEndDate__c,AvailableService__c 
                            FROM Service__c WHERE BillingContract__c IN:contractMap.keySet()]; 
           
        }

        if(!servicesList.isEmpty()){
            for(Service__c objService : servicesList){
                if(mapOfTariffLmtStartDateByAccId.containsKey(objService.BillingContract__r.AccountName__c)){
                    Date startDate = mapOfTariffLmtStartDateByAccId.get(objService.BillingContract__r.AccountName__c);
                    if(objService.ServiceStartDate__c <= startDate && (objService.ServiceEndDate__c == null || objService.ServiceEndDate__c >= startDate)){
                        if(!objWrapper.listOfServicesByContactIdMap.containsKey(objService.BillingContract__c)){
                            objWrapper.listOfServicesByContactIdMap.put(objService.BillingContract__c, new List<Service__c>{objService});
                        }else{
                            objWrapper.listOfServicesByContactIdMap.get(objService.BillingContract__c).add(objService);
                        }
                        if(objService.AvailableService__c != null){
                            objWrapper.availableServicesIds.add(objService.AvailableService__c);
                        }
                    }
                }
            }
        }
        return objWrapper;
    }
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           1 Aug 2018
    @param         
    @description    Wrapper class to create Data
    *******************************************************************************/
    private class WrapperServicesByContract{
        Map<Id,Id> contractByAccountIdMap;
        Map<Id, List<Service__c>> listOfServicesByContactIdMap ;
        set<Id> availableServicesIds ;
         private WrapperServicesByContract(){
             contractByAccountIdMap = new Map<Id,Id>();
             listOfServicesByContactIdMap = new Map<Id, List<Service__c>>();
             availableServicesIds = new set<Id>();
         }
    }
  
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           1 Aug 2018
    @param         
    @description    InsertOrUpdateServiceItemGrpAndGrpItem
    *******************************************************************************/
    private void InsertOrUpdateServiceItemGrpAndGrpItem(map<Id, SObject> newMap, map<Id, SObject> oldMap){
        //Set of Account Ids
        set<Id> setAccountId = new set<Id>();
        List<TariffLimit__c> existingTariffLimitList = new List<TariffLimit__c>(); //Changes for UL-166 Starts/Ends Here
        //Map to get List of tariff limit by account id.
        Map<Id, List<TariffLimit__c>> ListOftariffLimitByAccountId = new Map<Id, List<TariffLimit__c>>();
        WrapperServicesByContract objWrapper;
        Map<Id, List<AvailableBundle__c>> listOfAvailableBundleByAsIdMap;
        Map<Id, List<AvailableBundle__c>> availableBundleListByASIdMap = new Map<Id, List<AvailableBundle__c>>();
        Map<Id, List<AvailableServiceItem__c>> availableSIListByABIdMap = new Map<Id, List<AvailableServiceItem__c>>();
        List<ServiceItem__c> serviceItemList = new List<ServiceItem__c>();
        Map<Id,Date> mapOfTariffLmtStartDateByAccId = new  Map<Id,Date>();
        serviceItemUpdateList = new List<ServiceItem__c>();
        List<GroupType__c> tariffLimitGroupType = [Select Id from GroupType__c Where Name =:GlUt_Constants.GROUPTYPE_NAME_TARIFFLIMIT Limit 1]; //Changes for UL-166 Starts/Ends Here
        //New Case OR Existing Tariff Limit record having status changed from Pending to Approved. 
        //For each of the Tariff Limit records that does not have a Group of Type ‘Tariff Limit’ associated 
        //These are new and therefore a Group needs to be created 
        //Changes for UL-166 Starts Here
        for(TariffLimit__c objNewTariffLimit : (List<TariffLimit__c>) newMap.values()){
            if((oldMap == null || (oldMap != null && oldMap.keyset().size() > 0 && objNewTariffLimit.Status__c != ((TariffLimit__c) oldMap.get(objNewTariffLimit.Id)).Status__c))
               && objNewTariffLimit.Account__c != null  && objNewTariffLimit.Status__c == GlUt_Constants.TARIFFLIMIT_STATUS_APPROVED){ 
                   //Create a Set of Account Ids for each of the Tariff Limits where the Status is ‘Approved’ 
                   setAccountId.add(objNewTariffLimit.Account__c);
                   if(!ListOftariffLimitByAccountId.containsKey(objNewTariffLimit.Account__c)){
                       ListOftariffLimitByAccountId.put(objNewTariffLimit.Account__c, new List<TariffLimit__c>{objNewTariffLimit});
                   }else{
                       ListOftariffLimitByAccountId.get(objNewTariffLimit.Account__c).add(objNewTariffLimit);
                   }
                   // map to check latest end date of tariff limit for a particular account.
                   if(!mapOfTariffLmtStartDateByAccId.containsKey(objNewTariffLimit.Account__c)){
                       mapOfTariffLmtStartDateByAccId.put(objNewTariffLimit.Account__c, objNewTariffLimit.StartDate__c);
                   }else{
                       Date objStartDate = mapOfTariffLmtStartDateByAccId.get(objNewTariffLimit.Account__c);
                       if(objStartDate != null && objStartDate > objNewTariffLimit.StartDate__c){
                           mapOfTariffLmtStartDateByAccId.put(objNewTariffLimit.Account__c, objNewTariffLimit.StartDate__c);
                       }
                   } //Existing Tariff Limit record having status Already Approved. 
               }else if(oldMap != null && oldMap.keyset().size() > 0 &&  objNewTariffLimit.Status__c == ((TariffLimit__c) oldMap.get(objNewTariffLimit.Id)).Status__c && objNewTariffLimit.Status__c == GlUt_Constants.TARIFFLIMIT_STATUS_APPROVED){
                   existingTariffLimitList.add(objNewTariffLimit);
               }
        }
        if(existingTariffLimitList.size() > 0 && tariffLimitGroupType != null && tariffLimitGroupType.size() > 0){
            //For each of the Tariff Limit records that has a Group already associated 
            TariffLimitWrapper TariffLimitWrapper = getTariffBasedGroups(existingTariffLimitList,tariffLimitGroupType[0].Id);
            set<Id> ServiceItemIds =  new set<Id>();
            Map<Id,List<Id>> listOfServiceItemByGrpIdMap = new Map<Id,List<Id>>();
            Map<Id, GroupItem__c> groupItemIdMap = new Map<Id, GroupItem__c>([SELECT Id, Group__c,ServiceItem__c FROM GroupItem__c WHERE Group__c IN:TariffLimitWrapper.groupByIdMap.keySet()]);
            if(groupItemIdMap.keySet().size() > 0){
                for(Id objId1 : groupItemIdMap.keySet()){
                    ServiceItemIds.add(groupItemIdMap.get(objId1).ServiceItem__c);
                    if(!listOfServiceItemByGrpIdMap.containsKey(groupItemIdMap.get(objId1).Group__c)){
                        listOfServiceItemByGrpIdMap.put(groupItemIdMap.get(objId1).Group__c, new List<Id>());
                        listOfServiceItemByGrpIdMap.get(groupItemIdMap.get(objId1).Group__c).add(groupItemIdMap.get(objId1).ServiceItem__c);
                    }else{
                        listOfServiceItemByGrpIdMap.get(groupItemIdMap.get(objId1).Group__c).add(groupItemIdMap.get(objId1).ServiceItem__c);
                    }
                }
            }
            Map<Id, ServiceItem__c> serviceItemByIdMap;
            if(ServiceItemIds.size() > 0){
                serviceItemByIdMap= new  Map<Id, ServiceItem__c>([Select Id,StartDate__c, EndDate__c FROM ServiceItem__c WHERE ID IN: ServiceItemIds]);
            }
            for(TariffLimit__c objNewTariffLimit : (List<TariffLimit__c>) newMap.values()){
                if(TariffLimitWrapper.listOfGroupIdByTariffIdMap.containsKey(objNewTariffLimit.Id)){
                    for(Id objGroupId : TariffLimitWrapper.listOfGroupIdByTariffIdMap.get(objNewTariffLimit.Id)){
                        if(listOfServiceItemByGrpIdMap.containsKey(objGroupId)){
                            for(Id objServiceItemId : listOfServiceItemByGrpIdMap.get(objGroupId)){
                                if(serviceItemByIdMap.containsKey(objServiceItemId)){
                                    ServiceItem__c objServiceItem =  serviceItemByIdMap.get(objServiceItemId);
                                    TariffLimit__c objOldTariffLimit = (TariffLimit__c)oldMap.get((objNewTariffLimit).Id);
                                    if(objNewTariffLimit.StartDate__c != objOldTariffLimit.StartDate__c){
                                        objServiceItem.StartDate__c = objNewTariffLimit.StartDate__c;
                                    }
                                    if(objNewTariffLimit.EndDate__c != objOldTariffLimit.EndDate__c){
                                        objServiceItem.EndDate__c = objNewTariffLimit.EndDate__c;
                                    }
                                    serviceItemUpdateList.add(objServiceItem);
                                }
                            }
                        }
                    }
                }
            }
        }
        if(setAccountId.size() > 0 && tariffLimitGroupType != null && tariffLimitGroupType.size() > 0){
            List<TariffLimit__c> tariffLimitList = new List<TariffLimit__c>();
            for(List<TariffLimit__c> tariffLimits : ListOftariffLimitByAccountId.values()){
                tariffLimitList.addAll(tariffLimits);
            } 
            //Query for each of the Active Services linked to Contracts related to the Accounts, an Active Service is a Service where the Start Date is <= Tariff Limit Start Date and the End Date is Null or > Tariff Limit Start Date. 
            Map<Id, BillingContract__c> contractMap = new Map<Id, BillingContract__c>([Select Id, Name, Status__c, AccountName__c 
                                                                                       FROM BillingContract__c WHERE Status__c =: GlUt_APIConstantsContracts.STATUS_ACTIVE  
                                                                                       AND AccountName__c IN :setAccountId]);
            //Query for each of the Active Services linked to Contracts related to the Accounts, an Active Service is a Service where the Start Date is <= Tariff Limit Start Date and the End Date is Null or > Tariff Limit Start Date.                                                
            objWrapper = getActiveServices(setAccountId,mapOfTariffLmtStartDateByAccId); 
            if(objWrapper != null && objWrapper.availableServicesIds != null && objWrapper.availableServicesIds.size() > 0){
                listOfAvailableBundleByAsIdMap = new Map<Id, List<AvailableBundle__c>> ();
                //Query for each of the Available Bundles marked as a Tariff Limit Bundle related to the Service via Available Bundle -> Available Service -> Service
                Map<Id, AvailableBundle__c> availableBundleMap = new Map<Id, AvailableBundle__c>([SELECT ID, Bundle__c, Bundle__r.TariffLimit__c, AvailableService__c // AT-3280
                                                                                                  FROM AvailableBundle__c 
                                                                                                  WHERE AvailableService__c IN : objWrapper.availableServicesIds 
                                                                                                  AND Bundle__r.TariffLimit__c = true  ]);  // AT-3280
                if(availableBundleMap.keySet().size() > 0){
                    for(AvailableBundle__c objAvailableBundle : availableBundleMap.values()){
                        if(!availableBundleListByASIdMap.containsKey(objAvailableBundle.AvailableService__c)){
                            availableBundleListByASIdMap.put(objAvailableBundle.AvailableService__c, new List<AvailableBundle__c>{objAvailableBundle});
                        }else{
                            availableBundleListByASIdMap.get(objAvailableBundle.AvailableService__c).add(objAvailableBundle);
                        }
                    }
                    
                    List<AvailableServiceItem__c> availableServiceItemList  = [SELECT Id, ServiceItemType__c,AvailableBundle__c,BundleItem__c 
                                                                               FROM AvailableServiceItem__c 
                                                                               WHERE AvailableBundle__c IN : availableBundleMap.keySet()];
                    if(availableServiceItemList != null & !availableServiceItemList.isEmpty()){
                        for(AvailableServiceItem__c objAvailableServiceItem : availableServiceItemList){
                            if(!availableSIListByABIdMap.containsKey(objAvailableServiceItem.AvailableBundle__c)){
                                availableSIListByABIdMap.put(objAvailableServiceItem.AvailableBundle__c, new List<AvailableServiceItem__c>{objAvailableServiceItem});
                            }else{
                                availableSIListByABIdMap.get(objAvailableServiceItem.AvailableBundle__c).add(objAvailableServiceItem);
                            }
                        }
                    }
                }
            }
            //Map of Id, Id to get tariff id by service id.
            Map<Id, Id> tarrifidByServiceid = new Map<Id, Id>();
            List<Group__c> groupList = new List<Group__c>();
            for(TariffLimit__c objNewTariffLimit : (List<TariffLimit__c>) newMap.values()){
                Map<String,AvailableServiceItem__c> mapOfGroupTypeServiceCombination2AvailableServiceItem = new Map<String,AvailableServiceItem__c>();
                if(objNewTariffLimit.Account__c != null && objWrapper.contractByAccountIdMap != null){
                    if(objWrapper.contractByAccountIdMap.containsKey(objNewTariffLimit.Account__c)){
                        Id contractId = objWrapper.contractByAccountIdMap.get(objNewTariffLimit.Account__c);
                        if(contractId != null && objWrapper.listOfServicesByContactIdMap != null && objWrapper.listOfServicesByContactIdMap.containsKey(contractId)){
                            for(Service__c objService : objWrapper.listOfServicesByContactIdMap.get(contractId)){
                                if(!tarrifidByServiceid.containsKey(objService.Id)){
                                    tarrifidByServiceid.put(objService.Id, objNewTariffLimit.Id);
                                }
                                if(objService.AvailableService__c != null && availableBundleListByASIdMap.containsKey(objService.AvailableService__c)){}{
                                    for(AvailableBundle__c objAvaiableBundle : availableBundleListByASIdMap.get(objService.AvailableService__c)){
                                        if(availableSIListByABIdMap.containsKey(objAvaiableBundle.Id)){
                                            for(AvailableServiceItem__c objAvailableServiceItem : availableSIListByABIdMap.get(objAvaiableBundle.Id)){
                                                ServiceItem__c objServiceItem = new ServiceItem__c();
                                                objServiceItem.Service__c = objService.Id;
                                                objServiceItem.StartDate__c =  objNewTariffLimit.StartDate__c;
                                                objServiceItem.EndDate__c = objNewTariffLimit.EndDate__c;
                                                objServiceItem.AvailableServiceItem__c = objAvailableServiceItem.Id;
                                                objServiceItem.ServiceItemType__c = objAvailableServiceItem.ServiceItemType__c;
                                                serviceItemList.add(objServiceItem);
                                                if(!mapOfGroupTypeServiceCombination2AvailableServiceItem.containsKey(tariffLimitGroupType[0].Id+'-'+objService.Id)){
                                                    groupList.addAll(createGroupForApprovedTariffLimit(tariffLimitGroupType[0].Id,objService.Id,objNewTariffLimit.Id));
                                                    mapOfGroupTypeServiceCombination2AvailableServiceItem.put(tariffLimitGroupType[0].Id+'-'+objService.Id,objAvailableServiceItem);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            //Create Group of Type ‘Tariff Limit’, Link the Group to the Tariff Limit record currently being processed  
            Map<Id, Id> groupidBytariffLimitId = new Map<Id, Id>();
            if(groupList != null && !groupList.isEmpty()){
                groupList = (List<Group__c>) GlUt_FieldSecurity.cleanseFields(groupList, false);
                insert groupList;
                
                for(Group__c objGroup : groupList){
                    if(!groupidBytariffLimitId.containsKey(objGroup.TariffLimit__c)){
                        groupidBytariffLimitId.put(objGroup.TariffLimit__c,objGroup.Id);
                    }
                }
            }
            //Changes for UL-166 Ends Here
            if(!serviceItemList.isEmpty()){
                serviceItemList = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(serviceItemList, false);
                insert serviceItemList;
                List<GroupItem__c> groupItemList = CreateGroupItems(serviceItemList,tarrifidByServiceid,groupidBytariffLimitId);
                if(!groupItemList.isEmpty()){
                    groupItemList = (List<GroupItem__c>) GlUt_FieldSecurity.cleanseFields(groupItemList, false);
                    insert groupItemList;
                }
            }
        }
     }
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           4 Aug 2018
    @param         
    @description    Create Group Item with the use of service item.
    *******************************************************************************/
    private List<GroupItem__c> CreateGroupItems(List<ServiceItem__c> serviceItemList,Map<Id, Id> tarrifidByServiceid,Map<Id, Id> groupidBytariffLimitId){
        List<GroupItem__c> groupItemList = new List<GroupItem__c>();
        for(ServiceItem__c objServiceItem : serviceItemList){
            GroupItem__c objGroupItm = new GroupItem__c();
            objGroupItm.ServiceItem__c = objServiceItem.Id;
            if(tarrifidByServiceid.containsKey(objServiceItem.Service__c)){
                if(groupidBytariffLimitId.containsKey(tarrifidByServiceid.get(objServiceItem.Service__c))){
                    objGroupItm.Group__c= groupidBytariffLimitId.get(tarrifidByServiceid.get(objServiceItem.Service__c));
                    groupItemList.add(objGroupItm);
                }
            }
        }
        return groupItemList;
    }
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           1 Aug 2018
    @param          Id tariffLimitGroupTypeId, Map<Id,List<Id>> listOfGroupIdByTariffIdMap, Id serviceId, Id tariffId
    @description    //Create Group of Type ‘Tariff Limit’, Link the Group to the Tariff Limit record currently being processed  
    @revision       Change Method Parameters and create service based groups earlier it was account specific.(UL-166)
    *******************************************************************************/
    private List<Group__c> createGroupForApprovedTariffLimit(Id tariffLimitGroupTypeId, Id serviceId, Id tariffId){
        List<Group__c> groupListToInsert = new List<Group__c>();
        Group__c objGroup = new Group__c();
        objGroup.GroupType__c = tariffLimitGroupTypeId;
        objGroup.TariffLimit__c = tariffId;
        objGroup.Service__c = serviceId;
        groupListToInsert.add(objGroup);
        return groupListToInsert;
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           4 March 2019
    @description    Wrapper class to create Data
    *******************************************************************************/
    private class TariffLimitWrapper{        
        private Map<Id,List<Id>> listOfGroupIdByTariffIdMap;
        private Map<Id,Group__c> groupByIdMap;
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           04 March 2019
    @param          List<TariffLimit__c> tariffLimits,Id tariffLimitGroupTypeId
    @description    Fetch groups having group Type as Tariff Limit
    *******************************************************************************/
    private TariffLimitWrapper getTariffBasedGroups(List<TariffLimit__c> tariffLimits, Id tariffLimitGroupTypeId){
        //For each of the Tariff Limit records that has a Group already associated 
        TariffLimitWrapper tariffLimitWrapper = new TariffLimitWrapper();
        Map<Id,Group__c> groupByIdMap = new Map<Id,Group__c>([SELECT Id, TariffLimit__c FROM Group__c WHERE TariffLimit__c IN:tariffLimits AND GroupType__c=:tariffLimitGroupTypeId]) ;
        Map<Id,List<Id>> listOfGroupIdByTariffIdMap = new Map<Id,List<Id>>();
        if(groupByIdMap != null && groupByIdMap.keySet().size() > 0){
            for(Id objId : groupByIdMap.keySet()){
                if(!listOfGroupIdByTariffIdMap.containsKey(groupByIdMap.get(objId).TariffLimit__c)){
                    listOfGroupIdByTariffIdMap.put(groupByIdMap.get(objId).TariffLimit__c, new List<Id>());
                    listOfGroupIdByTariffIdMap.get(groupByIdMap.get(objId).TariffLimit__c).add(objId);
                }else{
                    listOfGroupIdByTariffIdMap.get(groupByIdMap.get(objId).TariffLimit__c).add(objId);
                }
            }
        }
        tariffLimitWrapper.listOfGroupIdByTariffIdMap = listOfGroupIdByTariffIdMap;
        tariffLimitWrapper.groupByIdMap = groupByIdMap;
        return tariffLimitWrapper;
    }
}