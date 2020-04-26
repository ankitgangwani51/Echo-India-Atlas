/*******************************************************************************
@author         Echo: Sudhir Kumar
@date           19 Dec 2018
@description    Utillity for the CuUt_ConcessionValidationCtrlr 
********************************************************************************/

public with sharing class CuUt_ConcessionUtility {
	private static FINAL Integer CRN_NUMERIC_LENGTH			= 9 ;
    private static FINAL String PASSWORD_DIGEST_ALGORITHM	= 'SHA1' ;
    
    //To get mock response in non-Test context - used for testing purpose only - controlled by custom label 'CuAp_ActivateCentrelinkMockResponse'
    private static final string MOCK_RESPCODE 	= 'responseCode' ;
    private static final string MOCK_HEADER 	= 'headers' ;
    private static final string MOCK_BODY 		= 'body' ;
    //Wrapper class containing 'retrieveBenefitStatusSubset Result Dto' payload in json format
    public class ResponseJson  {
        public Integer responseCode ; 
        public Map<String, Object> headers ; 
        public Map<String, Object> body ;  
    }
    /**********************************************************************************************
	@author      : Echo: Sudhir Kumar
	@date        : 11-Jan-2019
	@params      : none
	@return      : CentrelinkUserCredential__mdt
	@description : This method 'getCentrelinkUserCredential' will return list of CentrelinkUserCredential__mdt
	@revesion	 : Updated By Echo: Dependra Singh -12-03-2019 - MetaData types Fix
	**********************************************************************************************/ 
    public static CentrelinkUserCredential__mdt getCentrelinkUserCredential() {
        List<CentrelinkUserCredential__mdt> mdts = new  List<CentrelinkUserCredential__mdt>();
        if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap != null && GlUt_CustomMetaDataUtility.customMetadataRecordsMap.keyset().size()  > 0){
            if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap.containsKey(LoBt_Constants.CENTERLINKMETADATAQUERY)){
                mdts = (List<CentrelinkUserCredential__mdt>)GlUt_CustomMetaDataUtility.customMetadataRecordsMap.get(LoBt_Constants.CENTERLINKMETADATAQUERY);  
            }
        }else{
            mdts = (List<CentrelinkUserCredential__mdt>) new GlUt_CustomMetaDataUtility().getCustomMetadataRecords(LoBt_Constants.CENTERLINKMETADATAQUERY);
        }
        if(!mdts.isEmpty()){
            return mdts[0];
        }else{
            return null;
        }
    }
    /**********************************************************************************************
	@author      : Echo: Sudhir Kumar
	@date        : 11-Jan-2019
	@params      : none
	@return      : map<String, CentrelinkException__mdt>
	@description : This method 'getCentrelinkException' will return map of CentrelinkException__mdt
	@revesion	 : Updated By Echo: Dependra Singh -12-03-2019 - MetaData types Fix
	**********************************************************************************************/ 
    public static map<String, CentrelinkException__mdt> getCentrelinkException() {
        map<String, CentrelinkException__mdt> mapCentrelinkException = new map<String, CentrelinkException__mdt>() ;
        String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
        List<CentrelinkException__mdt> listCentrelinkException = new List<CentrelinkException__mdt>();
        if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap != null && GlUt_CustomMetaDataUtility.customMetadataRecordsMap.keyset().size()  > 0){
            if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap.containsKey(LoBt_Constants.CENTERLINKEXCEPTIONMETADATAQUERY)){
                listCentrelinkException = (List<CentrelinkException__mdt>)GlUt_CustomMetaDataUtility.customMetadataRecordsMap.get(LoBt_Constants.CENTERLINKEXCEPTIONMETADATAQUERY);  
            }
        }else{
            listCentrelinkException = (List<CentrelinkException__mdt>) new GlUt_CustomMetaDataUtility().getCustomMetadataRecords(LoBt_Constants.CENTERLINKEXCEPTIONMETADATAQUERY);
        } 
        if(listCentrelinkException != null && listCentrelinkException.size() > 0){
            for(CentrelinkException__mdt centrelinkException : listCentrelinkException) {
                mapCentrelinkException.put(centrelinkException.QualifiedApiName, centrelinkException) ;
            }
        }
        return mapCentrelinkException ;        
	}
    /**********************************************************************************************
	@author      : Echo: Sudhir Kumar
	@date        : 03-Jan-2019
	@params      : none
	@return      : CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResultDto
	@description : This method 'getBenefitStatusMockResponse' will return ConcessionRecord
	**********************************************************************************************/ 
    public static CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResultDto getBenefitStatusMockResponse() {
        List<StaticResource> resource = new List<StaticResource>();
        ResponseJson response = new ResponseJson();
        CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResultDto  dto ;
        resource = [SELECT Id, Body FROM StaticResource WHERE Name =: System.Label.CuAp_CentrelinkBenefitStatusPositiveMockStaticResource] ; 
        if(resource != null && !resource.isEmpty()){ 
            Map<String , Object>  o = (Map<String , Object>) JSON.deserializeUntyped(resource[0].body.toString()) ;
            if (o.get(MOCK_BODY) != null){
                response.body = (Map<String , Object> )o.get(MOCK_BODY) ; 
            }
            dto = (CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResultDto) JSON.deserialize(JSON.serialize(response.body), CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResultDto.class) ;
        }
        return dto ;
    }
    
    /**********************************************************************************************
	@author      : Echo: Sudhir Kumar
	@date        : 31-Dec-2018   
	@params      : Id concessionId
	@return      : Concession__c
	@description : This method 'getConcessionRecord' will return ConcessionRecord
	**********************************************************************************************/ 
    //Get the concession details
    public static Concession__c getConcessionRecord(Id concessionId) {
        list<Concession__c> listConcession = [SELECT Id, CRN__c, Account__c, ConfirmDate__c, Validated__c, PostCode__c FROM Concession__c WHERE Id =: concessionId LIMIT 1] ;
        return listConcession != null && !listConcession.isEmpty() ? listConcession[0] : null ;
    }
    
    /**********************************************************************************************
	@author      : Echo: Sudhir Kumar
	@date        : 31-Dec-2018   
	@params      : Date confirmDate
	@return      : Boolean
	@description : This method 'isValidConfirmDate' will validate ConfirmDate
	**********************************************************************************************/
    //Valid Confirm Date check
    public static Boolean isValidConfirmDate(Date confirmDate) {
        if(confirmDate == null) confirmDate = System.today() ;
        return String.isNotBlank(String.valueOf(confirmDate)) && Pattern.matches('\\d\\d\\d\\d-\\d\\d-\\d\\d', String.valueOf(confirmDate)) && (confirmDate <= System.today() && confirmDate > System.today().addYears(-2)) ;
    }
    
    /**********************************************************************************************
	@author      : Echo: Sudhir Kumar
	@date        : 31-Dec-2018   
	@params      : String crn
	@return      : Boolean
	@description : This method 'isValidCRN' will validate CRN
	**********************************************************************************************/
    //Valid CRN check
    public static Boolean isValidCRN(String crn) {
        Boolean isValid = true ;
        if(String.isNotBlank(crn)) {
            if(crn.length() < CRN_NUMERIC_LENGTH) {
                isValid = false ;
            }  else {
                if(!crn.substring(0, CRN_NUMERIC_LENGTH - 1).isNumeric()) isValid = false ;
            	if(!crn.substring(CRN_NUMERIC_LENGTH).isAlpha()) isValid = false ;
            }
        } else {
            isValid = false ;
        }
        return isValid ;
    }
    
    /**********************************************************************************************
	@author      : Echo: Sudhir Kumar
	@date        : 31-Dec-2018   
	@params      : String password
	@return      : Blob
	@description : This method 'generatePasswordDigest' will generate Digest of Password
	**********************************************************************************************/
    //Password_Digest = Base64 ( SHA-1 ( nonce + created + password ) ) 
    public static Blob generatePasswordDigest(String password) {
       	return Crypto.generateDigest(PASSWORD_DIGEST_ALGORITHM, Blob.valueOf(password)) ;
    } 
    
    /**********************************************************************************************
	@author      : Echo: Sudhir Kumar
	@date        : 31-Dec-2018   
	@params      : none
	@return      : String
	@description : This method 'generateNounce' will generate Nounce
	**********************************************************************************************/
    //Generate nounce
    public static String generateNounce() {
        Long randomLong = Crypto.getRandomLong() ;
        return EncodingUtil.base64Encode(Blob.valueOf(String.valueOf(randomLong))) ;
    }
    
    /**********************************************************************************************
	@author      : Echo: Sudhir Kumar
	@date        : 31-Dec-2018   
	@params      : none
	@return      : String
	@description : This method 'generateTimestamp' will generate current Timestamp
	**********************************************************************************************/
    //Generate Timestamp in GMT
    public static String generateTimestamp() {
        return DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') ;
    }
    public static String generateTimestampFormatCCYYMMDDHHMMSS() {
        return DateTime.now().format('YYYYMMDDHHMMSSS') ; 
    }
}