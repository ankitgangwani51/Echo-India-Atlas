/************************************************************************************************************
@author      : Echo : Ankit Gangwani
@date        : 03 Jan 2018
@description : CuAp_SetupInstalmentsCtrlr class is used to display instalments records
**************************************************************************************************************/
public with sharing class CuAp_SetupInstalmentsCtrlr {
    
    private static final String CLASS_NAME = 'CuAp_SetupInstalmentsCtrlr';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    private static List<string> instalmentFields;
    
    static{
        //Get Fields from the Instalment__c Object
        instalmentFields = new List<string>();
        instalmentFields.add(GlUt_APIConstantsInstalment.INSTALMENTNUMBERAPINAME);
        instalmentFields.add(GlUt_APIConstantsInstalment.INSTALMENTDUEDATEAPINAME);
        instalmentFields.add(GlUt_APIConstantsInstalment.INSTALMENTAMOUNTDUEAPINAME);
        instalmentFields.add(GlUt_APIConstantsInstalment.INSTALMENTTYPEAPINAME);
    }
    
    /**********************************************************************************************
    @author      : Echo : Ankit Gangwani
    @date        : 03 Jan 2018
    @return      : List<GLAp_FieldProps>
    @description : This method returns the field properties for each of the fields that are
    to be displayed on the screen
    **********************************************************************************************/
    @AuraEnabled
    public static List<GLAp_FieldProps> retrieveInstalmentPropDetails() {
        
        try{
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
            List<GLAp_FieldProps> allFieldProp = new List<GLAp_FieldProps>();
            
            //Get the field properties for the Instalment object
            List<GLAp_FieldProps> locProp = GlAp_LightningDataAccess.getObjectsFieldProperties(GlUt_APIConstantsInstalment.INSTALMENTAPINAME, instalmentFields); 
            
            for(GLAp_FieldProps intalmentProps: locProp){
                
                //Want to make all of the Instalment fields readonly
                intalmentProps.isEditable = false;
                if(intalmentProps.fieldName == GlUt_APIConstantsInstalment.INSTALMENTNUMBERAPINAME){
                    intalmentProps.fieldLabel = CuAp_Constants.INSTALMENTNUMBERLABEL;
                }
                
                if(intalmentProps.fieldName == GlUt_APIConstantsInstalment.INSTALMENTDUEDATEAPINAME){
                    intalmentProps.fieldLabel = CuAp_Constants.INSTALMENTDUEDATELABEL;
                    intalmentProps.isEditable = true;
                }
                
                if(intalmentProps.fieldName == GlUt_APIConstantsInstalment.INSTALMENTAMOUNTDUEAPINAME){
                    intalmentProps.fieldLabel = CuAp_Constants.INSTALMENTAMOUNTDUELABEL;
                    intalmentProps.isEditable = true;
                }
                
                allFieldProp.add(intalmentProps);
            } 
            
            return allFieldProp;
        }
        catch(Exception e){
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
    
    /**********************************************************************************************
    @author         Echo: Ankit Gangwani
    @date           03 Jan 2018
    @param          lstInstalments (List of instalments comes as a parameter from the parent component)
    @return         List<BlAp_CombinedRecord>
    @description    This method returns the BlAp_CombinedRecord with list of instalments, unique-ids, isSelected and readOnlyFields
    **********************************************************************************************/
    @AuraEnabled
    public static List<BlAp_CombinedRecord> retrieveInstalmentsRecord(String lstInstalments) {
        
        try{
            GlUt_Logger.logDebug(GlUt_Constants.EXECUTINGLGTHNGCMPCTRL + DEBUG);
            // Deserialise the JSON String into a list of spreadRemList
            List<Instalment__c> lstInstalmentsClient = (List<Instalment__c>)JSON.deserialize(lstInstalments, List<Instalment__c>.class);
            List<BlAp_CombinedRecord> instalmentCombinedList = new List<BlAp_CombinedRecord>();
            
            Integer iCount = 0;
            
            for(Instalment__c instobj : lstInstalmentsClient ){
                iCount = iCount + 1;
                BlAp_CombinedRecord instalmentObj = new BlAp_CombinedRecord(); 
                instalmentObj.uniqueId = String.valueOf(iCount);
                instalmentObj.isSelected = false;
                instalmentObj.objectMap = new Map<string, sObject>();
                instalmentObj.readOnlyFields = new Map<string, boolean>();
                instalmentObj.objectMap.put(GlUt_APIConstantsInstalment.INSTALMENTAPINAME, instobj);
                
                instalmentCombinedList.add(instalmentObj);
            }
            return instalmentCombinedList;
        }
        catch(Exception e){
            GlUt_Logger.logException(e);
            throw new AuraHandledException(e.getMessage());
        }
        finally {   
            GlUt_Logger.writeLogsToDatabase();
        }
    }
}