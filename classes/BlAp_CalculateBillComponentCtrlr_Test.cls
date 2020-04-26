/******************************************************************************
@author:      Accenture: Sucharu Gupta
@date:        05 October 2017
@description: Test Class for BlAp_CalculateBillComponentCtrlr
@revision(s) : 08-Dec-2018 - Amit K.
               10-Apr-2018 - Swati -- Made changes for main class revision to
                                      combine billable and pending bill components
@Revisions	  AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/

@isTest
//test data creation for BlAp_CalculateBillComponentCtrlr class
public class BlAp_CalculateBillComponentCtrlr_Test{
    
    private static final String HEROKUSECURITY = 'ABCSRESSGSTSEESDGS';
    private static final String USER_PROFILE ='System Administrator';
    private static final String USER_NAME = 'TestUser'; 
    private static final String USERNAMECOMPLETE  = USER_NAME+ '@unitest.com';
    private static final String ACCOUNT_NAME = 'TestAccount'; 
    private static final String CONTRACT_NAME_ONE ='TestContract';
    private static final String BILL_NAME ='TestBill';
    public static final String BILL_CALCULATION_STATUS_ERROR = 'Error';
    
    public static final String BILL_CALCULATION_STATUS_PENDING = 'Pending';
    public static final String BILL_CALCULATION_STATUS_NEW = 'New';
    public static final String BILL_CALCULATION_STATUS_COMPLETED = 'Completed';
    private static final String BILLINGRESPONSEMOCKPOSITIVE = 'GlUt_Mock_createBilling_Response_Positive';
    private static final String BILLINGRESPONSEMOCKERROR = 'GlUt_Mock_createBilling_Response_Error';
    private static final String WRONGCONTRACTID = 'XYZ';
    private static final String OBJBILLINGCONTRACT = GlUt_NamespacePrefix.getNamespacePrefix() + 'BillingContract__c';
    private static final String TESTREGION = 'Test Region';

    
   /******************************************************************
    Purpose: method to create test data used by all USER_NAMEtest methods
    Throws [Exceptions]: N/A
    Description: create test data for test methods.
    *******************************************************************/
    @TestSetup
    static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE ,USER_NAME ,null);
        Database.insert(objUser);
        
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(CONTRACT_NAME_ONE,objAccount);
        objContract.LastBillCalculationDate__c = system.Today();
        Database.insert(objContract); 
        
        List<BillCalculation__c>  lstBillCalc = new List<BillCalculation__c>();
       
        BillCalculation__c objBillCalculation = GlUt_FactoryData_Test.createBillCalculation();
        objBillCalculation.Type__c = Label.BlIn_BillCalculationTypePending;
        objBillCalculation.Reason__c = Label.BlIn_BillCalculationReasonAgent;
        objBillCalculation.Status__c = Label.BlIn_BillCalculationStatusPending;
        objBillCalculation.BillingContract__c = objContract.Id;
        lstBillCalc.add(objBillCalculation);
        
        BillCalculation__c objBillCalculation1 = GlUt_FactoryData_Test.createBillCalculation();
        objBillCalculation1.Type__c = Label.BlIn_BillCalculationTypePending;
        objBillCalculation1.Reason__c = Label.BlIn_BillCalculationReasonAgent;
        objBillCalculation1.Status__c = Label.BlIn_BillCalculationStatusNew;
        objBillCalculation1.BillingContract__c = objContract.Id;        
        lstBillCalc.add(objBillCalculation1);        
        
        BillCalculation__c objBillCalculation2 = GlUt_FactoryData_Test.createBillCalculation();
        objBillCalculation2.Type__c = Label.BlIn_BillCalculationTypeBillable;
        objBillCalculation2.Status__c = Label.BlIn_BillCalculationStatusVoid;
        objBillCalculation2.Reason__c = Label.BlIn_BillCalculationReasonAgent;
        objBillCalculation2.BillingContract__c = objContract.Id;        
        lstBillCalc.add(objBillCalculation2);
        Database.insert(lstBillCalc);
        
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILL_NAME,objContract);
        Database.insert(objBill);
        
        HerokuSecurity__c hSecurity = GlUt_FactoryData_Test.createHerokuSecurity(HEROKUSECURITY);
        Database.insert(hSecurity);   
        
        Region__c objRegion = GlUt_FactoryData_Test.createRegion(TESTREGION, true, false, false);
        insert objRegion;
    }
    
      
    /*******************************************************************
    Purpose: Method to test new bill request(Positive Scenario)
    Throws [Exceptions]: N/A
    Description: 
    *******************************************************************/
    static testmethod void initiateBillsRequestTest_Positive(){
        User objuser = [select id from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1]; 
        BillingContract__c objContract = [select id from BillingContract__c limit 1];
        
        System.runAs(objUser){
            Test.startTest();
            List<BillCalculation__c> lstBillCalc = BlAp_CalculateBillComponentCtrlr.initiateBillsRequest(Label.BlIn_BillCalculationTypePending,OBJBILLINGCONTRACT, objContract.id, null);
            Test.stopTest();
            System.assert(!lstBillCalc.isEmpty());
        }
    }
    
   /******************************************************************
    Purpose: Method to test new bill request(Positive Scenario)
    Throws [Exceptions]: N/A
    Description: 
    *******************************************************************/
    static testmethod void initiateBillsRequestTest2_Positive(){
        User objuser = [select id from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1]; 
        BillingContract__c objContract = [select id from BillingContract__c limit 1];        
        BillCalculation__c objBillCalculation = [select id from BillCalculation__c where Status__c = :Label.BlIn_BillCalculationStatusPending ];
        objBillCalculation.Status__c = Label.BlIn_BillCalculationStatusNew;
        Database.update(objBillCalculation);    
        
        System.runAs(objUser){
            Test.startTest();
            List<BillCalculation__c> lstBillCalc = BlAp_CalculateBillComponentCtrlr.initiateBillsRequest(Label.BlIn_BillCalculationTypePending,OBJBILLINGCONTRACT, objContract.id, null);
            Test.stopTest();
            System.assert(!lstBillCalc.isEmpty());
        }
    }
    
    /******************************************************************
    Purpose: Method to test new bill request(Negative Scenario)
    Throws [Exceptions]: N/A
    Description: 
    *******************************************************************/
    static testmethod void initiateBillsRequestTest_Negative(){
        User objuser = [select id from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1]; 
        BillingContract__c objContract = [select id from BillingContract__c limit 1];
        boolean isException = true;
        
        System.runAs(objUser){
            Test.startTest();
            try{
                List<BillCalculation__c> lstBillCalc = BlAp_CalculateBillComponentCtrlr.initiateBillsRequest(Label.BlIn_BillCalculationStatusVoid,OBJBILLINGCONTRACT, objContract.id, null);
             }
            catch(exception exc){
                 isException = true;
            }
            Test.stopTest();            
            System.assertEquals(true,isException);
           
        }
    }
        
    /******************************************************************
    Purpose: Method to test new bill calculation(Positive Scenario)
    Throws [Exceptions]: N/A
    Description: 
    *******************************************************************/
        static testmethod void requestBillsTest_Positive(){
        User objuser = [select id from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1];
        BillingContract__c objContract = [select id from BillingContract__c limit 1];
        List<BillCalculation__c> lstBillCalculation = [select id,Status__c from BillCalculation__c];
        String billCalculationsJSON = System.JSON.serialize(lstBillCalculation);
        
        System.runAs(objUser){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BILLINGRESPONSEMOCKPOSITIVE));
            List<BillCalculation__c> lstBillCalc = BlAp_CalculateBillComponentCtrlr.requestBills(billCalculationsJSON);
            Test.stopTest();    
            System.assert(!lstBillCalc.isEmpty());
        }
    }
    
    
    /******************************************************************
    Purpose: Method to test new bill calculation(Positive Scenario)
    Throws [Exceptions]: N/A
    Description: 
    *******************************************************************/
    static testmethod void getBillTest_Positive(){
        User objuser = [select id from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1];
        BillCalculation__c objBillCalc = [select id from BillCalculation__c limit 1];
        System.runAs(objUser){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BILLINGRESPONSEMOCKPOSITIVE)); 
            BlIn_ExecuteBillCalculation.BillResults  billRes= BlAp_CalculateBillComponentCtrlr.getBill(objBillCalc);
            system.debug('billRes***'+ billRes);
            Test.stopTest();    
            System.assert(billRes == null);
        }   
    }

}