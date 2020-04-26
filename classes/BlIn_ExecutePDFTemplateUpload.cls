/******************************************************************************
@author         Accenture: Patrick Dixon
@date           01 Sep 2017
@description    Class for PDF template upload callout
    			Max heap size determines max file size
*******************************************************************************/
public with sharing class BlIn_ExecutePDFTemplateUpload {

    private static final String CLASS_NAME = 'BlIn_ExecutePDFTemplateUpload';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static final String BOUNDARY_STRING = '--------------------------' + generateRandomString(32);
    private static final Integer MAX_FILE_SIZE = 3000000;        // 3MB


    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           12 Oct 2017
    @param          Integer - length of required string
    @return         String - random string
    @description    Generates a random string to use as a boundary for the multipart form
    *******************************************************************************/
    @TestVisible
    private static String generateRandomString(Integer length) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randomString = '';
        while (randomString.length() < length) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randomString += chars.substring(idx, idx + 1);
        }
        return randomString; 
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           29 Sep 2017
    @param          Id - bill calculation Id
    @return         Boolean - success
    @description    HEROKU REST callout to upload a PDF Template to Heroku
    *******************************************************************************/
    public static Boolean UploadTemplate(Id documentId) {
        
        System.debug(DEBUG + 'BUILDING THE PAYLOAD');
        
		try {
			GlUt_Logger.logDebug(GlUt_Constants.EXECUTING + DEBUG);
	        // get the file
	        Blob fileContent;
	        String fileName;
	        for (ContentVersion document : [select Id, ContentDocumentId,Title,VersionData, 
	                                        PathOnClient from ContentVersion 
	                                        where ContentDocumentId = :documentId
	                                        order by CreatedDate desc]) {
	                                            
	            fileContent = document.VersionData;
	            fileName = document.Title;
	            break;		// get most recent version only
	        }
	
	        // assemble the payload
	        String header = '--' + BOUNDARY_STRING + '\r\n' 
	                        + 'Content-Disposition: form-data; name="name"\r\n\r\n'
	                        + fileName
	
	                        + '\r\n--' + BOUNDARY_STRING + '\r\n' 
	                        + 'Content-Disposition: form-data; name="file"; filename="' + fileName + '.pdf"\r\n'
	                        + 'Content-Type: application/pdf';
	        
			String footer = '--' + BOUNDARY_STRING + '--';
	
			// replace any base64 padding on the end of the header with CR LF
			String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
			while (headerEncoded.endsWith('=')) {
			    header += ' ';
			    headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
			}
			
			// remove any base64 padding from the end of the body and pad by using the CR LF prefix to the footer instead
			Blob bodyBlob = null;
			String last4Bytes = EncodingUtil.base64Encode(fileContent).substring(EncodingUtil.base64Encode(fileContent).length() - 4, 
		      						EncodingUtil.base64Encode(fileContent).length());
		
			// prepend CR LF to the footer
			if (last4Bytes.endsWith('==')) {
				last4Bytes = last4Bytes.substring(0, 2) + '0K';		// 'oK' if using \n\n rather than \r\n
				String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
				bodyBlob = EncodingUtil.base64Decode(headerEncoded 
						+ EncodingUtil.base64Encode(fileContent).substring(0, EncodingUtil.base64Encode(fileContent).length() - 4) 
						+ last4Bytes + footerEncoded);
		
			} else if(last4Bytes.endsWith('=')) {
				last4Bytes = last4Bytes.substring(0, 3) + 'N';		// 'K' if using \n\n rather than \r\n
				footer = '\n' + footer;
				String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
				bodyBlob = EncodingUtil.base64Decode(headerEncoded 
						+ EncodingUtil.base64Encode(fileContent).substring(0,EncodingUtil.base64Encode(fileContent).length() - 4) 
						+ last4Bytes + footerEncoded);              
		
			} else {
				footer = '\r\n' + footer;
				String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
				bodyBlob = EncodingUtil.base64Decode(headerEncoded + EncodingUtil.base64Encode(fileContent) + footerEncoded);  
			}
	
	        if (bodyBlob.size() > MAX_FILE_SIZE) { 
	        	System.debug(Label.BlAp_PDFTemplateFileSizeError);
	            throw new AuraHandledException(Label.BlAp_PDFTemplateFileSizeError);

	        } else {
		        System.debug(DEBUG + 'MAKING PDF TEMPLATE UPLOAD CALLOUT');
		        System.debug(DEBUG + 'fileName: ' + fileName);
		
		        // make the callout
				String contentType = 'multipart/form-data; boundary=' + BOUNDARY_STRING;
		        HttpResponse response = BlUt_HerokuWebservices.makeCallout(BlUt_HerokuWebservices.PDF_TEMPLATE_UPLOAD, 2000, contentType, bodyBlob);
		        
		        // handle response
		        // 
		        if (response.getStatusCode() == 200) {
		            System.debug(DEBUG + 'Good response: ' + response.getStatusCode() + ' ' + response.getStatus());
		            
		
		        } else {
		            System.debug(DEBUG + 'Error response: ' + response.getStatusCode() + ' ' + response.getStatus());
		            throw new AuraHandledException(Label.BlAp_PDFTemplateUploadError + response.getStatus());
		        }
	        }

        } catch (exception e) {
            GlUt_Logger.logException(e);
            System.debug(DEBUG + 'Exception: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }	
        return true;
    }
}