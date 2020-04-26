/******************************************************************************
@author         Echo: Patrick Dixon
@date           17 May 2018
@description    A data transfer object (DTO) class used to create an instance 
                of the data extracted from Salesforce records to format the 
                XML message which is passed to the PDF Correspondence REST service
Revision(s)		AT-4888, Checkmarks issues.
Revision(s)     Tarun Gupta , AT_4858 , Added DPID fields
*******************************************************************************/
/******************************************************************************
Object Hierarchy
----------------

[SDFC Name (DTO Name)]
PdfTemplateName
XsltName
PDFRequest__c (PDFRequest)
    ->  BillingContract__c (Contract)
        ->  DebtRecoveryProcess__c (DebtRecoveryProcess)
        ->  Payment__c (Payment) - (last 12 months)
        ->  PaymentPlan__c (PaymentPlan)
            ->  Instalment__c (Instalment)
        ->  Service__c (Service)
            ->  SupplyPoint__c (SupplyPoint)
                ->  SupplyPointDevice__c (SupplyPointDevice)
                    ->  AverageDailyUsage__c (AverageDailyUse) - (last 18 months)
                    ->  Device__c (Device)
                        ->  Reading__c (Reading) - (last 12 months)
                        ->  SubDevices__c (SubDevice)
                            ->  Reading__c (Reading) - (last 12 months)
                ->  Location__c (Location)
                    ->  LocationOccupant__c (LocationOccupant)
                ->  ReadTimetable__c (ReadTimetable)
        ->  Bill__c (Bill) - (last 12 months)
        ->  Balance__c (Balance)
    ->  Account (AccountObj)
    ->  Contact (ContactObj)
                                    
*******************************************************************************/
public with sharing class GlUt_ComplexCorrespondenceDataContainer {
    
    private static final String CLASS_NAME = 'GlUt_ComplexCorrespondenceDataContainer';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    // utility methods used to format date and datetime fields for json as yyyy-MM-dd HH:mm:ss
    private static String dateToString(Date d) {return d != null ? String.valueOf(d) + ' 00:00:00' : null;}
    private static String dateToString(DateTime dt) {return dt != null ? String.valueOf(dt) : null;}
    
    public PDFRequests data {get; private set;}     // structured data
    public String XML {get; private set;}       // XML of structured data
       
    // the records required for the data payload
    public Map<Id, TemplateMapping__c> templateSettingMap;      // map of templates keyed on pdf request Id
    public List<Account> accounts;
    public List<Contact> contacts;
    public List<BillingContract__c> contracts;
    @testVisible private List<Service__c> services;
    private List<SupplyPoint__c> supplyPoints;      // includes related supply point device records
    private List<Location__c> locations;      // includes related location occupants records
    @testVisible private List<AverageDailyUsage__c> averageDailyUses;      // last 18 months
    private List<Device__c> devices;
    private Map<Id, Set<Id>> serviceTypeMap;     // map of set of the ServiceType Ids keyed on SupplyPoint Id used to identify correct device
    private List<Device__c> subDevices;
    private List<Reading__c> readings;     // last 12 months
    private List<Bill__c> bills;     // last 12 months
    private List<DebtRecoveryProcess__c> debtRecoveryProcesses;
    private List<Payment__c> payments;
    private List<PaymentPlan__c> paymentPlans;      // includes related instalment records

    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 May 2018
    @param          List<PDFRequest__c> - the list of pdf requests
    @description    Constructor
    *******************************************************************************/
    public GlUt_ComplexCorrespondenceDataContainer(List<PDFRequest__c> pdfRequests) {
        
        // get the pdf templates for all the pdf requests
        templateSettingMap = GlUt_CorrespondenceHandler.getTemplateSettings(pdfRequests);
        
        // build a list of the contract Ids
        List<Id> contractIds = new List<Id>();
        for (PDFRequest__c pdfRequest : pdfRequests) {
            contractIds.add(pdfRequest.BillingContract__c);
        }
    
        contracts = getContracts(contractIds);
        buildXML(pdfRequests, contractIds);
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 May 2018
    @param          List<PDFRequest__c> - the list of pdf requests
    @param          List<Id> - the list of contract Ids
    @description    Builds the XML data
    *******************************************************************************/
    private void buildXML(List<PDFRequest__c> pdfRequests, List<Id> contractIds) {

        // build lists of the account and contact Ids
        List<Id> accountIds = new List<Id>();
        List<Id> contactIds = new List<Id>();
        for (PDFRequest__c pdfRequest : pdfRequests) {
            accountIds.add(pdfRequest.Account__c);
            contactIds.add(pdfRequest.Contact__c);
        }

        /* STEP 1: get all the data records required */

        // get all the account records
        accounts = getAccounts(accountIds);

        // get all the contact records
        contacts = getContacts(contactIds);

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
        
        /* STEP 2: build the data using the DTO hierachy */

        // build DTOs
        data = new PDFRequests(this, pdfRequests);
        
        // serialise
        XML = GlUt_XMLSerialiser.serialize((Object) data);
        
        system.debug('XML correspondence ::' + XML);

        GlUt_Logger.logDebug(DEBUG + 'XML: ' + XML);
        GlUt_Logger.logDebug(DEBUG + 'Heap Size Used: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize() 
                + ' (' + ((Limits.getHeapSize() * 100) / Limits.getLimitHeapSize()) + '%)');
        GlUt_Logger.logDebug(DEBUG + 'CPU Time Used: ' + Limits.getCpuTime()  + '/' + Limits.getLimitCpuTime()
                + ' (' + ((Limits.getCpuTime() * 100) / Limits.getLimitCpuTime()) + '%)');
    }
    
    /* METHODS FOR STEP 1: get all the data records required */
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           25 May 2018
    @param          List<Id> - contract Ids
    @return         List<BillingContract__c> - contracts
    @description    gets the contract records
    *******************************************************************************/
    public static List<BillingContract__c> getContracts(List<Id> contractIds) {
        return [select Id, 
                        AccountName__c, 
                        Balance__r.Balance__c, 
                        Balance__r.BalanceSnapshot__c, 
                        CurrentPaymentPlanType__c, 
                        CurrentDebtRecoveryProcess__c, 
                        DebtRecoveryProfile__c, 
                        DayOfMonth__c, 
                        DayOfWeek__c, 
                        PaymentMethodType__c, 
                        BillingStreet__c, 
                        BillingCity__c, 
                        BillingState__c, 
                        BillingCountry__c, 
                        BillingPostalCode__c,
                // MT - 20 Aug 2018 Start of AT-3410
                        UseAlternativeAddress__c,
                        AlternativeBilling__r.BillingStreet, 
                        AlternativeBilling__r.BillingCity, 
                        AlternativeBilling__r.BillingState, 
                        AlternativeBilling__r.BillingCountry, 
                        AlternativeBilling__r.BillingPostalCode,
                //End of AT-3410
                // AT-4933 Starts Here
                       AlternativeBillingRelationship__c,
                       AlternativeBillingName__c,
                // AT-4933 Ends Here
                // AT-4858 Starts Here
                       BillingAuDpid__c,
                       AlternativeAuDpid__c,
                // AT-4858 Ends Here
                        (select Id from Services__r)
                 
                 from BillingContract__c
                 where Id in :contractIds];
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
                        AccountReference__c,
                 		AuDpid__c // AT-4858
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
    private List<Reading__c> getReadings(Set<Id> deviceIds) {

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
                		AuDPID__c, //AT-4858
                        (select Id, 
                                Name, 
                         		Account__c, //AT-5535, Ankit, 23/04/2019
                         		Account__r.Name, //AT-5535, Ankit, 23/04/2019
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

    /* SUB-CLASSES FOR STEP 2: build the data using the DTO hierachy */
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           25 May 2018
    @description    Subclass for PDFRequests
    *******************************************************************************/
    private class PDFRequests {

        private List<PDFRequest> PDFRequest;

        public override String toString() {
            return 'PDFRequests';
        }
    
        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           25 May 2018
        @param          GlUt_ComplexCorrespondenceDataContainer - instance of the container class
        @param          List<PDFRequest__c> - pdfRequest records
        @description    Constructor
        *******************************************************************************/
        private PDFRequests(GlUt_ComplexCorrespondenceDataContainer container, List<PDFRequest__c> pdfRequests) {
            
            // build the pdfRequest DTO
            PDFRequest = new List<PDFRequest>();
            for (PDFRequest__c thisPDFRequest : pdfRequests) {
                PDFRequest.add(new PDFRequest(container, thisPDFRequest));
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           22 May 2018
    @description    Subclass for PDFRequest__c
    *******************************************************************************/
    private class PDFRequest {
        /* PDF Request parent object Fields */
        private String PdfTemplateName;
        private String XsltName;
        private Id Id;
        private String SourceType;
        /* Contract Releated Fields */
        private Id Contract_Id;
        private String Contract_CurrentPaymentPlanType;
        private String Contract_CurrentDebtRecoveryProcess;
        private String Contract_DebtRecoveryProfile;
        private String Contract_DayOfMonth;
        private String Contract_DayOfWeek;
        private String Contract_PaymentMethodType;
        private String Contract_BillingStreet;
        private String Contract_BillingCity;
        private String Contract_BillingState;
        private String Contract_BillingCountry;
        private String Contract_BillingPostalCode;
        private Boolean Contract_UseAlternativeAddress;
        private String Contract_AlternativeBillingStreet ;
        private String Contract_AlternativeBillingCity ;
        private String Contract_AlternativeBillingState ;
        private String Contract_AlternativeBillingCountry ;
        private String Contract_AlternativeBillingPostalCode ;
        // AT-4933 Starts Here
        private String  Contract_AlternativeBilling_Name ;
        private String  Contract_AlternativeBilling_Relationship ;
        // AT-4933 Ends Here
        /*Account Fields */
        private String Account_Id; 
        private String Account_Name; 
        private String Account_AccountReference; 
        /* Contact Fields */
        private String Contact_Id; 
        //AT-4858 Starts Here
        private String Contract_BillingAuDpid;
		private String Contract_AlternativeAuDpid;
        private String Account_AuDpid; 
        //AT-4858 Ends Here
        
        private List<Service> Service;
        private List<Bill> Bill;
        private DebtRecoveryProcess DebtRecoveryProcess;
        private List<Payment> Payment;
        private PaymentPlan PaymentPlan;
        private Balance Balance;
        
        //private Contract Contract;
        
        public override String toString() {
            return 'PDFRequest__c';
        }
    
        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           22 May 2018
        @param          GlUt_ComplexCorrespondenceDataContainer - instance of the container class
        @param          PDFRequest__c - pdfRequest record
        @description    Constructor
        *******************************************************************************/
        private PDFRequest(GlUt_ComplexCorrespondenceDataContainer container, PDFRequest__c pdfRequest) {
            
            // select the template
            TemplateMapping__c templateMapping = container.templateSettingMap.get(pdfRequest.Id);

            // add the fields to the DTO
            if (templateMapping != null) {
                PdfTemplateName = templateMapping.PDFTemplate__c;
                XsltName = templateMapping.XSLTDocument__c;
            }
            Id = pdfRequest.Id;
            SourceType = pdfRequest.SourceType__c;

            // build the contract DTO
            for (BillingContract__c thisContract : container.contracts) {
                if (thisContract.Id == pdfRequest.BillingContract__c) {
                    Contract_Id = thisContract.Id;
                    Contract_CurrentPaymentPlanType = thisContract.CurrentPaymentPlanType__c;
                    Contract_CurrentDebtRecoveryProcess = thisContract.CurrentDebtRecoveryProcess__c;
                    Contract_DebtRecoveryProfile = thisContract.DebtRecoveryProfile__c;
                    Contract_DayOfMonth = thisContract.DayOfMonth__c;
                    Contract_DayOfWeek = thisContract.DayOfWeek__c;
                    Contract_PaymentMethodType = thisContract.PaymentMethodType__c;
                    Contract_BillingStreet = thisContract.BillingStreet__c;
                    Contract_BillingCity = thisContract.BillingCity__c;
                    Contract_BillingState = thisContract.BillingState__c;
                    Contract_BillingCountry = thisContract.BillingCountry__c;
                    Contract_BillingPostalCode = thisContract.BillingPostalCode__c;
                    //AT-4858 Starts Here
                    Contract_BillingAuDpid = thisContract.BillingAuDpid__c;
                    Contract_AlternativeAuDpid = thisContract.AlternativeAuDpid__c;
                    //AT-4858 Ends Here
                    
                    if(thisContract.UseAlternativeAddress__c){
                        Contract_UseAlternativeAddress = thisContract.UseAlternativeAddress__c;
                        Contract_AlternativeBillingStreet = thisContract.AlternativeBilling__r.BillingStreet;
                        Contract_AlternativeBillingCity = thisContract.AlternativeBilling__r.BillingCity;
                        Contract_AlternativeBillingState = thisContract.AlternativeBilling__r.BillingState;
                        Contract_AlternativeBillingCountry = thisContract.AlternativeBilling__r.BillingCountry;
                        Contract_AlternativeBillingPostalCode = thisContract.AlternativeBilling__r.BillingPostalCode;
                    }
                    // AT-4933 Starts Here
                    Contract_AlternativeBilling_Name = thisContract.AlternativeBillingName__c;
                    Contract_AlternativeBilling_Relationship = thisContract.AlternativeBillingRelationship__c; 
                    // AT-4933 Ends Here
                    // build the list of service DTOs
                    Service = new List<Service>();
                    for (Service__c thisService : container.services) {
                        if (thisService.BillingContract__c == thisContract.Id) {
                            Service.add(new Service(container, thisService));
                        }
                    }
                    
                    // build the list of bill DTOs
                    Bill = new List<Bill>();
                    for (Bill__c thisBill : container.bills) {
                        if (thisBill.BillingContract__c == thisContract.Id) {
                            Bill.add(new Bill(container, thisBill));
                        }
                    }
                    
                    // build the debt recovery process DTO
                    for (DebtRecoveryProcess__c thisDebtRecoveryProcess : container.debtRecoveryProcesses) {
                        if (thisDebtRecoveryProcess.BillingContract__c == thisContract.Id) {
                            DebtRecoveryProcess = new DebtRecoveryProcess(container, thisDebtRecoveryProcess);
                            break;      // one only
                        }
                    }
                    
                    // build the list of payment DTOs
                    Payment = new List<Payment>();
                    for (Payment__c thisPayment : container.payments) {
                        if (thisPayment.BillingContract__c == thisContract.Id) {
                            Payment.add(new Payment(container, thisPayment));
                        }
                    }
                    
                    // build the list of payment plan DTOs
                    for (PaymentPlan__c thisPaymentPlan : container.paymentPlans) {
                        if (thisPaymentPlan.BillingContract__c == thisContract.Id) {  // AT-3174 
                            PaymentPlan = new PaymentPlan(container, thisPaymentPlan);
                            break;      // one only
                        }
                    }
                    
                    // build the balance DTO
                    if (thisContract.Balance__r.Balance__c != null
                        && thisContract.Balance__r.BalanceSnapshot__c != null) {
                            Balance = new Balance(container, thisContract);
                        }
                    break;
                }
            }

            // build the contract DTO
            for (Account thisAcccount : container.accounts) {
                if (thisAcccount.Id == pdfRequest.Account__c) {
                    Account_Id = thisAcccount.Id; 
                    Account_Name = thisAcccount.Name; 
                    Account_AccountReference = thisAcccount.AccountReference__c;
                    Account_AuDpid = thisAcccount.AuDpid__c; // AT-4858
                    break;
                }
            }

            // build the contact DTO
            for (Contact thisContact : container.contacts) {
                if (thisContact.Id == pdfRequest.Contact__c) {
                    Contact_Id = thisContact.Id;
                    break;
                }
            }
            
        }
    
        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           01 Jun 2018
        @param          PDFRequest - instance of the PDFRequest class
        @param          PDFRequest__c - pdfRequest record
        @description    assigns the template and XSLT names for the correspondence
        *******************************************************************************/
        private void selectTemplate(PDFRequest thisPDFRequest, PDFRequest__c pdfRequest) {
            
            thisPDFRequest.PdfTemplateName = 'TemplateName';
            thisPDFRequest.XsltName = 'XSLTDocumentName';
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           22 May 2018
    @description    Subclass for Service
    *******************************************************************************/
    private class Service {
        
        private SupplyPoint SupplyPoint;

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           22 May 2018
        @param          GlUt_ComplexCorrespondenceDataContainer - instance of the container class
        @param          Service__c - service record
        @description    Constructor
        *******************************************************************************/
        private Service(GlUt_ComplexCorrespondenceDataContainer container, Service__c service) {

            // add the service fields to this DTO

            // build the supply point DTO
            for (SupplyPoint__c thisSupplyPoint : container.supplyPoints) {
                if (service.SupplyPoint__c == thisSupplyPoint.Id) {
                    SupplyPoint = new SupplyPoint(container, service.ServiceType__c, thisSupplyPoint); 
                    break;      // one only
                }
            }
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           25 May 2018
    @description    Subclass for SupplyPoint
    *******************************************************************************/
    private class SupplyPoint {
        
        private String ReadFrequency;
        private List<SupplyPointDevice> SupplyPointDevice;
        private Location Location;
        private ReadTimetable ReadTimetable;

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           25 May 2018
        @param          GlUt_ComplexCorrespondenceDataContainer - instance of the container class
        @param          Id - service type Id
        @param          SupplyPoint__c - supplyPoint record
        @description    Constructor
        *******************************************************************************/
        private SupplyPoint(GlUt_ComplexCorrespondenceDataContainer container, Id serviceType, SupplyPoint__c supplyPoint) {
            
            // add the fields to this DTO
            ReadFrequency = supplyPoint.Read_Frequency__c;

            // build the list of supply point device DTOs
            SupplyPointDevice = new List<SupplyPointDevice>();
            for (SupplyPointDevice__c thisSupplyPointDevice : supplyPoint.supplyPointDevices__r) {
                // MT - 22-08-2018 Start of AT-3410 added check of containsKey
                if(container.serviceTypeMap.containsKey(thisSupplyPointDevice.Id)){
                    if (container.serviceTypeMap.get(thisSupplyPointDevice.Id).contains(serviceType)) {
                        SupplyPointDevice.add(new SupplyPointDevice(container, thisSupplyPointDevice));
                    }
                }
                // End of AT-3410
            }

            // build the location DTO
            for (Location__c thisLocation : container.locations) {
                if (supplyPoint.Location__c == thisLocation.Id) {
                    Location = new Location(container, thisLocation);
                    break;      // one only
                }
            }
            
            if (supplyPoint.Book__r.ReadTimetable__r.Name != null)
            ReadTimetable = new ReadTimeTable(container, supplyPoint);
        }
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 May 2018
    @description    Subclass for SupplyPointDevice
    *******************************************************************************/
    private class SupplyPointDevice {
        
        private String InstallationDate;
        private Device Device;
        private List<AverageDailyUse> AverageDailyUse;

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           23 May 2018
        @param          GlUt_ComplexCorrespondenceDataContainer - instance of the container class
        @param          SupplyPointDevice__c - supplyPointDevice record
        @description    Constructor
        *******************************************************************************/
        private SupplyPointDevice(GlUt_ComplexCorrespondenceDataContainer container, SupplyPointDevice__c supplyPointDevice) {
            // add the fields to this DTO
            InstallationDate = dateToString(supplyPointDevice.InstallationDate__c);
            
            // build the service device DTO
            for (Device__c thisDevice : container.devices) {
                if (supplyPointDevice.Device__c == thisDevice.Id) {
                    Device = new Device(container, thisDevice);
                    break;      // one only
                }
            }
            
            // build the list of average daily use DTOs
            AverageDailyUse = new List<AverageDailyUse>();
            for (AverageDailyUsage__c thisAverageDailyUse : container.averageDailyUses) {
                if (thisAverageDailyUse.SupplyPointDevice__c == supplyPointDevice.Id) {
                    AverageDailyUse.add(new AverageDailyUse(container, thisAverageDailyUse));
                }
            } 
        }
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 May 2018
    @description    Subclass for AverageDailyUsage
    *******************************************************************************/
    private class AverageDailyUse {
        
        private String StartDate;
        private String EndDate;
        private Decimal AverageDailyUsage;
        private Boolean Invalid;   //AT-3555

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           23 May 2018
        @param          GlUt_ComplexCorrespondenceDataContainer - instance of the container class
        @param          AverageDailyUsage__c - averageDailyUse record
        @description    Constructor
        *******************************************************************************/
        private AverageDailyUse(GlUt_ComplexCorrespondenceDataContainer container, AverageDailyUsage__c averageDailyUse) {
            
            // add the averageDailyUsage fields to this DTO
            StartDate = dateToString(averageDailyUse.StartDate__c);
            EndDate = dateToString(averageDailyUse.EndDate__c);
            AverageDailyUsage = averageDailyUse.AverageDailyUsage__c;
            Invalid = averageDailyUse.Invalid__c;   //AT-3555
        } 
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 May 2018
    @description    Subclass for Sub Device
    *******************************************************************************/
    private virtual class SubDevice {

        private String SerialNumber;
        private String Digits;
        private String DeviceType;
        private List<Reading> Reading;  

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           23 May 2018
        @param          GlUt_ComplexCorrespondenceDataContainer - instance of the container class
        @param          Device__c - device record (can be sub or main if the class is extended)
        @description    Constructor
        *******************************************************************************/
        private SubDevice(GlUt_ComplexCorrespondenceDataContainer container, Device__c device) {
            
            // add the sub device fields to this DTO
            SerialNumber = device.SerialNo__c;
            Digits = String.valueOf(device.Digit__c);
            DeviceType = device.DeviceType__c;

            // build the list of related readings DTOs
            Reading = new List<Reading>();  
            for (Reading__c thisReading : container.readings) {
                if (thisReading.Device__c == device.Id) {
                    Reading.add(new Reading(container, thisReading));
                }
            }
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 May 2018
    @description    Subclass for Device (extends base class DTO to include child sub device records)
    *******************************************************************************/
    private class Device extends SubDevice {

        private List<SubDevice> SubDevice;

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           23 May 2018
        @param          GlUt_ComplexCorrespondenceDataContainer - instance of the container class
        @param          Device__c - device record
        @description    Constructor
        *******************************************************************************/
        private Device(GlUt_ComplexCorrespondenceDataContainer container, Device__c device) {

            super(container, device);
            
            // build the list of related sub devices DTOs
            SubDevice = new List<SubDevice>();
            
            /* MT - 22-08-2018 Start of AT-3410 Sub device logic is not needed anymore
              for (Device__c thisSubDevice : container.subDevices) {
                for (DeviceRelationship__c relationship : device.DeviceRelationships__r) {
                    if (relationship.MainDevice__c == device.Id) {
                        SubDevice.add(new SubDevice(container, thisSubDevice));
                    }
                }
            }
            End of AT-3410*/
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           23 May 2018
    @description    Subclass for Reading
    *******************************************************************************/
    private class Reading {
        
        private Decimal Reading;
        private String ReadingDate;
        private String ReadingSource;
        private String ReadingMethod;
        private String ReadingType;        

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           23 May 2018
        @param          GlUt_ComplexCorrespondenceDataContainer - instance of the container class
        @param          Reading__c - reading record
        @description    Constructor
        *******************************************************************************/
        private Reading(GlUt_ComplexCorrespondenceDataContainer container, Reading__c reading) {
            // add the fields to this DTO
            this.Reading = reading.Reading__c;
            ReadingDate = dateToString(reading.ReadingDate__c);
            ReadingSource = reading.ReadingSource__c; 
            ReadingMethod = reading.ReadingMethod__c; 
            ReadingType = reading.ReadingType__c; 
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           25 May 2018
    @description    Subclass for Location
    *******************************************************************************/
    private class Location {

        private String Street;
        private String City;
        private String State;
        private String Country;        
        private String PostalCode;        
        private String VoidLocation;
        private String LocationAuDpid; // AT-4858
        
        private List<LocationOccupant> LocationOccupant;

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           25 May 2018
        @param          GlUt_ComplexCorrespondenceDataContainer - instance of the container class
        @param          Location__c - location record
        @description    Constructor
        *******************************************************************************/
        private Location(GlUt_ComplexCorrespondenceDataContainer container, Location__c location) {
            // add the fields to this DTO
            Street = location.Street__c;
            City = location.City__c;
            State = location.State__c;
            Country = location.Country__c;
            PostalCode = location.PostalCode__c;
            VoidLocation = String.valueOf(location.VoidLocation__c);
            LocationAuDpid = location.AuDPID__c; //AT-4858

            // build the list of related location occupant DTOs
            LocationOccupant = new List<LocationOccupant>();
            for (LocationOccupant__c thisLocationOccupant : location.LocationOccupants__r) {
                LocationOccupant.add(new LocationOccupant(container, thisLocationOccupant));
            }
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           25 May 2018
    @description    Subclass for LocationOccupant
    *******************************************************************************/
    private class LocationOccupant {
        
        private String Name;
        private String OccupancyType;
        private String ShowOnBill;
        private String StartDate;        
        private String EndDate;  
        private String AccountName; //AT-5535, Ankit, 23/02/2019
        
        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           25 May 2018
        @param          GlUt_ComplexCorrespondenceDataContainer - instance of the container class
        @param          LocationOccupant__c - location occupant record
        @description    Constructor
        *******************************************************************************/
        private LocationOccupant(GlUt_ComplexCorrespondenceDataContainer container, LocationOccupant__c locationOccupant) {
            
            // add the fields to this DTO
            Name = locationOccupant.Name;
            OccupancyType = locationOccupant.OccupancyType__c;
            ShowOnBill = String.valueOf(locationOccupant.ShowOnBill__c);
            StartDate = dateToString(locationOccupant.StartDate__c);
            EndDate = dateToString(locationOccupant.EndDate__c);
            AccountName = locationOccupant.Account__r.Name; //AT-5535, Ankit, 23/04/2019
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           25 May 2018
    @description    Subclass for ReadTimetable
    *******************************************************************************/
    private class ReadTimetable {
        
        private String Name;
        
        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           25 May 2018
        @param          GlUt_ComplexCorrespondenceDataContainer - instance of the container class
        @param          SupplyPoint__c - supplyPoint record
        @description    Constructor
        *******************************************************************************/
        private ReadTimetable(GlUt_ComplexCorrespondenceDataContainer container, SupplyPoint__c supplyPoint) {
            
            // add the fields to this DTO
            Name = supplyPoint.Book__r.ReadTimetable__r.Name;
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           24 May 2018
    @description    Subclass for Bill
    *******************************************************************************/
    private class Bill {
        
        private String StartDate;
        private String EndDate;
        private String BillDate;
        private Decimal BilledAmount;        

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           23 May 2018
        @param          GlUt_ComplexCorrespondenceDataContainer - instance of the container class
        @param          Bill__c - bill record
        @description    Constructor
        *******************************************************************************/
        private Bill(GlUt_ComplexCorrespondenceDataContainer container, Bill__c bill) {
            
            // add the fields to this DTO
            StartDate = dateToString(bill.StartDate__c);
            EndDate = dateToString(bill.EndDate__c);
            BillDate = dateToString(bill.BillDate__c);
            BilledAmount = bill.BilledAmount__c; 
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           25 May 2018
    @description    Subclass for Debt Recovery Process
    *******************************************************************************/
    private class DebtRecoveryProcess {
        
        private String PaymentDueDate;
        private Decimal TotalAmountDue;
        private String CurrentStage;
        private String CurrentStageDateTime;        

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           25 May 2018
        @param          GlUt_ComplexCorrespondenceDataContainer - instance of the container class
        @param          DebtRecoveryProcess__c - debt recovery process record
        @description    Constructor
        *******************************************************************************/
        private DebtRecoveryProcess(GlUt_ComplexCorrespondenceDataContainer container, DebtRecoveryProcess__c debtRecoveryProcess) {
            
            // add the fields to this DTO
            PaymentDueDate = dateToString(debtRecoveryProcess.PaymentDueDate__c);
            TotalAmountDue = debtRecoveryProcess.TotalAmountDue__c;
            CurrentStage = debtRecoveryProcess.CurrentStage__c;
            CurrentStageDateTime = dateToString(debtRecoveryProcess.CurrentStageDateTime__c);
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           25 May 2018
    @description    Subclass for Payment
    *******************************************************************************/
    private class Payment {
        
        private Decimal Amount;
        private String PaymentMethod;
        private String PaymentSource;
        private String PaymentDate;        

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           25 May 2018
        @param          GlUt_ComplexCorrespondenceDataContainer - instance of the container class
        @param          Payment__c - payment record
        @description    Constructor
        *******************************************************************************/
        private Payment(GlUt_ComplexCorrespondenceDataContainer container, Payment__c payment) {
            
            // add the fields to this DTO
            Amount = payment.Amount__c;
            PaymentMethod = payment.PaymentMethod__c;
            PaymentSource = payment.PaymentSource__c;
            PaymentDate = dateToString(payment.PaymentDate__c);
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           25 May 2018
    @description    Subclass for Payment Plan
    *******************************************************************************/
    private class PaymentPlan {
        
        private String Name; 
        private String PaymentFrequency; 
        private Decimal PaymentPlanTotal; 
        private String StartDate;
        private Decimal TotalInstalmentAmount;

        private List<Instalment> Instalment;

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           25 May 2018
        @param          GlUt_ComplexCorrespondenceDataContainer - instance of the container class
        @param          PaymentPlan__c - payment plan record
        @description    Constructor
        *******************************************************************************/
        private PaymentPlan(GlUt_ComplexCorrespondenceDataContainer container, PaymentPlan__c paymentPlan) {
            
            // add the fields to this DTO
            Name = paymentPlan.Name;
            PaymentFrequency = paymentPlan.PaymentFrequency__c;
            PaymentPlanTotal = paymentPlan.PaymentPlanTotal__c;
            StartDate = dateToString(paymentPlan.StartDate__c);
            TotalInstalmentAmount = paymentPlan.TotalInstalmentAmount__c;

            // build the list of related instalment DTOs
            Instalment = new List<Instalment>();
            for (Instalment__c thisInstalment : paymentPlan.Instalments__r) {
                Instalment.add(new Instalment(container, thisInstalment));
            }
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           25 May 2018
    @description    Subclass for Instalment
    *******************************************************************************/
    private class Instalment {
        
        private Decimal InstalmentAmountDue; 
        private Decimal InstalmentAmountOutstanding; 
        private String InstalmentDueDate; 
        private Integer InstalmentNumber;
        private Decimal SumofAllocatedPayment;

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           25 May 2018
        @param          GlUt_ComplexCorrespondenceDataContainer - instance of the container class
        @param          Instalment__c - instalment record
        @description    Constructor
        *******************************************************************************/
        private Instalment(GlUt_ComplexCorrespondenceDataContainer container, Instalment__c instalment) {
            
            // add the fields to this DTO
            InstalmentAmountDue = instalment.InstalmentAmountDue__c; 
            InstalmentAmountOutstanding = instalment.InstalmentAmountOutstanding__c; 
            InstalmentDueDate = dateToString(instalment.InstalmentDueDate__c); 
            InstalmentNumber = Integer.valueOf(instalment.InstalmentNumber__c); 
            SumofAllocatedPayment = instalment.SumofAllocatedPayment__c;
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           25 May 2018
    @description    Subclass for Balance
    *******************************************************************************/
    private class Balance {
        
        private Decimal Balance; 
        private Decimal BalanceSnapshot; 

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           25 May 2018
        @param          GlUt_ComplexCorrespondenceDataContainer - instance of the container class
        @param          BillingContract__c - contract record
        @description    Constructor
        *******************************************************************************/
        private Balance(GlUt_ComplexCorrespondenceDataContainer container, BillingContract__c contract) {
            
            // add the fields to this DTO
            Balance = contract.Balance__r.Balance__c; 
            BalanceSnapshot = contract.Balance__r.BalanceSnapshot__c; 
        }
    }


}