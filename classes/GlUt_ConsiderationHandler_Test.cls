/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        19-12-2017
@description: Test Class for GlUt_ConsiderationHandler
Revision(s):  Shivangi Gaur -- 21-12-2017 -- Incorporated review comments on 
                                             AT-1278 dated 20-12-2017.
              Shivangi Gaur -- 05-01-2018 -- Made changes to fix asserts and increase 
                                             coverage as per changes done to GlUt_ConsiderationHandler.
@Revisions	  	AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest
Public Class GlUt_ConsiderationHandler_Test{
    
    //Variable declaration start
    
    private static string ACCOUNTNAME = 'Test Account';
    private static string ACCOUNTNAMENEW = 'Test Account New';
    private static string ZIPCODE = 'EC2R 6AB';
    private static string LOCSUBTYPE = 'Flat';
    private static string MEASUREDVAL = 'Yes';
    private static String PROFILENAME = 'System Administrator';
    private static String USERNAME = 'TestUser444';
    private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    private static String CONSIDERATIONTYPNAME = 'Test Consideration Type';
    private static String SUPPLYDISCONSTATUS = 'Shared Supply';
    private static Integer MAXDMLSTATEMENTS = 50;
    private static Integer MAXQUERIES       = 70;
    private static String LIMITCONST1       =  'Fewer than ';
    private static String LIMITCONST2       =  ' DML statements should have been executed : ';
    private static String LIMITCONST3       =  ' SOQL statements should have been executed : ';    
    
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String MEASURED = 'Monthly';
    //Variable declaration end
    
    /*******************************************************************
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/    
    @TestSetup
    Static void createTestData(){  

        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(PROFILENAME,USERNAME,null);
        Database.insert(objUser);
        
        //Create account record for consideration type as disconnection permitted = true
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNTNAME);
        Database.insert(objAccount);
        
        //Create account record for consideration type as disconnection permitted = false
        Account objAccountInActive = GlUt_FactoryData_Test.createAccount(ACCOUNTNAMENEW);
        Database.insert(objAccountInActive);
        
        //Create location record
        Location__c locObj = GlUt_FactoryData_Test.createLocation(ZIPCODE);
        locObj.LocationSubType__c = LOCSUBTYPE;
        Database.insert(locObj);
        
        //Create consideration type record for disconnection permitted = true
        ConsiderationType__c objConType = GlUt_FactoryData_Test.createConsiderationType(CONSIDERATIONTYPNAME);
        objConType.DisconnectionPermitted__c = true;
        Database.insert(objConType);
        
        //Create consideration record for above consideration type
        Consideration__c objConsideration = GlUt_FactoryData_Test.createConsideration(objAccount,objConType);
        Database.insert(objConsideration);
        
        //Create consideration type record for disconnection permitted = false
        ConsiderationType__c objConTypeInactive = GlUt_FactoryData_Test.createConsiderationType(CONSIDERATIONTYPNAME);
        objConTypeInactive.DisconnectionPermitted__c = false;
        Database.insert(objConTypeInactive);
        
        //Create consideration record for above consideration type
        Consideration__c objConsiderationInactive = GlUt_FactoryData_Test.createConsideration(objAccountInActive,objConTypeInactive);
        objConsiderationInactive.Active__c = false;
        Database.insert(objConsiderationInactive);
                
        //Create active location occupant record
        LocationOccupant__c locOccObjActive = GlUt_FactoryData_Test.createLocationOccupant(objAccount, locObj);
        locOccObjActive.StartDate__c = System.today()-10;
        locOccObjActive.EndDate__c = null;
        Database.insert(locOccObjActive);
        
         //Create inactive location occupant record
        LocationOccupant__c locOccObjInActive = GlUt_FactoryData_Test.createLocationOccupant(objAccountInActive, locObj);
        locOccObjInActive.StartDate__c = System.today()-10;
        locOccObjInActive.EndDate__c = System.today()-2;
        Database.insert(locOccObjInActive);

        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Create supply point record
        SupplyPoint__c supPointObj = GlUt_FactoryData_Test.createSupplyPoint(locObj, objSupplyPointUsageType);
        supPointObj.Measured__c = True; // AT-3174
        supPointObj.SupplyDisconnectionStatus__c = GlUt_Constants.SUPPLYDISCONNECTIONSTATUS;
        supPointObj.AllowDisconnection__c = false;
        Database.insert(supPointObj);
       
        
    }
    /*******************************************************************
    Purpose: Test bulk insert for Consideration
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void insertConsideration_Bulk(){
        
        User dummyUser = [select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Account accObj = [Select id, Name from Account where Name =: ACCOUNTNAME limit 1];
        ConsiderationType__c objConType = [Select id from ConsiderationType__c where DisconnectionPermitted__c = true limit 1];
        
        List<Consideration__c> lstConsideration = new List<Consideration__c>();
        for(integer i =0; i < 200; i++){
            Consideration__c considerationObj = GlUt_FactoryData_Test.createConsideration(accObj,objConType);
            lstConsideration.add(considerationObj);
        }        
        system.runAs(dummyUser){
            
            Test.startTest();
            Database.insert(lstConsideration);
            
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            
            Test.stopTest();
        }
        
        SupplyPoint__c objSupPoint = [Select id,AllowDisconnection__c,Location__c from SupplyPoint__c where 
                                                        SupplyDisconnectionStatus__c =: GlUt_Constants.SUPPLYDISCONNECTIONSTATUS limit 1];
        System.assertEquals(objSupPoint.AllowDisconnection__c, true);
        
        //Below code is to check supply point asserted above is linked to consideration inserted
        //Fetch Location and its location occupants based on supply point asserted above
        Location__c locObj = [Select id, (Select id, Account__c from LocationOccupants__r limit 1) from Location__c where id =: objSupPoint.Location__c];
        //Fetching single Location Occupant since we have only 1 record created in the test class
        LocationOccupant__c locOcc = locObj.LocationOccupants__r;
        //Assert to check supply point asserted above is linked to consideration record inserted in the test class
        System.assertEquals(locOcc.Account__c,lstConsideration[0].Account__c);
        
    }
    /*******************************************************************
    Purpose: Test bulk update for Consideration
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void updateConsideration_Bulk(){
        
        User dummyUser = [select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Account accObj = [Select id, Name from Account where Name =: ACCOUNTNAME limit 1];
        ConsiderationType__c objConType = [Select id from ConsiderationType__c where DisconnectionPermitted__c = true limit 1];
        
        List<Consideration__c> lstConsideration = new List<Consideration__c>();
        for(integer i =0; i < 200; i++){
            Consideration__c considerationObj = GlUt_FactoryData_Test.createConsideration(accObj,objConType);
            considerationObj.Active__c = false;
            lstConsideration.add(considerationObj);
        }
        Database.insert(lstConsideration);
        for(integer i =0; i < 200; i++){
            lstConsideration[i].Active__c = true;
        }
        
        system.runAs(dummyUser){
            
            Test.startTest();
            Database.update(lstConsideration);
            
            SupplyPoint__c objSupPoint = [Select id,AllowDisconnection__c,Location__c from SupplyPoint__c where 
                                            SupplyDisconnectionStatus__c =: GlUt_Constants.SUPPLYDISCONNECTIONSTATUS limit 1];
            System.assertEquals(objSupPoint.AllowDisconnection__c, false);
            
            //Update consideration records to check for Allow Disconnection to be false on consideration bulk update
            for(integer i =0; i < 200; i++){
                lstConsideration[i].Active__c = false;
            }
            Database.update(lstConsideration);
            SupplyPoint__c objSupPointNew = [Select id,AllowDisconnection__c,Location__c from SupplyPoint__c where 
                                            SupplyDisconnectionStatus__c =: GlUt_Constants.SUPPLYDISCONNECTIONSTATUS limit 1];
            System.assertEquals(objSupPointNew.AllowDisconnection__c, true);
            
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            
            Test.stopTest();
            
            //Below code is to check supply point asserted above is linked to consideration updated
            //Fetch Location and its location occupants based on supply point asserted above
            Location__c locObj = [Select id, (Select id, Account__c from LocationOccupants__r limit 1) from Location__c where id =: objSupPointNew.Location__c];
            //Fetching single Location Occupant since we have only 1 record created in the test class
            LocationOccupant__c locOcc = locObj.LocationOccupants__r;
            //Assert to check supply point asserted above is linked to consideration record updated in the test class
            System.assertEquals(locOcc.Account__c,lstConsideration[0].Account__c);
        }
        
        
        
    }
    /*******************************************************************
    Purpose: To test negative scenario of setAllowDisconnectionUpdate() method.
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void setAllowDisconnectionUpdate_Negative(){
        
        User dummyUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Consideration__c objConsideration = [Select id, Active__c,Account__c from Consideration__c where Active__c = true limit 1];
        objConsideration.Active__c = false;
        
        system.runAs(dummyUser){
            
            Test.startTest();
            Database.update(objConsideration);
            Test.stopTest();
            
        }
        SupplyPoint__c objSupPoint = [Select id,AllowDisconnection__c,Location__c from SupplyPoint__c where 
                                            SupplyDisconnectionStatus__c =: GlUt_Constants.SUPPLYDISCONNECTIONSTATUS limit 1];
        System.assertEquals(true, objSupPoint.AllowDisconnection__c);
        
        //Below code is to check supply point asserted above is linked to consideration updated
        //Fetch Location and its location occupants based on supply point asserted above
        Location__c locObj = [Select id, (Select id, Account__c from LocationOccupants__r limit 1) from Location__c where id =: objSupPoint.Location__c];
        //Fetching single Location Occupant since we have only 1 record created in the test class
        LocationOccupant__c locOcc = locObj.LocationOccupants__r;
        //Assert to check supply point asserted above is linked to consideration record updated in the test class
        System.assertEquals(locOcc.Account__c,objConsideration.Account__c);
        
    }
    /*******************************************************************
    Purpose: To test positive scenario of setAllowDisconnectionUpdate() method
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void setAllowDisconnectionUpdate_Positive(){
        
        User dummyUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Consideration__c objConsideration = [Select id, Active__c,Account__c from Consideration__c where Active__c = true limit 1];
        objConsideration.Active__c = false;
        Database.update(objConsideration);
        objConsideration.Active__c = true;
        
        system.runAs(dummyUser){
            
            Test.startTest();
            Database.update(objConsideration);
            Test.stopTest();
            
        }
        SupplyPoint__c objSupPoint = [Select id,AllowDisconnection__c,Location__c from SupplyPoint__c where 
                                                SupplyDisconnectionStatus__c =: GlUt_Constants.SUPPLYDISCONNECTIONSTATUS limit 1];
        System.assertEquals(false, objSupPoint.AllowDisconnection__c);
        
        //Below code is to check supply point asserted above is linked to consideration updated
        //Fetch Location and its location occupants based on supply point asserted above
        Location__c locObj = [Select id, (Select id, Account__c from LocationOccupants__r limit 1) from Location__c where id =: objSupPoint.Location__c];
        //Fetching single Location Occupant since we have only 1 record created in the test class
        LocationOccupant__c locOcc = locObj.LocationOccupants__r;
        //Assert to check supply point asserted above is linked to consideration record updated in the test class
        System.assertEquals(locOcc.Account__c,objConsideration.Account__c);
    }
    /*******************************************************************
    Purpose: To test negative scenario of setAllowDisconnectionUpdate() method
             where checkbox is updated to false
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void setAllowDisconnectionUpdateToFalse_Negative(){
        
        User dummyUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Consideration__c objConsideration = [Select id, Active__c,Account__c from Consideration__c where Active__c = false limit 1];
        objConsideration.Active__c = true;
        
        system.runAs(dummyUser){
            
            Test.startTest();
            Database.update(objConsideration);
            Test.stopTest();
            
        }
        SupplyPoint__c objSupPoint = [Select id,AllowDisconnection__c,Location__c from SupplyPoint__c where 
                                                SupplyDisconnectionStatus__c =: GlUt_Constants.SUPPLYDISCONNECTIONSTATUS limit 1];
        
      //  System.assertEquals(false, objSupPoint.AllowDisconnection__c);
        
        //Below code is to check supply point asserted above is linked to consideration updated
        //Fetch Location and its location occupants based on supply point asserted above
        Location__c locObj = [Select id, (Select id, Account__c, Active__c from LocationOccupants__r where Active__c = false limit 1) from Location__c where id =: objSupPoint.Location__c];
        //Fetching single Location Occupant since we have only 1 record created in the test class
        LocationOccupant__c locOcc = locObj.LocationOccupants__r;
        //Assert to check supply point asserted above is linked to consideration record updated in the test class
        System.assertEquals(locOcc.Account__c,objConsideration.Account__c);
    }
    /*******************************************************************
    Purpose: To test InProgressEntry() method
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void InProgressEntry_Positive(){
        
        User dummyUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        GlUt_TriggerHandlerObj newTriggerObj = new GlUt_TriggerHandlerObj();
        newTriggerObj.TriggerObject = GlUt_Constants.OBJCONSIDERATION;
        GlUt_ConsiderationHandler triggerHandler = new GlUt_ConsiderationHandler();
        //GlUt_CentralDispatcher objCentralDispatcher = new GlUt_CentralDispatcher();
        system.runAs(dummyUser){
            
            Test.startTest();
            triggerHandler.InProgressEntry(newTriggerObj);
            Test.stopTest();
            
            System.assert(GlUt_CentralDispatcher.activefunction == null);
        }
        //No assert added since the method in GlUt_ConsiderationHandler class is not performing any actions as of now.
        
    }
    /*******************************************************************
    Purpose: To test positive scenario of setAllowDisconnectionInsert() 
             method
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void setAllowDisconnectionInsert_Positive(){
        
        User dummyUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Account objAccount = [Select id, Name from Account where Name =: ACCOUNTNAME limit 1];
        ConsiderationType__c objConType = [Select id from ConsiderationType__c where DisconnectionPermitted__c = true limit 1];
        Consideration__c objConsideration = GlUt_FactoryData_Test.createConsideration(objAccount,objConType);        
        
        system.runAs(dummyUser){
            
            Test.startTest();
            Database.insert(objConsideration);
            Test.stopTest();
            
        }
        
        SupplyPoint__c objSupPoint = [Select id,AllowDisconnection__c,Location__c from SupplyPoint__c where 
                                                SupplyDisconnectionStatus__c =: GlUt_Constants.SUPPLYDISCONNECTIONSTATUS limit 1];
        System.assertEquals(objSupPoint.AllowDisconnection__c, true);
        
        //Below code is to check supply point asserted above is linked to consideration inserted
        //Fetch Location and its location occupants based on supply point asserted above
        Location__c locObj = [Select id, (Select id, Account__c from LocationOccupants__r limit 1) from Location__c where id =: objSupPoint.Location__c];
        //Fetching single Location Occupant since we have only 1 record created in the test class
        LocationOccupant__c locOcc = locObj.LocationOccupants__r;
        //Assert to check supply point asserted above is linked to consideration record inserted in the test class
        System.assertEquals(locOcc.Account__c,objConsideration.Account__c);
        
    }
    /*******************************************************************
    Purpose: To test negative scenario of setAllowDisconnectionInsert() 
             method
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void setAllowDisconnectionInsert_Negative(){
        
        User dummyUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Account objAccount = [Select id, Name from Account where Name =: ACCOUNTNAME limit 1];
        ConsiderationType__c objConType = [Select id from ConsiderationType__c where DisconnectionPermitted__c = true limit 1];
        
        Consideration__c objConsideration = GlUt_FactoryData_Test.createConsideration(objAccount,objConType);        
        objConsideration.Active__c = false;
        
        system.runAs(dummyUser){
            
            Test.startTest();
            Database.insert(objConsideration);
            Test.stopTest();
            
        }
        
        SupplyPoint__c objSupPoint = [Select id,AllowDisconnection__c,Location__c from SupplyPoint__c where 
                                            SupplyDisconnectionStatus__c =: GlUt_Constants.SUPPLYDISCONNECTIONSTATUS limit 1];
        System.assertEquals(objSupPoint.AllowDisconnection__c, false);
        
        //Below code is to check supply point asserted above is linked to consideration inserted
        //Fetch Location and its location occupants based on supply point asserted above
        Location__c locObj = [Select id, (Select id, Account__c from LocationOccupants__r limit 1) from Location__c where id =: objSupPoint.Location__c];
        //Fetching single Location Occupant since we have only 1 record created in the test class
        LocationOccupant__c locOcc = locObj.LocationOccupants__r;
        //Assert to check supply point asserted above is linked to consideration record inserted in the test class
        System.assertEquals(locOcc.Account__c,objConsideration.Account__c);
    }
}