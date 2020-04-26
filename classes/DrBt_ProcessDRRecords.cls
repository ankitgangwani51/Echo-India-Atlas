/******************************************************************************
@author         Neha Rajput
@date           24 Nov 2017
@description    Batch Class For Debt Management And Recovery Process
                AT-4891/2 Code Check Marx Changes for FLS INSERT/UPDATE
*******************************************************************************/
global class DrBt_ProcessDRRecords implements Schedulable, Database.Batchable<sObject> {
    
    private final String sQuery;
    private final String sMode; 
    private final Integer iResultLimit;
    /******************************************************************************
    @author         Neha Rajput
    @date           24 Nov 2017
	@param			String query, String mode, Integer resultLimit
    @description    Constructor Method 
    *******************************************************************************/
    global DrBt_ProcessDRRecords(String query, String mode, Integer resultLimit){           
        sQuery = query;
        sMode = mode; 
        iResultLimit = integer.valueOf(resultLimit);
    }
    /******************************************************************************
    @author         Neha Rajput
    @date           24 Nov 2017
	@param			SchedulableContext sc
    @description    excecute method for Schedulable interface
    *******************************************************************************/
    global void execute(SchedulableContext sc){
        // Call Start method...
        Database.executeBatch(this);           
    }
    /******************************************************************************
    @author         Neha Rajput
    @date           24 Nov 2017
	@param			Database.BatchableContext bc
    @description    start method for Batchable interface
    *******************************************************************************/	
    global Database.QueryLocator start(Database.BatchableContext bc) {         
        return Database.getQueryLocator(sQuery);
    }
   /******************************************************************************
    @author         Neha Rajput
    @date           24 Nov 2017
	@param			Database.BatchableContext bc, List<Instalment__c> records
    @description    execute method for Batchable interface
    *******************************************************************************/
    global void execute(Database.BatchableContext bc, List<DebtRecoveryProcess__c> records){ 
        
        List<DebtRecoveryProcess__c> lstNewDebtRecoveryProcess = new List<DebtRecoveryProcess__c>();
        // New Variables Start - AT-4176
        Set<Id> contractIds = new Set<Id>();
        Set<Id> customerIds = new Set<Id>();
        Map<Id, Id> mapofAccountIdByContractId = new  Map<Id, Id>();
        // Create Map to check if the related contract is suppressed
        Map<Id, boolean> mapToCheckIfContractSupressed = new  Map<Id, boolean>();
        // Create Map  to check if the related account is suppressed
        Map<Id, boolean> mapToCheckIfAccountSupressed = new  Map<Id, boolean>();
        // New Variables End - AT-4176 
        System.debug('records size = '+records.size());
        if (sMode == GlUt_Constants.PREDICTMODE)
            updateDebtPredict(records);            
        else{
            //AT-4176 Performance Issue while running Debt Recovery record selection - Added By Dependra - 31-10-2018
            //Check if record list is not empty then creating set of contract ids 
            if(records != null && !records.isEmpty()){
                for(DebtRecoveryProcess__c debtRecoveryProcessObj: records){
                    if(debtRecoveryProcessObj.BillingContract__c != null){
                        contractIds.add(debtRecoveryProcessObj.BillingContract__c);
                    }
                }
            }
           
            //  Check the size of set if size is greater than 0 then query to fetch the suppressed contract.
            if(contractIds.size() > 0){
                List<Suppression__c> supressionList = [SELECT Id,BillingContract__c
                                                       FROM Suppression__c 
                                                       WHERE BillingContract__c  IN:contractIds 
                                                       AND SuppressionStartDate__c <= :Date.today()
                                                       AND (SuppressionEndDate__c = null  OR SuppressionEndDate__c > :Date.today()) 
                                                       AND BillingContract__r.Status__c != :Label.GlAp_ContractStatusInactiveNoDebt
                                                       AND SuppressRecoveryNotice__c = true];  // AT-2340
              
                // Assigning value in Map to check if the related contract is suppressed or not
                if(supressionList != null && !supressionList.isEmpty()){
                    for(Suppression__c objSupression : supressionList){
                        if(!mapToCheckIfContractSupressed.containsKey(objSupression.BillingContract__c)){
                            mapToCheckIfContractSupressed.put(objSupression.BillingContract__c, true);
                        }
                    }
                }  
                // Get all billing contract by suing set of contract ids  and create set of customer ids and map to get account id by passing contract id.
                List<BillingContract__c> billingContractList = [SELECT Id,AccountName__c FROM BillingContract__c 
                                                                WHERE Id IN:contractIds];
                if(billingContractList != null && !billingContractList.isEmpty()){
                    for(BillingContract__c objBiilingContract : billingContractList){
                        if(objBiilingContract.AccountName__c != null){
                            customerIds.add(objBiilingContract.AccountName__c);
                            if(!mapofAccountIdByContractId.containsKey(objBiilingContract.Id)){
                                mapofAccountIdByContractId.put(objBiilingContract.Id, objBiilingContract.AccountName__c);
                            }
                        }
                    }
                }												
            }
            // Check if size of customer id is greater than 0 then fetch suppression list and create map.
            if(customerIds.size() > 0){
                List<Suppression__c> supressionListForAccount =[SELECT Id,Account__c FROM Suppression__c 
                                                                WHERE Account__c IN:customerIds 
                                                                AND Account__c != null  
                                                                AND SuppressionStartDate__c <= :Date.today()
                                                                AND (SuppressionEndDate__c = null 
                                                                     OR SuppressionEndDate__c > :Date.today())
                                                                AND SuppressRecoveryNotice__c = true];  // AT-2340
                if(supressionListForAccount != null && !supressionListForAccount.isEmpty())	{
                    for(Suppression__c supressionObj : supressionListForAccount){
                        if(!mapToCheckIfAccountSupressed.containsKey(supressionObj.Account__c)){
                            mapToCheckIfAccountSupressed.put(supressionObj.Account__c, true);
                        }
                    }
                }											
            }
            // AT-2117, we need to ignore those records that are associated with suppressed Contracts or Accounts.
            for(DebtRecoveryProcess__c objDebtRecoveryProcess: records){
                Boolean isContractSuppressed = false;
                //AT-4176 Performance Issue while running Debt Recovery record selection - Added By Dependra - 31-10-2018
                if(objDebtRecoveryProcess.BillingContract__c != null){
                    if(mapToCheckIfContractSupressed.containsKey(objDebtRecoveryProcess.BillingContract__c)){
                        isContractSuppressed = mapToCheckIfContractSupressed.get(objDebtRecoveryProcess.BillingContract__c);
                        if(!isContractSuppressed){
                            if(mapofAccountIdByContractId.containsKey(objDebtRecoveryProcess.BillingContract__c)){
                                if(mapToCheckIfAccountSupressed.containsKey(mapofAccountIdByContractId.get(objDebtRecoveryProcess.BillingContract__c))){
                                    isContractSuppressed = mapToCheckIfAccountSupressed.get(mapofAccountIdByContractId.get(objDebtRecoveryProcess.BillingContract__c));
                                }   
                            }
                        }
                    }
                    if(!isContractSuppressed){                        
                        lstNewDebtRecoveryProcess.add(objDebtRecoveryProcess); // AT-2117, Process those records which are not associated with Suppressed Contracts or Accounts.
                    }
                }
                else{
                    lstNewDebtRecoveryProcess.add(objDebtRecoveryProcess); // AT-2117, Process those records which are not associated with Suppressed Contracts or Accounts.
                }
                
            }
            if(!lstNewDebtRecoveryProcess.isEmpty()){
                updateDebtEvaluate(lstNewDebtRecoveryProcess);
            }
        }               
    } 
    global void finish(Database.BatchableContext bc){
        
    }
    
    /******************************************************************************
    @author        Neha Rajput 
    @date          24 Nov 2017   
    @param         List of DebtRecoveryProcess__c records
    @return        Void   
    @description   Method for Update Predict for Debt Recovery Checkbox of 
    DebtRecoveryProcess__c to TRUE
    *******************************************************************************/   
    private void updateDebtPredict(List<DebtRecoveryProcess__c> records){
        List<DebtRecoveryProcess__c> updatedDRPList = new List<DebtRecoveryProcess__c>();
        for(DebtRecoveryProcess__c newDRP : records ){
            newDRP.PredictForDebtRecovery__c = true;
            newDRP.Flag__c = true;
            updatedDRPList.add(newDRP);           
        } 
        //AT-4892 Code Check Marx Changes Starts Here.
        if(!updatedDRPList.isEmpty()){
            updatedDRPList = (List<DebtRecoveryProcess__c>) GlUt_FieldSecurity.cleanseFields(updatedDRPList, false);
            Database.update(updatedDRPList);        
        }
        //AT-4892 Code Check Marx Changes Ends Here.
    }
    
    /******************************************************************************
    @author        Neha Rajput  
    @date          24 Nov 2017   
    @param         List of DebtRecoveryProcess__c
    @return        Void   
    @description   Method for Update Evaluate for Debt Recovery Checkbox of 
    DebtRecoveryProcess__c to TRUE 
    *******************************************************************************/
    private void updateDebtEvaluate(List<DebtRecoveryProcess__c> records){
        List<DebtRecoveryProcess__c> updatedDRPList = new List<DebtRecoveryProcess__c>();
        Integer counter = 0;
        if(iResultLimit != null && iResultLimit > 0){
            for(DebtRecoveryProcess__c newDRP : records ){
                if(newDRP.CurrentStage__c != newDRP.PredictedStage__c){
                    newDRP.EvaluateForDebtRecovery__c = true;
                    newDRP.Flag__c = true;
                    updatedDRPList.add(newDRP);
                    counter = counter + 1;                   
                }
                if(counter == iResultLimit)
                    break;                
            }       
        }
        else{
            for(DebtRecoveryProcess__c newDRP : records){
                newDRP.EvaluateForDebtRecovery__c = true;
                newDRP.Flag__c = true;
                updatedDRPList.add(newDRP);                
            }  
        } 
        //AT-4892 Code Check Marx Changes Starts Here.
        if(!updatedDRPList.isEmpty()){
            updatedDRPList = (List<DebtRecoveryProcess__c>) GlUt_FieldSecurity.cleanseFields(updatedDRPList, false);
            Database.update(updatedDRPList); 
        }
        //AT-4892 Code Check Marx Changes Ends Here.
    }
}