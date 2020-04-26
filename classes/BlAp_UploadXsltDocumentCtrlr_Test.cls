/***************************************************************************************************
@author        Echo : Dependra Singh
@date          25 May 2018
@description:  Test Class for BlAp_UploadXSLTTemplateCtrlr 
@group         
*******************************************************************************************************/
@isTest
public with sharing class BlAp_UploadXsltDocumentCtrlr_Test {
    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME+ '@unitest.com';
    private static String CONTENTTYPE = 'application/octet-stream';
    private static String TESTBODY = '<?xml version="1.0"?><xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"><xsl:template match="/"><html><body><h2>My CD Collection</h2><table border="1"><tr bgcolor="#9acd32"><th>Title</th><th>Artist</th></tr><xsl:for-each select="catalog/cd"><tr><td><xsl:value-of select="title"/></td><td><xsl:value-of select="artist"/></td></tr></xsl:for-each></table></body></html></xsl:template></xsl:stylesheet>';
    private static final string HEROKUSECURITY = 'ABCSRESSGSTSEESDGS';
    private static string XSLTTEMPLATEMOCKPOSITIVE = 'BlAp_Mock_PDFTemplate_Response_Positive';
    private static string ATTACHMENTNAME = 'UnitTestAttachment.xslt';
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
    
    /*******************************************************************
    Purpose: Method to test (Positive Scenario)
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void uploadFile_Positive(){
        User objuser = [select id from user limit 1];
        
        Attachment attach=new Attachment(); 
        attach.Name= ATTACHMENTNAME; 
        Blob bodyBlob=Blob.valueOf(TESTBODY); 
        attach.body=bodyBlob; 
        attach.ContentType = CONTENTTYPE; 
        attach.Description = TESTDESCRIPTION; 
        system.runas(objUser){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(XSLTTEMPLATEMOCKPOSITIVE));
            BlAp_UploadXsltDocumentCtrlr objTemplate  = new BlAp_UploadXsltDocumentCtrlr();
            objTemplate.getObjAttachment();
            objTemplate.objAttachment = attach;
            objTemplate.fileName= attach.Name;
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
    static testmethod void uploadFile_Negative1(){
        User objuser = [select id from user limit 1];
        
        Attachment attach=new Attachment(); 
        attach.Name= ATTACHMENTNAME; 
        attach.ContentType = CONTENTTYPE; 
        attach.Description = TESTDESCRIPTION; 
        system.runas(objUser){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(XSLTTEMPLATEMOCKPOSITIVE));
            BlAp_UploadXsltDocumentCtrlr objTemplate  = new BlAp_UploadXsltDocumentCtrlr();
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
    static testmethod void uploadFile_Negative(){
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
            BlAp_UploadXsltDocumentCtrlr objTemplate  = new BlAp_UploadXsltDocumentCtrlr();
            objTemplate.uploadFile();
            Test.stopTest();
            system.assert(objTemplate.fileUploadProcessed == false);
        }   
    }
    
}