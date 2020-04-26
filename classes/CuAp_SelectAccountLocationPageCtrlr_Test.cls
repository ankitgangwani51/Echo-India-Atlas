/******************************************************************************
@author:      Accenture: Ashish Tiwari
@date:        04 December 2017
@description: Test Class for CuAp_SelectAccountLocationPageCtrlr
@Revisions	  	05/03/19 Tarun , Fixed consdev test class deployment failures.
*******************************************************************************/
@isTest
Public Class CuAp_SelectAccountLocationPageCtrlr_Test{
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME = 'TestUser'; 
    private static String ACCOUNT_NAME = 'TestAccount'; 
    private static String ZIPCODE='ws2 8de';
    private static String OPERATOR='Equals';
    private static String PROPERTY='Zip/Postal Code';
    
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
}        
/*******************************************************************
Purpose: Method to test retrieveLocationPropDetails method
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testRetrieveLocationPropDetails(){
        User objuser = [Select id,name from user where isActive = true limit 1];
        system.runas(objUser){
            Test.startTest();
            List<GLAp_FieldProps> fieldPropList = CuAp_SelectAccountLocationPageCtrlr.retrieveLocationPropDetails();
            Test.stopTest();
            system.assert(fieldPropList.size()>0);
        }
    }
/*******************************************************************
Purpose: Method to test Positive scenario for getLocationOccupants method
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testgetLocationOccupants_Positive(){
        
        User objuser = [Select id,name from user where isActive = true limit 1];
        Account objAccount = [Select id from Account limit 1];
        LocationOccupant__c objLocationOccupants = [Select id from LocationOccupant__c limit 1];
        Location__c  objLocation = [Select id, City__c, Street__c, State__c, PostalCode__c, Country__c, AuDPID__c from Location__c limit 1];
        system.runas(objUser){
            Test.startTest();
          //  List<BlAp_CombinedRecord> combinedRec = CuAp_SelectAccountLocationPageCtrlr.getLocationOccupants(objAccount.id,ZIPCODE,OPERATOR,PROPERTY);
             List<BlAp_CombinedRecord> combinedRec = CuAp_SelectAccountLocationPageCtrlr.queryForLocations(objAccount.id,objLocation);
            Test.stopTest();
            system.assert(combinedRec.size()>0);
            System.assertEquals(combinedRec[0].isSelected,false);
            System.assertEquals(combinedRec[0].uniqueId,objLocationOccupants.id);
        }
    }
/*******************************************************************
Purpose: Method to test Negative scenario for getLocationOccupants method
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void testgetLocationOccupants_Negative(){
        
        User objuser = [Select id,name from user where isActive = true limit 1];
        Account objAccount = [Select id from Account limit 1];
        // Location__c  objLocation = [Select id, City__c, Street__c, State__c, PostalCode__c, Country__c, AuDPID__c from Location__c limit 1];
        Location__c  objLocation = new Location__c();
        Boolean isException = false;
        List<BlAp_CombinedRecord> combinedRec = new List<BlAp_CombinedRecord>();
        system.runas(objUser){
            Test.startTest();
            try{
                // List<BlAp_CombinedRecord> combinedRec = CuAp_SelectAccountLocationPageCtrlr.getLocationOccupants(null,ZIPCODE,OPERATOR,PROPERTY);
                combinedRec = CuAp_SelectAccountLocationPageCtrlr.queryForLocations(objAccount.id,objLocation);
            } catch(Exception ex){
                isException = true;
            }
            Test.stopTest();
            System.assert(combinedRec.size() == 0);
            
        }
    }
}