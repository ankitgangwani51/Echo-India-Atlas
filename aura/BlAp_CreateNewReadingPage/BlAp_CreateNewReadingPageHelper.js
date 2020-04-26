({
	DEBUG: 'CreateNewReading: ',

    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {
        component.set('v.isInitialised', false);
        component.set('v.supplyPoint', {'sobjectType':this.setPrefixedString('SupplyPoint__c')});
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component) {
        var wizObj = component.get('v.wizardprop');
        var reading = component.get('v.reading');
        if (!reading) reading = {'sobjectType': this.setPrefixedString('Reading__c')};
        
        //component.set('v.location', {'sobjectType': this.setPrefixedString('Location__c')}); AT-3174

        /*if (wizObj.locationId) {
            let params = {'locationId': wizObj.locationId
                      };
            this.callServer(component, 'c.getLocation',
                            function(response) { 
                                component.set('v.location', response); 
                            },                         
                            params);
        }*/ // AT-3174
        var deviceId;
        var today = new Date();
        var dateToday = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);
        
        //AT-3737 -start
        var instDate = new Date(component.get('v.wizardprop.removalDate'));
        console.log('101******instDate ' + instDate);
        instDate.setDate(instDate.getDate() + 1);
        var dateInstall = instDate.getFullYear() + '-' + ('0' + (instDate.getMonth() + 1)).slice(-2) + '-' + ('0' + instDate.getDate()).slice(-2);        
        //AT-3737 -end
        
        //AT-3461 Start.       
        if(wizObj.wizardType == $A.get('$Label.c.LoAp_ExchangeDevice') && 
           component.get('v.readingType') == $A.get('$Label.c.BlAp_ReadingScreenInstall')){
            var finalReadingDate = new Date(component.get('v.wizardprop.finalReading')[this.setPrefixedString('ReadingDate__c')]);
            finalReadingDate.setDate(finalReadingDate.getDate() + 1);
            dateInstall = finalReadingDate.getFullYear() + '-' + ('0' + (finalReadingDate.getMonth() + 1)).slice(-2) + '-' + ('0' + finalReadingDate.getDate()).slice(-2); 
        }
        if(dateInstall == NaN || dateInstall == 'NaN-aN-aN'){
            dateInstall = dateToday;
        }
        //AT-3461 End.
        
    	console.log(this.DEBUG + 'readingType: ' + component.get('v.readingType'));
        if (component.get('v.readingType') == $A.get('$Label.c.BlAp_ReadingScreenInstall')) {
			reading[this.setPrefixedString('ReadingType__c')] = $A.get('$Label.c.CuAp_ReadingReadingTypeExchangeInitial');
	        reading[this.setPrefixedString('ReadingDate__c')] = dateInstall;//AT-3737
	        reading[this.setPrefixedString('BillableType__c')] = $A.get('$Label.c.CuAp_ReadingBillableTypeBillable');
			reading[this.setPrefixedString('ReadingSource__c')] = $A.get('$Label.c.CuAp_ReadingReadingSourceCompanyReading');
			reading[this.setPrefixedString('ReadingMethod__c')] = $A.get('$Label.c.CuAp_ReadingReadingMethodActual');
            deviceId = wizObj.spDeviceToBeAdded[this.setPrefixedString('Device__c')];
            if (wizObj.initialReading) {
            	reading[this.setPrefixedString('ActualDeviceReading__c')] = wizObj.initialReading[this.setPrefixedString('ActualDeviceReading__c')];
            }
            

        } else if (component.get('v.readingType') == $A.get('$Label.c.BlAp_ReadingScreenFinal')) {
			reading[this.setPrefixedString('ReadingType__c')] = $A.get('$Label.c.CuAp_ReadingReadingTypeExchangeFinal');
	        reading[this.setPrefixedString('ReadingDate__c')] = dateToday;
	        reading[this.setPrefixedString('BillableType__c')] = $A.get('$Label.c.CuAp_ReadingBillableTypeBillable');
			reading[this.setPrefixedString('ReadingSource__c')] = $A.get('$Label.c.CuAp_ReadingReadingSourceCompanyReading');
			reading[this.setPrefixedString('ReadingMethod__c')] = $A.get('$Label.c.CuAp_ReadingReadingMethodActual');
            deviceId = wizObj.supplyPointDevice[this.setPrefixedString('Device__c')];
            console.log(this.DEBUG + 'wizObj.finalReading: ' + JSON.stringify(wizObj.finalReading));
            if (wizObj.finalReading) {
            	reading[this.setPrefixedString('ActualDeviceReading__c')] = wizObj.finalReading[this.setPrefixedString('ActualDeviceReading__c')];
            }

        } else {
            deviceId = component.get('v.recordId');
        }
        console.log('401**Neha ******reading ' + reading);
        console.log('402**Neha ******reading ' + JSON.stringify(reading));
        reading[this.setPrefixedString('Device__c')] = deviceId; //AT-3174
        component.set('v.deviceId', deviceId);
        component.set('v.reading', reading);
        component.set('v.DisplayNewReadingForm',true); //AT-3461
    	console.log(this.DEBUG + 'reading: ' + JSON.stringify(reading));

        if (deviceId) {
        	let params = {'deviceId': deviceId
                      };
        	this.callServer(component, 'c.fetchDeviceData',
                            function(response) {  
                                component.set('v.lastReading', response.actualReading); 
                                component.set('v.deviceDigits', response.deviceDigits); 
                                component.set('v.device', response.existingDevice);
                                console.log(this.DEBUG + 'lastReading: ' + response.actualReading);
                                console.log(this.DEBUG + 'deviceDigits: ' + response.deviceDigits);
                                console.log(this.DEBUG + 'device: ' + JSON.stringify(component.get('v.device')));
                            },                         
                            params);
        }
      
        if (!component.get('v.isInitialised')) {
            this.initialiseFields(component);
            component.set('v.isInitialised', true);
        }
        if (component.get('v.readingType') == $A.get('$Label.c.BlAp_ReadingScreenInstall')) {
            var supplyPoint = component.get('v.supplyPoint');
            var wizObj = component.get('v.wizardprop');
          /*  if (wizObj.wizardType == $A.get('$Label.c.LoAp_ExchangeDevice')) {   //AT-4185
                if (wizObj.selectedSupplyPointRemoved[this.setPrefixedString('ReadFrequency__c')]) {
                    supplyPoint[this.setPrefixedString('ReadFrequency__c')] = wizObj.selectedSupplyPointRemoved[this.setPrefixedString('ReadFrequency__c')];
                }
            }*/
        }
        console.log('404**Neha ******v.reading ' + component.get('v.reading'));
    },
    
    // validate the data gathered by the component 
    validateOnNext: function(component, event, helper) {
    	
    	if (this.validate(component)) {
    		return this.populateWizardProp(component);
    	}
        return false;
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

    // initialise fields from server
    initialiseFields: function(component) { 
        component.set('v.supplyPoint', {'sobjectType': this.setPrefixedString('SupplyPoint__c')});
   
        if (component.get('v.readingType') == $A.get('$Label.c.BlAp_ReadingScreenFinal')) {
	        this.callServer(component,'c.retrieveDeviceFields', 
	                        function(response) {
	                            component.set('v.deviceFields', response);
	                        },
	                        null);
	    }
     /*   this.callServer(component,'c.retrieveSupplyPointFields', 
                        function(response) {
                            component.set('v.supplyPointFields', response);
                        },
                        null);   */  //AT-4185   
    },
    
    // validates the data entered
    validate: function(component) {

    	// validate the new reading form
        var reading = component.find('newReadingForm').validate();
    	console.log(this.DEBUG + 'reading: ' + JSON.stringify(reading));
        
        if (reading) {
        	component.set('v.reading', reading);
	        var ErrorMessageVal = [];  
	        var readingDate = reading[this.setPrefixedString('ReadingDate__c')];   
	        var supplyPoint = component.get('v.supplyPoint');
	        var today = new Date();
	        var dateToday = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);
	     
	        var deviceId;
	        console.log(this.DEBUG + 'device: ' + JSON.stringify(component.get('v.device')));
	        if (component.get('v.device') != null) {
	            var device = component.get('v.device');
	            deviceId = device.Id;
	        }
	        console.log(this.DEBUG + 'deviceId: ' + deviceId);
	        
	        // device Id must be populated
	        if (!deviceId) {
	            ErrorMessageVal.push($A.get('$Label.c.LoAp_DeviceReferenceVal'));                
	        }

	        // Final Read Validations        
	        if (component.get('v.readingType') == $A.get('$Label.c.BlAp_ReadingScreenFinal')) {
	            if (readingDate > dateToday) {                 
	                ErrorMessageVal.push($A.get('$Label.c.LoAp_DeviceExchngRemDateGTToday'));                            
	            }      
	        }
	        
	        // Initial Read Validations
	        if (component.get('v.readingType') == $A.get('$Label.c.BlAp_ReadingScreenInstall')) { 
	            
	            // reading date must be earlier than today
	            if (!readingDate || readingDate > dateToday) {                 
	                ErrorMessageVal.push($A.get('$Label.c.LoAp_DeviceExchngInstDateGTToday'));                            
	            }
	            
	            // supply point read frequency must be selected
	        /*    var readFrequency = supplyPoint[this.setPrefixedString('ReadFrequency__c')];    AT-4185
		        if (!readFrequency) {
		            ErrorMessageVal.push($A.get('$Label.c.BlAp_ReadingFrequency'));
		        } */
		        
		        // installation date can’t be before the removal date from the previous supply point for the device.
	            var removalDate = component.get('v.wizardprop.removalDate');
	            if (removalDate) {
                   console.log('*****removalDate'+removalDate+'*****readingDate'+readingDate);
	               if (removalDate > readingDate) {                
	                    ErrorMessageVal.push($A.get('$Label.c.LoAp_DeviceExchngInstalDateLTRemDatePrevSP'));                
	                }
	            }           
	        }
	        
	        // reading source field must be populated
	        var readingSource = reading[this.setPrefixedString('ReadingSource__c')];
	        if (!readingSource) {               
	            ErrorMessageVal.push($A.get('$Label.c.LoAp_DeviceExchngReadSource'));                        
	        }
	        
	        // reading method field must be populated
	        var readingMethod = reading[this.setPrefixedString('ReadingMethod__c')];        
	        if (!readingMethod) {                
	            ErrorMessageVal.push($A.get('$Label.c.LoAp_DeviceExchngReadMethos'));                        
	        }
	        
	        // billable type field must be populated
	        var billableType = reading[this.setPrefixedString('BillableType__c')];
	        if (!billableType) {                
	            ErrorMessageVal.push($A.get('$Label.c.LoAp_DeviceExchngBillType'));                        
	        }
	        
	        // reading type field must be populated
	        var readingType = reading[this.setPrefixedString('ReadingType__c')];
	        if (!readingType) {                
	            ErrorMessageVal.push($A.get('$Label.c.LoAp_DeviceExchngReadType'));                        
	        }
	        
	        // reading date field must be populated
	        if (!readingDate) {
	            ErrorMessageVal.push($A.get('$Label.c.BlAp_ReadingDate')); 
	        }
	
	        // actual reading must be populated
	        var actualDeviceReading = reading[this.setPrefixedString('ActualDeviceReading__c')];        
	        if (!actualDeviceReading) {
	            ErrorMessageVal.push($A.get('$Label.c.LoAp_ActualReading'));
	
	        // reading validation
	        } else  {
                var lastReading = component.get('v.lastReading');
	            var deviceDigit = component.get('v.deviceDigits');
	            var deviceReading = parseInt(actualDeviceReading); 
                
	
	            // check formatting
	            if (!Number.isInteger(deviceReading) || actualDeviceReading.includes('-') || actualDeviceReading.includes('.')) {
	                ErrorMessageVal.push($A.get('$Label.c.LoAp_ActualReadingValidation'));                                        
	
	            // cannot be less than last reading
	            } else if (lastReading) {
                    debugger;
                    var tripped = reading[this.setPrefixedString('Tripped__c')];  //AT-3890
	                if (parseInt(lastReading) > deviceReading && !tripped) {          //AT-3890                   
	                    ErrorMessageVal.push($A.get('$Label.c.LoAp_ReadingLTActualReading'));                            
	                }
	            }
	            
	            // 20-03-2018 MT - AT- 2142 Changed the validation as it's not required anymore if the actual device reading digits are less than device digits
	            if (actualDeviceReading.length > deviceDigit) {
	                ErrorMessageVal.push($A.get('$Label.c.LoAp_ActualReadDigits') + '-' + deviceDigit);
	            }
	        }
	        
	        // display errors and exit
	        if (ErrorMessageVal.length > 0) { 
	        	this.showNotification(component, ErrorMessageVal);
	            return false;
	        }
	        return true;
	    }
	    return false;
    },
    
	// populate wizard properties
    populateWizardProp: function(component) {
        var wizObj = component.get('v.wizardprop');
        var reading = component.get('v.reading');   
        var amendReadings = component.get('v.amendReadings');   
        var readingDate = reading[this.setPrefixedString('ReadingDate__c')];   
        var supplyPoint = component.get('v.supplyPoint');
    //    var readFrequency = supplyPoint[this.setPrefixedString('ReadFrequency__c')];  AT-4185

        // Add Device wizardprop
        if (wizObj.wizardType == $A.get('$Label.c.LoAp_NewDevice')) {
            wizObj.initialReading = reading;
            wizObj.spDeviceToBeAdded[this.setPrefixedString('InstallationDate__c')] = readingDate;
       //     wizObj.selectedSupplyPointAdded[this.setPrefixedString('ReadFrequency__c')] = readFrequency;   //AT-4185

        // Remove Device wizardprop
        } else if (wizObj.wizardType == $A.get('$Label.c.LoAp_RemoveDevice')) {
            wizObj.finalReading = reading;
            wizObj.supplyPointDevice[this.setPrefixedString('RemovalDate__c')] = readingDate;

        // Device Exchange wizardprop
        } else if (wizObj.wizardType == $A.get('$Label.c.LoAp_ExchangeDevice')) { 
        	if (component.get('v.readingType') == $A.get('$Label.c.BlAp_ReadingScreenFinal')) {

                wizObj.finalReading = reading;
                wizObj.supplyPointDevice[this.setPrefixedString('RemovalDate__c')] = readingDate;
                return true;
                
        	} else if (component.get('v.readingType') == $A.get('$Label.c.BlAp_ReadingScreenInstall')) {

                wizObj.initialReading = reading;
                wizObj.spDeviceToBeAdded[this.setPrefixedString('InstallationDate__c')] = readingDate;
           //     wizObj.selectedSupplyPointRemoved[this.setPrefixedString('ReadFrequency__c')] = readFrequency;   //AT-4185

                // check final reading date is before new installation date
                var finalReadDate = component.get('v.wizardprop.finalReading')[this.setPrefixedString('ReadingDate__c')]
                if (finalReadDate > readingDate) {                
                    this.showNotification(component, [$A.get('$Label.c.LoAp_DeviceExchngInstalDateLTRemDate')]);                
                    return false;
                }
            }
        }

		// get the records to amend
    	var amendReadings = [];
    	var relatedRecords = component.get('v.amendReadings');
    	var objectName = this.setPrefixedString('Reading__c');

    	for (var i = 0; i < relatedRecords.length; i++) {
    		amendReadings.push(relatedRecords[i].objectMap[objectName]);
    	}
        wizObj.amendReadings = amendReadings;
        component.set('v.wizardprop', wizObj);
    	console.log(this.DEBUG + 'wizObj: ' + JSON.stringify(wizObj));
        return true;
	},    
})