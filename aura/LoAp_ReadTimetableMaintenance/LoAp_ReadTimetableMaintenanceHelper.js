({
    // initialise component
    doInit: function(component){ 
        component.set('v.tempRowIdCount','0');
        
        var sectionList = [];
        sectionList.push($A.get("$Label.c.LoAp_SectionLabelArea")); 
        sectionList.push($A.get("$Label.c.LoAp_SectionLabelDepot"));
        sectionList.push($A.get("$Label.c.LoAp_SectionLabelBook"));        
        component.set('v.sections',sectionList);
        
        let params ={
            "SectionName": $A.get("$Label.c.LoAp_SectionLabelArea")
        }; 
        
        this.callServer(component, 'c.retrieveFieldPropDetails',
                        function(response) {
                           component.set('v.areaFieldList', response);
                        },
                        params);       
        
    },    
    handleRowClickEvent: function(component, event) {
        var tableName = event.getParam('Source'); 
        var sRowId = event.getParam('RowId');
        
        
        if (tableName == $A.get("$Label.c.LoAp_ReadTimetableObject")) {
            component.set('v.recordList',[]);
            component.set('v.areaRecordList',[]);
            component.set('v.depotRecordList',[]);
            component.set('v.bookRecordList',[]); 
            component.set('v.disabled',true); 
        }
        
        if (tableName == $A.get("$Label.c.LoAp_ReadPeriodObject")){
            component.set('v.disabled',false); 
            component.set('v.selReadPeriodId',sRowId); 
            let params ={
                "readingPeriodId": sRowId             
            };
            this.callServer(component, 'c.getReadingModeRecords',
                            function(response) {
                                component.set('v.resultContainer', response);
                                component.set('v.areaRecordList' , component.get('v.resultContainer').areaRecordList);
                                component.set('v.depotRecordList' , component.get('v.resultContainer').depotRecordList);                                
                                component.set('v.bookRecordList' , component.get('v.resultContainer').bookRecordList);                                
                                this.loadSectionalRecords(component);
                                
                                // AT-4065...Start
                                component.set('v.existingAreaRecordList' , component.get('v.resultContainer').areaRecordList);
                                component.set('v.existingDepotRecordList' , component.get('v.resultContainer').depotRecordList);                                
                                component.set('v.existingBookRecordList' , component.get('v.resultContainer').bookRecordList); 
                                // AT-4065...End    
                            },
                            params);
            //Changes for AT-3040 Starts Here
            this.callServer(component, 'c.getReadPeriod',
                            function(response) {
                                component.set('v.readPeriodObject', response);
                            },
                            params);
            //Changes for AT-3040 Ends Here
        } 
        
        if (tableName == $A.get("$Label.c.LoAp_DisplaySectionObject")){
            component.set('v.selReadingModeId',sRowId); 
            var response = component.get('v.recordList');            
            console.log('response11 = '+JSON.stringify(response));
            for(var i = 0;i<response.length;i++){ 
                var rowId  = response[i].uniqueId;
                if(rowId == sRowId){
                    var modeValue =  response[i].objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('Mode__c')];                    
                    if (modeValue == $A.get("$Label.c.LoAp_EstimateModeValue")){ 
                        response[i].readOnlyFields[this.setPrefixedString('ReadingMode__c.'+[this.setPrefixedString('EstimateDate__c')])] = false;                        
                    }
                    else{
                        response[i].readOnlyFields[this.setPrefixedString('ReadingMode__c.' +[this.setPrefixedString('EstimateDate__c')])] = true; 
                        response[i].objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')] = '';
                    }
                }
            }
            component.set('v.recordList',response);            
        }
        
    },    
    
    tabSelected: function(component,event,helper) {   
       
       component.set('v.recordList',[]);
       component.set('v.fieldList',[]);
        
        let params ={
            "SectionName": component.get("v.selTabId")
        };        
        this.callServer(component, 'c.retrieveFieldPropDetails',
                        function(response) {
                            component.set('v.fieldList', response);
                            this.loadSectionalRecords(component);
                            
                        },
                        params);
        
    },
    
    loadSectionalRecords: function(component){ 
        var section = component.get('v.selTabId');    
        
        if(section == $A.get("$Label.c.LoAp_SectionLabelArea")){              
            component.set('v.recordList', component.get('v.areaRecordList'));
        }
        if(section == $A.get("$Label.c.LoAp_SectionLabelDepot")){             
            component.set('v.recordList', component.get('v.depotRecordList'));         
        }        
        if(section == $A.get("$Label.c.LoAp_SectionLabelBook")){
            component.set('v.recordList', component.get('v.bookRecordList'));
        }
    },
    
    AddRow: function(component){        
        var section = component.get('v.selTabId');
        var records =  component.get('v.recordList');
        var obj = new Object();
        
        var action = component.get("c.blankRow");
        action.setParams({
            "readingPeriodId":  component.get('v.selReadPeriodId'),
            "SectionName": component.get("v.selTabId")
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS') {
                //Swati- 06-Jul-2018 : AT-3024 
                obj = response.getReturnValue();                
                var tempRowId = parseInt(component.get('v.tempRowIdCount')) + 1;                             
                component.set('v.tempRowIdCount', tempRowId);
                if(!obj.uniqueId ){
                    obj.uniqueId = tempRowId;
                }                            
                records.push(obj);
                component.set('v.recordList', records);
                
                if(section == $A.get("$Label.c.LoAp_SectionLabelArea")){
                    component.set('v.areaRecordList',records);
                }
                if(section == $A.get("$Label.c.LoAp_SectionLabelDepot")){ 
                    component.set('v.depotRecordList',records);
                }
                if(section == $A.get("$Label.c.LoAp_SectionLabelBook")){
                    component.set('v.bookRecordList',records);
                }
            } else {
                this.handleError(component, response);
            }
        });
        $A.enqueueAction(action);
    },
    
    DeleteRow: function(component){
        
        var section = component.get('v.selTabId');
        var delRecordList = component.get('v.recordList');
        
        var selectedRowId  = component.get('v.selReadingModeId');  
        component.set('v.selReadingModeId', null); 
        
        //please select a row to delete 
        if(!selectedRowId){
            component.find('notification').showNotification([$A.get('$Label.c.LoAp_NoRowSelected')],$A.get('$Label.c.GlAp_NotificationTypeError'));                
            return false;
        }
        
        for(var i = 0;i<delRecordList.length;i++){
            if(delRecordList[i].uniqueId == selectedRowId){
                delRecordList.splice(i,1);                   
                component.set('v.recordList',delRecordList);
                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "type": "success",
                                    "message": $A.get("$Label.c.LoAp_ReadingModeDeleted") 
                                });        
                                toastEvent.fire();
            }               
        } 
        
        if(section == $A.get("$Label.c.LoAp_SectionLabelArea")){
            component.set('v.areaRecordList',delRecordList);
        }
        if(section == $A.get("$Label.c.LoAp_SectionLabelDepot")){ 
            component.set('v.depotRecordList',delRecordList);
        }
        if(section == $A.get("$Label.c.LoAp_SectionLabelBook")){
            component.set('v.bookRecordList',delRecordList);
        }        
        
        if (JSON.stringify(selectedRowId).length > 5 ){           
            //make a server call to delete it from object 
            var action = component.get("c.deleteRecord");
            action.setParams({
                "readingModeId": selectedRowId
            });
            action.setCallback(this, function(response){
                if(response.getState() === 'SUCCESS') {
                    //To display toast for some couple of seconds
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "message": $A.get("$Label.c.LoAp_ReadingModeDeleted") 
                    });        
                    toastEvent.fire();                    
                } else {
                    this.handleError(component, response);
                }
            });
            $A.enqueueAction(action);
        }
        
    },
    
    save: function(component, event,helper) {
        
        //Clears down the toast messages displays on screen        
        component.find('notification').clearNotification();   
        var newrecords = new Map();
		
		var areaRecords = component.get('v.areaRecordList'); 
        var depotRecords = component.get('v.depotRecordList');
        var bookRecords = component.get('v.bookRecordList');
        
        var existingAreaRecords = component.get('v.existingAreaRecordList');    // AT-4065
        var existingDepotRecords = component.get('v.existingDepotRecordList');	// AT-4065
        var existingBookRecords = component.get('v.existingBookRecordList');	// AT-4065
        
        //Get today's date in YYYY-MM-DD format
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1;
        var yyyy = today.getFullYear();
        if(dd<10){
            dd='0'+dd;
        } 
        if(mm<10){
            mm='0'+mm;
        } 
        var today = yyyy+'-'+mm+'-'+dd;
        		    
        if(this.areaValidation(component, areaRecords, today, existingAreaRecords)  && this.depotValidation(component, depotRecords, today, existingDepotRecords)
          && this.bookValidation(component, bookRecords, today, existingBookRecords)){   // AT-4065 added 4th passing parameter in areaValidation/depotValidation/bookValidation 
            
            newrecords['area'] = areaRecords;
            newrecords['depot'] = depotRecords;
            newrecords['book'] = bookRecords;
            
            var listToSave = [];
            for(var key in newrecords){
                var val = newrecords[key];
                for(var i = 0; i < newrecords[key].length; i++){
                    listToSave.push(val[i]);
                }
            }
            //Need to loop through all of the entries in the list and then set the sObject types so that the 
            //server can reserialise the records
            for(var i=0; i < listToSave.length; i++){
                var recEntry = listToSave[i];
                
                //when estimate date is blank for mode = actual
                if(recEntry.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')] == ''){
                    delete listToSave[i].objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')];                
                }
                
                var readingModeEntry = recEntry.objectMap[this.setPrefixedString('ReadingMode__c')];    
                var areaEntry = recEntry.objectMap[this.setPrefixedString('Area__c')];
                var depotEntry = recEntry.objectMap[this.setPrefixedString('Depot__c')];
                var bookEntry = recEntry.objectMap[this.setPrefixedString('Book__c')];
                
                let readingModeAtributes =  {
                    "type": this.setPrefixedString('ReadingMode__c'),
                };
                let areaAtributes =  {
                    "type": this.setPrefixedString('Area__c'),
                };
                let depotAtributes =  {
                    "type": this.setPrefixedString('Depot__c'),
                };
                let bookAtributes =  {
                    "type": this.setPrefixedString('Book__c'),
                };         
                
                readingModeEntry.attributes=readingModeAtributes;
                
                if(areaEntry){
                    areaEntry.attributes=areaAtributes;
                }            
                if(depotEntry){
                    depotEntry.attributes=depotAtributes;
                }
                if(bookEntry){
                    bookEntry.attributes=bookAtributes;
                }            
            }
            var action = component.get("c.doSave");
            action.setParams({
                "responseJSON": JSON.stringify(listToSave)
            });
            action.setCallback(this, function(response){
                if(response.getState() === 'SUCCESS') {
                    
                    //To display toast for some couple of seconds
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": $A.get("$Label.c.GlAp_Success"),
                        "message": $A.get("$Label.c.LoAp_ReadingModeSaved") 
                    });        
                    toastEvent.fire();
                    
                    let params ={
                        "readingPeriodId": component.get('v.selReadPeriodId')           
                    };
                    this.callServer(component, 'c.getReadingModeRecords',
                                    function(response) {
                                        component.set('v.resultContainer', response);
                                        component.set('v.areaRecordList' , component.get('v.resultContainer').areaRecordList);
                                        component.set('v.depotRecordList' , component.get('v.resultContainer').depotRecordList);
                                        component.set('v.bookRecordList' , component.get('v.resultContainer').bookRecordList);
                                        
                                        this.loadSectionalRecords(component);
                                    },
                                    params);  
                    
                } else {
                    this.handleError(component, response);
                }
            });
            $A.enqueueAction(action);       
        }
    },
    
    areaValidation: function(component, areaRecords, today, existingAreaRecords){
        var areaNames = [];   
        
        for(var i=0; i < areaRecords.length; i++){
            var record = areaRecords[i];
            
            // AT-4065 start
            var existingRecord = existingAreaRecords[i];            
            if(existingRecord != undefined &&
               (record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('Mode__c')] == existingRecord.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('Mode__c')]) &&
               (record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')] == existingRecord.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')]))              
                continue;
            // AT-4065 end
            
            areaNames.push(record.objectMap[this.setPrefixedString('Area__c')]['Name']);
            //Validation - NameNotSelectedError            
            if(record.objectMap[this.setPrefixedString('Area__c')]['Name'] == $A.get("$Label.c.CuAp_FilterNone")){
                component.find('notification').showNotification([$A.get('$Label.c.LoAp_NameNotSelectedError')],$A.get('$Label.c.GlAp_NotificationTypeError'));                
                return false;   
            }
            //Validation - if estimate mode is selected estimate date must be provided
            if((record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('Mode__c')] == $A.get("$Label.c.LoAp_EstimateModeValue")) &&
               (record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')] == '')){
                component.find('notification').showNotification([$A.get('$Label.c.LoAp_EstimateDateMissingForEstimateMode')],$A.get('$Label.c.GlAp_NotificationTypeError'));                
                return false;
            }
            //Validation - estimate date cannot be before today 
            if((record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('Mode__c')] == $A.get("$Label.c.LoAp_EstimateModeValue")) &&
               (record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')] < today)){
                component.find('notification').showNotification([$A.get('$Label.c.LoAp_EstimateDateCannotBeBeforeToday')],$A.get('$Label.c.GlAp_NotificationTypeError'));                
                return false;
            }
            //Validation - estimate date should be within reading period. 
            //Changes for AT-3040 Starts Here
            if((record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('Mode__c')] == $A.get("$Label.c.LoAp_EstimateModeValue")) &&
               ((record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')] > component.get('v.readPeriodObject')[this.setPrefixedString('ReadEnd__c')])
               || (record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')] < component.get('v.readPeriodObject')[this.setPrefixedString('ReadStart__c')]))){
                component.find('notification').showNotification([$A.get('$Label.c.LoAp_EstimateDateWithInReadPeriod')],$A.get('$Label.c.GlAp_NotificationTypeError'));                
                return false;
            }
            //Changes for AT-3040 Ends Here
        }
        
        //Validation - there should only be one mode for each period and area OR depot OR book combination
        if(this.IsExistDuplicates(areaNames)){
            component.find('notification').showNotification([$A.get('$Label.c.LoAp_DuplicateNames')],$A.get('$Label.c.GlAp_NotificationTypeError'));                
            return false;
        }
        return true;
    },
    
    depotValidation: function(component, depotRecords, today, existingDepotRecords){        
        var depotNames = [];
        for(var i=0; i < depotRecords.length; i++){           
            var record = depotRecords[i]; 
            
            // AT-4065 start
            var existingRecord = existingDepotRecords[i];            
            if(existingRecord != undefined &&
               (record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('Mode__c')] == existingRecord.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('Mode__c')]) &&
               (record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')] == existingRecord.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')]))              
                continue;
            // AT-4065 end
            
            depotNames.push(record.objectMap[this.setPrefixedString('Depot__c')]['Name']);
            if(record.objectMap[this.setPrefixedString('Depot__c')]['Name'] == $A.get("$Label.c.CuAp_FilterNone")){
                component.find('notification').showNotification([$A.get('$Label.c.LoAp_DepotNameNotSelectedError')],$A.get('$Label.c.GlAp_NotificationTypeError'));   
                return false;   
            }
            //Validation - if estimate mode is selected estimate date must be provided
            if((record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('Mode__c')] == $A.get("$Label.c.LoAp_EstimateModeValue")) &&
               (record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')] == '')){
                component.find('notification').showNotification([$A.get('$Label.c.LoAp_EstimateDateMissingForEstimateMode')],$A.get('$Label.c.GlAp_NotificationTypeError'));                
                return false;
            }
            //Validation - estimate date cannot be before today 
            if((record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('Mode__c')] == $A.get("$Label.c.LoAp_EstimateModeValue")) &&
               (record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')] < today)){
                component.find('notification').showNotification([$A.get('$Label.c.LoAp_EstimateDateCannotBeBeforeToday')],$A.get('$Label.c.GlAp_NotificationTypeError'));                
                return false;
            }
            //Changes for AT-3040 Starts Here
            if((record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('Mode__c')] == $A.get("$Label.c.LoAp_EstimateModeValue")) &&
               ((record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')] > component.get('v.readPeriodObject')[this.setPrefixedString('ReadEnd__c')])
               || (record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')] < component.get('v.readPeriodObject')[this.setPrefixedString('ReadStart__c')]))){
                component.find('notification').showNotification([$A.get('$Label.c.LoAp_EstimateDateWithInReadPeriod')],$A.get('$Label.c.GlAp_NotificationTypeError'));                
                return false;
            }
            //Changes for AT-3040 Ends Here
        }
        //Validation - there should only be one mode for each period and area OR depot OR book combination
        if(this.IsExistDuplicates(depotNames)){
            component.find('notification').showNotification([$A.get('$Label.c.LoAp_DepotDuplicateNames')],$A.get('$Label.c.GlAp_NotificationTypeError'));                
            return false;
        }
        return true;
    },
    
    bookValidation: function(component, bookRecords, today, existingBookRecords){        
        var bookNames = [];
        for(var i=0; i < bookRecords.length; i++){           
            var record = bookRecords[i]; 
            
           // AT-4065 start
            var existingRecord = existingBookRecords[i];            
            if(existingRecord != undefined &&
               (record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('Mode__c')] == existingRecord.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('Mode__c')]) &&
               (record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')] == existingRecord.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')]))              
                continue;
            // AT-4065 end
            
            bookNames.push(record.objectMap[this.setPrefixedString('Book__c')]['Name']);
            if(record.objectMap[this.setPrefixedString('Book__c')]['Name'] == $A.get("$Label.c.CuAp_FilterNone")){
                component.find('notification').showNotification([$A.get('$Label.c.LoAp_BookNameNotSelectedError')],$A.get('$Label.c.GlAp_NotificationTypeError'));   
                return false;   
            }
            //Validation - if estimate mode is selected estimate date must be provided
            if((record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('Mode__c')] == $A.get("$Label.c.LoAp_EstimateModeValue")) &&
               (record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')] == '')){
                component.find('notification').showNotification([$A.get('$Label.c.LoAp_EstimateDateMissingForEstimateMode')],$A.get('$Label.c.GlAp_NotificationTypeError'));                
                return false;
            }
            //Validation - estimate date cannot be before today 
            if((record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('Mode__c')] == $A.get("$Label.c.LoAp_EstimateModeValue")) &&
               (record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')] < today)){
                component.find('notification').showNotification([$A.get('$Label.c.LoAp_EstimateDateCannotBeBeforeToday')],$A.get('$Label.c.GlAp_NotificationTypeError'));                
                return false;
            }
            //Validation - estimate date should be within reading period. 
            //Changes for AT-3040 Starts Here
            if((record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('Mode__c')] == $A.get("$Label.c.LoAp_EstimateModeValue")) &&
               ((record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')] > component.get('v.readPeriodObject')[this.setPrefixedString('ReadEnd__c')])
               || (record.objectMap[this.setPrefixedString('ReadingMode__c')][this.setPrefixedString('EstimateDate__c')] < component.get('v.readPeriodObject')[this.setPrefixedString('ReadStart__c')]))){
                component.find('notification').showNotification([$A.get('$Label.c.LoAp_EstimateDateWithInReadPeriod')],$A.get('$Label.c.GlAp_NotificationTypeError'));                
                return false;
            }
            //Changes for AT-3040 Ends Here
        }
        //Validation - there should only be one mode for each period and area OR depot OR book combination
        if(this.IsExistDuplicates(bookNames)){
            component.find('notification').showNotification([$A.get('$Label.c.LoAp_BookDuplicateNames')],$A.get('$Label.c.GlAp_NotificationTypeError'));                
            return false;
        }
        return true;
    },
    
    close : function(component, event,helper) {
         $A.get('e.force:refreshView').fire();
    },
    
    handleError : function(component, response) {	
        var errorMessage = [] ;
        errorMessage.push(response.getError()[0].message) ;
        this.showError(component, errorMessage) ;
    },
    
    showError : function(component, errorMessage) {
        component.find('notification').showNotification(errorMessage, $A.get('$Label.c.GlAp_NotificationTypeError')) ;
    },
    
    IsExistDuplicates : function(array){
        for ( var i = 0; i < array.length; i++){
            for (var j = i+1; j< array.length; j++){
                if (array [i] === array [j]){
                    return true;
                }
            }
        }
    },
    
})