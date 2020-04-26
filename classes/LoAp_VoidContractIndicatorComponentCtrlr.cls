/******************************************************************************
 @author      	Accenture: Pratyush Kumar
 @date      	12-December-2017
 @description	Component controller for Void Contract Indicator Component
*******************************************************************************/
public with sharing class LoAp_VoidContractIndicatorComponentCtrlr {
    
    private static final String CLASS_NAME = 'LoAp_VoidContractIndicatorComponentCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    // void contract statuses - must match lightning component statuses
    private static final String VOIDCONTRACT_YES = 'YES';
    private static final String VOIDCONTRACT_NO = 'NO';
    private static final String CONTRACTSTATUS_ACTIVE = 'Active';
    
    /******************************************************************************
     * @author      	Accenture: Pratyush Kumar
     * @date      		12-December-2017
     * @param          Id - record Id
     * @return         String - void contract status YES/NO
     * @description    Checks if the record has a related void contract or not.
    *******************************************************************************/
    @AuraEnabled
    public static String getVoidContractStatus(Id recordId) {
        // call the method which returns Yes or No based on whether a related contract is void or not
        return isContractVoid(recordId) ? VOIDCONTRACT_YES : VOIDCONTRACT_NO;
    }
    
    /******************************************************************************
     * @author         Accenture: Pratyush Kumar
     * @date      	   12-December-2017
     * @param          Id - record Id
     * @return         Boolean - true if there exists a void contract 
     * @description    This method is used to check if a related Contract is void or not.
    *******************************************************************************/
    private static Boolean isContractVoid(Id recordId) {
        List<BillingContract__c> voidContractList = [SELECT Id, Void__c 
                                              FROM BillingContract__c
                                              WHERE Void__c = true
                                              AND Status__c = :CONTRACTSTATUS_ACTIVE
                                              AND Id IN (SELECT BillingContract__c
                                                         FROM Service__c
                                                         WHERE SupplyPoint__r.Location__c  = :recordId)];
        
        if(voidContractList.size() >= 1) {
            return true;
        }
        return false;
    }
}