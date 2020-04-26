/******************************************************************************
@author         Echo: Patrick Dixon
@date           07 Feb 2018
@description    Handler for Payment Plan trigger
@Revisions - 18-Apr-2018 Tarun , AT-2267 , To add a check of null while ending old PP's 
As if PP is created via Cust move , the end date is blank as it has an Yearly plan.
@Revisions - 18-Apr-2018 Tarun , AT-2267 , To delete PP created on same day.
@Revisions - 19-Apr-2018 Tarun , AT-2266 , Removed End Date reference, Made old PP Active = False .
@Revisions - 27-Apr-2018 Tarun , AT-2267 , To delete PP created on same day with in 90 min.
@Revisions - 27-Apr-2018 Tarun , AT-2481 , To add Billing Event record whenever PP is inserted.
@Revisions - 21-Jun-2018 Swati , AT-2946 , To update addBillingEventToContract method.
@Revisions - 26/07/18 , Tarun, AT-2295 , commenting code to avoid deleting duplicate PP
@Revisions - 22/08/18 , Tarun, AT-3427 
@Revisions - Fixed cleanse issue(innser query) while updating replacedPaymentPlanMap
*******************************************************************************/
public with sharing class GlUt_PaymentPlanHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_PaymentPlanHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    // Maps of the related records that will be updated by this trigger
    Map<Id, PaymentPlan__c> replacedPaymentPlanMap;
    //List<PaymentPlan__c> deletePaymentPlanOnSameDate; //AT-2295
    List<BillingContract__c> contractListToUpdate;
    List<BillEvent__c> billEventListToUpdate;
    List<PDFRequest__c> PDFRequestListToInsert; // -- AT-2946 
    Map<Id, DebtRecoveryInstalment__c> updateDebtRecoveryInstalment;
    Map<Id, DebtRecoveryProcess__c> updateDebtRecoveryProcess;
    
    /******************************************************************************
	@author         Echo: Patrick Dixon
	@date           07 Feb 2018
	@param          GlUt_TriggerHandlerObj - inputParam
	@description    This method handles the initial invocation of the trigger
	*******************************************************************************/
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {
        
        // initialise related records maps
        replacedPaymentPlanMap = new Map<Id, PaymentPlan__c>();
        //deletePaymentPlanOnSameDate = new List<PaymentPlan__c>(); //AT-2295
        contractListToUpdate = new List<BillingContract__c>();
        billEventListToUpdate = new List<BillEvent__c>();
        PDFRequestListToInsert =new List<PDFRequest__c>(); // -- AT-2946 
        
        updateDebtRecoveryInstalment = new Map<Id, DebtRecoveryInstalment__c>();
        updateDebtRecoveryProcess = new Map<Id, DebtRecoveryProcess__c>();
        
        try {
           
            // TO-DO Logger.Push('MainEntry', 'GlUt_AccountHandler');
            
            if (inputParam.isInsert && inputParam.isAfter) {
                // end any payment plans that are being replaced
                endActivePaymentPlans(inputParam.newMap);
                updatePaymentPlanTypeOnContract(inputParam.newMap,null);
                updatePaymentUnAllocAmount(inputParam.newMap);
                addBillingEventToContract(inputParam.newMap); // AT-2481
            }
            
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        
        finally {
            // update the related records
            if (!replacedPaymentPlanMap.isEmpty()) {
                List<PaymentPlan__c> lstPaymentPlanToUpdate = new List<PaymentPlan__c>();
                for(PaymentPlan__c objPlan : replacedPaymentPlanMap.values()){
                    PaymentPlan__c objPlanNew = new PaymentPlan__c();
                    objPlanNew.Id = objPlan.Id;
                    objPlanNew.Active__c = false;
                    if(DrUt_ChangePaymentPlan.isAutoCancelled)
                        objPlanNew.AutoCancelledDate__c = Date.today();
                    
                    lstPaymentPlanToUpdate.add(objPlanNew);
                }
                lstPaymentPlanToUpdate = (List<PaymentPlan__c>) GlUt_FieldSecurity.cleanseFields(lstPaymentPlanToUpdate, false);
                update lstPaymentPlanToUpdate;
            }
            
            if(updateDebtRecoveryInstalment != null && !updateDebtRecoveryInstalment.isEmpty()){
                List<DebtRecoveryInstalment__c> lstDebtRecInstalmentToUpdate = (List<DebtRecoveryInstalment__c>) GlUt_FieldSecurity.cleanseFields(updateDebtRecoveryInstalment.values(), false);
                update lstDebtRecInstalmentToUpdate;
            }
            
            if(updateDebtRecoveryProcess!= null && !updateDebtRecoveryProcess.isEmpty()){
                List<DebtRecoveryProcess__c> lstDebtRecProcessToUpdate = (List<DebtRecoveryProcess__c>) GlUt_FieldSecurity.cleanseFields(updateDebtRecoveryProcess.values(), false);
                update lstDebtRecProcessToUpdate;
            }
            
            //AT-2295 Starts Here
            // Delete the related records
            /*if (!deletePaymentPlanOnSameDate.isEmpty()) {
                delete deletePaymentPlanOnSameDate;
            }*/
            //AT-2295 Ends Here
            
            if(!contractListToUpdate.isEmpty()){
                contractListToUpdate = (List<BillingContract__c>) GlUt_FieldSecurity.cleanseFields(contractListToUpdate, false);
                update contractListToUpdate;
            }
            
            if(!billEventListToUpdate.isEmpty()){
                billEventListToUpdate = (List<BillEvent__c>) GlUt_FieldSecurity.cleanseFields(billEventListToUpdate, false);
                insert billEventListToUpdate;
            }
            // -- AT-2946 
            if(!PDFRequestListToInsert.isEmpty()){
                PDFRequestListToInsert = (List<PDFRequest__c>) GlUt_FieldSecurity.cleanseFields(PDFRequestListToInsert, false);
                insert PDFRequestListToInsert;
            }
            
            // Reset the active function to null in case this class was first in stack
            // this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();
        }
    }    
    
    /******************************************************************************
	@author         Echo: Patrick Dixon
	@date           07 Feb 2018
	@param          Map<Id, SObject> - objectMap
	@description    ends any payment plans that are being replaced by updating the end date
	@Revisions - 	18-Apr-2018 Tarun , AT-2267 ,  Added check of null for end date while ending PP
	Added logic to delete PP created on same day.
					26/07/18 , Tarun, AT-2295 , commenting code to avoid deleting duplicate PP
					20/08/18 , Tarun , AT-3427 , To deactivate Debt Recovery Instalment 
	*******************************************************************************/
    public void endActivePaymentPlans(Map<Id, SObject> objectMap) {
        
        Set<Id> setInActiveInstalmentIds = new Set<Id>();
        Set<Id> contractIdForDebtRecProcess = new Set<Id>();
        Set<Id> contractIds = new Set<Id>();
        // build a list of the related contract Ids
        for (PaymentPlan__c paymentPlan : (List<PaymentPlan__c>)objectMap.values()) {
            contractIds.add(paymentPlan.BillingContract__c);//AT-3174
        }
        
        List<PaymentPlan__c> listPaymentPlan = [SELECT Id,
                                                (SELECT Id FROM Instalments__r) ,
                                                Active__c,
                                                AutoCancelledDate__c, //AT-4910, Ankit, 24/01/2018
                                                BillingContract__c,BillingContract__r.PreventRecoveryReset__c,
                                                PaymentPlanType__c,PaymentPlanType__r.ResetDebtRecovery__c
                                                FROM PaymentPlan__c
                                                WHERE BillingContract__c in :contractIds];
        
        if(!listPaymentPlan.isEmpty()){            
            for(PaymentPlan__c objPayPlan : listPaymentPlan){
                
                if(!objectMap.containsKey(objPayPlan.Id)){
                    
                    if(objPayPlan.Active__c == true){
                        objPayPlan.Active__c = false;
                        //AT-4910, Ankit, 24/01/2018
                        if(DrUt_ChangePaymentPlan.isAutoCancelled)
                            objPayPlan.AutoCancelledDate__c = Date.today();
                        replacedPaymentPlanMap.put(objPayPlan.Id, objPayPlan);
                    }
                    
                    for(Instalment__c objInstalment : objPayPlan.Instalments__r){
                        setInActiveInstalmentIds.add(objInstalment.Id);
                    }
                }
                else if(objectMap.containsKey(objPayPlan.Id)){
                    
                    if(objPayPlan.BillingContract__r.PreventRecoveryReset__c == false 
                       && objPayPlan.PaymentPlanType__r.ResetDebtRecovery__c == true){
                           
                           contractIdForDebtRecProcess.add(objPayPlan.BillingContract__c);
                       }
                }
            }
        }
        if(setInActiveInstalmentIds.size() > 0){
            
            for(DebtRecoveryInstalment__c objDebtRecInstal : [SELECT Id,Name,Active__c,Instalment__c
                                                              FROM DebtRecoveryInstalment__c
                                                              WHERE Instalment__c IN: setInActiveInstalmentIds
                                                              AND Active__c = true]){
                                                                  
                                                                  objDebtRecInstal.Active__c = false;
                                                                  updateDebtRecoveryInstalment.put(objDebtRecInstal.Id, objDebtRecInstal);
                                                              }
        }        
        if(contractIdForDebtRecProcess.size() > 0){
            
            for(DebtRecoveryProcess__c objDebt : [SELECT Id,Name,
                                                  BillingContract__c,
                                                  ProcessComplete__c
                                                  FROM DebtRecoveryProcess__c
                                                  WHERE BillingContract__c IN: contractIdForDebtRecProcess
                                                  AND ProcessComplete__c = false]){
                                                      
                                                      objDebt.ProcessComplete__c = true;                                                      
                                                      updateDebtRecoveryProcess.put(objDebt.Id, objDebt);
                                                  }
        }
    }
    
    /******************************************************************************
	@author         Echo: Dependra Singh
	@date           22 Feb 2018
	@param          Map<Id,sObject> newmap, Map<Id,sObject> oldmap
	@description    Update the payment plan trigger handler to update the contract with the active payment plan ( for aged debt reporting)
	(1)-Trigger checks to see if the Start Date of the Payment Plan is either Today’s date or before. 
	(2)-Trigger checks to see of the End Date of the Payment Plan is either in the future or not populated          
	(3)-If both above conditions are met, then the Trigger populates the lookup field ‘Current Payment Plan Type’ (on the related Contract record) with the Payment Plan Type related to the Payment Plan
	@return         void
	*******************************************************************************/
    private void updatePaymentPlanTypeOnContract(Map<Id,sObject> newMap, Map<Id,sObject> oldmap) {
        
        Map<Id,Id> paymentPlanByContractIdMap = new Map<Id,Id>();
        //List<BillingContract__c> contractListToUpdate = new List<BillingContract__c>();
        
        if(newMap != null){
            for(PaymentPlan__c objPaymentPlan : (List<PaymentPlan__c>)newMap.values()) {
                //if((objPaymentPlan.StartDate__c != null && objPaymentPlan.StartDate__c <= System.today()) && (objPaymentPlan.EndDate__c > System.today() || objPaymentPlan.EndDate__c== null)){
                if(objPaymentPlan.Active__c == true){
                    if(!paymentPlanByContractIdMap.containsKey(objPaymentPlan.BillingContract__c) && objPaymentPlan.PaymentPlanType__c != null){//AT-3174
                        paymentPlanByContractIdMap.put(objPaymentPlan.BillingContract__c, objPaymentPlan.PaymentPlanType__c);//AT-3174
                    }
                }
            }
        }
        if(paymentPlanByContractIdMap.keySet().size() >0){
            //MT - 20/05/2018 AT-2206 Start building a map of payment plan type id and its record
            Map<Id,PaymentPlanType__c> paymentPlanTypeIdAndRecordMap = new Map<Id,PaymentPlanType__c>();
            for(PaymentPlanType__c objPaymentPlanType : [SELECT Id, DebtRecoveryProfile__c FROM PaymentPlanType__c WHERE Id IN: paymentPlanByContractIdMap.values() And SystemDefault__c = True]){
                if(!paymentPlanTypeIdAndRecordMap.containsKey(objPaymentPlanType.Id)){
                    paymentPlanTypeIdAndRecordMap.put(objPaymentPlanType.Id, objPaymentPlanType);
                }
            }
            //building a map of payment plan type and payment method type
            Map<Id,Id> paymentPlanTypeAndPaymentMethodTypeMap = new Map<Id,Id>();
            for(PaymentMethod__c objPaymentMethod : [SELECT Id,PaymentPlanType__c,PaymentMethodType__c FROM PaymentMethod__c WHERE PaymentPlanType__c IN: paymentPlanTypeIdAndRecordMap.keySet() And Default__c = True]){
                if(!paymentPlanTypeAndPaymentMethodTypeMap.containsKey(objPaymentMethod.PaymentPlanType__c)){
                    paymentPlanTypeAndPaymentMethodTypeMap.put(objPaymentMethod.PaymentPlanType__c, objPaymentMethod.PaymentMethodType__c);
                }
            }
            
            for(BillingContract__c objContractNew : [SELECT Id,CurrentPaymentPlanType__c FROM BillingContract__c WHERE ID IN: paymentPlanByContractIdMap.keyset()]){
                objContractNew.CurrentPaymentPlanType__c = paymentPlanByContractIdMap.get(objContractNew.Id);
                // assigning default payment method type to contract payment method type field  
                if(paymentPlanTypeAndPaymentMethodTypeMap.containsKey(paymentPlanByContractIdMap.get(objContractNew.Id))){
                    objContractNew.PaymentMethodType__c = paymentPlanTypeAndPaymentMethodTypeMap.get(paymentPlanByContractIdMap.get(objContractNew.Id));
                }
                // assigning debt recovery profile of system default payment plan type to contract debt recovery profile field
                if(paymentPlanTypeIdAndRecordMap.containsKey(paymentPlanByContractIdMap.get(objContractNew.Id))){
                    objContractNew.DebtRecoveryProfile__c = paymentPlanTypeIdAndRecordMap.get(paymentPlanByContractIdMap.get(objContractNew.Id)).DebtRecoveryProfile__c;
                }
                //End of AT-2206
                contractListToUpdate.add(objContractNew);
            }
        }
        
        
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           23 Feb 2018
    @param          Map<Id, SObject> - objectMap
    @description    Locate all payments against the same contract as new payment plan where record type = Payment and Amount Unallocated to Instalment > 0
    For each of these payments mark Amount Unallocated to Installment = 0 and Instalment Allocation Status = "fully allocated"
    *******************************************************************************/
    public void updatePaymentUnAllocAmount(Map<Id, SObject> objectMap) {
        
        GlUt_PaymentUtilities objPaymentUtility = new GlUt_PaymentUtilities();
        objPaymentUtility.updatePaymentUnAllocAmount(objectMap);
        
    }
            
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           04 June 2018
    @param          Map<Id, SObject> - objectMap
    @description    AT-2481 , Locate the contract against new payment plan and add a Billing Event record against it
    @revision       21-Jun-2018, Swati -- AT-2946, modified the logic of creation of Bill Event
    *******************************************************************************/
    private void addBillingEventToContract(Map<Id, SObject> objectMap) {
        //AT-2946 -changes start
        Set<Id> setContractIds = new Set<Id>();
        Map<Id,Bill__c> contractId2BillMap = new Map<Id,Bill__c>(); 
        List<Bill__c> billList = new List<Bill__c>();
        
        // build a list of the related contract Ids
        for (PaymentPlan__c paymentPlan : (List<PaymentPlan__c>)objectMap.values()) {
            
            setContractIds.add(paymentPlan.BillingContract__c);  //AT-3174          
        }
        
        if(setContractIds.size() > 0){
            billList = [SELECT Id, 
                        BillingContract__c
                        FROM Bill__c 
                        WHERE BillingContract__c IN: setContractIds
                        AND DataXml__c = false];
        }
        
        if (!billList.isEmpty() || billList != null) {
            for(Bill__c objBill :billList){     
                if(!contractId2BillMap.containsKey(objBill.BillingContract__c)){
                    contractId2BillMap.put(objBill.BillingContract__c,objBill);
                }           
            }
        }
        
        for(Id objId : setContractIds){            
            if( contractId2BillMap.keyset().size() > 0 &&  contractId2BillMap.containsKey(objId)){
                // create bill event 
                BillEvent__c objBillEvent = new BillEvent__c();
                objBillEvent.BillingContract__c = objId;
                objBillEvent.EventType__c = GlUt_APIConstantsBillEvent.PAYMENTPLANBILLEVENTTYPE; // 'Payment Plan Change'; 
                objBillEvent.Status__c = GlUt_APIConstantsBillEvent.PENDINGBILLEVENTSTATUS;  // 'Pending';                
                billEventListToUpdate.add(objBillEvent);
            }
            else { // create PDF request
                PDFRequest__c objPDFRequest = new PDFRequest__c();
                objPDFRequest.BillingContract__c = objId;
                objPDFRequest.CorrespondenceType__c = GlUt_APIConstantsPDFRequest.PAYMENTPLANNOTIFICATION; // 'Payment Plan Notification'
                objPDFRequest.SourceType__c = GlUt_APIConstantsPDFRequest.XMLSOURCETYPE ; // 'Data Transfer XML'
                objPDFRequest.Status__c = GlUt_APIConstantsPDFRequest.PENDINGSTATUS;  // 'Pending'     
                PDFRequestListToInsert.add(objPDFRequest);
            }            
        } 
        //AT-2946 -changes end
    }
}