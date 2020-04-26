/******************************************************************************
@author         Tarun Gupta 
@date           17 Sep 2018
@description    Utility class for Customer Move Amendment  
@Revisions		Tarun Gupta, AT-3904 Updates the Ended__c checkbox as true for all the Service Items where End date is modified
				Tarun Gupta, AT-3936 create void readings in case there is only one location occupant on location
*******************************************************************************/
public with sharing class GlUt_CustMoveAmendUtility {    
    
    private static Map<Id,Reading__c> mapDeviceId2ReadingObject = new Map<Id,Reading__c>();
    private static LocationOccupant__c currentLocOccRecord = new LocationOccupant__c(); 
    private static List<Reading__c> listReadingFromWizard = new List<Reading__c>();
    private static List<Reading__c> listMoveInOutReadingOnDevice = new List<Reading__c>();
    private static List<ServiceItem__c> serviceItemListOnLocation = new List<ServiceItem__c>();
    private static  List<LocationOccupant__c> listAllLocOccOnLocation = new List<LocationOccupant__c>();
    private static Map<Id,LocationOccupant__c> mapAllLocOccOnLocation = new Map<Id,LocationOccupant__c>();
    private static List<Reading__c> listVoidAndMoveReadingsOnDevice = new List<Reading__c>();
    private static BillingContract__c newBillingAddress = new BillingContract__c();
    private static  Map<Id,Id> mapServiceItemId2ContractId = new Map<Id,Id>();
    
    private static Set<Id> setDeviceIds = new Set<Id>();
    private static Set<Id> setContractIds = new Set<Id>();
    private static Date newMoveInDate;
    private static Date newMoveOutDate;
    
    private static Id locationOccupantId;
    private static Id locationId;
    private static Id accountId;
    private static String deleteRecord; 
    private static String moveInOrMoveOut;
    
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
            GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATE    
            };
                
  	private static final List<String> supplyPointFields = new List<string>{
        	GlUt_APIConstantsSupplyPoint.LOCATIONAPINAME
            }; 
                
	private static final List<String> serviceFields = new List<string>{
        	GlUt_APIConstantsService.SERVICESTARTDATEAPINAME,
            GlUt_APIConstantsService.SERVICEENDDATEAPINAME,
            GlUt_APIConstantsService.SERVICECONTRACTAPINAME   
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
                GlUt_APIConstantsServiceItem.SUPPLYPOINTAPINAME,
                GlUt_APIConstantsServiceItem.AMENDEDBYSERVICEITEMAPINAME,
                GlUt_APIConstantsServiceItem.SERVICECONTRACTREFAPINAME,
                GlUt_APIConstantsServiceItem.AVAILABLESERVICEITEMAPINAME,
                GlUt_APIConstantsServiceItem.DISCHARGEAGREEMENTAPINAME,
                GlUt_APIConstantsServiceItem.QUANTITYAPINAME,
                GlUt_APIConstantsServiceItem.ENDEDAPINAME
            };   
                
	/**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is for getting preRequisite
    **********************************************************************************************/    
    public static Set<Id> preRequisite(Id accountIdFromWiz, Id locationOccupantIdFromWiz, Id locationIdFromWiz, List<Reading__c> listWizardReadingFromWiz, String deleteRecordFromWiz, Date moveInDateFromWiz, Date moveOutDateFromWiz, BillingContract__c newBillingAddressFromWiz) {
        
        //Assign Generic Values
        assignGenericValues(accountIdFromWiz, locationOccupantIdFromWiz,locationIdFromWiz,deleteRecordFromWiz,moveInDateFromWiz,moveOutDateFromWiz,listWizardReadingFromWiz,newBillingAddressFromWiz);
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
        amendOrDeleteLocOccRecord();
        
        return setContractIds;
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to assign generic values to global variables
    **********************************************************************************************/    
    public static void assignGenericValues(Id accountIdFromWiz, Id locationOccupantIdFromWiz, Id locationIdFromWiz, String deleteRecordFromWiz, Date moveInDateFromWiz, Date moveOutDateFromWiz, List<Reading__c> listWizardReading, BillingContract__c newBillingAddressFromWiz) {
        
        locationOccupantId = locationOccupantIdFromWiz;
        locationId = locationIdFromWiz;
        deleteRecord = deleteRecordFromWiz;
        newMoveInDate = moveInDateFromWiz;
        newMoveOutDate = moveOutDateFromWiz;
        listReadingFromWizard = listWizardReading;
        newBillingAddress = newBillingAddressFromWiz;
        accountId = accountIdFromWiz;
        
        if(newMoveInDate != null)
            moveInOrMoveOut = Label.CuAp_ReadingReadingTypeMoveIn; //Move In Type
        else if(newMoveOutDate != null)
            moveInOrMoveOut = Label.CuAp_ReadingReadingTypeMoveOut; //Move Out Type
        
        system.debug('600....moveInOrMoveOut ' + moveInOrMoveOut);
        
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
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to get all location occupant records on location
    **********************************************************************************************/    
    public static void getLocationOccRecordsOnLocation() {
        
        String filterStatement = 'WHERE ' + GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTLOCATION + ' = ' + '\'' + locationId + '\'';
        filterStatement = filterStatement + ' AND ' + GlUt_APIConstantsLocationOccupant.PRIMARY + ' = true ORDER BY ' + GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTSTARTDATE;  
            
        listAllLocOccOnLocation = (List<LocationOccupant__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME,
                                                                                                  locOccFields, 
                                                                                                  filterStatement);        
        
        for(LocationOccupant__c objLocationOcc : listAllLocOccOnLocation){
            
            if(!mapAllLocOccOnLocation.containsKey(objLocationOcc.Id)){
                mapAllLocOccOnLocation.put(objLocationOcc.Id, objLocationOcc);
            }
        }
        
        system.debug('602....mapAllLocOccOnLocation ' + mapAllLocOccOnLocation);
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
            Date moveInOrOutDate = currentLocOccRecord.StartDate__c;
            String dateInString = String.valueOf(moveInOrOutDate);
            List<String> dateInList = dateInString.split(' ');
            DateTime dt1 = Date.valueOf(dateInList[0]);
            system.debug('605A...dt1 ' + dt1);
            
            filterStatement = ' WHERE ' + GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME + ' IN ' + GlUt_FieldSecurity.IdsToString(setDeviceIds);
            filterStatement = filterStatement + ' AND ' + GlUt_APIConstantsReading.READINGTYPEAPINAME + ' = ' + '\'' + Label.CuAp_ReadingReadingTypeMoveIn + '\'';
            filterStatement = filterStatement + ' AND ' + GlUt_APIConstantsReading.READINGDATEAPINAME + ' <=  ' + dt1.format('yyyy-MM-dd')  + ' ORDER BY ' + GlUt_APIConstantsReading.READINGDATEAPINAME + ' DESC LIMIT 1';
            
            listMoveInOutReadingOnDevice = (List<Reading__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME,
                                                                                                  readingFields, 
                                                                                                  filterStatement);
            system.debug('605...listMoveInOutReadingOnDevice ' + listMoveInOutReadingOnDevice);
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
            
            serviceList = (List<Service__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsService.SERVICEAPINAME,
                                                                                 serviceFields, 
                                                                                 'WHERE ' + GlUt_APIConstantsService.SUPPLYPOINTAPINAME + ' IN ' + GlUt_FieldSecurity.IdsToString(supplyPointIds));
            
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
    @description : This method is for Cust Amend core logic
    **********************************************************************************************/    
    public static void amendOrDeleteLocOccRecord() {
        
        Savepoint sp = Database.setSavepoint();
        try{
            
            if(deleteRecord == 'false'){
                amendReadingAndLocOccAndSI();
            }
            else if(deleteRecord == 'true'){
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
    @description : This method is to delete period of occupancy, Req. 
    **********************************************************************************************/    
    public static void deleteLocationOccupantsRecords() {
        
        //Any location occupant records where the start date is more than or equal to the start date of the period of occupancy being deleted 
        //and the location occupant end date is less than or equal to the date of the period of occupancy that is being deleted  
        
        List<LocationOccupant__c> listLocOcc = new List<LocationOccupant__c>();
        
        if(!listAllLocOccOnLocation.isEmpty() && currentLocOccRecord!= null){
            
            for(LocationOccupant__c objListLoccToDelete :listAllLocOccOnLocation){
                
                if((currentLocOccRecord.EndDate__c != null && objListLoccToDelete.StartDate__c >= currentLocOccRecord.StartDate__c && objListLoccToDelete.EndDate__c <= currentLocOccRecord.EndDate__c) 
                   || objListLoccToDelete.StartDate__c == currentLocOccRecord.StartDate__c){
                    
                    listLocOcc.add(objListLoccToDelete);
                }
            }
        }
        
        if(listLocOcc != null && !listLocOcc.isEmpty()){
            
            updateBillingAddress();
            
            //create void period
            Id voidId = GlUt_ContractUtilities.createVoidContract(locationId, currentLocOccRecord.StartDate__c, null, currentLocOccRecord.StartDate__c);
            
            createVoidreadings(currentLocOccRecord.StartDate__c, Label.CuAp_ReadingReadingTypeVoidStart);
            if(currentLocOccRecord.EndDate__c != null)
            	createVoidreadings(currentLocOccRecord.EndDate__c.addDays(-1), Label.CuAp_ReadingReadingTypeVoidEnd);
            
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
        
        //serviceItemListOnLocation
        for(ServiceItem__c objSIToUpdate :serviceItemListOnLocation){
            
            if(objSIToUpdate.StartDate__c == currentLocOccRecord.StartDate__c){
                //Make it Inalid
                objSIToUpdate.Invalid__c = true;
                listServiceItemsToEnd.add(objSIToUpdate);
            }
        }
        
        if(!listServiceItemsToEnd.isEmpty()){
            
            for(ServiceItem__c objContract :listServiceItemsToEnd){
                if(objContract.Service__c != null && objContract.Service__r.BillingContract__c != null){
                    setContractIds.add(objContract.Service__r.BillingContract__c);
                }
            }
            listServiceItemsToEnd = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(listServiceItemsToEnd, false);
            update listServiceItemsToEnd;
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
            
            accountList = (List<Account>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAccount.ACCOUNTAPINAME,
                                                                              accountFields, 
                                                                              'WHERE Id = ' + '\'' + accountId + '\'');
            List<Account> updatedAccountList = new List<Account>();   // AT-4373
            // account billing address
            for (Account account : accountList) {
                
                account.BillingStreet = newBillingAddress.BillingStreet__c; 
                account.BillingCity = newBillingAddress.BillingCity__c;
                account.BillingState = newBillingAddress.BillingState__c;
                account.BillingPostalCode = newBillingAddress.BillingPostalCode__c;
                account.BillingCountry = newBillingAddress.BillingCountry__c;
                account = (Account) GlUt_FieldSecurity.cleanseFields(account, false);
                updatedAccountList.add(account);  // AT-4373
            }
            if(!updatedAccountList.isEmpty()){
                updatedAccountList = (List<Account>) GlUt_FieldSecurity.cleanseFields(updatedAccountList, false);
                database.update(updatedAccountList);
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
        
        for(Reading__c objInvalidateReading :listVoidAndMoveReadingsOnDevice){
            
            //Invalidate this Move In Reading
            if(objInvalidateReading.ReadingType__c == Label.CuAp_ReadingReadingTypeMoveIn && objInvalidateReading.ReadingDate__c == currentLocOccRecord.StartDate__c){
                objInvalidateReading.BillableType__c = Label.CuAp_ReadingBillableTypeInvalid;
                listMoveReadingsToInvalidateInDelete.add(objInvalidateReading);
            }
            
            //Invalidate this Move Out Reading
            if(currentLocOccRecord.EndDate__c != null && objInvalidateReading.ReadingType__c == Label.CuAp_ReadingReadingTypeMoveOut && objInvalidateReading.ReadingDate__c == currentLocOccRecord.EndDate__c){
                objInvalidateReading.BillableType__c = Label.CuAp_ReadingBillableTypeInvalid;
                listMoveReadingsToInvalidateInDelete.add(objInvalidateReading);
            }
        }
        
        if(!listMoveReadingsToInvalidateInDelete.isEmpty()){
            listMoveReadingsToInvalidateInDelete = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(listMoveReadingsToInvalidateInDelete, false);
            update listMoveReadingsToInvalidateInDelete;
        }
        
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is for Cust Amend core logic
    **********************************************************************************************/    
    public static void amendReadingAndLocOccAndSI() {
        
        // To Invalidate old Move In\Out reading
        invalidateOldMoveInOrOutReadings();
        
        // New Move In\Out reading to be created
        insertNewReadingsFromWizard();
        
        //Update Loc Occ Records
        updateLocOccNewLogic();
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
               && objReadingInvalid.ReadingDate__c == (moveInOrMoveOut == Label.CuAp_ReadingReadingTypeMoveIn ? currentLocOccRecord.StartDate__c : currentLocOccRecord.EndDate__c)){
                   
                   objReadingInvalid.BillableType__c = Label.CuAp_ReadingBillableTypeInvalid;
                   listReadingToInvalidate.add(objReadingInvalid);
               }
        }        
        if(!listReadingToInvalidate.isEmpty())  {
            listReadingToInvalidate = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(listReadingToInvalidate, false); 
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
            insert listReadingToInsert;
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to update Loc Occ records
    **********************************************************************************************/    
    public static void updateLocOccNewLogic() {
        Map<Id,LocationOccupant__c> mapId2LocOccRec = new Map<Id,LocationOccupant__c>();
        Map<Date,Date> mapOldStartDateToNewStartDate = new Map<Date,Date>();
        Map<Date,Date> mapOldEndDateToNewEndDate = new Map<Date,Date>();
        for(LocationOccupant__c objLocc : listAllLocOccOnLocation){
            if(moveInOrMoveOut == Label.CuAp_ReadingReadingTypeMoveIn){
                if(objLocc.StartDate__c < newMoveInDate && (/*objLocc.EndDate__c == null ||*/ objLocc.EndDate__c  != null && objLocc.EndDate__c > newMoveInDate)){
                    if(objLocc.Id == currentLocOccRecord.Id){
                        
                        if(!mapOldStartDateToNewStartDate.containsKey(objLocc.StartDate__c)){
                            mapOldStartDateToNewStartDate.put(objLocc.StartDate__c,newMoveInDate);
                        }
                        objLocc.StartDate__c = newMoveInDate;
                    }
                    if(objLocc.EndDate__c != null){
                        if(!mapOldEndDateToNewEndDate.containsKey(objLocc.EndDate__c)){
                            mapOldEndDateToNewEndDate.put(objLocc.EndDate__c,newMoveInDate.addDays(-1));
                        }
                        objLocc.EndDate__c = newMoveInDate.addDays(-1);
                    }
                    if(!mapId2LocOccRec.containsKey(objLocc.Id)){
                        mapId2LocOccRec.put(objLocc.Id,objLocc);
                    }
                }
                if(objLocc.Id == currentLocOccRecord.Id){
                    
                    if(!mapOldStartDateToNewStartDate.containsKey(objLocc.StartDate__c)){
                        mapOldStartDateToNewStartDate.put(objLocc.StartDate__c,newMoveInDate);
                    }
                    objLocc.StartDate__c = newMoveInDate;
                    if(!mapId2LocOccRec.containsKey(objLocc.Id)){
                        mapId2LocOccRec.put(objLocc.Id,objLocc);
                    }
                }
                if(objLocc.StartDate__c == currentLocOccRecord.StartDate__c){
                    if(!mapOldStartDateToNewStartDate.containsKey(objLocc.StartDate__c)){
                        mapOldStartDateToNewStartDate.put(objLocc.StartDate__c,newMoveInDate);
                    }
                    objLocc.StartDate__c = newMoveInDate;
                    if(!mapId2LocOccRec.containsKey(objLocc.Id)){
                        mapId2LocOccRec.put(objLocc.Id,objLocc);
                    }
                }
            }
            else if(moveInOrMoveOut == Label.CuAp_ReadingReadingTypeMoveOut){
                
                if(objLocc.EndDate__c == null && objLocc.StartDate__c <= newMoveOutDate /*&& objLocc.StartDate__c > currentLocOccRecord.StartDate__c && objLocc.StartDate__c < newMoveOutDate*/ ){
                    if(!mapOldStartDateToNewStartDate.containsKey(objLocc.StartDate__c)){
                        mapOldStartDateToNewStartDate.put(objLocc.StartDate__c,newMoveOutDate.addDays(1));
                    }
                    objLocc.StartDate__c = newMoveOutDate.addDays(1);
                    if(!mapId2LocOccRec.containsKey(objLocc.Id)){
                        mapId2LocOccRec.put(objLocc.Id,objLocc);
                    }
                }
                if(objLocc.Id == currentLocOccRecord.Id){
                    if(!mapOldEndDateToNewEndDate.containsKey(objLocc.EndDate__c)){
                        mapOldEndDateToNewEndDate.put(objLocc.EndDate__c,newMoveOutDate);
                    }
                    objLocc.EndDate__c = newMoveOutDate;
                    if(!mapId2LocOccRec.containsKey(objLocc.Id)){
                        mapId2LocOccRec.put(objLocc.Id,objLocc);
                    }
                }
                
                if(objLocc.EndDate__c == currentLocOccRecord.EndDate__c){
                    if(!mapOldEndDateToNewEndDate.containsKey(objLocc.EndDate__c)){
                        mapOldEndDateToNewEndDate.put(objLocc.EndDate__c,newMoveOutDate);
                    }
                    objLocc.EndDate__c = newMoveOutDate;
                    if(!mapId2LocOccRec.containsKey(objLocc.Id)){
                        mapId2LocOccRec.put(objLocc.Id,objLocc);
                    }
                }
                
                if(objLocc.EndDate__c != null && objLocc.EndDate__c > newMoveOutDate && newMoveOutDate > objLocc.StartDate__c){
                    if(!mapOldEndDateToNewEndDate.containsKey(objLocc.EndDate__c)){
                        mapOldEndDateToNewEndDate.put(objLocc.EndDate__c,newMoveOutDate);
                    }
                    objLocc.EndDate__c = newMoveOutDate;
                    if(!mapId2LocOccRec.containsKey(objLocc.Id)){
                        mapId2LocOccRec.put(objLocc.Id,objLocc);
                    }
                }
            }
        }
        
        system.debug('mapId2LocOccRec****'+ mapId2LocOccRec + '...mapOldEndDateToNewEndDate...' + mapOldEndDateToNewEndDate);
       
        if(mapId2LocOccRec.keyset().size() > 0){
            updateServiceItemsLogicNew(mapOldStartDateToNewStartDate,mapOldEndDateToNewEndDate);
            createAndInvalidateMoveReadings(mapOldStartDateToNewStartDate,mapOldEndDateToNewEndDate);
            createVoidPeriod();
            
            // update Locc Occ records & create void readings and period if any
            List<LocationOccupant__c> lstLocationOccupant= (List<LocationOccupant__c>) GlUt_FieldSecurity.cleanseFields(mapId2LocOccRec.values(), false);
            update lstLocationOccupant;
            
            //Check if now there are any void readings already present in system which is to be invalidated
            invalidateVoidReadings(mapId2LocOccRec);
        }
    }
        
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to update SI
	@Revisions		Tarun Gupta, AT-3904 Updates the Ended__c checkbox as true for all the Service Items where End date is modified
    **********************************************************************************************/    
    public static void updateServiceItemsLogicNew(Map<Date,Date> mapOldStartDateToNewStartDate, Map<Date,Date> mapOldEndDateToNewEndDate) {
        
        Map<Integer,ServiceItem__c> mapUniqueKey2AmendedServiceItem = new Map<Integer,ServiceItem__c>();
        Map<Integer,ServiceItem__c> mapUniqueKey2NewServiceItem = new Map<Integer,ServiceItem__c>();
        List<ServiceItem__c> listServiceItemToAmend = new List<ServiceItem__c>();
        List<ServiceItem__c> listServiceItemToAmendNew = new List<ServiceItem__c>();
        
        Integer uniqueCount = 0;
        
        Date oldStartDate  = currentLocOccRecord.StartDate__c;
        Date oldEndDate  = currentLocOccRecord.EndDate__c;
        
        Boolean booleanConditionMet = false;
        
        //serviceItemListOnLocation
        for(ServiceItem__c objSIToUpdate :serviceItemListOnLocation){
            uniqueCount += 1;
            if(moveInOrMoveOut == Label.CuAp_ReadingReadingTypeMoveIn){
                
                ServiceItem__c objNewSI = new ServiceItem__c();
                
                //if(setOldStartDate.contains(objSIToUpdate.StartDate__c)){
                //objSIToUpdate.EndDate__c != null && objSIToUpdate.EndDate__c > newMoveInDate && objSIToUpdate.StartDate__c < newMoveInDate
                if(objSIToUpdate.StartDate__c == oldStartDate){
                    //Create new SI with new Move In Date
                    booleanConditionMet = true;
                    objNewSI = createServiceItemObject(objSIToUpdate,newMoveInDate,Label.CuAp_AmendMoveStartDateChange);
                }
                else if(mapOldStartDateToNewStartDate.containskey(objSIToUpdate.StartDate__c)){
                    booleanConditionMet = true;
                    objNewSI = createServiceItemObject(objSIToUpdate,mapOldStartDateToNewStartDate.get(objSIToUpdate.StartDate__c),Label.CuAp_AmendMoveStartDateChange);
                }
                else if(objSIToUpdate.EndDate__c != null && mapOldEndDateToNewEndDate.containskey(objSIToUpdate.EndDate__c)){
                    objSIToUpdate.EndDate__c = mapOldEndDateToNewEndDate.get(objSIToUpdate.EndDate__c);
                    objSIToUpdate.Ended__c = true;
                    listServiceItemToAmend.add(objSIToUpdate);
                }
                
                if(booleanConditionMet){
                    booleanConditionMet = false;
                    if(!mapUniqueKey2AmendedServiceItem.containsKey(uniqueCount)){
                        mapUniqueKey2AmendedServiceItem.put(uniqueCount,objSIToUpdate);
                    }
                    if(!mapUniqueKey2NewServiceItem.containsKey(uniqueCount)){
                        mapUniqueKey2NewServiceItem.put(uniqueCount,objNewSI);
                    }
                }
            }
            else if(moveInOrMoveOut == Label.CuAp_ReadingReadingTypeMoveOut){
                //if(setOldEndDate.contains(objSIToUpdate.EndDate__c)){
                //
                ServiceItem__c objNewSI = new ServiceItem__c();
                
                if(objSIToUpdate.EndDate__c != null && (objSIToUpdate.EndDate__c == oldEndDate || (objSIToUpdate.EndDate__c > newMoveOutDate && newMoveOutDate > objSIToUpdate.StartDate__c))){
                    objSIToUpdate.EndDate__c = newMoveOutDate;
                    objSIToUpdate.Ended__c = true;
                    listServiceItemToAmend.add(objSIToUpdate);
                }
                else if(mapOldStartDateToNewStartDate.containskey(objSIToUpdate.StartDate__c)){
                    booleanConditionMet = true;
                    objNewSI = createServiceItemObject(objSIToUpdate,mapOldStartDateToNewStartDate.get(objSIToUpdate.StartDate__c),Label.CuAp_AmendMoveStartDateChange);
                }
                else if(objSIToUpdate.EndDate__c != null && mapOldEndDateToNewEndDate.containskey(objSIToUpdate.EndDate__c)){
                    objSIToUpdate.EndDate__c = mapOldEndDateToNewEndDate.get(objSIToUpdate.EndDate__c);
                    objSIToUpdate.Ended__c = true;
                    listServiceItemToAmend.add(objSIToUpdate);
                }
                
                if(booleanConditionMet){
                    booleanConditionMet = false;
                    if(!mapUniqueKey2AmendedServiceItem.containsKey(uniqueCount)){
                        mapUniqueKey2AmendedServiceItem.put(uniqueCount,objSIToUpdate);
                    }
                    if(!mapUniqueKey2NewServiceItem.containsKey(uniqueCount)){
                        mapUniqueKey2NewServiceItem.put(uniqueCount,objNewSI);
                    }
                }
            }
        }
        
        if(mapUniqueKey2NewServiceItem.keyset().size() > 0){
            List<ServiceItem__c> lstServiceItem= (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(mapUniqueKey2NewServiceItem.values(), false);
            insert mapUniqueKey2NewServiceItem.values();
            
            if(mapUniqueKey2AmendedServiceItem.keyset().size() > 0){
                
                for(Integer objAmendSI : mapUniqueKey2AmendedServiceItem.keyset()){
                    
                    ServiceItem__c objServiceItemAmend = mapUniqueKey2AmendedServiceItem.get(objAmendSI);
                    objServiceItemAmend.AmendedByServiceItem__c = mapUniqueKey2NewServiceItem.get(objAmendSI).Id;
                    
                    listServiceItemToAmend.add(objServiceItemAmend);
                }
            }
        }
        
        if(!listServiceItemToAmend.isEmpty()){
            for(ServiceItem__c objServItem : listServiceItemToAmend){
                setContractIds.add(mapServiceItemId2ContractId.get(objServItem.Id));
            }
            listServiceItemToAmend= (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(listServiceItemToAmend, false);
            if(!listServiceItemToAmend.isEmpty()){
                listServiceItemToAmendNew.addAll(listServiceItemToAmend);
                listServiceItemToAmend.clear();
                upsert listServiceItemToAmendNew;
            }
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
        
        system.debug('listNewMoveReadings***'+ listNewMoveReadings);
        
        if(!listNewMoveReadings.isEmpty()){
            listNewMoveReadingsNew.addall(listNewMoveReadings);
            listNewMoveReadings.clear();
            upsert listNewMoveReadingsNew;
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
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to get void period
	@Revisions	   Tarun Gupta, AT-3936 create void readings in case there is only one location occupant on location
    **********************************************************************************************/    
    public static void createVoidPeriod() {
        
        List<Date> listStartDate = new List<Date>();
        List<Date> listEndDate = new List<Date>();
        Boolean isLocOccAfterCurrentExists = false;
        
        Map<Id,LocationOccupant__c> mapId2LocOcc = new Map<Id,LocationOccupant__c>();        
        Map<Date,Date> mapStartVoid2EndVoid = new Map<Date,Date>();
        
        for(LocationOccupant__c objLoc : listAllLocOccOnLocation){
            if(!mapId2LocOcc.containsKey(objLoc.Id)){
                mapId2LocOcc.put(objLoc.Id, objLoc);
            }
        }
        
        if(mapId2LocOcc.values().size() == 1){
            // It means there is only one location occupant on location i.e. the currentLocOccRecord
            createVoidPeriodForOneLocOcc();
        }
        else{
            // It means there are more than one location occupant on location 
            if(newMoveInDate != null){
                // In case date is increased
                if(newMoveInDate > currentLocOccRecord.StartDate__c || newMoveInDate < currentLocOccRecord.StartDate__c){
                    //check for record with enddate less then the current rec
                    for(LocationOccupant__c objMapNew : mapId2LocOcc.values()){
                        if(objMapNew.Id != currentLocOccRecord.Id 
                           && objMapNew.EndDate__c != null 
                           && objMapNew.EndDate__c < currentLocOccRecord.StartDate__c
                           && newMoveInDate > objMapNew.EndDate__c){
                               //Get the lastest end date record only
                               listEndDate.add(objMapNew.EndDate__c);
                           }
                    }
                    if(!listEndDate.isEmpty()){
                        listEndDate.sort();
                        for(LocationOccupant__c objMap : listAllLocOccOnLocation){
                            if(objMap.Id != currentLocOccRecord.Id 
                               && objMap.EndDate__c != null 
                               && objMap.EndDate__c < currentLocOccRecord.StartDate__c
                               && objMap.EndDate__c == listEndDate[listEndDate.size() - 1]){
                                   if(objMap.EndDate__c.daysBetween(newMoveInDate) > 1){
                                       mapStartVoid2EndVoid.put(objMap.EndDate__c.addDays(1), newMoveInDate.addDays(-1));
                                   }
                               }
                        }
                    }
                }
            }
            else if(newMoveOutDate != null){
                if(newMoveOutDate < currentLocOccRecord.EndDate__c || newMoveOutDate > currentLocOccRecord.EndDate__c) {
                    // if there is any record present with start date greater then new newMoveOutDate
                    for(LocationOccupant__c objMapNew : mapId2LocOcc.values()){
                        if(objMapNew.Id != currentLocOccRecord.Id
                           && objMapNew.StartDate__c > newMoveOutDate){
                               listStartDate.add(objMapNew.StartDate__c);
                           }
                        // AT-5418 start..
                        // if current occupier is last occupieron location
                        if(objMapNew.Id != currentLocOccRecord.Id && currentLocOccRecord.StartDate__c < objMapNew.StartDate__c)
                        	isLocOccAfterCurrentExists= true;
                        // AT-5418 end..
                        
                    }
                    if(!listStartDate.isEmpty()){
                        listStartDate.sort();
                        for(LocationOccupant__c objMap : mapId2LocOcc.values()){
                            if(objMap.Id != currentLocOccRecord.Id 
                               && objMap.StartDate__c > newMoveOutDate
                               && objMap.StartDate__c == listStartDate[0]){
                                   if(newMoveOutDate.daysBetween(objMap.StartDate__c) > 1){
                                       mapStartVoid2EndVoid.put(newMoveOutDate.addDays(1),objMap.StartDate__c.addDays(-1));
                                   }
                               }
                           }
                    }
                }
            }
        }
        
        if(mapStartVoid2EndVoid.keySet().size() > 0){
            // Create a void period between these dates and invalidate old void periods
            //Ideally this map should only have one value , so putting it in loop
            
            Date startVoid;
            Date endVoid;
            for(Date objDate : mapStartVoid2EndVoid.keyset()){
                startVoid = objDate;
                endVoid =  mapStartVoid2EndVoid.get(objDate);
            }
            
            Boolean booleanCreateVoidStart = false;
            Boolean booleanCreateVoidEnd = false;
            
            for(Reading__c objVoidRead :listVoidAndMoveReadingsOnDevice){
                
                if(startVoid != null && objVoidRead.ReadingType__c == Label.CuAp_ReadingReadingTypeVoidStart && objVoidRead.ReadingDate__c == startVoid){
                    // It means there is a void reading with this date , not required to create this void start
                    booleanCreateVoidStart = true;
                    break;
                }
            }
            
            for(Reading__c objVoidRead :listVoidAndMoveReadingsOnDevice){
                
                if(endVoid != null && objVoidRead.ReadingType__c == Label.CuAp_ReadingReadingTypeVoidEnd && objVoidRead.ReadingDate__c == endVoid){
                    // It means there is a void reading with this date , not required to create this void start
                    booleanCreateVoidEnd = true;
                    break;
                }
            }
            
            if(!booleanCreateVoidStart)
	            createVoidreadings(startVoid, Label.CuAp_ReadingReadingTypeVoidStart);
            
            if(!booleanCreateVoidEnd)
            	createVoidreadings(endVoid, Label.CuAp_ReadingReadingTypeVoidEnd);
            
            Id voidId = GlUt_ContractUtilities.createVoidContract(locationId, startVoid, null, startVoid);
            
        } else if(!isLocOccAfterCurrentExists){  // AT-5418 if Occupier is a last 
            Date startVoid = newMoveOutDate.addDays(1);            
            createVoidreadings(startVoid, Label.CuAp_ReadingReadingTypeVoidStart);
            Id voidId = GlUt_ContractUtilities.createVoidContract(locationId, startVoid, null, startVoid);
        }  // AT-5418 end..
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 11 Oct 2018
    @description : AT-3936 , This method is to generate void readings when there is only one location occupant on location
    **********************************************************************************************/    
    public static void createVoidPeriodForOneLocOcc() {
        
        if(newMoveInDate != null){
            Date locationBuildDate = [SELECT Id,Name,BuildDate__c FROM Location__c WHERE Id =: currentLocOccRecord.Location__c LIMIT 1].BuildDate__c;
            
            if(locationBuildDate != null && newMoveInDate > locationBuildDate){
                createVoidreadings(locationBuildDate, Label.CuAp_ReadingReadingTypeVoidStart);
                createVoidreadings(newMoveInDate.addDays(-1), Label.CuAp_ReadingReadingTypeVoidEnd);
            }
        }
        
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to generate void readings
    **********************************************************************************************/    
    public static void createVoidreadings(Date voidDate, String voidStartOrEnd) {
        
        List<Reading__c> listVoidReadingToInsert = new List<Reading__c>();
        List<Reading__c> listVoidReadingToInvalidate = new List<Reading__c>();
        
        Reading__c objReadingVoid = new Reading__c();
        
        String actualReading;
        String readingMethod;
        
        //AT-5418 start...
        if(newMoveOutDate != null && !mapDeviceId2ReadingObject.isEmpty()){
            for(Id deviceId: mapDeviceId2ReadingObject.keySet()){
                Reading__c objReading = new Reading__c();
                objReading.Device__c =  deviceId;
                objReading.ReadingDate__c = voidDate;
                objReading.ActualDeviceReading__c = mapDeviceId2ReadingObject.get(deviceId).ActualDeviceReading__c;
                objReading.ReadingMethod__c = mapDeviceId2ReadingObject.get(deviceId).ReadingMethod__c;
                objReading.ReadingType__c = voidStartOrEnd;
                objReading.Billed__c = false;
                
                listVoidReadingToInsert.add(objReading);
            }
        } // AT-5418 end...
        else if(!listMoveInOutReadingOnDevice.isEmpty()){
            //List will only have one record
            for(Reading__c objNew : listMoveInOutReadingOnDevice){
                actualReading = objNew.ActualDeviceReading__c;
                readingMethod = objNew.ReadingMethod__c;
            }
        }
        
        if(actualReading != null && readingMethod != null){
            
            for(Id objDeviceId : setDeviceIds){
                
                Reading__c objReading = new Reading__c();
                objReading.Device__c =  objDeviceId;
                objReading.ReadingDate__c = voidDate;
                objReading.ActualDeviceReading__c = actualReading;
                objReading.ReadingMethod__c = readingMethod;
                objReading.ReadingType__c = voidStartOrEnd;
                objReading.Billed__c = false;
                
                listVoidReadingToInsert.add(objReading);
            }
        }
        
        if(!listVoidReadingToInsert.isEmpty()){
            
            //Invalidate old void readings
            for(Reading__c objVoidRead :listVoidAndMoveReadingsOnDevice){
                if(objVoidRead.ReadingType__c == Label.CuAp_ReadingReadingTypeVoidStart || objVoidRead.ReadingType__c == Label.CuAp_ReadingReadingTypeVoidEnd){
                    
                    if(objVoidRead.ReadingDate__c == voidDate && objVoidRead.ReadingType__c == voidStartOrEnd){
                        objVoidRead.BillableType__c = Label.CuAp_ReadingBillableTypeInvalid;
                        listVoidReadingToInvalidate.add(objVoidRead);
                    }
                    
                    if(voidStartOrEnd == Label.CuAp_ReadingReadingTypeVoidEnd && objVoidRead.ReadingType__c == Label.CuAp_ReadingReadingTypeVoidEnd && objVoidRead.ReadingDate__c < voidDate){
                        objVoidRead.BillableType__c = Label.CuAp_ReadingBillableTypeInvalid;
                        listVoidReadingToInvalidate.add(objVoidRead);
                    }
                }
            }
            listVoidReadingToInsert = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(listVoidReadingToInsert, false);
            insert listVoidReadingToInsert;
            
            if(!listVoidReadingToInvalidate.isEmpty()){
                listVoidReadingToInvalidate = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(listVoidReadingToInvalidate, false);
                update listVoidReadingToInvalidate;
            }
        }
    }
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 17 Sep 2018
    @description : This method is to generate void readings
    **********************************************************************************************/    
    public static void invalidateVoidReadings(Map<Id,LocationOccupant__c> mapId2LocOccRec) {
        
        List<Reading__c> listOldVoidReadingsToInvalidate = new List<Reading__c>();
        
        for(Reading__c objVoidCheck :listVoidAndMoveReadingsOnDevice){
            
            if(objVoidCheck.ReadingType__c == Label.CuAp_ReadingReadingTypeVoidStart || objVoidCheck.ReadingType__c == Label.CuAp_ReadingReadingTypeVoidEnd){
                for(LocationOccupant__c objLocOcc :mapId2LocOccRec.values()){
                    
                    if(objLocOcc.EndDate__c != null && objVoidCheck.ReadingDate__c >= objLocOcc.StartDate__c && objVoidCheck.ReadingDate__c <= objLocOcc.EndDate__c){
                        listOldVoidReadingsToInvalidate.add(objVoidCheck);
                    }
                    else if(objLocOcc.EndDate__c == null && objVoidCheck.ReadingDate__c >= objLocOcc.StartDate__c){
                        listOldVoidReadingsToInvalidate.add(objVoidCheck);
                    }
                }
            }
        }
        
        for(Reading__c objReadVoid :listOldVoidReadingsToInvalidate){
            objReadVoid.BillableType__c = Label.CuAp_ReadingBillableTypeInvalid;
        }
        
        if(!listOldVoidReadingsToInvalidate.isEmpty()){
            listOldVoidReadingsToInvalidate = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(listOldVoidReadingsToInvalidate, false);
            update listOldVoidReadingsToInvalidate;
        }
    }
}