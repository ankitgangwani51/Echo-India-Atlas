/**********************************************************************************************
@author      : Echo : Amit K.
@date        : 17 Jan 2019
@description : Parameter Class for Auth Key payload Request.
**********************************************************************************************/
public class PyPr_PaymentAuthKeyRequestParameters {
    public static final String PAYMENT = 'payment';
    public static final String CURRENCYAUD = 'AUD';
    public static final String SUB_TYPE = 'single';
    public static final String CSSSTYLE = '.control-label{color:blue;}';
    public static final String REDIRECTION_URL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/'+ GlUt_APIConstantsContracts.CONTRACTAPINAME;
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @description : This class is used to create AuthKey Request payload.
    **********************************************************************************************/
    public class ProcessTxnData {
        private String Action; 
        private Boolean TestMode; 
        private Decimal Amount ; 
        private String Currency_x ; 
        private String Crn1; 
        private Integer TokenisationMode ;
        private String SubType ;
        private String Type ; 
        private Object EmailAddress ;
        private Boolean AmexExpressCheckout ; 
        private DVTokenData DVTokenData; 
        /**********************************************************************************************
        @author      : Echo : Amit K.
        @date        : 17 Jan 2019
        @param       : BPointInterfaceParameters__mdt bPointDetails
        @description : constructor for AuthKey Request payload.
        **********************************************************************************************/
        public ProcessTxnData(BPointInterfaceParameters__mdt bPointDetails, string contractNo){
            this.Action = PAYMENT;
            this.TestMode = bPointDetails != null ? bPointDetails.Testmode__c : null;
            this.Amount =  0.00;
            this.Currency_x = CURRENCYAUD;
            this.Crn1 = contractNo+'_'+DateTime.now().format(GlUt_Constants.DATE_TIME_FORMAT);
            this.TokenisationMode = 1;
            this.SubType = SUB_TYPE;
            this.Type = bPointDetails != null ? bPointDetails.TransactionType__c : null;
            this.EmailAddress = null;
            this.AmexExpressCheckout = false;
            this.DVTokenData = new DVTokenData();
            
        }
    }
	public String RedirectionUrl = REDIRECTION_URL;
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @description : This class is used to create AuthKey Request payload.
    **********************************************************************************************/
    public class IframeParameters {
        private String CSS; 
        private Boolean ShowSubmitButton;
        /**********************************************************************************************
        @author      : Echo : Amit K.
        @date        : 17 Jan 2019
        @param       : 
        @description : constructor for AuthKey Request payload.
        **********************************************************************************************/
        public IframeParameters(){
            this.CSS = CSSSTYLE;
            this.ShowSubmitButton = false;
        }
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @description : This class is used to create AuthKey Request payload.
    **********************************************************************************************/
    public class DVTokenData {
        /**********************************************************************************************
        @author      : Echo : Amit K.
        @date        : 17 Jan 2019
        @param       : 
        @description : constructor for AuthKey Request payload.
        **********************************************************************************************/
       public DVTokenData (){
            
        }
        
    }
   
}