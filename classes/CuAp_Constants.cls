/************************************************************************************************************
@author         Accenture : Luke Emberton
@date           10-Sep-2017
@description:   This is the constants class for all static strings used in this namespace
@revision:      07-Mar-2018 MT - Added the namespace prefix
**************************************************************************************************************/
public with sharing class CuAp_Constants {

    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    //The prefix for this namespace
    public static string PREFIX = 'CuAp_';
    public static string ID = 'Id';
    
    //Appended to the end of all trigger handler classes
    public static string  LOCATIONAPINAME            = NAMESPACEPREFIX + 'Location__c';
    public static string  STREETAPINAME              = NAMESPACEPREFIX + 'Street__c';
    public static string  CITYAPINAME                = NAMESPACEPREFIX + 'City__c';
    public static string  STATEPROVINCEAPINAME       = NAMESPACEPREFIX + 'State__c';
    public static string  POSTALZIPCODEAPINAME       = NAMESPACEPREFIX + 'PostalCode__c';
    public static string  PARENTLOCATIONAPINAME      = NAMESPACEPREFIX + 'ParentLocation__c';
    public static string  LOCATIONTYPEAPINAME        = NAMESPACEPREFIX + 'LocationType__c';
    public static string  LOCATIONSUBTYPEAPINAME     = NAMESPACEPREFIX + 'LocationSubType__c';
    //public static string  LOCATIONREFERENCEAPINAME   = NAMESPACEPREFIX + 'LocationReference__c'; //AT-3174
    public static string  LOCATIONIDAPINAME          = 'Id';
    public static string  LOCATIONNAMEAPINAME        = 'Name';
    public static string  LOCATIONADDRESSAPINAME     = NAMESPACEPREFIX + 'Address__c';
    public static string  LOCATIONCOUNTRYAPINAME     = NAMESPACEPREFIX + 'Country__c';
    public static string  LOCATIONVOIDLOCATIONAPINAME= NAMESPACEPREFIX + 'VoidLocation__c';
    
    
    public static string  LOCATIONOCCUPENTAPINAME    = NAMESPACEPREFIX + 'LocationOccupant__c';
    public static string  SUPPLYPOINTAPINAME         = NAMESPACEPREFIX + 'SupplyPoint__c';
    public static string  AVAILABLESRVAPINAME        = NAMESPACEPREFIX + 'AvailableService__c';
    public static string  AVAILABLEBUNDLEAPINAME     = NAMESPACEPREFIX + 'AvailableBundle__c';
    public static string  AVAILABLESRVITEMAPINAME    = NAMESPACEPREFIX + 'AvailableServiceItem__c';
    public static string  ACCOUNTAPINAME             = 'Account';
    public static string  SUPPOINTDEVICESRVAPINAME   = NAMESPACEPREFIX + 'SupplyPointDeviceService__c';   
    public static string  CONTRACTAPINAME            = NAMESPACEPREFIX + 'BillingContract__c';  
    public static string  SERVICEAPINAME             = NAMESPACEPREFIX + 'Service__c';   // Dependra - Added on 5-Dec-2017
    
    // 04/Oct/2017 -- Shivangi Gaur -- Added constant "MASTERRECORDTYPE" to be used in HH customization controllers
    public static string  MASTERRECORDTYPE = 'Master';
    
    // 21 Nov 2017, Shivangi Gaur - Contract Billing Method value
    public static final String CONTRACTBILLINGMETHOD = 'Bill On Contract Frequency no Top Up';
    
    // 22 Nov 2017, Shivangi Gaur - Constants for CuAp_SelectContractCtrlr class
    public static final String CONTRACTSTARTDATELABEL = 'Contract Start Date';
    public static final String CONTRACTENDDATELABEL   = 'Contract End Date';
    public static final String STARTDATELABEL         = 'Start Date';
    public static final String ENDDATELABEL           = 'End Date';
    public static final String STATUSACTIVE           = System.Label.GlAp_ContractStatusActive;
    public static final String CONTRACTNAME           = 'Name';
    public static final String CONTRACTCUSTOMERNAME   = NAMESPACEPREFIX + 'AccountName__c';
    public static final String CONTRACTSTATUS         = NAMESPACEPREFIX + 'Status__c';
    public static final String CONTRACTSTARTDATE      = NAMESPACEPREFIX + 'ContractStartDate__c';
    public static final String CONTRACTENDDATE        = NAMESPACEPREFIX + 'ContractEndDate__c';
    public static final String CONTRACTSUPPRESSED     = NAMESPACEPREFIX + 'Suppressed__c';

    // 24 Nov 2017, Satish Nair - Constants for CuAp_SelectBundleCtrlr
    //public static final String BUNDLENAME   = NAMESPACEPREFIX + 'BundleName__c'; --AT-3174
    public static final String SUPPLYPTNAME = 'Name';
    //public static final String SERVTYPENAME = NAMESPACEPREFIX + 'ServiceTypesRef__c';--AT-3174
    public static final String AVLSRVITEMS  = 'Available Service Items';
    public static final String FIELDTYPE    = 'text';
    
     //30 Nov 2017, Dependra Singh Constants for CuAp_NewBillingAddressPageCtlr class -
    
    public static final String BILLINGADDRESSAPINAME    = NAMESPACEPREFIX + 'BillingAddress__c';
    public static final String BILLINGSTREETNAME        = NAMESPACEPREFIX + 'BillingStreet__c';
    public static final String BILLINGCITYAPINAME       = NAMESPACEPREFIX + 'BillingCity__c';
    public static final String BILLINGSTATEAPINAME      = NAMESPACEPREFIX + 'BillingState__c';
    public static final String BILLINGPOSTALCODEAPINAME = NAMESPACEPREFIX + 'BillingPostalCode__c';
    public static final String BILLINGCOUNTRYAPINAME    = NAMESPACEPREFIX + 'BillingCountry__c';
    public static final String STATUSAPINAME            = NAMESPACEPREFIX + 'Status__c';
    public static final String HOUSEHOLDBILLINGAPINAME  = NAMESPACEPREFIX + 'HouseholdBilling__c';
    public static final String CUSTOMERAPINAME          = NAMESPACEPREFIX + 'AccountName__c';
    
     // 05 December Dependra Singh Added New Constants for CuAp_NewBillingAddressPageCtlr class 
     public static final String SPLOCATIONAPINAME      = NAMESPACEPREFIX + 'Location__c';
     public static final String SERVICEENDDATEAPINAME  = NAMESPACEPREFIX + 'ServiceEndDate__c';
     public static final String SERVICECONTRACTAPINAME = NAMESPACEPREFIX + 'BillingContract__c';

    
    // 29 Nov 2017, Vandana Anshu - Constants for CuAp_SelectBundleCtrlr
    
    public static string  BILLITEMAPINAME          = NAMESPACEPREFIX + 'BillItem__c';  // Vandana - Added on 29-Nov-2017
    public static string  BILLSERVICETYPEAPINAME   = NAMESPACEPREFIX + 'BillServiceType__c';  // Vandana - Added on 1-Dec-2017
    public static final String BILLITMNAME         = 'Bill Items'; 
    public static final String BILLITEMNAMELABEL   = 'Bill Item Name';    
    public static final String FROMLABEL           = 'From';
    public static final String BILLTOLABEL         = 'To';
    public static final String BILLITMAMOUNT       = 'Billed Amount';
    public static final String BILLITEMAMOUNTLABEL = 'Amount';
    public static final String BILLITEMNAME        = 'Name';
    public static final String BILLITEMFROM        = NAMESPACEPREFIX + 'StartDate__c';
    public static final String BILLITEMTO          = NAMESPACEPREFIX + 'EndDate__c';
    public static final String BILLITEMAMOUNT      = NAMESPACEPREFIX + 'BilledAmount__c';
    public static final string BILLSERVTYPENAME    = 'Name';
    public static final String DATEFIELDTYPE       = 'date';
    public static final String BILLSERVICETYPE     = NAMESPACEPREFIX + 'BillServiceType__c ';
    
    // 06 Dec 2017, P Dixon - status key names for Move In/Out wizard component status attribute - these need to match with the javascript controller
    public static final String IS_HH_ACCOUNT             = 'isHHAccount';
    public static final String IS_STALE_ACCOUNT          = 'isStaleAccount';
    public static final String HAS_CONTRACT              = 'hasContract';
    public static final String HAS_MEASURED_SUPPLY_POINT = 'hasMeasuredSupplyPoint';
    
    // 19 Dec 2017, P Dixon - service type names (to match created records)
    public static final String SERVICE_TYPE_SUNDRY = 'Sundry';

    // 12 Dec 2017, Tarun Gupta - Constants for Select Service Page CuAp_SelectServicesPageCtrlr
    public static final String AVAILSERVICENAME = 'Name';
    public static final String AVAILSERVICETYPE = NAMESPACEPREFIX + 'ServiceType__c';
    public static final String AVAILSUPPLYPOINT = NAMESPACEPREFIX + 'SupplyPoint__c';
    
    // 12 Dec 2017, Ashish Tiwari - Constants for Select Move In Date Page CuAp_MoveInDatePageCtrlr
    public static final String LOCATIONOCCUPANTACCOUNT   = NAMESPACEPREFIX + 'Account__c';
    public static final String LOCATIONOCCUPANTSTARTDATE = NAMESPACEPREFIX + 'StartDate__c';
    public static final String LOCATIONOCCUPANTENDDATE   = NAMESPACEPREFIX + 'EndDate__c';
    public static final String LOCATIONOCCUPANTACTIVE    = NAMESPACEPREFIX + 'Active__c';
    
    public static final String LOCATIONOCCUPANTSTARTDATEOLDLABEL = 'Start Date';
    public static final String LOCATIONOCCUPANTSTARTDATENEWLABEL = 'Move In Date';
    public static final String LOCATIONOCCUPANTENDDATEOLDLABEL   = 'End Date';
    public static final String LOCATIONOCCUPANTENDDATENEWLABEL   = 'Move Out Date';   
    public static final String LOCATIONOCCUPANTLOCATION          = NAMESPACEPREFIX + 'Location__c';
    
    public static final String LOCATIONNAME          = 'Name';
    public static final String LOCATIONADDRESS       = NAMESPACEPREFIX + 'Address__c';
    public static final String LOCATIONID            = 'Id';
    public static final String FLAGTRUE              = 'True';
    public static final String FLAGFALSE             = 'False';
    public static final String SOQLCONDITION         = ' AND ((' + NAMESPACEPREFIX + 'StartDate__c <=TODAY AND' + ' ' + NAMESPACEPREFIX + 'EndDate__c=Null) OR (' + NAMESPACEPREFIX + 'StartDate__c <=TODAY AND' + ' ' + NAMESPACEPREFIX + 'EndDate__c>TODAY) OR (' + NAMESPACEPREFIX + 'StartDate__c >TODAY))';
    public static final String ACCOUNTRECORDTYPE     = 'HouseholdAccount';
    public static final String INITIALFORPICKLIST    = 'Select Type';
    public static final String LOCATIONOCCUPANTAPI   = NAMESPACEPREFIX + 'LocationOccupant__c';
    public static final String OCCUPANCYTYPEAPI      = NAMESPACEPREFIX + 'OccupancyType__c';
    public static final String LOCATIONADDRESSREF    = 'Location Ref';
    public static final String LOCATIONSEARCHCITY    = 'City';
    public static final String LOCATIONSEARCHCITYAPI = NAMESPACEPREFIX + 'City__c';
    public static final String LOCATIONSEARCHSTREET  = 'Street';
    
    public static final String LOCATIONSEARCHSTREETAPI  = NAMESPACEPREFIX + 'Street__c';
    public static final String LOCATIONSEARCHSTATE      = 'State/Province';
    public static final String LOCATIONSEARCHSTATEAPI   = NAMESPACEPREFIX + 'State__c';
    public static final String LOCATIONSEARCHZIP        = 'Zip/Postal Code';
    public static final String LOCATIONSEARCHZIPAPI     = NAMESPACEPREFIX + 'PostalCode__c';
    public static final String LOCATIONSEARCHCOUNTRY    = 'Country';
    public static final String LOCATIONSEARCHCOUNTRYAPI = NAMESPACEPREFIX + 'Country__c';
    
    public static final String OPERATIONEQUALS      = System.Label.CuAp_FilterOperationEquals;
    public static final String OPERATIONNOTEQUALSTO = System.Label.CuAp_FilterOperationNotEqual;
    public static final String OPERATIONCONTAINS    = System.Label.CuAp_FilterOperationContains;
    public static final String OPERATIONNOTCONTAINS = System.Label.CuAp_FilterOperationDoesNotContain;
    public static final String OPERATIONIN          = 'IN';
    public static final String OCCUPANCYTYPE        = 'Landlord';
    
        // 12 Dec 2017, Shivangi Gaur - Constants for CuAp_HHCustomerController class
    public static final String ACCTYPE             = 'Type';
    public static final String ACCMOBILE           = NAMESPACEPREFIX + 'Mobile__c';
    public static final String ACCEMAIL            = NAMESPACEPREFIX + 'Email__c';
    public static final String ACCBILLSTREET       = 'BillingStreet';
    public static final String ACCBILLCITY         = 'BillingCity';
    public static final String ACCBILLSTATE        = 'BillingState';
    public static final String ACCBILLCOUNTRY      = 'BillingCountry';
    public static final String ACCBILLZIP          = 'BillingPostalCode';
    public static final String ACCBIRTHDATE        = NAMESPACEPREFIX + 'DateofBirth__c';
    public static final String ACCMAILOPTOUT       = NAMESPACEPREFIX + 'MailOptOut__c';
    public static final String ACCPASSWORD         = NAMESPACEPREFIX + 'ConsiderationPassword__c';
    //public static final String ACCSOCIALRATE       = NAMESPACEPREFIX + 'SocialRate__c'; --AT-3174
    public static final String ACCPREFERREDCONTACT = NAMESPACEPREFIX + 'PreferredContactMethod__c';
    public static final String ACCSHIPSTREET       = 'ShippingStreet';
    public static final String ACCSHIPSTATE        = 'ShippingState';
    public static final String ACCSHIPCITY         = 'ShippingCity';
    public static final String ACCSHIPCOUNTRY      = 'ShippingCountry';
    public static final String ACCSHIPZIP          = 'ShippingPostalCode';
    public static final String ACCPHONE            = 'Phone';
    public static final String ACCNOMINEE          = NAMESPACEPREFIX + 'Nominee__c';
    public static final String ACCNOMINEEDETAILS   = NAMESPACEPREFIX + 'NomineeContactDetails__c';
    public static final String CONSALUTATION       = 'Salutation';
    public static final String CONFIRSTNAME        = 'FirstName';
    public static final String CONLASTNAME         = 'LastName';
    public static final String CONACCID            = 'AccountId';
    public static final String CONMOBILE           = 'MobilePhone';
    public static final String CONEMAIL            = 'Email';
    // public static final String CONTYPE             = NAMESPACEPREFIX + 'ContactType__c'; // AT-3174
    public static final String ACCURLPREFIX        = '001';
    public static final String DUPLICATERESP       = 'Duplicates detected on following accounts: ';
    
    public static final String SPACE = ' ';
    
    // 18th December - Satish Nair - Adding the constants for screen 5 Move in Wizard
    public static final String SRVITEMTYPENAME = 'Name';
    public static final String SRVITEMTYPE     = NAMESPACEPREFIX + 'ServiceItemType__c';
    
    // 19 Dec 2017, Tarun Gupta - Constants for Device Exchange Page LoAp_EnterReadingPageCtrlr
    // SerialNo__c,DeviceType__c,DeviceReference__c,Digit__c,DeviceType__r.Name,DeviceType__r.DeviceSizeName__c
    // Name,ServiceType__r.Name,SupplyPointDevice__r.Name,SupplyPointDevice__r.InstallationDate__c,SupplyPointDevice__r.SupplyPoint__c
    public static final String SERIALNO    = NAMESPACEPREFIX + 'SerialNo__c';
    public static final String DEVICETYPE  = NAMESPACEPREFIX + 'DeviceType__c';
    //public static final String DEVICEREF   = NAMESPACEPREFIX + 'DeviceReference__c'; --AT-3174
    public static final String DEVICEDIGIT = NAMESPACEPREFIX + 'Digit__c';      
    public static final String SPDSNAME    = 'Name';        
    public static final String OBJECTNAME  = NAMESPACEPREFIX + 'Reading__c';      
    public static List<String> FIELDNAME   = new List<String>{ NAMESPACEPREFIX + 'ReadingSource__c', NAMESPACEPREFIX + 'ReadingMethod__c' ,NAMESPACEPREFIX + 'ReadingType__c',NAMESPACEPREFIX + 'BillableType__c'};      
    
    // 19 Dec 2017, Mohit Tayal - Constants for Device Exchange Page LoAp_SearchDevicePageCtrlr
    public static final String DEBTRECOVERYPROFILE = NAMESPACEPREFIX + 'DebtRecoveryProfile__c';
    public static final String MANUFACTURER        = NAMESPACEPREFIX + 'Manufacturer__c';
    public static final String ACTDEVICEREADING    = NAMESPACEPREFIX + 'ActualDeviceReading__c';
    public static final String READINGTYPE         = NAMESPACEPREFIX + 'ReadingType__c';
    public static final String REMOVALDATE         = NAMESPACEPREFIX + 'RemovalDate__c';
    
    // 21 Dec 2017, Tarun Gupta - Constants for Create New Reading Page BlAp_CreateNewReadingPageCtrlr
    // DeviceReference__c,ReadingDate__c,ActualDeviceReading__c,ReadingMethod__c,GrossConsumption__c,ReadingType__c,BillableType__c,Billed__c    
    public static final String READDATE         = NAMESPACEPREFIX + 'ReadingDate__c';            
    public static final String ACTUALDEVICEREAD = NAMESPACEPREFIX + 'ActualDeviceReading__c';            
    public static final String READMETHOD       = NAMESPACEPREFIX + 'ReadingMethod__c';            
    public static final String READTYPE         = NAMESPACEPREFIX + 'ReadingType__c';            
    public static final String BILLABLETYPE     = NAMESPACEPREFIX + 'BillableType__c';            
    public static final String BILLED           = NAMESPACEPREFIX + 'Billed__c';  
    
    //28 Dec 2017 Amit K. - Constant for New Reading Page LoAp_showDeviceReadingCtrlr
    //public static final String GROSSCONSUMPTION             = NAMESPACEPREFIX + 'GrossConsumption__c'; AT-2159
    public static final String NETCONSUMPTION               = NAMESPACEPREFIX + 'NetConsumption__c';
    public static final String ALGORITHMTYPE                = NAMESPACEPREFIX + 'AlgorithmType__c';
    public static final String BILLSERVICETYPETOSERVICETYPE = NAMESPACEPREFIX + 'BillServiceType__r.' + NAMESPACEPREFIX + 'ServiceType__c';
    public static final String MEASUREDBILLING              = 'Measured Billing';
    
    //03 Jan 2018 Ankit Gangwani - Constants for CuAp_SetupInstalments
    public static final String INSTALMENTOBJECT         = NAMESPACEPREFIX + 'Instalment__c';
    public static final String INSTALMENTNUMBER         = NAMESPACEPREFIX + 'InstalmentNumber__c';
    public static final String INSTALMENTNUMBERLABEL    = 'Instalment #';
    public static final String INSTALMENTDUEDATE        = NAMESPACEPREFIX + 'InstalmentDueDate__c';
    public static final String INSTALMENTDUEDATELABEL   = 'Instalment Date';
    public static final String INSTALMENTAMOUNTDUE      = NAMESPACEPREFIX + 'InstalmentAmountDue__c';
    public static final String INSTALMENTAMOUNTDUELABEL = 'Amount';
    public static final String INSTALMENTTYPE           = NAMESPACEPREFIX + 'Type__c';
    public static final String INSTALMENTTYPELABEL      = 'Type';
    
    //25 Jan 2018 Ankit Gangwani - Constants for CuAp_ManageDiscountsCtrlr
    public static String LOCATIONAPINAMELABEL     = 'Location(s)';
    public static String SUPPLYPOINTNAMELABEL     = 'Supply Point(s)';
    public static String SERVICETYPELABEL         = 'Service Type';
    public static String SERVICEITEMTYPELABEL     = 'Service Item Type';
    public static String OVERRIDEDISCOUNTLABEL    = 'Override Discount';
    public static String OLDSTARTDATEAPINAME      = 'Old_Start_Date';
    public static String OLDSTARTDATELABEL        = 'Old Start Date';
    public static String DISCOUNTTYPELABEL        = 'Discount Type';
    public static String PERCENTAGEDISCOUNTLABEL  = 'Percentage Discount';
    public static String FIXEDDISCOUNTLABEL       = 'Fixed Discount';
    public static String FREQUENCYLABEL           = 'Frequency';
    public static String OVERRIDEDISCOUNT         = 'Override_Discount';
    public static String OLDSTARTDATE             = 'Old_Start_Date';
    
    
    //05 Jan 2018 Amit K. - Constants for BlIn_PDFXMLDefinition
    public static final String BILL              = NAMESPACEPREFIX + 'Bill__c';
    public static final String ACCOUNT           = NAMESPACEPREFIX + 'Account__c';// AT-3174
    public static final String CONTRACTNUMBER    = NAMESPACEPREFIX + 'BillingContract__c';
    public static final String BILLNAME          = 'Name';
    public static final String BILLDATE          = NAMESPACEPREFIX + 'BillDate__c';    
    public static final String BILLFROM          = NAMESPACEPREFIX + 'StartDate__c';     
    public static final String BILLTO            = NAMESPACEPREFIX + 'EndDate__c';     
    public static final String BILLEDAMOUNT      = NAMESPACEPREFIX + 'BilledAmount__c';    
    public static final String TOTALDUE          = NAMESPACEPREFIX + 'TotalDue__c';    
    public static final String SERVICETYPENAME   = NAMESPACEPREFIX + 'ServiceType__r.Name';     
    public static final String TOTALBILLEDAMOUNT = NAMESPACEPREFIX + 'TotalBilledAmount__c';    
    public static final String SERVICEITEMNAME   = NAMESPACEPREFIX + 'ServiceItem__r.Name';

    public static final String SERVICEITEMTOSERVICEITEMTYPENAME     = NAMESPACEPREFIX + 'ServiceItem__r.' + NAMESPACEPREFIX + 'ServiceItemType__r.Name';    
    public static final String BILLSERVICETYPETOSERVICEITEMTYPENAME = NAMESPACEPREFIX + 'BillServiceType__r.' + NAMESPACEPREFIX + 'ServiceType__r.Name';   
    
    public static final String VOLUMEUSED                 = NAMESPACEPREFIX + 'VolumeUsed__c';     
    public static final String NUMBEROFDAYS               = NAMESPACEPREFIX + 'NumberOfDays__c';
    public static final String RATEBANDRATE               = NAMESPACEPREFIX + 'RateBand__r.' + NAMESPACEPREFIX + 'Rate__c';
    public static final String RATERETAILAMOUNT           = NAMESPACEPREFIX + 'Rate__r.' + NAMESPACEPREFIX + 'RetailAmount__c';
    public static final String RATEWHOLESALEAMOUNT        = NAMESPACEPREFIX + 'Rate__r.' + NAMESPACEPREFIX + 'WholesaleAmount__c';
    public static final String READINGACTUALDEVICEREADING = NAMESPACEPREFIX + 'Reading__r.' + NAMESPACEPREFIX + 'ActualDeviceReading__c';
    public static final String READINGTODEVICEREFSERIALNO = NAMESPACEPREFIX + 'Reading__r.' + NAMESPACEPREFIX + 'Device__r.' + NAMESPACEPREFIX + 'SerialNo__c';//AT-3174
    public static final String READINGGROSSCONSUMPTION    = NAMESPACEPREFIX + 'Reading__r.' + NAMESPACEPREFIX + 'GrossConsumption__c';
    
    public static final String READING                  = NAMESPACEPREFIX + 'Reading__r.' + NAMESPACEPREFIX + 'Reading__c';
    public static final String READINGREADTYPE          = NAMESPACEPREFIX + 'Reading__r.' + NAMESPACEPREFIX + 'ReadingType__c';
    public static final String ACCOUNTNAME              = 'Name';
    public static final String ACCOUNTREF               = NAMESPACEPREFIX + 'AccountReference__c';
    public static final String FAX                      = 'Fax';
    public static final String WEBSITE                  = 'Website';
    // public static final String VATREGNO                 = NAMESPACEPREFIX + 'VATRegistrationNumber__c'; AT-3174
    public static final String BILLINGFREQ              = NAMESPACEPREFIX + 'BillingFrequency__c';
    public static final String NUMBEROFOCCUPIER         = NAMESPACEPREFIX + 'NumberOfOccupiers__c';
    public static final String ACCNAME                  = NAMESPACEPREFIX + 'Account__r.Name';
    public static final String PRIMARY                  = NAMESPACEPREFIX + 'Primary__c';
    public static final String SHOWBILL                 = NAMESPACEPREFIX + 'ShowOnBill__c';
    public static final String LOCOCCNAME               = 'Name';
    public static final String PAYMENTPLAN              = NAMESPACEPREFIX + 'PaymentPlan__c';
    public static final String CONTRACTORDER            = NAMESPACEPREFIX + 'BillingContract__c'; //AT-3174
    public static final String PAYMENTFREQ              = NAMESPACEPREFIX + 'PaymentFrequency__c';
    public static final String PAYMENTPLANTYPENAME      = NAMESPACEPREFIX + 'PaymentPlanType__r.Name';
    public static final String PLANAMOUNT               = NAMESPACEPREFIX + 'TotalInstalmentAmount__c';
    public static final String STARTDATE                = NAMESPACEPREFIX + 'StartDate__c';
    public static final String DEVICESERIALNO           = NAMESPACEPREFIX + 'Device__r.' + NAMESPACEPREFIX + 'SerialNo__c';
    public static final String SUPPLYPOINTLOCPOSTALCODE = NAMESPACEPREFIX + 'SupplyPoint__r.' + NAMESPACEPREFIX + 'Location__r.' + NAMESPACEPREFIX + 'PostalCode__c';
    public static final String SUPPLYPOINTID            = NAMESPACEPREFIX + 'SupplyPoint__r.Id';
    
     // 11/Jan/2018 -- Ashish Tiwari -- Added constant for CuAp_SuppressionWizardComponentCtrlr
    public static final string  FIELDAPISUPPRESSIONREASON               = NAMESPACEPREFIX + 'SuppressionReason__c';
    public static final string  FIELDAPISUPPRESSIONSTARTDATE            = NAMESPACEPREFIX + 'SuppressionStartDate__c';
    public static final string  FIELDAPISUPPRESSIONENDDATE              = NAMESPACEPREFIX + 'SuppressionEndDate__c';
    public static final string  FIELDAPISUPPRESSIONBILLPRINT            = NAMESPACEPREFIX + 'SuppressBillPrint__c';
    public static final string  FIELDAPISUPPRESSIONRECOVERYNOTICE       = NAMESPACEPREFIX + 'SuppressRecoveryNotice__c';
    public static final string  FIELDAPICONTACTNAME                     = 'Name';
    public static final string  FIELDAPICONTACTSTATUS                   = NAMESPACEPREFIX + 'Status__c';
    public static final string  FIELDAPICONTACTBILLINGFREQUENCY         = NAMESPACEPREFIX + 'BillingFrequency__c';
    public static final string  FIELDVALUESUPPRESSIONENDDATE            = 'Suppression End Date';
    public static final string  FIELDSHOWVALUESUPPRESSIONENDDATE        = 'End Date';
    public static final string  FIELDVALUESUPPRESSIONSTARTDATE          = 'Suppression Start Date';
    public static final string  FIELDSHOWVALUESUPPRESSIONSTARTDATE      = 'Start Date';
    public static final string  FIELDVALUESUPPRESSIONREASON             = 'Suppression Reason';
    public static final string  FIELDSHOWVALUESUPPRESSIONREASON         = 'Reason';
    public static final string  FIELDVALUESUPPRESSIONBILLPRINT          = 'Suppress Bill Print';
    public static final string  FIELDSHOWVALUESUPPRESSIONBILLPRINT      = 'Suppress Bill';
    public static final string  FIELDVALUESUPPRESSIONRECOVERYNOTICE     = 'Suppress Recovery Notice';
    public static final string  FIELDSHOWVALUESUPPRESSIONRECOVERYNOTICE = 'Suppress Recovery';
    
    //11 Jan 2018 Amit K. - Constants for CuAp_SelectDiscountApplyCtrlr
    public static final string DISCOUNTTYPENAME         = 'Name';
    public static final string RECURRENCEFREQUENCY      = NAMESPACEPREFIX + 'RecurrenceFrequency__c';
    public static final string PERCENTAGEDISCOUNTAMOUNT = NAMESPACEPREFIX + 'PercentageDiscountAmount__c';
    public static final string ABSOLUTEDISCOUNTAMOUNT   = NAMESPACEPREFIX + 'AbsoluteDiscountAmount__c';
    public static final string FIXEDDISCOUNTAMOUNTLABEL = 'Fixed Discount Amount';    
    public static final string DISCOUNTTYPE             = NAMESPACEPREFIX + 'Type__c';
    public static final string DISCOUNTTYPEAPI          = NAMESPACEPREFIX + 'DiscountType__c';
    public static final string SERVICECONTRACT          = NAMESPACEPREFIX + 'Service__r.' + NAMESPACEPREFIX + 'BillingContract__c';
    public static final String OPERATIONGREATERTHAN     = 'Greater Than';
    public static final String OPERATIONLESSTHAN        = 'Less Than';
    public static final String DISCOUNTPERCENTAGE       = 'Percentage';
    public static final String DISCOUNTFIXED            = 'Fixed';
    public static final String FIELDAPIRECURRING        = NAMESPACEPREFIX + 'Recurring__c';
    public static final String FIELDAPICANBEOVERRIDDEN  = NAMESPACEPREFIX + 'CanbeOverridden__c';
    public static List<String> DISCOUNTTYPEPICKLIST     = new List<String>{ NAMESPACEPREFIX + 'Type__c'};
    // 12/Jan/2018 -- Ashish Tiwari -- Added constant for CuAp_AgreedRatePageCtrlr
    public static final string FIELDAPIAGREEDRATESVALUE           = NAMESPACEPREFIX + 'Value__c';
    public static final string FIELDAPIAGREEDRATESSTARTDATE       = NAMESPACEPREFIX + 'StartDate__c';
    public static final string FIELDAPIAGREEDRATESENDDATE         = NAMESPACEPREFIX + 'EndDate__c';
    public static final string FIELDAPIAGREEDRATESLEADYEAR        = NAMESPACEPREFIX + 'LeapYear__c';
    public static final string FIELDAPISERVICEITEMSERVICETYPE     = NAMESPACEPREFIX + 'ServiceType__c';
    public static final string FIELDAPISERVICEITEMSERVICEITEMTYPE = NAMESPACEPREFIX + 'ServiceItemType__c';
    public static final string FIELDAPISERVICEITEMSUPPLYPOINT     = NAMESPACEPREFIX + 'Supply_Point__c';
    public static final string FIELDAPISERVICEITEMLOCATION        = NAMESPACEPREFIX + 'Location__c';
    public static final string FIELDAPIRATESRETAILAMOUNT          = NAMESPACEPREFIX + 'RetailAmount__c';
    public static final string OBJECTAPIRATES                     = NAMESPACEPREFIX + 'Rate__c';
    public static final string FIELDVALUEAGREEDRATESVALUE         = 'Value';
    public static final string FIELDSHOWVALUEAGREEDRATESVALUE     = 'Agreed Rate';
    
    //25 Jan 2018 Swati Mathur - Constants for LoAp_SelectLocationDevicePageCtrlr
    public static final string INSTALLATIONDATE = NAMESPACEPREFIX + 'InstallationDate__c';
    // public static final string DEVICETYPENAME   = NAMESPACEPREFIX + 'DeviceTypeName__c'; // AT-3174
    //public static final string DEVICESIZE       = NAMESPACEPREFIX + 'DeviceSizeName__c'; // AT-3174
    public static final string SERVTYPNAME      = 'Name';
    public static final string TYPEOFDEVICE     = 'Device Type';
    public static final string SERVICETYPE      = 'Service Type';
    // Constans for AdditionalBillerPage
    public static final string ACCDISPLAYFIELDS = 'Id,Name,' + NAMESPACEPREFIX + 'Email__c,' + NAMESPACEPREFIX + 'Mobile__c';
    
    public static final String LOCATIONOCCUPANTOCCTYPEOLDLABEL = 'Occupancy Type';
    public static final String NUMOFOCCUPIEROLDLABEL = 'Number of Occupiers';

    // Sudhir - 9/3/2018
    public static final string MOVEIN               = 'Move In' ;
    public static final string MOVEOUT              = 'Move Out' ;
    
    public static final string CUSTOMERREADING      = 'Customer Reading' ;
    public static final string SERVICETYPELBL       = 'Service Type' ;
    public static final string ESTIMATE             = 'Estimate';
    public static final string AMEND                = 'Amend' ;
    public static final string TEXT                 = 'text' ;
    public static final string ACTUALREADINGLABEL   = 'Actual Device Reading' ;
    public static final string READINGMETHODLABEL   = 'Reading Method' ;
    public static final string READINGDATELABEL     = 'Reading Date' ;
    public static final string REGULAR              = 'Regular' ;
    public static final string TRIPPEDLABEL         = 'Tripped' ;    //AT-3420
    public static final string SERVICEITEMCHARGE    = 'Service Item Charge' ;
    public static final string BILLABLETYPELABEL    = 'Billable Type' ; // AT-3388 (Core-8b)
    public static final string NONBILLABLE          = 'Non Billable' ; // AT-3388 (Core-8b)
    
    // Sudhir - AT-2480 - Move In/Move Out BillEvent constants
    public static final String  PENDINGBILLEVENTSTATUS      =   'Pending' ;
    
    // Ankit - AT-3096 - Stepped Tairff Process constants
    public static final String  SERVICETYPEFIELD        =   'ServiceType' ;
    public static final String  DURATIONINMONTHSFIELD   =   'DurationInMonths';
    public static final String  DURATIONINMONTHSLABEL   =   'Duration In Months';
    public static final String  LOCAITONFIELDANDLABEL   =   'Locations';
    public static final String  ADDRESSLABEL            =   'Address';
    public static final String  SERVICELABEL			= 	'Service';
    
    // Sudhir - AT-2463 - Manage Reading Import Error Lightning Component    
    public static final String  DEVICESETIALNUMBER      =   'Device Serial Number';
    public static final String  DEVICEMANUFACTURER      =   'Device Manufacturer';
    public static final String  LOCATIONADDRESSLABEL    =   'Location Address';
    public static final String  OVERRIDEREADINGAPINAME  =   'Override_Reading';
    public static final String  OVERRIDEFIELDLABEL      =   'Override Reading';
    public static final String  OVERRIDEVALUEAPINAME    =   'Override_Value';    
    public static final String  OVERRIDEVALUELABEL      =   'Override Value';
    public static final String  REQUESTREADINGAPINAME   =   'Request_Reading';
    public static final String  REQUESTREADINGLABEL     =   'Request Reading';
    public static final String  REQUESTEDDATEAPINAME    =   'Requested_Date';    
    public static final String  REQUESTEDDATELABEL      =   'Requested Date';
    
    //09 Oct 2018  Vivek AT-3855
    public static final String  HIGHREADINGAPINAME   =   'High Reading';
    
    //UL-21, Ankit, 21/02/2019
    public static final String CHECKBILLINGTOLERANCE = 'Check Billing Tolerances';
    
    // 12 Jun 2018, P Dixon - Button Attribute Display Statuses
    public static final String BUTTON_ACTIVE = 'ACTIVE';
    public static final String BUTTON_INACTIVE = 'INACTIVE';
    public static final String BUTTON_DISABLED = 'DISABLED';
    
    // 01 Jul 2018, P Dixon - this lookup field to BatchRequestQueue__c must be implemented by ALL staging table objects
    public static final String STAGING_TABLE_LOOKUP_FIELD = GlUt_NamespacePrefix.getNamespacePrefix() + 'BatchRequestQueue__c';
    
    // 01 Jul 2018, P Dixon - name of Org Wide Email for batch process emails
    public static final String BATCH_PROCESS_EMAIL_SENDER = 'Batch Process Notification';
    
    public static final String OCCUPANTSLABEL       = 'Occupants';
    public static final String BILLINGCONTRACTLABEL = 'Billing Contract';
	public static final String REFERENCEFIELDTYPE   = 'reference';
    
    // 20 August 2018, Ankit - Manage Service Wizard
    public static final String DEVICELABEL = 'device';
    public static final String DEVICEDIGITLABEL = 'deviceDigit';
    public static final String SUPPLYPOINT = 'SupplyPoint';
    public static final String SUPPLYPOINTLABEL = 'Supply Point';
    
    public static final String AVAILABLESERVICESLABEL = 'Available Services';//Swati, 28-08-2018 , AT-3174
    public static final String AVAILABLEBUNDLELABEL = 'Available Bundle';//Swati 29-08-2018 , AT-3174
    
    public static final String PAYMENTCARD = 'Payment Card';//CuAp_NewPaymentCardRequestCtrlr
    
    public static final string DELETEBUTTON             = 'Delete';
    public static final string DISCOUNTPERCENTAGEOVERRIDE = 'Discount Percentage Override';
    public static final string DISCOUNTAMOUNTOVERRIDE = 'Discount Amount Override';
    public static final String DISCOUNTPERDAYOVERRIDE = 'Discount Per Day Override';
    
    // 11 Dec 2018, Ankit Gangwani - Concession (Discount Wizard)
    public static final String RECORDTYPEAPINAME = 'RecordType';
    public static final String RECORDTYPELABEL = 'Record Type';
    //Sudhir: AT-4849__Real Time Concession Validation__AU3
    public static final String Y 							=  'Y';
    public static final String N 							=  'N';
    public static final String UC 							=  'UC';
    public static final String YES 							=  'Yes';
    public static final String NO 							=  'No';
    public static final String UNABLE_TO_CONFIRM 			=  'Unable to Confirm';
    public static final String CONCESSION_TYPE_REALTIME 	=  'Real-Time';
    
    //AT-5259, Ankit, 27/02/2019
    public static final String DISCOUNT_RENEWALS_SUCCESS	= 'DiscountRenewalsSuccess';
    public static final String DISCOUNT_RENEWALS_FAILURES	= 'DiscountRenewalsFailures';
       
}