/******************************************************************************
@author:      Echo: Swati
@date:        07-12-2017  
@description: Test Class for LoAp_SelectLocationDevicePageCtrlr
@revision:    08-Mar-2018 MT - Use the field from constant class
@Revisions	  AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/

@isTest
public class LoAp_SelectLocationDevicePageCtrlr_Test {

    //Variable declaration start    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='FN123LN123'; 
    private static final String USER_FNAME= 'FN123';
    private static final String USER_LNAME= 'LN123';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static String TEST_SERVICE_TYPE_1 ='TestServiceType1';
    private static String TEST_SERVICE_TYPE_2 ='TestServiceType2';
    private static String LOCATION_NAME ='A99 9AA';   
    private static String LOCATION_SUB_TYPE = 'Detached';
    private static String STREET = 'teststreet';
    private static String DEVICE_TYPE_NAME ='Meter';
    private static String DEVICE_NAME ='123456789';
    private static String YES ='yes';
    private static String NULLVALUE = '';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static String SOQLINJECTIONTEST = 'abc%\' OR ' + GlUt_APIConstantsLocation.POSTALCODEAPINAME + ' LIKE \'% ';
    
    //private static String TRUE ='true';
    private static String MEASURED = 'Monthly';
     
    
    //Variable declaration end

/******************************************************************************
@author:    Echo: Swati
@date:      07-12-2017  
@description: Test data setup method
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
        
        ServiceType__c objServiceType1 = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE_1 );
        Database.insert(objServiceType1);
        
        ServiceType__c objServiceType2 = GlUt_FactoryData_Test.CreateServiceType(TEST_SERVICE_TYPE_2 );
        Database.insert(objServiceType2);

        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        Device__c  objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICE_NAME, objDeviceType);        
        Database.insert(objDevice);      
        
        SupplyPointDevice__c  objSupplyPointDevice = GlUt_FactoryData_Test.CreateSupplyPointDevices(objDevice, objSupplyPoint);        
        Database.insert(objSupplyPointDevice);        
        
        SupplyPointDeviceService__c  objSupplyPointDeviceService1 = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(objSupplyPointDevice, objServiceType1);        
        Database.insert(objSupplyPointDeviceService1);
        
        SupplyPointDeviceService__c  objSupplyPointDeviceService2 = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(objSupplyPointDevice, objServiceType2);        
        Database.insert(objSupplyPointDeviceService2);
            
    }
    
/******************************************************************************
@author:    Echo: Swati
@date:      07-12-2017  
@description: Test method for getInfoToDisplay() method
*******************************************************************************/
    
    static testmethod void getInfoToDisplay_Positive(){ 
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        
        List<Location__c> objLocId = [SELECT Id FROM Location__c];  
        Id LocationId = objLocId[0].id;
        
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            LoAp_SelectLocationDevicePageCtrlr.ContainerWrapper displayRec = LoAp_SelectLocationDevicePageCtrlr.getInfoToDisplay(LocationId); 
            Test.stopTest();
            
            System.assert(displayRec != null);  
        }
    }        
        
/******************************************************************************
@author:    Echo: Swati
@date:      07-12-2017  
@description: Test method for getLocationDeviceFieldProps() method
*******************************************************************************/
    
    static testmethod void getLocationDeviceFieldProps_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
                
        List<Location__c> objLocId = [SELECT Id FROM Location__c];  
        Id LocationId = objLocId[0].id;
        
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            List<GLAp_FieldProps> lstFieldProps = LoAp_SelectLocationDevicePageCtrlr.getLocationDeviceFieldProps();            
            Test.stopTest();
            
            System.assertEquals(lstFieldProps.size(), 4);                     
        }
    }   
   
/******************************************************************************
@author:    Echo: Swati
@date:      07-12-2017  
@description: Test method for getLocationDetails() method
*******************************************************************************/
    
    static testmethod void getLocationDetails_Positive(){ 
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
                
        List<Location__c> objLocId = [SELECT Id FROM Location__c];  
        String LocationId = objLocId[0].id;
        
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            Location__c  foundLoc = LoAp_SelectLocationDevicePageCtrlr.getLocationDetails(LocationId);
            Test.stopTest();
            
            System.assertNotEquals(foundLoc.Address__c, null);
            
        }
    }    
    
   
/******************************************************************************
@author:    Echo: Swati
@date:      07-12-2017  
@description: Test method for getLocationDevices() method
*******************************************************************************/
    
    static testmethod void getLocationDevices_Positive(){ 
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
                
        List<Location__c> objLocId = [SELECT Id FROM Location__c];  
        String LocationId = objLocId[0].id;
        
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            List<BlAp_CombinedRecord> displayRec = LoAp_SelectLocationDevicePageCtrlr.getLocationDevices(LocationId); 
            Test.stopTest();
            
            System.assertNotEquals(displayRec, null);
        }
    } 
    
/******************************************************************************
@author:    Echo: Swati
@date:      07-12-2017  
@description: Test method for getLocationDevices() method
*******************************************************************************/
    
    static testmethod void getLocationDevices_Negative(){ 
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        Location__c objLocId = new Location__c();
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            List<BlAp_CombinedRecord> displayRec = LoAp_SelectLocationDevicePageCtrlr.getLocationDevices(objUser.Id); 
            Test.stopTest();
            
            System.assertEquals(displayRec.isEmpty(),true);
        }
    } 
    
    /******************************************************************************
@author:    Echo: Swati
@date:      07-12-2017  
@description: Test method for getLocationDevices() method
*******************************************************************************/
    
    static testmethod void retrieveLocationFields_testmethod(){ 
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        
        List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
        //Run test class in user context
            try{
             System.runAs(objUser){ 
                
                Test.startTest();
                twoColFormattedList = LoAp_SelectLocationDevicePageCtrlr.retrieveLocationFields(); 
                Test.stopTest();
                System.assert(twoColFormattedList.size() > 0);
                system.debug('twoColFormattedList ' + twoColFormattedList);
            }
        }
        catch(Exception e){
        }
       
    } 
  }