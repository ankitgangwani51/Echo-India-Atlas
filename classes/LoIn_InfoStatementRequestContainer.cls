/******************************************************************************
@author         Echo: Sudhir Kumar
@date           29 Oct 2018
@description    Container class for JSON Information Statement Request Payload
				AT-4127 (AU1): Salesforce Statement payload
******************************************************************************/

/******************************************************************************
Object Hierarchy
----------------
[SFDC Name (DTO Name)]
InformationStatement__c (Information Statement)
Location__c (LocationID)
	-> SupplyPoint__c (SupplyPoints)
		-> SupplyPointDevices
			-> Device (ServiceDevice)
				-> Readings (ServiceReadings)
	 
******************************************************************************/

public with sharing class LoIn_InfoStatementRequestContainer {
    
    private static final String CLASS_NAME = 'LoIn_InfoStatementRequestContainer';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    //Utility methods used to format date and datetime fields for json as yyyy-MM-dd HH:mm:ss
    private static String dateToString(Date d) {return d != null ? String.valueOf(d) + ' 00:00:00' : null;} 
    private static String dateToString(DateTime dt) {return dt != null ? String.valueOf(dt) : null;}    
    
    //the records required for Info Statement payload
    public list<SupplyPoint__c> SupplyPoints ;
    private list<SupplyPointDevice__c> SupplyPointDevices ;
    private list<Device__c> Devices ;
    private list<Reading__c> Readings ;
    private map<Id, Device__c> mapDeviceId2DeviceObj ;
    
    //Structured Information Statement data
    public LoIn_InfoStatementRequestContainer requestData {get; private set;} 
    
    public LoIn_InfoStatementRequestContainer(set<Id> locationIds) {
        //Step 1. Get all required data
        system.debug('locationIds= ' + locationIds) ;
        //Get Supply Point records
        SupplyPoints = getSupplyPoints(locationIds) ;
        system.debug('SupplyPoints= ' + SupplyPoints) ;
        set<Id> setSupplyPointId = new set<Id>() ;
        for(SupplyPoint__c supplyPoint : SupplyPoints) {
            setSupplyPointId.add(supplyPoint.Id) ;
        }
        
        //Get Supply Point Device records
        SupplyPointDevices = getSupplyPointDevices(setSupplyPointId) ;
        system.debug('SupplyPointDevices= ' + SupplyPointDevices) ;
        set<Id> setDeviceId = new set<Id>() ;
        for(SupplyPointDevice__c supplyPointDevice : SupplyPointDevices) {
            setDeviceId.add(supplyPointDevice.Device__c) ;
        }
        system.debug('setDeviceId= ' + setDeviceId) ;
        //Get Device records
        Devices = getDevices(setDeviceId) ;
        system.debug('Devices= ' + Devices) ;
        mapDeviceId2DeviceObj = new map<Id, Device__c>() ;
        for(Device__c device : Devices) {
            mapDeviceId2DeviceObj.put(device.Id, device) ;
        }
        system.debug('mapDeviceId2DeviceObj= ' + mapDeviceId2DeviceObj) ;
        //Get Reading records
        Readings = getReadings(setDeviceId) ;
        system.debug('Readings= ' + Readings) ;
    }
    
    /* METHODS FOR STEP 1: get all the data records required */
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           29 Oct 2018
    @param          Id - location Ids
    @return         List<SupplyPoint__c> - supply point
    @description    gets all the supply point  related records
    *******************************************************************************/
    private list<SupplyPoint__c> getSupplyPoints(set<Id> locationIds) {
        return [SELECT Id from SupplyPoint__c WHERE Location__c IN: locationIds] ;
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           29 Oct 2018
    @param          Id - supplyPointId Ids
    @return         List<SupplyPointDevice__c> - supply point device
    @description    gets all the supply point device related records
    *******************************************************************************/
    private list<SupplyPointDevice__c> getSupplyPointDevices(set<Id> supplyPointIds) {
        return [SELECT Id, Device__c, SupplyPoint__c from SupplyPointDevice__c WHERE SupplyPoint__c IN: supplyPointIds AND Active__c = true] ;
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           29 Oct 2018
    @param          Id - supplyPointDeviceId Ids
    @return         List<Device__c> -  device
    @description    gets all the device related records
    *******************************************************************************/
    private list<Device__c> getDevices(set<Id> DeviceIds) {
        return [SELECT Id, Name from Device__c WHERE Id IN: DeviceIds] ;	//add other fields if required
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           29 Oct 2018
    @param          Id - Info Statement Ids
    @return         List<Reading__c> - list of Reading
    @description    gets all the supply point  related records
    *******************************************************************************/
    private list<Reading__c> getReadings(Id InfoStatementId) {
        return [SELECT Id, Name, Device__c, ReadingDate__c, ReadingMethod__c, Reading__c, ReadingType__c FROM Reading__c Where InformationStatement__c =: InfoStatementId] ;
    }
    private list<Reading__c> getReadings(set<Id> deviceIds) {
        return [SELECT Id, Name, Device__c, ReadingDate__c, ReadingMethod__c, Reading__c, ReadingType__c, InformationStatement__c 
                FROM Reading__c Where Device__c =: deviceIds] ; // removed during packaging -  AND ReadingType__c =: LoAp_Constants.INFORMATION_STATEMENT
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           29 Oct 2018
    @description    Subclass for SupplyPointObj JSON Object
    *******************************************************************************/
    @TestVisible
    public class SupplyPoint {
        @TestVisible private String SupplyPointId ;
        @TestVisible private list<SupplyPointDevice> SupplyPointDevices ;
        
        public SupplyPoint (LoIn_InfoStatementRequestContainer container, SupplyPoint__c supplyPointObj, String infoStatementId) {
            SupplyPointId = supplyPointObj.Id ;
            SupplyPointDevices = new list<SupplyPointDevice>() ;
            for(SupplyPointDevice__c spd : container.SupplyPointDevices) {
                if(spd.SupplyPoint__c == SupplyPointId) {
                    SupplyPointDevices.add(new SupplyPointDevice(container, spd, infoStatementId)) ;
                }
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           29 Oct 2018
    @description    Subclass for SupplyPointDevice
    *******************************************************************************/
    private class SupplyPointDevice {
        
        private String SupplyPointDeviceId ;
		private Device ServiceDevice ;
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           29 Oct 2018
        @param          LoIn_InfoStatementRequestContainer - instance of the container class
        @param          SupplyPointDevice__c - supplyPointDevice record
        @description    Constructor
        *******************************************************************************/
        private SupplyPointDevice(LoIn_InfoStatementRequestContainer container, SupplyPointDevice__c supplyPointDevice, String infoStatementId) {
            
            // add the fields to this DTO
			SupplyPointDeviceId 	= supplyPointDevice.Id ;
            Device__c thisDevice 	= container.mapDeviceId2DeviceObj.containsKey(supplyPointDevice.Device__c) ? container.mapDeviceId2DeviceObj.get(supplyPointDevice.Device__c) : null ;
            if(thisDevice != null) ServiceDevice = new Device(container, thisDevice, infoStatementId) ;
            // build the list of average daily use DTOs
          
            
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           29 Oct 2018
    @description    Subclass for  Device
    *******************************************************************************/
    private  class Device {
        private String ServiceDeviceId ;
        private String Name ;
        private List<Reading> ServiceReadings;  

        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           29 Oct 2018
        @param          LoIn_InfoStatementRequestContainer container, 
        @param          Device__c device - device record 
        @description    Constructor
        *******************************************************************************/
        private Device(LoIn_InfoStatementRequestContainer container, Device__c device, String infoStatementId) {
            Name = device.Name ;
            ServiceDeviceId = device.Id ;
            ServiceReadings = new List<Reading>();  
            for (Reading__c thisReading : container.Readings) { 
                if (thisReading.InformationStatement__c == infoStatementId && thisReading.Device__c == device.Id) {		//Sudhir : 28/112018
                    ServiceReadings.add(new Reading(container, thisReading, infoStatementId));
                }
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           29 Oct 2018
    @description    Subclass for Reading
    *******************************************************************************/
    private class Reading {
        private String ServiceReadingId ;
        private Decimal Reading;
        private String ReadingDate;
        private String ReadingMethod;
        private String ReadingType; 

        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           29 Oct 2018
        @param          Reading__c - reading record
        @description    Constructor
        *******************************************************************************/
        private Reading(LoIn_InfoStatementRequestContainer container, Reading__c reading,  String infoStatementId) {
            
            // add the fields to this DTO
            system.debug('reading.InformationStatement= ' + reading.InformationStatement__c);
            system.debug('infoStatementId= ' + infoStatementId);
            if(reading.InformationStatement__c == infoStatementId) {
                ServiceReadingId = reading.Id ;
                this.Reading = reading.Reading__c;
                ReadingDate = dateToString(reading.ReadingDate__c);
                ReadingMethod = reading.ReadingMethod__c; 
                ReadingType = reading.ReadingType__c;	
            }
        }
    }
}