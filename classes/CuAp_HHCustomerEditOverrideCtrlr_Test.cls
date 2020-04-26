/******************************************************************************
@author:      Accenture: Satish Nair
@date:        26th September 2017
@description: Test Class for CuAp_HHCustomerEditOverrideCtrlr
Revision(s):  Shivangi Gaur -- 14-Dec-2017 -- Updated test methods as per latest 
                                              changes done to CuAp_HHCustomerEditController.
              Shivangi Gaur -- 21-12-2017 -- Updated class name as per naming standards.
              Shivangi Gaur -- 22-12-2017 -- Incorporated review comments on AT-439 dated 21-12-2017..
@Revision        AT-3985, Tarun, modified class name as per security reviews
*******************************************************************************/

@isTest
public class CuAp_HHCustomerEditOverrideCtrlr_Test{

private static string HOUNSEHOLDACCOUNT ='Household Account';
private static string HOUNSEHOLDCONTACT ='Household Contact';
private static string SYSADMIN ='System Administrator';
private static string USERNAME ='TestUser333';
private static string TESTACC ='TestAccount';
private static string TESTFNAME ='TestFirstName';
private static string TESTLNAME ='TestLastName';
private static string USERNAMECOMPLETE = USERNAME+ '@unitest.com';
private static string TESTRECTYPE ='Test Record Type';
    
/******************************************************************************
@author:      Accenture: Satish Nair
@date:        26th September 2017
@description: Test data setup method
*******************************************************************************/
    @TestSetup
    static void createTestData(){
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(HOUNSEHOLDACCOUNT).getRecordTypeId();
        Id contRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(HOUNSEHOLDCONTACT).getRecordTypeId();

        User objUser = GlUt_FactoryData_Test.createUser(SYSADMIN,USERNAME,null);
        Database.insert(objUser); 
        
        Account objAccount = GlUt_FactoryData_Test.createAccount(TESTACC);
        objAccount.recordTypeId = accRecordTypeId;
        Database.insert(objAccount);
        
        Contact con = GlUt_FactoryData_Test.createContact(TESTFNAME,TESTLNAME); 
        con.recordTypeId = contRecordTypeId;
        Database.insert(con);
         
    }
/******************************************************************************
@author:      Accenture: Satish Nair
@date:        26th September 2017
@description: Test method for getHHAccountRecordTypeName positive scenario.
*******************************************************************************/
    static testmethod void getHHAccountRecordTypeName_Positive(){
        
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        
        Account acc = [Select id,name,Recordtype.Name from Account where name=:TESTACC Limit 1];
        Contact con = [Select id,name from Contact where FirstName=:TESTFNAME Limit 1];
        
        System.runAs(objUser){
            
            Test.startTest();
            String recNameAcc = CuAp_HHCustomerEditOverrideCtrlr.getHHAccountRecordTypeName(acc.id);
            CuAp_HHCustomerEditOverrideCtrlr.recTypeName = null;
            String recNameCon = CuAp_HHCustomerEditOverrideCtrlr.getHHAccountRecordTypeName(con.id);
            Test.stopTest();
            
            system.assert(recNameAcc != null);
            system.assertEquals(recNameAcc,HOUNSEHOLDACCOUNT);
            
            system.assert(recNameCon != null);
            system.assertEquals(recNameCon,HOUNSEHOLDCONTACT);
        }
        
 }
/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        14 December 2017
@description: Test method for getHHAccountRecordTypeName negative scenario.
*******************************************************************************/
    static testmethod void getHHAccountRecordTypeName_Negative(){
        
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];        
        
        System.runAs(objUser){
            
            Test.startTest();           
            String recName = CuAp_HHCustomerEditOverrideCtrlr.getHHAccountRecordTypeName(objUser.id);          
            Test.stopTest();
            
            //Assert to check no record type name is received
            system.assertEquals(recName,null);
        }        
    }
/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        22 December 2017
@description: Test method for getHHAccountRecordTypeName negative scenario where 
              null record id is passed as parameter to method.
*******************************************************************************/
    static testmethod void getHHAccountRecordTypeNameNullParameter_Negative(){
        
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];        
        String recName;
        boolean isException = false;
        
        System.runAs(objUser){
            
            Test.startTest();
            try{
                recName = CuAp_HHCustomerEditOverrideCtrlr.getHHAccountRecordTypeName(null);
            }
            catch(Exception exc){
                System.assert(exc.getMessage() != null);
                isException = true;
            }          
            Test.stopTest();
            
            //Assert to check no record type name is received
            system.assertEquals(recName, null);
            system.assertEquals(isException,true);
        }        
    }
/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        22 December 2017
@description: Test method for getHHAccountRecordTypeName negative scenario where 
              recTypeName is already set.
*******************************************************************************/
    static testmethod void getHHAccountRecordTypeNameNotNull_Negative(){
        
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        Account acc = [Select id,name,Recordtype.Name from Account where name=:TESTACC Limit 1];        
        CuAp_HHCustomerEditOverrideCtrlr.recTypeName = TESTRECTYPE;
        boolean isException = false;
        
        System.runAs(objUser){
            
            Test.startTest();
            String recName = CuAp_HHCustomerEditOverrideCtrlr.getHHAccountRecordTypeName(acc.id);
            Test.stopTest();
            
            //Assert to check recTypeName is not updated
            system.assertEquals(recName,TESTRECTYPE);
            system.assertNotEquals(recName,HOUNSEHOLDACCOUNT);
        }        
    }
}