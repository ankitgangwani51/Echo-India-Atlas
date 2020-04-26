/******************************************************************************
@author:      Echo: Mohit Tayal
@date:        13 December 2017
@description: Test Class for GlUt_CreateLetter_Test
@revision:    MT - Changed the query from Void Management and Debt Recovery Processes
                   Actions and also added the asserts.
*******************************************************************************/
@isTest
public class GlUt_CreateLetter_Test {

    private static String USER_PROFILE      ='System Administrator';
    private static String USERNAME          ='TestUser';
    private static String USERNAMECOMPLETE  = USERNAME+ '@unitest.com';
    private static string MANAGERID        = Null;
    private static string ZIPCODE          = 'ws2 8de';
    private static string ACCOUNT_NAME     =  'Test';
    private static string CONTRACT_NAME    =  'Test';
    private static string FLAT             =  'Flat';
    private static List<String> queryFields;
    static{
        queryFields = new List<string>();
        queryFields.add(GlUt_APIConstantsDebtRecoveryAction.PARAMETERSAPINAME); 
    }
    @TestSetup
    Static void createTestData(){
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USERNAME , MANAGERID);
        Database.insert(objUser);
        
        //Create Location record
        Location__c  objLocation = GlUt_FactoryData_Test.Createlocation(ZIPCODE);
        objLocation.LocationSubType__c = FLAT;
        Database.insert(objLocation);
        
        //Create Void Management Process record
        VoidManagementProcess__c objVoidMgtProcess = GlUt_FactoryData_Test.createVoidManagementProcess(objLocation);
        objVoidMgtProcess.ProcessComplete__c = TRUE;
        Database.insert(objVoidMgtProcess);
        
        //Create Void Management Action record
        VoidManagementAction__c objVoidMgtAct = GlUt_FactoryData_Test.createVoidManagementAction(objVoidMgtProcess);
        objVoidMgtAct.Processed__c = FALSE;
        Database.insert(objVoidMgtAct);
        
        //Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        //Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(CONTRACT_NAME, objAccount);
        Database.insert(objContract);
        
        //Create Debt. Recovery Process record
        DebtRecoveryProcess__c objDebtRecProcess = GlUt_FactoryData_Test.createDebtRecoveryProcess(objContract);
        objDebtRecProcess.ProcessComplete__c = TRUE;
        Database.insert(objDebtRecProcess);
        
        //Create Debt. Recovery Action record
        DebtRecoveryAction__c objDebtRecAct = GlUt_FactoryData_Test.createDebtRecoveryAction(objDebtRecProcess);
        objDebtRecAct.Processed__c = FALSE;
        Database.insert(objDebtRecAct);
    }
    
/******************************************************************************
@author:      Echo: Mohit Tayal
@date:        13 December 2017
@description: Test method for sendLetter method positive scenario.
@revision:    MT - Added the asserts and changed the query to actions from process.
*******************************************************************************/
    
    static testmethod void sendLetter_Positive(){   
        
        List<VoidManagementAction__c> voidMgmtActList = [SELECT Id FROM VoidManagementAction__c WHERE Processed__c = FALSE];
        List<DebtRecoveryAction__c> debtRecoveryActList = [SELECT Id FROM DebtRecoveryAction__c WHERE Processed__c = FALSE];
        User objUser = [SELECT Id FROM user WHERE isActive = TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        
        List<Id> voidMgmtActId = new List<Id>();
        List<Id> debtRecoveryActId = new List<Id>();
        
        for(VoidManagementAction__c vMRec: voidMgmtActList)
        {
            voidMgmtActId.add(vMRec.Id);
        }
        
        for(DebtRecoveryAction__c dRRec: debtRecoveryActList)
        {
            debtRecoveryActId.add(dRRec.Id);
        }
 
        List<String> returnOptionsList = new List<String>();
        
        System.runAs(objUser){
            Test.startTest();
           GlUt_CreateLetter.sendLetter(voidMgmtActId,GlUt_APIConstantsVoidManagementAction.VOIDMANAGEMENTACTIONAPINAME,queryFields);
           GlUt_CreateLetter.sendLetter(debtRecoveryActId,GlUt_APIConstantsDebtRecoveryAction.DEBTRECOVERYACTIONAPINAME,queryFields);
            Test.stopTest();
             
            //MT - added to asserts to validate. 
            for(VoidManagementAction__c vMRecActionObj : [SELECT Id, Processed__c FROM VoidManagementAction__c WHERE Id IN :voidMgmtActId]){
                System.assertEquals(TRUE, vMRecActionObj.Processed__c);
            }
            
            for(DebtRecoveryAction__c dRRecActionObj : [SELECT Id, Processed__c FROM DebtRecoveryAction__c WHERE Id IN :debtRecoveryActId]){
                System.assertEquals(TRUE, dRRecActionObj.Processed__c);
            }
        }
    }
    
/******************************************************************************
@author:      Echo: Mohit Tayal
@date:        31 Jan 2017
@description: Test method for sendLetter method for negative scenario.
*******************************************************************************/
    
    static testmethod void sendLetter_Negative(){   
        
        List<VoidManagementAction__c> voidMgmtActList = [SELECT Id FROM VoidManagementAction__c WHERE Processed__c = TRUE];
        List<DebtRecoveryAction__c> debtRecoveryActList = [SELECT Id FROM DebtRecoveryAction__c WHERE Processed__c = TRUE];
        User objUser = [SELECT Id FROM user WHERE isActive = TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        Boolean isException = False;
        
        List<Id> voidMgmtActId = new List<Id>();
        List<Id> debtRecoveryActId = new List<Id>();
        
        for(VoidManagementAction__c vMRec: voidMgmtActList)
        {
            voidMgmtActId.add(vMRec.Id);
        }
        
        for(DebtRecoveryAction__c dRRec: debtRecoveryActList)
        {
            debtRecoveryActId.add(dRRec.Id);
        }
 
        List<String> returnOptionsList = new List<String>();
        
        System.runAs(objUser){
            Test.startTest();
            try{
                GlUt_CreateLetter.sendLetter(voidMgmtActId,GlUt_APIConstantsVoidManagementAction.VOIDMANAGEMENTACTIONAPINAME,queryFields);
                GlUt_CreateLetter.sendLetter(debtRecoveryActId,GlUt_APIConstantsDebtRecoveryAction.DEBTRECOVERYACTIONAPINAME,queryFields);
            }
            catch(exception e)
            {
                System.debug('Exception = ' +e.getMessage());
                isException = TRUE;
            }
            Test.stopTest();
            
            if(!isException == TRUE){
                for(VoidManagementAction__c vMRecActionObj : [SELECT Id, Processed__c FROM VoidManagementAction__c WHERE Id IN :voidMgmtActId]){
                    System.assertEquals(FALSE, vMRecActionObj.Processed__c);
                }
                
                for(DebtRecoveryAction__c dRRecActionObj : [SELECT Id, Processed__c FROM DebtRecoveryAction__c WHERE Id IN :debtRecoveryActId]){
                    System.assertEquals(FALSE, dRRecActionObj.Processed__c);
                }
            }
        }
    }
}