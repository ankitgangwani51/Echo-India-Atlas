/******************************************************************************
@author:      Echo: Mohit Tayal
@date:        16 January 2018
@description: Test Class for DrUt_MarkForDisconnection 
*******************************************************************************/
@isTest
public class DrUt_MarkForDisconnection_Test {
    
    private static final String USER_PROFILE        = 'System Administrator';
    private static final String USER_NAME           = 'TestUser'; 
    private static final String USERNAMECOMPLETE    = USER_NAME+ '@unitest.com';
    private static final String ACCOUNT_NAME        = 'TestAccount'; 
    private static final String CONTRACT_NAME       = 'TestContract';
    private static final String DEVICE_NAME         = 'TestDevice';
    private static final String DEVICE_TYPE         = 'TestDeviceType';
    private static final String TEST_SERVICE_TYPE1   = 'TestServiceType1';
    private static final String TEST_SERVICE_TYPE2   = 'TestServiceType2';
    private static final String TESTSPLYPNTUSAGETYPT = 'TestSupplyPointUsageType';
    private static final String LOCATION_NAME       = 'A99 9AA';
    private static final String YES                 = 'yes';
    private static final String MEASURED            = 'Monthly';
    private static final String WHOLESALER          = 'TestWholesaler';
    private static final String AVAILABLESERVICES   = 'TestAvailableService';
    private static final String YEARLY              = 'Yearly';
    private static final String DEVICE_SIZE 		= 'TestDeviceSize';
    private static final String MANUFACTURER 		= 'Siemens';
    private static final String UNIT_OF_MEASURE 	= 'Metric';
    
/*******************************************************************
@author:      Echo: Mohit Tayal
@date:        16 January 2018
@param:       N/A
@return:      void
@description: Method to create test data used by all test methods
********************************************************************/
    @TestSetup
    static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        Database.insert(objUser); 
        
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        BillingContract__c con = GlUt_FactoryData_Test.createContract(CONTRACT_NAME,objAccount); 
        Database.insert(con);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME ,objDeviceType);
        Database.insert(objDevice);
        
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(TEST_SERVICE_TYPE1);
        Database.insert(objServiceType);
        
        ServiceType__c objServiceType2 = GlUt_FactoryData_Test.createServiceType(TEST_SERVICE_TYPE2);
        Database.insert(objServiceType2);
        
        Reading__c objReading1 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading1.ReadingDate__c = Date.today();
        Database.insert(objReading1); 
  
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        Database.insert(objLocation);
        
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(TESTSPLYPNTUSAGETYPT);
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
        
        Service__c objService1 = GlUt_FactoryData_Test.createService(con,objReading1,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService1);    
        
        Service__c objService2 = GlUt_FactoryData_Test.createService(con,objReading1,objServiceType2,objSupplyPoint,objAvailableService);
        Database.insert(objService2);
        
        //Create Debt. Recovery Process record
        DebtRecoveryProcess__c objDebtRecProcess = GlUt_FactoryData_Test.createDebtRecoveryProcess(con);
        objDebtRecProcess.ProcessComplete__c = TRUE;
        Database.insert(objDebtRecProcess);
        
        //Create Debt. Recovery Action record
        DebtRecoveryAction__c objDebtRecAct1 = GlUt_FactoryData_Test.createDebtRecoveryAction(objDebtRecProcess);
        objDebtRecAct1.Processed__c = FALSE;
        Database.insert(objDebtRecAct1);
        
        DebtRecoveryAction__c objDebtRecAct2 = GlUt_FactoryData_Test.createDebtRecoveryAction(objDebtRecProcess);
        objDebtRecAct2.Processed__c = FALSE;
        Database.insert(objDebtRecAct2);
    }
     
/*******************************************************************
@author:      ECHO: Mohit Tayal
@date:        01 Feb 2018
@param:       N/A
@return:      void
@description: Positive Test scenario for markForDisconnection
********************************************************************/
 
      static testmethod void markForDisconnection_PositiveTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1]; 
    
        List<DebtRecoveryAction__c> debtRecoveryActList = [SELECT Id FROM DebtRecoveryAction__c WHERE Processed__c = FALSE];    
        List<Id> debtRecoveryActId = new List<Id>();
        
        for(DebtRecoveryAction__c dRRec: debtRecoveryActList)
        {
            debtRecoveryActId.add(dRRec.Id);
        }   
          
        System.runAs(objUser){
            Test.startTest();
            DrUt_MarkForDisconnection.markForDisconnection(debtRecoveryActId);
            Test.stopTest();
            
            for(DebtRecoveryAction__c objDebtRecAct : [SELECT Id,Processed__c FROM DebtRecoveryAction__c WHERE Id IN :debtRecoveryActId]){
                System.assertEquals(TRUE, objDebtRecAct.Processed__c);
            }

            for(SupplyPoint__c objSupplyPoint : [SELECT Id, DisconnectionStatus__c FROM SupplyPoint__c WHERE AllowDisconnection__c = TRUE]){
                System.assertEquals(DrBt_Constants.TOBEDISCONNECTED, objSupplyPoint.DisconnectionStatus__c);
            }
        }
    }
    
/*******************************************************************
@author:      ECHO: Mohit Tayal
@date:        01 Feb 2018
@param:       N/A
@return:      void
@description: Negative Test scenario for markForDisconnection
********************************************************************/
      static testmethod void markForDisconnection_NegativeTest(){
        User objUser = [SELECT Id,Name FROM User WHERE isActive=TRUE AND Username =: USERNAMECOMPLETE LIMIT 1]; 
    
        List<DebtRecoveryAction__c> debtRecoveryActList = [SELECT Id FROM DebtRecoveryAction__c WHERE Processed__c = TRUE];    
        List<Id> debtRecoveryActId = new List<Id>();
        
        for(DebtRecoveryAction__c dRRec: debtRecoveryActList)
        {
            debtRecoveryActId.add(dRRec.Id);
        }   
          
        System.runAs(objUser){
            Test.startTest();
            DrUt_MarkForDisconnection.markForDisconnection(debtRecoveryActId);
            Test.stopTest();
            
            List<DebtRecoveryAction__c> debtRecActList = [SELECT Id,Processed__c FROM DebtRecoveryAction__c WHERE Id IN :debtRecoveryActId];
            System.assert(debtRecActList.size() == 0);

            for(SupplyPoint__c objSupplyPoint : [SELECT Id, DisconnectionStatus__c FROM SupplyPoint__c WHERE AllowDisconnection__c = TRUE]){
                System.assertNotEquals(DrBt_Constants.TOBEDISCONNECTED, objSupplyPoint.DisconnectionStatus__c);
            }
        }
    }       
}