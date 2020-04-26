({
	DEBUG: 'MoveOutReading: ',
	
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {
        console.log(this.DEBUG + 'reInitialise');
        component.set('v.isInitialised', false);
        component.set('v.locationId', []);
        component.set('v.moveOutDate', null);
		component.set('v.fieldList', []);
		component.set('v.recordList', []);
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component) {
    	// do checks here if required
    	console.log(this.DEBUG + 'checksOnEntry');

    	var wizObj = component.get('v.wizardprop');
    	if (wizObj.location.Id && wizObj.moveOutDate) {
			if (!component.get('v.isInitialised')) {
				this.initialiseDisplayedFields(component);
			}
	        this.loadReadings(component);
    	}
    },
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {
        var wizObj = component.get('v.wizardprop');
        var moveOutDate = wizObj.moveOutDate;
        var moveInDate = this.formatDate(this.addDays(moveOutDate, 1));
        var recordList = component.get('v.recordList');

        var moveOutReadings = [] ;
        var errorMessage = [];

        for (var i = 0; i < recordList.length ; i++) {  
            var objReading = recordList[i].objectMap[this.setPrefixedString('Reading__c1')]; //Sit005 Sanity testing issue
            var objPreviousReading  = recordList[i].objectMap[this.setPrefixedString('Reading__c')];

            var newReading = objReading[this.setPrefixedString('ActualDeviceReading__c')];
            var readingMethod = objReading[this.setPrefixedString('ReadingMethod__c')];
            var tripped = objReading[this.setPrefixedString('Tripped__c')];		// AT-3421 core 8b
            var previousReading = objPreviousReading[this.setPrefixedString('ActualDeviceReading__c')];
            var deviceDigit = recordList[i].objectMap[this.setPrefixedString('Device__c')][this.setPrefixedString('Digit__c')];
            var serialNumber = recordList[i].objectMap[this.setPrefixedString('Device__c')][this.setPrefixedString('SerialNo__c')];

            // validate the reading
            if (!newReading || !readingMethod) {
                errorMessage.push($A.get('$Label.c.CuAp_ReadingRequiredFieldsMoveOut') + ' ' + serialNumber);  
            }
            if (newReading && parseInt(previousReading) > parseInt(newReading) && !tripped) {   // AT-3421 core 8b
               errorMessage.push($A.get('$Label.c.CuAp_ValidateReadingMoveOut') + ' ' + serialNumber);              
            }
            // 20-03-2018 MT - AT- 2142 Changed the validation as it's not required anymore if the actual device reading digits are less than device digits
            if (newReading && deviceDigit < newReading.length) {
                errorMessage.push($A.get('$Label.c.CuAp_ValidateDigits') + ' ' + serialNumber); 
            }
	
            // add the move out readings
            var moveOutReading = {sobjectType: this.setPrefixedString('Reading__c'),
                            [this.setPrefixedString('ActualDeviceReading__c')]: newReading,
                            [this.setPrefixedString('Device__c')]: objReading[this.setPrefixedString('Device__c')],		//AT-3174
                            [this.setPrefixedString('ReadingDate__c')]: moveOutDate,
                            [this.setPrefixedString('ReadingMethod__c')]: objReading[this.setPrefixedString('ReadingMethod__c')],
                            [this.setPrefixedString('ReadingSource__c')]: objReading[this.setPrefixedString('ReadingSource__c')],
                            [this.setPrefixedString('ReadingType__c')]: objReading[this.setPrefixedString('ReadingType__c')],
                            [this.setPrefixedString('Tripped__c')]: objReading[this.setPrefixedString('Tripped__c')]	// AT-3421 core 8b
                           };
            moveOutReadings.push(moveOutReading);
            
            // JIRA# AT-730: Move Out Reading used for Move In
            if (objPreviousReading[this.setPrefixedString('ActualDeviceReading__c')] != '' 
            		&& objPreviousReading[this.setPrefixedString('ReadingType__c')] != $A.get('$Label.c.CuAp_ReadingReadingTypeVoidStart')) {
                var moveInReading = {sobjectType: this.setPrefixedString('Reading__c'),
                                     [this.setPrefixedString('ActualDeviceReading__c')]: newReading,
                                     [this.setPrefixedString('Device__c')]: objReading[this.setPrefixedString('Device__c')],		//AT-3174
                                     [this.setPrefixedString('ReadingDate__c')]: moveInDate,
                                     [this.setPrefixedString('ReadingMethod__c')]: objReading[this.setPrefixedString('ReadingMethod__c')],
                                     [this.setPrefixedString('ReadingSource__c')]: objReading[this.setPrefixedString('ReadingSource__c')],
                                     [this.setPrefixedString('ReadingType__c')]: $A.get('$Label.c.CuAp_ReadingReadingTypeVoidStart')// AT-2657 - Fix by Dependra Singh
                                    };
                moveOutReadings.push(moveInReading);
            }
        }
        
        if (errorMessage.length > 0) {
            this.showNotification(component, errorMessage);
            return false;
            
        } else {
            this.clearNotification(component);
        	if (moveOutReadings.length > 0) {
                wizObj.moveOutReadings = moveOutReadings;
                component.set('v.wizardprop', wizObj);
            }
        }
        console.log(component.get('v.wizardprop'));
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

        // retrieve list of fields and properties
        this.callServer(component, 'c.retrieveSupFieldPropDetails',
                        function(response) {
                            component.set('v.fieldList', response); 
                        },
                        null);
        component.set('v.isInitialised', true);
    },   

	// query for device readings
    loadReadings: function(component) {         
        var wizObj = component.get('v.wizardprop');
        var locationId = wizObj.location.Id;        
        var moveOutDate =  wizObj.moveOutDate;

        // if the location or the move out date have changed
        if (component.get('v.locationId') != locationId 
        		|| component.get('v.moveOutDate') != moveOutDate) {        

        	component.set('v.locationId', locationId);
        	component.set('v.moveOutDate', moveOutDate);

	        let params = {
	            'LocationId': locationId,
	            'moveOutDate': moveOutDate
	        };
	
	        this.callServer(component, 'c.retrieveReadingAndDevice',
	        				function(response) {
	        					component.set('v.recordList', response);
	                        },                           
	                        params);
	    }
    },

    // Estimate Button 
    handleRowButtonPressEvent: function(component, event) {
        if (event.getParam('ButtonId') == 'Estimate') {
	    	var sRowId = event.getParam('RowId');
	    	var readingEstimate = component.find('readingEstimate');
            var wizObj = component.get('v.wizardprop');  //AT-2129 
            var moveInDate = wizObj.moveInDate;          //AT-2129 
	        var errorMessage = [];
			
	        // estimate a move out reading
	        var recordList = component.get('v.recordList');
	        for (var i = 0; i < recordList.length; i++) {
	            if (recordList[i].uniqueId == sRowId) {
                    var newReading = recordList[i].objectMap[this.setPrefixedString('Reading__c1')]; //Sit005 Sanity testing issue
		            var deviceId = newReading[this.setPrefixedString('Device__c')];	// AT-3174
		            var readingDate = newReading[this.setPrefixedString('ReadingDate__c')]; 
					console.log('neha.1...........' + JSON.stringify(newReading));
                    console.log('neha.2...........' + JSON.stringify(component.get('v.fieldList')));
		            console.log(this.DEBUG + 'estimating move out reading ...');
		            var helper = this;
		            readingEstimate.getEstimate(deviceId, readingDate, 
									function(response) {
							            console.log(helper.DEBUG + 'move in reading estimate: ' + JSON.stringify(response));
							            if (response && response[helper.setPrefixedString('ActualDeviceReading__c')]) {
					                        newReading[helper.setPrefixedString('ActualDeviceReading__c')] = response[helper.setPrefixedString('ActualDeviceReading__c')];
					                        newReading[helper.setPrefixedString('BillableType__c')] = response[helper.setPrefixedString('BillableType__c')];
					                        newReading[helper.setPrefixedString('ReadingSource__c')] = response[helper.setPrefixedString('ReadingSource__c')];
					                        newReading[helper.setPrefixedString('ReadingMethod__c')] = response[helper.setPrefixedString('ReadingMethod__c')];
                                            newReading[helper.setPrefixedString('Tripped__c')] = response[helper.setPrefixedString('Tripped__c')];   // AT-3421 core 8b					                        
					                    } else {
					                        errorMessage.push($A.get('$Label.c.CuAp_ExceptionADU'));
					                        helper.showNotification(component, errorMessage, 'warn');
					                    }
					                    component.set('v.recordList', []);
					                    component.set('v.recordList', recordList);
					                 });
		            break;
	            }
	        }
	    }
    },

	// add days to input date
    addDays: function (date, days) {
        var result = new Date(date);
        result.setDate(result.getDate() + days);
        return result;
    },
    
    // format a date as yyyy-mm-dd
    formatDate: function(date) {
        var dd = date.getDate();
		var mm = date.getMonth() + 1;
        var yyyy = date.getFullYear();
        if (dd < 10) {
            dd = '0' + dd;
        } 
        if (mm < 10) {
            mm = '0' + mm;
        } 
        return yyyy + '-' + mm + '-' + dd;        
    }
})