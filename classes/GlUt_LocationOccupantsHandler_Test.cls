/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        18-12-2017
@description: Test Class for GlUt_LocationOccupantsHandler
Revision(s):  Shivangi Gaur -- 21-12-2017 -- Incorporated review comments on 
                                             AT-1277 dated 20-12-2017.
              Shivangi Gaur -- 22-12-2017 -- Incorporated review comments on 
                                             AT-1277 dated 20-12-2017.
              Shivangi Gaur -- 05-01-2018 -- Updated test class to fix asserts for changes 
                                             made in GlUt_LocationOccupantsHandler
@Revisions	  	AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest
Public Class GlUt_LocationOccupantsHandler_Test{
    
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
        Database.insert(objConsiderationInactive);
                
        //Create inactive location occupant record
        LocationOccupant__c locOccObjInActive = GlUt_FactoryData_Test.createLocationOccupant(objAccountInActive, locObj);
        locOccObjInActive.StartDate__c = System.today()-10;
        locOccObjInActive.EndDate__c = System.today()-2;
        Database.insert(locOccObjInActive);
        
        //Create active location occupant record
        LocationOccupant__c locOccObjActive = GlUt_FactoryData_Test.createLocationOccupant(objAccount, locObj);
        locOccObjActive.StartDate__c = System.today()-10;
        locOccObjActive.EndDate__c = null;
        Database.insert(locOccObjActive);

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
    Purpose: Test bulk insert for Location Occupant
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void insertLocOccupant_Bulk(){
        
        User dummyUser = [select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Account accObj = [Select id, Name from Account where Name =: ACCOUNTNAME limit 1];
        Location__c locObj = [Select id, LocationSubType__c from Location__c where LocationSubType__c =: LOCSUBTYPE limit 1];
        
        List<LocationOccupant__c> lstLocOcc = new List<LocationOccupant__c>();
        for(integer i =0; i < 200; i++){
            LocationOccupant__c locOcc = GlUt_FactoryData_Test.createLocationOccupant(accObj,locObj);
            locOcc.StartDate__c = system.today()-10;
            locOcc.EndDate__c = null;
            lstLocOcc.add(locOcc);
        }        
        system.runAs(dummyUser){
            
            Test.startTest();
            Database.insert(lstLocOcc);
            
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            
            Test.stopTest();
        }
        
        SupplyPoint__c objSupPoint = [Select id,AllowDisconnection__c,Location__c from SupplyPoint__c where Location__c =: locObj.id limit 1];
        System.assertEquals(objSupPoint.AllowDisconnection__c, true);
        
        //Below code is to check supply point asserted above is linked to location occupant inserted
        //Fetching location from one of the above inserted location occupant record
        LocationOccupant__c locOcc = [Select id, Location__c from LocationOccupant__c where id =: lstLocOcc[0].id];
        //Assert to check supply point asserted above is linked to location occupant record inserted in the test class
        System.assertEquals(objSupPoint.Location__c,locOcc.Location__c);
        
    }
    /*******************************************************************
    Purpose: Test bulk update for Location Occupant
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void updateLocOccupant_Bulk(){
        
        User dummyUser = [select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        
        //Create account record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNTNAME);
        Database.insert(objAccount);
        
        //Create location record
        Location__c locObj = GlUt_FactoryData_Test.createLocation(ZIPCODE);
        locObj.LocationSubType__c = LOCSUBTYPE;
        Database.insert(locObj);
        
        //Create consideration type record
        ConsiderationType__c objConType = GlUt_FactoryData_Test.createConsiderationType(CONSIDERATIONTYPNAME);
        objConType.DisconnectionPermitted__c = false;
        Database.insert(objConType);
        
        //Create consideration record
        Consideration__c objConsideration = GlUt_FactoryData_Test.createConsideration(objAccount,objConType);
        Database.insert(objConsideration);
        
        SupplyPointUsageType__c objSupplyPointUsageType = [select Id from SupplyPointUsageType__c limit 1];
        
        //Create supply point record
        SupplyPoint__c supPointObj = GlUt_FactoryData_Test.createSupplyPoint(locObj, objSupplyPointUsageType);
        //supPointObj.Measured__c = MEASUREDVAL;

        supPointObj.SupplyDisconnectionStatus__c = GlUt_Constants.SUPPLYDISCONNECTIONSTATUS;
        supPointObj.AllowDisconnection__c = false;
        Database.insert(supPointObj);
        
        //Insert bulk location occupant records
        List<LocationOccupant__c> lstLocOcc = new List<LocationOccupant__c>();
        for(integer i =0; i < 200; i++){
            LocationOccupant__c locOcc = GlUt_FactoryData_Test.createLocationOccupant(objAccount,locObj);
            locOcc.StartDate__c = system.today()-10;
            locOcc.EndDate__c = system.today()+10;
            lstLocOcc.add(locOcc);
        }
        Database.insert(lstLocOcc);
        
        system.runAs(dummyUser){
            
            Test.startTest();
            
            //Update location occupant records to inactive to check for Allow Disconnection = false
            for(integer i =0; i < 200; i++){
                lstLocOcc[i].EndDate__c = null;
            }            
            Database.update(lstLocOcc);
            
            //Assert to check Allow Disconnection on Supply Point is updated successfully
            SupplyPoint__c objSupPointUpdated = [Select id,AllowDisconnection__c,Location__c from SupplyPoint__c where Location__c =: locObj.id limit 1];
            System.assertEquals(objSupPointUpdated.AllowDisconnection__c, false);
            
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            
            Test.stopTest();
            
            //Below code is to check supply point asserted above is linked to location occupant updated
            //Fetching location from above updated location occupant record
            LocationOccupant__c locOcc = [Select id, Location__c from LocationOccupant__c where id =: lstLocOcc[0].id];
            //Assert to check supply point asserted above is linked to location occupant record updated in the test class
            System.assertEquals(objSupPointUpdated.Location__c,locOcc.Location__c);
            
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
                
        LocationOccupant__c locOccObj = [Select id,Location__c,ActiveBackground__c from LocationOccupant__c where ActiveBackground__c = false limit 1];
        
        
        locOccObj.StartDate__c = System.today()-10;
        locOccObj.EndDate__c = System.today()+10;
        
        system.runAs(dummyUser){
            
            Test.startTest();
            Database.update(locOccObj);
            SupplyPoint__c objSPoint = [Select id,AllowDisconnection__c,Location__c,SupplyDisconnectionStatus__c from SupplyPoint__c where Location__c =: locOccObj.Location__c limit 1];
            objSPoint.SupplyDisconnectionStatus__c = SUPPLYDISCONSTATUS;
            Database.update(objSPoint);
            locOccObj.EndDate__c = System.today()+20;
            Database.update(locOccObj);
            Test.stopTest();
            
        }
        
        SupplyPoint__c objSupPoint = [Select id,AllowDisconnection__c,Location__c from SupplyPoint__c where Location__c =: locOccObj.Location__c limit 1];
        System.assertEquals(objSupPoint.AllowDisconnection__c, false);
        
        //Below code is to check supply point asserted above is linked to location occupant updated
        //Fetching location from above updated location occupant record
        LocationOccupant__c locOcc = [Select id, Location__c from LocationOccupant__c where id =: locOccObj.id];
        //Assert to check supply point asserted above is linked to location occupant record updated in the test class
        System.assertEquals(objSupPoint.Location__c,locOcc.Location__c);
        
    }
    /*******************************************************************
    Purpose: To test positive scenario of setAllowDisconnectionUpdate() method
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void setAllowDisconnectionUpdate_Positive(){
        
        User dummyUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        //Create account record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNTNAME);
        Database.insert(objAccount);
        
        //Create location record
        Location__c locObj = GlUt_FactoryData_Test.createLocation(ZIPCODE);
        locObj.LocationSubType__c = LOCSUBTYPE;
        Database.insert(locObj);
        
        //Create consideration type record
        ConsiderationType__c objConType = GlUt_FactoryData_Test.createConsiderationType(CONSIDERATIONTYPNAME);
        objConType.DisconnectionPermitted__c = true;
        Database.insert(objConType);
        
        //Create consideration record
        Consideration__c objConsideration = GlUt_FactoryData_Test.createConsideration(objAccount,objConType);
        Database.insert(objConsideration);
        
        SupplyPointUsageType__c objSupplyPointUsageType = [select Id from SupplyPointUsageType__c limit 1];
        
        //Create supply point record
        SupplyPoint__c supPointObj = GlUt_FactoryData_Test.createSupplyPoint(locObj, objSupplyPointUsageType);
        //supPointObj.Measured__c = MEASUREDVAL;
 
        supPointObj.SupplyDisconnectionStatus__c = GlUt_Constants.SUPPLYDISCONNECTIONSTATUS;
        supPointObj.AllowDisconnection__c = false;
        Database.insert(supPointObj);
        
        LocationOccupant__c locOccObj = GlUt_FactoryData_Test.createLocationOccupant(objAccount, locObj);
        locOccObj.StartDate__c = System.today()-10;
        locOccObj.EndDate__c = System.today()-7;
        Database.insert(locOccObj);
        
        locOccObj.EndDate__c = null;
        system.runAs(dummyUser){
            
            Test.startTest();
            Database.update(locOccObj);
            Test.stopTest();
            
        }
        SupplyPoint__c objSupPoint = [Select id,AllowDisconnection__c,Location__c from SupplyPoint__c where id =: supPointObj.id limit 1];
        System.assertEquals(true, objSupPoint.AllowDisconnection__c);
        
        //Below code is to check supply point asserted above is linked to location occupant updated
        //Fetching location from above updated location occupant record
        LocationOccupant__c locOcc = [Select id, Location__c from LocationOccupant__c where id =: locOccObj.id];
        //Assert to check supply point asserted above is linked to location occupant record updated in the test class
        System.assertEquals(objSupPoint.Location__c,locOcc.Location__c);
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
        newTriggerObj.TriggerObject = GlUt_Constants.OBJLOCATIONOCCUPANTS;
        GlUt_LocationOccupantsHandler triggerHandler = new GlUt_LocationOccupantsHandler();
        
        system.runAs(dummyUser){
            
            Test.startTest();
            triggerHandler.InProgressEntry(newTriggerObj);
            Test.stopTest();
            System.assert(GlUt_CentralDispatcher.activefunction == null);
            
        }
        //No assert added since the method in GlUt_LocationOccupantsHandler class is not performing any actions as of now.
        
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
        Location__c locObj = [Select id, LocationSubType__c from Location__c where LocationSubType__c =: LOCSUBTYPE limit 1];
        LocationOccupant__c locOccObj = GlUt_FactoryData_Test.createLocationOccupant(objAccount, locObj);
        locOccObj.StartDate__c = System.today()-10;
        locOccObj.EndDate__c = System.today()+10;
        
        system.runAs(dummyUser){
            
            Test.startTest();
            Database.insert(locOccObj);
            Test.stopTest();
            
        }
        
        SupplyPoint__c objSupPoint = [Select id,AllowDisconnection__c,Location__c from SupplyPoint__c where Location__c =: locObj.id limit 1];
        System.assertEquals(objSupPoint.AllowDisconnection__c, true);
        
        //Below code is to check supply point asserted above is linked to location occupant inserted
        //Fetching location from above inserted location occupant record
        LocationOccupant__c locOcc = [Select id, Location__c from LocationOccupant__c where id =: locOccObj.id];
        //Assert to check supply point asserted above is linked to location occupant record inserted in the test class
        System.assertEquals(objSupPoint.Location__c,locOcc.Location__c);
        
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
        Account objAccount = [Select id, Name from Account where Name =: ACCOUNTNAMENEW limit 1];      
        
        Location__c locObj = [Select id, LocationSubType__c from Location__c where LocationSubType__c =: LOCSUBTYPE limit 1];
        
        //Update supply point Supply Disconnection Status to test for negative scenario where trigger does not work
        SupplyPoint__c objSupPoint = [Select id,AllowDisconnection__c,Location__c from SupplyPoint__c where Location__c =: locObj.id limit 1];
        objSupPoint.SupplyDisconnectionStatus__c = SUPPLYDISCONSTATUS;
        Database.update(objSupPoint);
        
        LocationOccupant__c locOccObj = GlUt_FactoryData_Test.createLocationOccupant(objAccount, locObj);
        locOccObj.StartDate__c = System.today()-10;
        locOccObj.EndDate__c = System.today()+10;
        system.runAs(dummyUser){
            
            Test.startTest();
            Database.insert(locOccObj);
            Test.stopTest();
            
        }
        SupplyPoint__c supPointObj = [Select id,AllowDisconnection__c,Location__c from SupplyPoint__c where Id =: objSupPoint.id limit 1];
        System.assertEquals(supPointObj.AllowDisconnection__c, false);

        //Below code is to check supply point asserted above is linked to location occupant inserted
        //Fetching location from above inserted location occupant record
        LocationOccupant__c locOcc = [Select id, Location__c from LocationOccupant__c where id =: locOccObj.id];
        //Assert to check supply point asserted above is linked to location occupant record inserted in the test class
        System.assertEquals(supPointObj.Location__c,locOcc.Location__c);        
    }
    /*******************************************************************
    Purpose: To test negative scenario of setAllowDisconnectionInsert() 
             method where the checkbox is set to false on location occupant insert
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void setAllowDisconnectionInsertToFalse_Negative(){
        
        User dummyUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Account objAccount = [Select id, Name from Account where Name =: ACCOUNTNAMENEW limit 1];
        Location__c locObj = [Select id, LocationSubType__c from Location__c where LocationSubType__c =: LOCSUBTYPE limit 1];
        LocationOccupant__c locOccObj = GlUt_FactoryData_Test.createLocationOccupant(objAccount, locObj);
        locOccObj.StartDate__c = System.today()-10;
        locOccObj.EndDate__c = null;
        
        system.runAs(dummyUser){
            
            Test.startTest();
            Database.insert(locOccObj);
            Test.stopTest();
            
        }
        
        SupplyPoint__c objSupPoint = [Select id,AllowDisconnection__c,Location__c from SupplyPoint__c where Location__c =: locObj.id limit 1];
        System.assertEquals(objSupPoint.AllowDisconnection__c, false);
        
        //Below code is to check supply point asserted above is linked to location occupant inserted
        //Fetching location from above inserted location occupant record
        LocationOccupant__c locOcc = [Select id, Location__c from LocationOccupant__c where id =: locOccObj.id];
        //Assert to check supply point asserted above is linked to location occupant record inserted in the test class
        System.assertEquals(objSupPoint.Location__c,locOcc.Location__c);        
    }
}