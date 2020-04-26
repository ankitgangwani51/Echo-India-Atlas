/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        31-10-2017
@description: Test Class for GlUt_SupplyPointDeviceServiceHandler
Revision(s):  
*******************************************************************************/
@isTest
Public Class GlUt_SPDeviceServiceHandler_Test{
    
    //Variable declaration start
    private static string DEVICETYPENAME = 'Test Device Type';
    private static string DEVICENAME = 'Test Device';
    private static string ZIPCODE = 'EC2R 6AB';
    private static string LOCSUBTYPE = 'Flat';
    private static string MEASUREDVAL = 'Yes';
    private static string SERVTYPENAME = 'Water';
    private static string SERVTYPENAMEELEC = 'Electricity';
    private static string SERVTYPENAMESEW = 'Sewerage';
    private static String PROFILENAME = 'System Administrator';
    private static String USERNAME = 'TestUser';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String MEASURED = 'Monthly';
    //Variable declaration end
    
    /*******************************************************************
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/    
    @TestSetup
    Static void createTestData(){  

        User objUser = GlUt_FactoryData_Test.createUser(PROFILENAME,USERNAME,null);
        Database.insert(objUser);
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Type Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        Device__c devObj = GlUt_FactoryData_Test.CreateDevice(DEVICENAME,objDeviceType);
        Database.insert(devObj);
        
        Location__c locObj = GlUt_FactoryData_Test.CreateLocation(ZIPCODE);
        locObj.LocationSubType__c = LOCSUBTYPE;
        Database.insert(locObj);

        //Insert Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        SupplyPoint__c supPointObj = GlUt_FactoryData_Test.CreateSupplyPoint(locObj, objSupplyPointUsageType);
        supPointObj.Measured__c = True; // AT-3174 
   
        Database.insert(supPointObj);
        
        SupplyPointDevice__c supPointDevObj = GlUt_FactoryData_Test.CreateSupplyPointDevices (devObj,supPointObj);
        Database.insert(supPointDevObj);
        
        List<ServiceType__c> servTypeList = new List<ServiceType__c>();
        ServiceType__c servType1 = GlUt_FactoryData_Test.CreateServiceType(SERVTYPENAME);
        servTypeList.add(servType1);
        ServiceType__c servType2 = GlUt_FactoryData_Test.CreateServiceType(SERVTYPENAMEELEC);
        servTypeList.add(servType2);
        ServiceType__c servType3 = GlUt_FactoryData_Test.CreateServiceType(SERVTYPENAMESEW);
        servTypeList.add(servType3);        
        Database.insert(servTypeList);
    }
    
    /*******************************************************************
    Purpose: Test bulk insert for Supply Point Device Service
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void insertspDevService_Bulk(){
        User dummyUser = [select id,name from user where isActive=true limit 1];
        SupplyPointDevice__c spDevObj = [Select id from SupplyPointDevice__c limit 1];
        ServiceType__c servTypeObj = [Select id from ServiceType__c where Name =: SERVTYPENAME limit 1];
        List<SupplyPointDeviceService__c> lstSPDeviceSer = new List<SupplyPointDeviceService__c>();
        List<ServiceType__c> lstServType = new List<ServiceType__c>();
        List<SupplyPointDeviceService__c> lstSPDeviceSerNew = new List<SupplyPointDeviceService__c>();
        System.runAs(dummyUser){
            Test.startTest();
            for(integer i =0; i < 200; i++){
                ServiceType__c servType = GlUt_FactoryData_Test.CreateServiceType(SERVTYPENAME+i);
                lstServType.add(servType);
            }
            Database.insert(lstServType);
            for(integer i =0; i < 200; i++){
                SupplyPointDeviceService__c spObj = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(spDevObj,lstServType[i]);
                lstSPDeviceSerNew.add(spObj);
            }
            Database.insert(lstSPDeviceSerNew);
            Test.stopTest();
            System.assertEquals(lstSPDeviceSerNew.size(),200);
        }       
    }
    /*******************************************************************
    Purpose: Test bulk update for Supply Point Device Service
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void updatespDevService_Bulk(){
        User dummyUser = [select id,name from user where isActive=true limit 1];
        SupplyPointDevice__c spDevObj = [Select id from SupplyPointDevice__c limit 1];
        ServiceType__c servTypeObj = [Select id from ServiceType__c where Name =: SERVTYPENAME limit 1];
        List<SupplyPointDeviceService__c> lstSPDeviceSer = new List<SupplyPointDeviceService__c>();
        List<ServiceType__c> lstServType = new List<ServiceType__c>();
        List<SupplyPointDeviceService__c> lstSPDeviceSerNew = new List<SupplyPointDeviceService__c>();
        for(integer i =0; i < 200; i++){
            ServiceType__c servType = GlUt_FactoryData_Test.CreateServiceType(SERVTYPENAME+i);
            lstServType.add(servType);
        }
        System.runAs(dummyUser){
            Test.startTest();
            Database.insert(lstServType);
            for(integer i =0; i < 200; i++){
                SupplyPointDeviceService__c spObj = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(spDevObj,lstServType[i]);
                lstSPDeviceSerNew.add(spObj);
            }
            Database.insert(lstSPDeviceSerNew);
            System.assertEquals(lstSPDeviceSerNew.size(),200);
            Test.stopTest();
        }       
    }
    /*******************************************************************
    Purpose: To test positive scenario of allowing one active device per 
             supply point for a service on insert event
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void insertSPDeviceServiceInsert_Positive(){
        User dummyUser =[select id,name from user where isActive=true limit 1];
        SupplyPointDevice__c spDevObj = [Select id from SupplyPointDevice__c limit 1];
        ServiceType__c servTypeObj = [Select id from ServiceType__c where Name =: SERVTYPENAME limit 1];
        SupplyPointDeviceService__c spDevSer = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(spDevObj,servTypeObj);
        ServiceType__c servTypeElec = [Select id from ServiceType__c where Name =: SERVTYPENAMEELEC limit 1];
        System.runAs(dummyUser){
            Test.startTest();
            Database.insert(spDevSer);
            SupplyPointDeviceService__c spDevSerNew = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(spDevObj,servTypeElec);
            Database.insert(spDevSerNew);
            Test.stopTest();
            System.assert(spDevSer.id != null);
            System.assert(spDevSerNew.id != null);
        }       
    }
    /*******************************************************************
    Purpose: To test negative scenario of allowing one active device per 
             supply point for a service on insert event
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void insertSPDeviceServiceInsert_Negative(){
        User dummyUser =[select id,name from user where isActive=true limit 1];
        SupplyPointDevice__c spDevObj = [Select id,InstallationDate__c,RemovalDate__c,Active__c from SupplyPointDevice__c limit 1];
        ServiceType__c servTypeObj = [Select id from ServiceType__c limit 1];
        SupplyPointDeviceService__c spDevSer = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(spDevObj,servTypeObj);
        Database.insert(spDevSer);
        
        System.debug('@@@spDevObj1'+spDevObj.InstallationDate__c);
        System.debug('@@@spDevObj2'+spDevObj.RemovalDate__c);
        System.debug('@@@spDevObj3'+spDevObj.Active__c);
        SupplyPointDeviceService__c spDevSerNew = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(spDevObj,servTypeObj);
        System.runAs(dummyUser){
            Test.startTest();
            Database.SaveResult SR = Database.insert(spDevSerNew,false);
            Test.stopTest();
            for(Database.Error err : SR.getErrors()){
                System.AssertEquals(System.Label.CuAp_SPDeviceServiceError, err.getMessage());
            }
        }               
    }
    /*******************************************************************
    Purpose: To test negative scenario of allowing one active device per 
             supply point for a service on update event
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void insertSPDeviceServiceUpdate_Negative(){
        User dummyUser =[select id,name from user where isActive=true limit 1];
        SupplyPointDevice__c spDevObj = [Select id from SupplyPointDevice__c limit 1];
        ServiceType__c servTypeObj = [Select id from ServiceType__c limit 1];
        SupplyPointDeviceService__c spDevSer = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(spDevObj,servTypeObj);
        ServiceType__c servTypeElec = [Select id from ServiceType__c where Name =: SERVTYPENAMEELEC limit 1];
        System.runAs(dummyUser){
            Test.startTest();
            Database.insert(spDevSer);
            System.assert(spDevSer.id != null);
            SupplyPointDeviceService__c spDevSerNew = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(spDevObj,servTypeElec);
            Database.insert(spDevSerNew);
            System.assert(spDevSerNew.id != null);
            spDevSerNew.ServiceType__c = servTypeObj.id;
            Database.SaveResult SR = Database.update(spDevSerNew,false);
            Test.stopTest();
            for(Database.Error err : SR.getErrors()){
                System.AssertEquals(System.Label.CuAp_SPDeviceServiceError, err.getMessage());
            }
        }       
    }
    /*******************************************************************
    Purpose: To test positive scenario of allowing one active device per 
             supply point for a service on update event
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void insertSPDeviceServiceUpdate_Positive(){
        User dummyUser =[select id,name from user where isActive=true limit 1];
        SupplyPointDevice__c spDevObj = [Select id from SupplyPointDevice__c limit 1];
        ServiceType__c servTypeObj = [Select id from ServiceType__c limit 1];
        SupplyPointDeviceService__c spDevSer = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(spDevObj,servTypeObj);
        ServiceType__c servTypeElec = [Select id from ServiceType__c where Name =: SERVTYPENAMEELEC limit 1];
        ServiceType__c servTypeSew = [Select id from ServiceType__c where Name =: SERVTYPENAMEELEC limit 1];
        System.runAs(dummyUser){
            Test.startTest();
            Database.insert(spDevSer);
            SupplyPointDeviceService__c spDevSerNew = GlUt_FactoryData_Test.CreateSupplyPointDeviceService(spDevObj,servTypeElec);
            Database.insert(spDevSerNew);
            spDevSerNew.ServiceType__c = servTypeSew.id;
            Database.update(spDevSerNew);
            Test.stopTest();
            System.assert(spDevSer.id != null);
            System.assert(spDevSerNew.id != null);
        }       
    }
}