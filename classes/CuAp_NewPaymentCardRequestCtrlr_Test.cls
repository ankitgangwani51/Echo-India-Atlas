/******************************************************************************
@author         Echo: Swati 
@date           22 June 2018
@description    Test class for CuAp_NewPaymentCardRequestCtrlr 
*******************************************************************************/
@isTest
public class CuAp_NewPaymentCardRequestCtrlr_Test {
    
    //Variable declaration start    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='FN123LN123'; 
    private static final String USER_FNAME= 'FN123';
    private static final String USER_LNAME= 'LN123';
    private static String ACCOUNT_NAME = 'Test Account';
    private static String CONTACT_NAME = 'Test Contact';
    private static String DAY_OF_MONTH = '2';
    private static String DAY_OF_WEEK = 'Monday';
    private static String PLAN_NAME = 'DD FORTNIGHTLY';
    private static String PAY_FREQ = 'Monthly';
    private static Integer NUM_OF_INSTAL = 3;
    private static String PAYMENT_METHOD_TYPE = 'Payment Card';
    private static String MONTHLY = 'Monthly';
    private static Integer FORECASTAMOUNT = 100;    
    
    //Variable declaration end

/******************************************************************************
@author:    Echo: Swati
@date:      22-06-2018 
@description: Test data setup method
*******************************************************************************/
    @TestSetup
    Static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);  
        
        PaymentMethodType__c  objPaymentMethodType = GlUt_FactoryData_Test.createPaymentMethodType();
        objPaymentMethodType.Name = PAYMENT_METHOD_TYPE;
        Database.insert(objPaymentMethodType);
        
        PaymentPlanType__c  objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PLAN_NAME,PAY_FREQ,NUM_OF_INSTAL);
        objPaymentPlanType.PlanType__c = Label.CuAp_PaymentPlanTypePlanTypePayInFull;
        objPaymentPlanType.FinalPaymentPlan__c = true;
        objPaymentPlanType.DaysNotice__c = 10;
        objPaymentPlanType.Active__c = true;
        objPaymentPlanType.PaymentFrequency__c = MONTHLY;
        objPaymentPlanType.MaximumNumberOfInstalments__c = 4;
        Database.insert(objPaymentPlanType);
        
        PaymentMethod__c  objPaymentMethod = GlUt_FactoryData_Test.createPaymentMethod(objPaymentMethodType,objPaymentPlanType);
        Database.insert(objPaymentMethod);
                
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTACT_NAME,objAccount);
        objContract.DayOfMonth__c = DAY_OF_MONTH;
        objContract.DayOfWeek__c = DAY_OF_WEEK;
        objContract.CurrentPaymentPlanType__c = objPaymentPlanType.Id;
        objContract.PaymentMethodType__c = objPaymentMethodType.id;
        Database.insert(objContract);        
        
        PaymentPlan__c  objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType, objContract, FORECASTAMOUNT);
        Database.insert(objPaymentPlan);
        
        PaymentPlanCard__c  objPaymentPlanCard = GlUt_FactoryData_Test.createPaymentPlanCard(objContract, objPaymentPlan);
        objPaymentPlanCard.RequestedOn__c =date.valueOf('2018-03-01');
        Database.insert(objPaymentPlanCard);
        
    }
    
    /******************************************************************************
    @author:    Echo: Swati
    @date:      22-06-2018
    @description: Test method for allowPaymentCardRequest() method 
    *******************************************************************************/  
    static testmethod void allowPaymentCardRequest_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        BillingContract__c objContract = [Select id,name from BillingContract__c limit 1];
                
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            CuAp_NewPaymentCardRequestCtrlr.resultWrapper objRes = CuAp_NewPaymentCardRequestCtrlr.allowPaymentCardRequest(objContract.Id);
            Test.stopTest();
            
            System.assertNotEquals(objRes, null);                     
        }
    }
    
    /******************************************************************************
    @author:    Echo: Swati
    @date:      22-06-2018
    @description: Test method for allowPaymentCardRequest() method 
    *******************************************************************************/  
    static testmethod void allowPaymentCardRequest_Negative(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        BillingContract__c objContract = [Select id,name from BillingContract__c limit 1];
                
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            CuAp_NewPaymentCardRequestCtrlr.resultWrapper objRes = CuAp_NewPaymentCardRequestCtrlr.allowPaymentCardRequest(objUser.Id);
            Test.stopTest();
            
            System.assertEquals(objRes.allowRequest, null); 
            System.assertEquals(objRes.paymentPlanIdList, null); 
           
        }
    }
    
    /******************************************************************************
    @author:    Echo: Swati
    @date:      22-06-2018
    @description: Test method for doChangeRequestedOnDate() method 
    *******************************************************************************/   
    static testmethod void doChangeRequestedOnDate_Positive(){
        
        Boolean isUpdated = false;
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        List<PaymentPlan__c> lstPaymentPlan = [Select id,name from PaymentPlan__c];
        
        List<Id> lstPaymentPlanId =  new List<Id>();
        for(PaymentPlan__c pp :lstPaymentPlan){
            lstPaymentPlanId.add(pp.Id);
        }             
        
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            isUpdated = CuAp_NewPaymentCardRequestCtrlr.doChangeRequestedOnDate(lstPaymentPlanId);
            Test.stopTest();
            
            System.assertNotEquals(isUpdated, false);                     
        }
    }
    
    /******************************************************************************
    @author:    Echo: Swati
    @date:      22-06-2018
    @description: Test method for doChangeRequestedOnDate() method 
    *******************************************************************************/   
    static testmethod void doChangeRequestedOnDate_Negative(){
        
        Boolean isUpdated = false;
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        List<PaymentPlan__c> lstPaymentPlan = [Select id,name from PaymentPlan__c];
        
        List<Id> lstPaymentPlanId =  new List<Id>();
        for(PaymentPlan__c pp :lstPaymentPlan){
            lstPaymentPlanId.add(pp.Id);
        }  
        
        List<Id> lstUserId = new List<Id>();
        lstUserId.add(objUser.Id);
         
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            isUpdated = CuAp_NewPaymentCardRequestCtrlr.doChangeRequestedOnDate(lstUserId);
            Test.stopTest();
            
            System.assertNotEquals(isUpdated, true);                     
        }
    }

}