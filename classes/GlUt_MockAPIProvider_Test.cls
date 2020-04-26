/*********************************************************************************************
@author      Accenture: Sucharu Gupta  
@date        08/09/2017    
@description: This class will be use in unit testing the integration API calls  
@group MockAPIProvider
Revision(s):  Shivangi Gaur -- 20-Dec-2017 -- Incorporated review comments on AT-456 dated 19/Dec/2017.
              Shivangi Gaur -- 05-Jan-2017 -- Incorporated review comments on AT-456 dated 03/Jan/2018. 
**********************************************************************************************/
@isTest
public class GlUt_MockAPIProvider_Test implements HttpCalloutMock  {

    // 20 Dec 2017, Shivangi Gaur - GlUt_MockAPIProvider_Test constants
    private static final string MOCK_RESPCODE = 'responseCode';// Changed By Dependra
    private static final string MOCK_HEADER = 'headers';
    private static final string MOCK_BODY = 'body';
    public class ResponseJson  {
        public Integer responseCode ; 
        public Map<String, Object> headers ; 
        public Map<String, Object> body ;  
    }
    
    public ResponseJson response = new ResponseJson();
    public GlUt_MockAPIProvider_Test(String resourceName) {   
        buildResponseFromResource(resourceName) ;
    }
     /*
    * @description Builds the response based on the static resource.
    */
    public void buildResponseFromResource(String resourceName) {
        System.debug('resourceName === '+resourceName);
        List<StaticResource> res = new List<StaticResource>();
        //StaticResource res = [SELECT Id, Body FROM StaticResource WHERE Name = :resourceName] ; 
        //Changed By Tarun on 30/Jan/2018 
        //Made changes to take a list Instead as there are chances that the Select statement doesn't return any record so excpetion is thrown.
         res = [SELECT Id, Body FROM StaticResource WHERE Name = :resourceName] ; 
        System.debug('res === '+res);
        if(res != null && res.size() > 0){ // Changed by Dependra 
            Map<String , Object>  o = (Map<String , Object>) JSON.deserializeUntyped(res[0].body.toString()) ;
            
            system.debug('oooooo ==== '+o);
            response = new ResponseJson() ; 
            if (o.get(MOCK_RESPCODE) != null){
                response.responseCode = (Integer) o.get(MOCK_RESPCODE) ; 
            }            
            if (o.get(MOCK_HEADER) != null){
                response.headers =  (Map<String, Object>) o.get(MOCK_HEADER) ; 
            }            
            if (o.get(MOCK_BODY) != null){
                
                response.body = (Map<String , Object> )o.get(MOCK_BODY) ; 
            }
            System.debug('response === '+response);       
        }
    }
    /*
    * @return Populate the HttpResponse object and return it base on the content of the static resource. 
    */ 
    public HttpResponse populateResponse() {
        System.debug('inside populate');
        HttpResponse r = new HttpResponse() ;
        // Added By Dependra
        if(response.responseCode != null){
            r.setStatusCode(response.responseCode) ; 
        }
        if (response.headers != null) {
            for (String s : response.headers.keySet() ){
                r.setHeader(s, (String) response.headers.get(s)) ; 
            }
        }
        if(response.body != null) {
            r.setBody(JSON.serializePretty(response.body)) ; 
        }
        System.debug('r ==== '+r);
        return r; 
       
    }
    public HTTPResponse respond(HTTPRequest req){
        return populateResponse(); 
    }
}