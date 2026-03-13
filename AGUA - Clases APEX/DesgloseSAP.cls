public class DesgloseSAP implements Triggers.Handler{ // Implementa la clase handler
    
    public void handle(){ // Utiliza la clase auxiliar para secuenciar el trigger
        // Clase creada a partir del antiguo trigger de cuentas "DesgloseSAP"
        List<Account> accList = new List<Account>(); 
        
        System.debug('------------------------------------Desglose SAP-------------------------');
        for (Account acc: (List<Account>) Trigger.new) {
            /* Desglosamos Codigo ramo 1 */
            if ((acc.COM_TXT_CodigoRamo1_HIDDEN__c  != null) && acc.COM_TXT_CodigoRamo1_HIDDEN__c.length() == 6 && (acc.OCUL_BOOL_OrigenPeticion__c==true)) {
                String MercadoAltoNivel;
                String Mercado;
                String Segmento;
                
                MercadoAltoNivel = acc.COM_TXT_CodigoRamo1_HIDDEN__c.left(2);
                Mercado = acc.COM_TXT_CodigoRamo1_HIDDEN__c.substring(2,4);
                Segmento  = acc.COM_TXT_CodigoRamo1_HIDDEN__c.right(2);
                
                /*
                System.debug(' ****************** MercadoAltoNivel: '+ MercadoAltoNivel);
                System.debug(' ****************** Mercado: '+ Mercado);
                System.debug(' ****************** Segmento: '+ Segmento);       
                */
                if (MercadoAltoNivel != null) {
                    Mercado_Alto_Nivel__c merAltNivel = Mercado_Alto_Nivel__c.getInstance(MercadoAltoNivel);
                    // System.debug('El mercado de alto nivel desde la custom setting es: '+merAltNivel.Descripcion__c);
                    // System.debug('El mercado de alto nivel en la cuenta es: '+acc.COM_SEL_Mercado_alto_nivel__c);
                    if (merAltNivel  != null) {
                        acc.COM_SEL_Mercado_alto_nivel__c = merAltNivel.Descripcion__c;
                        System.debug(acc + ' --');
                    }else {
                    	acc.COM_SEL_Mercado_alto_nivel__c = null;
                        System.debug('NULLL --');
                    }
                    //System.debug('El mercado de alto nivel desde la custom setting es: '+merAltNivel.Descripcion__c);
                    //System.debug('Después de setear la custom setting el mercado de alto nivel en la cuenta es: '+acc.COM_SEL_Mercado_alto_nivel__c);
                }
                
                if (Mercado != null) {
                    Mercado__c mer = Mercado__c.getInstance(Mercado);
                    if (mer != null) acc.COM_SEL_Mercado__c = mer.Descripcion__c;
                    else acc.COM_SEL_Mercado__c = null;
                }
                if (Segmento != null) {
                    Segmento__c seg = Segmento__c.getInstance(Segmento);
                    if (seg != null) acc.COM_SEL_Segmento__c = seg.Descripcion__c;
                    else acc.COM_SEL_Segmento__c = null;
                }
                accList.add(acc);
            }

            if ((acc.COM_NUM_Codigo__c != null) && (acc.COM_TXT_NUM_COMP__c == null) && (acc.OCUL_BOOL_OrigenPeticion__c!=true)) {
                System.debug('FLOW 1///////////');
                //System.debug(' ****************** Copiamos COM_NUM_Codigo__c en COM_TXT_NUM_COMP__c: '+ acc.COM_NUM_Codigo__c);
                acc.COM_TXT_NUM_COMP__c = acc.COM_NUM_Codigo__c;
            }
            
            /* Al dar de alta la matriz el codigo SAP lo tiene que heredar la hija  */
            System.debug('UserInfo: --' + UserInfo.getUserId() + ' Label admin ' + Label.ADMIN_USER_SAP_ID);
            System.debug('txt_grupo de cuentas: --' + acc.COM_TXT_Grupo_de_cuentas_SAP__c + ' Label fiscal ' + Label.Compania_Fiscal);
            if (UserInfo.getUserId() == Label.ADMIN_USER_SAP_ID && acc.COM_TXT_Grupo_de_cuentas_SAP__c==Label.Compania_Fiscal) {
                //System.debug(' ****************** acc.COM_NUM_Codigo__c: '+ acc.COM_NUM_Codigo__c);
                //System.debug(' ****************** Compañia Fiscal ');
                //System.debug(' ****************** acc.parentId: ' + acc.parentId);
                //System.debug(' ****************** acc.OCUL_BOOL_OrigenPeticion__c: ' + acc.OCUL_BOOL_OrigenPeticion__c);
                /* Alta de hija fiscal  */ 
                System.debug('FLOW 2///////////');
                if ((acc.parentId != null) && (acc.COM_TXT_Numero_Compania_SAP__c == null)) {
                    System.debug(' ****************** Alta hija fiscal: ');
                    Account accMatriz = [SELECT COM_TXT_Numero_Compania_SAP__c FROM Account WHERE ID = :acc.parentId];
                    System.debug('FLOW 3///////////');
                    if (accMatriz.COM_TXT_Numero_Compania_SAP__c != null) {
                        System.debug('FLOW 4///////////');
                        acc.COM_TXT_Numero_Compania_SAP__c = accMatriz.COM_TXT_Numero_Compania_SAP__c;
                        accMatriz.COM_TXT_Numero_Compania_SAP__c = null;
                        update accMatriz;
                    }
                }
            }
            
            /* Asociamos las hijas a su matriz por CIF */
            if ((acc.COM_TXT_NIFCIF__c !=null) && 
            (UserInfo.getUserId() == Label.ADMIN_USER_SAP_ID) && (acc.COM_TXT_Grupo_de_cuentas_SAP__c==Label.Compania_NO_Fiscal)) {  
                System.debug('FLOW 7///////////');
                List<Account> listAccParent = new List<Account>(); 
                listAccParent = [Select ID from Account where parentId = null AND COM_TXT_NIFCIF__c = :acc.COM_TXT_NIFCIF__c]; 
                
                if ((listAccParent != null) && (listAccParent.size()>0)) {
                    System.debug('FLOW 8///////////');
                    acc.parentId = listAccParent[0].Id;
                    String ObjectName = 'Account';
                    String RTdevName = 'Compania_Hija';
                    list<recordType> listaRT= new list<recordType>([select id from recordType where developername=:RTdevName and SobjectType=:ObjectName]);
                    //acc.RecordTypeId = '012w00000006kGWAAY';
                    acc.RecordTypeId = listaRT.get(0).Id;
                }
            }
            
            /* Las Compañias de SAP se generan inactivas */
            if ((UserInfo.getUserId() == Label.ADMIN_USER_SAP_ID) && (acc.ACC_TXT_OPERA_HIDDEN__c == Label.Insert) && (Trigger.isInsert == true)) {
                //System.debug(' ****************** Si compañia viene de SAP se crea inactiva');
                System.debug('FLOW 9///////////');
                acc.COM_BOL_Inactiva__c  = true; 
                // acc.OCUL_BOOL_OrigenPeticion__c=false;
            }          
            acc.OCUL_BOOL_OrigenPeticion__c=false;  
        }
    }
}