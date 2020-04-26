/************************************************************************************************************
@author        Accenture : Manish Singh
@date          04-Sep-2017
@description:  Reading object trigger
**************************************************************************************************************/
Trigger GlUt_ReadingTrigger on Reading__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

    //Create a new parameters object for the trigger handler
    GlUt_TriggerHandlerObj trigObj = new GlUt_TriggerHandlerObj();    
    //Update the object with trigger properties
    trigObj.TriggerObject =GlUt_Constants.objReading;
    trigObj.IsBefore = trigger.IsBefore;
    trigObj.IsDelete =trigger.IsDelete;
    trigObj.IsAfter =  trigger.IsAfter;
    trigObj.IsInsert = trigger.IsInsert;
    trigObj.IsUpdate = trigger.IsUpdate;
    trigObj.IsExecuting = trigger.IsExecuting;
    trigObj.newlist = trigger.new;
    trigObj.newmap =  trigger.newmap;
    trigObj.oldlist = trigger.old;
    trigObj.oldmap =trigger.oldmap;
        
    //Invoke the central dispatcher with the parameter object
    GlUt_CentralDispatcher.mainEntry(trigObj); 
}