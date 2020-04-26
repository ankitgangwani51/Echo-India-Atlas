/*******************************************************************************
@author         Echo: Sudhir Kumar
@date           17 Dec 2018
@description    Centrelink Oasis WS Utility Dto
				//Generated by FuseIT WSDL2Apex 
				// Warning: TimestampType - All the XmlSchemaElements in '<xsd:choice>' element are added as members of the class. Choice Members:
********************************************************************************/

public class CuIn_CentrelinkOasisWSUtilityDto {
    
    //Failed to process Attribute of type XmlSchemaAttributeGroupRef for AttributedDateTime. Line:0 Position:0
	//Warning: Simple Content Types with Attributes are not supported by WebServiceCallout.invoke
    public class AttributedDateTime {
        public String input;
        private String[] input_type_info = new String[]{'input','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    
    //Failed to process Attribute of type XmlSchemaAttributeGroupRef for AttributedURI. Line:0 Position:0
	//Warning: Simple Content Types with Attributes are not supported by WebServiceCallout.invoke
    public class AttributedURI {
        public String input;
        private String[] input_type_info = new String[]{'input','http://www.w3.org/2001/XMLSchema','anyURI','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    
    // Warning: TimestampType - All the XmlSchemaElements in '<xsd:choice>' element are added as members of the class. Choice Members:
	//Failed to process Attribute of type XmlSchemaAttributeGroupRef for TimestampType. Line:0 Position:0
    public class TimestampType {
        public CuIn_CentrelinkOasisWSUtilityDto.AttributedDateTime Created;
        public CuIn_CentrelinkOasisWSUtilityDto.AttributedDateTime Expires;
        private String[] Created_type_info = new String[]{'Created','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd','','0','1','false'};
        private String[] Expires_type_info = new String[]{'Expires','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd','','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd','true','false'};
        private String[] field_order_type_info = new String[]{'Created','Expires'};
    }
}