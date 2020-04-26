/******************************************************************************
    @author:      Accenture: Shivangi Gaur
    @date:        04 December 2017
    @description: Test Class for CuAp_MoveInDatePageCtrlr
    Revision(s):  Shivangi Gaur -- 12-Dec-2017 -- Incorporated review comments provided 
                                                    on AT-1184 dated 11-12-2017.
    *******************************************************************************/

    @isTest
    Public Class CuAp_MoveInDatePageCtrlr_Test{
        
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
    @author:      Accenture: Shivangi Gaur
    @date:        04 December 2017
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
            LocationOccupant__c locOccObj = GlUt_FactoryData_Test.createLocationOccupant(objAccount,objLocation);
            locOccObj.StartDate__c = system.today()-1;
            locOccObj.EndDate__c = system.today()+1;
            Database.insert(locOccObj);

        }
        
    /******************************************************************************
    @author:      Shivangi Gaur
    @date:        04 December 2017
    @description: Test method for retrieveLocationPropDetails() method
    *******************************************************************************/
        static testmethod void retrieveLocationPropDetails_Positive(){
            
            //Query user record created in test setup data method
            User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
            
            //Run test class in user context
            system.runas(objUser){
                
                Test.startTest();
                List<GlAp_FieldProps> lstFieldProp = CuAp_MoveInDatePageCtrlr.retrieveLocationPropDetails();
                Test.stopTest();
                
                //Asserts to check properties of list of GlAp_FieldProps retrieved
                System.assert(lstFieldProp.size()>0);
                System.assertEquals(lstFieldProp[0].isEditable,false);
                System.assertEquals(lstFieldProp[1].isEditable,false);
                System.assertEquals(lstFieldProp[0].fieldType,'reference');
                System.assertEquals(lstFieldProp[1].fieldType,'date');
                System.assertEquals(lstFieldProp[2].fieldType,'date');
                System.assertEquals(lstFieldProp[3].fieldType,'checkbox');
            }
        }
    /******************************************************************************
    @author:      Shivangi Gaur
    @date:        04 December 2017
    @description: Test method for getLocationOccupants() method. This is for 
                  positive scenario when there are location occupants associated to location.
    *******************************************************************************/
        static testmethod void getLocationOccupants_Positive(){
            
            //Query user record created in test setup data method
            User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
            
            //Query location record
            Location__c locObj = [Select id from Location__c where PostalCode__c =: LOCATIONNAME limit 1];
            
            //Query location occupant record
            LocationOccupant__c locOccObj = [Select id,Location__c from LocationOccupant__c where Location__c =: locObj.id limit 1];
            
            //Run test class in user context
            system.runas(objUser){
                
                Test.startTest();
                List<BlAp_CombinedRecord> lstCombinedRec = CuAp_MoveInDatePageCtrlr.getLocationOccupants(locObj.id);
                Test.stopTest();
                
                //Asserts to check properties of list of BlAp_CombinedRecord retrieved
                System.assert(lstCombinedRec.size()>0);
                System.assertEquals(lstCombinedRec[0].isSelected,true);
                System.assertEquals(lstCombinedRec[0].uniqueId,locOccObj.id);
            }
        }
    /******************************************************************************
    @author:      Shivangi Gaur
    @date:        04 December 2017
    @description: Test method for getLocationOccupants() method negative scenario.
    *******************************************************************************/
        static testmethod void getLocationOccupants_Negative(){
            
            //Query user record created in test setup data method
            User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
            
            //Query location record
            Location__c locObj = [Select id from Location__c where PostalCode__c =: LOCATIONNAME limit 1];
            
            //Run test class in user context
            system.runas(objUser){
                
                Test.startTest();
                List<BlAp_CombinedRecord> lstCombinedRec = CuAp_MoveInDatePageCtrlr.getLocationOccupants(null);
                Test.stopTest();
                
                System.assertEquals(lstCombinedRec.size(),0);
            }
        }
    /******************************************************************************
    @author:      Shivangi Gaur
    @date:        04 December 2017
    @description: Test method for getLocationDetails() method positive scenario.
    *******************************************************************************/
        static testmethod void getLocationDetails_Positive(){
            
            //Query user record created in test setup data method
            User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
            
            //Query account record
            Account accObj = [Select id from Account where Name =: ACCOUNTNAME limit 1];
            
            //Query location record
            Location__c locObj = [Select id from Location__c where PostalCode__c =: LOCATIONNAME limit 1];
            
            //Run test class in user context
            system.runas(objUser){
                
                Test.startTest();
                List<String> lstString = CuAp_MoveInDatePageCtrlr.getLocationDetails(locObj.id,accObj.id);
                Test.stopTest();
                
                System.assert(lstString.size() > 0);
            }
        }
    /******************************************************************************
    @author:      Shivangi Gaur
    @date:        04 December 2017
    @description: Test method for getLocationDetails() method negative scenario.
    *******************************************************************************/
        static testmethod void getLocationDetails_Negative(){
            
            //Query user record created in test setup data method
            User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
            
            //Query account record
            Account accObj = [Select id from Account where Name =: ACCOUNTNAME limit 1];
            
            //Query location record
            Location__c locObj = [Select id from Location__c where PostalCode__c =: LOCATIONNAME limit 1];
            
            //Run test class in user context
            system.runas(objUser){
                
                Test.startTest();
                List<String> lstString = CuAp_MoveInDatePageCtrlr.getLocationDetails(null,accObj.id);
                Test.stopTest();
                
                System.assertEquals(lstString.size(), 0);
            }
        }
    /******************************************************************************
    @author:      Shivangi Gaur
    @date:        04 December 2017
    @description: Test method for occupancyType() method.
    *******************************************************************************/
        static testmethod void occupancyType_Positive(){
            
            //Query user record created in test setup data method
            User objUser =[Select id,name from user where isActive = true and username =: USERNAMECOMPLETE limit 1];
            
            LocationOccupant__c locOcc = [Select id, OccupancyType__c from LocationOccupant__c limit 1];
            
            boolean isExist = false;
            
            //Run test class in user context
            system.runas(objUser){
                
                Test.startTest();
                List<String> lstString = CuAp_MoveInDatePageCtrlr.occupancyType();
                Test.stopTest();
                
                Set<String> optionSet = new Set<String>();
                for(String opt : lstString){
                    optionSet.add(opt);
                }
                
                if(optionSet.contains(locOcc.OccupancyType__c)){
                    isExist = true;
                }
                System.assertEquals(isExist,true);
            }
        }  
        
    /******************************************************************************
    @author:      Neha R
    @date:        10 Mar 2018
    @description: Test method for retrieveLocationFields() method.
    *******************************************************************************/
        static testmethod void retrieveLocationFields_Positive(){
            
            //Query user record created in test setup data method
            User objUser =[SELECT id, name FROM user WHERE isActive = true AND username =: USERNAMECOMPLETE LIMIT 1];
                        
            //Run test class in user context
            system.runas(objUser){
                
                Test.startTest();
                List<List<GlAp_FieldProps>> listFieldProp = CuAp_MoveInDatePageCtrlr.retrieveLocationFields();
                Test.stopTest();
                system.assert(listFieldProp.size() > 0);
                
            }
        } 
        
        
    }