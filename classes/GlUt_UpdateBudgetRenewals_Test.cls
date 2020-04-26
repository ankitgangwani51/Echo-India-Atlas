/******************************************************************************
@author:      Echo: Tarun Gupta
@date:        06 June 2018
@description: Test Class for GlUt_UpdateBudgetRenewals
*******************************************************************************/
@isTest
Private class GlUt_UpdateBudgetRenewals_Test {
    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='FN123LN123'; 
    private static final String USER_FNAME= 'FN123';
    private static final String USER_LNAME= 'LN123';
    
    private static String PAYMENT_METHOD_TYPE1 = 'Payment Card';
    private static String PLAN_NAME = 'MEASURED MONTHLY';
    private static String PAY_FREQ = 'Monthly';
    private static Integer NUM_OF_INSTAL = 12;
    private static Integer NUM_OF_ROLLING_INSTAL = 2;
    
    private static String AVAIL_PAY_DAY_NAME = 'APD Monday';
    private static String DAY_OF_MONTH = '2';
    private static String DAY_OF_WEEK = 'Monday';
    private static String ACCOUNT_NAME = 'Test Account';
    private static String CONTACT_NAME = 'Test Contact';
    private static Double AMOUNT = 100.0;
    private static Double FORECAST_AMOUNT = 200.0;
    private static Double PAYPLAN_AMOUNT = 500.0;
    private static String MONTHLY = Label.CuAp_PaymentPlanTypePaymentFrequencyMonthly;
    
    private static final String TESTSERVICE_TYPE1   = 'TestServiceType1';
    private static final String LIBRARIES           = 'Libraries'; 
    private static final String OLDDEVICE_SERIALNO  = '1234';
    private static final String TEST_DEPOT  = 'Test Depot';
    private static final String TEST_READ_TIMETABLE     = 'Test Read Timetable';
    
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String TEST_SERVICE_TYPE ='TestServiceType';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String LOCATION_NAME ='A99 9AA';
    private static final String LOCATION_SUB_TYPE = 'Detached';
    private static final String STREET = 'teststreet';
    private static final String YES ='yes';
    private static final String MEASURED = 'Monthly';
    private static final String WHOLESALER ='TestWholesaler';
    private static final String AVAILABLESERVICES ='TestAvailableService';    
    
    /******************************************************************************
@author:      Echo: Tarun Gupta
@date:        06 June 2018
@description: Test method for amendPPInstalments() method
*******************************************************************************/
    
    @TestSetup
    Static void createTestData(){
        
        //Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        //Create payment method type Record        
        PaymentMethodType__c  objPaymentMethodType = GlUt_FactoryData_Test.createPaymentMethodType();
        objPaymentMethodType.Name = PAYMENT_METHOD_TYPE1;
        Database.insert(objPaymentMethodType);        
        
        //Create payment plan type Record
        PaymentPlanType__c  objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PLAN_NAME,PAY_FREQ,NUM_OF_INSTAL);
        objPaymentPlanType.PlanType__c = Label.CuAp_PaymentPlanTypePlanTypeBudgetPlan;
        objPaymentPlanType.FinalPaymentPlan__c = false;
        objPaymentPlanType.DaysNotice__c = 10;
        objPaymentPlanType.Active__c = true;
        objPaymentPlanType.PaymentFrequency__c = MONTHLY;
        objPaymentPlanType.NumberofRollingInstalments__c = NUM_OF_ROLLING_INSTAL;
        objPaymentPlanType.RenewalFrequency__c = '3';
        Database.insert(objPaymentPlanType);        
        
        //Create payment method Record
        PaymentMethod__c  objPaymentMethod = GlUt_FactoryData_Test.createPaymentMethod(objPaymentMethodType,objPaymentPlanType);
        Database.insert(objPaymentMethod);
        
        //Create available payment day Record
        AvailablePaymentDay__c  objAvailPaymentDay = GlUt_FactoryData_Test.createAvailPaymentDay(AVAIL_PAY_DAY_NAME,DAY_OF_MONTH,DAY_OF_WEEK,objPaymentMethodType);
        Database.insert(objAvailPaymentDay);
        
        //Create account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        //Create Balance Record
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);
        Database.insert(objBalance);
        
        //Create Balance Transaction Record
        BalanceTransaction__c objBalanceTransaction = GlUt_FactoryData_Test.createBalanceTransaction(objBalance);
        //objBalanceTransaction.BillItemAmount__c = AMOUNT; // AT-3275
        objBalanceTransaction.BillAmount__c = AMOUNT; // AT-3275
        objBalanceTransaction.RecordTypeId = Schema.SObjectType.BalanceTransaction__c.getRecordTypeInfosByName().get('Bill').getRecordTypeId(); // AT-3275
        Database.insert(objBalanceTransaction);
        
        //Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTACT_NAME,objAccount);
        objContract.DayOfMonth__c = DAY_OF_MONTH;
        objContract.DayOfWeek__c = DAY_OF_WEEK;
        objContract.CurrentPaymentPlanType__c = objPaymentPlanType.Id;
        objContract.Balance__c = objBalance.Id;
        objContract.PaymentMethodType__c = objPaymentMethodType.id;
        Database.insert(objContract);
        
        //Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);       
        
        //Create Service Type Record - 1
        ServiceType__c objServiceType1 = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE1);
        Database.insert(objServiceType1);        
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Create Depot Record
        Depot__c objDepot = GlUt_FactoryData_Test.createDepot(TEST_DEPOT);
        Database.insert(objDepot);
        
        //Create Read Timetable Record
        ReadTimetable__c objReadTimeTable = GlUt_FactoryData_Test.createReadTimetable(TEST_READ_TIMETABLE,MONTHLY);
        Database.insert(objReadTimeTable);
        
        //Create Book Record
        Book__c objBook = GlUt_FactoryData_Test.createBook(objDepot,objReadTimeTable);
        objBook.BudgetResetMonth__c = 'April;September;November';
        objBook.ReadFrequency__c = MEASURED;
        Database.insert(objBook);
        
        //Create Supply Point Record
        SupplyPoint__c  objSupplyPoint1 = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint1.Measured__c = True; // AT-3174 
  
        objSupplyPoint1.SpecialInstructions__c = LIBRARIES;
        objSupplyPoint1.Book__c = objBook.Id;
        Database.insert(objSupplyPoint1);
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record
        Device__c  objOldDevice = GlUt_FactoryData_Test.CreateDevice(OLDDEVICE_SERIALNO , objDeviceType);        
        objOldDevice.SerialNo__c = OLDDEVICE_SERIALNO;
        Database.insert(objOldDevice);
        
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objOldDevice);
        Database.insert(objReading);
        
        // Create Division Record
        Division__c  objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        // Create Wholesaler Record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        // Create Available Service Record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType1,objSupplyPoint1,objWholesaler);
        Database.insert(objAvailableService);
        
        // Create Service Record 
        Service__c  objOldService1 = GlUt_FactoryData_Test.CreateService(objContract, objReading , objServiceType1, objSupplyPoint1, objAvailableService);
        objOldService1.SupplyPoint__c = objSupplyPoint1.Id;
        Database.insert(objOldService1);
        
    }
    
    /******************************************************************************
@author:      Echo: Tarun Gupta
@date:        06 June 2018
@description: Test method for amendPPInstalments() method, Here Else case will work where Instalments needs to be added
*******************************************************************************/
    
    static testmethod void amendPPInstalments_AddInstalments(){               
        
        List<User> objUser = [SELECT Id, 
                              Name, 
                              FirstName, 
                              LastName 
                              FROM User 
                              WHERE isActive = TRUE 
                              AND LastName = :USER_LNAME];
        
        Account objAccount = [Select Id,
                              Name 
                              FROM Account
                              WHERE Name =: ACCOUNT_NAME LIMIT 1];
        
        BillingContract__c objContract = [Select Id,
                                   Name,
                                   CurrentPaymentPlanType__c
                                   FROM BillingContract__c 
                                   WHERE AccountName__c =: objAccount.id  LIMIT 1];
        
        PaymentPlanType__c objPaymentPlanType = [SELECT Id,
                                                 Name,
                                                 PlanType__c,
                                                 PaymentFrequency__c,
                                                 MaximumNumberOfInstalments__c,
                                                 NumberofRollingInstalments__c
                                                 FROM PaymentPlanType__c
                                                 WHERE Active__c = true LIMIT 1];
        
        PaymentPlan__c objPaymentPlan = new PaymentPlan__c(BillingContract__c = objContract.Id,//AT-3174
                                                           ForecastAmount__c = FORECAST_AMOUNT,
                                                           PaymentPlanTotal__c = PAYPLAN_AMOUNT,
                                                           PaymentPlanType__c = objPaymentPlanType.Id,
                                                           StartDate__c = system.today() + 5);
        
        List<Instalment__c> listInstalments = new List<Instalment__c>();
        
        Instalment__c objInst1 = new Instalment__c(Type__c= Label.CuAp_InstalmentTypeNormal,  InstalmentNumber__c=1, InstalmentAmountDue__c=2343.79, InstalmentDueDate__c= objPaymentPlan.StartDate__c);
        Instalment__c objInst2 = new Instalment__c(Type__c= Label.CuAp_InstalmentTypeNormal,  InstalmentNumber__c=2, InstalmentAmountDue__c=2343.79, InstalmentDueDate__c= objPaymentPlan.StartDate__c.addMonths(1));    
        Instalment__c objInst3 = new Instalment__c(Type__c= Label.CuAp_InstalmentTypeRolling, InstalmentNumber__c=3, InstalmentAmountDue__c=2343.79, InstalmentDueDate__c= objPaymentPlan.StartDate__c.addMonths(2));
        Instalment__c objInst4 = new Instalment__c(Type__c= Label.CuAp_InstalmentTypeRolling, InstalmentNumber__c=4, InstalmentAmountDue__c=2343.79, InstalmentDueDate__c= objPaymentPlan.StartDate__c.addMonths(3));
        
        listInstalments.add(objInst1);
        listInstalments.add(objInst2);
        listInstalments.add(objInst3);
        listInstalments.add(objInst4);
        
        List<Book__c> bookList = new List<Book__c>();
        
        System.runAs(objUser[0]){
            Test.starttest();
            GlUt_UpdateBudgetRenewals.WrapPaymentPlanInstalments wrapClass = new GlUt_UpdateBudgetRenewals.WrapPaymentPlanInstalments();
            wrapClass = GlUt_UpdateBudgetRenewals.amendPPInstalments(objContract.Id,objPaymentPlan.StartDate__c,objPaymentPlanType,listInstalments, bookList, null); 
            Test.stoptest();
            
            system.debug('wrapClass in Test Class'+ wrapClass.lstInstalmentsToBeAdded);
            system.debug('lstInstalmentsToBeAdded.size'+ wrapClass.lstInstalmentsToBeAdded.size());
            
            if(wrapClass.lstInstalmentsToBeAdded.size() > 0){
                
                Integer indexInstalment = NUM_OF_ROLLING_INSTAL + 1;
                
                Date lastInstalmentDate = Date.newInstance(wrapClass.lstInstalmentsToBeAdded[wrapClass.lstInstalmentsToBeAdded.size() - indexInstalment].InstalmentDueDate__c.year(), wrapClass.lstInstalmentsToBeAdded[wrapClass.lstInstalmentsToBeAdded.size() - indexInstalment].InstalmentDueDate__c.month(), 01);
                //System.assertEquals(wrapClass.contractRenewalDate , lastInstalmentDate);
                System.assert(wrapClass.contractRenewalDate != null);
            }
            
        }
    }
    
    /******************************************************************************
@author:      Echo: Tarun Gupta
@date:        06 June 2018
@description: Test method for amendPPInstalments() method, Here Else case will work where Instalments needs to be added
*******************************************************************************/
    
    static testmethod void amendPPInstalments_RemoveInstalments(){               
        
        List<User> objUser = [SELECT Id, 
                              Name, 
                              FirstName, 
                              LastName 
                              FROM User 
                              WHERE isActive = TRUE 
                              AND LastName = :USER_LNAME];
        
        Account objAccount = [Select Id,
                              Name 
                              FROM Account
                              WHERE Name =: ACCOUNT_NAME LIMIT 1];
        
        BillingContract__c objContract = [Select Id,
                                   Name,
                                   CurrentPaymentPlanType__c
                                   FROM BillingContract__c 
                                   WHERE AccountName__c =: objAccount.id  LIMIT 1];
        
        PaymentPlanType__c objPaymentPlanType = [SELECT Id,
                                                 Name,
                                                 PlanType__c,
                                                 PaymentFrequency__c,
                                                 MaximumNumberOfInstalments__c,
                                                 NumberofRollingInstalments__c
                                                 FROM PaymentPlanType__c
                                                 WHERE Active__c = true LIMIT 1];
        
        PaymentPlan__c objPaymentPlan = new PaymentPlan__c(BillingContract__c = objContract.Id,//AT-3174
                                                           ForecastAmount__c = FORECAST_AMOUNT,
                                                           PaymentPlanTotal__c = PAYPLAN_AMOUNT,
                                                           PaymentPlanType__c = objPaymentPlanType.Id,
                                                           StartDate__c = system.today() + 5);
        
        List<Instalment__c> listInstalments = new List<Instalment__c>();
        Date instalDate = system.today() + 5;
        
        for(Integer icnt=1 ; icnt <= 12 ; icnt++){            
            Instalment__c objInst = new Instalment__c(Type__c= Label.CuAp_InstalmentTypeNormal,  
                                                      InstalmentNumber__c= icnt, 
                                                      InstalmentAmountDue__c=2343.79, 
                                                      InstalmentDueDate__c= instalDate);
            instalDate = instalDate.addMonths(icnt);
            
            listInstalments.add(objInst);
        }
        
        Instalment__c objInst13 = new Instalment__c(Type__c= Label.CuAp_InstalmentTypeRolling, InstalmentNumber__c=3, InstalmentAmountDue__c=2343.79, InstalmentDueDate__c= objPaymentPlan.StartDate__c.addMonths(12));
        Instalment__c objInst14 = new Instalment__c(Type__c= Label.CuAp_InstalmentTypeRolling, InstalmentNumber__c=4, InstalmentAmountDue__c=2343.79, InstalmentDueDate__c= objPaymentPlan.StartDate__c.addMonths(13));        
        
        listInstalments.add(objInst13);
        listInstalments.add(objInst14);
        List<Book__c> bookList = new List<Book__c>();
        System.runAs(objUser[0]){
            Test.starttest();
            GlUt_UpdateBudgetRenewals.WrapPaymentPlanInstalments wrapClass = new GlUt_UpdateBudgetRenewals.WrapPaymentPlanInstalments();
            wrapClass = GlUt_UpdateBudgetRenewals.amendPPInstalments(objContract.Id,objPaymentPlan.StartDate__c,objPaymentPlanType,listInstalments,bookList,null); 
            Test.stoptest();
            
            system.debug('wrapClass in Test Class'+ wrapClass.lstInstalmentsToBeAdded);
            system.debug('lstInstalmentsToBeAdded.size'+ wrapClass.lstInstalmentsToBeAdded.size());
            
            if(wrapClass.lstInstalmentsToBeAdded.size() > 0){
                
                Integer indexInstalment = NUM_OF_ROLLING_INSTAL + 1;
                
                Date lastInstalmentDate = Date.newInstance(wrapClass.lstInstalmentsToBeAdded[wrapClass.lstInstalmentsToBeAdded.size() - indexInstalment].InstalmentDueDate__c.year(), wrapClass.lstInstalmentsToBeAdded[wrapClass.lstInstalmentsToBeAdded.size() - indexInstalment].InstalmentDueDate__c.month(), 01);

                //System.assertEquals(wrapClass.contractRenewalDate , lastInstalmentDate);
                System.assert(wrapClass.contractRenewalDate != null);
            }
            
        }
    }
    
    /******************************************************************************
@author:      Echo: Tarun Gupta
@date:        04 July 2018
@description: Test method for getListOfBookOnContract() method, 
*******************************************************************************/
    
    static testmethod void getListOfBookOnContract_Positive(){               
        
        List<User> objUser = [SELECT  Id, 
                                      Name, 
                                      FirstName, 
                                      LastName 
                              FROM User 
                              WHERE isActive = TRUE 
                              AND LastName = :USER_LNAME];
        
        Account objAccount = [Select Id,
                              		 Name 
                              FROM Account
                              WHERE Name =: ACCOUNT_NAME LIMIT 1];
        
        Map<Id,BillingContract__c> mapContractId = new Map<Id,BillingContract__c>([Select  Id,
                                                     Name,
                                                     CurrentPaymentPlanType__c
                                             FROM BillingContract__c 
                                             WHERE AccountName__c =: objAccount.id  LIMIT 1]);
        
        
        
        Map<Id,List<Book__c>> mapContractId2bookList = new Map<Id,List<Book__c>>();
        
        System.runAs(objUser[0]){
            Test.starttest();
            mapContractId2bookList = GlUt_UpdateBudgetRenewals.getListOfBookOnContract(mapContractId.keySet()); 
            Test.stoptest(); 
            
            Integer mapCount = mapContractId2bookList.keyset().size();
            
            system.assert(mapCount > 0);
        }
        
        system.debug('mapContractId2bookList--'+ mapContractId2bookList);
    }
    
    /******************************************************************************
@author:      Echo: Tarun Gupta
@date:        07 Sept 2018
@description: Test method for getListOfBookOnContract() method, 
*******************************************************************************/
    
    static testmethod void getListOfBookOnContract_Negative(){               
        
        List<User> objUser = [SELECT  Id, 
                                      Name, 
                                      FirstName, 
                                      LastName 
                              FROM User 
                              WHERE isActive = TRUE 
                              AND LastName = :USER_LNAME];
        
        Map<Id,List<Book__c>> mapContractId2bookList = new Map<Id,List<Book__c>>();
        
        System.runAs(objUser[0]){
            Test.starttest();
            mapContractId2bookList = GlUt_UpdateBudgetRenewals.getListOfBookOnContract(null); 
            Test.stoptest(); 
            
            Integer mapCount = mapContractId2bookList.keyset().size();
            
            system.assert(mapCount == 0);
        }
        
        system.debug('mapContractId2bookList--'+ mapContractId2bookList);
    }
}