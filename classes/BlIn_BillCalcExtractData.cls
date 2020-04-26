/******************************************************************************
@author         Accenture: Patrick Dixon
@date           29 Aug 2017
@description    Extracts billing data and packages as JSON
                to pass to the bill calculation REST service
Revision(s)     14 Mar 2018, P Dixon - additions to support pending bill calculations
*******************************************************************************/
public with sharing class BlIn_BillCalcExtractData {
    
    private static final String CLASS_NAME = 'BlIn_BillCalcExtractData';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    // utility methods used to format date and datetime fields for json as yyyy-MM-dd HH:mm:ss
    private static String dateToString(Date d) {return d != null ? String.valueOf(d) + ' 00:00:00' : null;}
    private static String dateToString(DateTime dt) {return dt != null ? String.valueOf(dt) : null;}
       
    public BlIn_BillCalcObj data {get; private set;}         // the structured bill data

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           29 Aug 2017
    @param          Id - bill calculation Id
    @description    Constructor
    *******************************************************************************/
    public BlIn_BillCalcExtractData(Id billCalculationId) {

        // STEP 1: get all the data records required 
        // get the bill calculation record and the related contract Id and contract group fields
        BillCalculation__c billCalculation;
        for (BillCalculation__c billCalc : [select Id,
                                                    Status__c, 
                                                    Type__c, 
                                                    Reason__c, 
                                                    RequestDate__c,
                                                    ContractGroup__c, 
                                                    ContractGroup__r.Account__c,
                                                    ContractGroup__r.Account__r.Name,
                                                    BillingContract__c 

                                            from BillCalculation__c 
                                            where Id = :billCalculationId]) {

            billCalculation = billCalc;
            break;      // one only
        }

        // get the contract records
        List<BillingContract__c> contracts = billCalculation.ContractGroup__c != null 
                                    ? GlUt_ContractUtilities.getContracts(billCalculation.ContractGroup__c) 
                                    : GlUt_ContractUtilities.getContract(billCalculation.BillingContract__c);

        BlIn_BillCalcDataContainer container = new BlIn_BillCalcDataContainer(contracts);
        // STEP 2: build the data using the DTO hierachy 
        data = new BlIn_BillCalcObj(container, billCalculation);
        system.debug('data===='+data);
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           18 Sep 2017
    @description    Subclass for Bill Calculation
    *******************************************************************************/
    public class BlIn_BillCalcObj {
        
        private Id CalculationId;
        private String Status;
        private String Type;
        private String Reason;
        private BlIn_BillCalcDataContainer.BlIn_BillCalcContractGroupObj ContractGroup;
        private List<BlIn_BillCalcDataContainer.BlIn_BillCalcContractObj> Contracts;

        /******************************************************************************
        @author         Accenture: Patrick Dixon
        @date           18 Sep 2017
        @param          BlIn_BillCalcDataContainer - container class instance
        @param          BillCalculation__c - bill calculation record
        @description    Constructor
        *******************************************************************************/
        private BlIn_BillCalcObj(BlIn_BillCalcDataContainer container, BillCalculation__c billCalculation) {
            
            // add the bill calc fields to this DTO
            CalculationId = billCalculation.Id;
            Status = billCalculation.Status__c;
            Type = billCalculation.Type__c;
            Reason = billCalculation.Reason__c;
            
            // add the contract group DTO
            if (billCalculation.ContractGroup__c != null) {
                ContractGroup = new BlIn_BillCalcDataContainer.BlIn_BillCalcContractGroupObj(billCalculation);
            }

            // build the list of contract DTOs
            Contracts = new List<BlIn_BillCalcDataContainer.BlIn_BillCalcContractObj>();
            for (BillingContract__c contract : container.contracts) {
                Contracts.add(new BlIn_BillCalcDataContainer.BlIn_BillCalcContractObj(container, contract));
            }
        }            
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           29 Aug 2017
    @return         String - JSON package
    @description    Retrieves and packages billing data
    *******************************************************************************/
    public String retrieveData() {
        
        // serialise
        String JSONPayload = JSON.serialize(data);
        
        System.debug(DEBUG + 'Serialized JSON Payload billing data: ' + JSONPayload);
        return JSONPayload;
    }
}