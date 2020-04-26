/*******************************************************************************
@author         Echo: Sudhir Kumar
@date           02 Jan 2019
@group 			Test Class
@description    Test class for CuIn_CentrelinkMessagesTypeDto class
				//This is just a DTO instantiation. So there should not be need to positive/negative scenrios.
				//So that we have some coverage, this is created because these DTO are not being used in any of current Concession interfaces.
********************************************************************************/
@isTest
private class CuIn_CentrelinkMessagesTypeDto_Test {
	/******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           02 Jan 2019
    @description    Test scenario for retrieveIncomeDetails_element
    *******************************************************************************/ 
    static testmethod void testRetrieveIncomeDetailsDto() {
        //messageDto
        CuIn_CentrelinkMessagesTypeDto.messageDto messageDto = new CuIn_CentrelinkMessagesTypeDto.messageDto() ;
        list<CuIn_CentrelinkMessagesTypeDto.messageDto> messageDtoList = new list<CuIn_CentrelinkMessagesTypeDto.messageDto>() ;
        messageDtoList.add(messageDto) ;
        system.assert(messageDtoList != null) ;
        //messagesType
        CuIn_CentrelinkMessagesTypeDto.messagesType messagesType = new CuIn_CentrelinkMessagesTypeDto.messagesType() ;   
        messagesType.messageDto = messageDtoList ;
        //ServiceBusinessException_x
        CuIn_CentrelinkMessagesTypeDto.ServiceBusinessException_x serviceBusinessException_x = new CuIn_CentrelinkMessagesTypeDto.ServiceBusinessException_x() ;   
        serviceBusinessException_x.messageDto = messageDtoList ;
        //ServiceInfrastructureException_x
        CuIn_CentrelinkMessagesTypeDto.ServiceInfrastructureException_x serviceInfrastructureException_x = new CuIn_CentrelinkMessagesTypeDto.ServiceInfrastructureException_x() ;   
        serviceInfrastructureException_x.messageDto = messageDtoList ;
        //ServiceSecurityException_x
        CuIn_CentrelinkMessagesTypeDto.ServiceSecurityException_x serviceSecurityException_x = new CuIn_CentrelinkMessagesTypeDto.ServiceSecurityException_x() ;   
        serviceSecurityException_x.messageDto = messageDtoList ;
    }
}