/******************************************************************************
@author         Swati Mathur
@date           12 Dec 2017
@description    Class For AddToDebtRecovery
@Revision       Swati M - 07 Feb 2018 -- updated DebtRecoveryProfile and PaymentDueDate for new DRP records
@Revision       Tarun Gupta - 04 Oct 2018,AT-3783 - updated Instalment due amount and active field values on Debt Recovery Instalment record
*******************************************************************************/
public class DrUt_AddToDebtRecovery {
    
    /******************************************************************************
    @author         Echo: Swati Mathur
    @date           12 Dec 2017
    @param          Map<Id,List<Instalment__c>> instalmentMap,  Map<Id,DebtRecoveryProcess__c> dRPMap, Map<Id,Id> balanceMap
    @return         none
    @description    This method is called from DrBt_ProcessInstalments Batch class. It will add the instalments to 
                    existing Debt Recovery process or to a new Debt Recovery process
                    AT-4891/2 Code Check Marx Changes for FLS INSERT/UPDATE
    *******************************************************************************/ 
    public static void processBatches(Map<Id,List<Instalment__c>> instalmentMap,  Map<Id,DebtRecoveryProcess__c> dRPMap, Map<Id,Id> balanceMap ){
        
        Boolean dRPNotFound = FALSE;
        List<DebtRecoveryProcess__c> dRPToInsertList = new List<DebtRecoveryProcess__c>();
        List<DebtRecoveryProcess__c> dRPToUpdateList = new List<DebtRecoveryProcess__c>();
        List<DebtRecoveryInstalment__c> dRIToInsertList = new List<DebtRecoveryInstalment__c>();
        
        // Iterate for each Contract and check whether dRP record exists for that contract 
        for(Id instContractId : instalmentMap.keySet()){
            System.debug('instContractId======='+instContractId);
            // If dRP record is found
            if(dRPMap.keySet().contains(instContractId)){
                
                // Iterate for each instalment linked to the assosisated Contract of the dRP record and
                // link them to the dRP record as well
                System.debug('instalmentMap.get(instContractId)======='+instalmentMap.get(instContractId));
                for(Instalment__c instObj : instalmentMap.get(instContractId)){                    
                    // for each instalment a dRI record 
                    DebtRecoveryInstalment__c dRIToBeCreated = new DebtRecoveryInstalment__c();            
                    dRIToBeCreated.Instalment__c = instObj.Id;
                    dRIToBeCreated.DebtRecoveryProcess__c = dRPMap.get(instContractId).Id;
                    dRIToBeCreated.InstalmentAmountDue__c = instObj.InstalmentAmountDue__c; //AT-3783
                    dRIToBeCreated.Active__c = true; //AT-3783
                    dRIToInsertList.add(dRIToBeCreated);
                }
                DebtRecoveryProcess__c dRPObject =  dRPMap.get(instContractId);
                System.debug('dRPObject====='+dRPObject);
                
                if(dRPObject.Id != null){
                    dRPToUpdateList.add(dRPObject);
                }
            } else {
                // If dRP record is not found
                dRPNotFound = True;
                
                // A new dRP record will be created 
                DebtRecoveryProcess__c dRPToBeCreated = new DebtRecoveryProcess__c();
                dRPToBeCreated.BillingContract__c = instContractId;
                dRPToBeCreated.Balance__c =  balanceMap.get(instContractId);
                
                dRPToInsertList.add(dRPToBeCreated);                
            }            
        }
        
        System.debug(dRPToInsertList);
        
        if(dRPNotFound){
            //AT-4891 Code Check Marx Changes Starts Here.
            if(!dRPToInsertList.isEmpty()){
                // insert all dRP objects of the list to create new dRP records
                dRPToInsertList = (List<DebtRecoveryProcess__c>) GlUt_FieldSecurity.cleanseFields(dRPToInsertList, false); 
                insert dRPToInsertList;
            }
            //AT-4891 Code Check Marx Changes Ends Here.
            String debtRecProfile = '';
            
            for(DebtRecoveryProcess__c dRPObj : dRPToInsertList){                
                List<Date> instDueDateList = new List<Date>();
                
                // Iterate for each instalment linked to the assosisated Contract of newly created dRP record
                for( Instalment__c instObj : instalmentMap.get(dRPObj.BillingContract__c)){
                    
                    // A dRI record will be created for the dRP record
                    DebtRecoveryInstalment__c dRIToBeCreated = new DebtRecoveryInstalment__c();            
                    
                    dRIToBeCreated.Instalment__c = instObj.Id;
                    dRIToBeCreated.DebtRecoveryProcess__c = dRPObj.Id;
                    dRIToBeCreated.InstalmentAmountDue__c = instObj.InstalmentAmountDue__c; //AT-3783
                    dRIToBeCreated.Active__c = true; //AT-3783
                    dRIToInsertList.add(dRIToBeCreated);            
                                        
                    debtRecProfile = instObj.PaymentPlan__r.BillingContract__r.DebtRecoveryProfile__c; //AT-3174
                    instDueDateList.add(instObj.InstalmentDueDate__c);
                    
                }                               
                // Update TotalAmountDue, DebtRecoveryProfile and PaymentDueDate of the dRP record 
                DebtRecoveryProcess__c dRPObject = new DebtRecoveryProcess__c();
                
                dRPObject.Id = dRPObj.Id;
                dRPObject.DebtRecoveryProfile__c = debtRecProfile;
                
                instDueDateList.sort();
                dRPObject.PaymentDueDate__c = instDueDateList.get(0);
                
                dRPToUpdateList.add(dRPObject);
                
            }
        }  
        //AT-4891 Code Check Marx Changes Starts Here.
        if(!dRIToInsertList.isEmpty()){
            dRIToInsertList = (List<DebtRecoveryInstalment__c>) GlUt_FieldSecurity.cleanseFields(dRIToInsertList, false); 
            // insert all dRI objects 
            insert dRIToInsertList;  
        }
        //AT-4891 Code Check Marx Changes Ends Here.
        //AT-4892 Code Check Marx Changes Starts Here.
        if(!dRPToUpdateList.isEmpty()){
            // update all existing dRP objects and newly created dRP objects
            dRPToUpdateList = (List<DebtRecoveryProcess__c>) GlUt_FieldSecurity.cleanseFields(dRPToUpdateList, false); 
            update dRPToUpdateList;
        }
        //AT-4892 Code Check Marx Changes Ends Here.
    }
}