/******************************************************************************
@author:      Echo: Neha 
@date:        04-04-2018  
@description: Test Class for GlAp_RelatedRecordListCtrlr
*******************************************************************************/
@isTest 
public class GlAp_RelatedRecordListCtrlr_Test {
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String DEVICE_SIZE = 'TestDeviceSize';
    private static final String MANUFACTURER = 'Siemens';
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String DEVICE_NAME = '123456789';
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    private static final String RELATED_LIST = NAMESPACEPREFIX + 'RelatedListDetails';
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        04-04-2018  
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
        
        // Create Device Record
        Device__c objDevice = GlUt_FactoryData_Test.createDevice(DEVICE_NAME, objDeviceType);        
        Database.insert(objDevice);
        
        // Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading);
        
    }

	/******************************************************************************
	@author:      Echo: Neha
	@date:        05-04-2018  
	@description: Test Method 
	*******************************************************************************/
    static testmethod void retrieveFieldProperties_Positive(){            
        
        User objUser =[SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
      
        System.runAs(objUser){
            Test.startTest(); 
            
        	List<GLAp_FieldProps> fieldPropsList = new List<GLAp_FieldProps>(); 
        	
        	fieldPropsList = GlAp_RelatedRecordListCtrlr.retrieveFieldProperties(GlUt_APIConstantsReading.READINGAPINAME, RELATED_LIST, true); 
          
            system.assert(fieldPropsList.size() > 0);
            Test.stopTest();          
        }         
    }  
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        05-04-2018  
	@description: Test Method 
	*******************************************************************************/
    static testmethod void retrieveRecords_Positive(){            
        
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
      
        Device__c recordId = [SELECT Id FROM device__c LIMIT 1];
        
        System.runAs(objUser){
            Test.startTest(); 
            
        	List<BlAp_CombinedRecord> combinedRecordList = new List<BlAp_CombinedRecord>(); 
        	
        	combinedRecordList = GlAp_RelatedRecordListCtrlr.retrieveRecords(recordId.id, GlUt_APIConstantsReading.READINGAPINAME, GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME, RELATED_LIST, null); 
          
            system.assert(combinedRecordList.size() > 0);
            
            Test.stopTest();                     
        }  
    } 
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        05-04-2018  
	@description: Test Method 
	*******************************************************************************/
    static testmethod void retrieveRecords_Negative(){            
        
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
      
        Device__c recordId = [SELECT Id FROM device__c LIMIT 1];
        
        System.runAs(objUser){
            Test.startTest(); 
            
        	List<BlAp_CombinedRecord> combinedRecordList = new List<BlAp_CombinedRecord>(); 
        	
        	combinedRecordList = GlAp_RelatedRecordListCtrlr.retrieveRecords(null, GlUt_APIConstantsReading.READINGAPINAME, GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME, RELATED_LIST, null); 
          
            system.assert(combinedRecordList.size() == 0);
            
            Test.stopTest();                       
        }  
    } 
    
    
    /******************************************************************************
	@author:      Echo: Tarun
	@date:        28-08-2018  
	@description: Test Method 
	*******************************************************************************/
    static testmethod void setRecordInvalid_Negative(){            
        
        User objUser = [SELECT Id,Name FROM user WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
      
        Device__c recordId = [SELECT Id FROM device__c LIMIT 1];
        
        System.runAs(objUser){
            Test.startTest(); 
            
        	List<SObject> sobjectRecords = new List<SObject>(); 
        	
        	sobjectRecords = GlAp_RelatedRecordListCtrlr.setRecordInvalid(recordId.Id); 
            
            system.debug('sobjectRecords***'+ sobjectRecords);
          
            system.assert(sobjectRecords.size() == 0);
            
            Test.stopTest();                       
        }  
    }
    
}