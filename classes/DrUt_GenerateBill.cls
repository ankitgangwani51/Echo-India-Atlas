/**********************************************************************************************
@author      	Echo: Vivek Sethi
@date      		22-Nov-2017
@description	Class To Generate Bill for Debt. Recovery Process.
@revision       MT - Changed the class name from GlUt_GenerateBill to DrUt_GenerateBill in 
                name and description of the class .
                Changed the code to Generate Bill for Debt. Recovery Process Only.
***********************************************************************************************/
public class DrUt_GenerateBill {
    public static void generateBill(List<Id> recList){
        /*Debt. Recovery*/       
        /*Fetching Debt. Recovery Action Records*/
        List<DebtRecoveryAction__c> dbtRecActionList =  [SELECT Id, Processed__c , DebtRecoveryProcess__r.BillingContract__c FROM DebtRecoveryAction__c WHERE Id IN :recList];
        
        /*Debt Recovery action flag set to processed for Billing*/
        for(DebtRecoveryAction__c dRecActRec : dbtRecActionList )
        {
            dRecActRec.Processed__c= TRUE;  
        }
        
        Database.update(dbtRecActionList);        
    }
}