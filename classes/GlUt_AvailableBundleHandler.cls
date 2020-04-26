/***************************************************************************************************
@author        Echo : Dependra Singh
@date          29-Nov-2017
@description:  This is helper class used by Available Bundle object trigger  
@group         TriggerHelper
Revision(s)    Echo:Sudhir Kumar -> AT-3075
@description   If the Available Bundle has been marked as Default, Validate that there are no other Available Bundles linked to the same Available Service are also marked as Default.
Revision(s)	   Echo: Sudhir Kumar -> AT-3719, AT-3775, AT-3747, AT-3754 - Core CC
*******************************************************************************************************/
public with sharing class GlUt_AvailableBundleHandler extends GlUt_TriggerHandlerBase{
    // Variable declaration
    private static final String CLASS_NAME = 'GlUt_AvailableBundleHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    // End variable declaration
    
    /**********************************************************************************************
    @author        Echo: Dependra Singh
    @date          29-Nov-2017
    @param         GlUt_TriggerHandlerObj inputParam
    @return        void
    @description   This method is used to invoke method from trigger
    **********************************************************************************************/
    public override void  MainEntry(GlUt_TriggerHandlerObj inputParam){
        try{
            if( inputParam.isInsert && inputParam.isBefore ){
                preventDuplicateAvailableBundle(inputParam.newlist);
                checkDefaultAvailableBundle(inputParam.newlist);	// AT-3075
                checkForOnlyOneTariffBundle(inputParam.newlist,inputParam.oldMap);
            }
            if( inputParam.isInsert && inputParam.isAfter ){
                processBundleChangeOnAvailableBundle(inputParam.newmap, inputParam.oldmap) ;  // AT-3075
            }
            if( inputParam.isUpdate && inputParam.isBefore ){
                preventDuplicateAvailableBundle(inputParam.newlist);
                checkDefaultAvailableBundle(inputParam.newlist);	// AT-3075
                checkForOnlyOneTariffBundle(inputParam.newlist,inputParam.oldMap);
            }
            if( inputParam.isUpdate && inputParam.isAfter ){
                processBundleChangeOnAvailableBundle(inputParam.newmap, inputParam.oldmap) ;  // AT-3075
            }  
            if( inputParam.isDelete && inputParam.isBefore ){
                
            }
            if( inputParam.isDelete && inputParam.isAfter ){
                
            }  
        }
        catch (Exception ex){
            GlUt_Logger.logException(ex);
            GlUt_Logger.writeLogsToDatabase();
        }
        
        finally{   
            //Reset the active function to null in case this class was first in stack
            //this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
           
        }
        
    }
    
    /**********************************************************************************************
    @author        Echo: Sudhir Kumar
    @date          16-July-2018
    @param         map<Id, SObject> mapNewAvailableBundle
    @return        void
    @description   AT-3075-> This method is used to process available bundles om bundle change
    **********************************************************************************************/ 
    public void processBundleChangeOnAvailableBundle(map<Id, SObject> mapNewAvailableBundle, map<Id, SObject> mapOldAvailableBundle) {
        List<AvailableBundle__c> listNewAvailableBundle = (List<AvailableBundle__c>) mapNewAvailableBundle.values() ;
        map<Id, GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper> mapOfBundlesToProcess = new  map<Id, GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper>() ;
        if(mapOldAvailableBundle != null) {		// After update context
            for(AvailableBundle__c availableBundle : listNewAvailableBundle) {
                if(availableBundle.Bundle__c != ((AvailableBundle__c) mapOldAvailableBundle.get(availableBundle.Id)).Bundle__c) {
                    GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper availableBundleWrapper = new GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper() ;
                    availableBundleWrapper.availableBundle = availableBundle ;
                    availableBundleWrapper.effectiveDate = availableBundle.LastBundleChangeDate__c ;		// Effective Date set to Last Bundle Change Date
                    mapOfBundlesToProcess.put(availableBundle.Id, availableBundleWrapper) ;
                }
            }
            system.debug('On update-mapOfBundlesToProcess= ' + mapOfBundlesToProcess);
        } else {	// After insert context
            for(AvailableBundle__c availableBundle : listNewAvailableBundle) {
                if(availableBundle.Bundle__c != null) {
                    GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper availableBundleWrapper = new GlUt_ProcessAvailableBundle.GlUt_ProcessAvailableBundleWrapper() ;
                    availableBundleWrapper.availableBundle = availableBundle ;
                    if(availableBundle.LastBundleChangeDate__c != null) {
                        availableBundleWrapper.effectiveDate = availableBundle.LastBundleChangeDate__c ;		//  Effective Date set to Last Bundle Change Date
                    }  else {
                        availableBundleWrapper.effectiveDate = System.today() ;		// this is being set as null from SPD creation from Device wizard
                    } 
                    //availableBundleWrapper.effectiveDate = System.today() ;		//  Effective Date set to Today's Date for New ABs during Move-In ? Or MoveIn Date?
                    mapOfBundlesToProcess.put(availableBundle.Id, availableBundleWrapper) ;
                }
            }
        }
        //Now, call the GlUt_ProcessAvailableBundle class passing mapOfBundlesToProcess
        if(!mapOfBundlesToProcess.isEmpty()) {
            system.debug('mapOfBundlesToProcess2= ' + mapOfBundlesToProcess);
            GlUt_ProcessAvailableBundle.processAvailableBundleChange(mapOfBundlesToProcess) ;
        }
    }
    
   
    /**********************************************************************************************
    @author        Echo: Dependra Singh
    @date          10-Jan-2018
    @param         List<SObject> newlist
    @return        void
    @description   This method is used to prevent to create available bundle with the same combination of Available Service and Bundle
    **********************************************************************************************/ 
    public void preventDuplicateAvailableBundle(List<SObject> newlist)
    {
        //Start  Initializing variables    
        Set<Id> avaliableServiceIds = new set<Id>();
        Set<Id> bundleIds = new set<Id>();
        Set<String> uniqueCombinationOfASAndBundle = new Set<String>();
        Map<Id, String> uniqueCombinationMap = new Map<Id, String>();
        //End Initializing variables    
        // Checking if list is not empty
        if(!newlist.isEmpty()){
            for(AvailableBundle__c objAvailableBundle : (List<AvailableBundle__c>)newlist){
                if(objAvailableBundle.AvailableService__c != null){
                    avaliableServiceIds.add(objAvailableBundle.AvailableService__c); 
                }
                if(objAvailableBundle.Bundle__c != null){
                    bundleIds.add(objAvailableBundle.Bundle__c);
                }
            }
            
            // Creating unique combination. 
            for(AvailableBundle__c objAvailableBundle1 : [SELECT Id,
                                                          AvailableService__c,
                                                          Bundle__c 
                                                          FROM AvailableBundle__c 
                                                          WHERE AvailableService__c IN :avaliableServiceIds 
                                                          AND Bundle__c IN : bundleIds]){
                                                              if(objAvailableBundle1.AvailableService__c!= null && objAvailableBundle1.Bundle__c != null){
                                                                  
                                                                  String  uniqueCombination ='';
                                                                  uniqueCombination = string.valueOf(objAvailableBundle1.AvailableService__c) 
                                                                      + string.valueOf(objAvailableBundle1.Bundle__c);
                                                                  if(!uniqueCombinationMap.containsKey(objAvailableBundle1.Id)){
                                                                      uniqueCombinationMap.put(objAvailableBundle1.Id, uniqueCombination);
                                                                  }
                                                              }
                                                          }
            
            // convert list to set
            Set<String> uniqueCombinations = new Set<String>();
            uniqueCombinations.addAll(uniqueCombinationMap.values());
            
            // Preventing to create if record with same combination is alerady exist.
            for(AvailableBundle__c objAvailableBundle2 : (List<AvailableBundle__c>)newlist){   
                if(objAvailableBundle2.AvailableService__c!= null && objAvailableBundle2.Bundle__c != null){
                    
                    String uniqueCombination='';
                    uniqueCombination= string.valueOf(objAvailableBundle2.AvailableService__c) 
                        + string.valueOf(objAvailableBundle2.Bundle__c);
                    
                    if ((!uniqueCombinationMap.keySet().contains(objAvailableBundle2.Id) || uniqueCombinationMap.get(objAvailableBundle2.Id) != uniqueCombination)
                        && uniqueCombinations.contains(uniqueCombination)) {
                            objAvailableBundle2.addError(System.Label.GlUt_AvailableBundleDuplicateMessage);
                        }
                    
                }
            }
        } 
    }
    
    /**********************************************************************************************
    @author        Echo: Vivek Sethi   AT-1908
    @date          23-March-2018
    @param         List<SObject> newlist
    @return        void
    @description   This method is used to prevent the creation of duplicate default Available Bundles
    **********************************************************************************************/ 
    public void checkDefaultAvailableBundle(List<SObject> newlist)
    {
        Set<Id> bundleIds = new set<Id>();
        Map<Id,Boolean> serviceIdMap = new Map<Id,Boolean> ();
        if(!newlist.isEmpty())
        {
            for(AvailableBundle__c objAvailableBundle : (List<AvailableBundle__c>)newlist){
                if(objAvailableBundle.Default__c){   /*On Creating Default Available Bundle*/
                    bundleIds.add(objAvailableBundle.Id);
                    if(!serviceIdMap.containsKey(objAvailableBundle.AvailableService__c))
                    {
                        serviceIdMap.put(objAvailableBundle.AvailableService__c,TRUE);
                    }
                }
            }
            
            if(serviceIdMap.keySet().size() > 0 && bundleIds.size() > 0){
                for(AvailableBundle__c objAvailableBundle1 : [SELECT Id,
                                                              AvailableService__c,
                                                              Bundle__c,
                                                              Default__c
                                                              FROM AvailableBundle__c 
                                                              WHERE AvailableService__c IN :serviceIdMap.keySet()
                                                              AND Id NOT IN : bundleIds])       /*Iterate through the other Available Bundles of similar AvailableService */                  
                {
                    if(objAvailableBundle1.Default__c)   /*If Default Available Bundle Already exists  then through an error*/
                    {
                        for(AvailableBundle__c objAvailableBundle2 : (List<AvailableBundle__c>)newlist)   /*Fetched newlist to add an Error*/
                        {
                            if(serviceIdMap.get(objAvailableBundle1.AvailableService__c))
                                objAvailableBundle2.addError(System.Label.GlUt_DefaultBundleDuplicateMessage);                           
                        } 
                    }
                }  
            }
        }
    }
    /**********************************************************************************************
    @author        Echo: Dependra Singh
    @date          13-Aug-2018
    @param         List<SObject> newlist
    @return        void
    @description   This method is used to prevent Only one Tariff Limit Bundle can be made available for each Available Service’ and do not commit the change. 
    **********************************************************************************************/ 
    
    public void checkForOnlyOneTariffBundle(List<SObject> newlist, map<Id, SObject> oldMap){
        Set<Id> bundleIds = new set<Id>();
        Set<Id> availableServiceIds = new set<Id>();
        Map<Id, Id> mapBundleIdByAvailableServiceId = new Map<Id, Id>();
        Map<Id,Bundle__c> mapBundleById;
        List<AvailableBundle__c> availableBundleList = new List<AvailableBundle__c>();
        if(!newlist.isEmpty()) {
            for(AvailableBundle__c objAvailableBundle : (List<AvailableBundle__c>)newlist){
                bundleIds.add(objAvailableBundle.Bundle__c);
            }
        }
        if(bundleIds.size() > 0){
            mapBundleById = new Map<Id, Bundle__c>([SELECT Id, TariffLimit__c FROM Bundle__c WHERE Id IN : bundleIds]);
            if(mapBundleById.keyset().size() > 0){
                for(AvailableBundle__c objAvailableBundle1 : (List<AvailableBundle__c>)newlist){
                    if(mapBundleById.containsKey(objAvailableBundle1.Bundle__c) && mapBundleById.get(objAvailableBundle1.Bundle__c).TariffLimit__c) {
                        availableServiceIds.add(objAvailableBundle1.AvailableService__c);
                    }
                }
            }
        }
        if(availableServiceIds.size() > 0){
            availableBundleList =[SELECT Id, AvailableService__c,Bundle__c, Bundle__r.TariffLimit__c FROM AvailableBundle__c WHERE AvailableService__c IN : availableServiceIds  AND Bundle__r.TariffLimit__c = true];
            if(availableBundleList.size() > 0){
                for(AvailableBundle__c objAvailableBundle2 :availableBundleList){
                    if(!mapBundleIdByAvailableServiceId.containsKey(objAvailableBundle2.AvailableService__c)){
                        mapBundleIdByAvailableServiceId.put(objAvailableBundle2.AvailableService__c, objAvailableBundle2.Bundle__c);
                    }
                }
            }
        }
        for(AvailableBundle__c objAvailableBundle3 : (List<AvailableBundle__c>)newlist){
            if(oldMap!= null  && oldMap.keySet().size() > 0){
                if(objAvailableBundle3.Bundle__c != ((AvailableBundle__c) oldMap.get(objAvailableBundle3.Id)).Bundle__c) {
                    if(!((AvailableBundle__c) oldMap.get(objAvailableBundle3.Id)).TariffLimit__c && mapBundleById.get(objAvailableBundle3.Bundle__c).TariffLimit__c){
                        if(mapBundleIdByAvailableServiceId.containsKey(objAvailableBundle3.AvailableService__c)){
                            objAvailableBundle3.addError(System.Label.GlUt_OnlyOneTariffLimitBundleAllowed);
                        }
                    }
                }
            }else{
                if(mapBundleIdByAvailableServiceId.containsKey(objAvailableBundle3.AvailableService__c)){
                    objAvailableBundle3.addError(System.Label.GlUt_OnlyOneTariffLimitBundleAllowed);
                } 
            }
        }
    }
}