/***************************************************************************************************
@author        Echo : Dependra Singh
@date          25 May 2018
@description:  Test Class for BlAp_UploadPdfTemplateCtrlr 
@group         
*******************************************************************************************************/
@isTest
public with sharing class BlAp_UploadPdfTemplateCtrlr_Test {
    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME+ '@unitest.com';
    private static String XSLTTEMPLATE = 'TestXsltTemplate';
    private static String CONTENTTYPE = 'application/octet-stream';
    private static String TESTBODY = 'TESTBODY';
    
    private static final string HEROKUSECURITY = 'ABCSRESSGSTSEESDGS';
    private static string PDFTEMPLATEMOCKPOSITIVE = 'BlAp_Mock_PDFTemplate_Response_Positive';
    private static string ATTACHMENTNAME = 'UnitTestAttachment';
    private static string TESTDESCRIPTION = 'Test Description';
    private static string FAKEATTACHMENTNAME = 'UnitTestAttachment';
    private static final String TESTREGION = 'Test Region';
    
    /*******************************************************************
    Purpose: method to create test data 
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    @TestSetup
    Static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE ,USER_NAME ,null);
        Database.insert(objUser);   
        
        HerokuSecurity__c hSecurity = GlUt_FactoryData_Test.createHerokuSecurity(HEROKUSECURITY);
        DataBase.insert(hSecurity);
        
        Region__c objRegion = GlUt_FactoryData_Test.createRegion(TESTREGION, true, false, false);
        insert objRegion;
        
    }
    
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        25 May 2018
    @description: Test method for generateRandomString method.
    *******************************************************************************/  
    
    static testmethod void generateRandomString_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive = true limit 1];
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            string randomString = BlUt_DocumentsUpload.generateRandomString(7);
            Test.stopTest();            
            System.assertNotEquals(randomString,null); 
        }
    }
    /*******************************************************************
    Purpose: Method to test (Positive Scenario)
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void uploadFile_Positive(){
        User objuser = [select id from user limit 1];
        
        Attachment attach=new Attachment(); 
        attach.Name=ATTACHMENTNAME; 
        Blob bodyBlob=Blob.valueOf(TESTBODY); 
        attach.body=bodyBlob; 
        attach.ContentType = CONTENTTYPE; 
        attach.IsPrivate = false; 
        attach.Description = TESTDESCRIPTION; 
        
        system.runas(objUser){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(PDFTEMPLATEMOCKPOSITIVE));
            BlAp_UploadPdfTemplateCtrlr objTemplate  = new BlAp_UploadPdfTemplateCtrlr();
            objTemplate.getObjAttachment();
            BlAp_UploadPdfTemplateCtrlr.uploadPdfTemplateRequest();
            objTemplate.objAttachment = attach;
            objTemplate.fileName= attach.Name;
            objTemplate.xsltTemplateName=XSLTTEMPLATE;
            objTemplate.uploadFile();
            Test.stopTest();
            system.assert(objTemplate.fileUploadProcessed == true);
        }   
    }
    /*******************************************************************
    Purpose: Method to test (Negative Scenario)
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void uploadFile_Negative(){
        User objuser = [select id from user limit 1];
        
        Attachment attach=new Attachment(); 
        attach.Name= ATTACHMENTNAME; 
        attach.ContentType = CONTENTTYPE; 
        attach.Description = TESTDESCRIPTION; 
        
        system.runas(objUser){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(TESTDESCRIPTION));
            BlAp_UploadPdfTemplateCtrlr objTemplate  = new BlAp_UploadPdfTemplateCtrlr();
            objTemplate.getObjAttachment();
            objTemplate.objAttachment = attach;
            objTemplate.fileName= ATTACHMENTNAME;
            objTemplate.uploadFile();
            Test.stopTest();
            system.assert(objTemplate.fileUploadProcessed == false);
        }   
    }
    
     /*******************************************************************
    Purpose: Method to test (Negative Scenario)
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void uploadFile_Negative1(){
        User objuser = [select id from user limit 1];
        
        Attachment attach=new Attachment(); 
        attach.Name= ATTACHMENTNAME; 
        Blob bodyBlob=Blob.valueOf(TESTBODY); 
        attach.body=bodyBlob; 
        attach.ContentType = CONTENTTYPE; 
        attach.Description = TESTDESCRIPTION; 
        
        system.runas(objUser){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(TESTDESCRIPTION));
            BlAp_UploadPdfTemplateCtrlr objTemplate  = new BlAp_UploadPdfTemplateCtrlr();
            objTemplate.fileName= ATTACHMENTNAME;
            
            objTemplate.uploadFile();
            Test.stopTest();
            system.assert(objTemplate.fileUploadProcessed == false);
        }   
    }
    
}