/******************************************************************************
@author:      Accenture: Satish Nair
@date:        25th September 2017
@description: Test Class for CuAp_HHCustomerCtrlr
Revision(s):  Shivangi Gaur -- 14-Dec-2017 -- Updated test methods as per changes 
                                              made to CuAp_HHCustomerCtrlr.
              Shivangi Gaur -- 21-12-2017 -- Updated class name as per naming convention.
			  Neha Rajput- Rename test class name as CuAp_HHCustomerCtrlr class name updated as 
CuAp_HHCustomerPageCtrlr //AT-3827
*******************************************************************************/

@isTest
public class CuAp_HHCustomerPageCtrlr_Test{  //AT-3827

private static String HOUNSEHOLDACCOUNT ='Household Account';
private static String HOUNSEHOLDCONTACT ='Household Contact';
private static String NONHOUNSEHOLDACCOUNT ='Non-Household Account';
private static String SYSADMIN ='System Administrator';
private static String USERNAME ='TestUser111';
private static String TESTACC ='Mrs. Test Acc 777';
private static String TESTFNAME ='Test';
private static String TESTLNAME ='Acc 777';
private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
private static String MOBILEDATA = '9999888899';
private static String SALUTATIONVAL = 'Mrs.';
private static String PREFERREDCONVAL = 'Letter';
    
/******************************************************************************
@author:      Accenture: Satish Nair
@date:        25th September 2017
@description: Test data setup method
*******************************************************************************/
    @TestSetup
    Static void createTestData(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(HOUNSEHOLDACCOUNT).getRecordTypeId();

        User objUser = GlUt_FactoryData_Test.createUser(SYSADMIN,USERNAME,null);
        Database.insert(objUser); 
        
        Account objAccount = GlUt_FactoryData_Test.createAccount(TESTACC);
        objAccount.recordTypeId = accRecordTypeId;
        objAccount.Mobile__c = MOBILEDATA;
        Database.insert(objAccount);
        
        Contact con = GlUt_FactoryData_Test.createContact(TESTFNAME,TESTLNAME); 
        con.AccountId = objAccount.Id;
        Database.insert(con);
         
    }
    
/******************************************************************************
@author:      Accenture: Satish Nair
@date:        25th September 2017
@description: Test method for getHHAccount method positive scenario
*******************************************************************************/
    static testmethod void getHHAccount_Positive(){
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        
        Account accObj = [Select id,name,Recordtype.Name from Account where name=:TESTACC limit 1];
        Contact conObj = [Select id,accountId,FirstName from Contact where FirstName=:TESTFNAME and accountId =:accObj.Id limit 1];
        
        System.runAs(objUser){
            
            Test.startTest();
            BlAp_CombinedRecord combinedRecordAcc = CuAp_HHCustomerPageCtrlr.getHHAccount(accObj.id);  //AT-3827
            BlAp_CombinedRecord combinedRecordCon = CuAp_HHCustomerPageCtrlr.getHHAccount(conObj.id);  //AT-3827
            
            Test.stopTest();
            
            system.assert(combinedRecordAcc != null);
            system.assert(combinedRecordCon != null);
            system.assertEquals(combinedRecordAcc.uniqueId,accObj.id);
            system.assertEquals(combinedRecordCon.uniqueId,conObj.id);
        }
    }
/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        14 December 2017
@description: Test method for getHHAccount method negative scenario
*******************************************************************************/
    static testmethod void getHHAccount_Negative(){
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        
        System.runAs(objUser){
            
            Test.startTest();
            BlAp_CombinedRecord combinedRec = CuAp_HHCustomerPageCtrlr.getHHAccount(objUser.id);
            Test.stopTest();
            
            system.assertEquals(combinedRec.objectMap.get(GlUt_Constants.OBJACCOUNT), null);  //AT-3827
            system.assertEquals(combinedRec.objectMap.get(GlUt_Constants.OBJCONTACT), null);   //AT-3827
        }
    }   
/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        14 December 2017
@description: Test method for emptyHHAccount method positive scenario
*******************************************************************************/
    static testmethod void emptyHHAccount_Positive(){
        
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        
        System.runAs(objUser){
            
            Test.startTest();
            BlAp_CombinedRecord combinedRecordAcc = CuAp_HHCustomerPageCtrlr.getHHAccount(null);  //AT-3827
            Test.stopTest();
            
            system.assert(combinedRecordAcc != null);
            system.assert(combinedRecordAcc.objectMap.get(GlUt_Constants.OBJACCOUNT) != null);   
            system.assert(combinedRecordAcc.objectMap.get(GlUt_Constants.OBJCONTACT) != null); 
        }
    }
/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        14 December 2017
@description: Test method for preferredContactMethod method positive scenario
*******************************************************************************/
    static testmethod void preferredContactMethod_Positive(){
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        boolean isExist = false;
        
        System.runAs(objUser){
            
            Test.startTest();
            List<String> lstValues = CuAp_HHCustomerPageCtrlr.preferredContactMethod();
            Test.stopTest();
            
            system.assertEquals(lstValues.size()>0,true);
            Set<String> setValues = new Set<String>(lstValues);
            if(setValues.contains(PREFERREDCONVAL)){
                isExist = true;
            }
            System.assertEquals(isExist,true);
        }
    }
/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        14 December 2017
@description: Test method for salutationValues method positive scenario
*******************************************************************************/
    static testmethod void salutationValues_Positive(){
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        boolean isExist = false;
        
        System.runAs(objUser){
            
            Test.startTest();
            List<String> lstValues = CuAp_HHCustomerPageCtrlr.salutationValues();   //AT-3827
            Test.stopTest();
            
            system.assertEquals(lstValues.size()>0,true);
            Set<String> setValues = new Set<String>(lstValues);
            if(setValues.contains(SALUTATIONVAL)){
                isExist = true;
            }
            System.assertEquals(isExist,true);
        }
    }
/******************************************************************************
@author:      Accenture: Manish Singh
@date:        16 Oct 2017
@description: Test method for saveHHAccount positive scenario
*******************************************************************************/
    static testmethod void saveHHAccount_Positive(){
        
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        
        Account accObj = [Select id,name,Recordtype.Name from Account where name=:TESTACC limit 1];
        Contact conObj = [Select id,accountId,FirstName from Contact where FirstName=:TESTFNAME and accountId =:accObj.Id limit 1];
        
        System.runAs(objUser){
            
            Test.startTest();
            String retValAcc = CuAp_HHCustomerPageCtrlr.saveHHAccount(conObj ,accObj,accObj.id,false );  //AT-3827
            String retValCon = CuAp_HHCustomerPageCtrlr.saveHHAccount(conObj ,accObj,conObj.id,false );   //AT-3827
            Test.stopTest();
            
            System.assertNotEquals(retValAcc , null);
            System.assertEquals(retValAcc.startsWith(CuAp_Constants.ACCURLPREFIX ) , true);
            System.assertNotEquals(retValCon , null);
            System.assertEquals(retValCon.startsWith(CuAp_Constants.ACCURLPREFIX ) , true);
            
        }
    }
/******************************************************************************
@author:      Accenture: Shivangi Gaur
@date:        14 December 2017
@description: Test method for saveHHAccount negative scenario
*******************************************************************************/
    static testmethod void saveHHAccount_Negative(){
        User objUser =[select id,name from user where isActive=true and username =: USERNAMECOMPLETE limit 1];
        
        Account accObj = GlUt_FactoryData_Test.createAccount(TESTACC);
        accObj.Mobile__c = MOBILEDATA;
        Contact conObj = GlUt_FactoryData_Test.createContact(TESTFNAME,TESTLNAME);
        conObj.Salutation = SALUTATIONVAL;
        
        System.runAs(objUser){
            
            Test.startTest();           
            String retValDup = CuAp_HHCustomerPageCtrlr.saveHHAccount(conObj ,accObj,null,false );   //AT-3827
            String retValDupSave = CuAp_HHCustomerPageCtrlr.saveHHAccount(conObj ,accObj,null,true );   //AT-3827
            String retValError = CuAp_HHCustomerPageCtrlr.saveHHAccount(conObj ,accObj,null,false );    //AT-3827
            Test.stopTest();
            
            System.assertEquals(retValDup.contains(CuAp_Constants.DUPLICATERESP) , true);
            System.assertNotEquals(retValDupSave , null);
            System.assertEquals(retValDupSave.startsWith(CuAp_Constants.ACCURLPREFIX ) , true);
            System.assertNotEquals(retValError.startsWith(CuAp_Constants.ACCURLPREFIX ) , true);
            
        }
    }   
}