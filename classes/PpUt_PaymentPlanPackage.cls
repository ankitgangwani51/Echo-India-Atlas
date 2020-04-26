/******************************************************************************
@author         Echo: Patrick Dixon
@date           24 Jan 2018
@description    Wrapper class for a payment plan and instalments
@group          Utility
Revision(s)     Swati Mathur - 08-Mar-2018 -- did changes for EarliestStartDate__c for AT-2010  
Revision(s)     Tarun Gupta - 15-Mar-2018 -- did changes for getNextDayOfTheWeek - 
                Added new parameter for considering Days Notice for Fortnightly\Weekly Plans
Revision(s)     Tarun Gupta - 18-Apr-2018 -- Added check of null in determineAmountToBeSplit 
Revision(s)     Tarun Gupta - 19-Apr-2018 -- Removed End Date reference 
                06 June 2018, AT-2449 Tarun - Modified to add new parameter for contract Renewal Date and changes visibility of few variables to access them in different class
@Revisions      Tarun Gupta , 25-06-2018,AT-2913, Considering holidays and business hours while calculating days notice
@Revisions      Tarun Gupta , 03-07-2018,AT-2942,2993, Updating List of Instalments to be retained
@Revisions      Tarun Gupta , 13-11-2018,AT-4315, Updated logic for arrears on first Instalment
@Revisions      AT-4254, TG , 29/11/18 , Sent bank details linked to contract
@Revisions      AT-2701, TG , 21/12/18 , Updated to avoid to create instalments with amount less than 0, amount should be 0 in that case
@Revisions      CLB-33,CLB-76
@Revisions      CLB-100
@Revisions      CLB-31
*******************************************************************************/
public class PpUt_PaymentPlanPackage {
    
    private static final String CLASS_NAME = 'PpUt_PaymentPlanPackage';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    @TestVisible public BillingContract__c contract;
    public PaymentPlanType__c paymentPlanType;
    
    private Decimal balance;
    public Date planStartDate;
    public Date planEndDate;
    public Date planEndDateFromWizard;
    @AuraEnabled public Date planRenewalDate;
    @AuraEnabled public PaymentPlan__c paymentPlan;     // the new payment plan
    @AuraEnabled public List<Instalment__c> instalments;        // the list of calculated instalments with date and value fields populated 
    @AuraEnabled public Integer numberOfInstalments;        // actual number of instalments
    private Integer numberOfRollingInstalments;     // number of rolling instalments
    public Payment__c refund;       // a refund payment created as part of the payment plan (null if no refund required)
    public ForecastedInstalment__c forecastInstalment;      // a refund payment created as part of the payment plan (null if no refund required) AT-2942,2993
    public Map<Id,List<Instalment__c>> mapContractId2ListInstalmentToRetain; // To get list of Instalments to be retained AT-2942,2993
    public Map<Id,Decimal> mapContractId2InstalmentAmountForValidation; // To get Instalment Amount for Threshhold Validation AT-2942,2993


    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           24 Jan 2018
    @param          Contract__c contract 
                    (required fields: AccountName__c, CurrentPaymentPlanType__c, PaymentPlanRenewalDate__c, DayOfWeek__c, DayOfMonth__c)
    @param          PaymentPlanType__c - paymentPlanType
                    (required fields: PlanType__c, DaysNotice__c, PaymentFrequency__c, Unmeasured__c, EarliestStartDate__c, 
                    EndDate__c, AlignBudgetPlanRenewalToReadings__c, MaximumNumberofInstalments__c, NumberofRollingInstalments__c, ArrearsOnFirstInstalment__c, 
                    CreditHandling__c, MinRefundHousehold__c, MinRefundNonHousehold__c, MaxRefundHousehold__c, MaxRefundNonHousehold__c, 
                    HalfYearlyFirstInstalmentDate__c)
    @param          Decimal - the outstanding balance from Balance__c.Balance__c (reduced by the refund amount if already applied in a wizard)
    @param          Integer - the number of instalments requested
    @description    Constructors
    *******************************************************************************/
    public PpUt_PaymentPlanPackage(BillingContract__c contract, PaymentPlanType__c paymentPlanType, Decimal balance) {
        this(contract, paymentPlanType, balance, null, null);
    }
    
    public PpUt_PaymentPlanPackage(BillingContract__c contract, PaymentPlanType__c paymentPlanType, Decimal balance, 
                                   Integer numberOfInstalments, Date planStartDate) {
        
        this.contract = contract;
        this.paymentPlanType = paymentPlanType;
        this.balance = (balance == null) ? 0 : balance;
        this.planStartDate = planStartDate;
        // Added to create instalments based on inputs provided from PP wizard
        this.numberOfInstalments = numberOfInstalments;
        initialisePaymentPlan();
    }
    
    //AT-2942,2993
    public PpUt_PaymentPlanPackage(BillingContract__c contract, PaymentPlanType__c paymentPlanType, Decimal balance, Integer numberOfInstalments, 
                                   Date planStartDate, Map<Id,List<Instalment__c>> mapContractId2ListInstalmentToRetain, 
                                   Map<Id,Decimal> mapContractId2InstalmentAmountForValidation) {
                                       
        this(contract, paymentPlanType, balance, numberOfInstalments, planStartDate);
        this.mapContractId2ListInstalmentToRetain = mapContractId2ListInstalmentToRetain;
        this.mapContractId2InstalmentAmountForValidation = mapContractId2InstalmentAmountForValidation;
    }
    
    //AT-2942,2993
    public PpUt_PaymentPlanPackage(BillingContract__c contract, PaymentPlanType__c paymentPlanType, Decimal balance, Integer numberOfInstalments, 
                                   Date planStartDate, Map<Id,List<Instalment__c>> mapContractId2ListInstalmentToRetain, 
                                   Map<Id,Decimal> mapContractId2InstalmentAmountForValidation, Date planEndDateNew) {
                                       
		this.contract = contract;
        this.paymentPlanType = paymentPlanType;
        this.balance = (balance == null) ? 0 : balance;
        this.planStartDate = planStartDate;
        // Added to create instalments based on inputs provided from PP wizard
        this.numberOfInstalments = numberOfInstalments;
		this.mapContractId2ListInstalmentToRetain = mapContractId2ListInstalmentToRetain;
        this.mapContractId2InstalmentAmountForValidation = mapContractId2InstalmentAmountForValidation;                                       
        this.planEndDateFromWizard = planEndDateNew;                                   
		initialisePaymentPlan();        
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           24 Jan 2018
    @description    calculates the instalments for a payment plan
    *******************************************************************************/
    private void initialisePaymentPlan() {
        paymentPlan = new PaymentPlan__c(
                                        BillingContract__c = contract.Id, //AT-3174 
                                        PaymentPlanType__c = paymentPlanType.Id
                                        );
        setStartDate();
        setEndDate();
        determineNumberOfInstalments();
        numberOfRollingInstalments = paymentPlanType.NumberofRollingInstalments__c != null 
                                    ? Integer.valueOf(paymentPlanType.NumberofRollingInstalments__c)
                                    : 0;
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           24 Jan 2018
    @param          Boolean
    @description    true if the payment plan requires a forecast amount
    *******************************************************************************/
    public Boolean requiresForecast() {
        return paymentPlanType.PlanType__c == Label.CuAp_PaymentPlanTypePlanTypeBudgetPlan;
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           24 Jan 2018
    @description    calculates the instalments for a payment plan
                    for budget plans a forecast is required
    *******************************************************************************/
    public void calculateInstalments(Map<Id,Decimal> mapContractId2LatestBillAmountOutstanding) { //AT-3315
        determineAmountToBeSplit();
        System.debug(DEBUG + 'balance: ' + balance);
        System.debug(DEBUG + 'paymentPlan.ForecastAmount__c: ' + paymentPlan.ForecastAmount__c);
        System.debug(DEBUG + 'refund: ' + refund);
        createInstalments(mapContractId2LatestBillAmountOutstanding); //AT-3315
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           29 Jan 2018
    @param          Boolean - true for household accounts
    @description    generates a refund payment for a budget plan with a credit balance
                    and subtracts the refund from the balance
    @Revisions      AT-4249 Tarun 12-Nov-2018, Added new parameters hasBankDetails to decide the payment method for refund record
    *******************************************************************************/
    public void processRefund(Boolean isHHAccount, Boolean hasBankDetails, Map<Id,BankAccountDetails__c> mapContractId2BankDetails) {
        
        Decimal minRefund = isHHAccount ? paymentPlanType.MinRefundHousehold__c : paymentPlanType.MinRefundNonHousehold__c;
        Decimal maxRefund = isHHAccount ? paymentPlanType.MaxRefundHousehold__c : paymentPlanType.MaxRefundNonHousehold__c;
        System.debug(DEBUG + 'balance: ' + balance);
        System.debug(DEBUG + 'minRefund: ' + minRefund);
        System.debug(DEBUG + 'maxRefund: ' + maxRefund);
        system.debug('contract: ' + contract);
        
        if (paymentPlanType.PlanType__c == Label.CuAp_PaymentPlanTypePlanTypeBudgetPlan 
                && paymentPlanType.CreditHandling__c == Label.CuAp_PaymentPlanTypeCreditHandlingyRefund 
                //&& -balance <= maxRefund
                && balance < 0
                && -balance >= minRefund // old condition == -balance <= minRefund
                 ) {
                    
            Id refundRecTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(PyAp_Constants.REFUND).getRecordTypeId(); //AT-2916

            // refund required
            Decimal refundAmount = -balance > maxRefund ? maxRefund : -balance;
            //refundAmount = refundAmount * -1;
            refund = new Payment__c(
                                    Account__c = contract.AccountName__c, 
                                    BillingContract__c = contract.Id, 
                                    //new changes below AT-2916    
                                    CreditAmount__c = 0,            
                                    RecordtypeId = refundRecTypeId,
                                    PaymentDate__c = system.today(),
                                    Amount__c = refundAmount,
                                    PaymentMethod__c = hasBankDetails ? PyAp_Constants.DIRECTCREDIT : PyAp_Constants.CHEQUE,
                					//AT-4254
                					BankAccountSortCode__c = hasBankDetails && mapContractId2BankDetails.containsKey(contract.Id) ? mapContractId2BankDetails.get(contract.Id).BankAccountSortCode__c : null,
                					BankAccountNumber__c = hasBankDetails && mapContractId2BankDetails.containsKey(contract.Id) ? mapContractId2BankDetails.get(contract.Id).BankAccountNumber__c : null,
                					NameofRefundAccount__c = hasBankDetails && mapContractId2BankDetails.containsKey(contract.Id) ? mapContractId2BankDetails.get(contract.Id).NameOnAccount__c : null,
                					RefundAddress__c = !hasBankDetails ? contract.BillingAddress__c.replace('<br>', '\r\n') : null                					
                                    );
            balance += refundAmount; 
            System.debug(DEBUG + 'balance after refund: ' + balance);
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           24 Jan 2018
    @param          Date - the date
    @return         String - the day of the week
    @description    gets the day of the week from a date
    *******************************************************************************/
    private String dayOfTheWeek(Date d) {
        Datetime dt = DateTime.newInstance(d, Time.newInstance(0, 0, 0, 0));
        return dt.format('EEEE');
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           24 Jan 2018
    @param          String - the day of the week
    @return         Date - the date
    @description    gets the next date (including today) that matches the day of the week
    @Revisions      25-06-2018,AT-2913, Considering holidays and business hours while calculating days notice
    *******************************************************************************/
    private Date getNextDayOfTheWeek(String dayOfTheWeek , Integer daysNotice) {
        
        system.debug(DEBUG + 'dayOfTheWeek: ' + dayOfTheWeek);
        system.debug(DEBUG + 'daysNotice: ' + daysNotice);
        GlUt_BusinessDays objBusinessDays = new GlUt_BusinessDays();
        Date d;

        // User is given the ability to change start date from the payment plan wizard
        if (planStartDate != null) {
            d = planStartDate;    
        } else {
            d = Date.today();
        }
        
        //d = d.AddDays(daysNotice);
        d = objBusinessDays.addBusinessDays(d, daysNotice);
        
        system.debug('d---'+ d);
            
        Integer i = 0;
        while (dayOfTheWeek(d) != dayOfTheWeek) {
            d = d.addDays(1);
            if (++i > 7) break;     // day of the week not found
        }
        return d;
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           24 Jan 2018
    @param          Date - the date
    @return         Date - the incremented date
    @description    increments the date depending on the payment frequency
    *******************************************************************************/
    private Date incrementDate(Date d) {
        
        if (paymentPlanType.PaymentFrequency__c == Label.CuAp_PaymentPlanTypePaymentFrequencyWeekly) d = d.addDays(7);
        else if (paymentPlanType.PaymentFrequency__c == Label.CuAp_PaymentPlanTypePaymentFrequencyFortnightly) d = d.addDays(14);
        else if (paymentPlanType.PaymentFrequency__c == Label.CuAp_PaymentPlanTypePaymentFrequencyMonthly) d = d.addMonths(1);
        else if (paymentPlanType.PaymentFrequency__c == Label.CuAp_PaymentPlanTypePaymentFrequencyHalfYearly) d = d.addMonths(6);
        else if (GlUt_RegionUtility.getAURegionCustomSetting() && paymentPlanType.PaymentFrequency__c == Label.CuAp_PaymentPlanTypePaymentFrequencyQuarterly) d = d.addMonths(3);
        return d;
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           24 Jan 2018
    @description    gets the start date for the payment plan
    @Revisions      25-06-2018,AT-2913, Considering holidays and business hours while calculating days notice
    *******************************************************************************/
    private void setStartDate() {
        
        GlUt_BusinessDays objBusinessDays = new GlUt_BusinessDays();
        
        Integer intDaysNotice = Integer.valueOf(paymentPlanType.DaysNotice__c);
        if (paymentPlanType.PlanType__c == Label.CuAp_PaymentPlanTypePlanTypePayInFull) {
            //User is given the ability to change start date from the payment plan wizard
            if(planStartDate != null){
                //paymentPlan.StartDate__c = planStartDate.addDays(Integer.valueOf(paymentPlanType.DaysNotice__c));
                paymentPlan.StartDate__c = objBusinessDays.addBusinessDays(planStartDate, intDaysNotice);
            }
            else{
                //paymentPlan.StartDate__c = Date.today().addDays(Integer.valueOf(paymentPlanType.DaysNotice__c));
                paymentPlan.StartDate__c = objBusinessDays.addBusinessDays(Date.today(), intDaysNotice);
            }
            //paymentPlan.EndDate__c = null;
            planEndDate = null;
            
        } else {
            
            Date potentialStartDate;
            
            // find first day after the notice period
            // User is given the ability to change start date from the payment plan wizard
            if (planStartDate != null) {
                //potentialStartDate = planStartDate.addDays(Integer.valueOf(paymentPlanType.DaysNotice__c));
                potentialStartDate = objBusinessDays.addBusinessDays(planStartDate, intDaysNotice);

            } else{
                //potentialStartDate = Date.today().addDays(Integer.valueOf(paymentPlanType.DaysNotice__c));
                potentialStartDate = objBusinessDays.addBusinessDays(Date.today(), intDaysNotice);
            }
            if (paymentPlanType.PaymentFrequency__c == Label.CuAp_PaymentPlanTypePaymentFrequencyMonthly 
                || paymentPlanType.PaymentFrequency__c == Label.CuAp_PaymentPlanTypePaymentFrequencyHalfYearly 
                || paymentPlanType.PaymentFrequency__c == Label.CuAp_PaymentPlanTypePaymentFrequencyYearly
                || (GlUt_RegionUtility.getAURegionCustomSetting() && paymentPlanType.PaymentFrequency__c == Label.CuAp_PaymentPlanTypePaymentFrequencyQuarterly)) {
                    
                    if(contract.DayOfMonth__c != null){
                        // find the next day of the month
                        potentialStartDate = potentialStartDate.day() <= Integer.valueOf(contract.DayOfMonth__c) ? potentialStartDate : potentialStartDate.addMonths(1);
                        potentialStartDate = Date.valueOf(potentialStartDate.year() + '-' + potentialStartDate.month() + '-' + contract.DayOfMonth__c);
                    }
                    // if unmeasured find the next day of the month after the earliest start date
                    if (paymentPlanType.Unmeasured__c && paymentPlanType.EarliestStartDate__c != null) { 
                        Date earliestStartDate = Date.valueOf(Date.today().year() + '-' 
                                                              + paymentPlanType.EarliestStartDate__c.split('/')[1] + '-' 
                                                              + paymentPlanType.EarliestStartDate__c.split('/')[0]);
                        System.debug(DEBUG + 'earliestStartDate: ' + earliestStartDate);
                        while (potentialStartDate < earliestStartDate) {
                            potentialStartDate = potentialStartDate.addMonths(1);
                        }
                    }
                } else {
                    // find the next day of the week
                    potentialStartDate = getNextDayOfTheWeek(contract.DayOfWeek__c, intDaysNotice);
                    system.debug(DEBUG + 'potentialStartDate: ' + potentialStartDate);
                    // if unmeasured find the first day of the week after the earliest start date
                    if (paymentPlanType.Unmeasured__c && paymentPlanType.EarliestStartDate__c != null) { 
                        Date earliestStartDate = Date.valueOf(Date.today().year() + '-' 
                                                              + paymentPlanType.EarliestStartDate__c.split('/')[1] + '-' 
                                                              + paymentPlanType.EarliestStartDate__c.split('/')[0]);
                        System.debug(DEBUG + 'earliestStartDate: ' + earliestStartDate);
                        while (potentialStartDate < earliestStartDate) {
                            potentialStartDate = potentialStartDate.addDays(7);
                        }
                    }
                }
            paymentPlan.StartDate__c = potentialStartDate;
            planStartDate = paymentPlan.StartDate__c;
        }
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           24 Jan 2018
    @description    gets the end date for the payment plan
    *******************************************************************************/
    private void setEndDate() {
        
        system.debug('planEndDateFromWizard***'+ planEndDateFromWizard);

        
        if (paymentPlanType.PlanType__c == Label.CuAp_PaymentPlanTypePlanTypePayInFull) {
            //paymentPlan.EndDate__c = null;
            planEndDate = null;
            
        } else {
            if (paymentPlanType.Unmeasured__c && paymentPlanType.EndDate__c != null) {
                //paymentPlan.EndDate__c = Date.valueOf(paymentPlanType.EndDate__c);
            
                planEndDate = Date.valueOf(Date.today().year() + '-'     //VS AT-2279   
                                           + paymentPlanType.EndDate__c.split('/')[1] + '-' 
                                           + paymentPlanType.EndDate__c.split('/')[0]);
            } else if (paymentPlanType.AlignBudgetPlanRenewalToReadings__c && (planEndDateFromWizard != null || contract.PaymentPlanRenewalDate__c != null)) {
                //paymentPlan.EndDate__c = contract.PaymentPlanRenewalDate__c.addYears(1);
                planEndDate = planEndDateFromWizard != null ? planEndDateFromWizard : contract.PaymentPlanRenewalDate__c.addYears(1);
            } else {
                //paymentPlan.EndDate__c = paymentPlan.StartDate__c.addYears(1);
                planEndDate = planEndDateFromWizard != null ? planEndDateFromWizard : paymentPlan.StartDate__c.addYears(1);
                
            }
            //AT-2935
            if (paymentPlanType.PlanType__c == Label.CuAp_PaymentPlanTypePlanTypeBudgetPlan && paymentPlanType.RenewalFrequency__c != null) {
                planEndDate = planEndDateFromWizard != null ? planEndDateFromWizard : paymentPlan.StartDate__c.addMonths(Integer.valueOf(paymentPlanType.RenewalFrequency__c));
            }
            // move the plan renewal date to the new plan end date
            //contract.PaymentPlanRenewalDate__c = paymentPlan.EndDate__c;
            contract.PaymentPlanRenewalDate__c = planEndDate;
        }
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           24 Jan 2018
    @description    determine the number of instalments
    *******************************************************************************/
    private void determineNumberOfInstalments() {
        system.debug('planEndDate***'+ planEndDate);
        if (paymentPlanType.PlanType__c == Label.CuAp_PaymentPlanTypePlanTypePayInFull) {
            numberOfInstalments = 1;
            
        } else if (paymentPlanType.PaymentFrequency__c == Label.CuAp_PaymentPlanTypePaymentFrequencyHalfYearly && numberOfInstalments == 2) {
            
            // adjust the number of half yearly instalments if there is only time for one
                                                                                                                        // VS AT-2279  
            if ((paymentPlanType.Unmeasured__c && paymentPlan.StartDate__c > Date.valueOf(Date.today().year() + '-'      
                                                                                          + paymentPlanType.HalfYearlyFirstInstalmentDate__c.split('/')[1] + '-' 
                                                                                          + paymentPlanType.HalfYearlyFirstInstalmentDate__c.split('/')[0]))
                
                //|| paymentPlan.StartDate__c.addMonths(6) > paymentPlan.EndDate__c) {
                || paymentPlan.StartDate__c.addMonths(6) > planEndDate) {
                    
                    // one instalment only
                    numberOfInstalments = 1;
            }

        } else {
            
            // limit the number of instalment to fit between the start and end dates
            numberOfInstalments = numberOfInstalments == null || numberOfInstalments > Integer.valueOf(paymentPlanType.MaximumNumberofInstalments__c) 
                                ? Integer.valueOf(paymentPlanType.MaximumNumberofInstalments__c) 
                                : numberOfInstalments;
            Date instalmentDate = paymentPlan.StartDate__c;
            
            for (Integer n = 0; n < numberOfInstalments; n++) {
                System.debug(DEBUG + 'instalmentDate: ' + instalmentDate);
                System.debug(DEBUG + 'n: ' + n);
                
                //if (instalmentDate <= paymentPlan.EndDate__c) {
                if (instalmentDate <= planEndDate) {    
                    instalmentDate = incrementDate(instalmentDate);

                } else {
                    numberOfInstalments = n;
                    break;
                }
            }
        }
        system.debug('numberOfInstalments***'+ numberOfInstalments);
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           24 Jan 2018
    @description    determines the amount to be split
    *******************************************************************************/
    private void determineAmountToBeSplit() {
        
        if (paymentPlanType.PlanType__c == Label.CuAp_PaymentPlanTypePlanTypePayInFull || paymentPlanType.PlanType__c == Label.CuAp_PaymentPlanTypePlanTypeInstalmentPlan) {
            paymentPlan.PaymentPlanTotal__c = balance;
        } else {        // Budget Plan
            paymentPlan.PaymentPlanTotal__c = paymentPlan.ForecastAmount__c;
            
            // split the balance across the instalments
            if ((!paymentPlanType.ExcludeCurrentDebt__c || balance < 0) && !paymentPlanType.ArrearsOnFirstInstalment__c) {    //AT-3170
                paymentPlan.PaymentPlanTotal__c += balance;
            }
        }
        if(paymentPlan.PaymentPlanTotal__c != null){
            paymentPlan.PaymentPlanTotal__c = paymentPlan.PaymentPlanTotal__c.setScale(2, System.RoundingMode.DOWN);
        }
        if(paymentPlan.ForecastAmount__c != null){
            paymentPlan.ForecastAmount__c = paymentPlan.ForecastAmount__c.setScale(2, System.RoundingMode.DOWN);
        }
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           24 Jan 2018
    @description    creates the instalments
    *******************************************************************************/
    private void createInstalments(Map<Id, Decimal> mapContractId2LatestBillAmountOutstanding) {  //AT-2047
        
        instalments = new List<Instalment__c>();
        
        //AT-2942,2993 Starts Here
    
        List<Instalment__c> listInstalmentsToBeRetained = new List<Instalment__c>();
        List<Instalment__c> listInstalmentsDueOnOldPayPlan = new List<Instalment__c>();
        //listInstalmentsToBeRetained = getInstalmentsToBeRetained();
        
        if(mapContractId2ListInstalmentToRetain != null && mapContractId2ListInstalmentToRetain.keyset().size() > 0 && mapContractId2ListInstalmentToRetain.containsKey(contract.Id)){
            listInstalmentsDueOnOldPayPlan = mapContractId2ListInstalmentToRetain.get(contract.Id);
        }
        system.debug('listInstalmentsDueOnOldPayPlan=='+ listInstalmentsDueOnOldPayPlan);
        
        if(!listInstalmentsDueOnOldPayPlan.isEmpty()){
            
            for(Instalment__c objDueInstalments : listInstalmentsDueOnOldPayPlan){
                
                if(objDueInstalments.InstalmentDueDate__c < paymentplan.StartDate__c){
                    listInstalmentsToBeRetained.add(objDueInstalments);
                }
            }
        }
        
        Decimal amountForValidation = 0.0;
        Decimal maxRenewalThresholdAmt = 0.0;
        Decimal minRenewalThresholdAmt = 0.0;
        
        if(mapContractId2InstalmentAmountForValidation != null && mapContractId2InstalmentAmountForValidation.keyset().size() > 0 && mapContractId2InstalmentAmountForValidation.containsKey(contract.Id)){
            amountForValidation = mapContractId2InstalmentAmountForValidation.get(contract.Id);
        }
        
        if (paymentPlanType.PlanType__c == Label.CuAp_PaymentPlanTypePlanTypeBudgetPlan && paymentPlanType.MaxRenewalThreshold__c != null && paymentPlanType.MinRenewalThreshold__c != null && amountForValidation != 0.0){                
            maxRenewalThresholdAmt = amountForValidation * paymentPlanType.MaxRenewalThreshold__c / 100;
            minRenewalThresholdAmt = amountForValidation * paymentPlanType.MinRenewalThreshold__c / 100;
        }
        system.debug('maxRenewalThresholdAmt***'+ maxRenewalThresholdAmt);
        system.debug('minRenewalThresholdAmt***'+ minRenewalThresholdAmt);
        system.debug('amountForValidation***'+ amountForValidation);
        if (paymentPlanType.PlanType__c == Label.CuAp_PaymentPlanTypePlanTypeBudgetPlan && !listInstalmentsToBeRetained.isEmpty()){
            
            paymentPlan.StartDate__c = listInstalmentsToBeRetained[0].InstalmentDueDate__c;
            
            Integer instalmentNumber = 0;
            
            for(Instalment__c objInstalment : listInstalmentsToBeRetained){
                instalmentNumber += 1;
                
                instalments.add(new Instalment__c(
                                                Type__c = Label.CuAp_InstalmentTypeNormal, 
                                                InstalmentNumber__c = instalmentNumber, 
                                                InstalmentAmountDue__c = objInstalment.InstalmentAmountDue__c < 0 ? 0 : objInstalment.InstalmentAmountDue__c, 
                                                InstalmentDueDate__c = objInstalment.InstalmentDueDate__c 
                ));
            }   
        }
        
        //AT-2942,2993 Ends Here
        
        system.debug('paymentPlan.PaymentPlanTotal__c***'+ paymentPlan.PaymentPlanTotal__c);
        system.debug('numberOfInstalments***'+ numberOfInstalments);
        // calculate the instalment amounts
        Decimal instalmentAmount = (paymentPlan.PaymentPlanTotal__c / numberOfInstalments);
        system.debug('instalmentAmount***'+ instalmentAmount);

        // round to 2 decimal places and determine rounding error
        instalmentAmount = instalmentAmount.setScale(2, System.RoundingMode.DOWN);
        Decimal roundingError = paymentPlan.PaymentPlanTotal__c - (instalmentAmount * numberOfInstalments);
        
        //AT-3315 -- start
        Decimal latestBillOutstanding;
        if(mapContractId2LatestBillAmountOutstanding != null && mapContractId2LatestBillAmountOutstanding.keyset().size() > 0 && mapContractId2LatestBillAmountOutstanding.containsKey(contract.Id)){
            latestBillOutstanding = mapContractId2LatestBillAmountOutstanding.get(contract.Id);
        }
        
        //AT-3315 -- end
        system.debug('latestBillOutstanding***'+ latestBillOutstanding);
            
        //AT-4315 Start
        Decimal adjustArrearOnFirstInstalment = 0.0;
        Decimal arrearsAmount = 0.0;
        if(paymentPlanType.PlanType__c == Label.CuAp_PaymentPlanTypePlanTypeInstalmentPlan && paymentPlanType.ArrearsOnFirstInstalment__c){
            adjustArrearOnFirstInstalment = (latestBillOutstanding != null ? balance - latestBillOutstanding : 0);
            arrearsAmount = balance - (latestBillOutstanding != null ? latestBillOutstanding : balance);
            instalmentAmount = ((latestBillOutstanding != null ? latestBillOutstanding : paymentPlan.PaymentPlanTotal__c) / numberOfInstalments);
            
            // round to 2 decimal places and determine rounding error
            instalmentAmount = instalmentAmount.setScale(2, System.RoundingMode.DOWN);
            roundingError = (latestBillOutstanding != null ? latestBillOutstanding : paymentPlan.PaymentPlanTotal__c) - (instalmentAmount * numberOfInstalments) ;
            system.debug('roundingError***'+ roundingError);
            system.debug('instalmentAmount 2222***'+ instalmentAmount);
            
        }
        //AT-4315 
        
        //AT-2942,2993 Starts Here
        Date instalmentDate; 
        
        // initialise the instalment date
        
        if(!listInstalmentsToBeRetained.isEmpty()){
            instalmentDate = listInstalmentsToBeRetained[listInstalmentsToBeRetained.size() - 1].InstalmentDueDate__c;
            
            //instalments.addall(listInstalmentsToBeRetained);
            
            instalmentDate = incrementDate(instalmentDate);
        }
        else{
            instalmentDate = paymentplan.StartDate__c;
        }
         
        Boolean validationFailed = false;
        Decimal failedInstalmentAmount = 0.0;
        String failedReason = '';
        Date failedStartDate;
        Date failedEndDate;
        
        //AT-2942,2993
                
        // create the instalments and add them to the list
        for (Integer n = 1; n <= numberOfInstalments; n++) {
            Decimal adjustedInstalmentAmount = instalmentAmount;
            
            // add any rounding error to the first instalment
            adjustedInstalmentAmount = (n <= 1) 
                ? adjustedInstalmentAmount + roundingError 
                : adjustedInstalmentAmount;
            
            // add arrears to the first instalment if required             
            adjustedInstalmentAmount = (n <= 1 && paymentPlanType.ArrearsOnFirstInstalment__c) 
                //? adjustedInstalmentAmount + (latestBill != null ? balance - latestBill.TotalAmountOutstanding__c : 0) //AT-3315
                ? adjustedInstalmentAmount + arrearsAmount //AT-4315 
                : adjustedInstalmentAmount;
           
            //AT-2942,2993 Starts Here
            
            if (maxRenewalThresholdAmt != 0.0 && minRenewalThresholdAmt != 0.0){
                
                if(adjustedInstalmentAmount < minRenewalThresholdAmt){
                    validationFailed = true;
                    failedReason = String.valueOf(adjustedInstalmentAmount) + ' - ' +  Label.PpUt_PayPlanTypeMinThresholdVal + ' - ' + String.valueOf(minRenewalThresholdAmt);
                }
                
                if(adjustedInstalmentAmount > maxRenewalThresholdAmt){
                    validationFailed = true;
                    failedReason = String.valueOf(adjustedInstalmentAmount) + ' - ' +  Label.PpUt_PayPlanTypeMaxThresholdVal + ' - ' + String.valueOf(maxRenewalThresholdAmt);
                }
                
                system.debug('failedReason---'+ failedReason);
                
                if(validationFailed){
                    failedInstalmentAmount = adjustedInstalmentAmount;
                    failedStartDate = instalmentDate;
                    failedEndDate = incrementDate(instalmentDate);
                    
                }
            }
            //AT-2942,2993 Ends Here
            
            instalments.add(new Instalment__c(
                                            Type__c = Label.CuAp_InstalmentTypeNormal, 
                                            InstalmentNumber__c = n, 
                                            InstalmentAmountDue__c = adjustedInstalmentAmount < 0 ? 0 : adjustedInstalmentAmount, 
                                            InstalmentDueDate__c = instalmentDate 
                                            ));
            instalmentDate = incrementDate(instalmentDate);
        }
        
        //AT-2942,2993 Starts Here
        
        if(validationFailed){
            createForecastInstalment(failedInstalmentAmount,failedReason,failedStartDate,failedEndDate);
        }
        
        Integer updateInstalmentNumber = 0;
        Decimal updatedPaymentPlanTotal = 0.0;
        
        for(Instalment__c objInstalment : instalments){
            
            updateInstalmentNumber += 1;
            objInstalment.InstalmentNumber__c = updateInstalmentNumber;
            
            updatedPaymentPlanTotal += objInstalment.InstalmentAmountDue__c;
        }
        
        //This is to update the payment plan total of new plan when old Instalments were retained
        if(updatedPaymentPlanTotal > paymentPlan.PaymentPlanTotal__c){
            paymentPlan.PaymentPlanTotal__c = updatedPaymentPlanTotal;
        }
        //AT-2942,2993 Ends Here

        // create the rolling instalments and add them to the end of the list
        for (Integer n = 1; n <= numberOfRollingInstalments; n++) {
            
            instalments.add(new Instalment__c(
                                            Type__c = Label.CuAp_InstalmentTypeRolling, 
                                            InstalmentNumber__c = 1 + instalments.size(), 
                                            InstalmentAmountDue__c = instalmentAmount < 0 ? 0 : instalmentAmount, 
                                            InstalmentDueDate__c = instalmentDate 
                                            ));
            instalmentDate = incrementDate(instalmentDate);
        }
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           02 Feb 2018
    @description    link all the instalments to the payment plan Id
                    (the payment plan record must be inserted before calling this method)
    *******************************************************************************/
    public void updateInstalmentsMasterDetailRelationship() {
        for (Instalment__c instalment : instalments) {
            if(instalment.Id == null){
                system.debug('instalment   '   +  instalment);
                system.debug('paymentPlan.Id   *****'  + paymentPlan.Id);
                instalment.PaymentPlan__c = paymentPlan.Id;
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           28 June 2018
    @param          Params to create ForecastedInstalment__c
    @description    generates a ForecastedInstalment__c record , AT-2942,2993 
    *******************************************************************************/
    public void createForecastInstalment(Decimal failedInstalmentAmount, String failedReason, Date StartDate, Date EndDate) {
        
        forecastInstalment = new ForecastedInstalment__c(
            BillingContract__c = contract.Id,
            HoldReason__c = failedReason,
            Amount__c = failedInstalmentAmount,
            FromDate__c = StartDate,
            ToDate__c = EndDate
        );
        
    }
    
}