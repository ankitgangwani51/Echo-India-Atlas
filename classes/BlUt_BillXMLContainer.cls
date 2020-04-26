/**********************************************************************************************
@author         Echo: Sudhir Kumar
@date           04 June 2018
@description    A data transfer object (DTO) class used to create an instance 
                of the data extracted from Salesforce records to format the 
                XML message which is passed to the AWS S3 "echo-data-transfer-xml" bucket
Revision(s)     Amit K. AU2 (AT-4475) 20 Dec 2018 
Revision(s)     Tarun Gupta , AT_4858 , Added DPID fields
***********************************************************************************************/

/************************************************************************************************
Object Hierarchy
----------------
-> Bills (root tag)
    ->  Bill__c (Bill)* - (where Data XML file checkbox is not checked)
            ->  PdfTemplateName - (Retrieve using the latest ‘Pending’ Billing Event)
            ->  XsltName    - (Retrieve using the latest ‘Pending’ Billing Event)
            ->  Account (Account)   
            ->  BillingContract__c (Contract)  - (Retrieve ‘Last Printed Bill Date" per contract)
                ->  Payment__c  - (Payment Date is greater than or equal to the "Last Printed Bill Date")
                ->  Contract Bill Message   - (only Active one to include)
            ->  Balance__c (Balance)
            ->  PaymentPlan__c (PaymentPlan)
                ->  Instalment__c (Instalment)
            ->  RuralEntitlement (Rural Entitlement)
            ->  BillItem__c(BillItem)**
                ->  ServiceItemType__c (Service Item Type)
                ->  ServiceItemFamily__c (Service Item Family)
                ->  Rate__c (Rate) 
                ->  ServiceMessage__c (Service Messages) - (only active one to include)
                ->  SupplyPoint__c (SupplyPoint)
                    ->  SupplyPointDevice__c (SupplyPointDevice)
                        ->  AverageDailyUsage__c (AverageDailyUse) - (last 18 months)
                    ->  Location__c (Location)
                        ->  LocationOccupant__c (LocationOccupant)  - (Start Date is greater than or equal to the Contract Start Date and Location Occupant End Date is greater than or equal to Bill Item End Date or null)
                ->  Device__c (Device)
                    ->  Reading__c (Reading) - (Reading Date is greater than or equal to the "Last Printed Bill Date")
                ->  Agreed_Volume(AgreedVolume)   //AT-3166
                    ->  AgreedVolume__c         
                ->  StandardSampleStrength__c(StandardSampleStrength) //AT-3166
                    ->  SSStandardStrength__c     
                    ->  CODStandardStrength__c
            ->  BillItem__c(BillItem)**
    ->  Bill__c (Bill)*
-> Bills (root tag)
************************************************************************************************/

public class BlUt_BillXMLContainer implements GlUt_DataTransferXmlInterface { // AU1: AT-4098
    
    private static final String CLASS_NAME = 'BlUt_BillXMLContainer';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    // utility methods used to format date and datetime fields for json as yyyy-MM-dd HH:mm:ss
    private static String dateToString(Date d) {return d != null ? String.valueOf(d) + ' 00:00:00' : null;}        
    public Bills data {get; private set;}  // structured wrapper data
    public String XML {get;  private set;} // XML of structured data
    // the records required for the data payload
    private List<BillingContract__c> contracts;
    private map<Id, Date> mapContractId2LastPrintedBilldate  ;  //Last Printed Bill Date for each Contract
    private map<Id, Id> mapBillId2ContractId ;
    private map<Id, list<Payment__c>> mapContractd2ListPayments ;
    private Map<Id, List<BalanceTransaction__c>> mapPaymentIdToBalanceTransactions; //AT-4017
    private Map<Id, List<BillItem__c>> mapBillId2ListBillItem ;
    private map<Id, Id> mapBillItemId2ServiceTypeId ;
    private Map<Id, List<ContractBillMessage__c>> mapContractId2BillMessage; // AT-3046
    private Map<Id,List<PaymentPlan__c>> mapBillId2ListPaymentPlan ;
    private Map<Id, SupplyPointDevice__c>  mapBillItemId2SpdAndAdu ;
    private map<Id, Id> mapBillItemId2SupplyPointLocation ;
    private Map<Id,list<Location__c>> mapBillItemId2Listlocation ;
    private map<Id, Id> mapBillItemId2SupplyPointlocationId  ;
    private map<Id, set<Id>> mapBillItemId2SetDeviceId  ;   
    private map<Id, List<Device__c>> mapBillItemId2ListDevice  ;
    private Map<Id, Id> mapBillItemId2SupplyPointId ;
    private map<Id, TemplateMapping__c> mapBillId2PdfTemplateXslt ;
    private map<Id, Id> mapContractId2PaymentPlanTypeId  ;
    private map<Id, BillEvent__c> mapBillId2PendingBillEvent  ;
    private map<Id, ServiceMessage__c> mapBillItemId2ServiceMessage ;
    private Map<Id,List<AgreedVolume__c>> mapBillItemId2AgreedVolume ;  //AT-3166
    private Map<Id,list<StandardSampleStrength__c>> mapBillItemId2StandardSampleStrength ;  //AT-3166
    private Map<Id, List<Bill__c>> mapBillId2ListTransferBills ; //AT-3258
    //AT-4475 Starts Here for Rural Billing.
    private Map<Id, List<RuralEntitlement__c>> mapOfContractId2RuralEntitlementList;
    //AT-4475 Ends Here for Rural Billing.
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           4 June 2018
    @param          List<Bill__c> - the list of Bill records with false Data XML
    @description    Constructor
	@revision		// AU1: AT-4098
    *******************************************************************************/
    public String getDataTransferXmlString(List<Bill__c> billRecords) {
        System.debug('50.1 Inside getDataTransferXmlString billRecords = '+billRecords);
        // maps initilization
        mapContractId2LastPrintedBilldate = new map<Id, Date>() ;   
        mapBillId2ContractId = new map<Id, Id>() ;
        mapContractd2ListPayments = new map<Id, list<Payment__c>>() ;
        mapPaymentIdToBalanceTransactions = new Map<Id,List<BalanceTransaction__c>>(); // AT-4017
        mapBillId2ListBillItem = new Map<Id, List<BillItem__c>>() ;
        mapBillItemId2ServiceTypeId = new map<Id, Id>() ;
        mapBillItemId2ServiceMessage = new map<Id, ServiceMessage__c>() ;
        mapContractId2BillMessage   = new Map<Id, List<ContractBillMessage__c>>() ;  // AT-3046
        mapBillId2ListPaymentPlan = new Map<Id,List<PaymentPlan__c>>() ;
        mapBillItemId2SpdAndAdu = new Map<Id, SupplyPointDevice__c>() ;
        mapBillItemId2SupplyPointLocation = new map<Id, Id>() ;
        mapBillItemId2SetDeviceId = new map<Id, set<Id>>() ; 
        mapBillItemId2ListDevice = new map<Id, List<Device__c>>() ;
        mapBillItemId2SupplyPointId = new Map<Id, Id>();
        mapBillId2PdfTemplateXslt = new map<Id, TemplateMapping__c> () ;
        mapContractId2PaymentPlanTypeId = new map<Id, Id>() ;
        mapBillId2PendingBillEvent = new map<Id, BillEvent__c>() ;
        mapBillItemId2Listlocation = new Map<Id,list<Location__c>>() ;
        mapBillItemId2SupplyPointlocationId = new map<Id, Id>() ;
        mapBillItemId2AgreedVolume = new map<Id, List<AgreedVolume__c>>();  //AT-3166
        mapBillItemId2StandardSampleStrength  = new map<Id, List<StandardSampleStrength__c>>();  //AT-3166
        mapBillId2ListTransferBills = new Map<Id, List<Bill__c>>(); //AT-3258
        //AT-4475 Starts Here for Rural Billing.
        mapOfContractId2RuralEntitlementList = new Map<Id,List<RuralEntitlement__c>>();
        //AT-4475 Ends Here for Rural Billing.
        // build a list of the contract Ids
        set<Id> setContractIds = new set<Id>();
        for (Bill__c billRecord : billRecords) {
            setContractIds.add(billRecord.BillingContract__c);
            mapBillId2ContractId.put(billRecord.Id, billRecord.BillingContract__c) ;
        }
        
        contracts = [select Id,  BillingMethod__c,  BillingFrequency__c,  AccountName__c,  ContractStartDate__c,
                        (SELECT Id, Active__c, BillMessage__r.MessageText__c FROM ContractBillMessage__r WHERE Active__c = true Order By CreatedDate Asc), //AT-3046 LIMIT 1) ,    // Currently LIMIT to 1 based on Andy's discussion
                        (SELECT Id, BillDate__c FROM Bills__r WHERE DataXml__c = true ORDER BY BillDate__c Desc LIMIT 1),
                        CurrentPaymentPlanType__c // Payment Plan Type of Active Payment Plan on Contract
                     FROM BillingContract__c
                     WHERE
                     Id IN: setContractIds] ;        
        
        for(BillingContract__c contract : contracts) { 
            //Get Payment Plan Type of Active Payment Plan on Contract
            if(contract.CurrentPaymentPlanType__c != null) {
                mapContractId2PaymentPlanTypeId.put(contract.Id, contract.CurrentPaymentPlanType__c) ;
            }
            //Get Last Printed Bill date for each contract 
            if(contract.Bills__r != null && !contract.Bills__r.isEmpty()) {                         
                mapContractId2LastPrintedBilldate.put(contract.Id, contract.Bills__r[0].BillDate__c) ;
            } else {
                mapContractId2LastPrintedBilldate.put(contract.Id, contract.ContractStartDate__c) ;
            }
            //Get Contract Bill  Messages
            // Start of AT-3046           
            for(ContractBillMessage__c objCBM : contract.ContractBillMessage__r){
                if(!mapContractId2BillMessage.containsKey(contract.Id)) {
                    List<ContractBillMessage__c> cbmList = new List<ContractBillMessage__c>();
                    cbmList.add(objCBM);
                    mapContractId2BillMessage.put(contract.Id, cbmList) ;
                }else{
                    List<ContractBillMessage__c> cbmList = new List<ContractBillMessage__c>();
                    cbmList = mapContractId2BillMessage.get(contract.Id);
                    cbmList.add(objCBM);
                    mapContractId2BillMessage.put(contract.Id, cbmList);
                }
            }
            // end of AT-3046
        }
        buildXMLDocument(billRecords, setContractIds);
        
        return XML ;
    }
     
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           5 June 2018
    @param          List<Bill__c> - the list of bill
    @param          List<Id> - the list of contract Ids
    @description    Builds the XML data
    *******************************************************************************/
    private void buildXMLDocument(List<Bill__c> billRecords, set<Id> setContractIds) {
        // build lists of the account and contract Ids
        List<Id> accountIds = new List<Id>();
        set<Id> setBillIds = new set<Id>() ;
        for (Bill__c billRecord : billRecords) {
            accountIds.add(billRecord.BillingContract__r.AccountName__c);
            setBillIds.add(billRecord.Id) ;
        }
        
        /** STEP 1: get all the data records required **/
        mapBillId2PendingBillEvent = getPendingBillEvent(billRecords) ;
        mapBillId2PdfTemplateXslt = getTemplateMapping(billRecords, mapBillId2PendingBillEvent) ;
        // Get contract payments:
        mapContractd2ListPayments = getContractPayments(mapBillId2ContractId, mapContractId2LastPrintedBilldate) ;
        // AT-4017
        mapPaymentIdToBalanceTransactions = getPaymentBalanceTransactions(mapContractd2ListPayments);
        //Get Bill Item Information     -       // Also contains Service Item Type & Service Item Family fields,  Rate Information, Reading fields & Device fields
        mapBillId2ListBillItem  =   extractBillItemData(setBillIds) ;   
        mapBillItemId2ServiceMessage = extractBillItemServiceType(mapBillItemId2ServiceTypeId) ;
        //Get payment plan and installments associated with the bill
        mapBillId2ListPaymentPlan   =   extractPaymentPlanAndInstalments(mapBillId2ContractId) ;
        //Get supply point device and average daily usage
        mapBillItemId2SpdAndAdu = extractSupplyPointDeviceAndAverageDailyUsage(mapBillId2ListBillItem) ;
        //Get Supply Point Location Details, Location occupants and Account details
        mapBillItemId2Listlocation = extractLocationData(mapBillItemId2SupplyPointlocationId) ;
        mapBillItemId2ListDevice = extractDeviceAndReadings(mapBillItemId2SetDeviceId) ;
        mapBillItemId2AgreedVolume = extractAgreedVolumeData(setBillIds);   //AT-3166
        mapBillItemId2StandardSampleStrength  = extractStandardSampleStrengthData(setBillIds);   //AT-3166
        mapBillId2ListTransferBills = extractListOfTransferBills(setBillIds,billRecords); //AT-3258
        //AT-4475 Starts Here for Rural Billing.
        mapOfContractId2RuralEntitlementList = getRuralEntitlementFromContractIds(mapBillId2ContractId);
        //AT-4475 Ends Here for Rural Billing.
        /** STEP 2: build the data using the DTO hierachy **/
        // build DTOs
        data = new Bills(this, billRecords);
        //Clear the map data so as to reduce the heap size
        mapBillId2PendingBillEvent.clear() ;
        mapBillId2PdfTemplateXslt.clear() ;
        mapContractd2ListPayments.clear() ;
        mapPaymentIdToBalanceTransactions.clear();
        mapBillId2ListBillItem.clear() ;
        mapContractId2LastPrintedBilldate.clear() ;
        mapContractId2BillMessage.clear() ;
        mapContractId2PaymentPlanTypeId.clear() ;
        mapBillItemId2ServiceMessage.clear() ;
        mapBillId2ListPaymentPlan.clear() ;
        mapBillItemId2SpdAndAdu.clear() ;
        mapBillItemId2Listlocation.clear() ;
        mapBillItemId2ListDevice.clear() ;
        mapBillItemId2AgreedVolume.clear() ;  //AT-3166
        mapBillItemId2StandardSampleStrength.clear();  //AT-3166
        mapBillId2ListTransferBills.clear(); //AT-3258
        //AT-4475 Starts Here for Rural Billing.
        mapOfContractId2RuralEntitlementList.clear();
        //AT-4475 Ends Here for Rural Billing.
       // serialise the data into xml
        XML = GlUt_XMLSerialiser.serialize((Object) data);
        
        system.debug(DEBUG + 'XML: ' + XML);
    }    
    
    /*****************************************************************/
    /***** METHODS FOR STEP 1: get all the data records required *****/
    /*****************************************************************/
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           8 June 2018
    @param          map<Id, BillEvent__c> mapBillId2PendingBillEvent
    @param          List<Bill__c> listBill 
    @description    getTemplateMapping
    *******************************************************************************/
    private map<Id, TemplateMapping__c> getTemplateMapping(List<Bill__c> listBill, map<Id, BillEvent__c> mapBillId2PendingBillEvent) {
        Map<Id, TemplateMapping__c> mapBillId2TemplateSetting = new Map<Id, TemplateMapping__c>();
        String strPaymentPlanType ;
        String strPaymentMethodType ;
        String strAccountRecordType ;
      
        // get all the templates
        List<TemplateSetting__c> templates = [select Id, BillingEvent__c, 
                                              TemplateMapping__c, 
                                              TemplateMapping__r.PDFTemplate__c, 
                                              TemplateMapping__r.XSLTDocument__c, 
                                              Type__c, 
                                              AccountType__c, 
                                              PaymentMethodType__c, 
                                              PaymentPlanType__c
                                              from TemplateSetting__c
                                              WHERE Type__c != null
                                              AND TemplateMapping__c != null];
        
        for(Bill__c bill : listBill) {
          
            String billEventType = mapBillId2PendingBillEvent.get(bill.Id) != null ? mapBillId2PendingBillEvent.get(bill.Id).EventType__c : GlUt_APIConstantsBillEvent.NORMALBILLEVENTSTATUS ;
            Boolean exactMatchFound = false ;
            // check each template setting for a match
            TemplateMapping__c matchedTemplate;
            for(TemplateSetting__c template : templates) {
                // check for a perfect match first
                if (billEventType == template.BillingEvent__c 
                    && bill.BillingContract__r.AccountName__r.RecordType.Name == template.AccountType__c  
                    && bill.BillingContract__r.PaymentMethodType__c == template.PaymentMethodType__c 
                    && mapContractId2PaymentPlanTypeId.get(bill.BillingContract__c) == template.PaymentPlanType__c) 
                    {
                        matchedTemplate = new TemplateMapping__c(Id = template.TemplateMapping__c, 
                                                                PDFTemplate__c = template.TemplateMapping__r.PDFTemplate__c, 
                                                                XSLTDocument__c = template.TemplateMapping__r.XSLTDocument__c);
                        exactMatchFound = true ;
                        break;      // quit looking once a perfect match found
                    }
            }
            // no perfect match yet, so check for the default match
            if(!exactMatchFound) {
                for(TemplateSetting__c template : templates) { 
                    if (billEventType == template.BillingEvent__c
                        && template.AccountType__c == null 
                        && template.PaymentMethodType__c == null 
                        && template.PaymentPlanType__c == null) {
                            matchedTemplate = new TemplateMapping__c(Id = template.TemplateMapping__c, 
                                                                    PDFTemplate__c = template.TemplateMapping__r.PDFTemplate__c, 
                                                                    XSLTDocument__c = template.TemplateMapping__r.XSLTDocument__c);
                        }
                }
            } 
            mapBillId2TemplateSetting.put(bill.Id, matchedTemplate) ;
        }
        
        return mapBillId2TemplateSetting ;
    }
    /******************************************************************************
    @author         Echo: Amit Kumar
    @date           14 Dec 2018
    @param          Map<Id,Id> mapBillId2ContractId 
    @param          Map<Id, List<RuralEntitlement__c>> 
    @description    get RuralEntitlement From ContractIds(AT-4475)
    *******************************************************************************/
    private Map<Id, List<RuralEntitlement__c>> getRuralEntitlementFromContractIds(Map<Id,Id> mapBillId2ContractId) {
        Set<Id> contractIdSet = new Set<Id>();
        contractIdSet.addAll(mapBillId2ContractId.values());
        Map<Id,List<RuralEntitlement__c>> mapOfContractId2RuralEntitlementList = new  Map<Id,List<RuralEntitlement__c>>();
        List<RuralEntitlement__c> ruralEntitlementList = GlUt_RuralBillingUtilities.getRuralEntitlementFromContractIds(contractIdSet);
        if(ruralEntitlementList != null && !ruralEntitlementList.isEmpty()){
            for(RuralEntitlement__c ruralEntitlement : ruralEntitlementList){
                if(!mapOfContractId2RuralEntitlementList.containsKey(ruralEntitlement.RuralLicense__r.BillingContract__c)){
                    mapOfContractId2RuralEntitlementList.put(ruralEntitlement.RuralLicense__r.BillingContract__c,new List<RuralEntitlement__c>());
                }
                mapOfContractId2RuralEntitlementList.get(ruralEntitlement.RuralLicense__r.BillingContract__c).add(ruralEntitlement);
            }
        }
        return mapOfContractId2RuralEntitlementList; 
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           8 June 2018
    @param          list<Bill__c> listBill
    @description    getPendingBillEvent
    *******************************************************************************/
    private map<Id, BillEvent__c> getPendingBillEvent(list<Bill__c> listBill) {
        map<Id, String> mapBillId2PdfXsltInfo = new map<Id, String>() ;
        map<Id, Id> mapBillId2BillEventId = new map<Id, Id>() ;
        for(Bill__c bill : listBill) {
            mapBillId2BillEventId.put(bill.Id, bill.BillEvent__c) ;
        }
        //Gopal - AT-4159 start
        Map<Id, BillEvent__c> mapBillEvent =  new Map<Id, BillEvent__c>([SELECT Id, EventType__c, Status__c FROM BillEvent__c
                                            WHERE Id IN: mapBillId2BillEventId.values()
                                                                        Order By CreatedDate Desc]) ;
        //Gopal - AT-4159 end
        if(!mapBillId2BillEventId.isEmpty()) {
            for(String billId : mapBillId2BillEventId.keySet()) {
                if(!mapBillEvent.isEmpty() 
                                            && 
                                            mapBillId2BillEventId.get(billId) != null 
                                            && 
                                            mapBillEvent.containsKey(mapBillId2BillEventId.get(billId))
                                            &&
                                            mapBillEvent.get(mapBillId2BillEventId.get(billId)) != null) {
                    mapBillId2PendingBillEvent.put(billId, mapBillEvent.get(mapBillId2BillEventId.get(billId))) ;
                } else {
    	            mapBillId2PendingBillEvent.put(billId, null) ;                    
                }
            }
        }
        
        return mapBillId2PendingBillEvent ;
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           8 June 2018
    @param          map<Id, Id> mapBillId2ContractId, map<Id, Date> tempMapContractId2LastPrintedBilldate
    @description    getContractPayments
    *******************************************************************************/
    private map<Id, list<Payment__c>> getContractPayments(map<Id, Id> mapBillId2ContractId, map<Id, Date> tempMapContractId2LastPrintedBilldate) {
        map<Id, list<Payment__c>> tempMapContractd2ListPayments = new map<Id, list<Payment__c>>();
        if(!mapBillId2ContractId.isEmpty()) {
            /*Changes for AT-4299,AT-4301 Starts here(Use created date field in filtering condition from PaymentDate*/
            for(Payment__c pay : [SELECT Id, CreatedDate, BillingContract__c, Amount__c, PaymentDate__c, PaymentMethod__c, PaymentSource__c, RecordType.Name
                                  FROM Payment__c 
                                  WHERE BillingContract__c IN: mapBillId2ContractId.values() 
                                   AND DoNotPrint__c = false  // AT-4899
                                  ]) 
            {
                if(tempMapContractId2LastPrintedBilldate.get(pay.BillingContract__c) != null &&  pay.CreatedDate.Date() >= tempMapContractId2LastPrintedBilldate.get(pay.BillingContract__c)) {
                    if(!tempMapContractd2ListPayments.containsKey(pay.BillingContract__c)) {
                        tempMapContractd2ListPayments.put(pay.BillingContract__c, new list<Payment__c> {pay}) ;
                    } else {
                        tempMapContractd2ListPayments.get(pay.BillingContract__c).add(pay) ;
                    }
                }
            }
        }
        /*Changes for AT-4299,AT-4301 Ends here(Use created date field in filtering condition from PaymentDate*/
        return tempMapContractd2ListPayments ; 
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           02 Nov 2018
    @param          map<Id, List<Payment__c> mapBillId2ContractId, map<Id, Date> tempMapContractId2LastPrintedBilldate
    @description    getContractPayments
    *******************************************************************************/
    private Map<Id, List<BalanceTransaction__c>> getPaymentBalanceTransactions(map<Id, List<Payment__c>> mapContractd2ListPayments) {
        Set<Id> paymentIdSet = new Set<Id>();
        Map<Id, List<BalanceTransaction__c>> mapOfPaymentIdToBalanceTransactions = new Map<Id, List<BalanceTransaction__c>>();
        List<BalanceTransaction__c> balanceTransactionLists = new List<BalanceTransaction__c>();
        if(mapContractd2ListPayments != null && !mapContractd2ListPayments.isEmpty()){
            for(List<Payment__c> paymentList : mapContractd2ListPayments.values()){
                for(Payment__c objPayment : paymentList){
                    paymentIdSet.add(objPayment.Id);
                }
            }
            if(paymentIdSet != null && paymentIdSet.size() > 0){
                balanceTransactionLists = [SELECT Id, 
                                           Balance__c,
                                           Amount__c, 
                                           Payment__c,
                                           RecordType.Name
                                           FROM BalanceTransaction__c
                                           WHERE Payment__c IN : paymentIdSet 
                                           AND RecordType.Name =:PyAp_Constants.PAYMENT];
                if(!balanceTransactionLists.isEmpty()){
                    for(BalanceTransaction__c objBT : balanceTransactionLists){
                        if(!mapOfPaymentIdToBalanceTransactions.containsKey(objBT.Payment__c)) {
                            mapOfPaymentIdToBalanceTransactions.put(objBT.Payment__c, new List<BalanceTransaction__c> {objBT}) ;
                        } else {
                            mapOfPaymentIdToBalanceTransactions.get(objBT.Payment__c).add(objBT) ;
                        }
                    }
                }
            }
        }
        
        return mapOfPaymentIdToBalanceTransactions;
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           8 June 2018
    @param          Set<Id> billIds
    @description    extractBillItemData - //Get Bill Item Information
    *******************************************************************************/
    private Map<Id, List<BillItem__c>> extractBillItemData(Set<Id> billIds){
        Map<Id, List<BillItem__c>> billItemMap = new Map<Id, List<BillItem__c>>();
        List<BillItem__c> billItemListResults = [SELECT  
                                                 //Bill Item fields
                                                 //AT-4475 Starts Here for Rural Billing
                                                 RuralGrossConsumption__r.StartDate__c,
                                                 RuralGrossConsumption__r.EndDate__c,
                                                 RuralGrossConsumption__r.Consumption__c,
                                                 RuralGrossConsumption__r.Type__c,
                                                 //AT-4475 Ends Here for Rural Billing
                                                 NegatedBillItem__c,AmountOutstanding__c,  Name, //AT-4301 For Negated Bill Item field
                                                 Bill__c, BillItem__c, BillServiceType__c, // not required
                                                 BilledAmount__c, StartDate__c, TotalDiscountAmount__c, TotalTaxAmount__c, VolumeUsed__c, EndDate__c,NumberOfDays__c,
                                                 StartReadingID__c, EndReadingID__c,   //AT-3823
                                                 //Charge Basis fields
                                                 ChargeBasis__r.Amount__c, ChargeBasis__r.StartDate__c, ChargeBasis__r.EndDate__c,ChargeBasis__r.Type__c, //UL-161
                                                 // Service Item Type & Service Item Family fields
                                                 ServiceItem__r.ServiceItemType__r.Name, 
                                                 ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.ServiceType__c,
                                                 ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.ServiceType__r.Name, 
                                                 ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.AlgorithmType__c, // TG 28/11 , AT-4305
                                                 ServiceItem__r.Service__r.SupplyPoint__c, ServiceItem__r.Service__r.SupplyPoint__r.Location__c,
                                                 //Discharge Agreement 
                                                 ServiceItem__r.DischargeAgreement__r.name,   //AT-3166
                                                 ServiceItem__r.DischargeAgreement__c,   //AT-3166
                                                 // rate Information
                                                 Rate__r.RetailAmount__c, Rate__r.StartDate__c, Rate__r.EndDate__c, 
                                                 // Reading fields
                                                 Reading__r.ReadingMethod__c, Reading__r.ReadingType__c, Reading__r.Reading__c, Reading__r.ActualDeviceReading__c, Reading__r.ReadingSource__c,Reading__r.Leak__c,Reading__r.EffectiveReading__c, //AT-2932
                                                 Reading__r.HighReading__c, //AT-3856
                                                 // Tax fields
                                                 (SELECT Id, Name, Tax__r.Name, Tax__r.PercentTax__c, TaxAmount__c FROM Bill_Item_Tax__r), //AT-5639, Ankit, 25/04/2019
                                                 // Device fields
                                                 Reading__r.Device__r.Name, Reading__r.Device__r.DeviceType__r.Manufacturer__c, //AT-3174
                                                 Reading__r.Device__r.SerialNo__c, Reading__r.ReadingDate__c, //AT-3174
                                                 Reading__r.Device__r.Digit__c, //AT-3174
                                                 // Bill Item Discount - To check if it is required
                                                 (SELECT Id, DiscountAmount__c, 
                                                  Discount__r.DiscountType__r.Type__c, Discount__r.DiscountType__r.AbsoluteDiscountAmount__c, 
                                                  Discount__r.DiscountType__r.PercentageDiscountAmount__c ,  
                                                  Discount__r.DiscountType__r.TopUp__c   //AT-4388
                                                  FROM BillItemDiscount__r), 
                                                 (SELECT StartDate__c, EndDate__c, AllowanceApplied__c, SupplyPointAllowance__r.Type__c, 
                                                  Order__c FROM VolumeAlterationItem__r) // AT-2783
                                                 FROM BillItem__c WHERE Bill__c IN: billIds ORDER BY StartDate__c ASC];
        //loop over list of bill items and make the map of bill id to bill item.
        for(BillItem__c bItem : billItemListResults){
            if(bItem.ServiceItem__c != null && 
                                bItem.ServiceItem__r.ServiceItemType__c != null &&
                                bItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__c != null &&
                                bItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.ServiceType__c != null) {
                    mapBillItemId2ServiceTypeId.put(bItem.Id, bItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.ServiceType__c) ;
            }
            List<BillItem__c> billItemsList;
            if(billItemMap.containsKey(bItem.Bill__c)){
                billItemsList = billItemMap.get(bItem.Bill__c);
            }else{
                billItemsList = new List<BillItem__c>();
            }
            billItemsList.add(bItem);
            billItemMap.put(bItem.Bill__c, billItemsList);
        }    
        
        return billItemMap;
    }
    
    /******************************************************************************
    @author         Echo: Vivek Sethi  AT-3166
    @date           26 July 2018
    @param          Set<Id> billIds
    @description    extractAgreedVolumeData - //Get Agreed Volume Information
    *******************************************************************************/
    private Map<Id, List<AgreedVolume__c>> extractAgreedVolumeData(Set<Id> billIds){
        Map<Id, Id> dischargeAgreementMap = new Map<Id, Id>(); 
        Map<Id, List<AgreedVolume__c>> billItem2AgreedVolumeMap = new  Map<Id, List<AgreedVolume__c>>();
        List<AgreedVolume__c> agreedVolumeList = new List<AgreedVolume__c>();
        for(BillItem__c billItemObj : [SELECT Id, ServiceItem__r.DischargeAgreement__c  FROM BillItem__c WHERE Bill__c IN: billIds] )
        {
            if(billItemObj.ServiceItem__r.DischargeAgreement__c != null)
                dischargeAgreementMap.put(billItemObj.ServiceItem__r.DischargeAgreement__c, billItemObj.Id);
        }
        
        if(!dischargeAgreementMap.isEmpty()) {
            for(AgreedVolume__c agreedVolumeObj : [SELECT  
                                                   Id,  
                                                   AgreedVolume__c ,
                                                   DischargeAgreement__c
                                                   FROM AgreedVolume__c
                                                   WHERE DischargeAgreement__c IN:dischargeAgreementMap.keySet()]) 
            {
                agreedVolumeList.add(agreedVolumeObj);
                billItem2AgreedVolumeMap.put(dischargeAgreementMap.get(agreedVolumeObj.DischargeAgreement__c) , agreedVolumeList);
            }
        }
        
        return billItem2AgreedVolumeMap;
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           07 Aug 2018
    @param          Set<Id> billIds
    @description    extractListOfTransferBills - //Get Bill Transfer Information
    *******************************************************************************/
    
    private Map<Id, List<Bill__c>> extractListOfTransferBills(Set<Id> billIds, List<Bill__c> listBillRecords){
        
        Map<Id, Date> mapContractId2CurrentBillDate = new Map<Id, Date>();
        Map<Id, Date> mapContractId2LastPrintDate = new Map<Id, Date>();
        Map<Id,List<Bill__c>> mapContractId2ListOfTransferBills = new Map<Id,List<Bill__c>>();
        Map<Id,List<Bill__c>> mapContractId2ListOfGeneralBills = new Map<Id,List<Bill__c>>();
        Map<Id,List<Bill__c>> mapContractId2TransferBillsInXML = new Map<Id,List<Bill__c>>();
        
        List<Bill__c> listOfOtherBillsToContract = new List<Bill__c>();
        
        if(!listBillRecords.isEmpty()){
            
            for(Bill__c objBill : listBillRecords){
                if(!mapContractId2CurrentBillDate.containsKey(objBill.BillingContract__c)){
                    mapContractId2CurrentBillDate.put(objBill.BillingContract__c, objBill.BillDate__c);
                }
            }
        }

        Map<Id , List<Bill__c>> mapBillsByContractId = new Map<Id , List<Bill__c>>();
        if(mapBillId2ContractId.keyset().size() > 0){
            
            // Get list of all bills to contract where current bill is not In
            listOfOtherBillsToContract = [SELECT  Id,
                                          StartDate__c,
                                          EndDate__c,
                                          BillDate__c,
                                          BilledAmount__c,
                                          BillingContract__c,
                                          PrintDate__c,
                                          PrintXml__c,
                                          BillType__c,
                                          TransferredBillTransfer__c,
                                          TransferredBillTransfer__r.TransferAmount__c,
                                          TransferredBillTransfer__r.TransferFromContract__c,
                                          TransferredBillTransfer__r.TransferReason__c,
                                          TransferredBillTransfer__r.CreatedDate
                                          FROM Bill__c 
                                          WHERE BillingContract__c IN: mapBillId2ContractId.values() 
                                          AND ID NOT IN: billIds];
            //AND TransferredFromBillingContract__c = null];
        }

        if(!listOfOtherBillsToContract.isEmpty()){
           for(Bill__c billObj : listOfOtherBillsToContract){
			   if(!mapBillsByContractId.containsKey(billObj.BillingContract__c)){
				   mapBillsByContractId.put(billObj.BillingContract__c,  new List<Bill__c>());
			   }
			   mapBillsByContractId.get(billObj.BillingContract__c).add(billObj);
		   } 
            if(mapBillsByContractId.keySet().size() > 0){
                for(Id  objId : mapBillsByContractId.keyset()){
                    for(Bill__c objBill : mapBillsByContractId.get(objId)){
                        if(objBill.BillDate__c <= mapContractId2CurrentBillDate.get(objBill.BillingContract__c)){
                            
                            // Transferred Bills
                            if(objBill.BillType__c == Label.GlUt_Transfer &&  objBill.TransferredBillTransfer__c != null){
                                
                                if(!mapContractId2ListOfTransferBills.containsKey(objBill.BillingContract__c)){
                                    mapContractId2ListOfTransferBills.put(objBill.BillingContract__c, new List<Bill__c>());
                                }
                                mapContractId2ListOfTransferBills.get(objBill.BillingContract__c).add(objBill);
                            }
                            // Non Transferred Bills
                            else{
                                if(objBill.PrintXml__c){
                                    if(!mapContractId2ListOfGeneralBills.containsKey(objBill.BillingContract__c)){
                                        mapContractId2ListOfGeneralBills.put(objBill.BillingContract__c, new List<Bill__c>());
                                    }
                                    mapContractId2ListOfGeneralBills.get(objBill.BillingContract__c).add(objBill);
                                }
                            }
                        }
                    }
                }	
            } 	
		}	
        // Get the latest bill from these
        if(mapContractId2ListOfGeneralBills.keyset().size() > 0){
            for(Id objId : mapContractId2ListOfGeneralBills.keyset()){
                List<Bill__c> listBills = mapContractId2ListOfGeneralBills.get(objId);
                if(!listBills.isEmpty()){
                    listBills.sort();
                    Date lastBillDate = listBills[listBills.size() - 1].BillDate__c;
                    if(!mapContractId2LastPrintDate.containsKey(objId)){
                        mapContractId2LastPrintDate.put(objId, lastBillDate);
                    }                    
                }
            }
        }

        //This map(mapContractId2ListOfTransferBills) has all transferred bills against Contract
        if( mapContractId2ListOfTransferBills.keyset().size() > 0){
            for(Id objIdTransfer : mapContractId2ListOfTransferBills.keyset()){
                List<Bill__c> listBillsTransferred = mapContractId2ListOfTransferBills.get(objIdTransfer);
                List<Bill__c> listTransferBillToBeAddedInXML = new List<Bill__c>();
                if(!listBillsTransferred.isEmpty()){
                    for(Bill__c objBillToTransfer : listBillsTransferred){
                        // Get all the transferred bills between current and last bill date  
                        if(objBillToTransfer.BillDate__c <= mapContractId2CurrentBillDate.get(objIdTransfer) 
                           && objBillToTransfer.BillDate__c > mapContractId2LastPrintDate.get(objIdTransfer)){
                               listTransferBillToBeAddedInXML.add(objBillToTransfer);
                        }
                    }
                    if(!listTransferBillToBeAddedInXML.isEmpty()){
                        if(!mapContractId2TransferBillsInXML.containsKey(objIdTransfer)){
                            mapContractId2TransferBillsInXML.put(objIdTransfer, listTransferBillToBeAddedInXML);
                        }
                    }
                }
                
            }
        }
        return mapContractId2TransferBillsInXML;
    }
    
    /******************************************************************************
    @author         Echo: Vivek Sethi  AT-3166
    @date           26 July 2018
    @param          Set<Id> billIds
    @description    extractStandardSampleStrengthData - //Get Standard Sample Strength Data Information on the basis of Wholesalers__c and Division__c from Available Service
    *******************************************************************************/
    private Map<Id, List<StandardSampleStrength__c>> extractStandardSampleStrengthData(Set<Id> billIds){
        Map<Id, Id> service2BillItemMap = new Map<Id, Id>(); 
        Map<Id, Id>  wholesaler2BillItemMap = new Map<Id, Id>();
        Map<Id, Id>  division2BillItemMap = new Map<Id, Id>();
        Map<Id, List<StandardSampleStrength__c>> billitem2StandardSampleStrength = new Map<Id, List<StandardSampleStrength__c>>();
        Map<Id, Id>  availService2BillItemIdMap = new Map<Id, Id>();
        List<StandardSampleStrength__c> StandardSampleStrengthObjList = new  List<StandardSampleStrength__c>();
        
        for(BillItem__c billItemObj : [SELECT Id, ServiceItem__r.Service__c  FROM BillItem__c WHERE Bill__c IN: billIds] )
        {
            if(billItemObj.ServiceItem__r.Service__c != null)
                service2BillItemMap.put(billItemObj.ServiceItem__r.Service__c , billItemObj.Id);
        }
        if(!service2BillItemMap.isEmpty())
        { 
            for(Service__c serviceObj :[SELECT Id, 
                                        AvailableService__c 
                                        FROM Service__c 
                                        WHERE Id IN: service2BillItemMap.keySet()]) 
            {
                availService2BillItemIdMap.put(serviceObj.AvailableService__c , service2BillItemMap.get(serviceObj.Id) );
            }
        }
        if(!availService2BillItemIdMap.isEmpty())
        {
            for(AvailableService__c AvailserviceObj : [SELECT  
                                                       Id, 
                                                       Wholesalers__c, 
                                                       Division__c
                                                       FROM AvailableService__c
                                                       WHERE Id IN:availService2BillItemIdMap.keySet()]) 
            {
                wholesaler2BillItemMap.put(AvailserviceObj.Wholesalers__c , availService2BillItemIdMap.get(AvailserviceObj.Id));
                division2BillItemMap.put(AvailserviceObj.Division__c , availService2BillItemIdMap.get(AvailserviceObj.Id));
            }
        }
        if(!wholesaler2BillItemMap.isEmpty() &&  !division2BillItemMap.isEmpty()) {
            for(StandardSampleStrength__c StandardSampleStrengthObj :  [SELECT Id ,
                                                                        Wholesaler__c,
                                                                        Division__c , 
                                                                        CODStandardStrength__c ,
                                                                        SSStandardStrength__c 
                                                                        FROM StandardSampleStrength__c
                                                                        WHERE Wholesaler__c IN: wholesaler2BillItemMap.keySet()
                                                                        AND Division__c IN: division2BillItemMap.keySet()]) 
            { 
                if(wholesaler2BillItemMap.containsKey(StandardSampleStrengthObj.Wholesaler__c)  && division2BillItemMap.containsKey(StandardSampleStrengthObj.Division__c)) {
                    StandardSampleStrengthObjList.add(StandardSampleStrengthObj);
                    billitem2StandardSampleStrength.put(wholesaler2BillItemMap.get(StandardSampleStrengthObj.Wholesaler__c), StandardSampleStrengthObjList);
                }
            }
        }
        
        return billitem2StandardSampleStrength;
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           8 June 2018
    @param          map<Id, ServiceType__c>
    @description    extractBillItemServiceType - // extract BillItem Service Type record
    *******************************************************************************/
    private map<Id, ServiceMessage__c> extractBillItemServiceType(map<Id, Id> mapBillItemId2ServiceTypeId) {
        map<Id, ServiceMessage__c> tempMapBillItemId2ServiceType = new map<Id, ServiceMessage__c>() ;
        map<Id, ServiceMessage__c> mapServiceTypeId2ServiceMessage = new map<Id, ServiceMessage__c>() ;
        if(!mapBillItemId2ServiceTypeId.values().isEmpty()) {
            for(ServiceMessage__c sm : [SELECT Id, MessageText__c, ServiceType__c FROM ServiceMessage__c
                                        WHERE
                                        ServiceType__c IN: mapBillItemId2ServiceTypeId.values()
                                        Order By CreatedDate Desc]) {   // There is no Active checkbox on the object
                if(!mapServiceTypeId2ServiceMessage.containskey(sm.ServiceType__c)) {
                    mapServiceTypeId2ServiceMessage.put(sm.ServiceType__c, sm) ;                                
                }                            
            }
        }
        if(!mapBillItemId2ServiceTypeId.isEmpty()) {
            for(String bItemId : mapBillItemId2ServiceTypeId.keySet()) {
                String serviceTypeId = mapBillItemId2ServiceTypeId.get(bItemId) ;
                if(!mapServiceTypeId2ServiceMessage.isEmpty() 
                    && mapServiceTypeId2ServiceMessage.containsKey(serviceTypeId)
                    && mapServiceTypeId2ServiceMessage.get(serviceTypeId) != null) {
                        tempMapBillItemId2ServiceType.put(bItemId, mapServiceTypeId2ServiceMessage.get(serviceTypeId)) ;
                }
            }
        }
        
        return tempMapBillItemId2ServiceType ;
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           8 June 2018
    @param          map<Id, Id> mapBillId2ContractId
    @description    extractPaymentPlanAndInstalments - // extract PaymentPlan & Instalments
    *******************************************************************************/
    private Map<Id,List<PaymentPlan__c>> extractPaymentPlanAndInstalments(map<Id, Id> mapBillId2ContractId) {
        map<Id,List<PaymentPlan__c>> tempMapBillId2ListPaymentPlan = new map<Id,List<PaymentPlan__c>>();
        if(!mapBillId2ContractId.isEmpty()) {
              Map<Id, List<PaymentPlan__c>> mapContractId2ListPaymentPlan = new Map<Id, List<PaymentPlan__c>>();
             //Query for payment plan and instalmment details
            //Changes for AT-3048 Starts here
            for(PaymentPlan__c pPlan : [SELECT Id, Active__c, BillingContract__c,  PaymentFrequency__c, Name, PaymentPlanTotal__c, PaymentPlanType__r.Name, 
                                        StartDate__c, TotalInstalmentAmount__c, 
                                                      (SELECT Id,InstalmentAmountDue__c, InstalmentAmountOutstanding__c,InstalmentDueDate__c,InstalmentNumber__c, SumofAllocatedPayment__c 
                                                       FROM Instalments__r WHERE Type__c =: System.Label.CuAp_InstalmentTypeNormal ORDER by InstalmentNumber__c Desc) 
                                        FROM PaymentPlan__c WHERE BillingContract__c IN: mapBillId2ContractId.values() AND Active__c = True]) {
               //Changes for AT-3048 Ends here
                if(!mapContractId2ListPaymentPlan.containsKey(pPlan.BillingContract__c))  {
                    mapContractId2ListPaymentPlan.put(pPlan.BillingContract__c, new list<PaymentPlan__c> {pPlan}) ;
                } else {
                    mapContractId2ListPaymentPlan.get(pPlan.BillingContract__c).add(pPlan) ;
                }         
            }
             //Loop over the mapBillId2ContractId to build the tempMapBillId2ListPaymentPlan
            for(Id billId : mapBillId2ContractId.keySet()){
                Id contractId = mapBillId2ContractId.get(billId);
                //PaymentPlan__c pplan = contractToPaymentPlanMap.get(contractId);
                if(mapContractId2ListPaymentPlan.containsKey(contractId)) {
                    for(PaymentPlan__c pplan : mapContractId2ListPaymentPlan.get(contractId)) {
                        if(!tempMapBillId2ListPaymentPlan.containsKey(billId)) {
                            tempMapBillId2ListPaymentPlan.put(billId, new list<PaymentPlan__c> {pplan}) ;
                        } else {
                            tempMapBillId2ListPaymentPlan.get(billId).add(pplan) ;
                        }
                    }
                } 
            } 
        }
        
        return tempMapBillId2ListPaymentPlan ;
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           8 June 2018
    @param          Map<Id, List<BillItem__c>> mapBillId2ListBillItem
    @description    extractSupplyPointDeviceAndAverageDailyUsage - // Get supply point device and average daily usage
    *******************************************************************************/
    private Map<Id, SupplyPointDevice__c> extractSupplyPointDeviceAndAverageDailyUsage(Map<Id, List<BillItem__c>> mapBillId2ListBillItem) {
        Map<Id, SupplyPointDevice__c> mapBillItemId2SupplyPointDevice = new Map<Id, SupplyPointDevice__c>();
        //Loop over the bill items to get the supply points for each bill
        Map<Id, Set<Id>> supplyPointId2billItemSetMap = new Map<Id, Set<Id>>();
        //Loop through all of the bill items for all of the bill to build a map of bill id to supply point id
        for(Id billId : mapBillId2ListBillItem.keySet()) {
            List<BillItem__c> billItemList = mapBillId2ListBillItem.get(billId);
            for(BillItem__c bItem : billItemList) {
                if(bItem.ServiceItem__c != null && bItem.ServiceItem__r.Service__c != null && bItem.ServiceItem__r.Service__r.SupplyPoint__c != null) {
                    Id supplyPointId = bItem.ServiceItem__r.Service__r.SupplyPoint__c;
                    mapBillItemId2SupplyPointlocationId.put(bItem.Id, bItem.ServiceItem__r.Service__r.SupplyPoint__r.Location__c) ;
                    mapBillItemId2SupplyPointId.put(bItem.Id, supplyPointId);       // billItemId2SupplyPointIdMap can be removed because supplyPointId2billItemSetMap will do the job.
                    Set<Id> billItemSet = new Set<Id>();
                    if(supplyPointId2billItemSetMap.containsKey(supplyPointId)) {
                        supplyPointId2billItemSetMap.get(supplyPointId).add(bItem.Id);
                    } else {
                        billItemSet.add(bItem.Id);
                        supplyPointId2billItemSetMap.put(supplyPointId, billItemSet);
                    }
                }
            }
        }
        
        //Now query the supply points and average daily usage tables 
        if(mapBillItemId2SupplyPointId.values() != null && !mapBillItemId2SupplyPointId.values().isEmpty()) {
            List<SupplyPointDevice__c> supDevList = [SELECT Active__c, DefaultAverageDailyUsage__c, Device__c, Device__r.Name, Device__r.SerialNo__c, 
                                                     Device__r.DeviceType__r.Manufacturer__c,  InstallationDate__c, ReadFrequency__c, RemovalDate__c, SupplyPoint__c, Name, 
                                                     SupplyPoint__r.Location__c,   // Retrieve the associated Location
                                                     //AT-4475 Starts Here
                                                     SupplyPoint__r.RuralOutletType__c,
                                                     SupplyPoint__r.AccessType__c,
                                                     SupplyPoint__r.RuralChannel__r.Name,
                                                     //AT-4475 Ends Here
                                                     //AT-3555  Invalid Flag addition
                                                     (SELECT AverageDailyUsage__c, StartDate__c, EndDate__c, Invalid__c, Account__c FROM AverageDailyUsage__r  WHERE StartDate__c = LAST_N_MONTHS: 18 )  //AT-5350
                                                     FROM SupplyPointDevice__c 
                                                     WHERE
                                                     SupplyPoint__c IN: supplyPointId2billItemSetMap.keySet()] ;        // 
            //Loop over the list of supply point device returned and find out each of the bill items that it maps to
            if(supDevList != null && !supDevList.isEmpty()) {
                for(SupplyPointDevice__c supDev : supDevList) {
                    Id supplyPointId = supDev.SupplyPoint__c;
                    Set<Id> billItemIdSet = supplyPointId2billItemSetMap.get(supplyPointId);    //Get associated billItemId
                    for(Id billItemId : billItemIdSet) {
                        if(!mapBillItemId2SetDeviceId.containsKey(billItemId)) {
                            mapBillItemId2SetDeviceId.put(billItemId, new set<Id> {supDev.Device__c}) ;
                        } else {
                            mapBillItemId2SetDeviceId.get(billItemId).add(supDev.Device__c) ;
                        }
                        mapBillItemId2SupplyPointDevice.put(billItemId, supDev);
                        mapBillItemId2SupplyPointLocation.put(billItemId, supDev.SupplyPoint__r.Location__c) ;
                    }
                }
            }
        }
        
        return mapBillItemId2SupplyPointDevice ;
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           8 June 2018
    @param          map<Id, set<Id>> mapBillItemId2SetDeviceId
    @description    extractDeviceAndReadings -//Get Device and Reading
    *******************************************************************************/
    private map<Id, List<Device__c>> extractDeviceAndReadings(map<Id, set<Id>> mapBillItemId2SetDeviceId) {
        map<Id, List<Device__c>> tempMapBillItemId2ListDevice = new map<Id, List<Device__c>>()  ;
        if(!mapBillItemId2SupplyPointId.isEmpty()) {
            set<Id> setDeviceIds = new set<Id> () ;
            for(set<Id> set1 : mapBillItemId2SetDeviceId.values()) {
                setDeviceIds.addAll(set1) ;
            }
            //Changes for AT-3047  Starts Here
           /* map<Id, Device__c> mapDevice = new map<Id, Device__c>([SELECT Id, Name, SerialNo__c, Digit__c, DeviceType__c,
                                                                   DeviceType__r.DeviceSize__r.Name,
                                                        (SELECT Id, Device__c, Reading__c, ReadingDate__c, ReadingType__c, ReadingSource__c, ReadingMethod__c, Leak__c, EffectiveReading__c // AT-2932 //AT-3174
                                                         FROM Readings__r WHERE ReadingDate__c >= :mapContractId2LastPrintedBilldate.values() ORDER BY  ReadingDate__c desc)   //Ordered by Descending AT-3166 //AT-3174
                                              FROM Device__c WHERE Id IN: setDeviceIds]) ;*/
            /*For a time being removing the LastPrintBill Date check from Query as per AT- 4301*/
             map<Id, Device__c> mapDevice = new map<Id, Device__c>([SELECT Id, Name, SerialNo__c, Digit__c, DeviceType__c,
                                                                   DeviceType__r.DeviceSize__r.Name,
                                                        (SELECT Id, Device__c, Reading__c, ReadingDate__c, ReadingType__c, ReadingSource__c, ReadingMethod__c, Leak__c, EffectiveReading__c // AT-2932 //AT-3174
                                                         FROM Readings__r ORDER BY  ReadingDate__c desc)   //Ordered by Descending AT-3166 //AT-3174
                                              FROM Device__c WHERE Id IN: setDeviceIds]) ;
            //Changes for AT-3047  Ends Here
            for(String billItemId : mapBillItemId2SetDeviceId.keySet()) {
                for(Id deviceId : mapBillItemId2SetDeviceId.get(billItemId)) {
                    if(mapDevice.containsKey(deviceId)) {
                        if(!tempMapBillItemId2ListDevice.containsKey(billItemId)) {
                            tempMapBillItemId2ListDevice.put(billItemId, new list<Device__c> {mapDevice.get(deviceId)}) ;
                        } else {
                            tempMapBillItemId2ListDevice.get(billItemId).add(mapDevice.get(deviceId)) ;
                        }
                    }
                }
            }
        }
        
        return tempMapBillItemId2ListDevice ;
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           8 June 2018
    @param          map<Id, Id> mapBillItemId2SupplyPointlocationId
    @description    extractLocationData - //Get location
	@revision		AT-5535, Ankit, 23/04/2019
					Added Account__c and Account__r.Name field in Location Occupant query
    *******************************************************************************/
    private Map<Id,list<Location__c>> extractLocationData(map<Id, Id> mapBillItemId2SupplyPointlocationId) { 
        Map<Id,list<Location__c>> tempMapBillItemId2Listlocation = new Map<Id,list<Location__c>>(); 
        map<Id, Location__c> mapSupplyPointLocationId2LocationObj = new map<Id, Location__c>([SELECT Id, Street__c, City__c, State__c, Country__c, PostalCode__c,RuralLicense__r.Name, AuDPID__c,
                                            (SELECT Id, Name, Primary__c, Account__c, Account__r.Name, ShowOnBill__c, OccupancyType__c, StartDate__c, EndDate__c FROM LocationOccupants__r)
                                            , (SELECT Name, Description__c FROM LocationMessages__r WHERE Active__c = true) // AU3__AT-4950
                               FROM Location__c 
                               WHERE Id IN: mapBillItemId2SupplyPointlocationId.values()]) ;
        if(!mapBillItemId2SupplyPointlocationId.isEmpty()) {
            for(String billItemId : mapBillItemId2SupplyPointlocationId.keySet()) {
                if(mapBillItemId2SupplyPointlocationId.containsKey(billItemId) && mapBillItemId2SupplyPointlocationId.get(billItemId) != null) {
                    Location__c tempLocation = mapSupplyPointLocationId2LocationObj.get(mapBillItemId2SupplyPointlocationId.get(billItemId)) ;
                    if(!tempMapBillItemId2Listlocation.containsKey(billItemId)) {
                        tempMapBillItemId2Listlocation.put(billItemId, new list<Location__c> {tempLocation}) ;
                    } else {
                        tempMapBillItemId2Listlocation.get(billItemId).add(tempLocation) ;
                    }
                }
            }
        }

        return tempMapBillItemId2Listlocation;
    }
    
    /**************************************************************************/
    /*****  SUB-CLASSES FOR STEP 2: build the data using the DTO hierachy *****/
    /**************************************************************************/
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           5 June 2018
    @description    Subclass for Bills
    *******************************************************************************/
    private class Bills {
        private List<Bill> Bill;
        public override String toString() {
            return 'Bills';
        }
    
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           5 June 2018
        @param          BlUt_BillXMLContainer - instance of the container class
        @param          List<Bill__c> - bill records
        @description    Constructor
        *******************************************************************************/
        private Bills(BlUt_BillXMLContainer container, List<Bill__c> billRecords) {
            // build the BILL DTO
            Bill = new List<Bill>();
            for (Bill__c thisBill : billRecords) {
                Bill.add(new Bill(container, thisBill));        // To check- method does not exist error
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           24 May 2018
    @description    Subclass for Bill
    *******************************************************************************/
    private class Bill {
        //PDFXSLT Mapping
        private String PdfTemplateName ;
        private String XsltName ;
        //Bill attributes
        private String Id ;
        private String InvoiceReference ; // TG 28/11 , AT-4349,4289
        private String StartDate;
        private String EndDate;
        private String BillDate;
        private String BilledAmount;  
        private String TotalAmountOutstanding ;
        //Account attributes
        private String  Account_Id ;
        private String Account_Name ;
        private String Account_AccountReference ;
        //Contract attributes
        private String  Contract_Id ;
        private String  Contract_Name ;
        private String  Contract_CurrentPaymentPlanType ;
        private String  Contract_DayOfMonth ;
        private String  Contract_DayOfWeek ;
        private String  Contract_BillingStreet ;
        private String  Contract_BillingCity ;
        private String  Contract_BillingState ;
        private String  Contract_BillingCountry ;
        private String  Contract_BillingPostalCode ;
        // MT - 20 Aug 2018 Start of AT-3409
        private Boolean Contract_UseAlternativeAddress;
        private String  Contract_AlternativeBilling_BillingStreet ;
        private String  Contract_AlternativeBilling_BillingCity ;
        private String  Contract_AlternativeBilling_BillingState ;
        private String  Contract_AlternativeBilling_BillingCountry ;
        private String  Contract_AlternativeBilling_BillingPostalCode ;
        //End of AT-3409
        private String  Contract_PaymentMethodType ;
        private String  Contract_ContractStartDate ;
        private String  Contract_ContractBalance ;
        private String  Contract_BalanceSnapshot ;
        // Payment Wrapper list
        private List<Payment> Payment ; 
        //Contract Bill Message Wrapper list
        private List<ContractBillMessage> ContractBillMessage ;  // AT-3046
        // Bill Item attributes
        private List<BillItemObj> BillItem ;
        // PaymentPlan wrapper  list - Also contains Instalments
        private list<PaymentPlan> PaymentPlan ;
        // BillTransfer wrapper  list 
        private list<BillTransfer> BillTransfer ;
        //AT-4475 Starts Here for Rural Billing.
        //RuralEntitlement wrapper list
        private list<RuralEntitlement> RuralEntitlement ;  
        //AT-4475 Ends Here for Rural Billing.
        // AT-4933 Starts Here
        private String  Contract_AlternativeBilling_Name ;
        private String  Contract_AlternativeBilling_Relationship ;
        // AT-4933 Ends Here
        // AT-4858 Starts Here
        private String Contract_AlternativeAuDpid;
        private String Contract_BillingAuDpid;
        private String Account_AuDpid;
        // AT-4858 Ends Here
        public override String toString() {
            return 'Bill__c';
        }
        
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           5 June 2018
        @param          BlUt_BillXMLContainer - instance of the container class
        @param          Bill__c - bill record
        @description    Constructor
        *******************************************************************************/
        private Bill(BlUt_BillXMLContainer container, Bill__c bill) {
            // add the fields to this DTO           
            PdfTemplateName = container.mapBillId2PdfTemplateXslt.get(bill.Id) != null ? container.mapBillId2PdfTemplateXslt.get(bill.Id).PDFTemplate__c : null ;
            XsltName = container.mapBillId2PdfTemplateXslt.get(bill.Id) != null ? container.mapBillId2PdfTemplateXslt.get(bill.Id).XSLTDocument__c : null ;
            
            system.debug('PdfTemplateName=> ' + PdfTemplateName);
            system.debug('XsltName=> ' + XsltName);
            
            //Bill fields mapping
            Id = bill.Id ;
            InvoiceReference = bill.Name; // TG 28/11 , AT-4349,4289
            StartDate = dateToString(bill.StartDate__c);
            EndDate = dateToString(bill.EndDate__c);
            BillDate = dateToString(bill.BillDate__c);
            BilledAmount = String.valueOf(bill.BilledAmount__c) ; 
            TotalAmountOutstanding = String.valueOf(bill.TotalAmountOutstanding__c) ; 
            //Account field mapping
            Account_Id = bill.BillingContract__r.AccountName__c ;
            Account_Name = bill.BillingContract__r.AccountName__r.Name ;
            Account_AccountReference = bill.BillingContract__r.AccountName__r.AccountReference__c ;
            //Contract fields mapping
            Contract_Id = bill.BillingContract__c ;
            Contract_Name = bill.BillingContract__r.Name  ;
            Contract_CurrentPaymentPlanType = bill.BillingContract__r.CurrentPaymentPlanType__c  ;
            Contract_DayOfMonth = bill.BillingContract__r.DayOfMonth__c  ;
            Contract_DayOfWeek = bill.BillingContract__r.DayOfWeek__c  ;
            Contract_BillingStreet = bill.BillingContract__r.BillingStreet__c  ;
            Contract_BillingCity = bill.BillingContract__r.BillingCity__c  ;
            Contract_BillingState = bill.BillingContract__r.BillingState__c  ;
            Contract_BillingCountry = bill.BillingContract__r.BillingCountry__c  ;
            Contract_BillingPostalCode = bill.BillingContract__r.BillingPostalCode__c  ;
            // MT - 20 Aug 2018 Start of AT-3409
            if(bill.BillingContract__r.UseAlternativeAddress__c){
                Contract_UseAlternativeAddress = bill.BillingContract__r.UseAlternativeAddress__c;
                Contract_AlternativeBilling_BillingStreet = bill.BillingContract__r.AlternativeBilling__r.BillingStreet;
                Contract_AlternativeBilling_BillingCity = bill.BillingContract__r.AlternativeBilling__r.BillingCity;
                Contract_AlternativeBilling_BillingState = bill.BillingContract__r.AlternativeBilling__r.BillingState;
                Contract_AlternativeBilling_BillingCountry = bill.BillingContract__r.AlternativeBilling__r.BillingCountry;
                Contract_AlternativeBilling_BillingPostalCode = bill.BillingContract__r.AlternativeBilling__r.BillingPostalCode;
            }
            //End of AT-3409
            Contract_PaymentMethodType = bill.BillingContract__r.PaymentMethodType__c  ;
            Contract_ContractStartDate = dateToString(bill.BillingContract__r.ContractStartDate__c)  ;
            Contract_ContractBalance = String.valueOf(bill.BillingContract__r.ContractBalance__c)  ;
            Contract_BalanceSnapshot = String.valueOf(bill.BillingContract__r.Balance__r.BalanceSnapshot__c) ; 
            // AT-4047
            // AT-4933 Starts Here
            Contract_AlternativeBilling_Name = bill.BillingContract__r.AlternativeBillingName__c;
            Contract_AlternativeBilling_Relationship = bill.BillingContract__r.AlternativeBillingRelationship__c; 
            // AT-4933 Ends Here
            
            // AT-4858 Starts Here
            Contract_AlternativeAuDpid = bill.BillingContract__r.AlternativeAuDpid__c;
            Contract_BillingAuDpid = bill.BillingContract__r.BillingAuDpid__c; 
            Account_AuDpid = bill.BillingContract__r.AccountName__r.AuDpid__c ;
            // AT-4858 Ends Here
            
            Payment = new List<Payment>() ;
            if(container.mapBillId2ContractId.containsKey(bill.Id)) {   // Payment wrapping
                Id billContractId = container.mapBillId2ContractId.get(bill.Id) ;
                if(billContractId != null && container.mapContractd2ListPayments.get(billContractId) != null) {
                    if(!container.mapContractd2ListPayments.isEmpty() && !container.mapContractd2ListPayments.values().isEmpty()) {
                        for(Payment__c pay : container.mapContractd2ListPayments.get(billContractId)) {
                            Payment.add(new Payment(container, pay)) ;
                        }
                    }
                }
                
                ContractBillMessage = new List<ContractBillMessage>() ; //AT-3046
                if(!container.mapContractId2BillMessage.isEmpty() && !container.mapContractId2BillMessage.values().isEmpty()) { // ContractBillMessage wrapping
                    if(container.mapContractId2BillMessage.get(billContractId) != null) {
                        // Start of AT-3046
                        for(ContractBillMessage__c cbm : container.mapContractId2BillMessage.get(billContractId)) {
                            ContractBillMessage.add(new ContractBillMessage(container, cbm)) ;
                        }
                    }
                } 
            }
            
            //Bill Item wrapping
            BillItem = new List<BillItemObj>() ;
            if(!container.mapBillId2ListBillItem.isEmpty() && container.mapBillId2ListBillItem.containsKey(bill.Id)) {
                for(BillItem__c billItemObj : container.mapBillId2ListBillItem.get(bill.Id)) {
                    BillItem.add(new BillItemObj(container, billItemObj)) ;
                }
            }
            
            // PaymentPlan wrapping
            PaymentPlan = new list<PaymentPlan> () ;
            if(!container.mapBillId2ListPaymentPlan.isEmpty() && container.mapBillId2ListPaymentPlan.containsKey(bill.Id)) {
                for(PaymentPlan__c paymentPlanObj : container.mapBillId2ListPaymentPlan.get(bill.Id)) {
                    PaymentPlan.add(new PaymentPlan(container, paymentPlanObj)) ;
                }
            }
            
            BillTransfer = new List<BillTransfer>();
            if(!container.mapBillId2ListTransferBills.isEmpty() && container.mapBillId2ListTransferBills.containsKey(bill.BillingContract__c)) {
                for(Bill__c billObject : container.mapBillId2ListTransferBills.get(bill.BillingContract__c)) {
                    BillTransfer.add(new BillTransfer(container, billObject)) ;
                }
            } 
            //AT-4475 Starts Here for Rural Billing.
            RuralEntitlement = new List<RuralEntitlement>();
            if(!container.mapOfContractId2RuralEntitlementList.isEmpty() && container.mapOfContractId2RuralEntitlementList.containsKey(bill.BillingContract__c)){
                for(RuralEntitlement__c ruralEntitlementObject : container.mapOfContractId2RuralEntitlementList.get(bill.BillingContract__c)) {
                    RuralEntitlement.add(new RuralEntitlement(container, ruralEntitlementObject)) ;
                }
            }
            //AT-4475 Ends Here for Rural Billing.
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           5 June 2018
    @description    Subclass for BillItem
    *******************************************************************************/
    private class BillItemObj {
        private Boolean NegatedBillItem; //AT-4301 Starts/Ends Here
        private String AmountOutstanding ;
        private String Name ;
        private String BilledAmount ;
        private String StartDate ;
        private String EndDate ;
        private String TotalDiscountAmount ;
        private String TotalTaxAmount ;
        private String VolumeUsed ;
        private String NumberOfDays ;
        //Service Item
        private String attr_ServiceItem ;   // act as an attribute
        private String attr_ServiceType ;   // act as an attribute
        private String ServiceItem_ServiceItemType_Name ;   
        private String ServiceItem_DischargeAgreement_Name ;  //AT-3166
        private String ServiceItem_ServiceItemType_ServiceItemFamily_ServiceType_Name ;
        private String attr_AlgorithmType ; // TG 28/11 , AT-4305
        //Rate
        private String Rate_RetailAmount ;
        private String Rate_StartDate ;
        private String Rate_EndDate ;
        //Reading fields
        private String Reading_ReadingDate ;
        private String Reading_ReadingType ;
        private String Reading_ReadingMethod ;
        private Decimal Reading_ReadingValue ;   //AT-3166
        private String Reading_ReadingSource ;
        private String Reading_Leak ; //AT-2932
        private Decimal Reading_EffectiveReading ; //AT-2932
        private Boolean Reading_HighReading ;  //AT-3856
        //Device fields
        private String Reading_DeviceReference_Name ;
        private String Reading_DeviceReference_DeviceType_Manufacturer ;
        private String Reading_DeviceReference_SerialNo ;
        private String Reading_DeviceReference_DeviceReference ;
        private String Reading_DeviceReference_Digit ;
        //Charge Basis fields
        private String ChargeBasis_Amount ;
        private String ChargeBasis_StartDate ;
        private String ChargeBasis_EndDate ;
        private String ChargeBasis_Type ; //UL-161
        //AT-3823 
        private String StartReadingID ;
        private String EndReadingID ;
        //Bill Item tax wrapper list
        private list<BillItemTax> BillItemTax ;
        //AverageDailyUse
        private List<AverageDailyUse> AverageDailyUse ; 
        //Location Occupants
        private List<Location> Location ;
        //Agreed Volume
        private List<AgreedVolume> AgreedVolume ;   //AT-3166
        private List<StandardSampleStrength> StandardSampleStrength ;   //AT-3166
        //Device and Reading wrapper list
        private List<Device> Device ;
        private list<SupplyPointDevice> SupplyPointDevice ;
        //Start of AT - 2783
        private list<VolumeAlterationItem> VolumeAlterationItem ;
        //End of AT - 2783
        //ServiceMessage wrapper
        private String ServiceMessage ; // Single message only
        //Discount Type TopUp
        private  list<BillItemDiscount> BillItemDiscount;
        //AT-4475 Starts Here for Rural Billing.
        private String RuralGrossConsumption_StartDate;
        private String RuralGrossConsumption_EndDate;
        private Decimal RuralGrossConsumption_Consumption;
        private String RuralGrossConsumption_Type;
        //AT-4475 Starts Here for Rural Billing.
        
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           5 June 2018
        @param          BlUt_BillXMLContainer - instance of the container class
        @param          BillItem__c billItem - record
        @description    Constructor
        *******************************************************************************/
        private BillItemObj(BlUt_BillXMLContainer container, BillItem__c billItem) {
            NegatedBillItem = billItem.NegatedBillItem__c; //AT-4301 Starts/Ends Here
            AmountOutstanding = String.valueOf(billItem.AmountOutstanding__c) ;
            Name = billItem.Name ;
            BilledAmount = String.valueOf(billItem.BilledAmount__c) ;
            StartDate = dateToString(billItem.StartDate__c) ;
            EndDate = dateToString(billItem.EndDate__c) ;
            TotalDiscountAmount = String.valueOf(billItem.TotalDiscountAmount__c) ;
            TotalTaxAmount = String.valueOf(billItem.TotalTaxAmount__c) ;
            VolumeUsed = String.valueOf(billItem.VolumeUsed__c) ;
            NumberOfDays = String.valueOf(billItem.NumberOfDays__c) ;
            StartReadingID = String.valueOf(billItem.StartReadingID__c) ;  //AT-3823
            EndReadingID = String.valueOf(billItem.EndReadingID__c) ;  //AT-3823
            //AT-4475 Starts Here for Rural Billing.
            RuralGrossConsumption_StartDate = String.valueOf(billItem.RuralGrossConsumption__r.StartDate__c);
            RuralGrossConsumption_EndDate = String.valueOf(billItem.RuralGrossConsumption__r.EndDate__c);
            RuralGrossConsumption_Consumption = billItem.RuralGrossConsumption__r.Consumption__c;
            RuralGrossConsumption_Type = billItem.RuralGrossConsumption__r.Type__c;
            //AT-4475 Ends Here for Rural Billing.
            //UL-161 Starts Here for UK Localisation
            ChargeBasis_Amount = String.valueOf(billItem.ChargeBasis__r.Amount__c);
            ChargeBasis_StartDate = String.valueOf(billItem.ChargeBasis__r.StartDate__c);
            ChargeBasis_EndDate = String.valueOf(billItem.ChargeBasis__r.EndDate__c);
            ChargeBasis_Type = billItem.ChargeBasis__r.Type__c;
            //UL-161 Ends Here for UK Localisation
            if(billItem.ServiceItem__c != null  && billItem.ServiceItem__r.ServiceItemType__c != null) {
                attr_ServiceItem = billItem.ServiceItem__r.ServiceItemType__r.Name ;
                ServiceItem_ServiceItemType_Name = billItem.ServiceItem__r.ServiceItemType__r.Name ;
            }
            if(billItem.ServiceItem__c != null && billItem.ServiceItem__r.ServiceItemType__c != null
                                        && billItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__c != null) 
            {
                attr_ServiceType = billItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.ServiceType__r.Name ;
                ServiceItem_ServiceItemType_ServiceItemFamily_ServiceType_Name = billItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.ServiceType__r.Name ;
                attr_AlgorithmType 	= billItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.AlgorithmType__c ; // TG 28/11 , AT-4305
            }
            
            // AT-3166  Discharge Agreement Name   
            if(billItem.ServiceItem__c != null  && billItem.ServiceItem__r.DischargeAgreement__c != null) 
                ServiceItem_DischargeAgreement_Name = billItem.ServiceItem__r.DischargeAgreement__r.name ;
            // ends  AT-3166
            Rate_RetailAmount = String.valueOf(billItem.Rate__r.RetailAmount__c) ;
            Rate_StartDate = dateToString(billItem.Rate__r.StartDate__c) ;
            Rate_EndDate = dateToString(billItem.Rate__r.EndDate__c) ;
            
            if(billItem.Reading__c != null) {   // Reading mapping
                Reading_ReadingDate = dateToString(billItem.Reading__r.ReadingDate__c) ;
                Reading_ReadingType = billItem.Reading__r.ReadingType__c ;
                Reading_ReadingMethod = billItem.Reading__r.ReadingMethod__c ;    
                Reading_ReadingValue  =   billItem.Reading__r.Reading__c;    //AT-3166
                Reading_ReadingSource = billItem.Reading__r.ReadingSource__c ;
                Reading_Leak = String.valueOf(billItem.Reading__r.Leak__c) ; //AT-2932
                Reading_EffectiveReading = billItem.Reading__r.EffectiveReading__c ; //AT-2932
                Reading_HighReading = billItem.Reading__r.HighReading__c;  //AT-3856
            }
            if(billItem.Reading__c != null && billItem.Reading__r.Device__c != null) {     // device mapping //AT-3174
                Reading_DeviceReference_Name = billItem.Reading__r.Device__r.Name ;
                Reading_DeviceReference_DeviceType_Manufacturer = billItem.Reading__r.Device__r.DeviceType__r.Manufacturer__c ;
                Reading_DeviceReference_SerialNo = billItem.Reading__r.Device__r.SerialNo__c ;
                Reading_DeviceReference_Digit = String.valueOf(billItem.Reading__r.Device__r.Digit__c) ;
            }
            
            //Service Message
            if(!container.mapBillItemId2ServiceMessage.isEmpty()) {
                if(container.mapBillItemId2ServiceMessage.containsKey(billItem.Id) && container.mapBillItemId2ServiceMessage.get(billItem.Id) != null)  {
                    If(container.mapBillItemId2ServiceMessage.get(billItem.Id) != null) 
                        ServiceMessage = container.mapBillItemId2ServiceMessage.get(billItem.Id).MessageText__c ;
                }
             }
            
            BillItemTax = new list<BillItemTax>() ;
            if(billItem.Bill_Item_Tax__r != null && !billItem.Bill_Item_Tax__r.isEmpty()) { // Bill Item Tax
                for(BillItemTax__c billItemTaxObj : billItem.Bill_Item_Tax__r) {
                     BillItemTax.add(new BillItemTax(container, billItemTaxObj)) ;
                }
            }    
            
            //AT-4388
            BillItemDiscount = new list<BillItemDiscount>() ;
            if(billItem.BillItemDiscount__r != null && !billItem.BillItemDiscount__r.isEmpty()) { // BillItemDiscount TopUp
                for(BillItemDiscount__c billItemDiscObj : billItem.BillItemDiscount__r) {
                    BillItemDiscount.add(new BillItemDiscount(container, billItemDiscObj)) ;
                }
            } 
       
            AverageDailyUse = new list<AverageDailyUse>() ;     // ADU
            SupplyPointDevice = new list<SupplyPointDevice>() ;  // SPD
            if(!container.mapBillItemId2SpdAndAdu.isEmpty() && container.mapBillItemId2SpdAndAdu.containsKey(billItem.Id)) {
                SupplyPointDevice__c spd = container.mapBillItemId2SpdAndAdu.get(billItem.Id) ;
                SupplyPointDevice.add(new SupplyPointDevice(container ,spd)) ;
                
            }
            
            // Location & Location Occupant
            Location = new List<Location> () ;
            if(!container.mapBillItemId2Listlocation.isEmpty() && container.mapBillItemId2Listlocation.containsKey(billItem.Id)) {
                for(Location__c loc : container.mapBillItemId2Listlocation.get(billItem.Id)) {
                    Location.add(new Location(container, loc)) ;
                }
            }
            
            //AT-3166 Agreed Volume
            AgreedVolume = new List<AgreedVolume> () ;
            if(!container.mapBillItemId2AgreedVolume.isEmpty() && container.mapBillItemId2AgreedVolume.containsKey(billItem.Id)) {
                for(AgreedVolume__c agrVol : container.mapBillItemId2AgreedVolume.get(billItem.Id)) {
                    AgreedVolume.add(new AgreedVolume(container, agrVol)) ;
                }
            }
            
            //AT-3166 Standard Sample Strength
            StandardSampleStrength = new List<StandardSampleStrength> () ;
            if(!container.mapBillItemId2StandardSampleStrength.isEmpty() && container.mapBillItemId2StandardSampleStrength.containsKey(billItem.Id)) {
                for(StandardSampleStrength__c sST : container.mapBillItemId2StandardSampleStrength.get(billItem.Id)) {
                    StandardSampleStrength.add(new StandardSampleStrength(container, sST)) ;
                }
            }
       
            //Device and Reading  
            Device = new list<Device>() ;
            if(!container.mapBillItemId2ListDevice.isEmpty() && container.mapBillItemId2ListDevice.containsKey(billItem.Id)) {
                for(Device__c deviceObj : container.mapBillItemId2ListDevice.get(billItem.Id)) {
                    Device.add(new Device(container, deviceObj)) ;
                }
            }
            
            //Start of AT - 2783
            //Volume Alteration Items
            VolumeAlterationItem = new List<VolumeAlterationItem>() ;
            if(billItem.VolumeAlterationItem__r != null && !billItem.VolumeAlterationItem__r.isEmpty()) {   // Bill Item Tax
                for(VolumeAlterationItem__c volumeAlterationItemObj : billItem.VolumeAlterationItem__r) {
                     VolumeAlterationItem.add(new VolumeAlterationItem(container, volumeAlterationItemObj)) ;
                }
            }//End of AT - 2783
        }
    }
    /******************************************************************************
    @author         Echo: Amit  Kumar
    @date           14 Dec 2018
    @description    Subclass for Bill(AT-4475)
    *******************************************************************************/
    private class RuralEntitlement {
        private String EndDate;
        private Decimal BaseVolume;
        private Decimal SeasonalAllocation;
        private Decimal PermanentTransfersIn;
        private Decimal PermanentTransfersOut;
        private Decimal TemporaryTransfersIn;
        private Decimal TemporaryTransfersOut;
        private Decimal DeliveryMeteredVolume;
        private Decimal DeliveryHeadVolume;
        private Decimal DeliveryUncontrolledVolume;
        private Decimal AllocatedVolume;
        private String LicenseNumber;
        private String TransferDate;
        /******************************************************************************
        @author         Echo: Amit Kumar
        @date           14 Dec 2018
        @param          BlUt_BillDataTransferXMLContainer - instance of the container class
        @param          RuralEntitlement__c - rural Entitlement record
        @description    Constructor
        *******************************************************************************/
        private RuralEntitlement(BlUt_BillXMLContainer container, RuralEntitlement__c ruralEntitlement) {
            EndDate = dateToString(ruralEntitlement.EndDate__c);
            BaseVolume = ruralEntitlement.BaseVolume__c;
            SeasonalAllocation = ruralEntitlement.SeasonalAllocation__c;
            PermanentTransfersIn = ruralEntitlement.PermanentTransfersIn__c;
            PermanentTransfersOut = ruralEntitlement.PermanentTransfersOut__c;
            TemporaryTransfersIn = ruralEntitlement.TemporaryTransfersIn__c;
            TemporaryTransfersOut = ruralEntitlement.TemporaryTransfersOut__c;
            DeliveryMeteredVolume = ruralEntitlement.DeliveredMeteredVolume__c;
            DeliveryHeadVolume = ruralEntitlement.DeliveredHeadVolume__c;
            DeliveryUncontrolledVolume = ruralEntitlement.DeliveredUncontrolledVolume__c;
            AllocatedVolume = ruralEntitlement.AllocatedVolume__c;
            LicenseNumber = ruralEntitlement.RuralLicense__r.Name;
            TransferDate = dateToString(ruralEntitlement.RuralLicense__r.TransferredFromLicense__r.TransferDate__c);
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           9 June 2018
    @description    Subclass for ServiceMessage - Commented for future just in case multiple messages are required
    *******************************************************************************/
    private class ServiceMessage {
        private String MessageText ;
        
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           9 June 2018
        @param          BlUt_BillXMLContainer - instance of the container class
        @param          ServiceMessage__c serviceMessage
        @description    Constructor
        *******************************************************************************/
        private ServiceMessage(BlUt_BillXMLContainer container, ServiceMessage__c serviceMessage) {
            MessageText = serviceMessage.MessageText__c ;
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           5 June 2018
    @description    Subclass for BillItemTax
    *******************************************************************************/
    private class BillItemTax {
        private String Name ;
        private String Amount ;
        private String PercentTax; //AT-5639, Ankit, 25/04/2019
        
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           5 June 2018
        @param          BlUt_BillXMLContainer - instance of the container class
        @param          BillItemTax__c billItemTax - billItemTax record
        @description    Constructor
        *******************************************************************************/
        private BillItemTax(BlUt_BillXMLContainer container, BillItemTax__c billItemTax) {
            Name = billItemTax.Name ;
            Amount = String.valueOf(billItemTax.TaxAmount__c) ;
            PercentTax = String.valueOf(billItemTax.Tax__r.PercentTax__c); //AT-5639, Ankit, 25/04/2019
        }
    }
                    
    /******************************************************************************
    @author         Echo: Vivek Sethi  AT-4388
    @date           20 Nov 2018
    @description    Subclass for BillItemDiscount
    *******************************************************************************/
    private class BillItemDiscount {
        private Boolean TopUp ;
        
        /******************************************************************************
        @author         Echo: Vivek Sethi  
        @date           20 Nov 2018
        @param          BlUt_BillXMLContainer - instance of the container class
        @param          BillItemDiscount__c BillItemDiscount
        @description    Constructor
        *******************************************************************************/
        private BillItemDiscount(BlUt_BillXMLContainer container, BillItemDiscount__c billItemDisc) {
            if(billItemDisc.Discount__r.DiscountType__r.TopUp__c != null)
                TopUp = billItemDisc.Discount__r.DiscountType__r.TopUp__c  ;
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           5 June 2018
    @description    Subclass for SupplyPointDevice
    *******************************************************************************/
    private class SupplyPointDevice {
        private String InstallationDate;
        //AT-4475 Starts Here
        private String ReadFrequency; 
        private String RuralOutletType; 
        private String AccessType;
        private String RuralChannelName;
        //AT-4475 Ends Here
        private List<AverageDailyUse> AverageDailyUse;

        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           5 June 2018
        @param          BlUt_BillXMLContainer - instance of the container class
        @param          SupplyPointDevice__c - supplyPointDevice record
        @description    Constructor
        *******************************************************************************/
        private SupplyPointDevice(BlUt_BillXMLContainer container, SupplyPointDevice__c supplyPointDevice) {
            // add the fields to this DTO
            InstallationDate = dateToString(supplyPointDevice.InstallationDate__c);
            //AT-4475 Starts Here
            ReadFrequency = supplyPointDevice.ReadFrequency__c ;
            RuralOutletType = supplyPointDevice.SupplyPoint__r.RuralOutletType__c;
            AccessType = supplyPointDevice.SupplyPoint__r.AccessType__c;
            RuralChannelName = supplyPointDevice.SupplyPoint__r.RuralChannel__r.Name;
            //AT-4475 Ends Here
            // build the list of average daily use DTOs
            AverageDailyUse = new List<AverageDailyUse>();
            for (AverageDailyUsage__c thisAverageDailyUse : supplyPointDevice.AverageDailyUsage__r) {
                AverageDailyUse.add(new AverageDailyUse(container, thisAverageDailyUse));
            }
        }
    }

    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           5 June 2018
    @description    Subclass for AverageDailyUsage
    *******************************************************************************/
    private class AverageDailyUse {
        private String StartDate;
        private String EndDate;
        private Decimal AverageDailyUsage;
        private Boolean Invalid; //AT-3555
        private String Account;  //AT-5350

        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           5 June 2018
        @param          BlUt_BillXMLContainer - instance of the container class
        @param          AverageDailyUsage__c - averageDailyUse record
        @description    Constructor
        *******************************************************************************/
        private AverageDailyUse(BlUt_BillXMLContainer container, AverageDailyUsage__c averageDailyUse) {
            // add the averageDailyUsage fields to this DTO
            StartDate = dateToString(averageDailyUse.StartDate__c);
            EndDate = dateToString(averageDailyUse.EndDate__c);
            AverageDailyUsage = averageDailyUse.AverageDailyUsage__c;
            Invalid = averageDailyUse.Invalid__c;   //AT-3555
            Account = averageDailyUse.Account__c;   //AT-5350
        }
    }

    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           5 June 2018
    @description    Subclass for Location
    *******************************************************************************/
    private class Location {
        private String Street;
        private String City;
        private String State;
        private String Country;        
        private String PostalCode;   
        private String RuralLicenseName; //AT-4475
        private String LocationAuDpid; //AT-4858
        private List<LocationOccupant> LocationOccupant;
        private List<LocationMessage> LocationMessage ;	// Sudhir: AU3__AT-4950

        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           5 June 2018
        @param          BlUt_BillXMLContainer - instance of the container class
        @param          Location__c - location record
        @description    Constructor
        *******************************************************************************/
        private Location(BlUt_BillXMLContainer container, Location__c location) {            
            // add the fields to this DTO
            Street = location.Street__c;
            City = location.City__c;
            State = location.State__c;
            Country = location.Country__c;
            PostalCode = location.PostalCode__c;
            RuralLicenseName = location.RuralLicense__r.Name; //AT-4475
            LocationAuDpid = location.AuDPID__c; //AT-4858
            // build the list of related location occupant DTOs
            LocationOccupant = new List<LocationOccupant>();
            for (LocationOccupant__c thisLocationOccupant : location.LocationOccupants__r) {
                LocationOccupant.add(new LocationOccupant(container, thisLocationOccupant));
            }
            // build the list of related location message DTOs: AU__AT-4950
            LocationMessage = new List<LocationMessage>();
            for (LocationMessage__c thisLocationMessage : location.LocationMessages__r) {
                LocationMessage.add(new LocationMessage(container, thisLocationMessage));
            }
        }
    }
 	/******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           16 Jan 2019
    @description    Subclass for LocationMessage // Sudhir: AU3__AT-4950
    *******************************************************************************/
    private class LocationMessage {
        //private String Name;
        private String Description;
        
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           5 June 2018
        @param          BlUt_BillXMLContainer - instance of the container class
        @param          LocationOccupant__c - location occupant record
        @description    Constructor
        *******************************************************************************/
        private LocationMessage(BlUt_BillXMLContainer container, LocationMessage__c locationMessage) {
            // add the fields to this DTO
            //Name = locationMessage.Name;
            Description = locationMessage.Description__c;
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           5 June 2018
    @description    Subclass for LocationOccupant
    *******************************************************************************/
    private class LocationOccupant {
        private String Name;
        private String OccupancyType;
        private String ShowOnBill;
        private String StartDate;        
        private String EndDate;        
        private Boolean Primary ;
        private String AccountName; //AT-5535, Ankit, 23/04/2019
        
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           5 June 2018
        @param          BlUt_BillXMLContainer - instance of the container class
        @param          LocationOccupant__c - location occupant record
        @description    Constructor
        *******************************************************************************/
        private LocationOccupant(BlUt_BillXMLContainer container, LocationOccupant__c locationOccupant) {
            // add the fields to this DTO
            Name = locationOccupant.Name;
            
            OccupancyType = locationOccupant.OccupancyType__c;
            ShowOnBill = String.valueOf(locationOccupant.ShowOnBill__c);
            StartDate = dateToString(locationOccupant.StartDate__c);
            EndDate = dateToString(locationOccupant.EndDate__c);
            Primary = locationOccupant.Primary__c ;
            AccountName = locationOccupant.Account__r.Name; //AT-5535, Ankit, 23/04/2019
        }
    }
    
    /******************************************************************************
    @author         Echo: Vivek Sethi AT-3166
    @date           26 July 2018
    @description    Subclass for Agreed Volume
    *******************************************************************************/
    private class AgreedVolume {
        private Decimal AgreedVolume;
        
        /******************************************************************************
        @author         Echo: Vivek Sethi AT-3166
        @date           26 July 2018
        @param          BlUt_BillXMLContainer - instance of the container class
        @param          AgreedVolume__c - Agreed Volume record
        @description    Constructor
        *******************************************************************************/
        private AgreedVolume(BlUt_BillXMLContainer container, AgreedVolume__c AgreedVol) {
            AgreedVolume = AgreedVol.AgreedVolume__c;
        }
    }
 
    /******************************************************************************
    @author         Echo: Vivek Sethi AT-3166
    @date           26 July 2018
    @description    Subclass for StandardSampleStrength
    *******************************************************************************/
    private class StandardSampleStrength {
        private Decimal CODStandardStrength;
        private Decimal SSStandardStrength;
        
        /******************************************************************************
        @author         Echo: Vivek Sethi AT-3166
        @date           26 July 2018
        @param          BlUt_BillXMLContainer - instance of the container class
        @param          StandardSampleStrength__c - Standard Sample Strength
        @description    Constructor
        *******************************************************************************/
        private StandardSampleStrength(BlUt_BillXMLContainer container, StandardSampleStrength__c StdSampleStrength) {
            CODStandardStrength = StdSampleStrength.CODStandardStrength__c;
            SSStandardStrength =  StdSampleStrength.SSStandardStrength__c;
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           5 June 2018
    @description    Subclass for ContractBillMessage - Commented for future just in case multiple messages are required
                    code uncommented under AT-3046
    *******************************************************************************/    
    public class ContractBillMessage {
        private String BillMessage_MessageText ;
        
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           5 June 2018
        @param          BlUt_BillXMLContainer - instance of the container class
        @param          ContractBillMessage__c - contractBillMessage record
        @description    Constructor
        *******************************************************************************/
         public ContractBillMessage(BlUt_BillXMLContainer container, ContractBillMessage__c contractBillMessage) {
            BillMessage_MessageText = contractBillMessage.BillMessage__r.MessageText__c ;
        }
    } 
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           5 June 2018
    @description    Subclass for Payment
    *******************************************************************************/
    public class Payment {
        private String Amount;
        private String PaymentMethod;
        private String PaymentSource;
        private String attr_RecordType;
        private String RecordType;        
        private String PaymentDate;  
        private List<BalanceTransaction> BalanceTransaction ;
        
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           5 June 2018
        @param          BlUt_BillXMLContainer - instance of the container class
        @param          LocationOccupant__c - location occupant record
        @description    Constructor
        *******************************************************************************/
        public Payment(BlUt_BillXMLContainer container, Payment__c payment) {
            // add the fields to this DTO
            Amount = String.valueOf(payment.Amount__c);
            PaymentMethod = payment.PaymentMethod__c;
            PaymentSource = payment.PaymentSource__c;
            PaymentDate = dateToString(payment.PaymentDate__c );
            attr_RecordType = payment.RecordType.Name ;
            RecordType = payment.RecordType.Name ;
            //start
            BalanceTransaction = new List<BalanceTransaction>();
            if(container.mapPaymentIdToBalanceTransactions.containsKey(payment.Id)){
                for(BalanceTransaction__c objBT : container.mapPaymentIdToBalanceTransactions.get(payment.Id)){
                    BalanceTransaction.add(new BalanceTransaction(container, objBT));                                    
                }//end
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           02 Nov 2018
    @description    Subclass for Balance Transaction
    *******************************************************************************/
    public class BalanceTransaction {
        private Id balance;
        private String Amount;
        private Id payment;
        private String RecordType;    
        
        /******************************************************************************
        @author         Echo: Ankit Gangwani
        @date           02 Nov 2018
        @param          BlUt_BillXMLContainer - instance of the container class
        @param          BlUt_BillXMLContainer container, BalanceTransaction__c objBalanceTransaction
        @description    Constructor
        *******************************************************************************/
        public BalanceTransaction(BlUt_BillXMLContainer container, BalanceTransaction__c objBT) {
            Amount = String.valueOf(objBT.Amount__c);
            payment = objBT.Payment__c;
            balance = objBT.Balance__c;            
            RecordType = objBT.RecordType.Name ;            
        }
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           09 Aug 2018
    @description    Subclass for Bill Transfer
    *******************************************************************************/
    private class BillTransfer {
        
        private String TransferBillId; 
        private String StartDate; 
        private String EndDate; 
        private String BillDate; 
        private Decimal BilledAmount; 
        private String TransferredFromContract; 
        private String TransferReason; 
        private String TransferDate; 
        
        /******************************************************************************
        @author         Echo: Tarun Gupta
        @date           09 Aug 2018
        @param          BlUt_BillDataTransferXMLContainer - instance of the container class
        @param          Bill__c - bill record
        @description    Constructor
        *******************************************************************************/
        private BillTransfer(BlUt_BillXMLContainer container, Bill__c billObj) {
            // add the fields to this DTO
            
            TransferBillId= billObj.Id;
            StartDate = dateToString(billObj.StartDate__c);
            EndDate = dateToString(billObj.EndDate__c);
            BillDate = dateToString(billObj.BillDate__c);
            BilledAmount = billObj.BilledAmount__c;
            TransferredFromContract = billObj.TransferredBillTransfer__r.TransferFromContract__c;
            TransferReason = billObj.TransferredBillTransfer__r.TransferReason__c;
            TransferDate = string.valueOf(billObj.TransferredBillTransfer__r.CreatedDate);            
            system.debug('Exit-BillTransfer Constructor');
        }
    }

    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           5 June 2018
    @description    Subclass for Payment Plan
    *******************************************************************************/
    private class PaymentPlan {
        private String Name; 
        private String PaymentFrequency; 
        private Decimal PaymentPlanTotal; 
        private String StartDate;
        private Decimal TotalInstalmentAmount;
        private List<Instalment> Instalment;

        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           5 June 2018
        @param          BlUt_BillXMLContainer - instance of the container class
        @param          PaymentPlan__c - payment plan record
        @description    Constructor
        *******************************************************************************/
        private PaymentPlan(BlUt_BillXMLContainer container, PaymentPlan__c paymentPlan) {
            // add the fields to this DTO
            Name = paymentPlan.Name;
            PaymentFrequency = paymentPlan.PaymentFrequency__c;
            PaymentPlanTotal = paymentPlan.PaymentPlanTotal__c;
            StartDate = dateToString(paymentPlan.StartDate__c);
            TotalInstalmentAmount = paymentPlan.TotalInstalmentAmount__c;
            // build the list of related instalment DTOs
            Instalment = new List<Instalment>();
            for (Instalment__c thisInstalment : paymentPlan.Instalments__r) {
                Instalment.add(new Instalment(container, thisInstalment));
            }
        }
    }

    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           5 June 2018
    @description    Subclass for Instalment
    *******************************************************************************/
    private class Instalment {
        private Decimal InstalmentAmountDue; 
        private Decimal InstalmentAmountOutstanding; 
        private String InstalmentDueDate; 
        private Integer InstalmentNumber;
        private Decimal SumofAllocatedPayment;

        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           5 June 2018
        @param          BlUt_BillXMLContainer - instance of the container class
        @param          Instalment__c - instalment record
        @description    Constructor
        *******************************************************************************/
        private Instalment(BlUt_BillXMLContainer container, Instalment__c instalment) {
            // add the fields to this DTO
            InstalmentAmountDue = instalment.InstalmentAmountDue__c; 
            InstalmentAmountOutstanding = instalment.InstalmentAmountOutstanding__c; 
            InstalmentDueDate = dateToString(instalment.InstalmentDueDate__c); 
            InstalmentNumber = Integer.valueOf(instalment.InstalmentNumber__c); 
            SumofAllocatedPayment = instalment.SumofAllocatedPayment__c;
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           5 June 2018
    @description    Subclass for  Device
    *******************************************************************************/
    private  class Device {
        private String attr_Name ;
        private String Name ;
        private String SerialNumber;
        private String Digits;
        private String DeviceType;
        private String DeviceSize ;   //AT-3047
        private List<Reading> Reading;  

        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           5 June 2018
        @param          BlUt_BillXMLContainer container, 
        @param          Device__c device - device record 
        @description    Constructor
        *******************************************************************************/
        private Device(BlUt_BillXMLContainer container, Device__c device) {
            // add the sub device fields to this DTO
            attr_Name = device.Name ;
            Name = device.Name ;
            SerialNumber = device.SerialNo__c;
            DeviceSize = device.DeviceType__r.DeviceSize__r.Name;    //AT-3047
            Digits = String.valueOf(device.Digit__c);
            DeviceType = device.DeviceType__c;
            // build the list of related readings DTOs
            Reading = new List<Reading>();  
            for (Reading__c thisReading : device.Readings__r) { //AT-3174
                if (thisReading.Device__c == device.Id) {
                    Reading.add(new Reading(container, thisReading));
                }
            }
        }
    }
    
    /******************************************************************************
    @author         
    @date           
    @description    Subclass for Reading
    *******************************************************************************/
    private class Reading {
        private Decimal Reading;
        private Id ReadingId; //AT-4301
        private String ReadingDate;
        private String ReadingSource;
        private String ReadingMethod;
        private String ReadingType; 
        private String Leak; //AT-2932
        private Decimal EffectiveReading; //AT-2932 

        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           5 June 2018
        @param          Reading__c - reading record
        @description    Constructor
        *******************************************************************************/
        private Reading(BlUt_BillXMLContainer container, Reading__c reading) {
            // add the fields to this DTO
            this.Reading = reading.Reading__c;
            ReadingId = reading.Id; //AT-4301
            ReadingDate = dateToString(reading.ReadingDate__c);
            ReadingSource = reading.ReadingSource__c; 
            ReadingMethod = reading.ReadingMethod__c; 
            ReadingType = reading.ReadingType__c;
            Leak = String.valueOf(reading.Leak__c); //AT-2932
            EffectiveReading = reading.EffectiveReading__c; //AT-2932
            // mapping needs to be done
            }
        }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           25 June 2018
    @description    AT - 2783 Subclass for VolumeAlterationItem
    *******************************************************************************/
    private class VolumeAlterationItem {
        private String StartDate ;
        private String EndDate ;
        private Decimal AllowanceApplied ;
        private String SupplyPointAllowance_Type ;
        private Decimal Order ;
        
        /******************************************************************************
        @author         Echo: Mohit Tayal
        @date           25 June 2018
        @param          BlUt_BillXMLContainer - instance of the container class
        @param          VolumeAlterationItem__c volumeAlterationItem - volumeAlterationItem record
        @description    Constructor
        *******************************************************************************/
        private VolumeAlterationItem(BlUt_BillXMLContainer container, VolumeAlterationItem__c volumeAlterationItem) {
            StartDate = dateToString(volumeAlterationItem.StartDate__c) ;
            EndDate = dateToString(volumeAlterationItem.EndDate__c) ;
            AllowanceApplied = volumeAlterationItem.AllowanceApplied__c;
            if(volumeAlterationItem.SupplyPointAllowance__c != null)
                SupplyPointAllowance_Type = volumeAlterationItem.SupplyPointAllowance__r.Type__c;
            Order = volumeAlterationItem.Order__c;
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           5 June 2018        
    @param          none
    @description    bill field list for query in the batch class
    *******************************************************************************/
    public static list<String> billFieldList = new list<String> {   
        GlUt_APIConstantsBill.BILLDATEAPINAME,
            GlUt_APIConstantsBill.BILLNUMBERAPINAME,  // TG 28/11 , AT-4349,4289
            GlUt_APIConstantsBill.STARTDATEAPINAME,
            GlUt_APIConstantsBill.ENDDATEAPINAME,
            GlUt_APIConstantsBill.TOTALAMOUNTOUTSTANDINGAPINAME,
            GlUt_APIConstantsBill.CONTRACTNUMBERAPINAME,
            GlUt_APIConstantsBill.BILLEDAMOUNTAPINAME,
            GlUt_APIConstantsBill.BILL_TYPE,
            GlUt_APIConstantsBill.PRINTXMLAPINAME,
            GlUt_APIConstantsBill.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.CUSTOMERAPINAME,
            GlUt_APIConstantsBill.ACCOUNTAPINAME, //AT-3174
            GlUt_APIConstantsBill.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.RELATED_ACCOUNT + '.' + GlUt_APIConstantsAccount.ACCOUNTNAMEAPINAME, 
            GlUt_APIConstantsBill.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.RELATED_ACCOUNT + '.' + GlUt_APIConstantsAccount.ACCOUNTREFERENCEAPINAME, 
            GlUt_APIConstantsBill.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.CONTRACTNAMEAPINAME, 
            GlUt_APIConstantsBill.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.CURRENTPAYMENTPLANTYPE, 
            GlUt_APIConstantsBill.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.DAYOFMONTHAPINAME, 
            GlUt_APIConstantsBill.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.DAYOFWEEKAPINAME, 
            GlUt_APIConstantsBill.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.BILLINGSTREETNAME, 
            GlUt_APIConstantsBill.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.BILLINGCITYAPINAME, 
            GlUt_APIConstantsBill.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.BILLINGSTATEAPINAME, 
            GlUt_APIConstantsBill.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.BILLINGCOUNTRYAPINAME, 
            GlUt_APIConstantsBill.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.BILLINGPOSTALCODEAPINAME, 
            GlUt_APIConstantsBill.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.PAYMENTMETHODTYPEAPINAME, 
            GlUt_APIConstantsBill.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.STARTDATE, 
            GlUt_APIConstantsBill.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.CONTRACTBALANCEAPINAME, 
            GlUt_APIConstantsBill.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsBalances.BALANCERELAPINAME + '.' +  GlUt_APIConstantsBalances.BALANCESNAPSHOTAPINAME,
            GlUt_APIConstantsBill.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.BALANCEAPINAME, 
            GlUt_APIConstantsBillEvent.BILLEVENTAPINAME,  
            GlUt_APIConstantsBill.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.RELATED_ACCOUNT + '.' + GlUt_APIConstantsAccount.RECORD_TYPE + '.' + GlUt_APIConstantsAccount.ACCOUNTNAMEAPINAME,
            // MT - 20 Aug 2018 Start of AT-3409    
            GlUt_APIConstantsContracts.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.USEALTERNATIVEADDRESSAPINAME,
            GlUt_APIConstantsContracts.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.ALTERNATIVEBILLINGRELAPINAME + '.' + GlUt_APIConstantsAccount.BILLINGSTREETAPINAME,
            GlUt_APIConstantsContracts.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.ALTERNATIVEBILLINGRELAPINAME + '.' + GlUt_APIConstantsAccount.BILLINGCITYAPINAME,
            GlUt_APIConstantsContracts.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.ALTERNATIVEBILLINGRELAPINAME + '.' + GlUt_APIConstantsAccount.BILLINGSTATEAPINAME,
            GlUt_APIConstantsContracts.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.ALTERNATIVEBILLINGRELAPINAME + '.' + GlUt_APIConstantsAccount.BILLINGCOUNTRYAPINAME,
            GlUt_APIConstantsContracts.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.ALTERNATIVEBILLINGRELAPINAME + '.' + GlUt_APIConstantsAccount.BILLINGPOSTALCODEAPINAME,
            // End of AT-3409
            // AT-4933 Starts Here
            GlUt_APIConstantsContracts.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.ALTERNATIVEBILLINGNAMEAPINAME,
            GlUt_APIConstantsContracts.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.ALTERNATIVEBILLINGRELATIONSHIPAPINAME,
            // AT-4933 Ends Here
            
            // AT-4858 Starts Here
            GlUt_APIConstantsContracts.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.BILLINGAUDPIDAPINAME,
            GlUt_APIConstantsContracts.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.ALTERNATEAUDPIDAPINAME,
            GlUt_APIConstantsBill.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.RELATED_ACCOUNT + '.' + GlUt_APIConstantsAccount.AUDPIDAPINAME 
            // AT-4858 Ends Here
    } ;
        
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           1 Nov 2018        
    @param          none
    @description    Get Query String   // AU1 AT-4098
    *******************************************************************************/
    public String getQueryString(Id recordId, String filterCriteria) {
        String queryString = '' ;
        queryString = String.format('SELECT {0} FROM {1}' , new List<String> {'Id, ' + String.join(BlUt_BillXMLContainer.billFieldList, ',') , GlUt_APIConstantsBill.BILLAPINAME}) ;
        if(String.isNotBlank(filterCriteria)) {
            queryString += ' WHERE ' + filterCriteria ;
        }
        
        return queryString ;
    }                                   
}