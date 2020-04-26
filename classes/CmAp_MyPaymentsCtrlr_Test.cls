/*******************************************************************
@author:      ECHO: Mohit Tayal
@date:        12 April 2018
@param:       N/A
@return:      void
@description: Test Class for CmAp_MyPaymentsCtrlr
********************************************************************/ 
@isTest
public class CmAp_MyPaymentsCtrlr_Test {

    private static final String USER_PROFILE        = 'System Administrator';
    private static final String USER_NAME           = 'TestUser'; 
    private static final String PORTAL_USER_NAME    = 'PortalTestUser';
    private static final String USERNAMECOMPLETE    =  USER_NAME + '@unitest.com';
    private static final String PORTAL_USERNAMECOMPLETE =  PORTAL_USER_NAME + '@unitest.com';
    private static final String ACCOUNT_NAME        = 'TestAccount';
    private static final String FIRST_NAME          = 'TestFirstName';
    private static final String LAST_NAME           = 'TestLastName';
    private static final String PORTALTYPE          = 'None';
	
    
    /*******************************************************************
    @author:      ECHO: Mohit Tayal
    @date:        12 April 2018
    @param:       N/A
    @return:      void
    @description: Creating the test data
    ********************************************************************/     
    @testSetup
    static void createTestdata() {
        //Create portal account owner
        UserRole portalRole = [Select Id From UserRole Where PortalType = :PORTALTYPE Limit 1];
		User portalAccountOwner = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
		portalAccountOwner.UserRoleId = portalRole.Id ;
		Database.insert(portalAccountOwner);
        
        System.runAs(portalAccountOwner){
            Test.startTest();
            testSetupData(portalAccountOwner.Id) ;   
            Test.stopTest();
        }
    }

    /*******************************************************************
    @author:      ECHO: Mohit Tayal
    @date:        12 April 2018
    @param:       N/A
    @return:      void
    @description: Creating the portal user test setup
    ********************************************************************/ 
   @future
    static void testSetupData(Id portalAccountOwnerId) {
        //Create account
		Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
		objAccount.OwnerId = portalAccountOwnerId ;
        Database.insert(objAccount);
        
        //Create contact
		Contact objContact = GlUt_FactoryData_Test.createContact(FIRST_NAME, LAST_NAME);
		objContact.AccountId = objAccount.Id;
		Database.insert(objContact);
        
        //Create Portal  user
        User portalUser = GlUt_FactoryData_Test.createCommunityUser(objContact, PORTAL_USER_NAME);
        if(portalUser != null)
            Database.insert(portalUser);
        
        List<Payment__c> lstPayment = new List<Payment__c>();
        
        for(Integer i = 0 ; i < 10; i++){
            Payment__c objPayment = new Payment__c();
            objPayment.Amount__c = i + 10;
            objPayment.Account__c = objAccount.Id;
            objPayment.PaymentDate__c = Date.today() - 10 + i;
            lstPayment.add(objPayment);
        }
        
        Database.insert(lstPayment);	
    }
    
    /*******************************************************************
    @author:      ECHO: Mohit Tayal
    @date:        12 April 2018
    @param:       N/A
    @return:      void
    @description: Positive Test scenario for getUserPayments
    ********************************************************************/ 
    static testmethod void getUserPayments_PositiveTest(){
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        Account objAccount = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
        List<Payment__c> lstPayment = new List<Payment__c>();
        
        System.runAs(objUser){
            Test.startTest();
               lstPayment = CmAp_MyPaymentsCtrlr.getUserPayments();
            Test.stopTest();
        }
   
        System.assert(!lstPayment.isEmpty());
    }
    
    /*******************************************************************
    @author:      ECHO: Mohit Tayal
    @date:        12 April 2018
    @param:       N/A
    @return:      void
    @description: Negative Test scenario for getUserPayments
    ********************************************************************/ 
    static testmethod void getUserPayments_NegativeTest(){
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        Account objAccount = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
        List<Payment__c> lstPayment = [SELECT Id,Account__c FROM Payment__c WHERE Account__c = :objAccount.Id];
        for(Payment__c objPayment : lstPayment){
            objPayment.Account__c = null;
        }
        Database.update(lstPayment);
        
        System.runAs(objUser){
            Test.startTest();
               lstPayment = CmAp_MyPaymentsCtrlr.getUserPayments();
            Test.stopTest();
        }
   
        System.assert(lstPayment.isEmpty());
    }
    
    /*******************************************************************
    @author:      ECHO: Mohit Tayal
    @date:        12 April 2018
    @param:       N/A
    @return:      void
    @description: Positive Test scenario for getPaymentPropDetails
    ********************************************************************/
    static testmethod void getPaymentPropDetails_PositiveTest(){
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        List<GLAp_FieldProps> lstPaymentsProp = new List<GLAp_FieldProps>();
        
        System.runAs(objUser){
            Test.startTest();
               lstPaymentsProp = CmAp_MyPaymentsCtrlr.getPaymentPropDetails();
            Test.stopTest();
        }
        
        System.assert(!lstPaymentsProp.isEmpty());
    }
}