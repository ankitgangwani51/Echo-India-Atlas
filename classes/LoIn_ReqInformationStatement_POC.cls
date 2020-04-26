global class LoIn_ReqInformationStatement_POC {
	
    global class CustomerRequests {
         webservice list<String> CustomerRequest ;   
    }
    
    global class CustodianResponses {
        webservice list<String> CustodianResponse ;   
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           26 Nov 2018
    @param          CustodianRequest custodianRequest, String messageString
    @return         CustodianResponses
    @description    getCustodianResponses - method used to frame and return Custodian Response Payload
    *******************************************************************************/
    webservice static CustodianResponses getCustodianResponses(CustomerRequests customerRequests) {
        system.debug('CustomerRequests=> ' + String.valueOf(customerRequests)) ;
        String response = '' ;
        CustodianResponses resp = new CustodianResponses() ;
        resp.CustodianResponse = new list<String>() ;
        
        response = '<?xml version="1.0" encoding="UTF-8"?>' +
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
        resp.CustodianResponse.add(response) ;
        system.debug('CustodianResponses=> ' + String.valueOf(resp)) ;
        return resp ;
    }
    
}