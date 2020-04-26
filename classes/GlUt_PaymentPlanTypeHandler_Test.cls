/******************************************************************************
@author    		Echo: Swati
@date      		22 Aug 2018
@description 	Test Class for GlUt_PaymentPlanTypeHandler
Comments by Dependra Singh
// Please incorporate the changes as mentioned below whenever you are updating it.
// (1)- If test class is for trigger, Kinldy test bulkified scenario.
*******************************************************************************/
@isTest
public class GlUt_PaymentPlanTypeHandler_Test {

    private static final String USER_PROFILE        = 'System Administrator';
    private static final String USER_NAME           = 'TestUser'; 
    private static final String USERNAMECOMPLETE    = USER_NAME+ '@unitest.com';
    private static final String ACCOUNT_NAME        = 'TestAccount';    
    private static final String CONTRACT_NAME1       = 'TestContract1';
    private static final String CONTRACT_NAME2       = 'TestContract2';   
    private static final String PAYMENTPLANTYPE_NAME1 = 'TestPaymentPlanType1';
    private static final String PAYMENTPLANTYPE_NAME2 = 'TestPaymentPlanType2';
    private static final String PAYMENTPLANTYPE_NAME3 = 'TestPaymentPlanType3';
    private static final Integer PLANAMOUNT          = 5000;
    private static final Integer NUMBEROFINSTALMENTS = 10;
    private static final String YEARLY              = 'Yearly';
    private static final String INSTALMENTPLAN      = 'Instalment Plan';
    private static final Integer MAXNUMOFINSTALMENTS = 12;
    
    
    /*******************************************************************
    @author:      Echo: Swati
    @date       	22 Aug 2018
    @param:       N/A
    @return:      void
    @description: method to create test data used by all test methods
    ********************************************************************/
    @TestSetup
    static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        Database.insert(objUser); 
        
        PaymentPlanType__c objPaymentPlanType = GlUt_FactoryData_Test.createPaymentPlanType(PAYMENTPLANTYPE_NAME1, YEARLY, MAXNUMOFINSTALMENTS);
        objPaymentPlanType.PlanType__c = INSTALMENTPLAN;
        objPaymentPlanType.SystemDefault__c = True;
        Database.insert(objPaymentPlanType);
    }
    
    /******************************************************************************
	@author:      Echo: Swati
    @date       	22 Aug 2018  
	@description: Test method for mainEntry Insert scenario
	*******************************************************************************/
    static testmethod void MainEntry_InsertScenario(){            
        User objUser = [SELECT Id,Name FROM USER WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        
        PaymentPlanType__c objPaymentPlanType = new PaymentPlanType__c(Name = PAYMENTPLANTYPE_NAME2,
                                                                       PaymentFrequency__c = YEARLY,
                                                                       MaximumNumberOfInstalments__c = MAXNUMOFINSTALMENTS);
        
        objPaymentPlanType.SystemDefault__c = True;
       
        boolean isException;
        System.runAs(objUser){ 
            try{           
                Test.startTest();
                Database.insert(objPaymentPlanType);
                Test.stopTest();                    
            }
            catch(exception e){
                isException = true;     
            }            
        }
        System.assert(isException == true); 
    } 
    
    /******************************************************************************
	@author:      Echo: Swati
    @date       	22 Aug 2018  
	@description: Test method for mainEntry Update scenario
	*******************************************************************************/
    static testmethod void MainEntry_UpdateScenario(){   
        
        User objUser = [SELECT Id,Name FROM USER WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        
        PaymentPlanType__c objPaymentPlanType1 = new PaymentPlanType__c(Name = PAYMENTPLANTYPE_NAME3,
                                                                       PaymentFrequency__c = YEARLY,
                                                                       MaximumNumberOfInstalments__c = MAXNUMOFINSTALMENTS);
        boolean isException;
        System.runAs(objUser){ 
            try{           
                Test.startTest();
                Database.insert(objPaymentPlanType1);
                objPaymentPlanType1.SystemDefault__c = True;
                Database.update(objPaymentPlanType1);
                Test.stopTest();                    
            }
            catch(exception e){
                isException = true;     
            }            
        }
        System.assert(isException == true);

    }
    
    /******************************************************************************
	@author:      Echo: Swati
    @date         23 Aug 2018  
	@description: Test method for mainEntry positive scenario
	*******************************************************************************/
    static testmethod void MainEntry_UpsertScenario(){            
        User objUser = [SELECT Id,Name FROM USER WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        
        List<PaymentPlanType__c> lstPPt = new List<PaymentPlanType__c>();               
        PaymentPlanType__c objPaymentPlanType1 = new PaymentPlanType__c(Name = PAYMENTPLANTYPE_NAME1,
                                                                       PaymentFrequency__c = YEARLY,
                                                                       MaximumNumberOfInstalments__c = MAXNUMOFINSTALMENTS);  
        lstPPt.add(objPaymentPlanType1);
        
        PaymentPlanType__c objPaymentPlanType2 = new PaymentPlanType__c(Name = PAYMENTPLANTYPE_NAME2,
                                                                       PaymentFrequency__c = YEARLY,
                                                                       MaximumNumberOfInstalments__c = MAXNUMOFINSTALMENTS);
       
        
        boolean isException;
        System.runAs(objUser){
            try{   
                Test.startTest(); 
                Database.insert(objPaymentPlanType2);
                objPaymentPlanType2.SystemDefault__c = True; 
                lstPPt.add(objPaymentPlanType2);
                
                Database.upsert(lstPPt);
                Test.stopTest();
            }
            catch(exception e){
                isException = true;     
            } 
        }
        System.assert(isException == true);
        
    }
    
    /******************************************************************************
	@author:      Echo: Swati
    @date         23 Aug 2018  
	@description: Test method for mainEntry Insert scenario
	*******************************************************************************/
    static testmethod void MainEntry_InsertListScenario(){            
        User objUser = [SELECT Id,Name FROM USER WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        
        List<PaymentPlanType__c> lstPPt = new List<PaymentPlanType__c>(); 
        PaymentPlanType__c objPaymentPlanType = new PaymentPlanType__c(Name = PAYMENTPLANTYPE_NAME1,
                                                                       PaymentFrequency__c = YEARLY,
                                                                       MaximumNumberOfInstalments__c = MAXNUMOFINSTALMENTS);
        
        objPaymentPlanType.SystemDefault__c = True;
        lstPPt.add(objPaymentPlanType);
        
        PaymentPlanType__c objPaymentPlanType1 = new PaymentPlanType__c(Name = PAYMENTPLANTYPE_NAME2,
                                                                       PaymentFrequency__c = YEARLY,
                                                                       MaximumNumberOfInstalments__c = MAXNUMOFINSTALMENTS);
        objPaymentPlanType1.SystemDefault__c = True;
        lstPPt.add(objPaymentPlanType1);
        
       
        boolean isException;
        System.runAs(objUser){ 
            try{           
                Test.startTest();
                Database.insert(lstPPt);
                Test.stopTest();                    
            }
            catch(exception e){
                isException = true;     
            }            
        }
        System.assert(isException == true); 
    }
    
    /******************************************************************************
	@author:      Echo: Swati
    @date         23 Aug 2018  
	@description: Test method for mainEntry Update scenario
	*******************************************************************************/
    static testmethod void MainEntry_UpdateListScenario(){   
        
        User objUser = [SELECT Id,Name FROM USER WHERE isActive=true AND USERNAME =: USERNAMECOMPLETE LIMIT 1]; 
        List<PaymentPlanType__c> lstPPt = new List<PaymentPlanType__c>(); 
        PaymentPlanType__c objPaymentPlanType1 = new PaymentPlanType__c(Name = PAYMENTPLANTYPE_NAME1,
                                                                       PaymentFrequency__c = YEARLY,
                                                                       MaximumNumberOfInstalments__c = MAXNUMOFINSTALMENTS);
        lstPPt.add(objPaymentPlanType1);
        
        PaymentPlanType__c objPaymentPlanType2 = new PaymentPlanType__c(Name = PAYMENTPLANTYPE_NAME2,
                                                                       PaymentFrequency__c = YEARLY,
                                                                       MaximumNumberOfInstalments__c = MAXNUMOFINSTALMENTS);
        lstPPt.add(objPaymentPlanType2);
        
        boolean isException;
        System.runAs(objUser){ 
            try{           
                Test.startTest();
                Database.insert(lstPPt);
                objPaymentPlanType1.SystemDefault__c = True;
                objPaymentPlanType2.SystemDefault__c = True;
                Database.update(lstPPt);
                Test.stopTest();                    
            }
            catch(exception e){
                isException = true;     
            }            
        }
        System.assert(isException == true);

    }
    
    
}