/******************************************************************************
@author    		Accenture: Patrick Dixon
@date      		29 Nov 2017
@description 	Class for Account utilities
@Revisions		09 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
@revision		Echo: Sudhir Kumar - AT-3982: Updating return type from String to Boolean for getSocialTariffStatus & getOpenCaseStatus methods
					-Reverted for now
				AT-4249, Tarun Gupta, builds a map of contract to bank details                     
*******************************************************************************/
public with sharing class GlUt_AccountUtilities {
    
    private static final String CLASS_NAME = 'GlUt_AccountUtilities';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static final String YES = 'YES';
    private static final String CLOSED = 'Closed';
    public static final String HH_ACCOUNT = 'Household Account';
    public static final String NHH_ACCOUNT = 'Non-Household Account';
    
    private static final Date CURRENT_DATE = System.today();       
    
    /******************************************************************************
	@author    		Accenture: Patrick Dixon
	@date      		29 Nov 2017
	@param			Id - account Id
	@param			Date - move in date
	@return			Boolean - true if the account has an active contract
	@description	Checks the account to see if it has active contracts 
	that start on or before the move in date, or today if null
	*******************************************************************************/
    public static Boolean hasActiveContract(Id accountId, Date moveInDate) {
        
        moveInDate = moveInDate != null ? moveInDate : Date.today();
        
        // check for active contracts for the account
        for (BillingContract__c contract : [select Id 
                                     from BillingContract__c
                                     where AccountName__c = :accountId 
                                     and ContractStartDate__c <= :moveInDate
                                     and (ContractEndDate__c = null 
                                          or ContractEndDate__c > :Date.today())]) {
                                              
                                              return true;
                                          }
        return false;
    }    
    
    /******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		30 Jan 2018
	@param			Set<Id> - set of contract Ids
	@return			Map<Id, Boolean> - map of HH Account status keyed on the contract Ids
	@description	builds a map of contract account types
	*******************************************************************************/
    public static Map<Id, Boolean> getContractAccountTypes(Set<Id> contractIds) {
        
        Map<Id, Boolean> accountTypeMap = new Map<Id, Boolean>();
        
        // get the Household record type Id
        Id HHAccountRecordTypeId;
        if (GlUt_RecordTypeUtilities.getRecordTypeMap().keySet().contains(GlUt_Constants.HH_ACCOUNT_RECORDTYPE_NAME)) {
            HHAccountRecordTypeId = GlUt_RecordTypeUtilities.getRecordTypeMap().get(GlUt_Constants.HH_ACCOUNT_RECORDTYPE_NAME).Id;
        }
        
        // for each of the contracts check if the account record type is matched
        for (BillingContract__c contract : [select Id, 
                                     AccountName__r.RecordTypeId 
                                     from BillingContract__c
                                     where Id in :contractIds]) {
                                         
                                         accountTypeMap.put(contract.Id, contract.AccountName__r.RecordTypeId == HHAccountRecordTypeId);
                                     }
        return accountTypeMap;
    }    
    
    /******************************************************************************
	@author    		Accenture: Patrick Dixon
	@date      		28 Nov 2017
	@param			Id - account Id
	@return			Boolean - true for a HH Account
	@description	Checks the account to see if it's a HH Account
	*******************************************************************************/
    public static Boolean isHHAccount(Id accountId) {
        
        // get the Household record type Id
        Id HHAccountRecordTypeId;
        if (GlUt_RecordTypeUtilities.getRecordTypeMap().keySet().contains(GlUt_Constants.HH_ACCOUNT_RECORDTYPE_NAME)) {
            HHAccountRecordTypeId = GlUt_RecordTypeUtilities.getRecordTypeMap().get(GlUt_Constants.HH_ACCOUNT_RECORDTYPE_NAME).Id;
        }
        
        // check if the account record type is a match
        for (Account account : [select Id 
                                from Account
                                where Id = :accountId
                                and RecordTypeId = :HHAccountRecordTypeId]) {
                                    
                                    return true;
                                }
        return false;
    }    
    
    /******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		12 Jan 2018
	@param			Id - account Id
	@return			Boolean - true for a NHH Account
	@description	Checks the account to see if it's a NHH Account
	*******************************************************************************/
    public static Boolean isNHHAccount(Id accountId) {
        
        // get the Household record type Id
        Id NHHAccountRecordTypeId;
        if (GlUt_RecordTypeUtilities.getRecordTypeMap().keySet().contains(GlUt_Constants.NHH_ACCOUNT_RECORDTYPE_NAME)) {
            NHHAccountRecordTypeId = GlUt_RecordTypeUtilities.getRecordTypeMap().get(GlUt_Constants.NHH_ACCOUNT_RECORDTYPE_NAME).Id;
        }
        
        // check if the account record type is a match
        for (Account account : [select Id 
                                from Account
                                where Id = :accountId
                                and RecordTypeId = :NHHAccountRecordTypeId]) {
                                    
                                    return true;
                                }
        return false;
    }    
    
    /******************************************************************************
	@author    		Accenture: Patrick Dixon
	@date      		14 Dec 2017
	@param			Id - account Id
	@return			Boolean - true if the account has no active location occupants
	@description	Checks the account to see if it has active location occupants
	*******************************************************************************/
    public static Boolean isStaleAccount(Id accountId) {
        
        // check for active location occupants for the account
        for (LocationOccupant__c occupant : [select Id 
                                             from LocationOccupant__c
                                             where Account__c = :accountId 
                                             and StartDate__c <= :Date.today()
                                             and (EndDate__c != null 
                                                  or EndDate__c > :Date.today())]) {
                                                      
                                                      return false;		// has an active location occupant
                                                  }
        return true;
    }    
    
    /**********************************************************************************************
	@author         Echo: Neha R
	@date           23-Feb-2018
	@param          Id - Account ID
	@param          List<String> - List of case object fields
	@return         String 
	@description    Method is used to identify open case on an Account 
	@revision		Echo: Sudhir Kumar - AT-3982: Updating return type from String to Boolean
	**********************************************************************************************/     
    public static String getOpenCaseStatus(Id accountId, List<String> caseFields){
              
        List<Case> caseList = new List<Case>();
        caseList = (List<Case>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsCase.CASEAPINAME, 
																	caseFields, 
																	accountId, 
																	'AccountId', 
																	'Status != ' + GlUt_FieldSecurity.QuotedString(CLOSED));
        if (caseList.size() > 0) return YES;
        //if (caseList.size() > 0) return true ;
        return null ;        
    }
    
    /**********************************************************************************************
	@author         Echo: Neha R
	@date           23-Feb-2018
	@param          Id - Account Id
	@param          List<String> serviceItem Fields
	@param          List<String> serviceItemType Fields
	@param          List<String> bundleItem Fields
	@return         List<Account>() 
	@description    Method is used to retrieve account by passing account id, limit and status.
	@revision		Echo: Sudhir Kumar - AT-3982: Updating return type from String to Boolean
	**********************************************************************************************/     
    public static String getSocialTariffStatus(String sObjectName, Id recordId, List<String> serviceItemFields, List<String> serviceItemTypeFields, List<String> bundleItemFields){
              
        String sOQLQuery;
        Set<Id> serviceItemFamilyList = new Set<Id>();
        Set<Id> serviceItemTypeIDList = new Set<Id>();  
        Set<Id> bundleList = new Set<Id>();
        
        List<ServiceItem__c> serviceItemList = new List<ServiceItem__c>();
        List<ServiceItemType__c> serviceItemTypeList = new List<ServiceItemType__c>();       
        List<BundleItem__c> bundleItemList = new List<BundleItem__c>();
        List<BillingContract__c> contractList = new List<BillingContract__c>(); 
       
        // HouseHold Customer
        if(sObjectName == 'Account'){
            
        	List<Account> accountList = [SELECT Id FROM Account WHERE Id = :recordId AND RecordType.name =: HH_ACCOUNT LIMIT 1];
            contractList = [SELECT Id FROM BillingContract__c 
                            WHERE AccountName__c In :accountList
                              AND Status__c = :(System.Label.GlAp_ContractStatusActive)];
            
        }else if (sObjectName == GlUt_APIConstantsContracts.CONTRACTAPINAME){
            
            contractList = [SELECT Id FROM BillingContract__c 
                            WHERE Id = :recordId 
                              AND Status__c = :(System.Label.GlAp_ContractStatusActive) 
                              AND AccountName__r.RecordType.name =: HH_ACCOUNT]; 
        }
        
        // Active Contracts 
        if(contractList.size() > 0) {
            List<Service__c> serviceList = [SELECT Id FROM Service__c 
                                            WHERE BillingContract__c IN :contractList
                                            AND (ServiceEndDate__c = null OR ServiceEndDate__c >= :CURRENT_DATE)];
                   
            //Services without an End Date or End Date>= TODAY
            if (serviceList.size() > 0) {                
                sOQLQuery = String.format('SELECT {0} FROM {1}', 
                            new List<String>{'Id,'+ String.join(serviceItemFields,','), 
                            GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME + ' WHERE ' + GlUt_APIConstantsServiceItem.SERVICEAPINAME + ' IN :serviceList AND (' 
                            + GlUt_APIConstantsServiceItem.ENDDATE + ' = null OR ' + GlUt_APIConstantsServiceItem.ENDDATE + ' >= :CURRENT_DATE)'}); 
                
               
                serviceItemList = Database.query(sOQLQuery);
                
                // Check the security on the Contract Item Type fields
                //serviceItemList = GlUt_FieldSecurity.cleanseFields(serviceItemList, serviceItemFields, true); 
               // serviceItemList = GlUt_FieldSecurity.cleanseFields(serviceItemList, true);        
                // ServiceItem Available
                if (serviceItemList.size() > 0) {
                    for(ServiceItem__c objServiceItem: serviceItemList) {
                        serviceItemTypeIDList.add(objServiceItem.ServiceItemType__c);
                    } 
                            
                    sOQLQuery = String.format('SELECT {0} FROM {1}', 
                                new List<String>{'Id,'+ String.join(serviceItemTypeFields,','), 
                                GlUt_APIConstantsServiceItemType.SERVICEITEMTYPEAPINAME + ' WHERE ID IN :serviceItemTypeIDList '});  
                    serviceItemTypeList = Database.query(sOQLQuery);
                    // Check the security on the Contract Item Type fields
                    //serviceItemTypeList = GlUt_FieldSecurity.cleanseFields(serviceItemTypeList, serviceItemTypeFields, true); 
                    // serviceItemTypeList = GlUt_FieldSecurity.cleanseFields(serviceItemTypeList, true);
                     if (serviceItemTypeList.size() > 0) {
                         // Bundles Items
                         sOQLQuery = String.format('SELECT {0} FROM {1}', 
                                                   new List<String>{'Id,'+ String.join(bundleItemFields,','), 
                                                       GlUt_APIConstantsBundleItem.BUNDLEITEMAPINAME + ' WHERE ' + GlUt_APIConstantsBundleItem.SERVICEITEMTYPEAPINAME + ' IN :serviceItemTypeList'});
                         
                         bundleItemList = Database.query(sOQLQuery);
                         
                        // Check the security on the Contract Item Type fields
                       // bundleItemList = GlUt_FieldSecurity.cleanseFields(bundleItemList, bundleItemFields, true); 
                      //  bundleItemList = GlUt_FieldSecurity.cleanseFields(bundleItemList, true); 
                                
                        if (bundleItemList.size() > 0) {
                            for( BundleItem__c objBundleItem: bundleItemList) {
                                bundleList.add(objBundleItem.Bundle__c);
                            }
                                
                            // Bundles 
                            List<Bundle__c> socialBundleList = [SELECT Id FROM Bundle__c WHERE Id IN :bundleList AND TariffLimit__c = TRUE ]; //AT-3280
                                
                            If (socialBundleList.size() > 0)
                                return YES;
                                //return true ;	//AT-3982: Updating return type from String to Boolean
                        }
                    } 
                }   
            }
        }  
        return null;        
        //return false ;	//AT-3982: Updating return type from String to Boolean
    }
    
    
    /******************************************************************************
    @author         Echo: Neha R.
    @date           13/09/2018
    @param           
    @return         Id 
    @description    Method is used to Get the contact id based on email address which we are getting from custom setting.
					// AT-3157 core7b
    *******************************************************************************/
    public static Id getContactByCustomSetting(){
        String printLetterEmailAddress = '';
        List<Contact> contactList = new List<Contact>();
        // Need to pass profile id or user id. 
        ConfigureTemplate__c templateSetting = ConfigureTemplate__c.getOrgDefaults();
        if(templateSetting.PrintedLetterEmailAddress__c != null){
            printLetterEmailAddress = templateSetting.PrintedLetterEmailAddress__c;
        }
       
        if(string.isNotBlank(printLetterEmailAddress)){
            contactList = [SELECT Id, Email FROM Contact WHERE Email =:printLetterEmailAddress];
        }         
        System.debug(DEBUG + 'contactList: ' + contactList);
        if(!contactList.isEmpty() && contactList[0] != null){
            return contactList[0].Id;
        }else{
            return null;
        }
    }
    
    /******************************************************************************
	@author    		Echo: Tarun Gupta
	@date      		12 Nov 2018
	@param			Set<Id> - set of contract Ids
	@return			Map<Id, Boolean> - map of Bank Acc on the contract Ids
	@description	AT-4249, builds a map of contract account bank details                     
	*******************************************************************************/
    public static Map<Id, Boolean> getContractAccountBankDetails(Set<Id> contractIds, Set<Id> accountIds) {
        
        Map<Id, Boolean> mapContractId2Bank = new Map<Id, Boolean>();
        Map<Id, Boolean> mapAccountId2Bank = new Map<Id, Boolean>();
        
        for(BankAccountDetails__c objBankAcc : [SELECT Id,Account__c
                                                FROM BankAccountDetails__c
                                                WHERE Account__c IN : accountIds]){
                                                    mapAccountId2Bank.put(objBankAcc.Account__c,true);  
                                                }
        
        for (BillingContract__c contract : [SELECT Id,AccountName__c,PaymentMethodType__c,PaymentMethodType__r.Name
                                            FROM BillingContract__c
                                            WHERE Id in :contractIds]) {
                                                
                                                if(contract.PaymentMethodType__c != null && contract.PaymentMethodType__r.Name == PyAp_Constants.DIRECTDEBIT && mapAccountId2Bank.containsKey(contract.AccountName__c)){
                                                    mapContractId2Bank.put(contract.Id,true);
                                                }
                                                else{
                                                    mapContractId2Bank.put(contract.Id,false);
                                                }
                                            }
        return mapContractId2Bank;
    } 
    
}