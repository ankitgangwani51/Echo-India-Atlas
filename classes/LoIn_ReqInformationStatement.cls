/******************************************************************************
@author         Echo: Sudhir Kumar
@date           26 Nov 2018
@description    SOAP WS class for Information Statement Request from LanData/ SAI Global
                AT-3509: Receive requests for information statements so the information statement requests can be handled by an agent
                AT-4432 (AU2): Create a New Utility Class LoIn_ReqInformationStatement
******************************************************************************/

/******************************************************************************
XML Hierarchy
----------------
CustomerRequests
    -> CustomerRequest
        -> AgentReference
        -> Agent
        -> MessageType
        -> CustomerReference
        -> PropertyPfi
        -> SettlementDate       
        -> PropertyAddress
        -> Municipality
        -> Titles
        -> LotPlansAndCrownAllotments
        -> CustodianIdentifiers
        -> MapReferences
        -> ProprietorNames
        -> CertificateName
        -> TimeStamp
    -> CustomerRequest
CustomerRequests

******************************************************************************/ 

/**************************************
TO DO LIST:
~~~~~~~~~~
1. Code refactoring, if required
2. Replacing har coded values
3. Test Classes
 **************************************/

global with sharing class LoIn_ReqInformationStatement {
    
    // utility methods to cope with null values in the response
    private static Date dateEscapeNull(String s) {return s != null ? Date.valueOf(s) : null;}
    private static Decimal decimalEscapeNull(String s) {return s != null ? Decimal.valueOf(s) : null;}
    private static Integer integerEscapeNull(String s) {return s != null ? Integer.valueOf(s) : null;}
    private static Boolean booleanEscapeNull(String s) {return s != null ? s.toLowerCase() == 'true' : false;}
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           26 Nov 2018
    @param          CustodianRequest custodianRequest, String messageString
    @return         CustodianResponses
    @description    getCustodianResponses - method used to frame and return Custodian Response Payload
    *******************************************************************************/
    global static CustodianResponses getCustodianResponses(CustodianRequest custodianRequest, String messageString) {
        CustodianResponses response = new CustodianResponses() ;
        response.CustodianResponse  = new CustodianResponse() ;
        response.CustodianResponse.AgentReference = new AgentReference() ;
        response.CustodianResponse.AgentReference.ApplicationId = custodianRequest.AgentReference.ApplicationId ;
        response.CustodianResponse.AgentReference.CertificateNumber = custodianRequest.AgentReference.CertificateNumber ;
        response.CustodianResponse.AgentReference.CheckNumber = custodianRequest.AgentReference.CheckNumber ;
        response.CustodianResponse.MessageType = 'ACK' ;
        //response.CustodianResponse.OrderStatus = 'Completed' + ' ' +  System.today() ;
        response.CustodianResponse.OrderStatus = new OrderStatus() ;
        response.CustodianResponse.OrderStatus.Status = 'Under Review' ;
        response.CustodianResponse.OrderStatus.Code = 'InProgress' ;
        //response.CustodianResponse.OrderStatus = messageString + ' ' +  System.today() ;
        //response.CustodianResponse.OrderStatus.Code = 'InProgress' ;  // - code defined by custodian
        //response.CustodianResponse.CertificateType = 'PDF' ; // enums - pdf, txt
        response.CustodianResponse.CustodianReferences = new CustodianReferences() ;
        //response.CustodianResponse.CustodianReferences.CustodianReference = custodianRequest.CustodianIdentifiers.CustodianIdentifier.CustodianIdentifierId ;
        /*response.CustodianResponse.Exceptions = new Exceptions() ;
        response.CustodianResponse.Exceptions.Exception_x = new Exception_x() ;
        if(messageString.containsIgnoreCase('Success'))
            response.CustodianResponse.Exceptions.Exception_x.code = '0' ;
        else
            response.CustodianResponse.Exceptions.Exception_x.code = '-1' ;
        */
        response.CustodianResponse.TimeStamp = String.valueOf(System.now()) ;
        return response ;
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           26 Nov 2018
    @param          ParsedAddress parsedAddress
    @return         String - locationId
    @description    getLocationId - parse ParsedAddress and query to get existing Location ID based on PostalCode
    *******************************************************************************/
    global static String getLocationId(ParsedAddress parsedAddress) {
        String locationId = '' ;
        list<Location__c> listLocation = [SELECT Id, PostalCode__c, Street__c FROM Location__c WHERE PostalCode__c =: parsedAddress.Postcode] ;
        if(listLocation != null && !listLocation.isEmpty()) {
            if(listLocation.size() > 1) {
                locationId = 'Error: Multiple locations are found' ;
            } else {
                locationId = listLocation[0].Id ;
            }
        }
        system.debug('locationId=> ' + locationId);
        return locationId ;
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           11 Dec 2018
    @param          CustodianRequests custodianRequests
    @return         CustodianResponses
    @description    routeMessageType - route to different logic based on MessageType = 'REQ->ACK' or 'STA->CER'
    *******************************************************************************/
    static CustodianResponses processCustomerRequest(CustodianRequests custodianRequests) {
        String responseMessage = '' ;
        
        CustodianResponses custodianResponses = getCustodianResponses(custodianRequests.CustodianRequest, responseMessage) ;
        system.debug('custodianResponses=> ' + custodianResponses);
        return custodianResponses ;
    }
    static CustodianResponses getCustodianCertificateStatus(CustodianRequests custodianRequests) {
        String responseMessage = '' ;
        
        CustodianResponses custodianResponses = getCustodianResponses(custodianRequests.CustodianRequest, responseMessage) ;
        system.debug('custodianResponses=> ' + custodianResponses);
        return custodianResponses ;
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           26 Nov 2018
    @param          CustodianRequests custodianRequests
    @return         CustodianResponses
    @description    getInformationStatement - SOAP WS method exposed to get Custodian Request Payload
    *******************************************************************************/
    webservice static CustodianResponses getInformationStatement(CustodianRequests custodianRequests) {
        system.debug('custodianRequests=> ' + custodianRequests);
        system.debug('custodianRequests2=> ' + String.valueOf(custodianRequests)) ;
        system.debug('custodianRequests3=> ' + JSON.serialize(custodianRequests)) ;
        try {
            String responseMessage = '' ;
            InformationStatement__c infoStatementObj = null ;
            //STEP 1 -> Validate the custodianRequests data structure
            if(custodianRequests != null && custodianRequests.CustodianRequest != null) {
                CustodianRequest request = custodianRequests.CustodianRequest ;
                infoStatementObj = new InformationStatement__c(RequestXML__c = String.valueOf(custodianRequests),
                                                               Status__c = 'Under Review' //Will use Custom Label
                                                              ) ;
                //infoStatementObj.RequestXML__c = GlUt_XMLSerialiser.serialize((Object) custodianRequests).escapeXml() ;
                infoStatementObj.RequestXML__c = GlUt_XMLSerialiser.serialize((Object) custodianRequests) ;
                system.debug('infoStatementObj.RequestXML=> ' + infoStatementObj.RequestXML__c);
                //infoStatementObj.Source__c = String.isNotBlank(request.Agent) ? (request.Agent == 'LANDATA' ? 'LanData' : (request.Agent == 'SAI Global' ? 'SAIGlobal' : null)) : null ;
                infoStatementObj.Source__c = String.isNotBlank(request.Agent) ? request.Agent : null ;
                infoStatementObj.SettlementDate__c = String.isNotBlank(request.SettlementDate) ? dateEscapeNull(request.SettlementDate) : null ;
                if(request.PropertyAddress != null && request.PropertyAddress.ParsedAddress != null) {
                    String locationId = getLocationId(request.PropertyAddress.ParsedAddress) ;
                    if(String.isNotBlank(locationId) && !locationId.containsIgnoreCase('Error')) {
                        infoStatementObj.Location__c = locationId ;
                    } else {
                        responseMessage = locationId ;
                    }
                } else {
                    responseMessage = 'Error: ParsedAddress do not exist in the request payload' ;
                }
            } else {
                responseMessage = 'Error: CustodianRequest is empty in the request payload' ;
            }
            CustodianResponses custodianResponses = getCustodianResponses(custodianRequests.CustodianRequest, responseMessage) ;
            infoStatementObj.ResponseXML__c = GlUt_XMLSerialiser.serialize((Object) custodianResponses).escapeXml() ;
            Database.SaveResult saveResult = Database.insert(infoStatementObj, false) ;
            if(saveResult != null && !saveResult.isSuccess()) {
                Database.Error error = saveResult.getErrors()[0] ;
                responseMessage = error.getMessage() ;
                custodianResponses = getCustodianResponses(custodianRequests.CustodianRequest, responseMessage) ;
            }
            system.debug('custodianResponses=> ' + custodianResponses);
            return custodianResponses ;
        } /*catch(CalloutException calloutEx) {
            String calloutExString = String.valueOf(calloutEx) ;
            system.debug('calloutExString=> ' + calloutExString) ;
            if(calloutExString.contains('SOAPFault')) {
                DOM.Document doc = new DOM.Document() ;
                doc.load(calloutExString) ;
                system.debug('doc=> ' + doc) ;
                String calloutExXmlString = doc.toXmlString() ;
                system.debug('calloutExXmlString=> ' + calloutExXmlString);
            }
            return null ;
        }*/
        catch(Exception ex) {
            system.debug('Exception=> ' + ex);
            GlUt_Logger.logException(ex) ;
            return null ;
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           26 Nov 2018     
    @description    Wrapper class to structure the request payload
    *******************************************************************************/
    global class CustodianResponses {
         webservice CustodianResponse CustodianResponse ;   
        public override String toString() {
            return 'CustodianResponses' ;
        }
    }
    global class CustodianResponse {
        webservice AgentReference AgentReference ;
        webservice String MessageType ;
        webservice OrderStatus OrderStatus ;                        //OrderStatus(attribute=code) - wrapper : To check on this?
        //webservice String OrderStatus ;                           //OrderStatus(attribute=code) - wrapper
        webservice String CertificateType ;                         //CER
        webservice CustodianReferences CustodianReferences ;        //CustodianReferences - wrapper
        webservice Exceptions Exceptions ;                          //CER -> Exceptions(attribute=code) - wrapper
        webservice String TimeStamp ;
        public override String toString() {
            return 'CustodianResponse' ;
        }
    }
    global class OrderStatus {
        webservice String Status ;
        webservice String Code ;
    }
    global class CustodianReferences {
        webservice String CustodianReference ;
    }
    global class Exceptions {
        webservice Exception_x Exception_x ;
    }
    global class Exception_x {
        webservice String code ;
    }
    global class CustodianRequests {
        webservice CustodianRequest CustodianRequest ;
        public override String toString() {
            return 'CustodianRequests' ;
        }
    }
    global class CustodianRequest {
        webservice AgentReference AgentReference ;                              //AgentReference - wrapper
        webservice String Agent ;
        webservice String MessageType ;
        webservice String CustomerReference ;
        webservice String PropertyPfi ;
        webservice String SettlementDate ;
        webservice PropertyAddress PropertyAddress ;                            //PropertyAddress - wrapper
        webservice String Municipality ;
        webservice Titles Titles ;                                              //Titles - wrapper
        webservice LotPlansAndCrownAllotments LotPlansAndCrownAllotments ;      //LotPlansAndCrownAllotments - wrapper
        webservice CustodianIdentifiers CustodianIdentifiers ;                  //CustodianIdentifiers - wrapper
        webservice MapReferences MapReferences ;                                //MapReferences - wrapper
        webservice ProprietorNames ProprietorNames ;                            //ProprietorNames - wrapper
        webservice CertificateName CertificateName ;                            // CertificateName - wrapper
        webservice String TimeStamp ;
        public override String toString() {
            return 'CustodianRequest' ;
        }
    }
    
    global class AgentReference {
        webservice String ApplicationId ;
        webservice String CertificateNumber ;
        webservice String CheckNumber ;
    }
    global class PropertyAddress {
        webservice DisplayAddress DisplayAddress ;
        webservice ParsedAddress ParsedAddress ;
    }
    global class DisplayAddress {
        webservice String StreetLocation ;
        webservice String StreetName ;
        webservice String Suburb ;
        webservice String Postcode ;
    }
    global class ParsedAddress {
        webservice String UnitType ;
        webservice String UnitNumber1 ;
        webservice String StreetNumber1 ;
        webservice String StreetNumber2 ;
        webservice String Street ;
        webservice String StreetType ;
        webservice String Suburb ;
        webservice String Postcode ;
    }
    global class Titles {
        webservice Title Title ;
    }
    global class Title {
        webservice String VolumeFolio ;
    }
    global class LotPlansAndCrownAllotments {
        webservice LotPlan LotPlan ;
    }
    global class LotPlan {
        webservice String Lots ;
        webservice String PlanNumber ;
    }
    global class CustodianIdentifiers {
        webservice CustodianIdentifier CustodianIdentifier ;
    }
    global class CustodianIdentifier {
        webservice  String name;
        webservice String[] name_att_info = new String[]{'name'};
        webservice String type_x;
		webservice String[] type_x_att_info = new String[]{'type'};
            
        /*
        webservice String CustodianIdentifierId ;
        //webservice String Custodian ;   //attribute
        webservice String Type ;        //attribute
		*/
    }
    global class MapReferences {
        webservice MapReference MapReference ;
    }
    global class MapReference {
        webservice String MapEdition ;  //attribute
        webservice String MapName ;
        webservice String MapPage ;
        webservice String MapGrid ;
    }
    global class ProprietorNames {
        webservice String ProprietorName ;
    }
    global class CertificateName {
        webservice String Name ;
        webservice String code ;    //attribute
    }
}