/******************************************************************************
@author         Tarun Gupta 
@date           21 Sep 2018
@description    Test class for CuAp_SelectLocationOccToAmendCtrlr
*******************************************************************************/
@isTest 
public class CuAp_SelectLocationOccToAmendCtrlr_Test {
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String DEVICE_NAME = '123456789';
    private static final String RELATED_LIST = 'RelatedListDetails';
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        04-04-2018  
	@description: Test data setup method
	*******************************************************************************/
    @TestSetup
    static void createTestData()
    {
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USER_NAME, null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize, MANUFACTURER, UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);        
        Database.insert(objDevice);
        
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading);
        
    }

	/******************************************************************************
	@author:      Echo: Neha
	@date:        05-04-2018  
	@description: Test Method 
	*******************************************************************************/
    static testmethod void retrieveFieldProperties_Positive(){            
        
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
      
        System.runAs(objUser){
            Test.startTest(); 
            
        	List<GLAp_FieldProps> fieldPropsList = new List<GLAp_FieldProps>(); 
        	
        	fieldPropsList = CuAp_SelectLocationOccToAmendCtrlr.retrieveLocationOccupantFieldPropDetails(); 
          
            system.assert(fieldPropsList.size() > 0);
            Test.stopTest();          
        }         
    } 

}