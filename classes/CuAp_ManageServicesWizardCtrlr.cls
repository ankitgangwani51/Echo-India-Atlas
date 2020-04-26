/******************************************************************************
@author         Echo: Ankit Gangwani
@date           02 August 2018
@description    Component controller for Manage Services wizard
                AT-4891/2 Code Check Marx Changes for FLS INSERT/UPDATE
*******************************************************************************/
public class CuAp_ManageServicesWizardCtrlr {
    
    public static WizardObject wizObject;
    private static List<String> serviceFields;    
    private static List<String> serviceItemFields;  
    private static final String CLASS_NAME = 'CuAp_ManageServicesWizardCtrlr';
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
        @TestVisible private List<AvailableService__c> availableServiceTransfers;
        @TestVisible private List<Reading__c> newReadings;
        @TestVisible private Date effectiveDate;
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           02 August 2018
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
    @author         Echo: Ankit Gangwani
    @date           02 August 2018
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
    @author         Echo: Ankit Gangwani
    @date           02 August 2018
    @param          List<Reading__c>
	@return 		Map<Id,List<Reading__c>>
    @description    Updates the wizard properties
    *******************************************************************************/
    public static Map<Id,List<Reading__c>> buildReadingsMap(List<Reading__c> readingList) {
        Map<Id,List<Reading__c>> mapOfDeviceId2Readings = new Map<Id,List<Reading__c>>();
        if(!readingList.isEmpty()){
            for(Reading__c objReading : readingList){
                if(!mapOfDeviceId2Readings.containsKey(objReading.Device__c)){
                    mapOfDeviceId2Readings.put(objReading.Device__c, new List<Reading__c>());
                }
                mapOfDeviceId2Readings.get(objReading.Device__c).add(objReading);                
            }
            return mapOfDeviceId2Readings;
        }
        return null;               
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           02 August 2018
    @param          String - json string of object wizardprop
    @return         Id - contractId
    @description    Method called by wizard to create new services and service items and update the existing service and service items
    *******************************************************************************/
    @AuraEnabled
    public static Id processingServices(String wizardprop, String readings) { 
        Savepoint sp = Database.setSavepoint();
        try {
            UpdateWizardProperties(wizardprop);
            Map<Id,List<Reading__c>> mapOfDeviceId2Readings = new Map<Id,List<Reading__c>>();

            if(readings != 'null'){
                List<Reading__c> readingList = (List<Reading__c>)JSON.deserialize(readings, List<Reading__c>.class);
                mapOfDeviceId2Readings = buildReadingsMap(readingList);
            }
            
            Set<Id> serviceIds = new Set<Id>();
            Set<Id> supplyPointIds = new Set<Id>();
            Map<Id,Id> mapOfOldServiceId2NewServiceId = new Map<Id,Id>();
            Map<Id,Id> mapOfSPId2DeviceId = new Map<Id,Id>(); 
            List<Service__c> serviceList = new List<Service__c>();
            List<Service__c> newServices = new List<Service__c>();
            List<Service__c> oldServices = new List<Service__c>();
            List<ServiceItem__c> newServiceItemsList = new List<ServiceItem__c>();
            List<ServiceItem__c> oldServiceItemsList = new List<ServiceItem__c>();
            
            System.debug('wizObject.serviceTransfers = '+wizObject.serviceTransfers);
                
            if(!wizObject.serviceTransfers.isEmpty()){
                for(Integer i=0;i<wizObject.serviceTransfers.size();i++){
                    if(wizObject.effectiveDate >= wizObject.serviceTransfers[i].ServiceStartDate__c || 
                       (wizObject.serviceTransfers[i].ServiceEndDate__c != null && wizObject.effectiveDate < wizObject.serviceTransfers[i].ServiceEndDate__c)){
                        serviceIds.add(wizObject.serviceTransfers[i].Id);
                    }
                }
                
                if(serviceIds != null){
                    /*List<Service__c> serviceLists = [SELECT Id, Name,
                                                     AvailableService__c,
                                                     BillingContract__c,
                                                     Device__c,
                                                     DischargeAgreement__c,
                                                     Reading__c,
                                                     ServiceType__c,
                                                     SupplyPoint__c                                             
                                                     FROM Service__c WHERE Id = :serviceIds];*/
                    
                    // get all the services records based on serviceIds set
                    List<Service__c> serviceLists = (List<Service__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsService.SERVICEAPINAME,
                                                                                                           serviceFields,
                                                                                                           'WHERE ' + LoAp_Constants.Id + 
                                                                                                           ' IN ' + GlUt_FieldSecurity.IdsToString(serviceIds));                     
                    
                    if(!serviceLists.isEmpty()){
                        for(Service__c service : serviceLists){
                            supplyPointIds.add(service.SupplyPoint__c);
                        }
                        /*List<SupplyPointDevice__c> spdLists = [SELECT Id, SupplyPoint__c, Device__c FROM SupplyPointDevice__c WHERE SupplyPoint__c = :supplyPointIds];*/
                        
                        // get all the Supply Point Device records based on Supply Point Ids set
                        List<SupplyPointDevice__c> spdLists = (List<SupplyPointDevice__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME,
                                                                                                                               new List<String>{LoAp_Constants.Id,GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,GlUt_APIConstantsDevice.DEVICEAPINAME},
                                                                                                                               'WHERE ' + GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME + 
                                                                                                                               ' IN ' + GlUt_FieldSecurity.IdsToString(supplyPointIds)); 
                        
                        if(!spdLists.isEmpty()){
                            for(SupplyPointDevice__c spd : spdLists){
                                mapOfSPId2DeviceId.put(spd.SupplyPoint__c , spd.Device__c);
                            }
                        }
                    }
                    /*List<ServiceItem__c> serviceItemList = [SELECT Id, Name, ServiceType__c, StartDate__c, EndDate__c, 
                                                            ServiceItemType__c, AvailableServiceItem__c, 
                                                            DischargeAgreement__c, Service__c FROM ServiceItem__c WHERE Service__c = :serviceIds];*/
                    
                    // get all the services records based on serviceIds set
                    List<ServiceItem__c> serviceItemList = (List<ServiceItem__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME,
                                                                                                                      serviceItemFields,
                                                                                                                      'WHERE ' + GlUt_APIConstantsService.SERVICEAPINAME + 
                                                                                                                      ' IN ' + GlUt_FieldSecurity.IdsToString(serviceIds));   
                    
                    
                    for(Service__c objService : serviceLists){
                        Id serviceTransferStart = null;
                        Id serviceTransferEnd = null;
                        
                        if(mapOfSPId2DeviceId.containsKey(objService.SupplyPoint__c)){
                            if(mapOfDeviceId2Readings.containsKey(mapOfSPId2DeviceId.get(objService.SupplyPoint__c))){
                                List<Reading__c> readingLists = mapOfDeviceId2Readings.get(mapOfSPId2DeviceId.get(objService.SupplyPoint__c));
                                for(Reading__c objReading : readingLists){
                                    if(objReading.ReadingType__c == System.Label.CuAp_ServiceTransferStart)
                                        serviceTransferStart = objReading.Id;
                                    if(objReading.ReadingType__c == System.Label.CuAp_ServiceTransferEnd)
                                        serviceTransferEnd = objReading.Id;
                                }
                            }
                        }
                        
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
                    if(!newServices.isEmpty()){
                        newServices = (List<Service__c>) GlUt_FieldSecurity.cleanseFields(newServices, false);
                        insert newServices;
                    }
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
			                oldServiceItem.Ended__c = true; // AT-3892, AT-3895 
                            oldServiceItemsList.add(oldServiceItem);
                        }
                        newServiceItemsList = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(newServiceItemsList, false);
                        insert newServiceItemsList;
                        GlUt_ContractUtilities.CreateGroupWithGroupItem(newServiceItemsList,null,null); //UL-169 Changes Starts/Ends Here.
                        oldServiceItemsList = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(oldServiceItemsList, false);
                        update oldServiceItemsList;
                        return wizObject.contractId;
                    }
                }
            }
            return null;
        }
        catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            System.debug('exception = '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           02 August 2018
    @param          String - json string of object wizardprop
    @return         Id - contractId
    @description    Method called by wizard to create new readings
    *******************************************************************************/
    @AuraEnabled
    public static List<Reading__c> processingReadings(String wizardprop) { 
        Savepoint sp = Database.setSavepoint();
        try {
            // build the wizard object from the wizard properties
            UpdateWizardProperties(wizardprop);
            if(!wizObject.newReadings.isEmpty()) {
            	wizObject.newReadings = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(wizObject.newReadings, false);
                insert wizObject.newReadings;
                return wizObject.newReadings;
            }   
            return null;
        }
        catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            System.debug('exception = '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           02 August 2018
    @param          String - json string of object wizardprop
    @return         Id - contractId
    @description    Method called by wizard to create new readings
    *******************************************************************************/
    @AuraEnabled
    public static Id processingAvailableServices(String wizardprop, String readings) { 
        Savepoint sp = Database.setSavepoint();
        try {
            // build the wizard object from the wizard properties
            UpdateWizardProperties(wizardprop);
            
            Map<Id,List<Reading__c>> mapOfDeviceId2Readings = new Map<Id,List<Reading__c>>();
            if(readings != 'null'){
                List<Reading__c> readingList = (List<Reading__c>)JSON.deserialize(readings, List<Reading__c>.class);
                mapOfDeviceId2Readings = buildReadingsMap(readingList);
            }
            
            Map<Id,Id> mapOfSPId2DeviceId = new Map<Id,Id>();  
            Set<Id> supplyPointIds = new Set<Id>();
            Set<Id> availableServiceIds = new Set<Id>();
            Set<Id> serviceIds = new Set<Id>();
            Map<Id, SupplyPoint__c>  mapSupplyPointById = new Map<Id,SupplyPoint__c>(); //AT-5133, Ankit, 15/02/2019
            List<Service__c> oldServices = new List<Service__c>();
            List<Service__c> newServices = new List<Service__c>();
            List<ServiceItem__c> newServiceItemsList = new List<ServiceItem__c>();
            List<ServiceItem__c> oldServiceItemsList = new List<ServiceItem__c>();
            Map<Id,Id> mapOfOldServiceId2NewServiceId = new Map<Id,Id>();
            
            if(!wizObject.availableServiceTransfers.isEmpty()){
                for(AvailableService__c objAvailableService : wizObject.availableServiceTransfers){
                    availableServiceIds.add(objAvailableService.Id);
                }
                
                System.debug('availableServiceIds = '+availableServiceIds);
                System.debug('wizObject.effectiveDate = '+wizObject.effectiveDate);
                
                if(availableServiceIds != null){
                    List<Service__c> serviceLists = [SELECT Id, Name,
                                                     AvailableService__c,
                                                     BillingContract__c,
                                                     Device__c,
                                                    
                                                     Reading__c,
                                                     ServiceType__c,
                                                     SupplyPoint__c                                             
                                                     FROM Service__c WHERE AvailableService__c = :availableServiceIds AND 
                                                     (ServiceStartDate__c <= :wizObject.effectiveDate) AND (ServiceEndDate__c = null OR ServiceEndDate__c > :wizObject.effectiveDate)];
                                                         
                                                         
                    // Get all the service records based on avaialable service ids and effective date by user
                    /*List<Service__c> serviceLists = (List<Service__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsService.SERVICEAPINAME,
                                                                                                           serviceFields,
                                                                                                           ' WHERE ' + GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME + ' IN ' +
                                                                                                           GlUt_FieldSecurity.IdsToString(availableServiceIds) +
                                                                                                           ' AND ' + GlUt_APIConstantsService.SERVICESTARTDATEAPINAME + ' <= :' + wizObject.effectiveDate +
                                                                                                           ' AND (' + GlUt_APIConstantsService.SERVICEENDDATEAPINAME + ' = null OR ' + 
                                                                                                           GlUt_APIConstantsService.SERVICEENDDATEAPINAME + ' > :' + wizObject.effectiveDate + ')');*/
                    System.debug('Dynamic serviceLists = '+serviceLists);
                    
                    if(!serviceLists.isEmpty()){
                        for(Service__c objService : serviceLists){
                            serviceIds.add(objService.Id);
                            supplyPointIds.add(objService.SupplyPoint__c);
                        }
                        
                        /*List<SupplyPointDevice__c> spdLists = [SELECT Id, SupplyPoint__c, Device__c FROM SupplyPointDevice__c WHERE SupplyPoint__c = :supplyPointIds];*/
                        
                        // get all the Supply Point Device records based on Supply Point Ids set
                        List<SupplyPointDevice__c> spdLists = (List<SupplyPointDevice__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME,
                                                                                                                               new List<String>{LoAp_Constants.Id,
                                                                                                                                   GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,
                                                                                                                                   GlUt_APIConstantsDevice.DEVICEAPINAME},
                                                                                                                               'WHERE ' + GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME + 
                                                                                                                               ' IN ' + GlUt_FieldSecurity.IdsToString(supplyPointIds)); 
                        
                        
                        
                        
                        
                        
                        System.debug('Dynamic spdLists = '+spdLists);
                        if(!spdLists.isEmpty()){
                            for(SupplyPointDevice__c spd : spdLists){
                                mapOfSPId2DeviceId.put(spd.SupplyPoint__c , spd.Device__c);
                            }
                        }
                        
                    }
                    if(serviceIds != null){
                        /*List<ServiceItem__c> serviceItemList = [SELECT Id, Name, ServiceType__c, StartDate__c, EndDate__c, 
                                                                ServiceItemType__c, AvailableServiceItem__c, 
                                                                DischargeAgreement__c, Service__c FROM ServiceItem__c WHERE Service__c = :serviceIds];*/
                        
                        
                        // get all the services records based on serviceIds set
                        List<ServiceItem__c> serviceItemList = (List<ServiceItem__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME,
                                                                                                                          serviceItemFields,
                                                                                                                          'WHERE ' + GlUt_APIConstantsService.SERVICEAPINAME + 
                                                                                                                          ' IN ' + GlUt_FieldSecurity.IdsToString(serviceIds));   
                        

                        
                        
                        System.debug('Dynamic serviceItemList = '+serviceItemList);
                        for(Service__c objService : serviceLists){
                            
                            Id serviceTransferStart = null;
                            Id serviceTransferEnd = null;
                            
                            if(mapOfSPId2DeviceId.containsKey(objService.SupplyPoint__c)){
                                if(mapOfDeviceId2Readings.containsKey(mapOfSPId2DeviceId.get(objService.SupplyPoint__c))){
                                    List<Reading__c> readingLists = mapOfDeviceId2Readings.get(mapOfSPId2DeviceId.get(objService.SupplyPoint__c));
                                    for(Reading__c objReading : readingLists){
                                        if(objReading.ReadingType__c == System.Label.CuAp_ServiceTransferStart)
                                            serviceTransferStart = objReading.Id;
                                        if(objReading.ReadingType__c == System.Label.CuAp_ServiceTransferEnd)
                                            serviceTransferEnd = objReading.Id;
                                    }
                                }
                            }
                            
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
                        newServices = (List<Service__c>) GlUt_FieldSecurity.cleanseFields(newServices, false);
                        insert newServices;
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
				oldServiceItem.Ended__c = true; // AT-3892, AT-3895   
                                oldServiceItemsList.add(oldServiceItem);
                            } 
                            newServiceItemsList = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(newServiceItemsList, false);
                            insert newServiceItemsList;
                            GlUt_ContractUtilities.CreateGroupWithGroupItem(newServiceItemsList,null,null); //UL-169 Changes Starts/Ends Here.
                            oldServiceItemsList = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(oldServiceItemsList, false);
                            update oldServiceItemsList;
                            return wizObject.contractId;
                        }
                    }
                }
            }
            return null;
        }
        catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            System.debug('exception = '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           02 August 2018
    @param          String - json string of object wizardprop
    @return         Id - contractId
    @description    Method called by wizard to create new readings
    *******************************************************************************/
    @AuraEnabled
    public static Id removedServices(String wizardprop, String readings) { 
        Savepoint sp = Database.setSavepoint();
        try {            
            UpdateWizardProperties(wizardprop);
            Set<Id> serviceIds = new Set<Id>();
            Map<Id,List<Reading__c>> mapOfDeviceId2Readings = new Map<Id,List<Reading__c>>();
            Map<Id,Id> mapOfSPId2DeviceId = new Map<Id,Id>();  
            Set<Id> supplyPointIds = new Set<Id>();
            List<ServiceItem__c> oldServiceItemsList = new List<ServiceItem__c>();
            List<Service__c> oldServices = new List<Service__c>();
            
            if(readings != 'null'){
                List<Reading__c> readingList = (List<Reading__c>)JSON.deserialize(readings, List<Reading__c>.class);
                mapOfDeviceId2Readings = buildReadingsMap(readingList);
                
            }
            
            if(!wizObject.removedServices.isEmpty()){
                for(Service__c objService : wizObject.removedServices){
                    serviceIds.add(objService.Id);
                }
                
                if(serviceIds != null){                    
                    /*List<Service__c> serviceLists = [SELECT Id, Name,
                                                     AvailableService__c,
                                                     BillingContract__c,
                                                     Device__c,
                                                     DischargeAgreement__c,
                                                     Reading__c,
                                                     ServiceType__c,
                                                     SupplyPoint__c                                             
                                                     FROM Service__c WHERE Id = :serviceIds];*/
                    
                    // get all the services records based on serviceIds set
                    List<Service__c> serviceLists = (List<Service__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsService.SERVICEAPINAME,
                                                                                                           serviceFields,
                                                                                                           'WHERE ' + LoAp_Constants.Id + 
                                                                                                           ' IN ' + GlUt_FieldSecurity.IdsToString(serviceIds));   
                    
                    if(!serviceLists.isEmpty()){                        
                        for(Service__c service : serviceLists){
                            supplyPointIds.add(service.SupplyPoint__c);
                        }
                        /*List<SupplyPointDevice__c> spdLists = [SELECT Id, SupplyPoint__c, Device__c FROM SupplyPointDevice__c WHERE SupplyPoint__c = :supplyPointIds];*/
                        
                        // get all the Supply Point Device records based on Supply Point Ids set
                        List<SupplyPointDevice__c> spdLists = (List<SupplyPointDevice__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME,
                                                                                                                               new List<String>{LoAp_Constants.Id,
                                                                                                                                   GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,
                                                                                                                                   GlUt_APIConstantsDevice.DEVICEAPINAME},
                                                                                                                               'WHERE ' + GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME + 
                                                                                                                               ' IN ' + GlUt_FieldSecurity.IdsToString(supplyPointIds)); 
                        
                        
                        if(!spdLists.isEmpty()){
                            for(SupplyPointDevice__c spd : spdLists){
                                mapOfSPId2DeviceId.put(spd.SupplyPoint__c , spd.Device__c);
                            }
                        }
                        
                        for(Service__c objService : serviceLists){
                            Id serviceTransferEnd = null;
                            
                            if(mapOfSPId2DeviceId.containsKey(objService.SupplyPoint__c)){
                                if(mapOfDeviceId2Readings.containsKey(mapOfSPId2DeviceId.get(objService.SupplyPoint__c))){
                                    List<Reading__c> readingLists = mapOfDeviceId2Readings.get(mapOfSPId2DeviceId.get(objService.SupplyPoint__c));
                                    for(Reading__c objReading : readingLists){                                        
                                        if(objReading.ReadingType__c == System.Label.CuAp_ServiceTransferEnd)
                                            serviceTransferEnd = objReading.Id;
                                    }
                                }
                            }
                            objService.Reading__c = serviceTransferEnd;
                            oldServices.add(objService);                            
                        }
                        oldServices = (List<Service__c>) GlUt_FieldSecurity.cleanseFields(oldServices, false); //AT-4892 Code Check Marx Changes Starts/Ends Here.
                        update oldServices;
                    }
                    /*List<ServiceItem__c> serviceItemLists = [SELECT Id, EndDate__c FROM ServiceItem__c WHERE Service__c = :serviceIds];*/
                    List<ServiceItem__c> serviceItemLists = (List<ServiceItem__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME,
                                                                                                                       new List<String>{LoAp_Constants.Id,
                                                                                                                           GlUt_APIConstantsServiceItem.ENDDATE},
                                                                                                                       'WHERE ' + GlUt_APIConstantsService.SERVICEAPINAME + 
                                                                                                                       ' IN ' + GlUt_FieldSecurity.IdsToString(serviceIds)); 
                    
                    
                    for(ServiceItem__c objServiceItem : serviceItemLists){
                        objServiceItem.EndDate__c = wizObject.effectiveDate;
			objServiceItem.Ended__c = true; // AT-3892, AT-3895
                        oldServiceItemsList.add(objServiceItem);
                    }
                    oldServiceItemsList = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(oldServiceItemsList, false);
                    update oldServiceItemsList;
                    return wizObject.contractId;
                }
            }
            return null;
        }
        catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            System.debug('exception = '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
}