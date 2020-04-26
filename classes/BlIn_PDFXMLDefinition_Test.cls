/******************************************************************************
@author:      Accenture: Sucharu Gupta
@date:        29 September 2017
@description: Test Class for    BlIn_PDFXMLDefinition 
*******************************************************************************/

@isTest
//test data creation for    BlIn_PDFXMLDefinition class
public Class BlIn_PDFXMLDefinition_Test{
    
    private static final String USER_PROFILE ='System Administrator';
    private static final String USER_NAME ='TestUser'; 
    private static final String USERNAMECOMPLETE  = USER_NAME+ '@unitest.com';  
    private static final String  XMLFIELD  = 'XMLFields';
    private static final Integer countXMLObject = 0;
    /*******************************************************************
Purpose: method to create test data used by all test methods
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    @TestSetup
    Static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(USER_PROFILE,USER_NAME,null);
        Database.insert(objUser); 
    }
    
    /*******************************************************************
Purpose: Method to test  XML data records {Positive scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void BlIn_PDFXMLDefinition_Positive(){
        User objUser =[select id,name from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1];
        List<BlIn_PDFBillData.XMLObject> XMLObjects = new List<BlIn_PDFBillData.XMLObject>();
        System.runAs(objUser){
            Test.startTest();
            BlIn_PDFXMLDefinition objBlIn_PDFXMLDefinition = new BlIn_PDFXMLDefinition(); 
            XMLObjects = objBlIn_PDFXMLDefinition.XMLObjects;
            String jsonStr = JSON.serialize(XMLObjects);
            JSONParser parser = JSON.createParser(jsonStr);
            Integer countXMLFields=0;
            while (parser.nextToken() != null)
            {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) 
                {
                    if(parser.getText() == XMLFIELD){
                        countXMLFields = countXMLFields + 1;
                    }
                }
            }
            Test.stopTest();
            System.assert(XMLObjects!=null);
            System.assertEquals(XMLObjects.size(),countXMLFields);
        }
    }
    
    /*******************************************************************
Purpose: Method to test  XML data records {Negative scenario}
Parameters: N/A 
Returns: void
Throws [Exceptions]: N/A
********************************************************************/
    static testmethod void BlIn_PDFXMLDefinition_Negative(){
        User objUser =[select id,name from user where isActive=true AND USERNAME =: USERNAMECOMPLETE limit 1];
        List<BlIn_PDFBillData.XMLObject> XMLObjects = new List<BlIn_PDFBillData.XMLObject>();
        System.runAs(objUser){
            Test.startTest();
            BlIn_PDFXMLDefinition objBlIn_PDFXMLDefinition = new BlIn_PDFXMLDefinition(); 
            XMLObjects = objBlIn_PDFXMLDefinition.XMLObjects;
            Test.stopTest();
            System.assert(XMLObjects!=null);
            System.assertNotEquals(XMLObjects.size(),countXMLObject);
        }
    }
}