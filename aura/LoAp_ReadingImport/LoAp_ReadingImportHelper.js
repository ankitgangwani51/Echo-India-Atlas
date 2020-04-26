({
    doInit : function(component, event, helper) {
        var Map1 = new Map(); 
        var Map2 = new Map(); 
        var Map3 = new Map();
        
        /*Map1  to create folders*/
        Map1.set($A.get("$Label.c.LoAp_Files"),'ContentDocument');
        Map1.set($A.get("$Label.c.LoAp_Errors"),this.setPrefixedString('BatchError__c'));
        Map1.set($A.get("$Label.c.LoAp_Staging"),this.setPrefixedString('ReadingUpload__c'));
        component.set('v.mapTabObject',Map1);
        
        /*Map2 to display the fields in respective folder */
        var BatchErrorFields = '[\'' + this.setPrefixedString('BatchRequestOperation__c') + '\',\'' + this.setPrefixedString('ErrorDetails__c')  + '\',\'Name\',\'' + this.setPrefixedString('BatchRequestType__c')  + '\',\'' + this.setPrefixedString('OperatingRecordId__c')  + '\']';
        var ReadingUploadFields = '[\'' + this.setPrefixedString('SerialNumber__c') + '\',\'' + this.setPrefixedString('ReadingDate__c')  + '\',\'' + this.setPrefixedString('ReadingStatus__c')  + '\']';
        Map2.set('ContentDocument',"['Title','ContentSize','FileType']");
        Map2.set(this.setPrefixedString('BatchError__c'),BatchErrorFields); 
        Map2.set(this.setPrefixedString('ReadingUpload__c'),ReadingUploadFields);
        component.set('v.mapObjectFields',Map2);        
        
        Map3.set(this.setPrefixedString('BatchRequestQueue__c'),this.setPrefixedString($A.get("$Label.c.LoAp_ReadingImportLabel")));
        component.set('v.mapBRQFieldSet',Map3);
    },
    
    showNewReadingImport : function(component, event, helper) {       
        component.set("v.showNewReadingImport", true);       
    },
    
    closeNewReadingImport: function(component, event, helper) {
        component.set("v.showNewReadingImport", false);
    }
})