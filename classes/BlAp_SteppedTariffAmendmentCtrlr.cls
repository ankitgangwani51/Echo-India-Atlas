/************************************************************************************************************
@author      : Echo: Ankit Gangwani
@date        : 20 July 2018
@description : BlAp_SteppedTariffAmendmentCtrlr class is used to display stepped tariff fields
**************************************************************************************************************/
public with sharing class BlAp_SteppedTariffAmendmentCtrlr {
    
    private static List<String> steppedTariffFields;    
    private static List<String> steppedTariffServiceFields;
    private static final String CLASS_NAME = LoAp_Constants.STAmendmentClassLabel;
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    static{
        //Get Fields from the Discount Object
        steppedTariffFields = new List<string>();
        steppedTariffFields.add(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME);           
        steppedTariffFields.add(GlUt_APIConstantsSteppedTariff.STARTDATEAPINAME);
        steppedTariffFields.add(GlUt_APIConstantsSteppedTariff.ENDDATEAPINAME);        
        
        steppedTariffServiceFields = new List<String>();
        steppedTariffServiceFields.add(LoAp_Constants.Id);
        steppedTariffServiceFields.add(GlUt_APIConstantsSteppedTariff.STEPPEDTARIFFAPINAME);
    }
    
    /**********************************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 20 July 2018
    @return      : List<GLAp_FieldProps>
    @description : This method returns the field properties for each of the fields that are
    to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<GlAp_FieldProps> retrieveSteppedTariffFields() {
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
            List<GLAp_FieldProps> allFieldProp = new List<GLAp_FieldProps>();            
            
            // get the fields properties of stepped tariff fields 
            List<GLAp_FieldProps> steppedTariffProp = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsSteppedTariff.STEPPEDTARIFFAPINAME, steppedTariffFields); 
            
            for(GlAp_FieldProps fieldProp:steppedTariffProp){
                fieldProp.isEditable = false;
                fieldProp.editMode = false;
                allFieldProp.add(fieldProp);
            }
            
            // Create the Location read-only field to show the the no of locations per stepped tariff record
            GlAp_FieldProps serviceTypePicklist = new GlAp_FieldProps();
            serviceTypePicklist.isFLSVisible = true;
            serviceTypePicklist.isEditable = false;
            serviceTypePicklist.editMode = false;
            serviceTypePicklist.fieldName = CuAp_Constants.LOCAITONFIELDANDLABEL;
            serviceTypePicklist.fieldLabel = CuAp_Constants.LOCAITONFIELDANDLABEL;
            serviceTypePicklist.fieldType = 'text';
            serviceTypePicklist.isRequired = false;
            serviceTypePicklist.changeEvent = false;
            serviceTypePicklist.transformField = true;
            serviceTypePicklist.parentObject = GlUt_APIConstantsLocation.LOCATIONAPINAME;            
            allFieldProp.add(serviceTypePicklist);
            
            return allFieldProp;
        }catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }   
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /**********************************************************************************************
    @author      : Echo : Ankit Gangwani
    @date        : 20 July 2018
    @param       : String ContractId
    @return      : List<BlAp_CombinedRecord>
    @description : This method returns the BlAp_CombinedRecord with list of Stepped Tariff, Total Count of Stepped Tariff Services Records
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveSteppedTariffRecords(String ContractId) {
            
        try {     
            Integer noOfSteppedTariffServices;
            List<BlAp_CombinedRecord> returnSteppedTariffRecords = new List<BlAp_CombinedRecord>();
            Set<Id> steppedTariffIds = new Set<Id>();
            Map<Id,Integer> mapOfSTId2Locations = new Map<Id,Integer>();
            /* Claytone Review: Sudhir commented dynamic query and used GlAp_LightningDataAccess
            String soqlQuery ='';            
            soqlQuery = String.format('SELECT {0} FROM {1}', new List<String>{LoAp_Constants.Id + ',' + 
                String.join(steppedTariffFields,','), GlUt_APIConstantsSteppedTariff.STEPPEDTARIFFAPINAME + 
                ' WHERE ' + GlUt_APIConstantsContracts.CONTRACTAPINAME + ' =\'' + String.escapeSingleQuotes(ContractId) + '\'' + 
                ' AND (' + GlUt_APIConstantsSteppedTariff.ENDDATEAPINAME + ' >= TODAY OR ' + 
                GlUt_APIConstantsSteppedTariff.ENDDATEAPINAME + ' = null)'});
            */
            String filterStatement = ' WHERE ' + GlUt_APIConstantsContracts.CONTRACTAPINAME + ' =\'' + String.escapeSingleQuotes(ContractId) + '\''
                                     + ' AND (' + GlUt_APIConstantsSteppedTariff.ENDDATEAPINAME + ' >= TODAY OR ' 
                                     + GlUt_APIConstantsSteppedTariff.ENDDATEAPINAME + ' = null)' ;
            List<SteppedTariff__c> steppedTariffList = (List<SteppedTariff__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSteppedTariff.STEPPEDTARIFFAPINAME,
                                                                                                                    steppedTariffFields,
                                                                                                                    filterStatement); 
			            
            
            
            // get all the stepped tariff records associated with contract
            //List<SteppedTariff__c> steppedTariffList = Database.query(soqlQuery);      
            
            // Iterate the stapped tariff records to get the ids
            for(SteppedTariff__c objST : steppedTariffList){
                steppedTariffIds.add(objST.Id);
            }     
            
            // get all the stepped tariff services records associated with stepped tariff record
            List<SteppedTariffService__c> steppedTariffServiceList = (List<SteppedTariffService__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSteppedTariffService.STEPPEDTARIFFSERVICEAPINAME,
                                                                                                                                         steppedTariffServiceFields,
                                                                                                                                         'WHERE ' + GlUt_APIConstantsSteppedTariff.STEPPEDTARIFFAPINAME + 
                                                                                                                                         ' IN ' + GlUt_FieldSecurity.IdsToString(steppedTariffIds)); 
            // Iterate the stepped tariff services records to get the count of no of stepped tariff services records on stepped tariff record
            for(SteppedTariffService__c objSTS : steppedTariffServiceList){
                
                if(!mapOfSTId2Locations.containsKey(objSTS.SteppedTariff__c)){
                    noOfSteppedTariffServices = 1;
                    mapOfSTId2Locations.put(objSTS.SteppedTariff__c,noOfSteppedTariffServices);                    
                }else{
                    noOfSteppedTariffServices+=1;
                    mapOfSTId2Locations.put(objSTS.SteppedTariff__c,noOfSteppedTariffServices);  
                }
            }
            
            for(SteppedTariff__c objST : steppedTariffList){
                BlAp_CombinedRecord steppedTariffComb = new BlAp_CombinedRecord();            
                steppedTariffComb.uniqueId = objST.Id;
                steppedTariffComb.isSelected = steppedTariffList.size() == 1 ? true : false;
                steppedTariffComb.readOnlyFields = new Map<string, boolean>();
                steppedTariffComb.objectMap	= new Map<string, sObject>();
                steppedTariffComb.objectMap.put(GlUt_APIConstantsSteppedTariff.STEPPEDTARIFFAPINAME, objST);
                Map<string, string> transFormFieldMap = new Map<string, string>();
                transFormFieldMap.put(CuAp_Constants.LOCAITONFIELDANDLABEL, String.valueOf(mapOfSTId2Locations.get(objST.Id)) != null ? String.valueOf(mapOfSTId2Locations.get(objST.Id)) : '0');
                steppedTariffComb.transformFieldMap = new Map<string,Map<string, string>>();
                steppedTariffComb.transformFieldMap.put(GlUt_APIConstantsLocation.LOCATIONAPINAME, transFormFieldMap); 
                returnSteppedTariffRecords.add(steppedTariffComb);
            }
            return returnSteppedTariffRecords;
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }        
    }    
}