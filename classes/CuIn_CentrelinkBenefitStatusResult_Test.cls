/*******************************************************************************
@author         Echo: Sudhir Kumar
@date           27 Dec 2018
@group 			Test Class
@description    Test class for CuIn_CentrelinkBenefitStatusSubResultDto class
				//This is just a DTO instantiation. So there should not be need to positive/negative scenrios.
				//So that we have some coverage, this is created because these(some) DTO are not being used in any of current Concession interfaces.
********************************************************************************/
@isTest
private class CuIn_CentrelinkBenefitStatusResult_Test {
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           21 Dec 2018
    @description    Test scenario for retrieveBenefitStatusSubsetResult_element
    *******************************************************************************/ 
    static testmethod void testRetrieveBenefitStatusSubsetResultDto() {
        CuIn_CentrelinkBenefitStatusSubResultDto resultDto = new CuIn_CentrelinkBenefitStatusSubResultDto() ;
        //cardDetailsResultDto
        list<CuIn_CentrelinkBenefitStatusSubResultDto.cardDetailsResultDto> listCardDetailsResultDto = new list<CuIn_CentrelinkBenefitStatusSubResultDto.cardDetailsResultDto>() ;
        CuIn_CentrelinkBenefitStatusSubResultDto.cardDetailsResultDto cardDetailsResultDto = new CuIn_CentrelinkBenefitStatusSubResultDto.cardDetailsResultDto() ;
        cardDetailsResultDto.cardType 		= 'TestCardType' ;
        cardDetailsResultDto.entStartDate 	= String.valueOf(System.today()) ;
        cardDetailsResultDto.entEndDate 	= String.valueOf(System.today() + 7) ;
        listCardDetailsResultDto.add(cardDetailsResultDto) ;
        system.assert(!listCardDetailsResultDto.isEmpty()) ;
        //paymentDetailsResultDto
        list<CuIn_CentrelinkBenefitStatusSubResultDto.paymentDetailsResultDto> listPaymentDetailsResultDto = new list<CuIn_CentrelinkBenefitStatusSubResultDto.paymentDetailsResultDto>() ;
        CuIn_CentrelinkBenefitStatusSubResultDto.paymentDetailsResultDto paymentDetailsResultDto = new CuIn_CentrelinkBenefitStatusSubResultDto.paymentDetailsResultDto() ;
        paymentDetailsResultDto.pymtType 		= 'TestPaymentType' ;
        paymentDetailsResultDto.pymtStatus 		= 'TestStatus' ;
        paymentDetailsResultDto.pymtStartDate 	= String.valueOf(System.today()) ; 
        paymentDetailsResultDto.pymtEndDate 	= String.valueOf(System.today() + 7) ;
        paymentDetailsResultDto.datePaidTo 		= String.valueOf(System.today() + 2) ;
        paymentDetailsResultDto.maxRate 		= '10' ;
        paymentDetailsResultDto.rateRatio 		= '1' ;
        paymentDetailsResultDto.rateThold 		= '5' ;
        listPaymentDetailsResultDto.add(paymentDetailsResultDto) ;
        system.assert(!listPaymentDetailsResultDto.isEmpty()) ;
        //retrieveBenefitStatusSubsetResultDto
        CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResultDto benefitStatusResultDto = new CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResultDto() ;
        benefitStatusResultDto.cardDetails = listCardDetailsResultDto ;
        benefitStatusResultDto.paymentDetails = listPaymentDetailsResultDto ;
        system.assert(benefitStatusResultDto.paymentDetails != null) ;
        //retrieveBenefitStatusSubsetResult_element
        CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResult_element benefitStatusSubsetResult_element = new CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResult_element() ;        
        system.assert(benefitStatusSubsetResult_element != null) ;
    }
}