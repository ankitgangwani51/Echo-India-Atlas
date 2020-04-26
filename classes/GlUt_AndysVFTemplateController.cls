public class GlUt_AndysVFTemplateController {
    
    private List<Account> accounts;
    private List<Service__c> services;
    private List<Contact> contacts;
    private List<SupplyPoint__c> supplyPoints;
    private List<Device__c> devices;
    private List<Reading__c> readings;
    private List<AverageDailyUsage__c> averageDailyuses;
    private List<Location__c> locations;
    private List<Bill__c> bills;
    private List<DebtRecoveryProcess__c> debtRecoveryProcesses;
    private List<Payment__c> payments;
    private List<PaymentPlan__c> paymentPlans;
    private Map<Id, Set<Id>> serviceTypeMap; 
    
    public void getData(BillingContract__c contract){
        // build lists of the account and contact Ids
        List<Id> accountIds = new List<Id>();
        List<Id> contactIds = new List<Id>();
        List<Id> contractIds = new List<Id>();
        //accountIds.add(contract.Account__c);
        //contactIds.add(pdfRequest.Contact__c);
        contractIds.add(contract.id);


        /* STEP 1: get all the data records required */

        // get all the account records
        accounts = getAccounts(accountIds);

        // get all the contact records
        //contacts = getContacts(contactIds);

        // get all the related service records
        services = getServices(contractIds);
                       
        // get all the supply point related records
        supplyPoints = getSupplyPoints(contractIds);

        // build a list of the supply point devices to get the associated records
        List<Id> supplyPointIds = new List<Id>();
        for (SupplyPoint__c supplyPoint : supplyPoints) {
            supplyPointIds.add(supplyPoint.Id);
        }
        
        // get all the related devices and their device relationships and readings records
        devices = getDevices(supplyPointIds);

        // build a set of all the main device Ids
        // and a set of all the devices' sub device Ids
        Set<Id> deviceIds = new Set<Id>();
        Set<Id> subDeviceIds = new Set<Id>();
        for (Device__c device : devices) {
            deviceIds.add(device.Id);
            /*for (DeviceRelationship__c subDevice : device.DeviceRelationships__r) {
                subDeviceIds.add(subDevice.SubDevice__c);
            }*/
        }
        
        // build the service type map for the main devices
         serviceTypeMap = buildServiceTypeMap(deviceIds);
        
        // AT-2926, Sub device is not required anymore
        // then get all the sub devices and their related readings records
        /*subDevices = getDevices(true, subDeviceIds);
        
        // add the sub device Ids to the set of main device Ids
        for (Device__c device : subDevices) {
            deviceIds.add(device.Id);
        }*/
        
        // get all the devices' readings
        readings = getReadings(deviceIds);
        
        // and get all the related average daily use records
        averageDailyUses = getAverageDailyUses(supplyPointIds); 

        // get all the location related records
        locations = getLocations(supplyPointIds);

        // get all the related bill records
        bills = getBills(contractIds);
        
        // get all the related debt recovery process records
        debtRecoveryProcesses = getDebtRecoveryProcesses(contractIds);
        
        // get all the related payment records
        payments = getpayments(contractIds);
        
        // get all the related payment plan records
        paymentPlans = getpaymentPlans(contractIds);
        
}
    
       /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           25 May 2018
    @param          List<Id> - account Ids
    @return         List<Account> - accounts
    @description    gets the account records
    *******************************************************************************/
    private List<Account> getAccounts(List<Id> accountIds) {
        return  [select Id, 
                        Name,
                        AccountReference__c 
                from Account 
                where Id in :accountIds];
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           25 May 2018
    @param          List<Id> - contract Ids
    @return         List<Contact> - contacts
    @description    gets the contact records
    *******************************************************************************/
    private List<Contact> getContacts(List<Id> contactIds) {
        return  [select Id 
                from Contact 
                where Id in :contactIds];
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 May 2018
    @param          List<Id> - contract Ids
    @return         List<Service__c> - services
    @description    gets the related service records
    *******************************************************************************/
    private List<Service__c> getServices(List<Id> contractIds) {
        return  [select Id, 
                        BillingContract__c, 
                        ServiceType__c,
                        SupplyPoint__c 
                from Service__c 
                where BillingContract__c in :contractIds];
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 May 2018
    @param          List<Id> - contract Ids
    @return         List<SupplyPoint__c> - subDevices
    @description    gets all the supply point related records
    *******************************************************************************/
    private List<SupplyPoint__c> getSupplyPoints(List<Id> contractIds) {
        return [select Id, 
                        Location__c, 
                        Read_Frequency__c, 
                        Book__r.ReadTimetable__r.Name, 
                        
                        (select Id, 
                                InstallationDate__c, 
                                Device__c 
                        from SupplyPointDevices__r)

                from SupplyPoint__c 
                where Id in (select SupplyPoint__c from Service__c where BillingContract__c = :contractIds)];
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 May 2018
    @param          List<Id> - supplyPoint Ids
    @return         List<AverageDailyUsage__c> - AverageDailyUses
    @description    gets the average daily use records
    *******************************************************************************/
    private List<AverageDailyUsage__c> getAverageDailyUses(List<Id> supplyPointIds) {
        return [select Id, 
                        StartDate__c, 
                        EndDate__c,
                        Invalid__c,   //AT-3555
                        AverageDailyUsage__c, 
                        SupplyPointDevice__c 
                from AverageDailyUsage__c 
                where SupplyPointDevice__r.SupplyPoint__c in :supplyPointIds
                    and (EndDate__c = null
                        or EndDate__c >= :Date.today().addMonths(-18))        // last 18 months only
                ];
    } 
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 May 2018
    @param          List<Id> - supply point Ids
    @return         List<Device__c> - devices
    @description    gets the devices, their device relationships and readings records
    *******************************************************************************/
    private List<Device__c> getDevices(List<Id> supplyPointIds) {
        return getDevices(false, new Set<Id>(supplyPointIds));
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 May 2018
    @param          Set<Id> - device Ids
    @return         Map<Id, Id> - map of service type Ids keyed on supply point device Id 
    @description    builds a map of the service type Ids keyed on supply point device Id    
                    for the devices, so that only the correct devices will be matched 
                    to the service
    *******************************************************************************/
    private Map<Id, Set<Id>> buildServiceTypeMap(Set<Id> deviceIds) {
        
        Map<Id, Set<Id>> serviceTypeMap = new Map<Id, Set<Id>>();
        for (SupplyPointDeviceService__c supplyPointDeviceService : [select Id, 
                                                                            ServiceType__c, 
                                                                            SupplyPointDevice__c 
                                                                    from SupplyPointDeviceService__c
                                                                    where SupplyPointDevice__r.Device__c in :deviceIds]) {
            if (serviceTypeMap.keySet().contains(supplyPointDeviceService.SupplyPointDevice__c)) {
                serviceTypeMap.get(supplyPointDeviceService.SupplyPointDevice__c).add(supplyPointDeviceService.ServiceType__c);

            } else {
                serviceTypeMap.put(supplyPointDeviceService.SupplyPointDevice__c, 
                        new Set<Id>{supplyPointDeviceService.ServiceType__c});
            }
        }
        return serviceTypeMap;
    }
    
     /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 May 2018
    @param          Set<Id> - device Ids
    @return         List<Reading__c> - readings and amended readings
    @description    gets the billed readings and their amended readings records
    *******************************************************************************/
    private List<Reading__c> getreadings(Set<Id> deviceIds) {

        return [select Id, 
                       Device__c, 
                       Reading__c, 
                       ReadingDate__c, 
                       ReadingType__c, 
                       ReadingSource__c, 
                       ReadingMethod__c, 
                       BillableType__c 
                from Reading__c 
                where Device__c in :deviceIds
                    and BillableType__c = :Label.CuAp_ReadingBillableTypeBillable        // billable types only
                    and ReadingDate__c >= :Date.today().addMonths(-12)        // last 12 months only
                ];
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           25 May 2018
    @param          List<Id> - supplyPoint Ids
    @return         List<Location__c> - locations
    @description    gets the location and location occupant records
    *******************************************************************************/
    private List<Location__c> getLocations(List<Id> supplyPointIds) {
        return [select Id, 
                        Street__c, 
                        City__c, 
                        State__c, 
                        Country__c, 
                        PostalCode__c, 
                        VoidLocation__c, 
                        (select Id, 
                                Name, 
                                OccupancyType__c, 
                                ShowOnBill__c, 
                                StartDate__c, 
                                EndDate__c 
                        from LocationOccupants__r) 
                from Location__c 
                where Id in (select Location__c from SupplyPoint__c where Id in :supplyPointIds)
                ];
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 May 2018
    @param          List<Id> - contract Ids
    @return         List<Bill__c> - bills
    @description    gets the related bill records
    *******************************************************************************/
    private List<Bill__c> getBills(List<Id> contractIds) {
        return  [select Id, 
                        Name, 
                        BillingContract__c, 
                        StartDate__c, 
                        EndDate__c, 
                        BillDate__c, 
                        BilledAmount__c 
                from Bill__c 
                where BillingContract__c in :contractIds
                    and BillDate__c >= :Date.today().addMonths(-12)];        // last 12 months only
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           25 May 2018
    @param          List<Id> - contract Ids
    @return         List<DebtRecoveryProcess__c> - debt recovery processes
    @description    gets the related debt recovery process records
    *******************************************************************************/
    private List<DebtRecoveryProcess__c> getDebtRecoveryProcesses(List<Id> contractIds) {
        return  [select Id, 
                        BillingContract__c, 
                        PaymentDueDate__c, 
                        TotalAmountDue__c, 
                        CurrentStage__c, 
                        CurrentStageDateTime__c
                from DebtRecoveryProcess__c 
                where BillingContract__c in :contractIds];
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           25 May 2018
    @param          List<Id> - contract Ids
    @return         List<Payment__c> - payments
    @description    gets the related payment records
    *******************************************************************************/
    private List<Payment__c> getPayments(List<Id> contractIds) {
        return  [select Id, 
                        BillingContract__c, 
                        Amount__c, 
                        PaymentMethod__c, 
                        PaymentSource__c, 
                        PaymentDate__c 
                from Payment__c 
                where BillingContract__c in :contractIds
                    and PaymentDate__c >= :Date.today().addMonths(-12)];        // last 12 months only
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           25 May 2018
    @param          List<Id> - contract Ids
    @return         List<PaymentPlan__c> - payment plans
    @description    gets the related payment plan records
    *******************************************************************************/
    private List<PaymentPlan__c> getPaymentPlans(List<Id> contractIds) {
        return  [select Id, 
                        Name, 
                        BillingContract__c,   // AT-3174 
                        PaymentFrequency__c, 
                        PaymentPlanTotal__c, 
                        StartDate__c, 
                        TotalInstalmentAmount__c, 
                        (select Id, 
                                InstalmentAmountDue__c, 
                                InstalmentAmountOutstanding__c, 
                                InstalmentDueDate__c, 
                                InstalmentNumber__c, 
                                SumofAllocatedPayment__c
                        from Instalments__r)
                from PaymentPlan__c 
                where BillingContract__c in :contractIds  // AT-3174 
                    and Active__c = true];      // active only
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 May 2018
    @param          Boolean - isSubDevicesQuery (uses device Ids rather than contract ids)
    @param          Set<Id> - Ids (supply point Ids for main devices, device Ids for sub devices)
    @return         List<Device__c> - devices
    @description    gets the devices, their device relationships and readings records
    @revision       Echo: Ankit Gangwani, Remove the DeviceRelationship__c reference, 26 June 2018, AT-2926
    *******************************************************************************/
    private List<Device__c> getDevices(Boolean isSubDevicesQuery, Set<Id> Ids) {
        
        String filterStatement = ' SELECT ' + GlUt_APIConstantsDevice.Id + ' , ' + GlUt_APIConstantsDevice.DEVICENAMEAPINAME + ' , ' + GlUt_APIConstantsDevice.SERIALNOAPINAME + ' , ' + GlUt_APIConstantsDevice.DIGITSAPINAME + ' , ' +  GlUt_APIConstantsDevice.DEVICETYPEAPINAME;
        filterStatement += ' FROM ' + GlUt_APIConstantsDevice.DEVICEAPINAME;
        
        if(isSubDevicesQuery)
            filterStatement += '  WHERE ID IN : Ids' ;
        else
            filterStatement += ' WHERE ID IN (select ' + GlUt_APIConstantsDevice.DEVICEAPINAME 
            + ' FROM ' + GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME 
            + ' WHERE ' + GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME + ' IN: Ids)';
        
        return Database.query(filterStatement);
    }
    

}