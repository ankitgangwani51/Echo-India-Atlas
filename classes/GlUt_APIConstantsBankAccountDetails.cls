/******************************************************************************
@author         Echo: Dependra Singh
@date           25 June 2018
@description    This is the constants class for all static fields used in the Bank Account Detail object   
*******************************************************************************/
public class GlUt_APIConstantsBankAccountDetails {
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Object API Name
    public static String  BANKACCOUNTDETAILSAPINAME = NAMESPACEPREFIX + 'BankAccountDetails__c';
    //  Bank Account Detail object fields API Names
    public static final string  ID = 'Id';
    public static final string  NAME = 'Name';
    public static final string  ACCOUNTAPINAME = NAMESPACEPREFIX + 'Account__c';
	public static final string  NAMEONACCOUNTAPINAME = NAMESPACEPREFIX + 'NameOnAccount__c';
	public static final string  ACCOUNTNUMBERAPINAME = NAMESPACEPREFIX + 'BankAccountNumber__c';
	public static final string  BANKACCOUNTSORTCODEAPINAME = NAMESPACEPREFIX + 'BankAccountSortCode__c';
}