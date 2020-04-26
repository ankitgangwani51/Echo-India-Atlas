({
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component, event, helper) {                 
        console.log(this.DEBUG + 'reInitialise');
        component.set('v.isInitialised', false);    
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component, event, helper) {  
        debugger;
        // Cretae List and assign in option to check new or existing process.                                          
        var optionsList = [{'label': $A.get('$Label.c.GlUt_New'), 'value': $A.get('$Label.c.GlUt_New')},
                            {'label': $A.get('$Label.c.GlUt_Existing'), 'value': $A.get('$Label.c.GlUt_Existing')} ];
        component.set('v.options', optionsList);
        // Initialize component values
        if(!component.get('v.isInitialised')) {
            component.set('v.objBankAccountDetail', {'sobjectType': this.setPrefixedString('BankAccountDetails__c')});
            this.initialiseDisplayedFields(component, event, helper);
        }
    },
    // validates the wizardprop on completion of the step
    validateOnNext: function(component, event, helper) { 
        debugger;
        var errorMessages = [];
        var objBankAccountDetail = component.get("v.objBankAccountDetail");
        var wizardProp = component.get('v.wizardprop'); 
        if(component.get('v.isShowExisting') || component.get('v.isShowNew')){
            if(component.get('v.radioValue') == $A.get("$Label.c.GlUt_New")){
                if(objBankAccountDetail)
                    if(!objBankAccountDetail[this.setPrefixedString('BankAccountNumber__c')] || !objBankAccountDetail[this.setPrefixedString('NameOnAccount__c')] || 
                       !objBankAccountDetail[this.setPrefixedString('BankAccountSortCode__c')]){
                        errorMessages.push($A.get("$Label.c.PyAp_EnterMandatoryFields")); 
                        this.showNotification(component, errorMessages);
                        return false;
                    }
                    else{
                        wizardProp.bankAccountDetail =objBankAccountDetail;
                        component.set('v.wizardprop',wizardProp); 
                        return true;
                    }
            }
            else{
                debugger;
                if(!component.get('v.selectedBankAccountDetailId')){
                    errorMessages.push($A.get("$Label.c.PyAp_SelectBankAccountDetailRecord"));
                    this.showNotification(component, errorMessages);
                    return false;
                }else{
                    debugger;
                    var existingBankAccountDetail = component.get('v.selectedBankAccountDetailId');
                    wizardProp.bankAccountDetailId =existingBankAccountDetail['Id'];
                    component.set('v.wizardprop',wizardProp); 
                    return true;
                }
            }
        }else{
            var errorMessages = [];
            errorMessages.push($A.get("$Label.c.PyAp_SelectOperationMandatory"));
            this.showNotification(component, errorMessages);
            return false; 
        }
    },
   
    // AT-4920 validates the Sort Code on Validate Button Click
    validateSortCode: function(component, event, helper) { 
        this.clearNotification(component);
        component.set('v.bankBranchFound', false); 
        debugger;
        var errorMessages = [];
        var objBankAccountDetail = component.get("v.objBankAccountDetail");
        
        this.callServer(component,'c.retrieveBankBranchFields', 
                        function(response) {
                            component.set('v.bankBranchFields',response);
                        },
                        null);
        
        
        if(!objBankAccountDetail[this.setPrefixedString('BankAccountSortCode__c')]){
            errorMessages.push($A.get("$Label.c.PyAp_SortCodeBlank")); 
            this.showNotification(component, errorMessages);
            return false;
        }
        else{
            let params_SortCode = {
                'sortCode': objBankAccountDetail[this.setPrefixedString('BankAccountSortCode__c')]
            }
            
            this.callServer(component,'c.validateSortCodeEntered',
                            function(response){ 
                                if(response == null) {
                                    component.set('v.bankBranchFound', false); 
                                    errorMessages.push($A.get("$Label.c.PyAp_SortCodeInvalid")); 
                                    this.showNotification(component, errorMessages,'warn');
                                }
                                else {
                                    if(response.Id != null) {
                                        component.set('v.bankBranchFound', true); 
                                        component.set('v.bankBranchRec', response); 
                                    }
                                }
                            },                         
                            params_SortCode);
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
    // initialise all the displayed fields
    initialiseDisplayedFields: function(component, event, helper) {  
        // retrieve list of fields and properties for the search parameters
        var wizprop = component.get("v.wizardprop");
        if(component.get('v.isInitialised')){
            if(component.get('v.radioValue') == $A.get("$Label.c.GlUt_New")){
                component.set('v.isShowNew',true);
                component.set('v.isShowExisting',false);
            }else{
                component.set('v.isShowNew',false);
                component.set('v.isShowExisting',true);
            }
        } 
        else{
            this.callServer(component,'c.retrieveBankAccountDetailsFields', 
                            function(response) {
                                component.set('v.bankAccountDetailsFields', response);
                            },
                            null); 
        
        }
        if(wizprop.contractId){   
            let params_Contract = {
                'selectedContractId': wizprop.contractId
            }
            // Get existing account in case of transfer credit. 
            this.callServer(component,'c.getExistingAccount',
                            function(response){ 
                                component.set('v.objAccount', response);
                            },                         
                            params_Contract);
            
            
            this.callServer(component,'c.checkBankBranchRecords',   //AT-4920
                            function(response) {
                              component.set('v.validateButtonEnabled', response);
                            },
                            null); 
        }  
        component.set('v.isInitialised', true);
    },
    // used to show and hide credit refund and transfer section 
    showDetailsSection: function(component, event, helper) {  
        //var changeValue = event.getParam("value");
        debugger;
        var processAsOption = document.getElementsByName('processAsRadio') ;
        var selectedOption = this.getSelectedOption(component, processAsOption) ;
        if(selectedOption == $A.get("$Label.c.GlUt_New")){
            component.set('v.isShowNew',true);
            component.set('v.isShowExisting',false);
            component.set('v.selectedBankAccountDetailId','');
            // Fix as bug told by Ruchika- Dependra Singh(18 Oct 2018)
            component.set('v.radioValue',$A.get("$Label.c.GlUt_New")) ;
        }
        if(selectedOption == $A.get("$Label.c.GlUt_Existing")){
            component.set('v.isShowNew',false);
            component.set('v.isShowExisting',true);
             // Fix as bug told by Ruchika - Dependra Singh(18 Oct 2018)
            component.set('v.radioValue',$A.get("$Label.c.GlUt_Existing")) ;
        }
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
})