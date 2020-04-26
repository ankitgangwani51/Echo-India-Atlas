/******************************************************************************
@author			Accenture: Shivangi Gaur
@date			13-Nov-2017
@description	Component controller for Select Contract wizard page
Revision(s)		08 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class CuAp_SelectContractCtrlr {
  
    private static final String CLASS_NAME = 'CuAp_SelectContractCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    @testVisible
    private static List<string> conFields;
    
    static{
        
        //Get Fields from the Contract Object
        conFields = new List<string>();
        conFields.add(GlUt_APIConstantsContracts.CONTRACTNAMEAPINAME);
        conFields.add(GlUt_APIConstantsContracts.STATUSAPINAME);
        conFields.add(GlUt_APIConstantsContracts.STARTDATE);
        conFields.add(GlUt_APIConstantsContracts.ENDDATE);
        conFields.add(GlUt_APIConstantsContracts.SUPPRESSEDAPINAME);
        
    }
    
	/**********************************************************************************************
	@author         Accenture: Shivangi Gaur
	@date           13-Nov-2017
	@return         List<GLAp_FieldProps>
	@description    This method returns the field properties for each of the fields that are
	                to be displayed on the screen
	**********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveContractFieldPropDetails() {
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        try {
            //Get the field properties from the contract object
            List<GLAp_FieldProps> contractProps = GlAp_LightningDataAccess.getObjectsFieldProperties(BlAp_Constants.CONTRACTAPINAME, conFields);
            
            //Want to make all of the contract fields readonly
            for (GLAp_FieldProps conProp: contractProps) {
                conProp.isEditable = false;
                
                //Change table header for 'Contract Start Date' field to 'Start Date'
                if (conProp.fieldLabel == CuAp_Constants.CONTRACTSTARTDATELABEL) {
                    conProp.fieldLabel = CuAp_Constants.STARTDATELABEL;
                }
                //Change table header for 'Contract End Date' field to 'End Date'
                if (conProp.fieldLabel == CuAp_Constants.CONTRACTENDDATELABEL) {
                    conProp.fieldLabel = CuAp_Constants.ENDDATELABEL;
                }
            }
            
            //Build a map list of all field properties
            
            for (GLAp_FieldProps fldProp : contractProps) {
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
	@author         Accenture: Shivangi Gaur
	@date           13-Nov-2017
	@param          string customerId
	@param          string moveInDate (yyyy-mm-dd)
	@return         List<BlAp_CombinedRecord>
	@description    This method takes the customerId to return all contracts associated to it.
	@revision(s)	22 Jan 2018, P Dixon - exclude contracts that start after the move in date
	**********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveContractSuppressions(String customerId, String moveInDate) {
        
        List<BlAp_CombinedRecord> contractSuppressList = new List<BlAp_CombinedRecord>();
        try {
            //Query for all contracts under the account
            List<BillingContract__c> conList = (List<BillingContract__c>) GlAp_LightningDataAccess.getRecords(BlAp_Constants.CONTRACTAPINAME, 
                                                                                                conFields, 
                                                                                                customerId, 
                                                                                                GlUt_APIConstantsContracts.CUSTOMERAPINAME, 
                                                                                                String.format('{0} = {1} AND {2} <= {3}', 
                                                                                                              new List<String>{
                                                                                                                  GlUt_APIConstantsContracts.STATUSAPINAME, 
                                                                                                                      GlUt_FieldSecurity.QuotedString(CuAp_Constants.STATUSACTIVE), 
                                                                                                                      GlUt_APIConstantsContracts.STARTDATE, 
                                                                                                                      moveInDate}));
            
            List<Id>contractIds = new List<Id>();
            for (BillingContract__c objContract : conList) {
                contractIds.add(objContract.Id);
            }       
            
            //Loop throught the contract list and add to list of BlAp_CombinedRecord
            for (BillingContract__c con : conList) {
                
                BlAp_CombinedRecord supContract = new BlAp_CombinedRecord();            
                supContract.uniqueId = con.Id;
                supContract.isSelected = false;
                supContract.objectMap = new Map<string, sObject>();
                supContract.objectMap.put(BlAp_Constants.CONTRACTAPINAME, con);
                contractSuppressList.add(supContract);            
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return contractSuppressList;
    }
}