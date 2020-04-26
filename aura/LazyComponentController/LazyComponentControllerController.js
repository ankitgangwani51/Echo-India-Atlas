({
    doInit : function(component, event, helper) {
        helper.columnsandquickactions(component);
        helper.getOpportunityList(component);
        helper.totalopportunity(component);       
    },
    handleSelectedRow :function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        var NoofRows = selectedRows.length;
        alert(NoofRows);   
    },
    RowAction: function (component, event, helper) {
        var action = event.getParam('action');
        switch (action.name){ 
            case 'New': alert(action.name)
            break;
            case 'edit':alert(action.name)
            break;
            case 'delete': alert(action.name)
            break;
            case 'view':alert(action.name)
            break; 
            default: alert('Salesforce');
        }
    },
    LoadMore:function (component, event, helper) {
        event.getSource().set("v.isLoading", true);
        var recordLimit = component.get("v.initRows");
        var action = component.get("c.getOpportunity");
        action.setParams({
            "Limits": recordLimit,
        });
        action.setCallback(this, function(response) {          
            var state = response.getState();     
            if (state === "SUCCESS" ) {
                var Opplist = response.getReturnValue();
                component.set("v.initRows",component.get("v.initRows")+1);
                event.getSource().set("v.isLoading", false);
                component.set('v.Opplist',Opplist);  
                component.set("v.locallimit",Opplist.length);
            }
        });
        if(component.get('v.totalResult') == component.get('v.locallimit')){
            event.getSource().set("v.isLoading", false);
        }
        else{
            $A.enqueueAction(action);
        }
    },

})