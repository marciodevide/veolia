public class OpportunityProductController {
    
    @AuraEnabled
    public static List<AggregateResult> getAnualProductPricesByOpportunity(Id opportunityId) {
        return new List<AggregateResult>([SELECT Year__c,SUM(Price__c) Price FROM AnualProductPrice__c WHERE Product__r.OP_MD_Oportunidad__c = :opportunityId GROUP BY Year__c ORDER BY Year__c ASC LIMIT 5000]);
    }
}