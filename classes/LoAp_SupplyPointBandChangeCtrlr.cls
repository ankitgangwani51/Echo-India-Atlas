/******************************************************************************
@author         Echo: Swati Mathur
@date           12 Jul 2018
@description    Component controller for Supply Point Band Change lightning component
@revesion 		Changes by Dependra Singh - Security Review - 14-09-2018
*******************************************************************************/
public with sharing class LoAp_SupplyPointBandChangeCtrlr {
    
    private static final String CLASS_NAME = 'LoAp_SupplyPointBandChangeCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static final List<String> SupplyPointBandFields = new List<String> {
        GlUt_APIConstantsSupplyPointBand.BANDTYPEAPINAME,
        GlUt_APIConstantsSupplyPointBand.BANDVALUEAPINAME,
        GlUt_APIConstantsSupplyPointBand.STARTDATEAPINAME,
        GlUt_APIConstantsSupplyPointBand.ENDDATEAPINAME
    }; 
        
        
    /**********************************************************************************************
    @author         Echo: Swati Mathur
    @date           12-Jul-2018
	@param 			
    @return         List<List<GLAp_FieldProps>>
    @description    This method returns the supply point band related fields as List
    **********************************************************************************************/
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrieveSupplyPointBandFields() {   

        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
            
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            List<GLAp_FieldProps> spbFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsSupplyPointBand.SUPPLYPOINTBANDAPINAME, SupplyPointBandFields);

            for (GLAp_FieldProps spbProp : spbFields) { 
                spbProp.showLabel = true;
                if(spbProp.fieldLabel == LoAp_Constants.ENDDATE){
                    spbProp.isEditable = true;
                }
                else{
                    spbProp.isEditable = false;
                }               
            }         

            for (Integer i = 0; i < spbFields.size(); i = i + 2) {
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                Integer secondEntryIndex = i + 1;
                lstEntry.add(spbFields[i]);
                if (secondEntryIndex < spbFields.size()) {
                    lstEntry.add(spbFields[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
            }
            return twoColFormattedList;
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }  
    }    
    
    /**********************************************************************************************
    @author         Echo: Swati Mathur
    @date           12-Jul-2018
	@param 			Id supplyPointId
    @return         List<List<GLAp_FieldProps>>
    @description    This method returns the supply point band related fields as List
    **********************************************************************************************/
    @AuraEnabled
    public static SupplyPointBand__c fetchSupplyPointBandData(Id supplyPointId){ 
        
        Datetime systemToday = System.today();
        String timeZone = UserInfo.getTimeZone().getID();
        String todate = systemToday.format('yyyy-MM-dd',timeZone); 
        
        Savepoint sp = Database.setSavepoint();        
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);  
            System.debug('supplyPointId--'+supplyPointId);
            String filterStatement  = 'WHERE ' + '(' + GlUt_APIConstantsSupplyPointBand.ENDDATEAPINAME + ' = null OR ' 
                + GlUt_APIConstantsSupplyPointBand.ENDDATEAPINAME + ' > ' + todate + ')' + ' AND '
                + GlUt_APIConstantsSupplyPointBand.SUPPLYPOINTAPINAME + ' = \''+ supplyPointId +'\' ' ;
            
            List<SupplyPointBand__c> lstSPBand = GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointBand.SUPPLYPOINTBANDAPINAME, 
                                                                                     SupplyPointBandFields,
                                                                                     filterStatement);
            
            System.debug('lstSPBand--'+lstSPBand);
            
            if(!lstSPBand.isEmpty()){
                return lstSPBand[0];
            }
            else{
                return null;        
            }
        }
        catch (exception e){            
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());            
        } finally { 
            GlUt_Logger.writeLogsToDatabase();
        }
        
    }
    
    /**********************************************************************************************
    @author         Echo: Swati Mathur
    @date           12-Jul-2018
	@param 			SupplyPointBand__c newSPBand, SupplyPointBand__c oldSPBand, Id supplyPointId
    @return         Id of SupplyPointBand__c
    @description    This method returns the supply point band related fields as List
    **********************************************************************************************/
    @AuraEnabled
    public static Id saveSupplyPointBandRecord(SupplyPointBand__c newSPBand, SupplyPointBand__c oldSPBand, Id supplyPointId){         
        
        Savepoint sp = Database.setSavepoint();        
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);  
            
            if(newSPBand != null && supplyPointId != null){                
                if(oldSPBand!= null){
                    if(oldSPBand.EndDate__c == null && newSPBand.StartDate__c > oldSPBand.StartDate__c){
                        oldSPBand.EndDate__c = newSPBand.StartDate__c - 1;
                    }
                    //update existing supply point band
                    //Changes by Dependra Singh - Security Review - 14-09-2018
                    SupplyPointBand__c objOldSupplyPointBand = (SupplyPointBand__c)GlUt_FieldSecurity.cleanseFields(oldSPBand, false);
                    if(objOldSupplyPointBand != null)
                        update objOldSupplyPointBand;                     
                }                                
                //insert the new supply point band
                newSPBand.SupplyPoint__c = supplyPointId;    
                //Changes by Dependra Singh - Security Review - 14-09-2018
                SupplyPointBand__c objSupplyPointBand = (SupplyPointBand__c)GlUt_FieldSecurity.cleanseFields(newSPBand, false);
                if(objSupplyPointBand != null)
                    insert objSupplyPointBand; 
                
                //return id of newly created supply point band 
                return objSupplyPointBand.Id;
            }
            else 
                return null;
        }
        catch (exception e){            
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            if(e.getMessage().contains(System.label.Glut_BandsOverlapException)){
                throw new AuraHandledException(System.label.Glut_BandsOverlapException); 
            }else if(e.getMessage().contains(System.label.GlUt_BandLimitException)){
                throw new AuraHandledException(System.label.GlUt_BandLimitException); 
            }else{
                throw new AuraHandledException(e.getMessage());            
            }
        } finally { 
            GlUt_Logger.writeLogsToDatabase();
        }
        
    }


}