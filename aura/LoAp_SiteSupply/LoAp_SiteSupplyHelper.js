({
    // On page load assign vlaues in attributes by calling server.
    doInit : function(component, event, helper) {
        let params = {"supplyPointId": component.get('v.recordId')}; 
        var wrappers = component.get('v.addMoreInfoList');
        
        var supplyPointLookupFlds = 'Id, Name,' + this.setPrefixedString('Location__c') ;
        component.set("v.customLookUpSP",supplyPointLookupFlds);
        
        this.callServer(component,'c.getInfoToDisplay',function(response) {
            console.log('getInfoToDisplay-response=> ' + JSON.stringify(response)) ;
            component.set("v.isShowButton",response.isShowCmp);
            component.set("v.recordList", response.fieldPropList);
            component.set("v.objSiteSupply", response.objSP);
            component.set("v.newAddInfoList", response.siteSupplyWrap);
            console.log('getInfoToDisplay-response.siteSupplyWrap=> ' + JSON.stringify(response.siteSupplyWrap)) ;
            var newList = [];
            for (var j = 0; j < response.siteSupplyWrap.length; j++) { 
                var objSiteSupply =  {'sobjectType':this.setPrefixedString('SiteSupply__c'),
                                      ['SiteSupplyId'] 	: response.siteSupplyWrap[j].SiteSupplyId,
                                      'objSupplyPoint' 	: response.siteSupplyWrap[j].objSupplyPoint,
                                      [this.setPrefixedString('StartDate__c')] : response.siteSupplyWrap[j].startDate,
                                      [this.setPrefixedString('EndDate__c')] : response.siteSupplyWrap[j].endDate,	//EndDate
                                      [this.setPrefixedString('PercentageSplit__c')] 	: response.siteSupplyWrap[j].strPercentageSplit,
                                      ['strLocationName'] 	: response.siteSupplyWrap[j].strLocationName,
                                      ['strStatus'] 	   : response.siteSupplyWrap[j].strStatus};
                newList.push(objSiteSupply);
            }
            component.set("v.addMoreInfoList",newList);
            component.set('v.PercentageWarningPopup',false); 
            component.set("v.percentageWarningAccepted",false);
        }, params);     
    },
    // Method is used to active component or open modal box.
    doActive : function(component, event, helper) {
        component.set('v.isActive', true);      
        this.doInit(component, event, helper);
    },
    // Method is used to close component or open modal box.
    doCancel : function(component, event, helper) {
        component.set('v.isActive', false); 
        component.set('v.addMoreInfoList', []);
        
    },
    // Validate Page Before Save.
    checkValidation : function(component, event, helper) {
        this.clearNotification(component);
        var atleastOneBillingContract = false;
        var addMoreInfoList = component.get('v.addMoreInfoList');
        if(addMoreInfoList.length > 0){
            var isValidRow = true;
            var percentageSplit = 0;
            var checkDuplicateSupplyPoint = [];
            var firstDateValue = true;
            var index = i;
            var firstDate;
            for (var i = 0; i < addMoreInfoList.length; i++) { 
                if(addMoreInfoList[i].strLocationName == '') {
                    this.showNotification(component, [$A.get("$Label.c.LoAp_InvalidSupplyPoint")], 'error');
                    return false;;
                }
                
                if(!addMoreInfoList[i][this.setPrefixedString('StartDate__c')]) {
                    this.showNotification(component,[$A.get("$Label.c.LoAp_InvalidStartDate")], 'error');
                    return false;;
                }
                
                if(firstDateValue) {
                    firstDate = addMoreInfoList[i][this.setPrefixedString('StartDate__c')];
                    firstDateValue = false;
                    index =  i;
                }
                if(index != i && addMoreInfoList[i][this.setPrefixedString('StartDate__c')] != firstDate ) {
                    this.showNotification(component,[$A.get("$Label.c.LoAp_StartDateNotSame")], 'error');
                    return false;;
                }
            
                if(!addMoreInfoList[i][this.setPrefixedString('PercentageSplit__c')]) {
                    this.showNotification(component,[$A.get("$Label.c.LoAp_InvalidPercSplit")], 'error');
                     return false;; 
                }
                percentageSplit = percentageSplit + addMoreInfoList[i][this.setPrefixedString('PercentageSplit__c')];
                checkDuplicateSupplyPoint.push(addMoreInfoList[i].objSupplyPoint.Id);  
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
       return  isValidRow ;
       
    },
    // call the notifier method to show a message on the notification component on the wizard
    showNotification: function(component, message, type) {
        component.find('notification').showNotification(message, type);
    },
    
    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
        component.find('notification').clearNotification();
    },
    
    doAcceptQuestion: function(component, event, helper) {
        component.set('v.PercentageWarningPopup',false);  
        component.set("v.percentageWarningAccepted",true); 
        this.doSave(component, event, helper);
    },
    
    doCancelQuestion: function(component, event, helper) {
        component.set('v.PercentageWarningPopup',false); 
        component.set("v.percentageWarningAccepted",false);
    }, 
    
   // Method is used to save the split payment records 
    doSave : function(component, event, helper) {
        if(!this.checkValidation(component, event, helper))
            return false;
        var addMoreInfoObj = component.get('v.addMoreInfoList');
        var existingList = [];
        var newList = [];
        for (var j = 0; j < addMoreInfoObj.length; j++) { 
            if(addMoreInfoObj[j].strStatus ==  $A.get('$Label.c.LoAp_SiteSupplyExistingRecord')) {
                var objSiteSupplyExisting =  {'sobjectType':this.setPrefixedString('SiteSupply__c'),
                                              [this.setPrefixedString('SiteSupplyPoint__c')] 	: component.get('v.recordId'),
                                              ['Id'] 	: addMoreInfoObj[j].SiteSupplyId,
                                              [this.setPrefixedString('SupplyPoint__c')] : addMoreInfoObj[j].objSupplyPoint.Id,
                                              [this.setPrefixedString('StartDate__c')] 	: addMoreInfoObj[j][this.setPrefixedString('StartDate__c')] ,
                                              [this.setPrefixedString('EndDate__c')] 	: addMoreInfoObj[j][this.setPrefixedString('EndDate__c')] , //EndDate
                                              [this.setPrefixedString('PercentageSplit__c')] 	: addMoreInfoObj[j][this.setPrefixedString('PercentageSplit__c')]};
                
                
                existingList.push(objSiteSupplyExisting);
            }
            if(addMoreInfoObj[j].strStatus ==   $A.get('$Label.c.LoAp_SiteSupplyNewRecord')  && addMoreInfoObj[j].objSupplyPoint != null) {
                var objSiteSupplyNew =  {'sobjectType':this.setPrefixedString('SiteSupply__c'),
                                         [this.setPrefixedString('SiteSupplyPoint__c')] 	: component.get('v.recordId'),
                                         [this.setPrefixedString('SupplyPoint__c')] : addMoreInfoObj[j].objSupplyPoint.Id,
                                         [this.setPrefixedString('StartDate__c')] 	:    addMoreInfoObj[j][this.setPrefixedString('StartDate__c')] ,
                                         [this.setPrefixedString('EndDate__c')] 	: addMoreInfoObj[j][this.setPrefixedString('EndDate__c')] , //EndDate
                                         [this.setPrefixedString('PercentageSplit__c')] 	: addMoreInfoObj[j][this.setPrefixedString('PercentageSplit__c')]};
                
                newList.push(objSiteSupplyNew);
            }
        }
      
        component.set("v.existingRecordsList",existingList);
        component.set("v.newRecordsList",newList);
        console.log('newRecordsList=> ' + JSON.stringify(component.get("v.newRecordsList"))) ;
        console.log('existingRecordsList=> ' + JSON.stringify(component.get("v.existingRecordsList"))) ;
        console.log('removedSiteSupplyList=> ' + JSON.stringify(component.get("v.removedSiteSupplyList"))) ;
        
        let params = {
            'newRecords' : JSON.stringify(component.get("v.newRecordsList")),
            'existingRecords': JSON.stringify(component.get("v.existingRecordsList")),
            'removedRecords' : JSON.stringify(component.get("v.removedSiteSupplyList"))
        };
        
        this.callServer(component,'c.ProcessSiteSupply',function(response) {
            if(response.isSuccess){
                if(response.siteSupplyContractlist != null) {
                    component.set('v.newListOfContractId', response.siteSupplyContractlist);
                    var calculateBillCmp = component.find('calculatePendingBillComponent');
                    calculateBillCmp.calculateBills(function(response) {});
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "message": $A.get('$Label.c.LoAp_SiteSupplyRecordsCreated')
                    });    
                    component.find('spinner').hide();   
                }
                else {
                    this.handleError(component, response) ;                
                }
            }
        }, params);
    },
    
    handleError : function(component, response) {
        var errorMessage = [] ;
        errorMessage.push(response.getError()[0].message) ;
        this.showNotification(component, errorMessage, 'error') ;
    },
    
    // function for delete the row
    removeRow : function(component, event, helper){
        var index = event.currentTarget.parentElement.parentElement.cells[0].innerHTML;
        console.log('index=> ' +  typeof index) ;
        // get the all List (addMoreInfoList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.addMoreInfoList");
        if(AllRowsList[index-1].objSupplyPoint  != null ) {
            var deleteRecordList = [];
            if(AllRowsList[index-1].strStatus ==    $A.get('$Label.c.LoAp_SiteSupplyExistingRecord')) {
                if(component.get("v.removedSiteSupplyList") == ''){
                    deleteRecordList.push(AllRowsList[index-1].SiteSupplyId);                    
                }else{
                    deleteRecordList.push(AllRowsList[index-1].SiteSupplyId);
                    var getDeleteRecordList1 = [];
                    getDeleteRecordList1 = component.get("v.removedSiteSupplyList");
                    
                    for(var k = 0;k<getDeleteRecordList1.length;k++){
                        deleteRecordList.push(getDeleteRecordList1[k]);
                    }
                }
                component.set("v.removedSiteSupplyList",deleteRecordList);
            }
        }
        AllRowsList.splice(parseInt(index-1), 1);
        // set the addMoreInfoList after remove selected row element  
        component.set("v.addMoreInfoList", AllRowsList);
    } , 
    
    // add a biller row to the table
    addRow: function(component) {
        // check for a blank row
        var addMoreInfoObj = component.get('v.addMoreInfoList');
        var blankRow = false;
        for (var i = 0; i < addMoreInfoObj.length; i++) { 
            if (!(addMoreInfoObj[i].objSupplyPoint  && addMoreInfoObj[i].objSupplyPoint.Id)) {
                blankRow = true;
                break;
            }
        }
        // add a new row if not already a blank row
        if (!blankRow) {
            this.callServer(component, 'c.AddMoreRows', function(response) {
                var wrappers = component.get('v.addMoreInfoList');
                wrappers.push(response);
                component.set('v.addMoreInfoList', wrappers);
            },null);
        }
        console.log('addRow-addMoreInfoList=> ' + JSON.stringify(component.get('v.addMoreInfoList'))) ;
    },
    
    splitPercentage: function(component) {
        var addMoreInfoObj = component.get('v.addMoreInfoList');
        var splitPercentageList = [];
        for (var i = 0; i < addMoreInfoObj.length; i++) {
            addMoreInfoObj[i][this.setPrefixedString('PercentageSplit__c')]  = (100 / addMoreInfoObj.length).toFixed(2); 
            splitPercentageList.push(addMoreInfoObj[i]);
        }
        component.set('v.addMoreInfoList',"");
        component.set('v.addMoreInfoList',splitPercentageList);
    },
    
    // Handle custom look up change event.
    handleCustomLookUpEvent: function(component, event, helper) {
        this.assignLocationAddressInList(component, event, helper);
        
    },
    // Set account Name on select of contract.
    assignLocationAddressInList: function(component, event, helper) {	
        var objectValue = event.getParam("objectVal");
        var addMoreInfoObj = component.get('v.addMoreInfoList');
        
        for (var i = 0; i < addMoreInfoObj.length; i++) { 
            if (addMoreInfoObj[i].objSupplyPoint && addMoreInfoObj[i].objSupplyPoint.Id) {
                if(addMoreInfoObj[i].objSupplyPoint.Id == objectValue.Id)  {
                    if(addMoreInfoObj[i].objSupplyPoint[this.setPrefixedString('Location__c')]){
                        let params = {"locationId": addMoreInfoObj[i].objSupplyPoint[this.setPrefixedString('Location__c')]};   
                        this.callServer(component,'c.getAccountNameById',function(response) {
                            addMoreInfoObj[i-1].strLocationName = response;
                            component.set('v.addMoreInfoList', addMoreInfoObj);
                        }, params);
                    }
                }
            }
        }
    },
    // Handle input change event of amount field.
    handleInputChangeEvent:function(component, event, helper) {
        var eventParams = event.getParams();
    },
    // show toast message and return
    showToast: function(result) {    	 	
        var message = result;
        if (message) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title":  $A.get("$Label.c.GuAp_SuccessTitle"),
                "type": $A.get("$Label.c.GlAp_Success"),
                "message": message 
            });
            toastEvent.fire();
        }      
    },  
    handleBillCalculationComplete: function(component, event, helper) {
        this.doCancel(component, event, helper) ;
    },
})