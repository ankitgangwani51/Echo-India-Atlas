/******************************************************************************
@author         Neha R. 
@date           15 Jan 2019
@description    An apex controller for Suspended Service Item Lightning Component    
@revision       
*******************************************************************************/
public with sharing class CuAp_SuspendServiceItemCtrlr {
    
    private static final String CLASS_NAME = 'CuAp_SuspendServiceItemCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    private static final List<String> serviceItemFields = new List<string>{
                                                          GlUt_APIConstantsServiceItem.SERVICEITEMNOAPINAME, 
                                                          GlUt_APIConstantsServiceItem.SERVICEITEMTYPEAPINAME,                                                          
                                                          GlUt_APIConstantsServiceItem.STARTDATEAPINAME, 
                                                          GlUt_APIConstantsServiceItem.ENDDATE,
                                                          GlUt_APIConstantsServiceItem.SUSPENDENDDATEAPINAME
                                                          }; 
                                                                  
    /******************************************************************************
    @author         Neha R. 
    @date           15 Jan 2019	
    @description    Wrapper class         
    *******************************************************************************/                                                              
    public class SuspendSIContainerWrapper {  
        @AuraEnabled 
        public ServiceItem__c objServiceItem;
        @AuraEnabled 
        public List<List<GlAp_FieldProps>> siFieldPropList;
        
        public SuspendSIContainerWrapper(){            
            this.siFieldPropList = new List<List<GlAp_FieldProps>>();
            this.objServiceItem = new ServiceItem__c();
        }
    }                                                         
                                                              
    /******************************************************************************
    @author         Neha R. 
    @date           15 Jan 2019
	@parameters 	String sObjectName, Id recordId
    @return         Wrapper class Object
    @description    Method to retrive field property and details of service item 
					by recordId
    *******************************************************************************/
    @AuraEnabled
    public static CuAp_SuspendServiceItemCtrlr.SuspendSIContainerWrapper retrieveServiceItemDetails(String sObjectName, Id recordId) {
        CuAp_SuspendServiceItemCtrlr.SuspendSIContainerWrapper wrapperObj = new CuAp_SuspendServiceItemCtrlr.SuspendSIContainerWrapper();       
        try {            
            if(sObjectName == GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME){                  
                wrapperObj.siFieldPropList = retrieveSIFieldsDetails();
                wrapperObj.objServiceItem  = retrieveSIRecordDetails(recordId, serviceItemFields);            
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }        
        return wrapperObj;  
    }

    /******************************************************************************
    @author         Neha R. 
    @date           
	@parameters 	String sObjectName
    @return         List<GLAp_FieldProps>
    @description    
    *******************************************************************************/
    @AuraEnabled
    public static String saveServiceItemRecord(Id recordId, String suspendedStartDateString, String suspendedEndDateString) {                
        try {  
            Date suspendedStartDate = date.valueOf(suspendedStartDateString);
            Date suspendedEndDate = date.valueOf(suspendedEndDateString);
            
            //check bill item exist which overlaps the period between Suspend Start Date and Suspend End Date. 
            List<BillItem__c> billItemList = new List<BillItem__c>();
            billItemList = [SELECT Id
                            FROM BillItem__c
                            WHERE ServiceItem__c =: recordId
                            AND StartDate__c >= :suspendedStartDate
                            AND (EndDate__c >= :suspendedEndDate OR EndDate__c = null )];
           
            // if BillItem exist
            if(!billItemList.isEmpty())
                return Label.CuAp_BillExistInSuspensionPeriod; //Bills exist between the Suspension period. This requires an amendment
            else{
                // Modify Service Item 
                List<ServiceItem__c> serviceItemList = new List<ServiceItem__c>();               
                for(ServiceItem__c objServiceItem: [SELECT Id,SuspendEndDate__c,EndDateResume__c,EndDate__c 
                                                    FROM ServiceItem__c
                                                    WHERE Id =: recordId]){
                     objServiceItem.EndDateResume__c = objServiceItem.EndDate__c;
                     objServiceItem.EndDate__c = suspendedStartDate;                                  
                     objServiceItem.SuspendEndDate__c = suspendedEndDate;
                     serviceItemList.add(objServiceItem);                                   
                }                
                serviceItemList = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(serviceItemList, false);
                update serviceItemList;            
            }
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            return e.getMessage();
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return Label.GlAp_Success;   //'Success';  
    }
    
    /******************************************************************************
    @author         Neha R.   
    @date           15 Jan 2019
    @return         List<List<GlAp_FieldProps>>
    @description    This method returns the field properties for each of the fields that are
    to be displayed on the screen
    *******************************************************************************/
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrieveSIFieldsDetails() {
        List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
        try {
            List<GLAp_FieldProps> siFieldProps = new List<GLAp_FieldProps>();
            siFieldProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME, serviceItemFields);
            
            // Create a transfieldprop 
            GLAp_FieldProps transFieldProp = new GLAp_FieldProps();
            transFieldProp.isFLSVisible    = true;
            transFieldProp.isEncrypted     = false;
            transFieldProp.isEditable      = true;
            transFieldProp.isRequired      = false;
            transFieldProp.fieldName       = Label.CuAp_SuspendStartDate;
            transFieldProp.fieldLabel      = Label.CuAp_SuspendStartDate;
            transFieldProp.fieldType       = 'date' ; //CuAp_Constants.DATEFIELDTYPE;
            transFieldProp.transformField  = true;
            transFieldProp.parentObject    = GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME;          
            
            for(integer i=0; i < siFieldProps.size(); i = i + 2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i + 1; 
                boolean skipSecondEntryIndex = false;  // variable to add transField
                
                if(siFieldProps[i].fieldName == GlUt_APIConstantsServiceItem.SUSPENDENDDATEAPINAME){                    
                    siFieldProps[i].isEditable = true;
                    lstEntry.add(transFieldProp); //add transfield..
                    lstEntry.add(siFieldProps[i]);                 
                    skipSecondEntryIndex = true;  //skip second list entry
                    i = i - 1;
                }
                else{
                    siFieldProps[i].isEditable = false;                
                	lstEntry.add(siFieldProps[i]); 
                }
                
                if(secondEntryIndex < siFieldProps.size() && !skipSecondEntryIndex){  
                    if(siFieldProps[secondEntryIndex].fieldName == GlUt_APIConstantsServiceItem.SUSPENDENDDATEAPINAME){
                        siFieldProps[secondEntryIndex].isEditable = true;                        
                    }
                    else
                        siFieldProps[secondEntryIndex].isEditable = false;                    
                    lstEntry.add(siFieldProps[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
            }
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }       
        return twoColFormattedList; 
    }
    
    /******************************************************************************
    @author         Neha R.   
    @date           15 Jan 2019
    @return         ServiceItem__c      
    @description    Method is used to return ServiceItem information by using ServiceItem id.
    *******************************************************************************/
    @AuraEnabled 
    public static ServiceItem__c retrieveSIRecordDetails(Id serviceItemId, List<String> serviceItemFields) {    
        ServiceItem__c objServiceItem ;     
        if(string.isNotBlank(serviceItemId) || serviceItemId != null){
            objServiceItem = (ServiceItem__c)GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME,
                                                                                serviceItemId,
                                                                                serviceItemFields);
        }	
        return objServiceItem;
    }
    

}