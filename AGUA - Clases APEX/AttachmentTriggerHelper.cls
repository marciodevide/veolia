public class AttachmentTriggerHelper {
    public void pertenenciaArchivo(List<Adjuntos_Aprobacion__c> newMap){
        Map<Id,String> mapOppArchivo = new Map<Id,String>();
        for (Adjuntos_Aprobacion__c adj :newMap){
            if(adj.AttachmentOwnership__c == 'SSJJ'){
                mapOppArchivo.put(adj.Opportunity__c,'SSJJ');
            }else if(adj.AttachmentOwnership__c == 'Ecofin'){
                mapOppArchivo.put(adj.Opportunity__c,'Ecofin');
            }
       	}
        if(!mapOppArchivo.isEmpty()){
           	List<Opportunity> listOpp = new List<Opportunity>();
            for(Opportunity opp : [SELECT Id,OPO_BOL_SSJJ_Archivos__c,OPO_BOL_Ecofin_Archivos__c FROM Opportunity WHERE Id in:mapOppArchivo.keySet()]){
                if(mapOppArchivo.get(opp.id)=='SSJJ'){
                    if(opp.OPO_BOL_SSJJ_Archivos__c!=null){
                        opp.OPO_BOL_SSJJ_Archivos__c ++;
                    }else{
                        opp.OPO_BOL_SSJJ_Archivos__c = 1;
                    }
                    listOpp.add(opp);
                }else if(mapOppArchivo.get(opp.id)=='Ecofin'){
                    if(opp.OPO_BOL_Ecofin_Archivos__c!=null){
                        opp.OPO_BOL_Ecofin_Archivos__c ++;
                    }else{
                        opp.OPO_BOL_Ecofin_Archivos__c = 1;
                    }
                    listOpp.add(opp);
                }
            }
            if(!listOpp.isEmpty()){
                update listOpp;
            }
        }
   }
   public void pertenenciaArchivo(Map<Id,Adjuntos_Aprobacion__c> oldMap,Map<Id,Adjuntos_Aprobacion__c> newMap){
       	Map<Id,String> mapOldOppArchivo = new Map<Id,String>();
        Map<Id,String> mapOppArchivo = new Map<Id,String>();
        for (Adjuntos_Aprobacion__c adj :newMap.values()){
            mapOppArchivo.put(adj.Opportunity__c,adj.AttachmentOwnership__c);
            mapOldOppArchivo.put(adj.Opportunity__c,oldMap.get(adj.id).AttachmentOwnership__c);
       	}
        if(!mapOppArchivo.isEmpty()){
           	List<Opportunity> listOpp = new List<Opportunity>();
            for(Opportunity opp : [SELECT Id,OPO_BOL_SSJJ_Archivos__c,OPO_BOL_Ecofin_Archivos__c FROM Opportunity WHERE Id in:mapOppArchivo.keySet()]){
                if(mapOppArchivo.get(opp.id)=='SSJJ' && mapOldOppArchivo.get(opp.id)!='SSJJ') {
                    if(opp.OPO_BOL_SSJJ_Archivos__c!=null){
                        opp.OPO_BOL_SSJJ_Archivos__c ++;
                    }else{
                        opp.OPO_BOL_SSJJ_Archivos__c = 1;
                    }
                    if(mapOldOppArchivo.get(opp.id)=='Ecofin'){
                        opp.OPO_BOL_Ecofin_Archivos__c--;
                    }
                    listOpp.add(opp);
                }else if(mapOppArchivo.get(opp.id)=='Ecofin' && mapOldOppArchivo.get(opp.id)!='Ecofin') {
                    if(opp.OPO_BOL_Ecofin_Archivos__c!=null){
                        opp.OPO_BOL_Ecofin_Archivos__c ++;
                    }else{
                        opp.OPO_BOL_Ecofin_Archivos__c = 1;
                    }
                    if(mapOldOppArchivo.get(opp.id)=='SSJJ'){
                        opp.OPO_BOL_SSJJ_Archivos__c--;
                    }
                    listOpp.add(opp);
                }else if(mapOppArchivo.get(opp.id)=='Otros'){
                    if(mapOldOppArchivo.get(opp.id)=='SSJJ'){
                        opp.OPO_BOL_SSJJ_Archivos__c--;
                    }else if(mapOldOppArchivo.get(opp.id)=='Ecofin'){
                        opp.OPO_BOL_Ecofin_Archivos__c--;
                    }
                    listOpp.add(opp);
                }
            }
            if(!listOpp.isEmpty()){
                update listOpp;
            }
        }
   }
}