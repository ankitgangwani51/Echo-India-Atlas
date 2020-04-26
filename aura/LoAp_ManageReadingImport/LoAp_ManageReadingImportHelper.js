({
    //  Displays the Reading Upload values to the components
    doInit : function(component, event, helper) {
        component.set("v.objReadingUpload", {'sobjectType':this.setPrefixedString('ReadingUpload__c'),
                                             [this.setPrefixedString('SerialNumber__c')] 	: '',
                                             [this.setPrefixedString('Manufacturer__c')] 	: '',
                                             [this.setPrefixedString('DeviceReference__c')] : '',
                                             [this.setPrefixedString('ReadingDate__c')] 	: '',
                                             [this.setPrefixedString('ReadingValue__c')]    : '',
                                             [this.setPrefixedString('ReadingMethod__c')] 	: '',
                                             [this.setPrefixedString('ReadSource__c')] 		: '',                                            
                                             [this.setPrefixedString('RejectionReason__c')] : '',
                                             [this.setPrefixedString('ReadingType__c')] 	: '',
                                             [this.setPrefixedString('Billable__c')] 		: '',
                                             [this.setPrefixedString('CheckServiceItemTolerance__c')] : ''}); //UL-21, Ankit, 21/02/2019
        
        component.set("v.objLocation", {'sobjectType':this.setPrefixedString('Location__c'),
                                        [this.setPrefixedString('Address__c')] : ''});
        
        component.set("v.objReading", {'sobjectType':this.setPrefixedString('Reading__c'),
                                       ['Override_Reading'] : false,
                                       ['Request_Reading']  : false,
                                       ['Override_Value']  : null,
                                       ['High_Reading']  : false,      //AT-3855
                                       ['Requested_Date']  : null});
        
        this.callServer(component,'c.retrieveReadingUploadFields', 
                        function(response) {
                            component.set('v.readingUploadFieldsForGeneric', response);
                        },
                        null);
        
        let params = {
            "readingUploadId" : component.get('v.recordId')
        };
        //To get contract details from server
        this.callServer(component,'c.getReadingUploadDetails',
                        function(response){ 
                            component.set("v.objReadingUpload", {'sobjectType':this.setPrefixedString('ReadingUpload__c'),
                                                                 [this.setPrefixedString('SerialNumber__c')] 	: response[this.setPrefixedString('SerialNumber__c')],
                                                                 [this.setPrefixedString('Manufacturer__c')] 	: response[this.setPrefixedString('Manufacturer__c')],
                                                                 [this.setPrefixedString('DeviceReference__c')] : response[this.setPrefixedString('DeviceReference__c')],
                                                                 [this.setPrefixedString('ReadingDate__c')] 	: response[this.setPrefixedString('ReadingDate__c')],
                                                                 [this.setPrefixedString('ReadingValue__c')] 	: response[this.setPrefixedString('ReadingValue__c')],
                                                                 [this.setPrefixedString('ReadingMethod__c')] 	: response[this.setPrefixedString('ReadingMethod__c')],
                                                                 [this.setPrefixedString('ReadSource__c')] 		: response[this.setPrefixedString('ReadSource__c')],
                                                                 [this.setPrefixedString('RejectionReason__c')] : response[this.setPrefixedString('RejectionReason__c')],
                                                                 [this.setPrefixedString('ReadingType__c')] 	: response[this.setPrefixedString('ReadingType__c')],
                                                                 [this.setPrefixedString('Billable__c')] 		: response[this.setPrefixedString('Billable__c')],
                                                                 [this.setPrefixedString('ReadPeriodId__c')] 	: response[this.setPrefixedString('ReadPeriodId__c')],
                                                                 [this.setPrefixedString('Tripped__c')]			: response[this.setPrefixedString('Tripped__c')], // SIT005 Readiness, Gopal Gupta, 05/04/2019
                                                                 //[this.setPrefixedString('Processed__c')]		: response[this.setPrefixedString('Processed__c')],
                                                                 [this.setPrefixedString('ReadingStatus__c')]	: response[this.setPrefixedString('ReadingStatus__c')], // CLB-18, Ankit, 01/04/2019
                                                                 [this.setPrefixedString('CheckServiceItemTolerance__c')]		: response.CheckServiceItemTolerance__c == 'true' ? true : false}); //UL-21, Ankit, 21/02/2019
                            
                            
                            component.set("v.objLocation", {'sobjectType':this.setPrefixedString('Location__c'),
                                                            [this.setPrefixedString('Address__c')] : response[this.setPrefixedString('Address__c')]});
                            
                            component.set('v.deviceId',response.DeviceId);
                            component.set('v.supplyPointId',response.supplyPointId); 
                            component.set('v.supplyPointDeviceId',response.supplyPointDeviceId);   //At-3855
                            component.set('v.deviceDigit',response.DeviceDigit);
                            component.set('v.lastReading',response.lastReading);
                        },                         
                        params); 
     
        component.set('v.objectName',this.setPrefixedString['Reading__c']);
        component.set('v.detailListFields',this.setPrefixedString['BillablePreviousReadings']);        
        
    },
    
    // shows the manage reading component and hide the manage reading import button
    showManageReadingComponent:function(component, event, helper) {        
        component.set('v.manageReadingImportScreen',true);
    },
    
    // shows the manage reading import button and hide the manage reading component
    hideManageReadingComponent:function(component, event, helper) {
        component.set('v.manageReadingImportScreen',false);
    },
    
    // change event function fo handle the checkbox field to show/hide the input field based on checkbox    
    handleInputChangeEvent  : function(component, event, helper) {
        var eventParams = event.getParams();
        var readingValues = component.get('v.objReading');
        
        //AT-3855
        if(eventParams['fieldName'] == [$A.get('$Label.c.LoAp_HighReading')]){
            if(readingValues['High Reading'])
                component.set('v.highReading',true);
            else
                component.set('v.highReading',false);
        }
        
        if(eventParams['fieldName'] == 'Override_Reading'){
            if(readingValues['Override_Reading']){
                component.set('v.editOverrideReading',true);
            }else{
                readingValues['Override_Value'] = null;
                component.set("v.objReading", {'sobjectType':this.setPrefixedString('Reading__c'),
                                               ['Override_Reading'] : false,
                                               ['Override_Value']  : null});
                component.set('v.editOverrideReading',false);  
            }
        } 
        if(eventParams['fieldName'] == 'Request_Reading'){
            if(readingValues['Request_Reading']){
                component.set('v.editRequestReading',true);
            }else{
                readingValues['Requested_Date'] = null;
                component.set("v.objReading", {'sobjectType':this.setPrefixedString('Reading__c'),
                                               ['Request_Reading']  : false,
                                               ['Requested_Date']  : null});
                component.set('v.editRequestReading',false);
                
            }
        }
    },
    
    // Validate new reading with previous readings and create Reading, Schedule Read and Reading Upload records
    handleAccept: function(component, event, helper) {
        component.find('notification').clearNotification();
        var readingUploadId = component.get('v.recordId'); 
        var deviceId = component.get('v.deviceId');
        var readingValues = component.get('v.objReading');        
        var readingUploadValues = component.get('v.objReadingUpload');        
        var selectedRecord = component.get('v.selectedRecord');
        
        if(!deviceId){
            component.find('notification').showNotification([$A.get("$Label.c.LoAp_NoDeviceFound")],'error');
            return false;
        }
       
        // SIT005 Readiness, Gopal Gupta, 05/04/2019
        if(readingUploadValues[this.setPrefixedString('Tripped__c')] == false && readingUploadValues[this.setPrefixedString('ReadingValue__c')] <= component.get('v.lastReading')){        // AT-4376    
            component.find('notification').showNotification([$A.get("$Label.c.LoAp_ReadingLowerMustBeAmendment")],'error');
            return false;
        }
        
        if(!readingUploadValues[this.setPrefixedString('ReadPeriodId__c')]){            
            component.find('notification').showNotification([$A.get("$Label.c.LoAp_NoReadingPeriodIdExist")],'error');
            return false;
        }        
        
        let params = {
            "readingUploadValues" : JSON.stringify(readingUploadValues),
            "overrideValue" : '',
            "deviceId" : deviceId,
            "readingUploadId" : readingUploadId,
            "supplyPointId" : component.get('v.supplyPointId'),
            "mode" : $A.get("$Label.c.LoAp_Accept"),
            "highreading"  :  component.get('v.highReading'),  //AT-3855
            "supplyPointDeviceId" : component.get('v.supplyPointDeviceId'),  //AT-3855
            "checkBillingTolerance" : readingUploadValues[this.setPrefixedString('CheckServiceItemTolerance__c')] //UL-21, Ankit, 21/02/2019
        };
        
        this.callServer(component,'c.saveReadingRecord', 
                        function(response) {   
                            component.find('spinner').show();
                            if(response == [$A.get('$Label.c.GlAp_NoError')]){
                                component.find('notification').showNotification([$A.get("$Label.c.LoAp_ReadingCreated")],'info');
                                this.doInit(component, event, helper);// Calling doInit for page refresh and display latest reading values
                            }                                
                            else{  //AT-3855
                                if(response == [$A.get('$Label.c.GlAp_UpperThresholdReadingRejected')]) {
                                    component.find('notification').showNotification([$A.get("$Label.c.LoAp_ReadOutsideUpperThreshold")],'error');
                                }
                                else if(response == [$A.get('$Label.c.GlAp_ADUInactive')])
                                    component.find('notification').showNotification([$A.get("$Label.c.LoAp_ADUNotFound")],'error');
                                    else if (response ==  [$A.get('$Label.c.GlAp_ReadTimetableThresholdInvalid')]) 
                                        component.find('notification').showNotification([$A.get("$Label.c.LoAp_ReadTimetableThresholdInvalid")],'error');
                                        else
                                            component.find('notification').showNotification([$A.get("$Label.c.LoAp_ReadingCannotCreated")],'error');
                            }
                            component.find('spinner').hide();   
                        },
                        params);        
    },
    
    // Validate the override values and create the reading, schedule read and reading upload values 
    handleOverride: function(component, event, helper) {
        component.find('notification').clearNotification();
        
        var deviceDigit = component.get('v.deviceDigit');
        var readingUploadId = component.get('v.recordId'); 
        var deviceId = component.get('v.deviceId');
        var readingUploadValues = component.get('v.objReadingUpload');
        var readingValues = component.get('v.objReading');
       
        if(!deviceId){
            component.find('notification').showNotification([$A.get("$Label.c.LoAp_NoDeviceFound")],'error');
            return false;
        }
        
        if(readingValues['Override_Reading']){
            
            if(!readingValues['Override_Value']){
                component.find('notification').showNotification([$A.get("$Label.c.LoAp_PleaseEnterOverrideValue")],'error');  
                return false;
            }
            
            if(readingValues['Override_Value'] < readingUploadValues[this.setPrefixedString('ReadingValue__c')]){
                component.find('notification').showNotification([$A.get("$Label.c.LoAp_ReadingLowerThanPrevious")],'error');  
                return false;
            }
            
            if(deviceDigit < readingValues['Override_Value'].toString().length){   //AT-4397          
                component.find('notification').showNotification([$A.get("$Label.c.LoAp_Overridevalueshouldbedevicedigit") + ' ' +deviceDigit],'error');  
                return false;
            }
            
            if(!readingUploadValues[this.setPrefixedString('ReadPeriodId__c')]){            
                component.find('notification').showNotification([$A.get("$Label.c.LoAp_NoReadingPeriodIdExist")],'error');
                return false;
            }  
            
            //AT-4397
            if(readingValues['Override_Value'] <= component.get('v.lastReading')){            
                component.find('notification').showNotification([$A.get("$Label.c.LoAp_ReadingLowerMustBeAmendment")],'error');
                return false;
            }
                
            let params = {
                "readingUploadValues" : JSON.stringify(readingUploadValues),
                "overrideValue" : JSON.stringify(readingValues['Override_Value']),
                "deviceId" : deviceId,
                "readingUploadId" : readingUploadId,
                "supplyPointId" : component.get('v.supplyPointId'),
                "mode" : $A.get("$Label.c.LoAp_Override"),
                "highreading"  :  component.get('v.highReading'),  //AT-3855
                "supplyPointDeviceId" : component.get('v.supplyPointDeviceId')   //AT-3855
            };
            this.callServer(component,'c.saveReadingRecord', 
                            function(response) {   
                                component.find('spinner').show();
                                
                                if(response == [$A.get('$Label.c.GlAp_NoError')]){
                                    component.set("v.objReading", {'sobjectType':this.setPrefixedString('Reading__c'),
                                                                   ['Override_Reading'] : false,
                                                                   ['Override_Value']  : null});
                                    component.find('notification').showNotification([$A.get("$Label.c.LoAp_ReadingCreated")],'info');
                                    this.doInit(component, event, helper);// Calling doInit for page refresh and display latest reading values
                                }                                
                                else{  //AT-3855
                                    if(response == [$A.get('$Label.c.GlAp_UpperThresholdReadingRejected')]) {
                                        component.find('notification').showNotification([$A.get("$Label.c.LoAp_ReadOutsideUpperThreshold")],'error');
                                    }
                                    else if(response == [$A.get('$Label.c.GlAp_ADUInactive')])
                                        component.find('notification').showNotification([$A.get("$Label.c.LoAp_ADUNotFound")],'error');
                                        else if (response ==  [$A.get('$Label.c.GlAp_ReadTimetableThresholdInvalid')]) 
                                            component.find('notification').showNotification([$A.get("$Label.c.LoAp_ReadTimetableThresholdInvalid")],'error');
                                            else
                                                component.find('notification').showNotification([$A.get("$Label.c.LoAp_ReadingCannotCreated")],'error');
                                }
                                component.find('spinner').hide();   
                            },
                            params);
        }
    },
    
    // Validate the Request Date and create Request Reading records associated with the Supply Point
    handleRequestRead: function(component, event, helper) {
        component.find('notification').clearNotification();
        
        var deviceId = component.get('v.deviceId');
        if(!deviceId){
            component.find('notification').showNotification([$A.get("$Label.c.LoAp_NoDeviceFound")],'error');
            return false;
        }

        var readingValues = component.get('v.objReading');
        var today = new Date();
        var todaysDate = today.getFullYear() + "-" + ("0" + (today.getMonth() + 1)).slice(-2) + "-" + ("0" + today.getDate()).slice(-2);
   
        if(readingValues['Request_Reading'] == true){
            
            if(!readingValues['Requested_Date']){
                component.find('notification').showNotification([$A.get("$Label.c.LoAp_EnterRequstedDate")],'error');  
                return false;
            }
            
            if(readingValues['Requested_Date'] <= todaysDate){
                component.find('notification').showNotification([$A.get("$Label.c.LoAp_RequestedDateMustBeFuture")],'error');  
                return false;
            }
            
            let params = {
                "requestedDate" : readingValues['Requested_Date'],
                "supplyPointId" : component.get('v.supplyPointId')
            };
            this.callServer(component,'c.saveRequestRead', 
                            function(response) {
                                component.find('spinner').show();
                                if(response){
                                    component.set("v.objReading", {'sobjectType':this.setPrefixedString('Reading__c'),
                                               ['Request_Reading']  : false,
                                               ['Requested_Date']  : null});
                                    component.find('notification').showNotification([$A.get("$Label.c.LoAp_RequestReadingCreated")],'info');
                                    this.doInit(component, event, helper); // Calling doInit for page refresh and display latest reading values
                                }                                    
                                else
                                    component.find('notification').showNotification([$A.get("$Label.c.LoAp_RequestReadingCannotCreated")],'error');  
                                component.find('spinner').hide();                            
                            },
                            params);
        }
    },
    
    // Validate new reading with previous readings and create Reading, Schedule Read and Reading Upload records, also generate an amendment bill 
    handleAmendPrevious: function(component, event, helper) {
        component.find('notification').clearNotification();
        
        var readingUploadId = component.get('v.recordId'); 
        var deviceId = component.get('v.deviceId');
        var readingValues = component.get('v.objReading');        
        var readingUploadValues = component.get('v.objReadingUpload');        
        var selectedRecord = component.get('v.selectedRecord'); 
        
        if(!deviceId){
            component.find('notification').showNotification([$A.get("$Label.c.LoAp_NoDeviceFound")],'error');
            return false;
        }
        
        if(!selectedRecord){
            component.find('notification').showNotification([$A.get("$Label.c.LoAp_ReadingMustSelectToAmend")],'error');
            return false;
        }
        
        if(readingUploadValues[this.setPrefixedString('ReadingValue__c')] < selectedRecord[this.setPrefixedString('Reading__c')]){   
            component.find('notification').showNotification([$A.get("$Label.c.LoAp_ReadingLowerThanPrevious")],'error');
            return false;
        }
        
        if(!readingUploadValues[this.setPrefixedString('ReadPeriodId__c')]){            
            component.find('notification').showNotification([$A.get("$Label.c.LoAp_NoReadingPeriodIdExist")],'error');
            return false;
        }
        
        let params = {
            "readingUploadValues" : JSON.stringify(readingUploadValues),
            "overrideValue" : '',
            "deviceId" : deviceId,
            "readingUploadId" : readingUploadId,
            "supplyPointId" : component.get('v.supplyPointId'),
            "amendedByFieldName" : this.setPrefixedString('AmendedByReading__c'),
            "selectedRecord" : JSON.stringify(selectedRecord),
            "highreading"  :  component.get('v.highReading'),  //AT-3855
            "supplyPointDeviceId" : component.get('v.supplyPointDeviceId'),   //AT-3855
            "checkBillingTolerance" : readingUploadValues[this.setPrefixedString('CheckServiceItemTolerance__c')] //UL-21, Ankit, 21/02/2019
        };
        
        this.callServer(component,'c.saveAmendPrevious', 
                        function(response) {   
                            component.find('spinner').show();
                            
                            component.set('v.objectName',this.setPrefixedString('Reading__c'));
                            if(response.readingId)
                                component.set('v.newRecordId', response.readingId);
                           
                            if(response.Error)   //AT-3885
                            { 
                                if(response.Error == [$A.get('$Label.c.GlAp_UpperThresholdReadingRejected')]) 
                                    component.find('notification').showNotification([$A.get("$Label.c.LoAp_ReadOutsideUpperThreshold")],'error');
                                if(response.Error == [$A.get('$Label.c.GlAp_ADUInactive')])
                                    component.find('notification').showNotification([$A.get("$Label.c.LoAp_ADUNotFound")],'error');
                                if (response.Error  == [$A.get('$Label.c.GlAp_ReadTimetableThresholdInvalid')]) 
                                   component.find('notification').showNotification([$A.get("$Label.c.LoAp_ReadTimetableThresholdInvalid")],'error');
                            }
                            else if(!response.readingId && !response.scheduleReadId && response.processed != $A.get("$Label.c.LoAp_ProcessedLabel")) { // CLB-18, Ankit, 01/04/2019
                                component.find('notification').showNotification([$A.get("$Label.c.LoAp_ReadingCannotCreated")],'error');                              
                            }
                            else if(response.readingId && response.amendListSize > 0){
                                component.set('v.isActive',true);
                                var calculateBillCmp = component.find('calculatePendingBillComponent');
                                calculateBillCmp.calculateBills(function(response) {});
                            }
                            
                            component.find('spinner').hide();   
                        },
                        params);
    },
  
    
    // Reset the selected values to the previous tab
    handleTab: function(component, event, helper){
        component.find('notification').clearNotification();
        component.set('v.selectedRecord',null);
    },
    
    showNotification: function(component, message, type) {
        component.find('notification').showNotification(message, type);
    },
    
    newRecordAdded: function(component) {
        component.find('notification').showNotification([$A.get("$Label.c.LoAp_ReadingCreatedWithBillAmended")],'info');
    },
    
    // close the modal and signal that a new record was added
    handleBillCalculationComplete: function(component, event, helper) {
        component.set('v.isActive',false);
        this.newRecordAdded(component);
    }
})