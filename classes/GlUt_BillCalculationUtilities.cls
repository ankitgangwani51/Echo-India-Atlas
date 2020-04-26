/******************************************************************************
@author         Dependra Singh
@date           23 Oct 2018
@description    An apex class for Bill calculation utilities Methods
@revision    
*******************************************************************************/
public with sharing class GlUt_BillCalculationUtilities {
    
    /******************************************************************************
    @author         Dependra
    @date           23 Oct 2018
	@parameters		String contractId
					
    @return         BillCalculation__c
    @description    This method create and return bill calculation record     
    *******************************************************************************/
    public static BillCalculation__c createBillCalculation(string contractId, string strType, string strStatus){
        BillCalculation__c billCalculationObj = new BillCalculation__c();
        if(contractId != null){
            billCalculationObj.BillingContract__c = contractId;
            billCalculationObj.Type__c = strType;
            billCalculationObj.Status__c = strStatus;
            billCalculationObj  = (BillCalculation__c) GlUt_FieldSecurity.cleanseFields(billCalculationObj, false);
            insert billCalculationObj;
        }
        return billCalculationObj;
    }
}