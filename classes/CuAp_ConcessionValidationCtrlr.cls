/*******************************************************************************
@author         Echo: Sudhir Kumar
@date           17 Dec 2018
@description    Controller for the CuAp_ConcessionValidation component 
********************************************************************************/

public with sharing class CuAp_ConcessionValidationCtrlr {
    private static Concession__c concessionObj ;
    private static list<ResponseObject> listResponseObject ;
    private static map<String, String> mapConcessionCardCode2Value = new map<String, String>{CuAp_Constants.Y => CuAp_Constants.YES, 
											     CuAp_Constants.N => CuAp_Constants.NO, 
											     CuAp_Constants.UC => CuAp_Constants.UNABLE_TO_CONFIRM} ;
    
    /**********************************************************************************************
	@author      : Echo: Sudhir Kumar
	@date        : 31-Dec-2018   
	@params      : Concession__c concessionObj, CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResultDto benefitStatusResultDto
	@return      : Boolean
	@description : This method 'validateConcessionAttributes' will validate Concession Attributes
	**********************************************************************************************/     
    //validate Centrelink Response
    private static Boolean validateConcessionAttributes(Concession__c concessionObj, CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResultDto benefitStatusResultDto) {
        //1. crn(CRN) -> Mandatory: 9 consecutive numeric characters followed by an alpha character.
        String crn 			= concessionObj != null ? concessionObj.CRN__c : benefitStatusResultDto != null ? benefitStatusResultDto.crn : null ;
        Boolean validCRN 	= CuUt_ConcessionUtility.isValidCRN(crn) ;
        if(!validCRN) listResponseObject.add(new ResponseObject('ERROR: Invalid CRN ' + crn, false)) ;
        //2. cnfrmDate(Confirm Date) -> Optional: 10 numeric characters in the format CCYY-MM-DD. Dates cannot be more than 2 years in the past and cannot be in the future.
        Date cnfrmDate 		= concessionObj != null ? concessionObj.ConfirmDate__c : benefitStatusResultDto != null ? benefitStatusResultDto.cnfrmDate : null ;	
        Boolean validConfirmDate = CuUt_ConcessionUtility.isValidConfirmDate(cnfrmDate) ;
        if(!validConfirmDate) listResponseObject.add(new ResponseObject('ERROR: Invalid ConfirmDate ' + cnfrmDate, false)) ;
        return (validCRN && validConfirmDate) ;
    }
    
    /**********************************************************************************************
	@author      : Echo: Sudhir Kumar
	@date        : 31-Dec-2018   
	@params      : 
	@return      : 
	@description : This is Response Object for the component
	**********************************************************************************************/ 
    public class ResponseObject {
        @AuraEnabled public String message ;
        @AuraEnabled public Boolean successFlag ;
        ResponseObject(String message, Boolean successFlag) {
            this.message 		= message ;
            this.successFlag	= successFlag ;
        }
    }
    
    /**********************************************************************************************
	@author      : Echo: Sudhir Kumar
	@date        : 31-Dec-2018   
	@params      : CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResultDto benefitStatusResultDto
	@return      : void
	@description : This method 'processCentrelinkBenefitStatusResponse' process Centrelink Benefi tStatus Response payload
	**********************************************************************************************/ 
    //Post-Callout logic to process the reponse: A new concession validation record will be created, and the selected Concession record will be updated
    private static list<ResponseObject> processCentrelinkBenefitStatusResponse(CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResultDto benefitStatusResultDto) {
        Boolean isValidCentrelinkResponse = true ;
        if(benefitStatusResultDto != null) {
            isValidCentrelinkResponse = validateConcessionAttributes(null, benefitStatusResultDto) ;	//Centrelink side Concession record validation
        } else {
            // Mock Response for testing purpose
            isValidCentrelinkResponse = System.Label.CuAp_ActivateCentrelinkMockResponse == CuAp_Constants.YES ? validateConcessionAttributes(null, CuUt_ConcessionUtility.getBenefitStatusMockResponse()) : false ;	//Mock BenefitStatusSubsetResultDto
        }
        //Once validation passed -> create Concession Validation and update Concession record
        if(isValidCentrelinkResponse) {	//If Centrelink side Concession record validation passed
            //Create ConcessionValidation record once validation is successful
            ConcessionValidation__c cncValidationObj = new ConcessionValidation__c() ;
            cncValidationObj.Concession__c		= concessionObj.Id ;
            cncValidationObj.Validated__c		=  true ;  //A check box to determine if the concession was valid when the concession validation record was created.
            cncValidationObj.Type__c			=  CuAp_Constants.CONCESSION_TYPE_REALTIME ;
            cncValidationObj.ConfirmDate__c		= benefitStatusResultDto.cnfrmDate != null ? benefitStatusResultDto.cnfrmDate : System.today() ; //Date used by Centrelink to validate a concession.
            cncValidationObj.PCC__c	 			= mapConcessionCardCode2Value.get(benefitStatusResultDto.pcc) ;
            cncValidationObj.HCC__c 			= mapConcessionCardCode2Value.get(benefitStatusResultDto.hcc) ;
            cncValidationObj.SHC__c 			= mapConcessionCardCode2Value.get(benefitStatusResultDto.shc) ;
            cncValidationObj.LIC__c 			= mapConcessionCardCode2Value.get(benefitStatusResultDto.lic) ;
            cncValidationObj.Deceased__c 		= benefitStatusResultDto.deceased == CuAp_Constants.Y ? true : false ;
            //Indicates whether the <pcode> provided in the RetrieveBenefitStatusSubset operation matches the customer’s postcode in the Centrelink database
            cncValidationObj.PostCode__c 		= benefitStatusResultDto.pcode ;
            ConcessionValidation__c cncValidationCleansedObj = (ConcessionValidation__c) GlUt_FieldSecurity.cleanseFields(cncValidationObj, false);
            Database.insert(cncValidationCleansedObj) ;
            //Update Concession record once validation is successful
            concessionObj.ConfirmDate__c		=  cncValidationObj.ConfirmDate__c ;	//Date used by Centrelink to validate a concession.
            concessionObj.Validated__c			=  true ;
            Concession__c concessionCleansedObj = (Concession__c) GlUt_FieldSecurity.cleanseFields(concessionObj, false);
            Database.update(concessionCleansedObj) ;
            listResponseObject.add(new ResponseObject(System.label.CuAp_CentrelinkConcessionValidationSuccessMessage, true)) ;
        } else {
            listResponseObject.add(new ResponseObject(System.label.CuAp_CentrelinkConcessionValidationFailureMessage, false)) ;
        }
        return listResponseObject ;
    }
    
    /**********************************************************************************************
	@author      : Echo: Sudhir Kumar
	@date        : 31-Dec-2018   
	@params      : Id concessionId
	@return      : list<ResponseObject>
	@description : This aura method 'validateConcession' validates the Concession record and its Centrelink Concession attributes
	**********************************************************************************************/ 
    //Method executed from the CuAp_ConcessionValidation component helper
    @AuraEnabled 
    public static list<ResponseObject> validateConcession(Id concessionId) {
		listResponseObject = new list<ResponseObject>() ;
        //Step 1. Get the Concession details
        try {
            Boolean isValidConcessionRecord = true ;
            if(String.isNotBlank(concessionId)) {
                concessionObj = (Concession__c) GlUt_FieldSecurity.cleanseFields(CuUt_ConcessionUtility.getConcessionRecord(concessionId), false) ;
                //validate Concession first before making actual callout
                isValidConcessionRecord = validateConcessionAttributes(concessionObj, null) ;	//Aptumo side Concession record validation
            }
            if(isValidConcessionRecord) {	//If Aptumo side Concession record validation passed
                String username = '' ;
                String password = '' ;
                String passwordType = '' ;
                CentrelinkUserCredential__mdt objCentrelinkUserCredential	= CuUt_ConcessionUtility.getCentrelinkUserCredential() ;
                if(objCentrelinkUserCredential != null) {	//Get credential from custom metadata type
                    password = objCentrelinkUserCredential.Password__c ;
                    username = objCentrelinkUserCredential.Username__c ;
                    passwordType = objCentrelinkUserCredential.PasswordType__c ;
                }
                
                //Step 2. Frame the request header and payload
                CuIn_CentrelinkCustomerConfirmationWS.customerConfirmationPort customerconfirmationService = new CuIn_CentrelinkCustomerConfirmationWS.customerConfirmationPort() ;
                CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResultDto benefitStatusResultDto = new CuIn_CentrelinkBenefitStatusSubResultDto.retrieveBenefitStatusSubsetResultDto() ;
                CuIn_CentrelinkBenefitStatusSubsetDto.retrieveBenefitStatusSubsetDto benefitStatusRequestDto = new CuIn_CentrelinkBenefitStatusSubsetDto.retrieveBenefitStatusSubsetDto() ;
                //Encoding - To Do
                //Request headers - To Do
                //1. Setup Header Security Info
                CuIn_CentrelinkOasisWSSecurityDto.SecurityHeaderType securitytag = new CuIn_CentrelinkOasisWSSecurityDto.SecurityHeaderType() ;
                //1.1 Setup Username
                securitytag.UsernameToken 			= new CuIn_CentrelinkOasisWSSecurityDto.UsernameTokenType() ;
                CuIn_CentrelinkOasisWSSecurityDto.AttributedString usernameAttributeString = new CuIn_CentrelinkOasisWSSecurityDto.AttributedString() ;
                //usernameAttributeString.input 	= 'TestUsername1' ;
                
                usernameAttributeString.input 		= username ;
                securitytag.UsernameToken.Username 	= usernameAttributeString ;
                //1.2 Setup Password
                CuIn_CentrelinkOasisWSSecurityDto.PasswordString pwdString = new CuIn_CentrelinkOasisWSSecurityDto.PasswordString() ;
                pwdString.input 					= new CuIn_CentrelinkOasisWSSecurityDto.AttributedString() ;
                pwdString.input.input 				= String.valueOf(CuUt_ConcessionUtility.generatePasswordDigest(password)) ;
                //pwdString.Type_x 					= 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest' ;
                pwdString.Type_x 					= passwordType ;
                securitytag.UsernameToken.Password 	= pwdString ;
                //1.3 Setup Nonce
                CuIn_CentrelinkOasisWSSecurityDto.EncodedString nonceString = new CuIn_CentrelinkOasisWSSecurityDto.EncodedString() ;
                nonceString.input 				= new CuIn_CentrelinkOasisWSSecurityDto.AttributedString() ;
                nonceString.input.input 		= CuUt_ConcessionUtility.generateNounce() ;
                nonceString.EncodingType 		= '' ;
                securitytag.UsernameToken.Nonce = nonceString ;
                //1.4 Setup Created timestamp
                CuIn_CentrelinkOasisWSUtilityDto.AttributedDateTime createdAttributeString = new CuIn_CentrelinkOasisWSUtilityDto.AttributedDateTime() ;
                createdAttributeString.input 			= CuUt_ConcessionUtility.generateTimestamp() ;
                securitytag.UsernameToken.Created 		= createdAttributeString ;
                securitytag.UsernameToken.anyElement 	= new List<DOM.XmlNode>() ;
                customerconfirmationService.timeout_x = 2000 ; //2s
                benefitStatusRequestDto.inputRefId = null ; //Optional
                benefitStatusRequestDto.crn = concessionObj.CRN__c ;
                benefitStatusRequestDto.pcode = concessionObj.PostCode__c ; //Optional - CLB-172
                benefitStatusRequestDto.cnfrmDate = concessionObj.ConfirmDate__c != null ? concessionObj.ConfirmDate__c : System.today() ; 
                benefitStatusRequestDto.scndryCrn = null ;	//Optional
                //Step 3. Invoke the stub
                benefitStatusResultDto = System.Label.CuAp_ActivateCentrelinkMockResponse != CuAp_Constants.YES ? customerconfirmationService.retrieveBenefitStatusSubset(benefitStatusRequestDto) : CuUt_ConcessionUtility.getBenefitStatusMockResponse() ;
                //Step 4. Process the Centrelink response
                return benefitStatusResultDto != null ? processCentrelinkBenefitStatusResponse(benefitStatusResultDto) : null ;
           } else {
                return listResponseObject ;
            }
        } catch(CalloutException calloutEx) {
            GlUt_Logger.logException(calloutEx) ;
            //Handle Soap fault in Callout Exception
            String calloutExString = String.valueOf(calloutEx) ;
            if(calloutExString.toLowerCase().contains('fault')) { // To Do: MODIFY AS PER THE ACTUAL RESPONSE
                system.debug('calloutEx Parsing=> ');
            }
            listResponseObject.add(new ResponseObject(GlUt_Logger.getActualErrorMessage(calloutEx.getMessage()), false)) ;
            return listResponseObject ;
        } catch(Exception ex) {
            GlUt_Logger.logException(ex) ;
            listResponseObject.add(new ResponseObject(GlUt_Logger.getActualErrorMessage(ex.getMessage()), false)) ;
            return listResponseObject ;  
        } 
    }
}