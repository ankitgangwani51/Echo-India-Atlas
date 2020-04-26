/******************************************************************************
@author    		Echo: Patrick Dixon
@date      		02 Jul 2018
@description 	Component controller for related bills list lightning component
Revision(s)		
*******************************************************************************/
public with sharing class CuAp_RelatedBillsListCtrlr {
	
	private static final String CLASS_NAME = 'CuAp_RelatedBillsListCtrlr';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
	
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		02 Jul 2018
	@param			String - the name of the fieldset
	@return			List<GLAp_FieldProps> - list of field properties for device table
	@description 	get the field properties for the Device__c object
	*******************************************************************************/
	@AuraEnabled
    public static List<GLAp_FieldProps> retrieveFieldProperties(String fieldsetName) {
		List<GLAp_FieldProps> fieldPropertiesList;
		
		try {
	    	fieldPropertiesList = GlAp_LightningDataAccess.getObjectsFieldPropertiesByFieldSetName(GlUt_APIConstantsBill.BILLAPINAME, fieldsetName);
	    	
            // add the 'View PDF' button column Commented by Dependra- 16-01-2019- AT-5020
            //fieldPropertiesList.add(new GlAp_FieldProps(LoAp_Constants.ACTION, LoAp_Constants.ACTION, true));

	    	// make all fields read only
	    	for (GLAp_FieldProps fieldProperties : fieldPropertiesList) {
	    		fieldProperties.isEditable = false;
	    	}
	    	
	    	// TO-DO - add view PDF button column
	    	//		button will call view/generate component method, passing the bill Id to the aura method
	    	
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return fieldPropertiesList;
	}
 
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		02 Jul 2018
	@param			Id - the record Id
	@param			String - the name of the fieldset
	@return			List<BlAp_CombinedRecord> - list of combined device records to display
	@description 	get the list of device records to display
	*******************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveRecords(Id recordId, String fieldsetName) {
        System.debug(DEBUG + 'recordId: ' + recordId);
        List<BlAp_CombinedRecord> recordsToDisplay = new List<BlAp_CombinedRecord>();
        
        String orderByClause = 'order by ' + GlUt_APIConstantsBill.BILLDATEAPINAME + ' desc';
        try {
            // add the Bill PDF flag field to the fieldset to control rendering of the button
            List<String> fieldNames = GlAp_LightningDataAccess.getFieldSetFields(GlUt_APIConstantsBill.BILLAPINAME, fieldSetName);
            fieldNames.add(GlUt_APIConstantsBill.BILLPDFAPINAME);
            
            // check field accessibility and get the 'Normal' bills
            List<SObject> records = GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBill.BILLAPINAME, 
            															fieldNames, 
            															recordId, 
            															GlUt_APIConstantsBill.CONTRACTNUMBERAPINAME, 
            															'(' + GlUt_APIConstantsBill.BILL_TYPE + ' != ' + GlUt_FieldSecurity.QuotedString(Label.BlIn_BillTypePending) 
            															+ ' or ' + GlUt_APIConstantsBill.CURRENT + ' = true)', 
            															'order by ' + GlUt_APIConstantsBill.BILLDATEAPINAME + ', CreatedDate desc');
        	System.debug(DEBUG + 'records: ' + records);
                        

            // build the display list
            for (Bill__c record : (List<Bill__c>) records) {
                BlAp_CombinedRecord recordToDisplay = new BlAp_CombinedRecord();            
                recordToDisplay.uniqueId = record.Id;
                recordToDisplay.isSelected = false;
                recordToDisplay.readOnlyFields = new Map<String, Boolean>();
                recordToDisplay.objectMap = GlAp_LightningDataAccess.getRecordMapWithFields(GlUt_APIConstantsBill.BILLAPINAME, record);

                // initialise the button attributes
                recordToDisplay.buttonAttributes = new List<BlAp_CombinedRecord.ButtonAttribute>();
                
                // add view PDF button display attributes- Commented by Dependra- 16-01-2019- AT-5020
                /*String buttonLabel = record.BillPDF__c ? Label.BlAp_ViewPDFButton : Label.BlAp_GeneratePDFButton;
                            
                recordToDisplay.buttonAttributes.add(new BlAp_CombinedRecord.ButtonAttribute(LoAp_Constants.ACTION, 
                                                                                    buttonLabel, 
                                                                                    CuAp_Constants.BUTTON_ACTIVE));
                system.debug(DEBUG + 'recordToDisplay.buttonAttributes: ' + recordToDisplay.buttonAttributes);*/

                recordsToDisplay.add(recordToDisplay);           
                System.debug(DEBUG + 'recordToDisplay: ' + recordToDisplay);
            }
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return recordsToDisplay;
    }
}