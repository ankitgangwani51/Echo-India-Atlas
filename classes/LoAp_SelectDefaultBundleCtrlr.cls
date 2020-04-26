/******************************************************************************
@author      	Echo: Mohit Tayal
@date      		01-Feb-2018
@description	Component controller for Select Default Bundle Lightning Component

Revisions		09 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class LoAp_SelectDefaultBundleCtrlr {
	
    // Variables
    private static List<String> supplyPointDeviceFields;
    private static List<String> availableServiceFields;
    private static List<String> bundleFields;
    private static List<String> bundleItemFields;
    private static List<String> serviceTypeFields;
    private static List<String> availableBundleFields;
    
    private static final String CLASS_NAME = 'LoAp_SelectDefaultBundleCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    static{
        
        // Get fields from the Supply Point Device object
        supplyPointDeviceFields = new List<String>();
        supplyPointDeviceFields.add(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME);
        
        // Get fields from the Available Service object
        availableServiceFields = new List<String>();
        availableServiceFields.add(GlUt_APIConstantsAvailableService.NAMEAPINAME);
        availableServiceFields.add(GlUt_APIConstantsAvailableService.ACTIVEAPINAME);
        availableServiceFields.add(GlUt_APIConstantsAvailableService.SUPPLYPOINTAPINAME);
        availableServiceFields.add(GlUt_APIConstantsAvailableService.SERVICETYPEAPINAME);
        
        // Get fields from the Bundle object
        bundleFields = new List<String>();
        bundleFields.add(GlUt_APIConstantsBundle.NAMEAPINAME);
        bundleFields.add(GlUt_APIConstantsBundle.SERVICETYPEAPINAME);
        
        // Get fields from the Bundle Item object
        bundleItemFields = new List<String>();
        bundleItemFields.add(GlUt_APIConstantsBundleItem.NAMEAPINAME);
        bundleItemFields.add(GlUt_APIConstantsBundleItem.BUNDLEAPINAME);
        
        // Get fields from the Service Type object
        serviceTypeFields = new List<String>();
        serviceTypeFields.add(GlUt_APIConstantsServiceType.NAMEAPINAME);
        serviceTypeFields.add(GlUt_APIConstantsServiceType.SERVICETYPEDSCRAPINAME);
        
        // Get fields from the Available Bundle object
        availableBundleFields = new List<String>();
        availableBundleFields.add(GlUt_APIConstantsAvailableBundle.BUNDLEAPINAME);
        availableBundleFields.add(GlUt_APIConstantsAvailableBundle.AVAILABLESERVICEAPINAME);
        availableBundleFields.add(GlUt_APIConstantsAvailableBundle.DEFAULTAPINAME);
    }
    
	/**********************************************************************************************
    @author         Echo: Mohit Tayal
    @date           01-Feb-2018
    @return         List<GLAp_FieldProps> - List of field properties for each of the fields that are 
                                            to be displayed on the screen
    @description    This method returns the field properties for each of the fields that are to be 
                    displayed on the screen          
    **********************************************************************************************/    
    @AuraEnabled
    public static List<GLAp_FieldProps> RetrieveBundleFieldPropDetails() {
        // List of fieldprops to return
        
        List<GLAp_FieldProps> bundleProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsBundle.BUNDLEAPINAME, bundleFields);
        List<GLAp_FieldProps> serviceTypeProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME, serviceTypeFields);
        List<GLAp_FieldProps> bundleItemProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsBundleItem.BUNDLEITEMAPINAME, bundleItemFields);
        
        //field properties of the bundle item object
        GLAp_FieldProps bundleItemProp = new GLAp_FieldProps();
        bundleItemProp.isFLSVisible = true;
        bundleItemProp.isEncrypted = false;
        bundleItemProp.isEditable = false;
        bundleItemProp.isRequired = false;
        bundleItemProp.fieldName = GlUt_APIConstantsBundleItem.NAMEAPINAME;
        bundleItemProp.fieldLabel = LoAp_Constants.BUNDLEITEMLABEL;
        bundleItemProp.fieldType = LoAp_Constants.TEXT;
        bundleItemProp.transformField = true; //Indicates this is a Transfrom and NOT a DB field
        bundleItemProp.parentObject = GlUt_APIConstantsBundleItem.NAMEAPINAME; //Attach to Bundle for display
        
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG );
            
            // Get the field properties for the service type object      
            for(GLAp_FieldProps fldProp : serviceTypeProps){
                if(fldProp.fieldName == GlUt_APIConstantsServiceType.NAMEAPINAME){
                    fldProp.fieldLabel = LoAp_Constants.SERVICETYPELABEL;
                    fldProp.isEditable = false;
                    fldPropList.add(fldProp);
                }
            }
            
            // Get the field properties for the bundle object
            for(GLAp_FieldProps fldProp : bundleProps){           
                if(fldProp.fieldName == GlUt_APIConstantsBundle.NAMEAPINAME){
                    fldProp.fieldLabel = LoAp_Constants.BUNDLELABEL;
                    fldProp.isEditable = false;
                    fldPropList.add(fldProp);
                }
            }
            
            // Get the field properties for the bundle item object
            for(GLAp_FieldProps fldProp : bundleItemProps){
                if(fldProp.fieldName == GlUt_APIConstantsBundleItem.NAMEAPINAME){
                    fldPropList.add(bundleItemProp);
                }
            }  
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return fldPropList;
    }
    
    /**********************************************************************************************
    @author         Echo: Mohit Tayal
    @date           01-Feb-2018
    @param          String recordId - Id of either supply point or device depending on the wizardtype
    @param          String wizardType - Action performing via the wizard
    @return         Map<Id,List<BlAp_CombinedRecord>> - Map of Service Type Id and List of combined records
                                                        of service type, bundle and bundle items based on bundle.
    @description    This method returns all the data required to display on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static Map<Id,List<BlAp_CombinedRecord>> RetrieveBundleRecords(String recordId, String wizardType) {
        
        Map<Id, List<BlAp_CombinedRecord>> srvcTypIdCmbinRecMap = new Map<Id, List<BlAp_CombinedRecord>>();
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG );
            
            //validating whether the record id have value or not
            if (String.isNotBlank(recordId)) {
                
                List<AvailableService__c> availableServiceList = RetrvAvalbleSrvcList(recordId, wizardType);
                
                if (availableServiceList.size() > 0) {
                    Set<Id> serviceTypeIdsSet = new Set<Id>();
                    
                    //fetching the Service Type from available service and creating a service type ids set
                    for (AvailableService__c objAvailService : availableServiceList) {
                        serviceTypeIdsSet.add(objAvailService.ServiceType__c);
                    }
                    
                    List<ServiceType__c> serviceTypeList = (List<ServiceType__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME, 
                                                                                                                      serviceTypeFields, 
                                                                                                                      'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(serviceTypeIdsSet));
                    Map<Id,ServiceType__c> serviceTypeIdRecMap = new Map<Id,ServiceType__c>();
                    
                    //building map for service type id and its related record
                    for(ServiceType__c objserviceType : serviceTypeList){
                        serviceTypeIdRecMap.put(objserviceType.Id, objserviceType);
                    }
                    
                    //query for fetching the bundle records base on the service type ids from the keyset of serviceTypeIdsSet map
                    List<Bundle__c> bundlesList = (List<Bundle__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBundle.BUNDLEAPINAME, 
                                                                                                        bundleFields, 
                                                                                                        String.format('WHERE {0} IN {1}', 
                                                                                                                      new List<String>{ 
                                                                                                                          GlUt_APIConstantsBundle.SERVICETYPEAPINAME, 
                                                                                                                              GlUt_FieldSecurity.IdsToString(serviceTypeIdsSet)}));
                    
                    if (bundlesList.size() > 0) {                    
                        //creating a set of bundle ids
                        Set<Id> bundleIdsSet = new Set<Id>();
                        for (Bundle__c objBundle : bundlesList) {
                            bundleIdsSet.add(objBundle.Id);
                        }
                        
                        //fetching the bundle items records using the set bundleIdsSet
                        List<BundleItem__c> bundleItemList = (List<BundleItem__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBundleItem.BUNDLEITEMAPINAME, 
                                                                                                                       bundleItemFields, 
                                                                                                                       String.format('WHERE {0} IN {1}', 
                                                                                                                                     new List<String>{ 
                                                                                                                                         GlUt_APIConstantsBundleItem.BUNDLEAPINAME, 
                                                                                                                                             GlUt_FieldSecurity.IdsToString(bundleIdsSet)}));
                        Map<Id, String> idBundleItemNames = new Map<Id, String>();
                        
                        //creating a map of bundle id and bundle items name seperated by semicolon
                        for (BundleItem__c objBundleItem : bundleItemList) {
                            String name = objBundleItem.Name;
                            if (idBundleItemNames.containsKey(objBundleItem.Bundle__c)) {
                                name = idBundleItemNames.get(objBundleItem.Bundle__c) + '; ' + name;   
                            }
                            idBundleItemNames.put(objBundleItem.Bundle__c, name);
                        }
                        
                        // Prepare the combined record list to display on screen
                        for (Bundle__c objBundle : bundlesList) {
                            BlAp_CombinedRecord bundleObj = new BlAp_CombinedRecord();            
                            bundleObj.uniqueId = objBundle.Id;
                            bundleObj.isSelected = false;
                            bundleObj.objectMap = new Map<String, sObject>();
                            bundleObj.objectMap.put(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME, serviceTypeIdRecMap.get(objBundle.ServiceType__c));
                            bundleObj.objectMap.put(GlUt_APIConstantsBundle.BUNDLEAPINAME, objBundle);
                            
                            // Prepare the transform field map to display the values of Bundle Item column
                            Map<String, String> transFormFieldMap = new Map<String, String>();
                            transFormFieldMap.put(GlUt_APIConstantsBundleItem.NAMEAPINAME, idBundleItemNames.get(objBundle.Id));
                            bundleObj.transformFieldMap = new Map<String, Map<String, String>>();
                            bundleObj.transformFieldMap.put(GlUt_APIConstantsBundleItem.NAMEAPINAME, transFormFieldMap);
                            if(!srvcTypIdCmbinRecMap.containsKey(objBundle.ServiceType__c)){
                                srvcTypIdCmbinRecMap.put(objBundle.ServiceType__c, new List<BlAp_CombinedRecord>());
                            }
                            srvcTypIdCmbinRecMap.get(objBundle.ServiceType__c).add(bundleObj);
                        }
                    }
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return srvcTypIdCmbinRecMap;
    }
    
 	/**********************************************************************************************
    @author         Echo: Mohit Tayal
    @date           13-Feb-2018
    @param          String recordId - Id of either supply point or device depending on the wizardtype
    @param          String wizardType - Action performing via the wizard
    @return         Map<Id,AvailableBundle__c> - Map of Service type Id and related available bundle
    @description    This method is used to retrieve the avaialble bundles having default__c field as true
    **********************************************************************************************/
    @AuraEnabled
    public static Map<Id,AvailableBundle__c> RetrvAvalbleBndlRecords(String recordId, String wizardType) {
        
        Map<Id, AvailableBundle__c> srvcTypIdavilbleBndlRecMap = new Map<Id, AvailableBundle__c>();
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG );
            
            //validating whether the record id have value or not
            if (String.isNotBlank(recordId)) {
                List<AvailableService__c> availableServiceList = RetrvAvalbleSrvcList(recordId, wizardType);
                
                if (availableServiceList.size() > 0) {
                    Set<Id> availableServiceIdsSet = new Set<Id>();
                    
                    //creating the set of available service ids
                    for (AvailableService__c objAvailService : availableServiceList) {
                        availableServiceIdsSet.add(objAvailService.Id);
                    }
                    
                    //query for fetching the available bundles having default true and having the avaialable service id present in set availableServiceIdsSet
                    List<AvailableBundle__c> availableBundleList = (List<AvailableBundle__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME, 
                                                                                                                                  availableBundleFields, 
                                                                                                                                  String.format('WHERE {0} IN {1} and {2} = TRUE', 
                                                                                                                                                new List<String>{ 
                                                                                                                                                    GlUt_APIConstantsAvailableBundle.AVAILABLESERVICEAPINAME, 
                                                                                                                                                        GlUt_FieldSecurity.IdsToString(availableServiceIdsSet), 
                                                                                                                                                        GlUt_APIConstantsAvailableBundle.DEFAULTAPINAME}));
                    
                    if (availableBundleList.size() > 0) {
                        
                        //creating a map map of avaialble service id and its related record
                        Map<Id, AvailableBundle__c> avalsrvcIdavilbleBndlRecMap = new Map<Id, AvailableBundle__c>();
                        for (AvailableBundle__c objAvailableBundle : availableBundleList) {
                            avalsrvcIdavilbleBndlRecMap.put(objAvailableBundle.AvailableService__c, objAvailableBundle);
                        }
                        
                        //creating a map of service type id and available bundle record associated with it
                        for (AvailableService__c objAvailService : availableServiceList) {
                            if (avalsrvcIdavilbleBndlRecMap.containsKey(objAvailService.Id)) {
                                srvcTypIdavilbleBndlRecMap.put(objAvailService.ServiceType__c, avalsrvcIdavilbleBndlRecMap.get(objAvailService.Id));
                            }
                        }
                    }
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return srvcTypIdavilbleBndlRecMap;
    }
    
	/**********************************************************************************************
    @author         Echo: Vivek Sethi
    @date           23-May-2018
    @param          String recordId - Id of either supply point or device depending on the wizardtype
    @param          String wizardType - Action performing via the wizard
    @return         Map<Id,AvailableService__c> - Map of Service type Id and related available Services
    @description    This method is used to create the new available bundle with the available service record
    **********************************************************************************************/
    @AuraEnabled   //VS   #AT-2644
    public static Map<Id,AvailableService__c> RetrieveAvailableServiceRecords(String recordId, String wizardType) {   
        
        Map<Id, AvailableService__c> serviceTypeIdToAvailServiceMap = new Map<Id, AvailableService__c>();
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG );
            
            //validating whether the record id have value or not
            if (String.isNotBlank(recordId)) {
                List<AvailableService__c> availableServiceList = RetrvAvalbleSrvcList(recordId, wizardType);
                if (availableServiceList.size() > 0) {
                    //fetching the Service Type from available service and creating a service type ids set
                    for (AvailableService__c objAvailService : availableServiceList) {
                        serviceTypeIdToAvailServiceMap.put(objAvailService.ServiceType__c,objAvailService);
                    }
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return serviceTypeIdToAvailServiceMap;
    }
    
    /**********************************************************************************************
    @author         Echo: Mohit Tayal
    @date           13-Feb-2018
    @param          String recordId - Id of either supply point or device depending on the wizardtype
    @param          String wizardType - Action performing via the wizard
    @return         List<AvailableService__c> - List of available services
    @description    This method is used to fetch the avaialble service records
    **********************************************************************************************/    
    public static List<AvailableService__c> RetrvAvalbleSrvcList(String recordId, String wizardType) { 
        List<AvailableService__c> availableServiceList = new List<AvailableService__c>();
        
        //validating whether the record id have value or not
        if (String.isNotBlank(recordId)) {
        	Set<Id> supplyPointIdSet = new Set<Id>();
            
            //validating if the remove action is carriying out via wizard
            if (wizardType == LoAp_Constants.REMOVEDEVICE) {
                
                //query for fetching the supply point device records using the device id
                List<SupplyPointDevice__c> supplyPointDeviceList = (List<SupplyPointDevice__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, 
																																	supplyPointDeviceFields, 
																																	recordId, 
																																	GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME, 
																																	GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME + ' = TRUE LIMIT 1');
                
                //creating a set of supply point ids from the supply point device records
                for (SupplyPointDevice__c objSupplyPointDevice : supplyPointDeviceList) {
                    supplyPointIdSet.add(objSupplyPointDevice.SupplyPoint__c);
                }

            } else {
            	
            	supplyPointIdSet.add(recordId);
            }

            //query for fetching the available service records using the supply point id(s)
            availableServiceList = (List<AvailableService__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME, 
																									availableServiceFields, 
																									String.format('WHERE {0} IN {1} and {2} = TRUE', 
																										new List<String>{ 
																											GlUt_APIConstantsAvailableService.SUPPLYPOINTAPINAME, 
																											GlUt_FieldSecurity.IdsToString(supplyPointIdSet), 
																											GlUt_APIConstantsAvailableService.ACTIVEAPINAME}));
            System.debug('availableServiceList = ' + availableServiceList);
        }
        return availableServiceList;
    }  
}