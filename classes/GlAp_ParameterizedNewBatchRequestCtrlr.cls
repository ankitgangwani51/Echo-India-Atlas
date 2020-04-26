/******************************************************************************
@author         Echo:Vivek 
@date           30 Nov 2018
@description    Component controller for New Batch Request Lightning component
Revision(s)     
*******************************************************************************/
public with sharing class GlAp_ParameterizedNewBatchRequestCtrlr {
    private static final String CLASS_NAME = 'GlAp_ParameterizedNewBatchRequestCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static List<String> discountTypeFields;    
    static{    
        discountTypeFields = new List<String>();
        discountTypeFields.add(GlUt_APIConstantsDiscountType.DISCOUNTTYPENAMEAPINAME);
        discountTypeFields.add(GlUt_APIConstantsDiscountType.DISCOUNTTYPESTARTDATE);       
    }
    
	/******************************************************************************
	@author    	    Echo:Vivek 
	@date      		30 Nov 2018
	@param			Id - batch process Id
	@return			Id - the Id of the batch request queue record
	@description 	creates a new batch request record
	*******************************************************************************/
    @AuraEnabled
    public static Boolean createDefaultBatchRequest(String responseJSON , Id batchProcessId) {
      
        List<Id> discountTypeIdList = new List<Id>();
        Integer discTypeCount = 0;
      
        List<BlAp_CombinedRecord> recordList = (List<BlAp_CombinedRecord>) System.JSON.deserialize(responseJSON, List<BlAp_CombinedRecord>.class);             
        for(BlAp_CombinedRecord objCombineRecord: recordList){                  
            if(objCombineRecord.isSelected == true){
                discountTypeIdList.add(objCombineRecord.uniqueId);
            }            
        }
  
        if(discountTypeIdList.isEmpty() || discountTypeIdList == null)
            return false;
        
        CuBt_DiscountTypeParameters discTypeParameterObj = new CuBt_DiscountTypeParameters();
        discTypeParameterObj.discountTypeID = discountTypeIdList;
      	
        BatchRequestQueue__c batchRequestQueue = new BatchRequestQueue__c(
            BatchProcess__c = batchProcessId, 
            Priority__c = Label.CuAp_BatchProcessPriorityHigh, 
            Parameters__c = JSON.serialize(discTypeParameterObj),
            SendEmailNotification__c = true, 
            Status__c = Label.CuAp_BatchProcessStatusInitialised, 
            NotificationUser__c = UserInfo.getUserId() 
        );
        
        try {  
         	insert batchRequestQueue;

        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
            
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return true;
    }
    
    /******************************************************************************
    @author         Vivek Sethi 
    @date           30 Nov 2018
	@parameters 	-
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the fields that are
                    to be displayed on the screen
    *******************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveFieldList(){  
        
        // Get the field properties for the Message object        
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        try {            
            List<GLAp_FieldProps> MsgProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDiscountType.DISCOUNTTYPEAPINAME, discountTypeFields); 
            for(GlAp_FieldProps fieldProp : MsgProps ){
                if (fieldProp.fieldName == GlUt_APIConstantsDiscountType.DISCOUNTTYPENAMEAPINAME) {  
                    fieldProp.fieldLabel = Label.GlAp_DiscountTypeLabel;  
                  
                }
                fieldProp.isEditable = false;
                fldPropList.add(fieldProp);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return fldPropList;  
    }
    
    /******************************************************************************
    @author         Vivek Sethi 
    @date           30 Nov 2018
	@parameters		Id recordId,
					String sObjectName
    @return         List<BlAp_CombinedRecord>
    @description    This method returns the discount types  
    *******************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveRecordList() { 
        
        List<BlAp_CombinedRecord> DiscountTypeList = new List<BlAp_CombinedRecord>();        
        try {
        
            String filterStatement = ' WHERE ' + GlUt_APIConstantsDiscountType.ACTIVEAPINAME +  '= TRUE ' + 
                					 ' AND ' + GlUt_APIConstantsDiscountType.DISCOUNTTYPESELFLOOKUPAPINAME + '!= NULL'; 
            
            List<DiscountType__c> discTypeList = new List<DiscountType__c>();
            discTypeList = (List<DiscountType__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDiscountType.DISCOUNTTYPEAPINAME,
                                                                                       discountTypeFields,
                                                                                       filterStatement);   
            
            for (DiscountType__c objMsg : discTypeList) {                
                BlAp_CombinedRecord discTypeRecord = new BlAp_CombinedRecord();  
                discTypeRecord.uniqueId = objMsg.Id;
                discTypeRecord.objectMap = new Map<string, sObject>();
                discTypeRecord.objectMap.put(GlUt_APIConstantsDiscountType.DISCOUNTTYPEAPINAME, objMsg);                                    
                DiscountTypeList.add(discTypeRecord);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }        
        return DiscountTypeList;
    }

}