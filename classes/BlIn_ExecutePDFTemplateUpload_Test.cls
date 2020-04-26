/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        26 October 2017
@description: Test Class for BlIn_ExecutePDFTemplateUpload
Revision(s):  03-Nov-2017 -- Shivangi Gaur -- Added method UploadTemplateWithLast4NotFooter_Positive().
@Revisions	  AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/

@isTest
Public Class BlIn_ExecutePDFTemplateUpload_Test{
   
    //Variable declaration start
    private static string USERPROFILENAME = 'System Administrator';
    private static string USERNAME = 'TestUser';
    private static string MANAGERID = Null;
    private static String ACCOUNT_NAME = 'TestAccount';
    private static String CONTRACT_NAME ='TestContract';
    private static String BILL_NAME ='TestBill';
    private static final string HEROKUSECURITY = 'ABCSRESSGSTSEESDGS';  
    private static string LENGTH = '7';
    private static string FILENAME = 'test';
    private static string BILLCALCULATIONMOCKPOSITIVE = 'BlAp_Mock_BillingCalculation_Response_Positive';
    //Variable declaration end

/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        26 October 2017
@description: Test data setup method
*******************************************************************************/    
    @TestSetup
    static void createTestData(){
            
        User objUser = GlUt_FactoryData_Test.createUser(USERPROFILENAME, USERNAME , null);
        Database.insert(objUser);
    
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
    
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(CONTRACT_NAME,objAccount);
        objContract.LastBillCalculationDate__c = system.Today();
        Database.insert(objContract);
    
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILL_NAME,objContract);
        Database.insert(objBill);
    
        HerokuSecurity__c hSecurity = GlUt_FactoryData_Test.createHerokuSecurity(HEROKUSECURITY);
        DataBase.insert(hSecurity);     
        
    }
     
/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        26 October 2017
@description: Test method for generateRandomString method.
*******************************************************************************/
    static testmethod void generateRandomString_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive = true limit 1];
        //Run test class in user context
        System.runAs(objUser){
            Test.startTest();
            string randomString = BlIn_ExecutePDFTemplateUpload.generateRandomString(7);
            Test.stopTest();            
            System.assertNotEquals(randomString,null); 
        }
    }
        
/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        26 October 2017
@description: Test method for UploadTemplate method.
*******************************************************************************/ 
    static testmethod void uploadTemplate_Positive(){
        User objuser = [select id from user limit 1];
        Bill__c objBill = [select id from Bill__c limit 1];
        // save the XML as a content document and link it to the bill
        ContentVersion document = new ContentVersion(
                                  Title = 'test', 
                                  VersionData =  Blob.valueOf('testfile'), 
                                  PathOnClient =  'bill PDF ' + objBill.id + '.pdf' 
                                  );
        insert document;
        Blob fileContent = Blob.valueOf('testfile');
        String fileName = FILENAME;               
        document = [select Id, ContentDocumentId from ContentVersion where Id = :document.Id order by CreatedDate desc];                
        Id docId = document.ContentDocumentId;
        Boolean b;                
        system.runas(objUser){
            try{
                Test.startTest();                  
                // Set mock callout class
                Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BILLCALCULATIONMOCKPOSITIVE));
                b = BlIn_ExecutePDFTemplateUpload.UploadTemplate(docId);
                Test.stopTest();
            	system.assertNotEquals(false,b); 
            }catch(exception e){
                system.debug('****************e ' + e);
            }
        }
    }

/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        03 Nov 2017
@description: Test method for UploadTemplate method.
*******************************************************************************/ 
 static testmethod void uploadTemplateWithLast4NotFooter_Positive(){
        User objuser = [select id from user limit 1];
        Bill__c objBill = [select id from Bill__c limit 1];
        // save the XML as a content document and link it to the bill
        ContentVersion document = new ContentVersion(
                                  Title = 'test', 
                                  VersionData =  Blob.valueOf('testfile===='), 
                                  PathOnClient =  'bill PDF ' + objBill.id + '.pdf' 
                                  );
        insert document;
        Blob fileContent = Blob.valueOf('testfile====');
        String fileName = FILENAME;               
        document = [select Id, ContentDocumentId from ContentVersion where Id = :document.Id order by CreatedDate desc];                
        Id docId = document.ContentDocumentId;
        Boolean b;                
        system.runas(objUser){
            try{
                Test.startTest();                  
                // Set mock callout class
                Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BILLCALCULATIONMOCKPOSITIVE));
                b = BlIn_ExecutePDFTemplateUpload.UploadTemplate(docId);
                Test.stopTest();
            }catch(exception e){
                system.debug('*********e '+  e);
            }
            system.assertNotEquals(false,b); 
        }
    }  

/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        26 October 2017
@description: Test method for UploadTemplate method.
*******************************************************************************/
    static testmethod void uploadTemplate_Negative(){   
        User objuser = [select id from user limit 1];
        Bill__c objBill = [select id from Bill__c limit 1];
        Boolean b;               
        system.runas(objUser){
            try{
                Test.startTest();                      
                // Set mock callout class
                Test.setMock(HttpCalloutMock.class, new GlUt_MockAPIProvider_Test(BILLCALCULATIONMOCKPOSITIVE));
                b = BlIn_ExecutePDFTemplateUpload.UploadTemplate(objBill.id);
                Test.stopTest();
              }catch(exception e){
                  System.assert(e.getmessage()!= null); 
                }

            }
    }       

 
}