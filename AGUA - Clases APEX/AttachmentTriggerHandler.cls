public class AttachmentTriggerHandler implements Triggers.Handler{
	public void handle(){
        AttachmentTriggerHelper adjTriggerHelper = new AttachmentTriggerHelper();
        List<Adjuntos_Aprobacion__c> newListAdj = Trigger.New;
        List<Adjuntos_Aprobacion__c> oldListAdj = Trigger.Old;
        Map<Id, Adjuntos_Aprobacion__c> mapNewAdjById = (Map<Id, Adjuntos_Aprobacion__c>)Trigger.newMap;
        Map<Id, Adjuntos_Aprobacion__c> mapOldAdjById = (Map<Id, Adjuntos_Aprobacion__c>)Trigger.OldMap;
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                adjTriggerHelper.pertenenciaArchivo(newListAdj);
            }
            else if(Trigger.isUpdate){
                adjTriggerHelper.pertenenciaArchivo(mapOldAdjById,mapNewAdjById);
            }
        }
        if(Trigger.isAfter){
            if(Trigger.isUpdate){
                
            }else if(Trigger.isInsert){
                
            }
        }
    }
}