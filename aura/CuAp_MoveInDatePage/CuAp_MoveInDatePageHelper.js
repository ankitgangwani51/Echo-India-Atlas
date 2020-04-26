({
	DEBUG: 'MoveInDate: ',

    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {
        component.set('v.isInitialised', false);
        component.set('v.locationId', '');
        component.set('v.fieldList', []);
        component.set('v.recordList', []);
        component.set('v.occupantsFound',false);
        component.set('v.locationDetails', {'sobjectType':this.setPrefixedString('Location__c')});
        component.set('v.selectedMoveIn', {'sobjectType':this.setPrefixedString('LocationOccupant__c')});
        component.set('v.locationsRef', []);
        component.set('v.occupancyType', []);
    },

    // check the wizardprop/status on entry
    checksOnEntry: function(component) {
  
    	// do checks here if required
        var wizObj = component.get('v.wizardprop');
        if (wizObj.location.Id) {
	    	if (!component.get('v.isInitialised')) {
                component.set('v.locationDetails', {'sobjectType':this.setPrefixedString('Location__c')});
                component.set('v.selectedMoveIn', {'sobjectType':this.setPrefixedString('LocationOccupant__c')}); 
	    		this.initialiseDisplayedFields(component);
	    	}
            this.showNewRecord(component);
        }
    },
   
    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {
    	// do all completion validation here
        var moveInField = component.get('v.selectedMoveIn');
        var hhAccount = component.get('v.isHHAccount');
        var locDetails = component.get('v.locationDetails');
        
        var errorList = [];
        
        // move In Date is required
        if (!moveInField[this.setPrefixedString('StartDate__c')]) {
    		errorList.push($A.get('$Label.c.CuAp_ValidationMoveInDatePage'));
		}
        if (moveInField[this.setPrefixedString('EndDate__c')] && moveInField[this.setPrefixedString('EndDate__c')] > moveInField[this.setPrefixedString('StartDate__c')]) {
        	errorList.push($A.get('$Label.c.CuAp_ValidateMoveInDate'));
        } 
        if (!moveInField[this.setPrefixedString('OccupancyType__c')]) {
    		errorList.push($A.get('$Label.c.CuAp_ValidationOccupancyType'));
		}
        if (hhAccount == 'True' && (!locDetails[this.setPrefixedString('NumberOfOccupiers__c')] || locDetails[this.setPrefixedString('NumberOfOccupiers__c')] < 1)) {
            errorList.push($A.get('$Label.c.CuAp_ValidateNumberOfOccupier'));
        }
        
        /*MT - As per ticket number AT-1446 validation is added to prevents a move in date been entered that is before 
         the move in date of the current active primary occupant or should not overlap the move in date of the current active primary occupant*/
        var locationOccList = component.get('v.recordList');
        for (var i = 0; i < locationOccList.length; i++) {
            if (locationOccList[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('Primary__c')]) {  
                if (locationOccList[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('EndDate__c')]
                		&& locationOccList[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('EndDate__c')] > moveInField[this.setPrefixedString('StartDate__c')]) {
                    errorList.push($A.get('$Label.c.CuAp_ValidatePrimaryMoveInDate'));
                    
                } else if (locationOccList[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('StartDate__c')] > moveInField[this.setPrefixedString('StartDate__c')]) {
                    errorList.push($A.get('$Label.c.CuAp_ValidatePrimaryMoveInDate'));  
                }
            }
            
            // AT-2150, Move out date of previous occupier must be after move in date of the previous occupier
            if(component.get('v.latestOccMoveInDate') === null){
                component.set('v.latestOccMoveInDate',locationOccList[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('StartDate__c')]);
            } else if(component.get('v.latestOccMoveInDate') < locationOccList[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('StartDate__c')]){
                component.set('v.latestOccMoveInDate',locationOccList[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('StartDate__c')]);
            }
        }

        // AT-2150, Move out date of previous occupier must be after move in date of the previous occupier
        if(component.get('v.latestOccMoveInDate') != null && moveInField[this.setPrefixedString('EndDate__c')] && moveInField[this.setPrefixedString('EndDate__c')] < component.get('v.latestOccMoveInDate')){
            errorList.push($A.get('$Label.c.CuAp_MoveoutDateMoveInDatePreviousOcc')); 
        }        
        
        // MT 02-08-2018 AT - 2336 Move in date should be greater than the previous occupier move out date
        if(component.get("v.lastOccMoveOutDate") >= moveInField[this.setPrefixedString('StartDate__c')]){
            errorList.push($A.get('$Label.c.CuAp_MoveInDatePrevOccMoveOut'));
        }
        
        if (errorList.length > 0) {
        	this.showNotification(component, errorList);
        	return false;
        }
        
        //AT-4037 Start
        var wizObj = component.get('v.wizardprop'); 
        wizObj.selectedOccType = moveInField[this.setPrefixedString('OccupancyType__c')];
        component.set('v.wizardprop', wizObj); 
        var compEvent = component.getEvent("passValueEvent");
        compEvent.setParam("PicklistValue", moveInField[this.setPrefixedString('OccupancyType__c')]);
        compEvent.fire();
        //AT-4037 End
        
        this.populateWizardObject(component);
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
        
        this.callServer(component,'c.retrieveLocationFields', 
                        function(response) {
                            component.set('v.locationOccupantFields', response);
                        },
                        null);

        // retrieve list of fields and properties for the location
        this.callServer(component,'c.retrieveLocationPropDetails', 
        					function(response) {
        						component.set('v.fieldList', response);
        				},
        				null);
        				
        // retrieve picklist values for occupancy types
        this.callServer(component, 'c.occupancyType',
        					function(response) {
        						component.set('v.occupancyType', response);
            			},
            			null);
        component.set('v.isInitialised', true);
    },
    
    // get the location occupant and details records
    showNewRecord: function(component) {
        var wizObj = component.get('v.wizardprop');        
        var locationId = component.get('v.locationId');     
        
        // if the location has changed
        if (locationId != wizObj.location.Id) {        
        	component.set('v.locationId', wizObj.location.Id);
	        let params = {
	            'sLocationId': component.get('v.locationId'),
	            'recordId' : wizObj.accountId,
	        };

	        this.callServer(component, 'c.getLocationDetails',
        					function(response) {
        						component.set('v.locationsRef', response);
                                
                                var locationRefVar = component.get('v.locationsRef');
                                component.set('v.isHHAccount',locationRefVar[2]);
                                if(locationRefVar[1] == 'True'){  //AT-3174 Used 2nd element of Array instead of 3rd as Location Ref field was removed
                                    component.set('v.locationDetails', {'sobjectType':this.setPrefixedString('Location__c'),
                                                    [this.setPrefixedString('NumberOfOccupiers__c')]:1});
                                }
	    					},
	    					params);
	    					
	        let params2 = {
	        		'sLocationId': component.get('v.locationId')
	        };

	        this.callServer(component, 'c.getLocationOccupants', 
        					function(response) {
        						component.set('v.recordList', response);
        						component.set('v.occupantsFound', response.length > 0);
	        				},
	        				params2);
            
            // MT 02-08-2018 AT - 2336 Move in date should be greater than the previous occupier move out date
            this.callServer(component, 'c.getLastOccupantMoveOutDate',
                        function(response) {
                            component.set("v.lastOccMoveOutDate",response);
                        },
                        params2);
        }
    },

    // populate the wizard properties
    populateWizardObject: function(component) {
        var wizObj = component.get('v.wizardprop');
        var recordSet = component.get('v.recordList');
        var searchLoc = component.get('v.selectedMoveIn');
        var location = component.get('v.locationDetails');
        var endDate;

        if (!searchLoc[this.setPrefixedString('EndDate__c')]) {
        	var startDate = searchLoc[this.setPrefixedString('StartDate__c')].split('-');
       		var newStartDate = new Date(startDate[0], startDate[1] - 1, startDate[2]);
            var newEndDate = newStartDate;
            newEndDate.setDate(newEndDate.getDate() - 1);
            endDate = newEndDate.getFullYear() + '-' + (parseInt(newEndDate.getMonth()) + 1) + '-' + newEndDate.getDate();
        }
        else {
            endDate = searchLoc[this.setPrefixedString('EndDate__c')];
        }
        wizObj.locationOccupantToMoveIn = {sobjectType: this.setPrefixedString('LocationOccupant__c'),
                                           [this.setPrefixedString('Account__c')]: component.get('v.wizardprop.accountId'),
                                           [this.setPrefixedString('Location__c')]: component.get('v.wizardprop.location.Id'),
                                           [this.setPrefixedString('Primary__c')]: true,
                                           [this.setPrefixedString('ShowOnBill__c')]: true,
                                           [this.setPrefixedString('EndDate__c')]: null,
                                           [this.setPrefixedString('StartDate__c')]: searchLoc[this.setPrefixedString('StartDate__c')],
                                           [this.setPrefixedString('OccupancyType__c')]: searchLoc[this.setPrefixedString('OccupancyType__c')]};
        
        var moveOutRecord = [];
        for (var i = 0; i < recordSet.length; i++) {
            if (recordSet[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('EndDate__c')] == 'undefined' 
            		|| recordSet[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('EndDate__c')] == null) {
            	var rec = {sobjectType : this.setPrefixedString('LocationOccupant__c'),
            			Id: recordSet[i].objectMap[this.setPrefixedString('LocationOccupant__c')].Id,
                        [this.setPrefixedString('OccupancyType__c')]: recordSet[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('OccupancyType__c')],   //AT-4040
                        [this.setPrefixedString('Account__c')]: recordSet[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('Account__c')],   //AT-4040
            			[this.setPrefixedString('EndDate__c')]: endDate} 
                moveOutRecord.push(rec);
			} else {
			    var rec = {sobjectType: this.setPrefixedString('LocationOccupant__c'),
			    		Id: recordSet[i].objectMap[this.setPrefixedString('LocationOccupant__c')].Id,
                        [this.setPrefixedString('OccupancyType__c')]: recordSet[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('OccupancyType__c')],  //AT-4040    
                        [this.setPrefixedString('Account__c')]: recordSet[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('Account__c')],   //AT-4040
			    		[this.setPrefixedString('EndDate__c')]: recordSet[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('EndDate__c')]} 
				moveOutRecord.push(rec);
			}
        }
        wizObj.locationOccupantsToMoveOut = moveOutRecord;
        wizObj.moveInDate = searchLoc[this.setPrefixedString('StartDate__c')];
        wizObj.moveOutDate = endDate;
        
        // update the number of occupiers if entered                      
        if (location[this.setPrefixedString('NumberOfOccupiers__c')]) {
        	wizObj.location[this.setPrefixedString('NumberOfOccupiers__c')] = location[this.setPrefixedString('NumberOfOccupiers__c')];
        }
        component.set('v.wizardprop', wizObj);
    },
})