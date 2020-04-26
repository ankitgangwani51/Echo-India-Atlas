/******************************************************************************
@author         Echo: Neha R
@date           21 Feb 2018
@description    Component controller for CustomerHighlights
                Modified code At-2147 to display social tariff on Contract - Neha Rajput 28/03/2018
@revision		Echo: Sudhir Kumar - AT-3982: Updating return type from String to Boolean for getSocialTariffStatus & getOpenCaseStatus methods
*******************************************************************************/
public class GlUt_CustomerHighlights {     
    private static final Date CURRENT_DATE = System.today();
    private static final String CLASS_NAME = 'GlUt_CustomerHighlights';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static List<String> caseItemFields;
    private static List<String> serviceItemFields;
    private static List<String> serviceItemTypeFields;
    private static List<String> bundleItemFields;
    private static List<String> billFields;
    
    static{
        billFields = new List<String>();
        billFields.add(GlUt_APIConstantsBill.BILL_TYPE);
        billFields.add(GlUt_APIConstantsBill.CONTRACTNUMBERAPINAME);
    }
    static{
        caseItemFields = new List<String>();
        caseItemFields.add(GlUt_APIConstantsCase.STATUSAPINAME);
    }
    static{
        serviceItemFields = new List<String>();
        serviceItemFields.add(GlUt_APIConstantsServiceItem.SERVICEITEMTYPEAPINAME);
    }
    
    static{
        serviceItemTypeFields = new List<String>();
        serviceItemTypeFields.add(GlUt_APIConstantsServiceItemType.SERVICEITEMFAMILYAPINAME);
    }
    
    static{
        bundleItemFields = new List<String>();
        bundleItemFields.add(GlUt_APIConstantsBundleItem.BUNDLEAPINAME);
    }    
    
    /******************************************************************************
    @author         Echo: Neha R
    @date           21 Feb 2018
    @param          Id - Can be a Account or Contract or Location Id
                    String - sObject Name
    @return         WrapperClass
    *******************************************************************************/
    @AuraEnabled
    public static WrapperClass customerHighlights(Id recordId, String sObjectName) {
        
        String resultValue;  
        
        WrapperClass wcObj = new WrapperClass();
        try {

            if (sObjectName == GlUt_APIConstantsLocation.LOCATIONAPINAME){
                
                /* ****** Hightlights on Location ****** */            
                resultValue = GlUt_LocationUtilities.getVoidContractStatus(recordId);                                       
                if (resultValue == GlUt_Constants.SUCCESSFUL){
                    wcObj.isVoid = true;                
                }
                
            }
            else if(sObjectName == GlUt_APIConstantsAccount.ACCOUNTAPINAME || sObjectName == GlUt_APIConstantsContracts.CONTRACTAPINAME)   //AT-3377 Core 8b
            {  
                if (sObjectName == GlUt_APIConstantsAccount.ACCOUNTAPINAME){     /* ****** Highlights Only on Account ****** */  //AT-3377 Core 8b                          
                    resultValue = GlUt_AccountUtilities.getOpenCaseStatus(recordId, caseItemFields); 
                    if (resultValue == GlUt_Constants.SUCCESSFUL){
                        wcObj.isOpenCase = true;                    
                    }                             
                    
                }
                else{    /* ****** Highlights Only on Contracts ****** */
                    
                    /* Debt Recovery Stage */
                    resultValue = GlUt_DebtRecoveryUtilities.getCurrentDebtRecoveryStage(recordId, sObjectName);                
                    if (resultValue != null && resultValue != ' '){
                        wcObj.isDRStage = true;
                        wcObj.dRStageLabel = resultValue; 
                    }  
                    
                    /******Highlights for Pending Bill on Billing Contract  AT-3377****/
                    resultValue = getPendingBillStatus(recordId, sObjectName);
                    if(resultValue == 'true') 
                        wcObj.isBillPending = true ;
                    else
                        wcObj.isBillPending = false; 
                    /***********AT-3377*****************************/
                    
                    //UL-218- Added By Dependra Singh- UK1 - 11-02-2019-  Start 
                    wcObj.isHeldBill = getHeldBillStatus(recordId, sObjectName);
                    //UL-218- Added By Dependra Singh- UK1 - 11-02-2019- End
                }
                
                /* Suppression / Contract Suppression */
                resultValue = getSuppressionStatus(recordId, sObjectName);
                if (resultValue == GlUt_Constants.SUCCESSFUL)
                {
                    wcObj.isSuppressed = true;
                    wcObj.suppressedLabel = System.Label.GlAp_SuppressedLabel;
                    wcObj.suppressedColorCode = System.Label.GlAp_SuppressedColorCode;
                    wcObj.suppressedTextColorCode = System.Label.GlAp_SuppressedTextColorCode;
                }
                else if (resultValue == GlUt_Constants.SUPPRESSED_PARTIAL)
                {
                    wcObj.isSuppressed = true;
                    wcObj.suppressedLabel = System.Label.GlAp_ContractSuppressedLabel;
                    wcObj.suppressedColorCode = System.Label.GlAp_PartialSuppressedColorCode;
                    wcObj.suppressedTextColorCode = System.Label.GlAp_PartialSuppressedTextColorCode;
                }
                
                /* Social Tariff */
                resultValue = GlUt_AccountUtilities.getSocialTariffStatus(sObjectName, recordId, serviceItemFields, serviceItemTypeFields, bundleItemFields);                
                if (resultValue == GlUt_Constants.SUCCESSFUL){
                    wcObj.isSocialTariff = true;                   
                } 
            }     
    
            if (wcObj.isSuppressed == true || wcObj.isVoid == true || wcObj.isOpenCase == true || wcObj.isDRStage == true || wcObj.isSocialTariff == true || wcObj.isBillPending == true || wcObj.isHeldBill == true)
                wcObj.isActive = true;
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }

        return wcObj;       
    }
    
    /******************************************************************************
    @author         Echo: Neha R
    @date           22 Feb 2018
    @param          Id - Can be a Account or contract Id
                    String - sObject Name
    @return         String - Record Suppressed Status
    *******************************************************************************/
    public static String getSuppressionStatus(Id recordId, String sObjectName) {
   
        if (sObjectName == GlUt_APIConstantsAccount.ACCOUNTAPINAME) {  //AT-3377 Core 8b
            return GlUt_SuppressionUtilities.getAccountSuppressionStatus(recordId);
            
        } else if (sObjectName == GlUt_APIConstantsContracts.CONTRACTAPINAME) {
            return GlUt_SuppressionUtilities.isContractSuppressed(recordId) 
                    ? GlUt_Constants.SUPPRESSED_YES //Change Constant Class Reference AT-3174 Starts here
                    : GlUt_Constants.SUPPRESSED_NO; //Change Constant Class Reference AT-3174 Ends here
        }        
        return null;        
    }
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           21 Aug 2018
    @param          Id - contract Id
                    String - sObject Name
    @return         String - Get Pending Bill Status
    *******************************************************************************/
    public static String getPendingBillStatus(Id recordId, String sObjectName) {
        Boolean pendingBill;
        if (sObjectName == GlUt_APIConstantsContracts.CONTRACTAPINAME) {
            pendingBill = false;
           
            // Code modified under AT-3817             
            List<Bill__c> lastBillOnContractList = new List<Bill__c>();
            lastBillOnContractList = [SELECT Id,BillType__c
                                      FROM Bill__c
                                      WHERE BillingContract__c = :recordId ORDER BY BillDate__c DESC, createddate DESC LIMIT 1];          
            if (lastBillOnContractList != null && !lastBillOnContractList.isEmpty() && lastBillOnContractList[0].BillType__c == Label.BlIn_BillTypePending )
                return 'true';   
        }
        return 'false';
    }
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           21 Aug 2018
    @param          Id - contract Id
                    String - sObject Name
    @return         String - if there are any bill records that are currently linked to the Billing Contract with the following criteria.
                    Billtype = “Held Bill”
                    Invalid = false 
					If a bill is found with the above criteria, then a new pill will be displayed against the Billing Contract for “Held Bill”.
					//UL-218- Added By Dependra Singh- UK1 - 11-02-2019
    *******************************************************************************/
    public static Boolean getHeldBillStatus(Id recordId, String sObjectName) {
        Boolean isHeldBill= false;
        if (sObjectName == GlUt_APIConstantsContracts.CONTRACTAPINAME) {
            // Code modified under AT-3817
            String filterStatement = ' WHERE ' + GlUt_APIConstantsBill.CONTRACTNUMBERAPINAME +' =\'' + String.escapeSingleQuotes(recordId) + '\'';
            List<Bill__c> lastBillOnContractList = (List<Bill__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsBill.BILLAPINAME,billFields,filterStatement);        
            if (lastBillOnContractList != null && !lastBillOnContractList.isEmpty()){
                for(Bill__c objBill : lastBillOnContractList){
                    if(objBill.BillType__c == Label.BlIn_BillTypeBillHeld){
                        isHeldBill = true; 
			    break;
                    }
                }
            }
        }
        return isHeldBill;
    }
    
    public class WrapperClass {
        @AuraEnabled public Boolean isActive;
        @AuraEnabled public Boolean isSuppressed;
        @AuraEnabled public Boolean isVoid;
        @AuraEnabled public Boolean isOpenCase;
        @AuraEnabled public Boolean isDRStage;
        @AuraEnabled public Boolean isSocialTariff;
        @AuraEnabled public Boolean isBillPending;     //AT-3377
        @AuraEnabled public Boolean isHeldBill;  //UL-218- Added By Dependra Singh- UK1 - 11-02-2019
        
        @AuraEnabled public String suppressedLabel;  
        @AuraEnabled public String dRStageLabel;
        
        @AuraEnabled public String suppressedColorCode;
        @AuraEnabled public String suppressedTextColorCode;
        
         
    }
    
}