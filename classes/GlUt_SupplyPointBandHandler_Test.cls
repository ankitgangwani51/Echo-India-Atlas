@isTest
public class GlUt_SupplyPointBandHandler_Test {
   
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String ACCOUNT_NAME = 'TEST_ACCOUNT';
    private static final String LOCATION_NAME = 'A99 9AA';
    private static final String LOCATION_NAME2 = 'A89 9AA';    
    private static final String MEASURED ='Yes';
    private static final String READFREQUENCY_M = 'Monthly'; 
    private static final String READFREQUENCY_HY = 'Half Yearly';
    private static final String CONTYPE_NAME ='Test Consideration Type';
    private static final String DISCONNECTED_STATUS = 'Shared Supply';
    private static final String SUPPLYDISCONNECTIONSTATUS = 'Able to Disconnect';
    private static final String NULL_VALUE = null ;
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String SP_USAGE_TYPE2 = 'SupplyPointUsageType2';
    private static final String READFREQUENCY_Q = 'Quarterly';
    private static final String READTIMETABLE_NAME = 'RTT1';
    private static final String READTIMETABLE_NAME1 = 'RTT2';
    private static final String DEPOT_NAME = 'depot1';
    private static final String DEPOT_NAME1 = 'depot2';
    private static final String PAYMENT_METHOD_TYPE1 = 'Payment Card';    
    private static final String PLAN_NAME = 'MEASURED MONTHLY';
    private static final String PAY_FREQ = 'Monthly';
    private static final Integer FORECAST_AMOUNT = 200;
    private static final Integer PAYPLAN_AMOUNT = 500;    
    private static final String TESTSERVICE_TYPE1 ='water service';
    private static final Integer NUM_OF_INSTAL = 12;
    private static final Integer NUM_OF_ROLLING_INSTAL = 2;
    private static final String CONTACT_NAME = 'Test Contact';
    private static final String MONTHLY = Label.CuAp_PaymentPlanTypePaymentFrequencyMonthly;
    private static final String DAY_OF_MONTH = '2';
    private static final String DAY_OF_WEEK = 'Monday';
    private static final String FOUR_WEEKLY = 'Four weekly';
    private static final String ANNUAL = 'Annual';
    private static final String DEVICE_SERIALNO     = '1234';
    private static final String AVAILABLESERVICES = 'avail service';    
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';    
    private static final String WHOLESALER = 'wholesaler';    
    private static final String LowerV = '1';   
    private static final String UpperV = '5';   
    private static final Boolean isException;
   private static String TEST_SERVICE_TYPE ='TestServiceType';
    private static String BUNDLENAME ='TestBundle';
    private static final String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static final String BUNDLEITEM ='TestBundleItem';
    private static final String SERVICEITEMFAMILY ='TestServiceItemFamily';
    private static final String SERVICEITEMTYPE ='TestServiceitemtype';
    
    @TestSetup
    static void createTestData()
    {
        
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        Database.insert(objLocation);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create Depot Record
        Depot__c objDepot = GlUt_FactoryData_Test.createDepot(DEPOT_NAME);        
        Database.insert(objDepot);
        
        // Create ReadTimetable Record
        ReadTimetable__c objReadTimetable1 = GlUt_FactoryData_Test.createReadTimetable(READTIMETABLE_NAME, READFREQUENCY_M);        
        Database.insert(objReadTimetable1);
        
        // Create Book Record
        Book__c objBook1 = GlUt_FactoryData_Test.createBook(objDepot,objReadTimetable1) ; 
        objBook1.ReadFrequency__c = FOUR_WEEKLY;
        objBook1.BudgetResetMonth__c = 'April;September;November';
        Database.insert(objBook1);
        
        
        // Create BandType Record 
        List<BandType__c> bandTypeList = new  List<BandType__c>();
        BandType__c  objBandType = GlUt_FactoryData_Test.createBandType( LowerV,  UpperV );
        objBandType.Name = 'TestBandType';
        bandTypeList.add(objBandType);
        
        
        BandType__c  objBandType2 = GlUt_FactoryData_Test.createBandType( LowerV,  UpperV );
        objBandType2.Name = 'TestBandType2';
         bandTypeList.add(objBandType2);
        Database.insert(bandTypeList);
        
        // Create SupplyPoint Record        
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        //objSupplyPoint.Measured__c = MEASURED;
  
        objSupplyPoint.Book__c = objBook1.Id;
        objSupplyPoint.WalkOrder__c = 5;
        objSupplyPoint.Depot__c = objDepot.Id;
        Database.insert(objSupplyPoint);
        
        // Create SupplyPointBand Record 
        //List<SupplyPointBand__c> SPBList = new  List<SupplyPointBand__c>();       
        SupplyPointBand__c objSupplyPointBand = GlUt_FactoryData_Test.createSupplyPointBand(objSupplyPoint);
        objSupplyPointBand.BandType__c = objBandType.id;
        objSupplyPointBand.SupplyPoint__c = objSupplyPoint.id;
        
        objSupplyPointBand.EndDate__c = System.Today() + 2;
        Database.insert(objSupplyPointBand);
        
        // Create SupplyPointBand Record        
        SupplyPointBand__c objSupplyPointBand2 = GlUt_FactoryData_Test.createSupplyPointBand(objSupplyPoint);
        objSupplyPointBand2.BandType__c = objBandType.id;
        objSupplyPointBand2.SupplyPoint__c = objSupplyPoint.id;
        objSupplyPointBand2.StartDate__c = System.Today() + 3 ;
        objSupplyPointBand2.EndDate__c = System.Today() + 4 ;
        
        Database.insert(objSupplyPointBand2);
        
        //Create service record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE);
        Database.insert(objServiceType);
        
         //Create service record
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        //Create service record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        //Create service record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME,objServiceType);
        Database.insert(objBundle);
        
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(BUNDLENAME,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
        Bundle__c objBundle1 = GlUt_FactoryData_Test.CreateBundle(BUNDLENAME +'-1',objServiceType);
        Database.insert(objBundle1);
        
          AvailableBundle__c objAvailableBundle1 = GlUt_FactoryData_Test.CreateAvailableBundle(BUNDLENAME,objBundle1,objAvailableService);
       // objAvailableBundle1.LastBundleChangeDate__c
        Database.insert(objAvailableBundle1);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
            DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
            Database.insert(objDeviceSize);
        
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
            Database.insert(objDeviceType);

        
         ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
            Database.insert(objServiceItemFamily);
            ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
            Database.insert(objServiceItemType);
            
            ServiceItemType__c  objServiceItemType2 = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
            Database.insert(objServiceItemType2);
        
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
            Database.insert(objBundleItem);
        
        List<AvailableServiceItem__c> lstAvailableServiceItem = new List<AvailableServiceItem__c>();
            AvailableServiceItem__c  objAvailableServiceItem1 = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle1);
            objAvailableServiceItem1.ServiceItemType__c = objServiceItemType.Id;
        objAvailableServiceItem1.SupplyPointBand__c = objSupplyPointBand.Id;
            lstAvailableServiceItem.add(objAvailableServiceItem1); 
            AvailableServiceItem__c  objAvailableServiceItem2 = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle1);
            objAvailableServiceItem2.ServiceItemType__c = objServiceItemType.Id;
            lstAvailableServiceItem.add(objAvailableServiceItem2);
            Database.insert(lstAvailableServiceItem);
        

        
    }    
    /**************************************************************************************
    @author         Echo: Sudhir 
    @date           23 July 2018
    @description    Test if meathod finds the BandLimitexception when insertig new SPB
    ********************************************************************************************/    
    static testmethod void processSupplyPointBandDateChange_Positive() {
        User objUser =[SELECT Id, Name FROM User WHERE isActive = TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1] ;
        List<SupplyPointBand__c> supplyPointBandList = [Select Id, BandType__c, SupplyPoint__c, StartDate__c, EndDate__c from SupplyPointBand__c LIMIT 1] ;
        system.debug('Test supplyPointBandList = ' + supplyPointBandList);
        list<SupplyPointBand__c> listSPB = new list<SupplyPointBand__c>();
        for(SupplyPointBand__c spb : supplyPointBandList) {
            spb.StartDate__c = System.today() + 10 ;
            spb.EndDate__c = System.today() + 20 ;
            listSPB.add(spb) ;
        }
        System.runAs(objUser){ 
            system.debug('Test listSPB = ' + listSPB);
        	Database.update(listSPB) ;
            System.assertEquals(System.today() + 10, supplyPointBandList[0].StartDate__c);
        }
    }
  
    /**************************************************************************************
    @author         Echo: Hasan 
    @date           23 July 2018
    @description    Test if meathod finds the BandLimitexception when insertig new SPB
********************************************************************************************/    
    static testmethod void ValidateSupplyPointBand_BU()
    {
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        //List<BandType__c> bandTypeList = [select id from BandType__c];
        List<SupplyPointBand__c> supplyPointBandList = [select id,BandType__c,SupplyPoint__c, StartDate__c from SupplyPointBand__c];
        
        //List<Location__c> locationList = [select id from Location__c Limit 1];
        List<SupplyPoint__c> supplyPointList = [select id from SupplyPoint__c];
        SupplyPointBand__c SPB = new SupplyPointBand__c();
        //ListSPB.add(spb);
        SPB.id = supplyPointBandList[0].id;
        SPB.SupplyPoint__c = supplyPointList[0].id;
        SPB.BandValue__c = '2';
        //SPB.StartDate__c =  System.Today() + 5 ; 
        //SPB.EndDate__c =  System.Today() + 6 ;
        
        System.runAs(objUser){
            Try{
                Test.startTest();             
                update SPB;
                Test.stopTest();
            }
            Catch(exception e)
            {
                Boolean expectedExceptionThrown =  (e.getMessage().contains(System.Label.Glut_BandsOverlapException)) ? true : false;
                System.AssertEquals(expectedExceptionThrown, true); 
            }  
        }
    } 
}