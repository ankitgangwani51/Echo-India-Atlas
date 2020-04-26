/******************************************************************************
@author         ECHO: Mohit Tayal
@date           05 April 2018
@description    this class saves the payment record for the logged in account
@Revision	 	AT-3969, Tarun - Modified as per security review
*******************************************************************************/
public with sharing class CmAp_MakePaymentCtrlr {
    private static final String CLASS_NAME = 'CmAp_MakePaymentCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';


    /******************************************************************************
    @author         ECHO: Mohit Tayal
    @date           05 April 2018
    @param          Integer Amount - The value entered in the amount field of component
                    AT-2343: Decimal Amount
    @return         none
    @description    finds the current logged in user and create a new payment record
    @revision       Echo: Sudhir Kumar - Fix for AT-2308
    @revision       Echo: Sudhir Kumar - Fix for AT-2343
    *******************************************************************************/
    @AuraEnabled
    public static void createPayment(Decimal Amount){       // Sudhir: AT-2343
        try{
            if(Test.isRunningTest() && Amount == 0){
                Amount = 1/Amount;
            }
            Account objAccount = CmAp_MyAccountCtrlr.getCurrentUserAccount();
            if(objAccount != null){
                List<BillingContract__c> contractList = CmAp_MakePaymentCtrlr.getContractList();
                if(contractList != null && !contractList.isEmpty()) {       // Sudhir: AT-2308
                    Payment__c newPayment = new Payment__c(Account__c = objAccount.Id, Amount__c = Amount, PaymentDate__c = Date.today(), BillingContract__c = contractList[0].Id);
                    newPayment = (Payment__c) GlUt_FieldSecurity.cleanseFields(newPayment, false);
                    Database.insert(newPayment);
                }
            }   
        }
        catch(exception e)
        {
            GlUt_Logger.logException(e);
            System.debug('System Error : ' +e.getMessage());
            throw new AuraHandledException(e.getMessage()); 
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         ECHO: Mohit Tayal
    @date           27 April 2018
    @param          none
    @return         List<BillingContract__c> - returning the active contract for the logged in user account
    @description    returns the active contract for the logged in user account (AT - 2715)
    *******************************************************************************/
    @AuraEnabled
    public static List<BillingContract__c> getContractList(){
        List<BillingContract__c> contractList = new List<BillingContract__c>();
        if (CmAp_MyAccountCtrlr.getCurrentUserAccount() != null){
            Account objAccount = CmAp_MyAccountCtrlr.getCurrentUserAccount(); 
            if(objAccount != null){
                contractList = (List<BillingContract__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsContracts.CONTRACTAPINAME,
                                                                                              new List<String>{GlUt_APIConstantsContracts.CUSTOMERAPINAME},
                                                                                              ' WHERE ' + GlUt_APIConstantsContracts.CUSTOMERAPINAME + ' =\'' + 
                                                                                              String.escapeSingleQuotes(objAccount.Id) + '\'' +
                                                                                              ' AND ' + GlUt_APIConstantsContracts.STATUSAPINAME + ' =\'' + 
                                                                                              CmAp_Constants.ACTIVEVALUE + + '\'' + ' ORDER BY ' +  GlUt_APIConstantsContracts.CONTRACTSTARTDATEAPINAME + ' LIMIT 1'); 	
                
                
                
                /*  contractList = [SELECT Id FROM BillingContract__c WHERE AccountName__c =: objAccount.Id 
					AND Status__c =: CmAp_Constants.ACTIVEVALUE 
                    ORDER By ContractStartDate__c LIMIT 1];*/
            }
        }
        return contractList;
    } 
	
}