/******************************************************************************
@author    		Echo: Amit K.
@date      		23 Feb 2018
@description 	Class is used to Saves a file as a content document, links it to a record, 
and optionally puts it in a specified library folder
*******************************************************************************/
public with sharing class LtAp_CreateLetterPdfHelper {
    
    public static final String SHARE_TYPE = 'V';
    /******************************************************************************
	@author    		Echo: Amit K.
	@date      		23 Feb 2018
	@param			Map<Id,Blob> - mapOfCreateLetterRequestIdToResponseString
	@param			String -  workspaceName 
	@param			Map<Id,String> - mapOfCreateLetterRequestIdToPDFName
	@param			Map<Id,String> - mapOfCreateLetterRequestIdToRelatedId
	@return			List<ContentVersion>
	@description 	Saves a file as a content document, links it to a record, 
					and optionally puts it in a specified library folder
	*******************************************************************************/
    public static List<ContentVersion> saveLinkedDocument(Map<Id,Blob> mapOfCreateLetterRequestIdToResponseString,
                                                          String workspaceName, 
                                                          Map<Id,String> mapOfCreateLetterRequestIdToPDFName,
                                                          Map<Id,String> mapOfCreateLetterRequestIdToRelatedId) {
        List<ContentVersion> documentList = new List<ContentVersion>();// contentVersion collection list that needs to be Insert.
        Map<ContentVersion,Id> mapOfContentVersionToRelatedId = new  Map<ContentVersion,Id>(); // create Map of ContentVersion record having account or contact Id.
                                                              
        for(Id createLetterRequestId : mapOfCreateLetterRequestIdToResponseString.keySet()){
               ContentVersion document = new ContentVersion();
               document.VersionData = mapOfCreateLetterRequestIdToResponseString.get(createLetterRequestId);
               String name = mapOfCreateLetterRequestIdToPDFName.get(createLetterRequestId);
               document.Title = name; // title of content version
               document.PathOnClient = name; // path on client for content version
               documentList.add(document);
               Id rId = mapOfCreateLetterRequestIdToRelatedId.get(createLetterRequestId); // fetch account or contact Id on the basis of create letter record id.
               mapOfContentVersionToRelatedId.put(document,rId);
        }
        if(!documentList.isEmpty()){
            //Cannot deserialize instance of base64 from VALUE_STRING value in cleanse method.
            //documentList = (List<ContentVersion>) GlUt_FieldSecurity.cleanseFields(documentList, false);
            insert documentList; // create new content version records.
        }
        Map<Id,Id> mapOfContentversionIdToRelatedId = new  Map<Id,Id>();    // create Map of contentversion Id having contact or account Id.                                                
        for(ContentVersion cv :mapOfContentVersionToRelatedId.keySet()){
            mapOfContentversionIdToRelatedId.put(cv.Id,mapOfContentVersionToRelatedId.get(cv)); 
        }
        // fetch content version record list having content document Ids.
		List<ContentVersion> cvList = [select Id,
                                       ContentDocumentId
                                       from ContentVersion where Id IN :documentList];
        
        List<ContentDocumentLink> recordLinkList = new List<ContentDocumentLink>();
        for(ContentVersion cv : cvList) {
            ContentDocumentLink recordLink = new ContentDocumentLink(ContentDocumentId = cv.ContentDocumentId, // assign the value of content Document Id.
                                                                     LinkedEntityId = mapOfContentversionIdToRelatedId.get(cv.Id), // assign the account or contact id to linked entity Id.
                                                                     ShareType = SHARE_TYPE); // assign value to Share Type as View.
            recordLinkList.add(recordLink);
        }  
        
        if(!recordLinkList.isEmpty()){
             recordLinkList = (List<ContentDocumentLink>) GlUt_FieldSecurity.cleanseFields(recordLinkList, false); 
            insert recordLinkList; // create new content document link records.
        }
		// move the document to the specified folder
		if (!String.isBlank(workspaceName)) {
			saveInWorkspace(cvList, workspaceName);
		}

		return documentList;
	}
	
    /******************************************************************************
	@author    		Echo: Amit K.
	@date      		23 Feb 2018
	@param			List<ContentVersion> documentList
	@param			String -  workspaceName 
	@return			Void
	@description 	Saves a file as a content document, links it to a record, 
					and optionally puts it in a specified library folder
	*******************************************************************************/
    public static void saveInWorkspace(List<ContentVersion> cvList, String workspaceName) {
        // find the folder
        String folderId;
        for (ContentWorkspace folder : [select Id 
                                        from ContentWorkspace 
                                        where Name = :workspaceName]) {
                                            folderId =  folder.Id;                          
                                        }
        List<ContentWorkspaceDoc> contentWorkSpaceList = new List<ContentWorkspaceDoc>();
        for(ContentVersion cv : cvList){
            // create a link record between the folder and document
            ContentWorkspaceDoc folderLink = new ContentWorkspaceDoc(
                ContentWorkspaceId = folderId,
                ContentDocumentId = cv.ContentDocumentId
            );
            contentWorkSpaceList.add(folderLink);
        }
        if(!contentWorkSpaceList.isEmpty()){
            contentWorkSpaceList = (List<ContentWorkspaceDoc>) GlUt_FieldSecurity.cleanseFields(contentWorkSpaceList, false); 
            insert contentWorkSpaceList;
        }
    }
}