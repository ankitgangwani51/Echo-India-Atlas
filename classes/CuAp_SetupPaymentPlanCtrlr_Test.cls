/******************************************************************************
@author:      Echo: Tarun Gupta
@date:        13 Feb 2018
@description: Test Class for CuAp_SetupPaymentPlanCtrlr
*******************************************************************************/
@isTest
Private class CuAp_SetupPaymentPlanCtrlr_Test {
    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='FN123LN123'; 
    private static final String USER_FNAME= 'FN123';
    private static final String USER_LNAME= 'LN123';

	private static String PAYMENT_METHOD_TYPE1 = 'Payment Card';
    private static String PAYMENT_METHOD_TYPE2 = 'Giro Slips';
    private static String PAYMENT_METHOD_TYPE3 = 'Direct Debit';
    private static String PLAN_NAME = 'DD FORTNIGHTLY';
    private static String PAY_FREQ = 'Monthly';
    private static Integer NUM_OF_INSTAL = 3;
    private static String PLAN_NAME2 = Label.CuAp_PaymentPlanTypePlanTypeBudgetPlan;
    private static String PAY_FREQ2 = 'Monthly';
    private static Integer NUM_OF_INSTAL2 = 1;
    private static String PLAN_NAME3 = 'BUDGET PLAN';
    private static String PAY_FREQ3 = 'Fortnightly';
    private static Integer NUM_OF_INSTAL3 = 4;
    private static String PLAN_NAME4 = 'BUDGET PLAN';
    private static String PAY_FREQ4 = 'Weekly';
    private static Integer NUM_OF_INSTAL4 = 4;
    private static String AVAIL_PAY_DAY_NAME = 'APD Monday';
    private static String DAY_OF_MONTH = '2';
    private static String DAY_OF_WEEK = 'Monday';
    private static String ACCOUNT_NAME = 'Test Account';
    private static String ACCOUNT_NAME1 = 'Test Account1';
    private static String ACCOUNT_NAME2 = 'Test Account2';
    private static String ACCOUNT_NAME3 = 'Test Account3';
    private static String CONTACT_NAME = 'Test Contact';
    private static Double AMOUNT = 100.0;
    private static String MONTHLY = Label.CuAp_PaymentPlanTypePaymentFrequencyMonthly;
    
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    
    private static final String DEVICE_NAME = 'TestDevice';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String TEST_SERVICE_TYPE ='TestServiceType';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String LOCATION_NAME ='A99 9AA';
    private static final String LOCATION_SUB_TYPE = 'Detached';
    private static final String STREET = 'teststreet';
    private static final String YES ='yes';
    private static final String MEASURED = 'measured';
    private static final String WHOLESALER ='TestWholesaler';
    private static final String AVAILABLESERVICES ='TestAvailableService';
    
    private static final List < String > contractListFields = new List <String> {
        GlUt_APIConstantsContracts.CUSTOMERAPINAME,
        GlUt_APIConstantsContracts.STATUSAPINAME,
        GlUt_APIConstantsContracts.BALANCEAPINAME
    };
        
    private static final List < String > balanceFieldList = new List <String> {
        GlUt_APIConstantsBalances.BALANCEAMOUNTAPINAME,
        GlUt_APIConstantsBalances.TOTALREFUNDAMOUNTAPINAME
    };
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        12 Dec 2017
    @description: Test method for fetchdevicedata() method
    *******************************************************************************/
    
    @TestSetup
    Static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        Account objAccount1 = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME1);
        Database.insert(objAccount1);

        List<PaymentMethodType__c> listPMT = new List<PaymentMethodType__c>();
		PaymentMethodType__c  objPaymentMethodType = GlUt_FactoryData_Test.createPaymentMethodType();
        objPaymentMethodType.Name = PAYMENT_METHOD_TYPE1;
        listPMT.add(objPaymentMethodType);
        
        PaymentMethodType__c  objPaymentMethodType2 = GlUt_FactoryData_Test.createPaymentMethodType();
        objPaymentMethodType2.Name = PAYMENT_METHOD_TYPE2;
        listPMT.add(objPaymentMethodType2);        
        
        PaymentMethodType__c  objPaymentMethodType3 = GlUt_FactoryData_Test.createPaymentMethodType();
        objPaymentMethodType3.Name = PAYMENT_METHOD_TYPE3;
        listPMT.add(objPaymentMethodType3);
        Database.insert(listPMT);
        
        List<PaymentPlanType__c> listPPT = new List<PaymentPlanType__c>();        
        PaymentPlanType__c  objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PLAN_NAME,PAY_FREQ,NUM_OF_INSTAL);
        objPaymentPlanType.PlanType__c = Label.CuAp_PaymentPlanTypePlanTypePayInFull;
        objPaymentPlanType.FinalPaymentPlan__c = true;
        objPaymentPlanType.DaysNotice__c = 10;
        objPaymentPlanType.Active__c = true;
        objPaymentPlanType.PaymentFrequency__c = MONTHLY;
        objPaymentPlanType.MaximumNumberOfInstalments__c = 4;
        listPPT.add(objPaymentPlanType);
        
        PaymentPlanType__c  objPaymentPlanType2 = GlUt_FactoryData_Test.createPaymentPlanType(PLAN_NAME2,PAY_FREQ2,NUM_OF_INSTAL2);
        objPaymentPlanType2.PlanType__c = Label.CuAp_PaymentPlanTypePlanTypeBudgetPlan;
        //objPaymentPlanType2.FinalPaymentPlan__c = true;
        objPaymentPlanType2.DaysNotice__c = 10;
        objPaymentPlanType2.Active__c = true;
        objPaymentPlanType2.PaymentFrequency__c = MONTHLY;
        objPaymentPlanType2.CreditHandling__c = 'Add to Calculation';
        objPaymentPlanType2.EarliestStartDate__c = '06/06';
        objPaymentPlanType2.MaximumNumberOfInstalments__c = 2;
        objPaymentPlanType2.NumberofRollingInstalments__c = 3;
        listPPT.add(objPaymentPlanType2);
        
        PaymentPlanType__c  objPaymentPlanType3 = GlUt_FactoryData_Test.createPaymentPlanType(PLAN_NAME3,PAY_FREQ3,NUM_OF_INSTAL3);
        objPaymentPlanType3.PlanType__c = Label.CuAp_PaymentPlanTypePlanTypeInstalmentPlan;
        objPaymentPlanType3.FinalPaymentPlan__c = true;
        objPaymentPlanType3.DaysNotice__c = 10;
        objPaymentPlanType3.Active__c = true;
        objPaymentPlanType3.PaymentFrequency__c = MONTHLY;
        objPaymentPlanType3.MaximumNumberOfInstalments__c = 4;
		listPPT.add(objPaymentPlanType3);        
        
        PaymentPlanType__c  objPaymentPlanType4 = GlUt_FactoryData_Test.createPaymentPlanType(PLAN_NAME4,PAY_FREQ4,NUM_OF_INSTAL4);
        objPaymentPlanType4.PlanType__c = Label.CuAp_PaymentPlanTypePlanTypeInstalmentPlan;
        objPaymentPlanType4.FinalPaymentPlan__c = true;
        objPaymentPlanType4.DaysNotice__c = 10;
        objPaymentPlanType4.Active__c = true;
        objPaymentPlanType4.PaymentFrequency__c = 'Weekly';
        objPaymentPlanType4.MaximumNumberOfInstalments__c = 4;
        //objPaymentPlanType4.Unmeasured__c = true;
        listPPT.add(objPaymentPlanType4);        
        Database.insert(listPPT);
        
        List<PaymentMethod__c> listPayMethod = new List<PaymentMethod__c>();        
        PaymentMethod__c  objPaymentMethod = GlUt_FactoryData_Test.createPaymentMethod(objPaymentMethodType,objPaymentPlanType);
        listPayMethod.add(objPaymentMethod);
        
        PaymentMethod__c  objPaymentMethod2 = GlUt_FactoryData_Test.createPaymentMethod(objPaymentMethodType2,objPaymentPlanType2);
        listPayMethod.add(objPaymentMethod2);        
        
        PaymentMethod__c  objPaymentMethod3 = GlUt_FactoryData_Test.createPaymentMethod(objPaymentMethodType3,objPaymentPlanType3);
        listPayMethod.add(objPaymentMethod3);
        Database.insert(listPayMethod);
        
        AvailablePaymentDay__c  objAvailPaymentDay = GlUt_FactoryData_Test.createAvailPaymentDay(AVAIL_PAY_DAY_NAME,DAY_OF_MONTH,DAY_OF_WEEK,objPaymentMethodType);
        Database.insert(objAvailPaymentDay);
        
        List<Account> listAccount = new List<Account>();
        
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        listAccount.add(objAccount);
        Account objAccount2 = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME2);
        listAccount.add(objAccount2);
        Account objAccount3 = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME3);
        listAccount.add(objAccount3);
        Database.insert(listAccount);
        
        List<Balance__c> listBalance = new List<Balance__c>();        
        
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);
        listBalance.add(objBalance);
        Balance__c objBalance1 = GlUt_FactoryData_Test.createBalance(objAccount1);
        listBalance.add(objBalance1);
        Database.insert(listBalance);
        
        List<BalanceTransaction__c> listBalanceTrans = new List<BalanceTransaction__c>();        
        
        BalanceTransaction__c objBalanceTransaction = GlUt_FactoryData_Test.createBalanceTransaction(objBalance);
        //objBalanceTransaction.BillItemAmount__c = AMOUNT; // AT-3275
        objBalanceTransaction.BillAmount__c = AMOUNT; // AT-3275
        objBalanceTransaction.RecordTypeId = Schema.SObjectType.BalanceTransaction__c.getRecordTypeInfosByName().get('Bill').getRecordTypeId(); // AT-3275
        listBalanceTrans.add(objBalanceTransaction);        
        
        BalanceTransaction__c objBalanceTransaction1 = GlUt_FactoryData_Test.createBalanceTransaction(objBalance1);
        //objBalanceTransaction1.BillItemAmount__c = 0.0; // AT-3275
        objBalanceTransaction1.BillAmount__c = 0.0; // AT-3275
        objBalanceTransaction1.RecordTypeId = Schema.SObjectType.BalanceTransaction__c.getRecordTypeInfosByName().get('Bill').getRecordTypeId(); // AT-3275
        listBalanceTrans.add(objBalanceTransaction1);
        Database.insert(listBalanceTrans);
        
        List<BillingContract__c> listBillingContract = new List<BillingContract__c>();
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTACT_NAME,objAccount);
        objContract.DayOfMonth__c = DAY_OF_MONTH;
        objContract.DayOfWeek__c = DAY_OF_WEEK;
        objContract.CurrentPaymentPlanType__c = objPaymentPlanType.Id;
        objContract.Balance__c = objBalance.Id;
        objContract.PaymentMethodType__c = objPaymentMethodType.id;
        listBillingContract.add(objContract);
        
        BillingContract__c objContract1 = GlUt_FactoryData_Test.createContract(CONTACT_NAME,objAccount1);
        objContract1.DayOfMonth__c = DAY_OF_MONTH;
        objContract1.DayOfWeek__c = DAY_OF_WEEK; 
        objContract1.CurrentPaymentPlanType__c = objPaymentPlanType2.Id;
        objContract1.Balance__c = objBalance1.Id; 
        listBillingContract.add(objContract1);
        
        BillingContract__c objContract2 = GlUt_FactoryData_Test.createContract(CONTACT_NAME,objAccount2);
        objContract2.DayOfMonth__c = DAY_OF_MONTH;
        objContract2.DayOfWeek__c = DAY_OF_WEEK; 
        objContract2.CurrentPaymentPlanType__c = objPaymentPlanType3.Id;
        objContract2.Balance__c = objBalance1.Id; 
        listBillingContract.add(objContract2);
        
        BillingContract__c objContract3 = GlUt_FactoryData_Test.createContract(CONTACT_NAME,objAccount3);
        objContract3.DayOfMonth__c = DAY_OF_MONTH;
        objContract3.DayOfWeek__c = DAY_OF_WEEK; 
        objContract3.CurrentPaymentPlanType__c = objPaymentPlanType4.Id;
        objContract3.Balance__c = objBalance1.Id; 
        listBillingContract.add(objContract3);
        Database.insert(listBillingContract);
    }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        13 Feb 2018
    @description: Test method for serverPaymentMethod() method
    *******************************************************************************/
    
    static testmethod void checkPaymentMethodValues(){               
        
        List<User> objUser = [SELECT Id, 
                              		 Name, 
                              		 FirstName, 
                              		 LastName 
                              FROM User 
                              WHERE isActive = TRUE 
                              AND LastName = :USER_LNAME];
        
        System.runAs(objUser[0]){
            Test.starttest();
            List<CuAp_SetupPaymentPlanCtrlr.WrapPaymentMethodType> lstWrapPaymentMethod = CuAp_SetupPaymentPlanCtrlr.serverPaymentMethod();                         
            Test.stoptest();
            
            if(lstWrapPaymentMethod.size() > 0){
                System.assertEquals(lstWrapPaymentMethod[0].objPaymentMethodType.Name,PAYMENT_METHOD_TYPE1);
            }  
        }
    }    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        13 Feb 2018
    @description: Test method for serverPaymentPlanType() method
    *******************************************************************************/
    
    static testmethod void checkPaymentPlanTypeValues(){               
        
        List<User> objUser = [SELECT Id, 
                              		 Name, 
                              		 FirstName, 
                              		 LastName 
                              FROM User 
                              WHERE isActive = TRUE 
                              AND LastName = :USER_LNAME];
        
        System.runAs(objUser[0]){
           
            Test.starttest();
            List<CuAp_SetupPaymentPlanCtrlr.WrapPaymentPlanType> lstWrapPaymentPlanType = CuAp_SetupPaymentPlanCtrlr.serverPaymentPlanType();                         
            Test.stoptest();
            
            if(lstWrapPaymentPlanType.size() > 0){
                System.assertEquals(lstWrapPaymentPlanType[0].objPaymentPlanType.Name,PLAN_NAME);
            }            
        }
    }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        13 Feb 2018
    @description: Test method for getContractDetails() method
    @revision:    08-Mar-2018 MT - Use the field from constant class
    *******************************************************************************/
    
    static testmethod void checkContractDetails(){               
        
        List<User> objUser = [SELECT Id, 
                              		 Name, 
                              		 FirstName, 
                              		 LastName 
                              FROM User 
                              WHERE isActive = TRUE 
                              AND LastName = :USER_LNAME];
        
        Map<String,String> mapContractDetails = new Map<String,String>();
        
        Account objAccount = [Select Id,
                                     Name 
                              FROM Account
                              WHERE Name =: ACCOUNT_NAME LIMIT 1];
        
        BillingContract__c objContract = [Select Id,
                                   		  Name 
                                   FROM BillingContract__c 
                                   WHERE AccountName__c =: objAccount.id LIMIT 1];  
        
        System.runAs(objUser[0]){
            Test.starttest();
            mapContractDetails = CuAp_SetupPaymentPlanCtrlr.getContractDetails(objContract.Id);                         
            Test.stoptest();
            
            if(mapContractDetails.keySet().size() > 0){
                system.debug('mapContractDetails---'+ mapContractDetails);
                System.assertEquals(mapContractDetails.get(GlUt_APIConstantsContracts.DAYOFMONTHAPINAME),DAY_OF_MONTH);
            }
                        
        }
    }
    
    /*****************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        13 Feb 2018
    @description: Test method for getBalanceAmount() method
    *******************************************************************************/
    
    static testmethod void getBalanceAmountValues_Positive(){               
        
        List<User> objUser = [SELECT Id, 
                              		 Name, 
                              		 FirstName, 
                              		 LastName 
                              FROM User 
                              WHERE isActive = TRUE 
                              AND LastName = :USER_LNAME];
        
        String strBalanceAmount = '';
        
        Account objAccount = [Select Id,
                                     Name 
                              FROM Account
                              WHERE Name =: ACCOUNT_NAME LIMIT 1];
        
        BillingContract__c objContract = [Select Id,
                                   		  Name,
                                          AccountName__c,
                                          Balance__r.Balance__c
                                   FROM BillingContract__c 
                                   WHERE AccountName__c =: objAccount.id LIMIT 1]; 
        
        System.runAs(objUser[0]){
            Test.starttest();
            strBalanceAmount = CuAp_SetupPaymentPlanCtrlr.getBalanceAmount(objContract.Id,contractListFields,balanceFieldList,null);    
            
            Test.stoptest();
            
            System.assertEquals(Double.valueOf(strBalanceAmount),AMOUNT);
            
            system.debug('strBalanceAmount---'+ strBalanceAmount);
                        
        }
    }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        13 Feb 2018
    @description: Test method for getBalanceAmount() method
    *******************************************************************************/
    
    static testmethod void getBalanceAmountValues_Negative(){               
        
        List<User> objUser = [SELECT Id, 
                              		 Name, 
                              		 FirstName, 
                              		 LastName 
                              FROM User 
                              WHERE isActive = TRUE 
                              AND LastName = :USER_LNAME];
        
        String strBalanceAmount = '';
        
        System.runAs(objUser[0]){
            Test.starttest();
            strBalanceAmount = CuAp_SetupPaymentPlanCtrlr.getBalanceAmount(null,contractListFields,balanceFieldList,null);    
            
            Test.stoptest();
            
            System.assertEquals(Double.valueOf(strBalanceAmount),0);
            
            system.debug('strBalanceAmount---'+ strBalanceAmount);
                        
        }
    }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        13 Feb 2018
    @description: Test method for calculatePaymentPlan() method
    *******************************************************************************/
    
    static testmethod void calculatePaymentPlanValues(){               
        
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
                                          AccountName__c,
                                   		  CurrentPaymentPlanType__c
                                   FROM BillingContract__c 
                                   WHERE AccountName__c =: objAccount.id  LIMIT 1];
        
        PaymentPlanType__c objPaymentPlanType = [SELECT Id,
                                                		Name
                                                 FROM PaymentPlanType__c
                                                 WHERE Active__c = true LIMIT 1];
        
        System.runAs(objUser[0]){
            Test.starttest();
            PpUt_PaymentPlanPackage objPaymentPlanPackage = CuAp_SetupPaymentPlanCtrlr.calculatePaymentPlan(objContract,NUM_OF_INSTAL,null,null,null);    
            Test.stoptest();
            
            System.assertEquals(objPaymentPlanPackage.contract.CurrentPaymentPlanType__c , objPaymentPlanType.Id);
                        
        }
    }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        13 Feb 2018
    @description: Test method for PpUt_PaymentPlanPackage Monthly Plans
    *******************************************************************************/
    
    static testmethod void calculatePaymentPlanValues_Monthly(){               
        
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
                              WHERE Name =: ACCOUNT_NAME2 LIMIT 1];
        
        BillingContract__c objContract = [Select Id,
                                   		  Name,
                                          AccountName__c,
                                   		  DayOfMonth__c,
                                   		  DayOfWeek__c,
                                   		  CurrentPaymentPlanType__c
                                   FROM BillingContract__c 
                                   WHERE AccountName__c =: objAccount.id  LIMIT 1];
        
        Account objAccount2 = [Select Id,
                                     Name 
                              FROM Account
                              WHERE Name =: ACCOUNT_NAME3 LIMIT 1];
        
        BillingContract__c objContract2 = [Select Id,
                                   		  Name,
                                          AccountName__c,
                                   		  DayOfMonth__c,
                                   		  DayOfWeek__c,
                                   		  CurrentPaymentPlanType__c
                                   FROM BillingContract__c 
                                   WHERE AccountName__c =: objAccount2.id  LIMIT 1];
        
        PaymentPlanType__c objPaymentPlanType = [SELECT Id,
                                                		Name
                                                 FROM PaymentPlanType__c
                                                 WHERE Active__c = true LIMIT 1];
        
        System.runAs(objUser[0]){
            Test.starttest();
            PpUt_PaymentPlanPackage objPaymentPlanPackage = CuAp_SetupPaymentPlanCtrlr.calculatePaymentPlan(objContract,NUM_OF_INSTAL,null,null,null);    
            PpUt_PaymentPlanPackage objPaymentPlanPackage2 = CuAp_SetupPaymentPlanCtrlr.calculatePaymentPlan(objContract2,NUM_OF_INSTAL,null,null,null);    
            Test.stoptest();
            
            //System.assertEquals(objPaymentPlanPackage.contract.CurrentPaymentPlanType__c , objPaymentPlanType.Id);
            system.assert(objPaymentPlanPackage != null);
                        
        }
    }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        13 Feb 2018
    @description: Test method for calculatePaymentPlan() method
    *******************************************************************************/
    /*
    static testmethod void calculatePaymentPlanValues_Negative(){               
        
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
                              WHERE Name =: ACCOUNT_NAME1 LIMIT 1];
        
        Contract__c objContract = [Select Id,
                                   		  Name,
                                   		  DayOfMonth__c,
                                   		  DayOfWeek__c,
                                   		  CurrentPaymentPlanType__c
                                   FROM Contract__c 
                                   WHERE AccountName__c =: objAccount.id  LIMIT 1];
        
        System.runAs(objUser[0]){
            Test.starttest();
            PpUt_PaymentPlanPackage objPaymentPlanPackage = CuAp_SetupPaymentPlanCtrlr.calculatePaymentPlan(objContract,NUM_OF_INSTAL);    
            Test.stoptest();
            
                        
        }
    }*/
    
    /******************************************************************************
    @author:      Echo: Neha R
    @date:        10 Mar 2018
    @description: Test method for retrievePaymentPlanFields Monthly Plans
    *******************************************************************************/
    static testmethod void retrievePaymentPlanFields(){ 
        
        List<User> objUser = [SELECT Id, 
                              		 Name, 
                              		 FirstName, 
                              		 LastName 
                              FROM User 
                              WHERE isActive = TRUE 
                              AND LastName = :USER_LNAME];        
        
        System.runAs(objUser[0]){
            Test.starttest();
            List<List<GlAp_FieldProps>> listOflistFieldProps = CuAp_SetupPaymentPlanCtrlr.retrievePaymentPlanFields(); 
            Test.stoptest();
            
            system.assert(listOflistFieldProps.size() > 0);
        }
    }         
}