/******************************************************************************
@author    		Echo: Tarun Gupta
@date      		07 Nov 2017
@description 	Component controller for select service wizard
@Revision(s)	08 May 2018, P Dixon - revised to use GlAp_LightningDataAccess methods to retrieve records for display
@Revisions		AT-3494, Modified to add SI start date  
*******************************************************************************/
public with sharing class CuAp_SelectServicesPageCtrlr {
      
    private static final String CLASS_NAME = 'CuAp_SelectServicesPageCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    
    private static List<string> avlServiceFields;
    private static List<string> serviceItemFields;
    
    static{
        //Get Fields from the Service Type Object
        avlServiceFields = new List<string>();
        avlServiceFields.add(GlUt_APIConstantsServiceType.NAMEAPINAME);    // -- Swati 28-08-2018, AT-3174                         
        serviceItemFields = new List<String>();
        serviceItemFields.add(GlUt_APIConstantsServiceItem.STARTDATEAPINAME);
    }
    
    /**********************************************************************************************
    @author        Echo: Tarun Gupta
    @date          07-Nov-2017
    @return        List<GLAp_FieldProps>
    @description   This method returns the field properties for each of the fields that are
				   to be displayed on the screen
    **********************************************************************************************/      
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveSerAvailServiceFieldPropDetails() {
        List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
        
        try {
            //Get the field properties for the Available Service object
            List<GLAp_FieldProps> avlSrvProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME, avlServiceFields);
            
            Boolean regionAU = GlUt_RegionUtility.getAURegionCustomSetting();
            if(regionAU){
                List<GLAp_FieldProps> servItemProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME, serviceItemFields);
				avlSrvProps.addAll(servItemProps);
                GLAp_FieldProps transFieldProp = new GLAp_FieldProps();
                transFieldProp.isFLSVisible = true;
                transFieldProp.isEncrypted = false;
                transFieldProp.isEditable = true;
                transFieldProp.editMode = false;
                transFieldProp.isRequired = false;
                transFieldProp.fieldName = 'Service_Start_Date';
                transFieldProp.fieldLabel = 'Service Start Date';
                transFieldProp.fieldType = 'date';
                //transFieldProp.transformField = false;
                transFieldProp.buttonField = false;
                transFieldProp.parentObject = GlUt_APIConstantsServiceType.SERVICETYPEAPINAME;
                //avlSrvProps.add(transFieldProp);
            }
            for(GLAp_FieldProps fldProp : avlSrvProps){
                fldProp.isEditable = true; 
                if(fldProp.fieldName == GlUt_APIConstantsServiceType.NAMEAPINAME){
                fldProp.fieldLabel = CuAp_Constants.AVAILABLESERVICESLABEL; // -- Swati 28-08-2018, AT-3174
                fldProp.isEditable = false; // -- Swati 28-08-2018, AT-3174
                }
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
    @author        Echo: Tarun Gupta
    @date          07-Nov-2017
    @param         loaction Id
    @return        List<String>
    @description   Method to fetch all available services
    **********************************************************************************************/            
    @AuraEnabled        
    public static WrapAvailableService fetchListOfAvailServices(Id sLocationId, String moveInDate, String occType){        	
        
        WrapAvailableService objWrapper = new WrapAvailableService();
        List<BlAp_CombinedRecord> availServiceListToBeReturn = new List<BlAp_CombinedRecord>();
        try {
            Boolean regionAU = GlUt_RegionUtility.getAURegionCustomSetting();
            Date lastBillItemEndDate = getLastBillItemEndDate(sLocationId,Date.valueOf(moveInDate));
            Date serviceItemStartDate;
            ServiceItem__c objSI = new ServiceItem__c();
            if(regionAU){
                if(occType == Label.CuAp_AUMoveInOccType){ // If it is tenant
                    serviceItemStartDate = Date.valueOf(moveInDate);
                }
                else{ // Landlord or Owner
                    if(lastBillItemEndDate != null)
                        serviceItemStartDate = Date.valueOf(lastBillItemEndDate).addDays(1);
                    else
                        serviceItemStartDate = Date.valueOf(moveInDate);
                }
                objSI.StartDate__c = serviceItemStartDate ;
            }
            
            List<AvailableService__c> availableServiceList = (List<AvailableService__c>) GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME, 
                                                                                                                             new List<string>{
                                                                                                                                 GlUt_APIConstantsAvailableService.NAMEAPINAME,
                                                                                                                                     GlUt_APIConstantsAvailableService.SERVICETYPEAPINAME,
                                                                                                                                     GlUt_APIConstantsAvailableService.SUPPLYPOINTAPINAME
                                                                                                                                     //GlUt_APIConstantsAvailableService.SERVICETYPEREFAPINAME // -- Swati 28-08-2018, AT-3174
                                                                                                                                     }, 
                                                                                                                             sLocationId, 
                                                                                                                             GlUt_APIConstantsAvailableService.SUPPLYPOINTRELAPINAME + '.' + GlUt_APIConstantsSupplyPoint.LOCATIONAPINAME, 
                                                                                                                             GlUt_APIConstantsAvailableService.ACTIVEAPINAME + ' = true');
             // -- Swati 28-08-2018 - Start, AT-3174                          
            List<Id> serviceTypeIdList = new List<Id>();
            for (AvailableService__c objAS : availableServiceList) {
                serviceTypeIdList.add(objAS.ServiceType__c); 
            } 
            List<ServiceType__c> lstServiceType =  GlAp_LightningDataAccess.getRecords(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME,
                                                                                       avlServiceFields,
                                                                                       String.format('WHERE {0} IN {1}', 
                                                                                                      new List<String>{
                                                                                                      GlUt_APIConstantsServiceType.Id, 
                                                                                                      GlUt_FieldSecurity.IdsToString(serviceTypeIdList)}));   
            
            Map<Id, ServiceType__c> serviceTypeId2ServiceTypeMap = new Map<Id, ServiceType__c>(lstServiceType);
            // -- Swati 28-08-2018 - End, AT-3174          
            
            for (AvailableService__c objAS : availableServiceList) {            
                BlAp_CombinedRecord bundleRecrds = new BlAp_CombinedRecord();            
                bundleRecrds.uniqueId = objAS.Id;
                bundleRecrds.isSelected = true;
                bundleRecrds.objectMap = new Map<string, sObject>();                
                bundleRecrds.objectMap.put(GlUt_APIConstantsAvailableService.AVAILABLESERVICEAPINAME, objAS);
                bundleRecrds.objectMap.put(GlUt_APIConstantsServiceType.SERVICETYPEAPINAME, serviceTypeId2ServiceTypeMap.get(objAS.ServiceType__c)); // -- Swati 28-08-2018, AT-3174
                if(regionAU){
                    bundleRecrds.objectMap.put(GlUt_APIConstantsServiceItem.SERVICEITEMAPINAME, objSI);
                }
                availServiceListToBeReturn.add(bundleRecrds);
                
            }
            objWrapper.availServiceListToBeReturn = availServiceListToBeReturn;
            objWrapper.auRegion = regionAU;
        } catch (exception e) {
            GlUt_Logger.logException(e);
        }
        finally {
            GlUt_Logger.writeLogsToDatabase();
        }
        return objWrapper;
    }
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           12-Feb-2017
    @param          none
    @return         none
    @description    wrapper class to hold the Payment Plan Type and corresponding List of payment method
    *******************************************************************************/
    public class WrapAvailableService{
        @AuraEnabled public Boolean auRegion;                
        @AuraEnabled public List<BlAp_CombinedRecord> availServiceListToBeReturn; 
        public WrapAvailableService(){
            this.availServiceListToBeReturn = new List<BlAp_CombinedRecord>();
        } 
    }
    /******************************************************************************
	@author    		Echo: Tarun Gupta
	@date      		24 Oct 2018
	@param			Id - location Id
	@param			Date - the Start date for the service items (move In Date)
	@return 		Date - lastBillItemEndDate
	@description 	Gets last bill item dateat a location 
	*******************************************************************************/
    public static Date getLastBillItemEndDate(Id locationId, Date moveInDate) {
        Date lastBillItemEndDate;
        List<ServiceItem__c> listServiceItems = new List<ServiceItem__c>();
        List<BillItem__c> listBillItems = new List<BillItem__c>();
        Set<Id> setServiceItemId = new Set<Id>();
        listServiceItems = [SELECT Id, StartDate__c, EndDate__c, ServiceItemType__c, Invalid__c, Service__r.OccupancyType__c, Service__r.BillingContract__c, Ended__c
                            FROM ServiceItem__c 
                            WHERE Service__r.Supplypoint__r.Location__c = :locationId 
                            AND StartDate__c <=: moveInDate
                            AND (EndDate__c = null OR EndDate__c >: moveInDate)
                            AND (ServiceItemType__r.Owner__c = true OR ServiceItemType__r.Landlord__c = true)];
        for(ServiceItem__c objSI : listServiceItems){
            setServiceItemId.add(objSI.Id);
        }
        if(setServiceItemId.size() > 0){
            listBillItems = [SELECT Id,Name,EndDate__c
                             FROM BillItem__c
                             WHERE ServiceItem__c IN :setServiceItemId 
                             AND EndDate__c <= :moveInDate ORDER BY EndDate__c DESC];
              
            if(!listBillItems.isEmpty()){
                lastBillItemEndDate = listBillItems[0].EndDate__c;
            }
        }
        return lastBillItemEndDate;
    }
}