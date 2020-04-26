/******************************************************************************
@author         Echo: Ankit Gangwani
@date           16 Jan 2019
@description    Class is used to get all the final bills with positive amount of 
				total outstanding and matched with customized amount through metadata (FinalBill__mdt)
				Heroku will update the DoNotPrint__c to True for associated bills
*******************************************************************************/
global with sharing class BlBt_FinalBillsWriteOff extends GlBt_BatchProcess implements Schedulable,Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    
    global static final String CLASS_NAME = 'BlBt_FinalBillsWriteOff';
    global static final String DEBUG = '[' + CLASS_NAME + '] ';
    global static final Integer  BATCHSIZE =  200 ;
    
    global BatchRequestQueue__c batchRequestQueue;
                       
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           16 Jan 2019
    @param          SchedulableContext SC
    @return         void
    @description    Makes this batch schedulable
    *******************************************************************************/
    global void execute(SchedulableContext SC) {	// so that it could be scheduled from Salesforce standard UI
        Database.executeBatch(new BlBt_FinalBillsWriteOff(), BATCHSIZE) ;
    }
                                        
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           16 Jan 2019
    @description    Override GlBt_BatchProcess method as per Batch framework.
    *******************************************************************************/
    global override void Initialise(BatchRequestQueue__c brq){
        this.batchRequestQueue = brq;
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           16 Jan 2019
    @description    Batch's start method
					Retrieve the XML file data and iterate through it 
					and query the Concessions record using the CRN number from the XML data
   *******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {        
        
        // Update the Batch Request Queue status to "Processing"
        if(batchRequestQueue != null){
            updateBRQ(batchRequestQueue, LoBt_Constants.BRQPROCESSINGSTATUS);
        }
        // Fetch the Bill Amount value from Custom Metadata DoNotPrintBelowField__c field
        Decimal doNotPrintBelow = 0.0;
        FinalBill__mdt mdt = getFinalBillDetails();
        if (mdt !=null && mdt.DoNotPrintBelow__c != null) {
            doNotPrintBelow = mdt.DoNotPrintBelow__c;
        }
        //Get all the final Bills based on doNotPrintBelow amount
        String sQuery = 'SELECT Id, '  + 
            GlUt_APIConstantsBill.FINALBILLAPINAME + ',' +
            GlUt_APIConstantsBill.DONOTPRINTAPINAME + ',' + 
            GlUt_APIConstantsBill.TOTALAMOUNTOUTSTANDINGAPINAME + 
            ' FROM ' + GlUt_APIConstantsBill.BILLAPINAME + 
            ' WHERE ' + GlUt_APIConstantsBill.FINALBILLAPINAME + ' = TRUE AND ' +
            GlUt_APIConstantsBill.DONOTPRINTAPINAME + ' = false AND ' + 
            GlUt_APIConstantsBill.TOTALAMOUNTOUTSTANDINGAPINAME + ' > 0 AND ' +
            GlUt_APIConstantsBill.TOTALAMOUNTOUTSTANDINGAPINAME + ' <= ' + doNotPrintBelow;
        return Database.getQueryLocator(sQuery);        
    }

   
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           16 Jan 2019
    @description    Batch's execute method
					Prepare the payload of Bill Ids and passes to the external system (Heroku)
    *******************************************************************************/
    global void execute(Database.BatchableContext bc, List<Bill__c> bills){ 
        try{
            String payload;
            String endPoint;
            endPoint = BlUt_HerokuWebservices.PRINT_BILL; 
            List<Id> billIdsList = new List<Id>();   
            for(Bill__c objBill : bills){
                billIdsList.add(objBill.Id);
            }
            
            PayloadParam objParam = new PayloadParam();
            objParam.billIds = billIdsList;
            payload = Json.serialize(objParam);
            
            // make the callout            
            HttpResponse response = BlUt_HerokuWebservices.makeCallout(endPoint, 2000, 'application/json', payload, 'PUT');
            
            // handle response
            if (response.getStatusCode() == 200) {
                // Update the Batch Request Queue status to "Completed"
                updateBRQ(batchRequestQueue, LoBt_Constants.BRQSTATUS);                
            } else {
                // Update the Batch Request Queue status to "Error"                                
                updateBRQ(batchRequestQueue, LoBt_Constants.BRQSTATUSERRORS);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            GlUt_Logger.writeLogsToDatabase();
        } 
    } 
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           16 Jan 2019
    @description    Batch's final method
   *******************************************************************************/
    global void finish(Database.BatchableContext bc){        
        
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           16 Jan 2019
    @description    updateBRQ - Update Batch Request Queue Status
   *******************************************************************************/
    public static list<BatchRequestQueue__c> updateBRQ(BatchRequestQueue__c brqRec , String Status){
        //SOQL is required here in order to prevent "Record is Read-only" during batch context
        list<BatchRequestQueue__c> listBatchRequestQueueToUpdate = new list<BatchRequestQueue__c>() ;
        for(BatchRequestQueue__c brq :  [Select id,Status__c from BatchRequestQueue__c where Id =: brqRec.Id]) {
            brq.Status__c = Status ;
            listBatchRequestQueueToUpdate.add(brq) ;
        }
        if(!listBatchRequestQueueToUpdate.isEmpty()){
            listBatchRequestQueueToUpdate = (List<BatchRequestQueue__c>) GlUt_FieldSecurity.cleanseFields(listBatchRequestQueueToUpdate, false);
            update listBatchRequestQueueToUpdate ;
        }        
        return listBatchRequestQueueToUpdate ;
    }
                                        
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           16 Jan 2019
    @description    Wrapper class to prepare payload of Bill Ids
   *******************************************************************************/
    public class PayloadParam {
        public List<Id> billIds;
    }
     /******************************************************************************
    @author         Echo:Dependra Singh
    @date           11 Mar 2019
    @description    Method is used to set custom meta data  type data for Final Bill.
    *******************************************************************************/
    private static FinalBill__mdt getFinalBillDetails(){
        List<FinalBill__mdt> mdts = new  List<FinalBill__mdt>();
        if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap != null && GlUt_CustomMetaDataUtility.customMetadataRecordsMap.keyset().size()  > 0){
            if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap.containsKey(GlUt_Constants.FINALBILLQUERY)){
                mdts = (List<FinalBill__mdt>)GlUt_CustomMetaDataUtility.customMetadataRecordsMap.get(GlUt_Constants.FINALBILLQUERY);  
            }
        }else{
            mdts = (List<FinalBill__mdt>) new GlUt_CustomMetaDataUtility().getCustomMetadataRecords(GlUt_Constants.FINALBILLQUERY);
        }
        if(!mdts.isEmpty()){
            return mdts[0];
        }else{
            return null;
        }
    }
}