/******************************************************************************
@author:      Accenture: Sucharu Gupta
@date:        05 September 2017
@description: Test Class for BlIn_ExecuteBillCalculation
Revision(s):  Shivangi Gaur -- 22-Dec-2017 -- Incorporated review comments on AT-438
                                              dated 21-Dec-2017.
              Shivangi Gaur -- 04-Jan-2018 -- Incorporated review comments on AT-438
                                              dated 03-Jan-2018. 
*******************************************************************************/

@isTest
//test data creation for BlIn_BillCalcExtractData class
public class BlIn_ExecuteBillCalculation_Test{
    
    //Variable declaration startTest
    
    private static string BILLINGRESPONSEMOCKPOSITIVE = 'GlUt_Mock_createBilling_Response_Positive';
    private static string BILLINGRESPONSEMOCKNEGATIVE = 'GlUt_Mock_createBilling_Response_Negative';
    private static String PROFILENAME  = 'System Administrator';
    private static String USERNAME = 'TestUser555';
    private static final string HEROKUSECURITY = 'ABCSRESSGSTSEESDGS';
    private static string BILLCALCULATIONMOCKPOSITIVE = 'BlAp_Mock_BillingCalculation_Response_Positive';
    private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    private static string BILLCALCULATIONMOCKERROR = 'GlUt_Mock_createBilling_Response_Error';
    private static final String TESTREGION = 'Test Region';
    
/*******************************************************************
Purpose: method to create test data used by all test methods
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/

    @TestSetup
    Static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(PROFILENAME,USERNAME,null);
        Database.insert(objUser);
        
        BillCalculation__c  objBillCalculation = GlUt_FactoryData_Test.createBillCalculation();
        Database.insert(objBillCalculation);
        
        BillCalculation__c  objBillCalculation1 = GlUt_FactoryData_Test.createBillCalculation();
        objBillCalculation1.Status__c = Label.BlIn_BillCalculationStatusCompleted;
        Database.insert(objBillCalculation1);
              
        HerokuSecurity__c hSecurity = GlUt_FactoryData_Test.createHerokuSecurity(HEROKUSECURITY);
        DataBase.insert(hSecurity);
        
        Region__c objRegion = GlUt_FactoryData_Test.createRegion(TESTREGION, true, false, false);
        insert objRegion;
         
    }
        
/*******************************************************************
Purpose: Method to test requestBillCalculation() positive scenario.
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void requestBillCalculation_PositiveTest(){
        
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        BillCalculation__c objBillCalculation =[Select id from BillCalculation__c limit 1];
        
        System.runAs(objUser ){
            
            Test.startTest();
            // Set mock callout class with response code as 200 and response status as Completed
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BILLINGRESPONSEMOCKPOSITIVE));
            boolean b = BlIn_ExecuteBillCalculation.requestBillCalculation(objBillCalculation.id);
            Test.stopTest();
            
            System.assertEquals(true,b);
        }   
    }
/*******************************************************************
Purpose: Method to test requestBillCalculation() negative scenario where 
         response code is not 200.
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void requestBillCalculation_NegativeTest(){
        
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        BillCalculation__c objBillCalculation =[Select id from BillCalculation__c limit 1];
        boolean isException = true;
        
        System.runAs(objUser ){
            
            Test.startTest();
            // Set mock callout class with response code not 200
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BILLINGRESPONSEMOCKNEGATIVE));
            try{
                boolean b = BlIn_ExecuteBillCalculation.requestBillCalculation(objBillCalculation.id);
            }
            catch(exception exc){
                System.assert(exc.getMessage() != null);
                isException = true;
            }
            Test.stopTest();
            
            System.assertEquals(true,isException);
        }   
    }
/*******************************************************************
Purpose: Method to test requestBillCalculation() negative scenario where 
         no parameter is passed while calling the method.
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void requestBillCalculationNullParameter_NegativeTest(){
        
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        boolean isException = false;
        
        System.runAs(objUser ){
            
            Test.startTest();
            // Set mock callout class with response code as 200 and response status as Completed
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BILLINGRESPONSEMOCKPOSITIVE));
            try{
                boolean b = BlIn_ExecuteBillCalculation.requestBillCalculation(null);
            }
            catch(Exception exc){
                isException = true;               
            }
            Test.stopTest();
            
            System.assertEquals(true,isException);
        }   
    }    
/*******************************************************************
Purpose: Method to test getBillCalculationResult() positive scenario.
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/    
    static testmethod void getBillCalculationResult_PositiveTest(){
        
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        BillCalculation__c objBillCalculation =[Select id from BillCalculation__c limit 1];
        List<Id> billCalculationIdList = new List<Id>();
        
        System.runAs(objUser ){
            
            Test.startTest();
                // Set mock callout class with response code as 200 and response status as Completed
                Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BILLINGRESPONSEMOCKPOSITIVE));            
                BlIn_ExecuteBillCalculation.BillResults billResults = BlIn_ExecuteBillCalculation.getBillCalculationResult(objBillCalculation.id);
            Test.stopTest();
            
            System.assert(billCalculationIdList != null);
            
            //Assert to check properties of bill inserted
            //Bill__c objBill = [Select id, BillCalculation__c from Bill__c where id =: billCalculationIdList[0] limit 1];
            //Changed By Tarun on 30/Jan/2018 
            //Made changes to take a list Instead as there are chances that the Select statement doesn't return any record so excpetion is thrown.
            if(billCalculationIdList.size() > 0){
                List<Bill__c> objBill = [SELECT id, BillCalculation__c from Bill__c where id =: billCalculationIdList[0] limit 1];
                if(objBill.size() > 0){
                    System.assertEquals(objBill[0].BillCalculation__c ,objBillCalculation.id);
                }
            }
            
        }   
    }
    
/*******************************************************************
Purpose: Method to test getBillCalculationResult() positive scenario.
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/    
    static testmethod void getBillCalculationResult_PositiveTest1(){
        
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        BillCalculation__c objBillCalculation =[Select id from BillCalculation__c Where Status__c =: Label.BlIn_BillCalculationStatusCompleted limit 1];
        boolean isException = false;
        
        System.runAs(objUser ){
            
            Test.startTest();
            try{
                // Set mock callout class with response code as 200 and response status as Completed
                Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BILLINGRESPONSEMOCKPOSITIVE));            
                BlIn_ExecuteBillCalculation.BillResults billResults = BlIn_ExecuteBillCalculation.getBillCalculationResult(objBillCalculation.id);                
               
            }catch(Exception e){
                isException = true;
            }
            Test.stopTest();
            
            System.assertEquals(isException,false);
        }   
    }
    
   
/*******************************************************************
Purpose: Method to test getBillCalculationResult() negative scenario 
         where response code is not 200
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    
    static testmethod void getBillCalculationResultResponseNot200_NegativeTest(){
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        BillCalculation__c objBillCalculation =[Select id,Status__c from BillCalculation__c limit 1];
        String beforeStatus = objBillCalculation.Status__c;
        
        boolean isException = false;
        
        System.runAs(objUser ){
            
            Test.startTest();
            try{
                
                // Set mock callout class with response code not 200
                Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BILLINGRESPONSEMOCKNEGATIVE));
                BlIn_ExecuteBillCalculation.BillResults billResults = BlIn_ExecuteBillCalculation.getBillCalculationResult(objBillCalculation.Id); 
                
            } 
            catch(Exception exc){
                isException = true;               
            }
            Test.stopTest();
            String afterStatus = objBillCalculation.Status__c;
            
            System.assertEquals(isException,false);
            System.assertEquals(beforeStatus,afterStatus);
        }   
    }
/*******************************************************************
Purpose: Method to test getBillCalculationResult() negative scenario 
         where response status is Error
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/    
    static testmethod void getBillCalculationResultError_NegativeTest(){
        
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        BillCalculation__c objBillCalculation =[Select id from BillCalculation__c where Status__c != :Label.BlIn_BillCalculationStatusCompleted limit 1];
        boolean isException = false;
        BlIn_ExecuteBillCalculation.BillResults billResults;
        
        System.runAs(objUser){            
            Test.startTest();
            try{
                // Set mock callout class with response status as Error
                Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BILLCALCULATIONMOCKERROR));
                billResults = BlIn_ExecuteBillCalculation.getBillCalculationResult(objBillCalculation.id);   
                
            } 
            catch(AuraHandledException e){
                System.assert(e.getmessage()!= null);
                isException = true;
            }
            Test.stopTest();
            
            System.assertEquals(isException,false);
            System.assertEquals(billResults.error,Label.BlAp_BillCalcResultErrorResponse);
            
        }   
    }
}