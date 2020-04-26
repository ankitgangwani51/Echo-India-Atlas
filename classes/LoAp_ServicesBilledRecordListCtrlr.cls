/******************************************************************************
@author         Neha Rajput
@date           11 Oct 2018
@description    Component controller for display reading linked services billed
@version:       
*******************************************************************************/
public with sharing class LoAp_ServicesBilledRecordListCtrlr { 
    
    private static final String CLASS_NAME = 'LoAp_ServicesBilledRecordListCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
	private static List<String> servicesBilledFields;
    private static List<String> servicesBilledFieldsHeader;
    
    static{    
        servicesBilledFields = new List<String>();
        servicesBilledFields.add(GlUt_APIConstantsService.NAMEAPINAME);      // Service No.
        servicesBilledFields.add(GlUt_APIConstantsService.SERVICETYPEAPINAME);
        servicesBilledFields.add(GlUt_APIConstantsService.SERVICECONTRACTAPINAME);
        servicesBilledFields.add(GlUt_APIConstantsService.SUPPLYPOINTAPINAME);
        servicesBilledFields.add(GlUt_APIConstantsService.SERVICESTARTDATEAPINAME);
        
        servicesBilledFieldsHeader = new List<String>();
        servicesBilledFieldsHeader.add(GlUt_APIConstantsService.NAMEAPINAME); 
        servicesBilledFieldsHeader.add(GlUt_APIConstantsService.SERVICESTARTDATEAPINAME);
    }   
    
    /**********************************************************************************************
    @author         Neha Rajput
    @date           11 Oct 2018
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the fields that are
                    to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveServiceBilledFieldSetList() {
      
        List<GlAp_FieldProps> fldPropList = new List<GlAp_FieldProps>();
        try {
            fldPropList = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsService.SERVICEAPINAME, servicesBilledFieldsHeader);
           
            // SERVICE TYPE
            GlAp_FieldProps serviceTypefieldprop = new GlAp_FieldProps(true, false, false, false,GlUt_APIConstantsService.SERVICETYPEAPINAME, 
                                                                       LoAp_constants.SERVICETYPELABEL, LoAp_Constants.REFERENCEFIELD, true, 
                                                                       GlUt_APIConstantsService.SERVICETYPEAPINAME);
            fldPropList.add(1,serviceTypefieldprop);
            
            //BILLING CONTRACT
            GlAp_FieldProps billingContractfieldprop = new GlAp_FieldProps(true, false, false, false,GlUt_APIConstantsService.SERVICECONTRACTAPINAME, 
                                                                           LoAp_constants.BILLINGCONTRACTLABEL, LoAp_Constants.REFERENCEFIELD, true, 
                                                                           GlUt_APIConstantsService.SERVICECONTRACTAPINAME);
            fldPropList.add(2,billingContractfieldprop);
            
            //SUPPLY POINT
            GlAp_FieldProps supplyPointfieldprop = new GlAp_FieldProps(true, false, false, false,GlUt_APIConstantsService.SUPPLYPOINTAPINAME, 
                                                                       LoAp_constants.SUPPLYPOINTLABEL, LoAp_Constants.REFERENCEFIELD, true, 
                                                                       GlUt_APIConstantsService.SUPPLYPOINTAPINAME);
            fldPropList.add(3,supplyPointfieldprop);
            
            //BILLED
            GlAp_FieldProps billedfieldprop = new GlAp_FieldProps(true, false, false, false,GlUt_Constants.BILLED, 
                                                                  GlUt_Constants.BILLED, LoAp_Constants.TEXT, true, 
                                                                  GlUt_APIConstantsService.SERVICEAPINAME);
            fldPropList.add(billedfieldprop);            
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return fldPropList;
    }
    
    /******************************************************************************
    @author         Neha Rajput
    @date           11 Oct 2018
    @param          Id - Reading Id
    @return         List<BlAp_CombinedRecord> - list of combined services records to display
    @description    get the list of Service records to display
    *******************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveServiceBilledFieldRecords(Id recordId) {
       
        List<BlAp_CombinedRecord> records = new List<BlAp_CombinedRecord>();
        try {            
            // Selected Reading Record
            Reading__c objReading = [SELECT Device__c,ReadingDate__c
                                     FROM Reading__c
                                     WHERE Id =: recordId LIMIT 1]; 
            
            if(objReading != null){
                List<SupplyPointDevice__c> lstSPD = new List<SupplyPointDevice__c>();
                lstSPD = [SELECT Device__c,SupplyPoint__c
                          FROM SupplyPointDevice__c
                          WHERE Device__c =: objReading.Device__c
                          AND InstallationDate__c <=: objReading.ReadingDate__c 
                          AND (RemovalDate__c >=: objReading.ReadingDate__c 
                               OR RemovalDate__c = null) LIMIT 1];
                
                if(lstSPD != null && !lstSPD.isEmpty()){
                    String queryClause = ' WHERE ' + GlUt_APIConstantsService.SUPPLYPOINTAPINAME + ' = \'' + lstSPD[0].SupplyPoint__c + '\' ';
                    List<Service__c> serviceRecordList = new List<Service__c>();
                    // Service linked to Supply Point
                    serviceRecordList = GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsService.SERVICEAPINAME, 
                                                                            servicesBilledFields, 
                                                                            queryClause);
                    
                    // Bill Item Linked on services
                    List<BillItem__c> billItemRecordList = new List<BillItem__c>();
                    billItemRecordList = [SELECT Id,ServiceItem__r.Service__c  
                                          FROM BillItem__c
                                          WHERE ServiceItem__r.Service__c IN: serviceRecordList
                                           AND Reading__c =: objReading.Id];
                    
                    Set<Id> billItemOnService = new Set<Id>();
                    for(BillItem__c serviceID: billItemRecordList){
                        billItemOnService.add(serviceID.ServiceItem__r.Service__c);
                    }                  
                   
                    List<Id> lstServiceTypeReferencefields = new List<Id>();
                    List<Id> lstBillingContractReferencefields = new List<Id>();
                    List<Id> lstSupplyPointReferencefields = new List<Id>();
                  
                    for(Service__c objService : serviceRecordList){  
                        if(objService.ServiceType__c != null)
                            lstServiceTypeReferencefields.add(objService.ServiceType__c);
                        	                        
                        if(objService.BillingContract__c != null)
                            lstBillingContractReferencefields.add(objService.BillingContract__c);
                        	
                        if(objService.SupplyPoint__c != null)
                        	lstSupplyPointReferencefields.add(objService.SupplyPoint__c);                            
                    }
                    
                    //Service Type
                    Map<Id, String> serviceTypeDetailsMap = new Map<Id, String>();
                    if(!lstServiceTypeReferencefields.isEmpty()){
                        serviceTypeDetailsMap = GlAp_LightningDataAccess.getRecordName(lstServiceTypeReferencefields);
                    }
                    
                    //Billing Contract
                    Map<Id, String> billingContactDetailsMap = new Map<Id, String>();
                    if(!lstBillingContractReferencefields.isEmpty()){                        
                        billingContactDetailsMap = GlAp_LightningDataAccess.getRecordName(lstBillingContractReferencefields);                    
                    }
                    
                    //Supply Point
                    Map<Id, String> supplyPoinDetailsMap = new Map<Id, String>();
                    if(!lstSupplyPointReferencefields.isEmpty()){                        
                        supplyPoinDetailsMap = GlAp_LightningDataAccess.getRecordName(lstSupplyPointReferencefields);                    
                    }
                    
                    for (Service__c objService : serviceRecordList) {
                        BlAp_CombinedRecord record = new BlAp_CombinedRecord();            
                        record.uniqueId = objService.Id;
                        record.isSelected = false;
                        record.readOnlyFields = new Map<String, Boolean>();
                        
                        record.objectMap = new Map<String, sObject>();
                        record.objectMap.put(GlUt_APIConstantsService.SERVICEAPINAME, objService); 
                        
                        record.transFormFieldMap = new Map<String,Map<String,String>>(); 
                        
                        // BILLED
                        Map<String,String> transFormBilledFieldMap = new Map<String,String>();
                        if(billItemOnService.contains(objService.Id))
                        	transFormBilledFieldMap.put(GlUt_Constants.BILLED, 'True');
                        else
                            transFormBilledFieldMap.put(GlUt_Constants.BILLED, 'False');                         
                        record.transFormFieldMap.put(GlUt_APIConstantsService.SERVICEAPINAME, transFormBilledFieldMap);
                        
                        // SERVICE TYPE
                        if(!serviceTypeDetailsMap.isEmpty()){
                            Map<String,String> serviceTypeDetailsFieldMap = new Map<String,String>();
                            serviceTypeDetailsFieldMap.put(objService.ServiceType__c,
                                                              serviceTypeDetailsMap.get(objService.ServiceType__c));
                            record.transFormFieldMap.put(GlUt_APIConstantsService.SERVICETYPEAPINAME ,serviceTypeDetailsFieldMap);
                        }
                        
                        // BILLING CONTRACT
                        if(!billingContactDetailsMap.isEmpty()){
                            Map<String,String> billingContractDetailsFieldMap = new Map<String,String>();
                            billingContractDetailsFieldMap.put(objService.BillingContract__c,
                                                              billingContactDetailsMap.get(objService.BillingContract__c));
                            record.transFormFieldMap.put(GlUt_APIConstantsService.SERVICECONTRACTAPINAME ,billingContractDetailsFieldMap);
                        }
                        
                        // SUPPLY POINT
                        if(!supplyPoinDetailsMap.isEmpty()){
                            Map<String,String> supplyPointDetailsFieldMap = new Map<String,String>();
                            supplyPointDetailsFieldMap.put(objService.SupplyPoint__c,
                                                              supplyPoinDetailsMap.get(objService.SupplyPoint__c));
                            record.transFormFieldMap.put(GlUt_APIConstantsService.SUPPLYPOINTAPINAME ,supplyPointDetailsFieldMap);
                        }
                        
                        records.add(record);                       
                        System.debug(DEBUG + 'record: ' + record);
            		}
                }                
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return records;
    }
    
    
}