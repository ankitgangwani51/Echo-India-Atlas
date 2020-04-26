/******************************************************************************
@author         Tarun Gupta 
@date           01 Aug 2018
@description      
@revision       23 Oct 2018  Dependra Singh - BillTransfer payload Changes
@Revisions		13 Dec 2018 , Tarun Gupta , AT-4502,4504,4505 , Added new parameter - LicenseId and sent it as blank
*******************************************************************************/
public with sharing class CuAp_BillTransferCtrlr {
    
    private static final String CLASS_NAME = 'CuAp_BillTransferCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static final List<String> billFields = new List<string>{
                                                          GlUt_APIConstantsBill.BILLDATEAPINAME,
                                                          GlUt_APIConstantsBill.BILL_TYPE, 
                                                          GlUt_APIConstantsBill.BILLEDAMOUNTAPINAME,
                                                          GlUt_APIConstantsBill.STARTDATEAPINAME,
                                                          GlUt_APIConstantsBill.ENDDATEAPINAME
                                                          };  
                                                              
    private static final List<String> transferReasonField = new List<string>{
                                                          GlUt_APIConstantsBillTransfer.TRANSFERREASONAPINAME
                                                          };                                             
    /******************************************************************************
    @author         Tarun Gupta 
    @date           01 Aug 2018
    @parameters     
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the fields that are
                    to be displayed on the screen
    *******************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveBillFieldDetails() {        
        // Get the field properties for the Bill Message object        
        List<GLAp_FieldProps> billProperties = new List<GLAp_FieldProps>();
        try {
            billProperties = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsBill.BILLAPINAME, billFields); 
            for(GlAp_FieldProps fieldProp : billProperties ){
                fieldProp.isEditable = false;
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return billProperties;
    }
    /******************************************************************************
    @author         Dependra Singh 
    @date           16 Nov 2018
    @parameters     
    @return         
    @description    This method returns the field properties for each of the fields that are
                    to be displayed on the screen
    *******************************************************************************/
    @AuraEnabled
    public static WrapperBillTransferDetails retrieveBillTransferDetails(string recordId) {           
        WrapperBillTransferDetails objWrapper = new WrapperBillTransferDetails();
        if(recordId !=  null){
            objWrapper.fieldList =  CuAp_BillTransferCtrlr.retrieveBillFieldDetails();
            objWrapper.selectedUnpaidBillList = CuAp_BillTransferCtrlr.getUnpaidBills(recordId);
            objWrapper.accountId =CuAp_BillTransferCtrlr.getAccountIdDetails(recordId);
            objWrapper.billTransferFields =CuAp_BillTransferCtrlr.retrieveTransferReasonDetails();
        }
        return objWrapper;
    }
    
    /******************************************************************************
    @author         Tarun Gupta 
    @date           01 Aug 2018

    @return         List<BlAp_CombinedRecord>
    @description    This method returns the field of Bill Messages that are
                    to be displayed on the screen    
    *******************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> getUnpaidBills(String recordId) {
    
        List<BlAp_CombinedRecord> billSelectList = new List<BlAp_CombinedRecord>();
        List<String> lstBillTypes  = new List<String>();
        List<Bill__c> listOfBill = new List<Bill__c>();
        try {
            lstBillTypes.add(Label.CuAp_NormalBillType);
            lstBillTypes.add(Label.GlUt_Transfer);
            //String billType = Label.CuAp_NormalBillType;
            String filterStatement = ' WHERE ' + GlUt_APIConstantsBill.CONTRACTNUMBERAPINAME + ' = \'' + String.escapeSingleQuotes(recordId) + '\'';
            //filterStatement = filterStatement + ' AND ' + GlUt_APIConstantsBill.BILL_TYPE + ' = \'' + String.escapeSingleQuotes(billType)+ '\''; 
            filterStatement = filterStatement + ' AND ' + GlUt_APIConstantsBill.BILL_TYPE + ' IN ' + GlUt_FieldSecurity.ListToString(lstBillTypes) ;
            filterStatement = filterStatement + ' AND ' + GlUt_APIConstantsBill.TOTALAMOUNTOUTSTANDINGAPINAME + ' > 0 ';
            filterStatement = filterStatement + ' AND ' + GlUt_APIConstantsBill.SELECTEDBILLTRANSFER  + '= null';
            listOfBill = (List<Bill__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBill.BILLAPINAME,billFields,filterStatement);
            // Loop through the Bill  list and capture the appropriate Bill Message information
            for (Bill__c objBill : listOfBill) {
                BlAp_CombinedRecord BillSelectRecord = new BlAp_CombinedRecord();  
                BillSelectRecord.uniqueId = objBill.Id;
                BillSelectRecord.objectMap = new Map<string, sObject>();
                BillSelectRecord.objectMap.put(GlUt_APIConstantsBill.BILLAPINAME, objBill);                                    
                billSelectList.add(BillSelectRecord);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return billSelectList;
    }
    
    /******************************************************************************
    @author         Tarun Gupta 
    @date           01 Aug 2018
    @parameters     String recordId
    @return         List<BlAp_CombinedRecord>
    @description    This method returns the field of Bill Messages that are
                    to be displayed on the screen    
    *******************************************************************************/
    @AuraEnabled
    public static String getAccountIdDetails(String recordId) {
        String accountId;
         BillingContract__c contractObj = (BillingContract__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsContracts.CONTRACTAPINAME, Id.valueOf(recordId), 
                                                                                                   new List<String>{GlUt_APIConstantsContracts.CUSTOMERAPINAME});
        //BillingContract__c contractObj = [SELECT AccountName__c FROM BillingContract__c WHERE Id =: recordId LIMIT 1];
        accountId = contractObj.AccountName__c;
        return accountId;
        
    }
    
    /******************************************************************************
    @author         Tarun Gupta 
    @date           01 Aug 2018
    @parameters     
    @return         List<BlAp_CombinedRecord>
    @description    This method returns the field of Bill Messages that are
                    to be displayed on the screen    
    *******************************************************************************/
    
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrieveTransferReasonDetails() {
        
        List<GLAp_FieldProps> allFieldProp = new List<GLAp_FieldProps>();  
        List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
        try {
            List<GLAp_FieldProps> transferReasonFieldProps = new List<GLAp_FieldProps>();
            transferReasonFieldProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsBillTransfer.BILLTRANSFERAPINAME, transferReasonField);
            
            for(integer i=0; i < transferReasonFieldProps.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(transferReasonFieldProps[i]);
                
                if(secondEntryIndex < transferReasonFieldProps.size()){
                    lstEntry.add(transferReasonFieldProps[secondEntryIndex]);   
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
    @author         Dependra Singh
    @date           23 Oct 2018
    @parameters     String contractId
                    
    @return         BillCalculation__c
    @description    This method create  bill calculation record and return id 
    *******************************************************************************/
    @AuraEnabled
    public static Id createBillCalculation(string contractId){
        BillCalculation__c billCalculationObj = GlUt_BillCalculationUtilities.createBillCalculation(contractId,Label.GlUt_Transfer,Label.BlIn_BillCalculationStatusNew);
        return billCalculationObj.Id;
    }
    /******************************************************************************
    @author         Tarun Gupta 
    @date           01 Aug 2018
    @parameters     List<Id> selectedBillIds, 
                    String contractToTransferId, 
                    String contractId, 
                    String transferReason
    @return         List<BlAp_CombinedRecord>
    @description    This method returns the field of Bill Messages that are
                    to be displayed on the screen  
    @revesion       Update Bill Transfer Payload, Created new class for payload- CuAp_BillTransferObject
                    AT-4049, AT-4050 -  Date - 23 Oct 2018 - Dependra Singh
    *******************************************************************************/
    @AuraEnabled
    public static String transferBills(List<Id> selectedBillIds, String contractToTransferId, String contractId, String transferReason,string billCalculationId) {        
        String responseCode;
        CuAp_BillTransferObject objBTData = new CuAp_BillTransferObject();
        objBTData.BillTransfers = new List<CuAp_BillTransferObject.BillTransfers>(); 
        
        CuAp_BillTransferObject.BillTransfers objBillTransfer = new CuAp_BillTransferObject.BillTransfers(selectedBillIds,contractToTransferId,contractId,
                                                                                                          transferReason,null,billCalculationId,null);
        objBTData.BillTransfers.add(objBillTransfer);
        //BillTransferObj data = new BillTransferObj(selectedBillIds, contractToTransferId, contractId, transferReason);
        String JSONPayload = JSON.serialize(objBTData);
       try{
            HttpResponse response = BlUt_HerokuWebservices.makeCallout(BlUt_HerokuWebservices.BILL_TRANSFER, 2000, 'application/json', JSONPayload, 'PUT');
           // handle response
            if (response.getStatusCode() == 200) {
                System.debug(DEBUG + 'Good response: ' + response.getStatusCode() + ' ' + response.getStatus());
                
                if(billCalculationId != null ){
                    List<BillCalculation__c> billCalculationList = [SELECT Id, Status__c FROM BillCalculation__c 
                                                                    WHERE ID =: billCalculationId LIMIT 1];
                    billCalculationList[0].Status__c = Label.BlIn_BillCalculationStatusPending;
                    billCalculationList  = (List<BillCalculation__c>) GlUt_FieldSecurity.cleanseFields(billCalculationList, false);
                    update billCalculationList;
                }
                responseCode = Label.GlUt_OK; 
            }
            else {
                System.debug(DEBUG + 'Error response: ' + response.getStatusCode() + ' ' + response.getStatus());
                throw new AuraHandledException(Label.BlAp_BillCalcRequestError + response.getStatus());
            }
        }
        catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        return responseCode;
    }
    
   /******************************************************************************
    @author         Echo: Dependra Singh
    @date           16- Nov-2018
    @param          none
    @return         none
    @description    wrapper class to show the values in screen.
    *******************************************************************************/
    public class WrapperBillTransferDetails{
        @AuraEnabled public List<GLAp_FieldProps> fieldList;                
        @AuraEnabled public List<BlAp_CombinedRecord> selectedUnpaidBillList;
        @AuraEnabled public string accountId;
        @AuraEnabled public List<List<GlAp_FieldProps>>  billTransferFields;
        // Constructor to initialize member variables
        public WrapperBillTransferDetails(){
            this.fieldList = new List<GLAp_FieldProps>();             
            this.selectedUnpaidBillList = new List<BlAp_CombinedRecord>();
            this.billTransferFields = new List<List<GlAp_FieldProps>>();
        } 
    }
}