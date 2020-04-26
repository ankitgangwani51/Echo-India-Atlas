/**********************************************************************************************
@author         Accenture : Manish Singh
@date           18-Aug-2017
@description:   This TriggerHandlerBase Class needs to be implemented by handler class
                Reference : Development Standards document section Atlas Section: 10.3 Trigger Framework 
@revisions:     Luke Emberton 24/08/2017
                    - Updated to take an object as a paramter as opposed to separate objects
**********************************************************************************************/
public virtual class GlUt_TriggerHandlerBase{
    
    public class NotImplementedException extends Exception{}
    
    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           18-Aug-2017
    @param          GlUt_TriggerHandlerObj inputParam
    @return         void
    @description        This method is the code that fires initially for a trigger
    **********************************************************************************************/

    public virtual void MainEntry(GlUt_TriggerHandlerObj inputParam){        
        throw new NotImplementedException('Error Not Implemented');
    }
            
    /**********************************************************************************************
    @author         Accenture: Luke Emberton
    @date           18-Aug-2017
    @param          GlUt_TriggerHandlerObj inputParam
    @return         void
    @description        This method will fire if a trigger is already running. It has a default
                    implementation that will just run the handler of the respective object
                    if it is not overwitten
    **********************************************************************************************/
    public virtual void InProgressEntry(GlUt_TriggerHandlerObj inputParam){
            
        //By default just call the main entry of the invoking classes controller object 
        String TypeName = GlUt_Constants.PREFIX + inputParam.TriggerObject + GlUt_Constants.HANDLERSUFFIX;
        Type t = Type.forName(GlUt_NamespacePrefix.getNamespacePrefix().replace('__',''),TypeName);
        
        GlUt_TriggerHandlerBase activeFunction = (GlUt_TriggerHandlerBase)t.newInstance();            
        
        //Update the dispatcher active function so that it references the new object
        GlUt_CentralDispatcher.activeFunction = activeFunction;
    
        activeFunction.MainEntry(inputParam);
            
        //Reset the active function so that it points to the current class
        GlUt_CentralDispatcher.activeFunction = this;
    }
}