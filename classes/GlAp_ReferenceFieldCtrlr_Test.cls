/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        25 September 2017
@description: Test Class for GlAp_ReferenceFieldCtrlr
Revision(s):  Shivangi Gaur -- 04-Jan-2018 -- Incorporated review comments on AT-450 
                                              dated 03 Jan 2018.
*******************************************************************************/
@isTest
public class GlAp_ReferenceFieldCtrlr_Test{

    //Variable declaration start

    private static string USERPROFILENAME = 'System Administrator';
    private static string USERNAME = 'TestUser';
    private static string MANAGERID = Null;
    private static string ACCNAME = 'TestAccount';
    private static string SEARCHKEYWORD = '%' + 'Test'+ '%';     
    private static string SOBJECTTYPE = 'Account';
    private static string FIELDNAME = 'AccountId';
    private static string FIELDNAME2 = 'Title';
    private static string PARENTOBJECT = 'Contact';
    private static string CONFIRSTNAME = 'Test';
    private static string CONLASTNAME = 'Contact101';
    private static string USERNAMECOMPLETE = USERNAME+ '@unitest.com';
    private static string SOQLINJECTIONTEST = ' OR username LIKE \'% ';
    private static string EXCEPTIONMSG = 'Invalid id';

    //Variable declaration end

/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        25 September 2017
@description: Test data setup method
*******************************************************************************/
    @TestSetup
    static void createTestData(){

        User objUser = GlUt_FactoryData_Test.createUser(USERPROFILENAME, USERNAME , MANAGERID);
        Database.insert(objUser);

        Account objAccount = GlUt_FactoryData_Test.createAccount(ACCNAME);
        Database.insert(objAccount);

        //Create contact record
        Contact objCon = GlUt_FactoryData_Test.createContact(CONFIRSTNAME, CONLASTNAME );
        objCon.AccountId = objAccount.id;
        Database.insert(objCon);        

    }

/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        25 September 2017
@description: Test method for fetchRecords method positive scenario.
*******************************************************************************/
    static testmethod void fetchRecords_Positive(){

        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];

        //Query Account record created in test setup data method
        Account objAccount = [Select id,name from Account where name LIKE :SEARCHKEYWORD];

        //Run test class in user context
        System.runAs(objUser){

            Test.startTest();  
            List<sObject> newAcc = GlAp_ReferenceFieldCtrlr.fetchRecords(objAccount.name,SOBJECTTYPE);
            Test.stopTest();
            
            System.assert(newAcc.size()>0);
        }
    }

/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        11 December 2017
@description: Test method for fetchRecords method Negative scenario.
*******************************************************************************/
    static testmethod void fetchRecords_Negative(){

        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];

        //Query Account record created in test setup data method
        Account objAccount = [Select id,name from Account where name LIKE :SEARCHKEYWORD limit 1 ];

        delete objAccount;

        //Run test class in user context
        System.runAs(objUser){

            Test.startTest();  
            List<sObject> newAcc = GlAp_ReferenceFieldCtrlr.fetchRecords(objUser.name,SOBJECTTYPE);
            Test.stopTest();
            
            System.assertEquals(newAcc.size(),0);
        }
    }

/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        10th October 2017
@description: Test method for getObjectType method positive scenario.
*******************************************************************************/        
    static testmethod void getObjectType_Positive(){

        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];

        //Run test class in user context
        System.runAs(objUser){
            //Query Account record created in test setup data method
            Account acc = [Select id,name from Account where name =:ACCNAME  Limit 1];

            //Query Contact record.
            Contact con = [Select id,accountId from Contact Limit 1];

            Test.startTest();
            GlAp_ReferenceFieldCtrlr.getObjectType(con.id);
            Test.stopTest();
            
            System.assertEquals(con.accountId, acc.id);
        }
    }

/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        10th October 2017
@description: Test method for getObjectTypeForField method positive scenario.
*******************************************************************************/                    
    static testmethod void getObjectTypeForField_Positive(){

        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];

        //query a contact record where for accountId field where parent object is Account.
        Contact con = [Select id,accountId from Contact Limit 1];

        //Run test class in user context
        System.runAs(objUser){

            Test.startTest();
            string objName = GlAp_ReferenceFieldCtrlr.getObjectTypeForField(FIELDNAME, PARENTOBJECT);
            Test.stopTest(); 
            
            System.assertEquals(SOBJECTTYPE ,objName ); 
        }
    }          

/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        12th December 2017
@description: Test method for getObjectTypeForField method Negative scenario.
*******************************************************************************/                    
    static testmethod void getObjectTypeForField_Negative(){

        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];

        //Query Account record created in test setup data method
        Account acc = [Select id,name from Account where name =:ACCNAME  Limit 1];

        //Run test class in user context
        System.runAs(objUser){

            Test.startTest();
            string objName = GlAp_ReferenceFieldCtrlr.getObjectTypeForField(FIELDNAME2, PARENTOBJECT);
            Test.stopTest();
            
            System.assertEquals(objName, ''); 
        }
    }          

/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        10th October 2017
@description: Test method for getRecordName methods positive scenario.
*******************************************************************************/            
    static testmethod void getRecordName_Positive(){

        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];

        //Query Contact record.
        Contact con = [Select id,Name,accountId from Contact Limit 1];

        //Run test class in user context
        System.runAs(objUser){

            Test.startTest();
            String recName = GlAp_ReferenceFieldCtrlr.getRecordName(con.id);
            Test.stopTest();
            
            System.assertEquals(recName,con.Name);

        }
    }

/******************************************************************************
@author:      Accenture: Vandana Anshu
@date:        12th December 2017
@description: Test method for getRecordName methods Negative scenario.
*******************************************************************************/            
    static testmethod void getRecordName_Negative(){

        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];

        //Query Contact record.
        Contact con = [Select id,FirstName,accountId from Contact Limit 1];

        //Run test class in user context
        System.runAs(objUser){

            Test.startTest();
            String recName = GlAp_ReferenceFieldCtrlr.getRecordName(null);
            Test.stopTest();

            System.assertEquals(recName,'');

        }
    }
/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        04 January 2018
@description: Test method for getRecordName method SOQL injection check.
*******************************************************************************/            
    static testmethod void getRecordNameSOQLInjection_Negative(){

        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];

        boolean isException = false;
        
        //Run test class in user context
        System.runAs(objUser){
			String recName;
            Test.startTest();
            try{
                recName = GlAp_ReferenceFieldCtrlr.getRecordName(objUser.id+SOQLINJECTIONTEST);
            }
            catch(Exception exc){
                isException = true;
                System.assertEquals(exc.getMessage().contains(EXCEPTIONMSG),true);
            }            
            Test.stopTest();

            System.assertEquals(recName,'');

        }
    }
}