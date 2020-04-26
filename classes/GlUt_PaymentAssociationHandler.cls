/******************************************************************************
@author         Neha Rajput 
@date           07 Dec 2018
@description    Handler for Payment Association trigger
@revisions:     
*******************************************************************************/
public with sharing class GlUt_PaymentAssociationHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_PaymenttAssociationHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author         Neha Rajput 
    @date           07 Dec 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    @revision       
    *******************************************************************************/
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {
        try {
            if (inputParam.isInsert && inputParam.isBefore) {
            }
            if (inputParam.isInsert && inputParam.isAfter) {
                createFCRForReturnTransferPayment(inputParam.newlist);
            }
            
            if (inputParam.isUpdate && inputParam.isBefore) {    
               
            }
            
            if (inputParam.isUpdate && inputParam.isAfter) {
                
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
    @author         Neha Rajput 
    @date           07 Dec 2018       
    @param          List<PaymentAssociation__c> listPaymentAssociation
    @description    method to create FCT of return transfer payment
    ******************************************************************************/    
    private void createFCRForReturnTransferPayment(List<PaymentAssociation__c> listPaymentAssociation){
       
        // Map of <Id,Id> , get Original Payment Id by Return Transfer Payment Id .
        Map<Id,Id> returnPayamentWithOriginalPayment = new Map<Id,Id>();
        // Map of <string,Id> , get financial transaction event type id by Name.
        Map<string, Id> mapFTETIdByName = new Map<string, Id>();
        // List of FCR
        List<FinancialControl__c> lstFinancialControl = new List<FinancialControl__c>();
            
        for(PaymentAssociation__c objPaymentAssociation: listPaymentAssociation){
            returnPayamentWithOriginalPayment.put(objPaymentAssociation.TransferredRefundedPayment__c, objPaymentAssociation.OriginalPayment__c);
             
        }
        // List of all TransferredRefundedPayment__c payment with recordtype 'Return Transfer'
        List<Id> lstReturnTransferPayment = new List<Id>();
        for(Payment__c objPayment: [SELECT Id 
                                    FROM Payment__c
                                    WHERE Id IN: returnPayamentWithOriginalPayment.keySet()
                                    AND RecordType.Name =: FcUt_Constants.RETURNTRANSFER
                                    AND BillingContract__c != null]){
        	lstReturnTransferPayment.add(objPayment.Id);                                       
        }
        
        if(!lstReturnTransferPayment.isEmpty()){
            // remove non Return Transfer payment from returnPayamentWithOriginalPayment Map
            for(Id returntransferId: returnPayamentWithOriginalPayment.keySet()){
                if(!lstReturnTransferPayment.contains(returntransferId))
                    returnPayamentWithOriginalPayment.remove(returntransferId);
            }
            
            // Querying list of financial transaction event type where name in Payments record types  and Object is payemnt.
            for(FinancialTransactionEventType__c objFTET: [SELECT Id, Name, Name__c, Object__c,Category__c 
                                                           FROM FinancialTransactionEventType__c 
                                                           WHERE Name__c =: FcUt_Constants.RETURNTRANSFER 
                                                           AND Object__c =: FcUt_Constants.PAYMENT LIMIT 1]){
                if(!mapFTETIdByName.containsKey(objFTET.Name__c)){
                    mapFTETIdByName.put(objFTET.Name__c, objFTET.Id);
                }
            }   
           
            // Date variable to store payment created date.
            Date paymentCreatedDate;
            for(Payment__c objPayment : [SELECT Id, CreatedDate 
                                         FROM Payment__c 
                                         WHERE Id IN: returnPayamentWithOriginalPayment.keySet()]){            
                paymentCreatedDate = date.newinstance(objPayment.CreatedDate.year(), objPayment.CreatedDate.month(), objPayment.CreatedDate.day());
            }       
            //get Actual and Effective period
            Period objPeriod = [SELECT Id,FiscalYearSettings.Name,Number 
                                FROM Period 
                                WHERE Type =: FcUt_Constants.MONTH
                                AND StartDate <=: paymentCreatedDate 
                                AND EndDate >=: paymentCreatedDate];
            
            // Original Payment List
            Map<Id,Payment__c> originalPaymentMap = new Map<Id,Payment__c>([SELECT Id,BillAmountUnallocated__c
                                                                            FROM Payment__c
                                                                            WHERE Id IN: returnPayamentWithOriginalPayment.values()]);
            
            for(Id objReturnTransfer: returnPayamentWithOriginalPayment.keySet()){
                Payment__c objPayment = new Payment__c();
                objPayment = originalPaymentMap.get(returnPayamentWithOriginalPayment.get(objReturnTransfer));
                
                // FCR record
                FinancialControl__c objFinancialControl = new FinancialControl__c(); 
                objFinancialControl.Payment__c = objReturnTransfer;
                
                if(!mapFTETIdByName.isEmpty())
                    objFinancialControl.FinancialTransactionEventType__c = mapFTETIdByName.get(FcUt_Constants.RETURNTRANSFER); 
                // if Bill Amount Unallocated exist on original Payment
                if(objPayment.BillAmountUnallocated__c != null && objPayment.BillAmountUnallocated__c > 0)
                    objFinancialControl.Amount__c = -(objPayment.BillAmountUnallocated__c); 
                else
                    objFinancialControl.Amount__c = 0;
                
                objFinancialControl.ActualPeriod__c = String.valueOf(objPeriod.Number);
                objFinancialControl.ActualPeriodId__c = objPeriod.Id;
                objFinancialControl.ActualYear__c = objPeriod.FiscalYearSettings.Name; 
                objFinancialControl.EffectivePeriod__c = String.valueOf(objPeriod.Number);
                objFinancialControl.EffectivePeriodId__c = objPeriod.Id;
                objFinancialControl.EffectiveYear__c = objPeriod.FiscalYearSettings.Name; 
               
                lstFinancialControl.add(objFinancialControl);            
            }
           
            // Checking if list is not empty then inserting.  
            if(!lstFinancialControl.isEmpty()){
                lstFinancialControl = (List<FinancialControl__c>) GlUt_FieldSecurity.cleanseFields(lstFinancialControl, false);
                insert lstFinancialControl;
            } 
        }
    }
        
        
  

}