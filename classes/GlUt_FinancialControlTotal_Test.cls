/******************************************************************************
@author:      Echo: Tarun Gupta
@date:        04 Apr 2018
@description: Test Class for GlUt_FinancialControlTotal
@Revisions	  	AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest
Private class GlUt_FinancialControlTotal_Test {
    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='FN123LN123'; 
    private static final String USER_FNAME= 'FN123';
    private static final String USER_LNAME= 'LN123';
    
    private static final String SERVICE_TYPE_NAME     = 'Water';
    private static final String SERVICE_ITEM_FAMILYNAME = 'Measured Water Volumetric';
    private static final String SERVICE_ITEM_TYPE     = 'Measured Water Volumetric';
    private static final String MANUFACTURER       = 'Siemens';
    private static final String UNIT_OF_MEASURE     = 'Metric';
    private static final String DEVICE_SIZE        = 'TestDeviceSize';
    private static final String WHOLESALER_NAME      = 'Wholesale System';
    
    private static final String FTET_NAME      = 'FTET-1';
    private static final String FTET_CATEGORY      = 'Bill Calculation';
    private static final String FTET_OBJECT      = 'Bill Item';
    private static final String FTET_NAME_C      = 'Agent Real Time Bill Calculation';
    
    private static final String EFFECTIVE_PERIOD_ID      = 'ABC123';
    private static final String EFFECTIVE_PERIOD      = '4';
    private static final String EFFECTIVE_YEAR      = '2018';
    private static final String ACTUAL_PERIOD_ID      = 'XYZ456';
    private static final String ACTUAL_PERIOD      = '5';
    private static final String ACTUAL_YEAR      = '2017';
    
    private static final String MONTHLY      = 'MONTHLY';
    private static final DECIMAL AMOUNT      = 100;
    private static final DECIMAL DISCAMOUNT      = 10;
    private static final DECIMAL TAXAMOUNT      = 20;
        
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        04 Apr 2018
    @description: Test method to create dummy data
    *******************************************************************************/
    
    @TestSetup
    Static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        // Create ServiceType Record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(SERVICE_TYPE_NAME);
        Database.insert(objServiceType);
        
        // Create ServiceItemFamily Record
        ServiceItemFamily__c objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICE_ITEM_FAMILYNAME,objServiceType);
        Database.insert(objServiceItemFamily);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Division Record
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        // Create Wholesaler Record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER_NAME);
        Database.insert(objWholesaler);
        
        // Create ServiceItemType Record
        ServiceItemType__c objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICE_ITEM_TYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType); 
        
        FinancialTransactionEventType__c  objFinancialTransactionEventType = GlUt_FactoryData_Test.createFinancialTransactionEventType();
        objFinancialTransactionEventType.Name = FTET_NAME;
        objFinancialTransactionEventType.Category__c = FTET_CATEGORY;
        objFinancialTransactionEventType.Object__c = FTET_OBJECT;
        objFinancialTransactionEventType.Name__c = FTET_NAME_C;
        Database.insert(objFinancialTransactionEventType);
        
        FinancialControl__c  objFinancialControl = GlUt_FactoryData_Test.createFinancialControl();
        objFinancialControl.ServiceItemType__c = objServiceItemType.Id;
        objFinancialControl.FinancialTransactionEventType__c = objFinancialTransactionEventType.Id;
        objFinancialControl.EffectivePeriodId__c = EFFECTIVE_PERIOD_ID;
        objFinancialControl.EffectivePeriod__c = EFFECTIVE_PERIOD;
        objFinancialControl.EffectiveYear__c = EFFECTIVE_YEAR;
        objFinancialControl.ActualPeriodId__c = ACTUAL_PERIOD_ID;
        objFinancialControl.ActualPeriod__c = ACTUAL_PERIOD;
        objFinancialControl.ActualYear__c = ACTUAL_YEAR;
        objFinancialControl.BillingFrequency__c = MONTHLY;
        objFinancialControl.Amount__c = AMOUNT;
        objFinancialControl.DiscountAmount__c = DISCAMOUNT;
        objFinancialControl.TaxAmount__c = TAXAMOUNT;
        Database.insert(objFinancialControl);
    }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        04 Apr 2018
    @description: Test method for FinancialTotalEffective() method
    *******************************************************************************/
    
    static testmethod void checkFinancialControlTotalRecords(){               
        
        List<FinancialControlTotal__c> listFCT = new List<FinancialControlTotal__c>();
        List<User> objUser = [SELECT  Id, 
                                      Name, 
                                      FirstName, 
                                      LastName 
                                      FROM User 
                                      WHERE isActive = TRUE 
                                      AND LastName = :USER_LNAME];
        
        List<FinancialControl__c> lstFinControl = [SELECT  Id,Name,ServiceItemType__c,FinancialTransactionEventType__c,
                                                           EffectivePeriodId__c,EffectivePeriod__c,EffectiveYear__c,
                                                           ActualPeriodId__c,ActualPeriod__c,ActualYear__c,
                                                           BillingFrequency__c,Amount__c,DiscountAmount__c,TaxAmount__c
                                                   FROM FinancialControl__c LIMIT 10]; 
        
        System.runAs(objUser[0]){
            Test.starttest();
            GlUt_FinancialControlTotal.FinancialTotalEffective(lstFinControl);
            Test.stoptest();
            listFCT = [SELECT Id FROM FinancialControlTotal__c LIMIT 10];
            System.assert(listFCT.size() > 0);
        }
    }

}