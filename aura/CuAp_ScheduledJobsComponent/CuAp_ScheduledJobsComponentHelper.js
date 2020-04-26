({
	DEBUG: 'ScheduledJobs: ',
	
	// initialise the component
    doInit: function (component) {
    
    	// initialise tab names
    	var tabNames = [$A.get('$Label.c.GlAp_ScheduleTypeDaily'), 
					    	$A.get('$Label.c.GlAp_ScheduleTypeWeekly'), 
					    	$A.get('$Label.c.GlAp_ScheduleTypeMonthly')
					    ];
    	component.set('v.tabNames', tabNames);

    	// initialise the days of the week
    	var daysOfWeek = [$A.get('$Label.c.GlAp_DayOfWeekMonday'), 
					    	$A.get('$Label.c.GlAp_DayOfWeekTuesday'), 
					    	$A.get('$Label.c.GlAp_DayOfWeekWednesday'), 
					    	$A.get('$Label.c.GlAp_DayOfWeekThursday'), 
					    	$A.get('$Label.c.GlAp_DayOfWeekFriday'), 
					    	$A.get('$Label.c.GlAp_DayOfWeekSaturday'), 
					    	$A.get('$Label.c.GlAp_DayOfWeekSunday')
					    ];
    	component.set('v.daysOfWeek', daysOfWeek);
    
    	// initialise the date options
    	var dateOptions = [];
    	dateOptions.push(' ');
    	for (var i = 1; i <= 31; i++) {
    		dateOptions.push(i.toString());
    	}
    	component.set('v.dateOptions', dateOptions);

    	// check for an existing schedule
    	let params = {batchProcessId: component.get('v.recordId')};
        this.callServer(component, 'c.getSchedule',
        				function(response) {
        					console.log(this.DEBUG + 'response: ' + JSON.stringify(response));
        					component.set('v.initialised', true);
        					component.set('v.schedule', response);
        				}, 
                        params);            
    },
    
    // select day of the week
    selectDayOfWeek: function (component, event) {       
        var selectedButtonLabel = event.getSource().get('v.label');
        component.set('v.dayOfWeekInput', selectedButtonLabel);
        console.log(this.DEBUG + 'Button label: ' + selectedButtonLabel);
    },
    
    // switch tab
    handleTab: function (component) {
    	this.clearNotification(component);
    	component.set('v.dayOfWeekInput', null);
    	component.set('v.timeInput', null);
    	component.set('v.dateInput', null);
    },
    
    // create a new scheduled job
    startSchedule: function (component) {
    	this.clearNotification(component);
    	var recordId = component.get('v.recordId');
    	var scheduleType = component.get('v.activeTab');
    	var scheduleTime = component.get('v.timeInput');
    	var scheduleDay = component.get('v.dayOfWeekInput');
    	var scheduleDate = component.get('v.dateInput');
    	
    	var hours;
    	var minutes;
    	var dayOfMonth;
    	var dayOfWeek;
    	
    	// check for errors
    	var errors = [];
    	if (!scheduleTime) {
    		errors.push($A.get('$Label.c.CuAp_ScheduledJobTimeRequired'));
    		
    	} else {
    		hours = scheduleTime.split(':')[0];
    		minutes = scheduleTime.split(':')[1];
    		console.log(this.DEBUG + 'hours: ' + hours);
    		console.log(this.DEBUG + 'minutes: ' + minutes);
    	}

    	switch (scheduleType) {
    	
    		case $A.get('$Label.c.GlAp_ScheduleTypeDaily'):
    			dayOfMonth = '*';
    			dayOfWeek = '?';
    			break;
    			
    		case $A.get('$Label.c.GlAp_ScheduleTypeWeekly'):
    			if (!scheduleDay) { 
    				errors.push($A.get('$Label.c.CuAp_ScheduledJobDayOfWeekRequired'));

    			} else {
    				switch (scheduleDay) {
    					case $A.get('$Label.c.GlAp_DayOfWeekMonday'): 
    						dayOfWeek = '1';
    						break;
    					case $A.get('$Label.c.GlAp_DayOfWeekTuesday'): 
    						dayOfWeek = '2';
    						break;
    					case $A.get('$Label.c.GlAp_DayOfWeekWednesday'): 
    						dayOfWeek = '3';
    						break;
    					case $A.get('$Label.c.GlAp_DayOfWeekThursday'): 
    						dayOfWeek = '4';
    						break;
    					case $A.get('$Label.c.GlAp_DayOfWeekFriday'): 
    						dayOfWeek = '5';
    						break;
    					case $A.get('$Label.c.GlAp_DayOfWeekSaturday'): 
    						dayOfWeek = '6';
    						break;
    					case $A.get('$Label.c.GlAp_DayOfWeekSunday'): 
    						dayOfWeek = '7';
    						break;
    					default:
    				}
    			}
    			dayOfMonth = '?';
    			break;
    			
    		case $A.get('$Label.c.GlAp_ScheduleTypeMonthly'):
    			if (!scheduleDate) {
    				errors.push($A.get('$Label.c.CuAp_ScheduledJobDayOfMonthRequired'));
    				
    			} else {
    				if (parseInt(scheduleDate) >= 29) {
    					dayOfMonth = 'L';
    					
    				} else {
    					dayOfMonth = scheduleDate;
    				}
    			}
    			dayOfWeek = '?';
    			break;
    			
    		default:
    	}
		console.log(this.DEBUG + 'dayOfWeek: ' + dayOfWeek);
		console.log(this.DEBUG + 'dayOfMonth: ' + dayOfMonth);
	
    	// show any errors and quit
    	if (errors.length > 0) {
    		this.showNotification(component, errors);
    		return false;
    	}

    	// create a new schedule
    	let params = {
    				batchProcessId: component.get('v.recordId'), 
    				minutes: minutes, 
    				hours: hours, 
    				dayOfMonth: dayOfMonth, 
    				dayOfWeek: dayOfWeek    				
    				};
        this.callServer(component, 'c.createNewSchedule',
        				function(response) {
        					console.log(this.DEBUG + 'response: ' + JSON.stringify(response));
        					component.set('v.schedule', response);
        				}, 
                        params);            
    },

	// stop the scheduled job
    stopSchedule: function (component) {

    	let params = {jobId: component.get('v.schedule').Id};
        this.callServer(component, 'c.stopScheduledJob',
        				function(response) {
        					component.set('v.schedule', []);
        				}, 
                        params);            
    },
    
    // call the notification component method to show a notification
    showNotification: function(component, message, type) {
    	component.find('notification').showNotification(message, type);
    },

    // call the notification component method to clear a notification
    clearNotification: function(component) {
    	this.showNotification(component, null);
    },
})