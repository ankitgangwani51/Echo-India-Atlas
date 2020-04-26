/******************************************************************************
@author         Echo: Tarun Gupta
@date           16 Jan 2018
@description    Component controller for Payment Plan wizard
@Revisions      19-Apr-2018 Tarun , AT-2266 , Removed End Date reference.
                04 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
                06 June 2018, AT-2449 Tarun - Modified to add new parameter for contract Renewal Date
                02 July 2018, AT-2935 Tarun - Modified to update contract.BudgetPlanHold & create Payment plan card record 
                13/11/2018, Tarun, AT-3033 if there is no book , then add renewal date based on RenewalFrequency__c
                    
*******************************************************************************/
public with sharing class PyAp_PaymentPlanWizardCmpCtrlr {
 
    private static final String CLASS_NAME = 'PyAp_PaymentPlanWizardCmpCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    public static WizardObject wizObject;
    
    private static final List < String > contractListFields = new List <String> {
            GlUt_APIConstantsContracts.CUSTOMERAPINAME,
            GlUt_APIConstantsContracts.STATUSAPINAME,
            GlUt_APIConstantsContracts.BALANCEAPINAME
            }; 
                
    private static final List < String > contractFields = new List <String> {
            GlUt_APIConstantsContracts.DAYOFMONTHAPINAME,
            GlUt_APIConstantsContracts.DAYOFWEEKAPINAME,
            GlUt_APIConstantsContracts.DEBTRECPROFILEAPINAME,
            GlUt_APIConstantsContracts.CURRENTPAYMENTPLANTYPE,
            GlUt_APIConstantsContracts.PAYMENTMETHODTYPEAPINAME,
            GlUt_APIConstantsContracts.PAYPLANRENEWALDATEAPINAME,
            GlUt_APIConstantsContracts.CUSTOMERAPINAME, // Core 7a Changes - AT-2882
            GlUt_APIConstantsContracts.BUDGETPLANONHOLDAPINAME, // Core 7a Changes - AT-2935
            GlUt_APIConstantsContracts.CUSTOMERAPINAME // Core 7a Changes - AT-2935
                
            };
                
    private static final List < String > debtRecoveryProcessFields = new List <String> {
            GlUt_APIConstantsDebtRecoveryProcess.CURRENTSTAGEAPINAME
            };
                
       
    private static final List < String > balanceFieldList = new List <String> {
            GlUt_APIConstantsBalances.BALANCEAMOUNTAPINAME,
            GlUt_APIConstantsBalances.TOTALREFUNDAMOUNTAPINAME
            }; 
                
    private static final List <String> paymentPlanTypeFields = new List <String> {
            GlUt_APIConstantsPaymentPlanType.RESETDEBTRECAPINAME,
            GlUt_APIConstantsPaymentPlanType.DEBTRECPROFILEAPINAME,
            GlUt_APIConstantsPaymentPlanType.PLANTYPEAPINAME // Core 7a Changes - AT-2935
            };
                
    private static final List <String> paymentMethodTypeFields = new List <String> {
            GlUt_APIConstantsPaymentMethodType.NAMEAPINAME
            }; 
                
    // utility methods used to format date and datetime fields for json as yyyy-MM-dd HH:mm:ss
    private static String dateToString(Date d) {return d != null ? String.valueOf(d) + ' 00:00:00' : null;}
    private static String dateToString(DateTime dt) {return dt != null ? String.valueOf(dt) : null;}
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           16 Jan 2018
    @description    Wrapper class for Wizard variables
    *******************************************************************************/
    /*
    Screen  wizardprop element name         type
    ==============================================================================
    Base
            recordId                        Id (the Id of the host page record) - should be the same as contractId but use contractId
            contractId                      Id (the Id of the Contract)         
            
    WS1     creditRefund                    True(If Refund / Transfer Credit Amount option is selected)
                                            False(If Incorporate Credit Amount in Instalment Calculation option is selected)

    WS2     objPayment                      True(If Refund / Transfer Credit Amount option is selected)
                                            False(If Incorporate Credit Amount in Instalment Calculation option is selected)

                                            Payment__c
                                            Amount__c = 
                                            BillingContract__c
                                            Account__c

    WS3     paymentPlanRecord:              PaymentPlan__c
                                            StartDate__c = system.today()
                                            PaymentPlanType__c = from screen
                                            NumberOfInstalments__c = from screen

            lstInstalments                  List<Instalment__c> = from screen

            contractRecord:                 BillingContract__c
                                            DayOfMonth__c = from screen
                                            DayOfWeek__c = from screen
                                            CurrentPaymentPlanType__c = New PPT
                                            PaymentPlanRenewalDate__c = today + 1year

           bankAccountDetailId              Id (Existing bank account detail Id to map with contract(Field - BankAccountDetails__c))
           selectedPaymentMethod            This will contain selected payment method.

            
                                                        
    */    
    
    public class WizardObject {
        
        public Id recordId;
        public Id contractId;
        public List<Instalment__c> lstInstalments;    // List of Instalments to be Inserted
        public PaymentPlan__c paymentPlanRecord;
        public Decimal forecastAmount ;  // Sudhir AT2199
        public Payment__c objPayment;
        public String creditRefund;
        public String creditValue;
        public String dayOfMonth;
        public String payMethod;
        public String dayOfWeek;
        public BankAccountDetails__c bankAccountDetail;
        public string bankAccountDetailId;
        public string selectedPaymentMethod;
        //public List<BlAp_CombinedRecord> spreadRemainingInstal; 
        public Decimal creditAmount;
        @TestVisible
        private boolean isCreditTransfer; 
        @TestVisible
        private boolean isCreditRefund;
        @TestVisible
        public String planStartDate; 
        @TestVisible
        public String contractRenewalDate; 
        /*@TestVisible
		public String planEndDate;*/
        @TestVisible
        private boolean isCreditWriteOff;
     
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           16 Jan 2018
    @param          String - wizardprop
    @description    Updates the wizard properties
    *******************************************************************************/
    @AuraEnabled
    public static Map<String, String> WizardStatus(String wizardprop) {
        
        Map<String, String> status = new Map<String, String>();
        try {
            // build the wizard object from the wizard properties
            UpdateWizardProperties(wizardprop);
            
            //To check whether there is any credit on contract , we will return boolean value
            String creditValue = getCreditDetails(wizObject.contractId);        
            String creditDetails = 'false';
            
            if(String.isNotBlank(creditValue)){
                creditDetails = 'true';
            }
            status.put('creditDetails', creditDetails);     // true if account = Household account
            status.put('creditRefund', wizObject.creditRefund);
            status.put('creditValue', creditValue);
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        System.debug(DEBUG + 'status: ' + status);
        return status;
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           16 Jan 2018
    @param          String - wizardprop
    @description    Updates the wizard properties
    *******************************************************************************/
    public static void UpdateWizardProperties(String wizardprop) {
        // strip out all the SObject type references from the json
        wizardprop = wizardprop.replaceAll('"sobjectType":"(.*?)"(,|[^}]*)', '');
        // and deserialise it
        wizObject = (WizardObject)System.JSON.deserializeStrict(wizardprop, WizardObject.class);        
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           16 Jan 2018
    @param          String - json string of object wizardprop
    @param          String - wizardprop
    @description    Method called by wizard to complete the payment plan execution process.
    *******************************************************************************/
    @AuraEnabled
    public static Id  paymentPlanWizard(String wizardprop) { 
        Savepoint sp = Database.setSavepoint();
        String debtRecoveryProfile = '';
        
        PaymentPlanType__c paymentPlanType;
        
        try {
            // build the wizard object from the wizard properties
            UpdateWizardProperties(wizardprop); 
            if (wizObject.paymentPlanRecord != null) {
                
                if (wizObject.planStartDate != null) {
                    wizObject.paymentPlanRecord.StartDate__c = Date.valueOf(wizObject.planStartDate);
                }
                else {
                    wizObject.paymentPlanRecord.StartDate__c = system.today();  
                }
                
                if (wizObject.forecastAmount != null) {
                    wizObject.paymentPlanRecord.ForecastAmount__c = wizObject.forecastAmount;   // Sudhir AT2199
                }
                
                wizObject.paymentPlanRecord.BillingContract__c = wizObject.contractId;
                //Cleanse payment plan record.
                wizObject.paymentPlanRecord = (PaymentPlan__c) GlUt_FieldSecurity.cleanseFields(wizObject.paymentPlanRecord, false);
                insert wizObject.paymentPlanRecord; //Create Payment plan record.
                
                Boolean resetDebt = false;
                Id planTypeId = wizObject.paymentPlanRecord.PaymentPlanType__c;
                //Fetch payment plan type on the basis of payment plan Id.
                paymentPlanType = [Select Id,
                                   ResetDebtRecovery__c,
                                   DebtRecoveryProfile__c,
                                   PlanType__c,
                                   RenewalFrequency__c
                                   from PaymentPlanType__c Where Id=:planTypeId];
             
                
                if (paymentPlanType.Id != null) {
                    
                    resetDebt = paymentPlanType.ResetDebtRecovery__c;
                    
                    if (paymentPlanType.DebtRecoveryProfile__c != null) {
                        debtRecoveryProfile = paymentPlanType.DebtRecoveryProfile__c;
                    }
                }
                
                
                
                if (wizObject.isCreditRefund != null && wizObject.isCreditTransfer != null) {
                    creditRefundTransfer();  //Call credit Refund transfer method.  
                }
                
                if (resetDebt) {
                    //Reset the debt recovery process.
                    List<DebtRecoveryProcess__c> lstDebtRecProcess = new List<DebtRecoveryProcess__c>();
                    lstDebtRecProcess =  [Select Id,
                                          CurrentStage__c 
                                          from DebtRecoveryProcess__c
                                          WHERE BillingContract__c =:wizObject.contractId 
                                          AND CurrentStage__c !=: GlUt_Constants.COMPLETED];
              
                    
                    if (lstDebtRecProcess != null) {
                        for (DebtRecoveryProcess__c debtRecProcess : lstDebtRecProcess) {
                            debtRecProcess.CurrentStage__c = GlUt_Constants.COMPLETED;
                            debtRecProcess.CurrentStageDateTime__c = system.today();
                            debtRecProcess.Flag__c = true;        //AT-2718   set flag__c to True  to avoid the validation rule firing on DRP      
                            debtRecProcess.NextStage__c = null;         //AT-2969
                            debtRecProcess.ProcessComplete__c = true;   //AT-2969
                        }
                        //Cleanse Debt recovery process
                        lstDebtRecProcess = (List<DebtRecoveryProcess__c>) GlUt_FieldSecurity.cleanseFields(lstDebtRecProcess, false);
                        update lstDebtRecProcess;
                        
                        //AT-2718   set flag__c to false again   
                        for (DebtRecoveryProcess__c debtRecProcess : lstDebtRecProcess) {
                            debtRecProcess.Flag__c = false;        
                        }
                        //Cleanse Debt Recovery Process records.
                        lstDebtRecProcess = (List<DebtRecoveryProcess__c>) GlUt_FieldSecurity.cleanseFields(lstDebtRecProcess, false);
                        //Update Debt Recovery Process records.
                        update lstDebtRecProcess; 
                    }
                }
            }  
            
            if (wizObject.lstInstalments != null) {
                
                // To update Instalment records with payment plan Id
                for (Instalment__c objInstal : wizObject.lstInstalments) {
                    objInstal.PaymentPlan__c = wizObject.paymentPlanRecord.Id;
                }
                wizObject.lstInstalments = (List<Instalment__c>) GlUt_FieldSecurity.cleanseFields(wizObject.lstInstalments, false);
                //Create instalments on the basis of payment plan
                insert wizObject.lstInstalments;
            }
            
            if (wizObject.contractId != null) {
                //Fetch billing contract on the basis of contract Id.
                BillingContract__c contract  = [Select Id,
                                                 DayOfMonth__c,
                                                 DayOfWeek__c,
                                                 CurrentPaymentPlanType__c,
                                                 PaymentMethodType__c,
                                                 PaymentPlanRenewalDate__c,
                                                 DebtRecoveryProfile__c,
                                                 AccountName__c,
                                                 BudgetPlanHold__c
                                                 from BillingContract__c Where Id=:wizObject.contractId];
              
                
                 
                List<PaymentMethodType__c> lstPaymentMethodType = new List<PaymentMethodType__c>();
                //Fetch payment method types on the basis of payment method.
                lstPaymentMethodType = [Select Id,Name from PaymentMethodType__c Where Name =: wizObject.payMethod];
      
                
                if (contract.Id != null) {
                    
                    contract.DayOfMonth__c = wizObject.dayOfMonth;
                    contract.DayOfWeek__c = wizObject.dayOfWeek;
                    contract.CurrentPaymentPlanType__c = wizObject.paymentPlanRecord.PaymentPlanType__c;
                    
                    if (!lstPaymentMethodType.isEmpty()) {
                        contract.PaymentMethodType__c = lstPaymentMethodType[0].Id;
                    }
                    
                    // AT-2449                
                    if (wizObject.contractRenewalDate != null){ // This will have value only in case of Budget plan
                        contract.PaymentPlanRenewalDate__c = date.valueOf(wizObject.contractRenewalDate);
                    }
                    else if (wizObject.planStartDate != null) {
                        contract.PaymentPlanRenewalDate__c = Date.valueOf(wizObject.planStartDate).addYears(1);
                    }
                    else {
                        contract.PaymentPlanRenewalDate__c = date.today().addYears(1);
                    }
                    // AT-3033 if there is no book , then add renewal date based on RenewalFrequency__c
                    if(paymentPlanType.PlanType__c == Label.CuAp_PaymentPlanTypePlanTypeBudgetPlan && 
                       wizObject.planStartDate != null &&
                       wizObject.contractRenewalDate ==  null && 
                       paymentPlanType.RenewalFrequency__c != null){
                           String planRenewDate = dateToString(date.valueOf(wizObject.planStartDate).addDays(-1).addmonths(Integer.valueOf(paymentPlanType.RenewalFrequency__c)));
                           contract.PaymentPlanRenewalDate__c = Date.valueOf(planRenewDate);
                           contract.PaymentPlanRenewalDate__c = date.newInstance(contract.PaymentPlanRenewalDate__c.year(), contract.PaymentPlanRenewalDate__c.month(), 01) ;
                       }
                    contract.DebtRecoveryProfile__c = debtRecoveryProfile;
                    
                    //AT-2935 Starts Here
                    if(paymentPlanType.PlanType__c == Label.CuAp_PaymentPlanTypePlanTypeBudgetPlan && contract.BudgetPlanHold__c){
                        
                        contract.BudgetPlanHold__c = false;
                        //Fetch forecasted Instalments on the basis of contract Id.
                        List<ForecastedInstalment__c> listForecastedInstalment =  [SELECT Id,Corrected__c 
                                                                                   FROM ForecastedInstalment__c 
                                                                                   WHERE BillingContract__c =: contract.Id
                                                                                   AND Corrected__c = false ];
                        if(listForecastedInstalment != null && listForecastedInstalment.size() > 0){
                            for(ForecastedInstalment__c objForecastInstalment : listForecastedInstalment){
                                objForecastInstalment.Corrected__c = true;
                            }   
                            //Update Forecasted Instalments records
                            // Added by Dependra -03-12-2018 , Clayton Issue fix.
                            if(listForecastedInstalment != null && !listForecastedInstalment.isEmpty()){
                                listForecastedInstalment = ( List<ForecastedInstalment__c>) GlUt_FieldSecurity.cleanseFields(listForecastedInstalment, false);
                                update listForecastedInstalment;
                            }
                        }
                    }
                    
                    if(contract.PaymentMethodType__c != null){
                        
                        if(lstPaymentMethodType[0].Name == Label.PpUt_PaymentMethodType){ // Payment Card
                            //Create new payment plan record.
                            PaymentPlanCard__c objPaymentPlanCard = new PaymentPlanCard__c();
                            objPaymentPlanCard.BillingContract__c = contract.Id;
                            objPaymentPlanCard.AccountName__c = contract.AccountName__c;
                            objPaymentPlanCard.PaymentPlan__c = wizObject.paymentPlanRecord.Id;
                            objPaymentPlanCard.RequestedOn__c = system.today();
                            //Cleasne payment plan card fields.
                            objPaymentPlanCard = (PaymentPlanCard__c) GlUt_FieldSecurity.cleanseFields(objPaymentPlanCard, false);
                            //Create payment plan record.
                            insert objPaymentPlanCard;
                        }
                    }
                    
                    //AT-2935 Ends Here
                    
                    // Core 7a Changes - AT-2882
                    List<BankAccountDetails__c> lstbankAccountDetail = new List<BankAccountDetails__c>();
                    if(wizObject.bankAccountDetailId != null){
                        contract.BankAccountDetails__c = wizObject.bankAccountDetailId;
                    }else{
                        if(wizObject.bankAccountDetail != null && string.isNotBlank(wizObject.bankAccountDetail.NameOnAccount__c) && 
                           string.isNotBlank(wizObject.bankAccountDetail.BankAccountNumber__c) && string.isNotBlank(wizObject.bankAccountDetail.BankAccountSortCode__c)){
                               BankAccountDetails__c objBankAccOuntDetail = new BankAccountDetails__c();
                           //    objBankAccountDetail.Name= wizObject.bankAccountDetail.NameOnAccount__c;
                               objBankAccountDetail.BankAccountNumber__c= wizObject.bankAccountDetail.BankAccountNumber__c;
                               objBankAccountDetail.NameOnAccount__c= wizObject.bankAccountDetail.NameOnAccount__c;
                               objBankAccountDetail.BankAccountSortCode__c= wizObject.bankAccountDetail.BankAccountSortCode__c;
                               objBankAccountDetail.Account__c= contract.AccountName__c ;
                               
                               //AT-4920
                               BankBranch__c bankBranch = PyAp_BranchCodeUtility.validateSortCodeEntered(wizObject.bankAccountDetail.BankAccountSortCode__c);
                               if(bankBranch != null)
                                   objBankAccountDetail.Validated__c = True;
                               
                               lstbankAccountDetail.add(objBankAccountDetail);
                               
                           }
                    }
                    
                    if(!lstbankAccountDetail.isEmpty()){
                        //Create Bank Account details records.
                        lstbankAccountDetail = (List<BankAccountDetails__c>) GlUt_FieldSecurity.cleanseFields(lstbankAccountDetail, false);
                        insert lstbankAccountDetail;
                        if(lstbankAccountDetail[0].Id != null){
                            contract.BankAccountDetails__c = lstbankAccountDetail[0].Id;
                        }
                    }
                    //Cleanse Billing contract fields
                    contract = (BillingContract__c) GlUt_FieldSecurity.cleanseFields(contract, false);
                    //Update the contract records.
                    update contract;
                }
            }
            return wizObject.contractId;
        } catch (exception e) {
            Database.rollback(sp);
            System.debug('exception = '+e.getMessage());
            GlUt_Logger.logException(e);         
            throw new AuraHandledException(e.getMessage());
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           16 Jan 2018
    @param          String - json string of object wizardprop
    @param          String - wizardprop
    @description    This method is used to transfer/Refund the credit payment using utility classes.
    *******************************************************************************/
    public static void creditRefundTransfer() {
        
        if (wizObject.contractId != null && wizObject.objPayment != null) {
            BillingContract__c contract = (BillingContract__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsContracts.CONTRACTAPINAME, 
                                                                                    wizObject.contractId, 
                                                                                    contractListFields);
            if (contract.Id != null) {
                if (wizObject.isCreditRefund) {
                    PyAp_RefundTransferCreditUtility.refundCredit(wizObject.objPayment, contract);
                    
                } else if (wizObject.isCreditTransfer) {
                    PyAp_RefundTransferCreditUtility.transferCredit(wizObject.objPayment, contract);
                }
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           16 Jan 2018
    @param          String - json string of object wizardprop
    @param          String - wizardprop
    @description    Method called on the basis of contract Id in order to fetch the balance amount.
    *******************************************************************************/
    @AuraEnabled
    public static String getCreditDetails(Id contractId) { 
        String getCreditDetailsVal;
        try {
            getCreditDetailsVal = string.valueOf(GlUt_BalanceUtilities.getBalanceAmount(contractId,contractListFields,balanceFieldList));
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return getCreditDetailsVal;
    }
}