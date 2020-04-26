({
    
    //Fire if reading period change from parent componet as a parameter.
    periodChange : function(component, event, helper) {
        var periodIds = [];
        var periodIds =  component.get("v.periodId");
        var screenName = component.get("v.screenName");
        console.log('periodIds',periodIds);
        let params ={
            "periodIds": periodIds,
            "screenName": screenName
        };
        
        helper.callServer(component,'c.getInfoToDisplay',
                          function(response) {
                              component.set("v.resultContainer", response);
                              component.set('v.fieldList',  component.get("v.resultContainer").fieldPropList);
                              component.set('v.recordList', component.get("v.resultContainer").combinedList);
                              component.set('v.serverRecordList',component.get("v.recordList"));
                              var result = component.get("v.recordList");
                              var uniqueDepots = new Set();
                              var uniqueArea   = new Set();
                              uniqueDepots.add($A.get('$Label.c.CuAp_FilterNone'));
                              uniqueArea.add($A.get('$Label.c.CuAp_FilterNone'));
                              for (var i = 0; i < result.length; i++) {
                                  if(result[i].objectMap){
                                       uniqueDepots.add(result[i].objectMap[this.setPrefixedString('Depot__c')]['Name']);
                                       uniqueArea.add(result[i].objectMap[this.setPrefixedString('Area__c')]['Name']);
                                  }
                              }
                              var arrayOfArea = Array.from(uniqueArea);
                              var arrayOfDepot = Array.from(uniqueDepots);
                              component.set('v.areaOptions',arrayOfArea);
                              component.set('v.depotOptions',arrayOfDepot);
                              if (result.length > 0) {
                                  component.set('v.isActive',true); 
                                  component.set('v.noResultFound',false);
                              } else{
                                  component.set('v.noResultFound',true);
                              }
                          },
                          params);  
        
        var picklistArray;
        var mapOfPicklistLabel2Values = component.get('v.mapOfPicklistLabelWithValues');
        for (var key in component.get('v.mapOfPicklistLabelWithValues')) {
            picklistArray = mapOfPicklistLabel2Values[key];
            component.set('v.selectPicklistLabel',key);
        }
        component.set('v.selectOptions',picklistArray);
       },
       //Filter results on the basis of picklist selection.
       isPickValChange: function(component, event, helper) { 
            var areaVal   =   component.get('v.areaVal');
            var depotVal  =   component.get('v.depotVal');
            var selectVal =   component.get('v.selectVal');
            var recList   =   component.get("v.serverRecordList");
            var filteredList = [];
        if(areaVal && areaVal != $A.get('$Label.c.CuAp_FilterNone') && depotVal == $A.get('$Label.c.CuAp_FilterNone')){
            for (var i = 0; i < recList.length; i++) {
                if(recList[i].objectMap && recList[i].objectMap[this.setPrefixedString('Area__c')]['Name'] == areaVal || recList[i].isSelected == true){
                    filteredList.push(recList[i]);
                }
            }
        }else if(depotVal && depotVal != $A.get('$Label.c.CuAp_FilterNone') && areaVal == $A.get('$Label.c.CuAp_FilterNone')){
            for (var i = 0; i < recList.length; i++) {
                if(recList[i].objectMap && recList[i].objectMap[this.setPrefixedString('Depot__c')]['Name'] == depotVal || recList[i].isSelected == true){
                    filteredList.push(recList[i]);
                }
            }
        }else if(depotVal && areaVal && depotVal != $A.get('$Label.c.CuAp_FilterNone') && areaVal != $A.get('$Label.c.CuAp_FilterNone')){
            for (var i = 0; i < recList.length; i++) {
                if((recList[i].objectMap && recList[i].objectMap[this.setPrefixedString('Depot__c')]['Name'] == depotVal && recList[i].objectMap && recList[i].objectMap[this.setPrefixedString('Area__c')]['Name'] == areaVal) 
                   || recList[i].isSelected == true){
                    filteredList.push(recList[i]);
                }else{
                    component.set('v.recordList',[]); 
                }
            }
        }else{
            component.set('v.recordList',recList);
        }
        
        if(filteredList.length > 0){
            component.set('v.recordList',[]);
            component.set('v.recordList',filteredList);
        }
        if(selectVal){
            if(selectVal == 'All' || selectVal == 'Unallocated'){
                component.set('v.isFilterActive',false);
            }else{
                component.set('v.isFilterActive',true);
            }
        }
        component.set('v.executionMode',selectVal);
    },
    //handel row select event.
    handleRowSelectEvent : function(component, event) {
        var selectedRecords = this.selectedRecords(component, event);
        component.set('v.selectedRecords',selectedRecords);
    },
    //get all meter books records or selected records on the basis of criteria.
    selectedRecords: function(component, event) {
        var recList;
        if(component.get('v.isFilterActive')){
            recList = component.get('v.serverRecordList');
        }else{
            recList = component.get('v.recordList');
        }
        var selectedRecords = [];
        for (var i = 0; i < recList.length; i++) {
            if(component.get('v.isFilterActive') && recList[i].isSelected){
                selectedRecords.push(recList[i].uniqueId);
            }else if(!component.get('v.isFilterActive')){
                selectedRecords.push(recList[i].uniqueId);
            }
        }
        return selectedRecords;
    },
   
    //return the selected records to parent component. 
    getSelectedBooks: function(component, event){
        var selectedRecords = this.selectedRecords(component, event);
        if(component.get('v.isFilterActive')){
            return component.get('v.selectedRecords');
        }
        else{
            return  selectedRecords;
        }
        
    },
})