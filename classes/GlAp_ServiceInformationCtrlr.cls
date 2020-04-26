/******************************************************************************
@author         Echo: Amit K.
@date           01 Aug 2018
@description    Generic class controller to fetch the service related information while doing service transfer from
                One contract to another.
*******************************************************************************/
public class GlAp_ServiceInformationCtrlr {
    private static final String CLASS_NAME = 'GlAp_ServiceInformationCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static List<string> serviceFields;
    private static Boolean isChecked = true; //Global variable for select All checkbox.

    static{
        serviceFields = new List<string>();
        serviceFields.add(GlUt_APIConstantsService.SERVICESTARTDATEAPINAME);
        serviceFields.add(GlUt_APIConstantsService.SERVICEENDDATEAPINAME);
    }
    private static List<string> contractFields;
    static{
        contractFields = new List<string>();
    }
    private static List<string> supplyPointFields;
    static{
        supplyPointFields = new List<string>();
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.LOCATIONAPINAME);
    }
    private static List<string> availableServiceFields;
    static{
        availableServiceFields = new List<string>();
    }
    private static List<string> serviceTypeFields;
    static{
        serviceTypeFields = new List<string>();
        serviceTypeFields.add(GlUt_APIConstantsServiceType.NAMEAPINAME);
    }
    private static List<string> locationFields;
    static{
        locationFields = new List<string>();
        locationFields.add(GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME);
    }
    /**********************************************************************************************
    @author      : Echo:Amit K.
    @date        : 01 Aug 2018
    @params      : 
    @return      : List<GLAp_FieldProps>
    @description : This method returns Service,Service Type and Supply Point Transform fields as List. 
    **********************************************************************************************/
    @AuraEnabled
	public static List<GLAp_FieldProps> retrievePropDetails(Id contractId,Id supplyPointId) {
		List<GLAp_FieldProps> serviceTypeProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME, serviceTypeFields);
        List<GLAp_FieldProps> serviceProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsService.SERVICEAPINAME, serviceFields);
	    List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        //Field properties for Service Type object.
        for (GLAp_FieldProps fldProp : serviceTypeProps) {
            if (fldProp.fieldName == GlUt_APIConstantsServiceType.NAMEAPINAME) {
                fldProp.isEditable = false;
                fldPropList.add(fldProp); 
            }
        }

        //Transform Field for Supply Point
        GLAp_FieldProps spProp = new GLAp_FieldProps();
        spProp.isFLSVisible = false;
        spProp.isEncrypted  = false;
        spProp.isEditable   = true;
        spProp.isRequired   = false;
        spProp.fieldName    = GlUt_APIConstantsService.SUPPLYPOINTAPINAME;
        spProp.fieldLabel   = CuAp_Constants.SUPPLYPOINTNAMELABEL;
        spProp.fieldType    = LoAp_Constants.REFERENCEFIELD;
        spProp.transformField = true; 
        spProp.parentObject = GlUt_APIConstantsService.SUPPLYPOINTAPINAME;
        fldPropList.add(spProp);
        //Transform Field for Location Address
        GLAp_FieldProps locProp = new GLAp_FieldProps();
        locProp.isFLSVisible = false;
        locProp.isEncrypted  = false;
        locProp.isEditable   = true;
        locProp.isRequired   = false;
        locProp.fieldName    = GlUt_APIConstantsLocation.LOCATIONAPINAME;
        locProp.fieldLabel   = CuAp_Constants.LOCATIONADDRESSLABEL;
        locProp.fieldType    = LoAp_Constants.TEXT;
        locProp.transformField = true; 
        locProp.parentObject = GlUt_APIConstantsLocation.LOCATIONAPINAME;
        fldPropList.add(locProp);
        //Field properties for Service object.
        for (GLAp_FieldProps fldProp : serviceProps) {
            if(string.isNotBlank(supplyPointId)){
                //Skip fields properties for Service Start Date and Service end date in case of supply point.
                if(fldProp.fieldName != GlUt_APIConstantsService.SERVICESTARTDATEAPINAME && fldProp.fieldName != GlUt_APIConstantsService.SERVICEENDDATEAPINAME){
                    fldProp.isEditable = false;
                    fldPropList.add(fldProp);
                }
            }else{
                fldProp.isEditable = false;
                fldPropList.add(fldProp);
            }
        }
		return fldPropList;
	}
    
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 01 Aug 2018
    @return      : List<BlAp_CombinedRecord>
    @parameter   : Id contractId,Id supplyPointId
    @description : This method returns the BlAp_CombinedRecord with list of --, and it's unique-ids, isSelected
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> getServiceRelatedInformation(Id contractId,Id supplyPointId){
        List<BlAp_CombinedRecord>  serviceCombinedList = new List<BlAp_CombinedRecord>(); //Combined service list collection.
        Savepoint sPoint = Database.setSavepoint();
        try{
            if(string.isNotBlank(contractId)){
              serviceCombinedList = getServiceInfoFromContractNumber(contractId); //Fetch service related information on the basis of contract Id.
            }else if(string.isNotBlank(supplyPointId)){
                serviceCombinedList = getServiceInfoFromSupplyPointNumber(supplyPointId);//Fetch service related information on the basis of supply Point Id.
            }
        }
        catch (exception e){
            GlUt_Logger.logException(e);
            Database.rollback(sPoint);
            throw new AuraHandledException(e.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return serviceCombinedList;
    }
    
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 01 Aug 2018
    @return      : ContainerWrapper
    @parameter   : List<Id> periodIds
    @description : This is a wrapper class include the List of Unique Depot and Area Names,Combined List
                   records,FieldProperty Details.
    **********************************************************************************************/
    @AuraEnabled
    Public static ContainerWrapper getInfoToDisplay(Id contractId,Id supplyPointId){
        //instance of wrapper class
        ContainerWrapper resultContainer = new ContainerWrapper(); 
        //call to method to get field properties
        resultContainer.fieldPropList = retrievePropDetails(contractId,supplyPointId);
        //Call Method to get the service OR available service Details
        resultContainer.combinedList = getServiceRelatedInformation(contractId,supplyPointId);
        resultContainer.isChecked = isChecked; // Set the Select All check box in wrapper.
        return resultContainer;
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 01 Aug 2018
    @return      : ContainerWrapper
    @description : This is a wrapper class Combined List records,FieldProperty Details.
    **********************************************************************************************/
    public class ContainerWrapper {
        @AuraEnabled public List<GLAp_FieldProps> fieldPropList = new List<GLAp_FieldProps>(); //Field Property List.
        @AuraEnabled public List<BlAp_CombinedRecord> combinedList = new List<BlAp_CombinedRecord>(); //Combined record list
        @AuraEnabled public Boolean isChecked = true; //By Default True for Select All check box on UI.

    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 01 Aug 2018
    @return      : List<BlAp_CombinedRecord>
    @parameter   : Id supplyPointId
    @description : This method returns the BlAp_CombinedRecord with list of --, and it's unique-ids, isSelected
    **********************************************************************************************/
    public static List<BlAp_CombinedRecord> getServiceInfoFromSupplyPointNumber(Id supplyPointId) {
        List<BlAp_CombinedRecord>  serviceCombinedList = new List<BlAp_CombinedRecord>(); // Available Service combined record.
        Map<Id,ServiceType__c> mapOfServiceTypeId2ServiceType = new Map<Id,ServiceType__c>(); // map of Service Type Id having Service Type record.
        List<Id> lstreferencefield = new List<Id>();
        List<ServiceType__c> serviceTypeList = new List<ServiceType__c>(); // Service Type record List
        List<SupplyPoint__c> spList = new  List<SupplyPoint__c>(); // S.P record List.
        List<Location__c> LocationList = new  List<Location__c>(); // Location record List.
        Map<Id,String> supplyPointIdReferenceNameMap = new Map<Id,String>(); // map of S.P Id having Referenced S.P field Name.
        List<Service__c> serviceList = new List<Service__c>(); // Service list.
        Map<Id,Id> mapOfServiceId2ServiceTypeId = new Map<Id,Id>(); // map of Service ID having Service Type Id.
        Map<Id,Id> mapOfASId2SupplyPointId = new Map<Id,Id>();  // map of Available Service having Supply Point Id.
        Map<Id,Id> mapOfSupplyPointId2LocationId = new Map<Id,Id>(); // map of Supply Point Id having Location Id.
        Map<Id,String> mapOfLocationId2LocationAddress = new Map<Id,String>(); // map of Location Id having Location Address.
        //Available Service fields information.
        availableServiceFields.add(GlUt_APIConstantsAvailableService.SERVICETYPEAPINAME);
        availableServiceFields.add(GlUt_APIConstantsAvailableService.SUPPLYPOINTAPINAME);
        List<AvailableService__c> availableServiceList = new List<AvailableService__c>();
        Map<Id,Id> mapOfAvailableServiceId2ServiceType = new Map<Id,Id>(); // map of Available Service Id having Service Type Id.
            availableServiceList = GlUt_ServiceUtilities.getAvailableServiceFromSupplyPointId(supplyPointId,availableServiceFields); //Fetch Available Service from S.P Id.
            if(availableServiceList != null && !availableServiceList.isEmpty()){
                for(AvailableService__c availableService : availableServiceList){
                    if(availableService.SupplyPoint__c!=null)
                        mapOfASId2SupplyPointId.put(availableService.Id,availableService.SupplyPoint__c); // fill map of Available Service having Supply Point Id.
                    mapOfAvailableServiceId2ServiceType.put(availableService.Id,availableService.ServiceType__c); // fill map of Available Service Id having Service Type Id.
                }
            }
            if(mapOfAvailableServiceId2ServiceType.values().size() > 0){
                serviceTypeList = GlUt_ServiceUtilities.getServiceTypeFromServiceTypeId(mapOfAvailableServiceId2ServiceType.values(),serviceTypeFields); // Fetch Service Type from Service Type Id.
                if(serviceTypeList != null && !serviceTypeList.isEmpty()){
                    for(ServiceType__c sType: serviceTypeList){
                        mapOfServiceTypeId2ServiceType.put(sType.Id,sType); // fill map of Service Type Id having Service Type record.
                    }
                }
            }
        
        if(mapOfASId2SupplyPointId.values().size() > 0){
            supplyPointIdReferenceNameMap = GlUt_ServiceUtilities.getRecordName(mapOfASId2SupplyPointId.values()); // Fetch S.P referenced field informtion on the basis of S.P record Id.
            spList = GlUt_ServiceUtilities.getSupplyPointInfoFromServiceSupplyPointId(mapOfASId2SupplyPointId.values(),supplyPointFields); //Fetch Supply Point information on the basis of Servie-->S.P Id. 
             if(!spList.isEmpty()){
                 for(SupplyPoint__c sp: spList){
                     mapOfSupplyPointId2LocationId.put(sp.Id,sp.Location__c); // fill map of S.P Id having Location Id.
                 }
                 if(mapOfSupplyPointId2LocationId.values().size() > 0){
                     LocationList = GlUt_ServiceUtilities.getLocationInfoFromServiceSupplyPointLocationId(mapOfSupplyPointId2LocationId.values(),locationFields); // Fetch Location information on the basis of Service-->S.P-->Location Id.
                     for(Location__c loc: LocationList){
                         mapOfLocationId2LocationAddress.put(loc.Id,loc.Address__c); // fill map of Location Id having Location Address.
                     }
                 }
             }
        }
        if(availableServiceList != null && !availableServiceList.isEmpty()){
            for (AvailableService__c avService: availableServiceList){
                BlAp_CombinedRecord objServiceCom = new BlAp_CombinedRecord(); 
                objServiceCom.uniqueId = avService.Id;
                objServiceCom.isSelected = false;
                objServiceCom.objectMap = new Map<string, sObject>();
                //Create a map of Available service object and records.
                objServiceCom.objectMap.put(GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME, avService);
                //Create a map of Service Type object and records.
                objServiceCom.objectMap.put(GlUt_APIConstantsAvailableService.SERVICETYPEAPINAME,mapOfServiceTypeId2ServiceType.get(mapOfAvailableServiceId2ServiceType.get(avService.Id)));
                objServiceCom.transformFieldMap = new Map<String,Map<String,String>>();
                if(!supplyPointIdReferenceNameMap.isEmpty()){
                    Map<String,String> supplyPointTransformFieldMap = new Map<String,String>();
                    if(supplyPointIdReferenceNameMap.containsKey(avService.SupplyPoint__c)){
                        supplyPointTransformFieldMap.put(avService.SupplyPoint__c,
                                                         supplyPointIdReferenceNameMap.get(avService.SupplyPoint__c));
                        objServiceCom.transformFieldMap.put(GlUt_APIConstantsService.SUPPLYPOINTAPINAME,supplyPointTransformFieldMap); //Create Transform field map for S.P object with it's name Information.
                    }
                }
                //Select All option false on UI if any row is unchecked i.e. isSelected = false.
                if(!objServiceCom.isSelected)
                    isChecked = false;
                Map<String,String> LocationTransformFieldMap = new Map<String,String>();
                LocationTransformFieldMap.put(GlUt_APIConstantsLocation.LOCATIONAPINAME,
                                               mapOfLocationId2LocationAddress.get(mapOfSupplyPointId2LocationId.get(mapOfASId2SupplyPointId.get(avService.Id))));
                objServiceCom.transformFieldMap.put(GlUt_APIConstantsLocation.LOCATIONAPINAME,LocationTransformFieldMap); //Create Transform field map for Location object having it's address information.
                serviceCombinedList.add(objServiceCom);
            }
        }
        return serviceCombinedList;
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 01 Aug 2018
    @return      : List<BlAp_CombinedRecord>
    @parameter   : Id contractId
    @description : This method returns the BlAp_CombinedRecord with list of --, and it's unique-ids, isSelected
    **********************************************************************************************/
    public static List<BlAp_CombinedRecord> getServiceInfoFromContractNumber(Id contractId) {
        List<BlAp_CombinedRecord>  serviceCombinedList = new List<BlAp_CombinedRecord>(); // Service combined record list,
        Map<Id,ServiceType__c> mapOfServiceTypeId2ServiceType = new Map<Id,ServiceType__c>(); // map of Service Type Id having Service Type record.
        List<ServiceType__c> serviceTypeList = new List<ServiceType__c>(); // Service Type record List.
        Map<Id,String> supplyPointIdReferenceNameMap = new Map<Id,String>(); // map of S.P Id having refrenced name field.
        List<Service__c> serviceList = new List<Service__c>(); // Service record list.
        List<SupplyPoint__c> spList = new  List<SupplyPoint__c>(); // Supply Point record list.
        List<Location__c> LocationList = new  List<Location__c>(); // location record list.
        Map<Id,Id> mapOfServiceId2ServiceTypeId = new Map<Id,Id>(); // map of Service Id having Service Type Id.
        Map<Id,Id> mapOfServiceId2SupplyPointId = new Map<Id,Id>(); // map of Service Id having S.P Id.
        Map<Id,Id> mapOfSupplyPointId2LocationId = new Map<Id,Id>(); // map of S.P ID having location Id.
        Map<Id,String> mapOfLocationId2LocationAddress = new Map<Id,String>(); // map of Location Id having Loc Address.
        //Service Fields information.
        serviceFields.add(GlUt_APIConstantsService.SERVICETYPEAPINAME);
        serviceFields.add(GlUt_APIConstantsService.SUPPLYPOINTAPINAME);
        
        //Fetch Services on the basis of contract Id.
        serviceList = GlUt_ServiceUtilities.getServicesFromContractId(contractId,serviceFields);
        if(serviceList != null && !serviceList.isEmpty()){
            for(Service__c service: serviceList){
                if(service.SupplyPoint__c != null){
                    mapOfServiceId2SupplyPointId.put(service.Id,service.SupplyPoint__c); // fill map of Service Id having S.P Id.
                }
                mapOfServiceId2ServiceTypeId.put(service.Id,service.ServiceType__c);// fill map of Service Id having Service Type Id.
            }
        }
        if(mapOfServiceId2ServiceTypeId.values().size() > 0){
            //Fetch Service Type records on the basis of Service Type Ids.
            serviceTypeList = GlUt_ServiceUtilities.getServiceTypeFromServiceTypeId(mapOfServiceId2ServiceTypeId.values(),serviceTypeFields);
            if(serviceTypeList != null && !serviceTypeList.isEmpty()){
                for(ServiceType__c sType: serviceTypeList){
                    mapOfServiceTypeId2ServiceType.put(sType.Id,sType); // fill map of Service Type Id having Service Type record.
                }
            }
        }
         if(mapOfServiceId2SupplyPointId.values().size() > 0){
             //Fetch S.P Name reference field.
             supplyPointIdReferenceNameMap = GlUt_ServiceUtilities.getRecordName(mapOfServiceId2SupplyPointId.values());
             //Fetch S.P records on the basis of Service-->S.P Id
             spList = GlUt_ServiceUtilities.getSupplyPointInfoFromServiceSupplyPointId(mapOfServiceId2SupplyPointId.values(),supplyPointFields);
             if(!spList.isEmpty()){
                 for(SupplyPoint__c sp: spList){
                     mapOfSupplyPointId2LocationId.put(sp.Id,sp.Location__c); // fill map of S.P ID having location Id.
                 }
                 if(mapOfSupplyPointId2LocationId.values().size() > 0){
                     //Fetch Location record on the basis of Service-->S.P-->Location Id.
                     LocationList = GlUt_ServiceUtilities.getLocationInfoFromServiceSupplyPointLocationId(mapOfSupplyPointId2LocationId.values(),locationFields);
                     for(Location__c loc: LocationList){
                         mapOfLocationId2LocationAddress.put(loc.Id,loc.Address__c); //fill  map of Location Id having Loc Address.
                     }
                 }
             }
         }
        System.debug('*****supplyPointIdReferenceNameMap'+supplyPointIdReferenceNameMap);
        if(serviceList != null && !serviceList.isEmpty()){
            for (Service__c service: serviceList){
                BlAp_CombinedRecord objServiceCom = new BlAp_CombinedRecord(); 
                objServiceCom.uniqueId = service.Id;
                objServiceCom.isSelected = false;
                objServiceCom.objectMap = new Map<string, sObject>();
                //Create a map of service related field values
                objServiceCom.objectMap.put(GlUt_APIConstantsService.SERVICEAPINAME, service);
                //Create a map of service type related field values
                objServiceCom.objectMap.put(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME,mapOfServiceTypeId2ServiceType.get(mapOfServiceId2ServiceTypeId.get(service.Id)));
                objServiceCom.transformFieldMap = new Map<String,Map<String,String>>();
                if(!supplyPointIdReferenceNameMap.isEmpty()){
                    Map<String,String> supplyPointTransformFieldMap = new Map<String,String>();
                    if(supplyPointIdReferenceNameMap.containsKey(service.SupplyPoint__c)){
                        supplyPointTransformFieldMap.put(service.SupplyPoint__c,
                                                         supplyPointIdReferenceNameMap.get(service.SupplyPoint__c));
                        //Create a map of S.P related field values
                        objServiceCom.transformFieldMap.put(GlUt_APIConstantsService.SUPPLYPOINTAPINAME,supplyPointTransformFieldMap);
                    }
                }
                 //Select All option false on UI if any row is unchecked i.e. isSelected = false.
                if(!objServiceCom.isSelected)
                    isChecked = false;
                Map<String,String> LocationTransformFieldMap = new Map<String,String>();
                LocationTransformFieldMap.put(GlUt_APIConstantsLocation.LOCATIONAPINAME,
                                               mapOfLocationId2LocationAddress.get(mapOfSupplyPointId2LocationId.get(mapOfServiceId2SupplyPointId.get(service.Id))));
                //Create a map of Location related field values
                objServiceCom.transformFieldMap.put(GlUt_APIConstantsLocation.LOCATIONAPINAME,LocationTransformFieldMap);
                serviceCombinedList.add(objServiceCom);
            }
        }
        return serviceCombinedList;
        
    }
   
}