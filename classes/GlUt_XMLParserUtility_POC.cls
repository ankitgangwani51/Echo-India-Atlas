//Sudhir Kumar
public class GlUt_XMLParserUtility_POC {
    
    private String TEST_XML_SAMPLE = 	'<?xml version="1.0" encoding="UTF-8"?>' +
                                            '<products>' +
                                                '<product>' +
                                                    '<name>Xbox</name>' +
                                                    '<code>XBO</code>' +
                                                '</product>' +
                                                '<product>' +
                                                    '<name>Playstation</name>' +
                                                    '<code>PS4</code>' +
                                                '</product>' +
                                                '<product>' +
                                                    '<name>Wifi</name>' +
                                                '</product>' +
                                        '</products>' ;
    
    private String parseXmlDocument(String toParse) {
        DOM.Document doc = new DOM.Document();
        try {
            doc.load(toParse);
            DOM.XMLNode root = doc.getRootElement();
            return processNode(root);
            
        } catch(System.XMLException e) { // invalid XML
            return e.getMessage();
        }
    }

	private String processNode(DOM.XMLNode node) {
		String result = '\n';
		if (node.getNodeType() == DOM.XMLNodeType.COMMENT) {
			return 'Comment (' + node.getText() + ')';
		}
		if (node.getNodeType() == DOM.XMLNodeType.TEXT) {
			return 'Text (' + node.getText() + ')';
		}
		if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
			result += 'Element: ' + node.getName();
			if (node.getText().trim() != '') {
				result += ', text=' + node.getText().trim();
			}
			if (node.getAttributeCount() > 0) {
				for (Integer i = 0; i < node.getAttributeCount(); i++) {
					result += ', attribute #' + i + ':' + node.getAttributeKeyAt(i) + '=' + node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i));
				}
			}
			for (Dom.XMLNode child: node.getChildElements()) {
				result += processNode(child);
			}
			return result;
		}
		return ''; //should never reach here 
	}

}