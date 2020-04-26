({
	DEBUG: 'Amendments: ',
	
    // sets the isActive flag to enable the new button on a related list
    selectedRecordHandler: function(component) {
        debugger;      
        var selectedRecord = component.get('v.selectedRecord');
        var activeFieldName = component.get('v.activeFieldName');
        if (activeFieldName && selectedRecord[activeFieldName]) {
        	component.set('v.recordIsActive', selectedRecord[activeFieldName]);
        }
        
    },
    
})