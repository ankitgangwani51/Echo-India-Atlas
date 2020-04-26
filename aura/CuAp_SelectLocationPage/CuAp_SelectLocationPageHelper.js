({
	DEBUG: 'Selectlocation: ',

	/* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {
    	console.log(this.DEBUG + 'reInitialise');
        component.set('v.isInitialised', false);
    	component.set('v.locationsFound', false);
    	component.set('v.hasSearched', false);
    	component.set('v.searchLocation', {'sobjectType': this.setPrefixedString('Location__c')});
		component.set('v.fieldList', []);
		component.set('v.searchFieldList', []);
		component.set('v.recordList', []);
    },

    // check the wizardprop/status on entry
    checksOnEntry: function(component) {
    	// do checks here if required
    	console.log(this.DEBUG + 'checksOnEntry');
    	if (!component.get('v.isInitialised')) {
            component.set('v.searchLocation', {'sobjectType': this.setPrefixedString('Location__c')});
    		this.initialiseDisplayedFields(component);
    	}
    },

    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {
    	// do all completion validation here
    	console.log(this.DEBUG + 'validateOnNext');
    	var wizObj = component.get('v.wizardprop');
    	
    	// locationId is required
        if (wizObj.location === undefined || wizObj.location.Id === undefined || wizObj.location.Id === null) {
			this.showNotification(component, ['You must select a location']);
			return false;
		}
		return true;
    },

    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
    	component.find('notifier').showNotification(message, type);
    },

    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
    	component.find('notifier').clearNotification();
    },   
	/* END: REQUIRED BY FRAMEWORK */
    
    /* PAGE SPECIFIC FUNCTIONS */
    // initialise all the displayed fields
	initialiseDisplayedFields: function(component) {

        // retrieve list of fields and properties for the search parameters
        this.callServer(component,'c.retrieveSearchLocationDetails', 
                        function(response) {
                            component.set('v.searchFieldList', response);
                            console.log(response);
                        },
                        null);
        
        // retrieve list of fields and properties for the location
        this.callServer(component,'c.retrieveLocationPropDetails', 
                          function(response) {
                              component.set('v.fieldList', response);
                              console.log(response);
                          },
                          null);  
        component.set('v.isInitialised', true);
    },
    
    // select/unselect a location
    handleRowSelectEvent: function(component, event, helper) {
        var sRowId = event.getParam('RowId');
        var locFound = component.get('v.recordList');
        var wizObj = component.get('v.wizardprop');
        wizObj.locationId = null;
        wizObj.location = {sobjectType: this.setPrefixedString('Location__c'), 
        						Id: null,
        						[this.setPrefixedString('NumberOfOccupiers__c')] : null};
        
        for (var i = 0; i < locFound.length; i++) {
            if (locFound[i].uniqueId != sRowId) {
                locFound[i].isSelected = false;
            } else if(locFound[i].isSelected == true) {
                wizObj.locationId = sRowId;
                wizObj.location = {sobjectType: this.setPrefixedString('Location__c'), 
        						Id: sRowId,
        						[this.setPrefixedString('NumberOfOccupiers__c')] : null}
            }
        }
        component.set('v.wizardprop',wizObj);
        component.set('v.recordList', locFound);
        this.clearNotification(component);
    },
    
    // clear the location
    clearLocation: function(component) {
        var wizObj = component.get('v.wizardprop');
        delete(wizObj.location);
        component.set('v.wizardprop', wizObj);
    },
    
    // perform a search by calling the server
    doSearch: function(component, event, helper) { 
        var searchLoc = component.get('v.searchLocation');
        this.clearLocation(component);
    	component.set('v.hasSearched', false);

        // retrieve the list of location records
        let params = {
            'searchLoc': searchLoc
        }; 
        
        this.callServer(component,'c.queryForLocations', 
        					function(response) {
        						component.set('v.recordList', response);
        						if (response.length > 0) {
        							component.set('v.locationsFound', true);
        						} else {
        							component.set('v.locationsFound', false);
        						}
        						component.set('v.hasSearched', true);
                          },
                          params);
    },
})