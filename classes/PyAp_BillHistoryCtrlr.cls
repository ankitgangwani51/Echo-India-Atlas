/******************************************************************************
@author      	Echo: Vivek Sethi
@date      		25-Jan-2018
@description	Component controller for Bill History Lightning Component

Revisions		10 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class PyAp_BillHistoryCtrlr {
    
    private static List<string> billFields;  
    private static List<string> paymentFields;    
    private static List<String> servcItmFields;
    private static List<string> payAllocationFields;    
    private static List<string> billItmFields;
    
    
    private static final String CLASS_NAME = 'PyAp_BillHistoryCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    static{
        //get fields from Bill__c object
        billFields = new List<string>();
        billFields.add(GlUt_APIConstantsBill.BILLNUMBERAPINAME);
        billFields.add(GlUt_APIConstantsBill.BILLDATEAPINAME);
        billFields.add(GlUt_APIConstantsBill.BILLEDAMOUNTAPINAME); 
        
        // Get fields from the Payment object
        paymentFields = new List<string>();
        paymentFields.add(GlUt_APIConstantsPayments.PAYMENTMETHODAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.BILLALLOCATIONSTATUSAPINAME);
        
        // Get fields from the PaymentAllocation object
        payAllocationFields = new List<String>();
        payAllocationFields.add(GlUt_APIConstantsPaymentAllocation.NAMEAPINAME);
        payAllocationFields.add(GlUt_APIConstantsPaymentAllocation.PAYMENTAPINAME);
        payAllocationFields.add(GlUt_APIConstantsPaymentAllocation.AMOUNTALLOCATEDAPINAME);
        payAllocationFields.add(GlUt_APIConstantsPaymentAllocation.STATUSAPINAME);
        payAllocationFields.add(GlUt_APIConstantsPaymentAllocation.BILLITEMAPINAME);
        
        // Get fields from the ServiceItem object
        servcItmFields = new List<String>();
        servcItmFields.add(GlUt_APIConstantsServiceItem.LOCATIONAPINAME);
        servcItmFields.add(GlUt_APIConstantsServiceItem.SUPPLYPOINTAPINAME);
        servcItmFields.add(GlUt_APIConstantsServiceItem.SERVICEITEMTYPEAPINAME);
        
        // Get fields from the BillItem object
        billItmFields = new List<String>();
        billItmFields.add(GlUt_APIConstantsBillItem.SERVICEITEMAPINAME);
        billItmFields.add(GlUt_APIConstantsBillItem.BILLEDAMOUNTAPINAME);
    }
    
    /**********************************************************************************************
	@author         Echo: Vivek Sethi
	@date           25-Jan-2018
	@return         List<GLAp_FieldProps>
	@description    This method returns the field properties for each of the fields that are to be displayed on the screen
	**********************************************************************************************/ 
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveBillFieldPropDetails() {
        List<GLAp_FieldProps> billProps    = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsBill.BILLAPINAME, billFields);
        List<GLAp_FieldProps> paymentProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsPayments.PAYMENTAPINAME, paymentFields);
        List<GLAp_FieldProps> pmtallocProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsPaymentAllocation.PAYMENTALLOCATIONAPINAME, payAllocationFields);
        
        // Create transform field for Payment Allocation - Amount Allocated
        GLAp_FieldProps amtPaidOffProp = new GLAp_FieldProps();
        amtPaidOffProp.isFLSVisible = true;
        amtPaidOffProp.isEncrypted = false;
        amtPaidOffProp.isEditable = false;
        amtPaidOffProp.isRequired = false;
        amtPaidOffProp.fieldName = GlUt_APIConstantsPaymentAllocation.AMOUNTALLOCATEDAPINAME;
        amtPaidOffProp.fieldLabel =   PyAp_Constants.AMOUNTALLOCATEDLABEL;
        amtPaidOffProp.fieldType = 'text';
        amtPaidOffProp.transformField = true; //Indicates this is a Transfrom and NOT a DB field
        amtPaidOffProp.parentObject = GlUt_APIConstantsBill.BILLAPINAME; //Attach to Bill for display
        
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG );
            for(GLAp_FieldProps fldProp : billProps){
                if(fldProp.fieldName == GlUt_APIConstantsBill.BILLNUMBERAPINAME){
                    fldProp.fieldLabel = PyAp_Constants.NAME;   //AT-2146
                    fldPropList.add(fldProp); 
                }
                if(fldProp.fieldName == GlUt_APIConstantsBill.BILLDATEAPINAME){
                    fldProp.fieldLabel = PyAp_Constants.BILLDATELABEL;
                    fldPropList.add(fldProp); 
                }
            }
            for(GLAp_FieldProps fldProp : paymentProps){
                if(fldProp.fieldName == GlUt_APIConstantsPayments.PAYMENTMETHODAPINAME){
                    fldProp.fieldLabel = PyAp_Constants.PMTMETHODLABEL;
                    fldPropList.add(fldProp); 
                }
            }
            for(GLAp_FieldProps fldProp : billProps){
                if(fldProp.fieldName == GlUt_APIConstantsBill.BILLEDAMOUNTAPINAME){
                    fldProp.fieldLabel = PyAp_Constants.BILLEDAMTLABEL;
                    fldPropList.add(fldProp);
                }
            }
            for(GLAp_FieldProps fldProp : paymentProps){
                if(fldProp.fieldName == GlUt_APIConstantsPayments.BILLALLOCATIONSTATUSAPINAME){
                    fldProp.fieldLabel = PyAp_Constants.BILLALLOCATIONSTATUSLABEL;
                    fldPropList.add(fldProp); 
                }
            }
            for(GLAp_FieldProps fldProp : pmtallocProps){
                if(fldProp.fieldName == GlUt_APIConstantsPaymentAllocation.AMOUNTALLOCATEDAPINAME){
                    fldPropList.add(amtPaidOffProp); 
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return fldPropList;
    }
    
    /**********************************************************************************************
	@author         Echo: Vivek Sethi
	@date           25-Jan-2018
	@return         List<BlAp_CombinedRecord>
	@description    This method returns the Bill data
	**********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveBillRecords(string paymentId) {
        
        List<BlAp_CombinedRecord> billsList = new List<BlAp_CombinedRecord>();
        try{
            
           GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG );   
            Payment__c payment = (Payment__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsPayments.PAYMENTAPINAME, 
                                                                                 paymentId, 
                                                                                 paymentFields);
            Map<Id, Payment__c> paymentMap = new Map<Id, Payment__c>();
            paymentMap.put(payment.Id, payment);
            
            List<PaymentAllocation__c> pList = (List<PaymentAllocation__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPaymentAllocation.PAYMENTALLOCATIONAPINAME, 
                                                                                                                payAllocationFields, 
                                                                                                                paymentId, 
                                                                                                                GlUt_APIConstantsPaymentAllocation.PAYMENTAPINAME);
            Set<Id> billItemIdSet = new Set<Id>();
            Map<Id, PaymentAllocation__c> paymentAllocationMap = new Map<Id, PaymentAllocation__c>();
            for (PaymentAllocation__c objPA : pList ) {
                if (objPA.BillItem__c != null) {
                    billItemIdSet.add(objPA.BillItem__c);
                    paymentAllocationMap.put(objPA.Id, objPA);
                }
            }
            
            List<BillItem__c> billItemList = (List<BillItem__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBillItem.BILLITEMAPINAME, 
                                                                                                     new List<String>{GlUt_APIConstantsBillItem.BILLAPINAME}, 
                                                                                                     'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(billItemIdSet));
            Set<Id> billIdSet = new Set<Id>();
            Map<Id, BillItem__c> billItemMap = new Map<Id, BillItem__c>();
            for (BillItem__c objBI : billItemList ) {   
                if (objBI.Bill__c != null) {
                    billIdSet.add(objBI.Bill__c);
                    billItemMap.put(objBI.Id, objBI);
                }
            }
            
            List<Bill__c> billList = (List<Bill__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBill.BILLAPINAME, 
                                                                                         billFields, 
                                                                                         String.format('WHERE Id IN {0} ORDER BY {1} DESC', 
                                                                                                       new List<String>{
                                                                                                           GlUt_FieldSecurity.IdsToString(billIdSet), 
                                                                                                               GlUt_APIConstantsBill.BILLDATEAPINAME}));
            Map<Id, Bill__c> billMap                  = new Map<Id,Bill__c>();
            Map<Id, sObject> paymentAllocationBillMap = new Map<Id, sObject>();
            Map<Id, sObject> paymentbillMap           = new Map<Id, sObject>();
            
            for (Bill__c objBill : billList) {
                billMap.put(objBill.Id, objBill);
            }
            
            Map<Id, Decimal> totalPayAllocMap = new Map<Id, Decimal>();
            for (PaymentAllocation__c payAlloc : pList) {
                if (payAlloc.BillItem__c  != null) {		/*Allow only when Bill Item Exists on payment allocation record*/
                    if (billItemMap.get(payAlloc.BillItem__c) != null) {		/*Allow only when Bill exists on Bill Item record*/
                        
                        /*Payment Allocation with Bill linkage */
                        paymentAllocationBillMap.put(billMap.get(billItemMap.get(payAlloc.BillItem__c).Bill__c).Id, paymentAllocationMap.get(payAlloc.Id));
                        /*Payment with Bill linkage */
                        paymentbillMap.put(billMap.get(billItemMap.get(payAlloc.BillItem__c).Bill__c).Id, paymentMap.get(payAlloc.Payment__c));
                        /*Summing up Payment Allocation Amount Allocated using similar Bill Id's*/
                        
                        if (billMap.get(billItemMap.get(payAlloc.BillItem__c).Bill__c).Id != null) {
                            if (!totalPayAllocMap.containsKey(billMap.get(billItemMap.get(payAlloc.BillItem__c).Bill__c).Id)) {
                                totalPayAllocMap.put(billMap.get(billItemMap.get(payAlloc.BillItem__c).Bill__c).Id, 0.00);
                            }
                            if (payAlloc.AmountAllocated__c != null) {
                                payAlloc.AmountAllocated__c = payAlloc.AmountAllocated__c.setScale(2) ;
                                totalPayAllocMap.put(billMap.get(billItemMap.get(payAlloc.BillItem__c).Bill__c).Id, 
                                                     totalPayAllocMap.get(billMap.get(billItemMap.get(payAlloc.BillItem__c).Bill__c).Id) + payAlloc.AmountAllocated__c); 
                            }
                        }
                    }
                }            
            }
            
            for (Bill__c objBill : billList) {
                BlAp_CombinedRecord payAllocObj = new BlAp_CombinedRecord(); 
                payAllocObj.uniqueId            = objBill.Id;
                payAllocObj.isSelected          = false;
                payAllocObj.objectMap           = new Map<String, sObject>();
                
                // Set the object map for displaying the columns data
                payAllocObj.objectMap.put(GlUt_APIConstantsBill.BILLAPINAME,objBill);
                payAllocObj.objectMap.put(GlUt_APIConstantsPaymentAllocation.PAYMENTALLOCATIONAPINAME,paymentAllocationBillMap.get(objBill.Id)) ; 
                payAllocObj.objectMap.put(GlUt_APIConstantsPayments.PAYMENTAPINAME, paymentbillMap.get(objBill.Id)) ; 
                
                // Prepare the transform field map to display the values of Amount Paid off column
                Map<String,String> transFormFieldMap = new Map<String,String>();
                transFormFieldMap.put(GlUt_APIConstantsPaymentAllocation.AMOUNTALLOCATEDAPINAME, String.valueOf(totalPayAllocMap.get(objBill.Id)));
                payAllocObj.transformFieldMap = new Map<String, Map<String,String>>();
                payAllocObj.transformFieldMap.put(GlUt_APIConstantsBill.BILLAPINAME, transFormFieldMap);
                billsList.add(payAllocObj);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return billsList;
    }
    
    /**********************************************************************************************
	@author         Echo: Vivek Sethi
	@date           25-Jan-2018
	@return         List<GLAp_FieldProps>
	@description    This method returns the field properties for each of the fields that are to be displayed on the screen
	**********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveBillItmPropDetails() {
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG );
            // Get the field properties for the PaymentAllocation object
            List<GLAp_FieldProps> payAllocFldPropList = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsPaymentAllocation.PAYMENTALLOCATIONAPINAME, payAllocationFields);
            for(GLAp_FieldProps fldProp : payAllocFldPropList){
                if(fldProp.fieldName == GlUt_APIConstantsPaymentAllocation.NAMEAPINAME){
                    fldProp.fieldLabel = PyAp_Constants.NAME;  //AT-2146
                    fldPropList.add(fldProp);
                }
            }
            
            // Get the field properties for the ServiceItem object
            List<GLAp_FieldProps> servcItmFldPropList = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME, servcItmFields);
            for(GLAp_FieldProps fldProp : servcItmFldPropList){
                if(fldProp.fieldName == GlUt_APIConstantsServiceItem.SERVICEITEMTYPEAPINAME){
                    fldProp.fieldLabel =  PyAp_Constants.SERVICEITEMTYPELABEL;
                }
                fldPropList.add(fldProp);
            }
            
            // Get the field properties for the BillItem object
            List<GLAp_FieldProps> billItmFldPropList = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsBillItem.BILLITEMAPINAME, billItmFields);
            for(GLAp_FieldProps fldProp : billItmFldPropList){
                if(fldProp.fieldName == GlUt_APIConstantsBillItem.BILLEDAMOUNTAPINAME){
                    fldProp.fieldLabel = PyAp_Constants.BILLEDAMOUNTLABEL;
                    fldPropList.add(fldProp);
                }
            }
            
            // Add the field properties for the PaymentAllocation object
            for(GLAp_FieldProps fldProp : payAllocFldPropList){
                if(fldProp.fieldName == GlUt_APIConstantsPaymentAllocation.AMOUNTALLOCATEDAPINAME || fldProp.fieldName == GlUt_APIConstantsPaymentAllocation.STATUSAPINAME){
                    fldPropList.add(fldProp);
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return fldPropList;
    }
    
    /**********************************************************************************************
	@author         Echo: Vivek Sethi
	@date           25-Jan-2018
	@return         List<BlAp_CombinedRecord>
	@description    This method returns the bill Item data
	**********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveBillItems(String paymentId, String billId) {
        
        List<BlAp_CombinedRecord>  billItemsList = new List<BlAp_CombinedRecord>();
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG );
            
            // Get the associated BillItem records using the billId
            List<BillItem__c> billItmList = (List<BillItem__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBillItem.BILLITEMAPINAME, 
                                                                                                    billItmFields, 
                                                                                                    billId, 
                                                                                                    GlUt_APIConstantsBillItem.BILLAPINAME);
            
            
            // Prepare a map of BillItem
            Set<Id> billItemIds = new Set<Id>();
            Set<Id> serviceItmIds = new Set<Id>();
            Map<Id,BillItem__c> billItemMap = new Map<Id,BillItem__c>();
            for (BillItem__c bi : billItmList) {
                billItemIds.add(bi.Id);
                serviceItmIds.add(bi.ServiceItem__c);
                billItemMap.put(bi.Id, bi);
            }
            
            // Get the associated ServiceItems records using the serviceitem ids from the billitem records
            List<ServiceItem__c> servcItmList = (List<ServiceItem__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME, 
                                                                                                           servcItmFields, 
                                                                                                           'WHERE ID IN ' + GlUt_FieldSecurity.IdsToString(serviceItmIds));
            
            // Prepare a map of ServiceItem
            Map<Id,ServiceItem__c> servItemMap = new Map<Id,ServiceItem__c>();
            for(ServiceItem__c servItm : servcItmList){
                servItemMap.put(servItm.Id, servItm);
            }
            
            // Get the associated PaymentAllocation records using the billitem ids and payment id
            List<PaymentAllocation__c> payAllocationList = (List<PaymentAllocation__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPaymentAllocation.PAYMENTALLOCATIONAPINAME, 
                                                                                                                            payAllocationFields, 
                                                                                                                            paymentId, 
                                                                                                                            GlUt_APIConstantsPaymentAllocation.PAYMENTAPINAME, 
                                                                                                                            String.format('{0} IN {1} AND {2} != NULL', 
                                                                                                                                          new List<String>{
                                                                                                                                              GlUt_APIConstantsPaymentAllocation.BILLITEMAPINAME, 
                                                                                                                                                  GlUt_FieldSecurity.IdsToString(billItemIds), 
                                                                                                                                                  GlUt_APIConstantsPaymentAllocation.BILLITEMAPINAME}));
            
            // Prepare the combined record list
            for (PaymentAllocation__c payAlloc : payAllocationList) {
                BlAp_CombinedRecord payAllocObj = new BlAp_CombinedRecord();            
                payAllocObj.uniqueId = payAlloc.Id;
                payAllocObj.isSelected = false;
                payAllocObj.objectMap = new Map<String, sObject>();
                
                // Set the object map for displaying the columns data
                payAllocObj.objectMap.put(GlUt_APIConstantsPaymentAllocation.PAYMENTALLOCATIONAPINAME, payAlloc);
                payAllocObj.objectMap.put(GlUt_APIConstantsBillItem.BILLITEMAPINAME, billItemMap.get(payAlloc.BillItem__c));
                payAllocObj.objectMap.put(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME, servItemMap.get(billItemMap.get(payAlloc.BillItem__c).ServiceItem__c));
                billItemsList.add(payAllocObj);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }

        return billItemsList;
    }
}