@RestResource(urlMapping='/CustomerRequest/*')
global with sharing class LoIn_ReqInformationStatement_POC2 {
	@HttpPost
    global static String doPost(String requestPayload) {
        system.debug('requestPayload=> ' + requestPayload);
        
        String response = '<?xml version="1.0" encoding="UTF-8"?>' +
                    '<CustodianResponses>' +
                        '<CustodianResponse>' +
                            '<AgentReference>' +
                                '<ApplicationId>1249874</ApplicationId>' +
                                '<CertificateNumber>006</CertificateNumber>' +
                                '<CheckNumber>3</CheckNumber>' +
                            '</AgentReference>' +
                            '<MessageType>ACK</MessageType>' +
                            '<OrderStatus code="InProgress">Expect completion by Thursday 27/11/2003.</OrderStatus>' +
                            '<CustodianReferences>' +
                                '<CustodianReference>31092</CustodianReference>' +
                            '</CustodianReferences>' +
                            '<TimeStamp>2003-11-22T12:54:03</TimeStamp>' +
                        '</CustodianResponse>' +
                    '</CustodianResponses>' ;
        return response ;
    }
}