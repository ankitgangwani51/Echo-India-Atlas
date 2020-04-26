/******************************************************************************
@author         Echo: Patrick Dixon
@date			24 Jan 2018
@description:   Payment Plan utility class
@group          Utility
Revision(s)     AT-4254, TG , 29/11/18 , Sent bank details linked to contract
Revision(s)		AT-5453 , Fixed cleanse issue in wrapper
@Revisions      CLB-31
*******************************************************************************/
public with sharing class PpUt_PaymentPlanUtilities {
    
    private static final String CLASS_NAME = 'PpUt_PaymentPlanUtilities';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static Date planEndDateNew;
    
    // Variable declaration
    // End variable declaration
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           01 Feb 2018
    @param          List<PaymentPlan__c> - the paymentPlans to be forecast (just one for now)
    @return         Boolean - success
    @description    HEROKU REST callout to forecast a bill for a payment plan
    				updates the ForecastAmount__c field in the payment plan with the forecast result
	@Revisions		03-July-2018 AT-2914,AT-2935 = Added new Parameter 
    *******************************************************************************/
	private class ForecastResponseContainer {private Decimal Amount;}		// class to format callout response
    private static Boolean forecastBill(List<PaymentPlan__c> paymentPlans,PaymentPlanType__c plansTypeBudgets) { //AT-2935
        System.debug(DEBUG + 'MAKING BILL FORECAST CALLOUT');
        try {
        	//GlUt_Logger.logDebug(DEBUG + GlUt_Constants.EXECUTING);
			// format the payload using the forecast data DTO
			PpIn_ForecastExtractData forecastCalc = new PpIn_ForecastExtractData(paymentPlans,plansTypeBudgets); //AT-2935
	        String payload = forecastCalc.retrieveData();      // JSON billing data
			system.debug(DEBUG + 'heroku payload: ' + payload); 
	        // make the callout
	        HttpResponse response = BlUt_HerokuWebservices.makeCallout(BlUt_HerokuWebservices.BILL_FORECAST, 2000, 'application/json', payload);
	        system.debug(DEBUG + 'heroku response: ' + response.getBody()); 
	        // handle response
			ForecastResponseContainer forecastResponse = new ForecastResponseContainer();
	        if (response.getStatusCode() == 200) {
	            System.debug(DEBUG + 'Good response: ' + response.getStatusCode() + ' ' + response.getStatus());
	            forecastResponse = (ForecastResponseContainer) System.JSON.deserialize(response.getBody(), ForecastResponseContainer.class);
	            paymentPlans[0].ForecastAmount__c = forecastResponse.Amount;		// single plan only for now
				system.debug(DEBUG + 'forecastResponse: ' + forecastResponse);    
	            
	        } else {
	            System.debug(DEBUG + 'Error response: ' + response.getStatusCode() + ' ' + response.getBody());
	            throw new AuraHandledException(Label.BlAp_BillCalcRequestError + response.getBody());
	        }
	        
		} catch (exception e) {
            //GlUt_Logger.logException(e);
            system.debug('e.getMessage() -- '+ e.getMessage());
			throw new AuraHandledException(e.getMessage());
        }
        finally {   
            //GlUt_Logger.writeLogsToDatabase();
        }
        return true;
    }

	/******************************************************************************
	@author			Echo: Patrick Dixon
	@date			24 Jan 2018
	@param			BillingContract__c - the contracts for which a plan will be calculated
	@param			Decimal - the balance outstanding (refund already applied)
	@param			PaymentPlan__c - the payment plan record
	@param			Integer - the number of instalments requested
	@return			<PpUt_PaymentPlanPackage - a payment plan wrapper
	@description	calcuates a new payment plan with instalments (individual).
	@Revisions		AT-2942 Tarun 03-July-2018, Added new parameters to calculatePlans
	*******************************************************************************/
    public static PpUt_PaymentPlanPackage calculatePlan(BillingContract__c contract, Decimal balance, Integer numberOfInstalments , Date planStartDate, Date planEndDate) {
    	balance = (balance == null) ? 0 : balance;
        planEndDateNew = planEndDate;
    	List<BillingContract__c> contracts = new List<BillingContract__c>{contract};
    	for (PpUt_PaymentPlanPackage plan : calculatePlans(contracts, false, balance, numberOfInstalments, planStartDate, null, null, null)) {
    		return plan;		// one plan only
    	}
    	return null;
    }

	/******************************************************************************
	@author			Echo: Patrick Dixon
	@date			24 Jan 2018
	@param			List<BillingContract__c> - list of the contracts for which plans will be calculated
					(required fields: AccountName__c, CurrentPaymentPlanType__c, Balance__c, PaymentPlanRenewalDate__c, DayOfWeek__c, DayOfMonth__c)
	@return			List<PpUt_PaymentPlanPackage> - list of payment plan wrappers
	@description	calcuates new payment plans with instalments and commits the records (batch).1.0
	@Revisions		AT-2942 Tarun 03-July-2018, Added new parameters to calculatePlans
	*******************************************************************************/
    public static List<PpUt_PaymentPlanPackage> calculatePlans(List<BillingContract__c> contracts) {  
        system.debug('11.....');
		// calculate the payment plans
     	List<PpUt_PaymentPlanPackage> plans = calculatePlans(contracts, true, null, null, null, null, null, null);
     	// build a list of the payment plans to insert
     	List<PaymentPlan__c> paymentPlansToInsert = new List<PaymentPlan__c>();
     	for (PpUt_PaymentPlanPackage plan : plans) {
            paymentPlansToInsert.add(plan.paymentPlan);
        }
        // insert the records
        if (!paymentPlansToInsert.isEmpty()) {
            paymentPlansToInsert = (List<PaymentPlan__c>) GlUt_FieldSecurity.cleanseFields(paymentPlansToInsert, false);
            insert paymentPlansToInsert;
        }
        //This is to again assign payment plan Id as it was losing instance in wrapper after cleanseFields
        if(paymentPlansToInsert.size() == plans.size()){
            for(Integer i=0 ; i< plans.size() ; i++ ){
                plans[i].paymentPlan.Id = paymentPlansToInsert[i].Id;
            }
        }
        // link the instalments in each wrapper to their payment plan
     	for (PpUt_PaymentPlanPackage plan : plans) {
     		plan.updateInstalmentsMasterDetailRelationship();
     	}
     	// build a list of the instalments to insert
     	List<Instalment__c> instalmentsToInsert = new List<Instalment__c>();
     	for (PpUt_PaymentPlanPackage plan : plans) {
     		instalmentsToInsert.addAll(plan.instalments);
     	}
        // insert the records
        if (!instalmentsToInsert.isEmpty()) {
            instalmentsToInsert = (List<Instalment__c>) GlUt_FieldSecurity.cleanseFields(instalmentsToInsert, false);
            insert instalmentsToInsert;
        }
        return plans;
    }
    
	/******************************************************************************
	@author			Echo: Patrick Dixon
	@date			24 Jan 2018
	@param			List<BillingContract__c> - list of the contracts for which plans will be calculated
	@param			Boolean - true if refunds should be processed before calculating instalments
	@param			Decimal - the balance outstanding (null for batch)
	@param			Integer - the number of instalments requested (null for batch)
	@return			List<PpUt_PaymentPlanPackage> - list of payment plan wrappers
	@description	calcuates new payment plans with instalments (base).
	@Revisions		AT-2942 Tarun 03-July-2018, Added new parameters to calculatePlans
					AT-4249 Tarun 12-Nov-2018, Added new parameters hasBankDetails to decide the payment method for refund record
	*******************************************************************************/
    private static List<PpUt_PaymentPlanPackage> calculatePlans(List<BillingContract__c> contracts, 
                                                                Boolean processRefunds, 
                                                                Decimal balance, 
                                                                Integer numberOfInstalments, 
                                                                Date planStartDate, 
                                                                Map<Id,ForecastedResult__c> mapContractForecast, //AT-2942
                                                                Map<Id,List<Instalment__c>> mapContractId2ListInstalmentToRetain, //AT-2942
                                                                Map<Id,Decimal> mapContractId2InstalmentAmountForValidation) { //AT-2942
                                                                    system.debug('222....');
                                                                    
                                                                 

    	// map of instalment details wrappers keyed on contract Id
		List<PpUt_PaymentPlanPackage> plans = new List<PpUt_PaymentPlanPackage>();
		
		// build the Id sets for the queries
		Set<Id> contractIds = new Set<Id>();
		Set<Id> accountIds = new Set<Id>();                                                                    
		Set<Id> paymentPlanTypeIds = new Set<Id>();
		Set<Id> balanceIds = new Set<Id>();
		for (BillingContract__c contract : contracts) {
			contractIds.add(contract.Id);
            accountIds.add(contract.AccountName__c);
			paymentPlanTypeIds.add(contract.CurrentPaymentPlanType__c);
			if (balance == null) balanceIds.add(contract.Balance__c);
		}
        System.debug(DEBUG + 'paymentPlanTypeIds: '+ paymentPlanTypeIds);
		// get the PaymentPlanTypes into a Map keyed on their Ids
		Map<Id, PaymentPlanType__c> paymentPlanTypeMap = new Map<Id, PaymentPlanType__c>([select Id, 
																								PlanType__c, 
																								DaysNotice__c, 
																								PaymentFrequency__c, 
																								Unmeasured__c, 
																								EarliestStartDate__c, 
																								EndDate__c, 
																								AlignBudgetPlanRenewalToReadings__c, 
																								MaximumNumberofInstalments__c, 
																								NumberofRollingInstalments__c, 
																								ArrearsOnFirstInstalment__c, 
																								CreditHandling__c, 
																								MinRefundHousehold__c, 
																								MinRefundNonHousehold__c, 
																								MaxRefundHousehold__c, 
																								MaxRefundNonHousehold__c, 
																								HalfYearlyFirstInstalmentDate__c,
                                                                                          		RenewalFrequency__c, //AT-2942
                                                                                          		MaxRenewalThreshold__c, //AT-2942
                                                                                          		MinRenewalThreshold__c, //AT-2942
                                                                                                //RollingAverage__c, // AT-5070 //AT-5685, Ankit, 30/04/2019, Remove field reference
                                                                                          		ExcludeCurrentDebt__c // CLB-31
																							from paymentPlanType__c 
																							where Id in :paymentPlanTypeIds]);
					
		Map<Id, Balance__c> balanceMap;
		if (balance == null) {
			// get the Balances into a Map keyed on their Ids
			balanceMap = new Map<Id, Balance__c>([select Id, 
														Balance__c 
													from Balance__c 
													where Id in :balanceIds]);
		}
                                                                    
        //AT-3315 -- find the the most recent bill of the contract       
        List<Bill__c> listBillsOnContracts = [Select TotalAmountOutstanding__c,
                                               BillDate__c,
                                        	   BilledAmount__c,
                                               BillingContract__c,
                                        	   CreatedDate
                                        From Bill__c 
                                        Where BillingContract__c IN :contracts
                                        //AND BillType__c =: Label.CuAp_NormalBillType
                                        Order By BillDate__c DESC, CreatedDate DESC ]; 
		
        //This will only have one bill per contract                                                            
		Map<Id, Bill__c> contractId2BillMap = new Map<Id, Bill__c>();
		Map<Id,Decimal> mapContractId2LatestBillAmountOutstanding = new Map<Id,Decimal>();
                                                                    
		if(listBillsOnContracts != null && !listBillsOnContracts.isEmpty()){ 
            for(Bill__c objBill:listBillsOnContracts){
                if(!contractId2BillMap.containsKey(objBill.BillingContract__c))
                contractId2BillMap.put(objBill.BillingContract__c, objBill);
            }            
        }

		if(contractId2BillMap.keyset().size() > 0){
            
            List<Bill__c> listLatestBill = new List<Bill__c>();
            listLatestBill = contractId2BillMap.values();
            Set<Id> setBillIds = new Set<Id>();
            for(Bill__c objBill : listLatestBill){
                setBillIds.add(objBill.Id);
            }            
            List<BillItem__c> latestBillItemList = [Select Id,AmountOutstanding__c,Bill__c,Bill__r.BillingContract__c                                       
                                                    From BillItem__c 
                                                    Where Bill__c IN :setBillIds];            
            if(latestBillItemList != null && !latestBillItemList.isEmpty()){
                
                for(BillItem__c objBillItem : latestBillItemList){
                    
                    if(!mapContractId2LatestBillAmountOutstanding.containsKey(objBillItem.Bill__r.BillingContract__c)){
                        mapContractId2LatestBillAmountOutstanding.put(objBillItem.Bill__r.BillingContract__c, objBillItem.AmountOutstanding__c);
                    }
                    else{
                        Decimal billItemAmt = mapContractId2LatestBillAmountOutstanding.get(objBillItem.Bill__r.BillingContract__c);
                        billItemAmt += objBillItem.AmountOutstanding__c;
                        mapContractId2LatestBillAmountOutstanding.put(objBillItem.Bill__r.BillingContract__c, billItemAmt);
                    }
                }
            }                                                       
        }             
        //AT-3315 - end                                                          
		// build the payment plan wrappers and a list of the plans requiring forecasts
		List<PaymentPlan__c> plansRequiringForecasts = new List<PaymentPlan__c>();
        List<PaymentPlanType__c> plansTypeBudgets = new List<PaymentPlanType__c>(); //AT-2942
		for (BillingContract__c contract : contracts) {
			
            //AT-2942 - Starts Here
			Date forecastStartDate;
			
			if(mapContractForecast != null && mapContractForecast.keyset().size() > 0 && mapContractForecast.containskey(contract.Id)){
				forecastStartDate = mapContractForecast.get(contract.Id).FromDate__c;
			}
            
            //AT-2942 - Ends Here
			// instantiate each payment plan wrapper and add it to the map
			balance = (balance == null) ? balanceMap.get(contract.Balance__c).Balance__c : balance;
			PpUt_PaymentPlanPackage plan = new PpUt_PaymentPlanPackage(contract, 
																		paymentPlanTypeMap.get(contract.CurrentPaymentPlanType__c), 
																		balance, 
																		numberOfInstalments,
																		(forecastStartDate == null) ? planStartDate : forecastStartDate, //AT-2942
                                                                      	mapContractId2ListInstalmentToRetain,//AT-2942
                                                                      	mapContractId2InstalmentAmountForValidation,
                                                                      	planEndDateNew);//AT-2942
										
            //AT-2942
			if(mapContractForecast != null && mapContractForecast.keyset().size() > 0 && mapContractForecast.containskey(contract.Id)){
				plan.paymentPlan.ForecastAmount__c = mapContractForecast.get(contract.Id).ForecastedAmount__c;
			}
            //AT-2942
			
			plans.add(plan);
			
			// add those requiring a forecast to the list
			if (plan.requiresForecast()) {
				plansRequiringForecasts.add(plan.paymentPlan);
                plansTypeBudgets.add(plan.paymentPlanType); //AT-2935
			}
            
            balance = null;
            
		}
		system.debug('plans::>> ' + plans);
        // call webservice to get all the forecasts
		if (!plansRequiringForecasts.isEmpty() && mapContractForecast == null) forecastBill(plansRequiringforecasts,plansTypeBudgets[0]); //AT-2942
		system.debug('Here after Exception');
		// build a map of the contract account types
		Map<Id, Boolean> accountTypeMap = new Map<Id, Boolean>();
		Map<Id, Boolean> mapContractId2Bank = new Map<Id, Boolean>();    
		Map<Id,BankAccountDetails__c> mapContractId2BankDetails = new Map<Id,BankAccountDetails__c>();
		if (processRefunds) {
			accountTypeMap = GlUt_AccountUtilities.getContractAccountTypes(contractIds);
            mapContractId2Bank = GlUt_AccountUtilities.getContractAccountBankDetails(contractIds, accountIds);
            mapContractId2BankDetails = GlUt_ContractUtilities.getBankLinkedToContract(contractIds); // AT-4254, TG , 29/11/18 , Sent bank details linked to contract
        }
			
		// calculate the payment plan instalments
		for (PpUt_PaymentPlanPackage plan : plans) {
			if (processRefunds) {
				Boolean isHHAccount = accountTypeMap.get(plan.paymentPlan.BillingContract__c);
				Boolean hasBankDetails = mapContractId2Bank.get(plan.paymentPlan.BillingContract__c);                
				plan.processRefund(isHHAccount,hasBankDetails,mapContractId2BankDetails);
			}
            plan.calculateInstalments(mapContractId2LatestBillAmountOutstanding); //AT-3315
		}
		return plans;
                                                                    
    }
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           03-Jan-2018
    @param          List<Id> - bill Ids
    @return         List<PpUt_PaymentPlanPackage> - the list of PpUt_PaymentPlanPackages created
    @description    calcuates payment plans for new bills.
    *******************************************************************************/
    public static List<PpUt_PaymentPlanPackage> calculatePlans(List<Id> billIds) {
        system.debug('33...');
        // build a list of contracts related to the bills
        List<BillingContract__c> contracts = [select Id, 
                                              AccountName__c, 
                                              CurrentPaymentPlanType__c, 
                                              Balance__c, 
                                              PaymentPlanRenewalDate__c, 
                                              DayOfWeek__c, 
                                              DayOfMonth__c,
                                              BillingAddress__c
                                              from BillingContract__c
                                              where Id in (select BillingContract__c from Bill__c where Id in :billIds)];
        
        // calculate new plans for these contracts
        return calculatePlans(contracts);
    }
	
	/******************************************************************************
    @author         Echo: Tarun Gupta
    @date           20-June-2018
    @param          List<ForecastedResult__c> 
    @return         List<PpUt_PaymentPlanPackage> - the list of PpUt_PaymentPlanPackages created
    @description    AT-2942, calcuates payment plans for new ForecastedResult record.
    *******************************************************************************/
    public static List<PpUt_PaymentPlanPackage> calculatePlans(List<ForecastedResult__c> listForecastedResult) {
        system.debug('4444...');
		List<PpUt_PaymentPlanPackage> listPPPackage = new List<PpUt_PaymentPlanPackage>();
		List<BillingContract__c> listContracts = new List<BillingContract__c>();
		
		Map<Id,ForecastedResult__c> mapContractIds2ForecastAmount = new Map<Id,ForecastedResult__c>();                
        Map<Id,List<Instalment__c>> mapContractId2ListInstalmentToRetain = new Map<Id,List<Instalment__c>>();
        Map<Id,Decimal> mapContractId2InstalmentAmountForValidation = new Map<Id,Decimal>();
		
		// build a list of the related contract Ids
		for (ForecastedResult__c objForecastResult : listForecastedResult) {
            if(objForecastResult.BillingContract__c != null){
                if(!mapContractIds2ForecastAmount.containskey(objForecastResult.BillingContract__c)){
                    mapContractIds2ForecastAmount.put(objForecastResult.BillingContract__c,objForecastResult);
                }
            }
		}
        system.debug('1...mapContractIds2ForecastAmount ' + mapContractIds2ForecastAmount);
        if(mapContractIds2ForecastAmount != null && mapContractIds2ForecastAmount.keyset().size() > 0){
            listContracts = [SELECT  Id,Name,AccountName__c, 
                                     CurrentPaymentPlanType__c, 
                                     Balance__c, 
                                     PaymentPlanRenewalDate__c, 
                                     DayOfWeek__c, 
                                     DayOfMonth__c,
                             		 BudgetPlanHold__c,
                             		 BillingAddress__c
                             FROM BillingContract__c WHERE Id IN: mapContractIds2ForecastAmount.keyset()];             
        }
        system.debug('2...listContracts ' + listContracts);
        WrapContractId2InstalmentAndAmount objWrapper = getListOfInstalmentToRetain(mapContractIds2ForecastAmount.keyset());
        
        mapContractId2ListInstalmentToRetain = objWrapper.mapContractId2ListInstalmentToRetain;
        mapContractId2InstalmentAmountForValidation = objWrapper.mapContractId2InstalmentAmountForValidation;
		// Here we get the list of PpUt_PaymentPlanPackage based on params passed
		listPPPackage = calculatePlans(listContracts, true, null, null, null, mapContractIds2ForecastAmount, mapContractId2ListInstalmentToRetain,mapContractId2InstalmentAmountForValidation) ;
        system.debug('3.....listPPPackage ' + listPPPackage);
        //Get List of Book against the Contract
        Map<Id,List<Book__c>> mapContract2ListOfBook = GlUt_UpdateBudgetRenewals.getListOfBookOnContract(mapContractIds2ForecastAmount.keyset()); 
        system.debug('4....mapContract2ListOfBook ' + mapContract2ListOfBook);
        //Create a new package class list with updated values
        List<PpUt_PaymentPlanPackage> listPPPackageToInsert = new List<PpUt_PaymentPlanPackage>();
        system.debug('5....listPPPackageToInsert ' + listPPPackageToInsert);
        if(!listPPPackage.isEmpty()){
            for(PpUt_PaymentPlanPackage objPaymentPlanPackage : listPPPackage){
                PpUt_PaymentPlanPackage objPaymentPlanPackageNew = updatePlanForRenewals(objPaymentPlanPackage,mapContract2ListOfBook);
                
                if(objPaymentPlanPackageNew != null){
                    listPPPackageToInsert.add(objPaymentPlanPackageNew);
                }
            }
        }
        system.debug('6.....listPPPackageToInsert ' + listPPPackageToInsert);
        if(!listPPPackageToInsert.isEmpty()){
            createRenewalPlan(listPPPackageToInsert);
        }        	
        system.debug('7...end');
		return listPPPackage;
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           20-June-2018
    @param          List<PpUt_PaymentPlanPackage> 
    @return         PpUt_PaymentPlanPackage - the list of PpUt_PaymentPlanPackages created
    @description    AT-2942, update renewals for new ForecastedResult record.
    *******************************************************************************/
    public static PpUt_PaymentPlanPackage updatePlanForRenewals(PpUt_PaymentPlanPackage objPaymentPlanPackage,Map<Id,List<Book__c>> mapContract2ListOfBook) {           
        system.debug('5555');
        if(objPaymentPlanPackage != null && objPaymentPlanPackage.paymentPlanType != null && objPaymentPlanPackage.paymentPlanType.PlanType__c == Label.CuAp_PaymentPlanTypePlanTypeBudgetPlan){
            
            GlUt_UpdateBudgetRenewals.WrapPaymentPlanInstalments wrapClass = new GlUt_UpdateBudgetRenewals.WrapPaymentPlanInstalments();
            
            if(mapContract2ListOfBook != null && mapContract2ListOfBook.keyset().size() > 0  && mapContract2ListOfBook.containsKey(objPaymentPlanPackage.contract.Id)){
                List<Book__c> bookList = mapContract2ListOfBook.get(objPaymentPlanPackage.contract.Id);
                wrapClass = GlUt_UpdateBudgetRenewals.amendPPInstalments(objPaymentPlanPackage.paymentPlan.BillingContract__c,objPaymentPlanPackage.planStartDate,
                                                                         objPaymentPlanPackage.paymentPlanType,objPaymentPlanPackage.instalments, bookList, 
                                                                         objPaymentPlanPackage.planEndDate); 
                if(wrapClass != null){
                    
                    if(objPaymentPlanPackage.instalments.size() > 0 && wrapClass.lstInstalmentsToBeAdded != null && wrapClass.lstInstalmentsToBeAdded.size() > 0){
                        objPaymentPlanPackage.instalments.clear();
                        objPaymentPlanPackage.instalments.addall(wrapClass.lstInstalmentsToBeAdded);
                    }
                    
                    if(wrapClass.contractRenewalDate != null){
                        objPaymentPlanPackage.planRenewalDate = wrapClass.contractRenewalDate;
                    }
                }
            }
        }
        return objPaymentPlanPackage;
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           20-June-2018
    @param          List<PpUt_PaymentPlanPackage> 
    @return         PpUt_PaymentPlanPackage - the list of PpUt_PaymentPlanPackages created
    @description    AT-2942,create new record.
    *******************************************************************************/
    public static void createRenewalPlan(List<PpUt_PaymentPlanPackage> listPPPackageToInsert) {  
        Savepoint sp = Database.setSavepoint();
        try{
            // build a list of the payment plans to insert
            List<PaymentPlan__c> paymentPlansToInsert = new List<PaymentPlan__c>();
            system.debug('501....');
            for(PpUt_PaymentPlanPackage plans : listPPPackageToInsert){
                // To check this contract doesn't have a ForecastedInstalment__c(forecastInstalment) record
                if(plans.forecastInstalment == null)
                    paymentPlansToInsert.add(plans.paymentPlan);
            }
            system.debug('502....paymentPlansToInsert  ' + paymentPlansToInsert);
            // insert the records
            if (!paymentPlansToInsert.isEmpty()){
                paymentPlansToInsert = (List<PaymentPlan__c>) GlUt_FieldSecurity.cleanseFields(paymentPlansToInsert, false);
                insert paymentPlansToInsert;
                system.debug('503...paymentPlansToInsert ' + paymentPlansToInsert);
            } 
            //This is to again assign payment plan Id as it was losing instance in wrapper after cleanseFields
            //if(paymentPlansToInsert.size() == listPPPackageToInsert.size()){
            Integer validCount = 0;
            for(Integer i=0 ; i< listPPPackageToInsert.size() ; i++ ){              
                if(listPPPackageToInsert[i].forecastInstalment == null){
                    listPPPackageToInsert[i].paymentPlan.Id = paymentPlansToInsert[validCount].Id;
                    validCount = validCount + 1;
                }
                
            }
            //}
            
            // link the instalments in each wrapper to their payment plan
            for (PpUt_PaymentPlanPackage plans : listPPPackageToInsert) {
                plans.updateInstalmentsMasterDetailRelationship();
            }
            system.debug('504...');
            // build a list of the instalments to insert
            List<Instalment__c> instalmentsToInsert = new List<Instalment__c>();
            // build a list of the contract - renewalDate to update
            List<BillingContract__c> contractToUpdate = new List<BillingContract__c>();
            // build a list of the contract - renewalDate to update
            List<Payment__c> paymentsToUpdate = new List<Payment__c>();
            Map<Id,Payment__c> mapContractIdToPayment = new Map<Id,Payment__c>();
            // build a list of the ForecastedInstalment__c to create
            List<ForecastedInstalment__c> forecastedInstalmentToCreate = new List<ForecastedInstalment__c>();
            // build a list of the contracts to update BudgetPlanHold__c
            List<BillingContract__c> listContractsToUpdateBudgetHold = new List<BillingContract__c>();
            
            for (PpUt_PaymentPlanPackage plans : listPPPackageToInsert) {
                system.debug('505...');
                if(plans.planRenewalDate != null){
                    plans.contract.PaymentPlanRenewalDate__c = plans.planRenewalDate;
                }
                // To check this contract doesn't have a ForecastedInstalment__c(forecastInstalment) record
                if(plans.forecastInstalment == null){
                    instalmentsToInsert.addAll(plans.instalments);
                    contractToUpdate.add(plans.contract);
                    if(plans.refund != null){
                        if(!mapContractIdToPayment.containsKey(plans.refund.BillingContract__c)){
                            mapContractIdToPayment.put(plans.refund.BillingContract__c, plans.refund);
                        }
                    }
                }
                else{
                    forecastedInstalmentToCreate.add(plans.forecastInstalment);
                    BillingContract__c objContractBudgetHold = new BillingContract__c(Id = plans.contract.Id,BudgetPlanHold__c = true);
                    contractToUpdate.add(objContractBudgetHold);
                }			
            }
            system.debug('506.....instalmentsToInsert ' + instalmentsToInsert);
            // insert the records
            if (!instalmentsToInsert.isEmpty()){
                instalmentsToInsert = (List<Instalment__c>) GlUt_FieldSecurity.cleanseFields(instalmentsToInsert, false);
                insert instalmentsToInsert;
            } 
            system.debug('507....instalmentsToInsert ' + instalmentsToInsert);
            // insert the records
            if (!forecastedInstalmentToCreate.isEmpty()){
                forecastedInstalmentToCreate = (List<ForecastedInstalment__c>) GlUt_FieldSecurity.cleanseFields(forecastedInstalmentToCreate, false);
                insert forecastedInstalmentToCreate;
            } 
            system.debug('508....contractToUpdate ' + contractToUpdate);
            // update the records
            if (!contractToUpdate.isEmpty()){
                contractToUpdate = (List<BillingContract__c>) GlUt_FieldSecurity.cleanseFields(contractToUpdate, false);
                update contractToUpdate;
            } 
            system.debug('509....contractToUpdate ' + contractToUpdate);
            // update the records
            if(mapContractIdToPayment != null && mapContractIdToPayment.keyset().size() > 0){
                createRefundPaymentRecords(mapContractIdToPayment);
            }
            system.debug('510....');
        }
        catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            system.debug('511...');
            System.debug('exception = '+e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           20-June-2018
    @param          List<PpUt_PaymentPlanPackage> 
    @return         PpUt_PaymentPlanPackage - the list of PpUt_PaymentPlanPackages created
    @description    AT-2942, create Refund Records.
    *******************************************************************************/
    public static void createRefundPaymentRecords(Map<Id,Payment__c> mapContractIdToPayment) { 
        Map<Id,List<Payment__c>> mapContractIdToListExistingPayment = new Map<Id,List<Payment__c>>();
        List<Payment__c> listNewPayments = new List<Payment__c>();
        List<Payment__c> existingPaymentList = new List<Payment__c>();
        Set<Id> setContractIds = new Set<Id>();
        setContractIds = mapContractIdToPayment.keyset();
        listNewPayments = mapContractIdToPayment.values();
        existingPaymentList = GlBt_RefundTransferCreditUtility.getExistingPaymnts(setContractIds);
        GlBt_RefundTransferCreditUtility.creditRefund(listNewPayments, existingPaymentList);
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           20-June-2018
    @param          List<PpUt_PaymentPlanPackage> 
    @return         PpUt_PaymentPlanPackage - the list of PpUt_PaymentPlanPackages created
    @description    AT-2942, Get list of Instalments to be retained and amount of Instalments to do the validation
    *******************************************************************************/
    public static WrapContractId2InstalmentAndAmount getListOfInstalmentToRetain(Set<Id> contractIds) {         
        
        List<PaymentPlan__c> listExistingPP = new List<PaymentPlan__c>();
        List<BillCalculation__c> listLatestBillCalculation = new List<BillCalculation__c>();
        List<Instalment__c> listInstalmentsToBeRetained = new List<Instalment__c>();
        Set<Id> setPayPlanIds = new Set<Id>();
        Map<Id,PaymentPlan__c> mapContractId2PaymentPlan = new Map<Id,PaymentPlan__c>();
        Map<Id,DateTime> mapContractId2LatestBillCalcDate = new Map<Id,DateTime>();
        Map<Id,List<Instalment__c>> mapPaymentPlanId2ListInstalments = new Map<Id,List<Instalment__c>>();
        Map<Id,List<Instalment__c>> mapContractId2ListInstalmentToRetain = new Map<Id,List<Instalment__c>>();
        Map<Id,Decimal> mapContractId2InstalmentAmountForValidation = new Map<Id,Decimal>();
        
        WrapContractId2InstalmentAndAmount objWrapper = new WrapContractId2InstalmentAndAmount();
        if(!contractIds.isEmpty()){
            //This gets the current PP datails and their instalment which are left to be paid 
            listExistingPP = [SELECT  Id,Name,
                                      BillingContract__c,//AT-3174
                                      Active__c
                              FROM PaymentPlan__c
                              WHERE BillingContract__c IN: contractIds//AT-3174
                              AND Active__c = true];
        }
        if(!listExistingPP.isEmpty()){
            
            for(PaymentPlan__c objPaymentPlan :listExistingPP){
                setPayPlanIds.add(objPaymentPlan.Id);
                
                if(!mapContractId2PaymentPlan.containsKey(objPaymentPlan.BillingContract__c)){
                    mapContractId2PaymentPlan.put(objPaymentPlan.BillingContract__c, objPaymentPlan);//AT-3174
                }
            }
        }
		List<BillingContract__c> listContractForLastBillCalcDate = [SELECT Id,LastBillCalculationDate__c
                                                            FROM BillingContract__c
                                                            WHERE ID IN: contractIds];
        
        for(BillingContract__c objContract : listContractForLastBillCalcDate){
            
            if(!mapContractId2LatestBillCalcDate.containsKey(objContract.Id)){
                mapContractId2LatestBillCalcDate.put(objContract.Id,objContract.LastBillCalculationDate__c);
            }
        }    
        listInstalmentsToBeRetained = [SELECT Id,InstalmentDueDate__c,
                                       		  PaymentPlan__c,
                                       		  InstalmentAmountDue__c,
                                       		  InstalmentNumber__c,
                                       		  Type__c
                                       FROM Instalment__c
                                       WHERE PaymentPlan__c IN: setPayPlanIds
                                       AND Type__c =: Label.CuAp_InstalmentTypeNormal];
        if(!listInstalmentsToBeRetained.isEmpty()){
            for(Instalment__c objInstalment : listInstalmentsToBeRetained){           
                
                if(!mapPaymentPlanId2ListInstalments.containsKey(objInstalment.PaymentPlan__c)){
                    mapPaymentPlanId2ListInstalments.put(objInstalment.PaymentPlan__c,new List<Instalment__c>());
                }
                mapPaymentPlanId2ListInstalments.get(objInstalment.PaymentPlan__c).add(objInstalment);
            }
        }  
        if(mapContractId2PaymentPlan != null && mapContractId2PaymentPlan.keyset().size() > 0){
            
            for(Id objContractId : mapContractId2PaymentPlan.keyset()){
                List<Instalment__c> listAllPPInstalments = new List<Instalment__c>();
                DateTime lastBillCalcDate;
                PaymentPlan__c objPayPlan = new PaymentPlan__c();
                if(mapContractId2LatestBillCalcDate != null && mapContractId2LatestBillCalcDate.containsKey(objContractId))
                    lastBillCalcDate = mapContractId2LatestBillCalcDate.get(objContractId);
                
                if(mapContractId2PaymentPlan.containsKey(objContractId))
                    objPayPlan = mapContractId2PaymentPlan.get(objContractId);
                
                if(mapPaymentPlanId2ListInstalments != null && mapPaymentPlanId2ListInstalments.keyset().size() > 0 && mapPaymentPlanId2ListInstalments.containsKey(objPayPlan.Id))
                    listAllPPInstalments = mapPaymentPlanId2ListInstalments.get(objPayPlan.Id);
                
                if(!listAllPPInstalments.isEmpty()){    
                    //This is for getting Instalment amount for validation purpose
                    if(listAllPPInstalments.size() > 1){
                        mapContractId2InstalmentAmountForValidation.put(objContractId,listAllPPInstalments[1].InstalmentAmountDue__c);
                    }
                    else{
                        mapContractId2InstalmentAmountForValidation.put(objContractId,listAllPPInstalments[0].InstalmentAmountDue__c);
                    }
                    for(Instalment__c objRetainInstalment : listAllPPInstalments){
                        if(objRetainInstalment.InstalmentDueDate__c > lastBillCalcDate){
                            if(!mapContractId2ListInstalmentToRetain.containsKey(objContractId)){
                                mapContractId2ListInstalmentToRetain.put(objContractId,new List<Instalment__c>());
                            }
                            mapContractId2ListInstalmentToRetain.get(objContractId).add(objRetainInstalment);
                        }                
                    }
                }
            }
        }
        objWrapper.mapContractId2ListInstalmentToRetain = mapContractId2ListInstalmentToRetain;
        objWrapper.mapContractId2InstalmentAmountForValidation = mapContractId2InstalmentAmountForValidation;
        return objWrapper;                
    }
    
    /******************************************************************************
    @author      	Echo: Tarun Gupta
    @date      		12-Feb-2017
    @param			none
    @return			none
    @description	AT-2942, wrapper class to hold list of Instalments to be retained and amount of Instalments to do the validation
    *******************************************************************************/
    public class WrapContractId2InstalmentAndAmount{
        public Map<Id,List<Instalment__c>> mapContractId2ListInstalmentToRetain;                
        public Map<Id,Decimal> mapContractId2InstalmentAmountForValidation;
        
        public WrapContractId2InstalmentAndAmount(){
            this.mapContractId2ListInstalmentToRetain = new Map<Id,List<Instalment__c>>();             
            this.mapContractId2InstalmentAmountForValidation = new Map<Id,Decimal>();
        } 
    }
    
}