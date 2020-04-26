/******************************************************************************
@author         Echo: Neha R
@date           07 Feb 2018
@description    Component controller for LoAp_DeviceManagementSelectAction lightning component
@Revisions		09 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class LoAp_DeviceManagementSelectActionCtrlr {
    
    private static final String CLASS_NAME = 'LoAp_DeviceManagementSelectActionCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
     public static List<String> sPDeviceFields;
        
    static{        
        sPDeviceFields = new List<String>();
        sPDeviceFields.add(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME);  
        sPDeviceFields.add(GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME);  
    }
     
    
    /**********************************************************************************************
	@author         Echo: Neha R
	@date           07 Feb 2018
    @param          ID locationId 
	@return         WrapperObject
	@description    Method to find number of active devices & SPD at a location   
	**********************************************************************************************/
    @AuraEnabled
    public static WrapperObject retrieveActiveDevice(ID locationId) {
        
        WrapperObject objWrapper = new WrapperObject();
        List<Id> spIdList = new List<Id>();
        Set<Id> spIdSet = new Set<Id>();
        
        Map<Id, SupplyPoint__c> supplyPointMap = new Map<Id, SupplyPoint__c>([SELECT Id FROM SupplyPoint__c WHERE Location__c = :locationId]);
        Map<Id, Device__c> deviceMap = new Map<Id, Device__c>([SELECT Id FROM Device__c WHERE Active__c = true]);     
        
        List<SupplyPointDevice__c> spdList = new List<SupplyPointDevice__c>();
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG );
            
            spdList = (List<SupplyPointDevice__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, 
                                                                                       sPDeviceFields, 
                                                                                       String.format('WHERE {0} IN {1} AND {2} IN {3} AND {4} = true', 
                                                                                                     new List<String>{
                                                                                                         GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME, 
                                                                                                             GlUt_FieldSecurity.IdsToString(supplyPointMap.keySet()), 
                                                                                                             GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME, 
                                                                                                             GlUt_FieldSecurity.IdsToString(deviceMap.keySet()), 
                                                                                                             GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME
                                                                                                             }));
            
            // Total no of active device on Location
            objWrapper.noOfActiveDevices = spdList.isEmpty() ? 0 : spdList.size();
            
            for (SupplyPointDevice__c objSPD: spdList) { 
                
                // SupplyPointDevice Id if only one active device available at location
                if (objWrapper.noOfActiveDevices == 1) {
                    objWrapper.objSupplyPointDevice = objSPD;
                }
                spIdList.add(objSPD.SupplyPoint__c);
            }
            
            spIdSet.addAll(spIdList);
            
            // Location has a supply point to add a new device
            objWrapper.activeSupplyPoint = supplyPointMap.size() > spIdSet.size();
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
       
        return objWrapper;
    }   
    
    /******************************************************************************
    @author         Echo: Neha R
    @date           07 Feb 2018
    @description    Wrapper class 
    *******************************************************************************/
    public class WrapperObject {        
        @AuraEnabled public Integer noOfActiveDevices;
        @AuraEnabled public Boolean activeSupplyPoint;
        @AuraEnabled public SupplyPointDevice__c objSupplyPointDevice;       
    }
}