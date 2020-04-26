/**********************************************************************************************
@author      : Echo : Amit K.
@date        : 17 Jan 2019
@description : Interface having set of methods Implemented in PyAp_CardPaymentHttpRequestRepository
**********************************************************************************************/
public Interface PyAp_CardPaymentHttpRequestInterface{
      HttpResponse makeCallout(String apiCredential, String webserviceName, String urlParams, Integer timeout, String contentType,String payload);
      PyPr_PaymentAuthKeyResponseParameters getAuthKeyStructuredResponse(HttpResponse response);
      PyPr_PaymentResponseParameters  getPaymentStructuredResponse(HttpResponse response);
}