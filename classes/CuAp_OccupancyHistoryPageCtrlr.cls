/**********************************************************************************************
@author      : Echo:Mohit Tayal
@date        : 02 Aug 2018
@description : Controller for CuAp_OccupancyHistoryPage Lightning Component
**********************************************************************************************/
public with sharing class CuAp_OccupancyHistoryPageCtrlr {

    private static final String CLASS_NAME = 'CuAp_OccupancyHistoryPageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static List<String> locationOccupantFields = new List<String>();
    private static List<String> locationFields = new List<String>();
    private static List<String> contractFields = new List<String>();
    private static List<String> occupantsFields = new List<String>();
    
    static{
        locationOccupantFields.add(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTLOCATION);
        locationOccupantFields.add(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATE);
        locationOccupantFields.add(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTENDDATE);
        
        locationFields.add(GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME);
        
        contractFields.add(GlUt_APIConstantsContracts.CONTRACTNAMEAPINAME);
        contractFields.add(GlUt_APIConstantsContracts.CONTRACTSTARTDATEAPINAME);
        contractFields.add(GlUt_APIConstantsContracts.CONTRACTENDDATEAPINAME);
        
        occupantsFields.add(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATE);
        occupantsFields.add(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTENDDATE);
        occupantsFields.add(GlUt_APIConstantsLocationOccupant.PRIMARY);
        occupantsFields.add(GlUt_APIConstantsLocationOccupant.OCCUPANCYTYPEAPI);
    }
    
    /**********************************************************************************************
    @author      : Echo:Mohit Tayal
    @date        : 02 Aug 2018
    @params      : null
    @return      : List<GlAp_FieldProps>
    @description : This method returns the field properties for the location list
    **********************************************************************************************/
    @AuraEnabled
    public static List<GlAp_FieldProps> retrieveLocationListFieldProps(){
        try{
            List<GlAp_FieldProps> lstFieldProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsLocation.LOCATIONAPINAME, locationFields);
            GlAp_FieldProps fieldProp = new GlAp_FieldProps();
            fieldProp.buttonField = False;
            fieldProp.fieldName = CuAp_Constants.LOCATIONNAMEAPINAME;
            fieldProp.fieldLabel = CuAp_Constants.LOCAITONFIELDANDLABEL;
            fieldProp.fieldType = CuAp_Constants.REFERENCEFIELDTYPE;
            fieldProp.isEditable = False;
            fieldProp.transformField = True;
            fieldProp.parentObject = GlUt_APIConstantsLocation.LOCATIONAPINAME;
            lstFieldProps.add(0,fieldProp);
            
            GlAp_FieldProps fieldProp1 = new GlAp_FieldProps();
            fieldProp1.buttonField = False;
            fieldProp1.fieldName = CuAp_Constants.CONTRACTNAME;
            fieldProp1.fieldLabel = CuAp_Constants.BILLINGCONTRACTLABEL;
            fieldProp1.fieldType = CuAp_Constants.REFERENCEFIELDTYPE;
            fieldProp1.isEditable = False;
            fieldProp1.transformField = True;
            fieldProp1.parentObject = GlUt_APIConstantsContracts.CONTRACTAPINAME;
            lstFieldProps.add(fieldProp1);
            return lstFieldProps;
        }catch(Exception ex) {
            GlUt_Logger.logException(ex) ;
            GlUt_Logger.writeLogsToDatabase();
            system.debug(DEBUG + ' Exception found=> ' + ex);
            throw new AuraHandledException(ex.getMessage()) ;
        }
    }
    
    /**********************************************************************************************
    @author      : Echo:Mohit Tayal
    @date        : 02 Aug 2018
    @params      : String accountId - Account Id of the record home page
    @return      : List<BlAp_CombinedRecord>
    @description : This method returns the List of location occupants on a location that overlaps 
                   the location occupant of the current account
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveLocationListRecords(String accountId){
        try{
            if(String.isNotBlank(accountId)){
                List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
                String listFilter =  GlUt_APIConstantsLocationOccupant.SHOWONBILLAPINAME + ' = TRUE';
                String listOrder = ' Order By ' + GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATE + ' DESC';
                Set<Id> setOfLocationIds = new Set<Id>();
                Map<Id,List<LocationOccupant__c>> mapOfLocationIdToLstLocationOccupant = new Map<Id,List<LocationOccupant__c>>();
                
                /* AT-3912 ---- Started ---- */
                Set<Id> billingContractIdsSet = new Set<Id>();
                List<Service__c> serviceLists = new List<Service__c>();
                List<SupplyPoint__c> supplyPointLists = new List<SupplyPoint__c>();
                Map<Id,List<Id>> mapOfBillingContractId2ServiceLists = new Map<Id,List<Id>>(); // Contract 	--> Services
                Map<Id,Id> mapOfServiceId2SupplyPointId = new Map<Id,Id>(); 	// Service 		--> SupplyPoint
                Map<Id,Id> mapOfSupplyPointId2LocationId = new Map<Id,Id>();    // SupplyPoint 	--> location
                /* AT-3912 ---- Ended ---- */
                    
                for(LocationOccupant__c objLocationOccupant : (List<LocationOccupant__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, 
                                                                                                                              locationOccupantFields, 
                                                                                                                              accountId, 
                                                                                                                              GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTACCOUNT,
                                                                                                                              listFilter, 
                                                                                                                              listOrder) ){
                    if(!mapOfLocationIdToLstLocationOccupant.containsKey(objLocationOccupant.Location__c))                                                                                    
                        mapOfLocationIdToLstLocationOccupant.put(objLocationOccupant.Location__c, new List<LocationOccupant__c>{objLocationOccupant});
                    else
                        mapOfLocationIdToLstLocationOccupant.get(objLocationOccupant.Location__c).add(objLocationOccupant); 
                }
                
                /* AT-3911 (FR), AT-3912 																 
                 * 11 October 2018
                 * Ankit Gangwani        
                 * Earlier the location has been identified with BillingContract__c.HouseholdBilling__c, 
                 * now the location will be identified with BillingContract__c --> Service__c --> SupplyPoint__c --> Location__c 
				 */
                
                
                if(mapOfLocationIdToLstLocationOccupant.keySet() != null){
                    Map<Id,List<BillingContract__c>> mapOfLocaionIdToLstContracts = new map<Id,List<BillingContract__c>>();
                    Map<Id,List<BillingContract__c>> mapOfLocaionIdToLstContracts1 = new map<Id,List<BillingContract__c>>();
                    
                    
                    List<BillingContract__c> billingContractLists = (List<BillingContract__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsContracts.CONTRACTAPINAME, 
                                                                                                                                   contractFields, 
                                                                                                                                   accountId, 
                                                                                                                                   GlUt_APIConstantsContracts.CUSTOMERAPINAME);
                    if(billingContractLists != null && !billingContractLists.isEmpty()){
                        for(BillingContract__c objBillingContract : billingContractLists){
                            billingContractIdsSet.add(objBillingContract.Id);
                        }                        
                    }
                    if(billingContractIdsSet != null && billingContractIdsSet.size() > 0){
                        serviceLists = (List<Service__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsService.SERVICEAPINAME,
                                                                                              new List<String>{LoAp_Constants.Id,
                                                                                                  GlUt_APIConstantsContracts.CONTRACTAPINAME,
                                                                                                  GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME},
                                                                                              'WHERE ' + GlUt_APIConstantsContracts.CONTRACTAPINAME + 
                                                                                              ' IN ' + GlUt_FieldSecurity.IdsToString(billingContractIdsSet));                        
                    }
                    if(!serviceLists.isEmpty()){
                        for(Service__c objService : serviceLists){
                            if(objService.BillingContract__c != null){
                                if(!mapOfBillingContractId2ServiceLists.containsKey(objService.BillingContract__c))
                                    mapOfBillingContractId2ServiceLists.put(objService.BillingContract__c, new List<Id>());                                
                                mapOfBillingContractId2ServiceLists.get(objService.BillingContract__c).add(objService.Id);
                            }
                            if(objService.SupplyPoint__c != null && !mapOfServiceId2SupplyPointId.containsKey(objService.SupplyPoint__c)){
                                mapOfServiceId2SupplyPointId.put(objService.Id,objService.SupplyPoint__c);
                            }
                        }
                    }
                    
                    if(mapOfServiceId2SupplyPointId.size() > 0){
                        supplyPointLists = (List<SupplyPoint__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,
                                                                                                      new List<String>{LoAp_Constants.Id,
                                                                                                          GlUt_APIConstantsLocation.LOCATIONAPINAME},
                                                                                                      'WHERE ' + LoAp_Constants.Id + 
                                                                                                      ' IN ' + GlUt_FieldSecurity.IdsToString(mapOfServiceId2SupplyPointId.values()));
                        if(!supplyPointLists.isEmpty()){
                            for(SupplyPoint__c objSupplyPoint : supplyPointLists){
                                if(objSupplyPoint.Location__c != null && !mapOfSupplyPointId2LocationId.containsKey(objSupplyPoint.Id)){
                                    mapOfSupplyPointId2LocationId.put(objSupplyPoint.Id,objSupplyPoint.Location__c);                                    
                                }
                            }
                        }
                    }
                    
                    
                    if(billingContractLists != null && !billingContractLists.isEmpty()){
                        for(BillingContract__c objBillingContract : billingContractLists){
                            if(mapOfBillingContractId2ServiceLists.containsKey(objBillingContract.Id)){
                                for(Id serviceID: mapOfBillingContractId2ServiceLists.get(objBillingContract.Id)){
                                    if(mapOfServiceId2SupplyPointId.containsKey(serviceID)){
                                        Id SupplyPointID = mapOfServiceId2SupplyPointId.get(serviceID);
                                        if(mapOfSupplyPointId2LocationId.containsKey(SupplyPointID)){
                                            Id LocationID = mapOfSupplyPointId2LocationId.get(SupplyPointID);
                                            if(LocationID != null){
                                                if(!mapOfLocaionIdToLstContracts.containsKey(LocationID))
                                                    mapOfLocaionIdToLstContracts.put(LocationID, new List<BillingContract__c>{objBillingContract});
                                                else
                                                    mapOfLocaionIdToLstContracts.get(LocationID).add(objBillingContract);
                                            }    
                                        }
                                    }
                                }
                            }
                        }
                    } 
                    
                    /* AT-3912 ---- Ended ---- */
                       
                    /*for(BillingContract__c objContract : (List<BillingContract__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsContracts.CONTRACTAPINAME, 
                                                                                                                        contractFields, 
                                                                                                                        String.format('WHERE {0} IN {1} Order By {2} DESC',
                                                                                                                        new List<String>{GlUt_APIConstantsContracts.HOUSEHOLDBILLINGAPINAME, 
                                                                                                                            GlUt_FieldSecurity.IdsToString(mapOfLocationIdToLstLocationOccupant.keySet()), 
                                                                                                                            GlUt_APIConstantsContracts.CONTRACTSTARTDATEAPINAME})
                                                                                                                        )){     
                        if(objContract.HouseholdBilling__c != Null){                                                                                     
                            if(!mapOfLocaionIdToLstContracts.containsKey(objContract.HouseholdBilling__c))
                                mapOfLocaionIdToLstContracts.put(objContract.HouseholdBilling__c, new List<BillingContract__c>{objContract});
                            else
                                mapOfLocaionIdToLstContracts.get(objContract.HouseholdBilling__c).add(objContract);
                        }
                    }*/
                    
                    locationFields.add(GlUt_APIConstantsLocation.NAMEAPINAME);
                    for(Location__c objLocation : (List<Location__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocation.LOCATIONAPINAME, 
                                                                                                          locationFields, 
                                                                                                          String.format('WHERE {0} IN {1} ',
                                                                                                          new List<String>{'Id',GlUt_FieldSecurity.IdsToString(mapOfLocationIdToLstLocationOccupant.keySet())})
                                                                                                          )){
                        BlAp_CombinedRecord record = new BlAp_CombinedRecord();
                        record.isSelected = False;
                        record.uniqueId = objLocation.Id;
                        record.objectMap = new Map<String,sObject>();
                        record.objectMap.put(GlUt_APIConstantsLocation.LOCATIONAPINAME, objLocation);
                        record.transformFieldMap = new Map<String,Map<String,String>>();    
                        Map<String,String> locationIdToNameMap = new Map<String,String>{objLocation.Id => objLocation.Name};
                        record.transformFieldMap.put(GlUt_APIConstantsLocation.LOCATIONAPINAME, locationIdToNameMap); 
                        Boolean breakContractLoop = False;                                                                                      
                        if(mapOfLocaionIdToLstContracts != null && !mapOfLocaionIdToLstContracts.isEmpty() && mapOfLocaionIdToLstContracts.containsKey(objLocation.Id)){
                            system.debug('mapOfLocaionIdToLstContracts = ' +mapOfLocaionIdToLstContracts);
                            for(BillingContract__c objContract : mapOfLocaionIdToLstContracts.get(objLocation.Id)){
                                for(LocationOccupant__c objLocationOccupant : mapOfLocationIdToLstLocationOccupant.get(objLocation.Id)){
                                    if(objLocationOccupant.EndDate__c != Null && objContract.ContractEndDate__c != Null){                                                                                                          
                                        if((objContract.ContractStartDate__c >= objLocationOccupant.StartDate__c && objContract.ContractStartDate__c <= objLocationOccupant.EndDate__c)
                                           || (objContract.ContractEndDate__c >= objLocationOccupant.StartDate__c && objContract.ContractEndDate__c <= objLocationOccupant.EndDate__c) 
                                           || (objContract.ContractStartDate__c <= objLocationOccupant.StartDate__c && objContract.ContractEndDate__c >= objLocationOccupant.EndDate__c)){
                                               Map<String,String> contractIdToNameMap = new Map<String,String>{objContract.Id => objContract.Name};
                                               record.transformFieldMap.put(GlUt_APIConstantsContracts.CONTRACTAPINAME, contractIdToNameMap);
                                               breakContractLoop = True;
                                               break;
                                           }
                                    }else if(objLocationOccupant.EndDate__c != Null && objContract.ContractEndDate__c == Null){
                                        if(objContract.ContractStartDate__c < objLocationOccupant.EndDate__c){
                                            Map<String,String> contractIdToNameMap = new Map<String,String>{objContract.Id => objContract.Name};
                                            record.transformFieldMap.put(GlUt_APIConstantsContracts.CONTRACTAPINAME, contractIdToNameMap);
                                            breakContractLoop = True;
                                            break;
                                        }                                                                                                          
                                    }else if(objLocationOccupant.EndDate__c == Null && objContract.ContractEndDate__c != Null){
                                        if(objContract.ContractEndDate__c > objLocationOccupant.StartDate__c){
                                            Map<String,String> contractIdToNameMap = new Map<String,String>{objContract.Id => objContract.Name};
                                            record.transformFieldMap.put(GlUt_APIConstantsContracts.CONTRACTAPINAME, contractIdToNameMap);
                                            breakContractLoop = True;
                                            break;
                                        } 
                                    }else if(objLocationOccupant.EndDate__c == Null && objContract.ContractEndDate__c == Null){
                                        Map<String,String> contractIdToNameMap = new Map<String,String>{objContract.Id => objContract.Name};
                                        record.transformFieldMap.put(GlUt_APIConstantsContracts.CONTRACTAPINAME, contractIdToNameMap);
                                        breakContractLoop = True;
                                        break;
                                    }
                                }
                                if(breakContractLoop)
                                    break;
                            }                                                                                     
                        }                                                                         
                        records.add(record);
                    }
                }
            return records;
            }
            return null;
        }catch(Exception ex) {
            GlUt_Logger.logException(ex) ;
            GlUt_Logger.writeLogsToDatabase();
            system.debug(DEBUG + ' Exception found=> ' + ex);
            throw new AuraHandledException(ex.getMessage()) ;
        }
    }
    
    /**********************************************************************************************
    @author      : Echo:Mohit Tayal
    @date        : 02 Aug 2018
    @params      : null
    @return      : List<GlAp_FieldProps>
    @description : This method returns the field properties of the occupant list
    **********************************************************************************************/
    @AuraEnabled
    public static List<GlAp_FieldProps> retrieveOccupantsListFieldProps(){
        try{
            List<GlAp_FieldProps> lstFieldProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, occupantsFields);
            GlAp_FieldProps fieldProp = new GlAp_FieldProps();
            fieldProp.buttonField = False;
            fieldProp.fieldName = GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTACCOUNT;
            fieldProp.fieldLabel = CuAp_Constants.OCCUPANTSLABEL;
            fieldProp.fieldType = CuAp_Constants.REFERENCEFIELDTYPE;
            fieldProp.isEditable = False;
            fieldProp.transformField = True;
            fieldProp.parentObject = GlUt_APIConstantsAccount.ACCOUNTAPINAME;
            lstFieldProps.add(0,fieldProp);
            return lstFieldProps;
        }catch(Exception ex) {
            GlUt_Logger.logException(ex) ;
            GlUt_Logger.writeLogsToDatabase();
            system.debug(DEBUG + ' Exception found=> ' + ex);
            throw new AuraHandledException(ex.getMessage()) ;
        }
    }
    
    /**********************************************************************************************
    @author      : Echo:Mohit Tayal
    @date        : 02 Aug 2018
    @params      : String locationId - Location Id of selected record
                   String accountId - Account Id of the record home page
    @return      : List<LocationOccupant__c>
    @description : This method returns the List of location occupants on a location that overlaps 
                   the location occupant of the current account
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveOccupantsListRecords(String locationId, String accountId){
        try{
            if(String.isNotBlank(locationId) && String.isNotBlank(accountId)){
                String listFilter =  GlUt_APIConstantsLocationOccupant.SHOWONBILLAPINAME + ' = TRUE';
                String listOrder = ' Order By ' + GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATE + ' DESC';
                List<LocationOccupant__c> lstLocationOccupant = (List<LocationOccupant__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, occupantsFields, accountId, 
                                                                                                         GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTACCOUNT, listFilter, listOrder);
        
                List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
                if(!lstLocationOccupant.isEmpty() && lstLocationOccupant != Null){
                    occupantsFields.add(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTACCOUNT);
                    listOrder = ' Order By ' + GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATE + ' ASC';
                    List<LocationOccupant__c> lstLocationOccupant2 = (List<LocationOccupant__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, occupantsFields, locationId, 
                                                                                                                                 GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTLOCATION, listFilter, listOrder);
                    List<Id> setOfAccountIds = new List<Id>();
                    for(LocationOccupant__c objLocationOccupant : lstLocationOccupant2){
                        setOfAccountIds.add(objLocationOccupant.Account__c);
                    }
                    Map<Id,String> mapOfAccountIdToName = getRecordName(setOfAccountIds);
                    for(LocationOccupant__c objLocationOccupant : lstLocationOccupant2){  
                        if(objLocationOccupant.EndDate__c != Null && lstLocationOccupant[0].EndDate__c != Null){                                                                                                          
                            if((objLocationOccupant.StartDate__c >= lstLocationOccupant[0].StartDate__c && objLocationOccupant.StartDate__c <= lstLocationOccupant[0].EndDate__c)
                               || (objLocationOccupant.EndDate__c >= lstLocationOccupant[0].StartDate__c && objLocationOccupant.EndDate__c <= lstLocationOccupant[0].EndDate__c) 
                               || (objLocationOccupant.StartDate__c <= lstLocationOccupant[0].StartDate__c && objLocationOccupant.EndDate__c >= lstLocationOccupant[0].EndDate__c)){
                                   BlAp_CombinedRecord record = new BlAp_CombinedRecord();
                                   record.isSelected = False;
                                   record.uniqueId = objLocationOccupant.Id;
                                   record.objectMap = new Map<String,sObject>();
                                   record.objectMap.put(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME,objLocationOccupant);
                                   record.transformFieldMap = new Map<String,Map<String,String>>();
                                   Map<String,String> accountReferenceFieldMap = new Map<String,String>{objLocationOccupant.Account__c => mapOfAccountIdToName.get(objLocationOccupant.Account__c)};
                                       record.transformFieldMap.put(GlUt_APIConstantsAccount.ACCOUNTAPINAME,accountReferenceFieldMap);
                                   records.add(record);
                               }
                        }else if(objLocationOccupant.EndDate__c == Null && lstLocationOccupant[0].EndDate__c != Null){
                            if(objLocationOccupant.StartDate__c < lstLocationOccupant[0].EndDate__c){
                                BlAp_CombinedRecord record = new BlAp_CombinedRecord();
                                record.isSelected = False;
                                record.uniqueId = objLocationOccupant.Id;
                                record.objectMap = new Map<String,sObject>();
                                record.objectMap.put(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME,objLocationOccupant);
                                record.transformFieldMap = new Map<String,Map<String,String>>();
                                Map<String,String> accountReferenceFieldMap = new Map<String,String>{objLocationOccupant.Account__c => mapOfAccountIdToName.get(objLocationOccupant.Account__c)};
                                    record.transformFieldMap.put(GlUt_APIConstantsAccount.ACCOUNTAPINAME,accountReferenceFieldMap);
                                records.add(record);
                            }                                                                                                          
                        }else if(objLocationOccupant.EndDate__c != Null && lstLocationOccupant[0].EndDate__c == Null){
                            if(objLocationOccupant.EndDate__c > lstLocationOccupant[0].StartDate__c){
                                BlAp_CombinedRecord record = new BlAp_CombinedRecord();
                                record.isSelected = False;
                                record.uniqueId = objLocationOccupant.Id;
                                record.objectMap = new Map<String,sObject>();
                                record.objectMap.put(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME,objLocationOccupant);
                                record.transformFieldMap = new Map<String,Map<String,String>>();
                                Map<String,String> accountReferenceFieldMap = new Map<String,String>{objLocationOccupant.Account__c => mapOfAccountIdToName.get(objLocationOccupant.Account__c)};
                                    record.transformFieldMap.put(GlUt_APIConstantsAccount.ACCOUNTAPINAME,accountReferenceFieldMap);
                                records.add(record);
                            } 
                        }else if(objLocationOccupant.EndDate__c == Null && lstLocationOccupant[0].EndDate__c == Null){
                            BlAp_CombinedRecord record = new BlAp_CombinedRecord();
                            record.isSelected = False;
                            record.uniqueId = objLocationOccupant.Id;
                            record.objectMap = new Map<String,sObject>();
                            record.objectMap.put(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME,objLocationOccupant);
                            record.transformFieldMap = new Map<String,Map<String,String>>();
                            Map<String,String> accountReferenceFieldMap = new Map<String,String>{objLocationOccupant.Account__c => mapOfAccountIdToName.get(objLocationOccupant.Account__c)};
                                record.transformFieldMap.put(GlUt_APIConstantsAccount.ACCOUNTAPINAME,accountReferenceFieldMap);
                            records.add(record);
                        }
                    }
                }
            return records;
        }
        return null;
        }catch(Exception ex) {
            GlUt_Logger.logException(ex) ;
            GlUt_Logger.writeLogsToDatabase();
            system.debug(DEBUG + ' Exception found=> ' + ex);
            throw new AuraHandledException(ex.getMessage()) ;
        }
    }
    
    /**********************************************************************************************
    @author      : Echo:Mohit Tayal
    @date        : 02 Aug 2018
    @params      : Sting recordIdString - the list of referenced Ids
    @return      : Map of Id to the name of the referenced field object
    @description : This method returns the Map of referenced object Id and object name
    **********************************************************************************************/
    @testVisible
    private static Map<Id,String> getRecordName(List<Id> recordIdString){
        Map<Id,String> referenceIdNameMap = new Map<Id,String>();
        if(!recordIdString.isEmpty()) {
            String objName = getObjectType(recordIdString[0]);
            List<SObject> retList = Database.query('SELECT Name FROM ' + objName + ' WHERE Id = :recordIdString');
            if(!retList.isEmpty()){
                for(Sobject obj : retList){
                    referenceIdNameMap.put(obj.Id, (String)obj.get('Name'));
                }
            }
        }
        return referenceIdNameMap;
    }
    
    /**********************************************************************************************
    @author      : Echo:Mohit Tayal
    @date        : 02 Aug 2018
    @params      : Sting objectId - the object Id of the referenced object 
    @return      : String object type
    @description : This method returns the object name of the referenced object
    **********************************************************************************************/
    @testVisible        
    private static string getObjectType(string objectId){
        Id sId = (Id)objectId;
        return sId.getSobjectType().getDescribe().getName();
    }
   
}