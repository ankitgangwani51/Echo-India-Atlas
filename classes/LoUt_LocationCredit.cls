/****************************************************************************************************************************
@author         Echo: Sudhir Kumar
@date           06 Nov 2018
@description    A Utility Class to to calculate the total amount of credit for the location linked to the information statement. 
*****************************************************************************************************************************/
public with sharing class LoUt_LocationCredit {
    
    /******************************************************************************
    @author    		Echo: Sudhir Kumar
    @date      		06 Nov 2018
    @param			Id - infoStatementId
    @return			Decimal - return credit amount
    @description	Method is used retrieve Bill Amount Allocated thru a payment linked to a billing contract on an info Statement.
    *******************************************************************************/
    //Thru Contract
    public static decimal getTotalBillAmountAllocated(Id infoStatementId) {
        decimal totalBillAmountAllocated = 0.00 ;
        if(String.isNotEmpty(infoStatementId)) {
            list<InformationStatement__c> listInfoStmt = [SELECT BillingContract__c FROM InformationStatement__c WHERE Id =: infoStatementId LIMIT 1] ;
            if(listInfoStmt != null && !listInfoStmt.isEmpty() && listInfoStmt[0].BillingContract__c != null) {
                list<Payment__c> listPayment = [SELECT Id, BillingContract__c, BillAmountUnallocated__c FROM Payment__c 
                                            WHERE BillingContract__c =: listInfoStmt[0].BillingContract__c] ;
                system.debug('listPayment = ' + listPayment) ;
                for(Payment__c pay : listPayment) {
                    totalBillAmountAllocated += pay.BillAmountUnallocated__c ;
                }
            }
            
        }
        return totalBillAmountAllocated ;
    }    
    //Thru Location
    //Commenting it for future change only if required.
    /*
    public static decimal getTotalBillAmountAllocated_2(Id locationId) {
        decimal totalBillAmountAllocated = 0.00 ;
        set<Id> setActiveContractIds ;
        if(String.isNotEmpty(locationId)) {
            List<SupplyPoint__c> supplyPointList = [SELECT Id FROM SupplyPoint__c WHERE Location__c =: locationId] ;
            if(supplyPointList != null && !supplyPointList.isEmpty()) {
                List<Service__c> serviceList = [SELECT Id, BillingContract__c, BillingContract__r.ContractStartDate__c, 
                                                BillingContract__r.ContractEndDate__c FROM Service__c WHERE SupplyPoint__c IN : supplyPointList];
                if(serviceList != null && !serviceList.isEmpty()) {
                    for(Service__c service : serviceList) {
                        if(service.BillingContract__c != null) {
                            setActiveContractIds = new set<Id>() ;
                            if(service.BillingContract__r.ContractStartDate__c <= System.today()
                              && (service.BillingContract__r.ContractEndDate__c == null 
                                  || service.BillingContract__r.ContractEndDate__c > System.today())) {
                                setActiveContractIds.add(service.BillingContract__c) ;
                            }
                        }
                    }
                }
            }
            if(setActiveContractIds != null && !setActiveContractIds.isEmpty()) {
                list<Payment__c> listPayment = [SELECT Id, BillAllocationAmount__c FROM Payment__c WHERE
                                               BillingContract__c IN: setActiveContractIds] ;
                system.debug('listPayment = ' + listPayment) ;
                for(Payment__c pay : listPayment) {
                    totalBillAmountAllocated += pay.BillAllocationAmount__c ;
                }
            }
        }
        return totalBillAmountAllocated ;
    }  
	*/
}