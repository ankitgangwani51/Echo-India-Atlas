/***************************************************************************************************
@author        Echo : Neha Rajput
@date          25-Jan-2018
@description:  This is helper class used by SupplyPoint object trigger  
@group         TriggerHelper
Revision(s)   
*******************************************************************************************************/
public with sharing class GlUt_SupplyPointHandler extends GlUt_TriggerHandlerBase {
    
    // Variable declaration
    private static final String CLASS_NAME = 'GlUt_SupplyPointHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    // End variable declaration
    
    /**********************************************************************************************
    @author        Echo: Neha Rajput
    @date          25-Jan-2017
    @param         GlUt_TriggerHandlerObj inputParam
    @return        void
    @description   This method is used to invoke method from trigger
    **********************************************************************************************/
    public override void MainEntry(GlUt_TriggerHandlerObj inputParam) {
        try { 
            if (inputParam.isInsert && inputParam.isBefore) {           
                supplyPointBeforeInsert(inputParam.newlist);
                //ruralChannel(inputParam.newlist);					//AT-4473
            }
            if (inputParam.isInsert && inputParam.isAfter) {
            }
            if (inputParam.isUpdate && inputParam.isBefore) {                     
                supplyPointBeforeUpdate(inputParam.newlist, inputParam.oldmap);
                //ruralChannel(inputParam.newlist);     //AT-4473
            }
            if (inputParam.isUpdate && inputParam.isAfter) {
               allocateOutStandingBillItemToPaymentAllocQueue(inputParam.newlist, inputParam.oldmap);
            }
            if (inputParam.isDelete && inputParam.isBefore) {
                
            }
            if (inputParam.isDelete && inputParam.isAfter) {
                
            }
        } catch (Exception ex) {
            system.debug('Line Number:=' + ex.getLineNumber());
            system.debug('Line Number:=' + ex.getMessage());
            system.debug('Line Number:=' + ex.getStackTraceString());
            GlUt_Logger.logException(ex);
            GlUt_Logger.writeLogsToDatabase();
            

        } finally {
            //Reset the active function to null in case this class was first in stack
            //this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            
        }        
    }
    
    /**********************************************************************************************
    @author        Echo: Neha Rajput
    @date          25-Jan-2018
    @param         <List> newMap
    @return        void
    @description   This method is used to process Suppy Point
    **********************************************************************************************/
    private void supplyPointBeforeInsert(List <SupplyPoint__c> newlist) {
        
        Set<Id> newBookSet = new Set<Id>();
        Set<Id> locationIds = new Set<Id>();
        Set<SupplyPoint__c> bookUpdatedOnSPSet = new Set<SupplyPoint__c>();                     
        Map<Id, String> maxWalkOrdOnBookMap = new Map<Id, String>();
        Map<Id, List<String>> listOfWalkOrdOnBookMap = new Map<Id, List<String>>();      
        
        Map<Id,Book__c> bookIdMap = new Map<Id,Book__c>(); 
        Map<Id, Boolean> mapOfConsiderationStatusByLocationId = new Map<Id, Boolean>();
        /*List<BillingContract__c> disconnectPermitAccList = new List<BillingContract__c>(); //AT-3303
        disconnectPermitAccList = disconnectionPermitted();*/
        for(SupplyPoint__c objSupplyPoint: newlist ){
          if(objSupplyPoint.Location__c != null){
              locationIds.add(objSupplyPoint.Location__c);
          } 
        }
        if(locationIds.size() > 0){
           mapOfConsiderationStatusByLocationId = createAllowDisconnectionFlagData(locationIds);
        }
        
        for(SupplyPoint__c objSupplyPoint: newlist ){           
            setAllowDisconnectionFlag(objSupplyPoint,mapOfConsiderationStatusByLocationId);    
            if(objSupplyPoint.Book__c != null){                              
                newBookSet.add(objSupplyPoint.Book__c);
                bookUpdatedOnSPSet.add(objSupplyPoint);
            }else{
                if(objSupplyPoint.WalkOrder__c != null)
                    objSupplyPoint.WalkOrder__c = null;                
            }  
        }       
        
        if(bookUpdatedOnSPSet.size() > 0) { 
            
            // Book Details
            for(Book__c objBook : [SELECT Id,ReadFrequency__c ,  Depot__c FROM Book__c WHERE Id IN: newBookSet]){  
                bookIdMap.put(objBook.Id, objBook);                            
            }
            
            WrapWalkOrder wrapperclass = new WrapWalkOrder();
            wrapperclass = walkOrderDetails( newBookSet);
            
            for(SupplyPoint__c objSupplyPoint : bookUpdatedOnSPSet){
                
                // Read frequency of SupplyPoint Don't match with Book Read Frequency
             //  if( objSupplyPoint.ReadFrequency__c != bookIdMap.get(objSupplyPoint.Book__c).ReadFrequency__c )
             //       objSupplyPoint.ReadFrequency__c = bookIdMap.get(objSupplyPoint.Book__c).ReadFrequency__c;                
               
                If(objSupplyPoint.Book__c != null){   
                    
                    // Supply Point & Depot don't match
                    if(objSupplyPoint.Depot__c != null){
                        if(bookIdMap.containsKey(objSupplyPoint.Book__c) &&
                           objSupplyPoint.Depot__c != bookIdMap.get(objSupplyPoint.Book__c).Depot__c){                                
                               objSupplyPoint.addError(Label.GlUt_SPBookDepotError);
                           }
                    }else{
                        //update Supply Point Depot by Book Depot  
                        objSupplyPoint.Depot__c = bookIdMap.get(objSupplyPoint.Book__c).Depot__c;    
                    }  
                    
                    // Walk Order.....
                    if(objSupplyPoint.WalkOrder__c == null && objSupplyPoint.Book__c != null){
                        
                        // start AT-3015                           
                        if((wrapperclass.maxWalkOrdOnBookMap).containsKey(objSupplyPoint.Book__c))
                            objSupplyPoint.WalkOrder__c = (wrapperclass.maxWalkOrdOnBookMap).get(objSupplyPoint.Book__c) + 1;
                        else
                            objSupplyPoint.WalkOrder__c = 1;
                        // end AT-3015
                        
                        (wrapperclass.maxWalkOrdOnBookMap).put(objSupplyPoint.Book__c, Integer.valueOf(objSupplyPoint.WalkOrder__c));
                        
                        if((wrapperclass.listOfWalkOrdOnBookMap).containsKey(objSupplyPoint.Book__c)){
                            List<Integer> walkOrdList = (wrapperclass.listOfWalkOrdOnBookMap).get(objSupplypoint.Book__c);
                            walkOrdList.add(Integer.valueOf(objSupplypoint.WalkOrder__c));
                            (wrapperclass.listOfWalkOrdOnBookMap).put(objSupplypoint.Book__c, walkOrdList);  
                        }else{ //AT- 3015
                            List<Integer> walkOrdList = new List<Integer>();
                            walkOrdList.add(Integer.valueOf(objSupplypoint.WalkOrder__c));
                            (wrapperclass.listOfWalkOrdOnBookMap).put(objSupplypoint.Book__c, walkOrdList);                     
                        } 
                    }else{
                        if((wrapperclass.listOfWalkOrdOnBookMap).containsKey(objSupplyPoint.Book__c)){
                            List<Integer> walkOrderList = (wrapperclass.listOfWalkOrdOnBookMap).get(objSupplyPoint.Book__c);
                            if (walkOrderList.contains(Integer.valueOf(objSupplyPoint.WalkOrder__c)) ){
                                /* Boolean correctWalkOrder = false;
                                if((wrapperclass.WalkOrderOnSPMap).get(objSupplyPoint.Id) == objSupplyPoint.WalkOrder__c)
                                correctWalkOrder = true;
                                if(correctWalkOrder == false)*/
                                objSupplyPoint.addError(Label.GlUt_SPWalkOrderError); 
                            }else{
                                List<Integer> walkOrdList = (wrapperclass.listOfWalkOrdOnBookMap).get(objSupplypoint.Book__c);
                                walkOrdList.add(Integer.valueOf(objSupplypoint.WalkOrder__c));
                                (wrapperclass.listOfWalkOrdOnBookMap).put(objSupplypoint.Book__c, walkOrdList); 
                            }
                        }else{
                            List<Integer> walkOrdList = new List<Integer>();
                            walkOrdList.add(Integer.valueOf(objSupplypoint.WalkOrder__c));
                            (wrapperclass.listOfWalkOrdOnBookMap).put(objSupplypoint.Book__c, walkOrdList);                     
                        } 
                    }
                }              
            }
        }
    }
    
    /**********************************************************************************************
    @author        Echo: Neha Rajput
    @date          25-Jan-2018
    @param         List <SupplyPoint__c> newlist, Map<Id,sObject> oldmap
    @return        void
    @description   This method is used to process Suppy Point
                    AT-4890 - CRUD Delete for GlUt_SupplyPointHandler - Added Cleanse (Code Check Marx Security Review)
    **********************************************************************************************/    
    public void supplyPointBeforeUpdate(List <SupplyPoint__c> newlist,Map<Id,sObject> oldmap) {
        
        Map<Id, String> spBookDepotMap = new Map<Id, String>();       
        Map<Id, Id> oldBookReadTTMap = new Map<Id, Id>();
        Map<Id, Id> activeSupplyPointContractMap = new Map<Id, Id>();
        Map<Id, Id> contractAccountMap = new Map<Id, Id>();
        Map<Id, Id> contractPaymentPlanMap = new Map<Id, Id>();
        Map<Id, Id> paymentPlanPaymentPlanTypeMap = new Map<Id, Id>();
        Map<Id, Date> paymentPlanStartDateMap = new Map<Id, Date>();
        Map<Id, List<Instalment__c>> paymentPlanInstalmentListMap = new Map<Id, List<Instalment__c>>();     
        Map<Id, PaymentPlanType__c> PaymentPlanTypeIdObjectMap = new Map<Id, PaymentPlanType__c>();
        Map<Id, List<Instalment__c>> ppNewInstallmentList = new Map<Id, List<Instalment__c>>(); 
        Map<Id, Date> contractRenewalDateMap = new Map<Id, Date>();  
        Map<Id, Book__c> newBookIdMap = new Map<Id, Book__c>();
        Set<Id> locationIds = new Set<Id>();
        Set<Id> newBookSet = new Set<Id>();
        Set<Id> oldBookSet = new Set<Id>();
        Set<Book__c> newBookObjectSet = new Set<Book__c>(); 
        Set<SupplyPoint__c> supplyPointBookUpdatedSet = new Set<SupplyPoint__c>();
        Set<SupplyPoint__c> allSPOnBookUpdatedSet = new Set<SupplyPoint__c>();
        Set<Id> booksIdSet = new Set<Id>();
        Set<String> newBookDepotSet = new Set<String>();
                    
        String supplyPointBook, supplyPointDepot;
        Map<Id, Boolean> mapOfConsiderationStatusByLocationId = new Map<Id, Boolean>();
        /*List<BillingContract__c> disconnectPermitAccList = new List<BillingContract__c>(); //AT-3303
        disconnectPermitAccList = disconnectionPermitted();*/
        for(SupplyPoint__c objSupplyPoint: newlist ){
          if(objSupplyPoint.Location__c != null){
              locationIds.add(objSupplyPoint.Location__c);
          } 
        }
        if(locationIds.size() > 0){
           mapOfConsiderationStatusByLocationId = createAllowDisconnectionFlagData(locationIds);
        }
        for(SupplyPoint__c objSupplyPoint: newlist){
            SupplyPoint__c oldValue = (SupplyPoint__c)oldmap.get(objSupplyPoint.id);
            System.debug('oldValue=='+oldValue);
            System.debug('objSupplyPoint=='+objSupplyPoint);
            if (objSupplyPoint.SupplyDisconnectionStatus__c != oldValue.SupplyDisconnectionStatus__c){              
                setAllowDisconnectionFlag(objSupplyPoint,mapOfConsiderationStatusByLocationId); 
            }             
            
            // Modified Book on Supply Point and current Book Value is not null  
            if(objSupplyPoint.Book__c != null && objSupplyPoint.Book__c <> oldValue.Book__c ){
                // AT-3030 started
                // Update if Current book not null
                if(oldValue.Book__c != null){
                    // Updated Supply Point  Set
                    supplyPointBookUpdatedSet.add(objSupplyPoint);
                }
                // Set of all Supply Point where Book update either current book is blank
                allSPOnBookUpdatedSet.add(objSupplyPoint);                
                // ens of AT-3030
                
                //Set of New book associated with Supply Point
                newBookSet.add(objSupplyPoint.Book__c);
                
                //Set of Current book associated on Supply Point
                oldBookSet.add(oldValue.Book__c);               
                
                //Depot associated with the Supply Point
                if (objSupplyPoint.Depot__c != null){
                    supplyPointBook = String.valueOf(objSupplyPoint.Book__c);
                    supplyPointDepot = String.valueOf(objSupplyPoint.Depot__c);
                    // Map to book and depot combination associated with Supply Point
                    spBookDepotMap.put(objSupplyPoint.Id, supplyPointBook + ',' + supplyPointDepot);
                } 
            }
            
            if (objSupplyPoint.Book__c == null && objSupplyPoint.WalkOrder__c != null)
                objSupplyPoint.WalkOrder__c = null;
            
            if(objSupplyPoint.Book__c != null){
                booksIdSet.add(objSupplyPoint.Book__c);
            }
        }
        
        System.debug('spBookDepotMap=='+spBookDepotMap);
        
        //If Book updated on Supply Point
        if(allSPOnBookUpdatedSet.size() > 0){   // AT-3030      
            
            // Details of New & Current Books associated with updated Supply Point
            for(Book__c objBook : [SELECT Id, Depot__c,ReadTimetable__c,BudgetResetMonth__c,ReadFrequency__c
                                   FROM Book__c 
                                   WHERE Id IN: newBookSet 
                                   OR Id IN: oldBookSet ]){   
                                       
                                       // new book details
                                       if(newBookSet.contains(objBook.Id)){                    
                                           // Combination of book and depot associated with book
                                           newBookDepotSet.add(String.valueOf(objBook.Id) + ',' + String.valueOf(objBook.Depot__c)); 
                                           
                                           // new Book Map
                                           newBookIdMap.put(objBook.Id,objBook);                   
                                           
                                           newBookObjectSet.add(objBook);
                                       }
                                       
                                       // old book details
                                       if(oldBookSet.contains(objBook.Id)){                    
                                           
                                           // Map of Read Timetable associated with CURRENT Book
                                           oldBookReadTTMap.put(objBook.Id,objBook.ReadTimetable__c);
                                       }
                                   }
            
            System.debug('newBookDepotSet=='+newBookDepotSet);
            
            if(supplyPointBookUpdatedSet.size() > 0){    //AT-3030 
                // Active Contract associated with Supply Points             
                for(SupplyPoint__c objSupplyPoint: [SELECT Id,
                                                    (SELECT Id, BillingContract__c, BillingContract__r.PaymentPlanRenewalDate__c, BillingContract__r.AccountName__c 
                                                     FROM Services__r 
                                                     WHERE ServiceEndDate__c =: null 
                                                     OR ServiceEndDate__c >: System.today() )
                                                    FROM SupplyPoint__c
                                                    WHERE Id IN: supplyPointBookUpdatedSet ])
                {
                    for(Service__c objService: objSupplyPoint.Services__r){
                        activeSupplyPointContractMap.put(objSupplyPoint.Id,objService.BillingContract__c);  
                        contractAccountMap.put(objService.BillingContract__c,objService.BillingContract__r.AccountName__c);
                    }
                }
                
                //Active Payment Plan Details
                for(PaymentPlan__c objPaymentPlan: [SELECT Id, PaymentPlanType__c, StartDate__c, BillingContract__c,//AT-3174
                                                    (SELECT Id,Type__c,InstalmentNumber__c, InstalmentAmountDue__c, InstalmentDueDate__c,PaymentPlan__c FROM Instalments__r)                                                 
                                                    FROM PaymentPlan__c
                                                    WHERE BillingContract__c IN: activeSupplyPointContractMap.values()//AT-3174
                                                    AND Active__c = TRUE
                                                    AND PaymentPlanType__r.PlanType__c =: GlUt_Constants.BUDGETPLAN]){  // 'Budget Plan']){
                                                        contractPaymentPlanMap.put(objPaymentPlan.BillingContract__c, objPaymentPlan.Id);//AT-3174
                                                        paymentPlanPaymentPlanTypeMap.put(objPaymentPlan.Id,objPaymentPlan.PaymentPlanType__c);
                                                        paymentPlanStartDateMap.put(objPaymentPlan.Id,objPaymentPlan.StartDate__c);
                                                        paymentPlanInstalmentListMap.put(objPaymentPlan.Id,objPaymentPlan.Instalments__r);
                                                    }
                
                //List of Payment Plan Type associated with Payment Plan
                for(PaymentPlanType__c objPaymentPlanType: [SELECT Id,Name,PlanType__c,PaymentFrequency__c,MaximumNumberOfInstalments__c,NumberofRollingInstalments__c
                                                            FROM PaymentPlanType__c
                                                            WHERE Id IN: paymentPlanPaymentPlanTypeMap.values()]){
                                                                PaymentPlanTypeIdObjectMap.put(objPaymentPlanType.Id, objPaymentPlanType);                                          
                                                            }
                
                system.debug('supplyPointBookUpdatedSet=='+supplyPointBookUpdatedSet);
                List<GlUt_CorrespondenceHandler.ContainerWrapper> wrapperObjectsList = new List<GlUt_CorrespondenceHandler.ContainerWrapper>();
                for(SupplyPoint__c objSupplyPoint : supplyPointBookUpdatedSet){
                    
                    //Check combination of book and depot on supply Point and New Book 
                    system.debug('spBookDepotMap==2='+spBookDepotMap);
                    system.debug('newBookDepotSet==2='+newBookDepotSet);
                    if(spBookDepotMap.containsKey(objSupplyPoint.Id) &&  (!newBookDepotSet.contains(spBookDepotMap.get(objSupplyPoint.Id))) ){                    
                        objSupplyPoint.addError(Label.GlUt_SPBookDepotError); 
                    }
                    
                    SupplyPoint__c CurrentValues = (SupplyPoint__c)oldmap.get(objSupplyPoint.id);
                    //Check the Read Timetable on the current Book against the New Book
                    if(newBookIdMap.get(objSupplyPoint.Book__c).ReadTimetable__c != oldBookReadTTMap.get(CurrentValues.Book__c) && 
                       activeSupplyPointContractMap.containsKey(objSupplyPoint.Id) &&
                       contractPaymentPlanMap.containsKey(activeSupplyPointContractMap.get(objSupplyPoint.Id))){
                           
                           List<Book__c> bookList = new List<Book__c>();
                           
                           for(Book__c objBook: newBookObjectSet){
                               if(objBook.Id == objSupplyPoint.Book__c)
                                   bookList.add(objBook);
                           }
                           
                           Id contractId = activeSupplyPointContractMap.get(objSupplyPoint.Id);
                           Date planStartDate =  paymentPlanStartDateMap.get(contractPaymentPlanMap.get(contractId));
                           PaymentPlanType__c paymentPlanTypeObject = PaymentPlanTypeIdObjectMap.get(paymentPlanPaymentPlanTypeMap.get(contractPaymentPlanMap.get(contractId)));
                           List<Instalment__c> listOfWizardInstalments = paymentPlanInstalmentListMap.get(contractPaymentPlanMap.get(contractId));
                           
                           // updated plan list
                           GlUt_UpdateBudgetRenewals.WrapPaymentPlanInstalments objWarpper = new GlUt_UpdateBudgetRenewals.WrapPaymentPlanInstalments();
                           
                           objWarpper = GlUt_UpdateBudgetRenewals.amendPPInstalments(String.valueOf(contractId), planStartDate, paymentPlanTypeObject, listOfWizardInstalments, bookList, null); //AT-2913,2935
                           
                           contractRenewalDateMap.put(contractId, objWarpper.contractRenewalDate);
                           ppNewInstallmentList.put(contractPaymentPlanMap.get(contractId), objWarpper.lstInstalmentsToBeAdded);
                           
                           // PDF Request
                           Id accountId = contractAccountMap.get(contractId);
                           
                           // GlUt_CorrespondenceHandler class handler object 
                           GlUt_CorrespondenceHandler.ContainerWrapper wrapperObj = new GlUt_CorrespondenceHandler.ContainerWrapper(accountId,null,GlUt_Constants.READTIMETABLECHANGE,null,null);
                           wrapperObjectsList.add(wrapperObj);                          
                       } 
                }
                
                // PDF Request
                if(wrapperObjectsList.size() > 0)
                    GlUt_CorrespondenceHandler.CreateCorrespondence(wrapperObjectsList);
            }
            
            // ReadFrequency...
            for(SupplyPoint__c objSupplyPoint : allSPOnBookUpdatedSet){ 
                //ReadFrequency associated to SupplyPoint and Book don't match                
              //  if(objSupplyPoint.ReadFrequency__c != newBookIdMap.get(objSupplyPoint.Book__c).ReadFrequency__c)
              //     objSupplyPoint.ReadFrequency__c = newBookIdMap.get(objSupplyPoint.Book__c).ReadFrequency__c;
                        }
            
            // walk order.....           
            if(booksIdSet.size() > 0){
                WrapWalkOrder wrapperclass = new WrapWalkOrder();                
                wrapperclass = walkOrderDetails(booksIdSet);
                
                for(SupplyPoint__c objSupplyPoint: newlist)
                {
                    If(objSupplyPoint.Book__c != null){
                        
                        if(objSupplyPoint.WalkOrder__c == null && objSupplyPoint.Book__c != null){                           
                            // start AT-3015
                            if((wrapperclass.maxWalkOrdOnBookMap).containsKey(objSupplyPoint.Book__c))
                                objSupplyPoint.WalkOrder__c = (wrapperclass.maxWalkOrdOnBookMap).get(objSupplyPoint.Book__c) + 1;
                            else
                                objSupplyPoint.WalkOrder__c = 1;
                            // end AT-3015
                            (wrapperclass.maxWalkOrdOnBookMap).put(objSupplyPoint.Book__c, Integer.valueOf(objSupplyPoint.WalkOrder__c));
                            
                            if((wrapperclass.listOfWalkOrdOnBookMap).containsKey(objSupplyPoint.Book__c)){
                                List<Integer> walkOrdList = (wrapperclass.listOfWalkOrdOnBookMap).get(objSupplypoint.Book__c);
                                walkOrdList.add(Integer.valueOf(objSupplypoint.WalkOrder__c));
                                (wrapperclass.listOfWalkOrdOnBookMap).put(objSupplypoint.Book__c, walkOrdList);  
                            }else{  // AT-3015
                                List<Integer> walkOrdList = new List<Integer>();
                                walkOrdList.add(Integer.valueOf(objSupplypoint.WalkOrder__c));
                                (wrapperclass.listOfWalkOrdOnBookMap).put(objSupplypoint.Book__c, walkOrdList);                     
                            }                             
                        }else{
                            if((wrapperclass.listOfWalkOrdOnBookMap).containsKey(objSupplyPoint.Book__c)){
                                List<Integer> walkOrderList = (wrapperclass.listOfWalkOrdOnBookMap).get(objSupplyPoint.Book__c);
                                if (walkOrderList.contains(Integer.valueOf(objSupplyPoint.WalkOrder__c) )){
                                    Boolean correctWalkOrder = false;
                                    if((wrapperclass.WalkOrderOnSPMap).get(objSupplyPoint.Id) == objSupplyPoint.WalkOrder__c)
                                        correctWalkOrder = true;
                                    
                                    if(correctWalkOrder == false)
                                        objSupplyPoint.addError(Label.GlUt_SPWalkOrderError); 
                                }else{
                                    List<Integer> walkOrdList = (wrapperclass.listOfWalkOrdOnBookMap).get(objSupplypoint.Book__c);
                                    walkOrdList.add(Integer.valueOf(objSupplypoint.WalkOrder__c));
                                    (wrapperclass.listOfWalkOrdOnBookMap).put(objSupplypoint.Book__c, walkOrdList); 
                                }
                            }else{
                                List<Integer> walkOrdList = new List<Integer>();
                                walkOrdList.add(Integer.valueOf(objSupplypoint.WalkOrder__c));
                                (wrapperclass.listOfWalkOrdOnBookMap).put(objSupplypoint.Book__c, walkOrdList);                     
                            } 
                        }
                    }  
                }       
            }
            
            // update Contract Renewal Date
            if (contractRenewalDateMap.size() > 0){
                List<BillingContract__c> updatedBillingContractList = new List<BillingContract__c>();
                for(BillingContract__c objContract : [SELECT Id,PaymentPlanRenewalDate__c FROM BillingContract__c WHERE Id IN: contractRenewalDateMap.keySet()]){
                    objContract.PaymentPlanRenewalDate__c = contractRenewalDateMap.get(objContract.Id);
                    updatedBillingContractList.add(objContract);                  
                }
                if (updatedBillingContractList.size() > 0){
                    updatedBillingContractList = (List<BillingContract__c>) GlUt_FieldSecurity.cleanseFields(updatedBillingContractList, false);
                    database.update(updatedBillingContractList);   
                }
                
            }
            
            // update installments
            List<Instalment__c> addInstallmentList = new List<Instalment__c>();
            List<Instalment__c> deleteInstallmentList = new List<Instalment__c>();            
            if (ppNewInstallmentList.size() > 0){
                
                for(Id objPaymentPlan : ppNewInstallmentList.keySet()){
                    
                    List<Instalment__c> newInstalmentList = ppNewInstallmentList.get(objPaymentPlan);
                    List<Instalment__c> oldInstalmentList = paymentPlanInstalmentListMap.get(objPaymentPlan);
                    
                    // Add Instalments
                    if (newInstalmentList.size() > oldInstalmentList.size()){
                        for(Instalment__c objNewInstalment : newInstalmentList){
                            boolean instalmentFound = false;                            
                            for(Instalment__c objOldInstalment: oldInstalmentList){
                                if(objOldInstalment.InstalmentDueDate__c == objNewInstalment.InstalmentDueDate__c){
                                    if(objOldInstalment.Type__c == objNewInstalment.Type__c){
                                        instalmentFound = true;
                                    }else{
                                        deleteInstallmentList.add(objOldInstalment); 
                                    }                            
                                }
                            }
                            if(instalmentFound == false){
                                objNewInstalment.PaymentPlan__c = objPaymentPlan;
                                addInstallmentList.add(objNewInstalment);
                            }                            
                        }
                    }else if((newInstalmentList.size() < oldInstalmentList.size())){ // delete installments
                        for(Instalment__c objOldInstalment : oldInstalmentList){
                            boolean instalmentFound = false;
                            for(Instalment__c objNewInstalment: newInstalmentList){
                                if(objOldInstalment.InstalmentDueDate__c == objNewInstalment.InstalmentDueDate__c){ 
                                    if(objOldInstalment.Type__c == objNewInstalment.Type__c){
                                        instalmentFound = true;
                                    }else{
                                        objNewInstalment.PaymentPlan__c = objPaymentPlan;
                                        addInstallmentList.add(objNewInstalment); 
                                    }  
                                }
                            }
                            if(instalmentFound == false){
                                deleteInstallmentList.add(objOldInstalment);
                            }                            
                        }                        
                    }            
                }   
            }
            
            if(addInstallmentList.size() > 0){
                addInstallmentList = (List<Instalment__c>) GlUt_FieldSecurity.cleanseFields(addInstallmentList, false);
                database.insert(addInstallmentList);  
            }
            
            if(deleteInstallmentList.size() > 0){
                /*AT-4890 Code Check marx Changes Starts here*/
                if(GlUt_ObjectSecurity.isObjectPermission(deleteInstallmentList,true,false,false,false,false)){ 
                    deleteInstallmentList = (List<Instalment__c>) GlUt_FieldSecurity.cleanseFields(deleteInstallmentList, false); 
                    database.delete(deleteInstallmentList); 
                }
                /*AT-4890 Code Check marx Changes Ends here*/
            }
        } 
    }
    /**********************************************************************************************
    @author        Echo: Dependra Singh
    @date          01-Nov-2018
    @param         set<Id> locationIds
    @return        Map<Id, Boolean>
    @description   This method is used to create the map for check the permission of Allow disconnection status
                   If It is allowed from Location -> LocationOccupant -> Account -> Consideration -> ConsiderationType 
                  (Check the permission if it is on ConsiderationType)
    **********************************************************************************************/       
    private Map<Id, Boolean>  createAllowDisconnectionFlagData(set<Id> locationIds) { 
        Map<Id, Boolean> mapOfConsiderationStatusByLocationId = new Map<Id, Boolean>();
        Set<Id> accountIds = new Set<Id>(); 
        Map<Id, Boolean> mapOfConsiderationByAccountId = new Map<Id, Boolean>();
        
        if(locationIds.size() > 0){
          List<LocationOccupant__c> locationOccupantList = [SELECT Id,Location__c,Account__c,Active__c 
                                                            FROM LocationOccupant__c WHERE Location__c IN : locationIds 
                                                            AND Active__c = true ];
            if(locationOccupantList != null && locationOccupantList.size() >0 ){
                for(LocationOccupant__c objLocationOccupant : locationOccupantList){
                    accountIds.add(objLocationOccupant.Account__c);
                }
        
                if(accountIds.size() > 0){
                    List<Consideration__c> considerationList = [SELECT Id, Account__c , ConsiderationType__r.DisconnectionPermitted__c 
                                                                FROM Consideration__c WHERE Account__c IN : accountIds];
                                                                
                    if(considerationList != null && !considerationList.isEmpty()){
                        for(Consideration__c objConsideration : considerationList){
                            if(!mapOfConsiderationByAccountId.containsKey(objConsideration.Account__c)){
                                mapOfConsiderationByAccountId.put(objConsideration.Account__c, objConsideration.ConsiderationType__r.DisconnectionPermitted__c);
                            }
                        }
                    }                                           
                }
                for(LocationOccupant__c objLocationOccupant : locationOccupantList){
                    if(!mapOfConsiderationStatusByLocationId.containsKey(objLocationOccupant.Location__c)){
                        if(mapOfConsiderationByAccountId.containsKey(objLocationOccupant.Account__c)){
                            mapOfConsiderationStatusByLocationId.put(objLocationOccupant.Location__c, mapOfConsiderationByAccountId.get(objLocationOccupant.Account__c));
                        }
                    }
                }
            }
        }
        system.debug('mapOfConsiderationStatusByLocationId==='+mapOfConsiderationStatusByLocationId);
        return mapOfConsiderationStatusByLocationId;            
    }
    /**********************************************************************************************
    @author        Echo: Dependra Singh
    @date          01-Nov-2018
    @param         SupplyPoint__c objSupplyPoint, 
                   Map<Id, Boolean> mapOfConsiderationStatusByLocationId
    @return        void
    @description   This method is used to update Allow Disconnection checkbox value
    @revision      AT-3303 - Dependra Singh
                   Removed all code and changed whole method.
    **********************************************************************************************/     
    private void setAllowDisconnectionFlag(SupplyPoint__c objSupplyPoint, Map<Id, Boolean> mapOfConsiderationStatusByLocationId) { 
        system.debug('objSupplyPoint==='+objSupplyPoint);
        if (objSupplyPoint.SupplyDisconnectionStatus__c == GlUt_Constants.SUPPLYDISCONNECTIONSTATUS){   
            if(objSupplyPoint.AllowDisconnection__c){
                if(objSupplyPoint.Location__c != null ){
                    if(mapOfConsiderationStatusByLocationId.containsKey(objSupplyPoint.Location__c)){
                        objSupplyPoint.AllowDisconnection__c = mapOfConsiderationStatusByLocationId.get(objSupplyPoint.Location__c);  
                    }
                }
            }
        }else{
            objSupplyPoint.AllowDisconnection__c = false;
        }
    }
    
   /**********************************************************************************************
    @author        Echo: Neha Rajput
    @date          25-Jan-2018
    @param         SupplyPoint__c objSupplyPoint
    @return        void
    @description   This method is used to update Allow Disconnection checkbox value
    @revision      AT-3303
                   AT-3911 (FR), AT-3912, Ankit Gangwani
                   Earlier the location has been identified with BillingContract__c.HouseholdBilling__c, 
                   now the location will be identified with BillingContract__c --> Service__c --> SupplyPoint__c --> Location__c
    **********************************************************************************************/           
    /*private void setAllowDisconnectionFlag(SupplyPoint__c objSupplyPoint,List<BillingContract__c> disconnectPermitAccList) { 
        objSupplyPoint.AllowDisconnection__c = false;        
        Set<Id> contractIdsSet = new Set<Id>();        
        // SUPPLYDISCONNECTIONSTATUS is 'Able to Disconnect' already available in GlUt_Constants by Ashish on 13-Dec-2017 
        //        
        if (objSupplyPoint.SupplyDisconnectionStatus__c == GlUt_Constants.SUPPLYDISCONNECTIONSTATUS){             
            for(BillingContract__c disconnectPermit : disconnectPermitAccList){
                contractIdsSet.add(disconnectPermit.Id);                
            }
            
            // AT-3911 (FR), AT-3912
            if(contractIdsSet != null && contractIdsSet.size() > 0){
                for(Service__c objService : [SELECT Id, BillingContract__c, SupplyPoint__r.Location__c FROM Service__c WHERE BillingContract__c IN :contractIdsSet]){
                    if(objService.SupplyPoint__r.Location__c == objSupplyPoint.Location__c){
                        objSupplyPoint.AllowDisconnection__c = true; 
                        break;
                    }                   
                }
            }
        }
    }*/
    
    /**********************************************************************************************
    @author        Echo: Neha Rajput
    @date          25-Jan-2018
    @param         
    @return        List<BillingContract__c>
    @description   Method to retrive all Disconnection Permitted accounts
    **********************************************************************************************/           
    /*private List<BillingContract__c> disconnectionPermitted() {  //-- AT-3303
        List<BillingContract__c> disconnectPermitList = [SELECT Id, AccountName__c FROM BillingContract__c 
                                                         WHERE AccountName__c IN (SELECT Account__c FROM Consideration__c WHERE Active__c = true 
                                                                                  AND ConsiderationType__r.DisconnectionPermitted__c = true)];       
        return disconnectPermitList;
    }   */
    
    /**********************************************************************************************
    @author        Echo: Neha Rajput
    @date          25-May-2018
    @param         
    @return        List<LocationOccupant__c>
    @description   WrapWalkOrder Wrapper class for walkorder details
    **********************************************************************************************/
    private WrapWalkOrder walkOrderDetails(Set<ID> booksId){
        
        WrapWalkOrder wrapperclass = new WrapWalkOrder();
        Map<Id, Integer> maxWalkOrdOnBookLocalMap = new Map<Id, Integer>();
        
        //Max walkorder on book.....
        Map<Id,AggregateResult> result = new Map<Id,AggregateResult>([SELECT Book__c Id, Max(WalkOrder__c) max 
                                                                      FROM SupplyPoint__c 
                                                                      WHERE Book__c IN: booksId GROUP BY Book__c]);
        for(Id objId : result.keySet()){            
            AggregateResult aggResults = result.get(objId); 
            
            // Map of max walk order on a book
            if (aggResults.get(GlUt_Constants.MAX) == null)    //if (aggResults.get('max') == null)
                maxWalkOrdOnBookLocalMap.put(objId, 0);
            else
                maxWalkOrdOnBookLocalMap.put(objId, Integer.valueOf(aggResults.get(GlUt_Constants.MAX)));
        }  
        
        //List of Walk Order on book and SupplyPoint
        Map<Id, List<Integer>> listOfWalkOrdOnBookLocalMap = new Map<Id, List<Integer>>();
        Map<Id, Integer> WalkOrdOnSPLocalMap = new Map<Id,Integer>();
        
        for(SupplyPoint__c objSupplypoint : [SELECT Book__c,WalkOrder__c 
                                             FROM SupplyPoint__c
                                             WHERE Book__c IN: booksId ]){ 
                                                 
                                                 WalkOrdOnSPLocalMap.put(objSupplypoint.Id,Integer.valueOf(objSupplypoint.WalkOrder__c)); 
                                                 
                                                 if(listOfWalkOrdOnBookLocalMap.containsKey(objSupplypoint.Book__c)){
                                                     List<Integer> walkOrdList = listOfWalkOrdOnBookLocalMap.get(objSupplypoint.Book__c);
                                                     walkOrdList.add(Integer.valueOf(objSupplypoint.WalkOrder__c));
                                                     listOfWalkOrdOnBookLocalMap.put(objSupplypoint.Book__c, walkOrdList);               
                                                 }else{
                                                     List<Integer> walkOrdList = new List<Integer>();
                                                     walkOrdList.add(Integer.valueOf(objSupplypoint.WalkOrder__c));
                                                     listOfWalkOrdOnBookLocalMap.put(objSupplypoint.Book__c, walkOrdList);
                                                 }                                  
                                             }  
        
        wrapperclass.maxWalkOrdOnBookMap = maxWalkOrdOnBookLocalMap.clone();
        wrapperclass.listOfWalkOrdOnBookMap = listOfWalkOrdOnBookLocalMap.clone();
        wrapperclass.WalkOrderOnSPMap = WalkOrdOnSPLocalMap.clone(); 
        
        return wrapperclass;       
    }
    
    /**********************************************************************************************
    @author        Echo: Neha Rajput
    @date          25-May-2018
    @param         
    @return        List<LocationOccupant__c>
    @description   WrapWalkOrder Wrapper class for walkorder details
    **********************************************************************************************/
    private class WrapWalkOrder{        
        private Map<Id, Integer> maxWalkOrdOnBookMap;
        private Map<Id, List<Integer>> listOfWalkOrdOnBookMap;
        private Map<Id, Integer> WalkOrderOnSPMap;        
    }
    /**********************************************************************************************
    @author        Echo: AmitK.
    @date          06-Aug-2018
    @param         List<SObject> newlist, Map<Id, SObject> oldMap 
    @return        
    @description   Allocate OutStanding Bill Item to Payment Allocation Queue when disputed S.P changes to Un-Disputed mode.
    **********************************************************************************************/ 
    private void allocateOutStandingBillItemToPaymentAllocQueue(List<SObject> newlist, Map<Id, SObject> oldMap) {
        Set<Id> spIds = new Set<Id>();
        for(SupplyPoint__c sp : (List<SupplyPoint__c>) newlist) {
            //Check if Supply Point is Disputed.
            if(sp.Disputed__c == false && sp.Disputed__c != ((SupplyPoint__c) oldMap.get(sp.Id)).Disputed__c) {
                spIds.add(sp.Id); // Assign Un-Disputed S.P Ids to set of S.P Ids.
            }
        }
        if(!spIds.isEmpty()){
            //Fetch Bill Item where OutStanding Amount > 0 for respective S.P's
            Map<Id,BillItem__c> mapOfBillItem = new Map<Id,BillItem__c>([select Id 
                                                                         from BillItem__c 
                                                                         where ServiceItem__r.Service__r.SupplyPoint__c In: spIds AND AmountOutstanding__c > 0]);
            if(mapOfBillItem != null && !mapOfBillItem.isEmpty()){
                //Fetch Payment Allocation Queue record where Status = New for respective Bill Items
                List<String> paymentAllocationQueueFields = new List<String>();
                paymentAllocationQueueFields.add(GlUt_APIConstantsPaymentAllocationQueue.BILLITEMAPINAME); 
                paymentAllocationQueueFields.add(GlUt_APIConstantsPaymentAllocationQueue.STATUSAPINAME); 
                string filterStatement = ' AND '+ GlUt_APIConstantsPaymentAllocationQueue.STATUSAPINAME +' != \'' +GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_PROCESSSED +'\' ';
                List<PaymentAllocationQueue__c> paymentAllocQueueList = GlUt_PaymentAllocationQueueUtilities.getPaymentAllocationQueueFromBillItem(mapOfBillItem.keySet(),filterStatement,paymentAllocationQueueFields);
                Set<Id> setOfBillItemIds = new Set<Id>();
                for(PaymentAllocationQueue__c payAllocQueue: paymentAllocQueueList){
                    setOfBillItemIds.add(payAllocQueue.BillItem__c); // Assign Payment Alloc Queue Bill Item having Status = New to Set of collection containg Bill item Ids.
                }
                List<PaymentAllocationQueue__c> newPaymentAllocationQueueList = new List<PaymentAllocationQueue__c>();
                for(Id billItemId : mapOfBillItem.keySet()){
                    //Check if bill Item doesn't exist having Payment Allocation Status = New.
                    if(!setOfBillItemIds.contains(billItemId)){
                        //Create New Payment Allocation Queue record with Status = New and Operation = Update.
                        PaymentAllocationQueue__c newPayAllocationQueue = GlUt_PaymentAllocationQueueUtilities.buildPaymentAllocationQueue(billItemId,GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_NEW,GlUt_Constants.PAYMENTALLOCATIONQUEUE_OPERATION_UPDATE);
                        newPaymentAllocationQueueList.add(newPayAllocationQueue);
                    }
                }
                // Insert newely Created Payment Allocation Queue records.
                if(!newPaymentAllocationQueueList.isEmpty()){
                    newPaymentAllocationQueueList = (List<PaymentAllocationQueue__c>) GlUt_FieldSecurity.cleanseFields(newPaymentAllocationQueueList, false);
                    insert newPaymentAllocationQueueList;
                }
            }
        }
    }
    
    /**********************************************************************************************
    @author        Echo: Neha R.
    @date          11-Dec-2018
    @param         List<SObject> newlist
    @return        
    @description   Validation for Rural Channel
    **********************************************************************************************/ 
    private void ruralChannel(List<SObject> newlist) {
        Set<Id> channelIdSet = new Set<Id>();
        for(SupplyPoint__c objSupplyPoint : (List<SupplyPoint__c>)newlist){           
            if(objSupplyPoint.RuralChannel__c != null) 
                channelIdSet.add(objSupplyPoint.RuralChannel__c);
        }
        Map<Id,RuralChannel__c> ruralChannelMap = new Map<Id,RuralChannel__c>();
        if(!channelIdSet.isEmpty()){          
            for(RuralChannel__c objRuralChannel : GlUt_RuralBillingUtilities.getRuralChannel(channelIdSet)){
                ruralChannelMap.put(objRuralChannel.Id, objRuralChannel);
            }
            if(!ruralChannelMap.isEmpty()){
                for(SupplyPoint__c objSupplyPoint : (List<SupplyPoint__c>)newlist){           
                    if(objSupplyPoint.RuralChannel__c != null){
                        // validate Rural Channel Type
                        List<String> validOutletTypelst = new List<String>();
                        if(ruralChannelMap.get(objSupplyPoint.RuralChannel__c).ValidOutletTypes__c != null){
                            validOutletTypelst = ruralChannelMap.get(objSupplyPoint.RuralChannel__c).ValidOutletTypes__c.split(';');
                            if(objSupplyPoint.RuralOutletType__c != null && !validOutletTypelst.contains(objSupplyPoint.RuralOutletType__c))
                                objSupplyPoint.addError(Label.GlUt_RuralOutletTypeError); //Rural Outlet Type not valid for this Channel’
                        }
                    }                        
                }
            }            
        }  
    }
}