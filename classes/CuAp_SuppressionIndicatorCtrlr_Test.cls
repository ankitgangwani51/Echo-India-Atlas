/******************************************************************************
@author:      Echo: Vivek Sethi
@date:        13 February 2018
@description: Test Class for CuAp_SuppressionIndicatorComponentCtrlr
@revision:    08-Mar-2018 MT - Use the field from constant class
*******************************************************************************/

@isTest
public class CuAp_SuppressionIndicatorCtrlr_Test {
    private static final String PROFILENAME = 'System Administrator';
    private static final String USERNAME = 'TestUser111';
    private static final String USERNAMECOMPLETE = USERNAME+ '@unitest.com';  
    private static final String ACCOUNTNAME = 'Account';
    private static final String CONTRACTNAME = GlUt_APIConstantsContracts.CONTRACTAPINAME;
    private static final String CONTRACTNAME1 ='TestContract';
    private static final String INVALIDDATA = 'Test';
    private static final String CUSTOMERNAME = 'Test';
    private static final String REASON = 'Test';
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi
    @date:        13 February 2018
    @description: Test data setup method
    *******************************************************************************/
    @TestSetup
    static void createTestData(){
         //  Create user record
        User objUser = GlUt_FactoryData_Test.createUser(PROFILENAME,USERNAME,null);
        Database.insert(objUser); 
        
        //Create account record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNTNAME);
        Database.insert(objAccount); 
        
        //Create account record
        Account objAccount1 = GlUt_FactoryData_Test.createAccount(ACCOUNTNAME);
        Database.insert(objAccount1); 
        
        //Create Contract record     
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(CONTRACTNAME1,objAccount);
        Database.insert(objContract); 
        
        //To Create suppressed Contract record     
        BillingContract__c objContract1 = GlUt_FactoryData_Test.CreateContract(CONTRACTNAME1,objAccount1);
        Database.insert(objContract1);
        
        //Create suppression record
        Suppression__c objSuppression =  GlUt_FactoryData_Test.createSuppression(objAccount1,objContract1,REASON);
        objSuppression.Account__c = objAccount1.Id;
        objSuppression.SuppressionStartDate__c = Date.today();
        objSuppression.SuppressionEndDate__c = null;  
        Database.insert(objSuppression); 
    }
    
    /******************************************************************************
    @author:      Vivek Sethi
    @date:        13 February 2018
    @description: Test method for getSuppressionStatus() method positive scenario with 
    Wizard Properties as Input.
    *******************************************************************************/
    static testmethod void getSuppressionStatus_Positive(){
        Account objAccount =[Select id,name from Account limit  1 ];
        List<BillingContract__c> conList =[Select id,name from BillingContract__c limit  2 ];
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        String  suppresstatString;
        System.runAs(objUser){
            Test.startTest();
            suppresstatString =  CuAp_SuppressionIndicatorComponentCtrlr.getSuppressionStatus(ACCOUNTNAME,objAccount.Id );
            for(BillingContract__c cObj : conList)
            {
                suppresstatString = CuAp_SuppressionIndicatorComponentCtrlr.getSuppressionStatus(CONTRACTNAME,cObj.Id );
            }
            Test.stopTest();
        }
         System.assert(suppresstatString != null);
    }
    /******************************************************************************
    @author:      Vivek Sethi
    @date:        13 February 2018
    @description: Test method for getSuppressionStatus() method negative scenario with 
    Wizard Properties as Input.
    *******************************************************************************/
    static testmethod void getSuppressionStatus_Negative(){
        Account objAccount =[Select id,name from Account limit  1 ];
        BillingContract__c objContract =[Select id,name from BillingContract__c limit  1 ];
        User objUser = [Select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        String  suppresstatString;
        System.runAs(objUser){
            Test.startTest();
            suppresstatString = CuAp_SuppressionIndicatorComponentCtrlr.getSuppressionStatus(INVALIDDATA,objAccount.Id );
            suppresstatString = CuAp_SuppressionIndicatorComponentCtrlr.getSuppressionStatus(INVALIDDATA,objContract.Id );
            Test.stopTest();
        }
         System.assert(suppresstatString == null);
    }
}