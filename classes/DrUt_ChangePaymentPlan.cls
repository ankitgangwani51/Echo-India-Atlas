/******************************************************************************
@author         Echo: Mohit Tayal
@date           03-Jan-2018
@description    Class to change change the payment plan for the Debt Recovery Action records 
of type 'Change Payment Plan'
*******************************************************************************/
public with sharing class DrUt_ChangePaymentPlan {
    
    private static final String CLASS_NAME = 'DrUt_ChangePaymentPlan';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    public static Boolean isAutoCancelled = false; //AT-4910, Ankit, 24/01/2018
    
    
    /******************************************************************************
	@author         Echo: Mohit Tayal
	@date           03-Jan-2018
	@param			recList - List of debt recovery action Ids
	@description    Method to change change the payment plan for the Debt Recovery Action records 
	of type 'Change Payment Plan'
	*******************************************************************************/    
    public static void updatePayment(List<DebtRecoveryAction__c> dbtRecActionList) {
      // Chnaged By Dependra - 13-11-2018 - Removed Query, No Need to query again. AT-3824
        Set<String> debtRecActionParamSet = new Set<String>();
        Map<Id, Id> actionContractIdsMap = new Map<Id, Id>();
        Map<String, Id> payPlanTypeIdNameMap = new Map<String, Id>();
        
        try {
            // creating map of debt recovery action id and associated contract id
            for (DebtRecoveryAction__c dRecActRec : dbtRecActionList) {
                if (dRecActRec.DebtRecoveryProcess__r.BillingContract__c != null) {
                    actionContractIdsMap.put(dRecActRec.Id, dRecActRec.DebtRecoveryProcess__r.BillingContract__c);
                }
                debtRecActionParamSet.add(dRecActRec.Parameters__c);
            }
            System.debug('debtRecActionParamSet***'+ debtRecActionParamSet);
            for (PaymentPlanType__c payPlanType : [SELECT Id, Name, ResetDebtRecovery__c FROM PaymentPlanType__c WHERE Name IN :debtRecActionParamSet]) {
                payPlanTypeIdNameMap.put(payPlanType.Name, payPlanType.Id);
            }
            System.debug('payPlanTypeIdNameMap**'+ payPlanTypeIdNameMap);
            system.debug('actionContractIdsMap**'+ actionContractIdsMap);
            // creating map of the contract ids and the contract object
            if(actionContractIdsMap.values().size() > 0){
                Map<Id, BillingContract__c> contractMap = new Map<Id, BillingContract__c>([SELECT Id, 
                                                                             // fields required for payment plan calculation
                                                                             AccountName__c, 
                                                                             CurrentPaymentPlanType__c, 
                                                                             PaymentPlanRenewalDate__c, 
                                                                             DayOfWeek__c, 
                                                                             DayOfMonth__c,  
                                                                             // fields required for debt recovery
                                                                             CurrentPaymentPlanType__r.ResetDebtRecovery__c, 
                                                                             CurrentDebtRecoveryProcess__c, 
                                                                             CurrentDebtRecoveryProcess__r.CurrentStage__c,
                                                                             Balance__c,
                                                                             BillingAddress__c
                                                                             FROM BillingContract__c WHERE Id IN :actionContractIdsMap.values()]);
                
                Map<Id, BillingContract__c> updatedContractMap = new Map<Id, BillingContract__c>();
                
                for (DebtRecoveryAction__c dRecActRec : dbtRecActionList) {
                    
                    // validating the parameter field of the debt recovery action  
                    if (String.isBlank(dRecActRec.Parameters__c) || dRecActRec.Parameters__c == null) {
                        dRecActRec.Status__c = DrBt_Constants.ERROR;                        
                        dRecActRec.ErrorMessage__c = Label.DrUt_ChangePaymentPlanParamBlankError;
                        
                    } else if (!actionContractIdsMap.containsKey(dRecActRec.Id)) {
                        dRecActRec.Status__c = DrBt_Constants.ERROR;
                        dRecActRec.ErrorMessage__c = Label.DrUt_ChangePaymentPlanNoConAgainstActionError;
                        
                    } else if (payPlanTypeIdNameMap.containsKey(dRecActRec.Parameters__c)) {
                        Id contractId = actionContractIdsMap.get(dRecActRec.Id);
                        BillingContract__c contract = contractMap.get(contractId);
                        contract.CurrentPaymentPlanType__c = payPlanTypeIdNameMap.get(dRecActRec.Parameters__c);
                        updatedContractMap.put(contract.Id,contract);
                        dRecActRec.Status__c = DrBt_Constants.PROCESSED;
                    } else {
                        dRecActRec.Status__c = DrBt_Constants.ERROR;
                        dRecActRec.ErrorMessage__c = Label.DrUt_ChangePaymentPlanNoPaymentPlanTypeError;
                    }
                } 
                if(updatedContractMap.values().size() > 0){
                    Database.update(updatedContractMap.values());
                    isAutoCancelled = True; //AT-4910, Ankit, 24/01/2018
                    // calculate a new payment plan and commit all the records
                    PpUt_PaymentPlanUtilities.calculatePlans(updatedContractMap.values());
                    
                    // Code to update Debt Recovery Process for the contract as completed
                    List<DebtRecoveryProcess__c> debtRecProcessList = new List<DebtRecoveryProcess__c>();
                    
                    for (BillingContract__c con : [SELECT Id, 
                                            CurrentPaymentPlanType__r.ResetDebtRecovery__c, 
                                            CurrentDebtRecoveryProcess__c, 
                                            CurrentDebtRecoveryProcess__r.CurrentStage__c
                                            FROM BillingContract__c WHERE Id IN :updatedContractMap.keySet()]) {
                                                if (con.CurrentPaymentPlanType__r.ResetDebtRecovery__c) {
                                                    DebtRecoveryProcess__c objDebtRecProcess = new DebtRecoveryProcess__c(Id = con.CurrentDebtRecoveryProcess__c, 
                                                                                                                          CurrentStage__c = DrBt_Constants.COMPLETED, 
                                                                                                                          EvaluateForDebtRecovery__c = TRUE, 
                                                                                                                          CurrentStageDateTime__c = Date.today(), 
                                                                                                                          Flag__c = TRUE);
                                                    debtRecProcessList.add(objDebtRecProcess);
                                                }
                                            }
                    if(debtRecProcessList.size() > 0){
                        debtRecProcessList = (List<DebtRecoveryProcess__c>) GlUt_FieldSecurity.cleanseFields(debtRecProcessList, false);
                        Database.update(debtRecProcessList);
                    }
                    // End Code to update Debt Recovery Process for the contract as completed
                }
                dbtRecActionList = (List<DebtRecoveryAction__c>) GlUt_FieldSecurity.cleanseFields(dbtRecActionList, false);
                Database.update(dbtRecActionList);
            }
        }
        catch (exception e) {
            GlUt_Logger.logException(e);
            System.debug(DEBUG + 'Error == ' + e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    /******************************************************************************
	@author         Echo: Amit K.
	@date           22-June-2018
	@param			bankAccountActionList - List of Bank Account Actions
	@description    Method to change the current payment plan type on the contract records associated with the Bank Account
                    Action and create new payment plan using PpUt_PaymentPlanUtilities. 
	*******************************************************************************/
    public static void changePaymentPlan(List<BankAccountAction__c> bankAccountActionList) {
        Map<Id,Id> mapOfBankAccountActionId2ContractId = new Map<Id,Id>(); // Map of Bank Account Action record Id having Contract Id.
        Set<String> paymentPlanTypeNameSet = new Set<String>();
        Savepoint sp = Database.setSavepoint();
        try {
            for(BankAccountAction__c bankAccountActionObject: bankAccountActionList){
                if(bankAccountActionObject.BankAccountChange__r.BillingContract__c != null)// Check if Bank Account Change having billing contract Id.
                    mapOfBankAccountActionId2ContractId.put(bankAccountActionObject.Id,bankAccountActionObject.BankAccountChange__r.BillingContract__c);
                else if(bankAccountActionObject.DirectDebitReturn__r.BillingContract__c != null)
                    mapOfBankAccountActionId2ContractId.put(bankAccountActionObject.Id,bankAccountActionObject.DirectDebitReturn__r.BillingContract__c);
                if(string.isNotBlank(bankAccountActionObject.Parameters__c) && bankAccountActionObject.Parameters__c != null){
                    paymentPlanTypeNameSet.add(bankAccountActionObject.Parameters__c);//create collections on payment plans names.
                }
            }
             Map<String,Id> mapOfPaymentPlanName2PaymentPlanId = new Map<String,Id>();
            //Fetch the payment plan type record on the basis of payment plan names. 
            List<PaymentPlanType__c> paymentPlanTypeList = [Select Id,
                                                            Name,
                                                            PlanType__c
                                                            from PaymentPlanType__c 
                                                            WHERE Name IN : paymentPlanTypeNameSet];
            if(paymentPlanTypeList != null && !paymentPlanTypeList.isEmpty()){
                for(PaymentPlanType__c paymentPlanTypeObj: paymentPlanTypeList){
                    mapOfPaymentPlanName2PaymentPlanId.put(paymentPlanTypeObj.Name,paymentPlanTypeObj.Id); // Map of Payment plan type name having payment plan type Id.
                }
            }
            if(mapOfBankAccountActionId2ContractId.values().size() > 0){
                Map<Id, BillingContract__c> contractMap = new Map<Id, BillingContract__c>([SELECT Id, 
                                                                             // fields required for payment plan calculation
                                                                             AccountName__c, 
                                                                             CurrentPaymentPlanType__c, 
                                                                             PaymentPlanRenewalDate__c, 
                                                                             DayOfWeek__c, 
                                                                             DayOfMonth__c,
                                                                             Balance__c,
                                                                             BillingAddress__c
                                                                             FROM BillingContract__c WHERE Id IN :mapOfBankAccountActionId2ContractId.values()]);
                Map<Id, BillingContract__c> updatedContractMap = new Map<Id, BillingContract__c>();
                List<BankAccountAction__c> updatedBankAccountActionStatusList = new List<BankAccountAction__c>();
                for(BankAccountAction__c objBankAccountAction : bankAccountActionList){
                   //Check if payment plan type exists or not OR contract balance Less then equal to zero.
                    if(!mapOfPaymentPlanName2PaymentPlanId.containsKey(objBankAccountAction.Parameters__c)){
                        objBankAccountAction.Status__c = PyBt_Constants.BANK_ACCOUNT_ACTION_ERROR;
                        updatedBankAccountActionStatusList.add(objBankAccountAction);
                    }
                    else if((objBankAccountAction.BankAccountChange__r.BillingContract__c != null &&
                             objBankAccountAction.BankAccountChange__r.BillingContract__r.ContractBalance__c <= 0) || 
                            (objBankAccountAction.DirectDebitReturn__r.BillingContract__c != null &&
                             objBankAccountAction.DirectDebitReturn__r.BillingContract__r.ContractBalance__c <= 0)){
                                 objBankAccountAction.Status__c = PyBt_Constants.BANK_ACCOUNT_ACTION_ERROR;
                                 updatedBankAccountActionStatusList.add(objBankAccountAction);
                             }
                    else if(mapOfPaymentPlanName2PaymentPlanId.containsKey(objBankAccountAction.Parameters__c) &&
                            (objBankAccountAction.BankAccountChange__r.BillingContract__c != null ||
                             objBankAccountAction.DirectDebitReturn__r.BillingContract__c != null)){
                                 Id contractId = mapOfBankAccountActionId2ContractId.get(objBankAccountAction.Id);
                                 BillingContract__c contract = contractMap.get(contractId);
                                 contract.CurrentPaymentPlanType__c =  mapOfPaymentPlanName2PaymentPlanId.get(objBankAccountAction.Parameters__c);
                                 updatedContractMap.put(contract.Id,contract);
                                 objBankAccountAction.Status__c = PyBt_Constants.BANK_ACCOUNT_ACTION_PROCESSED;
                                 updatedBankAccountActionStatusList.add(objBankAccountAction);
                             }
                }
                if(!updatedBankAccountActionStatusList.isEmpty()){
                    updatedBankAccountActionStatusList = (List<BankAccountAction__c>) GlUt_FieldSecurity.cleanseFields(updatedBankAccountActionStatusList, false);
                    Database.update(updatedBankAccountActionStatusList); // update the bank account action record status
                }
                if(updatedContractMap.values().size() > 0){
                    Database.update((List<BillingContract__c>) GlUt_FieldSecurity.cleanseFields(updatedContractMap.values(), false)); // update the contract current payment plan type with new payment plan type.
                    PpUt_PaymentPlanUtilities.calculatePlans(updatedContractMap.values()); // Call utility in order to create Payment plan and instalments
                }
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