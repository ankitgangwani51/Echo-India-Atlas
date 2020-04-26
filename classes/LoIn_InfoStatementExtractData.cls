/******************************************************************************
@author         Echo: Sudhir Kumar
@date           29 Oct 2018
@description    Container class for JSON Information Statement Response Payload
				AT-4127 (AU1): Salesforce Statement payload
******************************************************************************/

public with sharing class LoIn_InfoStatementExtractData {
	
    private static final String CLASS_NAME 	= 'LoIn_InfoStatementExtractData' ;
    private static final String DEBUG 		= '[' + CLASS_NAME + '] ' ;
    //Utility methods used to format date and datetime fields for json as yyyy-MM-dd HH:mm:ss
    private static String dateToString(Date d) {return d != null ? String.valueOf(d) + ' 00:00:00' : null;} 
    private static String dateToString(DateTime dt) {return dt != null ? String.valueOf(dt) : null;} 
    public LoIn_InfoStatementRequestObj infoStmtData {get; private set;}
    
    public LoIn_InfoStatementExtractData(Id infoStatementId) {
        // STEP 1: get all the data records required 
        // get the Information Statement record
        InformationStatement__c infoStmtObj = [SELECT Id, SettlementDate__c, Type__c, Location__c FROM InformationStatement__c WHERE Id =: infoStatementId] ;
        LoIn_InfoStatementRequestContainer container = new LoIn_InfoStatementRequestContainer(new set<Id> {infoStmtObj.Location__c}) ;
        infoStmtData = new LoIn_InfoStatementRequestObj(container, infoStmtObj) ;
    }
    
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           29 Oct 2018
    @description    Subclass for Information Statement JSON Object
    *******************************************************************************/
    @TestVisible
    private class LoIn_InfoStatementRequestObj {
        @TestVisible private String InformationStatementId ;
        @TestVisible private String SettlementDate ;
        @TestVisible private String Type ;
        @TestVisible private String LocationId ;
        @TestVisible private List<LoIn_InfoStatementRequestContainer.SupplyPoint> SupplyPoints ;
        
        private LoIn_InfoStatementRequestObj(LoIn_InfoStatementRequestContainer container, InformationStatement__c infoStmtObj) {
            system.debug('LoIn_InfoStatementRequestObj STARTS..');
            InformationStatementId = infoStmtObj.Id ;
            SettlementDate = dateToString(infoStmtObj.SettlementDate__c) ;
            Type = infoStmtObj.Type__c ;
            LocationId = infoStmtObj.Location__c ;
            //add Supply Point
            SupplyPoints = new List<LoIn_InfoStatementRequestContainer.SupplyPoint>() ;
            for(SupplyPoint__c supplyPoint : container.supplyPoints) {
                SupplyPoints.add(new LoIn_InfoStatementRequestContainer.SupplyPoint(container, supplyPoint, infoStmtObj.Id)) ;
            }       
            system.debug('LoIn_InfoStatementRequestObj ENDS..');
        }
    }  
    
    /******************************************************************************
	@author    		Echo: Sudhir Kumar
	@date      		29 Oct 2018
	@return			String - JSON string
	@description 	Retrieves and packages InfoStatement data
	*******************************************************************************/
    public String getInfoStatementRequestPayload() {
        System.debug('infoStmtData1= ' + infoStmtData);
        //Serialise into json
        String jsonPayload = JSON.serializePretty(infoStmtData) ;
        system.debug('jsonPayload= ' + jsonPayload);
        return jsonPayload ;
    }
}