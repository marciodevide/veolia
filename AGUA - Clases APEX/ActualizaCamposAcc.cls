public class ActualizaCamposAcc implements Triggers.Handler{

    public void handle(){
        if(Trigger.isBefore){
            if(Trigger.isInsert) actualizaKam();
            else if(Trigger.isUpdate){
                actualizaInactiva();
                actualizaKam(); 
            }
        }
        if(Trigger.isAfter){
            if(Trigger.isUpdate) actualizaKamHijas();
        }
    }
    
    //Si se modifica el Kam en una compañia Matriz actualiza el Kam de las hijas activas.
    public void actualizaKamHijas(){
        if(Trigger.isUpdate){
            Map<id,Account> accKamModify = new Map<id,Account>();
            Map<id,Account> accParent = new Map<id,Account>();
            
            Account accAux;
            //Creamos una lista con las compañias que han modificado su Kam
            for(Account acc:(List<Account>)Trigger.new){
                accAux = (Account)Trigger.oldmap.get(acc.id);
                if(acc.COM_LKP_Director_de_Cuenta_KAM__c != accAux.COM_LKP_Director_de_Cuenta_KAM__c) accKamModify.put(acc.id,acc);
            }
            
            //Buscamos las compañias hijas de las compañias que han modificado su Kam y rellenamos el campo en la hija
            List<Account> accHijas = [SELECT id,COM_LKP_Director_de_Cuenta_KAM__c,ParentId FROM Account WHERE ParentId in :accKamModify.keyset() AND COM_BOL_Inactiva__c = false];
            for (Account accHija:accHijas){
                accAux = accKamModify.get(accHija.parentId);
                if(accAux.COM_LKP_Director_de_Cuenta_KAM__c != null){
                    accHija.COM_LKP_Director_de_Cuenta_KAM__c = accKamModify.get(accHija.parentId).COM_LKP_Director_de_Cuenta_KAM__c;
                } else accHija.COM_LKP_Director_de_Cuenta_KAM__c = null;
            }
            update accHijas;
        }
    }

    //Actualiza el KAM cuando se crea una cuenta o se modifica.
    public void actualizaKam(){
        List<Account> acc2update = new List<Account>();
        List<Id> parentAccIdList = new List<Id>();
        //obtenemos los parentId
        for (Account acc :(List<Account>)Trigger.new) parentAccIdList.add(acc.ParentId);

        Map<Id,Account> parentAccMap = new Map<Id,Account>([SELECT Id,COM_LKP_Director_de_Cuenta_KAM__c,COM_TXT_NIFCIF__c FROM Account WHERE Id IN :parentAccIdList]);       
        for (Account acc :(List<Account>)Trigger.new){
            if(acc.ParentId != null && acc.COM_BOL_Inactiva__c==false){
                //Si el Kam de la cuenta no es el mismo que el del padre actualizamos.
                if(acc.COM_LKP_Director_de_Cuenta_KAM__c == null && parentAccMap.get(acc.ParentId).COM_LKP_Director_de_Cuenta_KAM__c != null){
                    acc.COM_LKP_Director_de_Cuenta_KAM__c = parentAccMap.get(acc.ParentId).COM_LKP_Director_de_Cuenta_KAM__c;
                }
            }      
            if(acc.ParentId != null && acc.COM_TXT_NIFCIF__c==null) acc.COM_TXT_NIFCIF__c = parentAccMap.get(acc.ParentId).COM_TXT_NIFCIF__c;
        }
    }

    public void actualizaInactiva(){
        //Recorremos las cuentas
        List<Account> accUpdate = new List<Account>();
        for (Account acc :(List<Account>)Trigger.new){
            if(acc.COM_BOL_Inactiva__c==true && (acc.COM_LKP_Director_de_Cuenta_KAM__c!=null || acc.COM_LKP_Gerente_de_Cuenta__c!=null)){
                //Si la cuenta esta inactiva las añadiremos a una lista para actualizar las lookups
                acc.COM_LKP_Director_de_Cuenta_KAM__c=null;
                acc.COM_LKP_Gerente_de_Cuenta__c=null;
                accUpdate.add(acc);          
            }
        }
    }
}