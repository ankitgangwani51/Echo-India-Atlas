/***************************************************************************************************
@author        Accenture : Ashish Tiwari
@date          13-Dec-2017
@description:  This is helper class used by Consideration object trigger  
@group         TriggerHelper
Revision(s):    
*******************************************************************************************************/
public with sharing class GlUt_ConsiderationHandler extends GlUt_TriggerHandlerBase{
    
    private static final String CLASS_NAME = 'GlUt_ConsiderationHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    // Variable declaration
    
    // End variable declaration
    
    /**********************************************************************************************
    @author        Accenture: Ashish Tiwari
    @date          13-Dec-2017
    @param         GlUt_TriggerHandlerObj inputParam
    @return        void
    @description   This method is used to invoke method from trigger
    **********************************************************************************************/
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam){
        try{
            if( inputParam.isInsert && inputParam.isBefore ){
                
            }
            if( inputParam.isInsert && inputParam.isAfter ){
                // Set AllowDisconnection value on insert
                setAllowDisconnectionInsert(inputParam.newlist);
                
            }
            if( inputParam.isUpdate && inputParam.isBefore ){
                
            }
            if( inputParam.isUpdate && inputParam.isAfter ){
                // Set AllowDisconnection value on update
                setAllowDisconnectionUpdate(inputParam.newlist,inputParam.oldMap);               
            }  
            if( inputParam.isDelete && inputParam.isBefore ){
                
            }
            if( inputParam.isDelete && inputParam.isAfter ){
            
            }  
        }
        catch (Exception ex){
            system.debug('Line Number:=' + ex.getLineNumber());
            GlUt_Logger.logException(ex);
        }
        finally{   
            //Reset the active function to null in case this class was first in stack
            //this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();
        }

    }
    
    /**********************************************************************************************
    @author         Accenture: Ashish Tiwari
    @date           13-Dec-2017
    @param          GlUt_TriggerHandlerObj inputParam
    @return         void
    @description    This method overides the InProgressEntry in the base class. This is 
                    only necessary where special handling is required in the event that a trigger
                    causes another trigger to fire. In this case it is the Consideration trigger
                    calling the Consideration trigger in which case the subsequnet invocation is supressed
    **********************************************************************************************/
    public override void inProgressEntry(GlUt_TriggerHandlerObj inputParam){        
        if(inputParam.TriggerObject == GlUt_Constants.OBJCONSIDERATION){
            //Supress recursion
        }
        //Otherwise invoke the default version of the tigger
        else{
            system.debug('Running standard trigger');
            super.InProgressEntry(inputParam);
        }
    }
    /**********************************************************************************************
    @author        Accenture: Ashish Tiwari
    @date          13-Dec-2017
    @param         Trigger.new
    @return        void
    @description   This method is used to set Allow Disconnection to true/false 
                   on supply Point if Record is insert on Consideration
    **********************************************************************************************/
    private void setAllowDisconnectionInsert(list<Consideration__c> newlist){
        Map<Id,SupplyPoint__c> sPointMap = new Map<Id,SupplyPoint__c>();
        Set<Id> locOccAccIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for(Consideration__c conRec: newlist){
            locOccAccIds.add(conRec.Account__c);
        }
        for(Consideration__c con: [Select Id,Account__c from Consideration__c where 
                                   (ConsiderationType__r.DisconnectionPermitted__c !=true or Active__c!=true) and Account__c in:locOccAccIds]){
            accountIds.add(con.Account__c);
        }
        locOccAccIds.removeAll(accountIds);
        for(SupplyPoint__c supplyPointRecord: [Select Id,AllowDisconnection__c from SupplyPoint__c where 
                                          SupplyDisconnectionStatus__c=:GlUt_Constants.SUPPLYDISCONNECTIONSTATUS and 
                                          Location__c IN (Select Location__c from LocationOccupant__c 
                                          where (EndDate__c = null OR EndDate__c > Today) 
                                           and Account__c in: locOccAccIds)]){
            supplyPointRecord.AllowDisconnection__c = true;
            sPointMap.put(supplyPointRecord.Id,supplyPointRecord);
        }
        for(SupplyPoint__c supplyPointRecord: [Select Id,AllowDisconnection__c from SupplyPoint__c where 
                                          SupplyDisconnectionStatus__c=:GlUt_Constants.SUPPLYDISCONNECTIONSTATUS and 
                                          Location__c in (Select Location__c from LocationOccupant__c 
                                          where (EndDate__c = null OR EndDate__c > Today) 
                                           and Account__c in: accountIds)]){
            supplyPointRecord.AllowDisconnection__c = false;
            sPointMap.put(supplyPointRecord.Id,supplyPointRecord);
        }
        if(!sPointMap.IsEmpty() && sPointMap!=null){
            update sPointMap.values();
        }
    }
    
    /**********************************************************************************************
    @author        Accenture: Ashish Tiwari
    @date          13-Dec-2017
    @param         Trigger.new
    @return        void
    @description   This method is used to set Allow Disconnection to true/false 
                   on supply Point if Record is update on Consideration
    **********************************************************************************************/
    private void setAllowDisconnectionUpdate(list<Consideration__c> newlist,Map<Id,sObject> oldmap){
        Map<Id,SupplyPoint__c> sPointMap = new Map<Id,SupplyPoint__c>();
        Set<Id> locOccAccIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for(Consideration__c conRec: newlist){
            Consideration__c oldValue = (Consideration__c)oldmap.get(conRec.id);
            if(oldValue.Active__c != conRec.Active__c){
                locOccAccIds.add(conRec.Account__c);
            }
        }
        for(Consideration__c con: [Select Id,Account__c from Consideration__c where 
                                   Active__c<>true and Account__c in:locOccAccIds]){
            accountIds.add(con.Account__c);
        }
        locOccAccIds.removeAll(accountIds);
        for(SupplyPoint__c supplyPointRecord: [Select Id,AllowDisconnection__c from SupplyPoint__c where 
                                          SupplyDisconnectionStatus__c=:GlUt_Constants.SUPPLYDISCONNECTIONSTATUS and 
                                          Location__c in (Select Location__c from LocationOccupant__c 
                                          where (EndDate__c = null OR EndDate__c > Today) 
                                           and Account__c in: locOccAccIds)]){
            supplyPointRecord.AllowDisconnection__c = false;
            sPointMap.put(supplyPointRecord.Id,supplyPointRecord);
        }
        for(SupplyPoint__c supplyPointRecord: [Select Id,AllowDisconnection__c from SupplyPoint__c where 
                                          SupplyDisconnectionStatus__c=:GlUt_Constants.SUPPLYDISCONNECTIONSTATUS and 
                                          Location__c in (Select Location__c from LocationOccupant__c 
                                          where (EndDate__c = null OR EndDate__c > Today) 
                                           and Account__c in: accountIds)]){
            supplyPointRecord.AllowDisconnection__c = true;
            sPointMap.put(supplyPointRecord.Id,supplyPointRecord);
        }
        if(!sPointMap.IsEmpty() && sPointMap!=null){
            update sPointMap.values();
        }
    } 
}