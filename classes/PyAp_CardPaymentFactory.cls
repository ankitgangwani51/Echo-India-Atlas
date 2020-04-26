/**********************************************************************************************
@author      : Echo : Amit K.
@date        : 17 Jan 2019
@description : Factory Class for calling the Repository methods having dafinations present in interface.
**********************************************************************************************/
public with sharing class PyAp_CardPaymentFactory { 
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @return      : PyAp_CardPaymentRepositoryInterface - Interface
    @description : This class is used to return the methods specified PyAp_CardPaymentRepositoryInterface
    **********************************************************************************************/
    public static PyAp_CardPaymentRepositoryInterface GetRepository() {
        return new PyAp_CardPaymentRepository();
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @return      : PyAp_CardPaymentHttpRequestInterface - Interface
    @description : This class is used to return the methods specified PyAp_CardPaymentHttpRequest Interface
    **********************************************************************************************/
    public static PyAp_CardPaymentHttpRequestInterface GetHttpRequestService() {
        return new PyAp_CardPaymentHttpRequestRepository();
    }
    
}