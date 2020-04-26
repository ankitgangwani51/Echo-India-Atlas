/**********************************************************************************************
@author      : Echo : Amit K.
@date        : 17 Jan 2019
@description : Parameter Class for payment request payload.
**********************************************************************************************/
public class PyPr_PaymentRequestParameters {
    public static final String CURRENCYAUD =  'AUD';
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @description : This class is used to create Payment Process transaction payload.
    **********************************************************************************************/
    public class TxnReq{
        private String Amount;
        private String Currency_x;
        private String Crn1;
        private CardDetails CardDetails;
        /**********************************************************************************************
        @author      : Echo : Amit K.
        @date        : 17 Jan 2019
        @param       : string contractNo, string cardHolderName,string amount
        @description : constructor for process payment transaction payload.
        **********************************************************************************************/
        public TxnReq(string contractNo, string cardHolderName,string amount){
            this.Amount = amount;
            this.Currency_x = CURRENCYAUD;
            this.Crn1 = contractNo +'_'+DateTime.now().format(GlUt_Constants.DATE_TIME_FORMAT);
            this.CardDetails = new CardDetails(cardHolderName);
        }
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 17 Jan 2019
    @description : This class is used to create Payment Process transaction payload with card holder information.
    **********************************************************************************************/
    public class CardDetails{
        private String CardHolderName;
        /**********************************************************************************************
        @author      : Echo : Amit K.
        @date        : 17 Jan 2019
        @param       : string cardHolderName
        @description : constructor for process payment transaction payload with card holder information.
        **********************************************************************************************/
        public CardDetails(string cardHolderName){
            this.CardHolderName = cardHolderName;
        }
    }
}