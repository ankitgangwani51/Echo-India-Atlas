/***************************************************************************************************
@author        Gopal Gupta	
@date          15-Apr-2018
@description:  This is a class for Amazon S3 integration  
@revision	   Echo: Dependra Singh - 14-03-2019 -Meta data Setting updated.
*******************************************************************************************************/
public  class GlUt_AWSS3AddFileToBucket extends GlUt_AWSS3Utilities{
    public String payloadXml ; 
    public String resourceName ;
    public  String strBucketName ;
    public AWSBucketSettings__c oAWSBucketSetting  ;
    AWSConfigurationsSettings__mdt mdtAWSConfigurationsSetting;
    //public list<AWSConfigurationsSettings__mdt> listAWSConfigurationsSetting ;
    
    /***************************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-June-2018
    @description:  This is one parameterized constructor taking bucket name
    *******************************************************************************************************/
    public GlUt_AWSS3AddFileToBucket(String strBucketName) {
        this.strBucketName = strBucketName ;
        oAWSBucketSetting = AWSBucketSettings__c.getInstance(strBucketName) ;
        mdtAWSConfigurationsSetting = GlUt_AWSS3Utilities.getAWSConfigurationSettingDetails(GlUt_AWSConstants.AWSCONFIGURATIONSETTINGQUERY);
        //listAWSConfigurationsSetting = [SELECT AccessKeyId__c, CloudFrontKeyPairId__c, CloudFrontKeyPairPrivateKey__c, SecretKey__c, Service__c FROM AWSConfigurationsSettings__mdt LIMIT 1] ;
    }
    
    /***************************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-June-2018
    @description:  This overrides GlUt_AWSS3Utilities init method to initialise the required AWS attributes
    *******************************************************************************************************/
    public override void init() {
        String bucketURL = 'https://' + strBucketName + '.s3.amazonaws.com' ;	
        endpoint = new Url(bucketURL); 
        resource = '/' + resourceName ;	
        if(oAWSBucketSetting != null) {
            region = oAWSBucketSetting.Region__c ; 
        }
        /*if(listAWSConfigurationsSetting != null && !listAWSConfigurationsSetting.isEmpty()) {
        service = listAWSConfigurationsSetting[0].Service__c ;
        accessKey = listAWSConfigurationsSetting[0].AccessKeyId__c; 
        }*/
        if(mdtAWSConfigurationsSetting != null) {
            service = mdtAWSConfigurationsSetting.Service__c ;
            accessKey = mdtAWSConfigurationsSetting.AccessKeyId__c; 
        }
        method = HttpMethod.XPUT;
        payload = Blob.valueOf(payloadXml) ;
        
        if(mdtAWSConfigurationsSetting != null && string.isNotBlank(mdtAWSConfigurationsSetting.SecretKey__c)){
            createSigningKey(mdtAWSConfigurationsSetting.SecretKey__c); 
        } 
    }
    
    /***************************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-June-2018
    @description:  This actually makes Http callout to AWS S3
    *******************************************************************************************************/
    public HttpResponse addFileToBucket() {
        //init() ;
        HttpResponse response = sendRequest();        
        return response ;
    }
}