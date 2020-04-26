({
	DEBUG: 'TemplateSettingForm: ',
	
    // initialise component
	doInit: function(component, event, helper) {

        component.set('v.objectType', this.setPrefixedString('TemplateSetting__c'));
        component.set('v.client', {'sobjectType': this.setPrefixedString('TemplateSetting__c')});
        component.set('v.fieldSet', this.setPrefixedString('EntryFields'));
        
        // get the fields to display         
        this.getObjectFieldsIn2ColForm(component, event, helper, 
	    		function(response) {            					            					 
					component.set('v.fieldSetResults', response);
	    		}
        );
        
        // get the template names for the picklist
        this.callServer(component, 'c.getCorrespondenceTemplates',
        					function(response) {
						        var correspondenceTemplates = [{templateId: null, templateName: null, templateType: null}];
						        correspondenceTemplates.push(...response);
						        component.set('v.correspondenceTemplates', correspondenceTemplates);
						        
						    	// if the record exists, initialise the fields
						    	if (component.get('v.recordId')) {
									this.getObjectRecord(component, event, helper, 
								    		function(response) {
												component.set('v.client', response);
							                    if (response) {
													if (response.hasOwnProperty('CurrencyIsoCode')) {
							                        	component.set('v.currencyCode', response.CurrencyIsoCode);
							                        }
							                        
							                        // initialise the selected template
							                        var templateId;
							                        if (response[this.setPrefixedString('TemplateMapping__c')]) {
							                        	templateId = response[this.setPrefixedString('TemplateMapping__c')];
							                        	
							                        } else if (response[this.setPrefixedString('EmailTemplateId__c')]) {
							                        	templateId = response[this.setPrefixedString('EmailTemplateId__c')];
							                        }

							                        if (templateId) {
												    	for (var i = 0; i < correspondenceTemplates.length; i++) {
												    		if (templateId === correspondenceTemplates[i].templateId) {
												    			component.set('v.selectedTemplateName', correspondenceTemplates[i].templateName);
												    			break;
												    		}
												    	}
												    }
							                    }
								    		}
							        );
							    }
						        
        					},
        					null);
        					
    },
    
    // navigation with validation/server calls 
    navigateStep: function(component, event) {
        
        console.log(this.DEBUG + 'Wizard navigation handler');
        var message = event.getParam('message');
        if (message === 'CANCEL') {
            this.doCancel(component);
            
        } else if (message === 'NEXT') {
            var TemplateSetting = this.validateOnNext(component);
            if (TemplateSetting) {
                this.callApexSave(component, TemplateSetting);
            }
            
        } else if (message === 'BACK') {
            // not valid
        }
    },
    
    // validate the form
    validateOnNext: function(component) {

    	var selectedTemplateName = component.get('v.selectedTemplateName');
    	var TemplateSetting = component.get('v.client');
        console.log(this.DEBUG + 'TemplateSetting: ' + JSON.stringify(TemplateSetting));
    	
    	if (TemplateSetting[this.setPrefixedString('AccountType__c')] == '') {
    		TemplateSetting[this.setPrefixedString('AccountType__c')] = null;
    	}
    	
		var allMatchFieldsCompleted = TemplateSetting[this.setPrefixedString('AccountType__c')] != null 
										&& TemplateSetting[this.setPrefixedString('PaymentPlanType__c')] != null 
										&& TemplateSetting[this.setPrefixedString('PaymentMethodType__c')] != null;
		var noMatchFieldsCompleted = TemplateSetting[this.setPrefixedString('AccountType__c')] == null 
										&& TemplateSetting[this.setPrefixedString('PaymentPlanType__c')] == null 
										&& TemplateSetting[this.setPrefixedString('PaymentMethodType__c')] == null;
        console.log(this.DEBUG + 'allMatchFieldsCompleted: ' + allMatchFieldsCompleted);
        console.log(this.DEBUG + 'noMatchFieldsCompleted: ' + noMatchFieldsCompleted);

		// validate the fields
		var errorMessages = [];
		if (!TemplateSetting[this.setPrefixedString('Type__c')]) {
			errorMessages.push($A.get('$Label.c.CuAp_TemplateSettingTypeRequiredError'));
		
		// correspondence
		} else if (TemplateSetting[this.setPrefixedString('Type__c')] != $A.get('$Label.c.CuAp_TemplateSettingTypeBillPDF')) {
		
			// clear any billing event
			TemplateSetting[this.setPrefixedString('BillingEvent__c')] = null;
			
		// bill pdf
		} else {
		
			// billing event must be populated
			if (!TemplateSetting[this.setPrefixedString('BillingEvent__c')]) {
				errorMessages.push($A.get('$Label.c.CuAp_TemplateSettingBillingEventRequiredError'));
			}
		}
		
		// additional match fields must be either all complete or all empty
		if (!allMatchFieldsCompleted && !noMatchFieldsCompleted) {		// not all completed and not all empty
			errorMessages.push($A.get('$Label.c.CuAp_TemplateSettingMatchFieldsAllOrNoneError'));			
		}

		// template name must be populated
		if (!selectedTemplateName) {
			errorMessages.push($A.get('$Label.c.CuAp_TemplateSettingTemplateRequiredError'));
		}

		// display errors and exit
		if (errorMessages.length > 0) {
			this.showNotification(component, errorMessages);
			return null;
		}
		
		// assign the template Id to the correct field on the template setting
		if (selectedTemplateName) {
			var selectedTemplate;
			var correspondenceTemplates = component.get('v.correspondenceTemplates');
	    	for (var i = 0; i < correspondenceTemplates.length; i++) {
	    		if (selectedTemplateName === correspondenceTemplates[i].templateName) {
	    			selectedTemplate = correspondenceTemplates[i];
	    			break;
	    		}
	    	}
			console.log(JSON.stringify(selectedTemplate));
		
			switch (selectedTemplate.templateType) {
				case 'PDF': 
					TemplateSetting[this.setPrefixedString('TemplateMapping__c')] = selectedTemplate.templateId;
					TemplateSetting[this.setPrefixedString('EmailTemplateId__c')] = null;
					TemplateSetting[this.setPrefixedString('TemplateName__c')] = selectedTemplate.templateName;
					break;
					
				case 'CSV': 
					TemplateSetting[this.setPrefixedString('TemplateMapping__c')] = selectedTemplate.templateId;
					TemplateSetting[this.setPrefixedString('EmailTemplateId__c')] = null;
					TemplateSetting[this.setPrefixedString('TemplateName__c')] = selectedTemplate.templateName;
					break;
					
				case 'HTML': 
					TemplateSetting[this.setPrefixedString('TemplateMapping__c')] = null;
					TemplateSetting[this.setPrefixedString('EmailTemplateId__c')] = selectedTemplate.templateId;
					TemplateSetting[this.setPrefixedString('TemplateName__c')] = selectedTemplate.templateName;
					break;
					
				case 'Visualforce': 
					TemplateSetting[this.setPrefixedString('TemplateMapping__c')] = null;
					TemplateSetting[this.setPrefixedString('EmailTemplateId__c')] = selectedTemplate.templateId;
					TemplateSetting[this.setPrefixedString('TemplateName__c')] = selectedTemplate.templateName;
					break;
	
				default:
					TemplateSetting[this.setPrefixedString('TemplateMapping__c')] = null;
					TemplateSetting[this.setPrefixedString('EmailTemplateId__c')] = null;
					TemplateSetting[this.setPrefixedString('TemplateName__c')] = null;
			}
		}
		return TemplateSetting;
    },
    
    // save the form
    callApexSave: function(component, TemplateSetting) {
		
        // call server to save the record
        let params = {'TemplateSetting': TemplateSetting
                     };

        this.callServer(component,'c.saveTemplateSetting',
                        function(response) { 
                            if (response) this.goToRecord(response);		// re-direct to new/updated record
                        },                         
                        params);
	},
	
    // call the notification component method to show a notification
    showNotification: function(component, message, type) {
    	component.find('notification').showNotification(message, type);
    },

    // call the notification component method to clear a notification
    clearNotification: function(component) {
    	this.showNotification(component, null);
    },
    
    // toggle the form section visibility
    doToggleSection: function(component) {
        var sctn = component.find('formSect');
        
        var DownIcon = component.find('DownIcon');
        var RightIcon = component.find('RightIcon');
        
        $A.util.toggleClass(DownIcon, 'slds-hide');
        $A.util.toggleClass(RightIcon, 'slds-hide');
		$A.util.toggleClass(sctn, 'slds-is-open');
	},
	
	// cancel
	doCancel: function(component) {
		this.back();
	},
    
    // handle change event
    handleInputChangeEvent: function(component, event) {
        var eventParams = event.getParams();
        var PDFTemplateRecord = component.get('v.client');
        
        if (eventParams['fieldName'] == this.setPrefixedString('Type__c')) {
        	component.set('v.isBillPDF', PDFTemplateRecord[this.setPrefixedString('Type__c')] == 'Bill PDF');
        }
    },

	// switch to another record page
    goToRecord: function(recordId) {
        console.log(this.DEBUG + 'redirecting ...');
        var evt = $A.get('e.force:navigateToURL');
        console.log(this.DEBUG + 'record Id: ' + recordId);
        evt.setParams({
            url: '/one/one.app#/sObject/' + recordId
        });
        evt.fire();
    },

    reloadPage: function() {
		var urlEvent = $A.get('e.force:navigateToURL');
		var currentUrl = window.location.href;
		urlEvent.setParams({
			'url': currentUrl
		});
		urlEvent.fire();
	},
	
	back: function() {
        var url = window.location.href; 
        var value = url.substr(0, url.lastIndexOf('/') + 1);
        window.history.back();
    }

})