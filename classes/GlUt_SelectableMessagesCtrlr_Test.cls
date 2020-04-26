/******************************************************************************
@author:      Echo: Neha 
@date:        30 Oct 2018
@description: Test Class for GlUt_SelectableMessagesCtrlr
@revision	  16-Jan-2019: Sudhir Kumar 
			  AT-4954 (AT-3642) : AU3 - Component Generalization: Ensure the component can be made usable from each object it is called from	  
								  Renamed from LoAp_SelectableMessagesCtrlr_Test  -> GlUt_SelectableMessagesCtrlr_Test
*******************************************************************************/
@isTest 
public class GlUt_SelectableMessagesCtrlr_Test {
    
	private static final String USER_PROFILE      = 'System Administrator';
    private static final String USER_NAME         = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME        = 'First_User_Name';
    private static final String USER_LNAME        = 'Last_User_Name'; 
    private static final String ACCOUNT_NAME      = 'TEST_ACCOUNT';
    private static final String CONTACT_NAME      = 'test1';
    private static final String ZIP_CODE          = 'WS2 8DE';
    private static final String SP_USAGE_TYPE     = 'SP usage';
    private static final String MEASURED          = 'Monthly';
    private static final String TEST_SERVICE_TYPE = 'TestServiceType';
    private static final String WHOLESALER        = 'TestWholesaler';
    private static final String AVAILABLESERVICES = 'TestAvailableService';   
    private static final String MSG_DESC		  = 'Test MSG1';
    private static final String MSG_DESC2		  = 'Test MSG2';
    private static final Boolean ACTIVE_FLAG      = True;
    private static final Boolean DEFAULT_FLAG     = false;
    private static final Boolean SELECTABLE_FLAG  = True;
    private static final String MSG_TYPE          = 'Information Statement';
    private static final String DEVICE_SIZE       = '10mm';
    private static final String MANUFACTURER      = 'Kent';
    private static final String UNITOFMEAS        = 'Metric';
    private static final String DEVICE            = 'dev';
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        30 Oct 2018  
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
           
        // Create Account Record
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);        
        Database.insert(objAccount);
                
        //Create Contract Record
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTACT_NAME,objAccount);        
        Database.insert(objContract);  
        
        //Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(ZIP_CODE);        
        Database.insert(objLocation);        
        
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        //Create Supply Point Record
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True;
        Database.insert(objSupplyPoint);
        
        //Create Service Type Record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(TEST_SERVICE_TYPE );
        Database.insert(objServiceType);
        
        //Create Division Record
        Division__c  objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);
        
        //Create Wholesaler Record
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);
        
        //Create AvailableService Record
        AvailableService__c  objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAILABLESERVICES ,objDivision,objServiceType,objSupplyPoint,objWholesaler);
        Database.insert(objAvailableService);
        
        //Create DeviceSize Record
        DeviceSize__c  objDeviceSize = GlUt_FactoryData_Test.createDeviceSize(DEVICE_SIZE);
        Database.insert(objDeviceSize);
        
        //Create DeviceType Record
        DeviceType__c  objDeviceType = GlUt_FactoryData_Test.createDeviceType(objDeviceSize, MANUFACTURER, UNITOFMEAS);
        Database.insert(objDeviceType);
        
        //Create Device Record
        Device__c  objDevice = GlUt_FactoryData_Test.createDevice(DEVICE, objDeviceType);
        Database.insert(objDevice);
        
        //Create Reading Record
        Reading__c objReading = GlUt_FactoryData_Test.createReading(objDevice);
        Database.insert(objReading);
 
        //Create Service Record
        Service__c  objService = GlUt_FactoryData_Test.createService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);               
        
		//Create InformationStatement Record
        InformationStatement__c objInformationStatement = GlUt_FactoryData_Test.createInformationStatement(objContract, objLocation, objService);        
        Database.insert(objInformationStatement);         
         
        //Create Message Record
        Message__c objMessage = GlUt_FactoryData_Test.createMessage(MSG_DESC, ACTIVE_FLAG, DEFAULT_FLAG, SELECTABLE_FLAG, MSG_TYPE);        
        Database.insert(objMessage);
        
        //Create InformationStatementMessage Record
        InformationStatementMessage__c objInformationStatementMessage = GlUt_FactoryData_Test.createInformationStatementMessage(objInformationStatement, objMessage, ACTIVE_FLAG);        
        Database.insert(objInformationStatementMessage); 
        
        //Create Message Record
        Message__c objMessage1 = GlUt_FactoryData_Test.createMessage(MSG_DESC2, ACTIVE_FLAG, DEFAULT_FLAG, SELECTABLE_FLAG, MSG_TYPE);        
        Database.insert(objMessage1);
        
        //Create InformationStatementMessage Record
        InformationStatementMessage__c objInformationStatementMessage1 = GlUt_FactoryData_Test.createInformationStatementMessage(objInformationStatement, objMessage1, ACTIVE_FLAG);        
        Database.insert(objInformationStatementMessage1); 
        
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        30 Oct 2018     
	@description: 
	*******************************************************************************/
    static testmethod void retrieveFieldList()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];             
        System.runAs(objUser){
            Test.startTest();            
        	List<GLAp_FieldProps> msgProps = GlUt_SelectableMessagesCtrlr.retrieveFieldList();
            Test.stopTest();            
            system.assert( msgProps.size() > 0);
        }
    }
    
    /******************************************************************************
	@author:      Echo: Neha
	@date:        30 Oct 2018   
	@description: 
	*******************************************************************************/
    static testmethod void retrieveRecordList()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];        
        InformationStatement__c objInformationStatement = [SELECT Id FROM InformationStatement__c LIMIT 1]; 
        System.runAs(objUser){
            Test.startTest();             
        	List<BlAp_CombinedRecord> messageSelectList = GlUt_SelectableMessagesCtrlr.retrieveRecordList(objInformationStatement.Id,GlUt_APIConstantsInformationStatement.OBJECTAPINAME );            
            Test.stopTest();            
            system.assert( messageSelectList.size() > 0);
        }
    }   
    /******************************************************************************
	@author:      Echo: Neha
	@date:        30 Oct 2018
	@description: 
	*******************************************************************************/
    static testmethod void saveInformationStatementMessageDetails()
    {            
        User objUser =[SELECT Id, Name FROM user WHERE isActive=TRUE AND USERNAME =: USERNAMECOMPLETE LIMIT 1];
    	String result;
        InformationStatement__c objInformationStatement = [SELECT Id FROM InformationStatement__c LIMIT 1];  
        System.runAs(objUser){
            Test.startTest();             
        	List<BlAp_CombinedRecord> messageSelectList = GlUt_SelectableMessagesCtrlr.retrieveRecordList(objInformationStatement.Id,GlUt_APIConstantsInformationStatement.OBJECTAPINAME); 
            Set<Id> cbmMessageIdSet = new Set<Id>();
            if(messageSelectList.size() > 0){
                Integer icount = 1;
                for(Message__c objMessage: [SELECT Id FROM Message__c LIMIT 1] ){
                	cbmMessageIdSet.add(objMessage.Id);                                                         
                }                
                for(BlAp_CombinedRecord objCR: messageSelectList){
                    system.debug('objCR ' + objCR);                   
                    if(icount == 1 && cbmMessageIdSet.contains(objCR.objectMap.get(GlUt_APIConstantsMessage.OBJECTAPINAME).id)){
                        objCR.isSelected = false;
                    }
                }
                String responseJSON = JSON.serialize(messageSelectList);
                result = GlUt_SelectableMessagesCtrlr.saveInformationStatementMessageDetails(responseJSON, objInformationStatement.Id, GlUt_APIConstantsInformationStatement.OBJECTAPINAME);
            }
            Test.stopTest();            
            system.assert(result == 'Success');
        }
    }
        
}