/******************************************************************************
@author         Echo: Amit K.
@date           23 Jan 2018
@description    Component controller for showDeviceReading lightning component

Revisions		10 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class PyAp_PaymentAmendmentsPageCtrlr {
    
    private static final String CLASS_NAME = 'PyAp_PaymentAmendmentsPageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static List<string> paymentFields;
    private static List<string> accountFields;
    private static List<string> paymentAssociationFields;
    static{
        paymentFields = new List<string>();
        paymentFields.add(GlUt_APIConstantsPayments.AMOUNTAPINAME); 
        paymentFields.add(GlUt_APIConstantsPayments.PAYMENTDATEAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.CONTRACTAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.ACCOUNTAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.REVERSEDAMOUNTAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.AMENDMENTREASONAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.PAYMENTMETHODAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.RECORDTYPEAPINAME);
        paymentFields.add(GlUt_APIConstantsPayments.DONOTPRINT);     // AT-4897
    }
    static{
        accountFields = new List<string>();
        accountFields.add(GlUt_APIConstantsAccount.ACCOUNTNAMEAPINAME); 
    }
    static{
        paymentAssociationFields = new List<string>();
        paymentAssociationFields.add(GlUt_APIConstantsPaymentAssociation.ORIGINALPAYMENTAPINAME); 
        paymentAssociationFields.add(GlUt_APIConstantsPaymentAssociation.TRANSFERREDFUNDEDPAYMENTAPINAME);
    }
    private static final List < String > paymentListField = new List < string > {
        GlUt_APIConstantsPayments.PAYMENTTRANSFERREASONAPINAME
    };
    
    /**********************************************************************************************
    @author      : Echo:Amit K.
    @date        : 08-Mar-2018
    @params      : 
    @return      : List<List<GLAp_FieldProps>>
    @description : This method returns back Payment related fields as List. 
    **********************************************************************************************/
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrievePaymentFields() {
        try {
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            List<GLAp_FieldProps> lstPaymentFields = new List<GLAp_FieldProps>();
            lstPaymentFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsPayments.PAYMENTAPINAME, paymentListField);
            for(GLAp_FieldProps pmtProp: lstPaymentFields){ 
                pmtProp.showLabel = true;
                pmtProp.isEditable = true;
                if(pmtProp.fieldName == GlUt_APIConstantsPayments.PAYMENTTRANSFERREASONAPINAME){
                    pmtProp.fieldLabel = Label.PyAp_PaymentAmendmentReasonLabel;
                }
            }
 
            for(integer i=0; i < lstPaymentFields.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(lstPaymentFields[i]);
                if(secondEntryIndex < lstPaymentFields.size()){
                    lstEntry.add(lstPaymentFields[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
            }
            return twoColFormattedList;
         } catch (exception e) {
             GlUt_Logger.logException(e);
             throw new AuraHandledException(e.getMessage());
        }  
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /**********************************************************************************************
	@author      : Echo: Amit K.
	@date        : 25-Jan-2017
	@return      : ContainerWrapper Wrapper Class
	@params      : String originalPaymentId
	@description : This method used to fetch the existing account lookup record available on Payment record based on payment record id.
	**********************************************************************************************/ 
    @AuraEnabled
    public static ContainerWrapper getExistingPaymentAccount(String originalPaymentId) {

        //instance of wrapper class
        ContainerWrapper resultContainer = new ContainerWrapper(); 

        Payment__c payment;
        Account account;
        try{
            if (string.isNotBlank(originalPaymentId)) {
                payment = (Payment__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsPayments.PAYMENTAPINAME, 
                                                                          originalPaymentId, 
                                                                          paymentFields);
            }
            
            if (payment.Id != null) {
                List<PaymentAssociation__c> paymentAssociationList = (List<PaymentAssociation__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPaymentAssociation.PAYMENTASSOCIATIONAPINAME, 
                                                                                                                                       paymentAssociationFields, 
                                                                                                                                       payment.Id, 
                                                                                                                                       GlUt_APIConstantsPaymentAssociation.ORIGINALPAYMENTAPINAME);
                
                resultContainer.isPaymentExist = !paymentAssociationList.isEmpty();
                
                resultContainer.existingRecordTypeName = Schema.SObjectType.Payment__c.getRecordTypeInfosById().get(payment.RecordTypeId).getName();
                if (payment.Account__c != null) {
                    account = (Account) GlAp_LightningDataAccess.getRecord(CuAp_Constants.ACCOUNTAPINAME, 
                                                                           payment.Account__c, 
                                                                           accountFields);
                }
            }
            if (account != null && account.Id != null) {
                resultContainer.Account = account;
            } else {
                resultContainer.Account = null;
            }
            return resultContainer;
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
    }
    
    /**********************************************************************************************
	@author      : Echo: Ankit Gangwani
	@date        : 01 Nov 2018
	@return      : Boolean
	@params      : String originalPaymentId, 				   
	@description : This method return true of Location exist on Payment record
	**********************************************************************************************/ 
    @AuraEnabled
    public static boolean getLocationOnPayment(String originalPaymentId) { 
        
        List<Payment__c> paymentList = new List<Payment__c>();
        Boolean isLocationExist = false;
        string sOQLQuery ='';
        if (string.isNotBlank(originalPaymentId) && originalPaymentId != null) {
            /*sOQLQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ GlUt_APIConstantsPayments.LOCATIONAPINAME, 
                GlUt_APIConstantsPayments.PAYMENTAPINAME +' WHERE Id =\''+String.escapeSingleQuotes(originalPaymentId)+'\''});
            paymentList = Database.query(sOQLQuery);*/
            
            String filterStatement = ' WHERE Id =\''+String.escapeSingleQuotes(originalPaymentId)+'\'';
            paymentList  = (List<Payment__c>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPayments.PAYMENTAPINAME, 
                                                                                new List<String>{GlUt_APIConstantsPayments.LOCATIONAPINAME}, 
                                                                                filterStatement);
            
        }
        
        if(!paymentList.isEmpty() && paymentList[0].Location__c != null){
            isLocationExist = true;            
        }
        else{
            isLocationExist = false;
        }
        return isLocationExist;
    }
    
    /**********************************************************************************************
	@author      : Echo: Amit K.
	@date        : 24-Jan-2017
	@return      : String
	@params      : String originalPaymentId, 
				   String paymentType, 
                   String paymentTransferReason, 
                   String selectedContractId, 
                   String selectedAccountId,
				   Boolean isDoNotPrint // AT-4897
	@description : This method creates new payment record and update the existing payment record on the basis of transfer payment or return payment scenarios.
	**********************************************************************************************/ 
    @AuraEnabled
    public static String  paymentAmendment(String originalPaymentId, String paymentType, String paymentTransferReason, String selectedContractId, String selectedAccountId, Boolean isDoNotPrint) {  // AT-4897 
        List<Payment__c> paymentList = new List<Payment__c>();
        Payment__c newNegativePayment;
        Payment__c newPaymentForSelectedCustomerContract;
        List<Payment__c> combinedPaymentList = new List<Payment__c>();
        List<PaymentAssociation__c> paymentAssociationList = new List<PaymentAssociation__c>();
        PaymentAssociation__c pa;
        string sOQLQuery ='';
        String retVal ='';
        
        system.debug('originalPaymentId--' +  originalPaymentId);
        system.debug('paymentType--' +  paymentType);
        system.debug('paymentTransferReason--' +  paymentTransferReason);
        system.debug('selectedContractId--' +  selectedContractId);
        system.debug('selectedAccountId--' +  selectedAccountId);
        system.debug('isDoNotPrint--' +  isDoNotPrint);
        
        if (string.isNotBlank(originalPaymentId) && originalPaymentId != null) {
            // Changes By Dependra Singh- Clayton Issue.
           /* paymentList = [SELECT Id, Amount__c,PaymentDate__c,BillingContract__c,Account__c,ReversedAmount__c,AmendmentReason__c,PaymentMethod__c,RecordTypeId,BillAmountUnallocated__c // Neha AT-  
						   FROM Payment__c WHERE Id =: originalPaymentId];
            sOQLQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(paymentFields,','), 
                		GlUt_APIConstantsPayments.PAYMENTAPINAME +' WHERE Id =\''+String.escapeSingleQuotes(originalPaymentId)+'\''});
            paymentList = Database.query(sOQLQuery);*/
            
            String filterStatement = ' WHERE Id =\''+String.escapeSingleQuotes(originalPaymentId)+'\'';
            paymentList  = (List<Payment__c>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsPayments.PAYMENTAPINAME, 
                                                                                 paymentFields, 
                                                                                 filterStatement);
            
        }
        if (string.isNotBlank(paymentType) && paymentType != null && !paymentList.isEmpty()) {
            Savepoint sp = Database.setSavepoint();
            try {
                // Find the transfer return record type id from Payment object.
                ID recordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(System.Label.PyAp_ReturnTransferPaymentRecordType).getRecordTypeId();
                //Create new payment record having negative amount for return payment or transfer payment scenario.
                newNegativePayment = new Payment__c();
                newNegativePayment.Amount__c = Decimal.valueOf('-' + paymentList[0].Amount__c); 
                newNegativePayment.BillingContract__c = paymentList[0].BillingContract__c;
                newNegativePayment.PaymentDate__c = System.today();
                newNegativePayment.Account__c = paymentList[0].Account__c;
                newNegativePayment.RecordTypeId = recordTypeId;
                
                //Check if scenario is return payment.
                if(paymentType == System.Label.PyAp_PaymentAmendmentOptValue1){
                    newNegativePayment.Transferred__c = System.Label.PyAp_ReturnPaymentTransferred;
                    paymentList[0].AmendmentReason__c = System.Label.PyAp_ReturnPaymentAmendReason;
                }
                
                //Check if scenario is transfer payment.
                if(paymentType == System.Label.PyAp_PaymentAmendmentOptValue2){
                    newNegativePayment.Transferred__c = System.Label.PyAp_TransferPaymentTransferred;
                    paymentList[0].AmendmentReason__c = System.Label.PyAp_PaymentTransferAmendReason; 
                    //AT-4897 Start...
                    newNegativePayment.DoNotPrint__c = isDoNotPrint;
                    paymentList[0].DoNotPrint__c     = isDoNotPrint;
                    //At-4897 End...
                }
                paymentList[0].PaymentTransferReason__c = paymentTransferReason;
                paymentList[0].ReversedAmount__c = paymentList[0].Amount__c;
                
                //Add new negative payment record to combined payment list for transfer or return payment scenario.
                combinedPaymentList.add(newNegativePayment);
                // Check the security on the Payment fields
            	paymentList = GlUt_FieldSecurity.cleanseFields(paymentList, false);
                //update original payment record.
                update paymentList[0];
                if (paymentType == System.Label.PyAp_PaymentAmendmentOptValue2) {
                	
                    //Create new payment record for transfer payment scenario.
                    newPaymentForSelectedCustomerContract = new Payment__c(); 
                    newPaymentForSelectedCustomerContract.BillingContract__c =  selectedContractId;
                    newPaymentForSelectedCustomerContract.Account__c =  selectedAccountId;
                    newPaymentForSelectedCustomerContract.PaymentDate__c = System.today();
                    newPaymentForSelectedCustomerContract.Amount__c = paymentList[0].Amount__c;
                    newPaymentForSelectedCustomerContract.PaymentMethod__c = paymentList[0].PaymentMethod__c;                    
                    newPaymentForSelectedCustomerContract.DoNotPrint__c = isDoNotPrint; //AT-4897 
                    
                    //Add new payment record for selected contract or account to combined payment list for transfer payment scenario.
                    combinedPaymentList.add(newPaymentForSelectedCustomerContract);
                }
                // Check the security on the Payment fields.
                combinedPaymentList = GlUt_FieldSecurity.cleanseFields(combinedPaymentList, false);
                //Insert the combined payment record for transfer/return payemnt scenario.
                if (!combinedPaymentList.isEmpty()) {
                    insert combinedPaymentList;
                    system.debug('501*****combinedPaymentList ' + combinedPaymentList);
                    for (Payment__c p:combinedPaymentList) {
                        pa = new PaymentAssociation__c();
                        if (p.RecordTypeId == recordTypeId) {
                            pa.OriginalPayment__c = paymentList[0].Id;
                            pa.TransferredRefundedPayment__c = p.Id;
                        } else {
                            pa.OriginalPayment__c = p.Id;
                            pa.TransferredRefundedPayment__c = combinedPaymentList[0].Id;
                        }
                        
                        //Add payment associated record to new list.
                        paymentAssociationList.add(pa);
                    }
                }
                
                // Check the security on the Payment Association fields
                paymentAssociationList = GlUt_FieldSecurity.cleanseFields(paymentAssociationList, false);
                
                //Create payment associated records for transfer/return payment scenario.
                if (!paymentAssociationList.isEmpty()) {
                    insert paymentAssociationList;
                }
                
            } catch (Exception ex){
                system.debug('Here in exception**');
                GlUt_Logger.logException(ex);
                Database.rollback(sp);
                String errormsg = ex.getmessage();
                retVal = errormsg.split(':')[1].split(',')[1];
            }
            finally {   
                GlUt_Logger.writeLogsToDatabase();
            }
        }
        return retVal;
    }
    
    /******************************************************************************
	@author      	Echo: Amit K.
	@date      		09 Feb 2018
	@param			none
	@return			none
	@description	Wrapper Class to hold Payment details and Account Details
	which will be returned to helper
	*******************************************************************************/
    public class ContainerWrapper {
        @AuraEnabled public Account Account;
        @AuraEnabled public string existingRecordTypeName;
        @AuraEnabled public Boolean isPaymentExist;
    }
    
}