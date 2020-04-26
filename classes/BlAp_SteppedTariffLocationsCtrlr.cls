/************************************************************************************************************
@author      : Echo: Ankit Gangwani
@date        : 17 July 2018
@description : BlAp_SteppedTariffLocationsCtrlr class is used to display stepped tariff fields for service type selection
**************************************************************************************************************/
public with sharing class BlAp_SteppedTariffLocationsCtrlr {
    
    private static List<String> steppedTariffFields;
    private static List<String> serviceFields;
    private static List<String> locationFields;
    private static List<String> steppedTariffServiceFields;
    private static final String CLASS_NAME = LoAp_Constants.STLocationClassLabel;
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    static{
        // Get Fields from the Stepped Tariff Object
        steppedTariffFields = new List<string>();
        steppedTariffFields.add(GlUt_APIConstantsSteppedTariff.STARTDATEAPINAME);
        steppedTariffFields.add(GlUt_APIConstantsSteppedTariff.ENDDATEAPINAME);
        
        // Get Fields from the Stepped Tariff Service Object
        steppedTariffServiceFields = new List<String>();
        steppedTariffServiceFields.add(GlUt_APIConstantsSteppedTariff.STEPPEDTARIFFAPINAME);
        steppedTariffServiceFields.add(GlUt_APIConstantsSteppedTariffService.STARTDATEAPINAME);
        steppedTariffServiceFields.add(GlUt_APIConstantsSteppedTariffService.ENDDATEAPINAME);
        steppedTariffServiceFields.add(GlUt_APIConstantsSteppedTariffService.SERVICEAPINAME);        
         
        
        // Get Fields from the Service Object
        serviceFields = new List<String>();
        serviceFields.add(GlUt_APIConstantsService.NAMEAPINAME);
        serviceFields.add(GlUt_APIConstantsService.SERVICESTARTDATEAPINAME);
        serviceFields.add(GlUt_APIConstantsService.SERVICEENDDATEAPINAME);
        
        // Get Fields from the Location Object
        locationFields = new List<String>();
        locationFields.add(GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME);                
    }
    
    /**********************************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 17 July 2018
    @return      : List<GLAp_FieldProps>
    @description : This method returns the field properties for each of the fields that are
    to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrieveSteppedTariffFields(String wizardType) {
        try {
            List<String> durationInMonthsList = new List<String>{'','3','6','9','12','15','18'};
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            List<GLAp_FieldProps> allFieldProp = new List<GLAp_FieldProps>();            
            
            // Create the Service Type read-only field to display the data from 2nd screen (Select Type of Step Tariff)
            GlAp_FieldProps serviceTypePicklist = new GlAp_FieldProps();
            serviceTypePicklist.isFLSVisible = true;
            serviceTypePicklist.isEditable = false;
            serviceTypePicklist.editMode = false;
            serviceTypePicklist.fieldName = CuAp_Constants.SERVICETYPEFIELD;
            serviceTypePicklist.fieldLabel = CuAp_Constants.SERVICETYPELABEL;
            serviceTypePicklist.fieldType = 'text';
            serviceTypePicklist.isRequired = false;
            serviceTypePicklist.changeEvent = false;
            serviceTypePicklist.parentObject = GlUt_APIConstantsSteppedTariff.STEPPEDTARIFFAPINAME;            
            allFieldProp.add(serviceTypePicklist);
            
            // Create the Picklist field - "Duration In Months" only when the wizard process is = "Add new step tariff"
            // Values = "3,6,9,12,15,18"
            if(wizardType == System.Label.BlAp_NewStepTariff){
                GlAp_FieldProps durationInMonths = new GlAp_FieldProps();
                durationInMonths.isFLSVisible = true;
                durationInMonths.isEditable = true;
                durationInMonths.editMode = true;
                durationInMonths.fieldName = CuAp_Constants.DURATIONINMONTHSFIELD;
                durationInMonths.fieldLabel = CuAp_Constants.DURATIONINMONTHSLABEL;
                durationInMonths.isRequired = false;
                durationInMonths.changeEvent = false;
                durationInMonths.fieldType = 'select';
                durationInMonths.parentObject = GlUt_APIConstantsSteppedTariff.STEPPEDTARIFFAPINAME;
                durationInMonths.pickListValues = durationInMonthsList;
                allFieldProp.add(durationInMonths);
            }
            
            // get the field properties of Stepped Tairf object
            List<GLAp_FieldProps> steppedTariffProp = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsSteppedTariff.STEPPEDTARIFFAPINAME, steppedTariffFields); 
            
            for(GlAp_FieldProps fieldProp:steppedTariffProp){
                if(fieldProp.fieldName == GlUt_APIConstantsSteppedTariff.STARTDATEAPINAME || fieldProp.fieldName == GlUt_APIConstantsSteppedTariff.ENDDATEAPINAME){
                    fieldProp.isEditable = false;
                    fieldProp.editMode = false;
                    fieldProp.fieldType = 'text';
                    fieldProp.isFLSVisible = false;
                }
                allFieldProp.add(fieldProp);
            }
            
            // display the field in 2 column pattern
            for(Integer i=0; i < allFieldProp.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                Integer secondEntryIndex = i+1;
                lstEntry.add(allFieldProp[i]);
                
                if(secondEntryIndex < allFieldProp.size()){
                    lstEntry.add(allFieldProp[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
            }
            
            return twoColFormattedList;
        }catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }   
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Ankit Gangwani
    @date        : 17 July 2018
    @return      : List<GLAp_FieldProps>
    @description : This method returns the field properties for each of the fields that are
    to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveServicefieldList(){
        try {
            List<GLAp_FieldProps> addServiceFieldProps = new List<GLAp_FieldProps>();
            //Get the field properties for the Services object AT-3794
            List<GLAp_FieldProps> serviceProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsService.SERVICEAPINAME , serviceFields); 
            for(GlAp_FieldProps objProp: serviceProps){
                if(objProp.fieldName == GlUt_APIConstantsService.NAMEAPINAME){
                    objProp.fieldLabel = CuAp_Constants.SERVICELABEL;
                    addServiceFieldProps.add(objProp);
                }                
            }
            
            
            //Get the field properties for the Location object            
            List<GLAp_FieldProps> locationProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsLocation.LOCATIONAPINAME, locationFields); 
            for(GlAp_FieldProps objProp: locationProps){
                if(objProp.fieldName == GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME){
                    objProp.fieldLabel = CuAp_Constants.ADDRESSLABEL;
                }
                addServiceFieldProps.add(objProp);
            }
            
            //Get the field properties for the Service object
            List<GLAp_FieldProps> steppedTariffServiceProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsSteppedTariffService.STEPPEDTARIFFSERVICEAPINAME, steppedTariffServiceFields); 
            
            for(GLAp_FieldProps objProp: steppedTariffServiceProps){
                
                if(objProp.fieldName == GlUt_APIConstantsSteppedTariffService.STARTDATEAPINAME){
                    objProp.isEditable = true;
                    objProp.fieldLabel = CuAp_Constants.STARTDATELABEL;
                }
                
                if(objProp.fieldName == GlUt_APIConstantsSteppedTariffService.ENDDATEAPINAME){
                    objProp.isEditable = true;
                    objProp.fieldLabel = CuAp_Constants.ENDDATELABEL;                    
                }
                addServiceFieldProps.add(objProp);
            }            
            
            return addServiceFieldProps;
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
	@author      	Echo: Ankit Gangwani
	@date      		19 July 2018	
	@description	wrapper class to hold the stepped tariff information
	*******************************************************************************/
    public class steppedTariffInfo {
        @AuraEnabled public Boolean isChecked = true;
        @AuraEnabled public List<BlAp_CombinedRecord> serviceRecordCombinedList;
    }
    
    /**********************************************************************************************
    @author      : Echo : Ankit Gangwani
    @date        : 17 July 2018
    @param       : String ContractId
    @return      : List<BlAp_CombinedRecord>
    @description : This method returns the BlAp_CombinedRecord with list of Service, Location, unique-ids, isSelected and readOnlyFields
    **********************************************************************************************/
    @AuraEnabled
    public static steppedTariffInfo retrieveSTSRecords(String SteppedTariffId) {
        // Create the instance of the wrapper
        steppedTariffInfo objSteppedTariffInfo = new steppedTariffInfo();        
        try {
            objSteppedTariffInfo.serviceRecordCombinedList = new List<BlAp_CombinedRecord>();            
            Map<Id,Id> mapOfSTSId2ServiceId = new Map<Id,Id>();
            Map<Id,Id> mapOfServiceId2SupplyPointId = new Map<Id,Id>();
            Map<Id,Id> mapOfSupplyPointId2LocationId = new Map<Id,Id>();
            Map<Id,Location__c> mapOfLocationId2Location = new Map<Id,Location__c>();
            
            String soqlQuery ='';            
            /*soqlQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,' + GlUt_APIConstantsService.SERVICEAPINAME + ',' + 
                GlUt_APIConstantsSteppedTariff.STEPPEDTARIFFAPINAME + ',' + 
                String.join(steppedTariffServiceFields,','), 
                GlUt_APIConstantsSteppedTariffService.STEPPEDTARIFFSERVICEAPINAME + 
                ' WHERE ' + GlUt_APIConstantsSteppedTariff.STEPPEDTARIFFAPINAME + ' =\'' + String.escapeSingleQuotes(SteppedTariffId) + '\''});        */    
            
          
            
            // get all the stepped tariff services records associated with stepped tariff 
           // List<SteppedTariffService__c> steppedTariffServices = Database.query(soqlQuery); 
            String filterStatement = ' WHERE ' + GlUt_APIConstantsSteppedTariff.STEPPEDTARIFFAPINAME +' =\'' + String.escapeSingleQuotes(SteppedTariffId) + '\'';
            List<SteppedTariffService__c> steppedTariffServices = (List<SteppedTariffService__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSteppedTariffService.STEPPEDTARIFFSERVICEAPINAME, 
                                                                                                                                      steppedTariffServiceFields, 
                                                                                                                                      filterStatement);
            // Iterate the stepped tariff service list to get all the service ids 
            for(SteppedTariffService__c objSTS : steppedTariffServices){
                mapOfSTSId2ServiceId.put(objSTS.Id, objSTS.Service__c);
            }
            // get all the service records based on their ids
            List<Service__c> servicesList = (List<Service__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsService.SERVICEAPINAME,
                                                                                                   new List<String>{LoAp_Constants.Id,GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME},
                                                                                                   'WHERE ' + LoAp_Constants.Id + ' IN ' + GlUt_FieldSecurity.IdsToString(mapOfSTSId2ServiceId.values())); 
            // Iterate the service list to get supply points 
            for(Service__c objService: servicesList){
                if(objService.SupplyPoint__c != null)
                    mapOfServiceId2SupplyPointId.put(objService.Id, objService.SupplyPoint__c);
            }
            
            // get all the supply point records
            List<SupplyPoint__c> supplyPointLists = (List<SupplyPoint__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,
                                                                                                   new List<String>{LoAp_Constants.Id,GlUt_APIConstantsLocation.LOCATIONAPINAME},
                                                                                                   'WHERE ' + LoAp_Constants.Id + ' IN ' + GlUt_FieldSecurity.IdsToString(mapOfServiceId2SupplyPointId.values())); 
            // Iterate the supply point lists to get the location id
            for(SupplyPoint__c objSupplyPoint : supplyPointLists){
                if(objSupplyPoint.Location__c != null){
                    mapOfSupplyPointId2LocationId.put(objSupplyPoint.Id, objSupplyPoint.Location__c);
                }                
            }
            
            // get the location address from location id
            List<Location__c> locationLists = (List<Location__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocation.LOCATIONAPINAME,
                                                                                                   new List<String>{LoAp_Constants.Id,GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME},
                                                                                                   'WHERE ' + LoAp_Constants.Id + ' IN ' + GlUt_FieldSecurity.IdsToString(mapOfSupplyPointId2LocationId.values())); 
            for(Location__c objLocation : locationLists){
                mapOfLocationId2Location.put(objLocation.Id,objLocation);
            }

            // Process the BlAp_CombinedRecord method 
            for (SteppedTariffService__c objSTS : steppedTariffServices) { 
                BlAp_CombinedRecord steppedTariffComb = new BlAp_CombinedRecord();            
                steppedTariffComb.uniqueId			= objSTS.Id;
                steppedTariffComb.isSelected 		= true;
                steppedTariffComb.readOnlyFields 	= new Map<string, boolean>();
                steppedTariffComb.objectMap 		= new Map<string, sObject>();
                steppedTariffComb.objectMap.put(GlUt_APIConstantsSteppedTariffService.STEPPEDTARIFFSERVICEAPINAME, objSTS);
                steppedTariffComb.objectMap.put(GlUt_APIConstantsLocation.LOCATIONAPINAME,mapOfLocationId2Location.get(mapOfSupplyPointId2LocationId.get(mapOfServiceId2SupplyPointId.get(mapOfSTSId2ServiceId.get(objSTS.Id)))));
                if(!steppedTariffComb.isSelected)
                    objSteppedTariffInfo.isChecked = false;
                objSteppedTariffInfo.serviceRecordCombinedList.add(steppedTariffComb);
            }
            return objSteppedTariffInfo;
        }catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }   
    }
    
    /**********************************************************************************************
    @author      : Echo : Ankit Gangwani
    @date        : 17 July 2018
    @param       : String ContractId
    @return      : List<BlAp_CombinedRecord>
    @description : This method returns the BlAp_CombinedRecord with list of Service, Location, unique-ids, isSelected and readOnlyFields
    **********************************************************************************************/
    @AuraEnabled
    public static steppedTariffInfo retrieveServicerecordList(String ContractId, String serviceType) {
        
        // Create the instance of the wrapper
        steppedTariffInfo objSteppedTariffInfo = new steppedTariffInfo();        
        try {    
            Set<Id> serviceTypeIds = new Set<Id>();
            Map<Id,Id> mapOfServiceId2SupplyPointId = new Map<Id,Id>();
            Map<Id,Id> mapOfSupplyPointId2LocationId = new Map<Id,Id>();
            Map<Id,Location__c> mapOfLocationId2Location = new Map<Id,Location__c>();
            Map<Id,SteppedTariffService__c> mapOfServiceId2STS = new Map<Id,SteppedTariffService__c>();
            objSteppedTariffInfo.serviceRecordCombinedList = new List<BlAp_CombinedRecord>();
            
            // Dummy instance of stepped tariff service object
            SteppedTariffService__c dummySTS = new SteppedTariffService__c();
            dummySTS.StartDate__c = Date.today();
            dummySTS.EndDate__c = null;
            
            /*String soqlQuery ='';
            soqlQuery = String.format('SELECT {0} FROM {1}', new List<String>{LoAp_Constants.Id + ',' + GlUt_APIConstantsServiceType.NAMEAPINAME, 
            GlUt_APIConstantsServiceType.SERVICETYPEAPINAME + ' WHERE ' + GlUt_APIConstantsServiceType.NAMEAPINAME + ' =\'' + String.escapeSingleQuotes(serviceType) + '\''});   
            
            
            List<ServiceType__c> serviceTypeLists = Database.query(soqlQuery); */
            // Get all the service type records based on service type            
            String filterStatement =' WHERE ' + GlUt_APIConstantsServiceType.NAMEAPINAME + ' =\'' + String.escapeSingleQuotes(serviceType) + '\'';
            List<ServiceType__c> serviceTypeLists=(List<ServiceType__c>)GlAp_LightningDataAccess.getRecords( GlUt_APIConstantsServiceType.SERVICETYPEAPINAME, 
                                                                                                            new List<String>{GlUt_APIConstantsServiceType.NAMEAPINAME}, 
                                                                                                            filterStatement);
            if(serviceTypeLists != null && !serviceTypeLists.isEmpty()){
                for(ServiceType__c objServiceType : serviceTypeLists){
                    serviceTypeIds.add(objServiceType.Id);
                }
            }
            
            // Get all the service item family records from service type id set 
            List<ServiceItemFamily__c> serviceItemFamilyList = (List<ServiceItemFamily__c>) GlAp_LightningDataAccess.getRecords(GlUt_ApiConstantsServiceItemFamily.SRVCITEMFMLYAPINAME,
                                                                                                                                new List<String>{LoAp_Constants.Id,
                                                                                                                                    GlUt_ApiConstantsServiceItemFamily.ALGORITHMTYPEAPINAME,
                                                                                                                                    GlUt_APIConstantsServiceType.SERVICETYPEAPINAME},
                                                                                                                                'WHERE ' + GlUt_APIConstantsServiceType.SERVICETYPEAPINAME + 
                                                                                                                                ' IN ' + GlUt_FieldSecurity.IdsToString(serviceTypeIds)); 
            // Clear the set of service type ids to make it reusuable
            serviceTypeIds.clear();
            
            // Iterate the service item family list to check service item family should be "Measured Billing"
            if(serviceItemFamilyList != null && !serviceItemFamilyList.isEmpty()){
                for(ServiceItemFamily__c objSIF : serviceItemFamilyList){
                    if(objSIF.AlgorithmType__c == System.Label.BlAp_MeasuredBilling)
                        serviceTypeIds.add(objSIF.ServiceType__c);
                }
            }
           
            // Get all the service records based on "Measured Billing" service item family, associated with contract and not ended services
            List<Service__c> servicesList = (List<Service__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsService.SERVICEAPINAME,
                                                                                                   new List<String>{LoAp_Constants.Id,GlUt_APIConstantsService.NAMEAPINAME,GlUt_ApiConstantsSupplyPoint.SUPPLYPOINTAPINAME},
                                                                                                   ' WHERE ' + GlUt_APIConstantsContracts.CONTRACTAPINAME + ' =\'' + 
                                                                                                   String.escapeSingleQuotes(ContractId) + '\'' +
                                                                                                   ' AND (' + GlUt_APIConstantsService.SERVICEENDDATEAPINAME + ' >= TODAY OR ' + 
                                                                                                   GlUt_APIConstantsService.SERVICEENDDATEAPINAME + ' = null)' + 
                                                                                                   ' AND ' + GlUt_APIConstantsServiceType.SERVICETYPEAPINAME + 
                                                                                                   ' IN ' + GlUt_FieldSecurity.IdsToString(serviceTypeIds)); 
            
            // Iterate the service list to get the supply points
            if(servicesList != null && !servicesList.isEmpty()){
                for(Service__c objService: servicesList){
                    if(objService.SupplyPoint__c != null)
                        mapOfServiceId2SupplyPointId.put(objService.Id, objService.SupplyPoint__c);
                }
            }

            // Get all the stepped tariff service records based on service ids
            List<SteppedTariffService__c> STSLists = (List<SteppedTariffService__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSteppedTariffService.STEPPEDTARIFFSERVICEAPINAME,
                                                                                                                         new List<String>{LoAp_Constants.Id,
                                                                                                                             GlUt_APIConstantsService.SERVICEAPINAME,
                                                                                                                             GlUt_APIConstantsSteppedTariffService.STARTDATEAPINAME,
                                                                                                                             GlUt_APIConstantsSteppedTariffService.ENDDATEAPINAME},
                                                                                                                         'WHERE ' + GlUt_APIConstantsService.SERVICEAPINAME + 
                                                                                                                         ' IN ' + GlUt_FieldSecurity.IdsToString(mapOfServiceId2SupplyPointId.keySet())); 
            if(STSLists != null && !STSLists.isEmpty()){
                for(SteppedTariffService__c objSTS : STSLists){
                    mapOfServiceId2STS.put(objSTS.Service__c,objSTS);                
                }
            }
            
            List<SupplyPoint__c> supplyPointLists = (List<SupplyPoint__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,
                                                                                                               new List<String>{LoAp_Constants.Id,GlUt_APIConstantsLocation.LOCATIONAPINAME},
                                                                                                               'WHERE ' + LoAp_Constants.Id + ' IN ' + GlUt_FieldSecurity.IdsToString(mapOfServiceId2SupplyPointId.values())); 
            if(supplyPointLists != null && !supplyPointLists.isEmpty()){
                for(SupplyPoint__c objSupplyPoint : supplyPointLists){
                    if(objSupplyPoint.Location__c != null){
                        mapOfSupplyPointId2LocationId.put(objSupplyPoint.Id, objSupplyPoint.Location__c);
                    }                
                }
            }
            
            // Get the address of the supply point to display in the table
            List<Location__c> locationLists = (List<Location__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocation.LOCATIONAPINAME,
                                                                                                      new List<String>{LoAp_Constants.Id,GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME},
                                                                                                      'WHERE ' + LoAp_Constants.Id + ' IN ' + GlUt_FieldSecurity.IdsToString(mapOfSupplyPointId2LocationId.values())); 
            if(locationLists != null && !locationLists.isEmpty()){
                for(Location__c objLocation : locationLists){
                    mapOfLocationId2Location.put(objLocation.Id,objLocation);
                }  
            }
            
            // Preapre the BlAp_CombinedRecord to display the data into table
            if(servicesList != null && !servicesList.isEmpty()){
                for (Service__c objService : servicesList) {                
                    if(objService.SupplyPoint__c != null){
                        BlAp_CombinedRecord serviceComb = new BlAp_CombinedRecord();            
                        serviceComb.uniqueId		= objService.Id;
                        serviceComb.isSelected 		= mapOfServiceId2STS.containsKey(objService.Id) ? true : false; // If Service Id is already associated with Stepped Tariff Service then checkbox should checked by default
                        serviceComb.readOnlyFields 	= new Map<string, boolean>();
                        serviceComb.objectMap 		= new Map<string, sObject>();
                        serviceComb.objectMap.put(GlUt_APIConstantsService.SERVICEAPINAME,objService); // AT-3794
                        serviceComb.objectMap.put(GlUt_APIConstantsSteppedTariffService.STEPPEDTARIFFSERVICEAPINAME, mapOfServiceId2STS.containsKey(objService.Id) ? mapOfServiceId2STS.get(objService.Id) : dummySTS);
                        serviceComb.objectMap.put(GlUt_APIConstantsLocation.LOCATIONAPINAME, mapOfLocationId2Location.get(mapOfSupplyPointId2LocationId.get(mapOfServiceId2SupplyPointId.get(objService.Id))));   
                        if(!serviceComb.isSelected)
                            objSteppedTariffInfo.isChecked = false;
                        objSteppedTariffInfo.serviceRecordCombinedList.add(serviceComb);                    
                    }
                }
            }
            return objSteppedTariffInfo;
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }        
    }  
    
    /**********************************************************************************************
    @author      : Echo : Ankit Gangwani
    @date        : 17 July 2018
    @param       : String ServiceTypeId
    @return      : String Service Type Name
    @description : This method returns the BlAp_CombinedRecord with list of Service, Location, unique-ids, isSelected and readOnlyFields
    **********************************************************************************************/
    @AuraEnabled
    public static String retrieveSertviceTypeName(String ServiceTypeId) {
        try {
            String soqlQuery =''; 
            ServiceType__c objServiceType  = (ServiceType__c)GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME, ServiceTypeId,
                                                                                                new List<String>{LoAp_Constants.NameLabel});
            if(objServiceType.Id != null)
                return objServiceType.Name;
            else
                return null; 
        }catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }  
    }
}