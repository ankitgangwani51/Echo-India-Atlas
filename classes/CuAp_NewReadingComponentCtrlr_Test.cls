/******************************************************************************
@author:      Echo: Neha R.
@date:        16-02-2018  
@description: Test Class for CuAp_NewReadingComponentCtrlr
@Revision     Added WizardObject - Dependra 17 Feb 2018
@Revisions	  	AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest
public class CuAp_NewReadingComponentCtrlr_Test {
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String DEVICE_SIZE = '22 mm';
    private static final String MANUFACTURER = 'Aqua';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String DEVICE_NAME = 'Meter';  
    private static final String NEW_DEVICE_SIZE = '20 mm';
    private static final String MANUFACTURER1 = 'Kent';    
    private static final String NEW_DEVICE_NAME = 'New Meter';
        
    /******************************************************************************
    @author:      Echo: Neha R.
    @date:        16-02-2018  
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
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);       
        Database.insert(objDeviceType);
        
        // Create Device Record            
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);   
        Database.insert(objDevice);
        
        // Create Reading Record 
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice); 
        objReading.BillableType__c = 'Billable';
        objReading.Billed__c = false;
        Database.insert(objReading); 
    }
    
    /******************************************************************************
    @author:      Echo: Neha R.
    @date:        16-02-2018  
    @description: Test Method to update and insert Reading in POSITIVE scenario
    *******************************************************************************/
    static testmethod void saveReadings_Positive()
    {            
        User objUser =[SELECT id,name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        boolean isException;
       
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(NEW_DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER1,UNIT_OF_MEASURE);       
        Database.insert(objDeviceType);
        
        // Create Device Record            
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(NEW_DEVICE_NAME, objDeviceType);   
        Database.insert(objDevice);        
        
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        
        list<Reading__c> ListReadings = [SELECT id FROM Reading__c];
        list<Reading__c> amendedReadings = new list<Reading__c>();
        
        for(Reading__c obj: ListReadings){        
            obj.BillableType__c = 'Non Billable';
            obj.Billed__c = true;
            amendedReadings.add(obj);
        }
        // Added wizard object - Dependra 
        
        CuAp_NewReadingComponentCtrlr.WizardObject objWizardObject = new CuAp_NewReadingComponentCtrlr.WizardObject();    
        objWizardObject.deviceId = objDevice.Id;
        objWizardObject.newReading = objReading;
        objWizardObject.amendReadings = amendedReadings;
        String jsonStr = JSON.serialize(objWizardObject);
        System.runAs(objUser){
            try{                
                Test.startTest();
                Id readingId = CuAp_NewReadingComponentCtrlr.saveReadings(jsonStr);  
                Test.stopTest();
                System.assert(readingId != null);
                
            }catch(exception e){
                isException = true;            
            }
        }
        
    /*    for(Reading__c obj: ListReadings){
            system.assert(obj.BillableType__c == 'Non Billable');           
        }*/
        
    }
    /******************************************************************************
    @author:      Echo: Neha R.
    @date:        01-02-2018  
    @description: Test Method to update and insert Reading in Negative scenario 
    *******************************************************************************/
    static testmethod void saveReadings_Negative_NUll()
    {            
        User objUser =[SELECT id,name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
        boolean isException;
        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(NEW_DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER1,UNIT_OF_MEASURE);       
        Database.insert(objDeviceType);
        
        // Create Device Record            
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(NEW_DEVICE_NAME, objDeviceType);   
        Database.insert(objDevice);          
        Reading__c objReading = [Select Id, Name from Reading__c LIMIT 1];
        
        /*list<Reading__c> ListReadings = [SELECT id FROM Reading__c];
        
        list<Reading__c> amendedReadings = new list<Reading__c>();
        
        for(Reading__c obj: ListReadings){        
            obj.BillableType__c = 'Non Billable';
            obj.Billed__c = true;
            amendedReadings.add(obj);
        }*/
        CuAp_NewReadingComponentCtrlr.WizardObject objWizardObject = new CuAp_NewReadingComponentCtrlr.WizardObject();    
        objWizardObject.deviceId = objDevice.Id;
        objWizardObject.newReading = objReading;
        //objWizardObject.amendReadings = amendedReadings;
        String jsonStr = JSON.serialize(objWizardObject);
        
        System.runAs(objUser){
            try{                
                Test.startTest();
                CuAp_NewReadingComponentCtrlr.saveReadings(jsonStr);  
                Test.stopTest();
                
            }catch(exception e){
                isException = true;            
            }
        }
      system.assert(isException == true);
    }
}