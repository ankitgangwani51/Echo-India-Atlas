({
	DEBUG: 'NewReadingForm: ',
	
    // initialise component
	doInit: function(component, event, helper) {
                
        component.set('v.client', {'sobjectType': this.setPrefixedString('Reading__c')});
    	// initialise the fields from the parent record Id & reading type
    	this.prePopulateRecord(component);
        this.getObjectFieldsIn2ColForm(component, event, helper, 
	    		function(response) {            					            					 
					component.set('v.fieldSetResults', response);
	    		}
        );
    },
    
	// pre-populate the reading fields
    prePopulateRecord: function(component) {
        debugger;
    	var prePopulatedReading = component.get('v.reading');
    	var reading = component.get('v.client');

    	console.log(this.DEBUG + 'sObjectName: ' + component.get('v.sObjectName'))
    	if (reading) {
    	
	    	switch (component.get('v.sObjectName')) {
	    	
	    		// parent is Device
	    		case this.setPrefixedString('Device__c'):
	    			reading[this.setPrefixedString('Device__c')] = component.get('v.recordId');	//AT-3174
		        	break;
		    }
            
	    	if (prePopulatedReading) {
	    		if (prePopulatedReading[this.setPrefixedString('Device__c')]) {		//AT-3174
	    			reading[this.setPrefixedString('Device__c')] = prePopulatedReading[this.setPrefixedString('Device__c')];	//AT-3174
	    		}
	    		if (prePopulatedReading[this.setPrefixedString('ReadingType__c')]) {
	    			reading[this.setPrefixedString('ReadingType__c')] = prePopulatedReading[this.setPrefixedString('ReadingType__c')];
	    		}
	    		if (prePopulatedReading[this.setPrefixedString('ReadingDate__c')]) {
	    			reading[this.setPrefixedString('ReadingDate__c')] = prePopulatedReading[this.setPrefixedString('ReadingDate__c')];
	    		}
	    		if (prePopulatedReading[this.setPrefixedString('BillableType__c')]) {
	    			reading[this.setPrefixedString('BillableType__c')] = prePopulatedReading[this.setPrefixedString('BillableType__c')];
	    		}
	    		if (prePopulatedReading[this.setPrefixedString('ReadingSource__c')]) {
	    			reading[this.setPrefixedString('ReadingSource__c')] = prePopulatedReading[this.setPrefixedString('ReadingSource__c')];
	    		}
	    		if (prePopulatedReading[this.setPrefixedString('ReadingMethod__c')]) {
	    			reading[this.setPrefixedString('ReadingMethod__c')] = prePopulatedReading[this.setPrefixedString('ReadingMethod__c')];
	    		}
	    		if (prePopulatedReading[this.setPrefixedString('ActualDeviceReading__c')]) {
	    			reading[this.setPrefixedString('ActualDeviceReading__c')] = prePopulatedReading[this.setPrefixedString('ActualDeviceReading__c')];
	    		}
                if (prePopulatedReading[this.setPrefixedString('Tripped__c')]) {  // AT-3415 core-8b
	    			reading[this.setPrefixedString('Tripped__c')] = prePopulatedReading[this.setPrefixedString('Tripped__c')];
	    		}
	    	}
		}

    	component.set('v.client', reading);
    	console.log(this.DEBUG + 'reading: ' + JSON.stringify(reading));
    },

    // validate the form
    validateForm: function(component) {

		// Ensure that required fields are populated
		var required;
		var fieldNameLabel;   // AT-2198 core 8b
		var fieldName;
		var fieldLabel;
		var requiredFieldErrorList = [];
        
        //testing
        var readingRecord = component.get('v.reading');
        console.log(this.DEBUG + 'reading rec: ' + JSON.stringify(readingRecord));
			
		var fieldSetResults = component.get('v.fieldSetResults');
		var record = component.get('v.client');
        //record[this.setPrefixedString('ActualDeviceReading__c')]
		console.log(this.DEBUG + 'client: ' + JSON.stringify(record));
		console.log(this.DEBUG + 'fieldSetResults: ' + JSON.stringify(fieldSetResults));
		
		for (var i in fieldSetResults) {
			var propEntry = fieldSetResults[i];
			
			for (var j in propEntry) {
				var prop = propEntry[j];
				required = prop.isRequired;
				fieldNameLabel = prop.fieldName;   //AT-2198 core 8b               
				fieldLabel = prop.fieldLabel;
				fieldName = record[fieldNameLabel];   //AT-2198 core 8b
                
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
					errorMessage = $A.get('$Label.c.CuAp_RequiredFieldsErrorMsg');
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
			this.doObjectSave(component, event, helper, 
					function(response) {
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
    
    //handling the change event of the component
    handleInputChangeEvent  : function(component, event, helper) {
        var eventParams = event.getParams();
        var readingRecord = component.get('v.client');
        var fieldSet = component.get('v.fieldSetResults');
        if(eventParams['fieldName'] == this.setPrefixedString('ReadingMethod__c')){
            if(readingRecord[this.setPrefixedString('ReadingMethod__c')]){
                //looping on the fields 
                for(var i = 0; i < fieldSet.length; i++){
                    for(var j = 0; j < fieldSet[i].length; j++){
                        //validating if the field is ActualDeviceReading__c or not
                        if(fieldSet[i][j]['fieldName'] == this.setPrefixedString("ActualDeviceReading__c")){
                            //if the ReadingMethod__c is system estimated than enable the ActualDeviceReading__c for editing
                            if(readingRecord[this.setPrefixedString('ReadingMethod__c')] == $A.get('$Label.c.CuAp_NewReadingFormReadngMthd')){
                                fieldSet[i][j]['isEditable'] = false;
                            }else if(readingRecord[this.setPrefixedString('ReadingMethod__c')] != $A.get('$Label.c.CuAp_NewReadingFormReadngMthd')){
                                fieldSet[i][j]['isEditable'] = true;
                            }
                            break;
                        }
                    }
                    break;
                }
                component.set('v.fieldSetResults',fieldSet);
                //AT-3084 Starts Here
                component.set('v.isPicklistPrePopulated',true);
                //AT-3084 Ends Here
            }
        }
        
        // AT-2198 core 8b start...
        if(eventParams['fieldName'] == this.setPrefixedString('ReadingType__c')){
            if(readingRecord[this.setPrefixedString('ReadingType__c')]){
                if(readingRecord[this.setPrefixedString('ReadingType__c')] == $A.get('$Label.c.CuAp_ReadingReadingTypeExchangeInitial')){
                   component.set('v.isExchangeInitialReading',true);
                }else if(readingRecord[this.setPrefixedString('ReadingMethod__c')] != $A.get('$Label.c.CuAp_ReadingReadingTypeExchangeInitial')){
                   component.set('v.isExchangeInitialReading',false);
                }               
            }
        }  // AT-2198 core 8b end...
    }
    
    
    
    
})