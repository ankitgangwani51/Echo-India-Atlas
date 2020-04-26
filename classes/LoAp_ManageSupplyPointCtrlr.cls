public with sharing class LoAp_ManageSupplyPointCtrlr {
    private static List<string> supplyPointFields;
    static{
        supplyPointFields = new List<string>();
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.NAMEAPINAME);
        supplyPointFields.add(GlUt_APIConstantsSupplyPoint.BOOKRELAPINAME);
    }
    private static List<string> deviceFields;
    static{
        deviceFields = new List<string>();
        deviceFields.add(GlUt_APIConstantsDevice.DEVICENAMEAPINAME);
    }
    private static List<string> depotFields;
    static{
        depotFields = new List<string>();
        depotFields.add(GlUt_APIConstantsDepot.AREAAPINAME);
    }
    @AuraEnabled
    Public static ContainerWrapper getInfoToDisplay(Id locationId){
        //instance of wrapper class
        ContainerWrapper resultContainer = new ContainerWrapper(); 
        //call to method to get field properties
        resultContainer.fieldPropList = retrievePropDetails();
        //Call Method to get the service OR available service Details
        resultContainer.combinedList = getLocationRelatedInformation(locationId);
        return resultContainer;
    }
     public class ContainerWrapper {
        @AuraEnabled public List<GLAp_FieldProps> fieldPropList = new List<GLAp_FieldProps>(); //Field Property List.
        @AuraEnabled public List<BlAp_CombinedRecord> combinedList = new List<BlAp_CombinedRecord>(); //Combined record list

    }
    @AuraEnabled
    public static List<GLAp_FieldProps> retrievePropDetails() {
        try {
            List<GLAp_FieldProps> spProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsBook.BOOKAPINAME, supplyPointFields);
            List<GLAp_FieldProps> deviceProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsDepot.DepotAPINAME, deviceFields);
            List<GLAp_FieldProps> depotProps = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsArea.AreaAPINAME, depotFields);
            List<GLAp_FieldProps> fldPropList = new List<GLAp_FieldProps>();
            for (GLAp_FieldProps fldProp : spProps) {
                fldProp.isEditable = false;
                fldPropList.add(fldProp); 
            }
            for (GLAp_FieldProps fldProp : deviceProps) {
                fldProp.isEditable = false;
                fldPropList.add(fldProp); 
            }
            for (GLAp_FieldProps fldProp : depotProps) {
                fldProp.isEditable = false;
                fldPropList.add(fldProp); 
            }
            return fldPropList;

        }
        catch (exception e) {
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    @AuraEnabled
    public static List<BlAp_CombinedRecord> getLocationRelatedInformation(Id locationId) {
        return null;
        
    }
    

}