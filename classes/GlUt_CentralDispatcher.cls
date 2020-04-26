/**********************************************************************************************
@author    		Accenture : Manish Singh
@date      		18-Aug-2017
@description: 	This Class is invoked from the trigger and used to dispatch execution to the handler
				methods depending on the event
				Reference : Development Standards document section Atlas Section: 10.3 Trigger Framework  
@group   		TriggerDispatcher
@revisions:		Luke Emberton 24/08/2017 - Updated with details of how to switch triggers on or off 
**********************************************************************************************/
public without sharing class GlUt_CentralDispatcher {
    private static final String CLASS_NAME = 'GlUt_CentralDispatcher';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
    public static GlUt_TriggerHandlerBase activefunction = null;
    
    /**********************************************************************************************
	@author      	Accenture: Luke Emberton
	@date      		18-Aug-2017
	@param			GlUt_TriggerHandlerObj inputParam
	@return			void
	@description		This method is invoked by the code directly from any object triggers. It
	determines the appropriate handler class to fire and runs that so long as
	the custom setting for the user is switched on
	**********************************************************************************************/
    public static void MainEntry(GlUt_TriggerHandlerObj inputParam){   
        
        //Set up some default variables for this method
        boolean triggerEnabled = true;
        string triggerHandlerName = GlUt_Constants.PREFIX + inputParam.TriggerObject + GlUt_Constants.HANDLERSUFFIX;
        string  triggerFieldName = inputParam.TriggerObject + GlUt_Constants.CUSTSETFIELDSUFFIX;
        
        //Retrive the custom setting information
        GlUt_DisableAutomation__c automationSetting = GlUt_DisableAutomation__c.getInstance(UserInfo.getUserId());
        
        Map<String, Object> custSettingsFields = automationSetting.getPopulatedFieldsAsMap();
        
        //Identify if the trigger is running for this object
        if(custSettingsFields.containsKey(triggerFieldName)){
            boolean triggerDisabled = (boolean)custSettingsFields.get(triggerFieldName);
            triggerEnabled = !triggerDisabled;
        }
        //Only if the trigger is enabled for this object then proceed
        if(triggerEnabled){   
            try{
                //If the active function is set then it means that a trigger is currently running
                //therfore call the in progress entry of that trigger to provide any special handling
                //e.g recursion control
                if(activefunction!=null){ 
                    activefunction.InProgressEntry(inputParam);
                }  
                
                //If no triggers are currently running then create a new instance of the appropriate
                //handler for that object
                else{        
                    string TypeName;
                    TypeName = triggerHandlerName;
                    Type t = Type.forName(GlUt_NamespacePrefix.getNamespacePrefix().replace('__',''),TypeName);
                    activefunction = (GlUt_TriggerHandlerBase)t.newInstance();
                    activefunction.MainEntry(inputParam);
                }
                
            }
            catch(Exception ex){
                GlUt_Logger.logException(ex);
                GlUt_Logger.writeLogsToDatabase();
                
                //Diagnostics.DebugException(ex);
                //Diagnostics.PopAll();   
            }
            finally {   
               
            }
        }
    }
    
}