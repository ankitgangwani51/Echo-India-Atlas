/******************************************************************************
@author         Accenture: Patrick Dixon
@date           29 Nov 2017
@description    Class for Contract utilities
*******************************************************************************/
public with sharing class GlUt_ContractUtilities {
    
    private static final String CLASS_NAME = 'GlUt_ContractUtilities';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           22 Feb 2018
    @param          String - the record api name
    @param          Id - record Id
    @return         Set<Id> - set of contract Ids
    @description    Finds the contracts affected by a record amendment using the 
                    GlUt_ContractFinder service.
    *******************************************************************************/
    public static Set<Id> retrieveContractIds(String recordName, Id recordId) {
    
        if (recordName == null) {
            recordName = recordId.getSObjectType().getDescribe().getName().removeEnd('__c');
        }

        // build the contract finder class name for the record type
        Type classType = Type.forName(GlUt_NamespacePrefix.getNamespacePrefix().replace('__',''),GlUt_Constants.PREFIX + recordName + GlUt_Constants.CONTRACT_FINDER);
        
        // get the contract Ids
        GlUt_ContractFinder contractFinder = (GlUt_ContractFinder)classType.newInstance();
        return contractFinder.retrieveContractIds(recordId);
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           04 Sep 2017
    @param          Id - contract group Id
    @return         List<BillingContract__c> - contracts
    @description    gets the contract records for a grouped contract
    @revision       MT 07-Mar-2018 Use the field from constant class
    *******************************************************************************/
    public static List<BillingContract__c> getContracts(Id contractGroupId) {
        return Database.query(getContractQuery() + ' where ' +  GlUt_APIConstantsContracts.CONTRACTGROUPAPINAME + ' = :contractGroupId');
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           30 Oct 2017
    @param          Id - contract Id
    @return         List<BillingContract__c> - contracts
    @description    gets the contract record for a non-grouped contract
    *******************************************************************************/
    public static List<BillingContract__c> getContract(Id contractId) {
        return Database.query(getContractQuery() + ' where Id = :contractId');
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           23 Nov 2017
    @return         String - the base contract query fields
    @description    gets the query fields for a contract or contract group Id query
    *******************************************************************************/
    private static String getContractQuery() {
        return Database.getQueryLocator(
                'select Id, '
                    + GlUt_APIConstantsContracts.BILLING_METHOD + ', '
                    + GlUt_APIConstantsContracts.BILLING_FREQUENCY + ', '
                    + GlUt_APIConstantsContracts.CUSTOMERAPINAME + ', '
                    + GlUt_APIConstantsContracts.RELATED_ACCOUNT + '.Name, '
            		+ GlUt_APIConstantsContracts.RELATED_ACCOUNT + '.' + GlUt_APIConstantsAccount.SUPPRESSEDAPINAME + ',' //AT-2102, Ankit, 15/04/2019
                    + GlUt_APIConstantsContracts.STARTDATE + ', '
                    + GlUt_APIConstantsContracts.ENDDATE + ', '
                    + GlUt_APIConstantsContracts.LAST_BILL_CALCULATION_DATE + ', '
                    + GlUt_APIConstantsContracts.SUPPRESSEDAPINAME + ', '    //AT-3297
                    + GlUt_APIConstantsContracts.BUDGETPLANONHOLDAPINAME + ', '  //AT-4574
            		+ GlUt_APIConstantsContracts.OWNEDBYAPINAME + ',' //AT-5084, Ankit, 23/01/2018
            		+ GlUt_APIConstantsContracts.HOLDENTIREBILLTOLERANCEAPINAME + ',' // UL-21, Ankit, 21/02/2019
                    + '(select Id from ' + GlUt_APIConstantsContracts.RELATED_SERVICES + '), '
                    
                    + '(select Id, '
                            + GlUt_APIConstantsBillEvent.EVENT_TYPE + ', '
                            + GlUt_APIConstantsBillEvent.STATUS + ' '
                    + 'from ' + GlUt_APIConstantsContracts.RELATED_BILL_EVENTS + ' '
                    + 'where ' + GlUt_APIConstantsBillEvent.STATUS + ' = \'' + GlUt_APIConstantsBillEvent.PENDINGBILLEVENTSTATUS + '\' '        // 'Pending' only
                    + 'order by CreatedDate desc) ' 
             
            + 'from ' + GlUt_APIConstantsContracts.CONTRACTAPINAME
       ).getQuery();

/*
        return Database.getQueryLocator(
            [select Id, 
                     BillingMethod__c, 
                     BillingFrequency__c, 
                     AccountName__c,
                     AccountName__r.Name,
                     ContractStartDate__c,
                     ContractEndDate__c,
                     LastBillCalculationDate__c, 
                     
                     (select Id from Services__r),
                     (select Id, 
                            EventType__c 
                     from BillEvents__r
                     where Status__c = 'Pending')       // salesforce won't accept bind variable here
             
             from BillingContract__c]
        ).getQuery();
*/
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           19 Dec 2017
    @return         Id - the Id of the default bill template
    @description    Get the default bill template Id to populate a new contract
    *******************************************************************************/
    private static Id DefaultBillTemplateId;
    public static Id getDefaultBillTemplateId() {
        
        if (DefaultBillTemplateId == null) {
            for (BillTemplate__c billTemplate : [select Id 
                                                 from BillTemplate__c 
                                                 where Name = :GlUt_Constants.DEFAULT_PDF_TEMPLATE]) {
                                                     
                                                     DefaultBillTemplateId = billTemplate.Id;
                                                 }
        }
        return DefaultBillTemplateId;   
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           22 Nov 2017
    @param          Set<Id> - device Ids
    @return         Map<Id, Id> - map of supply point device Ids keyed on service type Id
    @description    Builds a map of the supply point device Ids keyed on service type Id 
    for the devices, so that we can match a device/reading to the correct service
    *******************************************************************************/
    private static Map<Id, Id> BuildSupplyPointDeviceMap(Set<Id> deviceIds) {
        
        Map<Id, Id> supplyPointDeviceMap = new Map<Id, Id>();
        for (SupplyPointDeviceService__c supplyPointDeviceService : [select Id, 
                                                                     ServiceType__c, 
                                                                     SupplyPointDevice__c 
                                                                     from SupplyPointDeviceService__c
                                                                     where SupplyPointDevice__r.Device__c in :deviceIds]) {
                                                                         
                                                                         supplyPointDeviceMap.put(supplyPointDeviceService.ServiceType__c, supplyPointDeviceService.SupplyPointDevice__c);
                                                                     }
        return supplyPointDeviceMap;
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           22 Nov 2017
    @param          List<Reading__c> - readings
    @return         Map<Id, Id> - map of reading Ids keyed on service type Id
    @description    Builds a map of the move in reading Ids keyed on service type Id, 
    so that we can match a device/reading to the correct service
    *******************************************************************************/
    private static Map<Id, Id> BuildReadingsMap(List<Reading__c> readings) {
        
        Map<Id, Id> readingsMap = new Map<Id, Id>();
        if (readings != null) {
            for (Reading__c reading : readings) {
                if (reading.ReadingType__c == System.Label.GlAp_ReadingReadingTypeMoveInActive) {
                    readingsMap.put(reading.Device__c, reading.Id);
                }
            }
        }
        return readingsMap;
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           22 Nov 2017
    @param          List<Id> - supply point device Ids
    @return         Map<Id, Id> - map of device Ids keyed on supply point device Id
    @description    Builds a map of the device Ids keyed on supply point device Id, 
    so that we can match a device/reading to the correct service
    *******************************************************************************/
    private static Map<Id, Id> BuildDeviceMap(List<Id> supplyPointDeviceIds) {
        
        Map<Id, Id> deviceMap = new Map<Id, Id>();      // map of device Ids keyed on supply point device Id
        for (SupplyPointDevice__c supplyPointDevice : [select Id, 
                                                       Device__c
                                                       from SupplyPointDevice__c
                                                       where Id in :supplyPointDeviceIds]) {
                                                           
                                                           deviceMap.put(supplyPointDevice.Id, supplyPointDevice.Device__c);
                                                       }
        return deviceMap;
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           22 Nov 2017
    @param          Id - contract Id
    @param          Date - start date of the contract
    @param          List<AvailableService__c> - list of the services to supply
    @param          List<AvailableBundle__c> - list of the available bundles
    @param          List<AvailableServiceItem__c> - list of the service items to supply
    @param          List<ServiceItemType__c> - list of sundry items to supply
    @param          List<Reading__c> - list of the move in readings
    @return         Boolean - success
    @description    Adds services and service items to a contract
    *******************************************************************************/
    public static Boolean AddServiceItemsToContract(Id accountId,
                                                    Id contractId, 
                                                    Date startDate, 
                                                    List<AvailableService__c> suppliedServices, 
                                                    List<AvailableBundle__c> availableBundles, 
                                                    List<AvailableServiceItem__c> suppliedServiceItems, 
                                                    List<ServiceItemType__c> selectedSundryItems, 
                                                    List<Reading__c> moveInReadings,
                                                    String occType) { //AT-4038
                                                        
        // build some maps to relate the move in reading on a device to a service type for a supply point
        Map<Id, Id> moveInReadingsMap = BuildReadingsMap(moveInReadings);       // map of move in reading Ids keyed on device Id        
        Map<Id, Id> supplyPointDeviceMap = BuildSupplyPointDeviceMap(moveInReadingsMap.keySet());       // map of supply point device Ids keyed on service type Id
        Map<Id, Id> deviceMap = BuildDeviceMap(supplyPointDeviceMap.values());      // map of device Ids keyed on supply point device Id
        List<TariffLimit__c> tariffLimitList = CheckActiveTariffLimit(accountId, startDate);
        List<GroupType__c> tariffLimitGroupTypeList = [Select Id from GroupType__c Where Name =:GlUt_Constants.GROUPTYPE_NAME_TARIFFLIMIT Limit 1];
        // add the services
        List<Service__c> servicesToInsert = new List<Service__c>();
        for (AvailableService__c availableService : suppliedServices) {
            // get the move in reading Id for the service using the service type
            Id supplyPointDeviceId = supplyPointDeviceMap.get(availableService.ServiceType__c);
            Id deviceId = deviceMap.get(supplyPointDeviceId);
            Id moveInReadingId = moveInReadingsMap.get(deviceId);
            
            // create a new service
            servicesToInsert.add(new Service__c(
                BillingContract__c = contractId, 
                AvailableService__c = availableService.Id, 
                ServiceType__c = availableService.ServiceType__c, 
                SupplyPoint__c = availableService.SupplyPoint__c, 
                Reading__c = moveInReadingId,
                OccupancyType__c = occType //AT-4038
            ));
        }
        // add a sundry service if there are sundry service items to add
        Id sundryServiceTypeId;
        if (!selectedSundryItems.isEmpty()) {
            
            // get the sundry service type Id
            for (ServiceType__c serviceType : [select Id 
                                               from ServiceType__c 
                                               where Name = :CuAp_Constants.SERVICE_TYPE_SUNDRY]) {
                                                   sundryServiceTypeId = serviceType.Id;
                                               }
            
            // create a new sundry service
            servicesToInsert.add(new Service__c(
                BillingContract__c = contractId, 
                ServiceType__c = sundryServiceTypeId,
                OccupancyType__c = occType //AT-4038 
           
            ));         
        }
        
        servicesToInsert = (List<Service__c>) GlUt_FieldSecurity.cleanseFields(servicesToInsert, false);
        insert servicesToInsert;
        
        // build maps to link service items to services
        Map<Id, Service__c> servicesToInsertMap = new Map<Id, Service__c>();     // map of services keyed on available service Id
        Id sundryServiceId;     // sundry service Id
        for (Service__c service : servicesToInsert) {
            servicesToInsertMap.put(service.AvailableService__c, service);
            // get the sundry service Id (if one was added)
            if (service.ServiceType__c == sundryServiceTypeId) {
                sundryServiceId = service.Id;
            }
        }
        Map<Id, AvailableBundle__c> availableBundleByIdMap = new Map<Id, AvailableBundle__c>();
        Map<Id, Id> availableBundleMap = new Map<Id, Id>();     // map of available service Ids keyed on available bundle Id
        for(AvailableBundle__c availableBundle : availableBundles) {
            availableBundleMap.put(availableBundle.Id, availableBundle.AvailableService__c);
            if(!availableBundleByIdMap.containsKey(availableBundle.Id)){
                availableBundleByIdMap.put(availableBundle.Id, availableBundle);
            }
        }
        
        // add the service items
        List<ServiceItem__c> serviceItemsToInsert = new List<ServiceItem__c>();
        List<ServiceItem__c> serviceItemsToLinkGrpItemToInsert = new List<ServiceItem__c>();
         //For each of the Available Service Items retrieved 
        Group__c newTariffGroup;
        Boolean isNewTariffGroupExist = false;
        for (AvailableServiceItem__c availableServiceItem : suppliedServiceItems) {
            // get the service from the map using the available bundle's available service
            Service__c service = servicesToInsertMap.get(availableBundleMap.get(availableServiceItem.AvailableBundle__c));
            AvailableBundle__c objAvailableBundle = availableBundleByIdMap.get(availableServiceItem.AvailableBundle__c);
            //If Available Bundle is marked as a Tariff Limit Bundle
            if(tariffLimitList != null && tariffLimitList.size() > 0 && objAvailableBundle != null && objAvailableBundle.TariffLimit__c == true){
                // create a new service item
                    serviceItemsToLinkGrpItemToInsert.add(new ServiceItem__c(
                    Service__c = service.Id, 
                    AvailableServiceItem__c = availableServiceItem.Id, 
                    ServiceItemType__c = availableServiceItem.ServiceItemType__c, 
                    StartDate__c = startDate,
                    EndDate__c = tariffLimitList.size() > 0 ? tariffLimitList[0].EndDate__c:null      
                ));
                if(!isNewTariffGroupExist && tariffLimitGroupTypeList != null && tariffLimitGroupTypeList.size() > 0){
                    newTariffGroup = new Group__c();
                    newTariffGroup.Service__c = service.Id;
                    newTariffGroup.TariffLimit__c = tariffLimitList[0].Id;
                    newTariffGroup.GroupType__c = tariffLimitGroupTypeList[0].Id;
                    isNewTariffGroupExist = true;
                }
                 system.debug('serviceItemsToLinkGrpItemToInsert 2  '  + serviceItemsToLinkGrpItemToInsert);
            }else{
                 // create a new service item
                    serviceItemsToInsert.add(new ServiceItem__c(
                    Service__c = service.Id, 
                    AvailableServiceItem__c = availableServiceItem.Id, 
                    ServiceItemType__c = availableServiceItem.ServiceItemType__c, 
                    StartDate__c = startDate 
                ));
            }
        }      
        // add any sundry service items
        for (ServiceItemType__c serviceItemType : selectedSundryItems) {
            serviceItemsToInsert.add(new ServiceItem__c(
                Service__c = sundryServiceId, 
                ServiceItemType__c = serviceItemType.Id, 
                StartDate__c = startDate 
            ));
        }
        List<ServiceItem__c> allServiceItemsToInsert = new List<ServiceItem__c>();
        if(serviceItemsToInsert.size() > 0){
           serviceItemsToInsert = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(serviceItemsToInsert, false);
           allServiceItemsToInsert.addAll(serviceItemsToInsert);
        }
        if(serviceItemsToLinkGrpItemToInsert.size() > 0){
           serviceItemsToLinkGrpItemToInsert = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(serviceItemsToLinkGrpItemToInsert, false);
           allServiceItemsToInsert.addAll(serviceItemsToLinkGrpItemToInsert);
        }
        if(!allServiceItemsToInsert.isEmpty()){
            insert allServiceItemsToInsert;
        }
        //UL-155 Changes Starts Here. 
        CreateGroupWithGroupItem(serviceItemsToInsert,newTariffGroup,serviceItemsToLinkGrpItemToInsert);
        //UL-155 Changes Ends Here. 
        return true;
    }
     /******************************************************************************
    @author         Echo: Amit K.
    @date           01 March 2019
    @param          List<ServiceItem__c> newServiceItemList
    @param          Group__c existingLinkedGroup,List<ServiceItem__c> serviceItemsToLinkGrpItemToInsert
    @return         Void
    @description    Create Group and Group Items
    *******************************************************************************/
    public static void CreateGroupWithGroupItem(List<ServiceItem__c> newServiceItemList, Group__c existingLinkedGroup, List<ServiceItem__c> serviceItemsToLinkGrpItemToInsert){
        //List of newely created Groups Items
        List<GroupItem__c> newGroupItemList = new List<GroupItem__c>(); 
        //List of newely created Groups
        List<Group__c> newGroupList = new List<Group__c>();
        if(existingLinkedGroup != null){
            newGroupList.add(existingLinkedGroup);
        }
        List<ServiceItem__c> serviceItemList = new List<ServiceItem__c>();
        List<Group__c> existingGroupList;
        if(!newServiceItemList.isEmpty()){
            //Fetch All Service Item having Group Type by ServiceItemType --> Group Type
            serviceItemList  = [Select Id,Service__c,ServiceItemType__r.GroupType__c from ServiceItem__c Where Id In:newServiceItemList AND ServiceItemType__r.GroupType__c != NULL];
            if(serviceItemList != null && !serviceItemList.isEmpty()){
                Set<Id> groupTypeIdSet = new  Set<Id>();
                Set<Id> serviceIdSet = new Set<Id>();
                for(ServiceItem__c serviceItem: serviceItemList){
                    if(serviceItem.ServiceItemType__r.GroupType__c != null)
                        groupTypeIdSet.add(serviceItem.ServiceItemType__r.GroupType__c);
                    serviceIdSet.add(serviceItem.Service__c);
                }
                
                if(!groupTypeIdSet.isEmpty())
                    existingGroupList = [Select Id,Service__c,GroupType__c from Group__c Where GroupType__c In:groupTypeIdSet AND Service__c In:serviceIdSet];
                //Fetch Service Group type combination from existing group used in Available bundle change case.
                Map<String,Group__c> mapOfExistingServiceGroupType2Group = new Map<String,Group__c>();
                if(existingGroupList != null){
                    for(Group__c existingGroup: existingGroupList){
                        mapOfExistingServiceGroupType2Group.put(existingGroup.Service__c+'-'+existingGroup.GroupType__c,existingGroup);
                    }
                }
                
                Map<String,ServiceItem__c> mapOfServiceGroupCombination2ServiceItem = new  Map<String,ServiceItem__c>();
                //Create new Group if there is no service linked to groups that are associated with group type of service items . 
                for(ServiceItem__c serviceItem : serviceItemList){
                    if(!mapOfExistingServiceGroupType2Group.containsKey(serviceItem.Service__c+'-'+serviceItem.ServiceItemType__r.GroupType__c) && !mapOfServiceGroupCombination2ServiceItem.containsKey(serviceItem.Service__c+'-'+serviceItem.ServiceItemType__r.GroupType__c)){
                        Group__c newGroup = new Group__c();
                        newGroup.GroupType__c = serviceItem.ServiceItemType__r.GroupType__c;
                        newGroup.Service__c = serviceItem.Service__c;
                        newGroupList.add(newGroup);
                        mapOfServiceGroupCombination2ServiceItem.put(serviceItem.Service__c+'-'+serviceItem.ServiceItemType__r.GroupType__c,serviceItem);
                    }
                }
            }
        }
        if(!newGroupList.isEmpty()){
            newGroupList = (List<Group__c>) GlUt_FieldSecurity.cleanseFields(newGroupList, false);
            //Create New Groups
            insert newGroupList;
        }
        //If there are existing groups in Available Bundle scenario
        if(existingGroupList != null && !existingGroupList.isEmpty()){
            newGroupList.addAll(existingGroupList);
        }
        //Create new group Items for those service items that are not already linked to groups.
        for(ServiceItem__c serviceItem : serviceItemList){
            for(Group__c groups: newGroupList){
                //Create new group Item for those service items that belongs to same group types and services for groups created/Retreived above. 
                if(groups.Service__c == serviceItem.Service__c && groups.GroupType__c == serviceItem.ServiceItemType__r.GroupType__c){
                    GroupItem__c newGroupItem = new GroupItem__c();
                    newGroupItem.ServiceItem__c = serviceItem.Id;
                    newGroupItem.Group__c = groups.Id;
                    newGroupItemList.add(newGroupItem);
                    break;
                }
            }
        }
        if(existingLinkedGroup != null && serviceItemsToLinkGrpItemToInsert != null && !serviceItemsToLinkGrpItemToInsert.isEmpty()){
            //Create a Group Item to link the Service item to the existing Group
            for(ServiceItem__c objServiceItem : serviceItemsToLinkGrpItemToInsert){
                GroupItem__c objGroupItm = new GroupItem__c();
                objGroupItm.ServiceItem__c = objServiceItem.Id;
                if(!newGroupList.isEmpty() && newGroupList.size() > 0){
                    objGroupItm.Group__c = newGroupList[0].Id;
                    newGroupItemList.add(objGroupItm);
                }
            }
        }
        //Create new Group Items
        if(newGroupItemList.size() > 0){
            newGroupItemList = (List<GroupItem__c>) GlUt_FieldSecurity.cleanseFields(newGroupItemList, false);
            insert newGroupItemList;
        }
    }
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           14 Aug 2018
    @param          Id - accountId
    @param          Date - strMoveInDate
    @return         boolean
    @description    If the Account being moved into a Location has an active Tariff Limit associated, 
                    where the Limit Start Date is <= Move in Date and the Limit End Date is > Move In Date or Null
    *******************************************************************************/ 
    public static List<TariffLimit__c> CheckActiveTariffLimit(Id accountId, Date moveInDate){
        List<TariffLimit__c> tariffLimitList  = new List<TariffLimit__c>();
        if(accountId != null  && moveInDate != null){
            tariffLimitList = [SELECT Id,Name,Account__c,EndDate__c,StartDate__c,Status__c 
                                                    FROM TariffLimit__c WHERE Account__c =: accountId 
                                                    AND StartDate__c <=: moveInDate AND (EndDate__c >: moveInDate OR EndDate__c = null)];
        }
        System.debug('tariffLimitList======'+tariffLimitList);
        return tariffLimitList;
    }
    
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           29 Nov 2017
    @param          Id - location Id
    @param          Date - the start date for the contract
    @param          List<Reading__c> - list of the move out readings
    @return         Id - the void contract Id
    @description    Creates a void contract for the location using the default services
    *******************************************************************************/
    public static Id createVoidContract(Id locationId, Date startDate, List<Reading__c> moveOutReadings, Date moveInDate) {
        
        Date serviceItemEndDate;
        
        if(moveInDate > startDate){
            serviceItemEndDate = moveInDate.addDays(-1);
        }else{
            serviceItemEndDate = null;
        }
        
        // get the location fields
        Location__c location;
        for (Location__c theLocation : [select Id, 
                                        VoidStartDate__c, 
                                        VoidEndDate__c, 
                                        Street__c, 
                                        City__c, 
                                        State__c, 
                                        PostalCode__c, 
                                        Country__c 
                                        from Location__c
                                        where Id = :locationId]) {
                                            location = theLocation;     
                                        }
        
        // error exit
        if (location == null) return null;      
        
        // get all the supply points at the location
        List<SupplyPoint__c> supplyPoints = [select Id,
                                             Read_Frequency__c
                                             from SupplyPoint__c 
                                             where Location__c = :locationId];
        
        System.debug(DEBUG + 'supplyPoints: ' + supplyPoints);
        
        // create a new contract for the location with the void flag set
        BillingContract__c voidContract = new BillingContract__c(
            Suppressed__c = true, 
            BillingStreet__c = location.Street__c, 
            BillingCity__c = location.City__c,
            BillingState__c = location.State__c,
            BillingPostalCode__c = location.PostalCode__c,
            BillingCountry__c = location.Country__c,
            Void__c = true, 
            
            // other contract defaults
            BillingMethod__c = GlUt_Constants.DEFAULT_BILLING_METHOD, 
            BillingFrequency__c =  moveInDate == null ? supplyPoints[0].Read_Frequency__c : GlUt_Constants.DEFAULT_BILLING_FREQUENCY, //AT-2298
            BillTemplate__c = getDefaultBillTemplateId()
        );        
        
        // insert the contract
        voidContract = (BillingContract__c) GlUt_FieldSecurity.cleanseFields(voidContract, false);
        insert voidContract;
        
        // build some maps to relate the move out reading on a device to a service type for a supply point
        Map<Id, Id> moveOutReadingsMap = BuildReadingsMap(moveOutReadings);     // map of move in reading Ids keyed on device Id        
        Map<Id, Id> supplyPointDeviceMap = BuildSupplyPointDeviceMap(moveOutReadingsMap.keySet());      // map of supply point device Ids keyed on service type Id
        Map<Id, Id> deviceMap = BuildDeviceMap(supplyPointDeviceMap.values());      // map of device Ids keyed on supply point device Id
        
        // for the supply points find the default available services
        List<AvailableService__c> defaultAvailableServices = [select Id, 
                                                              SupplyPoint__c, 
                                                              ServiceType__c 
                                                              from AvailableService__c 
                                                              where SupplyPoint__c in :supplyPoints 
                                                              and Active__c = true 
                                                              and Default__c = true];
        
        // for the default available services find the available service items
        List<AvailableServiceItem__c> availableServiceItems = [select Id, 
                                                               AvailableBundle__r.AvailableService__c, 
                                                               ServiceItemType__c 
                                                               from AvailableServiceItem__c 
                                                               where AvailableBundle__r.AvailableService__c in :defaultAvailableServices
                                                               and AvailableBundle__r.Default__c = true];
        
        // for each default available service create a new service on the contract
        List<Service__c> services = new List<Service__c>();
        for (AvailableService__c availableService : defaultAvailableServices) {
            
            // get the move in reading Id for the service using the service type
            Id supplyPointDeviceId = supplyPointDeviceMap.get(availableService.ServiceType__c);
            Id deviceId = deviceMap.get(supplyPointDeviceId);
            Id moveOutReadingId = moveOutReadingsMap.get(deviceId);
            
            services.add(new Service__c(BillingContract__c = voidContract.Id, 
                                        AvailableService__c = availableService.Id, 
                                        ServiceType__c = availableService.ServiceType__c, 
                                        SupplyPoint__c = availableService.SupplyPoint__c, 
                                        Reading__c = moveOutReadingId 
                                       ));
        }
        
        // insert the services
        services = (List<Service__c>) GlUt_FieldSecurity.cleanseFields(services, false);
        insert services;
        
        // build a map of available service Ids to service Ids to link the service items to the services
        Map<Id, Id> serviceIdMap = new Map<Id, Id>();       // map of service Ids keyed on available service Id
        for (Service__c service : services) {
            serviceIdMap.put(service.AvailableService__c, service.Id);
        }
        
        // for each available service item create a service item
        List<ServiceItem__c> serviceItems = new List<ServiceItem__c>();
        for (AvailableServiceItem__c availableServiceItem : availableServiceItems) {
            serviceItems.add(new ServiceItem__c(Service__c = serviceIdMap.get(availableServiceItem.AvailableBundle__r.AvailableService__c), 
                                                ServiceItemType__c = availableServiceItem.ServiceItemType__c, 
                                                AvailableServiceItem__c = availableServiceItem.Id, 
                                                StartDate__c = startDate,
                                                EndDate__c = serviceItemEndDate // AT-2271, Void Contract will be ended, when move-in date is greater than Void Contract Start Date (which is move-out date + 1)
                                            
                                            
                                               ));
            
               system.debug('serviceItems 1 '  + serviceItems);
        }
        
        // insert the service items
        serviceItems = (List<ServiceItem__c>)GlUt_FieldSecurity.cleanseFields(serviceItems, false);
        insert serviceItems;
        
        // flag the location as void
        location.VoidEndDate__c = null;
        location.VoidStartDate__c = startDate;
        
        // and update location
        location = (Location__c) GlUt_FieldSecurity.cleanseFields(location, false);
        update location;
        
        return voidContract.Id;
    }
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           29 Nov 2018
    @param          Set<Id> - contractId Id
    @return         Map<Id,BankAccountDetails__c> - contract Id to bank details
	@description    AT-4254,Creates a map of contract Id to bank details
	*******************************************************************************/
    public static Map<Id,BankAccountDetails__c> getBankLinkedToContract(Set<Id> contractIds) {
        Map<Id,Id> mapBankId2ContractId = new Map<Id,Id>();
        Map<Id,BankAccountDetails__c> mapBankId2BankDetails = new Map<Id,BankAccountDetails__c>();
        Map<Id,BankAccountDetails__c> mapContractId2BankDetails = new Map<Id,BankAccountDetails__c>();
        for (BillingContract__c contract : [SELECT Id,BankAccountDetails__c FROM BillingContract__c WHERE Id in :contractIds]) {
            if(contract.BankAccountDetails__c != null){
                if(!mapBankId2ContractId.containsKey(contract.BankAccountDetails__c)){
                    mapBankId2ContractId.put(contract.BankAccountDetails__c, contract.Id);
                }
            }
        }
        
        if(mapBankId2ContractId.Keyset().size() > 0){
            for(BankAccountDetails__c objBankDetails : [SELECT Id,Name,Account__c,BankAccountNumber__c,NameOnAccount__c,BankAccountSortCode__c FROM BankAccountDetails__c WHERE Id IN: mapBankId2ContractId.Keyset()]){
                if(!mapBankId2BankDetails.containsKey(objBankDetails.Id)){
                    mapBankId2BankDetails.put(objBankDetails.Id, objBankDetails);
                }
            }            
            
            for(Id objBankId : mapBankId2ContractId.Keyset()){
                Id contractId = mapBankId2ContractId.get(objBankId);
                if(!mapContractId2BankDetails.containsKey(contractId) && mapBankId2BankDetails.containsKey(objBankId)){
                    mapContractId2BankDetails.put(contractId, mapBankId2BankDetails.get(objBankId));
                }
            }
        }
        
        return mapContractId2BankDetails;
    }
}