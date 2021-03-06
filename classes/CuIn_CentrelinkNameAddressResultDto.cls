/*******************************************************************************
@author         Echo: Sudhir Kumar
@date           17 Dec 2018
@description    Centrelink Name Address Result Dto
				//Generated by FuseIT WSDL2Apex
********************************************************************************/	
	
public class CuIn_CentrelinkNameAddressResultDto {
	public class verifyNameAddressResult_element {
		public CuIn_CentrelinkNameAddressResultDto.verifyNameAddressResultDto verifyNameAddressResultDto;
		private String[] verifyNameAddressResultDto_type_info = new String[]{'verifyNameAddressResultDto','http://www.centrelink.gov.au/xml/schema/ccs/verifynameaddressresult/v1','verifyNameAddressResultDto','1','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://www.centrelink.gov.au/xml/schema/ccs/verifynameaddressresult/v1','true','false'};
		private String[] field_order_type_info = new String[]{'verifyNameAddressResultDto'};
	}
	public class verifyNameAddressResultDto {
		public String inputRefId;
		public String crn;
		public Date cnfrmDate;
		public String name;
		public String firstName;
		public String middleName;
		public String surname;
		public String dob;
		public String addr;
		public String stateMtch;
		private String[] inputRefId_type_info = new String[]{'inputRefId','http://www.centrelink.gov.au/xml/schema/ccs/verifynameaddressresult/v1','','0','1','false'};
		private String[] crn_type_info = new String[]{'crn','http://www.centrelink.gov.au/xml/schema/ccs/verifynameaddressresult/v1','','0','1','false'};
		private String[] cnfrmDate_type_info = new String[]{'cnfrmDate','http://www.centrelink.gov.au/xml/schema/ccs/verifynameaddressresult/v1','date','0','1','false'};
		private String[] name_type_info = new String[]{'name','http://www.centrelink.gov.au/xml/schema/ccs/verifynameaddressresult/v1','','0','1','false'};
		private String[] firstName_type_info = new String[]{'firstName','http://www.centrelink.gov.au/xml/schema/ccs/verifynameaddressresult/v1','','0','1','false'};
		private String[] middleName_type_info = new String[]{'middleName','http://www.centrelink.gov.au/xml/schema/ccs/verifynameaddressresult/v1','','0','1','false'};
		private String[] surname_type_info = new String[]{'surname','http://www.centrelink.gov.au/xml/schema/ccs/verifynameaddressresult/v1','','0','1','false'};
		private String[] dob_type_info = new String[]{'dob','http://www.centrelink.gov.au/xml/schema/ccs/verifynameaddressresult/v1','','0','1','false'};
		private String[] addr_type_info = new String[]{'addr','http://www.centrelink.gov.au/xml/schema/ccs/verifynameaddressresult/v1','','0','1','false'};
		private String[] stateMtch_type_info = new String[]{'stateMtch','http://www.centrelink.gov.au/xml/schema/ccs/verifynameaddressresult/v1','','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://www.centrelink.gov.au/xml/schema/ccs/verifynameaddressresult/v1','true','false'};
		private String[] field_order_type_info = new String[]{'inputRefId','crn','cnfrmDate','name','firstName','middleName','surname','dob','addr','stateMtch'};
	}
}