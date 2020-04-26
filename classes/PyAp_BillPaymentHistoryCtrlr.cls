/******************************************************************************
@author      	Echo: Gopal Gupta
@date      		23-Jan-2018
@description	Component controller for Bill Payment History Lightning Component

Revisions		10 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class PyAp_BillPaymentHistoryCtrlr {
    
    private static final String CLASS_NAME = 'PyAp_BillPaymentHistoryCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
	// Variables
    private static List<String> paymentFields;
    private static List<String> billItmFields;
    private static List<String> payAllocationFields;
    private static List<String> servcItmFields;
    
    static{
        // Get fields from the Payment object
        paymentFields = new List<String>();
        paymentFields.add(GlUt_APIConstantsPayments.NAMEAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.PAYMENTDATEAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.RECORDTYPEAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.PAYMENTMETHODAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.AMOUNTAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.BILLALLOCATIONSTATUSAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.INSTALMENTALLOCATIONSTATUSAPINAME);
        
        // Get fields from the BillItem object
        billItmFields = new List<String>();
        billItmFields.add(GlUt_APIConstantsBillItem.SERVICEITEMAPINAME);
        billItmFields.add(GlUt_APIConstantsBillItem.BILLEDAMOUNTAPINAME);
        
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
    }
    
	/**********************************************************************************************
    @author         Echo: Gopal Gupta
    @date           23-Jan-2018
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the fields that are to be displayed on the screen
    **********************************************************************************************/    
    @AuraEnabled
    public static List<GLAp_FieldProps> retrievePaymentFieldPropDetails() {
        // List of fieldprops to return
        List<GLAp_FieldProps> paymentProps = new List<GLAp_FieldProps>();
        try{
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG ); 
            // Create transform tield for Bill Amount Paid off
            GLAp_FieldProps billAmtPaidOffProp = new GLAp_FieldProps();
            billAmtPaidOffProp.isFLSVisible = true;
            billAmtPaidOffProp.isEncrypted = false;
            billAmtPaidOffProp.isEditable = false;
            billAmtPaidOffProp.isRequired = false;
            billAmtPaidOffProp.fieldName = PyAp_Constants.BILLAMTPAIDOFFLABEL;
            billAmtPaidOffProp.fieldLabel = PyAp_Constants.BILLAMTPAIDOFFLABEL;
            billAmtPaidOffProp.fieldType = 'text';
            billAmtPaidOffProp.transformField = true; //Indicates this is a Transfrom and NOT a DB field
            billAmtPaidOffProp.parentObject = GlUt_APIConstantsPayments.PAYMENTAPINAME; //Attach to payment for display
            
            // Get the field properties for the Payment object
            for(GLAp_FieldProps fldProp : GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsPayments.PAYMENTAPINAME, paymentFields)){
                if(fldProp.fieldName == GlUt_APIConstantsPayments.BILLALLOCATIONSTATUSAPINAME){
                    paymentProps.add(billAmtPaidOffProp);
                }
                if(fldProp.fieldName == GlUt_APIConstantsPayments.PAYMENTMETHODAPINAME){
                    fldProp.fieldLabel = PyAp_Constants.PAYMENTMETHODLABEL;
                }
                if(fldProp.fieldName == GlUt_APIConstantsPayments.RECORDTYPEAPINAME){
                    fldProp.fieldLabel = PyAp_Constants.RECORDTYPELABEL;
                }
                if(fldProp.fieldName == GlUt_APIConstantsPayments.PAYMENTDATEAPINAME){
                    fldProp.fieldLabel = PyAp_Constants.PAYMENTDATELABEL;
                }
                if(fldProp.fieldName == GlUt_APIConstantsPayments.NAMEAPINAME){
                    fldProp.fieldLabel = PyAp_Constants.NAMELABEL;
                }
                paymentProps.add(fldProp);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return paymentProps;
    }
    
    /**********************************************************************************************
    @author         Echo: Gopal Gupta
    @date           23-Jan-2018
    @return         List<BlAp_CombinedRecord>
    @description    This method returns the payment data
	**********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrievePaymentRecords(String billId) {
        List<BlAp_CombinedRecord>  paymentList = new List<BlAp_CombinedRecord>();
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG );
            // Get the associated BillItem records using the billId
            List<BillItem__c> billItmList = (List<BillItem__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBillItem.BILLITEMAPINAME, 
                                                                                                    billItmFields, 
                                                                                                    billId, 
                                                                                                    GlUt_APIConstantsBillItem.BILLAPINAME);
            
            
            // Prepare a set of BillItem ids and get the associated payment allocation records
            Set<Id> billItemIds = new Set<Id>();
            for (BillItem__c billItem : billItmList) {
                billItemIds.add(billItem.Id);
            } 
            
            List<PaymentAllocation__c> payAllocationList = (List<PaymentAllocation__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPaymentAllocation.PAYMENTALLOCATIONAPINAME, 
                                                                                                                            payAllocationFields, 
                                                                                                                            String.format('WHERE {0} IN {1}', 
                                                                                                                                          new List<String>{
                                                                                                                                              GlUt_APIConstantsPaymentAllocation.BILLITEMAPINAME, 
                                                                                                                                                  GlUt_FieldSecurity.IdsToString(billItemIds)}));
            
            // Prepare a map of payment to payment allocation to calculate the bill amt paid off
            Map<Id, Decimal> payToPayAllocMap = new Map<Id, Decimal>();
            for (PaymentAllocation__c pa : payAllocationList) {
                if (pa.Payment__c != null) {
                    if (!payToPayAllocMap.containsKey(pa.Payment__c)) {
                        payToPayAllocMap.put(pa.Payment__c, 0.00);
                    }
                    if (pa.AmountAllocated__c != null) {
                        payToPayAllocMap.put(pa.Payment__c,payToPayAllocMap.get(pa.Payment__c) + pa.AmountAllocated__c); 
                    }
                }
            }
            
            // Get the related payment records
            Set<Id> paymentIds = payToPayAllocMap.keySet();
            List<Payment__c> paymentsList = (List<Payment__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPayments.PAYMENTAPINAME, 
                                                                                                   paymentFields, 
                                                                                                   String.format('WHERE Id IN {0} ORDER BY {1} DESC', 
                                                                                                                 new List<String>{
                                                                                                                     GlUt_FieldSecurity.IdsToString(paymentIds), 
                                                                                                                         GlUt_APIConstantsPayments.PAYMENTDATEAPINAME}));
            
            // Prepare the combined record list to display on screen
            for (Payment__c pay : paymentsList) {
                BlAp_CombinedRecord payObj = new BlAp_CombinedRecord();            
                payObj.uniqueId = pay.Id;
                payObj.isSelected = false;
                payObj.objectMap = new Map<String, sObject>();
                payObj.objectMap.put(GlUt_APIConstantsPayments.PAYMENTAPINAME, pay);
                
                // Prepare the transform field map to display the values of Bill Amount Paid off column
                Map<String,String> transFormFieldMap = new Map<String,String>();
                transFormFieldMap.put(PyAp_Constants.BILLAMTPAIDOFFLABEL, String.valueOf(payToPayAllocMap.get(pay.Id)));
                payObj.transFormFieldMap = new Map<String,Map<String,String>>();
                payObj.transFormFieldMap.put(GlUt_APIConstantsPayments.PAYMENTAPINAME, transFormFieldMap);
                paymentList.add(payObj);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return paymentList;
    }
        
    /**********************************************************************************************
    @author         Echo: Gopal Gupta
    @date           23-Jan-2018
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
                    fldProp.fieldLabel = PyAp_Constants.NAMELABEL;
                    fldPropList.add(fldProp);
                }
            }
            
            // Get the field properties for the ServiceItem object
            List<GLAp_FieldProps> servcItmFldPropList = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME, servcItmFields);
            for(GLAp_FieldProps fldProp : servcItmFldPropList){
                if(fldProp.fieldName == GlUt_APIConstantsServiceItem.SERVICEITEMTYPEAPINAME){
                    fldProp.fieldLabel = PyAp_Constants.SERVICEITEMTYPENAMELABEL;
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
            throw new AuraHandledException(e.getMessage());
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return fldPropList;
    } 
    
    /**********************************************************************************************
    @author         Echo: Gopal Gupta
    @date           23-Jan-2018
    @return         List<BlAp_CombinedRecord>
    @description    This method returns the bill item data
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
            Map<Id, BillItem__c> billItemMap = new Map<Id, BillItem__c>();
            for (BillItem__c bi : billItmList) {
                billItemIds.add(bi.Id);
                serviceItmIds.add(bi.ServiceItem__c);
                billItemMap.put(bi.Id, bi);
            }
            
            // Get the associated ServiceItems records using the serviceitem ids from the billitem records
            List<ServiceItem__c> servcItmList = (List<ServiceItem__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME, 
                                                                                                           servcItmFields, 
                                                                                                           'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(serviceItmIds));
            
            // Prepare a map of ServiceItem
            Map<Id, ServiceItem__c> servItemMap = new Map<Id, ServiceItem__c>();
            for (ServiceItem__c servItm : servcItmList) {
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