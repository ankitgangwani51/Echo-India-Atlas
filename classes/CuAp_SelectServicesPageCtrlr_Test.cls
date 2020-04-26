/******************************************************************************
@author:      Echo: Tarun Gupta
@date:        07 Nov 2017
@description: Test Class for CuAp_SelectServicesPageController
Revisions(s): 10-Nov-2017 -- Tarun Gupta -- Updated class to remove hard coding
and implemented other code quality aspects.
*******************************************************************************/
@isTest
Private class CuAp_SelectServicesPageCtrlr_Test {
    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='FN123LN123'; 
    private static final String USER_FNAME= 'FN123';
    private static final String USER_LNAME= 'LN123';
    private static String TEST_SERVICE_TYPE ='TestServiceType';
    private static String LOCATION_NAME ='A99 9AA';
    private static String LOCATION_SUB_TYPE = 'Detached';
    private static String STREET = 'teststreet';
    private static String YES ='yes';
    private static String MEASURED = 'Monthly';
    private static String WHOLESALER ='TestWholesaler';
    private static String AVAILABLESERVICES ='TestAvailableService';            
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        07 Nov 2017
    @description: Test method for CuAp_fetchListOfAvailServicesTest() method
    *******************************************************************************/
    
    @TestSetup
    Static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        objLocation.LocationSubType__c=LOCATION_SUB_TYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        ServiceType__c objServiceType = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE );
        Database.insert(objServiceType);
        
        Division__c  objDivision = GlUt_FactoryData_Test.CreateDivision();
        Database.insert(objDivision);
        
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.CreateWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.CreateAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);        
    }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        07 Nov 2017
    @description: Positive Test method for CuAp_fetchListOfAvailServicesTest() method
    *******************************************************************************/
    
    static testmethod void fetchListOfAvailServices_Positive(){               
        
        User objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME limit 1];          
        List<Location__c> objLocId = [SELECT Id FROM Location__c];  
        Id LocationId = objLocId[0].id;
        List<BlAp_CombinedRecord> lstCombinedRec = new List<BlAp_CombinedRecord>();
        System.runAs(objUser){
            Test.starttest();
            CuAp_SelectServicesPageCtrlr.WrapAvailableService objWrapper = new CuAp_SelectServicesPageCtrlr.WrapAvailableService();
            objWrapper = CuAp_SelectServicesPageCtrlr.fetchListOfAvailServices(LocationId, String.valueOf(system.today()), Label.CuAp_AUMoveInOccType); 
            lstCombinedRec = objWrapper.availServiceListToBeReturn; 
            Test.stoptest();
            System.assertEquals(lstCombinedRec.size(),1);
            //System.assertEquals(availServices[0].availServiceId, [Select Id from AvailableService__c Limit 1][0].Id);
            
        }
    } 
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        07 Nov 2017
    @description: Negative Test method for CuAp_fetchListOfAvailServicesTest() method
    *******************************************************************************/
    
    static testmethod void fetchListOfAvailServices_Negative(){               
        
        User objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME limit 1];          
        List<Location__c> objLocId = [SELECT Id FROM Location__c];  
        Id LocationId = objLocId[0].id;
        List<BlAp_CombinedRecord> lstCombinedRec = new List<BlAp_CombinedRecord>();
        System.runAs(objUser){
            Test.starttest();
            
            CuAp_SelectServicesPageCtrlr.WrapAvailableService objWrapper = new CuAp_SelectServicesPageCtrlr.WrapAvailableService();
            objWrapper = CuAp_SelectServicesPageCtrlr.fetchListOfAvailServices(null, String.valueOf(system.today()), Label.CuAp_AUMoveInOccType); 
            lstCombinedRec = objWrapper.availServiceListToBeReturn;
            Test.stoptest();
            System.assertEquals(lstCombinedRec.size(),0);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        12 Dec 2017
    @description: Positive Test method for retrieveSerAvailServiceFieldPropDetails() method
    *******************************************************************************/    
    static testmethod void retrieveSerAvailServiceFieldPropDetails_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME limit 1];          
        
        //Run test class in user context
        system.runas(objUser){
            
            Test.startTest();
            List<GlAp_FieldProps> lstFieldProp = CuAp_SelectServicesPageCtrlr.retrieveSerAvailServiceFieldPropDetails();
            Test.stopTest();
            
            System.assert(lstFieldProp.size()>0);
        }
    }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        12 Dec 2017
    @description: Negative Test method for retrieveSerAvailServiceFieldPropDetails() method
    *******************************************************************************/    
    static testmethod void retrieveSerAvailServiceFieldPropDetails_Negative(){
        
        //Query user record created in test setup data method
        User objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME limit 1];          
        
        //change the constant for AvailableBundle__c object in order to test negative scenario        
        GlUt_APIConstantsServiceType.SERVICETYPEAPINAME = 'ServiceType';        

        Boolean isException = false; 
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            List<GlAp_FieldProps> lstFieldProp;
            try{
                lstFieldProp = CuAp_SelectServicesPageCtrlr.retrieveSerAvailServiceFieldPropDetails();
            }
            catch(Exception exc){
                isException = true;
            }
            Test.stopTest();
            System.assertEquals(lstFieldProp.isEmpty(),true);            
        }
       
    }
}