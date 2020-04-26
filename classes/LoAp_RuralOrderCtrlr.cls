/******************************************************************************
@author    		Echo: Neha R.
@date      		11 Dec 2018
@description 	Component controller for Rural Order
Revisions		
*******************************************************************************/
public with sharing class LoAp_RuralOrderCtrlr {
    
    private static final String CLASS_NAME = 'LoAp_RuralOrderCtrl';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    public class ROWrapperClass {        
        @AuraEnabled public Boolean isError = false;      
        @AuraEnabled public String errorMsg;
        @AuraEnabled public String confirmMSG1;
        @AuraEnabled public String confirmMSG2;    
    }
        
    /**********************************************************************************************
    @author      : Echo: Neha R.
    @date        : 11 Dec 2018
    @return      : List<String>
    @description : Method to validate and save record
    **********************************************************************************************/   
    @AuraEnabled
    public static ROWrapperClass onSave(RuralOrder__c recordDetails){         
        system.debug('recordDetails---' + recordDetails);
        ROWrapperClass objwrapper = new ROWrapperClass();        
        try {
            //Entitlement Lookup is not populated           
            if(recordDetails.RuralEntitlement__c == null){
                objwrapper.isError = true;
                objwrapper.errorMsg = Label.LoAp_RuralEntitlementInvalid;  //Error:-‘Please select an Entitlement to record this order against’
            }            
            //Rural Channel is not populated 
            if(objwrapper.isError == false && recordDetails.RuralChannel__c == null){
                objwrapper.isError = true;
                objwrapper.errorMsg = Label.LoAp_RuralChannelInvalid;     //Error:-‘Please select a Channel to record this order against’
            }            
            // Location is not populated 
		    if(objwrapper.isError == false && recordDetails.Location__c == null){
                objwrapper.isError = true;
                objwrapper.errorMsg = Label.CuAp_SelectLocationError;     //Error:-‘Please select a Location to record this order against’ 
            } 
            //Order Date is not populated
            if(objwrapper.isError == false && recordDetails.OrderDate__c == null){
                objwrapper.isError = true;
                objwrapper.errorMsg = Label.LoAp_OrderDateError;          //Error:-‘Please enter an order date’
            }  
           
            // Checks for Confirmation messages
            if(objwrapper.isError == false &&
               recordDetails.RuralEntitlement__c != null &&
               recordDetails.RuralChannel__c != null &&
               recordDetails.OrderDate__c != null){  
                   
                   // check for balance on billing contract
                   RuralEntitlement__c objRularEntitlement = [SELECT Id,RuralLicense__c, RuralLicense__r.BillingContract__c
                                                              FROM RuralEntitlement__c
                                                              WHERE Id =: recordDetails.RuralEntitlement__c LIMIT 1];					                  
                   if(objRularEntitlement != null && objRularEntitlement.RuralLicense__r.BillingContract__c != null){
                       List<BillingContract__c> lstBillingContract = new List<BillingContract__c>();
                       lstBillingContract = [SELECT Id, ContractBalance__c
                                             FROM BillingContract__c
                                             WHERE Id =: objRularEntitlement.RuralLicense__r.BillingContract__c
                                             AND ContractBalance__c > 0 LIMIT 1];                         
                       if(!lstBillingContract.isEmpty()){
                           objwrapper.confirmMSG1 = Label.LoAp_RuralOrderDebt + ' ' +  String.valueOf(lstBillingContract[0].ContractBalance__c);   //Confirmation message:-‘This Customer has an outstanding Balance of’ + Balance Value 
                       }
                   }
                   
                   // check for outlet linked to location
                   List<SupplyPoint__c> lstSupplyPoint = new List<SupplyPoint__c>();
                   lstSupplyPoint = [SELECT Id
                                     FROM SupplyPoint__c
                                     WHERE Location__c =: recordDetails.Location__c
                                     AND AccessType__c != null LIMIT 1];  // =: LoAp_Constants.SINGLESHARED_CHANNEL                   
                   if(!lstSupplyPoint.isEmpty()){
                       List<RuralOrder__c> lstexistingRuralOrder = new List<RuralOrder__c>();
                       lstexistingRuralOrder = [SELECT Id
                                                FROM RuralOrder__c
                                                WHERE OrderDate__c =: recordDetails.OrderDate__c
                                                AND RuralChannel__c =: recordDetails.RuralChannel__c LIMIT 1];                           
                       if(!lstexistingRuralOrder.isEmpty()) 
                           objwrapper.confirmMSG2 = Label.LoAp_AnotherRuralOrderExist; //Confirmation message:-‘There is another order for this Rural Channel on this date’
                   }
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        system.debug('objwrapper... ' + objwrapper);
        return objwrapper;
    }
    
}