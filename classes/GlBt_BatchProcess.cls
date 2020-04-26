/**********************************************************************************************
@author         Echo : Sudhir Kumar
@date           07-May-2018
@description:   GlBt_BatchProcess must be implemented by each of the Batch Processes in the system in order for the process to work within framework. 
@revisions:     
**********************************************************************************************/

global virtual class GlBt_BatchProcess {

   global class NotImplementedException extends Exception{}  
    /**********************************************************************************************
    @author         Echo : Sudhir Kumar
    @date           07-May-2018
    @param          BatchRequestQueue__c batchRequest
    @return         void
    @description    The initialise method must be overridden in all batch classes that implement this virtual class. 
					This method is called from the Batch Request Queue trigger in order to load the Parameters for the Batch Process
    **********************************************************************************************/    
    global virtual void initialise(BatchRequestQueue__c batchRequest) {
         throw new NotImplementedException('Error Not Implemented');
    }
    /**********************************************************************************************
    @author         Echo : Sudhir Kumar
    @date           07-May-2018
    @param          List<ContentDocumentLink> documentLink
    @return         List<BatchError__c>
    @description    The fileImport method can be optionally overridden in the batch process requires that an uploaded file is imported into 
					a staging table prior to executing the batch class. If there are any errors during the import of the staging table, 
					these will be recorded as Batch Error records and returned to the calling procedure.
    **********************************************************************************************/   
    global virtual List<BatchError__c> fileImport(List<ContentDocumentLink> documentLink) {
        throw new NotImplementedException('Error Not Implemented');
    }
}