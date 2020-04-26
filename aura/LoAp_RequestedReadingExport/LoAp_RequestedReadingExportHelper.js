({
    //Handle component initialization
    doInit : function(component, event, helper) {
        var Map1 = new Map(); 
        var Map2 = new Map(); 
        var Map3 = new Map();
        
        Map1.set('Files','ContentDocument');
        Map1.set('Errors',this.setPrefixedString('BatchError__c'));
        component.set('v.mapTabObject',Map1);    
        
        Map2.set('ContentDocument',"['Id','ContentSize','FileType']");
        Map2.set(this.setPrefixedString('BatchError__c'),[this.setPrefixedString('ErrorDetails__c'),this.setPrefixedString('OperatingRecordId__c')]);        
        component.set('v.mapObjectFields',Map2);
        Map3.set(this.setPrefixedString('BatchRequestQueue__c'), this.setPrefixedString($A.get('$Label.c.LoAp_RequestedReadFieldSet')));
        component.set('v.mapBRQFieldSet',Map3);
    }, 
    // New request method to create BRQ record.
    newRequest: function(component, event, helper) {
        this.callServer(component,'c.createBRQ',
                        function(response){
                            $A.get('e.force:refreshView').fire();
                        },
                        null);
        
    },    
    
})