/*******************************************************************************
@author         Echo: Sudhir Kumar
@date           02 Jan 2019
@group 			Test Class
@description    Test class for CuIn_CentrelinkDvaDetailsDto class
				//This is just a DTO instantiation. So there should not be need to positive/negative scenrios.
				//So that we have some coverage, this is created because these DTO are not being used in any of current Concession interfaces.
********************************************************************************/
@isTest
private class CuIn_CentrelinkDvaDetailsDto_Test {
	/******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           02 Jan 2019
    @description    Test scenario for verifyDvaDetails_element
    *******************************************************************************/ 
    static testmethod void testRetrieveIncomeDetailsDto() {
        //verifyDvaDetailsDto
        CuIn_CentrelinkDvaDetailsDto.verifyDvaDetailsDto verifyDvaDetailsDto = new CuIn_CentrelinkDvaDetailsDto.verifyDvaDetailsDto() ;
        //verifyDvaDetails_element
        CuIn_CentrelinkDvaDetailsDto.verifyDvaDetails_element verifyDvaDetailsElement = new CuIn_CentrelinkDvaDetailsDto.verifyDvaDetails_element() ;   
        verifyDvaDetailsElement.verifyDvaDetailsDto = verifyDvaDetailsDto ;
        system.assert(verifyDvaDetailsElement.verifyDvaDetailsDto != null) ;
    }
}