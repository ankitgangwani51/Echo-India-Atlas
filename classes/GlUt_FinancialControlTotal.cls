/******************************************************************************
@author         Echo: Tarun Gupta
@date           22 mar 2018
@description    Business logic for Financial Control total . THis is called from GlUt_FinancialControlHandler
@Revisions  	02-May-2018 Tarun Gupta AT-2349 , Fix to add null pointer check
@revision		Echo: Sudhir Kumar - AT-3986: Dynamic SOQL for GlUt_FinancialControlTotal (Security Review)
                    - Added with sharing
                    - Removed String.escapeSingleQuotes()
                    - Added headers, variable descriptions
                    - Used constant class variable for Actual and Effective
                AT-4891/2 Code Check Marx Changes for FLS INSERT/UPDATE
@revisions:     04 Mar 2019: Echo: Tarun Gupta -> UL-63,UL-241
*******************************************************************************/
public with sharing class GlUt_FinancialControlTotal {

    private static final String CLASS_NAME = 'GlUt_FinancialControlTotal';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static final List <String> financialCtrlTotalFieldList = new List <String> {
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
        GlUt_APIConstantsFinancialControlTotal.TOTALTAXAPINAME,
        GlUt_APIConstantsFinancialControlTotal.VOIDAPINAME
    };  
    
    private static Map <String, List <FinancialControlTotal__c>> mapExistingFinCtrlTot;	// map of Existing Financial Control Total
    private static Map <Id, FinancialControlTotal__c> mapUpdateExistingFinCtrlTot;		// map of Updated Financial Control Total	
    
    /**********************************************************************************************
    @author         Echo: Tarun Gupta
    @date           29-Mar-2018
    @param          
    @return         
    @description    To create\update FinancialControlTotal__c and associated FinancialControlsAssociation__c
    **********************************************************************************************/

    public static void FinancialTotalEffective(List <SObject> lstFinControl) {              
        //Instantiate Map\List Values        
        mapExistingFinCtrlTot = new Map <String, List <FinancialControlTotal__c>>();
        mapUpdateExistingFinCtrlTot = new Map <Id, FinancialControlTotal__c>();
     
        List <FinancialControlTotal__c> lstFinControlTotalEff = new List <FinancialControlTotal__c> ();
        List <FinancialControlTotal__c> lstFinControlTotalActual = new List <FinancialControlTotal__c> ();

        Set <Id> setServiceItemTypeId = new Set <Id> ();
        Set <Id> setFinTransEventTypeId = new Set <Id> ();
        Set <String> setEffectivePeriodId = new Set <String> ();
        Set <String> setActualPeriodId = new Set <String> ();
      
        Savepoint sp = Database.setSavepoint();
        String sOQLQuery = '';

        Map <String, List <FinancialControlTotal__c>> mapFinCtrlTotalEffLst = new Map <String, List <FinancialControlTotal__c>> ();
        Map <String, List <FinancialControlTotal__c>> mapFinCtrlTotalActualLst = new Map <String, List <FinancialControlTotal__c>> ();

        Map <String, String> mapDailyEffctive = new Map <String, String> ();
        mapDailyEffctive.put(GlUt_APIConstantsFinancialControlTotal.EFFECTIVENOTDAILY, GlUt_APIConstantsFinancialControlTotal.EFFECTIVENOTDAILY);
        mapDailyEffctive.put(GlUt_APIConstantsFinancialControlTotal.EFFECTIVEDAILY, GlUt_APIConstantsFinancialControlTotal.EFFECTIVEDAILY);

        Map <String, String> mapDailyActual = new Map <String, String> ();
        mapDailyActual.put(GlUt_APIConstantsFinancialControlTotal.ACTUALNOTDAILY, GlUt_APIConstantsFinancialControlTotal.ACTUALNOTDAILY);
        mapDailyActual.put(GlUt_APIConstantsFinancialControlTotal.ACTUALDAILY, GlUt_APIConstantsFinancialControlTotal.ACTUALDAILY);
              
        try {
            if (!lstFinControl.isEmpty()) {

                for (FinancialControl__c objFinCtrl: (List <FinancialControl__c> ) lstFinControl) {
                    if(objFinCtrl.ServiceItemType__c != null)						//AT-2673
                    	setServiceItemTypeId.add(objFinCtrl.ServiceItemType__c);
                    if(objFinCtrl.FinancialTransactionEventType__c != null)			//AT-2673
                    	setFinTransEventTypeId.add(objFinCtrl.FinancialTransactionEventType__c);
                    if(objFinCtrl.EffectivePeriodId__c != null)						//AT-2673
                    	setEffectivePeriodId.add(objFinCtrl.EffectivePeriodId__c);
                    if(objFinCtrl.ActualPeriodId__c != null)						//AT-2673
                    	setActualPeriodId.add(objFinCtrl.ActualPeriodId__c);                            
                }
            }
            
            if(setServiceItemTypeId != Null && !setServiceItemTypeId.isEmpty() && setFinTransEventTypeId != Null & !setFinTransEventTypeId.isEmpty() 
               && setEffectivePeriodId != Null && !setEffectivePeriodId.isEmpty()){
                   //Query to find all Financial Control Total records WHERE EFFECTIVE
                   sOQLQuery = String.format('SELECT {0} FROM {1}', new List <String> {
                       'Id,' + String.join(financialCtrlTotalFieldList, ','),
                           GlUt_APIConstantsFinancialControlTotal.FINANCIALCONTROLAPINAME +
                           ' WHERE ' + GlUt_APIConstantsFinancialControlTotal.SERVICEITEMTYPEAPINAME + ' IN: setServiceItemTypeId' +
                           ' AND ' + GlUt_APIConstantsFinancialControlTotal.FINANCIALTRANSEVENTAPINAME + ' IN: setFinTransEventTypeId' +
                           ' AND ' + GlUt_APIConstantsFinancialControlTotal.PERIODIDAPINAME + ' IN: setEffectivePeriodId' +
                           ' AND ' + GlUt_APIConstantsFinancialControlTotal.EFFECTIVEACTUALAPINAME + ' =\'' + GlUt_APIConstantsFinancialControlTotal.EFFECTIVE + '\''
                           });
                   
                   lstFinControlTotalEff = Database.query(sOQLQuery);                   
                   if (!lstFinControlTotalEff.isEmpty()) {
                       for (FinancialControlTotal__c objFCTEff: lstFinControlTotalEff) {
                           String mapFCTId = objFCTEff.ServiceItemType__c + '-' + objFCTEff.FinancialTransactionEvent__c + '-' + objFCTEff.Period_Id__c + '-' + GlUt_APIConstantsFinancialControlTotal.EFFECTIVE;
                           
                           if (!mapFinCtrlTotalEffLst.containsKey(mapFCTId)) {
                               mapFinCtrlTotalEffLst.put(mapFCTId, new List <FinancialControlTotal__c> ());
                           }
                           mapFinCtrlTotalEffLst.get(mapFCTId).add(objFCTEff);
                       }
                   }
               }
            if(setServiceItemTypeId != Null && !setServiceItemTypeId.isEmpty() && setFinTransEventTypeId != Null & !setFinTransEventTypeId.isEmpty() 
               && setActualPeriodId != Null && !setActualPeriodId.isEmpty()){
                   //Query to find all Financial Control Total records WHERE ACTUAL
                   sOQLQuery = String.format('SELECT {0} FROM {1}', new List <String> {
                       'Id,' + String.join(financialCtrlTotalFieldList, ','),
                           GlUt_APIConstantsFinancialControlTotal.FINANCIALCONTROLAPINAME +
                           ' WHERE ' + GlUt_APIConstantsFinancialControlTotal.SERVICEITEMTYPEAPINAME + ' IN: setServiceItemTypeId' +
                           ' AND ' + GlUt_APIConstantsFinancialControlTotal.FINANCIALTRANSEVENTAPINAME + ' IN: setFinTransEventTypeId' +
                           ' AND ' + GlUt_APIConstantsFinancialControlTotal.PERIODIDAPINAME + ' IN: setActualPeriodId' +
                           ' AND ' + GlUt_APIConstantsFinancialControlTotal.EFFECTIVEACTUALAPINAME + ' =\'' + GlUt_APIConstantsFinancialControlTotal.ACTUAL + '\''
                           });
                   
                   lstFinControlTotalActual = Database.query(sOQLQuery);                   
                   if (!lstFinControlTotalActual.isEmpty()) {
                       
                       for (FinancialControlTotal__c objFCTActual: lstFinControlTotalActual) {
                           String mapFCTId = objFCTActual.ServiceItemType__c + '-' + objFCTActual.FinancialTransactionEvent__c + '-' + objFCTActual.Period_Id__c + '-' + GlUt_APIConstantsFinancialControlTotal.ACTUAL;
                           
                           if (!mapFinCtrlTotalActualLst.containsKey(mapFCTId)) {
                               mapFinCtrlTotalActualLst.put(mapFCTId, new List <FinancialControlTotal__c> ());
                           }
                           mapFinCtrlTotalActualLst.get(mapFCTId).add(objFCTActual);
                       }
                   }
               }
            List <FinancialControlTotal__c> lstFinancialControlTotalAll = new List <FinancialControlTotal__c> ();
            List <FinancialControlTotal__c> lstFinancialControlTotalUpdate = new List <FinancialControlTotal__c> ();
            List <FinancialControlTotal__c> lstFinancialControlTotalUpsert = new List <FinancialControlTotal__c> ();

            for (FinancialControl__c objFinCtrl: (List <FinancialControl__c> ) lstFinControl) {
                String strEffective = objFinCtrl.ServiceItemType__c + '-' + objFinCtrl.FinancialTransactionEventType__c + '-' + objFinCtrl.EffectivePeriodId__c + '-' + GlUt_APIConstantsFinancialControlTotal.EFFECTIVE;
                String strActual = objFinCtrl.ServiceItemType__c + '-' + objFinCtrl.FinancialTransactionEventType__c + '-' + objFinCtrl.ActualPeriodId__c + '-' + GlUt_APIConstantsFinancialControlTotal.ACTUAL;
                Map <String, String> dailyEffc = new Map <String, String> ();
                //Bug Fix AT-2305,2307 starts Here
                if (!mapFinCtrlTotalEffLst.isEmpty() && mapFinCtrlTotalEffLst.get(strEffective) != null && mapFinCtrlTotalEffLst.get(strEffective).size()> 0) {
                    //Bug Fix AT-2305,2307 ends Here
                    createFinancialControlTotalRecords(mapFinCtrlTotalEffLst,
                                                       strEffective,
                                                       objFinCtrl,
                                                       mapDailyEffctive);
                } else {
                    //These are the records where no previous records exists for FCT
                    createFinancialControlTotalNewRecords(mapDailyEffctive,
                                                          objFinCtrl);
                }
                // Actual List ..........................
                if (!mapFinCtrlTotalActualLst.isEmpty() && mapFinCtrlTotalActualLst.get(strActual) != null && mapFinCtrlTotalActualLst.get(strActual).size()> 0) {
                    createFinancialControlTotalRecords(mapFinCtrlTotalActualLst,
                                                       strActual,
                                                       objFinCtrl,
                                                       mapDailyActual);
                } else {
                    //These are the records where no previous records exists for FCT
                    createFinancialControlTotalNewRecords(mapDailyActual,
                                                          objFinCtrl);
                }
            }
            List <FinancialControlTotal__c> lstFCTToBeInserted = new List <FinancialControlTotal__c> ();
            
			//AT-4892 Code Check Marx Changes Starts Here.
            if (!mapUpdateExistingFinCtrlTot.values().isEmpty()) {
                List<FinancialControlTotal__c> updateExistingFinCtrlTotList = (List<FinancialControlTotal__c>) GlUt_FieldSecurity.cleanseFields(mapUpdateExistingFinCtrlTot.values(), false); //AT-4892 Code Check Marx Changes Starts/Ends Here.
                update updateExistingFinCtrlTotList;
            }
            //AT-4892 Code Check Marx Changes Ends Here.
            if (!mapExistingFinCtrlTot.isEmpty()) {

                for (String objStr: mapExistingFinCtrlTot.keySet()) {
                    
                    FinancialControlTotal__c objFirstFCT = mapExistingFinCtrlTot.get(objStr)[0];
                    Decimal taxAmount = 0.00;
                    Decimal totAmount = 0.00;
                    Decimal discAmount = 0.00;
                    
                    for (FinancialControlTotal__c objFCt: mapExistingFinCtrlTot.get(objStr)) {

                        if (objFCt.TotalTax__c != null) {
                            taxAmount += objFCt.TotalTax__c;
                        }
                        if (objFCt.TotalAmount__c != null) {
                            totAmount += objFCt.TotalAmount__c;
                        }
                        if (objFCt.TotalDiscount__c != null) {
                            discAmount += objFCt.TotalDiscount__c;
                        }
                    }
                    objFirstFCT.TotalAmount__c = totAmount;
                    objFirstFCT.TotalTax__c = taxAmount;
                    objFirstFCT.TotalDiscount__c = discAmount;
                    lstFCTToBeInserted.add(objFirstFCT);
                }
            }
            if (!lstFCTToBeInserted.isEmpty()) {
                lstFCTToBeInserted = (List<FinancialControlTotal__c>) GlUt_FieldSecurity.cleanseFields(lstFCTToBeInserted, false); //AT-4891 Code Check Marx Changes Starts/Ends Here.
                insert lstFCTToBeInserted;
            }
            List <FinancialControlsAssociation__c> lstFCAToInsert = new List <FinancialControlsAssociation__c> ();
            for (FinancialControl__c objFinCtrl: (List <FinancialControl__c> ) lstFinControl) {
                
                if(!mapUpdateExistingFinCtrlTot.values().IsEmpty()){
                    createFinancialControlsAssociation(objFinCtrl,
                                                       mapUpdateExistingFinCtrlTot.values(),
                                                       lstFCAToInsert
                                                      );
                }
                if(!lstFCTToBeInserted.isEmpty()){
                    createFinancialControlsAssociation(objFinCtrl,
                                                       lstFCTToBeInserted,
                                                       lstFCAToInsert);
                }
            }
            if (!lstFCAToInsert.isEmpty()) {
                lstFCAToInsert = (List<FinancialControlsAssociation__c>) GlUt_FieldSecurity.cleanseFields(lstFCAToInsert, false); //AT-4891 Code Check Marx Changes Starts/Ends Here.
                insert lstFCAToInsert;
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            Database.rollback(sp);
            System.debug('exception = ' + e.getMessage());
            GlUt_Logger.writeLogsToDatabase();
        }
        finally {   
        }
    }

    /**********************************************************************************************
    @author         Echo: Tarun Gupta
    @date           29-Mar-2018
    @param          
    @return         
    @description    To prepare an object of FinancialControlTotal__c
    **********************************************************************************************/
    private static FinancialControlTotal__c createFinancialControlTotal(FinancialControl__c objFinancialCtrl,String actualEffective,Boolean daily) {
        FinancialControlTotal__c objFCTToBeAdded = new FinancialControlTotal__c();
        objFCTToBeAdded.EffectiveActual__c = actualEffective;
        objFCTToBeAdded.DailyRecord__c = daily;
        objFCTToBeAdded.BillingFrequency__c = objFinancialCtrl.BillingFrequency__c;
        objFCTToBeAdded.ServiceItemType__c = objFinancialCtrl.ServiceItemType__c;
        objFCTToBeAdded.FinancialTransactionEvent__c = objFinancialCtrl.FinancialTransactionEventType__c;
        if(GlUt_RegionUtility.getUKRegionCustomSetting()){
            objFCTToBeAdded.Void__c = objFinancialCtrl.Void__c;
        }
        
        if (actualEffective == 'Effective') {
            objFCTToBeAdded.Period_Id__c = objFinancialCtrl.EffectivePeriodId__c;
            if (objFinancialCtrl.EffectiveYear__c != null) {
                objFCTToBeAdded.FinancialYear__c = Integer.valueOf(objFinancialCtrl.EffectiveYear__c);
            }
            if (objFinancialCtrl.EffectivePeriod__c != null) {
                objFCTToBeAdded.FinancialPeriod__c = Integer.valueOf(objFinancialCtrl.EffectivePeriod__c);
            }
        } else {
            objFCTToBeAdded.Period_Id__c = objFinancialCtrl.ActualPeriodId__c;
            if (objFinancialCtrl.ActualYear__c != null) {
                objFCTToBeAdded.FinancialYear__c = Integer.valueOf(objFinancialCtrl.ActualYear__c);
            }
            if (objFinancialCtrl.ActualPeriod__c != null) {
                objFCTToBeAdded.FinancialPeriod__c = Integer.valueOf(objFinancialCtrl.ActualPeriod__c);
            }
        }
        objFCTToBeAdded.TotalAmount__c = objFinancialCtrl.Amount__c;
        objFCTToBeAdded.TotalTax__c = objFinancialCtrl.TaxAmount__c;
        objFCTToBeAdded.TotalDiscount__c = objFinancialCtrl.DiscountAmount__c;        
        return objFCTToBeAdded;
    }

    /**********************************************************************************************
    @author         Echo: Tarun Gupta
    @date           29-Mar-2018
    @param          
    @return         
    @description    To prepare an object of  FinancialControlsAssociation__c
    **********************************************************************************************/
    private static void createFinancialControlsAssociation(FinancialControl__c objFinCtrl,
        List <FinancialControlTotal__c> lstFCTToBeInserted,
        List <FinancialControlsAssociation__c> lstFCAToInsert) {

        String strEff = objFinCtrl.ServiceItemType__c + '-' + objFinCtrl.FinancialTransactionEventType__c + '-' + objFinCtrl.EffectivePeriodId__c + '-' + GlUt_APIConstantsFinancialControlTotal.EFFECTIVE;
        String strActual = objFinCtrl.ServiceItemType__c + '-' + objFinCtrl.FinancialTransactionEventType__c + '-' + objFinCtrl.ActualPeriodId__c + '-' + GlUt_APIConstantsFinancialControlTotal.ACTUAL;
        Integer counter = 0;

        for (FinancialControlTotal__c objFCT: lstFCTToBeInserted) {
            
            String strEffUniqueValue = strEff + String.valueOf(objFCT.Id) + String.valueOf(objFinCtrl.Id);
            String strActUniqueValue = strActual + String.valueOf(objFCT.Id) + String.valueOf(objFinCtrl.Id);
            String strEffTot = objFCT.ServiceItemType__c + '-' + objFCT.FinancialTransactionEvent__c + '-' + objFCT.Period_Id__c + '-' + GlUt_APIConstantsFinancialControlTotal.EFFECTIVE;
            String strActTot = objFCT.ServiceItemType__c + '-' + objFCT.FinancialTransactionEvent__c + '-' + objFCT.Period_Id__c + '-' + GlUt_APIConstantsFinancialControlTotal.ACTUAL;
            
            if(objFinCtrl.EffectivePeriodId__c == objFinCtrl.ActualPeriodId__c){
                FinancialControlsAssociation__c objFCAEffTrue = new FinancialControlsAssociation__c();
                objFCAEffTrue.FinancialControlRecord__c = objFinCtrl.Id;
                objFCAEffTrue.FinancialControlTotal__c = objFCT.Id;
                lstFCAToInsert.add(objFCAEffTrue);                
            }
            else{
                if (strEff == strEffTot) {
                    FinancialControlsAssociation__c objFCAEffTrue = new FinancialControlsAssociation__c();
                    objFCAEffTrue.FinancialControlRecord__c = objFinCtrl.Id;
                    objFCAEffTrue.FinancialControlTotal__c = objFCT.Id;
                    lstFCAToInsert.add(objFCAEffTrue);
                }
                if (strActual == strActTot) {
                    FinancialControlsAssociation__c objFCAEffTrue = new FinancialControlsAssociation__c();
                    objFCAEffTrue.FinancialControlRecord__c = objFinCtrl.Id;
                    objFCAEffTrue.FinancialControlTotal__c = objFCT.Id;
                    lstFCAToInsert.add(objFCAEffTrue);
                }
            }
        }
    }

    /**********************************************************************************************
    @author         Echo: Tarun Gupta
    @date           03-Apr-2018
    @param          Map <String, List <FinancialControlTotal__c>> mapFinCtrlTotalLst, String strEffectiveActual, FinancialControl__c objFinCtrl, Map <String, String> mapActualEffctive
    @return         void
    @description    To create\update Financial Control Total records
    **********************************************************************************************/
    private static void createFinancialControlTotalRecords(Map <String, List <FinancialControlTotal__c>> mapFinCtrlTotalLst,
        String strEffectiveActual,
        FinancialControl__c objFinCtrl,
        Map <String, String> mapActualEffctive) {
        Map <String, String> dailyEffc = new Map <String, String> ();

        for (FinancialControlTotal__c objFCTUpdList: mapFinCtrlTotalLst.get(strEffectiveActual)) {

            String dailyActive = objFCTUpdList.EffectiveActual__c + '-' + String.valueOf(objFCTUpdList.DailyRecord__c);

            dailyEffc.put(dailyActive, dailyActive);

            //Bug Fix AT-2349 starts Here

            if (objFCTUpdList.TotalTax__c != null && objFinCtrl.TaxAmount__c != null) {
                objFCTUpdList.TotalTax__c += objFinCtrl.TaxAmount__c;
            } else {
                objFCTUpdList.TotalTax__c = objFinCtrl.TaxAmount__c;
            }
            if (objFCTUpdList.TotalAmount__c != null && objFinCtrl.Amount__c != null) {
                objFCTUpdList.TotalAmount__c += objFinCtrl.Amount__c;
            } else {
                objFCTUpdList.TotalAmount__c = objFinCtrl.Amount__c;
            }
            if (objFCTUpdList.TotalDiscount__c != null && objFinCtrl.DiscountAmount__c != null) {
                objFCTUpdList.TotalDiscount__c += objFinCtrl.DiscountAmount__c;
            } else {
                objFCTUpdList.TotalDiscount__c = objFinCtrl.DiscountAmount__c;
            }
            if(GlUt_RegionUtility.getUKRegionCustomSetting()){
                objFCTUpdList.Void__c = objFinCtrl.Void__c;
            }
            if (!mapUpdateExistingFinCtrlTot.containskey(objFCTUpdList.Id)) {
                mapUpdateExistingFinCtrlTot.put(objFCTUpdList.Id, objFCTUpdList);
            }
        }
        //These are the records where few previous records exists for FCT , the ones which doesn't exists , needs to be created.

        for (String objStr1: mapActualEffctive.keySet()) {
            if (!dailyEffc.containsKey(objStr1)) {
                Map <String, String> mapNewRecords = new Map <String, String> ();
                mapNewRecords.put(objStr1, objStr1);
                createFinancialControlTotalNewRecords(mapNewRecords, objFinCtrl);
            }
        }
    }

    /**********************************************************************************************
    @author         Echo: Tarun Gupta
    @date           03-Apr-2018
    @param          Map <String, String> mapActualEffctive, FinancialControl__c objFinCtrl
    @return         void
    @description    To create New Financial Control Total records
    **********************************************************************************************/
    private static void createFinancialControlTotalNewRecords(Map <String, String> mapActualEffctive,
        FinancialControl__c objFinCtrl) {
        for (String objStrCreate: mapActualEffctive.keySet()) {

            //FinancialControlTotal__c objFinControlTotalToAdd = new FinancialControlTotal__c();
            List <String> lstDailyActualEffctvCreate = mapActualEffctive.get(objStrCreate).split('-');
            
            String uniqueStr = '';
            
            if (lstDailyActualEffctvCreate[0] == GlUt_APIConstantsFinancialControlTotal.EFFECTIVE) {
                uniqueStr = objFinCtrl.ServiceItemType__c +
                    '-' + objFinCtrl.FinancialTransactionEventType__c +
                    '-' + objFinCtrl.EffectivePeriodId__c +
                    '-' + lstDailyActualEffctvCreate[0] +
                    '-' + lstDailyActualEffctvCreate[1];
            } else if (lstDailyActualEffctvCreate[0] == GlUt_APIConstantsFinancialControlTotal.ACTUAL) {
                uniqueStr = objFinCtrl.ServiceItemType__c +
                    '-' + objFinCtrl.FinancialTransactionEventType__c +
                    '-' + objFinCtrl.ActualPeriodId__c +
                    '-' + lstDailyActualEffctvCreate[0] +
                    '-' + lstDailyActualEffctvCreate[1];
            }
            FinancialControlTotal__c objFinControlTotalToAdd = createFinancialControlTotal(objFinCtrl, lstDailyActualEffctvCreate[0], Boolean.valueOf(lstDailyActualEffctvCreate[1]));
            if (!mapExistingFinCtrlTot.containskey(uniqueStr)) {
                mapExistingFinCtrlTot.put(uniqueStr, new List <FinancialControlTotal__c> {
                    objFinControlTotalToAdd
                });
            } else {
                mapExistingFinCtrlTot.get(uniqueStr).add(objFinControlTotalToAdd);
            }
        }
    }
}