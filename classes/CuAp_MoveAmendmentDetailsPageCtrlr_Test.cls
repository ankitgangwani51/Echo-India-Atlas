/******************************************************************************
@author:     Swati Mathur
@date:        17-Sep 2018
@description: Test Class for CuAp_MoveAmendmentDetailsPageCtrlr
*******************************************************************************/

    @isTest
    Public Class CuAp_MoveAmendmentDetailsPageCtrlr_Test{
        
        //Variable declaration start
        
        private static String PROFILENAME = 'System Administrator';
        private static String USERNAME = 'TestUser222';
        private static String ACCOUNTNAME = 'TestAccount';
        private static String LOCATIONNAME ='A99 9AA';
        private static String LOCATIONSUBTYPE = 'Detached';
        private static String STREET = 'teststreet';
        private static String USERNAMECOMPLETE = USERNAME+ '@unitest.com';
        
        //Variable declaration end

    /******************************************************************************
    @author:     Swati Mathur
    @date:       17-Sep 2018
    @description: Test data setup method
    *******************************************************************************/
        @TestSetup
        static void createTestData(){
            //Create user record
            User objUser = GlUt_FactoryData_Test.createUser(PROFILENAME,USERNAME,null);
            Database.insert(objUser); 

            //Create account record
            Account objAccount = GlUt_FactoryData_Test.createAccount(ACCOUNTNAME);
            Database.insert(objAccount);
            
            //Create location record        
            Location__c objLocation = GlUt_FactoryData_Test.createLocation(LOCATIONNAME);
            objLocation.LocationSubType__c=LOCATIONSUBTYPE ; 
            objLocation.Street__c =STREET ;
            Database.insert(objLocation);
            
            //Create location occupant record       
            LocationOccupant__c locOccObj1 = GlUt_FactoryData_Test.createLocationOccupant(objAccount,objLocation);
            locOccObj1.StartDate__c = system.today()-1;
            locOccObj1.EndDate__c = system.today()+1;
            Database.insert(locOccObj1);
            
            //Create location occupant record       
            LocationOccupant__c locOccObj2 = GlUt_FactoryData_Test.createLocationOccupant(objAccount,objLocation);
            locOccObj2.StartDate__c = system.today()-10;
            locOccObj2.EndDate__c = system.today()-2;
            Database.insert(locOccObj2);
            
            //Create location occupant record       
            LocationOccupant__c locOccObj3 = GlUt_FactoryData_Test.createLocationOccupant(objAccount,objLocation);
            locOccObj3.StartDate__c = system.today()+2;
            locOccObj3.EndDate__c = system.today()+10;
            Database.insert(locOccObj3);

        }
        
    /******************************************************************************
    @author:      Swati Mathur
    @date:        17-Sep 2018
    @description: Test method for retrieveLocationPropDetails() method
    *******************************************************************************/
        static testmethod void retrieveLocationPropDetails_Positive(){
            
            //Query user record created in test setup data method
            User objUser =[Select Id,Name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
            Location__c objLocation =[Select Id,Name from Location__c];
            LocationOccupant__c locOccObj =[Select Id,Name,StartDate__c,EndDate__c from LocationOccupant__c where StartDate__c = :system.today()-1];
            //Run test class in user context
            system.runas(objUser){
                
                Test.startTest();
                CuAp_MoveAmendmentDetailsPageCtrlr.ContainerWrapper getLocAndLocOccDetails = CuAp_MoveAmendmentDetailsPageCtrlr.getLocAndLocOccDetails(objLocation.Id, locOccObj);
                Test.stopTest();
                System.assertNotEquals(getLocAndLocOccDetails,null);
                System.assertNotEquals(getLocAndLocOccDetails.twoColFormattedList.size(),0);
                System.assertNotEquals(getLocAndLocOccDetails.prevOccStartDate,null);
                System.assertNotEquals(getLocAndLocOccDetails.nextOccEndDate,null);
               
            }
        }
    /******************************************************************************
    @author:      Swati Mathur
    @date:        17-Sep 2018
    @description: Test method for retrieveLocationPropDetails() method
    *******************************************************************************/
        static testmethod void retrieveLocationPropDetails_Negative(){
            
            //Query user record created in test setup data method
            User objUser =[Select Id,Name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
            Location__c objLocation =[Select Id,Name from Location__c];
            LocationOccupant__c locOccObj =[Select Id,Name,StartDate__c,EndDate__c from LocationOccupant__c where StartDate__c = :system.today()-1];
            //Run test class in user context
            system.runas(objUser){
                
                Test.startTest();
                CuAp_MoveAmendmentDetailsPageCtrlr.ContainerWrapper getLocAndLocOccDetails = CuAp_MoveAmendmentDetailsPageCtrlr.getLocAndLocOccDetails(objUser.Id, locOccObj);
                Test.stopTest();
                System.assertEquals(getLocAndLocOccDetails.prevOccStartDate,null);
                System.assertEquals(getLocAndLocOccDetails.nextOccEndDate,null);
            }
        }
    }