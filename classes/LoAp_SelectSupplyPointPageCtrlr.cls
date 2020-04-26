/******************************************************************************
@author         Echo: Amit K.
@date           05 Feb 2018
@description    Component controller for SelectSupplyPointPage lightning component

Revisions		10 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class LoAp_SelectSupplyPointPageCtrlr {
    
    private static List<string> supplyPointFields;
    private static List<string> supplyPointDeviceFields;
    private static List<string> locationFields;
    private static List<string> availableServiceFields;
    private static List<string> avlServiceFields;// -- Swati 28-08-2018, AT-3174 
    
    private static final String CLASS_NAME = 'LoAp_SelectSupplyPointPageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
   
     static{
         supplyPointFields = new List<string>();
         supplyPointFields.add(GlUt_APIConstantsSupplyPoint.DEVICELOCATIONAPINAME);
     }
    static{
        supplyPointDeviceFields = new List<string>();
        supplyPointDeviceFields.add(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME); 
        supplyPointDeviceFields.add(GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME); 
     }
  
    static{
        availableServiceFields = new List<string>();
        // availableServiceFields.add(GlUt_APIConstantsAvailableService.SERVICETYPEREFAPINAME); //-- Swati 28-08-2018, AT-3174 
        availableServiceFields.add(GlUt_APIConstantsAvailableService.SUPPLYPOINTAPINAME);
        availableServiceFields.add(GlUt_APIConstantsAvailableService.SERVICETYPEAPINAME);
    }
    
    // -- Swati 28-08-2018, AT-3174   
    static{
        //Get Fields from the Service Type Object
        avlServiceFields = new List<string>();
        avlServiceFields.add(GlUt_APIConstantsServiceType.NAMEAPINAME);  
    }
    
    /**********************************************************************************************
	@author         Echo: Amit K.
	@date           05 Feb 2018
	@return         List<GLAp_FieldProps>
	@description    This method returns the field properties for each of the fields that are to be displayed on the screen
	**********************************************************************************************/
	@AuraEnabled
	public static List<GLAp_FieldProps> getSupplyPointFieldProps() {    
        //Get the field properties for Supply Point object
        List<GLAp_FieldProps> supplyPointProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, supplyPointFields);
        
        //Create Transform Field for Available Service having parent object Supply Point.
        GLAp_FieldProps spdServicesProp = new GLAp_FieldProps();
        spdServicesProp.isFLSVisible = true;
        spdServicesProp.isEncrypted = false;
        spdServicesProp.isEditable = false;
        spdServicesProp.isRequired = false;
        spdServicesProp.fieldName  =  LoAp_Constants.AVAILABLESERVICENAME;
        spdServicesProp.fieldLabel =  LoAp_Constants.AVAILABLESERVICELABEL;
        spdServicesProp.fieldType = 'text';
        spdServicesProp.transformField = true; 
        spdServicesProp.parentObject = GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME; 
        
        //Create Transform Field for Supply Point No.
        GLAp_FieldProps supplyPointNameProp = new GLAp_FieldProps();
        supplyPointNameProp.isFLSVisible = true;
        supplyPointNameProp.isEncrypted = false;
        supplyPointNameProp.isEditable = false;
        supplyPointNameProp.isRequired = false;
        supplyPointNameProp.fieldName  =  GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME;
        supplyPointNameProp.fieldLabel =  LoAp_Constants.SUPPLYPOINTNAMELABEL;
        supplyPointNameProp.fieldType =    LoAp_Constants.REFERENCEFIELD;
        supplyPointNameProp.transformField = true; 
        supplyPointNameProp.parentObject =   LoAp_Constants.SUPPLYPOINTNAMELABEL;  
        
        
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        try {
            for (GLAp_FieldProps fldProp : supplyPointProps) {
                fldProp.isEditable = false;
                fldPropList.add(fldProp);
            }
          
            //Add transform field to the property list
            fldPropList.add(supplyPointNameProp);
            fldPropList.add(spdServicesProp);
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return fldPropList;
    }
    
    /**********************************************************************************************
	@author         Echo: Amit K.
	@date           13 Feb 2018
	@return         List<Id>
	@param			string supplyPointId
	@description    This method returns the service type ids on supply point.
	@revision       MT 07-Mar-2018 Use the field from constant class
	**********************************************************************************************/
    @AuraEnabled
    public static List<Id> getAvailableServicesOnSupplyPoint(string supplyPointId){
        List<SupplyPoint__c> supplyPointList = new List<SupplyPoint__c>();
        List<AvailableService__c> availableServiceList = new List<AvailableService__c>();
        List<Id> stIdList = new List<Id>();
        try {
            if (string.isNotBlank(supplyPointId)) {
                
                //VS- 22 Feb 2018 AT-1872 added the 'Active' check in the available service query 
                
                availableServiceList = (List<AvailableService__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME, 
                                                                                                       availableServiceFields, 
                                                                                                       supplyPointId, 
                                                                                                       GlUt_APIConstantsAvailableService.SUPPLYPOINTAPINAME, 
                                                                                                       GlUt_APIConstantsAvailableService.ACTIVEAPINAME + ' = TRUE');
                
                Set<Id> serviceTypeId = new Set<Id>();
                for (AvailableService__c avs : availableServiceList) {
                    serviceTypeId.add(avs.ServiceType__c);
                }
                if (!serviceTypeId.isEmpty()) {
                    for (Id stId : serviceTypeId) {
                        stIdList.add(stId);
                    }
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return stIdList;
    }
    
    /**********************************************************************************************
	@author         Echo: Amit K.
	@date           05 Feb 2018
	@param          string locationId
	@return         List<BlAp_CombinedRecord>
	@description    This method takes the locationId  to return all associated SupplyPoint having Active Supply Point Devices Status = 0.
	@revision       MT 07-Mar-2018 Use the field from constant class
	**********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> getSupplyPointsOnLocation(string locationId) {
        
        //Collection declaration.
        List<BlAp_CombinedRecord> supplypointComList = new List<BlAp_CombinedRecord>();
        List<SupplyPoint__c> supplyPointList = new List<SupplyPoint__c>();
        List<SupplyPointDevice__c> supplyPointDeviceList = new List<SupplyPointDevice__c>();
        List<AvailableService__c> availableServiceList = new List<AvailableService__c>();
        Map<Id, String> mapOfSupplyPointIdToAvailableServiceItem = new Map<Id,String>();
        Map<Id, List<SupplyPointDevice__c>> mapOfSupplyPointIdToActiveSupplyPointDevice = new Map<Id, List<SupplyPointDevice__c>>();
        try {
            if (string.isNotBlank(locationId)) {
                supplyPointList = (List<SupplyPoint__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, 
                                                                                             supplyPointFields, 
                                                                                             locationId, 
                                                                                             GlUt_APIConstantsSupplyPoint.LOCATIONAPINAME);
            }
            
            // build a list of supply point Ids to use in subsequent queries
            List<Id>supplyPointIds = new List<Id>();
            for (SupplyPoint__c supplyPoint : supplyPointList) {
                supplyPointIds.add(supplyPoint.Id);
            }
            
            if (!supplyPointList.isEmpty()) {
                
                //VS- 22 Feb 2018 AT-1872 added the 'Active' check in the available service query 
                availableServiceList = (List<AvailableService__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME, 
                                                                                                       availableServiceFields, 
                                                                                                       String.format('WHERE {0} IN {1} AND {2} = true', 
                                                                                                                     new List<String>{
                                                                                                                         GlUt_APIConstantsAvailableService.SUPPLYPOINTAPINAME, 
                                                                                                                             GlUt_FieldSecurity.IdsToString(supplyPointIds), 
                                                                                                                             GlUt_APIConstantsAvailableService.ACTIVEAPINAME}));
            }
             // -- Swati 28-08-2018 - Start, AT-3174                          
            List<Id> serviceTypeIdList = new List<Id>();
            for (AvailableService__c objAS : availableServiceList) {
                serviceTypeIdList.add(objAS.ServiceType__c); 
            } 
            List<ServiceType__c> lstServiceType =  GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME,
                                                                                       avlServiceFields,
                                                                                       String.format('WHERE {0} IN {1}', 
                                                                                                      new List<String>{
                                                                                                      GlUt_APIConstantsServiceType.Id, 
                                                                                                      GlUt_FieldSecurity.IdsToString(serviceTypeIdList)}));   
            
            Map<Id, ServiceType__c> serviceTypeId2ServiceTypeMap = new Map<Id, ServiceType__c>(lstServiceType);
            // -- Swati 28-08-2018 - End, AT-3174
            
            //Create Map for Supply Point Id and set of Available services.
            Map<Id, Set<String>> mapOfSupplyPointIdToAvailableServices = new Map<Id, Set<String>>();
            for (AvailableService__c avService : availableServiceList) {
                String service = '';
               if(serviceTypeId2ServiceTypeMap.containsKey(avService.ServiceType__c)){ //-- Swati 28-08-2018, AT-3174
                    service = serviceTypeId2ServiceTypeMap.get(avService.ServiceType__c).Name; // -- Swati 28-08-2018, AT-3174
                    if (!mapOfSupplyPointIdToAvailableServices.containsKey(avService.SupplyPoint__c)) {
                        mapOfSupplyPointIdToAvailableServices.put(avService.SupplyPoint__c, new Set<String>()); 
                    }
                    mapOfSupplyPointIdToAvailableServices.get(avService.SupplyPoint__c).add(service);
                }
            }
            //Fetch available services in comma seperated string and create Map of Supply Point ID --> Available Services
            for (Id spId : mapOfSupplyPointIdToAvailableServices.keySet()) {
                if (mapOfSupplyPointIdToAvailableServices.get(spId) != null) {
                    Set<String> serviceType = new Set<String>();
                    serviceType = mapOfSupplyPointIdToAvailableServices.get(spId);
                    for (String s : serviceType) {
                        String services = '';
                        if (mapOfSupplyPointIdToAvailableServiceItem.containsKey(spId)) {
                            services = mapOfSupplyPointIdToAvailableServiceItem.get(spId);
                            services = services + ',';
                        }
                        services = services + s;
                        mapOfSupplyPointIdToAvailableServiceItem.put(spId,services);
                    }
                }
            }
            if (!supplyPointList.isEmpty()) {
                supplyPointDeviceList = (List<SupplyPointDevice__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, 
                                                                                                         supplyPointDeviceFields, 
                                                                                                         String.format('WHERE {0} IN {1} AND {2} = true', 
                                                                                                                       new List<String>{
                                                                                                                           GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME, 
                                                                                                                               GlUt_FieldSecurity.IdsToString(supplyPointIds), 
                                                                                                                               GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME}));
            }
            //Fetch all supply points whose active supply point device status = True.
            for (SupplyPointDevice__c spd : supplyPointDeviceList) {
                if (!mapOfSupplyPointIdToActiveSupplyPointDevice.containsKey(spd.SupplyPoint__c)) {
                    mapOfSupplyPointIdToActiveSupplyPointDevice.put(spd.SupplyPoint__c, new List<SupplyPointDevice__c>()); 
                }
                mapOfSupplyPointIdToActiveSupplyPointDevice.get(spd.SupplyPoint__c).add(spd); 
            }
                
            Map<Id,String> supplyPointIdReferenceNameMap = new Map<Id,String>();
            if(!supplyPointIds.isEmpty()){
                supplyPointIdReferenceNameMap = GlAp_LightningDataAccess.getRecordName(supplyPointIds);
            }
            
            for(SupplyPoint__c sp : supplyPointList) {
                //Add those supply points in combined list which are not in Active Supply Point device Status Map.
                if (!mapOfSupplyPointIdToActiveSupplyPointDevice.containsKey(sp.Id)) {
                    BlAp_CombinedRecord objSupplyPointCom = new BlAp_CombinedRecord();            
                    objSupplyPointCom.uniqueId = sp.Id;
                    objSupplyPointCom.isSelected = false;
                    String availableServices = mapOfSupplyPointIdToAvailableServiceItem.get(sp.Id);
                    objSupplyPointCom.objectMap = new Map<string, sObject>();
                    
                    //Create a map of supply point related field values
                    objSupplyPointCom.objectMap.put(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, sp);

                    //Add in transform list fields
                    Map<string, string> transFormFieldMap1 = new Map<string, string>();
                    transFormFieldMap1.put(sp.Id, supplyPointIdReferenceNameMap.get(sp.Id));
                    objSupplyPointCom.transformFieldMap = new Map<string,Map<string, string>>();
                    objSupplyPointCom.transformFieldMap.put(LoAp_Constants.SUPPLYPOINTNAMELABEL, transFormFieldMap1); 
                     
                    //Add in transform list fields
                    Map<string, string> transFormFieldMap = new Map<string, string>();
                    transFormFieldMap.put(LoAp_Constants.AVAILABLESERVICENAME, availableServices);
                    objSupplyPointCom.transformFieldMap.put(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, transFormFieldMap); 
                    supplypointComList.add(objSupplyPointCom);
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return supplypointComList;  
    }
    
}