/**********************************************************************************************
@author      : Echo : Amit K.
@date        : 17 Jan 2019
@description : Repository Class for implementation details having method specified in PyAp_CardPaymentHttpRequestInterface.
**********************************************************************************************/
public with sharing class PyAp_CardPaymentHttpRequestRepository implements PyAp_CardPaymentHttpRequestInterface{

    public static final String BPOINT_AUTHKEYREQUEST = 'BPointAuthKeyRequest';
    public static final String BPOINT_PAYMENTREQUEST = 'BPointPaymentRequest';
    public static final String AUTHORIZATION = 'Authorization';
    public static final String POST = 'POST';
    public static final String CONTENT_TYPE = 'Content-Type';
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @param       : String apiCredential, String webserviceName, String urlParams, Integer timeout, String contentType,String payload
    @return      : HttpResponse
    @description : This class is used to make the callout @ BPoint in order to get 
                   AuthKey Id or Processing the Card Payment.
    **********************************************************************************************/
    public Static HttpResponse makeCallout(String apiCredential, String webserviceName, String urlParams, Integer timeout, String contentType,String payload){// build the request
        Blob blobCred;
        HttpRequest request = new HttpRequest(); 
        if(string.isNotBlank(apiCredential)){
            blobCred = Blob.valueOf(apiCredential);
            request.setHeader(AUTHORIZATION,EncodingUtil.base64Encode(blobCred));
        }
        request.setMethod(POST);
        urlParams = urlParams == null ? '' : urlParams;
        request.setEndpoint(getEndPoint(webserviceName) + urlParams);
        request.setHeader(CONTENT_TYPE, contentType);
        
        request.setBody(payload);
        request.setTimeout(timeout);
        
        // invoke the endpoint using the Http class
        Http http = new Http();
        return http.send(request);
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @param       : HttpResponse response
    @return      : PyPr_PaymentAuthKeyResponseParameters
    @description : This class is used to structure the response got from Bpoint AuthKey end point . 
    **********************************************************************************************/
     public static PyPr_PaymentAuthKeyResponseParameters getAuthKeyStructuredResponse(HttpResponse response){
        PyPr_PaymentAuthKeyResponseParameters authKeyResponse;
        authKeyResponse = PyPr_PaymentAuthKeyResponseParameters.parse(response.getBody());
        System.debug('*****authKeyResponse'+authKeyResponse);
        return authKeyResponse;
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @param       : HttpResponse response
    @return      : PyPr_PaymentResponseParameters
    @description : This class is used to structure the response got from Bpoint process payment gateway . 
    **********************************************************************************************/
    public static PyPr_PaymentResponseParameters getPaymentStructuredResponse(HttpResponse response){
        PyPr_PaymentResponseParameters paymentResponse;
        paymentResponse = PyPr_PaymentResponseParameters.parse(response.getBody());
        System.debug('*****paymentResponse'+paymentResponse);
        return paymentResponse;
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @param       : String webserviceName
    @return      : String
    @description : This class is used to fetch the end point details from Meta Data type . 
    **********************************************************************************************/
    private static BPointInterfaceParameters__mdt settings;
    private static String getEndPoint(String webserviceName) {
        /*  if (settings == null) {
            for (BPointInterfaceParameters__mdt bPoint : [select AuthkeyEndpoint__c, PaymentEndpoint__c from BPointInterfaceParameters__mdt limit 1]) {
            settings = bPoint;
            break;
            }
        }*/
        settings = PyAp_CardPaymentRepository.getBPointDetails(PyAp_Constants.BPOINTINTERFACEPARAMSETTINGQUERY);
        if(settings != null){    
            if (webserviceName == BPOINT_AUTHKEYREQUEST) return settings.AuthkeyEndpoint__c;
            if (webserviceName == BPOINT_PAYMENTREQUEST) return settings.PaymentEndpoint__c;
        }
        return null;
    }
}