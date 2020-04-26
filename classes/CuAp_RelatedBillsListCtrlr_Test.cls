/******************************************************************************
@author    		Echo: Patrick Dixon
@date      		05 Jul 2018
@description 	Test Class for CuAp_RelatedBillsListCtrlr
@Revisions	  	AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest 
public class CuAp_RelatedBillsListCtrlr_Test {
   
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE = USER_NAME + '@unitest.com';
    private static final String USER_FIRST_NAME = 'FirstName';
    private static final String USER_LAST_NAME = 'LastName';
    private static final String ACCOUNT_NAME = 'Test Account';
    
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    private static final String FIELDSET_NAME = NAMESPACEPREFIX + 'RelatedListDetails';		// fieldset must exist
   
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		05 Jul 2018
	@description 	Test data setup
	*******************************************************************************/
    @TestSetup
    static void createTestData() {
    	
        // create a user
        User testUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USER_NAME, null);
        testUser.FirstName = USER_FIRST_NAME;
        testUser.LastName = USER_LAST_NAME;
        Database.insert(testUser);
        
        // create an account and some contracts
		Account account = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
		insert account;
		
  		List<BillingContract__c> contracts = new List<BillingContract__c>();
  		for (Integer i = 0 ; i < 10 ; i++) {
  			contracts.add(GlUt_FactoryData_Test.createContract(account));
  		}
  		insert contracts;
  		
        // create some bills on one of the contracts
  		List<Bill__c> bills = new List<Bill__c>();
  		Boolean hasBillPDF = false;
  		for (Integer i = 0 ; i < 10 ; i++) {
      		bills.add(new Bill__c( //Name = 'Bill-' + String.valueOf(i), 
	  								BillingContract__c = contracts[0].Id, 
	  								BilledAmount__c = 567 + i, 
	  								HerokuPostgresId__c = 'HerokuId-' + String.valueOf(i), 
	  								BillDate__c = date.newInstance(2017, 09, 17), 
	  								BillPDF__c = !hasBillPDF
	  								));
		}
		insert bills;
    }
    
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		05 Jul 2018
	@description 	Field properties test 
	*******************************************************************************/
    static testmethod void retrieveFieldProperties_Positive() {            
        
        User testUser = [select Id, 
        						Name 
        				from User 
        				where isActive = true 
        					and Username = :USERNAMECOMPLETE LIMIT 1];
      
        System.runAs(testUser) {
            Test.startTest(); 
            
        	List<GLAp_FieldProps> fields = CuAp_RelatedBillsListCtrlr.retrieveFieldProperties(FIELDSET_NAME); 
            system.assert(!fields.isEmpty());
            
            Test.stopTest();          
        }         
    }  
   
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		05 Jul 2018
	@description 	Records test (records returned)
	*******************************************************************************/
    static testmethod void retrieveRecords_Positive(){            
        
        User testUser = [select Id, 
        						Name 
        				from User 
        				where isActive = true 
        					and Username = :USERNAMECOMPLETE LIMIT 1];
      
      	// select a contract with bills
		BillingContract__c record;		
		for (BillingContract__c contract : [select Id 
									from BillingContract__c 
									where AccountName__r.Name = :ACCOUNT_NAME
										and Id in (select BillingContract__c from Bill__c)]) {
			
			record = contract;
			break;
		}
      
        System.runAs(testUser) {
            Test.startTest();  
        	List<BlAp_CombinedRecord> records = CuAp_RelatedBillsListCtrlr.retrieveRecords(record.Id, FIELDSET_NAME); 
            Test.stopTest();                     
            system.assert(!records.isEmpty());
        }  
    } 
  
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		05 Jul 2018
	@description 	Records test (no records returned)
	*******************************************************************************/
    static testmethod void retrieveRecords_Negative(){            
        
        User testUser = [select Id, 
        						Name 
        				from User 
        				where isActive = true 
        					and Username = :USERNAMECOMPLETE LIMIT 1];
      
      	// select a contract without bills
		BillingContract__c record;		
		for (BillingContract__c contract : [select Id 
									from BillingContract__c 
									where AccountName__r.Name = :ACCOUNT_NAME
										and Id not in (select BillingContract__c from Bill__c)]) {
			
			record = contract;
			break;
		}
		
        System.runAs(testUser) {
            Test.startTest(); 
            
        	List<BlAp_CombinedRecord> records = CuAp_RelatedBillsListCtrlr.retrieveRecords(record.Id, ''); 
            system.assert(records == null || records.isEmpty());
            
            Test.stopTest();                       
        }  
    } 
    
    
}