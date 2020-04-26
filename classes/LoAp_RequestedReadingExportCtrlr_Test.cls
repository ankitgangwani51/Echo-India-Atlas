/******************************************************************************
@author:      Echo: Swati
@date:        07-06-2018
@description: Test Class for LoAp_RequestedReadingExportCtrlr
*******************************************************************************/

@isTest
public class LoAp_RequestedReadingExportCtrlr_Test {

    //Variable declaration start    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='FN123LN123'; 
    private static final String USER_FNAME= 'FN123';
    private static final String USER_LNAME= 'LN123';
    private static final String BATCH_CLASS = 'LoBt_ExportRequestedReadings';  
    private static final String EXPORT_OPERATION = 'Export';
    
    //Variable declaration end

/******************************************************************************
@author:    Echo: Swati
@date:      07-06-2018
@description: Test data setup method
*******************************************************************************/
    @TestSetup
    Static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        //Create Batch Process record
        BatchProcess__c objBatchProcess = GlUt_FactoryData_Test.createBatchProcess(BATCH_CLASS);
        objBatchProcess.Operation__c = EXPORT_OPERATION;
        
        Database.insert(objBatchProcess);
        
        
            
    }

    /******************************************************************************
    @author:    Echo: Swati
    @date:      07-06-2018 
    @description: Test method for createBRQ() method
    *******************************************************************************/    
    static testmethod void createBRQ_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        
        //Run test class in user context
        System.runAs(objUser){             
            Test.startTest();
            LoAp_RequestedReadingExportCtrlr.createBRQ();
            Test.stopTest();
            List<BatchRequestQueue__c> objBRQ = [SELECT Id FROM BatchRequestQueue__c];
            System.assert(objBRQ.size() > 0);
        }
    } 
    
    /******************************************************************************
    @author:    Echo: Swati
    @date:      07-06-2018 
    @description: Test method for createBRQ() method
    *******************************************************************************/    
    static testmethod void createBRQ_Negative(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        BatchProcess__c objBatchProcess = [Select id,Operation__c from BatchProcess__c limit 1];
        objBatchProcess.Operation__c = null;
        update objBatchProcess;
        //Run test class in user context
        System.runAs(objUser){             
            Test.startTest();
            LoAp_RequestedReadingExportCtrlr.createBRQ();
            Test.stopTest();
            List<BatchRequestQueue__c> objBRQ = [SELECT Id FROM BatchRequestQueue__c];
            System.assertEquals(objBRQ.size() , 0);
        }
    } 
}