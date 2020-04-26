/******************************************************************************
	@author    		Echo: Sudhir Kumar
	@date      		23 Oct 2018
	@description 	AT-3514(I want to add encumbrance details to an Information Statement) AT-4134
	@revision		Echo: Sudhir Kumar 16-Jan-2019: AT-4954 (AT-3642) : AU3 - Component Generalization: Ensure the component can be made usable from each object it is called from
					Renamed from LoAp_SelectableMessagesCtrlr_Test  -> GlUt_SelectableMessagesCtrlr_Test.
					Background:
								1. Junction Message object to have these 2 fields: 	Active__c, Message__c
								2. Message object to have this field:				Description__c
								3. 'Parent' object label name, like 'Information Statement', 'Location' for which Message object is to be associated, 
									must be present as one of the picklist values in 'Type' field on Message object.
	
	*******************************************************************************/
	public with sharing class GlUt_SelectableMessagesCtrlr {
		private static List<String> messageFields;    
		static{    
			messageFields = new List<String>();
			messageFields.add(GlUt_APIConstantsMessage.DESCRIPTIONAPINAME);       
		}
		private static List<String> junctionMessageObjectFields;   						//will be reused across all type of junction object messages 
		static{    
			junctionMessageObjectFields = new List<String>();
			junctionMessageObjectFields.add(GlUt_APIConstantsMessage.ACTIVEAPINAME); 	//refering to this object as all other will have to follow the same field API name
			junctionMessageObjectFields.add(GlUt_APIConstantsMessage.OBJECTAPINAME);
		}
		/******************************************************************************
		@author         Neha R. 
		@date           26 Oct 2018
		@parameters 	-
		@return         List<GLAp_FieldProps>
		@description    This method returns the field properties for each of the fields that are
						to be displayed on the screen
		*******************************************************************************/
		@AuraEnabled
		public static List<GLAp_FieldProps> retrieveFieldList(){         
			List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
			try {            
				List<GLAp_FieldProps> MsgProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsMessage.OBJECTAPINAME, messageFields); 
				for(GlAp_FieldProps fieldProp : MsgProps ){
					if (fieldProp.fieldName == GlUt_APIConstantsMessage.DESCRIPTIONAPINAME) {  
						fieldProp.fieldLabel = Label.LoAp_MessageDescription;  
						fieldProp.isEditable = false;
					}
					fldPropList.add(fieldProp);
				}
			} catch (exception e) {
				GlUt_Logger.logException(e);
			}
			finally {
				GlUt_Logger.writeLogsToDatabase();
			}
			return fldPropList;  
		}
		/******************************************************************************
		@author         Sudhir Kumar 
		@date           16-Jan-2019
		@parameters		String sObjectName
		@return         String
		@description    This method 'getRelatedMessageObject' returns related junction Message Object API name
						AT-4954 (AT-3642) : AU3 - Component Generalization: Ensure the component can be made usable from each object it is called from
		*******************************************************************************/
		private static String getRelatedMessageObject(String sObjectName) {
			return sObjectName.replace('__c', GlUt_Constants.MESSAGE_API_SUFFIX) ;
		}
        /******************************************************************************
		@author         Sudhir Kumar 
		@date           16-Jan-2019
		@parameters		String sObjectName
		@return         String - sObject Label
		@description    This method 'getCurrentSObjectLabel' returns current sObject Label
						AT-4954 (AT-3642) : AU3 - Component Generalization: Ensure the component can be made usable from each object it is called from
		*******************************************************************************/
		private static String getCurrentSObjectLabel(String sObjectName) {
			return Schema.getGlobalDescribe().get(sObjectName).getDescribe().getLabel() ;
		}
        
		/******************************************************************************
		@author         Sudhir Kumar 
		@date           16-Jan-2019
		@parameters		String relatedMessageObjectAPI
		@return         sObject
		@description    This method 'getCurrentSObjectInstance' returns related junction Message Object API name
						AT-4954 (AT-3642) : AU3 - Component Generalization: Ensure the component can be made usable from each object it is called from
		*******************************************************************************/
		private static sObject getCurrentSObjectInstance(String relatedMessageObjectAPI) {
			return Schema.getGlobalDescribe().get(relatedMessageObjectAPI).newSObject() ;
		}	
		/******************************************************************************
		@author         Neha R. 
		@date           26 Oct 2018
		@parameters		Id recordId,
						String sObjectName
		@return         List<BlAp_CombinedRecord>
		@description    This method returns the field of Messages that are
						to be displayed on the screen    
		@revision		Sudhir Kumar: AT-4954 (AT-3642) : AU3 - Component Generalization: Ensure the component can be made usable from each object it is called from
		*******************************************************************************/
		@AuraEnabled
		public static List<BlAp_CombinedRecord> retrieveRecordList(Id recordId, String sObjectName) { 
			List<BlAp_CombinedRecord> messageSelectList = new List<BlAp_CombinedRecord>();        
			try {
				Map<Id, SObject> mapRelatedJunctionMessageObj = new Map<Id, SObject>();
				String relatedMessageObjectAPI = getRelatedMessageObject(sObjectName) ;
				String filterStatement = ' WHERE ' + sObjectName + ' = \'' + recordId + '\'' ;             
				for(SObject currentSObject:  GlAp_LightningDataAccess.getRecords(relatedMessageObjectAPI,
																		 junctionMessageObjectFields,
																		 filterStatement)) { 
					
					mapRelatedJunctionMessageObj.put((Id) currentSObject.get(GlUt_APIConstantsMessage.OBJECTAPINAME), currentSObject);                                                 
				}        
				String filterStatementMessage =  ' WHERE ' + GlUt_APIConstantsMessage.TYPEAPINAME + ' = \'' + getCurrentSObjectLabel(sObjectName)  + '\'' +   
												 ' AND ' + GlUt_APIConstantsMessage.ACTIVEAPINAME + ' = TRUE ' + 
												 ' AND ' + GlUt_APIConstantsMessage.SELECTABLEAPINAME + ' = TRUE ' + 
												 ' AND ' + GlUt_APIConstantsMessage.DEFAULTAPINAME + ' = FALSE '; 
				List<Message__c> msgList = new List<Message__c>();
				msgList = (List<Message__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsMessage.OBJECTAPINAME,
																				 messageFields,
																				 filterStatementMessage);              
				for (Message__c objMsg : msgList) {                
					BlAp_CombinedRecord messageSelectRecord = new BlAp_CombinedRecord();  
					messageSelectRecord.uniqueId = objMsg.Id;
					SObject messageObj = mapRelatedJunctionMessageObj.get(objMsg.Id) ;
					if(mapRelatedJunctionMessageObj.containsKey(objMsg.Id) && (Boolean) messageObj.get(GlUt_APIConstantsMessage.ACTIVEAPINAME)) 
						messageSelectRecord.isSelected = TRUE;
					else
						messageSelectRecord.isSelected = FALSE;
					messageSelectRecord.objectMap = new Map<string, sObject>();
					messageSelectRecord.objectMap.put(GlUt_APIConstantsMessage.OBJECTAPINAME, objMsg);                                    
					messageSelectList.add(messageSelectRecord);
				}
			} catch (exception e) {
				GlUt_Logger.logException(e);
			}
			finally {
				GlUt_Logger.writeLogsToDatabase();
			}        
			return messageSelectList;
		}
		
		/******************************************************************************
		@author         Neha R. 
		@date           29 Oct 2018
		@parameters		String responseJSON,
						String recordId,
						String sObjectName
		@return         String
		@description    This method update the field of Contract Bill Message that updated
						on the screen    
		@revision		Sudhir Kumar: AT-4954 (AT-3642) : AU3 - Component Generalization: 
									  Ensure the component can be made usable from each object it is called from					
		*******************************************************************************/
		@AuraEnabled
		public static String saveInformationStatementMessageDetails(String responseJSON, String recordId, String sObjectName) {
			String relatedMessageObjectAPI = getRelatedMessageObject(sObjectName) ;        
			String result = '' ;
			try {            
				set<Id> setSelectedMessageIds = new set<Id>();
				Set<Id> setExistingJunctionMessageIds = new Set<Id>();
				List<BlAp_CombinedRecord> recordList = (List<BlAp_CombinedRecord>) System.JSON.deserialize(responseJSON, List<BlAp_CombinedRecord>.class);
				for(BlAp_CombinedRecord objCombineRecord: recordList){                  
					if(objCombineRecord.isSelected)
						setSelectedMessageIds.add(objCombineRecord.uniqueId);                            
				}            
				List<SObject> sObjectUpdatedList = new List<SObject>();
				List<SObject> sObjectList = new List<SObject>();
				set<Id> setMessageIds = new set<Id>();
				String filterStatement = ' WHERE ' + sObjectName + ' = \'' + recordId + '\'' ; 
				for(SObject currentSObject : GlAp_LightningDataAccess.getRecords(relatedMessageObjectAPI,
																		junctionMessageObjectFields,
																		filterStatement)){ 
					sObjectList.add(currentSObject);
					setMessageIds.add((Id) currentSObject.get(GlUt_APIConstantsMessage.OBJECTAPINAME));                                                                                                                                  	                                                                                                              
				}
				// List of active/default message
				set<Id> setDefaultMesssageIds = new set<Id>();
				for(Message__c objMSG: [SELECT Default__c, Active__c
										FROM Message__c 
										WHERE Id IN: setMessageIds
										  AND Default__c = TRUE]){ 
					setDefaultMesssageIds.add(objMSG.Id); 
				}
				// All junction Message records on current object            
				for(SObject currentSObject: sObjectList) {
					if(setSelectedMessageIds.contains((Id) currentSObject.get(GlUt_APIConstantsMessage.OBJECTAPINAME))) {
						setExistingJunctionMessageIds.add((Id) currentSObject.get(GlUt_APIConstantsMessage.OBJECTAPINAME));
						if(!(Boolean) currentSObject.get(GlUt_APIConstantsMessage.ACTIVEAPINAME)){
							currentSObject.put(GlUt_APIConstantsMessage.ACTIVEAPINAME, TRUE) ;
							sObjectUpdatedList.add(currentSObject);                        
						}
					}else{
						if(!setDefaultMesssageIds.contains((Id) currentSObject.get(GlUt_APIConstantsMessage.OBJECTAPINAME))) {                     
							currentSObject.put(GlUt_APIConstantsMessage.ACTIVEAPINAME, FALSE) ;
							sObjectUpdatedList.add(currentSObject);
						}
					}
				}
				// To update SObject Message List 
				if(!sObjectUpdatedList.isEmpty()) { 
					sObjectUpdatedList = GlUt_FieldSecurity.cleanseFields(sObjectUpdatedList, false); 
					database.update(sObjectUpdatedList);
				}
				// message description           
				Map<Id,Message__c> messsageMap = new Map<Id,Message__c>();
				for(Message__c objMSG: [SELECT Description__c
										FROM Message__c 
										WHERE Id IN: setSelectedMessageIds]){ 
					messsageMap.put(objMSG.Id,objMSG); 
				}
				List<SObject> sObjectInsertList = new List<SObject>();
				for(Id messageID: setSelectedMessageIds) {
					if(!setExistingJunctionMessageIds.contains(messageID)) {
						sObject currentSObject = getCurrentSObjectInstance(relatedMessageObjectAPI) ;
						currentSObject.put(GlUt_APIConstantsMessage.ACTIVEAPINAME, TRUE);
						currentSObject.put(sObjectName, recordId) ;
						currentSObject.put(GlUt_APIConstantsMessage.OBJECTAPINAME, messageID) ;
						if(messsageMap.containsKey(messageID))
							currentSObject.put(GlUt_APIConstantsMessage.DESCRIPTIONAPINAME,messsageMap.get(messageID).Description__c);
						sObjectInsertList.add(currentSObject);
					}                
				}
				if(!sObjectInsertList.isEmpty()) {  
					sObjectInsertList = GlUt_FieldSecurity.cleanseFields(sObjectInsertList, false);               
					database.insert(sObjectInsertList);
				}            
				result =  Label.GlAp_Success;
			} catch (exception e) {
				GlUt_Logger.logException(e);
				result = e.getMessage();          
			}
			return result;
		}   
	}