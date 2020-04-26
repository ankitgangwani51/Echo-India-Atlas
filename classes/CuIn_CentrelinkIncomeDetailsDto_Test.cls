/*******************************************************************************
@author         Echo: Sudhir Kumar
@date           02 Jan 2019
@group 			Test Class
@description    Test class for CuIn_CentrelinkIncomeDetailsDto class
				//This is just a DTO instantiation. So there should not be need to positive/negative scenrios.
				//So that we have some coverage, this is created because these DTO are not being used in any of current Concession interfaces.
********************************************************************************/
@isTest
private class CuIn_CentrelinkIncomeDetailsDto_Test {
	/******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           02 Jan 2019
    @description    Test scenario for retrieveIncomeDetails_element
    *******************************************************************************/ 
    static testmethod void testRetrieveIncomeDetailsDto() {
        //retrieveIncomeDetailsDto
        CuIn_CentrelinkIncomeDetailsDto.retrieveIncomeDetailsDto incomeDetailsDto = new CuIn_CentrelinkIncomeDetailsDto.retrieveIncomeDetailsDto() ;
        //retrieveIncomeDetails_element
        CuIn_CentrelinkIncomeDetailsDto.retrieveIncomeDetails_element incomeDetailsElement = new CuIn_CentrelinkIncomeDetailsDto.retrieveIncomeDetails_element() ;   
        incomeDetailsElement.retrieveIncomeDetailsDto = incomeDetailsDto ;
        system.assert(incomeDetailsElement.retrieveIncomeDetailsDto != null) ;
    }
}