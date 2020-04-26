({
	DEBUG: 'RecordListTitleWithIcon: ',
	
    // initialise component
    doInit: function(component) {           

        // get the object properties
        this.getObjectProperties(component);
    },
    
    // get the object properties including the icon URL
    getObjectProperties: function(component) {           
        this.callServer(component, 'c.retrieveObjectProperties',
                          function(response) {
                              component.set('v.object', response);
                          },
                          {'objectName': component.get('v.objectName')});
    },
})