/***************************************************************************************************
@author        Sudhir Kumar
@date          14-June-2018
@description:  This is test class for GlUt_BatchRequestQueueHandler
@group         TestClass
@revision:     
*******************************************************************************************************/

@isTest
public with sharing class GlUt_BatchRequestQueueHandler_Test {

    private static String USER_PROFILE            = 'System Administrator';
    private static String USERNAME                = 'TestBRQUser';
    private static String USERNAMECOMPLETE        =  USERNAME+ '@unitest.com';
    private static String  USEREMAIL              = 'sudhirkumar@echo-ms.com';
    private static String  BATCHPROCESSNAME       = 'Data Transfer XML';
    private static String  BATCHCLASS             = 'BlBt_BillDataTransferXMLExtract';
    private static Integer BATCHSIZE              =  50;
    
    @TestSetup
    static void createTestData(){
        //Create user record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USERNAME,null);
        Database.insert(objUser); 
        
        //Create batch process record 
        BatchProcess__c batpro = new BatchProcess__c();
        batpro.BatchClass__c = BATCHCLASS;
        batpro.BatchSize__c = BATCHSIZE;   
        insert batpro;
        
        List<BatchRequestQueue__c> brqList = new List<BatchRequestQueue__c>();
        List<BatchRequestQueue__c> brqList2 = new List<BatchRequestQueue__c>();
        
        for(Integer i=1; i<=200; i++) {
            BatchRequestQueue__c brq = new BatchRequestQueue__c();
            if(i<100){
                brq.Priority__c =  GlBt_Constants.BRQLOWPRIORITY ; 
            } else if(i<150){
                brq.Priority__c = GlBt_Constants.BRQMEDIUMPRIORITY ;
            } else if(i<175){
                brq.Priority__c = GlBt_Constants.BRQHIGHPRIORITY ;
            } else {
                brq.Priority__c = GlBt_Constants.BRQVERYHIGHPRIORITY ;
            }
            
            brq.Status__c = GlBt_Constants.BRQINITIALISEDSTATUS ;
            brq.BatchProcess__c = batpro.Id;
            brq.SendEmailNotification__c = true;
            brq.NotificationUser__c = objUser.id; 
            brqList.add(brq);
        }
        
        for(Integer i=1; i<=5; i++) {
            BatchRequestQueue__c brq = new BatchRequestQueue__c();
            brq.Priority__c = GlBt_Constants.BRQVERYHIGHPRIORITY ;
            brq.Status__c = GlBt_Constants.BRQINITIALISEDSTATUS ;
            brq.BatchProcess__c = batpro.Id;
            brq.SendEmailNotification__c = true;
            brq.NotificationUser__c = objUser.id; 
            brqList2.add(brq);
        }
        
        for(Integer i=1; i<=5; i++) {
            BatchRequestQueue__c brq = new BatchRequestQueue__c();
            brq.Priority__c = GlBt_Constants.BRQVERYHIGHPRIORITY ;
            brq.Status__c = GlBt_Constants.BRQLOADINGDSTATUS ;
            brq.BatchProcess__c = batpro.Id;
            brq.SendEmailNotification__c = true;
            brq.NotificationUser__c = objUser.id; 
            brqList2.add(brq);
        }
        brqList.addAll(brqList2) ;
        
        Database.insert(brqList) ;
    }
    
    /***************************************************************************************************
    @author        Sudhir Kumar
    @date          19-June-2018
    @description:  This is positive test method for doBatchLogic method
    @revision:     
    *******************************************************************************************************/
    static testmethod void testDoBatchLogic_positive() {
        User objUser = [SELECT Id, Name FROM User WHERE isActive = True AND Username = :USERNAMECOMPLETE LIMIT 1];
        BatchProcess__c batpro = [SELECT Id, Name, BatchClass__c, BatchSize__c FROM BatchProcess__c];   
        
        List<BatchRequestQueue__c> brqCompletedList = new List<BatchRequestQueue__c>();
        brqCompletedList = [SELECT Id, Status__c from BatchRequestQueue__c WHERE Status__c =: GlBt_Constants.BRQCOMPLETEDSTATUS] ;
        System.runAs(objUser) {
            system.assert(!brqCompletedList.isEmpty()) ;
        }
    }
    /***************************************************************************************************
    @author        Sudhir Kumar
    @date          07-Sep-2018
    @description:  This is negative test method for doBatchLogic method
    @revision:     
    *******************************************************************************************************/
    static testmethod void testDoBatchLogic_negative() {
        User objUser = [SELECT Id, Name FROM User WHERE isActive = True AND Username = :USERNAMECOMPLETE LIMIT 1];
        BatchProcess__c batpro = [SELECT Id, Name, BatchClass__c, BatchSize__c FROM BatchProcess__c];   
        
        List<BatchRequestQueue__c> brqErrorList = new List<BatchRequestQueue__c>();
        brqErrorList = [SELECT Id, Status__c from BatchRequestQueue__c WHERE Status__c =: GlBt_Constants.BRQERRORSSTATUS] ; 
        System.runAs(objUser) {
            system.assert(!brqErrorList.isEmpty()) ;
        }	
    }
    
    
}