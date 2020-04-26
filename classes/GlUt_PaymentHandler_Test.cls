/******************************************************************************
@author:      Echo: Swati Mathur
@date:        14 February 2018
@description: Test Class for GlUt_InstalmentHandler
*******************************************************************************/

@isTest
public class GlUt_PaymentHandler_Test {
   
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
        
    // Trigger Specific variables
    private static Integer MAXDMLSTATEMENTS = 50;
    private static Integer MAXQUERIES       = 70;
    private static String LIMITCONST1       =  'Fewer than ';
    private static String LIMITCONST2       =  ' DML statements should have been executed : ';
    private static String LIMITCONST3       =  ' SOQL statements should have been executed : ';
    
    /*******************************************************************
    Purpose: Method is used to Test Setup in test class.
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
	@revesion	   Change By Dependra Singh- 25-02-2019- Salesforce Limit Analysis
    ********************************************************************/     
    @TestSetup
    static void createTestData(){
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(USERPROFILE,USERNAME,NULL);
        objUser.FirstName = USERFNAME;
        objUser.LastName = USERLNAME;
        Database.insert(objUser); 
       
        List<Account> lstAccount = new List<Account>();
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNTNAME);
        lstAccount.add(objAccount);
        Account objAccount1 = GlUt_FactoryData_Test.CreateAccount(ACCOUNTNAME1);
        lstAccount.add(objAccount1);
        insert lstAccount;
        List<BillingContract__c> lstBilllingContract = new List<BillingContract__c>();
        
        if(lstAccount != null && !lstAccount.isEmpty()){
            Balance__c objBalance = GlUt_FactoryData_Test.createBalance(lstAccount[0]);
            Database.insert(objBalance);  
            BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(' ',lstAccount[0]);
            objContract.BillingStreet__c=BILLINGSTREET;
            objContract.BillingCity__c=BILLINGCITY;
            objContract.BillingState__c=BILLINGSTATE;
            objContract.BillingPostalCode__c=BILLINGPOSTCODE;
            objContract.BillingCountry__c=BILLINGCOUNTRY;
            objContract.Balance__c=objBalance.Id; 
            lstBilllingContract.add(objContract);
            //Database.insert(objContract);
            
            BillingContract__c objContract1 = GlUt_FactoryData_Test.CreateContract(' ',lstAccount[1]);
            objContract1.BillingStreet__c=BILLINGSTREET;
            objContract1.BillingCity__c=BILLINGCITY;
            objContract1.BillingState__c=BILLINGSTATE;
            objContract1.BillingPostalCode__c=BILLINGPOSTCODE;
            objContract1.BillingCountry__c=BILLINGCOUNTRY;
            lstBilllingContract.add(objContract1);
            insert lstBilllingContract;
        }
        
       
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENTPLANTYPENAME, FREQUENCY, MAXINSTALMENT);
        objPaymentPlanType.PlanType__c = PLANTYPE;
        Database.insert(objPaymentPlanType);
        
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType,lstBilllingContract[0],PLANAMOUNT);
        Database.insert(objPaymentPlan);
        
        Instalment__c objInstalment = new Instalment__c(PaymentPlan__c= objPaymentPlan.Id, InstalmentDueDate__c= system.today());
        Database.insert(objInstalment);
       
        Bill__c objBill = GlUt_FactoryData_Test.CreateBill(BILLNAME ,lstBilllingContract[0]);
        objBill.Account__c = lstAccount[0].id; //AT-3174
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
        
        Service__c  objService = GlUt_FactoryData_Test.CreateService(lstBilllingContract[0],objReading,objServiceType,objSupplyPoint,objAvailableService);
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
                
        
    }
    
    /*******************************************************************
    Purpose: Test bulk Insert for Instalment
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/ 
    
    static testmethod void insertPayment1_Bulk(){
        
        //Query user record created in test setup data method
        User objUser = [SELECT id,name FROM user WHERE isActive = TRUE AND username =: USERNAMECOMPLETE LIMIT 1];        
        Account objAcc = [SELECT id FROM Account WHERE name =:ACCOUNTNAME ];
        BillingContract__c objCon = [SELECT id FROM BillingContract__c WHERE Balance__c!= NULL AND AccountName__c=:objAcc.Id LIMIT 1]; 
        List<Payment__c> lstPayment = new List<Payment__c>();
        for(integer i=LISTSTART; i<LISTSIZE; i++){
            
            Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAcc, objCon);
            lstPayment.add(objPayment);
        }       
        
        lstPayment[0].RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
        lstPayment[1].RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId();
        //Run test class in user context
        system.runas(objUser)
        {
            Test.startTest();
            Database.insert(lstPayment);
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }        
    }
   
    /*******************************************************************
    Purpose: Test bulk Insert for Instalment
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/ 
    static testmethod void insertPayment2_Bulk(){
        
        //Query user record created in test setup data method
        User objUser = [SELECT id,name FROM user WHERE isActive = TRUE AND username =: USERNAMECOMPLETE LIMIT 1];        
        Account objAcc = [SELECT id FROM Account WHERE name =:ACCOUNTNAME1 ];
        BillingContract__c objCon = [SELECT id FROM BillingContract__c WHERE AccountName__c=:objAcc.Id LIMIT 1];
        
        objCon.Balance__c=null;
        update objCon;
        
        List<Payment__c> lstPayment = new List<Payment__c>();
        for(integer i=LISTSTART; i<LISTSIZE; i++)
        {
          Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAcc, objCon);
          lstPayment.add(objPayment);
        }
        
        //Run test class in user context
        system.runas(objUser)
        {
            Test.startTest();
            Database.insert(lstPayment);
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }        
    }
    /*******************************************************************
    Purpose: Test bulk Insert for Instalment
    Returns: void
    Throws [Exceptions]: N/A  
    ********************************************************************/ 
    static testmethod void updatePayment1_Bulk(){
        
        //Query user record created in test setup data method
        User objUser = [SELECT id,name FROM user WHERE isActive = TRUE AND username =: USERNAMECOMPLETE LIMIT 1];        
        Account objAcc = [SELECT id FROM Account WHERE name =:ACCOUNTNAME ];
        BillingContract__c objCon = [SELECT id FROM BillingContract__c WHERE AccountName__c=:objAcc.Id LIMIT 1];
        
        objCon.Balance__c=null;
        update objCon;
            
        List<Payment__c> lstPayment = new List<Payment__c>();
        for(integer i=LISTSTART; i<LISTSIZE; i++)
        {
            Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAcc, objCon);
            lstPayment.add(objPayment);
        }
                
        Database.insert(lstPayment); 
        
        for(integer i=LISTSTART; i<LISTSIZE; i++)
        {
            lstPayment[i].ReversedAmount__c  = 100 * i;
        }
        
        Instalment__c objInstalment = [SELECT id FROM Instalment__c];
        BillItem__c objBillItem = [SELECT id FROM BillItem__c];
                
        //Create Payment Allocation record
        PaymentAllocation__c objPaymentAllocation= GlUt_FactoryData_Test.createPaymentAllocation(PAYMENTALLOCATIONNAME, 100.00, objBillItem, objInstalment, lstPayment[0]);
        Database.insert(objPaymentAllocation);
        
        //Run test class in user context
        system.runas(objUser)
        {
            Test.startTest();
            Database.update(lstPayment);
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }
    }
    /*******************************************************************
    Purpose: Test bulk Insert for Instalment
    Returns: void
    Throws [Exceptions]: N/A  
    ********************************************************************/     
    static testmethod void updatePayment2_Bulk(){
        //Query user record created in test setup data method
        
        User objUser = [SELECT id,name FROM user WHERE isActive = TRUE AND username =: USERNAMECOMPLETE LIMIT 1];        
        Account objAcc = [SELECT id FROM Account WHERE name =:ACCOUNTNAME ];
        BillingContract__c objCon = [SELECT id FROM BillingContract__c WHERE Balance__c!= NULL AND AccountName__c=:objAcc.Id LIMIT 1]; 
            
        List<Payment__c> lstPayment = new List<Payment__c>();
        for(integer i=LISTSTART; i<LISTSIZE; i++)
        {
            Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAcc, objCon);
            lstPayment.add(objPayment);
        }
        Database.insert(lstPayment); 
        
        for(integer i=LISTSTART; i<LISTSIZE; i++)
        {
            lstPayment[i].ReversedAmount__c  = 120;
        }
        
        
        //Run test class in user context
        system.runas(objUser)
        {
            Test.startTest();
            Database.update(lstPayment);
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }
    } 
    /*******************************************************************
    Purpose: Test bulk Insert for Instalment
    Returns: void
    Throws [Exceptions]: N/A  
    ********************************************************************/ 
    static testmethod void updatePayment3_Bulk(){
        
        //Query user record created in test setup data method
        
        User objUser = [SELECT id,name FROM user WHERE isActive = TRUE AND username =: USERNAMECOMPLETE LIMIT 1];        
        Account objAcc = [SELECT id FROM Account WHERE name =:ACCOUNTNAME ];
        BillingContract__c objCon = [SELECT id FROM BillingContract__c WHERE Balance__c!= NULL AND AccountName__c=:objAcc.Id LIMIT 1]; 
        
        List<Payment__c> lstPayment = new List<Payment__c>();
        for(integer i=LISTSTART; i<LISTSIZE; i++)
        {
            Payment__c objPayment = GlUt_FactoryData_Test.createPayment(objAcc, objCon);
            lstPayment.add(objPayment);
        }
        Database.insert(lstPayment); 
        
        for(integer i=LISTSTART; i<LISTSIZE; i++)
        {
            lstPayment[i].ReversedAmount__c  = 100 * i;
        }
        lstPayment[0].ReversedAmount__c  = 120;
        
        
        //Run test class in user context
        system.runas(objUser)
        {
            Test.startTest();
            Database.update(lstPayment);
            //Asserts to check bulk limits
            System.assert( Limits.getDMLStatements() < MAXDMLSTATEMENTS, LIMITCONST1 + MAXDMLSTATEMENTS + LIMITCONST2 + Limits.getDMLStatements()  );
            System.assert( Limits.getQueries()       < MAXQUERIES      , LIMITCONST1 + MAXQUERIES + LIMITCONST3 + Limits.getQueries()  );
            Test.stopTest();
        }
    }
}