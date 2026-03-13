public class checkInactiva implements Triggers.Handler{ // Implementa la clase handler
    
    public void handle(){ // Utiliza la clase auxiliar para secuenciar el trigger
        // Clase creada a partir del antiguo trigger de cuentas "checkInactiva"
        Map<Id,Account> oldOppMap = new Map<Id,Account>((List<Account>)Trigger.old); //Se crean estos mapas para luego poder operar con ellos sin problemas.
        Map<Id,Account> newOppMap = new Map<Id,Account>((List<Account>)Trigger.new);
        List<Account> cuentasHijas;
        List<RecordType> RecordTypeMatriz = new List<RecordType>([SELECT Id FROM RecordType WHERE developerName = 'CUE_RT_Compania_Matriz']);
        Id idMatriz= RecordTypeMatriz.get(0).Id;
        
        for(Account cuent: newOppMap.values()){
            if(cuent.RecordTypeId == idMatriz){
                if(oldOppMap.get(cuent.Id).COM_BOL_Inactiva__c == false && newOppMap.get(cuent.Id).COM_BOL_Inactiva__c == true){
                    cuentasHijas = new List<Account>([SELECT Id FROM Account WHERE ParentId =: cuent.Id AND COM_BOL_Inactiva__c = false]);
                    if(cuentasHijas.size() > 0){
                        cuent.addError('No puede pasar a inactiva una compañia que tiene compañías hijas activas');
                    }
                }
            }
        }
    }
}