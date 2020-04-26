/******************************************************************************
@author         Echo: Ankit Gangwani
@date           28 August 2018
@description    
*******************************************************************************/
public class GlAp_HerokuBatchParameters {
    public Integer id;
    public String JobCron;  
    public String JobType;    
    public String SubmittedBy; 
    public Date EndDate;
    
    
    /**********************************************************************************************
    @author      : Echo: Ankit Gangwani
    @date        : 28 August 2018
    @params      : String json
    @return      : GlAp_HerokuBatchParameters
    @description : This method is used to Deserialize the parse JSON string.
    **********************************************************************************************/
    public static GlAp_HerokuBatchParameters parse(String json) {        
        return (GlAp_HerokuBatchParameters) System.JSON.deserialize(json, GlAp_HerokuBatchParameters.class);
    }
}