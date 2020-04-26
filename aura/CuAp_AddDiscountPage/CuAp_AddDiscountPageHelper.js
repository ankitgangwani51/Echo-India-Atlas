({          
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component, event, helper) {  
        
        component.set('v.discount', {'sobjectType' : this.setPrefixedString('Discount__c')});
        component.set('v.discountTypeOld', {'sobjectType' : this.setPrefixedString('DiscountType__c')});
        component.set('v.dummyContract', {'sobjectType' : this.setPrefixedString('BillingContract__c')});
        
        component.set('v.discountType', {'sobjectType': this.setPrefixedString('DiscountType__c')});
        component.set('v.discount', {'sobjectType': this.setPrefixedString('Discount__c')});
        component.set('v.discountTypeOld', {'sobjectType': this.setPrefixedString('DiscountType__c')});          
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component, event, helper) {
        
        component.set('v.discTypeBillToBill',false);
        component.set('v.discType',false);
        component.set('v.discountType', {'sobjectType': this.setPrefixedString('DiscountType__c')});
        component.set('v.discount', {'sobjectType': this.setPrefixedString('Discount__c')});
        component.set('v.discountTypeOld', {'sobjectType': this.setPrefixedString('DiscountType__c')});
        component.set('v.dummyContract', {'sobjectType': this.setPrefixedString('BillingContract__c')});
        component.set('v.selectedConcession',null);
        var wizObj = component.get('v.wizardprop');
        
        var concessionWiz = wizObj.concessions;
        var concession = [];
        if(concessionWiz){
            for(var i=0;i<concessionWiz.length;i++){
                concession.push(concessionWiz[i]);            
            }
        }
        component.set('v.concessions',concession);
        component.set('v.discountType',wizObj.discountType);
        var discountTypeRecord = component.get('v.discountType');

        let params = {"discountType": discountTypeRecord[this.setPrefixedString('Type__c')],
                      "canbeOverridden": discountTypeRecord[this.setPrefixedString('CanbeOverridden__c')],
                      "suppressed": false
                      };

        
        this.callServer(component,'c.retrieveDiscountFields', 
                        function(response) {
                            component.set('v.discountFieldsForGeneric', response);
                        },
                        params);
        
        if(discountTypeRecord[this.setPrefixedString('Type__c')] == $A.get("$Label.c.CuAp_BillToBillDiscount")){
            component.set('v.discTypeBillToBill',true);
        }
        
        if(discountTypeRecord[this.setPrefixedString('Type__c')] == $A.get("$Label.c.CuAp_PercentageDiscount")){
            component.set('v.discType',true);
        }
        
        // Set frequency to 'One Off' when it is blank  
        var frequency = discountTypeRecord[this.setPrefixedString('RecurrenceFrequency__c')];
        if(frequency === undefined  || frequency === '' || frequency === null){
            //var discFreq = component.get('v.discountType');
            discountTypeRecord[this.setPrefixedString('RecurrenceFrequency__c')] = $A.get("$Label.c.CuAp_RecurrFreqOneOffLabel");
            component.set('v.discountType', discountTypeRecord);
        }
        
        //if the discount type can be overriden then check box will be editable
        if (discountTypeRecord[this.setPrefixedString('CanbeOverridden__c')]){
            //component.find("checkboxOverrideDiscount").set("v.isEditable", true);
        }
        
        // when clicked BACK button and the selection is changed on "Select Discount" screen then values previously saved on this screen should get refreshed else not 
        var oldValue = component.get('v.discountTypeOld');
        
        if((oldValue) && (oldValue.Id === component.get('v.discountType.Id')))
        {
            return;
        }
        
        component.set('v.discountTypeOld',wizObj.discountType);
        
        var objDummyContract 	 = component.get('v.dummyContract');
        objDummyContract[this.setPrefixedString('Suppressed__c')] = false;
        component.set('v.dummyContract',objDummyContract);
        
        var objDiscount = component.get('v.discount');
        objDiscount[this.setPrefixedString('OverriddenDiscountPercentage__c')] = '';
        objDiscount[this.setPrefixedString('OverriddenDiscountAmount__c')] = null;
        objDiscount[this.setPrefixedString('OverriddenDailyDiscountAmount__c')] = null;
        objDiscount[this.setPrefixedString('EndDate__c')] = null;
        
        // Set Start Date defaulted to Today's Date 
        var today = new Date();  
        
        objDiscount[this.setPrefixedString('StartDate__c')] = today.getFullYear() + "-" + ("0" + (today.getMonth() + 1)).slice(-2) + "-" + ("0" + today.getDate()).slice(-2);
        component.set('v.discount',objDiscount);
        
    },
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component, event, helper) {
       
        var concessionId 		= null;
        var concessions 		= component.get('v.concessions');
        var discountRecord 		= component.get('v.discount');
        var discountTypeRecord 	= component.get('v.discountType');        
        var sDate 				= discountRecord[this.setPrefixedString('StartDate__c')];
        var eDate 				= discountRecord[this.setPrefixedString('EndDate__c')];
        var discTypeSDate 		= discountTypeRecord[this.setPrefixedString('StartDate__c')];
        var selectedConcession 	= component.get('v.selectedConcession');
        
        // Concession Validation
        if(!selectedConcession && concessions && discountTypeRecord[this.setPrefixedString('Type__c')] == $A.get("$Label.c.CuAp_BillToBillDiscount")){
            this.showNotification(component, [$A.get("$Label.c.CuAp_ConcessionMandatory")], 'error');
            return false;
        }
        
        // Concession Id Assignment
        if(selectedConcession && discountTypeRecord[this.setPrefixedString('Type__c')] == $A.get("$Label.c.CuAp_BillToBillDiscount"))
            concessionId = selectedConcession.Id;
        else
            concessionId = null;
        
        // start date validation
        if(!sDate){
            this.showNotification(component, [$A.get("$Label.c.CuAp_StartDateBlankError")], 'error');
            return false;
        }       
        // end date validation
        if  (eDate && (sDate > eDate || sDate === eDate))  {
			this.showNotification(component, [$A.get("$Label.c.CuAp_EndDateValueError")], 'error');
            return false;
        }
        
        //AT-2107  Discount Start Date lesser than Discount Type Start Date
        if(sDate < discTypeSDate)  {
            this.showNotification(component, [$A.get("$Label.c.CuAp_StartDateBeforeError")], 'error');
            return false; 
        }

        var disPercent 		= discountRecord[this.setPrefixedString('OverriddenDiscountPercentage__c')];
        var disAmount 		= discountRecord[this.setPrefixedString('OverriddenDiscountAmount__c')];
        var disBillToBill 	= discountRecord[this.setPrefixedString('OverriddenDailyDiscountAmount__c')];
        
        if(disPercent > 100){
            this.showNotification(component, [$A.get("$Label.c.CuAp_OverrideDiscountmorethan100")], 'error');
			return false;            
        }
        
        if(discountRecord[this.setPrefixedString('OverriddenDiscountPercentage__c')] === "") disPercent = null;
        if(discountRecord[this.setPrefixedString('OverriddenDiscountAmount__c')] === "") disAmount = null;
        if(discountRecord[this.setPrefixedString('OverriddenDailyDiscountAmount__c')] === "") disBillToBill = null;
        
        var wizObj = component.get('v.wizardprop');
        component.set('v.DiscountRecordList', {sobjectType: this.setPrefixedString('Discount__c'),
                                               [this.setPrefixedString('EndDate__c')]						: eDate,
                                               [this.setPrefixedString('StartDate__c')]						: sDate,
                                               [this.setPrefixedString('Concession__c')]					: concessionId, 
                                               [this.setPrefixedString('DiscountType__c')]					: discountTypeRecord.Id,
                                               [this.setPrefixedString('BillingContract__c')]				: wizObj.contractId,
                                               [this.setPrefixedString('OverriddenDiscountAmount__c')]		: disAmount,
                                               [this.setPrefixedString('OverriddenDiscountPercentage__c')]	: disPercent,
                                               [this.setPrefixedString('OverriddenDailyDiscountAmount__c')]	: disBillToBill,
                                               [this.setPrefixedString('BaseDiscountAmount__c')]			: discountTypeRecord[this.setPrefixedString('AbsoluteDiscountAmount__c')],
                                               [this.setPrefixedString('BaseDiscountPercentage__c')]		: discountTypeRecord[this.setPrefixedString('PercentageDiscountAmount__c')],
                                               [this.setPrefixedString('BaseDailyDiscountAmount__c')]		: discountTypeRecord[this.setPrefixedString('DiscountPerDay__c')]});
        
        
        wizObj.discount = component.get('v.DiscountRecordList');
        component.set("v.wizardprop",wizObj);
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
    
    /* PAGE SPECIFIC METHOD*/ 
    handleCheckboxValueChange:function(component, event, helper) {
        if(!component.get('v.dummyContract')[this.setPrefixedString('Suppressed__c')]){   
            var objDisc = component.get('v.discount');
            objDisc[this.setPrefixedString('OverriddenDiscountPercentage__c')] = '';
            objDisc[this.setPrefixedString('OverriddenDiscountAmount__c')] = '';
            objDisc[this.setPrefixedString('OverriddenDailyDiscountAmount__c')] = '';
            component.set('v.discount',null);        
            component.set('v.discount',objDisc);            
        }
    },
    
    handleInputChangeEvent  : function(component, event, helper) {
       
        var eventParams = event.getParams();
        
        if(eventParams['fieldName'] == this.setPrefixedString('Suppressed__c')){
            var dispObj = component.get('v.dummyContract');
            
            if(dispObj[this.setPrefixedString('Suppressed__c')]){
               component.set('v.editOrNot', true) ;
            }
            else if(!dispObj[this.setPrefixedString('Suppressed__c')]){
               component.set('v.editOrNot', false) ;
            }
            /*Changes Regarding Security Review*/
            //(dispObj[this.setPrefixedString('Suppressed__c')] == true ? dispObj[this.setPrefixedString('Suppressed__c')] = true : dispObj[this.setPrefixedString('Suppressed__c')] = false);
            component.set('v.dummyContract', dispObj);           
        }   
    }
})