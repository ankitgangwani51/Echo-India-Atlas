/******************************************************************************
@author         Accenture: Vivek Chauan
@date           10 Nov 2017
@description    Component controller for AggredRatePage lightning component
@Revision(s)	By Dependra Singh -01-03-2018 - Added field security. 
				By Tarun Gupta -07-03-2018 - Changed relationship query to individual as security classes doesn't support it
				03 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class CuAp_AgreedRatePageCtrlr {
    public static List<string> AgreedRatesFields;
    public static List<string> ServiceItemFields;
    public static List<string> rateFields;   
    public static List<string> contractListFields;   
    private static boolean fieldsInitialised = false;
    private static final String CLASS_NAME = 'CuAp_AgreedRatePageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    static{
        //Get Fields from the Agreed Rate Object
        AgreedRatesFields = new List<string>();
        AgreedRatesFields.add(CuAp_Constants.FIELDAPIAGREEDRATESVALUE);
        AgreedRatesFields.add(CuAp_Constants.FIELDAPIAGREEDRATESSTARTDATE);
        AgreedRatesFields.add(CuAp_Constants.FIELDAPIAGREEDRATESENDDATE);
        AgreedRatesFields.add(CuAp_Constants.FIELDAPIAGREEDRATESLEADYEAR);
        
        //Get Fields from the Service Item object 
        ServiceItemFields = new List<string>();
      //ServiceItemFields.add('name');                    
        ServiceItemFields.add(CuAp_Constants.FIELDAPISERVICEITEMSERVICETYPE);
        ServiceItemFields.add(CuAp_Constants.FIELDAPISERVICEITEMSERVICEITEMTYPE);
      //ServiceItemFields.add('Retail_Amount__c');                      // commented By Ashish on 12/01/2018 ref.AT-1491
        ServiceItemFields.add(CuAp_Constants.FIELDAPISERVICEITEMSUPPLYPOINT);
        ServiceItemFields.add(CuAp_Constants.FIELDAPISERVICEITEMLOCATION);
        
        //Get Fields from the Rate Object
        rateFields = new List<String>();                                // Added By Ashish on 12/01/2018 ref.AT-1491 
        rateFields.add(CuAp_Constants.FIELDAPIRATESRETAILAMOUNT);       // Added By Ashish on 12/01/2018 ref.AT-1491
        
        //Get Fields from the Contr Object
        contractListFields = new List <String> {
        GlUt_APIConstantsContracts.CUSTOMERAPINAME,
        GlUt_APIConstantsContracts.STATUSAPINAME,
        GlUt_APIConstantsContracts.BALANCEAPINAME,
        GlUt_APIConstantsContracts.STARTDATE,
        GlUt_APIConstantsContracts.ENDDATE
        }; 
    }
    
    private static final List < String > serviceItemFieldList = new List <String> {
    	GlUt_APIConstantsServiceItem.SERVICETYPEAPINAME,
        GlUt_APIConstantsServiceItem.SERVICEITEMTYPEAPINAME,    
        GlUt_APIConstantsServiceItem.SUPPLYPOINTAPINAME,   
        GlUt_APIConstantsServiceItem.LOCATIONAPINAME       
    };
        
    private static final List < String > serviceFieldList = new List <String> {
        GlUt_APIConstantsService.SERVICECONTRACTAPINAME
    };
        
    private static final List < String > serviceItemTypeFieldList = new List <String> {
        GlUt_APIConstantsServiceItemType.ELIGIBLEFORAGREEDDATEAPINAME
    }; 
        
    private static final List < String > rateFieldList = new List <String> {
        GlUt_APIConstantsRate.RETAILAMOUNTAPINAME,
        GlUt_APIConstantsRate.SERVICEITEMTYPEAPINAME,
        GlUt_APIConstantsRate.STARTDATEAPINAME,
        GlUt_APIConstantsRate.ENDDATEAPINAME
    };
        
    private static final List < String > agreedRateFieldList = new List <String> {
        GlUt_APIConstantsAgreedRate.VALUEAPINAME,
        GlUt_APIConstantsAgreedRate.STARTDATEAPINAME,
        GlUt_APIConstantsAgreedRate.ENDDATEAPINAME,
        GlUt_APIConstantsAgreedRate.LEAPYEARAPINAME,
        GlUt_APIConstantsAgreedRate.SERVICEITEMAPINAME,
        GlUt_APIConstantsAgreedRate.AMENDEDBYAGREEDRATEAPINAME
    };    
    
    /**********************************************************************************************
	@author         Accenture: Vivek Chauhan
	@date           11-Nov-2017
	@return         List<GLAp_FieldProps>
	@description        This method returns the field properties for each of the fields that are
	to be displayed on the screen
	**********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveAgreedRatesFieldPropDetails() {
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        try {
            //Get the field properties for the supression object
            List<GLAp_FieldProps> AgreedRatesProps = GlAp_LightningDataAccess.getObjectsFieldProperties(BlAp_Constants.AGREEDRATESNAME , AgreedRatesFields);
            //Get the field properties from the contract object
            List<GLAp_FieldProps> serviceItemProps = GlAp_LightningDataAccess.getObjectsFieldProperties(BlAp_Constants.SERVICEITEMNAME, ServiceItemFields);
            //Get the field properties from the Rate object
            List<GLAp_FieldProps> rateProps = GlAp_LightningDataAccess.getObjectsFieldProperties(CuAp_Constants.OBJECTAPIRATES, rateFields);        // Added By Ashish on 12/01/2018 ref.AT-1491
            //Want to make all of the contract fields readonly
            
            //Build a map list of all field properties
            for(GLAp_FieldProps fldProp : serviceItemProps){
                fldProp.isEditable = false;
                fldPropList.add(fldProp); 
            }
            for(GLAp_FieldProps fldProp : rateProps){                   // Added By Ashish on 12/01/2018 ref.AT-1491
                fldProp.isEditable = false;
                fldPropList.add(fldProp); 
            }
            for(GLAp_FieldProps fldProp : AgreedRatesProps){
                if(fldProp.fieldLabel == CuAp_Constants.FIELDVALUEAGREEDRATESVALUE ){
                    fldProp.fieldLabel = CuAp_Constants.FIELDSHOWVALUEAGREEDRATESVALUE;
                }
                fldPropList.add(fldProp); 
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
	@author         Accenture: Vivek Chauhan
	@date           12-Nov-2017
	@param          string customerId
	@return         List<BlAp_SupressContracts>
	@description	This method takes the customerId to return al associated service item and 
					agreed rate  in a combined list of wrapper objects
	Revision(s)		Tarun Gupta -07-03-2018 - Changed relationship query to individual as security classes doesn't support it
	**********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveAgreedRatesNew(string contractId) {
        List<BlAp_CombinedRecord>  AgreedRatesComList = new List<BlAp_CombinedRecord>();
        
        List<Service__c> lstServices = new List<Service__c>();
        List<ServiceItemType__c> lstServiceItemType = new List<ServiceItemType__c>();
        List<ServiceItem__c> serviceItemList = new List<ServiceItem__c>();
        List<Rate__c > ratesList = new List<Rate__c >();
        List<AgreedRate__c > AgreedRatesList = new List<AgreedRate__c>();
        
        Set<Id> setServiceId = new Set<Id>(); 
        Set<Id> setServiceItemTypeId = new Set<Id>(); 
        Set<Id> setServiceItemId = new Set<Id>(); 
        
        try {
            GlUt_Logger.logDebug(DEBUG);
            // Get All service records where Contract__c = contractId
            lstServices = (List<Service__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsService.SERVICEAPINAME, 
                                                                                 serviceFieldList,
                                                                                 contractId, 
                                                                                 GlUt_APIConstantsService.SERVICECONTRACTAPINAME);
            
            //Take set of all Id's of service to get service Item records
            for(Service__c objService : lstServices){
                setServiceId.add(objService.Id);
            }
            
            // Get All service Item Type records where ELIGIBLEFORAGREEDDATEAPINAME = YES
            lstServiceItemType = (List<ServiceItemType__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceItemType.SERVICEITEMTYPEAPINAME, 
                                                                                                serviceItemTypeFieldList,
                                                                                                String.format('WHERE {0} = {1}', 
                                                                                                              new List<String>{
                                                                                                                  GlUt_APIConstantsServiceItemType.ELIGIBLEFORAGREEDDATEAPINAME, 
                                                                                                                      GlUt_FieldSecurity.QuotedString('YES')}));
            
            //Take set of all Id's of service Item type to get service Item records
            for(ServiceItemType__c objServiceItemType : lstServiceItemType){
                setServiceItemTypeId.add(objServiceItemType.Id);
            }
            
            // Get All service Item records
            serviceItemList = (List<ServiceItem__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME, 
                                                                                         serviceItemFieldList,
                                                                                         String.format('WHERE {0} IN {1} AND {2} IN {3}', 
                                                                                                       new List<String>{
                                                                                                           GlUt_APIConstantsServiceItem.SERVICEITEMTYPEAPINAME, 
                                                                                                               GlUt_FieldSecurity.IdsToString(setServiceItemTypeId),
                                                                                                               GlUt_APIConstantsServiceItem.SERVICEAPINAME, 
                                                                                                               GlUt_FieldSecurity.IdsToString(setServiceId)}));
            
            List<Id>serviceItemIds = new List<Id>();
            List<Id>serviceTypeIds = new List<Id>();                    // Added By Ashish on 12/01/2018 ref.AT-1491
            for(ServiceItem__c objServiceItem :serviceItemList){
                serviceItemIds.add(objServiceItem.id);
                serviceTypeIds.add(objServiceItem.ServiceItemType__c);  // Added By Ashish on 12/01/2018 ref.AT-1491
            }
            // Added By Ashish on 12/01/2018 ref.AT-1491
            //**Start Code**// 
            if(serviceTypeIds.size() > 0){
                
                //Query for active(start Date<=ToDay>End Date) rate under service item Type
                ratesList = (List<Rate__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsRate.RATEAPINAME, 
                                                                                rateFieldList,
                                                                                String.format('WHERE {0} IN {1} AND {2} <= TODAY AND {3} > TODAY', 
                                                                                              new List<String>{
                                                                                                  GlUt_APIConstantsRate.SERVICEITEMTYPEAPINAME, 
                                                                                                      GlUt_FieldSecurity.IdsToString(serviceTypeIds),
                                                                                                      GlUt_APIConstantsRate.STARTDATEAPINAME, 
                                                                                                      GlUt_APIConstantsRate.ENDDATEAPINAME}));
                
            }
            
            Map<Id, Rate__c> rateMap = new Map<Id, Rate__c>();
            for(Rate__c rate: ratesList){
                rateMap.put(rate.ServiceItemType__c, rate);
            }
            //**End Code**//
            //Query for all agreed rate under service item
            AgreedRatesList = (List<AgreedRate__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAgreedRate.AGREEDRATEAPINAME, 
                                                                                        agreedRateFieldList,
                                                                                        String.format('WHERE {0} IN {1}', 
                                                                                                      new List<String>{
                                                                                                          GlUt_APIConstantsAgreedRate.SERVICEITEMAPINAME, 
                                                                                                              GlUt_FieldSecurity.IdsToString(serviceItemIds)}));
            
            Map<Id, AgreedRate__c> serItemAggRateMap = new Map<Id, AgreedRate__c>();
            for(AgreedRate__c aggRate: AgreedRatesList){
                serItemAggRateMap.put(aggRate.ServiceItem__c, aggRate);
            }
            for(ServiceItem__c objServiceItem : serviceItemList ){
                AgreedRate__c aggRate = new AgreedRate__c();
                BlAp_CombinedRecord aggContract = new BlAp_CombinedRecord();            
                aggContract.uniqueId=objServiceItem.Id;
                aggContract.isSelected = false;
                aggContract.objectMap = new Map<string, sObject>();
                aggContract.readOnlyFields = new Map<string, boolean>();
                aggContract.objectMap.put(BlAp_Constants.SERVICEITEMNAME , objServiceItem);
                aggContract.objectMap.put(CuAp_Constants.OBJECTAPIRATES , rateMap.get(objServiceItem.ServiceItemType__c));  // Added By Ashish on 12/01/2018 ref.AT-1491
                aggContract.objectMap.put(BlAp_Constants.AGREEDRATESNAME, aggRate);
                AgreedRatesComList.add(aggContract);
            }
            system.debug(JSON.serialize(AgreedRatesComList));
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return AgreedRatesComList;
    }
    
    /**********************************************************************************************
	@author         Accenture: vivek chauhan
	@date           12-Nov-2017
	@param          string AgreedRateString
	@param          string customerId
	@return         string
	@description	This method takes a string to work around lighnting component issue of not
					being able to accept a list paramter.It process and created and update agreed rate records.
	**********************************************************************************************/
    @AuraEnabled
    public static string saveAgreedRate(string AgreedRateString) {   
        //string sOQLQuery ='';
        List<ServiceItem__c> serviceItemList = new List<ServiceItem__c>();
        string retVal = '';
        List<BlAp_CombinedRecord> agreedRateComList = (List<BlAp_CombinedRecord>)JSON.deserialize(AgreedRateString, List<BlAp_CombinedRecord>.class);
        List<AgreedRate__c> agreedRateToInsert= new List<AgreedRate__c>();
        List<AgreedRate__c> agreedRateToUpdate= new List<AgreedRate__c>();
        try {
            //Loop over the list of 
            for(BlAp_CombinedRecord agreedRateCom : agreedRateComList){
                boolean isInsertOrUpdate = agreedRateCom.isSelected;
                AgreedRate__c agreedRate = (AgreedRate__c)agreedRateCom.objectMap.get(BlAp_Constants.AGREEDRATESNAME);
                ServiceItem__c objServiceItem = (ServiceItem__c)agreedRateCom.objectMap.get(BlAp_Constants.SERVICEITEMNAME);
                Rate__c objRate = (Rate__c)agreedRateCom.objectMap.get(CuAp_Constants.OBJECTAPIRATES);       // Added By Ashish on 12/01/2018 ref.AT-1491
                serviceItemList.add(objServiceItem);
                if(isInsertOrUpdate && agreedRate!=null && agreedRate.id == null){
                    agreedRate.ServiceItem__c = objServiceItem.id;
                    agreedRate.RetailAmount__c = objRate.RetailAmount__c;                // Modify By Ashish on 12/01/2018 ref.AT-1491
                    agreedRateToInsert.add(agreedRate);
                }
            } 
            List<Id>serviceItemIds = new List<Id>();
            for(ServiceItem__c objServiceItem :serviceItemList){
                serviceItemIds.add(objServiceItem.id);
            }
            //Query for all agreed rate under service item
            /*
            sOQLQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(agreedRateFieldList,','),
                GlUt_APIConstantsAgreedRate.AGREEDRATEAPINAME +' WHERE ' +
                GlUt_APIConstantsAgreedRate.SERVICEITEMAPINAME  + ' IN: serviceItemIds' + ' order by ' + GlUt_APIConstantsAgreedRate.ENDDATEAPINAME + ' DESC '});			
            
            List<AgreedRate__c > AgreedRatesList = Database.query(sOQLQuery);   
			*/
            //Sudhir - AT-3960: Dynamic SOQL for CuAp_AgreedRatePageCtrlr - Replaced Dynamic SOQL with static SOQL (Security review)
            List<AgreedRate__c > AgreedRatesList = [SELECT Id, Value__c, StartDate__c, EndDate__c, LeapYear__c, ServiceItem__c, AmendedByAgreedRate__c FROM AgreedRate__c
                																		WHERE ServiceItem__c IN: serviceItemIds  ORDER BY  EndDate__c DESC] ;
            
            Map<Id, List<AgreedRate__c>> serItemAggRateMap = new Map<Id, List<AgreedRate__c>>();
            if(AgreedRatesList != null) { // AT-3960
                for(AgreedRate__c aggRate: AgreedRatesList){
                    if(!serItemAggRateMap.containskey(aggRate.ServiceItem__c)){
                        List<AgreedRate__c>lstAgreedRate = new List<AgreedRate__c>();
                        lstAgreedRate.add(aggRate);
                        serItemAggRateMap.put(aggRate.ServiceItem__c, lstAgreedRate);
                    }
                    else if(serItemAggRateMap.containskey(aggRate.ServiceItem__c)){
                        serItemAggRateMap.get(aggRate.ServiceItem__c).add(aggRate);
                    }
                }
            }
            try{
                //Check the field security on the records to be upserted
                agreedRateToInsert = GlUt_FieldSecurity.cleanseFields(agreedRateToInsert, false);
                if(!agreedRateToInsert.isEmpty()){
                    Insert agreedRateToInsert;
                    for(AgreedRate__c agreedRate :agreedRateToInsert){
                        if(serItemAggRateMap!=null && serItemAggRateMap.containsKey(agreedRate.ServiceItem__c) ){
                            for (AgreedRate__c agreedRateext :serItemAggRateMap.get(agreedRate.ServiceItem__c)){
                                if(agreedRateext.EndDate__c!=null && agreedRate.StartDate__c<agreedRateext.EndDate__c){
                                    agreedRateext.AmendedByAgreedRate__c = agreedRate.id;
                                    agreedRateToUpdate.add(agreedRateext);
                                }
                                if(agreedRateext.EndDate__c==null && agreedRate.StartDate__c == system.today() ){
                                    if(agreedRateext.StartDate__c  == system.today()){
                                        agreedRateext.EndDate__c = system.today().addDays(1);
                                        agreedRateToUpdate.add(agreedRateext);
                                    }
                                    else{
                                        agreedRateext.EndDate__c = system.today().addDays(-1);
                                        agreedRateToUpdate.add(agreedRateext);
                                    }
                                }
                                if(agreedRateext.EndDate__c==null && agreedRate.StartDate__c < system.today()){
                                    agreedRateext.EndDate__c = system.today();
                                    agreedRateext.AmendedByAgreedRate__c = agreedRate.id;
                                    agreedRateToUpdate.add(agreedRateext);
                                    
                                }
                            }
                        }
                    }
                    retVal = Label.CuAp_AgreedRate_Sucess;
                }
                if(!agreedRateToUpdate.isEmpty()){
                    agreedRateToUpdate = (List<AgreedRate__c>) GlUt_FieldSecurity.cleanseFields(agreedRateToUpdate, false);
                    Update agreedRateToUpdate;
                    retVal = Label.CuAp_AgreedRate_Sucess;
                }
            }
            catch (Exception ex){
                GlUt_Logger.logException(ex);
                String errormsg = ex.getmessage();
                retVal = errormsg;
                retVal = errormsg.split(':')[1].split(',')[1];
                
            } finally {   
                GlUt_Logger.writeLogsToDatabase();
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return retVal;    
    }
    
	/**********************************************************************************************
	@author         Accenture: vivek chauhan
	@date           14-Nov -2017
	@param          string contractId
	@return         Contract object
	@description    This method takes a string customer id and return contract detail.
	@Revision		By Dependra Singh -01-03-2018 - Added field security. 
	**********************************************************************************************/
    @AuraEnabled
    public static BillingContract__c retrieveContract(string contractId) { 
        BillingContract__c contract;
        try {
            contract = (BillingContract__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsContracts.CONTRACTAPINAME, 
                                                                                    contractId, 
                                                                                    contractListFields);
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        if (contract.Id != null) {
            return contract;
        }
		return null; 
    }
}