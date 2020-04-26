({
    //This will create the debt recovery process fields from fieldset
    doInit : function(component,event,helper){
        helper.doInit(component, event, helper);
    },
    
    //Clears down the toast message
    doCancel: function(component, event, helper) {
        helper.doCancel(component, event, helper); 
    },    
    
    // Validate the input fields and criteria and fires batch/schedule batch
    runReport: function(component,event,helper){
        helper.runReport(component, event, helper);           
    },
    
    // Validate the input fields and criteria and fires batch/schedule batch for all the debt recovery process records
    runDirectReport: function(component,event,helper){
        helper.runDirectReport(component, event, helper);           
    },
    
    //set the evaluate radio button
    setEvaluate: function(component,event,helper){
        helper.setEvaluate(component, event, helper);           
    },
    
    //set the predict radio button
    setPredict: function(component,event,helper){
        helper.setPredict(component, event, helper);           
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