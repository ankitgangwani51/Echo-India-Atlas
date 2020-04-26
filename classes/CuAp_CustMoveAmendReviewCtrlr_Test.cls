/******************************************************************************
@author:     Swati Mathur
@date:       21-Sep 2018
@description: Test Class for CuAp_CustMoveAmendReviewCtrlr
@Revisions	  AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/

    @isTest
    Public Class CuAp_CustMoveAmendReviewCtrlr_Test{
        
        //Variable declaration start
        
        private static String PROFILENAME = 'System Administrator';
        private static String USERNAME = 'TestUser222';
        private static String ACCOUNTNAME = 'TestAccount';
        private static String LOCATIONNAME ='A99 9AA';
        private static String LOCATIONSUBTYPE = 'Detached';
        private static String STREET = 'teststreet';
        private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
        private static final String DEVICE_SIZE = 'TestDeviceSize';
        private static final String MANUFACTURER = 'Siemens';
        private static final String UNIT_OF_MEASURE = 'Metric';
        private static String DEVICE_TYPE ='TestDeviceType';
        private static String DEVICE_NAME = 'TestDevice'; 
        
        //Variable declaration end

    /******************************************************************************
    @author:     Swati Mathur
    @date:       21-Sep 2018
    @description: Test data setup method
    *******************************************************************************/
        @TestSetup
        static void createTestData(){
            //Create user record
            User objUser = GlUt_FactoryData_Test.createUser(PROFILENAME,USERNAME,null);
            Database.insert(objUser); 

            //Create account record
            Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNTNAME);
            Database.insert(objAccount);
            
            //Create location record        
            Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATIONNAME);
            objLocation.LocationSubType__c=LOCATIONSUBTYPE ; 
            objLocation.Street__c =STREET ;
            Database.insert(objLocation);
            
            //Create location occupant record       
            LocationOccupant__c locOccObj1 = GlUt_FactoryData_Test.createLocationOccupant(objAccount,objLocation);
            locOccObj1.StartDate__c = system.today()-1;
            locOccObj1.EndDate__c = system.today()+1;
            Database.insert(locOccObj1);
            
            // Create Device Size Record 
            DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
            Database.insert(objDeviceSize);
            
            // Create Device Type Record
            DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
            Database.insert(objDeviceType);
            
            // Create Device Record
            Device__c objDevice = GlUt_FactoryData_Test.CreateDevice(DEVICE_NAME ,objDeviceType );
            objDevice.Digit__c = 10;
            Database.insert(objDevice);            
            
            //Create reading record
            Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);            
            Database.insert(objReading);
            
            
        }
        
    /******************************************************************************
    @author:      Swati Mathur
    @date:        21-Sep 2018
    @description: Test method for retrieveReadingPropDetails() method
    *******************************************************************************/
        static testmethod void retrieveReadingPropDetails_Positive(){
            
            //Query user record created in test setup data method
            User objUser =[Select Id,Name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
            //Run test class in user context
            system.runas(objUser){
                
                Test.startTest();
                List<GLAp_FieldProps> lstFieldProp = CuAp_CustMoveAmendReviewCtrlr.retrieveReadingPropDetails();
                Test.stopTest();
                System.assertNotEquals(lstFieldProp.size(),0);               
            }
        }
   
    /******************************************************************************
    @author:      Swati Mathur
    @date:        21-Sep 2018
    @description: Test method for retrieveReadingPropDetails() method
    *******************************************************************************/
        static testmethod void retrieveReadingRecords_Positive(){
            
            //Query user record created in test setup data method
            User objUser =[Select Id,Name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
            List<Reading__c> readingsList =[Select Id,Name,Device__c from Reading__c];
            
            //Run test class in user context
            system.runas(objUser){
                Test.startTest();
                List<BlAp_CombinedRecord> records = CuAp_CustMoveAmendReviewCtrlr.retrieveReadingRecords(readingsList);
                Test.stopTest();
                System.assert(!records.isEmpty());
            }
        } 
    /******************************************************************************
    @author:      Swati Mathur
    @date:        21-Sep 2018
    @description: Test method for retrieveReadingRecords() method
    *******************************************************************************/
        static testmethod void retrieveReadingRecords_Negative(){
            
            //Query user record created in test setup data method
            User objUser =[Select Id,Name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
            List<Reading__c> readingsList =[Select Id,Name from Reading__c];
            
            boolean isException = false;
            //Run test class in user context
            system.runas(objUser){
                try{
                    Test.startTest();
                    List<BlAp_CombinedRecord> records = CuAp_CustMoveAmendReviewCtrlr.retrieveReadingRecords(readingsList);
                    Test.stopTest();
                }
                catch(exception e){
                    isException = true;
                }
                System.assertEquals(isException,true);  
            }
        }        
    }