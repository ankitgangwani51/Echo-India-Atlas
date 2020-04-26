/******************************************************************************
@author    		Accenture: Patrick Dixon
@date      		06 Dec 2017
@description 	Class for Suppression utilities
*******************************************************************************/
public with sharing class GlUt_SuppressionUtilities {
    
    private static final String CLASS_NAME = 'GlUt_SuppressionUtilities';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
@author    		Accenture: Patrick Dixon
@date      		06 Dec 2017
@param			Id - void contract Id
@param			Date - the suppression start date 
@return			Id - the suppression Id
@description 	Creates a suppression record for a void contract
*******************************************************************************/
    public static Id suppressVoidContract(Id contractId, Date startDate) {
        
        startDate = startDate < Date.today() ? Date.today() : startDate;		// prevent past start date
        Suppression__c suppression = new Suppression__c(
            BillingContract__c = contractId, 
            SuppressionStartDate__c	= startDate, 
            SuppressRecoveryNotice__c = true, 
            SuppressBillPrint__c = true, 
            SuppressionReason__c = GlUt_Constants.SUPPRESSION_REASON_VOID 
        );
        
        // insert the record
        suppression = (Suppression__c) GlUt_FieldSecurity.cleanseFields(suppression, false);
        insert suppression;
        
        return suppression.Id;
    }
    
    /******************************************************************************
@author         Accenture: Vivek Chauhan
@date           05-Oct-2017
@param          string contractId
@return         Boolean - true if suppressed 
@description    This method is used to check if a Contract is suppressed or not.
@revision		11 Dec 2017, P Dixon
*******************************************************************************/
    public static Boolean isContractSuppressed(Id contractId) {
        
        // check if the contract is suppressed
        for (Suppression__c suppression : [select Id 
                                           from Suppression__c 
                                           where BillingContract__c = :contractId 
                                           and SuppressionStartDate__c <= :Date.today()
                                           and (SuppressionEndDate__c = null 
                                                or SuppressionEndDate__c > :Date.today()) 
                                           and BillingContract__r.Status__c != :Label.GlAp_ContractStatusInactiveNoDebt]) {
                                               
                                               return true;
                                           }
        
        // check if the related account is suppressed
        String customerId;
        for (BillingContract__c contract : [select Id, 
                                            AccountName__c 
                                            from BillingContract__c 
                                            where id = :contractId]) {
                                                
                                                customerId = contract.AccountName__c;
                                            }
        
        for (Suppression__c suppression : [select Id 
                                           from Suppression__c 
                                           where Account__c = :customerId 
                                           and Account__c != null  
                                           and SuppressionStartDate__c <= :Date.today()
                                           and (SuppressionEndDate__c = null 
                                                or SuppressionEndDate__c > :Date.today())]) {
                                                    return true;
                                                }
        return false;
    }
    
    /******************************************************************************
@author         Accenture: Vivek Chauhan
@date           05-Oct-2017
@param          string customerId
@return         String - status YES/NO/PARTIALLY
@description    This method is used to check if an Account is suppressed or not.
@revision		11 Dec 2017, P Dixon
*******************************************************************************/
    public static String getAccountSuppressionStatus(Id customerId) {
        
        for (Suppression__c suppression : [select Id 
                                           from Suppression__c 
                                           where Account__c = :customerId 
                                           and SuppressionStartDate__c <= :Date.today()
                                           and (SuppressionEndDate__c = null 
                                                or SuppressionEndDate__c > :Date.today())]) {
                                                    
                                                    return GlUt_Constants.SUPPRESSED_YES;											
                                                }
        
        // build a set of the account's contract Ids
        Set<Id> setOfContractIds = new Set<Id>();
        for (BillingContract__c objContract : [select Id 
                                               from BillingContract__c 
                                               where AccountName__c = :customerId]) {
                                                   
                                                   setOfContractIds.add(objContract.id);
                                               }
        
        for (Suppression__c suppression : [select Id 
                                           from Suppression__c 
                                           where BillingContract__c in :setOfContractIds 
                                           and SuppressionStartDate__c <= :Date.today()
                                           and (SuppressionEndDate__c = null 
                                                or SuppressionEndDate__c > :Date.today()) 
                                           and BillingContract__r.Status__c != :Label.GlAp_ContractStatusInactiveNoDebt]) {
                                               
                                               return GlUt_Constants.SUPPRESSED_PARTIAL;		
                                           }        
        return GlUt_Constants.SUPPRESSED_NO;
    }
    
    /******************************************************************************
@author         Echo: Vivek Sethi    AT-2340
@date           13-June-2018
@param          string Contract Id
@return         Boolean - status YES/NO
@description    This method is used to check if suppression is on Debt. Recovery.
*******************************************************************************/
    public static Boolean isSuppressionOnDebtRecovery(Id contractId) {
        
        // check if the contract is suppressed
        for (Suppression__c suppression : [select Id 
                                           from Suppression__c 
                                           where BillingContract__c = :contractId 
                                           and SuppressRecoveryNotice__c = true     //If Debt Recovery is suppressed 
                                           and SuppressionStartDate__c <= :Date.today()
                                           and (SuppressionEndDate__c = null 
                                                or SuppressionEndDate__c > :Date.today()) 
                                           and BillingContract__r.Status__c != :Label.GlAp_ContractStatusInactiveNoDebt]) {
                                               
                                               return true;
                                           }
        
        // check if the related account is suppressed
        String customerId;
        for (BillingContract__c contract : [select Id, 
                                            AccountName__c 
                                            from BillingContract__c 
                                            where id = :contractId]) {
                                                customerId = contract.AccountName__c;
                                            }
        
        for (Suppression__c suppression : [select Id 
                                           from Suppression__c 
                                           where Account__c = :customerId 
                                           and Account__c != null  
                                           and SuppressionStartDate__c <= :Date.today()
                                           and (SuppressionEndDate__c = null 
                                                or SuppressionEndDate__c > :Date.today())]) {
                                                    return true;
                                                }
        return false;
    }
}