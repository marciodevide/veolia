public without sharing class integrationSAP implements Triggers.Handler{ // Implementa la clase handler
    
    public void handle(){ // Utiliza la clase auxiliar para secuenciar el trigger
        
        System.debug('El needTriggerRun devuelve: '+UtilAcc.needTriggerRun());
        if(!UtilAcc.needTriggerRun()){
            System.debug('El needTriggerRun devuelve: '+UtilAcc.needTriggerRun());  
            System.debug('Recursivo o desde batch contadores BOWe');    
            return;            
        }
        
        //Depends from the custom labels. Si admin aqua o admin everis lanzan en el trigger mas de 5 oportunidades, no integramos.
        if(System.isFuture() || (label.Activa_Integracion_Opp != 'TRUE'  && label.Activa_Integracion_Compa_ia != 'TRUE') || (Trigger.new.size() >5 && (UserInfo.getName() == 'admin aqua' || UserInfo.getName() == 'admin everis'))) return;
        //system.debug ('==============================================>NO INTEGRAMOS');
    
        //Management insert
        
        Integer cont=0;
        Boolean actualiza_campos_relacionados = false;
        List<Id> listOppSacc = new List<Id>();
        List<AQUA_Sociedad_Ofertante__c> listEmpresa = new List<AQUA_Sociedad_Ofertante__c>();
        List<Id> listAccId = new List<Id>();
        //List <Account> listAccount = new List<Account>();
        Set<Account> listAccount = new Set<Account>();
        List<Id> listOpportId = new List<Id>();
        Map<Id,Oportunidad_Producto__c> mapProdOpportId;
        List<AQUA_Sociedad_Ofertante__c> listSociedadOfertante = new List<AQUA_Sociedad_Ofertante__c>();
        Account acc;
        AQUA_Sociedad_Ofertante__c opp1 = new AQUA_Sociedad_Ofertante__c ();
        AQUA_Sociedad_Ofertante__c empresa;
        Integer NumSol = 0;
        Map<Id,Opportunity> oldOppMap = new Map<Id,Opportunity>();
        
        // IF ORIGEN SALESFORCE
        
        map <Id, String> mapaAntiguo = new map <Id, String> ();
        map <Id, String> mapaNuevo = new map <Id, String> ();
        
        System.debug('Trigger insert ' + Trigger.isInsert);
        System.debug('Trigger update ' + Trigger.isUpdate);
        String stageOld;
        String stageNew;
        String offerLegalEntityOld;
        String offerLegalEntityNew;
        //Revisar 18/02
        Opportunity oportOld = new Opportunity();
        Opportunity oportNew = new Opportunity();
        Boolean esNueva=false;
           
        if(Trigger.isUpdate){
            System.debug('Old ' + (List<Opportunity>)Trigger.old);
            System.debug('New ' + (List<Opportunity>)Trigger.new);
            oldOppMap = new Map<Id,Opportunity>((List<Opportunity>)Trigger.old); //Se crean estos mapas para luego poder operar con ellos sin problemas.

            for (Opportunity opor : (List<Opportunity>)Trigger.new) {
                //Generamos un mapa mapaAntiguo con pares {clave: opp.Id; valor: opp.StageName}
                //Rellenamos el string stageOld con el StageName de la última opp
                //Rellenamos el sObject oportOld con la última opp
                mapaAntiguo.put(opor.Id, oldOppMap.get(opor.Id).StageName);
                stageOld=oldOppMap.get(opor.Id).StageName;
                offerLegalEntityOld = oldOppMap.get(opor.Id).OPO_LKP_Sociedad_Ofertante__c;
                oportOld = oldOppMap.get(opor.Id);

                //Generamos un mapa mapaNuevo con pares {clave: opp.Id; valor: opp.StageName}
                //Rellenamos el string stageNew con el StageName de la última opp
                //Rellenamos el sObject oportNew con la última opp
                mapaNuevo.put(opor.Id, opor.StageName);
                stageNew=opor.StageName;
                offerLegalEntityNew = opor.OPO_LKP_Sociedad_Ofertante__c;
                oportNew=opor;
            }

            System.debug('stageNew: ' + stageNew);
            System.debug('stageOld: ' + stageOld);
            System.debug('stageNew.equals(stageOld): ' + stageNew.equals(stageOld));
            System.debug('oportOld: ' + oportOld);
            System.debug('oportNew: ' + oportNew);
            System.debug('offerLegalEntityNew: ' + offerLegalEntityNew);
            System.debug('offerLegalEntityOld: ' + offerLegalEntityOld);
            //System.debug('oportOld==oportNew: ' + oportOld==oportNew);
            
            if(stageNew.equals(stageOld) && oportOld==oportNew){
                System.debug('Bypass 1');
                System.debug('Iguales stageNew: ' + stageNew);
                System.debug('Iguales stageOld: ' + stageOld);
                System.debug('Iguales oportNew: ' + oportNew);
                System.debug('Iguales oportOld: ' + oportOld);
                return;
            }
            if(stageNew.equals(stageOld) && oportOld!=oportNew && !UtilAcc.runOnce()){
                System.debug('Bypass 2');
                System.debug('Iguales stageNew: ' + stageNew);
                System.debug('Iguales stageOld: ' + stageOld);
                System.debug('Iguales oportNew: ' + oportNew);
                System.debug('Iguales oportOld: ' + oportOld);
                return;
            }

            if(!stageNew.equals(stageOld) && !UtilAcc.runOnce() && (stageNew != Label.stage5SAP && (stageNew != Label.stage3SAP || offerLegalEntityOld == offerLegalEntityNew || offerLegalEntityNew == null))){ //Si el estado ha cambiado a elaboracion de oferta y sociedad ofertante OPO_LKP_Sociedad_Ofertante__c ha pasado de vacío a relleno...
                System.debug('Bypass 3');
                System.debug('Distintos stageNew: ' + stageNew);
                System.debug('Distintos stageOld: ' + stageOld);
                System.debug('Distintos oportNew: ' + oportNew);
                System.debug('Distintos oportOld: ' + oportOld);
                System.debug('UtilAcc.runOnce: ' + UtilAcc.runOnce());
                return;
            }
            //FIN de Revisar 18/02
        }

        //FUCKING UPDATES
        Listado_Elaborador_de_oferta__c team = [SELECT Id, Name FROM Listado_Elaborador_de_oferta__c WHERE Name ='Usuario SAP'];
        User lider = [SELECT Id, Name FROM User WHERE Name='Admin SAP'];
        for (Opportunity opp :  (List<Opportunity>)Trigger.new) {  // la lista como mucho tiene tamaño uno
            System.debug('La oportunidad al inicio: '+opp);
            
            if(Trigger.isUpdate){
                if (opp.StageName != oldOppMap.get(opp.Id).StageName) {
                    opp.OPO_DAT_F_ultimo_cambio_de_estado__c = Date.today();
                }
            }
            
            if(Trigger.isInsert && UserInfo.getUserId() != Label.ADMIN_USER_SAP_ID){
                if(opp.OPO_LKP_Sociedad_Ofertante__c!=null){
                    esNueva=true;
                    System.debug('esnueva: '+esnueva);
                } else opp.OPO_SEL_Estado_SAP__c= Label.Estado_Borrador_SAP;
            }
            System.debug(' ****************** opp.StageName antes mapeo ************************' + opp.StageName);
            if((UserInfo.getUserId() == Label.ADMIN_USER_SAP_ID) && ((opp.StageName != null) || (opp.StageName != ''))){
                if(opp.StageName == Label.Oportunidad_SAP)              opp.StageName= Label.stage1SAP;
                else if(opp.StageName == Label.ENFOQUE_PRESENTADO_SAP)  opp.StageName= Label.stage2SAP; 
                else if(opp.StageName == Label.ELABORACION_SAP)         opp.StageName= Label.stage3SAP;
                else if(opp.StageName == Label.Presentada_SAP)          opp.StageName= Label.stage4SAP;
                else if(opp.StageName == Label.Ganada_SAP)              opp.StageName= Label.stage5SAP;
                else if(opp.StageName == Label.Perdida_SAP)             opp.StageName= Label.stage6SAP;
                else if(opp.StageName == Label.Cancelada_SAP)           opp.StageName= Label.stage7SAP;
                else if(opp.StageName == Label.Desestimada_SAP)         opp.StageName= Label.stage8SAP;
            }
            System.debug(' ****************** opp.StageName despues mapeo ************************' + opp.StageName);
            //***************Start Everis 01-02-21
            if (UserInfo.getUserId() == Label.ADMIN_USER_SAP_ID) {
                opp.OPO_LKP_Gerente_Cuenta__c   = team.Id;
                opp.COM_LKP_Lider_oferta__c     = lider.Id;
                opp.OPO_SEL_Canal_Entrada__c    = 'Directa';
                opp.OPP_BOL_Opp_Nueva_Flow__c   = true;
                opp.recordtypeid                = Label.RT_Espana;
            }
            System.debug(' ****************** opp.OPO_DAT_Fecha_Deteccion_Oportunidad__c antes mapeo ************************' + opp.OPO_DAT_Fecha_Deteccion_Oportunidad__c);
            System.debug(' ****************** stagename antes mapeo ************************' + opp.StageName);
            DateTime todaysDate = System.today();
            String todaysDateStr = todaysDate.format('yyyy-MM-dd');
            if ((UserInfo.getUserId() == Label.ADMIN_USER_SAP_ID) && (opp.OPO_DAT_Fecha_Deteccion_Oportunidad__c == null)){
                opp.OPO_DAT_Fecha_Deteccion_Oportunidad__c = Date.valueOf(todaysDateStr);
            }
            if ((UserInfo.getUserId() == Label.ADMIN_USER_SAP_ID) && (opp.OPO_DAT_Fecha_Deteccion_Oportunidad__c != null)){
                if(!Trigger.isUpdate){
                    opp.CloseDate                               = opp.OPO_DAT_Fecha_Deteccion_Oportunidad__c;
                    opp.Opp_DATE_Fecha_Presentacion_Informe__c  = opp.OPO_DAT_Fecha_Deteccion_Oportunidad__c;
                    opp.OPO_DAT_Fecha_Inicio_Proyecto__c        = opp.OPO_DAT_Fecha_Deteccion_Oportunidad__c;
                    opp.OPO_DAT_Fecha_Fin_Proyecto__c           = opp.OPO_DAT_Fecha_Deteccion_Oportunidad__c;
                    opp.COM_DATE_Limite_entrega_N_A__c          = opp.OPO_DAT_Fecha_Deteccion_Oportunidad__c;
                    opp.OPO_DAT_Fecha_Presentacion_Oferta__c    = opp.OPO_DAT_Fecha_Deteccion_Oportunidad__c;
                }
                //opp.OPO_DAT_Fecha_Adjudicacion__c =  opp.OPO_DAT_Fecha_Deteccion_Oportunidad__c;
            }
            if ((UserInfo.getUserId() == Label.ADMIN_USER_SAP_ID) && (opp.StageName == Label.stage2SAP)){
                opp.Opp_DATE_Fecha_Presentacion_Informe__c = opp.OPO_DAT_Fecha_Deteccion_Oportunidad__c;
                System.debug(' ****************** opp.Opp_DATE_Fecha_Presentacion_Informe__c en el if   ************************' + opp.Opp_DATE_Fecha_Presentacion_Informe__c);
            }
            if ((UserInfo.getUserId() == Label.ADMIN_USER_SAP_ID) && (opp.StageName == Label.stage5SAP)){
                opp.OPO_DAT_Fecha_Adjudicacion__c   = opp.OPO_DAT_Fecha_Deteccion_Oportunidad__c;
                opp.recordtypeid                    = Label.RT10;
                System.debug(' ****************** opp.OPO_DAT_Fecha_Adjudicacion__c en el if   ************************' + opp.OPO_DAT_Fecha_Adjudicacion__c);
            }
            if ((UserInfo.getUserId() == Label.ADMIN_USER_SAP_ID) && ((opp.StageName == Label.stage6SAP) || (opp.StageName == Label.stage7SAP) || (opp.StageName == Label.stage8SAP))){
                opp.OPO_DAT_Fecha_Cierre__c = opp.OPO_DAT_Fecha_Deteccion_Oportunidad__c;
                opp.OPO_SEL_Motivo__c       = 'Otros (motivos descarte internos)';
                //opp.recordtypeid=Label.RT10;
            }
            System.debug(' ****************** opp.OPO_DAT_Fecha_Deteccion_Oportunidad__c despues mapeo ************************' + opp.OPO_DAT_Fecha_Deteccion_Oportunidad__c);
            System.debug(' ****************** opp.OPO_DAT_Fecha_Adjudicacion__c  despues mapeo ************************' + opp.OPO_DAT_Fecha_Adjudicacion__c);
            System.debug(' ****************** opp.OPO_DAT_Fecha_Cierre__c despues mapeo ************************' + opp.OPO_DAT_Fecha_Cierre__c);
            //***************Fin Everis 01-02-21
            System.debug('=============== analizo el registro' + opp);
            //if(!Trigger.isExecuting)
            if ((UserInfo.getUserId() == Label.ADMIN_USER_SAP_ID) && (opp.OCUL_BOOL_OrigenPeticion__c==true)&& !System.isFuture()) {
                System.debug('*************** Llamada Web Service Origen SAP, método borrar productos ********************');
                DateTime dia = DateTime.now();
                
                //DateTime diaS = DateTime.newInstanceGmt(dia.year(), dia.month(), dia.day(), dia.hour(), dia.minute()-2, dia.second()); Esto pone la fecha con el horario del usuario
                DateTime diaS = dia - 0.00138888888; // Esto resta dos minutos a la hora de modificación del producto
                System.debug('La select consulta por el dia' +diaS);
                
                mapProdOpportId = new Map<Id ,Oportunidad_Producto__c> ([SELECT Id,Name FROM Oportunidad_Producto__c WHERE OP_MD_Oportunidad__c = :opp.id AND CreatedDate < :diaS]);
                if(mapProdOpportId.size() > 0) UtilAcc.DeleteProdOport(mapProdOpportId.keySet());/*TODO*/

                // origen de la peticion SAP. 
                opp.OCUL_BOOL_OrigenPeticion__c=false;
                System.debug(' ******************Si origen SAP Bloquear Oportunidad ************************');
                opp.recordtypeid=Label.RT10;

                return; 
            }
            
            // analizo la cuenta
            if(UserInfo.getUserId() != Label.ADMIN_USER_SAP_ID){
                if(Trigger.isUpdate || esNueva){
                    if (opp.accountId == null) return;
                    acc= UtilAcc.getClient(opp.accountId);   
                    
                    System.debug('=======>>> Estoy en Integracion SAP , analizo la compañia ' + acc);
                    if(NumSol==0) NumSol = UtilAcc.ObtenerMaxNumSolic();  // Calculamos el numero de peticion que vamos a integrar.
                    
                    if(opp.Id != null && opp.OPO_LKP_Sociedad_Ofertante__c != null){
                        System.debug(' =======>>> Estamos analizando la oportunidad ' + opp.Id + '  Para la sociedad ofertante ' + opp.OPO_LKP_Sociedad_Ofertante__c);
                        opp1 = UtilAcc.getSociedadOfertante(opp.OPO_LKP_Sociedad_Ofertante__c); 
                        System.debug(' =======>>>Detalle de sociedad ofertante ' + opp1);
                    }

                    if(acc != null || acc.OCUL_BOOL_OrigenPeticion__c == false){ // comprobamos si la compañia existe en SAP
                        // si la cuenta no tiene idSAP relacionado consideramos que es no existe en SAP y la enviamos a no ser que tenga otra opp relacionada realizamos ambas comprobaciones
                        if((acc.COM_TXT_Numero_Compania_SAP__c == null || acc.COM_TXT_Numero_Compania_SAP__c == '') && acc.COM_SEL_Estado__c != Label.Enviada_a_SAP){
                            System.debug(' La compañia es nueva en SAP, se realiza un insert');
                            System.debug(' acc.COM_BOL_Compania_fiscal__c ' + acc.COM_BOL_Compania_fiscal__c);
                            acc.ACC_TXT_OPERA_HIDDEN__c=Label.Insert;
                            //acc.COM_SEL_Estado_Solicitud_Modificacion__c=Label.Enviada_a_SAP;
                            acc.COM_SEL_Estado__c=Label.Enviada_a_SAP;
                            /*acc.COM_NUM_Numero_Solicitud__c =  NumSol  + 1; */
                            if((opp1 != null) && (acc.COM_TXT_HIDDEN_SOCIEDAD__c != opp1.EMP_TXT_IdSAP__c)){
                                acc.COM_TXT_HIDDEN_SOCIEDAD__c=opp1.EMP_TXT_IdSAP__c;
                                actualiza_campos_relacionados = true;
                                System.debug(' acc.Sociedad_Ofertante__c '  +  acc.Sociedad_Ofertante__c );
                                if(acc.Sociedad_Ofertante__c == null){
                                    System.debug('Entro para modificar: '+acc.Sociedad_Ofertante__c);
                                    acc.Sociedad_Ofertante__c=opp.OPO_LKP_Sociedad_Ofertante__c;
                                    System.debug('valor modificado: '+acc.Sociedad_Ofertante__c);
                                }
                                System.debug(' ============== >> La sociedad ofertante es ' + acc);
                            }
                            
                            //Se heredan las condiciones de pago de la Oportunidad
                            //if (((opp.OPO_FOR_Condicion_pago__c != null) && (opp.OPO_FOR_Condicion_pago__c != '')) && (acc.COM_HIDDEN_TXT_Condicion_pago__c != opp.OPO_FOR_Condicion_pago__c)){
                            //    System.debug(' ********* HEREDA Condicion de PAGO de OPORTUNIDAD:  ' + opp.OPO_FOR_Condicion_pago__c);
                                //acc.COM_HIDDEN_TXT_Condicion_pago__c = opp.OPO_FOR_Condicion_pago__c;
                            //    actualiza_campos_relacionados = true;
                            //}
                            
                            //if (((opp.OPO_FOR_Codigo_via_pago__c != null) && (opp.OPO_FOR_Codigo_via_pago__c != '')) && (acc.COM_HIDDEN_TXT_Codigo_via_pago__c != opp.OPO_FOR_Codigo_via_pago__c)){
                            //    System.debug(' ********* HEREDA VIA de PAGO de OPORTUNIDAD:  ' + opp.OPO_FOR_Codigo_via_pago__c);
                                //acc.COM_HIDDEN_TXT_Codigo_via_pago__c = opp.OPO_FOR_Codigo_via_pago__c;actualiza_campos_relacionados = true;
                            //}
                            
                            if(mapaAntiguo.get(opp.Id) != mapaNuevo.get(opp.Id)) actualiza_campos_relacionados = true;
                            
                            if(actualiza_campos_relacionados){
                                System.debug('Es true el campos relacionados en el 1');
                                listAccId.add(acc.Id);   
                                listAccount.add(acc); 
                                actualiza_campos_relacionados = false;
                                NumSol++;                       
                            }                       
                        }else {
                            // comprobamos si es la primera vez que esta compañia opera para esta sociedad ofertante, en caso afirmativo debemos de realizar una peticion de alta de compañia para esa sociedad.
                            System.debug(' acc.COM_BOL_Compania_fiscal__c' + acc.COM_BOL_Compania_fiscal__c);
                            cont = 0;
                            //cont = UtilAcc.getNumOpportunity(opp.accountId,opp.OPO_LKP_Sociedad_Ofertante__c);
                            cont = UtilAcc.getNumOpportunity(opp.accountId,opp.OPO_LKP_Sociedad_Ofertante__c,opp.id);
                            System.debug ('====> El numero de veces que ha operado esta compañia para esta sociedad ofertante es de ' +  cont + ' Solo integramos para valores inferiores a 1');
                            
                            if (cont < 1 && (opp1 != null && opp1.EMP_TXT_IdSAP__c !=null)){
                                Account aux = new Account ();
                                aux.Id=acc.Id;
                                System.debug('Entro en el 2');
                                System.debug('el id:'+acc.Sociedad_Ofertante__c);
                                aux.ACC_TXT_OPERA_HIDDEN__c=Label.Update;
                                aux.COM_TXT_HIDDEN_SOCIEDAD__c = acc.COM_TXT_HIDDEN_SOCIEDAD__c;
                                //aux.COM_HIDDEN_TXT_Condicion_pago__c = acc.COM_HIDDEN_TXT_Condicion_pago__c;
                                //aux.COM_HIDDEN_TXT_Codigo_via_pago__c = acc.COM_HIDDEN_TXT_Codigo_via_pago__c;
                                acc.ACC_TXT_OPERA_HIDDEN__c=Label.Update;
                                aux.OCUL_BOOL_OrigenPeticion__c=true;
                                aux.COM_SEL_Estado_Solicitud_Modificacion__c=Label.Enviada_a_SAP;
                                /*aux.COM_NUM_Numero_Solicitud__c = NumSol  + 1; aux.COM_NUM_Numero_Solicitud__c = NumSol  + 1;*/
                                aux.COM_BOL_Compania_fiscal__c = acc.COM_BOL_Compania_fiscal__c;
                                if((opp1 != null) && (aux.COM_TXT_HIDDEN_SOCIEDAD__c != opp1.EMP_TXT_IdSAP__c)){
                                if(aux.COM_TXT_HIDDEN_SOCIEDAD__c == null) aux.COM_TXT_HIDDEN_SOCIEDAD__c=opp1.EMP_TXT_IdSAP__c;
                                actualiza_campos_relacionados = true;
                                System.debug('Entro en el 2.1');
                                if(aux.ACC_TXT_OPERA_HIDDEN__c == null || aux.ACC_TXT_OPERA_HIDDEN__c == '' ) aux.Sociedad_Ofertante__c=opp.OPO_LKP_Sociedad_Ofertante__c;
                                System.debug(' ============== >> La sociedad ofertante es ' + acc);
                                }  
                                
                                //if (((opp.OPO_FOR_Condicion_pago__c != null) 
                                //&& (opp.OPO_FOR_Condicion_pago__c != '')) && 
                                //(aux.COM_HIDDEN_TXT_Condicion_pago__c != opp.OPO_FOR_Condicion_pago__c)){
                                //    System.debug(' ********* HEREDA Condicion de PAGO de OPORTUNIDAD:  ' + opp.OPO_FOR_Condicion_pago__c);
                                    //aux.COM_HIDDEN_TXT_Condicion_pago__c = opp.OPO_FOR_Condicion_pago__c;
                                //    System.debug('Entro en el 2.2');
                                //    actualiza_campos_relacionados = true;
                                //}
                                    
                                //if (((opp.OPO_FOR_Codigo_via_pago__c != null) 
                                //&& (opp.OPO_FOR_Codigo_via_pago__c != '')) && 
                                //(aux.COM_HIDDEN_TXT_Codigo_via_pago__c != opp.OPO_FOR_Codigo_via_pago__c)){
                                //    System.debug(' ********* HEREDA VIA de PAGO de OPORTUNIDAD:  ' + opp.OPO_FOR_Codigo_via_pago__c);
                                    //aux.COM_HIDDEN_TXT_Codigo_via_pago__c = opp.OPO_FOR_Codigo_via_pago__c;
                                //    System.debug('Entro en el 2.3');
                                //    actualiza_campos_relacionados = true;
                                //}
                                    
                                if(mapaAntiguo.get(opp.Id) != mapaNuevo.get(opp.Id)) actualiza_campos_relacionados = true;
                                
                                if (actualiza_campos_relacionados){
                                    System.debug('Es true el campos relacionados en el 2');
                                    NumSol++;    
                                    listAccId.add(aux.Id); 
                                    listAccount.add(aux); 
                                    actualiza_campos_relacionados = false;
                                    System.debug(' La compañia ya existia en  SAP, se realiza un update');
                                    // meto la fiscal si han sido actualizados campos relacionados con la oportunidad
                                }
                                
                                if (aux.COM_BOL_Compania_fiscal__c != true){
                                    List <Account> listAccountFiscal = UtilAcc.getClientMatriz(acc.COM_FOR_Cod_Matriz__c);
                                    
                                    if (listAccountFiscal!=null){
                                        for (Account a : listAccountFiscal){
                                            if(a.COM_BOL_Compania_fiscal__c ){
                                                if(a.COM_SEL_Estado__c != 'Borrador'){
                                                    System.debug('He encontrado la compañia fiscal  ' + a );
                                                    System.debug('Entro en el 3');
                                                    a.ACC_TXT_OPERA_HIDDEN__c=Label.Update;
                                                    acc.ACC_TXT_OPERA_HIDDEN__c=Label.Update;
                                                    a.COM_SEL_Estado_Solicitud_Modificacion__c=Label.Enviada_a_SAP;
                                                    //a.COM_SEL_Estado__c=Label.Enviada_a_SAP;
                                                    //a.COM_NUM_Numero_Solicitud__c =  NumSol  + 1; 
                                                    
                                                    if((opp1 != null) && (a.COM_TXT_HIDDEN_SOCIEDAD__c != opp1.EMP_TXT_IdSAP__c))   {
                                                        if(a.COM_TXT_HIDDEN_SOCIEDAD__c == null) a.COM_TXT_HIDDEN_SOCIEDAD__c=opp1.EMP_TXT_IdSAP__c;
                                                        actualiza_campos_relacionados = true;
                                                        System.debug('Entro en el 3.1');
                                                        if(a.Sociedad_Ofertante__c == null) a.Sociedad_Ofertante__c=opp.OPO_LKP_Sociedad_Ofertante__c;
                                                        System.debug(' ============== >> La sociedad ofertante es ' + acc);
                                                        
                                                        //Se heredan las condiciones de pago de la Oportunidad
                                                        //if ((opp.OPO_FOR_Condicion_pago__c != null
                                                        //&& opp.OPO_FOR_Condicion_pago__c != '')
                                                        //&& a.COM_HIDDEN_TXT_Condicion_pago__c != opp.OPO_FOR_Condicion_pago__c){
                                                        //    System.debug(' ********* HEREDA Condicion de PAGO de OPORTUNIDAD:  ' + opp.OPO_FOR_Condicion_pago__c);
                                                            //a.COM_HIDDEN_TXT_Condicion_pago__c = opp.OPO_FOR_Condicion_pago__c;
                                                        //    System.debug('Entro en el 3.2');
                                                        //    actualiza_campos_relacionados = true;
                                                        //}
                                                            
                                                        //if ((opp.OPO_FOR_Codigo_via_pago__c != null
                                                        //&& opp.OPO_FOR_Codigo_via_pago__c != '')
                                                        //&& a.COM_HIDDEN_TXT_Codigo_via_pago__c != opp.OPO_FOR_Codigo_via_pago__c){
                                                        //    System.debug(' ********* HEREDA VIA de PAGO de OPORTUNIDAD:  ' + opp.OPO_FOR_Codigo_via_pago__c);
                                                            //a.COM_HIDDEN_TXT_Codigo_via_pago__c = opp.OPO_FOR_Codigo_via_pago__c;
                                                        //    System.debug('Entro en el 3.3');
                                                        //    actualiza_campos_relacionados = true;
                                                        //}
                                                            
                                                        if(mapaAntiguo.get(opp.Id) != mapaNuevo.get(opp.Id)) actualiza_campos_relacionados = true;
                                                            
                                                        if (actualiza_campos_relacionados){
                                                            System.debug('Es true el campos relacionados en el 3');
                                                            NumSol++;
                                                            listAccId.add(a.Id);   
                                                            listAccount.add(a); 
                                                            actualiza_campos_relacionados = false;
                                                        }                                                   
                                                    }
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
                    
                    if(!acc.COM_BOL_Compania_fiscal__c){
                        System.debug('AAA-!acc.COM_BOL_Compania_fiscal__c: ' + !acc.COM_BOL_Compania_fiscal__c);
                        // objeto la lista de compañias dependiente de esta matriz
                        List <Account> listAccountFiscal = UtilAcc.getClientMatriz(acc.COM_FOR_Cod_Matriz__c);
                        Account accFiscal;
                        
                        // me quedo con la lista sin incluir a la acc que he estudiado anteriormente 
                        if (listAccountFiscal!=null ){
                            for (Account a : listAccountFiscal){
                                if(a.COM_BOL_Compania_fiscal__c){
                                    System.debug('He encontrado la compañia fiscal  ' + a );
                                    System.debug('He encontrado la compañia fiscal estado  ' + a.COM_SEL_Estado__c );
                                    if(a.COM_SEL_Estado__c == 'Borrador'){a.ACC_TXT_OPERA_HIDDEN__c=Label.Insert;
                                        acc.ACC_TXT_OPERA_HIDDEN__c=Label.Insert;
                                        //a.COM_SEL_Estado_Solicitud_Modificacion__c=Label.Enviada_a_SAP;
                                        a.COM_SEL_Estado__c=Label.Enviada_a_SAP;
                                        /*a.COM_NUM_Numero_Solicitud__c =  NumSol  + 1; */
                                        if((opp1 != null) &&  (a.COM_TXT_HIDDEN_SOCIEDAD__c != opp1.EMP_TXT_IdSAP__c)&& (a.COM_TXT_Numero_Compania_SAP__c == null|| a.COM_TXT_Numero_Compania_SAP__c == '')){
                                            if(a.COM_TXT_HIDDEN_SOCIEDAD__c == null){a.COM_TXT_HIDDEN_SOCIEDAD__c=opp1.EMP_TXT_IdSAP__c;}actualiza_campos_relacionados = true;
                                            if((a.Sociedad_Ofertante__c == null ||a.Sociedad_Ofertante__c == '')){a.Sociedad_Ofertante__c=opp.OPO_LKP_Sociedad_Ofertante__c;}
                                            System.debug(' ============== >> La sociedad ofertante es ' + acc);
                                        }
                                        //if (((opp.OPO_FOR_Condicion_pago__c != null) && (opp.OPO_FOR_Condicion_pago__c != '')) && (a.COM_HIDDEN_TXT_Condicion_pago__c != opp.OPO_FOR_Condicion_pago__c)){
                                        //    System.debug(' ********* HEREDA Condicion de PAGO de OPORTUNIDAD:  ' + opp.OPO_FOR_Condicion_pago__c);
                                        //    //a.COM_HIDDEN_TXT_Condicion_pago__c = opp.OPO_FOR_Condicion_pago__c;actualiza_campos_relacionados = true;
                                        //}
                                        //if ((opp.OPO_FOR_Codigo_via_pago__c != null) && (opp.OPO_FOR_Codigo_via_pago__c != '') && (a.COM_HIDDEN_TXT_Codigo_via_pago__c != opp.OPO_FOR_Codigo_via_pago__c)){
                                        //    System.debug(' ********* HEREDA VIA de PAGO de OPORTUNIDAD:  ' + opp.OPO_FOR_Codigo_via_pago__c);
                                            //a.COM_HIDDEN_TXT_Codigo_via_pago__c = opp.OPO_FOR_Codigo_via_pago__c;actualiza_campos_relacionados = true;
                                        //}
                                        if (actualiza_campos_relacionados){
                                            NumSol++;
                                            listAccId.add(a.Id);   
                                            listAccount.add(a);
                                            actualiza_campos_relacionados = false;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                //FUCKING UPDATES
                System.debug('*************** Paso 1 comprobamos si la oportunidad cumple con alguna regla sobre el objeto empresa: >>>> status:  ' + opp.StageName +
                                ' Sociedad Ofertante: ' + opp.OPO_LKP_Sociedad_Ofertante__c  );
                
                if(opp.OPO_LKP_Sociedad_Ofertante__c==null || String.valueOf(opp.OPO_LKP_Sociedad_Ofertante__c )==''){
                    System.debug('La oportunidad no tiene informada la sociedad ofertante, no integramos con SAP');
                    return;
                }
                
                // modo bloqueo, cedemos testigo a SAP
                
                System.debug('============================================  Valores de la select=> status: ' + opp.StageName + ' sociedad ofertantes: ' +  opp.OPO_LKP_Sociedad_Ofertante__c );
                
                listSociedadOfertante = [SELECT EMP_BOL_Sociedad_Ofertante_del__c, EMP_BOL_Notificacion_SAP__c ,EMP_SEL_Estado__c FROM AQUA_Sociedad_Ofertante__c 
                                            WHERE (EMP_SEL_Estado__c includes (:opp.StageName) 
                                                AND EMP_BOL_Sociedad_Ofertante_del__c = true AND id=: opp.OPO_LKP_Sociedad_Ofertante__c ) 
                                            OR (EMP_BOL_Notificacion_SAP__c = true
                                                AND EMP_BOL_Sociedad_Ofertante_del__c = true 
                                                AND id=: opp.OPO_LKP_Sociedad_Ofertante__c )
                                            OR (EMP_BOL_Sociedad_Ofertante_del__c = true 
                                                AND id=: opp.OPO_LKP_Sociedad_Ofertante__c )];
                
                System.debug('***** El numero de reglas que cumple es ' + listSociedadOfertante );
                
                System.debug('***** OPO_OCUL_BOOL_LLAMADA_SAP__c ' + opp.OPO_OCUL_BOOL_LLAMADA_SAP__c );
                //System.Debug('Entra a este bucle');
                // Si el cambio es debido a el botón javascript y no son usuarios administradores
                PermissionSet pSet = [SELECT PermissionsModifyAllData FROM PermissionSet WHERE ProfileId=:UserInfo.getProfileId() LIMIT 1];
                System.debug('list of opportunities old ' + (List<Opportunity>)Trigger.old);
                if(Trigger.old != null) oldOppMap = new Map<Id,Opportunity>((List<Opportunity>)Trigger.old);//TODO
                System.debug('Map of opportunities old ' + oldOppMap);
                if(Trigger.isInsert && !UtilAcc.runOnce()){}
                else{
                    System.debug('else offer society');
                    System.debug('else offer society-listSociedadOfertante: ' + listSociedadOfertante);
                    System.debug('else offer society-listSociedadOfertante.size(): ' + listSociedadOfertante.size());
                    if (listSociedadOfertante.size() > 0 && listSociedadOfertante[0] != null) {
                        System.debug('else offer society-listSociedadOfertante[0].EMP_SEL_Estado__c: ' + listSociedadOfertante[0].EMP_SEL_Estado__c);
                        System.debug('else offer society-String.valueOf(listSociedadOfertante[0].EMP_SEL_Estado__c): ' + String.valueOf(listSociedadOfertante[0].EMP_SEL_Estado__c));
                        System.debug('else offer society-listSociedadOfertante[0].EMP_BOL_Sociedad_Ofertante_del__c: ' + listSociedadOfertante[0].EMP_BOL_Sociedad_Ofertante_del__c);
                    }
                    System.debug('else offer society-String.valueOf(opp.StageName): ' + String.valueOf(opp.StageName));
                    if(listSociedadOfertante != null && listSociedadOfertante.size() > 0 && listSociedadOfertante[0].EMP_SEL_Estado__c != null && 
                    (String.valueOf(listSociedadOfertante[0].EMP_SEL_Estado__c).contains(String.valueOf(opp.StageName)) && listSociedadOfertante[0].EMP_BOL_Sociedad_Ofertante_del__c==true)){
                        System.debug('Enviamos y bloqueamos opp, Estoy en 1-> opp '+opp);
                        //opp.recordtypeid=Label.RT10;
                        opp.OCUL_BOOL_OrigenPeticion__c=false;
                        opp.OPO_SEL_Estado_SAP__c= Label.Enviada_a_SAP;
                        opp.ActSap__c=true;
                        opp.OPO_OCUL_BOOL_LLAMADA_SAP__c = true;
                        listOpportId.add(opp.id);
                    }else if(opp.OPO_BOL_Seguimiento_de_Costes__c==true 
                    && listSociedadOfertante!=null 
                    && listSociedadOfertante.size() > 0
                    && listSociedadOfertante[0].EMP_BOL_Sociedad_Ofertante_del__c==true){
                        System.debug('Enviamos y dejamos editar opp, Estoy en 2 -> opp '+opp);
                        opp.OCUL_BOOL_OrigenPeticion__c=false;
                        opp.OPO_SEL_Estado_SAP__c= Label.Enviada_a_SAP;
                        opp.OPO_OCUL_BOOL_LLAMADA_SAP__c = true;
                        listOpportId.add(opp.id); 
                        opp.ActSap__c=false;
                    }else if(listSociedadOfertante!=null &&
                    listSociedadOfertante.size() > 0 
                    && listSociedadOfertante[0].EMP_BOL_Notificacion_SAP__c==true){
                                        
                        System.debug('Solo Enviamos opp y dejamos editar opp, Estoy en 3-> opp '+opp);    
                        opp.OPO_SEL_Estado_SAP__c= Label.Enviada_a_SAP;
                        opp.OCUL_BOOL_OrigenPeticion__c=false;
                        opp.OPO_OCUL_BOOL_LLAMADA_SAP__c = true;
                        listOppSacc.add(opp.id);
                        opp.ActSap__c=false;
                    }
                }
            }
        }
        
        
        // Integramos
        
        if(listOpportId.size()> 0 && !(Trigger.isInsert)){
            System.debug('A aqui si');
            if(listAccId.size()>0 && !Test.isRunningTest()){
                System.debug('************** Llamada a Clientes*****************');
                List <Account> listAccount1 = new List<Account>(listAccount);
                System.debug('soy un trigger before?: '+ Trigger.isBefore+ ' el contenido de listaccount es: '+ listAccount1);
                System.debug('El id del usuario activo es: '+UserInfo.getUserId()+ 'El usuario tiene permisos para borrar? '+Schema.sObjectType.Account.isUpdateable());
                update(listAccount1);
                if(acc.ACC_TXT_OPERA_HIDDEN__c == 'I'){
                    Z017vClientesWsSf_CreateCompaniaSAP.invokeFuturo(listAccId, acc.ACC_TXT_OPERA_HIDDEN__c);
                    System.debug('invoco a  insertar cliente '+listAccId+' '+acc.ACC_TXT_OPERA_HIDDEN__c);
                }else{
                    Z017vClientesWsSf_CreateCompaniaSAP.invokeExtension(listAccId, acc.ACC_TXT_OPERA_HIDDEN__c);
                    System.debug('invoco a  modifico cliente');
                    System.debug('==============envio de cuentas a SAP: ' + listAccId+' '+acc.ACC_TXT_OPERA_HIDDEN__c);
                }
                System.debug('============== actualizamos cuentas sobre la oportunidad' + listAccount);
                System.debug('************** Despues Llamada a Clientes*****************');
            }
            System.debug('************** Llamada a Oportunidades *****************' );
            System.debug('listOpportId: ' + listOpportId);
            Z017V_OFERTAS_SF_CreateOportunidadSAP.invokeFuturo(listOpportId);
        }
        if(listOppSacc.size()> 0 && !Test.isRunningTest() ){
            //Cuando opp ganada, sociedad ofertante (Company) con Id SAP relleno y no está informado el Company number SAP en account (C)
            System.debug('************** Llamada a Oportunidades sin account *****************' );
            Z017V_OFERTAS_SF_CreateOportunidadSAP.invokeFuturo(listOppSacc);
            system.debug('============================================================= Lista listoppSacc' +  listOppSacc);
            System.debug('************** Despues llamada a Oportunidades sin account *****************');
        }
    }
}