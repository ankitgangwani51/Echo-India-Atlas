/*******************************************************************
@author:      ECHO: Vivek Sethi
@date:        30-Oct-2018
@param:       N/A
@return:      void
@description: Test class for LoAp_InfoStatementAddReadingsCtrlr_Test
********************************************************************/

@isTest
public class LoAp_InfoStatementAddReadingsCtrlr_Test {
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    private static final String DEVICE_SIZE = '22 mm';
    private static final String MANUFACTURER = 'Aqua';
    private static final String CONTRACT_NAME = 'Test_Contract';
    private static final String ACCOUNT_NAME  = 'TestAccount' ;
    private static final String UNIT_OF_MEASURE = 'Metric';
    private static final String DEVICE_NAME = 'Meter';  
    private static final String NEW_DEVICE_SIZE = '20 mm';
    private static final String MANUFACTURER1 = 'Kent';    
    private static final String NEW_DEVICE_NAME = 'New Meter';
    private static final String AVAIL_SERVICE 	= 'WATER';
    private static final String ZIPCODE 		= 'WS2 8DE';	
    private static final String SERVICE_TYPE 	= 'Service_Type';  
    private static final String SP_USAGE_TYPE	= 'SupplyPointUsageType';
    private static final String WHOLESALER 		= 'abc';
    private static final String READFREQUENCY	='Monthly';
    private static final String FIELDSET 	    = Label.LoAp_InfoStatementReadingFieldSet; 
    
    
    /******************************************************************************
	@author:      ECHO: Vivek Sethi
	@date:        30-Oct-2018
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
        
        //Create account
        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
  
        // Create Contract Record            
        BillingContract__c objContract = GlUt_FactoryData_Test.createContract(CONTRACT_NAME, objAccount);
        Database.insert(objContract);
		
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
        objReading.ReadingDate__c = system.today();
        objReading.Billed__c = false;
        Database.insert(objReading); 
        
         // Create Location Record            
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(ZIPCODE);
        Database.insert(objLocation);
		
        //Create Supply Point Usage Type Record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        // Create SupplyPoint Record            
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c = True; 
   
        Database.insert(objSupplyPoint);
        
        //Insert supply point device record
        SupplyPointDevice__c objSPD = GlUt_FactoryData_Test.createSupplyPointDevices(objDevice,objSupplyPoint);
        Database.insert(objSPD);
        
         // Create Division Record            
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.insert(objDivision);        
        
        // Create Wholesaler Record            
        Wholesaler__c objWholesaler = GlUt_FactoryData_Test.createWholesaler(WHOLESALER);
        Database.insert(objWholesaler);    
        
        // Create Service Type Record            
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(SERVICE_TYPE);
        Database.insert(objServiceType);
		
		// Create Available Service Record            
        AvailableService__c objAvailableService = GlUt_FactoryData_Test.createAvailableService(AVAIL_SERVICE, objDivision, objServiceType, objSupplyPoint, objWholesaler );
        Database.insert(objAvailableService);	
        
        //Create Service Record
        Service__c  objService = GlUt_FactoryData_Test.CreateService(objContract,objReading,objServiceType,objSupplyPoint,objAvailableService);
        Database.insert(objService);
        
        //Create Information Statement
        InformationStatement__c objInformationStatement = GlUt_FactoryData_Test.createInformationStatement(objContract, objLocation,objService);
        Database.insert(objInformationStatement);	
    }
    
    /******************************************************************************
	@author:      ECHO: Vivek Sethi
	@date:        30-Oct-2018
    @description: Test Method for retrieveDevicePropDetails
    *******************************************************************************/
    static testmethod void retrieveDevicePropDetails(){
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        system.Runas(objUser){
            Test.starttest();
            List<GLAp_FieldProps> lstFieldProps = LoAp_InfoStatementAddReadingsCtrlr.retrieveDevicePropDetails();
            Test.stoptest();
            system.assert(lstFieldProps!=null);
        }
    }
    
    /******************************************************************************
	@author:      ECHO: Vivek Sethi
	@date:        30-Oct-2018
    @description: Test Method for retrieveReadingsPropDetails
    *******************************************************************************/
    static testmethod void retrieveReadingsPropDetails(){
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        system.Runas(objUser){
            Test.starttest();
            List<GLAp_FieldProps> lstFieldProps = LoAp_InfoStatementAddReadingsCtrlr.retrieveReadingsPropDetails(FIELDSET);
            Test.stoptest();
            system.assert(lstFieldProps!=null);
        }
    }
    /******************************************************************************retrieveReadings
	@author:      ECHO: Vivek Sethi
	@date:        30-Oct-2018
    @description: Test Method for retrieveReadings
    *******************************************************************************/
    static testmethod void retrieveReadings_Positive()
    { 
        User objUser =[select Id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        InformationStatement__c objInformationStatement =[select Id, CreatedDate from InformationStatement__c limit 1];
        Device__c objDevice =[select Id from Device__c limit 1];
        system.Runas(objUser){
            Test.starttest();
            List<BlAp_CombinedRecord>lstFieldProps = LoAp_InfoStatementAddReadingsCtrlr.retrieveReadings(objDevice.Id, FIELDSET, objInformationStatement.Id);
            Test.stoptest();
            system.assert(lstFieldProps.size() > 0);
        }
    }
    
    /******************************************************************************retrieveReadings
	@author:      ECHO: Vivek Sethi
	@date:        30-Oct-2018
    @description: Test Method for retrieveReadings
    *******************************************************************************/
    static testmethod void retrieveReadings_Negative()
    { 
        User objUser =[select Id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        InformationStatement__c objInformationStatement =[select Id from InformationStatement__c limit 1];
        Device__c objDevice = new Device__c();
        Boolean isException;
        List<BlAp_CombinedRecord>lstFieldProps = new List<BlAp_CombinedRecord>();
        system.Runas(objUser){
            try{
                Test.starttest();
                lstFieldProps = LoAp_InfoStatementAddReadingsCtrlr.retrieveReadings(objDevice.Id, FIELDSET, objInformationStatement.Id);
                Test.stoptest();
            }catch(exception e) {
                isException = true;
            }  
            system.assert(lstFieldProps.size() == 0);
        }
    }
  
    /******************************************************************************retrieveReadings
	@author:      ECHO: Vivek Sethi
	@date:        30-Oct-2018
    @description: Test Method for retrieveDeviceRecords
    *******************************************************************************/
    static testmethod void retrieveDeviceRecords_Positive()
    { 
        User objUser =[select Id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        InformationStatement__c objInformationStatement =[select Id from InformationStatement__c limit 1];
        system.Runas(objUser){
            Test.starttest();
            List<BlAp_CombinedRecord>lstFieldProps = LoAp_InfoStatementAddReadingsCtrlr.retrieveDeviceRecords(objInformationStatement.Id);
            Test.stoptest();
            
            system.assert(lstFieldProps.size() > 0);
        }
    }
    
    /******************************************************************************
	@author:      ECHO: Vivek Sethi
	@date:        30-Oct-2018
	@description: Test Method for saverecord
	*******************************************************************************/
    static testmethod void saverecord_Positive()
    { 
        User objUser =[select Id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        InformationStatement__c objInformationStatement =[select Id from InformationStatement__c limit 1];
        Reading__c objReading =[select Id from Reading__c limit 1];
        Device__c objDevice =[select Id from Device__c limit 1];
        system.Runas(objUser){
            Test.starttest();
            Boolean recordSaved = LoAp_InfoStatementAddReadingsCtrlr.saveRecords(objReading.Id, objInformationStatement.Id,objDevice.Id);
            Test.stoptest();
            system.assertEquals(recordSaved, true);
        }
    }
    
    /******************************************************************************
	@author:      ECHO: Vivek Sethi
	@date:        30-Oct-2018
	@description: Test Method for saverecord
	*******************************************************************************/
    static testmethod void saverecord_Negative()
    { 
        User objUser =[select Id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        InformationStatement__c objInformationStatement = new InformationStatement__c();
        Reading__c objReading =[select Id from Reading__c limit 1];
        Device__c objDevice =[select Id from Device__c limit 1];
        Boolean recordSaved ;
        Boolean isException;
        system.Runas(objUser){
            try{
                Test.starttest();
                recordSaved = LoAp_InfoStatementAddReadingsCtrlr.saveRecords(objReading.Id, objInformationStatement.Id,objDevice.Id);
                Test.stoptest();
            }catch(exception e) {
                isException = true;
            } 
            system.assertEquals(recordSaved, false);
        }
    }
}