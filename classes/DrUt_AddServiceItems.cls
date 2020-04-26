/******************************************************************************
@author         Andrew Edge
@date           01 Sep 2017
@description    Class for adding Service Items to a Sundry service based on a DebtRecoveryAction__c.
				Bundle to be added is defined in Parameters__c field
*******************************************************************************/
public class DrUt_AddServiceItems {
    /******************************************************************************
    @author         Andrew Edge
    @date           18 Sep 2017
    @description    Wrapper of the new service list and debt recovery action id and 
                    it's corresponding service id record map
    *******************************************************************************/
    public class DrUt_AddServiceItemsWrapper{
       public Map<Id,Id> debtRecActIdServiceIdMap {get; set;}
       public List<Service__c> newServiceList {get; set;}
        public DrUt_AddServiceItemsWrapper(){
            debtRecActIdServiceIdMap = new Map<Id,Id>();
            newServiceList = new List<Service__c>();
        }
    }
         
    /******************************************************************************
    @author         Andrew Edge
    @date           18 Sep 2017
    @param          recList - List of DebtRecoveryAction__c objects
    @return         void
    @description    Debt Recovery Action Processing -Works on DebtRecoveryAction__c objects of 
					the type 'addServiceItem'
                    AT-4891/2 Code Check Marx Changes for FLS INSERT/UPDATE
    *******************************************************************************/
    public static void addServiceItem(List<Id> recList){
              
        Map<Id,Bundle__c> debtRecActIdBundlemap = new Map<Id,Bundle__c>();
        Map<String,Bundle__c> bundleNameRecMap = new Map<String,Bundle__c>();
        Map<Id,Id> debtRecActIdServiceIdMap = new Map<Id,Id>();
        List<ServiceItem__c> servItemList = new List<ServiceItem__c>();
                
        /*Fetching Debt. Recovery Action Records*/
        List<DebtRecoveryAction__c> debtRecActionList =  [SELECT Id , Parameters__c , Date__c, DebtRecoveryProcess__r.BillingContract__c FROM DebtRecoveryAction__c WHERE Id IN :recList];
        //Id Set of all Contracts
        Set<Id> contractIdSet = new Set<Id>();
        Set<String> debtRecActParamSet = new Set<String>();
        
        //creating set for values present in the parameter field of debt recovery action and corresponding contract 
        for(DebtRecoveryAction__c debtRecAct : debtRecActionList){
            debtRecActParamSet.add(debtRecAct.Parameters__c);
            contractIdSet.add(debtRecAct.DebtRecoveryProcess__r.BillingContract__c);
        }
        
        //fetching the bundles via the value present in the debt recovery action parameter field
        List<Bundle__c> bundleList = [SELECT Id, Name, ServiceType__c, (SELECT Id, ServiceItemFamily__c , ServiceItemType__c FROM BundleItems__r) FROM Bundle__c WHERE Name IN :debtRecActParamSet];
        //Get services for each of the contracts
        List<Service__c> serviceList = [SELECT Id, ServiceType__c, BillingContract__c, ServiceStartDate__c, ServiceEndDate__c FROM Service__c WHERE BillingContract__c IN:contractIdSet];
        
        //creating the map of bundle name and it's record for further processing
        for(Bundle__c bunbleRec : bundleList){
            if(!bundleNameRecMap.containsKey(bunbleRec.Name)){
                bundleNameRecMap.put(bunbleRec.Name, bunbleRec);
            }
        }
        
        for(DebtRecoveryAction__c debtRecAct : debtRecActionList){
            if(bundleNameRecMap.containsKey(debtRecAct.Parameters__c)){   // Debt Recovery Action parameter field is used to refer the Bundle object  
                debtRecActIdBundlemap.put(debtRecAct.Id,bundleNameRecMap.get(debtRecAct.Parameters__c));       //Binding Bundle with Debt. Recovery Action Id using Parameters               
            }          
        }            
        
        //calling createService method
        DrUt_AddServiceItemsWrapper addServiceItemsWrapperFirst = createService(debtRecActionList, serviceList, debtRecActIdBundlemap, debtRecActIdServiceIdMap);
        
        DrUt_AddServiceItemsWrapper addServiceItemsWrapperSecond = addServiceItemsWrapperFirst;
        
        if(addServiceItemsWrapperFirst.newServiceList.size() > 0){
            addServiceItemsWrapperFirst.newServiceList = (List<Service__c>) GlUt_FieldSecurity.cleanseFields(addServiceItemsWrapperFirst.newServiceList, false); //AT-4891 Code Check Marx Changes Starts/Ends Here.
            Database.insert(addServiceItemsWrapperFirst.newServiceList);
            addServiceItemsWrapperSecond = createService(debtRecActionList, addServiceItemsWrapperFirst.newServiceList, debtRecActIdBundlemap, addServiceItemsWrapperFirst.debtRecActIdServiceIdMap);        
        }
        
        //Run through the action list again to add the service items associated with the service
        for(DebtRecoveryAction__c debtRecAct : debtRecActionList){
            if(debtRecActIdBundlemap.containsKey(debtRecAct.Id)){
                for(BundleItem__c bI : debtRecActIdBundlemap.get(debtRecAct.Id).BundleItems__r){
                    ServiceItem__c objServiceItem     = new ServiceItem__c();              /*Creating Service Items Using Bundle Items*/
                    objServiceItem.Service__c         =  addServiceItemsWrapperSecond.debtRecActIdServiceIdMap.get(debtRecAct.Id);
                    objServiceItem.ServiceItemType__c =  bI.ServiceItemType__c;
                    objServiceItem.StartDate__c       =  debtRecAct.Date__c;
                    servItemList.add(objServiceItem);
                }
                debtRecAct.Processed__c = true;
            }
        }
        //AT-4891 Code Check Marx Changes Starts Here.
        if(!servItemList.isEmpty()){
            servItemList = (List<ServiceItem__c>) GlUt_FieldSecurity.cleanseFields(servItemList, false); 
            // insert service items
            Database.insert(servItemList); 
        }
        //AT-4891 Code Check Marx Changes Ends Here.
        //AT-4892 Code Check Marx Changes Starts Here.
        if(!debtRecActionList.isEmpty()){
            // insert processed Debt recovery actions
            debtRecActionList = (List<DebtRecoveryAction__c>) GlUt_FieldSecurity.cleanseFields(debtRecActionList, false); 
            Database.update(debtRecActionList); 
        }
        //AT-4892 Code Check Marx Changes Ends Here.
    }   
    
    /******************************************************************************
    @author         Mohit Tayal
    @date           25 Jan 2017
    @param          debtRecActionList - List of DebtRecoveryAction__c objects
                    serviceList - existing service on the contracts
                    debtRecActIdBundlemap - debt recovery action id and it's corresponding bundle record map
                    debtRecActIdServiceIdMap - debt recovery action id and it's corresponding service id record map
    @return         DrUt_AddServiceItemsWrapper - Wrapper of the new service list and debt recovery action id and 
                                                  it's corresponding service id record map
    @description    Creating service records - create service record if a service is not present on the contract 
                    for the service type associated with the bundle.. and active based on dates.
                    Also creating the Map of debt recovery action id and it's corresponding service id
    *******************************************************************************/
  
    public static DrUt_AddServiceItemsWrapper createService(List<DebtRecoveryAction__c> debtRecActionList, 
                                                            List<Service__c> serviceList, 
                                                            Map<Id,Bundle__c> debtRecActIdBundlemap, 
                                                            Map<Id,Id> debtRecActIdServiceIdMap){
        
        Boolean serviceAvailable = false;
        List<Service__c> newServiceList = new List<Service__c>();
        Map<Id,List<Service__c>> contractIdServiceMap = new Map<Id,List<Service__c>>();
        
        // creating the map for the services associated with the contract Id
        for(Service__c serviceRec : serviceList){
            if(!contractIdServiceMap.containsKey(serviceRec.BillingContract__c)){
                contractIdServiceMap.put(serviceRec.BillingContract__c, new List<Service__c>());  
            }
            contractIdServiceMap.get(serviceRec.BillingContract__c).add(serviceRec);
        }
        
        /*Create a Map of all Contracts that already have the service for this bundle and creating the service if is not present on the contract 
          for the service type associated with the bundle.. and active based on dates*/
        for(DebtRecoveryAction__c debtRecAct : debtRecActionList){
            //Check if bundle exists against a debt recovery action
            if(debtRecActIdBundlemap.containsKey(debtRecAct.Id)){
                serviceAvailable = FALSE;
                if(contractIdServiceMap.containsKey(debtRecAct.DebtRecoveryProcess__r.BillingContract__c)){
                    for(Service__c serviceRec : contractIdServiceMap.get(debtRecAct.DebtRecoveryProcess__r.BillingContract__c)){
                        if(serviceRec.ServiceType__c == debtRecActIdBundlemap.get(debtRecAct.Id).ServiceType__c && (serviceRec.ServiceStartDate__c == null || 
                           serviceRec.ServiceStartDate__c <= debtRecAct.Date__c) && (serviceRec.ServiceEndDate__c > debtRecAct.Date__c || serviceRec.ServiceEndDate__c == null)){
                               debtRecActIdServiceIdMap.put(debtRecAct.Id,serviceRec.Id);                        
                               serviceAvailable = TRUE;
                               BREAK;
                           }
                    }
                }
                
                //If the Service isn't on the contract then create it
                if(!serviceAvailable){
                    Service__c objService = new Service__c();
                    objService.BillingContract__c     = debtRecAct.DebtRecoveryProcess__r.BillingContract__c;      //Debt Recovery Process - Contract
                    // serv.SupplyPoint__c  = ''  need to discuss 
                    objService.ServiceType__c  = debtRecActIdBundlemap.get(debtRecAct.Id).ServiceType__c;         //Bundle Object Service Type
                    newServiceList.add(objService);
                }
            }
        }
        system.debug('newServiceList====='+newServiceList);
        // creating new services and calling this method again to add the new services id against it's debt recovery action in the map      
        DrUt_AddServiceItemsWrapper wrapper = new DrUt_AddServiceItemsWrapper();
        wrapper.debtRecActIdServiceIdMap = debtRecActIdServiceIdMap;
        wrapper.newServiceList = newServiceList;
        system.debug('wrapper====='+wrapper);
        return wrapper;
    }
}