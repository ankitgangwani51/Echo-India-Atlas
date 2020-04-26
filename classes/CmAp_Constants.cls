/************************************************************************************************************
@author         Echo : Vivek
@date           10-April-2018
@description:   This is the constants class for all static strings used in this namespace
**************************************************************************************************************/
public class CmAp_Constants {
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    public static String AMTALLOCATEDLABEL  = 'Amount Paid Off';
    public static String BILLIMAGELABEL     = 'Bill Image';
    public static String CUSTOMURLLABEL     = 'Preview Bill';
    public static Boolean TRUEVALUE		    = True ;
    public static String ACTIVEVALUE		= 'Active' ;
    public static String TEXT		        = 'Text' ;
    
    public static String BILLINGADDRESS		  = 'BillingAddress' ;
    public static String BILLINGADDRESSLABEL  = 'Billing Address' ;
    public static String SHIPPINGADDRESS	  = 'ShippingAddress' ;
    public static String SHIPPINGADDRESSLABEL = 'Shipping Address' ;
    public static String MYPAYMENTSFIELDSET	       = NAMESPACEPREFIX + 'CmAp_PymtDateAmtFieldSet';
    public static String HHACCINFOFIELDSET	       = NAMESPACEPREFIX + 'CmAp_HHAccounInfo';
    public static String NHHACCINFOFIELDSET	       = NAMESPACEPREFIX + 'CmAp_NHHAccounInfo';
    public static String ACCADDRESSFIELDSET	       = NAMESPACEPREFIX + 'CmAp_AccountAddressFieldSet';
    public static String CONTACTINFOFIELDSET	   = NAMESPACEPREFIX + 'CmAp_ContactInformationFieldSet';
    public static String ACCSICFIELDSET	           = NAMESPACEPREFIX + 'CmAp_AccountSicFieldSet';
    public static String CONSIDERATIONFIELDSET	   = NAMESPACEPREFIX + 'CmAp_ConsiderationFieldSet';
    public static String HHADDITIONALINFOFIELDSET  = NAMESPACEPREFIX + 'CmAp_HHAdditionalInfoFieldSet';
    public static String NHHADDITIONALINFOFIELDSET = NAMESPACEPREFIX + 'CmAp_NHHAdditionalInfoFieldSet';
}