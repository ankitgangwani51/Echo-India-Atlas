({
    reset: function(component) {
        component.set('v.spinnerCounter', 0);
        component.set('v.showSpinner', false);
	},
	
    show: function(component) {
        var spinnerCounter = component.get('v.spinnerCounter');
        if (spinnerCounter++ === 0) {
	        console.log('SpinnerComponent: ' + 'show spinner');
	        component.set('v.showSpinner', true);
	    }
        component.set('v.spinnerCounter', spinnerCounter);
    },
    
	hide: function(component) {
        var spinnerCounter = component.get('v.spinnerCounter');
        if (--spinnerCounter <= 0) {
        	component.set('v.showSpinner', false);
        }
        component.set('v.spinnerCounter', spinnerCounter);
    },
})