/******************************************************************************
@author         Echo: Amit K.
@date           03 May 2018
@description    Handler for Heroku Bill Calculation trigger
Revision        06 Jun 2018, P Dixon - added pending bill events status update
*******************************************************************************/
public with sharing class GlUt_HerokuBillCalculationStatusHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_HerokuBillCalculationStatusHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    // Maps of the related records that will be updated by this trigger
    Map<Id, BillCalculation__c> billCalculationsToUpdate;
    Map<Id, BillEvent__c> billEventsToUpdate;
    
    /******************************************************************************
    @author         Echo: Amit K.
    @date           03 May 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void MainEntry(GlUt_TriggerHandlerObj inputParam) {
        
        // initialise related records maps
        billCalculationsToUpdate = new Map<Id, BillCalculation__c>();
        billEventsToUpdate = new Map<Id, BillEvent__c>();
    
        try {
            /* This is a Heroku mastered object so we shouldn't be modifying any fields on it */
            /* Therfore before Insert/Update triggers not required */
            if (inputParam.isInsert && inputParam.isAfter) {
                
                // update fields on related records
                updateRelatedRecords(inputParam.newmap);
                updateBillEventRecords(inputParam.newmap);
                // update  Bulk Write Off record
                updateBulkWriteOff(inputParam.newlist);  // AT-3703
            }
            if (inputParam.isUpdate && inputParam.isAfter) {
            }
            if (inputParam.isDelete && inputParam.isBefore) {
            }
            if (inputParam.isDelete && inputParam.isAfter) {
            }
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        
        finally {
            
            // update the related records
            if (!billCalculationsToUpdate.isEmpty()) update billCalculationsToUpdate.values();
            if (!billEventsToUpdate.isEmpty()) update billEventsToUpdate.values();
            
            // Reset the active function to null in case this class was first in stack
            // this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         Echo: Amit K.
    @date           03 May 2018
    @param          Map<Id, SObject> - newMap
    @description    Updates Status on BillCalculation for new Heroku Bill Calculation record inserted
    @revision       Ankit Gangwani, AT-3892, AT-3899 Updates the Ended__c checkbox as false for all the Service Items related to Billing Contract of Bill Calculation
	@revision		Echo: AT-3489: Sudhir Kumar: Updated Ended__c flag of Site Supply
    *******************************************************************************/
    public void updateRelatedRecords(Map<Id, SObject> newMap) {
        system.debug('SK-updateRelatedRecords-newMap=> ' + newMap);
         // Create Map of Bill Calc Id having Heroku Bill Calculation record
        Map<Id, HerokuBillCalculationStatus__c> mapOfBillCalcId2HerokuBillCalc = new Map<Id, HerokuBillCalculationStatus__c>();
        Set<Id> serviceIdsSet = new Set<Id>();
        Set<Id> siteSupplyPointIdsSet ; // AT-3489
        list<SiteSupply__c> listSiteSupplyToUpdate ; // AT-3489
        Set<Id> billingContractIdsSet = new Set<Id>();        
        Map<Id,ServiceItem__c> mapOfServiceItemId2ServiceItemObject = new Map<Id,ServiceItem__c>();
        for (HerokuBillCalculationStatus__c herokuBillCalculation : (List<HerokuBillCalculationStatus__c>)newMap.values()) {
            mapOfBillCalcId2HerokuBillCalc.put(herokuBillCalculation.BillCalculation__c, herokuBillCalculation);
        }
        if (!mapOfBillCalcId2HerokuBillCalc.isEmpty()) {
            
            // for each related bill calculation
            for (BillCalculation__c billCalculation : [select Id, Status__c, BillingContract__c from BillCalculation__c where Id in :mapOfBillCalcId2HerokuBillCalc.keySet()]) {
                system.debug('Ank-billCalculation = '+billCalculation);
                // Stamp the Heroku Bill Calculation record Status field to corresponding Bill Calculation record status field.
                if ((mapOfBillCalcId2HerokuBillCalc.containsKey(billCalculation.Id) && 
                     billCalculation.Status__c != System.Label.BlIn_BillCalculationStatusCompleted) && 
                    ((mapOfBillCalcId2HerokuBillCalc.get(billCalculation.Id).Status__c == System.Label.BlIn_BillCalculationStatusError) || 
                     (string.isBlank(mapOfBillCalcId2HerokuBillCalc.get(billCalculation.Id).BillHerokuPostgresId__c) && 
                      mapOfBillCalcId2HerokuBillCalc.get(billCalculation.Id).Status__c == System.Label.BlIn_BillCalculationStatusCompleted))) {
                          
                          billCalculation.Status__c = System.Label.BlIn_BillCalculationStatusCompleted;
                          billCalculationsToUpdate.put(billCalculation.Id, billCalculation);
                                                   
                      }
                if(billCalculation.Status__c == System.Label.BlIn_BillCalculationStatusCompleted){
                    // AT-3892, AT-3899 
                    if(billCalculation.BillingContract__c != null){
                        billingContractIdsSet.add(billCalculation.BillingContract__c);
                    }
                }
            }
            
            // AT-3892, AT-3899 
            //set<Id> setSiteSupplyId = new set<Id>() ;
            system.debug('SK-billingContractIdsSet=> ' + billingContractIdsSet);
            if(billingContractIdsSet != null && billingContractIdsSet.size() > 0){
                siteSupplyPointIdsSet = new Set<Id>() ; // AT-3489
                
                for(Service__c objService : [SELECT Id, BillingContract__c, SupplyPoint__c FROM Service__c WHERE BillingContract__c IN :billingContractIdsSet]){	// AT-3489
                    serviceIdsSet.add(objService.Id);
                    //supplyPointIdsSet.add(objService.SupplyPoint__c) ; // AT-3489
                }
				
                list<Bill__c> listBill = [SELECT Id, (SELECT Id, SiteSupply__c FROM BillItems__r) FROM Bill__c WHERE BillingContract__c IN: billingContractIdsSet] ;
                system.debug('SK-listBill=> ' + listBill);
                if(listBill != null && !listBill.isEmpty()) {
                    for(Bill__c bill : listBill) {
                        for(BillItem__c billItem : bill.BillItems__r) {
                            if(billItem.SiteSupply__c != null) siteSupplyPointIdsSet.add(billItem.SiteSupply__c) ;
                        }
                    }
                }
                if(serviceIdsSet != null && serviceIdsSet.size() > 0){
                    for(ServiceItem__c objServiceItem : [SELECT Id, Service__c, Ended__c FROM ServiceItem__c WHERE Service__c IN :serviceIdsSet]){
                        objServiceItem.Ended__c = false;
                        if(!mapOfServiceItemId2ServiceItemObject.containsKey(objServiceItem.Id)) {
                            mapOfServiceItemId2ServiceItemObject.put(objServiceItem.Id,objServiceItem);
                        }
                    }
                    //Start: AT-3489: Site Supply Points
                    System.debug('siteSupplyPointIdsSet=> ' + siteSupplyPointIdsSet);
                    if(siteSupplyPointIdsSet != null && !siteSupplyPointIdsSet.isEmpty()) {
                        listSiteSupplyToUpdate = new list<SiteSupply__c>() ;
                        list<SiteSupply__c> listSiteSupply = [SELECT Id, SiteSupplyPoint__c, SupplyPoint__c, Ended__c FROM SiteSupply__c WHERE Id IN: siteSupplyPointIdsSet AND Ended__c = true] ;
                        System.debug('listSiteSupply=> ' + listSiteSupply) ;
                        for(SiteSupply__c siteSupplyObj : listSiteSupply) {
                            siteSupplyObj.Ended__c = false ;
                            listSiteSupplyToUpdate.add(siteSupplyObj) ;
                        }
                    }
                    System.debug('listSiteSupplyToUpdate=> ' + listSiteSupplyToUpdate);
                    if(listSiteSupplyToUpdate != null && !listSiteSupplyToUpdate.isEmpty()) {
                        listSiteSupplyToUpdate = (list<SiteSupply__c>) GlUt_FieldSecurity.cleanseFields(listSiteSupplyToUpdate, false) ;
                        Database.update(listSiteSupplyToUpdate) ;
                    } //End: AT-3489
                }
            }
            if(mapOfServiceItemId2ServiceItemObject != null && mapOfServiceItemId2ServiceItemObject.size() > 0){
                List<ServiceItem__c> listServiceItem = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(mapOfServiceItemId2ServiceItemObject.values(), false);
                update listServiceItem;
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           06 Jun 2018
    @param          Map<Id, SObject> - newMap
    @description    Updates status on related 'Pending' bill events
    *******************************************************************************/
    public void updateBillEventRecords(Map<Id, SObject> newMap) {
        
         // create a set of the related contract Ids
        Set<Id> contractIds = new Set<Id>();
        
        for (HerokuBillCalculationStatus__c herokuBillCalculation : (List<HerokuBillCalculationStatus__c>)newMap.values()) {
            contractIds.add(herokuBillCalculation.BillingContract__c);
        }

        // get related pending bill event records
        for (BillEvent__c billEvent : [select Id, 
                                            Status__c
                                    from BillEvent__c
                                    where BillingContract__c in :contractIds
                                        and Status__c = :GlUt_APIConstantsBillEvent.PENDINGBILLEVENTSTATUS]) {
            
            // update the status            
            billEvent.Status__c = GlUt_APIConstantsBillEvent.PROCESSEDBILLEVENTSTATUS;      // 'Processed';
            billEventsToUpdate.put(billEvent.Id, billEvent);  
        }
    }
    
    /******************************************************************************
    @author         Neha Rajput
    @date           20 Sep 2018
    @param          List<HerokuBillCalculationStatus__c> newList
    @description    builds to update BulkWrite Off Record status where Heroku Bill 
					Calculation Status is associated with a Bulk Write Off record 
					(AT-3703 )
    Revisions		
    *******************************************************************************/
    private void updateBulkWriteOff(List<HerokuBillCalculationStatus__c> newlist){
        
    	List<BillWriteOff__c> billWriteOffList = new List<BillWriteOff__c>();
        List<Id> billWriteOffRecordList = new List<Id>();
        
        for(HerokuBillCalculationStatus__c objHerokuBillCalculationStatus: newlist){
            if(objHerokuBillCalculationStatus.BillWriteOff__c != null)
            	billWriteOffRecordList.add(objHerokuBillCalculationStatus.BillWriteOff__c);
        }        
        
        if(billWriteOffRecordList.size() > 0){
            // Update BillWriteOff Record Status to 'Error' where Heroku Bill Calculation Status is associated with a Bulk Write Off record
            for(BillWriteOff__c objBillWriteOff: [SELECT Id,Status__c FROM BillWriteOff__c WHERE Id IN: billWriteOffRecordList ]){
                objBillWriteOff.Status__c = GlUt_Constants.ERROR;
                billWriteOffList.add(objBillWriteOff);
            }
            
            if(billWriteOffList.size() > 0){
                billWriteOffList = (List<BillWriteOff__c>) GlUt_FieldSecurity.cleanseFields(billWriteOffList, false); 
                database.update(billWriteOffList);
            }    
        }        
    }
}