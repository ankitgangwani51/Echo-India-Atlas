/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        25 September 2017
@description: Test Class for GlUt_FieldSecurity
Revision(s):  10-Oct-2017 - Shivangi Gaur - Test.startTest() and Test.stopTest() 
                                            added in all test methods.
              20-Dec-2017 - Shivangi Gaur - Incorporated review comments on AT-455
                                            dated 19-12-2017.  
              MT 07-Mar-2018 Use the field from constant class
*******************************************************************************/

@isTest
Public Class GlUt_FieldSecurity_Test{
    
    //Variable declaration start
    
    private static String PROFILENAME = 'System Administrator';
    private static String PROFILENAMECUSTOM = 'Standard User'; // Client Agent
    private static String USERNAME = 'TestUser';
    private static String USERNAMECUSTOM = 'TestUser101';
    private static String ACCNAME = 'TestAccount';
    private static String NAMEFIELD = 'Name';
    private static String TYPEFIELD = 'Type';
    private static String BIRTHDATE = GlUt_APIConstantsAccount.BIRTHDATEAPINAME ;
    private static String FIRSTNAME = 'FIRSTNAME';
    private static String LASTNAME = 'LASTNAME';
    private static String DONOTCALL = 'DONOTCALL';
    private static String CONFIRSTNAME = 'Test';
    private static String CONLASTNAME = 'Contact 101';
    private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    private static String USERNAMECOMPLETECUSTOM = USERNAMECUSTOM+ '@unitest.com';
    private static String DEVICENAME = 'TestDevice';
    private static String DEVICETYPE ='TestDeviceType';
    private static String SUBDEVICETYPE ='TestSubDevice';
    private static String TESTSERVICETYPE ='TestServiceType';
    private static String LOCATIONNAME ='A99 9AA';
    private static String LOCATIONSUBTYPE = 'Detached';
    private static String STREET = 'teststreet';
    private static String YES ='yes';
    private static String MEASURED = 'Monthly';
    private static String WHOLESALER ='TestWholesaler';
    private static String AVAILABLESERVICES ='TestAvailableService';
    private static String SERVICEITEMFAMILY ='TestServiceItemFamily';
    private static String SERVICEITEMTYPE ='TestServiceitemtype';
    private static String BUNDLE ='TestBundle';
    private static String AVAILABLEBUNDLE ='TestAvailableBundle';
    private static String BUNDLEITEM ='TestBundleItem';
    private static String AVAILABLESERVIEITEM='TestAvailableServiceItem';
    private static string WHOLESALEAMTFIELD = GlUt_APIConstantsAgreedRate.WHOLESALEAMOUNTAPINAME;
    private static string AGREEDRATEOBJ = GlUt_APIConstantsAgreedRate.AGREEDRATEAPINAME;
    private static string AGREEDRATENAME = 'Test Rate';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
   
    //Variable declaration end

/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        25 September 2017
@description: Test data setup method
*******************************************************************************/    
    @TestSetup
    static void createTestData(){
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(PROFILENAME,USERNAME,null);
        Database.insert(objUser); 

        //Create user record with custom profile
        User objUserCustom = GlUt_FactoryData_Test.createUser(PROFILENAMECUSTOM,USERNAMECUSTOM,null);
        Database.insert(objUserCustom);

        //Create account record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCNAME);
        Database.insert(objAccount);
        
        //Create contact record
        Contact objCon = GlUt_FactoryData_Test.createContact(CONFIRSTNAME,CONLASTNAME);
        Database.insert(objCon);
        
         //Create contract record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(' ',objAccount);
        Database.insert(objContract); 
        
        // Create Device Size Record - Ankit Gangwani, 14 Feb 2018
        DeviceSize__c objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        // Create Device Size Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize,MANUFACTURER,UNIT_OF_MEASURE);
        Database.insert(objDeviceType);
        
        //Create device record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICENAME ,objDeviceType );
        Database.insert(objDevice);
        
        //Create reading record
        Reading__c  objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading);
        
        //Create service type record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(TESTSERVICETYPE );
        Database.insert(objServiceType);
        
        //Create location record        
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATIONNAME);
        objLocation.LocationSubType__c=LOCATIONSUBTYPE ; 
        objLocation.Street__c =STREET ;
        Database.insert(objLocation);

        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Create supply point record
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174
   
        Database.insert(objSupplyPoint);
        
        //Create division record
        Division__c  objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        //Create wholesaler record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        //Create available service record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
                
        //Create service record
        Service__c  objService = GlUt_FactoryData_Test.createService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService); 
        
        //Create service item family record
        ServiceItemFamily__c  objServiceItemFamily = GlUt_FactoryData_Test.createServiceItemFamily(SERVICEITEMFAMILY,objServiceType);
        Database.insert(objServiceItemFamily);
        
        //Create service item type record
        ServiceItemType__c  objServiceItemType = GlUt_FactoryData_Test.createServiceItemType(SERVICEITEMTYPE,objServiceItemFamily,objDivision,objDeviceType,objWholesaler);
        Database.insert(objServiceItemType);
        
        //Create bundle record
        Bundle__c objBundle = GlUt_FactoryData_Test.createBundle(BUNDLE,objServiceType);
        Database.insert(objBundle);
        
        //Create available bundle record
        AvailableBundle__c  objAvailableBundle = GlUt_FactoryData_Test.createAvailableBundle(AVAILABLEBUNDLE,objBundle,objAvailableService);
        Database.insert(objAvailableBundle);
        
        //Create bundle item record
        BundleItem__c  objBundleItem = GlUt_FactoryData_Test.createBundleItem(BUNDLEITEM,objBundle,objServiceItemType,objServiceItemFamily);
        Database.insert(objBundleItem);
        
        //Create available service item record
        AvailableServiceItem__c  objAvailableServiceItem = GlUt_FactoryData_Test.createAvailableServiceItem(AVAILABLESERVIEITEM,objBundleItem,objServiceItemType,objAvailableBundle);
        Database.insert(objAvailableServiceItem); 
        
        //Create service item record
        ServiceItem__c  objServiceItem = GlUt_FactoryData_Test.createServiceItem(objAvailableServiceItem,objServiceItemType,objService);
        objServiceItem.StartDate__c = Date.newInstance(2016, 12, 9);
        objServiceItem.EndDate__c = Date.newInstance(2019, 12, 9);
        Database.insert(objServiceItem);
        
        //Create agreed rate record
        AgreedRate__c objAgreedRate = GlUt_FactoryData_Test.createAgreedRate(AGREEDRATENAME,objServiceItem);
        objAgreedRate.WholesaleAmount__c = 12345;
        Database.insert(objAgreedRate); 
    }
   
/******************************************************************************
@author:      Shivangi Gaur
@date:        25 September 2017
@description: Test method for getFieldPropertiesObject() method
*******************************************************************************/
    static testmethod void fieldPropertiesObject_Positive(){
        
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive=true and USERNAME =: USERNAMECOMPLETE limit 1];
        List<String> fieldList = new List<String>{NAMEFIELD,TYPEFIELD, BIRTHDATE};
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            List<GlAp_FieldProps> lstFieldProp = GlUt_FieldSecurity.getFieldPropertiesObject(GlUt_Constants.OBJACCOUNT,fieldList);
            Test.stopTest();
            
            System.assert(lstFieldProp.size()>0);
        }
    }
/******************************************************************************
@author:      Shivangi Gaur
@date:        05 December 2017
@description: Test method for getFieldPropertiesObject() method
*******************************************************************************/
    static testmethod void fieldPropertiesObject_Negative(){
        
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive=true and Profile.Name =: PROFILENAMECUSTOM and USERNAME =: USERNAMECOMPLETECUSTOM limit 1];
        List<String> fieldList = new List<String>{WHOLESALEAMTFIELD};
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            List<GlAp_FieldProps> lstFieldProp = GlUt_FieldSecurity.getFieldPropertiesObject(AGREEDRATEOBJ,fieldList);
            Test.stopTest();
            
            System.assertEquals(lstFieldProp.size(),0);
        }
    }

/******************************************************************************
@author:      Shivangi Gaur
@date:        26 September 2017
@description: Test method for cleanseFields() and checkFields() methods
*******************************************************************************/
    static testmethod void cleanseFields_Positive(){
        
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive=true and USERNAME =: USERNAMECOMPLETE limit 1];
        List<String> fieldList = new List<String>{NAMEFIELD,TYPEFIELD, BIRTHDATE};
        List<Account> objList = [Select id,Name,Type,DateofBirth__c from Account limit 1];        
        List<BillingContract__c> objListContract = [Select id,AccountName__r.Name from BillingContract__c limit 1]; 
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            //List<Account> accListFields = GlUt_FieldSecurity.cleanseFields(objList,fieldList,false);
            List<Account> accListFields = GlUt_FieldSecurity.cleanseFields(objList,false);
            List<Account> accListFieldsNew = GlUt_FieldSecurity.cleanseFields(objList,true);
            List<BillingContract__c> accListFieldsNew1 = GlUt_FieldSecurity.cleanseFields(objListContract,true); 
            Test.stopTest();
            
            System.assert(accListFields.size()>0);
            System.assert(accListFieldsNew.size()>0);
             System.assert(accListFieldsNew1.size()>0); 
        }
    }
/******************************************************************************
@author:      Shivangi Gaur
@date:        26 September 2017
@description: Test method for cleanseFields() and checkFields() methods with custom PROFILENAME
              to check for read only fields accessibility
*******************************************************************************/
    static testmethod void cleanseFieldsCustomProfile_Positive(){
        
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive=true and Profile.Name =: PROFILENAMECUSTOM and USERNAME =: USERNAMECOMPLETECUSTOM limit 1];
                
        List<String> fieldList = new List<String>{FIRSTNAME,LASTNAME,DONOTCALL};
        List<Contact> objListContact = [Select id,FIRSTNAME,LASTNAME,DONOTCALL from Contact limit 1];
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            //List<Contact> accListFields = GlUt_FieldSecurity.cleanseFields(objListContact,fieldList,true);
            List<Contact> accListFields = GlUt_FieldSecurity.cleanseFields(objListContact,true);
            List<Contact> accListFieldsNew = GlUt_FieldSecurity.cleanseFields(objListContact,true);
            Test.stopTest();
            
            System.assert(accListFields.size()>0);
            System.assert(accListFieldsNew.size()>0);
        }
    }
/******************************************************************************
@author:      Shivangi Gaur
@date:        26 September 2017
@description: Test method for cleanseFields() and checkFields() methods with custom profile
              for negative scenario when isRead is false.
*******************************************************************************/
    static testmethod void cleanseFieldsCustomProfile_Negative(){
        
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive=true and Profile.Name =: PROFILENAMECUSTOM and USERNAME =: USERNAMECOMPLETECUSTOM limit 1];
        
        List<String> fieldList = new List<String>{WHOLESALEAMTFIELD};
        List<AgreedRate__c> objListContact = [Select id,WholesaleAmount__c from AgreedRate__c limit 1];
        
        List<String> fieldListNew = new List<String>{FIRSTNAME,LASTNAME,DONOTCALL};
        List<Contact> objListContactNew = [Select id,DONOTCALL from Contact limit 1];
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            //List<AgreedRate__c> accListFields = GlUt_FieldSecurity.cleanseFields(objListContact,fieldList,false);
            List<AgreedRate__c> accListFields = GlUt_FieldSecurity.cleanseFields(objListContact,false);
            List<AgreedRate__c> accListFieldsNew = GlUt_FieldSecurity.cleanseFields(objListContact,false);
            Test.stopTest();
            
            //Asserts to check not accessible fields are removed from object map
            
            boolean fieldExists = accListFields[0].getSobjectType().getDescribe().fields.getMap().keySet().contains(WHOLESALEAMTFIELD);
            System.assertEquals(fieldExists,false);
            
            boolean fieldExistsNew = accListFieldsNew[0].getSobjectType().getDescribe().fields.getMap().keySet().contains(WHOLESALEAMTFIELD);
            System.assertEquals(fieldExistsNew,false);
        }
    }
/******************************************************************************
@author:      Shivangi Gaur
@date:        05 December 2017
@description: Test method for cleanseFields(sObject obj, boolean isRead) method.
*******************************************************************************/
    static testmethod void cleanseFieldsSObject_Positive(){
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive=true and USERNAME =: USERNAMECOMPLETE limit 1];
        
        Contact objContact = [Select id,FIRSTNAME,DONOTCALL from Contact limit 1];
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            SObject conObj = GlUt_FieldSecurity.cleanseFields(objContact,true);
            Test.stopTest();
            
            boolean fieldExists = conObj.getSobjectType().getDescribe().fields.getMap().keySet().contains(FIRSTNAME.toLowerCase());
            //Assert to check field exists on the SObject
            System.assertEquals(fieldExists,true);
        }
    }
/******************************************************************************
@author:      Shivangi Gaur
@date:        06 December 2017
@description: Test method for cleanseFields(sObject obj, boolean isRead) method negative scenario.
*******************************************************************************/
    static testmethod void cleanseFieldsSObject_Negative(){
        //Query user record created in test setup data method
        User objUser =[Select id,name from user where isActive=true and Profile.Name =: PROFILENAMECUSTOM and USERNAME =: USERNAMECOMPLETECUSTOM limit 1];
        
        AgreedRate__c objListRate = [Select id,WholesaleAmount__c from AgreedRate__c limit 1];
        
        //Run test class in user context
        System.runAs(objUser){
            
            Test.startTest();
            SObject rateObj = GlUt_FieldSecurity.cleanseFields(objListRate,false);
            Test.stopTest();
            
            boolean fieldExists = rateObj.getSobjectType().getDescribe().fields.getMap().keySet().contains(WHOLESALEAMTFIELD);
            //Assert to check field is removed from SObject map
            System.assertEquals(fieldExists,false);
        }
    }   
}