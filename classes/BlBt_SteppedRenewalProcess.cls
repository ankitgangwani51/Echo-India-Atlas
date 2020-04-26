/******************************************************************************
@author         Dependra Singh
@date           16 July 2018
@description    Batch Class For Renewal process for stepped 
*******************************************************************************/
global class BlBt_SteppedRenewalProcess implements Schedulable, Database.Batchable<sObject> {
    private static List<string> steppedTariffFields;
    static{
        steppedTariffFields = new List<string>();
        steppedTariffFields.add(GlUt_APIConstantsSteppedTariff.STARTDATEAPINAME);
        steppedTariffFields.add(GlUt_APIConstantsSteppedTariff.ENDDATEAPINAME);
        steppedTariffFields.add(GlUt_APIConstantsSteppedTariff.RENEWALMONTHAPINAME);  
        steppedTariffFields.add(GlUt_APIConstantsSteppedTariff.BILLINGCONTRACTAPINAME);
        steppedTariffFields.add(GlUt_APIConstantsSteppedTariff.RENEWALSTEPPEDTARIFFAPINAME);	
        steppedTariffFields.add(GlUt_APIConstantsSteppedTariff.SERVICETYPEAPINAME);	
    }    
    /******************************************************************************
    @author         Sudhir Kumar
    @date           11 Oct 2018
	@param			SchedulableContext sc
    @description    excecute method for Schedulable interface
					AT-3992 - Dynamic SOQL for BlBt_SteppedRenewalProcess - Added Header (Security Review)
    *******************************************************************************/
    global void execute(SchedulableContext sc){
        // Schedule the batch class
        Database.executeBatch(this);           
    }
    
    /******************************************************************************
    @author         Sudhir Kumar
    @date           11 Oct 2018
	@param			Database.BatchableContext bc
    @description    start method for Batchable interface
					AT-3992 - Dynamic SOQL for DrBt_ProcessAction - Added Header (Security Review)
							- Replaced Dynamic SOQL with static SOQL and using getQuery of getQueryLocator.
					//collect the batches of records or objects to be passed to execute
    *******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        Date dtTodayPlus14;
        // Date variable for end date is more than 14 days in the future
        String noOfDays = System.label.BlBt_SteppedTariffRenewalNoOfDays;
        if(noOfDays != null){
            dtTodayPlus14 = Date.today().addDays(Integer.ValueOf(noOfDays));
        }
        
        //string variable to store the query which need to pass in query locater.
        string sQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(steppedTariffFields,','), 
            GlUt_APIConstantsSteppedTariff.STEPPEDTARIFFAPINAME +' WHERE ' + 
            GlUt_APIConstantsSteppedTariff.STARTDATEAPINAME + ' < TODAY AND ' + 
            GlUt_APIConstantsSteppedTariff.ENDDATEAPINAME + ' != null AND ' +  
            GlUt_APIConstantsSteppedTariff.ENDDATEAPINAME + ' > TODAY AND ' +  
            GlUt_APIConstantsSteppedTariff.ENDDATEAPINAME + ' <=: dtTodayPlus14 AND ' + 
            GlUt_APIConstantsSteppedTariff.RENEWALMONTHAPINAME + ' != null AND ' + 
            GlUt_APIConstantsSteppedTariff.RENEWALSTEPPEDTARIFFAPINAME + ' = null'}); 
        
        system.debug('sQuery = '+sQuery);
        return Database.getQueryLocator(sQuery);
    }

    /******************************************************************************
    @author         Sudhir Kumar
    @date           11 Oct 2018
	@param			Database.BatchableContext bc, List<DebtRecoveryAction__c> scope
    @description    execute method for Batchable interface
					AT-3992 - Dynamic SOQL for DrBt_ProcessAction - Added Header (Security Review)
                    AT-4891/2 Code Check Marx Changes for FLS INSERT/UPDATE
    *******************************************************************************/
    global void execute(Database.BatchableContext bc, List<SteppedTariff__c> records){   
         system.debug('records = '+records);
        // set of Id to store step tariff ids.
        set<Id> steppedTariffIdSet = new set<Id>();
        //Map<Id, List<SteppedTariffService__c>> to keep the existing stepped tariff service records that are linked to the stepped tariff record.   
        Map<Id, List<SteppedTariffService__c>> ListOfSTSBySteppedTariffIdMap = new Map<Id, List<SteppedTariffService__c>>();
        //Map<Id, SteppedTariff__c> to keep new stepped tariff record regarding old stepped tariff record Id
        Map<Id, SteppedTariff__c> newSteppedTariffIdByOldSTMap = new Map<Id, SteppedTariff__c>();
        //  List of new stepped tariff record 
        List<SteppedTariff__c> steppedTariffNewList = new List<SteppedTariff__c>();
        //  List of new stepped tariff services record 
        List<SteppedTariffService__c> steppedTariffServicesNewList = new List<SteppedTariffService__c>();
        //  List of existing stepped tariff services record to update
        List<SteppedTariff__c> steppedTariffExistingListToUpdate = new List<SteppedTariff__c>();
        // If records list is not empty then creating set of stepped tariff record ids.
        
        try{
            if(records != null  && !records.isEmpty()){
                for(SteppedTariff__c objSteppedTraiff : records){
                    steppedTariffIdSet.add(objSteppedTraiff.Id);
                }
                // If set size is greater than 0 then getting all stepped tariff services records and creating map.
                if(steppedTariffIdSet.size() > 0){
                    //Find the service that is linked to the stepped tariff service record, only process records where the end date is not populated
                    List<SteppedTariffService__c> steppedTariffServicesList = [SELECT Id , Name, EndDate__c,Service__c, StartDate__c, SteppedTariff__c 
                                                                               FROM SteppedTariffService__c 
                                                                               WHERE SteppedTariff__c  IN : steppedTariffIdSet 
                                                                               AND EndDate__c = null];
                    if(steppedTariffServicesList != null && !steppedTariffServicesList.isEmpty()){
                        for(SteppedTariffService__c objSteppedTarrifServices : steppedTariffServicesList){
                            if(objSteppedTarrifServices.SteppedTariff__c != null){
                                if(!ListOfSTSBySteppedTariffIdMap.containsKey(objSteppedTarrifServices.SteppedTariff__c)){
                                    ListOfSTSBySteppedTariffIdMap.put(objSteppedTarrifServices.SteppedTariff__c, new List<SteppedTariffService__c>());
                                } 
                                ListOfSTSBySteppedTariffIdMap.get(objSteppedTarrifServices.SteppedTariff__c).add(objSteppedTarrifServices);
                            }
                        }
                    }
                    system.debug('ListOfSTSBySteppedTariffIdMap===='+ListOfSTSBySteppedTariffIdMap);
                    // The new stepped tariff record will need to have the following fields created. 
                    // Lookup to the Contract, based on the original stepped tariff record. 
                    // The start date is the end date of the previous stepped record + 1 day. 
                    // The end date is the start date plus the number of renewal months specific on the stepped tariff record.
                    // The renewal Months will be copied from the original stepped tariff record
                    
                    for(SteppedTariff__c objSteppedTraiff : records){
                        SteppedTariff__c  objNewSteppedTraiff = new SteppedTariff__c();
                        objNewSteppedTraiff.BillingContract__c = objSteppedTraiff.BillingContract__c; 
                        if(objSteppedTraiff.EndDate__c != null){
                            objNewSteppedTraiff.StartDate__c = objSteppedTraiff.EndDate__c.addDays(1);
                            objNewSteppedTraiff.EndDate__c = objSteppedTraiff.EndDate__c.addMonths(Integer.valueOf(objSteppedTraiff.RenewalMonths__c));
                        }                        
                        objNewSteppedTraiff.RenewalMonths__c = objSteppedTraiff.RenewalMonths__c; 
                        objNewSteppedTraiff.ServiceType__c = objSteppedTraiff.ServiceType__c;
                        steppedTariffNewList.add(objNewSteppedTraiff);
                    }
                     system.debug('steppedTariffNewList = '+steppedTariffNewList);
                    // If list is not empty then inserting new stepped tariff records.
                    if(!steppedTariffNewList.isEmpty()){
                        steppedTariffNewList = (List<SteppedTariff__c>) GlUt_FieldSecurity.cleanseFields(steppedTariffNewList, false); //AT-4891 Code Check Marx Changes Starts/Ends Here.
                        insert steppedTariffNewList;
                    }
                    //if old and new list size are equal then creating map.
                    if(records.size() == steppedTariffNewList.size()){
                        for(integer i = 0 ; i < records.size() ; i++){
                            if(!newSteppedTariffIdByOldSTMap.containsKey(records[i].Id)){
                                newSteppedTariffIdByOldSTMap.put(records[i].Id, steppedTariffNewList[i]);
                            }
                            records[i].RenewalSteppedTariff__c = steppedTariffNewList[i].Id;
                            steppedTariffExistingListToUpdate.add(records[i]);
                        }
                    }
                  
                    // Creating new Stepped Tariff services and linking with newly created stepped tariff.
                    // A lookup to the new Stepped Tariff record that has been created. 
                    // A lookup to the service record as per previous stepped tariff service record. 
                    // The start date will be copied from the start date of the stepped tariff record. 
                    // The end date will be copied from the end date of the stepped tariff record. 
                    if(ListOfSTSBySteppedTariffIdMap.keySet().size() > 0){
                        for(Id objId : ListOfSTSBySteppedTariffIdMap.keySet()){
                            List<SteppedTariffService__c> lstStepTariffServices = ListOfSTSBySteppedTariffIdMap.get(objId);
                            if(lstStepTariffServices != null && !lstStepTariffServices.isEmpty()){
                                for(SteppedTariffService__c objSTS : lstStepTariffServices){
                                    SteppedTariffService__c objNewSTS = new SteppedTariffService__c();
                                    objNewSTS.Service__c = objSTS.Service__c;
                                    if(newSteppedTariffIdByOldSTMap.containsKey(objSTS.SteppedTariff__c)){
                                        objNewSTS.SteppedTariff__c = newSteppedTariffIdByOldSTMap.get(objSTS.SteppedTariff__c).Id;
                                        objNewSTS.StartDate__c = newSteppedTariffIdByOldSTMap.get(objSTS.SteppedTariff__c).StartDate__c;
                                        objNewSTS.EndDate__c = newSteppedTariffIdByOldSTMap.get(objSTS.SteppedTariff__c).EndDate__c;
                                    }
                                    steppedTariffServicesNewList.add(objNewSTS);
                                }
                            }
                        }
                    }
                    system.debug('steppedTariffServicesNewList = '+steppedTariffServicesNewList); 
                    // If list is not empty then inserting new stepped tariff services records.
                    if(!steppedTariffServicesNewList.isEmpty()){
                        steppedTariffServicesNewList = (List<SteppedTariffService__c>) GlUt_FieldSecurity.cleanseFields(steppedTariffServicesNewList, false); //AT-4891 Code Check Marx Changes Starts/Ends Here.
                        insert steppedTariffServicesNewList;
                    }
                    system.debug('steppedTariffExistingListToUpdate = '+steppedTariffExistingListToUpdate); 
                    // If list is not empty then updating existing stepped tariff records.
                    if(!steppedTariffExistingListToUpdate.isEmpty()){
                        steppedTariffExistingListToUpdate = (List<SteppedTariff__c>) GlUt_FieldSecurity.cleanseFields(steppedTariffExistingListToUpdate, false); //AT-4892 Code Check Marx Changes Starts/Ends Here.
                        update steppedTariffExistingListToUpdate;
                    }
                }
            }   
        }catch(Exception ex){
            GlUt_Logger.logException(ex);
        } 
        finally{
            GlUt_Logger.writeLogsToDatabase();
        }
    }    
    
    /******************************************************************************
    @author         Sudhir Kumar
    @date           11 Oct 2018
	@param			Database.BatchableContext bc
    @description    finish method for Batchable interface - execute any post-processing operations
					AT-3992 - Dynamic SOQL for DrBt_ProcessAction - Added Header (Security Review)
    *******************************************************************************/
    global void finish(Database.BatchableContext bc){
        
    }   
    
}