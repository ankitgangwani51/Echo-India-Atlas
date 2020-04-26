/******************************************************************************
@author    		Echo: Gopal Gupta
                Echo: Amit K.
@date      		20 Nov 2017
                12 Feb 2018
@description 	Component controller for Device Management wizard
*******************************************************************************/
public with sharing class LoAp_DeviceExchangeWizardCmpCtrlr {

	private static final String CLASS_NAME = 'LoAp_DeviceExchangeWizardCmpCtrlr';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';

	public static WizardObject wizObject;

	/******************************************************************************
    @author         Echo: Amit K. (Add , Exchange and Remove Device)
    @date           12 Feb 2018
    @description    Wrapper class for Wizard variables
    *******************************************************************************/
	/*
	Screen	wizardprop element name			type
	==============================================================================
    Base
			   recordId						Id (the Id of the host page record) - should be the same as locationId but use locationId
			   locationId				    Id (the Id of the device exchange location)

    Add Scenario:
   
    WS0
			   wizardType				    String (NewDevice,ExchangeDevice,RemoveDevice)

    WS3,WS6    selectedSupplyPointAdded     SupplyPoint__c
                                               Measured__c = 'Yes'
                                               ReadFrequency__c = from WS4
                                               Id = from Screen
               
              spDeviceToBeAdded            SupplyPointDevice__c
                                               SupplyPoint__c = from Screen
                                               Device__c = from screen
                                               InstallationDate__c = null (from WS4)

              newSPDservices                List<SupplyPointDeviceService__c>
                                               ServiceType__c = service type of the device
											   SupplyPointDevice__c = null (Need to be set in Controller)


              newDeviceId                  Id of the device to be added

    WS4
            initialReading:		            Reading__c
												DeviceReference__c = newDeviceId
												ActualDeviceReading__c = from screen
												ReadingDate__c = from screen
												ReadingMethod__c = 	from screen
												ReadingSource__c = from screen
												ReadingType__c = from screen
                                                BillableType__c = from screen

           spDeviceToBeAdded                SupplyPointDevice__c
                                               InstallationDate__c = from screen

           selectedSupplyPointAdded         SupplyPoint__c
                                               ReadFrequency__c = from screen

    WS7       availabeBundle               List<AvailableBundle__c>
                                               Id = Available Bundle Id
                                               AvailableService__c = from selection
                                               Bundle__c = from selection
    
   
             
   Remove Scenario:

   WS0       supplyPointDevice            SupplyPointDevice__c
                                               Id = Id of the SPD
                                               SupplyPoint__c = SupplyPointDevice-->SupplyPointId
                                               Device__c = SupplyPointDevice-->DeviceId
                                               RemovalDate__c = null (from WS2)

            selectedSupplyPointRemoved  SupplyPoint__c
                                               Measured__c = 'No',
                                               ReadFrequency__c = 'Unmeasured'
                                               Id : SupplyPointDevice-->SupplyPoint ID

   WS1      supplyPointDevice              SupplyPointDevice__c
                                               Id = (from selection) SupplyPointDevice
                                               SupplyPoint__c = (from selection) SupplyPointDevice-->SupplyPointId
                                               Device__c = (from selection) SupplyPointDevice-->DeviceId
                                               RemovalDate__c = null (from WS2)

           selectedSupplyPointRemoved      SupplyPoint__c
                                               Measured__c = 'No',
                                               ReadFrequency__c = 'Unmeasured'
                                               Id : SupplyPointDevice-->SupplyPoint ID

  

   WS2       finalReading:		            Reading__c
												DeviceReference__c = supplyPointDevice.Device__c
												ActualDeviceReading__c = from screen
												ReadingDate__c = from screen
												ReadingMethod__c = 	from screen
												ReadingSource__c = from screen
												ReadingType__c = from screen
                                                BillableType__c = from screen
    
             amendReadings                List<Reading>
                                               Id = Reading Id
                                               AmendedByReading__c = Initial Reading ID

            supplyPointDevice             SupplyPointDevice__c
                                               RemovalDate__c = From screen

    WS7       availabeBundle                List<AvailableBundle__c>
                                               Id = Available Bundle Id
                                               AvailableService__c = from selection
                                               Bundle__c = from selection


  Exchange Scenario:
  
   WS0       wizardType				      String (NewDevice,ExchangeDevice,RemoveDevice)

             supplyPointDevice            SupplyPointDevice__c
                                               Id = Id of the SPD
                                               SupplyPoint__c = SupplyPointDevice-->SupplyPointId
                                               Device__c = SupplyPointDevice-->DeviceId
                                               RemovalDate__c = null (from WS2)

            selectedSupplyPointRemoved    SupplyPoint__c
                                               ReadFrequency__c = from SPD-->SPFrequency
                                               Id : SupplyPointDevice-->SupplyPoint ID

   WS1       supplyPointDevice              SupplyPointDevice__c
                                               Id = (from selection) SupplyPointDevice
                                               SupplyPoint__c = (from selection) SupplyPointDevice-->SupplyPointId
                                               Device__c = (from selection) SupplyPointDevice-->DeviceId
                                               RemovalDate__c = null (from WS2)

            selectedSupplyPointRemoved      SupplyPoint__c
                                               ReadFrequency__c = from SP-->ReadFrequency
                                               Id : SupplyPointDevice-->SupplyPoint ID


   WS2       finalReading:		            Reading__c
												DeviceReference__c = supplyPointDevice.Device__c
												ActualDeviceReading__c = from screen
												ReadingDate__c = from screen
												ReadingMethod__c = 	from screen
												ReadingSource__c = from screen
												ReadingType__c = from screen
                                                BillableType__c = from screen

            amendReadings                   List<Reading>
                                               Id = Reading Id
                                               AmendedByReading__c = Initial Reading ID

            supplyPointDevice             SupplyPointDevice__c
                                               RemovalDate__c = From screen


  WS3      spDeviceToBeAdded           SupplyPointDevice__c
                                               SupplyPoint__c = from Screen
                                               Device__c = from screen
                                               InstallationDate__c = null (from WS4)

           newSPDservices               List<SupplyPointDeviceService__c>
                                                 ServiceType__c = service type of device
                                                 SupplyPointDevice__c = null (need to be set in the controller with the Id of spDeviceToBeAdded)

  WS4
          initialReading:		            Reading__c
												DeviceReference__c = newDeviceId
												ActualDeviceReading__c = from screen
												ReadingDate__c = from screen
												ReadingMethod__c = 	from screen
												ReadingSource__c = from screen
												ReadingType__c = from screen
                                                BillableType__c = from screen

          spDeviceToBeAdded                SupplyPointDevice__c
                                               InstallationDate__c = from screen

         selectedSupplyPointRemoved           SupplyPoint__c
                                               ReadFrequency__c = from screen

  


    */
   
	public class WizardObject {
        
        public Id recordId;
        public Id locationId;
        public Id newDeviceId;
        public Date removalDate;
        public SupplyPointDevice__c supplyPointDevice;     // supply point device updated.
        public SupplyPointDevice__c spDeviceToBeRemoved;    // No Use in Device Management Wizard
        public Reading__c finalReading;    // final reading to be inserted for the old device
        public SupplyPointDevice__c spDeviceToBeAdded;    // supply point device to be inserted for the exchanged device
        public Reading__c initialReading;    // initial reading to be inserted for the exchanged device
        public List<SupplyPointDeviceService__c> newSPDServices;    // supply point device services to be inserted for the exchanged device
        public String wizardType;              // helps in Conditional based wizard steps.
        public Integer numberOfSupplyPointPerLocation;    // Number of Supply Point per location.
        public Integer noOfActiveDevicesPerLocation;       // Number of active device per location.
        public SupplyPoint__c selectedSupplyPointAdded;   // Add Supply Point for device that needs to be added.
        public SupplyPoint__c selectedSupplyPointRemoved; //Supply Point where device needs to be removed.
        public List<AvailableBundle__c> availabeBundle; // update available bundle with selected bundle.
        public List<Reading__c> amendReadings;  //amended by reading to be updated with final reading in case of select last good reading.
    }
    
    /******************************************************************************
	@author    		Echo: Gopal Gupta
	@date      		4 Dec 2017
	@param			String - wizardprop
	@description	Updates the wizard properties
	*******************************************************************************/
    @AuraEnabled
	public static void WizardStatus(String wizardprop) {
		
        // build the wizard object from the wizard properties
		UpdateWizardProperties(wizardprop);
	}
    
    /******************************************************************************
	@author    		Echo: Gopal Gupta
	@date      		4 Dec 2017
	@param			String - wizardprop
	@description	Updates the wizard properties
	*******************************************************************************/
	public static void UpdateWizardProperties(String wizardprop) {
		
		// strip out all the SObject type references from the json
		wizardprop = wizardprop.replaceAll('"sobjectType":"(.*?)"(,|[^}]*)', '');
		
		// and deserialise it
		wizObject = (WizardObject)System.JSON.deserializeStrict(wizardprop, WizardObject.class);
	}
    
    /******************************************************************************
	@author    		Echo: Gopal Gupta
                    Echo: Amit K.
	@date      		21 Nov 2017
                    13-Feb-2018
	@param			String - json string of object wizardprop
	@param			String - wizardprop
	@return			Id - the new reading Id
	@description 	Method called by wizard to complete the device management process
	@revision		Echo: Sudhir Kumar=>AT-3075 (Core 7b): Update Available Bundle Trigger Handler -> Assign Last Bundle Change Date field
	@revision		Echo: Sudhir Kumar=>AT-3910 (Core Misc): On Device exchange where Available Service Items and Service Items are continuing, 
															 "Last Bundle Change Date" still gets updated on "Available Bundle".
										("Last Bundle Change date" on "Available Bundle" should not change during either "Band Change" or "Device Change". 
										This field is changed only during Bundle change.)
										Reverted changes done under AT-3075.
	@revision		Echo: Sudhir Kumar -> AT-3754 (Core Misc)- Last Bundle Change Date: Set to device Installation Date if adding new device; 
															   and set to device Removal Date if it is removed.						
	*******************************************************************************/
	@AuraEnabled
	public static Id ManageDevice(String wizardprop) {
		Id finalReadingId;
        Savepoint sp = Database.setSavepoint();
        
		try {
            // build the wizard object from the wizard properties
            UpdateWizardProperties(wizardprop);            
            if (wizObject.wizardType == System.Label.LoAp_ExchangeDevice) {
                // update the removal date on the supply point device
                
                if (wizObject.supplyPointDevice != null) {
                    wizObject.supplyPointDevice.Ended__c = true;
                    wizObject.supplyPointDevice = (SupplyPointDevice__c) GlUt_FieldSecurity.cleanseFields(wizObject.supplyPointDevice, false);
                    update wizObject.supplyPointDevice;
                }
                
                // insert the supply point device records for the exchanged device
                if (wizObject.spDeviceToBeAdded != null) {
                    wizObject.spDeviceToBeAdded = (SupplyPointDevice__c) GlUt_FieldSecurity.cleanseFields(wizObject.spDeviceToBeAdded, false);
                    insert wizObject.spDeviceToBeAdded;
                }
                
                // final readings
                if (wizObject.finalReading != null) {
                    // insert the readings
                    wizObject.finalReading = (Reading__c) GlUt_FieldSecurity.cleanseFields(wizObject.finalReading, false);
                    insert wizObject.finalReading;
                    finalReadingId = wizObject.finalReading.Id;

					// amended readings
                    if (wizObject.amendReadings != null) {
                        for (Reading__c reading:wizObject.amendReadings) {
                            reading.AmendedByReading__c = finalReadingId;
                        }
                        wizObject.amendReadings = (List<Reading__c>) GlUt_FieldSecurity.cleanseFields(wizObject.amendReadings, false);
                        update wizObject.amendReadings;
                    }
                }
                // initial readings
                if (wizObject.initialReading != null) {
                    // insert the readings
                    wizObject.initialReading = (Reading__c) GlUt_FieldSecurity.cleanseFields(wizObject.initialReading, false);
                    insert wizObject.initialReading;
                }
                
                // link the newly added supply point device to the services and insert them
                if (wizObject.newSPDServices != null) {
                    for(SupplyPointDeviceService__c spds : wizObject.newSPDServices){
                        spds.SupplyPointDevice__c = wizObject.spDeviceToBeAdded.Id;
                    }
                    wizObject.newSPDServices = (List<SupplyPointDeviceService__c>) GlUt_FieldSecurity.cleanseFields(wizObject.newSPDServices, false);
                    insert wizObject.newSPDServices;
                }
                //Update SP having reading frequency selected  from screen.
                if (wizObject.selectedSupplyPointRemoved != null) {   //AT-4185
               /* List<SupplyPoint__c> readFrequency = [select Book__r.ReadFrequency__c from SupplyPoint__c where Id =: wizObject.selectedSupplyPointRemoved.Id];
                    
                    if(readFrequency != null && !readFrequency.isEmpty() && readFrequency[0].Book__r.ReadFrequency__c  != null)   
                        wizObject.selectedSupplyPointRemoved.ReadFrequency__c = readFrequency[0].Book__r.ReadFrequency__c;
                    */
                    wizObject.selectedSupplyPointRemoved = (SupplyPoint__c) GlUt_FieldSecurity.cleanseFields(wizObject.selectedSupplyPointRemoved, false);
                    update wizObject.selectedSupplyPointRemoved;  
                }    
               
            } else if (wizObject.wizardType == System.Label.LoAp_NewDevice) {
                
				//Step 4. update supply point.
                if (wizObject.selectedSupplyPointAdded != null) { //AT-4185
                /*  List<SupplyPoint__c> readFrequency = [select Book__r.ReadFrequency__c from SupplyPoint__c where Id =: wizObject.selectedSupplyPointAdded.Id];
                    
                    if(readFrequency != null && !readFrequency.isEmpty() && readFrequency[0].Book__r.ReadFrequency__c  != null)   
                        wizObject.selectedSupplyPointAdded.ReadFrequency__c = readFrequency[0].Book__r.ReadFrequency__c;
                  */
                    wizObject.selectedSupplyPointAdded = (SupplyPoint__c) GlUt_FieldSecurity.cleanseFields(wizObject.selectedSupplyPointAdded, false); 
                    update wizObject.selectedSupplyPointAdded;  
                        
                }
                //Step 2. create new supply point device record for device added.
                if (wizObject.spDeviceToBeAdded != null ){
                    wizObject.spDeviceToBeAdded = (SupplyPointDevice__c) GlUt_FieldSecurity.cleanseFields(wizObject.spDeviceToBeAdded, false); 
                    insert wizObject.spDeviceToBeAdded;
                }
                //Step 1. Create Initial reading record for device added.           
                // add initial readings
                if (wizObject.initialReading != null) {
                    // insert the readings
                    wizObject.initialReading = (Reading__c) GlUt_FieldSecurity.cleanseFields(wizObject.initialReading, false);
                    insert wizObject.initialReading;
                }
                //Step 3. link the newly added supply point device to the services and insert them
                if (wizObject.newSPDServices != null) {
                    for(SupplyPointDeviceService__c spds : wizObject.newSPDServices){
                        spds.SupplyPointDevice__c = wizObject.spDeviceToBeAdded.Id;
                    }
                    wizObject.newSPDServices = (List<SupplyPointDeviceService__c>) GlUt_FieldSecurity.cleanseFields(wizObject.newSPDServices, false);
                    insert wizObject.newSPDServices;
                }
               
                //Step 5. update\insert available bundles with new bundle id.
                if (wizObject.availabeBundle != null) {
                    //Reverted the code as per AT-3910
                    //Start: AT-3075 (Core 7b) & AT-3754 (Core Misc)
                    SupplyPointDevice__c objSupplyPointDevice = (SupplyPointDevice__c) wizObject.spDeviceToBeAdded;	
                    for(AvailableBundle__c objAvailabeBundle : (List<AvailableBundle__c>) wizObject.availabeBundle) {	
                        objAvailabeBundle.LastBundleChangeDate__c = objSupplyPointDevice.InstallationDate__c;	
                    } 	
                    wizObject.availabeBundle = (List<AvailableBundle__c>) GlUt_FieldSecurity.cleanseFields(wizObject.availabeBundle, false);    // VS  AT-2644
                    //End: AT-3075 (Core 7b) & AT-3754 (Core Misc)
                    if(wizObject.availabeBundle != null && !wizObject.availabeBundle.isEmpty()) {	// AT-3489
                        if(wizObject.availabeBundle[0].Id != null)
                            update wizObject.availabeBundle;
                        else
                            insert wizObject.availabeBundle;
                    }
                    
                }

            } else if (wizObject.wizardType == System.Label.LoAp_RemoveDevice) {
                //Step 2. update supply point device record for device removed.
                if (wizObject.supplyPointDevice != null) {
                    wizObject.supplyPointDevice = (SupplyPointDevice__c) GlUt_FieldSecurity.cleanseFields(wizObject.supplyPointDevice, false); 
                    wizObject.supplyPointDevice.Ended__c = true;
                    update wizObject.supplyPointDevice;
                }
                //Step 1. Create final/Amend reading record for device removed.           
                // final reading
                if (wizObject.finalReading != null) {
                    // insert the readings
                    wizObject.finalReading = (Reading__c) GlUt_FieldSecurity.cleanseFields(wizObject.finalReading, false);
                    insert wizObject.finalReading;
                    finalReadingId = wizObject.finalReading.Id;

					// amended readings
	                if (wizObject.amendReadings != null) {
	                    for (Reading__c reading:wizObject.amendReadings) {
	                        reading.AmendedByReading__c = finalReadingId;
	                    }
	                    update wizObject.amendReadings;
	                }
                }
                //Step 3. update supply point where device removed.
                if (wizObject.selectedSupplyPointRemoved != null) {
                    wizObject.selectedSupplyPointRemoved = (SupplyPoint__c) GlUt_FieldSecurity.cleanseFields(wizObject.selectedSupplyPointRemoved, false); 
                    update wizObject.selectedSupplyPointRemoved;
                }
                //Step 5. update available bundles at supply point where the device was removed.
                if (wizObject.availabeBundle != null) {
                    //Reverted the code as per AT-3910
                    //Start: AT-3075 (Core 7b) & AT-3754 (Core Misc)	
                    SupplyPointDevice__c objSupplyPointDevice = (SupplyPointDevice__c) wizObject.supplyPointDevice;	
                    for(AvailableBundle__c objAvailabeBundle : (List<AvailableBundle__c>) wizObject.availabeBundle) {	
                        objAvailabeBundle.LastBundleChangeDate__c = objSupplyPointDevice.RemovalDate__c;	
                    } 	
                    wizObject.availabeBundle = (List<AvailableBundle__c>) GlUt_FieldSecurity.cleanseFields(wizObject.availabeBundle, false);  // VS  AT-2644
                    //End: AT-3075 (Core 7b) & AT-3754 (Core Misc)
                    if(wizObject.availabeBundle != null && !wizObject.availabeBundle.isEmpty()) {	// AT-3489
                        if(wizObject.availabeBundle[0].Id != null)
                            update wizObject.availabeBundle;
                        else 
                            insert wizObject.availabeBundle;
                    }
                }
            }
            return finalReadingId;
            
        } catch (exception e) {
            GlUt_Logger.logException(e);
            
            Database.rollback(sp);
            // MT - 11-04-2018 AT-2218 Added if statement to display error message without the DML exception
            if(e.getMessage().contains(System.Label.GlUt_AvailableBundleDuplicateMessage))
                throw new AuraHandledException(System.Label.GlUt_AvailableBundleDuplicateMessage);
            else
                throw new AuraHandledException(GlUt_Logger.getActualErrorMessage(e.getMessage()));
		}
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
	}
    
   
}