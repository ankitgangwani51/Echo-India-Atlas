/*******************************************************************
@author:      ECHO: Vivek Sethi
@date:        09-Apr-2018
@param:       N/A
@return:      void
@description: Test class for CmAp_MyBillsCtlr
********************************************************************/

@isTest
public class CmAp_MyBillsCtlr_Test {

    private static final String USER_PROFILE             = 'System Administrator';
    private static final String USER_NAME                = 'TestUser';
    private static final String PORTAL_USER_NAME    	 = 'PortalTestUser';
    private static final String NON_PORTAL_USER_NAME     = 'NonPortalTestUser' ;
    private static final String USERNAMECOMPLETE    	 =  USER_NAME + '@unitest.com';
    private static final String PORTAL_USERNAMECOMPLETE  =  PORTAL_USER_NAME + '@unitest.com';
    private static final String ACCOUNT_NAME        	 = 'TestAccount';
    private static final String FIRST_NAME          	 = 'TestFirstName';
    private static final String LAST_NAME           	 = 'TestLastName';
    private static final String BILL_ITEM_NAME           = 'BillItem_Test';
    private static final Integer USED_VOLUME 			 = 50;
    private static final Integer BILLED_AMOUNT 			 = 150;
    private static final String HEROKU_POSTGRESID 		 = 'XYZ';
    private static final String BILL_SERVICE_TYPE_NAME   = 'BillServiceType_Test';
    private static final String BILL_NAME 				 = 'Test_Bill';
    private static final String CONTRACT_NAME 			 = 'Test_Contract';
    private static final String AVAIL_SERVICE_ITEM		 = 'AvailableServiceItem_Test';
    private static final String BUNDLE_ITEM				 = 'Test_BundleItem';
    private static final String BUNDLE_NAME				 = 'Bundle_Test';
    private static final String SERVICE_TYPE			 = 'Service_Type';    
    private static final String SERVICE_ITEM_FAMILY	     = 'Service_Item_Family';
    private static final String SERVICE_ITEM_TYPE		 = 'Service_Item_Type';
    private static final String WHOLESALER 				 = 'abc';
    private static final String DEVICE_TYPE				 = 'small Meter';
	private static final String AVAILABLE_BUNDLE		 = 'AvailableBundle';
	private static final String AVAIL_SERVICE			 = 'WATER';
	private static final String ZIPCODE					 = 'WS2 8DE';	
	private static final String	DEVICE_NAME				 = 'Meter';		
	private static final String	PAYMENT_PLAN_TYPE		 = 'New Payment Plan';
	private static final Integer PLAN_AMOUNT			 = 50;
	private static final Integer NO_OF_INSTALLMENT		 = 12;
	private static final String	PAYMENT_ALLOCATION		 = 'Payment Allocation'; 
	private static final decimal ALLOCATION_AMOUNT		 = 50;
    private static final String MEASURED				 ='Yes';
    private static final String READFREQUENCY			 ='Monthly';
    private static final String INVALID_BILL_ID			 = 'ABC';
    private static final String INVALID_PAYMENT_ID		 = 'ABC';
    private static final String SP_USAGE_TYPE			 = 'SupplyPointUsageType';
    private static final String PAYMENT_FREQ			 = 'Monthly';
    private static final Integer MAX_INSTALLMENT		 = 12;
    private static final Integer AMOUNTALLOCATED		 = 12;
    private static final String DEVICE_SIZE				 = 'TestDeviceSize';
    private static final String MANUFACTURER			 = 'Siemens';
    private static final String UNIT_OF_MEASURE			 = 'Metric';
    private static final String PORTAL_PROFILE_NAME      = SYSTEM.LABEL.CmAp_CommunityUserProfile ;
    
    /******************************************************************************
	@author:      Echo: Vivek Sethi.
	@date:        09-Apr-2018
	@description: Test data setup method
	*******************************************************************************/
    /*@testSetup
    static void createTestdata() {
        //Create portal account owner
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile = [Select Id from Profile where name =: USER_PROFILE];
        User portalAccountOwner = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        portalAccountOwner.UserRoleId = portalRole.Id ;
        Database.insert(portalAccountOwner);
        User nonPortalUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,NON_PORTAL_USER_NAME,null);
        Database.insert(nonPortalUser);
        System.runAs(portalAccountOwner){
            Test.startTest();
            testSetupData(portalAccountOwner.Id) ;
            Test.stopTest();           
        }
    }*/

   /*@future
    static void testSetupData(Id portalAccountOwnerId) {
        //Create account
		Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
		objAccount.OwnerId = portalAccountOwnerId ;
        Database.insert(objAccount);
		System.debug('objAccount:: ' + objAccount) ;
        
        //Create contact
		Contact objContact = GlUt_FactoryData_Test.createContact(FIRST_NAME, LAST_NAME);
		objContact.AccountId = objAccount.Id;
		Database.insert(objContact);
        System.debug('objContact:: ' + objContact) ;
        
        //Create user
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
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create ServiceItemType Record            
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICE_ITEM_FAMILY, objServiceItemFamily, objDivision, objDeviceType, objWholesaler);
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
        objSupplyPoint.ReadFrequency__c = READFREQUENCY;
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
        Contract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME, objAccount);
        Database.insert(objContract);
		
		// Create Device Record            
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);
        Database.insert(objDevice); 
		
		// Create Reading Record            
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading); 
  
		// Create Service Record            
        Service__c objService = GlUt_FactoryData_Test.createService(objContract, objReading, objServiceType, objSupplyPoint, objAvailableService);
        Database.insert(objService);  
  
        // Create ServiceItem Record            
        ServiceItem__c objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objService);
        objServiceItem.StartDate__c = Date.today();
        Database.insert(objServiceItem);         
          
        // Create Bill Record            
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILL_NAME, objContract);
        Database.insert(objBill);
        
        // Create ContentVersion Record            
        ContentVersion ObjContentVersion = GlUt_FactoryData_Test.createContentVersion(objBill);
        Database.insert(ObjContentVersion);
        
        // Create ContentVersion Record            
        ContentDocumentLink ObjContentDocumentLink = GlUt_FactoryData_Test.createContentDocumentLink(ObjContentVersion,objBill);
        Database.insert(ObjContentDocumentLink);

        // Create BillServiceType Record            
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILL_SERVICE_TYPE_NAME, objBill, HEROKU_POSTGRESID);
        Database.insert(objBillServiceType);         
          
        // Create BillItem Record            
        BillItem__c objBillItem = GlUt_FactoryData_Test.createBillItem(BILL_ITEM_NAME, objServiceItem, USED_VOLUME , BILLED_AMOUNT , objBillServiceType , HEROKU_POSTGRESID);
        objBillItem.Bill__c = objBill.id;
        Database.insert(objBillItem);         
            
		// Create Payment Record            
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount, objContract);
        Database.insert(objPayment);
		
		// Create PaymentPlanType Record            
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENT_PLAN_TYPE, PAYMENT_FREQ, MAX_INSTALLMENT);
        Database.insert(objPaymentPlanType);
			
		// Create PaymentPlan Record            
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType, objContract, PLAN_AMOUNT);
        Database.insert(objPaymentPlan);
		
		// Create Instalment Record            
        Instalment__c objInstalment = GlUt_FactoryData_Test.createInstalment(objPaymentPlan);
        Database.insert(objInstalment);
			
		// Create PaymentAllocation Record            
        PaymentAllocation__c objPaymentAllocation = GlUt_FactoryData_Test.createPaymentAllocation(PAYMENT_ALLOCATION, ALLOCATION_AMOUNT, objBillItem, objInstalment, objPayment);
        Database.insert(objPaymentAllocation); 
    }*/
    /*******************************************************************
    @author:      ECHO: Vivek Sethi
    @date:        09-Apr-2018
    @param:       N/A
    @return:      void
    @description: Positive Test scenario for retrieveBillPropDetails
    ********************************************************************/
    /*static testmethod void retrieveBillPropDetails_PositiveTest() {
        List<GLAp_FieldProps> billProps = new List<GLAp_FieldProps>();
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
    
        System.runAs(objUser){
            Test.startTest();
            billProps = CmAp_MyBillsCtlr.retrieveBillPropDetails();
            Test.stopTest();
        }        
        System.assert(!billProps.isEmpty());
    }*/
    
    /*******************************************************************
    @author:      ECHO: Vivek Sethi
    @date:        09-Apr-2018
    @param:       N/A
    @return:      void
    @description: Positive Test scenario for getUserBills
	********************************************************************/
    /*static testmethod void getUserBills_PositiveTest() {
        List<Profile> portalProfile = [SELECT Id FROM Profile WHERE Name =: GlUt_FactoryData_Test.PORTAL_PROFILE_NAME Limit 1];
        String usrName;
        if(portalProfile != null && portalProfile.size() > 0)
            usrName = PORTAL_USERNAMECOMPLETE;
        else
            usrName = USERNAMECOMPLETE;
        
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: usrName LIMIT 1];
        List<BlAp_CombinedRecord> listReading = new List<BlAp_CombinedRecord>();      
        System.runAs(objUser){
            Test.startTest();
            listReading = CmAp_MyBillsCtlr.getUserBills();
            Test.stopTest();
        }
        System.assert(!listReading.isEmpty());
    }*/
    
    /*******************************************************************
    @author:      ECHO: Vivek Sethi
    @date:        09-Apr-2018
    @param:       N/A
    @return:      void
    @description: Negative Test scenario for getUserBills
********************************************************************/
    /*static testmethod void getUserBills_NegativeTest() {
        try {
            User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: NON_PORTAL_USER_NAME LIMIT 1];
            System.runAs(objUser){
                Test.startTest();
                List<BlAp_CombinedRecord> listReading = CmAp_MyBillsCtlr.getUserBills();
                Test.stopTest();
            }
        } catch(Exception ex){}
    }*/
}