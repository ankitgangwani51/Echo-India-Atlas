/******************************************************************************
@author         Echo: Tarun Gupta
@date           11 Feb 2019
@description    AT-5235 , recieve a file of rejected direct debit payments
*******************************************************************************/
global class PyUt_AUSplitCombinedBankAccountNumber {
    
    /******************************************************************************
    @author         Echo: Tarun Gupta
    @date           11 Feb 2019
    @description    Recieve a list of Direct Debit Return records and populate Account and sort code
	@Params 		List<DirectDebitReturn__c>
	@Return			Void
    *******************************************************************************/
    
    @InvocableMethod(label='Get Direct Debit Return Records' description='populate BankAccountNumber__c and BankAccountSortCode__c from BankAccountNumberCombined__c')
    global static void populateAccountAndSortCodes(List<DirectDebitReturn__c> listDDRToProcess) {
        List<DirectDebitReturn__c> listDDRToUpdate = new List<DirectDebitReturn__c>();
        Set<Id> setIds = new Set<Id>();
        //Created Set as it was giving "order of execution" error while processing the same input list
        for (DirectDebitReturn__c objDDR : listDDRToProcess) {
            setIds.add(objDDR.Id);
        }
        for(DirectDebitReturn__c objDDR : [SELECT Id,BankAccountSortCode__c,BankAccountNumber__c,BankAccountNumberCombined__c FROM DirectDebitReturn__c WHERE ID IN: setIds]){
            
            if(objDDR.BankAccountNumberCombined__c != null){
                String decryptedString = decryptBankAccNumberCombined(Blob.valueOf(objDDR.BankAccountNumberCombined__c));
                if(decryptedString.length() == 16){
                    objDDR.BankAccountSortCode__c = decryptedString.substring(0,7);
                    objDDR.BankAccountNumber__c = decryptedString.substring(7,16).trim();
                    listDDRToUpdate.add(objDDR);
                }
            }
        }
        // update the DirectDebitReturn__c records
        listDDRToUpdate = (List<DirectDebitReturn__c>) GlUt_FieldSecurity.cleanseFields(listDDRToUpdate, false);
		if (!listDDRToUpdate.isEmpty()) update listDDRToUpdate;
    }
    
    /******************************************************************************
    @author    		Echo: Tarun Gupta
    @date      		11 Feb 2019
    @description 	Method to Decrypt BankAccountNumberCombined__c
	*******************************************************************************/
    public static String decryptBankAccNumberCombined(Blob bankAccNumberCombined){
        Blob key = Crypto.generateAesKey(128);
        Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, bankAccNumberCombined);
        Blob decrypted = Crypto.decryptWithManagedIV('AES128', key, encrypted);
        String decryptedString = decrypted.toString();
        return decryptedString;
    }
}