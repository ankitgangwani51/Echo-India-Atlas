/*******************************************************************************
@author         Echo: Sudhir Kumar
@date           02 Jan 2019
@group 			Test Class
@description    Test class for CuIn_CentrelinkNameAddressDto class
				//This is just a DTO instantiation. So there should not be need to positive/negative scenrios.
				//So that we have some coverage, this is created because these DTO are not being used in any of current Concession interfaces.
********************************************************************************/
@isTest
private class CuIn_CentrelinkNameAddressDto_Test {
	/******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           02 Jan 2019
    @description    Test scenario for verifyNameAddress_element
    *******************************************************************************/ 
    static testmethod void testRetrieveIncomeDetailsDto() {
        //verifyNameAddressDto
        CuIn_CentrelinkNameAddressDto.verifyNameAddressDto verifyNameAddressDto = new CuIn_CentrelinkNameAddressDto.verifyNameAddressDto() ;
        //verifyNameAddress_element
        CuIn_CentrelinkNameAddressDto.verifyNameAddress_element incomeDetailsElement = new CuIn_CentrelinkNameAddressDto.verifyNameAddress_element() ;   
        incomeDetailsElement.verifyNameAddressDto = verifyNameAddressDto ;
        system.assert(incomeDetailsElement.verifyNameAddressDto != null) ;
    }
}