/******************************************************************************
@author         Accenture: Patrick Dixon
@date           01 Sep 2017
@description    Container class for JSON billing response

        This class runs without object and field permission checks since: 
        (a) Its primary function is to synchronise data between Heroku and Salesforce
            and this requires access to all records/fields
        (b) It does not expose record data to the user

@revision(s)    07 Nov 2017, P Dixon - MP2
                15 Nov 2017, P Dixon - Added BillItem to Bill lookup relationship
                14 Dec 2017, P Dixon - Updated Payload for MP2
                02 Jan 2018, Amit K. - Make the private variable and method test visible.
                05 Feb 2018, P Dixon - Updated Payload for MP3 to add BillItemTax and BillItemDiscount objects
                15 Mar 2018, P Dixon - Updated Payload for MP4 to add BillItemAmendment object
                08 June 2018, AT-2715 , T Gupta - Made changes to link Bill Event to Bill object in response
                30 Oct  2018, Sudhir Kumar - AT-4123 - Salesforce Payload Regular Bill Calciulation
                18 Dec  2018, Amit K. - AT- 4485 - Add Regular gross consumption on Bill Item.
                24 Dec  2018, Tarun Gupta - AT- 4866 - Added Do Not Print on Bill.
                20 Feb  2019, Sudhir Kumar AT-3489: Site Supply
				29 Apr  2019, Tarun AT-5605
*******************************************************************************/
public with sharing class BlIn_BillCalcResponseContainer {

    private static final String CLASS_NAME = 'BlIn_BillCalcResponseContainer';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    // utility methods to cope with null values in the response
    private static Date dateEscapeNull(String s) {return s != null ? Date.valueOf(s) : null;}
    private static Decimal decimalEscapeNull(String s) {return s != null ? Decimal.valueOf(s) : null;}
    private static Integer integerEscapeNull(String s) {return s != null ? Integer.valueOf(s) : null;}
    private static Boolean booleanEscapeNull(String s) {return s != null ? s.toLowerCase() == 'true' : false;}

    // Bill Calculation
    public String Status;
    @TestVisible private List<BlIn_BillCalcResponseBillObj> Bills;
    @TestVisible private List<BlIn_BillCalcResponseBillItemAmendmentObject> Amendments; 
    
    // Bill
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           01 Sep 2017
    @description    Subclass for Bill JSON Object
    *******************************************************************************/
    @TestVisible 
    private class BlIn_BillCalcResponseBillObj {
        
        @TestVisible  private String Id;      // Heroku Postgres Id
        @TestVisible  private String Name;
        @TestVisible  private String BillDate;
        @TestVisible  private String AccountId;
        @TestVisible  private String ContractGroupId;
        @TestVisible  private String ContractId;
        @TestVisible  private String StartDate;
        @TestVisible  private String EndDate;
        @TestVisible  private String BilledAmount;
        @TestVisible  private String TotalDue;
        @TestVisible  private String FinalBill;
        @TestVisible  private String BillType;
        @TestVisible  private String LatestPendingBill;
        @TestVisible  private String BillCalculationReason;
        @TestVisible  private String BillEventId;
        //MT - 25/05/2018 AT - 2663 Defined a total discount amount variable
        @TestVisible  private String TotalDiscountAmount;
        @TestVisible  private String DoNotPrint; //AT-4866
        /* salesforce only fields
            PrintBill__c
            PrintDate__c
            ExcludeFromBatchPrint__c
        */
      
        @TestVisible  private List<BlIn_BillCalcResponseBillServiceTypeObject> BillServiceTypes;
        @TestVisible  private String AnnualBill; //UL-534
    }
    
    // Bill Services
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           20 Sep 2017
    @description    Subclass for Bill Services Type JSON Object
    *******************************************************************************/
    @TestVisible private class BlIn_BillCalcResponseBillServiceTypeObject {
        
        @TestVisible  private String Id;      // Heroku Postgres Id
        @TestVisible  private String Name;
        @TestVisible  private String ServiceTypeId;
        @TestVisible  private String TotalBilledAmount;
        @TestVisible  private String TotalDiscountAmount;
        @TestVisible  private List<BlIn_BillCalcResponseBillItemObject> BillItems;
    }
    
    // Bill Items
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           01 Sep 2017
    @description    Subclass for Bill Item JSON Object
    *******************************************************************************/
    @TestVisible  private class BlIn_BillCalcResponseBillItemObject {
        
        @TestVisible  private String Id;      // Heroku Postgres Id
        @TestVisible  private String Name;
        @TestVisible  private String ServiceItemId;      // required (master-detail)
        @TestVisible  private String BillItemId; 
        @TestVisible  private String RateId; 
        @TestVisible  private String RateBandId; 
        @TestVisible  private String AgreedRateId;
        @TestVisible  private String ChargeBasisId;
        @TestVisible  private String ReadingId; 
        @TestVisible  private String OriginalCalculationDate;
        @TestVisible  private String StartDate;
        @TestVisible  private String EndDate;
        @TestVisible  private String VolumeUsed;
        @TestVisible  private String BilledAmount;
        @TestVisible  private String NetBilledAmount;
        //@TestVisible  private String GrossConsumption; AT-2159
        @TestVisible  private String NetConsumption;
        @TestVisible  private String EstimatedConsumption;
        @TestVisible  private String NegatedBillItem;
        @TestVisible  private String ReplacedByNewBillItems;
        @TestVisible  private String ManualAmendmentId;
        @TestVisible  private String AmendmentDate;
        @TestVisible  private String TotalCalculatedAllowance;
        @TestVisible  private String TotalDiscountAmount;
        @TestVisible  private String TotalTaxAmount;
        
        @TestVisible  private String ConsumptionAllowance;
        @TestVisible  private String AgreedSampleStrengthId;
        @TestVisible  private String AgreedVolumeId;
        //AT-4996, Ankit, 18/01/2018
        @TestVisible  private String FreeStrengthId;
        @TestVisible  private String PSampleStrength;
        @TestVisible  private String TDSSampleStrength;
        @TestVisible  private String TKNSampleStrength;
        
        /* salesforce only fields
            NumberOfDays__c
            AmountPaid__c
            AmountOutstanding__c
            DebtAge__c
            Debt_Age_Bucket__c
        */

        // for top-up readings estimated by Heroku
        @TestVisible  private String TopUpId;       // UUID generated by Heroku for a Top-up reading
        @TestVisible  private String TopUpDate;
        @TestVisible  private String TopUpValue;
        @TestVisible  private String TopUpDeviceId;

        @TestVisible  private List<BlIn_BillCalcResponseBillItemTaxObject> BillItemTaxes;
        @TestVisible  private List<BlIn_BillCalcResponseBillItemDiscountObject> BillItemDiscounts;
        //Start of AT - 2781
        @TestVisible  private List<BlIn_BillCalcResponseBillItemVolumeAlterationItemObject> VolumeAlterationItems;
        //End of AT - 2781
        @TestVisible  private String SteppedTariffId;
        @TestVisible  private String SteppedTariffServiceId;
        
        @TestVisible  private String StartReadingID;   //AT-3393
        @TestVisible  private String EndReadingID;     //AT-3393
        @TestVisible private String SupplyPointId ; // Sudhir: AU1 - AT-4123
        @TestVisible private String RuralGrossConsumptionId ; // AU2 - AT-4485
        @TestVisible private String ServiceItemToleranceId; //UK1-UL-22, Ankit, 14 Feb 2019
        @TestVisible private String SiteSupplyId ; // AT-3489
    }
    
    // Bill Item Taxes
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           05 Feb 2018
    @description    Subclass for Bill Item Tax JSON Object
    *******************************************************************************/
    @TestVisible  private class BlIn_BillCalcResponseBillItemTaxObject {
        
        @TestVisible  private String Id;      // Heroku Postgres Id
        @TestVisible  private String Name;
        @TestVisible  private String BillItemId; 
        @TestVisible  private String TaxId;
        @TestVisible  private String TaxClassificationId;
        @TestVisible  private String TaxAmount;
        @TestVisible  private String StartDate;
        @TestVisible  private String EndDate;
    }
    
    // Bill Item Discounts
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           05 Feb 2018
    @description    Subclass for Bill Item Discount JSON Object
    *******************************************************************************/
    @TestVisible  private class BlIn_BillCalcResponseBillItemDiscountObject {
        
        @TestVisible  private String Id;      // Heroku Postgres Id
        @TestVisible  private String Name;
        @TestVisible  private String BillItemId; 
        @TestVisible  private String DiscountId;
        @TestVisible  private String DiscountAmount;
        @TestVisible  private String StartDate;
        @TestVisible  private String EndDate;
        @TestVisible  private String TopUp; //AT-4409
    }
    
    // Bill Item Amendments
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           15 Feb 2018
    @description    Subclass for Bill Item Amendment JSON Object
    *******************************************************************************/
    @TestVisible  private class BlIn_BillCalcResponseBillItemAmendmentObject {
        
        @TestVisible  private String Id;      // Heroku Postgres Id - HerokuPostgresId__c
        @TestVisible  private String Name;
        @TestVisible  private String BillItemId;
        @TestVisible  private String AmendmentReason;
        @TestVisible  private String AgreedSampleStrengthId;
        @TestVisible  private String AgreedVolumeId;
        @TestVisible  private String ChargeBasisId;
        @TestVisible  private String DiscountId;
        @TestVisible  private String ReadingId;
        @TestVisible  private String ServiceItemId;
        @TestVisible  private String TaxClassificationId;
        @TestVisible  private String ManualAmendmentId;
        @TestVisible  private String Amount;
        @TestVisible  private String DiscountAmount;
        @TestVisible  private String TaxAmount;
        @TestVisible  private String RuralGrossConsumptionId;
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           01 Sep 2017
    @param          String - json
    @return         BlIn_BillCalcResponseContainer - formatted billing object
    @description    parses and formats the JSON response 
    *******************************************************************************/
    public static BlIn_BillCalcResponseContainer parse(String json) {
        
        return (BlIn_BillCalcResponseContainer) System.JSON.deserialize(json, BlIn_BillCalcResponseContainer.class);
    }
    
    /******************************************************************************
    @author         Echo: Mohit Tayal
    @date           25 June 2018
    @description    AT - 2781 Subclass for Volume Alteration Item JSON Object
    *******************************************************************************/
    @TestVisible  private class BlIn_BillCalcResponseBillItemVolumeAlterationItemObject {
        
        @TestVisible  private String Id;      // Heroku Postgres Id
        //@TestVisible  private String SupplyPointAllowance;
        @TestVisible  private String SupplyPointAllowanceId; //AT-4439
        @TestVisible  private String AllowanceApplied; 
        @TestVisible  private String AllowanceAvailable;
        @TestVisible  private String StartDate;
        @TestVisible  private String EndDate;
        @TestVisible  private String BillItemId;
        @TestVisible  private String Order;
        //AT-4996, Ankit, 18/01/2018
        @TestVisible  private String FreeAllowanceId;        
        @TestVisible  private String ServiceItemAgreedVolumeId; //AT-4439
    }
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           20 Sep 2017
    @param          Id - bill calculation Id
    @param          BlIn_BillCalcResponseContainer - formatted billing object
    @return         List<Id> - bill Ids 
                        null if there were no bills in the response, 
                        an empty list if there was a conflict inserting and the Ids could not be recovered
    @description    builds and inserts the records 
    *******************************************************************************/
    public static List<Id> processResult(Id billCalculationId, BlIn_BillCalcResponseContainer result) { 

        system.debug(DEBUG + 'billCalculationId: ' + billCalculationId);
        system.debug(DEBUG + 'result: ' + result);
                
        List<Bill__c> billsInserted = new List<Bill__c>();
        List<String> billExtIds = new List<String>();
            
        List<BillItemAmendment__c> amendmentsToInsert = new List<BillItemAmendment__c>(); // MT - 14-08-2018 3174
        List<Id> billIds;
        System.debug(DEBUG + 'MAP BILLS--'+ result.Bills);
        List<BillServiceType__c> billServiceTypeInserted = new List<BillServiceType__c>();
        List<BillItem__c> billItemInserted = new List<BillItem__c>();
        List<BillItemTax__c> billItemTaxInserted = new List<BillItemTax__c>();
        List<BillItemDiscount__c> billItemDiscountInserted = new List<BillItemDiscount__c>();
        List<VolumeAlterationItem__c> billVolumeAlterationItemInserted = new List<VolumeAlterationItem__c>();
       
        for (BlIn_BillCalcResponseBillObj billObj : result.Bills) {
            Bill__c billReference = new Bill__c(HerokuPostgresId__c = billObj.Id);
            Bill__c bill = (new Bill__c(//Name = billObj.Name, -- AT 3174
                                        HerokuPostgresId__c = billObj.Id, 
                                        BillCalculation__c = (Id)billCalculationId, 
                                        BillDate__c = dateEscapeNull(billObj.BillDate),
                                        Account__c = (Id)billObj.AccountId, //AT 3174
                                        ContractGroup__c = (Id)billObj.ContractGroupId, 
                                        BillingContract__c = (Id)billObj.ContractId,                                                 
                                        StartDate__c = dateEscapeNull(billObj.StartDate), 
                                        EndDate__c = dateEscapeNull(billObj.EndDate), 
                                        BilledAmount__c = decimalEscapeNull(billObj.BilledAmount), 
                                        FinalBill__c = Boolean.valueOf(billObj.FinalBill), 
                                        DoNotPrint__c = Boolean.valueOf(billObj.DoNotPrint), //AT-4866
                                        AnnualBill__c = Boolean.valueOf(billObj.AnnualBill), //UL-534
                                        BillEvent__c = (Id)billObj.BillEventId,
                                        BillType__c = billObj.BillType, 
                                        BillCalculationReason__c = billObj.BillCalculationReason, 
                                        LatestPendingBill__c = booleanEscapeNull(billObj.LatestPendingBill),
                                        //MT - 25/05/2018 AT - 2663 Assigning the total discount amount value coming from the heroku in the field
                                        TotalDiscountAmount__c = decimalEscapeNull(billObj.TotalDiscountAmount)));
            //recordsToInsert.add(bill);
            billExtIds.add(billObj.Id);

            // add the bill to the list of bills inserted               
            billsInserted.add(bill);
                
            System.debug(DEBUG + 'MAP BILL SERVICE TYPES');
            for (BlIn_BillCalcResponseBillServiceTypeObject billServiceTypeObj : billObj.BillServiceTypes) {
                
                BillServiceType__c billServiceTypeReference = new BillServiceType__c(HerokuPostgresId__c = billServiceTypeObj.Id);
                billServiceTypeInserted.add(new BillServiceType__c(
                                                            Name = billServiceTypeObj.Name, 
                                                            HerokuPostgresId__c = billServiceTypeObj.Id, 
                                                            Bill__r = billReference, 
                                                            ServiceType__c = (Id)billServiceTypeObj.ServiceTypeId, 
                                                            TotalBilledAmount__c = decimalEscapeNull(billServiceTypeObj.TotalBilledAmount),
                                                            //MT - 25/05/2018 AT - 2663 Assigning the total discount amount value coming from the heroku in the field
                                                            TotalDiscountAmount__c = decimalEscapeNull(billServiceTypeObj.TotalDiscountAmount)
                                                            )
                                    );

                System.debug(DEBUG + 'MAP BILL ITEMS');
                for (BlIn_BillCalcResponseBillItemObject billItemObj : billServiceTypeObj.BillItems) {
                        
                    BillItem__c billItemReference = new BillItem__c(HerokuPostgresId__c = billItemObj.Id);
                    billItemInserted.add(new BillItem__c(
                                                        //Name = billItemObj.Name, 
                                                        HerokuPostgresId__c = billItemObj.Id, 
                                                        BillServiceType__r = billServiceTypeReference, 
                                                        Bill__r = billReference, 
                                                        ServiceItem__c = (Id)billItemObj.ServiceItemId, 
                                                        BillItem__c = (Id)billItemObj.BillItemId, 
                                                        Rate__c = (Id)billItemObj.RateId, 
                                                        RateBand__c = (Id)billItemObj.RateBandId, 
                                                        AgreedRate__c = (Id)billItemObj.AgreedRateId, 
                                                        ChargeBasis__c = (Id)billItemObj.ChargeBasisId, 
                                                        Reading__c = (Id)billItemObj.ReadingId, 
                                                        StartDate__c = dateEscapeNull(billItemObj.StartDate), 
                                                        EndDate__c = dateEscapeNull(billItemObj.EndDate), 
                                                        OriginalCalculationDate__c = dateEscapeNull(billItemObj.OriginalCalculationDate), 
                                                        VolumeUsed__c = decimalEscapeNull(billItemObj.VolumeUsed), 
                                                        BilledAmount__c = decimalEscapeNull(billItemObj.BilledAmount), 
                                                        NetBilledAmount__c = decimalEscapeNull(billItemObj.NetBilledAmount), 
                                                        //GrossConsumption__c = decimalEscapeNull(billItemObj.GrossConsumption), AT-2159
                                                        NetConsumption__c = decimalEscapeNull(billItemObj.NetConsumption), 
                                                        EstimatedConsumption__c = decimalEscapeNull(billItemObj.EstimatedConsumption), 
                                                        NegatedBillItem__c = booleanEscapeNull(billItemObj.NegatedBillItem), 
                                                        ReplacedByNewBillItems__c = booleanEscapeNull(billItemObj.ReplacedByNewBillItems), 
                                                        ManualAmendment__c = (Id)billItemObj.ManualAmendmentId, 
                                                       // AmendmentDate__c = dateEscapeNull(billItemObj.AmendmentDate), 
                                                        TotalCalculatedAllowance__c = decimalEscapeNull(billItemObj.TotalCalculatedAllowance), 
                                                        TotalDiscountAmount__c = decimalEscapeNull(billItemObj.TotalDiscountAmount), 
                                                        TotalTaxAmount__c = decimalEscapeNull(billItemObj.TotalTaxAmount), 

                                                        ConsumptionAllowance__c = decimalEscapeNull(billItemObj.ConsumptionAllowance), 
                                                        AgreedSampleStrength__c = (Id)billItemObj.AgreedSampleStrengthId, 
                                                        AgreedVolume__c = (Id)billItemObj.AgreedVolumeId, 
                                                        //AT-4996, Ankit, 18/01/2018
                                                        FreeStrength__c = (Id)billItemObj.FreeStrengthId,
                                                        PSampleStrength__c = decimalEscapeNull(billItemObj.PSampleStrength),
                                                        TDSSampleStrength__c = decimalEscapeNull(billItemObj.TDSSampleStrength),
                                                        TKNSampleStrength__c = decimalEscapeNull(billItemObj.TKNSampleStrength),
                                                        TopUpId__c = billItemObj.TopUpId, 
                                                        TopUpDate__c = dateEscapeNull(billItemObj.TopUpDate), 
                                                        TopUpValue__c = decimalEscapeNull(billItemObj.TopUpValue), 
                                                        TopUpDeviceId__c = billItemObj.TopUpDeviceId,
                                                        SteppedTariff__c = billItemObj.SteppedTariffId,
                                                        SteppedTariffService__c = billItemObj.SteppedTariffServiceId,
                                                        StartReadingID__c = billItemObj.StartReadingID,   //AT-3393
                                                        EndReadingID__c = billItemObj.EndReadingID,        //AT-3393
                                                        SupplyPoint__c = billItemObj.SupplyPointId, // Sudhir: AU1 - AT-4123
                                                        RuralGrossConsumption__c = billItemObj.RuralGrossConsumptionId, //AU2 - (AT-4485)
                                                        ServiceItemTolerance__c = billItemObj.ServiceItemToleranceId, //UK1-UL-22, Ankit, 14 Feb 2019
                                                        SiteSupply__c = (Id) billItemObj.SiteSupplyId //AT-3489
                                                        )
                                            );
                                            
                    System.debug(DEBUG + 'MAP BILL ITEM TAXES');
                    for (BlIn_BillCalcResponseBillItemTaxObject billItemTaxObj : billItemObj.BillItemTaxes) {
                            
                        billItemTaxInserted.add(new BillItemTax__c(
                                                            Name = billItemTaxObj.Name, 
                                                            HerokuPostgresId__c = billItemTaxObj.Id, 
                                                            BillItem__r = billItemReference, 
                                                            Tax__c = (Id)billItemTaxObj.TaxId, 
                                                            TaxClassification__c = (Id)billItemTaxObj.TaxClassificationId, 
                                                            TaxAmount__c = decimalEscapeNull(billItemTaxObj.TaxAmount), 
                                                            StartDate__c = dateEscapeNull(billItemTaxObj.StartDate), 
                                                            EndDate__c = dateEscapeNull(billItemTaxObj.EndDate) 
                                                            )
                                            );
                    }
                    
                    System.debug(DEBUG + 'MAP BILL ITEM DISCOUNTS');
                    for (BlIn_BillCalcResponseBillItemDiscountObject billItemDiscountObj : billItemObj.BillItemDiscounts) {
                            
                        billItemDiscountInserted.add(new BillItemDiscount__c(
                                                            Name = billItemDiscountObj.Name, 
                                                            HerokuPostgresId__c = billItemDiscountObj.Id, 
                                                            BillItem__r = billItemReference, 
                                                            Discount__c = (Id)billItemDiscountObj.DiscountId, 
                                                            DiscountAmount__c = decimalEscapeNull(billItemDiscountObj.DiscountAmount), 
                                                            StartDate__c = dateEscapeNull(billItemDiscountObj.StartDate), 
                                                            EndDate__c = dateEscapeNull(billItemDiscountObj.EndDate),
                                                            TopUp__c = Boolean.valueOf(billItemDiscountObj.TopUp)  //AT-4409
                                                            )
                                            );
                    }

                    //Start of AT - 2781
                    System.debug(DEBUG + 'MAP BILL ITEM Volume Alteration Items');
                    for (BlIn_BillCalcResponseBillItemVolumeAlterationItemObject billItemVolumeAlterationItemObj : billItemObj.VolumeAlterationItems) {
                        if(billItemVolumeAlterationItemObj != null){    
                        billVolumeAlterationItemInserted.add(new VolumeAlterationItem__c(
                                                            SupplyPointAllowance__c = (Id)billItemVolumeAlterationItemObj.SupplyPointAllowanceId, //AT-4439
                                                            HerokuPostgresId__c = billItemVolumeAlterationItemObj.Id,
                                                            AllowanceApplied__c = decimalEscapeNull(billItemVolumeAlterationItemObj.AllowanceApplied),
                                                            /*Changes for AT-4372 Starts here */
                                                            BillItem__r = billItemReference,
                                                            //AT-4996, Ankit, 18/01/2018
                                                            FreeAllowance__c = (Id)billItemVolumeAlterationItemObj.FreeAllowanceId,
                                                            /*Changes for AT-4372 Ends here */
                                                            AllowanceAvailable__c = decimalEscapeNull(billItemVolumeAlterationItemObj.AllowanceAvailable), 
                                                            Order__c = decimalEscapeNull(billItemVolumeAlterationItemObj.Order), 
                                                            StartDate__c = dateEscapeNull(billItemVolumeAlterationItemObj.StartDate), 
                                                            EndDate__c = dateEscapeNull(billItemVolumeAlterationItemObj.EndDate),
                                                            ServiceItemAgreedVolume__c = (Id)billItemVolumeAlterationItemObj.ServiceItemAgreedVolumeId //AT-4439
                                                            )
                                            );
                        }
                    }
                    //End of AT - 2781
                }
            }
        }
        
        // amendments to existing bill items
        System.debug(DEBUG + 'MAP BILL ITEM AMENDMENTS');
        for (BlIn_BillCalcResponseBillItemAmendmentObject amendment : result.Amendments) {
            amendmentsToInsert.add(new BillItemAmendment__c(   // MT - 14-08-2018 3174
                                                Name = amendment.Name, 
                                                HerokuPostgresId__c = amendment.Id, 
                                                AmendedBillItem__c = (Id)amendment.BillItemId,      // reference to existing bill item that has been amended
                                                AmendmentReason__c = amendment.AmendmentReason, 
                                                AgreedSampleStrength__c = (Id)amendment.AgreedSampleStrengthId,
                                                AgreedVolume__c = (Id)amendment.AgreedVolumeId,
                                                ChargeBasis__c = (Id)amendment.ChargeBasisId,
                                                Discount__c = (Id)amendment.DiscountId,
                                                Reading__c = (Id)amendment.ReadingId,
                                                ServiceItem__c = (Id)amendment.ServiceItemId,
                                                TaxClassification__c = (Id)amendment.TaxClassificationId,
                                                ManualAmendment__c = (Id)amendment.ManualAmendmentId,
                                                Amount__c = decimalEscapeNull(amendment.Amount),
                                                DiscountAmount__c = decimalEscapeNull(amendment.DiscountAmount),
                                                TaxAmount__c = decimalEscapeNull(amendment.TaxAmount),
                                                RuralGrossConsumption__c = (Id)amendment.RuralGrossConsumptionId
                                                )
                                  );
        }
        // save all the records in the response
        // split the commits to cope with asynchronous Heroku Connect updates
        try {
            system.debug('amendmentsToInsert====='+amendmentsToInsert);
            // save the amemendment records
            if (!amendmentsToInsert.isEmpty()) {
                insert amendmentsToInsert;  // MT - 14-08-2018 3174
            }
        } catch (Exception e) {
            GlUt_Logger.logException(e);
            System.debug(DEBUG + 'AMENDMENTS SYNCED BY HEROKU CONNECT');
        } finally {
                billIds = new List<Id>();
                try {
                    // save the all bill/bill child records (related through the external Ids)
                    // return a list of the Ids of the bill records inserted
                    if(!billsInserted.isEmpty()){
                        Database.UpsertResult[] results = Database.upsert(billsInserted);
                    }
                    if(!billServiceTypeInserted.isEmpty()){
                        Database.UpsertResult[] results = Database.upsert(billServiceTypeInserted);
                    }
                    if(!billItemInserted.isEmpty()){
                        Database.UpsertResult[] results = Database.upsert(billItemInserted);
                    }
                    if(!billItemTaxInserted.isEmpty()){
                        Database.UpsertResult[] results = Database.upsert(billItemTaxInserted);
                    }
                    if(!billItemDiscountInserted.isEmpty()){
                        Database.UpsertResult[] results = Database.upsert(billItemDiscountInserted);
                    }
                    if(!billVolumeAlterationItemInserted.isEmpty()){
                        Database.UpsertResult[] results = Database.upsert(billVolumeAlterationItemInserted);
                    }
                    for (Bill__c bill : billsInserted) {
                        System.debug(DEBUG + 'Bill: ' + bill);
                        billIds.add(bill.Id);
                    }
                } catch (Exception e) {
                    GlUt_Logger.logException(e);
                    System.debug(DEBUG + 'BILLS SYNCED BY HEROKU CONNECT - RETRIEVING IDS'+e.getMessage());
                    // couldn't insert the bills so try to retrieve them
                    Map<Id, Bill__c> bills = new Map<Id, Bill__c>([SELECT Id FROM Bill__c WHERE HerokuPostgresId__c in :billExtIds]);
                    billIds.addAll(bills.keySet());
                    GlUt_Logger.writeLogsToDatabase();
                }       
            
        }
        return billIds;
    }
}