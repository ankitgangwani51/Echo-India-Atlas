/************************************************************************************************************
@author        Echo : Neha Rajput
@date          14 Dec 2018
@description:  Trigger for RuralMeasurement object
**************************************************************************************************************/
trigger GlUt_RuralMeasurementTrigger on RuralMeasurement__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    //Create a new parameters object for the trigger handler
    GlUt_TriggerHandlerObj trigObj = new GlUt_TriggerHandlerObj();
    
    //Update the object with trigger properties
    trigObj.TriggerObject = GlUt_Constants.OBJRURALMEASUREMENT;
    trigObj.IsBefore 	= trigger.IsBefore;
    trigObj.IsDelete 	= trigger.IsDelete;
    trigObj.IsAfter  	= trigger.IsAfter;
    trigObj.IsInsert 	= trigger.IsInsert;
    trigObj.IsUpdate 	= trigger.IsUpdate;
    trigObj.IsExecuting = trigger.IsExecuting;
    trigObj.newlist     = trigger.new;
    trigObj.newmap  	= trigger.newmap;
    trigObj.oldlist 	= trigger.old;
    trigObj.oldmap  	= trigger.oldmap;
    
    //Invoke the central dispatcher with the parameter object
    GlUt_CentralDispatcher.mainEntry(trigObj); 
    
}