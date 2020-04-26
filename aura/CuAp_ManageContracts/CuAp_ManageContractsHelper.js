({
    DEBUG:	'ManageContracts: ',
    //Fetch the records from wizard cancel button.
    doisWizardCancel : function(component) {
        if(!component.get('v.isWizardActive')){
            component.set('v.lcHost',  'https://' +  window.location.hostname  + '/img/icon/t4v35/custom/custom37_120.png');
            var recordId = component.get('v.recordId');
            var childCmp = component.find('getServiceRelatedInfo');
            var result   = childCmp.getServiceRelatedInfo(recordId);
        }
    },
    //Show Manage Contract Wizard.
    doAdd : function(component) {
        var ErrorMessageVal = [];
        if(component.get('v.servicesRemove').length > 0){
            ErrorMessageVal.push($A.get('$Label.c.CuAp_SelectServiceAdd'));
            // Check if there is any error in array
            if (ErrorMessageVal.length > 0) {
                this.showNotification(component, ErrorMessageVal);
            } 
        }else{
            component.set('v.wizardType','Add');
            component.set('v.isWizardActive',true);
        }
    },
    //Show Manage Contract Wizard with Service that needs to be remove from contract.
    doRemove : function(component) {
        var ErrorMessageVal = [];
        if(component.get('v.servicesRemove').length > 0){
            component.set('v.wizardType','Remov');
            component.set('v.isWizardActive',true);
        }else{
            ErrorMessageVal.push($A.get('$Label.c.CuAp_SelectServiceMandatory'));
            // Check if there is any error in array
            if (ErrorMessageVal.length > 0) {
                this.showNotification(component, ErrorMessageVal);
            }
        }
    },
    //Hide Manage Contract Component.
    doCancel : function(component) {
        component.set('v.isActive',false); 
    },
    //Show Manage Contract Component.
    showManageContractComponent: function(component) {
        component.set('v.isActive',true);
        var recordId = component.get('v.recordId');
        var childCmp = component.find('getServiceRelatedInfo');
        var result   = childCmp.getServiceRelatedInfo(recordId);
        this.clearNotification(component);
        
    },
    // call the notifier method to show a message on the notification component.
    showNotification: function(component, message, type) {
        component.find('notification').showNotification(message, type);
    },
    
    // call the notification component method to clear a notification
    clearNotification: function(component) {
    	this.showNotification(component, null);
    },
    
})