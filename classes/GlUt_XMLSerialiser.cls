/******************************************************************************
@author         Echo: Patrick Dixon
@date           18 May 2018
@description    Class to create an XML document
*******************************************************************************/
public with sharing class GlUt_XMLSerialiser {
    
    private static final String CLASS_NAME = 'GlUt_XMLSerialiser';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    // XML tags
    private static final String VERSION = '1.0';
    private static final String ENCODING = 'UTF-8';     // all fields are UTF-8 encoded
    private static final String TYPE = 'type';
    
    // prefix for attribute field names
    private static final String ATTRIBUTE_PREFIX = 'attr_';
    
    public static List<String> XMLList {get; private set;}		// list of the XML elements


    /******************************************************************************
	@author         Echo: Patrick Dixon
	@date           25 May 2018
    @param          Object - root class for XML serialisation
    @param          Map<String, String> - Type attribute map
    @description    Constructor
    *******************************************************************************/
	public static String serialize(Object data) {
		
		// initialise the list
		XMLList = new List<String>();
		Integer index = 0;
		XMLList.add('<?xml version="' + VERSION + '" encoding="' + ENCODING + '"?>');
		
		// add a dummy string at the end of the list to give us a valid index position to add to
		XMLList.add('EOF');
		
		// build the list
		addXMLObject(++index, data.toString(), data);
		
		// remove the dummy string at the end of the list
		XMLList.remove(XMLList.size()-1);
		
		// concatenate the strings to give us the XML string
		return String.join(XMLList, '');
	}

    /******************************************************************************
	@author         Echo: Patrick Dixon
	@date           18 May 2018
    @param          Integer - nodeIndex (position of parent opening tag in list)
    @param          Integer - index (position to add new element in list)
    @param          String - name of the field/attribute
    @param          String - value of the field/attribute
    @description    adds a field node at the index position or an attribute to the parent opening tag
    *******************************************************************************/
	private static void addXMLField(Integer nodeIndex, Integer index, String fieldName, String fieldValue) {
		// add attribute to the parent tag
		if (fieldName.startsWith(ATTRIBUTE_PREFIX)) {
			String attributeName = fieldName.substringAfter(ATTRIBUTE_PREFIX);
			XMLList[nodeIndex] = XMLList[nodeIndex].replace('>', ' ' + attributeName + '="' + EncodingUtil.urlEncode(fieldValue, ENCODING) + '"' + '>');
	
		// add field as new node
		} else {
			XMLList.add(index++, '<' + fieldName + '>');
			XMLList.add(index++, EncodingUtil.urlEncode(fieldValue, ENCODING));
			//XMLList.add(index++, fieldValue);
			XMLList.add(index++, '</' + fieldName + '>');
		}
        system.debug('XMLList=> ' + XMLList) ;
	}
    
	/******************************************************************************
	@author         Echo: Patrick Dixon
	@date           18 May 2018
    @param          Integer - position to add object in list
    @param          String - name of the object node
    @param          Object - the structured object (class heirachy)
    @description    adds an object node to the XML list
    *******************************************************************************/
    private static void addXMLObject(Integer index, String nodeName, Object DTO) {
		// create node
		Integer nodeIndex = index;
		XMLList.add(index++, '<' + nodeName + '>');		// node without attribute
 		XMLList.add(index, '</' + nodeName + '>');
		
        // add object to node
        Map<String, Object> objectMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(DTO)); 
        system.debug('objectMap=> ' + objectMap) ;
        for (String fieldName : objectMap.keySet()) {
        	
        	Object member = objectMap.get(fieldName);
            system.debug('member=> ' + member) ;
        	if (member == null) {
        		
        		// null value field/attribute
				if (fieldName.startsWith(ATTRIBUTE_PREFIX)) {
					String attributeName = fieldName.substringAfter(ATTRIBUTE_PREFIX);
					XMLList[nodeIndex] = XMLList[nodeIndex].replace('>', ' ' + attributeName + '="">');
					
				} else {
        			XMLList.add(index++, '<' + fieldName + '/>');
				}
        		
        	} else if (member InstanceOf Id) {
        		addXMLField(nodeIndex, index, fieldName, String.valueOf(objectMap.get(fieldName)));
        		
        	} else if (member InstanceOf String) {
        		addXMLField(nodeIndex, index, fieldName, String.valueOf(objectMap.get(fieldName)));

        	} else if (member InstanceOf Integer) {
        		addXMLField(nodeIndex, index, fieldName, String.valueOf(objectMap.get(fieldName)));
        		
        	} else if (member InstanceOf Decimal) {
        		addXMLField(nodeIndex, index, fieldName, String.valueOf(objectMap.get(fieldName)));
        		
        	} else if (member InstanceOf Boolean) {
        		addXMLField(nodeIndex, index, fieldName, String.valueOf(objectMap.get(fieldName)));        		
        		
        	} else if (member InstanceOf List<Object>) {
        		List<Object> members = (List<Object>) objectMap.get(fieldName);
        		for (Object childDTO : members) {
        			addXMLObject(index, fieldName, childDTO);
        		}
        		
        	} else {		// (member InstanceOf Object)
				addXMLObject(index, fieldName, member);
        	}      
        }
	}
}