/******************************************************************************
@author         Echo: Vivek Sethi
@date           07 Dec 2018
@description    Batch class for Entitlement Renewal
*******************************************************************************/

global with sharing class LoBt_EntitlementRenewal extends GlBt_BatchProcess implements Database.Batchable<sObject>,Database.Stateful{
    
    private static final String CLASS_NAME = 'LoBt_EntitlementRenewal';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    global static string sQuery;
    global BatchRequestQueue__c batchRequestQueue;
    global Integer seasonalAllocation;
    global Boolean batchError;
    global Date renewalDate;
    
    private static List<BatchError__c > batchErrorList = new List<BatchError__c>();
    private static  Map<Id,BatchError__c> alreadyRenewedEntitlementsToBatchErrorMap = new Map<Id,BatchError__c>();
    private static Map<Id,RuralEntitlement__c> mapOfRuralEntitlementIdToRecord = new Map<Id,RuralEntitlement__c>();
    private static List<string> ruralEntitlementFields;
    static{
        ruralEntitlementFields = new List<string>();
        ruralEntitlementFields.add(GlUt_APIConstantsRuralEntitlement.ACTIVEAPINAME); 
        ruralEntitlementFields.add(GlUt_APIConstantsRuralEntitlement.ENDDATEAPINAME); 
        ruralEntitlementFields.add(GlUt_APIConstantsRuralEntitlement.STARTDATEAPINAME); 
        ruralEntitlementFields.add(GlUt_APIConstantsRuralEntitlement.PERMANENTTRANSFERINAPINAME); 
        ruralEntitlementFields.add(GlUt_APIConstantsRuralEntitlement.PERMANENTTRANSFEROUTAPINAME); 
        ruralEntitlementFields.add(GlUt_APIConstantsRuralEntitlement.SEASONALALLOCATIONAPINAME); 
        ruralEntitlementFields.add(GlUt_APIConstantsRuralEntitlement.RURALLICENSEAPINAME); 
        ruralEntitlementFields.add(GlUt_APIConstantsRuralEntitlement.RURALENTITLEMENTNUMBERAPINAME);
        
    }   
    
    /******************************************************************************
	@author         Echo: Vivek Sethi
	@date           07 Dec 2018
    @description    Override GlBt_BatchProcess method as per Batch framework.
    *******************************************************************************/
    global override void Initialise(BatchRequestQueue__c brq){
        this.batchRequestQueue = brq;
    }
    
    /******************************************************************************
  	@author         Echo: Vivek Sethi
	@date           07 Dec 2018
    @description    Batch's start method
    *******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {        
        LoBt_EntitlementRenewalWrapper entitlementRenewalParams;        
        //updateBRQ(batchRequestQueue,LoBt_Constants.BRQPROCESSINGSTATUS); 
        //Checkmarx Review: Sudhir
        updateBRQ(new list<BatchRequestQueue__c> {batchRequestQueue},LoBt_Constants.BRQPROCESSINGSTATUS);  // Checkmarx
        batchError = false;
        try{
            if(batchRequestQueue != null && batchRequestQueue.Parameters__c == null){
                createBatchError(batchRequestQueue,  LoBt_Constants.INVALIDPARAMETERSERROR,null);
                batchError = true;
            }
            else{
                entitlementRenewalParams = LoBt_EntitlementRenewalWrapper.parse(batchRequestQueue.Parameters__c);
                seasonalAllocation = entitlementRenewalParams.SeasonalAllocation;
                renewalDate = entitlementRenewalParams.RenewalDate;
                
                if(seasonalAllocation == null ||  renewalDate == null) {
                    createBatchError(batchRequestQueue,  LoBt_Constants.INVALIDPARAMETERSERROR,null);
                    batchError = true;
                }
                else {
                    sQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(ruralEntitlementFields,','), 
                        GlUt_APIConstantsRuralEntitlement.RURALENTITLEMENTAPINAME +' WHERE ' + 
                        GlUt_APIConstantsRuralEntitlement.ACTIVEAPINAME + ' = TRUE'});                 
                }
            }
        }catch (exception e){
            GlUt_Logger.logException(e);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return Database.getQueryLocator(sQuery);
    }
    
    /******************************************************************************
   	@author         Echo: Vivek Sethi
	@date           07 Dec 2018
    @description    Batch's execute method
    *******************************************************************************/
    global void execute(Database.BatchableContext bc, List<RuralEntitlement__c> ruralEntitlementllist){
        List<RuralLicense__c> ruralLicenseList = new List<RuralLicense__c>();
        List<ServiceItem__c> serviceItemslist = new List<ServiceItem__c>();
        List<ServiceItem__c> existingServiceItemslist = new List<ServiceItem__c>();
        List<RuralEntitlement__c> expiredRuralEntitlementsList = new List<RuralEntitlement__c>();
        Map<Id,RuralEntitlement__c> ruralLicenseWithRuralEntitlementMap = new Map<Id,RuralEntitlement__c>();
        Map<Id,RuralEntitlement__c> oldRuralEntitlementWithNewRuralEntitlement = new Map<Id,RuralEntitlement__c>();
        Map<Id,RuralLicense__c> ruralEntitlementWithRuralLicenseMap = new Map<Id,RuralLicense__c>();
        Map<Id,ServiceItem__c> oldServiceItemIdwithNewServiceItemMap = new Map<Id,ServiceItem__c>();
        Map<Id,Id> infraChargeWithRuralEntitlementMap = new Map<Id,Id>();
        Map<Id,Decimal> mapOfRuralEntitlementIdToBaseVolumeWithTransfers = new Map<Id,Decimal>();
        
        List<RuralEntitlement__c> ruralEntitlementupsertList = new List<RuralEntitlement__c>();
        try{
            batchError = false;
            for(RuralEntitlement__c objRuralEntitlement : ruralEntitlementllist) {
                if(!mapOfRuralEntitlementIdToRecord.containsKey(objRuralEntitlement.Id))
                    mapOfRuralEntitlementIdToRecord.put(objRuralEntitlement.Id,objRuralEntitlement);
            }
            //Filtering the expired Rural Entitlement records
            for(RuralEntitlement__c objRuralEntitlement : ruralEntitlementllist) {
                if(objRuralEntitlement.StartDate__c >= renewalDate) {
                    createBatchError(batchRequestQueue,LoBt_Constants.ENTITLEMENTACTIVE, objRuralEntitlement.Id);
                }
                else
                	expiredRuralEntitlementsList.add(objRuralEntitlement);
            }
            //Fetching Rural Licenses with only one active Rural Entitlements  
            if(expiredRuralEntitlementsList != null && !expiredRuralEntitlementsList.isEmpty()) {
                for(RuralEntitlement__c objRuralEntitlement : expiredRuralEntitlementsList) {
                    if(!ruralLicenseWithRuralEntitlementMap.containsKey(objRuralEntitlement.RuralLicense__c))
                        ruralLicenseWithRuralEntitlementMap.put(objRuralEntitlement.RuralLicense__c, objRuralEntitlement);
                }
            }
         
            if(ruralLicenseWithRuralEntitlementMap != null && !ruralLicenseWithRuralEntitlementMap.isEmpty()) {
                for(RuralLicense__c objRuralLicense : [SELECT Id , InfrastructureCharge__c, HeadworkInfrastructureCharge__c, BaseEntitlement__c from RuralLicense__c where Id IN: ruralLicenseWithRuralEntitlementMap.keySet()]) {
                    ruralEntitlementWithRuralLicenseMap.put(ruralLicenseWithRuralEntitlementMap.get(objRuralLicense.Id).Id, objRuralLicense);
                }
            }

            if(ruralEntitlementWithRuralLicenseMap != null && !ruralEntitlementWithRuralLicenseMap.isEmpty()) {
                for(RuralEntitlement__c ruralEntitlementExpired : expiredRuralEntitlementsList) {
                    
                    if(ruralEntitlementWithRuralLicenseMap.containsKey(ruralEntitlementExpired.Id)) {
                        //Creating the new Entitlement records
                        RuralEntitlement__c ObjNewRuralEntitlement      = new RuralEntitlement__c();
                        ObjNewRuralEntitlement.StartDate__c 		    = renewalDate;
                        ObjNewRuralEntitlement.SeasonalAllocation__c    = seasonalAllocation;
                        ObjNewRuralEntitlement.RuralLicense__c 		    = ruralEntitlementWithRuralLicenseMap.get(ruralEntitlementExpired.Id).Id; 
                        ObjNewRuralEntitlement.PermanentTransfersIn__c  = 0; 
                        ObjNewRuralEntitlement.PermanentTransfersOut__c = 0; 
                        //Updating current Entitlement to active = false
                        ruralEntitlementExpired.Active__c = false;     
                        ruralEntitlementExpired.EndDate__c = renewalDate - 1;   //AT-5316
                        ruralEntitlementupsertList.add(ObjNewRuralEntitlement);
                        ruralEntitlementupsertList.add(ruralEntitlementExpired);
                        oldRuralEntitlementWithNewRuralEntitlement.put(ruralEntitlementExpired.Id,ObjNewRuralEntitlement);
                    }
                }   
            }
            
            if(ruralEntitlementupsertList != null && !ruralEntitlementupsertList.isEmpty())
                upsert ruralEntitlementupsertList;
            
            // AT-5030, Ankit, 08 Feb 2019
            for(RuralEntitlement__c ruralEnt : [SELECT Id, BaseVolumewithTransfers__c FROM RuralEntitlement__c WHERE Id IN:ruralEntitlementupsertList]){
                if(!mapOfRuralEntitlementIdToBaseVolumeWithTransfers.containsKey(ruralEnt.Id)){
                    mapOfRuralEntitlementIdToBaseVolumeWithTransfers.put(ruralEnt.Id,ruralEnt.BaseVolumewithTransfers__c);
                }
            }
            
             //Find the latest Service Item Records  (Headwork Infrastructure Charge Or Infrastructure Charge)  
            if(ruralEntitlementWithRuralLicenseMap != null && !ruralEntitlementWithRuralLicenseMap.isEmpty()) {
                for(ServiceItem__c  objServiceItem :  [SELECT Id, Service__c, RuralEntitlement__c, AvailableServiceItem__c, ServiceItemType__c , StartDate__c, EndDate__c, Quantity__c 
                                                       from ServiceItem__c
                                                       where RuralEntitlement__c IN: ruralEntitlementWithRuralLicenseMap.Keyset()
                                                       and StartDate__c <: renewalDate
                                                       and EndDate__c =: null 
                                                       order by StartDate__c Desc]) 
                {
                    if((ruralEntitlementWithRuralLicenseMap.get(objServiceItem.RuralEntitlement__c).InfrastructureCharge__c != null && 
                        ruralEntitlementWithRuralLicenseMap.get(objServiceItem.RuralEntitlement__c).InfrastructureCharge__c ==  objServiceItem.ServiceItemType__c) ||
                       (ruralEntitlementWithRuralLicenseMap.get(objServiceItem.RuralEntitlement__c).HeadworkInfrastructureCharge__c != null && 
                        ruralEntitlementWithRuralLicenseMap.get(objServiceItem.RuralEntitlement__c).HeadworkInfrastructureCharge__c ==  objServiceItem.ServiceItemType__c)) 
                    {
                        ServiceItem__c newServiceItem = new ServiceItem__c();
                        newServiceItem.Service__c = objServiceItem.Service__c;
                        newServiceItem.ServiceItemType__c = objServiceItem.ServiceItemType__c;
                        newServiceItem.StartDate__c = renewalDate;
                        newServiceItem.AvailableServiceItem__c = objServiceItem.AvailableServiceItem__c;
                        // AT-5030, Ankit, 08 Feb 2019
                        Id newEntitlementId = oldRuralEntitlementWithNewRuralEntitlement.get(objServiceItem.RuralEntitlement__c).Id;
                        if(newEntitlementId != null) {
                            newServiceItem.RuralEntitlement__c = newEntitlementId;
                            if(mapOfRuralEntitlementIdToBaseVolumeWithTransfers.containsKey(newEntitlementId)){
                                Decimal baseVolume = mapOfRuralEntitlementIdToBaseVolumeWithTransfers.get(newEntitlementId);
                                newServiceItem.Quantity__c = baseVolume/1000;
                            }                        
                        }
                        serviceItemslist.add(newServiceItem);
                        oldServiceItemIdwithNewServiceItemMap.put(objServiceItem.Id,newServiceItem);
                    }
                }
            }
            if(serviceItemslist != null && !serviceItemslist.isEmpty())
                insert serviceItemslist;
            
            //Ending current Service Item to Renewal Date - 1 
            for(Id serviceItemObj : oldServiceItemIdwithNewServiceItemMap.keySet()) {
                ServiceItem__c updateServiceItemobj = new ServiceItem__c(Id = serviceItemObj,
                                                                         AmendedByServiceItem__c = oldServiceItemIdwithNewServiceItemMap.get(serviceItemObj).Id,
                                                                         EndDate__c =  renewalDate - 1);
                existingServiceItemslist.add(updateServiceItemobj); 
            }
            
            if(existingServiceItemslist != null && !existingServiceItemslist.isEmpty())
                update existingServiceItemslist;
   
            //Updating Rural License Base Entitlement
            if(ruralLicenseWithRuralEntitlementMap != null && !ruralLicenseWithRuralEntitlementMap.isEmpty()) {
                for(RuralLicense__c objRuralLicense : [SELECT Id , BaseEntitlement__c from RuralLicense__c where Id IN: ruralLicenseWithRuralEntitlementMap.keySet()]) {
                    if(ruralLicenseWithRuralEntitlementMap.containsKey(objRuralLicense.Id)) {
                        //Updating Rural License Base Entitlement
                        if(objRuralLicense.BaseEntitlement__c  != null && ruralLicenseWithRuralEntitlementMap.get(objRuralLicense.Id).PermanentTransfersIn__c != null &&  ruralLicenseWithRuralEntitlementMap.get(objRuralLicense.Id).PermanentTransfersOut__c != null) {
                            objRuralLicense.BaseEntitlement__c =  objRuralLicense.BaseEntitlement__c + ruralLicenseWithRuralEntitlementMap.get(objRuralLicense.Id).PermanentTransfersIn__c - ruralLicenseWithRuralEntitlementMap.get(objRuralLicense.Id).PermanentTransfersOut__c;
                            ruralLicenseList.add(objRuralLicense);
                        }
                    }
                }
            }
            
            if(ruralLicenseList != null && !ruralLicenseList.isEmpty())
                update ruralLicenseList;
            
            if(batchErrorList != null && !batchErrorList.isEmpty())
                insert batchErrorList;
            
            //Linking Batch Error with already Renewed Entitlement Records
            List<RuralEntitlement__c> ruralEntitlementBatchErrorList = new List<RuralEntitlement__c>();
            if(alreadyRenewedEntitlementsToBatchErrorMap != null && !alreadyRenewedEntitlementsToBatchErrorMap.isEmpty()) {
                for(Id ruralEntitlementId : alreadyRenewedEntitlementsToBatchErrorMap.keySet()){
                    RuralEntitlement__c ObjRecordEntitlement = new RuralEntitlement__c(Id = ruralEntitlementId ,
                                                                                       BatchError__c =  alreadyRenewedEntitlementsToBatchErrorMap.get(ruralEntitlementId).Id);                    
                    ruralEntitlementBatchErrorList.add(ObjRecordEntitlement);
                }
            }
            if(ruralEntitlementBatchErrorList != null && !ruralEntitlementBatchErrorList.isEmpty())
                update ruralEntitlementBatchErrorList;
        }catch (exception e){
            GlUt_Logger.logException(e);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************l
  	@author         Echo: Vivek Sethi
	@date           07 Dec 2018
    @description    Batch's final method
    *******************************************************************************/
    global void finish(Database.BatchableContext bc){
        Savepoint sp = Database.setSavepoint();
        if(!batchError)
            //updateBRQ(batchRequestQueue,LoBt_Constants.BRQSTATUS); //Checkmarx
            updateBRQ(new list<BatchRequestQueue__c> {batchRequestQueue},LoBt_Constants.BRQSTATUS); 
        else
            //updateBRQ(batchRequestQueue,LoBt_Constants.BRQSTATUSERRORS);     //Checkmarx   
            updateBRQ(new list<BatchRequestQueue__c> {batchRequestQueue},LoBt_Constants.BRQSTATUSERRORS); 
       
    }
    
    /******************************************************************************
  	@author         Echo: Vivek Sethi
	@date           07 Dec 2018
    @param          BatchRequestQueue__c batchRequestQueue
    @return         BatchError__c
    @description    create Batch Error record
	*******************************************************************************/
    public static void createBatchError(BatchRequestQueue__c batchRequestQueue, String errorType, Id FailureRecordId){        
        //create a Batch Error record 
        BatchError__c objBatchError;
        String ruralEntitlementName = '';
        if(errorType == LoBt_Constants.INVALIDPARAMETERSERROR)
            objBatchError = new BatchError__c(BatchRequestQueue__c = batchRequestQueue.Id,
                                              ErrorDetails__c = LoBt_Constants.INVALIDPARAMETERSERROR);
        else {
            if(FailureRecordId != null && mapOfRuralEntitlementIdToRecord.containsKey(FailureRecordId))
                ruralEntitlementName = mapOfRuralEntitlementIdToRecord.get(FailureRecordId).Name;
            objBatchError = new BatchError__c(BatchRequestQueue__c = batchRequestQueue.Id, 
                                              ErrorDetails__c =  LoBt_Constants.RURALENTITLEMENTLABEL + ' ' + ruralEntitlementName + ' ' + LoBt_Constants.ENTITLEMENTRENEWEDERROR);
            
            if(FailureRecordId != null) 
                alreadyRenewedEntitlementsToBatchErrorMap.put(FailureRecordId,objBatchError);
        }
        batchErrorList.add(objBatchError); 
    }
    
    /******************************************************************************
	@author         Echo: Vivek Sethi
	@date           07 Dec 2018
    @param          BatchRequestQueue__c batchRequestQueue , String Status
    @return         BatchRequestQueue__c
    @description    update BRQ status
    *******************************************************************************/
    public static list<BatchRequestQueue__c> updateBRQ(list<BatchRequestQueue__c> batchRequestQueueList , String Status) {
        set<Id> setBRQIds = new set<Id>() ;
        list<BatchRequestQueue__c> listBatchRequestQueueToUpdate = new list<BatchRequestQueue__c>() ;
        for(BatchRequestQueue__c brq : batchRequestQueueList) {
            setBRQIds.add(brq.Id) ;
        }
        for(BatchRequestQueue__c brq :  [Select id,Status__c from BatchRequestQueue__c where Id IN: setBRQIds]) {
            brq.Status__c = Status ;
            listBatchRequestQueueToUpdate.add(brq) ;
        }
        if(!listBatchRequestQueueToUpdate.isEmpty()){
            listBatchRequestQueueToUpdate = (List<BatchRequestQueue__c>) GlUt_FieldSecurity.cleanseFields(listBatchRequestQueueToUpdate, false);
            update listBatchRequestQueueToUpdate ;
        }
        
        return listBatchRequestQueueToUpdate ;
    }
    
}