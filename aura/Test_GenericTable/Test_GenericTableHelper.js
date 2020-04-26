({
	handleRowClickEvent: function(component, event, helper) {
        var sRowId = event.getParam('RowId');
        var rowArray = helper.asArray(component.find("GenericRowItem"));
        for (var i = 0; i < rowArray.length; i++) {
        	var cmp = rowArray[i];
            cmp.HighlightRowSelected(sRowId);            
        }
        // If any of the row has unchecked, then selectAll would be unchecked also
        
    },
    
    // This function will make the editable fields as read-only fields when the records gets de-selected and make them editable once selected again
    handleRowSelectEvent: function(component,event,helper){   
        var mainChecked = false;
        //var rec = component.get("v.recordList");
        var rec = component.get("v.paginationList");
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
    
    handleRecordsList : function(component,event,helper){
        
        component.set('v.first','<<');
        component.set('v.last','>>');
        component.set('v.next','>');
        component.set('v.previous','<');
        
        var tempRecordList 	= component.get('v.tempRecordList');
        var recordList 		= component.get("v.recordList");  
        var tempRecordArray = [];
        
        if(tempRecordList.length != recordList.length){
            if(recordList){
                for(var i=0; i< recordList.length; i++){
                    tempRecordArray.push(recordList[i]);    
                }
                component.set('v.tempRecordList', tempRecordArray);
            }
            
            var pageSize = component.get("v.pageSize");
            component.set("v.totalSize", component.get("v.tempRecordList").length);
            component.set("v.start",0);
            component.set("v.end",pageSize-1);
            var tempRecordList = component.get("v.tempRecordList");        
            var pages = Math.ceil(tempRecordList.length / pageSize);
            var paginationList = [];
            if(tempRecordList){
                for(var i=0; i< pageSize; i++){
                    if(i < tempRecordList.length)
                        paginationList.push(tempRecordList[i]);    
                }
                component.set('v.pages', pages);
                component.set('v.paginationList', paginationList);
            }
        }
	},
    
    handleNext : function(component,event,helper){
        
        var recordList 		= component.get("v.recordList");
        var end 			= component.get("v.end");
        var start 			= component.get("v.start");
        var pageSize 		= component.get("v.pageSize");
        var page 			= component.get('v.page');
        var paginationList 	= [];
        var counter 		= 0;
        
        //alert('next start = '+start + 'end = '+end + 'pagesize = '+pageSize + 'records = '+recordList.length);
        for(var i=end+1; i<end+pageSize+1; i++){
            if(recordList.length > i){
                paginationList.push(recordList[i]);                
            }
            counter ++ ;
        }
        
        start 	= start + counter;
        end 	= end 	+ counter;
        page 	= page 	+ 1;
        component.set("v.start",start);
        component.set("v.end",end);     
        component.set('v.page',page);
        component.set('v.paginationList', paginationList);
        component.set('v.spinner',false);        
    },
    
    handlePrevious : function(component,event,helper){
        
        var recordList 		= component.get("v.recordList");
        var end 			= component.get("v.end");
        var start 			= component.get("v.start");
        var pageSize 		= component.get("v.pageSize");
        var page 			= component.get('v.page');
        var paginationList 	= [];
        var counter 		= 0;
        
        //alert('previous start = '+start + 'end = '+end + 'pagesize = '+pageSize + 'records = '+recordList.length);
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                paginationList.push(recordList[i]);
                counter ++;
            }
            else{
                start++;
            }
        }
        start 	= start - counter;        
        end  	= end   - counter;
        
        if(start < 0){
            start 	= 0;
            end 	= pageSize-1;            
        }
        
        page 	= page 	- 1;
        
        component.set("v.start",start);
        component.set("v.end",end);
        component.set('v.page',page);
        component.set('v.paginationList', paginationList);        
    },
    
    handleFirst : function(component,event,helper){
        
        
        var recordList 		= component.get("v.recordList");
        var end 			= component.get("v.end");
        var start 			= component.get("v.start");
        var pageSize 		= component.get("v.pageSize");
        var paginationList 	= [];
        var counter 		= 0;
        
        //alert('first start = '+start + 'end = '+end + 'pagesize = '+pageSize + 'records = '+recordList.length);
        for(var i=0; i<pageSize; i++){
            if(i < recordList.length){
                paginationList.push(recordList[i]);
                counter ++ ;
            }
        }
        
        start = 0;
        end = counter-1;
        var page = 1;
        component.set("v.start",start);
        component.set("v.end",end);        
        component.set('v.page',page);
        component.set('v.paginationList', paginationList);
    },
    
    handleLast : function(component,event,helper){
        
        var recordList 		= component.get("v.recordList");
        var end 			= component.get("v.end");
        var start 			= component.get("v.start");
        var pageSize 		= component.get("v.pageSize");
        var paginationList 	= [];
        var counter 		= 0;
        var pages = Math.ceil(recordList.length / pageSize);
        alert('pages = '+pages + 'formula = '+(pages-1)*pageSize);
        //alert('last start = '+start + 'end = '+end + 'pagesize = '+pageSize + 'records = '+recordList.length);
        for(var i=(pages-1)*pageSize; i<recordList.length; i++){
            paginationList.push(recordList[i]);
            counter ++ ;            
        }
        
        var pages = Math.ceil(recordList.length / pageSize);
        start = recordList.length-counter;
        end = recordList.length;
        //end = recordList.length-1;
        component.set("v.start",start);
        component.set("v.end",end);  
        component.set('v.page',pages);
        component.set('v.paginationList', paginationList);
    },
    
    
    
    // This function will select all the records once the main checkbox checked and vice versa
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