/************************************************************************************************************
@author      : Echo : Tarun Gupta
@date        : 08-Mar-2018
@description : This class use for CuAp_AddDiscountPage Lightning component to add discounts
@revision	 : AT-4385, Modified the add discount page for concessions discounts for Bill To Bill Discount Record Type
**************************************************************************************************************/
public with sharing class CuAp_AddDiscountPageCtrlr {
    
    private static final List < String > discountTypeListField = new List < string > {
            GlUt_APIConstantsDiscountType.TYPEAPINAME,
            GlUt_APIConstantsDiscountType.PERCENTAGEDISCOUNTAPINAME,
            GlUt_APIConstantsDiscountType.FIXEDDISCOUNTAPINAME,
            GlUt_APIConstantsDiscountType.DISCOUNTPERDAYAPINAME,
            GlUt_APIConstantsDiscountType.RECURRINGFREQUENCYAPINAME
        };
            
    private static final List < String > contractListField = new List < string > {
        GlUt_APIConstantsContracts.SUPPRESSEDAPINAME
        };
            
    private static final List < String > discountListField = new List < string > {
        GlUt_APIConstantsDiscounts.OVERRIDDENPERCENTAGEAPINAME,
        GlUt_APIConstantsDiscounts.OVERRIDDENAMOUNTAPINAME,
        GlUt_APIConstantsDiscounts.OVERRIDDENDAILYDISCOUNTAPINAME,
        GlUt_APIConstantsDiscounts.STARTDATEAPINAME,
        GlUt_APIConstantsDiscounts.ENDDATEAPINAME    
        };      
            
    private static final String CLASS_NAME = 'CuAp_AddDiscountPageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    
    /**********************************************************************************************
    @author      : Echo: Tarun Gupta
    @date        : 08-Mar-2018
    @params      : String discountType,Boolean canbeOverridden,Boolean suppressed
    @return      : List<List<GLAp_FieldProps>>
    @description : This method returns back discount type and related fields as List 
                   This change is done t cater name spaces changes
	@revision	 : AT-4385, Modified the add discount page for concessions discounts for Bill To Bill Discount Record Type
    **********************************************************************************************/   
    @AuraEnabled
    public static List<List<GlAp_FieldProps>> retrieveDiscountFields(String discountType,Boolean canbeOverridden,Boolean suppressed) {
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
            List<List<GlAp_FieldProps>> twoColFormattedList = new List<List<GlAp_FieldProps>>();
            
            List<String> lstUpdatedDiscType = new List<String>();
            List<String> lstUpdatedDisc = new List<String>();
            
            List<GLAp_FieldProps> lstDiscountTypeFields = new List<GLAp_FieldProps>();
            
            for(String objString : discountTypeListField){
                
                // If Discount Type = Fixed Discount then hide Percentage Discount and Bill To Bill Discount
                if(discountType == System.Label.CuAp_FixedDiscount){
                    if(!objString.contains(GlUt_APIConstantsDiscountType.PERCENTAGEDISCOUNTAPINAME) && !objString.contains(GlUt_APIConstantsDiscountType.DISCOUNTPERDAYAPINAME)){                    
                           lstUpdatedDiscType.add(objString);
                       }
                }
                
                // If Discount Type = Percentage Discount then hide Fixed Discount and Bill To Bill Discount
                else if(discountType == System.Label.CuAp_PercentageDiscount){                    
                    if(!objString.contains(GlUt_APIConstantsDiscountType.FIXEDDISCOUNTAPINAME) && !objString.contains(GlUt_APIConstantsDiscountType.DISCOUNTPERDAYAPINAME)){
                           lstUpdatedDiscType.add(objString);
                       }
                }
                
                // If Discount Type = Bill To Bill Discount then hide Fixed Discount and Percentage Discount
                else if(discountType == System.Label.CuAp_BillToBillDiscount){                    
                    if(!objString.contains(GlUt_APIConstantsDiscountType.FIXEDDISCOUNTAPINAME) && !objString.contains(GlUt_APIConstantsDiscountType.PERCENTAGEDISCOUNTAPINAME)){
                           lstUpdatedDiscType.add(objString);
                       }
                }
            }
            
            for(String objString : discountListField){
                
                if(discountType == System.Label.CuAp_FixedDiscount){
                    if(!objString.contains(GlUt_APIConstantsDiscounts.OVERRIDDENPERCENTAGEAPINAME) && !objString.contains(GlUt_APIConstantsDiscounts.OVERRIDDENDAILYDISCOUNTAPINAME)){                    
                        lstUpdatedDisc.add(objString);
                    }
                }
                else if(discountType == System.Label.CuAp_PercentageDiscount){                    
                    if(!objString.contains(GlUt_APIConstantsDiscounts.OVERRIDDENAMOUNTAPINAME) && !objString.contains(GlUt_APIConstantsDiscounts.OVERRIDDENDAILYDISCOUNTAPINAME)){
                        lstUpdatedDisc.add(objString);
                    }
                }
                else if(discountType == System.Label.CuAp_BillToBillDiscount){                    
                    if(!objString.contains(GlUt_APIConstantsDiscounts.OVERRIDDENAMOUNTAPINAME) && !objString.contains(GlUt_APIConstantsDiscounts.OVERRIDDENPERCENTAGEAPINAME)){
                        lstUpdatedDisc.add(objString);
                    }
                }
            }
            
            if(discountType == System.Label.CuAp_BillToBillDiscount){
                lstUpdatedDiscType.add(GlUt_APIConstantsDiscountType.MAXDISCOUNTPERSERVICEITEMAPINAME);
                lstUpdatedDiscType.add(GlUt_APIConstantsDiscountType.TOPUPAPINAME);                
            }
            lstDiscountTypeFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDiscountType.DISCOUNTTYPEAPINAME, lstUpdatedDiscType);
            
            List<GLAp_FieldProps> lstcontractFields = new List<GLAp_FieldProps>();
            lstcontractFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsContracts.CONTRACTAPINAME, contractListField);
            
            List<GLAp_FieldProps> lstdiscountFields = new List<GLAp_FieldProps>();
            lstdiscountFields = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDiscounts.DISCOUNTAPINAME, lstUpdatedDisc);
            
            for(integer i=0; i< lstcontractFields.size() ; i++){
                lstDiscountTypeFields.add(lstcontractFields[i]);
            }
            
            for(integer z=0; z< lstdiscountFields.size() ; z++){
                lstDiscountTypeFields.add(lstdiscountFields[z]);
            }
            
            for(GLAp_FieldProps objDicountFields: lstDiscountTypeFields){
                
                if(objDicountFields.fieldName == GlUt_APIConstantsContracts.SUPPRESSEDAPINAME){
                    objDicountFields.fieldLabel = CuAp_Constants.OVERRIDEDISCOUNTLABEL;
                    objDicountFields.changeEvent = true;
                    objDicountFields.editMode = true;
                    objDicountFields.isEditable = true;
                }
                
                if(!canbeOverridden && objDicountFields.fieldName == GlUt_APIConstantsContracts.SUPPRESSEDAPINAME){
                    objDicountFields.fieldName = '';
                    objDicountFields.isEditable = false;
                }
                
                // Discount = OverriddenDiscountPercentage__c
                if(discountType == System.Label.CuAp_PercentageDiscount){
                    if(objDicountFields.fieldName == GlUt_APIConstantsDiscounts.OVERRIDDENPERCENTAGEAPINAME){
                        objDicountFields.fieldLabel = CuAp_Constants.DISCOUNTPERCENTAGEOVERRIDE;
                        objDicountFields.editMode = true;
                        objDicountFields.isEditable = false;
                    }
                }
                
                // Discount = OverriddenDiscountAmount__c
                else if(discountType == System.Label.CuAp_FixedDiscount){
                    if(objDicountFields.fieldName == GlUt_APIConstantsDiscounts.OVERRIDDENAMOUNTAPINAME){                        
                        objDicountFields.fieldLabel = CuAp_Constants.DISCOUNTAMOUNTOVERRIDE;
                        objDicountFields.editMode = true;
                        objDicountFields.isEditable = false;                        
                    }
                }
                
                // Discount = OverriddenDailyDiscountAmount__c
                else if(discountType == System.Label.CuAp_BillToBillDiscount){
                    if(objDicountFields.fieldName == GlUt_APIConstantsDiscounts.OVERRIDDENDAILYDISCOUNTAPINAME){                        
                        objDicountFields.fieldLabel = CuAp_Constants.DISCOUNTPERDAYOVERRIDE;
                        objDicountFields.editMode = true;
                        objDicountFields.isEditable = false;                        
                    }
                }
                
                // Discount Type = Type__c
                if(objDicountFields.fieldName == GlUt_APIConstantsDiscountType.TYPEAPINAME){
                    objDicountFields.fieldLabel = System.Label.CuAp_DiscountType;
                    objDicountFields.showLabel = true;
                    objDicountFields.isEditable = false;
                }
                
                // Discount Type = PercentageDiscountAmount__c
                if(objDicountFields.fieldName == GlUt_APIConstantsDiscountType.PERCENTAGEDISCOUNTAPINAME){
                    objDicountFields.fieldLabel = System.Label.CuAp_PercentageDiscount;
                    objDicountFields.showLabel = true;
                    objDicountFields.isEditable = false;
                    
                }
                
                // Discount Type = AbsoluteDiscountAmount__c
                if(objDicountFields.fieldName == GlUt_APIConstantsDiscountType.FIXEDDISCOUNTAPINAME){
                    objDicountFields.fieldLabel = System.Label.CuAp_FixedDiscount;
                    objDicountFields.showLabel = true;
                    objDicountFields.isEditable = false;
                }
                
                // Discount Type = DiscountPerDay__c
                if(objDicountFields.fieldName == GlUt_APIConstantsDiscountType.DISCOUNTPERDAYAPINAME){
                    objDicountFields.showLabel = true;
                    objDicountFields.isEditable = false;
                }
                
                if(objDicountFields.fieldName == GlUt_APIConstantsDiscountType.RECURRINGFREQUENCYAPINAME){
                    objDicountFields.fieldLabel = Label.CuAp_RecurrenceFrequency;
                    objDicountFields.showLabel = true;
                    objDicountFields.isEditable = false;
                }
                
                
                if(objDicountFields.fieldName == GlUt_APIConstantsDiscountType.MAXDISCOUNTPERSERVICEITEMAPINAME){
                    objDicountFields.fieldLabel = System.Label.CuAp_MaxPercentageServiceItem;
                    objDicountFields.showLabel = true;
                    objDicountFields.isEditable = false;
                }
                
                if(objDicountFields.fieldName == GlUt_APIConstantsDiscountType.TOPUPAPINAME){
                    objDicountFields.fieldLabel = System.Label.CuAp_TopUpLabel;
                    objDicountFields.showLabel = true;
                    objDicountFields.isEditable = false;
                }
                
                
                if(objDicountFields.fieldName == GlUt_APIConstantsDiscounts.STARTDATEAPINAME){
                    objDicountFields.isEditable = true;
                    objDicountFields.editMode = true;
                }
                
                if(objDicountFields.fieldName == GlUt_APIConstantsDiscounts.ENDDATEAPINAME){
                    objDicountFields.isEditable = true;
                    objDicountFields.editMode = true;
                }
            }
            
            for(integer i=0; i < lstDiscountTypeFields.size(); i = i+2){
                List<GlAp_FieldProps> lstEntry = new List<GlAp_FieldProps>();
                integer secondEntryIndex = i+1;
                lstEntry.add(lstDiscountTypeFields[i]);
                
                if(secondEntryIndex < lstDiscountTypeFields.size()){
                    lstEntry.add(lstDiscountTypeFields[secondEntryIndex]);   
                }
                twoColFormattedList.add(lstEntry);
            }
            return twoColFormattedList;
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }  finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
   
    }

}