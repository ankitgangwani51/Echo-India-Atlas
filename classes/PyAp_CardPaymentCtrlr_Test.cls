/******************************************************************************
@author:      Echo: Amit K.
@date:        05 Feb 2018
@description: Test Class for PyAp_CardPaymentCtrlr
@Revision     Tarun/Dependra, Fixed Deployment failures - 11 Mar 2019
*******************************************************************************/
@isTest
public class PyAp_CardPaymentCtrlr_Test {
    private static String PROFILENAME  = 'System Administrator';
    private static String USERNAME = 'TestUser555';
    private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    private static string BPOINT_AUTH_KEY_RESPONSE_MOCK_POSITIVE = 'PyAp_BpointAuthKeyResponseMock_Positive';
    private static string BPOINT_AUTH_KEY_RESPONSE_MOCK_NEGATIVE = 'PyAp_BpointAuthKeyResponseMock_Negative';
    private static string BPOINT_PROCESS_PAYMENT_RESPONSE_MOCK_POSITIVE = 'PyAp_BpointProcessPaymentResponseMock_Positive';
    private static string BPOINT_PROCESS_PAYMENT_RESPONSE_MOCK_NEGATIVE = 'PyAp_BpointProcessPaymentResponseMock_Negative';
    private static string CONTRACT_NO = 'Con-0001';
    private static string CARD_HOLDER_NAME = 'cardHolderName';
    private static string PAYMENT_METHOD = 'Credit Card';
    private static string AMOUNT = '100';
    private static string AUTHKEY = '****XXXXX****';
    
    /******************************************************************************
    @author:      Echo: Amit K.
    @date:        05 Feb 2018
    @description: Test data setup method
    *******************************************************************************/   
    @TestSetup
    Static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(PROFILENAME,USERNAME,null);
        Database.insert(objUser);
        Account  objAccount = GlUt_FactoryData_Test.createAccount(USERNAME);
        Database.insert(objAccount);
        BillingContract__c  objBillingContract = GlUt_FactoryData_Test.createContract(objAccount);
        Database.insert(objBillingContract);
    }
    /******************************************************************************
    @author:      Echo: Amit K.
    @date:        05 Feb 2018
    @description: Bpoint Authentication Key Request method postitive scenario
    *******************************************************************************/ 
    static testmethod void requestAuthenticationKey_PositiveTest(){
        setBPointData(); // Added By Echo: Dependra Singh 
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        BillingContract__c objBillingContract = [Select id from BillingContract__c limit 1];
        System.runAs(objUser ){
            PyAp_CardPaymentCtrlr.ContainerWrapper responseWrapper;
            
            Test.startTest();
            // Set mock callout class with response code as 200 and response status as Completed
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BPOINT_AUTH_KEY_RESPONSE_MOCK_POSITIVE));
            responseWrapper = PyAp_CardPaymentCtrlr.getInfoToDisplay(objBillingContract.Id);
            Test.stopTest();
            System.assert(responseWrapper!= null);
        }   
    }
    /******************************************************************************
    @author:      Echo: Amit K.
    @date:        05 Feb 2018
    @description: Bpoint Authentication Key Request method negative scenario
    *******************************************************************************/ 
    static testmethod void requestAuthenticationKey_NegativeTest(){
        setBPointData();// Added By Echo: Dependra Singh
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        BillingContract__c objBillingContract = [Select id from BillingContract__c limit 1];
        
        System.runAs(objUser ){
            PyAp_CardPaymentCtrlr.ContainerWrapper responseWrapper;
            Test.startTest();
            // Set mock callout class with response code as 200 and response status as Completed
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BPOINT_AUTH_KEY_RESPONSE_MOCK_NEGATIVE));
            responseWrapper = PyAp_CardPaymentCtrlr.getInfoToDisplay(objBillingContract.Id);
            Test.stopTest();
            System.assert(string.isBlank(responseWrapper.AuthKey));
        }   
    }
    /******************************************************************************
    @author:      Echo: Amit K.
    @date:        05 Feb 2018
    @description: Bpoint Process Payment Request method postitive scenario
    *******************************************************************************/ 
    static testmethod void processPayment_PositiveTest(){
        setBPointData();// Added By Echo: Dependra Singh
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        BillingContract__c objBillingContract = [Select id,AccountName__c from BillingContract__c limit 1];
        
        System.runAs(objUser ){
            PyAp_CardPaymentCtrlr.ProcessPaymentWrapper responseWrapper;
            Test.startTest();
            // Set mock callout class with response code as 200 and response status as Completed
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BPOINT_PROCESS_PAYMENT_RESPONSE_MOCK_POSITIVE));
            responseWrapper = PyAp_CardPaymentCtrlr.processPayment(CONTRACT_NO,CARD_HOLDER_NAME,AMOUNT,AUTHKEY,objBillingContract.Id,objBillingContract.AccountName__c,PAYMENT_METHOD);
            Test.stopTest();
            System.assert(string.isNotBlank(responseWrapper.redirectionUrl));
        }   
    }
    /******************************************************************************
    @author:      Echo: Amit K.
    @date:        05 Feb 2018
    @description: Bpoint Process Payment Request method negative scenario
    *******************************************************************************/ 
    static testmethod void processPayment_NegativeTest(){
        setBPointData();// Added By Echo: Dependra Singh
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        BillingContract__c objBillingContract = [Select id,AccountName__c from BillingContract__c limit 1];
        
        System.runAs(objUser ){
            PyAp_CardPaymentCtrlr.ProcessPaymentWrapper responseWrapper;
            Test.startTest();
            // Set mock callout class with response code as 200 and response status as Completed
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BPOINT_PROCESS_PAYMENT_RESPONSE_MOCK_NEGATIVE));
            responseWrapper = PyAp_CardPaymentCtrlr.processPayment(CONTRACT_NO,CARD_HOLDER_NAME,AMOUNT,AUTHKEY,objBillingContract.Id,objBillingContract.AccountName__c,PAYMENT_METHOD);
            Test.stopTest();
            System.assert(string.isBlank(responseWrapper.redirectionUrl));
        }   
    }
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        11 Mar 2019
    @description: Bpoint Custom meta data setting
    *******************************************************************************/ 
    private static void setBPointData(){
        GlUt_CustomMetaDataUtility.setMetadata(PyAp_Constants.BPOINTINTERFACEPARAMSETTINGQUERY,(List<BPointInterfaceParameters__mdt>) JSON.deserialize( 
            '[{ "' + 
            PyAp_Constants.BPOINT_INTERFACE_AUTHKEY_FIELD + '":"' + PyAp_Constants.BPOINT_INTERFACE_AUTHKEY_VALUE + '","' + 
            PyAp_Constants.BPOINT_INTERFACE_IFRAME_FIELD  + '":"' + PyAp_Constants.BPOINT_INTERFACE_IFRAME_VALUE + '","' + 
            PyAp_Constants.BPOINT_INTERFACE_PAYMENT_FIELD + '":"' +  PyAp_Constants.BPOINT_INTERFACE_PAYMENT_VALUE  + '","' +
            PyAp_Constants.BPOINT_INTERFACE_TESTMODE_FIELD + '":"' + PyAp_Constants.BPOINT_INTERFACE_TESTMODE_VALUE + '","' + 
            PyAp_Constants.BPOINT_INTERFACE_PWD_FIELD + '":"' + PyAp_Constants.BPOINT_INTERFACE_PWD_VALUE + '","' + 
            PyAp_Constants.BPOINT_INTERFACE_TRANSTYPE_FIELD + '":"' + PyAp_Constants.BPOINT_INTERFACE_TRANSTYPE_VALUE  + '","' + 
            PyAp_Constants.BPOINT_INTERFACE_USERNAME_FIELD + '":"' + PyAp_Constants.BPOINT_INTERFACE_USERNAME_VALUE + '"}]', List<BPointInterfaceParameters__mdt>.class )); 
        
    }
}