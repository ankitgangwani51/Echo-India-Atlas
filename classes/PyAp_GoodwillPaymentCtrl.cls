/******************************************************************************
@author         Echo: Sudhir Kumar
@date           21 June 2018
@description    Component controller for GoodwillPayment lightning component.
@revesion		Changes by Dependra Singh - Security Review
*******************************************************************************/

public with sharing class PyAp_GoodwillPaymentCtrl {
	
	private static final String CLASS_NAME = 'PyAp_GoodwillPaymentCtrl';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static final String goodwillPaymentRecordType = 'Goodwill' ;
    private static final Id goodwillPaymentRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(goodwillPaymentRecordType).getRecordTypeId() ;
    
	// Goodwill Payment fields
	private static list<String> goodwillPaymentFields = new list<String> {
		GlUt_APIConstantsPayments.AMOUNTAPINAME ,	
        GlUt_APIConstantsPayments.GOODWILLREASONAPINAME 
	} ;
	
    // List of bank related field's string(Related to payment object).
    private static final List<String> paymentBankAccFields = new List<String>{
		GlUt_APIConstantsPayments.REFUNDACCOUNTAPINAME, 
		GlUt_APIConstantsPayments.BANKACCOUNTNOAPINAME,
        GlUt_APIConstantsPayments.BANKACCSORTCODEAPINAME
	};
	
	// List of cheque related field's string(Related to payment object).
	private static final List<String> paymentChequeRefFields = new List<String>{
		GlUt_APIConstantsPayments.REFUNDADDRESSAPINAME,
		GlUt_APIConstantsPayments.REFUNDREFRENCEAPINAME                                                    
	};       
			
	// List of account related field's string.      
	private static final List<String> paymentAccountFields = new List<String>{
		PyAp_Constants.NAME                                                 
	};
        
    //List of Bank Branch field's string     
    public static List<String> bankBranchListFields = new List<String>{
      	 GlUt_APIConstantsbankBranch.FICODEAPINAME,
         GlUt_APIConstantsbankBranch.STATEAPINAME,
         GlUt_APIConstantsbankBranch.BRANCHADDRESSAPINAME,
         GlUt_APIConstantsbankBranch.POSTCODEAPINAME,
         GlUt_APIConstantsbankBranch.TOWNCITYAPINAME
  	};                 
                    
        
    /**********************************************************************************************
	@author      : Echo: Sudhir Kumar
	@date        : 29-June-2018   
	@params      : Payment__c goodwillPaymentObj, String accountId, String type, String contractId, String bankAccountDetailId
	@return      : void
	@description : This method insert Good will payment created from Goodwill LC
	**********************************************************************************************/   
    @AuraEnabled
    public static void saveGoodwillPayment(Payment__c goodwillPaymentObj, String accountId, String type, String contractId, String bankAccountDetailId) {
		try {
            Payment__c goodwillPayment = new Payment__c() ;
            goodwillPaymentObj.PaymentDate__c = System.today() ;
            goodwillPaymentObj.RecordTypeId = goodwillPaymentRecordTypeId ;
            goodwillPaymentObj.Account__c = accountId ;
            goodwillPaymentObj.BillingContract__c = contractId ;
            goodwillPaymentObj.GoodwillType__c = type ;
            goodwillPaymentObj.PaymentMethod__c =  type == PyAp_Constants.REFUND ? PyAp_Constants.DIRECTCREDIT : '';   //AT-3189 
            goodwillPaymentObj.BankAccountDetail__c = bankAccountDetailId ;
            if(goodwillPaymentObj != null && goodwillPaymentObj.Amount__c != null)
                goodwillPaymentObj.Amount__c = -goodwillPaymentObj.Amount__c ;
            goodwillPaymentObj.RefundStatus__c = PyAp_Constants.REQUESTED_REFUND_STATUS ;
            //Changes by Dependra Singh - Security Review
            Payment__c objPayment = (Payment__c)GlUt_FieldSecurity.cleanseFields(goodwillPaymentObj, false);
            if(objPayment != null)
                Database.insert(objPayment) ;
        } catch(Exception ex) {
            GlUt_Logger.logException(ex) ;
            system.debug(DEBUG + ' Exception found=> ' + ex);
            throw new AuraHandledException(ex.getMessage()) ;
        }
        finally {
            GlUt_Logger.writeLogsToDatabase() ;
        }
    }
    
    /**********************************************************************************************
	@author      : Echo: Sudhir Kumar
	@date        : 22-June-2018   
	@params      : String accountId
	@return      : Account
	@description : This method returns Account object to LC
	**********************************************************************************************/   
    @AuraEnabled
    public static Account retrieveAccountInfo(String accountId) {
		try {
            Account accountObj ;
            if(!String.isBlank(accountId))
				accountObj = (Account) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsAccount.ACCOUNTAPINAME, (Id) accountId, paymentAccountFields);
			return accountObj;

		 } catch (exception e) {
             GlUt_Logger.logException(e);
			 throw new AuraHandledException(e.getMessage());
	    }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /**********************************************************************************************
	@author      : Echo: Sudhir Kumar
	@date        : 22-June-2018   retrieveAccountInfo
	@params      : 
	@return      : GLAp_FieldProps
	@description : This method returns payments account related fields prop
	**********************************************************************************************/   
    @AuraEnabled
    public static GLAp_FieldProps retrieveAccountFields() {
		try {
			List<GLAp_FieldProps>  fieldProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsAccount.ACCOUNTAPINAME, paymentAccountFields);
			return fieldProps[0];

		 } catch (exception e) {
             GlUt_Logger.logException(e);
			 throw new AuraHandledException(e.getMessage());
	    }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /**********************************************************************************************
	@author      : Echo: Sudhir Kumar
	@date        : 21-June-2018 
	@params      : 
	@return      : List<List<GLAp_FieldProps>>
	@description : This method returns goodwill payments related fields as List 
	**********************************************************************************************/   
    @AuraEnabled
    public static List<List<GLAp_FieldProps>> retrieveGoodwillPaymentFields() {
		try {
			List<List<GlAp_FieldProps>>  twoColFormattedList = 
                		GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetNameFor2ColForm(PyAp_Constants.PAYMENTAPINAME, GlUt_NamespacePrefix.getNamespacePrefix() + System.Label.PyAp_GoodwillPaymentFieldSet);
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
	@author      : Echo: Sudhir Kumar
	@date        : 25-June-2018
	@params      : String paymentType
	@return      : List<List<GLAp_FieldProps>>
	@description : This method returns BankAccountFields on payment
	**********************************************************************************************/   
   @AuraEnabled
    public static List<List<GLAp_FieldProps>> retrieveBankAccountFields(String paymentType) {
		try {
			List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
			List<GLAp_FieldProps> payProps = new List<GLAp_FieldProps>();
            //Security Review - 14-09-2018
			if(String.isNotBlank(paymentType) && paymentType == Label.PyAp_BankAccountDetail){
				payProps = GlAp_LightningDataAccess.getObjectsFieldProperties(PyAp_Constants.PAYMENTAPINAME, paymentBankAccFields);
			}
			//Changes by Dependra Singh - Security Review
			if(String.isNotBlank(paymentType) && paymentType == Label.PyAp_Cheque){
				payProps = GlAp_LightningDataAccess.getObjectsFieldProperties(PyAp_Constants.PAYMENTAPINAME, paymentChequeRefFields);
			}
			for(integer i=0; i < payProps.size(); i = i+2){
				List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
				integer secondEntryIndex = i+1;
				lstEntry.add(payProps[i]);
				
				if(secondEntryIndex < payProps.size()){
					lstEntry.add(payProps[secondEntryIndex]);   
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
    @author      : Echo: Vivek Sethi
    @date        : 11 Jan 2019
    @params      : void
    @return      : Boolean
    @description : This method checks the Bank Branch Records
    **********************************************************************************************/   
    @AuraEnabled
    public static Boolean checkBankBranchRecords() {
        try {
            //Validate Button Will only be visible if there is at least one record in Bank Branch object. 
            return PyAp_BranchCodeUtility.checkBankBranchRecords();
        } catch (exception e) {
            GlUt_Logger.logException(e);
            system.debug(DEBUG + 'e.getMessage(): ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }	
    
    /**********************************************************************************************
    @author      : Echo: Vivek Sethi
    @date        : 11 Jan 2019
    @params      : void
    @return      : Boolean
    @description : This method checks the entered Bank Branch Records
    **********************************************************************************************/   
    @AuraEnabled
    public static BankBranch__c validateSortCodeEntered(String sortCode) {
        try {
            if(!String.isBlank(sortCode)) {
                BankBranch__c bankBranch = PyAp_BranchCodeUtility.validateSortCodeEntered(sortCode);
                if(bankBranch != null)
                    return bankBranch;
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return null;		
    }	
    
    /**********************************************************************************************
    @author      : Echo: Vivek Sethi
    @date        : 11-Jan-2019
    @params      : 
    @return      : List<List<GLAp_FieldProps>>
    @description : This method returns back device , device type and reading related fields as List 
    **********************************************************************************************/   
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrieveBankBranchFields() {
        try {
            
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            List<GLAp_FieldProps> bankBranchFields = new List<GLAp_FieldProps>();
            bankBranchFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsBankBranch.BANKBRANCHAPINAME, bankBranchListFields);
            
            for(GLAp_FieldProps bankProp: bankBranchFields){
                bankProp.showLabel = true;
                bankProp.isEditable = false;
            }
            
            for(integer i=0; i < bankBranchFields.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(bankBranchFields[i]);
                
                if(secondEntryIndex < bankBranchFields.size()){
                    lstEntry.add(bankBranchFields[secondEntryIndex]);   
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
}