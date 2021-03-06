/*******************************************************************************
@author         Echo: Sudhir Kumar
@date           17 Dec 2018
@description    Centrelink Income Details Result Dto
				//Generated by FuseIT WSDL2Apex (http://www.fuseit.com/Solutions/SFDC-Explorer/Help-WSDL-Parser.aspx)
********************************************************************************/	
	
public class CuIn_CentrelinkIncomeDetailsResultDto {
	public class assetDetailsResultDto {
		public String assetTypeCode;
		public Decimal assetValueAmount;
		public Date dateOfEffect;
		private String[] assetTypeCode_type_info = new String[]{'assetTypeCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] assetValueAmount_type_info = new String[]{'assetValueAmount','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] dateOfEffect_type_info = new String[]{'dateOfEffect','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','date','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','true','false'};
		private String[] field_order_type_info = new String[]{'assetTypeCode','assetValueAmount','dateOfEffect'};
	}
	public class assetFinancialDetailsResultDto {
		public String assetTypeCode;
		public Decimal amount;
		public String currencyType;
		public Date dateOfEffect;
		public String institutionName;
		public String accountType;
		public Integer unitCount;
		public Decimal unitValue;
		public Integer percentageOwned;
		private String[] assetTypeCode_type_info = new String[]{'assetTypeCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] amount_type_info = new String[]{'amount','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] currencyType_type_info = new String[]{'currencyType','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] dateOfEffect_type_info = new String[]{'dateOfEffect','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','date','0','1','false'};
		private String[] institutionName_type_info = new String[]{'institutionName','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] accountType_type_info = new String[]{'accountType','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] unitCount_type_info = new String[]{'unitCount','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] unitValue_type_info = new String[]{'unitValue','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] percentageOwned_type_info = new String[]{'percentageOwned','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','true','false'};
		private String[] field_order_type_info = new String[]{'assetTypeCode','amount','currencyType','dateOfEffect','institutionName','accountType','unitCount','unitValue','percentageOwned'};
	}
	public class deductionDetailsResultDto {
		public String organisationName;
		public String deductionTypeCode;
		public Decimal amount;
		public Date lastPaymentDate;
		public Decimal targetAmount;
		public Decimal outstandingBalance;
		public Date deductionEndDate;
		public Decimal yearToDateAmount;
		private String[] organisationName_type_info = new String[]{'organisationName','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] deductionTypeCode_type_info = new String[]{'deductionTypeCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] amount_type_info = new String[]{'amount','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] lastPaymentDate_type_info = new String[]{'lastPaymentDate','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','date','0','1','false'};
		private String[] targetAmount_type_info = new String[]{'targetAmount','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] outstandingBalance_type_info = new String[]{'outstandingBalance','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] deductionEndDate_type_info = new String[]{'deductionEndDate','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','date','0','1','false'};
		private String[] yearToDateAmount_type_info = new String[]{'yearToDateAmount','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','true','false'};
		private String[] field_order_type_info = new String[]{'organisationName','deductionTypeCode','amount','lastPaymentDate','targetAmount','outstandingBalance','deductionEndDate','yearToDateAmount'};
	}
	public class deductionFromPaymentDetailsResultDto {
		public String paymentTypeCode;
		public String deductionTypeCode;
		public Decimal amount;
		public Date lastPaymentDate;
		private String[] paymentTypeCode_type_info = new String[]{'paymentTypeCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] deductionTypeCode_type_info = new String[]{'deductionTypeCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] amount_type_info = new String[]{'amount','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] lastPaymentDate_type_info = new String[]{'lastPaymentDate','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','date','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','true','false'};
		private String[] field_order_type_info = new String[]{'paymentTypeCode','deductionTypeCode','amount','lastPaymentDate'};
	}
	public class foreignIncomeFinancialDetailsResultDto {
		public String incomeTypeCode;
		public String componentCode;
		public Decimal amount;
		public String currencyType;
		private String[] incomeTypeCode_type_info = new String[]{'incomeTypeCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] componentCode_type_info = new String[]{'componentCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] amount_type_info = new String[]{'amount','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] currencyType_type_info = new String[]{'currencyType','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','true','false'};
		private String[] field_order_type_info = new String[]{'incomeTypeCode','componentCode','amount','currencyType'};
	}
	public class futureIrregularPaymentDetailsResultDto {
		public String benefitTypeCode;
		public String paymentTypeCode;
		public Decimal amount;
		public Date dateToBePaid;
		public String frequencyCode;
		private String[] benefitTypeCode_type_info = new String[]{'benefitTypeCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] paymentTypeCode_type_info = new String[]{'paymentTypeCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] amount_type_info = new String[]{'amount','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] dateToBePaid_type_info = new String[]{'dateToBePaid','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','date','0','1','false'};
		private String[] frequencyCode_type_info = new String[]{'frequencyCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','true','false'};
		private String[] field_order_type_info = new String[]{'benefitTypeCode','paymentTypeCode','amount','dateToBePaid','frequencyCode'};
	}
	public class futureRegularPaymentDetailsResultDto {
		public String benefitTypeCode;
		public String paymentTypeCode;
		public Decimal amount;
		public Date dateToBePaid;
		public Date grantDate;
		public Decimal legislatedMaximumEntitlement;
		private String[] benefitTypeCode_type_info = new String[]{'benefitTypeCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] paymentTypeCode_type_info = new String[]{'paymentTypeCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] amount_type_info = new String[]{'amount','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] dateToBePaid_type_info = new String[]{'dateToBePaid','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','date','0','1','false'};
		private String[] grantDate_type_info = new String[]{'grantDate','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','date','0','1','false'};
		private String[] legislatedMaximumEntitlement_type_info = new String[]{'legislatedMaximumEntitlement','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','true','false'};
		private String[] field_order_type_info = new String[]{'benefitTypeCode','paymentTypeCode','amount','dateToBePaid','grantDate','legislatedMaximumEntitlement'};
	}
	public class incomeManagementDeductionDetailsResultDto {
		public String organisationName;
		public String deductionTypeCode;
		public Decimal amount;
		public Date lastPaymentDate;
		public Decimal targetAmount;
		public Decimal outstandingBalance;
		public Date deductionEndDate;
		public Decimal yearToDateAmount;
		private String[] organisationName_type_info = new String[]{'organisationName','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] deductionTypeCode_type_info = new String[]{'deductionTypeCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] amount_type_info = new String[]{'amount','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] lastPaymentDate_type_info = new String[]{'lastPaymentDate','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','date','0','1','false'};
		private String[] targetAmount_type_info = new String[]{'targetAmount','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] outstandingBalance_type_info = new String[]{'outstandingBalance','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] deductionEndDate_type_info = new String[]{'deductionEndDate','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','date','0','1','false'};
		private String[] yearToDateAmount_type_info = new String[]{'yearToDateAmount','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','true','false'};
		private String[] field_order_type_info = new String[]{'organisationName','deductionTypeCode','amount','lastPaymentDate','targetAmount','outstandingBalance','deductionEndDate','yearToDateAmount'};
	}
	public class maximumRateDetailsResultDto {
		public String maximumRateTypeCode;
		public String maximumRateIndicator;
		private String[] maximumRateTypeCode_type_info = new String[]{'maximumRateTypeCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] maximumRateIndicator_type_info = new String[]{'maximumRateIndicator','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','true','false'};
		private String[] field_order_type_info = new String[]{'maximumRateTypeCode','maximumRateIndicator'};
	}
	public class nonCuIn_CentrelinkIncomeDetailsResultDto {
		public String incomeTypeCode;
		public Decimal amount;
		public String frequencyCode;
		public Date dateOfEffect;
		private String[] incomeTypeCode_type_info = new String[]{'incomeTypeCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] amount_type_info = new String[]{'amount','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] frequencyCode_type_info = new String[]{'frequencyCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] dateOfEffect_type_info = new String[]{'dateOfEffect','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','date','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','true','false'};
		private String[] field_order_type_info = new String[]{'incomeTypeCode','amount','frequencyCode','dateOfEffect'};
	}
	public class previousIrregularPaymentDetailsResultDto {
		public String benefitTypeCode;
		public String paymentTypeCode;
		public Decimal amount;
		public Date lastPaymentDate;
		public String frequencyCode;
		private String[] benefitTypeCode_type_info = new String[]{'benefitTypeCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] paymentTypeCode_type_info = new String[]{'paymentTypeCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] amount_type_info = new String[]{'amount','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] lastPaymentDate_type_info = new String[]{'lastPaymentDate','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','date','0','1','false'};
		private String[] frequencyCode_type_info = new String[]{'frequencyCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','true','false'};
		private String[] field_order_type_info = new String[]{'benefitTypeCode','paymentTypeCode','amount','lastPaymentDate','frequencyCode'};
	}
	public class previousRegularPaymentDetailsResultDto {
		public String benefitTypeCode;
		public String paymentTypeCode;
		public Decimal amount;
		public Date lastPaymentDate;
		public Date grantDate;
		public Decimal legislatedMaximumEntitlement;
		private String[] benefitTypeCode_type_info = new String[]{'benefitTypeCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] paymentTypeCode_type_info = new String[]{'paymentTypeCode','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] amount_type_info = new String[]{'amount','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] lastPaymentDate_type_info = new String[]{'lastPaymentDate','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','date','0','1','false'};
		private String[] grantDate_type_info = new String[]{'grantDate','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','date','0','1','false'};
		private String[] legislatedMaximumEntitlement_type_info = new String[]{'legislatedMaximumEntitlement','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','true','false'};
		private String[] field_order_type_info = new String[]{'benefitTypeCode','paymentTypeCode','amount','lastPaymentDate','grantDate','legislatedMaximumEntitlement'};
	}
	public class retrieveIncomeDetailsResult_element {
		public CuIn_CentrelinkIncomeDetailsResultDto.retrieveIncomeDetailsResultDto retrieveIncomeDetailsResultDto;
		private String[] retrieveIncomeDetailsResultDto_type_info = new String[]{'retrieveIncomeDetailsResultDto','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','retrieveIncomeDetailsResultDto','1','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','true','false'};
		private String[] field_order_type_info = new String[]{'retrieveIncomeDetailsResultDto'};
	}
	public class retrieveIncomeDetailsResultDto {
		public String inputRefId;
		public String crn;
		public String orgRefNumber;
		public Date cnfrmDate;
		public String surname;
		public String firstName;
		public Date dob;
		public String partnerIndicator;
		public String paidAtSingleRateIndicator;
		public String youthIndependentRateIndicator;
		public String remoteIncomeSupportIndicator;
		public CuIn_CentrelinkIncomeDetailsResultDto.maximumRateDetailsResultDto[] maximumRateDetails;
		public Integer numberOfChildrenAssessed;
		public Decimal[] percentageOfCareForChildren;
		public String streetSuburbMatchIndicator;
		public String stateMatchIndicator;
		public String postcodeMatchIndicator;
		public CuIn_CentrelinkIncomeDetailsResultDto.previousRegularPaymentDetailsResultDto[] previousRegularPaymentDetails;
		public CuIn_CentrelinkIncomeDetailsResultDto.previousIrregularPaymentDetailsResultDto[] previousIrregularPaymentDetails;
		public CuIn_CentrelinkIncomeDetailsResultDto.deductionFromPaymentDetailsResultDto[] deductionFromPaymentDetails;
		public CuIn_CentrelinkIncomeDetailsResultDto.deductionDetailsResultDto[] deductionDetails;
		public CuIn_CentrelinkIncomeDetailsResultDto.incomeManagementDeductionDetailsResultDto[] incomeManagementDeductionDetails;
		public CuIn_CentrelinkIncomeDetailsResultDto.futureRegularPaymentDetailsResultDto[] futureRegularPaymentDetails;
		public CuIn_CentrelinkIncomeDetailsResultDto.futureIrregularPaymentDetailsResultDto[] futureIrregularPaymentDetails;
		public CuIn_CentrelinkIncomeDetailsResultDto.nonCuIn_CentrelinkIncomeDetailsResultDto[] nonCentrelinkIncomeDetails;
		public CuIn_CentrelinkIncomeDetailsResultDto.foreignIncomeFinancialDetailsResultDto[] foreignIncomeFinancialDetails;
		public CuIn_CentrelinkIncomeDetailsResultDto.assetDetailsResultDto[] assetDetails;
		public CuIn_CentrelinkIncomeDetailsResultDto.assetFinancialDetailsResultDto[] assetFinancialDetails;
		private String[] inputRefId_type_info = new String[]{'inputRefId','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] crn_type_info = new String[]{'crn','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] orgRefNumber_type_info = new String[]{'orgRefNumber','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] cnfrmDate_type_info = new String[]{'cnfrmDate','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','date','0','1','false'};
		private String[] surname_type_info = new String[]{'surname','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] firstName_type_info = new String[]{'firstName','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] dob_type_info = new String[]{'dob','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','date','0','1','false'};
		private String[] partnerIndicator_type_info = new String[]{'partnerIndicator','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] paidAtSingleRateIndicator_type_info = new String[]{'paidAtSingleRateIndicator','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] youthIndependentRateIndicator_type_info = new String[]{'youthIndependentRateIndicator','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] remoteIncomeSupportIndicator_type_info = new String[]{'remoteIncomeSupportIndicator','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] maximumRateDetails_type_info = new String[]{'maximumRateDetails','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','maximumRateDetailsResultDto','0','-1','false'};
		private String[] numberOfChildrenAssessed_type_info = new String[]{'numberOfChildrenAssessed','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] percentageOfCareForChildren_type_info = new String[]{'percentageOfCareForChildren','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','-1','false'};
		private String[] streetSuburbMatchIndicator_type_info = new String[]{'streetSuburbMatchIndicator','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] stateMatchIndicator_type_info = new String[]{'stateMatchIndicator','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] postcodeMatchIndicator_type_info = new String[]{'postcodeMatchIndicator','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','','0','1','false'};
		private String[] previousRegularPaymentDetails_type_info = new String[]{'previousRegularPaymentDetails','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','previousRegularPaymentDetailsResultDto','0','-1','false'};
		private String[] previousIrregularPaymentDetails_type_info = new String[]{'previousIrregularPaymentDetails','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','previousIrregularPaymentDetailsResultDto','0','-1','false'};
		private String[] deductionFromPaymentDetails_type_info = new String[]{'deductionFromPaymentDetails','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','deductionFromPaymentDetailsResultDto','0','-1','false'};
		private String[] deductionDetails_type_info = new String[]{'deductionDetails','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','deductionDetailsResultDto','0','-1','false'};
		private String[] incomeManagementDeductionDetails_type_info = new String[]{'incomeManagementDeductionDetails','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','incomeManagementDeductionDetailsResultDto','0','-1','false'};
		private String[] futureRegularPaymentDetails_type_info = new String[]{'futureRegularPaymentDetails','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','futureRegularPaymentDetailsResultDto','0','-1','false'};
		private String[] futureIrregularPaymentDetails_type_info = new String[]{'futureIrregularPaymentDetails','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','futureIrregularPaymentDetailsResultDto','0','-1','false'};
		private String[] nonCentrelinkIncomeDetails_type_info = new String[]{'nonCentrelinkIncomeDetails','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','nonCuIn_CentrelinkIncomeDetailsResultDto','0','-1','false'};
		private String[] foreignIncomeFinancialDetails_type_info = new String[]{'foreignIncomeFinancialDetails','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','foreignIncomeFinancialDetailsResultDto','0','-1','false'};
		private String[] assetDetails_type_info = new String[]{'assetDetails','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','assetDetailsResultDto','0','-1','false'};
		private String[] assetFinancialDetails_type_info = new String[]{'assetFinancialDetails','http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','assetFinancialDetailsResultDto','0','-1','false'};
		private String[] apex_schema_type_info = new String[]{'http://www.centrelink.gov.au/xml/schema/ccs/retrieveincomedetailsresult/v1','true','false'};
		private String[] field_order_type_info = new String[]{'inputRefId','crn','orgRefNumber','cnfrmDate','surname','firstName','dob','partnerIndicator','paidAtSingleRateIndicator','youthIndependentRateIndicator','remoteIncomeSupportIndicator','maximumRateDetails','numberOfChildrenAssessed','percentageOfCareForChildren','streetSuburbMatchIndicator','stateMatchIndicator','postcodeMatchIndicator','previousRegularPaymentDetails','previousIrregularPaymentDetails','deductionFromPaymentDetails','deductionDetails','incomeManagementDeductionDetails','futureRegularPaymentDetails','futureIrregularPaymentDetails','nonCentrelinkIncomeDetails','foreignIncomeFinancialDetails','assetDetails','assetFinancialDetails'};
	}
}