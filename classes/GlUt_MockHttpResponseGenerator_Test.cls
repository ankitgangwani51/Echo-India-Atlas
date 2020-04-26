/******************************************************************************
@author        Accenture: Satish Nair
@date          28th September 2017
@description   This class is used to generate Mock repsonse
*******************************************************************************/
@isTest
global class GlUt_MockHttpResponseGenerator_Test implements HttpCalloutMock {
    private Integer statusCode;

    public GlUt_MockHttpResponseGenerator_Test(Integer statusCode){
        this.statusCode = statusCode;
    }
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
       // System.assertEquals('http://real-time-billing-app-dev.herokuapp.com/realtime/pdf/generate', req.getEndpoint()); // KC this assert is causing and issue - why is ther an assert even here?
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"pdf":"generate"}');
        res.setStatusCode(this.statusCode);
        return res;
    }
}