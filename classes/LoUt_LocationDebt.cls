/****************************************************************************************************************************
@author         Echo: Dependra Singh
@date           18 Oct 2018
@description    A Utility Class to establish the level of debt associated with a property
*****************************************************************************************************************************/
public with sharing class LoUt_LocationDebt {
    /******************************************************************************
    @author    		Echo: Dependra Singh
    @date      		18 Oct 2018
    @param			Id - locationId
    @return			Decimal - return debt amount
    @description	Method is used retrieve outstanding amount for each bill item which is related to 
    supply point using location.
    *******************************************************************************/
    public static decimal getTotalOutstandingDebt(Id locationId) {
        decimal totalOutStandingAmount = 0.00;
        if(locationId != null){
            Set<Id> supplyPointIds = new Set<Id>();
            List<SupplyPoint__c> lstSupplyPoint = [SELECT Id FROM SupplyPoint__c WHERE Location__c =: locationId LIMIT 1];
            if(lstSupplyPoint != null && !lstSupplyPoint.isEmpty()){
                for(SupplyPoint__c objSupplyPoint : lstSupplyPoint){
                    supplyPointIds.add(objSupplyPoint.Id);
                }
            }	
            if(supplyPointIds.size() > 0){
                for(BillItem__c billItemObj :[SELECT Id,AmountOutstanding__c,ServiceItem__r.Service__c, ServiceItem__r.Service__r.OccupancyType__c,SupplyPoint__c 
                                              FROM BillItem__c 
                                              WHERE SupplyPoint__c IN : supplyPointIds 
                                              AND ServiceItem__r.Service__r.OccupancyType__c !=: System.Label.CuAp_AUMoveInOccType]){
                                                  if(billItemObj.AmountOutstanding__c != null){
                                                      totalOutStandingAmount += billItemObj.AmountOutstanding__c;
                                                  }
                                              }
            }
        }
        return totalOutStandingAmount;
    } 
    /******************************************************************************
    @author    		Echo: Dependra Singh
    @date      		26 Mar 2019
    @param			Id - locationId, string occupancyType
    @return			Decimal - return debt amount
    @description	Method is used retrieve outstanding amount for each bill item based on occcupancy type which is related to 
    supply point using location.
					This is for future purpose if we need to calculate the outstanding amount of tenant also.
					
    *******************************************************************************/
    public static decimal getTotalOutstandingDebt(Id locationId, string occupancyType) { 
        decimal totalOutStandingAmount = 0.00;
        Set<Id> supplyPointIds = new Set<Id>();
        List<Service__c> serviceList;
        if(locationId != null){
            
            List<SupplyPoint__c> lstSupplyPoint = [SELECT Id FROM SupplyPoint__c WHERE Location__c =: locationId LIMIT 1];
            if(lstSupplyPoint != null && !lstSupplyPoint.isEmpty()){
                for(SupplyPoint__c objSupplyPoint : lstSupplyPoint){
                    supplyPointIds.add(objSupplyPoint.Id);
                }
            }
        }
        if(supplyPointIds.size() > 0){
            if(string.isNotBlank(occupancyType)){
                for(BillItem__c billItemObj :[SELECT Id,AmountOutstanding__c,ServiceItem__r.Service__c, ServiceItem__r.Service__r.OccupancyType__c,SupplyPoint__c
                                              FROM BillItem__c WHERE SupplyPoint__c IN : supplyPointIds]){
                                                  if(billItemObj.AmountOutstanding__c != null && billItemObj.ServiceItem__r.Service__r.OccupancyType__c == occupancyType){
                                                      totalOutStandingAmount += billItemObj.AmountOutstanding__c;
                                                  }
                                              }
            }else{
                for(BillItem__c billItemObj :[SELECT Id,AmountOutstanding__c,ServiceItem__r.Service__c,SupplyPoint__c
                                              FROM BillItem__c 
                                              WHERE SupplyPoint__c IN : supplyPointIds]){
                                                  if(billItemObj.AmountOutstanding__c != null){
                                                      totalOutStandingAmount += billItemObj.AmountOutstanding__c;
                                                  }
                                              }
            }
        }
        return totalOutStandingAmount;
    }    
}