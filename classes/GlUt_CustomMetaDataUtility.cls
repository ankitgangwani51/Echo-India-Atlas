/***************************************************************************************************
@author        Echo: Dependra Singh
@date          12-Feb-2019
@description:  This Class is used to get the data of meta data and generate the map.
*******************************************************************************************************/
public class GlUt_CustomMetaDataUtility {
    @testVisible  public static Map<String, List<SObject>> customMetadataRecordsMap = new Map<String, List<SObject>>();
    /***************************************************************************************************
    @author        Echo: Dependra Singh
    @date          12-Feb-2019
	@parameter	   String query
	@return		   List<SObject>
    @description:  Method is used to create map and return list of sobject of metadata type.
    *******************************************************************************************************/
    public List<SObject> getCustomMetadataRecords(String query) {
        if ( !customMetadataRecordsMap.containsKey( query ) ) {
            customMetadataRecordsMap.put( query, Database.query(query));
        }
        return customMetadataRecordsMap.get( query );
    }
    /***************************************************************************************************
    @author        Echo: Dependra Singh
    @date          18-June-2018
	@parameter	   String query, List<SObject> records
	@return		   Void
    @description:  Method is used to set Meta Data in Map
    *******************************************************************************************************/
    public static void setMetadata( String query, List<SObject> records ) {
        GlUt_CustomMetaDataUtility.customMetadataRecordsMap.put( query, records );
    }
    /******************************************************************************
    @author         Echo:Dependra Singh
    @date           14 Mar 2019
    @description    Method is used to set custom meta data  type data for Enviroment Setting.
    *******************************************************************************/
    public static EnvironmentSettings__mdt getEnviromentSettingDetails(String query){
        List<EnvironmentSettings__mdt> mdts = new  List<EnvironmentSettings__mdt>();
        if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap != null && GlUt_CustomMetaDataUtility.customMetadataRecordsMap.keyset().size()  > 0){
            if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap.containsKey(query)){
                mdts = (List<EnvironmentSettings__mdt>)GlUt_CustomMetaDataUtility.customMetadataRecordsMap.get(query);  
            }
        }else{
            mdts = (List<EnvironmentSettings__mdt>) new GlUt_CustomMetaDataUtility().getCustomMetadataRecords(query);
        }
        if(mdts != null && mdts.size() > 0){
            return mdts[0];
        }else{
            return null;
        }
    }
    /******************************************************************************
    @author         Echo:Dependra Singh
    @date           11 Mar 2019
    @description    Method is used to set custom meta data  type data for Combiz Interface
    *******************************************************************************/
    public static CombizInterface__mdt getCustomDataforCombizInterface(string query){
        List<CombizInterface__mdt> mdts = new  List<CombizInterface__mdt>();
        if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap != null && GlUt_CustomMetaDataUtility.customMetadataRecordsMap.keyset().size()  > 0){
            if(GlUt_CustomMetaDataUtility.customMetadataRecordsMap.containsKey(query)){
                mdts = (List<CombizInterface__mdt>)GlUt_CustomMetaDataUtility.customMetadataRecordsMap.get(query);  
            }
        }else{
            mdts = (List<CombizInterface__mdt>) new GlUt_CustomMetaDataUtility().getCustomMetadataRecords(query);
        }
        if(mdts != null && mdts.size() > 0){
            return mdts[0];
        }else{
            return null;
        }
    }
}