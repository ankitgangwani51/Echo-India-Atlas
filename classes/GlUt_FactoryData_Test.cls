/******************************************************************************
@author        Accenture: Vivek Chauhan
@date          5 Sep 2017
@description   This is global class which will be used to created data of various object for test classes.
@version    
@Accenture Sucharu-- Date 6 Sept'17 -- Added method createUser for user creation
@Accenture Shivangi -- 24-10-2017 -- Updated method CreateReading() with actual reading data
@Accenture Sucharu -- 26-10-2017 -- Changing Name of the class as per Coding Standard
@Accenture Shivangi -- 31-10-2017 -- Added method CreateSupplyPointDeviceService().
@Accenture Sucharu -- 01-11-2017-- Added mandatory fields in CreateReading().

                                     Date not greater than today.
@Accenture Shivangi -- 02-11-2017 -- Updated method CreateSupplyPointDevices() to add Final Reading 
                                     and method CreateAvailableService() to remove Name field and
                                     method CreateAvailableBundle() to remove Name field and method
                                     CreateAvailableServiceItem() to remove Name field. 
@Accenture Shivangi -- 16-11-2017 -- Updated method CreateContract() for new values of field Debt Recovery Profile.
                                     Updated method CreateSupplyPointDevices() to make Removal Date blank for active SPD.
@Accenture Shivangi -- 04-12-2017 -- Added method CreateLocationOccupant() for location occupant creation.  
@Accenture Vandana --  11-12-2017 -- Added method createAutomationSetting  for GlUt_DisableAutomation__c.
@Accenture Shivangi -- 18-12-2017 -- Added methods createConsiderationType() and createConsideration(). 
@Echo Neha Rajput -- 17-12-2017 -- Added  methods createDiscountType() and createDiscountTypeitem().
@Echo Neha Rajput -- 06-02-2018 -- Modified method createPaymentPlanType().
@Echo Neha Rajput -- 17-02-2018 -- Added  methods createPaymentAllocationQueue().
@Echo Neha Rajput -- 06-03-2018 -- Added method createCase().
Revision    12 Feb 2018, P Dixon - removed NumberOfInstalments__c from Payment Plan 
Revision    04 Apr 2018, Tarun - Added method for Financial Control objects
Revision    12 Apr 2018, Sudhir - Added method for creating a Community User instance
Revision    10 May 2018, Neha - Added method for creating a Depot, Book & ReadTimetable
***************************************************************************************************************/
  @isTest
  public class GlUt_FactoryData_Test{
      private static final String USER_ALIAS = 'standt';
      private static final String USER_EMAIL = '@unitest.com';
      private static final String USER_UTF = 'UTF-8';
      private static final String USER_LNAME= 'UnitTest';
      private static final String USER_LAN_LOCALKEY= 'en_US';
      private static final String USER_TIMEZONEKEY= 'Europe/London';
      private static final String USER_PHONE = '1234567891';
      private static final String USER_MPHONE = '0111111111';
      @TestVisible private static final String PORTAL_PROFILE_NAME = SYSTEM.LABEL.CmAp_CommunityUserProfile ;    // Sudhir: AT-2167
      private static final String BANKACCOUNTNUMBER   = '12341234';    // AT-2891
      private static final String NAMEONACCOUNT = 'TEST';  
      
      /******************************************************************************
        @author        Echo: Sudhir Kumar
        @date          12 Mar 2019
        @param         String HerokuPostgresId, String InformationStatementId, String BillingContractId
        @description   Create AccrualBill object instance and return it.
      *******************************************************************************/
      public static AccrualBill__c createAccrualBill(String HerokuPostgresId, String InformationStatementId, String BillingContractId) {
          AccrualBill__c accrualBillObj = new AccrualBill__c(HerokuPostgresId__c = HerokuPostgresId, InformationStatement__c = InformationStatementId, BillingContract__c = BillingContractId) ;
          accrualBillObj.BilledAmount__c = 100 ;
          accrualBillObj.Type__c = 'Information Statement' ;
          return accrualBillObj ;
      }
      /******************************************************************************
        @author        Echo: Sudhir Kumar
        @date          12 Mar 2019
        @param         String HerokuPostgresId, String AccrualBilld, String RateId, String ServiceItemId
        @description   Create AccrualBillItem object instance and return it.
      *******************************************************************************/
      public static AccrualBillItem__c createAccrualBillItem(String HerokuPostgresId, String AccrualBilld, String RateId, String ServiceItemId) {
          AccrualBillItem__c accrualBillItemObj = new AccrualBillItem__c(HerokuPostgresId__c = HerokuPostgresId, AccrualBill__c = AccrualBilld, Rate__c = RateId, ServiceItem__c = ServiceItemId) ;
          accrualBillItemObj.BilledAmount__c    = 100 ;
          accrualBillItemObj.NetBilledAmount__c = 100 ;
          accrualBillItemObj.StartDate__c       = System.today() - 10 ;
          accrualBillItemObj.EndDate__c         = System.today() + 10 ;
          return accrualBillItemObj ;
      }
      
      /******************************************************************************
        @author        Echo: Sudhir Kumar
        @date          12 Mar 2019
        @param         String BillingContractId, String LocationId, String ServiceId, String TemplateMappingId
        @return        InformationStatement__c - infoObj
        @description   Create InformationStatement object instance and return it.
      *******************************************************************************/
      public static InformationStatement__c createInformationStatement(String BillingContractId, String LocationId, String ServiceId, String TemplateMappingId) {
          InformationStatement__c infoObj = new InformationStatement__c(BillingContract__c = BillingContractId, Location__c = LocationId, 
                                                                        SettlementDate__c = System.today() + 1,
                                                                        Service__c = ServiceId, TemplateMapping__c = TemplateMappingId) ;
          return infoObj ;
      }
    
  /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         string sName
  @return        Account - objAccount
  @description   Create Account  object instance and return it.
      *******************************************************************************/
  public static Account createAccount(string sName){
    Account objAccount = new Account(Name=sName,BillingStreet='testBillingStreet',BillingCity='testBillingCity',BillingState='testBillingState',
                                     BillingCountry='testBillingCountry',BillingPostalCode='testPostcode',ShippingStreet='testShippingStreet ',
                                     ShippingCity='testShippingCity',ShippingState='testShippingState',ShippingCountry='ShippingCountry',
                                     ShippingPostalCode='testPostCode');
    return objAccount;
  }
  
  /******************************************************************************
  @author        Echo: Sudhir Kumar
  @date          07 Sep 2018
  @param         list<PDFRequest__c> listPdfrequest
  @return        list<PDFGenerationResult__c>
  @description   Create list of PDFGenerationResult object instance and return it
  *******************************************************************************/
  public static list<PDFGenerationResult__c> createPDFGenerationResult(list<PDFRequest__c> listPdfrequest) {
      list<PDFGenerationResult__c> listPGR = new list<PDFGenerationResult__c>() ;
      for(Integer i = 0; i < listPdfrequest.size(); i++) {
          PDFGenerationResult__c objPDFGenerationResult = new PDFGenerationResult__c(DataXMLFileName__c = 'TestFileName' + String.valueOf(i), 
                                                                                     PDFRequest__c = listPdfrequest[i].Id, 
                                                                                     HerokuPostgresId__c = 'TestHerokuId123' + String.valueOf(i)) ;
          listPGR.add(objPDFGenerationResult) ;
      }
      return listPGR ;
  }
  
  /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         string sFirstName, string sLastName
  @return        Contact  - con
  @description   Create contact object instance and return it.
  *******************************************************************************/
  public static Contact createContact(string sFirstName, string sLastName){
    Contact con = new Contact(FirstName=sFirstName, LastName=sLastName);
    return con;
  }
  /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         string-sName,Account objAccount
  @return        Contract  - objContract
  @description   Create Contract object instance and return it.
  *******************************************************************************/
  public static BillingContract__c createContract(Account objAccount) {
    return createContract(null, objAccount);
  }
  public static BillingContract__c createContract(string sName,Account objAccount){
      BillingContract__c objContract = new BillingContract__c(AccountName__c =objAccount.id ,BillingFrequency__c='Monthly',
                                                              DebtRecoveryProfile__c='Profile 1');
      return objContract;
  }
      
  /******************************************************************************
  @author        Echo: Ankit Gangwani
  @date          14 Feb 2018
  @param         string-sName
  @return        Device Size - objDeviceSize  T
  @description   Create DeviceType__c  object instance and return it.
  *******************************************************************************/
  public static DeviceSize__c createDeviceSize(string sName){
    DeviceSize__c objDeviceSize = new DeviceSize__c (Name = sName);
    return objDeviceSize;
  }
   
  /******************************************************************************
  @author        Echo: Dependra Singh
  @date          18 Jan 2018
  @param         objDeviceType, strManufacturer, strUnitOfMeasure
  @return        DeviceType__c - objDeviceType
  @description   Create DeviceType__c  object instance and return it.
  *******************************************************************************/
  public static DeviceType__c createDeviceType(DeviceSize__c objDeviceSize, string strManufacturer, string strUnitOfMeasure){
    DeviceType__c objDeviceType = new DeviceType__c (DeviceSize__c=objDeviceSize.Id ,Manufacturer__c=strManufacturer,UnitOfMeasure__c=strUnitOfMeasure );
    return objDeviceType;
  }   
  
  /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         string-sName
  @return        Device__c - objDevice
  @description   Create Device__c object instance and return it.
  *******************************************************************************/
  public static Device__c createDevice(string sName, DeviceType__c objDeviceType){
    Device__c objDevice = new Device__c (DeviceType__c= objDeviceType.id,Digit__c=10,SerialNo__c = string.valueof(Math.round(Math.random()*1000)) );    
    return objDevice;
  }

 /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         string-sName
  @return        ServiceType__c- objServiceType
  @description   Create ServiceType__c object instance and return it.
  *******************************************************************************/
  public static ServiceType__c createServiceType(string sName){
    ServiceType__c objServiceType = new ServiceType__c(Name = sName,ServiceTypeDescription__c='testdescription');
    return objServiceType;
  }

 /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         String -sName,Device__c objDevice
  @return        Reading__c- objReading  
  @description   Create Reading__c object instance and return it.
  *******************************************************************************/
  public static Reading__c createReading(Device__c objDevice){
    Reading__c  objReading  = new Reading__c (Device__c =objDevice.id,ActualDeviceReading__c='9088767784',ReadingSource__c = 'Customer Reading',
                                              ReadingMethod__c = 'System Estimated',BillableType__c = 'Billable',ReadingDate__c = System.today());
    return objReading ;
  }

/******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         String -sName  
  @return        Location__c  - objLocation    
  @description   Create Location__c    object instance and return it.
  Revision:      13-Oct-2017   Accenture: Vandana Anshu 
                 Changing Location Type from 'Domestic' to 'Household'.
  *******************************************************************************/
  public static Location__c createLocation(string sZipcode){
    Location__c objLocation  = new Location__c(PostalCode__c= sZipcode,
    LocationType__c='Household',LocationSubType__c='Flat',Street__c='ABC');
    return objLocation;
  }

/******************************************************************************
  @author        ECHO: Mohit Tayal
  @date          01 Feb 2018
  @param         string sName
  @return        SupplyPointUsageType__c  - objSupplyPointUsageType
  @description   Create Supply Poin tUsage Type object instance and return it.
  *******************************************************************************/
  public static SupplyPointUsageType__c createSupplyPointUsageType(string sName){
    SupplyPointUsageType__c objSupplyPointUsageType = new SupplyPointUsageType__c(Name = sName);
    return objSupplyPointUsageType;
  }      
      
/******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         String -sName,Location__c objLocation  
  @return        SupplyPoint__c  - objSupplyPoint
  @description   Create SupplyPoint__c  object instance and return it.
  *******************************************************************************/
  public static SupplyPoint__c createSupplyPoint(Location__c objLocation, SupplyPointUsageType__c objSupplyPointUsageType){
    SupplyPoint__c objSupplyPoint  = new SupplyPoint__c(Location__c= objLocation.id, SupplyPointUsageType__c = objSupplyPointUsageType.id, 
                                                        Description__c='testsupplypoint');
    return objSupplyPoint;
  }
  
    
/******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         none  
  @return        Division__c - objDivision
  @description   Create Division__c object instance and return it.
  *******************************************************************************/
  public static Division__c createDivision(){
    Division__c objDivision  = new Division__c(ChargingArea__c= 'STW - Lower Severn',ChargingDivision__c='Lower Severn');
    return objDivision;
  }
  
  /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         String-sName
  @return        Division__c - objDivision
  @description   Create Division__c object instance and return it.
  *******************************************************************************/
  public static Wholesaler__c createWholesaler(String sName){
    Wholesaler__c  objWholesaler   = new Wholesaler__c (Name = sName);
    return objWholesaler;
  }
  /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         String-sName
  @return        AvailableService__c- objAvailableService   
  @description   Create AvailableService__c object instance and return it.
  @revision      MT - 22 Feb 2018 AT - 1872 Added Active__c while creating the new object
  *******************************************************************************/
  public static AvailableService__c createAvailableService(String sName ,Division__c objDivision,ServiceType__c objServiceType,
                                                           SupplyPoint__c objSupplyPoint,Wholesaler__c  objWholesalers){
                                                               
    AvailableService__c objAvailableService   = new AvailableService__c (Division__c = objDivision.id,ServiceType__c =objServiceType.id,
                                                                         SupplyPoint__c =objSupplyPoint.id,
                                                                         Wholesalers__c =objWholesalers.id, Active__c = TRUE);
    return objAvailableService;
  }
  
  /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         String-sName
  @return        Service__c - objService   
  @description   Create Service__c object instance and return it.
  *******************************************************************************/
  public static Service__c createService(BillingContract__c objContract,Reading__c objReading,ServiceType__c objServiceType,
                                         SupplyPoint__c objSupplyPoint,AvailableService__c objAvailableService){
    Service__c objService   = new Service__c(ServiceType__c =objServiceType.id,
                                             SupplyPoint__c =objSupplyPoint.id,
                                             AvailableService__c=objAvailableService.id,
                                             BillingContract__c=objContract.id );
    return objService;
  }
  
  /******************************************************************************
  @author        Accenture: Sucharu Gupta
  @date          06 Sep 2017
  @param         String,String,Id
  @return        User   
  @description   Used for creating the User
  *******************************************************************************/
    
    public static User createUser (String profileName, String uName,ID mgrId){
            UserRole r = [Select Id From UserRole limit 1 ]; //where Name = 'All Echo User'
            Profile prof = [select id from Profile where Name =:profileName LIMIT :1];
            User newUser = new User(alias = USER_ALIAS, 
                                    email=uName+USER_EMAIL, 
                                    emailencodingkey=USER_UTF,
                                    lastname=USER_LNAME,
                                    languagelocalekey=USER_LAN_LOCALKEY, 
                                    localesidkey=USER_LAN_LOCALKEY, 
                                    profileid = prof.Id, 
                                    timezonesidkey=USER_TIMEZONEKEY,
                                    username= uName+USER_EMAIL,
                                    isActive=true);
            if(mgrId != null){
                newUser.ManagerId = mgrId;
            }
            newUser.Phone = USER_PHONE;
            newUser.MobilePhone =USER_MPHONE; 
            return newUser;
                
    }
    
  /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         String-sName
  @return        ServiceItemFamily__c - objServiceItemFamily   
  @description   Create     ServiceItemFamily__c object instance and return it.
  *******************************************************************************/
  public static  ServiceItemFamily__c createServiceItemFamily(String sName,ServiceType__c objServiceType){
    ServiceItemFamily__c objServiceItemFamily  = new ServiceItemFamily__c(Name =sName,
                                                                          ServiceType__c=objServiceType.id,
                                                                          AlgorithmType__c='Measured Billing', 
                                                                          UoM__c='Annual'); // need to move 'Measured Billing' into a Constants Class
    return objServiceItemFamily;
  }
  
    /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         String-sName
  @return        ServiceItemType__c - objServiceItemType  
  @description   Create ServiceItemFamily__c object instance and return it.
  *******************************************************************************/
  public static     ServiceItemType__c createServiceItemType(String sName, ServiceItemFamily__c objServiceItemFamily,Division__c objDivision,
                                                             DeviceType__c  objDeviceType,Wholesaler__c  objWholesaler){
    ServiceItemType__c objServiceItemType  = new ServiceItemType__c(Name =sName,
                                                                    Division__c=objDivision.id,
                                                                    ServiceItemFamily__c=objServiceItemFamily.id,
                                                                    ServiceCompany__c=objWholesaler.id);
    return objServiceItemType;
  }
   /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         String-sName,ServiceType__c-objServiceType
  @return        Bundle__c - objBundle
  @description   Create     Bundle__c object instance and return it.
  *******************************************************************************/
  public static  Bundle__c createBundle(String sName,ServiceType__c objServiceType){
    Bundle__c objBundle  = new Bundle__c(Name =sName,ServiceType__c=objServiceType.id);
    return objBundle;
  }
  
     /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         String-sName,Bundle__c -objBundle,AvailableService__c -objAvailableService
  @return        AvailableBundle__c- objAvailableBundle
  @description   Create AvailableBundle__c object instance and return it.
  *******************************************************************************/
  public static  AvailableBundle__c createAvailableBundle(String sName,Bundle__c  objBundle,AvailableService__c  objAvailableService){
    AvailableBundle__c objAvailableBundle  = new AvailableBundle__c(Bundle__c =objBundle.id,AvailableService__c=objAvailableService.id);
    return objAvailableBundle;
  }
  
  
       /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         String-sName,Bundle__c -objBundle,AvailableService__c -objAvailableService
  @return        BundleItem__c - objBundleItem  
  @description   Create BundleItem__c object instance and return it.
  *******************************************************************************/
  public static  BundleItem__c createBundleItem(String sName,Bundle__c  objBundle,ServiceItemType__c objServiceItemType,ServiceItemFamily__c  objServiceItemFamily){
      BundleItem__c objBundleItem  = new BundleItem__c(Name =sName,Bundle__c =objBundle.id);
      if(objServiceItemFamily != null){
          objBundleItem.ServiceItemFamily__c = objServiceItemFamily.id;
      } else{
          objBundleItem.ServiceItemType__c = objServiceItemType.id;
      }
      return objBundleItem;
  }
  
   
  /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         String-sName,Bundle__c -objBundle,AvailableService__c -objAvailableService
  @return        AvailableServiceItem__c - objAvailableServiceItem
  @description   Create AvailableServiceItem__c  object instance and return it.
  *******************************************************************************/
  public static  AvailableServiceItem__c createAvailableServiceItem (String sName,BundleItem__c  objBundleItem,ServiceItemType__c objServiceItemType,
                                                                     AvailableBundle__c objAvailableBundle){
    AvailableServiceItem__c objAvailableServiceItem  = new AvailableServiceItem__c(AvailableBundle__c=objAvailableBundle.id,
                                                                                   BundleItem__c=objBundleItem.id, 
                                                                                   ServiceItemType__c = objServiceItemType.Id , 
                                                                                   StartDate__c = system.today());
    return objAvailableServiceItem ;
  }
  
  /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         String-sName,Bundle__c -objBundle,AvailableService__c -objAvailableService
  @return        ServiceItem__c - objServiceItem 
  @description   Create AvailableServiceItem__c  object instance and return it.
  *******************************************************************************/
  public static  ServiceItem__c createServiceItem (AvailableServiceItem__c objAvailableServiceItem,ServiceItemType__c objServiceItemType,Service__c objService){
    ServiceItem__c objServiceItem  = new ServiceItem__c(AvailableServiceItem__c=objAvailableServiceItem.id,
                                                        ServiceItemType__c=objServiceItemType.id,
                                                        Service__c=objService.id,
                                                        StartDate__c= system.today());
    return objServiceItem ;
  }
    
  
   /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         Device__c objmaindevice,Device__c objsubdevice  
  @return        DeviceRelationship__c - objDeviceRelationship  
  @description   Create DeviceRelationship__c  object instance and return it.
  *******************************************************************************/
  /*public static  DeviceRelationship__c createDeviceRelationship (Device__c objmaindevice,Device__c objsubdevice){
    DeviceRelationship__c objDeviceRelationship  = new DeviceRelationship__c(MainDevice__c=objmaindevice.id,SubDevice__c=objsubdevice.id);
    return objDeviceRelationship;
  }*/
      
  /******************************************************************************
  @author        Echo: Ankit Gangwani 
  @date          22 June 2018
  @param         SupplyPoint__c objMainSupply,SupplyPoint__c objSubSupply  
  @return        SupplyPointRelationship__c - objSupplyPointRelationship  
  @description   Create SupplyPointRelationship__c  object instance and return it.
  *******************************************************************************/
  public static  SupplyPointRelationship__c createSupplyPointRelationship (SupplyPoint__c objMainSupply,SupplyPoint__c objSubSupply){
    SupplyPointRelationship__c objSupplyPointRelationship  = new SupplyPointRelationship__c(MainSupply__c = objMainSupply.id,SubSupply__c = objSubSupply.id);
    return objSupplyPointRelationship;
  }
  
  /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          05 Sep 2017
  @param         Device__c objmaindevice,Device__c objsubdevice  
  @return        DeviceRelationship__c - objDeviceRelationship  
  @description   Create DeviceRelationship__c  object instance and return it.
  *******************************************************************************/
  public static  SupplyPointDevice__c createSupplyPointDevices (Device__c device ,SupplyPoint__c supplypoint){
    SupplyPointDevice__c supplyPointDevices = new SupplyPointDevice__c (Device__c=device.Id ,SupplyPoint__c = supplypoint.Id, 
        InstallationDate__c = system.today()-10, RemovalDate__c = null);
        
    return supplyPointDevices ;
  }
  
  /******************************************************************************
  @author        Accenture: Shivangi Gaur
  @date          31 Oct 2017
  @param         SupplyPointDevice__c, ServiceType__c
  @return        SupplyPointDeviceService__c
  @description   Create SupplyPointDeviceService__c  object instance and return it.
  *******************************************************************************/
  public static  SupplyPointDeviceService__c createSupplyPointDeviceService (SupplyPointDevice__c spDevice , ServiceType__c serviceTypeObj){
    SupplyPointDeviceService__c spDeviceServ = new SupplyPointDeviceService__c (SupplyPointDevice__c = spDevice.Id , ServiceType__c = serviceTypeObj.Id);
    return spDeviceServ ;
  }
  
     /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          07 Sep 2017
  @param         String sName ,SupplyPoint__c objsupplypoint  
  @return        Sample__c - objSample
  @description   Create Sample__c object instance and return it.
  *******************************************************************************/
  public static  Sample__c createSample (String sName ){
    Sample__c  objSample= new Sample__c();

    return objSample;
  }
      
  /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          07 Sep 2017
  @param         String sName ,ServiceItem__c objServiceItem
  @return        AgreedRate__c - objAgreedRate
  @description   Create AgreedRate__c  object instance and return it.
  *******************************************************************************/
  public static  AgreedRate__c createAgreedRate (String sName ,ServiceItem__c objServiceItem){
    AgreedRate__c objAgreedRate = new AgreedRate__c(ServiceItem__c= objServiceItem.Id,Value__c= 100);

    return objAgreedRate;
  }
  
  /******************************************************************************
  @author        Accenture: Sucharu Gupta
  @date          12 Sep 2017
  @param         String sName
  @return        string jsonStr
  @description   Create Billing Calculation JSON
  *******************************************************************************/
      Public static string createJson (string str1) {
          String jsonStr = '{"bills" :['+ '{"extId": 12,"CustomerNumber":12345,"ContractNumber":6889, "BilledAmount":568,"TotalDue" : 678, "BillItems" :[{"extId": 34,"VolumeUsed":978,"ChargeBasisValue":898979,"FromDate":"2017-09-06T16:58:54.858Z", "ToDate":"2017-10-04T16:58:54.858Z","BilledAmount":7867}]}]}';      
          return jsonStr; 
      }
  
  /******************************************************************************
  @author        Accenture: Sucharu Gupta
  @date          12 Sep 2017
  @param         Dom.Document - billPDFDataXML
  @return        Dom.Document - doc
  @description   Create Billing PDF
  *******************************************************************************/
      Public static Dom.Document createBillPDFDataXML () {
          Dom.Document doc = new Dom.Document();
          return doc;
      }
   
  /******************************************************************************
  @author        Accenture: Sucharu Gupta
  @date          12 Sep 2017
  @param         string-sName, BillingContract__c objContract 
  @return        Bill__c  - objBill
  @description   Create Bill__c object instance and return it.
  *******************************************************************************/
  
      public static Bill__c createBill(string sName,BillingContract__c objContract){
          Bill__c objBill = new Bill__c(//Name = sName, -- AT 3174
              BillingContract__c = objContract.id, BilledAmount__c = 567, HerokuPostgresId__c = 'id123',
              BillDate__c = date.newInstance(2017, 09, 17));
          return objBill; 
      }
    
  /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          21 Sep 2017
  @param         None
  @return        BillCalculation__c - objBillCalculation
  @description   Create BillCalculation__c object instance and return it.
  *******************************************************************************/
  
      public static BillCalculation__c  createBillCalculation(){
          BillCalculation__c objBillCalculation = new BillCalculation__c(RequestDate__c = system.today(),Status__c='Pending');
          return objBillCalculation ; 
      }
  /******************************************************************************
  @author        Echo: Dependra Singh
  @date          29 Oct 2018
  @param         None
  @return        BillCalculation__c - objBillCalculation
  @description   Create BillCalculation__c object instance and return it.
 *******************************************************************************/      
      public static BillCalculation__c createBillCalculation(string contractId, string strType, string strStatus){
          BillCalculation__c billCalculationObj = new BillCalculation__c(BillingContract__c = contractId,
                                                                         Type__c = strType,
                                                                         Status__c = strStatus,
                                                                         RequestDate__c = system.today());
          return billCalculationObj;
      }   
      
 /******************************************************************************
  @author        Echo: Dependra Singh
  @date          29 Oct 2018
  @param         None
  @return        BillTransfer__c - objBillTransfer
  @description   Create BillTransfer__c object instance and return it.
 *******************************************************************************/            
      public static BillTransfer__c createBillTransfer(string billCalculationId,string locationId,decimal transferAmount,string transferReason,
                                                      string contractToId, string contractFromId){
          BillTransfer__c objBillTransfer = new BillTransfer__c(BillCalculation__c = billCalculationId, 
                                                                Location__c = locationId, 
                                                                TransferAmount__c = transferAmount,
                                                                TransferFromContract__c = contractFromId,
                                                                TransferToContract__c = contractToId,
                                                                TransferReason__c = transferReason
                                                               );
         return objBillTransfer;                                                
              
      }
      
  /******************************************************************************
  @author        Accenture: Sucharu Gupta
  @date          26 Sep 2017
  @param         string sName, Bill__c  objBill, string 
                 HerokuPostgresId
  @return        BillServiceType__c -- objBillServiceType
  @description   Create BillServiceType__c object instance and return it.
  *******************************************************************************/
    Public static BillServiceType__c createBillServiceType(string sName, Bill__c  objBill, string 
    HerokuPostgresId){
        BillServiceType__c objBillServiceType = new BillServiceType__c(Name = sName, Bill__c = objBill.id, HerokuPostgresId__c = HerokuPostgresId);
        return objBillServiceType;
    }
      
  /******************************************************************************
  @author        Accenture: Sucharu Gupta
  @date          26 Sep 2017
  @param         string sName, ServiceItem__c objServiceItem, Integer VolumeUsed , 
                 Integer BilledAmount ,   BillServiceType__c objBillServiceType , string HerokuPostgresId
  @return        BillItem__c -- objBillItems
  @description   Create BillItem__c object instance and return it.
  *******************************************************************************/
  Public static BillItem__c createBillItem(string sName, ServiceItem__c objServiceItem, Integer VolumeUsed , Integer BilledAmount , 
                                           BillServiceType__c objBillServiceType , string HerokuPostgresId){
      BillItem__c objBillItems = new BillItem__c(/*Name = sName,*/ 
                                                 ServiceItem__c = objServiceItem.id, 
                                                 VolumeUsed__c = VolumeUsed, 
                                                 BilledAmount__c = BilledAmount, 
                                                 BillServiceType__c = objBillServiceType.id, 
                                                 HerokuPostgresId__c = HerokuPostgresId);
      objBillItems.StartDate__c = system.Today();
      objBillItems.EndDate__c = system.Today();
      return objBillItems;  
  }
  
  /******************************************************************************
  @author        Accenture: Sucharu Gupta
  @date          26 Sep 2017
  @param         string sName
  @return        PaymentPlanType__c -- objPaymentPlanType
  @description   Create PaymentPlanType__c object instance and return it.
  *******************************************************************************/
  public static PaymentPlanType__c createPaymentPlanType(string sName, String PaymentFreq, Integer NoOfInstalment){
      PaymentPlanType__c objPaymentPlanType = new PaymentPlanType__c(Name = sName, PaymentFrequency__c = PaymentFreq, MaximumNumberOfInstalments__c = NoOfInstalment );
      return objPaymentPlanType;  
    }
    
  /******************************************************************************
  @author        Accenture: Sucharu Gupta
  @date          26 Sep 2017
  @param         string sName
  @return        PaymentPlan__c -- objPaymentPlan
  @description   Create PaymentPlan__c object instance and return it.
  *******************************************************************************/
  public static PaymentPlan__c createPaymentPlan(PaymentPlanType__c objPaymentPlanType, BillingContract__c objContract, Integer ForecastAmount){
      PaymentPlan__c objPaymentPlan = new PaymentPlan__c(PaymentPlanType__c = objPaymentPlanType.id, 
        BillingContract__c = objContract.id, ForecastAmount__c = ForecastAmount);//AT-3174
      return objPaymentPlan;  
    } 

  /******************************************************************************
  @author        ECHO: Mohit Tayal
  @date          05 Feb 2018
  @param         Account objAccount
  @return        Balance__c  - objBalance
  @description   Create Balance object instance and return it.
  *******************************************************************************/      
  public static Balance__c createBalance(Account objAccount){
      Balance__c objBalance = new Balance__c(Account__c =objAccount.id);
      return objBalance;
    }    
  /******************************************************************************
  @author        Accenture: Manish
  @date          03 Oct 2017
  @param         string sName
  @return        HerokuSecurity__c -- objPaymentPlan
  @description   Create HerokuSecurity__c object instance and return it.
  *******************************************************************************/
  public static HerokuSecurity__c createHerokuSecurity(String AuthenticationToken){
      HerokuSecurity__c objHerokuSecurity = new HerokuSecurity__c(Name= USER_LNAME,AuthenticationToken__c=AuthenticationToken);
      return objHerokuSecurity;  
    }
    
/******************************************************************************
  @author        Accenture: Sucharu Gupta
  @date          11 Oct 2017
  @param         string sName
  @return        HerokuSecurity__c -- objPaymentPlan
  @description   Create HerokuSecurity__c object instance and return it.
  *******************************************************************************/
  public static Rate__c createRate(ServiceItemType__c objServiceItemType, integer RetailAmount ){
      Rate__c objRate = new Rate__c(ServiceItemType__c =objServiceItemType.id, RetailAmount__c = RetailAmount);
      objRate.StartDate__c = system.today();
      return objRate;  
    }
    
        
/******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          16 Oct 2017
  @param         Rate__c objRate 
  @return        RateBand__c objRateBand
  @description   Create RateBand__c object instance and return it.
  *******************************************************************************/
  public static RateBand__c createRateBand(Rate__c objRate, Integer lowerLimit, Integer higherLimit ){
      RateBand__c objRateBand= new RateBand__c (Rate__c = objRate.id,LowerLimit__c = lowerLimit , UpperLimit__c = higherLimit);
      return objRateBand;  
    }
    
    /******************************************************************************
  @author        Accenture: Vivek Chauhan
  @date          16 Oct 2017
  @param         Rate__c objRate 
  @return        ContractGroup__c objContractGroup
  @description   Create RateBand__c object instance and return it.
  *******************************************************************************/
  public static ContractGroup__c createContractGroup(Account objAccount){
      ContractGroup__c objContractGroup = new ContractGroup__c(Account__c = objAccount.id, Name = 'testcontractgp');
      return objContractGroup ;  
    }
    
/******************************************************************************
  @author        Accenture: Sucharu Gupta
  @date          02 Nov 2017
  @param         string sName
  @return        BillTemplate__c -- objBillTemplate

  @description   Create BillTemplate__c object instance and return it.
  *******************************************************************************/
  public static BillTemplate__c createBillTemplate(String sName){
      BillTemplate__c objBillTemplate = new BillTemplate__c(Name = sName);
      return objBillTemplate;  
    }
 
 /******************************************************************************
  @author        Echo: Vivek Sethi
  @date          01 Dec 2017
  @param         Location__c objLocation
  @return        VoidManagementProcess__c- objVoidManagementProcess  
  @description   Create VoidManagementProcess__c object instance and return it.
  *******************************************************************************/
  public static VoidManagementProcess__c createVoidManagementProcess(Location__c objLocation){
    VoidManagementProcess__c  objVoidManagementProcess  = new VoidManagementProcess__c (VoidLocation__c = objLocation.Id);
    return objVoidManagementProcess ;
  }
      
 /******************************************************************************
  @author        Echo: Vivek Sethi
  @date          01 Dec 2017
  @param         VoidManagementProcess__c objVoidManagementProcess
  @return        VoidManagementAction__c- objVoidManagementAction  
  @description   Create VoidManagementAction__c object instance and return it.
  *******************************************************************************/
  public static VoidManagementAction__c createVoidManagementAction(VoidManagementProcess__c objVoidManagementProcess){
    VoidManagementAction__c  objVoidManagementAction  = new VoidManagementAction__c (VoidManagementProcess__c = objVoidManagementProcess.Id);
    return objVoidManagementAction ;
  }  
      
/******************************************************************************
  @author        Echo: Vivek Sethi
  @date          01 Dec 2017
  @param         BillingContract__c objContract
  @return        DebtRecoveryProcess__c- objVoidManagementProcess  
  @description   Create DebtRecoveryProcess__c object instance and return it.
  *******************************************************************************/
  public static DebtRecoveryProcess__c createDebtRecoveryProcess(BillingContract__c objContract){
    DebtRecoveryProcess__c  objDebtRecoveryProcess  = new DebtRecoveryProcess__c (BillingContract__c = objContract.Id);
    return objDebtRecoveryProcess ;
  }
      
/******************************************************************************
  @author        Echo: Vivek Sethi
  @date          01 Dec 2017
  @param         BillingContract__c objContract
  @return        DebtRecoveryAction_c- objVoidManagementProcess  
  @description   Create DebtRecoveryProcess__c object instance and return it.
  *******************************************************************************/
  public static DebtRecoveryAction__c createDebtRecoveryAction(DebtRecoveryProcess__c objDebtRecoveryProcess){
    DebtRecoveryAction__c  objDebtRecoveryAction  = new DebtRecoveryAction__c (DebtRecoveryProcess__c = objDebtRecoveryProcess.Id);
    return objDebtRecoveryAction ;
  }
/******************************************************************************
  @author        Accenture: Shivangi Gaur
  @date          04 Dec 2017
  @param         Account objAcc, Location__c locObj
  @return        LocationOccupant__c locOccupant
  @description   Create LocationOccupant__c object instance and return it.
  *******************************************************************************/
  public static LocationOccupant__c createLocationOccupant(Account objAcc, Location__c locObj){
    LocationOccupant__c  locOccupant  = new LocationOccupant__c (Account__c = objAcc.id, Location__c = locObj.id);
    locOccupant.StartDate__c = system.today();
    locOccupant.EndDate__c = system.today()+10;
    locOccupant.OccupancyType__c = 'Tenant';
    return locOccupant ;
  } 
  
  /******************************************************************************
  @author        Accenture: Vandana Anshu
  @date          11 Dec 2017
  @param         
  @return        GlUt_DisableAutomation__c automationSetting
  @description   Create Custom Setting instance and return it.
  *******************************************************************************/
  //Retrive the custom setting information
   public static GlUt_DisableAutomation__c createAutomationSetting (){
        //GlUt_DisableAutomation__c automationSetting = GlUt_DisableAutomation__c.getInstance(UserInfo.getUserId());
        GlUt_DisableAutomation__c automationSetting = new GlUt_DisableAutomation__c();
        return automationSetting;
      } 
      
  /******************************************************************************
  @author        Accenture: Vandana Anshu
  @date          14 Dec 2017
  @param         string sName
  @return        Group__c -- objGroup
  @description   Create Group__c object instance and return it.
  *******************************************************************************/
      
    public static Group__c createGroup(String sName){
    //Group__c objGroup = new Group__c(Name = sName);
    Group__c objGroup = new Group__c();
    return objGroup;
    }
      
 /******************************************************************************
  @author        Accenture: Vandana Anshu
  @date          14 Dec 2017
  @param         string sName
  @return        GroupItem__c-- objGrpItem 
  @description   Create GroupItem__c object instance and return it.
  *******************************************************************************/
      
    public static GroupItem__c createGroupItem(ServiceItem__c objServiceItem){
    GroupItem__c objGrpItem = new GroupItem__c(ServiceItem__c = objServiceItem.Id);
    return objGrpItem;
    }
    
   /******************************************************************************
  @author        Accenture: Vandana Anshu
  @date          15 Dec 2017
  @param         string sName
  @return        ChargeBasis__c -- objChargeBasis 
  @description   Create ChargeBasis__c object instance and return it.
  *******************************************************************************/
      
    public static ChargeBasis__c createChargeBasis(AvailableService__c availableServObj){
    ChargeBasis__c objChargeBasis = new ChargeBasis__c(AvailableService__c = availableServObj.id, Amount__c =200, StartDate__c = system.today(), Type__c = 'Maximum Daily Demand');
    return objChargeBasis;
    }
    
    /******************************************************************************
  @author        Accenture: Vandana Anshu
  @date          15 Dec 2017
  @param         string sName
  @return        AverageDailyUsage__c -- objAvgDailyUses 
  @description   Create AverageDailyUsage__c object instance and return it.
  *******************************************************************************/
      
    public static AverageDailyUsage__c createAvgDailyUses(SupplyPointDevice__c spdObj){
    AverageDailyUsage__c objAvgDailyUses = new AverageDailyUsage__c(SupplyPointDevice__c =spdObj.id, AverageDailyUsage__c=200, StartDate__c = system.today());
    return objAvgDailyUses;
    } 
    
  /******************************************************************************
  @author        Accenture: Vandana Anshu
  @date          15 Dec 2017
  @param         string sName
  @return        ManualAmendment__c -- objManualAmendment 
  @description   Create ManualAmendment__c object instance and return it.
  *******************************************************************************/
      
    public static ManualAmendment__c createManualAmendment(BillItem__c billItemObj){
    ManualAmendment__c objManualAmendment = new ManualAmendment__c(AmendedBillItem__c = billItemObj.id, Amount__c=200, AmendmentReason__c = 'Bill Correction');
    return objManualAmendment;
    }
    /******************************************************************************
    @author        Accenture: Shivangi Gaur
    @date          18 Dec 2017
    @param         string sName
    @return        ConsiderationType__c -- objConsiderationType 
    @description   Create ConsiderationType__c object instance and return it.
    *******************************************************************************/
      
    public static ConsiderationType__c createConsiderationType(String conTypeName){
        ConsiderationType__c objConsiderationType = new ConsiderationType__c(Name = conTypeName);
        return objConsiderationType;
    }
    /******************************************************************************
    @author        Accenture: Shivangi Gaur
    @date          18 Dec 2017
    @param         Account objAccount, ConsiderationType__c objConsiderationType
    @return        Consideration__c -- objConsideration 
    @description   Create Consideration__c object instance and return it.
    *******************************************************************************/
      
    public static Consideration__c createConsideration(Account objAccount, ConsiderationType__c objConsiderationType){
        Consideration__c objConsideration = new Consideration__c(Account__c = objAccount.id, ConsiderationType__c = objConsiderationType.id);
        objConsideration.Active__c = true;
        return objConsideration;
    }
    /******************************************************************************
    @author        Accenture: Vivek Chuauhan
    @date          03 Jan 2018
    @param         Bill__c  objBill
    @return        ContentVersion  -- objContentVersion  
    @description   Create ContentVersion object instance and return it.
    *******************************************************************************/
      
    public static ContentVersion createContentVersion(Bill__c  objBill){
        ContentVersion objContentVersion = new ContentVersion(Title = 'test', 
                                                              VersionData =  Blob.valueOf('testfile'), 
                                                              PathOnClient =  'bill PDF ' + objBill.id + '.pdf');
        return objContentVersion;
    }
      
    /******************************************************************************
    @author        Echo: Ankit Gangwani
    @date          05 June 2018
    @param         BatchProcess__c objBP
    @return        BatchProcess__c  -- objBatchProcess  
    @description   Create Batch Process object instance and return it.
    *******************************************************************************/
      
    public static BatchProcess__c createBatchProcess(String batchClass){
        BatchProcess__c objBatchProcess = new BatchProcess__c(BatchClass__c = batchClass);
        return objBatchProcess;
    }
      
    /******************************************************************************
    @author        Echo: Ankit Gangwani
    @date          05 June 2018
    @param         BatchProcess__c objBP
    @return        BatchProcess__c  -- objBatchProcess  
    @description   Create Batch Process object instance and return it.
    *******************************************************************************/
      
    public static BatchError__c createBatchError(Id batchRequestQueueId){
        BatchError__c objBatchError = new BatchError__c(BatchRequestQueue__c = batchRequestQueueId);
        return objBatchError;
    }
      
    /******************************************************************************
    @author        Echo: Ankit Gangwani
    @date          05 June 2018
    @param         BatchProcess__c objBP
    @return        BatchProcess__c  -- objBatchProcess  
    @description   Create Batch Process object instance and return it.
    *******************************************************************************/
      
    public static ReadingUpload__c createReadingUpload(Id batchRequestQueueId){
        ReadingUpload__c objReadingUpload = new ReadingUpload__c(BatchRequestQueue__c = batchRequestQueueId);
        return objReadingUpload;
    }
      
    /******************************************************************************
    @author        Accenture: Vivek Chuauhan
    @date          03 Jan 2018
    @param         ContentVersion objContentVersion,Bill__c objBill
    @return        ContentDocumentLink   -- objContentDocumentLink   
    @description   Create ContentDocumentLink  object instance and return it.
    *******************************************************************************/
      
    public static ContentDocumentLink  createContentDocumentLink (ContentVersion  objContentVersion,Bill__c objBill  ){
        ContentVersion objContentVersionToUse  = [select Id, ContentDocumentId from ContentVersion where Id = :objContentVersion.Id];
        
        ContentDocumentLink objContentDocumentLink = new ContentDocumentLink(ContentDocumentId = objContentVersionToUse.ContentDocumentId, 
                                                                             LinkedEntityId = objBill.id, ShareType = 'V');
        return objContentDocumentLink;
    } 
      
    /******************************************************************************
    @author        Echo: Neha Rajput
    @date          17 Jan 2018
    @param         String sName, Date FromDate, Date ToDate, String Discounttype, Decimal PercentageDiscountAmount
    @return        DiscountType__c -- objDiscountType   
    @description   Create DiscountType__c object instance and return it.
    *******************************************************************************/ 
      
    public static DiscountType__c createDiscountType(String sName, Date FromDate, Date ToDate, String Discounttype, Decimal PercentageDiscountAmount){
        DiscountType__c objDiscountType = new DiscountType__c(Name = sName,
                                                              StartDate__c = FromDate, 
                                                              EndDate__c = ToDate, 
                                                              Type__c = Discounttype, 
                                                              PercentageDiscountAmount__c = PercentageDiscountAmount );        
        return objDiscountType;
    }
      
    /******************************************************************************
    @author        Echo: Neha Rajput
    @date          17 Jan 2018
    @param         DiscountType__c objDiscountType, ServiceItemType__c objServiceItemType
    @return        DiscountTypeitem__c -- objDiscountTypeitem   
    @description   Create DiscountType__c object instance and return it.
    *******************************************************************************/    
      
    public static DiscountTypeitem__c createDiscountTypeitem(DiscountType__c objDiscountType, ServiceItemType__c objServiceItemType){
        DiscountTypeitem__c objDiscountTypeitem = new DiscountTypeitem__c(DiscountType__c = objDiscountType.id, ServiceItemType__c = objServiceItemType.id);        
        return objDiscountTypeitem;
    }
  
      
    /******************************************************************************
    @author        Echo: Neha Rajput
    @date          02 Feb 2018
    @param         BillingContract__c objContract,DiscountType__c objDiscountType, Service__c objService, ServiceItem__c objServiceItem 
    @return        Discount__c -- objDiscount   
    @description   Create Discount__c object instance and return it.
    *******************************************************************************/  
    public static Discount__c createDiscount(BillingContract__c objContract,DiscountType__c objDiscountType){
        Discount__c objDiscount = new Discount__c(BillingContract__c = objContract.Id, DiscountType__c = objDiscountType.Id);
        return objDiscount;
    }

         /******************************************************************************
    @author        Echo: Amit K.
    @date          29 Jan 2018
    @param         Account objAccount, BillingContract__c objContract
    @return        Payment__c -- objPayment   
    @description   Create Payment__c object instance and return it.
    *******************************************************************************/
      public static Payment__c createPayment(Account objAccount, BillingContract__c objContract){
          Payment__c objPayment = new Payment__c(Account__c = objAccount.id, BillingContract__c = objContract.id,Amount__c = 120, PaymentDate__c = System.Today());        
          return objPayment;
      }
      
        /******************************************************************************
    @author        Echo: Neha 
    @date          07 Dec 2018
    @param         Account objAccount, BillingContract__c objContract
    @return        PaymentAssociation__c -- objPaymentAssociation 
    @description   Create PaymentAssociation__c object instance and return it.
    *******************************************************************************/
      public static PaymentAssociation__c createPaymentAssociation(Payment__c objOriginalPayment, Payment__c objTransferredRefundedPayment){
          PaymentAssociation__c objPaymentAssociation = new PaymentAssociation__c(OriginalPayment__c = objOriginalPayment.id, TransferredRefundedPayment__c = objTransferredRefundedPayment.id);        
          return objPaymentAssociation;
      }
    
    /******************************************************************************
    @author        Echo: Neha Rajput
    @date          02 Feb 2018
    @param         PaymentPlan__c objPaymentPlan
    @return        Instalment__c -- objInstalment   
    @description   Create Instalment__c object instance and return it.
    *******************************************************************************/
      public static Instalment__c createInstalment(PaymentPlan__c objPaymentPlan){  
        Instalment__c objInstalment = new Instalment__c(PaymentPlan__c = objPaymentPlan.id);        
        return objInstalment;
    }
    
    /******************************************************************************
    @author        Echo: Neha Rajput
    @date          02 Feb 2018
    @param         String sName, Decimal AmountAllocated, BillItem__c objBillItem, Instalment__c objInstalment, Payment__c objPayment 
    @return        PaymentAllocation__c -- objPaymentAllocation   
    @description   Create PaymentAllocation__c object instance and return it.
    *******************************************************************************/
    public static PaymentAllocation__c createPaymentAllocation(String sName, Decimal AmountAllocated, BillItem__c objBillItem, Instalment__c objInstalment, Payment__c objPayment){ 
        PaymentAllocation__c objPaymentAllocation = new PaymentAllocation__c(AmountAllocated__c = AmountAllocated, 
                                                                             BillItem__c = objBillItem.id, 
                                                                             Instalment__c = objInstalment.id,
                                                                             Payment__c = objPayment.id);        
          return objPaymentAllocation;
    }
      
    /******************************************************************************
    @author        Echo: Tarun Gupta
    @date          13 Feb 2018
    @param         
    @return        PaymentMethodType__c -- objPaymentMethodType   
    @description   Create PaymentMethodType__c object instance and return it.
    *******************************************************************************/
    public static PaymentMethodType__c createPaymentMethodType(){   
        PaymentMethodType__c objPaymentMethodType = new PaymentMethodType__c(Name='Payment Card');        
        return objPaymentMethodType;
    } 
      
    /******************************************************************************
    @author        Echo: Tarun Gupta
    @date          13 Feb 2018
    @param         PaymentMethodType__c objPaymentMethodType, PaymentPlanType__c objPaymentPlanType 
    @return        PaymentMethod__c -- objPaymentMethod   
    @description   Create PaymentMethod__c object instance and return it.
    *******************************************************************************/
    public static PaymentMethod__c createPaymentMethod(PaymentMethodType__c objPaymentMethodType,PaymentPlanType__c objPaymentPlanType){    
        PaymentMethod__c objPaymentMethod = new PaymentMethod__c(PaymentMethodType__c = objPaymentMethodType.Id, PaymentPlanType__c = objPaymentPlanType.Id);        
        return objPaymentMethod;
    }
      
    /******************************************************************************
    @author        Echo: Tarun Gupta
    @date          13 Feb 2018
    @param         String sName, String dayofMonth, String dayofWeek , PaymentMethodType__c objPaymentMethodType 
    @return        AvailablePaymentDay__c -- objAvailPaymentDay   
    @description   Create PaymentMethod__c object instance and return it.
    *******************************************************************************/
    public static AvailablePaymentDay__c createAvailPaymentDay(String sName, String dayofMonth,String dayofWeek, PaymentMethodType__c objPaymentMethodType){    
        AvailablePaymentDay__c objAvailPaymentDay = new AvailablePaymentDay__c(DayofMonth__c = dayofMonth, 
                                                                               DayofWeek__c = dayofWeek,
                                                                               PaymentMethodType__c = objPaymentMethodType.Id);        
        return objAvailPaymentDay;
    }
      
    /******************************************************************************
    @author        Echo: Tarun Gupta
    @date          13 Feb 2018
    @param         Balance__c objBalance 
    @return        AvailablePaymentDay__c -- objAvailPaymentDay   
    @description   Create PaymentMethod__c object instance and return it.
    *******************************************************************************/
    public static BalanceTransaction__c createBalanceTransaction(Balance__c objBalance){    
        BalanceTransaction__c objBalanceTransaction = new BalanceTransaction__c(Balance__c = objBalance.Id);        
        return objBalanceTransaction;
    }  
      
    /******************************************************************************
    @author        ECHO: Mohit Tayal
    @date          15 Feb 2018
    @param         String - Account__c objAccount,BillingContract__c objContract, String sReason  
    @return        Suppression__c  - objSuppression
    @description   Create Suppression__c  object instance and return it.
    *******************************************************************************/
    public static Suppression__c createSuppression(Account objAccount, BillingContract__c objContract, String sReason){
       Suppression__c objSuppression  = new Suppression__c(Account__c = objAccount.Id, BillingContract__c = objContract.Id, 
                                                           SuppressionReason__c = sReason, SuppressBillPrint__c = TRUE,
                                                          SuppressionStartDate__c = Date.today(), SuppressionEndDate__c= Date.today().addDays(10));
    return objSuppression;
  } 
      
   /******************************************************************************
    @author        Echo: Neha R
    @date          16 Feb 2018
    @param         String - BillItem__c objBillItem,Instalment__c objInstalment, objPayment 
    @return        PaymentAllocationQueue__c  - objPaymentAllocationQueue
    @description   Create PaymentAllocationQueue__c  object instance and return it.
    *******************************************************************************/
    public static PaymentAllocationQueue__c createPaymentAllocationQueue(BillItem__c objBillItem, Instalment__c objInstalment, Payment__c objPayment){
       PaymentAllocationQueue__c objPaymentAllocationQueue  = new PaymentAllocationQueue__c(BillItem__c = objBillItem.Id, 
                                                                                            Instalment__c = objInstalment.Id, 
                                                                                            Payment__c = objPayment.Id );
       return objPaymentAllocationQueue;
  } 
    /******************************************************************************
    @author        Echo: Amit K.
    @date          17 Feb 2018
    @param         Location__c objLocation
    @return        DischargeAgreement__c  - objDischargeAgreement
    @description   Create DischargeAgreement__c  object instance and return it.
    *******************************************************************************/
    public static DischargeAgreement__c createDischargeAgreement(Location__c objLocation){
       DischargeAgreement__c objDischargeAgreement  = new DischargeAgreement__c(Location__c = objLocation.Id,
                                                                                StartDate__c = System.Today(), 
                                                                                EndDate__c = System.Today()+365);
       return objDischargeAgreement;
  } 
      
  /******************************************************************************
    @author        Echo: Neha R.
    @date          06 Mar 2018
    @param         Account objAccount, String caseStatus
    @return        Case  - objCase
    @description   Create Case  object instance and return it.
    *******************************************************************************/
    public static Case createCase(Account objAccount, String caseStatus){
       Case objCase  = new Case(AccountId = objAccount.Id, Status = caseStatus );
       return objCase;
  }  
   /******************************************************************************
    @author        Echo: Amit K.
    @date          06 March 2018
    @param         Account objAccount
    @return        PDFRequest__c  - objCreateLetterPDFRequest
    @description   Create PDFRequest__c  object instance and return it.
    *******************************************************************************/
       public static PDFRequest__c createLetterPDFRequest(Account objAccount){
       PDFRequest__c objCreateLetterPDFRequest  = new PDFRequest__c(HtmlBody__c ='XYZ',Status__c = 'Pending');
       return objCreateLetterPDFRequest;
  }  
      
  /******************************************************************************
  @author        ECHO: Mohit Tayal
  @date          26 Mar 2018
  @param         string sName
  @return        TaxClassificationType__c  - objTaxClassificationType
  @description   Create Tax Classification Type object instance and return it.
  *******************************************************************************/
  public static TaxClassificationType__c createTaxClassificationType(string sName){
    TaxClassificationType__c objTaxClassificationType = new TaxClassificationType__c(Name = sName);
    return objTaxClassificationType;
  }   
      
  /******************************************************************************
  @author        ECHO: Mohit Tayal
  @date          26 Mar 2018
  @param         string sName , DischargeAgreement__c objDischargeAgreement
  @return        AgreedSampleStrength__c  - objAgreedSampleStrength
  @description   Create Agreed Sample Strength object instance and return it.
  *******************************************************************************/
  public static AgreedSampleStrength__c createAgreedSampleStrength(string sName, DischargeAgreement__c objDischargeAgreement){
    AgreedSampleStrength__c objAgreedSampleStrength = new AgreedSampleStrength__c(DischargeAgreement__c  = objDischargeAgreement.Id, 
                                                                                  StartDate__c = Date.today() - 10,
                                                                                  SSAgreedSampleStrength__c = 10, 
                                                                                  CODAgreedSampleStrength__c = 10);
    return objAgreedSampleStrength;
  }  
   
  /******************************************************************************
  @author        ECHO: Mohit Tayal
  @date          26 Mar 2018
  @param         string sName , DischargeAgreement__c objDischargeAgreement
  @return        AgreedVolume__c  - objAgreedVolume
  @description   Create Agreed Volume object instance and return it.
  *******************************************************************************/
  public static AgreedVolume__c createAgreedVolume(string sName, DischargeAgreement__c objDischargeAgreement){
    AgreedVolume__c objAgreedVolume = new AgreedVolume__c(DischargeAgreement__c  = objDischargeAgreement.Id, 
                                                          StartDate__c = Date.today() - 10, 
                                                          AgreedVolume__c = 100);
    return objAgreedVolume;
  }    
      
  /******************************************************************************
  @author        ECHO: Mohit Tayal
  @date          26 Mar 2018
  @param         Account objAccount , TaxClassificationType__c objTaxClassificationType
  @return        TaxClassification__c  - objTaxClassification
  @description   Create Tax Classification object instance and return it.
  *******************************************************************************/
  public static TaxClassification__c createTaxClassification(Account objAccount, TaxClassificationType__c objTaxClassificationType){
    TaxClassification__c objTaxClassification = new TaxClassification__c(Account__c  = objAccount.Id, TaxClassificationType__c = objTaxClassificationType.Id, 
                                                                         SICStartDate__c = Date.today() - 10);
    return objTaxClassification;
  }
      
  /******************************************************************************
  @author        ECHO: Tarun Gupta
  @date          04 Apr 2018
  @param         
  @return        FinancialControl__c  - objFinancialControl
  @description   Create Financial Control object instance and return it.
  *******************************************************************************/
  public static FinancialControl__c createFinancialControl(){
    FinancialControl__c objFinancialControl = new FinancialControl__c();
    return objFinancialControl;
  }
      
  /******************************************************************************
  @author        ECHO: Tarun Gupta
  @date          04 Apr 2018
  @param         
  @return        FinancialControl__c  - objFinancialControl
  @description   Create Financial Control object instance and return it.
  *******************************************************************************/
  public static FinancialTransactionEventType__c createFinancialTransactionEventType(){
    FinancialTransactionEventType__c objFinancialTransactionEventType = new FinancialTransactionEventType__c();
    return objFinancialTransactionEventType;
  }    
      
  /******************************************************************************
  @author        ECHO: Sudhir Kumar
  @date          12 Apr 2018
  @param         Contact portalContact, String portalProfileName
  @return        User  - portalUser
  @description   Create Community Portal User instance and return it. Refer AT-2167
  *******************************************************************************/
  public static User createCommunityUser(Contact portalContact, String portalUserName) {
      //Create user
      List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: PORTAL_PROFILE_NAME Limit 1];
      if(portalProfile != null && portalProfile.size() > 0){
          User portalUser = GlUt_FactoryData_Test.createUser(PORTAL_PROFILE_NAME, portalUserName, null);
          portalUser.ContactId = portalContact.Id ;
          portalUser.ProfileId = portalProfile[0].Id ;
          return portalUser;
      }
      else{
         return null; 
      }
  }       
      
    /******************************************************************************
    @author        Echo: Neha Rajput
    @date          10 May 2018
    @param         sName
    @return        Depot__c - objDepot
    @description   Create Depot__c object instance and return it.
    *******************************************************************************/
    public static Depot__c createDepot(String sName){
        Depot__c objDepot = new Depot__c(Name=sName);
        return objDepot;
    }
    
    /******************************************************************************
    @author        Echo: Neha Rajput
    @date          10 May 2018
    @param         sName
    @return        ReadTimetable__c - objReadTimetable
    @description   Create ReadTimetable__c object instance and return it.
    *******************************************************************************/
    public static ReadTimetable__c createReadTimetable(String sName, String readFreq){
        ReadTimetable__c objReadTimetable = new ReadTimetable__c(Name=sName,ReadFrequency__c = readFreq);
        return objReadTimetable;
    }
    
    /******************************************************************************
    @author        Echo: Neha Rajput
    @date          10 May 2018
    @param         Depot__c objDepot, ReadTimetable__c objReadTimeTable
    @return        Book__c - objBook
    @description   Create Book__c object instance and return it.
    *******************************************************************************/
    public static Book__c createBook(Depot__c objDepot, ReadTimetable__c objReadTimeTable){
        Book__c objBook = new Book__c(Depot__c=objDepot.Id, ReadTimetable__c=objReadTimeTable.Id);
        return objBook;
    }
    
    /******************************************************************************
    @author        Echo: Vivek Sethi
    @date          30 May 2018
    @param         BillingContract__c objContract
    @return        BillEvent__c - ObjBillEvent
    @description   Create BillEvent__c object instance and return it.
    *******************************************************************************/
    public static BillEvent__c createBillEvent(BillingContract__c objContract){
        BillEvent__c ObjBillEvent = new BillEvent__c(BillingContract__c=objContract.Id);
        return ObjBillEvent;
    }
      
    /******************************************************************************
    @author        Echo: Neha
    @date          06 June 2018
    @param         String sName
    @return        Area__c - objArea
    @description   Create Area__c object instance and return it.
    *******************************************************************************/
    public static Area__c createArea(String sName){
        Area__c objArea = new Area__c(Name=sName);
        return objArea;
    }
      
    /******************************************************************************
    @author        Echo: Neha
    @date          06 June 2018
    @param         ReadTimetable__c objReadTimetable, Integer DUStart, Integer DUEnd, Integer APVBelowPercentage, Integer APVAbovePercentage 
    @return        ReadTimetableThresholds__c - objReadTimetableThresholds
    @description   Create ReadTimetableThresholds__c object instance and return it.
    *******************************************************************************/
    public static ReadTimetableThresholds__c createReadTimetableThresholds(ReadTimetable__c objReadTimetable, Integer DailyUsageStart, 
                                                                           Integer DailyUsageEnd, Integer APVBelowPercentage, 
                                                                           Integer APVAbovePercentage){
        ReadTimetableThresholds__c objReadTimetableThresholds = new ReadTimetableThresholds__c(ReadTimetable__c = objReadTimetable.Id, 
                                                                                               DailyUsageThresholdStart__c = DailyUsageStart,
                                                                                               DailyUsageThresholdEnd__c = DailyUsageEnd, 
                                                                                               AcceptablePercentageVarianceBelow__c = APVBelowPercentage, 
                                                                                               AcceptablePercentageVarianceAbove__c = APVAbovePercentage);
        return objReadTimetableThresholds;
    }
      
    /******************************************************************************
    @author        Echo: Neha
    @date          06 June 2018
    @param         String sName, Boolean CreateError, Boolean CreateEstimate  
    @return        SkipCode__c - objSkipCode
    @description   Create SkipCode__c object instance and return it.
    *******************************************************************************/
    public static SkipCode__c createSkipCode(String sName, Boolean CreateError, Boolean CreateEstimate ){
        SkipCode__c objSkipCode = new SkipCode__c(Name=sName,CreateError__c=CreateError,CreateEstimate__c=CreateEstimate);
        return objSkipCode;
    }
      
    /******************************************************************************
    @author        Echo: Neha
    @date          06 June 2018
    @param         ReadPeriod__c objReadPeriod, Book__c objBook, Depot__c objDepot, Area__c objArea  
    @return        ReadingMode__c - objReadingMode
    @description   Create ReadingMode__c object instance and return it.
    *******************************************************************************/
    public static ReadingMode__c createReadingMode(ReadPeriod__c objReadPeriod, Book__c objBook, Depot__c objDepot, Area__c objArea){
        ReadingMode__c objReadingMode = new ReadingMode__c(ReadPeriod__c=objReadPeriod.Id,Book__c=objBook.Id,Depot__c=objDepot.Id,Area__c=objArea.Id);
        return objReadingMode;
    }
      
    /******************************************************************************
    @author        Echo: Neha
    @date          06 June 2018
    @param         String sName, Boolean CreateError, Boolean CreateEstimate  
    @return        ReadPeriod__c - objReadPeriod__c
    @description   Create ReadPeriod__c object instance and return it.
    *******************************************************************************/
    public static ReadPeriod__c createReadPeriod(ReadTimetable__c objReadTimetable, Date readStart, Date readEnd, Date billingPeriodStart,Date billingPeriodEnd) {
        ReadPeriod__c objReadPeriod = new ReadPeriod__c(ReadTimetable__c=objReadTimetable.Id,
                                                        ReadStart__c=readStart,
                                                        ReadEnd__c=readEnd,
                                                        BillingPeriodStart__c=billingPeriodStart,
                                                        BillingPeriodEnd__c= billingPeriodEnd);
        return objReadPeriod;
    }
      
    /******************************************************************************
    @author        Echo: Vivek 
    @date          08 June 2018
    @param         none
    @return        BatchRequestQueue__c - objBatchRequestQueue
    @description   Create BatchRequestQueue__c object instance and return it.
    *******************************************************************************/
      public static BatchRequestQueue__c createBatchRequestQueue() {
          BatchRequestQueue__c objBatchRequestQueue = new BatchRequestQueue__c();
          return objBatchRequestQueue;
      }
    
    /******************************************************************************
    @author        Echo: Swati
    @date          08 June 2018
    @param         SupplyPoint__c objSupplyPoint
    @return        ReadingRequest__c - objReadingRequest
    @description   Create ReadingRequest__c object instance and return it.
    *******************************************************************************/
      public static ReadingRequest__c createReadingRequest(SupplyPoint__c objSupplyPoint) {
          ReadingRequest__c objReadingRequest = new ReadingRequest__c(SupplyPoint__c= objSupplyPoint.Id);
          return objReadingRequest;
      }
      
    /******************************************************************************
    @author        Echo: Swati
    @date          08 June 2018
    @param         ReadPeriod__c objReadPeriod
    @return        ScheduledRead__c - ScheduledRead__c
    @description   Create ScheduledRead__c object instance and return it.
    *******************************************************************************/
      public static ScheduledRead__c createScheduledRead(ReadPeriod__c objReadPeriod) {
          ScheduledRead__c objScheduledRead = new ScheduledRead__c(ReadPeriod__c= objReadPeriod.Id);
          return objScheduledRead;
      }
    /******************************************************************************
    @author        Echo: Amit K.
    @date          18 June 2018
    @param         
    @return        Task - objTask
    @description   Create Task object instance and return it.
    *******************************************************************************/   
      public static Task createTask() {
          Task objTask = new Task(Subject='Donni',Status='New',Priority='Normal',CallType='Outbound');
          return objTask;
      }
     
  /******************************************************************************
  @author        Mohit Tayal
  @date          12 Sep 2017
  @param         string-sName, BillingContract__c objContract 
  @return        Bill__c  - objBill
  @description   Create Bill__c object instance and return it.
  *******************************************************************************/
  
  public static BillMessage__c createBillMessage(String sName){
      BillMessage__c objBillMessage = new BillMessage__c(Name = sName);
      return objBillMessage; 
    }  
      
  /******************************************************************************
  @author        Mohit Tayal
  @date          12 Sep 2017
  @param         string-sName, BillingContract__c objContract 
  @return        Bill__c  - objBill
  @description   Create Bill__c object instance and return it.
  *******************************************************************************/
  
  public static ContractBillMessage__c createContractBillMessage(BillMessage__c objBillMessage, BillingContract__c objContract){
      ContractBillMessage__c objContractBillMessage = new ContractBillMessage__c(BillMessage__c = objBillMessage.Id, 
                                                                                 BillingContract__c = objContract.id, Active__c = True);
      return objContractBillMessage; 
    } 
      
  /******************************************************************************
  @author        Mohit Tayal
  @date          12 Sep 2017
  @param         string-sName, BillingContract__c objContract 
  @return        Bill__c  - objBill
  @description   Create Bill__c object instance and return it.
  *******************************************************************************/
  
  public static TemplateMapping__c createTemplateMapping(String PDFTemplate, String XSLTDocument){
      TemplateMapping__c objTemplateMapping = new TemplateMapping__c(PDFTemplate__c = PDFTemplate, XSLTDocument__c = XSLTDocument);
      return objTemplateMapping; 
    }   
      
  /******************************************************************************
  @author        Mohit Tayal
  @date          18 June 2018
  @param         string-sName, BillingContract__c objContract 
  @return        Bill__c  - objBill
  @description   Create Bill__c object instance and return it.
  *******************************************************************************/
  
  public static TemplateSetting__c createTemplateSetting(TemplateMapping__c objTemplateMapping, String billingEventType, String templateSettingType){
      TemplateSetting__c objTemplateSetting = new TemplateSetting__c(TemplateMapping__c = objTemplateMapping.Id, 
                                                                     BillingEvent__c = billingEventType, 
                                                                     Type__c = templateSettingType);
      return objTemplateSetting; 
    } 
      
   /******************************************************************************
  @author        Mohit Tayal
  @date          18 June 2018
  @param         string-sName, BillingContract__c objContract 
  @return        Bill__c  - objBill
  @description   Create Bill__c object instance and return it.
  *******************************************************************************/
  
  public static BillEvent__c createBillEvent(BillingContract__c objContract, String billEventType){
      BillEvent__c objBillEvent = new BillEvent__c(BillingContract__c = objContract.Id, EventType__c = billEventType);
      return objBillEvent; 
    }  
  /******************************************************************************
  @author        Mohit Tayal
  @date          12 Sep 2017
  @param         string-sName, BillingContract__c objContract 
  @return        Bill__c  - objBill
  @description   Create Bill__c object instance and return it.
  *******************************************************************************/
  
  public static ServiceMessage__c createServiceMessage(String sName, ServiceType__c objServiceType){
      ServiceMessage__c objServiceMessage = new ServiceMessage__c(Name = sName, 
                                                                  MessageText__c = 'testServiceMessage', 
                                                                  ServiceType__c = objServiceType.Id);
      return objServiceMessage; 
    }
      
  /******************************************************************************
  @author        Swati Mathur
  @date          22 Jun 2018
  @param         BillingContract__c objContract, PaymentPlan__c objPaymentPlan

  @return        PaymentPlanCard__c  - objPaymentPlanCard
  @description   Create PaymentPlanCard__c object instance and return it.
  *******************************************************************************/  
  public static PaymentPlanCard__c createPaymentPlanCard(BillingContract__c objContract, PaymentPlan__c objPaymentPlan){
      PaymentPlanCard__c objPaymentPlanCard = new PaymentPlanCard__c();
      objPaymentPlanCard.BillingContract__c = objContract.Id;
      objPaymentPlanCard.PaymentPlan__c = objPaymentPlan.Id;
      return objPaymentPlanCard; 
    }
      
  /******************************************************************************
  @author        Vivek Sethi
  @date          22 Jun 2018
  @param         ContractReference__c objContract
  @return        DirectCreditReturn__c  - objDirectCreditReturn
  @description   Create DirectCreditReturn__c object instance and return it.
  *******************************************************************************/  
  public static DirectCreditReturn__c createDirectCreditReturn(BillingContract__c objContract){
      DirectCreditReturn__c objDirectCreditReturn = new DirectCreditReturn__c();
      objDirectCreditReturn.BillingContract__c = objContract.Id;
      return objDirectCreditReturn; 
    }
      
    /******************************************************************************
    @author        Vivek Sethi
    @date          22 Jun 2018
    @param         ContractReference__c objContract
    @return        DirectCreditReturn__c  - objDirectCreditReturn
    @description   Create DirectCreditReturn__c object instance and return it.
    *******************************************************************************/  
      public static BankAccountDetails__c createBankAccountDetails(Account objAccount){
          BankAccountDetails__c objBankAccountDetails = new BankAccountDetails__c();
          objBankAccountDetails.Account__c = objAccount.Id;
          objBankAccountDetails.BankAccountNumber__c = BANKACCOUNTNUMBER;
          objBankAccountDetails.NameOnAccount__c = NAMEONACCOUNT;
          objBankAccountDetails.BankAccountSortCode__c = BANKACCOUNTNUMBER;
          return objBankAccountDetails; 
      }
      
    /******************************************************************************
    @author        Vivek Sethi
    @date          02 July 2018
    @param         BillingContract__c objContract, Instalment__c objInstalment
    @return        DirectDebitRequest__c  - objDirectDebitRequest
    @description   Create DirectDebitRequest__c object instance and return it.
    *******************************************************************************/  
      public static DirectDebitRequest__c createDirectDebitRequest(BillingContract__c objContract, Instalment__c objInstalment){
          DirectDebitRequest__c objDirectDebitRequest = new DirectDebitRequest__c();
          objDirectDebitRequest.BillingContract__c = objContract.Id;
          objDirectDebitRequest.Instalment__c = objInstalment.Id;
          objDirectDebitRequest.Status__c = 'Returned';
          return objDirectDebitRequest; 
      }
      
    /******************************************************************************
    @author        Vivek Sethi
    @date          03 July 2018
    @param         BillingContract__c objContract
    @return        DirectDebitReturn__c  - objDirectDebitReturn
    @description   Create DirectDebitReturn__c object instance and return it.
    *******************************************************************************/  
      public static DirectDebitReturn__c createDirectDebitReturn(BillingContract__c objContract){
          DirectDebitReturn__c objDirectDebitReturn = new DirectDebitReturn__c();
          objDirectDebitReturn.BillingContract__c = objContract.Id;
          objDirectDebitReturn.Status__c = 'Pending';
          objDirectDebitReturn.Amount__c = 1000;
          return objDirectDebitReturn; 
      }
    /******************************************************************************
    @author        Vivek Sethi
    @date          03 July 2018
    @param         BillingContract__c objContract
    @return        BankAccountChange__c  - objBankAccountChange
    @description   Create BankAccountChange__c object instance and return it.
    *******************************************************************************/  
      public static BankAccountChange__c createBankAccountChange(BillingContract__c objContract){
          BankAccountChange__c objBankAccountChange = new BankAccountChange__c();
          objBankAccountChange.BillingContract__c = objContract.Id;
          objBankAccountChange.Status__c = 'Pending';
          objBankAccountChange.BankAccountSortCode__c = '1234';
          objBankAccountChange.BankAccountNumber__c = '1234';
          objBankAccountChange.NameOnAccount__c = '1234';
          return objBankAccountChange; 
      }
      
   /******************************************************************************
    @author        Vivek Sethi
    @date          04 July 2018
    @param         
    @return        BankAccountAction__c objBankAccountAction
    @description   Create BankAccountAction__c object instance and return it.
    *******************************************************************************/  
      public static BankAccountAction__c createBankAccountAction(){
          BankAccountAction__c objBankAccountAction = new BankAccountAction__c();
          return objBankAccountAction; 
      }
      
  /******************************************************************************
  @author        Mohit Tayal
  @date          05 July 2018
  @param         String sName, ServiceItemFamily__c objServiceItemFamily, 
                 SupplyPointUsageType__c objSupplyPointUsageType, String priority, 
                 String allowanceType, Boolean activeAllowance 
  @return        AllowanceType__c  - objAllowanceType
  @description   Create AllowanceType__c object instance and return it.
  *******************************************************************************/
  
  public static AllowanceType__c createAllowanceType(String sName, ServiceItemFamily__c objServiceItemFamily, SupplyPointUsageType__c objSupplyPointUsageType, 
                                                     String priority, String allowanceType, Boolean activeAllowance){
      AllowanceType__c objAllowanceType = new AllowanceType__c(Name = sName, ServiceItemFamily__c = objServiceItemFamily.Id,
                                                               SupplyPointUsageType__c = objSupplyPointUsageType.Id, 
                                                               AllowanceAmount__c = 50, 
                                                               AllowancePriority__c = priority, 
                                                               Type__c = allowanceType, 
                                                               Active__c = activeAllowance,
                                                               StartDate__c = System.today() - 10);
      return objAllowanceType; 
    }  
      
  /******************************************************************************
  @author        Mohit Tayal
  @date          05 July 2018
  @param         String sName, ServiceItem__c objServiceItem, Integer volume
  @return        SIAgreedVolume__c  - objSIAgreedVolume
  @description   Create SIAgreedVolume__c object instance and return it.
  *******************************************************************************/
  
  public static SIAgreedVolume__c createSIAgreedVolume(String sName, ServiceItem__c objServiceItem, Integer volume){
      SIAgreedVolume__c objSIAgreedVolume = new SIAgreedVolume__c(Name = sName, 
                                                                  ServiceItem__c = objServiceItem.Id, 
                                                                  Volume__c = volume,
                                                                  StartDate__c = System.today() - 10);
      return objSIAgreedVolume; 
    }   
      
  /******************************************************************************
  @author        Mohit Tayal
  @date          05 July 2018
  @param         String sName, ServiceItem__c objServiceItem, AllowanceType__c objAllowanceType,
                 Boolean activeSupplyPointAllowance, SupplyPoint__c objSupplyPoint
  @return        SupplyPointAllowance__c  - objSupplyPointAllowance
  @description   Create SupplyPointAllowance__c object instance and return it.
  *******************************************************************************/
  
  public static SupplyPointAllowance__c createSupplyPointAllowance(String sName, ServiceItem__c objServiceItem, AllowanceType__c objAllowanceType, Boolean activeSupplyPointAllowance,
                                                                  SupplyPoint__c objSupplyPoint){
      SupplyPointAllowance__c objSupplyPointAllowance = new SupplyPointAllowance__c(Name = sName, ServiceItem__c = objServiceItem.Id,
                                                                                    AllowanceAmount__c = objAllowanceType.AllowanceAmount__c,
                                                                                    AllowancePriority__c = objAllowanceType.AllowancePriority__c, 
                                                                                    Active__c = activeSupplyPointAllowance, 
                                                                                    SupplyPoint__c = objSupplyPoint.Id,
                                                                                    StartDate__c = (objServiceItem.StartDate__c > objAllowanceType.StartDate__c ? objServiceItem.StartDate__c : objAllowanceType.StartDate__c),
                                                                                    Type__c = objAllowanceType.Type__c, 
                                                                                    AllowanceType__c =objAllowanceType.Id);
      return objSupplyPointAllowance; 
    }  
      
    /******************************************************************************
  @author        Mohit Tayal
  @date          05 July 2018
  @param         String sName, BillItem__c objBillItem, Integer order, Decimal allowanceApplied, Decimal allowanceAvailable,
                 SIAgreedVolume__c objSIAgreedVolume, SupplyPointAllowance__c objSupplyPointAllowance
  @return        VolumeAlterationItem__c  - objVolumeAlterationItem
  @description   Create VolumeAlterationItem__c object instance and return it.
  *******************************************************************************/
  
  public static VolumeAlterationItem__c createVolumeAlterationItem(String sName, BillItem__c objBillItem, Integer order, Decimal allowanceApplied, 
                                                                   Decimal allowanceAvailable,
                                                                   SIAgreedVolume__c objSIAgreedVolume, 
                                                                   SupplyPointAllowance__c objSupplyPointAllowance){
      VolumeAlterationItem__c objVolumeAlterationItem = new VolumeAlterationItem__c(Name = sName, HerokuPostgresId__c = 'id123', 
                                                                                    Order__c = order, 
                                                                                    BillItem__c = objBillItem.Id,
                                                                                    StartDate__c = System.today() - 10, 
                                                                                    SupplyPointAllowance__c = objSupplyPointAllowance.Id, 
                                                                                    AllowanceApplied__c = allowanceApplied,
                                                                                    ServiceItemAgreedVolume__c = objSIAgreedVolume.Id, 
                                                                                    AllowanceAvailable__c = allowanceAvailable);
      return objVolumeAlterationItem; 
    }
      
    /******************************************************************************
    @author        Dependra Singh
    @date          17 July 2018
    @param         BillingContract__c objContract
    @return        SteppedTariff__c  - objSteppedTariff
    @description   Create SteppedTariff__c object instance and return it.
    *******************************************************************************/  
      public static SteppedTariff__c createSteppedTariff(BillingContract__c objContract, ServiceType__c objServiceType){
          SteppedTariff__c objSteppedTariff = new SteppedTariff__c();
          objSteppedTariff.BillingContract__c = objContract.Id;
          objSteppedTariff.ServiceType__c = objServiceType.Id;
          objSteppedTariff.RenewalMonths__c= 3;
          return objSteppedTariff; 
      }   
      
    /******************************************************************************
    @author        Dependra Singh
    @date          17 July 2018
    @param         BillingContract__c objContract
    @return        SteppedTariff__c  - objSteppedTariff
    @description   Create SteppedTariff__c object instance and return it.
    *******************************************************************************/  
      public static SteppedTariffService__c createSteppedTariffService(SteppedTariff__c objSteppedTariff , Service__c objService){
          SteppedTariffService__c objSteppedTariffService = new SteppedTariffService__c();
          objSteppedTariffService.SteppedTariff__c = objSteppedTariff.Id;
          objSteppedTariffService.Service__c = objService.Id;
          return objSteppedTariffService; 
      }  
      
    /******************************************************************************
    @author        Dependra Singh
    @date          10 Sep 2018
    @param         Account objAcccount
    @return        TariffLimit__c  - objTariffLimit
    @description   Create TariffLimit__c object instance and return it.
    *******************************************************************************/  
      public static TariffLimit__c createTariffLimit(Account objAcccount, string status, Date startDate, Date endDate){
          TariffLimit__c objTariffLimit = new TariffLimit__c();
          objTariffLimit.Account__c = objAcccount.Id;
          objTariffLimit.Status__c = status;
          objTariffLimit.StartDate__c= startDate;
          objTariffLimit.EndDate__c= endDate;
          return objTariffLimit; 
      } 
      
      /******************************************************************************
        @author        Dependra Singh
        @date          10 Sep 2018
        @param         integer priority, string selectionOption
        @return        GroupType__c  - objGroupType
        @description   Create GroupType__c object instance and return it.
      *******************************************************************************/  
      public static GroupType__c createGroupType(string strName,integer priority, string selectionOption){
          GroupType__c objGroupType = new GroupType__c();
          objGroupType.Name =strName;
          objGroupType.Priority__c = priority;
          objGroupType.SelectionOption__c = selectionOption;
          return objGroupType; 
      } 
      
      /******************************************************************************
        @author        Dependra Singh
        @date          10 Sep 2018
        @param         integer priority, string selectionOption
        @return        Group__c  - objGroup
        @description   Create Group__c object instance and return it.
    *******************************************************************************/  
      public static Group__c createGroup( TariffLimit__c objTariffLimit, GroupType__c objGroupType){
          Group__c objGroup = new Group__c();
          objGroup.TariffLimit__c = objTariffLimit.Id;
          objGroup.GroupType__c = objGroupType.Id;
          return objGroup;
      }
              
      /******************************************************************************
        @author        Dependra Singh
        @date          10 Sep 2018
        @param         Group__c objGroup, ServiceItem__c objServiceItem
        @return        GroupItem__c  - objGroupItem
        @description   Create GroupItem__c object instance and return it.
      *******************************************************************************/  
      public static GroupItem__c createGroupItem(Group__c objGroup, ServiceItem__c objServiceItem){
          GroupItem__c objGroupItem = new GroupItem__c();
          objGroupItem.Group__c = objGroup.Id;
          objGroupItem.ServiceItem__c = objServiceItem.Id;
          return objGroupItem; 
      }   
      
    /******************************************************************************
    @author        Hasan Faisal
    @date          17 July 2018
    @param         SupplyPoint__c objSupplyPoint
    @return        SupplyPointBand__c  - objSupplyPointBand
    @description   Create SupplyPointBand__c object instance and return it.
    *******************************************************************************/  
      public static SupplyPointBand__c createSupplyPointBand(SupplyPoint__c objSupplyPoint ){
          SupplyPointBand__c objSupplyPointBand = new SupplyPointBand__c();
          
          objSupplyPointBand.StartDate__c = system.today();
          return objSupplyPointBand; 
      } 
   /******************************************************************************
    @author        Hasan Faisal
    @date          17 July 2018
    @param         BillingContract__c objContract
    @return        SteppedTariff__c  - objSteppedTariff
    @description   Create SteppedTariff__c object instance and return it.
    *******************************************************************************/  
      public static BandType__c createBandType(string LowerV,  string UpperV ){
          BandType__c objBandType = new BandType__c();
          objBandType.Name = 'TestBandOne'; 
          objBandType.LowerValue__c = LowerV;
          objBandType.UpperValue__c = UpperV;
          return objBandType; 
      } 
      
    /******************************************************************************
    @author        Neha Rajput
    @date          16 Aug 2018
    @param         Account objAccount,Date startDate, String status
    @return        TariffLimit__c  - objTariffLimit
    @description   Create TariffLimit__c object instance and return it.
    *******************************************************************************/  
      public static TariffLimit__c createTariffLimit(Account  objAccount, Date startDate, String status){
          TariffLimit__c objTariffLimit = new TariffLimit__c(Account__c = objAccount.Id, StartDate__c = startDate, Status__c = status);          
          return objTariffLimit; 
      } 
      
    /******************************************************************************
    @author        Neha Rajput
    @date          16 Aug 2018
    @param         String groupTypeName
    @return        GroupType__c  - objGroupType
    @description   Create GroupType__c object instance and return it.
    *******************************************************************************/  
      public static GroupType__c createGroupType(String groupTypeName){
          GroupType__c objGroupType = new GroupType__c(Name = groupTypeName);          
          return objGroupType; 
      }

    /******************************************************************************
    @author        Echo: Mohit Tayal
    @date          27 Aug 2018
    @param         DebtRecoveryProcess__c objDebtRecoveryProcess
                   Instalment__c objInstalment
    @return        DebtRecoveryInstalment__c -- objDebtRecoveryInstalment  
    @description   Create DebtRecoveryInstalment__c object instance and return it.
    *******************************************************************************/
      public static DebtRecoveryInstalment__c createDebtRecoveryInstalment(DebtRecoveryProcess__c objDebtRecoveryProcess, Instalment__c objInstalment){  
        DebtRecoveryInstalment__c objDebtRecoveryInstalment = new DebtRecoveryInstalment__c(DebtRecoveryProcess__c = objDebtRecoveryProcess.id, 
                                                                                            Instalment__c = objInstalment.Id);        
        return objDebtRecoveryInstalment; 
    }   
      
    /******************************************************************************
    @author        Echo: Neha Rajput
    @date          13/09/2018
    @param         
    @return        ConfigureTemplate__c  objConfigureTemplate  
    @description   Create ConfigureTemplate__c custom setting object instance and return it.
                    AT-3157Core7b
    *******************************************************************************/
    public static ConfigureTemplate__c createConfigureTemplate(String email){  
        ConfigureTemplate__c objConfigureTemplate = new ConfigureTemplate__c(PrintedLetterEmailAddress__c = email);        
        return objConfigureTemplate; 
    }  
      
    /******************************************************************************
    @author        Echo: Neha Rajput
    @date          20/09/2018
    @param         
    @return        BillWriteOff__c  objConfigureTemplate  
    @description   Create BillWriteOff__c custom setting object instance and return it.
                    AT-3703 Corecc
    *******************************************************************************/
    public static BillWriteOff__c createBillWriteOff(Bill__c objBill,String status, String writeOffReason){  
        BillWriteOff__c objBillWriteOff = new BillWriteOff__c(Bill__c=objBill.id,Status__c = status, WriteOffReason__c = writeOffReason);        
        return objBillWriteOff;  
    }
      
    /******************************************************************************
    @author        Echo: Neha Rajput
    @date          30 Oct 2018
    @param         
    @return        InformationStatement__c  objInformationStatement
    @description   Create InformationStatement custom setting object instance and return it.
                    AT-4134
    *******************************************************************************/
    public static InformationStatement__c createInformationStatement(BillingContract__c objBillingContract, Location__c objLocation, Service__c objService){  
        
        InformationStatement__c objInformationStatement = new InformationStatement__c(BillingContract__c=objBillingContract.Id, Service__c= objService.Id);    
        if(objLocation != null)
            objInformationStatement.Location__c = objLocation.Id;
        return objInformationStatement;  
    }
      
    /******************************************************************************
    @author        Echo: Neha Rajput
    @date          30 Oct 2018
    @param         
    @return        InformationStatementMessage__c  objInformationStatementMessage
    @description   Create InformationStatementMessage custom setting object instance and return it.
                    AT-4134
    *******************************************************************************/
    public static InformationStatementMessage__c createInformationStatementMessage(InformationStatement__c objInformationStatement, Message__c objMessage,Boolean activeFlag){  
        InformationStatementMessage__c objInformationStatementMessage = new InformationStatementMessage__c(InformationStatement__c=objInformationStatement.Id, Message__c = objMessage.Id,Active__c =activeFlag );        
        return objInformationStatementMessage;  
    }
      
    /******************************************************************************
    @author        Echo: Neha Rajput
    @date          30 Oct 2018
    @param         
    @return        Message__c  objMessage
    @description   Create Message custom setting object instance and return it.
                    AT-4134
    *******************************************************************************/
    public static Message__c createMessage(String description, Boolean activeFlag, Boolean defaultFlag, Boolean selectableFlag,String typeValue){  
        Message__c objMessage = new Message__c(Description__c=description,Active__c=activeFlag, Default__c = defaultFlag,Selectable__c =selectableFlag,Type__c= typeValue );        
        return objMessage;  
    }
      
    /******************************************************************************
    @author        Vivek Sethi
    @date          14 Dec 2018
    @param     
    @return        RuralLicense__c  - objRuralLicense
    @description   Create RuralLicense object instance and return it.
    *******************************************************************************/  
      public static RuralLicense__c createRuralLicense(){
          RuralLicense__c objRuralLicense = new RuralLicense__c();
          objRuralLicense.StartDate__c = system.today();
          objRuralLicense.Status__c = 'Pending';
          return objRuralLicense; 
      } 
   
    /******************************************************************************
    @author        Vivek Sethi
    @date          14 Dec 2018
    @param         RuralLicense__c objRuralLicense
    @return        RuralEntitlement__c  - ObjRuralEntitlement
    @description   Create RuralEntitlement__c object instance and return it.
    *******************************************************************************/  
      public static RuralEntitlement__c createRuralEntitlement(RuralLicense__c objRuralLicense){
          RuralEntitlement__c objRuralEntitlement = new RuralEntitlement__c();
          objRuralEntitlement.RuralLicense__c = objRuralLicense.Id;
          return objRuralEntitlement; 
      } 
      
    /******************************************************************************
    @author        Neha Rajput 
    @date          18 Dec 2018
    @param         Area__c objArea,Depot__c objDepot
    @return        RuralChannel__c  - ObjRuralChannel
    @description   Create RuralChannel object instance and return it.
    *******************************************************************************/  
      public static RuralChannel__c createRuralChannel(Area__c objArea,Depot__c objDepot){
          RuralChannel__c objRuralChannel = new RuralChannel__c(Area__c = objArea.Id,Depot__c = objDepot.Id);          
          return objRuralChannel; 
      }
      
      /******************************************************************************
    @author        Neha Rajput 
    @date          18 Dec 2018
    @param         Location__c objLocation, RuralChannel__c objRuralChannel, 
                RuralEntitlement__c objRuralEntitlement,Integer volume
    @return        RuralOrder__c  - ObjRuralOrder
    @description   Create RuralOrder object instance and return it.
    *******************************************************************************/  
      public static RuralOrder__c createRuralOrder(Location__c objLocation, RuralChannel__c objRuralChannel, RuralEntitlement__c objRuralEntitlement,Integer volume){
          RuralOrder__c objRuralOrder = new RuralOrder__c(Location__c=objLocation.Id,RuralChannel__c=objRuralChannel.Id,RuralEntitlement__c=objRuralEntitlement.Id,OrderVolume__c=volume);          
          return objRuralOrder; 
      }
          
    /******************************************************************************
    @author        Vivek Sethi
    @date          14 Dec 2018
    @param         RuralEntitlement__c  - ObjRuralEntitlementTransferTo, ObjRuralEntitlementTransferFrom.
    @return        RuralTransfer__c  - objRuralTransfer
    @description   Create RuralTransfer object instance and return it.
    *******************************************************************************/  
      public static RuralTransfer__c createRuralTransfer(RuralEntitlement__c objRuralEntitlementTransferTo , RuralEntitlement__c objRuralEntitlementTransferFrom, Decimal transferAmount, String transferType){
          RuralTransfer__c objRuralTransfer = new RuralTransfer__c();
          objRuralTransfer.TransferFrom__c = objRuralEntitlementTransferFrom.Id;
          objRuralTransfer.TransferTo__c =  objRuralEntitlementTransferTo.Id;
          objRuralTransfer.TransferAmount__c = transferAmount;
          objRuralTransfer.TransferType__c = transferType;

          return objRuralTransfer; 
      }
      /******************************************************************************
    @author        Neha Rajput 
    @date          20 Dec 2018
    @param         RuralChannel__c objRuralChannel,
                   RuralOrder__c objRuralOrder ,
                   SupplyPoint__c objSupplyPoint
    @return        RuralMeasurement__c  - ObjRuralMeasurement
    @description   Create RuralMeasurement object instance and return it.
    *******************************************************************************/  
      public static RuralMeasurement__c createRuralMeasurement(RuralChannel__c objRuralChannel ,SupplyPoint__c objSupplyPoint,Integer head){
          RuralMeasurement__c objRuralMeasurement = new RuralMeasurement__c(RuralChannel__c= objRuralChannel.Id,
                                                                            SupplyPoint__c= objSupplyPoint.Id,
                                                                            Head__c= head);          
          return objRuralMeasurement; 
      }
      
    /******************************************************************************
    @author        Neha Rajput 
    @date          20 Dec 2018
    @param         RuralMeasurement__c objArea,Depot__c objDepot
    @return        ChannelFlowConversion__c  - ObjChannelFlowConversion
    @description   Create RuralMeasurement object instance and return it.
    *******************************************************************************/  
      public static ChannelFlowConversion__c createChannelFlowConversion(RuralChannel__c objRuralChannel, Integer headReading,Integer flowRate ){
          ChannelFlowConversion__c objChannelFlowConversion = new ChannelFlowConversion__c(Channel__c =objRuralChannel.Id ,FlowRate__c = flowRate);          
          return objChannelFlowConversion; 
      }
      
    /******************************************************************************
    @author        Vivek Sethi
    @date          03 Jan 2019
    @param         RuralChannel__c objRuralChannel.
    @return        ChannelOpen__c  - objChannelOpen
    @description   Create ChannelOpen__c object instance and return it.
    *******************************************************************************/  
      public static ChannelOpen__c createChannelOpen(RuralChannel__c objRuralChannel){
          ChannelOpen__c objChannelOpen = new ChannelOpen__c();
          objChannelOpen.RuralChannel__c = objRuralChannel.Id;
          objChannelOpen.StartDate__c = system.today();
          return objChannelOpen; 
      }
          
    /******************************************************************************
    @author        Vivek Sethi
    @date          03 Jan 2019
    @param         RuralChannel__c objRuralChannel.
    @return        RuralGrossConsumption__c  - objRuralGrossConsumption
    @description   Create ChannelOpen__c object instance and return it.
    *******************************************************************************/  
      public static RuralGrossConsumption__c createRuralGrossConsumption(RuralEntitlement__c objRuralEntitlement, SupplyPoint__c objSupplyPoint){
          RuralGrossConsumption__c objRuralGrossConsumption = new RuralGrossConsumption__c();
          objRuralGrossConsumption.StartDate__c = system.today();
          objRuralGrossConsumption.RuralEntitlement__c = objRuralEntitlement.Id;
          objRuralGrossConsumption.SupplyPoint__c = objSupplyPoint.Id;
          objRuralGrossConsumption.Type__c =   'Head';
          objRuralGrossConsumption.Consumption__c = 200;
          return objRuralGrossConsumption; 
      }
      
    /******************************************************************************
    @author        Vivek Sethi
    @date          07 Jan 2019
    @param         Account objAccount.
    @return        Concession__c   - objConcession
    @description   Create Concession__c  object instance and return it.
    *******************************************************************************/  
      public static Concession__c  createConcession(Account objAccount){
          Concession__c  objConcession = new Concession__c ();
          objConcession.StartDate__c = system.today();
          objConcession.Account__c = objAccount.Id;
          objConcession.Type__c = 'Health Card';
          objConcession.ConfirmDate__c  =   System.today() ;    //AT-4849
          objConcession.CRN__c =    '123456789ABCD' ;           //AT-4849
          return objConcession; 
      }
      
    /******************************************************************************
    @author        Vivek Sethi
    @date          15 Jan 2019
    @param         
    @return        BankBranch__c   - objBankBranch
    @description   Create BankBranch__c  object instance and return it.
    *******************************************************************************/  
      public static BankBranch__c  createBankBranch(){
          BankBranch__c  objBankBranch = new BankBranch__c ();
          objBankBranch.Name = 'Test';
          objBankBranch.BankName__c = 'TestBankName';
          objBankBranch.BranchAddress__c = 'AddressTest';
          return objBankBranch; 
      }
      
      
        /******************************************************************************
        @author        Sudhir Kumar
        @date          01 Feb 2019
        @param         Id serviceTypeId1, Id serviceTypeId2, Id divisionId1, Id divisionId2, Id wholesalerId1, 
                       Id wholesalerId2, String bundleName1, String bundleName2, String supplyPointUsageType
        @return        LocationUpload__c   - objLocationUpload
        @description   Create LocationUpload__c  object instance and return it.
        *******************************************************************************/  
        public static LocationUpload__c  createLocationUpload(Id serviceTypeId1, Id serviceTypeId2, Id divisionId1, Id divisionId2, Id wholesalerId1, 
                                                            Id wholesalerId2, String bundleName1, String bundleName2, String supplyPointUsageType) {
          LocationUpload__c objLocationUpload = new LocationUpload__c(City__c = 'Noida', PostalCode__c = '201301', State__c = 'Uttar Pradesh', 
                                                            Street__c = 'C Block', Country__c = 'India', LocationType__c = 'Household', 
                                                            BuildDate__c = Date.newInstance(2019, 1, 30), 
                                                            SupplyPointUsageType__c = supplyPointUsageType,
                                                            VoidProfile__c = 'HH Void Management Profile',
                                                            LocationSubType__c = 'Flat', 
                                                            ServiceType1__c = serviceTypeId1,
                                                            ServiceType2__c = serviceTypeId2,
                                                            DivisionService1__c = divisionId1,
                                                            DivisionService2__c = divisionId2,
                                                            WholesalerService1__c = wholesalerId1,
                                                            WholesalerService2__c = wholesalerId2,
                                                            SpecialInstructions__c = 'Test Instructions',
                                                            Service1AvailableBundle__c = bundleName1,
                                                            Service2AvailableBundle__c = bundleName2,
                                                            Geolocation__latitude__s = 37.775,
                                                            Geolocation__longitude__s = -122.418,
                                                            Processed__c = false
                                                            ) ;
          return objLocationUpload ; 
      }
        /******************************************************************************
        @author        Amit Kumar
        @date          06 Feb 2019
        @param         Id bookId,Id supplyPointId,Id locationId, Id serviceTypeId1, 
                       Id serviceTypeId2, String bundleName1, String bundleName2 
        @return        DeviceUploadStaging__c   - objDeviceUpload
        @description   Create DeviceUploadStaging__c  object instance and return it.
        *******************************************************************************/
      public static DeviceUploadStaging__c  createDeviceUpload(Id bookId,Id supplyPointId,Id locationId, Id serviceTypeId1, Id serviceTypeId2, String bundleName1, String bundleName2) {
          DeviceUploadStaging__c objDeviceUpload = new DeviceUploadStaging__c(SupplyPoint__c = supplyPointId,Book__c = bookId,LocationNo__c = locationId,
                                                                              Service1__c = serviceTypeId1, Service2__c = serviceTypeId2,
                                                                              Service1AvailableBundle__c = bundleName1, Service2AvailableBundle__c = bundleName2
                                                                             );
          return objDeviceUpload;
      }
      
      /******************************************************************************
    @author        Tarun Gupta 
    @date          11 Feb 2019
    @param         Bill__c objLocation, BillingContract__c objRuralChannel, String status
    @return        BillExport__c  - objBillExport
    @description   Create Bill Export object instance and return it.
    *******************************************************************************/  
      public static BillExport__c createBillExport(Bill__c objBill, BillingContract__c objContract, String status){
          BillExport__c objBillExport = new BillExport__c(Bill__c=objBill.Id,BillingContract__c=objContract.Id,Status__c=status);          
          return objBillExport; 
      }
      
      
      /******************************************************************************
    @author        Tarun Gupta 
    @date          11 Feb 2019
    @param         Bill__c objLocation, BillingContract__c objRuralChannel, String status
    @return        BillExport__c  - objBillExport
    @description   Create Bill Export object instance and return it.
    *******************************************************************************/  
      public static DHHS__c createDHHSCustomSetting(Integer authorityId, String strAuthorityName){
          DHHS__c objDHHS = new DHHS__c();
          objDHHS.AuthorityID__c = authorityId;
          objDHHS.AuthorityName__c = strAuthorityName;
          return objDHHS; 
      }
      
            
    /******************************************************************************
    @author        Vivek Sethi
    @date          15 Feb 2019
    @param         SupplyPoint__c objSiteSupplyPoint, SupplyPoint__c objSupplyPoint
    @return        SiteSupply__c objSiteSupply
    @description   Create Site Supply object instance and return it.
    *******************************************************************************/  
      public static SiteSupply__c createSiteSupply(SupplyPoint__c objSiteSupplyPoint, SupplyPoint__c objSupplyPoint){
          SiteSupply__c objSiteSupply = new SiteSupply__c(SiteSupplyPoint__c = objSiteSupplyPoint.Id, SupplyPoint__c = objSupplyPoint.Id , StartDate__c = System.today());          
          return objSiteSupply; 
      }
    /******************************************************************************
    @author        Dependra Singh
    @date          05 March 2019
    @param         Region__c objRegion, SupplyPoint__c objSupplyPoint
    @return        SiteSupply__c objSiteSupply
    @description   Create Site Supply object instance and return it.
    *******************************************************************************/  
      public static Region__c createRegion(string strName, boolean isAU, boolean isUK, boolean isUS){
          Region__c objRegion = new Region__c(Name__c =strName, AU__c = isAU, UK__c = isUK , US__c = isUS);          
          return objRegion ; 
      } 
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        11 Mar 2019
    @description: Combiz Interface Custom meta data setting
    *******************************************************************************/ 
      public static void setCombizInterfaceMetaData(){
          GlUt_CustomMetaDataUtility.setMetadata(PyBt_Constants.COMBIZMETADATAQUERY,(List<CombizInterface__mdt>) JSON.deserialize( 
              '[{"' + PyBt_Constants.COMBIZ_BANKACCOUNT_FIELD + '":"' + PyBt_Constants.COMBIZ_BANKACCOUNT_VALUE + '","' + 
              PyBt_Constants.COMBIZ_BANKBRANCH_FIELD + '":"' + PyBt_Constants.COMBIZ_BANKBRANCH_VALUE + '","' + 
              PyBt_Constants.COMBIZ_DDFILENAME_FIELD + '":"' + PyBt_Constants.COMBIZ_DDFILENAME_VALUE + '","' + 
              PyBt_Constants.COMBIZ_DDLODGEMENT_FIELD + '":"' + PyBt_Constants.COMBIZ_DDLODGEMENT_VALUE + '","' + 
              PyBt_Constants.COMBIZ_PROCESSINGDAYS_FIELD + '":"' + PyBt_Constants.COMBIZ_PROCESSINGDAYS_VALUE + '","' + 
              PyBt_Constants.COMBIZ_REFUNDFILENAME_FIELD + '":"' + PyBt_Constants.COMBIZ_REFUNDFILENAME_VALUE + '","' + 
              PyBt_Constants.COMBIZ_REFUNDLODGEMENTREFERENCE_FIELD + '":"' + PyBt_Constants.COMBIZ_REFUNDLODGEMENTREFERENCE_VALUE + '","' + 
              PyBt_Constants.COMBIZ_USERBANK_FIELD + '":"' + PyBt_Constants.COMBIZ_USERBANK_VALUE + '","' + 
              PyBt_Constants.COMBIZ_USERNAME_FIELD + '":"' + PyBt_Constants.COMBIZ_USERNAME_VALUE + '","' + 
              PyBt_Constants.COMBIZ_USERNUMBER_FIELD + '":"' + PyBt_Constants.COMBIZ_USERNUMBER_VALUE + '"}]', 
              List<CombizInterface__mdt>.class ));  
      }
      
  }