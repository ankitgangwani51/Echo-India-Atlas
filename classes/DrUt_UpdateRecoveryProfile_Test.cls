/******************************************************************************
@author:      Echo: Mohit Tayal
@date:        18 December 2017
@description: Test Class for DrUt_UpdateRecoveryProfile_Test
*******************************************************************************/
@isTest
public class DrUt_UpdateRecoveryProfile_Test {
   
    private static String USER_PROFILE      = 'System Administrator';
    private static String USERNAME          = 'TestUser';
    private static String USERNAMECOMPLETE  = USERNAME+ '@unitest.com';
    private static string MANAGERID         = Null;
    private static string ACCOUNT_NAME      = 'Test';
    private static string CONTRACT_NAME     = 'Test';
    private static string PARAMETER1        = 'Profile 1';
    private static string PARAMETER2        = 'Profile 2';
    private static string PARAMETER3        = 'Profile 3';
    
    @TestSetup
    Static void createTestData(){
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USERNAME , MANAGERID);
        Database.insert(objUser);
        
        //Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        //Create First Contract Record
        BillingContract__c objContract1 = GlUt_FactoryData_Test.CreateContract(CONTRACT_NAME, objAccount);
        Database.insert(objContract1);
        
        //Create Debt. Recovery Process record
        DebtRecoveryProcess__c objDebtRecProcess1 = GlUt_FactoryData_Test.createDebtRecoveryProcess(objContract1);
        objDebtRecProcess1.ProcessComplete__c = TRUE;
        Database.insert(objDebtRecProcess1);
        
        //Create First Debt. Recovery Action record
        DebtRecoveryAction__c objDebtRecAct1 = GlUt_FactoryData_Test.createDebtRecoveryAction(objDebtRecProcess1);
        objDebtRecAct1.Parameters__c = PARAMETER2;
        Database.insert(objDebtRecAct1);
        
        //Create Debt. Recovery Action record
        DebtRecoveryAction__c objDebtRecAct2 = GlUt_FactoryData_Test.createDebtRecoveryAction(objDebtRecProcess1);
        objDebtRecAct2.Parameters__c = PARAMETER3;
        Database.insert(objDebtRecAct2);
        
        //Create Debt. Recovery Action record
        DebtRecoveryAction__c objDebtRecAct3 = GlUt_FactoryData_Test.createDebtRecoveryAction(objDebtRecProcess1);
        objDebtRecAct3.Parameters__c = PARAMETER1;
        Database.insert(objDebtRecAct3);   
        
        //End of First Contract Record
        
        //Create Second Contract Record
        BillingContract__c objContract2 = GlUt_FactoryData_Test.CreateContract(CONTRACT_NAME, objAccount);
        Database.insert(objContract2);
        
        //Create Debt. Recovery Process record
        DebtRecoveryProcess__c objDebtRecProcess2 = GlUt_FactoryData_Test.createDebtRecoveryProcess(objContract2);
        objDebtRecProcess2.ProcessComplete__c = TRUE;
        Database.insert(objDebtRecProcess2);
        
        //Create First Debt. Recovery Action record
        DebtRecoveryAction__c objDebtRecAct4 = GlUt_FactoryData_Test.createDebtRecoveryAction(objDebtRecProcess2);
        objDebtRecAct4.Parameters__c = PARAMETER2;
        Database.insert(objDebtRecAct4);     
        //End of Second Contract Record       
    }

    /******************************************************************************
    @author:      Echo: Mohit Tayal
    @date:        13 December 2017
    @description: Test method for updateRecoveryProfile methods.
    *******************************************************************************/  
    static testmethod void updateRecoveryProfile_Positive(){   
        
        Map<Id,DebtRecoveryProcess__c> DebtRecoveryProcMap = new Map<Id,DebtRecoveryProcess__c>([SELECT ID FROM DebtRecoveryProcess__c WHERE ProcessComplete__c = TRUE]);
        List<DebtRecoveryAction__c> DebtRecoveryActionList = [SELECT ID,DebtRecoveryProcess__r.BillingContract__c,Parameters__c FROM DebtRecoveryAction__c WHERE DebtRecoveryProcess__c IN :DebtRecoveryProcMap.keySet()];
        User objUser = [Select id from user where isActive = true AND Username =: USERNAMECOMPLETE limit 1];
        
        List<Id> DebtRecoveryActionId = new List<Id>();        
        Map<Id,Id> actionContractIdsMap = new Map<Id,Id>();
        Set<String> DebtRecoveryActionParams = new Set<String>();
        
        // creating map of debt recovery action id and assosciated contract id
        for(DebtRecoveryAction__c dRecActRec : DebtRecoveryActionList){
            if(dRecActRec.DebtRecoveryProcess__r.BillingContract__c != null){
                actionContractIdsMap.put(dRecActRec.Id,dRecActRec.DebtRecoveryProcess__r.BillingContract__c);                
            }
            DebtRecoveryActionId.add(dRecActRec.Id);
            DebtRecoveryActionParams.add(dRecActRec.Parameters__c);
        }
                
        System.runAs(objUser){
            Test.starttest();
            DrUt_UpdateRecoveryProfile.updateRecoveryProfile(DebtRecoveryActionId);
            Test.stoptest();
            // creating map of the contract ids and the contract object
            List<BillingContract__c> contractList = [SELECT Id, DebtRecoveryProfile__c FROM BillingContract__c WHERE Id IN :actionContractIdsMap.values()];
            for(BillingContract__c con : contractList){
                System.assert(DebtRecoveryActionParams.contains(con.DebtRecoveryProfile__c));
            }
        }
    }
    
    /******************************************************************************
    @author:      Echo: Mohit Tayal
    @date:        13 December 2017
    @description: Test method for updateRecoveryProfile methods.
    *******************************************************************************/ 
    static testmethod void updateRecoveryProfile_Negative(){   
    
        List<DebtRecoveryAction__c> DebtRecoveryActionList = [SELECT ID,DebtRecoveryProcess__r.BillingContract__c,Parameters__c FROM DebtRecoveryAction__c];
        User objUser = [Select id from user where isActive = true AND Username =: USERNAMECOMPLETE limit 1];
        
        List<Id> DebtRecoveryActionId = new List<Id>();        
        Map<Id,Id> actionContractIdsMap = new Map<Id,Id>();
        Set<String> DebtRecoveryActionParams = new Set<String>();
        
        // creating map of debt recovery action id and assosciated contract id
        for(DebtRecoveryAction__c dRecActRec : DebtRecoveryActionList){
            if(dRecActRec.DebtRecoveryProcess__r.BillingContract__c != null && dRecActRec.Parameters__c == PARAMETER3){
                actionContractIdsMap.put(dRecActRec.Id,dRecActRec.DebtRecoveryProcess__r.BillingContract__c); 
                DebtRecoveryActionId.add(dRecActRec.Id);
                DebtRecoveryActionParams.add(dRecActRec.Parameters__c);
            }
        }
                
        System.runAs(objUser){
            Test.starttest();
            DrUt_UpdateRecoveryProfile.updateRecoveryProfile(DebtRecoveryActionId);
            Test.stoptest();
            // creating map of the contract ids and the contract object
            List<BillingContract__c> contractList = [SELECT Id, DebtRecoveryProfile__c FROM BillingContract__c WHERE Id IN :actionContractIdsMap.values()];
            for(BillingContract__c con : contractList){
                System.assertEquals(False, DebtRecoveryActionParams.contains(con.DebtRecoveryProfile__c));
            }
        }
    }
}