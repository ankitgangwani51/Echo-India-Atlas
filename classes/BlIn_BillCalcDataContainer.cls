/******************************************************************************
@author         Accenture: Patrick Dixon
@date           29 Aug 2017
@description    A data transfer object (DTO) class used to create an instance 
                of the data extracted from Salesforce records to format the 
                JSON message which is passed to the bill calculation REST service

        This class runs without object and field permission checks since: 
        (a) Its primary function is to synchronise data between Heroku and Salesforce
            and this requires access to all records/fields
        (b) It does not expose record data to the user
        
@revision(s)    MP2 - 06 Nov 2017, P Dixon
                MP3 - 07 Feb 2018, P Dixon - additions for TE
                MP4 - 16 Mar 2018, P Dixon - additions for amended Tax Classification & Discount
                06 Jun 2018, P Dixon - added bill event
                AT-4567,05 Dec 2018, Tarun Gupta - Sent Invalid Move In\Out readings as well in the payload
                AT-4567,14 Dec 2018, Tarun Gupta - Sent All Invalid Move In\Out readings(whether billed or unbilled) as well in the payload
                AT-4485,20 Dec 2018, Amit K. - Sent Rural Gross Consumptions records in payload.
                AT-4888, Checkmarks issues.
                AT-3489/AT-5108: Sudhir Kumar: I want to define a % of consumption to charge site supplies
*******************************************************************************/
/******************************************************************************
Object Hierarchy
----------------

[SDFC Name (DTO Name)]
BillCalculation__c (BlIn_BillCalcObj)
BillEvent__c (BlIn_BillEventObj)
ContractGroup__c (BlIn_BillCalcContractGroupObj)
    ->  BillingContract__c (BlIn_BillCalcContractObj)
        ->  TaxClassification__c (BlIn_BillCalcTaxClassificationObj)
            ->  [Amended] TaxClassification__c (BlIn_BillCalcTaxClassificationObj)
        ->  Discount__c (BlIn_BillCalcDiscountObj)
            ->  [Amended] Discount__c BlIn_BillCalcDiscountObj
        ->  Service__c (BlIn_BillCalcServiceObj)
            -> [Amended] TEDevice__c(BlIn_BillCalcDataContainer)   //AT-3147
            -> [Amended] VolumePercentage__c (BlIn_BillCalcDataContainer)    //AT-3147
            -> AvailableServiceId  (BlIn_BillCalcServiceObj) //AT-3725
            ->  SupplyPoint__c (BlIn_BillCalcSupplyPoint)
                ->  Sample__c (BlIn_BillCalcSamplesObj)
                    ->  [Amended] Sample__c (BlIn_BillCalcSamplesObj)
                ->  SupplyPointDevice__c (BlIn_BillCalcSupplyPointDevice)
                    ->   BlIn_BillCalcAverageDailyUseObj)
                    ->  [Amended] TEDevice 
                    ->  Device__c (BlIn_BillCalcServDeviceObj)
                        ->  Reading__c (BlIn_BillCalcServReadingObj)
                            ->  [Amended] Readings__c BlIn_BillCalcServReadingObj
                        ->  SubDevices__c BlIn_BillCalcServSubDeviceObj
                            ->  Reading__c (BlIn_BillCalcServReadingObj)
                                ->  [Amended] Readings__c BlIn_BillCalcServReadingObj
               ->  AvailableService __c (BlIn_BillCalcAvailableServiceObj)
                    ->  ChargeBasis__c (BlIn_BillCalcServCrgBasisObj)
                        ->  [Amended] ChargeBase__c (BlIn_BillCalcServCrgBasisObj)
               ->  RuralGrossConsumption__c (BlIn_BillCalcRuralGrossConsumptionObj)
                   -> [Amedned] RuralGrossConsumption__c BlIn_BillCalcRuralGrossConsumptionObj
            ->  ServiceItem__c (BlIn_BillCalcServiceItemObj)
                ->  [Amended] ServiceItem__c (BlIn_BillCalcServiceItemObj)
                    ->  GroupItem__c (BlIn_BillCalcServiceItemGroupItemObj)
                    ->  AgreedRate__c (BlIn_BillCalcServItmAgreedRateObj)
                ->  GroupItem__c (BlIn_BillCalcServiceItemGroupItemObj)
                ->  AgreedRate__c (BlIn_BillCalcServItmAgreedRateObj)
                    ->  [Amended] AgreedRate__c BlIn_BillCalcServItmAgreedRateObj
                -> [Amended] DischargeAgreement__c (BlIn_BillCalcDischargeAgmtObj)    //AT-3147 D.A.  moved under Service Item
                    ->[Amended] Volume Percentage (BlIn_BillCalcDataContainer)    //AT-3452
                    ->  AgreedVolume__c (BlIn_BillCalcAgreedVolumeObj)
                      ->  [Amended] AgreedVolume__c (BlIn_BillCalcAgreedVolumeObj)
                    ->  AgreedSampleStrength__c (BlIn_BillCalcAgrdSmplStrengthObj)
                        ->  [Amended] AgreedSampleStrength__c (BlIn_BillCalcAgrdSmplStrengthObj)
                       **AT-3147************DischargePoint__c removed ************************
                    ->  DischargePoint__c (BlIn_BillCalcDischargePointObj)    -- Unmeasured TE only
                        ->  SupplyPoint__c (BlIn_BillCalcDischargeSupplyPoint)
                         ->  Sample__c (BlIn_BillCalcSamplesObj)
                                ->  [Amended] Sample__c (BlIn_BillCalcSamplesObj)
                         **AT-3147************DischargePoint__c removed ************************
                    ->  Sample__c (BlIn_BillCalcSamplesObj)
                       ->  [Amended] Sample__c (BlIn_BillCalcSamplesObj)
        ->  ManualAmendment__c (BlIn_BillCalcManualAmendmentObj)
                                    
*******************************************************************************/
public with sharing class BlIn_BillCalcDataContainer {
    private static final String CLASS_NAME = 'BlIn_BillCalcDataContainer';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    // utility methods used to format date and datetime fields for json as yyyy-MM-dd HH:mm:ss
    private static String dateToString(Date d) {return d != null ? String.valueOf(d) + ' 00:00:00' : null;}
    private static String dateToString(DateTime dt) {return dt != null ? String.valueOf(dt) : null;}
    private static String decimalToString(Decimal d) {return d != null ? String.valueOf(d) : null;} // AT-3489
    // the records required for the billing data payload
    public List<BillingContract__c> contracts;
    @testVisible private List<Service__c> services;
    private List<ServiceItem__c> serviceItems;      // includes amended records
    private List<GroupItem__c> groupItems;      // includes related group records
    private List<ManualAmendment__c> manualAmendments;
    private List<SupplyPoint__c> supplyPoints;      // includes related site area records
    private List<Sample__c> samples;     // includes amended records
    @testVisible private List<AverageDailyUsage__c> averageDailyUses;      // only those covering the readings period
    private List<AvailableService__c> availableServices; 
    private List<ChargeBasis__c> chargeBases;     // includes amended records
    private List<AgreedRate__c> agreedRates;     // includes amended records
    private List<Device__c> devices;
    private Map<Id, Set<Id>> serviceTypeMap;     // map of set of the ServiceType Ids keyed on SupplyPoint Id used to identify correct device
    private List<Device__c> subDevices;
    private List<Reading__c> readings;     // unbilled only, includes amended records
    //Start of AT - 2755
    private List<SIAgreedVolume__c> serviceItemAgreedVolumes;
    private List<SupplyPointAllowance__c> supplyPointAllowances; 
    //End of AT - 2755
    // TE additional objects
    private List<DischargeAgreement__c> dischargeAgreements;
    private List<AgreedVolume__c> agreedVolumes;
    private List<AgreedSampleStrength__c> agreedSampleStrengths;
    private List<DischargePoint__c> dischargePoints;
    // simulated billing additions
    private List<Discount__c> discounts;        // includes amended records
    private List<TaxClassification__c> taxClassifications;      // includes amended records
    private List<Sample__c> sampleData;     // AT-3147
    private List<Suppression__c> suppression;  //AT-3297
    private Map<Id,List<RuralGrossConsumption__c>> mapOfRuralGrossConsumption2AmendedRuralGrossConsumptions; //AT-4485
    private map<Id, SiteSupply__c> mapAmendedSiteSupply ; //AT-3489
    private map<Id, Id> mapSiteSupplyPointId2CustomerSupplyPointId ; //AT-3489
    //private map<Id, Id> mapSupplyPointId2List<SupplyPoint_SiteSupplyPointObj ; //AT-3489
    private map<Id, SupplyPoint__c> mapCustomerSupplyPointId2SiteSupplyPointObj ;
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           29 Aug 2017
    @param          List<BillingContract__c> - the list of contracts
    @description    Constructor
    *******************************************************************************/
    public BlIn_BillCalcDataContainer(List<BillingContract__c> contracts) {
        
        this.contracts = contracts;
        List<Id> contractIds = new List<Id>();
        Set<Id> accountIds = new Set<Id>();

        // build a list of the contract Ids
        for (BillingContract__c contract : contracts) {
            contractIds.add(contract.Id);
            //AT-2102, Ankit, 16/04/2019
            if(contract.AccountName__c != null)
                accountIds.add(contract.AccountName__c);
        }
        system.debug('contractIds========'+contractIds);
        // get all the related tax classification records
        taxClassifications = getTaxClassifications(contractIds);
        system.debug('taxClassifications========'+taxClassifications);
        // get all the related discount records
        discounts = getDiscounts(contractIds);

        // get all the related service records
        services = getServices(contractIds);
        
        // get all the related service items records
        serviceItems = getServiceItems(contractIds);
        
        System.debug('03 contractIds = '+contractIds);
         //AT-3297 get the related Suppression record
        suppression = getSuppressionDetails(contractIds);     //AT-3297
        System.debug('04 suppression = '+suppression);
        if(suppression.size() == 0)
            suppression = getSuppressionDetailsByAccount(accountIds);
        System.debug('05 suppression = '+suppression);
        //Start of AT - 2755
        //get all the related Service Item Agreed Volumes records
        serviceItemAgreedVolumes = getServiceItemAgreedVolumes(contractIds);
        //End of AT - 2755
        
        // get all the related group/group items records
        groupItems = getGroupItems(contractIds);
        system.debug('groupItems====='+groupItems);
        // get all the related manual amendment records
        manualAmendments = getManualAmendments(contractIds);
        
        // get all the related agreed rate records
        agreedRates = getAgreedRates(contractIds);

        // get TE discharge agreements
        dischargeAgreements = getDischargeAgreements(contractIds);

        // build a list of the discharge agreements to get the associated records
        List<Id> dischargeAgreementIds = new List<Id>();
        for (DischargeAgreement__c dischargeAgreement : dischargeAgreements) {
            dischargeAgreementIds.add(dischargeAgreement.Id);
        }
        
        // get related TE agreed volumes
        agreedVolumes = getAgreedVolumes(dischargeAgreementIds);

        // get related TE agreed sample strengths
        agreedSampleStrengths = getAgreedSampleStrengths(dischargeAgreementIds);
        
        // get related TE discharge points
        dischargePoints = getDischargePoints(dischargeAgreementIds);
        
        // get all the supply point related records
        supplyPoints = getSupplyPoints(contractIds);
        supplyPoints.addAll(getTESupplyPoints(dischargeAgreementIds));      // unmeasured TE supply points
        mapOfRuralGrossConsumption2AmendedRuralGrossConsumptions = getRuralGrossConsumptions(supplyPoints); //AT-4485
        // build a list of the supply point devices to get the associated records
        List<Id> supplyPointIds = new List<Id>();
        mapAmendedSiteSupply = new map<Id, SiteSupply__c>() ;  // AT-3489
        mapSiteSupplyPointId2CustomerSupplyPointId = new map<Id, Id>() ; 
        mapCustomerSupplyPointId2SiteSupplyPointObj = new map<Id, SupplyPoint__c> ()  ;
        
        system.debug('supplyPoints=> ' + supplyPoints) ;
        for (SupplyPoint__c supplyPoint : supplyPoints) {
            supplyPointIds.add(supplyPoint.Id);
            system.debug('supplyPoint.SiteSupplies1__r=> ' + supplyPoint.SiteSupplies1__r) ;
            if(supplyPoint.SiteSupplies1__r != null && !supplyPoint.SiteSupplies1__r.isEmpty()) {  // AT-3489
                for(SiteSupply__c siteSupply : supplyPoint.SiteSupplies1__r) {
                    SiteSupply__c amendedSiteSupply = siteSupply ;
                    system.debug('siteSupply=> ' + siteSupply);
                    if(!siteSupply.Invalid__c && !siteSupply.Ended__c && siteSupply.AmendedBySiteSupply__c == null && !mapAmendedSiteSupply.containsKey(siteSupply.Id)) { //updated 04/03
                        mapAmendedSiteSupply.put(siteSupply.Id, new SiteSupply__c()) ;
                    } 
                    system.debug('mapAmendedSiteSupply1=> ' + mapAmendedSiteSupply);
                    system.debug('siteSupply.AmendedBySiteSupply__c=> ' + siteSupply.AmendedBySiteSupply__c);
                    if(siteSupply.AmendedBySiteSupply__c != null && mapAmendedSiteSupply.containsKey(siteSupply.AmendedBySiteSupply__c)) {
                        mapAmendedSiteSupply.put(siteSupply.AmendedBySiteSupply__c, siteSupply) ;
                    }
                    system.debug('mapAmendedSiteSupply2=> ' + mapAmendedSiteSupply);
                    system.debug('supplyPoint.Id=> ' + supplyPoint.Id);
                    system.debug('siteSupply.SupplyPoint__c=> ' + siteSupply.SupplyPoint__c);
                    system.debug('siteSupply.SiteSupplyPoint__c=> ' + siteSupply.SiteSupplyPoint__c);
                    if(supplyPoint.Id == siteSupply.SupplyPoint__c && !mapSiteSupplyPointId2CustomerSupplyPointId.containsKey(siteSupply.SiteSupplyPoint__c)) {
                        mapSiteSupplyPointId2CustomerSupplyPointId.put(siteSupply.SiteSupplyPoint__c, siteSupply.SupplyPoint__c) ;
                    }
                    
                }                
            }
        }
        system.debug('mapSiteSupplyPointId2CustomerSupplyPointId=> ' + mapSiteSupplyPointId2CustomerSupplyPointId) ;
        system.debug('mapAmendedSiteSupply=> ' + mapAmendedSiteSupply) ;
        mapCustomerSupplyPointId2SiteSupplyPointObj = getMapMainSupplyPoints(mapSiteSupplyPointId2CustomerSupplyPointId) ;
        system.debug('mapCustomerSupplyPointId2SiteSupplyPointObj=> ' + mapCustomerSupplyPointId2SiteSupplyPointObj) ;
        // Get all the sample related records
        //  samples = getSamples(supplyPointIds);   //AT-3147 Commented  
        samples  = getSamples(dischargeAgreementIds);   // AT-3147
        
        // get all the related available services records
        availableServices = getAvailableServices(supplyPointIds);
        
        //Start of AT - 2755
        //get all the related Supply Point Allowances records
        supplyPointAllowances = getSupplyPointAllowances(contractIds,supplyPointIds);
        //End of AT - 2755

        // get all the related charge bases records
        chargeBases = getChargeBases(supplyPointIds);

        // get all the related devices and their device relationships and readings records
        // AT-3489
        system.debug('Device-supplyPointIds-1=> ' + supplyPointIds);
        if(!mapSiteSupplyPointId2CustomerSupplyPointId.isEmpty()) {
            for(Id siteSupplyPointId : mapSiteSupplyPointId2CustomerSupplyPointId.keySet()) {
                supplyPointIds.add(siteSupplyPointId) ;
            }
        }
        system.debug('Device-supplyPointIds-2=> ' + supplyPointIds);
        devices = getDevices(supplyPointIds);
        system.debug('devices=> ' + devices); 
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
        system.debug('deviceIds=> ' + deviceIds); 
        // build the service type map for the main devices
        serviceTypeMap = buildServiceTypeMap(deviceIds);
        
        // then get all the sub devices and their related readings records
        /*subDevices = getDevices(true, subDeviceIds);
        
        // add the sub device Ids to the set of main device Ids
        for (Device__c device : subDevices) {
            deviceIds.add(device.Id);
        }*/ // AT-2926, Sub device is not required anymore

        // get all the devices' readings and amended readings records
        readings = getReadings(deviceIds);
        system.debug('readings****'+ readings);

        // find the date of the earliest reading
        Date earliestReadingDate = Date.today();
        for (Reading__c reading : readings) {
            if(reading.BillableType__c == Label.CuAp_ReadingBillableTypeBillable && !reading.AllServicesBilled__c)
                earliestReadingDate = earliestReadingDate > reading.ReadingDate__c ? reading.ReadingDate__c : earliestReadingDate;            
            
        }

        // and get all the related average daily use records for the period covered by the readings
        averageDailyUses = getAverageDailyUses(supplyPointIds, earliestReadingDate); 
    }

    /* METHODS FOR STEP 1: get all the data records required */
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           16 Mar 2018
    @param          List<Id> - contract Ids
    @return         List<TaxClassification__c> - tax classification
    @description    gets all the tax classification related related records
    *******************************************************************************/
    private List<TaxClassification__c> getTaxClassifications(List<Id> contractIds) {
        return [select Id, 
                        Account__c, 
                        TaxClassificationType__c, 
                        Invalid__c, //AT-3322
                        SICStartDate__c, 
                        SICEndDate__c,
                        CreatedDate,//AT-3431- Dependra
                        (select Id, 
                                Account__c, 
                                TaxClassificationType__c,                                 
                                Invalid__c, //AT-3322
                                SICStartDate__c, 
                                SICEndDate__c,
                                CreatedDate
                        from AmendedTaxClassifications__r)
                        
                from TaxClassification__c
                where Account__c in (select AccountName__c from BillingContract__c where Id in :contractIds)
                    and AmendedByTaxClassification__c = null      // unamended only
                ];
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           16 Mar 2018
    @param          List<Id> - contract Ids
    @return         List<Discount__c> - discount
    @description    gets all the discount related related records
    *******************************************************************************/
    private List<Discount__c> getDiscounts(List<Id> contractIds) {
        return [select Id, 
                        BillingContract__c, 
                        DiscountType__c, 
                        StartDate__c, 
                        EndDate__c, 
                        Status__c, 
                        CreatedDate,//AT-3431
                        Invalid__c, //AT-3322
                        BaseDiscountAmount__c, 
                        BaseDiscountPercentage__c, 
                        OverriddenDiscountAmount__c, 
                        OverriddenDiscountPercentage__c, 
                		Concession__c, // SIT005, Ankit, 05/04/2019
                        BaseDailyDiscountAmount__c, //AT-4413                
                        OverriddenDailyDiscountAmount__c,  //AT-4413
                        (select Id, 
                                DiscountType__c, 
                                StartDate__c, 
                                EndDate__c, 
                                Status__c,
                                CreatedDate, //AT-3839
                                Invalid__c, //AT-3322
                                BaseDiscountAmount__c, 
                                BaseDiscountPercentage__c,  
                                OverriddenDiscountAmount__c, 
                         		Concession__c, // SIT005, Ankit, 05/04/2019
                                OverriddenDiscountPercentage__c, 
                                BaseDailyDiscountAmount__c, //AT-4413
                                OverriddenDailyDiscountAmount__c //AT-4413
                        from AmendedDiscounts__r)
                from Discount__c
                where BillingContract__c in :contractIds
                    and AmendedByDiscount__c = null      // unamended only
                ];
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           04 Sep 2017
    @param          List<Id> - contract Ids
    @return         List<Service__c> - services
    @description    gets the related service records
    *******************************************************************************/
    private List<Service__c> getServices(List<Id> contractIds) {
        return  [select Id, 
                        BillingContract__c, 
                        ServiceType__c,
                        SupplyPoint__c, 
                        OccupancyType__c, // AT-3517
                        AvailableService__c,   //AT-3725
                        VolumePercentage__c    // AT-3147
                from Service__c 
                where BillingContract__c in :contractIds];
    }
 
    /******************************************************************************
    @author         Echo : Vivek Sethi    AT-3297
    @date           06 Aug 2017
    @param          List<Id> - contract Ids
    @return         List<Suppression__c> - Suppression
    @description    gets the related Suppression records
    *******************************************************************************/
    private List<Suppression__c> getSuppressionDetails(List<Id> contractIds) {
        return  [select Id, 
                 Name, 
                 BillingContract__c , 
                 Account__c, //AT-2102, Ankit, 15/04/2019
                 SuppressBillPrint__c,
                 CreatedDate
                 from Suppression__c 
                 where BillingContract__c in :contractIds
                 and SuppressionStartDate__c <= :Date.today()
                 and (SuppressionEndDate__c = null or SuppressionEndDate__c > :Date.today()) limit 1]; 
    }
    
    /******************************************************************************
    @author         Echo : Ankit Gangwani
    @date           16 April 2019
    @param          Set<Id> - accountIds
    @return         List<Suppression__c> - Suppression
    @description    gets the related Suppression records
    *******************************************************************************/
    private List<Suppression__c> getSuppressionDetailsByAccount(Set<Id> accountIds) {
        return  [select Id, 
                 Name, 
                 Account__c, 
                 BillingContract__c,
                 SuppressBillPrint__c,
                 SuppressionEndDate__c,
                 CreatedDate
                 from Suppression__c 
                 where Account__c in :accountIds
                 and SuppressionStartDate__c <= :Date.today()
                 and (SuppressionEndDate__c = null or SuppressionEndDate__c > :Date.today()) limit 1]; 
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           04 Sep 2017
    @param          List<Id> - contract Ids
    @return         List<ServiceItem__c> - service items
    @description    gets the related service item records
    *******************************************************************************/
    private List<ServiceItem__c> getServiceItems(List<Id> contractIds) {
        return  [select Id, 
                        Service__c, 
                        ServiceItemType__c,
                        CreatedDate, //AT-3322
                        StartDate__c, 
                        EndDate__c,
                        Ended__c, // AT-3892, AT-3898
                        Quantity__c,
                        Invalid__c, //AT-3322
                        DischargeAgreement__c,  //VS AT-3147
                        //AT-4991, Ankit, 18/01/2018
                        DischargeFactor__c,                         
                        (select Id, 
                                ServiceItemType__c, 
                                CreatedDate, //AT-3322
                                StartDate__c, 
                                EndDate__c, 
                                Ended__c, // AT-3892, AT-3898
                                Quantity__c,
                                Invalid__c, //AT-3322
                                DischargeAgreement__c, //VS AT-3147                                
                                DischargeFactor__c //AT-4991, Ankit, 18/01/2018
                        from AmendedServiceItems__r)
                                            
                from ServiceItem__c 
                where Service__r.BillingContract__c in :contractIds
                    and AmendedByServiceItem__c = null      // unamended only
                ];
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           21 June 2018
    @param          List<Id> - contract Ids
    @return         List<SIAgreedVolume__c> - Service Item Agreed Volume
    @description    AT - 2755 gets the related Service Item Agreed Volume records
    *******************************************************************************/
    private List<SIAgreedVolume__c> getServiceItemAgreedVolumes(List<Id> contractIds) {
        return  [select Id, 
                        ServiceItem__c, 
                        StartDate__c,
                        EndDate__c,
                        Volume__c,
                        Invalid__c, //AT-3322
                        CreatedDate,
                 
                 (select Id,  
                         StartDate__c, 
                         EndDate__c, 
                         Volume__c,
                         Invalid__c, //AT-3322
                         CreatedDate
                  from SIAgreedVolume__r)
                                            
                from SIAgreedVolume__c 
                where ServiceItem__r.Service__r.BillingContract__c in :contractIds
                 and SIAgreedVolume__c = null     // MT - 10/08/2018 AT - 3310
                ];
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           26 Oct 2017
    @param          List<Id> - contract Ids
    @return         List<GroupItem__c> - group items
    @description    gets the group item and related group records
    *******************************************************************************/
    private List<GroupItem__c> getGroupItems(List<Id> contractIds) {
        return  [select Id, 
                        ServiceItem__c, 
                        Group__c 
                from GroupItem__c 
                where ServiceItem__r.Service__r.BillingContract__c in :contractIds];
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           04 Sep 2017
    @param          List<Id> - contract Ids
    @return         List<AgreedRate__c> - agreed rates
    @description    gets the agreed rate records
    *******************************************************************************/
    private List<AgreedRate__c> getAgreedRates(List<Id> contractIds) {
        return [select Id, 
                        ServiceItem__c, 
                        Value__c,
                        StartDate__c,
                        EndDate__c, 
                        
                        (select Id, 
                                ServiceItem__c, 
                                Value__c,
                                StartDate__c,
                                EndDate__c 
                        from AmendedAgreedRates__r)
                        
                from AgreedRate__c 
                where ServiceItem__r.Service__r.BillingContract__c in :contractIds
                    and AmendedByAgreedRate__c = null       // unamended only
                ];
    }
    
    //AT-3489
    private map<Id, SupplyPoint__c> getMapMainSupplyPoints(map<Id, Id> mapSiteSupplyPointId2CustomerSupplyPointId) {
        map<Id, SupplyPoint__c> mapSiteMainSupplyPoints = new map<Id, SupplyPoint__c>() ;
        if(!mapSiteSupplyPointId2CustomerSupplyPointId.isEmpty()) {
            list<SupplyPoint__c> listMainSupplyPoint = [SELECT Id, Name, RuralOutletBillingType__c, 
                                                            (SELECT Id, Name, TEDevice__c, Device__c, Active__c, Ended__c, RemovalDate__c FROM SupplyPointDevices__r) 
                                                        FROM SupplyPoint__c 
                                                        WHERE Id IN: mapSiteSupplyPointId2CustomerSupplyPointId.keySet()] ;
            system.debug('listMainSupplyPoint=> ' + listMainSupplyPoint);
            
            for(SupplyPoint__c supplyPoint : listMainSupplyPoint) {
                system.debug('SupplyPointDevices__r=> ' + supplyPoint.SupplyPointDevices__r);
                mapSiteMainSupplyPoints.put(mapSiteSupplyPointId2CustomerSupplyPointId.get(supplyPoint.Id), supplyPoint) ;
            }
        }
        system.debug('mapSiteMainSupplyPoints=> ' + mapSiteMainSupplyPoints);
        return mapSiteMainSupplyPoints ;
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           04 Sep 2017
    @param          List<Id> - contract Ids
    @return         List<SupplyPoint__c> - subDevices
    @description    gets all the supply point related records
                    (AT-4485) get related Rural Gross Consumption Records
    *******************************************************************************/
    private List<SupplyPoint__c> getSupplyPoints(List<Id> contractIds) {        
        return [select Id, 
                Name,
                RuralOutletBillingType__c,
                (select Id, 
                 Name, 
                 TEDevice__c,   //VS AT-3147
                 Device__c,
                 Active__c,
                 Ended__c,
                 RemovalDate__c
                 from SupplyPointDevices__r),
                // START: AT-3489/AT-5108
                (SELECT Id, SiteSupplyPoint__c, 
                 SupplyPoint__c, StartDate__c, EndDate__c, Ended__c, 
                 PercentageSplit__c, AmendedBySiteSupply__c, Invalid__c 
                 FROM SiteSupplies1__r WHERE (Invalid__c = True OR (Ended__c = True AND EndDate__c != null) OR (Invalid__c = false  AND Ended__c = false)) ORDER By CreatedDate DESC), //updated 04/03  // Customer's Site Supply // 
                // END: AT-3489/AT-5108
                (select Id,
                 StartDate__c,
                 EndDate__c,
                 Reading__c,
                 Type__c,
                 Invalid__c,
                 Consumption__c,
                 Billed__c,
                 AmendedBy__c,
                 CreatedDate,
                 SupplyPoint__c,
                 ChannelOpen__c,
                 RuralMeasurement__c,
                 RuralEntitlement__c
                 from RuralGrossConsumptions__r Where Billed__c = false AND AmendedBy__c = NULL
                )
                from SupplyPoint__c 
                where Id in (select SupplyPoint__c from Service__c where BillingContract__c = :contractIds)];
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           20 Dec 2018
    @param          List<SupplyPoint__c> supplyPoints
    @return         Map<Id,List<RuralGrossConsumption__c>> map of RuralGross Consumption having amended Consumptions.
    @description    gets rural gross Consumptions having amended rural gross consumptions
                    (AT-4485) 
    *******************************************************************************/
    private Map<Id,List<RuralGrossConsumption__c>> getRuralGrossConsumptions(List<SupplyPoint__c> supplyPoints) {
        Map<Id,List<RuralGrossConsumption__c>> mapOfRuralGrossConsumption2AmendedRuralGrossConsumptions = new Map<Id,List<RuralGrossConsumption__c>>();
        List<Id> ruralGrossConsumptionList = new List<Id>();
        for(SupplyPoint__c sp : supplyPoints){
            //Fetch supply point associated rural gross consumptions which not amended.
            for(RuralGrossConsumption__c ruralGrossConsumption: sp.RuralGrossConsumptions__r){
                  ruralGrossConsumptionList.add(ruralGrossConsumption.Id);         
            }
        }
        List<RuralGrossConsumption__c> amendedRuralGrossConsumptionList = new List<RuralGrossConsumption__c>();
        if(!ruralGrossConsumptionList.isEmpty()){
            //Fetch rural gross consumptions that has been amended.
            amendedRuralGrossConsumptionList =  [Select Id,
                                                 (select Id,
                                                  StartDate__c,
                                                  EndDate__c,
                                                  Reading__c,
                                                  Type__c,
                                                  Invalid__c,
                                                  Consumption__c,
                                                  Billed__c,
                                                  AmendedBy__c,
                                                  CreatedDate,
                                                  SupplyPoint__c,
                                                  ChannelOpen__c,
                                                  RuralMeasurement__c,
                                                  RuralEntitlement__c 
                                                  from RuralGrossConsumptions1__r)
                                                 from RuralGrossConsumption__c Where Id IN: ruralGrossConsumptionList];
        
            if(amendedRuralGrossConsumptionList != null && !amendedRuralGrossConsumptionList.isEmpty()){
                for(RuralGrossConsumption__c newRuralGrossConsumption : amendedRuralGrossConsumptionList){
                    for(RuralGrossConsumption__c amendedRuralGrossConsumption: newRuralGrossConsumption.RuralGrossConsumptions1__r){
                        //Create Map of Rural Gross consumptions having child records i.e. Amended rural gross consumptions.
                        if(!mapOfRuralGrossConsumption2AmendedRuralGrossConsumptions.containsKey(newRuralGrossConsumption.Id)){
                            mapOfRuralGrossConsumption2AmendedRuralGrossConsumptions.put(newRuralGrossConsumption.Id,new List<RuralGrossConsumption__c>());
                        }
                        mapOfRuralGrossConsumption2AmendedRuralGrossConsumptions.get(newRuralGrossConsumption.Id).add(amendedRuralGrossConsumption);
                    }
                }
                 
            }
        }
        
        return mapOfRuralGrossConsumption2AmendedRuralGrossConsumptions;
    }
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           07 Feb 2018
    @param          List<Id> - discharge agreement Ids (for unmeasured TE)
    @return         List<SupplyPoint__c> - subDevices
    @description    gets all the unmeasured TE supply point related records
    *******************************************************************************/
    private List<SupplyPoint__c> getTESupplyPoints(List<Id> dischargeAgreementIds) {
        return [select Id, 
                        Name, 
                        
                        (select Id, 
                                Name, 
                                Device__c 
                        from SupplyPointDevices__r)

                from SupplyPoint__c 
                where Id in (select SupplyPoint__c from DischargePoint__c where DischargeAgreement__c = :dischargeAgreementIds)];
    }
   
    /******************************************************************************
    @author         Echo: Vivek Sethi    AT-3147
    @date           17 July 2018
    @param          List<Id> - discharge agreement Ids
    @return         List<Sample__c> - Samples
    @description    get the Samples
    *******************************************************************************/
    private List<Sample__c> getSamples(List<Id> dischargeAgreementIds) {
        return [select Id,  
                name, 
                AmendedBySample__c,      
                CODSampleStrength__c,
                SSSampleStrength__c,
                SampleCollectionDate__c,
                DischargeAgreement__c,     
                //AT-4991, Ankit, 18/01/2018
                Exclude__c, 
                PSampleStrength__c,
                TDSSampleStrength__c,
                TKNSampleStrength__c,
                (select Id, 
                     Name ,
                     AmendedBySample__c,      
                     CODSampleStrength__c,
                     SSSampleStrength__c,
                     SampleCollectionDate__c,
                     //AT-4991, Ankit, 18/01/2018
                     Exclude__c,
                     PSampleStrength__c,
                     TDSSampleStrength__c,
                     TKNSampleStrength__c,                 
                     DischargeAgreement__c
                  from AmendedSamples__r)  
                from Sample__c 
                where DischargeAgreement__c in :dischargeAgreementIds
               ];
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           04 Sep 2017
    @param          List<Id> - supplyPoint Ids
    @return         List<AvailableService__c> - availableServices
    @description    gets all the available services related related records
    *******************************************************************************/
    private List<AvailableService__c> getAvailableServices(List<Id> supplyPointIds) {
        return [select Id, 
                        SupplyPoint__c, 
                        ServiceType__c 
                from AvailableService__c
                where Id in (select AvailableService__c 
                             from Service__c 
                             where SupplyPoint__c in :supplyPointIds) 
                ];
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           21 June 2018
    @param          List<Id> - supplyPoint Ids
    @return         List<SupplyPointAllowance__c> - SupplyPointAllowances
    @description    AT - 2755 gets all the Supply Point Allowances related records
    *******************************************************************************/
    private List<SupplyPointAllowance__c> getSupplyPointAllowances(List<Id>contractIds,List<Id> supplyPointIds) {
        return [select Id, 
                        SupplyPoint__c, 
                        ServiceItem__c,
                        AllowanceType__c,
                        AllowancePriority__c,
                        AllowanceAmount__c, 
                        StartDate__c,
                        EndDate__c,
                        Type__c,
                        Invalid__c, //AT-3322
                        CreatedDate,
                       (select Id,
                               SupplyPoint__c, 
                               ServiceItem__c,
                               AllowanceType__c,
                               AllowancePriority__c,
                               AllowanceAmount__c, 
                               StartDate__c,
                               EndDate__c,
                               Type__c,
                               Invalid__c, //AT-3322
                               CreatedDate
                       from SupplyPointAllowance__r)
                from SupplyPointAllowance__c
                where SupplyPoint__c in :supplyPointIds
                and ServiceItem__r.Service__r.BillingContract__r.Id in :contractIds
                and SupplyPointAllowance__c = null   // MT - 10/08/2018 AT - 3310
                ];
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           02 Nov 2017
    @param          List<Id> - supplyPoint Ids
    @return         List<ChargeBasis__c> - charge bases
    @description    gets all the charge bases related related records
    *******************************************************************************/
    private List<ChargeBasis__c> getChargeBases(List<Id> supplyPointIds) {
        return [select Id, 
                        AvailableService__c, 
                        StartDate__c,
                        Invalid__c, //AT-3322
                        EndDate__c, 
                        Amount__c,
                        Type__c,//UL-221
                        (select Id, 
                                StartDate__c, 
                                EndDate__c,
                                Invalid__c, //AT-3322
                                Amount__c,
                                Type__c //UL-221
                         from AmendedChargeBases__r)
                from ChargeBasis__c
                where AvailableService__c in (select AvailableService__c from Service__c where SupplyPoint__c in :supplyPointIds)
                    and AmendedByChargeBasis__c = null      // unamended only
                ];
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           25 Oct 2017
    @param          List<Id> - supplyPoint Ids
    @param          Date - earliest reading date
    @return         List<AverageDailyUsage__c> - AverageDailyUses
    @description    gets the average daily use records
    *******************************************************************************/
    private List<AverageDailyUsage__c> getAverageDailyUses(List<Id> supplyPointIds, Date earliestReadingDate) {
        return [select Id, 
                        StartDate__c, 
                        EndDate__c, 
                        AverageDailyUsage__c, 
                        SupplyPointDevice__c,
                        RollingDailyUsage__c // AT-5070
                from AverageDailyUsage__c 
                where SupplyPointDevice__r.SupplyPoint__c in :supplyPointIds
                    and (EndDate__c = null
                        or EndDate__c >= :earliestReadingDate)
                and Invalid__c = false   //AT-3555
                ];
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           04 Sep 2017
    @param          List<Id> - supply point Ids
    @return         List<Device__c> - devices
    @description    gets the devices, their device relationships and readings records
    *******************************************************************************/
    private List<Device__c> getDevices(List<Id> supplyPointIds) {
        return getDevices(false, new Set<Id>(supplyPointIds));
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           05 Sep 2017
    @param          Boolean - isSubDevicesQuery (uses device Ids rather than contract ids)
    @param          Set<Id> - Ids (supply point Ids for main devices, device Ids for sub devices)
    @return         List<Device__c> - devices
    @description    gets the devices, their device relationships and readings records
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
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           31 Oct 2017
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
    @author         Accenture: Patrick Dixon
    @date           24 Oct 2017
    @param          Set<Id> - device Ids
    @return         List<Reading__c> - readings and amended readings
    @description    gets the unbilled readings and their amended readings records
    *******************************************************************************/
    private List<Reading__c> getReadings(Set<Id> deviceIds) {
        return [select Id, 
                       Device__c, //AT-3174
                       Reading__c, 
                       ReadingDate__c, 
                       CreatedDate, //AT-3322
                       ReadingType__c, 
                       ReadingSource__c, 
                       ReadingMethod__c, 
                       BillableType__c,
                       EffectiveReading__c, // AT-2926
                       Billed__c,
                       Leak__c,       // AT-2931...Core 7a  
                       Tripped__c,    // AT-3417...Core 8b  
                       CheckServiceItemTolerance__c, // UL-21, Ankit, 21/02/2019
                       AllServicesBilled__c,  //AT-3851
                       (select Id, 
                        Device__c, //AT-3174
                        Reading__c, 
                        ReadingDate__c, 
                        CreatedDate, //AT-3322
                        ReadingType__c, 
                        ReadingSource__c, 
                        ReadingMethod__c, 
                        BillableType__c,
                        EffectiveReading__c, // AT-2926
                        Billed__c,
                        Leak__c,      // AT-2931...Core 7a
                        Tripped__c,    // AT-3417...Core 8b 
                        CheckServiceItemTolerance__c, // UL-21, Ankit, 21/02/2019
                        AllServicesBilled__c  //AT-3851
                        from AmendedReadings__r)                       
               from Reading__c 
               where Device__c in :deviceIds//AT-3174
                   and AmendedByReading__c = null      // unamended only (these readings will also be BillableType = 'Invalid')
                   //and BillableType__c = :Label.CuAp_ReadingBillableTypeBillable        // billable types only
                   and BillableType__c != :Label.CuAp_ReadingBillableTypeNonBillable        // Non billable types only
                   //and AllServicesBilled__c = false  //modified under AT-3851...Billed__c = false       // unbilled only
                ];
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           06 Feb 2018
    @param          List<Id> - contract Ids
    @return         List<DischargeAgreement__c> - discharge agreements
    @description    gets the discharge agreement records
    *******************************************************************************/
    private List<DischargeAgreement__c> getDischargeAgreements(List<Id> contractIds) {
        // AT-3147
        return [select Id, 
                StartDate__c, 
                EndDate__c,
                VolumePercentage__c,  //AT-3452  
                MinNumberofSamples__c,   //AT-3147
                TradeWasteType__c //AT-4991, Ankit, 18/01/2018
                from DischargeAgreement__c 
                where Id in (select DischargeAgreement__c from ServiceItem__c where Service__r.BillingContract__c in : contractIds)
               ];
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           06 Feb 2018
    @param          List<Id> - discharge agreement Ids
    @return         List<AgreedVolume__c> - agreed volumes
    @description    gets the agreed volume records and their amended agreed volume records
    *******************************************************************************/
    private List<AgreedVolume__c> getAgreedVolumes(List<Id> dischargeAgreementIds) {
        
        return [select Id, 
                        AgreedVolume__c, 
                        DischargeAgreement__c, 
                        Invalid__c, //AT-3322
                        StartDate__c, 
                        EndDate__c, 
                        (select Id, 
                                AgreedVolume__c, 
                                Invalid__c, //AT-3322 
                                StartDate__c,
                                EndDate__c 
                        from AmendedAgreedVolumes__r)
                from AgreedVolume__c 
                where DischargeAgreement__c in :dischargeAgreementIds
                    and AmendedByAgreedVolume__c = null      // unamended only      
                ];
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           06 Feb 2018
    @param          List<Id> - discharge agreement Ids
    @return         List<AgreedSampleStrength__c> - agreed sample strengths
    @description    gets the agreed sample strength records
    *******************************************************************************/
    private List<AgreedSampleStrength__c> getAgreedSampleStrengths(List<Id> dischargeAgreementIds) {
        
        return [select Id, 
                        DischargeAgreement__c, 
                        CODAgreedSampleStrength__c, 
                        SSAgreedSampleStrength__c,
                        Invalid__c, //AT-3322
                        StartDate__c, 
                        EndDate__c, 
                        (select Id, 
                                CODAgreedSampleStrength__c, 
                                SSAgreedSampleStrength__c, 
                                Invalid__c, //AT-3322
                                StartDate__c,
                                EndDate__c 
                        from AmendedAgreedSampleStrengths__r)
                from AgreedSampleStrength__c 
                where DischargeAgreement__c in :dischargeAgreementIds
                    and AmendedByAgreedSampleStrength__c = null      // unamended only      
                ];
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           06 Feb 2018
    @param          List<Id> - discharge agreement Ids
    @return         List<DischargePoint__c> - discharge points
    @description    gets the discharge point records
    *******************************************************************************/
    private List<DischargePoint__c> getDischargePoints(List<Id> dischargeAgreementIds) {
        
        return [select Id,  
                        DischargeAgreement__c, 
                        SupplyPoint__c 
                from DischargePoint__c 
                where DischargeAgreement__c in :dischargeAgreementIds
                ];
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           01 Nov 2017
    @param          List<Id> - contract Ids
    @return         List<GroupItem__c> - group items
    @description    gets the manual amendment records
    *******************************************************************************/
    private List<ManualAmendment__c> getManualAmendments(List<Id> contractIds) {
        return [select Id, 
                        AmendedBillItem__r.BillServiceType__r.Bill__r.BillingContract__c, 
                        AmendedBillItem__c, 
                        Amount__c, 
                        AmendmentReason__c, 
                        ApprovalStatus__c ,   //AT-3286
                        Billed__c
                from ManualAmendment__c 
                where AmendedBillItem__r.BillServiceType__r.Bill__r.BillingContract__c in :contractIds
                    and Billed__c = false       // unbilled only
                ];
    }

    /* SUB-CLASSES FOR STEP 2: build the data using the DTO hierachy */
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           16 Mar 2018
    @description    Subclass for Tax Classification (without amended child records)
    *******************************************************************************/
    private virtual class BlIn_BillCalcAmendedTaxClassificationObj {

        private Id TaxClassificationId;//AT-3431
        private Id AccountId;
        private Id TaxClassificationTypeId;
        // private String SICCode2;// AT-3174
        private String SICStartDate;
        private String SICEndDate;
        private Boolean Invalid; //AT-3322
        private String CreatedDate;//AT-3431

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           16 Mar 2018
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          TaxClassification__c - tax classification record
        @description    Constructor
        *******************************************************************************/
         private BlIn_BillCalcAmendedTaxClassificationObj(BlIn_BillCalcDataContainer container, TaxClassification__c taxClassification) {
            TaxClassificationId = taxClassification.Id;
            // add the tax classification fields to this DTO
            AccountId = taxClassification.Account__c;
            TaxClassificationTypeId = taxClassification.TaxClassificationType__c;
            // SICCode2 = taxClassification.SICCode2__c; // AT-3174
            SICStartDate = dateToString(taxClassification.SICStartDate__c);
            SICEndDate = dateToString(taxClassification.SICEndDate__c);
            Invalid = taxClassification.Invalid__c; //AT-3322
            CreatedDate=  dateToString(taxClassification.CreatedDate);
        }
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           16 Mar 2018
    @description    Subclass for Tax Classification (extends base class DTO to include child amended records)
    *******************************************************************************/
    private class BlIn_BillCalcTaxClassificationObj extends BlIn_BillCalcAmendedTaxClassificationObj {

        private List<BlIn_BillCalcAmendedTaxClassificationObj> AmendedTaxClassifications;

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           16 Mar 2018
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          TaxClassification__c - tax classification record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcTaxClassificationObj(BlIn_BillCalcDataContainer container, TaxClassification__c taxClassification) {
            
            super(container, taxClassification);
            
            // build the list of amended tax classification item DTOs
            AmendedTaxClassifications = new List<BlIn_BillCalcAmendedTaxClassificationObj>();  
            for (TaxClassification__c amendedTaxClassification : taxClassification.AmendedTaxClassifications__r) {
                AmendedTaxClassifications.add(new BlIn_BillCalcAmendedTaxClassificationObj(container, amendedTaxClassification));
            }
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           06 Jun 2018
    @description    Subclass for Bill Event
    *******************************************************************************/
    private class BlIn_BillEventObj {

        private Id BillEventId;
        private String EventType;
        private String Status;

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           06 Jun 2018
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          BillEvent__c - bill event record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillEventObj(BlIn_BillCalcDataContainer container, BillEvent__c billEvent) {
            
            // add the bill event fields to this DTO
            BillEventId = billEvent.Id;
            EventType = billEvent.EventType__c;
            Status = billEvent.Status__c;
        }
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           06 Nov 2017
    @description    Subclass for Contract Group
    *******************************************************************************/
    public class BlIn_BillCalcContractGroupObj {
        
        private Id ContractGroupId;
        private Id ContractGroupCustomerId;
        private String ContractGroupCustomerName;

        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           06 Nov 2017
        @param          BillCalculation__c - bill calculation record
        @description    Constructor
        *******************************************************************************/
        public BlIn_BillCalcContractGroupObj(BillCalculation__c billCalculation) {
            
            // add the contract group fields to this DTO
            ContractGroupId = billCalculation.ContractGroup__c;
            ContractGroupCustomerId = billCalculation.ContractGroup__r.Account__c;
            ContractGroupCustomerName = billCalculation.ContractGroup__r.Account__r.Name;            
        }
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           29 Aug 2017
    @description    Subclass for Contract
    *******************************************************************************/
    public class BlIn_BillCalcContractObj {
        
        private Id ContractId;
        private String BillingMethod;
        private String BillingFrequency;
        private String CustomerName;
        private Id CustomerId;
        private String LastBillCalculationDate;
        private String ContractEndDate;
        private String ContractStartDate;
        private Boolean HoldEntireBillForToleranceFail; // UL-21, Ankit, 21/02/2019        
        private Boolean Suppressed;  //AT-3297
        private Boolean CustomerSuppressed; //AT-2102, Ankit, 15/04/2019
        private Boolean BudgetPlanHold ; //AT-4574
        private BlIn_BillEventObj BillEvent;
        private String OwnedBy; //AT-5084, Ankit, 23/01/2018
        private List<BlIn_BillCalcTaxClassificationObj> TaxClassifications;
        private List<BlIn_BillCalcDiscountObj> Discounts;
        private List<BlIn_BillCalcServiceObj> Services;
        private List<BlIn_BillCalcManualAmendmentObj> ManualAmendments;
        private List<BlIn_BillCalcSuppressionObj> Suppression;   //AT-3297

        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           29 Aug 2017
        @param          BlIn_BillCalcDataContainer - container class instance
        @param          BillingContract__c - contract record
        @description    Constructor
        *******************************************************************************/
        public BlIn_BillCalcContractObj(BlIn_BillCalcDataContainer container, BillingContract__c contract) {
            
            // add the contract fields to this DTO
            ContractId = contract.Id;
            BillingMethod = contract.BillingMethod__c;
            BillingFrequency = contract.BillingFrequency__c;
            CustomerName = contract.AccountName__r.Name;            
            CustomerSuppressed = contract.AccountName__r.Suppressed__c; //AT-2102, Ankit, 15/04/2019
            CustomerId = contract.AccountName__c;
            OwnedBy = contract.OwnedBy__c; //AT-5084, Ankit, 23/01/2018
            ContractStartDate = dateToString(contract.ContractStartDate__c);
            ContractEndDate = dateToString(contract.ContractEndDate__c);
            HoldEntireBillForToleranceFail = contract.HoldEntireBillforToleranceFail__c; // UL-21, Ankit, 21/02/2019
            LastBillCalculationDate = dateToString(contract.LastBillCalculationDate__c);
            Suppressed = contract.Suppressed__c;  //AT-3297
            BudgetPlanHold = contract.BudgetPlanHold__c ; //AT-4574
            //need to add field for ownedBy
            // build the (pending) bill event DTO
            for (BillEvent__c thisBillEvent : contract.BillEvents__r) {
                BillEvent = new BlIn_BillEventObj(container, thisBillEvent);
                break;      // one only
            }
            
            // build the list of tax classification DTOs
            TaxClassifications = new List<BlIn_BillCalcTaxClassificationObj>();
            for (TaxClassification__c taxClassification : container.taxClassifications) {
                if (taxClassification.Account__c == contract.AccountName__c) {
                    TaxClassifications.add(new BlIn_BillCalcTaxClassificationObj(container, taxClassification));
                }
            }
            
            // build the list of discount DTOs
            Discounts = new List<BlIn_BillCalcDiscountObj>();
            for (Discount__c discount : container.discounts) {
                if (discount.BillingContract__c == contract.Id) {
                    Discounts.add(new BlIn_BillCalcDiscountObj(container, discount));
                }
            }
         
            // build the list of service DTOs
            Services = new List<BlIn_BillCalcServiceObj>();
            for (Service__c service : container.services) {
                if (service.BillingContract__c == contract.Id) {
                    Services.add(new BlIn_BillCalcServiceObj(container, service));
                }
            }
                         
            // build the list of manual amendment DTOs
            ManualAmendments = new List<BlIn_BillCalcManualAmendmentObj>();
            for (ManualAmendment__c manualAmendment : container.manualAmendments) {
                if (manualAmendment.AmendedBillItem__r.BillServiceType__r.Bill__r.BillingContract__c == contract.Id) {
                    ManualAmendments.add(new BlIn_BillCalcManualAmendmentObj(container, manualAmendment));
                }
            }
            
            System.debug('01 contract = '+contract);
            System.debug('02 container.suppression = '+container.suppression);
            //   AT-3297  build the list of Suppression Details                
            Suppression = new List<BlIn_BillCalcSuppressionObj>();
            for (Suppression__c suppressionObj : container.suppression) {
                if (suppressionObj.BillingContract__c == contract.Id) {
                    Suppression.add(new BlIn_BillCalcSuppressionObj(container, suppressionObj));
                }else if(suppressionObj.Account__c != null && suppressionObj.Account__c == contract.AccountName__c){ //AT-2102, Ankit, 15/04/2019
                    Suppression.add(new BlIn_BillCalcSuppressionObj(container, suppressionObj));
                }
            }
            // AT-3297 Ends
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           16 Mar 2018
    @description    Subclass for Discount (without amended child records)
    *******************************************************************************/
    private virtual class BlIn_BillCalcAmendedDiscountObj {

        private Id DiscountId;
        private Id DiscountTypeId;
        private String StartDate;
        private String EndDate;
        private String Status;
        private Decimal BaseDiscountAmount;
        private Decimal BaseDiscountPercentage;
        private Decimal OverriddenDiscountAmount;
        private Decimal OverriddenDiscountPercentage;
        private Boolean Invalid; //AT-3322
        private String  CreatedDate;//AT-3839
        private Decimal OverriddenDailyDiscountAmount;  //AT-4413
        private Decimal BaseDailyDiscountAmount;  //AT-4413
        private Id ConcessionId; // SIT005, Ankit, 05/04/2019
        

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           16 Mar 2018
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          Discount__c - discount record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcAmendedDiscountObj(BlIn_BillCalcDataContainer container, Discount__c discount) {
            
            // add the discount fields to this DTO
            DiscountId = discount.Id;
            DiscountTypeId = discount.DiscountType__c;
            StartDate = dateToString(discount.StartDate__c);
            EndDate = dateToString(discount.EndDate__c);
            Status = discount.Status__c;
            BaseDiscountAmount = discount.BaseDiscountAmount__c;
            BaseDiscountPercentage = discount.BaseDiscountPercentage__c;
            OverriddenDiscountAmount = discount.OverriddenDiscountAmount__c;
            OverriddenDiscountPercentage = discount.OverriddenDiscountPercentage__c;
            Invalid = discount.Invalid__c; //AT-3322
            CreatedDate = dateToString(discount.CreatedDate);//AT-3839
            OverriddenDailyDiscountAmount = discount.OverriddenDailyDiscountAmount__c; //AT-4413
            BaseDailyDiscountAmount = discount.BaseDailyDiscountAmount__c; //AT-4413
            ConcessionId = discount.Concession__c; // SIT005, Ankit, 05/04/2019
        }
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           16 Mar 2018
    @description    Subclass for Discount (extends base class DTO to include child amended records)
    *******************************************************************************/
    private class BlIn_BillCalcDiscountObj extends BlIn_BillCalcAmendedDiscountObj {

        private List<BlIn_BillCalcAmendedDiscountObj> AmendedDiscounts;

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           16 Mar 2018
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          Discount__c - discount record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcDiscountObj(BlIn_BillCalcDataContainer container, Discount__c discount) {
            
            super(container, discount);
            
            // build the list of amended discount DTOs
            AmendedDiscounts = new List<BlIn_BillCalcAmendedDiscountObj>();  
            for (Discount__c amendedDiscount : discount.AmendedDiscounts__r) {
                AmendedDiscounts.add(new BlIn_BillCalcAmendedDiscountObj(container, amendedDiscount));
            }
        }
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           29 Aug 2017
    @description    Subclass for Service
    *******************************************************************************/
    private class BlIn_BillCalcServiceObj {
        
        private Id ServiceId;
        private Id ServiceTypeId;
        private String OccupancyType; //AT-3517
        private decimal VolumePercentage;   //VS AT-3147
        private BlIn_BillCalcSupplyPointObj SupplyPoint;
        private List<BlIn_BillCalcServiceItemObj> ServiceItems;
        private Id AvailableServiceId; //AT-3725
        private BlIn_BillCalcSiteSupplyObj SiteSupply ; //AT-3489/AT-5108
   
        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           29 Aug 2017
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          Service__c - service record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcServiceObj(BlIn_BillCalcDataContainer container, Service__c service) {

            // add the service fields to this DTO
            ServiceId = service.Id;
            ServiceTypeId = service.ServiceType__c;
            VolumePercentage = service.VolumePercentage__c;   //VS AT-3147
            OccupancyType = service.OccupancyType__c;   //AT-3517
            AvailableServiceId = service.AvailableService__c; //AT-3725
            
            // build the Supply Point & Site Supply DTOs
            // START: AT-3489/AT-5108
            system.debug('DTO-service=> ' + service);
            system.debug('DTO-container.supplyPoints=> ' + container.supplyPoints);
            system.debug('DTO-container.mapCustomerSupplyPointId2SiteSupplyPointObj=> ' + container.mapCustomerSupplyPointId2SiteSupplyPointObj);
            for (SupplyPoint__c thisSupplyPoint : container.supplyPoints) {
                system.debug('DTO-thisSupplyPoint.SupplyPointDevices__r=> ' + thisSupplyPoint.SupplyPointDevices__r);
                //Select only those supply points where Device exists; not where the Customer Location exists
                if(thisSupplyPoint.Id == service.SupplyPoint__c) {
                    if(thisSupplyPoint.SupplyPointDevices__r != null && !thisSupplyPoint.SupplyPointDevices__r.isEmpty()) {     //General use case - Supply Point with Device
                        SupplyPoint = new BlIn_BillCalcSupplyPointObj(container, service.ServiceType__c, thisSupplyPoint) ; 
                    } else if(container.mapCustomerSupplyPointId2SiteSupplyPointObj.containsKey(service.SupplyPoint__c)) {  //Site Supply's Main Supply Point use case
                        SupplyPoint = new BlIn_BillCalcSupplyPointObj(container, service.ServiceType__c, container.mapCustomerSupplyPointId2SiteSupplyPointObj.get(service.SupplyPoint__c));         
                    }
                    break;      // one only 
                }
            } 
            for (SupplyPoint__c thisSupplyPoint : container.supplyPoints) {
                system.debug('DTO-thisSupplyPoint.SiteSupplies1__r=> ' + thisSupplyPoint.SiteSupplies1__r);                                                
                // build the Site Supply DTO
                if(thisSupplyPoint.SiteSupplies1__r != null && thisSupplyPoint.SiteSupplies1__r != null && !thisSupplyPoint.SiteSupplies1__r.isEmpty()) { 
                    for(SiteSupply__c thisSiteSupply : thisSupplyPoint.SiteSupplies1__r) {
                        if(thisSiteSupply.SupplyPoint__c == service.SupplyPoint__c) {
                            if((thisSiteSupply.Invalid__c || thisSiteSupply.Ended__c)) { 
                                SiteSupply = new BlIn_BillCalcSiteSupplyObj(container, thisSiteSupply) ; 
                                break;      // one only 
                            } else if(!thisSiteSupply.Invalid__c && !thisSiteSupply.Ended__c && container.mapAmendedSiteSupply.containsKey(thisSiteSupply.Id) && container.mapAmendedSiteSupply.get(thisSiteSupply.Id) != null && thisSiteSupply.SupplyPoint__c == service.SupplyPoint__c) {
                                SiteSupply = new BlIn_BillCalcSiteSupplyObj(container, thisSiteSupply) ; 
                                break;      // one only 
                            }
                        }
                    }
                }
            }
            // END: AT-3489/AT-5108
                                                                                          
            // build the list of related service item DTOs
            ServiceItems = new List<BlIn_BillCalcServiceItemObj>();
            for (ServiceItem__c serviceItem : container.serviceItems) {
                if (serviceitem.Service__c == service.Id) {
                    ServiceItems.add(new BlIn_BillCalcServiceItemObj(container, serviceItem));
                }
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           06 Feb 2019
    @description    AT-3489/AT-5108: Subclass for Site Supply
    *******************************************************************************/
    
    private class BlIn_BillCalcSiteSupplyObj extends BlIn_BillCalcSiteSupplyAmendedObj {
        private list<BlIn_BillCalcSiteSupplyAmendedObj> AmendedSiteSupply ;
        private BlIn_BillCalcSiteSupplyObj(BlIn_BillCalcDataContainer container, SiteSupply__c siteSupply) {
            super(container, siteSupply) ;  //main Site Supply
            system.debug('container.mapAmendedSiteSupply=> ' + container.mapAmendedSiteSupply);
            system.debug('siteSupply=> ' + siteSupply);
            AmendedSiteSupply = new list<BlIn_BillCalcSiteSupplyAmendedObj>() ; //Amended Site Supply
            if(container.mapAmendedSiteSupply.containsKey(siteSupply.Id) && container.mapAmendedSiteSupply.get(siteSupply.Id) != null) {
                SiteSupply__c objSiteSupply = container.mapAmendedSiteSupply.get(siteSupply.Id) ;
                if(!siteSupply.Invalid__c && !siteSupply.Ended__c && objSiteSupply.AmendedBySiteSupply__c != null) {    //AmendedSiteSupply should be sent only when it's not invalid & ended
                    AmendedSiteSupply.add(new BlIn_BillCalcSiteSupplyAmendedObj(container, objSiteSupply)) ;
                }
            }
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           06 Feb 2019
    @description    AT-3489/AT-5108: Subclass for Site Supply
    *******************************************************************************/
    private virtual class BlIn_BillCalcSiteSupplyAmendedObj {
        private String SiteSupplyId ;
        private String PercentageSplit ;
        private String StartDate ;
        private String EndDate ;
        private Boolean Ended ;
        private String SiteSupplyPointId ;
        private String SupplyPointId ;
        private Boolean Invalid ;
        private BlIn_BillCalcSiteSupplyAmendedObj(BlIn_BillCalcDataContainer container, SiteSupply__c siteSupply) {
            SiteSupplyId        = siteSupply.Id ;
            PercentageSplit     = decimalToString(siteSupply.PercentageSplit__c) ;
            StartDate           = dateToString(siteSupply.StartDate__c) ;
            EndDate             = dateToString(siteSupply.EndDate__c) ;
            SiteSupplyPointId    = siteSupply.SiteSupplyPoint__c ;
            SupplyPointId       = siteSupply.SupplyPoint__c ;
            Invalid             = siteSupply.Invalid__c ;
            Ended               = siteSupply.Ended__c ;
        }
    }
    
    /******************************************************************************
    @author         Echo: Vivek Sethi  //AT-3297
    @date           06 Aug 2018
    @description    Subclass for Suppression Object
    *******************************************************************************/
    private class BlIn_BillCalcSuppressionObj {
        
        private Id SuppressionId;
        private String SuppressionName;
        private Boolean SuppressBillPrint;
        private String CreatedDate;
     
        /******************************************************************************
        @author         Echo: Vivek Sethi  //AT-3297
        @date           06 Aug 2018
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          Suppression__c - Suppression record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcSuppressionObj(BlIn_BillCalcDataContainer container, Suppression__c suppression) {
            // add the service fields to this DTO
            SuppressionId = suppression.Id;
            SuppressionName = suppression.Name;
            SuppressBillPrint = suppression.SuppressBillPrint__c;
            CreatedDate = dateToString(suppression.createdDate);
        }
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           29 Aug 2017
    @description    Subclass for Service Item (without amended child records)
    *******************************************************************************/
    private virtual class BlIn_BillCalcAmendedServiceItemObj {

        private Id ServiceItemId;
        private Id ServiceItemTypeId;
        private String StartDate;
        private String EndDate;
        private Decimal Quantity;
        private Boolean Invalid; //AT-3322
        private Boolean Ended; //AT-3898
        private String CreatedDate; //AT-3322
        private Decimal DischargeFactor; //AT-4991, Ankit, 18/01/2018
        private List<BlIn_BillCalcServItmAgreedRateObj> ServiceItemAgreedRates;
        private List<BlIn_BillCalcServiceItemGroupItemObj> ServiceItemGroupItems;
        //Start of AT - 2755
        private List<BlIn_BillCalcServiceItemAgreedVolumeObj> SIAgreedVolumes;
        private List<BlIn_BillCalcSupplyPointAllowanceObj> SupplyPointAllowances;
        //End of AT - 2755
        private List<BlIn_BillCalcDischargeAgmtObj> DischargeAgreements;  //AT-3147

        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           29 Aug 2017
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          ServiceItem__c - serviceItem record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcAmendedServiceItemObj(BlIn_BillCalcDataContainer container, ServiceItem__c serviceItem) {

            // add the service item fields to this DTO
            system.debug('container====='+container);
            ServiceItemId = serviceItem.Id;
            ServiceItemTypeId = serviceItem.ServiceItemType__c;
            StartDate = dateToString(serviceItem.StartDate__c);
            EndDate = dateToString(serviceItem.EndDate__c);
            Quantity = serviceItem.Quantity__c;
            Invalid = serviceItem.Invalid__c; //AT-3322
            Ended = serviceItem.Ended__c; //AT-3898
            CreatedDate = dateToString(serviceItem.CreatedDate); //AT-3322
            DischargeFactor = serviceItem.DischargeFactor__c; //AT-4991, Ankit, 18/01/2018
            // build the list of related agreed rate DTOs
            ServiceItemAgreedRates = new List<BlIn_BillCalcServItmAgreedRateObj>();
            for (AgreedRate__c agreedRate : container.agreedRates) {
                if (agreedRate.ServiceItem__c == serviceItem.Id) {
                    ServiceItemAgreedRates.add(new BlIn_BillCalcServItmAgreedRateObj(container, agreedRate));
                }
            }
            // build the list of related group item DTOs
            ServiceItemGroupItems = new List<BlIn_BillCalcServiceItemGroupItemObj>();
            for (GroupItem__c groupItem : container.groupItems) { 
                if (groupItem.ServiceItem__c == serviceItem.Id) {
                    ServiceItemGroupItems.add(new BlIn_BillCalcServiceItemGroupItemObj(container, groupItem));
                }
            }
            
            //Start of AT - 2755
            SIAgreedVolumes = new List<BlIn_BillCalcServiceItemAgreedVolumeObj>();
            for(SIAgreedVolume__c serviceItemAgreedVolume : container.serviceItemAgreedVolumes){
                if(serviceItemAgreedVolume.ServiceItem__c == serviceItem.Id){
                   SIAgreedVolumes.add(new BlIn_BillCalcServiceItemAgreedVolumeObj(container, serviceItemAgreedVolume));
                }
            }
            
            SupplyPointAllowances = new List<BlIn_BillCalcSupplyPointAllowanceObj>();
            for(SupplyPointAllowance__c supplyPointAllowance : container.supplyPointAllowances){
                if (serviceItem.Id == supplyPointAllowance.ServiceItem__c) {
                    SupplyPointAllowances.add(new BlIn_BillCalcSupplyPointAllowanceObj(container, supplyPointAllowance));
                }
            }
            //End of AT - 2755
            
            /*Discharge Agreement   AT-3147*/
            DischargeAgreements = new List<BlIn_BillCalcDischargeAgmtObj>();    
            for (DischargeAgreement__c dischargeAgreement : container.dischargeAgreements) {
                if (serviceItem.DischargeAgreement__c == dischargeAgreement.Id) {
                    DischargeAgreements.add(new BlIn_BillCalcDischargeAgmtObj(container, dischargeAgreement));
                }
            }
            /*End of AT-3147 */
            
        }
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           29 Aug 2017
    @description    Subclass for Service Item (extends base class DTO to include child amended records)
    *******************************************************************************/
    private class BlIn_BillCalcServiceItemObj extends BlIn_BillCalcAmendedServiceItemObj {

        private List<BlIn_BillCalcAmendedServiceItemObj> AmendedServiceItems;

        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           29 Aug 2017
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          ServiceItem__c - serviceItem record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcServiceItemObj(BlIn_BillCalcDataContainer container, ServiceItem__c serviceItem) {
            
            super(container, serviceItem);
            
            // build the list of amended service item DTOs
            AmendedServiceItems = new List<BlIn_BillCalcAmendedServiceItemObj>();  
            for (ServiceItem__c amendedServiceItem : serviceItem.AmendedServiceItems__r) {
                AmendedServiceItems.add(new BlIn_BillCalcAmendedServiceItemObj(container, amendedServiceItem));
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           21 June 2018
    @description    AT - 2755 Subclass for Service Item Agreed Volume (without amended child records)
    *******************************************************************************/
    private virtual class BlIn_BillCalcAmendedServiceItemAgreedVolumeObj {

        private Id SIAgreedVolumeId;
        private String StartDate;
        private String EndDate;
        private Decimal Volume;
        private String CreatedDate;
        private Boolean Invalid; //AT-3322

        /******************************************************************************
        @author         ECHO: Mohit Tayal
        @date           21 June 2018
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          SIAgreedVolume__c - serviceItemAgreedVolume record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcAmendedServiceItemAgreedVolumeObj(BlIn_BillCalcDataContainer container, SIAgreedVolume__c serviceItemAgreedVolume) { 
             
            // add the Service Item Agreed Volume fields to this DTO
            SIAgreedVolumeId = serviceItemAgreedVolume.Id;
            StartDate = dateToString(serviceItemAgreedVolume.StartDate__c);
            EndDate = dateToString(serviceItemAgreedVolume.EndDate__c);
            Volume = serviceItemAgreedVolume.Volume__c;
            Invalid = serviceItemAgreedVolume.Invalid__c;
            CreatedDate = dateToString(serviceItemAgreedVolume.CreatedDate);
        }
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           21 June 2018
    @description    AT - 2755 Subclass for Service Item Agreed Volume
    *******************************************************************************/
    private class BlIn_BillCalcServiceItemAgreedVolumeObj extends BlIn_BillCalcAmendedServiceItemAgreedVolumeObj{

        private List<BlIn_BillCalcAmendedServiceItemAgreedVolumeObj> AmendedSIAgreedVolumes;
        
        /******************************************************************************
        @author         Echo: Mohit Tayal
        @date           21 June 2018
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          SIAgreedVolume__c - serviceItemAgreedVolume record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcServiceItemAgreedVolumeObj(BlIn_BillCalcDataContainer container, SIAgreedVolume__c serviceItemAgreedVolume) { 
             super(container, serviceItemAgreedVolume);
            
            // build the list of amended service item agreed Volume
            AmendedSIAgreedVolumes = new List<BlIn_BillCalcAmendedServiceItemAgreedVolumeObj>();  
            for (SIAgreedVolume__c amendedServiceItemAgreedVolume : serviceItemAgreedVolume.SIAgreedVolume__r) {
                AmendedSIAgreedVolumes.add(new BlIn_BillCalcAmendedServiceItemAgreedVolumeObj(container, amendedServiceItemAgreedVolume));
            }
        }
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           26 Oct 2017
    @description    Subclass for Group Item
    *******************************************************************************/
    private class BlIn_BillCalcServiceItemGroupItemObj {

        private String GroupItemId;
        private String GroupId;

        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           26 Oct 2017
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          GroupItem__c - groupItem record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcServiceItemGroupItemObj(BlIn_BillCalcDataContainer container, GroupItem__c groupItem) { 
             
            // add the group item fields to this DTO
            GroupItemId = groupItem.Id;
            GroupId = groupItem.Group__c;
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 Jan 2018
    @description    Subclass for (Discharge) SupplyPoint
    *******************************************************************************/
    private virtual class BlIn_BillCalcDischargeSupplyPoint {

        private Id SupplyPointId;
        private String SupplyPointName;
        private String RuralOutletBillingType; //AT-4485
        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           23 Jan 2018
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          SupplyPoint__c - supplyPoint record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcDischargeSupplyPoint(BlIn_BillCalcDataContainer container, SupplyPoint__c supplyPoint) {
            
            // add the supplyPoint fields to this DTO
            SupplyPointId = supplyPoint.Id;
            SupplyPointName = supplyPoint.Name;
            RuralOutletBillingType =  supplyPoint.RuralOutletBillingType__c; //AT-4485

        }
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           25 Oct 2017
    @description    Subclass for SupplyPoint
    *******************************************************************************/
    private class BlIn_BillCalcSupplyPointObj extends BlIn_BillCalcDischargeSupplyPoint {
        
        private List<BlIn_BillCalcAvailableServiceObj> AvailableServices;
        private List<BlIn_BillCalcSupplyPointDeviceObj> SupplyPointDevices;
        private List<BlIn_BillCalcRuralGrossConsumptionObj> RuralGrossConsumptions;
        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           25 Oct 2017
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          Id - service type Id
        @param          SupplyPoint__c - supplyPoint record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcSupplyPointObj(BlIn_BillCalcDataContainer container, Id serviceType, SupplyPoint__c supplyPoint) {
            
            super(container, supplyPoint);
            // build the list of available service DTOs
            AvailableServices = new List<BlIn_BillCalcAvailableServiceObj>();
             
            for (AvailableService__c thisAvailableService : container.availableServices) {
                if (thisAvailableService.SupplyPoint__c == supplyPoint.Id) {
                    AvailableServices.add(new BlIn_BillCalcAvailableServiceObj(container, thisAvailableService));
                }
            }
         
            // build the list of supply point device DTOs
            SupplyPointDevices = new List<BlIn_BillCalcSupplyPointDeviceObj>();
            system.debug('container.serviceTypeMap=> ' + container.serviceTypeMap);
            system.debug('serviceType=> ' + serviceType);
            system.debug('supplyPoint.supplyPointDevices__r=> ' + supplyPoint.supplyPointDevices__r);
            for (SupplyPointDevice__c supplyPointDevice : supplyPoint.supplyPointDevices__r) {
                system.debug('supplyPointDevice=> ' + supplyPointDevice);
                system.debug('container.serviceTypeMap.get(supplyPointDevice.Id)=> ' + container.serviceTypeMap.get(supplyPointDevice.Id));
                if (container.serviceTypeMap.containsKey(supplyPointDevice.Id) && container.serviceTypeMap.get(supplyPointDevice.Id).contains(serviceType))    {    //AT-3147  
                    SupplyPointDevices.add(new BlIn_BillCalcSupplyPointDeviceObj(container, supplyPointDevice));
                }
            }
            // build the list of Rural Gross Consumption DTOs
            // AT-4485 Starts Here Rural Billing
            RuralGrossConsumptions = new List<BlIn_BillCalcRuralGrossConsumptionObj>();
            for (RuralGrossConsumption__c thisRuralGrossConsumption : supplyPoint.RuralGrossConsumptions__r) {
                if (thisRuralGrossConsumption.SupplyPoint__c == supplyPoint.Id)    {  
                    RuralGrossConsumptions.add(new BlIn_BillCalcRuralGrossConsumptionObj(container, thisRuralGrossConsumption));
                }
            }
            // AT-4485 Ends Here Rural Billing
        }
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           13 Dec 2018(AT-4485)
    @description    Subclass for Amended Rural Gross Consumption
    *******************************************************************************/
    private virtual class BlIn_BillCalcAmendedRuralGrossConsumptionObj {
        private Id RuralGrossConsumptionId;
        private String StartDate;
        private String EndDate;
        private String CreatedDate;
        private Id Reading;
        private String Type;
        private Boolean Invalid;
        private Decimal Consumption;
        private Boolean Billed;
        private Id ChannelOpen;
        private Id RuralMeasurement;
        private Id RuralEntitlement;
        /******************************************************************************
        @author         Echo: Amit K.
        @date           13 Dec 2018(AT-4485)
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          RuralGrossConsumption__c - Rural Gross Consumption record
        @description    Constructor
        *******************************************************************************/
            private BlIn_BillCalcAmendedRuralGrossConsumptionObj(BlIn_BillCalcDataContainer container, RuralGrossConsumption__c ruralGrossConsumption) {
                
                RuralGrossConsumptionId = ruralGrossConsumption.Id;
                StartDate = dateToString(ruralGrossConsumption.StartDate__c);
                EndDate = dateToString(ruralGrossConsumption.EndDate__c);
                CreatedDate = dateToString(ruralGrossConsumption.CreatedDate);
                Reading = ruralGrossConsumption.Reading__c;
                Type = ruralGrossConsumption.Type__c;
                Invalid = ruralGrossConsumption.Invalid__c;
                Consumption = ruralGrossConsumption.Consumption__c;
                Billed = ruralGrossConsumption.Billed__c;
                ChannelOpen = ruralGrossConsumption.ChannelOpen__c;
                RuralMeasurement = ruralGrossConsumption.RuralMeasurement__c;
                RuralEntitlement = ruralGrossConsumption.RuralEntitlement__c;
            }
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           13 Dec 2018(AT-4485)
    @description    Class for Rural Gross Consumption.
    *******************************************************************************/
    private class BlIn_BillCalcRuralGrossConsumptionObj extends BlIn_BillCalcAmendedRuralGrossConsumptionObj{
        private List<BlIn_BillCalcAmendedRuralGrossConsumptionObj> AmendedRuralGrossConsumptions;
        /******************************************************************************
        @author         Echo: Amit K.
        @date           13 Dec 2018(AT-4485)
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          RuralGrossConsumption__c - Rural Gross Consumption record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcRuralGrossConsumptionObj(BlIn_BillCalcDataContainer container, RuralGrossConsumption__c ruralGrossConsumption){
            super(container,ruralGrossConsumption);
            //add the Amended Rural Gross Consumption fields to this DTO
            AmendedRuralGrossConsumptions = new List<BlIn_BillCalcAmendedRuralGrossConsumptionObj>();
            if(!container.mapOfRuralGrossConsumption2AmendedRuralGrossConsumptions.isEmpty() && container.mapOfRuralGrossConsumption2AmendedRuralGrossConsumptions.get(ruralGrossConsumption.Id) != null){
                for(RuralGrossConsumption__c amendedRuralGrossConsumption : container.mapOfRuralGrossConsumption2AmendedRuralGrossConsumptions.get(ruralGrossConsumption.Id)){
                    AmendedRuralGrossConsumptions.add(new BlIn_BillCalcAmendedRuralGrossConsumptionObj(container, amendedRuralGrossConsumption));
                }
            }
        }
    }
    
    /******************************************************************************
    @author         ECHO: Mohit Tayal
    @date           21 June 2018
    @description    AT - 2755 Subclass for Supply Point Allowance (without amended child records)
    *******************************************************************************/
    private virtual class BlIn_BillCalcAmendedSupplyPointAllowanceObj { 
        
        private Id SupplyPointAllowanceId;
        private Id SupplyPointId;
        private Id AllowanceTypeId;
        private String AllowancePriority;
        private Decimal AllowanceAmount;
        private String StartDate;
        private String EndDate;
        private String Type;
        private String CreatedDate;
        private Boolean Invalid; //AT-3322

        /******************************************************************************
        @author         ECHO: Mohit Tayal
        @date           21 June 2018
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          SupplyPointAllowance__c - Supply Point Allowance record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcAmendedSupplyPointAllowanceObj(BlIn_BillCalcDataContainer container, SupplyPointAllowance__c SupplyPointAllowance) {
            
            // add the service fields to this DTO
            SupplyPointAllowanceId = SupplyPointAllowance.Id;
            SupplyPointId = SupplyPointAllowance.SupplyPoint__c;
            AllowanceTypeId = SupplyPointAllowance.AllowanceType__c;
            AllowancePriority = SupplyPointAllowance.AllowancePriority__c;
            AllowanceAmount = SupplyPointAllowance.AllowanceAmount__c;
            StartDate = dateToString(SupplyPointAllowance.StartDate__c);
            EndDate = dateToString(SupplyPointAllowance.EndDate__c);
            Type = SupplyPointAllowance.Type__c;
            CreatedDate = dateToString(SupplyPointAllowance.CreatedDate);
            Invalid = SupplyPointAllowance.Invalid__c; //AT-3322
        }
    }
    
    /******************************************************************************
    @author         ECHO: Mohit Tayal
    @date           21 June 2018
    @description    AT - 2755 Subclass for SupplyPointAllowance
    *******************************************************************************/
    private class BlIn_BillCalcSupplyPointAllowanceObj extends BlIn_BillCalcAmendedSupplyPointAllowanceObj{ 
        
        private List<BlIn_BillCalcAmendedSupplyPointAllowanceObj> AmendedSupplyPointAllowances;

        /******************************************************************************
        @author         ECHO: Mohit Tayal
        @date           21 June 2018
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          SupplyPointAllowance__c - Supply Point Allowance record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcSupplyPointAllowanceObj(BlIn_BillCalcDataContainer container, SupplyPointAllowance__c SupplyPointAllowance) {
            super(container,SupplyPointAllowance);
            // add the service fields to this DTO
            AmendedSupplyPointAllowances = new List<BlIn_BillCalcAmendedSupplyPointAllowanceObj>();
            for(SupplyPointAllowance__c amendedSupplyPointAllowance : SupplyPointAllowance.SupplyPointAllowance__r){
                AmendedSupplyPointAllowances.add(new BlIn_BillCalcAmendedSupplyPointAllowanceObj(container, amendedSupplyPointAllowance));
            }
        }
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           26 Oct 2017
    @description    Subclass for Available Service
    *******************************************************************************/
    private class BlIn_BillCalcAvailableServiceObj { 
        
        private Id AvailableServiceId;
        private Id ServiceTypeId;
        private List<BlIn_BillCalcServCrgBasisObj> ServiceChargeBases;

        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           26 Oct 2017
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          AvailableService__c - available service record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcAvailableServiceObj(BlIn_BillCalcDataContainer container, AvailableService__c availableService) {
            
            // add the service fields to this DTO
            AvailableServiceId = availableService.Id;
            ServiceTypeId = availableService.ServiceType__c;
            
            // build the list of charge basis DTOs
            ServiceChargeBases = new List<BlIn_BillCalcServCrgBasisObj>();
            for (ChargeBasis__c chargeBasis : container.chargeBases) {          

                if (chargeBasis.AvailableService__c == availableService.Id) {
                    ServiceChargeBases.add(new BlIn_BillCalcServCrgBasisObj(container, chargeBasis));
                }
            }
        }
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           25 Oct 2017
    @description    Subclass for SupplyPointDevice
    *******************************************************************************/
    private class BlIn_BillCalcSupplyPointDeviceObj {
        
        private Id SupplyPointDeviceId;
        private String SupplyPointDeviceName;
        private Boolean TEDevice;
        private String RemovalDate;
        private Boolean Ended;
        private Boolean Active;
        private BlIn_BillCalcServDeviceObj ServiceDevice;
        private List<BlIn_BillCalcAverageDailyUseObj> AverageDailyUse;

        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           25 Oct 2017
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          SupplyPointDevice__c - supplyPointDevice record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcSupplyPointDeviceObj(BlIn_BillCalcDataContainer container, SupplyPointDevice__c supplyPointDevice) {
            
            // add the supplyPointDevice fields to this DTO
            SupplyPointDeviceId = supplyPointDevice.Id;
            SupplyPointDeviceName = supplyPointDevice.Name;
            TEDevice = supplyPointDevice.TEDevice__c;  
            RemovalDate = dateToString(supplyPointDevice.RemovalDate__c);
            Ended = supplyPointDevice.Ended__c;
            Active = supplyPointDevice.Active__c;
            
            // build the service device DTO
            for (Device__c device : container.devices) {
                if (supplyPointDevice.Device__c == device.Id) {
                    ServiceDevice = new BlIn_BillCalcServDeviceObj(container, device);
                    break;      // one only
                }
            }
            // build the list of average daily use DTOs
            AverageDailyUse = new List<BlIn_BillCalcAverageDailyUseObj>();
            for (AverageDailyUsage__c thisAverageDailyUse : container.averageDailyUses) {
                if (thisAverageDailyUse.SupplyPointDevice__c == supplyPointDevice.Id) {
                    AverageDailyUse.add(new BlIn_BillCalcAverageDailyUseObj(container, thisAverageDailyUse));
                }
            }
        }
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           25 Oct 2017
    @description    Subclass for AverageDailyUsage
    *******************************************************************************/
    private class BlIn_BillCalcAverageDailyUseObj {
        
        private Id AverageDailyUseId;
        private String StartDate;
        private String EndDate;
        private Decimal AverageDailyUsage;
        private Decimal RollingDailyUsage;  //AT-5070

        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           25 Oct 2017
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          AverageDailyUsage__c - averageDailyUse record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcAverageDailyUseObj(BlIn_BillCalcDataContainer container, AverageDailyUsage__c averageDailyUse) {
            
            // add the averageDailyUsage fields to this DTO
            AverageDailyUseId = averageDailyUse.Id;
            StartDate = dateToString(averageDailyUse.StartDate__c);
            EndDate = dateToString(averageDailyUse.EndDate__c);
            AverageDailyUsage = averageDailyUse.AverageDailyUsage__c;
            RollingDailyUsage =  averageDailyUse.RollingDailyUsage__c;  // AT-5070
        }  
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           29 Aug 2017
    @description    Subclass for Service Item Agreed Rate (without amended child records)
    *******************************************************************************/
    private virtual class BlIn_BillCalcServItmAmendedAgreedRateObj {

        private Id AgreedRateId;
        private String StartDate;
        private String EndDate;
        private Decimal Value;

        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           31 Aug 2017
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          AgreedRate__c - agreedRate record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcServItmAmendedAgreedRateObj(BlIn_BillCalcDataContainer container, AgreedRate__c agreedRate) {
            
            // add the agreed rate fields to this DTO
            AgreedRateId = agreedRate.Id;
            StartDate = dateToString(agreedRate.StartDate__c);
            EndDate = dateToString(agreedRate.EndDate__c);
            Value = agreedRate.Value__c;
        }
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           02 Nov 2017
    @description    Subclass for Service Item Agreed Rate (extends base class DTO to include child amended records)
    *******************************************************************************/
    private class BlIn_BillCalcServItmAgreedRateObj extends BlIn_BillCalcServItmAmendedAgreedRateObj {

        private List<BlIn_BillCalcServItmAmendedAgreedRateObj> AmendedAgreedRates;

        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           02 Nov 2017
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          AgreedRate__c - agreedRate record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcServItmAgreedRateObj(BlIn_BillCalcDataContainer container, AgreedRate__c agreedRate) {
            
            super(container, agreedRate);

            // build the list of amended agreed rate DTOs
            AmendedAgreedRates = new List<BlIn_BillCalcServItmAmendedAgreedRateObj>();  
            for (AgreedRate__c amendedAgreedRate : agreedRate.AmendedAgreedRates__r) {
                AmendedAgreedRates.add(new BlIn_BillCalcServItmAmendedAgreedRateObj(container, amendedAgreedRate));
            }
        }
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           29 Aug 2017
    @description    Subclass for Sub Device
    *******************************************************************************/
    private virtual class BlIn_BillCalcServSubDeviceObj {

        private Id ServiceDeviceId;
        private String ServiceDeviceName;
        private Decimal ServiceDeviceDigit;         //AT-3417 core 8b
        private List<BlIn_BillCalcServReadingObj> ServiceReadings;  

        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           31 Aug 2017
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          Device__c - device record (can be sub or main if the class is extended)
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcServSubDeviceObj(BlIn_BillCalcDataContainer container, Device__c device) {
            
            // add the sub device fields to this DTO
            ServiceDeviceId = device.Id;
            ServiceDeviceName = device.Name;
            ServiceDeviceDigit = device.Digit__c;           //AT-3417 core 8b

            // build the list of related readings DTOs
            ServiceReadings = new List<BlIn_BillCalcServReadingObj>();  
            system.debug('container.readings***'+ container.readings);
            for (Reading__c reading : container.readings) {
                if (reading.Device__c == device.Id) {//AT-3174
                    
                    if(reading.BillableType__c == Label.CuAp_ReadingBillableTypeBillable && !reading.AllServicesBilled__c)
                        ServiceReadings.add(new BlIn_BillCalcServReadingObj(container, reading));
                    else if(reading.BillableType__c == Label.CuAp_ReadingBillableTypeInvalid && 
                            (reading.ReadingType__c == Label.CuAp_ReadingReadingTypeMoveIn || reading.ReadingType__c == Label.CuAp_ReadingReadingTypeMoveOut)){
                        ServiceReadings.add(new BlIn_BillCalcServReadingObj(container, reading));
                    }
                }
            }
        }
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           29 Aug 2017
    @description    Subclass for Device (extends base class DTO to include child sub device records)
    *******************************************************************************/
    private class BlIn_BillCalcServDeviceObj extends BlIn_BillCalcServSubDeviceObj {

        private List<BlIn_BillCalcServSubDeviceObj> SubDevices;

        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           30 Aug 2017
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          Device__c - device record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcServDeviceObj(BlIn_BillCalcDataContainer container, Device__c device) {

            super(container, device);
            
            // build the list of related sub devices DTOs
            /*SubDevices = new List<BlIn_BillCalcServSubDeviceObj>();
            for (Device__c subDevice : container.subDevices) {
                for (DeviceRelationship__c relationship : device.DeviceRelationships__r) {
                    if (relationship.MainDevice__c == device.Id) {
                        SubDevices.add(new BlIn_BillCalcServSubDeviceObj(container, subDevice));
                    }
                }
            }*/ // Comment becuase AT-2926, sub device is not required anymore
        }
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           29 Aug 2017
    @description    Subclass for Amended Reading (without amended child records)
    *******************************************************************************/
    private virtual class BlIn_BillCalcServAmendedReadingObj {
        
        private Id ServiceReadingId;
        private Decimal Reading;
        private String ReadingDate;
        private String ReadingSource;
        private String ReadingMethod;
        private String ReadingType;        
        private String BillableType;
        private Boolean Billed;
        private Decimal EffectiveReading; // AT-2931...Core 7a
        private Boolean Leak; // AT-2931...Core 7a
        private String CreatedDate; //AT-3322
        private Boolean Tripped; //AT-3417 core 8b
        private Boolean AllServicesBilled; // AT-3851
        private Boolean CheckBillingTolerance; // UL-21, Ankit, 21/02/2019        
        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           30 Aug 2017
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          Reading__c - reading record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcServAmendedReadingObj(BlIn_BillCalcDataContainer container, Reading__c reading) {
            
            // add the reading fields to this DTO
            ServiceReadingId = reading.Id;
            this.Reading = reading.Reading__c;
            ReadingDate = dateToString(reading.ReadingDate__c);
            ReadingSource = reading.ReadingSource__c; 
            ReadingMethod = reading.ReadingMethod__c; 
            ReadingType = reading.ReadingType__c; 
            BillableType = reading.BillableType__c; 
            Billed = reading.Billed__c;            
            EffectiveReading = reading.EffectiveReading__c; // AT-2931...Core 7a
            Leak = reading.Leak__c; // AT-2931...Core 7a
            Tripped = reading.Tripped__c;  //AT-3417 Core8b
            CreatedDate = dateToString(reading.CreatedDate); //AT-3322
            AllServicesBilled = reading.AllServicesBilled__c; //AT-3851
            CheckBillingTolerance = reading.CheckServiceItemTolerance__c; // UL-21, Ankit, 21/02/2019
            //need to add field, ankit
        }
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           02 Nov 2017
    @description    Subclass for Reading (extends base class DTO to include child amended records)
    *******************************************************************************/
    private class BlIn_BillCalcServReadingObj extends BlIn_BillCalcServAmendedReadingObj {
        
        private List<BlIn_BillCalcServAmendedReadingObj> AmendedReadings;

        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           02 Nov 2017
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          Reading__c - reading record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcServReadingObj(BlIn_BillCalcDataContainer container, Reading__c reading) {
            
            super(container, reading);

            // build the list of amended readings DTOs
            AmendedReadings = new List<BlIn_BillCalcServAmendedReadingObj>();  
            for (Reading__c amendedReading : reading.AmendedReadings__r) {
                AmendedReadings.add(new BlIn_BillCalcServAmendedReadingObj(container, amendedReading));
            }
        }
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           29 Aug 2017
    @description    Subclass for Charging Basis (without amended child records)
    *******************************************************************************/
    private virtual class BlIn_BillCalcServAmendedCrgBasisObj {

        private Id ServiceChargeBasisId;
        private String StartDate;
        private String EndDate;
        private Decimal Amount;
        private Boolean Invalid; //AT-3322
        private String Type;

        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           31 Aug 2017
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          ChargeBasis__c - charge basis record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcServAmendedCrgBasisObj(BlIn_BillCalcDataContainer container, ChargeBasis__c chargeBasis) {
            
            // add the charge basis fields to this DTO
            ServiceChargeBasisId = chargeBasis.Id;
            StartDate = dateToString(chargeBasis.StartDate__c);
            EndDate = dateToString(chargeBasis.EndDate__c);
            Amount = chargeBasis.Amount__c;
            Invalid = chargeBasis.Invalid__c; //AT-3322
            Type = chargeBasis.Type__c; //UL-221
        }
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           02 Nov 2017
    @description    Subclass for Charging Basis (extends base class DTO to include child amended records)
    *******************************************************************************/
    private class BlIn_BillCalcServCrgBasisObj extends BlIn_BillCalcServAmendedCrgBasisObj {

        private List<BlIn_BillCalcServAmendedCrgBasisObj> AmendedChargeBases;

        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           02 Nov 
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          ChargeBasis__c - charge basis record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcServCrgBasisObj(BlIn_BillCalcDataContainer container, ChargeBasis__c chargeBasis) {
            
            super(container, chargeBasis);

            // build the list of amended charge basis DTOs
            AmendedChargeBases = new List<BlIn_BillCalcServAmendedCrgBasisObj>();  
            for (ChargeBasis__c amendedChargeBasis : chargeBasis.AmendedChargeBases__r) {
                AmendedChargeBases.add(new BlIn_BillCalcServAmendedCrgBasisObj(container, amendedChargeBasis));
            }
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 Jan 2018
    @description    Subclass for DischargeAgreement
    *******************************************************************************/
    private class BlIn_BillCalcDischargeAgmtObj {

        private Id DischargeAgreementId;
        private String StartDate;
        private String EndDate;
        private decimal MinNumberOfSamples;
        private decimal VolumePercentage;  //AT-3452
        private String TradeWasteType; //AT-4991, Ankit, 18/01/2018
        
        private List<BlIn_BillCalcAgreedVolumeObj> AgreedVolumes;
        private List<BlIn_BillCalcAgrdSmplStrengthObj> AgreedSampleStrengths;
     //   private List<BlIn_BillCalcDischargePointObj> DischargePoints;    //AT-3147 Commented
        private List<BlIn_BillCalcSamplesObj> Samples;   //AT-3147

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           23 Jan 2018
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          DischargeAgreement__c - dischargeAgreement record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcDischargeAgmtObj(BlIn_BillCalcDataContainer container, DischargeAgreement__c dischargeAgreement) {
            
            // add the discharge agreement fields to this DTO
            DischargeAgreementId = dischargeAgreement.Id;
            StartDate = dateToString(dischargeAgreement.StartDate__c);
            EndDate = dateToString(dischargeAgreement.EndDate__c);
            MinNumberOfSamples = dischargeAgreement.MinNumberofSamples__c;   //AT-3147
            VolumePercentage = dischargeAgreement.VolumePercentage__c;  //AT-3452
            TradeWasteType = dischargeAgreement.TradeWasteType__c; //AT-4991, Ankit, 18/01/2018
            // build the list of agreed volume DTOs
            AgreedVolumes = new List<BlIn_BillCalcAgreedVolumeObj>();  
            for (AgreedVolume__c agreedVolume : container.agreedVolumes) {
                if (agreedVolume.DischargeAgreement__c == dischargeAgreement.Id) {
                    AgreedVolumes.add(new BlIn_BillCalcAgreedVolumeObj(container, agreedVolume));
                }
            }
            
            // build the list of agreed sample strength DTOs
            AgreedSampleStrengths = new List<BlIn_BillCalcAgrdSmplStrengthObj>();  
            for (AgreedSampleStrength__c agreedSampleStrength : container.agreedSampleStrengths) {
                if (agreedSampleStrength.DischargeAgreement__c == dischargeAgreement.Id) {
                    AgreedSampleStrengths.add(new BlIn_BillCalcAgrdSmplStrengthObj(container, agreedSampleStrength));
                }
            }
            
            //VS AT-3147  Commented DischargePoints
            // build the list of discharge point DTOs*/
         /*  DischargePoints = new List<BlIn_BillCalcDischargePointObj>();  
            for (DischargePoint__c dischargePoint : container.dischargePoints) {
                if (dischargePoint.DischargeAgreement__c == dischargeAgreement.Id) {
                    DischargePoints.add(new BlIn_BillCalcDischargePointObj(container, dischargePoint));
                }
            }*/
            
            // AT-3147 
            Samples = new List<BlIn_BillCalcSamplesObj>();
            for (Sample__c sample : container.samples) {
                if (sample.DischargeAgreement__c == dischargeAgreement.Id) {
                    Samples.add(new BlIn_BillCalcSamplesObj(container, sample));
                }
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 Jan 2018
    @description    Subclass for AgreedVolume (without amended child records)
    *******************************************************************************/
    private virtual class BlIn_BillCalcAmendedAgreedVolumeObj {

        private Id AgreedVolumeId;
        private Decimal AgreedVolume;
        private String StartDate;
        private String EndDate;
        private Boolean Invalid; //AT-3322

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           23 Jan 2018
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          AgreedVolume__c - agreedVolume record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcAmendedAgreedVolumeObj(BlIn_BillCalcDataContainer container, AgreedVolume__c agreedVolume) {
            
            // add the agreed volume fields to this DTO
            AgreedVolumeId = agreedVolume.Id;
            this.AgreedVolume = agreedVolume.AgreedVolume__c;
            StartDate = dateToString(agreedVolume.StartDate__c);
            EndDate = dateToString(agreedVolume.EndDate__c);
            Invalid = agreedVolume.Invalid__c;  //AT-3322
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 Jan 2018
    @description    Subclass for AgreedVolume
    *******************************************************************************/
    private class BlIn_BillCalcAgreedVolumeObj extends BlIn_BillCalcAmendedAgreedVolumeObj {

        private List<BlIn_BillCalcAmendedAgreedVolumeObj> AmendedAgreedVolumes;

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           23 Jan 2018
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          AgreedVolume__c - agreedVolume record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcAgreedVolumeObj(BlIn_BillCalcDataContainer container, AgreedVolume__c agreedVolume) {
            
            super(container, agreedvolume);

            // build the list of amended agreed volume DTOs
            AmendedAgreedVolumes = new List<BlIn_BillCalcAmendedAgreedVolumeObj>();  
            for (AgreedVolume__c amendedAgreedVolume : agreedVolume.AmendedAgreedVolumes__r) {
                AmendedAgreedVolumes.add(new BlIn_BillCalcAmendedAgreedVolumeObj(container, amendedAgreedVolume));
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 Jan 2018
    @description    Subclass for AgreedSampleStrength (without amended child records)
    *******************************************************************************/
    private virtual class BlIn_BillCalcAmendedAgrdSmplStrengthObj {

        private Id AgreedSampleStrengthId;
        private Decimal CODAgreedSampleStrength;
        private Decimal SSAgreedSampleStrength;
        private String StartDate;
        private String EndDate;
        private Boolean Invalid; //AT-3322

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           23 Jan 2018
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          AgreedSampleStrength__c - agreedSampleStrength record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcAmendedAgrdSmplStrengthObj(BlIn_BillCalcDataContainer container, AgreedSampleStrength__c agreedSampleStrength) {
            
            // add the agreed sample strength fields to this DTO
            AgreedSampleStrengthId = agreedSampleStrength.Id;
            CODAgreedSampleStrength = agreedSampleStrength.CODAgreedSampleStrength__c;
            SSAgreedSampleStrength = agreedSampleStrength.SSAgreedSampleStrength__c;
            StartDate = dateToString(agreedSampleStrength.StartDate__c);
            EndDate = dateToString(agreedSampleStrength.EndDate__c);
            Invalid = agreedSampleStrength.Invalid__c;//AT-3322
        }
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 Jan 2018
    @description    Subclass for AgreedSampleStrength
    *******************************************************************************/
    private class BlIn_BillCalcAgrdSmplStrengthObj extends BlIn_BillCalcAmendedAgrdSmplStrengthObj{

        private List<BlIn_BillCalcAmendedAgrdSmplStrengthObj> AmendedAgreedSampleStrengths;

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           23 Jan 2018
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          AgreedSampleStrength__c - agreedSampleStrength record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcAgrdSmplStrengthObj(BlIn_BillCalcDataContainer container, AgreedSampleStrength__c agreedSampleStrength) {
            
            super(container, agreedSampleStrength);
            
            // build the list of amended agreed sample strength DTOs
            AmendedAgreedSampleStrengths = new List<BlIn_BillCalcAmendedAgrdSmplStrengthObj>();  
            for (AgreedSampleStrength__c amendedAgreedSampleStrength : agreedSampleStrength.AmendedAgreedSampleStrengths__r) {
                AmendedAgreedSampleStrengths.add(new BlIn_BillCalcAmendedAgrdSmplStrengthObj(container, amendedAgreedSampleStrength));
            }
        }
    }
    
    //Commented Discharge Point AT-3147
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 Jan 2018
    @description    Subclass for DischargePoint
    *******************************************************************************/
 /*   private class BlIn_BillCalcDischargePointObj {

        private Id DischargePointId;
        private BlIn_BillCalcDischargeSupplyPoint SupplyPoint;*/

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           23 Jan 2018
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          DischargePoint__c - dischargePoint record
        @description    Constructor
        *******************************************************************************/
   /*     private BlIn_BillCalcDischargePointObj(BlIn_BillCalcDataContainer container, DischargePoint__c dischargePoint) {
            
            // add the discharge point fields to this DTO
            DischargePointId = dischargePoint.Id;

            // build the supply point DTO
            for (SupplyPoint__c thisSupplyPoint : container.supplyPoints) {
                if (dischargePoint.SupplyPoint__c == thisSupplyPoint.Id) {
                    SupplyPoint = new BlIn_BillCalcDischargeSupplyPoint(container, thisSupplyPoint); 
                    break;      // one only
                }
            }
        }
    }
    */

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           29 Aug 2017
    @description    Subclass for Sample (without amended child records)
    *******************************************************************************/
    private virtual class BlIn_BillCalcAmendedSamplesObj {

        private Id SampleId;
        /*   AT-3147  */
        private Decimal CODSampleStrength;
        private String Name; 
        private date SampleCollectionDate;
        private decimal SSSampleStrength;
        /*   AT-3147  */
        //AT-4991, Ankit, 18/01/2018
        private Boolean Exclude;    
        private Decimal PSampleStrength;
        private Decimal TDSSampleStrength;
        private Decimal TKNSampleStrength;
        
        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           31 Aug 2017
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          Sample__c - sample record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcAmendedSamplesObj(BlIn_BillCalcDataContainer container, Sample__c sample) {
            
            // add the sample fields to this DTO
            SampleId = sample.Id;
            CODSampleStrength = sample.CODSampleStrength__c;        //   AT-3147  
            Name = sample.Name;                                     //   AT-3147  
            SampleCollectionDate = sample.SampleCollectionDate__c;  //   AT-3147  
            SSSampleStrength  = sample.SSSampleStrength__c;         //   AT-3147 
            //AT-4991, Ankit, 18/01/2018
            Exclude = sample.Exclude__c;
            PSampleStrength = sample.PSampleStrength__c;
            TDSSampleStrength = sample.TDSSampleStrength__c;
            TKNSampleStrength = sample.TKNSampleStrength__c;
            
        }
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           02 Nov 2017
    @description    Subclass for Sample (extends base class DTO to include child amended records)
    *******************************************************************************/
    private class BlIn_BillCalcSamplesObj extends BlIn_BillCalcAmendedSamplesObj {

        private List<BlIn_BillCalcAmendedSamplesObj> AmendedSamples;

        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           02 Nov 2017
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          Sample__c - sample record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcSamplesObj(BlIn_BillCalcDataContainer container, Sample__c sample) {
            
            super(container, sample);

            // build the list of amended samples DTOs
            AmendedSamples = new List<BlIn_BillCalcAmendedSamplesObj>();  
            for (Sample__c amendedSample : sample.AmendedSamples__r) {
                AmendedSamples.add(new BlIn_BillCalcAmendedSamplesObj(container, amendedSample));
            }
        }
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           01 Nov 2017
    @description    Subclass for Manual Ammendment
    *******************************************************************************/
    private class BlIn_BillCalcManualAmendmentObj {
        
        private Id ManualAmendmentId;
        private Id BillItemId;
        private Decimal Amount;
        private String Reason;
        Private String ApprovalStatus;  //AT-3286

        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           01 Nov 2017
        @param          BlIn_BillCalcDataContainer - instance of the container class
        @param          ManualAmendment__c - manual amendment record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcManualAmendmentObj(BlIn_BillCalcDataContainer container, ManualAmendment__c manualAmendment) {
            
            // add the manual amendment fields to this DTO
            ManualAmendmentId = manualAmendment.Id;
            BillItemId = manualAmendment.AmendedBillItem__c;
            Amount = manualAmendment.Amount__c;
            Reason = manualAmendment.AmendmentReason__c;
            ApprovalStatus = manualAmendment.ApprovalStatus__c;  //AT-3286
        }
    }
}