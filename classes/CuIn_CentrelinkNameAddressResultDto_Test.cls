/*******************************************************************************
@author         Echo: Sudhir Kumar
@date           02 Jan 2019
@group 			Test Class
@description    Test class for CuIn_CentrelinkNameAddressResultDto class
				//This is just a DTO instantiation. So there should not be need to positive/negative scenrios.
				//So that we have some coverage, this is created because these DTO are not being used in any of current Concession interfaces.
********************************************************************************/
@isTest
private class CuIn_CentrelinkNameAddressResultDto_Test {
	/******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           02 Jan 2019
    @description    Test scenario for verifyNameAddressResult_element
    *******************************************************************************/ 
    static testmethod void testRetrieveIncomeDetailsDto() {
        //verifyNameAddressResultDto
        CuIn_CentrelinkNameAddressResultDto.verifyNameAddressResultDto verifyNameAddressResultDto = new CuIn_CentrelinkNameAddressResultDto.verifyNameAddressResultDto() ;
        //verifyNameAddressResult_element
        CuIn_CentrelinkNameAddressResultDto.verifyNameAddressResult_element incomeDetailsElement = new CuIn_CentrelinkNameAddressResultDto.verifyNameAddressResult_element() ;   
        incomeDetailsElement.verifyNameAddressResultDto = verifyNameAddressResultDto ;
        system.assert(incomeDetailsElement.verifyNameAddressResultDto != null) ;
    }
}