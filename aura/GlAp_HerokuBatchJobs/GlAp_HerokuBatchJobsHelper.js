({
	doInit : function(component, event, helper) {
    },
    
    // call the notification component method to show a notification
    showNotification: function(component, message, type) {
    	component.find('notification').showNotification(message, type);
    },

    // call the notification component method to clear a notification
    clearNotification: function(component) {
    	this.showNotification(component, null);
    },
    
    handleManage: function (component, event, helper) { 
        component.find('notification').clearNotification();
        component.set('v.openAddHeroku',false);
        this.callServer(component, 'c.getHerokuJobsFields',
                        function(response) {
                            component.set('v.manageFieldList',response);
                        },
                        null); 
        
        this.callServer(component, 'c.getHerokuJobsRecords',
                        function(response) {
                            console.log('response parent = '+JSON.stringify(response));
                            if(response.isSuccess)
                                component.set('v.manageRecordList',response.combinedList);
                            else{
                                component.find('notification').showNotification([response.message],'error');            
                                return false;  
                            }
                        },
                        null); 
    },
    
    // handle Manage Button
    handleRowButtonPressEvent: function(component, event) {
        //this.clearNotification(component);
        component.set('v.cronExpression',null);
        component.set('v.manageTrue',false);
        if (event.getParam('ButtonId') == $A.get('$Label.c.GlAp_Manage')) {
            var sRowId = event.getParam('RowId');
            var manageRecordList = component.get('v.manageRecordList');
            for(var i=0;i<manageRecordList.length;i++){
                if(sRowId == manageRecordList[i].uniqueId){
                    component.set('v.cronExpression',manageRecordList[i].transformFieldMap.cronExpression);
                    component.set('v.herokuBatchRecord',manageRecordList[i]);
                    component.set('v.manageTrue',true);
                    break;
                }
            }
        }
        if (event.getParam('ButtonId') == $A.get('$Label.c.CuAp_PPDeleteLabel')) {
            var sRowId = event.getParam('RowId');
            component.set('v.isDelete',true);
            component.set('v.deleteId',sRowId);            
        }
        
        if (event.getParam('ButtonId') == $A.get('$Label.c.GlAp_ViewReportLabel')) {
            var sRowId = event.getParam('RowId');
            var sfdcBaseUrl = component.get('v.sfdcBaseUrl');
            var reportId = $A.get('$Label.c.GlAp_HerokuReportId');
            var finalUrl = sfdcBaseUrl + $A.get('$Label.c.GlAp_LightningReportText') + 
                reportId + $A.get('$Label.c.GlAp_Viewfv0Label') + sRowId;            
            
            window.open(finalUrl,'_blank');
        }
        
    },
    
    handleAdd : function(component, event, helper) {
        component.find('notification').clearNotification();
        component.set('v.openAddHeroku',true);
    },
    
    doCancelQuestion: function(component, event, helper) {
        component.set('v.manageTrue',false);
        component.set('v.isDelete',false);
    },
    
    doDeleteQuestion: function(component, event, helper) {
		var deleteId = component.get('v.deleteId');
        
        let param = {
            "deleteId" : deleteId
        };
        
        helper.callServer(component,'c.deleteHerokuJob',
                          function(response){
                              if(!response.isSuccess){
                                  component.find('notification').showNotification([response.message],'error');            
                                  return false;  
                                  // error message to display
                              }
                              else{
                                  component.set('v.isDelete',false);
                                  this.handleManage(component, event, helper);
                                  var toastEvent = $A.get("e.force:showToast");
                                  toastEvent.setParams({
                                      "title": "Success!",
                                      "type":"Success",
                                      "message": $A.get('$Label.c.GlAp_DeleteSuccess')
                                  });
                                  toastEvent.fire();
                              }
                              console.log('response ***********= '+JSON.stringify(response));                              
                          },      				
                          param);
    },
    
    handleStatus : function(component, event, helper){
        component.find('notification').clearNotification();
        component.set('v.FromDate',null);
        component.set('v.ToDate',null);
        component.set('v.statusTrue',false);
        component.set('v.openAddHeroku',false);
        this.callServer(component, 'c.getSfdcBaseUrl',
                        function(response) {
                            component.set('v.sfdcBaseUrl',response);
                        },
                        null); 
        
    },
    
    handleSearch: function(component, event, helper){
        component.find('notification').clearNotification();
        component.set('v.statusTrue',false);
        
        var fromDate = component.get('v.FromDate');
        var toDate = component.get('v.ToDate');
        if(!fromDate){
            component.find('notification').showNotification([$A.get('$Label.c.GlAp_EnterFromDate')],'error');            
            return false;  
        }
        if(!toDate){
            component.find('notification').showNotification([$A.get('$Label.c.GlAp_EnterToDate')],'error');            
            return false;  
        }
        if(fromDate > toDate){
            component.find('notification').showNotification([$A.get('$Label.c.GlAp_FromToDateCompare')],'error');            
            return false;  
        }
        
        this.callServer(component, 'c.getHerokuJobStatusFields',
                        function(response) {
                            component.set('v.statusFieldList',response);
                            component.set('v.statusTrue',true);
                        },
                        null); 
        
        let param = {
            "fromDate" : fromDate,
            "toDate"   : toDate
        };
        
        this.callServer(component, 'c.getHerokuJobStatusRecords',
                        function(response) {
                            console.log('response status = '+JSON.stringify(response));
                            if(response.isSuccess)
                                component.set('v.statusRecordList',response.combinedList);
                            else{
                                component.find('notification').showNotification([response.message],'error');            
                                return false;  
                            }
                        },
                        param); 
    }
})