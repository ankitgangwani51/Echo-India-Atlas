/******************************************************************************
@author         Echo: Swati Mathur
@date           22 Aug 2018
@description    Handler for Payment Plan Type trigger

*******************************************************************************/
public with sharing class GlUt_PaymentPlanTypeHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_PaymentPlanTypeHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
        
    /******************************************************************************
	@author         Echo: Swati Mathur
    @date           22 Aug 2018
	@param          GlUt_TriggerHandlerObj - inputParam
	@description    This method handles the initial invocation of the trigger
	*******************************************************************************/
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {        
               
        try {                     
            
            if (inputParam.isInsert && inputParam.isBefore) {
                checkDefaultPaymentPlanExists(null, null, inputParam.newList);
            }
            
            if (inputParam.isUpdate && inputParam.isBefore) {
                checkDefaultPaymentPlanExists(inputParam.oldMap, inputParam.newMap, null);
            }
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        
        finally {            
                       
            // Reset the active function to null in case this class was first in stack
            // this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();
        }
    }

    /******************************************************************************
	@author         Echo: Swati Mathur
    @date           22 Aug 2018
	@param          GlUt_TriggerHandlerObj - inputParam
	@description    This method handles the initial invocation of the trigger
	*******************************************************************************/
    public void checkDefaultPaymentPlanExists(Map<Id,sObject> oldMap, Map<Id, sObject> newMap, List<PaymentPlanType__c>newList) { 

        Boolean SDTrueRecordfound = false;
        PaymentPlanType__c errRecord;
        
        if(oldMap == null && newMap == null ){ //Insert event call 
            for(PaymentPlanType__c ppt: newList){                    
                if(ppt.SystemDefault__c == true ){                        
                    if(SDTrueRecordfound == false){
                        SDTrueRecordfound = true; 
                        errRecord = ppt;
                    }
                    else {// multiple system default records found
                        ppt.addError(System.Label.GlUt_DefaultPPTExists);
                    }                                          
                }
                
            }
        }
        else { //Update event call 
            for(PaymentPlanType__c ppt :(List<PaymentPlanType__c>)newMap.values()) { 
                PaymentPlanType__c oldPpt  = (PaymentPlanType__c)oldMap.get(ppt.Id);
                if(oldPpt.SystemDefault__c != ppt.SystemDefault__c && ppt.SystemDefault__c == true){
                    if(SDTrueRecordfound == false){
                        SDTrueRecordfound = true;    
                        errRecord = ppt;
                    }
                    else {// multiple system default records found
                        ppt.addError(System.Label.GlUt_DefaultPPTExists);
                    }     
                }
            }  
        }       
        
        if(SDTrueRecordfound == true){
            List<PaymentPlanType__c> paymentPlanTypeList = [SELECT Id,                                                         
                                                            SystemDefault__c 
                                                            FROM PaymentPlanType__c 
                                                            WHERE SystemDefault__c = true LIMIT 1];        
            if(paymentPlanTypeList.size() > 0){
                //Default PaymentPlanType already exists
                errRecord.addError(System.Label.GlUt_DefaultPPTExists);
            }  
        }      
    }
}