/******************************************************************************
@author         Echo: Dependra Singh
@date           22 Jan 2018
@description    Component controller for Refund/Transfer Credit lightning component.
*******************************************************************************/
public with sharing class PyAp_RefundTransferCreditPageCtrlr {
	
    private static final String CLASS_NAME = 'PyAp_RefundTransferCreditPageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
     // List of bank related field's string(Related to payment object).
    private static final List<String> payBankAccFields = new List<String>{
		        GlUt_APIConstantsPayments.REFUNDACCOUNTAPINAME, 
		        GlUt_APIConstantsPayments.BANKACCOUNTNOAPINAME,
                GlUt_APIConstantsPayments.BANKACCSORTCODEAPINAME
		        };
		        
   // List of cheque related field's string(Related to payment object).
    private static final List<String> payChequeRefFields = new List<String>{
		        GlUt_APIConstantsPayments.REFUNDADDRESSAPINAME,
		        GlUt_APIConstantsPayments.REFUNDREFRENCEAPINAME                                                    
		        };       
		    
     // AT-4154, 05 Dec 2018, Added Billing Address field to auto populate in the Refund Address field
     // List of account related field's string.      
    private static final List<String> accountFields = new List<String>{
        		PyAp_Constants.NAME,
            	GlUt_APIConstantsAccount.BILLINGSTREETAPINAME,
                GlUt_APIConstantsAccount.BILLINGCITYAPINAME,
                GlUt_APIConstantsAccount.BILLINGSTATEAPINAME,
                GlUt_APIConstantsAccount.BILLINGCOUNTRYAPINAME,
                GlUt_APIConstantsAccount.BILLINGPOSTALCODEAPINAME                
		        };   
		        
    //List of contract related field's string     
    private static final List<String> contractListFields = new List<String>{
		        GlUt_APIConstantsContracts.CUSTOMERAPINAME,
		        GlUt_APIConstantsContracts.STATUSAPINAME,
		        GlUt_APIConstantsContracts.BALANCEAPINAME
		        }; 
		        
    //List of contract's field related to balance.
    private static final List<String> contractListFieldsForBalance = new List<String>{
				GlUt_APIConstantsContracts.BALANCEAPINAME
		        };  
		        
    //  List of balance related field's string
    private static final List<String> balanceFieldList = new List<String>{
				GlUt_APIConstantsBalances.BALANCEAMOUNTAPINAME,
				GlUt_APIConstantsBalances.TOTALREFUNDAMOUNTAPINAME
				};        
                    
    //List of Bank Branch field's string     
    private static List<String> bankBranchListFields = new List<String>{
         	 GlUt_APIConstantsbankBranch.FICODEAPINAME,
             GlUt_APIConstantsbankBranch.STATEAPINAME,
             GlUt_APIConstantsbankBranch.BRANCHADDRESSAPINAME,
             GlUt_APIConstantsbankBranch.POSTCODEAPINAME,
             GlUt_APIConstantsbankBranch.TOWNCITYAPINAME
  		        };   
	/**********************************************************************************************
	@author      : Echo: Dependra
	@date        : 22-Jan-2018
	@params      : String
	@return      : List<List<GLAp_FieldProps>>
	@description : This method returns payments back related fields as List 
	**********************************************************************************************/   
    public static List<List<GLAp_FieldProps>> retrieveBankAccountFields(String strPaymentTypeFields) {
		try {
			List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
			List<GLAp_FieldProps> payProps = new List<GLAp_FieldProps>();
			if(String.isNotBlank(strPaymentTypeFields) && strPaymentTypeFields == PyAp_Constants.BANKACCOUNTDETAILS){
				payProps = GlAp_LightningDataAccess.getObjectsFieldProperties(PyAp_Constants.PAYMENTAPINAME, payBankAccFields);
			}
			if(String.isNotBlank(strPaymentTypeFields) && strPaymentTypeFields == PyAp_Constants.CHEQUEDETAILS){
				payProps = GlAp_LightningDataAccess.getObjectsFieldProperties(PyAp_Constants.PAYMENTAPINAME, payChequeRefFields);
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
		     system.debug('e.getMessage()====='+ e.getMessage());
			 throw new AuraHandledException(e.getMessage());
	    }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /**********************************************************************************************
	@author      : Echo: Dependra
	@date        : 25-Jan-2018
	@params      : String
	@return      : Account
	@description : This method returns theExisting account which exist on contract
	**********************************************************************************************/   
    public static Account getExistingAccount(String selectedContractId) {
        
        Account account;
        try {
            if (String.isNotBlank(selectedContractId)) {
                BillingContract__c contract = (BillingContract__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsContracts.CONTRACTAPINAME,selectedContractId,contractListFields);
                if (contract.AccountName__c != null) {
                    // Get account using account id.
                    account = (Account) GlAp_LightningDataAccess.getRecord(CuAp_Constants.ACCOUNTAPINAME, contract.AccountName__c, accountFields);
                }
            }
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            system.debug(DEBUG + 'e.getMessage(): ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return account;		
    }
    
    /**********************************************************************************************
	@author      : Echo: Dependra
	@date        : 29 Nov 2018
	@params      : string strPaymentTypeBank, string strPaymentTypeCheque, string selectedContractId
	@return      : WapperScreenData
	@description : This method used to return screen info
	**********************************************************************************************/   
    @AuraEnabled
    public static WapperScreenData getScreenInfo(string strPaymentTypeBank, string strPaymentTypeCheque, string selectedContractId){
        WapperScreenData objWrapper = new WapperScreenData();
        if(string.isNotBlank(strPaymentTypeBank)){
            objWrapper.lstFieldPropBank = retrieveBankAccountFields(strPaymentTypeBank);
        }
        if(string.isNotBlank(strPaymentTypeCheque)){
            objWrapper.lstFieldPropCheque = retrieveBankAccountFields(strPaymentTypeCheque);
        }
        if(string.isNotBlank(selectedContractId)){
            objWrapper.objAccount = getExistingAccount(selectedContractId);
        }
        objWrapper.isBranchCode =  checkBankBranchRecords();
        return objWrapper;
    }
   /**********************************************************************************************
	@author      : Echo: Dependra
	@date        : 29 Nov 2018
	@description : This Class is used to pass data in lightning component.
	**********************************************************************************************/   
    public class WapperScreenData {
        @AuraEnabled
        public Account objAccount{get;set;}
        @AuraEnabled
        public List<List<GLAp_FieldProps>> lstFieldPropBank{get;set;}
        @AuraEnabled
        public List<List<GLAp_FieldProps>> lstFieldPropCheque{get;set;}
        @AuraEnabled
        public boolean isBranchCode {get;set;}
        public WapperScreenData(){
            objAccount = new Account();
            lstFieldPropBank = new List<List<GLAp_FieldProps>>();
            lstFieldPropCheque = new List<List<GLAp_FieldProps>>(); 
            isBranchCode = false;
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