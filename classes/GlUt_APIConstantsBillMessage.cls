/******************************************************************************
@author         Neha R. 
@date           17 July 2018
@description    Component controller for Select Bill Message wizard page
@revision       This is the constants class for all static fields used in the Bill Message object
*******************************************************************************/
public class GlUt_APIConstantsBillMessage {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();  
    
    // Bill Message Object API Name
    public static String  BILLMESSAGEAPINAME = NAMESPACEPREFIX + 'BillMessage__c';
    
    // Bill Message object fields API Names 
    public static final String BILLMESSAGEID  		 = 'Id';
    public static final String NAMEAPINAME 			 = 'Name';
    public static final String MESSAGETEXTAPINAME 	 = NAMESPACEPREFIX + 'MessageText__c';
    
}