/******************************************************************************
@author         Echo: Ankit Gangwani
@date           29 Nov 2018
@description    Batch class to renew discount based on new discount types
*******************************************************************************/

global with sharing class CuBt_DiscountRenewal extends GlBt_BatchProcess implements Database.Batchable<sObject>,Database.Stateful{
    
    private static final String CLASS_NAME = 'CuBt_DiscountRenewal';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    global static string sQuery;
    global BatchRequestQueue__c batchRequestQueue;
    global Set<Id> discountTypeIds;
    global Map<Id,Id> mapOfDiscountTypeId2DiscountTypeSLId;
    global List<Discount__c> existingDiscountLists;
    global List<DiscountType__c> allDiscountTypeLists;
    global List<Discount__c> newDiscountList = new List<Discount__c>();
    global Map<Id,DiscountType__c> mapOfDiscountTypeId2DiscountTypeRecord;
    private Map<String,String> mapOfDiscountIdToErrorMessage = new Map<String,String>();
    
    private static List<string> discountTypeFields;
    static{
        discountTypeFields = new List<string>();
        discountTypeFields.add(GlUt_APIConstantsDiscountType.DISCOUNTTYPESELFLOOKUPAPINAME);        
    }   
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           29 Nov 2018
    @description    Override GlBt_BatchProcess method as per Batch framework.
    *******************************************************************************/
    global override void Initialise(BatchRequestQueue__c brq){
        this.batchRequestQueue = brq;
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
	@date           29 Nov 2018
    @description    Batch's start method
    *******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {        
        discountTypeIds = new Set<Id>();
        CuBt_DiscountTypeParameters discountTypeParam;  
        updateBRQ(new list<BatchRequestQueue__c> {batchRequestQueue},LoBt_Constants.BRQPROCESSINGSTATUS); //Checkmarx
        
        try{
            if(batchRequestQueue != null && batchRequestQueue.Parameters__c == null){
                createBatchError(batchRequestQueue);
            }
            else{
                discountTypeParam = CuBt_DiscountTypeParameters.parse(batchRequestQueue.Parameters__c);
                discountTypeIds.addAll(discountTypeParam.discountTypeID);
                
                if(discountTypeIds.size() == 0){
                    createBatchError(batchRequestQueue);
                }
                
                if(discountTypeIds != null && discountTypeIds.size() > 0){
                    sQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(discountTypeFields,','), 
                        GlUt_APIConstantsDiscountType.DISCOUNTTYPEAPINAME +' WHERE ' + 
                        LoAp_Constants.Id + ' IN:discountTypeIds'});                 
                }
            }
        }catch (exception e){
            GlUt_Logger.logException(e);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return Database.getQueryLocator(sQuery);
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           29 Nov 2018
    @description    Batch's execute method
    *******************************************************************************/
    global void execute(Database.BatchableContext bc, List<DiscountType__c> discountTypeLists){
        allDiscountTypeLists = new List<DiscountType__c>();
        mapOfDiscountTypeId2DiscountTypeSLId = new Map<Id,Id>();
        mapOfDiscountTypeId2DiscountTypeRecord = new Map<Id,DiscountType__c>();
        newDiscountList = new List<Discount__c>();
        
        try{
            for(DiscountType__c discountType: discountTypeLists){
                if(!mapOfDiscountTypeId2DiscountTypeSLId.containsKey(discountType.Id)){
                    mapOfDiscountTypeId2DiscountTypeSLId.put(discountType.Id, discountType.DiscountType__c);
                }
            }
            
            if(!mapOfDiscountTypeId2DiscountTypeSLId.isEmpty() && mapOfDiscountTypeId2DiscountTypeSLId.keySet().size() > 0){
                
                allDiscountTypeLists = [SELECT Id,
                                        StartDate__c, 
                                        EndDate__c,
                                        DiscountPerDay__c
                                        FROM DiscountType__c
                                        WHERE Id IN: mapOfDiscountTypeId2DiscountTypeSLId.keySet() 
                                        OR Id IN: mapOfDiscountTypeId2DiscountTypeSLId.values()];
                
                if(!mapOfDiscountTypeId2DiscountTypeSLId.isEmpty()){
                    for(DiscountType__c allDiscountType: allDiscountTypeLists){
                        if(!mapOfDiscountTypeId2DiscountTypeRecord.containsKey(allDiscountType.Id)){
                            mapOfDiscountTypeId2DiscountTypeRecord.put(allDiscountType.Id, allDiscountType);
                        }
                    }
                }
                
                existingDiscountLists = [SELECT Id,
                                         Name,
                                         DiscountType__c,
                                         Concession__c,                                     
                                         Concession__r.Validated__c,
                                         BaseDailyDiscountAmount__c,
                                         BillingContract__c,
                                         EndDate__c,
                                         Status__c
                                         FROM Discount__c 
                                         WHERE DiscountType__c IN: mapOfDiscountTypeId2DiscountTypeSLId.keySet()];
                                         
            }
            if(!existingDiscountLists.isEmpty()){
                mapOfDiscountIdToErrorMessage = new Map<String,String>();
                for(Discount__c oldDiscount : existingDiscountLists){
                    if(oldDiscount.Concession__c == null){
                        if(!mapOfDiscountIdToErrorMessage.containsKey(oldDiscount.Name))
                            mapOfDiscountIdToErrorMessage.put(oldDiscount.Name, System.Label.CuBt_ConcessionNotExist);
                        continue;
                    }
                    if(oldDiscount.Concession__c != null && !oldDiscount.Concession__r.Validated__c){
                        if(!mapOfDiscountIdToErrorMessage.containsKey(oldDiscount.Name))
                            mapOfDiscountIdToErrorMessage.put(oldDiscount.Name, System.Label.CuBt_ConcessionNotValidated);
                        continue;
                    }
                    if(oldDiscount.EndDate__c != null){
                        if(!mapOfDiscountIdToErrorMessage.containsKey(oldDiscount.Name))
                            mapOfDiscountIdToErrorMessage.put(oldDiscount.Name, System.Label.CuBt_DiscountNotActive);
                        continue;
                    }
                    
                    Id selfLookUpDiscountType = mapOfDiscountTypeId2DiscountTypeSLId.get(oldDiscount.DiscountType__c);
                    DiscountType__c discountTypeRecord = mapOfDiscountTypeId2DiscountTypeRecord.get(selfLookUpDiscountType);
                    Discount__c newDiscount 				= new Discount__c();
                    newDiscount.DiscountType__c 			= selfLookUpDiscountType;
                    newDiscount.StartDate__c 				= discountTypeRecord.StartDate__c;
                    newDiscount.EndDate__c 					= discountTypeRecord.EndDate__c;
                    newDiscount.BaseDailyDiscountAmount__c 	= discountTypeRecord.DiscountPerDay__c;
                    newDiscount.BillingContract__c 			= oldDiscount.BillingContract__c; 
                    newDiscount.Concession__c 				= oldDiscount.Concession__c;
                    newDiscount.Status__c					= oldDiscount.Status__c;
                    newDiscountList.add(newDiscount);                
                }
            }
            
            if(!newDiscountList.isEmpty()){
                newDiscountList = (List<Discount__c>) GlUt_FieldSecurity.cleanseFields(newDiscountList,false);
                Database.insert(newDiscountList); 
                newDiscountList = [SELECT Id, Name FROM Discount__c WHERE Id IN: newDiscountList];
                
            }  
        }catch (exception e){
            GlUt_Logger.logException(e);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************l
    @author         Echo: Ankit Gangwani
    @date           29 Nov 2018
    @description    Batch's final method
	@revision		AT-5259, 27/02/2019
					Modified the method to create output reports for Successfully
					Discount Renewals and Dicount Failures
    *******************************************************************************/
    global void finish(Database.BatchableContext bc){
        String fileData = '';
        DateTime currentDateTime = System.now();
        String formattedPDate = currentDateTime.format('ddMMyyyyhhmmss'); 
        
        if(mapOfDiscountIdToErrorMessage.size() > 0 && mapOfDiscountIdToErrorMessage.keySet().size() > 0){
            for(String discountName : mapOfDiscountIdToErrorMessage.keySet()){                    
                fileData += discountName + ' - ' + mapOfDiscountIdToErrorMessage.get(discountName) + '\r\n';
            }
            String successFile = CuAp_Constants.DISCOUNT_RENEWALS_FAILURES + '_' + formattedPDate + GlUt_Constants.REPORT_FILE_EXTENSION;  //'.txt';
            Id contentDocumentId = GlUt_ContentDocument.saveLinkedDocument(batchRequestQueue.Id, CuAp_Constants.DISCOUNT_RENEWALS_FAILURES, successFile, successFile, LoBt_Constants.SHARE_TYPE, blob.valueOf(fileData));
        }
        
        fileData = '';
        System.debug('newDiscountList = '+newDiscountList);
        if(!newDiscountList.isEmpty() && newDiscountList[0].Id != null){
            for(Discount__c newDiscount : newDiscountList){
                fileData += newDiscount.Name + ' - Renewed' + '\r\n';
            }
            String failureFile = CuAp_Constants.DISCOUNT_RENEWALS_SUCCESS + '_' + formattedPDate + GlUt_Constants.REPORT_FILE_EXTENSION;  //'.txt';
            Id contentDocumentId = GlUt_ContentDocument.saveLinkedDocument(batchRequestQueue.Id, CuAp_Constants.DISCOUNT_RENEWALS_SUCCESS, failureFile, failureFile, LoBt_Constants.SHARE_TYPE, blob.valueOf(fileData));
        }        
        updateBRQ(new list<BatchRequestQueue__c> {batchRequestQueue},LoBt_Constants.BRQSTATUS);  //Checkmarx
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           29 Nov 2018
    @param          BatchRequestQueue__c batchRequestQueue
    @return         BatchError__c
    @description    create Batch Error record
    *******************************************************************************/
    public static BatchError__c createBatchError(BatchRequestQueue__c batchRequestQueue ){        
        //create a Batch Error record 
        BatchError__c objBatchError = new BatchError__c(BatchRequestQueue__c = batchRequestQueue.Id, ErrorDetails__c = LoBt_Constants.INVALIDPARAMETERSERROR);
        Insert objBatchError;
        //update the Batch Request Queue Status to ‘Error’
        updateBRQ(new list<BatchRequestQueue__c> {batchRequestQueue},LoBt_Constants.BRQSTATUSERRORS);        //Checkmarx
        return objBatchError;
    }
   	
    /******************************************************************************
	@author         Echo: Ankit Gangwani
    @date           29 Nov 2018
    @param          BatchRequestQueue__c batchRequestQueue , String Status
    @return         BatchRequestQueue__c
    @description    update BRQ status
    *******************************************************************************/
    public static list<BatchRequestQueue__c> updateBRQ(list<BatchRequestQueue__c> batchRequestQueueList , String Status){ // Checkmarx: bulkify
        //SOQL is required here in order to prevent "Record is Read-only" during batch context
        set<Id> setBRQIds = new set<Id>() ;
        list<BatchRequestQueue__c> listBatchRequestQueueToUpdate = new list<BatchRequestQueue__c>() ;
        for(BatchRequestQueue__c brq : batchRequestQueueList) {
            setBRQIds.add(brq.Id) ;
        }
        for(BatchRequestQueue__c brq :  [Select id,Status__c from BatchRequestQueue__c where Id IN: setBRQIds]) {
            brq.Status__c = Status ;
            listBatchRequestQueueToUpdate.add(brq) ;
        }
        listBatchRequestQueueToUpdate = (List<BatchRequestQueue__c>) GlUt_FieldSecurity.cleanseFields(listBatchRequestQueueToUpdate,false);
        update listBatchRequestQueueToUpdate ;
        return listBatchRequestQueueToUpdate ;
    }
    
    
}