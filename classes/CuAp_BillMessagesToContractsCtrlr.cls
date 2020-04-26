/******************************************************************************
@author         Neha R. 
@date           17 July 2018
@description    Component controller to Apply Bill Messages to Contracts  
@revision       
*******************************************************************************/
public with sharing class CuAp_BillMessagesToContractsCtrlr {
    
    private static final String CLASS_NAME = 'CuAp_BillMessagesToContractsCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    private static final List<String> billMessageFields = new List<string>{
                                                          GlUt_APIConstantsBillMessage.NAMEAPINAME, 
                                                          GlUt_APIConstantsBillMessage.MESSAGETEXTAPINAME                                                                                                
                                                          };
                                                              
    private static final List<String> contractBillMessageFields = new List<string>{
                                                                  GlUt_APIConstantsContractBillMessage.ACTIVEAPINAME, 
                                                                  GlUt_APIConstantsContractBillMessage.BILLMESSAGEAPINAME,
                                                                  GlUt_APIConstantsContractBillMessage.BILLINGCONTRACTAPINAME
                                                                  };
                                                                      
    /******************************************************************************
    @author         Neha R. 
    @date           17 July 2018
	@parameters 	String sObjectName
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the fields that are
                    to be displayed on the screen
    *******************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveBillMessagePropDetails(String sObjectName) {        
        // Get the field properties for the Bill Message object        
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        try {          
            if(sObjectName == GlUt_APIConstantsContracts.CONTRACTAPINAME){
                 List<GLAp_FieldProps> billMsgProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsBillMessage.BILLMESSAGEAPINAME, billMessageFields); 
                for(GlAp_FieldProps fieldProp : billMsgProps ){
                    if (fieldProp.fieldName != GlUt_APIConstantsBillMessage.BILLMESSAGEID) {  //AT-3709
                        fieldProp.isEditable = false;
                        fldPropList.add(fieldProp); 
                    }
                }
               
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return fldPropList;    //AT-3709
    }
        
    /******************************************************************************
    @author         Neha R. 
    @date           17 July 2018
	@parameters		String sObjectName,
					String recordId
    @return         List<BlAp_CombinedRecord>
    @description    This method returns the field of Bill Messages that are
                    to be displayed on the screen    
    *******************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveBillMessageRecordsDetails(String sObjectName, String recordId) {
    
        List<BlAp_CombinedRecord> billMessageSelectList = new List<BlAp_CombinedRecord>();
        
        try {
            if(sObjectName == GlUt_APIConstantsContracts.CONTRACTAPINAME){                
                List<BillMessage__c> billMsgList = (List<BillMessage__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBillMessage.BILLMESSAGEAPINAME, billMessageFields);
                
                String filterStatement = ' WHERE ' + GlUt_APIConstantsContractBillMessage.BILLINGCONTRACTAPINAME + ' = \'' + recordId + '\'';
                List<ContractBillMessage__c> contractBillMsgList = (List<ContractBillMessage__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsContractBillMessage.CONTRACTBILLMESSAGEAPINAME,                                                                                                                                  
                                                                                                                                      contractBillMessageFields,
                                                                                                                                      filterStatement);
                Map<Id,Boolean> activeContractBillMessageMap = new Map<Id,Boolean>();
                // Map of active Bill Messages on Contract
                for(ContractBillMessage__c objCBM :contractBillMsgList){
                    activeContractBillMessageMap.put(objCBM.BillMessage__c, objCBM.Active__c);
                }
                
                // Loop through the Bill Message list and capture the appropriate Bill Message information
                for (BillMessage__c objBillMsg : billMsgList) {
                    
                    BlAp_CombinedRecord BillMessageSelectRecord = new BlAp_CombinedRecord();  
                    BillMessageSelectRecord.uniqueId = objBillMsg.Id;
                    
                    // If ContractBilling Message is active 
                    if(activeContractBillMessageMap.containsKey(objBillMsg.Id) && activeContractBillMessageMap.get(objBillMsg.Id) == true)
                        BillMessageSelectRecord.isSelected = true;
                    else                    
                        BillMessageSelectRecord.isSelected = false;
                    
                    BillMessageSelectRecord.objectMap = new Map<string, sObject>();
                    BillMessageSelectRecord.objectMap.put(GlUt_APIConstantsBillMessage.BILLMESSAGEAPINAME, objBillMsg);                                    
                    billMessageSelectList.add(BillMessageSelectRecord);
                }
            }
        
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return billMessageSelectList;
    }
       
    /******************************************************************************
    @author         Neha R. 
    @date           17 July 2018
	@parameters		String responseJSON,
					String recordId,
					String sObjectName
    @return         String
    @description    This method update the field of Contract Bill Message that updated
                    on the screen      
    *******************************************************************************/
    @AuraEnabled
    public static String saveContractBillMessageDetails(String responseJSON, String recordId, String sObjectName) {
       
        try {       
            if(sObjectName == GlUt_APIConstantsContracts.CONTRACTAPINAME){ 
                Set<Id> selectedBillMessageIdSet = new Set<Id>();
                List<BlAp_CombinedRecord> recordList = (List<BlAp_CombinedRecord>) System.JSON.deserialize(responseJSON, List<BlAp_CombinedRecord>.class);             
               
                for(BlAp_CombinedRecord objCombineRecord: recordList){                  
                    if(objCombineRecord.isSelected == true){
                        selectedBillMessageIdSet.add(objCombineRecord.uniqueId);
                    }            
                }
                
                String filterStatement = ' WHERE ' + GlUt_APIConstantsContractBillMessage.BILLINGCONTRACTAPINAME + ' = \'' + recordId + '\'';
                List<ContractBillMessage__c> contractBillMsgList = (List<ContractBillMessage__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsContractBillMessage.CONTRACTBILLMESSAGEAPINAME,                                                                                                                                  
                                                                                                                                      contractBillMessageFields,
                                                                                                                                      filterStatement);                  
                List<ContractBillMessage__c> updatedCBMList = new List<ContractBillMessage__c>();        
                // update existing Contract Bill Message record
                for(ContractBillMessage__c objCBM : contractBillMsgList){
                    if(selectedBillMessageIdSet.contains(objCBM.BillMessage__c)){
                        objCBM.Active__c = true;
                        selectedBillMessageIdSet.remove(objCBM.BillMessage__c);
                    }
                    else{
                        objCBM.Active__c = false;  
                    }
                    updatedCBMList.add(objCBM);
                }  
                if(updatedCBMList!= null && !updatedCBMList.isEmpty()){
                    updatedCBMList = (List<ContractBillMessage__c>)GlUt_FieldSecurity.cleanseFields(updatedCBMList, false);
                    Database.update(updatedCBMList);
                }
                // 
                /*AT-4373 Clayton Code Review Starts Here*/
                List<ContractBillMessage__c> newContractMessageList = new List<ContractBillMessage__c>();
                for(Id objBillMessage:selectedBillMessageIdSet){
                    ContractBillMessage__c objCBM = new ContractBillMessage__c(Active__c = true,
                                                                               BillMessage__c=objBillMessage,
                                                                               BillingContract__c=recordId );  
                    newContractMessageList.add(objCBM);
                }
                if(!newContractMessageList.isEmpty()){
                    newContractMessageList = (List<ContractBillMessage__c>)GlUt_FieldSecurity.cleanseFields(newContractMessageList, false);
                    database.insert(newContractMessageList);
                }
                /*for(Id objBillMessage:selectedBillMessageIdSet){
                    ContractBillMessage__c objCBM = new ContractBillMessage__c(Active__c = true,
                                                                               BillMessage__c=objBillMessage,
                                                                               BillingContract__c=recordId );                    
                    database.insert(objCBM);
                }*/
                /*AT-4373 Clayton Code Review Ends Here*/
                return  System.Label.GlAp_Success;
            }
        
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }     
        
        return '';
    }
    
}