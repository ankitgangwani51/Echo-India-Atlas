/******************************************************************************
@author         Echo: Ankit Gangwani
@date           24 Dec 2018
@description    Component controller for New Concession Response Import lightning component
*******************************************************************************/
public with sharing class CuAp_NewConcessionResponseImportCtrlr {

    private static final String CLASS_NAME = 'CuAp_NewConcessionResponseImportCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
  
    private static List<String> userFieldsList;    
    static{
         userFieldsList = new List<String>();         
         userFieldsList.add(GlUt_APIConstantsUser.NAMEAPINAME);
    }
       
    private static List<String> batchProcessFieldsList;    
    static{
        batchProcessFieldsList = new List<String>();         
        batchProcessFieldsList.add('Id');
    }
    
    /**********************************************************************************************
    @author         Echo: Ankit Gangwani
    @date           24 Dec 2018
	@param			none
    @return         List<User>
    @description    Method to return list of all active Users 
    **********************************************************************************************/
    @AuraEnabled
    public static List<User> activeNotifyUserList() {
        List<User> userList = new List<User>();     
            
        try {        
            String queryFilter = ' WHERE ' + GlUt_APIConstantsUser.ISACTIVEAPINAME + ' = true ';              
            userList = (List<User>)GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsUser.USERAPINAME, userFieldsList, queryFilter);           
        } catch (exception e) { 
            GlUt_Logger.logException(e);            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return userList;
    }   
    /**********************************************************************************************
    @author         Echo: Ankit Gangwani
    @date           24 Dec 2018
    @return         void   
	@param			String importJobName, boolean isUserNotification, String userNotify, String fileName, String base64Data, String contentType 
    @description    Method to save uploaded as new Salesforce Content Version and Create a Content 
                    Document Link record to link the File to the Batch Request queue  
    **********************************************************************************************/
    @AuraEnabled
    public static void saveDetails(String importJobName, boolean isUserNotification, String userNotify, String fileName, String base64Data, String contentType ) {       
        
        BatchProcess__c objBatchProcess = new BatchProcess__c();         
        try { 
            Id idUser = null;
            If (isUserNotification){
                idUser = Id.valueOf(userNotify) ;
            }
            BatchRequestQueue__c objBRQ = GlUt_BatchRequestQueueUtilities.createBatchRequestQueue(null,isUserNotification ,LoAp_Constants.HIGH,importJobName, 
                                                                                                  null,LoAp_Constants.BATCHPROCESSOPERATIONIMPORT,
                                                                                                  LoAp_Constants.CONCESSION_IMPORT,idUser,LoAp_Constants.LOADING,null);
            if(objBRQ.id != null){    
                Id contentDocumentId =  GlUt_ContentDocument.saveLinkedDocument(objBRQ.Id, null, fileName, fileName, 
                                                                                LoBt_Constants.SHARE_TYPE,EncodingUtil.base64Decode(base64Data));
            }
        } catch (exception e) { 
            GlUt_Logger.logException(e);            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
    }   
}