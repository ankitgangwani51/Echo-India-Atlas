/******************************************************************************
@author:      Echo: Mohit Tayal
@date:        16 January 2018
@description: Test Class for DrBt_ProcessAction 
*******************************************************************************/
@isTest
public class DrBt_ProcessAction_Test {
    private static final String USER_PROFILE        = 'System Administrator';
    private static final String USER_NAME           = 'TestUser'; 
    private static final String USERNAMECOMPLETE    = USER_NAME+ '@unitest.com';
    private static final String ACCOUNT_NAME        = 'TestAccount'; 
    private static final String CONTRACT_NAME1       = 'TestContract1';
    private static final String CONTRACT_NAME2       = 'TestContract2';  
    private static final String PAYMENTPLANTYPE_NAME = 'TestPaymentPlanType';
    private static final Integer PLANAMOUNT          = 5000;
    private static final Integer NUMBEROFINSTALMENTS = 10;
    private static final String DEVICE_NAME         = 'TestDevice';
    private static final String DEVICE_TYPE         = 'TestDeviceType';
    private static final String TEST_SERVICE_TYPE   = 'TestServiceType';
    private static final String LOCATION_NAME       = 'A99 9AA';
    private static final String LOCATION_SUB_TYPE   = 'Detached';
    private static final String STREET              = 'teststreet';
    private static final String YES                 = 'yes';
    private static final String MEASURED            = 'Monthly';
    private static final String WHOLESALER          = 'TestWholesaler';
    private static final String AVAILABLESERVICES   = 'TestAvailableService';
    private static final String SERVICEITEMFAMILY   = 'TestServiceItemFamily';
    private static final String SERVICEITEMTYPE     = 'TestServiceitemtype';
    private static final String BUNDLE              = 'TestBundle';
    private static final String BUNDLEITEM          = 'TestBundleItem';
    private static final String POSITIVETEST        = 'PositiveTest';
    private static final String NEGATIVETEST        = 'NegativeTest';
    private static final String YEARLY              = 'Yearly';
    private static final String INSTALMENTPLAN      = 'Instalment Plan';
    private static final Integer MAXNUMOFINSTALMENTS = 12;
    private static final String CHANGEPAYMENTPLAN   = 'Change Payment Plan';
    private static final String ERROR               = 'Error';
    private static final String PROCESSED           = 'Processed';
    private static final String ADDADDTNALSERVICES  = 'Add Additional Services';
    private static final String SENDRMNDRLETTER     = 'Send Reminder Letter';
    private static final String SENDDISCONNOTICE    = 'Send Disconnection Notice';
    private static final String SENDLETTER          = 'Send Letter';
    private static final String CALCULATEBILL       = 'Calculate Bill';    
    private static final String SP_USAGE_TYPE 		= 'SupplyPointUsageType';
    private static final String DEVICE_SIZE 		= 'TestDeviceSize';
    private static final String MANUFACTURER 		= 'Siemens';
    private static final String UNIT_OF_MEASURE 	= 'Metric';
    private static final String PROFILE             = 'Profile 1';
    private static final String CHANGRECOVRYPROFILE = 'Change Recovery Profile';
    private static final String MARKFFORDISCONCTION = 'Mark For Disconnection';  
    private static final String SCHEDULERNAME       = 'Test SchedulerName';
    private static final String BILLNAME = 'testBill';
    private static final String BILLSERVICENAME = 'Test Bill Service';
    private static final String HEROKUPOSTGRESID = 'Test ID';
    private static final String BILLITEMNAME = 'Test Bill Item';
    private static final Integer VOLUMEUSED = 200;
    private static final Integer BILLEDAMOUNT = 67878;
    private static final String AVAILABLEBUNDLE ='TestAvailableBundle';
    private static final String AVAILABLESERVIEITEM='TestAvailableServiceItem';
        
    
/*******************************************************************
@author:      Echo: Mohit Tayal
@date:        16 January 2018
@param:       N/A
@return:      void
@description: method to create test data used by all test methods
********************************************************************/
    @TestSetup
    static void CreateTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        Database.insert(objUser); 
        
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        

        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENTPLANTYPE_NAME, YEARLY, MAXNUMOFINSTALMENTS);
        objPaymentPlanType.PlanType__c = INSTALMENTPLAN;
        objPaymentPlanType.ResetDebtRecovery__c = TRUE;
        objPaymentPlanType.DaysNotice__c = 10;
        objPaymentPlanType.NumberofRollingInstalments__c =  12 ; //Label.CuAp_PaymentPlanTypeCreditHandlingyRefund ;
         //objPaymentPlanType.CreditHandling__c = Label.CuAp_PaymentPlanTypeCreditHandlingyRefund;
        Database.insert(objPaymentPlanType);
        
        BillingContract__c con1 = GlUt_FactoryData_Test.createContract(CONTRACT_NAME1,objAccount); 
        con1.CurrentPaymentPlanType__c = objPaymentPlanType.Id;
        Database.insert(con1);
        
        BillingContract__c con2 = GlUt_FactoryData_Test.createContract(CONTRACT_NAME2,objAccount); 
        con2.CurrentPaymentPlanType__c = objPaymentPlanType.Id;
        Database.insert(con2);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);
        
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(TEST_SERVICE_TYPE );
        Database.insert(objServiceType);
        
        Reading__c objReading1 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading1.ReadingDate__c = Date.today();
        Database.insert(objReading1); 
        
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
        objSupplyPoint.AllowDisconnection__c = TRUE;
        Database.update(objSupplyPoint);
        
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        AvailableService__c objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        Service__c objService = GlUt_FactoryData_Test.createService(con1,objReading1,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);
        
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);
        
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE,objServiceType);
        Database.insert(objBundle);
        
        BundleItem__c objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLEITEM,objBundle,objServiceItemType,null);
        Database.insert(objBundleItem);   
        
                  // Create AvailableBundle Record
        AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(AVAILABLEBUNDLE,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);      
  
        // Create AvailableServiceItem Record
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        Database.insert(objAvailableServiceItem); 
        // Create ServiceItem Record
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        objServiceItem.StartDate__c = Date.today();
        Database.insert(objServiceItem);
        
        //Create Debt. Recovery Process record
        DebtRecoveryProcess__c objDebtRecProcess1 = GlUt_FactoryData_Test.createDebtRecoveryProcess(con1);
        objDebtRecProcess1.ProcessComplete__c = TRUE;
        Database.insert(objDebtRecProcess1);
        con1.CurrentDebtRecoveryProcess__c = objDebtRecProcess1.Id;
        Database.update(con1);
        
        DebtRecoveryProcess__c objDebtRecProcess2 = GlUt_FactoryData_Test.createDebtRecoveryProcess(con2);
        objDebtRecProcess2.ProcessComplete__c = TRUE;
        Database.insert(objDebtRecProcess2);
        
        //Create Debt. Recovery Action record
        List<DebtRecoveryAction__c> debtRecActList = new List<DebtRecoveryAction__c>();
        for(Integer i = 0; i < 100; i++){
            
            DebtRecoveryAction__c objDebtRecAct = GlUt_FactoryData_Test.createDebtRecoveryAction(objDebtRecProcess1);
            
            if(i < 10){
                objDebtRecAct.Action__c = SENDRMNDRLETTER;
            } else if(i >= 10 && i < 20){
                objDebtRecAct.Action__c = SENDDISCONNOTICE;
            }else if(i >= 20 && i < 30){
                objDebtRecAct.Action__c = MARKFFORDISCONCTION;               
            }else if(i >= 30 && i < 40){
                objDebtRecAct.Action__c = ADDADDTNALSERVICES;
                objDebtRecAct.Parameters__c = BUNDLE;
            }else if(i >= 40 && i < 50){
                objDebtRecAct.Action__c = CALCULATEBILL;
            }else if(i >= 50 && i < 60){
                objDebtRecAct.Action__c = CHANGEPAYMENTPLAN;
                objDebtRecAct.Parameters__c = PAYMENTPLANTYPE_NAME;
            }else if(i >= 60 && i < 70){
                objDebtRecAct.Action__c = CHANGRECOVRYPROFILE;
                objDebtRecAct.Parameters__c = PROFILE;
            } else {
                objDebtRecAct.Action__c = SENDLETTER;
            }
            
            objDebtRecAct.Processed__c = FALSE;
            objDebtRecAct.Date__c = System.today();
            debtRecActList.add(objDebtRecAct);         
        }

        Database.insert(debtRecActList);
        
        // Create Bill Record
        Bill__c objBill = GlUt_FactoryData_Test.CreateBill(BILLNAME ,con1);
        objBill.Account__c = objAccount.id; //AT-3174
        Database.insert(objBill);
        // Create BillServiceType Record
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILLSERVICENAME, objBill, HEROKUPOSTGRESID);
        Database.insert(objBillServiceType);
        // Create BillItem Record
        BillItem__c objBillItems = GlUt_FactoryData_Test.createBillItem(BILLITEMNAME, objServiceItem , VOLUMEUSED ,BILLEDAMOUNT, objBillServiceType, HEROKUPOSTGRESID);
        objBillItems.Bill__c = objBill.Id;
        Database.insert(objBillItems);

        
        
    }
    
/*******************************************************************
@author:      ECHO: Mohit Tayal
@date:        16 January 2018
@param:       N/A
@return:      void
@description: Positive Test scenario for ProcessAction
********************************************************************/
 
    static testmethod void ProcessAction_PositiveTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1]; 
        String sCronExp =  '0 0 * * * ?' ;
        
        System.runAs(objUser){
            Test.startTest(); 
            Database.executeBatch(new DrBt_ProcessAction());
            String jobID = System.schedule(SCHEDULERNAME, sCronExp, new DrBt_ProcessAction());
            Test.stopTest();
            
            List<PaymentPlanType__c> paymentPlanTypeList = [SELECT Id, Name FROM PaymentPlanType__c WHERE Name = :PAYMENTPLANTYPE_NAME];
            List<BillingContract__c> contractList = [SELECT Id, CurrentPaymentPlanType__c FROM BillingContract__c WHERE AccountName__r.Name = :ACCOUNT_NAME];
            Location__c objLocation = [SELECT Id FROM Location__c WHERE PostalCode__c = :LOCATION_NAME LIMIT 1];
            SupplyPoint__c objSupplyPoint = [SELECT Id FROM SupplyPoint__c WHERE Location__c = :objLocation.Id AND AllowDisconnection__c = TRUE LIMIT 1];
            
            for(DebtRecoveryAction__c dbRecAction : [SELECT Id, Processed__c, Action__c, Status__c, Parameters__c, ErrorMessage__c, DebtRecoveryProcess__r.BillingContract__c FROM DebtRecoveryAction__c WHERE Processed__c = FALSE]){
                if(dbRecAction.Action__c == SENDRMNDRLETTER || 
                   dbRecAction.Action__c == SENDDISCONNOTICE || 
                   dbRecAction.Action__c == SENDLETTER ||
                   dbRecAction.Action__c == ADDADDTNALSERVICES ||
                   dbRecAction.Action__c == CALCULATEBILL){
                       System.assertEquals(TRUE, dbRecAction.Processed__c);
                   }else if (dbRecAction.Action__c == CHANGRECOVRYPROFILE) {
                       System.assertEquals(TRUE, dbRecAction.Processed__c);
                       System.assertEquals(contractList[0].DebtRecoveryProfile__c, dbRecAction.DebtRecoveryProcess__r.BillingContract__c);
                   }else if(dbRecAction.Action__c == CHANGEPAYMENTPLAN){
                       System.assertEquals(contractList[0].CurrentPaymentPlanType__c,paymentPlanTypeList[0].Id);
                       System.assertEquals(PROCESSED,dbRecAction.Status__c);
                   }else if(dbRecAction.Action__c == MARKFFORDISCONCTION){
                       System.assertEquals(TRUE, dbRecAction.Processed__c);
                       System.assertEquals(DrBt_Constants.TOBEDISCONNECTED, objSupplyPoint.DisconnectionStatus__c);
                   }
            }
        }
    }    
}