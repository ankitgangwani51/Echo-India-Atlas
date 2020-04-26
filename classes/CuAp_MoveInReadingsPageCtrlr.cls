/******************************************************************************
@author         Accenture: Shivangi Gaur
@date           08 Nov 2017
@description    Component controller for move in reading lightning component (move in move out)
@version:       20 Nov 2017 Manish Singh, Added device fields
                29 Dec 2017 Gopal Gupta, Added a NPE check for map mapDevListSvc 
                    in retrieveReadingAndDevice method at line # 100
                Shivangi Gaur -- 09-Jan-2018 -- Incorporated review comments on AT-1020 dated 08-Jan-2018.
                03 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
				04/12/18 - TG , AT-3872 , removed current read functionality
*******************************************************************************/
public with sharing class CuAp_MoveInReadingsPageCtrlr{
    
    @testVisible private static List<string> spdFields;
    @testVisible private static List<string> spdsFields;
    @testVisible private static List<string> devFields;
    @testVisible private static List<string> supFields;
    @testVisible private static List<string> readFields;
    @testVisible private static List<string> currReadFields;
    @testVisible private static List<string> bundleFields ;
    @testVisible private static List<string> availableServiceFields ;
    @testVisible private static List<string> estimateReadingFields;
    @testVisible private static List<String> listSPDevice;
    @testVisible private static List<String> additionalCurrReadFields;   // AT-3420 Core 8b
    @testVisible private static List<String> currentBillableReadFields ; //  Sudhir AT-3388  (Core-8b)
    private static List<SupplyPointDevice__c> spdList = new List<SupplyPointDevice__c>();
    private static Map<Id, SupplyPointDeviceService__c> mapNew = new Map<Id,SupplyPointDeviceService__c>();
    private static Map<Id, Device__c> mapDev = new Map<Id, Device__c>(); 
    private static Map<Id, Reading__c> readMap = new Map<Id, Reading__c>();
    private static Map<Id, SupplyPoint__c> mapSP = new Map<Id, SupplyPoint__c>();
    private static Map<Id, Reading__c> mapOldReading = new Map<Id, Reading__c>();
    private static Map<Id, List<String>> mapDevListSvc= new Map<Id, List<String>>();
    private static LocationOccupant__c objLoactionOccupant = new LocationOccupant__c();// Added By dependra - AT-2657
      
    private static final String CLASS_NAME = 'CuAp_MoveInReadingsPageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    
    static{     // Sudhir 9/3/2018  - updated constant class reference
        bundleFields = new List<string>();
        bundleFields.add(GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME);
        availableServiceFields = new List<string>();
        availableServiceFields.add(GlUt_APIConstantsAvailableService.SERVICETYPEAPINAME);
        availableServiceFields.add(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME);
        estimateReadingFields  = new List<string>();
        estimateReadingFields.add(GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME);
        listSPDevice = new List<string>();
        listSPDevice.add(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME);
        listSPDevice.add(GlUt_APIConstantsDevice.DEVICEAPINAME);
    }
    static{     // Sudhir 9/3/2018  - updated constant class reference
        spdFields = new List<string>();
        spdFields.add(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME);       
    } 
    static{     // Sudhir 9/3/2018  - updated constant class reference
        spdsFields = new List<string>();
        spdsFields.add(GlUt_APIConstantsAvailableService.SERVICETYPEAPINAME );            
    }
    static{     // Sudhir 9/3/2018  - updated constant class reference
        devFields = new List<string>();
        devFields.add(GlUt_APIConstantsDevice.SERIALNOAPINAME);
        devFields.add(GlUt_APIConstantsDevice.DIGITSAPINAME);            
    }
    static{     // Sudhir 9/3/2018  - updated constant class reference
        supFields = new List<string>();
        supFields.add(GlUt_APIConstantsSupplyPoint.DEVICELOCATIONAPINAME);            
    }
    static{     // Sudhir 9/3/2018  - updated constant class reference
        readFields = new List<string>();
        readFields.add(GlUt_APIConstantsReading.READINGDATEAPINAME);
        readFields.add(GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME);
        readFields.add(GlUt_APIConstantsReading.READINGMETHODAPINAME);
        readFields.add(GlUt_APIConstantsReading.TRIPPEDAPINAME);            //AT-3420 core 8b
    }
    static{     // Sudhir 9/3/2018  - updated constant class reference
        currReadFields = new List<string>();
        currReadFields.add(GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME);
        currReadFields.add(GlUt_APIConstantsReading.READINGMETHODAPINAME);       
    }
    
    static{     //  AT-3420 core 8b
        additionalCurrReadFields = new List<string>();
        additionalCurrReadFields.add(GlUt_APIConstantsReading.TRIPPEDAPINAME);     
        additionalCurrReadFields.add(GlUt_APIConstantsReading.BILLABLETYPEAPINAME);       
    }
    
    static{     //  Sudhir AT-3388 (Core-8b)
        currentBillableReadFields = new List<string>();
        currentBillableReadFields.add(GlUt_APIConstantsReading.BILLABLETYPEAPINAME);          
    }
    /**********************************************************************************************
    @author         Accenture: Shivangi Gaur
    @date           08-Nov-2017
    @param          List<string>
    @return         List<BlAp_CombinedRecord>
    @description    This method takes the available bundle ids selected to return details of device and
                    reading data.
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveReadingAndDevice(List<String> availableBun, String moveInDate) {
        
        Date readingDate = Date.valueof(moveInDate);
        getReadingDetails(availableBun, moveInDate, false);
        List<BlAp_CombinedRecord> combinedList = new List<BlAp_CombinedRecord>();
        try {
            for (SupplyPointDevice__c spdObj : spdList) {
                SupplyPointDeviceService__c spdObjNew = new SupplyPointDeviceService__c();
                Device__c devObjNew = new Device__c();
                SupplyPoint__c supObj = new SupplyPoint__c();
                Reading__c readObj = new Reading__c();
                if (mapNew.containskey(spdObj.id)) {
                    spdObjNew = mapNew.get(spdObj.id);
                }
                
                String commaSeperatedNames = '';
                if (mapDevListSvc.containskey(spdObj.id)) {
                    for (string avlSrvItm : mapDevListSvc.get(spdObj.Id)) {
                        commaSeperatedNames += avlSrvItm  + '\n' ;
                    }
                }
                commaSeperatedNames = commaSeperatedNames.subString(0, commaSeperatedNames.length()); 
                if (mapDev.containskey(spdObj.id)) {
                    devObjNew = mapDev.get(spdObj.id);
                    if (readMap.containsKey(devObjNew.id)) {
                        readObj = readMap.get(devObjNew.id);
                    }
                }
                if (mapSP.containsKey(spdObj.SupplyPoint__c)) {
                    supObj = mapSP.get(spdObj.SupplyPoint__c);
                }
                BlAp_CombinedRecord combRecord = new BlAp_CombinedRecord();   
                combRecord.uniqueId = spdObj.Id;
                combRecord.isSelected = true;
                combRecord.objectMap = new Map<string, sObject>();
                combRecord.readOnlyFields = new Map<string, boolean>();
                combRecord.objectMap.put(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, spdObj);
                combRecord.objectMap.put(GlUt_APIConstantsSPDService.SUPPLYPOINTSERVICEDEVICEAPINAME, spdObjNew);
                combRecord.objectMap.put(GlUt_APIConstantsDevice.DEVICEAPINAME, devObjNew);
                combRecord.objectMap.put(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, supObj);
                combRecord.objectMap.put(GlUt_APIConstantsLocationOccupant.LOCATIONOCCUPANTAPINAME, objLoactionOccupant);// Added By dependra - AT-2657
                combRecord.objectMap.put(GlUt_APIConstantsReading.READINGAPINAME, readObj);
                combRecord.objectMap.put(GlUt_APIConstantsReading.READINGAPINAME + '1', 
                                         new Reading__c(Device__c = devObjNew.Id, 
                                                        ReadingType__c = CuAp_Constants.MOVEIN,
                                                        ReadingDate__c = readingDate, 
                                                        ReadingSource__c = CuAp_Constants.CUSTOMERREADING, 
                                                        ReadingMethod__c ='',
                                                        Tripped__c = false));   // AT-3420 core 8b
                combRecord.objectMap.put(GlUt_APIConstantsReading.READINGAPINAME + '2', 
                                         new Reading__c(Device__c = devObjNew.Id, 
                                                        ReadingType__c = CuAp_Constants.MOVEIN,
                                                        ReadingDate__c = readingDate, 
                                                        ReadingSource__c = CuAp_Constants.CUSTOMERREADING, 
                                                        ReadingMethod__c ='' ));
                
                Map<string, string> contrtransFormFieldMap = new Map<string, string>();
                contrtransFormFieldMap.put(CuAp_Constants.SERVICETYPELBL, commaSeperatedNames);
                combRecord.transformFieldMap = new Map<string,Map<string, string>>();
                combRecord.transformFieldMap.put(GlUt_APIConstantsSPDService.SUPPLYPOINTSERVICEDEVICEAPINAME, contrtransFormFieldMap);
                combinedList.add(combRecord);
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        system.debug(JSON.serialize(combinedList));
        return combinedList;
        
    }
    
    /**********************************************************************************************
    @author         Accenture: Shivangi Gaur
    @date           08-Nov-2017
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the fields that are
                    to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveSupFieldPropDetails() {
        List<GLAp_FieldProps> fldPropList;
        try {
            fldPropList = fieldProp(false);
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return fldPropList;
    }
    
    /**********************************************************************************************
    @author         Accenture: Manish Singh
    @date           08-Dec-2017
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the fields that are
                    to be displayed on the screen. This is for the current or move in reading table.
    **********************************************************************************************/
    private static List<GLAp_FieldProps> fieldProp(Boolean current){

        List<GLAp_FieldProps> spdProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, spdFields);
        List<GLAp_FieldProps> spdsProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsSPDService.SUPPLYPOINTSERVICEDEVICEAPINAME, spdsFields);
        List<GLAp_FieldProps> devProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDevice.DEVICEAPINAME, devFields);
        List<GLAp_FieldProps> spProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, supFields);

        List<GLAp_FieldProps> readProps = current 
                                        ? GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReading.READINGAPINAME, currReadFields) 
                                        : GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReading.READINGAPINAME, readFields);
                  
        List<GLAp_FieldProps> readPropsNew = current 
                                            ? new List<GLAp_FieldProps>() 
                                            : GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReading.READINGAPINAME, currReadFields);  
        
        // AT-3420 core 8b
        if(current){
           spProps.addall(GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReading.READINGAPINAME, additionalCurrReadFields)) ;
           //readProps.addAll(GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReading.READINGAPINAME, currentBillableReadFields)) ;   //  Sudhir AT-3388  (Core-8b)
        }
         
        //Add in button fields
        GLAp_FieldProps buttonFieldProp1 = new GLAp_FieldProps();
        buttonFieldProp1.isFLSVisible = true;
        buttonFieldProp1.isEncrypted = false;
        buttonFieldProp1.isEditable = false;
        buttonFieldProp1.isRequired = false;
        buttonFieldProp1.fieldName = CuAp_Constants.ESTIMATE;
        buttonFieldProp1.fieldLabel = CuAp_Constants.ESTIMATE;
        buttonFieldProp1.buttonField = true;
        if (current) {
            spProps.Add(buttonFieldProp1);
        } else {
            readProps.add(buttonFieldProp1);
        }
        
        //Add in button fields
        GLAp_FieldProps buttonFieldProp2 = new GLAp_FieldProps();
        buttonFieldProp2.isFLSVisible = true;
        buttonFieldProp2.isEncrypted = false;
        buttonFieldProp2.isEditable = false;
        buttonFieldProp2.isRequired = false;
        buttonFieldProp2.fieldName = CuAp_Constants.AMEND;
        buttonFieldProp2.fieldLabel = CuAp_Constants.AMEND;
        buttonFieldProp2.fieldType = CuAp_Constants.TEXT;
        buttonFieldProp2.buttonField = true;
        
        for (GLAp_FieldProps spdProp : spdProps) {
            spdProp.isEditable = false;
        }
        for (GLAp_FieldProps spdsProp : spdsProps) {
            spdsProp.isEditable = false;
        }
        for (GLAp_FieldProps devProp : devProps) {
            devProp.isEditable = false;          
        }
        for (GLAp_FieldProps supProp : spProps) {
            supProp.isEditable = false;
        }
        
        List<GLAp_FieldProps> avlSrvItemsProps = retrieveTransformFieldPropDetails();
        
        if (current) {
            for (GLAp_FieldProps readProp : readProps) {
                
                if (readProp.fieldLabel == CuAp_Constants.ACTUALREADINGLABEL) {
                    readProp.fieldLabel = System.Label.CuAp_CurrentReading;
                }
                if (readProp.fieldLabel == CuAp_Constants.READINGMETHODLABEL) {
                    readProp.fieldLabel = System.Label.CuAp_CurrentReadingMethod;
                }
                /*
                if (readProp.fieldLabel == CuAp_Constants.BILLABLETYPELABEL){   //  Sudhir AT-3388  (Core-8b) 
                    readProp.isEditable = true;
                } 
                */
            }

        } else {
        
            for (GLAp_FieldProps prop : readPropsNew) {
                if (prop.parentObject == GlUt_APIConstantsReading.READINGAPINAME ) {
                    prop.parentObject = GlUt_APIConstantsReading.READINGAPINAME + '1';  
                }        
                 /*     
                if (prop.fieldLabel == CuAp_Constants.BILLABLETYPELABEL){   //  Sudhir AT-3388  (Core-8b) 
                    prop.isFLSVisible = false;
                }
                */
                
            }  
            for (GLAp_FieldProps readProp : readProps) {
                readProp.isEditable = false;
                if (readProp.fieldLabel == CuAp_Constants.ACTUALREADINGLABEL ){
                    readProp.fieldLabel = System.Label.CuAp_PreviousReading;
                }
                if (readProp.fieldLabel == CuAp_Constants.READINGMETHODLABEL) {
                    readProp.fieldLabel = System.Label.CuAp_PreviousReadingMethod;
                }
                if (readProp.fieldLabel == CuAp_Constants.READINGDATELABEL) {
                    readProp.fieldLabel = System.Label.CuAp_PreviousReadingDate;
                }                
                if (readProp.fieldLabel == CuAp_Constants.TRIPPEDLABEL){   // AT-3420  core 8b
                    readProp.isEditable = true;
                    readProp.parentObject = GlUt_APIConstantsReading.READINGAPINAME + '1'; 
                }                              
            }
            for (GLAp_FieldProps readProp : readPropsNew) {
                if (readProp.fieldLabel == CuAp_Constants.ACTUALREADINGLABEL) {
                    readProp.fieldLabel = System.Label.CuAp_MoveInReading;
                }
                if (readProp.fieldLabel == CuAp_Constants.READINGMETHODLABEL) {
                    readProp.fieldLabel = System.Label.CuAp_MoveInReadingMethod;
                }
            }
        }
        
        //Build a map list of all field properties
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        for (GLAp_FieldProps fldProp : spdProps) {            
            fldPropList.add(fldProp);                           
        }       
        for (GLAp_FieldProps fldProp : devProps) {            
            fldPropList.add(fldProp);                           
        }
        
        for (GLAp_FieldProps fldProp : avlSrvItemsProps) {            
            fldPropList.add(fldProp);                           
        }  
        for (GLAp_FieldProps fldProp : spProps) {  
            if(fldProp.fieldLabel == CuAp_Constants.TRIPPEDLABEL){ // AT-3420 core 8b
               fldProp.isEditable = true; 
            }
            if (fldProp.fieldLabel == CuAp_Constants.BILLABLETYPELABEL){   //  Sudhir AT-3388  (Core-8b) 
                    fldProp.isEditable = true;
                }
            fldPropList.add(fldProp);                           
        }
        
        for (GLAp_FieldProps fldProp : readProps) {            
            fldPropList.add(fldProp);                           
        }
        
        if (readPropsNew.size() > 0) {
            for (GLAp_FieldProps fldProp : readPropsNew) {            
                fldPropList.add(fldProp);                           
            }
        } 
        return fldPropList;
    }
    
    /**********************************************************************************************
    @author         Accenture: Manish Singh
    @date           19-Dec-2017
    @param          List<string>, String date, Boolean current
    @return         List<BlAp_CombinedRecord>
    @description    This method takes the available bundle ids selected to return details of device and
                    reading data for movein and current reading.
    **********************************************************************************************/
    public static List<BlAp_CombinedRecord> getReadingDetails(List<String> availableBun, String moveInDate, Boolean current) {

        Date readingDate = Date.valueof(moveInDate);
        Date systemToday = System.today();
        List<BlAp_CombinedRecord> combinedList = new List<BlAp_CombinedRecord>();
        Set<Id> setSP = new Set<Id>();
        Set<Id> setAvSer = new Set<Id>();
        Set<Id> setServType = new Set<Id> ();
        
        Map<Id, Id> mapSPtoServ = new Map<Id, Id>();
        Set<Id> setSPDS = new Set<Id>();
        Set<Id> setDevice = new Set<Id>();

        mapNew = new Map<Id, SupplyPointDeviceService__c>();
        
        List<SupplyPointDeviceService__c> spdsList = new List<SupplyPointDeviceService__c>();

        //Only query datbase if one field is field in
        List<AvailableBundle__c> listBundle = new List<AvailableBundle__c>();
        if (availableBun.size() > 0) {
            listBundle = (List<AvailableBundle__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAvailableBundle.AVAILABLEBUNDLEAPINAME, 
                                                                                        bundleFields,
                                                                                        'WHERE Id IN ' + GlUt_FieldSecurity.StringsToString(availableBun));
        }
        for (AvailableBundle__c avBunObj : listBundle) {
            if (avBunObj.AvailableService__c != null) {
                setAvSer.add(avBunObj.AvailableService__c);
            }               
        }

        List<AvailableService__c> listAvailableSer = new List<AvailableService__c>();        
        if (setAvSer.size() > 0) {
            
            //MT- 22 Feb 2018 AT-1872 added the active check while in the available service query
            listAvailableSer = (List<AvailableService__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME, 
                                                                                                availableServiceFields,
                                                                                                String.format('WHERE Id IN {0} AND {1} = TRUE', 
                                                                                                    new List<String>{
                                                                                                        GlUt_FieldSecurity.IdsToString(setAvSer), 
                                                                                                        GlUt_APIConstantsAvailableService.ACTIVEAPINAME}));
        }
        
        for (AvailableService__c availableSerObj : listAvailableSer) {
            if (availableSerObj.SupplyPoint__c != null) {
                setSP.add(availableSerObj.SupplyPoint__c);
            }               
            if (!mapSPtoServ.containsKey(availableSerObj.ServiceType__c)) {
                mapSPtoServ.put(availableSerObj.ServiceType__c,availableSerObj.ServiceType__c);
            }               
        }
        
        List<SupplyPoint__c> spList = new List<SupplyPoint__c>();
        List<SupplyPointDevice__c> listSupplyPointDevice = new List<SupplyPointDevice__c>();
        if (setSP.size() > 0) {
            spList = (List<SupplyPoint__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, 
                                                                                supFields,
                                                                                'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(setSP));

            listSupplyPointDevice = (List<SupplyPointDevice__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, 
                                                                                                    listSPDevice, 
                                                                                                    String.format('WHERE {0} = TRUE AND {1} IN {2}', 
                                                                                                        new List<String>{
                                                                                                            GlUt_APIConstantsAvailableService.ACTIVEAPINAME, 
                                                                                                            GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, 
                                                                                                            GlUt_FieldSecurity.IdsToString(setSP)}));
        } 
        
        Set<Id> newSetSP = new Set<Id>(); 
        if (listSupplyPointDevice.size() > 0) {
            for (SupplyPointDevice__c spPbj: listSupplyPointDevice) {
                setSPDS.add(spPbj.id);
                newSetSP.add(spPbj.SupplyPoint__c);
            }
        }
        mapSP = new Map<Id, SupplyPoint__c >([Select Id, DeviceLocation__c,Location__c from SupplyPoint__c where Id IN: newSetSP]);
        // Code added by dependra - AT-2657
        set<Id> setLocationIds = new set<Id>();
        if(mapSP.keyset().size() > 0){
            for(Id objId : mapSP.keyset()){
                if(mapSP.get(objId).Location__c != null){
                    setLocationIds.add(mapSP.get(objId).Location__c);
                }
            }
        }
        if(setLocationIds.size() > 0){
            List<LocationOccupant__c> lstLocationOccupant = [SELECT Id, Location__c, Active__c, Account__c,StartDate__c ,EndDate__c FROM LocationOccupant__c WHERE Location__c IN :setLocationIds  and Active__c = true];
            if(!lstLocationOccupant.isEmpty()){
                objLoactionOccupant = lstLocationOccupant[0];
            }
        }
        spdList = [Select Id, Device__c, SupplyPoint__c, 
                        (Select id, SupplyPointDevice__c, ServiceType__c from SupplyPointDeviceServices__r), 
                        (SELECT Id, AverageDailyUsage__c FROM AverageDailyUsage__r order by EndDate__c desc LIMIT 1) 
                    from SupplyPointDevice__c where SupplyPoint__c IN: newSetSP and Active__c = true];
                    
        List<Id> supplyPointDeviceIds = new List<Id>();
        for (SupplyPointDevice__c supplyPointDevice : spdList) {
            supplyPointDeviceIds.add(supplyPointDevice.Id);
        }
                    
        List<String> supplyPointDeviceServiceFields = new List<String>{      
                                        GlUt_APIConstantsSPDService.SUPPLYPOINTDEVICEAPINAME, 
                                        GlUt_APIConstantsSPDService.SUPPLYPOINTDEVICERELAPINAME + '.' + GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME, 
                                        GlUt_APIConstantsSPDService.SERVICETYPEAPINAME, 
                                        GlUt_APIConstantsSPDService.SERVICETYPERELAPINAME + '.Name'
                                        };
        spdsList = (List<SupplyPointDeviceService__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSPDService.SUPPLYPOINTSERVICEDEVICEAPINAME, 
                                                                                            supplyPointDeviceServiceFields, 
                                                                                            String.format('WHERE {0} IN {1}',
                                                                                                new List<String>{
                                                                                                    GlUt_APIConstantsSPDService.SUPPLYPOINTDEVICEAPINAME,  
                                                                                                    GlUt_FieldSecurity.IdsToString(supplyPointDeviceIds)}));
        
        if (spdsList.size() > 0) {
            mapDevListSvc.Clear();
            for(SupplyPointDeviceService__c spdsObj :spdsList){
                list<String > listServices = new List<String>();
                if (mapSPtoServ.containsKey(spdsObj.ServiceType__c) && mapSPtoServ.get(spdsObj.ServiceType__c) == spdsObj.ServiceType__c) {
                    setDevice.add(spdsObj.SupplyPointDevice__r.Device__c);
                    mapNew.put(spdsObj.SupplyPointDevice__c,spdsObj);
                    listServices.add(spdsObj.ServiceType__r.Name);
                    if (!mapDevListSvc.containsKey(spdsObj.SupplyPointDevice__c)) {
                        mapDevListSvc.put(spdsObj.SupplyPointDevice__c, listServices);
                    }
                    else{
                        List<String > listNew = mapDevListSvc.get(spdsObj.SupplyPointDevice__c);
                        listNew.add(spdsObj.ServiceType__r.Name);
                        mapDevListSvc.put(spdsObj.SupplyPointDevice__c, listNew);
                    }
                }    
            }
        }
        
        List<Reading__c> readList = new List<Reading__c>();   
        List<Device__c> devList = current ? [Select Id, SerialNo__c, Digit__c, 
                                             (Select Id, 
                                              ActualDeviceReading__c, 
                                              Device__c, 
                                              ReadingDate__c, 
                                              Reading__c, 
                                              ReadingMethod__c, 
                                              ReadingType__c,
                                              BillableType__c
                                              from Readings__r 
                                              where ReadingDate__c >= :readingDate 
                                              and ReadingDate__c <= :systemToday 
                                              ORDER BY ReadingDate__c Desc limit 1) 
                                             from Device__c 
                                             where Id IN :setDevice] 
            : [Select Id,SerialNo__c,Digit__c, 
               (Select Id, 
                ActualDeviceReading__c, 
                Device__c, 
                ReadingDate__c, 
                Reading__c, 
                ReadingMethod__c, 
                ReadingType__c 
                from Readings__r //AT-3174
                where ReadingDate__c <= :readingDate 
                ORDER BY ReadingDate__c Desc limit 1) 
               from Device__c 
               where Id IN :setDevice];
        List<Device__c> oldReadingDevice = new List<Device__c>();
        if (current) {
            oldReadingDevice = [Select Id, 
                                    (Select Id, 
                                        ActualDeviceReading__c, 
                                        Device__c, 
                                        ReadingDate__c, 
                                        Reading__c, 
                                        ReadingMethod__c, 
                                        ReadingType__c 
                                    from Readings__r //AT-3174
                                    ORDER BY ReadingDate__c Desc limit 1) 
                                from Device__c where Id IN :setDevice];
        }
        for (Device__c dev : oldReadingDevice ) {
            if (dev.Readings__r.size() > 0) {//AT-3174
                mapOldReading.put(dev.Id, dev.Readings__r[0]);
            }
        }
        for (Device__c devObj : devList){
            for (SupplyPointDevice__c spdObj : spdList) {
                if (spdObj.Device__c == devObj.id) {
                    mapDev.put(spdObj.id, devObj);
                }
                
            }
            if (devObj.Readings__r.size() > 0) { //AT-3174
                readList.AddAll(devObj.Readings__r);
                readMap.put(DevObj.Id, devObj.Readings__r[0]);
            }
        }
        return combinedList;
    }
    
    /**********************************************************************************************
    @author         Accenture: Manish Singh
    @date           16-Dec-2017
    @return         List<GLAp_FieldProps>
    @description    This method returns the field properties for each of the Transform fields that are
                    to be displayed on the screen
    **********************************************************************************************/
    private static List<GLAp_FieldProps> retrieveTransformFieldPropDetails() {
        List<GLAp_FieldProps> avlSrvItemsProps = new List<GLAp_FieldProps>();

        GLAp_FieldProps transFieldProp = new GLAp_FieldProps();
        transFieldProp.isFLSVisible = true;
        transFieldProp.isEncrypted = false;
        transFieldProp.isEditable = false;
        transFieldProp.isRequired = false;
        transFieldProp.fieldName = CuAp_Constants.SERVICETYPELBL;
        transFieldProp.fieldLabel = CuAp_Constants.SERVICETYPELBL;
        transFieldProp.fieldType = CuAp_Constants.TEXT;
        transFieldProp.transformField = true;
        transFieldProp.parentObject = GlUt_APIConstantsSPDService.SUPPLYPOINTSERVICEDEVICEAPINAME;
        avlSrvItemsProps.add(transFieldProp);

        return avlSrvItemsProps;
    }
}