({
    doInit : function(component, event, helper) {           
        let params = {
            "paymentId": component.get("v.recordId")
        };
        
        helper.callServer(component,'c.retrieveBillFieldPropDetails',
                          function(response){
                              
                              component.set("v.billsfieldList", response);
                              
                          },
                          null);
        helper.callServer(component,'c.retrieveBillRecords',
                          function(response){
                              component.set("v.billsrecordList", response);			
                          },
                          params);
        
    },
    
    // get the clicked rowid i.e. BillId in this case
    // get the field properties for Bill Item table and query them to display the data in table
    handleRowClickEvent: function(component, event, helper) {
        var  sRowId   = event.getParam('RowId');
        var tableName = event.getParam('Source');
        
        let params = {
            "paymentId": component.get("v.recordId"),
            "billId": sRowId,
        };
        
        if(tableName == $A.get("$Label.c.PyAp_BillHistoryTableName")){
            
            // Retrieve list of fields and properties for the BillItem
            helper.callServer(component,'c.retrieveBillItmPropDetails',
                              function(response){
                                  component.set("v.billItmFldList", response);
                              },
                              null);
            
            // Retrieve the list of Bill Items
            helper.callServer(component,'c.retrieveBillItems',
                              function(response){
                                  component.set("v.billItmRecordList", response);
                              },
                              params);
        }
    }
})