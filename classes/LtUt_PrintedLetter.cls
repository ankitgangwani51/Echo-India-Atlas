/******************************************************************************
@author         Swati Mathur
@date           23 Feb 2018
@description    
*******************************************************************************/
public with sharing class LtUt_PrintedLetter {
    
    private static final String CLASS_NAME = 'LtUt_PrintedLetter';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    //End of AT-2372 
        
    /******************************************************************************
    @author         Swati Mathur
    @date           23 Feb 2018 
    @param          
    @description    Constructor
    *******************************************************************************/
    public LtUt_PrintedLetter(Map<Id,String> ActivityIdToHtmlBodyMap){
        
        //call to CreateLetterPdfRequest method
        if(!ActivityIdToHtmlBodyMap.keySet().isEmpty())
          CreateLetterPdfRequest(ActivityIdToHtmlBodyMap);
    }
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           23 Feb 2018 
    @param          
    @return         
    @description    Creates a new CreateLetterPdfRequest record and populates it with  HtmlBody of EmailMessage
                    and WhoId/WhatId of related Task
    @revision       MT -  01/06/2018 AT - 2372 Change the logic to populate the account, contact,
                    contract fields on the PDFRequest object
    *******************************************************************************/ 
    public static void CreateLetterPdfRequest(Map<Id,String> ActivityIdToHtmlBodyMap){
        try{
            
            system.debug('CreateLetterPdfRequest ');
            List<Task> lstTask =  [SELECT WhoId, WhatId FROM Task WHERE ID IN: ActivityIdToHtmlBodyMap.keySet()];  
            List<PDFRequest__c> lstCreateLetterPDFRequest = new List<PDFRequest__c>();
            Map<Id,Id> contactIdAccountIdMap = new Map<Id,Id>();
            Map<Id,Id> contractIdAccountIdMap = new Map<Id,Id>();
            
              system.debug('lstTask '   +  lstTask);

            if(!lstTask.isEmpty()){
                for(Task objTask : lstTask){
                    
                    PDFRequest__c objCreateLetterPDFRequest = new PDFRequest__c();
                    objCreateLetterPDFRequest.HtmlBody__c = ActivityIdToHtmlBodyMap.get(objTask.Id);
                    objCreateLetterPDFRequest.SourceType__c = LtUt_Constants.HTMLPDFSOURCETYPE ;
                    objCreateLetterPDFRequest.Status__c = LtUt_Constants.PENDINGPDFSTATUS;
                    objCreateLetterPDFRequest.CorrespondenceType__c = LtUt_Constants.CORRESPONDENCETYPE;
                    
                    //Checking if task contains whoId than assigning the whoId in contact
                    if(objTask.WhoId != null){
                        if(objTask.WhoId.getsObjectType() == Contact.sObjectType){
                            objCreateLetterPDFRequest.Contact__c = objTask.WhoId;
                            contactIdAccountIdMap.put(objTask.WhoId, null);
                        }
                    }
                    //Checking if task contains whoId than assigning the whatId in contract or account
                    if(objTask.WhatId != null){
                        if(objTask.WhatId.getsObjectType() == Account.sObjectType){
                            objCreateLetterPDFRequest.Account__c = objTask.WhatId;
                        }
                        if(objTask.WhatId.getsObjectType() == BillingContract__c.sObjectType){
                            objCreateLetterPDFRequest.BillingContract__c = objTask.WhatId;
                            contractIdAccountIdMap.put(objTask.WhatId, null);
                        }
                    }
                    lstCreateLetterPDFRequest.add(objCreateLetterPDFRequest);
                }
            }
            //Building Map of contact Id and its related account id
            if(!contactIdAccountIdMap.keySet().isEmpty()){
                List<Contact> lstContact = [SELECT AccountId From Contact WHERE Id IN :contactIdAccountIdMap.keySet()];
                if(!lstContact.isEmpty()){
                    for(Contact objContact : lstContact){
                        if(objContact.AccountId != null){
                            contactIdAccountIdMap.put(objContact.Id,objContact.AccountId);
                        }
                    }
                }
            }
            //Building Map of contract Id and its related account id
            if(!contractIdAccountIdMap.keySet().isEmpty()){
                List<BillingContract__c> lstContract = [SELECT AccountName__c From BillingContract__c WHERE Id IN :contractIdAccountIdMap.keySet()];
                if(!lstContract.isEmpty()){
                    for(BillingContract__c objContract : lstContract){
                        if(objContract.AccountName__c != null){
                            contractIdAccountIdMap.put(objContract.Id,objContract.AccountName__c);
                        }
                    }
                }
            }
            
            //updating the PDFRequest records with the account id
            if(!contactIdAccountIdMap.keySet().isEmpty() || !contractIdAccountIdMap.keySet().isEmpty()){
                for(PDFRequest__c objPDFRequest : lstCreateLetterPDFRequest){
                    if(objPDFRequest.Account__c == null && contactIdAccountIdMap.containsKey(objPDFRequest.Contact__c)){
                        objPDFRequest.Account__c = contactIdAccountIdMap.get(objPDFRequest.Contact__c);
                    }
                    if(contractIdAccountIdMap.containsKey(objPDFRequest.BillingContract__c)){
                        objPDFRequest.Account__c = contractIdAccountIdMap.get(objPDFRequest.BillingContract__c);
                    }  
                }
            }
            if(!lstCreateLetterPDFRequest.isEmpty()){
                lstCreateLetterPDFRequest = (List<PDFRequest__c>) GlUt_FieldSecurity.cleanseFields(lstCreateLetterPDFRequest, false); 
                Database.insert(lstCreateLetterPDFRequest);
                        System.debug('lstCreateLetterPDFRequest***'+ lstCreateLetterPDFRequest);
            }  
        }catch(exception e){
            GlUt_Logger.logException(e);
            System.debug('Error : ' +e.getMessage());
        }finally{
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
}