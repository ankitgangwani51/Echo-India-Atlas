/******************************************************************************
@author         Accenture: Patrick Dixon
@date           15 Sep 2017
@description    Class to define the objects, fields and relationships that will 
                be used to construct the PDF XML data records submitted to the  
                the PDF generation webservice
*******************************************************************************/
public with sharing class BlIn_PDFXMLDefinition {
    
    // list of XMLObjects used to generate the PDF data
    public List<BlIn_PDFBillData.XMLObject> XMLObjects;
    
    /******************************************************************************
    @author         Accenture: Patrick Dixon
    @date           15 Sep 2017
    @description    Constructor
    *******************************************************************************/
    public BlIn_PDFXMLDefinition() {
        
        // define a list of XML objects
        XMLObjects = new List<BlIn_PDFBillData.XMLObject>{
        
            /* Bill */
            new BlIn_PDFBillData.XMLObject(
            
                    CuAp_Constants.BILL,              /* Object API name */
                    null,                   /* Parent object API name */
                    null,                   /* Parent Id field */
                    new Set<String>{        /* Id fields used to match object records*/
                                    CuAp_Constants.ACCOUNT,        // Account //AT-3174 
                                    CuAp_Constants.CONTRACTNUMBER         // Contract__c
                                    }, 
                    new Set<String>{        /* XML fields */
                                    CuAp_Constants.BILLNAME, 
                                    CuAp_Constants.BILLDATE, 
                                    CuAp_Constants.BILLFROM, 
                                    CuAp_Constants.BILLTO, 
                                    CuAp_Constants.BILLEDAMOUNT 
                                    //CuAp_Constants.TOTALDUE
                                    } 
                    ),
        
            /* Bill Service Types */
            new BlIn_PDFBillData.XMLObject(
            
                    CuAp_Constants.BILLSERVICETYPEAPINAME,       /* Object API name */
                    CuAp_Constants.BILL,                  /* Parent object API name */
                    CuAp_Constants.BILL,                  /* Parent Id field */
                    new Set<String>(),          /* Id fields used to match object records*/
                    new Set<String>{            /* XML fields */
                                    CuAp_Constants.BILLSERVTYPENAME, 
                                    CuAp_Constants.SERVICETYPENAME, 
                                    CuAp_Constants.TOTALBILLEDAMOUNT 
                                    } 
                    ),
        
            /* Bill Items */
            new BlIn_PDFBillData.XMLObject(
            
                    CuAp_Constants.BILLITEMAPINAME,              /* Object API name */
                    CuAp_Constants.BILLSERVICETYPEAPINAME,       /* Parent object API name */
                    CuAp_Constants.BILLSERVICETYPEAPINAME,       /* Parent Id field */
                    new Set<String>(),          /* Id fields used to match object records*/
                    new Set<String>{            /* XML fields */
                                    CuAp_Constants.SERVICEITEMNAME, 
                                    CuAp_Constants.SERVICEITEMTOSERVICEITEMTYPENAME, 
                                    CuAp_Constants.BILLSERVICETYPETOSERVICEITEMTYPENAME, 
                                    CuAp_Constants.VOLUMEUSED, 
                                    CuAp_Constants.NUMBEROFDAYS, 
                                    CuAp_Constants.RATEBANDRATE, 
                                    CuAp_Constants.RATERETAILAMOUNT, 
                                    CuAp_Constants.RATEWHOLESALEAMOUNT, 
                                    CuAp_Constants.BILLITEMAMOUNT, 
//                                  'VATAmount__c',  
                                    CuAp_Constants.READINGACTUALDEVICEREADING, 
                                    CuAp_Constants.READINGTODEVICEREFSERIALNO, 
                                    //CuAp_Constants.READINGGROSSCONSUMPTION, - Core-7b -- Swati- 26-07-2018 - the has has been deleted so commenting out 
                                    CuAp_Constants.READING, 
                                    //CuAp_Constants.READDATE, 
                                    CuAp_Constants.READINGREADTYPE  
                                    } 
                    ),
        
            /* Account */
            new BlIn_PDFBillData.XMLObject(
            
                    CuAp_Constants.ACCOUNTAPINAME,              /* Object API name */
                    null,                   /* Parent object API name */
                    null,                   /* Parent Id field */
                    new Set<String>(),      /* Id fields used to match object records*/
                    new Set<String>{        /* XML fields */
                                    CuAp_Constants.ACCOUNTNAME, 
                                    CuAp_Constants.ACCOUNTREF, 
                                    CuAp_Constants.ACCEMAIL, 
                                    CuAp_Constants.FAX, 
                                    CuAp_Constants.WEBSITE 
                                    }   
                    ),

            /* Contract */
            new BlIn_PDFBillData.XMLObject(
            
                    CuAp_Constants.CONTRACTAPINAME,          /* Object API name */
                    null,                   /* Parent object API name */
                    null,                   /* Parent Id field */
                    new Set<String>{        /* Id fields used to match object records*/
                                    CuAp_Constants.HOUSEHOLDBILLINGAPINAME              // Location__c
                                    }, 
                    new Set<String>{        /* XML fields */
                                    CuAp_Constants.CONTRACTNAME, 
                                    CuAp_Constants.BILLINGADDRESSAPINAME, 
                                    CuAp_Constants.BILLINGFREQ  
                                    } 
                    ),

            /* Location*/
            new BlIn_PDFBillData.XMLObject(
            
                    CuAp_Constants.LOCATIONAPINAME,         /* Object API name */
                    null,                   /* Parent object API name */
                    null,                   /* Parent Id field API name */
                    new Set<String>(),      /* Id fields used to match child object records*/
                    new Set<String>{        /* XML fields */
                                    CuAp_Constants.LOCATIONNAME, 
                                    CuAp_Constants.NUMBEROFOCCUPIER 
                                    } 
                    ),

            /* Location Occupants */
            new BlIn_PDFBillData.XMLObject(
            
                    CuAp_Constants.LOCATIONOCCUPANTAPI, /* Object API name */
                    CuAp_Constants.LOCATIONAPINAME,         /* Parent object API name */
                    CuAp_Constants.LOCATIONAPINAME,         /* Parent Id field API name */
                    new Set<String>(),      /* Id fields used to match child object records*/
                    new Set<String>{        /* XML fields */
                                    CuAp_Constants.LOCOCCNAME, 
                                    CuAp_Constants.ACCNAME, 
                                    CuAp_Constants.LOCATIONOCCUPANTSTARTDATE, 
                                    CuAp_Constants.LOCATIONOCCUPANTENDDATE, 
                                    CuAp_Constants.PRIMARY, 
                                    CuAp_Constants.SHOWBILL 
                                    } 
                    ),

            /* Payment Plans */
            new BlIn_PDFBillData.XMLObject(
            
                    CuAp_Constants.PAYMENTPLAN,       /* Object API name */
                    CuAp_Constants.CONTRACTAPINAME,          /* Parent object API name */
                    CuAp_Constants.CONTRACTORDER,     /* Parent Id field */
                    new Set<String>(),      /* Id fields used to match child object records*/
                    new Set<String>{        /* XML fields */
                                    CuAp_Constants.PAYMENTFREQ, 
                                    CuAp_Constants.PAYMENTPLANTYPENAME, 
                                    CuAp_Constants.PLANAMOUNT, 
                                    CuAp_Constants.STARTDATE  
                                    } 
                    ),

            /* Services */
            new BlIn_PDFBillData.XMLObject(
            
                    CuAp_Constants.SERVICEAPINAME,           /* Object API name */
                    CuAp_Constants.CONTRACTAPINAME,          /* Parent object API name */
                    CuAp_Constants.CONTRACTAPINAME,          /* Parent Id field */
                    new Set<String>(),      /* Id fields used to match child object records*/
                    new Set<String>{        /* XML fields */
                                    CuAp_Constants.SERVICETYPENAME,
                                    //CuAp_Constants.DEVICESERIALNO,    Mt - 26-03-2018 As device and dervice lookup has been deleted so, it not needed now.
                                    CuAp_Constants.SUPPLYPOINTLOCPOSTALCODE, 
                                    CuAp_Constants.SUPPLYPOINTID  
                                    } 
                    )
        };
    }
}