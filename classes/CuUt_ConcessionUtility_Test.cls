/*******************************************************************************
@author         Echo: Sudhir Kumar
@date           12 Mar 2019
@description    Test class for CuUt_ConcessionUtility class 
********************************************************************************/
@isTest
public class CuUt_ConcessionUtility_Test {
	
    private static final String USER_PROFILE        	= 'System Administrator' ;
    private static final String USER_NAME           	= 'ConcessionTestUser' ;
    private static final String USERNAMECOMPLETE   		=  USER_NAME + '@unitest.com' ;
    private static final String ACCOUNT_NAME        	= 'TestAccount' ;
    
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
            Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
            Database.insert(objAccount);
            //Create Concession
            Concession__c objConcession = GlUt_FactoryData_Test.createConcession(objAccount);
            Database.insert(objConcession);
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           12 Mar 2019
    @description    positive test scenario for getCentrelinkUserCredential method
    *******************************************************************************/ 
    static testmethod void getCentrelinkUserCredential_Positive() {
        setCenterlinkUserCredMetaData();
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(objUser) {
            Boolean isException = false ;
            try{
                Test.startTest() ;
                	CuUt_ConcessionUtility.getCentrelinkUserCredential() ;
                Test.stopTest() ;
            } catch(Exception ex) {
                isException = true ;
            }
            system.assert(!isException) ;
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           12 Mar 2019
    @description    positive test scenario for getCentrelinkException method
    *******************************************************************************/ 
    static testmethod void getCentrelinkException_Positive() {
        setCenterlinkUserCredMetaData();
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(objUser) {
            Boolean isException = false ;
            try{
                Test.startTest() ;
                	CuUt_ConcessionUtility.getCentrelinkException() ;
                Test.stopTest() ;
            } catch(Exception ex) {
                isException = true ;
            }
            system.assert(!isException) ;
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           12 Mar 2019
    @description    positive test scenario for getBenefitStatusMockResponse method
    *******************************************************************************/ 
    static testmethod void getBenefitStatusMockResponse_Positive() {
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(objUser) {
            Boolean isException = false ;
            try{
                Test.startTest() ;
                	CuUt_ConcessionUtility.getBenefitStatusMockResponse() ;
                Test.stopTest() ;
            } catch(Exception ex) {
                isException = true ;
            }
            system.assert(!isException) ;
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           12 Mar 2019
    @description    positive test scenario for getConcessionRecord method
    *******************************************************************************/ 
    static testmethod void getConcessionRecord_Positive() {
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        Concession__c objConcession = [SELECT Id FROM Concession__c WHERE Account__r.Name =: ACCOUNT_NAME LIMIT 1];
        system.runAs(objUser) {
            Boolean isException = false ;
            try{
                Test.startTest() ;
                	CuUt_ConcessionUtility.getConcessionRecord(objConcession.Id) ;
                Test.stopTest() ;
            } catch(Exception ex) {
                isException = true ;
            }
            system.assert(!isException) ;
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           12 Mar 2019
    @description    positive test scenario for isValidConfirmDate method
    *******************************************************************************/ 
    static testmethod void isValidConfirmDate_Positive() {
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(objUser) {
            Boolean isException = false ;
            try{
                Test.startTest() ;
                	CuUt_ConcessionUtility.isValidConfirmDate(System.today()) ;
                Test.stopTest() ;
            } catch(Exception ex) {
                isException = true ;
            }
            system.assert(!isException) ;
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           12 Mar 2019
    @description    positive test scenario for isValidCRN method
    *******************************************************************************/ 
    static testmethod void isValidCRN_Positive() {
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(objUser) {
            Boolean isException = false ;
            try{
                Test.startTest() ;
                	CuUt_ConcessionUtility.isValidCRN('123456789ABC') ;
                Test.stopTest() ;
            } catch(Exception ex) {
                isException = true ;
            }
            system.assert(!isException) ;
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           12 Mar 2019
    @description    negative test scenario for isValidCRN method
    *******************************************************************************/ 
    static testmethod void isValidCRN_Negative() {
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(objUser) {
            Boolean isValid = true ;
            Test.startTest() ;
            isValid = CuUt_ConcessionUtility.isValidCRN('') ;
            system.assert(!isValid) ;
            isValid = CuUt_ConcessionUtility.isValidCRN('12345678') ;
            system.assert(!isValid) ;
            Test.stopTest() ;
        } 
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           12 Mar 2019
    @description    positive test scenario for generatePasswordDigest method
    *******************************************************************************/ 
    static testmethod void generatePasswordDigest_Positive() {
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(objUser) {
            Boolean isException = false ;
            try{
                Test.startTest() ;
                	CuUt_ConcessionUtility.generatePasswordDigest('TestPassword123') ;
                Test.stopTest() ;
            } catch(Exception ex) {
                isException = true ;
            }
            system.assert(!isException) ;
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           12 Mar 2019
    @description    positive test scenario for generateNounce method
    *******************************************************************************/ 
    static testmethod void generateNounce_Positive() {
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(objUser) {
            Boolean isException = false ;
            try{
                Test.startTest() ;
                	CuUt_ConcessionUtility.generateNounce() ;
                Test.stopTest() ;
            } catch(Exception ex) {
                isException = true ;
            }
            system.assert(!isException) ;
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           12 Mar 2019
    @description    positive test scenario for generateTimestampFormatCCYYMMDDHHMMSS method
    *******************************************************************************/ 
    static testmethod void generateTimestampFormatCCYYMMDDHHMMSS_Positive() {
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(objUser) {
            Boolean isException = false ;
            try{
                Test.startTest() ;
                	CuUt_ConcessionUtility.generateTimestampFormatCCYYMMDDHHMMSS() ;
                Test.stopTest() ;
            } catch(Exception ex) {
                isException = true ;
            }
            system.assert(!isException) ;
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           12 Mar 2019
    @description    positive test scenario for generateTimestamp method
    *******************************************************************************/ 
    static testmethod void generateTimestamp_Positive() {
        User objUser =[select Id,Name FROM User WHERE isActive=True AND username =: USERNAMECOMPLETE LIMIT 1];
        system.runAs(objUser) {
            Boolean isException = false ;
            try{
                Test.startTest() ;
                	CuUt_ConcessionUtility.generateTimestamp() ;
                Test.stopTest() ;
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