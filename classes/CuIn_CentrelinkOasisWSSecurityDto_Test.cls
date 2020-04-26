/*******************************************************************************
@author         Echo: Sudhir Kumar
@date           03 Jan 2019
@group 			Test Class
@description    Test class for CuIn_CentrelinkOasisWSSecurityDto class
				//This is just a DTO instantiation. So there should not be need to positive/negative scenrios.
				//So that we have some coverage, this is created because these DTO are not being used in any of current Concession interfaces.
********************************************************************************/
@isTest
private class CuIn_CentrelinkOasisWSSecurityDto_Test {
	/******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           03 Jan 2019
    @description    Test scenario for CuIn_CentrelinkOasisWSSecurityDto
    *******************************************************************************/ 
    static testmethod void testCentrelinkOasisWSSecurity() {
        CuIn_CentrelinkOasisWSSecurityDto.AttributedString dtoAttributedString 							= new CuIn_CentrelinkOasisWSSecurityDto.AttributedString() ;
        system.assert(dtoAttributedString != null) ;
        CuIn_CentrelinkOasisWSSecurityDto.BinarySecurityTokenType dtoBinarySecurityTokenType 			= new CuIn_CentrelinkOasisWSSecurityDto.BinarySecurityTokenType() ;
        system.assert(dtoBinarySecurityTokenType != null) ;
        CuIn_CentrelinkOasisWSSecurityDto.EmbeddedType dtoEmbeddedType 									= new CuIn_CentrelinkOasisWSSecurityDto.EmbeddedType() ;
        system.assert(dtoEmbeddedType != null) ;
        CuIn_CentrelinkOasisWSSecurityDto.EncodedString dtoEncodedString 								= new CuIn_CentrelinkOasisWSSecurityDto.EncodedString() ;
        system.assert(dtoEncodedString != null) ;
        CuIn_CentrelinkOasisWSSecurityDto.KeyIdentifierType dtoKeyIdentifierType 						= new CuIn_CentrelinkOasisWSSecurityDto.KeyIdentifierType() ;
        system.assert(dtoKeyIdentifierType != null) ;
        CuIn_CentrelinkOasisWSSecurityDto.PasswordString dtoPasswordString 								= new CuIn_CentrelinkOasisWSSecurityDto.PasswordString() ;
        system.assert(dtoPasswordString != null) ;
        CuIn_CentrelinkOasisWSSecurityDto.ReferenceType dtoReferenceType 								= new CuIn_CentrelinkOasisWSSecurityDto.ReferenceType() ;
        system.assert(dtoReferenceType != null) ;
        CuIn_CentrelinkOasisWSSecurityDto.SecurityHeaderType dtoSecurityHeaderType 						= new CuIn_CentrelinkOasisWSSecurityDto.SecurityHeaderType() ;
        system.assert(dtoSecurityHeaderType != null) ;
        CuIn_CentrelinkOasisWSSecurityDto.SecurityTokenReferenceType dtoSecurityTokenReferenceType 		= new CuIn_CentrelinkOasisWSSecurityDto.SecurityTokenReferenceType() ;
        system.assert(dtoSecurityTokenReferenceType != null) ;
        CuIn_CentrelinkOasisWSSecurityDto.TransformationParametersType dtoTransformationParametersType 	= new CuIn_CentrelinkOasisWSSecurityDto.TransformationParametersType() ;
        system.assert(dtoTransformationParametersType != null) ;
        CuIn_CentrelinkOasisWSSecurityDto.UsernameTokenType dtoUsernameTokenType 						= new CuIn_CentrelinkOasisWSSecurityDto.UsernameTokenType() ;
        system.assert(dtoUsernameTokenType != null) ;
    }
}