/***********************
Evolutivo: Petición BOS
Autor: Everis
Fecha creación: 02/05/2017

Incluye la lógica de los contadores BOS auxiliares. Si se elimina una petición BOS su contador asociado deberá eliminarse también
*****************************/
public class ContadorBOSDeletion implements Triggers.Handler{
    
    public void handle(){
        List<Id> cBOSIds = new List<Id>();
        for(sObject pBOS:Trigger.old) cBOSIds.add((Id)pBOS.get('BOS_lkp_Contador_BOS__c'));
        List<Contador_BOS__c> cBOSToDelete = new List<Contador_BOS__c>();
        cBOSToDelete=[SELECT Id FROM Contador_BOS__c WHERE Id IN:cBOSIds];
        try{
            if(cBOSToDelete!=null&&cBOSToDelete.size()>0) delete cBOSToDelete;
        }catch(exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
}