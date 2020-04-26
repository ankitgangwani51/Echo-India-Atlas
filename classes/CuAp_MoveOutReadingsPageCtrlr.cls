/******************************************************************************
@author         Accenture: Manish Singh
@date           28 Nov 2017
@description    Component controller for move in reading lightning component (move out)
@version:       Shivangi Gaur -- 09-Jan-2018 -- Incorporated review comments on AT-1445 dated 08-01-2018.
Revision(s)		04 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class CuAp_MoveOutReadingsPageCtrlr{
    
    @testVisible private static List<string> spdFields;
    @testVisible private static List<string> spdsFields;
    @testVisible private static List<string> devFields;
    @testVisible private static List<string> supFields;
    @testVisible private static List<string> readFields;
    @testVisible private static List<string> currReadFields;
    private static map<Id, List<String>> mapDevListSvc = new map<Id, List<String>>();
    
    private static final String CLASS_NAME = 'CuAp_MoveOutReadingsPageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    @testVisible
	private static final List<String> supplyPointDeviceFields = new List<String>{
																				GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME, 
																				GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME, 
																				GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME
																				};      
    static{
        spdFields = new List<string>();
        spdFields.add(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME); 
    } 
    static{
        spdsFields = new List<string>();
        spdsFields.add(GlUt_APIConstantsSPDService.SERVICETYPEAPINAME);            
    }
    static{
        devFields = new List<string>();
        devFields.add(GlUt_APIConstantsDevice.SERIALNOAPINAME);
        devFields.add(GlUt_APIConstantsDevice.DIGITSAPINAME);            
    }
    static{
        supFields = new List<string>();
        supFields.add(GlUt_APIConstantsSupplyPoint.DEVICELOCATIONAPINAME);            
    }
    static{
        readFields = new List<string>();
        readFields.add(GlUt_APIConstantsReading.READINGDATEAPINAME);
        readFields.add(GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME);
        readFields.add(GlUt_APIConstantsReading.READINGMETHODAPINAME);   
        readFields.add(GlUt_APIConstantsReading.TRIPPEDAPINAME);   // AT-3421 core 8b
    }
    static{
        currReadFields = new List<string>();
        currReadFields.add(GlUt_APIConstantsReading.ACTUALDEVICEREADINGAPINAME);
        currReadFields.add(GlUt_APIConstantsReading.READINGMETHODAPINAME);     
    }
    
    /**********************************************************************************************
	@author         Accenture: Manish Singh
	@date           28-Nov-2017
	@param          List<string>
	@return         List<BlAp_CombinedRecord>
	@description    This method takes the available bundle ids selected to return details of device and
	reading data.
	**********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveReadingAndDevice(Id LocationId, String moveOutDate) {
        
        Date readingDate = Date.valueof(moveOutDate);
        List<BlAp_CombinedRecord> combinedList = new List<BlAp_CombinedRecord>();
        Set<Id> setSP = new SET<Id>();
        Set<Id> setAvSer = new Set<Id>();
        Set<Id> setServType = new Set<Id> ();
        Map<Id, Reading__c> readMap = new Map<Id, Reading__c>();
        Map<Id, Id> mapSPtoServ = new Map<Id, Id>();
        Set<Id> setSPDS = new Set<Id>();
        Set<Id> setDevice = new Set<Id>();
        Map<Id, SupplyPointDeviceService__c> mapNew = new Map<Id, SupplyPointDeviceService__c>();
        Map<Id, Device__c> mapDev = new Map<Id, Device__c>();
        Map<Id, SupplyPoint__c> mapSP = new Map<Id, SupplyPoint__c>();
        List<SupplyPointDeviceService__c> spdsList = new List<SupplyPointDeviceService__c>();
        
        try {
            GlUt_Logger.logDebug(DEBUG);
            String filterStatement = ' WHERE '+ GlUt_APIConstantsSupplyPoint.LOCATIONAPINAME +' =' + '\'' + LocationId + '\'';
            List<String> spFields = new List<String>();
            List<SupplyPoint__c> spRecords =  GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME,
                                                                                                  spFields,
                                                                                                  filterStatement);
            for(SupplyPoint__c SupplyPoint: spRecords){
                setSP.add(SupplyPoint.Id);            
            }
          
            List<SupplyPoint__c> spList = new List<SupplyPoint__c>();
            List<SupplyPointDevice__c> spdList = new List<SupplyPointDevice__c>();
            if (setSP.size() > 0) {
                spList = (List<SupplyPoint__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, 
                                                                                    supFields, 
                                                                                    'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(setSP));
                
                spdList = (List<SupplyPointDevice__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, 
                                                                                           supplyPointDeviceFields, 
                                                                                           String.format('WHERE {0} IN {1} AND {2} = true', 
                                                                                                         new List<String>{
                                                                                                             GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME, 
                                                                                                                 GlUt_FieldSecurity.IdsToString(setSP),
                                                                                                                 GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME}));
            }
            
            for(SupplyPoint__c sp: spList){
                mapSP.put(sp.Id,sp);
            }
            List<String> spdsFields = new List<String>();
            spdsFields.add(GlUt_APIConstantsSPDService.SUPPLYPOINTDEVICEAPINAME);
            spdsFields.add(GlUt_APIConstantsSPDService.SERVICETYPEAPINAME);
            List<Id> spdIds = new List<Id>();
            for(SupplyPointDevice__c spd: spdList){
                spdIds.add(spd.Id);
            }
            spdsList = (List<SupplyPointDeviceService__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSPDService.SUPPLYPOINTSERVICEDEVICEAPINAME, 
                                                                                    spdsFields, 
                                                                                    'WHERE '+ GlUt_APIConstantsSPDService.SUPPLYPOINTDEVICEAPINAME+ ' IN ' + GlUt_FieldSecurity.IdsToString(spdIds));
            List<Id> serviceTypeIds = new List<Id>();
            for(SupplyPointDeviceService__c spds: spdsList){
                serviceTypeIds.add(spds.ServiceType__c);
            }
            
            List<String> spdFields = new List<String>();
            spdFields.add(GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME);
            List<SupplyPointDevice__c> supplyPointDeviceList = new  List<SupplyPointDevice__c>();
            supplyPointDeviceList = (List<SupplyPointDevice__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, 
                                                                                    spdFields, 
                                                                                    'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(spdIds));
            for(SupplyPointDevice__c spd: supplyPointDeviceList){
                setDevice.add(spd.Device__c);
            }
            List<ServiceType__c> serviceTypeList = new List<ServiceType__c>();
            List<String> serviceTypeFields = new List<String>();
            serviceTypeFields.add(GlUt_APIConstantsServiceType.NAMEAPINAME);
            serviceTypeList = (List<ServiceType__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME, 
                                                                                    serviceTypeFields, 
                                                                                    'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(serviceTypeIds));
            Map<Id,ServiceType__c> mapOfServiceTypeId2ServiceType = new  Map<Id,ServiceType__c>();
            for(ServiceType__c sType: serviceTypeList){
                mapOfServiceTypeId2ServiceType.put(sType.Id,sType);
            }
            if (spdsList.size() > 0) {
                mapDevListSvc.Clear();
                for (SupplyPointDeviceService__c spdsObj : spdsList) {
                    list<String> listServices = new List<String>();                    
                    mapNew.put(spdsObj.SupplyPointDevice__c,spdsObj);
                    listServices.add(mapOfServiceTypeId2ServiceType.get(spdsObj.ServiceType__c).Name);
                    if (!mapDevListSvc.containsKey(spdsObj.SupplyPointDevice__c)) {
                        mapDevListSvc.put(spdsObj.SupplyPointDevice__c, listServices);
                    }
                    else {
                        List<String > listNew = mapDevListSvc.get(spdsObj.SupplyPointDevice__c);
                        listNew.add(mapOfServiceTypeId2ServiceType.get(spdsObj.ServiceType__c).Name);
                        mapDevListSvc.put(spdsObj.SupplyPointDevice__c, listNew);
                    }  
                }
            }
            
            List<Reading__c> readList = new List<Reading__c>();
            List<Device__c> devList = new List<Device__c>();
            devList = (List<Device__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsDevice.DEVICEAPINAME, 
                                                                                    devFields, 
                                                                                    'WHERE Id IN ' + GlUt_FieldSecurity.IdsToString(setDevice));
            readFields.add(GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME);
            readFields.add(GlUt_APIConstantsReading.READINGTYPEAPINAME);
            readFields.add(GlUt_APIConstantsReading.READINGAPINAME);
            List<Reading__c> readingList = new List<Reading__c>();
            DateTime readingDateFormat = Date.valueOf(moveOutDate);
            readingList = (List<Reading__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsReading.READINGAPINAME, 
                                                                                    readFields, 
                                                                                    'WHERE '+ GlUt_APIConstantsReading.READINGDATEAPINAME +' <=' + readingDateFormat.format('yyyy-MM-dd') + ' AND '+GlUt_APIConstantsReading.DEVICEREFERENCEAPINAME+ ' IN ' + GlUt_FieldSecurity.IdsToString(setDevice)+' ORDER BY ReadingDate__c Desc limit 1 ');
            Map<Id,Reading__c> mapOfDeviceId2Reading = new  Map<Id,Reading__c>();
            for(Reading__c reading: readingList){
                mapOfDeviceId2Reading.put(reading.Device__c,reading);
            }
   
            for(Device__c devObj : devList){
                for(SupplyPointDevice__c spdObj : spdList){
                    if(spdObj.Device__c == devObj.id){
                        mapDev.put(spdObj.id,devObj);
                    }
                }
                if(mapOfDeviceId2Reading.get(devObj.Id) != null){ //AT-3174
                    readList.Add(mapOfDeviceId2Reading.get(devObj.Id));
                    readMap.put(DevObj.Id,mapOfDeviceId2Reading.get(devObj.Id));
                }
            }
            
            for(SupplyPointDevice__c spdObj : spdList){
                Reading__c readObjEstimation = new Reading__c();
                SupplyPointDeviceService__c spdObjNew = new SupplyPointDeviceService__c();
                Device__c devObjNew = new Device__c();
                SupplyPoint__c supObj = new SupplyPoint__c();
                Reading__c readObj = new Reading__c();
                if(mapNew.containskey(spdObj.id)){
                    spdObjNew = mapNew.get(spdObj.id);
                }
                if(mapDev.containskey(spdObj.id)){
                    devObjNew = mapDev.get(spdObj.id);
                    if(readMap.containsKey(devObjNew.id)){
                        readObj = readMap.get(devObjNew.id);
                    }
                }
                
                String commaSepratedNames = '';
                if(mapDevListSvc.containskey(spdObj.id)){
                    for(string avlSrvItm : mapDevListSvc.get(spdObj.Id)){
                        commaSepratedNames += avlSrvItm  + '\n' ;
                    }
                }
                commaSepratedNames = commaSepratedNames.subString(0, commaSepratedNames.length()); 
                if(mapSP.containsKey(spdObj.SupplyPoint__c)){
                    supObj = mapSP.get(spdObj.SupplyPoint__c);
                }
                BlAp_CombinedRecord combRecord = new BlAp_CombinedRecord();            
                combRecord.uniqueId=spdObj.Id;
                combRecord.isSelected = true;
                combRecord.objectMap = new Map<string, sObject>();
                combRecord.objectMap.put(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, spdObj);
                combRecord.objectMap.put(GlUt_APIConstantsSPDService.SUPPLYPOINTSERVICEDEVICEAPINAME, spdObjNew);
                combRecord.objectMap.put(GlUt_APIConstantsDevice.DEVICEAPINAME, devObjNew);
                combRecord.objectMap.put(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, supObj);
                combRecord.objectMap.put(GlUt_APIConstantsReading.READINGAPINAME, readObj);
                combRecord.objectMap.put(GlUt_APIConstantsReading.READINGAPINAME + '1', 
                                         new Reading__c(Device__c = devObjNew.Id, 
                                                        ReadingType__c = CuAp_Constants.MOVEOUT,
                                                        ReadingDate__c = readingDate, 
                                                        ReadingSource__c = CuAp_Constants.CUSTOMERREADING, 
                                                        ReadingMethod__c = '',
                                                        Tripped__c = false));       // AT-3421 core 8b              
                combRecord.objectMap.put(GlUt_APIConstantsReading.READINGAPINAME + '2', 
                                         new Reading__c(Device__c = devObjNew.Id, 
                                                        ReadingType__c = CuAp_Constants.MOVEOUT,
                                                        ReadingDate__c = readingDate, 
                                                        ReadingSource__c = CuAp_Constants.CUSTOMERREADING, 
                                                        ReadingMethod__c = ''));
                Map<string, string> contrtransFormFieldMap = new Map<string, string>();
                contrtransFormFieldMap.put(CuAp_Constants.SERVICETYPELBL,commaSepratedNames);
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
	@author         Accenture: Manish Singh
	@date           28-Nov-2017
	@return         List<GLAp_FieldProps>
	@description        This method returns the field properties for each of the fields that are
	to be displayed on the screen
	**********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveSupFieldPropDetails() {
        
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        try {
            GlUt_Logger.logDebug(DEBUG);
            List<GLAp_FieldProps> spdProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTDEVICEAPINAME, spdFields);
            
            List<GLAp_FieldProps> spdsProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsSPDService.SUPPLYPOINTSERVICEDEVICEAPINAME, spdsFields);
            
            List<GLAp_FieldProps> devProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDevice.DEVICEAPINAME, devFields);
            
            List<GLAp_FieldProps> spProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsSupplyPoint.SUPPLYPOINTAPINAME, supFields);
            
            List<GLAp_FieldProps> readProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReading.READINGAPINAME, readFields);
            List<GLAp_FieldProps> readPropsNew = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsReading.READINGAPINAME, currReadFields);
            
            //Add in button fields
            GLAp_FieldProps buttonFieldProp1 = new GLAp_FieldProps();
            buttonFieldProp1.isFLSVisible = true;
            buttonFieldProp1.isEncrypted = false;
            buttonFieldProp1.isEditable = false;
            buttonFieldProp1.isRequired = false;
            buttonFieldProp1.fieldName = CuAp_Constants.ESTIMATE;
            buttonFieldProp1.fieldLabel = CuAp_Constants.ESTIMATE;
            buttonFieldProp1.buttonField = true;
            readProps.Add(buttonFieldProp1);
            List<GLAp_FieldProps> avlSrvItemsProps = retrieveTransformFieldPropDetails();    
            for(GLAp_FieldProps prop :readPropsNew){
                if(prop.parentObject == GlUt_APIConstantsReading.READINGAPINAME ){
                    prop.parentObject = GlUt_APIConstantsReading.READINGAPINAME + '1' ;  
                }
            }        
            for(GLAp_FieldProps spdProp: spdProps){
                spdProp.isEditable = false;
            }
            
            for(GLAp_FieldProps spdsProp: spdsProps){
                spdsProp.isEditable = false;
            }
            for(GLAp_FieldProps devProp: devProps){
                devProp.isEditable = false;
            }
            for(GLAp_FieldProps spProp: spProps){
                spProp.isEditable = false;
            }
            for(GLAp_FieldProps readProp: readProps){
                readProp.isEditable = false;
                if(readProp.fieldLabel == CuAp_Constants.ACTUALREADINGLABEL){
                    readProp.fieldLabel = System.Label.CuAp_PreviousReading;
                }
                if(readProp.fieldLabel == CuAp_Constants.READINGMETHODLABEL){
                    readProp.fieldLabel = System.Label.CuAp_PreviousReadingMethod;
                }
                if(readProp.fieldLabel == CuAp_Constants.READINGDATELABEL){
                    readProp.fieldLabel = System.Label.CuAp_PreviousReadingDate;
                }
                if(readProp.fieldLabel == CuAp_Constants.TRIPPEDLABEL){  // AT-3421 core 8b
                    readProp.isEditable = true;
                    readProp.parentObject = GlUt_APIConstantsReading.READINGAPINAME + '1' ;
                }
            }
            for(GLAp_FieldProps readProp: readPropsNew){
                if(readProp.fieldLabel == CuAp_Constants.ACTUALREADINGLABEL){
                    readProp.fieldLabel = System.Label.CuAp_MoveOutReading;
                }
                if(readProp.fieldLabel == CuAp_Constants.READINGMETHODLABEL){
                    readProp.fieldLabel = System.Label.CuAp_MoveOutReadingMethod;
                }
            }
            //Build a map list of all field properties        
            
            for(GLAp_FieldProps fldProp : spdProps){            
                
                fldPropList.add(fldProp);                           
            }       
            for(GLAp_FieldProps fldProp : devProps){            
                
                fldPropList.add(fldProp);                           
            }
            
            for(GLAp_FieldProps fldProp : avlSrvItemsProps){            
                fldPropList.add(fldProp);                           
            }  
            
            for(GLAp_FieldProps fldProp : spProps){            
                
                fldPropList.add(fldProp);                           
            }
            for(GLAp_FieldProps fldProp : readProps){            
                
                fldPropList.add(fldProp);                           
            }
            for(GLAp_FieldProps fldProp : readPropsNew){            
                
                fldPropList.add(fldProp);                           
            }
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
	@date           16-Dec-2017
	@return         List<GLAp_FieldProps>
	@description        This method returns the field properties for each of the Transform fields that are
	to be displayed on the screen
	**********************************************************************************************/
    private static List<GLAp_FieldProps> retrieveTransformFieldPropDetails() {
        List<GLAp_FieldProps> avlSrvItemsProps = new List<GLAp_FieldProps>();
        GLAp_FieldProps transFieldProp = new GLAp_FieldProps();
        transFieldProp.isFLSVisible = true;
        transFieldProp.isEncrypted = false;
        transFieldProp.isEditable = false;
        transFieldProp.isRequired = false;
        transFieldProp.fieldName = CuAp_Constants.SERVICETYPELBL ;
        transFieldProp.fieldLabel = CuAp_Constants.SERVICETYPELBL ;
        transFieldProp.fieldType = CuAp_Constants.TEXT ;
        transFieldProp.transformField = true;
        transFieldProp.parentObject = GlUt_APIConstantsSPDService.SUPPLYPOINTSERVICEDEVICEAPINAME;
        avlSrvItemsProps.add(transFieldProp);
        return avlSrvItemsProps;
    }
}