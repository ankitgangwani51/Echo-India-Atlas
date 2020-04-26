/************************************************************************************************************
@author    		Accenture : Luke Emberton
@date      		24-Aug-2017
@description: 	This is the properties class for parameters passed between a trigger and trigger handler class
**************************************************************************************************************/
public class GlUt_TriggerHandlerObj {
	
		public string TriggerObject {get;set;}
		public boolean IsBefore {get;set;}
		public boolean IsDelete {get;set;}
		public Boolean IsAfter{get;set;}
        public Boolean IsInsert {get;set;}
        public Boolean IsUpdate {get;set;}
        public Boolean IsExecuting {get;set;}
        public List<SObject> newlist {get;set;}
        public Map<ID, SObject> newmap {get;set;}
        public List<SObject> oldlist {get;set;}
        public Map<ID,SObject> oldmap {get;set;}
    
}