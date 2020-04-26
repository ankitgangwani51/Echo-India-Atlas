/******************************************************************************
@author         Accenture: Patrick Dixon
@date           04 Sep 2017
@description    Class to create the XML billing document
                Called from BlIn_ExecutePDFGeneration once an instance of 
                BlIn_PDFBillData has been created/exists for a bill.
                Transforms the XMLRecords into an XML document.
*******************************************************************************/
public with sharing class BlIn_PDFCreateBillDataXML {
    
    private static final String CLASS_NAME = 'BlIn_PDFCreateBillDataXML';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    // XML tags
    private static final String ENCODING = 'UTF-8';     // all strings are UTF-8 encoded
    private static final String PDF_DATA = 'pdfData';
    private static final String PDF_TEMPLATE_NAME = 'pdfTemplateName';
    private static final String OBJECT_RECORD = 'objectRecord';
    private static final String OBJECT_RECORD_LIST = 'objectRecordList';
    private static final String OBJECT_API_NAME = 'objectApiName';
    private static final String FIELD = 'field';
    private static final String API_NAME = 'apiName';
    private static final String VALUE = 'value';
    
    public Dom.Document XMLDocument {get; private set;}
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           04 Sep 2017
    @param          BlIn_PDFBillData.BlIn_PDFBillData - bill data
    @param          String - PDF template name
    @description    Constructor
    *******************************************************************************/
    public BlIn_PDFCreateBillDataXML(BlIn_PDFBillData billData) {

        // initialise the XML structure
        XMLDocument = new Dom.Document();
        XMLDocument.createRootElement(PDF_DATA, null, null);
        Dom.XmlNode objectNode = XMLDocument.getRootElement();
        
        // add the pdf template node
        objectNode.addChildElement(PDF_TEMPLATE_NAME, null, null).addTextNode(
                                    EncodingUtil.urlEncode(billData.PDFFormName, ENCODING)
                                    );
        
        // for each top level object record in the data structure       
        for (BlIn_PDFBillData.XMLRecord XMLRecord : billData.XMLObjectRecords) {

            // add the object record node and all its children
            addToXmlDoc(objectNode, XMLRecord);
        }
        system.debug(DEBUG + 'XML: ' + XMLDocument.toXMLString());
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           08 Sep 2017
    @param          Dom.XmlNode - parentNode
    @param          BlIn_PDFBillData.XMLObject - XMLObject structured object
    @description    adds an object node to the XML parent
    *******************************************************************************/
    private void addToXmlDoc(Dom.XmlNode parentNode, BlIn_PDFBillData.XMLRecord XMLRecord) {

        // add object
        parentNode = parentNode.addChildElement(OBJECT_RECORD, null, null);
        parentNode.addChildElement(OBJECT_API_NAME, null, null).addTextNode(
                                            EncodingUtil.urlEncode(XMLRecord.name, ENCODING)
                                            );
        
        // add fields
        Dom.XmlNode fieldNode;
        for (String fieldName : XMLRecord.fieldMap.keySet()) {
            fieldNode = parentNode.addChildElement(FIELD, null, null);
            fieldNode.addChildElement(API_NAME, null, null).addTextNode(
                                            EncodingUtil.urlEncode(fieldName, ENCODING)
                                            );
            fieldNode.addChildElement(VALUE, null, null).addTextNode(
                                            EncodingUtil.urlEncode(XMLRecord.fieldmap.get(fieldName), ENCODING)
                                            );
        }

        // add list objects (children)
        if (XMLRecord.objectListMap != null) {
            for (String objectListName : XMLRecord.objectListMap.keySet()) {
                parentNode = parentNode.addChildElement(OBJECT_RECORD_LIST, null, null);
                parentNode.addChildElement(OBJECT_API_NAME, null, null).addTextNode(
                                            EncodingUtil.urlEncode(objectListName, ENCODING)
                                            );
                
                // add the object record node
                for (BlIn_PDFBillData.XMLRecord XMLChildRecord : XMLRecord.objectListMap.get(objectListName)) {
                    addToXmlDoc(parentNode, XMLChildRecord);
                }
            }
        }
    }
}