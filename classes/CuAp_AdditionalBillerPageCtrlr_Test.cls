/******************************************************************************
@author:      Echo: Vivek Sethi
@date:        10 November 2017
@description: Test Class for CuAp_AdditionalBillerPageCtrlr
@Revision(s): Echo: Gopal Gupta
*******************************************************************************/
@isTest
Private class CuAp_AdditionalBillerPageCtrlr_Test {
    
    private static String USER_PROFILE_NAME   = 'System Administrator';
    private static String USERNAME          = 'TestUser';
    private static String USERNAMECOMPLETE  = USERNAME+ '@unitest.com';
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi
    @date:        10 November 2017
    @description: Test data setup method
    *******************************************************************************/    
    @TestSetup
    static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE_NAME, USERNAME, null);
        Database.insert(objUser);
        
    }
    
    /******************************************************************************
    @author:      Echo: Gopal Gupta
    @date:        12 December 2017
    @description: Test method for addBiller methods
    *******************************************************************************/     
    static testmethod void addBiller_Positive(){
            
        //Query user record created in test setup data method
        User objUser = [SELECT Id from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            List<CuAp_AdditionalBillerPageCtrlr.BillerInfo> biList = new List<CuAp_AdditionalBillerPageCtrlr.BillerInfo>();
            CuAp_AdditionalBillerPageCtrlr.BillerInfo bi1 = CuAp_AdditionalBillerPageCtrlr.addBiller();
            biList.add(bi1);
            CuAp_AdditionalBillerPageCtrlr.BillerInfo bi2 = CuAp_AdditionalBillerPageCtrlr.addBiller();
            biList.add(bi2);
            Test.stopTest();
            System.assert(bi1 != null);
            System.assert(bi2 != null);
            System.assert(bi1.occTypeOptions.size() > 0);
            System.assert(bi2.occTypeOptions.size() > 0);
            System.assertEquals(biList.size(), 2);
            
        }
    }
    
}