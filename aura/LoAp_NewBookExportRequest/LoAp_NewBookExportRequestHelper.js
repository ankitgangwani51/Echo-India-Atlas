({
	DEBUG:	'NewBookExportRequest: ',
	
    doInit : function(component) {
        var mapOfPicklistLabel2Values = new Map(); 
        var picklistArray = [];
        picklistArray.push($A.get('$Label.c.LoAp_MeterBookSelected'));
        picklistArray.push($A.get('$Label.c.LoAp_MeterBookSelectAll'));
        mapOfPicklistLabel2Values[$A.get('$Label.c.GlAp_SelectBookHeader')] = picklistArray;
        component.set('v.mapOfPicklistLabelWithValues', mapOfPicklistLabel2Values);
    },
    
    // handle row click event originating from child component.
    handleRowClickEvent: function(component, event) {
        //component.find('spinner').show();
        var tableName = event.getParam('Source');
        var rowId = event.getParam('RowId');
        var Ids = [];
        Ids.push(rowId);

        component.set('v.selectedBooks', []);
        if (tableName == $A.get("$Label.c.LoAp_ReadPeriodObject")) { 
            component.set("v.periodId", Ids);
            component.set('v.showSelectBook', true)
        }  
        if (tableName == $A.get("$Label.c.LoAp_ReadTimetableObject")) {
            component.set("v.timetableID", Ids);
            component.set('v.showSelectBook', false);

        }
        //component.find('spinner').hide();
    },
    
    // handle row click event originating from child component.
    handleRowSelectEvent: function(component, event) {
        if (component.get('v.showSelectBook')) {
            var bookIds = component.find('selectbook').getSelectedBooks();
            component.set('v.selectedBooks', bookIds);
        }
    },
    
    // navigation with validation/server calls 
    navigateStep: function(component, event) {
        var message = event.getParam('message');
        if (message === 'CANCEL') {
            this.close(component);
        } else if (message === 'NEXT') {
            this.save(component);
             
        } else if (message === 'BACK') {
            // not valid
        }
    },

    // call the notifier method to show a message on the notification component.
    showNotification: function(component, message, type) {
        component.find('notification').showNotification(message, type);
    },
    
    // call the notification component method to clear a notification
    clearNotification: function(component) {
    	this.showNotification(component, null);
    },
    
    // displays the modal
    newRequest: function(component) {
        component.set('v.isActive', true);
    },
    
    // Server call to save the data in BRQ.
    save: function(component) {
    	this.clearNotification(component);
        this.handleRowSelectEvent(component);
        var ErrorMessageVal = [];
        if (component.get('v.selectedBooks').length > 0) {
            let params = {
                "timetableID": component.get("v.timetableID"),
                "periodId": component.get("v.periodId"),
                "bookIds": component.get('v.selectedBooks')
            };
            this.callServer(component,'c.createBRQ',
                            function(response) {
                                if(response != null){
                                    this.goToRecord(response);
                                }
                            },
                            params);
        } else {
            ErrorMessageVal.push($A.get("$Label.c.LoAp_SelectBooksMandatory"));
            
            // Check if there is any error in array
            if (ErrorMessageVal.length > 0) {
                this.showNotification(component, ErrorMessageVal);
            }
        }
    },
    // close the modal
    close: function(component) {
        component.set('v.showSelectBook', false);
        component.set('v.selectedBooks', []);
        component.set('v.isActive', false);
    }
    
})