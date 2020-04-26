/******************************************************************************
@author:      Echo: Neha 
@date:        29-01-2018  
@description: Test Class for GlUt_SupplyPointHandler
@Revisions	  	AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/

@isTest  
public class GlUt_SupplyPointHandler_Test {   
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String ACCOUNT_NAME = 'TEST_ACCOUNT';
    private static final String LOCATION_NAME = 'A99 9AA';    
    private static final String MEASURED ='Yes';
    private static final String READFREQUENCY_M = 'Monthly'; 
    private static final String READFREQUENCY_HY = 'Half Yearly';
    private static final String CONTYPE_NAME ='Test Consideration Type';
    private static final String DISCONNECTED_STATUS = 'Shared Supply';
    private static final String SUPPLYDISCONNECTIONSTATUS = 'Able to Disconnect';
    private static final String NULL_VALUE = null ;
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String READFREQUENCY_Q = 'Quarterly';
    private static final String READTIMETABLE_NAME = 'RTT1';
    private static final String READTIMETABLE_NAME1 = 'RTT2';
    private static final String DEPOT_NAME = 'depot1';
    private static final String DEPOT_NAME1 = 'depot2';
    private static final String PAYMENT_METHOD_TYPE1 = 'Payment Card';    
    private static final String PLAN_NAME = 'MEASURED MONTHLY';
    private static final String PAY_FREQ = 'Monthly';
    private static final Integer FORECAST_AMOUNT = 200;
    private static final Integer PAYPLAN_AMOUNT = 500;    
    private static final String TESTSERVICE_TYPE1 ='water service';
    private static final Integer NUM_OF_INSTAL = 12;
    private static final Integer NUM_OF_ROLLING_INSTAL = 2;
    private static final String CONTACT_NAME = 'Test Contact';
    private static final String MONTHLY = Label.CuAp_PaymentPlanTypePaymentFrequencyMonthly;
    private static final String DAY_OF_MONTH = '2';
    private static final String DAY_OF_WEEK = 'Monday';
    private static final String FOUR_WEEKLY = 'Four weekly';
    private static final String ANNUAL = 'Annual';
    private static final String DEVICE_SERIALNO     = '1234';
    private static final String AVAILABLESERVICES = 'avail service';    
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';    
    private static final String WHOLESALER = 'wholesaler'; 
    private static final String AREA_NAME = 'North';            //AT-4473
    private static final String SP_RURALOUTLETTYPE = 'Box';     //AT-4473
    private static final String VALID_OUTLET_TYPE = 'Bookable Meter;Bookable Metered Pump;Box;Offtake Meter';
    private static final Boolean isException;  
    /******************************************************************************
    @author:      Echo: Neha
    @date:        29-01-2018  
    @description: Test data setup method
    *******************************************************************************/
    @TestSetup
    static void createTestData()
    {
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        // Create Depot Record
        Depot__c objDepot = GlUt_FactoryData_Test.createDepot(DEPOT_NAME);        
        Database.insert(objDepot);
        
        // create Area Record AT-4473
        Area__c objArea = GlUt_FactoryData_Test.createArea(AREA_NAME);        
        Database.insert(objArea);
       
        // Create ReadTimetable Record
        ReadTimetable__c objReadTimetable1 = GlUt_FactoryData_Test.createReadTimetable(READTIMETABLE_NAME, READFREQUENCY_M);        
        Database.insert(objReadTimetable1);
        
        // Create Book Record
        Book__c objBook1 = GlUt_FactoryData_Test.createBook(objDepot,objReadTimetable1) ; 
        objBook1.ReadFrequency__c = FOUR_WEEKLY;
        objBook1.BudgetResetMonth__c = 'April;September;November';
        Database.insert(objBook1);        
        
        // Create ReadTimetable Record
        ReadTimetable__c objReadTimetable2 = GlUt_FactoryData_Test.createReadTimetable(READTIMETABLE_NAME1, READFREQUENCY_M);        
        Database.insert(objReadTimetable2);
        
        // Create Book Record
        Book__c objBook2 = GlUt_FactoryData_Test.createBook(objDepot,objReadTimetable2) ; 
        objBook2.ReadFrequency__c = ANNUAL;
        objBook2.BudgetResetMonth__c = 'April;September;November';
        Database.insert(objBook2);
        
        // Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);        
        Database.insert(objAccount);
        
        //Create Balance Record
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);
        Database.insert(objBalance);
        
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
        Database.insert(objPaymentPlanType); 
        
         //Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTACT_NAME,objAccount);
        objContract.DayOfMonth__c = DAY_OF_MONTH;
        objContract.DayOfWeek__c = DAY_OF_WEEK;
        objContract.CurrentPaymentPlanType__c = objPaymentPlanType.Id;
        objContract.Balance__c = objBalance.Id;
        objContract.PaymentMethodType__c = objPaymentMethodType.id;
        Database.insert(objContract); 
                
        // Create PaymentPlan Record
        PaymentPlan__c objPaymentPlan = GlUt_FactoryData_Test.createPaymentPlan(objPaymentPlanType,objContract, FORECAST_AMOUNT);  
        objPaymentPlan.PaymentPlanTotal__c = PAYPLAN_AMOUNT;
        objPaymentPlan.StartDate__c =date.valueOf('2018-07-01');
        Database.insert(objPaymentPlan);
               
        // Create Instalment
        Instalment__c objInstalment = GlUt_FactoryData_Test.createInstalment(objPaymentPlan); 
        objInstalment.Type__c= 'Normal' ;
        objInstalment.InstalmentNumber__c=1; 
        objInstalment.InstalmentAmountDue__c=2343.79;
        objInstalment.InstalmentDueDate__c= date.valueOf('2018-07-01');
        Database.insert(objInstalment);        

        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        Database.insert(objLocation);
        
        // Create Location Occupant Record
        LocationOccupant__c objLocationOccupant = GlUt_FactoryData_Test.createLocationOccupant(objAccount, objLocation);        
        Database.insert(objLocationOccupant); 
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Create Rural Channel Record AT-4473
        RuralChannel__c objRuralChannel = GlUt_FactoryData_Test.createRuralChannel(objArea, objDepot);
        objRuralChannel.ValidOutletTypes__c = VALID_OUTLET_TYPE;
        Database.insert(objRuralChannel);
        
        // Create SupplyPoint Record        
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; // AT-3174
        objSupplyPoint.Book__c = objBook1.Id;
        objSupplyPoint.WalkOrder__c = 5;
        objSupplyPoint.Disputed__c = TRUE;
        objSupplyPoint.Depot__c = objDepot.Id;
        objSupplyPoint.RuralChannel__c = objRuralChannel.Id;
        objSupplyPoint.RuralOutletType__c = SP_RURALOUTLETTYPE; 
        Database.insert(objSupplyPoint);
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record
        Device__c  objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICE_SERIALNO , objDeviceType);        
        objDevice.SerialNo__c = DEVICE_SERIALNO;
        Database.insert(objDevice);

        // Create Division Record
        Division__c  objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        // Create Wholesaler Record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
                
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading);
        
        //Create Service Type Record 
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TESTSERVICE_TYPE1);
        Database.insert(objServiceType);  
        
        // Create Available Service Record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        // Create Service Record 
        Service__c  objOldService1 = GlUt_FactoryData_Test.createService(objContract, objReading , objServiceType, objSupplyPoint, objAvailableService);
        objOldService1.SupplyPoint__c = objSupplyPoint.Id;      
        Database.insert(objOldService1); 
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        29-01-2018  
    @description: method for insert  a new record
    *******************************************************************************/
    static testmethod void InsertSupplyPoint()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Location__c objLocation = [SELECT Id FROM Location__c LIMIT 1];
        
        List<SupplyPoint__c> spList = new List<SupplyPoint__c>();
        
        SupplyPointUsageType__c objSupplyPointUsageType = [SELECT Id FROM SupplyPointUsageType__c LIMIT 1];
        Book__c objBook = [SELECT Id FROM Book__c WHERE ReadFrequency__c = 'Four weekly' LIMIT 1 ];
                
        // Create SupplyPoint Record 
        SupplyPoint__c objSupplyPoint1 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint1.SupplyDisconnectionStatus__c = SUPPLYDISCONNECTIONSTATUS; // 'Able to Disconnect'
        objSupplyPoint1.Book__c = objBook.Id;                 
        spList.add(objSupplyPoint1);
        
        // Create SupplyPoint Record
        SupplyPoint__c objSupplyPoint2 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint2.SupplyDisconnectionStatus__c = SUPPLYDISCONNECTIONSTATUS; // 'Able to Disconnect'              
        objSupplyPoint2.WalkOrder__c = 900;  
        spList.add(objSupplyPoint2);
        
        // Create SupplyPoint Record
        SupplyPoint__c objSupplyPoint3 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint3.SupplyDisconnectionStatus__c = SUPPLYDISCONNECTIONSTATUS; // 'Able to Disconnect'
        objSupplyPoint3.Book__c = objBook.Id;        
        objSupplyPoint3.WalkOrder__c = 15;  
        spList.add(objSupplyPoint3); 
        
        System.runAs(objUser){
            Test.startTest();             
            Database.insert(spList);           
            Test.stopTest();            
            List<SupplyPoint__c> insertList = [SELECT Id,WalkOrder__c FROM SupplyPoint__c WHERE SupplyDisconnectionStatus__c =: SUPPLYDISCONNECTIONSTATUS AND Book__c != null];
            system.assert(insertList.size() > 0 );
            for(SupplyPoint__c objSP: insertList){
                system.assert(objSP.WalkOrder__c != null);
            }
        }
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        29-05-2018  
    @description: method for insert  a new record
    *******************************************************************************/
    static testmethod void InsertSP_WalkOrdExist()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Location__c objLocation = [SELECT Id FROM Location__c LIMIT 1];
        
        List<SupplyPoint__c> spList = new List<SupplyPoint__c>();
        Boolean exceptionStr = false;
        SupplyPointUsageType__c objSupplyPointUsageType = [SELECT Id FROM SupplyPointUsageType__c LIMIT 1];
        Book__c objBook = [SELECT Id FROM Book__c WHERE ReadFrequency__c = 'Four weekly' LIMIT 1 ];
                
        // Create SupplyPoint Record 
        SupplyPoint__c objSupplyPoint1 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint1.SupplyDisconnectionStatus__c = SUPPLYDISCONNECTIONSTATUS; // 'Able to Disconnect'
        objSupplyPoint1.Book__c = objBook.Id;  
        objSupplyPoint1.WalkOrder__c = 5;
        spList.add(objSupplyPoint1); 
        
        System.runAs(objUser){
            try{
                Test.startTest();             
                Database.insert(spList);           
                Test.stopTest(); 
            }catch(DMLException  e){
                exceptionStr = true;
            }
            
            system.assert( exceptionStr == true);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        29-05-2018  
    @description: method for insert
    *******************************************************************************/
    static testmethod void InsertSP_DepotDiff()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Location__c objLocation = [SELECT Id FROM Location__c LIMIT 1];
        
        List<SupplyPoint__c> spList = new List<SupplyPoint__c>();
        Boolean exceptionStr = false;
        SupplyPointUsageType__c objSupplyPointUsageType = [SELECT Id FROM SupplyPointUsageType__c LIMIT 1];
        Book__c objBook = [SELECT Id FROM Book__c WHERE ReadFrequency__c = 'Four weekly' LIMIT 1 ];
        
        // Create Depot Record
        Depot__c objDepot = GlUt_FactoryData_Test.createDepot(DEPOT_NAME1);        
        Database.insert(objDepot);   
        
        // Create SupplyPoint Record 
        SupplyPoint__c objSupplyPoint1 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint1.SupplyDisconnectionStatus__c = SUPPLYDISCONNECTIONSTATUS; // 'Able to Disconnect'
        objSupplyPoint1.Depot__c = objDepot.Id;  
        objSupplyPoint1.Book__c = objBook.Id;
        objSupplyPoint1.WalkOrder__c = 15;
        spList.add(objSupplyPoint1); 
        
        System.runAs(objUser){
            try{
                Test.startTest();             
                Database.insert(spList);           
                Test.stopTest(); 
            }catch(DMLException  e){
                exceptionStr = true;
            }            
            system.assert( exceptionStr == true);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        08/06/2018  
    @description: Method for update exiting record
    *******************************************************************************/
    static testmethod void UpdateSupplyPoint_book()
    {            
        User objUser = [SELECT id,name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];      
        List<SupplyPoint__c> UpdateSPList = new List<SupplyPoint__c>();
        
        List<SupplyPoint__c> objSupplyPointList = [SELECT Id,Book__c FROM SupplyPoint__c ];
        List<Book__c> bookList = [SELECT Id,ReadFrequency__c,ReadTimetable__c,BudgetResetMonth__c FROM Book__c ];
        Location__c objLocation = [SELECT Id FROM Location__c LIMIT 1];
        SupplyPointUsageType__c objSupplyPointUsageType = [SELECT Id FROM SupplyPointUsageType__c LIMIT 1];
        
        // Create SupplyPoint Record        
        SupplyPoint__c objSupplyPoint1 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint1.Book__c = bookList[0].Id;
        objSupplyPoint1.WalkOrder__c = 15;        
        Database.insert(objSupplyPoint1);
                
        SupplyPoint__c objSupplyPoint2 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint2.Book__c = bookList[0].Id;               
        Database.insert(objSupplyPoint2);
        
        // remove Book of first supply point
        objSupplyPoint1.Book__c = null ;
        UpdateSPList.add(objSupplyPoint1);
              
        // update book of 2nd Supply point and walkorder blank
        objSupplyPoint2.Book__c = bookList[1].Id;
        objSupplyPoint2.WalkOrder__c = NULL;
        UpdateSPList.add(objSupplyPoint2);        
        
        // update for payment plan
        for(SupplyPoint__c objSupplyPoint: objSupplyPointList)
        {          
            for(Book__c objBook: bookList){               
                if(objSupplyPoint.Book__c != objBook.Id){                  
                    objSupplyPoint.Book__c = objBook.Id;
                    break;
                }
            }
            UpdateSPList.add(objSupplyPoint);
        }
              
        System.runAs(objUser){
            Test.startTest(); 
            Database.update(UpdateSPList);   
            Test.stopTest();
        }   
        
        // read frequency updated
        SupplyPoint__c objSP = [SELECT Read_Frequency__c FROM SupplyPoint__c WHERE Id =: objSupplyPoint2.Id LIMIT 1];       
        system.assert( objSP.Read_Frequency__c <> READFREQUENCY_M);
        
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        08/06/2018  
    @description: Method for update exiting record
    *******************************************************************************/
    static testmethod void UpdateSP_WalkOrdExist()
    {            
        User objUser = [SELECT id,name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];      
        List<SupplyPoint__c> UpdateSPList = new List<SupplyPoint__c>();
        Boolean exceptionStr = false;
        
        Book__c book1 = [SELECT Id,ReadFrequency__c,ReadTimetable__c,BudgetResetMonth__c FROM Book__c WHERE ReadFrequency__c =: ANNUAL LIMIT 1];
        Book__c book2 = [SELECT Id,ReadFrequency__c,ReadTimetable__c,BudgetResetMonth__c FROM Book__c WHERE ReadFrequency__c =: FOUR_WEEKLY LIMIT 1];
        Location__c objLocation = [SELECT Id FROM Location__c LIMIT 1];
        SupplyPointUsageType__c objSupplyPointUsageType = [SELECT Id FROM SupplyPointUsageType__c LIMIT 1];
        
        // Create SupplyPoint Record        
        SupplyPoint__c objSupplyPoint1 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint1.Book__c = book1.Id;
        objSupplyPoint1.WalkOrder__c = 15;        
        Database.insert(objSupplyPoint1);
        
        // walk order same as existing one
        objSupplyPoint1.Book__c = book2.Id ;
        objSupplyPoint1.WalkOrder__c = 5;
        UpdateSPList.add(objSupplyPoint1);
              
        System.runAs(objUser){
            try{
                Test.startTest(); 
                Database.update(UpdateSPList);   
                Test.stopTest();
            }catch(DMLException  e){
                exceptionStr = true;
            }            
            system.assert( exceptionStr == true);
        }   
             
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        08/06/2018  
    @description: Method for update exiting record
    *******************************************************************************/
    static testmethod void UpdateSP_DepotDiff()
    {            
        User objUser = [SELECT id,name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];      
        List<SupplyPoint__c> UpdateSPList = new List<SupplyPoint__c>();
        Boolean exceptionStr;
        List<SupplyPoint__c> objSupplyPointList = [SELECT Id,Book__c FROM SupplyPoint__c ];
        
        // Create Depot Record
        Depot__c objDepot = GlUt_FactoryData_Test.createDepot(DEPOT_NAME1);        
        Database.insert(objDepot); 
        
        Book__c bookAnnual = [SELECT Id,ReadFrequency__c,ReadTimetable__c,BudgetResetMonth__c,Depot__c FROM Book__c WHERE ReadFrequency__c =: ANNUAL LIMIT 1]; 
        bookAnnual.Depot__c = objDepot.Id;
        Database.update(bookAnnual); 

        // update for payment plan
        for(SupplyPoint__c objSupplyPoint: objSupplyPointList)
        {          
            objSupplyPoint.Book__c = bookAnnual.Id;             
            UpdateSPList.add(objSupplyPoint);
        }
        
        System.runAs(objUser){
            try{
                Test.startTest(); 
                Database.update(UpdateSPList);   
                Test.stopTest();
            }catch(DMLException  e){
                exceptionStr = true;
            }            
            system.assert( exceptionStr == true);
        }      
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        08/06/2018  
    @description: Method for update exiting record
    *******************************************************************************/
    static testmethod void UpdateSP_deleteInstalment()
    {            
        User objUser = [SELECT id,name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];      
        
        List<SupplyPoint__c> objSupplyPointList = [SELECT Id,Book__c FROM SupplyPoint__c ];
        Book__c bookAnnual = [SELECT Id,ReadFrequency__c,ReadTimetable__c,BudgetResetMonth__c,Depot__c FROM Book__c WHERE ReadFrequency__c =: ANNUAL LIMIT 1]; 
        bookAnnual.BudgetResetMonth__c = 'January;September;November';
        Database.update(bookAnnual);
                       
        List<Date> dateList = new List<Date>();        
        dateList.add(Date.valueOf('2018-08-01'));
        dateList.add(Date.valueOf('2018-09-01'));
        dateList.add(Date.valueOf('2018-10-01'));
        dateList.add(Date.valueOf('2018-11-01'));
        dateList.add(Date.valueOf('2018-12-01'));
        dateList.add(Date.valueOf('2019-01-01'));
        dateList.add(Date.valueOf('2019-02-01'));
        dateList.add(Date.valueOf('2019-03-01'));
        dateList.add(Date.valueOf('2019-04-01'));
        dateList.add(Date.valueOf('2019-05-01'));
        dateList.add(Date.valueOf('2019-06-01'));
        dateList.add(Date.valueOf('2019-07-01'));
        
        PaymentPlan__c objPaymentPlan = [SELECT Id FROM PaymentPlan__c LIMIT 1]; 
        List<Instalment__c> instalmentList = new  List<Instalment__c>();
        for(Integer instalmentCount = 2;instalmentCount< 13; instalmentCount++ ){
            // Create Instalment
            Instalment__c objInstalment = GlUt_FactoryData_Test.createInstalment(objPaymentPlan); 
            objInstalment.Type__c= 'Normal' ;
            objInstalment.InstalmentNumber__c = instalmentCount; 
            objInstalment.InstalmentAmountDue__c=2343.79;
            objInstalment.InstalmentDueDate__c= dateList[instalmentCount - 2];
            instalmentList.add(objInstalment);
        }        
        Database.insert(instalmentList);  
                
        List<SupplyPoint__c> UpdateSPList = new List<SupplyPoint__c>();               
        
        for(SupplyPoint__c objSupplyPoint: objSupplyPointList)
        {     
            objSupplyPoint.Book__c = bookAnnual.Id;            
            UpdateSPList.add(objSupplyPoint);
        }
      
        System.runAs(objUser){
            Test.startTest(); 
            Database.update(UpdateSPList);   
            Test.stopTest();
            System.assertEquals(bookAnnual.Id, objSupplyPointList[0].Book__c);
        }   
                     
    }  
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        17-04-2018  
    @description: Method for update exiting record- Negative
    *******************************************************************************/
    static testmethod void UpdateSupplyPoint_negative()
    {            
        User objUser = [select id,name from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1];
      
        Id UpdatedID;
        List<SupplyPoint__c> objSupplyPointList = [select Id from SupplyPoint__c where SupplyDisconnectionStatus__c =: SUPPLYDISCONNECTIONSTATUS limit 1];
                
        List<SupplyPoint__c> UpdateSPList = new List<SupplyPoint__c>();
       
        for(SupplyPoint__c objSupplyPoint: objSupplyPointList)
        {
            UpdatedID = objSupplyPoint.id;
            objSupplyPoint.SupplyDisconnectionStatus__c = DISCONNECTED_STATUS;
            UpdateSPList.add(objSupplyPoint);             
        }  
        
        Database.update(UpdateSPList); 
        
        System.runAs(objUser){
            Test.startTest(); 
            Database.update(UpdateSPList);   
            Test.stopTest();
        }
        
        List<SupplyPoint__c> UpdatedList = [select AllowDisconnection__c from SupplyPoint__c where id = :UpdatedID ];
        for(SupplyPoint__c objSupplyPoint : UpdatedList )
        {
            system.assert(objSupplyPoint.AllowDisconnection__c == false );
        }
                
    }
                


    /******************************************************************************
    @author:      Echo: Neha
    @date:        17-04-2018  
    @description: Method for update exiting record- Negative
    *******************************************************************************/
    static testmethod void allocateOutStandingBillItemToPaymentAllocQueue_positive()
    {            
        User objUser = [select id,name from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1];
      
        Id UpdatedID;
        List<SupplyPoint__c> objSupplyPointList = [select Id, Disputed__c  from SupplyPoint__c where SupplyDisconnectionStatus__c =: SUPPLYDISCONNECTIONSTATUS limit 1];
                
        List<SupplyPoint__c> UpdateSPList = new List<SupplyPoint__c>();
       
        for(SupplyPoint__c objSupplyPoint: objSupplyPointList)
        {
            UpdatedID = objSupplyPoint.id;
            objSupplyPoint.Disputed__c = FALSE;
            UpdateSPList.add(objSupplyPoint);             
        } 
        System.runAs(objUser){
            Test.startTest(); 
            Database.update(UpdateSPList);   
            Test.stopTest();
            System.assertEquals(FALSE, objSupplyPointList[0].Disputed__c);
        }      
    }
                
}