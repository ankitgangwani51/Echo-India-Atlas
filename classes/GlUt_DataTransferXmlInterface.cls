/**********************************************************************************************
@author         Echo : Sudhir Kumar
@date           01-Nov-2018
@description:   GlUt_DataTransferXmlInterface must be implemented by each of the XML container in the system in order for the generate XML & Query string to work within framework.     
				AU1: AT-4098
**********************************************************************************************/

public interface GlUt_DataTransferXmlInterface {
    
    /**********************************************************************************************
    @author         Echo : Sudhir Kumar
    @date           01-Nov-2018
    @param          List<SObject> sobjectList
    @return         String
    @description    The method must be defined in all XML container  classes that implement this interface. 
					It return the XML string
    **********************************************************************************************/    
    String getDataTransferXmlString(List<SObject> sobjectList) ;
    
    /**********************************************************************************************
    @author         Echo : Sudhir Kumar
    @date           01-Nov-2018
    @param          Id recordId, String filterCriteria
    @return         String
    @description    The method must be defined in all XML container  classes that implement this interface. 
					It return the Query string needed for the COntainer class
    **********************************************************************************************/    
    String getQueryString(Id recordId, String filterCriteria) ;
}