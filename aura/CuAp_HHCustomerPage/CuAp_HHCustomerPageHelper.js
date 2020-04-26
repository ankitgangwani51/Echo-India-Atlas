({
	// get details of HH account and contact on screen.
    getData: function(component, event, helper) {

        //Call method to fetch picklist values for Preferred Contact Method field
        this.getPreferredConMethodOption(component);
        
        //Call method to fetch picklist values for Salutation field
        this.getSalutationOption(component);
        
        component.set("v.manageFields", true);
        let params = {
            "recordId": component.get("v.recordId"),
        };
        this.getFieldProperties(component,event, helper);
        helper.callServer(component, 'c.getHHAccount',
                          function(response) {
                              console.log('response = ' +JSON.stringify(response))
                              var wrapper = response;
                              var wrapperObjAcc = wrapper.objectMap.Account;
                              var wrapperObjCon = wrapper.objectMap.Contact;
                              component.set("v.HHWrapperAccount", wrapperObjAcc);
                              component.set("v.HHWrapperContact", wrapperObjCon);
                          }, params);
        
    },
    

	//used to get field properties.
    getFieldProperties: function(component, event, helper) { 
        this.callServer(component,'c.getHHAccountFieldProps',
                        function(response){
                            console.log('FieldProps============='+JSON.stringify(response));
                            var accountWrapper =response;
                            component.set('v.accountWrapper', response);
                            component.set('v.contactFieldList', accountWrapper.contactList);
                            component.set('v.accountBillingList', accountWrapper.accountBillingList);
                            component.set('v.accountShippingList', accountWrapper.accountShippingList);
                            component.set('v.accountInformationList', accountWrapper.accountInformationList);
                            component.set('v.accountConsiderationList', accountWrapper.accountConsiderationList);
                            component.set('v.accountAddtionalInfoList', accountWrapper.accountAddtionalInfoList);
                        },      				
                        null);
    },    

	// bypass duplicate rule and save account and contact.
    bypassDuplicates: function(component, event, helper) {
        component.set('v.bypassDup',true);
        this.doSave(component,event,helper);
    },

	// save HH Account and Contact.
    doSave: function(component, event, helper) {
        
        //Call method to check for errors
        this.checkError(component,event, helper);
        
        if (component.get("v.isError") == true) {
            return false;
        }
        else{
            var wrapperAccount = component.get("v.HHWrapperAccount");
            var wrapperContact = component.get("v.HHWrapperContact");
            delete wrapperContact.attributes;
            var contactString = JSON.stringify(wrapperContact);
            delete wrapperAccount.attributes;
            var accountString = JSON.stringify(wrapperAccount);
            
            let params = {
                "contactString": contactString,
                "accountString": accountString,
                "recordId": component.get('v.recordId'),
                "allowSaveRec": component.get('v.bypassDup')
            };
            var communities = component.get("v.communities");
            helper.callServer(component, 'c.saveHHAccount',
                              function(response) {
                                  if (response != undefined && response.startsWith('001')) {
                                      component.set('v.isDuplicate',false);
                                      if(communities){//AT-1269
                                          var urlEvent = $A.get("e.force:navigateToURL"); 
                                          urlEvent.setParams({
                                              "url": communities == true ? "/my-account" : '/one/one.app#/sObject/' + response, //
                                              "isredirect": "true"
                                          });
                                          console.log(urlEvent);
                                          console.log(response);
                                          console.log("*** Before Navigating ***");
                                          urlEvent.fire();
                                      }
                                      else {//AT-1269
                                          window.location = '/one/one.app#/sObject/' + response;
                                      }
                                      
                                  }else if (response.includes('Duplicates')) {
                                      component.set('v.isDuplicate',true);
                                      component.set('v.duplicateQuestion',response);
                                  } else {
                                      alert(response);
                                  }
                                  
                              },
                              params);
        }
    },

	//check for errors before saving data.
    checkError: function(component, event, helper) {
        var wrapperAccount = component.get("v.HHWrapperAccount");
        var wrapperContact = component.get("v.HHWrapperContact");
        
        //Get today's date in YYYY-MM-DD format
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1;
        var yyyy = today.getFullYear();
        if(dd<10){
            dd='0'+dd;
        } 
        if(mm<10){
            mm='0'+mm;
        } 
        var today = yyyy+'-'+mm+'-'+dd;
        
        //Display error for First Name required
        if (wrapperContact.FirstName == null || wrapperContact.FirstName == '' || wrapperContact.FirstName == undefined) {
            component.set('v.isError',true);
            component.find('notification').showNotification([$A.get("$Label.c.CuAp_FirstNameRequiredError")],'error');
        }
        else if (wrapperContact.LastName == null || wrapperContact.LastName == '' || wrapperContact.LastName == undefined) {
            //Display error for last name required
            component.set('v.isError',true);
            component.find('notification').showNotification([$A.get("$Label.c.CuAp_LastNameRequiredError")],'error');
        }
        else if(wrapperAccount[this.setPrefixedString('DateofBirth__c')] != null && wrapperAccount[this.setPrefixedString('DateofBirth__c')] != undefined && wrapperAccount[this.setPrefixedString('DateofBirth__c')] > today){
            //Display error for Birth Date cannot be a future date
            component.set('v.isError',true);
            component.find('notification').showNotification([$A.get("$Label.c.CuAp_BirthDateFutureError")],'error');
            
        }
        else{
            //Set isError attribute to false to proceed with data commit
            component.set('v.isError',false);
        }
    },

	// fetch picklist values for Preferred Contact Method field.
    getPreferredConMethodOption: function(component, event, helper) {
        
        var action = component.get("c.preferredContactMethod");
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.preferredContactValues', response.getReturnValue());
            } else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    },

	// refresh the view.
    reloadView: function(component, event, helper) {
        
        console.log("*** After Refreshing ***");
        $A.get('e.force:refreshView').fire();
    },

	// fetch picklist values for Salutation field.
    getSalutationOption: function(component, event, helper) {
        
        var action = component.get("c.salutationValues");
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.salutationValues', response.getReturnValue());
            } else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    },

	// close the modal box.
    closeModal: function(component, event, helper) {
        
        component.set("v.manageFields", false);
        var communities = component.get("v.communities");
        if(communities == true){
            $A.get("e.force:navigateToURL").setParams({
                "url": "/my-account",
                isredirect: true
            }).fire();
        }else{
            if (component.get('v.recordId') == null) {
                if ((component.get('v.recordTypeName') != null || component.get('v.recordTypeName') != undefined) && component.get('v.recordTypeName') == $A.get("$Label.c.CuAp_ContactRecordTypeHouseholdContact")) {
                    window.history.go(-2);
                } else {
                    window.history.back();
                }
            } else {
                window.history.go(-2);
            }
        }
    }
})