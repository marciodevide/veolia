public class OpportunityTriggerHandler implements Triggers.Handler{
	public void handle(){
        OpportunityTriggerHelper OPP = new OpportunityTriggerHelper();
        List<Opportunity> newListAcc = Trigger.New;
        List<Opportunity> oldListAcc = Trigger.Old;
        Map<Id, Opportunity> mapNewAccById = (Map<Id, Opportunity>)Trigger.newMap;
        Map<Id, Opportunity> mapOldAccById = (Map<Id, Opportunity>)Trigger.OldMap;
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                OPP.opportunityCreateWorkFlowRules(newListAcc);
                OPP.opportunityWorkFlowRules(oldListAcc,newListAcc);
            }
            else if(Trigger.isUpdate){
                OPP.opportunityWorkFlowRules(oldListAcc,newListAcc);
                OPP.actualizarDatosEmpresaAdjudicataria(oldListAcc,newListAcc);
            }
        }
        if(Trigger.isAfter){
            if(Trigger.isUpdate){
                
            }else if(Trigger.isInsert){
                
            }
        }
    }
}