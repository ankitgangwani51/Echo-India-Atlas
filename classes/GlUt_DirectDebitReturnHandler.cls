/******************************************************************************
@author         Echo: Amit K.
@date           20 June 2018
@description    Handler for Instalment trigger
*******************************************************************************/
public with sharing class GlUt_DirectDebitReturnHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_DirectDebitReturnHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    List<DirectDebitReturn__c> updateDirectDebitReturnList;
    
    /******************************************************************************
    @author         Echo: Amit K.
    @date           20 June 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {
        try {            
            if (inputParam.isInsert && inputParam.isBefore) {
                updateDirectDebitReturn(inputParam.newlist);
            }
            if (inputParam.isUpdate && inputParam.isBefore) {
                // Allocate Newely Created Payment to DDR.
                updateDirectDebitReturn(inputParam.newlist);
            }
            
            if (inputParam.isDelete && inputParam.isBefore) {
            }
            
            if (inputParam.isDelete && inputParam.isAfter) {
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
    @author         Echo: Amit K.
    @date           20 June 2018
    @param          List<SObject> newlist - trigger.new
    @param          Map<Id, SObject> oldMap - trigger.oldMap
    @description    Update Direct Debit Return records from Bank DDR import File on the basis of Status.
    *******************************************************************************/
    private void updateDirectDebitReturn(List<SObject> newlist) {
        updateDirectDebitReturnList = new List<DirectDebitReturn__c>(); 
        Set<Id> contractIds = new Set<Id>(); // Set of Contract Ids associated with DD Return
        for(DirectDebitReturn__c ddr : (List<DirectDebitReturn__c>) newlist) {
            if(ddr.BillingContract__c != null && ddr.Status__c != PyBt_Constants.BANK_ACCOUNT_ACTION_PROCESSED) {
                contractIds.add(ddr.BillingContract__c);
            }
        }
        if(!contractIds.isEmpty()){
            // Map of ContractId having Latest Direct Debit Request with Status = Confirmed
            Map<Id,DirectDebitRequest__c> mapOfContractId2DDR = new Map<Id,DirectDebitRequest__c>();
            Map<Id,Id> mapOfDDRId2PaymentId = new Map<Id,Id>();
            List<DirectDebitRequest__c> ddrequestList = [SELECT Id,
                                                         BillingContract__c,
                                                         Instalment__c,
                                                         RequestDate__c 
                                                         FROM DirectDebitRequest__c 
                                                         WHERE BillingContract__c IN:contractIds AND 
                                                         Status__c =: PyBt_Constants.DIRECT_DEBIT_REQUEST_STATUS_CONFIRMED Order 
                                                         BY RequestDate__c Desc];
            for(DirectDebitRequest__c ddrequest : ddrequestList){
                if(!mapOfContractId2DDR.containsKey(ddrequest.BillingContract__c))
                    mapOfContractId2DDR.put(ddrequest.BillingContract__c,ddrequest); // Map of Contact having Latest Direct Debit Request.
            }
            if(mapOfContractId2DDR.values().size() > 0){
                List<Payment__c> paymentList = [SELECT Id,
                                                DirectDebitRequest__c
                                                FROM Payment__c WHERE DirectDebitRequest__c IN:mapOfContractId2DDR.values()]; // Fetch the payment associated with latest Direct Debit Request.
                
                for(Payment__c objPayment: paymentList){
                    mapOfDDRId2PaymentId.put(objPayment.DirectDebitRequest__c,objPayment.Id);// Map of Latest Direct Debit Request having Payment id.
                }
            }
            for(DirectDebitReturn__c ddreturn : (List<DirectDebitReturn__c>) newlist){
                //If Contract Ids associated with DD Return and status not processed
                if(ddreturn.BillingContract__c != null && ddreturn.Status__c != PyBt_Constants.BANK_ACCOUNT_ACTION_PROCESSED) {
                    //If any of below condition true i.e. No Direct Debit Request OR Instalment OR Payment associated with Direct Debit return record.
                    if(ddreturn.DirectDebitRequest__c == null || ddreturn.Instalment__c == null || ddreturn.Payment__c == null){

                        //Stamp the latest Direct Debit request to Direct Debit return record on the basis of contract ID.
                        if(!mapOfContractId2DDR.isEmpty() && mapOfContractId2DDR.containsKey(ddreturn.BillingContract__c)){
                            DirectDebitRequest__c ddr = mapOfContractId2DDR.get(ddreturn.BillingContract__c);
                            ddreturn.Payment__c = mapOfDDRId2PaymentId.get(ddr.Id);
                            ddreturn.Instalment__c = mapOfContractId2DDR.get(ddreturn.BillingContract__c).Instalment__c;
                            ddreturn.DirectDebitRequest__c = mapOfContractId2DDR.get(ddreturn.BillingContract__c).Id;
                            
                        }else{
                            ddreturn.Status__c = PyBt_Constants.BANK_ACCOUNT_ACTION_ERROR; //Change the Status to Error If Latest DD Request doesn't exist on the basis Contract Id.
                        }
                        //updateDirectDebitReturnList.add(ddreturn); // Set the Direct Debit Return record updated values  before Insert or Update activity.
                    }
                }
            }
        }
    }

}