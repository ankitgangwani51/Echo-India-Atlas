/******************************************************************************
@author    		Accenture: Patrick Dixon
@date      		20 Sep 2017
@description 	Class for manipulating Content Documents
                AT-4891/2 Code Check Marx Changes for FLS INSERT/UPDATE
*******************************************************************************/
public with sharing class GlUt_ContentDocument {
    
	public static final String CLASS_NAME = 'GlUt_ContentDocument';
	public static final String DEBUG = '[' + CLASS_NAME + '] ';

	/******************************************************************************
	@author    		Accenture: Patrick Dixon
	@date      		20 Sep 2017
	@param			Id - linked record Id
	@param			String - document title
	@param			String - document path
	@param			String - share type (optional - defaults to View)
	@param			Blob - file content
	@return			Id - document Id
	@description 	Saves a file as a content document, links it to a record, 
					and optionally puts it in a specified library folder
	*******************************************************************************/
	public static Id saveLinkedDocument(Id linkedId, String title, String path, Blob file) {
		return saveLinkedDocument(linkedId, null, title, path, 'V', file);
	}
	public static Id saveLinkedDocument(Id linkedId, String workspaceName, String title, String path, Blob file) {
		return saveLinkedDocument(linkedId, workspaceName, title, path, 'V', file);
	}
	public static Id saveLinkedDocument(Id linkedId, String workspaceName, String title, String path, String shareType, Blob file) {

		// save the file as a content version
        ContentVersion document = new ContentVersion(
            Title = title, 
            VersionData = file, 
            PathOnClient = path 
        );
        
        // Commented By Dependra Singh- 08-01-2019
        //Cannot deserialize instance of base64 from VALUE_STRING value in cleanse method.
        //document = (ContentVersion) GlUt_FieldSecurity.cleanseFields(document, false); //AT-4891 Code Check Marx Changes Starts/Ends Here. 
        insert document;
		
		// inserting a content version creates a content document ...
		document = [select Id, ContentDocumentId from ContentVersion where Id = :document.Id];
		
		// ... which is then used to create the link to the salesforce record
		ContentDocumentLink recordLink = new ContentDocumentLink(
																ContentDocumentId = document.ContentDocumentId, 
																LinkedEntityId = linkedId, 
																ShareType = shareType 
																);
        recordLink = (ContentDocumentLink) GlUt_FieldSecurity.cleanseFields(recordLink, false); //AT-4891 Code Check Marx Changes Starts/Ends Here. 
		insert recordLink;
		// move the document to the specified folder
		if (!String.isBlank(workspaceName)) {

			saveInWorkspace(document.ContentDocumentId, workspaceName);
		}

		return document.ContentDocumentId;
	}
	
	/******************************************************************************
	@author    		Accenture: Patrick Dixon
	@date      		29 Sep 2017
	@param			Id - document Id
	@param			String - folder name
	@description 	Puts a content document in the specified content workspace
					If the content workspace isn't found, it will do nothing
	*******************************************************************************/
	public static void saveInWorkspace(Id documentId, String workspaceName) {
		/*AT-4373 CLAYTON security review Starts here */
		// find the folder
        ContentWorkspaceDoc linkFolder;
        for (ContentWorkspace folder : [select Id 
                                        from ContentWorkspace 
                                        where Name = :workspaceName]) {
                                            // and create a link record between the folder and document
                                            ContentWorkspaceDoc folderLink = new ContentWorkspaceDoc(ContentWorkspaceId = folder.Id,ContentDocumentId = documentId);
                                            linkFolder = folderLink;
                                            break;		// only one match allowed
                                        }
        if(linkFolder != null){
            linkFolder = (ContentWorkspaceDoc) GlUt_FieldSecurity.cleanseFields(linkFolder, false); //AT-4891 Code Check Marx Changes Starts/Ends Here. 
            insert linkFolder;
        }
        /*AT-4373 CLAYTON security review Ends here */
	}

}