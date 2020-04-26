/******************************************************************************
@author         Echo: Tarun Gupta
@date           23 Oct 2018
@description    Component controller for AU Move In wizard screen for Credit\Debit Transfer
*******************************************************************************/

public class CuAp_AUTransferCreditOrDebitCtrlr {
    
    private static final String CLASS_NAME = 'CuAp_AUTransferCreditOrDebitCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static final List < String > contractListFields = new List <String> {
            GlUt_APIConstantsContracts.CUSTOMERAPINAME,
            GlUt_APIConstantsContracts.STATUSAPINAME,
            GlUt_APIConstantsContracts.BALANCEAPINAME,
            GlUt_APIConstantsContracts.CONTRACTBALANCEAPINAME   
            };   
       
    private static final List < String > balanceFieldList = new List <String> {
            GlUt_APIConstantsBalances.BALANCEAMOUNTAPINAME,
            GlUt_APIConstantsBalances.TOTALREFUNDAMOUNTAPINAME
            };
                
	private static final List<String> supplyPointFields = new List<string>{
        	GlUt_APIConstantsSupplyPoint.LOCATIONAPINAME
            };    
                
    private static final List<String> serviceFields = new List<string>{
            GlUt_APIConstantsService.SERVICECONTRACTAPINAME,
            GlUt_APIConstantsService.SERVICESTARTDATEAPINAME,
            GlUt_APIConstantsService.SERVICEENDDATEAPINAME,
            GlUt_APIConstantsService.OCCUPANCYTYPEAPINAME    
            };
                
    /**********************************************************************************************
    @author      : Echo: Tarun
    @date        : 23 Oct 2018
    @return      : WrapCreditAndDebitDetails
    @params      : None
    @description : This method returns credit and debit details
    **********************************************************************************************/
    @AuraEnabled
    public static WrapCreditAndDebitDetails retrieveCreditAndDebitAmount(Id locationId, String newMoveInDate, String occType){
        
        WrapCreditAndDebitDetails objPMTWrapper = new WrapCreditAndDebitDetails();
        
        Id contractId;
        //String getCreditDetailsVal;
        Decimal locationDebt = 0.0;
        try {
            if(locationId != null){
                Set<Id> setContractId = getListOfContractOnLocation(locationId, newMoveInDate , occType);
                if(setContractId != null & setContractId.size() > 0){
                    contractId = new List<Id> (setContractId)[0];
                    if(contractId != null){
                        BillingContract__c contract = (BillingContract__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsContracts.CONTRACTAPINAME, contractId, contractListFields);
                        if(contract.ContractBalance__c != null){
                            if(contract.ContractBalance__c > 0){
                                objPMTWrapper.debtOnLocation = contract.ContractBalance__c;
                            }else{
                                objPMTWrapper.creditOnContract =  contract.ContractBalance__c*-1;
                            }
                        }
                    }
                }
            }        
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return objPMTWrapper;
    }
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           23 Oct 2018
    @param          none
    @return         none
    @description    wrapper class to hold the This method returns credit and debit details
    *******************************************************************************/
    public class WrapCreditAndDebitDetails{
        
        @AuraEnabled public Decimal debtOnLocation ;                
        @AuraEnabled public Decimal creditOnContract;
        
        public WrapCreditAndDebitDetails(){
            this.debtOnLocation = 0.0;             
            this.creditOnContract = 0.0;
        } 
    }
    
    /**********************************************************************************************
    @author      : Echo : Tarun Gupta
    @date        : 23 Sep 2018
    @description : This method is to get list of all Contracts linked to Location
    **********************************************************************************************/ 
    
    public static Set<Id> getListOfContractOnLocation(Id locationId, String newMoveInDate, String occType) {
        List<SupplyPoint__c> supplyPointList = new List<SupplyPoint__c>();
        List<Service__c> serviceList = new List<Service__c>();
        Set<Id> supplyPointIds = new Set<Id>();
        Set<Id> serviceIds = new Set<Id>();    
        Set<Id> contractIds = new Set<Id>();    
        
        supplyPointList = (List<SupplyPoint__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,
                                                                                     supplyPointFields, 
                                                                                     'WHERE ' + GlUt_APIConstantsSupplyPoint.LOCATIONAPINAME + ' = ' + '\'' + locationId + '\'');
        
        if(!supplyPointList.isEmpty()){
            for(SupplyPoint__c objSP : supplyPointList){
                supplyPointIds.add(objSP.Id);
            }
        }
        
        if(supplyPointIds.size() > 0){
            List<String> dateInList = newMoveInDate.split(' ');
            DateTime dt1 = Date.valueOf(dateInList[0]);
            
            String filterStatement = 'WHERE ';
            filterStatement += GlUt_APIConstantsService.SUPPLYPOINTAPINAME + ' IN ' + GlUt_FieldSecurity.IdsToString(supplyPointIds);
            filterStatement += ' AND ' + GlUt_APIConstantsService.SERVICESTARTDATEAPINAME + ' < ' + dt1.format('yyyy-MM-dd') ;            
            filterStatement += ' AND ' + GlUt_APIConstantsService.OCCUPANCYTYPEAPINAME + ' != ' + '\'' + Label.CuAp_AUMoveInOccType + '\'';
            
            serviceList = (List<Service__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsService.SERVICEAPINAME,
                                                                                 serviceFields, 
                                                                                 filterStatement);
            if(!serviceList.isEmpty()){
                for(Service__c objService : serviceList){
                    
                    if(objService.ServiceEndDate__c == null || (objService.ServiceEndDate__c != null && objService.ServiceEndDate__c >= Date.valueOf(newMoveInDate))){
                        contractIds.add(objService.BillingContract__c);
                    }
                }
            }
        }
        return contractIds;
    }
}