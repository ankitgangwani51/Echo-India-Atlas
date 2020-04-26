/******************************************************************************
@author         Echo: Tarun Gupta
@date           30 Jan 2019
@description    AT-4923 , Generate a file of bill data for DHHS accounts
@Revisions		AT-5408,5460
*******************************************************************************/
global with sharing class BlBt_DHHSInvoiceExport extends GlBt_BatchProcess implements Database.Batchable<sObject>, Database.Stateful {
    
    
    global BatchRequestQueue__c batchRequestQueue;
    private String strHeaderData; // String to build Header Data
    private Integer numberOfInvoicesRecords = 0;
    private Decimal sumOfInvoicesTotal = 0.0;
    private String authorityId;
    private String authorityName;
    private String fileData = '';
    @TestVisible private Integer numberOfRecordsProcessed = 0;
    private Set<Id> setBillIdsExportedAndProcessed = new Set<Id>(); // Update Bill Export to Processed
    private Set<Id> setBillIdsToCreateBatchError = new Set<Id>(); // Create Batch error for these
    private Map<Id,BatchError__c> mapBillId2BatchError = new Map<Id,BatchError__c>();
    private static List<string> billFields;
    
    static{
        billFields = new List<string>();
        billFields.add(GlUt_APIConstantsBill.CONTRACTNUMBERAPINAME); 
        billFields.add(GlUt_APIConstantsBill.BILLNUMBERAPINAME); 
        billFields.add(GlUt_APIConstantsBill.BILLDATEAPINAME); 
        billFields.add(GlUt_APIConstantsBill.BILLEDAMOUNTAPINAME); 
        billFields.add(GlUt_APIConstantsBill.TOTALAMOUNTOUTSTANDINGAPINAME); 
        billFields.add(GlUt_APIConstantsBill.CONTRACTLOADREFAPINAME); 
    }
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           30 Jan 2019
    @description    Initialize method 
	@Params 		BatchRequestQueue__c
	@Return			Void
    *******************************************************************************/
    global override void Initialise(BatchRequestQueue__c brq){
        this.batchRequestQueue = brq;
    }
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           30 Jan 2019
    @description    Start method 
	@Params 		Database.BatchableContext
	@Return			All DHHS Bill records
	*******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {   
        
        Set<Id> setDHHSContractIds = new Set<Id>();
        Set<Id> setDHHSBillIds = new Set<Id>();
        string sQuery;
        
        // Update the BRQ status to Processing
        changeBRQStatus(new list<BatchRequestQueue__c> {batchRequestQueue},BlBt_Constants.BRQPROCESSINGSTATUS);
        // Retrieve Custom Meta Data settings
        retrieveCustomDatafromAuthority();
        // Method to build Header string
        buildHeaderString();
        // Retreieve all contracts where owned by is DHHS
        for(BillingContract__c objContractId : [SELECT Id,OwnedBy__c FROM BillingContract__c WHERE OwnedBy__c =: Label.BlAp_ContractOwnedByDHHS]){
            setDHHSContractIds.add(objContractId.Id);
        }
        // Get All Bill exports with status pending and type DHHS linked to DHHS contracts
        for(BillExport__c objBillExport : [SELECT Id,Bill__c,BillingContract__c 
                                           FROM BillExport__c 
                                           WHERE BillingContract__c IN: setDHHSContractIds 
                                           AND Status__c =: Label.BlAp_BillExportStatusPending
                                           AND Type__c =: Label.BlAp_BillExportTypeDHHS]){
                                               setDHHSBillIds.add(objBillExport.Bill__c);
                                           }
        // Query all Bills linked to above bill exporrt records
        sQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(billFields,','), 
            GlUt_APIConstantsBill.BILLAPINAME +' WHERE ' + 
            ' ID ' + ' IN:setDHHSBillIds'});
        
        return Database.getQueryLocator(sQuery);        
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           30 Jan 2019
    @description    Execute method 
	@Params 		Database.BatchableContext , List<Bill__c>
	@Return			Void
	*******************************************************************************/
    global void execute(Database.BatchableContext bc, List<SObject> scope){ 
        try{
            Map<Id,Bill__c> mapBillId2Bill = new Map<Id,Bill__c>();
            Map<Id,Id> mapBillId2BillingContractId = new Map<Id,Id>();
            Map<Id,Id> mapBalanceId2BillId = new Map<Id,Id>();
            Map<Id,Balance__c> mapBillId2Balance = new Map<Id,Balance__c>();
            Map<Id,Id> mapBillContractId2PaymentPlanId = new Map<Id,Id>();
            Map<Id,List<Instalment__c>> mappaymentPlanId2ListInstalments = new Map<Id,List<Instalment__c>>();
            Map<Id,Id> mapContractId2LocationId = new Map<Id,Id>();
            Map<Id,LandTitle__c> mapLocationId2LandTitle = new Map<Id,LandTitle__c>();
            Map<Id,Id> mapLocationId2DeviceId = new Map<Id,Id>();
            Map<Id,List<Reading__c>> mapDeviceId2ListReading = new Map<Id,List<Reading__c>>();
            
            for(Bill__c objBill : (List<Bill__c>) scope){
                //Create Bill Id to Bill object Map
                if(!mapBillId2Bill.containsKey(objBill.Id))
                    mapBillId2Bill.put(objBill.Id, objBill);
                //Create Bill Id to Contract Id Map
                if(!mapBillId2BillingContractId.containsKey(objBill.Id))
                    mapBillId2BillingContractId.put(objBill.Id, objBill.BillingContract__c);
            }
            for(BalanceTransaction__c objBT : [SELECT Id,Balance__c,Bill__c FROM BalanceTransaction__c WHERE Bill__c IN: mapBillId2Bill.keySet()]){
                //Create Balance Id to Bill Id Map
                if(!mapBalanceId2BillId.containsKey(objBT.Balance__c))
                    mapBalanceId2BillId.put(objBT.Balance__c, objBT.Bill__c);
            }            
            Map<Id, Balance__c> mapBalanceId2Balance = new Map<Id, Balance__c>([SELECT Id,Name,BalanceSnapshot__c
                                                                                FROM Balance__c 
                                                                                WHERE Id IN :mapBalanceId2BillId.keyset()]);
            
            for(Id objBalanceId : mapBalanceId2BillId.keyset()){                
                //Create Bill Id to Balance object Map
                if(!mapBillId2Balance.containsKey(mapBalanceId2BillId.get(objBalanceId)))
                    mapBillId2Balance.put(mapBalanceId2BillId.get(objBalanceId), mapBalanceId2Balance.get(objBalanceId));
            }
            Map<Id, BillingContract__c> mapContractId2BillingContract = new Map<Id, BillingContract__c>([SELECT Id,Name,BillingStreet__c,BillingCity__c,BillingPostalCode__c 
                                                                                                         FROM BillingContract__c 
                                                                                                         WHERE ID IN: mapBillId2BillingContractId.values()]);
            
            for(PaymentPlan__c objPayPlan : [SELECT Id,Name,Active__c,BillingContract__c FROM PaymentPlan__c WHERE BillingContract__c IN: mapContractId2BillingContract.keyset() AND Active__c = true]){
                //Create Contract Id to Payment Plan Id Map
                if(!mapBillContractId2PaymentPlanId.containsKey(objPayPlan.BillingContract__c))
                    mapBillContractId2PaymentPlanId.put(objPayPlan.BillingContract__c,objPayPlan.Id);
            }
            for(Instalment__c objInstalment : [SELECT Id,Name,PaymentPlan__c,InstalmentAmountDue__c,InstalmentAmountOutstanding__c,InstalmentDueDate__c FROM Instalment__c WHERE PaymentPlan__c IN: mapBillContractId2PaymentPlanId.values() ORDER BY InstalmentDueDate__c]){
                //Create Payment plan Id to List <Instalment__c> Map
                if (!mappaymentPlanId2ListInstalments.containsKey(objInstalment.PaymentPlan__c)) {
                    mappaymentPlanId2ListInstalments.put(objInstalment.PaymentPlan__c, new List <Instalment__c>());
                }
                mappaymentPlanId2ListInstalments.get(objInstalment.PaymentPlan__c).add(objInstalment);
            }
            for(Service__c objService : [SELECT Supplypoint__c, Supplypoint__r.Location__c,BillingContract__c FROM Service__c WHERE BillingContract__c IN :mapContractId2BillingContract.keyset()]){
                //Create Contract Id to Location Id Map
                if(!mapContractId2LocationId.containsKey(objService.BillingContract__c))
                    mapContractId2LocationId.put(objService.BillingContract__c,objService.supplypoint__r.location__c);
            }
            for(LandTitle__c objLandTitle : [SELECT Id,FolioNumber__c,Location__c,VolumeNumber__c FROM LandTitle__c WHERE Location__c IN: mapContractId2LocationId.values()]){
                //Create Location Id to Land Title Map
                if(!mapLocationId2LandTitle.containsKey(objLandTitle.Location__c))
                    mapLocationId2LandTitle.put(objLandTitle.Location__c, objLandTitle);
            }
            Map<Id, SupplyPointDevice__c> supplyPointDeviceMap = new Map<Id, SupplyPointDevice__c>([select Id,Device__c ,SupplyPoint__c,SupplyPoint__r.Location__c
                                                                                                    from SupplyPointDevice__c 
                                                                                                    where SupplyPoint__r.Location__c IN : mapContractId2LocationId.values()
                                                                                                    And Active__c = true]);
            for(SupplyPointDevice__c supplyPointDeviceObj : supplyPointDeviceMap.values()) {
                //Create Location Id to Device Id Map
                if(!mapLocationId2DeviceId.containsKey(supplyPointDeviceObj.SupplyPoint__r.Location__c))
                    mapLocationId2DeviceId.put(supplyPointDeviceObj.SupplyPoint__r.Location__c,supplyPointDeviceObj.Device__c);
            }
            Map<Id, Device__c> mapDeviceId2Device = new Map<Id, Device__c>([SELECT Id,Name 
                                                                            FROM Device__c 
                                                                            WHERE ID IN: mapLocationId2DeviceId.values()]);
            
            for(Reading__c objReading : [SELECT Id,Name,Billed__c,Device__c,ReadingDate__c,ActualDeviceReading__c FROM Reading__c 
                                         WHERE Device__c IN: mapLocationId2DeviceId.values() AND Billed__c = true
                                         ORDER BY ReadingDate__c DESC]){
                                             //Create Device Id to List Reading Map
                                             if (!mapDeviceId2ListReading.containsKey(objReading.Device__c)) {
                                                 mapDeviceId2ListReading.put(objReading.Device__c, new List<Reading__c>());
                                             }
                                             mapDeviceId2ListReading.get(objReading.Device__c).add(objReading);
                                         }
            
            //Add Header data to file data - File Header
            fileData += strHeaderData;
            
            List<BillItem__c> listAllBillItems = [SELECT Id,Name,Bill__c,BillServiceType__c,StartDate__c,EndDate__c,NetConsumption__c,
                                                  Rate__r.RetailAmount__c,NetBilledAmount__c,Reading__c ,ServiceItem__r.ServiceItemType__r.DHHSAuthorityCode__c
                                                  FROM BillItem__c WHERE Bill__c IN: mapBillId2Bill.keySet()];
            for(Bill__c objBill : (List<Bill__c>) scope){
                numberOfRecordsProcessed += 1;
                Id payPlanId;
                Id contractId;
                List<Instalment__c> listInstalments = new List<Instalment__c>();
                
                contractId = mapBillId2BillingContractId.get(objBill.Id);
                
                if(mapBillContractId2PaymentPlanId.containsKey(contractId))
                    payPlanId = mapBillContractId2PaymentPlanId.get(contractId);
                
                listInstalments = mappaymentPlanId2ListInstalments.containsKey(payPlanId) ? mappaymentPlanId2ListInstalments.get(payPlanId) : null;
                //Add bill details to file - Invoice Detail
                String strInvoiceData = buildInvoiceHeaderString(objBill,mapBillId2Balance.get(objBill.Id),mapContractId2BillingContract.get(contractId),listInstalments);
                if(strInvoiceData == null){
                    setBillIdsToCreateBatchError.add(objBill.Id); // Create Batch Error for these
                    //Skip this record and do not process this record
                    continue;
                }   
                setBillIdsExportedAndProcessed.add(objBill.Id); // Update Bill Export to Processed
                fileData += strInvoiceData;
                for(BillItem__c objBillItem : listAllBillItems){
                    if(objBillItem.Bill__c == objBill.Id){
                        
                        Id deviceId;
                        Device__c objDevice = new Device__c();
                        List<Reading__c> listReadings = new List<Reading__c>();
                        LandTitle__c objLandTitle = new LandTitle__c();
                        Id locationId = mapContractId2LocationId.get(contractId);
                        
                        if(mapLocationId2LandTitle.containsKey(locationId))
                            objLandTitle = mapLocationId2LandTitle.get(locationId);
                        
                        if(mapLocationId2DeviceId.containsKey(locationId))
                            deviceId = mapLocationId2DeviceId.get(locationId);
                        
                        if(deviceId != null && mapDeviceId2Device.containsKey(deviceId))
                            objDevice = mapDeviceId2Device.get(deviceId);
                        
                        if(deviceId != null && mapDeviceId2ListReading.containsKey(deviceId))
                            listReadings = mapDeviceId2ListReading.get(deviceId);
                        
                        //Add billItem details to file - Invoice Header
                        fileData += buildInvoiceDetailString(mapBillId2Bill.get(objBillItem.Bill__c), objBillItem,objLandTitle, objDevice, listReadings);
                    }
                }
                //Add bill details to file - Invoice trailer
                fileData += buildInvoiceTrailerString(objBill);
            }
            //Add File traile to file - File trailer
            fileData += buildFileTrailerString();
            //Add File free text to file - File free text
            fileData += buildFileFreeTextString();
        }
        catch (exception e){
            changeBRQStatus(new list<BatchRequestQueue__c> {batchRequestQueue},BlBt_Constants.BRQSTATUSERRORS);
            GlUt_Logger.logException(e);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        } 
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           30 Jan 2019
    @description    Finish method 
	@Params 		Database.BatchableContext
	@Return			Void
	*******************************************************************************/
    global void finish(Database.BatchableContext bc){
        Savepoint sp = Database.setSavepoint();
        try{
            //Build the content document file and link to BRQ record
            buildContentDocument(fileData);
            
            List<BillExport__c> listBillExportToUpdate = new List<BillExport__c>();
            List<BatchError__c> listBatchErrorsToCreate = new List<BatchError__c>();
            Map<Id,BatchError__c> mapBillExportId2BatchError = new Map<Id,BatchError__c>();
            
            List<BillExport__c> listAllBillExport = new List<BillExport__c>();
            listAllBillExport = [SELECT Id,Name,Bill__c,Status__c FROM BillExport__c 
                                 WHERE Status__c =: Label.BlAp_BillExportStatusPending
                                 AND Type__c =: Label.BlAp_BillExportTypeDHHS
                                 AND (Bill__c IN: setBillIdsExportedAndProcessed
                                      OR Bill__c IN: setBillIdsToCreateBatchError)];
            
            for(BillExport__c objBillExport : listAllBillExport){
                //Update Status to processed
                if(setBillIdsExportedAndProcessed.contains(objBillExport.Bill__c)){
                    objBillExport.Status__c = BlBt_Constants.BILL_EXPORT_PROCESSEDSTATUS;
                    listBillExportToUpdate.add(objBillExport);
                }
                //Create BatchError__c for error records
                if(setBillIdsToCreateBatchError.contains(objBillExport.Bill__c) && mapBillId2BatchError.containsKey(objBillExport.Bill__c)){
                    //To create link between bill export and batch error
                    if(!mapBillExportId2BatchError.containsKey(objBillExport.Id))
                        mapBillExportId2BatchError.put(objBillExport.Id,mapBillId2BatchError.get(objBillExport.Bill__c));
                }
            }
            if(!mapBillExportId2BatchError.values().isEmpty()){
                listBatchErrorsToCreate = mapBillExportId2BatchError.values() ;
                listBatchErrorsToCreate = (List<BatchError__c>) GlUt_FieldSecurity.cleanseFields(listBatchErrorsToCreate, false);
                insert listBatchErrorsToCreate;
            }
            for(BillExport__c objBillExport : listAllBillExport){
                //Create BatchError__c for error records
                if(setBillIdsToCreateBatchError.contains(objBillExport.Bill__c) && mapBillId2BatchError.containsKey(objBillExport.Bill__c)){
                    //To create link between bill export and batch error
                    if(mapBillExportId2BatchError.containsKey(objBillExport.Id)){
                        objBillExport.BatchError__c = mapBillExportId2BatchError.get(objBillExport.Id).Id;
                        listBillExportToUpdate.add(objBillExport);
                    }
                }
            }
            if(!listBillExportToUpdate.isEmpty()){
                listBillExportToUpdate = (List<BillExport__c>) GlUt_FieldSecurity.cleanseFields(listBillExportToUpdate, false);
                update listBillExportToUpdate;
            }
        }
        catch (exception e){
            changeBRQStatus(new list<BatchRequestQueue__c> {batchRequestQueue},BlBt_Constants.BRQSTATUSERRORS);
            GlUt_Logger.logException(e);
            Database.rollback(sp);
        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		06 Feb 2019
    @description    Get the custom data
	*******************************************************************************/
    public void retrieveCustomDatafromAuthority(){ 
        DHHS__c objDHHS = DHHS__c.getOrgDefaults();
        if(objDHHS != null){
            authorityId = String.valueOf(objDHHS.AuthorityID__c).substringBefore('.');
            authorityName = String.valueOf(objDHHS.AuthorityName__c);
        }
    }
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		06 Feb 2019
    @param			List BRQ, String Status
    @return			List<BatchRequestQueue__c>
    @description 	Change the BRQ status 
    *******************************************************************************/
    public static list<BatchRequestQueue__c> changeBRQStatus(list<BatchRequestQueue__c> batchRequestQueueList , String Status){
        
        set<Id> setBRQIds = new set<Id>() ;
        list<BatchRequestQueue__c> listBatchRequestQueueToUpdate = new list<BatchRequestQueue__c>() ;
        for(BatchRequestQueue__c brq : batchRequestQueueList) {
            setBRQIds.add(brq.Id) ;
        }
        for(BatchRequestQueue__c brq :  [Select id,Status__c from BatchRequestQueue__c where Id IN: setBRQIds]) {
            brq.Status__c = Status ;
            listBatchRequestQueueToUpdate.add(brq) ;
        }
        if(!listBatchRequestQueueToUpdate.isEmpty() && listBatchRequestQueueToUpdate.size() > 0){
            listBatchRequestQueueToUpdate = (List<BatchRequestQueue__c>)GlUt_FieldSecurity.cleanseFields(listBatchRequestQueueToUpdate,false);
            update listBatchRequestQueueToUpdate;
        }
        return listBatchRequestQueueToUpdate;
    }
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		30 Jan 2019
    @description 	Create header of file of bill data for DHHS Accounts
	@return			Void
	******************************************************************************
	Field No. 	Field Name								Length

	1  			Record Type - 1	 						1
    2  			Authority Id\ Number					5
    3		    Authority Name							30
    *******************************************************************************/
    public void buildHeaderString(){
        try{
            // Record Type - 1 for Header
            strHeaderData = BlBt_Constants.DHHS_RECORDTYPE_1; 
            strHeaderData += buildPaddingString(authorityId,true,5,BlBt_Constants.SPACE,true); // authority Id
            strHeaderData += buildPaddingString(authorityName,true,30,BlBt_Constants.SPACE,true); // authority Name
            strHeaderData += '\r\n'; // Added next line for the next record
        }catch (exception e){
            changeBRQStatus(new list<BatchRequestQueue__c> {batchRequestQueue},BlBt_Constants.BRQSTATUSERRORS);
            GlUt_Logger.logException(e);           
        }
    }
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		30 Jan 2019
    @description 	Create Invoice header of file of bill data for DHHS Accounts

	******************************************************************************
	Field No. 	Field Name								Length

	1  			Record Type - 2	 						1
    2  			Invoice number(Bill Id\ Number)			20
    3		    Description(Blank)						30
	4  			Opening Balance(Balance Snapshot)		10
    5  			Invoice Date(Bill Date)					10
    6		    Invoice Total(Amount Outstanding)		10
	7 			Due date(1st Instalment Sue Date)		10
    8  			Authority Property identifier(Cont Id)	20
    9		    Street number(Blank)					20
	10  		Street Name(Billing Street)				30
    11  		Suburb Name(City)						30
    12		    Post Code								7
	13  		Numnber Of Instalments					2
    14		    Instalment 1 Amount						10
	15		    Instalment 2 Amount						10
	16		    Instalment 3 Amount						10
	17		    Instalment 4 Amount						10
	18		    Instalment 5 Amount						10
	19		    Instalment 6 Amount						10
	20		    Instalment 7 Amount						10
	21		    Instalment 8 Amount						10
	22		    Instalment 9 Amount						10
    23		    Instalment 10 Amount					10
    24		    Instalment 11 Amount					10
    25		    Instalment 12 Amount					10
	*******************************************************************************/
    public String buildInvoiceHeaderString(Bill__c objBill, Balance__c objBalance, BillingContract__c objContract, List<Instalment__c> listInstalments){
        
        String errorReason = '';
        Boolean error = false;
        // Record Type - 2 for Invoice Header
        String strInvoiceHeaderData = BlBt_Constants.DHHS_RECORDTYPE_2;
        
        strInvoiceHeaderData += buildPaddingString(objBill.Name,true,20,BlBt_Constants.SPACE,true); // Invoice number
        strInvoiceHeaderData = strInvoiceHeaderData.rightPad(51,BlBt_Constants.SPACE); // Added 30 spaces extra for description
        
        //Return null if any of the below mandatory field is null
        if(objBalance == null || objBalance.BalanceSnapshot__c == null){
            error = true;
            errorReason = Label.BlBt_NoOpeningBalance;
        }
        if(objBill.BillDate__c == null){
            error = true;
            errorReason = Label.BlBt_NoInvoiceDate;
        }
        if(objBill.TotalAmountOutstanding__c == null){
            error = true;
            errorReason = Label.BlBt_NoInvoiceTotal;
        }
        if(objBill.BillingContract__c == null){
            error = true;
            errorReason = Label.BlBt_NoPropIdentifier;
        }
        if(objContract.BillingStreet__c == null){
            error = true;
            errorReason = Label.BlBt_NoBillingStreet;
        }
        if(objContract.BillingCity__c == null){
            error = true;
            errorReason = Label.BlBt_NoBillingCity;
        }
        if(objContract.BillingPostalCode__c == null){
            error = true;
            errorReason = Label.BlBt_NoBillingPostCode;
        }
        if(error){
            if(!mapBillId2BatchError.containsKey(objBill.Id))
                mapBillId2BatchError.put(objBill.Id, createBatchError(errorReason, objBill.Id));
            return null;
        }
        strInvoiceHeaderData += buildPaddingString(String.valueOf(objBalance.BalanceSnapshot__c),true,10,BlBt_Constants.ZERO,false); // Opening Balance        
        strInvoiceHeaderData += buildPaddingString(String.valueOf(objBill.BillDate__c),true,10,BlBt_Constants.SPACE,true); // Invoice Date
        strInvoiceHeaderData += buildPaddingString(String.valueOf(objBill.TotalAmountOutstanding__c),true,10,BlBt_Constants.ZERO,false); // Invoice Total
        
        if(listInstalments != null && listInstalments.size() > 0)
            strInvoiceHeaderData += buildPaddingString(String.valueOf(listInstalments[0].InstalmentDueDate__c),true,10,BlBt_Constants.SPACE,true);  //Due date
        else
            strInvoiceHeaderData += buildPaddingString('',true,10,BlBt_Constants.SPACE,false);  //Due date
        
        strInvoiceHeaderData += objBill.BillingContract__r.LoadReference__c != null ? buildPaddingString(String.valueOf(objBill.BillingContract__r.LoadReference__c),true,20,BlBt_Constants.SPACE,false) : buildPaddingString('',true,20,BlBt_Constants.SPACE,false);  // authority Property Identifier
        strInvoiceHeaderData = strInvoiceHeaderData.rightPad(131,BlBt_Constants.SPACE); // Added 20 spaces extra for Street Number
        
        String streetAddress = '';
        if(objContract.BillingStreet__c != null){
            streetAddress = objContract.BillingStreet__c.replace('\r\n',BlBt_Constants.SPACE);
            streetAddress = streetAddress.length() > 30 ? streetAddress.substring(0,30) : streetAddress; // Street Name
        }
        strInvoiceHeaderData += buildPaddingString(streetAddress,true,30,BlBt_Constants.SPACE,false);  //Street Name
        
        String cityName = '';
        if(objContract.BillingCity__c != null){
            cityName = objContract.BillingCity__c.replace('\r\n',BlBt_Constants.SPACE);
            cityName = cityName.length() > 30 ? cityName.substring(0,30) : cityName; // BillingCity__c
        }
        strInvoiceHeaderData += buildPaddingString(cityName,true,30,BlBt_Constants.SPACE,false);  //City
        
        String billingPostCode = '';
        if(objContract.BillingPostalCode__c != null){
            billingPostCode = objContract.BillingPostalCode__c.replace('\r\n',BlBt_Constants.SPACE);
            billingPostCode = billingPostCode.length() > 7 ? billingPostCode.substring(0,7) : billingPostCode; // Street number
        }
        strInvoiceHeaderData += buildPaddingString(billingPostCode,true,7,BlBt_Constants.SPACE,false);  //Post Code
        
        if(listInstalments == null || listInstalments.size() == 0){
            strInvoiceHeaderData += buildPaddingString('',true,2,BlBt_Constants.ZERO,false);  // Number Of Instalments
            strInvoiceHeaderData = strInvoiceHeaderData.rightPad(320,BlBt_Constants.SPACE); // Add 12*10 spaces if number of Instalments = 0
        }
        else{
            strInvoiceHeaderData += buildPaddingString(String.valueOf(listInstalments.size()),true,2,BlBt_Constants.ZERO,false);  // Number Of Instalments
            for(Integer iCount =0 ; iCount < 12 ; iCount++){
                String instalmentAmountDue = ''; 
                if(listInstalments.size() > iCount && listInstalments[iCount] != null){
                    instalmentAmountDue = String.valueOf(listInstalments[iCount].InstalmentAmountOutstanding__c);
                }
                else{
                    //instalmentAmountDue = instalmentAmountDue.leftPad(10, BlBt_Constants.ZERO);
                }
                strInvoiceHeaderData += buildPaddingString(instalmentAmountDue,true,10,BlBt_Constants.ZERO,false);  
            }
        }    
        
        numberOfInvoicesRecords +=1;
        sumOfInvoicesTotal += objBill.TotalAmountOutstanding__c;
        strInvoiceHeaderData += '\r\n'; // Added next line for the next record
        return strInvoiceHeaderData;
    }
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		04 Feb 2019
    @description 	Create Invoice detail of file of bill data for DHHS Accounts
	******************************************************************************
	Field No. 	Field Name								Length

	1  			Record Type - 3	 						1
    2  			Invoice number(Bill Id\ Number)			20
    3		    Charge Code(Service Type)				20
	4  			Start Date								10
	5			End Date								10
	6			Number Of Units(NetConsumption__c)		10
	7			Charge Rate(RetailAmount__c)			10
	8			Charge Amount(NetBilledAmount__c)		10
	9			Volume Number(Land Title)				5
	10			Folio Number(Land Title)				5
	11			Meter\Device Number						20
	12			Previous Meter Reading					20
	13			Current Meter Reading					20
	*******************************************************************************/
    public String buildInvoiceDetailString(Bill__c objBill, BillItem__c objBillItem, LandTitle__c objLandTitle, Device__c objDevice, List<Reading__c> listReadings){
        // Record Type - 3 for Invoice detail
        String strInvoiceDetailData = BlBt_Constants.DHHS_RECORDTYPE_3;
        
        strInvoiceDetailData += buildPaddingString(objBill.Name,true,20,BlBt_Constants.SPACE,true); // Invoice number
        strInvoiceDetailData += buildPaddingString(objBillItem.ServiceItem__r.ServiceItemType__r.DHHSAuthorityCode__c,true,20,BlBt_Constants.SPACE,false); // charge Code
        strInvoiceDetailData += buildPaddingString(String.valueOf(objBillItem.StartDate__c),true,10,BlBt_Constants.SPACE,true); // Start Date
        strInvoiceDetailData += buildPaddingString(String.valueOf(objBillItem.EndDate__c),true,10,BlBt_Constants.SPACE,true); // End Date
        strInvoiceDetailData += objBillItem.NetConsumption__c != null ? buildPaddingString(String.valueOf(objBillItem.NetConsumption__c),true,10,BlBt_Constants.ZERO,false) : buildPaddingString('',true,10,BlBt_Constants.ZERO,false); //Number of units
        strInvoiceDetailData += objBillItem.Rate__r.RetailAmount__c != null ? buildPaddingString(String.valueOf(objBillItem.Rate__r.RetailAmount__c),true,10,BlBt_Constants.ZERO,false) : buildPaddingString('',true,10,BlBt_Constants.ZERO,false); // Charge Rate
        strInvoiceDetailData += objBillItem.NetBilledAmount__c != null ? buildPaddingString(String.valueOf(objBillItem.NetBilledAmount__c),true,10,BlBt_Constants.ZERO,false) : buildPaddingString(String.valueOf(''),true,10,BlBt_Constants.ZERO,false); // Charge Amount
        
        if(objLandTitle != null){
            String volumeNumber = objLandTitle.VolumeNumber__c != null ? objLandTitle.VolumeNumber__c : ''; //Volume number
            volumeNumber = volumeNumber.replace('\r\n',BlBt_Constants.SPACE);
            strInvoiceDetailData += buildPaddingString(volumeNumber,true,5,BlBt_Constants.SPACE,true); 
            
            String folioNumber = objLandTitle.FolioNumber__c != null ? objLandTitle.FolioNumber__c : ''; //Folio number
            folioNumber = folioNumber.replace('\r\n',BlBt_Constants.SPACE);
            strInvoiceDetailData += buildPaddingString(folioNumber,true,5,BlBt_Constants.SPACE,true); 
        }
        else{ // Added 10 spaces id land title is not present
            String landTitle = '';
            strInvoiceDetailData += buildPaddingString(landTitle,true,10,BlBt_Constants.SPACE,false); 
        }
        
        if(objDevice != null){ // Measured
            strInvoiceDetailData += buildPaddingString(objDevice.Name,true,20,BlBt_Constants.SPACE,false); 
            if(listReadings != null && listReadings.size() > 0 && objBillItem.Reading__c != null){
                String actualReading = '';
                String previousReading = '';
                Integer iCount = 0;
                for(Reading__c objReading : listReadings){
                    iCount+= 1;
                    if(objBillItem.Reading__c == objReading.Id){ // This is current Reading
                        actualReading = objReading.ActualDeviceReading__c;
                        break;
                    }
                }
                if(listReadings.size() > 1 && iCount <= listReadings.size()){ 
                    previousReading = listReadings[iCount - 1].ActualDeviceReading__c;
                }
                strInvoiceDetailData += buildPaddingString(previousReading,true,20,BlBt_Constants.ZERO,false); 
                strInvoiceDetailData += buildPaddingString(actualReading,true,20,BlBt_Constants.ZERO,false); 
            }
            else{ // No readings , so add 40 spaces for current and previous reading
                String readingDetails = '';
                strInvoiceDetailData += buildPaddingString(readingDetails,true,40,BlBt_Constants.SPACE,false); 
            }
        }
        else{// Add spaces for meter number(20), previous(20) and current readings(20)
            String deviceDetails = '';
            strInvoiceDetailData += buildPaddingString(deviceDetails,true,60,BlBt_Constants.SPACE,false); 
        }
        strInvoiceDetailData += '\r\n'; // Added next line for the next record
        return strInvoiceDetailData;
    }
    
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		05 Feb 2019
    @description 	Create Invoice Trailer of file of bill data for DHHS Accounts
    ******************************************************************************
	Field No. 	Field Name								Length

	1  			Record Type - 4	 						1
    2  			Invoice number(Bill Id\ Number)			20
    3		    Description - Free Text					260
	*******************************************************************************/
    public String  buildInvoiceTrailerString(Bill__c objBill){
        // Record Type - 4 for Invoice Trailer
        String strInvoiceTrailerData = BlBt_Constants.DHHS_RECORDTYPE_4;
        strInvoiceTrailerData += buildPaddingString(objBill.Name,true,20,BlBt_Constants.SPACE,true); // Invoice number
        strInvoiceTrailerData = strInvoiceTrailerData.rightPad(281,BlBt_Constants.SPACE); // Added 260 spaces extra as free text
        strInvoiceTrailerData += '\r\n';
        return strInvoiceTrailerData;
    }
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		05 Feb 2019
    @description 	Create File Trailer of file of bill data for DHHS Accounts

	******************************************************************************
	Field No. 	Field Name								Length

	1  			Record Type - 5	 						1
    2  			Number Of Invoices						5
    3		    Invoices Total							10
	*******************************************************************************/
    public String  buildFileTrailerString(){        
        // Record Type - 5 for File Trailer
        String strFileTrailerData = BlBt_Constants.DHHS_RECORDTYPE_5;
        strFileTrailerData += buildPaddingString(String.valueOf(numberOfInvoicesRecords),true,5,BlBt_Constants.ZERO,false ); // No. of invoices
        strFileTrailerData += buildPaddingString(String.valueOf(sumOfInvoicesTotal),true,10,BlBt_Constants.ZERO ,false); // Sum of invoices
        strFileTrailerData += '\r\n'; // Added next line for the next record
        return strFileTrailerData;
    }
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		05 Feb 2019
    @description 	Create File free text of file of bill data for DHHS Accounts

	******************************************************************************
	Field No. 	Field Name								Length

	1  			Record Type - 6							1
    2  			Free Text								
	*******************************************************************************/
    public String buildFileFreeTextString(){
        // Record Type - 6 for File Free Text
        String strFileFreeTextData = BlBt_Constants.DHHS_RECORDTYPE_6;
        strFileFreeTextData += '\r\n';
        return strFileFreeTextData;
    }
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		05 Feb 2019
    @description 	Method to create generic padded string
	*******************************************************************************/
    public String buildPaddingString(String strData, Boolean isLeftPad, Integer paddingSize, String zeroOrSpace, Boolean isSubstring){
        if(strData == null)
            strData = '';
        
        if(isSubstring)
            strData = strData.length() > paddingSize ? strData.substring(0,paddingSize) : strData;
        
        if(isLeftPad){
            strData = strData.leftPad(paddingSize,zeroOrSpace);
        }
        return strData;
    }
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		06 Feb 2019
    @description    Build the content document file and link to BRQ record
	*******************************************************************************/
    public void buildContentDocument(String fileData){ 
        
        String seqNumber = '';
        String txtFileData = '';
        List<BatchRequestQueue__c> listBRQ = [SELECT Id,Name,BatchProcess__c FROM BatchRequestQueue__c WHERE BatchProcess__c =: batchRequestQueue.BatchProcess__c AND createdDate = today];
        if(listBRQ != null && listBRQ.size() > 0)
            seqNumber = buildPaddingString(String.valueOf(listBRQ.size()),true,2,BlBt_Constants.ZERO,true); 
        else
            seqNumber = BlBt_Constants.DHHS_TXTFILE_SEQNO;
        
        //Create .pre file
        String fileName = buildPaddingString(authorityId,true,5,BlBt_Constants.ZERO,true); // authority Id
        DateTime currentDateTime = System.now();
        String formattedPDate = currentDateTime.format(BlBt_Constants.DHHS_FILE_FORMAT); 
        fileName += formattedPDate + seqNumber + BlBt_Constants.PRE_FILE_EXTENSION; 
        // It means no record is processed
        if(fileData == ''){
            fileData = Label.BlBt_TextFileData + String.valueOf(numberOfRecordsProcessed);
        }
        Id contentDocumentId = GlUt_ContentDocument.saveLinkedDocument(batchRequestQueue.Id, BlBt_Constants.DHHS_INVOICE_EXPORT, fileName, fileName, BlBt_Constants.SHARE_TYPE, blob.valueOf(fileData));
        
        //Create .txt file
        String txtFileName = Label.BlBt_TextFileLabel + '_' + currentDateTime.format(BlBt_Constants.DHHS_EXPORT_FILE_FORMAT) + BlBt_Constants.TXT_FILE_EXTENSION;
        
        txtFileData = Label.BlBt_TextFileData + String.valueOf(numberOfRecordsProcessed);
        Id contentDocumentTxtId = GlUt_ContentDocument.saveLinkedDocument(batchRequestQueue.Id, BlBt_Constants.DHHS_INVOICE_EXPORT, txtFileName, txtFileName, BlBt_Constants.SHARE_TYPE, blob.valueOf(txtFileData));
        
        changeBRQStatus(new list<BatchRequestQueue__c> {batchRequestQueue},BlBt_Constants.BRQSTATUS);
    }
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		06 Feb 2019
    @description 	Method to create Bath Error
	*******************************************************************************/
    public BatchError__c createBatchError(String errorReason, Id billId){
        BatchError__c objBatchError = new BatchError__c(
            BatchRequestQueue__c = batchRequestQueue.Id,
            ErrorDetails__c = errorReason,
            BatchRequestOperation__c= BlBt_Constants.DHHS_BATCH_REQ_OPERATION,
            BatchRequestType__c = BlBt_Constants.DHHS_BATCH_REQ_TYPE,
            OperatingRecordId__c = billId);
        
        return objBatchError;
    }
}