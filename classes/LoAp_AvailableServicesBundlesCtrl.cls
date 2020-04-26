/******************************************************************************
@author         Echo: Mohit Tayal
@date           16 July 2018
@description    Controller for Available Services Bundles Lightning Component
*******************************************************************************/
public with sharing class LoAp_AvailableServicesBundlesCtrl {
    
    public static List<String> lstAvailableBundleFields = new List<String>();
    public static List<String> lstAvailableServiceFields = new List<String>();
    public static List<String> lstServiceTypeFields = new List<String>();
    public static List<String> lstBundleFields = new List<String>();
    public static List<String> lstAvailableServiceItemFields = new List<String>();
    public static List<String> lstServiceItemFields = new List<String>();

    static{
        lstAvailableBundleFields.add(GlUt_APIConstantsAvailableBundle.NAMEAPINAME);
       // lstAvailableBundleFields.add(GlUt_APIConstantsAvailableBundle.BUNDLENAMEAPINAME);// -- Swati 29-08-2018 , AT-3174 
        lstAvailableBundleFields.add(GlUt_APIConstantsAvailableBundle.LASTBUNDLECHANGEDATEAPINAME);
        lstAvailableBundleFields.add(GlUt_APIConstantsAvailableBundle.DEFAULTAPINAME);
        lstAvailableServiceFields.add(GlUt_APIConstantsAvailableService.SERVICETYPEAPINAME);
        lstServiceTypeFields.add(GlUt_APIConstantsServiceType.NAMEAPINAME);
        lstBundleFields.add(GlUt_APIConstantsBundle.SOCIALBUNDLEAPINAME);
        lstBundleFields.add(GlUt_APIConstantsBundle.NAMEAPINAME);  // -- Swati 29-08-2018 , AT-3174 
        lstAvailableServiceItemFields.add(GlUt_APIConstantsAvailableServiceItem.AVAILABLEBUNDLEAPINAME);
        lstAvailableServiceItemFields.add(GlUt_APIConstantsAvailableServiceItem.ENDDATEAPINAME);
        lstServiceItemFields.add(GlUt_APIConstantsServiceItem.STARTDATEAPINAME);
        lstServiceItemFields.add(GlUt_APIConstantsServiceItem.ENDDATE);
        lstServiceItemFields.add(GlUt_APIConstantsServiceItem.AVAILABLESERVICEITEMAPINAME);
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           16 July 2018
    @param          String recordId - record Id of the supply point
    @return         Map<Id,String> - map of available service Id to service type
    @description    returns the map of available service Id to service type
    *******************************************************************************/
    @AuraEnabled
    public static Map<Id,String> retrieveAvailaleService(String recordId){
        try{
            system.debug('recordId= ' + recordId);
            Map<Id,String> mapOfAvailableServiceID2ServiceType = new Map<Id,String>();
            if(String.isNotBlank(recordId)){
                List<AvailableService__c> lstAvailableService = new List<AvailableService__c>();
                String listFilter = GlUt_APIConstantsAvailableService.ACTIVEAPINAME + ' = TRUE';
                lstAvailableService = (List<AvailableService__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME, 
                                                                                                      lstAvailableServiceFields, recordId, 
                                                                                                      GlUt_APIConstantsAvailableService.SUPPLYPOINTAPINAME, 
                                                                                                      listFilter);
                Set<Id> setOfServiceIds = new Set<Id>();
                for(AvailableService__c objAvailableService : lstAvailableService){
                    if(objAvailableService.ServiceType__c != Null)
                        setOfServiceIds.add(objAvailableService.ServiceType__c);
                }
                
                Map<Id,String> mapOfServiceTypeID2ServiceType = new Map<Id,String>();
                for(ServiceType__c objServiceType : (List<ServiceType__c>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME, 
                                                                                                                      lstServiceTypeFields,
                                                                                                                      String.format('WHERE {0} IN {1}',new List<String>{'Id',GlUt_FieldSecurity.IdsToString(setOfServiceIds)})
                                                                                                                     )){
                    if(objServiceType != null)
                        mapOfServiceTypeID2ServiceType.put(objServiceType.Id,objServiceType.Name);
                }
                
                for(AvailableService__c objAvailableService : lstAvailableService){
                    if(mapOfServiceTypeID2ServiceType.containsKey(objAvailableService.ServiceType__c))
                        mapOfAvailableServiceID2ServiceType.put(objAvailableService.Id, mapOfServiceTypeID2ServiceType.get(objAvailableService.ServiceType__c));
                }
            }
            system.debug('mapOfAvailableServiceID2ServiceType= ' + mapOfAvailableServiceID2ServiceType);
            return mapOfAvailableServiceID2ServiceType;
        }
        catch(Exception e){
            GlUt_Logger.logException(e);
            GlUt_Logger.writeLogsToDatabase();
            throw new AuraHandledException('Error : ' +e.getMessage()); 
        }
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           16 July 2018
    @param          
    @return         List<List<GlAp_FieldProps>>
    @description    returns the field properties of available bundle 
    *******************************************************************************/
    @AuraEnabled
    public static List<GlAp_FieldProps> retrieveAvailableBundleFields(){
        try{
            List<GlAp_FieldProps> lstFieldProps = new List<GlAp_FieldProps>();            
            List<GlAp_FieldProps> avlBundleProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME, lstAvailableBundleFields);
            // -- Swati 29-08-2018 , AT-3174 Start
            List<GlAp_FieldProps> bundleProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsBundle.BUNDLEAPINAME, lstBundleFields);
            
            for(GlAp_FieldProps avlBundleProp :avlBundleProps){   
                if(avlBundleProp.fieldName == GlUt_APIConstantsAvailableBundle.LASTBUNDLECHANGEDATEAPINAME){
                    for(GlAp_FieldProps bundleProp :bundleProps){
                        if(bundleProp.fieldName == GlUt_APIConstantsBundle.NAMEAPINAME){
                            bundleProp.fieldLabel = CuAp_Constants.AVAILABLEBUNDLELABEL;
                            lstFieldProps.add(bundleProp);
                        }
                    }
                }
                lstFieldProps.add(avlBundleProp);                
            }
            // -- Swati 29-08-2018 , AT-3174 End
            
            GlAp_FieldProps objGlAp_FieldProps = new GlAp_FieldProps();
            objGlAp_FieldProps.buttonField = False;
            objGlAp_FieldProps.editMode = False;
            objGlAp_FieldProps.fieldName = LoAp_Constants.ACTIVEFIELD;
            objGlAp_FieldProps.fieldLabel = LoAp_Constants.ACTIVELABEL;
            objGlAp_FieldProps.parentObject = GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME;
            objGlAp_FieldProps.transformField = True;
            objGlAp_FieldProps.isFLSVisible = False;
            objGlAp_FieldProps.isEditable = False;
            objGlAp_FieldProps.fieldType = LoAp_Constants.TEXT;
            lstFieldProps.add(objGlAp_FieldProps);
            
            GlAp_FieldProps objGlAp_FieldProps1 = new GlAp_FieldProps();
            objGlAp_FieldProps1.buttonField = True;
            objGlAp_FieldProps1.editMode = False;
            objGlAp_FieldProps1.fieldName = Label.LoAp_ChangeBundleField;
            objGlAp_FieldProps1.fieldLabel = LoAp_Constants.CHANGEBUTTONLABEL;
            objGlAp_FieldProps1.parentObject = GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME;
            objGlAp_FieldProps1.transformField = False;
            objGlAp_FieldProps1.isFLSVisible = False;
            objGlAp_FieldProps1.isEditable = False;
            lstFieldProps.add(objGlAp_FieldProps1);
            
            GlAp_FieldProps fieldprop2 = new GlAp_FieldProps(false, false, false, false, LoAp_Constants.ACTION, LoAp_Constants.ACTION, LoAp_Constants.TEXT, false, GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME);
            fieldprop2.buttonField = True;
            lstFieldProps.add(fieldprop2);
            return lstFieldProps;
        }
        catch(Exception e){
            GlUt_Logger.logException(e);
            GlUt_Logger.writeLogsToDatabase();
            throw new AuraHandledException('Error : ' +e.getMessage()); 
        }
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           16 July 2018
    @param          String availableServiceId - Record Id of available service
    @return         List<BlAp_CombinedRecord>
    @description    returns the record of available bundles related to the
                    available service
    *******************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveAvailableBundleRecords(String availableServiceId){
        try{
            lstAvailableBundleFields.add(GlUt_APIConstantsAvailableBundle.BUNDLEAPINAME);
            
            List<AvailableBundle__c> lstAvailableBundle = (List<AvailableBundle__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME, lstAvailableBundleFields, availableServiceId, GlUt_APIConstantsAvailableBundle.AVAILABLESERVICEAPINAME);
            system.debug('retrieveAvailableBundleRecords-lstAvailableBundle => ' + lstAvailableBundle);
            Set<Id> setOfAvailableBundleIds = new Set<Id>();
            Set<Id> setOfBundleIds = new Set<Id>();
            for(AvailableBundle__c objAvailableBundle : lstAvailableBundle){
                setOfAvailableBundleIds.add(objAvailableBundle.id);
                if(objAvailableBundle.Bundle__c != Null)
                    setOfBundleIds.add(objAvailableBundle.Bundle__c);
            }
            system.debug('retrieveAvailableBundleRecords-setOfAvailableBundleIds => ' + setOfAvailableBundleIds);
            Map<Id,Bundle__c> mapOfBundleId2Record = new Map<Id,Bundle__c>();
            for(Bundle__c objBundle : (List<Bundle__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAvailableBundle.BUNDLEAPINAME, 
                                                                                            lstBundleFields,
                                                                                            String.format('WHERE {0} IN {1}',new List<String>{'Id',GlUt_FieldSecurity.IdsToString(setOfBundleIds)})
                                                                                           )){
                 mapOfBundleId2Record.put(objBundle.Id, objBundle);                   
            }
            system.debug('retrieveAvailableBundleRecords-mapOfBundleId2Record => ' + mapOfBundleId2Record);
            Map<Id,Id> mapOfAvailableServiceItemId2AvailableBundleId = new Map<Id,Id>(); 
            Set<Id> setOfAvailableServiceIds = new Set<Id>();
            lstAvailableServiceItemFields.add(GlUt_APIConstantsAvailableServiceItem.ENDDATEAPINAME); // Sudhir: Core Misc.(AT-3738)
            for(AvailableServiceItem__c objAvailableServiceItem : (List<AvailableServiceItem__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAvailableServiceItem.AVAILABLESERVICEITEMSAPINAME, 
                                                                                                                                      lstAvailableServiceItemFields,
                                                                                                                                      String.format('WHERE {0} IN {1}',new List<String>{GlUt_APIConstantsAvailableServiceItem.AVAILABLEBUNDLEAPINAME,GlUt_FieldSecurity.IdsToString(setOfAvailableBundleIds)})
                                                                                                                                     )){
                //Sudhir: added extra check on EndDate__c for active ASI      // Core Misc.(AT-3738)                                                                          
                //if(objAvailableServiceItem.AvailableBundle__c != Null && (objAvailableServiceItem.EndDate__c == null || objAvailableServiceItem.EndDate__c > Date.today())) {
                if(objAvailableServiceItem.AvailableBundle__c != Null) {
                    if(!mapOfAvailableServiceItemId2AvailableBundleId.containsKey(objAvailableServiceItem.Id)) // Sudhir updated
                            mapOfAvailableServiceItemId2AvailableBundleId.put(objAvailableServiceItem.Id, objAvailableServiceItem.AvailableBundle__c);
                    }
					
                //&& (objAvailableServiceItem.EndDate__c == Null || objAvailableServiceItem.EndDate__c > Date.Today())
            }
            system.debug('retrieveAvailableBundleRecords-mapOfAvailableServiceItemId2AvailableBundleId => ' + mapOfAvailableServiceItemId2AvailableBundleId);
            Map<Id,list<ServiceItem__c>> mapOfAvailableBundleId2ServiceItem = new Map<Id,  list<ServiceItem__c>>();
            for(ServiceItem__c objServiceItem : (List<ServiceItem__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME, 
                                                                                            lstServiceItemFields,
                                                                                            String.format('WHERE {0} IN {1}',new List<String>{GlUt_APIConstantsServiceItem.AVAILABLESERVICEITEMAPINAME,GlUt_FieldSecurity.IdsToString(mapOfAvailableServiceItemId2AvailableBundleId.keySet())})
                                                                                           )){
                system.debug('retrieveAvailableBundleRecords-objServiceItem => ' + objServiceItem);                                                                               
                if(objServiceItem.AvailableServiceItem__c != Null && mapOfAvailableServiceItemId2AvailableBundleId.containsKey(objServiceItem.AvailableServiceItem__c) 
                   &&(objServiceItem.EndDate__c == Null || objServiceItem.EndDate__c > Date.Today())){
                    if(!mapOfAvailableBundleId2ServiceItem.containsKey(mapOfAvailableServiceItemId2AvailableBundleId.get(objServiceItem.AvailableServiceItem__c)))
                        mapOfAvailableBundleId2ServiceItem.put(mapOfAvailableServiceItemId2AvailableBundleId.get(objServiceItem.AvailableServiceItem__c), new list<ServiceItem__c> {objServiceItem}) ;
                    mapOfAvailableBundleId2ServiceItem.get(mapOfAvailableServiceItemId2AvailableBundleId.get(objServiceItem.AvailableServiceItem__c)).add(objServiceItem) ;
                }
            }
            system.debug('retrieveAvailableBundleRecords-mapOfAvailableBundleId2ServiceItem => ' + mapOfAvailableBundleId2ServiceItem);
            
            List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
            for(AvailableBundle__c objAvailableBundle : lstAvailableBundle){
                BlAp_CombinedRecord record = new BlAp_CombinedRecord();
                record.isSelected = False;
                record.uniqueId = objAvailableBundle.id;
                record.objectMap = new Map<String, sObject>();
                record.objectMap.put(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME,objAvailableBundle);
                record.objectMap.put(GlUt_APIConstantsBundle.BUNDLEAPINAME, mapOfBundleId2Record.get(objAvailableBundle.Bundle__c)); // -- Swati 29-08-2018 , AT-3174 
                record.transformFieldMap = new Map<String,Map<String,String>>();
                Map<String,String> activeTransformFieldMap = new Map<String,String>();
                record.buttonAttributes = new List<BlAp_CombinedRecord.ButtonAttribute>();
                String buttonStatus = CuAp_Constants.BUTTON_ACTIVE;
                BlAp_CombinedRecord.ButtonAttribute objButton = new BlAp_CombinedRecord.ButtonAttribute(Label.LoAp_ChangeBundleField,LoAp_Constants.CHANGEBUTTONLABEL,buttonStatus);
                record.buttonAttributes.add(objButton);
                if(mapOfAvailableBundleId2ServiceItem.containsKey(objAvailableBundle.id) && mapOfAvailableBundleId2ServiceItem.get(objAvailableBundle.id) != null ) { // Sudhir: Core Misc.(AT-3738)
                    activeTransformFieldMap.put(LoAp_Constants.ACTIVEFIELD,LoAp_Constants.YES);
                    buttonStatus = CuAp_Constants.BUTTON_INACTIVE; 
                } else{
                    activeTransformFieldMap.put(LoAp_Constants.ACTIVEFIELD,LoAp_Constants.NO);
                    if(mapOfBundleId2Record.containsKey(objAvailableBundle.Bundle__c) && mapOfBundleId2Record.get(objAvailableBundle.Bundle__c).TariffLimit__c != True ){ // AT-3280
                        buttonStatus = CuAp_Constants.BUTTON_ACTIVE;
                    } 
                }
                system.debug('retrieveAvailableBundleRecords-buttonStatus => ' + buttonStatus);
                BlAp_CombinedRecord.ButtonAttribute objButton1 = new BlAp_CombinedRecord.ButtonAttribute(LoAp_Constants.ACTION,LoAp_Constants.MAKEACTIVELABEL,buttonStatus);
                record.buttonAttributes.add(objButton1);
                record.transformFieldMap.put(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME, activeTransformFieldMap);
                records.add(record);
            }
            system.debug('retrieveAvailableBundleRecords-records => ' + records);
            return records;
        }
        catch(Exception e){
            GlUt_Logger.logException(e);
            GlUt_Logger.writeLogsToDatabase();
            throw new AuraHandledException('Error : ' +e.getMessage()); 
        }
    }
}