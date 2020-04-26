/******************************************************************************
@author         Accenture: Patrick Dixon
@date           06 Nov 2017
@description    Handler for Bill Item trigger
@Revisions  	30-Apr-2018 Tarun , AT-2341 , To create BT records only when Bill Type is not Pending.
@Revisions 		11-Apr-2019 Tarun , AT-5554
*******************************************************************************/
public with sharing class GlUt_BillItemHandler extends GlUt_TriggerHandlerBase {
    
    private static final String CLASS_NAME = 'GlUt_BillItemHandler';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    // Maps of the related records that will be updated by this trigger
    Map<Id, Reading__c> readingsToUpdate;
    Map<Id, ManualAmendment__c> manualAmendmentsToUpdate;
    Map<Id, RuralGrossConsumption__c> ruralGrossConsumptionToUpdate;
    
    // List to insert top up readings
    List<Reading__c> topUpReadingsToCreate;

    // List to insert payment allocation queue records
    List<PaymentAllocationQueue__c> paymentAllocationQueueList; 
    
    //List to insert Balance Transaction records
    List<BalanceTransaction__c> balanceTransactionList;
    List<BalanceTransaction__c> balanceTransactionListToUpdate;
    
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           06 Nov 2017
    @param          GlUt_TriggerHandlerObj - inputParam
    @description    This method handles the initial invocation of the trigger
    *******************************************************************************/
    public override void mainEntry(GlUt_TriggerHandlerObj inputParam) {

        // initialise related records maps
        readingsToUpdate = new Map<Id, Reading__c>();
        ruralGrossConsumptionToUpdate =  new Map<Id, RuralGrossConsumption__c>();
        manualAmendmentsToUpdate = new Map<Id, ManualAmendment__c>();
        topUpReadingsToCreate = new List<Reading__c>();
        paymentAllocationQueueList = new List<PaymentAllocationQueue__c>(); 
        balanceTransactionList = new List<BalanceTransaction__c>();
        balanceTransactionListToUpdate = new List<BalanceTransaction__c>();
        
        try {
            
            // TO-DO Logger.Push('MainEntry', 'GlUt_AccountHandler');
            
            /* This is a Heroku mastered object so we shouldn't be modifying any fields on it */
            /* Therfore before Insert/Update triggers not required */
            
                
            if (inputParam.isInsert && inputParam.isAfter) {
                // create top-up readings               
                createTopUpReadings(inputParam.newmap);
                
                // mark related records as billed
                updateBilled(inputParam.newmap, true);
                
                // creates Payment Allocation Queue records
                createPaymentAllocationQueues(inputParam.newlist, null);
                
                // creates Balance Transaction records
                createBalanceTransactions(inputParam.newMap,inputParam.newlist);
                
                //call FinancialControlDispatcher to create Financial Control Record
                CallFinancialControlDispatcher(inputParam);
                
                // update  Bulk Write Off record
                updateBulkWriteOff(inputParam.newlist);  // AT-3704 
            }
            
            if (inputParam.isUpdate && inputParam.isAfter) {
                // mark related records as billed - added to update for top up readings where the reading relationship is added in a update
                updateBilled(inputParam.newmap, true);

                // updates Payment Allocation Queue records
                createPaymentAllocationQueues(inputParam.newlist, inputParam.oldmap);
            }
            
            if (inputParam.isDelete && inputParam.isBefore) {
            }
            
            if (inputParam.isDelete && inputParam.isAfter) {
                // mark related records as unbilled
                updateBilled(inputParam.oldmap, false);
            }
            
        } catch (exception e) {         
            GlUt_Logger.logException(e);
            GlUt_Logger.writeLogsToDatabase();
            
        }

        finally {
            
            // update the related records
            if (!readingsToUpdate.isEmpty()) {
                List<Reading__c> lstReadingsToUpdate = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(readingsToUpdate.values(), false);
                update lstReadingsToUpdate;
            }
            if(!ruralGrossConsumptionToUpdate.isEmpty()){
                List<RuralGrossConsumption__c> lstRuralGrossConsumptionToUpdate = (List<RuralGrossConsumption__c>) GlUt_FieldSecurity.cleanseFields(ruralGrossConsumptionToUpdate.values(), false);
                update lstRuralGrossConsumptionToUpdate;
            }
            // update the related manual amendment records
            if (!manualAmendmentsToUpdate.isEmpty()) {
                List<ManualAmendment__c> lstManualAmendmentsToUpdate = (List<ManualAmendment__c>) GlUt_FieldSecurity.cleanseFields(manualAmendmentsToUpdate.values(), false);
                update lstManualAmendmentsToUpdate;
            }
            
            // insert the top up reading records
            if (!topUpReadingsToCreate.isEmpty()) {      
                topUpReadingsToCreate = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(topUpReadingsToCreate, false);
                insert topUpReadingsToCreate;              
            }
            
            // insert the related payment allocation queue records
            if (!paymentAllocationQueueList.isEmpty()) {
                paymentAllocationQueueList = (List<PaymentAllocationQueue__c>) GlUt_FieldSecurity.cleanseFields(paymentAllocationQueueList, false);
                insert paymentAllocationQueueList;
            }
            
            // insert the related payment allocation queue records
            if (!balanceTransactionList.isEmpty()) {
                balanceTransactionList = (List<BalanceTransaction__c>) GlUt_FieldSecurity.cleanseFields(balanceTransactionList, false);
                insert balanceTransactionList;
            }
            
            // update the related BT records
            if (!balanceTransactionListToUpdate.isEmpty()) {
                balanceTransactionListToUpdate = (List<BalanceTransaction__c>) GlUt_FieldSecurity.cleanseFields(balanceTransactionListToUpdate, false);
                update balanceTransactionListToUpdate;
            }
            
            // Reset the active function to null in case this class was first in stack
            // this indicates that the trigger has finished firing so it no longer needs to control flow
            GlUt_CentralDispatcher.activeFunction = null;
            
        }
    }
    
    /******************************************************************************
    @author         Echo: Patrick Dixon
    @date           07 Feb 2018
    @description    creates top up readings from fields returned by Heroku in the bill item
    *******************************************************************************/
    public void createTopUpReadings(Map<Id, SObject> objectMap) {
                
        Map<String, BillItem__c> newReadingMap = new Map<String, BillItem__c>();        // map of bill items keyed on the top up UUID
        Set<Id> deviceIds = new Set<Id>();
        
        for (BillItem__c billItem : (List<BillItem__c>) objectMap.values()) {
            // build a map of the billItems keyed on the TopUpId to de-duplicate the new readings
            if (billItem.TopUpId__c != null) {
                newReadingMap.put(billItem.TopUpId__c, billItem);
            }
           
            // build a set of the device Ids involved
            if (billItem.TopUpDeviceId__c != null) {
                deviceIds.add(billItem.TopUpDeviceId__c);
            }
        }
                
        // build a map of the devices
        Map<Id, Device__c> deviceMap = new Map<Id, Device__c>();        // map of devices keyed on their Id
       
        if(deviceIds != Null && !deviceIds.isEmpty()){
            for (Device__c device : [select Id, 
                                     Digit__c, 
                                     DeviceType__r.UnitOfMeasure__c, 
                                     DeviceType__r.Multiplier__c 
                                     from Device__c
                                     where Id in :deviceIds]) {
                                         
                                         deviceMap.put(device.Id, device);   
                                     }
        }
               
        // check to see if any of the new readings already exist
        if(newReadingMap.keySet() != Null && !newReadingMap.keySet().isEmpty())
            for (Reading__c reading : [select Id 
                                       from Reading__c
                                       where TopUpId__c in :newReadingMap.keySet()]) {
                                           
                                           // and remove them from the map
                                           newReadingMap.remove(reading.TopUpId__c);
                                       }
                
        // create the new top up readings from the map
        for (BillItem__c billItem : newReadingMap.values()) {
            
            // calculate an 'actual' device reading value that is the reverse of the Reading__c formula field
            Device__c device = deviceMap.get(billItem.TopUpDeviceId__c);
            Decimal reversedDeviceReading = device.DeviceType__r.UnitOfMeasure__c == System.Label.CuAp_DeviceTypeUnitOfMeasureImperialUKGallons  
                                        ? (billItem.TopUpValue__c * (1000 * 0.22)) / device.DeviceType__r.Multiplier__c 
                                        : billItem.TopUpValue__c / device.DeviceType__r.Multiplier__c;
                            
            // convert to it to a string and ensure the string length matches the meter digits validation rule by prefixing it with '0's            
            String actualDeviceReading = String.valueOf(Integer.valueOf(reversedDeviceReading));
            
            //AT-3424 core 8b start...          
            String maxDeviceReading = '';
            Boolean tripped = false;
            for(Integer i=0; i<device.Digit__c; i++){
            	maxDeviceReading = maxDeviceReading + '9';		    
            }  
           
            if(Decimal.valueOf(maxDeviceReading) < Decimal.valueOf(actualDeviceReading)){                
                //Top-up Reading from Heroku  Maximum Possible Reading on the Device)
                actualDeviceReading = String.valueOf(Integer.valueOf((billItem.TopUpValue__c - Decimal.valueOf(maxDeviceReading)).setScale(2)));                                  
                tripped = true;
            }           
            //AT-3424 core 8b end...
            
            while (device.Digit__c > actualDeviceReading.length()) {
                actualDeviceReading = '0' + actualDeviceReading;
            }
       
            if (!String.isBlank(billItem.TopUpId__c)) {
                topUpReadingsToCreate.add(new Reading__c(
                                                        TopUpId__c = billItem.TopUpId__c, 
                                                        Device__c = billItem.TopUpDeviceId__c, 
                                                        TopUpReading__c = billItem.TopUpValue__c, 
                                                        ActualDeviceReading__c = actualDeviceReading, 
                                                        ReadingDate__c = billItem.TopUpDate__c, 
                                                        ReadingMethod__c = System.Label.CuAp_ReadingReadingMethodTopUp, 
                                                        ReadingType__c = System.Label.CuAp_ReadingReadingTypeRegular, 
                                                        ReadingSource__c = System.Label.CuAp_ReadingReadingSourceSystem, 
                                                        BillableType__c = System.Label.CuAp_ReadingBillableTypeBillable, 
                                                        Billed__c = true,
                    									Tripped__c = tripped   //AT-3424 core 8b
                                                    ));
            }            
        }
    }

    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           06 Nov 2017
    @param          Map<Id, SObject> - objectMap
    @param          Boolean - isBilled
    @description    Marks/unmarks the related records as 'Billed' when Bill Items 
                    are inserted/deleted
	@revision		Echo: Sudhir Kumar
					AT-5110/ AT-3489: "All Services Billed" logic update for SiteSupply
    *******************************************************************************/
    public void updateBilled(Map<Id, SObject> objectMap, Boolean isBilled) {
        system.debug('objectMap -- '+ objectMap);
            
        Set<Id> readingIdsToUpdate = new Set<Id>();       // list of billed reading Ids
        List<Id> manualAmendmentIdsToUpdate = new List<Id>();       // list of billed manual amendment Ids
        Map<Id,Id> allServicesNotBilledReadingId = new Map<Id,Id>();  // AT-3850 new changes 
        Set<Id> ruralGrossConsumptionIdsToUpdate = new Set<Id>();       // Set of billed rural Gross Consumption Ids
        // Start: AT-5110
        map<Id, Id> mapBillItemId2SiteSupplyId = new map<Id, Id>() ;
        map<Id, set<Id>> mapSiteSupplyPointId2SetSupplyPointIds = new map<Id, set<Id>>() ;
        // End: AT-5110
                
        // UT-430... Start 
        Set<Id> billIdSet = new Set<Id>();
        for(BillItem__c billItem : (List<BillItem__c>) objectMap.values()) {
           billIdSet.add(billItem.Bill__c);           
        }        
        Map<Id,Bill__c> billIdWithBillMap = new Map<Id,bill__c>(); 
        for(Bill__c objBill: [SELECT Id , BillType__c FROM Bill__c WHERE Id IN: billIdSet]){
           	billIdWithBillMap.put(objBill.Id, objBill);
        }
        // UT-430 End...
        
         system.debug('102........billIdWithBillMap ' + billIdWithBillMap);
        
        // get the billed reading records
        for (BillItem__c billItem : (List<BillItem__c>) objectMap.values()) {
            if(billIdWithBillMap.containsKey(billItem.Bill__c)	&& billIdWithBillMap.get(billItem.Bill__c).BillType__c	!= GlUt_Constants.HELDBILLTYPE)   //UT-430
             	readingIdsToUpdate.add(billItem.Reading__c);
            
            if(billItem.RuralGrossConsumption__c != null) {
                ruralGrossConsumptionIdsToUpdate.add(billItem.RuralGrossConsumption__c);  
            }
            if(billItem.ManualAmendment__c != null) {
            	manualAmendmentIdsToUpdate.add(billItem.ManualAmendment__c);
            }
            if(billItem.SiteSupply__c != null) { // AT-5110
                mapBillItemId2SiteSupplyId.put(billItem.Id, billItem.SiteSupply__c) ;
            }
        }
        // Start: AT-5110
        system.debug('readingIdsToUpdate=> ' + readingIdsToUpdate) ;
        system.debug('mapBillItemId2SiteSupplyId=> ' + mapBillItemId2SiteSupplyId) ;
        set<Id> setSiteSupplyPointIds = new set<Id>() ;
        if(!mapBillItemId2SiteSupplyId.isEmpty()) {
            set<Id> setSiteSupplyIds = new set<Id>() ; 
            setSiteSupplyIds.addAll(mapBillItemId2SiteSupplyId.values()) ;
            system.debug('setSiteSupplyIds=> ' + setSiteSupplyIds) ;
            list<SiteSupply__c> listSiteSupply = [SELECT Id, SupplyPoint__c, SiteSupplyPoint__c FROM SiteSupply__c WHERE Id IN: setSiteSupplyIds] ;
            system.debug('listSiteSupply=> ' + listSiteSupply) ;   
            
            for(SiteSupply__c objSiteSupply : listSiteSupply) {
                setSiteSupplyPointIds.add(objSiteSupply.SiteSupplyPoint__c) ;
            }
            
            if(!setSiteSupplyPointIds.isEmpty()) {
                list<SiteSupply__c> listSiteSupplyOnMainSupply = [SELECT Id, SupplyPoint__c, SiteSupplyPoint__c FROM SiteSupply__c WHERE SiteSupplyPoint__c IN: setSiteSupplyPointIds
                                                                  AND AmendedBySiteSupply__c = null AND (EndDate__c = null OR EndDate__c > TODAY)] ;
                system.debug('listSiteSupplyOnMainSupply=> ' + listSiteSupplyOnMainSupply) ;
                for(SiteSupply__c objSiteSupply : listSiteSupplyOnMainSupply) {
                    if(!mapSiteSupplyPointId2SetSupplyPointIds.containsKey(objSiteSupply.SiteSupplyPoint__c)) {
                        mapSiteSupplyPointId2SetSupplyPointIds.put(objSiteSupply.SiteSupplyPoint__c, new set<Id> {objSiteSupply.SupplyPoint__c}) ;
                    } else {
                        mapSiteSupplyPointId2SetSupplyPointIds.get(objSiteSupply.SiteSupplyPoint__c).add(objSiteSupply.SupplyPoint__c) ;
                    } 
                }
            }
            system.debug('mapSiteSupplyPointId2SetSupplyPointIds=> ' + mapSiteSupplyPointId2SetSupplyPointIds) ;
        }
        // End: AT-5110
        if(!ruralGrossConsumptionIdsToUpdate.isEmpty()) {
            for(RuralGrossConsumption__c ruralGrossConsumption : [Select Id,
                                                                  Billed__c
                                                                  from RuralGrossConsumption__c where Id In: ruralGrossConsumptionIdsToUpdate]){
                                                                      ruralGrossConsumption.Billed__c = isBilled;
                                                                      ruralGrossConsumptionToUpdate.put(ruralGrossConsumption.Id,ruralGrossConsumption); 
                                                                  }
        }
        // Find all the services of the supply point AT-3850
        // New changes... Neha...        
        Map<Id,List<Reading__c>> deviceReadingListMap = new Map<Id,List<Reading__c>>();
        List<Id> deviceIdsList = new List<Id>();  
        if(!readingIdsToUpdate.isEmpty()) {
            for(Reading__c objReading : [SELECT Id,Device__c,ReadingDate__c
                                         FROM Reading__c
                                         WHERE Id IN: readingIdsToUpdate]){ 
                                             
                                             if(!deviceReadingListMap.containsKey(objReading.Device__c)){  
                                                 deviceReadingListMap.put(objReading.Device__c,new List<Reading__c>());
                                             }   
                                             deviceReadingListMap.get(objReading.Device__c).add(objReading);                             
                                         }
        }
        system.debug('deviceReadingListMap=> ' + deviceReadingListMap);
        Map<Id,List<Reading__c>> spReadingListMap = new Map<Id,List<Reading__c>>();
        if(deviceReadingListMap.keyset().size() > 0){
            for(SupplyPointDevice__c  objSPD: [SELECT Id, SupplyPoint__c,Device__c 
                                               FROM SupplyPointDevice__c
                                               WHERE Active__c = True
                                               AND Device__c IN: deviceReadingListMap.keySet()]){
                                                   if(deviceReadingListMap.containsKey(objSPD.Device__c)){
                                                       spReadingListMap.put(objSPD.SupplyPoint__c, deviceReadingListMap.get(objSPD.Device__c));
                                                       //if Main Supply Points exist in the Site Supply map
                                                       system.debug('mapSiteSupplyPointId2SetSupplyPointIds2=> ' + mapSiteSupplyPointId2SetSupplyPointIds);
                                                       if(mapSiteSupplyPointId2SetSupplyPointIds.containsKey(objSPD.SupplyPoint__c) && mapSiteSupplyPointId2SetSupplyPointIds.get(objSPD.SupplyPoint__c) != null) {
                                                           for(Id customerSupplyPointId : mapSiteSupplyPointId2SetSupplyPointIds.get(objSPD.SupplyPoint__c)) {
                                                               //the related Site Supply Points will have same reading as the one on the Supply Point device
                                                               spReadingListMap.put(customerSupplyPointId, deviceReadingListMap.get(objSPD.Device__c));
                                                           }    
                                                       }
                                                   }                                 
                                               }
        }  
        // Start: AT-5110
        system.debug('spReadingListMap=> ' + spReadingListMap);
        Map<Id, Reading__c> serviceItemReadingIdMap = new Map<Id, Reading__c>();
        Map<Id, List<ServiceItem__c>> supplyPointSIMap = new Map<Id, List<ServiceItem__c>>();
        if(spReadingListMap.keyset().size() > 0) {
            for(Service__c objService: [SELECT Id,SupplyPoint__c,
                                        (SELECT Id,StartDate__c,EndDate__c FROM ServiceItems__r WHERE AmendedByServiceItem__c = null)
                                        FROM Service__c 
                                        WHERE SupplyPoint__c IN: spReadingListMap.keySet()]) {
                                            if(spReadingListMap.containsKey(objService.SupplyPoint__c)){
                                                system.debug('Sudhir-objService=> ' + objService);
                                                for(ServiceItem__c objServiceItem: objService.ServiceItems__r){
                                                    for(Reading__c objReading : spReadingListMap.get(objService.SupplyPoint__c)){
                                                        system.debug('Sudhir-objReading=> ' + objReading);
                                                        system.debug('Sudhir-objServiceItem=> ' + objServiceItem);
                                                        if(objServiceItem.StartDate__c <= objReading.ReadingDate__c && (objServiceItem.EndDate__c == null || objReading.ReadingDate__c <= objServiceItem.EndDate__c)) {
                                                            serviceItemReadingIdMap.put(objServiceItem.Id,objReading);
                                                            if(!supplyPointSIMap.containsKey(objService.SupplyPoint__c)){
                                                                supplyPointSIMap.put(objService.SupplyPoint__c, new List<ServiceItem__c>());	        
                                                            }
                                                            supplyPointSIMap.get(objService.SupplyPoint__c).add(objServiceItem);
                                                        }
                                                    }
                                                }	                                
                                            }                           
                                        }
        }
        system.debug('supplyPointSIMap=> ' + supplyPointSIMap);
        Map<Id,List<Id>> readingToSIMap = new Map<Id,List<Id>>();
        if(!readingIdsToUpdate.isEmpty()) {
            for(BillItem__c bItem : [SELECT Id, Reading__c, ServiceItem__c,ServiceItem__r.Service__r.SupplyPoint__c,EndDate__c                                      
                                     FROM BillItem__c 
                                     WHERE Reading__c IN: readingIdsToUpdate]) {
                                         if(!readingToSIMap.containsKey(bItem.Reading__c)){
                                             readingToSIMap.put(bItem.Reading__c,new List<Id>());
                                         }
                                         readingToSIMap.get(bItem.Reading__c).add(bItem.ServiceItem__c);
                                     }
        }
		system.debug('readingToSIMap=> ' + readingToSIMap);
        for(Id spId : supplyPointSIMap.keySet()){
            for(ServiceItem__c sItem : supplyPointSIMap.get(spId)){
            	for(Reading__c spReading : spReadingListMap.get(spId)){
                    Boolean siFound = false;
                	for(Id serviceItemId : readingToSIMap.get(spReading.Id)){
                        if(sItem.Id == serviceItemId){
                        	siFound = true;
                            break;
                        }
                    }
                    if(!siFound){
                    	allServicesNotBilledReadingId.put(spReading.Id,spReading.Id);    
                    }
            	} 
        	}
            
        }
        system.debug('allServicesNotBilledReadingId=> ' + allServicesNotBilledReadingId);
        // end New changes
        // for each related reading
        if(readingIdsToUpdate.size() > 0) {
            for (Reading__c reading : [select Id, 
                                       Billed__c,
                                       AllServicesBilled__c
                                       from Reading__c
                                       where Id in :readingIdsToUpdate]) {
            
                // mark the reading as billed/unbilled
                reading.Billed__c = isBilled;

                //AT-3850               
                //if(!allServicesNotBilledReadingId.isEmpty() && !allServicesNotBilledReadingId.containsKey(reading.Id) && isBilled){	//AT-3489
                if(!allServicesNotBilledReadingId.containsKey(reading.Id) && isBilled){
               		reading.AllServicesBilled__c = true;
                }
                                           
                // and add it to the update map
                readingsToUpdate.put(reading.Id, reading);
            }
        }
        system.debug('readingsToUpdate2=> ' + readingsToUpdate);
        // for each related manual amendment
        if(manualAmendmentIdsToUpdate.size() > 0){
            for (ManualAmendment__c manualAmendment : [select Id, 
                                                       Billed__c
                                                       from ManualAmendment__c
                                                       where Id in :manualAmendmentIdsToUpdate]) {
                // mark the manual amendment as billed
                manualAmendment.Billed__c = isBilled;
                
                // and add it to the update map
                manualAmendmentsToUpdate.put(manualAmendment.Id, manualAmendment);
            }
        }
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar
    @date           16 Jan 2018
    @param          List<SObject> newlist - trigger.new
    @param          Map<Id, SObject> oldMap - trigger.oldMap
    @description    Inserts/Updates the related Payment Allocation Queue records 
                    when Bill Items are inserted/updated
    *******************************************************************************/
    private void createPaymentAllocationQueues(List<SObject> newlist, Map<Id, SObject> oldMap) {
        Boolean isInsert = oldmap == null;
        //List<PaymentAllocationQueue__c> paymentAllocationQueueList = new List<PaymentAllocationQueue__c>(); 
        Set<Id> billItemIdSet = new Set<Id>();
        for(BillItem__c billItem : (List<BillItem__c>) newlist) {
            if(isInsert) {
                paymentAllocationQueueList.add(buildPaymentAllocationQueue(billItem.Id, GlUt_Constants.PAYMENTALLOCATIONQUEUE_OPERATION_INSERT));
            } //else {// if(billItem.Status__c == 'Processed') { // check if we have any particular field that will be updated?
            //   billItemIdSet.add(billItem.Id);
            //}
            // CONFIRM: IF WE NEED TO PERFORM THIS ON UPDATE. IF YES, THEN CHECK THE CRITERIA
        }
        
        buildPaymentAllocationQueueList(paymentAllocationQueueList, billItemIdSet, newlist, isInsert);
    }
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar
    @date           16 Jan 2018
    @param          List<PaymentAllocationQueue__c> paymentAllocationQueueList,
                    Set<Id> billItemIdSet,
                    List<SObject> newlist,
                    Boolean isInsert
    @description    builds Payment Allocation Queue list for insertion
    *******************************************************************************/
    private void buildPaymentAllocationQueueList(List<PaymentAllocationQueue__c> paymentAllocationQueueList,
                                                          Set<Id> billItemIdSet,
                                                          List<SObject> newlist,
                                                          Boolean isInsert) {
        system.debug('SK-paymentAllocationQueueList= ' + paymentAllocationQueueList);
        system.debug('SK-billItemIdSet= ' + billItemIdSet);
        system.debug('SK-newlist= ' + newlist);
        system.debug('SK-isInsert= ' + isInsert);
		if(!billItemIdSet.isEmpty()) {
			List<PaymentAllocationQueue__c> existingPaymentAllocationQueueList = [SELECT Id, BillItem__c, Status__c, Operation__c
                                                                                 FROM PaymentAllocationQueue__c
                                                                                 WHERE BillItem__c IN :billItemIdSet
                                                                                 AND Status__c = :GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_PROCESSSED];
            system.debug('SK-existingPaymentAllocationQueueList= ' + existingPaymentAllocationQueueList);
			Map<Id, PaymentAllocationQueue__c> billItemIdToPaymentAllcMap = new Map<Id, PaymentAllocationQueue__c>();                                              
			for(PaymentAllocationQueue__c existingPaymentAllocationQueue : existingPaymentAllocationQueueList) {
				if(billItemIdToPaymentAllcMap.keySet().isEmpty() || !billItemIdToPaymentAllcMap.containsKey(existingPaymentAllocationQueue.BillItem__c)) {
					billItemIdToPaymentAllcMap.put(existingPaymentAllocationQueue.BillItem__c, existingPaymentAllocationQueue);
				}
			}
            system.debug('SK-billItemIdToPaymentAllcMap= ' + billItemIdToPaymentAllcMap);
			for(BillItem__c billItem : (List<BillItem__c>) newlist) {
				if(!isInsert && (billItemIdToPaymentAllcMap.keySet().isEmpty() || !billItemIdToPaymentAllcMap.containsKey(billItem.Id))) {
                	paymentAllocationQueueList.add(buildPaymentAllocationQueue(billItem.Id, GlUt_Constants.PAYMENTALLOCATIONQUEUE_OPERATION_INSERT));
            	}
        	}
    		system.debug('SK-paymentAllocationQueueList= ' + paymentAllocationQueueList);
		}
	}
    
    /******************************************************************************
    @author         Accenture: Pratyush Kumar
    @date           16 Jan 2018
    @param          Id billItemId, String operation
    @description    builds Payment Allocation Queue object for insertion
    *******************************************************************************/
    private PaymentAllocationQueue__c buildPaymentAllocationQueue(Id billItemId, String operation) {
        PaymentAllocationQueue__c paymentAllocationQueue = new PaymentAllocationQueue__c();
        paymentAllocationQueue.BillItem__c = billItemId; // need to also check scenario when there's bill item amendments?
        paymentAllocationQueue.Status__c = GlUt_Constants.PAYMENTALLOCATIONQUEUE_STATUS_NEW;
        paymentAllocationQueue.Operation__c = operation; // Need to check if it will always be 'Insert'
        
        return paymentAllocationQueue;
    } 
    
    /******************************************************************************
    @author         Andy Edge
    @date           13 Feb 2018
    @param          List<sObject> newList
    @description    builds Balance Transaction object for insertion, after new Bill_Item__c object inserted
    Revisions		30-Apr-2018 Tarun , AT-2341 , To create BT records only when Bill Type is not Pending.
    				04 Jul 2018, P Dixon - changed to create different balance transaction record types for Pending/Normal bills
					26 Oct 2018, Dependra Singh Changed code if bill type is "Transfer" then BT record type will be "Bill Transfer" and if type is 
					"Normal" then BT record type will be "Bill"
    *******************************************************************************/
    private void createBalanceTransactions(Map<Id, SObject> objectMap, List<SObject> newlist) {
        
        Id billRecordTypeId = Schema.SObjectType.BalanceTransaction__c.getRecordTypeInfosByName().get(GlUt_Constants.BALANCE_TYPE_BILL).getRecordTypeId();
        Id pendingBillRecordTypeId = Schema.SObjectType.BalanceTransaction__c.getRecordTypeInfosByName().get(GlUt_Constants.BALANCE_TYPE_PENDING_BILL).getRecordTypeId();
        Id transferBillCalcRecordTypeId = Schema.SObjectType.BalanceTransaction__c.getRecordTypeInfosByName().get(GlUt_Constants.BALANCE_TYPE_TRANSFER_BILL).getRecordTypeId();
        Map<Id,Decimal> mapBillId2BillAmount = new Map<Id,Decimal>();
        Map<Id,BalanceTransaction__c> mapBillId2BalanceTransaction = new Map<Id,BalanceTransaction__c>();
        Map<Id,String> mapBillId2BillType = new Map<Id,String>();
        Map<Id,Id> mapBillId2BalanceId = new Map<Id,Id>();
        List<BalanceTransaction__c> listBalanceTransaction = new List<BalanceTransaction__c>(); 
        Map<Id,Boolean> mapBillId2LatestPendingBill = new Map<Id,Boolean>();
        Set<Id> setBillIds = new Set<Id>();        
        for (BillItem__c billItem : [SELECT Id, 
                                     		Bill__c,
											Bill__r.BillType__c, 
											Bill__r.LatestPendingBill__c, 
											NetBilledAmount__c, 
											Bill__r.BillingContract__r.Balance__c 
                                       FROM BillItem__c 
                                       WHERE Id IN :objectMap.keySet()
                                       AND Bill__c != null]) {	
                                           
			setBillIds.add(billItem.Bill__c);
                                           
            if(!mapBillId2BillAmount.containsKey(billItem.Bill__c)){
                    mapBillId2BillAmount.put(billItem.Bill__c,billItem.NetBilledAmount__c);
            }                                           
			else{
                Decimal newAmt = 0.0;
                newAmt = mapBillId2BillAmount.get(billItem.Bill__c);
                newAmt += billItem.NetBilledAmount__c;
                mapBillId2BillAmount.put(billItem.Bill__c,newAmt);
			}  
                                           
			if(!mapBillId2BillType.containsKey(billItem.Bill__c)){
				mapBillId2BillType.put(billItem.Bill__c,billItem.Bill__r.BillType__c);                   
			} 
                                           
			if(!mapBillId2BalanceId.containsKey(billItem.Bill__c)){
                mapBillId2BalanceId.put(billItem.Bill__c,billitem.Bill__r.BillingContract__r.Balance__c);
			}
                                           
			if(!mapBillId2LatestPendingBill.containsKey(billItem.Bill__c)){
				mapBillId2LatestPendingBill.put(billItem.Bill__c,billItem.Bill__r.LatestPendingBill__c);                   
			}                           
        }
        if(setBillIds.size() > 0){
            
            listBalanceTransaction = [SELECT Id,Bill__c,BillAmount__c 
                                      FROM BalanceTransaction__c 
                                      WHERE Bill__c IN: setBillIds
                                      AND (RecordTypeId =: billRecordTypeId OR RecordTypeId =: pendingBillRecordTypeId)];
        }
        if(!listBalanceTransaction.isEmpty()){
            
            for(BalanceTransaction__c objBalanceTrans : listBalanceTransaction){
                
                if(!mapBillId2BalanceTransaction.containsKey(objBalanceTrans.Bill__c)){
                    mapBillId2BalanceTransaction.put(objBalanceTrans.Bill__c,objBalanceTrans);
                }                
            }
        }
        if(mapBillId2BillAmount.keyset().size() > 0){
            for(Id objId : mapBillId2BillAmount.keyset()){
                // Balance Transaction Already exist
                if(mapBillId2BalanceTransaction.keyset().size() > 0 && mapBillId2BalanceTransaction.containsKey(objId)){
                    
                    BalanceTransaction__c objBalanceTrans = new BalanceTransaction__c();
                    objBalanceTrans = mapBillId2BalanceTransaction.get(objId);
                    objBalanceTrans.BillAmount__c += mapBillId2BillAmount.get(objId);
                    balanceTransactionListToUpdate.add(objBalanceTrans);
                }
                // Create new Balance Transaction
                else{
                    if(mapBillId2BillType.keyset().size() > 0 && mapBillId2BillType.containsKey(objId)){
                        // 'Standard'
                        if(mapBillId2BillType.get(objId) != System.Label.BlIn_BillTypePending){
                            // Chnaged By Dependra Singh - AT-4054
                            // If the Bill Type is ‘Normal’ the Balance Transaction should have a record type of ‘Bill’ 
                            // If the Bill Type is ‘Transfer’ the Balance Transaction should have a record type of ‘Bill Transfer’
                            balanceTransactionList.add(new BalanceTransaction__c(
                                Bill__c = objId,
                                Balance__c = mapBillId2BalanceId.get(objId),
                                RecordTypeId = mapBillId2BillType.get(objId) == System.Label.GlUt_Transfer ? transferBillCalcRecordTypeId :billRecordTypeId,
                                BillAmount__c = mapBillId2BillAmount.get(objId), 
                                CurrentPendingBill__c = false));
                        }
                        else {
                            balanceTransactionList.add(new BalanceTransaction__c(
                                Bill__c = objId,
                                Balance__c = mapBillId2BalanceId.get(objId),
                                RecordTypeId = pendingBillRecordTypeId,
                                PendingBillAmount__c = mapBillId2BillAmount.get(objId), 
                                CurrentPendingBill__c = mapBillId2LatestPendingBill.get(objId)
                            ));
                        }
                    } 
                }
            }
        }
        system.debug('balanceTransactionList==='+balanceTransactionList);  
    }
    
	/******************************************************************************
    @author         Neha Rajput
    @date           18 Sep 2018
    @param          List<BillItem__c> newList
    @description    builds to update BulkWrite Off Record status where Bill Item is 
					associated with a Bulk Write Off record  (AT-3704 )
    Revisions		
    *******************************************************************************/
    private void updateBulkWriteOff(List<BillItem__c> newlist) {
        
        List<BillWriteOff__c> billWriteOffList = new List<BillWriteOff__c>();
        List<Id> billWriteOffRecordList = new List<Id>();
        
        for(BillItem__c objBillItem: newlist){
            if(objBillItem.BillWriteOff__c != null)
           		billWriteOffRecordList.add(objBillItem.BillWriteOff__c);
        }        
        if(billWriteOffRecordList.size() > 0){
            // Update BillWriteOff Record Status to 'Error' where Heroku Bill Calculation Status is associated with a Bulk Write Off record
            for(BillWriteOff__c objBillWriteOff: [SELECT Id,Status__c FROM BillWriteOff__c WHERE Id IN: billWriteOffRecordList ]){
                objBillWriteOff.Status__c = GlUt_Constants.PROCESSED;
                billWriteOffList.add(objBillWriteOff);
            }
            
            if(billWriteOffList.size() > 0){
                billWriteOffList = (List<BillWriteOff__c>) GlUt_FieldSecurity.cleanseFields(billWriteOffList, false);                
                database.update(billWriteOffList);
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           20 mar 2018
    @param          GlUt_TriggerHandlerObj inputParam
    @description    Call financial control dispatcher
    *******************************************************************************/
    public void CallFinancialControlDispatcher(GlUt_TriggerHandlerObj inputParam) {
        FcUt_CentralDispatcher.Main(inputParam);
    }        
}