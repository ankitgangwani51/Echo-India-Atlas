/************************************************************************************************************
@author         Echo : Vivek Sethi.
@date           11-Jan-2019
@description:   This is the constants class for all static fields used in the Bank Branch object                
**************************************************************************************************************/
public class GlUt_APIConstantsBankBranch {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Bank Branch Action Object API Name
    public static String  BANKBRANCHAPINAME = NAMESPACEPREFIX + 'BankBranch__c';
    
    // Bank Branch Action object fields API Names
    public static String  BRANCHCODEAPINAME =  'Name';
    public static String  BRANCHNAMEAPINAME = NAMESPACEPREFIX + 'BranchName__c';
    public static String  FICODEAPINAME = NAMESPACEPREFIX + 'FICode__c';
    public static String  POSTCODEAPINAME = NAMESPACEPREFIX + 'Postcode__c';
    public static String  TOWNCITYAPINAME = NAMESPACEPREFIX + 'TownCity__c';
    public static String  STATEAPINAME = NAMESPACEPREFIX + 'State__c';
    public static String  BRANCHADDRESSAPINAME = NAMESPACEPREFIX + 'BranchAddress__c';
 
}