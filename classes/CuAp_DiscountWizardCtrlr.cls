/******************************************************************************
@author         Echo: Amit K.
@date           09 Jan 2018
@description    Component controller for Manage Discount wizard
@Revision	 	AT-3975, Tarun - Modified as per security review
*******************************************************************************/
public with sharing class CuAp_DiscountWizardCtrlr {
    
    public static WizardObject wizObject;
    
    private static final String CLASS_NAME = 'CuAp_DiscountWizardCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    /******************************************************************************
    @author         Echo: Amit K.
    @date           31 Jan 2018
    @description    Wrapper class for Wizard variables
    *******************************************************************************/
    /*
    Screen  wizardprop element name         type
    ==============================================================================
    Base
            recordId                        Id (the Id of the host page record) - should be the same as contractId but use contractId
            contractId                      Id (the Id of the contract associated with discount)
    
    WS1
            wizardType                      String (this variable is used to hold the flag for new discount or existing discount selected from screen )

    WS2
           DiscountType__c                 DiscountType__c
                                                          Id: (from screen),
                                                          Name: (from screen),
                                                          RecurrenceFrequency__c: (from screen),
                                                          PercentageDiscountAmount__c: (from screen), 
                                                          AbsoluteDiscountAmount__c: (from screen),
                                                          Type__c: (from screen),
                                                          CanbeOverridden__c: (from screen)
                                          

    WS3
           Discount__c                   Discount__c
                                                    DiscountType__c: wizObj.discountType (from wizard object),
                                                    BaseDiscountAmount__c: (from wizard object)
                                                    BaseDiscountPercentage__c:  (from wizard object),
                                                    OverriddenDiscountPercentage__c: (from screen),
                                                    OverriddenDiscountAmount__c: (from screen),
                                                    StartDate__c: (from screen),
                                                    EndDate__c: (from screen)                                                  
                                                        


   */
    public class WizardObject {
        public Id recordId;
        public Id contractId;
        public string wizardType;
        public List<Id> lstDiscountIds;
        public List<Discount__c> discount;
        public DiscountType__c discountType; 
        public Set<Id> concessions;
    }
    
    /******************************************************************************
    @author         Echo: Amit K.
    @date           09 Jan 2018
    @param          String - wizardprop
    @description    Updates the wizard properties
    *******************************************************************************/
    @AuraEnabled
    public static void WizardStatus(String wizardprop) {
        try {
            // build the wizard object from the wizard properties
            UpdateWizardProperties(wizardprop);
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
    }
    
    /******************************************************************************
    @author         Echo: Amit K.
    @date           09 Jan 2018
    @param          String - wizardprop
    @description    Updates the wizard properties
    *******************************************************************************/
    public static void UpdateWizardProperties(String wizardprop) {
        
        // strip out all the SObject type references from the json
        wizardprop = wizardprop.replaceAll('"sobjectType":"(.*?)"(,|[^}]*)', '');
        
        // and deserialise it
        wizObject = (WizardObject)System.JSON.deserializeStrict(wizardprop, WizardObject.class);       
    }
    
    /******************************************************************************
    @author         Echo: Amit K.
    @date           31 Jan 2018
    @param          String - json string of object wizardprop
    @param          String - wizardprop
    @return         Id
    @description    Method called by wizard to complete the discount management process for add new discount scenario.
    *******************************************************************************/
    @AuraEnabled
    public static Id createDiscount(String wizardprop) { 
        Savepoint sp = Database.setSavepoint();
        try {
            // build the wizard object from the wizard properties
            UpdateWizardProperties(wizardprop); 
            //Create new discount.
            if(wizObject.discount!=null) {
                wizObject.discount = (List<Discount__c>) GlUt_FieldSecurity.cleanseFields(wizObject.discount, false);
                insert wizObject.discount;
            }
            return wizObject.contractId;
        }
        catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            System.debug('exception = '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }  finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           31 Jan 2018
    @param          String - json string of object wizardprop
    @param          String - wizardprop
    @description    Method called by wizard to complete the discount management process for add new discount scenario.
    @return         Discount__c
    @Revision       Changes as per AT-3448, Change return type to Discount__c
    *******************************************************************************/
    @AuraEnabled
    public static Discount__c createUpdateDiscount(String wizardprop) {
        Savepoint sp = Database.setSavepoint();
        try {
            System.debug('100.1 wizardprop == '+wizardprop);
            // build the wizard object from the wizard properties
            UpdateWizardProperties(wizardprop); 
            System.debug('100.2 wizardprop == '+wizardprop);
            
            if(wizObject.discount!=null) {
                wizObject.discount = (List<Discount__c>) GlUt_FieldSecurity.cleanseFields(wizObject.discount, false);
                System.debug('100.3 wizObject.discount == '+wizObject.discount);
                insert wizObject.discount;
                
                if(wizObject.lstDiscountIds != null){
                    
                    Map<Id,Discount__c> DTIdDiscObj = new Map<Id,Discount__c>();
                    
                    for(Discount__c objDisc: wizObject.discount){
                        DTIdDiscObj.put(objDisc.DiscountType__c, objDisc);                        
                    }
                   
                    List<Discount__c> lstDisc = [SELECT Id, 
                                                 AmendedByDiscount__c,
                                                 DiscountType__c
                                                 FROM Discount__c WHERE DiscountType__c IN :DTIdDiscObj.keySet() 
                                                 AND BillingContract__c = :wizObject.contractId
                                                 AND Id IN :wizObject.lstDiscountIds];
                    
                    for(Integer i=0;i<lstDisc.size();i++){
                        lstDisc[i].AmendedByDiscount__c=DTIdDiscObj.get(lstDisc[i].DiscountType__c).Id;
                    }        
                    if(lstDisc != null && !lstDisc.isEmpty()){
                        lstDisc =  (List<Discount__c>) GlUt_FieldSecurity.cleanseFields(lstDisc, false);
                         update lstDisc;
                    }
                   
                }
            }
            // Changes for AT-3448 starts here
            if(wizObject.discount.size() > 0){
                return wizObject.discount[0];
            }
            else{
                return null;
            }
            // Changes for AT-3448 Ends here
        }
        catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        } finally {
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    
    /******************************************************************************
    @author         Echo: Ankit Gangwani
    @date           31 Jan 2018
    @param          String - json string of object wizardprop
    @param          String - wizardprop
    @description    Method called by wizard to complete the discount management process for add new discount scenario.
    @return         Discount__c
    @Revision       Changes as per AT-3448, Change return type to Discount__c
    *******************************************************************************/
    @AuraEnabled
    public static Discount__c updateDiscount(String wizardprop) { 
        Savepoint sp = Database.setSavepoint();
        try {
            // build the wizard object from the wizard properties
            UpdateWizardProperties(wizardprop); 
            if(wizObject.discount!=null) {
                wizObject.discount = (List<Discount__c>) GlUt_FieldSecurity.cleanseFields(wizObject.discount, false);
                update wizObject.discount;
            }
            // Changes for AT-3448 starts here
            if(wizObject.discount.size() > 0)
                return wizObject.discount[0];
            else 
                return null;
            // Changes for AT-3448 Ends here
        }
        catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            System.debug('exception = '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        } finally {
            GlUt_Logger.writeLogsToDatabase();
        }

    }
}