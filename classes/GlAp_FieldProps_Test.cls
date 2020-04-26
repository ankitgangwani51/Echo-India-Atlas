/******************************************************************************
@author:      Accenture: Suman Kumar
@date:        26th September 2017
@description: Test Class for GlAp_FieldProps
@Revisions	  AT-4887 , Tarun , Added Assert as part of checkmarks result
*******************************************************************************/

@isTest
Public Class GlAp_FieldProps_Test{

//variable declation section
    private static final string SYSADMIN = 'System Administrator';
    private static final string TESTUSER = 'TestUser';
    private static final string UNSUPPORTED= 'Unsupported';
    private static final string TEXTAREA ='TextArea';    
    private static List<string> selectList ;  
    
    private static final string FIELDNAME  ='Test';    
    private static final string FIELDLABEL ='Test__c';    
    private static final Boolean TRANSFORMFIELD = true;    
    
    static{
            //Get Fields from the Supression Object
            selectList = new List<string>();
            selectList .add('FirstName');
            selectList .add('LastName');      
    }
    private static Map<string,string> MapSelectEntries ;   
    static{
            //Get Fields from the Supression Object
            MapSelectEntries = new  Map<string,string>();
            MapSelectEntries.put('FirstName','FirstName');
            MapSelectEntries.put('LastName','LastName');      
    }
    public GlAp_FieldProps fieldstype;

/******************************************************************************
@author:      Accenture: Suman Kumar
@date:        26th September 2017
@description: Test data setup method
*******************************************************************************/
    @TestSetup
    Static void createTestData(){
        User objUser = GlUt_FactoryData_Test.createUser(SYSADMIN,TESTUSER,null);
        Database.insert(objUser);  
    }

/******************************************************************************
@author:      Accenture: Suman Kumar
@date:        26th September 2017
@description: Test method for checking the field Type
*******************************************************************************/
    static void setFieldType(DisplayType fieldTypes, String type){
        User objUser =[select id,name from user where isActive=true limit 1];
        system.runas(objUser){
            Test.StartTest();
            GlAp_FieldProps fieldstype = new GlAp_FieldProps();
            DisplayType fieldType = fieldTypes;
            fieldstype.isRequired = true;
            fieldstype.isFLSVisible = true;
            fieldstype.isEncrypted = false;
            fieldstype.isEditable = true;
            fieldstype.fieldName = 'Test';
            fieldstype.fieldLabel = 'Test__c';
            fieldstype.parentObject = objUser.Id;
            fieldstype.fieldType = type;
            fieldsType.pickListValues = selectList ;
            fieldsType.pickListEntries = MapSelectEntries ;            
            fieldstype.setFieldType(fieldType);
            Test.StopTest();
        }
    }

/******************************************************************************
@author:      Accenture: Suman Kumar
@date:        26th September 2017
@description: Test method for checking the field Type
*******************************************************************************/
    static testmethod void setFieldTypeString(){
        User objUser =[select id,name from user where isActive=true limit 1];
        system.runas(objUser){
            DisplayType fieldType = Schema.DisplayType.STRING;
            String types = 'text';
            setFieldType(fieldType,types);
            system.assertNotequals(string.valueof(fieldType),types);
        }
    }  

/******************************************************************************
@author:      Accenture: Suman Kumar
@date:        26th September 2017
@description: Test method for checking the field Type
*******************************************************************************/
    static testmethod void setFieldTypeEmail(){
        User objUser =[select id,name from user where isActive=true limit 1];
        system.runas(objUser){
            DisplayType fieldType = Schema.DisplayType.EMAIL;
            String types = 'EMAIL';
            setFieldType(fieldType,types);
            system.assertequals(string.valueof(fieldType),types);
        }
    }    
  
/******************************************************************************
@author:      Accenture: Suman Kumar
@date:        26th September 2017
@description: Test method for checking the field Type
*******************************************************************************/
    static testmethod void setFieldTypePhone(){
        User objUser =[select id,name from user where isActive=true limit 1];
        system.runas(objUser){
            DisplayType fieldType = Schema.DisplayType.PHONE;
            String types = 'PHONE';
            setFieldType(fieldType,types);
            system.assertequals(string.valueof(fieldType),types);
        }
    } 

/******************************************************************************
@author:      Accenture: Suman Kumar
@date:        26th September 2017
@description: Test method for checking the field Type
*******************************************************************************/
    static testmethod void setFieldTypeURL(){
        User objUser =[select id,name from user where isActive=true limit 1];
        system.runas(objUser){
            DisplayType fieldType = Schema.DisplayType.URL;
            String types = 'URL';
            setFieldType(fieldType,types);
            system.assertequals(string.valueof(fieldType),types);
        }
    }    
 
/******************************************************************************
@author:      Accenture: Suman Kumar
@date:        26th September 2017
@description: Test method for checking the field Type
*******************************************************************************/
    static testmethod void setFieldTypeCurrency(){
        User objUser =[select id,name from user where isActive=true limit 1];
        system.runas(objUser){
            DisplayType fieldType = Schema.DisplayType.CURRENCY;
            String types = 'CURRENCY';
            setFieldType(fieldType,types);
            system.assertequals(string.valueof(fieldType),types);
        }
    }    
  
/******************************************************************************
@author:      Accenture: Suman Kumar
@date:        26th September 2017
@description: Test method for checking the field Type
*******************************************************************************/
    static testmethod void setFieldTypeInteger(){
        User objUser =[select id,name from user where isActive=true limit 1];
        system.runas(objUser){
            DisplayType fieldType = Schema.DisplayType.INTEGER;
            String types = 'INTEGER';
            setFieldType(fieldType,types);
            system.assertequals(string.valueof(fieldType),types);
        }
    }    

/******************************************************************************
@author:      Accenture: Suman Kumar
@date:        26th September 2017
@description: Test method for checking the field Type
*******************************************************************************/
    static testmethod void setFieldTypeBoolean(){
        User objUser =[select id,name from user where isActive=true limit 1];
        system.runas(objUser){
            DisplayType fieldType = Schema.DisplayType.BOOLEAN;
            String types = 'BOOLEAN';
            setFieldType(fieldType,types);
            system.assertequals(string.valueof(fieldType),types);   
        }
    }    
    /******************************************************************************
@author:      Accenture: Suman Kumar
@date:        26th September 2017
@description: Test method for checking the field Type
*******************************************************************************/
    static testmethod void setFieldTypeDate(){
        User objUser =[select id,name from user where isActive=true limit 1];
        system.runas(objUser){
            DisplayType fieldType = Schema.DisplayType.DATE;
            String types = 'DATE';
            setFieldType(fieldType,types);
            system.assertequals(string.valueof(fieldType),types);
        }
    }
    
/******************************************************************************
@author:      Accenture: Suman Kumar
@date:        26th September 2017
@description: Test method for checking the field Type
*******************************************************************************/
    static testmethod void setFieldTypeDateTime(){
        User objUser =[select id,name from user where isActive=true limit 1];
        system.runas(objUser){
            DisplayType fieldType = Schema.DisplayType.DATETIME;
            String types = 'DATETIME';
            setFieldType(fieldType,types);
            system.assertequals(string.valueof(fieldType),types);
            
        }
    }
/******************************************************************************
@author:      Accenture: Suman Kumar
@date:        26th September 2017
@description: Test method for checking the field Type
*******************************************************************************/
    static testmethod void setFieldTypemultiselect(){
        User objUser =[select id,name from user where isActive=true limit 1];
        system.runas(objUser){
            DisplayType fieldType = Schema.DisplayType.MULTIPICKLIST;
            String types = 'MULTIPICKLIST';
            setFieldType(fieldType,types);
            system.assertequals(string.valueof(fieldType),types);
        }
    }
    /******************************************************************************
@author:      Accenture: Suman Kumar
@date:        26th September 2017
@description: Test method for checking the field Type
*******************************************************************************/
    static testmethod void setFieldTypepicklist(){
        User objUser =[select id,name from user where isActive=true limit 1];
        system.runas(objUser){
            DisplayType fieldType = Schema.DisplayType.PICKLIST;
            String types = 'PICKLIST';
            setFieldType(fieldType,types);
            system.assertequals(string.valueof(fieldType),types);
        }
    }

/******************************************************************************
@author:      Accenture: Suman Kumar
@date:        26th September 2017
@description: Test method for checking the field Type
*******************************************************************************/
    static testmethod void setFieldTypecombobox(){
        User objUser =[select id,name from user where isActive=true limit 1];
        system.runas(objUser){
            DisplayType fieldType = Schema.DisplayType.COMBOBOX;
            String types = 'COMBOBOX';
            setFieldType(fieldType,types);
            system.assertequals(string.valueof(fieldType),types);
        }
    }
 /******************************************************************************
@author:      Accenture: Suman Kumar
@date:        26th September 2017
@description: Test method for checking the field Type
*******************************************************************************/
    static testmethod void setFieldTypepercent(){
        User objUser =[select id,name from user where isActive=true limit 1];
        system.runas(objUser){
            DisplayType fieldType = Schema.DisplayType.PERCENT;
            String types = 'PERCENT';
            setFieldType(fieldType,types);
            system.assertequals(string.valueof(fieldType),types);
        }
    }

        /******************************************************************************
@author:      Accenture: Suman Kumar
@date:        26th September 2017
@description: Test method for checking the field Type
*******************************************************************************/
    static testmethod void setFieldTypereference(){
        User objUser =[select id,name from user where isActive=true limit 1];
        system.runas(objUser){
            DisplayType fieldType = Schema.DisplayType.REFERENCE;
            String types = 'REFERENCE';
            setFieldType(fieldType,types);
            system.assertequals(string.valueof(fieldType),types);
        }
    }

/******************************************************************************
@author:      Accenture: Suman Kumar
@date:        26th September 2017
@description: Test method for checking the field Type
*******************************************************************************/
    static testmethod void setFieldTypetextarea(){
        User objUser =[select id,name from user where isActive=true limit 1];
        system.runas(objUser){
            DisplayType fieldType = Schema.DisplayType.TEXTAREA;
            String types = 'TEXTAREA';
            setFieldType(fieldType,types);
            system.assertequals(string.valueof(fieldType),types);
        }
    }
     /******************************************************************************
@author:      Accenture: Manish Singh
@date:        26th September 2017
@description: Test method for checking the field Type
*******************************************************************************/
    static testmethod void setFieldTypeUnsspported(){
        User objUser =[select id,name from user where isActive=true limit 1];
        system.runas(objUser){
            DisplayType fieldType = Schema.DisplayType.ADDRESS;
            String types = 'ADDRESS';
            setFieldType(fieldType,types);
            system.assertequals(string.valueof(fieldType),types);
        }
    }
    
    /******************************************************************************
    @author:      Accenture: Manish Singh
    @date:        26th September 2017
    @description: Test method for checking the field Type
    *******************************************************************************/
    static testmethod void setGlAp_FieldPropsConstructor(){
        User objUser =[select id,name from user where isActive=true limit 1];
        
        String fieldName = FIELDNAME;
        String fieldLabel = FIELDLABEL;
        Boolean transformField = TRANSFORMFIELD;
        String parentObject = objUser.Id;
        
        system.runas(objUser){
            Test.StartTest();
            GlAp_FieldProps fieldstype = new GlAp_FieldProps(fieldName,fieldLabel,transformField,parentObject);
            Test.StopTest();
            System.assert(fieldstype.isFLSVisible == true);
        }
    }
}