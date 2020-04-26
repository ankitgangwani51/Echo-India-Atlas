/******************************************************************************
@author:      Echo: Neha 
@date:        05-04-2018  
@description: Test Class for GlAp_NewRecordWithAmendmentCtrlr
@Revisions	  	AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest
public class GlAp_NewRecordWithAmendmentCtrlr_Test {
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name';
    private static final String DEVICE_SIZE = '20mm';
    private static final String MANUFACTURER = 'Siemens';
    private static final String FOUR_WEEKLY = 'Four weekly';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String READFREQUENCY_M = 'Monthly'; 
    private static final String DEVICE_NAME = '123456789';
    private static final String DEPOT_NAME = 'depot1';
    private static final String READTIMETABLE_NAME = 'RTT1';
    private static final string LOCATION= 'A99 9AA';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final string MEASURED= 'Monthly';
    private static final string YES = 'yes';
    private static final string LOCATION_NAME = 'ws2 8de';
    private static final string DEVICE_SERIALNO = '325362';
    private static final Integer DAILYUSAGE_START = 6;
    private static final Integer DAILYUSAGE_END = 500;
    private static final Integer ACCEPTPERCENTAGE_BELOW = 20;
    private static final Integer ACCEPTPERCENTAGE_ABOVE = 70;  
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        05-04-2018  
    @description: Test data setup method
    *******************************************************************************/
    @TestSetup
    static void createTestData()
    {
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USER_NAME, null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize, MANUFACTURER, UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create Location Record
        Location__c objLocationMain = GlUt_FactoryData_Test.createLocation(LOCATION_NAME);
        Database.insert(objLocationMain);
        
        // Create Depot Record
        Depot__c objDepot = GlUt_FactoryData_Test.createDepot(DEPOT_NAME);        
        Database.insert(objDepot);
        
        // Create ReadTimetable Record
        ReadTimetable__c objReadTimetable = GlUt_FactoryData_Test.createReadTimetable(READTIMETABLE_NAME, READFREQUENCY_M);        
        Database.insert(objReadTimetable);
        
        // Create ReadTimetableThresholds Record       
        ReadTimetableThresholds__c objReadTimetableThresholds = GlUt_FactoryData_Test.createReadTimetableThresholds(objReadTimetable, DAILYUSAGE_START, DAILYUSAGE_END, ACCEPTPERCENTAGE_BELOW, ACCEPTPERCENTAGE_ABOVE);        
        Database.insert(objReadTimetableThresholds);
        
        // Create Book Record
        Book__c objBook = GlUt_FactoryData_Test.createBook(objDepot,objReadTimetable) ; 
        objBook.ReadFrequency__c = FOUR_WEEKLY;
        objBook.BudgetResetMonth__c = 'April;September;November';
        Database.insert(objBook);
        
        // Create SupplyPoint Record        
        SupplyPoint__c objSupplyPointMain = GlUt_FactoryData_Test.createSupplyPoint(objLocationMain, objSupplyPointUsageType);
        objSupplyPointMain.Measured__c= True; // AT-3174 
        objSupplyPointMain.Book__c = objBook.Id;
        Database.insert(objSupplyPointMain);
        
        // Create Device Record
        Device__c  objDeviceMain = GlUt_FactoryData_Test.createDevice(DEVICE_SERIALNO , objDeviceType); 
        objDeviceMain.Digit__c = 3;
        objDeviceMain.SerialNo__c = DEVICE_SERIALNO;
        Database.insert(objDeviceMain);
        
        // Create Supply Point Device
        SupplyPointDevice__c  objSPDMain = GlUt_FactoryData_Test.createSupplyPointDevices(objDeviceMain , objSupplyPointMain);     
        Database.insert(objSPDMain);    
             
        // Create Reading Record
        Reading__c objReadingMain = GlUt_FactoryData_Test.createReading(objDeviceMain);   
        objReadingMain.ActualDeviceReading__c = '015';
        objReadingMain.ReadingDate__c = system.today() - 10;
        objReadingMain.Billed__c = true;
        objReadingMain.BillableType__c = System.Label.CuAp_ReadingBillableTypeBillable;
        Database.insert(objReadingMain);
        
        // Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATION);
        Database.insert(objLocation);
        
        // Create Device Record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);        
        Database.insert(objDevice);
        
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);   
        objReading.ActualDeviceReading__c = '015';
        objReading.ReadingDate__c = system.today();
        objReading.Billed__c = true;
        Database.insert(objReading); 
        
        // Create SupplyPoint Record        
        SupplyPoint__c objSupplyPointSub = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPointSub.Measured__c = TRUE;  //AT - 3174
        Database.insert(objSupplyPointSub);
            
        // Create Supply Point Device
        SupplyPointDevice__c  objSPDSub = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice,objSupplyPointSub);              
        Database.insert(objSPDSub);  
        
         // Create SupplyPointRelationship
        SupplyPointRelationship__c objSPR = GlUt_FactoryData_Test.createSupplyPointRelationship(objSupplyPointMain, objSupplyPointSub);
        objSPR.StartDate__c = system.today() - 10;
        Database.insert(objSPR);   
        
         // Create ADU
        AverageDailyUsage__c objADU = GlUt_FactoryData_Test.createAvgDailyUses(objSPDMain);
        objADU.StartDate__c = system.today() - 50;
        Database.insert(objADU);
        

    }

    /******************************************************************************
    @author:      Echo: Neha
    @date:        05-04-2018  
    @description: Test Method to update AmendedByReading field of reading by 
                  another reading record
    *******************************************************************************/
    static testmethod void saveRecords_Positive(){            
        
        User objUser =[SELECT Id, Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
      
        Id recordId;
        String newRecordObject, selectedRecords, selectedRecord;
        SupplyPointRelationship__c objSPR = [SELECT Id, SubSupply__c FROM SupplyPointRelationship__c LIMIT 1];
        SupplyPointDevice__c objSPD = [SELECT Device__c
                                          FROM SupplyPointDevice__c
                                          WHERE SupplyPoint__c =: objSPR.SubSupply__c
                                             AND Active__c = true LIMIT 1]; 
        
        Device__c objDevice = [SELECT Id FROM Device__c WHERE Id =: objSPD.Device__c LIMIT 1]; 
        List<Reading__c> readingList = [SELECT Id FROM Reading__c where Device__c =: objSPD.Device__c and ReadingDate__c =: system.today() LIMIT 1];     
        
        selectedRecords = JSON.serialize(readingList);
        selectedRecord = JSON.serialize(readingList[0]);
        
        
            
        // Create New Reading Record
        Reading__c objNewReading = GlUt_FactoryData_Test.createReading(objDevice);
        newRecordObject = JSON.serialize(objNewReading);  
        
        System.runAs(objUser){
            Test.startTest();
            recordId = GlAp_NewRecordWithAmendmentCtrlr.saveRecords(GlUt_APIConstantsReading.READINGAPINAME, newRecordObject, selectedRecords, GlUt_APIConstantsReading.AMENDEDBYREADINGAPINAME, selectedRecord); 
            Test.stopTest(); 
            system.assert(recordId != null);
           
        }         
    }  
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        05-04-2018  
    @description: Test Method to Throw error if amendment field name is not ID 
    *******************************************************************************/
    static testmethod void saveRecords_Error(){            
        
        User objUser =[SELECT Id, Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
      
        Id recordId;
        Boolean isException = false;
        String newRecordObject, selectedRecords, selectedRecord;
        
        Device__c objDevice = [SELECT Id FROM Device__c LIMIT 1]; 
        List<Reading__c> objReading = [SELECT Id FROM Reading__c LIMIT 1];        
        selectedRecords = JSON.serialize(objReading);
        selectedRecord = JSON.serialize(objReading[0]);
            
        // Create New Reading Record
        Reading__c objNewReading = GlUt_FactoryData_Test.createReading(objDevice);
        newRecordObject = JSON.serialize(objNewReading);  
        
        System.runAs(objUser){
            try{
                Test.startTest();
                recordId = GlAp_NewRecordWithAmendmentCtrlr.saveRecords(GlUt_APIConstantsReading.READINGAPINAME, newRecordObject, selectedRecords, GlUt_APIConstantsReading.READINGSOURCEAPINAME , selectedRecord); 
                Test.stopTest(); 
            }catch(Exception e){
                isException = true;
            }                
            system.assert(isException == true);          
        }         
    } 
    
    
    /******************************************************************************
    @author:      Echo: Neha
    @date:        04-07-2018  
    @description: Test Method to fetchDeviceReadings
    *******************************************************************************/
    static testmethod void fetchDeviceReadings_positive(){            
        
        User objUser =[SELECT Id, Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
      
        Id recordId;
        Boolean isException = false;
        String newRecordObject, selectedRecords;
        
        Device__c objDevice = [SELECT Id FROM Device__c LIMIT 1]; 
        List<Reading__c> readingList = new List<Reading__c>();      
        
        System.runAs(objUser){
            try{
                Test.startTest();
                readingList = GlAp_NewRecordWithAmendmentCtrlr.fetchDeviceReadings(objDevice.id); 
                Test.stopTest(); 
                system.assertNotEquals(readingList,null);
            }catch(Exception e){
                isException = true;
            }                
                   
        }         
    }
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi AT-3412
    @date:        29-08-2018  
    @description: Test Method to validateConsumption  First Reading
    *******************************************************************************/
    static testmethod void validateFirstReadingConsumption_positive(){            
        
        User objUser =[SELECT Id, Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        String returnType;
        String newRecordObject;
        
        SupplyPointRelationship__c objSPR = [SELECT Id, MainSupply__c FROM SupplyPointRelationship__c LIMIT 1];
        SupplyPointDevice__c objSPD = [SELECT Device__c
                                       FROM SupplyPointDevice__c
                                       WHERE SupplyPoint__c =: objSPR.MainSupply__c
                                       AND Active__c = true LIMIT 1]; 
        
        Device__c objDevice = [SELECT Id FROM Device__c WHERE Id =: objSPD.Device__c LIMIT 1]; 
        Reading__c readingObj = [SELECT Id, ReadingDate__c  FROM Reading__c where Device__c =: objSPD.Device__c LIMIT 1];        
        newRecordObject = JSON.serialize(readingObj);  
        
        System.runAs(objUser){
            Test.startTest();
            returnType = GlAp_NewRecordWithAmendmentCtrlr.validateConsumptionThreshold(GlUt_APIConstantsReading.READINGAPINAME , objDevice.id , newRecordObject, ''); 
            Test.stopTest(); 
            system.assertEquals(returnType, GlUt_Constants.NOERROR);
        }  
       
    } 
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi AT-3412
    @date:        29-08-2018  
    @description: Test Method to validateConsumption  Second Reading  Reading Rejected
    *******************************************************************************/
    static testmethod void validateSecondReadingConsumption_positive(){            
        
        User objUser =[SELECT Id, Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        String returnType;
        String newRecordObject;
        
        SupplyPointRelationship__c objSPR = [SELECT Id, MainSupply__c FROM SupplyPointRelationship__c LIMIT 1];
        SupplyPointDevice__c objSPD = [SELECT Device__c
                                       FROM SupplyPointDevice__c
                                       WHERE SupplyPoint__c =: objSPR.MainSupply__c
                                       AND Active__c = true LIMIT 1]; 
        
        Device__c objDevice = [SELECT Id FROM Device__c WHERE Id =: objSPD.Device__c LIMIT 1]; 

        // Create New Reading Record
        Reading__c objNewReading = GlUt_FactoryData_Test.createReading(objDevice);
        objNewReading.ActualDeviceReading__c = '100';
        objNewReading.ReadingDate__c = system.today();
        objNewReading.Billed__c = true;
        objNewReading.BillableType__c = System.Label.CuAp_ReadingBillableTypeBillable;
        newRecordObject = JSON.serialize(objNewReading); 
        
        List<Reading__c>  lastReadingList = [SELECT Id, ActualDeviceReading__c, ReadingDate__c FROM Reading__c where Device__c =: objSPD.Device__c and ReadingDate__c <: system.today() LIMIT 1];      
        String lastReading = JSON.serialize(lastReadingList[0]);  
        System.runAs(objUser){
            Test.startTest();
            returnType = GlAp_NewRecordWithAmendmentCtrlr.validateConsumptionThreshold(GlUt_APIConstantsReading.READINGAPINAME , objDevice.id , newRecordObject, lastReading); 
            readingUpload__c readingUploadObj = [SELECT Id , ReadingStatus__c FROM readingUpload__c WHERE DeviceReference__c =: objDevice.Id LIMIT 1];
            Test.stopTest(); 
            system.assertEquals(readingUploadObj.ReadingStatus__c, GlUt_Constants.ERROR);
            system.assertEquals(returnType, GlUt_Constants.READINGREJECTED);
        }  
    } 
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi AT-3412
    @date:        29-08-2018  
    @description: Test Method to validateConsumption  Second Reading
    *******************************************************************************/
    static testmethod void validateSecondReadingConsumption1_positive(){            
        
        User objUser =[SELECT Id, Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        String returnType;
        String newRecordObject;
        
        SupplyPointRelationship__c objSPR = [SELECT Id, MainSupply__c FROM SupplyPointRelationship__c LIMIT 1];
        SupplyPointDevice__c objSPD = [SELECT Device__c
                                       FROM SupplyPointDevice__c
                                       WHERE SupplyPoint__c =: objSPR.MainSupply__c
                                       AND Active__c = true LIMIT 1]; 
        
        Device__c objDevice = [SELECT Id FROM Device__c WHERE Id =: objSPD.Device__c LIMIT 1]; 

        // Create New Reading Record
        Reading__c objNewReading = GlUt_FactoryData_Test.createReading(objDevice);
        objNewReading.ActualDeviceReading__c = '416';
        objNewReading.ReadingDate__c = system.today();
        objNewReading.Billed__c = true;
        objNewReading.BillableType__c = System.Label.CuAp_ReadingBillableTypeBillable;
        newRecordObject = JSON.serialize(objNewReading);  
        
        List<Reading__c>  lastReadingList = [SELECT Id, ActualDeviceReading__c, ReadingDate__c FROM Reading__c where Device__c =: objSPD.Device__c and ReadingDate__c <: system.today() LIMIT 1];      
        String lastReading = JSON.serialize(lastReadingList[0]);  
        
        System.runAs(objUser){
            Test.startTest();
            returnType = GlAp_NewRecordWithAmendmentCtrlr.validateConsumptionThreshold(GlUt_APIConstantsReading.READINGAPINAME , objDevice.id , newRecordObject, lastReading); 
            Test.stopTest(); 
            system.assertEquals(returnType, GlUt_Constants.NOERROR);
        }  
       
    } 
    
    /******************************************************************************
    @author:      Echo: Vivek Sethi AT-3412
    @date:        29-08-2018  
    @description: Test Method to validateConsumption  Second Reading
    *******************************************************************************/
    static testmethod void validateSecondReadingConsumptionTripped_positive(){            
        
        User objUser =[SELECT Id, Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        
        String returnType;
        String newRecordObject;
        
        SupplyPointRelationship__c objSPR = [SELECT Id, MainSupply__c FROM SupplyPointRelationship__c LIMIT 1];
        SupplyPointDevice__c objSPD = [SELECT Device__c
                                       FROM SupplyPointDevice__c
                                       WHERE SupplyPoint__c =: objSPR.MainSupply__c
                                       AND Active__c = true LIMIT 1]; 
        
        Device__c objDevice = [SELECT Id FROM Device__c WHERE Id =: objSPD.Device__c LIMIT 1]; 

        // Create New Reading Record
        Reading__c objNewReading = GlUt_FactoryData_Test.createReading(objDevice);
        objNewReading.ActualDeviceReading__c = '416';
        objNewReading.ReadingDate__c = system.today();
        objNewReading.Billed__c = true;
        objNewReading.Tripped__c = true;
        objNewReading.BillableType__c = System.Label.CuAp_ReadingBillableTypeBillable;
        newRecordObject = JSON.serialize(objNewReading);  
        
        List<Reading__c>  lastReadingList = [SELECT Id, ActualDeviceReading__c, ReadingDate__c FROM Reading__c where Device__c =: objSPD.Device__c and ReadingDate__c <: system.today() LIMIT 1];      
        String lastReading = JSON.serialize(lastReadingList[0]);  
        
        System.runAs(objUser){
            Test.startTest();
            returnType = GlAp_NewRecordWithAmendmentCtrlr.validateConsumptionThreshold(GlUt_APIConstantsReading.READINGAPINAME , objDevice.id , newRecordObject, lastReading); 
            Test.stopTest(); 
            system.assertEquals(returnType, GlUt_Constants.READINGREJECTEDUPPER);
        }  
       
    } 
    
}