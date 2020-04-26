/******************************************************************************
@author:      Swati Mathur
@date:        31-10-2017
@description: Test Class for GlUt_EmailMessageHandler
@Revisions	  	AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/
@isTest
public class GlUt_EmailMessageHandler_Test {
    
    //Variable declaration start
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='TestUser'; 
    private static String ACCOUNT_NAME = 'TestAccount';
    private static String TO_ADDRESS = 'printLetter@clientName.com'; 
    private static String FROM_ADDRESS = 'abc@echo-ms.com'; 
    private static String EMAIL_SUBJECT = 'TestEmailSubject'; 
    private static String EMAIL_BODY = 'XYZ';
    
            
    /******************************************************************************
    @author        Swati Mathur
    @date          05 Feb 2018    
    @param         
    @return        Void   
    @description   Test data setup method
    *******************************************************************************/ 
    @testSetup
    static void SetUp()
    {
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        Database.insert(objUser); 
        
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        ConfigureTemplate__c objCS = new ConfigureTemplate__c();
        objCS.PrintedLetterEmailAddress__c = TO_ADDRESS;
        Database.insert(objCS);
    }
    
    /*******************************************************************
    Purpose: Test bulk insert for Supply Point Device Service
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void insertEmailMessage_Bulk(){
        User dummyUser = [select id,name from user where isActive=true limit 1];
        Account objAccount = [select id,name from Account limit 1];
        
        list<EmailMessage> lstEmailMessage = new list<EmailMessage>();
        List<PDFRequest__c> lstCreateLetterPDFRequest = new List<PDFRequest__c>();
        System.runAs(dummyUser){
            
            Test.startTest();
            for(integer i =0; i < 200; i++){
                //, ActivityId = objTask.Id
                EmailMessage objEmailMessage = new EmailMessage(ToAddress= TO_ADDRESS, FromAddress= FROM_ADDRESS, Subject= EMAIL_SUBJECT,HtmlBody= EMAIL_BODY, RelatedToId= objAccount.Id);
                lstEmailMessage.add(objEmailMessage);
            }
            Database.insert(lstEmailMessage); 
            Test.stopTest();
            lstCreateLetterPDFRequest = [SELECT Id FROM PDFRequest__c LIMIT 10];
            System.assert(lstCreateLetterPDFRequest.size() > 0);
        }
    }       
}