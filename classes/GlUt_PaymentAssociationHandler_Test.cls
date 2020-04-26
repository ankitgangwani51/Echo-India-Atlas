/******************************************************************************
@author:      Echo: Neha
@date:        07 Dec 2018
@description: Test Class for GlUt_PaymentAssociationHandler_Test
*******************************************************************************/

@isTest
public class GlUt_PaymentAssociationHandler_Test {
   
    //Variable declaration start
    private static String USERPROFILE = 'System Administrator';
    private static final String USERFNAME= 'TestFName';
    private static final String USERLNAME= 'TestLName';
    private static String USERNAME = 'TestUser';
    private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com'; 
    private static String ACCOUNTNAME = 'TestAccount';
    private static String ACCOUNTNAME1 = 'TestAccount_1';
    private static String PAYMENTALLOCATIONNAME = 'TestPaymentAllocation';
    private static String BILLINGSTREET ='Test Street';
    private static String BILLINGCITY = 'Test City';
    private static String BILLINGSTATE = 'Test State';
    private static String BILLINGPOSTCODE ='0000000';
    private static String BILLINGCOUNTRY ='Test Country';
    private static integer LISTSIZE = 200; 
    private static integer LISTSTART = 0;
    private static String PAYMENTPLANTYPENAME = 'Test Payment Plan Type1';
    private static String FREQUENCY = 'Monthly';
    private static Integer MAXINSTALMENT = 12;
    private static Integer PLANAMOUNT = 12345;
    private static Integer NUMBEROFINSTALMENTS = 07; 
    private static Integer INSTALMENTAMOUNTDUE = 100; 
    private static String PLANTYPE = 'Instalment Plan';
    private static final String SPUSAGETYPE = 'SupplyPointUsageType';
    private static String DEVICENAME = 'TestDevice';
    private static String DEVICETYPE ='TestDeviceType';
    private static final String DEVICESIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNITOFMEASURE = 'Metric';
    private static String TESTSERVICETYPE ='TestServiceType';
    private static String LOCATIONNAME ='A99 9AA';
    private static String WHOLESALER ='TestWholesaler';
    private static String YES ='yes';
    private static String MEASURED = 'Monthly';
    private static String AVAILABLESERVICES ='TestAvailableService';
    private static String SERVICEITEMFAMILY ='TestServiceItemFamily';
    private static String SERVICEITEMTYPE ='TestServiceitemtype';
    private static String BUNDLE ='TestBundle';
    private static String AVAILABLEBUNDLE ='TestAvailableBundle';
    private static String BUNDLEITEM ='TestBundleItem';
    private static String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static String BILLNAME = 'testBill';
    private static String BILLSERVICENAME = 'Test Bill Service';
    private static String BILLITEMNAME = 'Test Bill Item';
    private static Integer VOLUMEUSED = 200;
    private static Integer BILLEDAMOUNT = 67878;
    private static String HEROKUPOSTGRESID = 'Test ID';
    private static Decimal PAYMENT_AMT = 120;    
    private static Decimal UNALLOCATED_AMT = 50;
    // Trigger Specific variables
    private static Integer MAXDMLSTATEMENTS = 50;
    private static Integer MAXQUERIES       = 70;
    private static String LIMITCONST1       =  'Fewer than ';
    private static String LIMITCONST2       =  ' DML statements should have been executed : ';
    private static String LIMITCONST3       =  ' SOQL statements should have been executed : ';
    
    
    private static final String FTET_NAME      = 'FTET';
    private static final String FTET_NAME_1      = 'FTET-1';
    private static final String FTET_NAME_2      = 'FTET-2';
    private static final String FTET_NAME_3      = 'FTET-3';
    private static final String FTET_NAME_4      = 'FTET-4';
    private static final String FTET_CATEGORY    = 'Bill Calculation';
    private static final String FTET_NAME_C      = 'Agent Real Time Bill Calculation';
    private static final String AMENDMENT_REASON = 'Manual Amendment';
    
    /*******************************************************************
    Purpose: Method is used to Test Setup in test class.
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/     
    @TestSetup
    static void createTestData(){
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(USERPROFILE,USERNAME,NULL);
        objUser.FirstName = USERFNAME;
        objUser.LastName = USERLNAME;
        Database.insert(objUser); 
       
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNTNAME);
        Database.insert(objAccount);
                
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);
        Database.insert(objBalance);  
        
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(' ',objAccount);
        objContract.BillingStreet__c=BILLINGSTREET;
        objContract.BillingCity__c=BILLINGCITY;
        objContract.BillingState__c=BILLINGSTATE;
        objContract.BillingPostalCode__c=BILLINGPOSTCODE;
        objContract.BillingCountry__c=BILLINGCOUNTRY;
        objContract.Balance__c=objBalance.Id; 
        Database.insert(objContract);
            
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENTPLANTYPENAME, FREQUENCY, MAXINSTALMENT);
        objPaymentPlanType.PlanType__c = PLANTYPE;
        Database.insert(objPaymentPlanType);
        
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType,objContract,PLANAMOUNT);
        Database.insert(objPaymentPlan);
        
        Instalment__c objInstalment = new Instalment__c(PaymentPlan__c= objPaymentPlan.Id, InstalmentDueDate__c= system.today());
        Database.insert(objInstalment);
       
        Bill__c objBill = GlUt_FactoryData_Test.CreateBill(BILLNAME ,objContract);
        objBill.Account__c = objAccount.id; //AT-3174
        Database.insert(objBill);        
       
        BillServiceType__c objBillServiceType = GlUt_FactoryData_Test.createBillServiceType(BILLSERVICENAME, objBill, HEROKUPOSTGRESID);
        Database.insert(objBillServiceType);
        
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICESIZE);
        Database.insert(objDeviceSize);        
        
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNITOFMEASURE);
        Database.insert(objDeviceType);
        
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICENAME ,objDeviceType );
        Database.insert(objDevice);
                
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading); 
        
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATIONNAME);
        Database.insert(objLocation);
        
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SPUSAGETYPE);
        Database.insert(objSupplyPointUsageType);
        
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
  
        Database.insert(objSupplyPoint);
        
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        SupplyPointDevice__c  objSPD = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice,objSupplyPoint);
        Database.insert(objSPD);
        
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICETYPE );
        Database.insert(objServiceType);
        
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);
        
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.CreateServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.CreateServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);
        
        Bundle__c objBundle = GlUt_FactoryData_Test.CreateBundle(BUNDLE,objServiceType);
        Database.insert(objBundle);
        
        AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.CreateAvailableBundle(AVAILABLEBUNDLE,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.CreateBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
        
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.CreateAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        Database.insert(objAvailableServiceItem);         
        
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.CreateServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        Database.insert(objServiceItem);
        
        BillItem__c objBillItems = GlUt_FactoryData_Test.createBillItem(BILLITEMNAME, objServiceItem , VOLUMEUSED ,BILLEDAMOUNT, objBillServiceType, HEROKUPOSTGRESID);
        Database.insert(objBillItems);
        
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
        
        Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAccount,objContract);
        objPayment.Amount__c = PAYMENT_AMT;
        Database.insert(objPayment);               
    }
    
    /*******************************************************************
    Purpose: Test for payment have no unAllocated amount
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void insertPaymentAssociationWithNoUnAmt(){
        
        //Query user record created in test setup data method
        User objUser = [SELECT id,name FROM user WHERE isActive = TRUE AND username =: USERNAMECOMPLETE LIMIT 1];        
        Account objAcc = [SELECT id FROM Account WHERE name =:ACCOUNTNAME ];
        BillingContract__c objCon = [SELECT id FROM BillingContract__c WHERE Balance__c!= NULL]; 
        Payment__c objPay = [SELECT id,Amount__c,Account__c FROM Payment__c LIMIT 1];          
        ID recordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(System.Label.PyAp_ReturnTransferPaymentRecordType).getRecordTypeId();
        
        Payment__c newNegativePayment = GlUt_FactoryData_Test.createPayment(objAcc,objCon);
        newNegativePayment.Amount__c = Decimal.valueOf('-' + objPay.Amount__c);                       
        newNegativePayment.RecordTypeId = recordTypeId;
        newNegativePayment.Transferred__c = System.Label.PyAp_ReturnPaymentTransferred;
        objPay.AmendmentReason__c = System.Label.PyAp_ReturnPaymentAmendReason;
        objPay.ReversedAmount__c = objPay.Amount__c;
        Database.update(objPay);
        Database.insert(newNegativePayment);
        
        
        //Run test class in user context
        system.runas(objUser)
        {
            Test.startTest();
            PaymentAssociation__c objPaymentAssociation = GlUt_FactoryData_Test.createPaymentAssociation(objPay,newNegativePayment);
            Database.insert(objPaymentAssociation);
            system.assert(objPaymentAssociation != null);
            Test.stopTest();
        }    
    }
    
     /*******************************************************************
    Purpose: Test for payment with unAllocated amount
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void insertPaymentAssociationWithUnAmt(){
        
        //Query user record created in test setup data method
        User objUser = [SELECT id,name FROM user WHERE isActive = TRUE AND username =: USERNAMECOMPLETE LIMIT 1];        
        Account objAcc = [SELECT id FROM Account WHERE name =:ACCOUNTNAME ];
        BillingContract__c objCon = [SELECT id FROM BillingContract__c WHERE Balance__c!= NULL]; 
        Payment__c objPay = [SELECT id,Amount__c,Account__c FROM Payment__c LIMIT 1];          
        
        ID recordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get(System.Label.PyAp_ReturnTransferPaymentRecordType).getRecordTypeId();
        
        Payment__c newNegativePayment = GlUt_FactoryData_Test.createPayment(objAcc,objCon);
        newNegativePayment.Amount__c = Decimal.valueOf('-' + objPay.Amount__c);                       
        newNegativePayment.RecordTypeId = recordTypeId;
        newNegativePayment.Transferred__c = System.Label.PyAp_ReturnPaymentTransferred;
        objPay.AmendmentReason__c = System.Label.PyAp_ReturnPaymentAmendReason;
        objPay.ReversedAmount__c = objPay.Amount__c;
        objPay.BillAmountUnallocated__c = UNALLOCATED_AMT;
        Database.update(objPay);
        Database.insert(newNegativePayment);
        
        
        //Run test class in user context
        system.runas(objUser)
        {
            Test.startTest();
            PaymentAssociation__c objPaymentAssociation = GlUt_FactoryData_Test.createPaymentAssociation(objPay,newNegativePayment);
            Database.insert(objPaymentAssociation);
            system.assert(objPaymentAssociation != null);
            Test.stopTest();
        }
        
    }

}