/************************************************************************************************************
@author         Echo : Tarun Gupta
@date           27-Feb-2018
@description:   This is the constants class for all static fields used in the location object
                Please no revisions in constants classes, but use comments so that it's clear how the constants are being used
**************************************************************************************************************/
public class GlUt_APIConstantsLocationOccupant {
    
    // Get the prefix and append it to the object and fields api names
    private static String NAMESPACEPREFIX = GlUt_NamespacePrefix.getNamespacePrefix();
    
    // Location Object API Name
    public static String  LOCATIONOCCUPANTAPINAME = NAMESPACEPREFIX + 'LocationOccupant__c';
    
    // Location object fields API Names
	public static String NAMEAPINAME 				= 'Name';
    public static String LOCATIONOCCUPANTSTARTDATE 	= NAMESPACEPREFIX + 'StartDate__c';
    public static String OCCUPANCYTYPEAPI 			= NAMESPACEPREFIX + 'OccupancyType__c';
    public static String LOCATIONOCCUPANTENDDATE 	= NAMESPACEPREFIX + 'EndDate__c'; 
    
    public static final String LOCATIONOCCUPANTSTARTDATEOLDLABEL = 'Start Date';
    public static final String LOCATIONOCCUPANTENDDATEOLDLABEL = 'End Date';
    public static final String LOCATIONOCCUPANTOCCTYPEOLDLABEL = 'Occupancy Type';
    public static final String LOCATIONOCCUPANTSTARTDATENEWLABEL = 'Move In Date';
    public static final String LOCATIONOCCUPANTENDDATENEWLABEL   = 'Move Out Date';
    public static final String OCCUPANCYTYPE        = 'Landlord';
    public static final String SOQLCONDITION   = ' AND ((' + NAMESPACEPREFIX + 'StartDate__c <=TODAY AND' + ' ' + NAMESPACEPREFIX + 'EndDate__c=Null) OR (' + NAMESPACEPREFIX + 'StartDate__c <=TODAY AND' + ' ' + NAMESPACEPREFIX + 'EndDate__c>TODAY) OR (' + NAMESPACEPREFIX + 'StartDate__c >TODAY))';
    public static final String LOCATIONOCCUPANTACCOUNT   = NAMESPACEPREFIX + 'Account__c';
    public static final String LOCATIONOCCUPANTACTIVE    = NAMESPACEPREFIX + 'Active__c';
    public static final String PRIMARY = NAMESPACEPREFIX + 'Primary__c';
    public static final String LOCATIONOCCUPANTLOCATION  = NAMESPACEPREFIX + 'Location__c';
    public static final String SHOWONBILLAPINAME  = NAMESPACEPREFIX + 'ShowOnBill__c';
    public static final String OCCUPANCYTYPETENANT        = 'Tenant';
    
    public static final String LOCATIONOCCUPANTOCCUPANCYTYPELABEL = 'Occupancy Type';
    public static final String PREVIOUSLOCATIONOCCUPANTLABEL = 'PreviousOcc__c'; // Not to use NAMESPACEPREFIX
    public static final String SUBSEQUENTLOCATIONOCCUPANTLABEL = 'SubsequentOcc__c'; // Not to use NAMESPACEPREFIX
    // Added By Dependra 




}