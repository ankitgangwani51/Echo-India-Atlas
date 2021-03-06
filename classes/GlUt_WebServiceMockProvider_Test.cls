/*******************************************************************************
@author         Echo: Sudhir Kumar
@date           21 Dec 2018
@group 			MockAPIProvider
@description    Test class for WebServiceMock Provider. It implements WebServiceMock for SOAP WS.
				// *Note: requestName = The requested SOAP operation name -> This will make dynamic mock response based on Requested Stub Name -> Standard followed is: ClassName.StubName
				// Use different requestName(s) to get different mock response
				// Create response element from the autogenerated class.
                // Populate response element.
                // Add response element to the response parameter.
********************************************************************************/

@isTest
public class GlUt_WebServiceMockProvider_Test implements WebServiceMock {
    public static String MOCK_PROVIDER_NAME = '' ;	//TO ASSIGN FROM THE TEST CLASS
    //Request Name for Retrieving BenefitStatus Subset Web Service
    public static FINAL String RETRIEVE_BENEFIT_STATUS 	= 'CuIn_CentrelinkCustomerConfirmationWS.retrieveBenefitStatusSubset' ;	
    //Request Name for Retrieving IncomeDetails Web Service
    public static FINAL String RETRIEVE_INCOME_DETAILS 	= 'CuIn_CentrelinkCustomerConfirmationWS.retrieveIncomeDetails' ;
    //Request Name for verifying DvaDetails Web Service
    public static FINAL String VERIFY_DVA_DETAILS 	= 'CuIn_CentrelinkCustomerConfirmationWS.verifyDvaDetails' ;
    //Request Name for verifying NameAddress Web Service
    public static FINAL String VERIFY_NAME_ADDRESS 	= 'CuIn_CentrelinkCustomerConfirmationWS.verifyNameAddress' ;
    

    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           21 Dec 2018
	@parameter		Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, 
                    String requestName, String responseNS, String responseName, String responseType
	@return			void
    @description    doInvoke - to return mock SOAP response
    *******************************************************************************/ 
    public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, 
                         String requestName, String responseNS, String responseName, String responseType) {
         
		//frame retrieveBenefitStatusSubsetResultDto mock response
    	if(MOCK_PROVIDER_NAME.equalsIgnoreCase(RETRIEVE_BENEFIT_STATUS)) {
        	CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResultDto benefitStatusSubsetResultDto = new CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResultDto() ;
            benefitStatusSubsetResultDto.inputRefId 	= null ;
            benefitStatusSubsetResultDto.crn			= '123456789ABCDX' ;
            benefitStatusSubsetResultDto.cnfrmDate 		= System.today() ;
            benefitStatusSubsetResultDto.pcc		 	= null ;
            benefitStatusSubsetResultDto.hcc		 	= null ;
            benefitStatusSubsetResultDto.shc		 	= null ;
            benefitStatusSubsetResultDto.lic		 	= null ;
            benefitStatusSubsetResultDto.deceased 		= null ;
            benefitStatusSubsetResultDto.pcode	 		= null ; 
            benefitStatusSubsetResultDto.scndryCrn 		= null ;
            CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResult_element responseElement = new CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResult_element() ;
            responseElement.retrieveBenefitStatusSubsetResultDto = benefitStatusSubsetResultDto ;
            response.put('response_x', responseElement);   
            system.debug('response=> ' + response);
        } else if(MOCK_PROVIDER_NAME.equalsIgnoreCase(RETRIEVE_INCOME_DETAILS)) {	//frame retrieveIncomeDetails mock response
        	CuIn_CentrelinkIncomeDetailsResultDto.retrieveIncomeDetailsResultDto resultDto = new CuIn_CentrelinkIncomeDetailsResultDto.retrieveIncomeDetailsResultDto() ;
            resultDto.inputRefId 				= null ;
            resultDto.crn						= '123456789ABCDX' ;
            resultDto.cnfrmDate 				= System.today() ;
            resultDto.orgRefNumber				= null ;
            resultDto.firstName		 			= null ;
            resultDto.surname		 			= null ;
            resultDto.dob		 				= System.today().addYears(-30) ;
            resultDto.postcodeMatchIndicator 	= null ;
            resultDto.partnerIndicator	 		= null ; 
            resultDto.paidAtSingleRateIndicator = null ;
            CuIn_CentrelinkIncomeDetailsResultDto.retrieveIncomeDetailsResult_element responseElement = new CuIn_CentrelinkIncomeDetailsResultDto.retrieveIncomeDetailsResult_element() ;
            responseElement.retrieveIncomeDetailsResultDto = resultDto ;
            response.put('response_x', responseElement);   
            system.debug('response=> ' + response);
        } else if(MOCK_PROVIDER_NAME.equalsIgnoreCase(VERIFY_DVA_DETAILS)) {	//frame verifyDvaDetails mock response
        	CuIn_CentrelinkDvaDetailsResultDto.verifyDvaDetailsResultDto resultDto = new CuIn_CentrelinkDvaDetailsResultDto.verifyDvaDetailsResultDto() ;
            resultDto.inputRefId 		= null ;
            resultDto.custId			= '123456789ABCDX' ;
            resultDto.cnfrmDate 		= System.today() ;
            resultDto.orgType			= null ;
            resultDto.pcc		 		= null ;
            resultDto.shc		 		= null ;
            resultDto.dob		 		= String.valueOf(System.today().addYears(-30)) ;
            resultDto.deceased 			= null ;
            resultDto.rateRatio	 		= null ; 
            resultDto.pymtStartDate	 	= null ;
            CuIn_CentrelinkDvaDetailsResultDto.verifyDvaDetailsResult_element responseElement = new CuIn_CentrelinkDvaDetailsResultDto.verifyDvaDetailsResult_element() ;
            responseElement.verifyDvaDetailsResultDto = resultDto ;
            response.put('response_x', responseElement);   
            system.debug('response=> ' + response);
        } else if(MOCK_PROVIDER_NAME.equalsIgnoreCase(VERIFY_NAME_ADDRESS)) {	//frame verifyNameAddressResult mock response
        	CuIn_CentrelinkNameAddressResultDto.verifyNameAddressResultDto resultDto = new CuIn_CentrelinkNameAddressResultDto.verifyNameAddressResultDto() ;
            resultDto.inputRefId 		= null ;
            resultDto.crn 				= '123456789ABCDX' ;
            resultDto.name				= 'TestName' ;
            resultDto.cnfrmDate 		= System.today() ;
            CuIn_CentrelinkNameAddressResultDto.verifyNameAddressResult_element responseElement = new CuIn_CentrelinkNameAddressResultDto.verifyNameAddressResult_element() ;
            responseElement.verifyNameAddressResultDto = resultDto ;
            response.put('response_x', responseElement);   
            system.debug('response=> ' + response);
        } else {	//Negative test response
        	CalloutException ex = new CalloutException() ;
            ex.setMessage('Exception found') ;
            throw ex ;
        }
    }
}