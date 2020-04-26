/******************************************************************************
@author:      Echo: Mohit Tayal
@date:        15 December 2017
@description: This class is updating the debt recovery profile field of contract
              with the value present in the parameter field of the debt recovery action
*******************************************************************************/
public class DrUt_UpdateRecoveryProfile {
    /***************************************************************************************************
    @author        Echo: Mohit Tayal
    @date          15 December 2017
	@parameter	   List<Id> recList
	@return		   None
    @description:  This is used to update the Recovery Profile
    *******************************************************************************************************/
    public static void updateRecoveryProfile(List<Id> recList){
        
        List<DebtRecoveryAction__c> dbtRecActionList =  [SELECT Id, Parameters__c , DebtRecoveryProcess__r.BillingContract__c FROM DebtRecoveryAction__c WHERE Id IN :recList];
        
        Map<Id,Id> actionContractIdsMap = new Map<Id,Id>();
        
        // creating map of debt recovery action id and assosciated contract id
        for(DebtRecoveryAction__c dRecActRec : dbtRecActionList){
            if(dRecActRec.DebtRecoveryProcess__r.BillingContract__c != null){
                actionContractIdsMap.put(dRecActRec.Id,dRecActRec.DebtRecoveryProcess__r.BillingContract__c);
            }
        }
        
        // creating map of the contract ids and the contract object
        Map<Id,BillingContract__c> contractMap = new Map<Id,BillingContract__c>([SELECT Id, DebtRecoveryProfile__c FROM BillingContract__c WHERE Id IN :actionContractIdsMap.values()]);
        
        Set<String> contractDebtRecProfPickList = new Set<String>();
        // creating a set of the pickilst value of the debt recovery profile field of contract
        List<GlAp_FieldProps> fldProps = GlUt_FieldSecurity.getFieldPropertiesObject(CuAp_Constants.CONTRACTAPINAME,new List<String>{CuAp_Constants.DEBTRECOVERYPROFILE});
        for(GlAp_FieldProps fp : fldProps){
            if(fp.isFLSVisible){
                contractDebtRecProfPickList.addAll(fp.pickListEntries.Values());
            }
        }
        
        Map<Id,BillingContract__c> updatedContractMap = new Map<Id,BillingContract__c>();
        List<DebtRecoveryAction__c> updatedDRAList = new List<DebtRecoveryAction__c>();
        
        for(DebtRecoveryAction__c dRecActRec : dbtRecActionList){
            // validating that the parameter field of the debt recovery action is not blank or 
            // it's values matches with the on of the pickilst value of the debt recovery profile field of contract 
            if(dRecActRec.Parameters__c != '' && contractDebtRecProfPickList.contains(dRecActRec.Parameters__c) && actionContractIdsMap.containsKey(dRecActRec.Id)){
                Id contractId = actionContractIdsMap.get(dRecActRec.Id);
                BillingContract__c contract = contractMap.get(contractId);
                contract.DebtRecoveryProfile__c = dRecActRec.Parameters__c;
                updatedContractMap.put(contract.Id,contract);
                //Mark Debt Recovery Action as processed
                dRecActRec.processed__c = true;
                updatedDRAList.add(dRecActRec);
            }
        } 
        if(updatedContractMap.values().size() > 0){
            List<BillingContract__c> lstUpdateContract = (List<BillingContract__c>) GlUt_FieldSecurity.cleanseFields(updatedContractMap.values(), false);
            update lstUpdateContract;
        }
        if(!updatedDRAList.isEmpty()){
            updatedDRAList = (List<DebtRecoveryAction__c>) GlUt_FieldSecurity.cleanseFields(updatedDRAList, false);
            update updatedDRAList;
        }
        
    }

}