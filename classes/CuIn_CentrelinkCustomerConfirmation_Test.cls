/*******************************************************************************
@author         Echo: Sudhir Kumar
@date           21 Dec 2018
@group 			Test Class
@description    Test class for CuIn_CentrelinkCustomerConfirmationWS class
********************************************************************************/

@isTest
public class CuIn_CentrelinkCustomerConfirmation_Test {
    public static FINAL String RETRIEVE_BENEFIT_STATUS = 'CuIn_CentrelinkCustomerConfirmationWS.retrieveBenefitStatusSubset' ;	
	
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           21 Dec 2018
    @description    Positive test scenario for retrieveBenefitStatusSubset method
    *******************************************************************************/ 
    static testmethod void testRetrieveBenefitStatusSubset_positive() {
        CuIn_CentrelinkCustomerConfirmationWS.customerConfirmationPort portService = new CuIn_CentrelinkCustomerConfirmationWS.customerConfirmationPort() ;
        CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResultDto resultDto = new CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResultDto() ;
        CuIn_CentrelinkBenefitStatusSubsetDto.retrieveBenefitStatusSubsetDto requestDto = new CuIn_CentrelinkBenefitStatusSubsetDto.retrieveBenefitStatusSubsetDto() ;
        
        Test.startTest() ;
        	Boolean isException = false ;
            try {
            	GlUt_WebServiceMockProvider_Test.MOCK_PROVIDER_NAME = RETRIEVE_BENEFIT_STATUS ;
                Test.setMock(System.WebServiceMock.class, new GlUt_WebServiceMockProvider_Test()) ;
                resultDto = portService.retrieveBenefitStatusSubset(requestDto) ;    
            } catch(Exception ex) {
                isException = true ;
            }
        	system.debug('+isException=> ' + resultDto);
        	system.assert(!isException) ;
        Test.stopTest() ;
        
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           21 Dec 2018
    @description    Negative test scenario for retrieveBenefitStatusSubset method
    *******************************************************************************/ 
    static testmethod void testRetrieveBenefitStatusSubset_negative() {
        CuIn_CentrelinkCustomerConfirmationWS.customerConfirmationPort portService 				= new CuIn_CentrelinkCustomerConfirmationWS.customerConfirmationPort() ;
        CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResultDto resultDto = new CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResultDto() ;
        CuIn_CentrelinkBenefitStatusSubsetDto.retrieveBenefitStatusSubsetDto requestDto 		= new CuIn_CentrelinkBenefitStatusSubsetDto.retrieveBenefitStatusSubsetDto() ;
        
        Test.startTest() ;
        	Boolean isException = false ;
            try {
                Test.setMock(System.WebServiceMock.class, new GlUt_WebServiceMockProvider_Test()) ;
                resultDto = portService.retrieveBenefitStatusSubset(requestDto) ;
                system.debug('resultDto=> ' + resultDto);
            } catch(Exception ex) {
                isException = true ;
            }
        	system.debug('-isException=> ' + resultDto);
        	system.assert(isException) ;
        	//To Do further
        Test.stopTest() ;
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           21 Dec 2018
    @description    Positive test scenario for retrieveIncomeDetails method
    *******************************************************************************/ 
    static testmethod void testRetrieveIncomeDetails_positive() {
        CuIn_CentrelinkCustomerConfirmationWS.customerConfirmationPort portService 		= new CuIn_CentrelinkCustomerConfirmationWS.customerConfirmationPort() ;
        CuIn_CentrelinkIncomeDetailsResultDto.retrieveIncomeDetailsResultDto resultDto 	= new CuIn_CentrelinkIncomeDetailsResultDto.retrieveIncomeDetailsResultDto() ;
        CuIn_CentrelinkIncomeDetailsDto.retrieveIncomeDetailsDto requestDto 			= new CuIn_CentrelinkIncomeDetailsDto.retrieveIncomeDetailsDto() ;
        Test.startTest() ;
        Boolean isException = false ;
            try {
                GlUt_WebServiceMockProvider_Test.MOCK_PROVIDER_NAME = GlUt_WebServiceMockProvider_Test.RETRIEVE_INCOME_DETAILS ;
                Test.setMock(System.WebServiceMock.class, new GlUt_WebServiceMockProvider_Test()) ;
                resultDto = portService.retrieveIncomeDetails(requestDto) ;
            } catch(Exception ex) {
                isException = true ;
            }
        system.debug('-isException=> ' + resultDto);
        system.assert(!isException) ;
        Test.stopTest() ;
        
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           21 Dec 2018
    @description    Positive test scenario for verifyDvaDetails method
    *******************************************************************************/ 
    static testmethod void testVerifyDvaDetails_positive() {
        CuIn_CentrelinkCustomerConfirmationWS.customerConfirmationPort portService = new CuIn_CentrelinkCustomerConfirmationWS.customerConfirmationPort() ;
        CuIn_CentrelinkDvaDetailsResultDto.verifyDvaDetailsResultDto resultDto 		= new CuIn_CentrelinkDvaDetailsResultDto.verifyDvaDetailsResultDto() ;
        CuIn_CentrelinkDvaDetailsDto.verifyDvaDetailsDto requestDto 				= new CuIn_CentrelinkDvaDetailsDto.verifyDvaDetailsDto() ;
        Test.startTest() ;
        	Boolean isException = false ;
            try {
                GlUt_WebServiceMockProvider_Test.MOCK_PROVIDER_NAME = GlUt_WebServiceMockProvider_Test.VERIFY_DVA_DETAILS ;
                Test.setMock(System.WebServiceMock.class, new GlUt_WebServiceMockProvider_Test()) ;
                resultDto = portService.verifyDvaDetails(requestDto) ;
            } catch(Exception ex) {
                isException = true ;
            }
        	system.debug('-isException=> ' + resultDto);
        	system.assert(!isException) ;
        Test.stopTest() ;
        
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           21 Dec 2018
    @description    Positive test scenario for verifyNameAddressResultDto method
    *******************************************************************************/ 
    static testmethod void testVerifyNameAddress_positive() {
        CuIn_CentrelinkCustomerConfirmationWS.customerConfirmationPort portService = new CuIn_CentrelinkCustomerConfirmationWS.customerConfirmationPort() ;
        CuIn_CentrelinkNameAddressDto.verifyNameAddressDto requestDto 				= new CuIn_CentrelinkNameAddressDto.verifyNameAddressDto() ;
        CuIn_CentrelinkNameAddressResultDto.verifyNameAddressResultDto resultDto 	= new CuIn_CentrelinkNameAddressResultDto.verifyNameAddressResultDto() ;
        Test.startTest() ;
        	Boolean isException = false ;
            try {
                GlUt_WebServiceMockProvider_Test.MOCK_PROVIDER_NAME = GlUt_WebServiceMockProvider_Test.VERIFY_NAME_ADDRESS ;
                Test.setMock(System.WebServiceMock.class, new GlUt_WebServiceMockProvider_Test()) ;
                resultDto = portService.verifyNameAddress(requestDto) ;
            } catch(Exception ex) {
                isException = true ;
            }
        	system.debug('-isException=> ' + resultDto);
        	system.assert(!isException) ;
        Test.stopTest() ;
        
    }
}