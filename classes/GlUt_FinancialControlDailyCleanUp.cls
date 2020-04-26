/******************************************************************************
@author         Echo: Dependra Singh
@date           19 Mar 2018
@description    Scheduled Batch Class For Financial Control History(Total) records clean up.
*******************************************************************************/
global class GlUt_FinancialControlDailyCleanUp implements Schedulable, Database.Batchable<sObject> {
    
    /******************************************************************************
    @author         Sudhir Kumar
    @date           10 Oct 2018
	@param			SchedulableContext sc
    @description    excecute method for Schedulable interface
					AT-3983 - Dynamic SOQL for GlUt_FinancialControlDailyCleanUp - Added Header (Security Review)
    *******************************************************************************/	
    global void execute(SchedulableContext sc){         
        Database.executeBatch(this,200);           
    }    
    
    /******************************************************************************
    @author         Sudhir Kumar
    @date           10 Oct 2018
	@param			Database.BatchableContext bc
    @description    start method for Batchable interface
					AT-3983 - Dynamic SOQL for GlUt_FinancialControlDailyCleanUp - Added Header (Security Review)
							- Replaced Dynamic SOQL with static SOQL and using getQuery()
    *******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc){         
        // Query all Financial Control History records where Daily = true 
        /*
        String sQuery = 'SELECT Id,' +  + GlUt_APIConstantsFinancialControlTotal.DAILYRECORDAPINAME + ' FROM ' + GlUt_APIConstantsFinancialControlTotal.FINANCIALCONTROLAPINAME + 
            ' WHERE ' + GlUt_APIConstantsFinancialControlTotal.DAILYRECORDAPINAME + ' = TRUE';
        */
        //String sQuery = Database.getQueryLocator([SELECT Id, DailyRecord__c FROM FinancialControlTotal__c WHERE DailyRecord__c = true]).getQuery() ; // Sudhir: AT-3983
        return Database.getQueryLocator([SELECT Id, DailyRecord__c FROM FinancialControlTotal__c WHERE DailyRecord__c = true]) ; // Sudhir: AT-3983
    }    

      
    /******************************************************************************
    @author         Sudhir Kumar
    @date           10 Oct 2018
	@param			Database.BatchableContext bc, List<DebtRecoveryAction__c> scope
    @description    execute method for Batchable interface - delete the scope records of this batch
					AT-3983 - Dynamic SOQL for GlUt_FinancialControlDailyCleanUp - Added Header (Security Review)
                    AT-4890 - CRUD Delete for GlUt_FinancialControlDailyCleanUp - Added Cleanse (Code Check Marx Security Review)
    *******************************************************************************/  
    global void execute(Database.BatchableContext bc, List<Instalment__c> records){
        /*AT-4890 Code Check marx Changes Starts here*/
        if(GlUt_ObjectSecurity.isObjectPermission(records,true,false,false,false,false)){ 
            records = (List<Instalment__c>) GlUt_FieldSecurity.cleanseFields(records, false);
            /*AT-4890 Code Check marx Changes Ends here*/
            delete records; 
        }
    }    
	
    /******************************************************************************
    @author         Sudhir Kumar
    @date           10 Oct 2018
	@param			Database.BatchableContext bc
    @description    finish method for Batchable interface
					AT-3983 - Dynamic SOQL for GlUt_FinancialControlDailyCleanUp - Added Header (Security Review)
    *******************************************************************************/
    global void finish(Database.BatchableContext bc){
    
    }   
}