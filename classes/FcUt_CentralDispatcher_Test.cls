/******************************************************************************
@author:      Swati Mathur
@date:        11-Apr-2018
@description: Test Class for FcUt_CentralDispatcher
@Revisions	  AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/

@isTest
public class FcUt_CentralDispatcher_Test{
    
    private static final String USER_PROFILE ='System Administrator';
    private static final String USER_NAME ='TestUser'; 
    private static final String ACCOUNT_NAME = 'TestAccount'; 
    private static final String CONTRACT_NAME1 ='TestContract1';
    private static final String CONTRACT_NAME2 ='TestContract2';
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String DEVICE_TYPE ='TestDeviceType';
    private static final String TEST_SERVICE_TYPE ='TestServiceType';
    private static final String LOCATION_NAME ='A99 9AA';
    private static final String LOCATION_SUB_TYPE = 'Detached';
    private static final String STREET = 'teststreet';
    private static final String YES ='yes';
    private static final String MEASURED = 'Monthly';
    private static final String WHOLESALER ='TestWholesaler';
    private static final String AVAILABLESERVICES ='TestAvailableService';
    private static final String SERVICEITEMFAMILY ='TestServiceItemFamily';
    private static final String SERVICEITEMTYPE ='TestServiceitemtype';
    private static final String BUNDLE ='TestBundle';
    private static final String AVAILABLEBUNDLE ='TestAvailableBundle';
    private static final String BUNDLEITEM ='TestBundleItem';
    private static final String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static final String AVAILABLESERVIEITEM1='TestAvailableServiceItem1';
    private static final String BILLNAME = 'testBill';
    private static final String BILLSERVICENAME = 'Test Bill Service';
    private static final String BILLITEMNAME1 = 'Test Bill Item';
    private static final String BILLITEMNAME2 = 'Test Bill Item 2';
    private static final String PAYMENTPLANNAME = 'Test Payment Plan Type';
    private static final Integer VOLUMEUSED = 200;
    private static final Integer BILLEDAMOUNT = 67878;
    private static final String HEROKUPOSTGRESID1 = 'Test ID 1';
    private static final String HEROKUPOSTGRESID2 = 'Test ID 2';
    private static final Integer PLANAMOUNT = 56557;
    private static final Integer NUMBEROFINSTALMENTS =12;
    private static final String USERNAMECOMPLETE = USER_NAME+ '@unitest.com';
    private static final Integer MAXINSTLLMNT = 12;
    private static final String PLANTYP = 'Instalment Plan';
    private static final String FREQUENCY = 'Monthly';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String FTET_NAME      = 'FTET';
    private static final String FTET_NAME_1      = 'FTET-1';
    private static final String FTET_NAME_2      = 'FTET-2';
    private static final String FTET_NAME_3      = 'FTET-3';
    private static final String FTET_NAME_4      = 'FTET-4';
    private static final String FTET_CATEGORY    = 'Bill Calculation';
    private static final String FTET_NAME_C      = 'Agent Real Time Bill Calculation';
    private static final Decimal CREDITAMT1   = 100.00;
    private static final Decimal CREDITAMT2   = 25.00;
    private static final Decimal DISCOUNTAMOUNT = 100.00;
    private static final Decimal TAXAMOUNT  = 20.00; 
    private static final Decimal AMENDMENTAMOUNT = 100.00;
    private static Id PAYMENTRECORDTYPE = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
    private static Id REFUNDRECORDTYPE = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId();
    private static final String PAYMENT_ALLOCATION_NAME = 'Payment Allocation test';
    private static final Decimal AMOUNTALLOCATED = 100.00;     
    private static final String AMENDMENT_NAME = 'Amendment test';
    private static final String AMENDMENT_REASON = 'Manual Amendment';
    /*******************************************************************
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    @TestSetup
    static void createTestData(){        
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        Database.insert(objUser); 
        
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount); 
        
        List<BillingContract__c> listContracts = new List<BillingContract__c>();
        BillingContract__c con = GlUt_FactoryData_Test.createContract(CONTRACT_NAME1,objAccount);
        con.BillingFrequency__c = 'Monthly';
        listContracts.add(con);

        BillingContract__c con1 = GlUt_FactoryData_Test.createContract(CONTRACT_NAME2,objAccount);
        con1.BillingFrequency__c = 'Monthly';
        listContracts.add(con1);
        Database.insert(listContracts);
        
        List<BillCalculation__c> listBillCalc = new List<BillCalculation__c>();
        BillCalculation__c objBillCalculation = GlUt_FactoryData_Test.createBillCalculation(); 
        listBillCalc.add(objBillCalculation);
        
        BillCalculation__c objBillCalculation1 = GlUt_FactoryData_Test.createBillCalculation();
        objBillCalculation1.BillingContract__c = con.id;
        listBillCalc.add(objBillCalculation1);
        Database.insert(listBillCalc);
        
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);
        
        List<ServiceType__c> listServiceType = new List<ServiceType__c>();
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(TEST_SERVICE_TYPE );
        listServiceType.add(objServiceType);
        
        ServiceType__c objServiceType1 = GlUt_FactoryData_Test.createServiceType(TEST_SERVICE_TYPE );
        listServiceType.add(objServiceType1);
        Database.insert(listServiceType);
        
        Reading__c  objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading);
        
        Reading__c objReading1 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading1.AmendedByReading__c = objReading.id;
        Database.insert(objReading1);
        
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        SupplyPointDevice__c objSupplyPointDevices = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice, objSupplyPoint);
        Database.insert(objSupplyPointDevices);
       
        Division__c  objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        Service__c  objService = GlUt_FactoryData_Test.createService(con,objReading,objServiceType,objSupplyPoint,objAvailableService);    
        Database.insert(objService);
        
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);
        
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE,objServiceType);
        Database.insert(objBundle);
        
        AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAILABLEBUNDLE,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily); 
        Database.insert(objBundleItem);
        
        List<AvailableServiceItem__c> listASI = new List<AvailableServiceItem__c>();
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        listASI.add(objAvailableServiceItem);
        
        AvailableServiceItem__c  objAvailableServiceItem1 = GlUt_FactoryData_Test.createAvailableServiceItem(AVAILABLESERVIEITEM1,objBundleItem,objServiceItemType,objAvailableBundle);
        listASI.add(objAvailableServiceItem1);
        Database.insert(listASI); 
        
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        Database.insert(objServiceItem);
        
        ServiceItem__c  objServiceItem1 = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem1,objServiceItemType,objService);
        objServiceItem1.AmendedByServiceItem__c = objServiceItem.Id;
        Database.insert(objServiceItem1);        
        
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILLNAME ,con);
        objBill.Account__c = objAccount.id; //AT-3174
        objBill.BillCalculationReason__c = FTET_NAME_C;
        Database.insert(objBill);
        
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILLSERVICENAME, objBill, HEROKUPOSTGRESID1);
        Database.insert(objBillServiceType);
        
        BillItem__c objBillItem = GlUt_FactoryData_Test.createBillItem(BILLITEMNAME1, objServiceItem , VOLUMEUSED ,BILLEDAMOUNT, objBillServiceType, HEROKUPOSTGRESID1);
        objBillItem.TotalDiscountAmount__c = DISCOUNTAMOUNT;
        objBillItem.TotalTaxAmount__c = TAXAMOUNT;
        Database.insert(objBillItem);
        
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENTPLANNAME, FREQUENCY, MAXINSTLLMNT);      
        objPaymentPlanType.PlanType__c = PLANTYP;        
        Database.insert(objPaymentPlanType);
        
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType,con,PLANAMOUNT);
        Database.insert(objPaymentPlan);
        
        Instalment__c objInstalment = GlUt_FactoryData_Test.createInstalment(objPaymentPlan);           
        Database.insert(objInstalment);   
        
        List<FinancialTransactionEventType__c> lstFTET = new List<FinancialTransactionEventType__c>();
        
        FinancialTransactionEventType__c  objFinancialTransactionEventType = GlUt_FactoryData_Test.createFinancialTransactionEventType();
        objFinancialTransactionEventType.Name = FTET_NAME;
        objFinancialTransactionEventType.Category__c = FTET_CATEGORY;
        objFinancialTransactionEventType.Object__c = FcUt_Constants.BILLITEM;
        objFinancialTransactionEventType.Name__c = FTET_NAME_C;
        lstFTET.add(objFinancialTransactionEventType);
        
        FinancialTransactionEventType__c  objFinancialTransactionEventType1 = GlUt_FactoryData_Test.createFinancialTransactionEventType();
        objFinancialTransactionEventType1.Name = FTET_NAME_1;
        objFinancialTransactionEventType1.Category__c = FcUt_Constants.REFUND;
        objFinancialTransactionEventType1.Object__c = FcUt_Constants.PAYMENT;
        objFinancialTransactionEventType1.Name__c = FcUt_Constants.REFUND;
        lstFTET.add(objFinancialTransactionEventType1);
        
        FinancialTransactionEventType__c  objFinancialTransactionEventType2 = GlUt_FactoryData_Test.createFinancialTransactionEventType();
        objFinancialTransactionEventType2.Name = FTET_NAME_2;
        objFinancialTransactionEventType2.Category__c = FcUt_Constants.PAYMENT;
        objFinancialTransactionEventType2.Object__c = FcUt_Constants.PAYMENT;
        objFinancialTransactionEventType2.Name__c = FcUt_Constants.PAYMENT;
        lstFTET.add(objFinancialTransactionEventType2);
        
        FinancialTransactionEventType__c  objFinancialTransactionEventType3 = GlUt_FactoryData_Test.createFinancialTransactionEventType();
        objFinancialTransactionEventType3.Name = FTET_NAME_3;
        objFinancialTransactionEventType3.Object__c = FcUt_Constants.PAYALLOC;
        objFinancialTransactionEventType3.Name__c = FcUt_Constants.PAYMENT;
        lstFTET.add(objFinancialTransactionEventType3);
        
        FinancialTransactionEventType__c  objFinancialTransactionEventType4 = GlUt_FactoryData_Test.createFinancialTransactionEventType();
        objFinancialTransactionEventType4.Name = FTET_NAME_4;
        objFinancialTransactionEventType4.Object__c = FcUt_Constants.AMENDMENT;
        objFinancialTransactionEventType4.Name__c = AMENDMENT_REASON;
        lstFTET.add(objFinancialTransactionEventType4);
        Database.insert(lstFTET);
        
        //Create Payment record        
        Payment__c objPayment= GlUt_FactoryData_Test.createPayment(objAccount, con);
        objPayment.RecordTypeId = PAYMENTRECORDTYPE;
        objPayment.CreditAmount__c = CREDITAMT1;
        Database.insert(objPayment);
    }
    /******************************************************************************
    @author:      Echo: Swati
    @date:        11-Apr-2018
    @description: 
    *******************************************************************************/
    static testmethod void ProcessBillItem_Positive(){
        //Query user record created in test setup data method
        User objUser = [SELECT Id,
                        Name,
                        Profile.Name
                        FROM User
                        WHERE isActive=TRUE AND
                        Username =: USERNAMECOMPLETE LIMIT 1];
        ServiceItem__c objServItem = [SELECT Id FROM ServiceItem__c LIMIT 1];
        Bill__c objBill = [SELECT Id FROM Bill__c LIMIT 1];
        BillServiceType__c objBillServType = [SELECT Id FROM BillServiceType__c LIMIT 1];
        
        // Create Bill Item Record
        BillItem__c objBillItem = GlUt_FactoryData_Test.createBillItem(BILLITEMNAME2, objServItem , VOLUMEUSED ,BILLEDAMOUNT, objBillServType, HEROKUPOSTGRESID2);  
            objBillItem.Bill__c = objBill.Id;
            objBillItem.TotalDiscountAmount__c = DISCOUNTAMOUNT;
            objBillItem.TotalTaxAmount__c = TAXAMOUNT;
            objBillItem.OriginalCalculationDate__c = System.today();
        
        //Run test class in user context        
        System.runAs(objUser){ 
            Test.startTest();
            Database.insert(objBillItem);
            Test.stopTest();   
            
            List<FinancialControl__c> listFCR = [SELECT Id,Name FROM FinancialControl__c WHERE BillItem__c =: objBillItem.Id];
            System.assert(!listFCR.isEmpty());
        }
    }
    /******************************************************************************
    @author:      Echo: Swati
    @date:        11-Apr-2018
    @description: 
    *******************************************************************************/
    static testmethod void ProcessPayment_Positive(){
        //Query user record created in test setup data method
        User objUser = [SELECT Id,
                        Name,
                        Profile.Name
                        FROM User
                        WHERE isActive=TRUE AND
                        Username =: USERNAMECOMPLETE LIMIT 1];
        
        Account objAcc = [SELECT Id FROM Account LIMIT 1];
        BillingContract__c objCon = [SELECT Id FROM BillingContract__c LIMIT 1];
        
        //Create Payment record
        Payment__c objPayment= GlUt_FactoryData_Test.createPayment(objAcc, objCon); 
        objPayment.RecordTypeId = REFUNDRECORDTYPE;
        
        Payment__c objPayment1= [SELECT id FROM Payment__c WHERE RecordTypeId =:PAYMENTRECORDTYPE];
        objPayment1.CreditAmount__c = CREDITAMT2;
        
        //Run test class in user context        
        System.runAs(objUser){ 
            Test.startTest();
            Database.insert(objPayment); 
            Database.update(objPayment1); 
            Test.stopTest();  
            
            List<FinancialControl__c> listFCR = [SELECT Id,Name FROM FinancialControl__c WHERE Payment__c =: objPayment.Id];
            System.assert(!listFCR.isEmpty());
        }
    }

    /******************************************************************************
    @author:      Echo: Swati
    @date:        13-Apr-2018
    @description: 
    *******************************************************************************/
    static testmethod void ProcessPaymentAllocation_Positive(){
        //Query user record created in test setup data method
        User objUser = [SELECT Id,
                        Name,
                        Profile.Name
                        FROM User
                        WHERE isActive=TRUE AND
                        Username =: USERNAMECOMPLETE LIMIT 1];
        
        BillItem__c objBillItem = [SELECT Id,BilledAmount__c,TotalDiscountAmount__c,TotalTaxAmount__c FROM BillItem__c LIMIT 1];
        Instalment__c objInstalment = [SELECT Id FROM Instalment__c LIMIT 1];
        Payment__c objPayment = [SELECT Id FROM Payment__c LIMIT 1];
        
        //Create Payment Allocation record
        PaymentAllocation__c objPaymentAllocation= GlUt_FactoryData_Test.createPaymentAllocation(PAYMENT_ALLOCATION_NAME, AMOUNTALLOCATED, objBillItem, objInstalment, objPayment);     
        
        //Run test class in user context        
        System.runAs(objUser){ 
            Test.startTest();
            Database.insert(objPaymentAllocation); 
            Test.stopTest();            
            List<FinancialControl__c> listFCR = [SELECT Id,Name FROM FinancialControl__c WHERE PaymentAllocation__c =: objPaymentAllocation.Id];
            System.assert(!listFCR.isEmpty());
        }
    }

    /******************************************************************************
    @author:      Echo: Swati
    @date:        13-Apr-2018
    @description: 
    *******************************************************************************/
    static testmethod void ProcessAmendment_Positive(){
        //Query user record created in test setup data method
        User objUser = [SELECT Id,
                        Name,
                        Profile.Name
                        FROM User
                        WHERE isActive=TRUE AND
                        Username =: USERNAMECOMPLETE LIMIT 1];
        
        BillItem__c objBillItem = [SELECT Id,BilledAmount__c,TotalDiscountAmount__c,TotalTaxAmount__c FROM BillItem__c LIMIT 1];
        Instalment__c objInstalment = [SELECT Id FROM Instalment__c LIMIT 1];
        Payment__c objPayment = [SELECT Id FROM Payment__c LIMIT 1];
        
        
        //Create Payment Allocation record
        BillItemAmendment__c objAmendment= new BillItemAmendment__c();    // MT - 14-08-2018 3174
        objAmendment.Name = AMENDMENT_NAME;
        objAmendment.HerokuPostgresId__c = HEROKUPOSTGRESID1;
        objAmendment.AmendmentReason__c = AMENDMENT_REASON;
        objAmendment.AmendedBillItem__c = objBillItem.Id;
        objAmendment.Amount__c = AMENDMENTAMOUNT;
        objAmendment.DiscountAmount__c = DISCOUNTAMOUNT;
        objAmendment.TaxAmount__c = TAXAMOUNT;
        
        //Run test class in user context        
        System.runAs(objUser){ 
            Test.startTest();
            Database.insert(objAmendment); 
            Test.stopTest();            
            List<FinancialControl__c> listFCR = [SELECT Id,Name FROM FinancialControl__c WHERE Amendment__c =: objAmendment.Id];
            System.assert(!listFCR.isEmpty());
        }
    }
    
}