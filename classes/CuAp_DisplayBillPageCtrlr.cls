/**********************************************************************************************
@author:		Accenture : Sucharu Gupta
@date:			20-Nov-2017
@description:	This is associated controller Class used to Query Bill Items and used in 
				CuAp_DisplayBillComponent  
@group:          
@Revision(s):	Accenture : Vandana Anshu  24-11-2017
				Accenture : Vandana Anshu  4-12-2017 
				02 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
@Revision	 	AT-3979, Tarun - Modified as per security review
**********************************************************************************************/
public with sharing class CuAp_DisplayBillPageCtrlr {
    
    private static List<string> billFields; 
    private static List<string> billServTypeFlds;
    private static List<string> billItemFields; 
    private static List<string> billItemRecordFields;
    private static final String CLASS_NAME = 'CuAp_DisplayBillPageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    static {
    	
    	billFields = new List<String>{
    								GlUt_APIConstantsBill.BILLEDAMOUNTAPINAME};
    	
             
        // Get Fields from the Bill Service Type Object
        //MT - 24/05/2018 AT - 2685 Removed the name field and added service type field
        billServTypeFlds = new List<string>();
        billServTypeFlds.add(GlUt_APIConstantsBillServiceType.SERVICETYPEAPINAME);
        
        // Get Fields from the Bill Item Object
        //MT - 24/05/2018 AT - 2685 Removed the name field and added service item type name field
        billItemFields = new List<string>();
        billItemFields.add(GlUt_APIConstantsBillItem.BILLITEMFROM);
        billItemFields.add(GlUt_APIConstantsBillItem.BILLITEMTO);
        billItemFields.add(GlUt_APIConstantsBillItem.BILLEDAMOUNTAPINAME);
        billItemFields.add(GlUt_APIConstantsBillItem.SERVICEITEMTYPENAME);
        
        //MT - 24/05/2018 AT - 2685 created the below list to fetch the fields which is not required for display
        billItemRecordFields = new List<string>();
        billItemRecordFields.add(GlUt_APIConstantsBillItem.BILLITEMFROM);
        billItemRecordFields.add(GlUt_APIConstantsBillItem.BILLITEMTO);
        billItemRecordFields.add(GlUt_APIConstantsBillItem.BILLEDAMOUNTAPINAME);
        billItemRecordFields.add(GlUt_APIConstantsBillItem.BILLSERVICETYPEAPINAME);
        billItemRecordFields.add(GlUt_APIConstantsBillItem.SERVICEITEMTYPENAME);
    }       
      
    /**********************************************************************************************
    @author         Accenture: Vandana Anshu
    @date           30-Nov-2017
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the fields that are
                    to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveBillItemFieldPropDetails() {
        
        // Get the field properties for the Bill Service Type object
        List<GLAp_FieldProps> billServTypeProps = GlAp_LightningDataAccess.getObjectsFieldProperties(CuAp_Constants.BILLSERVICETYPEAPINAME, billServTypeFlds);
        
        // Get the field properties for the Location object
        List<GLAp_FieldProps> billItmProps = GlAp_LightningDataAccess.getObjectsFieldProperties(CuAp_Constants.BILLITEMAPINAME, billItemFields);
        
        // Build a map list of all field properties
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        try {
            GlUt_Logger.logDebug(DEBUG);
            if (billServTypeProps != null) {
                for (GLAp_FieldProps fldProp : billServTypeProps) {
                    fldProp.isEditable = false;        
                    fldPropList.add(fldProp);                           
                }       
            }
            
            if (billItmProps != null) {
                for (GlAp_FieldProps fldProp : billItmProps) {
                    fldProp.isEditable = false;
                    
                    if (fldProp.fieldLabel == CuAp_Constants.BILLITMAMOUNT) {
                        fldProp.fieldLabel = CuAp_Constants.BILLITEMAMOUNTLABEL;
                    }
                    fldPropList.add(fldProp); 
                }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return fldPropList;
    }
    
    /**********************************************************************************************
    @author         Accenture: Vandana Anshu
    @date           30-Nov-2017
    @param          Id - bill Id
    @return         List<BlAp_CombinedRecord>
    @description    This method takes the contractId to return all the Bill Item associated to it for its latest Bill.
    **********************************************************************************************/     
    @AuraEnabled
    public static List<BlAp_CombinedRecord> fetchLstOfBillItems(Id billId) {
        
        List<BlAp_CombinedRecord> combBillItemList = new List<BlAp_CombinedRecord>();
        
        try {
            GlUt_Logger.logDebug(DEBUG);
            Map<Id,BillServiceType__c> mapBillSrvType = new Map<Id,BillServiceType__c>();
            for (BillServiceType__c billSrvType : (List<BillServiceType__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBillServiceType.OBJECTAPINAME, 
                                                                                                                 billServTypeFlds, 
                                                                                                                 billId, 
                                                                                                                 GlUt_APIConstantsBillServiceType.BILLAPINAME)) {
                                                                                                                     
                                                                                                                     mapBillSrvType.put(billSrvType.Id, billSrvType);
                                                                                                                 }
            
            List<Id> billsrvTypeIds = new List<String>();
            billsrvTypeIds.addAll(mapBillSrvType.keySet());
            
            String filterStatements = String.format(' WHERE {0} IN {1}', new List<String>{
                GlUt_APIConstantsBillItem.BILLSERVICETYPEAPINAME, 
                    GlUt_FieldSecurity.IdsToString(billsrvTypeIds)});
            
            // Loop throught the billItem list and add to list of BlAp_CombinedRecord
            for (BillItem__c billItem : (List<BillItem__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBillItem.BILLITEMAPINAME, 
                                                                                                billItemRecordFields, 
                                                                                                filterStatements)) {
               BlAp_CombinedRecord billItemRec = new BlAp_CombinedRecord();
               BillServiceType__c billSrvType = new BillServiceType__c();
               if (mapBillSrvType.containsKey(billItem.BillServiceType__c)) {
               billSrvType = mapBillSrvType.get(billItem.BillServiceType__c);
               }   
               billItemRec.uniqueId = billItem.Id;
               billItemRec.isSelected = false;
               billItemRec.objectMap = new Map<string, sObject>();
               billItemRec.objectMap.put(CuAp_Constants.BILLITEMAPINAME, billItem);
               billItemRec.objectMap.put(GlUt_APIConstantsBillItem.BILLSERVICETYPEAPINAME, billSrvType);
               combBillItemList.add(billItemRec);            
                                                                                                    
               }   
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        system.debug(JSON.serialize(combBillItemList));
        return combBillItemList;        
    }
  
    /**********************************************************************************************
    @author         Accenture: Vandana Anshu
    @date           2-Nov-2017
    @param          Id - bill Id
    @return         totalBilledAmount
    @description    This method returns the Billed Amount for a Bill.
    **********************************************************************************************/     
    @AuraEnabled
    public static Double retrieveBillAmount(Id billId) {
        Bill__c bill ;
        try {
            GlUt_Logger.logDebug(DEBUG);
            bill = (Bill__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsBill.BILLAPINAME, billId, billFields);
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return bill.BilledAmount__c;
    }      
}