({
    // Your renderer method overrides go here
    //AT-3084 Starts Here
    rerender : function(component, helper) {
        this.superRerender();
        component.set('v.isPicklistPrePopulated',false);
        // Write your custom code here. 
    }
    //AT-3084 Ends Here
})