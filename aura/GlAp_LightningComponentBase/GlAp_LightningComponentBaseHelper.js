({
	getObjectFieldsIn2ColForm : function(component, event, helper, callback){
		let params = {
            "objectAPIName": component.get("v.objectType"),
            "fieldSetName": component.get("v.fieldSet")            
       	};
       	
		helper.callServer(	component,'c.getObjectsFieldPropertiesByFieldSetNameFor2ColForm',
	    					function(response){
	        					callback.call(this,response);
	        					      					
	    					},      				
        params);      	
	},
	getObjectFields : function(component, event, helper, callback){
		let params = {
            "objectAPIName": component.get("v.objectType"),
            "fieldSetName": component.get("v.fieldSet")  
       	};
		helper.callServer(	component,'c.getObjectsFieldPropertiesByFieldSetName',
	    					function(response){
	        					
	        					callback.call(this,response);
	        					      					
	    					},      				
        params);      	
	},
	getObjectList : function(component, event, helper, callback){
	let params = {
            "sId": component.get("v.recordId"),
            'parentField' : component.get("v.parentField"),
            "listFilter" : component.get("v.listFilter"),
            "objectAPIName": component.get("v.objectType"),
            "fieldSetName": component.get("v.fieldSet") 
       	};
       					  
        helper.callServer(	component,'c.getRelatedRecordsByFieldSetName',
        					function(response){
            					callback.call(this,response);      					
        					},
        					params);
	},
	getObjectRecord : function(component, event, helper, callback){  
        
		let params = {
            "sId": component.get("v.recordId"),
            "objectAPIName": component.get("v.objectType"),
            "fieldSetName": component.get("v.fieldSet") 
       	};
        helper.callServer(	component,'c.getRecordByIdAndFieldSetName',
        					function(response){
            					callback.call(this,response);      					
        					},
        					params);	
	},
    getFilteredRecordsByFieldList : function(component, event, helper, callback){  
		let params = {
            "sWhereClause": component.get("v.whereClause"),
            "objectAPIName": component.get("v.objectType"),
            "fieldNames": component.get("v.listOfFields") 
       	};
        helper.callServer(	component,'c.getFilteredRecordsByFieldList',
        					function(response){
            					callback.call(this,response);      					
        					},
        					params);	
	},
	doObjectSave : function(component, event, helper, callback) {
		var sObj = component.get("v.client");
		var action = component.get("c.updateObject");
		
		var sObjString = JSON.stringify(sObj);
		let params = {
            "objectAPIName": component.get("v.objectType"),
            "recordClientString": sObjString
       	};
        helper.callServer(	component, 'c.updateObject',
			function(response){
				callback.call(this,response);
			},
			params);      		
	},
	callServer : function(component,method,callback,params) {
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }
    	if (component.find('spinner')) component.find('spinner').show();
        action.setCallback(this, function(response) {
            if (component.find('spinner')) component.find('spinner').hide();
            var state = response.getState();
            if (state === "SUCCESS") { 
                callback.call(this,response.getReturnValue());   
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        throw new Error("Error" + errors[0].message);
                    }
                } else {
                    throw new Error("Unknown Error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    // switch to another record page
    goToRecord: function(recordId) {
        var evt = $A.get('e.force:navigateToURL');
        evt.setParams({
            url: '/one/one.app#/sObject/' + recordId
        });
        evt.fire();
    },
    
    // adds the namespace prefix to a object/field api name
    setPrefixedString: function(value) {
        return (($A.get('$Label.c.GlUt_NSPrefix') == 'BLANK') ? '' : $A.get('$Label.c.GlUt_NSPrefix')) + value;
    }
})