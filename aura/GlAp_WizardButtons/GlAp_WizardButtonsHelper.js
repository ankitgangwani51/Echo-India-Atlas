({
    doCancel: function(component, event, helper) {	
        var cmpEvent = component.getEvent('wizEvent');
        cmpEvent.setParams({'message': 'CANCEL'});
        cmpEvent.fire();
    },
    doNext: function(component, event, helper) {	
        var cmpEvent = component.getEvent('wizEvent');
        cmpEvent.setParams({'message': 'NEXT'});
        cmpEvent.fire();
    },
    doBack: function(component, event, helper) {	
        var cmpEvent = component.getEvent('wizEvent');
        cmpEvent.setParams({'message': 'BACK'});
        cmpEvent.fire();
    }
})