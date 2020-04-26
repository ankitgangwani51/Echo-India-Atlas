/******************************************************************************
@author         Echo: Dependra Singh
@date           20 mar 2018
@description    Handler for Payment Allocation trigger
*******************************************************************************/
public with sharing class GlUt_PaymentAllocationHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_PaymentAllocationHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           20 mar 2018
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void MainEntry(GlUt_TriggerHandlerObj inputParam) {
                
        try {
            
            // AT-4162
            if (inputParam.isInsert && inputParam.isBefore) {
                updateTaxDiscountField(inputParam);               	 
            }
            
            if (inputParam.isInsert && inputParam.isAfter) {
                //  If(!Test.isRunningTest())  // Sudhir: System.LimitException: Too many SOQL queries: 101
                CallFinancialControlDispatcher(inputParam); //Swati-- 23-Mar-2018
            }
            
            
            if (inputParam.isUpdate && inputParam.isAfter) {
                system.debug('GlUt_PaymentAllocationHandler-After Update Trigger on Payment Allocation:: ') ;
                reverseInstalmentAndBillItems(inputParam.newlist, inputParam.oldmap) ;      // Sudhir:  AT-2034, AT-2111, AT-2062
               	
                CallFinancialControlDispatcher(inputParam);  //AT-2673
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
    @author         Echo: Dependra Singh
    @date           20 mar 2018
    @param          GlUt_TriggerHandlerObj inputParam
    @description    Call financial control dispatcher
    *******************************************************************************/
    public void CallFinancialControlDispatcher(GlUt_TriggerHandlerObj inputParam) {
        FcUt_CentralDispatcher.Main(inputParam);
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           21 March 2018
    @param          List<SObject> newlist, Map<Id, SObject> oldMap
    @description    AT-2034, AT-2062: Reverse Amount Allocated on Instalments and Bill Items and Update balance
    *******************************************************************************/ 
    
    public void reverseInstalmentAndBillItems(List<SObject> newlist, Map<Id, SObject> oldmap) {
        
        Map<Id, PaymentAllocation__c> paymentAllocationOldMap =  (Map<Id, PaymentAllocation__c>) oldmap ;
        Map<Id, PaymentAllocation__c> reversedPaymentAllocMap = new Map<Id, PaymentAllocation__c>() ;
        
        for(PaymentAllocation__c payAlloc : (List<PaymentAllocation__c>) newlist) {
            if(payAlloc.Status__c == GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_REVERSED  && paymentAllocationOldMap.get(payAlloc.Id).Status__c != GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_REVERSED ) 
               reversedPaymentAllocMap.put(payAlloc.Id, payAlloc) ;
        }
        system.debug('reversedPaymentAllocMap= ' + reversedPaymentAllocMap);
        if(!reversedPaymentAllocMap.isEmpty()) processInstalmentAndBillItemsReversal(reversedPaymentAllocMap) ;
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           22 March 2018
    @param          Map<Id, PaymentAllocation__c> reversedPaymentAllocMap
    @description    AT-2034, AT-2062: Reverse Amount Allocated on Instalments and Bill Items and Update balance
    *******************************************************************************/ 
    
    public void processInstalmentAndBillItemsReversal(Map<Id, PaymentAllocation__c> reversedPaymentAllocMap) {
        List<SObject> sObjectList = new List<SObject>() ;
        Set<Id> instalmentSet = new Set<Id>() ;
        Set<Id> billItemSet = new Set<Id>() ;
        Map<Id, PaymentAllocation__c> paymentAllocMap = new Map<Id, PaymentAllocation__c>() ;
        system.debug('processInstalmentAndBillItemsReversal-reversedPaymentAllocMap= ' + reversedPaymentAllocMap);
        try {
            List<PaymentAllocation__c> listPayAlloc = [SELECT Id, AmountAllocated__c, Instalment__c, Instalment__r.SumofAllocatedPayment__c,  
                                                      Instalment__r.InstalmentAmountOutstanding__c, Instalment__r.InstalmentAmountDue__c, BillItem__c, BillItem__r.AmountPaid__c, 
                                                      BillItem__r.NetBilledAmount__c, Payment__c, Payment__r.InstalmentAllocationAmount__c, Payment__r.BillAllocationAmount__c 
                                                      FROM
                                                      PaymentAllocation__c
                                                      WHERE
                                                      Id IN: reversedPaymentAllocMap.keySet()] ;
            if(listPayAlloc != null && !listPayAlloc.isEmpty()) {
                for(PaymentAllocation__c payAlloc : listPayAlloc) {
                    if(payAlloc.AmountAllocated__c != null &&  payAlloc.AmountAllocated__c != 0.00) {
                        if(payAlloc.Instalment__c != null) {
                            instalmentSet.add(payAlloc.Instalment__c) ;
                            paymentAllocMap.put(payAlloc.Instalment__c, payAlloc) ;
                        } 
                        if(payAlloc.BillItem__c != null) {
                            billItemSet.add(payAlloc.BillItem__c) ;
                            paymentAllocMap.put(payAlloc.BillItem__c, payAlloc) ;
                        }
                    }
                }
            }
            system.debug('processInstalmentAndBillItemsReversal-instalmentSet= ' + instalmentSet);
            if(!instalmentSet.isEmpty()) {
                List<Instalment__c> instalmentToReverse = [SELECT Id, InstalmentAmountDue__c, SumofAllocatedPayment__c FROM Instalment__c
                                                      WHERE Id IN: instalmentSet] ;
                for(Instalment__c instalment : instalmentToReverse) {
                    if(instalment.SumofAllocatedPayment__c != null && instalment.SumofAllocatedPayment__c != 0.00)
                       instalment.SumofAllocatedPayment__c -= paymentAllocMap.get(instalment.Id).AmountAllocated__c ;
                        sObjectList.add(instalment) ;
                }
            }
            system.debug('processInstalmentAndBillItemsReversal-billItemSet= ' + billItemSet);
            if(!billItemSet.isEmpty()) {
                List<BillItem__c> billItemToReverse = [SELECT Id, NetBilledAmount__c, AmountPaid__c FROM BillItem__c
                                                          WHERE Id IN: billItemSet] ;
                for(BillItem__c billItem : billItemToReverse) {
                    if(billItem.AmountPaid__c != null && billItem.AmountPaid__c != 0.00)
                        billItem.AmountPaid__c -= paymentAllocMap.get(billItem.Id).AmountAllocated__c ;
                        sObjectList.add(billItem) ;
                }
           } 
           if(!sObjectList.isEmpty()) {
                sObjectList.sort() ;
                Database.update(sObjectList) ;
               system.debug('processInstalmentAndBillItemsReversal-sObjectList= ' + sObjectList);
            }   
        } catch (Exception ex) {
            system.debug('processInstalmentAndBillItemsReversal-Exception :: ' + ex) ;
        }
    }
    
    /******************************************************************************
    @author         Echo: Neha R
    @date           30 Oct 2018
    @param          GlUt_TriggerHandlerObj inputParam
    @description    Update TaxAmount and Discount amount field of PaymentAllocation
					AT-4162
    *******************************************************************************/
    public void updateTaxDiscountField(GlUt_TriggerHandlerObj inputParam){ 
        // Set of Bill Item Ids
        set<Id> setBillItemIds = new set<Id>();     
        // Checking if trigger.new is not empty then looping over trigger new list to store vlues in variables.
        if(!inputParam.newlist.isEmpty()){
            for(PaymentAllocation__c objPaymentAllocation : (List<PaymentAllocation__c>)inputParam.newlist){
                if(objPaymentAllocation.BillItem__c != null)
                	setBillItemIds.add(objPaymentAllocation.BillItem__c);
            }
            
            // Map of Bill Item By id
            Map<Id,BillItem__c> mapBillItemById = new Map<Id, BillItem__c>([SELECT Id, Name,BilledAmount__c, 
                                                                            TotalTaxAmount__c, EndDate__c, 
                                                                            ServiceItem__r.ServiceItemType__c,
                                                                            ServiceItem__r.Service__r.BillingContract__r.BillingFrequency__c,
                                                                            TotalDiscountAmount__c                                                                  
                                                                            FROM BillItem__c 
                                                                            WHERE Id IN : setBillItemIds]);
            
            //create Financial Controls Records
            for(PaymentAllocation__c objPaymentAllocation : (List<PaymentAllocation__c>)inputParam.newlist){
                if(objPaymentAllocation.BillItem__c != null &&  mapBillItemById.containsKey(objPaymentAllocation.BillItem__c) ){                        
                    if(mapBillItemById.get(objPaymentAllocation.BillItem__c).TotalDiscountAmount__c != null)
                        objPaymentAllocation.DiscountAmount__c = (objPaymentAllocation.AmountAllocated__c / mapBillItemById.get(objPaymentAllocation.BillItem__c).BilledAmount__c) * mapBillItemById.get(objPaymentAllocation.BillItem__c).TotalDiscountAmount__c;                                                  
                    if(mapBillItemById.get(objPaymentAllocation.BillItem__c).TotalTaxAmount__c!= null)	
                        objPaymentAllocation.TaxAmount__c = (objPaymentAllocation.AmountAllocated__c / mapBillItemById.get(objPaymentAllocation.BillItem__c).BilledAmount__c) * mapBillItemById.get(objPaymentAllocation.BillItem__c).TotalTaxAmount__c;                                                                                  
                }                 
            }
            
        }
    }
}