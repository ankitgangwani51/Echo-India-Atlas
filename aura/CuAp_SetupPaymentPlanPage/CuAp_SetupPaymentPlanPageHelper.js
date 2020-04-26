({
    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component, event, helper) {   
        component.set('v.paymentmethod', []);
        component.set('v.paymentplantype', []);
        component.set('v.paymentdate', []);
        component.set('v.paymentday', []);
        component.set('v.numberOfInstalments', '');
        component.set('v.showInstalments', false);
        
        component.set('v.paymentPlan', {'sobjectType': this.setPrefixedString('PaymentPlan__c'),
                                        [this.setPrefixedString('StartDate__c')]: '' ,
                                        [this.setPrefixedString('ForecastAmount__c')]: '' , // Sudhir
                                        [this.setPrefixedString('PaymentPlanTotal__c')]: '', // AT-2313
                                        [this.setPrefixedString('EndDate__c')]: '' //AT-3551
                                        });
        
        component.set("v.objAvailPayDay", {'sobjectType':this.setPrefixedString('AvailablePaymentDay__c'),
                                           [this.setPrefixedString('DayofWeek__c')] :'',
                                           [this.setPrefixedString('DayofMonth__c')] :''});	
        
        
        component.set("v.objpaymentPlanType1", {'sobjectType':this.setPrefixedString('PaymentPlanType__c'),
                                                'Name': '',
                                                [this.setPrefixedString('MaximumNumberOfInstalments__c')] : ''});
        
        component.set("v.objpaymentMethodType", {'sobjectType':this.setPrefixedString('PaymentMethodType__c'),
                                                 'Name': ''});            
    },
    
    // check the wizardprop/status on entry
    checksOnEntry: function(component, event, helper) {
        //To clear all the values if navigating back to previous screen of the wizard and coming back
        component.set('v.paymentPlan', {'sobjectType': this.setPrefixedString('PaymentPlan__c'),
                                        [this.setPrefixedString('StartDate__c')]: '' ,
                                        [this.setPrefixedString('ForecastAmount__c')]: '' , // Sudhir
                                        [this.setPrefixedString('PaymentPlanTotal__c')]: '', // AT-2313
                                        [this.setPrefixedString('EndDate__c')]: '' // AT-3551
                                        });
        component.set("v.objAvailPayDay", {'sobjectType':this.setPrefixedString('AvailablePaymentDay__c'),
                                           [this.setPrefixedString('DayofWeek__c')] :'',
                                           [this.setPrefixedString('DayofMonth__c')] :''});	
        component.set("v.objpaymentPlanType1", {'sobjectType':this.setPrefixedString('PaymentPlanType__c'),
                                                'Name': '',
                                                [this.setPrefixedString('MaximumNumberOfInstalments__c')] : ''});
        component.set("v.objpaymentMethodType", {'sobjectType':this.setPrefixedString('PaymentMethodType__c'),
                                                 'Name': ''});            
        component.set("v.checkOnEntryVar",true);
        this.doInit(component,event,helper);
    },  
    
    // validates the wizardprop on completion of the step
    validateOnNext: function(component, event, helper) {
        
        //There are few common validations on click of generate Instalment button and Finish Button , below is to differentiate the two.
        component.set('v.saveValidation', true);
        var returnvalue = this.doGenerateInstalments(component,event,helper,'callFromFinishButton');
        
        if(returnvalue == false){            
            return false;
        }
        
        if(component.get('v.disableInstalment') == false){
            var checkInstalmentDetails = this.checkInstalmentDetails(component,event,helper);
            
            if(checkInstalmentDetails == false){  
                return false;
            }
        }
        
        //To get latest Instalment Details
        var wizObjInst = component.get('v.wizardprop'); 
        var lstInstalmentNew = [];
        
        for(var i=0;i< component.get('v.recordList').length; i++){
            lstInstalmentNew.push(component.get('v.recordList')[i].objectMap[this.setPrefixedString('Instalment__c')]);
        }
        wizObjInst.lstInstalments = lstInstalmentNew ;
        component.set("v.wizardprop",wizObjInst);
        
        return true;
    },
    
    //This is checking is user directly click on Finish instead of Generate Instalment
    checkInstalmentDetails: function(component,event,helper) {
        
        var recList = component.get('v.recordList');
        var errorMessageNew = [];
        var totalAmount = 0.0;
        var objPaymentPlan = component.get('v.paymentPlan');
        var newInstAmount = objPaymentPlan[this.setPrefixedString('PaymentPlanTotal__c')];
        
        var DaysNotice = component.get('v.daysNotice');
        var firstinstdate;
        
        //Assign the first instalment amount in the first record of the array recList.
        if(recList.length < 1){
            this.showNotification(component, [$A.get("$Label.c.CuAp_InstalmentNotExist")], 'error');
            return false;
        }
        var firstRecord = recList[0];
        firstinstdate = firstRecord.objectMap[this.setPrefixedString('Instalment__c')][this.setPrefixedString('InstalmentDueDate__c')];        
        
        var today = new Date();
        var dateDaysNotice = new Date();
        dateDaysNotice.setDate(today.getDate()+DaysNotice);
        
        var newDate = dateDaysNotice.getFullYear() + "-" + ("0" + (dateDaysNotice.getMonth() + 1)).slice(-2) + "-" + ("0" + dateDaysNotice.getDate()).slice(-2);
        
        var payInFull = component.get('v.paymentPlanPayInFull');
        
        if(firstinstdate < newDate){
            this.showNotification(component, [$A.get("$Label.c.CuAp_PPIncorrectFirstInstalDate ") + DaysNotice], 'error');
            return false;
        }
        
        if(recList == null || recList == ''){
            this.showNotification(component, [$A.get("$Label.c.CuAp_NoInstExist")], 'error');
            return false;            
        }
        
        // This loop will check the instalment dates, if not in order then displays warning message
        for(var i = 0;i<recList.length -1 ;i++){
            
            if(recList[i].objectMap[this.setPrefixedString('Instalment__c')][this.setPrefixedString('InstalmentDueDate__c')] > recList[i + 1].objectMap[this.setPrefixedString('Instalment__c')][this.setPrefixedString('InstalmentDueDate__c')]){
                this.showNotification(component, [$A.get("$Label.c.CuAp_PPIncorrectDatesOrder")], 'error');
                return false;  
            }
        }
        
        // This loop will calculate the total sum for instalments
        for(i = 0;i<recList.length;i++){     
            if(recList[i].objectMap[this.setPrefixedString('Instalment__c')][this.setPrefixedString('Type__c')] != $A.get("$Label.c.CuAp_InstalmentTypeRolling")){
                var instAmount = recList[i].objectMap[this.setPrefixedString('Instalment__c')][this.setPrefixedString('InstalmentAmountDue__c')];            
                totalAmount = totalAmount + instAmount;
            }
            
        }
        totalAmount = Math.round(totalAmount * 100) / 100; 
        //AT-2449
        if(totalAmount !=  newInstAmount && !component.get("v.budgetPlan") && !component.get("v.specialPlan")){ // AT-2981
            this.showNotification(component, [$A.get("$Label.c.CuAp_TotalSumText") + newInstAmount + $A.get("$Label.c.CuAp_IntsalmentAmountText") + totalAmount + $A.get("$Label.c.CuAp_CorrectionMssgText")], 'error');
            return false; 
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
    
    //Init Methos
    doInit: function(component, event, helper) { 
        
        var wizNew = component.get('v.wizardprop');
        let params = {"contractId": wizNew.recordId};
        this.callServer(component,'c.getInfoToDisplay', 
                        function(response) {
                            component.set('v.paymentPlanFieldsForGeneric', response.twoColFormattedList);
                            //To get contract details from server
                            component.set("v.getContractDetails",response.mapContractDetails);
                            //To check if we could get all values of payment plan type from server
                            component.set("v.serverPaymentPlanType", response.lstPPTWrapper);
                            //To check if we could get all values of payment method from server
                            this.assignPickListValues(response.lstPMTWrapper,component, event, helper);
                        },
                        params);
    },
    //Assign picklist values to respective combo boxes
    assignPickListValues : function(inputvalues,component, event, helper){
        
        component.set("v.objPaymentMethod", inputvalues);        
        var contractDetails = component.get("v.getContractDetails");
        var contractPayMethod ; 
        
        if(contractDetails[this.setPrefixedString('DayOfMonth__c')] != undefined && contractDetails[this.setPrefixedString('DayOfMonth__c')] != null){
            component.set("v.paymentdate", contractDetails[this.setPrefixedString('DayOfMonth__c')]);
        }
        if(contractDetails[this.setPrefixedString('DayOfWeek__c')] != undefined && contractDetails[this.setPrefixedString('DayOfWeek__c')] != null){
            component.set("v.paymentday", contractDetails[this.setPrefixedString('DayOfWeek__c')]);
        }
        if(contractDetails[this.setPrefixedString('CurrentPaymentPlanType__c')] != undefined && contractDetails[this.setPrefixedString('CurrentPaymentPlanType__c')] != null){
            component.set("v.paymentplantype", contractDetails[this.setPrefixedString('CurrentPaymentPlanType__c')]);
        }
        if(contractDetails[this.setPrefixedString('PaymentPlanRenewalDate__c')] != undefined && contractDetails[this.setPrefixedString('PaymentPlanRenewalDate__c')] != null){
            component.set("v.paymentPlanRenewalDate", contractDetails[this.setPrefixedString('PaymentPlanRenewalDate__c')]);
        }
        if(contractDetails[this.setPrefixedString('PaymentMethodType__c')] != undefined && contractDetails[this.setPrefixedString('PaymentMethodType__c')] != null){
            contractPayMethod = contractDetails[this.setPrefixedString('PaymentMethodType__c')];
            component.set("v.contractDefault", true);           
        }
        var payMethodList = [];
        payMethodList.push('');
        for(var icount =0; icount < inputvalues.length; icount++){
            var stringMethod = inputvalues[icount].objPaymentMethodType.Name;
            payMethodList.push(stringMethod);    
        }
        component.set("v.paymentmethod", payMethodList);
        if(contractPayMethod != undefined && contractPayMethod != null){
            component.set("v.objpaymentMethodType", {'sobjectType':this.setPrefixedString('PaymentMethodType__c'),
                                                     'Name':contractPayMethod});            
            component.set("v.selectedPaymentMethodNew",contractPayMethod);
            this.doSaveQuestion(component, event, helper); 
        }
    },
    //Fetch values of payment plan type on selecting YES to payment method change question    
    doSaveQuestion: function(component, event, helper) {
        component.set('v.showInstalments', false);
        if(component.get("v.contractDefault") != true){
            component.set("v.planTypeId", '') ;
        }
        var wizObjInstClear = component.get('v.wizardprop'); 
        wizObjInstClear.lstInstalments = null;
        component.set('v.wizardprop',wizObjInstClear);
        
        if(component.get("v.selectedPaymentMethodNew") != null && component.get("v.selectedPaymentMethodNew") != undefined){
            component.set("v.selectedPaymentMethod",component.get("v.selectedPaymentMethodNew"));    
        }
        var objPaymentMethod = component.get("v.objPaymentMethod");
        var paymentDate = [];
        var paymentDay = [];
        paymentDate.push('');
        paymentDay.push('');
        var payPlanTypeForSelectedPayMethod = [];
        var stringDayofMonth = '';
        var stringDayofWeek = '';
        
        for(var icount =0; icount < objPaymentMethod.length; icount++){
            if(objPaymentMethod[icount].objPaymentMethodType.Name == component.get("v.selectedPaymentMethod")){
                for(var apdCount =0; apdCount < objPaymentMethod[icount].lstAvailPaymentDays.length; apdCount++){
                    if(stringDayofMonth == ''){
                        stringDayofMonth = objPaymentMethod[icount].lstAvailPaymentDays[apdCount][this.setPrefixedString('DayofMonth__c')];
                        stringDayofWeek  = objPaymentMethod[icount].lstAvailPaymentDays[apdCount][this.setPrefixedString('DayofWeek__c')];
                    }
                    else{
                        stringDayofMonth = stringDayofMonth + ';' + objPaymentMethod[icount].lstAvailPaymentDays[apdCount][this.setPrefixedString('DayofMonth__c')];
                        stringDayofWeek  = stringDayofWeek + ';' + objPaymentMethod[icount].lstAvailPaymentDays[apdCount][this.setPrefixedString('DayofWeek__c')];
                    }
                }
                for(var payMethCount =0; payMethCount < objPaymentMethod[icount].lstPaymentMethod.length; payMethCount++){
                    payPlanTypeForSelectedPayMethod.push( objPaymentMethod[icount].lstPaymentMethod[payMethCount][this.setPrefixedString('PaymentPlanType__c')]);
                }
                var temp1 = [];
                var temp2 = [];
                temp1 = stringDayofMonth.split(";");
                temp2 = stringDayofWeek.split(";");
            }   
        }
        for(var j = 0 ; j<temp1.length ; j++){
            paymentDate.push(temp1[j]);
        }
        for(var k = 0 ; k<temp2.length ; k++){
            paymentDay.push(temp2[k]);
        }
        function removeDuplicates(arr){
            let unique_array = []
            for(let i = 0;i < arr.length; i++){
                if(unique_array.indexOf(arr[i]) == -1){
                    unique_array.push(arr[i])
                }
            }
            return unique_array
        }
        payPlanTypeForSelectedPayMethod =  removeDuplicates(payPlanTypeForSelectedPayMethod);
        component.set("v.payPlanTypeForSelectedPayMethod",payPlanTypeForSelectedPayMethod);
        var newPaymentDate =  removeDuplicates(paymentDate);
        var newPaymentDay =  removeDuplicates(paymentDay);
        newPaymentDate.sort(
            function(a,b) {
                if (isNaN(a) || isNaN(b)) {
                    return a > b ? 1 : -1;
                }
                return a - b;
            }
        );
        function s(a,b){
            return daysOfWeek.indexOf(a) - daysOfWeek.indexOf(b); // basic sort function that compares the indexes of the two days
        }
        var daysOfWeek = [ $A.get("$Label.c.VmDr_SundayLabel "),
                           $A.get("$Label.c.VmDr_MondayLabel "),
                           $A.get("$Label.c.VmDr_TuesdayLabel "),
                           $A.get("$Label.c.VmDr_WednesdayLabel "),
                           $A.get("$Label.c.VmDr_ThursdayLabel "),
                           $A.get("$Label.c.VmDr_FridayLabel "),
                           $A.get("$Label.c.VmDr_SaturdayLabel ")]; // array of days sorted
        
        newPaymentDay.sort(s);
        component.set("v.paymentdate", newPaymentDate);
        component.set("v.paymentday", newPaymentDay);
        
        var contractDefault = component.get("v.contractDefault"); 
        if(contractDefault){
            var contractDetails = component.get("v.getContractDetails"); 
            
            if(contractDetails[this.setPrefixedString('DayOfMonth__c')] != undefined && contractDetails[this.setPrefixedString('DayOfMonth__c')] != null){
                var defaultDayOfMonth = contractDetails[this.setPrefixedString('DayOfMonth__c')];
                
                component.set("v.objAvailPayDay", {'sobjectType':this.setPrefixedString('AvailablePaymentDay__c'),
                                                   [this.setPrefixedString('DayofWeek__c')] :'',
                                                   [this.setPrefixedString('DayofMonth__c')] :defaultDayOfMonth});	
            }
            if(contractDetails[this.setPrefixedString('DayOfWeek__c')] != undefined && contractDetails[this.setPrefixedString('DayOfWeek__c')] != null){
                var defaultDayOfWeek = contractDetails[this.setPrefixedString('DayOfWeek__c')];
                
                component.set("v.objAvailPayDay", {'sobjectType':this.setPrefixedString('AvailablePaymentDay__c'),
                                                   [this.setPrefixedString('DayofWeek__c')] :defaultDayOfWeek,
                                                   [this.setPrefixedString('DayofMonth__c')] :''});
            }
        }
        this.getPaymentTypeValues(component,event,helper);
    },
    //Fetch list of payment plan type based on selected payment method
    getPaymentTypeValues : function(component,event,helper){
        var paymentMethod = component.get('v.selectedPaymentMethod');
        var wizObj = component.get("v.wizardprop");
        var contractId = wizObj.recordId ;
        //Here we are trying to sort all values of plan type in client side only instead of below server call
        var serverPaymentPlanType = component.get("v.serverPaymentPlanType");
        var serverPaymentPlanTypeNew = [];
        var serverPaymentPlanTypeFinal = [];
        var serverPaymentPlanTypeUnMeas = [];
        var paymentplantypeValues = [];
        paymentplantypeValues.push('');
        
        var payPlanTypeForSelectedPayMethod = component.get("v.payPlanTypeForSelectedPayMethod");
        var getContractDetails = component.get("v.getContractDetails");
        var unMeasured = getContractDetails[this.setPrefixedString('Unmeasured__c')];
        
        for(var jCount = 0;jCount< serverPaymentPlanType.length ; jCount++){
            if(serverPaymentPlanType[jCount].lstPaymentMethod != undefined ){
                for(var payMethCount = 0; payMethCount< payPlanTypeForSelectedPayMethod.length ; payMethCount++){    
                    if(payPlanTypeForSelectedPayMethod[payMethCount] == serverPaymentPlanType[jCount].objPaymentPlanType.Id){
                        if(getContractDetails[this.setPrefixedString('FinalPaymentPlan__c')] == 'true'){
                            if(serverPaymentPlanType[jCount].objPaymentPlanType[this.setPrefixedString('FinalPaymentPlan__c')]){
                                serverPaymentPlanTypeNew.push(serverPaymentPlanType[jCount]);    
                            }
                        }
                        else{
                            if(!serverPaymentPlanType[jCount].objPaymentPlanType[this.setPrefixedString('FinalPaymentPlan__c')]){
                                serverPaymentPlanTypeNew.push(serverPaymentPlanType[jCount]);    
                            }
                        }
                    }
                }
            }
        }
        //Loop For Umeasured check
        for(var unMeasCount = 0;unMeasCount< serverPaymentPlanTypeNew.length ; unMeasCount++){
            if(getContractDetails[this.setPrefixedString('Unmeasured__c')] == 'false'){
                if(!serverPaymentPlanTypeNew[unMeasCount].objPaymentPlanType[this.setPrefixedString('Unmeasured__c')]){
                    serverPaymentPlanTypeUnMeas.push(serverPaymentPlanTypeNew[unMeasCount]);
                }
            }
            else{
                if(serverPaymentPlanTypeNew[unMeasCount].objPaymentPlanType[this.setPrefixedString('Unmeasured__c')]){
                    serverPaymentPlanTypeUnMeas.push(serverPaymentPlanTypeNew[unMeasCount]);
                }
            }
        }
        for(var zCount = 0;zCount< serverPaymentPlanTypeUnMeas.length ; zCount++){
            if(getContractDetails[this.setPrefixedString('EligibleforBudgetPlan__c')] != 'true'){
                if(serverPaymentPlanTypeUnMeas[zCount].objPaymentPlanType[this.setPrefixedString('PlanType__c')] != $A.get("$Label.c.CuAp_PaymentPlanTypePlanTypeBudgetPlan")){
                    serverPaymentPlanTypeFinal.push(serverPaymentPlanTypeUnMeas[zCount]);
                }   
            }
            else{
                serverPaymentPlanTypeFinal.push(serverPaymentPlanTypeUnMeas[zCount]);
            }
        } 
        this.getPaymentPlanTypeValues(serverPaymentPlanTypeFinal,component, event, helper);
    },
    //Assign picklist values to respective combo boxes
    getPaymentPlanTypeValues : function(inputvalues,component, event, helper){
        
        component.set('v.paymentPlanTypeRecord', inputvalues); 
        var planTypeName = [];        
        planTypeName.push('');
        
        for(var i=0 ; i< inputvalues.length ; i++ ){
            planTypeName.push(inputvalues[i].objPaymentPlanType.Name);
        }        
        component.set('v.paymentplantype', planTypeName);
        var contractDefault = component.get("v.contractDefault"); 
        if(contractDefault){
            component.set("v.contractDefault",false);
            var contractDetails = component.get("v.getContractDetails"); 
            if(contractDetails[this.setPrefixedString('CurrentPaymentPlanType__c')] != undefined && contractDetails[this.setPrefixedString('CurrentPaymentPlanType__c')] != null){
                component.set("v.selectedPaymentPlanTypeNew",contractDetails[this.setPrefixedString('CurrentPaymentPlanType__c')]);
                this.doSaveQuestionType(component, event, helper);
            }
        }
    },
    //Validations on click of Finish & Generate Instalments button    
    doGenerateInstalments: function(component, event, helper, callingFrom) {
        this.clearNotification(component);
        var contractDetails = component.get("v.getContractDetails");
        // Instalment component will only close when click on Generate Instalment button only
        if(callingFrom == 'callFromGenerateButton'){
            component.set('v.showInstalments', false);            
        }
        var wizObjTest = component.get("v.wizardprop");
        var contractId = wizObjTest.recordId ;
        var errorMessage = [];
        var payMethod = component.get('v.selectedPaymentMethodNew'); 
        if(!payMethod){
            errorMessage.push($A.get("$Label.c.CuAp_PaymentMethod"));
        }
        //Map of Payment Plan Type
        var planTypeId = component.get('v.planTypeId');
        if(!planTypeId){
            errorMessage.push($A.get("$Label.c.CuAp_PaymentPlanTypeErr"));
        }
        var payInFull = component.get('v.paymentPlanPayInFull');
        if(payInFull != $A.get("$Label.c.CuAp_PaymentPlanTypePlanTypePayInFull")){
            
            //Map of day Of Month
            var dayValidation = component.get("v.styleNameDay");
            var dayOfMonth = component.get('v.selectedDayOfMonth');  
            var payFreqOption = component.get('v.payFreqOption');  
            
            if((dayValidation) && (!dayOfMonth) && payFreqOption != $A.get("$Label.c.CuAp_PaymentPlanTypePaymentFrequencyYearly")){
                errorMessage.push($A.get("$Label.c.CuAp_PaymentDayError"));
            }
            //Map of day Of Week
            var dateValidation = component.get("v.styleName");
            var dayOfWeek = component.get('v.selectedDayOfWeek');  
            if(dateValidation && (!dayOfWeek)){
                errorMessage.push($A.get("$Label.c.CuAp_PaymentDateError"));
            } 
        }
        //number Of Instalments
        var numberOfInstalments = component.get("v.numberOfInstalments");
        var numberOfInstalmentsServer = component.get("v.numberOfInstalmentsServer");
        
        var getMaxInstall = component.get("v.objpaymentPlanType1");
        numberOfInstalments = getMaxInstall[this.setPrefixedString('MaximumNumberOfInstalments__c')];
        component.set("v.numberOfInstalments",numberOfInstalments);
        
        if(!numberOfInstalments){
            errorMessage.push($A.get("$Label.c.CuAp_PaymentPlanInstalments"));
        }
        //AT-2449
        if(numberOfInstalments > numberOfInstalmentsServer && !component.get("v.budgetPlan")){
            errorMessage.push($A.get("$Label.c.CuAp_PaymentPlanInstalmentsVal"));
        }
        if(!component.get('v.showInstalments') && component.get('v.saveValidation')){
            errorMessage.push($A.get("$Label.c.CuAp_GenerateInstalments"));
        }
        if(component.get("v.budgetPlan") == true && contractDetails[this.setPrefixedString('BudgetPlanHold__c')] != undefined && contractDetails[this.setPrefixedString('BudgetPlanHold__c')] != null && contractDetails[this.setPrefixedString('BudgetPlanHold__c')] == 'true'){
            errorMessage.push($A.get("$Label.c.CuAp_BudgetPlanOnHold"));
        }
        var objpaymentPlanStartDateNew = component.get("v.paymentPlan");
        var dateScreenVal  = objpaymentPlanStartDateNew[this.setPrefixedString('StartDate__c')];
        var today = new Date();
        var newtoday = today.getFullYear() + "-" + ("0" + (today.getMonth() + 1)).slice(-2) + "-" + ("0" + today.getDate()).slice(-2);        
        
        if(dateScreenVal && dateScreenVal < newtoday){                 
            errorMessage.push($A.get("$Label.c.CuAp_PPStartDateLessThanToday"));
        }
        if(errorMessage.length > 0  ){ 
            component.set('v.showInstalments', false);
            this.showNotification(component, errorMessage, 'error');
            return false;
        }
        //This is to check validation on click of save and Generate Instalment button
        if(component.get('v.saveValidation') != true){            
            if(!dayOfWeek){
                dayOfWeek = null;
            }
            if(!dayOfMonth){
                dayOfMonth = null;
            }
            var paymentPlanRenewalDate = component.get('v.paymentPlanRenewalDate');
            var contractRecord = {sobjectType : this.setPrefixedString('BillingContract__c'),
                                  Id : contractId,
                                  [this.setPrefixedString('CurrentPaymentPlanType__c')] : planTypeId,
                                  [this.setPrefixedString('DayOfMonth__c')] : dayOfMonth,
                                  [this.setPrefixedString('DayOfWeek__c')] : dayOfWeek,
                                  [this.setPrefixedString('PaymentPlanRenewalDate__c')] : paymentPlanRenewalDate
                                 };
            
            var newDate = component.get('v.newDate');
            
            var objpaymentPlanStartDate = component.get("v.paymentPlan");
            newDate = objpaymentPlanStartDate[this.setPrefixedString('StartDate__c')];
            var endDate = objpaymentPlanStartDate[this.setPrefixedString('EndDate__c')]; // AT-3551

            let paramsnew = {"contract": contractRecord,
                             "numberOfInstalments": numberOfInstalments,
                             "planStartDate": newDate,
                             "creditRefund" : wizObjTest.creditRefund,
                             "planEndDate": endDate,
                            };
            //Retrieve list of avail services for the location
            this.callServer(component,'c.calculatePaymentPlan',
                            function(response){ 
                                if(response.instalments != undefined){
                                    var wizObjInst = component.get('v.wizardprop');                                  
                                    wizObjInst.lstInstalments = response.instalments ;
                                    wizObjInst.planStartDate = response.paymentPlan[this.setPrefixedString('StartDate__c')] ;
                                    
                                    // AT-2449
                                    if(component.get("v.budgetPlan")){
                                        if(response.planRenewalDate != null){
                                            wizObjInst.contractRenewalDate = response.planRenewalDate;
                                        }
                                    }
                                    
                                    var objPaymentPlanTypeBudget = component.get("v.objpaymentPlanType1");
                                    var planTypeRec = {sobjectType : this.setPrefixedString('PaymentPlanType__c'),
                                                       ['Name'] : objPaymentPlanTypeBudget.Name,
                                                       [this.setPrefixedString('MaximumNumberOfInstalments__c')] : response.numberOfInstalments
                                                      };
                                    component.set("v.objpaymentPlanType1",planTypeRec);
                                    
                                    component.set("v.wizardprop",wizObjInst);
                                    component.set("v.recordList",response.instalments);
                                    component.set("v.totalInstalmentSum",response.paymentPlan[this.setPrefixedString('PaymentPlanTotal__c')]);
                                    component.set("v.newDate",response.paymentPlan[this.setPrefixedString('StartDate__c')]);
                                    
                                    var readrec = {sobjectType : this.setPrefixedString('PaymentPlan__c'),
                                                   [this.setPrefixedString('StartDate__c')] : response.paymentPlan[this.setPrefixedString('StartDate__c')],
                                                   [this.setPrefixedString('PaymentPlanTotal__c')] : response.paymentPlan[this.setPrefixedString('PaymentPlanTotal__c')],
                                                   [this.setPrefixedString('EndDate__c')]  : endDate //AT-3551
                                                  };
                                    component.set("v.paymentPlan",readrec);
                                    component.set("v.forecastAmount",response.paymentPlan[this.setPrefixedString('ForecastAmount__c')]);	// Sudhir AT2199
                                    component.set("v.paymentPlanTotal",response.paymentPlan[this.setPrefixedString('PaymentPlanTotal__c')]);	// AT-2313
                                    
                                    // activate the wizard
                                    component.set('v.showInstalments', true);
                                }
                                else{
                                    var errorMessagesNew = [];
                                    errorMessagesNew.push(response.getError()[0].message);
                                    this.showNotification(component, response, 'error');
                                    return false;
                                }
                            },                         
                            paramsnew);
        }
        else if(component.get('v.saveValidation')){
            
            var paymentPlanRecord = {sobjectType : this.setPrefixedString('PaymentPlan__c'),
                                     [this.setPrefixedString('PaymentPlanType__c')] : planTypeId ,
                                     [this.setPrefixedString('PaymentPlanTotal__c')] : component.get("v.paymentPlanTotal") // AT-2313
                                    };
            
            var wizObjNew = component.get('v.wizardprop');
            wizObjNew.paymentPlanRecord = paymentPlanRecord;
            wizObjNew.dayOfWeek = dayOfWeek;
            wizObjNew.forecastAmount = component.get("v.forecastAmount") ;	// Sudhir AT 2199
            wizObjNew.dayOfMonth = dayOfMonth;
            wizObjNew.payMethod = payMethod;
            component.set("v.wizardprop",wizObjNew);
        }
    },
    
    // Function on click of save of payment plan type question
    doSaveQuestionType: function(component, event, helper) {
        
        component.set('v.showInstalments', false);
        
        var wizObjInstClear = component.get('v.wizardprop'); 
        wizObjInstClear.lstInstalments = null;
        component.set('v.wizardprop',wizObjInstClear);
        
        if(component.get("v.selectedPaymentPlanTypeNew")){
            component.set("v.selectedPaymentPlanType",component.get("v.selectedPaymentPlanTypeNew"));    
        }
        
        component.set("v.objpaymentPlanType1", {'sobjectType':this.setPrefixedString('PaymentPlanType__c'),
                                                'Name':component.get("v.selectedPaymentPlanType")});
        
        var paymentPlanTypeRecord = component.get('v.paymentPlanTypeRecord');        
        for(var i=0 ; i< paymentPlanTypeRecord.length ; i++ ){
            
            if(component.get("v.selectedPaymentPlanTypeNew") == paymentPlanTypeRecord[i].objPaymentPlanType.Name){
                var planType = paymentPlanTypeRecord[i].objPaymentPlanType[this.setPrefixedString('PlanType__c')];
                var payFreq = paymentPlanTypeRecord[i].objPaymentPlanType[this.setPrefixedString('PaymentFrequency__c')];  
                var maxInstal = paymentPlanTypeRecord[i].objPaymentPlanType[this.setPrefixedString('MaximumNumberOfInstalments__c')]; 
                var planTypeId = paymentPlanTypeRecord[i].objPaymentPlanType.Id;
                var daysNotice = paymentPlanTypeRecord[i].objPaymentPlanType[this.setPrefixedString('DaysNotice__c')]; 
                var specialPlan = paymentPlanTypeRecord[i].objPaymentPlanType[this.setPrefixedString('Special__c')]; // AT-2981                
            }
        }
        component.set('v.specialPlan',specialPlan);  // AT-2981      
        component.set('v.payFreqOption',payFreq);
        component.set('v.paymentPlanPayInFull',planType);
        component.set('v.planTypeId',planTypeId);
        component.set('v.daysNotice',daysNotice);
        
        if(planType && planType == $A.get("$Label.c.CuAp_PaymentPlanTypePlanTypePayInFull")){
        }
        else{
            component.set('v.disableInstalment',false);
        }
        
        if(payFreq != undefined && (payFreq == $A.get("$Label.c.CuAp_PaymentPlanTypePaymentFrequencyWeekly") || payFreq == $A.get("$Label.c.CuAp_PaymentPlanTypePaymentFrequencyFortnightly") )){
            component.set("v.requiredDateTrue",false);
            component.set("v.requiredDayTrue",true);
            component.set("v.styleName","pointer-events: none;opacity: 0.8;");
            component.set("v.styleNameDay","");
            
            if(component.get("v.checkOnEntryVar") != true){
                component.set("v.objAvailPayDay", {'sobjectType':this.setPrefixedString('AvailablePaymentDay__c'),
                                                   [this.setPrefixedString('DayofWeek__c')] :''});	
            }
        }
        else if(payFreq == 'Yearly'){
            component.set("v.requiredDateTrue",true);
            component.set("v.requiredDayTrue",false);
            component.set("v.styleName","");
            component.set("v.styleNameDay","pointer-events: none;opacity: 0.8;");
        }
        else{
            component.set("v.requiredDateTrue",true);
            component.set("v.requiredDayTrue",false);
            component.set("v.styleName","");
            component.set("v.styleNameDay","pointer-events: none;opacity: 0.8;");
            
            if(!component.get("v.checkOnEntryVar")){
                component.set("v.objAvailPayDay", {'sobjectType':this.setPrefixedString('AvailablePaymentDay__c'),
                                                   [this.setPrefixedString('DayofMonth__c')] :''});	
            }
        }
        
        if(planType == $A.get("$Label.c.CuAp_PaymentPlanTypePlanTypePayInFull")){
            component.set("v.requiredDateTrue",true);
            component.set("v.requiredDayTrue",true);
            
        }
        var objpaymentPlanNew = component.get('v.paymentPlan');
        //At-2449
        if(planType == $A.get("$Label.c.CuAp_PaymentPlanTypePlanTypeBudgetPlan")){
            component.set("v.budgetPlan",true);
            component.set('v.paymentPlan', {'sobjectType': this.setPrefixedString('PaymentPlan__c'),
                                            [this.setPrefixedString('StartDate__c')]: objpaymentPlanNew[this.setPrefixedString('StartDate__c')] ,
                                            [this.setPrefixedString('ForecastAmount__c')]: objpaymentPlanNew[this.setPrefixedString('ForecastAmount__c')] , 
                                            [this.setPrefixedString('PaymentPlanTotal__c')]: objpaymentPlanNew[this.setPrefixedString('PaymentPlanTotal__c')], 
                                            [this.setPrefixedString('EndDate__c')]: '' 
                                           }); 
        }
        else{
            component.set("v.budgetPlan",false);
        }      
        
        component.set("v.objpaymentPlanType1", {'sobjectType':this.setPrefixedString('PaymentPlanType__c'),
                                                'Name':component.get("v.selectedPaymentPlanType"),
                                                [this.setPrefixedString('MaximumNumberOfInstalments__c')] : maxInstal});
        
        component.set("v.checkOnEntryVar",false);
        component.set("v.numberOfInstalments",maxInstal);
        component.set("v.numberOfInstalmentsServer",maxInstal);
        
    },
    
    //Had to add the call server here as there was an issue when resolving the
    //component when going to the base class
    callServer : function(component,method,callback,params) {
        
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }        
   //     action.setStorable();
        action.setCallback(this,function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {                 
                callback.call(this,response.getReturnValue());   
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {                    
                    if (errors[0] && errors[0].message) {
                        this.handleError(component, response);
                    }
                } else {
                    throw new Error("Unknown Error");
                }
            }
        });
        
        $A.enqueueAction(action); 
    },
    // handles any errors
    handleError: function(component, response) {
        var errorMessages = [];
        errorMessages.push(response.getError()[0].message);
        this.showError(component, errorMessages);
    },
    
    // shows the error message
    showError: function(component, errorMessages) {
        this.showNotification(component, errorMessages);
    },
    
    handleInputChangeEvent  : function(component, event, helper) {
        component.set('v.showInstalments', false);
        
        var eventParams = event.getParams();
        
        var contractDetails = component.get("v.getContractDetails"); 
        var wizObj = component.get('v.wizardprop'); 
        if(eventParams['objectName'] == this.setPrefixedString('PaymentMethodType__c')){
            
            var objpaymentMethodType = component.get('v.objpaymentMethodType');
            var selectedPaymentMethod = component.get("v.selectedPaymentMethod");
            //AT-2882 - Updated By Dependra for bank Account Details from.
            if(objpaymentMethodType['Name'] == $A.get("$Label.c.PyAp_DirectDebit")){
                wizObj.selectedPaymentMethod = objpaymentMethodType['Name'];
                component.get('v.wizardprop', wizObj); 
                var compEvent = component.getEvent("passValueEvent");
                compEvent.setParam("PicklistValue", objpaymentMethodType['Name']);
                compEvent.fire();  
            }else{
                wizObj.selectedPaymentMethod = objpaymentMethodType['Name'];
                component.get('v.wizardprop', wizObj); 
                var compEvent = component.getEvent("passValueEvent");
                compEvent.setParam("PicklistValue", objpaymentMethodType['Name']);
                compEvent.fire(); 
            }
           
            if(selectedPaymentMethod != null && selectedPaymentMethod != undefined){
                component.set("v.selectedPaymentMethodNew", objpaymentMethodType['Name']); 
            }
            else{
                component.set("v.selectedPaymentMethod", objpaymentMethodType['Name']);
            }
            
            
            // Here Tryin to blank out PPT - START
            component.set("v.selectedPaymentPlanType",'');
            component.set("v.objpaymentPlanType1", {'sobjectType':this.setPrefixedString('PaymentPlanType__c'),
                                                'Name': '',
                                                [this.setPrefixedString('MaximumNumberOfInstalments__c')] : ''});
            
            // Here Tryin to blank out PPT - END
            
            if(contractDetails[this.setPrefixedString('PaymentMethodType__c')] == undefined || contractDetails[this.setPrefixedString('PaymentMethodType__c')] == null
              || contractDetails[this.setPrefixedString('PaymentMethodType__c')] == ''){
                this.doSaveQuestion(component, event, helper);
            }
            
            if(!component.get("v.checkOnEntryVar")){
                this.doSaveQuestion(component, event, helper);
            }
        } 
        
        if(eventParams['objectName'] == this.setPrefixedString('PaymentPlanType__c')){
            var objpaymentPlanType1 = component.get('v.objpaymentPlanType1');         
            
            component.set("v.selectedPaymentPlanTypeNew",objpaymentPlanType1['Name']);
            component.set("v.objAvailPayDay", {'sobjectType':this.setPrefixedString('AvailablePaymentDay__c'),
                                           [this.setPrefixedString('DayofWeek__c')] :'',
                                           [this.setPrefixedString('DayofMonth__c')] :''});
            
            if(contractDetails[this.setPrefixedString('CurrentPaymentPlanType__c')] == undefined || contractDetails[this.setPrefixedString('CurrentPaymentPlanType__c')] == null
              || contractDetails[this.setPrefixedString('CurrentPaymentPlanType__c')] == ''){
                this.doSaveQuestionType(component, event, helper);
            }
            
            if(!component.get("v.checkOnEntryVar")){
                this.doSaveQuestionType(component, event, helper);
            }
        }
        
        if(eventParams['objectName'] == this.setPrefixedString('AvailablePaymentDay__c') && eventParams['fieldName'] == this.setPrefixedString('DayofWeek__c')){
            var objAvailPayDay = component.get('v.objAvailPayDay');      
            component.set("v.selectedDayOfWeek",objAvailPayDay[this.setPrefixedString('DayofWeek__c')]);
        }
        
        if(eventParams['objectName'] == this.setPrefixedString('AvailablePaymentDay__c') && eventParams['fieldName'] == this.setPrefixedString('DayofMonth__c')){            
            var objAvailPayDay = component.get('v.objAvailPayDay');   
            component.set("v.selectedDayOfMonth",objAvailPayDay[this.setPrefixedString('DayofMonth__c')]);
        }    
    }
})