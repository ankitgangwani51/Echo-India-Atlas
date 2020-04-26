/**********************************************************************************************
@author      : Echo : Amit K.
@date        : 17 Jan 2019
@description : Repository Class for implementation details having method specified in PyAp_CardPaymentRepositoryInterface.
**********************************************************************************************/
public with sharing class PyAp_CardPaymentRepository implements PyAp_CardPaymentRepositoryInterface {
    private static List<String> contractFields;
    static{
        // Get Fields from the Billing Contract Object
        contractFields = new List<string>();
        contractFields.add(GlUt_APIConstantsContracts.CONTRACTNAMEAPINAME);
        contractFields.add(GlUt_APIConstantsContracts.CUSTOMERAPINAME);
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @param       : Id contractId
    @return      : BillingContract__c
    @description : This class is used to fetch Billing Contract Details
    **********************************************************************************************/
    @AuraEnabled
    public static BillingContract__c getBillingContract(Id contractId){
        BillingContract__c billingContract = (BillingContract__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsContracts.CONTRACTAPINAME, 
                                                                                                     contractId, 
                                                                                                     contractFields);
        return billingContract;
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @param       : string contractNo, Id contractId
    @return      : String
    @description : This class is used to get the structured authentication key payload request.
    **********************************************************************************************/
    @AuraEnabled
    public static String getAuthenticationRequestPayload(string contractNo, Id contractId){
        string payload;
        BPointInterfaceParameters__mdt bPointDetails = getBPointDetails(PyAp_Constants.BPOINTINTERFACEPARAMSETTINGQUERY);
        AuthKeyRequestPayload authKeyPayload = new AuthKeyRequestPayload(bPointDetails, contractNo, contractId);
        payload = replaceReservedCharacter(Json.serialize(authKeyPayload));
        return payload;    
    }
     public static String replaceReservedCharacter(String payload){
          return payload.replace(PyAp_Constants.CURRENCY_REPLACED, PyAp_Constants.CURRENCY_RESERVED);
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @param       : string query
    @return      : BPointInterfaceParameters__mdt
    @description : This class is used to get BPoint details from Metda data type.
    @revesion	 : Dependra Singh - Date -11-03-2019- Package Fixes
    **********************************************************************************************/
    @AuraEnabled
    public static BPointInterfaceParameters__mdt getBPointDetails(string query){
        List<BPointInterfaceParameters__mdt> mdts = new  List<BPointInterfaceParameters__mdt>();
        if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap != null && GlUt_CustomMetaDataUtility.customMetadataRecordsMap.keyset().size()  > 0){
            if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap.containsKey(query)){
                mdts = (List<BPointInterfaceParameters__mdt>)GlUt_CustomMetaDataUtility.customMetadataRecordsMap.get(query);  
            }
        }else{
            mdts = (List<BPointInterfaceParameters__mdt>) new GlUt_CustomMetaDataUtility().getCustomMetadataRecords(query);
        }
        if(mdts != null && mdts.size() > 0){
            return mdts[0];
        }else{
            return null;
        }
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @param       : Id contractId, string amount, Id accountId, string paymentMethod
    @return      : 
    @description : This class is used to create the payment record in salesforce 
                    after successful payment in Bpoint gateway.
    **********************************************************************************************/
    @AuraEnabled
    public static void saveRecord(Id contractId, Id accountId,string amount, string paymentMethod){ 
        Payment__c newPayment = new Payment__c();
        newPayment.Account__c = accountId;
        newPayment.Amount__c = Decimal.valueOf(amount);
        newPayment.PaymentDate__c = System.today();
        newPayment.BillingContract__c = contractId;
        newPayment.PaymentMethod__c = paymentMethod;
        newPayment = (Payment__c) GlUt_FieldSecurity.cleanseFields(newPayment, false);
        insert newPayment;
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @description : This class is used to create the Auth Key Payload Request.
    **********************************************************************************************/
    public class AuthKeyRequestPayload{
        private PyPr_PaymentAuthKeyRequestParameters.ProcessTxnData ProcessTxnData;
        private PyPr_PaymentAuthKeyRequestParameters.IframeParameters IframeParamters;
        private String RedirectionUrl;
        /**********************************************************************************************
        @author      : Echo : Amit K.
        @date        : 17 Jan 2019
        @param       : BPointInterfaceParameters__mdt bPointDetails
        @description : constructor for Auth Key payload Request.
        **********************************************************************************************/
        public AuthKeyRequestPayload(BPointInterfaceParameters__mdt bPointDetails, string contractNo, Id contractId){
            ProcessTxnData = new PyPr_PaymentAuthKeyRequestParameters.ProcessTxnData(bPointDetails,contractNo);
            IframeParamters = new PyPr_PaymentAuthKeyRequestParameters.IframeParameters();
            PyPr_PaymentAuthKeyRequestParameters paymentAuthKeyRequestParameter = new PyPr_PaymentAuthKeyRequestParameters();
            RedirectionUrl = paymentAuthKeyRequestParameter.RedirectionUrl +'/'+ contractId +'/view';
        }
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @param       : string contractNo, string cardHolderName,string amount
    @return      : String
    @description : This class is used to get the structured payment payload request.
    **********************************************************************************************/
    @AuraEnabled
    public static String getPaymentRequestPayload(string contractNo, string cardHolderName,string amount){
        string payload;
        PaymentRequestPayload paymentPayload = new PaymentRequestPayload(contractNo,cardHolderName,amount);
        payload = replaceReservedCharacter(Json.serialize(paymentPayload));
        return payload;    
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @description : This class is used to create the Payment Payload Request.
    **********************************************************************************************/
    public class PaymentRequestPayload{
         private PyPr_PaymentRequestParameters.TxnReq TxnReq;
        /**********************************************************************************************
        @author      : Echo : Amit K.
        @date        : 17 Jan 2019
        @param       : string contractNo, string cardHolderName,string amount
        @description : constructor for Payment payload Request.
        **********************************************************************************************/
         public PaymentRequestPayload(string contractNo, string cardHolderName,string amount){
             TxnReq = new PyPr_PaymentRequestParameters.TxnReq(contractNo,cardHolderName,amount);
         }
    }
    
  
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @param       : 
    @return      : List<List<GlAp_FieldProps>>
    @description : This class is used to get fields and it's properties.
    **********************************************************************************************/
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrievePaymentFields() {
        try {
            List<String> pickListValuesList= new List<String>();
            Schema.DescribeFieldResult fieldResult = Payment__c.PaymentMethod__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }     
            String paymentMethodValues = System.Label.CuAp_ValidCardPaymentMethods;
            List<String> paymentMethodList = new List<String>();
            List<String> paymentMethods = paymentMethodValues.split(',');
            if(!paymentMethods.isEmpty()){
                for(String payMethod : paymentMethods){
                    if(pickListValuesList.contains(payMethod))
                        paymentMethodList.add(payMethod);
                }
            }
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            List<GLAp_FieldProps> allFieldProp = new List<GLAp_FieldProps>();
            allFieldProp = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsContracts.CONTRACTAPINAME, contractFields);
            for(GLAp_FieldProps contractProp: allFieldProp){
                contractProp.showLabel = true;
                contractProp.isEditable = false;
            }
            
            GlAp_FieldProps cardHolderName = new GlAp_FieldProps();
            cardHolderName.isFLSVisible = true;
            cardHolderName.isEditable = true;
            cardHolderName.editMode = true;
            cardHolderName.fieldName = PyAp_Constants.CARDHOLDERNAME_FIELDTYPE;
            cardHolderName.fieldLabel = PyAp_Constants.CARDHOLDERNAME_FIELDLABEL;
            cardHolderName.fieldType = PyAp_Constants.FIELDTYPETEXT;
            cardHolderName.isRequired = false;
            cardHolderName.changeEvent = false;
            cardHolderName.parentObject = GlUt_APIConstantsContracts.CONTRACTAPINAME;
            cardHolderName.isRequired = true;
            allFieldProp.add(cardHolderName);
            
            GlAp_FieldProps amount = new GlAp_FieldProps();
            amount.isFLSVisible = true;
            amount.isEditable = true;
            amount.editMode = true;
            amount.fieldName = PyAp_Constants.BILLEDAMOUNTLABEL;
            amount.fieldLabel = PyAp_Constants.BILLEDAMOUNTLABEL;
            amount.fieldType = PyAp_Constants.FIELDTYPETEXT;
            amount.isRequired = false;
            amount.changeEvent = false;
            amount.parentObject = GlUt_APIConstantsContracts.CONTRACTAPINAME;
            amount.isRequired = true;
            allFieldProp.add(amount);
            
            
            GlAp_FieldProps paymentMethod = new GlAp_FieldProps();
            paymentMethod.isFLSVisible = true;
            paymentMethod.isEditable = true;
            paymentMethod.editMode = true;
            paymentMethod.fieldName = PyAp_Constants.PAYMENTMETHOD_FIELDTYPE;
            paymentMethod.fieldLabel = PyAp_Constants.PAYMENTMETHOD_FIELDLABEL;
            paymentMethod.isRequired = false;
            paymentMethod.changeEvent = false;
            paymentMethod.fieldType = PyAp_Constants.FIELDTYPE_SELECT;
            paymentMethod.parentObject = GlUt_APIConstantsContracts.CONTRACTAPINAME;
            paymentMethod.pickListValues = paymentMethodList;
            paymentMethod.isRequired = true;
            allFieldProp.add(paymentMethod);
            
            GlAp_FieldProps paymentDate = new GlAp_FieldProps();
            paymentDate.isFLSVisible = true;
            paymentDate.isEditable = false;
            paymentDate.editMode = false;
            paymentDate.fieldName = PyAp_Constants.PAYMENTDATE_FIELDTYPE;
            paymentDate.fieldLabel = PyAp_Constants.PAYMENTDATE_FIELDLABEL;
            paymentDate.isRequired = false;
            paymentDate.changeEvent = false;
            paymentDate.fieldType = PyAp_Constants.FIELDTYPETEXT;
            paymentDate.parentObject = GlUt_APIConstantsContracts.CONTRACTAPINAME;
            allFieldProp.add(paymentDate);
            for(integer i=0; i < allFieldProp.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(allFieldProp[i]);
                if(secondEntryIndex < allFieldProp.size()){
                    lstEntry.add(allFieldProp[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
            }
            return twoColFormattedList;
         } catch (exception e) {
             GlUt_Logger.logException(e);
             throw new AuraHandledException(e.getMessage());
        }  
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
}