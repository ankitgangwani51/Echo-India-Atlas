/******************************************************************************
@author         Accenture: Satish Nair
@date           06 Nov 2017
@description    Component controller for Service Bundles lightning component
Revision(s)     08 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class CuAp_SelectBundleCtrlr {
    
    private static List<string> supplyPointFields;
    private static List<string> servTypeFields;
    private static List<string> avlServiceFields;
    private static List<string> avlServiceFields1;
    private static List<string> avlServiceItemFields;
    private static List<string> bundleFields;
    private static List<string> avlBundlesFields;
    private static List<string> servItmTypeFields;
      
    private static final String CLASS_NAME = 'CuAp_SelectBundleCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
 

    // to display the Sundry service Item types 
    private static List<string> srvItemTypeFields;
    
    static{

        //Get Fields from the Bundle Object
        avlBundlesFields = new List<string>(); 
        avlBundlesFields.add(GlUt_APIConstantsBundle.NAMEAPINAME); // -- Swati 28-08-2018 , AT-3174
       // avlBundlesFields.add(GlUt_APIConstantsAvailableBundle.BUNDLENAMEAPINAME);  
        
        //Get Fields from the Supply Point Object        
        supplyPointFields = new List<string>();
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.NAMEAPINAME);

        //Get Fields from the Service Type Object
        avlServiceFields = new List<string>();
        avlServiceFields.add(GlUt_APIConstantsServiceType.NAMEAPINAME); // -- Swati 28-08-2018 , AT-3174

        avlServiceFields1 = new List<string>();
        //avlServiceFields1.add(GlUt_APIConstantsServiceType.SRVCTYPSREFAPINAME); // -- Swati 28-08-2018 , AT-3174
        avlServiceFields1.add(GlUt_APIConstantsServiceType.SUPPLYPOINTAPINAME);
        avlServiceFields1.add(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME);
        
        
        //Get Fields from the Service Item Type Object
        srvItemTypeFields = new List<string>();
        srvItemTypeFields.add(GlUt_APIConstantsServiceItemType.NAMEAPINAME);
        
        avlServiceItemFields = new List<string>();
        avlServiceItemFields.add(GlUt_APIConstantsAvailableServiceItem.SERVICEITEMAPINAME);
        //avlServiceItemFields.add(GlUt_APIConstantsAvailableServiceItem.AVALSRVCITEMRELAPINAME);
        avlServiceItemFields.add(GlUt_APIConstantsAvailableServiceItem.AVAILABLEBUNDLEAPINAME);
        avlServiceItemFields.add(GlUt_APIConstantsAvailableServiceItem.AVAILABLESERVICEITEMSAPINAME);

    }
    
    /**********************************************************************************************
    @author         Accenture: Satish Nair
    @date           06-Nov-2017
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the fields that are
                    to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveSerBundlesFieldPropDetails() {
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        try {
            GlUt_Logger.logDebug(DEBUG);
            //Get the field properties for the Supply Point object
            List<GLAp_FieldProps> supplyPtProps = GlAp_LightningDataAccess.getObjectsFieldProperties(
                GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, supplyPointFields);
            //Get the field properties for the Available Service object
            List<GLAp_FieldProps> avlSrvProps = GlAp_LightningDataAccess.getObjectsFieldProperties(
                GlUt_APIConstantsServiceType.SERVICETYPEAPINAME, avlServiceFields);
            //Get the field properties from the Available Bundle object
            List<GLAp_FieldProps> avlBundleProps = GlAp_LightningDataAccess.getObjectsFieldProperties(  
              GlUt_APIConstantsBundle.BUNDLEAPINAME, avlBundlesFields);// -- Swati 29-08-2018 , AT-3174
               
            //Get the field properties from the Available Service Items object
            List<GLAp_FieldProps> avlSrvItemsProps = retrieveTransformFieldPropDetails();
            //Build a map list of all field properties
            
            
            for(GLAp_FieldProps fldProp : avlBundleProps){ 
                fldProp.fieldLabel = CuAp_Constants.AVAILABLEBUNDLELABEL;// -- Swati 29-08-2018 , AT-3174
                fldProp.isEditable = false; // -- Swati 29-08-2018 , AT-3174
                fldPropList.add(fldProp);                           
            }
            for(GLAp_FieldProps fldProp : supplyPtProps){
                fldPropList.add(fldProp); 
            }
            
            for(GLAp_FieldProps fldProp : avlSrvProps){
                fldProp.fieldLabel = CuAp_Constants.AVAILABLESERVICESLABEL; // -- Swati 28-08-2018 , AT-3174
                fldProp.isEditable = false; // -- Swati 28-08-2018 , AT-3174
                fldPropList.add(fldProp); 
            }
            for(GLAp_FieldProps fldProp : avlSrvItemsProps){            
                fldPropList.add(fldProp);                           
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
    @author         Accenture: Satish Nair
    @date           06-Nov-2017
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the Transform fields that are
                    to be displayed on the screen
    **********************************************************************************************/
    private static List<GLAp_FieldProps> retrieveTransformFieldPropDetails() {
        
        List<GLAp_FieldProps> avlSrvItemsProps = new List<GLAp_FieldProps>();
        GLAp_FieldProps transFieldProp = new GLAp_FieldProps();
        transFieldProp.isFLSVisible = true;
        transFieldProp.isEncrypted = false;
        transFieldProp.isEditable = false;
        transFieldProp.isRequired = false;
        transFieldProp.fieldName = CuAp_Constants.AVLSRVITEMS;
        transFieldProp.fieldLabel = CuAp_Constants.AVLSRVITEMS;
        transFieldProp.fieldType = CuAp_Constants.FIELDTYPE;
        transFieldProp.transformField = true;
        transFieldProp.parentObject = GlUt_APIConstantsAvailableServiceItem.AVALSRVCITEMAPINAME;
        avlSrvItemsProps.add(transFieldProp);

        return avlSrvItemsProps;
    }

    /**********************************************************************************************
    @author         Accenture: Satish Nair
    @date           06-Nov-2017
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the fields that are
                    displayed under Other Sevices   
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveSundryFieldPropDetails() {
        //Get the field properties for the Supply Point object
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        try {
            GlUt_Logger.logDebug(DEBUG);
            List<GLAp_FieldProps> srvItmTypeProps = GlAp_LightningDataAccess.getObjectsFieldProperties(
                GlUt_APIConstantsServiceItemType.SERVICEITEMTYPEAPINAME, srvItemTypeFields);
            
            
            for(GLAp_FieldProps fldProp : srvItmTypeProps){            
                fldProp.isEditable = false;
                fldPropList.add(fldProp);                           
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
    @author         Accenture: Satish Nair
    @date           06-Nov-2017
    @param          List<String> availableBun (Associated ServiceType from Available Services) 
    @return         List<BlAp_CombinedRecord>
    @description    This method takes the Available Service or Supply Point to return all Available 
                    Bundles and associated Available Service Items records in a combined list of wrapper objects
    **********************************************************************************************/    
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveServiceBundles(List<String>supplyPtIds , List<String> serviceIds) {
        
        List<BlAp_CombinedRecord>  combSupplyPyList = new List<BlAp_CombinedRecord>();
        
        List<AvailableBundle__c> avlBundleList = new List<AvailableBundle__c>();
        Map<Id,List<AvailableServiceItem__c>> avlSrvItemMap = new Map<Id,List<AvailableServiceItem__c>>();
        Map<Id,SupplyPoint__c> supPtServMap = new Map<Id,SupplyPoint__c>();
        
        List<Id> avlSrvIds = new List<Id>();
        List<Id> serviceTypeIdList = new List<Id>(); // -- Swati 28-08-2018, AT-3174
        List<Id> avlBundleIdList = new List<Id>(); // -- Swati 28-08-2018, AT-3174
        Map<Id,AvailableService__c> avlSrvMap = new Map<Id,AvailableService__c>();
        Set<Id> avlSrvSupplyIds = new Set<Id>();
        //Query for the Available Services
        //MT- 22 Feb 2018 AT-1872 added the active check while in the available service query
        // Updated By Dependra 11-04-2011
        try {
            GlUt_Logger.logDebug(DEBUG);
            List<AvailableService__c> avlSrvList = (List<AvailableService__c>) 
                GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME, 
                                                    avlServiceFields1,
                                                    String.format('WHERE Id IN {0} AND {1} IN {2} AND {3} = true', 
                                                                  new List<String>{GlUt_FieldSecurity.IdsToString(serviceIds),
                                                                      GlUt_APIConstantsAvailableService.SUPPLYPOINTAPINAME, 
                                                                      GlUt_FieldSecurity.IdsToString(supplyPtIds),
                                                                      GlUt_APIConstantsAvailableService.ACTIVEAPINAME}));
            if(!avlSrvList.isEmpty()){
                for(AvailableService__c avlSrv : avlSrvList){
                    avlSrvSupplyIds.add(avlSrv.SupplyPoint__c);
                    avlSrvIds.add(avlSrv.Id);
                    avlSrvMap.put(avlSrv.Id,avlSrv);
                    serviceTypeIdList.add(avlSrv.ServiceType__c); // -- Swati 28-08-2018 , AT-3174
                }
            }
            //-- Swati 28-08-2018  Start  , AT-3174 
            List<ServiceType__c> serviceTypeList =  GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME,
                                                                                       avlServiceFields,
                                                                                       String.format('WHERE {0} IN {1}', 
                                                                                                      new List<String>{
                                                                                                      GlUt_APIConstantsServiceType.Id, 
                                                                                                      GlUt_FieldSecurity.IdsToString(serviceTypeIdList)}));            
            Map<Id, ServiceType__c> serviceTypeId2ServiceTypeMap = new Map<Id, ServiceType__c>(serviceTypeList);
            //-- Swati 28-08-2018  End  , AT-3174
            
            if(!avlSrvIds.isEmpty()){
                avlBundleList = retrieveAvblBundles(avlSrvIds);
                avlSrvItemMap = retrieveAvlSrvItm(avlBundleList);
                System.debug('avlBundleList final = '+avlBundleList);
                System.debug('avlSrvItemMap final = '+avlSrvItemMap);
            }
            if(!avlSrvList.isEmpty() && !avlSrvSupplyIds.isEmpty()){
                supPtServMap = retrieveSupplyPoints(avlSrvSupplyIds,avlSrvList);
            } 
            //-- Swati 28-08-2018  Start  , AT-3174 
            for(AvailableBundle__c availbundleRec: avlBundleList){
                avlBundleIdList.add(availbundleRec.Bundle__c);
            } 
            List<Bundle__c> bundleList =  GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBundle.BUNDLEAPINAME,
                                                                                       avlBundlesFields,
                                                                                       String.format('WHERE {0} IN {1}', 
                                                                                                      new List<String>{
                                                                                                      GlUt_APIConstantsBundle.ID, 
                                                                                                      GlUt_FieldSecurity.IdsToString(avlBundleIdList)}));  
            Map<Id, Bundle__c> bundleId2BundleMap = new Map<Id, Bundle__c>(bundleList);            
            //-- Swati 28-08-2018  End  , AT-3174
            
            //Loop throught the Available Bundle list and capture the appropriate Related information
            for(AvailableBundle__c availbundleRec: avlBundleList){// -- Swati 28-08-2018, AT-3174 
                String commaSeperatedNames ='';
                
                SupplyPoint__c suppRec = new SupplyPoint__c();
                AvailableService__c avlServ = new AvailableService__c();
                ServiceType__c servTypeRec = new ServiceType__c(); //-- Swati 28-08-2018 , AT-3174 
                Bundle__c bundleRec = new Bundle__c(); //-- Swati 28-08-2018 , AT-3174 
                List<AvailableServiceItem__c> avlSrvItmList = new List<AvailableServiceItem__c>();
                if(avlSrvMap.containsKey(availbundleRec.AvailableService__c)){// -- Swati 28-08-2018, AT-3174 
                    avlServ = avlSrvMap.get(availbundleRec.AvailableService__c);// -- Swati 28-08-2018, AT-3174 
                }
                //-- Swati 28-08-2018  Start , AT-3174   
                if(serviceTypeId2ServiceTypeMap.containsKey(avlServ.ServiceType__c)){
                    servTypeRec = serviceTypeId2ServiceTypeMap.get(avlServ.ServiceType__c);
                }
                if(bundleId2BundleMap.containsKey(availbundleRec.Bundle__c)){
                    bundleRec = bundleId2BundleMap.get(availbundleRec.Bundle__c);
                }                
                //-- Swati 28-08-2018  End , AT-3174
                
                if(supPtServMap.containsKey(avlServ.Id)){
                    suppRec = supPtServMap.get(avlServ.Id);
                }
                
                if(avlSrvItemMap.containsKey(availbundleRec.Id)){// -- Swati 28-08-2018, AT-3174 
                    avlSrvItmList = avlSrvItemMap.get(availbundleRec.Id);// -- Swati 28-08-2018, AT-3174 
                }
                
                for(AvailableServiceItem__c avlSrvItm : avlSrvItmList){
                    commaSeperatedNames += avlSrvItm.AvailableServiceItem__c + '\n' ;
                }
                commaSeperatedNames = commaSeperatedNames.subString(0,commaSeperatedNames.length());  
                
                BlAp_CombinedRecord bundleRecrds = new BlAp_CombinedRecord();
                bundleRecrds = combinedRecWrap(servTypeRec,avlServ,suppRec,commaSeperatedNames,availbundleRec,bundleRec,avlSrvItmList); // -- Swati 28-08-2018, AT-3174     
                combSupplyPyList.add(bundleRecrds);      
            }                
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        system.debug('combSupplyPyList = ' +combSupplyPyList);
        return combSupplyPyList;
    }

    /**********************************************************************************************
    @author         Accenture: Satish Nair
    @date           12-Dec-2017
    @param          List<Id> avlSrvIds 
    @return         List<AvailableBundle__c>
    @description    This method takes the Available Service Ids and retieves the corresponding Available Bundles
    **********************************************************************************************/
    private static List<AvailableBundle__c> retrieveAvblBundles (List<Id> avlSrvIds){
        //Query for all the Available Bundles and corresponding Available Service Items
               
        List<AvailableBundle__c> avlBundleList = (List<AvailableBundle__c>) 
            GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME, 
                                                new List<String>{
                                                    GlUt_APIConstantsAvailableBundle.BUNDLEAPINAME, //Swati 28-08-2018 , AT-3174 
                                                    GlUt_APIConstantsAvailableBundle.AVAILABLESERVICEAPINAME, 
                                                    GlUt_APIConstantsAvailableBundle.DEFAULTAPINAME,
                                                    GlUt_APIConstantsAvailableBundle.TARIFFLIMITAPINAME
                                                    }, 
                                                String.format('WHERE {0} IN {1}', new List<String>{
                                                    GlUt_APIConstantsAvailableBundle.AVAILABLESERVICEAPINAME, 
                                                        GlUt_FieldSecurity.IdsToString(avlSrvIds)}));
        
        return avlBundleList;                                       
    }
    /**********************************************************************************************
    @author         Accenture: Satish Nair
    @date           12-Dec-2017
    @param          List<AvailableBundle__c> avlBundleList
    @return         Map<Id,List<AvailableServiceItem__c>>
    @description    This method takes the Available Bundle and retieves the corresponding Available Service Items
    **********************************************************************************************/
    private static Map<Id,List<AvailableServiceItem__c>> retrieveAvlSrvItm(List<AvailableBundle__c> avlBundleList){
        set<Id> setAvailableBundleIds = new set<Id>();
        Map<Id,List<AvailableServiceItem__c>> avlSrvItemMap = new Map<Id,List<AvailableServiceItem__c>>();
        if(!avlBundleList.isEmpty()){
            for(AvailableBundle__c objAvaiableBundle : avlBundleList){
                setAvailableBundleIds.add(objAvaiableBundle.Id);
            }
        }
        
        if(setAvailableBundleIds.size() > 0){
            List<AvailableServiceItem__c>lstAvaiServiceItem = (List<AvailableServiceItem__c>) 
                GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAvailableServiceItem.AVALSRVCITEMAPINAME, 
                                                    new List<String>{ GlUt_APIConstantsAvailableServiceItem.SERVICEITEMAPINAME, 
                                                        GlUt_APIConstantsAvailableServiceItem.AVAILABLESERVICEITEMSAPINAME, 
                                                        GlUt_APIConstantsAvailableServiceItem.AVAILABLEBUNDLEAPINAME
                                                        }, 
                                                    String.format('WHERE {0} IN {1}', new List<String>{
                                                        GlUt_APIConstantsAvailableServiceItem.AVAILABLEBUNDLEAPINAME, 
                                                            GlUt_FieldSecurity.IdsToString(setAvailableBundleIds)}));
            System.debug('lstAvaiServiceItem d02 = '+lstAvaiServiceItem);
            for(AvailableServiceItem__c objAvailableServiceItm : lstAvaiServiceItem){
                if(objAvailableServiceItm.AvailableBundle__c !=null){
                    if(!avlSrvItemMap.containsKey(objAvailableServiceItm.AvailableBundle__c)){
                        avlSrvItemMap.put(objAvailableServiceItm.AvailableBundle__c, new List<AvailableServiceItem__c>());
                        avlSrvItemMap.get(objAvailableServiceItm.AvailableBundle__c).add(objAvailableServiceItm);
                    }else{
                        avlSrvItemMap.get(objAvailableServiceItm.AvailableBundle__c).add(objAvailableServiceItm);
                    }
                }
            }
        }
        system.debug('avlSrvItemMap================='+ avlSrvItemMap);
        return avlSrvItemMap;
    }

    /**********************************************************************************************
    @author         Accenture: Satish Nair
    @date           12-Dec-2017
    @param          Set<Id> avlSrvSupplyIds
    @param          List<Id> avlSrvIds
    @return         Map<Id,SupplyPoint__c>
    @description    This method takes the Supply Point Ids and retieves the other information pertaining to the Supply Point 
    **********************************************************************************************/
    private static Map<Id,SupplyPoint__c> retrieveSupplyPoints(Set<Id> avlSrvSupplyIds, List<AvailableService__c> lstAvaiableService) {
        
        Map<Id,SupplyPoint__c> supPtServMap = new Map<Id,SupplyPoint__c>();
        Map<Id, SupplyPoint__c> mapSupplyPointById = new Map<Id, SupplyPoint__c>([Select id,Name from SupplyPoint__c where id in: avlSrvSupplyIds]);
        if(!lstAvaiableService.isEmpty()){
            for(AvailableService__c objAvlService : lstAvaiableService){
                if(objAvlService.SupplyPoint__c != null){
                    if(!supPtServMap.containsKey(objAvlService.id)){
                        supPtServMap.put(objAvlService.id, mapSupplyPointById.get(objAvlService.SupplyPoint__c));
                    }
                }
            }
        }
       return supPtServMap;
    }

    /**********************************************************************************************
    @author         Accenture: Satish Nair
    @date           12-Dec-2017
    @param          AvailableService__c avlServ
    @param          SupplyPoint__c suppRec
    @param          String commaSeperatedNames
    @param          AvailableBundle__c bundleRec
    @return         BlAp_CombinedRecord
    @description    This method takes the information from all the objects and wraps into the Combined Record wrapper
    **********************************************************************************************/
    /*private static BlAp_CombinedRecord combinedRecWrap(AvailableService__c avlServ, SupplyPoint__c suppRec, 
                                                        String commaSeperatedNames, AvailableBundle__c bundleRec, List<AvailableServiceItem__c> avlSrvItmList) {
        
        BlAp_CombinedRecord bundleRecrds = new BlAp_CombinedRecord();            
            bundleRecrds.uniqueId=bundleRec.Id;
            if(bundleRec.Default__c==true){
                bundleRecrds.isSelected = true;
            }else{
                bundleRecrds.isSelected = false;
            }
                bundleRecrds.objectMap = new Map<string, sObject>();
                system.debug('bundleRec = ' +bundleRec);
                bundleRecrds.objectMap.put(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME, bundleRec);
                bundleRecrds.objectMap.put(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, suppRec);
                bundleRecrds.objectMap.put(GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME, avlServ);
                bundleRecrds.objectMap.put(GlUt_APIConstantsAvailableService.AVAILABLESRVITEMAPINAME, avlSrvItmList);
                //bundleRecrds.objectMap.put(CuAp_Constants.AVAILABLESRVITEMAPINAME, avlSrItem);
                //Add in transform list fields
                Map<string, string> contrtransFormFieldMap = new Map<string, string>();
                contrtransFormFieldMap.put(CuAp_Constants.AVLSRVITEMS,commaSeperatedNames);
                bundleRecrds.transformFieldMap = new Map<string,Map<string, string>>();
                bundleRecrds.transformFieldMap.put(GlUt_APIConstantsAvailableServiceItem.AVALSRVCITEMAPINAME, contrtransFormFieldMap);                                 
 
        return bundleRecrds;   
    }*/
      private static BlAp_CombinedRecord combinedRecWrap(ServiceType__c servTypeRec,  AvailableService__c avlServ, SupplyPoint__c suppRec, // -- Swati 28-08-2018 , AT-3174 
                                                        String commaSeperatedNames, AvailableBundle__c availBundleRec, Bundle__c bundleRec, List<AvailableServiceItem__c> avlSrvItmList) {
        
        BlAp_CombinedRecord bundleRecrds = new BlAp_CombinedRecord();            
            bundleRecrds.uniqueId=availBundleRec.Id;// -- Swati 28-08-2018 , AT-3174 
            if(availBundleRec.Default__c==true){// -- Swati 28-08-2018 , AT-3174 
                bundleRecrds.isSelected = true;
            }else{
                bundleRecrds.isSelected = false;
            }
                bundleRecrds.objectMap = new Map<string, sObject>();
                bundleRecrds.lstSobjectMap = new Map<string, List<Sobject>>();
                system.debug('availBundleRec = ' +availBundleRec);
                bundleRecrds.objectMap.put(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME, availBundleRec);// -- Swati 28-08-2018 , AT-3174 
                bundleRecrds.objectMap.put(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, suppRec);
                bundleRecrds.objectMap.put(GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME, avlServ);
                bundleRecrds.objectMap.put(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME, servTypeRec); // -- Swati 28-08-2018 , AT-3174 
                bundleRecrds.objectMap.put(GlUt_APIConstantsBundle.BUNDLEAPINAME, bundleRec); // -- Swati 28-08-2018 , AT-3174 
                bundleRecrds.lstSobjectMap.put(CuAp_Constants.AVAILABLESRVITEMAPINAME, avlSrvItmList);
                //bundleRecrds.objectMap.put(CuAp_Constants.AVAILABLESRVITEMAPINAME, avlSrItem);
                //Add in transform list fields
                Map<string, string> contrtransFormFieldMap = new Map<string, string>();
                contrtransFormFieldMap.put(CuAp_Constants.AVLSRVITEMS,commaSeperatedNames);
                bundleRecrds.transformFieldMap = new Map<string,Map<string, string>>();
                bundleRecrds.transformFieldMap.put(GlUt_APIConstantsAvailableServiceItem.AVALSRVCITEMAPINAME, contrtransFormFieldMap);                                 
 
        return bundleRecrds;   
    }
    
    /**********************************************************************************************
    @author         Echo: Dependra Singh
    @date           12-Aug-2018
    @param          NA
    @return         boolean
    @description    This method is used to identify that account has an active tariff limit or not.
    8A Development
    **********************************************************************************************/     
    @AuraEnabled
    public static boolean CheckActiveTariffLimit(Id accountId, string strMoveInDate){
        boolean isActiveTariff = false;
        try {
            if(accountId != null  && strMoveInDate != null){
                Date moveInDate = Date.valueOf(strMoveInDate);
                List<TariffLimit__c> tariffLimitList = [SELECT Id,Name,Account__c,EndDate__c,StartDate__c,Status__c 
                                                        FROM TariffLimit__c WHERE Account__c =: accountId 
                                                        AND StartDate__c <=: moveInDate AND (EndDate__c >: moveInDate OR EndDate__c = null)];
                if(tariffLimitList != null && !tariffLimitList.isEmpty()){
                    isActiveTariff = true;
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return isActiveTariff;
    }
    /**********************************************************************************************
    @author         Accenture: Satish Nair
    @date           06-Nov-2017
    @param          NA
    @return         List<BlAp_CombinedRecord>
    @description    This method retrieves all the Sundry service Item types and displays on the screen
    **********************************************************************************************/    
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveSundryServices() {
        List<BlAp_CombinedRecord>  combSundryList = new List<BlAp_CombinedRecord>();
        try {
            GlUt_Logger.logDebug(DEBUG);
            List<ServiceItemType__c> srvItmTypeList = [Select Id,name,AvailabletoSelectInWizard__c,StartDate__c,EndDate__c,SelectSundry__c from ServiceItemType__c 
                                                       where AvailabletoSelectInWizard__c=True and SelectSundry__c=True];                                 
            
            if(!srvItmTypeList.isEmpty()){
                for(ServiceItemType__c srvItmType : srvItmTypeList){
                    BlAp_CombinedRecord srvItmTypeRecrds = new BlAp_CombinedRecord();
                    srvItmTypeRecrds.uniqueId=srvItmType.Id;
                    srvItmTypeRecrds.isSelected = false;
                    
                    srvItmTypeRecrds.objectMap = new Map<string, sObject>();
                    srvItmTypeRecrds.objectMap.put(GlUt_APIConstantsServiceItemType.SERVICEITEMTYPEAPINAME, srvItmType);
                    combSundryList.add(srvItmTypeRecrds);
                    
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return combSundryList;
    }
   
}