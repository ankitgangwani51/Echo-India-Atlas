public class ApexControllerLazyComponent {
 
    @AuraEnabled
    public Static list<Opportunity> getOpportunity(Integer Limits){ 
        return [Select id,Name,AccountId,StageName,CloseDate,Account.Name From Opportunity LIMIT :Integer.valueof(Limits)]; 
    }
    
    @AuraEnabled
    public static Integer TotalOpportunity(){
        AggregateResult results = [SELECT Count(Id) TotalOpportunity From Opportunity];
        Integer totalOpportunity = (Integer)results.get('TotalOpportunity'); 
        return totalOpportunity;
    } 
}