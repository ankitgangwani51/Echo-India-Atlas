/**********************************************************************************************
@author         Echo : Sudhir Kumar
@date           05-Nov-2018
@description:   AT- (AU1) : Update Location Balance (Debt/ Credit)
**********************************************************************************************/
public with sharing class LoAp_InfoStatementUpdateBalanceCtrlr {
	
    @AuraEnabled
    public static String updateLocationBalance(Id infoStmtRecordId) {
        system.debug('infoStmtRecordId= ' + infoStmtRecordId);
        Decimal debtAmount = 0.00 ;
        Decimal creditAmount = 0.00 ;
        try {
            if(String.isNotBlank(infoStmtRecordId)) {
                
                list<InformationStatement__c> listInfoStmt = [SELECT Location__c FROM InformationStatement__c
                                                              WHERE Id =: infoStmtRecordId] ;
                if(listInfoStmt != null && !listInfoStmt.isEmpty() && listInfoStmt[0].Location__c != null) {
                    creditAmount = LoUt_LocationCredit.getTotalBillAmountAllocated(infoStmtRecordId) ;
                    system.debug('creditAmount= ' + creditAmount);
                    debtAmount = LoUt_LocationDebt.getTotalOutstandingDebt(listInfoStmt[0].Location__c) ;
                    Decimal locationBalance = debtAmount - creditAmount ;
                    system.debug('locationBalance= ' + locationBalance);
                    InformationStatement__c infoObj = new InformationStatement__c(Id = infoStmtRecordId, 
                                                                                  LocationBalance__c = locationBalance) ;
                    InformationStatement__c cleansedInfoObj = (InformationStatement__c) GlUt_FieldSecurity.cleanseFields(infoObj, false);
                    if(cleansedInfoObj != null) Database.update(cleansedInfoObj) ;
                    
                } else {
                    return 'ERROR: No location found' ;		// TO DO:: Use Label
                }
                
            }
            system.debug('debtAmount= ' + debtAmount);
            return 'SUCCESS' ;		// TO DO:: Use Label
            
        } catch(Exception ex) {
            system.debug('ex = ' + ex);
            GlUt_Logger.logException(ex) ;
            throw new AuraHandledException('ERROR: ' +ex.getMessage());
        }
    }
}