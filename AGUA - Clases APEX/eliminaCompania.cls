public class eliminaCompania implements Triggers.Handler{ // Implementa la clase handler
    
    public void handle(){ // Utiliza la clase auxiliar para secuenciar el trigger
        // Clase creada a partir del antiguo trigger de cuentas "eliminaCompania"
        Map<Id,Account> oldOppMap = new Map<Id,Account>((List<Account>)Trigger.old); //Se crean estos mapas para luego poder operar con ellos sin problemas.
        
        list<Id> idsParent = new list<Id>();
        for(Account cuent: oldOppMap.values()) idsParent.add(cuent.Id);
        
        list<Account> cuentasDelSistemaHijas = new list<Account>([SELECT Id, Name, RecordtypeId, ParentId FROM Account WHERE ParentId IN: idsParent]);
        list <RecordType> RecordTypeHija = new list<RecordType>([SELECT Id FROM RecordType WHERE developerName = 'Compania_Hija']);
        Id idHija= RecordTypeHija.get(0).Id;
        for(Account a : oldOppMap.values()){
            if(a.RecordtypeId != idHija) {
                for(Account b: cuentasDelSistemaHijas){
                    if(b.ParentId==a.Id) a.addError('No puede eliminar una compañia que tiene compañías hijas asociadas');
                }
            }
        }
    }
}