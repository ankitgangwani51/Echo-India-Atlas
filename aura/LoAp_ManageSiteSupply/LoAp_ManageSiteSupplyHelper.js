({
	/* Required By Framework - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component, event, helper) {     
        component.set('v.recordList',[]);
        component.set('v.removedSiteSupplyList',[]);
        
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component, event, helper) {  
        this.doInit(component, event, helper);
    },  
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component, event, helper) {
        var isValidate = helper.checkValidation(component, event, helper);
        if(isValidate){
            var isDataStored = helper.doSave(component, event, helper);                
            return isDataStored;
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
    
    // method is used to dipslay the popup when percentage split is in between 99-100
    doAcceptQuestion: function(component, event, helper) {
        component.set('v.PercentageWarningPopup',false);  
        helper.doSave(component, event, helper);
        var cmpEvent = component.getEvent("refreshEvent");
        cmpEvent.fire();
    },
    
    // method is used to close the popup appears for percentage split message
    doCancelQuestion: function(component, event, helper) {
        component.set('v.PercentageWarningPopup',false); 
    }, 
    
    // method is used to structure the data select from the screen to be processed in wizard controller
    doSave: function(component, event, helper){
        var wizObj = component.get('v.wizardprop');
        var recordList = component.get('v.recordList');                
        var removedSiteSupplyList = component.get('v.removedSiteSupplyList');
        if(wizObj.wizardType == $A.get("$Label.c.LoAp_isAmend") && removedSiteSupplyList.length > 0){
            var ssInvalids = [];
            for(var i=0;i<removedSiteSupplyList.length;i++){
                var ssInvalid =  {'sobjectType':this.setPrefixedString('SiteSupply__c'),
                                  ['Id'] : removedSiteSupplyList[i],
                                  [this.setPrefixedString('Invalid__c')] : true};
                ssInvalids.push(ssInvalid);
            }
            wizObj.siteSuppliesToInvalid = ssInvalids;
        }
        
        var ssToCreateAddRows = [];
        var ssExistingSfRecords = [];
        var effectiveStartDate = component.get('v.effectiveStartDate');
        for(var i=0;i<recordList.length;i++){
            if(wizObj.wizardType == $A.get("$Label.c.LoAp_isAmend")){
                if(recordList[i].recordType == $A.get("$Label.c.LoAp_SiteSupplyNewRecord")){
                    var ssToCreateAddRow =  {'sobjectType':this.setPrefixedString('SiteSupply__c'),
                                             [this.setPrefixedString('SiteSupplyPoint__c')]	: wizObj.supplyPointId,
                                             [this.setPrefixedString('StartDate__c')]		: effectiveStartDate,
                                             [this.setPrefixedString('PercentageSplit__c')]	: recordList[i].PercentageSplit,
                                             [this.setPrefixedString('SupplyPoint__c')] 	: recordList[i].objSupplyPoint.Id};
                    ssToCreateAddRows.push(ssToCreateAddRow);
                }else{
                    var ssExistingSfRecord = {'sobjectType':this.setPrefixedString('SiteSupply__c'),
                                              ['Id'] : recordList[i].SiteSupplyId,
                                              [this.setPrefixedString('SiteSupplyPoint__c')]	: wizObj.supplyPointId,
                                              [this.setPrefixedString('StartDate__c')]			: effectiveStartDate,
                                              [this.setPrefixedString('PercentageSplit__c')]	: recordList[i].PercentageSplit,
                                              [this.setPrefixedString('SupplyPoint__c')] 		: recordList[i].objSupplyPoint.Id};
                    ssExistingSfRecords.push(ssExistingSfRecord);
                }
                
            }else{//when End operation
                var startDate = new Date(recordList[i].startDate);
                var day = startDate.getDate();
                var month_index = startDate.getMonth() + 1;
                var year = startDate.getFullYear();
                startDate = year + "-" + month_index + "-" + day;
                
                var ssToCreateAddRow =  {'sobjectType':this.setPrefixedString('SiteSupply__c'),
                                         [this.setPrefixedString('SiteSupplyPoint__c')]	: wizObj.supplyPointId,
                                         [this.setPrefixedString('StartDate__c')]		: startDate,
                                         [this.setPrefixedString('PercentageSplit__c')]	: recordList[i].PercentageSplit,
                                         [this.setPrefixedString('SupplyPoint__c')] 	: recordList[i].objSupplyPoint.Id};
                ssToCreateAddRows.push(ssToCreateAddRow);
            }
        }        
        wizObj.siteSupplyToCreateAddRows = ssToCreateAddRows;
        wizObj.siteSupplyToAmendCreate = ssExistingSfRecords;
        wizObj.siteSuppliesToCreate = [];
        return true;
    },

    // method is used to display existing records of site supply
    doInit: function(component, event, helper){
        var month_names =["Jan","Feb","Mar",
                          "Apr","May","Jun",
                          "Jul","Aug","Sep",
                          "Oct","Nov","Dec"];
        component.set('v.PercentageWarningPopup',false); 
        component.set("v.percentageWarningAccepted",false);
        var supplyPointLookupFlds = 'Id, Name,' + this.setPrefixedString('Location__c') ;
        component.set("v.customLookUpSP",supplyPointLookupFlds);
        
        var wizObj = component.get('v.wizardprop');
        
        if(wizObj.wizardType == $A.get("$Label.c.LoAp_isEnd")){
            component.set('v.isStartDate',false);
            if(wizObj.siteSuppliesToCreate != null){
                var siteSupplyInstanceList = [];
                for (var j = 0; j < wizObj.siteSuppliesToCreate.length; j++) { 
                    var startDate = wizObj.siteSuppliesToCreate[j][this.setPrefixedString('StartDate__c')];
                    
                    var day = startDate.getDate();
                    var month_index = startDate.getMonth();
                    var year = startDate.getFullYear();
                    startDate = day + "-" + month_names[month_index] + "-" + year;
                    var objSiteSupply =  {'sobjectType':this.setPrefixedString('SiteSupply__c'),
                                          'SiteSupplyId'	: null,
                                          'objSupplyPoint'	: {"Id" : wizObj.siteSuppliesToCreate[j][this.setPrefixedString('SupplyPoint__c')],
                                                               "Name" : wizObj.siteSuppliesToCreate[j].SupplyPointName},                                      
                                          'strLocationName'	: wizObj.siteSuppliesToCreate[j]['Address'],
                                          'SiteSupplyPoint'	: wizObj.siteSuppliesToCreate[j][this.setPrefixedString('SiteSupplyPoint__c')],
                                          'startDate' 		: startDate,
                                          'PercentageSplit'	: wizObj.siteSuppliesToCreate[j][this.setPrefixedString('PercentageSplit__c')],
                                          'recordType' 		: $A.get("$Label.c.LoAp_SiteSupplyExistingRecord"),
                                          'recordIdType'	: $A.get("$Label.c.LoAp_SiteSupplyExternal")};
                    siteSupplyInstanceList.push(objSiteSupply);
                }
                component.set('v.recordList',siteSupplyInstanceList);
            } 
        }else{
            
            component.set('v.isStartDate',true);
            var today = new Date();
            var todaysDate = today.getFullYear() + "-" + ("0" + (today.getMonth() + 1)).slice(-2) + "-" + ("0" + today.getDate()).slice(-2);
            component.set('v.effectiveStartDate',todaysDate);
            
            var siteSupplyExistingList = [];
            var supplyPointId = wizObj.supplyPointId;
            
            let params = {
                "supplyPointId": supplyPointId
            };
            this.callServer(component, 'c.retreiveSiteSupplyRecordList', function(response) {
                for(var i=0;i<response.length;i++){
                    var existingSiteSupply =  {'sobjectType'	:this.setPrefixedString('SiteSupply__c'),
                                               'SiteSupplyId'	: response[i].SiteSupplyId,
                                               'objSupplyPoint'	: response[i].objSupplyPoint,                                      
                                               'strLocationName': response[i].strLocationName,
                                               'SiteSupplyPoint': wizObj.supplyPointId,
                                               'startDate' 		: response[i].startDate,
                                               'PercentageSplit': response[i].strPercentageSplit,
                                               'recordType' 	: response[i].recordType,
                                               'recordIdType'	: response[i].recordIdType};
                    siteSupplyExistingList.push(existingSiteSupply);
                }
                component.set('v.recordList',siteSupplyExistingList);
            },params);
            
        }
    }, 
    
    // method is used to validate all the site supply records based on the requirement
    checkValidation: function(component, event, helper){
        this.clearNotification(component);
        var isValidRow = true;        
        var effectiveStartDate = component.get('v.effectiveStartDate');
        var isStartDate = component.get('v.isStartDate');
        var wizObj = component.get('v.wizardprop');
        if(isStartDate && !effectiveStartDate){
            this.showNotification(component, [$A.get("$Label.c.LoAp_EffectiveStartDateBlank")], 'error');
            return false;
        }
        var recordList = component.get('v.recordList');
        if(recordList.length > 0){
            var checkDuplicateSupplyPoint = [];
            
            var percentageSplit = 0;
            for (var i = 0; i < recordList.length; i++) { 
                if(!recordList[i].objSupplyPoint || (recordList[i].objSupplyPoint && !recordList[i].objSupplyPoint.Id)) {
                    this.showNotification(component, [$A.get("$Label.c.LoAp_InvalidSupplyPoint")], 'error');
                    return false;
                }
                
                if(!recordList[i]['PercentageSplit']) {
                    this.showNotification(component,[$A.get("$Label.c.LoAp_InvalidPercSplit")], 'error');
                    return false;; 
                }
                percentageSplit = percentageSplit + recordList[i]['PercentageSplit'];
                checkDuplicateSupplyPoint.push(recordList[i].objSupplyPoint.Id);  
            }
            
            var dupFound = false;
            for (var i = 0; i < checkDuplicateSupplyPoint.length; i++) {
                for (var j = i; j < checkDuplicateSupplyPoint.length; j++) {
                    if (i != j && checkDuplicateSupplyPoint[i] == checkDuplicateSupplyPoint[j])
                        dupFound = true;
                }
            }
            
            if(dupFound) {
                this.showNotification(component, [$A.get("$Label.c.LoAp_SupplyPointExist")], 'error');
                return false;;   
            }
            
            if(percentageSplit > 100 || percentageSplit < 99 ) { 
                this.showNotification(component, [$A.get("$Label.c.LoAp_PercSplitLimit")], 'error'); 
                return false;
            }
            
            if(percentageSplit < 100 && percentageSplit >= 99 ) {
                var percentageWarningAccepted  =  component.get('v.percentageWarningAccepted');
                
                if(percentageWarningAccepted)
                    isValidRow = true; 
                else {
                    component.set("v.PercentageWarningPopup",true); 
                    isValidRow = false;
                }       
            }
        }
        return isValidRow;
        
    },
    
    // mehid is used to create a new row instance for site supply record
    addMoreRows: function(component, event, helper){
        var recordList = component.get('v.recordList');
        var rowAdded = false;
        var wizObj = component.get('v.wizardprop');
        for (var i = 0; i < recordList.length; i++) {
            if(recordList[i].objSupplyPoint != null && recordList[i].objSupplyPoint.Id == null){
                rowAdded = true;
                break;
            }
        }   
        
        var effectiveEndDate = wizObj.effectiveEndDate;
        var incrementDate = new Date(effectiveEndDate);
        incrementDate.setDate(incrementDate.getDate() + 1);  
        if(wizObj.wizardType == $A.get("$Label.c.LoAp_isAmend"))
            incrementDate = null;
        if (!rowAdded) {   
            let params = {
                "startDate": incrementDate
            };
            this.callServer(component, 'c.AddMoreRows', function(response) {
                var wrappers = component.get('v.recordList');
                wrappers.push(response);
                component.set('v.recordList', wrappers);
            },params);
        }        
    },
    
    // method is used to auto populate the address based on select supply point
    handleCustomLookUpEvent: function(component, event, helper){
        var objectValue = event.getParam("objectVal");
        var recordList = component.get('v.recordList');
        
        for (var i = 0; i < recordList.length; i++) { 
            if (recordList[i].objSupplyPoint && recordList[i].objSupplyPoint.Id) {
                if(recordList[i].objSupplyPoint.Id == objectValue.Id)  {
                    if(recordList[i].objSupplyPoint[this.setPrefixedString('Location__c')]){
                        let params = {"locationId": recordList[i].objSupplyPoint[this.setPrefixedString('Location__c')]};   
                        this.callServer(component,'c.getAddressFromLocation',function(response) {                            
                            for (var j = 0; j < recordList.length; j++) {
                                if (recordList[j].objSupplyPoint && recordList[j].objSupplyPoint.Id) {
                                    if(recordList[j].objSupplyPoint.Id == objectValue.Id && recordList[j].objSupplyPoint[this.setPrefixedString('Location__c')]){
                                        var locId = recordList[j].objSupplyPoint[this.setPrefixedString('Location__c')];
                                        if(locId && locId == response.locationId){
                                            recordList[j].strLocationName = response.address;
                                        }
                                    }
                                }
                            }
                            component.set('v.recordList', []);
                            component.set('v.recordList', recordList);
                        }, params);
                    }
                }
            }
        }
        
    },
    
    // method is used to split percentage to 100 
    splitPercentage: function(component, event, helper) {
        var recordList = component.get('v.recordList');
        var splitPercentageList = [];
        for (var i = 0; i < recordList.length; i++) {
            recordList[i]['PercentageSplit']  = (100 / recordList.length).toFixed(2); 
            splitPercentageList.push(recordList[i]);
        }
        component.set('v.recordList',"");
        component.set('v.recordList',splitPercentageList);
    },
    
    // method is used to remove the site supply record from the displayed list
    removeRow : function(component, event, helper){
        var index = event.currentTarget.parentElement.parentElement.cells[0].innerHTML;
        var recordList = component.get("v.recordList");
        if(recordList[index-1].objSupplyPoint != null ) {
            var deleteRecordList = [];
            if(recordList[index-1].recordIdType = $A.get("$Label.c.LoAp_SiteSupplyInternal")){
                if(component.get("v.removedSiteSupplyList") == '' || component.get('v.removedSiteSupplyList') == undefined){
                    deleteRecordList.push(recordList[index-1].SiteSupplyId);                    
                }else{
                    deleteRecordList.push(recordList[index-1].SiteSupplyId);
                    var getDeleteRecordList1 = [];
                    getDeleteRecordList1 = component.get("v.removedSiteSupplyList");
                    
                    for(var k = 0;k<getDeleteRecordList1.length;k++){
                        deleteRecordList.push(getDeleteRecordList1[k]);
                    }
                }
                component.set("v.removedSiteSupplyList",deleteRecordList);
            }
        }
        recordList.splice(parseInt(index-1), 1);
        component.set("v.recordList", recordList);
    }, 
})