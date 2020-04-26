({
	DEBUG: 'SelectBundle: ',
	
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component) {
        console.log(this.DEBUG + 'reInitialise');
        component.set('v.isInitialised', false);
        component.set('v.selectedServiceIds', []);
        component.set('v.fieldList', []);
        component.set('v.recordList', []);
        component.set('v.recordList1', []);
        
        component.set('v.fieldListSundry', []);
        component.set('v.recordListSundry', []);
        component.set('v.errorMessage', '');
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component) {
        // do checks here if required
        console.log(this.DEBUG + 'checksOnEntry');
        var wizObj = component.get('v.wizardprop');
        if (wizObj.selectedServices &&  wizObj.selectedServices.length > 0) {
            if (!component.get('v.isInitialised')) {
                this.initialiseDisplayedFields(component);
                this.checkActiveTariffLimit(component,wizObj);
            }
            this.loadBundles(component);
        }
    },

    // validates the wizardprop on completion of the step
    validateOnNext: function(component) {
    	// check for errors
    	this.checkError(component);
        // show error message if there are errors
        var errMessage = component.get('v.errorMessage');
        if (errMessage.length > 0) {
            this.showNotification(component, errMessage);
            return false;
        }
        else {
        	this.clearNotification(component);
            this.handleSelectedRow(component);
            return true;
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
    initialiseDisplayedFields: function(component) {
        
        // Retrieve list of fields and properties for the fields on the wizard
        this.callServer(component,'c.retrieveSerBundlesFieldPropDetails',
                        function(response) {
                            component.set('v.fieldList', response);    
                        },  
                        null); 
        
        // Retrieve list of fields and properties for the fields related to Sundry
        this.callServer(component,'c.retrieveSundryFieldPropDetails',
                        function(response) {
                            component.set('v.fieldListSundry', response);    
                        },  
                        null); 
        
        this.callServer(component,'c.retrieveSundryServices',
                        function(response) {
                            component.set('v.recordListSundry', response);
                        },  
                        null); 
        component.set('v.isInitialised', true);
    },
    
    // load the bundles
    loadBundles: function(component) {
        debugger;
        component.set('v.recordList1', []);
        var wizObj = component.get('v.wizardprop');
        var selectedServiceIds = component.get('v.selectedServiceIds');     
        var selectedServices = wizObj.selectedServices;
        var serviceIds = [];
        var supplyPointIds = [];
        
        // check if the number of selected services has changed
        var selectedServicesHaveChanged = selectedServiceIds.length != selectedServices.length;
        
        // build the Id lists for the server call
        for (var i = 0; i < selectedServices.length; i++) {
            serviceIds.push(selectedServices[i].Id);
            supplyPointIds.push(selectedServices[i][this.setPrefixedString('SupplyPoint__c')]);
            
            // and check if any of the selected services have changed
            selectedServicesHaveChanged = selectedServicesHaveChanged || selectedServiceIds[i] != selectedServices[i].Id;
        }
        // if the selected services have changed
        if (selectedServicesHaveChanged) {        
            component.set('v.selectedServiceIds', serviceIds);
            // retrieve the list of related available bundles and Available Service Items
            let params = {
                'supplyPtIds': supplyPointIds,
                'serviceIds': serviceIds,           
            };
            this.callServer(component, 'c.retrieveServiceBundles',function(response) {
                debugger;
                console.log('response===='+ response)
                if(response.length > 0){
                    component.set('v.recordTempList', response); 
                }else{
                    component.set('v.recordList', response);
                     component.set('v.recordTempList', response); 
                }
                debugger;
                var recordList= component.get('v.recordTempList');
                var availableBundleWithoutTariff = [];
                var availableBundleWithTariff = [];
                for (var i = 0; i < recordList.length; i++) {
                    var isTariffLimit =  recordList[i].objectMap[this.setPrefixedString('AvailableBundle__c')][this.setPrefixedString('TariffLimit__c')];
                    if(!isTariffLimit){
                        availableBundleWithoutTariff.push(recordList[i]);
                    }else{
                        recordList[i].isSelected = true;
                        availableBundleWithTariff.push(recordList[i]); 
                    }
                }
                if(availableBundleWithoutTariff.length > 0){
                    component.set('v.recordList', availableBundleWithoutTariff);
                }
                if(component.get('v.isActiveTariffLimit')) {
                    if(availableBundleWithTariff.length > 0){
                        component.set('v.recordList1', availableBundleWithTariff);
                    }
                }
            },
                            params);
        }
        
    },
    //Check active tariff on Account
    checkActiveTariffLimit : function(component,wizProp) {
        let params = {
            'accountId': wizProp.accountId,
            'strMoveInDate': wizProp.moveInDate       
        };
        this.callServer(component, 'c.CheckActiveTariffLimit',
                        function(response) {
                            debugger;
                            console.log('response===='+ response)
                            component.set('v.isActiveTariffLimit',response);
                        },
                        params);
    },
    
    // handle selection of available bundles
    handleSelectedRow: function(component) {
        var allSelectedBun = [];
        var allSrvItems = [];
        var avlBundles = component.get('v.recordList');
        var avlSrvItems = [];
        var avlSrv = [];
        var avlBundles1 = component.get('v.recordList1');
        if(avlBundles1 && component.get('v.isActiveTariffLimit')){
            for (var i = 0; i < avlBundles1.length; i++) {
                avlBundles.push(avlBundles1[i]);
            }
        }
        // Sundry Records
        var allSundryItems = component.get('v.recordListSundry');
        var allSundryList = [];
        if (allSundryItems != undefined || allSundryItems != '') {
            for (var i = 0; i < allSundryItems.length; i++) {
                if (allSundryItems[i].isSelected) {
                    var sundryId = allSundryItems[i].uniqueId;
                    var sundryRec = {
                        sobjectType: this.setPrefixedString('ServiceItemType__c'),
                        Id: sundryId,                    
                    }
                    allSundryList.push(sundryRec);
                }     
            }
        }

        console.log('avlBundles = '+JSON.stringify(avlBundles));
        debugger;
        if (avlBundles != undefined || avlBundles != '') {
            for (var i = 0; i < avlBundles.length; i++) {
                if (avlBundles[i].isSelected) {
                    var rowId = avlBundles[i].uniqueId;
                    //avlSrvItems = avlBundles[i].objectMap[this.setPrefixedString('AvailableBundle__c')][this.setPrefixedString('AvailableServiceItems__r')];
                      avlSrvItems =  avlBundles[i].lstSobjectMap[this.setPrefixedString('AvailableServiceItem__c')];
                      
                    var rec = {
                                sobjectType: this.setPrefixedString('AvailableBundle__c'),
                                Id: rowId,
                                [this.setPrefixedString('AvailableService__c')]: avlBundles[i].objectMap[this.setPrefixedString('AvailableBundle__c')][this.setPrefixedString('AvailableService__c')],
                                [this.setPrefixedString('TariffLimit__c')]:avlBundles[i].objectMap[this.setPrefixedString('AvailableBundle__c')][this.setPrefixedString('TariffLimit__c')]
                            }
                    console.log('avlSrvItems = '+avlSrvItems)
                    if (avlSrvItems != null || avlSrvItems != undefined) {
                        for (var j = 0; j < avlSrvItems.length; j++) {
                            var avlSrvItm = avlSrvItems[j].Id;
                            var srvItemType = avlSrvItems[j][this.setPrefixedString('ServiceItemType__c')];
                            console.log('srvItemType = '+srvItemType)
                            var recs = {
                                sobjectType : this.setPrefixedString('AvailableServiceItem__c'),
                                Id: avlSrvItm,
                                [this.setPrefixedString('AvailableBundle__c')]:  rowId,
                                [this.setPrefixedString('ServiceItemType__c')]: srvItemType,
                            }
                            allSrvItems.push(recs);
                        }
                    }
                    allSelectedBun.push(rec); 
                }
            }
         
        }
        var wizObj = component.get('v.wizardprop');
        wizObj.availableBundles = allSelectedBun;
        wizObj.selectedServiceItems = allSrvItems;
        wizObj.selectedSundryItems = allSundryList;
        component.set('v.wizardprop', wizObj);
    },
    
    // check for errors
    checkError: function(component) {
        
        var allSelectedBun = [];
        var avlBundleMap = {};
        var unSelectedavlBundleMap = {};
        var oneBundleError = $A.get('$Label.c.CuAp_BundleErrorMessage');
        var noBundleError = $A.get('$Label.c.CuAp_NoBundleErrorMessage');
        var tariffLimitActiveButNoBundle = $A.get('$Label.c.CuAp_TariffLimitActiveButNoBundleAvailableErrorMsg');
        var errorMessage = new Array();
        var avlBundles = component.get('v.recordList');
        var wizObjNew = component.get('v.wizardprop');
        
        if (avlBundles != undefined || avlBundles != '') {
	        for (var i = 0; i < avlBundles.length; i++) {
	            if (avlBundles[i].isSelected) {
	                var rowId = avlBundles[i].uniqueId;
	                allSelectedBun.push(rowId);
	
	                var key = avlBundles[i].objectMap[this.setPrefixedString('AvailableBundle__c')][this.setPrefixedString('AvailableService__c')];
	                if (key in avlBundleMap) {
	                   avlBundleMap[key].push(avlBundles[i].uniqueId);
	
	                } else {
	                    avlBundleMap[key] = [avlBundles[i].uniqueId];
	                }
	                
	            } else {
	                var key = avlBundles[i].objectMap[this.setPrefixedString('AvailableBundle__c')][this.setPrefixedString('AvailableService__c')];
	                if (key in unSelectedavlBundleMap) {
	                    unSelectedavlBundleMap[key].push(avlBundles[i].uniqueId);    
	                } else {
	                    unSelectedavlBundleMap[key] = [avlBundles[i].uniqueId];
	                }
	            }
	        }
        }
        var getMapVal = [];

        if (allSelectedBun.length>0) {
            for (var keys in avlBundleMap) { 
                    getMapVal = avlBundleMap[keys];
                    
                    if (getMapVal.length>1) {
                        errorMessage.push(oneBundleError);
                        //break;
                    } else {
                        errorMessage = new Array();
                    }
            }
            
            for (var unsldkey in unSelectedavlBundleMap) {
                if (!(unsldkey in avlBundleMap)) {
                    if(wizObjNew.isAuRegion != null && wizObjNew.isAuRegion != true){
                        errorMessage.push(noBundleError);
                    }
                }
            }
            component.set('v.errorMessage', errorMessage);          
        } else {
            if(wizObjNew.isAuRegion != null && wizObjNew.isAuRegion != true){
                errorMessage.push(noBundleError);
                component.set('v.errorMessage', errorMessage);
            }
        }
        if(component.get('v.isActiveTariffLimit')) {
            var recordList = component.get('v.recordList1');
            if(recordList.length ==0 ){
                // Need to put in label.
                errorMessage.push(tariffLimitActiveButNoBundle); 
                component.set('v.errorMessage', errorMessage);
            }
        }
    }
})