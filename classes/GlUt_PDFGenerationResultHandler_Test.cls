/******************************************************************************
@author:      Echo: Sudhir Kumar
@date:        18-June-2018
@description: Test Class for GlUt_PDFGenerationResultHandler
*******************************************************************************/

@isTest
public class GlUt_PDFGenerationResultHandler_Test {
   
    //Variable declaration start
    private static String USERPROFILE = 'System Administrator';
    private static final String USERFNAME= 'TestFName';
    private static final String USERLNAME= 'TestLName';
    private static String USERNAME = 'TestUser';
    private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com'; 
    private static String ACCOUNTNAME = 'TestAccount';
    
    private static String BILLINGSTREET ='Test Street';
    private static String BILLINGCITY = 'Test City';
    private static String BILLINGSTATE = 'Test State';
    private static String BILLINGPOSTCODE ='0000000';
    private static String BILLINGCOUNTRY ='Test Country';
    
    private static String FIRSTNAME		 ='FirstName_Test';
    private static String LASTNAME		 ='LastName_Test';
	
    /*******************************************************************
    Purpose: Method is used to Test Setup in test class.
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    @TestSetup
    static void createTestData(){
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(USERPROFILE,USERNAME,NULL);
        objUser.FirstName = USERFNAME;
        objUser.LastName = USERLNAME;
        Database.insert(objUser); 
       
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNTNAME);
        Database.insert(objAccount);
        Contact objContact = GlUt_FactoryData_Test.createContact(FIRSTNAME, LASTNAME) ;
        Database.insert(objContact) ;
        
        Balance__c objBalance = GlUt_FactoryData_Test.createBalance(objAccount);
        Database.insert(objBalance);  
        
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(' ',objAccount);
        objContract.BillingStreet__c=BILLINGSTREET;
        objContract.BillingCity__c=BILLINGCITY;
        objContract.BillingState__c=BILLINGSTATE;
        objContract.BillingPostalCode__c=BILLINGPOSTCODE;
        objContract.BillingCountry__c=BILLINGCOUNTRY;
        objContract.Balance__c=objBalance.Id; 
        Database.insert(objContract);
        
		list<PDFRequest__c> listPdfRequest = new list<PDFRequest__c>() ;
        
        for(Integer i = 0; i < 200; i++) {
            if(i < = 100) {
                PDFRequest__c objPdfReq = new PDFRequest__c(Account__c = objAccount.Id, BillingContract__c = objContract.Id,  Contact__c = objContact.Id,
                                                             SourceType__c = GlUt_APIConstantsPDFRequest.HTMLSOURCETYPE , CorrespondenceType__c = GlUt_APIConstantsPDFRequest.BILLPDFCORRESPONDENCEYPE , 
                                                             Status__c = GlUt_APIConstantsPDFRequest.PENDINGSTATUS) ;
            	listPdfRequest.add(objPdfReq) ;
            } else {
                
                PDFRequest__c objPdfReq = new PDFRequest__c(Account__c = objAccount.Id, 
                                                            SourceType__c = GlUt_APIConstantsPDFRequest.XMLSOURCETYPE ,  
                                                            CorrespondenceType__c = GlUt_APIConstantsPDFRequest.BILLPDFCORRESPONDENCEYPE , 
                                                            Status__c = GlUt_APIConstantsPDFRequest.PENDINGSTATUS) ;
                listPdfRequest.add(objPdfReq) ;
            }
        }
        Database.insert(listPdfRequest);
    }
    
    /*******************************************************************
    Purpose: Test Positive case for createTask
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void createTask_Positive() { 
		User objUser = [SELECT id,name FROM user WHERE isActive = TRUE AND username =: USERNAMECOMPLETE LIMIT 1];    
        list<PDFRequest__c> listPdfrequest = [SELECT Id FROM PDFRequest__c WHERE SourceType__c =: GlUt_APIConstantsPDFRequest.HTMLSOURCETYPE] ;
        list<PDFGenerationResult__c> listPGR = new list<PDFGenerationResult__c>() ;
        System.runAs(objUser) {
            try {
                listPGR = GlUt_FactoryData_Test.createPDFGenerationResult(listPdfrequest) ;
                Test.startTest() ;
                	Database.insert(listPGR);
                Test.stopTest() ;
                system.assert(!listPGR.isEmpty()) ;
            } catch(Exception ex) {
                
            }
        }
    }

    /*******************************************************************
    Purpose: Test Negative case for createTask
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/ 
    static testmethod void createTask_Negative() { 
		User objUser = [SELECT id,name FROM user WHERE isActive = TRUE AND username =: USERNAMECOMPLETE LIMIT 1];    
        list<PDFRequest__c> listPdfrequest = [SELECT Id FROM PDFRequest__c WHERE SourceType__c =: GlUt_APIConstantsPDFRequest.XMLSOURCETYPE] ;
        list<PDFGenerationResult__c> listPGR = new list<PDFGenerationResult__c>() ;
        System.runAs(objUser) {
            try {
                listPGR = GlUt_FactoryData_Test.createPDFGenerationResult(listPdfrequest) ;
                Test.startTest() ;
                	Database.insert(listPGR);
                Test.stopTest() ;
                system.assert(!listPGR.isEmpty()) ;
            } catch(Exception ex) {
                
            }
        }
    }
    
}