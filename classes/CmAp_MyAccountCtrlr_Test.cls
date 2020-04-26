/****************************************************************************************************************************
@author    		Echo: Sudhir Kumar
@date      		20-Apr-2018
@description 	Test Class for CmAp_MyAccountCtrlr
@Revision        AT-3969, Tarun, modified class name as per security reviews
*****************************************************************************************************************************/

@isTest
public class CmAp_MyAccountCtrlr_Test {
    
    private static final String USER_PROFILE        	= 'System Administrator' ;
    private static final String USER_NAME           	= 'TestUser' ;
    private static final String PORTAL_USER_NAME    	= 'PortalTestUser' ;
    private static final String NON_PORTAL_USER_NAME    	= 'NonPortalTestUser' ;
    private static final String USERNAMECOMPLETE   		=  USER_NAME + '@unitest.com' ;
    private static final String PORTAL_USERNAMECOMPLETE =  PORTAL_USER_NAME + '@unitest.com' ;
    private static final String ACCOUNT_NAME        	= 'TestAccount' ;
    private static final String FIRST_NAME          	= 'TestFirstName' ;
    private static final String LAST_NAME          		= 'TestLastName' ;
    private static Id HHAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.AccAp_AccountRecordTypeHouseholdAccount).getRecordTypeId() ;
    private static Id NHHAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.AccAp_AccountRecordTypeNonHouseholdAccount).getRecordTypeId() ;
    
    public static Account objAccount = null ;
    @testSetup
    static void createTestData() {
        //Create portal account owner
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile = [Select Id from Profile where name =: USER_PROFILE];
        User portalAccountOwner = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        portalAccountOwner.UserRoleId = portalRole.Id ;
        User nonPortalUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,NON_PORTAL_USER_NAME,null);
        Database.insert(new list<User> { portalAccountOwner, nonPortalUser });
        System.runAs(portalAccountOwner){
            Test.startTest();
            testSetupData(portalAccountOwner.Id) ;
            Test.stopTest();           
        }
    }
    
    @future	// To prevent Mixed DML error
    static void testSetupData(Id portalAccountOwnerId) {
        //Create account
        //Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        objAccount.OwnerId = portalAccountOwnerId ;
        objAccount.RecordTypeId = HHAccountRecordTypeId ;
        Database.insert(objAccount);
        
        //Create contact
        Contact objContact = GlUt_FactoryData_Test.createContact(FIRST_NAME, LAST_NAME);
        objContact.AccountId = objAccount.Id;
        //Database.insert(objContact);
        
        //Create Community user
        User portalUser = GlUt_FactoryData_Test.createCommunityUser(objContact, PORTAL_USER_NAME);
        if(portalUser != null)
            Database.insert(portalUser);
    }
    
    /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/
    
    static testmethod void getCurrentUserAccount_PositiveTest() {
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        Account testAccount = [SELECT Id, RecordTypeId FROm Account Where Name =: ACCOUNT_NAME] ;
        
        System.runAs(objUser){    
            
            Account oAccount = CmAp_MyAccountCtrlr.getCurrentUserAccount() ;
            system.assert(oAccount != null) ;
        }
    }
    
    /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/    
    static testmethod void getCurrentUserAccount_NegativeTest() {
        try {
            List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
            String usrName;
            if(portalProfile != null && portalProfile.size() > 0)
                usrName = PORTAL_USERNAMECOMPLETE;
            else
                usrName = USERNAMECOMPLETE;
            
            User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
            Account objAccount = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
            System.runAs(objUser) {    
                
                Account oAccount = CmAp_MyAccountCtrlr.getCurrentUserAccount() ;
                system.assert(oAccount.id == objAccount.Id) ;
            }
        } catch(Exception ex){}
    }
    
        /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/
    // getMyAccountDetails
    static testmethod void getMyAccountDetails_PositiveTest() {
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        Account testAccount = [SELECT Id, RecordTypeId FROm Account Where Name =: ACCOUNT_NAME] ;
        
        System.runAs(objUser){    
            
            Account oAccountHH = CmAp_MyAccountCtrlr.getMyAccountDetails() ;
            system.assert(oAccountHH != null) ;
            testAccount.RecordTypeId = NHHAccountRecordTypeId ;
            update testAccount ;
            Account oAccountNHH = CmAp_MyAccountCtrlr.getMyAccountDetails() ;
            system.assert(oAccountNHH != null) ;
        }
    }
    
        /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/
    static testmethod void getMyAccountDetails_NegativeTest() {
        try {
            List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
            String usrName;
            if(portalProfile != null && portalProfile.size() > 0)
                usrName = PORTAL_USERNAMECOMPLETE;
            else
                usrName = USERNAMECOMPLETE;
            
            User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
            Account objAccount = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
            System.runAs(objUser) {    
                Account oAccount = CmAp_MyAccountCtrlr.getMyAccountDetails() ;
                system.assert(oAccount.Id == objAccount.Id) ;
            }
        }catch(Exception ex) {}  
    }
    
        /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/
    // getRecordTypeName
    static testmethod void getRecordTypeName_PositiveTest() {
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        
        System.runAs(objUser) {    
            
            String sRecordType = CmAp_MyAccountCtrlr.getRecordTypeName() ;
            system.assert(sRecordType != null) ;
        }
    }
    
        /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/
    // getAccountFieldsProps
    static testmethod void getAccountFieldsProps_PositiveTest() {
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        
        System.runAs(objUser) {    
            
            List<List<GlAp_FieldProps>> twoColFormattedList = CmAp_MyAccountCtrlr.getAccountFieldsProps() ;
            system.assert(twoColFormattedList != null) ;
        }
    }
    
        /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/
    // getAccountAddressFieldsProps
    static testmethod void getAccountAddressFieldsProps_PositiveTest() {
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        
        System.runAs(objUser) {    
            
            List<List<GlAp_FieldProps>> twoColFormattedList = CmAp_MyAccountCtrlr.getAccountAddressFieldsProps() ;
            system.assert(twoColFormattedList != null) ;
        }
    }
    
        /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/
    // getAccountContactFieldsProps
    static testmethod void getAccountContactFieldsProps_PositiveTest() {
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        
        System.runAs(objUser) {    
            
            List<List<GlAp_FieldProps>> twoColFormattedList = CmAp_MyAccountCtrlr.getAccountContactFieldsProps() ;
            system.assert(twoColFormattedList != null) ;
        }
    }
    
        /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/
    // getAccountSicFieldsProps
    static testmethod void getAccountSicFieldsProps_PositiveTest() {
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        
        System.runAs(objUser) {    
            
            List<List<GlAp_FieldProps>> twoColFormattedList = CmAp_MyAccountCtrlr.getAccountSicFieldsProps() ;
            system.assert(twoColFormattedList != null) ;
        }
    }
    
        /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/
    // getAccountConsiderationFieldsProps
    static testmethod void getAccountConsiderationFieldsProps_PositiveTest() {
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        
        System.runAs(objUser) {    
            
            List<List<GlAp_FieldProps>> twoColFormattedList = CmAp_MyAccountCtrlr.getAccountConsiderationFieldsProps() ;
            system.assert(twoColFormattedList != null) ;
        }
    }
    
        /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/
    // getAccountAdditionalFieldsProps
    static testmethod void getAccountAdditionalFieldsProps_PositiveTest() {
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        
        System.runAs(objUser) {    
            
            List<List<GlAp_FieldProps>> twoColFormattedList = CmAp_MyAccountCtrlr.getAccountAdditionalFieldsProps() ;
            system.assert(twoColFormattedList != null) ;
        }
    }
    
        /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/
    // getMyAccountAddressDetails
    static testmethod void getMyAccountAddressDetails_PositiveTest() {
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        
        System.runAs(objUser) {    
            
            Account objAccount = CmAp_MyAccountCtrlr.getMyAccountAddressDetails() ;
            system.assert(objAccount != null) ;
        }
    }

    /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/    
    static testmethod void getMyAccountAddressDetails_NegativeTest() {
        try {
            List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
            String usrName;
            if(portalProfile != null && portalProfile.size() > 0)
                usrName = PORTAL_USERNAMECOMPLETE;
            else
                usrName = USERNAMECOMPLETE;
            
            User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
            Account objAccount = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
            System.runAs(objUser) {    
                Account accountObj  = CmAp_MyAccountCtrlr.getMyAccountAddressDetails() ;
                system.assert(accountObj.Id == objAccount.Id) ;
                
            }
        }catch(Exception ex) {}
    }
    
        /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/
    // getMyAccountContactDetails
    static testmethod void getMyAccountContactDetails_PositiveTest() {
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        
        System.runAs(objUser) {    
            
            Account objAccount = CmAp_MyAccountCtrlr.getMyAccountContactDetails() ;
            system.assert(objAccount != null) ;
        }
    }
    
        /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/
    static testmethod void getMyAccountContactDetails_NegativeTest() {
        try {
            List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
            String usrName;
            if(portalProfile != null && portalProfile.size() > 0)
                usrName = PORTAL_USERNAMECOMPLETE;
            else
                usrName = USERNAMECOMPLETE;
            
            User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
            Account accountObj = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
            
            System.runAs(objUser) {    
                Account objAccount  = CmAp_MyAccountCtrlr.getMyAccountContactDetails() ;
                system.assert(objAccount.Id == accountObj.Id) ;
            }
        }catch(Exception ex) {}
    }
    
        /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/
    // getMyAccountSicDetails
    static testmethod void getMyAccountSicDetails_PositiveTest() {
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        
        System.runAs(objUser) {    
            
            Account objAccount = CmAp_MyAccountCtrlr.getMyAccountSicDetails() ;
            system.assert(objAccount != null) ;
        }
    }
    
        /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/
    static testmethod void getMyAccountSicDetails_NegativeTest() {
        try {
            List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
            String usrName;
            if(portalProfile != null && portalProfile.size() > 0)
                usrName = PORTAL_USERNAMECOMPLETE;
            else
                usrName = USERNAMECOMPLETE;
            
            User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
            Account accountObj = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
            
            System.runAs(objUser) {    
                Account objAccount  = CmAp_MyAccountCtrlr.getMyAccountSicDetails() ;
                system.assert(objAccount.Id == accountObj.Id) ;
            }
        }catch(Exception ex) {}  
    }
    
        /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/
    // getMyAccountConsiderationDetails
    static testmethod void getMyAccountConsiderationDetails_PositiveTest() {
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        
        System.runAs(objUser) {    
            
            Account objAccount = CmAp_MyAccountCtrlr.getMyAccountConsiderationDetails() ;
            system.assert(objAccount != null) ;
        }
    }
    
        /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/
    static testmethod void getMyAccountConsiderationDetails_NegativeTest() {
        try {
            List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
            String usrName;
            if(portalProfile != null && portalProfile.size() > 0)
                usrName = PORTAL_USERNAMECOMPLETE;
            else
                usrName = USERNAMECOMPLETE;
            
            User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
            Account accountObj = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
            
            System.runAs(objUser) {    
                Account objAccount  = CmAp_MyAccountCtrlr.getMyAccountConsiderationDetails() ;
                system.assert(objAccount.Id == accountObj.Id) ;
            }
        }catch(Exception ex) {} 
    }
    
        /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/
    // getMyAccountAdditionalDetails
    static testmethod void getMyAccountAdditionalDetails_PositiveTest() {
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        
        System.runAs(objUser) {    
            
            Account objAccount = CmAp_MyAccountCtrlr.getMyAccountAdditionalDetails() ;
            system.assert(objAccount != null) ;
        }
    }
    
        /*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        20-Apr-2018
@param:       N/A
@return:      void
@description: Positive Test scenario for  getCurrentUserAccount
********************************************************************/
    static testmethod void getMyAccountAdditionalDetails_NegativeTest() {
        try {
            List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
            String usrName;
            if(portalProfile != null && portalProfile.size() > 0)
                usrName = PORTAL_USERNAMECOMPLETE;
            else
                usrName = USERNAMECOMPLETE;
            
            User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
            Account accountObj = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
            
            System.runAs(objUser) {    
                Account objAccount  = CmAp_MyAccountCtrlr.getMyAccountAdditionalDetails() ;
                system.assert(objAccount.Id == accountObj.Id) ;
            }
        }catch(Exception ex) {}  
    }
}