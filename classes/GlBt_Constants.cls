/************************************************************************************************************
@author         Gopal Gupta
@date           12-Apr-2018
@description:   This is the constants class for all static strings used in this namespace
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlBt_Constants {
    
    //Constants used in GlUt_BatchRequestQueueHandler class
    //Constants for Status picklist field of the AsyncApexJob object
    public static final String APEXQUEUEINFOHOLDINGSTATUS = 'Holding';
    public static final String APEXQUEUEINFOQUEUEDSTATUS = 'Queued';
    public static final String APEXQUEUEINFOPROCESSINGSTATUS = 'Processing';
    public static final String APEXQUEUEINFOPREPARINGSTATUS = 'Preparing';
    public static final String APEXQUEUEINFOABORTEDSTATUS = 'Aborted';
    public static final String APEXQUEUEINFOCOMPLETEDSTATUS = 'Completed';
    
    //Constants for Priority picklist field of the BRQ object
    public static final String BRQVERYHIGHPRIORITY = 'Very High';
    public static final String BRQHIGHPRIORITY = 'High';
    public static final String BRQMEDIUMPRIORITY = 'Medium';
    public static final String BRQLOWPRIORITY = 'Low';
    
    //Constants for Status picklist field of the BRQ object
    // These should be custom labels!! 
    public static final String BRQWAITINGSTATUS = 'Waiting';
    public static final String BRQERRORSSTATUS = 'Errors';
    public static final String BRQCANCELLEDSTATUS = 'Cancelled';
    public static final String BRQCOMPLETEDSTATUS = 'Completed';
    public static final String BRQPROCESSINGSTATUS = Label.GlAp_Processing;
    public static final String BRQPENDINGSTATUS = Label.GlAp_Pending;
    public static final String BRQINITIALISEDSTATUS = Label.GlAp_Initialised;
    public static final String BRQLOADINGDSTATUS = 'Loading';
}