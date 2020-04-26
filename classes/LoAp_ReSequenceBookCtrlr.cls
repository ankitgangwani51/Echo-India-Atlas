/******************************************************************************
@author         Echo: Neha R.
@date           09 May 2018
@description    Component controller for Re-Sequence Book lightning component
@revesion		Update By Dependra Singh - Security review changes- 17-09-2018(AT-3687)
*******************************************************************************/
public with sharing class LoAp_ReSequenceBookCtrlr {
    
    private static final String CLASS_NAME = 'LoAp_ReSequenceBookCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static List<String> supplyPointFields;    
    static{
        supplyPointFields = new List<String>();         
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.WALKORDERAPINAME);
    }
    
    /**********************************************************************************************
    @author         Echo: Neha R.
    @date           09 May 2018
    @return         Integer
    @params			Id bookRecordId, Integer sequenceSpacing
    @description    This method returns Walkorder of supply point associated to bookId
    @revesion		Update By Dependra Singh - Security review changes- 17-09-2018
    **********************************************************************************************/
    @AuraEnabled
    public static Integer reSequenceWalkOrder(Id bookRecordId, Integer sequenceSpacing) {    
        Integer updatedRecords = 0;
        try {  
            List<SupplyPoint__c> spNewWalkOrderList = new List<SupplyPoint__c>();
            Integer newWalkOrderSequence = 0;
            //If Book record id is not null
            if (bookRecordId != null){
                String soqlQuery =''; 
                // Create query to get the supply point record based on book id. AT-3687          
                soqlQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,' + String.join(supplyPointFields,','), 
                    GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME + 
                    ' WHERE ' + GlUt_APIConstantsBook.BOOKAPINAME + ' =\'' + bookRecordId  + '\''  +
                    ' ORDER BY ' + GlUt_APIConstantsSupplyPoint.WALKORDERAPINAME });
                system.debug(DEBUG + ' soqlQuery : '+soqlQuery);
                // get all the supply point records 
                List<SupplyPoint__c> supplyPointList = Database.query(soqlQuery);  
                //Check if supplyPointList is not null or empty
                if(supplyPointList != null && !supplyPointList.isEmpty()){
                    for(SupplyPoint__c objSupplyPoint : supplyPointList){             
                        newWalkOrderSequence = newWalkOrderSequence + sequenceSpacing;             
                        objSupplyPoint.WalkOrder__c = newWalkOrderSequence;                       
                        spNewWalkOrderList.add(objSupplyPoint);
                    }        
                }	
                //Check if supplyPointList is not null or empty
                if (spNewWalkOrderList.size() > 0){ 
                    List<SupplyPoint__c> supplyPointUpdateList = (List<SupplyPoint__c>) GlUt_FieldSecurity.cleanseFields(spNewWalkOrderList, false);// 	Cleanse before DML-AT-3687		
                    if(supplyPointUpdateList != null && !supplyPointUpdateList.isEmpty()){
                        update supplyPointUpdateList; // Update walk order on SupplyPoint 
                        updatedRecords = supplyPointUpdateList.size();
                    }
                }
            }
        } catch (exception e) { 
            GlUt_Logger.logException(e);  
            throw new AuraHandledException(e.getMessage());			
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }            
        return updatedRecords;
    }
    
}