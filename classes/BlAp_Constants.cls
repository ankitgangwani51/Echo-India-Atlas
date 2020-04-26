/************************************************************************************************************
@author         Accenture : Luke Emberton
@date           09-Sep-2017
@description:   This is the constants class for all static strings used in this namespace
@revision:      07-Mar-2018 MT - Added the namespace prefix
**************************************************************************************************************/
public class BlAp_Constants {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    //The prefix for this namespace
    public static string PREFIX = 'BlAp_';
    
    public static string  CONTRACTAPINAME           = NAMESPACEPREFIX + 'BillingContract__c';
    public static string  SUPRESSIONAPINAME         = NAMESPACEPREFIX + 'Suppression__c';
    public static string  AGREEDRATESNAME           = NAMESPACEPREFIX + 'AgreedRate__c'; 
    public static string  SERVICEITEMNAME           = NAMESPACEPREFIX + 'ServiceItem__c';
    public static string  SUPPLYPOINTDEVICE         = NAMESPACEPREFIX + 'SupplyPointDevice__c';
    public static string  SUPPLYPOINT               = NAMESPACEPREFIX + 'SupplyPoint__c';   //Amit - Added on 30-Nov-2017
    public static string  DEVICE                    = NAMESPACEPREFIX + 'Device__c';   //Amit - Added on 30-Nov-2017
    public static string  READINGAPINAME            = NAMESPACEPREFIX + 'Reading__c';   //Amit - Added on 30-Nov-2017
    public static string  DEVICETYPEAPINAME         = NAMESPACEPREFIX + 'DeviceType__c';   //Amit - Added on 11-Dec-2017
    public static string  BILLITEMAPINAME           = NAMESPACEPREFIX + 'BillItem__c'; //Amit - Added on 18-Dec-2017
    public static string  SERVICEITEMFAMILYAPINAME  = NAMESPACEPREFIX + 'ServiceItemFamily__c'; //Amit - Added on 19-Dec-2017
    public static string  DISCOUNTTYPEAPINAME       = NAMESPACEPREFIX + 'DiscountType__c'; //Amit - Added on 11-Jan-2018
    public static final string DISCOUNTTYPEITEMAPI  = NAMESPACEPREFIX + 'DiscountTypeitem__c'; //Amit - Added on 12-Jan-2018

    //Added constant for BlAp_CombinedRecord 29/12/2017 - JIRA AT-427
    public static string  ADDCHECKBOX               = 'add-checkbox-';
    public static string  DOCUMENTNAME               = 'DocumentName';// Added by Dependra - 31-05-2018
    public static string  BILLLINK               = 'BillLink';// Added by Dependra - 31-05-2018
    
    
    public static final string INVALIDAPINAME  = NAMESPACEPREFIX + 'Invalid__c'; //Swati - Added on 21-08-2018
}