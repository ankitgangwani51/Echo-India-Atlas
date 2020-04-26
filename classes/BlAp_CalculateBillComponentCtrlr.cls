/******************************************************************************
@author    		Accenture: Patrick Dixon
@date      		06 Sep 2017
@description 	Component controller for calculate bill lightning component
				This class runs without object and field permission checks since: 
				(a) Its primary functions are to initiate a bill calculation and 
				to synchronise bill data between Heroku and Salesforce, 
				and this requires access to all records/fields
				(b) It does not expose record data to the user (status only)
Revision(s)		06 Nov 2017, P Dixon - MP2 changed bill calculation relationship
				02 Feb 2018, P Dixon - Moved billing interface code to utility class to allow reuse
				08 Mar 2018, P Dixon - added new bill calculation fields
				09 Apr 2018, P Dixon - revised to combine billable and pending bill components
				27 Sep 2018, Tarun - revised to use list of contract Id
                21 Dec 2018, Amit K. - Rural Billing Changes.
*******************************************************************************/
public with sharing class BlAp_CalculateBillComponentCtrlr {
    private static final String CLASS_NAME = 'BlAp_CalculateBillComponentCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

	// map of bill calculation reason picklist value keyed on object api name
    private static final Map<String, String> reasonMap = new Map<String, String> {
											GlUt_APIConstantsContracts.CONTRACTAPINAME => Label.BlIn_BillCalculationReasonAgent, 
											GlUt_APIConstantsReading.READINGAPINAME => Label.BlIn_BillCalculationReasonReading, 
											GlUt_APIConstantsChargeBasis.OBJECTAPINAME => Label.BlIn_BillCalculationReasonChargeBasis, 
											GlUt_APIConstantsAgreedRate.AGREEDRATEAPINAME => Label.BlIn_BillCalculationReasonAgreedRate, 
											GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME => Label.BlIn_BillCalculationReasonServiceItem, 
											GlUt_APIConstantsDiscounts.DISCOUNTAPINAME => Label.BlIn_BillCalculationReasonDiscount, 
											GlUt_APIConstantsManualAmendment.OBJECTAPINAME => Label.BlIn_BillCalculationReasonManualAmendment, 
											GlUt_APIConstantsTaxClassification.OBJECTAPINAME => Label.BlIn_BillCalculationReasonTax, 
											GlUt_APIConstantsAgreedVolume.OBJECTAPINAME => Label.BlIn_BillCalculationReasonAgreedVolume, 
											GlUt_APIConstantsAgreedSampleStrength.OBJECTAPINAME => Label.BlIn_BillCalculationReasonAgreedSampleStrength,
                                            GlUt_APIConstantsSIAgreedVolume.SIAGREEDVOLUMEAPINAME => Label.BlIn_BillCalculationReasonSIAgreedVolume,
                                            GlUt_APIConstantsSupplyPointAllowance.SUPPLYPOINTALLOWANCEAPINAME => Label.BlIn_BillCalculationReasonSupplyPointAllowance,
											GlUt_APIConstantsSupplyPointBand.SUPPLYPOINTBANDAPINAME => Label.BlIn_BillCalculationReasonServiceItem ,
                                            GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME => Label.BlIn_BillCalculationReasonServiceItem,   //AT - 3074
                                            GlUt_APIConstantsSample.SAMPLEAPINAME => Label.BlIn_BillCalculationReasonSampleReason,//AT-3457- Dependra Singh
                                            GlUt_APIConstantsRuralGrossConsumption.RURALGROSSCONSUMPTIONAPINAME => Label.BlIn_BillCalculationReasonRuralGrossConsumption //AT-4513
											};
                                                
    // map of bill calculation reason picklist value keyed on object api name  //AT-3322
    private static final Map<String, String> deletionReasonMap = new Map<String, String> {
											GlUt_APIConstantsContracts.CONTRACTAPINAME => Label.BlIn_BillCalculationReasonAgent, 
											GlUt_APIConstantsChargeBasis.OBJECTAPINAME => Label.BlIn_BillCalculationReasonChargeBasisInvalid, 
											GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME => Label.BlIn_BillCalculationReasonServiceItemInvalid, 
											GlUt_APIConstantsDiscounts.DISCOUNTAPINAME => Label.BlIn_BillCalculationReasonDiscountInvalid, 
											GlUt_APIConstantsTaxClassification.OBJECTAPINAME => Label.BlIn_BillCalculationReasonTaxClassificationInvalid, 
											GlUt_APIConstantsAgreedVolume.OBJECTAPINAME => Label.BlIn_BillCalculationReasonAgreedVolumeInvalid, 
											GlUt_APIConstantsAgreedSampleStrength.OBJECTAPINAME => Label.BlIn_BillCalculationReasonAgreedSampleStrengthInvalid,
                                            GlUt_APIConstantsSIAgreedVolume.SIAGREEDVOLUMEAPINAME => Label.BlIn_BillCalculationReasonSIAgreedVolumeInvalid,
                                            GlUt_APIConstantsSupplyPointAllowance.SUPPLYPOINTALLOWANCEAPINAME => Label.BlIn_BillCalculationReasonSPAllowanceInvalid
											};                                            
									
	// map of bill calculation lookup field api name keyed on object api name
    private static final Map<String, String> lookupFieldMap = new Map<String, String> {
											GlUt_APIConstantsContracts.CONTRACTAPINAME => GlUt_APIConstantsBillCalculation.CONTRACT, 
											GlUt_APIConstantsReading.READINGAPINAME => GlUt_APIConstantsBillCalculation.READING, 
											GlUt_APIConstantsChargeBasis.OBJECTAPINAME => GlUt_APIConstantsBillCalculation.CHARGEBASIS, 
											GlUt_APIConstantsAgreedRate.AGREEDRATEAPINAME => GlUt_APIConstantsBillCalculation.AGREEDRATE, 
											GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME => GlUt_APIConstantsBillCalculation.SERVICEITEM, 
											GlUt_APIConstantsDiscounts.DISCOUNTAPINAME => GlUt_APIConstantsBillCalculation.DISCOUNT, 
											GlUt_APIConstantsManualAmendment.OBJECTAPINAME => GlUt_APIConstantsBillCalculation.MANUALAMENDMENT, 
											GlUt_APIConstantsTaxClassification.OBJECTAPINAME => GlUt_APIConstantsBillCalculation.TAXCLASSIFICATION, 
											GlUt_APIConstantsAgreedVolume.OBJECTAPINAME => GlUt_APIConstantsBillCalculation.AGREEDVOLUME, 
											GlUt_APIConstantsAgreedSampleStrength.OBJECTAPINAME => GlUt_APIConstantsBillCalculation.AGREEDSAMPLESTRENGTH,
                                            GlUt_APIConstantsSIAgreedVolume.SIAGREEDVOLUMEAPINAME => GlUt_APIConstantsBillCalculation.SIAGREEDVOLUME,
                                            GlUt_APIConstantsSupplyPointAllowance.SUPPLYPOINTALLOWANCEAPINAME => GlUt_APIConstantsBillCalculation.SUPPLYPOINTALLOWANCE,
                                            GlUt_APIConstantsSupplyPointBand.SUPPLYPOINTBANDAPINAME => GlUt_APIConstantsBillCalculation.SUPPLYPOINTBAND,
                                            GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME => GlUt_APIConstantsBillCalculation.AVAILABLEBUNDLE,   //AT - 3074  
                                            GlUt_APIConstantsSample.SAMPLEAPINAME => GlUt_APIConstantsBillCalculation.SAMPLE,     //AT-3457- Dependra Singh
                                            GlUt_APIConstantsRuralGrossConsumption.RURALGROSSCONSUMPTIONAPINAME => GlUt_APIConstantsBillCalculation.RURALGROSSCONSUMPTION //AT-4513
											};
									
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		08 Mar 2018
	@param			String - the api name of the object that has been amended
	@param			Id - the new record Id
	@return			Set<Id> - the affected contract Ids
	@description 	Implements the contract finder service for the object type 
					to get the list of contract Ids affected by an amendment
					
					The following amendment types can affect multiple contracts:
						Reading
						ChargeBasis
						TaxClassification
						Agreed Volume
						Agreed Sample Strength
	*******************************************************************************/
	private static Set<Id> retrieveContractIds(String objectName, String recordId) {
        String objName = objectName.replace(GlUt_NamespacePrefix.getNamespacePrefix(), '');
		String serviceName = GlUt_Constants.PREFIX + objName.replace('__c','') + GlUt_Constants.CONTRACT_FINDER;
        GlUt_ContractFinder contractFinder = (GlUt_ContractFinder) Type.forName(GlUt_NamespacePrefix.getNamespacePrefix().replace('__',''),serviceName).newInstance();
        return contractFinder.retrieveContractIds(recordId);
	}
    
    /******************************************************************************
	@author    		Echo: Swati Mathur
	@date      		21 Aug 2018
	@param			String - the object api name
	@param			String - the field api name
	@return			boolean - True if field exist else false
	@description 	Check if the field exist on object or not , Added in AT-3322
	*******************************************************************************/
    public static boolean doesFieldExist(String objName, string fieldName)
    {
        try {
            SObject so = Schema.getGlobalDescribe().get(objName).newSObject();
            return so.getSobjectType().getDescribe().fields.getMap().containsKey(fieldName);
        }
        catch(Exception ex) {}
        return false;
    }
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		08 Mar 2018
	@param			String - the api name of the object
	@param			String - the type of bill calculation (eg Pending/Billable)
	@param			Id - the Id of the record that triggered the calculation
	@return			Id - the contract Id (if Agent initiated) or the new record Id
	@return			List<BillCalculation__c> - bill calculation record Ids one per affected contract
	@description 	Initiates a new pending bill request by creating a new list of bill calculation records
	@Revision 		27 Sep 2018, Tarun - revised to use list of contract Id
	*******************************************************************************/
	@AuraEnabled
	public static List<BillCalculation__c> initiateBillsRequest(String billCalculationType, String objectName, Id recordId, List<Id> listContractIds) {
        
		List<BillCalculation__c> billCalculations = new List<BillCalculation__c>();
		Set<Id> setContractIds = new Set<Id>();
		try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
			// initiate a new billing calculation request for each contract affected
            system.debug('101****billCalculationType=>' + billCalculationType + '=>objectName=>' + objectName + '=>recordId=>' + recordId + '=> listContractIds => ' + listContractIds);
			String reason = reasonMap.get(objectName);
            
            //AT-3322 - start
            if(doesFieldExist(objectName,BlAp_Constants.INVALIDAPINAME)){                
                //sObject obj =  Database.query('SELECT ' + BlAp_Constants.INVALIDAPINAME + ' FROM ' + objectName + ' WHERE Id =' + '\'' + recordId + '\' Limit 1');
                sObject obj = (sObject) GlAp_LightningDataAccess.getRecord(objectName, recordId, new List<String>{BlAp_Constants.INVALIDAPINAME});
                
                if(obj.get(BlAp_Constants.INVALIDAPINAME) == true){
                    reason = deletionReasonMap.get(objectName);

                }                
            }           
            //AT-3322 - end
			 String lookupField = lookupFieldMap.get(objectName);
            if(recordId != null){
                setContractIds = retrieveContractIds(objectName, recordId);
            }
            else if(listContractIds != null && !listContractIds.isEmpty()){
                setContractIds.addAll(listContractIds);
            }
        /* AT-4375 Changes as per Clayton Code Review Starts here*/
        if(!setContractIds.isEmpty()) {
                BillCalculation__c billCalculation;
                Set<Id> existingBillCalContractIds = new  Set<Id>();
                //Security Review
                String filterStatement = ' WHERE ' + GlUt_APIConstantsBillCalculation.TYPE + ' = \'' + billCalculationType + '\'';
                filterStatement = filterStatement + ' AND ' + GlUt_APIConstantsBillCalculation.CONTRACT + ' IN '  + GlUt_FieldSecurity.IdsToString(setContractIds); 
                filterStatement = filterStatement + ' AND ' + GlUt_APIConstantsBillCalculation.STATUSAPINAME + ' != ' + '\''+GlUt_Constants.COMPLETED+ '\''; 
                
                system.debug('114.......... filterStatement ' + filterStatement);
                system.debug('115..........setContractIds ' + setContractIds);
                List<BillCalculation__c> billCalculationList = (List<BillCalculation__c>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBillCalculation.BILLCALCULATIONAPINAME, 
                                                                                                                             new List<String>{GlUt_APIConstantsBillCalculation.STATUSAPINAME,
                                                                                                                                 GlUt_APIConstantsBillCalculation.CONTRACT}, 
                                                                                                                             filterStatement);
            system.debug('116.....billCalculationList ' + billCalculationList);
           
                for (BillCalculation__c existingBillCalculation : billCalculationList) {
                 /*
                 for (BillCalculation__c existingBillCalculation : [select Id, 
                                                                    Status__c,
                                                                    BillingContract__c
                                                                    from BillCalculation__c
                                                                    where Type__c = :billCalculationType
                                                                    and BillingContract__c In: setContractIds and Status__c !=: GlUt_Constants.COMPLETED]) {
                
               	*/	
                    // use the existing pending bill calc if present			
                    if (existingBillCalculation.Status__c == Label.BlIn_BillCalculationStatusPending) {
                        billCalculation = existingBillCalculation;
                        
                        // or the existing new pending bill calc if not
                    } else if (existingBillCalculation.Status__c == Label.BlIn_BillCalculationStatusNew) {
                        billCalculation = existingBillCalculation;
                    }
                    existingBillCalContractIds.add(existingBillCalculation.BillingContract__c);
                    system.debug('117A.....billCalculation ' + billCalculation);
                    billCalculations.add(billCalculation);
                }
           		 system.debug('117....billCalculations ' + billCalculations);
                for(Id contractId : setContractIds) {
                    if(!existingBillCalContractIds.contains(contractId)){
                        // or create a new bill calculation record
                        billCalculation = new BillCalculation__c(
                            BillingContract__c = contractId, 
                            Type__c = billCalculationType, 
                            Reason__c = reason,
                            Status__c = Label.BlIn_BillCalculationStatusNew, 
                            RequestDate__c = Date.today()
                        );
                        if(recordId != null){
                            billCalculation.put(lookupField, recordId);  		// link it to the new record
                        }
                        else if(listContractIds != null){
                            billCalculation.put(lookupField, contractId);
                        }
                        // add the bill calculation to the list
                        billCalculations.add(billCalculation);
                    }
                }
            system.debug('118.....billCalculations ' + billCalculations);
             
            }
           /* AT-4375 Changes as per Clayton Code Review Ends here*/
			
		} catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        
		// No overall try/catch because we want the error message returned to component
		if (!billCalculations.isEmpty()) {
			system.debug('119.....billCalculations ' + billCalculations);
	        try {
                List<sObject> billCalcSObjectList = GlUt_FieldSecurity.cleanseFields(billCalculations, false) ;
                billCalculations.clear();
                for(sObject sObj : billCalcSObjectList){
                	billCalculations.add((BillCalculation__c) sObj);  
                }
                 system.debug('120....billCalculations ' + billCalculations);
	        	upsert billCalculations;
	        	
			} catch (exception e) {
                GlUt_Logger.logException(e);
				throw new AuraHandledException(e.getMessage());
            } finally {   
                GlUt_Logger.writeLogsToDatabase();
            }
		}
		return billCalculations;
	}
    /******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		09 Mar 2018
	@param			BillCalculation__c - JSON string containing the bill calculation records
	@return			List<BillCalculation__c> - the updated bill calculation requests
	@description 	Method called to request bill calculations
	*******************************************************************************/
    @AuraEnabled
    public static List<BillCalculation__c> requestBills(String billCalculationsJSON) {
        
		// No try/catch here because we want error messages returned to component
    	List<BillCalculation__c> billCalculations = (List<BillCalculation__c>) System.JSON.deserialize(billCalculationsJSON, List<BillCalculation__c>.class);
        system.debug('Sudhir-requestBills-billCalculations=> ' + billCalculations);
        for (BillCalculation__c billCalculation : billCalculations) {
            	
        	if (billCalculation.Status__c == Label.BlIn_BillCalculationStatusNew) {
	            // make bill calculation request callout
        		BlIn_ExecuteBillCalculation.requestBillCalculation(billCalculation.Id);
	            // update the bill calculation status
	            billCalculation.Status__c = Label.BlIn_BillCalculationStatusPending;
        	}
        }
        
        try {
        	update billCalculations;
        	
		} catch (exception e) {
            GlUt_Logger.logException(e);
			throw new AuraHandledException(e.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return billCalculations;
    }
    
   /******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		09 Mar 2018
	@param			BillCalculation__c - the bill calculation record
	@return			BlIn_ExecuteBillCalculation.BillResults - map of bill Ids (null if bill result not ready) keyed on bill calculation Id + error message
					Note: there will only be one map element per callout/bill calculation
	@description 	Method called to fetch a bill calculation result
					No try/catch here because we want error messages returned to component
	Revision(s)		12 Apr 2018, P Dixon - revised to return wrapper as throwing exceptions rolls back
					updates to BillCalculation__c status
	*******************************************************************************/
    @AuraEnabled
    public static BlIn_ExecuteBillCalculation.BillResults getBill(BillCalculation__c billCalculation) {
            
        try {
            // callout to get the result
            BlIn_ExecuteBillCalculation.BillResults results = BlIn_ExecuteBillCalculation.getBillCalculationResult(billCalculation.Id);
            // check for bill calculation still pending
            if (results.error == null 
                && (results.billIdsMap.get(billCalculation.Id) == null 
                    || results.billIdsMap.get(billCalculation.Id).isEmpty())) { 
                        // no results yet
                        return null;
                    }
            return results;
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }

}