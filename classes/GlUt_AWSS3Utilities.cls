/***************************************************************************************************
@author        Gopal Gupta	
@date          12-Apr-2018
@description:  This is a class for Amazon S3 utilities method. The init method must be overridden. 
@revision:	   Echo: Dependra Singh - 14-03-2019 -Meta data Setting updated.
*******************************************************************************************************/
public with sharing abstract class GlUt_AWSS3Utilities{
    
    //Set these values in init()
	public String host; 
    public String region; 
    public String service; 
    public String resource; 
    public String accessKey; 
    public String payloadSha256;
	public Url endpoint;
	public HttpMethod method;
	public Blob payload;
    //Local variables
	Blob signingKey;
	public DateTime requestTime;
	Map<String, String> queryParams;
    Map<String, String> headerParams;
    //Make sure we can't misspell methods
	public enum HttpMethod { XGET, XPUT, XHEAD, XDELETE, XPOST }
	//Post initialization logic (after constructor, before call)
    public abstract void init();
	
     /***************************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-June-2018
	@parameter	   
	@return		   
    @description:  Constructor
    *******************************************************************************************************/
	public  GlUt_AWSS3Utilities() {
		requestTime = DateTime.now();
		queryParams = new Map<String, String>();
		headerParams = new Map<String, String>();
		payload = Blob.valueOf('');
	}
    //Add a header
	public void setHeader(String key, String value) {
		headerParams.put(key.toLowerCase(), value);
	}
    //Add a query param
	public void setQueryParam(String key, String value) {
		queryParams.put(key.toLowerCase(), uriEncode(value));
	}
	
     /***************************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-June-2018
	@parameter	   
	@return		   String - Cannonical Header String
    @description:  This is used to Create a canonical query string (used during signing)
    *******************************************************************************************************/
	private String createCanonicalQueryString() {
		List<String> results = new List<String>(); 
        List<String> keys = new List<String>(queryParams.keySet());
        keys.sort();
        for(String key : keys) {
            results.add(key+'='+queryParams.get(key));
        }
        return String.join(results, '&');
	}
     /***************************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-June-2018
	@parameter	   List<String> keys
	@return		   String - Cannonical Header String
    @description:  This is used to Create the canonical headers (used for signing)
    *******************************************************************************************************/
	private String createCanonicalHeaders(List<String> keys) {
		keys.addAll(headerParams.keySet());
		keys.sort();
		List<String> results = new List<String>(); 
		for(String key : keys) {
			results.add(key+':'+headerParams.get(key));
		}
		return String.join(results, '\n')+'\n';
	}
	
    /***************************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-June-2018
	@parameter	   List<String> headerKeys
	@return		   String - Cannonical String
    @description:  This is used to Create the entire canonical request
    *******************************************************************************************************/
    
    
	private String createCanonicalRequest(List<String> headerKeys) {
		return String.join(
			new List<String> {
				method.name().removeStart('X'),			//METHOD
				new Url(endPoint, resource).getPath(),	//RESOURCE
				createCanonicalQueryString(),			//CANONICAL QUERY STRING
				createCanonicalHeaders(headerKeys),		//CANONICAL HEADERS
               	String.join(headerKeys, ';'),			//SIGNED HEADERS
				payloadSha256							//SHA256 PAYLOAD
			},
			'\n'
		);
	}
    
    /***************************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-June-2018
	@parameter	   String value
	@return		   String 
    @description:  This is used to replace ~ and " " correctly, or we'll break AWS on those two characters
    *******************************************************************************************************/
    
    //
    public String uriEncode(String value) {
        return value==null? null: EncodingUtil.urlEncode(value, 'utf-8').replaceAll('%7E','~').replaceAll('\\+','%20');
    }
    
    /***************************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-June-2018
	@parameter	   List<String> signedHeaders
	@return		   String
    @description:  This is used to Create the entire string to sign
    *******************************************************************************************************/
   
    private String createStringToSign(List<String> signedHeaders) {
        String result = createCanonicalRequest(signedHeaders);
        return String.join(
            new List<String> {
                'AWS4-HMAC-SHA256',
                headerParams.get('date'),
                String.join(new List<String> { requestTime.formatGMT('YYYYMMdd'), region, service, 'aws4_request' },'/'),
                EncodingUtil.convertToHex(Crypto.generateDigest('sha256', Blob.valueof(result)))
            },
            '\n'
        );
    }
    
    /***************************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-June-2018
	@parameter	   String secretKey
	@return		   
    @description:  This is used to Create our signing key
    *******************************************************************************************************/
    
    
    public void createSigningKey(String secretKey) {
        signingKey = Crypto.generateMac('hmacSHA256', Blob.valueOf('aws4_request'),
            Crypto.generateMac('hmacSHA256', Blob.valueOf(service),
                Crypto.generateMac('hmacSHA256', Blob.valueOf(region),
                    Crypto.generateMac('hmacSHA256', Blob.valueOf(requestTime.formatGMT('YYYYMMdd')), Blob.valueOf('AWS4'+secretKey))
                )
            )
        );
    }
    /***************************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-June-2018
	@parameter	   
	@return		   HttpResponse
    @description:  This is used to Create all of the bits and pieces using all utility functions above
    *******************************************************************************************************/
    
    public HttpRequest createRequest() {		//private -> public
        init();
        payloadSha256 = EncodingUtil.convertToHex(Crypto.generateDigest('sha-256', payload));
        setHeader('x-amz-content-sha256', payloadSha256);
        setHeader('date', requestTime.formatGmt('E, dd MMM YYYY HH:mm:ss z'));
        if(host == null) {
            host = endpoint.getHost();
        }
        setHeader('host', host);
        HttpRequest request = new HttpRequest();
        request.setMethod(method.name().removeStart('X'));
        
        if(payload.size() > 0) {
            setHeader('Content-Length', String.valueOf(payload.size()));
            
            request.setBodyAsBlob(payload);
        } 
        String finalEndpoint = new Url(endpoint, resource).toExternalForm();
        String queryString = createCanonicalQueryString();
        if(queryString != '') {
            finalEndpoint += '?'+queryString;
        }
        request.setEndpoint(finalEndpoint);
        
        for(String key: headerParams.keySet()) {
            request.setHeader(key, headerParams.get(key));
        }
        
        List<String> headerKeys = new List<String>();
        
        String stringToSign = createStringToSign(headerKeys);
        if(string.isNotBlank(stringToSign) && signingKey != null){
            request.setHeader('Authorization', String.format(
                'AWS4-HMAC-SHA256 Credential={0},SignedHeaders={1},Signature={2}',
                new List<String>{
                    String.join(new List<String>{ accessKey, requestTime.formatGMT('YYYYMMdd'), region, service, 'aws4_request' },'/'),
                        String.join(headerKeys,';'), EncodingUtil.convertToHex(Crypto.generateMac('hmacSHA256', Blob.valueOf(stringToSign), signingKey))}
            ));
        }
        return request;
    }
    /***************************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-June-2018
	@parameter	   
	@return		   HttpResponse
    @description:  This is used to make Http callout to AWS
    *******************************************************************************************************/
    //Actually perform the request, and throw exception if response code is not valid
    public HttpResponse sendRequest() {  //protected -> public
        //Assume that only 200 is valid because most of the time, 200 is what we expect
        Set<Integer> validCodes = new Set<Integer>{ 200 };
        HttpResponse response = new Http().send(createRequest());
        if(!validCodes.contains(response.getStatusCode())) {
            Dom.XmlNode node = response.getBodyDocument().getRootElement();
            String code = node.getChildElement('Code', node.getNamespace()).getText();
			String message = node.getChildElement('Message', node.getNamespace()).getText();
    	}
    	return response;
	}
    
    /***************************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-June-2018
	@parameter	   String fileName, AWSConfigurationsSettings__mdt oAWSConfigurationsSetting, AWSBucketSettings__c oAWSBucketSetting
	@return		   String - signedURL
    @description:  This is used to get signed url from Cloudfront Distribution
    *******************************************************************************************************/
    
    protected String getCloudFrontSignedURL(String fileName, AWSConfigurationsSettings__mdt oAWSConfigurationsSetting, AWSBucketSettings__c oAWSBucketSetting) {
        String privateKey = oAWSConfigurationsSetting.CloudFrontKeyPairPrivateKey__c ;
        String keyPairId =  oAWSConfigurationsSetting.CloudFrontKeyPairId__c ;   
        
        String urlToSign = oAWSBucketSetting.DistributionURL__c  +  '/' + fileName ;
        // calculate request expiry time. Add 10 mins to the current time so that URL will expire after 10 mins 
        Datetime currentTime = DateTime.now(); 
        Datetime expiresOn = currentTime.addMinutes(GlUt_AWSConstants.CLOUDFRONTURLEXPIRYMINUTE); 
        Long expireTime = expiresOn.getTime()/1000; 
        // AWS Canned Policy Statement format. Parameters are URL to sign and URL expiry time 
        String policyStatementText = '{"Statement":[{"Resource":"'+urlToSign+'","Condition":{"DateLessThan":{"AWS:EpochTime":'+expireTime+'}}}]}'; 
        // Base64-encode the policy statement using MIME base64 encoding 
        String policyStatement = EncodingUtil.base64Encode(Blob.valueOf(policyStatementText)); 
        // Replace characters that are invalid in a URL query string with characters that are valid 
        policyStatement = policyStatement .replace('+','-'); 
        policyStatement = policyStatement .replace('=','_'); 
        policyStatement = policyStatement .replace('/','~');     
        // Use the SHA-1 hash function (Used for canned policy) and RSA to hash and sign the policy statement 
        Blob mac = Crypto.sign('RSA-SHA1', Blob.valueof(policyStatementText ), EncodingUtil.base64Decode(privateKey)); 	// RSA-SHA1 --> hmacSHA1
        // Base64-encode the policy statement using MIME base64 encoding 
        String signed = EncodingUtil.base64Encode(mac); 
        // Replace characters that are invalid in a URL query string with characters that are valid 
        signed = signed.replace('+','-'); 
        signed = signed.replace('=','_'); 
        signed = signed.replace('/','~'); 
        // finish concatenating the parts of your signed URL. This URL will be used to view the object from S3 bucket 
        String signedURL = urlToSign + '?Policy=' + policyStatement +  '&Signature=' + signed  + '&Key-Pair-Id=' + keyPairId; 
		return signedURL ;
    }
    /******************************************************************************
    @author         Echo:Dependra Singh
    @date           14 Mar 2019
    @description    Method is used to set custom meta data  type data for AWSConfigurationsSettings.
    *******************************************************************************/
    public static AWSConfigurationsSettings__mdt getAWSConfigurationSettingDetails(String query){
        List<AWSConfigurationsSettings__mdt> mdts = new  List<AWSConfigurationsSettings__mdt>();
        if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap != null && GlUt_CustomMetaDataUtility.customMetadataRecordsMap.keyset().size()  > 0){
            if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap.containsKey(query)){
                mdts = (List<AWSConfigurationsSettings__mdt>)GlUt_CustomMetaDataUtility.customMetadataRecordsMap.get(query);  
            }
        }else{
            mdts = (List<AWSConfigurationsSettings__mdt>) new GlUt_CustomMetaDataUtility().getCustomMetadataRecords(query);
        }
        if(!mdts.isEmpty()){
            return mdts[0];
        }else{
            return null;
        }
    }
}