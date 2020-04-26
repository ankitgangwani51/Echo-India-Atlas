({
    //intialize all the details when entering in the component
    doInit : function(component, event, helper) {
        component.set('v.accountRecord', {'sobjectType':this.setPrefixedString('Account')});
        var action = component.get("c.getRecordTypeName");
        action.setCallback(this, function(response) {
            var recTypeName  = response.getReturnValue();
            component.set("v.recordType",recTypeName);
            //fetching the account field properties
            this.getAccountFieldsProps(component, helper) ;
            //fetching the account records
            this.getAccountRecord(component, helper) ;
        });
        $A.enqueueAction(action);
    } ,
    
    //opening the edit page when clicked on edit button
    editMode : function(component) {
        var recId = component.get("v.accountId");  
        var recTypeName  = component.get("v.recordType");
        
        //redirect to custom HH page if record type is household
        if(recTypeName == $A.get("$Label.c.AccAp_AccountRecordTypeHouseholdAccount")){
            component.set('v.showEditPage',true);
            //creating the CuAp_HHCustomerPage edit page
            $A.createComponent(
                "c:CuAp_HHCustomerPage",
                {
                    "manageFields": true,
                    "recordId": recId,
                    "headerValue": $A.get("$Label.c.CuAp_HHAccountEdit"),
                    "communities": true
                },
                function(newCmp){
                    if (component.isValid()) {
                        component.set("v.body", newCmp);
                    };                        
                });
        }
        else{
            component.set('v.showEditPage',true);
            //creating the CuAp_NonHHCustomerPage edit page
            $A.createComponent(
                "c:CuAp_NonHHCustomerEdit",
                {
                    "recordId": recId,
                    "headerValue": "Edit Account",
                    "communities": true
                },
                function(newCmp){
                    if (component.isValid()) {
                        component.set("v.body", newCmp);
                    };                        
                });
            
        }
    } ,
    
    //fetching the account information field properties
    getAccountFieldsProps : function(component, helper) {
        helper.callServer(component, 'c.getAccountFieldsProps', 
                          function(response){
                              if(response) {
                                  component.set("v.accountFieldsList", response) ;
                              }
                          }, 
                          null) ;
        this.getAccountAddressFieldsProps(component, helper);
    } ,
    
    //fetching the account address information field properties
    getAccountAddressFieldsProps : function(component, helper) {
        helper.callServer(component, 'c.getAccountAddressFieldsProps', 
                          function(response){
                              if(response) {
                                  component.set("v.accountAddressFieldsList", response) ;
                              }
                          }, 
                          null) ;
        var recordType = component.get("v.recordType");
        if(recordType == $A.get("$Label.c.AccAp_AccountRecordTypeHouseholdAccount")){
            this.getAccountContactFieldsProps(component, helper);
        }else{
            this.getAccountSicFieldsProps(component, helper);
        }
    } ,
    
    //fetching the account contact information field properties
    getAccountContactFieldsProps : function(component, helper) {
        helper.callServer(component, 'c.getAccountContactFieldsProps', 
                          function(response){
                              if(response) {
                                  component.set("v.accountContactFieldsList", response) ;
                              }
                          }, 
                          null) ;
        this.getAccountConsiderationFieldsProps(component, helper);
    } ,
    
    //fetching the account sic information field properties
    getAccountSicFieldsProps : function(component, helper) {
        helper.callServer(component, 'c.getAccountSicFieldsProps', 
                          function(response){
                              if(response) {
                                  component.set("v.accountSicFieldsList", response) ;
                              }
                          }, 
                          null) ;
        this.getAccountConsiderationFieldsProps(component, helper);
    } ,
    
    //fetching the account consideration information field properties
    getAccountConsiderationFieldsProps : function(component, helper) {
        helper.callServer(component, 'c.getAccountConsiderationFieldsProps', 
                          function(response){
                              if(response) {
                                  component.set("v.accountConsiderationFieldsList", response) ;
                              }
                          }, 
                          null) ;
        this.getAccountAdditionalFieldsProps(component, helper);
    } ,
    
    //fetching the account additional information field properties
    getAccountAdditionalFieldsProps : function(component, helper) {
        helper.callServer(component, 'c.getAccountAdditionalFieldsProps', 
                          function(response){
                              if(response) {
                                  component.set("v.accountAdditionalFieldsList", response) ;
                              }
                          }, 
                          null) ;
    } ,
    
    //fetching the account information records
    getAccountRecord : function(component, helper) {
        helper.callServer(component, 'c.getMyAccountDetails', 
                          function(response){
                              if(response) {
                                  component.set("v.accountRecord", response) ;
                                  component.set("v.accountId", response.Id) ;
                              }
                          }, 
                          null) ;
        this.getAccountAddressRecord(component, helper);
    } ,
    
    //fetching the account address information records
    getAccountAddressRecord : function(component, helper) {
        helper.callServer(component, 'c.getMyAccountAddressDetails', 
                          function(response){
                              if(response) {
                                  var billingCount = 0;
                                  var shippingCount = 0;
                                  //binding all the field of billing and shipping address in one billing and one shipping address field
                                  for(var key in response){
                                      if(key.includes($A.get("$Label.c.CmAp_MyAccountBillingField"))){ 
                                          if(billingCount == 0){
                                              response[$A.get("$Label.c.CmAp_MyAccountBillingFieldLabel")] = response[key];
                                              billingCount = billingCount + 1;
                                          }else{
                                              response[$A.get("$Label.c.CmAp_MyAccountBillingFieldLabel")] = response[$A.get("$Label.c.CmAp_MyAccountBillingFieldLabel")] + ', ' + response[key];
                                          }
                                      }
                                      if(key.includes($A.get("$Label.c.CmAp_MyAccountShippingField"))){                                
                                          if(shippingCount == 0){
                                              response[$A.get("$Label.c.CmAp_MyAccountShippingFieldLabel")] = response[key];
                                              shippingCount = shippingCount + 1;
                                          }else{
                                              response[$A.get("$Label.c.CmAp_MyAccountShippingFieldLabel")] = response[$A.get("$Label.c.CmAp_MyAccountShippingFieldLabel")] + ', ' + response[key];
                                          }
                                      }
                                  }
                                  component.set("v.accountAddressRecord", response) ;
                              }
                          }, 
                          null) ;
        var recordType = component.get("v.recordType");
        if(recordType == $A.get("$Label.c.AccAp_AccountRecordTypeHouseholdAccount")){
            this.getAccountContactRecord(component, helper);
        }else{
            this.getAccountSicRecord(component, helper);
        }
    } ,
    
    //fetching the account contact information records
    getAccountContactRecord : function(component, helper) {
        helper.callServer(component, 'c.getMyAccountContactDetails', 
                          function(response){
                              if(response) {
                                  component.set("v.accountContactRecord", response) ;
                              }
                          }, 
                          null) ;
        this.getAccountConsiderationRecord(component, helper);
    } ,
    
    //fetching the account sic information records
    getAccountSicRecord : function(component, helper) {
        helper.callServer(component, 'c.getMyAccountSicDetails', 
                          function(response){
                              if(response) {
                                  component.set("v.accountSicRecord", response) ;
                              }
                          }, 
                          null) ;
        this.getAccountConsiderationRecord(component, helper);
    } ,
    
    //fetching the account consideration information records
    getAccountConsiderationRecord : function(component, helper) {
        helper.callServer(component, 'c.getMyAccountConsiderationDetails', 
                          function(response){
                              if(response) {
                                  component.set("v.accountConsiderationRecord", response) ;
                              }
                          }, 
                          null) ;
        this.getAccountAdditionalRecord(component, helper);
    } ,
    
    //fetching the account additional information records
    getAccountAdditionalRecord : function(component, helper) {
        helper.callServer(component, 'c.getMyAccountAdditionalDetails', 
                          function(response){
                              if(response) {
                                  component.set("v.accountAdditionalRecord", response) ;
                              }
                          }, 
                          null) ;
    },
    
    //Toggling the account address information icon and fields
    selectedAddress : function(component, event, helper) {
        var toggleIcon = component.find("addressInfoIcon");
        (toggleIcon.get('v.iconName') == "utility:chevronright") ? toggleIcon.set('v.iconName', 'utility:chevrondown') : toggleIcon.set('v.iconName', 'utility:chevronright');
        var toggleElement = component.find("addressInfo");
        $A.util.toggleClass(toggleElement, "slds-hide");
    },

    //Toggling the account contact information icon and fields    
    selectedContact : function(component, event, helper) {
        var toggleIcon = component.find("contactInfoIcon");
        (toggleIcon.get('v.iconName') == "utility:chevronright") ? toggleIcon.set('v.iconName', 'utility:chevrondown') : toggleIcon.set('v.iconName', 'utility:chevronright');
        var toggleElement = component.find("contactInfo");
        $A.util.toggleClass(toggleElement, "slds-hide");
    },
    
    //Toggling the account sic information icon and fields
    selectedSic : function(component, event, helper) {
        var toggleIcon = component.find("sicInfoIcon");
        (toggleIcon.get('v.iconName') == "utility:chevronright") ? toggleIcon.set('v.iconName', 'utility:chevrondown') : toggleIcon.set('v.iconName', 'utility:chevronright');
        var toggleElement = component.find("sicInfo");
        $A.util.toggleClass(toggleElement, "slds-hide");
    },
    
    //Toggling the account consideration information icon and fields
    selectedConsideration : function(component, event, helper) {
        var toggleIcon = component.find("ConsiderationIcon");
        (toggleIcon.get('v.iconName') == "utility:chevronright") ? toggleIcon.set('v.iconName', 'utility:chevrondown') : toggleIcon.set('v.iconName', 'utility:chevronright');
        var toggleElement = component.find("consideration");
        $A.util.toggleClass(toggleElement, "slds-hide");
    },
    
    //Toggling the account additional information icon and fields
    selectedAdditional : function(component, event, helper) {
        var toggleIcon = component.find("additionalInfoIcon");
        (toggleIcon.get('v.iconName') == "utility:chevronright") ? toggleIcon.set('v.iconName', 'utility:chevrondown') : toggleIcon.set('v.iconName', 'utility:chevronright');
        var toggleElement = component.find("additionalInfo");
        $A.util.toggleClass(toggleElement, "slds-hide");
    },
})