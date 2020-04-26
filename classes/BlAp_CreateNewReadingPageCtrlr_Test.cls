/******************************************************************************
@author:      Echo: Tarun Gupta
@date:        22 Dec 2017
@description: Test Class for BlAp_CreateNewReadingPageCtrlr
*******************************************************************************/
@isTest
public class BlAp_CreateNewReadingPageCtrlr_Test {
    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='FN123LN123'; 
    private static final String USER_FNAME= 'FN123';
    private static final String USER_LNAME= 'LN123';    
    private static String YES ='yes';
    private static String MEASURED = 'measured';    
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static String DEVICE_TYPE ='TestDeviceType';
    private static String DEVICE_NAME = 'TestDevice'; 
    private static String ACTUAL_READING ='5555';     
    private static String ZIP_CODE ='B91 2JA'; 
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        22 Dec 2017
    @description: Test method for fetchdevicedata() method
    *******************************************************************************/
    
    @TestSetup
    Static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICE_NAME ,objDeviceType );
        objDevice.Digit__c = 4;
        Database.insert(objDevice);
        
        Reading__c  objReadingNew = GlUt_FactoryData_Test.CreateReading(objDevice);        
        objReadingNew.ActualDeviceReading__c = ACTUAL_READING;
        objReadingNew.ReadingDate__c = system.today() -1 ;
        Database.insert(objReadingNew); 
        
        Reading__c  objReadingNew2 = GlUt_FactoryData_Test.CreateReading(objDevice);        
        objReadingNew2.ActualDeviceReading__c = ACTUAL_READING;
        objReadingNew2.ReadingDate__c = system.today() - 2 ;
        Database.insert(objReadingNew2);
        
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(ZIP_CODE);
        Database.insert(objLocation);
    }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        22 Dec 2017
    @description: Test method for picklistvaluesnew() method
    *******************************************************************************/
 /*   static testmethod void pickListValues_Positive(){
        
        //Query user record created in test setup data method
        User objUser =[SELECT id,name FROM user WHERE isActive = TRUE AND LastName = :USER_LNAME];
        
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            Map<String,List<String>> lstString = BlAp_CreateNewReadingPageCtrlr.picklistvaluesnew();
            Test.stopTest();            
            Boolean contains = lstString.containsKey('ReadingSource__c');
            System.assertEquals(true, contains);
        }
    }*/
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        22 Dec 2017
    @description: Test method for fetchdevicedata() method
    *******************************************************************************/
    
    static testmethod void fetchDeviceData_Positive(){               
        
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];  
        List<Device__c> objDevId = [SELECT Id FROM Device__c];  
        Id DeviceId = objDevId[0].id;
        
        System.runAs(objUser[0]){
            Test.starttest();
            BlAp_CreateNewReadingPageCtrlr.WrapSelectDevice availDevices = BlAp_CreateNewReadingPageCtrlr.fetchdevicedata(DeviceId);                         
            Test.stoptest();
            System.assertEquals(availDevices.actualReading,ACTUAL_READING);            
        }
    }
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        22 Dec 2017
    @description: Test method for saveNewReading() method
    *******************************************************************************/
    /*
    static testmethod void saveNewReading_Positive(){               
        
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];  
        
        List<Device__c> objDevice = [SELECT Id FROM Device__c]; 
        
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice[0]);        
        objReading.ActualDeviceReading__c = ACTUAL_READING;
        
        System.runAs(objUser[0]){
            Test.starttest();
            String strObj_positive = BlAp_CreateNewReadingPageCtrlr.saveNewReading(objReading,null);                                 
            Test.stoptest();             
            System.assertEquals(strObj_positive.length(),18);            
        }
    }
    */
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        22 Dec 2017
    @description: Negative Test method for saveNewReading() method
    *******************************************************************************/
    /*
    static testmethod void saveNewReading_Negative(){               
        
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME]; 
        
        List<Device__c> objDevice = [SELECT Id, Name FROM Device__c limit 1]; 
        
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice[0]);        
        objReading.ActualDeviceReading__c = ACTUAL_READING;
        objReading.ReadingDate__c = system.today();
        
        List<Reading__c> lstRead = [Select Id,Name,ReadingDate__c from Reading__c];
        
        //Reading Object full for Insertion        
        //Id field for updating the amendded by
        Date newDate = system.today() - 2;
        
        Reading__c objReadingId = [Select Id,Name,DeviceReference__c,ReadingDate__c from Reading__c WHERE ActualDeviceReading__c =: ACTUAL_READING AND ReadingDate__c = :newDate Limit 1];        
        
        System.runAs(objUser[0]){
            Test.starttest();
            String strObj_negative = BlAp_CreateNewReadingPageCtrlr.saveNewReading(objReading,objReadingId.Id);                     
            Test.stoptest();             
            System.assertEquals(strObj_negative.length(),18);            
        }
    }
    */
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        22 Dec 2017
    @description: Test method for saveNewReading() exception method
    *******************************************************************************/
    /*
    static testmethod void saveNewReading_Exception(){               
        
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME]; 
        
        List<Device__c> objDevice = [SELECT Id, Name FROM Device__c limit 1]; 
        
        Reading__c  objReading = GlUt_FactoryData_Test.CreateReading(objDevice[0]);        
        objReading.ActualDeviceReading__c = ACTUAL_READING;
        objReading.ReadingDate__c = system.today();
        objReading.BillableType__c = 'TESTBILLABLETYPE';
        
        System.runAs(objUser[0]){
            Test.starttest();            
            String strObj_exception = BlAp_CreateNewReadingPageCtrlr.saveNewReading(objReading,null);                     
            Test.stoptest(); 
            //This will make sure the flow goes in exception as there is no picklist value as 'TESTBILLABLETYPE' in Billable Type Picklist
            // Insert failed. First exception on row 0; first error: INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST, Billable Type: bad value for restricted picklist field: TESTBILLABLETYPE: [BillableType__c]
            Boolean contains = strObj_exception.contains('Billable Type');
            System.assertEquals(true, contains);
        }
    }
    */
    /******************************************************************************
    @author:      Echo: Amit K.
    @date:        19 March 2018
    @description: Test method for retrieveDeviceFields_Positive()
    *******************************************************************************/
    
     static testmethod void retrieveDeviceFields_Positive(){               
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];  
        System.runAs(objUser[0]){
            Test.starttest();
            List<List<GlAp_FieldProps>> objList = BlAp_CreateNewReadingPageCtrlr.retrieveDeviceFields();                                 
            Test.stoptest();
            System.assert(objList != null);
        }
         
    }    
    
    /******************************************************************************
    @author:      Echo: Amit K.
    @date:        19 March 2018
    @description: Test method for fetchReadings_Positive()
    *******************************************************************************/
    /*
    static testmethod void fetchReadings_Positive(){               
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];  
        List<Reading__c> objReading = [SELECT Id, Name,DeviceReference__c FROM Reading__c LIMIT 2];
        System.runAs(objUser[0]){
            Test.starttest();
            List<Reading__c> readingList = BlAp_CreateNewReadingPageCtrlr.fetchReadings(objReading[0], objReading[1].Id);                                 
            Test.stoptest();
            System.assert(readingList != null);
        }
    }
    */
    /******************************************************************************
    @author:      Echo: Amit K.
    @date:        19 March 2018
    @description: Test method for getLocation_Positive()
    *******************************************************************************/
     /*static testmethod void getLocation_Positive(){               
        List<User> objUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE isActive = TRUE AND LastName = :USER_LNAME];  
        List<Location__c> objLocation = [SELECT Id, Name FROM Location__c limit 1]; 
        
        System.runAs(objUser[0]){
            Test.starttest();
            Location__c locObject = BlAp_CreateNewReadingPageCtrlr.getLocation(objLocation[0].Id);                                 
            Test.stoptest();
            System.assertEquals(locObject.Id, objLocation[0].Id);
        }
    }*/
}