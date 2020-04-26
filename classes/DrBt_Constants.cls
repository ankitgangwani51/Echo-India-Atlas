/******************************************************************************
@author:      Echo: Mohit Tayal
@date:        31 January 2018
@description: This is the constant class for all static strings used in Debt Recovery 
*******************************************************************************/
public with sharing class DrBt_Constants {

    public static string PREFIX = 'DrBt_';
    public static string ID = 'Id';
    
    public static final String TOBEDISCONNECTED  = 'To Be Disconnected';
    
    public static final String CHANGEPAYMENTPLAN   = 'Change Payment Plan';
    public static final String ADDADDTNALSERVICES  = 'Add Additional Services';
    public static final String SENDRMNDRLETTER     = 'Send Reminder Letter';
    public static final String SENDDISCONNOTICE    = 'Send Disconnection Notice';
    public static final String SENDLETTER          = 'Send Letter';
    public static final String CALCULATEBILL       = 'Calculate Bill';
    public static final String MARKFFORDISCONCTION = 'Mark For Disconnection';
    public static final String CHANGRECOVRYPROFILE = 'Change Recovery Profile';
    
    public static final String ERROR = 'Error';
    public static final String PROCESSED = 'Processed';
    public static final String COMPLETED = 'Completed';
}