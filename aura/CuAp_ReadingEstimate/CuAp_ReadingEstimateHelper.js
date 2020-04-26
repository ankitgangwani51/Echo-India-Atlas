({
	DEBUG: 'ReadingEstimate: ',

    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
    	component.find('notifier').showNotification(message, type);
    },

    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
    	component.find('notifier').clearNotification();
    },   
    // Estimate Button 
    estimateReading: function(component) {
		this.clearNotification(component);        
		var reading = component.get('v.reading');
        console.log(this.DEBUG + 'reading: ' + JSON.stringify(reading));
		var deviceId = reading[this.setPrefixedString('Device__c')]; 		// AT-3174
		var readingDate = reading[this.setPrefixedString('ReadingDate__c')]; 

        var errorMessage = [];
        if (!deviceId) {
        	errorMessage.push($A.get('$Label.c.LoAp_ExceptionDeviceReferenceRequiredField'));
        }
        if (!readingDate) {
        	errorMessage.push($A.get('$Label.c.LoAp_ExceptionReadingDateRequiredField'));
        }
        if (errorMessage.length === 0) {
            let params = {
                'deviceId': deviceId, 
                'readingDate': readingDate  
            };
            this.callServer(component, 'c.createEstimatedReading',function(response) {
                console.log(this.DEBUG + 'response: ' + JSON.stringify(response));
                if (response[this.setPrefixedString('ActualDeviceReading__c')]) { 
                    reading[this.setPrefixedString('ActualDeviceReading__c')] = response[this.setPrefixedString('ActualDeviceReading__c')];
                    if (!reading[this.setPrefixedString('BillableType__c')]) {
                        reading[this.setPrefixedString('BillableType__c')] = response[this.setPrefixedString('BillableType__c')];
                    }
                    if (!reading[this.setPrefixedString('ReadingSource__c')]) {
                        reading[this.setPrefixedString('ReadingSource__c')] = response[this.setPrefixedString('ReadingSource__c')];
                    }
                    reading[this.setPrefixedString('ReadingMethod__c')] = response[this.setPrefixedString('ReadingMethod__c')]; 
                    reading[this.setPrefixedString('Tripped__c')] = response[this.setPrefixedString('Tripped__c')];   // AT-3419 core 8b
                    component.set('v.reading', reading);
                    console.log(this.DEBUG + 'estimated reading: ' + JSON.stringify(reading));
                    
                } else {
                    this.showNotification(component, [$A.get('$Label.c.CuAp_ExceptionADU')]);
                }
            },
                            params);
        } else {
            this.showNotification(component, errorMessage, 'warn');
        }
    },

    // Estimate method
    getEstimate: function(component, event) {
    	var args = event.getParam('arguments');
    	var callback;

    	if (args) {
    		callback = args.callback;

            let params = {
                'deviceId': args.deviceId, 
                'readingDate': args.readingDate  
            };
            this.callServer(component, 'c.createEstimatedReading',
                            function(response) {
                                console.log(this.DEBUG + 'response: ' + JSON.stringify(response));
								if (callback) callback(response);
                            },
                            params);
        }
    }
})