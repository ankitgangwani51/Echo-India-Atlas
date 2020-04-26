/****************************************************************************************************************************
@author    		Echo: Sudhir Kumar
@date      		28-Mar-2018
@description 	AT-1817: Component Controller to find the related Contract and its related Bills and their related Bill PDFs.  
Revision(s)		03 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
@Revision	 	AT-3969, Tarun - Modified as per security review
*****************************************************************************************************************************/
public with sharing class CmAp_MyBillsCtlr {
    
    private static final String CLASS_NAME = 'CmAp_MyBillsCtlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

	private static FINAL List<String> contractFieldList = new List<String> {
		GlUt_APIConstantsContracts.CONTRACTSTARTDATEAPINAME,
		GlUt_APIConstantsContracts.CONTRACTENDDATEAPINAME, 
		GlUt_APIConstantsContracts.STATUSAPINAME,     
		GlUt_APIConstantsContracts.PAYMENTMETHODTYPEAPINAME
	};

	private static FINAL List<String> billFieldList = new List<String> {
		GlUt_APIConstantsBill.BILLDATEAPINAME,
		GlUt_APIConstantsBill.BILLEDAMOUNTAPINAME
	};

	private static FINAL List<String> payAllocationFields = new List<String> {
		GlUt_APIConstantsPaymentAllocation.NAMEAPINAME,
		GlUt_APIConstantsPaymentAllocation.AMOUNTALLOCATEDAPINAME,
		GlUt_APIConstantsPaymentAllocation.BILLITEMAPINAME
	}; 
     
	private static FINAL List<String>billItmFields = new List<String> {
        GlUt_APIConstantsBillItem.SERVICEITEMAPINAME,
        GlUt_APIConstantsBillItem.BILLEDAMOUNTAPINAME,
        GlUt_APIConstantsBillItem.BILLAPINAME
            
    };
    
	/**********************************************************************************************
	@author         Echo: Vivek Sethi
	@date           25-Jan-2018
	@return         List<GLAp_FieldProps>
	@description    This method returns the field properties for each of the fields that are to be displayed on the screen
	**********************************************************************************************/ 
	@AuraEnabled
	public static List<GLAp_FieldProps> retrieveBillPropDetails() {
		List<GLAp_FieldProps> billProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsBill.BILLAPINAME, billFieldList);
	    List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
		try {
            GlUt_Logger.logDebug(DEBUG);
            GLAp_FieldProps billPdfLink = new GLAp_FieldProps();
            billPdfLink.isFLSVisible = true;
            billPdfLink.isEncrypted = false;
            billPdfLink.isEditable = false;
            billPdfLink.isRequired = false;
            billPdfLink.fieldName = GlUt_APIConstantsBill.CONTENTDOCUMENTID;
            billPdfLink.fieldLabel = CmAp_Constants.CUSTOMURLLABEL;
            billPdfLink.fieldType = 'url';
            billPdfLink.buttonField = true;
            billPdfLink.transformField = true; //Indicates this is a Transfrom and NOT a DB field
            billPdfLink.parentObject = GlUt_APIConstantsBill.BILLAPINAME; //Attach to Bill for display
            
            // Create transform field for Payment Allocation - Amount Allocated
            GLAp_FieldProps amtPaidOffProp = new GLAp_FieldProps();
            amtPaidOffProp.isFLSVisible = true;
            amtPaidOffProp.isEncrypted = false;
            amtPaidOffProp.isEditable = false;
            amtPaidOffProp.isRequired = false;
            amtPaidOffProp.fieldName = GlUt_APIConstantsPaymentAllocation.AMOUNTALLOCATEDAPINAME;
            amtPaidOffProp.fieldLabel =  CmAp_Constants.AMTALLOCATEDLABEL;
            amtPaidOffProp.fieldType = 'text';
            amtPaidOffProp.transformField = true; //Indicates this is a Transfrom and NOT a DB field
            amtPaidOffProp.parentObject = GlUt_APIConstantsBill.BILLAPINAME; //Attach to Bill for display       
            
            
            for (GLAp_FieldProps fldProp : billProps) {
                if (fldProp.fieldName == GlUt_APIConstantsBill.BILLDATEAPINAME) {
                    fldProp.fieldLabel = PyAp_Constants.BILLDATELABEL;
                    fldPropList.add(fldProp); 
                }
                if (fldProp.fieldName == GlUt_APIConstantsBill.BILLEDAMOUNTAPINAME) {
                    fldProp.fieldLabel = PyAp_Constants.TOTALAMOUNT;
                    fldPropList.add(fldProp); 
                }
            }
            fldPropList.add(amtPaidOffProp); 
            fldPropList.add(billPdfLink); 
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return fldPropList;
    }
	
    /******************************************************************************
	@author      	Echo: Sudhir Kumar
	@date      		28-Mar-2018
	@param			none
	@return			List<BlAp_CombinedRecord> 
	@description	AT-1817: An instance of this class represents a Bill record 
	*******************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> getUserBills() {
        Account accountObj = CmAp_MyAccountCtrlr.getCurrentUserAccount();
        List<BlAp_CombinedRecord> billsList = new List<BlAp_CombinedRecord>();
        Map<Id, ContentDocumentLink> billId2DocumentIdMap;
        Map<Id, Id> billItemBillMap;
        List<BillingContract__c> contractList;
        List<Bill__c> billList;
        list<PaymentAllocation__c> payAllocationList;
        Map<Id, Decimal> billPaymentAllocationMap = new Map<Id, Decimal>();
        Map<Id, Id> billToBillItmMap = new Map<Id, Id>();
        set<Id> billIdsSet;
      
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
            if (accountObj != null) {
                contractList = (List<BillingContract__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsContracts.CONTRACTAPINAME, 
                                                                                       contractFieldList, 
				                														accountObj.Id, 
				                														GlUt_APIConstantsContracts.CUSTOMERAPINAME, 
				                														null, 
				                														'ORDER BY CreatedDate Desc LIMIT 1');
            } 
            
            if (contractList != null && !contractList.isEmpty()) {
                billList = (List<Bill__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBill.BILLAPINAME, 
                																billFieldList, 
		                														contractList[0].Id, 
		                														GlUt_APIConstantsBill.CONTRACTNUMBERAPINAME , 
		                														null, 
		                														'ORDER BY ' + GlUt_APIConstantsBill.BILLDATEAPINAME + ' Desc');
                
                
                if (!billList.isEmpty()  && !billList.isEmpty()) {
                    billIdsSet = new set<Id>() ;
                    if (billList != null) {
                        for(Bill__c bill : billList ) {
                            billIdsSet.add(bill.Id) ;
                        }
                    }
                }
                
            }
            if (billIdsSet != null) {

                // Get the associated BillItem records using the billId
		        List<BillItem__c> billItmList = (List<BillItem__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBillItem.BILLITEMAPINAME, 
																										billItmFields, 
																										String.format('WHERE {0} IN {1}', 
																											new List<String>{
														        												GlUt_APIConstantsBillItem.BILLAPINAME, 
														        												GlUt_FieldSecurity.IdsToString(billIdsSet)})
														        										);

                // Prepare a set of BillItem ids and get the associated payment allocation records
                Set<Id> billItemIds = new Set<Id>();
                if (billItmList != null && !billItmList.isEmpty()) {
                    for (BillItem__c billItem : billItmList) {
                        billItemIds.add(billItem.Id);
                        billToBillItmMap.put(billItem.Id, billItem.Bill__c);
                    } 
                }
                
		        payAllocationList = (List<PaymentAllocation__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPaymentAllocation.PAYMENTALLOCATIONAPINAME, 
					        																		payAllocationFields,
																									String.format('WHERE {0} IN {1}', 
																										new List<String>{
													        												GlUt_APIConstantsPaymentAllocation.BILLITEMAPINAME, 
													        												GlUt_FieldSecurity.IdsToString(billItemIds)})
													        										);

                if (payAllocationList != null  && !payAllocationList.isEmpty()) {
                    for (PaymentAllocation__c pa : payAllocationList) {
                        if (pa.BillItem__c != null) {
                            if (!billPaymentAllocationMap.containsKey(billToBillItmMap.get(pa.BillItem__c))) {
                                billPaymentAllocationMap.put(billToBillItmMap.get(pa.BillItem__c), 0.00);
                            }
                            if (pa.AmountAllocated__c != null) {
                                pa.AmountAllocated__c = pa.AmountAllocated__c.setScale(2) ;    //AT-2703   Setting scale to 2 decimal places
                                billPaymentAllocationMap.put(billToBillItmMap.get(pa.BillItem__c), 
                                                             billPaymentAllocationMap.get(billToBillItmMap.get(pa.BillItem__c)) + pa.AmountAllocated__c); 
                            }
                        }
                    }
                }

            }
            if (billIdsSet != null && !billIdsSet.isEmpty()) {
                billId2DocumentIdMap = new Map<Id, ContentDocumentLink>();
		
                for (ContentDocumentLink cdl : (List<ContentDocumentLink>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPaymentAllocation.PAYMENTALLOCATIONAPINAME, 
					        																		new List<String>{'Id', 
								        																			'ContentDocumentId', 
								        																			'LinkedEntityId', 
								        																			'Visibility'}, 
																									String.format('WHERE {0} IN {1}', 
																										new List<String>{
													        												'LinkedEntityId', 
													        												GlUt_FieldSecurity.IdsToString(billIdsSet)}))) {
                                               	
					billId2DocumentIdMap.put(cdl.LinkedEntityId, cdl);
				}
            }
            if (billList != null && !billList.isEmpty()) {
                for (Bill__c objBill : billList) {
                    BlAp_CombinedRecord payAllocObj = new BlAp_CombinedRecord(); 
                    payAllocObj.uniqueId            = objBill.Id;
                    payAllocObj.isSelected          = false;
                    payAllocObj.objectMap           = new Map<String, sObject>();

                    // Set the object map for displaying the columns data
                    payAllocObj.objectMap.put(GlUt_APIConstantsBill.BILLAPINAME, objBill);
                    payAllocObj.transformFieldMap = new Map<String, Map<String, String>>();

                    // Prepare the transform field map to display the values of Amount Paid off column
                    if (!billId2DocumentIdMap.isEmpty() && billId2DocumentIdMap.get(objBill.Id) != null) {         
                        payAllocObj.objectMap.put(GlUt_APIConstantsBill.CONTENTDOCUMENTID, billId2DocumentIdMap.get(objBill.Id));
                    }
                    if (!billPaymentAllocationMap.isEmpty() && billPaymentAllocationMap.get(objBill.Id) != null) {
                        Map<String,String> transFormFieldMap2 = new Map<String, String>();
                        if (billPaymentAllocationMap.get(objBill.Id) != null) {
                            transFormFieldMap2.put(GlUt_APIConstantsPaymentAllocation.AMOUNTALLOCATEDAPINAME, String.valueOf(billPaymentAllocationMap.get(objBill.Id)));
                            payAllocObj.transformFieldMap.put(GlUt_APIConstantsBill.BILLAPINAME, transFormFieldMap2);
                        }
                    }
                    billsList.add(payAllocObj);
                }
            }
            return billsList;

        } catch (Exception oException) {
            GlUt_Logger.logException(oException);
            system.debug('Bill-oException:: ' + oException);
            throw new AuraHandledException('Error: ' + oException.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
}