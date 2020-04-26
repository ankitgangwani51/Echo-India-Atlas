({
    DEBUG: 'SelectOccupants: ',
    
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {
        console.log(this.DEBUG + 'reInitialise');
        component.set('v.isInitialised', false);
        component.set('v.locationId', null); 
        component.set('v.moveOutDate', null); 
        component.set('v.fieldList', []); 
        component.set('v.recordList', []);
        component.set('v.locationsRef', []);
        component.set('v.noResultFound', false);
    },
    
    // check the wizardprop/status on entry
    checksOnEntry : function(component) {
        // do checks here if required
        console.log(this.DEBUG + 'checksOnEntry');
        
        if (!component.get('v.isInitialised')) {
            this.initialiseDisplayedFields(component);
        }
        this.showNewRecords(component);
    },
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {
        var wizObj = component.get('v.wizardprop');
        var noResultFound = component.get('v.noResultFound');
        
        // locationId is required
        if (!noResultFound && !wizObj.locationOccupantsToMoveOut) {
            this.showNotification(component, [$A.get('$Label.c.CuAp_SelectLocationOccupantError')]);
            return false;
        } 
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
        
        // Retrieve list of fields and properties for the location
        this.callServer(component, 'c.retrieveLocationPropDetails',
                        function(response) {
                            component.set('v.fieldList', response);				
                        },
                        null);
        component.set('v.isInitialised', true);
    },
    
    // get the occupant records from the server
    showNewRecords: function(component) {
        var wizObj = component.get('v.wizardprop');
        
        // if the location or the move out date has changed
        if (component.get('v.locationId') != wizObj.location.Id
            || component.get('v.moveOutDate') != wizObj.moveOutDate) {        
            component.set('v.locationId', wizObj.location.Id);
            component.set('v.moveOutDate', wizObj.moveOutDate);
            
            let params = {
                'sLocationId': wizObj.location.Id,
                'sMoveOutDate': wizObj.moveOutDate,
            };
            this.callServer(component, 'c.getLocationOccupants',
                            function(response) {
                                component.set('v.recordList', response);
                                var selRec = [];
                                if (response.length > 0) {
                                    for (var i = 0; i < response.length; i++) {
                                        if (response[i].isSelected == true) {
                                            selRec.push({sobjectType : this.setPrefixedString('LocationOccupant__c'),
                                                         Id: response[i].objectMap[this.setPrefixedString('LocationOccupant__c')].Id,
                                                         [this.setPrefixedString('StartDate__c')]: response[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('StartDate__c')], //AT-4029
                                                         [this.setPrefixedString('EndDate__c')]: response[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('EndDate__c')]});    
                                        }
                                    }
                                    wizObj.locationOccupantsToMoveOut = selRec;
                                    component.set('v.noResultFound', false);
                                }
                                else {
                                    component.set('v.noResultFound', true);
                                }
                            },
                            params);
            
            this.callServer(component, 'c.queryLocation',
                            function(response) {
                                component.set('v.locationsRef', response);
                            },
                            {'sLocationId': wizObj.location.Id,});
        }
    },
    
    // selected/unselect an occupant
    handleRowSelectEvent: function(component, event) {
        var wizObj = component.get('v.wizardprop');
        var sRowId = event.getParam('RowId');
        var selRec = [];
        var recordList = component.get('v.recordList');
        for (var i = 0; i < recordList.length; i++) {
            if (recordList[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('OccupancyType__c')] == 'Landlord') {
                if (recordList[i].uniqueId == sRowId) { 
                    if (recordList[i].isSelected == true) {
                        recordList[i].isSelected = true;
                        selRec.push({sobjectType : this.setPrefixedString('LocationOccupant__c'),
                                     Id : recordList[i].objectMap[this.setPrefixedString('LocationOccupant__c')].Id,
                                     [this.setPrefixedString('EndDate__c')] : recordList[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('EndDate__c')]}); 
                    } else {
                        recordList[i].isSelected = false;    
                    }
                }
            } else {
                recordList[i].isSelected = true;
                selRec.push({sobjectType : this.setPrefixedString('LocationOccupant__c'),
                             Id : recordList[i].objectMap[this.setPrefixedString('LocationOccupant__c')].Id,
                             [this.setPrefixedString('EndDate__c')] : recordList[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('EndDate__c')]});
            }
        }
        component.set('v.recordList', recordList);
        wizObj.locationOccupantsToMoveOut = selRec;
        component.set('v.wizardprop', wizObj);
        this.clearNotification(component);
    },
    
})