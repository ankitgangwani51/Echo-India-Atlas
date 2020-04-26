/******************************************************************************
@author    		Echo: Tarun Gupta
@date      		04-June-2018
@description 	Controller for Updating Instalments in case of Budget Plans based on Renewal Date
@Revisions      CLB-33,CLB-76
*******************************************************************************/
public with sharing class GlUt_UpdateBudgetRenewals {
    
    private static final String CLASS_NAME = 'GlUt_UpdateBudgetRenewals';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static final List<String> bookFields = new List<String> {
        GlUt_APIConstantsBook.BUDGETRESETMONTHAPINAME,
        GlUt_APIConstantsBook.DEPOTAPINAME,
        GlUt_APIConstantsBook.READFREQUENCYAPINAME
    };
    
    private static final List<String> serviceFields = new List<String> {
    	GlUt_APIConstantsService.SUPPLYPOINTAPINAME,
        GlUt_APIConstantsService.SERVICECONTRACTAPINAME
    };
    
    private static final List<String> supplyPointFields = new List<String> {
    	GlUt_APIConstantsSupplyPoint.BOOKAPINAME
    };                   
    
    private static Map<String, Integer> monthsMap = new Map<String, Integer>{
        'January'  => 1,'February' => 2,'March'  => 3,'April'  => 4,'May'  => 5,'June'  => 6,
        'July'  => 7,'August'  => 8,'September'  => 9,'October'  => 10,'November'  => 11,'December'  => 12
    };
    
    
    /**********************************************************************************************
	@author         Echo : Tarun Gupta
	@date           29 May 2018
	@param          String contractId
	@return         Budget Renewal Date
	@description    
	**********************************************************************************************/
    @AuraEnabled
    public static WrapPaymentPlanInstalments amendPPInstalments(String contractId,Date planStartDate,PaymentPlanType__c paymentPlanTypeObject,List<Instalment__c> listOfWizardInstalments, List<Book__c> newBookList,Date datePlanEndDate) {
  
        WrapPaymentPlanInstalments objWrapper = new WrapPaymentPlanInstalments();
        String paymentFrequency;
        Integer maxNumberOfInstalments;
        Integer numberOfRollingInstalments;
        Date planEndDate;        
        Date lastInstalmentDate;
        Date updatedRenewalDateNew;
        Decimal lastInstalmentAmountDue;
        
        List<Instalment__c> lstPPInstalment = new List<Instalment__c>();
        List<String> listBudgetMonths = new List<String>();
        Map<Id,PaymentPlanType__c> mapPaymentPlanDetails = new Map<Id,PaymentPlanType__c>();
        
        if(paymentPlanTypeObject != null){    
            // It means it is called from wizard
            
            if(paymentPlanTypeObject != null && paymentPlanTypeObject.PlanType__c == Label.CuAp_PaymentPlanTypePlanTypeBudgetPlan){
                paymentFrequency = paymentPlanTypeObject.PaymentFrequency__c;
                maxNumberOfInstalments = Integer.valueOf(paymentPlanTypeObject.MaximumNumberOfInstalments__c); 
                numberOfRollingInstalments = Integer.valueOf(paymentPlanTypeObject.NumberofRollingInstalments__c);
                lstPPInstalment = getNormalInstalments(listOfWizardInstalments);
                
                Date EndDate;
                if(datePlanEndDate != null)
                    EndDate = datePlanEndDate;
                else
                    EndDate = planStartDate.addYears(1);
                
                planEndDate = date.newInstance(EndDate.year(), EndDate.month(), 01) ;
            }
            else{
                return null;
            }
        } 
        else{
            return null;
        }
        
        List<Book__c> bookList = new List<Book__c>();
        //New book passed from supply point screen
        if (newBookList.isEmpty()){
            // Get The list of Books associated to contract
            bookList = getListOfAssociatedBook(contractId);
        }else{
            bookList = newBookList.clone();
        }
        
        // Get The list of budget month
        if(!bookList.isEmpty()){
            listBudgetMonths = getListOfBudgetResetMonth(bookList);
        } 
        else{
            return null;
        }
        system.debug('listBudgetMonths***'+ listBudgetMonths);
        system.debug('planEndDate***'+ planEndDate);
        // Get The latest budget Month from the list        
        if(!listBudgetMonths.isEmpty()){
            List<Integer> listBudgetMonthsInteger = new List<Integer>();
            for(String objBudgetMonth : listBudgetMonths){
                listBudgetMonthsInteger.add(monthsMap.get(objBudgetMonth));
            }
            updatedRenewalDateNew = getRenewalDate(planEndDate ,listBudgetMonthsInteger);
        }
        else{
            return null;
        }
        system.debug('updatedRenewalDateNew***'+ updatedRenewalDateNew);
        
        if(updatedRenewalDateNew == null || (updatedRenewalDateNew != null && updatedRenewalDateNew < system.today())){
            return null;
        }
        
        // Get The amount and date of last Instalment        
        // Create a map of Month number with date of Instalments in that month 
        if(!lstPPInstalment.isEmpty()){
            lastInstalmentDate = lstPPInstalment[lstPPInstalment.size() - 1].InstalmentDueDate__c;
            lastInstalmentAmountDue = lstPPInstalment[lstPPInstalment.size() - 1].InstalmentAmountDue__c;  
        }
        
        if(updatedRenewalDateNew != null){
            objWrapper.contractRenewalDate = updatedRenewalDateNew;
            if(updatedRenewalDateNew.addMonths(1) < lastInstalmentDate){
                
                // It means take Instalments to this date and delete others
                List<Instalment__c> lstToBeAddedInWrapper = new List<Instalment__c>();
                
                for(Instalment__c objInstalment : lstPPInstalment){
                    if(objInstalment.Type__c == Label.CuAp_InstalmentTypeNormal && objInstalment.InstalmentDueDate__c < updatedRenewalDateNew.addMonths(1)){   
                        lstToBeAddedInWrapper.add(objInstalment);
                    }
                    else if(objInstalment.Type__c == Label.CuAp_InstalmentTypeRolling){
                        lstToBeAddedInWrapper.add(objInstalment);
                    }
                }
                
                Integer iCount = 0;
                
                if(!lstToBeAddedInWrapper.isEmpty()){
                    for(Instalment__c objUpdateInstalmentNumber: lstToBeAddedInWrapper){
                        iCount += 1;
                        objUpdateInstalmentNumber.InstalmentNumber__c = iCount;
                    }
                    objWrapper.lstInstalmentsToBeAdded.addAll(lstToBeAddedInWrapper);
                }
            }
            else{
                // Add new Instalments from last Instalment to updatedRenewalDateNew
                Date instalmentDate = lastInstalmentDate;
                
                // Add Existing Instalments to wrapper in case of adding new Instalments
                objWrapper.lstInstalmentsToBeAdded.addAll(lstPPInstalment);
                
                List<Instalment__c> lstToBeAddedInWrapper = new List<Instalment__c>();
                Integer instalmentNumber = lstPPInstalment.size();
                
                for(Integer n = 0; n < maxNumberOfInstalments; n++){
                    
                    instalmentDate = incrementDate(paymentFrequency,instalmentDate);
                    
                    if(instalmentDate < updatedRenewalDateNew.addMonths(1)){
                        instalmentNumber += 1;
                        
                        lstToBeAddedInWrapper.add(new Instalment__c(
                            Type__c = Label.CuAp_InstalmentTypeNormal, 
                            InstalmentNumber__c = instalmentNumber, 
                            InstalmentAmountDue__c = lastInstalmentAmountDue, 
                            InstalmentDueDate__c = instalmentDate 
                        ));
                    }
                }
                objWrapper.lstInstalmentsToBeAdded.addAll(lstToBeAddedInWrapper);
            }
        }
        
        // Add Number of Rolling Instalments
        if(!objWrapper.lstInstalmentsToBeAdded.isEmpty()){
            
            List<Instalment__c> listRollingInstalments = addRollingInstalments(numberOfRollingInstalments,
                                                                               objWrapper.lstInstalmentsToBeAdded.size(),
                                                                               objWrapper.lstInstalmentsToBeAdded[objWrapper.lstInstalmentsToBeAdded.size() - 1].InstalmentAmountDue__c,
                                                                               objWrapper.lstInstalmentsToBeAdded[objWrapper.lstInstalmentsToBeAdded.size() - 1].InstalmentDueDate__c,
                                                                               paymentFrequency);
            
            if(!listRollingInstalments.isEmpty()){
                objWrapper.lstInstalmentsToBeAdded.addAll(listRollingInstalments);
            }
        }
        
        return objWrapper;
    }
    
    /******************************************************************************
	@author      	Echo: Tarun Gupta
	@date      		01-June-2018
	@param			none
	@return			none
	@description	wrapper class to hold the Instalments and corrsponding Intalments to be Added\Deleted
	*******************************************************************************/
    public class WrapPaymentPlanInstalments{
        
        //@AuraEnabled public BillingContract__c objContract;                
        @AuraEnabled public Date contractRenewalDate; 
        @AuraEnabled public List<Instalment__c> lstInstalmentsToBeAdded; 
        
        public WrapPaymentPlanInstalments(){
            //this.objContract = new BillingContract__c();             
            this.lstInstalmentsToBeAdded = new List<Instalment__c>();
        } 
    }
    
    /******************************************************************************
	@author			Echo: Tarun Gupta
	@date           01 June 2018
	@param			Date - the date
	@return			Date - the incremented date
	@description    increments the date depending on the payment frequency
	*******************************************************************************/
    private static Date incrementDate(String paymentFrequency, Date d) {
        
        if (paymentFrequency == Label.CuAp_PaymentPlanTypePaymentFrequencyWeekly) d = d.addDays(7);
        else if (paymentFrequency == Label.CuAp_PaymentPlanTypePaymentFrequencyFortnightly) d = d.addDays(14);
        else if (paymentFrequency == Label.CuAp_PaymentPlanTypePaymentFrequencyMonthly) d = d.addMonths(1);
        else if (paymentFrequency == Label.CuAp_PaymentPlanTypePaymentFrequencyHalfYearly) d = d.addMonths(6);
        else if (GlUt_RegionUtility.getAURegionCustomSetting() && paymentFrequency == Label.CuAp_PaymentPlanTypePaymentFrequencyQuarterly) d = d.addMonths(3);
        return d;
    }
    
    /******************************************************************************
	@author			Echo: Tarun Gupta
	@date           05 June 2018
	@param			Date - the date
	@return			Date - Renewal Date
	@description    Return the Renewal Date
	*******************************************************************************/
    private static Date getRenewalDate(Date lastInstalmentDate , List<integer> listBudgetMonthsInteger) {
      
        Date updatedRenewalDate;
        List<Date> listPossibleRenewalDates = new List<Date>();
        List<Date> listEarlierRenewalDates = new List<Date>();
        List<Date> listLaterRenewalDates = new List<Date>();
        
        for(Integer objInt : listBudgetMonthsInteger){
            
            Date dummyrenewalMonth1 = date.newInstance(lastInstalmentDate.year(), objInt, 01) ;
            Date dummyrenewalMonth2 = date.newInstance(lastInstalmentDate.year() + 1, objInt, 01) ;
            Date dummyrenewalMonth3 = date.newInstance(lastInstalmentDate.year() - 1, objInt, 01) ;
            
            if(dummyrenewalMonth1 >= system.today()){
                listPossibleRenewalDates.add(dummyrenewalMonth1);
            }
            if(dummyrenewalMonth2 >= system.today()){
                listPossibleRenewalDates.add(dummyrenewalMonth2);
            }
            if(dummyrenewalMonth3 >= system.today()){
                listPossibleRenewalDates.add(dummyrenewalMonth3);
            }  
        }
        system.debug('listPossibleRenewalDates***'+ listPossibleRenewalDates);
        for(Date objDate : listPossibleRenewalDates){
            
            if(objDate <= lastInstalmentDate){
                listEarlierRenewalDates.add(objDate);
            }
            else{
                listLaterRenewalDates.add(objDate);
            }
        }
        
        if(!listEarlierRenewalDates.isEmpty()){
            listEarlierRenewalDates.sort();
            
            updatedRenewalDate = listEarlierRenewalDates[listEarlierRenewalDates.size() - 1];
        }
        if(updatedRenewalDate == null && !listLaterRenewalDates.isEmpty()){
            listLaterRenewalDates.sort();
            
            updatedRenewalDate = listLaterRenewalDates[0];
        }
        return updatedRenewalDate;
    }
    
    /******************************************************************************
	@author			Echo: Tarun Gupta
	@date           01 June 2018
	@param			Date - the date
	@return			Date - the incremented date
	@description    increments the date depending on the payment frequency
	*******************************************************************************/
    private static List<Instalment__c> addRollingInstalments(Integer numberOfRollingInstalments,Integer numberOFNormalInstalments,Decimal lastInstalmentAmountDue,Date lastNormalInstalmentDate,String paymentFrequency) {
		
        List<Instalment__c> listRollingInstalments = new List<Instalment__c>();
        
        for(Integer n = 0; n < numberOfRollingInstalments; n++){
            
            numberOFNormalInstalments += 1;
            lastNormalInstalmentDate = incrementDate(paymentFrequency,lastNormalInstalmentDate);
            listRollingInstalments.add(new Instalment__c(
                Type__c = Label.CuAp_InstalmentTypeRolling, 
                InstalmentNumber__c = numberOFNormalInstalments, 
                InstalmentAmountDue__c = lastInstalmentAmountDue, 
                InstalmentDueDate__c = lastNormalInstalmentDate 
            ));
        }
        return listRollingInstalments;
    }
    
    /******************************************************************************
	@author			Echo: Tarun Gupta
	@date           04 June 2018
	@param			Id - payment plan Id
	@return			List Instalment
	@description    return List of Instalment based on payment plan Id
	*******************************************************************************/
    private static List<Instalment__c> getNormalInstalments(List<Instalment__c> listAllInstalments) {
        List<Instalment__c> lstNormalInstalments = new List<Instalment__c>();
        if(!listAllInstalments.isEmpty()){
            for(Instalment__c objInstalments : listAllInstalments){
                if(objInstalments.Type__c == Label.CuAp_InstalmentTypeNormal){
                    lstNormalInstalments.add(objInstalments);
                }
            }
        }
        return lstNormalInstalments;
    }
    
    /******************************************************************************
	@author			Echo: Tarun Gupta
	@date           04 June 2018
	@param			String - ContractId
	@return			List - Book object
	@description    return List of Book object on based on contractId
	*******************************************************************************/
    private static List<Book__c> getListOfAssociatedBook(String contractId) {
        Set<Id> bookIdSet = new Set<Id>();
        Set<Id> supplyPointIdSet = new Set<Id>();
        List<Book__c> bookList = new List<Book__c>();
        List<Service__c> serviceList = new List<Service__c>();
        List<SupplyPoint__c> supplyPointList = new List<SupplyPoint__c>();
        serviceList = (List<Service__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsService.SERVICEAPINAME, 
                                         						            serviceFields,
                                         						            'WHERE ' + GlUt_APIConstantsService.SERVICECONTRACTAPINAME + ' = '  + GlUt_FieldSecurity.QuotedString(contractId));
        
        if(!serviceList.isEmpty()){
            for(Service__c objService :serviceList){
                supplyPointIdSet.add(objService.Supplypoint__c);
            }
        }
        if(!supplyPointIdSet.isEmpty()){
            supplyPointList = (List<SupplyPoint__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, 
                                                     						            supplyPointFields,
                                                     						            'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(supplyPointIdSet));
        }
        if(!supplyPointList.isEmpty()){
            for (SupplyPoint__c objSP : supplyPointList) {
                bookIdSet.add(objSP.Book__c);
            }
        }
        if(!bookIdSet.isEmpty()){
            bookList = (List<Book__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBook.BOOKAPINAME, 
                                       							            bookFields,
                                       							            'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(bookIdSet));
        }
        return bookList;
    }
    
    /******************************************************************************
	@author			Echo: Tarun Gupta
	@date           04 June 2018
	@param			List - Book object
	@return			String - Latest Budget Reset Month
	@description    return the latest budget reset month
	*******************************************************************************/
    private static List<String> getListOfBudgetResetMonth(List<Book__c> bookList) {
        
        String budgetResetMonthStr = '';
        List<String> lstBookBudgetResetMonth = new List<String>();        
        List<String> lstSelectedMonths = new List<String>();
        Set<String> setSelectedMonths = new Set<String>();
        
        for (Book__c bookObj : bookList) {
			if(string.isNotBlank(budgetResetMonthStr)){
				budgetResetMonthStr = budgetResetMonthStr + ';' + bookObj.BudgetResetMonth__c;     
			}else{
				budgetResetMonthStr = bookObj.BudgetResetMonth__c;
			}         
        }
       	if(string.isNotBlank(budgetResetMonthStr)){
            lstBookBudgetResetMonth = budgetResetMonthStr.split(';');
        }   	
        // To remove duplicate values        
        if(!lstBookBudgetResetMonth.isEmpty()){
          setSelectedMonths.addAll(lstBookBudgetResetMonth);
        }
        lstSelectedMonths.addAll(setSelectedMonths);   
        return lstSelectedMonths;
    }
    
    /******************************************************************************
	@author			Echo: Tarun Gupta
	@date           29 June 2018
	@param			Set<Id> - ContractIds
	@return			Map<Id,List<Book>>
	@description    return List of Book on contractId
	*******************************************************************************/
    public static Map<Id,List<Book__c>> getListOfBookOnContract(Set<Id> setContractIds) {
  
        Map<Id,List<Book__c>> mapContract2ListOfBook = new Map<Id,List<Book__c>>();                
        List<Service__c> listNewService = new List<Service__c>();
        List<Book__c> lisNewbooks = new List<Book__c>();
        
        listNewService = [SELECT  Id,Name,
                                  BillingContract__c,BillingContract__r.Name,
                                  SupplyPoint__c,SupplyPoint__r.Name,SupplyPoint__r.Book__c 
                          FROM Service__c WHERE BillingContract__c IN: setContractIds];
        
        Map<Id,Id> mapBookId2Contract = new Map<Id,Id>();
        
        if(!listNewService.isEmpty()){
            for(Service__c objService : listNewService){
                
                if(objService.SupplyPoint__r.Book__c != null){
                    
                    if(!mapBookId2Contract.containsKey(objService.SupplyPoint__r.Book__c)){
                        mapBookId2Contract.put(objService.SupplyPoint__r.Book__c ,objService.BillingContract__c);
                    }
                }
            }
        }
        
        if(mapBookId2Contract != null && mapBookId2Contract.keyset().size() > 0){
            lisNewbooks = [SELECT Id,BudgetResetMonth__c,Depot__c,ReadFrequency__c FROM Book__c WHERE Id IN: mapBookId2Contract.keyset()];
        }

        if(!lisNewbooks.isEmpty()){
            
            for(Book__c objBook :lisNewbooks){
                if(mapBookId2Contract.containsKey(objBook.Id)){
                    
                    if(!mapContract2ListOfBook.containsKey(mapBookId2Contract.get(objBook.Id))){
                        mapContract2ListOfBook.put(mapBookId2Contract.get(objBook.Id), new List<Book__c>());
                    }
                    mapContract2ListOfBook.get(mapBookId2Contract.get(objBook.Id)).add(objBook);
                }
            }
        }
        
        return mapContract2ListOfBook;
    }
}