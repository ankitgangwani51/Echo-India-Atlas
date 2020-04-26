({
	doInit : function(component, event, helper) {
        
        component.set("v.objSPBand",  {'sobjectType':this.setPrefixedString('SupplyPointBand__c')});        
        
        //Retrieve Supply Point Band fields Prop info
        this.callServer(component,'c.retrieveSupplyPointBandFields', 
                        function(response) {
                            component.set('v.spbFields', response);                            
                        },
                        null);	
        
        //Retrieve Supply Point Band Record 
        let params = {'supplyPointId' : component.get("v.recordId")
                     };
        
        this.callServer(component,'c.fetchSupplyPointBandData', 
                        function(response) {
                            component.set("v.objSPBand",response );      
                        },
                        params);
        
        component.set('v.objectName',this.setPrefixedString('SupplyPointBand__c'));        
	},
	
	//Opens Component
    doOpenBandChangeComponent : function(component) {
        
      component.set("v.showBandChangeComponent", true);
      component.set("v.objNewSPBand", {'sobjectType':this.setPrefixedString('SupplyPointBand__c'),
                                         [this.setPrefixedString('BandType__c')] 	: '',
                                         [this.setPrefixedString('BandValue__c')] 	: '',
                                         [this.setPrefixedString('StartDate__c')] 	: '',
                                         [this.setPrefixedString('EndDate__c')] 	: ''});
        //Retrieve Supply Point Band Record 
        let params = {'supplyPointId' : component.get("v.recordId")
                     };
        
        this.callServer(component,'c.fetchSupplyPointBandData', 
                        function(response) {
                            component.set("v.objSPBand",response );      
                        },
                        params);
    },
    
    //action on Cancel button click
    doCancel : function(component) {
        component.set("v.showBandChangeComponent", false);
    },
	
    //action on Save button click
    doSave : function(component, event, helper) {
        
        var newSPBand = component.get('v.objNewSPBand');  
        if(this.validateRecord(component,newSPBand)){
            //make a server call to Save Supply Point Band Record 
            var action = component.get("c.saveSupplyPointBandRecord");
            action.setParams({
                'newSPBand': newSPBand,
                'oldSPBand': component.get('v.objSPBand'),
                'supplyPointId' : component.get('v.recordId')                
            });
            action.setCallback(this, function(response){
                if(response.getState() === 'SUCCESS') {
                    component.set("v.newSPBandId", response.getReturnValue());
                    if(response){
                        component.set('v.isActive',true);
                        var calculateBillCmp = component.find('calculatePendingBillComponent');
                        calculateBillCmp.calculateBills(function(response) {});   
                        
                        //To display toast for some couple of seconds
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "success",
                            "message": $A.get("$Label.c.LoAp_SupplyPointBandAdded") 
                        });        
                        toastEvent.fire();
                    }
                                       
                } else {
                    this.handleError(component, response);
                }
            });
            $A.enqueueAction(action);
        }        
    },
    
    handleBillCalculationComplete: function(component, event, helper) {
        component.set('v.isActive',false);
        component.set("v.showBandChangeComponent", false);
        
    },
    
    //validate New Supply Point Band Record
    validateRecord : function(component,newSPBand) {        
        var bandType = newSPBand[this.setPrefixedString('BandType__c')];
        var bandValue = newSPBand[this.setPrefixedString('BandValue__c')];
        var startDate = newSPBand[this.setPrefixedString('StartDate__c')];
        var endDate = newSPBand[this.setPrefixedString('EndDate__c')];
        
        //Start Date Must be Populated
        if (startDate == ''){
            component.find('notification').showNotification([$A.get('$Label.c.LoAp_StartDateBlankError')],'error');                
            return false;
        }
        //Band Must be Populated
        if (bandType == ''){
            component.find('notification').showNotification([$A.get('$Label.c.LoAp_BandTypeBlankError')],'error');                
            return false;
        }
        //Band Value Must be Populated
        if (bandValue == ''){
            component.find('notification').showNotification([$A.get('$Label.c.LoAp_BandValueBlankError')],'error');                
            return false;
        }
        //Start Date Must be less than End Date
        if ((endDate != '') && (startDate == endDate || startDate > endDate)){
            component.find('notification').showNotification([$A.get('$Label.c.LoAp_StartDateLTEndDate')],'error');                
            return false;
        }
        return true;
    },
    
    handleError : function(component, response) {	
        var errorMessage = [] ;
        errorMessage.push(response.getError()[0].message) ;
        this.showError(component, errorMessage) ;
    },
    
    showError : function(component, errorMessage) {
        component.find('notification').showNotification(errorMessage, 'error') ;
    },
    
    showNotification: function(component, message, type) {
        component.find('notification').showNotification(message, type);
    },
    
})