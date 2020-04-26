({
    DEBUG: 'NewRecordWithAmendment: ',
    
    // screen initialisation
    doInit: function(component) {
        
        // check initial status
        this.checksOnEntry(component);
    },
    
    // reInitialise all pages on exit/close
    reInitialiseAllSteps: function(component) {
        
    },
    
    // check the current page on entry
    checksOnEntry: function(component) {
        
    }, 
    
    // validate new entered Reading
    validateReading: function(component) {
        var objectName = component.get('v.objectName');
        var newReading  = component.find('newReadingForm').validate();
        var lowerThresholdWarningAccept = component.get('v.lowerThresholdWarningAccept');
        
        if (lowerThresholdWarningAccept)    //AT-3854
        {
            component.set('v.lowerThresholdWarningAccept',false);   
            this.callApexSave(component, newReading);   
            return null;
        }
        
        if (newReading) {
            var rec;
            var lastactualDeviceReading;
            var lastactualDeviceReadingDate;  //AT-4285
            var selectedRecords = [];
            var relatedRecords = component.get('v.selectedRecords');

            if (relatedRecords) {
                for (var i = 0; i < relatedRecords.length; i++) {
                    rec = relatedRecords[i].objectMap[objectName];   
                }
            }
            
            component.set('v.lastReadingRecord','');
            var readingRecords;
            let readingParams = {
                'deviceId': component.get('v.recordId')
            };
            this.callServer(component, 'c.fetchDeviceReadings', function(response) { 
                if (response.length > 0) {
                    readingRecords = response;   
                    if (rec) {
                        console.log('inside rec');
                        for (var i = 0; i < readingRecords.length; i++) {
                            var currRec = readingRecords[i];  
                            var prevRec = readingRecords[i+1];                         
                            
                            if (rec[this.setPrefixedString('ReadingDate__c')] == currRec[this.setPrefixedString('ReadingDate__c')]){                        
                                lastactualDeviceReading = prevRec[this.setPrefixedString('ActualDeviceReading__c')];
                                lastactualDeviceReadingDate = prevRec[this.setPrefixedString('ReadingDate__c')];   //AT-4285
                                component.set('v.lastReadingRecord', prevRec);
                                break;
                            }
                        } 
                    } else {
                        var notLastReading = false;
                         for (var j = 0; j < readingRecords.length; j++) {                            
                             // Take the last reading of the entered reading
                             if(readingRecords[j][this.setPrefixedString('ReadingDate__c')] > newReading[this.setPrefixedString('ReadingDate__c')]){
                                 lastactualDeviceReading = readingRecords[j][this.setPrefixedString('ActualDeviceReading__c')];  
                                 lastactualDeviceReadingDate = readingRecords[j][this.setPrefixedString('ReadingDate__c')];     //AT-4285
                                 component.set('v.lastReadingRecord', readingRecords[j]);
                                 notLastReading = true;
                             }
                         }
                        if(!notLastReading) {
                            lastactualDeviceReading = readingRecords[0][this.setPrefixedString('ActualDeviceReading__c')];  
                            lastactualDeviceReadingDate = readingRecords[0][this.setPrefixedString('ReadingDate__c')];     //AT-4285
                            component.set('v.lastReadingRecord',  readingRecords[0]);
                        }
                    }    
                    var actualDeviceReading = newReading[this.setPrefixedString('ActualDeviceReading__c')]; 
                    var actualReadingDate = newReading[this.setPrefixedString('ReadingDate__c')];    //AT-4285
                    var tripped = newReading[this.setPrefixedString('Tripped__c')];  //AT-3415 core 8b
                    
                    // AT-2658 Starts here
                    var actualReadingMethod = newReading[this.setPrefixedString('ReadingMethod__c')]; 
                    
                    if(actualReadingMethod != null && actualReadingMethod == $A.get('$Label.c.CuAp_ReadingReadingMethodSystemEstimated')){                         
                     //   var actualReadingDate = newReading[this.setPrefixedString('ReadingDate__c')]; 
                        var olderThanActualReadingRecords = [];
                        for (var j = 0; j < readingRecords.length; j++) {                            
                            // Take all readings older than the current reading which is to be created
                            if(readingRecords[j][this.setPrefixedString('ReadingDate__c')] <= actualReadingDate){
                                olderThanActualReadingRecords.push(readingRecords[j]);
                            }
                        }
                        if(olderThanActualReadingRecords.length > 0){
                            lastactualDeviceReading = olderThanActualReadingRecords[0][this.setPrefixedString('ActualDeviceReading__c')];    
                            lastactualDeviceReadingDate = olderThanActualReadingRecords[0][this.setPrefixedString('ReadingDate__c')];        //AT-4285
                        }
                    }
                    // AT-2658 Ends here
                    if(!tripped) {
                        if(lastactualDeviceReadingDate > actualReadingDate) {
                            if(parseInt(lastactualDeviceReading) < parseInt(actualDeviceReading)) {
                                if (!rec)  {
                                    // A lesser actual reading is already present which is dated after this actual reading
                                    this.showNotification(component, [$A.get('$Label.c.LoAp_ReadingLTActualReadingDate')]); 
                                    return null;
                                }
                            }
                            if (rec) {
                                //Reading date cannot be less than last good reading date
                                this.showNotification(component, [$A.get('$Label.c.LoAp_ReadingLTLastGoodReadingDate')]); 
                                return null;
                            }
                        }
                        else {
                            if(parseInt(lastactualDeviceReading) > parseInt(actualDeviceReading)) {
                                if (rec) {
                                    //Reading entered can’t be less than Selected Last Good Reading
                                    this.showNotification(component, [$A.get('$Label.c.LoAp_ReadingLTLastGoodReading')]); 
                                    return null;
                                } else {
                                    //Reading entered can’t be less than the last Actual Reading of the Device.
                                    this.showNotification(component, [$A.get('$Label.c.LoAp_ReadingLTActualReading')]);
                                    return null;
                                }
                            }
                        }
                    }
                }
                this.thresholdValidation(component,newReading,objectName);
            },
	        readingParams);
        }
    },
    
    
    thresholdValidation: function(component, newReading, objectName) {
        //AT-3412 Consumption Threshold Validation 
        var ErrorValue;
        var HighReading = newReading[this.setPrefixedString('HighReading__c')];  //AT-3854
          
        let thresholdCheckParams = {
            'objectName': objectName,
            'deviceId': component.get('v.recordId'),
            'newReading' : JSON.stringify(newReading),
            'lastReadingRecord' : JSON.stringify(component.get('v.lastReadingRecord'))
        };

        this.callServer(component, 'c.validateConsumptionThreshold', function(response) { 
            if (response.length > 0) {
                ErrorValue = response; 
                //If Supply Point Device cannot be found that is Active as of the Reading Date.
                if (ErrorValue == [$A.get('$Label.c.GlAp_SPDInActive')]) {
                    this.showNotification(component, [$A.get('$Label.c.LoAp_SupplyPointDeviceNotFound')]); 
                    return null;
                }
                //If an ADU cannot be found that is Active as of the Reading Date.
                if (ErrorValue == [$A.get('$Label.c.GlAp_ADUInactive')]) {
                    this.showNotification(component, [$A.get('$Label.c.LoAp_ADUNotFound')]); 
                    return null;
                }
                // it will pass only when Threshold where Daily Usage Threshold Start <= ADU and Daily Usage Threshold End >= ADU 
                if (ErrorValue == [$A.get('$Label.c.GlAp_ReadTimetableThresholdInvalid')]) {
                    this.showNotification(component, [$A.get('$Label.c.LoAp_ReadTimetableThresholdInvalid')]); 
                    return null;
                }
                //Error “Reading has been rejected because it falls outside expected consumption thresholds” 
                if (ErrorValue ==  [$A.get('$Label.c.GlAp_LowerThresholdReadingRejected')]) {  //AT-3854
                    component.set('v.lowerThresholdWarningPopup',true);   
                }
                if (ErrorValue == [$A.get('$Label.c.GlAp_UpperThresholdReadingRejected')]) {  //AT-3854
                    if(!HighReading) {
                         component.set('v.upperThresholdWarningPopup',true);
                    } else 
                        this.callApexSave(component, newReading);   
                }
                if(ErrorValue == [$A.get('$Label.c.GlAp_NoError')]) {
                    this.callApexSave(component, newReading);  
                }
            }
            else {
                this.callApexSave(component, newReading); 
            }
            
        },thresholdCheckParams);
        //AT-3412 Ends
        
    },
    
    // validate the new record component
    // returns a new record if it validates
    validateOnNext: function(component) {
        if (component.get('v.objectName') == this.setPrefixedString('Reading__c')) {
            return this.validateReading(component);
            
        } else {
            return component.find('newComponent').validate();
        }   
    },
    doCancelQuestion: function(component, event, helper) {
        this.doClosePopUp(component);
    }, 
    doNo: function(component, event, helper) {
        this.doClosePopUp(component);
        var newReading  = component.find('newReadingForm').validate();
        this.callApexSave(component, newReading);
    },
    doYes: function(component, event, helper) {
        this.doClosePopUp(component);
        var newReading  = component.find('newReadingForm').validate();
        newReading[this.setPrefixedString('HighReading__c')] = true;
        this.callApexSave(component, newReading);

    },
    doClosePopUp: function(component) {
        component.set('v.lowerThresholdWarningPopup',false);   
        component.set('v.lowerThresholdWarningAccept', false);
        component.set('v.upperThresholdWarningPopup',false);
    },
    doAcceptQuestion: function(component) {
        component.set('v.lowerThresholdWarningAccept', true);
        this.validateReading(component);
        component.set('v.lowerThresholdWarningPopup',false);   
        
    },
    // navigation with validation/server calls 
    navigateStep: function(component, event) {
        
        console.log(this.DEBUG + 'Wizard navigation handler');
        var message = event.getParam('message');
        if (message === 'CANCEL') {
        	event.stopPropagation();		// prevent further event propagation
	    	this.clearNotification(component);
            this.doCancel(component);
            
        } else if (message === 'NEXT') {
        	event.stopPropagation();		// prevent further event propagation
	    	this.clearNotification(component);
            var newRecord = this.validateOnNext(component);
            if (newRecord) {
                this.callApexSave(component, newRecord);
            }
            
        } else if (message === 'BACK') {
        	event.stopPropagation();		// prevent further event propagation
	    	this.clearNotification(component);
            // not valid
        }
    },
    
    // activate the Wizard
    doStart: function(component) {
        console.log(this.DEBUG + 'wizard active ...');
        component.set('v.isActive', true);
    },
    
    // cancel the Wizard
    doCancel: function(component) {
        this.doInit(component);
        component.set('v.isActive', false);
    },
    
    // fire event to signal to the parent component that a new record was added 
    newRecordAdded: function(component) {
        var cmpEvent = component.getEvent('wizEvent');
        cmpEvent.setParams({'message': 'SAVED'});
        cmpEvent.fire();
    },
    
    // close the modal and signal that a new record was added
    handleBillCalculationComplete: function(component, event, helper) {
        this.doCancel(component);
        this.newRecordAdded(component);
    },
    
    // call the server to save the new record and update the records it amends
    callApexSave: function(component, newRecord) {    	
        
        // populate the parent field on the new record
        newRecord[component.get('v.parentField')] = component.get('v.recordId');
        console.log(this.DEBUG + 'newRecord: ' + JSON.stringify(newRecord));
        
        // get the records to amend
        var selectedRecords = [];
        var relatedRecords = component.get('v.selectedRecords');
        var objectName = component.get('v.objectName');
        
        for (var i = 0; i < relatedRecords.length; i++) {
            selectedRecords.push(relatedRecords[i].objectMap[objectName]);
        }
        console.log(this.DEBUG + 'selectedRecords: ' + JSON.stringify(selectedRecords));
        
        try {
            
            // save the record and update the amended records
            console.log(this.DEBUG + 'call server to save the new record');
            //Changes Start Here - (AT-2929)
            //Commented as we need to handel the error due to trigger so we need to use action.setCallback to handel the error rather than using this.callServer
          /*  let params = {
                'objectName': objectName,
                'newRecordObject': JSON.stringify(newRecord),
                'selectedRecords': JSON.stringify(selectedRecords), 
                'amendedByFieldName': component.get('v.selfLookupField')
            };*/
            var action = component.get("c.saveRecords") ;
           //Changes for AT-5193 Starts Here
            action.setParams({
                'objectName': objectName,
                'newRecordObject': JSON.stringify(newRecord),
                'selectedRecords': JSON.stringify(selectedRecords), 
                'amendedByFieldName': component.get('v.selfLookupField'),
                'selectedRecord' : JSON.stringify(component.get('v.selectedRecord'))
            }) ;
           //Changes for AT-5193 Ends Here
            component.find('spinner').show();
            // calling the server to save the payment
            action.setCallback(this, function(response) {
                console.log(' setCallback response:: ' + JSON.stringify(response)) ;
                component.find('spinner').hide();
                this.handleCallbackResponse(component, response, selectedRecords) ;
            }) ;
            $A.enqueueAction(action) ;
            //(AT-2929) comment below code, as we need to handel the error occur due to trigger, so we need to use action.setCallback to handel the error and show it on component rather than using this.callServer
          /*  this.callServer(component, 'c.saveRecords',
                            function(response) {
                                var newRecordId = response;
                                console.log(this.DEBUG + 'newRecordId: ' + newRecordId);
                                
                                if (newRecordId) {
                                    component.set('v.newRecordId', newRecordId);
                                    
                                    // if there were records to amend, calculate the pending bill(s) and wait for response
                                    if (selectedRecords.length > 0 && newRecordId) {
                                        console.log(this.DEBUG + 'Calculating pending bills ...')
                                        var calculateBillCmp = component.find('calculatePendingBillComponent');
                                        calculateBillCmp.calculateBills(function(response) {
                                            var billIds = response;
                                            console.log(this.DEBUG + 'bill Ids: ' + billIds)
                                        });
                                        
                                        // else just close the modal
                                    } else {
                                        this.doCancel(component);
                                        this.newRecordAdded(component);
                                    }
                                }
                            },
                            params); */     		
          //Changes Ends here -(AT-2929)  
        } catch (error) {
            this.showNotification(error.message);
            console.log(this.DEBUG + 'error when saving: ' + error.message);
        }
    },
    //handel Call Back Response (AT-2929)
    handleCallbackResponse : function(component, response, selectedRecords) {
        
        if(response.getState() === 'SUCCESS') {
            var newRecordId = response.getReturnValue();
            console.log(this.DEBUG + 'newRecordId: ' + newRecordId);
            
            if (newRecordId) {
                component.set('v.newRecordId', newRecordId);
                console.log(this.DEBUG + 'selectedRecords length = ' + selectedRecords.length);
                // if there were records to amend, calculate the pending bill(s) and wait for response
                if (selectedRecords.length > 0 && newRecordId) {
                    console.log(this.DEBUG + 'Calculating pending bills ...')
                    var calculateBillCmp = component.find('calculatePendingBillComponent');
                    calculateBillCmp.calculateBills(function(response) {
                        var billIds = response;
                        console.log(this.DEBUG + 'bill Ids: ' + billIds)
                    });
                    
                    // else just close the modal
                } else {
                    this.doCancel(component);
                    this.newRecordAdded(component);
                }
            }
        } else {
            this.handleError(component, response) ;
        }
    } ,
    //handel Error (AT-2929)
    handleError : function(component, response) {
        console.log(this.DEBUG + 'Exception caught.');
        var errorMessage = [] ;
        errorMessage.push(response.getError()[0].message) ;
        this.showNotification(component, errorMessage, 'error') ;
        
    } ,
    
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
    
    // call the notification component method to show a notification
    showNotification: function(component, message, type) {
        component.find('notification').showNotification(message, type);
    },
    
    // call the notification component method to clear a notification
    clearNotification: function(component) {
        this.showNotification(component, null);
    },
    
    // handles any errors
    handleError: function(component, response) {
        console.log(this.DEBUG + 'Exception caught successfully');
        var errorMessages = [];
        errorMessages.push(response.getError()[0].message);
        this.showError(component, errorMessages);
    },
    
    // shows the error message
    showError: function(component, errorMessages) {
        console.log(this.DEBUG + 'Displaying error: ', errorMessages);
        this.showNotification(component, errorMessages);
    },
    
})