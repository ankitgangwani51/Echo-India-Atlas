/******************************************************************************
@author        Echo: Sudhir Kumar
@date          21-Nov-2018
@description   This class is used to generate Mock repsonse for LoIn_InfoStatementResponseContainer from LoAp_InfoStatementCalculateChargesCtrlr
*******************************************************************************/
@isTest
public class LoIn_MockHttpResponseGenerator_Test implements HttpCalloutMock {
	private Integer statusCode ;
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           21-Nov-2018
    @param          Integer statusCode
    @return         none
    @description    Constructor
    *******************************************************************************/ 
    public LoIn_MockHttpResponseGenerator_Test(Integer statusCode) {
        this.statusCode = statusCode ;
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           21-Nov-2018
    @param          HttpRequest request
    @return         HttpResponse response
    @description    Method called frame mock http response
    *******************************************************************************/  
    public HttpResponse respond(HttpRequest request) {
        system.debug('LoIn_MockHttpResponseGenerator_Test-request= ' + request);
        //Create Mock response
        HttpResponse response = new HttpResponse() ;
        response.setStatusCode(statusCode) ;
        response.setHeader('Content-Type', 'text/html') ;
        if(statusCode == 200) {
            response.setBody('<html><div>Success</div></html>') ;	//with body content
        } else {
            response.setBody('') ;	//Empty body
        }
        return response ;
    }
}