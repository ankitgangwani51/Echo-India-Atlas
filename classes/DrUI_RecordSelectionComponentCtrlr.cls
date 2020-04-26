/************************************************************************************************************
@author         Echo : Ankit Gangwani
@date           25-Nov-2017
@description:   This class is used to set the dynamic query for Record Selection (Debt) and schedule the batch class 
on the basis of CRON Trigger which comes from the helper class
@revision	  :	Echo: Sudhir Kumar - AT-3995: Naming Convention for DrUI_RecordSelectionComponent (Security Review)
								   - Updated controller name from DrUI_RecordSelectionCtrlr to DrUI_RecordSelectionComponentCtrlr
**************************************************************************************************************/
public with sharing class DrUI_RecordSelectionComponentCtrlr {
    
    /**********************************************************************************************
    @author      : Echo : Ankit Gangwani
    @date        : 25-Nov-2017
    @return      : Boolean
    @param       : DebtRecoveryProfile, CurrentStage, CurrentStageDateTime, ResultLimit, CRON Expression and Report Type(Eg.. Immediate, Daily, Weekly etc.)
    @description : This method is used to passes the dynamic query to the batch class with mode ("Evaluate or Predict")
    **********************************************************************************************/
    @AuraEnabled
    public static boolean callingBatchOrSchedule(String debtRecoveryProfile, String currentStage, String currentStageDateTime, 
                                                 Decimal totatAmountDue, Integer resultLimit, String cronTrigger, String reportType, String sMode){
        
        String sQuery;        
        Boolean isError = false;      
        if(sMode == 'predict'){
            
            sQuery = 'SELECT ' + GlUt_APIConstantsDebtRecoveryProcess.PREDICTFORDEBTRECOVERYAPINAME + ' FROM ' + GlUt_APIConstantsDebtRecoveryProcess.DEBTRECOVERYPROCESSAPINAME + ' WHERE Id != null';      
                        
            if(debtRecoveryProfile != null && debtRecoveryProfile != ''){
                sQuery = sQuery + ' AND ' + GlUt_APIConstantsDebtRecoveryProcess.DEBTRECOVERYPROFILEAPINAME + ' = \'' + debtRecoveryProfile + '\'';
            }
            
            if(currentStage != null && currentStage != ''){
                sQuery = sQuery + ' AND ' + GlUt_APIConstantsDebtRecoveryProcess.CURRENTSTAGEAPINAME + ' = \'' + currentStage + '\'';
            } 
            
            if(currentStageDateTime != null && currentStageDateTime != ''){
                
                Date currentStageDate = date.valueOf(currentStageDateTime);
                Datetime finalDateTime = Datetime.newInstance(currentStageDate,Time.newInstance(23, 59, 59,0)); 
                string dateTimeFormat = finalDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
                sQuery = sQuery + ' AND ' + GlUt_APIConstantsDebtRecoveryProcess.CURRENTSTAGEDATETIMEAPINAME + ' <=' + dateTimeFormat;                
            }
            
            if(totatAmountDue != null ){
                sQuery = sQuery + ' AND ' + GlUt_APIConstantsDebtRecoveryProcess.TOTALAMOUNTDUEAPINAME + ' >= ' + totatAmountDue; 
            }            
            else{
                sQuery = sQuery + ' AND ' + GlUt_APIConstantsDebtRecoveryProcess.TOTALAMOUNTDUEAPINAME + ' > ' + 0; //AT-3427 , Added to include this is core 8 build
            }
            
            DrBt_ProcessDRRecords myBatchObject = new DrBt_ProcessDRRecords(sQuery,sMode, 0);
            Id batchId = Database.executeBatch(myBatchObject);
            return isError;
        }
        else{ 
            
            if(resultLimit != null && integer.valueOf(resultLimit) > 0) {       
                
                sQuery = 'SELECT ' + GlUt_APIConstantsDebtRecoveryProcess.EVALUATEFORDEBTRECOVERYAPINAME + ','
                    + GlUt_APIConstantsDebtRecoveryProcess.CURRENTSTAGEAPINAME + ',' 
                    + GlUt_APIConstantsDebtRecoveryProcess.PREDICTSTAGEAPINAME + ',' 
                    + GlUt_APIConstantsContracts.CONTRACTAPINAME
                    + ' FROM ' + GlUt_APIConstantsDebtRecoveryProcess.DEBTRECOVERYPROCESSAPINAME + ' WHERE Id != null AND ' 
                    + '(' + GlUt_APIConstantsDebtRecoveryProcess.PREDICTSTAGEAPINAME + ' != null OR ' 
                    + GlUt_APIConstantsDebtRecoveryProcess.PREDICTSTAGEAPINAME + ' != \' \')';
            }
            else
                sQuery = 'SELECT ' + GlUt_APIConstantsDebtRecoveryProcess.EVALUATEFORDEBTRECOVERYAPINAME + ',' 
                + GlUt_APIConstantsContracts.CONTRACTAPINAME 
                + ' FROM ' + GlUt_APIConstantsDebtRecoveryProcess.DEBTRECOVERYPROCESSAPINAME 
                + ' WHERE Id != null'; 
            
            String jobIDCheck = 'Debt';
            
            System.debug('sQuery = '+sQuery);
            
            if(debtRecoveryProfile != null && debtRecoveryProfile != ''){
                sQuery = sQuery + ' AND ' + GlUt_APIConstantsDebtRecoveryProcess.DEBTRECOVERYPROFILEAPINAME + ' = \'' + debtRecoveryProfile + '\'';
                jobIDCheck = jobIDCheck + '-' + debtRecoveryProfile;
            } 
            
            if(currentStage != null && currentStage != ''){
                sQuery = sQuery + ' AND ' + GlUt_APIConstantsDebtRecoveryProcess.CURRENTSTAGEAPINAME + ' = \'' + currentStage + '\'';
                jobIDCheck = jobIDCheck + '-' + currentStage;
            }        
            
            if(currentStageDateTime != null && currentStageDateTime != ''){
                Date currentStageDate = date.valueOf(currentStageDateTime);
                Datetime finalDateTime = Datetime.newInstance(currentStageDate,Time.newInstance(23, 59, 59,0)); 
                string dateTimeFormat = finalDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
                sQuery = sQuery + ' AND ' + GlUt_APIConstantsDebtRecoveryProcess.CURRENTSTAGEDATETIMEAPINAME + ' <=' + dateTimeFormat;                         
            }
            
            if(totatAmountDue != null ){
                sQuery = sQuery + ' AND ' + GlUt_APIConstantsDebtRecoveryProcess.TOTALAMOUNTDUEAPINAME + ' >= ' + totatAmountDue; 
            }
            else{
                sQuery = sQuery + ' AND ' + GlUt_APIConstantsDebtRecoveryProcess.TOTALAMOUNTDUEAPINAME + ' > ' + 0; //AT-3427 , Added to include this is core 8 build
            }
                        
            jobIdCheck = jobIdCheck + '-' + reportType;       
            
            system.debug(' executing myBatchObject ' + 'sQuery ' +  sQuery  + 'sMode ' + sMode +   'resultLimit' +  resultLimit );
            
            DrBt_ProcessDRRecords myBatchObject = new DrBt_ProcessDRRecords(sQuery,sMode, resultLimit);
          
            if (reportType == 'immediate'){
                Id batchId = Database.executeBatch(myBatchObject);
            }
            else{
                List<CronTrigger> cronList = [SELECT CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name =:jobIDCheck];
                if (cronList.size() == 0){
                    String jobID = System.schedule(jobIDCheck, cronTrigger, myBatchObject);                           
                    isError = false;
                }
                else{
                    isError = true;
                }
            }                
            
            return isError;
        }
    }
}