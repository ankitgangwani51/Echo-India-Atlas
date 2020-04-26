/***************************************************************************************************
@author        Gopal Gupta  
@date          15-Apr-2018
@description:  This is a class for Amazon S3 integration to  view PDF templates 
@revision      Echo: Dependra Singh - 14-03-2019 -Meta data Setting updated.
*******************************************************************************************************/
public with sharing class GlUt_AWSS3ViewFiles extends GlUt_AWSS3Utilities {
    
    public  String strBucketName ;
    public AWSBucketSettings__c oAWSBucketSetting  ;
    public AWSConfigurationsSettings__mdt mdtAWSConfigurationsSetting;
    public list<AWSConfigurationsSettings__mdt> listAWSConfigurationsSetting ;
   /***************************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-June-2018
    @description:  Thi smethod is used to initialize 
    *******************************************************************************************************/
    public override void init() {
        String bucketURL = 'https://' + strBucketName + '.s3.amazonaws.com' ;       // AT-2471
        endpoint = new Url(bucketURL); 
        //resource = '/'   ; //dynamic + resource  - 04/12 - CORRECTED: commented as it is being set in the constructor
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
        method = HttpMethod.XGET;
        if(mdtAWSConfigurationsSetting != null && string.isNotBlank(mdtAWSConfigurationsSetting.SecretKey__c)){
            //createSigningKey(listAWSConfigurationsSetting[0].SecretKey__c); 
            createSigningKey(mdtAWSConfigurationsSetting.SecretKey__c); 
        } 
    }
    /***************************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-June-2018
    @param         String strBucketName
    @description:  This is one parameterized constructor taking bucket name
    *******************************************************************************************************/
    public GlUt_AWSS3ViewFiles(String strBucketName) {
        this.strBucketName = strBucketName ;
        this.resource = '/' ;
        oAWSBucketSetting = AWSBucketSettings__c.getInstance(strBucketName) ;
        /*listAWSConfigurationsSetting = [SELECT AccessKeyId__c, CloudFrontKeyPairId__c, CloudFrontKeyPairPrivateKey__c, SecretKey__c, Service__c 
                                    				FROM AWSConfigurationsSettings__mdt LIMIT 1] ;*/
        mdtAWSConfigurationsSetting = GlUt_AWSS3Utilities.getAWSConfigurationSettingDetails(GlUt_AWSConstants.AWSCONFIGURATIONSETTINGQUERY);
        system.debug('GlUt_AWSS3ViewFiles-resource=> ' + resource);
    }
    /***************************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-June-2018
    @param        String strBucketName, String strResource
    @description:  This is two parameterized constructor taking bucket name and resource name
    *******************************************************************************************************/
    public GlUt_AWSS3ViewFiles(String strBucketName, String strResource) {
        
        this.strBucketName = strBucketName ;
        this.resource = '/' +  strResource ; // 04/12 - CORRECTED: missing '/' slash
        oAWSBucketSetting = AWSBucketSettings__c.getInstance(strBucketName) ;
        /*listAWSConfigurationsSetting = [SELECT AccessKeyId__c, CloudFrontKeyPairId__c, CloudFrontKeyPairPrivateKey__c, SecretKey__c, Service__c 
										 FROM AWSConfigurationsSettings__mdt LIMIT 1] ;*/
        mdtAWSConfigurationsSetting = GlUt_AWSS3Utilities.getAWSConfigurationSettingDetails(GlUt_AWSConstants.AWSCONFIGURATIONSETTINGQUERY);
    }
    
    /***************************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-June-2018
    @description:  This is a wrapper class to store s3 bucket file name and its signed url
    *******************************************************************************************************/
    
    public class BucketFileWrapper {
        @AuraEnabled public String fileName ;
        @AuraEnabled public String signedUrl ;
        public BucketFileWrapper(String fileName, String signedUrl) {
            this.fileName = fileName ;
            this.signedUrl = signedUrl ;
        }
        
    }
    
    /***************************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          18-June-2018
    @description:  This is a method is used to make Http callout to AWS by invoking GlUt_AWSS3Utilities methods.
    *******************************************************************************************************/
    
    public list<BucketFileWrapper> viewFilesFromBucket() {
        list<BucketFileWrapper> listBucketFileWrapper = new list<BucketFileWrapper>() ;
        try {
            HttpResponse response = sendRequest();   
            SYSTEM.debug('sk-response=> ' + response);
            Dom.XmlNode node = response.getBodyDocument().getRootElement();
            //Added by Sudhr - for testing
            SYSTEM.debug('sk-response2=> ' + response.getBodyDocument().toXmlString()) ;
            SYSTEM.debug('sk-node=> ' + node);
            //
            for(Dom.XmlNode childNode : node.getChildElements()){
                for(Dom.XmlNode keynode : childNode.getChildElements()){           
                    if (keynode.getNodeType() == DOM.XMLNodeType.ELEMENT) {
                        if(keynode.getName() == 'Key'){
                            SYSTEM.debug('sk-node text=> ' + keynode.getText());
                            String signedURL = '' ;
                            if(oAWSBucketSetting != null && mdtAWSConfigurationsSetting != null) {
                                signedURL = getCloudFrontSignedURL(keynode.getText(), mdtAWSConfigurationsSetting, oAWSBucketSetting) ;
                            }
                            if(String.isNotBlank(signedURL)) {
                                BucketFileWrapper objBucketFileWrapper = new BucketFileWrapper(keynode.getText(), signedURL) ;
                                listBucketFileWrapper.add(objBucketFileWrapper) ;
                            }
                            
                        }
                    }
                }
            }
        } catch(Exception ex) {
            
        }
        return listBucketFileWrapper ;
    }
    /***************************************************************************************************
    @author        Dependra Singh   
    @date          25-May-2018
    @param         string fileName
    @description:  Method is used to create signed url of cloud front.
    *******************************************************************************************************/
    public list<BucketFileWrapper> getCloudFrontSignedURL(string fileName) {    
        
        list<BucketFileWrapper> listBucketFileWrapper = new list<BucketFileWrapper>() ;
        String signedURL = '' ;
        if(oAWSBucketSetting != null && mdtAWSConfigurationsSetting != null ) {
            signedURL = getCloudFrontSignedURL(fileName, mdtAWSConfigurationsSetting, oAWSBucketSetting) ;
        }
        BucketFileWrapper objBucketFileWrapper = new BucketFileWrapper(fileName, signedURL) ;
        listBucketFileWrapper.add(objBucketFileWrapper) ;
        return listBucketFileWrapper ;
    }
}