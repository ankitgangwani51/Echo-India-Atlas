({
	doInit : function(component, event, helper) {
        var object;
        
        var transformField = component.get('v.transformField');
        
        var objectList = component.get('v.object');
        var objectName = component.get('v.objectName');
        
        //See if multiple objects are passed in, then get the object for the object type
        //otherwise assume just one object
        try{
        		if(transformField){
        			object = objectList.transformFieldMap[objectName];
        		}
        		else{
        			object = objectList.objectMap[objectName];
        		}
        		
        }
        catch(e){
        		object = objectList;
        }
        
        var fieldType = component.get('v.fieldType');
        var fieldName = component.get('v.fieldName');
        var picklistValues = component.get('v.picklistValues');
        var value;
        
        //Set field to readonly if has been set specifically for this object
        try{
            if(objectList.readOnlyFields != null && objectName != null){
                var curFieldName = objectName+'.' + fieldName;
                var fieldIsEditable = objectList.readOnlyFields[curFieldName];
     			component.set('v.readOnly', fieldIsEditable);
            }
        }
        catch(e){
            
       	}
        
        if(fieldName && fieldName.includes(".")) {
            component.set("v.value", object[fieldName.split(".")[0]][fieldName.split(".")[1]]);
        } else {
            try{
                var fldVal = object[fieldName];
            	component.set("v.value", fldVal);
            }
            catch(ex){
            	component.set("v.value", '');
            }
            
        }
        
        if(fieldType =='reference'){
	        var action = component.get("c.getRecordName");        
	        var recId = component.get("v.value");
	        if(transformField){
                for(var key in object){
                    component.set("v.urlLabel", object[key]); /*response.getReturnValue()*/
                    component.set("v.urlString", '/' + key); /*component.get("v.value")*/
                }
            }else{
                action.setParams({ 
                    "recordIdString": component.get("v.value")
                });
                
                action.setCallback( this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.urlLabel", response.getReturnValue());
                        component.set("v.urlString", '/' + component.get("v.value")); 
                    }
                })
                $A.enqueueAction(action);
            }
        }
        
    },
    
    doUpdateValue : function(component, event, helper) {
        var fldVal = component.get("v.value");
        var fieldName = component.get("v.fieldName");
        var object;
        
        var objectList = component.get('v.object');
        var objectName = component.get('v.objectName');
        
        //See if multiple objects are passed in, then get the object for the object type
        //otherwise assume just one object
        try{
        		object = objectList.objectMap[objectName];
        }
        catch(e){
        		object = objectList;
        	}
        
        try{
        	object[fieldName] = fldVal;
        	component.set("v.object", objectList); 
            
            /** if ChangeEvent param is set, fire event update to parent component **/
            var fireChangeEvent = component.get("v.changeEvent");
            if(fireChangeEvent){
                var compEvent = component.getEvent("inputFieldEvent");
                compEvent.setParam("objectName", component.get("v.objectName"));
                compEvent.setParam("fieldName", component.get("v.fieldName"));
                compEvent.fire();  
            }
        }
        catch(ex){
        }
    },
    
    doObjectUpdated : function(component, event, helper) {
		var object;
        
        var transformField = component.get('v.transformField');
        
        var objectList = component.get('v.object');
        var objectName = component.get('v.objectName');
        
        //See if multiple objects are passed in, then get the object for the object type
        //otherwise assume just one object
        try{
        		if(transformField){
        			object = objectList.transformFieldMap[objectName];
        		}
        		else{
        			object = objectList.objectMap[objectName];
        		}
        		
        }
        catch(e){
        		object = objectList;
        }
        
        
        var fieldType = component.get('v.fieldType');
        var fieldName = component.get('v.fieldName');
        var picklistValues = component.get('v.picklistValues');
        var value;
        
        //Set field to readonly if has been set specifically for this object
        try{
            if(objectList.readOnlyFields != null && objectName != null){
                var curFieldName = objectName+'.' + fieldName;
                var fieldIsEditable = objectList.readOnlyFields[curFieldName];
     			component.set('v.readOnly', fieldIsEditable);
            }
        }
        catch(e){
            
       	}

        
        if(fieldName && fieldName.includes(".")) {
            component.set("v.value", object[fieldName.split(".")[0]][fieldName.split(".")[1]]);
        } else {
            try{
            	var fldVal = object[fieldName];
            	component.set("v.value", fldVal);
            }
            catch(ex){
            	component.set("v.value", '');
            }
            
        }
        if(fieldType =='reference'){
	        var action = component.get("c.getRecordName");        
	        var recId = component.get("v.value");
            
            if(transformField){
                for(var key in object){
                    component.set("v.urlLabel", object[key]); /*response.getReturnValue()*/
                    component.set("v.urlString", '/' + key); /*component.get("v.value")*/
                }
            }else{
                action.setParams({ 
                    "recordIdString": component.get("v.value")
                });
                
                action.setCallback( this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.urlLabel", response.getReturnValue());
                        component.set("v.urlString", '/' + component.get("v.value")); 
                    }
                })
                $A.enqueueAction(action);
            }     
        }
    }
        
   
})