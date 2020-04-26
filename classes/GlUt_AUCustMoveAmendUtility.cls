/******************************************************************************
@author         Tarun Gupta 
@date           02 Nov 2018
@description    Utility class for AU Customer Move Amendment  
@Revisions		AT-5275
@Revisions		Fixed cleansing issues
@Revisions		Fixed cleansing issues in Map and Wrapper classes, 
				Changed upsert as it doesn't work on List<Sobject> after cleanse
*******************************************************************************/
public class GlUt_AUCustMoveAmendUtility {    
    
    private static Map<Id,Reading__c> mapDeviceId2ReadingObject = new Map<Id,Reading__c>();
    private static LocationOccupant__c currentLocOccRecord = new LocationOccupant__c(); 
    private static List<Reading__c> listReadingFromWizard = new List<Reading__c>();
    private static List<Reading__c> listMoveInOutReadingOnDevice = new List<Reading__c>();
    private static List<ServiceItem__c> serviceItemListOnLocation = new List<ServiceItem__c>();
    private static  List<LocationOccupant__c> listAllLocOccOnLocation = new List<LocationOccupant__c>();
    private static List<Reading__c> listVoidAndMoveReadingsOnDevice = new List<Reading__c>();
    private static BillingContract__c newBillingAddress = new BillingContract__c();
    private static  Map<Id,Id> mapServiceItemId2ContractId = new Map<Id,Id>();
    private static  Set<Id> amendedContracts = new Set<Id>();
    private static  Set<Id> supplyPointsWithNoPreviousTenant = new Set<Id>();
    private static  Set<Id> supplyPointsWithNoFollowingTenant = new Set<Id>();
    
    private static Map<Date,Date> mapOldStartDateToNewStartDate = new Map<Date,Date>();
	private static Map<Date,Date> mapOldEndDateToNewEndDate = new Map<Date,Date>();
    
    private static Set<Id> setDeviceIds = new Set<Id>();
    private static Set<Id> setContractIds = new Set<Id>();
    private static Date newMoveInDate;
    private static Date newMoveOutDate;
    private static Date originalMoveInDate;
    private static Date originalMoveOutDate;
    
    private static Id locationOccupantId;
    private static Id locationId;
    private static Id accountId;
    private static String deleteRecord; 
    private static String moveInOrMoveOut;
    private static Boolean prevOcc = false;
    private static Boolean subsequentOcc = false;
    
	private static final List<String> accountFields = new List<string>{
        	GlUt_APIConstantsAccount.BILLINGSTREETAPINAME,
            GlUt_APIConstantsAccount.BILLINGCITYAPINAME,
            GlUt_APIConstantsAccount.BILLINGSTATEAPINAME,
            GlUt_APIConstantsAccount.BILLINGPOSTALCODEAPINAME,
            GlUt_APIConstantsAccount.BILLINGCOUNTRYAPINAME    
            };
                
    private static final List<String> locOccFields = new List<string>{
        	GlUt_APIConstantsLocationOccupant.NAMEAPINAME,
            GlUt_APIConstantsLocationOccupant.PRIMARY,
            GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTENDDATE,
            GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTLOCATION,
            GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATE,
                GlUt_APIConstantsLocationOccupant.OCCUPANCYTYPEAPI,
                GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTACCOUNT
            };
                
  	private static final List<String> supplyPointFields = new List<string>{
        	GlUt_APIConstantsSupplyPoint.LOCATIONAPINAME
            }; 
                
	private static final List<String> serviceFields = new List<string>{
        	GlUt_APIConstantsService.SERVICESTARTDATEAPINAME,
            GlUt_APIConstantsService.SERVICEENDDATEAPINAME,
            GlUt_APIConstantsService.SERVICECONTRACTAPINAME,
                GlUt_APIConstantsService.OCCUPANCYTYPEAPINAME
            };
                
	private static final List<String> readingFields = new List<string>{
        	GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME,
            GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME,
            GlUt_APIConstantsReading.READINGDATEAPINAME,
            GlUt_APIConstantsReading.READINGMETHODAPINAME,
            GlUt_APIConstantsReading.READINGTYPEAPINAME,
            GlUt_APIConstantsReading.BILLEDAPINAME,
            GlUt_APIConstantsReading.NAMEAPINAME,
            GlUt_APIConstantsReading.BILLABLETYPEAPINAME
            };                
	
	private static final List<String> supplyPointDeviceFields = new List<string>{
        	GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME,
            GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME,
            GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME    
            };                

	private static final List<String> serviceItemFields = new List<string>{
        	GlUt_APIConstantsServiceItem.STARTDATEAPINAME,
            GlUt_APIConstantsServiceItem.ENDDATE,
            GlUt_APIConstantsServiceItem.SERVICEITEMTYPEAPINAME,
            GlUt_APIConstantsServiceItem.LOCATIONAPINAME,
                //GlUt_APIConstantsServiceItem.SUPPLYPOINTAPINAME,
                GlUt_APIConstantsServiceItem.AMENDEDBYSERVICEITEMAPINAME,
                GlUt_APIConstantsServiceItem.SERVICECONTRACTREFAPINAME,
                GlUt_APIConstantsServiceItem.AVAILABLESERVICEITEMAPINAME,
                GlUt_APIConstantsServiceItem.DISCHARGEAGREEMENTAPINAME,
                GlUt_APIConstantsServiceItem.QUANTITYAPINAME,
                GlUt_APIConstantsServiceItem.ENDEDAPINAME,
                GlUt_APIConstantsServiceItem.SERVICESPREFERENCAPINAME,
                GlUt_APIConstantsServiceItem.SERVICEITEMTYPETENANTREFAPINAME,
                GlUt_APIConstantsServiceItem.SERVICEITEMTYPEOWNERREFAPINAME,
                GlUt_APIConstantsServiceItem.SERVICEOCCTYPEREFAPINAME,
                GlUt_APIConstantsServiceItem.SERVICEAPINAME
            };   
                
	/**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is for getting preRequisite
    **********************************************************************************************/    
    public static Set<Id> preRequisite(Id accountIdFromWiz, LocationOccupant__c selectedLocOcc, Id locationOccupantIdFromWiz, Id locationIdFromWiz, List<Reading__c> listWizardReadingFromWiz, String deleteRecordFromWiz, Date moveInDateFromWiz, Date moveOutDateFromWiz, BillingContract__c newBillingAddressFromWiz, Boolean prevOccNew, Boolean subsequentOccNew) {
        
        //Assign Generic Values
        assignGenericValues(accountIdFromWiz, locationOccupantIdFromWiz,locationIdFromWiz,deleteRecordFromWiz,moveInDateFromWiz,moveOutDateFromWiz,listWizardReadingFromWiz,newBillingAddressFromWiz,prevOccNew, subsequentOccNew);
        //Get All device Id on Location 
        getDevicesOnLocation();
        //Get Current Location Occupant Record
        getCurrentLocationOccupant();
        //Get List of Location Occ on Location 
        getLocationOccRecordsOnLocation();
        //Get All device Id on Location if reading is not present, this is required in case of delete
        getDeviceIds();
        //Get All device move In move Out readings
        getAllDevicesMoveInOutReadings();
        //Get List of all SI on location
        serviceItemListOnLocation = getListOfServiceItems();
        //Get List of Void Readings
        getVoidAndMoveInReadingsOnDevice();
        //Operation
        checkOperation();
        
        setContractIds.addAll(amendedContracts);
        
        return setContractIds;
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to assign generic values to global variables
    **********************************************************************************************/    
    public static void assignGenericValues(Id accountIdFromWiz, Id locationOccupantIdFromWiz, Id locationIdFromWiz, String deleteRecordFromWiz, Date moveInDateFromWiz, Date moveOutDateFromWiz, List<Reading__c> listWizardReading, BillingContract__c newBillingAddressFromWiz, Boolean prevOccNew, Boolean subsequentOccNew) {
        
        locationOccupantId = locationOccupantIdFromWiz;
        locationId = locationIdFromWiz;
        deleteRecord = deleteRecordFromWiz;
        newMoveInDate = moveInDateFromWiz;
        newMoveOutDate = moveOutDateFromWiz;
        listReadingFromWizard = listWizardReading;
        newBillingAddress = newBillingAddressFromWiz;
        accountId = accountIdFromWiz;
        prevOcc = prevOccNew != null ? prevOccNew : false;
        subsequentOcc = subsequentOccNew != null ? subsequentOccNew : false;
        
        if(newMoveInDate != null)
            moveInOrMoveOut = Label.CuAp_ReadingReadingTypeMoveIn; //Move In Type
        else if(newMoveOutDate != null)
            moveInOrMoveOut = Label.CuAp_ReadingReadingTypeMoveOut; //Move Out Type
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to check operation
    **********************************************************************************************/    
    public static void checkOperation() {
        Savepoint sp = Database.setSavepoint();
        try{
            if(deleteRecord == 'false'){
                //If the start date of the Tenancy Occupation has been changed 
                if(newMoveInDate != null)
                    tenantStartDateChange();
                
                //If the end date of the Tenancy Occupation has changed 
                if(newMoveOutDate != null)
                    tenantEndDateChange();
                
                // To Invalidate old Move In\Out reading
                invalidateOldMoveInOrOutReadings();
                
                // New Move In\Out reading to be created
                insertNewReadingsFromWizard();
                
                //invalidate other move readings
                createAndInvalidateMoveReadings(mapOldStartDateToNewStartDate,mapOldEndDateToNewEndDate);
            }
            else if(deleteRecord == 'true'){
                //If the Occupancy has been deleted
                deleteLocationOccupantsRecords() ;
            }   
        }
        catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            System.debug('exception = '+e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }   
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to check operation
    **********************************************************************************************/    
    public static void tenantStartDateChange() {
        
        //Update Current Tenant
        updateCurrentTenant();
        //Update Service Items
        updateServiceItems(Label.CuAp_ReadingReadingTypeMoveIn);
        //If the Adjust Previous Occupancy flag is set to true in the wizard properties ,Update Previous Tenant, if required 
        updateOwnerAndPreviousOccupiers();
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to check operation
    **********************************************************************************************/    
    public static void tenantEndDateChange() {
        
        //Update Current Tenant
        updateCurrentTenant();
        //Update Service Items
        updateServiceItems(Label.CuAp_ReadingReadingTypeMoveOut);
        //If the Adjust Subsequent Occupancy flag is set to true ,Update Next Tenant, if required 
        updateOwnerAndNextOccupiers();
        
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to update Current selected tenant
    **********************************************************************************************/    
    public static void updateCurrentTenant() {
        
        LocationOccupant__c selectedLocOcc = new LocationOccupant__c();
        selectedLocOcc = currentLocOccRecord;
        
        if(selectedLocOcc != null){
            
            if(newMoveInDate != null){
                if(!mapOldStartDateToNewStartDate.containsKey(selectedLocOcc.StartDate__c)){
                    mapOldStartDateToNewStartDate.put(selectedLocOcc.StartDate__c,newMoveInDate);
                }
                selectedLocOcc.StartDate__c = newMoveInDate;
                
            }
            else if(newMoveOutDate != null){
                if(!mapOldEndDateToNewEndDate.containsKey(selectedLocOcc.EndDate__c)){
                    mapOldEndDateToNewEndDate.put(selectedLocOcc.EndDate__c,newMoveOutDate);
                }
                selectedLocOcc.EndDate__c = newMoveOutDate; 
            }
            selectedLocOcc = (LocationOccupant__c) GlUt_FieldSecurity.cleanseFields(selectedLocOcc, false);
            if(selectedLocOcc != null)
                update selectedLocOcc;
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to update Current selected tenants service Items
	**********************************************************************************************/    
    public static void updateServiceItems(String moveInOrMoveOut) {
        List<ServiceItem__c> listServiceItemToAmendNew = new List<ServiceItem__c>();
        serviceItemListOnLocation = getListOfServiceItems();
        
        Map<Integer,ServiceItem__c> mapUniqueKey2AmendedServiceItem = new Map<Integer,ServiceItem__c>();
        Map<Integer,ServiceItem__c> mapUniqueKey2NewServiceItem = new Map<Integer,ServiceItem__c>();
        List<ServiceItem__c> listServiceItemsToInsert = new List<ServiceItem__c>();
        List<ServiceItem__c> listServiceItemToAmend = new List<ServiceItem__c>();
        Map<Integer,Id> mapUniqueKey2NewServiceItemNew = new Map<Integer,Id>();
        Integer uniqueCount = 0;
        
        if(serviceItemListOnLocation != null && !serviceItemListOnLocation.isEmpty()){
            for(ServiceItem__c objSI :serviceItemListOnLocation){
                
                //Start Date is changed
                if(moveInOrMoveOut == Label.CuAp_ReadingReadingTypeMoveIn){
                    //Tenant and Start date same
                    if(objSI.Service__r.OccupancyType__c == Label.CuAp_AUMoveInOccType && objSI.StartDate__c == originalMoveInDate){
                        uniqueCount += 1;
                        ServiceItem__c objNewSI = new ServiceItem__c();
                        objNewSI = createServiceItemObject(objSI,newMoveInDate,Label.CuAp_AmendMoveStartDateChange);
                        
                        if(!mapUniqueKey2AmendedServiceItem.containsKey(uniqueCount)){
                            mapUniqueKey2AmendedServiceItem.put(uniqueCount,objSI);
                        }
                        if(!mapUniqueKey2NewServiceItem.containsKey(uniqueCount)){
                            mapUniqueKey2NewServiceItem.put(uniqueCount,objNewSI);
                        }
                        amendedContracts.add(objSI.Service__r.BillingContract__c);
                    }
                }
                //End Date is changed
                else if(moveInOrMoveOut == Label.CuAp_ReadingReadingTypeMoveOut){
                    
                    //Tenant and End date same
                    if(objSI.Service__r.OccupancyType__c == Label.CuAp_AUMoveInOccType && originalMoveOutDate != null && objSI.EndDate__c == originalMoveOutDate){
                        objSI.EndDate__c = newMoveOutDate.addDays(-1);
                        objSI.Ended__c = true;
                        listServiceItemToAmend.add(objSI);
                        amendedContracts.add(objSI.Service__r.BillingContract__c);
                    }
                }
            }
            if(mapUniqueKey2NewServiceItem.keyset().size() > 0){
                listServiceItemsToInsert = mapUniqueKey2NewServiceItem.values();
                listServiceItemsToInsert = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(listServiceItemsToInsert, false);
                if(!listServiceItemsToInsert.isEmpty())   {
                    insert listServiceItemsToInsert;
                    
                    Integer i = 0;
                    for(ServiceItem__c objSI : listServiceItemsToInsert){
                        i = i + 1;
                        mapUniqueKey2NewServiceItemNew.put(i,objSI.Id);
                    }
                    if(mapUniqueKey2AmendedServiceItem.keyset().size() > 0){
                        for(Integer objAmendSI : mapUniqueKey2AmendedServiceItem.keyset()){
                            if(mapUniqueKey2NewServiceItemNew.containsKey(objAmendSI)){
                                ServiceItem__c objServiceItemAmend = mapUniqueKey2AmendedServiceItem.get(objAmendSI);
                                objServiceItemAmend.AmendedByServiceItem__c = mapUniqueKey2NewServiceItemNew.get(objAmendSI);
                                listServiceItemToAmend.add(objServiceItemAmend);
                            }
                        }
                    }
                }
            }
            if(!listServiceItemToAmend.isEmpty()){
                listServiceItemToAmend = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(listServiceItemToAmend, false);
                if(!listServiceItemToAmend.isEmpty()){
                    listServiceItemToAmendNew.addAll(listServiceItemToAmend);
                    listServiceItemToAmend.clear();
                    upsert listServiceItemToAmendNew;
                }
            }
        }
    }
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : If the Adjust Previous Occupancy flag is set to true in the wizard properties, Update Previous Tenant, if required 
	**********************************************************************************************/    
    public static void updateOwnerAndPreviousOccupiers() {
        //If the Adjust Previous Occupancy flag is set to true
        if(prevOcc){
            updatePreviousTenant();
            updateOwnerServItemInPrevOccCase();
        }
        //If the Adjust Previous Occupancy flag is set to false
        else{
            //Add any Service Items related to the Owner
            updateOwnerServiceItemsMoveInDate();
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : If the Adjust Subsequent Occupancy flag is set to true in the wizard properties, Update Next Tenant, if required 
	**********************************************************************************************/    
    public static void updateOwnerAndNextOccupiers() {
        //If the Adjust Subsequent  Occupancy flag is set to true
        if(subsequentOcc){
            updateNextTenant();
            updateOwnerServItemInSubOccCase();
        }
        //If the Adjust Subsequent Occupancy flag is set to false
        else{
            //Add any Service Items related to the Owner
            updateOwnerServiceItemsMoveOutDate();
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : If the Adjust Previous Occupancy flag is set to true in the wizard properties, Update Previous Tenant, if required 
	**********************************************************************************************/    
    public static void updatePreviousTenant() {
        List<ServiceItem__c> listServiceItemToAmend = new List<ServiceItem__c>();
        List<ServiceItem__c> listServiceItemToAmendNew = new List<ServiceItem__c>();
        LocationOccupant__c objLocOccPrevTenant;
        
        for(LocationOccupant__c objLocc : listAllLocOccOnLocation){
            
            //Tenant & less than current selected 
            if(objLocc.OccupancyType__c == Label.CuAp_AUMoveInOccType && objLocc.StartDate__c < originalMoveInDate){
                if(!mapOldEndDateToNewEndDate.containsKey(objLocc.EndDate__c)){
                    mapOldEndDateToNewEndDate.put(objLocc.EndDate__c,newMoveInDate.addDays(-1));
                }
                objLocc.EndDate__c = newMoveInDate.addDays(-1);
                objLocOccPrevTenant = objLocc;
                break;
            }
        }
        
        if(objLocOccPrevTenant != null){
            objLocOccPrevTenant = (LocationOccupant__c) GlUt_FieldSecurity.cleanseFields(objLocOccPrevTenant, false);
            if(objLocOccPrevTenant != null)
                update objLocOccPrevTenant;
        }
        
        serviceItemListOnLocation = getListOfServiceItems();
        
        if(serviceItemListOnLocation != null && !serviceItemListOnLocation.isEmpty()){
            
            for(ServiceItem__c objSI :serviceItemListOnLocation){
                //Tenant
                if(objSI.Service__r.OccupancyType__c == Label.CuAp_AUMoveInOccType && objSI.EndDate__c != null && objSI.EndDate__c < originalMoveInDate){
                    //If the Previous Service has an End Date = Move in Date -1
                    if(objSI.EndDate__c == originalMoveInDate.addDays(-1)){
                        objSI.EndDate__c = newMoveInDate.addDays(-1);
                        objSI.Ended__c = true;
                        listServiceItemToAmend.add(objSI);
                        
                        if(objSI.Service__r.BillingContract__c != null){
                            amendedContracts.add(objSI.Service__r.BillingContract__c);
                        }
                    }
                    else{
                        amendedContracts.add(objSI.Service__r.BillingContract__c);
                        supplyPointsWithNoPreviousTenant.add(objSI.Service__r.Supplypoint__c); 
                    }
                }
            }
        }
        
        if(!listServiceItemToAmend.isEmpty()){
            listServiceItemToAmend = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(listServiceItemToAmend, false);
            if(!listServiceItemToAmend.isEmpty()){
                listServiceItemToAmendNew.addAll(listServiceItemToAmend);
                listServiceItemToAmend.clear();
                upsert listServiceItemToAmendNew;
            }   
        }
        for(ServiceItem__c objServItem : listServiceItemToAmend){
            setContractIds.add(mapServiceItemId2ContractId.get(objServItem.Id)); 
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : If the Adjust Previous Occupancy flag is set to true in the wizard properties, Update Previous Tenant, if required 
	**********************************************************************************************/    
    public static void updateOwnerServItemInPrevOccCase() {
        List<ServiceItem__c> listServiceItemToAmend = new List<ServiceItem__c>();
        
        List<ServiceItem__c> listOtherServiceItems = [SELECT Id,Name,ServiceItemType__c,ServiceItemType__r.Owner__c,ServiceItemType__r.Tenant__c,Service__r.BillingContract__c,EndDate__c,Ended__c
                                                     FROM ServiceItem__c 
                                                     WHERE Service__r.Supplypoint__c IN: supplyPointsWithNoPreviousTenant];
        if(listOtherServiceItems != null && !listOtherServiceItems.isEmpty()){
            
            for(ServiceItem__c objSI : listOtherServiceItems){
                if(objSI.ServiceItemType__r.Owner__c && objSI.ServiceItemType__r.Tenant__c && objSI.EndDate__c == originalMoveInDate.addDays(-1)){
                    objSI.EndDate__c = newMoveInDate.addDays(-1);
                    objSI.Ended__c = true;
                    listServiceItemToAmend.add(objSI);
                    amendedContracts.add(objSI.Service__r.BillingContract__c);
                }
            }
            
            if(!listServiceItemToAmend.isEmpty()){
                listServiceItemToAmend = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(listServiceItemToAmend, false);
                if(!listServiceItemToAmend.isEmpty())                					
                    update listServiceItemToAmend;
            }
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : If the Adjust Previous Occupancy flag is set to false in the wizard properties
	**********************************************************************************************/    
    public static void updateOwnerServiceItemsMoveInDate() {
        List<ServiceItem__c> listServiceItemToAmend = new List<ServiceItem__c>();
        List<ServiceItem__c> listServiceItemToAmendNew = new List<ServiceItem__c>();
        serviceItemListOnLocation = getListOfServiceItems();
        for(ServiceItem__c objSI :serviceItemListOnLocation){
            
            //Service Item is checked for Owner and Tenant Occupancy & related service is for owner\landlord
            if(objSI.ServiceItemType__r.Owner__c && objSI.ServiceItemType__r.Tenant__c && (objSI.Service__r.OccupancyType__c == Label.CuAp_AUMoveInOccTypeLandlord || objSI.Service__r.OccupancyType__c == Label.CuAp_AUMoveInOccTypeOwner)){
                
                if(objSI.StartDate__c < originalMoveInDate 
                   /*&& (objSI.EndDate__c == null || objSI.EndDate__c >= originalMoveInDate)*/ ){
                       
                       if(objSI.EndDate__c != null && objSI.EndDate__c == originalMoveInDate.addDays(-1)){
                           objSI.EndDate__c = newMoveInDate.addDays(-1);
                           objSI.Ended__c = true;
                           listServiceItemToAmend.add(objSI);
                       }
                       else{
                           //ServiceItem__c objNewSI = new ServiceItem__c();
                           //objNewSI = createServiceItemObject(objSI,newMoveInDate,Label.CuAp_AmendMoveStartDateChange);
                           ServiceItem__c objNewSI = new ServiceItem__c();
                           objNewSI.ServiceItemType__c = objSI.ServiceItemType__c;
                           objNewSI.AvailableServiceItem__c = objSI.AvailableServiceItem__c;
                           objNewSI.DischargeAgreement__c = objSI.DischargeAgreement__c;
                           objNewSI.StartDate__c = originalMoveInDate;
                           objNewSI.EndDate__c = newMoveInDate.addDays(-1);
                           objNewSI.Service__c = objSI.Service__c;
                           objNewSI.Quantity__c = objSI.Quantity__c;
                           
                           listServiceItemToAmend.add(objNewSI);
                       }
                       amendedContracts.add(objSI.Service__r.BillingContract__c);
                   }
            }
        }
        if(!listServiceItemToAmend.isEmpty()){
            listServiceItemToAmend = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(listServiceItemToAmend, false);
            if(!listServiceItemToAmend.isEmpty())   {
                listServiceItemToAmendNew.addAll(listServiceItemToAmend);
                listServiceItemToAmend.clear();
                upsert listServiceItemToAmendNew;
            }    
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : If the Adjust Subsequent Occupancy flag is set to true in the wizard properties, Update Next Tenant, if required 
	**********************************************************************************************/    
    public static void updateNextTenant() {
        LocationOccupant__c objLocOccSubsequentTenant ;
        List<LocationOccupant__c> listSubsequentTenantLocOcc = new List<LocationOccupant__c>();
        List<ServiceItem__c> listServiceItemsToInsert = new List<ServiceItem__c>();
        Map<Integer,ServiceItem__c> mapUniqueKey2AmendedServiceItem = new Map<Integer,ServiceItem__c>();
        Map<Integer,ServiceItem__c> mapUniqueKey2NewServiceItem = new Map<Integer,ServiceItem__c>();
        List<ServiceItem__c> listServiceItemToAmend = new List<ServiceItem__c>();
        Integer uniqueCount = 0;
        Map<Integer,Id> mapUniqueKey2NewServiceItemNew = new Map<Integer,Id>();
		List<ServiceItem__c> listServiceItemToAmendNew = new List<ServiceItem__c>();        
        
        // listAllLocOccOnLocation - sorted by start date in DESC order
        for(LocationOccupant__c objLocc : listAllLocOccOnLocation){
            
            //Tenant & Start Date greater than current selected 
            if(objLocc.OccupancyType__c == Label.CuAp_AUMoveInOccType && objLocc.StartDate__c > originalMoveInDate){
                listSubsequentTenantLocOcc.add(objLocc);
            }
        }
        
        if(!listSubsequentTenantLocOcc.isEmpty()){
            objLocOccSubsequentTenant = listSubsequentTenantLocOcc[listSubsequentTenantLocOcc.size() - 1];
            if(!mapOldStartDateToNewStartDate.containsKey(objLocOccSubsequentTenant.StartDate__c)){
                mapOldStartDateToNewStartDate.put(objLocOccSubsequentTenant.StartDate__c,newMoveOutDate.addDays(1));
            }
            objLocOccSubsequentTenant.StartDate__c = newMoveOutDate.addDays(1);
        }
        if(objLocOccSubsequentTenant != null){
            objLocOccSubsequentTenant = (LocationOccupant__c) GlUt_FieldSecurity.cleanseFields(objLocOccSubsequentTenant, false);
            if(objLocOccSubsequentTenant != null)			
                update objLocOccSubsequentTenant;
        }
        
        serviceItemListOnLocation = getListOfServiceItems();
        if(serviceItemListOnLocation != null && !serviceItemListOnLocation.isEmpty()){
            
            for(ServiceItem__c objSI :serviceItemListOnLocation){
                //Tenant and stat date is less tha original move out date
                if(objSI.Service__r.OccupancyType__c == Label.CuAp_AUMoveInOccType && objSI.StartDate__c < originalMoveOutDate){
                    //If the next Service has Start Date = Original Move out Date + 1 
                    if(objSI.StartDate__c == originalMoveInDate.addDays(1)){
                        //create amendment SI
                        
                        uniqueCount += 1;
                        ServiceItem__c objNewSI = new ServiceItem__c();
                        objNewSI = createServiceItemObject(objSI,newMoveoutDate.addDays(1),Label.CuAp_AmendMoveStartDateChange);
                        
                        if(!mapUniqueKey2AmendedServiceItem.containsKey(uniqueCount)){
                            mapUniqueKey2AmendedServiceItem.put(uniqueCount,objSI);
                        }
                        if(!mapUniqueKey2NewServiceItem.containsKey(uniqueCount)){
                            mapUniqueKey2NewServiceItem.put(uniqueCount,objNewSI);
                        }
                        if(objSI.Service__r.BillingContract__c != null){
                            amendedContracts.add(objSI.Service__r.BillingContract__c);
                        }
                    }
                    else{
                        supplyPointsWithNoFollowingTenant.add(objSI.Service__r.Supplypoint__c); 
                    }
                }
            }
        }
        
        if(mapUniqueKey2NewServiceItem.keyset().size() > 0){
            listServiceItemsToInsert = mapUniqueKey2NewServiceItem.values();
            listServiceItemsToInsert = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(listServiceItemsToInsert, false);
            if(!listServiceItemsToInsert.isEmpty())   {
                insert listServiceItemsToInsert;
                
                Integer i = 0;
                for(ServiceItem__c objSI : listServiceItemsToInsert){
                    i = i + 1;
                    mapUniqueKey2NewServiceItemNew.put(i,objSI.Id);
                }
                if(mapUniqueKey2AmendedServiceItem.keyset().size() > 0){
                    for(Integer objAmendSI : mapUniqueKey2AmendedServiceItem.keyset()){
                        if(mapUniqueKey2NewServiceItemNew.containsKey(objAmendSI)){
                            ServiceItem__c objServiceItemAmend = mapUniqueKey2AmendedServiceItem.get(objAmendSI);
                            objServiceItemAmend.AmendedByServiceItem__c = mapUniqueKey2NewServiceItemNew.get(objAmendSI);
                            listServiceItemToAmend.add(objServiceItemAmend);
                        }
                    }
                }
            }
        }
        if(!listServiceItemToAmend.isEmpty()){
            listServiceItemToAmend = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(listServiceItemToAmend, false);
            if(!listServiceItemToAmend.isEmpty()){
                listServiceItemToAmendNew.addAll(listServiceItemToAmend);
                listServiceItemToAmend.clear();
                upsert listServiceItemToAmendNew;
            }
        }
        for(ServiceItem__c objServItem : listServiceItemToAmend){
            setContractIds.add(mapServiceItemId2ContractId.get(objServItem.Id)); 
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : If the Adjust Sbsequent Occupancy flag is set to true in the wizard properties, 
	**********************************************************************************************/    
    public static void updateOwnerServItemInSubOccCase() {
        
        Map<Integer,ServiceItem__c> mapUniqueKey2AmendedServiceItem = new Map<Integer,ServiceItem__c>();
        Map<Integer,ServiceItem__c> mapUniqueKey2NewServiceItem = new Map<Integer,ServiceItem__c>();
        List<ServiceItem__c> listServiceItemToAmend = new List<ServiceItem__c>();
        List<ServiceItem__c> listServiceItemsToInsert = new List<ServiceItem__c>();
        Integer uniqueCount = 0;
        Map<Integer,Id> mapUniqueKey2NewServiceItemNew = new Map<Integer,Id>();
        List<ServiceItem__c> listServiceItemToAmendNew = new List<ServiceItem__c>();
        
        List<ServiceItem__c> listOtherServiceItems = [SELECT Id,Name,ServiceItemType__c,ServiceItemType__r.Owner__c,ServiceItemType__r.Tenant__c,
                                                      Service__r.BillingContract__c,StartDate__c,AvailableServiceItem__c,DischargeAgreement__c,
                                                      EndDate__c,Service__c,Quantity__c
                                                     FROM ServiceItem__c 
                                                     WHERE Service__r.Supplypoint__c IN: supplyPointsWithNoFollowingTenant];
        
        if(listOtherServiceItems != null && !listOtherServiceItems.isEmpty()){
            
            for(ServiceItem__c objSI : listOtherServiceItems){
                if(objSI.ServiceItemType__r.Owner__c && objSI.ServiceItemType__r.Tenant__c && objSI.StartDate__c == originalMoveOutDate.addDays(1)){
                    uniqueCount += 1;
                    ServiceItem__c objNewSI = new ServiceItem__c();
                    objNewSI = createServiceItemObject(objSI,newMoveoutDate.addDays(1),Label.CuAp_AmendMoveStartDateChange);
                    
                    if(!mapUniqueKey2AmendedServiceItem.containsKey(uniqueCount)){
                        mapUniqueKey2AmendedServiceItem.put(uniqueCount,objSI);
                    }
                    if(!mapUniqueKey2NewServiceItem.containsKey(uniqueCount)){
                        mapUniqueKey2NewServiceItem.put(uniqueCount,objNewSI);
                    }
                    amendedContracts.add(objSI.Service__r.BillingContract__c);
                }
            }
            
            if(mapUniqueKey2NewServiceItem.keyset().size() > 0){
                listServiceItemsToInsert = mapUniqueKey2NewServiceItem.values();
                listServiceItemsToInsert = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(listServiceItemsToInsert, false);
                if(!listServiceItemsToInsert.isEmpty())   {
                    insert listServiceItemsToInsert;
                    
                    Integer i = 0;
                    for(ServiceItem__c objSI : listServiceItemsToInsert){
                        i = i + 1;
                        mapUniqueKey2NewServiceItemNew.put(i,objSI.Id);
                    }
                    if(mapUniqueKey2AmendedServiceItem.keyset().size() > 0){
                        for(Integer objAmendSI : mapUniqueKey2AmendedServiceItem.keyset()){
                            if(mapUniqueKey2NewServiceItemNew.containsKey(objAmendSI)){
                                ServiceItem__c objServiceItemAmend = mapUniqueKey2AmendedServiceItem.get(objAmendSI);
                                objServiceItemAmend.AmendedByServiceItem__c = mapUniqueKey2NewServiceItemNew.get(objAmendSI);
                                listServiceItemToAmend.add(objServiceItemAmend);
                            }
                        }
                    }
                }
            }
            if(!listServiceItemToAmend.isEmpty()){
                listServiceItemToAmend = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(listServiceItemToAmend, false);
                if(!listServiceItemToAmend.isEmpty())  {
                    listServiceItemToAmendNew.addAll(listServiceItemToAmend);
                    listServiceItemToAmend.clear();
                    upsert listServiceItemToAmendNew;
                }    
            }
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : If the Adjust Subsequent Occupancy flag is set to false in the wizard properties
	**********************************************************************************************/    
    public static void updateOwnerServiceItemsMoveOutDate() {
        
        Map<Integer,ServiceItem__c> mapUniqueKey2AmendedServiceItem = new Map<Integer,ServiceItem__c>();
        Map<Integer,ServiceItem__c> mapUniqueKey2NewServiceItem = new Map<Integer,ServiceItem__c>();
        List<ServiceItem__c> listServiceItemToAmend = new List<ServiceItem__c>();
        List<ServiceItem__c> listServiceItemsToInsert = new List<ServiceItem__c>();
        Integer uniqueCount = 0;
        Map<Integer,Id> mapUniqueKey2NewServiceItemNew = new Map<Integer,Id>();
        List<ServiceItem__c> listServiceItemToAmendNew = new List<ServiceItem__c>();
        
        serviceItemListOnLocation = getListOfServiceItems();
        for(ServiceItem__c objSI :serviceItemListOnLocation){

            uniqueCount += 1;            
            if(objSI.StartDate__c < originalMoveOutDate && 
               objSI.EndDate__c != null && objSI.EndDate__c >= originalMoveOutDate && 
               (objSI.Service__r.OccupancyType__c == Label.CuAp_AUMoveInOccTypeLandlord || objSI.Service__r.OccupancyType__c == Label.CuAp_AUMoveInOccTypeOwner)){
                   //Service Item is checked for Owner and Tenant Occupancy
                   if(objSI.ServiceItemType__r.Owner__c && objSI.ServiceItemType__r.Tenant__c){
                       
                       ServiceItem__c objNewSI = new ServiceItem__c();
                       objNewSI = createServiceItemObject(objSI,newMoveOutDate.addDays(1),Label.CuAp_AmendMoveStartDateChange);
                       if(!mapUniqueKey2NewServiceItem.containsKey(uniqueCount)){
                           mapUniqueKey2NewServiceItem.put(uniqueCount,objNewSI);
                       }
                       
                       if(objSI.StartDate__c == originalMoveOutDate.addDays(1)){
                           if(!mapUniqueKey2AmendedServiceItem.containsKey(uniqueCount)){
                               mapUniqueKey2AmendedServiceItem.put(uniqueCount,objSI);
                           }
                       }
                       amendedContracts.add(objSI.Service__r.BillingContract__c);
                   }
               }
        }
        if(mapUniqueKey2NewServiceItem.keyset().size() > 0){
            listServiceItemsToInsert = mapUniqueKey2NewServiceItem.values();
            listServiceItemsToInsert = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(listServiceItemsToInsert, false);
            if(!listServiceItemsToInsert.isEmpty())   {
                insert listServiceItemsToInsert;
                
                Integer i = 0;
                for(ServiceItem__c objSI : listServiceItemsToInsert){
                    i = i + 1;
                    mapUniqueKey2NewServiceItemNew.put(i,objSI.Id);
                }
                if(mapUniqueKey2AmendedServiceItem.keyset().size() > 0){
                    for(Integer objAmendSI : mapUniqueKey2AmendedServiceItem.keyset()){
                        if(mapUniqueKey2NewServiceItemNew.containsKey(objAmendSI)){
                            ServiceItem__c objServiceItemAmend = mapUniqueKey2AmendedServiceItem.get(objAmendSI);
                            objServiceItemAmend.AmendedByServiceItem__c = mapUniqueKey2NewServiceItemNew.get(objAmendSI);
                            listServiceItemToAmend.add(objServiceItemAmend);
                        }
                    }
                }
            }
        }
        if(!listServiceItemToAmend.isEmpty()){
            listServiceItemToAmend = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(listServiceItemToAmend, false);
            if(!listServiceItemToAmend.isEmpty()) {
                listServiceItemToAmendNew.addAll(listServiceItemToAmend);
                listServiceItemToAmend.clear();
                upsert listServiceItemToAmendNew;
            } 
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to get device Id's on location
    **********************************************************************************************/    
    public static void getDevicesOnLocation() {
        
        List<SupplyPoint__c> supplyPointList = new List<SupplyPoint__c>();
        List<SupplyPointDevice__c> supplyPointDeviceList = new List<SupplyPointDevice__c>();
        Set<Id> supplyPointIds = new Set<Id>();
        
        supplyPointList = (List<SupplyPoint__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,
                                                                                     supplyPointFields, 
                                                                                     'WHERE ' + GlUt_APIConstantsSupplyPoint.LOCATIONAPINAME + ' = ' + '\'' + locationId + '\'');
        
        if(!supplyPointList.isEmpty()){
            for(SupplyPoint__c objSP : supplyPointList){
                supplyPointIds.add(objSP.Id);
            }
        }
        
        if(supplyPointIds.size() > 0){
            
            String filterStatement;
            filterStatement = ' WHERE ' + GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME + ' IN ' + GlUt_FieldSecurity.IdsToString(supplyPointIds);
            filterStatement = filterStatement + ' AND ' + GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME + ' = true';
            
            supplyPointDeviceList = (List<SupplyPointDevice__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME,
                                                                                 supplyPointDeviceFields, 
                                                                                 filterStatement);
            
            if(!supplyPointDeviceList.isEmpty()){
                for(SupplyPointDevice__c objSPD :supplyPointDeviceList){
                    if(objSPD.Device__c != null){
                        setDeviceIds.add(objSPD.Device__c);
                    }
                }
            }
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to get current selected location occupant record
    **********************************************************************************************/    
    public static void getCurrentLocationOccupant() {
        
        List<LocationOccupant__c> listLocOccRecords = new List<LocationOccupant__c>();
        
        listLocOccRecords = (List<LocationOccupant__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME,
                                                                                            locOccFields, 
                                                                                            'WHERE Id  = ' + '\'' + locationOccupantId + '\'');
        
        if(!listLocOccRecords.isEmpty()){
            currentLocOccRecord = listLocOccRecords[0];
            originalMoveInDate = currentLocOccRecord.StartDate__c;
            originalMoveOutDate = currentLocOccRecord.EndDate__c;
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to get all location occupant records on location
    **********************************************************************************************/    
    public static void getLocationOccRecordsOnLocation() {
        
        String filterStatement = 'WHERE ' + GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTLOCATION + ' = ' + '\'' + locationId + '\'';
        filterStatement = filterStatement + ' AND ' + GlUt_APIConstantsLocationOccupant.PRIMARY + ' = true ORDER BY ' + GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATE + ' DESC ';  
            
        listAllLocOccOnLocation = (List<LocationOccupant__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME,
                                                                                                  locOccFields, 
                                                                                                  filterStatement);
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to get device Id's based on the readings from wizard
    **********************************************************************************************/    
    public static void getDeviceIds() {
        if(listReadingFromWizard != null && !listReadingFromWizard.isEmpty()){
            for(Reading__c objRead : listReadingFromWizard){
                setDeviceIds.add(objRead.Device__c);
            }
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to Get move In readin for reference
    **********************************************************************************************/    
    public static void getAllDevicesMoveInOutReadings() {
        
        if(setDeviceIds.size() > 0){
            
            String filterStatement;
            Date moveInOrOutDate = originalMoveInDate;
            String dateInString = String.valueOf(moveInOrOutDate);
            List<String> dateInList = dateInString.split(' ');
            DateTime dt1 = Date.valueOf(dateInList[0]);
            
            filterStatement = ' WHERE ' + GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME + ' IN ' + GlUt_FieldSecurity.IdsToString(setDeviceIds);
            filterStatement = filterStatement + ' AND ' + GlUt_APIConstantsReading.READINGTYPEAPINAME + ' = ' + '\'' + Label.CuAp_ReadingReadingTypeMoveIn + '\'';
            filterStatement = filterStatement + ' AND ' + GlUt_APIConstantsReading.READINGDATEAPINAME + ' <=  ' + dt1.format('yyyy-MM-dd')  + ' ORDER BY ' + GlUt_APIConstantsReading.READINGDATEAPINAME + ' DESC LIMIT 1';
            
            listMoveInOutReadingOnDevice = (List<Reading__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME,
                                                                                                  readingFields, 
                                                                                                  filterStatement);
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to get list of all SI linked to Location
    **********************************************************************************************/    
    public static List<ServiceItem__c> getListOfServiceItems() {
        
        List<SupplyPoint__c> supplyPointList = new List<SupplyPoint__c>();
        List<Service__c> serviceList = new List<Service__c>();
        List<ServiceItem__c> serviceItemList = new List<ServiceItem__c>();
        Set<Id> supplyPointIds = new Set<Id>();
        Set<Id> serviceIds = new Set<Id>();    
        
        Map<Id,Id> mapServiceId2ContractId = new Map<Id,Id>();
        
        
        supplyPointList = (List<SupplyPoint__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,
                                                                                     supplyPointFields, 
                                                                                     'WHERE ' + GlUt_APIConstantsSupplyPoint.LOCATIONAPINAME + ' = ' + '\'' + locationId + '\'');
        
        if(!supplyPointList.isEmpty()){
            for(SupplyPoint__c objSP : supplyPointList){
                supplyPointIds.add(objSP.Id);
            }
        }
        
        if(supplyPointIds.size() > 0){
            
            String filter = 'WHERE ' + GlUt_APIConstantsService.SUPPLYPOINTAPINAME + ' IN ' + GlUt_FieldSecurity.IdsToString(supplyPointIds);
            //filter += ' AND ' + GlUt_APIConstantsService.OCCUPANCYTYPEAPINAME + ' = ' + '\'' + Label.CuAp_AUMoveInOccType + '\''; // Only Tenant service
            
            serviceList = (List<Service__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsService.SERVICEAPINAME,
                                                                                 serviceFields, 
                                                                                 filter);
            
            if(!serviceList.isEmpty()){
                for(Service__c objService : serviceList){
                    serviceIds.add(objService.Id);
                    
                    if(!mapServiceId2ContractId.containsKey(objService.Id)){
                        mapServiceId2ContractId.put(objService.Id, objService.BillingContract__c);
                    }
                }
            }
            
            if(serviceIds.size() > 0){
                String filterStatement;  
                String blank = '';
                
                filterStatement = 'WHERE ' + GlUt_APIConstantsServiceItem.SERVICEAPINAME + ' IN ' + GlUt_FieldSecurity.IdsToString(serviceIds);
                filterStatement = filterStatement + ' AND ' + GlUt_APIConstantsServiceItem.AMENDEDBYSERVICEITEMAPINAME + ' = ' + '\'' + blank + '\'';
                //filterStatement += ' AND ' + GlUt_APIConstantsServiceItem.STARTDATEAPINAME + ' = ' + dt1.format('yyyy-MM-dd');
                
                serviceItemList = (List<ServiceItem__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME,
                                                                                             serviceItemFields, 
                                                                                             filterStatement);
                
                for(ServiceItem__c objServiceItem :serviceItemList){
                    
                    if(!mapServiceItemId2ContractId.containsKey(objServiceItem.Id)){
                        mapServiceItemId2ContractId.put(objServiceItem.Id,mapServiceId2ContractId.get(objServiceItem.Service__c));
                    }
                    
                }
            }
        }
        
        return serviceItemList;
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to Get All void and move readings on all devices on the Location 
    **********************************************************************************************/    
    public static void getVoidAndMoveInReadingsOnDevice() {
        
        if(setDeviceIds.size() > 0){
            
            String filterStatement;
            
            filterStatement = ' WHERE ' + GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME + ' IN ' + GlUt_FieldSecurity.IdsToString(setDeviceIds);
            filterStatement = filterStatement + ' AND ' + ' ( ' + GlUt_APIConstantsReading.READINGTYPEAPINAME + ' = ' + '\'' + Label.CuAp_ReadingReadingTypeVoidStart + '\'';
            filterStatement = filterStatement + ' OR ' + GlUt_APIConstantsReading.READINGTYPEAPINAME + ' = ' + '\'' + Label.CuAp_ReadingReadingTypeVoidEnd + '\'' ;
            filterStatement = filterStatement + ' OR ' + GlUt_APIConstantsReading.READINGTYPEAPINAME + ' = ' + '\'' + Label.CuAp_ReadingReadingTypeMoveIn + '\'' ;
            filterStatement = filterStatement + ' OR ' + GlUt_APIConstantsReading.READINGTYPEAPINAME + ' = ' + '\'' + Label.CuAp_ReadingReadingTypeMoveOut + '\'' + ' ) ';
            filterStatement = filterStatement + ' AND ' + GlUt_APIConstantsReading.BILLABLETYPEAPINAME + ' != ' + '\'' + Label.CuAp_ReadingBillableTypeInvalid + '\'' ;
            
            listVoidAndMoveReadingsOnDevice = (List<Reading__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME,
                                                                                                  readingFields, 
                                                                                                  filterStatement);
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to delete period of occupancy, Req. 
    **********************************************************************************************/    
    public static void deleteLocationOccupantsRecords() {
        
        //Any location occupant records where the start date is more than or equal to the start date of the period of occupancy being deleted 
        //and the location occupant end date is less than or equal to the date of the period of occupancy that is being deleted  
        
        List<LocationOccupant__c> listLocOcc = new List<LocationOccupant__c>();
        if(!listAllLocOccOnLocation.isEmpty() && currentLocOccRecord!= null){
            
            for(LocationOccupant__c objListLoccToDelete :listAllLocOccOnLocation){
                //Tenant
                if(objListLoccToDelete.OccupancyType__c == Label.CuAp_AUMoveInOccType && 
                   (objListLoccToDelete.StartDate__c == originalMoveInDate ||
                    (originalMoveOutDate != null && objListLoccToDelete.StartDate__c >= originalMoveInDate && objListLoccToDelete.EndDate__c <= originalMoveOutDate))){
                        listLocOcc.add(objListLoccToDelete);
                    }
            }
        }
        
        if(listLocOcc != null && !listLocOcc.isEmpty()){
            
            updateBillingAddress();
            
            delete listLocOcc;
            
            // Delete Service Items if location occupant is deleted
            deleteServiceItemsLogicNew();
            
            // Invalidate Move In Out readings for this period
            invalidateMoveReadingsInDeleteCase();
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to Update ServiceItems in case Occupancy is deleted
    **********************************************************************************************/    
    public static void deleteServiceItemsLogicNew() {
        
        List<ServiceItem__c> listServiceItemsToEnd = new List<ServiceItem__c>();
        
        Id ownerContractId ;
        Set<Id> setServiceIds = new Set<Id>();
        
        //serviceItemListOnLocation
        for(ServiceItem__c objSIToUpdate :serviceItemListOnLocation){
            
            if(objSIToUpdate.StartDate__c == originalMoveInDate && objSIToUpdate.Service__r.OccupancyType__c == 'Tenant'){
                //Make it Inalid
                objSIToUpdate.Invalid__c = true;
                listServiceItemsToEnd.add(objSIToUpdate);
            }
        }
        
        if(!listServiceItemsToEnd.isEmpty()){
            
            for(ServiceItem__c objContract :listServiceItemsToEnd){
                if(objContract.Service__c != null && objContract.Service__r.BillingContract__c != null){
                    amendedContracts.add(objContract.Service__r.BillingContract__c);
                }
            }
            listServiceItemsToEnd = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(listServiceItemsToEnd, false);
            if(!listServiceItemsToEnd.isEmpty())                					
                update listServiceItemsToEnd;
        }   
        
        Id ownerAccountId;
        //Create new service Item against owner contract
        for(LocationOccupant__c objListLoccOccOwner :listAllLocOccOnLocation){
            // Earlier owner and now landlord after tenant
            if(objListLoccOccOwner.OccupancyType__c == 'Landlord'){
                ownerAccountId = objListLoccOccOwner.Account__c;
                break;
            }
        }        
        
        if(ownerAccountId != null){
            
            BillingContract__c objBillingContract = [SELECT Id,Name
                                                    FROM BillingContract__c
                                                    WHERE AccountName__c =: ownerAccountId 
                                                     AND Status__c = 'Active' LIMIT 1];
            
            if(objBillingContract != null){
                ownerContractId = objBillingContract.Id;
                List<Service__c> listOwnerServices = [SELECT Id,Name
                                                     FROM Service__c
                                                     WHERE BillingContract__c =: ownerContractId ];
                
                if(listOwnerServices != null && !listOwnerServices.isEmpty()){
                    for(Service__c objService : listOwnerServices){
                        setServiceIds.add(objService.Id);
                    }
                }
            }
        }
        
        List<ServiceItem__c> listServItemToCreate = new List<ServiceItem__c>();
        
        if(setServiceIds.size() > 0){
            //Create new servic item for all owner services
            for(Id objServId : setServiceIds){
                
                for(ServiceItem__c objSIToUpdate :serviceItemListOnLocation){
                    
                    //Looking for valid service items
                    if(objSIToUpdate.ServiceItemType__r.Owner__c && 
                       objSIToUpdate.ServiceItemType__r.Tenant__c && 
                       objSIToUpdate.StartDate__c >= originalMoveInDate &&
                       (objSIToUpdate != null && objSIToUpdate.EndDate__c <= originalMoveOutDate)
                      ){
                          //Create new service items under owner service
                          ServiceItem__c objNewSI = new ServiceItem__c();
                          objNewSI.ServiceItemType__c = objSIToUpdate.ServiceItemType__c;
                          objNewSI.AvailableServiceItem__c = objSIToUpdate.AvailableServiceItem__c;
                          objNewSI.DischargeAgreement__c = objSIToUpdate.DischargeAgreement__c;
                          objNewSI.StartDate__c = originalMoveInDate;
                          objNewSI.EndDate__c = originalMoveOutDate;
                          objNewSI.Service__c = objServId;
                          objNewSI.Quantity__c = objSIToUpdate.Quantity__c;
                          
                          listServItemToCreate.add(objNewSI);
                      }
                }
            }
        }
        
        if(!listServItemToCreate.isEmpty()){
            listServItemToCreate = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(listServItemToCreate, false);
            if(!listServItemToCreate.isEmpty())                					
                insert listServItemToCreate;
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to Update Billing Address in case Occupancy is deleted
    **********************************************************************************************/    
    public static void updateBillingAddress() {
        
        if (newBillingAddress != null) {
            
            // contract billing address
            newBillingAddress = (BillingContract__c) GlUt_FieldSecurity.cleanseFields(newBillingAddress, false);
            update newBillingAddress;
            
            List<Account> accountList = new List<Account>();
            List<Account> accountListNew = new List<Account>();
            
            accountList = (List<Account>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAccount.ACCOUNTAPINAME,
                                                                              accountFields, 
                                                                              'WHERE Id = ' + '\'' + accountId + '\'');
            // account billing address
            for (Account account : accountList) {
                
                account.BillingStreet = newBillingAddress.BillingStreet__c; 
                account.BillingCity = newBillingAddress.BillingCity__c;
                account.BillingState = newBillingAddress.BillingState__c;
                account.BillingPostalCode = newBillingAddress.BillingPostalCode__c;
                account.BillingCountry = newBillingAddress.BillingCountry__c;
                account = (Account) GlUt_FieldSecurity.cleanseFields(account, false);
                accountListNew.add(account);
            }
            if(!accountListNew.isEmpty()){
                update accountListNew;
            }
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to invalidate move readings in case Occupancy is deleted
    **********************************************************************************************/    
    public static void invalidateMoveReadingsInDeleteCase() {
        
        List<Reading__c> listMoveReadingsToInvalidateInDelete = new List<Reading__c>();
        List<Reading__c> listAllServiceBilledReadings = new List<Reading__c>();
        
        for(Reading__c objInvalidateReading :listVoidAndMoveReadingsOnDevice){
            
            //Invalidate this Move In Reading
            if(objInvalidateReading.ReadingType__c == Label.CuAp_ReadingReadingTypeMoveIn && objInvalidateReading.ReadingDate__c == originalMoveInDate){
                objInvalidateReading.BillableType__c = Label.CuAp_ReadingBillableTypeInvalid;
                listMoveReadingsToInvalidateInDelete.add(objInvalidateReading);
            }
            
            //Invalidate this Move Out Reading
            if(originalMoveOutDate != null && objInvalidateReading.ReadingType__c == Label.CuAp_ReadingReadingTypeMoveOut && objInvalidateReading.ReadingDate__c == originalMoveOutDate){
                objInvalidateReading.BillableType__c = Label.CuAp_ReadingBillableTypeInvalid;
                listMoveReadingsToInvalidateInDelete.add(objInvalidateReading);
            }
        }
        
        List<Reading__c> listAllReadings = [SELECT Id,Name,AllServicesBilled__c
                                            FROM Reading__c
                                            WHERE Device__c IN : setDeviceIds
                                            AND BillableType__c != :Label.CuAp_ReadingBillableTypeInvalid
                                            AND ReadingDate__c >= : originalMoveInDate 
                                            AND ReadingDate__c <= : originalMoveOutDate];
        
        if(listAllReadings != null && !listAllReadings.isEmpty()){
            for(Reading__c objReading : listAllReadings){
                objReading.AllServicesBilled__c = false;
                listAllServiceBilledReadings.add(objReading);
            }
        }
        
        if(!listAllServiceBilledReadings.isEmpty()){
            listAllServiceBilledReadings = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(listAllServiceBilledReadings, false);
            if(!listAllServiceBilledReadings.isEmpty())                					
                update listAllServiceBilledReadings;
        }
        
        if(!listMoveReadingsToInvalidateInDelete.isEmpty()){
            listMoveReadingsToInvalidateInDelete = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(listMoveReadingsToInvalidateInDelete, false);
            if(!listMoveReadingsToInvalidateInDelete.isEmpty())
                update listMoveReadingsToInvalidateInDelete;
        }
        
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to invalidate old move in date reading
	**********************************************************************************************/    
    public static void invalidateOldMoveInOrOutReadings() {
        
        List<Reading__c> listReadingToInvalidate = new List<Reading__c>();
        
        for(Reading__c objReadingInvalid : listVoidAndMoveReadingsOnDevice){
            
            if(objReadingInvalid.ReadingType__c == moveInOrMoveOut 
               && objReadingInvalid.ReadingDate__c == (moveInOrMoveOut == Label.CuAp_ReadingReadingTypeMoveIn ? originalMoveInDate : originalMoveOutDate)){
                   
                   objReadingInvalid.BillableType__c = Label.CuAp_ReadingBillableTypeInvalid;
                   listReadingToInvalidate.add(objReadingInvalid);
               }
        }
        
        if(!listReadingToInvalidate.isEmpty()){       
            listReadingToInvalidate = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(listReadingToInvalidate, false);
            if(!listReadingToInvalidate.isEmpty())
                update listReadingToInvalidate;
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is for new move in readings to Insert
    **********************************************************************************************/    
    public static void insertNewReadingsFromWizard() {
        
        List<Reading__c> listReadingToInsert = new List<Reading__c>();
        
        for(Reading__c objRead : listReadingFromWizard){            
            Reading__c objNewReading = new Reading__c();
            objNewReading.ActualDeviceReading__c = objRead.ActualDeviceReading__c;
            objNewReading.ReadingDate__c = moveInOrMoveOut == Label.CuAp_ReadingReadingTypeMoveIn ? newMoveInDate : newMoveOutDate;
            objNewReading.ReadingMethod__c = objRead.ReadingMethod__c;
            objNewReading.ReadingType__c = moveInOrMoveOut;
            objNewReading.Device__c = objRead.Device__c;
            
            if(!mapDeviceId2ReadingObject.containsKey(objNewReading.Device__c)){
                mapDeviceId2ReadingObject.put(objNewReading.Device__c, objNewReading);
            }
            listReadingToInsert.add(objNewReading);
        }
        
        if(!listReadingToInsert.isEmpty()){
            listReadingToInsert = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(listReadingToInsert, false);
            if(!listReadingToInsert.isEmpty())  
                insert listReadingToInsert;
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to create and update move readings
    **********************************************************************************************/    
    public static void createAndInvalidateMoveReadings(Map<Date,Date> mapOldStartDateToNewStartDate, Map<Date,Date> mapOldEndDateToNewEndDate) {
        
        List<Reading__c> listNewMoveReadings = new List<Reading__c>();
        List<Reading__c> listNewMoveReadingsNew = new List<Reading__c>();
        
        String actualReading;
        String readingMethod;
        
        for(Reading__c objMoveReadings :listVoidAndMoveReadingsOnDevice){
            
            if(moveInOrMoveOut == Label.CuAp_ReadingReadingTypeMoveIn 
               && objMoveReadings.ReadingType__c == Label.CuAp_ReadingReadingTypeMoveOut
               && mapOldEndDateToNewEndDate.containsKey(objMoveReadings.ReadingDate__c)){
                   actualReading = objMoveReadings.ActualDeviceReading__c;
                   readingMethod =   objMoveReadings.ReadingMethod__c;
               }
            
            if(moveInOrMoveOut == Label.CuAp_ReadingReadingTypeMoveOut 
               && objMoveReadings.ReadingType__c == Label.CuAp_ReadingReadingTypeMoveIn
               && mapOldStartDateToNewStartDate.containsKey(objMoveReadings.ReadingDate__c)){
                   actualReading = objMoveReadings.ActualDeviceReading__c;
                   readingMethod =   objMoveReadings.ReadingMethod__c;
               }
        }
        
        if(actualReading != null && readingMethod != null){
            
            for(Reading__c objMoveReadings :listVoidAndMoveReadingsOnDevice){
                if(objMoveReadings.ReadingType__c == Label.CuAp_ReadingReadingTypeMoveIn || objMoveReadings.ReadingType__c == Label.CuAp_ReadingReadingTypeMoveOut){
                    
                    if(moveInOrMoveOut == Label.CuAp_ReadingReadingTypeMoveIn){
                        // It means if move in changed and it results in change of move out date of other occupant, then invalidate this move out date and create new move out
                        if(mapOldEndDateToNewEndDate.containsKey(objMoveReadings.ReadingDate__c) && objMoveReadings.ReadingType__c == Label.CuAp_ReadingReadingTypeMoveOut){
                            
                            // Create New Move out with date - mapOldEndDateToNewEndDate.get(objMoveReadings.ReadingDate__c)
                            for(Id objDeviceId : setDeviceIds){
                                
                                Reading__c objReading = new Reading__c();
                                objReading.Device__c =  objDeviceId;
                                objReading.ReadingDate__c = mapOldEndDateToNewEndDate.get(objMoveReadings.ReadingDate__c);
                                objReading.ActualDeviceReading__c = actualReading;
                                objReading.ReadingMethod__c = readingMethod;
                                objReading.ReadingType__c = Label.CuAp_ReadingReadingTypeMoveOut;
                                objReading.Billed__c = false;
                                
                                listNewMoveReadings.add(objReading);
                            }
                            // Invalidate objMoveReadings
                            objMoveReadings.BillableType__c = Label.CuAp_ReadingBillableTypeInvalid;
                            listNewMoveReadings.add(objMoveReadings);
                        }
                    }
                    else if(moveInOrMoveOut == Label.CuAp_ReadingReadingTypeMoveOut){
                        
                        // It means if move out changed and it results in change of move In date of other occupant, then invalidate this move In date and create new move In
                        if(mapOldStartDateToNewStartDate.containsKey(objMoveReadings.ReadingDate__c) && objMoveReadings.ReadingType__c == Label.CuAp_ReadingReadingTypeMoveIn){
                            
                            // Create New Move out with date - mapOldEndDateToNewEndDate.get(objMoveReadings.ReadingDate__c)
                            for(Id objDeviceId : setDeviceIds){
                                
                                Reading__c objReading = new Reading__c();
                                objReading.Device__c =  objDeviceId;
                                objReading.ReadingDate__c = mapOldStartDateToNewStartDate.get(objMoveReadings.ReadingDate__c);
                                objReading.ActualDeviceReading__c = actualReading;
                                objReading.ReadingMethod__c = readingMethod;
                                objReading.ReadingType__c = Label.CuAp_ReadingReadingTypeMoveIn;
                                objReading.Billed__c = false;
                                
                                listNewMoveReadings.add(objReading);
                            }
                            // Invalidate objMoveReadings
                            objMoveReadings.BillableType__c = Label.CuAp_ReadingBillableTypeInvalid;
                            listNewMoveReadings.add(objMoveReadings);
                        }
                    }
                }
            }
        }
        
        if(!listNewMoveReadings.isEmpty()){
            listNewMoveReadings = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(listNewMoveReadings, false);
            if(!listNewMoveReadings.isEmpty())      {
                listNewMoveReadingsNew.addAll(listNewMoveReadings);
                listNewMoveReadings.clear();
                upsert listNewMoveReadingsNew;
            }   
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to create Service Item Object
    **********************************************************************************************/    
    public static ServiceItem__c createServiceItemObject(ServiceItem__c objupdatedServiceItem, Date dateNewMoveInOrOut, String startOrEndDate ) {
        
        ServiceItem__c objNewSI = new ServiceItem__c();
        objNewSI.ServiceItemType__c = objupdatedServiceItem.ServiceItemType__c;
        objNewSI.AvailableServiceItem__c = objupdatedServiceItem.AvailableServiceItem__c;
        objNewSI.DischargeAgreement__c = objupdatedServiceItem.DischargeAgreement__c;
        objNewSI.StartDate__c = startOrEndDate == Label.CuAp_AmendMoveStartDateChange ? dateNewMoveInOrOut : objupdatedServiceItem.StartDate__c;
        objNewSI.EndDate__c = startOrEndDate == Label.CuAp_AmendMoveEndDateChange  ? dateNewMoveInOrOut : objupdatedServiceItem.EndDate__c;
        objNewSI.Service__c = objupdatedServiceItem.Service__c;
        objNewSI.Quantity__c = objupdatedServiceItem.Quantity__c;
        
        return objNewSI;
    }
}