/******************************************************************************
@author:      Echo: Swati Mathur
@date:        14 February 2018
@description: Test Class for GlUt_InstalmentHandler
@Revisions    AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/

@isTest
public class GlUt_BillTemplateHandler_Test {
    //Variable declaration start
    private static String USER_PROFILE = 'System Administrator';
    private static final String USER_FNAME= 'TestFName';
    private static final String USER_LNAME= 'TestLName';
    private static final string TESTPDF = 'Test PDF';
    private static final string TESTPDF1 = 'Test PDF New';
    private static String USER_NAME = 'TestUser';
    private static String USERNAMECOMPLETE = USER_NAME+ '@unitest.com'; 
    private static String ACCOUNTNAME = 'TestAccount';
    private static String BILLING_STREET ='Test Street';
    private static String BILLING_CITY = 'Test City';
    private static String BILLING_STATE = 'Test State';
    private static String BILLING_POSTCODE ='0000000';
    private static String BILLING_COUNTRY ='Test Country';
    private static String BILLNAME = 'Test Bill';
    private static integer LISTSIZE = 200;
    private static integer LISTSTART = 0;
    private static final String TITLE                   = 'test';
    private static final string HEROKUSECURITY = 'ABCSRESSGSTSEESDGS';
    
    // Trigger Specific variables
    private static Integer MAXDMLSTATEMENTS = 50;
    private static Integer MAXQUERIES       = 70;
    private static String LIMITCONST1       =  'Fewer than ';
    private static String LIMITCONST2       =  ' DML statements should have been executed : ';
    private static String LIMITCONST3       =  ' SOQL statements should have been executed : ';
    
    /*******************************************************************
    Purpose: Method is used to Test Setup in test class.
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/ 
    @TestSetup
    static void createTestData(){
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser); 
        
        //Create account record
        Account objAccount = GlUt_FactoryData_Test.CreateAccount(ACCOUNTNAME);
        Database.insert(objAccount);
        
        //Create contract record
        BillingContract__c objContract = GlUt_FactoryData_Test.CreateContract(' ',objAccount);
        objContract.BillingStreet__c=BILLING_STREET;
        objContract.BillingCity__c=BILLING_CITY;
        objContract.BillingState__c=BILLING_STATE;
        objContract.BillingPostalCode__c=BILLING_POSTCODE;
        objContract.BillingCountry__c=BILLING_COUNTRY;
        
        Database.insert(objContract);
        
         //Insert bill record
        Bill__c objBill = GlUt_FactoryData_Test.createBill(BILLNAME ,objContract);
        objBill.StartDate__c = system.today().addDays(-10);
        objBill.EndDate__c =system.today().addDays(-5);
        objBill.Account__c = objAccount.id; //AT-3174
        Database.insert(objBill);
        
        HerokuSecurity__c hSecurity = GlUt_FactoryData_Test.createHerokuSecurity(HEROKUSECURITY);
        DataBase.insert(hSecurity);
        
        ContentVersion objContentVersion = GlUt_FactoryData_Test.createContentVersion(objBill);
        objContentVersion.Title = TESTPDF1;
        Database.insert(objContentVersion);
        String BillTemplateLibraryName='';
        
        setEnvironmentSettingData();
        if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap != null && GlUt_CustomMetaDataUtility.customMetadataRecordsMap.keyset().size()  > 0){
            if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap.containsKey(GlUt_Constants.ENVIROMENTSETTINGEXPORTLIBRARYQUERY)){
               List<EnvironmentSettings__mdt>  mdts = (List<EnvironmentSettings__mdt>)GlUt_CustomMetaDataUtility.customMetadataRecordsMap.get(GlUt_Constants.ENVIROMENTSETTINGEXPORTLIBRARYQUERY);  
                if (mdts.size() == 1 && mdts[0].BillTemplateLibraryName__c != null) {
                    BillTemplateLibraryName = mdts[0].BillTemplateLibraryName__c;
                }
            }
        }
        
        // String BillTemplateLibraryName = [SELECT BillTemplateLibraryName__c FROM EnvironmentSettings__mdt LIMIT 1].BillTemplateLibraryName__c; 
        if(string.isNotBlank(BillTemplateLibraryName)){
            List<ContentWorkspace> lstContentWorkSpace = [SELECT Id, Name FROM ContentWorkspace where Name = :BillTemplateLibraryName LIMIT 1];
            if(lstContentWorkSpace != null && lstContentWorkSpace.isEmpty()){
                Id templateWorkspaceId = lstContentWorkSpace[0].Id;
                if(templateWorkspaceId != null){
                    ContentDocumentLink objContentDocumentLink = GlUt_FactoryData_Test.createContentDocumentLink(objContentVersion,objBill);
                    Database.insert(objContentDocumentLink);
                    
                    ContentDocumentLink newobjContentDocumentLink = objContentDocumentLink.clone();
                    newobjContentDocumentLink.ShareType = 'I';
                    newobjContentDocumentLink.linkedentityid = templateWorkspaceId; 
                    Database.insert(newobjContentDocumentLink);
                    Database.delete(objContentDocumentLink);    
                }
            }
        }
        List<BillTemplate__c> lstBillTemplate = new List<BillTemplate__c>();
        for(integer i=LISTSTART; i<LISTSIZE; i++){
            BillTemplate__c objBillTemplate = GlUt_FactoryData_Test.createBillTemplate(TESTPDF);
            objBillTemplate.FileName__c = TESTPDF;
            lstBillTemplate.add(objBillTemplate);
        }
        
        Database.insert(lstBillTemplate);
    }
    /*******************************************************************
    Purpose: Test bulk Insert for BillTemplate
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/ 
    static testmethod void insertBillTemplate_Bulk(){
        setEnvironmentSettingData();// Added By Echo: Dependra Singh - 12-03-2018
        Boolean isException = false;
        List<BillTemplate__c> lstBillTemplate = new List<BillTemplate__c>();
        for(integer i=LISTSTART; i<LISTSIZE; i++){
            BillTemplate__c objBillTemplate = GlUt_FactoryData_Test.createBillTemplate(TESTPDF1);
            objBillTemplate.FileName__c = TESTPDF1;
            lstBillTemplate.add(objBillTemplate);
        }
        try{
            Test.startTest();
            Database.insert(lstBillTemplate);
            Test.stopTest();
            isException = false;
        }catch(exception e){
            isException = true;            
        }
        System.assert(!isException);
    }
    
    /*******************************************************************
    Purpose: Test bulk Insert for Instalment
    Returns: void
    Throws [Exceptions]: N/A  
    ********************************************************************/ 
    static testmethod void updateBillTemplateNegative_Bulk(){
        setEnvironmentSettingData();// Added By Echo: Dependra Singh - 12-03-2018
        Boolean isException = false;
        //lstBillTemplate[0].FileName__c = TESTPDF1;
        List<BillTemplate__c> lstBillTemplateUpdate = new List<BillTemplate__c> ();
        List<BillTemplate__c> lstBillTemplate = [Select Id, FileName__c FROM BillTemplate__c LIMIT 200];
        for(integer i=0; i<lstBillTemplate.size(); i++){
            lstBillTemplate[i].FileName__c = TESTPDF + string.valueOf(i);
            lstBillTemplateUpdate.add(lstBillTemplate[i]);
        }
        try{
            Test.startTest();
            Database.update(lstBillTemplateUpdate);
            Test.stopTest();
        }catch(exception e){
            isException = true;            
        }
        System.assert(isException);
    }
    
    /******************************************************************************
    @author:      Echo: Dependra Singh
    @date:        13 Mar 2019
    @description: Enviroment Setting Custom meta data type Data
    *******************************************************************************/ 
    private static void setEnvironmentSettingData(){
        GlUt_CustomMetaDataUtility.setMetadata(GlUt_Constants.ENVIROMENTSETTINGBILLTEMPLATELIBRARYQUERY,(List<EnvironmentSettings__mdt>) JSON.deserialize( 
            '[{"' + GlUt_Constants.BILL_TEMPLATE_LIBRARY_NAME_FIELD + '":"' + GlUt_Constants.BILL_TEMPLATE_LIBRARY_NAME_VALUE + '"}]', List<EnvironmentSettings__mdt>.class )); 
    }
}