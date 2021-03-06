/*******************************************************************************
@author         Echo: Sudhir Kumar
@date           17 Dec 2018
@description    Centrelink Oasis WS Security Dto
                //Generated by FuseIT WSDL2Apex 
                //Warning: '<xsd:attribute>' element Usage has been skipped. (83, 3)
                //Warning: '<xsd:any>' element type has been changed to dataType List<DOM.XmlNode> called anyElement
                //Warning: '<xsd:attribute>' element Usage has been skipped. (83, 3)
                //Warning: '<xsd:attribute>' element Usage has been skipped. (83, 3)
********************************************************************************/

	
public class CuIn_CentrelinkOasisWSSecurityDto {
	
	//Warning: Simple Content Types with Attributes are not supported by WebServiceCallout.invoke
	public class AttributedString {
		public String input;
		private String[] input_type_info = new String[]{'input','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
		private String[] field_order_type_info = new String[]{};
	}
	
	//Warning: Simple Content Types with Attributes are not supported by WebServiceCallout.invoke
	public class BinarySecurityTokenType {
		public CuIn_CentrelinkOasisWSSecurityDto.EncodedString input;
		private String[] input_type_info = new String[]{'input','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','EncodedString','1','1','false'};
		public String ValueType;
		public String[] ValueType_att_info = new String[]{'ValueType'};
		private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
		private String[] field_order_type_info = new String[]{};
	}
	public class EmbeddedType {
		public String ValueType;
		public String[] ValueType_att_info = new String[]{'ValueType'};
		private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
		private String[] field_order_type_info = new String[]{};
	}
	
	//Warning: Simple Content Types with Attributes are not supported by WebServiceCallout.invoke
	public class EncodedString {
		public CuIn_CentrelinkOasisWSSecurityDto.AttributedString input;
		private String[] input_type_info = new String[]{'input','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','AttributedString','1','1','false'};
		public String EncodingType;
		public String[] EncodingType_att_info = new String[]{'EncodingType'};
		private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
		private String[] field_order_type_info = new String[]{};
	}
	
	//Warning: Simple Content Types with Attributes are not supported by WebServiceCallout.invoke
	public class KeyIdentifierType {
		public CuIn_CentrelinkOasisWSSecurityDto.EncodedString input;
		private String[] input_type_info = new String[]{'input','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','EncodedString','1','1','false'};
		public String ValueType;
		public String[] ValueType_att_info = new String[]{'ValueType'};
		private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
		private String[] field_order_type_info = new String[]{};
	}
	
	//Warning: Simple Content Types with Attributes are not supported by WebServiceCallout.invoke
	public class PasswordString {
		public CuIn_CentrelinkOasisWSSecurityDto.AttributedString input;
		private String[] input_type_info = new String[]{'input','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','AttributedString','1','1','false'};
		public String Type_x;
		public String[] Type_x_att_info = new String[]{'Type'};
		private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
		private String[] field_order_type_info = new String[]{};
	}
	public class ReferenceType {
		public String URI;
		public String[] URI_att_info = new String[]{'URI'};
		public String ValueType;
		public String[] ValueType_att_info = new String[]{'ValueType'};
		private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
		private String[] field_order_type_info = new String[]{};
	}
	public class SecurityHeaderType {
        public UsernameTokenType UsernameToken ; //
        private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
		private String[] field_order_type_info = new String[]{};
	}
	public class SecurityTokenReferenceType {
		private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
		private String[] field_order_type_info = new String[]{};
	}
	public class TransformationParametersType {
		private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
		private String[] field_order_type_info = new String[]{};
	}
	
	//Warning: '<xsd:any>' element type has been changed to dataType List<DOM.XmlNode> called anyElement
	public class UsernameTokenType {
		public CuIn_CentrelinkOasisWSSecurityDto.AttributedString Username;
        public CuIn_CentrelinkOasisWSSecurityDto.PasswordString Password;	//Added
        public CuIn_CentrelinkOasisWSSecurityDto.EncodedString Nonce; //Added
		public CuIn_CentrelinkOasisWSUtilityDto.AttributedDateTime Created;
		public List<DOM.XmlNode> anyElement;
		private String[] Username_type_info = new String[]{'Username','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','AttributedString','1','1','false'};
        private String[] Password_type_info = new String[]{'Password','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','PasswordString','1','1','false'};
        private String[] Nonce_type_info = new String[]{'Nonce','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','EncodedString','1','1','false'};
		private String[] Created_type_info = new String[]{'Created','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','AttributedDateTime','1','1','false'};
		private String[] anyElement_type_info = new String[]{'anyElement','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','List<DOM.XmlNode>','0','1','true'};
		private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
		private String[] field_order_type_info = new String[]{'Username','Password','Nonce','Created','anyElement'};
	}
}