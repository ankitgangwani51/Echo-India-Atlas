/**********************************************************************************************
@author         Echo : Sudhir Kumar
@date           02-Nov-2018
@description:   AT-4125 (AU1) : Request Statement Action - call an API in Heroku to calculate the settlement debt

**********************************************************************************************/

public with sharing class LoAp_InfoStatementCalculateChargesCtrlr {
    
    private static InformationStatement__c infoStmtObj ;
    
    private static final list<String> listInfoStatementFields = new list<String> {
        GlUt_APIConstantsInformationStatement.LOCATIONAPINAME, 
        GlUt_APIConstantsInformationStatement.BILLINGCONTRACTAPINAME, 
        GlUt_APIConstantsInformationStatement.SETTLEMENTDATEAPINAME, 
        GlUt_APIConstantsInformationStatement.TEMPLATEMAPPINGAPINAME 
    } ;
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           19 Nov 2018
    @param          Id - recordId
    @return         InformationStatement__c - InformationStatement object
    @description    Method called to get current InformationStatement object
    *******************************************************************************/    
    @AuraEnabled
    public static InformationStatement__c getInformationStatement(Id recordId) {
        infoStmtObj = [SELECT Id, Location__c, SettlementDate__c, BillingContract__c, TemplateMapping__c,
                                               TemplateMapping__r.PDFTemplate__c, TemplateMapping__r.XSLTDocument__c 
                                               FROM InformationStatement__c WHERE Id =: recordId] ;
        
        return infoStmtObj ;
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           19 Nov 2018
    @param          Id infoStmtRecordId
    @return         String - AccrualBillId
    @description    Method called to make Heroku callto generate Accrual Bill and Bill Items
    *******************************************************************************/   
    @AuraEnabled
    public static String calculateCharges(Id infoStmtRecordId) {
        system.debug('infoStmtRecordId= ' + infoStmtRecordId);
        //system.debug('infoStmtObj.BillingContract= ' + infoStmtObj.BillingContract__c);
        String accrualBillId = '' ;
        try {
            if(String.isNotBlank(infoStmtRecordId)) {
                LoIn_InfoStatementExtractData dataGenerator = new LoIn_InfoStatementExtractData(infoStmtRecordId) ;
                String jsonPayload = dataGenerator.getInfoStatementRequestPayload() ;
                system.debug('jsonPayload= ' + jsonPayload);
                if(String.isNotBlank(jsonPayload)) {
                    HttpResponse response = BlUt_HerokuWebservices.makeCallout(BlUt_HerokuWebservices.INFORMATION_STATEMENT, 2000, 'application/json', jsonPayload);
                    system.debug('http response= ' + response);
                    system.debug('http response body= ' + response.getBody());
                    // handle response
                    if (response.getStatusCode() == 200 && response.getBody() != null) {
                        accrualBillId = LoIn_InfoStatementResponseContainer.processInfoStatementResponse(response.getBody(), infoStmtObj.BillingContract__c) ;
                        system.debug('http response-accrualBillId= ' + accrualBillId);
                        if(accrualBillId.containsIgnoreCase('ERROR')) {
                            system.debug('http response-accrualBillId= ' + accrualBillId) ;
                        }
                        system.debug('http accrualBillId= ' + accrualBillId);
                    } else {
                        /*
                        AuraHandledException auraEx = new AuraHandledException(response.getStatus()) ;
                        auraEx.setMessage(GlUt_Logger.getActualErrorMessage(response.getStatus())) ;
                        throw auraEx ;
						*/
                        String responseMessage = response.getBody() ;
                        system.debug('responseMessage= ' + responseMessage);
                        return 'ERROR: ' + responseMessage ;
                    }
                }
            }
        } catch(Exception ex) {
            system.debug('Exception = ' + ex);
            GlUt_Logger.logException(ex) ;
            String errorMessage = 'ERROR: ' + GlUt_Logger.getActualErrorMessage(ex.getMessage()) ;
            return errorMessage ;
        }
        
        //accrualBillId =  'a2i1v000000pFb4AAE' ;
        system.debug('accrualBillId= ' + accrualBillId);
        return accrualBillId ;
    }
    
}