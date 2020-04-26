/*****************************************************************************
	 * Expected XML of ContactRequest
	  -------------------------------
        <ContactRequest>
            <accountId>0011v000022RhdBAAS</accountId> //use a valid Account Id
            <firstName birthdate="1989-02-08">Sudhir</firstName>
            <lastName>Kumar</lastName>
        </ContactRequest>

	 Expected XML of ContactResponse
	 -------------------------------
		<ContactResponse>
          <contactId>0031v000021rO86AAE</contactId> //contains a valid Contact Id
          <message code="1">Success</message>
        </ContactResponse>

	Sample Actual SOAP Request payload - Generated from SOAPUI
	-----------------------------------------------------------

	<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tes="http://soap.sforce.com/schemas/class/TestSOAPAttributes_POC">
       <soapenv:Header>
          <tes:SessionHeader>
             <tes:sessionId>A_VALID_SESSION_ID</tes:sessionId>
          </tes:SessionHeader>
       </soapenv:Header>
       <soapenv:Body>
          <tes:createContact>
             <tes:oContactRequest>
                <!--Optional:-->
                <tes:accountId>0011v000022RhdBAAS</tes:accountId>
                <!--Optional:-->
                <tes:birthdate>1989-08-02</tes:birthdate>
                <!--Optional:-->
                <tes:firstName>Sudhir</tes:firstName>
                <!--Optional:-->
                <tes:lastName>Kumar</tes:lastName>
             </tes:oContactRequest>
          </tes:createContact>
       </soapenv:Body>
    </soapenv:Envelope>

	Sample Actual SOAP Response payload - Generated from SOAPUI
	-----------------------------------------------------------
	<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="http://soap.sforce.com/schemas/class/TestSOAPAttributes_POC">
       <soapenv:Body>
          <createContactResponse>
             <result>
                <code>1</code>
                <contactId>0031v000021rO86AAE</contactId>
                <message>Success</message>
             </result>
          </createContactResponse>
       </soapenv:Body>
    </soapenv:Envelope>
*****************************************************************************/

global with sharing class TestSOAPAttributes_POC {
    
    global class ContactRequest {
        webservice String accountId ;
        webservice String firstName ;
        webservice String lastName ;
        webservice String birthdate ; //Expectation is: To set it as an attribute of firstName
    }
    global class ContactResponse {
        webservice String contactId ;
        webservice String message ;
        webservice String code ; //Expectation is: To set it as an attribute of message
    }
    
     webservice static ContactResponse createContact(ContactRequest oContactRequest) {
		 Contact oContact = new Contact(AccountId = oContactRequest.accountId, FirstName = oContactRequest.firstName, 
                                         LastName = oContactRequest.LastName, birthdate = Date.valueOf(oContactRequest.Birthdate)) ;       
         insert oContact ;
         ContactResponse oContactResponse = new ContactResponse() ;
         oContactResponse.contactId = oContact.Id ;
         oContactResponse.message	= 'Success' ;
         oContactResponse.code	 	= '1' ;
         return oContactResponse ;
    }
}