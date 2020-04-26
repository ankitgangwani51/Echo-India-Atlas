/******************************************************************************
@author:      Echo: Amit K.
@date:        03 May 2018
@description: Test Class for GlUt_HerokuBillCalculationHandler
Revision(s): NA
*******************************************************************************/
@isTest 
public class GlUt_HerokuBillCalculationHandler_Test {
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String HEROKUPROGRESS_ID = 'SDSD23232'; 
    private static final String STATUS = 'Completed';
    private static final String PENDING = 'Pending';
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String CONTRACT_NAME = 'Con00021';
    private static final String BILL_NO = 'Bill001'; 
    private static final String BILLWRITEOFF_STATUS = 'Pending';
    private static final String BILLWRITEOFF_REASON = 'Bill Correction';
    
    /*******************************************************************
Purpose: method to create test data used by all test methods
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    @TestSetup
    static void createTestData()
    {
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        // AT-3703 start...
        // Create Account Record            
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        // Create Contract Record            
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME, objAccount);
        Database.insert(objContract); 
        
        // Create Bill Record            
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILL_NO, objContract);
        Database.insert(objBill); 
               
        // Create Bill Record            
        BillWriteOff__c objBillWriteOff = GlUt_FactoryData_Test.createBillWriteOff(objBill,BILLWRITEOFF_STATUS, BILLWRITEOFF_REASON);
        Database.insert(objBillWriteOff);
        //AT-3703 end...
                
        // Create Bill Calculation record.
        BillCalculation__c objBillCalc = GlUt_FactoryData_Test.createBillCalculation();
        Database.insert(objBillCalc);
    }
    /*******************************************************************
Purpose: Method to test getRecTypeName method positive scenario.
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/   
    static testmethod void insertHerokuBillCalculationStatus_Positive()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];      
        BillCalculation__c objBillCalc = [SELECT Id,Status__c FROM BillCalculation__c LIMIT 1];
        BillWriteOff__c objBillWriteOff = [SELECT Id,Status__c FROM BillWriteOff__c LIMIT 1];  // AT-3703 
        HerokuBillCalculationStatus__c objHerokuBillCalculationStatus = new HerokuBillCalculationStatus__c();
        objHerokuBillCalculationStatus.BillCalculation__c = objBillCalc.Id;
        objHerokuBillCalculationStatus.HerokuPostgresId__c = HEROKUPROGRESS_ID;
        objHerokuBillCalculationStatus.Status__c = STATUS;
        objHerokuBillCalculationStatus.BillWriteOff__c = objBillWriteOff.Id;		//AT-3703 
        System.runAs(objUser){
            Test.startTest();             
            Database.insert(objHerokuBillCalculationStatus);            
            Test.stopTest();
        }  
        BillCalculation__c objUpdatedBillCalc = [SELECT Id,Status__c FROM BillCalculation__c LIMIT 1];
        system.assert(objHerokuBillCalculationStatus.id != null);   
        System.assertEquals(objUpdatedBillCalc.Status__c,STATUS);
        BillWriteOff__c objBillWriteOff1 = [SELECT Id,Status__c FROM BillWriteOff__c LIMIT 1];  // AT-3703 
        system.assert(objBillWriteOff1.Status__c == GlUt_Constants.ERROR); //AT-3703 
    }
    /*******************************************************************
Purpose: Method to test getRecTypeName method negative scenario.
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void insertHerokuBillCalculationStatus_Negative()
    {     
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];      
        BillCalculation__c objBillCalc = [SELECT Id,Status__c FROM BillCalculation__c LIMIT 1];
        HerokuBillCalculationStatus__c objHerokuBillCalculationStatus = new HerokuBillCalculationStatus__c();
        objHerokuBillCalculationStatus.BillCalculation__c = objBillCalc.Id;
        objHerokuBillCalculationStatus.HerokuPostgresId__c = HEROKUPROGRESS_ID;
        objHerokuBillCalculationStatus.Status__c = PENDING;
        System.runAs(objUser){
            Test.startTest();             
            Database.insert(objHerokuBillCalculationStatus);            
            Test.stopTest();
        }  
        BillCalculation__c objUpdatedBillCalc = [SELECT Id,Status__c FROM BillCalculation__c LIMIT 1];
        system.assert(objHerokuBillCalculationStatus.id != null);   
        System.assertEquals(objUpdatedBillCalc.Status__c,PENDING);
    }
}