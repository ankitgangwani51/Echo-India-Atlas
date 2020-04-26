({          
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component, event, helper) {                 
        console.log(this.DEBUG + 'reInitialise');
        component.set('v.isInitialised', false);    
        component.set('v.objPayment', {'sobjectType': this.setPrefixedString('Payment__c')});
        component.set('v.objTempPayment', {'sobjectType': this.setPrefixedString('Payment__c')});
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component, event, helper) { 
        if(!component.get('v.isInitialised')) {
            component.set('v.objPayment', {'sobjectType': this.setPrefixedString('Payment__c')});
            component.set('v.objTempPayment', {'sobjectType': this.setPrefixedString('Payment__c')});
            this.initialiseDisplayedFields(component, event, helper);
        }
    },
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component, event, helper) {  
		   // retrieve list of fields and properties for the search parameters
        var wizprop = component.get("v.wizardprop");
        
        if(wizprop.isInActiveWithDebt){
            var wizprop = component.get("v.wizardprop");
            if(wizprop.isCreditWriteOff){
                return true;
            }
            
        }else{
            if(this.validateAmoutToCredit(component, event, helper)){
                if(component.get('v.isShowTransfer') == true){
                    return this.validateCustomerOrContract(component, event, helper);
                }else{
                    if(component.get('v.isRefundToBankAccount') || component.get('v.isRefundToCheque')){
                        if(component.get('v.isRefundToBankAccount') ){
                            if(component.get('v.isShowExisting') || component.get('v.isShowNew')){
                                var objPayment = component.get('v.objPayment');
                                var selectedBankAccountDetailid = component.get("v.selectedBankAccountDetailId");
                                if(component.get('v.isShowExisting')){
                                    if(selectedBankAccountDetailid != null && selectedBankAccountDetailid['Id']){
                                        objPayment[this.setPrefixedString('BankAccountDetail__c')] = selectedBankAccountDetailid['Id'];
                                    }else{
                                        var errorMessages = [];
                                        errorMessages.push($A.get("$Label.c.PyAp_EnterEitherBankAccountOrSingleAccountDetails"));
                                        this.showNotification(component, errorMessages);
                                        return false;
                                    }
                                }else 
                                    if(component.get('v.isShowNew')){
                                        if (objPayment[this.setPrefixedString('NameofRefundAccount__c')] === undefined || objPayment[this.setPrefixedString('NameofRefundAccount__c')] === '' ||
                                            objPayment[this.setPrefixedString('BankAccountSortCode__c')] === undefined || objPayment[this.setPrefixedString('BankAccountSortCode__c')] === '' ||
                                            objPayment[this.setPrefixedString('BankAccountNumber__c')] === undefined || objPayment[this.setPrefixedString('BankAccountNumber__c')] === '') {
                                            var errorMessages = [];
                                            errorMessages.push($A.get("$Label.c.PyAp_EnterMandatoryFields"));
                                            this.showNotification(component, errorMessages);
                                            return false;
                                        } 
                                    }
                            }else{
                                var errorMessages = [];
                                errorMessages.push($A.get("$Label.c.PyAp_SelectOperationMandatory"));
                                this.showNotification(component, errorMessages);
                                return false; 
                            }
                            // Setting values in wizard prop. 
                            var wizardProp = component.get('v.wizardprop');
                            objPayment[this.setPrefixedString('Amount__c')] = component.get('v.objTempPayment')[this.setPrefixedString('CreditAmount__c')];
                            wizardProp.objPayment =objPayment;
                            wizardProp.isCreditWriteOff = false;
                            wizardProp.isCreditTransfer = false;
                            wizardProp.isCreditRefund = true;  
                            
                            component.set('v.wizardprop',wizardProp); 
                            return true;
                        }
                        else 
                            if(component.get('v.isRefundToCheque')){
                                var objPayment = component.get('v.objPayment'); 
                                //AT-4154, 05 Dec 2018, Remove RefundReference__c required field validation                            
                                if (objPayment[this.setPrefixedString('RefundAddress__c')] === undefined || objPayment[this.setPrefixedString('RefundAddress__c')] === '') {
                                    var errorMessages = [];
                                    errorMessages.push($A.get("$Label.c.PyAp_EnterMandatoryFields"));
                                    this.showNotification(component, errorMessages);
                                    return false;
                                }
                                objPayment[this.setPrefixedString('Amount__c')] =component.get('v.objTempPayment')[this.setPrefixedString('CreditAmount__c')];
                                var wizardProp = component.get('v.wizardprop');
                                wizardProp.isCreditWriteOff = false;
                                wizardProp.isCreditTransfer = false;
                                wizardProp.isCreditRefund = true;    
                                wizardProp.objPayment =objPayment; 
                                component.set('v.wizardprop',wizardProp); 
                                return true;
                            }
                    }else{
                        var errorMessages = [];
                        errorMessages.push($A.get("$Label.c.PyAp_ActionToCarryOutMandateError"));
                        this.showNotification(component, errorMessages);
                        return false; 
                    }
                }
            } else{
                return false;
			}
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
    // initialise all the displayed fields
    initialiseDisplayedFields: function(component, event, helper) {  
        // retrieve list of fields and properties for the search parameters
        var wizprop = component.get("v.wizardprop");
        this.fetchTotalCredit(component, event, helper); 
        if(wizprop.isInActiveWithDebt){
            debugger;
            var options =  [{'label': $A.get('$Label.c.PyAp_CreditWriteOffLabel'), 'value': $A.get('$Label.c.PyAp_CreditWriteOff')}];
            component.set('v.options', options);
            var objPay = component.get('v.objTempPayment');
            objPay[this.setPrefixedString('CreditAmount__c')] = wizprop.creditAmount;
            component.set('v.objTempPayment',objPay);
            component.set('v.isEditable',false);
            component.set('v.isShowLabel',true);
            
        }else{
            var optionsList =  [{'label': $A.get('$Label.c.GlUt_New'), 'value': $A.get('$Label.c.GlUt_New')},
                                {'label': $A.get('$Label.c.GlUt_Existing'), 'value': $A.get('$Label.c.GlUt_Existing')} ];
            component.set('v.optionsList', optionsList);
            
            var options =  [{'label': $A.get('$Label.c.PyAp_RefundCreditAmount'), 'value': $A.get('$Label.c.PyAp_RefundCreditAmountValue')},
                            {'label': $A.get('$Label.c.PyAp_TransferCreditAmount'), 'value': $A.get('$Label.c.PyAp_TransferCreditAmountValue')}
                           ];
            component.set('v.options', options);
            
            
            if(component.get('v.isInitialised')){
                var currentSelection =component.get('v.radioValue');
                if(currentSelection == $A.get('$Label.c.PyAp_RefundCreditAmountValue')){
                    component.set('v.isShowRefund',true); 
                    component.set('v.isShowTransfer',false); 
                }
                if(currentSelection == $A.get('$Label.c.PyAp_TransferCreditAmountValue')){
                    component.set('v.isShowRefund',false); 
                    component.set('v.isShowTransfer',true); 
                }
            }
            else{
                // set credit amount from wizard prop to variable.
                
                var bankAccInfo='BankAccountDetails';
                var chequeInfo='ChequeDetails';
                let params = {
                    'strPaymentTypeBank': bankAccInfo,
                    'strPaymentTypeCheque': chequeInfo,
                    'selectedContractId': wizprop.contractId
                };
                
                this.callServer(component,'c.getScreenInfo', function(response) {
                    if(response.objAccount){
                        component.set('v.objAccount', response.objAccount);
                        
                        // AT-4154, 05 Dec 2018, get the billing address from the account associated with billing contract
                        var account = response.objAccount;
                        var billingAddress = '';
                        
                        if(account.BillingStreet != null)
                            billingAddress = billingAddress + ' ' + account.BillingStreet;
                        if(account.BillingCity != null)
                            billingAddress = billingAddress + ' ' + account.BillingCity;
                        if(account.BillingState != null)
                            billingAddress = billingAddress + ' ' + account.BillingState;
                        if(account.BillingCountry != null)
                            billingAddress = billingAddress + ' ' + account.BillingCountry;
                        if(account.BillingPostalCode != null)
                            billingAddress = billingAddress + ' ' + account.BillingPostalCode;
                        
                        component.set('v.billingAddress',billingAddress);
                    }
                    if(response.lstFieldPropBank.length > 0){
                        component.set('v.payBankInfoFieldList', response.lstFieldPropBank);  
                    }
                    if(response.lstFieldPropCheque.length > 0){
                        component.set('v.payChequeFieldList', response.lstFieldPropCheque);  
                    }
                    component.set('v.validateButtonEnabled', response.isBranchCode);
                },params);
                component.set('v.isInitialised', true);
            }
        }
    },
    // used to show and hide credit refund and transfer section 
    showDetailsSection: function(component, event, helper) {  
        var wizprop = component.get("v.wizardprop");
        debugger;
        if(wizprop.isInActiveWithDebt){
            var processAsOption = document.getElementsByName('processAsRadio') ;
            var selectedOption = this.getSelectedOption(component, processAsOption) ;
            component.set('v.radioValue',selectedOption);
            if(selectedOption == $A.get('$Label.c.PyAp_CreditWriteOff')){
                var objPayment = component.get("v.objPayment");
                wizprop.objPayment = objPayment;
                wizprop.isCreditTransfer = false;
                wizprop.isCreditRefund = false;
                wizprop.isCreditWriteOff = true;
                
            }else{
                wizprop.isCreditWriteOff = false;
            }
            component.set("v.wizardprop",wizprop);
        } 
        else{
            var processAsOption = document.getElementsByName('processAsRadio') ;
            var selectedOption = this.getSelectedOption(component, processAsOption) ;
            //var changeValue = event.getParam("value");
            if(selectedOption == $A.get('$Label.c.PyAp_RefundCreditAmountValue')){
                component.set('v.isShowRefund',true); 
                component.set('v.isShowTransfer',false); 
                component.set('v.radioValue',$A.get('$Label.c.PyAp_RefundCreditAmountValue')); 
            }
            if(selectedOption == $A.get('$Label.c.PyAp_TransferCreditAmountValue')){
                component.set('v.isShowRefund',false); 
                component.set('v.isShowTransfer',true); 
                component.set('v.radioValue',$A.get('$Label.c.PyAp_TransferCreditAmountValue')); 
            }
        }
    },
    showInnerDetailsSection: function(component, options) {
        var processAsOption = document.getElementsByName('processAsInnerRadio') ;
        var selectedOption = this.getSelectedOption(component, processAsOption) ;
        if(selectedOption == $A.get("$Label.c.GlUt_New")){
            component.set('v.isShowNew',true);
            component.set('v.isShowExisting',false);
        }
        if(selectedOption == $A.get("$Label.c.GlUt_Existing")){
            component.set('v.isShowNew',false);
            component.set('v.isShowExisting',true);
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
    // fetch total amout from wizard prop and assign to attribute 
    fetchTotalCredit: function(component, event, helper) {
        var wizprop = component.get("v.wizardprop");
        component.set('v.totalCreditAmount',wizprop.creditAmount);
        component.set('v.alreadyRequestedAmount',wizprop.alreadyRequestedRefundAmount);
    },
    // Method is used to validate input amount, should not be greater than credit amount.
    validateAmoutToCredit: function(component, event, helper) {  
        if(!component.get('v.objTempPayment')[this.setPrefixedString('CreditAmount__c')] || 
           parseFloat(component.get('v.objTempPayment')[this.setPrefixedString('CreditAmount__c')]) > component.get('v.totalCreditAmount') ){
            var errorMessages = [];
            errorMessages.push($A.get("$Label.c.PyAp_InputCreditAmountLowerThanBalanceAmountError"));
            this.showNotification(component, errorMessages);
            
            return false;
        }else 
            if(!component.get('v.objTempPayment')[this.setPrefixedString('CreditAmount__c')] || 
               parseFloat(component.get('v.objTempPayment')[this.setPrefixedString('CreditAmount__c')]) > (component.get('v.totalCreditAmount') - component.get('v.alreadyRequestedAmount'))){
                var errorMessages = [];
                errorMessages.push($A.get("$Label.c.PyAp_InputCreditAmountLowerThanBalanceAmountError"));
                this.showNotification(component, errorMessages);
            }else{
                return true;
            }
    },
    //Validating customer and contract in case of credit transfer.
    validateCustomerOrContract: function(component, event, helper) {  
        if(!component.get('v.objAccount.Id') || !component.get('v.selectedContractId') ){
            var errorMessages = [];
            errorMessages.push($A.get("$Label.c.PyAp_AccountContractSelectionError"));
            this.showNotification(component, errorMessages);
            return false;
        }else{
            var wizprop = component.get("v.wizardprop");
            var objPayment = component.get("v.objPayment");
            objPayment[this.setPrefixedString('Account__c')] = component.get("v.objAccount").Id;
            objPayment[this.setPrefixedString('BillingContract__c')] = component.get("v.selectedContractId").Id;
            objPayment[this.setPrefixedString('Amount__c')] = component.get('v.objTempPayment')[this.setPrefixedString('CreditAmount__c')] ;
            objPayment[this.setPrefixedString('DoNotPrint__c')] = component.get('v.isDoNotPrint') ;   //AT-4898
            wizprop.objPayment = objPayment;
            wizprop.isCreditTransfer = true;
            wizprop.isCreditRefund = false;
            component.set("v.wizardprop",wizprop);
            return true;
        }
    },
    // Hinding bank section and showing bank account 
    onCheckRefundToCheque: function(component, event, helper) {
        //var wizprop = component.get("v.wizardprop");
        //alert('refund to cheque value = '+component.get('v.isRefundToCheque'))
        if(component.get('v.isRefundToCheque')){
            component.set('v.isRefundToBankAccount',false);
            component.set('v.isRefundToCheque',true);
            component.set('v.isShowNew',false);
            component.set('v.isShowExisting',false);
            
            
            var objPayment = component.get('v.objPayment');             
            objPayment[this.setPrefixedString('NameofRefundAccount__c')]='';
            objPayment[this.setPrefixedString('BankAccountSortCode__c')]='';
            objPayment[this.setPrefixedString('BankAccountNumber__c')]='';
            // AT-4154, 05 Dec 2018, Auto Populate Billing Address in Refund Address field
            objPayment[this.setPrefixedString('RefundAddress__c')] = component.get('v.billingAddress');
            component.set('v.objPayment',objPayment);
        }
    },
    onCheckRefundToBank: function(component, event, helper) {
        //alert('refund to bank account value = '+component.get('v.isRefundToBankAccount'))
        if(component.get('v.isRefundToBankAccount')){
            component.set('v.isRefundToCheque',false);
            component.set('v.isRefundToBankAccount',true);
            var objPayment = component.get('v.objPayment');  
            objPayment[this.setPrefixedString('RefundAddress__c')]='';
            objPayment[this.setPrefixedString('RefundReference__c')]='';
            component.set('v.objPayment',objPayment);
        }
    },
    
    // AT-4920 validates the Sort Code on Validate Button Click
    validateSortCode: function(component, event, helper) { 
        this.clearNotification(component);
        component.set('v.bankBranchFound', false); 
        var errorMessages = [];
        this.callServer(component,'c.retrieveBankBranchFields', 
                        function(response) {
                            component.set('v.bankBranchFields',response);
                        },
                        null);
        
        var objPayment = component.get("v.objPayment");
        if(!objPayment[this.setPrefixedString('BankAccountSortCode__c')]){
            errorMessages.push($A.get("$Label.c.PyAp_SortCodeBlank")); 
            this.showNotification(component, errorMessages);
            return false;
        }
        else{
            let params_SortCode = {
                'sortCode': objPayment[this.setPrefixedString('BankAccountSortCode__c')]
            }
            
            this.callServer(component,'c.validateSortCodeEntered',function(response){ 
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
            },  params_SortCode);
        }
    },
    
})