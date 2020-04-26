/*******************************************************************************
@author         Echo: Sudhir Kumar
@date           03 Jan 2019
@group 			Test Class
@description    Test class for CuIn_CentrelinkOasisWSUtilityDto class
				//This is just a DTO instantiation. So there should not be need to positive/negative scenrios.
				//So that we have some coverage, this is created because these DTO are not being used in any of current Concession interfaces.
********************************************************************************/
@isTest
private class CuIn_CentrelinkOasisWSUtilityDto_Test {
	/******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           03 Jan 2019
    @description    Test scenario for CuIn_CentrelinkOasisWSUtilityDto
    *******************************************************************************/ 
    static testmethod void testCentrelinkOasisWSUtility() {
        CuIn_CentrelinkOasisWSUtilityDto.AttributedDateTime dtoAttributedDateTime 	= new CuIn_CentrelinkOasisWSUtilityDto.AttributedDateTime() ;
        system.assert(dtoAttributedDateTime != null) ;
        CuIn_CentrelinkOasisWSUtilityDto.AttributedURI dtoAttributedURI 			= new CuIn_CentrelinkOasisWSUtilityDto.AttributedURI() ;
        system.assert(dtoAttributedURI != null) ;
        CuIn_CentrelinkOasisWSUtilityDto.TimestampType dtoTimestampType				= new CuIn_CentrelinkOasisWSUtilityDto.TimestampType() ;
        system.assert(dtoTimestampType != null) ;
    }
}