/***************************************************************************************************
@author        Echo: Dependra Singh
@date          12-Feb-2019
@description:  Test Class of GlUt_CustomMetaDataUtility
*******************************************************************************************************/
@isTest
public class GlUt_CustomMetaDataUtility_Test {
    private static String SIZEMATCH = 'Size should match';
    /*******************************************************************
    Purpose: method to create test data of Custom Metadata Records
    Parameters: N/A 
    Returns: void
    Throws [Exceptions]: N/A
    ********************************************************************/
    public static testMethod void testGetMetadata() {
        List<SObject> customMetadataRecords;
        Test.startTest();
        customMetadataRecords = new GlUt_CustomMetaDataUtility().getCustomMetadataRecords( 'SELECT BillTemplateLibraryName__c FROM EnvironmentSettings__mdt LIMIT 1' );
        Test.stopTest();
        System.assertEquals( [ SELECT BillTemplateLibraryName__c FROM EnvironmentSettings__mdt LIMIT 1 ].size(), customMetadataRecords.size(), SIZEMATCH);
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
}