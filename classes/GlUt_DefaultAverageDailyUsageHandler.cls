/***************************************************************************************************
@author        Echo : Neha Rajput
@date          20-Mar-2018
@description:  This is helper class used by DefaultAverageDailyUsage object trigger  
@group         TriggerHelper
Revision(s)   
*******************************************************************************************************/
public with sharing class GlUt_DefaultAverageDailyUsageHandler extends GlUt_TriggerHandlerBase {

    // Variable declaration
    private static final String CLASS_NAME = 'GlUt_DefaultAverageDailyUsageHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    // End variable declaration
    
    /**********************************************************************************************
    @author        Echo: Neha Rajput
    @date          20-Mar-2018
    @param         GlUt_TriggerHandlerObj inputParam
    @return        void
    @description   This method is used to invoke method from trigger
    **********************************************************************************************/
    public override void MainEntry(GlUt_TriggerHandlerObj inputParam) {
        system.debug('******inputParam=' + inputParam);
        try {
            if (inputParam.isInsert && inputParam.isBefore) {
                
            }
            if (inputParam.isInsert && inputParam.isAfter) {
                 updateDADUEndDate(inputParam.newlist);
            }
            if (inputParam.isUpdate && inputParam.isBefore) {
                
            }
            if (inputParam.isUpdate && inputParam.isAfter) {
                
            }
            if (inputParam.isDelete && inputParam.isBefore) {
                
            }
            if (inputParam.isDelete && inputParam.isAfter) {
                
            }
        } catch (Exception ex) {
            system.debug('Line Number:=' + ex.getLineNumber());
            system.debug('Line Number:=' + ex.getMessage());
            system.debug('Line Number:=' + ex.getStackTraceString());
            GlUt_Logger.logException(ex);

        } finally {
            //Reset the active function to null in case this class was first in stack
            //this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();
        }        
    }
    
    /**********************************************************************************************
    @author        Echo: Neha Rajput
    @date          20-Mar-2018
    @param         (List<DefaultAverageDailyUsage__c> newlist)
    @return        void
    @description   This method is used to update Enddate of existing Dadu
    **********************************************************************************************/
    public void updateDADUEndDate(List<DefaultAverageDailyUsage__c> newlist) {
        List<DefaultAverageDailyUsage__c> listOldDADU = new List<DefaultAverageDailyUsage__c>();
        List<DefaultAverageDailyUsage__c> updatedDADU = new List<DefaultAverageDailyUsage__c>();
        
        List<Id> listNewDADU = new List<Id>();        
        List<Id> listDeviceSize = new List<Id>();
        List<Id> listSupplyPointUsageType = new List<Id>();
        List<Decimal> listNumberofOccupiers = new List<Decimal>(); 
        
        List<String> strList = new List<String>();
        
        Map<List<String>,Date> newDADUDetailsmap = new Map<List<String>,Date>();
        
        DefaultAverageDailyUsage__c objUpdateDADU = new DefaultAverageDailyUsage__c();
                
        
        // List out DeviceSize,SupplyPointUsageType,NumberofOccupiers of current DADU
        for(DefaultAverageDailyUsage__c objNewDADU : newlist){   
            listNewDADU.add(objNewDADU.Id);
            listDeviceSize.add(objNewDADU.DeviceSize__c);
            listSupplyPointUsageType.add(objNewDADU.SupplyPointUsageType__c);
            listNumberofOccupiers.add(objNewDADU.NumberofOccupiers__c);
            
            strList.add(objNewDADU.DeviceSize__c);            
            strList.add(objNewDADU.SupplyPointUsageType__c);
            strList.add(String.valueOf(objNewDADU.NumberofOccupiers__c));
            
            // create Map<List<String>, Date> of new DADU details, List of String is {DeviceSize,SupplyPointUsageType,NumberofOccupiers}
            // Date is StartDate         
            newDADUDetailsmap.put(strList,objNewDADU.StartDate__c);
            strList.clear();
        }
        // List of all existing DADU List via new combination of new DADU list of DeviceSize,SupplyPointUsageType & NumberofOccupiers
        // and end date should be blank
        listOldDADU = [SELECT Id,EndDate__c,NumberofOccupiers__c,SupplyPointUsageType__c,DeviceSize__c FROM DefaultAverageDailyUsage__c 
                       WHERE Id NOT IN: listNewDADU
                       AND DeviceSize__c IN: listDeviceSize 
                       AND SupplyPointUsageType__c IN: listSupplyPointUsageType
                       AND NumberofOccupiers__c IN: listNumberofOccupiers
                       AND EndDate__c = NULL];
        // List down all existing DADU's to update Enddate        
        for(DefaultAverageDailyUsage__c objOldDADU : listOldDADU){  
            strList.add(objOldDADU.DeviceSize__c);            
            strList.add(objOldDADU.SupplyPointUsageType__c);            
            strList.add(String.valueOf(objOldDADU.NumberofOccupiers__c));
            // check string set avaiable in new DADU
            if(newDADUDetailsmap.keySet().contains(strList)){
                objUpdateDADU = objOldDADU;                
                objUpdateDADU.EndDate__c = newDADUDetailsmap.get(strList) - 1;
                updatedDADU.add(objUpdateDADU);                 
            } 
            strList.clear();            
        }
        if(updatedDADU.size() > 0){
            updatedDADU = (List<DefaultAverageDailyUsage__c>) GlUt_FieldSecurity.cleanseFields(updatedDADU, false);
            Database.upsert(updatedDADU);
        }    
    }
}