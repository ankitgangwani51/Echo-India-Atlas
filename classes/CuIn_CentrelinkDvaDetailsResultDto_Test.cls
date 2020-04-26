/*******************************************************************************
@author         Echo: Sudhir Kumar
@date           02 Jan 2019
@group 			Test Class
@description    Test class for CuIn_CentrelinkDvaDetailsResultDto class
				//This is just a DTO instantiation. So there should not be need to positive/negative scenrios.
				//So that we have some coverage, this is created because these DTO are not being used in any of current Concession interfaces.
********************************************************************************/

@isTest
private class CuIn_CentrelinkDvaDetailsResultDto_Test {
	/******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           02 Jan 2019
    @description    Test scenario for verifyDvaDetailsResult_element
    *******************************************************************************/ 
    static testmethod void testRetrieveIncomeDetailsDto() {
        //verifyDvaDetailsResultDto
        CuIn_CentrelinkDvaDetailsResultDto.verifyDvaDetailsResultDto verifyDvaDetailsResultDto = new CuIn_CentrelinkDvaDetailsResultDto.verifyDvaDetailsResultDto() ;
        //verifyDvaDetailsResult_element
        CuIn_CentrelinkDvaDetailsResultDto.verifyDvaDetailsResult_element incomeDetailsElement = new CuIn_CentrelinkDvaDetailsResultDto.verifyDvaDetailsResult_element() ;   
        incomeDetailsElement.verifyDvaDetailsResultDto = verifyDvaDetailsResultDto ;
        system.assert(incomeDetailsElement.verifyDvaDetailsResultDto != null) ;
    }
}