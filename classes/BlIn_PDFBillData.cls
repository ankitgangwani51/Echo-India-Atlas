/******************************************************************************
@author         Accenture: Patrick Dixon
@date           04 Sep 2017
@description    PDF Bill Data class used to prepare the bill data
                includes XMLObject and XMLRecord sub classes.
                XMLObjects are used to extract data from the database 
                which is transformed into XMLRecords.  XMLRecords are then 
                written into the XML document.
*******************************************************************************/
public with sharing class BlIn_PDFBillData {
        
	private static final String CLASS_NAME = 'BlIn_PDFBillData';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';

    public String PDFFormName;		// template name
    public List<XMLRecord> XMLObjectRecords = new List<XMLRecord>();		// list of the top level object records
    private Integer level;      // for debug

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           15 Sep 2017
    @param          XMLRecord - parentRecord
    @param          XMLRecord - the record to add
    @description    adds an object record to a parent record in the XML data structure
    *******************************************************************************/
    public Boolean addChildRecord(XMLRecord parentRecord, XMLRecord recordToAdd) {

        // check if this is the correct parent record
        if (parentRecord.parentIds.contains(recordToAdd.parentLookup)) {
                
            // add it to the child list
            if (parentRecord.objectListMap.keySet().contains(recordToAdd.Name)) {
                parentRecord.objectListMap.get(recordToAdd.Name).add(recordToAdd);
                
            } else {
                List<XMLRecord> XMLObjectRecords = new List<XMLRecord>();
                XMLObjectRecords.add(recordToAdd);
                parentRecord.objectListMap.put(recordToAdd.Name, XMLObjectRecords);
            }

            // sucessfully added the record
            system.debug(DEBUG + 'sucessfully added the record ' + recordToAdd.name + ' to ' + recordToAdd.parentName);
            return true;
        }
            
        system.debug(DEBUG + 'failed to find ' + recordToAdd.parentName + ' for ' + recordToAdd.name);
        return false;
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           15 Sep 2017
    @param          List<XMLRecord> - this level record's child records
    @param          XMLRecord - the record to add
    @description    finds a record's parent in the XML data structure
                    and adds the record to the correct parent record
    *******************************************************************************/
    public Boolean checkBranch(List<XMLRecord> childRecords, XMLRecord recordToAdd) {
		Boolean found; 
            
        system.debug(DEBUG + 'level: ' + level++);

        // check the lower branches
        for (XMLRecord parentCandidate : childRecords) {

            // if this is the parent
            if (recordToAdd.parentName == parentCandidate.Name) {
                    
                // add the record to the parent record's children and exit
                found = addChildRecord(parentCandidate, recordToAdd);
                if (found) return true;
            }
                    
            // this is not the parent so check each level down the hierachy until the parent is found or we reach the bottom
            for (List<XMLRecord> parentCandidateChildren : parentCandidate.objectListMap.values()) {

                // check the next level down the hierachy until the parent is found or we reach the bottom
                found = checkBranch(parentCandidateChildren, recordToAdd);
                if (found) return true;
            }
        }
        return false;
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           14 Sep 2017
    @param          XMLRecord - the record to add
    @description    adds an object record to XML data structure
    *******************************************************************************/
    public Boolean addObjectRecord(XMLRecord recordToAdd) {
            
        level = 0;
        system.debug(DEBUG + 'adding: ' + recordToAdd.name);
            
        // base record 
        if (recordToAdd.parentName == null) {
                
            // add it to the data structure
            XMLObjectRecords.add(recordToAdd);
            system.debug(DEBUG + 'sucessfully added base record ' + recordToAdd.name);
            return true;

        // child records
        } else {
            Boolean found; 
            
            // check each record branch for the parent, starting at the top
            for (XMLRecord parentCandidate : XMLObjectRecords) {
                    
                // if this is the parent
                if (recordToAdd.parentName == parentCandidate.Name) {
                        
            system.debug(DEBUG + 'adding ' + recordToAdd.parentName);
                    // add the record to the parent record's children and exit
                    found = addChildRecord(parentCandidate, recordToAdd);
                    if (found) return true;
                }

                // this is not the parent so check the lower branches
                for (List<XMLRecord> parentCandidateChildren : parentCandidate.objectListMap.values()) {
                        
                    // check the next level down the hierachy until the parent is found or we reach the bottom
                    found = checkBranch(parentCandidateChildren, recordToAdd);
                    if (found) return true;
                }
            }
        }
            
        // error exit
        system.debug(DEBUG + 'failed to add ' + recordToAdd.name);
        return false;
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           08 Sep 2017
    @description    Subclass for XML Object data structure
    				This class is used to define the objects/fields that will be 
    				included in the XML.
    *******************************************************************************/
    public class XMLObject {
        
        public String name;     // name of the object
        public String parentName;       // name of the parent object
        public String parentIdName;     // name of the parent lookup field (also constrains the scope of the query to this bill)
        public Set<String> idFields;        // any additional fields on this object that can link to child objects
        public Set<String> XMLFields;       // the fields on this object that are added to the XML
            
        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           13 Sep 2017
        @description    Constructor
        *******************************************************************************/
        public XMLObject(String name, String parentName, String parentIdName, Set<String> idFields, Set<String> XMLFields) {
            
            this.name = name;
            this.parentName = parentName;
            this.parentIdName = parentIdName;
            this.idFields = idFields;
            this.XMLFields = XMLFields;
        }
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           14 Sep 2017
    @description    Subclass for XML Records
    				This class is used to hold the extracted records/fields that will 
    				be used to create the XML data structure
    *******************************************************************************/
    public class XMLRecord {
        
        public String name;     // name of the object
        public String parentName;       // name of the parent object

        public Map<String, String> fieldMap;        // a map of field values keyed on the field name for this record
        public Set<Id> parentIds;       // a set of the parent Ids associated with the record (includes the record Id)
        public Id parentLookup;     // the salesforce Id that links to the parent record
        public Map<String, List<XMLRecord>> objectListMap;      // a map of a list of child records keyed on the child object name
            
        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           13 Sep 2017
        @description    Constructor
        *******************************************************************************/
        public XMLRecord(XMLObject XMLObject) {

            name = XMLObject.name;
            parentName = XMLObject.parentName;
            
            fieldMap = new Map<String, String>();
            parentIds = new Set<Id>();
            objectListMap = new Map<String, List<XMLRecord>>();
        }
        
        /******************************************************************************
        @author         Accenture: KC Thiruchelvam
        @date           15 Dec 2017
        @description    Constructor
        *******************************************************************************/
        public XMLRecord(String objectName) {
        	name = objectName;
        	
        	fieldMap = new Map<String, String>();
            parentIds = new Set<Id>();
            objectListMap = new Map<String, List<XMLRecord>>();
        }
    }
}