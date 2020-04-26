/******************************************************************************
@author         Echo: Swati Mathur
@date           05 Feb 2018 
@description    Test Class For LtUt_PrintedLetter
*******************************************************************************/
@isTest
public class LtUt_PrintedLetter_Test {
    
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
        
        EmailMessage objEmailMessage = new EmailMessage(ToAddress= TO_ADDRESS, FromAddress= FROM_ADDRESS, Subject= EMAIL_SUBJECT,HtmlBody= EMAIL_BODY, RelatedToId= objAccount.Id);
        Database.insert(objEmailMessage);
       
    }     
    /******************************************************************************
    @author        Swati Mathur
    @date          05 Feb 2018  
    @param         
    @return        Void   
    @description   Test method for constructor
    *******************************************************************************/
    @isTest
    private static void LtUt_PrintedLetter_Test(){
        
        User objUser = [SELECT id,name FROM user WHERE isActive=true LIMIT 1];
        
        System.runAs(objUser){
            
           EmailMessage objEmailMes = [SELECT  ToAddress,HtmlBody FROM EmailMessage];                                               
           PDFRequest__c objCreateLetterPDFRequest = [SELECT id,HtmlBody__c FROM PDFRequest__c];
                                      
           System.assertEquals(objEmailMes.HtmlBody, objCreateLetterPDFRequest.HtmlBody__c);
        
        }
    }

}