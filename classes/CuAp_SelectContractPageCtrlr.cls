/******************************************************************************
@author         Accenture: Vivek Chauan
@date           10 Nov 2017
@description    Component controller for SelectContractPage lightning component
Revision(s)		08 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class CuAp_SelectContractPageCtrlr {
    
    public static List<string> conFields;
    private static final String CLASS_NAME = 'CuAp_SelectContractPageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    static{
        //Get Fields from the Contact Object
        conFields = new List<string>();
        conFields.add(GlUt_APIConstantsContracts.CONTRACTNAMEAPINAME);
        conFields.add(GlUt_APIConstantsContracts.STATUSAPINAME);
        conFields.add(GlUt_APIConstantsContracts.CONTRACTSTARTDATEAPINAME);
        conFields.add(GlUt_APIConstantsContracts.CONTRACTENDDATEAPINAME);
        conFields.add(GlUt_APIConstantsContracts.SUPPRESSEDAPINAME);        
    }    
    
    /**********************************************************************************************
    @author         Accenture: vivek chauhan
    @date           14-Nov-2017
    @return         List<GLAp_FieldProps>
    @description	This method returns the field properties for each of the fields that are
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
    @author         Accenture: Vivek chauhan
    @date           14-Nov-2017
    @param          string customerId
    @return         List<BlAp_SupressContracts>
    @description    This method takes the customerId to return all contracts  records in a combined list of wrapper objects
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveContracts(string customerId) {
        List<BlAp_CombinedRecord>  contractSupressList = new List<BlAp_CombinedRecord>();
        
        try {
            //Query for all contracts under the account
            List<BillingContract__c> conList = (List<BillingContract__c>) GlAp_LightningDataAccess.getRecords(BlAp_Constants.CONTRACTAPINAME, 
                                                                                                conFields, 
                                                                                                customerId, 
                                                                                                GlUt_APIConstantsContracts.CUSTOMERAPINAME, 
                                                                                                String.format('{0} = {1}', 
                                                                                                new List<String>{
                                                                                                GlUt_APIConstantsContracts.STATUSAPINAME, 
                                                                                                GlUt_FieldSecurity.QuotedString(CuAp_Constants.STATUSACTIVE)}));
            
            for (BillingContract__c con : conList) {
                
                BlAp_CombinedRecord supContract = new BlAp_CombinedRecord();            
                supContract.uniqueId = con.Id;
                supContract.isSelected = false;
                supContract.objectMap = new Map<string, sObject>();
                supContract.objectMap.put(BlAp_Constants.CONTRACTAPINAME, con);
                contractSupressList.add(supContract);
                
            }
            system.debug(JSON.serialize(contractSupressList));
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return contractSupressList;        
    }
}