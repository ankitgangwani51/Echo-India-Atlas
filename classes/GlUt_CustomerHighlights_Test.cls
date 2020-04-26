/******************************************************************************
@author:      Echo: Neha 
@date:        17-01-2018  
@description: Test Class for CuAp_SelectDiscountApplyCtrlr
*******************************************************************************/
@isTest  
public class GlUt_CustomerHighlights_Test {   
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String ACCOUNT_NAME1 = 'United water Corp.';
    private static final String CONTRACT_NAME1 = 'CON-00015784';
    private static final String ACCOUNT_NAME = 'United Oil & Gas Corp.';
    private static final String POSTAL_CODE = 'ws2 8de';
    private static final String OPEN_CASE_STATUS = 'New';
    private static final String CONTRACT_NAME = 'CON-00014670';
    private static final String CONTRACTSTATUS_ACTIVE = 'Active';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String MEASURED ='Yes';
    private static final String READFREQUENCY ='Monthly';    
    private static final String SERVICE_TYPE_NAME = 'Water';
    private static final String DEVICE_SIZE = 'Siemens 25mm';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String DEVICE_NAME = '000118186';
    private static final String SERVICE_NAME = 'S-1442'; 
    private static final String SERVICE_ITEM_FAMILY = 'Measured Water Volumetric';
    private static final String SERVICE_ITEM_TYPE = 'Measured Water Volumetric';
    private static final String BUNDLE_NAME ='Social Bundle';
    private static final String BUNDLE_ITEM ='TestBundleItem';
    private static final String AVAIL_SERVICE_ITEM ='TestAvailableServiceItem';
    private static final String WHOLESALER_NAME = 'AWB'; 
    private static final String AVAIL_BUNDLE = 'Available Bundle';
    private static final String SUPPRESSION_REASON = 'Payment Query';
    private static final String DEBT_RECOVERY_STAGE = 'Reminder 1';
    private static final Date STARTDATE = System.today() - 15;     
    
    
	/******************************************************************************
	@author:      Echo: Neha
	@date:        17-01-2018  
	@description: Test data setup method
	*******************************************************************************/
    @TestSetup
    static void createTestData()
    {
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USER_NAME, null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
                
        // Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);        
        Database.insert(objAccount); 
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(POSTAL_CODE);          
        Database.insert(objLocation);
        
        // Case Record (Open)
        Case objCase = GlUt_FactoryData_Test.createCase(objAccount, OPEN_CASE_STATUS);        
        Database.insert(objCase); 
        
        // Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME, objAccount);
		objContract.Void__c = true;         
        Database.insert(objContract);
        
        // Debt Recovery Process Record (Open)
        DebtRecoveryProcess__c objDebtRecoveryProcess = GlUt_FactoryData_Test.createDebtRecoveryProcess(objContract);        
        objDebtRecoveryProcess.CurrentStage__c = DEBT_RECOVERY_STAGE;
        objDebtRecoveryProcess.CurrentStageDateTime__c = STARTDATE;
        Database.insert(objDebtRecoveryProcess);
        
        Account objAccount1 = new Account();
        // Suppression
        Suppression__c objSuppression = GlUt_FactoryData_Test.createSuppression(objAccount1, objContract, SUPPRESSION_REASON);        
        Database.insert(objSuppression); 
                
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create SupplyPoint Record
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; // AT-3174
        Database.insert(objSupplyPoint);        
        
        // Create ServiceType Record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(SERVICE_TYPE_NAME);
        Database.insert(objServiceType);
        
        // Create Division Record
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        // Create Wholesaler Record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER_NAME);
        Database.insert(objWholesaler);
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize, MANUFACTURER, UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);        
        Database.insert(objDevice);
        
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading);
        
        // Create AvailableService Record
        AvailableService__c objAvailableService = GlUt_FactoryData_Test.createAvailableService(SERVICE_NAME, objDivision, objServiceType, objSupplyPoint, objWholesaler);
        Database.insert(objAvailableService);
        
        // Create Service Record
        Service__c objService = GlUt_FactoryData_Test.createService(objContract, objReading, objServiceType, objSupplyPoint, objAvailableService);
        Database.insert(objService);
     
        // Create Service Item Family Record
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICE_ITEM_FAMILY, objServiceType);       
        Database.insert(objServiceItemFamily);
        
        // Create Service Item Type Record
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICE_ITEM_TYPE, objServiceItemFamily, objDivision, objDeviceType, objWholesaler);       
        Database.insert(objServiceItemType);
      
        // Create Bundle Record (Social bundle)
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE_NAME, objServiceType);
        objBundle.TariffLimit__c = true;  //AT-3280
        Database.insert(objBundle);  

        // Create Bundle Item Record
        BundleItem__c objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLE_ITEM, objBundle, objServiceItemType, objServiceItemFamily);
        Database.insert(objBundleItem); 
                
        // Create Available Bundle Record
        AvailableBundle__c objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAIL_BUNDLE, objBundle, objAvailableService);
        Database.insert(objAvailableBundle);

		// Create Available Service Item Record
        AvailableServiceItem__c objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(AVAIL_SERVICE_ITEM, objBundleItem, objServiceItemType, objAvailableBundle);
        Database.insert(objAvailableServiceItem);        
        
        // Create Service Item Record
        ServiceItem__c objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem, objServiceItemType, objService);
        objServiceItem.StartDate__c = STARTDATE;
        Database.insert(objServiceItem);               
    }    

    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        06 Feb 2018  
	@description: Method for void Location check
	*******************************************************************************/
    static testmethod void customerHighlights_Loc_Positive(){            
        
        User objUser =[SELECT Id, Name FROM user WHERE isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        Location__c objLoc = [SELECT Id FROM Location__c LIMIT 1];
        
        System.runAs(objUser){
            Test.startTest();
            
        	// wrapper class object
            GlUt_CustomerHighlights.WrapperClass objWrapperClass = new GlUt_CustomerHighlights.WrapperClass();        	
        	objWrapperClass = GlUt_CustomerHighlights.customerHighlights(objLoc.Id, GlUt_APIConstantsLocation.LOCATIONAPINAME);
            Test.stopTest();
                       
            System.assert(objWrapperClass.isVoid == true);
        }
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        06 Feb 2018  
	@description: Method for customer highlights display on Account for
				  open case, Social Tariff , Contract Suppression
	*******************************************************************************/
    static testmethod void customerHighlights_Acc_Positive(){            
        
        User objUser =[SELECT Id, Name FROM user WHERE isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        DebtRecoveryProcess__c objDRP = [SELECT BillingContract__c FROM DebtRecoveryProcess__c LIMIT 1];
        
        BillingContract__c objContract = [SELECT CurrentDebtRecoveryProcess__c FROM BillingContract__c LIMIT 1];
        objContract.CurrentDebtRecoveryProcess__c = objDRP.Id;        
        update objContract;
        
        Account objAcc = [SELECT Id FROM Account LIMIT 1];
        
        System.runAs(objUser){
            Test.startTest();
            
        	// wrapper class object
            GlUt_CustomerHighlights.WrapperClass objWrapperClass = new GlUt_CustomerHighlights.WrapperClass();        	
        	objWrapperClass = GlUt_CustomerHighlights.customerHighlights(objAcc.Id, 'Account');
            Test.stopTest();       
                        
            System.assert(objWrapperClass.isOpenCase == true);
            System.assert(objWrapperClass.isSuppressed == true);
        }
    }
           
    /******************************************************************************
	@author:      Echo: Neha
	@date:        06 Feb 2018 
	@description: Method for customer highlights display on Contracts for
				  Suppression, Debt Recovery Stage
	*******************************************************************************/
    static testmethod void customerHighlights_Con_Positive() {            
        
        User objUser =[SELECT Id, Name FROM user WHERE isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        DebtRecoveryProcess__c objDRP = [SELECT BillingContract__c FROM DebtRecoveryProcess__c LIMIT 1]; 
        
        BillingContract__c objContract = [SELECT CurrentDebtRecoveryProcess__c FROM BillingContract__c LIMIT 1];
        objContract.CurrentDebtRecoveryProcess__c = objDRP.Id;        
        update objContract;
        
        System.runAs(objUser){
            Test.startTest();
            
        	// wrapper class object
            GlUt_CustomerHighlights.WrapperClass objWrapperClass = new GlUt_CustomerHighlights.WrapperClass();        	
        	objWrapperClass = GlUt_CustomerHighlights.customerHighlights(objContract.Id, GlUt_APIConstantsContracts.CONTRACTAPINAME);
            Test.stopTest();
            system.debug('101********objWrapperClass ' + objWrapperClass);
            System.assert(objWrapperClass.isDRStage == true);
            System.assert(objWrapperClass.isSuppressed == true);
        }
    }
      
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        06 Feb 2018  
	@description: Method for void Location check in negative scenario
	*******************************************************************************/
    static testmethod void customerHighlights_Loc_Neg(){            
        
        User objUser =[SELECT Id, Name FROM user WHERE isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        Location__c objLoc = new Location__c();
        
        System.runAs(objUser){
            Test.startTest();
            
        	// wrapper class object
            GlUt_CustomerHighlights.WrapperClass objWrapperClass = new GlUt_CustomerHighlights.WrapperClass();        	
        	objWrapperClass = GlUt_CustomerHighlights.customerHighlights(objLoc.Id, GlUt_APIConstantsLocation.LOCATIONAPINAME);
            Test.stopTest();
                       
            System.assert(objWrapperClass.isVoid == null);
        }
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        06 Feb 2018  
	@description: Method for customer highlights display on Account for
				  open case, Social Tariff , Contract Suppression in Negative screnario
	*******************************************************************************/
    static testmethod void customerHighlights_Acc_Neg(){            
       
        User objUser =[SELECT Id, Name FROM user WHERE isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        DebtRecoveryProcess__c objDRP = [SELECT BillingContract__c FROM DebtRecoveryProcess__c LIMIT 1]; 
        
        BillingContract__c objContract = [SELECT CurrentDebtRecoveryProcess__c FROM BillingContract__c LIMIT 1];
        objContract.CurrentDebtRecoveryProcess__c = objDRP.Id;
        update objContract;
        
        Account objAcc = new Account();
        
        System.runAs(objUser){
            Test.startTest();
            
        	// wrapper class object
            GlUt_CustomerHighlights.WrapperClass objWrapperClass = new GlUt_CustomerHighlights.WrapperClass();        	
        	objWrapperClass = GlUt_CustomerHighlights.customerHighlights(objAcc.Id, 'Account');
           
            Test.stopTest();   
            
            System.assert(objWrapperClass.isOpenCase == null); 
        }
    }
           
    /******************************************************************************
	@author:      Echo: Neha
	@date:        06 Feb 2018 
	@description: Method for customer highlights display on Contracts for
				  Suppression, Debt Recovery Stage in Negative scenario
	*******************************************************************************/
    static testmethod void customerHighlights_Con_Neg() {            
        
        Id ContractID;
        User objUser =[SELECT Id, Name FROM user WHERE isActive = true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Suppression__c objSuppression = [SELECT Id,Account__c,BillingContract__c FROM Suppression__c limit 1];
                system.debug('objSuppression   ' + objSuppression);
        BillingContract__c objContract = new BillingContract__c();
                
        System.runAs(objUser){
            Test.startTest();
            
        	// wrapper class object
            GlUt_CustomerHighlights.WrapperClass objWrapperClass = new GlUt_CustomerHighlights.WrapperClass();        	
        	objWrapperClass = GlUt_CustomerHighlights.customerHighlights(objContract.Id, GlUt_APIConstantsContracts.CONTRACTAPINAME);
            Test.stopTest();
                        
            System.assert(objWrapperClass.isDRStage == null);
            System.assert(objWrapperClass.isSuppressed == null);
        }
    }
    
    
}