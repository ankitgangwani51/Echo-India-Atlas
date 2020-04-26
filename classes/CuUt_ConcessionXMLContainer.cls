/**********************************************************************************************
@author         Echo: Dependra Singh
@date           31 December 2018
@description    A data transfer object (DTO) class used to create an instance 
                of the data extracted from Salesforce records to format the 
                XML message for Concession
***********************************************************************************************/
public class CuUt_ConcessionXMLContainer {
    private static final String CLASS_NAME = 'CuUt_ConcessionXMLContainer';
    private static final String DEBUG = '[' + CLASS_NAME + '] ';
    // utility methods used to format date and datetime fields for json as yyyy-MM-dd HH:mm:ss
    private static String dateToString(Date d) {return d != null ? String.valueOf(d) + ' 00:00:00' : null;}        
    public BatchRequest004 data {get; private set;}  // structured wrapper data
    public String XML {get;  private set;} // XML of structured data
    CentrelinkUserCredential__mdt custMetaCentrelinkUserCredential ;
    
    
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           31 December 2018
    @description    
    *******************************************************************************/ 
    public CuUt_ConcessionXMLContainer(List<Concession__c> concessionRecords){
        //custMetaCentrelinkUserCredential =[select Id,UserID__c,Username__c from CentrelinkUserCredential__mdt LIMIT 1];
        custMetaCentrelinkUserCredential = CuUt_ConcessionUtility.getCentrelinkUserCredential();
        if(concessionRecords != null && !concessionRecords.isEmpty()){
            data = new BatchRequest004(this, concessionRecords, custMetaCentrelinkUserCredential);
        }
        XML = GlUt_XMLSerialiser.serialize((Object) data);
        if(XML != null){
            if(XML.contains('system_X')){
                XML = XML.replace('system_X', 'system');
            }
        }
    }

  /******************************************************************************
    @author         Echo: Dependra Singh
    @date           31 December 2018
    @description    
    *******************************************************************************/
    private class BatchRequest004 {
        private headerObj header;
        private List<statusRqstObject> statusRqst;
        public override String toString() {
            return 'BatchRequest004';
        }
        private BatchRequest004(CuUt_ConcessionXMLContainer container, List<Concession__c> concessionRecords, CentrelinkUserCredential__mdt custMetaCentrelinkUserCredential) {
            // build the Concession DTO
            header = new  headerObj(container,custMetaCentrelinkUserCredential);
            statusRqst = new List<statusRqstObject>();
            integer counter = 1;
            for (Concession__c objConcession : concessionRecords) {
                statusRqst.add(new statusRqstObject(container, objConcession, counter));        // To check- method does not exist error
            }
        }
    }
	/******************************************************************************
    @author         Echo: Dependra Singh
    @date           31 December 2018
    @description    
    *******************************************************************************/
    private class headerObj {
        private String system_X ;
        private String timestamp;
        private String userId;
        private String senderOrgCrn;
        private String recverOrgCrn;
        private String senderAbn;
        private String recverAbn;
        private String batchInfo;
        private headerObj(CuUt_ConcessionXMLContainer container, CentrelinkUserCredential__mdt custMetaCentrelinkUserCredential) {
            system_X = GlUt_Constants.CONCESSIONSYSTEM;
            timestamp = CuUt_ConcessionUtility.generateTimestampFormatCCYYMMDDHHMMSS();
            userId = custMetaCentrelinkUserCredential.UserID__c != null ? custMetaCentrelinkUserCredential.UserID__c : '';
            senderOrgCrn ='';
            recverOrgCrn= '';
            senderAbn='';
            recverAbn='';
            batchInfo='';
        }
    }
    /******************************************************************************
    @author         Echo: Dependra Singh
    @date           31 December 2018
    @description    
    *******************************************************************************/
    private class statusRqstObject {
        private String crn ;
        private String cnfrmDate;
        private String pcode;
        private String scndryCrn;
        private String attr_id ;
        private statusRqstObject(CuUt_ConcessionXMLContainer container, Concession__c objConcession , integer counter) {
            // build the Concession DTO
            crn = objConcession.CRN__c;
            cnfrmDate = dateToString(objConcession.ConfirmDate__c);
            pcode = objConcession.PostCode__c;// Need to change in future. As of now it is for testing purpose
            scndryCrn = objConcession.CRN__c;
            attr_id = string.valueOf(counter);
        }
    }    
}