/******************************************************************************
@author         Echo: Vivek Sethi
@date           05-Feb-2019
@description    Component controller for Split Suspense Payment Lightning Component 
*******************************************************************************/
public with sharing class LoAp_SiteSupplyCtrlr {
    // Variables
    private static List<String> supplyPointFields;
    private static List<String> locationFields;
    private static List<String> siteSupplyFields;
    private static List<String> supplyPointDeviceFields;
   
    static{
        // Get fields from the supply Point object
        supplyPointFields = new List<String>();
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.NAMEAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.LOCATIONAPINAME);
    }
    
    static{
        //Get Fields from the Location Object
        locationFields = new List<String>();
        locationFields.add(GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME);
    }
    
    static{
        //Get Fields from the siteSupply Object
        siteSupplyFields = new List<String>();
        siteSupplyFields.add(GlUt_APIConstantsSiteSupply.SUPPLYPOINTAPINAME);
        siteSupplyFields.add(GlUt_APIConstantsSiteSupply.STARTDATEAPINAME);
        siteSupplyFields.add(GlUt_APIConstantsSiteSupply.ENDDATEAPINAME);
        siteSupplyFields.add(GlUt_APIConstantsSiteSupply.PERCENTAGESPLITAPINAME);
        
    }

    static {
        //Get Fields from the supplyPointDevice Object
        supplyPointDeviceFields  = new List<String>();
        supplyPointDeviceFields.add(GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME);
        supplyPointDeviceFields.add(GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME);
    }
    
    /**********************************************************************************************
	@author         Echo: Vivek Sethi
	@date           05-Feb-2019
	@return         List<List<GLAp_FieldProps>>
	@description    This method returns the values for each of the fields that are to be displayed on the screen
	**********************************************************************************************/    
    @AuraEnabled
    public static Map<String,String> retrieveSupplyPointDetails(string supplyPointId) {
        Map<String,String> siteSupplyMap = new Map<String,String>();
        SupplyPoint__c objSupplyPoint;
        Location__c objLocation;
        String whereClause;
        objSupplyPoint = (SupplyPoint__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,supplyPointId,supplyPointFields);
        
        if(objSupplyPoint != null && objSupplyPoint.Id != null) {
            siteSupplyMap.put(GlUt_APIConstantsSupplyPoint.NAMEAPINAME,objSupplyPoint.Name);
            
            if(objSupplyPoint.Location__c != null) {
             objLocation = (Location__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsLocation.LOCATIONAPINAME,objSupplyPoint.Location__c,locationFields);
             siteSupplyMap.put(GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME, objLocation.Address__c);
            }
        }
        return siteSupplyMap; 
    }
    
    /**********************************************************************************************
    @author         Echo: Vivek Sethi
    @date           05-Feb-2019
    @return         List<List<GLAp_FieldProps>>
    @description    This method returns the field properties for each of the fields that are to be displayed on the screen
    **********************************************************************************************/    
    @AuraEnabled
    public static List<List<GLAp_FieldProps>> retrieveSupplyPointPropDetails() {
        // List of fieldprops to return
        List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
        List<GLAp_FieldProps> paymentProps = new List<GLAp_FieldProps>();
        List<GLAp_FieldProps> locationFieldsList = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsLocation.LOCATIONAPINAME, locationFields); 
        List<GLAp_FieldProps> supplyPointList   =  GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, supplyPointFields);
        List<GLAp_FieldProps> siteSupplyList = new List<GLAp_FieldProps>();
      
        for(GLAp_FieldProps locProp: locationFieldsList){
            locProp.isEditable = false;
            if(locProp.fieldName == GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME){
                locProp.fieldLabel = PyAp_Constants.LOCATIONADDRESS_FIELDLABEL;
                siteSupplyList.add(locProp);
            }
        }
        
        for(GLAp_FieldProps spObj: supplyPointList){
            spObj.isEditable = false;
            if(spObj.fieldName ==  GlUt_APIConstantsSupplyPoint.NAMEAPINAME){
                spObj.fieldLabel = PyAp_Constants.SUPPLYPOINT_FIELDLABEL;
                siteSupplyList.add(spObj);
            }
        }

        for(integer i=0; i < siteSupplyList.size(); i = i+2){
            List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
            integer secondEntryIndex = i+1;
            lstEntry.add(siteSupplyList[i]);
            
            if(secondEntryIndex < siteSupplyList.size()){
                lstEntry.add(siteSupplyList[secondEntryIndex]);   
            }
            twoColFormattedList.add(lstEntry);
        }
        return twoColFormattedList;
    } 
    
    /**********************************************************************************************
    @author      : Echo : Vivek Sethi
    @date        : 05-Feb-2019
    @description : This is a wrapper class Combined List records,FieldProperty Details.
    **********************************************************************************************/
    public class ContainerWrapper {
        @AuraEnabled public List<List<GlAp_FieldProps>> fieldPropList;
        @AuraEnabled public Map<String,String> objSP;
        @AuraEnabled public List<SiteSupplyWrapper> siteSupplyWrap ; 
        @AuraEnabled public boolean isShowCmp;
        
        public ContainerWrapper(){
            fieldPropList = new List<List<GlAp_FieldProps>>();
            objSP= new Map<String,String>();
            siteSupplyWrap = new List<SiteSupplyWrapper>();
            isShowCmp = false;
        }
    }
    /**********************************************************************************************
    @author      : Echo : Vivek Sethi
    @date        : 05-Feb-2019
    @return      : ContainerWrapper
    @description : Method is used to show information in lighting page using wrapper class.
    **********************************************************************************************/
    @AuraEnabled
    public static ContainerWrapper getInfoToDisplay(string supplyPointId){
        try{
            ContainerWrapper resultContainer = new ContainerWrapper();
            resultContainer.fieldPropList = retrieveSupplyPointPropDetails();
            resultContainer.objSP =   retrieveSupplyPointDetails(supplyPointId);
            resultContainer.isShowCmp = IsShowComponent(supplyPointId);
            
            Map<Id,SiteSupply__c> siteSupplyId2SiteSupplyMap= new Map<Id,SiteSupply__c>();
            Map<Id,SupplyPoint__c> supplyPointLocation2SupplyPointMap= new Map<Id,SupplyPoint__c>();
            
            String filterStatement  = 'WHERE ' +  GlUt_APIConstantsSiteSupply.SITESUPPLYPOINTAPINAME + ' = \''+ string.escapeSingleQuotes(supplyPointId) +'\' ' 
                +  ' AND ' + GlUt_APIConstantsSiteSupply.INVALIDAPINAME + ' = FALSE' 
                + ' AND ' + GlUt_APIConstantsSiteSupply.AMENDEDBYSITESUPPLYAPINAME + ' = null '
                + ' AND ' + GlUt_APIConstantsSiteSupply.ENDDATEAPINAME + ' = null ';
         
            List<SiteSupply__c> lstSiteSupply = (List<SiteSupply__c>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSiteSupply.SITESUPPLYAPINAME, 
                                                                                     siteSupplyFields,
                                                                                     filterStatement);
            
            if(lstSiteSupply != null && !lstSiteSupply.isEmpty()) {
                for(SiteSupply__c objSiteSupply :  lstSiteSupply) { 
                    siteSupplyId2SiteSupplyMap.put(objSiteSupply.SupplyPoint__c,objSiteSupply);
                }
            }
            
            if(siteSupplyId2SiteSupplyMap != null && !siteSupplyId2SiteSupplyMap.isEmpty()) {
                List<SupplyPoint__c> lstSP = (List<SupplyPoint__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,
                                                                                                        SupplyPointFields,
                                                                                                        'WHERE ' + LoAp_Constants.Id + ' IN ' + GlUt_FieldSecurity.IdsToString(siteSupplyId2SiteSupplyMap.keySet())); 
                if(lstSP != null && !lstSP.isEmpty()) {
                    for(SupplyPoint__c objSupplyPoint :  lstSP){ 
                        supplyPointLocation2SupplyPointMap.put(objSupplyPoint.Location__c, objSupplyPoint);
                    }
                }
            }
            
            if(supplyPointLocation2SupplyPointMap != null && !supplyPointLocation2SupplyPointMap.isEmpty()) {
                List<Location__c> lstLocation = (List<Location__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocation.LOCATIONAPINAME,
                                                                                                        locationFields,
                                                                                                        'WHERE ' + LoAp_Constants.Id + ' IN ' + GlUt_FieldSecurity.IdsToString(supplyPointLocation2SupplyPointMap.keySet())); 
                
                if(lstLocation != null && !lstLocation.isEmpty()) {
                    for(Location__c objLocation : lstLocation){                
                        SiteSupplyWrapper objWrap = new SiteSupplyWrapper(); 
                        objWrap.SiteSupplyId = siteSupplyId2SiteSupplyMap.get(supplyPointLocation2SupplyPointMap.get(objLocation.Id).Id).Id;
                        objWrap.startDate =   siteSupplyId2SiteSupplyMap.get(supplyPointLocation2SupplyPointMap.get(objLocation.Id).Id).StartDate__c;
                        objWrap.endDate = siteSupplyId2SiteSupplyMap.get(supplyPointLocation2SupplyPointMap.get(objLocation.Id).Id).EndDate__c;
                        objWrap.strPercentageSplit = String.valueOf(siteSupplyId2SiteSupplyMap.get(supplyPointLocation2SupplyPointMap.get(objLocation.Id).Id).PercentageSplit__c);
                        objWrap.objSupplyPoint =   supplyPointLocation2SupplyPointMap.get(objLocation.Id);
                        objWrap.strStatus =    System.Label.LoAp_SiteSupplyExistingRecord;
                        objWrap.strLocationName =  objLocation.Address__c.length() > 29 ? objLocation.Address__c.substring(0,28) : objLocation.Address__c ;
                        resultContainer.siteSupplyWrap.add(objWrap);
                    }
                }
            }
            return resultContainer;
        }
        catch (exception e) {
            String errorMsg = GlUt_Logger.getActualErrorMessage(e.getMessage());
            GlUt_Logger.logException(e);
            throw new AuraHandledException(errorMsg);
        }
    }
    /**********************************************************************************************
    @author      : Echo: Vivek Sethi
    @date        : 05-Feb-2019
    @params      : String
    @return      : Payment
    @description : Component will be added to the Billing Actions Component 
				   where the Payment does not have a Contract or Account associated 
				   and is not an Invalid Suspense Payment
    **********************************************************************************************/   
    public static boolean IsShowComponent(String supplyPointId) {
        boolean isShowComponent= false;
        List<SupplyPointDevice__c> objSPDList = new List<SupplyPointDevice__c>();
        if (String.isNotBlank(supplyPointId)) {
            String filterStatement  = 'WHERE ' +  GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME + ' = \''+   String.escapeSingleQuotes(supplyPointId) +'\' ' ;
            List<SupplyPointDevice__c> lstSPD = GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, 
                                                                                    SupplyPointDeviceFields,
                                                                                    filterStatement);
            
            if(lstSPD != null && !lstSPD.isEmpty()) {
                for(SupplyPointDevice__c sp :  lstSPD) {
                    if(sp.Active__c ) {
                        isShowComponent =true;
                        break;
                    }
                }
            }
        }
        return isShowComponent;
    }
    /**********************************************************************************************
    @author      : Echo: Vivek Sethi
    @date        : 05-Feb-2019
    @params      : String
    @return      : Payment
    @description : Wrapper class for table 
    **********************************************************************************************/   
    public class SiteSupplyWrapper {
        @AuraEnabled public SupplyPoint__c objSupplyPoint;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Id  SiteSupplyId;
        @AuraEnabled public Date endDate;
        @AuraEnabled public String strLocationName;
        @AuraEnabled public String strStatus;
        @AuraEnabled public String strPercentageSplit;
        @AuraEnabled public String supplyPointId;
    }
    
  
    /******************************************************************************
    @author      : Echo: Vivek Sethi
    @date        : 05-Feb-2019
    @return      : SiteSupplyWrapper
    @description : This method adds a new Site Supply row in the component
    *******************************************************************************/
    @AuraEnabled
    public static SiteSupplyWrapper AddMoreRows() {
        SiteSupplyWrapper siteSupplyWrap = new SiteSupplyWrapper();        
        try {
            siteSupplyWrap.objSupplyPoint = new SupplyPoint__c();
            siteSupplyWrap.strLocationName = '';
            siteSupplyWrap.startDate = null;
            siteSupplyWrap.endDate = null;
            siteSupplyWrap.strLocationName = '';
            siteSupplyWrap.strStatus =  System.Label.LoAp_SiteSupplyNewRecord ;
            siteSupplyWrap.strPercentageSplit = '';
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return siteSupplyWrap;
    }
    /******************************************************************************
    @author      : Echo: Vivek Sethi
    @date        : 05-Feb-2019
    @return      : string AccountName
    @description : Get Account record By Account Id
    *******************************************************************************/
    @AuraEnabled
    public static string  getAccountNameById(string locationId){
        string strLocationAddress = '';
        if(locationId != null){
            Location__c objLocation = (Location__c)GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsLocation.LOCATIONAPINAME,locationId, locationFields); 
            if(objLocation != null){
                strLocationAddress =  objLocation.Address__c;
            }
        }
        return strLocationAddress;
    }
    
    /******************************************************************************
	@author      : Echo: Vivek Sethi
	@date        : 05-Feb-2019
	@return      : SiteSupplyWrapper
	@description : This method adds a split payment row in the component
	*******************************************************************************/
    public class RecordsProcessedWrapper {
        @AuraEnabled public List<Id> siteSupplyContractlist ; 
        @AuraEnabled public boolean isSuccess;
        public RecordsProcessedWrapper(){
            siteSupplyContractlist = new List<Id> ();
            isSuccess = false;
        }
    }
    
    /******************************************************************************
    @author      : Echo: Vivek Sethi
    @date        : 05-Feb-2019
    @return      : boolean
    @description : Method is used to save data.
    *******************************************************************************/
    @AuraEnabled
    public static RecordsProcessedWrapper ProcessSiteSupply(String newRecords , String existingRecords , String removedRecords ) {
		system.debug('ProcessSiteSupply-newRecords=> ' + newRecords);
        system.debug('ProcessSiteSupply-existingRecords=> ' + existingRecords);
        system.debug('ProcessSiteSupply-removedRecords=> ' + removedRecords);
        
        RecordsProcessedWrapper recordsProcessed = new RecordsProcessedWrapper();
        List<SiteSupply__c> exisingSiteSupplyList = new List<SiteSupply__c>();
        Set<Id> siteSupplyAmendedSet = new Set<Id> ();
        List<SiteSupply__c> newSiteSupplyList = new List<SiteSupply__c>();
        List<Id>  removedSiteSupplyIdList = new List<Id>();
        List<SiteSupply__c> siteSupplyRemovedList = new List<SiteSupply__c>();
        List<SiteSupply__c> amendedSiteSupplyList = new List<SiteSupply__c>();
        Map<Id,SiteSupply__c> exisingSupplyId2SiteSupplyMap = new  Map<Id,SiteSupply__c>();
        Map<Id,SiteSupply__c> addedSiteSupplyMap = new  Map<Id,SiteSupply__c>();
        Map<Id,SiteSupply__c> siteSupply2SiteSupplyModifiedMap = new Map<Id,SiteSupply__c>();
        Map<Id,SiteSupply__c> siteSupply2siteSupplyExistingMap = new Map<Id,SiteSupply__c>();
        
        if(existingRecords != null)
            exisingSiteSupplyList = (List<SiteSupply__c>)JSON.deserialize(existingRecords, List<SiteSupply__c>.class);
  
        if(newRecords != null)
            newSiteSupplyList = (List<SiteSupply__c>)JSON.deserialize(newRecords, List<SiteSupply__c>.class);
  
        if(removedRecords != null)
            removedSiteSupplyIdList = (List<Id>)JSON.deserialize(removedRecords, List<Id>.class);
  
        Savepoint sp = Database.setSavepoint();
        try {
            
            if(removedSiteSupplyIdList != null && !removedSiteSupplyIdList.isEmpty()) {
                for(SiteSupply__c siteSupplyInvalid : [SELECT Id, 
                                                       Invalid__c 
                                                       FROM SiteSupply__c
                                                       WHERE Id IN: removedSiteSupplyIdList]) 
                {
                    siteSupplyInvalid.Invalid__c = true ;
                    siteSupplyRemovedList.add(siteSupplyInvalid);
                    siteSupplyAmendedSet.add(siteSupplyInvalid.Id);
                }
                if(siteSupplyRemovedList!= null && !siteSupplyRemovedList.isEmpty())
                    update siteSupplyRemovedList;
            }
            if(newSiteSupplyList != null && !newSiteSupplyList.isEmpty()) {
                insert newSiteSupplyList;
            }
            if(exisingSiteSupplyList !=  null && !exisingSiteSupplyList.isEmpty()) {
                for(SiteSupply__c siteSupplyModifiedValues : exisingSiteSupplyList ) {
                    exisingSupplyId2SiteSupplyMap.put(siteSupplyModifiedValues.Id , siteSupplyModifiedValues);
                }
                for(SiteSupply__c siteSupplyExisting : [SELECT Id,
                                                        StartDate__c,
                                                        EndDate__c,
                                                        SupplyPoint__c,
                                                        Ended__c, 
                                                        PercentageSplit__c ,
                                                        SiteSupplyPoint__c, 
                                                        AmendedBySiteSupply__c
                                                        FROM SiteSupply__c 
                                                        WHERE Id IN: exisingSupplyId2SiteSupplyMap.keyset()]) 
                {
                    if((siteSupplyExisting.PercentageSplit__c != exisingSupplyId2SiteSupplyMap.get(siteSupplyExisting.Id).PercentageSplit__c)
                      || (siteSupplyExisting.StartDate__c != exisingSupplyId2SiteSupplyMap.get(siteSupplyExisting.Id).StartDate__c)) {
                           siteSupply2siteSupplyExistingMap.put(siteSupplyExisting.Id,siteSupplyExisting);
                           siteSupply2SiteSupplyModifiedMap.put(siteSupplyExisting.Id,exisingSupplyId2SiteSupplyMap.get(siteSupplyExisting.Id));
                       }
                }
                if(siteSupply2SiteSupplyModifiedMap != null && !siteSupply2SiteSupplyModifiedMap.isEmpty()) {
                    for(SiteSupply__c siteSupplyModified : siteSupply2SiteSupplyModifiedMap.values()) {
                        SiteSupply__c newSiteSupply = new SiteSupply__c();
                        newSiteSupply.StartDate__c =   siteSupplyModified.StartDate__c  ;
                        newSiteSupply.EndDate__c =   siteSupplyModified.EndDate__c  ; //EndDate
                        newSiteSupply.PercentageSplit__c = siteSupplyModified.PercentageSplit__c;
                        newSiteSupply.SiteSupplyPoint__c = siteSupplyModified.SiteSupplyPoint__c;
                        newSiteSupply.SupplyPoint__c = siteSupplyModified.SupplyPoint__c;
                        addedSiteSupplyMap.put(siteSupplyModified.Id,newSiteSupply);
                        
                        siteSupplyAmendedSet.add(siteSupplyModified.Id);
                        
                    }
                    insert addedSiteSupplyMap.values();
                    for(SiteSupply__c siteSupplyAmended : siteSupply2siteSupplyExistingMap.values()) {
                        if(newSiteSupplyList.isEmpty()) {
                            siteSupplyAmended.AmendedBySiteSupply__c = addedSiteSupplyMap.get(siteSupplyAmended.Id).Id;
                        } else {
                            siteSupplyAmended.Ended__c = true ; 
                            Date endDate = newSiteSupplyList[0].StartDate__c - 1 ;
                            siteSupplyAmended.EndDate__c =  siteSupplyAmended.StartDate__c > endDate ? siteSupplyAmended.StartDate__c :  endDate ; 
                        }
                        amendedSiteSupplyList.add(siteSupplyAmended);
                    }
                    if(amendedSiteSupplyList != null && !amendedSiteSupplyList.isEmpty())
                        update amendedSiteSupplyList;
                }
            }
            
            if(!siteSupplyAmendedSet.isEmpty()) {
                GlUt_SiteSupplyContractFinder siteSupplyContractFinder = new GlUt_SiteSupplyContractFinder();
                recordsProcessed.siteSupplyContractlist.addAll(siteSupplyContractFinder.retrieveContractIds(siteSupplyAmendedSet));
            }
            recordsProcessed.isSuccess = true;  
        } catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
        return recordsProcessed;
    }
}