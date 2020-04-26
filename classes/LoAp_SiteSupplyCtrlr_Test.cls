/******************************************************************************
@author:      Echo: Vivek Sethi
@date:        15 February 2019
@description: Test Class for LoAp_SiteSupplyCtrlr_Test
*******************************************************************************/
@isTest
public class LoAp_SiteSupplyCtrlr_Test{
    //Variable declaration start
   
    private static final String PROFILENAME = 'System Administrator';
    private static final String USERNAME = 'TestUser111';
    private static final String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    private static final String LOCATION_NAME       = 'A99 9AA';
    private static final String SP_USAGE_TYPE       = 'SupplyPointUsageType';
    private static final String LOCATION_SUB_TYPE   = 'Detached';
    private static final String STREET              = 'teststreet';
    private static final String DEVICE_SIZE         = 'TestDeviceSize';
    private static final String DEVICE_NAME         = 'TestDevice';
    private static final String MANUFACTURER        = 'Siemens';
    private static final String UNIT_OF_MEASURE     = 'Metric';
    private static final String LOCATIONADDRESS     = 'Test';
    
    //Variable declaration end
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi
    @date:        15 February 2019
    @description: Test data setup method
    *******************************************************************************/
    @TestSetup
    static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(PROFILENAME,USERNAME,null);
        Database.insert(objUser); 

        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME ,objDeviceType );
        Database.insert(objDevice);
        
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c = LOCATIONADDRESS;
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        SupplyPointDevice__c objSupplyPointDevice = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice, objSupplyPoint);
        Database.insert(objSupplyPointDevice);
        
        List<SupplyPoint__c> supplyPointList = new List<SupplyPoint__c>();
        SupplyPoint__c objSupplyPoint1 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        supplyPointList.add(objSupplyPoint1);
        
        SupplyPoint__c objSupplyPoint2 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint2.SpecialInstructions__c = 'Test';
        supplyPointList.add(objSupplyPoint2);
        
        SupplyPoint__c objSupplyPoint3 = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        supplyPointList.add(objSupplyPoint3);
        Database.insert(supplyPointList);
        
        List<SiteSupply__c> siteSupplyList = new List<SiteSupply__c>();
        SiteSupply__c objSiteSupplyExisting = GlUt_FactoryData_Test.createSiteSupply(objSupplyPoint, objSupplyPoint1);
        objSiteSupplyExisting.PercentageSplit__c = 10;
        objSiteSupplyExisting.EndDate__c = system.today() + 30;
        objSiteSupplyExisting.Invalid__c = false;
        objSiteSupplyExisting.AmendedBySiteSupply__c = null;
        siteSupplyList.add(objSiteSupplyExisting);
        
        SiteSupply__c objSiteSupplyExisting1 = GlUt_FactoryData_Test.createSiteSupply(objSupplyPoint, objSupplyPoint1);
        objSiteSupplyExisting1.PercentageSplit__c = 20;
        objSiteSupplyExisting1.EndDate__c = system.today() + 20;
        objSiteSupplyExisting1.Invalid__c = false;
        objSiteSupplyExisting1.AmendedBySiteSupply__c = null;
        siteSupplyList.add(objSiteSupplyExisting1);
        
        SiteSupply__c objSiteSupplyRemoved = GlUt_FactoryData_Test.createSiteSupply(objSupplyPoint, objSupplyPoint3);
        objSiteSupplyRemoved.Invalid__c = false;
        objSiteSupplyRemoved.PercentageSplit__c = 30;
        objSiteSupplyRemoved.EndDate__c = system.today() + 30;
        objSiteSupplyRemoved.AmendedBySiteSupply__c = null;
        siteSupplyList.add(objSiteSupplyRemoved);
        Database.insert(siteSupplyList);
    }
    
    /******************************************************************************
	@author:      Vivek Sethi
	@date:        15 February 2019
	@description: Test method for getInfoToDisplay() method positive scenario 
	*******************************************************************************/
    static testmethod void getInfoToDisplay_Positive(){
        
        List<SupplyPoint__c> sPList =  [SELECT Id FROM SupplyPoint__c  WHERE Measured__c = True LIMIT  1];
        LoAp_SiteSupplyCtrlr.ContainerWrapper infoToDisplay = new LoAp_SiteSupplyCtrlr.ContainerWrapper();
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            infoToDisplay = LoAp_SiteSupplyCtrlr.getInfoToDisplay(sPList[0].Id); 
            Test.stopTest();
            System.assertEquals(infoToDisplay.isShowCmp, true);
            System.assertNotEquals(infoToDisplay.objSP, null);
        }
    } 
    
    /******************************************************************************
	@author:      Vivek Sethi
	@date:        15 February 2019
	@description: Test method for getInfoToDisplay() method negative scenario
	*******************************************************************************/
    static testmethod void getInfoToDisplay_Negative(){
        List<SupplyPoint__c> sPList =  [SELECT Id FROM SupplyPoint__c  WHERE Measured__c != True LIMIT  1];
        LoAp_SiteSupplyCtrlr.ContainerWrapper infoToDisplay = new LoAp_SiteSupplyCtrlr.ContainerWrapper();
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
        
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            infoToDisplay = LoAp_SiteSupplyCtrlr.getInfoToDisplay(sPList[0].Id); 
            Test.stopTest();
            System.assertEquals(infoToDisplay.isShowCmp, false);
        }
    }
    
    /******************************************************************************
	@author:      Vivek Sethi
	@date:        15 February 2019
	@description: Test method for AddMoreRows() 
	*******************************************************************************/
    static testmethod void AddMoreRows(){
        LoAp_SiteSupplyCtrlr.SiteSupplyWrapper addMoreRows = new LoAp_SiteSupplyCtrlr.SiteSupplyWrapper();
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            addMoreRows = LoAp_SiteSupplyCtrlr.AddMoreRows(); 
            Test.stopTest();
            System.assertNotEquals(addMoreRows, null);
        }
    }
    
    /******************************************************************************
	@author:      Vivek Sethi
	@date:        15 February 2019
	@description: Test method for getAccountNameById()  positive scenario 
	*******************************************************************************/
    static testmethod void getAccountNameById_Positive(){
        String strAdress;
         List<Location__c> lList =  [SELECT Id FROM Location__c  LIMIT  1];
         User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            strAdress = LoAp_SiteSupplyCtrlr.getAccountNameById(lList[0].Id); 
            Test.stopTest();
            System.assertNotEquals(strAdress, Null);
        }
    }
    
   /******************************************************************************
	@author:      Vivek Sethi
	@date:        15 February 2019
	@description: Test method for getAccountNameById()  negative scenario
	*******************************************************************************/
    static testmethod void getAccountNameById_Negative(){
        String strAdress;
        List<Location__c> lList   = new List<Location__c>();
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
        Boolean isException = false;
        //Run test class in user context
        System.runAs(objUser){
            try{
                Test.startTest();
                strAdress = LoAp_SiteSupplyCtrlr.getAccountNameById(lList[0].Id); 
                Test.stopTest();
            }catch(exception e){
                isException = true;                
            }
            System.assertEquals(strAdress, null);
            System.assertEquals(isException, true);
        }
    }
  
    /******************************************************************************
	@author:      Vivek Sethi
	@date:        15 February 2019
	@description: Test method for ProcessSiteSupply  positive scenario 
	*******************************************************************************/
    static testmethod void ProcessSiteSupply_Positive(){
        List<Account> aList =  [SELECT Id FROM Account  LIMIT  1];
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
        List<SiteSupply__c> objSiteSupplyExisting = [SELECT Id, StartDate__c, Enddate__c, SupplyPoint__c, SiteSupplyPoint__c , PercentageSplit__c FROM SiteSupply__c  WHERE PercentageSplit__c =:10];
        objSiteSupplyExisting[0].PercentageSplit__c = 40;
        List<SiteSupply__c> objSiteSupplyRemoved = [SELECT Id, StartDate__c, Enddate__c, SupplyPoint__c, SiteSupplyPoint__c , PercentageSplit__c FROM SiteSupply__c  WHERE PercentageSplit__c =:30 LIMIT  1];
        List<SupplyPoint__c> objSupplyPoint = [Select Id from SupplyPoint__c WHERE SpecialInstructions__c != NULL ];
        List<SupplyPoint__c> objSiteSupplyPoint = [Select Id from SupplyPoint__c WHERE Measured__c = TRUE ];
        List<Id> siteSupplyRemovedId = new List<Id>();
        for(SiteSupply__c siteSupply : objSiteSupplyRemoved) {
            siteSupplyRemovedId.add(siteSupply.SupplyPoint__c);
            
        }
        List<SiteSupply__c> siteSupplyNew = new List<SiteSupply__c>();
        SiteSupply__c objSiteSupplyNew = GlUt_FactoryData_Test.createSiteSupply(objSiteSupplyPoint[0], objSupplyPoint[0]);
        objSiteSupplyNew.Invalid__c = false;
        objSiteSupplyNew.PercentageSplit__c = 20;
        objSiteSupplyNew.EndDate__c = system.today() + 30;
        objSiteSupplyNew.AmendedBySiteSupply__c = null;
        siteSupplyNew.add(objSiteSupplyNew);
        
        String jsonStrSiteSupplyExisting = JSON.serialize(objSiteSupplyExisting);
        String jsonStrSiteSupplyNew = JSON.serialize(siteSupplyNew);
        String jsonStrSiteSupplyRemoved = JSON.serialize(siteSupplyRemovedId);
        
        LoAp_SiteSupplyCtrlr.RecordsProcessedWrapper isDataSaved = new LoAp_SiteSupplyCtrlr.RecordsProcessedWrapper();
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            isDataSaved = LoAp_SiteSupplyCtrlr.ProcessSiteSupply(jsonStrSiteSupplyNew, jsonStrSiteSupplyExisting ,jsonStrSiteSupplyRemoved); 
            Test.stopTest();
            System.assertNotEquals(isDataSaved.siteSupplyContractlist, Null);
            System.assertEquals(isDataSaved.isSuccess, true);
        }
    }
        
    /******************************************************************************
	@author:      Vivek Sethi
	@date:        01 February 2019
	@description: Test method for SaveSplitPaymentsData()  positive scenario 
	*******************************************************************************/
    static testmethod void ProcessSiteSupply_Negative(){
        List<Account> aList =  [SELECT Id FROM Account  LIMIT  1];
        User objUser = [SELECT Id,name FROM user WHERE isActive=true AND username =: USERNAMECOMPLETE LIMIT 1];
 
        List<SiteSupply__c> objSiteSupplyExisting = [SELECT Id, StartDate__c, Enddate__c, SupplyPoint__c, SiteSupplyPoint__c , PercentageSplit__c FROM SiteSupply__c  WHERE PercentageSplit__c =:10];
        
        String jsonStrSiteSupplyExisting = JSON.serialize(objSiteSupplyExisting);
        String jsonStrSiteSupplyNew = JSON.serialize(objSiteSupplyExisting);
        String jsonStrSiteSupplyRemoved = JSON.serialize(objSiteSupplyExisting);
        
        Boolean isException;
        LoAp_SiteSupplyCtrlr.RecordsProcessedWrapper isDataSaved = new LoAp_SiteSupplyCtrlr.RecordsProcessedWrapper();
        //Run test class in user context
        System.runAs(objUser){
            try{
                Test.startTest();
                isDataSaved = LoAp_SiteSupplyCtrlr.ProcessSiteSupply(jsonStrSiteSupplyNew, jsonStrSiteSupplyExisting ,jsonStrSiteSupplyRemoved); 
                Test.stopTest();
            }catch(exception e){
                isException = true;                
            }
            System.assertEquals(isException, true);
        }
    }
}