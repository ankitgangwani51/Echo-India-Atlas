/******************************************************************************
@author         Echo: Tarun Gupta
@date           22 mar 2018
@description    Business logic for Financial Control total 
*******************************************************************************/
public with sharing class GlUt_FinancialControlTotalLogic {
    
    private static final List < String > financialCtrlTotalFieldList = new List <String> {
        	GlUt_APIConstantsFinancialControlTotal.EFFECTIVEACTUALAPINAME,
            GlUt_APIConstantsFinancialControlTotal.DAILYRECORDAPINAME,    
            GlUt_APIConstantsFinancialControlTotal.BILLINGFREQUENCYAPINAME,   
            GlUt_APIConstantsFinancialControlTotal.SERVICEITEMTYPEAPINAME,   
            GlUt_APIConstantsFinancialControlTotal.FINANCIALTRANSEVENTAPINAME,   
            GlUt_APIConstantsFinancialControlTotal.PERIODIDAPINAME,   
            GlUt_APIConstantsFinancialControlTotal.FINANCIALYEARAPINAME,   
            GlUt_APIConstantsFinancialControlTotal.FINANCIALPERIODAPINAME,   
            GlUt_APIConstantsFinancialControlTotal.TOTALAMOUNTAPINAME,   
            GlUt_APIConstantsFinancialControlTotal.TOTALDISCOUNTAPINAME,   
            GlUt_APIConstantsFinancialControlTotal.TOTALTAXAPINAME   
            };
                
    public static void FinancialTotalEffective(List<SObject> lstFinControl){
        
        system.debug('lstFinControl---'+ lstFinControl);
                    
        List<FinancialControlTotal__c> lstFinControlTotalToAdd = new List<FinancialControlTotal__c>();
        List<FinancialControlTotal__c> lstFinControlTotalUpUpd = new List<FinancialControlTotal__c>();
        List<FinancialControlTotal__c> lstFinControlTotal = new List<FinancialControlTotal__c>();
        
        Set<Id> setServiceItemTypeId = new Set<Id>();
        Set<Id> setFinTransEventTypeId = new Set<Id>();
        Set<String> setPeriodId = new Set<String>();
        
        Map<String,List<FinancialControlTotal__c>> mapFCT = new Map<String,List<FinancialControlTotal__c>>();
        
        String sOQLQuery = '';
        
        Map<Id,Id> mapFinCtrl = new Map<Id,Id>();	
        
        Map<String ,List<FinancialControlTotal__c>> mapFinCtrlTotalLst = new Map<String,List<FinancialControlTotal__c>>();	
        
        Map<String ,List<FinancialControl__c>> mapFinCtrlLst = new Map<String,List<FinancialControl__c>>();	
        
        if(!lstFinControl.isEmpty()){
            
            system.debug('Not emptyy');
            
            for(FinancialControl__c objFinCtrl : (List<FinancialControl__c>)lstFinControl){	
                
                String mapFCId = objFinCtrl.ServiceItemType__c + '-' + objFinCtrl.FinancialTransactionEventType__c + '-' + objFinCtrl.Period_Id__c;
                
                system.debug('mapFCId--'+ mapFCId);
                
                setServiceItemTypeId.add(objFinCtrl.ServiceItemType__c);
                setFinTransEventTypeId.add(objFinCtrl.FinancialTransactionEventType__c);
                setPeriodId.add(objFinCtrl.Period_Id__c);
                
                system.debug('after set creation');
                
                if(!mapFinCtrlLst.containsKey(mapFCId)){
                    system.debug('Adding to map');
                    
                    mapFinCtrlLst.put(mapFCId, new List<FinancialControl__c>());
                }
                
                system.debug('Adding to map list');
                mapFinCtrlLst.get(mapFCId).add(objFinCtrl);
                
                system.debug('Added list to mapt');
            }
        }
        
        system.debug('setServiceItemTypeId--'+ setServiceItemTypeId);
        system.debug('setFinTransEventTypeId--'+ setFinTransEventTypeId);
        system.debug('setPeriodId--'+ setPeriodId);
        
        system.debug('mapFinCtrlLst---'+ mapFinCtrlLst);
        
        //Query to find all Financial Control Total records
        sOQLQuery = String.format('SELECT {0} FROM {1}', new List<String>{'Id,'+ String.join(financialCtrlTotalFieldList,','), GlUt_APIConstantsFinancialControlTotal.FINANCIALCONTROLAPINAME
            +' WHERE ' + GlUt_APIConstantsFinancialControlTotal.SERVICEITEMTYPEAPINAME + ' IN: setServiceItemTypeId' 
            +' AND ' + GlUt_APIConstantsFinancialControlTotal.FINANCIALTRANSEVENTAPINAME + ' IN: setFinTransEventTypeId'
            +' AND ' + GlUt_APIConstantsFinancialControlTotal.PERIODIDAPINAME + ' IN: setPeriodId'});
        
        
        system.debug('sOQLQuery---'+ sOQLQuery);
        lstFinControlTotal = Database.query(sOQLQuery);
        system.debug('lstFinControlTotal--'+ lstFinControlTotal);
        
        if(!lstFinControlTotal.isEmpty()){
            
            for(FinancialControlTotal__c objFCT : lstFinControlTotal){
                String mapFCTId = objFCT.ServiceItemType__c + '-' + objFCT.FinancialTransactionEvent__c + '-' + objFCT.Period_Id__c;
                
                if(!mapFinCtrlTotalLst.containsKey(mapFCTId)){
                    mapFinCtrlTotalLst.put(mapFCTId, new List<FinancialControlTotal__c>());
                }
                mapFinCtrlTotalLst.get(mapFCTId).add(objFCT);
                
            }
            
        }
        
        system.debug('mapFinCtrlTotalLst----'+ mapFinCtrlTotalLst);
        
        system.debug('mapFinCtrlLst.keyset()===='+ mapFinCtrlLst.keyset());
        
        Map<String,Set<String>> mapDailyEffective = new Map<String,Set<String>>();
        
        for(String objStr : mapFinCtrlLst.keyset()){
            
            system.debug('objStr-***--'+ objStr);
            
            for(FinancialControl__c objUpdList : mapFinCtrlLst.get(objStr)){
                
                system.debug('objUpdList*****'+ objUpdList);
                
                if(mapFinCtrlTotalLst.get(objStr) != null){
                    
                    for(FinancialControlTotal__c objFCTUpdList : mapFinCtrlTotalLst.get(objStr)){
                        
                        String dailyActiveEffective = objFCTUpdList.EffectiveActual__c + '-' + objFCTUpdList.DailyRecord__c;
                        if(!mapDailyEffective.containsKey(objStr)){
                            mapDailyEffective.put(objStr, new Set<String>()); 
                        }
                        mapDailyEffective.get(objStr).add(dailyActiveEffective); 
                    }
                    
                }
                
            }
            
        }
        
        
        for(String objStr : mapFinCtrlLst.keyset()){
            
            system.debug('objStr-***--'+ objStr);
            
            for(FinancialControl__c objUpdList : mapFinCtrlLst.get(objStr)){
                
                system.debug('objUpdList*****'+ objUpdList);
                
                if(mapFinCtrlTotalLst.get(objStr) != null){
                    
                    for(FinancialControlTotal__c objFCTUpdList : mapFinCtrlTotalLst.get(objStr)){
                        
                        String dailyActive = objFCTUpdList.EffectiveActual__c + '-' + objFCTUpdList.DailyRecord__c;
                        
                        if(mapDailyEffective.get(objStr) != null){
                            
                            Set<String> values = mapDailyEffective.get(objStr);
                            if(values.contains(dailyActive)){
                                
                                objFCTUpdList.TotalTax__c = objFCTUpdList.TotalTax__c + objUpdList.TaxAmount__c;
                                objFCTUpdList.TotalAmount__c = objFCTUpdList.TotalAmount__c + objUpdList.Amount__c;
                                objFCTUpdList.TotalDiscount__c = objFCTUpdList.TotalDiscount__c + objUpdList.DiscountAmount__c;
                                
                                lstFinControlTotalUpUpd.add(objFCTUpdList);
                                
                            }
                            else{
                                
                            }
                            
                        }
                        
                    }                    
                    
                }
                else{                    
                    FinancialControlTotal__c objEffectFCT = new FinancialControlTotal__c();
                    
                    objEffectFCT.EffectiveActual__c 			= 'Effective';
                    objEffectFCT.DailyRecord__c 				= false;
                    objEffectFCT.BillingFrequency__c 			= objUpdList.BillingFrequency__c;
                    objEffectFCT.ServiceItemType__c 			= objUpdList.ServiceItemType__c;
                    objEffectFCT.FinancialTransactionEvent__c 	= objUpdList.FinancialTransactionEventType__c;
                    objEffectFCT.Period_Id__c					= objUpdList.Period_Id__c;
                    objEffectFCT.FinancialYear__c				= Integer.valueOf(objUpdList.EffectiveYear__c);
                    objEffectFCT.FinancialPeriod__c				= Integer.valueOf(objUpdList.EffectivePeriod__c);
                    objEffectFCT.TotalAmount__c					= objUpdList.Amount__c;
                    objEffectFCT.TotalTax__c					= objUpdList.TaxAmount__c;
                    objEffectFCT.TotalDiscount__c				= objUpdList.DiscountAmount__c;
                    
                    lstFinControlTotalToAdd.add(objEffectFCT);
                    
                    FinancialControlTotal__c objActualFCT = new FinancialControlTotal__c();
                    
                    objActualFCT.EffectiveActual__c 			= 'Actual';
                    objActualFCT.DailyRecord__c 				= false;
                    objActualFCT.BillingFrequency__c 			= objUpdList.BillingFrequency__c;
                    objActualFCT.ServiceItemType__c 			= objUpdList.ServiceItemType__c;
                    objActualFCT.FinancialTransactionEvent__c 	= objUpdList.FinancialTransactionEventType__c;
                    objActualFCT.Period_Id__c					= objUpdList.Period_Id__c;
                    objActualFCT.FinancialYear__c				= Integer.valueOf(objUpdList.ActualYear__c);
                    objActualFCT.FinancialPeriod__c				= Integer.valueOf(objUpdList.ActualPeriod__c);
                    objActualFCT.TotalAmount__c					= objUpdList.Amount__c;
                    objActualFCT.TotalTax__c					= objUpdList.TaxAmount__c;
                    objActualFCT.TotalDiscount__c				= objUpdList.DiscountAmount__c;
                    
                    lstFinControlTotalToAdd.add(objActualFCT);
                    
                    FinancialControlTotal__c objEffectDailyFCT = new FinancialControlTotal__c();
                    
                    objEffectDailyFCT.EffectiveActual__c 			= 'Effective';
                    objEffectDailyFCT.DailyRecord__c 				= true;
                    objEffectDailyFCT.BillingFrequency__c 			= objUpdList.BillingFrequency__c;
                    objEffectDailyFCT.ServiceItemType__c 			= objUpdList.ServiceItemType__c;
                    objEffectDailyFCT.FinancialTransactionEvent__c 	= objUpdList.FinancialTransactionEventType__c;
                    objEffectDailyFCT.Period_Id__c					= objUpdList.Period_Id__c;
                    objEffectDailyFCT.FinancialYear__c				= Integer.valueOf(objUpdList.EffectiveYear__c);
                    objEffectDailyFCT.FinancialPeriod__c			= Integer.valueOf(objUpdList.EffectivePeriod__c);
                    objEffectDailyFCT.TotalAmount__c				= objUpdList.Amount__c;
                    objEffectDailyFCT.TotalTax__c					= objUpdList.TaxAmount__c;
                    objEffectDailyFCT.TotalDiscount__c				= objUpdList.DiscountAmount__c;
                    
                    lstFinControlTotalToAdd.add(objEffectDailyFCT);
                    
                    FinancialControlTotal__c objActualDailyFCT = new FinancialControlTotal__c();
                    
                    objActualDailyFCT.EffectiveActual__c 			= 'Actual';
                    objActualDailyFCT.DailyRecord__c 				= true;
                    objActualDailyFCT.BillingFrequency__c 			= objUpdList.BillingFrequency__c;
                    objActualDailyFCT.ServiceItemType__c 			= objUpdList.ServiceItemType__c;
                    objActualDailyFCT.FinancialTransactionEvent__c 	= objUpdList.FinancialTransactionEventType__c;
                    objActualDailyFCT.Period_Id__c					= objUpdList.Period_Id__c;
                    objActualDailyFCT.FinancialYear__c				= Integer.valueOf(objUpdList.ActualYear__c);
                    objActualDailyFCT.FinancialPeriod__c			= Integer.valueOf(objUpdList.ActualPeriod__c);
                    objActualDailyFCT.TotalAmount__c				= objUpdList.Amount__c;
                    objActualDailyFCT.TotalTax__c					= objUpdList.TaxAmount__c;
                    objActualDailyFCT.TotalDiscount__c				= objUpdList.DiscountAmount__c;
                    
                    lstFinControlTotalToAdd.add(objActualDailyFCT);
                }
            }
        }
        
        if(!lstFinControlTotalToAdd.isEmpty()){
            lstFinControlTotalToAdd = (List<FinancialControlTotal__c>) GlUt_FieldSecurity.cleanseFields(lstFinControlTotalToAdd, false);
            insert lstFinControlTotalToAdd;
        }
        
        if(!lstFinControlTotalUpUpd.isEmpty()){
            lstFinControlTotalUpUpd = (List<FinancialControlTotal__c>) GlUt_FieldSecurity.cleanseFields(lstFinControlTotalUpUpd, false);
            update lstFinControlTotalUpUpd;
        }
    }
    
}