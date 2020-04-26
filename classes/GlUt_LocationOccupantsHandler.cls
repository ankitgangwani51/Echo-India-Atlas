/***************************************************************************************************
@author        Accenture : Ashish Tiwari
@date          14-Dec-2017
@description:  This is helper class used by Location Occupants object trigger  
@group         TriggerHelper
Revision(s):    
*******************************************************************************************************/
public with sharing class GlUt_LocationOccupantsHandler extends GlUt_TriggerHandlerBase{
    // Variable declaration
    private static final String CLASS_NAME = 'GlUt_LocationOccupantsHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    // End variable declaration
    
    /**********************************************************************************************
    @author        Accenture: Ashish Tiwari
    @date          14-Dec-2017
    @param         GlUt_TriggerHandlerObj inputParam
    @return        void
    @description   This method is used to invoke method from trigger
    **********************************************************************************************/
    public override void  mainEntry(GlUt_TriggerHandlerObj inputParam){
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
        //update inputParam.newlist;
    }
    
    /**********************************************************************************************
    @author         Accenture: Ashish Tiwari
    @date           14-Dec-2017
    @param          GlUt_TriggerHandlerObj inputParam
    @return         void
    @description    This method overides the InProgressEntry in the base class. This is 
                    only necessary where special handling is required in the event that a trigger
                    causes another trigger to fire. In this case it is the Acccount trigger
                    calling the account trigger in which case the subsequnet invocation is supressed
    **********************************************************************************************/
    public override void  inProgressEntry(GlUt_TriggerHandlerObj inputParam){        
        if(inputParam.TriggerObject == GlUt_Constants.OBJLOCATIONOCCUPANTS){
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
    @date          14-Dec-2017
    @param         Trigger.new
    @return        void
    @description   This method is used to set Allow Disconnection to true/false 
                   on supply Point if Record is insert on Location Occupant
    **********************************************************************************************/
    private void setAllowDisconnectionInsert(list<LocationOccupant__c> newlist){
        Map<Id,SupplyPoint__c> sPointMap = new Map<Id,SupplyPoint__c>();
        Set<Id> locOccAccIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> remAccountIds = new Set<Id>();
        for(LocationOccupant__c locOccupantRec: newlist){
            if((locOccupantRec.EndDate__c == null)){
                locOccAccIds.add(locOccupantRec.Account__c);
            }else{
                remAccountIds.add(locOccupantRec.Account__c);
            }
        }
        for(Consideration__c conRec: [Select id,Account__c from Consideration__c where 
                                   (ConsiderationType__r.DisconnectionPermitted__c <>true or Active__c<>true) and Account__c in:locOccAccIds]){
            accountIds.add(conRec.Account__c);
        }
        locOccAccIds.removeAll(accountIds);
        for(SupplyPoint__c sPointRecord: [Select id,AllowDisconnection__c,SupplyDisconnectionStatus__c from SupplyPoint__c where 
                                          Location__c in (Select Location__c from LocationOccupant__c 
                                          where Account__c in: remAccountIds)]){
            if(sPointRecord.SupplyDisconnectionStatus__c == GlUt_Constants.SUPPLYDISCONNECTIONSTATUS){                                      
                sPointRecord.AllowDisconnection__c = true;
            }
            else{
                sPointRecord.AllowDisconnection__c = false;
            }   
            sPointMap.put(sPointRecord.id,sPointRecord);
        }
        for(SupplyPoint__c sPointRecord: [Select id,AllowDisconnection__c from SupplyPoint__c where 
                                          SupplyDisconnectionStatus__c=:GlUt_Constants.SUPPLYDISCONNECTIONSTATUS and 
                                          Location__c in (Select Location__c from LocationOccupant__c 
                                          where ((EndDate__c = null) OR (StartDate__c <= Today and EndDate__c >Today) OR
                                                (StartDate__c > Today and EndDate__c >Today)) and Account__c in: locOccAccIds)]){
            sPointRecord.AllowDisconnection__c = true;
            sPointMap.put(sPointRecord.id,sPointRecord);
        }
        for(SupplyPoint__c sPointRecord: [Select id,AllowDisconnection__c from SupplyPoint__c where 
                                          SupplyDisconnectionStatus__c=:GlUt_Constants.SUPPLYDISCONNECTIONSTATUS and 
                                          Location__c in (Select Location__c from LocationOccupant__c 
                                          where ((EndDate__c = null) OR (StartDate__c <= Today and EndDate__c >Today) OR
                                                (StartDate__c > Today and EndDate__c >Today)) and Account__c in: accountIds)]){
                                              
            sPointRecord.AllowDisconnection__c = false;
            sPointMap.put(sPointRecord.id,sPointRecord);
        }
        if(!sPointMap.IsEmpty() && sPointMap!=null){
            update sPointMap.values();
        }
    } 
    
    /**********************************************************************************************
    @author        Accenture: Ashish Tiwari
    @date          14-Dec-2017
    @param         Trigger.new
    @return        void
    @description   This method is used to set Allow Disconnection to true/false 
                   on supply Point if Record is update on Location Occupant
    **********************************************************************************************/
    private void setAllowDisconnectionUpdate(list<LocationOccupant__c> newlist,Map<Id,sObject> oldmap){
        Map<Id,SupplyPoint__c> sPointMap = new Map<Id,SupplyPoint__c>();
        Set<Id> locOccAccIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> remAccountIds = new Set<Id>();
        for(LocationOccupant__c locOccupantRec: newlist){
            LocationOccupant__c oldValue = (LocationOccupant__c)oldmap.get(locOccupantRec.id);
            if((oldValue.EndDate__c !=locOccupantRec.EndDate__c))
                if(locOccupantRec.EndDate__c!=null){
                    locOccAccIds.add(locOccupantRec.Account__c);
                } 
                else{
                    accountIds.add(locOccupantRec.Account__c);
                }
        }
        for(Consideration__c conRec: [Select id,Account__c from Consideration__c where 
                                   (ConsiderationType__r.DisconnectionPermitted__c <>true or Active__c<>true) and Account__c in:accountIds]){
            remAccountIds.add(conRec.Account__c);
        } 
        accountIds.removeAll(remAccountIds);
        for(SupplyPoint__c sPointRecord: [Select id,AllowDisconnection__c,SupplyDisconnectionStatus__c from SupplyPoint__c where 
                                          Location__c in (Select Location__c from LocationOccupant__c 
                                          where Account__c in: locOccAccIds)]){
            if(sPointRecord.SupplyDisconnectionStatus__c == GlUt_Constants.SUPPLYDISCONNECTIONSTATUS){                                      
                sPointRecord.AllowDisconnection__c = true;
            }
            else{
                sPointRecord.AllowDisconnection__c = false;
            }   
            sPointMap.put(sPointRecord.id,sPointRecord);
        }
        for(SupplyPoint__c sPointRecord: [Select id,AllowDisconnection__c from SupplyPoint__c where 
                                          SupplyDisconnectionStatus__c=:GlUt_Constants.SUPPLYDISCONNECTIONSTATUS and 
                                          Location__c in (Select Location__c from LocationOccupant__c 
                                          where ((EndDate__c = null) OR (StartDate__c <= Today and EndDate__c >Today) OR
                                                (StartDate__c > Today and EndDate__c >Today)) and Account__c in: accountIds)]){
            sPointRecord.AllowDisconnection__c = true;
            sPointMap.put(sPointRecord.id,sPointRecord);
        }
        for(SupplyPoint__c sPointRecord: [Select id,AllowDisconnection__c from SupplyPoint__c where 
                                          SupplyDisconnectionStatus__c=:GlUt_Constants.SUPPLYDISCONNECTIONSTATUS and 
                                          Location__c in (Select Location__c from LocationOccupant__c 
                                          where ((EndDate__c = null) OR (StartDate__c <= Today and EndDate__c >Today) OR
                                                (StartDate__c > Today and EndDate__c >Today)) and Account__c in: remAccountIds)]){
            sPointRecord.AllowDisconnection__c = false;
            sPointMap.put(sPointRecord.id,sPointRecord);
        }
        if(!sPointMap.IsEmpty() && sPointMap!=null){
            update sPointMap.values();
        }
    }
}