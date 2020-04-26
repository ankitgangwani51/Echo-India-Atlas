/******************************************************************************
@author         Echo: Tarun Gupta
@date           12 Mar 2019
@description    Test class for PpIn_ForecastExtractData
*******************************************************************************/
@isTest
public class PpIn_ForecastExtractData_Test {
    
    private static final String USER_PROFILE 		= 'System Administrator';
    private static final String USER_NAME			= 'TestUser';
    private static final String USERNAMECOMPLETE  	= USER_NAME + '@unitest.com';
    private static final String USER_FNAME 			= 'First_User_Name';
    private static final String USER_LNAME 			= 'Last_User_Name';
    private static final String ACCOUNT_NAME 		= 'Test Account';    
    private static final String CONTRACT_NAME 		= 'Con00021';
    private static final String LOCATION_NAME 		= 'A99 9AA';   
    private static final String LOCATION_SUB_TYPE 	= 'Detached';
    private static final String STREET 				= 'teststreet';
    
    private static String PAYMENT_METHOD_TYPE1 = 'Payment Card';
    private static String PLAN_NAME = 'DD FORTNIGHTLY';
    private static String PAY_FREQ = 'Monthly';
    private static Integer NUM_OF_INSTAL = 3;
    private static String MONTHLY = Label.CuAp_PaymentPlanTypePaymentFrequencyMonthly;
    private static String AVAIL_PAY_DAY_NAME = 'APD Monday';
    private static String DAY_OF_MONTH = '2';
    private static String DAY_OF_WEEK = 'Monday';
    private static Integer PLANAMOUNT = 100;
    
    /*******************************************************************
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    @TestSetup
    Static void createTestData(){
        
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        // Create Account Record            
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        objAccount.RecordTypeId = GlUt_RecordTypeUtilities.getRecordTypeMap().get(GlUt_Constants.NHH_ACCOUNT_RECORDTYPE_NAME).Id;
        Database.insert(objAccount);
        
        // Create Balance Record
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);          
        Database.insert(objBalance);
        
        // Create Contract for Refund Paymet           
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME, objAccount);
        Database.insert(objContract);
        
        //Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);  
        
        List<PaymentMethodType__c> listPMT = new List<PaymentMethodType__c>();
		PaymentMethodType__c  objPaymentMethodType = GlUt_FactoryData_Test.createPaymentMethodType();
        objPaymentMethodType.Name = PAYMENT_METHOD_TYPE1;
        listPMT.add(objPaymentMethodType);
        Database.insert(listPMT);
        
        List<PaymentPlanType__c> listPPT = new List<PaymentPlanType__c>();        
        PaymentPlanType__c  objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PLAN_NAME,PAY_FREQ,NUM_OF_INSTAL);
        objPaymentPlanType.PlanType__c = Label.CuAp_PaymentPlanTypePlanTypeBudgetPlan;        
        objPaymentPlanType.DaysNotice__c = 10;
        objPaymentPlanType.Active__c = true;
        objPaymentPlanType.PaymentFrequency__c = MONTHLY;
        objPaymentPlanType.MaximumNumberOfInstalments__c = 4;
        listPPT.add(objPaymentPlanType);
        Database.insert(listPPT);
        
        List<PaymentMethod__c> listPayMethod = new List<PaymentMethod__c>();        
        PaymentMethod__c  objPaymentMethod = GlUt_FactoryData_Test.createPaymentMethod(objPaymentMethodType,objPaymentPlanType);
        listPayMethod.add(objPaymentMethod);
        Database.insert(listPayMethod);
        
        AvailablePaymentDay__c  objAvailPaymentDay = GlUt_FactoryData_Test.createAvailPaymentDay(AVAIL_PAY_DAY_NAME,DAY_OF_MONTH,DAY_OF_WEEK,objPaymentMethodType);
        Database.insert(objAvailPaymentDay);
    }
    
    /******************************************************************************
	@author:      Echo: Tarun Gupta
	@date:        12 Mar 2019
	@description: Positive method of retrieveData 
	*******************************************************************************/
    static testmethod void retrieveData_Positive(){            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        PaymentPlanType__c  objPaymentPlanType = [SELECT Id,Name,RenewalFrequency__c FROM PaymentPlanType__c LIMIT 1]; //AT-5685, Ankit, 30/04/2019, Remove field reference RollingAverage__c
        Account objAccount = [Select Id,Name FROM Account WHERE Name =: ACCOUNT_NAME limit 1];
        BillingContract__c objContract = [SELECT id FROM BillingContract__c WHERE AccountName__c=:objAccount.Id LIMIT 1];
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType,objContract,PLANAMOUNT);
        objPaymentPlan.StartDate__c = system.today();
        String payload;
        List<PaymentPlan__c> listPaymentPlans = new List<PaymentPlan__c>();
        listPaymentPlans.add(objPaymentPlan);
        Boolean isException = false;
        
        System.runAs(objUser){
            Test.startTest();
            try{
                PpIn_ForecastExtractData forecastCalc = new PpIn_ForecastExtractData(listPaymentPlans,objPaymentPlanType); 
                payload = forecastCalc.retrieveData();
            }
            catch(exception e){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException, false);
            System.assert(payload != null);
        }          
    }
    
    /******************************************************************************
	@author:      Echo: Tarun Gupta
	@date:        12 Mar 2019
	@description: Negative method of retrieveData 
	*******************************************************************************/
    static testmethod void retrieveData_Negative(){            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        String payload;
        Boolean isException = false;
        
        System.runAs(objUser){
            Test.startTest();
            try{
                PpIn_ForecastExtractData forecastCalc = new PpIn_ForecastExtractData(null,null); 
                payload = forecastCalc.retrieveData();
            }
            catch(exception e){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException, true);
            System.assert(payload == null);
        }          
    }
}