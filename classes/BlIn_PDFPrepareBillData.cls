/******************************************************************************
@author         Accenture: Patrick Dixon
@date           04 Sep 2017
@description    This class creates an XML formatted document using the 
                BlIn_PDFXMLDefinition class to extract and format the 
                salesforce data required for Bill PDF Generation.
*******************************************************************************/
public with sharing class BlIn_PDFPrepareBillData {
    
	private static final String CLASS_NAME = 'BlIn_PDFPrepareBillData';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';

    public BlIn_PDFBillData billData {get; private set;}
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           04 Sep 2017
    @param          Id - bill Id
    @description    Constructor
    *******************************************************************************/
    public BlIn_PDFPrepareBillData(Id billId, String PDFTemplateName) {

        // start with the bill Id and pick up the other parent Ids along the way        
        Set<Id> matchIds = new Set<Id>();
        matchIds.add(billId);
        
        // instantiate an instance of the XML definition
        BlIn_PDFXMLDefinition XMLDefinition = new BlIn_PDFXMLDefinition();

        // instantiate the XML data structure
        billData = new BlIn_PDFBillData();
        
        // add pdf template name
        billData.PDFFormName = PDFTemplateName;
		
		// instantiate set required for DeviceDetails xml record
		Set<Id> supplyPointIds = new Set<Id>();
		
        // populate the rest of the XML using the definition class objects
        for (BlIn_PDFBillData.XMLObject XMLObject : XMLDefinition.XMLObjects) {
            
            // build the records for each of the objects
            for (BlIn_PDFBillData.XMLRecord XMLObjectRecord : buildXMLObjectRecords(XMLObject, matchIds)) {

                // add them to the XML structure
                billData.addObjectRecord(XMLObjectRecord);
                
                // special xml build for DeviceDetails, dependent on Services
                if (XMLObject.Name == GlUt_APIConstantsService.SERVICEAPINAME) {
                	supplyPointIds.add( XMLObjectRecord.fieldMap.get(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTRELAPINAME + '.Id')); 
                }
            }
        }
        
        // build DeviceDetails xml record
        // (please note all of the below needs to be re-organised as currently quite messy)
        // (also proper comments are to be added before the weekend)
        if (supplyPointIds.size() > 0) {
        	// get all required data
        	Map<Id, SupplyPoint__c> supplyPointMap = new Map<Id, SupplyPoint__c>([Select Id, Location__r.Address__c From SupplyPoint__c where Id in :supplyPointIds]);
        	Set<Id> deviceIds = new Set<Id>();
        	Map<Id, SupplyPointDevice__c> supplyPointDeviceMap = new Map<Id, SupplyPointDevice__c>();
        	for (SupplyPointDevice__c supplyPointDevice : [Select Id, SupplyPoint__c, DeviceLocationPostcode__c, Device__c,
                                                           //Device__r.DeviceReference__c, --AT-3174
                                                           Device__r.SerialNo__c
        												   From SupplyPointDevice__c 
        												   Where SupplyPoint__c in :supplyPointIds and Active__c = true]) {
        		 supplyPointDeviceMap.put(supplyPointDevice.SupplyPoint__c, supplyPointDevice);
        		 deviceIds.add(supplyPointDevice.Device__c);
        	}
        	Map<Id, List<Reading__c>> readingMap = new Map<Id, List<Reading__c>>();
        	for (Reading__c reading : [select Id, ReadingDate__c, Reading__c, ReadingType__c, Device__c 
        							   from Reading__c 
        							   where Device__c in :deviceIds 
        							   order by ReadingDate__c desc]) {
        		 if (!readingMap.containsKey(reading.Device__c)) {
        		 	readingMap.put(reading.Device__c, new List<Reading__c>());
        		 }
				 if(readingMap.get(reading.Device__c).size() <= 1){
					readingMap.get(reading.Device__c).add(reading);
				 }
        	}
        	
        	// build XML Object Record
        	for (Id supplyPointId : supplyPointMap.keySet() ) {
        		SupplyPoint__c supplyPoint = supplyPointMap.get(supplyPointId);
        		SupplyPointDevice__c supplyPointDevice = supplyPointDeviceMap.get(supplyPointId);
        		List<Reading__c> readingsForSupplyPointDevice = readingMap.get(supplyPointDevice.Device__c);
        		Reading__c presentReading = readingsForSupplyPointDevice[0];
        		Reading__c previousReading = readingsForSupplyPointDevice[1];
        		
        		BlIn_PDFBillData.XMLRecord XMLObjectRecord = new BlIn_PDFBillData.XMLRecord('DeviceDetails');
        		
        		//XMLObjectRecord.fieldMap.put('DeviceReference', String.valueOf(supplyPointDevice.Device__r.DeviceReference__c) ); --AT-3174
        		XMLObjectRecord.fieldMap.put('SerialNumber', String.valueOf(supplyPointDevice.Device__r.SerialNo__c) );
        		XMLObjectRecord.fieldMap.put('SupplyAddress', String.valueOf(supplyPoint.Location__r.Address__c) );
        		XMLObjectRecord.fieldMap.put('MeterLocation', String.valueOf(supplyPointDevice.DeviceLocationPostcode__c) );
        		XMLObjectRecord.fieldMap.put('PresentReadingDate', String.valueOf(presentReading.ReadingDate__c) );
        		XMLObjectRecord.fieldMap.put('PresentReadingReading', String.valueOf(presentReading.Reading__c) );
        		XMLObjectRecord.fieldMap.put('PresentReadingReadingType', String.valueOf(presentReading.ReadingType__c) );
        		XMLObjectRecord.fieldMap.put('PresentReadingConsumption', String.valueOf(presentReading.Reading__c - previousReading.Reading__c) );
        		XMLObjectRecord.fieldMap.put('PreviousReadingDate', String.valueOf(previousReading.ReadingDate__c) );
        		XMLObjectRecord.fieldMap.put('PreviousReadingReading', String.valueOf(previousReading.Reading__c) );
        		XMLObjectRecord.fieldMap.put('PreviousReadingReadingType', String.valueOf(previousReading.ReadingType__c) );
        	
        		billData.addObjectRecord(XMLObjectRecord);
        	}
        }
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           13 Sep 2017
    @param          SObject - record
    @param          String - API name of the field
    @return         String - field value
    @description    gets a field value as a string from a record using the API field name
    *******************************************************************************/
    private String getValue(SObject record, String fieldName) {
                
        // initialise the field's parent object
        SObject parentRecord = record;

        // split the query field into a list of its parent objects and its field name
        List<String> fieldNameElements = fieldName.normalizeSpace().split('\\.');
        
        // get the parent object name from the schema, and then get the field value
        for (Integer i = 0; i < fieldNameElements.size(); i++) {

            // the last element is the actual field name
            if (i == fieldNameElements.size() - 1) {
            	
            	// get the properties of all the fields on the object using the describe method
                String parentObjectName = parentRecord.getSObjectType().getDescribe().getName();
            	Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(parentObjectName).getDescribe().fields.getMap();

            	// get the field type from the describe map
				DisplayType fieldType = fieldMap.get(fieldNameElements[i]).getDescribe().getType();
				system.debug(DEBUG + 'fieldType: ' + fieldType);
                        
                // return the value (appropriately formatted using user locale)
                if (fieldType == DisplayType.DATE) {
                	return parentRecord.get(fieldNameElements[i]) != null ? ((Date)parentRecord.get(fieldNameElements[i])).format() : '';

                } else if (fieldType == DisplayType.DOUBLE) {
                	return parentRecord.get(fieldNameElements[i]) != null ? ((Decimal)parentRecord.get(fieldNameElements[i])).format() : '';

                } else if (fieldType == DisplayType.CURRENCY) {
					String sCurrency = parentRecord.get(fieldNameElements[i]) != null 
                			? (((Decimal)parentRecord.get(fieldNameElements[i])).setScale(2) + 0.001).format() 
                			: '0.00';
                	sCurrency = sCurrency;
                	return sCurrency.substring(0, sCurrency.length() - 1);

                } else {
                	return parentRecord.get(fieldNameElements[i]) != null ? String.valueOf(parentRecord.get(fieldNameElements[i])) : '';
                }
                        
            // other elements are parent object references
            } else {
                
                // update the parent object
                parentRecord = parentRecord.getSobject(fieldNameElements[i]);
                
                // return empty string if no parent record
                if (parentRecord == null) {
                    return '';
                }
            }
        }
        
        // error exit - parent record match not found
        return null;
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           12 Sep 2017
    @param          XMLObject - the XMLObject prototype for this SObject
    @param          Set<Id> - set of record Ids to match with the parentIdName field 
    @return         List<XMLObject> - a list of the populated XMLObjects
    @description    builds a list of XMLObject records for an object type
    *******************************************************************************/
    private List<BlIn_PDFBillData.XMLRecord> buildXMLObjectRecords(BlIn_PDFBillData.XMLObject XMLObject, Set<Id> matchIds) {

        List<BlIn_PDFBillData.XMLRecord> objectXMLList = new List<BlIn_PDFBillData.XMLRecord>();

        // build a set of all fields required in the query
        Set<String> fieldSet = new Set<String>();
        
        // start with the XML fields
        fieldSet.addAll(XMLObject.XMLFields);
        
        // and add the match Id fields
        if (XMLObject.idFields != null) {
            fieldSet.addAll(XMLObject.idFields);
        }

        // and the Id, parent Id and where fields
        fieldSet.add('Id');
        if (XMLObject.parentIdName != null) {
            fieldSet.add(XMLObject.parentIdName);
        }

        // build a string of query fields from the set
        String fieldList = '';
        for (String field : fieldSet) {
            fieldList += String.isBlank(fieldList) ? field : ', ' + field;
        }
        
        // default the query 'where field' to Id if the parent Id is null
        String parentIdName = XMLObject.parentIdName != null ? XMLObject.parentIdName : 'Id';
        
        // build the query and get the return record
        String query = 'select '
                    + fieldList + ' '
                    + 'from ' + XMLObject.name + ' '
                    + 'where ' + parentIdName + ' in :matchIds';
    
        for (SObject record : Database.query(query)) {
			BlIn_PDFBillData.XMLRecord XMLObjectRecord = new BlIn_PDFBillData.XMLRecord(XMLObject);
            
            // for each field returned in the query     
            for (String fieldName : fieldSet) {
                
                // get the field value as a string
                String value = getValue(record, fieldName);
                
                // if it's a Id field add it to the global match Ids and to the parent Ids for this record
                if (!String.isBlank(value) && XMLObject.idFields != null && XMLObject.idFields.contains(fieldName)) {
                    matchIds.add((Id)value);
                    XMLObjectRecord.parentIds.add((Id)value);
                } 

                // save the parent Id match
                if (!String.isBlank(value) && fieldName == XMLObject.parentIdName) {
                    XMLObjectRecord.parentLookup = (Id)value;
                }

                // add the record Id to the global match Ids and to the parent Ids
                if (fieldName == 'Id') {
                    matchIds.add((Id)value);
                    XMLObjectRecord.parentIds.add((Id)value);
                }

                // populate the object field map
                if (XMLObject.XMLFields.contains(fieldName)) {
                    XMLObjectRecord.fieldMap.put(fieldName, value);
                }
            }
            
            
            
	        // carry out Transformation 
	        if (XMLObjectRecord.Name == GlUt_APIConstantsBillItem.BILLITEMAPINAME) {
	        		// Prepare Consumption XML Field
	        		String numberOfDays = XMLObjectRecord.fieldMap.get(CuAp_Constants.NUMBEROFDAYS);
	        		String volumeUsed = XMLObjectRecord.fieldMap.get(CuAp_Constants.VOLUMEUSED);
	        		String consumption = '';
	        		
	        		if (volumeUsed != null && volumeUsed != '') {
	        			consumption = volumeUsed + ' m3';
	        		} else if (numberOfDays != null && numberOfDays != '') {
	        			consumption = numberOfDays + ' days';
	        		}
	        		XMLObjectRecord.fieldMap.put('Consumption', consumption);
	        }
        
            
            objectXMLList.add(XMLObjectRecord);
        }
        return objectXMLList;
    }
    
}