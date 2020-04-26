({
	// init method - get field properties for payment table fields and query them
    doInit : function(component, event, helper) {           
        
        // Set the BillId in parameters
        let params = {
            "billId": component.get("v.recordId")
        };
        
        // Retrieve list of fields and properties for the payments
        helper.callServer(component,'c.retrievePaymentFieldPropDetails',
                          function(response){
                              component.set("v.paymentFldList", response);
                          },
                          null);
        
        // Retrieve the list of payments
        helper.callServer(component,'c.retrievePaymentRecords',
                          function(response){
                              component.set("v.paymentRecordList", response);			
                          },
                          params);        
    },
    
    // get the clicked rowid i.e. paymentid in this case
    // get the field properties for Bill Item table and query them to display the data in table
    handleRowClickEvent: function(component, event, helper) {
        
        var sRowId = event.getParam('RowId');
        var tableName = event.getParam('Source');
        
        let params = {
            "paymentId": sRowId,
            "billId": component.get("v.recordId")
        };
        
        if(tableName == $A.get("$Label.c.PyAp_PaymentHistoryPaymentTableName")){
            
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