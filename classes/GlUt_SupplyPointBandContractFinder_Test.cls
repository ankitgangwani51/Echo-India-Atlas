@isTest
public class GlUt_SupplyPointBandContractFinder_Test {
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String ACCOUNT_NAME = 'TEST_ACCOUNT';
    private static final String LOCATION_NAME = 'A99 9AA';    
    private static final String MEASURED ='Yes';
    private static final String READFREQUENCY_M = 'Monthly'; 
    private static final String READFREQUENCY_HY = 'Half Yearly';
    private static final String CONTYPE_NAME ='Test Consideration Type';
    private static final String DISCONNECTED_STATUS = 'Shared Supply';
    private static final String SUPPLYDISCONNECTIONSTATUS = 'Able to Disconnect';
    private static final String NULL_VALUE = null ;
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
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
    private static final String DEVICE_SERIALNO 	= '1234';
    private static final String AVAILABLESERVICES = 'avail service';    
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';    
    private static final String WHOLESALER = 'wholesaler';    
    
    
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
        
        // Create SupplyPoint Record        
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; // AT-3174 

        objSupplyPoint.Book__c = objBook1.Id;
        objSupplyPoint.WalkOrder__c = 5;
        objSupplyPoint.Depot__c = objDepot.Id;
        Database.insert(objSupplyPoint);
        
        // Create SupplyPointBand Record        
        SupplyPointBand__c objSupplyPointBand = GlUt_FactoryData_Test.createSupplyPointBand(objSupplyPoint);
        objSupplyPointBand.SupplyPoint__c = objSupplyPoint.Id;
        objSupplyPointBand.StartDate__c = system.today();
        Database.insert(objSupplyPointBand);
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record
        Device__c  objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICE_SERIALNO , objDeviceType);        
        objDevice.SerialNo__c = DEVICE_SERIALNO;
        Database.insert(objDevice);
        // Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);        
        Database.insert(objAccount);
        //Create Balance Record
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);
        Database.insert(objBalance);
        
        //Create payment method type Record        
        PaymentMethodType__c  objPaymentMethodType = GlUt_FactoryData_Test.createPaymentMethodType();
        objPaymentMethodType.Name = PAYMENT_METHOD_TYPE1;
        Database.insert(objPaymentMethodType);  
        
        //Create payment plan type Record
        PaymentPlanType__c  objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PLAN_NAME,PAY_FREQ,NUM_OF_INSTAL);
        objPaymentPlanType.PlanType__c = Label.CuAp_PaymentPlanTypePlanTypeBudgetPlan;
        objPaymentPlanType.FinalPaymentPlan__c = false;
        objPaymentPlanType.DaysNotice__c = 10;
        objPaymentPlanType.Active__c = true;
        objPaymentPlanType.PaymentFrequency__c = MONTHLY;
        objPaymentPlanType.NumberofRollingInstalments__c = NUM_OF_ROLLING_INSTAL;
        Database.insert(objPaymentPlanType); 
        
        //Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTACT_NAME,objAccount);
        objContract.DayOfMonth__c = DAY_OF_MONTH;
        objContract.DayOfWeek__c = DAY_OF_WEEK;
        objContract.CurrentPaymentPlanType__c = objPaymentPlanType.Id;
        objContract.Balance__c = objBalance.Id;
        objContract.PaymentMethodType__c = objPaymentMethodType.id;
        Database.insert(objContract); 
        
        // Create Division Record
        Division__c  objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        // Create Wholesaler Record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading);
        
        //Create Service Type Record 
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE1);
        Database.insert(objServiceType);  
        
        // Create Available Service Record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        // Create Service Record 
        Service__c  objOldService1 = GlUt_FactoryData_Test.createService(objContract, objReading , objServiceType, objSupplyPoint, objAvailableService);
        objOldService1.SupplyPoint__c = objSupplyPoint.Id;      
        Database.insert(objOldService1);        
    }
   /**************************************************************************************
	@author    		Echo: Hasan 
	@date      		19 July 2018
	@description 	Test if meathod finds the set of contract Ids affected by Supply Point Band
	********************************************************************************************/
    
    static testmethod void retrieveContractIds_positive()
        
    {
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<SupplyPointBand__c> supplyPointBandId = [select id,SupplyPoint__c, StartDate__c from SupplyPointBand__c];
        GlUt_SupplyPointBandContractFinder  SPB_ContractFinder = new GlUt_SupplyPointBandContractFinder();
        
        System.runAs(objUser){
            Test.startTest();             
            Set<Id> contractIds = SPB_ContractFinder.retrieveContractIds(supplyPointBandId[0].id);           
            Test.stopTest(); 
            system.assert(contractIds != null);
        }
        
    }
    /*******************************************************************************************
	@author    		Echo: Hasan 
	@date      		19 July 2018
	@description 	Test if meathod finds the set of contract Ids affected by Supply Point Band
	********************************************************************************************/
    static testmethod void retrieveContractIds_negative()
        
    {
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        List<SupplyPointBand__c> supplyPointBandId = [select id,SupplyPoint__c, StartDate__c from SupplyPointBand__c];
        GlUt_SupplyPointBandContractFinder  SPB_ContractFinder = new GlUt_SupplyPointBandContractFinder();
        Set<Id> contractIds;
        System.runAs(objUser){
            Try{
                Test.startTest();
                String invalidId = null;
                contractIds = SPB_ContractFinder.retrieveContractIds(invalidId);
                Test.stopTest();
            }
            Catch(exception e){
            }
            system.assert(contractIds.isEmpty());
            
        }
    }
}