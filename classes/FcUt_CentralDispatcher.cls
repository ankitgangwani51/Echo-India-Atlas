/**********************************************************************************************
@author         Echo : Dependra Singh
@date           19-March-2018
@description:   This Class this class to centralize the processing and creation of financial controls records. 
Reference : Development Standards document section Atlas Section: 10.3 Trigger Framework  
@group          FinancialReportCentralizeDispatcher
@revisions:     5 July 2018: Echo: Sudhir Kumar -> AT-2873(Core 7a)
                AT-4891/2 Code Check Marx Changes for FLS INSERT/UPDATE
@revisions:     04 Mar 2019: Echo: Tarun Gupta -> UL-63,UL-240
**********************************************************************************************/
public without sharing class FcUt_CentralDispatcher  {    
    /**********************************************************************************************
	@author         Echo: Dependra Singh
	@date           19-March-2018
	@param          GlUt_TriggerHandlerObj inputParam
	@return         void
	@description    This method is invoked by payments, payment allocation, 
	bill items and amendments will pass over the parameters passed to it from the respective method to 
	this class to centralize the processing and creation of financial controls records. 
	**********************************************************************************************/
    public static void Main(GlUt_TriggerHandlerObj trigObj){  
        system.debug('trigObj====='+trigObj);
        if(trigObj.TriggerObject == GlUt_Constants.OBJ_BILLITEM){
            ProcessBillItem(trigObj);
        }
        else 
            if(trigObj.TriggerObject == GlUt_Constants.OBJ_BILLITEMAMENDMENT){ // MT - 14-08-2018 3174
                ProcessAmendment(trigObj);
            }
        else   
            if(trigObj.TriggerObject == GlUt_Constants.OBJ_PAYMENT){
                system.debug('Payment====='+GlUt_Constants.OBJ_PAYMENT);
                ProcessPayment(trigObj);
            } 
        else  
            if(trigObj.TriggerObject == GlUt_Constants.OBJ_PAYMENTALLOCATION){
                ProcessPaymentAllocation(trigObj);
            }  
    }
    /**********************************************************************************************
	@author         Echo: Dependra Singh
	@date           19-March-2018
	@param          GlUt_TriggerHandlerObj inputParam
	@return         void
	@description    (1)-Check that the bill item is a new bill item (i.e. the lookup to bill item is blank) 
	(2)-Query the 'Financial Transaction Event Type' object where the 'Name' is equal to the bill item 'Bill Calculation Reason' and the object = 'Bill Item'
	(3)-Use mapping tables in the data mapping section of this document, Create a Financial Controls Record Based on the mappings. Link the Financial controls record to the bill item 
	(4)-Additionally, save the Financial Year to the 'Financial Year' Field on Bill Item. Also save the 'Financial Period' to the  'Financial Period' field on Bill Item
	**********************************************************************************************/
    
    public static void ProcessBillItem(GlUt_TriggerHandlerObj trigObj){
        // Set of string financial transaction event type 
        set<string> setFinancialTransactionEventType = new set<string>();
        //set of string of bill calculation reason 
        set<string> billCalculationReasonSet =  new set<string>();
        //Set of Bill Item Ids
        set<Id> billItemIds =  new set<Id>();
        // List of bill Item End Date
        List<Date> lstBillItemEndDt = new List<Date>();
        // Liat of Bill Item Calculation Date.
        List<Date> lstBillItemCalcDt = new List<Date>();
        // List of Financial Control Records
        List<FinancialControl__c> lstFinancialControl= new List<FinancialControl__c>();
        system.debug('trigObj.newlist======='+ trigObj.newlist);
        if(!trigObj.newlist.isEmpty()){
            
            //Check that the bill item is a new bill item (i.e. the lookup to bill item is blank) Also, only take those bill items which are not for ‘Pending Bills’
            for(BillItem__c objBillItem : (List<BillItem__c>)trigObj.newlist){
                if(objBillItem.BillItem__c == null)
                    billItemIds.add(objBillItem.Id);
            }
            system.debug('billItemIds======'+ billItemIds);
            List<BillItem__c> lstBillItem = [SELECT Id, BilledAmount__c, TotalDiscountAmount__c, TotalTaxAmount__c,
                                             Bill__r.BillType__c, Bill__r.BillCalculationReason__c,
                                             OriginalCalculationDate__c, EndDate__c,
                                             ServiceItem__r.ServiceItemType__c,
                                             ServiceItem__r.Service__r.BillingContract__r.BillingFrequency__c,
                                             ServiceItem__r.Service__r.BillingContract__r.AccountName__c
                                             FROM BillItem__c 
                                             WHERE Id IN:billItemIds AND Bill__r.BillType__c!=: FcUt_Constants.PENDING];
            system.debug('lstBillItem======'+ lstBillItem);
            if(!lstBillItem.isEmpty()){
                for(BillItem__c obj : lstBillItem){
                    billCalculationReasonSet.add(obj.Bill__r.BillCalculationReason__c);
                    
                    if(obj.EndDate__c != null)
                    	lstBillItemEndDt.add(obj.EndDate__c);
                    
                    if(obj.OriginalCalculationDate__c != null)
                    	lstBillItemCalcDt.add(obj.OriginalCalculationDate__c);
                }
            }	
            system.debug('lstBillItemEndDt======'+ lstBillItemEndDt);
            system.debug('lstBillItemCalcDt======'+ lstBillItemCalcDt);
            //get Effective period
            Map<Date,Period> billItemEndDtToPeriodMap = new Map<Date,Period>();
            if(!lstBillItemEndDt.isEmpty()){
                billItemEndDtToPeriodMap = getPeriodForDate(lstBillItemEndDt);
            }
            system.debug('billItemEndDtToPeriodMap======'+ billItemEndDtToPeriodMap);
            //get Actual period
            Map<Date,Period> billItemCalcDtToPeriodMap = new Map<Date,Period>();
            if(lstBillItemCalcDt != null && !lstBillItemCalcDt.isEmpty()){
                system.debug('Inside***');
                billItemCalcDtToPeriodMap = getPeriodForDate(lstBillItemCalcDt);
            }
            system.debug('billItemCalcDtToPeriodMap======'+ billItemCalcDtToPeriodMap);
            // Map of <string,Id> , get financial transaction event type id by Name.            
            Map<string, Id> mapFTETIdByName = new Map<string, Id>();
            
            //Query the ‘Financial Transaction Event Type’ object where the ‘Name’ is equal to the bill item ‘Bill Calculation Reason’ and the object = ‘Bill Item’             
            /*List<FinancialTransactionEventType__c> lstFinancialTranEventType = [SELECT Id, Name, Name__c, Object__c,Category__c 
                                                                                FROM FinancialTransactionEventType__c 
                                                                                WHERE Name__c IN : billCalculationReasonSet 
                                                                                AND Object__c =:FcUt_Constants.BILLITEM ];*/
			List<FinancialTransactionEventType__c> lstFinancialTranEventType = getFCEventType(billCalculationReasonSet,FcUt_Constants.BILLITEM);																	
             system.debug('lstFinancialTranEventType======'+ lstFinancialTranEventType);
            // Create map to get financial transaction event type id by using bill calculation reason name which we are having in financial transaction event type name.
            if(!lstFinancialTranEventType.isEmpty()){
                for(FinancialTransactionEventType__c objFTET : lstFinancialTranEventType){
                    if(!mapFTETIdByName.containsKey(objFTET.Name__c)){
                        mapFTETIdByName.put(objFTET.Name__c, objFTET.Id);
                    }
                }
            }
            system.debug('mapFTETIdByName======'+ mapFTETIdByName);
            // Looping over bill item record and create financial control records.
            for(BillItem__c objBillItem : lstBillItem){ 
                system.debug('objBillItem======'+ objBillItem);
                FinancialControl__c objFinancialControl = new FinancialControl__c(); 
                objFinancialControl.BillItem__c= objBillItem.Id;
                if(objBillItem.Bill__r.BillCalculationReason__c != null && mapFTETIdByName.containsKey(objBillItem.Bill__r.BillCalculationReason__c)){
                    objFinancialControl.FinancialTransactionEventType__c = mapFTETIdByName.get(objBillItem.Bill__r.BillCalculationReason__c); 
                }
                objFinancialControl.ServiceItemType__c = objBillItem.ServiceItem__r.ServiceItemType__c;                    
                objFinancialControl.Amount__c = objBillItem.BilledAmount__c;
                if(objBillItem.ServiceItem__r.Service__r.BillingContract__r.BillingFrequency__c!=null)
                    objFinancialControl.BillingFrequency__c = objBillItem.ServiceItem__r.Service__r.BillingContract__r.BillingFrequency__c;
                if(objBillItem.TotalDiscountAmount__c!=null)
                    objFinancialControl.DiscountAmount__c = objBillItem.TotalDiscountAmount__c;
                if(objBillItem.TotalTaxAmount__c!=null)
                    objFinancialControl.TaxAmount__c = objBillItem.TotalTaxAmount__c;
                
                if(objBillItem.OriginalCalculationDate__c != null && billItemCalcDtToPeriodMap.containsKey(objBillItem.OriginalCalculationDate__c)){
                    objFinancialControl.ActualPeriod__c = String.valueOf(billItemCalcDtToPeriodMap.get(objBillItem.OriginalCalculationDate__c).Number);
                    objFinancialControl.ActualPeriodId__c = billItemCalcDtToPeriodMap.get(objBillItem.OriginalCalculationDate__c).Id;
                    objFinancialControl.ActualYear__c = billItemCalcDtToPeriodMap.get(objBillItem.OriginalCalculationDate__c).FiscalYearSettings.Name;
                }
                system.debug('objBillItem.EndDate__c======'+ objBillItem.EndDate__c);
                if(billItemEndDtToPeriodMap.containsKey(objBillItem.EndDate__c)){
                    objFinancialControl.EffectivePeriod__c = String.valueOf(billItemEndDtToPeriodMap.get(objBillItem.EndDate__c).Number);
                    objFinancialControl.EffectivePeriodId__c = billItemEndDtToPeriodMap.get(objBillItem.EndDate__c).Id;
                    objFinancialControl.EffectiveYear__c = billItemEndDtToPeriodMap.get(objBillItem.EndDate__c).FiscalYearSettings.Name;
                }
                if(GlUt_RegionUtility.getUKRegionCustomSetting() && objBillItem.ServiceItem__r.Service__r.BillingContract__r.AccountName__c == null){
                    objFinancialControl.Void__c = true;
                }
                lstFinancialControl.add(objFinancialControl);
            }
            // Checking if list is not empty then inserting.
            system.debug('lstFinancialControl========'+ lstFinancialControl);
            if(!lstFinancialControl.isEmpty()){
                lstFinancialControl = (List<FinancialControl__c>) GlUt_FieldSecurity.cleanseFields(lstFinancialControl, false); //AT-4891 Code Check Marx Changes Starts/Ends Here.
                insert lstFinancialControl;
            }  
        }
    } 
    
    /**********************************************************************************************
	@author         Echo: Swati Mathur
	@date           19-March-2018
	@param          GlUt_TriggerHandlerObj inputParam
	@return         void
	@description    (1)-Query all of the associated bill items into a map of amendment id to bill item. 
	Use this to retrieve info from the bill item as specified in the mappings   table 
	(2)-Query the ‘Financial Transaction Event 'Type' object where the 'Name' is equal to the amendment 'Amendment Reason' and the object ='Amendment' 
	(3)-Use mapping tables in the data mapping section of this document 
	Create a Financial Controls Record Based on the mappings. Link the Financial controls record to the amendment
	**********************************************************************************************/
    public static void ProcessAmendment(GlUt_TriggerHandlerObj trigObj){
        // Map of <Id, Id> Bill Id id by ammendment id.
        Map<Id,Id> amendmentIdtoBillItemIdMap = new Map<Id,Id>();  
        // Map of <Id,BillItem__c> . Bill Item by Id.
        Map<Id,BillItem__c> BillItemIdtoBillItemMap = new Map<Id,BillItem__c>();  
        // Map of <string,Id> , get financial transaction event type id by Name.
        Map<string,Id> amendmentReasontoFTETIdMap = new Map<string,Id>(); 
        // Set of string - ammendment reason 
        Set<string> amendmentReasonSet =  new Set<string>();
        // List of bill Item end date
        List<Date> lstBillItemEndDt = new List<Date>();    
        // List of Financial Control Records
        List<FinancialControl__c> lstFinancialControl= new List<FinancialControl__c>();       
        Date amendmentCreatedDate;
        // If trigger.new is not empty
        if(!trigObj.newlist.isEmpty()){ 
            // Looping over Ammedments and settign values in variables.
            for(BillItemAmendment__c objAmendment : (List<BillItemAmendment__c>)trigObj.newlist){ 
                if(!amendmentIdtoBillItemIdMap.containsKey(objAmendment.Id)){
                    amendmentIdtoBillItemIdMap.put(objAmendment.Id, objAmendment.AmendedBillItem__c);   
                }			
                amendmentReasonSet.add(objAmendment.AmendmentReason__c);
                amendmentCreatedDate = date.newinstance(objAmendment.CreatedDate.year(), objAmendment.CreatedDate.month(), objAmendment.CreatedDate.day());
            }            
            // Querying bill items where id in map.
            List<BillItem__c> lstBillItem = [SELECT Id, EndDate__c, ServiceItem__r.ServiceItemType__c,
                                             ServiceItem__r.Service__r.BillingContract__r.BillingFrequency__c,
                                             ServiceItem__r.Service__r.BillingContract__r.Void__c
                                             FROM BillItem__c 
                                             WHERE Id IN: amendmentIdtoBillItemIdMap.values()];
            if(!lstBillItem.isEmpty()){
                for (BillItem__c objBillItem : lstBillItem){                
                    BillItemIdtoBillItemMap.put(objBillItem.Id, objBillItem);
                    lstBillItemEndDt.add(objBillItem.EndDate__c);
                }
            }							 
            //get Effective period
            Map<Date,Period> billItemEndDtToPeriodMap = new Map<Date,Period>();
            if(!lstBillItemEndDt.isEmpty())
                billItemEndDtToPeriodMap = getPeriodForDate(lstBillItemEndDt);            
            
            //get Actual period
            Period objActualPeriod = [SELECT Id,FiscalYearSettings.Name,Number 
                                      FROM Period 
                                      WHERE Type=:FcUt_Constants.MONTH
                                      AND StartDate <=: amendmentCreatedDate 
                                      AND EndDate >=: amendmentCreatedDate];
            // Querying list of financial transaction event type where name in amendmentReasonSet and Object is Amendment.            
            /*List<FinancialTransactionEventType__c> lstFinancialTranEventType = [SELECT Id, Name, Name__c, Object__c, Category__c  
                                                                                FROM FinancialTransactionEventType__c 
                                                                                WHERE Name__c IN: amendmentReasonSet 
                                                                                AND Object__c =: FcUt_Constants.AMENDMENT];*/
																				
			List<FinancialTransactionEventType__c> lstFinancialTranEventType = getFCEventType(amendmentReasonSet,FcUt_Constants.AMENDMENT);																	
            // Creating Map using list of financial transaction event type.                                                         
            if(!lstFinancialTranEventType.isEmpty()){ 
                for(FinancialTransactionEventType__c objFTET :lstFinancialTranEventType ){
                    if(!amendmentReasontoFTETIdMap.containsKey(objFTET.Name__c)){
                        amendmentReasontoFTETIdMap.put(objFTET.Name__c, objFTET.Id);                            
                    }                   
                }
            }
            //create Financial Controls Records      
            for(BillItemAmendment__c objAmendment : (List<BillItemAmendment__c>)trigObj.newlist){           
                FinancialControl__c objFinancialControl = new FinancialControl__c();
                objFinancialControl.Amendment__c = objAmendment.Id;
                if(amendmentReasontoFTETIdMap.containsKey(objAmendment.AmendmentReason__c)){
                    objFinancialControl.FinancialTransactionEventType__c = amendmentReasontoFTETIdMap.get(objAmendment.AmendmentReason__c);  
                }
                if(amendmentIdtoBillItemIdMap.containsKey(objAmendment.Id)){
                    if(BillItemIdtoBillItemMap.containsKey(amendmentIdtoBillItemIdMap.get(objAmendment.Id))){
                        objFinancialControl.ServiceItemType__c = BillItemIdtoBillItemMap.get(amendmentIdtoBillItemIdMap.get(objAmendment.Id)).ServiceItem__r.ServiceItemType__c;
                        if(GlUt_RegionUtility.getUKRegionCustomSetting()){
                            objFinancialControl.Void__c = BillItemIdtoBillItemMap.get(amendmentIdtoBillItemIdMap.get(objAmendment.Id)).ServiceItem__r.Service__r.BillingContract__r.Void__c;
                        }
                        objFinancialControl.BillingFrequency__c = BillItemIdtoBillItemMap.get(amendmentIdtoBillItemIdMap.get(objAmendment.Id)).ServiceItem__r.Service__r.BillingContract__r.BillingFrequency__c;
                        if(billItemEndDtToPeriodMap.containsKey(BillItemIdtoBillItemMap.get(amendmentIdtoBillItemIdMap.get(objAmendment.Id)).EndDate__c)){
                            objFinancialControl.EffectivePeriod__c = String.valueOf(billItemEndDtToPeriodMap.get(BillItemIdtoBillItemMap.get(amendmentIdtoBillItemIdMap.get(objAmendment.Id)).EndDate__c).Number);
                            objFinancialControl.EffectivePeriodId__c = billItemEndDtToPeriodMap.get(BillItemIdtoBillItemMap.get(amendmentIdtoBillItemIdMap.get(objAmendment.Id)).EndDate__c).Id;
                            objFinancialControl.EffectiveYear__c = billItemEndDtToPeriodMap.get(BillItemIdtoBillItemMap.get(amendmentIdtoBillItemIdMap.get(objAmendment.Id)).EndDate__c).FiscalYearSettings.Name;
                        }
                    }
                }
                if(objAmendment.Amount__c!=null)
                    objFinancialControl.Amount__c = objAmendment.Amount__c;
                if(objAmendment.DiscountAmount__c!=null)
                    objFinancialControl.DiscountAmount__c = objAmendment.DiscountAmount__c;
                if(objAmendment.TaxAmount__c!=null)
                    objFinancialControl.TaxAmount__c = objAmendment.TaxAmount__c;
                if(objActualPeriod != null){
                    objFinancialControl.ActualPeriod__c = String.valueOf(objActualPeriod.Number);
                    objFinancialControl.ActualPeriodId__c = objActualPeriod.Id;
                    objFinancialControl.ActualYear__c = objActualPeriod.FiscalYearSettings.Name;
                }
                lstFinancialControl.add(objFinancialControl);
            } 
            // Checking if list is not empty then inserting.           
            if(!lstFinancialControl.isEmpty()){
                lstFinancialControl = (List<FinancialControl__c>) GlUt_FieldSecurity.cleanseFields(lstFinancialControl, false); //AT-4891 Code Check Marx Changes Starts/Ends Here.
                insert lstFinancialControl;
            }            
        }       
    }
    
    /**********************************************************************************************
	@author         Echo: Dependra Singh
	@date           19-March-2018
	@param          GlUt_TriggerHandlerObj inputParam
	@return         void
	@description    (1)-Query the 'Financial Transaction Event Type' object where the 'Name' is equal to the bill item 'Record Type Name' and the object = 'Payment' 
	(2)-Use mapping tables in the data mapping section of this document ,Create a Financial Controls Record Based on the mappings. Link the Financial controls record to the payment 
	(3)-If the trigger is after update, Check the before and after version of the Credit Amount 
	If the amount has changed then create a new financial controls record for the delta (a reduction in credit amount will result in a negative financial controls record that will then reduce the credit amount shown in the totals records
	@revision		Echo: Sudhir Kumar
					AT-2873 (Core 7a): If the Payment does not have an associated Contract, the Payment should have a Credit Amount of 0 and no Financial Control Records will be created. 
	**********************************************************************************************/ 
    public static void ProcessPayment(GlUt_TriggerHandlerObj trigObj){
        System.debug('trigObj = Inside processPAyment = '+trigObj);
        // Map of <string,Id> , get financial transaction event type id by Name.
        Map<string, Id> mapFTETIdByName = new Map<string, Id>();
        // Set of String - Payment record types
        set<string> paymentRecordTypes = new  set<string>();
        // List of Financial Control Records
        List<FinancialControl__c> lstFinancialControl= new List<FinancialControl__c>();
        // Date variable to store payment created date.
        Date paymentCreatedDate;
        // Checking if trigger.new is not empty then looping over trigger new list to store vlues in variables.
        if(!trigObj.newlist.isEmpty()){
            for(Payment__c objPayment : (List<Payment__c>)trigObj.newlist){
                paymentRecordTypes.add(Schema.SObjectType.Payment__c.getRecordTypeInfosById().get(objPayment.RecordTypeId).getname());
                paymentCreatedDate = date.newinstance(objPayment.CreatedDate.year(), objPayment.CreatedDate.month(), objPayment.CreatedDate.day());
            }
            system.debug('paymentRecordTypes====='+paymentRecordTypes);
            system.debug('paymentCreatedDate====='+paymentCreatedDate);
            //get Actual and Effective period
            Period objPeriod = [SELECT Id,FiscalYearSettings.Name,Number FROM Period 
                                WHERE Type =: FcUt_Constants.MONTH
                                AND StartDate <=: date.valueOf(paymentCreatedDate) 
                                AND EndDate >=: date.valueOf(paymentCreatedDate) LIMIT 1];
            // Querying list of financial transaction event type where name in Payments record types  and Object is payemnt.
            /*List<FinancialTransactionEventType__c> lstFinancialTranEventType = [SELECT Id, Name, Name__c, Object__c,Category__c 
                                                                                    FROM FinancialTransactionEventType__c 
                                                                                    WHERE Name__c IN : paymentRecordTypes 
                                                                                    AND Object__c =: FcUt_Constants.PAYMENT
                                                                                    LIMIT 1];  */
            
            List<FinancialTransactionEventType__c> lstFinancialTranEventType =getFCEventType(paymentRecordTypes,FcUt_Constants.PAYMENT);
            system.debug('lstFinancialTranEventType====='+lstFinancialTranEventType);
            // Create map to get financial transaction event type id by using bill calculation reason name which we are having in financial transaction event type name.
            if(!lstFinancialTranEventType.isEmpty()){
                for(FinancialTransactionEventType__c objFTET : lstFinancialTranEventType){
                    if(!mapFTETIdByName.containsKey(objFTET.Name__c)){
                        mapFTETIdByName.put(objFTET.Name__c, objFTET.Id);
                    }
                }
            }
            system.debug('mapFTETIdByName====='+mapFTETIdByName);
            //create Financial Controls Records
            if(trigObj.oldmap != null && trigObj.oldmap.keyset().size()  > 0){
                for(Payment__c objPayment : (List<Payment__c>)trigObj.newlist){
                    string recordtypename = Schema.SObjectType.Payment__c.getRecordTypeInfosById().get(objPayment.RecordTypeId).getname();
                    system.debug('recordtypename====='+recordtypename);
                    if(objPayment.BillingContract__c != null && (recordtypename == FcUt_Constants.RETURNTRANSFER || recordtypename == FcUt_Constants.PAYMENT)){	//AT-2873 (Core 7a)
                        Payment__c objOldPayment = (Payment__c)trigObj.oldmap.get(objPayment.Id);
                        //handling null value for CreditAmount field
                        Decimal CreditAmount = objPayment.CreditAmount__c != null ? objPayment.CreditAmount__c : 0;
                        Decimal oldCreditAmount = objOldPayment.CreditAmount__c != null ? objOldPayment.CreditAmount__c : 0;
                        if(CreditAmount != oldCreditAmount){
                            FinancialControl__c objFinancialControl = new FinancialControl__c(); 
                            objFinancialControl.Payment__c = objPayment.Id; 
                            if(mapFTETIdByName.containsKey(recordtypename)){
                                objFinancialControl.FinancialTransactionEventType__c = mapFTETIdByName.get(recordtypename);
                            }
                            if(objOldPayment.CreditAmount__c != null){
                                objFinancialControl.Amount__c = CreditAmount - objOldPayment.CreditAmount__c; 
                            }else{
                                objFinancialControl.Amount__c = CreditAmount; 
                            }
                            
                            //AT-2763, AT-2769
                            /*if(recordtypename == FcUt_Constants.RETURNTRANSFER)
								objFinancialControl.Amount__c = objFinancialControl.Amount__c * -1;*/
                            
                            if(objPeriod != null){
                                objFinancialControl.ActualPeriod__c = String.valueOf(objPeriod.Number);
                                objFinancialControl.ActualPeriodId__c = objPeriod.Id;
                                objFinancialControl.ActualYear__c = objPeriod.FiscalYearSettings.Name; 
                                objFinancialControl.EffectivePeriod__c = String.valueOf(objPeriod.Number);
                                objFinancialControl.EffectivePeriodId__c = objPeriod.Id;
                                objFinancialControl.EffectiveYear__c = objPeriod.FiscalYearSettings.Name; 
                            }
                            lstFinancialControl.add(objFinancialControl);                            
                        }
                    }
                } 
            }else{
                for(Payment__c objPayment : (List<Payment__c>)trigObj.newlist){
                    string recordtypename = Schema.SObjectType.Payment__c.getRecordTypeInfosById().get(objPayment.RecordTypeId).getname();
                    system.debug('recordtypename====='+recordtypename);
                    if((objPayment.BillingContract__c != null && recordtypename == FcUt_Constants.REFUND) || recordtypename == FcUt_Constants.GOODWILL){  //AT-2873 (Core 7a) // AT-2673 /*recordtypename == FcUt_Constants.RETURNTRANSFER || */
                           FinancialControl__c objFinancialControl = new FinancialControl__c(); 
                           objFinancialControl.Payment__c = objPayment.Id;
                           if(!lstFinancialTranEventType.isEmpty())
                               objFinancialControl.FinancialTransactionEventType__c = mapFTETIdByName.get(recordtypename);   
                           objFinancialControl.Amount__c = objPayment.Amount__c; 
                           objFinancialControl.ActualPeriod__c = String.valueOf(objPeriod.Number);
                           objFinancialControl.ActualPeriodId__c = objPeriod.Id;
                           objFinancialControl.ActualYear__c = objPeriod.FiscalYearSettings.Name; 
                           objFinancialControl.EffectivePeriod__c = String.valueOf(objPeriod.Number);
                           objFinancialControl.EffectivePeriodId__c = objPeriod.Id;
                           objFinancialControl.EffectiveYear__c = objPeriod.FiscalYearSettings.Name; 
                           
                           //AT-2763, AT-2769
                           /*if(recordtypename == FcUt_Constants.RETURNTRANSFER)
								objFinancialControl.Amount__c = objFinancialControl.Amount__c * -1;*/
                           
                           lstFinancialControl.add(objFinancialControl);
                       }
                }
            }
            system.debug('lstFinancialControl====='+lstFinancialControl);
            // Checking if list is not empty then inserting.  
            if(!lstFinancialControl.isEmpty()){
                lstFinancialControl = (List<FinancialControl__c>) GlUt_FieldSecurity.cleanseFields(lstFinancialControl, false); //AT-4891 Code Check Marx Changes Starts/Ends Here.
                insert lstFinancialControl;
            }    
        }
    }
    /**********************************************************************************************
	@author         Echo: Dependra Singh
	@date           19-March-2018
	@param          GlUt_TriggerHandlerObj inputParam
	@return         void
	@description    (1)-Query all of the associated bill items into a map of payment allocation id to bill item. Use this to retrieve info 
	from the bill item as specified in the mappings table   
	(2)-Query the ‘Financial Transaction Event Type’ object where the ‘Name’ is equal to ‘Payment’ and the object = ‘Payment Allocation’ 
	(3)-Use mapping tables in the data mapping section of this document, Create a Financial Controls Record Based on the mappings. Link the Financial controls  record to the payment allocation
	**********************************************************************************************/ 
    public static void ProcessPaymentAllocation(GlUt_TriggerHandlerObj trigObj){
        system.debug('trigObj======'+ trigObj);
        // Map of <Id, Id> Bill Item Id by payment Allocation id.
        Map<Id, Id> mapBillItemIdByPymtAllocId = new Map<Id, Id>();
        // Set of Bill Item Ids
        set<Id> setBillItemIds = new set<Id>();
        // Set of payment ids
        Set<string> paymentIdSet =  new Set<string>();
        //List of Bill Item Date.
        List<Date> lstBillItemEndDt = new List<Date>(); 
        // List of Financial Control Records
        List<FinancialControl__c> lstFinancialControl= new List<FinancialControl__c>();
        // Checking if trigger.new is not empty then looping over trigger new list to store vlues in variables.
        
        if(!trigObj.newlist.isEmpty()){ 
            for(PaymentAllocation__c objPaymentAllocation : (List<PaymentAllocation__c>)trigObj.newlist){
                if(!mapBillItemIdByPymtAllocId.containsKey(objPaymentAllocation.id)){
                    if(objPaymentAllocation.BillItem__c != null){
                        mapBillItemIdByPymtAllocId.put(objPaymentAllocation.Id, objPaymentAllocation.BillItem__c);              
                    }     
                }                
                paymentIdSet.add(objPaymentAllocation.Payment__c);
            }
            if(mapBillItemIdByPymtAllocId.values().size() > 0){
                setBillItemIds.addAll(mapBillItemIdByPymtAllocId.values());
            }
            // Map of Bill Item By id
            Map<Id,BillItem__c> mapBillItemById = new Map<Id, BillItem__c>([SELECT Id, Name,BilledAmount__c, 
                                                                            TotalTaxAmount__c, EndDate__c, 
                                                                            ServiceItem__r.ServiceItemType__c,
                                                                            ServiceItem__r.Service__r.BillingContract__r.BillingFrequency__c,
                                                                            TotalDiscountAmount__c                                                                  
                                                                            FROM BillItem__c 
                                                                            WHERE Id IN : setBillItemIds]);
            //get Effective period
            if(mapBillItemById.keySet().size() >0){
                for(Id objId :mapBillItemById.keySet()){
                    lstBillItemEndDt.add(mapBillItemById.get(objId).EndDate__c);            
                }
            }
            Map<Date,Period> billItemEndDtToPeriodMap = new Map<Date,Period>();
            if(!lstBillItemEndDt.isEmpty()){
                billItemEndDtToPeriodMap = getPeriodForDate(lstBillItemEndDt); 
            }
            //get Actual period            
            Payment__c objPayment = [SELECT Id,CreatedDate
                                     FROM Payment__c 
                                     WHERE Id IN:paymentIdSet
                                     LIMIT 1];      
            Date PaymentCreatedDate = date.newinstance(objPayment.CreatedDate.year(), objPayment.CreatedDate.month(), objPayment.CreatedDate.day());        
            Period objActualPeriod = [SELECT Id,FiscalYearSettings.Name,Number 
                                      FROM Period 
                                      WHERE Type = :FcUt_Constants.MONTH 
                                      AND StartDate <=: PaymentCreatedDate 
                                      AND EndDate >=: PaymentCreatedDate];         
            // Querying list of financial transaction event type where object is payment allocation 
            List<FinancialTransactionEventType__c> lstFinancialTranEventType = [SELECT Id, Name, Name__c, Object__c,Category__c 
                                                                                FROM FinancialTransactionEventType__c 
                                                                                WHERE Name__c = :FcUt_Constants.PAYMENT
                                                                                AND Object__c = :FcUt_Constants.PAYALLOC
                                                                                LIMIT 1]; 
            
          //  Map<Id,FinancialControl__c> paTaxDiscountRecords = new Map<Id,FinancialControl__c>(); // AT-4162 
            
            //create Financial Controls Records
            for(PaymentAllocation__c objPaymentAllocation : (List<PaymentAllocation__c>)trigObj.newlist){
                system.debug('3******bjPaymentAllocation.BillItem__c ' + objPaymentAllocation.BillItem__c);
                system.debug('4******objPaymentAllocation.Id ' + objPaymentAllocation.Id);
                if(objPaymentAllocation.BillItem__c != null){
                    system.debug('5********');
                    FinancialControl__c objFinancialControl = new FinancialControl__c(); 
                    objFinancialControl.PaymentAllocation__c = objPaymentAllocation.Id;
                    if(!lstFinancialTranEventType.isEmpty())
                        objFinancialControl.FinancialTransactionEventType__c = lstFinancialTranEventType[0].Id;
                    if(mapBillItemIdByPymtAllocId.containsKey(objPaymentAllocation.Id)){
                        objFinancialControl.ServiceItemType__c = mapBillItemById.get(mapBillItemIdByPymtAllocId.get(objPaymentAllocation.Id)).ServiceItem__r.ServiceItemType__c;
                        if(mapBillItemById.containsKey(mapBillItemIdByPymtAllocId.get(objPaymentAllocation.Id))){
                            if(mapBillItemById.get(mapBillItemIdByPymtAllocId.get(objPaymentAllocation.Id)).ServiceItem__r.Service__r.BillingContract__r.BillingFrequency__c!=null)
                                objFinancialControl.BillingFrequency__c = mapBillItemById.get(mapBillItemIdByPymtAllocId.get(objPaymentAllocation.Id)).ServiceItem__r.Service__r.BillingContract__r.BillingFrequency__c;
                            if(mapBillItemById.get(mapBillItemIdByPymtAllocId.get(objPaymentAllocation.Id)).TotalDiscountAmount__c!= null)
                                objFinancialControl.DiscountAmount__c = (objPaymentAllocation.AmountAllocated__c / mapBillItemById.get(mapBillItemIdByPymtAllocId.get(objPaymentAllocation.Id)).BilledAmount__c) * mapBillItemById.get(mapBillItemIdByPymtAllocId.get(objPaymentAllocation.Id)).TotalDiscountAmount__c;                                                  
                            if(mapBillItemById.get(mapBillItemIdByPymtAllocId.get(objPaymentAllocation.Id)).TotalTaxAmount__c!= null)	
                                objFinancialControl.TaxAmount__c = (objPaymentAllocation.AmountAllocated__c / mapBillItemById.get(mapBillItemIdByPymtAllocId.get(objPaymentAllocation.Id)).BilledAmount__c) * mapBillItemById.get(mapBillItemIdByPymtAllocId.get(objPaymentAllocation.Id)).TotalTaxAmount__c;                                
                            if(billItemEndDtToPeriodMap.containsKey(mapBillItemById.get(mapBillItemIdByPymtAllocId.get(objPaymentAllocation.Id)).EndDate__c)){
                                objFinancialControl.EffectivePeriod__c = String.valueOf(billItemEndDtToPeriodMap.get(mapBillItemById.get(mapBillItemIdByPymtAllocId.get(objPaymentAllocation.Id)).EndDate__c).Number);
                                objFinancialControl.EffectivePeriodId__c = billItemEndDtToPeriodMap.get(mapBillItemById.get(mapBillItemIdByPymtAllocId.get(objPaymentAllocation.Id)).EndDate__c).Id;
                                objFinancialControl.EffectiveYear__c = billItemEndDtToPeriodMap.get(mapBillItemById.get(mapBillItemIdByPymtAllocId.get(objPaymentAllocation.Id)).EndDate__c).FiscalYearSettings.Name;
                            }
                            
                           /* if(objFinancialControl.DiscountAmount__c != null || objFinancialControl.TaxAmount__c != null)  // AT-4162 
                            	paTaxDiscountRecords.put(objPaymentAllocation.Id, objFinancialControl);*/
                        }
                    }
                    system.debug('2******Neha *****objPaymentAllocation.Status__c ' + objPaymentAllocation.Status__c);
                    If(objPaymentAllocation.Status__c == GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_REVERSED)   // AT-2673
                        objFinancialControl.Amount__c = -(objPaymentAllocation.AmountAllocated__c);
                    else
                    	objFinancialControl.Amount__c = objPaymentAllocation.AmountAllocated__c;  
                    system.debug('3/******objFinancialControl.Amount__c ' + objFinancialControl.Amount__c);
                    if(objActualPeriod != null)	{
                        objFinancialControl.ActualPeriod__c = String.valueOf(objActualPeriod.Number);
                        objFinancialControl.ActualPeriodId__c = objActualPeriod.Id;
                        objFinancialControl.ActualYear__c = objActualPeriod.FiscalYearSettings.Name; 
                    }	
                    system.debug('4-***************objFinancialControl  ' + objFinancialControl);
                    lstFinancialControl.add(objFinancialControl); 
                }
            }
            // Checking if list is not empty then inserting. 
            system.debug('lstFinancialControl ' + lstFinancialControl); 
            if(!lstFinancialControl.isEmpty()){
                lstFinancialControl = (List<FinancialControl__c>) GlUt_FieldSecurity.cleanseFields(lstFinancialControl, false); //AT-4891 Code Check Marx Changes Starts/Ends Here.
                insert lstFinancialControl;
                // AT-4162 start
              /*  if(paTaxDiscountRecords.size() > 0){
                    List<PaymentAllocation__c> paymentAllocationList = new List<PaymentAllocation__c>();
                    for(PaymentAllocation__c objPaymentAllocation: [SELECT Id, TaxAmount__c, DiscountAmount__c  
                                                                    FROM PaymentAllocation__c 
                                                                    WHERE Id IN: paTaxDiscountRecords.keySet()]){
                    	objPaymentAllocation.TaxAmount__c = paTaxDiscountRecords.get(objPaymentAllocation.Id).TaxAmount__c;
                        objPaymentAllocation.DiscountAmount__c = paTaxDiscountRecords.get(objPaymentAllocation.Id).DiscountAmount__c;                                                
                        paymentAllocationList.add(objPaymentAllocation);                                           
                    }
                    if(paymentAllocationList.size() > 0)
                        database.update(paymentAllocationList);                                        
                }*/
                // AT-4162 end
                
            }
            system.debug('lstFinancialControl=============='+lstFinancialControl);
        }
    }
    /**********************************************************************************************
	@author         Echo: Swati Mathur
	@date           23-Mar-2018
	@param          List<Date>
	@return         Map<Date,Period>
	@description    To get the exact Period for the Date 
	@Revisions	    Modified to fix test class issues of SOQL limits 
	**********************************************************************************************/
    public static Map<Date,Period> getPeriodForDate(List<Date> lstBillItemDate){
        Map<Date,Period> billItemDateToPeriodMap = new Map<Date,Period>();
        lstBillItemDate.sort();
        List<Period> listPeriod = new List<Period>();
        
        if(!lstBillItemDate.isEmpty()){
            listPeriod = [SELECT Id,FiscalYearSettings.Name,Number,StartDate,EndDate 
                          FROM Period  WHERE Type =: FcUt_Constants.MONTH
                          AND StartDate >=: lstBillItemDate.get(0).addMonths(-1) 
                          AND StartDate <=: lstBillItemDate.get(lstBillItemDate.size()- 1).addMonths(1)];
        }
        for(Date objDate :lstBillItemDate){                
            for(Period objEffPeriod :listPeriod){                
                if(objEffPeriod.StartDate<= objDate && objEffPeriod.EndDate >= objDate){                        
                    if(!billItemDateToPeriodMap.containsKey(objDate)){
                        billItemDateToPeriodMap.put(objDate,objEffPeriod);
                        break;
                    }
                }
            }                
        }
        system.debug('billItemDateToPeriodMap==GET PERIOD===='+ billItemDateToPeriodMap);
        return billItemDateToPeriodMap;
    }  
	/**********************************************************************************************
	@author         Echo: Dependra Singh
	@date           01-March-2019
	@params			
	@return         List<FinancialTransactionEventType__c>
	@description    This method is used to get the financial control record from data base 
	**********************************************************************************************/
	 private static List<FinancialTransactionEventType__c> getFCEventType(set<string> setOfReasons , string objectName){
		 return [SELECT Id, Name, Name__c, Object__c,Category__c FROM FinancialTransactionEventType__c 
																 WHERE Name__c IN : setOfReasons 
																 AND Object__c =:objectName LIMIT 1];
	 }
}