/********************************************************************************
@author:		Echo: Dependra Singh
@date:			24 November 2017
@description:	Component controller for New Billing Address Page(Moveout wizard) 
Revision(s)		04 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing  class CuAp_NewBillingAddressPageCtrlr {
    
    private static final String CLASS_NAME = 'CuAp_NewBillingAddressPageCtlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static final List<String> contractListFields = new List<String> {
																	        GlUt_APIConstantsContracts.BILLINGADDRESSAPINAME,
																	        GlUt_APIConstantsContracts.BILLINGSTREETNAME,
																	        GlUt_APIConstantsContracts.BILLINGCITYAPINAME,
																	        GlUt_APIConstantsContracts.BILLINGSTATEAPINAME,
																	        GlUt_APIConstantsContracts.BILLINGPOSTALCODEAPINAME,
																	        GlUt_APIConstantsContracts.BILLINGCOUNTRYAPINAME,
																	        GlUt_APIConstantsContracts.HOUSEHOLDBILLINGAPINAME,
																	        GlUt_APIConstantsContracts.CUSTOMERAPINAME,
																	        GlUt_APIConstantsContracts.STATUSAPINAME
																	        };          
    private static final List<String> supplyPointFieldsList = new List<String> {
																	        CuAp_Constants.SPLOCATIONAPINAME
																	        };      
    private static final List<String> servicesFieldsList = new List<String> {
																	        CuAp_Constants.SUPPLYPOINTAPINAME,
																	        CuAp_Constants.SERVICEENDDATEAPINAME,   
																	        CuAp_Constants.SERVICECONTRACTAPINAME
																	        };

	/**********************************************************************************************
	@author      : Echo: Dependra
	@date        : 22-Jan-2018
	@params      : String fieldsetName
	@return      : List<List<GLAp_FieldProps>>
	@description : This method returns payments back related fields as List 
	**********************************************************************************************/   
                                                                                 @AuraEnabled
    public static List<List<GLAp_FieldProps>> retrieveAddressFields(String fieldsetName) {
        try {
            fieldsetName =    GlUt_NamespacePrefix.getNamespacePrefix() +  fieldsetName;
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            List<GLAp_FieldProps> payProps = GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetName(CuAp_Constants.CONTRACTAPINAME, 
                                                                                                                     fieldsetName);
            for(GLAp_FieldProps billAddProp: payProps){
                if((billAddProp.fieldName ==  CuAp_Constants.BILLINGSTREETNAME) || (billAddProp.fieldName ==  CuAp_Constants.BILLINGPOSTALCODEAPINAME))
                    billAddProp.isRequired = true;
            }
            
            for(integer i=0; i < payProps.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(payProps[i]);
                
                if(secondEntryIndex < payProps.size()){
                    lstEntry.add(payProps[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
            }
            return twoColFormattedList;

        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }   
    } 
                          
	/**********************************************************************************************
	@author         Echo: Dependra Singh
	@date           24-Nov-2017
	@param          Id (Location Id)
	@param          Id (Account Id)
	@return         BillingContract__c
	@description    This method returns the active contract billing address fields based on location id .
	**********************************************************************************************/
    @AuraEnabled
    public static BillingContract__c retrieveContractBillingDetails(Id locationId, Id accountId) {
        
        List <BillingContract__c> contractList = new List <BillingContract__c>();
        List <SupplyPoint__c> supplyPointList = new List <SupplyPoint__c>();
        List <Service__c> servicesList = new List <Service__c>();
        List <BillingContract__c> actualContractList = new List <BillingContract__c>();
        set <Id> accountIds = new set <Id>();
        set <Id> locationIds = new set <Id>();
        set <Id> contractIds = new set <Id>();
        set <Id> supplyPointsIds = new set <Id>();
        
        try {
            if (accountId != null) {
                accountIds.add(accountId);
            }
            if (locationId != null) {
                locationIds.add(locationId);
                if (locationIds.size() > 0) {
                    // retrieve supplypoints information
                    supplyPointList = retrieveSupplyPoints(locationIds);
                    
                    if (!supplyPointList.isEmpty()) {
                        for (SupplyPoint__c objSP : supplyPointList) {
                            supplyPointsIds.add(objSP.id);
                        }
                    }
                    // retrieve services information
                    servicesList = retrieveServices(supplyPointsIds);
                    
                    if (!servicesList.isEmpty()) {
                        for (Service__c objService : servicesList) {
                            contractIds.add(objService.BillingContract__c);
                        }
                    }
                    // retrive contract information
                    contractList = retrieveContracts(contractIds, accountIds);
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        if (!contractList.isEmpty()) return contractList[0];
		return null;
    }
    
	/**********************************************************************************************
	@author         Echo: Dependra Singh
	@date           12-Dec-2017
	@param          set <Id> (Set of location Ids)
	@return         List<SupplyPoint__c>
	@description    This method returns list of supplypoints by using location ids  .
	**********************************************************************************************/ 
    private static List<SupplyPoint__c> retrieveSupplyPoints(Set<Id> locationIds) {

        return (List<SupplyPoint__c>) GlAp_LightningDataAccess.getRecords(CuAp_Constants.SUPPLYPOINTAPINAME, 
																	supplyPointFieldsList, 
																	String.format('WHERE {0} IN {1}', 
																		new List<String>{
																			CuAp_Constants.SPLOCATIONAPINAME, 
																			GlUt_FieldSecurity.IdsToString(locationIds)}));
    }
    
	/**********************************************************************************************
	@author         Echo: Dependra Singh
	@date           12-Dec-2017
	@param          set <Id> (Set of supplypoints Ids)
	@return         List<Service__c>
	@description    This method returns list of services by using supplypoints ids  .
	**********************************************************************************************/     
    private static List<Service__c> retrieveServices(set <Id> setSupplyPointsId) {

       return (List<Service__c>) GlAp_LightningDataAccess.getRecords(CuAp_Constants.SERVICEAPINAME, 
																	servicesFieldsList, 
																	String.format('WHERE {0} IN {1}', 
																		new List<String>{
																			CuAp_Constants.SUPPLYPOINTAPINAME, 
																			GlUt_FieldSecurity.IdsToString(setSupplyPointsId)}));
    }
    
	/**********************************************************************************************
	@author         Echo: Dependra Singh
	@date           12-Dec-2017
	@param          set<Id> (Set of contract Ids)
	@param          set<Id> (Set of account Ids)
	@return         List<BillingContract__c>
	@description    This method returns list of contracrs by using contract ids and account ids .
	**********************************************************************************************/         
    private static List<BillingContract__c> retrieveContracts(Set<Id> setContractId, Set<Id> setAccountId){
        Set<String> validStatuses = new Set<String>{GlUt_APIConstantsContracts.STATUS_ACTIVE};

        List<BillingContract__c> contractList = new List<BillingContract__c>();
        if (setContractId.size() > 0) {
			contractList = (List<BillingContract__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsContracts.CONTRACTAPINAME, 
																						contractListFields, 
																						String.format('where Id in {0} and {1} IN {2} and {3} in {4}', 
																							new List<String>{
																								GlUt_FieldSecurity.IdsToString(setContractId), 
										        												GlUt_APIConstantsContracts.CUSTOMERAPINAME, 
										        												GlUt_FieldSecurity.IdsToString(setAccountId), 
										        												GlUt_APIConstantsContracts.STATUSAPINAME, 
										        												GlUt_FieldSecurity.StringsToString(validStatuses)}));
        }
        return contractList;
    }
    
}