/******************************************************************************
@author         Echo: Vivek Sethi
@date           04 Dev 2018
@description    Wrapper class for holding Discount Type Parameters
@revision(s)    
*******************************************************************************/
public with sharing class CuBt_DiscountTypeParameters {
    public List<Id> discountTypeID; //List of discount Type selected.
    
    /**********************************************************************************************
  	@author      : Echo: Vivek Sethi
	@date        : 04 Dev 2018
    @params      : String json
    @return      : CuBt_DiscountTypeParameters
    @description : This method is used to Deserialize the parse JSON string.
    **********************************************************************************************/
    public static CuBt_DiscountTypeParameters parse(String json) {
        
        return (CuBt_DiscountTypeParameters) System.JSON.deserialize(json, CuBt_DiscountTypeParameters.class);
    }
}