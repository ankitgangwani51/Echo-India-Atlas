/******************************************************************************
@author:      Neha Rajput
@date:        10 May 2018
@description: Test Class for BlUt_ADUCalculation
@revision: Swati - did Amendments to both methods
*******************************************************************************/
@isTest
public class LoAp_ReSequenceBookCtrlr_Test {
    
    //Variables...
    private static String PROFILENAME = 'System Administrator';
    private static String USERNAME = 'TestUser';
    private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    private static String LOCATION= 'A99 9AA';    
    private static String DETACHED = 'Detached';
    private static String STRTEST ='test';
    private static String HOUSEHOLD = 'Household';
    private static String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static String MEASURED= 'Monthly';
    private static String YES = 'yes';
    private static String READTIMETABLE_NAME = 'Monthly';
    private static String READTIMETABLE_READFREQUENCY = 'Monthly';
    private static String DEPOT_NAME = 'abc depot';
    private static Integer WALK_ORD = 59 ;
    private static Integer WALKORD_SPACING = 10;
    
    /*******************************************************************
    Purpose: Method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/    
    @TestSetup
    Static void createTestData(){
        
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(PROFILENAME,USERNAME,null);
        Database.insert(objUser);
        
        //Create location record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION);
        objLocation.LocationSubType__c = DETACHED ; 
        objLocation.Street__c = STRTEST ;
        objLocation.NumberOfOccupiers__c = 1;
        objLocation.LocationType__c= HOUSEHOLD;
        Database.insert(objLocation);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Create ReadTimetable Record
        ReadTimetable__c objReadTimetable= GlUt_FactoryData_Test.createReadTimetable(READTIMETABLE_NAME, READTIMETABLE_READFREQUENCY);        
        Database.insert(objReadTimetable);
        
        //Create Depot Record
        Depot__c objDepot= GlUt_FactoryData_Test.createDepot(DEPOT_NAME);
        Database.insert(objDepot);
        
        //Create Book Record
        Book__c objBook = GlUt_FactoryData_Test.createBook(objDepot, objReadTimeTable);
        objBook.ReadFrequency__c = MEASURED;
        Database.insert(objBook);
        
        //Create Supply Point Record
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; // AT-3174 
        objSupplyPoint.Book__c = objBook.Id;
        objSupplyPoint.WalkOrder__c = WALK_ORD;
        Database.insert(objSupplyPoint);        
    }
    
    /*******************************************************************
    Purpose: 
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void reSequenceWalkOrder(){
        
        User dummyUser = [SELECT Id, Name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
        Integer totalUpdatedRecord = 0 ;
        system.runAs(dummyUser){            
            Book__c objBook = [SELECT Id FROM Book__c LIMIT 1];            
            Test.startTest();          
            totalUpdatedRecord = LoAp_ReSequenceBookCtrlr.reSequenceWalkOrder(objBook.Id, WALKORD_SPACING);
            Test.StopTest();
        }
        system.assert(totalUpdatedRecord == 1);
        SupplyPoint__c objSupplyPoint = [SELECT Id,WalkOrder__c FROM SupplyPoint__c];
        system.assert(objSupplyPoint.WalkOrder__c == WALKORD_SPACING);        
    }
    
    /*******************************************************************
    Purpose: 
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void reSequenceWalkOrder_Neg(){
        
        User dummyUser = [SELECT Id, Name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
        Integer totalUpdatedRecord = 0 ;
        system.runAs(dummyUser){            
            Book__c objBook = new Book__c();            
            Test.startTest();          
            totalUpdatedRecord = LoAp_ReSequenceBookCtrlr.reSequenceWalkOrder(null, WALKORD_SPACING);
            Test.StopTest();
        }
        system.assert(totalUpdatedRecord == 0);
        SupplyPoint__c objSupplyPoint = [SELECT Id,WalkOrder__c FROM SupplyPoint__c];
        system.assert(objSupplyPoint.WalkOrder__c != WALKORD_SPACING);
        system.assert(objSupplyPoint.WalkOrder__c == WALK_ORD);
        
    }
    
}