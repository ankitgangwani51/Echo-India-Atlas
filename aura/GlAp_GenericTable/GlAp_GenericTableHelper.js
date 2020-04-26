({
	handleRowClickEvent: function(component, event, helper) {
        var sRowId = event.getParam('RowId');
        var rowArray = helper.asArray(component.find("GenericRowItem"));
        for (var i = 0; i < rowArray.length; i++) {
        	var cmp = rowArray[i];
            cmp.HighlightRowSelected(sRowId);
            
        }
    },
    
    // This function will make the editable fields as read-only fields when the records gets de-selected and make them editable once selected again
    handleRowSelectEvent: function(component,event,helper){        
        var mainChecked = false;
        var rec = component.get("v.recordList");
        
        for (var i = 0; i < rec.length; i++) { 
            if(!rec[i].isSelected){
                mainChecked = true;
                break;
            }
        }
        
        if(!mainChecked)        
            component.set('v.isChecked',true);        
        else
            component.set('v.isChecked',false);
    },
    
    asArray: function(component) {
    	if (Array.isArray(component)) return component;
    	else return component ? [component] : [];
	},
    
    // This funtion will checked and unchecked all the records based on SelectAll checkbox button    
    doEdit : function(component,event,helper){
        if(!component.get('v.isChecked'))
            component.set('v.isChecked',true);
        else
            component.set('v.isChecked',false);
        
       	var rec = component.get("v.recordList");
        for (var i = 0; i < rec.length; i++) {
            rec[i].isSelected =component.get('v.isChecked');
        }
        //Update the component properties
        component.set("v.recordList", []);
        component.set("v.recordList", rec);
	}
})