/******************************************************************************
@author:      Echo: Hasan 
@date:        25-09-2018  
@description: Test Class for GlUt_RestrictDatesOverlap
*******************************************************************************/
@istest
public class GlUt_RestrictDatesOverlap_Test{
    
    
    private static final String USER_PROFILE = 'System Administrator';
    private static final String USER_NAME = 'TestUser';
    private static final String USERNAMECOMPLETE  = USER_NAME + '@unitest.com';
    private static final String USER_FNAME = 'First_User_Name';
    private static final String USER_LNAME = 'Last_User_Name'; 
    Private static final string zipcode = 'GX11 1AA';
    Private static final string wholesaler = 'wholesaler';
    Private static final string SupplyPointUsageTypeName = 'Waterusage';
    Private static final string ServiceTypeName = 'Water';
    Private static final string AvailableServiceName = 'Water as service';
    private static final Date CBstartDate1 = date.valueOf('2020-05-01');
    private static final Date CBendDate1 = date.valueOf('2020-05-30');
    private static final Date CBstartDate2 = date.valueOf('2020-10-01');
    private static final Date CBendDate2 = date.valueOf('2020-10-30');
    private static final Date CBstartDate3 = date.valueOf('2020-06-01');
    private static final Date CBendDate3 = date.valueOf('2020-06-30');
    Private static final string ReadFrequency = 'Monthly';
    
    @TestSetup
    static void createTestData()
    {
        // Create User Record
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        objUser.FirstName = USER_FNAME;
        objUser.LastName = USER_LNAME;
        Database.insert(objUser);
        
        //Create Location Record
        Location__c objLocation = GlUt_FactoryData_Test.createLocation(zipcode) ;
        Database.Insert(objLocation);
        
        //Create Division Record
        Division__c objDivision = GlUt_FactoryData_Test.createDivision();
        Database.Insert(objDivision);
        
        //Create Wholeseller Record
        Wholesaler__c objwholesalers = GlUt_FactoryData_Test.createWholesaler(wholesaler);
        Database.insert(objwholesalers);
        
        //Create SupplyPointUsageType__c record
        SupplyPointUsageType__c objSupplyPointUsageType = GlUt_FactoryData_Test.createSupplyPointUsageType(SupplyPointUsageTypeName);
        Database.Insert(objSupplyPointUsageType);
        
        //Create SupplyPoint__c record
        SupplyPoint__c objSupplyPoint = GlUt_FactoryData_Test.createSupplyPoint(objLocation, objSupplyPointUsageType);
 
        Database.Insert(objSupplyPoint);
        
        //Create ServiceType Record
        ServiceType__c objServiceType = GlUt_FactoryData_Test.createServiceType(ServiceTypeName);
        Database.Insert(objServiceType);
        
        //Create AvailableService Record
        AvailableService__c objAvailableService = GlUt_FactoryData_Test.createAvailableService(AvailableServiceName, objDivision, objServiceType, objSupplyPoint, objWholesalers);
        Database.Insert(objAvailableService);
        
        //Create Chargebasis Record
        List<ChargeBasis__c> cblist = new List<ChargeBasis__c> ();
        
        ChargeBasis__c objChargeBasis1 = GlUt_FactoryData_Test.createChargeBasis(objAvailableService);
        objChargeBasis1.StartDate__c  = CBstartDate1;
        objChargeBasis1.EndDate__c  = CBendDate1;
        cblist.add(objChargeBasis1);
        
        //Create Chargebasis Record
        ChargeBasis__c objChargeBasis2= GlUt_FactoryData_Test.createChargeBasis(objAvailableService);
        objChargeBasis2.StartDate__c  = CBstartDate1;
        objChargeBasis2.EndDate__c  = CBendDate1;
        cblist.add(objChargeBasis2);
        
        ChargeBasis__c objChargeBasis3 = GlUt_FactoryData_Test.createChargeBasis(objAvailableService);
        objChargeBasis3.StartDate__c  = CBstartDate1;
        //objChargeBasis3.EndDate__c  = CBendDate1;
        cblist.add(objChargeBasis3);
        
        ChargeBasis__c objChargeBasis5 = GlUt_FactoryData_Test.createChargeBasis(objAvailableService);
        objChargeBasis5.StartDate__c  = CBstartDate2;
        objChargeBasis5.EndDate__c  = CBendDate2;
        cblist.add(objChargeBasis5);
        
        ChargeBasis__c objChargeBasis4 = GlUt_FactoryData_Test.createChargeBasis(objAvailableService);
        objChargeBasis4.StartDate__c  = CBstartDate3;
        objChargeBasis4.EndDate__c  = CBendDate3;
        cblist.add(objChargeBasis4);
        
        Try{
            Database.insert(cblist);
        }Catch(DMLexception e)
        {Boolean expectedExceptionThrown =  (e.getMessage().contains(System.Label.GlUt_ChargeBasisOverLapException)) ? true : false;}
    }
    
/******************************************************************************
@author:      Echo: Hasan 
@date:        25-09-2018  
@description: Test Class for RestrictDatesOverlapUtilities Method
*******************************************************************************/
    public static testmethod void SelfSetRecordCheckOverlapLogic_Test()
    {
        
        
        List<ChargeBasis__c> cblist =[select id, AvailableService__c, StartDate__c, Enddate__c , Amount__c from Chargebasis__c];
        Map<Integer,ChargeBasis__c> mapOfInsertingUniqueId2sObject = new  Map<Integer,ChargeBasis__c>();
        Integer count = 0;
        for(ChargeBasis__c newChargeBasis : cblist){
            count = count + 1;//Increase the count for custom unique Id.
            mapOfInsertingUniqueId2sObject.put(count,newChargeBasis); // Map of Inserting Custom Id having CB Record.
            
        }
        User userObj = [select id from user Limit 1];
        system.runAs(userObj){
            Try{
                Test.startTest();
                GlUt_RestrictDatesOverlapUtilities.SelfSetRecordCheckOverlapLogic(mapOfInsertingUniqueId2sObject,GlUt_APIConstantsChargeBasis.AVAILABLESERVICEAPINAME, System.Label.GlUt_ChargeBasisOverLapException);
            }Catch (DMLexception e){
                Boolean expectedExceptionThrown =  (e.getMessage().contains(System.Label.GlUt_ChargeBasisOverLapException)) ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
            Test.stopTest();
        }  
    }
    
}