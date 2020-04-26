/******************************************************************************
@author         Echo: Dependra Singh
@date           06-Feb-2018
@description    Class for Balance utilities

Revisions       09 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class GlUt_BalanceUtilities{

    private static final String CLASS_NAME = 'GlUt_BalanceUtilities';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
        
    /**********************************************************************************************
    @author         Echo: Dependra Singh
    @date           06-Feb-2018
    @param          Id-(ContractId), List<String> (contract Field List), List<string> (Balance Field List.)
    @return         String (balance amount as string)
    @description    Method is used to fetch balance amount, Balance which is asssociated to contract.
    **********************************************************************************************/   
   
    public static decimal getBalanceAmount(Id contractId, List<String> contractListFields, List<String> balanceFieldList) {
        decimal strBalanceAmount = 0.00;
        if (contractId != null) {
            BillingContract__c contract = (BillingContract__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsContracts.CONTRACTAPINAME, contractId, contractListFields);
            if (contract.Balance__c != null) {
                Balance__c balance = (Balance__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsBalances.BALANCEAPINAME,contract.Balance__c,balanceFieldList);
                if (balance.Balance__c != null && balance.Balance__c < 0) {
                    strBalanceAmount = balance.Balance__c * -1;
                }
            }
        }
        return strBalanceAmount;
    }
    
     /**********************************************************************************************
    @author         Echo: Dependra Singh
    @date           06-Feb-2018
    @param          Id-(ContractId), List<String> (contract Field List), List<string> (Balance Field List.)
    @return         Balance__c
    @description    Method is used to return balance, Balance which is asssociated to contract.
    **********************************************************************************************/   
    public static Balance__c getBalance(Id contractId, List<String> contractListFields, List<String> balanceFieldList) {
        Balance__c balance ;
        if (contractId != null) {
            BillingContract__c contract = (BillingContract__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsContracts.CONTRACTAPINAME,contractId, contractListFields);
            if (contract.Balance__c != null) {
                balance = (Balance__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsBalances.BALANCEAPINAME,contract.Balance__c, balanceFieldList);
            }
        }
        return balance;
    }
    
}