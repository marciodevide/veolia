public class IntegracionSAPAfter implements Triggers.Handler{ // Implementa la clase handler
    
    public void handle(){ // Utiliza la clase auxiliar para secuenciar el trigger
        
        Map<Id,Opportunity> newOppMap = new Map<Id,Opportunity>((List<Opportunity>)Trigger.new);  //Se crean estos mapas para luego poder operar con ellos sin problemas.
        System.debug('El needTriggerRun devuelve: '+UtilAcc.needTriggerRun());
        
        if(! UtilAcc.runOnceAfter() || !UtilAcc.needTriggerRun()) {
            System.debug('El needTriggerRun devuelve: '+UtilAcc.needTriggerRun());  
            System.debug('Recursivo o contador BOWe');    
            return;            
        }
        
        if(System.isFuture() || (label.Activa_Integracion_Opp != 'TRUE' && label.Activa_Integracion_Compa_ia != 'TRUE')) {
            system.debug ('==============================================>NO INTEGRAMOS');
            return;
        }
        
        // Management insert
        Integer cont=0;
        List <Id> listOppSacc = new List<Id>();
        List <AQUA_Sociedad_Ofertante__c> listEmpresa = new List<AQUA_Sociedad_Ofertante__c>();
        List <Id> listAccId = new List<Id>();
        //List <Account> listAccount = new List<Account>();
        Set<Account> listAccount = new Set<Account>();
        List <Id> listOpportId = new List<Id>();
        Map < Id ,Oportunidad_Producto__c> mapProdOpportId;
        List <AQUA_Sociedad_Ofertante__c>listSociedadOfertante = new List<AQUA_Sociedad_Ofertante__c>();
        Account acc;
        AQUA_Sociedad_Ofertante__c opp1 = new AQUA_Sociedad_Ofertante__c ();
        AQUA_Sociedad_Ofertante__c empresa;
        Integer NumSol = 0;
        
        // IF ORIGEN SALESFORCE
        
        for (Opportunity opp :  newOppMap.values()) {  // la lista como mucho tiene tamaño uno
            System.debug('=============== analizo el registro' + opp);
            
            if (UserInfo.getUserId() != Label.ADMIN_USER_SAP_ID) {
                // analizo la cuenta
                
                if (opp.accountId == null) return; // no puede existir oportunidades sin compañia.
                acc = UtilAcc.getClient(opp.accountId);   
                
                System.debug('=======>>> Estoy en Integracion SAP , analizo la compañia ' + acc);
                if(NumSol == 0) NumSol = UtilAcc.ObtenerMaxNumSolic(); // Calculamos el numero de peticion que vamos a integrar.
                
                if(opp.Id!=null && opp.OPO_LKP_Sociedad_Ofertante__c !=null ){
                    System.debug(' =======>>> Estamos analizando la oportunidad ' + opp.Id + '  Para la sociedad ofertante ' + opp.OPO_LKP_Sociedad_Ofertante__c);
                    opp1 = UtilAcc.getSociedadOfertante(opp.OPO_LKP_Sociedad_Ofertante__c); 
                    System.debug(' =======>>>Detalle de sociedad ofertante ' + opp1);
                }

                if(acc.OCUL_BOOL_OrigenPeticion__c == false) { // comprobamos si la compañia existe en SAP
                    // si la cuenta no tiene idSAP relacionado consideramos que es no existe en SAP y la enviamos a no ser que tenga otra opp relacionada realizamos ambas comprobaciones
                    if((acc.COM_TXT_Numero_Compania_SAP__c == null || acc.COM_TXT_Numero_Compania_SAP__c == '') && 
                    acc.COM_SEL_Estado__c != Label.Enviada_a_SAP) {
                        System.debug(' La compañia es nueva en SAP, se realiza un insert');
                        System.debug(' acc.COM_BOL_Compania_fiscal__c' + acc.COM_BOL_Compania_fiscal__c);
                        acc.ACC_TXT_OPERA_HIDDEN__c=Label.Insert;
                        //acc.COM_SEL_Estado_Solicitud_Modificacion__c=Label.Enviada_a_SAP;
                        acc.COM_SEL_Estado__c=Label.Enviada_a_SAP;
                        /*acc.COM_NUM_Numero_Solicitud__c =  NumSol  + 1; */
                        NumSol++;
                        if(opp1 != null) {
                            acc.COM_TXT_HIDDEN_SOCIEDAD__c=opp1.EMP_TXT_IdSAP__c;
                            System.debug(' ============== >> La sociedad ofertante es ' + acc);
                        }
                        //Se heredan las condiciones de pago de la Oportunidad
                        //if ((opp.OPO_FOR_Condicion_pago__c != null) && (opp.OPO_FOR_Condicion_pago__c != '')) {
                        //    System.debug(' ********* HEREDA Condicion de PAGO de OPORTUNIDAD:  ' + opp.OPO_FOR_Condicion_pago__c);
                            //acc.COM_HIDDEN_TXT_Condicion_pago__c = opp.OPO_FOR_Condicion_pago__c;
                        //}
                        //if ((opp.OPO_FOR_Codigo_via_pago__c != null) && (opp.OPO_FOR_Codigo_via_pago__c != '')) {
                        //    System.debug(' ********* HEREDA VIA de PAGO de OPORTUNIDAD:  ' + opp.OPO_FOR_Codigo_via_pago__c);
                            //acc.COM_HIDDEN_TXT_Codigo_via_pago__c = opp.OPO_FOR_Codigo_via_pago__c;
                        //}
                        listAccId.add(acc.Id);   
                        listAccount.add(acc);   
                    } else {
                        // comprobamos si es la primera vez que esta compañia opera para esta sociedad ofertante, en caso afirmativo debemos de realizar una peticion de alta de compañia para esa sociedad.
                        System.debug(' acc.COM_BOL_Compania_fiscal__c' + acc.COM_BOL_Compania_fiscal__c);
                        cont = 0;
                        cont = UtilAcc.getNumOpportunity(opp.accountId,opp.OPO_LKP_Sociedad_Ofertante__c, opp.id);
                        System.debug ('====> El numero de veces que ha operado esta compañia para esta sociedad ofertante es de ' +  cont + ' Solo integramos para valores inferiores a 2');
                        System.debug('-------' + cont + opp1.EMP_TXT_IdSAP__c + opp1);
                        if (cont < 1  && (opp1 != null && opp1.EMP_TXT_IdSAP__c !=null)) {
                            Account aux = new Account ();
                            aux.Id=acc.Id;
                            aux.ACC_TXT_OPERA_HIDDEN__c=Label.Update;
                            aux.OCUL_BOOL_OrigenPeticion__c=true;
                            aux.COM_SEL_Estado_Solicitud_Modificacion__c=Label.Enviada_a_SAP;
                            /*
                            aux.COM_NUM_Numero_Solicitud__c = NumSol  + 1;
                            aux.COM_NUM_Numero_Solicitud__c = NumSol  + 1;
                            */
                            aux.COM_BOL_Compania_fiscal__c = acc.COM_BOL_Compania_fiscal__c;
                            NumSol++;
                            if(opp1 != null) {
                                if(aux.COM_TXT_HIDDEN_SOCIEDAD__c == null) aux.COM_TXT_HIDDEN_SOCIEDAD__c=opp1.EMP_TXT_IdSAP__c;
                                System.debug(' ============== >> La sociedad ofertante es ' + acc);
                            }  
                            
                            //Se heredan las condiciones de pago de la Oportunidad
                            //if ((opp.OPO_FOR_Condicion_pago__c != null) && (opp.OPO_FOR_Condicion_pago__c != '')) {
                            //    System.debug('********* HEREDA Condicion de PAGO de OPORTUNIDAD:  ' + opp.OPO_FOR_Condicion_pago__c);
                                //aux.COM_HIDDEN_TXT_Condicion_pago__c = opp.OPO_FOR_Condicion_pago__c;
                            //}
                            
                            //if ((opp.OPO_FOR_Codigo_via_pago__c != null) && (opp.OPO_FOR_Codigo_via_pago__c != '')) {
                                //System.debug('********* HEREDA VIA de PAGO de OPORTUNIDAD:  ' + opp.OPO_FOR_Codigo_via_pago__c);
                                //aux.COM_HIDDEN_TXT_Codigo_via_pago__c = opp.OPO_FOR_Codigo_via_pago__c;
                            //}
                            
                            listAccId.add(aux.Id);
                            listAccount.add(aux);
                            System.debug('La compañia ya existia en  SAP, se realiza un update');
                            // meto la fiscal
                            
                            if (aux.COM_BOL_Compania_fiscal__c != true) {
                                List <Account> listAccountFiscal = UtilAcc.getClientMatriz(acc.COM_FOR_Cod_Matriz__c);
                                if (listAccountFiscal!=null){
                                    for (Account a : listAccountFiscal){
                                        
                                        if(a.COM_BOL_Compania_fiscal__c){
                                            System.debug('He encontrado la compañia fiscal  ' + a );
                                            
                                            a.ACC_TXT_OPERA_HIDDEN__c=Label.Update;
                                            a.COM_SEL_Estado_Solicitud_Modificacion__c=Label.Enviada_a_SAP;
                                            /*
                                            a.COM_SEL_Estado__c=Label.Enviada_a_SAP;
                                            a.COM_NUM_Numero_Solicitud__c =  NumSol  + 1;
                                            */
                                            NumSol++;
                                            if(opp1 != null) {
                                                if(a.COM_TXT_HIDDEN_SOCIEDAD__c == null) a.COM_TXT_HIDDEN_SOCIEDAD__c=opp1.EMP_TXT_IdSAP__c;
                                                System.debug(' ============== >> La sociedad ofertante es ' + acc);
                                                
                                                //Se heredan las condiciones de pago de la Oportunidad
                                                //if ((opp.OPO_FOR_Condicion_pago__c != null) && (opp.OPO_FOR_Condicion_pago__c != '')) {
                                                //    System.debug(' ********* HEREDA Condicion de PAGO de OPORTUNIDAD:  ' + opp.OPO_FOR_Condicion_pago__c);
                                                    //a.COM_HIDDEN_TXT_Condicion_pago__c = opp.OPO_FOR_Condicion_pago__c;
                                                //}
                                                
                                                //if ((opp.OPO_FOR_Codigo_via_pago__c != null) && (opp.OPO_FOR_Codigo_via_pago__c != '')) {
                                                //    System.debug(' ********* HEREDA VIA de PAGO de OPORTUNIDAD:  ' + opp.OPO_FOR_Codigo_via_pago__c);
                                                    //a.COM_HIDDEN_TXT_Codigo_via_pago__c = opp.OPO_FOR_Codigo_via_pago__c;
                                                //}
                                                listAccId.add(a.Id);   
                                                listAccount.add(a);  
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // fin gestion de account  
                cont=0; // reset de variables
                if(!acc.COM_BOL_Compania_fiscal__c) {
                    // objeto la lista de compañias dependiente de esta matriz
                    List <Account> listAccountFiscal = UtilAcc.getClientMatriz(acc.COM_FOR_Cod_Matriz__c);
                    Account accFiscal;
                    // me quedo con la lista sin incluir a la acc que he estudiado anteriormente 
                    if(listAccountFiscal!=null){
                        for(Account a : listAccountFiscal){
                            if(a.COM_BOL_Compania_fiscal__c){
                                System.debug('He encontrado la compañia fiscal ' + a );
                                if(a.COM_SEL_Estado__c == 'Borrador'){
                                    a.ACC_TXT_OPERA_HIDDEN__c=Label.Insert;
                                    //a.COM_SEL_Estado_Solicitud_Modificacion__c=Label.Enviada_a_SAP;
                                    a.COM_SEL_Estado__c=Label.Enviada_a_SAP;
                                    /*a.COM_NUM_Numero_Solicitud__c =  NumSol  + 1; */
                                    NumSol++;
                                    if(opp1 != null) {
                                        if(a.COM_TXT_HIDDEN_SOCIEDAD__c == null) a.COM_TXT_HIDDEN_SOCIEDAD__c=opp1.EMP_TXT_IdSAP__c;
                                        System.debug(' ============== >> La sociedad ofertante es ' + acc);
                                    } 
                                    
                                    System.debug(' ********* HEREDA Condicion de PAGO de OPORTUNIDAD 4:  ' + opp.OPO_FOR_Condicion_pago__c); 
                                    //if ((opp.OPO_FOR_Condicion_pago__c != null) && (opp.OPO_FOR_Condicion_pago__c != '')) {
                                    //    System.debug(' ********* HEREDA Condicion de PAGO de OPORTUNIDAD:  ' + opp.OPO_FOR_Condicion_pago__c);
                                        //a.COM_HIDDEN_TXT_Condicion_pago__c = opp.OPO_FOR_Condicion_pago__c;
                                    //}
                                    
                                    //if ((opp.OPO_FOR_Codigo_via_pago__c != null) && (opp.OPO_FOR_Codigo_via_pago__c != '')) {
                                    //    System.debug(' ********* HEREDA VIA de PAGO de OPORTUNIDAD:  ' + opp.OPO_FOR_Codigo_via_pago__c);
                                        //a.COM_HIDDEN_TXT_Codigo_via_pago__c = opp.OPO_FOR_Codigo_via_pago__c;
                                    //}
                                    
                                    listAccId.add(a.Id);   
                                    listAccount.add(a);  
                                }
                            }
                        }
                    }
                }
                
                System.debug('*************** Paso 1 comprobamos si la oportunidad cumple con alguna regla sobre el objeto empresa: >>>> status:  ' + opp.StageName +
                             ' Sociedad Ofertante: ' + opp.OPO_LKP_Sociedad_Ofertante__c  );
                
                if(opp.OPO_LKP_Sociedad_Ofertante__c==null || String.valueOf(opp.OPO_LKP_Sociedad_Ofertante__c)==''){
                    System.debug('La oportunidad no tiene informada la sociedad ofertante, no integramos con SAP');
                    return;
                }
                
                // modo bloqueo, cedemos testigo a SAP
                System.debug('============================================  Valores de la select=> status: ' + opp.StageName + ' sociedad ofertantes: ' +  opp.OPO_LKP_Sociedad_Ofertante__c);
                listSociedadOfertante = [SELECT EMP_BOL_Sociedad_Ofertante_del__c,EMP_BOL_Notificacion_SAP__c,EMP_SEL_Estado__c FROM AQUA_Sociedad_Ofertante__c 
                                            WHERE (EMP_SEL_Estado__c includes (:opp.StageName) 
                                                AND EMP_BOL_Sociedad_Ofertante_del__c = true AND id=: opp.OPO_LKP_Sociedad_Ofertante__c)
                                            OR (EMP_BOL_Notificacion_SAP__c = true
                                                AND EMP_BOL_Sociedad_Ofertante_del__c = true AND id=: opp.OPO_LKP_Sociedad_Ofertante__c)
                                            OR (EMP_BOL_Sociedad_Ofertante_del__c = true AND id=: opp.OPO_LKP_Sociedad_Ofertante__c)];
                
                System.debug('***** El numero de reglas que cumple es ' + listSociedadOfertante);
                System.debug('***** OPO_OCUL_BOOL_LLAMADA_SAP__c ' + opp.OPO_OCUL_BOOL_LLAMADA_SAP__c);
                
                if(listSociedadOfertante != null && listSociedadOfertante.size() > 0 && listSociedadOfertante[0].EMP_SEL_Estado__c != null && 
                (String.valueOf(listSociedadOfertante[0].EMP_SEL_Estado__c).contains(String.valueOf(opp.StageName)) &&  
                listSociedadOfertante[0].EMP_BOL_Sociedad_Ofertante_del__c==true)) {
                    System.debug('Enviamos y bloqueamos opp');
                    listOpportId.add(opp.id);
                }else if(opp.OPO_BOL_Seguimiento_de_Costes__c ==true && listSociedadOfertante!= null &&
                listSociedadOfertante.size() > 0 && listSociedadOfertante[0].EMP_BOL_Sociedad_Ofertante_del__c==true){
                    System.debug('Enviamos y dejamos editar opp');
                    listOpportId.add(opp.id);
                }else if(listSociedadOfertante!= null &&
                listSociedadOfertante.size() > 0 && listSociedadOfertante[0].EMP_BOL_Notificacion_SAP__c ==true ){
                    System.debug('Solo Enviamos opp y dejamos editar opp');
                    listOppSacc.add(opp.id);
                }
            }
        }// fin for.
        
        // Integramos
        if((listOpportId.size()>0) && !Test.isRunningTest()){
            if (listAccId.size()>0){
                System.debug('************** Llamada a Clientes*****************');
                List <Account> listAccount1 = new List<Account>(listAccount);
                update(listAccount1);
                if(acc.ACC_TXT_OPERA_HIDDEN__c == 'I'){
                    Z017vClientesWsSf_CreateCompaniaSAP.invokeFuturo(listAccId, acc.ACC_TXT_OPERA_HIDDEN__c);
                    system.debug('invoco a  insetar cliente');
                }else Z017vClientesWsSf_CreateCompaniaSAP.invokeExtension(listAccId, acc.ACC_TXT_OPERA_HIDDEN__c);

                system.debug('============== actualizamos cuentas sobre la oportunidad' + listAccount);
                system.debug('invoco a  modifico cliente');
                System.debug('************** Despues Llamada a Clientes*****************');
            }
            System.debug('************** Llamada a Oportunidades *****************' );
            Z017V_OFERTAS_SF_CreateOportunidadSAP.invokeFuturo(listOpportId);
            system.debug('================================================================== Lista listOpportId' +  listOpportId);
            System.debug('************** Despues llamada a Oportunidades *****************');
        }
        if(listOppSacc.size()>0){
            System.debug('************** Llamada a Oportunidades sin account *****************' );
            Z017V_OFERTAS_SF_CreateOportunidadSAP.invokeFuturo(listOppSacc);
            system.debug('============================================================= Lista listoppSacc' +  listOppSacc);
            System.debug('************** Despues llamada a Oportunidades sin account *****************');
        }
    }
}