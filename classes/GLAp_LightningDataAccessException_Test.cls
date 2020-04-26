/******************************************************************************
@author:      Echo: Tarun Gupta
@date:        28 Dec 2017
@description: Test Class for GlAp_LightningDataAccessException
*******************************************************************************/
@isTest
public class GLAp_LightningDataAccessException_Test {
    
    /******************************************************************************
    @author:      Echo: Tarun Gupta
    @date:        28 Dec 2017
    @description: Test method for GlAp_LightningDataAccessException() class
    *******************************************************************************/
    static testMethod void exceptionClass(){
        
        try{
            throw new GlAp_LightningDataAccessException('Error'); 
        }
        catch(Exception e){ 
            System.assert(e.getmessage().contains('Error') ); 
        }        
    }
}