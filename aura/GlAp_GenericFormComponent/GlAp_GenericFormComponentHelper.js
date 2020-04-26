({
	DEBUG: 'GenericFormComponent: ',
	
    // initialise component
	doInit: function(component, event, helper) {           

	    component.find('spinner').show();
		this.getObjectRecord(component, event, helper, 
	    		function(response) {
					component.find('spinner').hide();
					component.set('v.client', response);
                    if (response) {
						if (response.hasOwnProperty('CurrencyIsoCode')) {
                        	component.set('v.currencyCode', response.CurrencyIsoCode);
                        }
                    }
	    		}
        );
        
	    component.find('spinner').show();
        this.getObjectFieldsIn2ColForm(component, event, helper, 
	    		function(response) {            					            					 
					component.find('spinner').hide();
					component.set('v.fieldSetResults', response);
	    		}
        );
    },
    
    // validate the form
    validateForm: function(component) {
    
		// Ensure that required fields are populated
		var required;
		var fieldName;
		var fieldName;
		var fieldLabel;
		var requiredFieldErrorList = [];
			
		var fieldSetResults = component.get('v.fieldSetResults');
		var record = component.get('v.client');
		console.log(this.DEBUG + 'client: ' + JSON.stringify(record));
		console.log(this.DEBUG + 'fieldSetResults: ' + JSON.stringify(fieldSetResults));
		
		for (var i in fieldSetResults) {
			var propEntry = fieldSetResults[i];
			
			for (var j in propEntry) {
				var prop = propEntry[j];
				required = prop.isRequired;
				fieldName = prop.fieldName;
				fieldLabel = prop.fieldLabel;
				fieldName = record[fieldName];
				
				if (required && !fieldName) {
					requiredFieldErrorList.push(fieldLabel);
				}
			} 
		} 
		
		if (requiredFieldErrorList.length > 0) {
			var errorMessage;
			
			for (var e in requiredFieldErrorList) {
				fieldLabel = requiredFieldErrorList[e];
				if (!errorMessage) {
					errorMessage = 'There are required fields on this page that are not populated: ';		// TO-DO - Label
					errorMessage += fieldLabel;
				}
				else {
					errorMessage += ', ' + fieldLabel;
				}
			}
			this.showNotification(component, [errorMessage]);
			return null;
		}
		return record;
    },
    
    // save the form
    doSave: function(component, event, helper) {
		
		if (this.validateForm(component) != null) {
			component.find('spinner').show();
			this.doObjectSave(component, event, helper, 
					function(response) {
						component.find('spinner').hide();
						if (response == null) {
							this.clearNotification(component);
							this.doInit(component);
							component.set('v.editMode', false);
							
						} else {
							this.showNotification(component, [response])
						}	
	    			}
			);
		}
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
		this.clearNotification(component);
		this.doInit(component);
		component.set('v.editMode', false);
	},
})