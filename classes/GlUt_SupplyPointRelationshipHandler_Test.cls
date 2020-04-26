/******************************************************************************
@author:      Echo: Ankit Gangwani 
@date:        26 June 2018
@description: Test Class for GlUt_SupplyPointRelationshipHandler
@Revisions	  	AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/

@isTest  
public class GlUt_SupplyPointRelationshipHandler_Test {   
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String ACCOUNT_NAME = 'TEST_ACCOUNT';
    private static final String LOCATION_NAME = 'A99 9AA';    
    private static final String MEASURED ='Yes';
    private static final String READFREQUENCY_M = 'Monthly'; 
    private static final String READFREQUENCY_HY = 'Half Yearly';
    private static final String CONTYPE_NAME ='Test Consideration Type';
    private static final String DISCONNECTED_STATUS = 'Shared Supply';
    private static final String SUPPLYDISCONNECTIONSTATUS = 'Able to Disconnect';
    private static final String NULL_VALUE = null ;
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String DEVICE_NAME2 = 'TestDevice2';
    private static final String DEVICE_NAME3 = 'TestDevice3';
    private static final String DEVICE_NAME4 = 'TestDevice4';
    private static final String SUB_DEVICE_TYPE ='TestSubDevice';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String FIRST = 'First';
    private static final String SECOND = 'Second';
    
    private static Boolean isException;
  
	/******************************************************************************
	@author:      Echo: Neha
	@date:        29-01-2018  
	@description: Test data setup method
	*******************************************************************************/
    @TestSetup
    static void createTestData()
    {
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
                
        // Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);        
        Database.insert(objAccount);
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        Database.insert(objLocation);
        
        // Create Location Occupant Record
        LocationOccupant__c objLocationOccupant = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);        
        Database.insert(objLocationOccupant);    

        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        List<SupplyPoint__c> supplyPointLists = new List<SupplyPoint__c>();
        for(Integer iCount = 0;iCount<200;iCount++){
            SupplyPoint__c objSP = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
            objSP.Measured__c = TRUE;
            objSP.Description__c = String.valueOf(iCount);
            supplyPointLists.add(objSP);
        }        
        
        if(!supplyPointLists.isEmpty())
            Database.insert(supplyPointLists);   
    }    
    
    /*******************************************************************
    Purpose: To test InProgressEntry() method
    Parameters: N/A 
    Returns: void
    @description: Method to test InProgressEntry
    ********************************************************************/
    static testmethod void InProgressEntry_Positive(){
        
        User dummyUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        GlUt_TriggerHandlerObj newTriggerObj = new GlUt_TriggerHandlerObj();
        newTriggerObj.TriggerObject = GlUt_Constants.OBJSUPPLYPOINTRELATIONSHIP;
        GlUt_SupplyPointRelationshipHandler triggerHandler = new GlUt_SupplyPointRelationshipHandler();
        
        system.runAs(dummyUser){            
            Test.startTest();
            triggerHandler.InProgressEntry(newTriggerObj);
            Test.stopTest();  
            System.assert(GlUt_CentralDispatcher.activefunction == null);
        }        
    }
    
    /******************************************************************************
	@author:      Echo: Ankit Gangwani
	@date:        13 Sept 2018
	@description: Method to test checkValidation for GlUt_SupplyPointRelationshipHandler with Positive Scenario		
	*******************************************************************************/
    static testmethod void checkValidation_First_Scenario()
    {            
        GlUt_SupplyPointRelationshipHandler objDeviceRealtionShip = new GlUt_SupplyPointRelationshipHandler();

        User objUser =[SELECT Id, Name 
                       FROM user 
                       WHERE isActive = TRUE
                       AND username =:USERNAMECOMPLETE
                       LIMIT 1];
        
        List<SupplyPoint__c> supplyPointLists = [SELECT Id 
                                                 FROM SupplyPoint__c
                                                 LIMIT 200]; 
        
        List<SupplyPointRelationship__c> supplyPointRelationshipLists = new List<SupplyPointRelationship__c>();
        for(Integer jCount = 0;jCount<supplyPointLists.size();jCount=jCount+2){
            SupplyPointRelationship__c objSPR = GlUt_FactoryData_Test.createSupplyPointRelationship(supplyPointLists[jCount], supplyPointLists[jCount+1]);
            objSPR.StartDate__c = Date.today().addDays(-30);
            if(jCount < 101)
                objSPR.EndDate__c = null;
            else
                objSPR.EndDate__c = Date.today().addDays(30);            
            supplyPointRelationshipLists.add(objSPR);
        }
        
        system.Runas(objUser){
            Test.starttest();
            insert supplyPointRelationshipLists;
            Test.stoptest();
            System.assert(supplyPointRelationshipLists[0].Id != null);
            
        }
    }
    
    /******************************************************************************
    @author:      Echo: Ankit Gangwani
    @date:        13 Sept 2018
	@description: Method to test checkValidation for GlUt_SupplyPointRelationshipHandler with Negative Scenario	
    *******************************************************************************/
    static testmethod void checkValidation_Negative()
    {            
        Boolean isExpected = FALSE;
        GlUt_SupplyPointRelationshipHandler objSPRealtionShip = new GlUt_SupplyPointRelationshipHandler();

        User objUser =[SELECT Id, Name 
                       FROM user 
                       WHERE isActive = TRUE 
                       AND username =:USERNAMECOMPLETE 
                       LIMIT 1];
        
        system.Runas(objUser){
            try{
                Test.starttest();
                objSPRealtionShip.checkValidation(NULL);
                Test.stoptest();
            }catch(Exception ex) {  
                isExpected = TRUE;
                system.debug('exception caught in test context:: ' + ex);
            }
            System.assert(isExpected == TRUE);            
        }
    }
}