/******************************************************************************
@author:      Echo: Ankit Gangwani 
@date:        03 July 2018
@description: Test Class for GlUt_BusinessDays
*******************************************************************************/
@isTest 
public class GlUt_BusinessDays_Test {
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String HOLIDAY_NAME = 'Test';
    
	/******************************************************************************
	@author:      Echo: Ankit Gangwani
	@date:        03 July 2018
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
        
        // Create Holiday Record
        Holiday objHoliday = new Holiday();
        objHoliday.ActivityDate = System.today().addDays(1);
        objHoliday.Name = HOLIDAY_NAME;
        Database.insert(objHoliday);
    }
    
    /******************************************************************************
	@author:      Echo: Ankit Gangwani
	@date:        03 July 2018
	@description: Test Method to check Business Days
	*******************************************************************************/
    static testmethod void addBusinessDays_Positive()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Date returnBusinessDate;
        System.runAs(objUser){
            Test.startTest();       
        	GlUt_BusinessDays objBuisness = new GlUt_BusinessDays();
            returnBusinessDate = objBuisness.addBusinessDays(System.today(),1);            
            Test.stopTest();
            System.assert(returnBusinessDate != null);
            
        }
    }
    
    /******************************************************************************
	@author:      Echo: Ankit Gangwani
	@date:        05 Sept 2018
	@description: Test Method to check Business Days
	*******************************************************************************/
    static testmethod void addBusinessDays_Negative()
    {            
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Date returnBusinessDate;
        System.runAs(objUser){
            Test.startTest();       
        	GlUt_BusinessDays objBuisness = new GlUt_BusinessDays();
            returnBusinessDate = objBuisness.addBusinessDays(null,null);            
            Test.stopTest();
            System.assert(returnBusinessDate == null);
            
        }
    }
}