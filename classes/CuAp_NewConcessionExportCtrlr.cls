/******************************************************************************
@author         Echo: Dependra Singh
@date           27 December 2018
@description    Component controller for New Concession Export Request lightning component
*******************************************************************************/
public class CuAp_NewConcessionExportCtrlr {
 /**********************************************************************************************
    @author      : Echo:Dependra Singh
    @date        : 27 December 2018
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
            string convert2Json='';
            if(!timetableID.isEmpty() && !periodId.isEmpty() && !bookIds.isEmpty()){
                CuPr_ConcessionExportParameters objectConcessionExportParams = new CuPr_ConcessionExportParameters();
                objectConcessionExportParams.timetableID   = timetableID[0];
                objectConcessionExportParams.periodId      = periodId[0];
                objectConcessionExportParams.booksToExport = bookIds;
                convert2Json = JSON.serialize(objectConcessionExportParams);
            }
            if(!string.isBlank(convert2Json)){
                objBRQ = GlUt_BatchRequestQueueUtilities.createBatchRequestQueue(convert2Json,true,LoAp_Constants.HIGH,null,null,LoAp_Constants.BATCHPROCESSOPERATION,
                                                                                 LoAp_Constants.BATCHPROCESSCONSCESSIONEXPORT, UserInfo.getUserId(),
                                                                                 LoAp_Constants.INITIALISED, GlUt_Constants.BRTYPECONCESSION); 
                
                if(objBRQ.Id != null){
                    returnId = objBRQ.Id;
                }
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