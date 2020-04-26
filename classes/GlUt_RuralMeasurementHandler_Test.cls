/******************************************************************************
@author:      Echo: Neha 
@date:        20-12-2018  
@description: Test Class for GlUt_RuralMeasurementHandler
*******************************************************************************/
@isTest  
public class GlUt_RuralMeasurementHandler_Test {   
    
    private static final String USER_PROFILE      = 'System Administrator';
    private static final String USER_NAME         = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME        = 'First_User_Name';
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
    private static final String BOX_BESIDE 		  = 'Box Beside';
    private static final Integer LOW_HEAD 		  = 1;
    private static final Integer BILLABLE_VOL     = 3; 
    private static final Decimal AVERAGE_HEAD     = 2;
    private static final Integer HEAD_READING     = 7;
    private static final Integer FLOW_RATE        = 2;
  
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
        
        // Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);        
        Database.insert(objAccount);
      
        //Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTACT_NAME,objAccount);
        objContract.DayOfMonth__c = DAY_OF_MONTH;
        objContract.DayOfWeek__c = DAY_OF_WEEK;        
        Database.insert(objContract); 
        
        // Create Area Record
        Area__c objArea = GlUt_FactoryData_Test.createArea(AREA_NAME);        
        Database.insert(objArea);
        
        // Create Depot Record
        Depot__c objDepot = GlUt_FactoryData_Test.createDepot(DEPOT_NAME);        
        Database.insert(objDepot);
        
        // Create RuralChannel Record**
        RuralChannel__c objRuralChannel = GlUt_FactoryData_Test.createRuralChannel(objArea, objDepot);          
        Database.insert(objRuralChannel);

        // Create Rural License Record
        RuralLicense__c objRuralLicense = GlUt_FactoryData_Test.createRuralLicense();
        objRuralLicense.BillingContract__c = objContract.Id;         
        Database.insert(objRuralLicense);
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        objLocation.RuralLicense__c=objRuralLicense.Id;
        Database.insert(objLocation);
        
        // Create RuralEntitlement Record
        RuralEntitlement__c objRuralEntitlement = GlUt_FactoryData_Test.createRuralEntitlement(objRuralLicense);
        objRuralEntitlement.RuralLicense__c=objRuralLicense.Id;
        objRuralEntitlement.Active__c=true;
        Database.insert(objRuralEntitlement);  
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create SupplyPoint Record        
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; 
        objSupplyPoint.AccessType__c = ACCESS_TYPE;
        objSupplyPoint.RuralOutletType__c = BOX_BESIDE;
        objSupplyPoint.RuralOutletSize__c = 12.00;
        objSupplyPoint.RuralChannel__c = objRuralChannel.Id;        
        Database.insert(objSupplyPoint);
        
        // Create RuralOrder Record 
        RuralOrder__c  objRuralOrder = GlUt_FactoryData_Test.createRuralOrder(objLocation, objRuralChannel , objRuralEntitlement, VOLUME);        
        objRuralOrder.OrderDate__c = ORDER_DATE;
        objRuralOrder.LowHeadVolume__c = LOW_HEAD;
        objRuralOrder.BillableVolume__c = BILLABLE_VOL;
        objRuralOrder.Outlet__c = objSupplyPoint.Id;
        Database.insert(objRuralOrder); 
      
        // Create ChannelFlowConversion Record 
        ChannelFlowConversion__c  objChannelFlowConversion = GlUt_FactoryData_Test.createChannelFlowConversion(objRuralChannel, HEAD_READING, FLOW_RATE); 
        objChannelFlowConversion.HeadReadingHigh__c = 10.00;
        objChannelFlowConversion.HeadReadingLow__c = 5.00;
        objChannelFlowConversion.RuralOutletSize__c = 12.00;
        objChannelFlowConversion.RuralOutletType__c = BOX_BESIDE;
        objChannelFlowConversion.Channel__c = objRuralChannel.Id;
        Database.insert(objChannelFlowConversion);
        
        // Create RuralMeasurement record
        RuralMeasurement__c objRuralMeasurement = GlUt_FactoryData_Test.createRuralMeasurement(objRuralChannel,objSupplyPoint,HEAD_READING); 
        objRuralMeasurement.DateTime__c = system.now() - 2;       
        objRuralMeasurement.Type__c = GlUt_Constants.START; 
        objRuralMeasurement.RuralOrder__c = objRuralOrder.Id;
        Database.insert(objRuralMeasurement);
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        20-12-2018  
    @description: method for errors
    *******************************************************************************/
    static testmethod void negativeScenario()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
       
        RuralChannel__c objRuralChannel = [SELECT Id FROM RuralChannel__c LIMIT 1];        
        SupplyPoint__c objSupplyPoint = [SELECT Id FROM SupplyPoint__c LIMIT 1];
        
        // Create RuralOrder Record 
        RuralMeasurement__c objRuralMeasurement = GlUt_FactoryData_Test.createRuralMeasurement(objRuralChannel,objSupplyPoint,HEAD_READING); 
        objRuralMeasurement.RuralChannel__c = null;
        objRuralMeasurement.SupplyPoint__c =  null;  
        objRuralMeasurement.Head__c =  null;
        Boolean isException = false;             
        System.runAs(objUser){
            try{
                Test.startTest();             
                insert(objRuralMeasurement);  
                Test.stopTest();
            }catch(Exception e){
                isException = true;
            }
            system.assert(isException == true);
            
        }
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        21-12-2018  
    @description: method for errors
    *******************************************************************************/
    static testmethod void positiveScenarioNormal()
    {            
        User objUser = [SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        RuralChannel__c objRuralChannel = [SELECT Id FROM RuralChannel__c LIMIT 1];        
        SupplyPoint__c objSupplyPoint = [SELECT Id FROM SupplyPoint__c LIMIT 1];
        RuralOrder__c objRuralOrder = [SELECT Id FROM RuralOrder__c LIMIT 1];
        
        // Create RuralOrder Record 
        RuralMeasurement__c objRuralMeasurement = GlUt_FactoryData_Test.createRuralMeasurement(objRuralChannel,objSupplyPoint,HEAD_READING); 
        objRuralMeasurement.DateTime__c = system.now();
        objRuralMeasurement.Head__c =  HEAD_READING; 
        objRuralMeasurement.Type__c = GlUt_Constants.NORMAL; 
        objRuralMeasurement.RuralOrder__c = objRuralOrder.Id; 
        
        Boolean isException = false;             
        System.runAs(objUser){
            try{
                Test.startTest();             
                insert(objRuralMeasurement);  
                Test.stopTest();
            }catch(Exception e){
                isException = true;
            }
            RuralGrossConsumption__c objRuralGrossConsumption = [SELECT Id FROM RuralGrossConsumption__c LIMIT 1];
            system.assert(objRuralGrossConsumption != null);
            
        }
    }
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        21-12-2018  
    @description: method for errors
    *******************************************************************************/
    static testmethod void positiveScenarioFinish()
    {            
        User objUser = [SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        ChannelFlowConversion__c objChannelFlowConversion = [SELECT Id, Channel__c, HeadReadingHigh__c, HeadReadingLow__c, RuralOutletSize__c, RuralOutletType__c FROM ChannelFlowConversion__c LIMIT 1];
        RuralChannel__c objRuralChannel = [SELECT Id FROM RuralChannel__c LIMIT 1];        
        SupplyPoint__c objSupplyPoint = [SELECT Id FROM SupplyPoint__c LIMIT 1];
        RuralOrder__c objRuralOrder = [SELECT Id FROM RuralOrder__c LIMIT 1];
        
        // Create RuralOrder Record 
        RuralMeasurement__c objRuralMeasurement = GlUt_FactoryData_Test.createRuralMeasurement(objRuralChannel,objSupplyPoint,HEAD_READING); 
        objRuralMeasurement.DateTime__c = system.now() - 1 ;
        objRuralMeasurement.AverageHead__c =  HEAD_READING;         
        objRuralMeasurement.Type__c = GlUt_Constants.NORMAL; 
        objRuralMeasurement.RuralOrder__c = objRuralOrder.Id; 
        objRuralMeasurement.ChannelFlowConversion__c = objChannelFlowConversion.Id;
        objRuralMeasurement.RuralChannel__c = objChannelFlowConversion.Channel__c;
        insert(objRuralMeasurement);
        
        // Create RuralOrder Record of finish type
        RuralMeasurement__c objRuralMeasurement1 = GlUt_FactoryData_Test.createRuralMeasurement(objRuralChannel,objSupplyPoint,HEAD_READING); 
        objRuralMeasurement1.DateTime__c = system.now();
        objRuralMeasurement1.AverageHead__c =  HEAD_READING; 
        objRuralMeasurement1.Type__c = GlUt_Constants.FINISH; 
        objRuralMeasurement1.RuralOrder__c = objRuralOrder.Id; 
        objRuralMeasurement1.ChannelFlowConversion__c = objChannelFlowConversion.Id;
        objRuralMeasurement1.RuralChannel__c = objChannelFlowConversion.Channel__c;
                
        Boolean isException = false;             
        System.runAs(objUser){
            try{
                Test.startTest();             
                insert(objRuralMeasurement1);  
                Test.stopTest();
            }catch(Exception e){
                isException = true;
            }
            ChannelOpen__c objChannelOpen = [SELECT Id FROM ChannelOpen__c LIMIT 1];
            system.assert(objChannelOpen != null);
        }
    }
    
    
}