/******************************************************************************
@author         Neha Rajput
@date           23 Nov 2017
@description    Batch Class For Void Management Process for Processing the Records.
*******************************************************************************/
public with sharing class VmBt_ProcessVMRecords implements Schedulable, Database.Batchable<sObject> {
    
    private final String sQuery;
    private final String sMode;
    
    /******************************************************************************
    @author         Neha Rajput
    @date           23 Nov 2017
    @param			String query, String mode
    @description    Constructor is used to set values in the variables.
    *******************************************************************************/
    public VmBt_ProcessVMRecords(String query, String mode){         
        sQuery = query;
        sMode = mode;
    }
    
    /******************************************************************************
    @author         Neha Rajput
    @date           23 Nov 2017
    @param			SchedulableContext sc
    @description    Method is used to execute the batch class.
    *******************************************************************************/ 
    public void execute(SchedulableContext sc){
        // Schedule the batch class
        Database.executeBatch(this);           
    }
    
    /******************************************************************************
    @author         Echo: Neha Rajput
    @date           23 Nov 2017
    @description    Start method of batch class which collect the batches of records or objects to be passed to execute
    *******************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) { 
        return Database.getQueryLocator(sQuery);
    }
    /******************************************************************************
    @author         Echo: Neha Rajput
    @date           23 Nov 2017
    @description    Execute method of batch class, process each batch of records
    *******************************************************************************/
    public void execute(Database.BatchableContext bc, List<VoidManagementProcess__c> records){                
        UpdateEvaluateField(records); 
    }
    /******************************************************************************
    @author         Echo: Neha Rajput
    @date           23 Nov 2017
    @description    Finish method of batch class.Execute any post-processing operations
    *******************************************************************************/    
    public void finish(Database.BatchableContext bc){
        
    }   
    
    /******************************************************************************
    @author         
    @date          23 Nov 2017   
    @param         List of VoidManagementProcess__c
    @return        Void   
    @description   Method for Update Evaluate Checkbox of VoidManagementProcess__c 
    to TRUE 
    *******************************************************************************/
    private void UpdateEvaluateField(List<VoidManagementProcess__c> records){
        List<VoidManagementProcess__c> UpdatedList = new List<VoidManagementProcess__c>();
        for(VoidManagementProcess__c NewVMP : records ){
            NewVMP.Evaluate__c = true;
            NewVMP.Flag__c = true;
            UpdatedList.add(NewVMP);
        }  
        if(!UpdatedList.isEmpty()){
            UpdatedList = (List<VoidManagementProcess__c>) GlUt_FieldSecurity.cleanseFields(UpdatedList, false);
            update UpdatedList;        
        }
    }
}