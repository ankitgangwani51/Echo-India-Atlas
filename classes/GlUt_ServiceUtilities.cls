public class GlUt_ServiceUtilities {
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 01 Aug 2018
    @return      : List<Service__c>
    @parameter   : Id billingContractId,List<String> serviceFields
    @description : This method returns the list of service records on the basis of Contract Id.
    **********************************************************************************************/
    public static List<Service__c> getServicesFromContractId(Id billingContractId,List<String> serviceFields) {
        try {
            String filterStatement = 'WHERE '+GlUt_APIConstantsService.SERVICECONTRACTAPINAME+' =' + '\'' + billingContractId + '\'  ORDER BY '+ GlUt_APIConstantsService.SERVICESTARTDATEAPINAME +' DESC';
            List<Service__c> lstServices =  GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsService.SERVICEAPINAME,
                                                                                serviceFields,
                                                                                filterStatement);
            if(lstServices != null && !lstServices.isEmpty())
                return lstServices;
            else
                return null;
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }   
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 01 Aug 2018
    @return      : List<AvailableService__c>
    @parameter   : Id supplyPointId,List<String> availableServiceFields
    @description : This method returns the list of availableservice records on the basis of S.P Id.
    **********************************************************************************************/
    public static List<AvailableService__c> getAvailableServiceFromSupplyPointId(Id supplyPointId,List<String> availableServiceFields) {
        try {
            String filterStatement = 'WHERE '+ GlUt_APIConstantsAvailableService.SUPPLYPOINTAPINAME +' =' + '\'' + supplyPointId + '\'  ORDER BY CreatedDate DESC';
            List<AvailableService__c> lstAvailableServices =  GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME,
                                                                                                  availableServiceFields,
                                                                                                  filterStatement);
            if(lstAvailableServices != null && !lstAvailableServices.isEmpty())
                return lstAvailableServices;
            else
                return null;
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }   
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 01 Aug 2018
    @return      : Map<Id,String>
    @parameter   : List<Id> recordIdString
    @description : This method returns the map of object Id having Name field record.
    **********************************************************************************************/
    public static Map<Id,String> getRecordName(List<Id> recordIdString){
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
    @author      : Echo : Amit K.
    @date        : 01 Aug 2018
    @return      : string
    @parameter   : string objectId
    @description : This method returns object name on the basis of record Id.
    **********************************************************************************************/ 
    public static string getObjectType(string objectId){
        Id sId = (Id)objectId;
        return sId.getSobjectType().getDescribe().getName();
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 01 Aug 2018
    @return      : List<ServiceType__c>
    @parameter   : List<Id> serviceTypeIds,List<String> serviceTypeFields
    @description : This method returns the list of service Types on the basis of service Type Ids.
    **********************************************************************************************/  
    public static List<ServiceType__c> getServiceTypeFromServiceTypeId(List<Id> serviceTypeIds,List<String> serviceTypeFields) {
        try {
            List<ServiceType__c> lstServiceType = (List<ServiceType__c>)GlUt_MeterBooksUtilities.getRecordsFromIds(serviceTypeIds,serviceTypeFields,GlUt_APIConstantsServiceType.SERVICETYPEAPINAME,GlUt_APIConstantsServiceType.Id);
            if(lstServiceType != null && !lstServiceType.isEmpty())
                return lstServiceType;
            else
                return null;
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }   
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 01 Aug 2018
    @return      : List<SupplyPoint__c>
    @parameter   : List<Id> supplyPointIds,List<String> supplyPointFields
    @description : This method returns the list of S.P records on the basis of Service-->S.P Ids.
    **********************************************************************************************/  
    public static List<SupplyPoint__c> getSupplyPointInfoFromServiceSupplyPointId(List<Id> supplyPointIds,List<String> supplyPointFields) {
        try {
            List<SupplyPoint__c> lstSupplyPoint = (List<SupplyPoint__c>)GlUt_MeterBooksUtilities.getRecordsFromIds(supplyPointIds,supplyPointFields,GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,GlUt_APIConstantsSupplyPoint.Id);
            if(lstSupplyPoint != null && !lstSupplyPoint.isEmpty())
                return lstSupplyPoint;
            else
                return null;
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }   
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    /**********************************************************************************************
    @author      : Echo : Amit K.
    @date        : 01 Aug 2018
    @return      : List<Location__c>
    @parameter   : List<Id> locationIds,List<String> locationFields
    @description : This method returns the list of location records on the basis of Service-->S.P-->Location Ids.
    **********************************************************************************************/ 
    public static List<Location__c> getLocationInfoFromServiceSupplyPointLocationId(List<Id> locationIds,List<String> locationFields) {
        try {
            List<Location__c> lstLocation = (List<Location__c>)GlUt_MeterBooksUtilities.getRecordsFromIds(locationIds,locationFields,GlUt_APIConstantsLocation.LOCATIONAPINAME,GlUt_APIConstantsLocation.LOCATIONID);
            if(lstLocation != null && !lstLocation.isEmpty())
                return lstLocation;
            else
                return null;
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }   
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
}