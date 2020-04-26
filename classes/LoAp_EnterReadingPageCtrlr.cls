/******************************************************************************
@author    		Echo: Tarun Gupta
@date      		20-Nov-2017
@description 	Component controller for Enter Reading wizard

Revisions		09 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
*******************************************************************************/
public with sharing class LoAp_EnterReadingPageCtrlr {
    
    private static final String CLASS_NAME = 'LoAp_EnterReadingPageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    /**********************************************************************************************
    @author      : Echo: Tarun
    @date        : 20-Nov-2017
    @return      : List<String>
@description : This method returns the picklist field values for Reading Type field from Reading object
**********************************************************************************************/
    //get the picklist options of Occupancy Type field of the Location Occupant object
    @AuraEnabled
    public static Map<String,List<String>> picklistvaluesnew(){        
        
        Map<String,List<String>> mapWrapper = new Map<String,List<String>>();
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG );
            for(String lstobj : CuAp_Constants.FIELDNAME){            
                List<String> returnOptionsList = new List<String>();
                List<GlAp_FieldProps> fldProps = GlUt_FieldSecurity.getFieldPropertiesObject(CuAp_Constants.OBJECTNAME,new List<String>{lstobj});
                for(GlAp_FieldProps fp : fldProps){
                    if(fp.isFLSVisible){ 
                        returnOptionsList.add('');
                        for(String optionVal : fp.pickListEntries.Values()){
                            if(optionVal != ''){
                                returnOptionsList.add(optionVal);
                            }
                        }
                    }
                }                        
                mapWrapper.put(lstobj, returnOptionsList);            
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return mapWrapper;        
    }
    
    /**********************************************************************************************
    @author      : Echo: Tarun
    @date        : 21-Nov-2017
    @return      : List<String>
@description : This method returns the Device,Reading,SPDS,Service Type values 
**********************************************************************************************/    
    @AuraEnabled
    public static WrapSelectDevice fetchdevicedata(Id deviceId, String screenFinalOrInstall){        
        
        //Wrapper class to set values
        WrapSelectDevice objWrap = new WrapSelectDevice();
        try {
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG );
            
            List<String> deviceFields = new List<string>{
                GlUt_APIConstantsDevice.SERIALNOAPINAME,
                    GlUt_APIConstantsDevice.DEVICETYPEAPINAME,
                   // GlUt_APIConstantsDevice.DEVICEREFERNCEAPINAME, --AT -3174
                    GlUt_APIConstantsDevice.DIGITSAPINAME
                    }; 
                        
                        //Fetch Device Details
                        Device__c device = (Device__c) GlAp_LightningDataAccess.getRecord(GlUt_APIConstantsDevice.DEVICEAPINAME, 
                                                                                          deviceId, 
                                                                                          deviceFields);
            
            if (device.Id != null) {            
                
                objWrap.deviceValues = device;             
                
                // This check is for screen WS2 only as Service Type is not required on WS4
                if (screenFinalOrInstall == 'FINAL') {
                    
                    List<String> supplyPointDeviceServiceFields = new List<String>{      
                        GlUt_APIConstantsSPDService.SERVICETYPERELAPINAME + '.Name', 
                            GlUt_APIConstantsSPDService.SUPPLYPOINTDEVICERELAPINAME + '.Name', 
                            GlUt_APIConstantsSPDService.SUPPLYPOINTDEVICERELAPINAME + '.' + GlUt_APIConstantsSupplyPointDevice.INSTALLATIONDATEAPINAME, 
                            GlUt_APIConstantsSPDService.SUPPLYPOINTDEVICERELAPINAME + '.' + GlUt_APIConstantsSupplyPointDevice.SUPPLYPOINTAPINAME 
                            };
                                List<SupplyPointDeviceService__c> lstSPDS 
                                = (List<SupplyPointDeviceService__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsSPDService.SUPPLYPOINTSERVICEDEVICEAPINAME, 
                                                                                                          supplyPointDeviceServiceFields, 
                                                                                                          deviceId, 
                                                                                                          GlUt_APIConstantsSPDService.SUPPLYPOINTDEVICERELAPINAME + '.' + GlUt_APIConstantsSupplyPointDevice.DEVICEAPINAME, 
                                                                                                          GlUt_APIConstantsSPDService.SUPPLYPOINTDEVICERELAPINAME + '.' + GlUt_APIConstantsSupplyPointDevice.ACTIVEAPINAME + ' = true');
                    
                    if (lstSPDS.size() > 0) {     
                        
                        Date installDate = lstSPDS[0].SupplyPointDevice__r.InstallationDate__c;
                        objWrap.installDate = installDate;                    
                        String servicetype = '';
                        
                        for(SupplyPointDeviceService__c obj : lstSPDS){                          
                            servicetype = servicetype + ':' + obj.ServiceType__r.Name; 
                        } 
                        //Removing Extra colon: in starting
                        servicetype = servicetype.substring(1,servicetype.length());
                        objWrap.servicetype = servicetype;  
                    }                
                } 
                
                // Fetching latest Reading against device                
                List<Reading__c> lstReadings = [SELECT ActualDeviceReading__c,ReadingMethod__c FROM Reading__c WHERE Device__c =: deviceId ORDER BY ReadingDate__c DESC LIMIT 1];   
                
                if(lstReadings.size() > 0){
                    objWrap.readingValues = lstReadings[0];
                }             
            }
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        
        return objWrap;
    }
    
    /******************************************************************************
    @author      	Echo: Tarun Gupta
    @date      		07-Nov-2017
    @param			none
    @return			none
    @description	wrapper class to hold the Reading & Device information
    *******************************************************************************/
    public class WrapSelectDevice{
        
        @AuraEnabled public Device__c deviceValues;                
        @AuraEnabled public Reading__c readingValues; 
        @AuraEnabled public String servicetype;
        @AuraEnabled public Date installDate;
        
        public WrapSelectDevice(){
            this.deviceValues = new Device__c();             
            this.readingValues = new Reading__c();
        } 
    }    
}