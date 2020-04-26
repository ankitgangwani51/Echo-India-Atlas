/******************************************************************************
@author         Accenture: Luke Emberton
@date           03 Oct 2017
@description    Component controller for suppression lightning component
@Revisions		09 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class CuAp_SuppressionWizardCtrlr {
    
    private static final String CLASS_NAME = 'CuAp_SuppressionWizardCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static final String SUCCESS = 'SUCCESS';

    @testVisible private static List<string> supFields;
    @testVisible private static List<string> conFields;
    
    private static boolean fieldsInitialised = false;
    
    static {

        // Get Fields from the Suppression Object
        // TO-DO - these need to be constants/labels
        supFields = new List<string>();
        supFields.add(CuAp_Constants.FIELDAPISUPPRESSIONREASON);
        supFields.add(CuAp_Constants.FIELDAPISUPPRESSIONSTARTDATE);
        supFields.add(CuAp_Constants.FIELDAPISUPPRESSIONENDDATE);
        supFields.add(CuAp_Constants.FIELDAPISUPPRESSIONBILLPRINT);
        supFields.add(CuAp_Constants.FIELDAPISUPPRESSIONRECOVERYNOTICE);
        
        // Get Fields from the Contact Object
        conFields = new List<string>();
        conFields.add(CuAp_Constants.FIELDAPICONTACTNAME);
        conFields.add(CuAp_Constants.FIELDAPICONTACTSTATUS);
        conFields.add(CuAp_Constants.FIELDAPICONTACTBILLINGFREQUENCY);
    }
    
	/**********************************************************************************************
	@author         Accenture: Luke Emberton
	@date           04-Sep-2017
	@return         List<GLAp_FieldProps>
	@description    This method returns the field properties for each of the fields that are
	                to be displayed on the screen
	@revision		Echo: Gopal Gupta - Commented out the label change if conditions because the labels are already modified on the object itself
	**********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveSuppFieldPropDetails() {
        
        // Get the field properties for the suppression object
        List<GLAp_FieldProps> suprProps = GlAp_LightningDataAccess.getObjectsFieldProperties(BlAp_Constants.SUPRESSIONAPINAME, supFields);
        
        // Get the field properties from the contract object
        List<GLAp_FieldProps> contractProps = GlAp_LightningDataAccess.getObjectsFieldProperties(BlAp_Constants.CONTRACTAPINAME, conFields);
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        
        try {
            //Want to make all of the contract fields readonly
            for(GLAp_FieldProps conProp: contractProps) {
                conProp.isEditable = false;
            }
            
            //Build a map list of all field properties
            for (GLAp_FieldProps fldProp : contractProps) {
                fldPropList.add(fldProp); 
            }
            for (GLAp_FieldProps fldProp : suprProps) {
                if (fldProp.fieldLabel == CuAp_Constants.FIELDVALUESUPPRESSIONENDDATE) {
                    //fldProp.fieldLabel = CuAp_Constants.FIELDSHOWVALUESUPPRESSIONENDDATE;
                    
                } else if (fldProp.fieldLabel == CuAp_Constants.FIELDVALUESUPPRESSIONSTARTDATE) {
                    //fldProp.fieldLabel = CuAp_Constants.FIELDSHOWVALUESUPPRESSIONSTARTDATE;
                    
                } else if (fldProp.fieldLabel == CuAp_Constants.FIELDVALUESUPPRESSIONREASON) {
                    //fldProp.fieldLabel = CuAp_Constants.FIELDSHOWVALUESUPPRESSIONREASON;
                    
                } else if (fldProp.fieldLabel == CuAp_Constants.FIELDVALUESUPPRESSIONBILLPRINT) {
                    fldProp.fieldLabel = CuAp_Constants.FIELDSHOWVALUESUPPRESSIONBILLPRINT;
                    
                } else if (fldProp.fieldLabel == CuAp_Constants.FIELDVALUESUPPRESSIONRECOVERYNOTICE) {
                    //fldProp.fieldLabel = CuAp_Constants.FIELDSHOWVALUESUPPRESSIONRECOVERYNOTICE;
                }
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
    @author         Accenture: vivek chauhan
    @date           05-Oct-2017
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the fields that are
                    to be displayed on the screen for Account suppression
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveSuppAccountFieldPropDetails(){
        
        // Get the field properties for the suppression object
        List<GLAp_FieldProps> suprProps = GlAp_LightningDataAccess.getObjectsFieldProperties(BlAp_Constants.SUPRESSIONAPINAME, supFields);
        
        // Build a map list of all field properties
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        try {
            for (GLAp_FieldProps fldProp : suprProps) {
                
                if (fldProp.fieldLabel == CuAp_Constants.FIELDVALUESUPPRESSIONENDDATE) {
                    //fldProp.fieldLabel = CuAp_Constants.FIELDSHOWVALUESUPPRESSIONENDDATE;
                    
                } else if (fldProp.fieldLabel == CuAp_Constants.FIELDVALUESUPPRESSIONSTARTDATE) {
                    //fldProp.fieldLabel = CuAp_Constants.FIELDSHOWVALUESUPPRESSIONSTARTDATE;
                    //fldProp.isEditable = false;
                    
                } else if (fldProp.fieldLabel == CuAp_Constants.FIELDVALUESUPPRESSIONREASON) {
                    //fldProp.fieldLabel = CuAp_Constants.FIELDSHOWVALUESUPPRESSIONREASON;
                    
                } else if (fldProp.fieldLabel == CuAp_Constants.FIELDVALUESUPPRESSIONBILLPRINT) {
                    fldProp.fieldLabel = CuAp_Constants.FIELDSHOWVALUESUPPRESSIONBILLPRINT;
                    
                } else if (fldProp.fieldLabel == CuAp_Constants.FIELDVALUESUPPRESSIONRECOVERYNOTICE) {
                    //fldProp.fieldLabel = CuAp_Constants.FIELDSHOWVALUESUPPRESSIONRECOVERYNOTICE;
                }
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
    @author         Accenture: Luke Emberton
    @date           04-Sep-2017
    @param          string customerId
    @return         List<BlAp_CombinedRecord>
    @description    This method takes the customerId to return all contracts and associated
                    suppressions records in a combined list of wrapper objects
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveContractSuppressions(string customerId) {

        List<BlAp_CombinedRecord> contractSuppressionList = new List<BlAp_CombinedRecord>();

        // Query for all contracts under the account that are not inactive with no debt
		List<BillingContract__c> conList = (List<BillingContract__c>) GlAp_LightningDataAccess.getRecords(BlAp_Constants.CONTRACTAPINAME, 
																							conFields, 
																							customerId, 
																							GlUt_APIConstantsContracts.CUSTOMERAPINAME, 
																							String.format('{0} != {1}', 
																								new List<String>{
																									GlUt_APIConstantsContracts.STATUSAPINAME, 
																									GlUt_FieldSecurity.QuotedString(Label.GlAp_ContractStatusInactiveNoDebt)}));

        List<Id>contractIds = new List<Id>();
        for (BillingContract__c objContract : conList) {
            contractIds.add(objContract.Id);
        }      
        // Query for active contract suppressions under the account
        String dateToday  = String.valueOf(Date.today());
		List<String> suppressionFields = new List<String>{CuAp_Constants.CONTRACTAPINAME};
		suppressionFields.addAll(supFields);
		List<Suppression__c> supList = (List<Suppression__c>) GlAp_LightningDataAccess.getRecords(BlAp_Constants.SUPRESSIONAPINAME, 
																								suppressionFields, 
																								String.format('WHERE {0} IN {1} AND {2} <= {3} AND ({4} = null OR {5} > {6})', 
																									new List<String>{
																										CuAp_Constants.CONTRACTAPINAME, 
																										GlUt_FieldSecurity.IdsToString(contractIds), 
																										GlUt_APIConstantsSuppression.SUPPRESSIONSTARTDATEAPINAME, 
																										dateToday, 
																										GlUt_APIConstantsSuppression.SUPPRESSIONENDDATEAPINAME, 
																										GlUt_APIConstantsSuppression.SUPPRESSIONENDDATEAPINAME, 
																										dateToday}));
        
        // Loop through the list of suppressions and add to a Map of Contract Id to suppressions
        Map<Id, Suppression__c> conSupMap = new Map<Id, Suppression__c>();
        for (Suppression__c sup: supList) {
            conSupMap.put(sup.BillingContract__c, sup);
        }
        
        // Loop throught the contract list and capture the appropriate suppression information
        for (BillingContract__c con : conList) {
            boolean isSuppressed = false;
            Suppression__c sup = new Suppression__c();
            sup.SuppressionReason__c = '';
            sup.SuppressionStartDate__c = system.today();

            if (conSupMap.containsKey(con.Id)) {
                sup = conSupMap.get(con.Id);
                isSuppressed = true;
            }
            
            BlAp_CombinedRecord supContract = new BlAp_CombinedRecord();            
            supContract.uniqueId = con.Id;
            supContract.isSelected = isSuppressed;
            supContract.objectMap = new Map<string, sObject>();
            supContract.objectMap.put(BlAp_Constants.CONTRACTAPINAME, con);
            supContract.objectMap.put(BlAp_Constants.SUPRESSIONAPINAME, sup);                                   
            contractSuppressionList.add(supContract);          
        }
        
        return contractSuppressionList;
    }
    
    /**********************************************************************************************
    @author         Accenture: Vivek Chauhan
    @date           05-Oct-2017
    @param          string customerId
    @return         List<BlAp_CombinedRecord>
    @description    This method takes the customerId to return all account
                    suppressions records in a combined list of wrapper objects
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveAccountSuppressions(string customerId) {

        List<BlAp_CombinedRecord> accountSuppressionList = new List<BlAp_CombinedRecord>();
        String dateToday  = String.valueOf(Date.today());
		List<String> suppressionFields = new List<String>{CuAp_Constants.CONTRACTAPINAME, GlUt_APIConstantsSuppression.ACCOUNTAPINAME};
		suppressionFields.addAll(supFields);
		List<Suppression__c> supList = (List<Suppression__c>) GlAp_LightningDataAccess.getRecords(BlAp_Constants.SUPRESSIONAPINAME, 
																								suppressionFields, 
																								customerId, 
																								GlUt_APIConstantsSuppression.ACCOUNTAPINAME, 
																								String.format('{0} <= {1} AND ({2} = null OR {3} > {4})', 
																									new List<String>{
																										GlUt_APIConstantsSuppression.SUPPRESSIONSTARTDATEAPINAME, 
																										dateToday, 
																										GlUt_APIConstantsSuppression.SUPPRESSIONENDDATEAPINAME, 
																										GlUt_APIConstantsSuppression.SUPPRESSIONENDDATEAPINAME, 
																										dateToday}));

        // Loop through the list of suppressions and add to a Map of Contract Id to suppression Id
        Map<Id, Suppression__c> accSupMap = new Map<Id, Suppression__c>();
        for (Suppression__c sup: supList) {
            accSupMap.put(sup.Account__c, sup);
        }
        boolean isSuppressed = false;
        Suppression__c sup = new Suppression__c();
        sup.SuppressionReason__c = '';
        sup.SuppressionStartDate__c = system.today();

        if (accSupMap.containsKey(customerId)) {
            sup = accSupMap.get(customerId);
            isSuppressed = true;
        }
        BlAp_CombinedRecord supAccount = new BlAp_CombinedRecord();            
        supAccount.uniqueId = customerId;
        supAccount.isSelected = isSuppressed;
        supAccount.objectMap = new Map<string, sObject>();
        supAccount.objectMap.put(BlAp_Constants.SUPRESSIONAPINAME, sup);                                   
        accountSuppressionList.add(supAccount);
        return accountSuppressionList;
    }
    
    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           04-Sep-2017
    @param          string suppressionsString
    @param          string customerId
    @return         void
    @description    This method takes a string to work around lightning component issue of not
                    being able to accept a list parameter. It processes the various contracts
                    which are marked for suppression and then either creates or updates the 
                    corresponding suppression record
    **********************************************************************************************/
    @AuraEnabled
    public static string saveSuppressions(string suppressionsString, string customerId) {    
        string retVal = SUCCESS;
        List<Suppression__c> suppressionsToInsert = new List<Suppression__c>();
        List<Suppression__c> suppressionsToUpdate = new List<Suppression__c>();
        List<BillingContract__c> contractToUpdate = new List<BillingContract__c>();
        Account objAccount;
        // Deserialise the JSON String into a list of contractSupressRecords
        List<BlAp_CombinedRecord> contractSuppressionList = (List<BlAp_CombinedRecord>)JSON.deserialize(suppressionsString, List<BlAp_CombinedRecord>.class);
        System.debug('contractSuppressionList = '+contractSuppressionList);
        // Loop over the list of contract suppressions
        for (BlAp_CombinedRecord conSupr : contractSuppressionList) {
            boolean isSuppressed = conSupr.isSelected;
            Suppression__c sup = (Suppression__c)conSupr.objectMap.get(BlAp_Constants.SUPRESSIONAPINAME);
            System.debug('sup = '+sup);
            BillingContract__c con = (BillingContract__c)conSupr.objectMap.get(BlAp_Constants.CONTRACTAPINAME);
            System.debug('con = '+con);
            if (sup.id != null) {
                if (sup.SuppressionEndDate__c <= system.today()) {

                    if (con != null) {
                        con.Suppressed__c = false;
                        contractToUpdate.add(con);
                    
                    } else {
                        objAccount = new Account(Id = customerId, Suppressed__c = false);
                    }
                }
                suppressionsToUpdate.add(sup);

            } else if (isSuppressed) {
                if (con != null) {
                    sup.BillingContract__c = con.Id;
                    con.Suppressed__c = true;
                    contractToUpdate.add(con);
                } else {
                    sup.Account__c = customerId;
                    objAccount = new Account (Id = customerId, Suppressed__c = true);
                }
                suppressionsToInsert.add(sup);
            }
        } 
        try {
            // Check the field security on the records to be upserted
            suppressionsToInsert = GlUt_FieldSecurity.cleanseFields(suppressionsToInsert, false);
            suppressionsToUpdate = GlUt_FieldSecurity.cleanseFields(suppressionsToUpdate, false);
            contractToUpdate = GlUt_FieldSecurity.cleanseFields(contractToUpdate, false);
            
            if(objAccount != null)
                objAccount = (Account)GlUt_FieldSecurity.cleanseFields(objAccount, false);

            if (suppressionsToInsert != null && suppressionsToInsert.size() > 0) {  //***Code added by Ashish Tiwari on 11/01/2018**/
                insert suppressionsToInsert;
            }
    
            if (suppressionsToUpdate != null && suppressionsToUpdate.size() > 0) {  //***Code added by Ashish Tiwari on 11/01/2018**/
                update suppressionsToUpdate;
            }
       
            if (contractToUpdate != null && contractToUpdate.size() > 0) {  
                //MT - changed from suppressionsToUpdate to contractToUpdate on 14/02/2018
                update contractToUpdate;
            }
            if (objAccount != null) {
            	update objAccount;
            }

        } catch (Exception ex) {
             GlUt_Logger.logException(ex);
             String errorMsg = ex.getMessage();
             retVal = 'Error while Saving Suppression Record:' + errorMsg.split(':')[1].split(',')[1];
            
        }
        finally {   
           GlUt_Logger.writeLogsToDatabase();
        }
        return retVal;
    }
}