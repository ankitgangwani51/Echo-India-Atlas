/******************************************************************************
@author         Ankit Gangwani
@date           25 Jan 2018
@description    Test Class For CuAp_SetupInstalmentsCtrlr
*******************************************************************************/
@isTest
public class CuAp_SetupInstalmentsCtrlr_Test {
    
    private static final String USER_PROFILE 	 = 'System Administrator';
    private static final String USER_NAME 		 = 'FN123LN123';  
    private static final String USER_FNAME		 = 'FN123';	
    private static final String USER_LNAME		 = 'LN123'; 
    private static String ACCOUNT_NAME 			 = 'TestAccount'; 
    private static String CONTRACT_NAME 		 = 'TestContract';
    private static String PAYMENT_PLAN_TYPE_NAME = 'TestPaymentPlanType';
    private static String PAYMENT_FREQUENCY		 = 'Yearly';
    private static String INSTALMENT_TYPE 		 = 'Normal';
    private static Integer PLAN_AMOUNT 			 = 100;
    private static Integer NUMBER_OF_INSTALMENTS = 10;
    
    /******************************************************************************
    @author        Ankit Gangwani 
    @date          25 Jan 2018
    @return        Void   
    @description   Setup Method for Initialize Data in Instalment__c Object 
    for Unit Testing
    *******************************************************************************/ 
    @TestSetup
    static void createTestData(){ 
        
        //Create Test User
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        //Create Account record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME); 
        Database.insert(objAccount);
        
        // Create Contract record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME,objAccount);
        Database.insert(objContract);
        
        // Create Payment Plan Type record
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENT_PLAN_TYPE_NAME, PAYMENT_FREQUENCY, NUMBER_OF_INSTALMENTS);
        Database.insert(objPaymentPlanType);
        
        // Create Payment Plan record
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType,objContract,PLAN_AMOUNT);
        Database.insert(objPaymentPlan);
        
        //Create 10 Instalment records
        List<Instalment__c> instalments = new List<Instalment__c>(); 
        for(Integer iCount = 1;iCount <11;iCount++){
            Instalment__c objInstalment = new Instalment__c();
            objInstalment.PaymentPlan__c = objPaymentPlan.Id;
            objInstalment.InstalmentNumber__c = iCount;
            objInstalment.InstalmentDueDate__c = system.today();
            objInstalment.InstalmentAmountDue__c = iCount * 10;
            objInstalment.Type__c = INSTALMENT_TYPE;
            instalments.add(objInstalment);
        }
        Database.insert(instalments);
    }
    
    /******************************************************************************
    @author        Ankit Gangwani    
    @date          25 Jan 2018
    @return        Void   
    @description   Method To test Evaluate checkbox update scenario 
    *******************************************************************************/  
    static testmethod void TestEvaluateMethod(){
        
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];
        List<Instalment__c> lstInstalments = [SELECT Id FROM Instalment__c];

        // Serialize the list to String
        String StringInstalments = JSON.serialize(lstInstalments);
        
        System.runAs(objUser[0]){
            Test.starttest();            
            List<GLAp_FieldProps> lstFieldProps = CuAp_SetupInstalmentsCtrlr.retrieveInstalmentPropDetails();
            List<BlAp_CombinedRecord> lstCombinedRecord = CuAp_SetupInstalmentsCtrlr.retrieveInstalmentsRecord(StringInstalments);            
            Test.stopTest();
            
            // Expecting 4 table headers such as - Instalment No., Date, Amount and Type
            System.assertEquals(4, lstFieldProps.size());
            
            // Expecting 10 instalment records to be create
            System.assertEquals(10, lstCombinedRecord.size());
        }
    }
}