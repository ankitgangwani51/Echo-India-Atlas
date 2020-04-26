/******************************************************************************
@author         Echo: Patrick Dixon
@date           31 Jan 2018
@description    Extracts forecast data and packages as JSON
                to pass to the forecasting REST service
@revision(s)
@Revisions - 19-Apr-2018 Tarun , AT-2266 , Removed End Date reference.
@Revisions - 25-June-2018 Tarun , AT-2914,2935 , Added new param for PP end date based on Budget Renewal frequency.
*******************************************************************************/
public with sharing class PpIn_ForecastExtractData {
    
    private static final String CLASS_NAME = 'PpIn_ForecastExtractData';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    // utility methods used to format date and datetime fields for json as yyyy-MM-dd HH:mm:ss
    private static String dateToString(Date d) {return d != null ? String.valueOf(d) + ' 00:00:00' : null;}
    private static String dateToString(DateTime dt) {return dt != null ? String.valueOf(dt) : null;}
    
    private static String renewalFrequency; //AT-2935
    private static PaymentPlanType__c commingPlansTypeBudgets; // AT-5070
       
    public PpIn_ForecastObj data {get; private set;}        // the structured forecast data
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           31 Jan 2018
    @param          List<PaymentPlan__c> - list of payment plans for which a forecast is required
    @description    Constructor
    *******************************************************************************/
    public PpIn_ForecastExtractData (List<PaymentPlan__c> paymentPlans,PaymentPlanType__c plansTypeBudgets) { //AT-2935

        /* STEP 1: get all the data records required */
        // get the contract records
        List<BillingContract__c> contracts = GlUt_ContractUtilities.getContract(paymentPlans[0].BillingContract__c);     // single plan for now //AT-3174

        BlIn_BillCalcDataContainer container = new BlIn_BillCalcDataContainer(contracts);
        
        renewalFrequency = plansTypeBudgets.RenewalFrequency__c; //AT-2935
        commingPlansTypeBudgets = plansTypeBudgets;  // AT-5070
                                                    
        /* STEP 2: build the data using the DTO hierachy */
        data = new PpIn_ForecastObj(container, paymentPlans[0]);
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           31 Jan 2018
    @description    Subclass for Forecast
    *******************************************************************************/
    public class PpIn_ForecastObj {
        
        private PpIn_PaymentPlanObj PaymentPlan;       // one only for now

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           31 Jan 2018
        @param          BlIn_BillCalcDataContainer - container class instance
        @param          PaymentPlan__c - payment plan record
        @description    Constructor
        *******************************************************************************/
        private PpIn_ForecastObj(BlIn_BillCalcDataContainer container, PaymentPlan__c plan) {
            
            // build the payment plan DTO
            paymentPlan = new PpIn_PaymentPlanObj(container, plan);
        }            
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           31 Jan 2018
    @description    Subclass for Payment Plan
    *******************************************************************************/
    private class PpIn_PaymentPlanObj {
        
        private String StartDate;
        private String EndDate;
        private PpIn_PaymentPlanTypeObj PaymentPlanType;    // AT-5070
        private BlIn_BillCalcDataContainer.BlIn_BillCalcContractObj Contract;

        /******************************************************************************
        @author         Echo: Patrick Dixon
        @date           31 Jan 2018
        @param          BlIn_BillCalcDataContainer - container class instance
        @param          PaymentPlan__c - paymentPlan record
        @description    Constructor
        *******************************************************************************/
        private PpIn_PaymentPlanObj(BlIn_BillCalcDataContainer container, PaymentPlan__c paymentPlan) {
            
            // add the paymentPlan fields to this DTO
            StartDate = dateToString(paymentPlan.StartDate__c);
            //EndDate = dateToString(paymentPlan.EndDate__c);
                         
            //AT-2935 - Starts Here
            if(renewalFrequency != null && !String.isBlank(renewalFrequency))
                EndDate = dateToString(paymentPlan.StartDate__c.addDays(-1).addmonths(Integer.valueOf(renewalFrequency)));            
            else
                EndDate = dateToString(paymentPlan.StartDate__c.addDays(-1).addYears(1));
            //AT-2935 - Ends Here
            
            //AT-5070
            PaymentPlanType = new PpIn_PaymentPlanTypeObj(commingPlansTypeBudgets);
            
            // build the list of contract DTOs (one only for now)
            Contract = new BlIn_BillCalcDataContainer.BlIn_BillCalcContractObj(container, container.contracts[0]);
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           01 Feb 2018
    @return         String - JSON package
    @description    packages forecast data
    *******************************************************************************/
    public String retrieveData() {
        
        // serialise
        String JSONPayload = JSON.serialize(data);
        
        System.debug(DEBUG + 'Serialized JSON billing data: ' + JSONPayload);
        return JSONPayload;
    }
    
     /******************************************************************************
    @author         Echo: Neha R
    @date           29 Jan 2019
    @description    Subclass for Payment Plan Type
    *******************************************************************************/
    private class PpIn_PaymentPlanTypeObj {
        
       private Id PaymentPlanTypeId;
       private Boolean RollingAverage;

        /******************************************************************************
        @author         Echo: Neha R
        @date           29 Jan 2019
        @param          PaymentPlanType__c - container class instance       
        @description    Constructor
						// AT-5070
        *******************************************************************************/
        private PpIn_PaymentPlanTypeObj(PaymentPlanType__c paymentPlanType) {
            PaymentPlanTypeId = paymentPlanType.Id;
            //RollingAverage = paymentPlanType.RollingAverage__c; //AT-5685, Ankit, 30/04/2019, Remove field reference
        }
    }    
}