/******************************************************************************
@author         Echo: Dependra Singh (Echo)
@date           20 Feb 2018
@description    Handler for Contract trigger
                AT-4891/2 Code Check Marx Changes for FLS INSERT/UPDATE
*******************************************************************************/
public with sharing class GlUt_BillingContractHandler extends GlUt_TriggerHandlerBase { 
    
    private static final String CLASS_NAME = 'GlUt_ContractHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    List<BankAccountChange__c> bankAccountChangeList;
    /******************************************************************************
    @author         Echo: Dependra Singh (Echo)
    @date           20 Feb 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {
        try {
            if (inputParam.isInsert && inputParam.isAfter) {
                createBalanceAssosiateWithContractAndAccount(inputParam.newlist);
                createNewPaymentPlanForNewContract(inputParam.newlist);
                createBankAccountChangeRecord(inputParam.newlist,inputParam.newMap, null,null);
            }
            if (inputParam.isInsert && inputParam.isBefore) {
            }
            if (inputParam.isUpdate && inputParam.isAfter) {
                 createBankAccountChangeRecord(inputParam.newlist,inputParam.newMap, inputParam.oldList,inputParam.oldMap);
            }
            if (inputParam.isUpdate && inputParam.isBefore) {
            }
            if (inputParam.isDelete && inputParam.isBefore) {
            }
            
            if (inputParam.isDelete && inputParam.isAfter) {
            }
            
        } catch (exception e) {
            System.debug('****'+e.getMessage());
            GlUt_Logger.logException(e);
            GlUt_Logger.writeLogsToDatabase();
            
            //Logger.debugException(e);
        }
        
        finally {
            // insert the bank account change records 
            if( bankAccountChangeList != null && !bankAccountChangeList.isEmpty()) {
                bankAccountChangeList = (List<BankAccountChange__c>) GlUt_FieldSecurity.cleanseFields(bankAccountChangeList, false); //AT-4891 Code Check Marx Changes Starts/Ends Here. 
                insert bankAccountChangeList;
            }
            // Reset the active function to null in case this class was first in stack
            // this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
           
            // TO-DO Logger.pop();
        }
    }
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           20 Feb 2018
    @param          List<BillingContract__c> contractList
    @description    Update the Contract trigger handler so that; on create of a contract an assoicated balance record is created, 
    linked to the same account that the contract is linked too
    @return         void
    *******************************************************************************/
    private void createBalanceAssosiateWithContractAndAccount(List<BillingContract__c> contractList) {
        
        // Set of contract ids  
        Set<Id> contractsIds = new Set<Id>();
        // List of contract to update
        List<BillingContract__c> contractListToUpdate = new List<BillingContract__c>();
        // List of balances
        List<Balance__c> balanceList = new List<Balance__c>();
        // Map of balance by customer id.
        Map<Id, Id> balanceByCustomerId = new Map<Id, Id>(); 
        // Looping on list of contracts coming through trigger.
        for(BillingContract__c objContract : contractList){
            if(objContract.AccountName__c != null){
                // Creating new balance object and adding it in list of balance.
                Balance__c objBalance = new Balance__c();
                objBalance.Account__c = objContract.AccountName__c;
                balanceList.add(objBalance);
                contractsIds.add(objContract.Id);
                
            } 
        }
        // If balance list not empty the inserting balance list and creating map of balance is by account id.
        if(!balanceList.isEmpty()){
            balanceList = (List<Balance__c>) GlUt_FieldSecurity.cleanseFields(balanceList, false); //AT-4891 Code Check Marx Changes Starts/Ends Here. 
            insert balanceList;
            for(Balance__c balance : balanceList)  {
                if(balance.Id != null && balance.Account__c != null){
                    if(!balanceByCustomerId.containsKey(balance.Account__c)){
                        balanceByCustomerId.put(balance.Account__c,balance.Id);
                    }
                }
            }
        }
        // If contract id set size is greater than 0 then fetching and udating balance on contract.  
        if(contractsIds.size() >0){
            List<BillingContract__c> lstContracts = [ SELECT Id,AccountName__c,Balance__c  FROM BillingContract__c WHERE ID IN:contractsIds]; 
            for(BillingContract__c objContract : lstContracts){ 
                if(balanceByCustomerId != null && balanceByCustomerId.containsKey(objContract.AccountName__c)){
                    if(objContract.Balance__c== null)
                        objContract.Balance__c = balanceByCustomerId.get(objContract.AccountName__c);
                    contractListToUpdate.add(objContract);
                }
            }
        } 
        if(!contractListToUpdate.isEmpty()){
            contractListToUpdate = (List<BillingContract__c>) GlUt_FieldSecurity.cleanseFields(contractListToUpdate, false); //AT-4892 Code Check Marx Changes Starts/Ends Here. 
            update contractListToUpdate;
        }
    }
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           20 Feb 2018
    @param          List<BillingContract__c> contractList
    @description    Create a payment plan for the new contract that is created. The payment plan should have a pay in full move in type.
    SystemDefault_c' on payment plan type to cover this. Find the first payment plan type where 'systemDefault_c' is true and use this as the default plan.
    If multiple plans are set as default just use the first one.
    @return         void
    *******************************************************************************/
    private void createNewPaymentPlanForNewContract(List<BillingContract__c> contractList) {
        List<PaymentPlan__c>    paymentPlanList = new List<PaymentPlan__c>();
        List<PaymentPlanType__c> paymentPlanTypeList = [SELECT Id, 
                                                        PlanType__c,
                                                        DebtRecoveryProfile__c,
                                                        SystemDefault__c 
                                                        FROM PaymentPlanType__c 
                                                        WHERE PlanType__c =: PyAp_Constants.PAYINFULL 
                                                        AND SystemDefault__c = true LIMIT 1];
        
        
        if(!paymentPlanTypeList.isEmpty()){
            for(BillingContract__c objContract : contractList){
                PaymentPlan__c objPaymentPlan = new PaymentPlan__c();
                objPaymentPlan.BillingContract__c = objContract.Id; //AT-3174
                objPaymentPlan.StartDate__c = System.today();
                objPaymentPlan.PaymentPlanType__c = paymentPlanTypeList[0].Id;
                paymentPlanList.add(objPaymentPlan);
            }
        }
        if(!paymentPlanList.isEmpty()){
            paymentPlanList = (List<PaymentPlan__c>) GlUt_FieldSecurity.cleanseFields(paymentPlanList, false); //AT-4891 Code Check Marx Changes Starts/Ends Here. 
            insert paymentPlanList;
        }
    }
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           20 June 2018
    @param          List<BillingContract__c> contractList
    @description    AT-3119,Create bank account change record when changing bank account details on contract.
    *******************************************************************************/
    private void createBankAccountChangeRecord(List<sObject> newList,Map<Id,sObject> newMap,List<sObject> oldList, Map<Id,sObject> oldMap) {
        // Map of Bank Account Detail By Id.
        Map<Id, BankAccountDetails__c> bankAccountDetailsMap ;
        //Set of bank Account Detail Ids
        Set<Id> bankAccountIdsSet = new Set<Id>();
        //List of bank account change to insert the records.
        bankAccountChangeList = new List<BankAccountChange__c>();
        //Bank Account Change Get RecordType Id by name.
        Id BankAccChangeOutgoingRecTypeId = Schema.SObjectType.BankAccountChange__c.getRecordTypeInfosByName().get(GlUt_Constants.OUTGOING).getRecordTypeId();
        if(newList != null && !newList.isEmpty() ){
            // Fetching Bank Account Ids and Details
            for(BillingContract__c objContract : (List<BillingContract__c>)newList){
                if(objContract.BankAccountDetails__c != null){
                    bankAccountIdsSet.add(objContract.BankAccountDetails__c) ;
                }
            }
            // If Old List is not empty
            if(oldList != null && !oldList.isEmpty()){
                for(BillingContract__c objContract : (List<BillingContract__c>)oldList){
                    if(objContract.BankAccountDetails__c != null){
                        bankAccountIdsSet.add(objContract.BankAccountDetails__c) ;
                    }
                }  
            }
            system.debug('bankAccountIdsSet============'+bankAccountIdsSet);
            if(bankAccountIdsSet.size() > 0){                
                bankAccountDetailsMap = new  Map<Id, BankAccountDetails__c>([Select Id,BankAccountNumber__c, BankAccountSortCode__c,
                                                                             NameOnAccount__c from BankAccountDetails__c where Id IN: bankAccountIdsSet]);
            }
            
            system.debug('bankAccountDetailsMap============'+bankAccountDetailsMap);
            if(oldMap != null && oldMap.keyset().size() > 0){
                for(BillingContract__c objContract : (List<BillingContract__c>)newList){
                    Id bankAccountDetailId = ((BillingContract__c) oldMap.get(objContract.Id)).BankAccountDetails__c;
                    system.debug('bankAccountDetailId============'+bankAccountDetailId);
                    //If the new Bank Account Detail is not Null and the old Bank Account Detail is Null create a Bank Account Change Record
                    if(objContract.BankAccountDetails__c != null && bankAccountDetailId == null){
                        BankAccountChange__c objBankAccountChange = createBankAccountChange(GlUt_Constants.TRANSACTIONCODE0N,objContract,bankAccountDetailsMap,oldMap);
						if(objBankAccountChange != null){
							bankAccountChangeList.add(objBankAccountChange);// Add created record to list
						}
                    }
                    // If the new Bank Account Detail is Null and the old Bank Account Detail is not Null create a Bank Account Change Record      
                    else 
                        if(objContract.BankAccountDetails__c == null && bankAccountDetailId != null){
                            BankAccountChange__c objBankAccountChange = new BankAccountChange__c();
                            objBankAccountChange.RecordTypeId = BankAccChangeOutgoingRecTypeId;
                            objBankAccountChange.TransactionCode__c = GlUt_Constants.TRANSACTIONCODE0C;
                            objBankAccountChange.Date__c = System.today();
							objBankAccountChange.BillingContract__c = objContract.Id;
                            objBankAccountChange.BankAccountDetails__c = bankAccountDetailId;
                            if(bankAccountDetailsMap != null && bankAccountDetailsMap.containsKey(bankAccountDetailId)){
                                objBankAccountChange.BankAccountNumber__c = bankAccountDetailsMap.get(bankAccountDetailId).BankAccountNumber__c;
                                objBankAccountChange.BankAccountSortCode__c  = bankAccountDetailsMap.get(bankAccountDetailId).BankAccountSortCode__c;
                                objBankAccountChange.NameOnAccount__c  = bankAccountDetailsMap.get(bankAccountDetailId).NameOnAccount__c;
                            }
                             objBankAccountChange.Status__c=System.Label.GlAp_Pending;
                            bankAccountChangeList.add(objBankAccountChange);// Add created record to list 
                        }
                    //If the new Bank Account Detail is not Null and the old Bank Account Detail is not Null but the value has changed, create two Bank Account Change Record
                    else 
					if(objContract.BankAccountDetails__c != null && bankAccountDetailId!= null){
						if(objContract.BankAccountDetails__c  != bankAccountDetailId){
						   BankAccountChange__c objBankAccountChange = createBankAccountChange(GlUt_Constants.TRANSACTIONCODE0N,objContract,bankAccountDetailsMap,oldMap);
						   if(objBankAccountChange != null){
							  bankAccountChangeList.add(objBankAccountChange);// Add created record to list
							}                                                               
							BankAccountChange__c objBankAccountChangeOld = createBankAccountChange(GlUt_Constants.TRANSACTIONCODE0C,objContract,bankAccountDetailsMap,oldMap);
							 if(objBankAccountChangeOld != null){
							  bankAccountChangeList.add(objBankAccountChangeOld);// Add created record to list
							}
						}
					}
                }
            }
            else{
                //If the new Bank Account Detail is not Null.
                for(BillingContract__c objContract : (List<BillingContract__c>)newList){
                    if(objContract.BankAccountDetails__c != null){
						BankAccountChange__c objBankAccountChange = createBankAccountChange(GlUt_Constants.TRANSACTIONCODE0N,objContract,bankAccountDetailsMap,oldMap);
						if(objBankAccountChange != null){
							bankAccountChangeList.add(objBankAccountChange);// Add created record to list
						}
                    }
                }
            }
        }
    }
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           20 June 2018
    @param          List<Contract__c> contractList
    @description    AT-3119,Create bank account change record when changing bank account details on contract.
    *******************************************************************************/	
	 private BankAccountChange__c createBankAccountChange(string strtransactionCode,BillingContract__c objContract,Map<Id, BankAccountDetails__c> bankAccountDetailsMap, Map<Id,sObject> oldMap) {
         Id BankAccChangeOutgoingRecTypeId = Schema.SObjectType.BankAccountChange__c.getRecordTypeInfosByName().get(GlUt_Constants.OUTGOING).getRecordTypeId();
         BankAccountChange__c objBankAccountChange = new BankAccountChange__c();
         objBankAccountChange.RecordTypeId = BankAccChangeOutgoingRecTypeId;
         objBankAccountChange.TransactionCode__c = strtransactionCode;
         objBankAccountChange.Date__c = System.today();
         objBankAccountChange.BillingContract__c = objContract.Id; 	
         if(strtransactionCode == GlUt_Constants.TRANSACTIONCODE0C){
             objBankAccountChange.BankAccountDetails__c = ((BillingContract__c) oldMap.get(objContract.Id)).BankAccountDetails__c;
         }else{
				objBankAccountChange.BankAccountDetails__c = objContract.BankAccountDetails__c;
			}
			if(bankAccountDetailsMap != null && bankAccountDetailsMap.containsKey(objBankAccountChange.BankAccountDetails__c)){
				objBankAccountChange.BankAccountNumber__c = bankAccountDetailsMap.get(objBankAccountChange.BankAccountDetails__c).BankAccountNumber__c;
				objBankAccountChange.BankAccountSortCode__c  = bankAccountDetailsMap.get(objBankAccountChange.BankAccountDetails__c).BankAccountSortCode__c;
				objBankAccountChange.NameOnAccount__c  = bankAccountDetailsMap.get(objBankAccountChange.BankAccountDetails__c).NameOnAccount__c;
			}
			objBankAccountChange.Status__c=System.Label.GlAp_Pending;
			return objBankAccountChange;
	 }
}