/************************************************************************************************************
@author    		Accenture : Luke Emberton
@date      		26-Aug-2017
@description: 	This class is used to create a copy of a SObject and remove or obfuscate inaccessible fields
Revision(s)		11 Apr 2018, P Dixon - revised to allow null value fields to be updated
				18 Apr 2018, P Dixon - rewritten to add accessible fields to an empty record 
				rather than removing inaccessible ones from a populated record, 
				and to make available for more general purpose use 
**************************************************************************************************************/
public class GlUt_ObjectUpdater {
    
    private static final String CLASS_NAME = 'GlUt_ObjectUpdater';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    @testVisible private String objectString;
    private String objectType;
	private Map<String, Object> recordMap; 
    
    /**********************************************************************************************
	@author      	Accenture: Luke Emberton
	@date      		26-Aug-2017
	@param			String objectType - the object API name
	@description	Constructor that takes the object type and builds a JSON string representation of the record
	**********************************************************************************************/	
    public GlUt_ObjectUpdater(String objectType) {
		recordMap = new Map<String, Object>(); 
    	this.objectType = objectType;

	    // serialise the revised object into the objectString field
    	objectString = JSON.serialize(recordMap);
    }

    /**********************************************************************************************
	@author      	Echo: Patrick Dixon
	@date      		16 Apr 2018
	@param			string fieldName
	@param			Object value - value of the field
	@description	Adds a field to the JSON string representation of the record
	**********************************************************************************************/
    public void addField(String fieldName, Object value) {
    	recordMap.put(fieldName, value);

	    // reserialise the revised object into the objectString field
    	objectString = JSON.serialize(recordMap); 		
    }
    
    /**********************************************************************************************
	@author      	Accenture: Luke Emberton
	@date      		26-Aug-2017
	@return			sObject
	@description	This method is used to get the updated sObject
	**********************************************************************************************/
    public sObject getSObject() {
		return (sObject)JSON.deserialize(objectString, Type.forName(objectType));
    }
}