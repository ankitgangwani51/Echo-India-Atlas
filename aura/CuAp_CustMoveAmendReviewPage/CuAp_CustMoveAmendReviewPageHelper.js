({          
    DEBUG: 'Cust Move Amend Review Changes: ',
    
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {            
        component.set('v.isInitialised', false);
        component.set('v.fieldList', []);
        component.set('v.recordList', []);        
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component) {
        
        // do checks here if required
        if (!component.get('v.isInitialised')) {
            this.initialiseDisplayedFields(component);
        }
    },
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component) { 
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
        
        var wizObj = component.get('v.wizardprop');
        
        component.set('v.locationAddress', wizObj.locationAddress);
        component.set('v.oldMoveInDate', wizObj.selectedLocOcc[this.setPrefixedString('StartDate__c')]);        
        component.set('v.oldMoveOutDate', wizObj.selectedLocOcc[this.setPrefixedString('EndDate__c')]);        
        component.set('v.newMoveInDate', wizObj.moveInDate);        
        component.set('v.newMoveOutDate', wizObj.moveOutDate);

        if(wizObj.newBillingAddress != null){
            
            var newAddress = wizObj.newBillingAddress;
            
            var newAddr = '';
            
            if(newAddress[this.setPrefixedString('BillingStreet__c')]){
                newAddr = newAddress[this.setPrefixedString('BillingStreet__c')];
            }
            if(newAddress[this.setPrefixedString('BillingCity__c')]){
                newAddr = newAddr + ' ' + newAddress[this.setPrefixedString('BillingCity__c')];
            }
            if(newAddress[this.setPrefixedString('BillingState__c')]){
                newAddr = newAddr + ' ' +  newAddress[this.setPrefixedString('BillingState__c')];
            }
            if(newAddress[this.setPrefixedString('BillingPostalCode__c')]){
                newAddr = newAddr + ' ' +  newAddress[this.setPrefixedString('BillingPostalCode__c')];
            }
            if(newAddress[this.setPrefixedString('BillingCountry__c')]){
                newAddr = newAddr + ' ' +  newAddress[this.setPrefixedString('BillingCountry__c')];
            }
            
            component.set('v.billingAddress', newAddr);        
        }
        
        // Retrieve list of fields and properties for the suppression contracts
        this.callServer(component, 'c.retrieveReadingPropDetails',
                        function(response) {        
                            component.set('v.fieldList', response);    
                        },  
                        null); 
        component.set('v.isInitialised', true);
        
        //Swati-- ;       
        var readingDate;
        
        if(wizObj.moveInDate) 
            readingDate = wizObj.moveInDate;        
        else 
            readingDate = wizObj.moveOutDate;
        
        let params ={
            "readingsList": wizObj.newReadingsLists
        };
        
        // Retrieve list of fields and properties for the suppression contracts
        this.callServer(component, 'c.retrieveReadingRecords',
                        function(response) {        
                            for(var iCount=0;iCount<response.length;iCount++){
                                var rowNo = iCount+1;
                                response[iCount].objectMap[this.setPrefixedString('Reading__c')][this.setPrefixedString('ReadingDate__c')]= readingDate;                      
                            }
                            component.set('v.recordList', response);    
                        },  
                        params); 
       
        
    }
})