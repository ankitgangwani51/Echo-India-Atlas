/******************************************************************************
@author			Accenture: Patrick Dixon
@date			14 Dec 2017
@description	Test class for suppression utilities class
*******************************************************************************/    
@isTest
public class GlUt_SuppressionUtilities_Test{

	private static final String USER_PROFILE = 'System Administrator';
	private static final String USER_NAME = 'TestUser'; 
	private static final String ACCOUNT_NAME = 'TestAccount'; 
	private static final String SUPPRESSION_REASON = 'Void';

	/******************************************************************************
	@author			Accenture: Patrick Dixon
	@date			14 Dec 2017
	@description	create the test data
	*******************************************************************************/    
    @TestSetup
    static void createTestData() {

        User user = GlUt_FactoryData_Test.createUser(USER_PROFILE, USER_NAME, null);

        Database.insert(user); 
        system.RunAs(user) {

			// create an account
	        Account account = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
	        Database.insert(account);

			// with contracts
	        List<BillingContract__c> contracts = new List<BillingContract__c>{
	        													GlUt_FactoryData_Test.CreateContract(null, account), 
	        													GlUt_FactoryData_Test.CreateContract(null, account)
	        													};
	        Database.insert(contracts);

			// suppress the account and one of the contracts
	        List<Suppression__c> suppressions = new List<Suppression__c> {
	        															new Suppression__c(
					        													Account__c = account.Id, 
					        													SuppressionStartDate__c = Date.today(), 
					        													SuppressionEndDate__c = Date.today().addDays(10), 
					        													SuppressBillPrint__c = true, 
					        													SuppressionReason__c = SUPPRESSION_REASON
																				), 
																		new Suppression__c(
					        													BillingContract__c = contracts[0].Id, 
					        													SuppressionStartDate__c = Date.today(), 
					        													SuppressionEndDate__c = Date.today().addDays(10), 
					        													SuppressBillPrint__c = true, 
					        													SuppressionReason__c = SUPPRESSION_REASON
																				) 
	        										};
	        Database.insert(suppressions);
        }
    }
   
	/******************************************************************************
	@author			Accenture: Patrick Dixon
	@date			14 Dec 2017
	@description	test void contract suppression creation
	*******************************************************************************/
	static testMethod void testGlUt_SuppressionUtilities_suppressVoidContract() {
		
   		List<BillingContract__c> contracts = [select Id from BillingContract__c];

        // create a suppression record on the contract							
		Test.startTest();
		
        User user = [select Id, Name from User where isActive = true limit 1];
        system.RunAs(user) {
	        Id suppressVoidContract = GlUt_SuppressionUtilities.suppressVoidContract(contracts[1].Id, Date.today());
        }
        
		Test.stopTest();
	    
	    // verify a suppression record was created for the contract
		Boolean hasSuppression = false;
        for (Suppression__c suppression : [select Id  
        									from Suppression__c 
        									where BillingContract__c in (select Id from BillingContract__c where Id = :contracts[1].Id)]) {
        	hasSuppression = true;
		}
        System.assert(hasSuppression, 'Void contract suppression not created');
	}
    
	/******************************************************************************
	@author			Accenture: Patrick Dixon
	@date			14 Dec 2017
	@description	test for contract suppression (positive scenario)
	*******************************************************************************/
	static testMethod void testGlUt_SuppressionUtilities_isContractSuppressedTrue() {

        Account account = [select Id from Account limit 1];
        List<BillingContract__c> contracts = [select Id, Name from BillingContract__c];

        // ensure the account suppression is ended
        List<Suppression__c> suppressions = new List<Suppression__c>();
        for (Suppression__c suppression : [select Id, 
        										SuppressionEndDate__c 
        									from Suppression__c 
        									where Account__c = :account.Id]) {

	        	suppression.SuppressionEndDate__c = Date.today();
	        	suppressions.add(suppression);
	        }
		Database.update(suppressions);
        			
        // check contract is suppressed							
		Test.startTest();
		
		Boolean isContractSuppressed;
        User user = [select Id, Name from User where isActive = true limit 1];
        system.RunAs(user) {
	        isContractSuppressed = GlUt_SuppressionUtilities.isContractSuppressed(contracts[0].Id);
		}
	        
        Test.stopTest();
        System.assert(isContractSuppressed, 'Contract suppression true test fail');
	}
	
	/******************************************************************************
	@author			Accenture: Patrick Dixon
	@date			14 Dec 2017
	@description	test for contract suppression (positive scenario)
	*******************************************************************************/
	static testMethod void testGlUt_SuppressionUtilities_isContractSuppressedTrue2() {

        List<BillingContract__c> contracts = [select Id, Name from BillingContract__c];

        // ensure all contract suppressions are ended
        List<Suppression__c> suppressions = new List<Suppression__c>();
        for (Suppression__c suppression : [select Id, 
        										SuppressionEndDate__c 
        									from Suppression__c 
        									where BillingContract__c = :contracts]) {

	        	suppression.SuppressionEndDate__c = Date.today();
	        	suppressions.add(suppression);
	        }
		Database.update(suppressions);
        										
        // check account forces contract suppression							
        Test.startTest();

		Boolean isContractSuppressed;
        User user = [select Id, Name from User where isActive = true limit 1];
        system.RunAs(user) {
			isContractSuppressed = GlUt_SuppressionUtilities.isContractSuppressed(contracts[0].Id);
		}
		
        Test.stopTest();
        System.assert(isContractSuppressed, 'Contract suppression true (account) test fail');
	}
	/******************************************************************************
	@author			Accenture: Patrick Dixon
	@date			14 Dec 2017
	@description	test for contract suppression (negative scenario)
	*******************************************************************************/
	static testMethod void testGlUt_SuppressionUtilities_isContractSuppressedFalse() {

        Account account = [select Id from Account limit 1];
        List<BillingContract__c> contracts = [select Id, Name from BillingContract__c];
        
        // ensure all account and contract suppressions are ended
        List<Suppression__c> suppressions = new List<Suppression__c>();
        for (Suppression__c suppression : [select Id, 
        										SuppressionEndDate__c 
        									from Suppression__c 
        									where Account__c = :account.Id 
        										or BillingContract__c in :contracts]) {

	        	suppression.SuppressionEndDate__c = Date.today();
	        	suppressions.add(suppression);
	        }
		Database.update(suppressions);

        // check contract not suppressed							
		Test.startTest();
        			
		Boolean isContractSuppressed;
        User user = [select Id, Name from User where isActive = true limit 1];
        system.RunAs(user) {
			isContractSuppressed = GlUt_SuppressionUtilities.isContractSuppressed(contracts[0].Id);
		}
	        
        Test.stopTest();
        System.assert(!isContractSuppressed, 'Contract suppression false test fail');
	}

	/******************************************************************************
	@author			Accenture: Patrick Dixon
	@date			14 Dec 2017
	@description	test for account suppression ('YES' scenario)
	*******************************************************************************/
    static testMethod void testGlUt_SuppressionUtilities_getAccountSuppressionStatusYES() {
    	
        Account account = [select Id from Account limit 1];

		// check account fully suppressed
		Test.startTest();
		
		String accountSuppressionStatus;
        User user = [select Id, Name from User where isActive = true limit 1];
        system.RunAs(user) {
			accountSuppressionStatus = GlUt_SuppressionUtilities.getAccountSuppressionStatus(account.Id);
        }
        
    	Test.stoptest();
        System.assert(accountSuppressionStatus == GlUt_Constants.SUPPRESSED_YES, 'Account suppression YES test fail');
    }

	/******************************************************************************
	@author			Accenture: Patrick Dixon
	@date			14 Dec 2017
	@description	test for account suppression ('NO' scenario)
	*******************************************************************************/    
    static testMethod void testGlUt_SuppressionUtilities_getAccountSuppressionStatusNO() {
    	
        Account account = [select Id from Account limit 1];
        List<BillingContract__c> contracts = [select Id, Name from BillingContract__c];

        // ensure all account and contract suppressions are ended
        List<Suppression__c> suppressions = new List<Suppression__c>();
        for (Suppression__c suppression : [select Id, 
        										SuppressionEndDate__c 
        									from Suppression__c 
        									where Account__c = :account.Id 
        										or BillingContract__c in :contracts]) {

	        	suppression.SuppressionEndDate__c = Date.today();
	        	suppressions.add(suppression);
	        }
		Database.update(suppressions);
        										
		// check account not suppressed
		Test.startTest();
	        
		String accountSuppressionStatus;
        User user = [select Id, Name from User where isActive = true limit 1];
        system.RunAs(user) {
			accountSuppressionStatus = GlUt_SuppressionUtilities.getAccountSuppressionStatus(account.Id);
        }
        
    	Test.stoptest();
        System.assert(accountSuppressionStatus == GlUt_Constants.SUPPRESSED_NO, 'Account suppression NO test fail');
    }

	/******************************************************************************
	@author			Accenture: Patrick Dixon
	@date			14 Dec 2017
	@description	test for account suppression ('PARTIAL' scenario)
	*******************************************************************************/
    static testMethod void testGlUt_SuppressionUtilities_getAccountSuppressionStatusPARTIAL() {
    	
        Account account = [select Id from Account limit 1];

        // ensure the account suppression is ended
        List<Suppression__c> suppressions = new List<Suppression__c>();
        for (Suppression__c suppression : [select Id, 
        										SuppressionEndDate__c 
        									from Suppression__c 
        									where Account__c = :account.Id]) {

	        	suppression.SuppressionEndDate__c = Date.today();
	        	suppressions.add(suppression);
	        }
	        Database.update(suppressions);
        										
		// check account partially suppressed
		Test.startTest();
	        
		String accountSuppressionStatus;
        User user = [select Id, Name from User where isActive = true limit 1];
        system.RunAs(user) {
			accountSuppressionStatus = GlUt_SuppressionUtilities.getAccountSuppressionStatus(account.Id);
        }
        
    	Test.stoptest();
        System.assert(accountSuppressionStatus == GlUt_Constants.SUPPRESSED_PARTIAL, 'Account suppression PARTIAL test fail');
    }
}