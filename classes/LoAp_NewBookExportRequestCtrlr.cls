/******************************************************************************
@author         Echo: Amit K.
@date           08 May 2018
@description    Component controller for New Book Export Request lightning component
@revesion 		Changes by Dependra Singh - Security Review - 17-09-2018
*******************************************************************************/
public with sharing class LoAp_NewBookExportRequestCtrlr {
    /**********************************************************************************************
    @author      : Echo:Amit K.
    @date        : 08 May 2018
    @params      : List<Id> timetableID,
				   List<Id> periodId,
				   List<Id> bookIds
    @return      : Id (BRQ ID)
    @description : This method is used to create Batch process + Batch Request Queue Record. 
    **********************************************************************************************/
    @AuraEnabled
    public static Id  createBRQ(List<Id> timetableID,List<Id> periodId,List<Id> bookIds){
        Savepoint sp = Database.setSavepoint();
        BatchRequestQueue__c objBRQ;
        Id returnId = null; 
        try{  
            string convert2Json;
            if(!timetableID.isEmpty() && !periodId.isEmpty() && !bookIds.isEmpty()){
                LoPr_BookExportParameters objectBookExportParams = new LoPr_BookExportParameters();
                objectBookExportParams.timetableID   = timetableID[0];
                objectBookExportParams.periodId      = periodId[0];
                objectBookExportParams.booksToExport = bookIds;
                convert2Json = Json.serialize(objectBookExportParams);
            }
            //Changes by Dependra Singh - Security Review - 17-09-2018 - AT-3696
            if(!string.isBlank(convert2Json)){
                objBRQ = GlUt_BatchRequestQueueUtilities.createBatchRequestQueue(convert2Json,true,LoAp_Constants.HIGH,null,null,LoAp_Constants.BATCHPROCESSOPERATION,
                                                                                 LoAp_Constants.BATCHPROCESSEXPORTBOOKCLASSNAME, UserInfo.getUserId(),
                                                                                 LoAp_Constants.INITIALISED, GlUt_Constants.BRTYPEMETERBOOK); 
                returnId = objBRQ.Id;
            }
        }
        catch (exception e){
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return returnId;
    }
}