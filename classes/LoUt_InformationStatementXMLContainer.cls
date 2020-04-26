/**********************************************************************************************
@author         Echo: Sudhir Kumar
@date           30 Oct 2018
@description    A data transfer object (DTO) class used to create an instance 
                of the data extracted from Salesforce Information Statement records to format the 
                XML message which is passed to the AWS S3 "echo-data-transfer-xml" bucket
                AT-4099 (AU1): PDF XML structure defined for information statements
Revision(s)     Tarun Gupta , AT_4858 , Added DPID fields
                Sudhir Kumar, AT-5324: #3 Display the Relevant latest Accural Bill
***********************************************************************************************/

/************************************************************************************************
 
Object Hierarchy
----------------

-> InformationStatements (start root tag)
    ->  InformationStatement (Individual InformationStatement)* 
            ->  PdfTemplateName - (taken directly from the information statement record)
            ->  XsltName    - (Retrieve using Template Setting) // The xslt that is linked to the relevant Template record.
            -> Location
                -> Location Occupant    // For each of the active location occupant records where the occupation type is "Owner" or "Landlord"
                -> Supply Point
                    -> Supply Point Device // Active one
                        -> Devices
                            -> Reading  // latest Billable reading that has been billed for this device
            -> Reading  // latest reading marked as “information statement” that is linked to the current Information Statement
            -> Accrual Bill
                -> Accrual Bill Item
                    -> Service Item type (by following this path: Accrual Bill item -> service Item -> Service item Type)
            -> Information Statement Messages
    ->  InformationStatement (InformationStatement)* 
-> InformationStatements (end root tag)

************************************************************************************************/

public with sharing class LoUt_InformationStatementXMLContainer implements GlUt_DataTransferXmlInterface {
    
    private static final String CLASS_NAME = 'LoUt_InformationStatementXMLContainer';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    // utility methods used to format date as yyyy-MM-dd HH:mm:ss
    private static String dateToString(Date d) {return d != null ? String.valueOf(d) + ' 00:00:00' : null;}
    private static String decimalToString(Decimal d) {return d != null ? String.valueOf(d) : null;}
    private static String integerToString(Integer d) {return d != null ? String.valueOf(d) : null;}
    
    public InformationStatements structuredInfoStatementData {get; private set;}        
    public String xmlInfoStatementData {get; private set;}                      
    
    // the records required for the data payload
    private List<InformationStatement__c> informationStatements ;
    private List<Location__c> locations ;
    private List<LandTitle__c> landTitle ;   //AT-5334
    private List<LocationOccupant__c> locationOccupants ;  
    private List<SupplyPoint__c> supplyPoints ;
    private List<SupplyPointDevice__c> supplyPointDevices ;
    private List<Device__c> devices ;
    private List<Reading__c> readings ;
    private List<AccrualBill__c> accrualBills ;
    private List<AccrualBillItem__c> accrualBillItems ;
    private List<InformationStatementMessage__c> informationStatementMessages ;
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           30 Oct 2018
    @param          String
    @description    Implemented method of GlUt_DataTransferXmlInterface
    *******************************************************************************/
    public String getDataTransferXmlString(list<InformationStatement__c> listInfoStatements) {
        system.debug('Entry-LoUt_InformationStatementXMLContainer Constructor');
        // Variables initilization
        
        prepareInfoStatementDataXML(listInfoStatements) ;
        system.debug('Exit-LoUt_InformationStatementXMLContainer Constructor');
        return xmlInfoStatementData ;
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           30 Oct 2018
    @param          list<InformationStatement__c> listInfoStatements
    @return         void
    @description    Builds the XML data
    *******************************************************************************/
    private void prepareInfoStatementDataXML(list<InformationStatement__c> listInfoStatements) {
        system.debug('Entry-prepareInfoStatementDataXML');
        
        /** STEP 1: Get all the data records required **/
        
        //Get Information Statement
        set<Id> setLocationIds = new set<Id>() ;
        set<Id> setInfoStatementIds = new set<Id>() ;
        //informationStatements = getInformationStatements(setInfoStatementIds) ;
        system.debug('Sudhir informationStatements=> ' + informationStatements);
        //for(InformationStatement__c info : informationStatements) {
        for(InformationStatement__c info : listInfoStatements) {
            setLocationIds.add(info.Location__c) ;
            setInfoStatementIds.add(info.Id) ;
        }
        system.debug('Sudhir setLocationIds=> ' + setLocationIds);
        //Get Location
        locations = getLocations(setLocationIds) ;
        system.debug('Sudhir locations=> ' + locations);
        //Get Land Title
        landTitle   = getLandTitle(setLocationIds);  //AT-5334
        system.debug(' landTitle=> ' + landTitle);
        
        //Get Location Occupant
        locationOccupants = getLocationOccupants(setLocationIds) ;     
        system.debug('Sudhir locationOccupants=> ' + locationOccupants);
        //Get Supply Points
        supplyPoints = getSupplyPoints(setLocationIds) ;
        system.debug('Sudhir supplyPoints=> ' + supplyPoints);
        //Get Supply Point Devices
        supplyPointDevices = getSupplyPointDevices(setLocationIds) ;
        system.debug('Sudhir supplyPointDevices=> ' + supplyPointDevices);
        set<Id> setDeviceIds = new set<Id>() ;
        for(SupplyPointDevice__c spd : supplyPointDevices) {
            setDeviceIds.add(spd.Device__c) ;
        }
        system.debug('Sudhir setDeviceIds=> ' + setDeviceIds);
        //Get Device
        devices = getDevices(setDeviceIds) ;
        system.debug('Sudhir devices=> ' + devices);
        //Get Reading
        readings = getReadings(setDeviceIds) ;
        system.debug('Sudhir readings=> ' + readings);
        //Get Accrual Bill
        set<Id> setAccrualBillIds = new set<Id>() ;
        accrualBills = getAccrualBills(setInfoStatementIds) ;
        /*
        for(AccrualBill__c aBill : accrualBills) {
            setAccrualBillIds.add(aBill.Id) ;
        }
        */
        system.debug('Sudhir setAccrualBillIds=> ' + setAccrualBillIds);
        //Get latest Accrual Bill Items
        String latestAccrualBillId = null ;
        //accrualBillItems = getAccrualBillItems(setAccrualBillIds) ;
        if(accrualBills != null && !accrualBills.isEmpty()) {
            latestAccrualBillId = accrualBills[0].Id ;
        }
        
        if(!String.isBlank(latestAccrualBillId)) {
            accrualBillItems = getAccrualBillItems(latestAccrualBillId) ;
        }
        system.debug('Sudhir latestAccrualBillId=> ' + latestAccrualBillId);    
        system.debug('Sudhir accrualBillItems=> ' + accrualBillItems);
        //Get Info Statement Messages
        informationStatementMessages = getInformationStatementMessages(setInfoStatementIds) ;
        system.debug('Sudhir informationStatementMessages=> ' + informationStatementMessages);
        
        /** STEP 2: Build Structured Information Statement Data using the DTO hierachy **/
        
        //structuredInfoStatementData = new InformationStatements(this, informationStatements) ;
        structuredInfoStatementData = new InformationStatements(this, listInfoStatements) ;
        system.debug('structuredInfoStatementData=> ' + structuredInfoStatementData);
        
        /** STEP 3: Prepare Information Statement XML **/
        
        // serialise the InformationStatement structured data
        xmlInfoStatementData = GlUt_XMLSerialiser.serialize((Object) structuredInfoStatementData) ;
        system.debug('xmlInfoStatementData=> ' + xmlInfoStatementData) ;
        
        GlUt_Logger.logDebug(DEBUG + 'xmlInfoStatementData: ' + xmlInfoStatementData) ;
        GlUt_Logger.logDebug(DEBUG + 'Heap Size Used: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize() 
                + ' (' + ((Limits.getHeapSize() * 100) / Limits.getLimitHeapSize()) + '%)');
        GlUt_Logger.logDebug(DEBUG + 'CPU Time Used: ' + Limits.getCpuTime()  + '/' + Limits.getLimitCpuTime()
                + ' (' + ((Limits.getCpuTime() * 100) / Limits.getLimitCpuTime()) + '%)');
        system.debug('Exit-prepareInfoStatementDataXML');
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           31 Oct 2018
    @param          set<Id> setInfoStatementIds
    @return         List<InformationStatement__c> - Information Statements
    @description    get the Information Statement records
    *******************************************************************************/
    /*
    private List<InformationStatement__c> getInformationStatements(set<Id> setInfoStatementIds) {
        return  [SELECT Id, Name, Template__c, SettlementDate__c, AmountDue__c, SchemeArrears__c, CalculatedCharges__c, 
                LocationBalance__c, Type__c, SolicitorName__c, IssueDate__c, SupplyAddress__c, Location__c,
                BillingContract__c, BillingContract__r.AccountName__c, BillingContract__r.AccountName__r.AuDpid__c, BillingContract__r.BillingAuDpid__c, BillingContract__r.AlternativeAuDpid__c
                FROM InformationStatement__c 
                WHERE Id IN: setInfoStatementIds];
    }
    */
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           31 Oct 2018
    @param          set<Id> setLocationIds
    @return         List<Location__c> - Locations
    @description    get the Location records
    *******************************************************************************/
    private List<Location__c> getLocations(set<Id> setLocationIds) {
        return  [SELECT Id, Name, TitleAddress__c, AuDPID__c
                FROM Location__c 
                WHERE Id IN: setLocationIds];
    }
    
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           28 Feb 2019
    @param          set<Id> setLocationIds
    @return         List<LandTitle__c> - Land Title
    @description    get the Land Title records
    *******************************************************************************/
    private List<LandTitle__c> getLandTitle(set<Id> setLocationIds) {   //At-5334
        return  [SELECT Id, Location__c, Name, FolioNumber__c, Type__c, VolumeNumber__c
                FROM LandTitle__c 
                WHERE Location__c IN: setLocationIds];
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           31 Oct 2018
    @param          set<Id> setLocationIds
    @return         List<Location__c> - Locations
    @description    get the Location records
    *******************************************************************************/
    private List<LocationOccupant__c> getLocationOccupants(set<Id> setLocationIds) {
        List<String> listOccupationType = new List<String>{LoAp_Constants.LANDLORD,LoAp_Constants.OWNER} ; // ToDo: use constant class here
        return  [SELECT Id, Name, Location__c
                FROM LocationOccupant__c 
                WHERE Location__c IN: setLocationIds AND Active__c = true AND OccupancyType__c IN: listOccupationType];  
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           31 Oct 2018
    @param          set<Id> setSupplyPoints
    @return         List<SupplyPoint__c> - SupplyPoints
    @description    get the SupplyPoint records // Currently only Id is being returned. Add additional fields if required in future scope.
    *******************************************************************************/
    private List<SupplyPoint__c> getSupplyPoints(set<Id> setLocationIds) {
        return  [SELECT Id, Location__c
                FROM SupplyPoint__c 
                WHERE Location__c IN: setLocationIds];  
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           31 Oct 2018
    @param          set<Id> setLocationIds
    @return         List<SupplyPointDevice__c> - SupplyPointDevices
    @description    get the SupplyPointDevice records // Currently only Id is being returned. Add additional fields if required in future scope.
    *******************************************************************************/
    private List<SupplyPointDevice__c> getSupplyPointDevices(set<Id> setLocationIds) {
        return  [SELECT Id, Device__c, SupplyPoint__c, SupplyPoint__r.Location__c
                FROM SupplyPointDevice__c 
                WHERE SupplyPoint__r.Location__c IN: setLocationIds AND Active__c = true];  
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           31 Oct 2018
    @param          set<Id> setDeviceIds
    @return         List<Device__c> - Devices
    @description    get the Device records // Currently only Id is being returned. Add additional fields if required in future scope.
    *******************************************************************************/
    private List<Device__c> getDevices(set<Id> setDeviceIds) {
        return  [SELECT Id, Name, DeviceType__c, SerialNo__c, DeviceType__r.Manufacturer__c, LoadReference__c, DeviceType__r.DeviceSize__r.Name, Digit__c
                FROM Device__c 
                WHERE Id IN: setDeviceIds];  
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           31 Oct 2018
    @param          set<Id> setDeviceIds
    @return         List<Device__c> - Readings
    @description    get the Reading records // Currently only Id is being returned. Add additional fields if required in future scope.
    *******************************************************************************/
    private List<Reading__c> getReadings(set<Id> setDeviceIds) {
        return  [SELECT Id, ReadingDate__c, Reading__c, ReadingType__c, Billed__c, BillableType__c, Device__c, InformationStatement__c
                FROM Reading__c 
                WHERE Device__c IN: setDeviceIds 
                AND ((BillableType__c =: GlUt_Constants.BILLABLE AND Billed__c = true) OR (ReadingType__c =: LoAp_Constants.INFORMATION_STATEMENT OR ReadingType__c =: GlUt_Constants.MOVEIN))
                ORDER BY ReadingDate__c DESC] ;  
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           31 Oct 2018
    @param          set<Id> setInfoStatementIds
    @return         List<AccrualBill__c> - AccrualBills
    @description    get the AccrualBill records 
    *******************************************************************************/
    private List<AccrualBill__c> getAccrualBills(set<Id> setInfoStatementIds) {
        return  [SELECT Id, InformationStatement__c, BilledAmount__c
                FROM AccrualBill__c 
                WHERE InformationStatement__c IN: setInfoStatementIds Order By CreatedDate Desc LIMIT 1];  // To check further for using map
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           31 Oct 2018
    @param          set<Id> setInfoStatementIds
    @return         List<AccrualBill__c> - AccrualBillItems
    @description    get the AccrualBillItem records 
    *******************************************************************************/
    //private List<AccrualBillItem__c> getAccrualBillItems(set<Id> setInfoStatementIds) {
    private List<AccrualBillItem__c> getAccrualBillItems(String latestAccrualBillId) {
        return  [SELECT Id, AccrualBill__c, AccrualBill__r.InformationStatement__c, ServiceItem__r.ServiceItemType__r.Name, 
                 StartDate__c, EndDate__c, AccrualDays__c, BilledAmount__c, Rate__c, Rate__r.RetailAmount__c, VolumeUsed__c, 
                 ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.AlgorithmType__c
                FROM AccrualBillItem__c 
                //WHERE AccrualBill__r.InformationStatement__c IN: setInfoStatementIds];  
                WHERE AccrualBill__c =: latestAccrualBillId];  
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           31 Oct 2018
    @param          set<Id> setInfoStatementIds
    @return         List<InformationStatementMessage__c> - InformationStatementMessages
    @description    get the InformationStatementMessage records 
    *******************************************************************************/
    private List<InformationStatementMessage__c> getInformationStatementMessages(set<Id> setInfoStatementIds) {
        return  [SELECT Id, Description__c, InformationStatement__c
                FROM InformationStatementMessage__c 
                WHERE InformationStatement__c IN: setInfoStatementIds AND Active__c = true];  
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           31 Oct 2018
    @description    Subclass for InformationStatements
    *******************************************************************************/
    private class InformationStatements {
        private list<InformationStatement> InformationStatement ;
        public override String toString() {
            return 'InformationStatements' ;
        }
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           31 Oct 2018
        @param          LoUt_InformationStatementXMLContainer - instance of the container class
        @param          InformationStatement__c - Information Statement record
        @description    Constructor
        *******************************************************************************/
        private InformationStatements(LoUt_InformationStatementXMLContainer container, list<InformationStatement__c> InformationStatements) {
            InformationStatement = new list<InformationStatement>() ;
            for(InformationStatement__c infoStmtObj : InformationStatements) {
                InformationStatement.add(new InformationStatement(container, infoStmtObj)) ;
            }
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           30 Oct 2018
    @description    Subclass for InformationStatement
    *******************************************************************************/
    private class InformationStatement {
        //PDFXSLT Mapping
        private String Account_Id ;
        private String Contract_Id ;
        // AT-3858 Starts Here
        private String Account_AuDpid ; 
        private String Contract_BillingAuDpid ; 
        private String Contract_AlternativeAuDpid ; 
        // AT-3858 Ends Here
        private String InformationStatementId ;
        private String RequestNumber ;
        private String PdfTemplateName ;
        private String XsltName ;
        private String SettlementDate ;
        private String AmountDue ;
        private String SchemeArrears ;
        private String CalculatedCharges ;
        private String LocationBalance ;
        private String Type ;
        private String SolicitorName ;
        private String IssueDate ;
        private String Address ;
        private Location Location ;
        //Start: AT-4243/AT-5485
        private String AdditionalChargeDescription ;	
        private String AdditionalCharges ;
        //End: AT-4243/AT-5485
        private List<AccrualBill> AccrualBill ;
        private List<InfoStatementMessage> InfoStatementMessage ;
        private List<Reading> Reading ;
        
        public override String toString() {
            return 'InformationStatement__c';
        }
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           30 Oct 2018
        @param          LoUt_InformationStatementXMLContainer - instance of the container class
        @param          InformationStatement__c - Information Statement record
        @description    Constructor
        *******************************************************************************/
        private InformationStatement(LoUt_InformationStatementXMLContainer container, InformationStatement__c infoStmt) {
            Account_Id = infoStmt.BillingContract__r.AccountName__c ;
            Contract_Id = infoStmt.BillingContract__c ;
            
            // AT-3858 Starts Here
            Account_AuDpid = infoStmt.BillingContract__r.AccountName__r.AuDpid__c ;
            Contract_BillingAuDpid = infoStmt.BillingContract__r.BillingAuDpid__c ;
            Contract_AlternativeAuDpid = infoStmt.BillingContract__r.AlternativeAuDpid__c ;
            // AT-3858 Ends Here
            
            InformationStatementId = infoStmt.Id ;
            RequestNumber = infoStmt.Name ;
            if(infoStmt.TemplateMapping__c != null) {
                PdfTemplateName = infoStmt.TemplateMapping__r.PDFTemplate__c ;
                XsltName = infoStmt.TemplateMapping__r.XSLTDocument__c ;
            }
            SettlementDate = dateToString(infoStmt.SettlementDate__c) ;
            AmountDue = decimalToString(infoStmt.AmountDue__c) ;
            SchemeArrears =   decimalToString(infoStmt.SchemeArrears__c) ;
            CalculatedCharges = decimalToString(infoStmt.CalculatedCharges__c) ;
            LocationBalance =  decimalToString(infoStmt.LocationBalance__c) ;
            Type = infoStmt.Type__c ;
            SolicitorName = infoStmt.SolicitorName__c ; 
            IssueDate = dateToString(System.today()) ;    
            Address = infoStmt.SupplyAddress__c ;
            //Start: AT-4243/AT-5485
            AdditionalChargeDescription	=	infoStmt.AdditionalChargesDescription__c ;
            AdditionalCharges			=	decimalToString(infoStmt.AdditionalCharges__c) ;
            //End: AT-4243/AT-5485
            for(Location__c locObj : container.locations) {
                if(locObj.Id == infoStmt.Location__c) {
                    Location = new Location(container, locObj) ;
                    break ; // only one
                }
            }
            AccrualBill = new list<AccrualBill>() ;
            for(AccrualBill__c accrualBillObj : container.AccrualBills) {
                if(accrualBillObj.InformationStatement__c == infoStmt.Id) {
                    AccrualBill.add(new AccrualBill(container, accrualBillObj)) ;
                }
            }
            InfoStatementMessage = new list<InfoStatementMessage>() ;
            for(InformationStatementMessage__c InfoStatementMessageObj : container.informationStatementMessages) { 
                if(InfoStatementMessageObj.InformationStatement__c == infoStmt.Id) {
                    InfoStatementMessage.add(new InfoStatementMessage(container, InfoStatementMessageObj)) ;
                }
            }    
            Reading = new list<Reading>() ;   
            for(Reading__c readingObj : container.Readings) {
                //if(readingObj.InformationStatement__c == infoStmt.Id && readingObj.ReadingType__c == 'Information Statement') {  // ToDo: use constant class
                if(readingObj.InformationStatement__c == infoStmt.Id) {
                    Reading.add(new Reading(container, readingObj)) ;
                }
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           30 Oct 2018
    @description    Subclass for Location
    *******************************************************************************/
    private class Location {
        private String LocationNo ;
        private String TitleAddress ;
        private String LocationAuDpid ; //AT-4858
        private List<LocationOccupant> LocationOccupant ;
        private List<LandTitle> LandTitle ;   //AT-5334
        private List<SupplyPoint> SupplyPoint ;
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           30 Oct 2018
        @param          LoUt_InformationStatementXMLContainer - instance of the container class
        @param          LoUt_InformationStatementXMLContainer container, Location__c location
        @description    Constructor
        *******************************************************************************/
        private Location(LoUt_InformationStatementXMLContainer container, Location__c location) {
            LocationNo = location.Name ;
            TitleAddress = location.TitleAddress__c ;
            LocationAuDpid = location.AuDpid__c ; //AT-4858
            LocationOccupant = new list<LocationOccupant>() ;
            for(LocationOccupant__c locationOccupantObj : container.locationOccupants) {
                if(locationOccupantObj.Location__c == location.Id) {
                    LocationOccupant.add(new LocationOccupant(container, locationOccupantObj)) ;
                }
            }
            //AT-5334
            LandTitle = new list<LandTitle>() ;
            for(LandTitle__c landTitleObj : container.landTitle) {
                if(landTitleObj.Location__c == location.Id) {
                    LandTitle.add(new LandTitle(container, landTitleObj)) ;
                }
            }
            
            
            SupplyPoint = new list<SupplyPoint>() ;
            for(SupplyPoint__c supplyPointObj : container.SupplyPoints) {
                if(supplyPointObj.Location__c == location.Id) {
                    SupplyPoint.add(new SupplyPoint(container, supplyPointObj)) ;
                }
            }
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           30 Oct 2018
    @description    Subclass for Location
    *******************************************************************************/
    private class LocationOccupant {
        private String Name ;
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           30 Oct 2018
        @param          LoUt_InformationStatementXMLContainer - instance of the container class
        @param          LoUt_InformationStatementXMLContainer container, LocationOccupant__c locationOccupant
        @description    Constructor
        *******************************************************************************/
        private LocationOccupant(LoUt_InformationStatementXMLContainer container, LocationOccupant__c locationOccupant) {
            Name = locationOccupant.Name ;
        }
    }
    
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           28 Feb 2019
    @description    Subclass for LandTitle
    *******************************************************************************/
    private class LandTitle {   //AT-5334
        private String LandTitleNumber ;
        private String FolioNumber ;
        private String Type;
        private String VolumeNumber;
        
    /******************************************************************************
    @author         Echo: Vivek Sethi
    @date           28 Feb 2019
    @param          LoUt_InformationStatementXMLContainer - instance of the container class
    @param          LoUt_InformationStatementXMLContainer container, LandTitle__c Land Title
    @description    Constructor
    *******************************************************************************/
        private LandTitle(LoUt_InformationStatementXMLContainer container, LandTitle__c landTitle) {
            LandTitleNumber = landTitle.Name ;
            FolioNumber = landTitle.FolioNumber__c ;
            Type = landTitle.Type__c ;
            VolumeNumber = landTitle.VolumeNumber__c ;
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           30 Oct 2018
    @description    Subclass for Location
    *******************************************************************************/
    private class SupplyPoint {
        private String SupplyPointId ;
        private SupplyPointDevice SupplyPointDevice ;   //Active one
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           30 Oct 2018
        @param          LoUt_InformationStatementXMLContainer - instance of the container class
        @param          LoUt_InformationStatementXMLContainer container, SupplyPoint__c supplyPoint
        @description    Constructor
        *******************************************************************************/
        private SupplyPoint(LoUt_InformationStatementXMLContainer container, SupplyPoint__c supplyPoint) {
            SupplyPointId = supplyPoint.Id ;
            for(SupplyPointDevice__c spdObj : container.supplyPointDevices) {
                if(spdObj.SupplyPoint__c == supplyPoint.Id) {
                    SupplyPointDevice = new SupplyPointDevice(container, spdObj) ;   
                    break ; //only one active
                }
            } 
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           30 Oct 2018
    @description    Subclass for Location
    *******************************************************************************/
    private class SupplyPointDevice {
        private String SupplyPointDeviceId ;
        private Device Device ;
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           30 Oct 2018
        @param          LoUt_InformationStatementXMLContainer - instance of the container class
        @param          LoUt_InformationStatementXMLContainer container, SupplyPointDevice__c supplyPointDevice
        @description    Constructor
        *******************************************************************************/
        private SupplyPointDevice(LoUt_InformationStatementXMLContainer container, SupplyPointDevice__c supplyPointDevice) {
            SupplyPointDeviceId = supplyPointDevice.Id ;
            for(Device__c deviceObj : container.devices) {
                if(deviceObj.Id == supplyPointDevice.Device__c) {
                    Device = new Device(container, deviceObj) ;
                    break ; // only one
                }
            }
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           30 Oct 2018
    @description    Subclass for Location
    *******************************************************************************/
    private class Device {
        private String DeviceId ;
        private String attr_Name ;
        private String Name ;
        private String SerialNumber;
        private String Digits;
        private String DeviceType;
        private String DeviceSize ; 
        private String Manufacturer ;
        private List<Reading> Reading ;
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           30 Oct 2018
        @param          LoUt_InformationStatementXMLContainer - instance of the container class
        @param          LoUt_InformationStatementXMLContainer container, Device__c device
        @description    Constructor
        *******************************************************************************/
        private Device(LoUt_InformationStatementXMLContainer container, Device__c device) {
            DeviceId = device.Id ;
            attr_Name = device.Name ;
            Name = device.Name ;
            SerialNumber = device.SerialNo__c;
            DeviceSize = device.DeviceType__r.DeviceSize__r.Name;  
            Digits = String.valueOf(device.Digit__c);
            DeviceType = device.DeviceType__c;    
            Reading = new list<Reading>() ;
            for(Reading__c readObj : container.readings) {
                //If there is no last billed reading, movein reading is sent then
                if(readObj.Device__c == device.Id && readObj.BillableType__c == GlUt_Constants.BILLABLE && (readObj.Billed__c || readObj.ReadingType__c == GlUt_Constants.MOVEIN)) {    
                    Reading.add(new Reading(container, readObj)) ;
                    break ; // since only latest billable reading that has been billed for this device
                }
                //What if there is no last billable reading - This could be in case of void property. Can IS be created on void property??
                /*
                else if(readObj.Device__c == device.Id && readObj.InformationStatement__c != null) {
                    Reading.add(new Reading(container, readObj)) ;
                    break ; // since only one Information Statement type reading
                }
                */
            }
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           30 Oct 2018
    @description    Subclass for Location
    *******************************************************************************/
    private class Reading {
        private String ReadingId ;
        private String ReadingDate ;
        private String ReadingType ;
        private Decimal Reading ;
        private String attr_ReadingType ;
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           30 Oct 2018
        @param          LoUt_InformationStatementXMLContainer - instance of the container class
        @param          LoUt_InformationStatementXMLContainer container, Reading__c reading
        @description    Constructor
        *******************************************************************************/
        private Reading(LoUt_InformationStatementXMLContainer container, Reading__c reading) {
            ReadingId           = reading.Id ;
            ReadingDate         = dateToString(reading.ReadingDate__c) ;
            ReadingDate         = dateToString(reading.ReadingDate__c) ;
            ReadingType         = reading.ReadingType__c ;
            attr_ReadingType    = reading.ReadingType__c ;
            this.Reading        = reading.Reading__c ;
        }
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           30 Oct 2018
    @description    Subclass for AccrualBill
    *******************************************************************************/
    private class AccrualBill {
        private String BilledAmount ;
        private List<AccrualBillItem> AccrualBillItem ;
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           30 Oct 2018
        @param          LoUt_InformationStatementXMLContainer - instance of the container class
        @param          LoUt_InformationStatementXMLContainer container, AccrualBill__c accrualBill
        @description    Constructor
        *******************************************************************************/
        private AccrualBill(LoUt_InformationStatementXMLContainer container, AccrualBill__c accrualBill) {
            BilledAmount = decimalToString(accrualBill.BilledAmount__c) ;
            AccrualBillItem = new list<AccrualBillItem>() ;  
            for(AccrualBillItem__c accrualBillItemObj : container.accrualBillItems) {
                if(accrualBillItemObj.AccrualBill__c == accrualBill.Id) {
                    AccrualBillItem.add(new AccrualBillItem(container, accrualBillItemObj)) ;   
                }
            }
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           30 Oct 2018
    @description    Subclass for AccrualBillItem
    *******************************************************************************/
    private class AccrualBillItem {
        private String ServiceItemType ;    // BillDescription ??
        private String StartDate ;
        private String EndDate ;
        private String AccrualDays ;
        private String Rate ;
        private String BilledAmount ; 
        private String VolumeUsed ;
        private String attr_AlgorithmType ;
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           30 Oct 2018
        @param          LoUt_InformationStatementXMLContainer - instance of the container class
        @param          LoUt_InformationStatementXMLContainer container, AccrualBillItem__c accrualBillItem
        @description    Constructor
        *******************************************************************************/
        private AccrualBillItem(LoUt_InformationStatementXMLContainer container, AccrualBillItem__c accrualBillItem) {
            if(accrualBillItem.ServiceItem__c != null && accrualBillItem.ServiceItem__r.ServiceItemType__c != null) {
                ServiceItemType = accrualBillItem.ServiceItem__r.ServiceItemType__r.Name ;
            }
            StartDate       = dateToString(accrualBillItem.StartDate__c) ;
            EndDate         = dateToString(accrualBillItem.EndDate__c) ;
            AccrualDays     = decimalToString(accrualBillItem.AccrualDays__c) ;
            if(accrualBillItem.Rate__c != null) {   // AT-5310
                Rate        = decimalToString(accrualBillItem.Rate__r.RetailAmount__c) ;
            }
            BilledAmount    = decimalToString(accrualBillItem.BilledAmount__c) ;
            VolumeUsed      = decimalToString(accrualBillItem.VolumeUsed__c) ;
            if(accrualBillItem.ServiceItem__c != null && accrualBillItem.ServiceItem__r.ServiceItemType__c != null 
                                                      && accrualBillItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__c != null) {
                attr_AlgorithmType  = accrualBillItem.ServiceItem__r.ServiceItemType__r.ServiceItemFamily__r.AlgorithmType__c ;
            }
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           30 Oct 2018
    @description    Subclass for InfoStatementMessage
    *******************************************************************************/
    private class InfoStatementMessage {
        private String Description ;
        /******************************************************************************
        @author         Echo: Sudhir Kumar
        @date           30 Oct 2018
        @param          LoUt_InformationStatementXMLContainer - instance of the container class
        @param          LoUt_InformationStatementXMLContainer container, InformationStatementMessage__c infoStatementMessage
        @description    Constructor
        *******************************************************************************/
        private InfoStatementMessage(LoUt_InformationStatementXMLContainer container, InformationStatementMessage__c infoStatementMessage) {
            Description = infoStatementMessage.Description__c ;
        }
    }
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           1 Nov 2018        
    @param          none
    @description    Get Query String - Implemented method of GlUt_DataTransferXmlInterface     // AU1 AT-4098
    *******************************************************************************/
    public String getQueryString(Id recordId, String filterCriteria) {
        String queryString = '' ;
        queryString = String.format('SELECT {0} FROM {1}' , new List<String> {'Id, ' + String.join(LoUt_InformationStatementXMLContainer.infoStatementFieldsList, ',') , GlUt_APIConstantsInformationStatement.OBJECTAPINAME}) ;
        if(String.isNotBlank(filterCriteria)) {
            queryString += ' WHERE ' + filterCriteria ;
        }
        return queryString ;
    }   
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           1 Nov 2018        
    @param          none
    @description    Information Statement Query fields list   // AU1 AT-4098
    *******************************************************************************/
    public static list<String> infoStatementFieldsList = new list<String>{
        GlUt_APIConstantsInformationStatement.NAMEAPINAME, 
        GlUt_APIConstantsInformationStatement.TEMPLATEAPINAME, 
        GlUt_APIConstantsInformationStatement.SETTLEMENTDATEAPINAME, 
        GlUt_APIConstantsInformationStatement.AMOUNTDUEAPINAME, 
        GlUt_APIConstantsInformationStatement.SCHEMEARRERSAPINAME, 
        GlUt_APIConstantsInformationStatement.CALCULATEDCHARGEAPINAME,
        GlUt_APIConstantsInformationStatement.LOCATIONBALANCEAPINAME, 
        GlUt_APIConstantsInformationStatement.TYPEAPINAME, 
        GlUt_APIConstantsInformationStatement.SOLICITORNAMEAPINAME, 
        GlUt_APIConstantsInformationStatement.ISSUEDATEAPINAME, 
        GlUt_APIConstantsInformationStatement.SUPPLYADDRESSAPINAME,       
        GlUt_APIConstantsInformationStatement.LOCATIONAPINAME,
        GlUt_APIConstantsInformationStatement.DATAXMLAPINAME,
        GlUt_APIConstantsInformationStatement.PRINTXMLAPINAME, 
        GlUt_APIConstantsInformationStatement.STATEMENTPDFAPINAME, 
        GlUt_APIConstantsInformationStatement.BILLINGCONTRACTAPINAME,
        GlUt_APIConstantsInformationStatement.ADDITIONAL_CHARGE_DESCRIPTION,
        GlUt_APIConstantsInformationStatement.ADDITIONAL_CHARGES,
        GlUt_APIConstantsContracts.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.CUSTOMERAPINAME,
        GlUt_APIConstantsInformationStatement.TEMPLATEMAPPINGAPINAME, 
        GlUt_APIConstantsInformationStatement.TEMPLATEMAPPINGRELAPINAME + '.' + GlUt_APIConstantsTemplateMapping.PDFTEMPLATEAPINAME,
        GlUt_APIConstantsInformationStatement.TEMPLATEMAPPINGRELAPINAME + '.' + GlUt_APIConstantsTemplateMapping.XSLTDOCUMENTAPINAME,
        //AT-3858 Starts Here
        GlUt_APIConstantsContracts.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.RELATED_ACCOUNT + '.' + GlUt_APIConstantsAccount.AUDPIDAPINAME,
        GlUt_APIConstantsContracts.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.BILLINGAUDPIDAPINAME,
        GlUt_APIConstantsContracts.CONTRACTRELAPINAME + '.' + GlUt_APIConstantsContracts.ALTERNATEAUDPIDAPINAME
        //AT-3858 Ends Here  
    } ;
        
}