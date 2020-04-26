/************************************************************************************************************
@author         Accenture : Satish Nair
@date           01-Nov-2017
@description:   This is handler class for RateTrigger
Revision(s):    Echo: Ankit Gangwani, 
                Modify the logic for checkValidation method from Main/Sub Device to Main/Sub Supply Point
                26 June 2018
**************************************************************************************************************/
public with sharing class GlUt_SupplyPointRelationshipHandler extends GlUt_TriggerHandlerBase{

    //Variable Declaration
    private static final String CLASS_NAME = 'GlUt_SupplyPointRelationshipHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
     //End Variable Declaration

    /**********************************************************************************************
    @author         Accenture: Vivek Chauhan
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
                    checkValidation(inputParam.newlist); 
                }
                if( inputParam.isInsert && inputParam.isAfter ){
                     
                }
                if( inputParam.isUpdate && inputParam.isBefore ){
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
            //update inputParam.newlist;
    }
    
    /**********************************************************************************************
    @author         Accenture: Vivek Chauhan
    @date           03-Dec-2017
    @param          GlUt_TriggerHandlerObj inputParam
    @return         void
    @description        This method overides the InProgressEntry in the base class. This is 
                    only necessary where special handling is required in the event that a trigger
                    causes another trigger to fire.
    **********************************************************************************************/
	public override void  InProgressEntry(GlUt_TriggerHandlerObj inputParam){        
        
        if(inputParam.TriggerObject == GlUt_Constants.OBJSUPPLYPOINTRELATIONSHIP){
                //Supress recursion                
        }
        //Otherwise invoke the default version of the tigger
        else{
                system.debug('Running standard trigger');
                super.InProgressEntry(inputParam);
        }             
	}
	
    /**********************************************************************************************
    @author        Echo: Ankit Gangwani
    @date          26 June 2018
    @param         List<SupplyPointRelationship__c> newSupplyPointRelationshipList
    @return        void
    @description   This utility method is used to check validation before creating supply point relationship realationship
    **********************************************************************************************/
    
    public void checkValidation(List<SupplyPointRelationship__c> newSupplyPointRelationshipList){
        
        Set<Id> supplyPointIdsSet = new Set<Id>();
        Map<String,SupplyPointRelationship__c> mapOfMainSub2SPR = new Map<String,SupplyPointRelationship__c>();
        
        for(SupplyPointRelationship__c objSupplyPointRelationship :newSupplyPointRelationshipList){
            if(objSupplyPointRelationship.MainSupply__c != null)
                supplyPointIdsSet.add(objSupplyPointRelationship.MainSupply__c);
            if(objSupplyPointRelationship.SubSupply__c != null)
                supplyPointIdsSet.add(objSupplyPointRelationship.SubSupply__c);            
        }
        
        List<SupplyPointRelationship__c> existingSPRel = [SELECT Id, MainSupply__c, SubSupply__c, StartDate__c, EndDate__c 
                                                          FROM SupplyPointRelationship__c
                                                          WHERE MainSupply__c = :supplyPointIdsSet
                                                          OR SubSupply__c = :supplyPointIdsSet];
        Boolean isValidateSecond = false;
        Map<Id,SupplyPointRelationship__c> mapOfMainId2SPR= new Map<Id,SupplyPointRelationship__c>();
        Set<Id> setOfSubSupplyIds = new Set<Id>();
            
        if(!existingSPRel.isEmpty()){
            for(SupplyPointRelationship__c objSPRel : existingSPRel ){                
                String combined = objSPRel.MainSupply__c + '-' + objSPRel.SubSupply__c;                
                if(!mapOfMainSub2SPR.containsKey(combined))
                    mapOfMainSub2SPR.put(combined, objSPRel);                
                combined = null;                
                if(!mapOfMainId2SPR.containsKey(objSPRel.MainSupply__c))
                    mapOfMainId2SPR.put(objSPRel.MainSupply__c, objSPRel);                
                setOfSubSupplyIds.add(objSPRel.SubSupply__c);
            }
        }
        for (SupplyPointRelationship__c objSupplyPointRelationship :newSupplyPointRelationshipList){
            isValidateSecond = false; 
            
            
            String combinedCheck = '';
            combinedCheck = objSupplyPointRelationship.MainSupply__c + '-' + objSupplyPointRelationship.SubSupply__c;
            
            if(mapOfMainSub2SPR.containsKey(combinedCheck)){
                if(mapOfMainSub2SPR.get(combinedCheck).StartDate__c <= objSupplyPointRelationship.StartDate__c && 
                   mapOfMainSub2SPR.get(combinedCheck).EndDate__c == null){
                       objSupplyPointRelationship.addError(Label.GlUt_SupplyPointRelationship_Error_1);  
                       isValidateSecond = true;                       
                   }                
                else if(mapOfMainSub2SPR.get(combinedCheck).StartDate__c <= objSupplyPointRelationship.StartDate__c && 
                        (objSupplyPointRelationship.EndDate__c == null ||
                         mapOfMainSub2SPR.get(combinedCheck).EndDate__c > objSupplyPointRelationship.EndDate__c ||
                         objSupplyPointRelationship.StartDate__c <= mapOfMainSub2SPR.get(combinedCheck).EndDate__c)){
                             objSupplyPointRelationship.addError(Label.GlUt_SupplyPointRelationship_Error_1);
                             isValidateSecond = true;
                         }
            }
            
            if(!isValidateSecond){
                if(setOfSubSupplyIds.contains(objSupplyPointRelationship.MainSupply__c) && mapOfMainId2SPR.containsKey(objSupplyPointRelationship.SubSupply__c)){ 
                    objSupplyPointRelationship.addError(Label.GlUt_SupplyPointRelationship_Error_2);                     
                }           
            }
        }
    }
}