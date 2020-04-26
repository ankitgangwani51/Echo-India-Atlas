({
    getOpportunityList : function(component) {
        var action = component.get("c.getOpportunity");
        action.setParams({
            "Limits": component.get("v.initRows")
        });
        action.setCallback(this, function(response) {          
           var state = response.getState();
            if (state === "SUCCESS" ) {
                alert('result == '+JSON.stringify(response.getReturnValue()));
                /*var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    'title' : 'Load',
                    'message' : 'Opportunity Load Sucessfully.'
                });
                showToast.fire();*/
                var Opplist = response.getReturnValue();
                component.set("v.Opplist",Opplist);
                var nextlimit = component.get("v.initRows")+component.get("v.Count");
                component.set("v.initRows",nextlimit);
            }
        });
        $A.enqueueAction(action);
    },
    columnsandquickactions: function(component){
        var actions =[
            {label: 'New', name:'New'},
            {label: 'Edit',name:'edit'},
            {label: 'View' ,name:'view'},
            {label: 'Delete', name: 'delete'}         
        ];
        component.set('v.columns',[{label:'Name',fieldName:'Name', type:'text',shortable:true},
            {label:'Account Name', fieldName:'AccountId', type:'Account Name',shortable:true},
            {label: 'Phone', fieldName: 'Phone', type: 'phone'},
            {label: 'Stage', fieldName:'StageName', type:'text'},
            {label: 'Close Date', fieldName:'CloseDate', type:'text'},
            {type:'action', typeAttributes:{
               rowActions:actions
            }}
        ]);
    },
   totalopportunity : function(component) {
        var action = component.get("c.TotalOpportunity");
       action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" ) {
                var resultData = response.getReturnValue();
                component.set("v.totalResult",resultData);
            }
        });
        $A.enqueueAction(action);
    },
})