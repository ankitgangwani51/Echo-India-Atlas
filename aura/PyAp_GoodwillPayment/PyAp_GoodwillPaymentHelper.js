({
    doInit : function(component, event, helper) {
        
        this.initializeVariables(component, event, helper);
        //Retrieve Account fields Prop info
        this.callServer(component,'c.retrieveAccountFields', 
                        function(response) {
                                component.set('v.accountFieldObj', response);
                                var field = component.get('v.accountFieldObj');
                            },
                            null);
            
        //Retrieve Account object info
            let params = {"accountId" : component.get('v.recordId')} ;
            this.callServer(component,'c.retrieveAccountInfo', 
                            function(response) {
                                component.set('v.accountObj', response);
                            },
                            params);
            
        //retrieve Goodwill Payment Field props
            this.callServer(component,'c.retrieveGoodwillPaymentFields', 
                            function(response) {
                                component.set('v.goodwillPaymentFieldList', response);
                            },
                            null);
        
        //retrieve Bank Account related Payment Fields
            var bankAccInfo= $A.get('$Label.c.PyAp_BankAccountDetail');
            let params_Bank = {
                'paymentType': bankAccInfo
            };
            this.callServer(component,'c.retrieveBankAccountFields', 
                            function(response) {
                                component.set('v.payBankInfoFieldList', response);
                            },
                            params_Bank);
        
        // retrieve Cheque related Payment fields
            var chequeInfo= $A.get('$Label.c.PyAp_Cheque');
            let params_Cheque = {
                'paymentType': chequeInfo
            }; 
            this.callServer(component,'c.retrieveBankAccountFields', 
                            function(response) {
                                component.set('v.payChequeFieldList', response);
                                
                            },
                            params_Cheque); 
           
         
           this.callServer(component,'c.checkBankBranchRecords',  
                            function(response) {
                              component.set('v.validateButtonEnabled', response);
                            },
                            null); 
 		  
    },
    
    reinitialise : function(component) {
        component.set("v.objPayment",  {'sobjectType':this.setPrefixedString('Payment__c')}) ;
        component.set('v.bankBranchFound', false); 
    },
    
    initializeVariables : function(component, event, helper) {
        component.set("v.objPayment",  {'sobjectType':this.setPrefixedString('Payment__c')}) ;
        // Cretae List to assign value  in Goodwill Type Options
        var goodWillTypeOptions=[{'label': $A.get('$Label.c.PyAp_RefundToCustomer'), 'value': $A.get('$Label.c.PyAp_RefundToCustomer')},
                                 {'label': $A.get('$Label.c.PyAp_PaymentToContract'), 'value': $A.get('$Label.c.PyAp_PaymentToContract')} ];
        
        component.set('v.goodwillTypeOptions', goodWillTypeOptions);
        
        var refundTypeOptions =  [{'label': $A.get('$Label.c.PyAp_BankAccount'), 'value': $A.get('$Label.c.PyAp_BankAccount')},
                                  {'label': $A.get('$Label.c.PyAp_Cheque'), 'value':$A.get('$Label.c.PyAp_Cheque')} ];
        component.set('v.refundTypeOptions', refundTypeOptions);
        
        // Cretae List and assign in oprtion to check new or existing process.                                          
        var optionsList =  [{'label': $A.get('$Label.c.GlUt_New'), 'value': $A.get('$Label.c.GlUt_New')},
                            {'label': $A.get('$Label.c.GlUt_Existing'), 'value': $A.get('$Label.c.GlUt_Existing')} ];
        component.set('v.optionsList', optionsList);

    },
    
    //action on Save button click
    doSave : function(component, event, helper) {
        if(this.validatePayment(component, event, helper)) {
            var goodwillType = component.get('v.isRefundToCustomer') ? $A.get('$Label.c.GlUt_Refund') : component.get('v.isPaymentToContract') ? $A.get('$Label.c.GlUt_Payment') : null ;
            var contractObj = component.get('v.selectedContractId') ;
            var bankDetailObj = component.get('v.selectedBankAccountDetailId') ;
            let params_goodwillPayment = {
                'goodwillPaymentObj' : component.get("v.objPayment") , 
                'accountId' : component.get('v.recordId'), 
                'type' : goodwillType, 
                'contractId' : contractObj != null ?  contractObj.Id : null, 
                'bankAccountDetailId' : bankDetailObj != null ?  bankDetailObj.Id : null
            } ;
            this.callServer(component, 'c.saveGoodwillPayment',
                            function(response){
                                component.set("v.showGoodwillComponent", false) ;
                                component.set('v.isRefundToCheque',false) ;
                                component.set('v.isRefundToBankAccount',false) ;
                                component.set('v.isPaymentToContract', false) ;
                                component.set('v.isRefundToCustomer', false) ;
                            }, 
                            params_goodwillPayment) ;
        }
    },
    
    //Validate Payemnt method to validate data.
    validatePayment : function(component, event, helper) {
        this.clearNotification(component) ;	//clear any existing notification
        var paymentObj = component.get("v.objPayment") ;
        var errorMessages = [] ;
        var validationPassed = true ;
        var payment = paymentObj[this.setPrefixedString('Amount__c')] ;
        if(!payment || ((payment < 0) || (payment == 0))) {
            errorMessages.push($A.get('$Label.c.PyAp_GoodwillPayment_AmountValidation')) ;
            validationPassed = false ;
        } 
        if(!paymentObj[this.setPrefixedString('GoodwillReason__c')]) {
            errorMessages.push($A.get('$Label.c.PyAp_GoodwillPayment_GoodwillReasonValidation')) ;
            validationPassed = false ;
        } 
        if(!component.get('v.isPaymentToContract') && !component.get('v.isRefundToCustomer')) {
            errorMessages.push($A.get('$Label.c.PyAp_GoodwillPayment_ProcessAsValidation')) ;
            validationPassed = false ;
        }
        if(component.get('v.isRefundToCustomer') && (!component.get('v.isRefundToCheque') && !component.get('v.isRefundToBankAccount'))) {
            errorMessages.push($A.get('$Label.c.PyAp_GoodwillPayment_RefundTypeValidation')) ;
            validationPassed = false ;
        }
        if(component.get('v.isRefundToCustomer') 
           		&& component.get('v.isRefundToCheque')	
           		&& (this.isNullOrWhitespace(component, paymentObj[this.setPrefixedString('RefundAddress__c')])
          		|| this.isNullOrWhitespace(component, paymentObj[this.setPrefixedString('RefundReference__c')]))) {
            errorMessages.push($A.get('$Label.c.PyAp_GoodwillPayment_PayeeValidation')) ;
            validationPassed = false ;
        }
        if(component.get('v.isRefundToCustomer') 
           		&& component.get('v.isRefundToBankAccount')	
           		&& (!component.get("v.selectedBankAccountDetailId")
                    && (this.isNullOrWhitespace(component, paymentObj[this.setPrefixedString('NameofRefundAccount__c')])
                        ||
                        this.isNullOrWhitespace(component, paymentObj[this.setPrefixedString('BankAccountSortCode__c')])
                        ||
                        this.isNullOrWhitespace(component, paymentObj[this.setPrefixedString('BankAccountNumber__c')])
                       )
                   )
          ) {
            errorMessages.push($A.get('$Label.c.PyAp_GoodwillPayment_BankAccountValidation')) ;
            validationPassed = false ;
        }
        if(component.get('v.isPaymentToContract') && !component.get('v.selectedContractId')) {
            errorMessages.push($A.get('$Label.c.PyAp_GoodwillPayment_ContractValidation')) ;
            validationPassed = false ;
        }
    
        if(!validationPassed) {
            this.showNotification(component, errorMessages) ;
            return false ;
        } else
            return true ;
    }, 
    
    // AT-4920 validates the Sort Code on Validate Button Click
    validateSortCode: function(component, event, helper) { 
        this.clearNotification(component);
        component.set('v.bankBranchFound', false); 
        debugger;
        var errorMessages = [];
        var paymentObj = component.get("v.objPayment") ;
        
        this.callServer(component,'c.retrieveBankBranchFields', 
                        function(response) {
                            component.set('v.bankBranchFields',response);
                        },
                        null);
        
        
        if(!paymentObj[this.setPrefixedString('BankAccountSortCode__c')]){
            errorMessages.push($A.get("$Label.c.PyAp_SortCodeBlank")); 
            this.showNotification(component, errorMessages);
            return false;
        }
        else{
            let params_SortCode = {
                'sortCode': paymentObj[this.setPrefixedString('BankAccountSortCode__c')]
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
    
    
    //checks for null, undefined, empty, whitespaces
    isNullOrWhitespace : function(component, input) {
        return !input || !input.trim();
    }, 
    
    //action on Cancel button click
    doCancel : function(component) {
        component.set("v.showGoodwillComponent", false) ;
        this.reinitialise(component) ;
    },
	
    //Opens Goodwill Component
    doOpenGoodwillComponent : function(component) {
      this.reinitialise(component) ;
      component.set("v.showGoodwillComponent", true) ;
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
    
    //New or Existing button click action
    showInnerDetailsSection: function(component, options) {
        var processAsOption = document.getElementsByName('processAsInnerRadio') ;
        var selectedOption = this.getSelectedOption(component, processAsOption) ;
        this.reinitializePaymentFields(component, selectedOption) ;
    },
    
    // used to show and hide Goodwill Payment: Refund to Customer and Payment to Contract section 
    showDetailsSection: function(component, event, helper) { 
        var processAsOption = document.getElementsByName('processAsRadio') ;
        var selectedOption = this.getSelectedOption(component, processAsOption) ;
        //Refund to Customer section & Payment to Contract section 
        this.reinitializePaymentFields(component, selectedOption) ;
    },
    
    //renders sections on refund type selection
    onRefundTypeSelection : function(component, event, helper) {
        var refundTypeOption = document.getElementsByName('refundTypeRadio') ;
        var selectedOption = this.getSelectedOption(component, refundTypeOption) ;
        this.reinitializePaymentFields(component, selectedOption) ;
    }, 
   
    // call the notifier method to show a message on the notification component on the Goodwill Payment component
    showNotification: function(component, message, type) {
        component.find('notifier').showNotification(message, type);
    },
    
    // call the notifier method to clear a message on the notification component on the Goodwill Payment component
    clearNotification: function(component) {
        component.find('notifier').clearNotification();
    },   
    
    reinitializePaymentFields : function(component, selectedOption) {
        var objPayment = component.get('v.objPayment') ;
        //renders sections on refund type selection
        if(selectedOption == $A.get('$Label.c.PyAp_BankAccount')) { 
            component.set('v.isRefundToCheque',false);
            component.set('v.isRefundToBankAccount',true);
            component.set('v.selectedContractId', '') ;
        }
        //renders sections on refund type selection
        if(selectedOption ==  $A.get('$Label.c.PyAp_Cheque')) { 
            component.set('v.isRefundToBankAccount',false);
            component.set('v.isRefundToCheque',true);
            component.set('v.selectedBankAccountDetailId', '') ;
        }
        //Refund to Customer section
        if(selectedOption == $A.get('$Label.c.PyAp_RefundToCustomer')) {
            component.set('v.isRefundToCustomer',true); 
            component.set('v.isPaymentToContract',false); 
            component.set('v.radioValue','refundCredit'); 
            component.set('v.selectedContractId', '') ;
            component.set('v.isRefundToCheque',false) ;
            component.set('v.isRefundToBankAccount',false) ;
        }
        //Payment to Contract section 
        if(selectedOption == $A.get('$Label.c.PyAp_PaymentToContract')) {
            component.set('v.isRefundToCustomer',false); 
            component.set('v.isPaymentToContract',true); 
            component.set('v.radioValue','transferCredit');  
            component.set('v.selectedBankAccountDetailId', '') ;
            component.set('v.isRefundToCheque',false) ;
            component.set('v.isRefundToBankAccount',false) ;
        }
        //New  button click action
        if(selectedOption == $A.get("$Label.c.GlUt_New")) {
            component.set('v.selectedBankAccountDetailId', '') ;
            component.set('v.isShowNew',true);
            component.set('v.isShowExisting',false);
        }
        //Existing button click action
        if(selectedOption == $A.get("$Label.c.GlUt_Existing")) {
            component.set('v.isShowNew',false);
            component.set('v.isShowExisting',true); 
        }
        if(selectedOption == $A.get('$Label.c.PyAp_BankAccount') || selectedOption ==  $A.get('$Label.c.PyAp_PaymentToContract')) { 
            objPayment[this.setPrefixedString('RefundAddress__c')]='';
            objPayment[this.setPrefixedString('RefundReference__c')]='';
        }
        if(selectedOption == $A.get('$Label.c.PyAp_Cheque') || selectedOption ==  $A.get('$Label.c.PyAp_PaymentToContract') || selectedOption == $A.get("$Label.c.GlUt_Existing")) { 
            objPayment[this.setPrefixedString('NameofRefundAccount__c')]='';
            objPayment[this.setPrefixedString('BankAccountSortCode__c')]='';
            objPayment[this.setPrefixedString('BankAccountNumber__c')]='';
        }
        component.set('v.objPayment',objPayment);
    } ,
    
})