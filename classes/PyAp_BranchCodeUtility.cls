/**********************************************************************************************
@author      : Echo: Vivek Sethi
@date        : 11 Jan 2019
@params      : void
@return      : 
@description : Utillty to vaidate Branch/Sort Code
**********************************************************************************************/   

public with sharing  class PyAp_BranchCodeUtility {
    
    //List of Bank Branch field's string     
    public static List<String> bankBranchListFields = new List<String>{
        GlUt_APIConstantsbankBranch.FICODEAPINAME,
        GlUt_APIConstantsbankBranch.STATEAPINAME,
        GlUt_APIConstantsbankBranch.BRANCHADDRESSAPINAME,
        GlUt_APIConstantsbankBranch.POSTCODEAPINAME,
        GlUt_APIConstantsbankBranch.TOWNCITYAPINAME
     };  
                
    /**********************************************************************************************
    @author      : Echo: Vivek Sethi
    @date        : 11 Jan 2019
    @params      : void
    @return      : Boolean
    @description : This method checks the Bank Branch Records
    **********************************************************************************************/   
                
    public static Boolean checkBankBranchRecords() {
        List<BankBranch__c> bankBranchList = [Select Id from BankBranch__c limit 1];
        bankBranchList = (List<BankBranch__c>) GlUt_FieldSecurity.cleanseFields(bankBranchList, false);
        if(bankBranchList != null && !bankBranchList.isEmpty())
            return true;
        
        return false;		
    }	
    
    /**********************************************************************************************
	@author      : Echo: Vivek Sethi
	@date        : 11 Jan 2019
	@params      : void
	@return      : Boolean
	@description : This method checks the entered Bank Branch Records
	**********************************************************************************************/   	
    public static BankBranch__c validateSortCodeEntered(String sortCode) {
        List<BankBranch__c> bankBranchList = new List<BankBranch__c>();
        if(!String.isBlank(sortCode)) {
            String filterStatements = String.format(' WHERE {0} = {1}', new List<String>{GlUt_APIConstantsBankBranch.BRANCHCODEAPINAME,'\'' + String.escapeSingleQuotes(sortCode) + '\''});
            bankBranchList = (List<BankBranch__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBankBranch.BANKBRANCHAPINAME, 
                                                                                       bankBranchListFields, 
                                                                                       filterStatements);
            
            if(bankBranchList != null && !bankBranchList.isEmpty())
                return bankBranchList[0];
        }
        return null;		
    }
}