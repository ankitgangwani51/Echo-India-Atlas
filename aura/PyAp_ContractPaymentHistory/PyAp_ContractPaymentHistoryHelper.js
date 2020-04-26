({
    // init method - get field properties for payment table fields and query them
    doInit : function(component, event, helper) {           
        // Set the BillId in parameters
        let params = {
            "contractId": component.get("v.recordId")
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
    // get the field properties for payment and query them to display the data in table
    handleRowClickEvent: function(component, event, helper) {
        var sRowId = event.getParam('RowId');
        var tableName = event.getParam('Source');
        if(tableName == $A.get("$Label.c.PyAp_PaymentHistoryPaymentTableName")){
            
            component.set("v.paymentRecordId", sRowId);
            
            let params = {
                "PaymentId": sRowId
                
            };
            
            // Retrieve list of fields and properties for the Bills
            helper.callServer(component,'c.retrieveBillPropDetails',
                              function(response){
                                  component.set("v.billFldList", response);
                              },
                              null);
            
            // Retrieve the list of Bills 
            helper.callServer(component,'c.retrieveBills',
                              function(response){
                                  component.set("v.billRecordList", response);
                              },
                              params);
        }        
        else if(tableName == $A.get("$Label.c.PyAp_PaymentHistoryBillTableName")){
            let params2 = {
                "paymentId": component.get('v.paymentRecordId') ,
                "billId": sRowId
                
            };
            
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
                              params2);
        }
    }
})