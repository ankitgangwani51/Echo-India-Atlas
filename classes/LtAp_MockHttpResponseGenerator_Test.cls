/******************************************************************************
@author        Echo: Amit K.
@date          06-March-2018
@description   This class is used to generate Mock repsonse for HTML TO PDF
*******************************************************************************/
@isTest
global class LtAp_MockHttpResponseGenerator_Test implements HttpCalloutMock {
    private Integer statusCode;
    
    public LtAp_MockHttpResponseGenerator_Test(Integer statusCode){
        this.statusCode = statusCode;
    }
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/html');
        res.setBody('<html><div>Dummy HTML String</div></html>');
        res.setStatusCode(this.statusCode);
        return res;
    }
}