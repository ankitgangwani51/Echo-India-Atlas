({
	// Select the record
    itemSelected : function(component, event, helper) {
        var target = event.target;   
        var SelIndex = helper.getIndexFrmParent(target,helper,"data-selectedIndex");
        var itemFieldValues = [];
        if(SelIndex){
            var serverResult = component.get("v.server_result");
            var selItem = serverResult[SelIndex];
            if(selItem){
              debugger;
               var fieldsArray = component.get("v.field_API_text").split(",");
                for(var i = 0; i < fieldsArray.length; i++ ){
                    itemFieldValues.push(selItem[fieldsArray[i].trim()]);
                }
                component.set("v.itemFieldValues",itemFieldValues);
                component.set("v.selItem",selItem);
                component.set("v.last_ServerResult",serverResult);
            } 
            component.set("v.server_result",null); 
            component.set("v.selItemCopy",selItem);
        } 
	}, 
    
    // Call the server, perform query and set the results in the attribute
    serverCall : function(component, event, helper) {  
        var target = event.target;  
        var searchText = target.value; 
        var last_SearchText = component.get("v.last_SearchText");
        
        //Escape button pressed 
        if (event.keyCode == 27 || !searchText.trim()) { 
            helper.clearSelection(component, event, helper);
        }else if(searchText.trim() != last_SearchText){ 
            //Save server call, if last text not changed
                     
            var objectName = component.get("v.objectName");
            var field_API_text = component.get("v.field_API_text");
            var field_API_search = component.get("v.field_API_search");
            var field_API_FilterText = component.get("v.field_API_FilterText");
            var field_API_FilterVal = component.get("v.field_API_FilterVal");  
            var field_API_FilterIds = component.get('v.field_API_FilterIds');
            console.log('field_API_FilterIds === '+field_API_FilterIds)
            var limit = component.get("v.limit");
            //Changes for AT-1742 Starts Here
            var field_API_Field_Concatenate = component.get('v.field_API_Field_Concatenate');
            //Changes for AT-1742 Ends Here
            var action = component.get('c.searchDB');
          //  action.setStorable();
            
            action.setParams({
                objectName : objectName,
                fld_API_Text : field_API_text,
                lim : limit, 
                fld_API_Search : field_API_search,
                searchText : searchText,
                fld_API_FilterText : field_API_FilterText,
                fld_API_FilterVal : field_API_FilterVal,
                field_API_Field_Concatenate : field_API_Field_Concatenate,   //Changes for AT-1742 Starts/Ends Here
                field_API_FilterIds : JSON.stringify(field_API_FilterIds)
            });
    
            action.setCallback(this,function(a){
                this.handleResponse(a,component,helper);
            });
            
            component.set("v.last_SearchText",searchText.trim());
            $A.enqueueAction(action); 
        }else if(searchText && last_SearchText && searchText.trim() == last_SearchText.trim()){ 
            component.set("v.server_result",component.get("v.last_ServerResult"));
        }         
	},
    
    handleResponse : function (res,component,helper){
        if (res.getState() === 'SUCCESS') {
            var retObj = JSON.parse(res.getReturnValue());
            var fld_API_Text = component.get("v.field_API_text");
            var arrSplitAPIText = fld_API_Text.split(",");
            if(retObj.length <= 0){
                var noResult = JSON.parse('[{"Name":"No Results Found","TransformField__t":"No Results Found"}]');
                component.set("v.server_result",noResult); 
                component.set("v.last_ServerResult",noResult);
            }else{
                component.set("v.server_result",retObj); 
                component.set("v.last_ServerResult",retObj);
                //Changes for AT-1742 Starts Here
                // To keep values in all fields which we querying before it was only for specific fields. Modified By  Dependra- 25-01-2019
                var finalRecordList = [];
                if(component.get('v.field_API_Field_Concatenate')){
                    var records = component.get('v.server_result');
                    for (var i = 0; i < records.length; i++) {
                        var obj = {};
                        for(var j=0; j<arrSplitAPIText.length; j++){
                            var key = arrSplitAPIText[j];
                            obj[key.trim()] = records[i][arrSplitAPIText[j].trim()];  
                        }
                        obj['sobjectType'] = component.get('v.objectName');
                        if(records[i]['Name'] && records[i][component.get('v.field_API_Field_Concatenate')]){
                            obj['TransformField__t'] = records[i]['Name']+' - '+records[i][component.get('v.field_API_Field_Concatenate')]; 
                        }
                        else 
                            if(records[i]['Name']){
                                obj['TransformField__t'] = records[i]['Name'];  
                            }
                        finalRecordList.push(obj);
                    }
                }else{
                    var finalRecordList = [];
                    var records = component.get('v.server_result');
                    for (var i = 0; i < records.length; i++) {
                        var obj = {};
                        for(var j=0; j<arrSplitAPIText.length; j++){
                            var key = arrSplitAPIText[j];
                            obj[key.trim()] = records[i][arrSplitAPIText[j].trim()];  
                        }
                        obj['sobjectType'] = component.get('v.objectName');
                        if(records[i]['Name']){
                            obj['TransformField__t'] = records[i]['Name'];  
                        }
                        finalRecordList.push(obj);
                    }
                }
                if(finalRecordList.length > 0){
                    component.set("v.server_result",finalRecordList);
                    component.set("v.last_ServerResult",finalRecordList);
                }
              //Changes for AT-1742 Ends Here
            }  
        }else if (res.getState() === 'ERROR'){
            var errors = res.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    alert(errors[0].message);
                }
            } 
        }
    },
    
    getIndexFrmParent : function(target,helper,attributeToFind){
        //User can click on any child element, so traverse till intended parent found
        var SelIndex = target.getAttribute(attributeToFind);
        while(!SelIndex){
            target = target.parentNode ;
            SelIndex = helper.getIndexFrmParent(target,helper,attributeToFind);           
        }
        return SelIndex;
    },
    
    // Added event on selection of object if need to pass value in parent component- Added By Dependra- 25-01-2019
    itemsChange : function(component, event, helper) {	
        debugger;
        var selItemCopy = component.get("v.selItemCopy");
        var evt = component.getEvent("selectedValueEvent");
        //evt.setParam("objectVal", selItemCopy);
        evt.setParams({"objectVal" :  selItemCopy});
        evt.fire(); 
    },
    
    // Remove the selected record
    clearSelection : function(component, event, helper){
        component.set("v.selItem",null);
        component.set("v.itemFieldValues",null);
        component.set("v.server_result",null);
    },
    
})