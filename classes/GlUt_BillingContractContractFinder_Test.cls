/******************************************************************************
@author:      Echo: Swati Mathur
@date:        06 Apr 2018
@description: Test Class for GlUt_ContractContractFinder
*******************************************************************************/
@isTest
public class GlUt_BillingContractContractFinder_Test {
    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='FN123LN123'; 
    private static final String USER_FNAME= 'FN123';
    private static final String USER_LNAME= 'LN123';
    private static String ACCOUNT_NAME = 'TestAccount';    
    private static String BILLING_STREET ='Test Street';
    private static String BILLING_CITY = 'Test City';
    private static String BILLING_STATE = 'Test State';
    private static String BILLING_POSTCODE ='0000000';
    private static String BILLING_COUNTRY ='Test Country';
       
    /******************************************************************************
    @author:      Echo: Swati Mathur
    @date:        05 Apr 2018
    @description: Test method to create dummy data
    *******************************************************************************/
    @TestSetup
    Static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        //create Account records
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        Database.insert(objAccount);       
        
        //create Contract records
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(' ',objAccount);
        objContract.BillingStreet__c=BILLING_STREET;
        objContract.BillingCity__c=BILLING_CITY;
        objContract.BillingState__c=BILLING_STATE;
        objContract.BillingPostalCode__c=BILLING_POSTCODE;
        objContract.BillingCountry__c=BILLING_COUNTRY;
        Database.insert(objContract);
        
    }
   
    /******************************************************************************
    @author:      Echo: Swati Mathur
    @date:        05 Apr 2018
    @description: Test method for retrieveContractIds() method
    *******************************************************************************/
    static testmethod void retrieveContractIds_positive(){
        
        User objUser = [SELECT id,name FROM user WHERE isActive=true LIMIT 1];
        Set<Id> contractIds = new Set<Id>();  
        String sobjectType;
        
        BillingContract__c objCon = [SELECT Id FROM BillingContract__c ];       
        
        System.runAs(objUser){            
            Test.startTest();
            GlUt_BillingContractContractFinder obj = new GlUt_BillingContractContractFinder();
            contractIds = obj.retrieveContractIds(objCon.Id);            
            Test.stopTest();           
            
            for(Id id : contractIds){                
               System.assertEquals(objCon.Id, id);
            }
            
        }
    }         

}