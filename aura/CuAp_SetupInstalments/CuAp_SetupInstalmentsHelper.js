({
    // This function will display the list of instalments in the generic table with table header
    doInit: function(component, event, helper) {  
        
        var lstInstalments = component.get('v.recordList');        
        
        
        this.callServer(component,'c.retrieveInstalmentPropDetails',
                          function(response){
                              component.set('v.fieldList', response);
                          },      				
                          null);
        
        let params = {
            "lstInstalments": JSON.stringify(lstInstalments)
        };
        
        this.callServer(component,'c.retrieveInstalmentsRecord',
                          function(response){
                              component.set('v.firstinstamt',response[0].objectMap[this.setPrefixedString('Instalment__c')][this.setPrefixedString('InstalmentAmountDue__c')]);                              
                              component.set('v.recordList', response);  
                              
                          },      				
                          params);
    },
    
    // This function is allocate the first instalment amount to the first instalment and spread the remaining amount to the remaining instalments
    doSpreadRemaining: function(component, event, helper) {
        //Clears down the toast messages displays on screen
        component.find('notification').clearNotification();
        this.clearNotification(component);
        //define newRecordList array to assign the records with the new instalment amount.
        var newRecordList   = [];
        
        var recList         = component.get("v.recordList");
        var firstinstamt    = component.get("v.firstinstamt");
        var remainingInstAmt = component.get('v.remainingInstAmt');
        var instalmentTotal = component.get("v.totalInstalmentSum");
        
        //Field Criteria Validations        
        if (recList == ""){
            component.find('notification').showNotification([$A.get("$Label.c.CuAp_NoInstExist_SpreadRemaining")],'error');
            return false;
        }
        
        if (firstinstamt == null){
            component.find('notification').showNotification([$A.get("$Label.c.CuAp_FirstInstCantNull")],'error');            
            return false;
        }
        
        if (firstinstamt < 1 ){
            component.find('notification').showNotification([$A.get("$Label.c.CuAp_FirstInstCantLessThan1")],'error');
            return false;
        }
        
        if(firstinstamt > instalmentTotal){
            component.find('notification').showNotification([$A.get("$Label.c.CuAp_FirstInstNotEqualInstTotal") + ' ' + instalmentTotal],'error');
            return false;
        }
        
        //Assign the first instalment amount in the first record of the array recList.
        var firstRecord = recList[0];
        firstRecord.objectMap[this.setPrefixedString('Instalment__c')][this.setPrefixedString('InstalmentAmountDue__c')] = firstinstamt;
        newRecordList.push(firstRecord);
        
        var icnt = 0;
        
        for(var i=0;i<recList.length;i++){
            
            if(recList[i].objectMap[this.setPrefixedString('Instalment__c')][this.setPrefixedString('Type__c')] != $A.get("$Label.c.CuAp_RollingLabelInstalment")){
                icnt = icnt + 1;
            }
        }
        
        // code fix as per AT-2092
        var remainingAmt = instalmentTotal - firstinstamt;        
        var partitionAmt = Math.round((remainingAmt / (icnt - 1)) * 100) / 100;
        var reverseAmt = Math.round((partitionAmt * (icnt - 1)) * 100) / 100;
        var difference = Math.round((remainingAmt - reverseAmt) * 100) / 100; 
        
        var amtForRolling = partitionAmt ;
        
        //get the remaining instalment records and assign the remaining instalment amount values to the newRecordList array
        for(var i=1;i<recList.length;i++){
            if(i == recList.length - 1 || i == icnt - 1){
             partitionAmt = partitionAmt + difference;   
            }
            var recEntry = recList[i];
            if(!remainingInstAmt){
                if(recList[i].objectMap[this.setPrefixedString('Instalment__c')][this.setPrefixedString('Type__c')] != $A.get("$Label.c.CuAp_RollingLabelInstalment")){
                    amtForRolling = partitionAmt;
                    recEntry.objectMap[this.setPrefixedString('Instalment__c')][this.setPrefixedString('InstalmentAmountDue__c')] = partitionAmt;
                }
                else{
                    recEntry.objectMap[this.setPrefixedString('Instalment__c')][this.setPrefixedString('InstalmentAmountDue__c')] = amtForRolling;
                }
            }
            else{ // AT-2981
                recEntry.objectMap[this.setPrefixedString('Instalment__c')][this.setPrefixedString('InstalmentAmountDue__c')] = remainingInstAmt;
            }
            newRecordList.push(recEntry);
        }
        
        component.set('v.recordList',"");
        component.set('v.recordList',newRecordList);
        
    },
    
    // call the notifier method to clear a message on the notification component on the wizard
    clearNotification: function(component) {
        component.find('notifier').clearNotification();
    }, 
    
    // This function will delete the selected instalments
    doDeleteSelected: function(component, event, helper) {
        component.find('notification').clearNotification();
        this.clearNotification(component);
        
        var recList = component.get("v.recordList");
        if(recList == ""){
            component.find('notification').showNotification([$A.get("$Label.c.CuAp_NoInstExist")],'error');
            return false;
        }
        
        var getDeleteRecordList = component.get("v.deleteRecordList");
        if(getDeleteRecordList == ''){
            component.find('notification').showNotification([$A.get("$Label.c.CuAp_PleaseSelectInst")],'error');
            return false;
        }
        component.set("v.questionMessage",true);
    },
    
     // This function is basically for the confirmation for delete selected instalments
    doDeleteQuestion: function(component, event, helper) {
        
        // define getDeleteRecordList array to get the list of instalment numbers to be delete                
        var getDeleteRecordList = []; 
        
        // define newRecordList array to get the list of remaining records to be displayed
        var newRecordList = []; 
        
        var recList = component.get("v.recordList");
        
        for(var i = 0;i<component.get("v.deleteRecordList").length;i++){
            getDeleteRecordList.push(component.get("v.deleteRecordList")[i]);
        }       
        
        //delete the selected records and assign the remaining records to the new array newRecordList 
        for(i = 0;i<recList.length;i++){
            if(getDeleteRecordList.indexOf(recList[i].objectMap[this.setPrefixedString('Instalment__c')][this.setPrefixedString('InstalmentNumber__c')].toString()) < 0){
                newRecordList.push(recList[i]);
            }
        }
        
        //Re-assign the uniqueID for the remaining records in the newRecordList array like this:- 1,2,3,4...
        for(i = 0;i<newRecordList.length;i++){            
            newRecordList[i].uniqueId = (i + 1).toString();
            newRecordList[i].objectMap[this.setPrefixedString('Instalment__c')][this.setPrefixedString('InstalmentNumber__c')] = newRecordList[i].uniqueId;
        }
        
        //Need to set recordList attribute as blank so that new array will display correctly...
        component.set('v.recordList',"");        
        
        component.set('v.recordList',newRecordList);            
        
        component.set("v.questionMessage",false);
        
        //To display toast for some couple of seconds
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "message": $A.get("$Label.c.CuAp_DeleteInstalmentSuccessful") 
        });        
        toastEvent.fire();
        
        //Blank out the deleteRecordList attribute so that user can select new records for delete
        component.set("v.deleteRecordList","");    
    },
    
    // This function will close the delete confirmation modal
    doCancelQuestion: function(component, event, helper) { 
        component.set("v.questionMessage",false);
    },
    
    // This function will get the list of selected instalments to delete
    handleRowSelectEvent: function(component, event, helper) {
        component.find('notification').clearNotification(); 
        var sRowId = event.getParam('RowId');
        var deleteRecordList = [];
        var indexNum;
        var recList = component.get("v.recordList");
        for(var i = 0; i < recList.length; i++){
            if(recList[i].uniqueId == sRowId && recList[i].isSelected == true){
                
                if(component.get("v.deleteRecordList") == ''){
                    deleteRecordList.push(sRowId);                    
                }else{
                    deleteRecordList.push(sRowId);
                    var getDeleteRecordList1 = [];
                    getDeleteRecordList1 = component.get("v.deleteRecordList");
                    
                    for(var k = 0;k<getDeleteRecordList1.length;k++){
                        deleteRecordList.push(getDeleteRecordList1[k]);
                    }
                }
                component.set("v.deleteRecordList",deleteRecordList);
            }
            
            
            if(recList[i].uniqueId == sRowId && recList[i].isSelected == false){
                var getDeleteRecordList = [];
                
                getDeleteRecordList = component.get("v.deleteRecordList");
                for(var j = 0;j<getDeleteRecordList.length;j++){
                    if(getDeleteRecordList[j] != sRowId){
                        deleteRecordList.push(getDeleteRecordList[j]);
                    }
                }
                component.set("v.deleteRecordList",deleteRecordList);
            }
            
        }
    }
})