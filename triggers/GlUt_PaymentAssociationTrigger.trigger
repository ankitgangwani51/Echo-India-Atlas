/******************************************************************************
    @author         Neha rajput
    @date           07 Dec 2018
    @description    PaymentAssociation trigger implementation using the trigger handler 
                    framework
*******************************************************************************/
trigger GlUt_PaymentAssociationTrigger on PaymentAssociation__c (after delete, after insert, after undelete, after update, 
        before delete, before insert, before update) {
    
    
    // Create a new parameters object for the trigger handler
    GlUt_TriggerHandlerObj trigObj = new GlUt_TriggerHandlerObj();
    
    // Update the object with trigger properties
    trigObj.triggerObject = GlUt_Constants.OBJ_PAYMENTASSOCIATION;        // reference the trigger object here
    trigObj.isBefore = Trigger.isBefore;
    trigObj.isDelete = Trigger.isDelete;
    trigObj.isAfter =  Trigger.isAfter;
    trigObj.isInsert = Trigger.isInsert;
    trigObj.isUpdate = Trigger.isUpdate;
    trigObj.isExecuting = Trigger.isExecuting;
    trigObj.newList = Trigger.new;
    trigObj.newMap = Trigger.newMap;
    trigObj.oldList = Trigger.old;
    trigObj.oldMap = Trigger.oldMap;
    
    // Invoke the central dispatcher with the parameter object
    GlUt_CentralDispatcher.mainEntry(trigObj);
}