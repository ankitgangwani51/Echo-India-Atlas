/***************************************************************************************************
@author        Accenture : Shivangi Gaur
@date          26-Oct-2017
@description:  This is helper class used by Supply Point Device Service object trigger  
@group         TriggerHelper
Revision(s)    30-Oct-2017 -- Shivangi Gaur -- Added method oneActiveDeviceOnSupplyPointUpdate().
               31-Oct-2017 -- Shivangi Gaur -- Updated method oneActiveDeviceOnSupplyPointUpdate().
               06-Nov-2017 -- Shivangi Gaur -- Moved the error message to custom label.
*******************************************************************************************************/
public with sharing class GlUt_SupplyPointDeviceServiceHandler extends GlUt_TriggerHandlerBase{
    
    private static final String CLASS_NAME = 'GlUt_SupplyPointDeviceServiceHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    // Variable declaration
    
    // End variable declaration
    
    /**********************************************************************************************
    @author        Accenture: Shivangi Gaur
    @date          26-Oct-2017
    @param         GlUt_TriggerHandlerObj inputParam
    @return        void
    @description   This method is used to invoke method from trigger
    **********************************************************************************************/
    public override void  MainEntry(GlUt_TriggerHandlerObj inputParam){
        try{
            if( inputParam.isInsert && inputParam.isBefore ){
                oneActiveDeviceOnSupplyPointInsert(inputParam.newlist);               
            }
            if( inputParam.isInsert && inputParam.isAfter ){
                   
            }
            if( inputParam.isUpdate && inputParam.isBefore ){
                oneActiveDeviceOnSupplyPointUpdate(inputParam.newlist, inputParam.oldmap);               
            }
            if( inputParam.isUpdate && inputParam.isAfter ){
                    
            }  
            if( inputParam.isDelete && inputParam.isBefore ){
                
            }
            if( inputParam.isDelete && inputParam.isAfter ){
            
            }  
        }
        catch (Exception ex){
            system.debug('Line Number:=' + ex.getLineNumber());
            system.debug('Line Number:=' + ex.getMessage());
            system.debug('Line Number:=' + ex.getStackTraceString());
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
    @author        Accenture: Shivangi Gaur
    @date          26-Oct-2017
    @param         Trigger.new
    @return        void
    @description   Method to prevent adding more than one service for an active device on a supply Point.
                   This method is for insert of Supply Point Device Service.
    **********************************************************************************************/
    private void oneActiveDeviceOnSupplyPointInsert(list<SupplyPointDeviceService__c> newlist){
        Set<Id> setSPDevice = new Set<Id>();
        Set<Id> setSupPoint = new Set<Id>();
        Set<Id> setActiveSPDevice = new Set<Id>();
        Map<Id,SupplyPointDeviceService__c> mapSPDeviceService = new Map<Id,SupplyPointDeviceService__c>();
        for(SupplyPointDeviceService__c spDeviceObj : newlist){
            if(spDeviceObj.SupplyPointDevice__c != null){
                setSPDevice.add(spDeviceObj.SupplyPointDevice__c);
            }           
        }
        if(setSPDevice != null){
            for(SupplyPointDevice__c spDevice : [Select id, SupplyPoint__c from SupplyPointDevice__c where id IN: setSPDevice AND Active__c = true limit 50000]){
                setSupPoint.add(spDevice.SupplyPoint__c);
            }       
        }
        if(setSupPoint != null){
            for(SupplyPoint__c spObj : [Select id, (Select id, Active__c from SupplyPointDevices__r where Active__c = true limit 500) from SupplyPoint__c where id IN: setSupPoint limit 500]){
                if(spObj.SupplyPointDevices__r != null){
                    for(SupplyPointDevice__c spObjNew : spObj.SupplyPointDevices__r){
                        setActiveSPDevice.add(spObjNew.id);
                    }                   
                }
            }       
        }
        if(setActiveSPDevice != null){
            for(SupplyPointDevice__c spDObj : [Select id, (Select id, ServiceType__c, SupplyPointDevice__c from SupplyPointDeviceServices__r limit 500) from SupplyPointDevice__c where id IN: setActiveSPDevice limit 50000]){
                if(spDObj.SupplyPointDeviceServices__r != null){
                    for(SupplyPointDeviceService__c newObj : spDObj.SupplyPointDeviceServices__r){
                        if(!mapSPDeviceService.containsKey(newObj.ServiceType__c)){
                            mapSPDeviceService.put(newObj.ServiceType__c,newObj);
                        }                        
                    }
                }
            }
        }
        for(SupplyPointDeviceService__c spDeviceServObj : newlist){
            if(!mapSPDeviceService.isEmpty() && mapSPDeviceService.containsKey(spDeviceServObj.ServiceType__c)){
                spDeviceServObj.addError(System.Label.CuAp_SPDeviceServiceError);        // **** should be a custom label not a constant ****
            }
        }
    }
    /**********************************************************************************************
    @author        Accenture: Shivangi Gaur
    @date          30-Oct-2017
    @param         Trigger.new, Trigger.oldmap
    @return        void
    @description   Method to prevent adding more than one service for an active device on a supply Point.
                   This method is for update of Supply Point Device Service.
    **********************************************************************************************/
    private void oneActiveDeviceOnSupplyPointUpdate(list<SObject> newlist, Map<Id, SObject> oldmap){
        List<SupplyPointDeviceService__c> listSPDeviceService = new List<SupplyPointDeviceService__c>();
        Map<Id, SupplyPointDeviceService__c> oldMapObj = new Map<Id, SupplyPointDeviceService__c>();
        oldMapObj = (Map<Id, SupplyPointDeviceService__c>)oldmap;
        for(SupplyPointDeviceService__c spDeviceObj : (List<SupplyPointDeviceService__c>)newlist){
            if(spDeviceObj.SupplyPointDevice__c != null && spDeviceObj.ServiceType__c != null && (spDeviceObj.SupplyPointDevice__c != oldMapObj.get(spDeviceObj.id).SupplyPointDevice__c || spDeviceObj.ServiceType__c != oldMapObj.get(spDeviceObj.id).ServiceType__c)){
                listSPDeviceService.add(spDeviceObj);
            }           
        }
        if(listSPDeviceService != null && !listSPDeviceService.isEmpty()){
            oneActiveDeviceOnSupplyPointInsert(listSPDeviceService);       
        }
    }
}