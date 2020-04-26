/**********************************************************************************************
@author         Echo : Sudhir Kumar
@date           20-Nov-2018
@description:   AT-4125 (AU1) : Test class for LoAp_InfoStatementCalculateChargesCtrlr

**********************************************************************************************/
@isTest
private class LoAp_InfoStatementCalculateCharges_Test {
	private static final String USER_PROFILE        	= 'System Administrator' ;
    private static final String USER_NAME           	= 'InfoStatementTestUser' ;
    private static final String USERNAMECOMPLETE   		=  USER_NAME + '@unitest.com' ;
    private static final String ACCOUNT_NAME        	= 'TestAccount' ;
    private static final String FIRST_NAME          	= 'TestFirstName' ;
    private static final String LAST_NAME          		= 'TestLastName' ;
	private static final String CONTRACT_NAME 			= 'Test_Contract';
	private static final String AVAIL_SERVICE_ITEM 		= 'AvailableServiceItem_Test';
	private static final String BUNDLE_ITEM 			= 'Test_BundleItem';
	private static final String BUNDLE_NAME 			= 'Bundle_Test';
	private static final String SERVICE_TYPE 			= 'Service_Type';    
	private static final String SERVICE_ITEM_FAMILY 	= 'Service_Item_Family';
	private static final String SERVICE_ITEM_TYPE 		= 'Service_Item_Type';
	private static final String WHOLESALER 				= 'abc';
	private static final String DEVICE_TYPE 			= 'small Meter';
	private static final String AVAILABLE_BUNDLE 		= 'AvailableBundle';
	private static final String AVAIL_SERVICE 			= 'WATER';
	private static final String ZIPCODE1 				= 'WS2 8DE';	
    private static final String ZIPCODE2 				= 'SK8 9PK';	
    private static final String ZIPCODE3 				= 'SK8 3PK';	
	private static final String	DEVICE_NAME 			= 'Meter';		
	private static final String MEASURED 				= 'Yes';
	private static final String READFREQUENCY 			= 'Monthly';
	private static final String SP_USAGE_TYPE 			= 'SupplyPointUsageType';
	private static final String DEVICE_SIZE 			= 'TestDeviceSize';
	private static final String MANUFACTURER 			= 'Siemens';
	private static final String UNIT_OF_MEASURE 		= 'Metric';
    private static final String XSLT_DOCUMENT			= 'Test XSLT Document' ;
    private static final String PDF_TEMPLATE			= 'Test PDF Template' ;
    private static final String AUTHENTICATION_TOKEN	= 'TestAuthenticationToken' ;
    private static final String CALCULATECHARGES_MOCK_POSITIVE_RESPONSE	= 'LoAp_InfoStatementCalculateChargesHttpMockResponse_Positive' ;
    private static final String CALCULATECHARGES_MOCK_NEGATIVE_RESPONSE	= 'LoAp_InfoStatementCalculateChargesHttpMockResponse_Negative' ;
    /*******************************************************************
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    @TestSetup
    static void createTestData() {
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USER_NAME, null);
        Database.insert(objUser); 
		System.runAs(objUser) {
            //Create account
            Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
            Database.insert(objAccount);
             // Create ServiceType Record            
            ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(SERVICE_TYPE);
            Database.insert(objServiceType);
            // Create ServiceItemFamily Record            
            ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICE_ITEM_FAMILY, objServiceType);
            Database.insert(objServiceItemFamily);
            // Create Division Record            
            Division__c objDivision = GlUt_FactoryData_Test.createDivision();
            Database.insert(objDivision);        
            // Create Wholesaler Record            
            Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
            Database.insert(objWholesaler);    
            // Create Device Size Record 
            DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
            Database.insert(objDeviceSize);
            // Create Device Type Record
            DeviceType__c  objDeviceType1 = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
            DeviceType__c  objDeviceType2 = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
            Database.insert(new list<DeviceType__c> {objDeviceType1, objDeviceType2});
            // Create ServiceItemType Record            
            ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICE_ITEM_FAMILY, objServiceItemFamily, objDivision, objDeviceType1, objWholesaler);
            Database.insert(objServiceItemType);
            
            // Create Bundle Record            
            Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE_NAME, objServiceType);
            Database.insert(objBundle);
            // Create BundleItem Record            
            BundleItem__c objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLE_ITEM, objBundle, objServiceItemType, objServiceItemFamily);
            Database.insert(objBundleItem);	
            // Create Location Record            
            Location__c objLocation1 = GlUt_FactoryData_Test.createLocation(ZIPCODE1);
            Location__c objLocation2 = GlUt_FactoryData_Test.createLocation(ZIPCODE2);
            Location__c objLocation3 = GlUt_FactoryData_Test.createLocation(ZIPCODE3);
            Database.insert(new list<Location__c> {objLocation1, objLocation2, objLocation3});
            //Create Location Occupant
            LocationOccupant__c objLocationOccupant = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation1);
            Database.insert(objLocationOccupant);
            //Create Supply Point Usage Type Record
            SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
            Database.insert(objSupplyPointUsageType);
            // Create SupplyPoint Record            
            SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation1, objSupplyPointUsageType);
            objSupplyPoint.Measured__c = True; 
            Database.insert(objSupplyPoint);
            // Create AvailableService Record            
            AvailableService__c objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAIL_SERVICE, objDivision, objServiceType, objSupplyPoint, objWholesaler );
            Database.insert(objAvailableService);		
            // Create AvailableBundle Record            
            AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAILABLE_BUNDLE, objBundle, objAvailableService );
            Database.insert(objAvailableBundle);		
            // Create AvailableServiceItem Record            
            AvailableServiceItem__c objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(AVAIL_SERVICE_ITEM, objBundleItem, objServiceItemType, objAvailableBundle);
            Database.insert(objAvailableServiceItem);
            // Create Contract Record            
            BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME, objAccount);
            Database.insert(objContract);
            // Create Device Record            
            Device__c objDevice1 = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType1);
            Device__c objDevice2= GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType2);
            Database.insert(new list<Device__c> {objDevice1, objDevice2}); 
            // Create Supply Point Device  
            SupplyPointDevice__c objSPD = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice1, objSupplyPoint) ;
            objSPD.InstallationDate__c  = System.today() - 1 ;
            Database.insert(objSPD); 
            // Create Reading Record            
            Reading__c objReading1 = GlUt_FactoryData_Test.createReading(objDevice1);
            Reading__c objReading2 = GlUt_FactoryData_Test.createReading(objDevice2);
            Database.insert(new list<Reading__c> {objReading1, objReading2});  
            // Create Service Record            
            Service__c objService = GlUt_FactoryData_Test.createService(objContract, objReading1, objServiceType, objSupplyPoint, objAvailableService);
            Database.insert(objService);  
            // Create Service Item   
            ServiceItem__c objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objService) ;
            objServiceItem.StartDate__c = Date.Today() ;
            objServiceItem.EndDate__c = Date.Today().addMonths(10) ;
            Database.insert(objServiceItem) ;
            //Create Template Mapping for Information Statement
            TemplateMapping__c templateObj = new TemplateMapping__c(PDFTemplate__c = PDF_TEMPLATE, XSLTDocument__c = XSLT_DOCUMENT) ;
			Database.insert(templateObj) ;            
            //Create Information Statement
            InformationStatement__c infoObj1 = new InformationStatement__c(BillingContract__c = objContract.Id, Location__c = objLocation1.Id, SettlementDate__c = System.today() + 5,
                                                                          Service__c = objService.Id, TemplateMapping__c = templateObj.Id) ;
            InformationStatement__c infoObj2 = new InformationStatement__c(BillingContract__c = objContract.Id, Location__c = objLocation2.Id, SettlementDate__c = System.today() + 10,
                                                                          Service__c = objService.Id) ; // without Template  TemplateMapping__c = templateObj.Id
            Database.insert(new list<InformationStatement__c> {infoObj1, infoObj2}) ;
            //Create Heroku Security
            HerokuSecurity__c objHerokuSecurity = GlUt_FactoryData_Test.createHerokuSecurity(AUTHENTICATION_TOKEN) ;
            Database.insert(objHerokuSecurity) ;
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           20 Nov 2018
    @description    positive test scenario for getInformationStatement method
    *******************************************************************************/ 
    static testmethod void getInformationStatement_Positive() {
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(objUser) {
            InformationStatement__c infoObj = [SELECT Id, Location__c, SettlementDate__c, Service__c, TemplateMapping__c FROM InformationStatement__c
                                               WHERE Location__r.PostalCode__c =: ZIPCODE1 LIMIT 1] ;
            system.assert(infoObj != null) ;
            LoAp_InfoStatementCalculateChargesCtrlr.getInformationStatement(infoObj.Id) ;
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           20 Nov 2018
    @description    negative test scenario for getInformationStatement method
    *******************************************************************************/ 
    static testmethod void getInformationStatement_Negative() {
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(objUser) {
            Boolean isException = false ;
            try {
                InformationStatement__c infoObj2 = [SELECT Id, Location__c, SettlementDate__c, Service__c, TemplateMapping__c FROM InformationStatement__c
                                               WHERE Location__r.PostalCode__c =: ZIPCODE3 LIMIT 1] ;
                LoAp_InfoStatementCalculateChargesCtrlr.getInformationStatement(infoObj2.Id) ;
            } catch(Exception ex) {
                isException = true ;
            }
            system.assert(isException) ;
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           20 Nov 2018
    @description    positive test scenario for calculateCharges method
    *******************************************************************************/ 
    static testmethod void calculateCharges_Positive() {
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1] ;
        InformationStatement__c infoObj = [SELECT Id, Location__c, SettlementDate__c, Service__c, TemplateMapping__c FROM InformationStatement__c
                                               WHERE Location__r.PostalCode__c =: ZIPCODE1 LIMIT 1] ;
        system.runAs(objUser) {
            Boolean isException = false ;
            try {
                Test.startTest() ;
                Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(CALCULATECHARGES_MOCK_POSITIVE_RESPONSE));
                LoAp_InfoStatementCalculateChargesCtrlr.calculateCharges(infoObj.Id) ;
                Test.stopTest() ;
            } catch(Exception ex) {
                isException = true ;
                system.debug('Exception= ' + ex);
            }
            system.debug('isException= ' + isException);
            system.assert(!isException) ;
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           20 Nov 2018
    @description    negative test scenario for calculateCharges method
    *******************************************************************************/ 
    static testmethod void calculateCharges_Negative() {
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1] ;
        InformationStatement__c infoObj = [SELECT Id, Location__c, SettlementDate__c, Service__c, TemplateMapping__c FROM InformationStatement__c
                                               WHERE Location__r.PostalCode__c =: ZIPCODE2 LIMIT 1] ;
        system.runAs(objUser) {
            Boolean isException = false ;
            try {
                Test.startTest() ;
                Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(CALCULATECHARGES_MOCK_NEGATIVE_RESPONSE));
                LoAp_InfoStatementCalculateChargesCtrlr.calculateCharges(infoObj.Id) ;
            } catch(Exception ex) {
                isException = true ;
                system.debug('Exception= ' + ex);
            }
            system.debug('isException= ' + isException);
            InformationStatement__c infoStmt = [SELECT Id, CalculatedCharges__c FROM InformationStatement__c WHERE Id =: infoObj.Id  LIMIT 1] ;
            system.debug('infoStmt= ' + infoStmt);
            system.debug('infoStmt-CalculatedCharges= ' + infoStmt.CalculatedCharges__c);
            system.assert(infoStmt.CalculatedCharges__c == 0.00) ;
        }
    }
    
}