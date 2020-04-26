/*******************************************************************
@author:      ECHO: Sudhir Kumar
@date:        09-Apr-2018
@param:       N/A
@return:      void
@description: Test class for CmAp_MyMeterDetailsCtlr
********************************************************************/

@isTest
public class CmAp_MyMeterDetailsCtlr_Test {

    private static final String USER_PROFILE        	= 'System Administrator' ;
    private static final String USER_NAME           	= 'TestUser' ;
    private static final String PORTAL_USER_NAME    	= 'PortalTestUser' ;
    private static final String USERNAMECOMPLETE   		=  USER_NAME + '@unitest.com' ;
    private static final String PORTAL_USERNAMECOMPLETE =  PORTAL_USER_NAME + '@unitest.com' ;
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
	private static final String ZIPCODE 				= 'WS2 8DE';	
	private static final String	DEVICE_NAME 			= 'Meter';		
	private static final String MEASURED 				='Yes';
	private static final String READFREQUENCY 			='Monthly';
	private static final String SP_USAGE_TYPE 			= 'SupplyPointUsageType';
	private static final String DEVICE_SIZE 			= 'TestDeviceSize';
	private static final String MANUFACTURER 			= 'Siemens';
	private static final String UNIT_OF_MEASURE 		= 'Metric';
	
    @testSetup
    static void createTestdata() {
        //Create portal account owner
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile = [Select Id from Profile where name =: USER_PROFILE];
		User portalAccountOwner = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
		portalAccountOwner.UserRoleId = portalRole.Id ;
		Database.insert(portalAccountOwner);
        System.runAs(portalAccountOwner){
           Test.startTest();
           	testSetupData(portalAccountOwner.Id) ;
           Test.stopTest();           
        }
    }

   @future	// To prevent Mixed DML error
    static void testSetupData(Id portalAccountOwnerId) {
        //Create account
		Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
		objAccount.OwnerId = portalAccountOwnerId ;
        Database.insert(objAccount);
        
        //Create contact
		Contact objContact = GlUt_FactoryData_Test.createContact(FIRST_NAME, LAST_NAME);
		objContact.AccountId = objAccount.Id;
		Database.insert(objContact);
        
        //Create Community user
        User portalUser = GlUt_FactoryData_Test.createCommunityUser(objContact, PORTAL_USER_NAME);
        if(portalUser != null)
            Database.insert(portalUser);
		
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
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
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
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(ZIPCODE);
        Database.insert(objLocation);
		
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create SupplyPoint Record            
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; // AT-3174 
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
		
        
		
    }
   
    /*******************************************************************
    @author:      ECHO: Sudhir Kumar
    @date:        09-Apr-2018
    @param:       N/A
    @return:      void
    @description: Positive Test scenario for getUserMeterDetails
    ********************************************************************/
    static testmethod void getUserMeterDetails_PositiveTest() {
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        
        System.runAs(objUser){
            List<BlAp_CombinedRecord> listReading = CmAp_MyMeterDetailsCtlr.getUserMeterDetails();
            CmAp_MyMeterDetailsCtlr.retrieveReadingPropDetails() ;
            CmAp_MyMeterDetailsCtlr.retrieveDevicePropDetails() ;
            CmAp_MyMeterDetailsCtlr.retrieveNewReadingPropDetails() ;
			List<Reading__c> existingReadingList = [SELECT Id,Device__c, Device__r.DeviceType__c, ActualDeviceReading__c FROM Reading__c WHERE Device__r.DeviceType__r.DeviceSize__r.Name =: DEVICE_SIZE ORDER BY CreatedDate Desc] ;
			system.assert(!existingReadingList.isEmpty()) ;
            Decimal lastActualDeviceReading = Decimal.valueOf(existingReadingList[0].ActualDeviceReading__c)  ;
            system.assert(existingReadingList[0].ActualDeviceReading__c != null) ;
            system.assert(existingReadingList[0].Device__c != null) ; //AT-3174
            system.assert(existingReadingList[0].Device__r.DeviceType__c != null) ; //AT-3174
            Decimal newDeviceReading = Decimal.valueOf(existingReadingList[0].ActualDeviceReading__c) + 10 ;
            String readingDate = String.valueOf(System.today()) ;
            CmAp_MyMeterDetailsCtlr.submitMyReading(existingReadingList[0].Device__c, newDeviceReading, readingDate) ; //AT-3174
            try {
                system.assert(existingReadingList[0].Device__c != null) ;
                String readingDate2 = String.valueOf(System.today()) ;
                CmAp_MyMeterDetailsCtlr.submitMyReading(existingReadingList[0].Device__c, newDeviceReading, readingDate2) ; //AT-3174
            } catch(Exception ex) {
                system.debug('exception caught in test context:: ' + ex);
            }
        }
		
    }
    /*******************************************************************
    @author:      ECHO: Sudhir Kumar
    @date:        09-Apr-2018
    @param:       N/A
    @return:      void
    @description: Negative Test scenario for getUserMeterDetails
    ********************************************************************/
    static testmethod void getUserMeterDetails_NegativeTest() {
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        
        System.runAs(objUser){
            List<BlAp_CombinedRecord> listReading = CmAp_MyMeterDetailsCtlr.getUserMeterDetails();
            CmAp_MyMeterDetailsCtlr.retrieveReadingPropDetails() ;
            CmAp_MyMeterDetailsCtlr.retrieveDevicePropDetails() ;
            CmAp_MyMeterDetailsCtlr.retrieveNewReadingPropDetails() ;
			List<Reading__c> existingReadingList = [SELECT Id,Device__c, Device__r.DeviceType__c, ActualDeviceReading__c FROM Reading__c WHERE Device__r.DeviceType__r.DeviceSize__r.Name =: DEVICE_SIZE] ;
			system.assert(!existingReadingList.isEmpty()) ;
            Decimal lastActualDeviceReading = Decimal.valueOf(existingReadingList[0].ActualDeviceReading__c)  ;
            system.assert(existingReadingList[0].ActualDeviceReading__c != null) ;
            system.assert(existingReadingList[0].Device__c != null) ; //AT-3174
            system.assert(existingReadingList[0].Device__r.DeviceType__c != null) ; //AT-3174
            Decimal newDeviceReading = Decimal.valueOf(existingReadingList[0].ActualDeviceReading__c) - 10 ;
            try {
                String readingDate2 = '' ;	// Invalid Date value
                system.assert(existingReadingList[0].Device__c != null) ;
                CmAp_MyMeterDetailsCtlr.submitMyReading(existingReadingList[0].Device__c, newDeviceReading, readingDate2) ; //AT-3174
            } catch(Exception ex) {
                system.debug('exception caught in test context:: ' + ex);
            }
        }
    }
}