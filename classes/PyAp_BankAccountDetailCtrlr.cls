/******************************************************************************
@author         Echo: Dependra Singh
@date           22 June 2018
@description    Component controller for PyAp_BankAccountDetailPage lightning component.
*******************************************************************************/
public with sharing class PyAp_BankAccountDetailCtrlr {
    private static final String CLASS_NAME = 'PyAp_BankAccountDetailCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    
	// List of bank related field's string(Related to payment object).
    public static List<String> bankAccountDetailsFields = new List<String>{
					GlUt_APIConstantsBankAccountDetails.NAMEONACCOUNTAPINAME, 
					GlUt_APIConstantsBankAccountDetails.ACCOUNTNUMBERAPINAME, 
					GlUt_APIConstantsBankAccountDetails.BANKACCOUNTSORTCODEAPINAME
		        };
	//List of contract related field's string     
    public static List<String> contractListFields = new List<String>{
		        GlUt_APIConstantsContracts.CUSTOMERAPINAME,
		        GlUt_APIConstantsContracts.STATUSAPINAME
		        }; 
    // List of account related field's string.      
    public static List<String> accountFields = new List<String>{
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
	@author      : Echo: Dependra
	@date        : 22 June 2018
	@params      : String
	@return      : String
	@description : This method returns bank account details fields.
	**********************************************************************************************/
	@AuraEnabled
	public static List<List<GLAp_FieldProps>> retrieveBankAccountDetailsFields() {
        try {
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            List<GLAp_FieldProps> payProps = new List<GLAp_FieldProps>();
            List<GLAp_FieldProps> payPropsClone = new List<GLAp_FieldProps>();
            payProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsBankAccountDetails.BANKACCOUNTDETAILSAPINAME, bankAccountDetailsFields);
            system.debug('payProps  '   + payProps);
            for(GLAp_FieldProps objFieldProp : payProps){
                if(objFieldProp.fieldName == GlUt_APIConstantsBankAccountDetails.NAMEONACCOUNTAPINAME){
                    objFieldProp.fieldType = PyAp_Constants.FIELDTYPETEXT;
                }
                if(objFieldProp.fieldName == GlUt_APIConstantsBankAccountDetails.ACCOUNTNUMBERAPINAME){
                    objFieldProp.fieldType = PyAp_Constants.FIELDTYPETEXT;
                }
                if(objFieldProp.fieldName == GlUt_APIConstantsBankAccountDetails.BANKACCOUNTSORTCODEAPINAME){
                    objFieldProp.fieldType = PyAp_Constants.FIELDTYPETEXT;
                }
                payPropsClone.add(objFieldProp);
            
            }
            system.debug('payPropsClone  '   + payPropsClone);
            for(integer i=0; i < payPropsClone.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                
                integer secondEntryIndex = i+1;
                lstEntry.add(payPropsClone[i]);
                
                if(secondEntryIndex < payPropsClone.size()){
                    lstEntry.add(payPropsClone[secondEntryIndex]);   
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
    @author      : Echo: Dependra
    @date        : 22 June 2018
    @params      : String
    @return      : Account
    @description : This method returns the existing account which exist on contract.
    **********************************************************************************************/   
    @AuraEnabled
    public static Account getExistingAccount(String selectedContractId) {
        
        Account account;
        try {
            if (String.isNotBlank(selectedContractId)) {
                BillingContract__c contract = (BillingContract__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsContracts.CONTRACTAPINAME, 
                                                                                                      selectedContractId, 
                                                                                                      contractListFields);
                if (contract.AccountName__c != null) {
                    // Get account using account id.
                    account = (Account) GlAp_LightningDataAccess.getRecord(CuAp_Constants.ACCOUNTAPINAME, 
                                                                           contract.AccountName__c, 
                                                                           accountFields);
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