/******************************************************************************
@author         Echo: Dependra Singh
@date           18 Dec 2018
@description : This class is used to Deserialize the parse JSON string.
**********************************************************************************************/
public with sharing class CuPr_ConcessionExportParameters {
    public ID timetableID ;
    public ID periodID;
    public List<Id> booksToExport ;
  
    /**********************************************************************************************
	@author  	 :Echo: Dependra Singh
	@date        : 18 Dec 2018
    @params      : String json
    @return      : CuPr_ConcessionExportParameters
    @description : This method is used to Deserialize the parse JSON string.
    **********************************************************************************************/
    public static CuPr_ConcessionExportParameters parse(String json) {
        return (CuPr_ConcessionExportParameters) System.JSON.deserialize(json, CuPr_ConcessionExportParameters.class);
    }
}