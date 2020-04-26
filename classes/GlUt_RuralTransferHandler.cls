public class GlUt_RuralTransferHandler extends GlUt_TriggerHandlerBase {
    // Variable declaration
    private static final String CLASS_NAME = 'GlUt_RuralTransferHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    // End variable declaration
    Map<Id, RuralTransfer__c> transferFromWithRuralTransferMap = new  Map<Id, RuralTransfer__c>();
    Map<Id, RuralTransfer__c> transferToWithRuralTransferMap = new  Map<Id, RuralTransfer__c>();
    Map<Id,RuralEntitlement__c> ruralLicenseWithRuralEntitlementMap = new Map<Id,RuralEntitlement__c>();

    
    /*********************************************************************************************************************************************************************
	@author        Echo: Vivek Sethi
	@date          17-Dec-2018
	@param         GlUt_TriggerHandlerObj inputParam
	@return        void
	@description   This method is used to invoke method from trigger
	*********************************************************************************************************************************************************************/
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {
        try {   
            if (inputParam.isInsert && inputParam.isBefore) {
                
            }
            if (inputParam.isInsert && inputParam.isAfter) { 
                createNewServiceItem(inputParam.newlist);
            }
            if (inputParam.isUpdate && inputParam.isBefore) {
            }
            if (inputParam.isUpdate && inputParam.isAfter) {   
                
            }
            if (inputParam.isDelete && inputParam.isBefore) {
                
            }
            if (inputParam.isDelete && inputParam.isAfter) {
                
            }
        } catch (Exception ex) {
            system.debug('Line Number:=' + ex.getLineNumber());
            GlUt_Logger.logException(ex);
            
        } finally {
            
        }
        //Reset the active function to null in case this class was first in stack
        //this indicates that the trigger has finished firing so it no longer needs to control flow
        GlUt_CentralDispatcher.activeFunction = null;
        GlUt_Logger.writeLogsToDatabase();
        
    }
    /*********************************************************************************************************************************************************************
	@author        Echo: Vivek Sethi
	@date          17-Dec-2018
	@param         List<RuralTransfer__c> newlist, Map<Id,sObject> oldmap
	@return        void
	@description   This method is used to create new service item 
	*********************************************************************************************************************************************************************/
    private void createNewServiceItem(List<RuralTransfer__c> newlist) {
       List<ruralEntitlement__c> ruralEntitlementList = new List<ruralEntitlement__c> ();
        
        for(RuralTransfer__c ruralTransferObj : newlist){
            if(ruralTransferObj.TransferFrom__c != null)
                transferFromWithRuralTransferMap.put(ruralTransferObj.TransferFrom__c , ruralTransferObj);
            if(ruralTransferObj.TransferTo__c != null)
                transferToWithRuralTransferMap.put(ruralTransferObj.TransferTo__c , ruralTransferObj);
        }
      
        /********************************************************TRANSFER FROM BLOCK STARTS****************************************************************/
        if(transferFromWithRuralTransferMap != null && !transferFromWithRuralTransferMap.isEmpty()) {
            
            for(RuralEntitlement__c ruralEntitlementObj : [Select Id, PermanentTransfersOut__c, TemporaryTransfersOut__c, RuralLicense__c FROM RuralEntitlement__c WHERE Id IN: transferFromWithRuralTransferMap.keySet()]){
                
                if(transferFromWithRuralTransferMap.get(ruralEntitlementObj.Id).TransferType__c  != null && transferFromWithRuralTransferMap.get(ruralEntitlementObj.Id).TransferAmount__c != null) {
                    
                    //If the Transfer type is permanent. Adding the Transfer Amount to the Permanent Transfers Out field value.
                    if(transferFromWithRuralTransferMap.get(ruralEntitlementObj.Id).TransferType__c ==   GlUt_Constants.PERMANENT) {
                        if(ruralEntitlementObj.PermanentTransfersOut__c == null)
                            ruralEntitlementObj.PermanentTransfersOut__c = 0.0;
                        ruralEntitlementObj.PermanentTransfersOut__c =  ruralEntitlementObj.PermanentTransfersOut__c + transferFromWithRuralTransferMap.get(ruralEntitlementObj.Id).TransferAmount__c;
                    }
                    //If the Transfer type is temporary. Adding the Transfer Amount to the Temporary Transfers Out field value. 
                    if(transferFromWithRuralTransferMap.get(ruralEntitlementObj.Id).TransferType__c ==  GlUt_Constants.TEMPORARY) {
                        if(ruralEntitlementObj.TemporaryTransfersOut__c == null)
                            ruralEntitlementObj.TemporaryTransfersOut__c = 0.0;
                        ruralEntitlementObj.TemporaryTransfersOut__c = ruralEntitlementObj.TemporaryTransfersOut__c + transferFromWithRuralTransferMap.get(ruralEntitlementObj.Id).TransferAmount__c;
                    }
                    ruralEntitlementList.add(ruralEntitlementObj);
                }
            } 
            if(ruralEntitlementList != null && !ruralEntitlementList.isEmpty()){
                update ruralEntitlementList;
                for(RuralEntitlement__c ruralEntitlementObj : [Select Id, BaseVolumewithTransfers__c, RuralLicense__c FROM RuralEntitlement__c WHERE Id in: ruralEntitlementList]){
                    if(!ruralLicenseWithRuralEntitlementMap.containsKey(ruralEntitlementObj.RuralLicense__c))
                        ruralLicenseWithRuralEntitlementMap.put(ruralEntitlementObj.RuralLicense__c, ruralEntitlementObj);
                }
                if(ruralLicenseWithRuralEntitlementMap != null && !ruralLicenseWithRuralEntitlementMap.isEmpty())
                    CreateandAmendServiceItem(ruralLicenseWithRuralEntitlementMap, transferFromWithRuralTransferMap);
            }
        }
        ruralEntitlementList.clear();
        ruralLicenseWithRuralEntitlementMap.clear();
        
        /********************************************************TRANSFER TO BLOCK STARTS******************************************************************/
        if(transferToWithRuralTransferMap != null && !transferToWithRuralTransferMap.isEmpty()) {
            
            for(RuralEntitlement__c ruralEntitlementObj : [Select Id, PermanentTransfersIn__c, TemporaryTransfersIn__c, RuralLicense__c FROM RuralEntitlement__c WHERE Id IN: transferToWithRuralTransferMap.keySet()]){
                if(transferToWithRuralTransferMap.get(ruralEntitlementObj.Id).TransferType__c  != null && transferToWithRuralTransferMap.get(ruralEntitlementObj.Id).TransferAmount__c != null) {
                    
                    //If the Transfer type is temporary . Adding the Transfer Amount to the temporary  Transfers In field value.
                    if(transferToWithRuralTransferMap.get(ruralEntitlementObj.Id).TransferType__c == GlUt_Constants.PERMANENT) {
                        if(ruralEntitlementObj.PermanentTransfersIn__c == null)
                            ruralEntitlementObj.PermanentTransfersIn__c = 0.0;
                        ruralEntitlementObj.PermanentTransfersIn__c = ruralEntitlementObj.PermanentTransfersIn__c + transferToWithRuralTransferMap.get(ruralEntitlementObj.Id).TransferAmount__c;
                    }
                    //If the Transfer type is temporary. Adding the Transfer Amount to the Temporary Transfers In field value. 
                    if(transferToWithRuralTransferMap.get(ruralEntitlementObj.Id).TransferType__c ==   GlUt_Constants.TEMPORARY) {
                        if(ruralEntitlementObj.TemporaryTransfersIn__c == null)
                            ruralEntitlementObj.TemporaryTransfersIn__c = 0.0;
                        ruralEntitlementObj.TemporaryTransfersIn__c = ruralEntitlementObj.TemporaryTransfersIn__c + transferToWithRuralTransferMap.get(ruralEntitlementObj.Id).TransferAmount__c;
                    }
                    ruralEntitlementList.add(ruralEntitlementObj);
                }
            }
        }
        
        if(ruralEntitlementList != null && !ruralEntitlementList.isEmpty()){
            update ruralEntitlementList;
            for(RuralEntitlement__c ruralEntitlementObj : [Select Id, BaseVolumewithTransfers__c, RuralLicense__c FROM RuralEntitlement__c WHERE Id in: ruralEntitlementList]){
                if(!ruralLicenseWithRuralEntitlementMap.containsKey(ruralEntitlementObj.RuralLicense__c))
                    ruralLicenseWithRuralEntitlementMap.put(ruralEntitlementObj.RuralLicense__c, ruralEntitlementObj);
            }
            if(ruralLicenseWithRuralEntitlementMap != null && !ruralLicenseWithRuralEntitlementMap.isEmpty())
                CreateandAmendServiceItem(ruralLicenseWithRuralEntitlementMap,transferToWithRuralTransferMap);
        }
        ruralEntitlementList.clear();
        ruralLicenseWithRuralEntitlementMap.clear();
    }
    
    
    /*********************************************************************************************************************************************************************
	@author        Echo: Vivek Sethi
	@date          17-Dec-2018
	@param         Map<Id,RuralEntitlement__c> ruralLicenseWithRuralEntitlementMap,Map<Id, RuralTransfer__c> transferToandFromWithRuralTransferMap
	@return        void
	@description   This method is used to End Existing Service Item and create new Service Item
	*********************************************************************************************************************************************************************/
    Private void CreateandAmendServiceItem(Map<Id,RuralEntitlement__c> ruralLicenseWithRuralEntitlementMap ,Map<Id, RuralTransfer__c> transferToandFromWithRuralTransferMap){
        Map<Id,RuralEntitlement__c> ruralEntitlementIdwithRuralEntitlementMap = new Map<Id,RuralEntitlement__c>();
        Map<Id,RuralLicense__c> ruralEntitlementIdWithRurallicenseMap = new Map<Id,RuralLicense__c>();   
        Map<Id,ServiceItem__c> oldServiceItemIdwithNewServiceItemMap = new Map<Id,ServiceItem__c>(); 
        List<ServiceItem__c> serviceItemslist = new List<ServiceItem__c>();
        List<ServiceItem__c> existingServiceItemslist = new List<ServiceItem__c>();
        
        if(ruralLicenseWithRuralEntitlementMap != null && !ruralLicenseWithRuralEntitlementMap.isEmpty()) {
            for(RuralLicense__c objRuralLicense : [SELECT Id , InfrastructureCharge__c ,HeadworkInfrastructureCharge__c  , BaseEntitlement__c from RuralLicense__c where Id IN: ruralLicenseWithRuralEntitlementMap.keySet()]) {
                ruralEntitlementIdWithRurallicenseMap.put(ruralLicenseWithRuralEntitlementMap.get(objRuralLicense.Id).Id,objRuralLicense);
                ruralEntitlementIdwithRuralEntitlementMap.put(ruralLicenseWithRuralEntitlementMap.get(objRuralLicense.Id).Id,ruralLicenseWithRuralEntitlementMap.get(objRuralLicense.Id));
            }
        }
 
        //license InfraStructure Charges
        if(transferToandFromWithRuralTransferMap != null && !transferToandFromWithRuralTransferMap.isEmpty()) {
            for(ServiceItem__c  objServiceItem :  [SELECT Id, Service__c, RuralEntitlement__c, AvailableServiceItem__c, ServiceItemType__c , StartDate__c, EndDate__c, Quantity__c 
                                                   from ServiceItem__c
                                                   where RuralEntitlement__c IN: transferToandFromWithRuralTransferMap.Keyset()
                                                   and EndDate__c =: null 
                                                   order by StartDate__c Desc] ) 
                
            {
                //Find the latest Service Item Records  (Headwork Infrastructure Charge Or Infrastructure Charge)  
                if(ruralEntitlementIdWithRurallicenseMap.containsKey(objServiceItem.RuralEntitlement__c) &&
                   transferToandFromWithRuralTransferMap.get(objServiceItem.RuralEntitlement__c).TransferDate__c != null && 
                   objServiceItem.StartDate__c < transferToandFromWithRuralTransferMap.get(objServiceItem.RuralEntitlement__c).TransferDate__c &&
                   (ruralEntitlementIdWithRurallicenseMap.get(objServiceItem.RuralEntitlement__c).InfrastructureCharge__c != null && 
                    ruralEntitlementIdWithRurallicenseMap.get(objServiceItem.RuralEntitlement__c).InfrastructureCharge__c ==  objServiceItem.ServiceItemType__c) ||
                   (ruralEntitlementIdWithRurallicenseMap.get(objServiceItem.RuralEntitlement__c).HeadworkInfrastructureCharge__c != null && 
                    ruralEntitlementIdWithRurallicenseMap.get(objServiceItem.RuralEntitlement__c).HeadworkInfrastructureCharge__c ==  objServiceItem.ServiceItemType__c)) 
                { 
                    ServiceItem__c newServiceItem = new ServiceItem__c();
                    newServiceItem.Service__c = objServiceItem.Service__c;
                    newServiceItem.ServiceItemType__c = objServiceItem.ServiceItemType__c;
                    newServiceItem.AvailableServiceItem__c = objServiceItem.AvailableServiceItem__c;
                    newServiceItem.StartDate__c = transferToandFromWithRuralTransferMap.get(objServiceItem.RuralEntitlement__c).TransferDate__c;
                    newServiceItem.RuralEntitlement__c =  objServiceItem.RuralEntitlement__c; 
                    
                    if(ruralEntitlementIdwithRuralEntitlementMap.get(objServiceItem.RuralEntitlement__c).BaseVolumewithTransfers__c != null){
                        Decimal baseVolume = ruralEntitlementIdwithRuralEntitlementMap.get(objServiceItem.RuralEntitlement__c).BaseVolumewithTransfers__c;
                        newServiceItem.Quantity__c = baseVolume/1000; 
                    }
                    
                    //Ending current Service Item to Transfer Date - 1 
                    objServiceItem.EndDate__c = transferToandFromWithRuralTransferMap.get(objServiceItem.RuralEntitlement__c).TransferDate__c - 1;
                    serviceItemslist.add(newServiceItem);
                    serviceItemslist.add(objServiceItem);
                    oldServiceItemIdwithNewServiceItemMap.put(objServiceItem.Id,newServiceItem);
                    
                }
            }
        }
        
        if(serviceItemslist != null && !serviceItemslist.isEmpty())
            upsert serviceItemslist;
        
        if(oldServiceItemIdwithNewServiceItemMap != null && !oldServiceItemIdwithNewServiceItemMap.isEmpty()) {
            //Updating  currentInfrastructureCharge Amended By to the Id
            for(Id serviceItemObj : oldServiceItemIdwithNewServiceItemMap.keySet()) {
                ServiceItem__c updateServiceItemobj = new ServiceItem__c(Id = serviceItemObj,
                                                                         AmendedByServiceItem__c = oldServiceItemIdwithNewServiceItemMap.get(serviceItemObj).Id);
                existingServiceItemslist.add(updateServiceItemobj); 
            }
        }
        if(existingServiceItemslist != null && !existingServiceItemslist.isEmpty())
            update existingServiceItemslist;
    }
}