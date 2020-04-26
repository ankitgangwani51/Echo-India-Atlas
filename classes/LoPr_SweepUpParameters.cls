/******************************************************************************
    @author         Echo: Amit K.
    @date           28 May 2018
    @description    Wrapper class for Sweep Up estimate.
*******************************************************************************/
public with sharing class LoPr_SweepUpParameters {
    public Id timetableID;  //the Id of the Reading Timetable.
    public Id periodID;    // the Id of the Period .
    public List<Id> booksToEstimate; //a List of Books selected for Sweep Up estimate.
    public string executionMode; //Either Selected/All
    /**********************************************************************************************
    @author      : Echo:Amit K.
    @date        : 28 May 2018
    @params      : String json
    @return      : LoPr_SweepUpParameters
    @description : This method is used to Deserialize the parse JSON string.
    **********************************************************************************************/
    public static LoPr_SweepUpParameters parse(String json) {
        return (LoPr_SweepUpParameters) System.JSON.deserialize(json, LoPr_SweepUpParameters.class);
    }
    
}