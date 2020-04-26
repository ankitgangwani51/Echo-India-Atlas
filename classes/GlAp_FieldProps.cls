/************************************************************************************************************
@author    		Accenture : Luke Emberton
@date      		24-Aug-2017
@description: 	This is the properties class for holding field information for data queried from the database
Revision(s)		01 Mar 2018, P Dixon - updated to support parent relationship fields
**************************************************************************************************************/
public class GlAp_FieldProps {
    	
    private static final String CLASS_NAME = 'GlAp_FieldProps';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

	@AuraEnabled
	public boolean isFLSVisible{get;set;}
	
	@AuraEnabled
	public boolean isEncrypted{get;set;}
	
	@AuraEnabled
	public boolean isEditable{get;set;}
	
	@AuraEnabled
	public boolean isRequired{get;set;}

	@AuraEnabled
	public string fieldName{get;set;}
	
	@AuraEnabled
	public string fieldLabel{get;set;}
	
	@AuraEnabled
	public List<string> pickListValues{get;set;}
	
	@AuraEnabled
	public Map<string, string> pickListEntries{get;set;}
	
	@AuraEnabled
	public string fieldType{get; set;}
	
	@AuraEnabled
	public boolean transformField{get;set;}
	
	@AuraEnabled
	public boolean buttonField{get;set;}
	
	@AuraEnabled
	public string parentObject{get; set;}

    // 01 Mar 2018, Tarun - Added for the outputField Component
	@AuraEnabled
	public Boolean showLabel{get; set;} 
    
    // 04 Mar 2018, A Edge - fire a GlAp_GenericInputEvent event when this field changes
    @AuraEnabled
	public Boolean changeEvent{get; set;} 
    
    // 01 Mar 2018, P Dixon - added to support parent relationship fields
	public string fieldPath {get; set;}
    
    // 08 Mar 2018, Tarun - Added new variable for edit mode in Generic Field
	@AuraEnabled
	public Boolean editMode{get; set;}

	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		14 Feb 2018
	@param			Boolean isFLSVisible
	@param			Boolean isEncrypted
	@param			Boolean isEditable
	@param			Boolean isRequired
	@param			String fieldName
	@param			String fieldLabel
	@param			String fieldType
	@param			Boolean transformField
	@param			Boolean buttonField
	@param			String parentObject
	@description 	constructors
	*******************************************************************************/
    public GlAp_FieldProps() {
    }
    
    public GlAp_FieldProps(String fieldName, String fieldLabel, Boolean transformField, String parentObject) {		// text read only field
    	this(true, false, false, false, fieldName, fieldLabel, 'text', transformField, parentObject);
    }
    
    public GlAp_FieldProps(String fieldName, String fieldLabel, Boolean buttonField) {		// button field
    	this(false, false, false, false, fieldName, fieldLabel, null, false, buttonField, null);
    }
    
    public GlAp_FieldProps(Boolean isFLSVisible, Boolean isEncrypted, Boolean isEditable, Boolean isRequired, 
    						String fieldName, String fieldLabel, String fieldType, Boolean transformField, String parentObject) {
    	this(isFLSVisible, isEncrypted, isEditable, isRequired, fieldName, fieldLabel, fieldType, transformField, false, parentObject);
    }
    
    public GlAp_FieldProps(Boolean isFLSVisible, Boolean isEncrypted, Boolean isEditable, Boolean isRequired, 
    						String fieldName, String fieldLabel, String fieldType, Boolean transformField, Boolean buttonField, String parentObject) {

		this.isFLSVisible = isFLSVisible;
        this.isEncrypted = isEncrypted;
        this.isEditable = isEditable;
        this.isRequired = isRequired;
        this.fieldName = fieldName;
        this.fieldLabel = fieldLabel;
        this.fieldType = fieldType;
        this.transformField = transformField;
        this.buttonField = buttonField;
        this.parentObject = parentObject;
    }	
	
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           07 Mar 2018
	@param          String - the parent object api name
    @param          String - field name with path
    @description    constructor to populate parent object and field name from a
    				field name with path (ie including parent reference(s))
    *******************************************************************************/
    public GlAp_FieldProps(String objectName, String fieldPath) {
        this.fieldPath = fieldPath;
        // initialise the field's parent object
        parentObject = objectName;
        // split the query field into a list of its parent objects and its field name
        List<String> fieldNameElements = fieldPath.normalizeSpace().split('\\.');
        for (Integer i = 0; i < fieldNameElements.size(); i++) {
            // the last element is the actual field name
            if (i == fieldNameElements.size() - 1) {
                fieldName = fieldNameElements[i];
                // other elements are parent object references
            } else {
                // so update the parent object
                Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(parentObject).getDescribe().fields.getMap();
                if(fieldNameElements[i].contains('__r')){ // CLB-125- Issues identified by Clayton- 08-04-2019 -> Updated by Dependra Singh
                    Schema.SObjectField fieldResult = fieldMap.get(fieldNameElements[i].replace('__r', '__c'));
                    for (Schema.SObjectType reference : fieldResult.getDescribe().getReferenceTo()) {
                        parentObject = reference.getDescribe().getName();
                    }
                }
            }
        }
    }
	
	/**********************************************************************************************
	@author      	Accenture: Luke Emberton
	@date      		18-Aug-2017
	@param			DisplayType fldType
	@return			void
	@description	This method is used to set the field Type based on a transformation of the
					Schema field type passed in so that it can be easily evaluated in java script
					in the lightning component controllers
	**********************************************************************************************/
	public void setFieldType(DisplayType fldType) {

        // Need to complete, not all field types supported below in the mapping
        if (fldType == Schema.DisplayType.STRING || fldType == Schema.DisplayType.ID ) fieldType = 'text';
        else if (fldType == Schema.DisplayType.EMAIL) fieldType = 'email';
        else if (fldType == Schema.DisplayType.PHONE) fieldType = 'tel';
        else if (fldType == Schema.DisplayType.URL) fieldType = 'url';
        else if (fldType == Schema.DisplayType.CURRENCY) fieldType = 'currency';
    	else if (fldType == Schema.DisplayType.INTEGER || fldType == Schema.DisplayType.DOUBLE) fieldType = 'number';
    	else if (fldType == Schema.DisplayType.BOOLEAN) fieldType = 'checkbox';
		else if (fldType == Schema.DisplayType.DATE) fieldType = 'date';
		else if (fldType == Schema.DisplayType.DATETIME) fieldType = 'datetime-local';
		else if (fldType == Schema.DisplayType.MULTIPICKLIST) fieldType = 'MultiPicklist';
		else if (fldType == Schema.DisplayType.PICKLIST) fieldType = 'select';
        else if (fldType == Schema.DisplayType.COMBOBOX) fieldType = 'combobox';
        else if (fldType == Schema.DisplayType.PERCENT) fieldType = 'percent';
        else if (fldType == Schema.DisplayType.REFERENCE) fieldType = 'reference';
        else if (fldType == Schema.DisplayType.TEXTAREA) fieldType = 'TextArea';
        else fieldType = 'unsupported';
    }
}