/******************************************************************************
@author      	Echo: Dependra Singh
@date      		28-Jan-2019
@description	Wrapper class to get data from lighting component after generating split payments
*******************************************************************************/
public class PyAp_SplitPaymentWrapper {
    public cls_records[] records;
    public Payment__c  objPayment;
    public Integer transferredAmount;	//666
    public Integer remaningAmount;	//334
    public class cls_records {
        public BillingContract__c objBillingContract;
        public Payment__c paymentObj;
    }
    public static PyAp_SplitPaymentWrapper parse(String json){
        return (PyAp_SplitPaymentWrapper) System.JSON.deserialize(json, PyAp_SplitPaymentWrapper.class);
    }
}