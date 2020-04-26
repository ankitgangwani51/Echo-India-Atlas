/******************************************************************************
@author         Echo: Amit K.
@date           08 May 2018
@description    Wrapper class for holding book export parameters
@revision(s)    
*******************************************************************************/
public with sharing class LoPr_BookExportParameters {
    public Id timetableID;  //the Id of the Reading Timetable being exported.
    public Id periodID;    // the Id of the Period being exported.
    public List<Id> booksToExport; //a List of Books selected for Export.
    /**********************************************************************************************
    @author      : Echo:Amit K.
    @date        : 08 May 2018
    @params      : String json
    @return      : LoPr_BookExportParameters
    @description : This method is used to Deserialize the parse JSON string.
    **********************************************************************************************/
    public static LoPr_BookExportParameters parse(String json) {
        
        return (LoPr_BookExportParameters) System.JSON.deserialize(json, LoPr_BookExportParameters.class);
    }
}