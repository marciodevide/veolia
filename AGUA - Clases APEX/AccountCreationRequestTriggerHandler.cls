public class AccountCreationRequestTriggerHandler {
    public static void beforeInsert(List<AQUA_PeticionAltaCompania__c> newProdOppList) {
        AccountCreationRequestTriggerHelper acr = new AccountCreationRequestTriggerHelper();
        //acr.accountCreationRequestWorkFlowRules(newProdOppList);
        
    }
	public static void afterInsert(List<AQUA_PeticionAltaCompania__c> newProdOppList) {
        AccountCreationRequestTriggerHelper acr = new AccountCreationRequestTriggerHelper();
    }
	public static void beforeUpdate(List<AQUA_PeticionAltaCompania__c> newProdOppList, List<AQUA_PeticionAltaCompania__c> oldProdOppMap) {
        AccountCreationRequestTriggerHelper acr = new AccountCreationRequestTriggerHelper();
        acr.accountCreationRequestWorkFlowRules(newProdOppList,oldProdOppMap);
       
    }
	public static void afterUpdate(List<AQUA_PeticionAltaCompania__c> newProdOppList,List<AQUA_PeticionAltaCompania__c> oldProdOppMap) {
        AccountCreationRequestTriggerHelper acr = new AccountCreationRequestTriggerHelper();
    }
}