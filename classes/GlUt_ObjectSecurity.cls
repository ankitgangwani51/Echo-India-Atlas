/************************************************************************************************************
@author         Echo: Amit K.
@date           09-Jan-2019
@description:   This class is used to check the object level permission Check i.e. CRUD.
Revision(s)     
**************************************************************************************************************/
public class GlUt_ObjectSecurity {
    
    private static final String CLASS_NAME = 'GlUt_ObjectSecurity';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';

    /**********************************************************************************************
    @author         Echo: Amit K.
    @date           09-Jan-2019
    @param          List<sObject> records,Boolean isDeletePermission,
    @param          Boolean isCreateablePermission,Boolean isUpdateablePermission,Boolean isAllPermissionCheck,
    @param          Boolean isUpsertPermissionCheck
    @return         Boolean - True/False
    @description    pass the list of records and check the object CRUD level permission for upsert records
    **********************************************************************************************/
    public static Boolean isObjectPermission(List<sObject> records,Boolean isDeletePermission,Boolean isCreateablePermission,Boolean isUpdateablePermission,Boolean isAllPermissionCheck, Boolean isUpsertPermissionCheck) {
        Boolean isPermission = false;
        if (!records.isEmpty() && records != null) {
            if(isDeletePermission || isCreateablePermission || isUpdateablePermission){
                isPermission = isObjectPermission(records,isDeletePermission,isCreateablePermission,isUpdateablePermission);
            }
            else if(isAllPermissionCheck){
                isPermission = isObjectPermission(records,isAllPermissionCheck);
            }
            else if(isUpsertPermissionCheck){
                isPermission = isObjectPermission(records);
            }
        }
        return isPermission;
    }
    /**********************************************************************************************
    @author         Echo: Amit K.
    @date           09-Jan-2019
    @param          List<sObject> records
    @return         Boolean - True/False
    @description    pass the list of records and check the object CRUD level permission for upsert records
    **********************************************************************************************/
    public static Boolean isObjectPermission(List<sObject> records) {
        Boolean isPermission = false;
        if (!records.isEmpty() && records != null) {
            Set<String> isCreateObjectNameList = new Set<String>();
            Set<String> isUpdateObjectNameList = new Set<String>();
            Set<Boolean> isPermissionList = new Set<Boolean>();
            for (SObject record : records) {
                if(record.get('Id') != null)
                    isUpdateObjectNameList.add(getTypeofSObject(record)); 
                else
                    isCreateObjectNameList.add(getTypeofSObject(record)); 
            }
            if(!isCreateObjectNameList.isEmpty()){
                for(String objectName : isCreateObjectNameList){
                    SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
                    if(sObjectType.getDescribe().isAccessible() && sObjectType.getDescribe().isCreateable())
                        isPermissionList.add(true);
                    else
                        isPermissionList.add(false);
                }
            }
            if(!isUpdateObjectNameList.isEmpty()){
                for(String objectName : isUpdateObjectNameList){
                    SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
                    if(sObjectType.getDescribe().isAccessible() && sObjectType.getDescribe().isUpdateable())
                        isPermissionList.add(true);
                    else
                        isPermissionList.add(false);
                }
            }
            if(!isPermissionList.isEmpty()){
                if(!isPermissionList.contains(false))
                    isPermission = true;
            }
        }
        return isPermission;
    }

    /**********************************************************************************************
    @author         Echo: Amit K.
    @date           09-Jan-2019
    @param          List<sObject> records,Boolean isDeletePermission,
    @param          Boolean isCreateablePermission,Boolean isUpdateablePermission
    @return         Boolean - True/False
    @description    pass the list of records and check the object CRUD level permission of perticular type
                    i.e. Delete or Create or Update
    **********************************************************************************************/
    public static Boolean isObjectPermission(List<sObject> records,Boolean isDeletePermission,Boolean isCreateablePermission,Boolean isUpdateablePermission) {
        Boolean isPermission = false;
        if (!records.isEmpty() && records != null) {
            Set<String> objectNameList = new Set<String>();
            for (SObject record : records) {
                objectNameList.add(getTypeofSObject(record)); 
            }
            if(!objectNameList.isEmpty()){
                Set<Boolean> isPermissionList = new Set<Boolean>();
                for(String objectName : objectNameList){
                    SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
                    if(sObjectType.getDescribe().isAccessible() && isDeletePermission)
                        isPermissionList.add(sObjectType.getDescribe().isDeletable());
                    else if(sObjectType.getDescribe().isAccessible() && isCreateablePermission)
                        isPermissionList.add(sObjectType.getDescribe().isCreateable());
                    else if(sObjectType.getDescribe().isAccessible() && isUpdateablePermission)
                        isPermissionList.add(sObjectType.getDescribe().isUpdateable());
                    else
                        isPermissionList.add(false);
                }
                if(!isPermissionList.isEmpty()){
                    if(!isPermissionList.contains(false))
                        isPermission = true;
                }
            }
        }
        return isPermission;
    }
    /**********************************************************************************************
    @author         Echo: Amit K.
    @date           09-Jan-2019
    @param          List<sObject> records,Boolean isAllPermissionCheck
    @return         Boolean - True/False
    @description    pass the list of records and check the object CRUD level permission
    **********************************************************************************************/
    public static Boolean isObjectPermission(List<sObject> records,Boolean isAllPermissionCheck) {
        Boolean isPermission = false;
        if (!records.isEmpty() && records != null) {
            Set<String> objectNameList = new Set<String>();
            for (SObject record : records) {
                objectNameList.add(getTypeofSObject(record)); 
            }
            if(!objectNameList.isEmpty()){
                Set<Boolean> isPermissionList = new Set<Boolean>();
                for(String objectName : objectNameList){
                    SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
                    if(isAllPermissionCheck && sObjectType.getDescribe().isDeletable() && sObjectType.getDescribe().isAccessible() && sObjectType.getDescribe().isCreateable() && sObjectType.getDescribe().isUpdateable())
                        isPermissionList.add(true);
                    else
                        isPermissionList.add(false);
                }
                if(!isPermissionList.isEmpty()){
                    if(!isPermissionList.contains(false))
                        isPermission = true;
                }
            }
        }
        return isPermission;
    }
    /**********************************************************************************************
    @author         Echo: Amit K.
    @date           09-Jan-2019
    @param          sObject obj
    @return         string - Object name
    @description    pass the record and return object name for that record
    **********************************************************************************************/
    private static string getTypeofSObject(sObject obj){
        return obj.getSObjectType().getDescribe().getName();       
    }
}