/******************************************************************************
@author:      Echo: Neha 
@date:        14/02/18 
@description: Test Class for LoAp_DeviceManagementSelectActionCtrlr
*******************************************************************************/

@isTest  
public class LoAp_DMSelectActionCtrlr_Test {   
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name';    
    private static final String DEVICE_SIZE_NAME = 'Meter';
    private static final String DEVICE_NAME = '123456789';
    private static final String DEVICE_MANUFACTURER = 'Aqua';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String LOCATION_NAME = 'A99 9AA';    
    private static final String MEASURED ='Yes';
    private static final String READFREQUENCY ='Monthly';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String INVALID_LOCATION_ID = 'abc';
      
  
	/******************************************************************************
	@author:      Echo: Neha
	@date:        14-02-2018  
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
			
		// Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        Database.insert(objLocation);
		
        // Create DeviceSize Record
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE_NAME);        
        Database.insert(objDeviceSize);
        
		// Create DeviceType Record
        DeviceType__c objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize, DEVICE_MANUFACTURER, UNIT_OF_MEASURE);        
        Database.insert(objDeviceType);
       
        // Create Device Record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);        
        Database.insert(objDevice);
		
		//Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create SupplyPoint Record
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; // AT-3174 
        Database.insert(objSupplyPoint);
		
		// Create SupplyPointDevice Record
        SupplyPointDevice__c objSupplyPointDevice = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice, objSupplyPoint);        
        Database.insert(objSupplyPointDevice);	
	
    }    
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        14-02-2018  
	@description: POSITIVE scenario with correct Location ID
	*******************************************************************************/
    static testmethod void retrieveActiveDevice_Positive()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Location__c objLocation = [SELECT Id FROM Location__c LIMIT 1];
        
        System.runAs(objUser){
            Test.startTest();       
        
        	LoAp_DeviceManagementSelectActionCtrlr.WrapperObject wrapclass = new  LoAp_DeviceManagementSelectActionCtrlr.WrapperObject();            
        	wrapclass = LoAp_DeviceManagementSelectActionCtrlr.retrieveActiveDevice(objLocation.id);  
            
            Test.stopTest();
            System.assert(wrapclass != null);
        }
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        14-02-2018  
	@description: POSITIVE scenario with correct Location ID with more then one SP 
	*******************************************************************************/
    static testmethod void retrieveActiveDevice_Positive_SP()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        Location__c objLocation = [SELECT Id FROM Location__c LIMIT 1];
        SupplyPointUsageType__c objSupplyPointUsageType = [SELECT Id FROM SupplyPointUsageType__c LIMIT 1];
        
        // create new SP record for same location 
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        //objSupplyPoint.Measured__c = MEASURED;
        Database.insert(objSupplyPoint);
        
        System.runAs(objUser){
            Test.startTest();       
        
        	LoAp_DeviceManagementSelectActionCtrlr.WrapperObject wrapclass = new  LoAp_DeviceManagementSelectActionCtrlr.WrapperObject();            
        	wrapclass = LoAp_DeviceManagementSelectActionCtrlr.retrieveActiveDevice(objLocation.id);  
            
            Test.stopTest();
            System.assert(wrapclass != null);
        }
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        14-02-2018  
	@description: NEGATIVE scenario with NULL Location Id
	*******************************************************************************/
    static testmethod void retrieveActiveDevice_Neg_Null_LID()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
       
        Location__c objLocation = new  Location__c();
        
        System.runAs(objUser){
            Test.startTest(); 
            
        	LoAp_DeviceManagementSelectActionCtrlr.WrapperObject wrapclass = new  LoAp_DeviceManagementSelectActionCtrlr.WrapperObject();            
        	wrapclass = LoAp_DeviceManagementSelectActionCtrlr.retrieveActiveDevice(objLocation.id);  
            
            Test.stopTest();
            System.assert(wrapclass.noOfActiveDevices==0); 
        }
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        14-02-2018  
	@description: NEGATIVE scenario with INVALID LocationId
	*******************************************************************************/
    static testmethod void retrieveActiveDevice_Neg_Invalid_LID()
    {            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        boolean isException;
        
        System.runAs(objUser){
            Test.startTest(); 
            
            try{
        		LoAp_DeviceManagementSelectActionCtrlr.WrapperObject wrapclass = new  LoAp_DeviceManagementSelectActionCtrlr.WrapperObject();            
        		wrapclass = LoAp_DeviceManagementSelectActionCtrlr.retrieveActiveDevice(INVALID_LOCATION_ID);   
            }catch(exception e)
            {
                isException = true;
            }
            
            Test.stopTest();
            System.assertEquals(TRUE, isException); 
        }
    }
    
}