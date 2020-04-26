public   with sharing class DataTableWithPagenation {

   @AuraEnabled
    public static AccountPagerWrapper fetchAccount(Decimal pageNumber ,Integer recordToDisply) {
        Integer pageSize = recordToDisply;
        Integer offset = ((Integer)pageNumber - 1) * pageSize;
        
        // create a instance of wrapper class.
        AccountPagerWrapper obj =  new AccountPagerWrapper();
        // set the pageSize,Page(Number), total records and accounts List(using OFFSET)   
        obj.pageSize = pageSize;
        obj.page = (Integer) pageNumber;
        obj.total = [SELECT count() FROM account];
        obj.accounts = [SELECT Id, Name,Phone FROM Account ORDER BY Name LIMIT :recordToDisply OFFSET :offset];
        // return the wrapper class instance .
        return obj;
    }
    
 // create a wrapper class with @AuraEnabled Properties    
    public class AccountPagerWrapper {
        @AuraEnabled public Integer pageSize {get;set;}
        @AuraEnabled public Integer page {get;set;}
        @AuraEnabled public Integer total {get;set;}
        @AuraEnabled public List<Account> accounts {get;set;}
    }
}