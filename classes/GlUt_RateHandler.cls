/************************************************************************************************************
@author         Accenture : Satish Nair
@date           01-Nov-2017
@description:   This is handler class for RateTrigger
Revision(s):    
                
**************************************************************************************************************/
public with sharing class GlUt_RateHandler extends GlUt_TriggerHandlerBase{
    //Variable Declaration
    private static final String CLASS_NAME = 'GlUt_RateHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    //End Variable Declaration

    /**********************************************************************************************
    @author         Accenture: Satish Nair
    @date           01-Nov-2017
    @param          GlUt_TriggerHandlerObj inputParam
    @return         void
    @description        This method is an example for handling the initial invocation of the trigger
                    for this example it simply updates the list of new records to make a recursive
                    call
    **********************************************************************************************/
    public override void  MainEntry(GlUt_TriggerHandlerObj inputParam){
        try{
            
            if( inputParam.isInsert && inputParam.isBefore ){
                checkOverlapRatesIfNotBanded(inputParam.newlist);      // Commented Validation Call  AT-3226
            }
            if( inputParam.isInsert && inputParam.isAfter ){
                UpdateEndDateOfExistingRateIfStartNew(inputParam.newlist);
            }
            if( inputParam.isUpdate && inputParam.isBefore ){
                checkOverlapRatesIfNotBanded(inputParam.newlist);     // Commented Validation  Call  AT-3226
            }
            if( inputParam.isUpdate && inputParam.isAfter ){
                
            }  
            if( inputParam.isDelete && inputParam.isBefore ){
                
            }
            if( inputParam.isDelete && inputParam.isAfter ){
                
            }  
        }
        catch (Exception ex){
            GlUt_Logger.logException(ex);
        }
        
        finally{   
            //Reset the active function to null in case this class was first in stack
            //this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();
        }
        //Cause recursion by making the trigger fire again by doing a second update on the account
        system.debug('Running Trigger Code');
    }
    
    /**********************************************************************************************
    @author        Echo : Dependra Singh
    @date          07-Mar-2019
    @param         List<Rate> newList
    @return        void
    @description   This utility method is used to update Where the existing rate for the Service Item Type has no end date 
				   the current rate will be ended on the day before the new Start Date 
    **********************************************************************************************/
    public static void UpdateEndDateOfExistingRateIfStartNew(List<Rate__c> newList){
        Set<Id> setRateIds = new Set<Id>();
        Set<Id> setServiceItemType = new Set<Id>();
        Map<Id,Rate__c> mapRateByServiceItemId = new Map<Id,Rate__c>();
        List<Rate__c> rateListToUpdate = new List<Rate__c>();
        for(Rate__c objRate : newList){
            setServiceItemType.add(objRate.ServiceItemType__c);
            setRateIds.add(objRate.Id);
        }
        for(Rate__c objRate : [SELECT Id,StartDate__c,EndDate__c,ServiceItemType__c,Banded__c FROM Rate__c WHERE Id NOT IN:setRateIds AND ServiceItemType__c IN: setServiceItemType]){
            if(objRate.EndDate__c == null){
                if(!mapRateByServiceItemId.containsKey(objRate.ServiceItemType__c)){
                    mapRateByServiceItemId.put(objRate.ServiceItemType__c,objRate);
                }
            }
        }
        for(Rate__c objNewRate : newList){
            if(!objNewRate.Banded__c){
                if(!mapRateByServiceItemId.isEmpty() && mapRateByServiceItemId.containsKey(objNewRate.ServiceItemType__c)){
                    Rate__c objOldRate = mapRateByServiceItemId.get(objNewRate.ServiceItemType__c);
                    if(objOldRate != null){
                        objOldRate.EndDate__c = objNewRate.StartDate__c.addDays(-1);
                        rateListToUpdate.add(objOldRate);
                    }
                }
            }
        }
        if(!rateListToUpdate.isEmpty()){
            rateListToUpdate = (List<Rate__c>) GlUt_FieldSecurity.cleanseFields(rateListToUpdate, false);
            update rateListToUpdate;
        }
    }
    /**********************************************************************************************
    @author        Accenture : Satish Nair
    @date          01-Nov-2017
    @param         List<Rate> newList
    @return        void
    @description   This utility method is used to create Rate and check for duplicates.
				   Where the existing rate for the Service Item Type has an end date then a new validation will be applied so that there is no overlap in Rates. 
				   An error message will be displayed “The rate period overlaps with an existing rate. Please adjust the start date”  
	@revesion	   Updated By Dependra Singh- 07-03-2019 - UL-495
    **********************************************************************************************/
    public static void checkOverlapRatesIfNotBanded(List<Rate__c> newList){
        Set<Id> setServiceItemType = new Set<Id>();
        Set<Id> setRateIds = new Set<Id>();
        Map<Id,List<Rate__c>> mapOfRateListByServiceItemType = new Map<Id,List<Rate__c>>();
        for(Rate__c objNewRate : newList){
            setServiceItemType.add(objNewRate.ServiceItemType__c);
            setRateIds.add(objNewRate.Id);
        }
        //Query the Service Item Type for all the active Rates
        for(Rate__c objRate : [SELECT Id,StartDate__c,EndDate__c,ServiceItemType__c,Banded__c FROM Rate__c WHERE id NOT in:setRateIds AND ServiceItemType__c in: setServiceItemType]){
            if(!objRate.Banded__c){
                if(String.isNotBlank(objRate.ServiceItemType__c) && !mapOfRateListByServiceItemType.containsKey(objRate.ServiceItemType__c)){
                    mapOfRateListByServiceItemType.put(objRate.ServiceItemType__c,new List<Rate__c>());
                }
                mapOfRateListByServiceItemType.get(objRate.ServiceItemType__c).add(objRate);
            }
        }
        for(Rate__c objNewRate : newList){
            if(!objNewRate.Banded__c){
                if(!mapOfRateListByServiceItemType.isEmpty() && mapOfRateListByServiceItemType.containsKey(objNewRate.ServiceItemType__c)){
                    for(Rate__c  objOldRate : mapOfRateListByServiceItemType.get(objNewRate.ServiceItemType__c)){
                        if((objOldRate.StartDate__c<=objNewRate.StartDate__c && objOldRate.EndDate__c>=objNewRate.StartDate__c)||(objNewRate.EndDate__c>=objOldRate.StartDate__c && objNewRate.EndDate__c<=objOldRate.EndDate__c)){
                            objNewRate.addError(System.Label.CuApRateOverlapError);
                        }
                        if(objNewRate.StartDate__c <= objOldRate.StartDate__c){
                            if(objNewRate.EndDate__c != null && objNewRate.EndDate__c  >= objOldRate.StartDate__c){
                                objNewRate.EndDate__c = objOldRate.StartDate__c.addDays(-1);
                            }else{
                                objNewRate.EndDate__c =  objOldRate.StartDate__c.addDays(-1);
                            }
                        }
                    }   
                }
            }
        }
    }
}