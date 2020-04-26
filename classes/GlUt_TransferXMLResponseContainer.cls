/******************************************************************************
@author         Echo: Sudhir Kumar
@date           01 Nov 2018
@description    Generic Transfer XML response structure from Heroku 
                - Currently being used in Information Statement. 
                - Future task: To use the same for Bill ??
*******************************************************************************/

public with sharing class GlUt_TransferXMLResponseContainer {
    
    public String dataXml ;
    public String printXml ; 
    public String billPdf ;
    public String statementPdf ;
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           01 Nov 2018
    @param          String - json
    @return         GlUt_TransferXMLResponseContainer - formatted Transfer XML response from heroku
    @description    parses and formats the JSON response 
    *******************************************************************************/
    
    public static GlUt_TransferXMLResponseContainer parse(String jsonString) {
        return (GlUt_TransferXMLResponseContainer) System.JSON.deserialize(jsonString , GlUt_TransferXMLResponseContainer.class) ;
    }
    
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           01 Nov 2018
    @param          GlUt_TransferXMLResponseContainer herokuResponse
    @return         Boolean - return true/false when
    @description    process the response 
    *******************************************************************************/
    
    public static Boolean processResponse(GlUt_TransferXMLResponseContainer herokuResponse, SObject currentObj) {
        Boolean processed = false ;
        try {
            list<SObject> listSObject = new list<SObject>() ;
            if(herokuResponse != null) {
                if(herokuResponse.StatementPdf == 'T') {
                    InformationStatement__c infoStmtObj = (InformationStatement__c) currentObj ;
                    infoStmtObj.DataXml__c = herokuResponse.dataXml == 'T' ? true : false ;
                    infoStmtObj.PrintXml__c = herokuResponse.printXml  == 'T' ? true : false ;
                    infoStmtObj.StatementPdf__c = herokuResponse.statementPdf  == 'T' ? true : false;
                    infoStmtObj.IssueDate__c = System.today() ; //Sudhir : 28/112018
                    listSObject.add(infoStmtObj) ;
                } 
                
                else if(herokuResponse.billPdf == 'T') {
                    /* -> since Heroku is taking care for this Bill object update
                    Bill__c billObj = (Bill__c) currentObj ;
                    billObj.DataXml__c = herokuResponse.DataXml ;
                    billObj.PrintXml__c = herokuResponse.PrintXml ;
                    billObj.BillPdf__c = herokuResponse.BillPdf ;
                    listSObject.add(billObj) ;
                    */
                    processed = true ;
                }
            }	
            system.debug('Generate Pdf-listSObject = ' + listSObject);
            if(listSObject != null && !listSObject.isEmpty()) {
                Database.SaveResult[] saveResult = Database.update(listSObject) ;
                if(saveResult!= null && !saveResult.isEmpty() && saveResult[0].isSuccess()) {
                    processed = true ;
                }
            }
        } catch(Exception ex) {
            system.debug('ex = ' + ex);
            processed = false ;
            GlUt_Logger.logException(ex) ;
            throw new AuraHandledException('ERROR: ' + ex.getMessage()) ;
        }
        return processed ;
    }
}