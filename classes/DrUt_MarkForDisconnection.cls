/******************************************************************************
@author      	Echo: Mohit Tayal
@date      		29-Jan-2018
@description	Class to mark Disconnection Status field of supply point as 'To Be Disconnected'
                if the AllowDisconnection field of supply point is true
                AT-4891/2 Code Check Marx Changes for FLS INSERT/UPDATE
*******************************************************************************/
public class DrUt_MarkForDisconnection {
    
	/******************************************************************************
	@author      	Echo: Mohit Tayal
	@date      		29-Jan-2018
	@param			recList - List of debt recovery action Ids
	@description	Method to mark Disconnection Status field of supply point as 'To Be Disconnected'
	                if the AllowDisconnection field of supply point is true
	*******************************************************************************/
    public static void markForDisconnection(List<Id> recList){
        
        Map<Id,List<DebtRecoveryAction__c>> contractIdDebtRecActIdMap = new Map<Id,List<DebtRecoveryAction__c>>();
        Map<Id,List<Id>> supplyPointIdContractIdMap = new Map<Id,List<Id>>();
        List<DebtRecoveryAction__c> debtRecActProcessedList = new List<DebtRecoveryAction__c>();
        
        if (recList.size() > 0 ){
            List<DebtRecoveryAction__c> debtRecActionList =  [SELECT Id , Parameters__c , DebtRecoveryProcess__r.BillingContract__c FROM DebtRecoveryAction__c WHERE Id IN :recList];
            Set<Id> contractIdSet = new Set<Id>();
            
            //building map of contract id and it's corresponding debt recovery action records
            for(DebtRecoveryAction__c debtRecAct : debtRecActionList)    {
                if(debtRecAct.DebtRecoveryProcess__r.BillingContract__c != null){
                    if(!contractIdDebtRecActIdMap.containsKey(debtRecAct.DebtRecoveryProcess__r.BillingContract__c)){
                        contractIdDebtRecActIdMap.put(debtRecAct.DebtRecoveryProcess__r.BillingContract__c, new List<DebtRecoveryAction__c>());
                    }
                    contractIdDebtRecActIdMap.get(debtRecAct.DebtRecoveryProcess__r.BillingContract__c).add(debtRecAct);
                }
            }
            
            //fetching the services against the contract ids in map contractIdDebtRecActIdMap
            List<Service__c> serviceList = [SELECT Id, ServiceType__c, BillingContract__c, ServiceStartDate__c, ServiceEndDate__c, SupplyPoint__c 
                                            FROM Service__c WHERE BillingContract__c IN:contractIdDebtRecActIdMap.keySet() AND (ServiceEndDate__c = null OR ServiceEndDate__c > :Date.today())];
            if(serviceList.size() > 0){
                //creating map of supply point id and it's corresponding contract ids
                for(Service__c serviceRec : serviceList){
                    if(serviceRec.SupplyPoint__c != null){
                    if(!supplyPointIdcontractIdMap.containsKey(serviceRec.SupplyPoint__c)){
                        supplyPointIdcontractIdMap.put(serviceRec.SupplyPoint__c, new List<Id>());
                    }
                    supplyPointIdcontractIdMap.get(serviceRec.SupplyPoint__c).add(serviceRec.BillingContract__c);
                    }
                }
                
                // fetching supply point records against the supply point id's in supplyPointIdContractIdMap map
                List<SupplyPoint__c> supplyPointList = [SELECT Id, DisconnectionStatus__c, AllowDisconnection__c FROM SupplyPoint__c WHERE Id IN :supplyPointIdContractIdMap.keySet()];
                
                if(supplyPointList.size() > 0){
                    // updating the supply point and debt recovery field based on the AllowDisconnection__c field
                    for(SupplyPoint__c supplyPointRec : supplyPointList){        
                        if(supplyPointIdcontractIdMap.containsKey(supplyPointRec.Id)){
                            if(supplyPointRec.AllowDisconnection__c){
                                supplyPointRec.DisconnectionStatus__c = DrBt_Constants.TOBEDISCONNECTED;
                            }
                            for(Id contractId : supplyPointIdcontractIdMap.get(supplyPointRec.Id)){
                                // if contract is already processed against any supply point then no need to process it again
                                if(!contractIdSet.contains(contractId)){
                                    contractIdSet.add(contractId);
                                    if(contractIdDebtRecActIdMap.containsKey(contractId)){
                                        for(DebtRecoveryAction__c debtRecActRec : contractIdDebtRecActIdMap.get(contractId)){
                                            if(supplyPointRec.AllowDisconnection__c){
                                                debtRecActRec.Processed__c = TRUE;
                                            } else{
                                                // Used to display error in the debt recovery action field once the error design gets ready.
                                            }
                                            debtRecActProcessedList.add(debtRecActRec);
                                        }
                                    }
                                }
                            }
                        }     
                    }
                    //AT-4892 Code Check Marx Changes Starts Here.
                    supplyPointList = (List<SupplyPoint__c>) GlUt_FieldSecurity.cleanseFields(supplyPointList, false);
                    Database.update(supplyPointList);
                    debtRecActProcessedList = (List<DebtRecoveryAction__c>) GlUt_FieldSecurity.cleanseFields(debtRecActProcessedList, false);
                    Database.update(debtRecActProcessedList);
                    //AT-4892 Code Check Marx Changes Ends Here.
                }
            }
        }
    }
}