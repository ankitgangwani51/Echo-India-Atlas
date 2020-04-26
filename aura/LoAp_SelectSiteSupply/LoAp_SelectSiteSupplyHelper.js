({
	/* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component, event, helper) {    
           component.set('v.fieldList', []);   
           component.set('v.recordList', []);
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component, event, helper) {
        this.doInit(component, event, helper);
    },  
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component, event, helper) {
        var isValidate = this.validate(component, event, helper);
        if(isValidate)
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
    
    // This method will list down all the site supply records
    doInit: function(component, event, helper){
                
        var wizObj = component.get('v.wizardprop');
        var supplyPointId = wizObj.supplyPointId;
        
        var today = new Date();
        var todaysDate = today.getFullYear() + "-" + ("0" + (today.getMonth() + 1)).slice(-2) + "-" + ("0" + today.getDate()).slice(-2);
        if(wizObj.effectiveEndDate != null) component.set('v.effectiveEndDate',wizObj.effectiveEndDate);
        else component.set('v.effectiveEndDate',todaysDate);
             
        helper.callServer(component,'c.retreiveSiteSupplyFieldList',
                          function(response){
                              console.log('retreiveSiteSupplyFieldList response = '+JSON.stringify(response));
                              component.set('v.fieldList', response);   
                          },      				
                          null);
        
        let params = {
            "supplyPointId": supplyPointId
        };
        
        helper.callServer(component,'c.retreiveSiteSupplyRecordList',
                          function(response){
                              console.log('response = '+JSON.stringify(response));                              
                              component.set('v.recordList', response);
                          },      				
                          params);
        
    },
    
    validate: function(component, event, helper){
        this.clearNotification(component);
        
        var record;
        var checkSelected 		= false;
        var recordList 			= component.get('v.recordList');
        var wizObj 				= component.get('v.wizardprop');
        var effectiveEndDate 	= component.get('v.effectiveEndDate');        
        var siteSuppliesToEnded = [];
        var siteSuppliesToCreate = [];
        var today = new Date();
        var todaysDate = today.getFullYear() + "-" + ("0" + (today.getMonth() + 1)).slice(-2) + "-" + ("0" + today.getDate()).slice(-2);
        if(!effectiveEndDate){
            this.showNotification(component, [$A.get("$Label.c.LoAp_EffectiveEndDateBlank")],'error');
            return false;            
        }
        
        for(var i=0;i<recordList.length;i++){   
            if(recordList[i].isSelected)
                checkSelected = true;
        }
        
        if(!checkSelected){
            this.showNotification(component, [$A.get("$Label.c.LoAp_SelectOneSiteSupply")],'error');
            return false;  
        }
        
        for(var i=0;i<recordList.length;i++){
            var effectiveEndedDate = effectiveEndDate < todaysDate ? recordList[i].objectMap[this.setPrefixedString('SiteSupply__c')][this.setPrefixedString('StartDate__c')] : effectiveEndDate;
            record = {sobjectType: this.setPrefixedString('SiteSupply__c'),
                      Id: recordList[i].uniqueId,
                      [this.setPrefixedString('EndDate__c')]: effectiveEndedDate,
                      [this.setPrefixedString('Ended__c')]: true
                     };    
            
            siteSuppliesToEnded.push(record);
            
            var incrementDate = new Date(effectiveEndDate);
            incrementDate.setDate(incrementDate.getDate() + 1);
            
            if(recordList[i].isSelected != true){
                record = {sobjectType									: 	this.setPrefixedString('SiteSupply__c'),                      
                          [this.setPrefixedString('StartDate__c')]		: 	incrementDate,                          
                          [this.setPrefixedString('SiteSupplyPoint__c')]:	wizObj.supplyPointId,
                          [this.setPrefixedString('SupplyPoint__c')]	:	recordList[i].objectMap[this.setPrefixedString('SiteSupply__c')][this.setPrefixedString('SupplyPoint__c')],
                          'Address'										: 	recordList[i].transformFieldMap[this.setPrefixedString('Location__c')][this.setPrefixedString('Address__c')],
                          'SupplyPointName'								: 	recordList[i].transformFieldMap['Name']['Name'],
                          [this.setPrefixedString('PercentageSplit__c')]:	recordList[i].objectMap[this.setPrefixedString('SiteSupply__c')][this.setPrefixedString('PercentageSplit__c')]};  
                siteSuppliesToCreate.push(record);
            }
        }
        wizObj.siteSuppliesToEnded = siteSuppliesToEnded;
        wizObj.siteSuppliesToCreate = siteSuppliesToCreate;
        wizObj.effectiveEndDate = effectiveEndDate;
        return true;
    }
})