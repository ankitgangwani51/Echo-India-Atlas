/******************************************************************************
@author:      Echo: Swati
@date:        20-07-2018
@description: Test Class for LoAp_SupplyPointBandChangeCtrlr
*******************************************************************************/
@isTest
public class LoAp_SupplyPointBandChangeCtrlr_Test {
    
    //Variable declaration start    
    private static String USER_PROFILE ='System Administrator';
    private static String USER_NAME ='FN123LN123'; 
    private static final String USER_FNAME= 'FN123';
    private static final String USER_LNAME= 'LN123';
    private static final String MONTHLY = 'Monthly';    
    private static String LOCATION_NAME ='A99 9AA';    
    private static String YES ='yes';
    private static String MEASURED = 'Monthly';
    private static final String SP_USAGE_TYPE = 'SupplyPointUsageType';
    //Variable declaration end

    /******************************************************************************
    @author:    Echo: Swati
    @date:      04-06-2018 
    @description: Test data setup method
    *******************************************************************************/
    @TestSetup
    Static void createTestData(){
        
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);     
        
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SP_USAGE_TYPE);
        Database.insert(objSupplyPointUsageType);
        
        Location__c objLocation = GlUt_FactoryData_Test.CreateLocation(LOCATION_NAME);
        Database.insert(objLocation);
        
        SupplyPoint__c  objSupplyPoint = GlUt_FactoryData_Test.CreateSupplyPoint(objLocation, objSupplyPointUsageType);
        objSupplyPoint.Measured__c= True; // AT-3174 
        Database.insert(objSupplyPoint);
        
        SupplyPointBand__c objSupplyPointBand = GlUt_FactoryData_Test.createSupplyPointBand(objSupplyPoint);
        objSupplyPointBand.SupplyPoint__c = objSupplyPoint.Id;
        objSupplyPointBand.EndDate__c = system.today() +30;
        Database.insert(objSupplyPointBand);
            
    }
    
    /******************************************************************************
    @author:    Echo: Swati
    @date:      20-07-2018
    @description: Test method for retrieveSupplyPointBandFields() method 
    *******************************************************************************/    
    static testmethod void retrieveSupplyPointBandFields_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
                
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            List<List<GlAp_FieldProps>> returnList = LoAp_SupplyPointBandChangeCtrlr.retrieveSupplyPointBandFields();
            Test.stopTest();            
            System.assertNotEquals(returnList, null);              
        }
    }
    
    /******************************************************************************
    @author:    Echo: Swati
    @date:      20-07-2018
    @description: Test method for fetchSupplyPointBandData() method 
    *******************************************************************************/    
    static testmethod void fetchSupplyPointBandData_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        SupplyPoint__c objSupplyPoint = [Select id,name from SupplyPoint__c];
        //Run test class in user context
        System.runAs(objUser){             
            Test.startTest();
            SupplyPointBand__c objSPBand = LoAp_SupplyPointBandChangeCtrlr.fetchSupplyPointBandData(objSupplyPoint.Id);
            Test.stopTest(); 
            System.assertNotEquals(objSPBand, null);                        
        }
        
    }
    
    /******************************************************************************
    @author:    Echo: Swati
    @date:      20-07-2018
    @description: Test method for fetchSupplyPointBandData() method 
    *******************************************************************************/    
    static testmethod void fetchSupplyPointBandData_Negative(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        SupplyPoint__c objSupplyPoint = [Select id,name from SupplyPoint__c];
                
        //Run test class in user context
        System.runAs(objUser){             
            Test.startTest();
            SupplyPointBand__c objSPBand = LoAp_SupplyPointBandChangeCtrlr.fetchSupplyPointBandData(objUser.Id);
            Test.stopTest();  
            System.assertEquals(objSPBand, null);
        }
    }
    
    /******************************************************************************
    @author:    Echo: Swati
    @date:      20-07-2018
    @description: Test method for saveSupplyPointBandRecord() method 
    *******************************************************************************/    
    static testmethod void saveSupplyPointBandRecord_Positive(){
        
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        SupplyPoint__c objSupplyPoint = [Select id,Name from SupplyPoint__c];
        SupplyPointBand__c oldSPBand = [Select id,EndDate__c,StartDate__c from SupplyPointBand__c];
        
        SupplyPointBand__c newSPBand = new SupplyPointBand__c();
        newSPBand.StartDate__c = System.today();
        //Run test class in user context
        System.runAs(objUser){ 
            
            Test.startTest();
            Id newSPBandId = LoAp_SupplyPointBandChangeCtrlr.saveSupplyPointBandRecord(newSPBand, oldSPBand, objSupplyPoint.Id);
            Test.stopTest();            
            System.assertNotEquals(newSPBandId, null);
        }       
    }
    
    /******************************************************************************
    @author:    Echo: Swati
    @date:      20-07-2018
    @description: Test method for saveSupplyPointBandRecord() method 
    *******************************************************************************/    
    static testmethod void saveSupplyPointBandRecord_Negative(){
        
        boolean isException;
        //Query user record created in test setup data method
        User objUser = [Select id,name from user where isActive=true limit 1];
        SupplyPoint__c objSupplyPoint = [Select id,Name from SupplyPoint__c];
        SupplyPointBand__c oldSPBand = [Select id,EndDate__c from SupplyPointBand__c];
        
        SupplyPointBand__c newSPBand = new SupplyPointBand__c();
        newSPBand.StartDate__c = System.today();
        //Run test class in user context
        System.runAs(objUser){ 
            try{           
                Test.startTest();
                Id newSPBandId = LoAp_SupplyPointBandChangeCtrlr.saveSupplyPointBandRecord(newSPBand, oldSPBand, objUser.Id);
                Test.stopTest();                      
            }
            catch(exception e){
                isException = true;     
            }            
        }
        System.assert(isException == true);
    }

}