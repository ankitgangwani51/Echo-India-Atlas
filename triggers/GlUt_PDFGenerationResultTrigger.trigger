/******************************************************************************
@author    		Echo: Sudhir Kumar
@date      		25-May-2018
@description 	PDF Request trigger : AT-2466

******************************************************************************/

trigger GlUt_PDFGenerationResultTrigger on PDFGenerationResult__c (before insert, before update, before delete,
                                            after insert, after update, after delete, after undelete) {
                                                
	GlUt_TriggerHandlerObj trigObj = new GlUt_TriggerHandlerObj() ;
    // Update the object with trigger properties
    trigObj.triggerObject = 'PDFGenerationResult' ; 	// To be referenced from GlUt_Constants
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