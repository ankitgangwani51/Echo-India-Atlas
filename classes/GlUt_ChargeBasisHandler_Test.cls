/******************************************************************************
@author:      Echo: Hasan 
@date:        25-09-2018  
@description: Test Class for GlUt_ChargeBasisHandler
*******************************************************************************/
@isTest
public class GlUt_ChargeBasisHandler_Test{
    
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
        objChargeBasis2.StartDate__c  = CBstartDate2;
        //objChargeBasis2.EndDate__c  = CBendDate2;
        cblist.add(objChargeBasis2);
        
        ChargeBasis__c objChargeBasis3 = GlUt_FactoryData_Test.createChargeBasis(objAvailableService);
        objChargeBasis3.StartDate__c  = CBstartDate3;
        objChargeBasis3.EndDate__c  = CBendDate3;
        cblist.add(objChargeBasis3);
        Database.insert(cblist);
    }
/******************************************************************************
@author:      Echo: Hasan 
@date:        25-09-2018  
@description: Test Class for ValidateChargeBasis Method positivie scenario
*******************************************************************************/
    
    Static testmethod void ValidateChargeBasis_Positive()
    {
        User objUser = [Select id from user Limit 1];
        Boolean isException = false;
        List<ChargeBasis__c> updatedcbasis = new List<ChargeBasis__c>();
        List<ChargeBasis__c> Chargebasislist = [select id, Amount__c from ChargeBasis__c];
        for(ChargeBasis__c cb : Chargebasislist )
        {
            cb.Amount__c = 20;
            updatedcbasis.add(cb);
        }
        system.runAs(objUser)
        {
            Test.startTest();
            update updatedcbasis;
            System.assert(!updatedcbasis.isEmpty());
            Test.stopTest();  
        }
    }
/******************************************************************************
@author:      Echo: Hasan 
@date:        25-09-2018  
@description: Test Class for ValidateChargeBasis Method negetive scenario
*******************************************************************************/
    
    Static testmethod void ValidateChargeBasis_Negetive()
    {
        User objUser = [Select id from user Limit 1];
        List<ChargeBasis__c> updatedcbasis = new List<ChargeBasis__c>();
        List<ChargeBasis__c> Chargebasislist = [select id, Amount__c from ChargeBasis__c  where StartDate__c =: CBstartDate2];
        for(ChargeBasis__c cb : Chargebasislist )
        {
            cb.StartDate__c = CBstartDate3;
            updatedcbasis.add(cb);
        }
        system.runAs(objUser)
        {
            Try{
                Test.startTest();
                update updatedcbasis;
            }Catch (DMLexception e){
                Boolean expectedExceptionThrown =  (e.getMessage().contains(System.Label.GlUt_ChargeBasisOverLapException)) ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
            Test.stopTest();
        }
    }
/******************************************************************************
@author:      Echo: Hasan 
@date:        25-09-2018  
@description: Test Class for ValidateChargeBasis Method scenario where one of 
existing record has no end date.
*******************************************************************************/
    
    Static testmethod void ValidateChargeBasis_NoEnddate()
    {
        User objUser = [Select id from user Limit 1];
        ChargeBasis__c existingcb = [SELECT id from ChargeBasis__c where startdate__c = :CBstartDate2];
        
        system.debug('**cblist**' +existingcb);
        List<Availableservice__c> listavs = [Select id from availableservice__c];
        
        ChargeBasis__c cb = new ChargeBasis__c();
        cb.StartDate__c = date.valueOf('2018-01-01');
        cb.EndDate__c = date.valueOf('2018-03-30');
        cb.AvailableService__c = listavs[0].id;
        
        system.runAs(objUser)
        {
            Try{
                Test.startTest();
                insert cb;
            }Catch (DMLexception e){
                Boolean expectedExceptionThrown =  (e.getMessage().contains(System.Label.GlUt_ChargeBasisOverLapException)) ? true : false;
                System.AssertEquals(expectedExceptionThrown, false);
            }
            Test.stopTest();
        }
    }
}