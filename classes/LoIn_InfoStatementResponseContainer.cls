/******************************************************************************
@author         Echo: Sudhir Kumar
@date           29 Oct 2018
@description    Container class for JSON Information Statement Response Payload
AT-4127 (AU1): Salesforce Statement payload
******************************************************************************/

public with sharing class LoIn_InfoStatementResponseContainer {
    
    private static final String CLASS_NAME = 'LoIn_InfoStatementResponseContainer';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    // utility methods to cope with null values in the response
    private static Date dateEscapeNull(String s) {return s != null ? Date.valueOf(s) : null;}
    private static Decimal decimalEscapeNull(String s) {return s != null ? Decimal.valueOf(s) : null;}
    private static Integer integerEscapeNull(String s) {return s != null ? Integer.valueOf(s) : null;}
    private static Boolean booleanEscapeNull(String s) {return s != null ? s.toLowerCase() == 'true' : false;}
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           29 Oct 2018
	@param			String jsonResponse, String contractId
	@return			String - accrualBillId
    @description    Method for processing Information Statement Response JSON Object
    *******************************************************************************/
    public static String processInfoStatementResponse(String jsonResponse, String contractId) {
        system.debug('Sudhir jsonResponse=> ' + jsonResponse);
        LoIn_InfoStatementResponseObj accrualBillResponse = parse(jsonResponse) ;
        system.debug('Sudhir accrualBillResponse=> ' + accrualBillResponse) ;
        list<AccrualBill__c> listAccrualBills  ;
        list<AccrualBillItem__c> listAccrualBillItems ;
        String accrualBillId = '' ;
        map<String, List<AccrualBillItemObj>> mapAccrualBillExtId2ListBillItems = new map<String, List<AccrualBillItemObj>>() ;
        try {
            if(accrualBillResponse != null) {  
                AccrualBillObj aBillObj = accrualBillResponse.AccrualBill ;
                if(aBillObj != null) {
                    AccrualBill__c aBill = new AccrualBill__c(HerokuPostgresId__c = aBillObj.Id, 
                                                              InformationStatement__c = aBillObj.InformationStatementId,
                                                              BillDate__c = dateEscapeNull(aBillObj.BillDate), 
                                                              StartDate__c = dateEscapeNull(aBillObj.StartDate), 
                                                              EndDate__c = dateEscapeNull(aBillObj.EndDate),      
                                                              BilledAmount__c = decimalEscapeNull(aBillObj.BilledAmount),
                                                              Type__c = aBillObj.Type,
                                                              BillingContract__c = contractId) ;
                    system.debug('Sudhir aBill=> ' + aBill) ;
                    system.debug('Sudhir AccrualBillItems=> ' + aBillObj.AccrualBillItems) ;
                    if(aBillObj.AccrualBillItems != null && !aBillObj.AccrualBillItems.isEmpty()) {
                        //mapAccrualBillExtId2ListBillItems.put(aBill.HerokuPostgresId__c, aBillObj.AccrualBillItems) ;
                        mapAccrualBillExtId2ListBillItems.put(aBillObj.Id, aBillObj.AccrualBillItems) ;
                    }
                    system.debug('Sudhir mapAccrualBillExtId2ListBillItems=> ' + mapAccrualBillExtId2ListBillItems) ;
                    Database.insert(aBill) ;
                    system.debug('After Insert-aBill= ' + aBill);
                    accrualBillId = aBill.Id ;
                    system.debug('After Insert-accrualBillId= ' + accrualBillId);
                }
                system.debug('Sudhir listAccrualBills=> ' + listAccrualBills);
                if(String.isNotBlank(accrualBillId)) {
                    if(mapAccrualBillExtId2ListBillItems.containsKey(aBillObj.Id) && mapAccrualBillExtId2ListBillItems.get(aBillObj.Id) != null) {
                        List<AccrualBillItemObj> listAccrualBillItemObj = mapAccrualBillExtId2ListBillItems.get(aBillObj.Id) ;
                        system.debug('Sudhir listAccrualBillItemObj=> ' + listAccrualBillItemObj) ;
                        if(listAccrualBillItemObj != null && !listAccrualBillItemObj.isEmpty()) {
                            listAccrualBillItems = new list<AccrualBillItem__c>() ;
                            for(AccrualBillItemObj aBillItemObj : listAccrualBillItemObj) {
                                AccrualBillItem__c aBillItem = new AccrualBillItem__c(AccrualBill__c = accrualBillId, 
                                                                                      HerokuPostgresId__c = aBillItemObj.Id, 
                                                                                      StartDate__c = dateEscapeNull(aBillItemObj.StartDate), 
                                                                                      EndDate__c = dateEscapeNull(aBillItemObj.EndDate), 
                                                                                      ServiceItem__c = aBillItemObj.ServiceItemId, 
                                                                                      VolumeUsed__c = decimalEscapeNull(aBillItemObj.VolumeUsed), 
                                                                                      BilledAmount__c = decimalEscapeNull(aBillItemObj.BilledAmount), 
                                                                                      TotalTaxAmount__c = decimalEscapeNull(aBillItemObj.TotalTaxAmount), 
                                                                                      NetBilledAmount__c = decimalEscapeNull(aBillItemObj.NetBilledAmount), 
                                                                                      TotalDiscountAmount__c = decimalEscapeNull(aBillItemObj.TotalDiscountAmount),
                                                                                      Rate__c = aBillItemObj.RateId,
                                                                                      AgreedRate__c = aBillItemObj.AgreedRateId, 
                                                                                      Device__c = aBillItemObj.DeviceId) ;
                                listAccrualBillItems.add(aBillItem) ;
                            }
                            Database.insert(listAccrualBillItems) ;
                            system.debug('After Insert-aBillItem= ' + listAccrualBillItems);
                        }
                    }
                }
                system.debug('aBillObj.InformationStatement= ' + aBillObj.InformationStatementId);
                if(aBillObj.InformationStatementId != null) {
                    InformationStatement__c infoStmtObj = new InformationStatement__c(Id = aBillObj.InformationStatementId, 
                                                                                      //IssueDate__c = System.today(), //Sudhir : 28/112018
                                                                                      CalculatedCharges__c = decimalEscapeNull(aBillObj.BilledAmount)) ;
                    Database.update(infoStmtObj) ;
                }
            }
            
        } catch(Exception ex) {
            system.debug('ex= ' + ex);
            GlUt_Logger.logException(ex);
            //String errorMessage = 'ERROR: ' + GlUt_Logger.getActualErrorMessage(ex.getMessage()) ;
            String errorMessage = 'ERROR: ' + ex.getMessage() ;
            //throw new AuraHandledException('Error: ' + ex.getMessage()) ;
           return errorMessage  ;
        }
        system.debug('returned accrualBillId= ' + accrualBillId);
        return accrualBillId ;
    }	
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           29 Oct 2018
	@param			String jsonResponse
	@return			LoIn_InfoStatementResponseObj - deserialized json response to apex type
    @description    Method for parsing  Information Statement Response JSON string
    *******************************************************************************/
    public static LoIn_InfoStatementResponseObj parse(String jsonResponse) {
        return (LoIn_InfoStatementResponseObj) System.JSON.deserialize(jsonResponse, LoIn_InfoStatementResponseObj.class) ;
    }
    
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           29 Oct 2018
    @description    Subclass for Information Statement Response JSON Object
    *******************************************************************************/
    @TestVisible
    private class LoIn_InfoStatementResponseObj {
        @TestVisible private AccrualBillObj AccrualBill ;
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           29 Oct 2018
    @description    Subclass for AccrualBill JSON Object
    *******************************************************************************/
    @TestVisible
    private class AccrualBillObj {
        @TestVisible private String Id ; //heroku postgress Id
        @TestVisible private String InformationStatementId ;
        @TestVisible private String Type ;
        @TestVisible private String BillDate ;
        @TestVisible private String StartDate ;
        @TestVisible private String EndDate ;
        @TestVisible private String BilledAmount ;
        @TestVisible private list<AccrualBillItemObj> AccrualBillItems ;
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           29 Oct 2018
    @description    Subclass for AccrualBillItem JSON Object
    *******************************************************************************/
    @TestVisible
    private class AccrualBillItemObj {
        @TestVisible private String Id ; //heroku postgress Id
        @TestVisible private String StartDate ;
        @TestVisible private String EndDate ;
        @TestVisible private String ServiceItemId ;
        @TestVisible private String VolumeUsed ;
        @TestVisible private String BilledAmount ;
        @TestVisible private String TotalTaxAmount ;
        @TestVisible private String NetBilledAmount ;
        @TestVisible private String TotalDiscountAmount ;
        @TestVisible private String RateId ;
        @TestVisible private String AgreedRateId ;
        @TestVisible private String DeviceId ;
    }
}