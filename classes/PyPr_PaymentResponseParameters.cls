/**********************************************************************************************
@author      : Echo : Amit K.
@date        : 17 Jan 2019
@description : Parameter Class for Payment response payload.
**********************************************************************************************/
public class PyPr_PaymentResponseParameters {
   public class APIResponse{
        public Integer ResponseCode;
        public String ResponseText;
    }
    public String ResultKey;
    public String RedirectionUrl;
    public APIResponse APIResponse;
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @param       : String json
    @return      : PyPr_PaymentResponseParameters
    @description : This class is deserialize the JSON payload.
    **********************************************************************************************/
    public static PyPr_PaymentResponseParameters parse(String json) {
        return (PyPr_PaymentResponseParameters) System.JSON.deserialize(json, PyPr_PaymentResponseParameters.class);
    }
}