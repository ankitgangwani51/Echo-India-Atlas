/**********************************************************************************************
@author      : Echo:Amit K.
@date        : 28 May 2018
@description : This class is used to create Batch Request Queue Record. 
@revesion 		Changes by Dependra Singh - Security Review - 17-09-2018
**********************************************************************************************/
public class LoAp_NewSweepUpEstimateRequestCtrlr {
    /**********************************************************************************************
    @author      : Echo:Amit K.
    @date        : 28 May 2018
    @params      : List<Id> timetableID,List<Id> periodId,List<Id> bookIds
    @return      : Id (BRQ ID)
    @description : This method is used to create Batch Request Queue Record. 
    **********************************************************************************************/
    @AuraEnabled
    public static Id  createBRQ(List<Id> timetableID,List<Id> periodId,List<Id> bookIds,String executionMode){
        Savepoint sp = Database.setSavepoint();
        BatchRequestQueue__c objBRQ;
        try{  
            string convert2Json;
            if(!timetableID.isEmpty() && !periodId.isEmpty() && !string.isBlank(executionMode)){
                LoPr_SweepUpParameters objectSweepUpParams = new LoPr_SweepUpParameters();
                objectSweepUpParams.timetableID   = timetableID[0];
                objectSweepUpParams.periodId      = periodId[0];
                objectSweepUpParams.booksToEstimate = bookIds;
                objectSweepUpParams.executionMode = executionMode;
                convert2Json = Json.serialize(objectSweepUpParams);
            }
            if(!string.isBlank(convert2Json)){
                //Changes by Dependra Singh - Security Review - 17-09-2018-AT-3696
                
                objBRQ = GlUt_BatchRequestQueueUtilities.createBatchRequestQueue(convert2Json,true ,LoAp_Constants.HIGH,null, 
                                                                                 null,LoAp_Constants.BATCHPROCESSOPERATION,
                                                                                 LoAp_Constants.BATCHPROCESSSWEEPUPESTIMATES,UserInfo.getUserId(),
                                                                                 LoAp_Constants.INITIALISED,null);
                
                system.debug('objBRQ  '   +  objBRQ);
            }
        }
        catch (exception e){
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return objBRQ.Id;
    }
    
}