/***************************************************************************************************
@author        Echo: Neha Rajput
@date          14 Dec 2018
@description:  This is helper class used by RuralMeasurement object trigger  
@group         TriggerHelper
Revision(s)   
*******************************************************************************************************/
public with sharing class GlUt_RuralMeasurementHandler extends GlUt_TriggerHandlerBase {
    
    // Variable declaration
    private static final String CLASS_NAME = 'GlUt_RuralMeasurementHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    // End variable declaration
    
    /**********************************************************************************************
    @author        Echo: Neha Rajput
    @date          14 Dec 2018
    @param         GlUt_TriggerHandlerObj inputParam
    @return        void
    @description   This method is used to invoke method from trigger
    **********************************************************************************************/
    public override void MainEntry(GlUt_TriggerHandlerObj inputParam) {
        try { 
            if (inputParam.isInsert && inputParam.isBefore){
                beforeInsertUpdate(inputParam.newlist);
            }
            if (inputParam.isInsert && inputParam.isAfter){
                afterInsert(inputParam.newlist);
            }
            if (inputParam.isUpdate && inputParam.isBefore){ 
                beforeInsertUpdate(inputParam.newlist);
            }
            if (inputParam.isUpdate && inputParam.isAfter){
            }
            if (inputParam.isDelete && inputParam.isBefore){                
            }
            if (inputParam.isDelete && inputParam.isAfter){                
            }
        } catch (Exception ex) {
            system.debug('Line Number:=' + ex.getLineNumber());
            system.debug('Line Number:=' + ex.getMessage());
            system.debug('Line Number:=' + ex.getStackTraceString());
            GlUt_Logger.logException(ex);

        } finally {
            //Reset the active function to null in case this class was first in stack
            //this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            GlUt_Logger.writeLogsToDatabase();
        }        
    }

    /**********************************************************************************************
    @author        Echo: Neha Rajput
    @date          14 Dec 2018
    @param         <List> newlist
    @return        void
    @description   This method is used to process RuralMeasurement
    **********************************************************************************************/
    private void beforeInsertUpdate(List<RuralMeasurement__c> newlist) {
                
        Set<Id> channelIdSet = new Set<Id>();		      
        Set<Id> supplypointIdSet = new Set<Id>();
        Map<Id,SupplyPoint__c> mapOfSupplyPointIdToRecord = new Map<Id,SupplyPoint__c>();
        List<RuralMeasurement__c> newRMNormalFinishTypelst = new List<RuralMeasurement__c>();
        Set<Decimal> newRuralMeasurementHeadSet = new Set<Decimal>(); 
        //Code to get field label by Field API Name
        String type = GlUt_APIConstantsRuralMeasurement.RURALMEASUREMENTAPINAME;        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keySet()) {                       
            fieldMap.get(fieldName).getDescribe().getLabel(); //It provides to get the object fields label.
        }
        // Validations ...
        for(RuralMeasurement__c newRuralMeasurement : newlist){
            //Date & Time check
            if(newRuralMeasurement.DateTime__c == null)
                newRuralMeasurement.addError(fieldMap.get(GlUt_APIConstantsRuralMeasurement.DATETIMEAPINAME) + ' ' + Label.LoAp_IsRequired);
            //Head check
            if(newRuralMeasurement.Head__c == null)
                newRuralMeasurement.addError(fieldMap.get(GlUt_APIConstantsRuralMeasurement.HEADAPINAME) + ' ' + Label.LoAp_IsRequired);
            //Type check
            if(newRuralMeasurement.Type__c == null)
                newRuralMeasurement.addError(fieldMap.get(GlUt_APIConstantsRuralMeasurement.TYPEAPINAME) + ' ' + Label.LoAp_IsRequired);
            //Channel check
            if(newRuralMeasurement.RuralChannel__c == null)
                newRuralMeasurement.addError(fieldMap.get(GlUt_APIConstantsRuralMeasurement.RURALCHANNELAPINAME) + ' ' + Label.LoAp_IsRequired);
            //Supply Point check
            if(newRuralMeasurement.SupplyPoint__c == null)
                newRuralMeasurement.addError(fieldMap.get(GlUt_APIConstantsRuralMeasurement.SUPPLYPOINTAPINAME) + ' ' + Label.LoAp_IsRequired);  
            
            // If the Type is ‘Start’, save the record without any further processing.......
            
            // If the Type is ‘Normal’ or ‘Finish’ further processing
            if(newRuralMeasurement.Type__c == GlUt_Constants.NORMAL || newRuralMeasurement.Type__c == GlUt_Constants.FINISH){
                channelIdSet.add(newRuralMeasurement.RuralChannel__c);
                supplypointIdSet.add(newRuralMeasurement.SupplyPoint__c);
                newRuralMeasurementHeadSet.add(newRuralMeasurement.Head__c); 
                newRMNormalFinishTypelst.add(newRuralMeasurement); 
            }
        }
        
        //AT-5603, Ankit, 26/04/2019
        if(supplypointIdSet.size() > 0){
            for(SupplyPoint__c objSP : [SELECT Id, RuralOutletType__c, RuralOutletSize__c FROM SupplyPoint__c WHERE Id IN: supplypointIdSet]){
                mapOfSupplyPointIdToRecord.put(objSP.Id,objSP);
            }
        }
        
        if(!channelIdSet.isEmpty() || !supplypointIdSet.isEmpty()){
            //  latest ‘Normal’ or ‘Start’ Rural Measurement associated with the Rural Channel and Supply Point,
            List<RuralMeasurement__c> lstPreviousRuralMeasurement = new List<RuralMeasurement__c>();                
            lstPreviousRuralMeasurement = [SELECT FlowPeriod__c,Head__c,RuralChannel__c,SupplyPoint__c,DateTime__c,RuralOrder__c 
                                           FROM RuralMeasurement__c
                                           WHERE ((Type__c =: GlUt_Constants.NORMAL OR Type__c =: GlUt_Constants.START) AND
                                                  RuralChannel__c IN: channelIdSet AND 
                                                  SupplyPoint__c IN: supplypointIdSet) ORDER BY DateTime__c DESC];
            
            // The Channel Flow Conversion record associated with the Channel  
            List<ChannelFlowConversion__c> lstChannelFlowConversion = new List<ChannelFlowConversion__c>();
            
            //AT-5603, Ankit, 26/04/2019
            lstChannelFlowConversion= [SELECT Channel__c,
                                       HeadReadingHigh__c,
                                       HeadReadingLow__c,
                                       RuralOutletType__c,
                                       RuralOutletSize__c
                                       FROM ChannelFlowConversion__c
                                       WHERE Channel__c IN: channelIdSet];
            
            Set<Id> updateCFCField = new Set<Id>(); // set of ChannelFlowConversion Id's            
            
            // newRMNormalFinishTypelst List of  RuralMeasurement__c where Type is ‘Normal’ or ‘Finish’
            for(RuralMeasurement__c newRuralMeasurement :newRMNormalFinishTypelst){                    
                
                //Find the latest ‘Normal’ or ‘Start’ Rural Measurement associated with the same Rural Channel and Supply Point, prior to the Date & Time of the newRuralMeasurement 
                for(RuralMeasurement__c previousRuralMeasurement : lstPreviousRuralMeasurement){                	
                    // existing latest ‘Normal’ or ‘Start’ Rural Measurement associated record 
                    // with the same Rural Channel and Supply Point and prior to the Date & Time of the new RuralMeasurement
                    if(newRuralMeasurement.RuralChannel__c == previousRuralMeasurement.RuralChannel__c &&
                       newRuralMeasurement.SupplyPoint__c == previousRuralMeasurement.SupplyPoint__c &&
                       newRuralMeasurement.DateTime__c > previousRuralMeasurement.DateTime__c  && //newRuralMeasurement.RuralOrder__c == previousRuralMeasurement.RuralOrder__c &&
                       ((newRuralMeasurement.Id != null && newRuralMeasurement.Id != previousRuralMeasurement.Id) || newRuralMeasurement.Id == null)){
                           
                           // Calculate the Flow Period in hours from last the reading date/time to the new reading date/time
                           // newRuralMeasurement Date & Time – previous Measurement Date & Time   
                           Decimal timePeriod = ((newRuralMeasurement.DateTime__c).getTime() - (previousRuralMeasurement.DateTime__c).getTime());    // AT-5220   
                           Decimal inSeconds = timePeriod.divide(1000,2);                           
                           Decimal inMinutes = inSeconds.divide(60,2);                  // AT-5220   
                           Decimal inHour = inMinutes.divide(60,2);                     // AT-5220   
                           newRuralMeasurement.FlowPeriod__c = inHour.setScale(2);      // AT-5220  
                           
                           // Calculate the Average Head as newRuralMeasurement Head Reading + previous Measurement Head Reading / 2
                           newRuralMeasurement.AverageHead__c = (newRuralMeasurement.Head__c + previousRuralMeasurement.Head__c)/2 ;      // AT-5163                         
                           break;
                    }
                }
                
                Boolean isChannelFlowConversionExist = false;
                for(ChannelFlowConversion__c objChannelFlowConversion :lstChannelFlowConversion){
                    //the Channel Flow Conversion record associated with the Channel where Average Head Reading = 
                    // newRuralMeasurement Head and the Channel matches the newRuralMeasurement Channel.

                    //AT-5603, Ankit, 26/04/2019
                    if(newRuralMeasurement.RuralChannel__c == objChannelFlowConversion.Channel__c &&
                       objChannelFlowConversion.HeadReadingHigh__c >= newRuralMeasurement.AverageHead__c && 
                       objChannelFlowConversion.HeadReadingLow__c <= newRuralMeasurement.AverageHead__c &&
                       objChannelFlowConversion.RuralOutletType__c == mapOfSupplyPointIdToRecord.get(newRuralMeasurement.SupplyPoint__c).RuralOutletType__c && 
                       objChannelFlowConversion.RuralOutletSize__c == mapOfSupplyPointIdToRecord.get(newRuralMeasurement.SupplyPoint__c).RuralOutletSize__c){
                           //Update the newRuralMeasurement lookup with the retrieved Channel Flow Conversion record 
                           newRuralMeasurement.ChannelFlowConversion__c = objChannelFlowConversion.Id; 
                           isChannelFlowConversionExist = true;
                           break;
                       }
                }
                //If a Channel Flow Conversion record isn’t found return the Error ‘No Channel Flow Conversion Record found for Head Value 
                if(!isChannelFlowConversionExist)
                    newRuralMeasurement.addError(Label.LoAp_NoChannelFlowConversion);                    
            }              
        }        
    }
    
    /**********************************************************************************************
    @author        Echo: Neha Rajput
    @date          14 Dec 2018
    @param         <List> newlist
    @return        void
    @description   This method is used to process RuralMeasurement
    **********************************************************************************************/
    private void afterInsert(List<RuralMeasurement__c> newlist) {
        List<Id> ruarlOrderIdLst = new List<Id>();
        Set<Id> channelIdSet = new Set<Id>();		      
        Set<Id> supplypointIdSet = new Set<Id>();
        Set<Id> lowheadSupplypointIdSet = new Set<Id>();
        
        List<RuralMeasurement__c> newRMNormalFinishTypelst = new List<RuralMeasurement__c>();
        for(RuralMeasurement__c objRuralMeasurement : newlist){            
            //If the Type is ‘Normal’ or ‘Finish’ further processing
            if(objRuralMeasurement.Type__c == GlUt_Constants.NORMAL || objRuralMeasurement.Type__c == GlUt_Constants.FINISH){
                
                // the Rural Order record associated with the Rural Measurement Record
                if(objRuralMeasurement.RuralOrder__c != null){
                    ruarlOrderIdLst.add(objRuralMeasurement.RuralOrder__c);                        
                }
                if(!objRuralMeasurement.LowHead__c){                  
                    lowheadSupplypointIdSet.add(objRuralMeasurement.SupplyPoint__c);
                    newRMNormalFinishTypelst.add(objRuralMeasurement);  
                }
				channelIdSet.add(objRuralMeasurement.RuralChannel__c);
				supplypointIdSet.add(objRuralMeasurement.SupplyPoint__c);                
            }
        }  
        
        //Rural Order record
        List<RuralOrder__c> lstRuralOrder = new List<RuralOrder__c>();
        if(!ruarlOrderIdLst.isEmpty())
            lstRuralOrder =[SELECT Id,BillableVolume__c,LowHeadVolume__c
                            FROM RuralOrder__c
                            WHERE Id IN: ruarlOrderIdLst];
        
        List<RuralMeasurement__c> previousRuralMeasurement = new List<RuralMeasurement__c>();
        Map<Id,Id> mapSPwithRuralLicense = new Map<Id,Id>();
        Map<Id,Id> mapSPwithRuralEntitlement = new Map<Id,Id>();
        
        if(!channelIdSet.isEmpty() || !supplypointIdSet.isEmpty()){
            //Previous Rural Measurement record
            previousRuralMeasurement = [SELECT FlowPeriod__c,Head__c,RuralChannel__c,SupplyPoint__c,DateTime__c,RuralGrossConsumption__c,Type__c 
                                        FROM RuralMeasurement__c
                                        WHERE ((Type__c =: GlUt_Constants.NORMAL OR Type__c =: GlUt_Constants.START) AND
                                               RuralChannel__c IN: channelIdSet AND 
                                               SupplyPoint__c IN: supplypointIdSet) ORDER BY DateTime__c DESC];
            
            //the Entitlement associated with newRuralMeasurement via Supply Point->Location->Rural License->Rural Entitlment where Active = True.  
            for(SupplyPoint__c objSP: [SELECT Location__r.RuralLicense__c
                                       FROM SupplyPoint__c
                                       WHERE Id IN: lowheadSupplypointIdSet]){
                if(objSP.Location__r.RuralLicense__c != null)
                    mapSPwithRuralLicense.put(objSP.Id,objSP.Location__r.RuralLicense__c); 
            } 
            if(!mapSPwithRuralLicense.isEmpty()){
                Set<Id> licenceIdSet = new Set<Id>();
                licenceIdSet.addAll(mapSPwithRuralLicense.values()); 
                for(RuralEntitlement__c objRuralEntitlement: GlUt_RuralBillingUtilities.getActiveRuralEntitlement(licenceIdSet)){
                    for(Id spId: mapSPwithRuralLicense.keySet() ){
                        if(mapSPwithRuralLicense.get(spId) == objRuralEntitlement.RuralLicense__c){
                            mapSPwithRuralEntitlement.put(spId,objRuralEntitlement.Id);
                            //  break;     AT-5293                   
                        }
                    }
                }
            }
        }
          
        List<RuralOrder__c> updatesRuralOrderlst = new List<RuralOrder__c>();
        List<RuralGrossConsumption__c> updateRuralGrossConsumptionlst = new List<RuralGrossConsumption__c>();
        List<ChannelOpen__c> updateChannelOpenlst = new List<ChannelOpen__c>();
        Map<Id,RuralMeasurement__c> newtoPrevRuralMeasurementIdMap = new Map<Id,RuralMeasurement__c>();

        for(RuralMeasurement__c newRuralMeasurement : newlist){
        	//If the Type is ‘Normal’ or ‘Finish’ further processing
            if(newRuralMeasurement.Type__c == GlUt_Constants.NORMAL || newRuralMeasurement.Type__c == GlUt_Constants.FINISH){               
                
                // the Rural Order record associated with the Rural Measurement Record
                if(newRuralMeasurement.RuralOrder__c != null){
                    // Rural Measurement is not flagged as Low Head 
                    for(RuralOrder__c objRuralOrder : lstRuralOrder){ 
                        if(newRuralMeasurement.RuralOrder__c == objRuralOrder.Id){
                            //If Rural Measurement is flagged as Low Head 
                            if(newRuralMeasurement.LowHead__c){
                                //Update the Rural Order Low Head Volume field = Low Head Volume + Rural Measurement Volume.                               
                                objRuralOrder.LowHeadVolume__c = (objRuralOrder.LowHeadVolume__c == null ? 0: objRuralOrder.LowHeadVolume__c) + (newRuralMeasurement.Volume__c == null ? 0:newRuralMeasurement.Volume__c);  // AT-5184
                            }else{ // Rural Measurement is not flagged as Low Head
                                //Update the Rural Order Billable Volume field = Billable Volume + Rural Measurement Volume
                                objRuralOrder.BillableVolume__c = (objRuralOrder.BillableVolume__c == null ? 0: objRuralOrder.BillableVolume__c) + (newRuralMeasurement.Volume__c== null ? 0:newRuralMeasurement.Volume__c);  //  AT-5184                         
                            } 
                            if(newRuralMeasurement.Type__c == GlUt_Constants.FINISH)
                                objRuralOrder.Status__c = GlUt_Constants.COMPLETE; //Update the Rural Order Status to ‘Complete
                            
                            updatesRuralOrderlst.add(objRuralOrder); 
                            break;
                        }
                    }                    
                }
                //Rural Measurement is not flagged as Low Head 
                if(!newRuralMeasurement.LowHead__c){
                    // existing latest ‘Normal’ or ‘Start’ Rural Measurement associated record 
                    // with the same Rural Channel and Supply Point and prior to the Date & Time of the new RuralMeasurement
                    for(RuralMeasurement__c objPreviousRM : previousRuralMeasurement){
                        if(newRuralMeasurement.RuralChannel__c == objPreviousRM.RuralChannel__c &&
                           newRuralMeasurement.SupplyPoint__c == objPreviousRM.SupplyPoint__c &&
                           newRuralMeasurement.DateTime__c > objPreviousRM.DateTime__c &&
                           (newRuralMeasurement.Id != null && newRuralMeasurement.Id != objPreviousRM.Id)){
                               
                               RuralGrossConsumption__c objRuralGrossConsumption = new RuralGrossConsumption__c();
                               //Date of the previousRuralMeasurement + 1
                               objRuralGrossConsumption.StartDate__c = objPreviousRM.DateTime__c.addSeconds(1);                              
                               objRuralGrossConsumption.EndDate__c = newRuralMeasurement.DateTime__c;
                               objRuralGrossConsumption.Consumption__c = newRuralMeasurement.Volume__c;
                               objRuralGrossConsumption.Type__c = GlUt_Constants.HEAD;
                               objRuralGrossConsumption.SupplyPoint__c = newRuralMeasurement.SupplyPoint__c;
                               objRuralGrossConsumption.RuralMeasurement__c = newRuralMeasurement.Id; 
                               if(newRuralMeasurement.SupplyPoint__c != null && mapSPwithRuralEntitlement.containsKey(newRuralMeasurement.SupplyPoint__c))
                               		objRuralGrossConsumption.RuralEntitlement__c = mapSPwithRuralEntitlement.get(newRuralMeasurement.SupplyPoint__c) ;
                               updateRuralGrossConsumptionlst.add(objRuralGrossConsumption);
                               newtoPrevRuralMeasurementIdMap.put(newRuralMeasurement.Id,objPreviousRM);                               
                               break;
                        }
                    }                
                }
                // If the Type is ‘Finish’ create open channel record
                if(newRuralMeasurement.Type__c == GlUt_Constants.FINISH){
                    ChannelOpen__c objChannelOpen = new ChannelOpen__c();
                    // update start date
                    for(RuralMeasurement__c objPreviousRM : previousRuralMeasurement){
                        if(newRuralMeasurement.RuralChannel__c == objPreviousRM.RuralChannel__c &&
                           newRuralMeasurement.SupplyPoint__c == objPreviousRM.SupplyPoint__c &&
                           newRuralMeasurement.DateTime__c > objPreviousRM.DateTime__c &&
                           (newRuralMeasurement.Id != null && newRuralMeasurement.Id != objPreviousRM.Id) &&
                            objPreviousRM.Type__c == GlUt_Constants.START){                              
                              objChannelOpen.StartDate__c = objPreviousRM.DateTime__c;                              
                              break;
                        }
                    }
                    
                    objChannelOpen.RuralChannel__c = newRuralMeasurement.RuralChannel__c;                 
                    objChannelOpen.EndDate__c = newRuralMeasurement.DateTime__c;
                    
                    updateChannelOpenlst.add(objChannelOpen);
                } 
            }
    	}
        
        // update rural Order record
        if(!updatesRuralOrderlst.isEmpty()){
            database.update(updatesRuralOrderlst);
        }
        
        if(!updateRuralGrossConsumptionlst.isEmpty()){             
            database.insert(updateRuralGrossConsumptionlst);
       
            //Update Rural Measurement records  to the Rural Gross Consumption record
            List<RuralMeasurement__c> updatedPreviousRMRecords = new List<RuralMeasurement__c>(); 
            Map<Id,RuralMeasurement__c> updatedNewRMRecordsMap = new Map<Id,RuralMeasurement__c>(); 
            
            if(!newtoPrevRuralMeasurementIdMap.isEmpty()){                
                for(RuralMeasurement__c objRM: [SELECT Id,RuralGrossConsumption__c
                                                FROM RuralMeasurement__c
                                                WHERE Id IN: newtoPrevRuralMeasurementIdMap.keySet()]){
                    updatedNewRMRecordsMap.put(objRM.Id,objRM);
                }
            }
            
            for(RuralGrossConsumption__c objRGM: updateRuralGrossConsumptionlst){                
                // update prev record gross cons.
                if(newtoPrevRuralMeasurementIdMap.containsKey(objRGM.RuralMeasurement__c)){
                    RuralMeasurement__c prevRM = newtoPrevRuralMeasurementIdMap.get(objRGM.RuralMeasurement__c);
                    prevRM.RuralGrossConsumption__c = objRGM.Id;
                    updatedPreviousRMRecords.add(prevRM);
                    //new record..
                    if(updatedNewRMRecordsMap.containsKey(objRGM.RuralMeasurement__c)){
                        RuralMeasurement__c newRM = updatedNewRMRecordsMap.get(objRGM.RuralMeasurement__c);
                        newRM.RuralGrossConsumption__c = objRGM.Id;
                        updatedPreviousRMRecords.add(newRM);
                    }                                          
                }               
            }
            if(!updatedPreviousRMRecords.isEmpty())
                database.update(updatedPreviousRMRecords);
        } 
        if(!updateChannelOpenlst.isEmpty()) 
            database.insert(updateChannelOpenlst);
    
    }
   
}