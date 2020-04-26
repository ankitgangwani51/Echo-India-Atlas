({
    DEBUG: 'NewBillingAddress: ',
    
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {
        component.set('v.isInitialised', false);
        component.set('v.locationId', null);
        component.set('v.isEnterNewAddress', false);
        component.set('v.updatedContract', null);
        component.set('v.objContract', null);
    },
    
    // check the wizardprop/status on entry
    checksOnEntry : function(component) {
        // do checks here if required
        var wizObj = component.get('v.wizardprop');
        
        if (wizObj.accountId && wizObj.location.Id) {
            if (!component.get('v.isInitialised')) {
                component.set('v.updatedContract', {'sobjectType': this.setPrefixedString('BillingContract__c')});
                component.set('v.objContract', {'sobjectType': this.setPrefixedString('BillingContract__c')});
                this.initialiseDisplayedFields(component);
            }
            this.getContract(component);
        }
        
    },
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {
        debugger;
        // Validation to check - all Forwarding Address fields must be populated in the wizard, or none (validation)
        var updatedContract = component.get('v.updatedContract');
        var billingStreet = updatedContract[this.setPrefixedString('BillingStreet__c')];
        var billingPostalCode = updatedContract[this.setPrefixedString('BillingPostalCode__c')];
        var isEnterNewAddress = component.get('v.isEnterNewAddress');
        if (isEnterNewAddress) {
            if (billingStreet && billingPostalCode) {
                // Assigning updated contract value in wizard object.
                return this.processContract(component);
            } else {
                this.showNotification(component, [$A.get('$Label.c.CuAp_StreetAndPostcodeAreMandatory')]);
                return false;
            }
        }
        else {
            return this.processContract(component);
        } 
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
    initialiseDisplayedFields: function(component, event, helper) {  
        // retrieve list of fields and properties for the search parameters
        var wizprop = component.get("v.wizardprop");
        
        this.callServer(component,'c.retrieveAddressFields', 
                        function(response) {
                            component.set('v.billingAddressFields', response);
                        },
                        {
                            'fieldsetName': $A.get('$Label.c.CuAp_BillingAddressFieldSet') 
                        });
        component.set('v.isInitialised', true);
    },
    
    // query for device readings
    getContract: function(component) {
        var wizObj = component.get('v.wizardprop');
        var locationId = wizObj.location.Id;        
        
        // if the location has changed
        if (component.get('v.locationId') != locationId) {
            component.set('v.locationId', locationId);
            
            let params = {
                'locationId': locationId,
                'accountId': wizObj.accountId
            };
            
            // Retrieve contract billing information
            this.callServer(component, 'c.retrieveContractBillingDetails', function(response) {
                component.set('v.objContract', response);
                if (response !== null) {
                    var objContract = component.get('v.objContract');
                    if (wizObj.accountId != null) {
                        if (objContract[this.setPrefixedString('AccountName__c')] != null) {
                            if (objContract[this.setPrefixedString('AccountName__c')] === wizObj.accountId) {
                                if (objContract[this.setPrefixedString('BillingAddress__c')]) {
                                    var billingAddress = objContract[this.setPrefixedString('BillingAddress__c')].replace(new RegExp('<br>', 'g'), ' ');
                                    objContract[this.setPrefixedString('BillingAddress__c')] = billingAddress;
                                }
                            }
                        }
                    }
                }
            }, 
          params);
        }
    },      
    
    // update contract billing address.
    processContract: function(component) {
        var updatedContract = component.get('v.updatedContract');
        var billingStreet = updatedContract[this.setPrefixedString('BillingStreet__c')];
        var billingCity = updatedContract[this.setPrefixedString('BillingCity__c')];
        var billingState = updatedContract[this.setPrefixedString('BillingState__c')];
        var billingPostalCode = updatedContract[this.setPrefixedString('BillingPostalCode__c')];
        var billingCountry = updatedContract[this.setPrefixedString('BillingCountry__c')];
        var altAuDPID = updatedContract[this.setPrefixedString('AlternativeAuDpid__c')];
        var billingAuDPID = updatedContract[this.setPrefixedString('BillingAuDpid__c')];
        
        var isNewAddress = component.get('v.isEnterNewAddress');
        var wizObj = component.get('v.wizardprop');
        var objContract = component.get('v.objContract');
         
        if (objContract !== null && objContract.Id !== null) {
            if (wizObj.accountId !== 'undefined' && wizObj.accountId !== null) {
                if (objContract[this.setPrefixedString('AccountName__c')] != 'undefined' && 
                    objContract[this.setPrefixedString('AccountName__c')] != null) {
                    if (objContract[this.setPrefixedString('AccountName__c')] === wizObj.accountId) {
                        if (isNewAddress) {
                            wizObj.newBillingAddress = {
                                sobjectType: this.setPrefixedString('BillingContract__c'),
                                Id: objContract.Id,
                                [this.setPrefixedString('BillingStreet__c')]: billingStreet,
                                [this.setPrefixedString('BillingCity__c')]: billingCity,
                                [this.setPrefixedString('BillingState__c')]: billingState,
                                [this.setPrefixedString('BillingPostalCode__c')]: billingPostalCode,
                                [this.setPrefixedString('BillingCountry__c')]: billingCountry,
                                [this.setPrefixedString('AlternativeAuDpid__c')]: altAuDPID,
                                [this.setPrefixedString('BillingAuDpid__c')]: billingAuDPID
                            };
                            
                        }
                        else{
                            wizObj.newBillingAddress = {
                                sobjectType: this.setPrefixedString('BillingContract__c'),
                                Id: objContract.Id,
                            };
                        }
                        component.set('v.wizardprop', wizObj);
                        return true;
                    } else {
                        this.showNotification(component, [$A.get('$Label.c.CuAp_ContractAccountIdDoesNotMatchWithAccountId')]);
                        return false;
                    }
                } else {
                    this.showNotification(component, [$A.get('$Label.c.CuAp_AccountNotFoundForSelectedLocation')]);
                    return false;
                }
            } else {
                this.showNotification(component, [$A.get('$Label.c.CuAp_AccountNotFoundForSelectedLocation')]);
                return false;
            }
        } else {
            //this.showNotification(component, [$A.get('$Label.c.CuAp_ContractNotFoundForSelectedLocation')]);
            return true;
        }
    },
})