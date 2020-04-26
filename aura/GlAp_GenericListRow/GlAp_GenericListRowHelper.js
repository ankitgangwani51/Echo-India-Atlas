({
	doInit : function(component,event,helper){
        
        var rec = component.get("v.record");
        var forceEdit = component.get("v.forceEditMode");
        
        //LEMB: Updated to enable the user to force the row to be in Edit Mode
        var edMode = (rec.isSelected || forceEdit);
        
        component.set("v.editMode", edMode);
    },
    doButtonFieldPress : function(component,event,helper){       
        var rec = component.get("v.record");
        //use standard html id as aura:id does not dynamacially bind
        var buttonId = event.target.id;
        
        var cmpEvent = component.getEvent("rowButtonEvent");
        cmpEvent.setParams({"RowId" :  rec.uniqueId, "ButtonId" : buttonId});
        cmpEvent.fire();
    },
    doEdit : function(component,event,helper){
		
        //retrieve the record
       	var rec = component.get("v.record");
       	var forceEdit = component.get("v.forceEditMode");
        
       	//Toggle the isSelected Value
       	rec.isSelected = !rec.isSelected;
        
        //LEMB: Updated to enable the user to force the row to be in Edit Mode
        //Set the editMode to true if the rec is not selected
       	var edMode = (rec.isSelected || forceEdit);
        
        //Update the component properties
        component.set("v.editMode", edMode);
        component.set("v.record", rec);
        var cmpEvent = component.getEvent("rowEvent");
        cmpEvent.setParams({"RowId" :  rec.uniqueId});
        cmpEvent.fire();
	},
    doRowClick : function(component, event, helper){
    	var rec = component.get("v.record");
        var tableName = component.get("v.tableName");
        
        // 22 Jun 2018, P Dixon - exclude button clicks from row click
        if (event.target.tagName != 'BUTTON') {
        
	        //Fire event so that the application knows which row has been clicked
	        var cmpEvent = component.getEvent("rowClickEvent");
	        if(cmpEvent != null){
	            cmpEvent.setParams({"RowId" :  rec.uniqueId, "Source" : tableName});
	            cmpEvent.fire();
	        }
        }
    },
    highlightRowSelect : function(component, event, helper){
    	var rec = component.get("v.record");
        var targetE1 = component.find("GenericRow").getElement();
        var sRowId;
        var params = event.getParam('arguments');
        if (params) {
            sRowId = params.RowId;
        }

        if(sRowId == rec.uniqueId){
            $A.util.addClass(targetE1, "slds-is-selected");
        }
        else{
        	$A.util.removeClass(targetE1, "slds-is-selected");
        }
    }
})