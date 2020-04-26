/**********************************************************************************************
@author      : Echo : Amit K.
@date        : 17 Jan 2019
@description : Interface having set of methods Implemented in PyAp_CardPaymentRepository
**********************************************************************************************/
public Interface PyAp_CardPaymentRepositoryInterface {
     BillingContract__c getBillingContract(Id contractId);
     String getAuthenticationRequestPayload(string contractNo, Id contractId);
     List<List<GlAp_FieldProps>> retrievePaymentFields();
     String getPaymentRequestPayload(string contractNo, string cardHolderName,string amount);
     BPointInterfaceParameters__mdt getBPointDetails(string query);
     void saveRecord(Id contractId, Id accountId, string amount, string paymentMethod); 
}