/******************************************************************************
@author         Neha R. 
@date           17 July 2018
@description    Component controller for Select Contract Bill Message wizard page
@revision       This is the constants class for all static fields used in the Bill Message object
*******************************************************************************/

public class GlUt_APIConstantsContractBillMessage {
    
	// Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();  
    
    // Bill Message Object API Name
    public static String  CONTRACTBILLMESSAGEAPINAME = NAMESPACEPREFIX + 'ContractBillMessage__c';
    
    // Bill Message object fields API Names 
    public static final String CONTRACTBILLMESSAGEID  = 'Id';
    public static final String NAMEAPINAME 			  = 'Name';
    public static final String ACTIVEAPINAME 	      = NAMESPACEPREFIX + 'Active__c';
    public static final String BILLMESSAGEAPINAME 	  = NAMESPACEPREFIX + 'BillMessage__c';
    public static final String BILLINGCONTRACTAPINAME = NAMESPACEPREFIX + 'BillingContract__c';
   
}