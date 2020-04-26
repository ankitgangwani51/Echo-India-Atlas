/*******************************************************************************
@author         Echo: Sudhir Kumar
@date           21 Dec 2018
@group 			Test Class
@description    Test class for CuAp_ConcessionValidationCtrlr class
********************************************************************************/
@isTest
private class CuAp_ConcessionValidationCtrlr_Test {
	private static final String USER_PROFILE        	= 'System Administrator' ;
    private static final String USER_NAME           	= 'ConcessionTestUser' ;
    private static final String USERNAMECOMPLETE   		=  USER_NAME + '@unitest.com' ;
    private static final String ACCOUNT_NAME        	= 'TestAccount' ;
    private static final String CALCULATECHARGES_MOCK_POSITIVE_RESPONSE	= 'LoAp_InfoStatementCalculateChargesHttpMockResponse_Positive' ;
    private static final String CALCULATECHARGES_MOCK_NEGATIVE_RESPONSE	= 'LoAp_InfoStatementCalculateChargesHttpMockResponse_Negative' ;
    /*******************************************************************
    Purpose: method to create test data used by all test methods
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    @TestSetup
    static void createTestData() {
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE, USER_NAME, null);
        Database.insert(objUser); 
		System.runAs(objUser) {
            //Create account
            Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNT_NAME);
            Database.insert(objAccount);
            //Create Concession
            Concession__c objConcession = GlUt_FactoryData_Test.createConcession(objAccount);
            Database.insert(objConcession);
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           17 Jan 2019
    @description    positive test scenario for validateConcession method
    *******************************************************************************/ 
    static testmethod void validateConcession_Positive() {
        setCenterlinkUserCredMetaData();// Added By Echo: Dependra Singh -12-03-2019 - MetaData types Fix
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(objUser) {
            Boolean isException = false ;
            try {
                Concession__c cncObj = [SELECT Id, CRN__c, ConfirmDate__c FROM Concession__c LIMIT 1] ;
                list<CuAp_ConcessionValidationCtrlr.ResponseObject> cncResponseList =  CuAp_ConcessionValidationCtrlr.validateConcession(cncObj.Id) ;
            } catch(Exception ex) {
                isException = true ;
            }
            system.assert(!isException) ;
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           17 Jan 2019
    @description    negative test scenario for validateConcession method
    *******************************************************************************/ 
    static testmethod void validateConcession_Negative() {
        setCenterlinkUserCredMetaData();// Added By Echo: Dependra Singh -12-03-2019 - MetaData types Fix
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(objUser) {
            Boolean isException = false ;
            try {
                system.runAs(objUser) {
                    Concession__c cncObj = [SELECT Id, CRN__c, ConfirmDate__c FROM Concession__c LIMIT 1] ;
                    list<CuAp_ConcessionValidationCtrlr.ResponseObject>  cncResponseList = CuAp_ConcessionValidationCtrlr.validateConcession(UserInfo.getUserId()) ;
                    map<String, CentrelinkException__mdt> mapCentrelinkException  = CuUt_ConcessionUtility.getCentrelinkException() ;
                }
            } catch(Exception ex) {
                isException = true ;
            }
            system.assert(!isException) ;
        }
    }
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        11 Mar 2019
    @description: Combiz Interface Custom meta data setting
    *******************************************************************************/ 
    private static void setCenterlinkUserCredMetaData(){
        GlUt_CustomMetaDataUtility.setMetadata(LoBt_Constants.CENTERLINKMETADATAQUERY,(List<CentrelinkUserCredential__mdt>) JSON.deserialize( 
            '[{ "' + 
            LoBt_Constants.QUALIFIED_FIELD + '":"' + LoBt_Constants.QUALIFIED_VALUE + '","' + 
            LoBt_Constants.USERID_FIELD  + '":"' + LoBt_Constants.USERID_VALUE + '","' + 
            LoBt_Constants.USERNAME_FIELD + '":"' +  LoBt_Constants.USERNAME_VALUE  + '","' +
            LoBt_Constants.PASSWORD_FIELD + '":"' + LoBt_Constants.PASSWORD_VALUE + '","' + 
            LoBt_Constants.PASSWORDTYPE_FIELD + '":"' + LoBt_Constants.PASSWORDTYPE_VALUE + '"}]', List<CentrelinkUserCredential__mdt>.class )); 
        
        GlUt_CustomMetaDataUtility.setMetadata(LoBt_Constants.CENTERLINKEXCEPTIONMETADATAQUERY,(List<CentrelinkException__mdt>) JSON.deserialize( 
            '[{ "' + 
            LoBt_Constants.QUALIFIED_FIELD + '":"' + LoBt_Constants.QUALIFIED_VALUE + '","' + 
            LoBt_Constants.EXCEPTIONSTRING_FIELD  + '":"' + LoBt_Constants.EXCEPTIONSTRING_VALUE + '","' + 
            LoBt_Constants.MEANINGS_FIELD + '":"' +  LoBt_Constants.MEANINGS_VALUE  + '","' +
            LoBt_Constants.POSSIBLEFOLLOWUP_FIELD + '":"' + LoBt_Constants.POSSIBLEFOLLOWUP_VALUE + '"}]', List<CentrelinkException__mdt>.class )); 
    }
}