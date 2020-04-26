/******************************************************************************
@author:      Accenture: Vivek Chauhan
@date:        05 September 2017
@description: Test Class for CuAp_SuppressionWizardCtrlr

Vivek - It would be really nice if this didn't say CuAp_SuppressionWizardCompCtrlr all over the place, please fix it!
*******************************************************************************/

@isTest
//test data creation for CuAp_SuppressionWizardCtrlr class
Public Class CuAp_SuppressionWizardCtrlr_Test{
    
      private static final String USER_PROFILE ='System Administrator';
      private static final String USER_NAME ='TestUser'; 
      private static final String USERNAMECOMPLETE = USER_NAME+ '@unitest.com';
      private static final String ACCOUNT_NAME = 'TestAccount'; 
      private static final String ACCOUNT_NAME2 = 'TestAccount2';
      private static final String CONTRACT_NAME_ONE ='TestContract';
      private static final String CONTRACT_NAME_SECOND ='TestContract2';      
      private static final String SUPPRESSIONREASONVAL ='Court Summons Issued';
      private static final String INACTIVESTATUS ='Inactive(with Credit)';

    /*******************************************************************
    @author:      Accenture: Vivek Chauhan
    @date:        05 September 2017
    @param:       N/A
    @return:      void
    @description: method to create test data used by all test methods
    @revision:    MT - Removed extra test data and used GlUt_FactoryData_Test
                  to create test data for suppression
    ********************************************************************/     
    @TestSetup
    static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE ,USER_NAME ,null);
        Database.insert(objUser);
        
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        Account objAccount2 = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME2);
        Database.insert(objAccount2);
        
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME_ONE,objAccount);
        
        BillingContract__c objContract2 = GlUt_FactoryData_Test.createContract(CONTRACT_NAME_SECOND ,objAccount2);

        List<BillingContract__c >lstContract = new List<BillingContract__c>(); 
        lstContract.add(objContract);
        lstContract.add(objContract2);
        Database.insert(lstContract);
            
        Suppression__c objSuppression = GlUt_FactoryData_Test.createSuppression(objAccount, objContract, SUPPRESSIONREASONVAL);
        Database.insert(objSuppression); 
    }
    
    /*******************************************************************
    @author:      Accenture: Vivek Chauhan
    @date:        05 September 2017
    @param:       N/A
    @return:      void
    @description: Positive test scenario for method SaveSupressions
    @revision:    MT - Changed logic, queries and header
    ********************************************************************/    
    static testmethod void SaveSupressions_Positive(){
        Account objAccount = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
        Account objAccount2 = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME2 LIMIT 1];    
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];

        System.runAs(objUser){
            Test.startTest();
            List<GLAp_FieldProps> lstFieldProps = CuAp_SuppressionWizardCtrlr.retrieveSuppFieldPropDetails();
            List<GLAp_FieldProps> lstFieldPropsAcc = CuAp_SuppressionWizardCtrlr.retrieveSuppAccountFieldPropDetails();
            List<BlAp_CombinedRecord> lstCombinedRecordAcc1 = CuAp_SuppressionWizardCtrlr.retrieveAccountSuppressions(objAccount.id);
            List<BlAp_CombinedRecord> lstCombinedRecordAcc2 = CuAp_SuppressionWizardCtrlr.retrieveAccountSuppressions(objAccount2.Id);
            List<BlAp_CombinedRecord> lstCombinedRecord1 = CuAp_SuppressionWizardCtrlr.retrieveContractSuppressions(objAccount.id);
            List<BlAp_CombinedRecord> lstCombinedRecord2 = CuAp_SuppressionWizardCtrlr.retrieveContractSuppressions(objAccount2.Id);
            
            for(BlAp_CombinedRecord rec : lstCombinedRecordAcc1){
                Suppression__c sup = (Suppression__c) rec.objectMap.get(BlAp_Constants.SUPRESSIONAPINAME);
                sup.SuppressionEndDate__c = Date.today();
            }
            
            for(BlAp_CombinedRecord rec : lstCombinedRecord1){
                Suppression__c sup = (Suppression__c) rec.objectMap.get(BlAp_Constants.SUPRESSIONAPINAME);
                sup.SuppressionEndDate__c = Date.today();
            }
            
            for(BlAp_CombinedRecord rec : lstCombinedRecordAcc2){
                rec.isSelected = TRUE;
                Suppression__c sup = (Suppression__c) rec.objectMap.get(BlAp_Constants.SUPRESSIONAPINAME);
                sup.SuppressBillPrint__c = FALSE;
                sup.SuppressRecoveryNotice__c = TRUE;
                sup.SuppressionReason__c = SUPPRESSIONREASONVAL;
            }
            
            for(BlAp_CombinedRecord rec : lstCombinedRecord2){
                rec.isSelected = TRUE;
                Suppression__c sup = (Suppression__c) rec.objectMap.get(BlAp_Constants.SUPRESSIONAPINAME);
                sup.SuppressBillPrint__c = FALSE;
                sup.SuppressRecoveryNotice__c = TRUE;
                sup.SuppressionReason__c = SUPPRESSIONREASONVAL;
            }
            
            String saveResult1 = CuAp_SuppressionWizardCtrlr.saveSuppressions(JSON.serialize(lstCombinedRecordAcc1),objAccount.id);
            String saveResult2 = CuAp_SuppressionWizardCtrlr.saveSuppressions(JSON.serialize(lstCombinedRecordAcc2),objaccount2.Id);
            String saveResult3 = CuAp_SuppressionWizardCtrlr.saveSuppressions(JSON.serialize(lstCombinedRecord1),objAccount.id);
            String saveResult4 = CuAp_SuppressionWizardCtrlr.saveSuppressions(JSON.serialize(lstCombinedRecord2),objaccount2.Id);
            Test.stopTest();
            
            System.assert(saveResult1=='SUCCESS');
            System.assert(saveResult2=='SUCCESS');
            System.assert(saveResult3=='SUCCESS');
            System.assert(saveResult4=='SUCCESS');
        }
    }
    
    /*******************************************************************
    @author:      Accenture: Vivek Chauhan
    @date:        05 September 2017
    @param:       N/A
    @return:      void
    @description: Negative test scenario for method SaveSupressions
    @revision:    MT - Changed logic, queries and header
    ********************************************************************/
    static testmethod void SaveSupressions_Negative(){
        Account objAccount = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME2 LIMIT 1];
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        System.runAs(objUser){
            Test.startTest();
            List<BlAp_CombinedRecord> lstCombinedRecordAcc = CuAp_SuppressionWizardCtrlr.retrieveAccountSuppressions(objAccount.Id);

            for(BlAp_CombinedRecord rec : lstCombinedRecordAcc){
                rec.isSelected = TRUE;
            }

            String saveResult = CuAp_SuppressionWizardCtrlr.saveSuppressions(JSON.serialize(lstCombinedRecordAcc),objaccount.Id);
            Test.stopTest();
            System.assertNotEquals(saveResult,'SUCCESS');
        }
    }
    
    /*******************************************************************
    @author:      Accenture: Vivek Chauhan
    @date:        05 September 2017
    @param:       N/A
    @return:      void
    @description: Positive test scenario for method RetrieveSuppFieldPropDetails
    @revision:    MT - Changed logic, queries and header
    ********************************************************************/
    static testmethod void RetrieveSuppFieldPropDetails_Positive(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        System.runAs(objUser){
            Test.startTest();
            List<GLAp_FieldProps>lstFieldProps = CuAp_SuppressionWizardCtrlr.retrieveSuppFieldPropDetails();
            Test.stopTest();
            System.assert(lstFieldProps!=null);
            System.assert(lstFieldProps.size()>0);
            System.assert(lstFieldProps[0].fieldName==CuAp_Constants.FIELDAPICONTACTNAME);
            System.assert(lstFieldProps[1].parentObject==GlUt_APIConstantsContracts.CONTRACTAPINAME);
        }
    }

    /*******************************************************************
    @author:      Accenture: Vivek Chauhan
    @date:        05 September 2017
    @param:       N/A
    @return:      void
    @description: Negative test scenario for method RetrieveSuppFieldPropDetails
    @revision:    MT - Changed logic, queries and header
    ********************************************************************/
    static testmethod void RetrieveSuppFieldPropDetails_Negative(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        Boolean isException = false;
        CuAp_SuppressionWizardCtrlr.supFields = null;
        CuAp_SuppressionWizardCtrlr.conFields = null;
        System.runAs(objUser){
            Test.startTest();
            try{
                List<GLAp_FieldProps>lstFieldProps = CuAp_SuppressionWizardCtrlr.retrieveSuppFieldPropDetails();
            }
            catch(Exception exc){
                isException = TRUE;
            }
            Test.stopTest();
            //Assert to check exception has occurred
            System.assertEquals(isException,TRUE);
        }
    }
  
    /*******************************************************************
    @author:      Accenture: Vivek Chauhan
    @date:        05 September 2017
    @param:       N/A
    @return:      void
    @description: Positive test scenario for method RetrieveSuppAccountFieldPropDetails
    @revision:    MT - Changed logic, queries and header
    ********************************************************************/
    static testmethod void RetrieveSuppAccountFieldPropDetails_Positive(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        System.runAs(objUser){
            Test.startTest();
            List<GLAp_FieldProps>lstFieldPropsAcc = CuAp_SuppressionWizardCtrlr.retrieveSuppAccountFieldPropDetails();
            Test.stopTest();
            System.assert(lstFieldPropsAcc!=null);
            System.assert(lstFieldPropsAcc[0].fieldName==CuAp_Constants.FIELDAPISUPPRESSIONREASON);
            System.assert(lstFieldPropsAcc.size()>0);
        }
    }

    /*******************************************************************
    @author:      Accenture: Vivek Chauhan
    @date:        05 September 2017
    @param:       N/A
    @return:      void
    @description: Negative test scenario for method RetrieveSuppAccountFieldPropDetails
    @revision:    MT - Changed logic, queries and header
    ********************************************************************/
    static testmethod void RetrieveSuppAccountFieldPropDetails_Negative(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        Boolean isException = false;
        CuAp_SuppressionWizardCtrlr.supFields = null;
        CuAp_SuppressionWizardCtrlr.conFields = null;
        System.runAs(objUser){
            Test.startTest();
            try{
                List<GLAp_FieldProps>lstFieldProps = CuAp_SuppressionWizardCtrlr.retrieveSuppAccountFieldPropDetails();
            }
            catch(Exception exc){
                isException = TRUE;
            }
            Test.stopTest();
            //Assert to check exception has occurred
            System.assertEquals(isException,TRUE);
        }
    }
   
    /*******************************************************************
    @author:      Accenture: Vivek Chauhan
    @date:        05 September 2017
    @param:       N/A
    @return:      void
    @description: Positive test scenario for method RetrieveAccountSupressions
    @revision:    MT - Changed logic, queries and header
                  Swati - Changed assertion
    ********************************************************************/
    static testmethod void RetrieveAccountSupressions_Positive(){
        Account objAccount = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        System.runAs(objUser){
            Test.startTest();
            List<BlAp_CombinedRecord>lstCombinedRecordAcc = CuAp_SuppressionWizardCtrlr.retrieveAccountSuppressions(objAccount.id);
            Test.stopTest();
            System.assert(lstCombinedRecordAcc!=null);
            System.assert(lstCombinedRecordAcc.size()>0);
            Suppression__c suppresionRec = (Suppression__c)lstCombinedRecordAcc[0].objectMap.get(BlAp_Constants.SUPRESSIONAPINAME);
            System.assertEquals(suppresionRec.SuppressionStartDate__c,system.today());
        }
    }
    
    /*******************************************************************
    @author:      Accenture: Vivek Chauhan
    @date:        05 September 2017
    @param:       N/A
    @return:      void
    @description: Negative test scenario for method RetrieveAccountSupressions
    @revision:    MT - Changed logic, queries and header
    ********************************************************************/
    static testmethod void RetrieveAccountSupressions_Negative(){
        Account objAccount = new Account();
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        Boolean isException = FALSE;
        List<BlAp_CombinedRecord>lstCombinedRecord = new List<BlAp_CombinedRecord>();
        System.runAs(objUser){
            Test.startTest();
            try{
                lstCombinedRecord = CuAp_SuppressionWizardCtrlr.retrieveAccountSuppressions(objAccount.Id);
            }
            catch(Exception exc){
                isException = TRUE;
            }      
            Test.stopTest();
            System.assertEquals(isException, TRUE);
        }
    }
    /*******************************************************************
    @author:      Accenture: Vivek Chauhan
    @date:        05 September 2017
    @param:       N/A
    @return:      void
    @description: Positive test scenario for method RetrieveContractSupressions
    @revision:    MT - Changed logic, queries and header
    ********************************************************************/
    static testmethod void RetrieveContractSupressions_Positive(){
        Account objAccount = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        System.runAs(objUser){
            Test.startTest();
            List<BlAp_CombinedRecord> lstCombinedRecord = CuAp_SuppressionWizardCtrlr.retrieveContractSuppressions(objAccount.Id);                
            Test.stopTest();
            System.assert(lstCombinedRecord!=null);
            System.assert(lstCombinedRecord.size()>0);
        }
    }
    
    /*******************************************************************
    @author:      Accenture: Vivek Chauhan
    @date:        05 September 2017
    @param:       N/A
    @return:      void
    @description: Negative test scenario for method RetrieveContractSupressions
    @revision:    MT - Changed logic, queries and header
    ********************************************************************/
    static testmethod void RetrieveContractSupressions_Negative(){
        Account objAccount = new Account();
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1];
        Boolean isException = FALSE;
        System.runAs(objUser){
            Test.startTest();
            try{
                List<BlAp_CombinedRecord>lstCombinedRecord = CuAp_SuppressionWizardCtrlr.retrieveContractSuppressions(objAccount.Id);
            }
            catch(Exception exc){
                isException = TRUE;
            }           
            Test.stopTest();
            System.assertEquals(isException, TRUE);
        }
    }
}