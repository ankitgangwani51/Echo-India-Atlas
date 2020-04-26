/******************************************************************************
@author:      Echo: Vivek Sethi
@date:        29 November 2017
@description: Test Class for DrUt_GenerateBill_Test
@revision:    MT - Changed the class description and name from GlUt_GenerateBill_Test
                   to DrUt_GenerateBill_Test. Also changed the query from Debt Recovery
                   Process to Debt Recovery Action and added system.assert.
*******************************************************************************/
@isTest
Private class DrUt_GenerateBill_Test {
    
    private static String USER_PROFILE      ='System Administrator';
    private static String USERNAME          ='TestUser';
    private static String USERNAMECOMPLETE  = USERNAME+ '@unitest.com';
    private static string MANAGERID        = Null;
    private static string ZIPCODE          = 'ws2 8de';
    private static string ACCOUNT_NAME     =  'Test';
    private static string CONTRACT_NAME    =  'Test';
    private static string FLAT             =  'Flat';
    
/******************************************************************************
@author:      Echo: Vivek Sethi
@date:        29 November 2017
@description: Test data setup method
@revision:    MT - Removed the void managment action setup.
*******************************************************************************/
    
    @TestSetup
    Static void createTestData(){
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USERNAME , MANAGERID);
        Database.insert(objUser);
        
        //Create Location record
        Location__c  objLocation = GlUt_FactoryData_Test.Createlocation(ZIPCODE);
        objLocation.LocationSubType__c = FLAT;
        Database.insert(objLocation);
        
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
@author:      Echo: Vivek Sethi
@date:        10 November 2017
@description: Test method for generateBill method for positive scenario.
@revision:    MT - Removed the testing of void management action.
*******************************************************************************/  
    
    static testmethod void generateBill_Positive(){   
        
        List<DebtRecoveryAction__c> debtRecoveryActList = [SELECT Id FROM DebtRecoveryAction__c WHERE Processed__c = FALSE];
        User objUser = [SELECT Id FROM user WHERE isActive = TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];       
        List<Id> debtRecoveryActId = new List<Id>();
        
        for(DebtRecoveryAction__c dRRec: debtRecoveryActList)
        {
            debtRecoveryActId.add(dRRec.Id);
        }
        
        System.runAs(objUser){
            Test.startTest();
            //MT - Changed the called class name from GlUt_GenerateBill_Test to DrUt_GenerateBill_Test
            DrUt_GenerateBill.generateBill(debtRecoveryActId);
            Test.stopTest();
             
            for(DebtRecoveryAction__c dRRecActionObj : [SELECT Id, Processed__c FROM DebtRecoveryAction__c WHERE Id IN :debtRecoveryActId]){
                System.assertEquals(TRUE, dRRecActionObj.Processed__c);
            }
            
        }
    }
    
/******************************************************************************
@author:      Echo: Mohit Tayal
@date:        31 Jan 2017
@description: Test method for generateBill method for negative scenario.
*******************************************************************************/
    
    static testmethod void generateBill_Negative(){   
        
        List<DebtRecoveryAction__c> debtRecoveryActList = [SELECT Id FROM DebtRecoveryAction__c WHERE Processed__c = TRUE];
        User objUser = [SELECT Id FROM user WHERE isActive = TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        List<Id> debtRecoveryActId = new List<Id>();
        
        for(DebtRecoveryAction__c dRRec: debtRecoveryActList)
        {
            debtRecoveryActId.add(dRRec.Id);
        }
        
        System.runAs(objUser){
            Test.startTest();
            DrUt_GenerateBill.generateBill(debtRecoveryActId);
            Test.stopTest();
            List<DebtRecoveryAction__c> debtRecActList = [SELECT Id FROM DebtRecoveryAction__c WHERE Processed__c = TRUE]; 
            System.assert(debtRecActList.size() == 0);                 
        }
    }    
}