/******************************************************************************
@author    		Echo: Patrick Dixon
@date      		11 Jan 2018
@description 	Component controller for billing actions
*******************************************************************************/
public with sharing class CuAp_BillingActionsCtrlr {
	
	private static final String CLASS_NAME = 'CuAp_BillingActionsCtrlr';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
	
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		11 Jan 2018
	@param			Id - account Id
	@return			Boolean - true for NHH Account
	@description	Method called by the Component to check if the host page is a HH Account
	*******************************************************************************/
	@AuraEnabled
	public static Boolean isNHHAccount(Id accountId) {
        Boolean isNHHAccountCheck;
        try {
            isNHHAccountCheck =  GlUt_AccountUtilities.isNHHAccount(accountId);

        } catch (exception e) {
            GlUt_Logger.logException(e);

        } finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return isNHHAccountCheck;
    }
    
    /******************************************************************************
	@author    		Echo: Tarun Gupta
	@date      		11 Dec 2018
	@param			Id - rural license Id
	@return			Boolean - true for active rural license
	@description	Method called by the Component to check if the rural license is active or not
	*******************************************************************************/
	@AuraEnabled
	public static Boolean statusOfRuralLicense(Id ruralLicenseId) {
        Boolean isActiveRL = false;
        try {
            isActiveRL =  GlUt_RuralBillingUtilities.isActiveRuralLicense(ruralLicenseId);
        } catch (exception e) {
            GlUt_Logger.logException(e);

        } finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return isActiveRL;
    }
    
    /******************************************************************************
	@author    		Echo: Ankit Gangwani
	@date      		11 March 2019
	@param			Id - Supply Point Id
	@return			Boolean - true for active Supply Point Devices
	@description	Method called by the Component to check if the Supply Point Device is active or not
	*******************************************************************************/
	@AuraEnabled
	public static Boolean isActiveSPD(Id supplyPointId) {
        Boolean isActiveSPD = false;
        List<SupplyPointDevice__c> objSPDList = new List<SupplyPointDevice__c>();
        if (String.isNotBlank(supplyPointId)) {
            String filterStatement  = 'WHERE ' +  GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME + ' = \''+   String.escapeSingleQuotes(supplyPointId) +'\' ' ;
            List<SupplyPointDevice__c> supplyPointDeviceLists = GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, 
                                                                                                    new List<String>{GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME,
                                                                                                        GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME},
                                                                                                    filterStatement);
            
            if(supplyPointDeviceLists != null && !supplyPointDeviceLists.isEmpty()) {
                for(SupplyPointDevice__c sp : supplyPointDeviceLists) {
                    if(sp.Active__c) {
                        isActiveSPD =true;
                        break;
                    }
                }
            }
        }
        return isActiveSPD;
    }
    /******************************************************************************
	@author    		Echo: Amit K. 
	@date      		13 March 2019
	@param			Id contractId
	@return			Boolean - true if Non Void Contracts
	@description	Method used to check Whether the contract is void or Non Void(UL-530)
	*******************************************************************************/
    @AuraEnabled
	public static Boolean isVoidContract(Id contractId) {
        Boolean isNonVoidContract = true;
        if(contractId != null){
            Id accountName = [Select Id,AccountName__c from BillingContract__c Where Id=:contractId Limit 1].AccountName__c;
            if(string.isBlank(accountName)){
                isNonVoidContract = false;
            }
        }
        return isNonVoidContract;
    }
}