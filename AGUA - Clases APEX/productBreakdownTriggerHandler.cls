public without sharing class productBreakdownTriggerHandler{
    public static void beforeInsert(List<Oportunidad_Producto__c> prodOppList) {
        productBreakdownTriggerHelper pb = new productBreakdownTriggerHelper();
        pb.pBreakdownCreateWorkFlowRules(prodOppList);
    }
	public static void afterInsert(List<Oportunidad_Producto__c> prodOppList) {
        productBreakdownTriggerHelper pb = new productBreakdownTriggerHelper();
        //pb.opportunityCheckProductLeader(prodOppList);
    }
	public static void beforeUpdate(List<Oportunidad_Producto__c> neProdOppMap, List<Oportunidad_Producto__c> oldProdOppMap) {
        productBreakdownTriggerHelper pb = new productBreakdownTriggerHelper();
        //pb.opportunityCheckProductLeader(prodOppList);
        
    }
	public static void afterUpdate(Map<Id, Oportunidad_Producto__c> neProdOppMap, Map<Id, Oportunidad_Producto__c> oldProdOppMap) {
        
    }
    
    public static void afterDelete(List<Oportunidad_Producto__c> prodOppList) {
        productBreakdownTriggerHelper pb = new productBreakdownTriggerHelper();
        pb.prodbCheckProductLeaderAfterDelete(prodOppList);
    }
}