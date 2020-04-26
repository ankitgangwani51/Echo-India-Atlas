/**********************************************************************************************
@author         Echo : Sudhir Kumar
@date           07-May-2018
@description:   GlUt_BatchRequestQueueTrigger implementation using the trigger handler framework
@revisions:     
**********************************************************************************************/

trigger GlUt_BatchRequestQueueTrigger on BatchRequestQueue__c (
    	before insert, before update, before delete,
        after insert, after update, after delete, after undelete) {
	
    // Create a new parameters object for the trigger handler
    GlUt_TriggerHandlerObj trigObj = new GlUt_TriggerHandlerObj();
    
    // Update the object with trigger properties
    trigObj.TriggerObject = GlUt_Constants.OBJBATCHREQUESTQUEUE ;        // reference the trigger object here
    trigObj.IsBefore = trigger.IsBefore;
    trigObj.IsDelete = trigger.IsDelete;
    trigObj.IsAfter =  trigger.IsAfter;
    trigObj.IsInsert = trigger.IsInsert;
    trigObj.IsUpdate = trigger.IsUpdate;
    trigObj.IsExecuting = trigger.IsExecuting;
    trigObj.newlist = trigger.new;
    trigObj.newmap = trigger.newmap;
    trigObj.oldlist = trigger.old;
    trigObj.oldmap = trigger.oldmap;
    
    // Invoke the central dispatcher with the parameter object
    GlUt_CentralDispatcher.mainEntry(trigObj);                                                               
}