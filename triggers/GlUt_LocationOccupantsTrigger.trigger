/************************************************************************************************************
@author        Accenture : Ashish Tiwari
@date          14-Dec-2017
@description:  Location Occupants object trigger
**************************************************************************************************************/
Trigger GlUt_LocationOccupantsTrigger on LocationOccupant__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    //Create a new parameters object for the trigger handler
    GlUt_TriggerHandlerObj trigObj = new GlUt_TriggerHandlerObj();    
    //Update the object with trigger properties
    trigObj.TriggerObject = GlUt_Constants.OBJLOCATIONOCCUPANTS;
    trigObj.IsBefore = trigger.IsBefore;
    trigObj.IsDelete = trigger.IsDelete;
    trigObj.IsAfter =  trigger.IsAfter;
    trigObj.IsInsert = trigger.IsInsert;
    trigObj.IsUpdate = trigger.IsUpdate;
    trigObj.IsExecuting = trigger.IsExecuting;
    trigObj.newlist = trigger.new;
    trigObj.newmap =  trigger.newmap;
    trigObj.oldlist = trigger.old;
    trigObj.oldmap = trigger.oldmap;
        
    //Invoke the central dispatcher with the parameter object
    GlUt_CentralDispatcher.mainEntry(trigObj); 
}