/******************************************************************************
@author    		Echo: Patrick Dixon
@date      		07 Mar 2018
@description 	Component controller for record list title with icon lightning component

@revision(s)		
*******************************************************************************/
public with sharing class GlAp_RecordListTitleWithIconCtrlr {
	
	private static final String CLASS_NAME = 'GlAp_RecordListTitleWithIconCtrlr';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
	
	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		20 Feb 2018
	@param			String - the object api name
	@return			Map<String, String> - map of the object properties including the icon URL
	@description 	gets the properties of an object including the small (120px width) icon URL
					the object must be visible in an app
	*******************************************************************************/
    private static Map<String, String> smallIconsMap;		// map of icon URLs keyed on object's plural name
    public static Map<String, String> getObjectProperties(String objectName) {

		if (String.isBlank(objectName)) return null;
		Map<String, String> objectMap = new Map<String, String>();
		String label = Schema.getGlobalDescribe().get(objectName).getDescribe().getLabel();
		objectMap.put('label', label);
		String labelPlural = Schema.getGlobalDescribe().get(objectName).getDescribe().getLabelPlural();
		objectMap.put('labelPlural', labelPlural);

        if (smallIconsMap == null) {
            smallIconsMap = new Map<String, String>();
                        
            // Iterate through each tab set
            for (Schema.DescribeTabSetResult tsr : Schema.describeTabs()) {               
                for (Schema.DescribeTabResult tab : tsr.getTabs()) {                    
                    for (Schema.DescribeIconResult icon : tab.getIcons()) {                    
                        if (!smallIconsMap.keySet().contains(tab.getLabel()) && icon.getWidth() == 120) {
                            smallIconsMap.put(tab.getLabel(), icon.getURL());
                        }
                    }
                }
            }
        }
        
        system.debug('102...' + smallIconsMap.get('Service Types'));
		objectMap.put('iconURL', smallIconsMap.get(labelPlural));
		return objectMap;
    }

	/******************************************************************************
	@author    		Echo: Patrick Dixon
	@date      		27 Feb 2018
	@param			String - the object api name
	@return			Map<String, String> - map of the object properties including the icon URL
	@description 	gets the properties of an object including the small (120px width) icon URL
	*******************************************************************************/
	@AuraEnabled
    public static Map<String, String> retrieveObjectProperties(String objectName) {
		return getObjectProperties(objectName);
    }

}