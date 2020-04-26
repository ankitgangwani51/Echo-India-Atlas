/******************************************************************************
@author         Tarun Gupta
@date           11 Dec 2018
@description    An apex class for License Transfer Lightning Component  
@revision    	Tarun , AT-5246 and AT-5251
@revision    	Tarun , AT-5274, AT-5255, AT-5231
@revision		Tarun , AT-5267
@Revisions		AT-5372,5498,5382
*******************************************************************************/
public with sharing class BlAp_LicenseTransferCtrlr {
    private static final String CLASS_NAME = 'BlAp_LicenseTransferCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static List<string> transferDateField;
    private static List<string> ruralLicenseFieldsToDisplay;
    private static List<string> ruralLicenseFieldsForData;
    
    static{
        transferDateField = new List<String>();
        transferDateField.add(GlUt_APIConstantsRuralLicense.RURALLICENSETRANSFERDATEAPINAME);
        
        ruralLicenseFieldsToDisplay = new List<String>();
        ruralLicenseFieldsToDisplay.add(GlUt_APIConstantsRuralLicense.RURALLICENSECONTRACTAPINAME);
        ruralLicenseFieldsToDisplay.add(GlUt_APIConstantsRuralLicense.RURALLICENSESTARTDATEAPINAME);
        
        ruralLicenseFieldsForData = new List<String>();
        ruralLicenseFieldsForData.add('Id');
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSECONTRACTAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSESTARTDATEAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSESTATUSAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSEALLOCATEBANKAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSEBUNDLEENTITLEAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSECANCELDATEAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSETRANSFERDATEAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSEINFRACHARGEAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSELOADREFERENCEAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSEOUTLETCHARGEAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSETOTALOUTLETAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSETOTALCHARGEOUTLETAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSEBASEENTITLEAPINAME);
        ruralLicenseFieldsForData.add(GlUt_APIConstantsRuralLicense.RURALLICENSEHEADINFRACHARGEAPINAME);
    }
    /******************************************************************************
    @author         Tarun Gupta
    @date           11 Dec 2018
    @return         List<List<GlAp_FieldProps>>
    @description    This method returns the field properties for each of the fields that are
    to be displayed on the screen
    *******************************************************************************/
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrieveTransferDateDetails() {
        List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
        try {
            List<GLAp_FieldProps> transferDateFieldProps = new List<GLAp_FieldProps>();
            transferDateFieldProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsRuralLicense.RURALLICENSEAPINAME, transferDateField);
            for(integer i=0; i < transferDateFieldProps.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(transferDateFieldProps[i]);
                
                if(secondEntryIndex < transferDateFieldProps.size()){
                    lstEntry.add(transferDateFieldProps[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
            }
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return twoColFormattedList; 
    }
    /******************************************************************************
    @author         Tarun Gupta
    @date           11 Dec 2018
    @return         List<List<GlAp_FieldProps>>
    @description    This method returns the field properties for each of the fields that are
    to be displayed on the screen
    *******************************************************************************/
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrieveRuralLicenseFieldDetails() { 
        List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
        // Get the field properties for the Location object        
        List<GLAp_FieldProps> ruralLicenseProperties = new List<GLAp_FieldProps>();
        try {
            ruralLicenseProperties = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsRuralLicense.RURALLICENSEAPINAME, 
                                                                                        ruralLicenseFieldsToDisplay); 
            for(GlAp_FieldProps fieldProp : ruralLicenseProperties ){
                fieldProp.isEditable = false;
                fieldProp.showLabel = true;
                
                if(fieldProp.fieldName == GlUt_APIConstantsRuralLicense.RURALLICENSECONTRACTAPINAME){
                    fieldProp.fieldLabel = Label.BlAp_RuralLicenseContractOld;
                }
                if(fieldProp.fieldName == GlUt_APIConstantsRuralLicense.RURALLICENSESTARTDATEAPINAME){
                    fieldProp.fieldLabel = Label.BlAp_RuralLicenseStartDateLabel;
                }
            }
            for(integer i=0; i < ruralLicenseProperties.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(ruralLicenseProperties[i]);
                
                if(secondEntryIndex < ruralLicenseProperties.size()){
                    lstEntry.add(ruralLicenseProperties[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return twoColFormattedList;
    }
    /******************************************************************************
    @author         Tarun Gupta
    @date           11 Dec 2018	
    @return         RuralLicense__c
    @description    Method is used to return location information by using location id.
    *******************************************************************************/
    @AuraEnabled
    public static RuralLicense__c retrieveRuralLicenseDetails(String ruralLicenseId, List<String> ruralLicenseFields) {    
        RuralLicense__c objRuralLicense ;
        if(string.isNotBlank(ruralLicenseId)){
            objRuralLicense = (RuralLicense__c)GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsRuralLicense.RURALLICENSEAPINAME,
                                                                                  ruralLicenseId,ruralLicenseFields);
        }	
        return objRuralLicense;
    }
    /******************************************************************************
    @author         Tarun Gupta
    @date           11 Dec 2018
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the fields that are
    to be displayed on the screen
    *******************************************************************************/
    @AuraEnabled
    public static transferLicenserWrapper doLicenseTransfer(String ruralLicenseID, String contractToTransferID, String transferDate) {
        String newRuralLicenseId;
        
        transferLicenserWrapper objWrapper = new transferLicenserWrapper();
        List<RuralLicense__c> listRuralLicenseToUpd = new List<RuralLicense__c>();
        List<ServiceItem__c> listServiceItemsToUpdate = new List<ServiceItem__c>();
        RuralEntitlement__c latestRuralEntitlement = new RuralEntitlement__c();
        List<Location__c> listLocationToUpdate = new List<Location__c>();
        Set<Id> setServiceItemIds = new Set<Id>();
        Date transferredLicenseEndDate;
        Map<Id,Date> mapLicenseId2TransferredLicenseEndDate = new Map<Id,Date>();
        Map<Id,String> mapLicenseId2contractToTransferID = new Map<Id,String>();
        Map<Id,RuralEntitlement__c> mapLicenseId2OldEntitlementObject = new Map<Id,RuralEntitlement__c>();
        
        try{ 
            if(ruralLicenseID != null){
                //Find Latest Active Rural Entitlement
                latestRuralEntitlement = [SELECT Id,Name,Active__c,RemainingVolume__c,SeasonalAllocation__c,StartDate__c
                                          FROM RuralEntitlement__c 
                                          WHERE RuralLicense__c =: Id.valueOf(ruralLicenseID)
                                          AND Active__c = true LIMIT 1];                
                if(latestRuralEntitlement != null){
                    //Find All SI linked to entitlements
                    List<ServiceItem__c> listServiceItems = [SELECT Id,Name
                                                             FROM ServiceItem__c
                                                             WHERE StartDate__c <: Date.valueOf(transferDate)
                                                             AND RuralEntitlement__c =: latestRuralEntitlement.Id
                                                             AND (EndDate__c = null OR EndDate__c > : Date.valueOf(transferDate))];
                    
                    if(listServiceItems != null && !listServiceItems.isEmpty()){
                        for(ServiceItem__c objSI : listServiceItems){
                            setServiceItemIds.add(objSI.Id);
                        }
                        //Find All BI linked to SI's
                        List<BillItem__c> listBillItems = [SELECT Id,Name,EndDate__c
                                                           FROM BillItem__c
                                                           WHERE ServiceItem__c IN: setServiceItemIds
                                                           ORDER BY EndDate__c DESC];
                        
                        if(listBillItems != null && !listBillItems.isEmpty()){
                            //Find latest Bill Item End Date
                            transferredLicenseEndDate = listBillItems[0].EndDate__c;
                            for(ServiceItem__c objSI : listServiceItems){
                                //Update SI End Date as latest Bill Item End Date
                                objSI.EndDate__c = transferredLicenseEndDate;
                                listServiceItemsToUpdate.add(objSI);
                            }
                            if(!listServiceItemsToUpdate.isEmpty()){
                                listServiceItemsToUpdate = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(listServiceItemsToUpdate, false);
                                update listServiceItemsToUpdate;
                            }
                        }
                    }
                    //Mark the Entitlement as active = false
                    latestRuralEntitlement.Active__c = false;
                }
                
                //Current Rural License record
                RuralLicense__c objRuralLicense = retrieveRuralLicenseDetails(ruralLicenseID,ruralLicenseFieldsForData);
                
                String strAllocationBankAccountReference = String.valueOf(objRuralLicense.AllocationBankAccountReference__c);
                String strBundledEntitlementEntityReference = String.valueOf(objRuralLicense.BundledEntitlementEntityReference__c);
                
                //Update Rural License to Cancel
                objRuralLicense.Status__c = Label.BlAp_LicenseTransferStatusTransferred;
                objRuralLicense.CancelledDate__c = Date.valueOf(transferDate).addDays(-1);
                objRuralLicense.TransferDate__c = Date.valueOf(transferDate);
                objRuralLicense.AllocationBankAccountReference__c = null;
                objRuralLicense.BundledEntitlementEntityReference__c = null;
                objRuralLicense = (RuralLicense__c) GlUt_FieldSecurity.cleanseFields(objRuralLicense, false);
                update objRuralLicense;
                
                //Create new license record
                RuralLicense__c objNewRuralLicense = new RuralLicense__c();
                objNewRuralLicense.BillingContract__c = Id.valueOf(contractToTransferID);
                objNewRuralLicense.StartDate__c = objRuralLicense.StartDate__c;
                objNewRuralLicense.Status__c = Label.BlAp_RuralLicenseStatusActive;
                objNewRuralLicense.AllocationBankAccountReference__c = strAllocationBankAccountReference;
                objNewRuralLicense.BundledEntitlementEntityReference__c = strBundledEntitlementEntityReference;
                objNewRuralLicense.OutletCharge__c = objRuralLicense.OutletCharge__c;
                objNewRuralLicense.TotalOutlets__c = objRuralLicense.TotalOutlets__c;
                objNewRuralLicense.BaseEntitlement__c = objRuralLicense.BaseEntitlement__c;
                objNewRuralLicense.InfrastructureCharge__c = objRuralLicense.InfrastructureCharge__c;
                if(GlUt_RegionUtility.getAURegionCustomSetting())
                    objNewRuralLicense.HeadworkInfrastructureCharge__c = objRuralLicense.HeadworkInfrastructureCharge__c;
                objNewRuralLicense.TransferredFromLicense__c = objRuralLicense.Id;
                objNewRuralLicense = (RuralLicense__c) GlUt_FieldSecurity.cleanseFields(objNewRuralLicense, false);
                insert objNewRuralLicense;
                newRuralLicenseId = String.valueOf(objNewRuralLicense.Id);
                objWrapper.newRuralLicenseId = newRuralLicenseId;
                
                for(Location__c objLocation: [SELECT Id,RuralLicense__c FROM Location__c WHERE RuralLicense__c =: objRuralLicense.Id]){
                    objLocation.RuralLicense__c = objNewRuralLicense.Id;
                    listLocationToUpdate.add(objLocation);
                }
                listLocationToUpdate = (List<Location__c>) GlUt_FieldSecurity.cleanseFields(listLocationToUpdate, false);
                if(!listLocationToUpdate.isEmpty()) update listLocationToUpdate;
				//To create access and fixed charges           
                GlUt_LicenseUtility.activateLicenses(new List<RuralLicense__c>{objNewRuralLicense} );
                // RuralEntitlement__c is created inside GlUt_LicenseUtility if any of the SIT is present, else create here only.
                if(objRuralLicense.OutletCharge__c != null || objRuralLicense.InfrastructureCharge__c != null || (GlUt_RegionUtility.getAURegionCustomSetting() && objRuralLicense.HeadworkInfrastructureCharge__c != null)){
                    if(transferredLicenseEndDate != null)
                        mapLicenseId2TransferredLicenseEndDate.put(objNewRuralLicense.Id, transferredLicenseEndDate.addDays(1));
                    else
                        mapLicenseId2TransferredLicenseEndDate.put(objNewRuralLicense.Id, objNewRuralLicense.StartDate__c);
                    mapLicenseId2contractToTransferID.put(objNewRuralLicense.Id,contractToTransferID);
                    if(latestRuralEntitlement != null)
                        mapLicenseId2OldEntitlementObject.put(objNewRuralLicense.Id,latestRuralEntitlement);
                    GlUt_LicenseUtility.createServiceAndSILinkedToLicenseBulkified(new List<RuralLicense__c>{objNewRuralLicense}, mapLicenseId2TransferredLicenseEndDate,mapLicenseId2contractToTransferID,mapLicenseId2OldEntitlementObject);
                }
                else{
                    RuralEntitlement__c objNewRuralEntitlement = new RuralEntitlement__c();
                    objNewRuralEntitlement.RuralLicense__c = objNewRuralLicense.Id;
                    objNewRuralEntitlement.Active__c = true;
                    objNewRuralEntitlement.StartDate__c = latestRuralEntitlement != null ? latestRuralEntitlement.StartDate__c : Date.valueOf(transferDate);
                    objNewRuralEntitlement.TransferFromEntitlement__c = latestRuralEntitlement != null ? latestRuralEntitlement.Id : null;
                    objNewRuralEntitlement.TransferFromRemainingVolume__c = latestRuralEntitlement != null ? latestRuralEntitlement.RemainingVolume__c : null;
                    objNewRuralEntitlement = (RuralEntitlement__c) GlUt_FieldSecurity.cleanseFields(objNewRuralEntitlement, false);
                    insert objNewRuralEntitlement;
                }
                if(latestRuralEntitlement != null){
                    latestRuralEntitlement = (RuralEntitlement__c) GlUt_FieldSecurity.cleanseFields(latestRuralEntitlement, false);
                    update latestRuralEntitlement;
                }
                Id billCalculationId = createBillCalculation(contractToTransferID);
                objWrapper.newBillCalculationId = billCalculationId;
            }
        }
        catch (exception e) {
            System.debug(DEBUG + 'e.getMessage() : '+ e.getMessage());
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return objWrapper;
    }
    /******************************************************************************
    @author         Tarun Gupta
    @date           18 Dec 2018
    @return         String ruralServiceType, String contractToTransferID
    @description    This method returns the Id of newly created service
    *******************************************************************************/
    public static Id createService(String ruralServiceType, String contractToTransferID) {
        
        Service__c objService = new Service__c();
        objService.BillingContract__c = Id.ValueOf(contractToTransferID);
        objService.ServiceType__c = ruralServiceType;
        objService = (Service__c) GlUt_FieldSecurity.cleanseFields(objService, false);
        insert objService;
        return objService.Id;
    }
    /******************************************************************************
    @author         Tarun Gupta
    @date           18 Dec 2018
    @description    This wrapper class is used to send newly created records. 
    *******************************************************************************/
    public class transferLicenserWrapper{
        @AuraEnabled
        public String newRuralLicenseId;
        @AuraEnabled
        public String newBillCalculationId;
        public transferLicenserWrapper(){
        }
    }
    /******************************************************************************
    @author         Tarun Gupta
    @date           18 Dec 2018
    @parameters		String contractId
    @return         BillCalculation Id
    @description    This method create  bill calculation record and return id 
    *******************************************************************************/
    @AuraEnabled
    public static Id createBillCalculation(string contractId){
        BillCalculation__c billCalculationObj = GlUt_BillCalculationUtilities.createBillCalculation(contractId,Label.GlUt_Transfer,Label.BlIn_BillCalculationStatusNew);
        return billCalculationObj.Id;
    }
    /******************************************************************************
    @author         Tarun Gupta
    @date           11 Dec 2018
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the fields that are
    to be displayed on the screen
    *******************************************************************************/
    @AuraEnabled
    public static string callHerokuTotransferLicense(String oldRuralLicenseID, String contractToTransferID, String newRuralLicenseId, String billCalculationId) {
        String responseCode;
        
        CuAp_BillTransferObject objBTData = new CuAp_BillTransferObject();
        objBTData.BillTransfers = new List<CuAp_BillTransferObject.BillTransfers>();
        
        CuAp_BillTransferObject.BillTransfers objBillTransfer = new CuAp_BillTransferObject.BillTransfers(null,contractToTransferID,null,
                                                                                                          Label.BlAp_LicenseTransferReason,null,billCalculationId,oldRuralLicenseID);
        
        objBTData.BillTransfers.add(objBillTransfer);
        String JSONPayload = JSON.serialize(objBTData); 
        try{ 
            system.debug('JSONPayload===='+JSONPayload);
            HttpResponse response = BlUt_HerokuWebservices.makeCallout(BlUt_HerokuWebservices.DEBT_TRANSFER, 2000, 'application/json', JSONPayload, 'PUT');
            // handle response
            if (response.getStatusCode() == 200) {
                if(billCalculationId != null ){ 
                    List<BillCalculation__c> billCalculationList = [SELECT Id, Status__c FROM BillCalculation__c 
                                                                    WHERE ID =: billCalculationId LIMIT 1];
                    billCalculationList[0].Status__c = Label.BlIn_BillCalculationStatusPending;
                    billCalculationList = (List<BillCalculation__c>) GlUt_FieldSecurity.cleanseFields(billCalculationList, false);
                    update billCalculationList;
                }                
                responseCode = Label.GlUt_OK; 
            }
            else {
                System.debug(DEBUG + 'Error response: ' + response.getStatusCode() + ' ' + response.getStatus());
                throw new AuraHandledException(Label.BlAp_BillCalcRequestError + response.getStatus());
            }
        }
        catch (exception e) {
            System.debug(DEBUG + 'e.getMessage() : '+ e.getMessage());
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return responseCode;
    }
    /******************************************************************************
    @author         Tarun Gupta
    @date           11 Dec 2018
    @description    This wrapper class is used to diaplay information on page. 
    *******************************************************************************/
    public class LicenseTransferContainerWrapper{
        @AuraEnabled
        public List<List<GlAp_FieldProps>> transferDateList;
        @AuraEnabled
        public List<List<GlAp_FieldProps>> currentContractFieldList;
        @AuraEnabled
        public RuralLicense__c ruralLicenseObj;
        
        public LicenseTransferContainerWrapper(){
            this.transferDateList = new List<List<GlAp_FieldProps>>();
            this.currentContractFieldList = new List<List<GlAp_FieldProps>>();
            this.ruralLicenseObj = new RuralLicense__c();
        }
    }
    /******************************************************************************
    @author         Tarun Gupta
    @date           11 Dec 2018
    @parameters		string ruralLicenseRecordId
    @return         License Transfer Container wrapper class
    @description    This method is used to display page information.
    *******************************************************************************/
    @AuraEnabled
    public static LicenseTransferContainerWrapper getInfoToDisplay(string ruralLicenseRecordId) { 
        LicenseTransferContainerWrapper objWrapper = new LicenseTransferContainerWrapper();
        if(ruralLicenseRecordId != null ){
            objWrapper.transferDateList = retrieveTransferDateDetails();
            objWrapper.currentContractFieldList = retrieveRuralLicenseFieldDetails();
            objWrapper.ruralLicenseObj = retrieveRuralLicenseDetails(ruralLicenseRecordId,ruralLicenseFieldsToDisplay); 
        }
        return objWrapper;
    }
}