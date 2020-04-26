({
	DEBUG: 'SelectAccountLocation: ',
	
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {
        console.log(this.DEBUG + 'reInitialise');
        component.set('v.isInitialised', false);
    	component.set('v.accountId', null);
    	component.set('v.savedFilterCriteria', null);
    	component.set('v.savedFilterOperation', null);
    	component.set('v.savedFilterValue', null);
        component.set('v.noResultFound', false);
        component.set('v.fieldList', []); 
        component.set('v.recordList', []);
        component.set('v.filterCriteria', null);
        component.set('v.filterOperation', null);
        component.set('v.filterValue', null);
        component.set('v.searchLocation', {'sobjectType': this.setPrefixedString('Location__c')});
    },
    
	// check the wizardprop/status on entry
    checksOnEntry : function(component) {
    	// do checks here if required
    	console.log(this.DEBUG + 'checksOnEntry');

    	if (!component.get('v.isInitialised')) {
            component.set('v.searchLocation', {'sobjectType': this.setPrefixedString('Location__c')});
    		this.initialiseDisplayedFields(component);
    	}
        this.showNewRecords(component);
    },
    
	// validates the wizardprop on completion of the step
    validateOnNext: function(component) {
        var wizObj = component.get('v.wizardprop');

        // locationId is required
        if (!wizObj.location || !wizObj.location.Id) {
			this.showNotification(component, [$A.get('$Label.c.CuAp_SelectLocationError')]);
			return false;
		}
        else {
            var locFound = component.get('v.recordList');
            for (var i = 0; i < locFound.length; i++) {
                if (locFound[i].isSelected == true) {
                    if (!locFound[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('EndDate__c')]) {
                        this.showNotification(component, [$A.get('$Label.c.CuAp_ValidateMoveOutDate')]);
                        return false;
                    } else if (locFound[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('EndDate__c')] < locFound[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('StartDate__c')]) {
                        this.showNotification(component, [$A.get('$Label.c.CuAp_ValidateMoveOut')]);
                        return false;
                    }
                    else {
                    	wizObj.moveOutDate = locFound[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('EndDate__c')];
                        wizObj.location[this.setPrefixedString('NumberOfOccupiers__c')] = 0;
                    }
                }
            }
        }    
        component.set('v.wizardprop', wizObj);
        this.clearNotification(component);
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
    
    /* PAGE SPECIFIC METHODS */    
    // initialise all the displayed fields
	initialiseDisplayedFields: function(component) {
	
		// initialise the filter labels
    	const criteriaList = [
    							$A.get('$Label.c.CuAp_LocationFilterByCity'), 
    							$A.get('$Label.c.CuAp_LocationFilterByStreet'), 
    							$A.get('$Label.c.CuAp_LocationFilterByState'), 
    							$A.get('$Label.c.CuAp_LocationFilterByPostalCode'), 
    							$A.get('$Label.c.CuAp_LocationFilterByCountry')
			        		];
    	component.set('v.criteriaList', criteriaList);
        component.set('v.filterCriteria', criteriaList[0]);

    	const operationList = [
    							$A.get('$Label.c.CuAp_FilterOperationEquals'), 
    							$A.get('$Label.c.CuAp_FilterOperationNotEqual'), 
    							$A.get('$Label.c.CuAp_FilterOperationContains'), 
    							$A.get('$Label.c.CuAp_FilterOperationDoesNotContain') 
			        		];
    	component.set('v.operationList', operationList);
        component.set('v.filterOperation', operationList[0]);
    	component.set('v.isInitialised', true);
        
        // Retrieve list of fields and properties for the location
        this.callServer(component,'c.retrieveSearchLocationDetails',
        				function(response) {
        					component.set('v.searchFieldList', response);				
        				},
        				null);
    	
        // Retrieve list of fields and properties for the location
        this.callServer(component,'c.retrieveLocationPropDetails',
        				function(response) {
        					component.set('v.fieldList', response);				
        				},
        				null);
        component.set('v.isInitialised', true);
    },
    
    // get the location records from the server
    showNewRecords: function(component) {
        
        var wizObj = component.get('v.wizardprop');
        
        var searchLoc = component.get('v.searchLocation');
        this.clearLocation(component);
        
        // retrieve the list of location records
        let params = {
            'sAccountId': wizObj.accountId,
            'searchLoc': searchLoc
        }; 
    
        this.callServer(component,'c.queryForLocations', 
                        function(response) {
                            
                            component.set('v.recordList', response);
                            if (response.length > 0) {
                                component.set('v.noResultFound', true);
                            } else {
                                component.set('v.noResultFound', false);
                            }
                            //component.set('v.hasSearched', true);
                        },
                        params);
    },
    
    // selected/unselect a location
    handleRowSelectEvent: function(component, event) {
        var sRowId = event.getParam('RowId');
        var recordList = component.get('v.recordList');
        var locationId;
        var moveOutDate;
        
        for (var i = 0; i < recordList.length; i++) {
            if (recordList[i].uniqueId == sRowId) {
            	recordList[i].isSelected = true;
            	recordList[i].readOnlyFields[[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('EndDate__c')]] = false;
            	locationId = recordList[i].objectMap[this.setPrefixedString('Location__c')].Id;
            	moveOutDate = recordList[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('EndDate__c')];
            }
            else {
            	recordList[i].readOnlyFields[[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('EndDate__c')]] = true;
                recordList[i].isSelected = false;
            }
        }
        component.set('v.recordList', []);
        component.set('v.recordList', recordList);
        var wizObj = component.get('v.wizardprop');
        wizObj.location = {sobjectType: this.setPrefixedString('Location__c'), 
        						Id: locationId}
        component.set('v.wizardprop', wizObj);
    },
    
    // clear the location
    clearLocation: function(component) {
        var wizObj = component.get('v.wizardprop');
        delete(wizObj.location);
        component.set('v.wizardprop', wizObj);
    },
    
    // apply the filter
  	doFilter: function(component) {
        this.clearLocation(component);
        this.showNewRecords(component);
    },
    
    // clear the filter
    doReset: function(component) {
    	component.set('v.filterCriteria', null);
    	component.set('v.filterOperation', null);
    	component.set('v.filterValue', null);
        this.clearLocation(component);
        this.showNewRecords(component); 
    },
    
})