/******************************************************************************
@author         Echo: Amit K.
@date           25-June-2018
@description    Class to change the Bank Account Details Billing Contracts  
*******************************************************************************/
public with sharing class PyBt_ChangeBankDetails{
    private static final String CLASS_NAME = 'PyBt_ChangeBankDetails';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author         Echo: Amit K.
    @date           25-June-2018
	@param			List<BankAccountAction__c> bankAccountActionList
    @description    Method is used to update bank account details.
    *******************************************************************************/
    public static void updateBankDetails(List<BankAccountAction__c> bankAccountActionList) {
        Set<Id> clearBankAccountDetailsContractIds = new Set<Id>();
        Map<Id,BankAccountDetails__c> mapOfContractId2NewBankAccountDetails = new Map<Id,BankAccountDetails__c>();
        List<BankAccountAction__c> bankAccountActionProcessedList = new List<BankAccountAction__c>();
        Savepoint sp = Database.setSavepoint(); 
        try {
            for(BankAccountAction__c bankAccountActionObj: bankAccountActionList){
                //Check Bank Account Change associated with Bank Account Action and Bank Account Change required field information should not be blank.
                if(bankAccountActionObj.BankAccountChange__c != null 
                   && string.isNotBlank(bankAccountActionObj.BankAccountChange__r.BankAccountSortCode__c)
                   && string.isNotBlank(bankAccountActionObj.BankAccountChange__r.NameOnAccount__c) 
                   && string.isNotBlank(bankAccountActionObj.BankAccountChange__r.BankAccountNumber__c)
                   && bankAccountActionObj.BankAccountChange__r.BillingContract__c != null){
                       BankAccountDetails__c newBankAccountDetailObj = new BankAccountDetails__c();
                       newBankAccountDetailObj.BankAccountSortCode__c = bankAccountActionObj.BankAccountChange__r.BankAccountSortCode__c;
                       newBankAccountDetailObj.NameOnAccount__c = bankAccountActionObj.BankAccountChange__r.NameOnAccount__c;
                       newBankAccountDetailObj.BankAccountNumber__c = bankAccountActionObj.BankAccountChange__r.BankAccountNumber__c;
                       newBankAccountDetailObj.Account__c = bankAccountActionObj.BankAccountChange__r.BillingContract__r.AccountName__c;
                       //AT-3124 Starts Here
                       //newBankAccountDetailObj.Name = bankAccountActionObj.BankAccountChange__r.BillingContract__r.AccountName__r.Name+' '+ Datetime.now().format('yyyy-MM-dd');
                       //AT-3124 Ends Here
                       mapOfContractId2NewBankAccountDetails.put(bankAccountActionObj.BankAccountChange__r.BillingContract__c,newBankAccountDetailObj);
                       bankAccountActionObj.Status__c = PyBt_Constants.BANK_ACCOUNT_ACTION_PROCESSED;
                       bankAccountActionProcessedList.add(bankAccountActionObj);
                   }else{
                       //Bank Account Detail records removed from Contract if bank account change records field information is blank and bank account change doesn't associated with bank account action.
                       if(bankAccountActionObj.DirectDebitReturn__c != null){
                           clearBankAccountDetailsContractIds.add(bankAccountActionObj.DirectDebitReturn__r.BillingContract__c); // Create list for contract Id where bank account details needs to be remove.
                           bankAccountActionObj.Status__c = PyBt_Constants.BANK_ACCOUNT_ACTION_PROCESSED;
                           bankAccountActionProcessedList.add(bankAccountActionObj);
                       }else if(bankAccountActionObj.BankAccountChange__c != null){
                           clearBankAccountDetailsContractIds.add(bankAccountActionObj.BankAccountChange__r.BillingContract__c);
                           bankAccountActionObj.Status__c = PyBt_Constants.BANK_ACCOUNT_ACTION_PROCESSED;
                           bankAccountActionProcessedList.add(bankAccountActionObj);
                       }else{
                           bankAccountActionObj.Status__c = PyBt_Constants.BANK_ACCOUNT_ACTION_ERROR;
                           bankAccountActionProcessedList.add(bankAccountActionObj);
                       }
                   }
            }
            if(mapOfContractId2NewBankAccountDetails.values().size() > 0)
                Database.insert(mapOfContractId2NewBankAccountDetails.values()); // create new bank account detail record.
            if(!clearBankAccountDetailsContractIds.isEmpty()){
                List<BillingContract__c> contractList = [select Id,
                                                  BankAccountDetails__c,
                                                  PaymentMethodType__c
                                                  from BillingContract__c 
                                                  where Id In:clearBankAccountDetailsContractIds]; // Fetch the required contract where bank account details needs to be removed.
                for(BillingContract__c contractObj: contractList){
                    contractObj.BankAccountDetails__c = null;
                    contractObj.PaymentMethodType__c = null;
                }
                if(contractList != null && !contractList.isEmpty())
                    Database.update(contractList); // remove bank account details from Contract record.
                System.debug(DEBUG+'*****contractList'+contractList);
            }
            List<BillingContract__c> updatedContractList = new List<BillingContract__c>(); // create contract list that needs to be updated with new bank account details.
            for(Id contractIds : mapOfContractId2NewBankAccountDetails.keySet()){
                BankAccountDetails__c bankDetailsObj  = mapOfContractId2NewBankAccountDetails.get(contractIds);
                BillingContract__c contractObj = new BillingContract__c();
                contractObj.BankAccountDetails__c = bankDetailsObj.Id;
                contractObj.Id =  contractIds;
                updatedContractList.add(contractObj);
            }
            if(!updatedContractList.isEmpty()){
                updatedContractList = (List<BillingContract__c>) GlUt_FieldSecurity.cleanseFields(updatedContractList, false);
                Database.update(updatedContractList); // modify the contract with new bank account detail record.
            }
            if(!bankAccountActionProcessedList.isEmpty()){
                bankAccountActionProcessedList = (List<BankAccountAction__c>) GlUt_FieldSecurity.cleanseFields(bankAccountActionProcessedList, false);
                Database.update(bankAccountActionProcessedList);// Change the Status to Processed for Bank Account Action records. 
            }
            
        }
        catch (exception e) {
            Database.rollback(sp);
            GlUt_Logger.logException(e);
            System.debug(DEBUG + 'Error == ' + e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
}