/**********************************************************************************************
@author      : Echo:Amit K.
@date        : 19 June 2018
@description : This class is used to Deserialize the parse JSON string.
**********************************************************************************************/
public with sharing class PyPr_DirectDebitRequestParameters {
    public Date requestDate; // The Date up to which extract Instalments up to. 
  
    /**********************************************************************************************
    @author      : Echo:Amit K.
    @date        : 19 June 2018
    @params      : String json
    @return      : PyPr_DirectDebitRequestParameters
    @description : This method is used to Deserialize the parse JSON string.
    **********************************************************************************************/
    public static PyPr_DirectDebitRequestParameters parse(String json) {
        return (PyPr_DirectDebitRequestParameters) System.JSON.deserialize(json, PyPr_DirectDebitRequestParameters.class);
    }
}