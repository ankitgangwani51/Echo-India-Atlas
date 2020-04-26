/******************************************************************************
@author:      Accenture: Ashish Tiwari
@date:        06 December 2017
@description: Test Class for CuAp_SelectOccupantsPageCtrlr
*******************************************************************************/

@isTest

Public Class CuAp_SelectOccupantsPageCtrlr_Test{
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME = 'TestUser'; 
    private static String ACCOUNT_NAME = 'TestAccount'; 
    private static String ZIPCODE='ws2 8de';
    private static String LANDLORD = 'Landlord';
    
    
/*******************************************************************
Purpose: method to create test data used by all USER_NAMEtest methods
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    @TestSetup
    Static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE ,USER_NAME ,null);
        Database.insert(objUser);
        
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        Location__c  objLocation = GlUt_FactoryData_Test.CreateLocation(ZIPCODE);
        Database.insert(objLocation);
        
        LocationOccupant__c objLocationOccupants = GlUt_FactoryData_Test.CreateLocationOccupant(objAccount,objLocation);
        Database.insert(objLocationOccupants);
        
        LocationOccupant__c objLocationOccupants1 = GlUt_FactoryData_Test.CreateLocationOccupant(objAccount,objLocation);
        objLocationOccupants1.OccupancyType__c = LANDLORD;
        Database.insert(objLocationOccupants1);
        
        
        
}        
/*******************************************************************
Purpose: Method to test Positive scanario for retrieveLocationPropDetails method
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testRetrieveLocationPropDetails_Positive(){
        
        User objuser = [select id from user limit 1];
        system.runas(objUser){
            Test.startTest();
            List<GLAp_FieldProps> FieldPropLst = CuAp_SelectOccupantsPageCtrlr.retrieveLocationPropDetails();
            Test.stopTest();
            system.assert(FieldPropLst.size()>0);
        }
    
    }

/*******************************************************************
Purpose: Method to test Positive scanario for getLocationOccupants method
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testGetLocationOccupants_Positive(){
        String[] str = String.valueOf(System.today()).split('-');
        String NEWDATE = str[0]+'-'+str[1]+'-'+str[2];
        User objuser = [select id from user limit 1];
        Location__c objLocation = [Select id from Location__c limit 1];
        system.runas(objUser){
            Test.startTest();
            List<BlAp_CombinedRecord> combinedRec = CuAp_SelectOccupantsPageCtrlr.getLocationOccupants(objLocation.id,NEWDATE);
            Test.stopTest();
            system.assert(combinedRec.size()>0);
        }
    
    }
/*******************************************************************
Purpose: Method to test Negative scanario for getLocationOccupants method
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testGetLocationOccupants_Negative(){
        String[] str = String.valueOf(System.today()).split('-');
        String NEWDATE = str[0]+'-'+str[1]+'-'+str[2];
        User objuser = [select id from user limit 1];
        system.runas(objUser){
            Test.startTest();
            List<BlAp_CombinedRecord> combinedRec = CuAp_SelectOccupantsPageCtrlr.getLocationOccupants(null,NEWDATE);
            Test.stopTest();
            system.assert(combinedRec.size()==0);
        }
    
    }
/*******************************************************************
Purpose: Method to test Positive scanario for queryLocation method
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testQueryLocation_Positive(){
        User objuser = [select id from user limit 1];
        Location__c objLocation = [Select id from Location__c limit 1];
        system.runas(objUser){
            Test.startTest();
            List<String> locationRef = CuAp_SelectOccupantsPageCtrlr.queryLocation(objLocation.id);
            Test.stopTest();
            system.assert(locationRef.size()>0);
        }
    
    }
/*******************************************************************
Purpose: Method to test Negative scanario for queryLocation method
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testQueryLocation_Negative(){
        User objuser = [select id from user limit 1];
        system.runas(objUser){
            Test.startTest();
            List<String> locationRef = CuAp_SelectOccupantsPageCtrlr.queryLocation(null);
            Test.stopTest();
            system.assert(locationRef.size()==0);
        }
    
    }
}