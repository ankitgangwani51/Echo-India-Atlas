/******************************************************************************
@author:      Echo: Ankit Gangwani 
@date:        04 July 2018
@description: Test Class for GlUt_BusinessDays
@Revisions	  	AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest 
public class GlUt_ForecastedResultHandler_Test {
    
    private static final String USER_PROFILE 		= 'System Administrator';
    private static final String USER_NAME 			= 'TestUser';
    private static final String USERNAMECOMPLETE  	= USER_NAME + '@unitest.com';
    private static final String USER_FNAME 			= 'First_User_Name';
    private static final String USER_LNAME 			= 'Last_User_Name'; 
    private static final String NAME 				= 'Test';
    private static final String PAYMENT_FREQUENCY 	= 'Monthly';
    private static final Integer NO_OF_INSTALMENT 	= 5;
    private static final String ZIP_CODE 			= 'WS2 7PD';
    private static final String MANUFACTURER 		= 'Kent';
    private static final String UNIT_OF_MEASURE 	= 'Metric';
    private static final Integer FORECASEAMOUNT 	= 100;
    private static final String WEEKLY				= 'Weekly';
    private static final String BUDGET_PLAN 		= 'Budget Plan';
    private static final String REFUND 				= 'Refund';
    private static final String MONTHLY				= 'Monthly';
    private static final String HEROKUPOSTGRESSID	= 'Test';
    
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        04 July 2018
    @description: Test data setup method
    *******************************************************************************/
    @TestSetup
    static void createTestData()
    {
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        // Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(NAME);
        Database.insert(objAccount);         
        
        /*BankAccountNumber__c, NameOnAccount__c*/ 
        BankAccountDetails__c objBankAccDetails = new BankAccountDetails__c();
        objBankAccDetails.BankAccountSortCode__c = '123abc';
        objBankAccDetails.BankAccountNumber__c = '123456';
        objBankAccDetails.NameOnAccount__c = NAME;
        objBankAccDetails.Account__c = objAccount.Id;
        Database.insert(objBankAccDetails);
        
        // Create Payment Plan Type
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(NAME, PAYMENT_FREQUENCY, NO_OF_INSTALMENT);
        objPaymentPlanType.PlanType__c = BUDGET_PLAN;
        objPaymentPlanType.CreditHandling__c = REFUND;
        objPaymentPlanType.NumberofRollingInstalments__c = 2.0;
        objPaymentPlanType.MinRefundHousehold__c = 10.00;
        objPaymentPlanType.MaxRefundHousehold__c = 200.00;
        objPaymentPlanType.MaxRenewalThreshold__c = 150;
        objPaymentPlanType.MinRenewalThreshold__c = 10;
        objPaymentPlanType.AlignBudgetPlanRenewalToReadings__c = true;
		objPaymentPlanType.PaymentFrequency__c = MONTHLY;        
        objPaymentPlanType.EndDate__c = '01/01';
        Database.insert(objPaymentPlanType); 
       
        // Create Balance Record
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);          
        Database.insert(objBalance);
        
        Id refundRecTypeId = Schema.SObjectType.BalanceTransaction__c.getRecordTypeInfosByName().get('Bill').getRecordTypeId();  // AT-3275
        
        // Create Balance Transaction Record
        BalanceTransaction__c objBalanceTransaction = GlUt_FactoryData_Test.createBalanceTransaction(objBalance);
        //objBalanceTransaction.BillItemAmount__c = -100.00;  // AT-3275
        objBalanceTransaction.BillAmount__c = -100.00; // AT-3275
        objBalanceTransaction.Amount__c = -150.00;        
        objBalanceTransaction.RecordTypeId = refundRecTypeId;
        Database.insert(objBalanceTransaction);
        
        // Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(NAME, objAccount);
        objContract.CurrentPaymentPlanType__c = objPaymentPlanType.Id;
        objContract.Balance__c = objBalance.Id;
        objContract.PaymentPlanRenewalDate__c = Date.today();
        objContract.DayOfWeek__c = System.Label.VmDr_MondayLabel;
        objContract.DayOfMonth__c = '3';
        objContract.BudgetPlanHold__c = True;  
        objContract.LastBillCalculationDate__c = Date.today().addMonths(-1);
        Database.insert(objContract);
        
        // Create Payment Plan Record
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType, objContract, FORECASEAMOUNT);
        Database.insert(objPaymentPlan);
        
        // Create Instalment Record
        Instalment__c objInstalment = GlUt_FactoryData_Test.createInstalment(objPaymentPlan);
        objInstalment.InstalmentAmountDue__c = 10.00;
        objInstalment.InstalmentNumber__c = 1;
        objinstalment.InstalmentDueDate__c = Date.today();
        objInstalment.Type__c = System.Label.CuAp_InstalmentTypeNormal;
        Database.insert(objInstalment);
        
        // Create Depot Record
        Depot__c objDepot = GlUt_FactoryData_Test.createDepot(NAME);
        Database.insert(objDepot);
        
        // Create Read Time Table Record
        ReadTimetable__c objReadTimeTable = GlUt_FactoryData_Test.createReadTimetable(NAME, PAYMENT_FREQUENCY);
        Database.insert(objReadTimeTable);
        
        // Create Book Record
        Book__c objBook = GlUt_FactoryData_Test.createBook(objDepot, objReadTimeTable);
        objBook.BudgetResetMonth__c = System.Label.CuAp_JanuaryLabel;
        objBook.ReadFrequency__c = MONTHLY;
        Database.insert(objBook);
        
        // Create Service Type Record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(NAME);
        Database.insert(objServiceType);
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(ZIP_CODE);
        Database.insert(objLocation);
        
        // Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(NAME);
        Database.insert(objSupplyPointUsageType);
        
        // Create Supply Point Record
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Book__c = objBook.Id;
        objSupplyPoint.Measured__c = True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        // Create Division Record
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        // Create Wholesaler Record
        Wholesaler__c objWholesalers = GlUt_FactoryData_Test.createWholesaler(NAME);
        Database.insert(objWholesalers);
        
        // Create Available Service Record
        AvailableService__c objAvailableService = GlUt_FactoryData_Test.createAvailableService(NAME, objDivision, objServiceType, objSupplyPoint, objWholesalers);
        Database.insert(objAvailableService);
        
        // Create Device Size Record
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(NAME);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize, MANUFACTURER, UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(NAME, objDeviceType);
        Database.insert(objDevice);
        
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading);
        
        // Create Service Record
        Service__c objService = GlUt_FactoryData_Test.createService(objContract, objReading, objServiceType, objSupplyPoint, objAvailableService);
        Database.insert(objService);  
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        04 July 2018
    @description: Test Method to check Financial Control Report - forecast_Positive
    *******************************************************************************/
    static testmethod void forecast_Positive()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c LIMIT 1];
        ForecastedResult__c objFCR = new ForecastedResult__c();
        objFCR.BillingContract__c = objContract.Id;
        objFCR.HerokuPostgresID__c = HEROKUPOSTGRESSID;  
        objFCR.ForecastedAmount__c = 300.00;
        objFCR.ToDate__c = Date.today().addMonths(3);
        objFCR.FromDate__c = Date.today();
        
        System.runAs(objUser){
            Test.startTest();    
            Database.insert(objFCR);            
            Test.stopTest();
            System.assert(objFCR.Id != null);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        04 July 2018
    @description: Test Method to check Financial Control Report - forecast_Second
    *******************************************************************************/
    static testmethod void forecast_Positive_2()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c LIMIT 1];
        Boolean isException = false;
        System.runAs(objUser){   
            
            try{
                Test.startTest();
                ForecastedResult__c objFCR = new ForecastedResult__c();
                objFCR.BillingContract__c = objContract.Id;
                objFCR.HerokuPostgresID__c = HEROKUPOSTGRESSID + 'a';
                objFCR.ForecastedAmount__c = 325.00;
                objFCR.ToDate__c = Date.today().addMonths(2);
                objFCR.FromDate__c = Date.today();
                Database.insert(objFCR);
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
            System.assert(isException == false);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        04 July 2018
    @description: Test Method to check Financial Control Report - forecast_Negative_ForeCaseAmount
    *******************************************************************************/
    static testmethod void forecast_Negative_ForeCaseAmount()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c];
        PaymentPlanType__c objPaymentPlanType = [SELECT Id, MaxRenewalThreshold__c, MinRenewalThreshold__c FROM PaymentPlanType__c];
        objPaymentPlanType.MaxRenewalThreshold__c = 0.0;
        objPaymentPlanType.MinRenewalThreshold__c = 0.0;
        Update objPaymentPlanType;
        Boolean isException = false;
        System.runAs(objUser){   
            
            try{
                Test.startTest();
                ForecastedResult__c objFCR = new ForecastedResult__c();
                objFCR.BillingContract__c = objContract.Id;
                objFCR.HerokuPostgresID__c = HEROKUPOSTGRESSID + 'b';
                objFCR.ForecastedAmount__c = null;
                objFCR.ToDate__c = Date.today().addMonths(3);
                objFCR.FromDate__c = Date.today();
                Database.insert(objFCR);
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
            System.assert(isException == false);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        04 July 2018
    @description: Test Method to check Financial Control Report - forecast_Positive_3
    *******************************************************************************/
    static testmethod void forecast_Positive_3()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        BillingContract__c objContract = [SELECT Id FROM BillingContract__c LIMIT 1];
        PaymentPlanType__c objPaymentPlanType = [SELECT Id, MaxRenewalThreshold__c, MinRenewalThreshold__c FROM PaymentPlanType__c LIMIT 1];
        objPaymentPlanType.PaymentFrequency__c = WEEKLY;        
        Update objPaymentPlanType;
        Boolean isException = false;
        System.runAs(objUser){   
            
            try{
                Test.startTest();
                ForecastedResult__c objFCR = new ForecastedResult__c();
                objFCR.BillingContract__c = objContract.Id;
                objFCR.HerokuPostgresID__c = HEROKUPOSTGRESSID + 'c';
                objFCR.ForecastedAmount__c = 425.00;
                objFCR.ToDate__c = Date.today().addMonths(5);
                objFCR.FromDate__c = Date.today();
                Database.insert(objFCR);
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
            System.assert(isException == false);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        07 Sept 2018
    @description: Test Method to check Financial Control Report - forecast_Negative_Contract_Null
    *******************************************************************************/
    static testmethod void forecast_Negative_Contract_Null()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Boolean isException = false;
        System.runAs(objUser){   
            
            try{
                Test.startTest();
                ForecastedResult__c objFCR = new ForecastedResult__c();                
                objFCR.HerokuPostgresID__c = HEROKUPOSTGRESSID + 'd';
                objFCR.ForecastedAmount__c = 425.00;
                objFCR.ToDate__c = Date.today().addMonths(5);
                objFCR.FromDate__c = Date.today();
                Database.insert(objFCR);
                Test.stopTest();
            }catch(exception e)
            {
                isException = true;
            }
            System.assert(isException == false);
        }
    }
}