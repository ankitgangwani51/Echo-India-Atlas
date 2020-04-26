/************************************************************************************************************
@author         Echo: Amit K.
@date           20 Sep 2018
@description:   This is Utility class for Restricting Overlap Dates on any Object.
Revision(s):    
**************************************************************************************************************/
public with sharing class GlUt_RestrictDatesOverlapUtilities {
    /******************************************************************************
    @author         Echo: Amit K.
    @date           20 Sep 2018
    @param          Map<Integer,sObject> mapOfInsertingUniqueId2sObject,string parentobjectName, string exceptionReason
    @description    Self Set Record Overlap Logic
    *******************************************************************************/
    public static void SelfSetRecordCheckOverlapLogic(Map<Integer,sObject> mapOfInsertingUniqueId2sObject,string parentobjectName, string exceptionReason){
        //Compare the new list records themselfes except the same record in iteration and this can be check using custom unique Id
        for(Integer insertingId1: mapOfInsertingUniqueId2sObject.keySet()){
            sObject insertingSPB1 = mapOfInsertingUniqueId2sObject.get(insertingId1);
            for(Integer insertingId2 : mapOfInsertingUniqueId2sObject.keySet()){
                sObject insertingSPB2 = mapOfInsertingUniqueId2sObject.get(insertingId2);
                if(insertingId1 != insertingId2){ // Compare the custom unique Id so that same record can't be matched.
                    if(insertingSPB1.get(parentobjectName) != null && insertingSPB2.get(parentobjectName) !=null && insertingSPB1.get(parentobjectName) == insertingSPB2.get(parentobjectName)){
                        if(insertingSPB1.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME) !=null && insertingSPB1.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME) != null){
                            if(insertingSPB2.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME) != null && insertingSPB2.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME) != null){
                                if((Date.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) >= Date.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) && Date.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) <= Date.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)))
                                   || (Date.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) >= Date.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) && Date.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) <= Date.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME))) 
                                   || (Date.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) <= Date.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) && Date.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) >= Date.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)))){
                                       insertingSPB1.addError(exceptionReason); // Date Overlap Exception.
                                   }
                            }
                            else if(Date.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) != null && Date.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) == null){
                                if(Date.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) > Date.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) && Date.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) < Date.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME))){
                                    // By Pass Validation
                                }else{
                                    insertingSPB1.addError(exceptionReason); // Date Overlap Exception.
                                }
                            }
                        }
                        else if(Date.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) !=null && Date.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) == null){
                            if(Date.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) != null && Date.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) == null){
                                insertingSPB1.addError(exceptionReason); // Date Overlap Exception.
                            }
                            else if(Date.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) != null && Date.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) != null){
                                if(Date.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) <= Date.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME))){
                                    insertingSPB1.addError(exceptionReason); // Date Overlap Exception.
                                }
                            }
                        }
                    }
                }
            }
        }
    }
   /******************************************************************************
    @author         Echo: Amit K.
    @date           20 Sep 2018
    @param          Map<Id, SObject> oldMap, List<String> queryFields, String objectName,Set<Id> filterRecordIds,Set<Id> excludingRecordIds
    @description    get existing records based on fiter records Id.
    *******************************************************************************/
    public static List<Sobject> getExistingRecords(List<String> queryFields, String objectName,Set<Id> filterRecordIds,Set<Id> excludingRecordIds, string filterField) {
        string queryString = String.format('select {0} from {1}', new List<String>{String.join(queryFields, ', '),objectName});
        String filterStatement = ' WHERE '+ filterField +' IN: filterRecordIds';
        if(excludingRecordIds != null  && !excludingRecordIds.isEmpty())
            filterStatement = filterStatement +' AND Id NOT IN: excludingRecordIds';
        queryString = queryString + filterStatement;
        return Database.query(queryString);
    }
    /******************************************************************************
    @author         Echo: Amit K.
    @date           20 Sep 2018
    @param          sObject newRecord,List<sObject> existingRecords,string parentobjectName,string exceptionReason
    @description    Dates Overlap Logic based on start date and end dates
    *******************************************************************************/
    public static void OverlapLogic (sObject newRecord, Map<Id, List<sObject>> mapOfParentFieldId2ExistingSobjectRecords,string parentobjectName,string exceptionReason){
        if(newRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME) != null && newRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME) != null){
            for(sObject existingRecord: mapOfParentFieldId2ExistingSobjectRecords.get((Id)newRecord.get(parentobjectName))){
                if(existingRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)  != null && existingRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME) != null){
                    if((Date.valueOf(newRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) >= Date.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) && Date.valueOf(newRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) <= Date.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)))
                       || (Date.valueOf(newRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) >= Date.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) && Date.valueOf(newRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) <= Date.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)))
                       || (Date.valueOf(newRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) <= Date.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) && Date.valueOf(newRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) >= Date.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)))){
                           newRecord.addError(exceptionReason); // Date Overlap Exception.
                       }
                }
                else if(Date.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) != null && Date.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) == null){
                    if(Date.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) > Date.valueOf(newRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) && Date.valueOf(newRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) < Date.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME))){
                        // By Pass Validation
                    }else{
                        newRecord.addError(exceptionReason); // Date Overlap Exception.
                    }
                }
            }
        }
        else if(newRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME) != null && newRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME) == null){
            for(sObject existingRecord: mapOfParentFieldId2ExistingSobjectRecords.get((Id)newRecord.get(parentobjectName))){
                if(Date.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) != null && Date.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) != null){
                    if(Date.valueOf(newRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) <= Date.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME))){
                        newRecord.addError(exceptionReason); // Date Overlap Exception.
                    }
                } 
                else if(Date.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME))!= null && Date.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) == null){
                    newRecord.addError(exceptionReason); // Date Overlap Exception.
                }
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Neha R.
    @date           27 Feb 2019
    @param          sObject newRecord,List<sObject> existingRecords,string parentobjectName,string exceptionReason
    @description    Dates Overlap Logic based on start date and end dates AT-5293
    *******************************************************************************/
    public static void OverlapLogicForDateTime (sObject newRecord, Map<Id, List<sObject>> mapOfParentFieldId2ExistingSobjectRecords,string parentobjectName,string exceptionReason){
        if(newRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME) != null && newRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME) != null){
            for(sObject existingRecord: mapOfParentFieldId2ExistingSobjectRecords.get((Id)newRecord.get(parentobjectName))){
                if(existingRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)  != null && existingRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME) != null){
                    if((DateTime.valueOf(newRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) >= DateTime.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) && DateTime.valueOf(newRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) <= DateTime.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)))
                       || (DateTime.valueOf(newRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) >= DateTime.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) && DateTime.valueOf(newRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) <= DateTime.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)))
                       || (DateTime.valueOf(newRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) <= DateTime.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) && DateTime.valueOf(newRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) >= DateTime.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)))){
                           newRecord.addError(exceptionReason); // Date Overlap Exception.
                       }
                }
                else if(DateTime.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) != null && DateTime.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) == null){
                    if(DateTime.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) > DateTime.valueOf(newRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) && DateTime.valueOf(newRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) < DateTime.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME))){
                        // By Pass Validation
                    }else{
                        newRecord.addError(exceptionReason); // Date Overlap Exception.
                    }
                }
            }
        }
        else if(newRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME) != null && newRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME) == null){
            for(sObject existingRecord: mapOfParentFieldId2ExistingSobjectRecords.get((Id)newRecord.get(parentobjectName))){
                if(DateTime.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) != null && DateTime.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) != null){
                    if(DateTime.valueOf(newRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) <= DateTime.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME))){
                        newRecord.addError(exceptionReason); // Date Overlap Exception.
                    }
                } 
                else if(DateTime.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME))!= null && DateTime.valueOf(existingRecord.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) == null){
                    newRecord.addError(exceptionReason); // Date Overlap Exception.
                }
            }
        }           
    }
    
     /******************************************************************************
    @author         Echo: Neha R.
    @date           27 Feb 2019
    @param          Map<Integer,sObject> mapOfInsertingUniqueId2sObject,string parentobjectName, string exceptionReason
    @description    Self Set Record Overlap Logic AT-5293
    *******************************************************************************/
    public static void SelfSetRecordCheckOverlapLogicForDateTime(Map<Integer,sObject> mapOfInsertingUniqueId2sObject,string parentobjectName, string exceptionReason){
        //Compare the new list records themselfes except the same record in iteration and this can be check using custom unique Id
        for(Integer insertingId1: mapOfInsertingUniqueId2sObject.keySet()){
            sObject insertingSPB1 = mapOfInsertingUniqueId2sObject.get(insertingId1);
            for(Integer insertingId2 : mapOfInsertingUniqueId2sObject.keySet()){
                sObject insertingSPB2 = mapOfInsertingUniqueId2sObject.get(insertingId2);
                if(insertingId1 != insertingId2){ // Compare the custom unique Id so that same record can't be matched.
                    if(insertingSPB1.get(parentobjectName) != null && insertingSPB2.get(parentobjectName) !=null && insertingSPB1.get(parentobjectName) == insertingSPB2.get(parentobjectName)){
                        if(insertingSPB1.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME) !=null && insertingSPB1.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME) != null){
                            if(insertingSPB2.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME) != null && insertingSPB2.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME) != null){
                                if((DateTime.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) >= DateTime.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) && DateTime.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) <= DateTime.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)))
                                   || (DateTime.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) >= DateTime.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) && DateTime.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) <= DateTime.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME))) 
                                   || (DateTime.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) <= DateTime.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) && DateTime.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) >= DateTime.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)))){
                                       insertingSPB1.addError(exceptionReason); // Date Overlap Exception.
                                   }
                            }
                            else if(DateTime.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) != null && DateTime.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) == null){
                                if(DateTime.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) > DateTime.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) && DateTime.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) < DateTime.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME))){
                                    // By Pass Validation
                                }else{
                                    insertingSPB1.addError(exceptionReason); // Date Overlap Exception.
                                }
                            }
                        }
                        else if(DateTime.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) !=null && DateTime.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) == null){
                            if(DateTime.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) != null && DateTime.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) == null){
                                insertingSPB1.addError(exceptionReason); // Date Overlap Exception.
                            }
                            else if(DateTime.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) != null && DateTime.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME)) != null){
                                if(DateTime.valueOf(insertingSPB1.get(GlUt_APIConstantsTariffLimit.STARTDATEAPINAME)) <= DateTime.valueOf(insertingSPB2.get(GlUt_APIConstantsTariffLimit.ENDDATEAPINAME))){
                                    insertingSPB1.addError(exceptionReason); // Date Overlap Exception.
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
}