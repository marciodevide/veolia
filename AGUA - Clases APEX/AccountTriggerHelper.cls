public with sharing class AccountTriggerHelper {
	public void AccountProcess(List<Account> oldMap, List<Account> newMap){
        for (Account acc :newMap){
            // SociedadOfertante
            // El campo a usarse pasa a ser COM_TXT_HIDDEN_SOCIEDAD_ID__c (Un campo formula), actualizar los sitios 
            // donde se usa el campo COM_TXT_HIDDEN_SOCIEDAD__c e indicar COM_TXT_HIDDEN_SOCIEDAD_ID__c
            // 
            // CamposPendSAP
            if(String.isNotBlank(acc.Campos_pendiente_de_envio_SAP__c) && acc.COM_TXT_HIDDEN_LastModifiedAlias__c!='aaquates'){
                acc.COM_BOL_Ind_camp_pend_SAP__c = true;
            }
            // CamposNOPendSAP
            else if(String.isBlank(acc.Campos_pendiente_de_envio_SAP__c) || acc.COM_TXT_HIDDEN_LastModifiedAlias__c=='aaquates'){
                acc.COM_BOL_Ind_camp_pend_SAP__c = false;
            }
        }
    }
    
    public void AccountProcessSAP(List<Account> oldMap, List<Account> newMap){
        List<Account> listAccToUpdate = new List<Account>();
        Boolean addToListCheck = false;
        for (Account acc :newMap){
            // NUM_COMPAÑIA
            // DEPRECATED, NO SE USA
            //
            // NUM_COMPAÑIA
            // Alternativa
            if(acc.COM_NUM_Codigo__c!=acc.COM_TXT_NUM_COMP__c){
                acc.COM_TXT_NUM_COMP__c = acc.COM_NUM_Codigo__c;
            }
        }
    }
    public void ChangeOwner(List<Account> newMap){      
        List<User> users = [SELECT id,Name FROM User WHERE Name='Admin SAP' OR Name='Admin Aqua' ];
        User adminSap;
        User adminAqua;
        for(User us : users){
            if(us.Name=='Admin SAP'){
                adminSap = us;
            }else if(us.Name=='Admin Aqua'){
                adminAqua = us;
            }
        }
        if(adminSap != null && adminAqua != null){
            for (Account acc :newMap){
                // Process Builder - Asigna account owner
                if(acc.OwnerId!=adminSap.id){
                    acc.OwnerId = adminAqua.id; 
                }
            }
        }
    }
}