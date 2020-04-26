/**********************************************************************************************
@author      : Echo : Amit K.
@date        : 17 Jan 2019
@description : Parameter Class for Auth key response payload.
**********************************************************************************************/
public class PyPr_PaymentAuthKeyResponseParameters {
    public class APIResponse{
        public Integer ResponseCode;
        public String ResponseText;
    }
    public String AuthKey;
    public APIResponse APIResponse;
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @param       : String json
    @return      : PyPr_PaymentAuthKeyResponseParameters
    @description : This class is deserialize the JSON payload.
    **********************************************************************************************/
    public static PyPr_PaymentAuthKeyResponseParameters parse(String json) {
        return (PyPr_PaymentAuthKeyResponseParameters) System.JSON.deserialize(json, PyPr_PaymentAuthKeyResponseParameters.class);
    }

}