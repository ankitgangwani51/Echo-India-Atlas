/******************************************************************************
@author         Dependra Singh
@date           23 Oct 2018
@description    An apex class for Debt Transfer Lightning Component  
@Revisions		13 Dec 2018 , Tarun Gupta , AT-4502,4504,4505 , Added new parameter - LicenseId and sent it as blank
*******************************************************************************/
public with sharing class LoAp_DebtTransferCtrlr {
    private static final String CLASS_NAME = 'LoAp_DebtTransferCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static final List<String> transferReasonField = new List<string>{ GlUt_APIConstantsBillTransfer.TRANSFERREASONAPINAME};   
    private static final List<String> locationFields = new List<string>{
        																 GlUt_APIConstantsLocation.NAMEAPINAME,
        															     GlUt_APIConstantsLocation.LOCATIONADDRESSAPINAME
                                                                       };                                                  
    /******************************************************************************
    @author         Dependra Singh
    @date           23 Oct 2018
    @return         List<List<GlAp_FieldProps>>
    @description    This method returns the field properties for each of the fields that are
    to be displayed on the screen
    *******************************************************************************/
	@AuraEnabled
	public static List<List<GlAp_FieldProps>> retrieveTransferReasonDetails() {
		List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
		try {
            List<GLAp_FieldProps> transferReasonFieldProps = new List<GLAp_FieldProps>();
            transferReasonFieldProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsBillTransfer.BILLTRANSFERAPINAME, transferReasonField);
            for(integer i=0; i < transferReasonFieldProps.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(transferReasonFieldProps[i]);
				
				if(secondEntryIndex < transferReasonFieldProps.size()){
					lstEntry.add(transferReasonFieldProps[secondEntryIndex]);   
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
    @author         Dependra Singh
    @date           23 Oct 2018
    @return         List<List<GlAp_FieldProps>>
    @description    This method returns the field properties for each of the fields that are
    to be displayed on the screen
    *******************************************************************************/
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrieveLocationFieldDetails() { 
        List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
        // Get the field properties for the Location object        
        List<GLAp_FieldProps> locationProperties = new List<GLAp_FieldProps>();
        try {
            locationProperties = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsLocation.LOCATIONAPINAME, locationFields); 
            GlAp_FieldProps objFieldProp = new GlAp_FieldProps(true, false, false, false,LoAp_Constants.DEBTAMOUNTAPI,LoAp_Constants.DEBTAMOUNTLABEL, 
                                                               'currency', false, false, GlUt_APIConstantsLocation.LOCATIONAPINAME) ;
            locationProperties.add(objFieldProp);
            for(GlAp_FieldProps fieldProp : locationProperties ){
                fieldProp.isEditable = false;
                fieldProp.showLabel = true;
            }
            for(integer i=0; i < locationProperties.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(locationProperties[i]);
                
                if(secondEntryIndex < locationProperties.size()){
                    lstEntry.add(locationProperties[secondEntryIndex]);   
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
    @author         Dependra Singh
    @date           23 Oct 2018
    @return         Location__c
    @description    Method is used to return location information by using location id.
    *******************************************************************************/
    @AuraEnabled
    public static Location__c retrieveLocationDetails(String LocationID) {    
        Location__c objLocation ;
        if(string.isNotBlank(LocationID)){
            objLocation = (Location__c)GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsLocation.LOCATIONAPINAME,
                                                                          LocationID,locationFields);
        }	
        return objLocation;
    }
	/******************************************************************************
    @author         Dependra Singh
    @date           23 Oct 2018
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the fields that are
    to be displayed on the screen
   *******************************************************************************/
    @AuraEnabled
    public static string transferDebts(String LocationID, String contractToTransferID, String transferReason,string billCalculationId) {
        String responseCode;
        
        CuAp_BillTransferObject objBTData = new CuAp_BillTransferObject();
        objBTData.BillTransfers = new List<CuAp_BillTransferObject.BillTransfers>();
        
        CuAp_BillTransferObject.BillTransfers objBillTransfer = new CuAp_BillTransferObject.BillTransfers(null,contractToTransferID,null,
                                                                                                          transferReason,LocationID,billCalculationId,null);
        objBTData.BillTransfers.add(objBillTransfer);
        String JSONPayload = JSON.serialize(objBTData);
        try{ 
            HttpResponse response = BlUt_HerokuWebservices.makeCallout(BlUt_HerokuWebservices.DEBT_TRANSFER, 2000, 'application/json', JSONPayload, 'PUT');
            // handle response
            if (response.getStatusCode() == 200) {
                System.debug(DEBUG + 'Good response: ' + response.getStatusCode() + ' ' + response.getStatus());
                
                if(billCalculationId != null ){ 
                    List<BillCalculation__c> billCalculationList = [SELECT Id, Status__c FROM BillCalculation__c 
                                                                    WHERE ID =: billCalculationId LIMIT 1];
                    billCalculationList[0].Status__c = Label.BlIn_BillCalculationStatusPending;
                    billCalculationList  = (List<BillCalculation__c>) GlUt_FieldSecurity.cleanseFields(billCalculationList, false);
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
    @author         Dependra
    @date           23 Oct 2018
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
    @author         Dependra Singh
    @date           11 Nov 2018
    @return         Boolean
    @description    This method returns status of debt transfer if already done for this location.
    *******************************************************************************/
	/*@AuraEnabled
    public static boolean checkIfDebtExist(string locationId){
        boolean isDebtExists = false;
        Set<Id> contractIds  = new Set<Id>();
        Set<Id> billIds  = new Set<Id>();
        if(locationId != null){
            Map<Id,SupplyPoint__c> supplyPointMap = new Map<Id,SupplyPoint__c>([SELECT Id FROM SupplyPoint__c WHERE Location__c =: locationId]);
            if(supplyPointMap.keySet().size() >0){
                Map<Id,BillItem__c> billItemMap = new Map<Id,BillItem__c>([SELECT Id, Bill__r.SelectedBillTransfer__c 
                                                                           FROM BillItem__c 
                                                                           WHERE SupplyPoint__c IN: supplyPointMap.keySet() 
                                                                           AND Bill__r.SelectedBillTransfer__c = null 
                                                                           AND Bill__r.TotalAmountOutstanding__c > 0 
                                                                           AND Bill__r.BillType__c =: Label.CuAp_NormalBillType]);
                if(billItemMap.keySet().size() >0){
                    isDebtExists = true;
                }
            }
        }
        return isDebtExists;
    } */
        
       
	/******************************************************************************
    @author         Dependra
    @date           24 Oct 2018
    @description    This wrapper class is used to diaplay information on page. 
    *******************************************************************************/
	public class DebtTransferContainerWrapper{
		@AuraEnabled
		public List<List<GlAp_FieldProps>> transferReasonList;
		@AuraEnabled
		public List<List<GlAp_FieldProps>> locationFieldList;
		@AuraEnabled
		public Location__c locationObj;
        //@AuraEnabled
        //public Boolean isDebtExist;
        @AuraEnabled
        public Decimal debtAmount;
        public DebtTransferContainerWrapper(){
              this.transferReasonList = new List<List<GlAp_FieldProps>>();
              this.locationFieldList = new List<List<GlAp_FieldProps>>();
              this.locationObj = new Location__c();
          }
	}
   /******************************************************************************
    @author         Dependra Singh
    @date           24 Oct 2018
	@parameters		string locationRecordId
    @return         DebtTransferContainerWrapper wrapper class
    @description    This method is used to display page information.
    *******************************************************************************/
	@AuraEnabled
    public static DebtTransferContainerWrapper getInfoToDisplay(string locationRecordId) { 
        DebtTransferContainerWrapper objWrapper = new DebtTransferContainerWrapper();
        if(locationRecordId != null ){
            objWrapper.transferReasonList = retrieveTransferReasonDetails();
            objWrapper.locationFieldList = retrieveLocationFieldDetails();
            objWrapper.locationObj = retrieveLocationDetails(locationRecordId); 
            //objWrapper.isDebtExist = checkIfDebtExist(locationRecordId);
            objWrapper.debtAmount = LoUt_LocationDebt.getTotalOutstandingDebt(Id.valueOf(locationRecordId));
        }
        system.debug('objWrapper===='+objWrapper);
        return objWrapper;
	}
}