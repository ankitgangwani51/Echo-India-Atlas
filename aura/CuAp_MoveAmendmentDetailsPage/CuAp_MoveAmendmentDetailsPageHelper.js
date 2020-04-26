({
	DEBUG: 'MoveAmendmentDetailsPage: ',

    /* REQUIRED BY FRAMEWORK - these helper functions must be implemented by the wizard page */
    // clear the entered data and start afresh
    reInitialise: function(component, event, helper) {        
        console.log(this.DEBUG + 'reInitialise');
     
        component.set('v.previousOccupier', {'sobjectType': this.setPrefixedString('LocationOccupant__c'),
                                        [this.setPrefixedString('StartDate__c')]: '' ,
                                        [this.setPrefixedString('EndDate__c')]: '' 
                                       });
        
        component.set('v.nextOccupier', {'sobjectType': this.setPrefixedString('LocationOccupant__c'),
                                        [this.setPrefixedString('StartDate__c')]: '' ,
                                        [this.setPrefixedString('EndDate__c')]: '' 
                                       });

    },

    // check the wizardprop/status on entry
    checksOnEntry: function(component, event, helper) {
        // do checks here if required
        console.log(this.DEBUG + 'checksOnEntry');
        var wizObj = component.get('v.wizardprop');
        var startDate ;
        var endDate;
        var prevOccTicked = false;
        var subOccTicked = false;
        if(wizObj.moveInDate || wizObj.moveOutDate){
            startDate = wizObj.moveInDate;
            endDate = wizObj.moveOutDate;
        }
        else{
           startDate = wizObj.selectedLocOcc[this.setPrefixedString('StartDate__c')];  
           endDate = wizObj.selectedLocOcc[this.setPrefixedString('EndDate__c')];
        }
        
        if(wizObj.prevOcc || wizObj.subsequentOcc){
            prevOccTicked = wizObj.prevOcc;
            subOccTicked = wizObj.subsequentOcc;
        }
        
        if (wizObj.selectedLocOcc ){            
            component.set('v.locationOccDetails', {'sobjectType':this.setPrefixedString('LocationOccupant__c'),
                                                   [this.setPrefixedString('Account__c')]: wizObj.accountName,
                                                   [this.setPrefixedString('Location__c')]: wizObj.locationName,
                                                   [this.setPrefixedString('StartDate__c')]: startDate,
                                                   [this.setPrefixedString('EndDate__c')]:  endDate,
                                                   [this.setPrefixedString('PreviousOcc__c')]:  prevOccTicked,
                                                   [this.setPrefixedString('SubsequentOcc__c')]:  subOccTicked
                                                  });
        }
        
        if(!wizObj.selectedLocOcc[this.setPrefixedString('EndDate__c')]){
            component.set('v.editOrNot', false); 
        }
        
        let params ={
            "locId": wizObj.locationId,
            "loccOcc":wizObj.selectedLocOcc
        };  
        this.callServer(component,'c.getLocAndLocOccDetails', 
                        function(response) {
                            console.log(this.DEBUG + 'response:getLocAndLocOccDetails ' + JSON.stringify(response));    
                            component.set('v.resultContainer', response);
                            component.set('v.locationOccupantFields', component.get('v.resultContainer').twoColFormattedList);
                            component.set('v.prevOccStartDate', component.get('v.resultContainer').prevOccStartDate); 
                            component.set('v.nextOccEndDate', component.get('v.resultContainer').nextOccEndDate);                            
                            component.set('v.previousOccupier', component.get('v.resultContainer').previousOccupier);                            
                            component.set('v.nextOccupier', component.get('v.resultContainer').nextOccupier);
							component.set('v.auAmendOrNormalAmend', component.get('v.resultContainer').auAmendment);                            
                        },
                        params); 
    },
   
    // validates the wizardprop on completion of the step
    validateOnNext: function(component, event, helper) {
    	// do all completion validation here
    	console.log(this.DEBUG + 'validateOnNext');
        var locOcc = component.get('v.locationOccDetails');
        var wizObj = component.get('v.wizardprop');        
        var errorList = [];  
        var auAmendOrNormalAmend = component.get('v.auAmendOrNormalAmend');
      
        if(locOcc[this.setPrefixedString('StartDate__c')]){
            
            if (locOcc[this.setPrefixedString('EndDate__c')] && !(locOcc[this.setPrefixedString('EndDate__c')] > locOcc[this.setPrefixedString('StartDate__c')])) {
                errorList.push($A.get('$Label.c.CuAp_ValidationAmendMoveInDate2'));
            } 
            if (!(locOcc[this.setPrefixedString('EndDate__c')] == wizObj.selectedLocOcc[this.setPrefixedString('EndDate__c')])
                && !(locOcc[this.setPrefixedString('StartDate__c')] == wizObj.selectedLocOcc[this.setPrefixedString('StartDate__c')])){
                errorList.push($A.get('$Label.c.CuAp_ValidationAmendMoveDates'));            
            }
            if(locOcc[this.setPrefixedString('StartDate__c')] < component.get('v.prevOccStartDate')){
                errorList.push($A.get('$Label.c.CuAp_ValidationAmendMoveInDate3')); 
            } 
            if(locOcc[this.setPrefixedString('EndDate__c')] && locOcc[this.setPrefixedString('EndDate__c')] > component.get('v.nextOccEndDate')){
                errorList.push($A.get('$Label.c.CuAp_ValidationAmendMoveOutDate'));
            }
            
            console.log('new start date---'+ locOcc[this.setPrefixedString('StartDate__c')]);
            console.log('old start date---'+ wizObj.selectedLocOcc[this.setPrefixedString('StartDate__c')]);
            console.log('PreviousOcc__c--' + locOcc['PreviousOcc__c']);
            console.log('previousOccupier---'+ JSON.stringify(component.get('v.previousOccupier')) );
            console.log('SubsequentOcc__c--' + locOcc['SubsequentOcc__c']);
            console.log('nextOccupier---'+ JSON.stringify(component.get('v.nextOccupier')));
            console.log('endddd---'+ locOcc[this.setPrefixedString('EndDate__c')]);
            console.log('endddd2222---'+ wizObj.selectedLocOcc[this.setPrefixedString('EndDate__c')]);
            console.log('auAmendOrNormalAmend---'+ auAmendOrNormalAmend);
            
            //New Move in Date prior to Original Move In Date and Adjust Previous Occupancy not ticked 
            if(auAmendOrNormalAmend && locOcc['PreviousOcc__c'] != undefined && component.get('v.previousOccupier') && locOcc[this.setPrefixedString('StartDate__c')] < wizObj.selectedLocOcc[this.setPrefixedString('StartDate__c')] && locOcc['PreviousOcc__c'] != true){
                errorList.push($A.get('$Label.c.CuAp_AUMoveAmendAdjustPrevOccValid'));
            }
            
            //New Move out Date prior to Original Move out Date and Adjust Subsequent Occupancy not ticked
            if(auAmendOrNormalAmend && locOcc['SubsequentOcc__c'] != undefined && component.get('v.nextOccupier') && locOcc[this.setPrefixedString('EndDate__c')] > wizObj.selectedLocOcc[this.setPrefixedString('EndDate__c')] && locOcc['SubsequentOcc__c'] != true){
                errorList.push($A.get('$Label.c.CuAp_AUMoveAmendAdjustSubOccValid'));
            }
            
            console.log('prev occ -----'+ JSON.stringify(component.get('v.previousOccupier')));
            console.log('next occ -----'+ JSON.stringify(component.get('v.nextOccupier')));
        }
        else{
            errorList.push($A.get('$Label.c.CuAp_ValidationAmendMoveInDate1'));
        }
        
        
        if (errorList.length > 0) {
            this.showNotification(component, errorList);
            return false;
        }  
        // populate the wizard properties
      
        
        // AT-4024 This is used without Namespace as this is a dummy field which is used to get the checkbox value
        if(locOcc['PreviousOcc__c'] && locOcc['PreviousOcc__c'] == true){
            wizObj.prevOcc = true;
        }
        if(locOcc['SubsequentOcc__c'] && locOcc['SubsequentOcc__c'] == true){
            wizObj.subsequentOcc = true;
        }
        
        wizObj.moveOutDate = null;
        wizObj.moveInDate = null;  
    
        if (locOcc[this.setPrefixedString('EndDate__c')] && !(locOcc[this.setPrefixedString('EndDate__c')] == wizObj.selectedLocOcc[this.setPrefixedString('EndDate__c')])) {
           wizObj.moveOutDate = locOcc[this.setPrefixedString('EndDate__c')];
        }
   
   		if(!(locOcc[this.setPrefixedString('StartDate__c')] == wizObj.selectedLocOcc[this.setPrefixedString('StartDate__c')])){
           wizObj.moveInDate = locOcc[this.setPrefixedString('StartDate__c')];
        }
              
        wizObj.combinedSPLists = null; //to be used in next screen 
        
        component.set('v.wizardprop',wizObj); 
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
   
})