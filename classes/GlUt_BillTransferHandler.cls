/***************************************************************************************************
@author         Echo : Dependra Singh
@date           22-Oct-2018
@description    This is helper class used by Bill Transfer object trigger  
@group          TriggerHelper
Revision(s)   
*******************************************************************************************************/
public with sharing class GlUt_BillTransferHandler extends GlUt_TriggerHandlerBase{
    
    private static final String CLASS_NAME = 'GlUt_BillTransferHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    List<BillCalculation__c> billCalculationUpdateList = new List<BillCalculation__c>();
    // Variable declaration
    
    // End variable declaration
    
    /**********************************************************************************************
    @author         Echo: Dependra Singh
    @date           22-Oct-2018
    @param          GlUt_TriggerHandlerObj inputParam
    @return         void
    @description    This method is used to invoke method from trigger
    **********************************************************************************************/
    public override void  MainEntry(GlUt_TriggerHandlerObj inputParam) {
        try {
            if (inputParam.isInsert && inputParam.isBefore) {
                
            }
            if (inputParam.isInsert && inputParam.isAfter) {
                //Calling method to update bill calculation record.
                updateBillCalculationStatus(inputParam.newList);
            }
            if (inputParam.isUpdate && inputParam.isBefore) {
                
            }
            if (inputParam.isUpdate && inputParam.isAfter) {
                
            }  
            if (inputParam.isDelete && inputParam.isBefore) {
                
            }
            if (inputParam.isDelete && inputParam.isAfter) {
                
            }  
        }
        catch (Exception ex) {
            system.debug(DEBUG + 'Line Number: ' + ex.getLineNumber());
            system.debug(DEBUG + 'Error Message: ' + ex.getMessage());
            system.debug(DEBUG + 'Stack Trace: ' + ex.getStackTraceString());
            GlUt_Logger.logException(ex);
        }
        
        finally {   
            // Update Bill Calculation Status
            if(!billCalculationUpdateList.isEmpty()){
                update billCalculationUpdateList;
            }
            //Reset the active function to null in case this class was first in stack
            //this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();
        }
        
    }
    
    /**********************************************************************************************
    @author         Echo: Dependra Singh
    @date           GlUt_BillTransferHandler
    @param          Map<Id, SObject> newlist
    @description    Method is used , when a Bill Transfer is inserted into Salesforce via Heroku Connect, 
					update the associated Bill Calculation record status to ‘Complete’
    **********************************************************************************************/ 
    public void updateBillCalculationStatus(List<SObject> newlist) {
        //Start  Initializing variables
        set<Id> billCalculationIds = new set<Id>();
        //End Initializing variables		   
        
        // Checking if list is not empty   
        if (!newlist.isEmpty()) {
            for (BillTransfer__c billTransferObj : (List<BillTransfer__c>)newlist) {
                if(billTransferObj.BillCalculation__c != null){
                    billCalculationIds.add(billTransferObj.BillCalculation__c);
                }
            }
            // If bill calculaion id size is greater than 0
            if(billCalculationIds.size() >0){
                List<BillCalculation__c> billCalculationList = [SELECT Id, Status__c FROM BillCalculation__c 
                                                                WHERE ID IN: billCalculationIds];
                if(billCalculationList != null && !billCalculationList.isEmpty()){
                    for(BillCalculation__c objBillCalculation : billCalculationList){
                        // Mark status as completed.
                        objBillCalculation.Status__c = GlUt_Constants.COMPLETED;
                        billCalculationUpdateList.add(objBillCalculation);
                    }
                }												
            }
        }
    }
}