({
	doInit : function(component, event, helper) {       
        var searchRes  = component.find("searchRes");
        $A.util.addClass(searchRes, 'slds-is-close');
        $A.util.removeClass(searchRes, 'slds-is-open');

        // set the name of the reference record
        if (component.get("v.value")) {
        	this.populateReferenceName(component);
        		        
        } else {
	        var pillTarget = component.find("lookup-pill");
			$A.util.addClass(pillTarget, 'slds-hide');
			$A.util.removeClass(pillTarget, 'slds-show');
		
	        var lookUpTarget = component.find("lookupField");
			$A.util.addClass(lookUpTarget, 'slds-show');
			$A.util.removeClass(lookUpTarget, 'slds-hide'); 
        }

        // set the object type
        var action = component.get("c.getObjectTypeForField");
        action.setParams({ 
            "fieldName": component.get("v.fieldName"),
            "parentObject": component.get("v.objectName")
        });
        action.setCallback( this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.objectType", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    // populate the the reference record name from the field value (Id)
    populateReferenceName: function (component) {
    
        var action = component.get("c.getRecordName");
        action.setParams({ 
            "recordIdString": component.get("v.value"),    
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.urlLabel", response.getReturnValue());
                component.set("v.urlString", '/' + component.get("v.value"));
                let selVal = {
                	Id: component.get("v.value"),
                	Name: response.getReturnValue()
                };

		        if (selVal.Id) {
		        	component.set("v.selectedRecord" , selVal);

		        	var pillTarget = component.find("lookup-pill");
		        	$A.util.addClass(pillTarget, 'slds-show');
		        	$A.util.removeClass(pillTarget, 'slds-hide');
		         
		        	var lookUpTarget = component.find("lookupField");
		        	$A.util.addClass(lookUpTarget, 'slds-hide');
		        	$A.util.removeClass(lookUpTarget, 'slds-show');
		        }
		    }
        });
        $A.enqueueAction(action);
    },
	        
    searchHelper : function(component, event, getInputkeyWord) {
    	
    	// call the apex class method 
    	var action = component.get("c.fetchRecords");
    	
    	// set param to method  
    	action.setParams({
            'searchKeyWord': getInputkeyWord,
            'sObjectType': component.get("v.objectType")
          });
        
        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", 'Search Result...');
                }
                
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
 
        });
        $A.enqueueAction(action);
	},
	
    keyPressController : function(component, event, helper) {
    
    	// get the search Input keyword   
		var getInputkeyWord = component.get("v.SearchKeyWord");
		
		// check if getInputKeyWord size id more then 0 then open the lookup result List and 
		// call the helper 
		// else close the lookup result List part.   
		if (getInputkeyWord.length > 0 ) {
        	var forOpen = component.find("searchRes");
        	$A.util.addClass(forOpen, 'slds-is-open');
        	$A.util.removeClass(forOpen, 'slds-is-close');
        	helper.searchHelper(component, event, getInputkeyWord);
        	
        } else{  
        	component.set("v.listOfSearchRecords", null ); 
        	var forclose = component.find("searchRes");
        	$A.util.addClass(forclose, 'slds-is-close');
        	$A.util.removeClass(forclose, 'slds-is-open');
          }
	},
  	
	// clear the selection 
    clear : function(component, event, helper){
      
         var pillTarget = component.find("lookup-pill");
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         var lookUpTarget = component.find("lookupField"); 
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');
      
         component.set("v.SearchKeyWord", null);
         component.set("v.listOfSearchRecords", null );
         
         component.set("v.value", null); 
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
     
    	// get the selected record from the COMPONENT event 	 
       var selectedObjectFromEvent = event.getParam("objectByEvent");
	   
	   component.set("v.selectedRecord" , selectedObjectFromEvent); 
	   
	   component.set("v.value" , selectedObjectFromEvent.Id); 
       
        var forclose = component.find("lookup-pill");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');  
	},
	
	// automatically call when the component is done waiting for a response to a server request.  
    hideSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : false });
        evt.fire();    
    },
    
    // automatically call when the component is waiting for a response to a server request.
    showSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();    
    }
})