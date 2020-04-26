/******************************************************************************
@author:      Echo: Neha 
@date:        05-04-2018  
@description: Test Class for CuAp_ReadingEstimateCtrlr
*******************************************************************************/
@isTest
public class CuAp_ReadingEstimateCtrlr_Test {

    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String DEVICE_NAME = '123456789';
    private static final String ZIP_CODE = 'WS2 8DE';
    private static final String SPUT_NAME = 'SPUT Water';
    private static final Date READING_DATE = system.today();
    private static final Boolean MEASURED = true; //AT-3174
    private static final String READFREQUENCY ='Monthly';
    private static final Decimal ROLLING_ADU = 1.32;
        
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
        
        // Create Location Record 
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(ZIP_CODE);
        Database.insert(objLocation);
               
        // Create SupplyPointUsageType Record 
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SPUT_NAME);
        Database.insert(objSupplyPointUsageType);
        
        // Create SupplyPoint__c Record 
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = MEASURED;
        Database.insert(objSupplyPoint);
                        
        // Create Device Size Record 
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        // Create Device Record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);        
        Database.insert(objDevice);
             
        // Create SupplyPointDevice Record
        SupplyPointDevice__c objSupplyPointDevice = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice, objSupplyPoint);        
        Database.insert(objSupplyPointDevice);
        
        // Create last year Reading Record
        Reading__c objReading1 = GlUt_FactoryData_Test.createReading(objDevice);
        objReading1.ReadingDate__c = READING_DATE.addYears(-1); 
        objReading1.ReadingMethod__c = 'Actual';
        Database.insert(objReading1);
        
        AverageDailyUsage__c objAverageDailyUse1 = GlUt_FactoryData_Test.createAvgDailyUses(objSupplyPointDevice);    
        objAverageDailyUse1.StartDate__c = READING_DATE.addYears(-1);
        objAverageDailyUse1.Reading__c = objReading1.Id; 
        Database.insert(objAverageDailyUse1);        
        
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        objReading.ReadingDate__c = READING_DATE - 31;          
        Database.insert(objReading);
        
        // Create AverageDailyUse Record
        AverageDailyUsage__c objAverageDailyUse = GlUt_FactoryData_Test.createAvgDailyUses(objSupplyPointDevice);      
        objAverageDailyUse.EndDate__c = null; //READING_DATE + 20;  
        objAverageDailyUse.RollingDailyUsage__c = ROLLING_ADU; // AT-5370
        Database.insert(objAverageDailyUse); 
        
    }
        
    /******************************************************************************
	@author:      Echo: Neha
	@date:        05-04-2018  
	@description: Test Method 
	*******************************************************************************/
    static testmethod void createEstimatedReading_Positive(){  
        
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
      
        Device__c objDevice = [SELECT Id FROM Device__c LIMIT 1];
        
        Reading__c oldReading = [SELECT Id FROM Reading__c WHERE ReadingDate__c =: READING_DATE.addYears(-1) LIMIT 1];
        Database.delete(oldReading);
        
        System.runAs(objUser){
            Test.startTest(); 
            
        	Reading__c objReading = new Reading__c();
        	
        	objReading = CuAp_ReadingEstimateCtrlr.createEstimatedReading(objDevice.Id, String.valueOf(READING_DATE));
            
            Test.stopTest();          
            system.assert(objReading != null);
            system.debug('objReading.ReadingMethod__c' + objReading.ReadingMethod__c);
           // system.assert(objReading.ReadingMethod__c == Label.CuAp_ReadingReadingMethodSystemEstimated );
           
        } 
    }   
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        05-04-2018  
	@description: Test Method 
	*******************************************************************************/
    static testmethod void createEstimatedReading_Negative(){  
        
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
      
        Device__c objDevice = [SELECT Id FROM Device__c LIMIT 1];   
        
        Reading__c oldReading = [SELECT Id FROM Reading__c WHERE ReadingDate__c =: READING_DATE.addYears(-1) LIMIT 1];        
        Database.delete(oldReading);
        
        List<AverageDailyUsage__c> lstAverageDailyUse = [SELECT Id FROM AverageDailyUsage__c];
        Database.delete(lstAverageDailyUse);
       
        System.runAs(objUser){
            Test.startTest(); 
            
        	Reading__c objReading = new Reading__c();
        	
        	objReading = CuAp_ReadingEstimateCtrlr.createEstimatedReading(objDevice.Id, String.valueOf(READING_DATE));
          
            system.debug('objReading  ' + objReading);
            Test.stopTest(); 
            system.assert(objReading.ReadingMethod__c != Label.CuAp_ReadingReadingMethodSystemEstimated );
        } 
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        12-03-19  
	@description: Test Method 
	*******************************************************************************/
    static testmethod void createEstimatedReading_Positive2(){  
        
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
      
        Device__c objDevice = [SELECT Id FROM Device__c LIMIT 1];
        
        System.runAs(objUser){
            Test.startTest(); 
            
        	Reading__c objReading = new Reading__c();
        	
        	objReading = CuAp_ReadingEstimateCtrlr.createEstimatedReading(objDevice.Id, String.valueOf(READING_DATE));
            
            Test.stopTest();          
            system.assert(objReading != null);
            system.debug('objReading.ReadingMethod__c' + objReading.ReadingMethod__c);          
           
        } 
    }   
    
    
}