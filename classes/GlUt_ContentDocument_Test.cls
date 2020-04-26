/******************************************************************************
@author:      Accenture: Satish Nair
@date:        26 October 2017
@description: Test Class for GlUt_ContentDocument
*******************************************************************************/

@isTest
//test data creation for GlUt_ContentDocument class
Public Class GlUt_ContentDocument_Test{
private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME = 'TestUser'; 
    private static String ACCOUNT_NAME = 'TestAccount'; 
    private static String CONTRACT_NAME_ONE ='TestContract';
    private static String BILL_NAME ='TestBill'; 
    private static String ASSET_LIB = 'Asset Library';
    private static String BILL_PDF = 'bill PDF ';
    private static String PDF_EXT = '.pdf';
    private static String TESTFILE = 'testfile';
/*******************************************************************
Purpose: method to create test data used by all USER_NAMEtest methods
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    @TestSetup
    Static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE ,USER_NAME ,null);
        Database.insert(objUser);
        
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNT_NAME);
        Database.insert(objAccount);
        
        BillCalculation__c objBillCalculation = GlUt_FactoryData_Test.createBillCalculation();
        Database.insert(objBillCalculation);
        
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(CONTRACT_NAME_ONE,objAccount);
//        objContract.BillCalculation__c = objBillCalculation.id;
        objContract.LastBillCalculationDate__c = system.Today();
        Database.insert(objContract);
        
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILL_NAME,objContract);
        Database.insert(objBill);
}        
/*******************************************************************
Purpose: Method to test getFolderId method
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void saveInWorkspace(){
        
        User objuser = [select id,UserName from user where isActive=true limit 1];
        Bill__c objBill = [select id from Bill__c limit 1];
        // save the XML as a content document and link it to the bill
        List<ContentWorkspace> folder = [Select Id,Name,DeveloperName,RootContentFolderId From ContentWorkspace Where Name =: ASSET_LIB];
        
        ContentVersion document = new ContentVersion(
                              Title = ASSET_LIB, 
                              VersionData =  Blob.valueOf(TESTFILE) ,
                              PathOnClient =  BILL_PDF + objBill.id + PDF_EXT 
                              );
        insert document;
        document = [select Id, Title,ContentDocumentId,PathOnClient from ContentVersion where Id = :document.Id];
        ContentDocumentLink link = new ContentDocumentLink(
                                  ContentDocumentId = document.ContentDocumentId, 
                                  LinkedEntityId = objBill.id, 
                                  ShareType = 'V' 
                                  );
        insert link;

        ContentWorkspaceDoc folderLink = new ContentWorkspaceDoc(
                                ContentWorkspaceId = folder[0].Id,
                                ContentDocumentId = document.ContentDocumentId
                                );
        insert folderLink;
        

        Bill__c objBillresult = [select id,(select Id, LinkedEntityId, ContentDocumentId, Title, FileType, ContentSize,FileExtension from AttachedContentDocuments) from Bill__c];    
    
        Id billId = objBill.id;
        system.runas(objUser){
            Test.startTest();
            GlUt_ContentDocument.saveLinkedDocument(objBill.id,ASSET_LIB,document.title,document.PathOnClient,Blob.valueOf(TESTFILE));
            GlUt_ContentDocument.saveLinkedDocument(objBill.id,null,document.PathOnClient,Blob.valueOf(TESTFILE));
            
            Test.stopTest();
            system.assertNotEquals(folderLink,null);
            system.assertEquals(folder[0].Name,ASSET_LIB);
        }
    
    }

    /*******************************************************************
    Purpose: Method to test the negative scenario
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    static testmethod void saveInWorkspace_negative(){

        User objuser = [select id,UserName from user where isActive=true limit 1];

        Bill__c objBill = [select id from Bill__c limit 1];
        Date billdate = system.today();
        BillingContract__c objcontract = [Select id from BillingContract__c where LastBillCalculationDate__c=:billdate Limit 1];
        // save the XML as a content document and link it to the bill
        List<ContentWorkspace> folder = [Select Id,Name,DeveloperName,RootContentFolderId From ContentWorkspace Where Name =: ASSET_LIB];

        ContentVersion document = new ContentVersion(
                              Title = ASSET_LIB, 
                              VersionData =  Blob.valueOf(TESTFILE) ,
                              PathOnClient =  BILL_PDF + objcontract.id + PDF_EXT 
                              );
        insert document;
        document = [select Id, Title,ContentDocumentId,PathOnClient from ContentVersion where Id = :document.Id];

        ContentDocumentLink link = new ContentDocumentLink(
                                  ContentDocumentId = document.ContentDocumentId, 
                                  LinkedEntityId = objcontract.id, 
                                  ShareType = 'V' 
                                  );
        insert link;

        ContentWorkspaceDoc folderLink = new ContentWorkspaceDoc(
                                ContentWorkspaceId = folder[0].Id,
                                ContentDocumentId = document.ContentDocumentId
                                );
        insert folderLink;

        Id conId = objcontract.id;
        system.runas(objUser){
          Test.startTest();
          GlUt_ContentDocument.saveLinkedDocument(objcontract.id,ASSET_LIB,document.title,document.PathOnClient,Blob.valueOf(TESTFILE));
          GlUt_ContentDocument.saveLinkedDocument(objcontract.id,null,document.PathOnClient,Blob.valueOf(TESTFILE));
          
          Test.stopTest();
          system.assertNotEquals(folderLink,null);
          system.assertEquals(folder[0].Name,ASSET_LIB);
            
        }


    }
}