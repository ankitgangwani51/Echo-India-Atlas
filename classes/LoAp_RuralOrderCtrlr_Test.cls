/******************************************************************************
@author:      Echo: Neha 
@date:        18-12-2018  
@description: Test Class for LoAp_RuralOrderCtrlr
*******************************************************************************/
@isTest  
public class LoAp_RuralOrderCtrlr_Test {   
    
    private static final String USER_PROFILE      = 'System Administrator';
    private static final String USER_NAME         = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME 		  = 'First_User_Name';
    private static final String USER_LNAME        = 'Last_User_Name'; 
    private static final String ACCOUNT_NAME      = 'TEST_ACCOUNT';
    private static final String LOCATION_NAME     = 'A99 9AA'; 
    private static final String DEPOT_NAME        = 'Leads';
    private static final String AREA_NAME         = 'North';
    private static final String BILLNAME          = 'FEB';
    private static final String SP_USAGE_TYPE     = 'SupplyPointUsageType';
    private static final String ACCESS_TYPE       = 'Channel - Single Shared';
    private static final String CONTACT_NAME      = 'Test Contact';    
    private static final String DAY_OF_MONTH      = '2';
    private static final String DAY_OF_WEEK       = 'Monday';  
    private static final String BILL              = 'Bill';
    private static final Integer VOLUME           = 2;
    private static final Decimal AMOUNT           = 23.2;
    private static final Date ORDER_DATE          = system.today();
  
    /******************************************************************************
    @author:      Echo: Neha
    @date:        18-12-2018  
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
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        Database.insert(objLocation);
        
        // Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);        
        Database.insert(objAccount);
        
        //Create Balance Record
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);       
        Database.insert(objBalance);
        
        //Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTACT_NAME,objAccount);
        objContract.DayOfMonth__c = DAY_OF_MONTH;
        objContract.DayOfWeek__c = DAY_OF_WEEK;  
        objContract.Balance__c = objBalance.Id;
        Database.insert(objContract); 
        
        // Create Area Record
        Area__c objArea = GlUt_FactoryData_Test.createArea(AREA_NAME);        
        Database.insert(objArea);
        
        // Create Depot Record
        Depot__c objDepot = GlUt_FactoryData_Test.createDepot(DEPOT_NAME);        
        Database.insert(objDepot);
        
        // Create RuralChannel Record
        RuralChannel__c objRuralChannel = GlUt_FactoryData_Test.createRuralChannel(objArea, objDepot);        
        Database.insert(objRuralChannel);

        // Create Rural License Record
        RuralLicense__c objRuralLicense = GlUt_FactoryData_Test.createRuralLicense();
		objRuralLicense.BillingContract__c = objContract.Id;         
        Database.insert(objRuralLicense);
        
        // Create RuralEntitlement Record
        RuralEntitlement__c objRuralEntitlement = GlUt_FactoryData_Test.createRuralEntitlement(objRuralLicense);        
        Database.insert(objRuralEntitlement);        
        
        //Create Bill Record
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILLNAME, objContract);       
        Database.insert(objBill);
        
        //Create BalanceTransaction Record
        BalanceTransaction__c objBalanceTransaction = GlUt_FactoryData_Test.createBalanceTransaction(objBalance);  
        objBalanceTransaction.Bill__c = objBill.Id; 
        objBalanceTransaction.BillAmount__c = AMOUNT;
        objBalanceTransaction.RecordTypeId = Schema.SObjectType.BalanceTransaction__c.getRecordTypeInfosByName().get(BILL).getRecordTypeId();
        Database.insert(objBalanceTransaction);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create SupplyPoint Record        
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; 
        objSupplyPoint.AccessType__c = ACCESS_TYPE;
        objSupplyPoint.RuralChannel__c = objRuralChannel.Id;        
        Database.insert(objSupplyPoint);
        
        // Create RuralOrder Record 
        RuralOrder__c  objRuralOrder = GlUt_FactoryData_Test.createRuralOrder(objLocation, objRuralChannel , objRuralEntitlement, VOLUME);        
        objRuralOrder.OrderDate__c = ORDER_DATE;
		Database.insert(objRuralOrder);       
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        18-12-2018  
    @description: method for Location error 
    *******************************************************************************/
    static testmethod void LocationError()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Location__c objLocation = new Location__c();
        RuralChannel__c objRuralChannel = [SELECT Id FROM RuralChannel__c LIMIT 1];
        RuralEntitlement__c objRuralEntitlement = [SELECT Id FROM RuralEntitlement__c LIMIT 1];
        
        // Create RuralOrder Record 
        RuralOrder__c  objRuralOrder = GlUt_FactoryData_Test.createRuralOrder(objLocation, objRuralChannel , objRuralEntitlement, VOLUME);        
      
        System.runAs(objUser){
            Test.startTest();             
            LoAp_RuralOrderCtrlr.ROWrapperClass wrapperObj = new LoAp_RuralOrderCtrlr.ROWrapperClass(); 
            wrapperObj = LoAp_RuralOrderCtrlr.onSave(objRuralOrder);
            Test.stopTest();            
            system.assert(wrapperObj.isError == true);
            system.assert(wrapperObj.errorMsg == Label.CuAp_SelectLocationError);
        }
    }
    
     /******************************************************************************
    @author:      Echo: Neha
    @date:        18-12-2018  
    @description: method for RuralEntitlement error 
    *******************************************************************************/
    static testmethod void RuralEntitlementError()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Location__c objLocation = [SELECT Id FROM Location__c LIMIT 1];
        RuralChannel__c objRuralChannel = [SELECT Id FROM RuralChannel__c LIMIT 1];
        RuralEntitlement__c objRuralEntitlement = new RuralEntitlement__c(); 
        
        // Create RuralOrder Record 
        RuralOrder__c  objRuralOrder = GlUt_FactoryData_Test.createRuralOrder(objLocation, objRuralChannel , objRuralEntitlement, VOLUME);        
      
        System.runAs(objUser){
            Test.startTest();             
            LoAp_RuralOrderCtrlr.ROWrapperClass wrapperObj = new LoAp_RuralOrderCtrlr.ROWrapperClass(); 
            wrapperObj = LoAp_RuralOrderCtrlr.onSave(objRuralOrder);
            Test.stopTest();            
            system.assert(wrapperObj.isError == true);
            system.assert(wrapperObj.errorMsg == Label.LoAp_RuralEntitlementInvalid);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        18-12-2018  
    @description: method for RuralChannel error 
    *******************************************************************************/
    static testmethod void RuralChannelError()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Location__c objLocation = [SELECT Id FROM Location__c LIMIT 1];
        RuralChannel__c objRuralChannel = new RuralChannel__c(); 
        RuralEntitlement__c objRuralEntitlement = [SELECT Id FROM RuralEntitlement__c LIMIT 1]; 
        
        // Create RuralOrder Record 
        RuralOrder__c  objRuralOrder = GlUt_FactoryData_Test.createRuralOrder(objLocation, objRuralChannel , objRuralEntitlement, VOLUME);        
      
        System.runAs(objUser){
            Test.startTest();             
            LoAp_RuralOrderCtrlr.ROWrapperClass wrapperObj = new LoAp_RuralOrderCtrlr.ROWrapperClass(); 
            wrapperObj = LoAp_RuralOrderCtrlr.onSave(objRuralOrder);
            Test.stopTest();            
            system.assert(wrapperObj.isError == true);
            system.assert(wrapperObj.errorMsg == Label.LoAp_RuralChannelInvalid);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        18-12-2018  
    @description: method for OrderDate error 
    *******************************************************************************/
    static testmethod void OrderDateError()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Location__c objLocation = [SELECT Id FROM Location__c LIMIT 1];
        RuralChannel__c objRuralChannel = [SELECT Id FROM RuralChannel__c LIMIT 1]; 
        RuralEntitlement__c objRuralEntitlement = [SELECT Id FROM RuralEntitlement__c LIMIT 1]; 
        
        // Create RuralOrder Record 
        RuralOrder__c objRuralOrder = GlUt_FactoryData_Test.createRuralOrder(objLocation, objRuralChannel , objRuralEntitlement, VOLUME );        
      
        System.runAs(objUser){
            Test.startTest();             
            LoAp_RuralOrderCtrlr.ROWrapperClass wrapperObj = new LoAp_RuralOrderCtrlr.ROWrapperClass(); 
            wrapperObj = LoAp_RuralOrderCtrlr.onSave(objRuralOrder);
            Test.stopTest();            
            system.assert(wrapperObj.isError == true);
            system.assert(wrapperObj.errorMsg == Label.LoAp_OrderDateError);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        29-01-2018  
    @description: method for insert  a new record
    *******************************************************************************/
    static testmethod void InsertRuralOrder()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        Location__c objLocation = [SELECT Id FROM Location__c LIMIT 1];
        RuralChannel__c objRuralChannel = [SELECT Id FROM RuralChannel__c LIMIT 1]; 
        RuralEntitlement__c objRuralEntitlement = [SELECT Id FROM RuralEntitlement__c LIMIT 1]; 
        
        // Create RuralOrder Record 
        RuralOrder__c  objRuralOrder = GlUt_FactoryData_Test.createRuralOrder(objLocation, objRuralChannel , objRuralEntitlement, VOLUME );        
        objRuralOrder.OrderDate__c = system.today();
        
        System.runAs(objUser){
            Test.startTest();             
            LoAp_RuralOrderCtrlr.ROWrapperClass wrapperObj = new LoAp_RuralOrderCtrlr.ROWrapperClass(); 
            wrapperObj = LoAp_RuralOrderCtrlr.onSave(objRuralOrder);
            Test.stopTest();            
            system.assert(wrapperObj.isError == false);            
        }
    }          
}