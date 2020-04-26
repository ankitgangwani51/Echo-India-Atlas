/**********************************************************************************************
@author			ECHO: Mohit Tayal
@date			29 March 2018
@description	This class displays the payment records of the logged in account
Revision(s)		02 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
@Revision	 	AT-3969, Tarun - Modified as per security review
**********************************************************************************************/
public with sharing class CmAp_MyPaymentsCtrlr {  

    /**********************************************************************************************
	@author    	   ECHO: Mohit Tayal
	@date      	   29 March 2018
    @param         none
    @return        List<GLAp_FieldProps>
    @description   This method returns the field properties for each of the fields that are
                   to be displayed on the screen
	**********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> getPaymentPropDetails() {
    //Get the field properties for the Payment object
        List<GLAp_FieldProps> lstPaymentsProp = GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetName(GlUt_APIConstantsPayments.PAYMENTAPINAME, CmAp_Constants.MYPAYMENTSFIELDSET);   
        return lstPaymentsProp;  
    }
    
    /******************************************************************************
	@author    		ECHO: Mohit Tayal
	@date      		29 March 2018
	@param			none
	@return			List<Payment__c> - List of payment records
	@description	Method called by the Component to retrieve the payments records of the logged in user account
	*******************************************************************************/
	@AuraEnabled
    public static List<Payment__c> getUserPayments() { 
        
        //accessing the logged in user account
        Account objAccount = CmAp_MyAccountCtrlr.getCurrentUserAccount();
        
        List<Payment__c> lstPayments = new List<Payment__c>();
        if(objAccount != null){
            //returning the payment records
            lstPayments = (List<Payment__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPayments.PAYMENTAPINAME,        
            																	CmAp_Constants.MYPAYMENTSFIELDSET, 
            																	objAccount.Id, 
            																	GlUt_APIConstantsPayments.ACCOUNTAPINAME, 
						            											null, 
																				'order by CreatedDate desc'		// order the results
						            											);
        }
        
        // Mt - 27-04-2018 AT - 2715 changes code to display payments from contract
        List<BillingContract__c> lstContract = CmAp_MakePaymentCtrlr.getContractList();
        
        if(lstContract != null && !lstContract.isEmpty()){
            lstPayments.addAll((List<Payment__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPayments.PAYMENTAPINAME, 
            																	CmAp_Constants.MYPAYMENTSFIELDSET, 
            																	lstContract[0].Id,
            																	GlUt_APIConstantsPayments.CONTRACTAPINAME, 
						            											null, 
																				'order by CreatedDate desc'		// order the results
						            											));
            
            Map<Id,Payment__c> paymentDateRecordsMap = new Map<Id,Payment__c>();
            
            for(Payment__c objPayment : lstPayments){
                paymentDateRecordsMap.put(objPayment.Id,objPayment); 
            }
            
            lstPayments = new List<Payment__c>();
            lstPayments.addAll(paymentDateRecordsMap.values());
            
            for(Integer i = 0; i < lstPayments.size(); i++){
                for(Integer j = i+1; j < lstPayments.size(); j++){
                    if(lstPayments[i].PaymentDate__c < lstPayments[j].PaymentDate__c){
                        Payment__c objPayment = lstPayments[i];
                        lstPayments[i] = lstPayments[j];
                        lstPayments[j] = objPayment;
                    }
                }
            }
        }
        // End of AT - 2715
        
        return lstPayments;
    }
}