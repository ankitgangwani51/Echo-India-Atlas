({
    DEBUG: 'MoveInReadings: ',
    
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {
        component.set('v.isInitialised', false);
        component.set('v.selectedBundleIds', []);
        component.set('v.moveInDate', null);
        component.set('v.fieldList', []);
        component.set('v.recordList', []);
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component) {
        // do checks here if required
        console.log(this.DEBUG + 'checksOnEntry');
        debugger;
        var wizObj = component.get('v.wizardprop');
        if (wizObj.availableBundles && wizObj.availableBundles.length > 0 && wizObj.moveInDate) {
            if (!component.get('v.isInitialised')) {
                this.initialiseDisplayedFields(component);
            }
            this.loadReadings(component);
        }
    },
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {
        var wizObj = component.get('v.wizardprop');
        var moveInDate = wizObj.moveInDate;
        console.log('testing in move in reading page helper check move out date set in wizard sucessfully- '+wizObj.moveOutDate);
        
        // AT-2211, we will use movein date - 1 only when agent doesn't provide move out date otherwise we will use moveout date enetered by an agent. 
        var moveOutDate = wizObj.moveOutDate /*this.formatDate(this.addDays(moveInDate, -1));*/ 
        
        var recordList = component.get('v.recordList');
        console.log(this.DEBUG + 'recordList:' + JSON.stringify(recordList));
        var moveInReadingCheckMap = new Map(); 
        
        var moveInReadings = [] ;
        var errorMessage = [];
        
        // Validations for Data Quality
        debugger;
        for (var i = 0; i < recordList.length; i++) {  
            var objReading = recordList[i].objectMap[this.setPrefixedString('Reading__c1')];  //Sit005 Sanity testing issue
            var objLocationOccupant = recordList[i].objectMap[this.setPrefixedString('LocationOccupant__c')];// Added By dependra - AT-2657
            var objPreviousReading = recordList[i].objectMap[this.setPrefixedString('Reading__c')];
            var newReading = recordList[i].objectMap[this.setPrefixedString('Reading__c1')][this.setPrefixedString('ActualDeviceReading__c')]; //Sit005 sanity testing issue
            var tripped = recordList[i].objectMap[this.setPrefixedString('Reading__c1')][this.setPrefixedString('Tripped__c')];  //AT-3420 core 8b  //Sit005 sanity testing issue
            var oldReadingDate = objPreviousReading[this.setPrefixedString('ReadingDate__c')];
            var newReadingDate = moveInDate;
            var previousReading = recordList[i].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('ActualDeviceReading__c')];
            var deviceDigit = recordList[i].objectMap[this.setPrefixedString('Device__c')][this.setPrefixedString('Digit__c')];
            var readingMethod = recordList[i].objectMap[this.setPrefixedString('Reading__c1')][this.setPrefixedString('ReadingMethod__c')];  //Sit005 sanity testing issue
            var serialNumber = recordList[i].objectMap[this.setPrefixedString('Device__c')][this.setPrefixedString('SerialNo__c')];   
            
            // Assign the supply point id and entered move in reading to map - moveInReadingCheckMap
            moveInReadingCheckMap.set(recordList[i].objectMap[this.setPrefixedString('SupplyPointDevice__c')][this.setPrefixedString('SupplyPoint__c')],newReading);
            
            console.log('newReading:: ' + newReading) ; // Sudhir
            console.log('deviceDigit:: ' + deviceDigit) ;
            console.log('objectMap: ' + JSON.stringify(recordList[i].objectMap)) ;
            if (!newReading || !readingMethod) {              
                errorMessage.push($A.get('$Label.c.CuAp_ReadingMoveInReadingError') + ' ' 
                                  + $A.get('$Label.c.CuAp_ReadingRequiredFields') + ' ' + serialNumber);  
            }
            //AT-3420 core 8b
            if (newReading && parseInt(previousReading) > parseInt(newReading) && !tripped  
                && (newReadingDate > oldReadingDate)) {
                errorMessage.push($A.get('$Label.c.CuAp_ReadingMoveInReadingError') + ' ' 
                                  + $A.get('$Label.c.CuAp_ValidateReading') + ' ' + serialNumber); 
            }
            // 20-03-2018 MT - AT- 2142 Changed the validation as it's not required anymore if the actual device reading digits are less than device digits
            if (newReading  && deviceDigit < newReading.length) {
                errorMessage.push($A.get('$Label.c.CuAp_ReadingMoveInReadingError') + ' ' 
                                  + $A.get('$Label.c.CuAp_ValidateDigits') + ' ' + serialNumber + ' ' 
                                  + $A.get('$Label.c.CuAp_ReadingDigitError') + ' ' + deviceDigit); 
            }
            else {
                var singleObj = {sobjectType: this.setPrefixedString('Reading__c'),
                                 [this.setPrefixedString('ActualDeviceReading__c')]: newReading,
                                 [this.setPrefixedString('Device__c')]: objReading[this.setPrefixedString('Device__c')],		// AT-3174
                                 [this.setPrefixedString('ReadingDate__c')]: moveInDate,
                                 [this.setPrefixedString('ReadingMethod__c')]: objReading[this.setPrefixedString('ReadingMethod__c')],
                                 [this.setPrefixedString('ReadingSource__c')]: objReading[this.setPrefixedString('ReadingSource__c')],
                                 [this.setPrefixedString('ReadingType__c')]: objReading[this.setPrefixedString('ReadingType__c')],
                                 [this.setPrefixedString('Tripped__c')]: objReading[this.setPrefixedString('Tripped__c')]   // AT-3420 core8b
                                };
                moveInReadings.push(singleObj);
                debugger;
                // JIRA# AT-730: Move In Reading used for Move Out
                
                // Added By dependra - AT-2657
                debugger;
                if(objLocationOccupant.Id){
                    if(!objLocationOccupant.EndDate__c){
                        if (objPreviousReading[this.setPrefixedString('ActualDeviceReading__c')] != '' 
                            && objPreviousReading[this.setPrefixedString('ReadingType__c')] != $A.get('$Label.c.CuAp_ReadingReadingTypeMoveOut')) {
                            var moveOutReading = {sobjectType: this.setPrefixedString('Reading__c'),
                                                  [this.setPrefixedString('ActualDeviceReading__c')]: newReading,
                                                  [this.setPrefixedString('Device__c')]: objReading[this.setPrefixedString('Device__c')],	//AT-3174
                                                  [this.setPrefixedString('ReadingDate__c')]: moveOutDate,
                                                  [this.setPrefixedString('ReadingMethod__c')]: objReading[this.setPrefixedString('ReadingMethod__c')],
                                                  [this.setPrefixedString('ReadingSource__c')]: objReading[this.setPrefixedString('ReadingSource__c')],
                                                  [this.setPrefixedString('ReadingType__c')]: $A.get('$Label.c.CuAp_ReadingReadingTypeMoveOut')
                                                 };
                            moveInReadings.push(moveOutReading);
                        }
                    }else{
                        if (objPreviousReading[this.setPrefixedString('ActualDeviceReading__c')] != '' 
                            && objPreviousReading[this.setPrefixedString('ReadingType__c')] != $A.get('$Label.c.CuAp_ReadingReadingTypeVoidEnd')) {
                            var moveOutReading = {sobjectType: this.setPrefixedString('Reading__c'),
                                                  [this.setPrefixedString('ActualDeviceReading__c')]: newReading,
                                                  [this.setPrefixedString('Device__c')]: objReading[this.setPrefixedString('Device__c')],		//AT-3174
                                                  [this.setPrefixedString('ReadingDate__c')]: moveOutDate,
                                                  [this.setPrefixedString('ReadingMethod__c')]: objReading[this.setPrefixedString('ReadingMethod__c')],
                                                  [this.setPrefixedString('ReadingSource__c')]: objReading[this.setPrefixedString('ReadingSource__c')],
                                                  [this.setPrefixedString('ReadingType__c')]: $A.get('$Label.c.CuAp_ReadingReadingTypeVoidEnd')
                                                 };
                            moveInReadings.push(moveOutReading);
                        }
                    }
                }else{
                    if (objPreviousReading[this.setPrefixedString('ActualDeviceReading__c')] != '' 
                        && objPreviousReading[this.setPrefixedString('ReadingType__c')] != $A.get('$Label.c.CuAp_ReadingReadingTypeVoidEnd')) {
                        var moveOutReading = {sobjectType: this.setPrefixedString('Reading__c'),
                                              [this.setPrefixedString('ActualDeviceReading__c')]: newReading,
                                              [this.setPrefixedString('Device__c')]: objReading[this.setPrefixedString('Device__c')], 	//AT-3174
                                              [this.setPrefixedString('ReadingDate__c')]: moveOutDate,
                                              [this.setPrefixedString('ReadingMethod__c')]: objReading[this.setPrefixedString('ReadingMethod__c')],
                                              [this.setPrefixedString('ReadingSource__c')]: objReading[this.setPrefixedString('ReadingSource__c')],
                                              [this.setPrefixedString('ReadingType__c')]: $A.get('$Label.c.CuAp_ReadingReadingTypeVoidEnd')
                                             };
                        moveInReadings.push(moveOutReading);
                    }
                }
                
            }
        }
        
        component.set('v.moveInReadingCheckMap',moveInReadingCheckMap);

        
        if (errorMessage.length > 0) {
            this.showNotification(component, errorMessage);
            return false;
        }
        else {
            this.clearNotification(component);
            if (moveInReadings.length > 0) {
                wizObj.moveInReadings = moveInReadings;
            }
            component.set('v.wizardprop', wizObj);
            console.log(this.DEBUG + 'wizObj:' + JSON.stringify(wizObj));
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
        var selectedBundleIds = component.get('v.selectedBundleIds');     
        var moveInDate = wizObj.moveInDate; 
        var bundleIds = [];
        
        // check if the number of selected bundles has changed
        var selectedBundlesHaveChanged = selectedBundleIds.length != wizObj.availableBundles.length;
        
        // build a bundle Id list for the server call
        for (var i = 0; i < wizObj.availableBundles.length; i++) {
            bundleIds.push(wizObj.availableBundles[i].Id);
            
            // and check if any of the selected bundles have changed
            selectedBundlesHaveChanged = selectedBundlesHaveChanged || selectedBundleIds[i] != wizObj.availableBundles[i].Id;
        }
        
        // if the selected bundles or the move in date have changed
        if (selectedBundlesHaveChanged || component.get('v.moveInDate') != moveInDate) {        
            component.set('v.selectedBundleIds', bundleIds);
            component.set('v.moveInDate', moveInDate);
            
            let params = {
                'availableBun': bundleIds,
                'moveInDate': moveInDate
            };
            
            this.callServer(component, 'c.retrieveReadingAndDevice',
                            function(response) {
                                component.set('v.recordList', response);
                            },
                            params);
        } 
    },
    
    // handle Estimate Button
    handleRowButtonPressEvent: function(component, event) {
        
        if (event.getParam('ButtonId') == 'Estimate') {
            var sRowId = event.getParam('RowId');
            var readingEstimate = component.find('readingEstimate');
            var wizObj = component.get('v.wizardprop');  //AT-2129 
            var moveInDate = wizObj.moveInDate;          //AT-2129 
            var errorMessage = [];
            
            // estimate a move in reading
            var recordList = component.get('v.recordList');
            for (var i = 0; i < recordList.length; i++) {
                if (recordList[i].uniqueId == sRowId) {
                    var newReading = recordList[i].objectMap[this.setPrefixedString('Reading__c1')]; //Sit005 sanity testing issue
                    var deviceId = newReading[this.setPrefixedString('Device__c')];		// AT-3174
                    var readingDate = newReading[this.setPrefixedString('ReadingDate__c')]; 
                    
                    console.log(this.DEBUG + 'estimating move in reading ...');
                    var helper = this;
                    readingEstimate.getEstimate(deviceId, readingDate, 
                                                function(response) {
                                                    console.log(helper.DEBUG + 'move in reading estimate: ' + JSON.stringify(response));
                                                    if (response && response[helper.setPrefixedString('ActualDeviceReading__c')]) {
                                                        newReading[helper.setPrefixedString('ActualDeviceReading__c')] = response[helper.setPrefixedString('ActualDeviceReading__c')];
                                                        newReading[helper.setPrefixedString('BillableType__c')] = response[helper.setPrefixedString('BillableType__c')];
                                                        newReading[helper.setPrefixedString('ReadingSource__c')] = response[helper.setPrefixedString('ReadingSource__c')];
                                                        newReading[helper.setPrefixedString('ReadingMethod__c')] = response[helper.setPrefixedString('ReadingMethod__c')];
                                                        newReading[helper.setPrefixedString('Tripped__c')] = response[helper.setPrefixedString('Tripped__c')];  //AT-3420 core 8b
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