/******************************************************************************
@author         Echo: Tarun Gupta
@date           11 Mar 2019
@description    Test class for CuAp_AddDiscountPageCtrlr
*******************************************************************************/
@isTest
public class CuAp_AddDiscountPageCtrlr_Test {
    
    private static final String USER_PROFILE 		= 'System Administrator';
    private static final String USER_NAME			= 'TestUser';
    private static final String USERNAMECOMPLETE  	= USER_NAME + '@unitest.com';
    private static final String USER_FNAME 			= 'First_User_Name';
    private static final String USER_LNAME 			= 'Last_User_Name';
    private static final String ACCOUNT_NAME 		= 'Test Account';    
    private static final String CONTRACT_NAME 		= 'Con00021';
    private static final String LOCATION_NAME 		= 'A99 9AA';   
    private static final String LOCATION_SUB_TYPE 	= 'Detached';
    private static final String STREET 				= 'teststreet';
    private static final String TESTSERVICE_TYPE1 	= 'TestServiceType1'; 
    private static final String SP_USAGE_TYPE 		= 'SupplyPointUsageType';
    
    private static final String DEVICE_SIZE 		= '10mm';
    private static final String MANUFACTURER 		= 'Kent';
    private static final String UNIT_OF_MEASURE 	= 'Metric';
    private static final String SERIALNO = '0801';
    private static final String WHOLESALER 			= 'TestWholesaler';
    private static final String AVAILABLESERVICES 	= 'TestAvailableService';
    private static final String SERVICE_ITEM_FAMILY = 'Service_Item_Family';
    private static final String BUNDLE_ITEM = 'Test_BundleItem';
    private static final String BUNDLE_NAME = 'Bundle_Test';
    private static final String AVAILABLE_BUNDLE = 'AvailableBundle';
    private static final String AVAIL_SERVICE_ITEM = 'AvailableServiceItem_Test';
    
    /*******************************************************************
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    @TestSetup
    Static void createTestData(){
        
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
    }
    
    /******************************************************************************
	@author:      Echo: Tarun Gupta
	@date:        11 Mar 2019
	@description: Positive method of retrieveDiscountFields 
	*******************************************************************************/
    static testmethod void retrieveDiscountFields_Positive(){            
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];        
        Boolean isException = false;
        
        System.runAs(objUser){
            Test.startTest();
            try{
                List<List<GlAp_FieldProps>> listFields = CuAp_AddDiscountPageCtrlr.retrieveDiscountFields(System.Label.CuAp_FixedDiscount,false,false);
                List<List<GlAp_FieldProps>> listFields2 = CuAp_AddDiscountPageCtrlr.retrieveDiscountFields(System.Label.CuAp_PercentageDiscount,false,false);
                List<List<GlAp_FieldProps>> listFields3 = CuAp_AddDiscountPageCtrlr.retrieveDiscountFields(System.Label.CuAp_BillToBillDiscount,false,false);
            }
            catch(exception e){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(isException, false);
        }          
    }
}