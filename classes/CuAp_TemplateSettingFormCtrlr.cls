/******************************************************************************
@author         Echo: Patrick Dixon
@date           08 Jun 2018
@description    Controller for Template Setting Form component
				This component is used for admin only and so there are no FLS checks performed
                AT-4890 - CRUD Delete for CuAp_TemplateSettingFormCtrlr - Added Cleanse (Code Check Marx Security Review)
*******************************************************************************/
public with sharing class CuAp_TemplateSettingFormCtrlr {
	    
    public static final String CLASS_NAME = 'CuAp_PDFTemplateFormCtrl';
    public static final String DEBUG = '[' + CLASS_NAME + '] ';

	public static final List<String> EMAIL_TEMPLATE_TYPES = new List<String>{
																			Label.CuAp_TemplateTypeHTML, 
																			Label.CuAp_TemplateTypeVisualforce
																			};

    public static List<CorrespondenceTemplate> correspondenceTemplates;

    /******************************************************************************
	@author         Echo: Patrick Dixon
	@date           08 Jun 2018
	@description	class to hold details of correspondence templates
	*******************************************************************************/
	public class CorrespondenceTemplate {
		
		@AuraEnabled public Id templateId;
		@AuraEnabled public String templateName;
		@AuraEnabled public String templateType;
		
		public CorrespondenceTemplate(Id templateId, String templateName, String templateType) {
			this.templateId = templateId;
			this.templateName = templateName;
			this.templateType = templateType;
		}
	}

    /******************************************************************************
	@author         Echo: Patrick Dixon
	@date           08 Jun 2018
	@return			List<CorrespondenceTemplate> - returns a list of correspondence template - email and pdf/csv
	@description	gets the correspondence templates
	*******************************************************************************/
    @AuraEnabled
    public static List<CorrespondenceTemplate> getCorrespondenceTemplates() {
        correspondenceTemplates = new List<CorrespondenceTemplate>();
        
        try {
	        for (EmailTemplate emailTemplate : [select Id, 
	        											Name, 
	        											TemplateType 
	        									 from EmailTemplate
	        									 where TemplateType in :EMAIL_TEMPLATE_TYPES]) {
	        								
				correspondenceTemplates.add(new CorrespondenceTemplate(emailTemplate.Id, emailTemplate.Name, emailTemplate.TemplateType));
			}
            /*AT-4374, Clayton Code Review Starts Here */
			for (TemplateMapping__c S3Template : [select Id, 
														Name, 
														PDFTemplate__c, 
														XSLTDocument__c 
												from TemplateMapping__c Limit 50000]) {
				correspondenceTemplates.add(new CorrespondenceTemplate(S3Template.Id, S3Template.PDFTemplate__c, Label.CuAp_TemplateTypePDF));
			}
            /*AT-4374, Clayton Code Review Ends Here */
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage()); 

        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        
		System.debug(DEBUG + 'correspondenceTemplates: ' + correspondenceTemplates);
        return correspondenceTemplates;
    }
    
    /******************************************************************************
	@author         Echo: Patrick Dixon
	@date           08 Jun 2018
	@param			TemplateSetting__c - updated/new TemplateSetting
	@return			Id - the Id of the saved TemplateSetting
	@description	saves the TemplateSetting
	*******************************************************************************/
    /*
     
	public static Id saveTemplateSetting(list<TemplateSetting__c> listTemplateSetting) {
		map<Id, TemplateSetting__c> mapTsIds	= new map<Id, TemplateSetting__c>() ;
		set<String> setTsType 					= new set<String>() ;
		set<String> setTsBillingEvent 			= new set<String>() ;
		set<String> setTsAccountType 			= new set<String>() ;
		set<String> setTsPaymentPlanType 		= new set<String>() ;
		set<String> setTsPaymentMethodType 		= new set<String>() ;
		list<TemplateSetting__c> listUpdatedTemplateSetting		= new list<TemplateSetting__c>() ;
		
    	if(listTemplateSetting != null && !listTemplateSetting.isEmpty()) {
			for(TemplateSetting__c tempSetting : listTemplateSetting) {
				mapTsIds.put(tempSetting.Id, tempSetting) ;
				setTsType.add(tempSetting.Type__c) ;
				setTsBillingEvent.add(tempSetting.BillingEvent__c) ;
				setTsAccountType.add(tempSetting.AccountType__c) ;
				setTsPaymentPlanType.add(tempSetting.PaymentPlanType__c) ;
				setTsPaymentMethodType.add(tempSetting.PaymentMethodType__c) ;
			}
			list<TemplateSetting__c> listTemplateSettingToRemove = new list<TemplateSetting__c>() ;
			for (TemplateSetting__c existingTemplateSetting : [SELECT Id FROM TemplateSetting__c
																WHERE 
																Type__c IN: setTsType
																AND BillingEvent__c IN: setTsBillingEvent
																AND AccountType__c IN: setTsAccountType
																AND PaymentPlanType__c IN: setTsPaymentPlanType
																AND PaymentMethodType__c IN: setTsPaymentMethodType]) {
				if(!mapTsIds.isEmpty() && !mapTsIds.containsKey(existingTemplateSetting.Id)) {
					//flag the edited one to be removed
	     			listTemplateSettingToRemove.add(new TemplateSetting__c(Id = TemplateSetting.Id)) ;
				} 
			}
		}

	*/
    @AuraEnabled
    public static Id saveTemplateSetting(TemplateSetting__c TemplateSetting) {
    	
        try {
	    	// check if this setting already exists
	    	TemplateSetting__c TemplateSettingToRemove;
	    	for (TemplateSetting__c existingTemplateSetting : [select Id  
				    												from TemplateSetting__c
				    												where Type__c = :TemplateSetting.Type__c 
				    													and BillingEvent__c = :TemplateSetting.BillingEvent__c
				    													and AccountType__c = :TemplateSetting.AccountType__c
				    													and PaymentPlanType__c = :TemplateSetting.PaymentPlanType__c 
				    													and PaymentMethodType__c = :TemplateSetting.PaymentMethodType__c]) {
		    														    		
	     		// if it does and it's not the edited one
	     		system.debug(DEBUG + 'existingTemplateSetting: ' + existingTemplateSetting);
	     		if (TemplateSetting.Id != null && TemplateSetting.Id != existingTemplateSetting.Id) {
	     			
	     			// flag the edited one to be removed
	     			TemplateSettingToRemove = new TemplateSetting__c(Id = TemplateSetting.Id);
	     		}
	     			
	    		// update the existing one							
	    		TemplateSetting.Id = existingTemplateSetting.Id;			
	     		
			}
	    	
	    	// update the records
			TemplateSetting = (TemplateSetting__c) GlUt_FieldSecurity.cleanseFields(TemplateSetting, false);
	    	upsert TemplateSetting;
            /*AT-4890 Code Check marx Changes Starts here*/
            if(TemplateSettingToRemove != null){
                List<TemplateSetting__c> templateSettingToRemoveList = new List<TemplateSetting__c>();
                templateSettingToRemoveList.add(TemplateSettingToRemove);
                if(GlUt_ObjectSecurity.isObjectPermission(templateSettingToRemoveList,true,false,false,false,false)){ 
                    TemplateSettingToRemove = (TemplateSetting__c) GlUt_FieldSecurity.cleanseFields(TemplateSettingToRemove, false);
                    delete TemplateSettingToRemove;
                }
            } 
            /*AT-4890 Code Check marx Changes Ends here*/
        } catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage()); 

        } finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
        
		return TemplateSetting.Id;
    }

}