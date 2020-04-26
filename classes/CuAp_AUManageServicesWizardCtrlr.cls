/******************************************************************************
@author         Echo: Sudhir Kumar
@date           03 Apr 2019
@description    CLB-28: Component controller for AU Manage Services wizard - CuAp_AUManageServicesWizard.cmp
*******************************************************************************/

public with sharing class CuAp_AUManageServicesWizardCtrlr {
	public static WizardObject wizObject;
    private static List<String> serviceFields;    
    private static List<String> serviceItemFields;  
    private static final String CLASS_NAME = 'CuAp_AUManageServicesWizardCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    static{
        //Get Fields from the Service Object
        serviceFields = new List<string>();
        serviceFields.add(LoAp_Constants.Id);
        serviceFields.add(LoAp_Constants.NameLabel);        
        serviceFields.add(GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME);
        serviceFields.add(GlUt_APIConstantsContracts.CONTRACTAPINAME);
        serviceFields.add(GlUt_APIConstantsDevice.DEVICEAPINAME);
      
        serviceFields.add(GlUt_APIConstantsReading.READINGAPINAME);
        serviceFields.add(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME);
        serviceFields.add(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME);
        
        //Get Fields from the Service Item Object
        serviceItemFields = new List<string>();
        serviceItemFields.add(LoAp_Constants.Id);
        serviceItemFields.add(LoAp_Constants.NameLabel);
        serviceItemFields.add(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME);
        serviceItemFields.add(GlUt_APIConstantsServiceItem.STARTDATEAPINAME);
        serviceItemFields.add(GlUt_APIConstantsServiceItem.ENDDATE);
        serviceItemFields.add(GlUt_APIConstantsServiceItem.SERVICEITEMTYPEAPINAME);
        serviceItemFields.add(GlUt_APIConstantsAvailableServiceItem.AVAILABLESERVICEITEMSAPINAME);
        serviceItemFields.add(GlUt_APIConstantsService.DISCHARGEAGREEMENTAPINAME);
        serviceItemFields.add(GlUt_APIConstantsService.SERVICEAPINAME);
    }
    
    public class WizardObject {
        @TestVisible private Id recordId;
        @TestVisible private Id contractId;
        @TestVisible private List<Service__c> serviceTransfers;
        @TestVisible private List<Service__c> removedServices;
        @TestVisible private Date effectiveDate;
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           03 Apr 2019
    @param          String - wizardprop
    @description    Updates the wizard properties
    *******************************************************************************/
    @AuraEnabled
    public static void WizardStatus(String wizardprop) {
        try {
            GlUt_Logger.logDebug(DEBUG);
            // build the wizard object from the wizard properties
            UpdateWizardProperties(wizardprop);
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }        
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           03 Apr 2019
    @param          String - wizardprop
    @description    Updates the wizard properties
    *******************************************************************************/
    public static void UpdateWizardProperties(String wizardprop) {
        
        // strip out all the SObject type references from the json
        wizardprop = wizardprop.replaceAll('"sobjectType":"(.*?)"(,|[^}]*)', '');
        // and deserialise it
        wizObject = (WizardObject)System.JSON.deserializeStrict(wizardprop, WizardObject.class);       
    }
    
     /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           03 Apr 2019
    @param          String - json string of object wizardprop
    @return         Id - contractId
    @description    Method called by wizard to create new services and service items and update the existing service and service items
    *******************************************************************************/
    @AuraEnabled
    public static Id processingServices(String wizardprop) { 
        Savepoint sp = Database.setSavepoint();
        try {
            UpdateWizardProperties(wizardprop);
            
            Set<Id> serviceIds = new Set<Id>();
            Set<Id> supplyPointIds = new Set<Id>();
            Map<Id,Id> mapOfOldServiceId2NewServiceId = new Map<Id,Id>();
            Map<Id,Id> mapOfSPId2DeviceId = new Map<Id,Id>(); 
            List<Service__c> serviceList = new List<Service__c>();
            List<Service__c> newServices = new List<Service__c>();
            List<Service__c> oldServices = new List<Service__c>();
            List<ServiceItem__c> newServiceItemsList = new List<ServiceItem__c>();
            List<ServiceItem__c> oldServiceItemsList = new List<ServiceItem__c>();
            system.debug(DEBUG + ' processingServices-wizObject=> ' + wizObject) ;
            system.debug(DEBUG + ' processingServices-wizObject.serviceTransfers=> ' + wizObject.serviceTransfers) ;
            if(wizObject.serviceTransfers != null && !wizObject.serviceTransfers.isEmpty()){
                for(Integer i=0;i<wizObject.serviceTransfers.size();i++){
                    if(wizObject.effectiveDate >= wizObject.serviceTransfers[i].ServiceStartDate__c || 
                       (wizObject.serviceTransfers[i].ServiceEndDate__c != null && wizObject.effectiveDate < wizObject.serviceTransfers[i].ServiceEndDate__c)){
                        serviceIds.add(wizObject.serviceTransfers[i].Id);
                    }
                }
                system.debug(DEBUG + ' processingServices-serviceIds=> ' + serviceIds) ;
                if(serviceIds != null){
                   
                    
                    // get all the services records based on serviceIds set
                    List<Service__c> serviceLists = (List<Service__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsService.SERVICEAPINAME,
                                                                                                           serviceFields,
                                                                                                           'WHERE ' + LoAp_Constants.Id + 
                                                                                                           ' IN ' + GlUt_FieldSecurity.IdsToString(serviceIds));                     
                    
                    
                    // get all the service items records based on serviceIds set
                    List<ServiceItem__c> serviceItemList = (List<ServiceItem__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME,
                                                                                                                      serviceItemFields,
                                                                                                                      'WHERE ' + GlUt_APIConstantsService.SERVICEAPINAME + 
                                                                                                                      ' IN ' + GlUt_FieldSecurity.IdsToString(serviceIds));   
                    
                    system.debug(DEBUG + ' processingServices-serviceLists=> ' + serviceLists) ;
                    system.debug(DEBUG + ' processingServices-serviceItemList=> ' + serviceItemList) ;
                    for(Service__c objService : serviceLists){
                        Id serviceTransferStart = null;
                        Id serviceTransferEnd = null;
                        
                        
                        // Copy the existing services to the new contract
                        Service__c newService = new Service__c();
                        newService.AvailableService__c = objService.AvailableService__c;
                        newService.BillingContract__c = wizObject.contractId;
                        newService.Device__c = objService.Device__c;
                        
                        newService.Reading__c = serviceTransferStart;
                        newService.ServiceType__c = objService.ServiceType__c;
                        newService.SupplyPoint__c = objService.SupplyPoint__c;
                        newServices.add(newService);
                        
                        objService.Reading__c = serviceTransferEnd;
                        oldServices.add(objService);
                    }
                    system.debug(DEBUG + ' processingServices-newServices=> ' + newServices) ;
                    if(!newServices.isEmpty()){
                        newServices = (List<Service__c>) GlUt_FieldSecurity.cleanseFields(newServices, false);
                        insert newServices;
                    }
                    system.debug(DEBUG + ' processingServices-oldServices=> ' + oldServices) ;
                    oldServices = (List<Service__c>) GlUt_FieldSecurity.cleanseFields(oldServices, false);
                    update oldServices;
                    
                    if(!newServices.isEmpty()){
                        for(Integer iCount=0;iCount<newServices.size();iCount++){
                            mapOfOldServiceId2NewServiceId.put(serviceLists[iCount].Id,newServices[iCount].Id);
                        }
                        
                        for(ServiceItem__c oldServiceItem : serviceItemList){
                            
                            // Created new Service Item associated with new services
                            ServiceItem__c newServiceItem = new ServiceItem__c();
                            newServiceItem.Service__c = mapOfOldServiceId2NewServiceId.get(oldServiceItem.Service__c);
                            newServiceItem.StartDate__c = wizObject.effectiveDate;
                            newServiceItem.EndDate__c = null;
                            newServiceItem.ServiceItemType__c = oldServiceItem.ServiceItemType__c;
                            newServiceItem.AvailableServiceItem__c = oldServiceItem.AvailableServiceItem__c;
                            newServiceItem.DischargeAgreement__c = oldServiceItem.DischargeAgreement__c;
                            newServiceItemsList.add(newServiceItem);
                            // Update the existing service item associated with existing services and marked them closed as a day before Effective Date by user
                            oldServiceItem.EndDate__c = wizObject.effectiveDate.addDays(-1);
			    			oldServiceItem.Ended__c = true; 
                            oldServiceItemsList.add(oldServiceItem);
                        }
                        system.debug(DEBUG + ' processingServices-newServiceItemsList=> ' + newServiceItemsList) ;
                        newServiceItemsList = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(newServiceItemsList, false);
                        insert newServiceItemsList;
                        system.debug(DEBUG + ' processingServices-oldServiceItemsList=> ' + oldServiceItemsList) ;
                        oldServiceItemsList = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(oldServiceItemsList, false);
                        update oldServiceItemsList;
                        return wizObject.contractId;
                    }
                }
            }
            return null;
        }
        catch (exception e) {
            system.debug(DEBUG + ' processingServices-exception=> ' + e) ;
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           03 Apr 2019
    @param          String - json string of object wizardprop
    @return         Id - contractId
    @description    Method called by wizard to remove Services
    *******************************************************************************/
    @AuraEnabled
    public static Id removedServices(String wizardprop) { 
        Savepoint sp = Database.setSavepoint();
        try {            
            UpdateWizardProperties(wizardprop);
            Set<Id> serviceIds = new Set<Id>();
            Map<Id,List<Reading__c>> mapOfDeviceId2Readings = new Map<Id,List<Reading__c>>();
            Map<Id,Id> mapOfSPId2DeviceId = new Map<Id,Id>();  
            Set<Id> supplyPointIds = new Set<Id>();
            List<ServiceItem__c> oldServiceItemsList = new List<ServiceItem__c>();
            List<Service__c> oldServices = new List<Service__c>();
            
            system.debug(DEBUG + ' removedServices-wizObject=> ' + wizObject) ;
            if(wizObject.removedServices != null && !wizObject.removedServices.isEmpty()){
                for(Service__c objService : wizObject.removedServices){
                    serviceIds.add(objService.Id);
                }
                system.debug(DEBUG + ' removedServices-serviceIds=> ' + serviceIds) ;
                if(serviceIds != null){                    
                   
                    // get all the service items records based on serviceIds set
                    
                    List<ServiceItem__c> serviceItemLists = (List<ServiceItem__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME,
                                                                                                                       new List<String>{LoAp_Constants.Id,
                                                                                                                           GlUt_APIConstantsServiceItem.ENDDATE},
                                                                                                                       'WHERE ' + GlUt_APIConstantsService.SERVICEAPINAME + 
                                                                                                                       ' IN ' + GlUt_FieldSecurity.IdsToString(serviceIds)); 
                    
                    
                    for(ServiceItem__c objServiceItem : serviceItemLists){
                        objServiceItem.EndDate__c = wizObject.effectiveDate;
						objServiceItem.Ended__c = true;
                        oldServiceItemsList.add(objServiceItem);
                    }
                    system.debug(DEBUG + ' removedServices-oldServiceItemsList=> ' + oldServiceItemsList) ;
                    oldServiceItemsList = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(oldServiceItemsList, false);
                    update oldServiceItemsList;
                    return wizObject.contractId;
                }
            }
            return null;
        }
        catch (exception e) {
            system.debug(DEBUG + ' removedServices-exception=> ' + e) ;
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
}