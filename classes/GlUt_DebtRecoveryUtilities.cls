/******************************************************************************
@author        Echo: Neha
@date          23 Feb 2018
@description   Class for Debt Recovery utilities
*******************************************************************************/
public with sharing class GlUt_DebtRecoveryUtilities {
    
    private static List<String> contractItemFields;
    private static List<String> debtRecoveryItemFields;
    
    static{
        contractItemFields = new List<String>();
        contractItemFields.add(GlUt_APIConstantsContracts.CURRENTDRPAPINAME);
    }
    
    static{
        debtRecoveryItemFields = new List<String>();
        debtRecoveryItemFields.add(GlUt_APIConstantsDebtRecoveryProcess.CURRENTSTAGEAPINAME);
    }    
    
    /******************************************************************************
	@author        Echo: Neha R
	@date          23 Feb 2017
	@param         Id - Account Id or Contract Id
	@param         String - sObjectName
	@return        String - Current Debt Recovery Stage
	@description  
	*******************************************************************************/
    public static String getCurrentDebtRecoveryStage(Id recordId, String sObjectName) {
        
        String sOQLQuery;
        String currentStage;
        
        List<BillingContract__c> contractList = new List<BillingContract__c>();
        List<DebtRecoveryProcess__c> drpList = new List<DebtRecoveryProcess__c>();
        List<Id> drpIdList = new List<Id>();
        
        sOQLQuery = String.format('SELECT {0} FROM {1}', 
                                  new List<String>{'Id,'+ String.join(contractItemFields,','), 
                       			  GlUt_APIConstantsContracts.CONTRACTAPINAME + ' WHERE Id = :recordId'});         
        
        contractList = Database.query(sOQLQuery);
            
        // Check the security on the Contract Item Type fields
        //contractList = GlUt_FieldSecurity.cleanseFields(contractList, contractItemFields, true);
        contractList = GlUt_FieldSecurity.cleanseFields(contractList, true);
       
        for(BillingContract__c conObj : contractList){
            system.debug('CurrentDebtRecoveryProcess__c.....' + conObj.CurrentDebtRecoveryProcess__c);
            drpIdList.add(conObj.CurrentDebtRecoveryProcess__c);
        }
        
        system.debug('test neha**************drpIdList ' + drpIdList);
        // Current Debt Recovery Process 
        sOQLQuery = String.format('SELECT {0} FROM {1}', 
                                  new List<String>{'Id,'+ String.join(debtRecoveryItemFields,','), 
                       			  GlUt_APIConstantsDebtRecoveryProcess.DEBTRECOVERYPROCESSAPINAME + ' WHERE Id IN :drpIdList'});   
               
        drpList = Database.query(sOQLQuery);
        
        // Check the security on the Debt Recovery Process Item Type fields
        //drpList = GlUt_FieldSecurity.cleanseFields(drpList, debtRecoveryItemFields, true); 
        drpList = GlUt_FieldSecurity.cleanseFields(drpList, true); 
        for(DebtRecoveryProcess__c objDRP : drpList)
        {    
			currentStage = objDRP.CurrentStage__c;
        }
        
        return currentStage;
    }
}