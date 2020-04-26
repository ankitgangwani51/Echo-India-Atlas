/**********************************************************************************************
@author         Accenture: Luke Emberton
@date           09-Sep-2017
@description	xxx
Revision		29/12/17 - Added 'add-checkbox-' to BlAp_Constants
				09/04/18 - Tarun - Added 'customUrlLabel' to display label for URL type fields
				21 Jun 2018, P Dixon - added buttonAttributes to allow show/hide of buttons in tables
**********************************************************************************************/
public class BlAp_CombinedRecord {
	
	
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           12 Jun 2018
    @description    Class for button attributes
    *******************************************************************************/
	public class ButtonAttribute {
		@AuraEnabled
        public String name;		// name of column heading
		@AuraEnabled
        public String label;		// label for button
		@AuraEnabled
        public String status;		// ACTIVE/INACTIVE/DISABLED
        
	    /******************************************************************************
	    @author         Echo: Patrick Dixon
	    @date           12 Jun 2018
	    @description    Constructor
	    *******************************************************************************/
        public ButtonAttribute(String name, String label, String status) {
        	this.name = name;
         	this.label = label;
         	this.status = status;
        }
	}
        
    @AuraEnabled
    public boolean isSelected{get;set;}
        
    @AuraEnabled
    public string uniqueId{get;set;}
        
    @AuraEnabled
    public string checkboxId{
        get{
            return BlAp_Constants.ADDCHECKBOX + uniqueId;
        }
    }
        
    @AuraEnabled
    public Map<string, Sobject> objectMap{get;set;}
    
    @AuraEnabled
    public Map<string, List<Sobject>> lstSobjectMap{get;set;}
        
    @AuraEnabled
    public Map<string, Map<string, string>> transformFieldMap{get;set;}
        
    @AuraEnabled
    public Map<string, boolean> readOnlyFields{get;set;}
    
	@AuraEnabled
    public string customUrlLabel{get;set;}
    
	@AuraEnabled
    public List<ButtonAttribute> buttonAttributes {get; set;}
}