/******************************************************************************
@author         Accenture: Patrick Dixon
@date           01 Sep 2017
@description    Class for billing callout
Revision(s)		19 Mar 2018, P Dixon - updated to check for Heroku Connect bill 
				creation before making a response callout
*******************************************************************************/
public with sharing class BlIn_ExecuteBillCalculation {

    private static final String CLASS_NAME = 'BlIn_ExecuteBillCalculation';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           18 Sep 2017
    @param          Id - bill calculation Id
    @return         Boolean - success
    @description    HEROKU REST callout to request a bill calculation
    *******************************************************************************/
    public static Boolean requestBillCalculation(Id billCalculationId) {
        System.debug(DEBUG + 'Sudhir-MAKING REQUEST BILL CALLOUT-billCalculationId=> ' + billCalculationId);
        System.debug(DEBUG + 'MAKING REQUEST BILL CALLOUT');
        
        try {
            
			// format the payload using the billing data DTO
			system.debug('before BlIn_BillCalcExtractData');
			BlIn_BillCalcExtractData billCalc = new BlIn_BillCalcExtractData(billCalculationId);
	        String payload = billCalc.retrieveData();      // JSON billing data

            System.debug('payload for move-out = '+payload);
	        // make the callout
	        HttpResponse response = BlUt_HerokuWebservices.makeCallout(BlUt_HerokuWebservices.BILL_CALCULATION, 2000, 'application/json', payload);
            System.debug('response = '+response.getBody());
	        // handle response
	        if (response.getStatusCode() == 200) {
	            System.debug(DEBUG + 'Good response: ' + response.getStatusCode() + ' ' + response.getStatus());
	            
	        } else {
	            System.debug(DEBUG + 'Error response: ' + response.getStatusCode() + ' ' + response.getStatus());
                GlUt_Logger.getAuraHandledException(GlUt_Constants.EXCEPTIONMESSAGE + Label.BlAp_BillCalcRequestError + GlUt_Constants.EXCEPTIONREASON + response.getBody());
	        }	        
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
	
        return true;
    }

    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           12 Apr 2018
    @description    Wrapper class for bill results
    *******************************************************************************/
	public class BillResults {
		@AuraEnabled public Map<Id, List<Id>> billIdsMap;
		@AuraEnabled public String error;
		
		public BillResults(Map<Id, List<Id>> billIdsMap) {
			this.billIdsMap = billIdsMap;
			error = null;
		}
	}

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           01 Sep 2017
    @param          Id - bill calculation Id
    @return         BillResult - map of bill Ids (null if bill result not ready) keyed on bill calculation Id + error message
    @description    HEROKU REST callout to get the bill calculation result
					No overall try/catch here because we want error messages returned to component
	Revision(s)		12 Apr 2018, P Dixon - revised to return wrapper as throwing exceptions rolls back
					updates to BillCalculation__c status
    *******************************************************************************/
    public static BillResults getBillCalculationResult(Id billCalculationId) {
        System.debug(DEBUG +  'MAKING BILL RESULT CALLOUT: ' + billCalculationId);

	    List<Id> billIds = new List<Id>();		// list of the new bill Ids
		Map<Id, List<Id>> billIdsMap = new Map<Id, List<Id>>();		// map of the list of new bill Ids keyed on the bill calculation Id
		billIdsMap.put(billCalculationId, billIds);
		BillResults results = new BillResults(billIdsMap);

    	// retrieve the bill calculation record
    	for (BillCalculation__c billCalculation : [select Id, 
															Status__c, 
															(select Id from Bills__r) 
													from BillCalculation__c 
													where Id = :billCalculationId]) {
            System.debug(DEBUG +  'billCalculation status: ' + billCalculation.Status__c);

        	// check its status to see if Heroku Connect has already created the bill(s)
    		if (billCalculation.Status__c == Label.BlIn_BillCalculationStatusCompleted) {
    			
    			// bill calculation completed, so get the bill Ids
    			for (Bill__c bill : billCalculation.Bills__r) {
    				billIds.add(bill.Id);
    			}
				billIdsMap.put(billCalculationId, billIds);
				results.billIdsMap = billIdsMap;
        	
        		// no bill Ids
                if (billIds.isEmpty()) {
                	System.debug(DEBUG + 'CALCULATION COMPLETED BUT RETURNED NO BILL');
                	results.error = Label.BlAp_BillCalcResultNoBillResponse;
                }
	
		    // if not, make the callout
    		} else {
    			
    			try {
			        String endPoint = BlUt_HerokuWebservices.BILL_CALCULATION;
			        String urlParams = '/' + billCalculationId;
			        HttpResponse response = BlUt_HerokuWebservices.makeCallout(endPoint, urlParams, 2000);
			        
			        // handle response
			        if (response.getStatusCode() == 200 && response.getBody() != null) {
			            System.debug(DEBUG +  'SAVING BILL RESULT');
			            System.debug(DEBUG +  'response.getBody(): ' + response.getBody());
	
	                    // deserialise JSON into BlIn_BillCalcResponseContainer object
	                    BlIn_BillCalcResponseContainer billingResponse = BlIn_BillCalcResponseContainer.parse(response.getBody());     
	                    System.debug(DEBUG +  'billingResponse: ' + billingResponse);
	                    billCalculation.Status__c = billingResponse.Status;
	                    System.debug(DEBUG +  'Updated status: ' + billCalculation.Status__c);
	                    
			            // completed bill result
			            if (billCalculation.Status__c == Label.BlIn_BillCalculationStatusCompleted) {
	
			                // create bills and write them to the database
			                billIds = BlIn_BillCalcResponseContainer.processResult(billCalculationId, billingResponse);
							billIdsMap.put(billCalculationId, billIds);
							results.billIdsMap = billIdsMap;
		            		System.debug(DEBUG +  'billIds: ' + billIds);
			                
							// check that there was a bill
			                if (billIds == null) {
			                	System.debug(DEBUG + 'BILL RESULT REQUEST RETURNED NO BILL');
	                			results.error = Label.BlAp_BillCalcResultNoBillResponse;

			                } else if (billIds.isEmpty()) {
			                	System.debug(DEBUG + 'A DATABASE CONFLICT OCCURED SO WAIT FOR IT TO BE RESOLVED');
			                }
			
			            // calculation error
			            } else if (billCalculation.Status__c == Label.BlIn_BillCalculationStatusError) {
			                System.debug(DEBUG + 'BILL RESULT REQUEST RETURNED AN ERROR');
	                		results.error = Label.BlAp_BillCalcResultErrorResponse;
			            
			            // calculation still pending
			            } else if (billCalculation.Status__c == Label.BlIn_BillCalculationStatusPending) {
			                System.debug(DEBUG + 'BILL RESULT NOT READY');
	
						// invalid response
			            } else {
			                System.debug(DEBUG + 'INVALID RESPONSE');
			            	throw new AuraHandledException(Label.BlAp_BillCalcResultUnknownResponse);
			        	}
			            
			        // error response
			        } else {
			            System.debug(DEBUG + 'Error response: ' + response.getStatusCode() + ' ' + response.getStatus());
			            throw new AuraHandledException(Label.BlAp_BillCalcResultError + response.getStatus());
			        }
			        
    			} catch (exception ex) {
                    GlUt_Logger.logException(ex);
		            System.debug(DEBUG +  'exception caught: ' + ex.getMessage());
    				
    			} finally {
                    GlUt_Logger.writeLogsToDatabase();
                    System.debug(DEBUG +  'Updated status: ' + billCalculation.Status__c);
    			}
    		}
		}

        // return the bill results
		System.debug(DEBUG + 'results: ' + results);
        return results;
    }
}