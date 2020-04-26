/******************************************************************************
@author         Swati Mathur
@date           12 Dec 2017
@description    Scheduled Batch Class For Debt Recovery Initiation Process
@Revision       Swati M - 08 Feb 2018 -- replaced Ledger__c object with Balance__c    
*******************************************************************************/
global class DrBt_ProcessInstalments implements Schedulable, Database.Batchable<sObject> {
    
    /******************************************************************************
    @author         Sudhir Kumar
    @date           10 Oct 2018
	@param			SchedulableContext sc
    @description    excecute method for Schedulable interface
					AT-3978 - Dynamic SOQL for DrBt_ProcessInstalments - Added Header (Security Review)
    *******************************************************************************/
    global void execute(SchedulableContext sc){         
        Database.executeBatch(this,200);           
    }    
    /******************************************************************************
    @author         Sudhir Kumar
    @date           10 Oct 2018
	@param			Database.BatchableContext bc
    @description    start method for Batchable interface
					AT-3978 - Dynamic SOQL for DrBt_ProcessInstalments - Added Header (Security Review)
							- Replaced Dynamic SOQL with static SOQL and using getQuery of getQueryLocator.
    *******************************************************************************/	
    global Database.QueryLocator start(Database.BatchableContext bc){  
        /*
        String payPlanId = 'a051v00000UTcLvAAL';
        // Query to get the instalments which are due on or before today and currently not assosiated with any Debt Recovery Instalment record        
        String sQuery = 'SELECT Id, ' + 
            GlUt_APIConstantsInstalment.INSTALMENTAMOUNTDUEAPINAME 	+ ',' + 
            GlUt_APIConstantsInstalment.INSTALMENTDUEDATEAPINAME 	+ ',' +  
            GlUt_APIConstantsPaymentPlan.PAYMENTPLANRELAPINAME + '.' + GlUt_APIConstantsPaymentPlan.CONTRACTORDERAPINAME + ',' + 
            GlUt_APIConstantsPaymentPlan.PAYMENTPLANRELAPINAME + '.' + GlUt_APIConstantsPaymentPlan.ACTIVEAPINAME + ',' + 
            GlUt_APIConstantsPaymentPlan.PAYMENTPLANRELAPINAME + '.' + GlUt_APIConstantsPaymentPlan.CONTRACTORDERRELAPINAME + '.' + GlUt_APIConstantsDebtRecoveryProcess.DEBTRECOVERYPROFILEAPINAME +
            ' FROM ' + GlUt_APIConstantsInstalment.INSTALMENTAPINAME + 
            ' WHERE ' + GlUt_APIConstantsInstalment.INSTALMENTDUEDATEAPINAME + ' <= Today AND ' + GlUt_APIConstantsInstalment.DEBTRECOVERYINSTALMENTCOUNT + ' = 0' + 
            ' AND ' + GlUt_APIConstantsInstalment.PAYMENTPLANAPINAME + ' = ' + '\'' + payPlanId + '\'';                
        system.debug('sQuery===='+sQuery);
		*/
        //Sudhir - AT-3978: Dynamic SOQL for DrBt_ProcessInstalments - Replaced Dynamic SOQL with static SOQL and using getQuery().
        return Database.getQueryLocator([SELECT Id, InstalmentAmountDue__c, InstalmentDueDate__c, PaymentPlan__r.BillingContract__c, PaymentPlan__r.Active__c,
                                                 PaymentPlan__r.BillingContract__r.DebtRecoveryProfile__c 
                                         		 FROM Instalment__c 
                                                 WHERE InstalmentDueDate__c <= TODAY AND DebtRecoveryInstalments__c = 0]);
    }    
    
    
    /******************************************************************************
    @author         Sudhir Kumar
    @date           10 Oct 2018
	@param			Database.BatchableContext bc, List<Instalment__c> records
    @description    execute method for Batchable interface
					AT-3978 - Dynamic SOQL for DrBt_ProcessInstalments - Added Header (Security Review)
							- Replaced Dynamic SOQL with static SOQL and using getQuery of getQueryLocator.
					// This execute method will find the Debt Recovery Process and Ledger Records for the Contracts assosiated with each instalment and
    				// will call AddToDebtRecovery class to process the instalments 
    *******************************************************************************/
    global void execute(Database.BatchableContext bc, List<Instalment__c> records){ 
        System.debug('records======='+records);
        // Map of Contract Id to Instalment Object       
        Map<Id,List<Instalment__c>> instalmentMap = new Map<Id,List<Instalment__c>>();        
        for(Instalment__c instObj : records){
            if(instObj.PaymentPlan__r.Active__c){
                if (!instalmentMap.containsKey(instObj.PaymentPlan__r.BillingContract__c)){  // AT-3174 
                    instalmentMap.put(instObj.PaymentPlan__r.BillingContract__c, new List<Instalment__c>());     // AT-3174             
                }
                instalmentMap.get(instObj.PaymentPlan__r.BillingContract__c).add(instObj);  // AT-3174 
            }
        }         
        
        //get DRP record of Latest Payment Due Date for assosiated Contract        
        List<DebtRecoveryProcess__c> dRPList = [SELECT ID, BillingContract__c,TotalAmountDue__c
                                                FROM DebtRecoveryProcess__c 
                                                WHERE BillingContract__c IN :instalmentMap.keySet() AND ProcessComplete__c = FALSE 
                                                ORDER BY PaymentDueDate__c ASC];        
        // Map of Assosiated Contract Id to DRP Id        
        Map<Id,DebtRecoveryProcess__c> dRPMap = new Map<Id,DebtRecoveryProcess__c>();         
        for(DebtRecoveryProcess__c dRPObj : dRPList){            
            dRPMap.put(dRPObj.BillingContract__c, dRPObj);            
        }
        
        //get Balance from assosiated Contract 
        List<BillingContract__c> contractList = [SELECT ID, Balance__c FROM BillingContract__c 
                                          WHERE Id IN :instalmentMap.keySet()];        
        // Map of Contract Id to Balance Id
        Map<Id,Id> balanceMap = new Map<Id,Id>();
        for(BillingContract__c conObj : contractList){
            balanceMap.put(conObj.Id,conObj.Balance__c);
        }
        // Call to AddToDebtRecovery class to process the instalments which are Due
        DrUt_AddToDebtRecovery.processBatches(instalmentMap,dRPMap,balanceMap);
    }    
    /******************************************************************************
    @author         Sudhir Kumar
    @date           10 Oct 2018
	@param			Database.BatchableContext bc
    @description    execute method for Batchable interface
					AT-3978 - Dynamic SOQL for DrBt_ProcessInstalments - Added Header (Security Review)
    *******************************************************************************/
    global void finish(Database.BatchableContext bc){
        
    }
    
}