/******************************************************************************
@author    		Echo: Swati 
@date      		21 June 2018
@description    Controller for CuAp_NewPaymentCardRequest lightning component
*******************************************************************************/
public with sharing class CuAp_NewPaymentCardRequestCtrlr {

	private static final String CLASS_NAME = 'PlAp_NewPaymentCardRequestCtrlr';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static final List<String> paymentPlanFields = new List<String> {
        GlUt_APIConstantsPaymentPlan.PAYMENTPLANTYPEAPINAME       
    }; 
        
    private static final List<String> paymentMethodFields = new List<String> {
        GlUt_APIConstantsPaymentMethod.PAYMETHODTYPEAPINAME       
    }; 
        
    private static final List<String> paymentPlanCardFields = new List<String> {
        GlUt_APIConstantsPaymentPlanCard.REQUESTEDONAPINAME       
    };
        
    private static final List<String> PMTFields = new List<String> {
        GlUt_APIConstantsPaymentMethodType.NAMEAPINAME
    }; 
        
    /******************************************************************************
    @author         Echo: Swati 
    @date           21 June 2018
    @param          Id contractId
    @return         resultWrapper objresultWrapper
    @description    to check whether button should be displayed on page or not 
    *******************************************************************************/
    @AuraEnabled
    public static resultWrapper allowPaymentCardRequest(Id contractId) {
        try {
            resultWrapper objresultWrapper = new resultWrapper();
            List<PaymentPlan__c> lstPaymentPlan  = new List<PaymentPlan__c>();
            List<PaymentMethod__c> lstPaymentMethod = new List<PaymentMethod__c>();
            List<PaymentMethodType__c> lstPMT = new List<PaymentMethodType__c>();
            
            String PPfilterStatement = 'WHERE ' + GlUt_APIConstantsPaymentPlan.ACTIVEAPINAME + '= ' + 'true' + ' AND ' + GlUt_APIConstantsPaymentPlan.CONTRACTORDERAPINAME + '= \'' + String.escapeSingleQuotes(contractId) + '\'';
            // get the PaymentPlan records
            lstPaymentPlan = GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPaymentPlan.PAYMENTPLANAPINAME,
                                                                                      paymentPlanFields,
                                                                                      PPfilterStatement);            
            List<Id> paymentPlanIdList = new List<Id>();
            Set<Id> setPPTId = new Set<Id>();
            for(PaymentPlan__c pp : lstPaymentPlan){
                setPPTId.add(pp.PaymentPlanType__c);
                paymentPlanIdList.add(pp.Id);
            }           
            
            String PMfilterStatement = 'WHERE ' + GlUt_APIConstantsPaymentMethod.PAYPLANTYPEAPINAME + ' IN ' + GlUt_FieldSecurity.IdsToString(setPPTId);       
            // get the PaymentMethod records
            lstPaymentMethod =  GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPaymentMethod.PAYMENTMETHODAPINAME,
                                                                    paymentMethodFields,
                                                                    PMfilterStatement);
            List<Id> lstPMTId = new List<Id>();
            
            if(!lstPaymentMethod.isEmpty() && lstPaymentMethod!= null){               
                for(PaymentMethod__c pm : lstPaymentMethod){
                    lstPMTId.add(pm.PaymentMethodType__c);
                }
            }
            
            if(!lstPMTId.isEmpty() && lstPMTId!= null){ 
                lstPMT = GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPaymentMethodType.PAYMENTMETHODTYPEAPINAME,
                                                             PMTFields,
                                                             'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(lstPMTId));
                if(!lstPMT.isEmpty() && lstPMT!= null){
                    for(PaymentMethodType__c pmt : lstPMT){
                        If(pmt.Name == CuAp_Constants.PAYMENTCARD){
                            //set flag as true                     
                            objresultWrapper.allowRequest = true;
                            objresultWrapper.paymentPlanIdList = paymentPlanIdList;
                        }
                    }
                }
            }
            return objresultWrapper;
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            // TO-DO - Log exception
            throw new AuraHandledException(e.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         Echo: Swati 
    @date           21 June 2018
    @param          List<Id> paymentPlanIdList
    @return         Boolean isUpdated
    @description    Change RequestedOnDate of Payment Plan Card record
    *******************************************************************************/
    @AuraEnabled
    public static Boolean doChangeRequestedOnDate(List<Id> paymentPlanIdList) {
        
        Boolean isUpdated = false;
        try {
            String filterStatement = 'WHERE ' + GlUt_APIConstantsPaymentPlanCard.PAYMENTPLANAPINAME + ' IN ' + GlUt_FieldSecurity.IdsToString(paymentPlanIdList);
            // get the Payment Plan Card records
            List<PaymentPlanCard__c> lstPaymentPlanCard = GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPaymentPlanCard.PAYMENTPLANCARDAPINAME,
                                                                                      paymentPlanCardFields,
                                                                                      filterStatement);
            if(!lstPaymentPlanCard.isEmpty() && lstPaymentPlanCard!= null){
                
                for(PaymentPlanCard__c obj : lstPaymentPlanCard){
                    obj.RequestedOn__c = System.today();
                }
                isUpdated = true;
                lstPaymentPlanCard = ( List<PaymentPlanCard__c>) GlUt_FieldSecurity.cleanseFields(lstPaymentPlanCard, false);
                Update lstPaymentPlanCard;
            }
            return isUpdated;            
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            // TO-DO - Log exception
            throw new AuraHandledException(e.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           21 June 2018
    @param          none
    @return         none
    @description    Wrapper Class 
    *******************************************************************************/
    public class resultWrapper {
        @AuraEnabled public Boolean allowRequest;
        @AuraEnabled public List<Id> paymentPlanIdList;        
    }
}