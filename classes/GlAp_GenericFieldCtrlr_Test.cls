/******************************************************************************
@author:      Accenture: Satish Nair
@date:        27th September 2017
@description: Test class for GlAp_GenericFieldCtrlr
Revision(s):  Shivangi Gaur -- 04-Jan-2018 -- Incorporated review comments on AT-449 
                                              dated 03 Jan 2018.
*******************************************************************************/

@isTest
public class GlAp_GenericFieldCtrlr_Test{
    
    private static String SYSADM ='System Administrator';
    private static String TESTACC ='TestAccount';
    private static String TESTFNAME ='TestFirstName';
    private static String TESTLNAME ='TestLastName';
    private static String HOUSEHOLDACCOUNT = 'Household Account';
    private static String NULLREC = '';
    private static String USER_NAME ='TestUser123'; 
    private static String USERNAMECOMPLETE = USER_NAME+ '@unitest.com'; 
    
/******************************************************************************
@author:      Accenture: Satish Nair
@date:        27th September 2017
@description: Test data setup method
*******************************************************************************/
    @TestSetup
    static void createTestData(){
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(HOUSEHOLDACCOUNT).getRecordTypeId();
        
        User objUser = GlUt_FactoryData_Test.createUser(SYSADM,USER_NAME,null);
        Database.insert(objUser); 
        
        Account objAccount = GlUt_FactoryData_Test.createAccount(TESTACC);
        objAccount.recordTypeId = accRecordTypeId;
        Database.insert(objAccount);
        
        Contact con = GlUt_FactoryData_Test.createContact(TESTFNAME,TESTLNAME); 
        Database.insert(con);
        
    }
    
/******************************************************************************
@author:      Accenture: Satish Nair
@date:        25th September 2017
@description: Test method for getting the Object Type from ID
*******************************************************************************/
    static testmethod void testGetRecordName_Positive(){
        
        User objUser =[select id,name from user where isActive=true and Profile.Name=:SYSADM and username =: USERNAMECOMPLETE limit 1];
        List<Account> acc = [Select id,name,Recordtype.Name from Account where name=:TESTACC Limit 1];
        
        System.runAs(objUser){
            
            Test.startTest();
            String recName = GlAp_GenericFieldCtrlr.getRecordName(acc[0].Id);
            Test.stopTest();
            
            System.assertEquals(recName,acc[0].Name);
        }
    } 

/******************************************************************************
@author:      Accenture: Satish Nair
@date:        5th December 2017
@description: Test method for getting the Object Type from ID (negative scenario)
*******************************************************************************/
    static testmethod void testGetRecordName_Negative(){
        
        User objUser =[select id,name from user where isActive=true and Profile.Name=:SYSADM and username =: USERNAMECOMPLETE limit 1];
        
        System.runAs(objUser){
            
            Test.startTest();
            String recordName = GlAp_GenericFieldCtrlr.getRecordName('');
            Test.stopTest();
            
            System.assertEquals(recordName,NULLREC);
        }
    }

/******************************************************************************
@author:      Accenture: Satish Nair
@date:        5th December 2017
@description: Test method for getting the Object Type from ID (negative scenario)
*******************************************************************************/
    static testmethod void testGetRecordNameNull_Negative(){
        
        User objUser =[select id,name from user where isActive=true and Profile.Name=:SYSADM and username =: USERNAMECOMPLETE limit 1];
        String recordName;
        boolean isException = false;

        System.runAs(objUser){
            
            Test.startTest();
            recordName = GlAp_GenericFieldCtrlr.getRecordName(null);
            Test.stopTest();
            
            System.assertEquals(recordName,NULLREC);                
        }
    }
}