/*****************************************************************************************************************************
@author         Echo: Sudhir Kumar
@date           25 Jan 2019
@description    AT-4767, AT-5049, AT-5050: Constants class for LocationImport
******************************************************************************************************************************/
public class GlUt_APIConstantsLocationImport {
	// Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix() ; 
        
    
    // Object API Name
    public static String LOCATION_UPLOAD_APINAME = NAMESPACEPREFIX + 'LocationUpload__c' ;	//Verify
    public static String BRQAPINAME 						= NAMESPACEPREFIX + 'BatchRequestQueue__c' ;
    public static String BATCHERRORAPINAME 					= NAMESPACEPREFIX + 'BatchError__c' ;
    
    public static String CITY_APINAME 						= NAMESPACEPREFIX + 'City__c' ;
    public static String POSTAL_CODE_APINAME 				= NAMESPACEPREFIX + 'PostalCode__c' ;
    public static String STATE_APINAME 						= NAMESPACEPREFIX + 'State__c' ;
    public static String STREET_APINAME 					= NAMESPACEPREFIX + 'Street__c' ;
    public static String LOCATION_TYPE_APINAME 				= NAMESPACEPREFIX + 'LocationType__c' ;
    public static String SUPPLYPOINT_TYPE_APINAME 			= NAMESPACEPREFIX + 'SupplyPointType__c' ;
    public static String BUILDDATE_APINAME 					= NAMESPACEPREFIX + 'BuildDate__c' ;
    public static String SUPPLY_POINT_USAGE_TYPE_APINAME 	= NAMESPACEPREFIX + 'SupplyPointUsageType__c' ;
    public static String VOID_PROFILE_APINAME 				= NAMESPACEPREFIX + 'VoidProfile__c' ;
    public static String COUNTRY_APINAME 					= NAMESPACEPREFIX + 'Country__c' ; 
    public static String LOCATION_SUB_TYPE_APINAME 			= NAMESPACEPREFIX + 'LocationSubType__c' ;
    
    public static String SERVICE_TYPE1_APINAME 				= NAMESPACEPREFIX + 'ServiceType1__c' ;
    public static String SERVICE_TYPE2_APINAME 				= NAMESPACEPREFIX + 'ServiceType2__c' ;
    public static String DIVISION_SERVICE_1_APINAME 		= NAMESPACEPREFIX + 'DivisionService1__c' ;
    public static String DIVISION_SERVICE_2_APINAME 		= NAMESPACEPREFIX + 'DivisionService2__c' ;
    public static String WHOLESALER_SERVICE_1_APINAME 		= NAMESPACEPREFIX + 'WholesalerService1__c' ;
    public static String WHOLESALER_SERVICE_2_APINAME 		= NAMESPACEPREFIX + 'WholesalerService2__c' ;
    public static String PROCESSED_APINAME 					= NAMESPACEPREFIX + 'Processed__c' ;
    
    public static String SPECIAL_INSTRUCTIONS_APINAME 		= NAMESPACEPREFIX + 'SpecialInstructions__c' ; 
    public static String SERVICE_1_AVAILABLEBUNDLE_APINAME 	= NAMESPACEPREFIX + 'Service1AvailableBundle__c' ; 
    public static String SERVICE_2_AVAILABLEBUNDLE_APINAME 	= NAMESPACEPREFIX + 'Service2AvailableBundle__c' ; 
    public static String GEOLOCATION_LATITUDE_APINAME 		= NAMESPACEPREFIX + 'Geolocation__latitude__s' ; 
    public static String GEOLOCATION_LONGITUDE_APINAME 		= NAMESPACEPREFIX + 'Geolocation__longitude__s' ; 
}