/******************************************************************************
@author        Accenture: Vivek
@date          28th September 2017
@description   This class is used to generate Mock repsonse for pdf generator
*******************************************************************************/
@isTest
global class GlUt_MockHttpPdfGenerator_Test implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://real-time-billing-app-dev.herokuapp.com/realtime/pdf/generate', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody('{"pdf":"generate"}');
        res.setStatusCode(200);
        return res;
    }
}