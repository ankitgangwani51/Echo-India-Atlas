({          
    DEBUG: 'Select Location Occ To Amend: ',
    
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
        else{
            var wizObj = component.get('v.wizardprop');
            component.set('v.checkedButton',wizObj.selectedOption);
            component.set('v.selectedOptionToAmend',wizObj.selectedOption);
        }
    },
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {  
        
        var errorVal = this.validations(component);
        if(errorVal != ''){
            this.showNotification(component, [errorVal],'error');
            return false;
        }
        component.set('v.selectedOptionToAmend','');
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
        
        var optionsList =  [{'label': $A.get('$Label.c.CuAp_AmendDetails'), 'value': $A.get('$Label.c.CuAp_AmendDetailsOptions')},
                            {'label': $A.get('$Label.c.CuAp_DeleteDetailsOptionsLabel'), 'value': $A.get('$Label.c.CuAp_DeleteDetailsOptions')}
                           ];
        component.set('v.optionsList', optionsList);
        
        let params = {"recordId" : component.get("v.recordId")};
        this.callServer(component,'c.getInfoToDisplay', 
                        function(response) {
                            component.set('v.fieldList', response.returnFieldProps);
                            component.set('v.recordList', response.listLocOccRecords);  
                            component.set('v.accName', response.accountName);
                        },
                        params);
         component.set('v.isInitialised', true);
    },
    
    // Set the stepped tariff values into wizard variable on selection of the row to process further
    handleRowSelectEvent: function(component, event, helper) {
        this.clearNotification(component);
        
        var sRowId = event.getParam('RowId');
        var recordList = component.get('v.recordList');
        var wizObj = component.get('v.wizardprop');
        
        //component.set("v.recordToDelete",'false');
        
        for (var i = 0; i < recordList.length; i++) {
            if (recordList[i].uniqueId != sRowId) {
                recordList[i].isSelected = false;
            } else if(recordList[i].isSelected == true) {
                
                wizObj.selectedLocOcc = {sobjectType: this.setPrefixedString('LocationOccupant__c'), 
                                         ['Id']											: recordList[i].objectMap[this.setPrefixedString('LocationOccupant__c')]['Id'],
                                         [this.setPrefixedString('StartDate__c')]		: recordList[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('StartDate__c')],
                                         [this.setPrefixedString('EndDate__c')]			: recordList[i].objectMap[this.setPrefixedString('LocationOccupant__c')][this.setPrefixedString('EndDate__c')]
                                        }
                wizObj.locationId = recordList[i].objectMap[this.setPrefixedString('Location__c')]['Id'];
                wizObj.locationName = recordList[i].objectMap[this.setPrefixedString('Location__c')]['Name'];
                wizObj.locationAddress = recordList[i].objectMap[this.setPrefixedString('Location__c')]['Address__c'];
                
                wizObj.location = {sobjectType: this.setPrefixedString('Location__c'), 
                                         ['Id']											: recordList[i].objectMap[this.setPrefixedString('Location__c')]['Id']
                                         
                                        }
            }
        }
        
        wizObj.accountName = component.get('v.accName') ;
        wizObj.accountId = component.get('v.recordId') ;
        
        if(component.get('v.selectedOptionToAmend') == $A.get("$Label.c.CuAp_DeleteDetailsOptions")){
            wizObj.deleteRecord = 'true';
        }
        else{
            wizObj.deleteRecord = 'false';
        }
        
        component.set('v.wizardprop',wizObj);        
        component.set('v.recordList', recordList);
        
    },
    
    showInnerDetailsSection: function(component, options, event) {
        var processAsOption = document.getElementsByName('processAsInnerRadio') ;
        var selectedOption = this.getSelectedOption(component, processAsOption) ;        
        this.clearNotification(component);
        
        component.set('v.selectedOptionToAmend',selectedOption);
        
        var wizObj = component.get('v.wizardprop');
        var compEvent = component.getEvent("passValueEvent");
        
        if(selectedOption == $A.get("$Label.c.CuAp_AmendDetailsOptions")){
            wizObj.deleteRecord = 'false';
        }
        if(selectedOption == $A.get("$Label.c.CuAp_DeleteDetailsOptions")){
            wizObj.deleteRecord = 'true';
        }
        
        wizObj.selectedOption = selectedOption;
        
        component.set('v.wizardprop',wizObj); 
        compEvent.fire();
        
    },
    
    //returns the user selected option
    getSelectedOption : function(component, options) {
        var selectedOption = '' ;
        for(var i = 0; length <= options.length; i++) {
            if(options[i].checked) {
                selectedOption = options[i].value ;
                break ;
            }
        }
        return selectedOption ;
    }, 
    
    validations: function(component) {
        
        var recordList = component.get('v.recordList');
        var wizObj = component.get('v.wizardprop');
        var errorValue = '';
        var selectARecord = false;
        
        if(component.get('v.selectedOptionToAmend') == '' || component.get('v.selectedOptionToAmend') == undefined){
            errorValue = $A.get("$Label.c.CuAp_SelectAOptionToAmend");
            return errorValue;
        }
        
        for (var i = 0; i < recordList.length; i++) {
            
            if(recordList[i].isSelected == true){
                selectARecord = true;
            }
        }
        
        if(!selectARecord){
            errorValue = $A.get("$Label.c.CuAp_SelectLocationOccToAmend");
        }
        
        return errorValue;
    }
    
})