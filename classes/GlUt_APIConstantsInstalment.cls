public class GlUt_APIConstantsInstalment {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Instalment Object API Name
    public static String  INSTALMENTAPINAME = NAMESPACEPREFIX + 'Instalment__c';
    
    // Instalment object fields API Names
	public static String INSTALMENTAMOUNTDUEAPINAME	= NAMESPACEPREFIX + 'InstalmentAmountDue__c';
    public static String INSTALMENTDUEDATEAPINAME	= NAMESPACEPREFIX + 'InstalmentDueDate__c';
    public static String INSTALMENTNUMBERAPINAME    = NAMESPACEPREFIX + 'InstalmentNumber__c';
    public static String INSTALMENTTYPEAPINAME 		= NAMESPACEPREFIX + 'Type__c';
    public static String DEBTRECOVERYINSTALMENTCOUNT 		= NAMESPACEPREFIX + 'DebtRecoveryInstalments__c';
    
    public static String NAMEAPINAME 		= 'Name';
    public static String PAYMENTPLANAPINAME 		= NAMESPACEPREFIX + 'PaymentPlan__c';
    public static String INSTALMENTAMOUNTOUTSTANDING = NAMESPACEPREFIX + 'InstalmentAmountOutstanding__c';
    
    // Instalment Object Fields Relational API Names
    public static String INSTALMENTRELAPINAME	= NAMESPACEPREFIX + 'Instalment__r';
    public static String CONTRACTORDERRELAPINAME = NAMESPACEPREFIX + 'PaymentPlan__r.'+ NAMESPACEPREFIX + 'BillingContract__c';  //AT-3174

    

}