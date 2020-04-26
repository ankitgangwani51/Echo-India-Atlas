({
    //This will create the void management process fields from fieldset
    doInit : function(component,event,helper){
        helper.doInit(component, event, helper);
    },
    
    // Validate the input fields and criteria and fires batch/schedule batch
    runReport: function(component,event,helper){
        helper.runReport(component, event, helper);           
    },
    
    //set the immediate radio button
    setImmediate: function(component,event,helper){
        helper.setImmediate(component, event, helper); 
    },
    
    //set the daily radio button
    setDaily: function(component,event,helper){
        helper.setDaily(component, event, helper);  
    },
    
    //set the weekly radio button
    setWeekly: function(component,event,helper){
        helper.setWeekly(component, event, helper);  
    },
    
    //set the monthly radio button
    setMonthly: function(component,event,helper){
        helper.setMonthly(component, event, helper);  
    }
})