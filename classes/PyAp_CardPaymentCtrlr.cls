/******************************************************************************
@author         Echo: Amit Kumar
@date           17 Jan 2019
@description    Component controller for Card Payment Lightning component.
*******************************************************************************/
public with sharing class PyAp_CardPaymentCtrlr {
    public static final String BPOINT_AUTHKEYREQUEST = 'BPointAuthKeyRequest';
    public static final String BPOINT_PAYMENTREQUEST = 'BPointPaymentRequest';
    public static final String CONTENT_TYPE = 'application/json; charset=utf-8';
    public static final Integer TIME_OUT = 6000;
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @param       : Id contractId
    @return      : ContainerWrapper
    @description : This class is used to fetch fields and it's properties with auth key from 
                   Bpoint authentication key gateway.
    **********************************************************************************************/
    @AuraEnabled
    Public static ContainerWrapper getInfoToDisplay(Id contractId){
        try{
            //instance of wrapper class
            ContainerWrapper resultContainer = new ContainerWrapper();
            PyAp_CardPaymentRepositoryInterface repoInterface = PyAp_CardPaymentFactory.GetRepository(); 
            resultContainer.fieldPropList = repoInterface.retrievePaymentFields();
            resultContainer.billingContract = repoInterface.getBillingContract(contractId);
            string contractNo = resultContainer.billingContract.Name;
            String payload = repoInterface.getAuthenticationRequestPayload(contractNo,contractId);
            if(!string.isEmpty(payload)){
                PyAp_CardPaymentHttpRequestInterface httpRequestInterface = PyAp_CardPaymentFactory.GetHttpRequestService();
                BPointInterfaceParameters__mdt bPointDetails = repoInterface.getBPointDetails(PyAp_Constants.BPOINTINTERFACEPARAMSETTINGQUERY);
                if(bPointDetails != null){
                    resultContainer.bPointDetails = bPointDetails;
                    String apiCredentials = bPointDetails.Username__c+'|'+bPointDetails.Password__c;
                    HttpResponse response = httpRequestInterface.makeCallout(apiCredentials,BPOINT_AUTHKEYREQUEST,null,TIME_OUT,CONTENT_TYPE,payload); 
                    if(response.getStatusCode() == 200){
                        PyPr_PaymentAuthKeyResponseParameters authKeyResponse = httpRequestInterface.getAuthKeyStructuredResponse(response);
                        if(authKeyResponse.APIResponse.ResponseCode != 0)
                            resultContainer.errorText = authKeyResponse.APIResponse.ResponseText;
                        else
                            resultContainer.AuthKey = authKeyResponse.AuthKey;
                    }
                    else{
                        System.debug('**********BAD REQUEST*************');
                        resultContainer.errorText = PyAp_Constants.BPOINT_SERVER_CONNECTION_FAILURE;
                    }
                }
            }
            return resultContainer;
        }
        catch (exception e) {
            String errorMsg = GlUt_Logger.getActualErrorMessage(e.getMessage());
            GlUt_Logger.logException(e);
            throw new AuraHandledException(errorMsg);
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @return      : ContainerWrapper
    @description : This is a wrapper class contains FieldProperty Details AND BPoint interface details.
    **********************************************************************************************/
    public class ContainerWrapper {
        @AuraEnabled public List<List<GlAp_FieldProps>> fieldPropList;
        @AuraEnabled public String authKey;
        @AuraEnabled public String errorText;
        @AuraEnabled public BillingContract__c billingContract;
        @AuraEnabled public BPointInterfaceParameters__mdt bPointDetails;
        @AuraEnabled public String todaysDate = System.now().format('dd-MMM-yyyy'); //AT-5404, Ankit, 08/03/2019
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @param       : string contractNo, string cardHolderName, string amount, string authKey,
                   Id contractId, Id accountId, string paymentMethod
    @return      : ProcessPaymentWrapper
    @description : This class is used to process payment by hitting Bpoint gateway and save record in salesforce.
    **********************************************************************************************/
    @AuraEnabled
    Public static ProcessPaymentWrapper processPayment(string contractNo, string cardHolderName, string amount, string authKey, Id contractId, Id accountId, string paymentMethod){
        Savepoint sp;
        try{
            ProcessPaymentWrapper resultContainer = new ProcessPaymentWrapper();
            PyAp_CardPaymentRepositoryInterface repoInterface = PyAp_CardPaymentFactory.GetRepository();
            String paymentRequestPayload = repoInterface.getPaymentRequestPayload(contractNo,cardHolderName,amount);
            if(!string.isEmpty(paymentRequestPayload)){
                PyAp_CardPaymentHttpRequestInterface httpRequestInterface = PyAp_CardPaymentFactory.GetHttpRequestService();
                HttpResponse response = httpRequestInterface.makeCallout(null,BPOINT_PAYMENTREQUEST,authKey,TIME_OUT,CONTENT_TYPE,paymentRequestPayload); 
                if(response.getStatusCode() == 200){
                    sp = Database.setSavepoint();
                    PyPr_PaymentResponseParameters paymentResponse = httpRequestInterface.getPaymentStructuredResponse(response);
                    if(paymentResponse.APIResponse.ResponseCode != 0){
                        resultContainer.errorText = paymentResponse.APIResponse.ResponseText;
                    }else{
                        repoInterface.saveRecord(contractId,accountId,amount,paymentMethod);
                        resultContainer.successText = paymentResponse.APIResponse.ResponseText;
                        resultContainer.redirectionUrl = paymentResponse.RedirectionUrl;
                    }
                }else{
                    System.debug('**********BAD REQUEST*************');
                    resultContainer.errorText = PyAp_Constants.BPOINT_SERVER_CONNECTION_FAILURE;
                }
            }
            return  resultContainer;
        }
        catch (exception e) {
            String errorMsg = GlUt_Logger.getActualErrorMessage(e.getMessage());
            GlUt_Logger.logException(e);
            if(sp != null)
                Database.rollback(sp);
            throw new AuraHandledException(errorMsg);
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @return      : ProcessPaymentWrapper
    @description : This is a wrapper class used to hold payment status.
    **********************************************************************************************/
    public class ProcessPaymentWrapper {
        @AuraEnabled public String successText;
        @AuraEnabled public String errorText;
        @AuraEnabled public String redirectionUrl;
    }
        
}