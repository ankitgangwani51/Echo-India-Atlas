/************************************************************************************************************
@author         Echo : Mohit Tayal
@date           07-Mar-2018
@description:   This is the class used to give the package namespace prefix
**************************************************************************************************************/
public class GlUt_NamespacePrefix {
	
    /************************************************************************************************************
    @author         Echo : Mohit Tayal
    @date           07-Mar-2018
	@return			String - namespace prefix
    @description:   This method is used to give the package namespace prefix
    **************************************************************************************************************/
    public static String getNamespacePrefix(){
        
        return System.Label.GlUt_NSPrefix == 'BLANK' ? '' : System.Label.GlUt_NSPrefix;
    }
}