/************************************************************************************************************
@author      : Echo: Ankit Gangwani
@date        : 17 July 2018
@description : BlAp_SteppedTariffRenewalCtrlr class is used to display stepped tariff fields for service type selection
**************************************************************************************************************/
public with sharing class BlAp_SteppedTariffRenewalCtrlr {
   
    private static List<String> steppedTariffFields;
    private static List<String> serviceFields;
    private static List<String> serviceTypeFields;
    private static List<String> serviceItemFamilyFields;
    private static final String CLASS_NAME = LoAp_Constants.RenewalClassLabel;
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
 
    static{
        //Get Fields from the Stepped Tariff Object
        steppedTariffFields = new List<string>();
        steppedTariffFields.add(GlUt_APIConstantsSteppedTariff.STARTDATEAPINAME);
        steppedTariffFields.add(GlUt_APIConstantsSteppedTariff.ENDDATEAPINAME);
        
        //Get Fields from the Service Object
        serviceFields = new List<String>();
        serviceFields.add(LoAp_Constants.Id);
        serviceFields.add(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME);
        
        //Get Fields from the Service Type Object
        serviceTypeFields = new List<String>();
        serviceTypeFields.add(LoAp_Constants.Id);
        serviceTypeFields.add(GlUt_APIConstantsServiceType.NAMEAPINAME);
        
        //Get Fields from the Service Item Family Object
        serviceItemFamilyFields = new List<String>();
        serviceItemFamilyFields.add(LoAp_Constants.Id);       
        serviceItemFamilyFields.add(GlUt_ApiConstantsServiceItemFamily.ALGORITHMTYPEAPINAME);
        serviceItemFamilyFields.add(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME);
    }
    
    /**********************************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 17 July 2018
    @return      : List<Service__c>
    @description : This method returns the field properties for each of the fields that are
    to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<ServiceType__c> retrieveServicesOnContract(Id ContractId) {        
        try {
            Set<Id> serviceTypeIds = new Set<Id>();
            
            // Get all the service associated with contract 
            //List<Service__c> serviceList = [SELECT Id, ServiceType__c FROM Service__c WHERE BillingContract__c = :ContractId];
            //Clayton Review: Sudhir Added GlAp_LightningDataAccess and escapeSingleQuotes
            String whereClause = 'WHERE ' + CuAp_Constants.CONTRACTAPINAME + ' = \'' + String.escapeSingleQuotes(ContractId) + '\'';
            List<Service__c> serviceList = (List<Service__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsService.SERVICEAPINAME, 
                                                                               serviceFields,
                                                                               whereClause);
            for(Service__c objService : serviceList){
                serviceTypeIds.add(objService.ServiceType__c);
            }
            
            // get the name of service type based on their Id nand return to display in the picklist field
            //List<ServiceType__c> serviceTypeList = [SELECT Id, Name FROM ServiceType__c WHERE Id IN :serviceTypeIds];
            //Clayton Review: Sudhir Added GlAp_LightningDataAccess
            List<ServiceType__c> serviceTypeList = (List<ServiceType__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME,
                                                                                                              serviceTypeFields,
                                                                                                              'WHERE ' + ' Id ' + 
                                                                                                              ' IN ' + GlUt_FieldSecurity.IdsToString(serviceTypeIds));
            if(!serviceTypeList.isEmpty())
                return serviceTypeList;
            else
                return null;
        }catch(Exception oException) {
            GlUt_Logger.logException(oException);
            throw new AuraHandledException('Error: ' + oException.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
 
    /**********************************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 17 July 2018
    @return      : List<GLAp_FieldProps>
    @description : This method returns the field properties for each of the fields that are
    to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrieveSteppedTariffFields(Id ContractId) {
        try {
            Set<Id> serviceTypeSet = new Set<Id>();
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            List<GLAp_FieldProps> allFieldProp = new List<GLAp_FieldProps>();            
            Set<String> serviceTypeStrings = new Set<String>();
                
            List<String> durationInMonthsList = new List<String>{'','3','6','9','12','15','18'};
            //Clayton Review: Sudhir Added escapeSingleQuotes    
            String whereClause = 'WHERE ' + CuAp_Constants.CONTRACTAPINAME + ' = \'' + String.escapeSingleQuotes(ContractId) + '\'';
            
            // get all the service associated with the contract
            List<Service__c> serviceList = GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsService.SERVICEAPINAME, 
                                                                               serviceFields,
                                                                               whereClause);
            
            // Iterate the list of sevices to get the service type Ids
            for(Service__c objService: serviceList){
                serviceTypeSet.add(objService.ServiceType__c);                   
            }
            
            // get all the service item family records based on their service type ids to match "Measured Billing" algorithm
            List<ServiceItemFamily__c> serviceItemFamilyList = (List<ServiceItemFamily__c>) GlAp_LightningDataAccess.getRecords(GlUt_ApiConstantsServiceItemFamily.SRVCITEMFMLYAPINAME,
                                                                                                                                serviceItemFamilyFields,
                                                                                                                                'WHERE ' + GlUt_ApiConstantsServiceType.SERVICETYPEAPINAME + 
                                                                                                                                ' IN ' + GlUt_FieldSecurity.IdsToString(serviceTypeSet)); 
            
            // clear the service type id to make it resuable
            serviceTypeSet.clear();
            
            // Iterate the service item family list to collect all the service type id whose service item family is "Measured Billing"
            for(ServiceItemFamily__c objSIF : serviceItemFamilyList){
                if(objSIF.AlgorithmType__c == System.Label.BlAp_MeasuredBilling)
                    serviceTypeSet.add(objSIF.ServiceType__c);
            }
            
            // get all the service type records based on their ids
            List<ServiceType__c> serviceTypeLists = (List<ServiceType__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME, 
                                                                                                               serviceTypeFields,
                                                                                                               'WHERE ' + LoAp_Constants.Id + ' IN ' + GlUt_FieldSecurity.IdsToString(serviceTypeSet)); 
            
            // Iterate the service type list to make a List<String> of names only to assign into picklistvalues field
            for(ServiceType__c objServiceType:serviceTypeLists){
                serviceTypeStrings.add(objServiceType.Name);
            }
            
            List<String> serviceTypeList = new List<String>{''}; 
            serviceTypeList.addAll(serviceTypeStrings);   
            
            // Create the Picklist Field - "Service Type" - 
            // Values - "Water, Sewerage, Gas etc.."
            GlAp_FieldProps serviceTypePicklist = new GlAp_FieldProps();
            serviceTypePicklist.isFLSVisible = true;
            serviceTypePicklist.isEditable = true;
            serviceTypePicklist.editMode = true;
            serviceTypePicklist.fieldName = CuAp_Constants.SERVICETYPEFIELD ;
            serviceTypePicklist.fieldLabel = CuAp_Constants.SERVICETYPELABEL;
            serviceTypePicklist.fieldType = 'select';
            serviceTypePicklist.isRequired = true;
            serviceTypePicklist.changeEvent = false;
            serviceTypePicklist.parentObject = GlUt_APIConstantsSteppedTariff.STEPPEDTARIFFAPINAME;
            serviceTypePicklist.pickListValues = serviceTypeList;
            allFieldProp.add(serviceTypePicklist);
            
            // Create the Picklist Field - "Duration In Months"
            // Values - "3,6,9,12,15,18"
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
            
            // get the field properties of Stepped Tariff fields
            List<GLAp_FieldProps> steppedTariffProp = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsSteppedTariff.STEPPEDTARIFFAPINAME, steppedTariffFields); 
            
            for(GlAp_FieldProps fieldProp:steppedTariffProp){
                if(fieldProp.fieldName == GlUt_APIConstantsSteppedTariff.STARTDATEAPINAME){
                    fieldProp.isRequired = true;
                }
                allFieldProp.add(fieldProp);
            }
            
            // display the input fields in 2 column pattern
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
        }catch(Exception oException) {
            GlUt_Logger.logException(oException);
            throw new AuraHandledException('Error: ' + oException.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
}