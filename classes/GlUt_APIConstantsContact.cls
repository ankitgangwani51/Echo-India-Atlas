/************************************************************************************************************
@author         Echo : Mohit Tayal
@date           08-Mar-2018
@description:   This is the constants class for all static fields used in the contact object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsContact {

    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Contact Object API Name
    public static String  LOCATIONAPINAME = NAMESPACEPREFIX + 'Contact__c';
    public static final String CONTACTAPINAME     = 'Contact' ;
    //Custom Fields
    public static final String CONSALUTATION       = 'Salutation';
    public static final String RECORDTYPEID        ='RecordTypeId' ;
    public static final String CONFIRSTNAME        = 'FirstName';
    public static final String CONLASTNAME         = 'LastName';
    public static final String CONACCID            = 'AccountId';
    public static final String CONMOBILE           = 'MobilePhone';
    public static final String CONEMAIL            = 'Email';
    // public static String LANGUAGESAPINAME  = NAMESPACEPREFIX + 'Languages__c'; // AT-3174
}