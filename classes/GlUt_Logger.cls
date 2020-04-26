/******************************************************************************
@author:      Accenture: KC Thiruchelvam
@date:        04 April 2018
@description: Logger class for logging Custom Log records
*******************************************************************************/
public with sharing class GlUt_Logger {
    
    public class CustomException extends Exception{}
    
    private static final string DEBUGTYPE = 'Debug';
    private static final string EXCEPTIONTYPE = 'Exception';
    
    // Static Logs list populated during an execution,
    // then inserted at end of execution.
    private static List<Log__c> logs = new List<Log__c>();
    // Custom Setting that contains:
    // - whether Logging is enabled for current profile
    // - the Crypto Key used for encrypting Messages and Stacktrace
    private static LogManagement__c logManage = LogManagement__c.getInstance(UserInfo.getProfileId());
    
    private static integer sequence = 0;
    private static boolean loggingEnabled = isLoggingEnabled();
    private static string executionId;
    
    /******************************************************************************
    @author    		Accenture: KC Thiruchelvam
    @date      		04 April 2018
    @param			String - a debug log message
    @return			null
    @description 	Saves a given message as a Debug Log record if Logging
    is enabled.
    *******************************************************************************/
    public static void logDebug(String message) {
        system.debug('message0=> '+ message);
        createLog(DEBUGTYPE, message, '', '', null);
    }
    
    /******************************************************************************
    @author    		Accenture: KC Thiruchelvam
    @date      		04 April 2018
    @param			Exception - an Exception object
    @return			null
    @description 	Converts the given Exception into an Exception Log record if
    Logging is enabled.
    *******************************************************************************/
    public static void logException(Exception ex){
        
        createLog(EXCEPTIONTYPE, ex.getMessage(), ex.getTypeName(), String.valueOf(ex.getLineNumber()),ex);
    }
    
    /******************************************************************************
    @author    		Accenture: KC Thiruchelvam
    @date      		04 April 2018
    @param			String - an error log message
    @return			null
    @description 	Saves a given message as an Error Log record if
    Logging is enabled.
    *******************************************************************************/
    public static void logException(String exceptionMessage){
        
        CustomException ex = new CustomException(exceptionMessage);
        logException(ex);
    }
    
    /******************************************************************************
    @author    		Accenture: KC Thiruchelvam
    @date      		04 April 2018
    @param			List<Log__c> - a list of Log records
    @return			null
    @description 	Writes all the given Log records to the database if
    Logging is enabled.
    *******************************************************************************/
    public static void writeLogsToDatabase(List<Log__c> logs){
        
        //if debug custom setting is on
        system.debug('logs 2 => ' + logs);
        if(loggingEnabled  && !logs.isEmpty()){	
            logs = (List<Log__c>) GlUt_FieldSecurity.cleanseFields(logs, false);
            insert  logs;
        }
    }
    /******************************************************************************
    @author    		Dependra
    @date      		
    @param			List<Log__c> - a list of Log records
    @return			null
    @description 	Writes all the given Log records to the database if
    Logging is enabled.
    *******************************************************************************/
    public static void writeLogsToDatabase(){
        if(!logs.isEmpty())
        writeLogsToDatabase(logs);
        logs.clear();
    } 
    
    /******************************************************************************
    @author    		Accenture: KC Thiruchelvam
    @date      		
    @param			String logType, String message,String exceptionType, String exceptionLine , Exception ex
    @return			String
    @description 	Writes all the given Log records to the database if
    Logging is enabled.
    *******************************************************************************/
    private static void createLog(String logType, String message,String exceptionType, String exceptionLine , Exception ex) {
        if(!loggingEnabled){
           	return;	
        }
        system.debug('message2=> ' + message);
        string strSecureStackTrace =  '';
        if(ex != null){
            //strSecureStackTrace = secureMessage(getStackTrace(ex)); //Currently, we are not encrypting message.
             strSecureStackTrace = getStackTrace(ex);// Added this line and commented below, as per discussion with Sandeep.
        } 
        system.debug('message3=> ' + message);
        Log__c log = new Log__c(
            ExecutionId__c = getExecutionId(),
            StackTrace__c = strSecureStackTrace,
            Limits__c = getLimits(),
            Message__c = message,// Added this line and commented below, as per discussion with Sandeep.
            //Message__c = secureMessage(message),// Currently, we are not encrypting message.
            LogType__c = logType,
            User__c = Userinfo.getUserId(),
            ExceptionType__c = exceptionType,
            Sequence__c = sequence + '_' + executionId
        );
        if(ex != null){
           logs.add(log); 
        }
        system.debug('log=> ' + log);
        //logs.add(log);// In case of we are entering in methods we are not capturing logs. // Sudhir: SOQL query optimization Test
        sequence++;
    }
    /******************************************************************************
    @author    		Accenture: KC Thiruchelvam
    @date      		
    @param			
    @return			String
    @description 	Method is used to get the execution Id as string 
    *******************************************************************************/
    private static String getExecutionId(){
        if(executionId != null && executionId != ''){
            return executionId;
        }
        else {
            executionId = 'ExId_' + String.ValueOf(System.currentTimeMillis());
            return executionId;
        }
    }
    /******************************************************************************
    @author    		Accenture: KC Thiruchelvam
    @date      		
    @param			String message
    @return			Boolean
    @description 	Method is used to encrypt the string(debug or error)
    *******************************************************************************/
    private static String secureMessage(String message){
    	
    	// 14 Jun 2018, P Dixon - TEMP NO ENCRYPTION for dev org testing
    	return message;
        
        // Get AES Key
        Blob cryptoKey;
        if (logManage != null) {
            cryptoKey =  Blob.valueOf(logManage.CryptoKey__c);
        }
        else {
            throw new CustomException('No Log Management Custom Setting found');
        }
        // Generate the data to be encrypted.
        Blob data = Blob.valueOf(message);
        // Encrypt the data and have Salesforce.com generate the initialization vector
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, data);
        // Return encrypted data as String
        return EncodingUtil.base64Encode(encryptedData);
    }
    /******************************************************************************
    @author    		Accenture: KC Thiruchelvam
    @date      		
    @param			
    @return			Boolean
    @description 	Method is used to get the status of logging from custom setting.
    *******************************************************************************/
    // Assume Logging is false by default
    private static Boolean isLoggingEnabled() {
        system.debug('logManage=> ' + logManage);
        system.debug('EnableLogging=> ' + logManage.EnableLogging__c);
        if (logManage != null) {
            return logManage.EnableLogging__c;
        }
        else {
            throw new CustomException('No Log Management Custom Setting found');
        }
    }
    /******************************************************************************
    @author    		Dependra
    @date      		
    @param			Exception ex
    @return			null
    @description 	Method id used to get stack trace string.
    *******************************************************************************/
    private static String getStackTrace(Exception ex ) {
        String stackTrace = ex.getStackTraceString();
        //Commented by Dependra
        /*
        List<String> stackLines = stackTrace.split('\n');
        stacklines.remove(0);
        stacklines.remove(stackLines.size()-1);
        stackTrace  = string.join(stackLines ,' -> ');
        system.debug(stackTrace);
        */
        
        return stackTrace;
    }
    /******************************************************************************
    @author    		Accenture: KC Thiruchelvam
    @date      		
    @param			
    @return			String
    @description 	Method is used toget the limit of apex in one instance.
    *******************************************************************************/
    private static string getLimits(){
        // ToDo: calculate ratios
        string limitstring = '';
        limitstring += 'Query Limits: '+ Limits.getQueries() + '/' + Limits.getLimitQueries() +'\n';
        limitstring += 'DML Rows Limits: '+Limits.getDMLRows()+'/' + Limits.getLimitDMLRows()+'\n';
        limitstring += 'Heap Size Limits: '+Limits.getHeapSize()+'/' +Limits.getLimitHeapSize()+'\n';
        limitstring += 'Query Return Limits: '+Limits.getQueryRows()+'/' + Limits.getLimitQueryRows()+'\n';
        limitstring += 'Aggregate Queries: '+Limits.getAggregateQueries()+'/' + Limits.getLimitAggregateQueries()+ '\n';
        limitstring += 'Callouts: '+Limits.getCallouts()+'/' +Limits.getLimitCallouts()+ '\n';
        limitstring += 'CPU Time: '+Limits.getCpuTime()+'/' +Limits.getLimitCpuTime()+ '\n';
        limitstring += 'DML Statements: '+Limits.getDMLStatements()+'/' +Limits.getLimitDMLStatements()+ '\n';
        limitstring += 'Email Invocations: '+Limits.getEmailInvocations()+'/' +Limits.getLimitEmailInvocations()+ '\n';
        limitstring += 'Future Calls: '+Limits.getFutureCalls()+'/' +Limits.getLimitFutureCalls()+ '\n';
        limitstring += 'Query Locator Rows: '+Limits.getQueryLocatorRows() +'/'+Limits.getLimitQueryLocatorRows()+ '\n';
        
        return limitstring;
        
    }
     /******************************************************************************
    @author    		Accenture: KC Thiruchelvam
    @date      		
    @param			
    @return			String
    @description 	Method is used to get the limit of apex in one instance.
    *******************************************************************************/
    public static string getActualErrorMessage(string strErrorMessage){
        //Added check for FIELD_CUSTOM_VALIDATION_EXCEPTION to return user friendly error.//
        String errorMsg = strErrorMessage;
        if(errorMsg.contains(GlUt_Constants.FIELDCUSTOMVALIDATIONEXCEPTION)){
            errorMsg = errorMsg.substringBetween(GlUt_Constants.FIELDCUSTOMVALIDATIONEXCEPTION + ', ', ': ');
        }
        else if(errorMsg.contains(GlUt_Constants.REQUIREDFIELDMISSING)){
            errorMsg = errorMsg.substringBetween(GlUt_Constants.REQUIREDFIELDMISSING + ', ', ': ');
        } 
        return errorMsg;
    }
    /******************************************************************************
    @author    		Echo: Amit K.
    @date      		08-Oct-2018
    @param			string strErrorMessage
    @return			void
    @description 	Method is used to show valid error message instead of Script throw exception.
    *******************************************************************************/ 
    public static void getAuraHandledException(string strErrorMessage){
        AuraHandledException e = new AuraHandledException(strErrorMessage);
        e.setMessage(strErrorMessage);
        throw e;
    }
}