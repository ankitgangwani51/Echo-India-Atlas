/*******************************************************************
@author:      ECHO: Mohit Tayal
@date:        12 April 2018
@param:       N/A
@return:      void
@description: Test Class for CmAp_MakePaymentCtrlr
@revision	  Echo: Sudhir Kumar - Fix for AT-2308
@Revisions	  AT-4887 , Tarun , Added Assert as part of checkmarks result
********************************************************************/ 
@isTest
public class CmAp_MakePaymentCtrlr_Test {

    private static final String USER_PROFILE        = 'System Administrator';
    private static final String USER_NAME           = 'TestUser'; 
    private static final String PORTAL_USER_NAME    = 'PortalTestUser';
    private static final String USERNAMECOMPLETE    =  USER_NAME + '@unitest.com';
    private static final String PORTAL_USERNAMECOMPLETE =  PORTAL_USER_NAME + '@unitest.com';
    private static final String ACCOUNT_NAME        = 'TestAccount';
    private static final String FIRST_NAME          = 'TestFirstName';
    private static final String LAST_NAME           = 'TestLastName';
    private static final String PORTALTYPE          = 'None';
    private static final Integer AMOUNT             = 100;
    // START - Sudhir: AT-2308
	private static final String CONTRACT_NAME 		= 'Test_Contract';		
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
    // END - Sudhir: AT-2308
   
    /*******************************************************************
    @author:      ECHO: Mohit Tayal
    @date:        12 April 2018
    @param:       N/A
    @return:      void
    @description: Creating the test data
    ********************************************************************/
    @testSetup
    static void createTestdata() {
        //Create portal account owner
        UserRole portalRole = [Select Id From UserRole Where PortalType = :PORTALTYPE Limit 1];
		User portalAccountOwner = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
		portalAccountOwner.UserRoleId = portalRole.Id ;
		Database.insert(portalAccountOwner);
        
        System.runAs(portalAccountOwner){
            Test.startTest();
            testSetupData(portalAccountOwner.Id) ;   
            Test.stopTest();
        }
    }

    /*******************************************************************
    @author:      ECHO: Mohit Tayal
    @date:        12 April 2018
    @param:       N/A
    @return:      void
    @description: Creating the portal user test setup
    ********************************************************************/ 
   @future
    static void testSetupData(Id portalAccountOwnerId) {
        //Create account
		Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
		objAccount.OwnerId = portalAccountOwnerId ;
        Database.insert(objAccount);
        
        //START - Sudhir: AT-2308
        //Create Contract
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(null, objAccount) ;
        Database.insert(objContract); 
        
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
        objSupplyPoint.Measured__c = true;
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
		
		// Create Device Record            
        Device__c objDevice1 = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType1);
        Device__c objDevice2= GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType2);
        Database.insert(new list<Device__c> {objDevice1, objDevice2}); 
        
		// Create Supply Point Device  
		SupplyPointDevice__c objSPD = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice1, objSupplyPoint) ;
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
        // END - Sudhir: AT-2308
        //Create contact
		Contact objContact = GlUt_FactoryData_Test.createContact(FIRST_NAME, LAST_NAME);
		objContact.AccountId = objAccount.Id;
		//Database.insert(objContact);
        
        //Create Portal  user
        User portalUser = GlUt_FactoryData_Test.createCommunityUser(objContact, PORTAL_USER_NAME);
        if(portalUser != null)
            Database.insert(portalUser);
    }
    
    /*******************************************************************
    @author:      ECHO: Mohit Tayal
    @date:        12 April 2018
    @param:       N/A
    @return:      void
    @description: Positive Test scenario for createPayment
    ********************************************************************/
    static testmethod void createPayment_PositiveTest(){
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        Account objAccount = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
 		BillingContract__c objContract = [SELECT Id FROM BillingContract__c WHERE AccountName__c = :objAccount.Id LIMIT 1];	//  Sudhir: AT-2308 
        
        System.runAs(objUser){
            Test.startTest();
              CmAp_MakePaymentCtrlr.createPayment(AMOUNT);
            Test.stopTest();
        }
        
        List<Payment__c> lstPayment = [SELECT Id, Amount__c FROM Payment__c WHERE Account__c = :objAccount.Id];
        
        System.assert(!lstPayment.isEmpty());
        for(Payment__c objPayment : lstPayment){
            System.assertEquals(objPayment.Amount__c, AMOUNT);
        }
		
    }
    
    /*******************************************************************
    @author:      ECHO: Mohit Tayal
    @date:        12 April 2018
    @param:       N/A
    @return:      void
    @description: Negative Test scenario for createPayment
    ********************************************************************/ 
    static testmethod void createPayment_NegativeTest() {
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        Boolean isException = false;
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        System.runAs(objUser){
            Test.startTest();
            try{
              CmAp_MakePaymentCtrlr.createPayment(0);
            }
            catch(exception e){
                isException = true;
                System.debug('Exception ' +e.getMessage());
            }
            Test.stopTest();
            System.assert(isException);
        }
    }
}