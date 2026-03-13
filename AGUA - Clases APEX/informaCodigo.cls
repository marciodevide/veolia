public class informaCodigo implements Triggers.Handler{ // Implementa la clase handler
    // Clase creada a partir del antiguo trigger de oportunidades "informaCodigo"
    // Está clase rellena en el producto con los campos de la oportunidad "copyStageToProduct" y inserta el código de la Oportunidad

    public void handle(){ // Utiliza la clase auxiliar para secuenciar el trigger
        System.debug('El proceso devuelve: '+UtilAcc.needTriggerRun());
      
        if (!UtilAcc.needTriggerRun()){
            System.debug('El needTriggerRun no devuelve: ');
        } else {
            System.debug('El needTriggerRun ejecuta el metodo: ');
            
            opportunityUtil.copyStageToProduct((Map<id,opportunity>)Trigger.newMap,(Map<id,opportunity>)Trigger.OldMap);
            if(Trigger.isInsert){
                AQUA_Configuracion__c confActual;
                Integer contador;
                Integer anno = date.today().year() - 2000;
                string annoTxt = string.valueof(anno);
                confActual = [SELECT CON_TXT_Anio__c,CON_TXT_Contador__c FROM AQUA_Configuracion__c WHERE CON_TXT_Anio__c =: annoTxt LIMIT 1];
                contador = integer.valueof(confActual.CON_TXT_Contador__c);
                
                for(Opportunity a: (List<Opportunity>) Trigger.new){
                    contador++;
                    string contadorTxt = string.valueof(contador).leftpad(6, '0');
                    a.OPO_TXT_Codigo_Oportunidad__c = annoTxt + contadorTxt;
                    System.debug(a);
                    //Tambien copio los campos Dominio y Mercado - EN PROD NO ESTABA COMENTADO
                    /*if(a.OPO_SEL_Canal_Entrada__c == 'Concesión'){
                        Account cuentaRelacionada = [SELECT Id,COM_FOR_Dominio__c,COM_SEL_Mercado__c FROM Account WHERE Id =: a.AccountId];
                        a.OPO_TXT_Dominio_Compania__c = cuentaRelacionada.COM_FOR_Dominio__c;
                        a.OPO_TXT_Mercado_Compania__c = cuentaRelacionada.COM_SEL_Mercado__c;
                    }*/
                }

                System.debug('----- nextTXT' + string.valueof(contador).leftpad(6, '0'));
                confActual.CON_TXT_Contador__c = string.valueof(contador).leftpad(6, '0');
                System.debug('confActual'+confActual);
                upsert confActual;
                
            }
            if(Trigger.isUpdate ){
                
                Map<Id,Opportunity> oldOppMap = new Map<Id,Opportunity>((List<Opportunity>)Trigger.old); //Se crean estos mapas para luego poder operar con ellos sin problemas.
                Map<Id,Opportunity> newOppMap = new Map<Id,Opportunity>((List<Opportunity>)Trigger.new);
                
                //***************Start Everis 28/01 --- SES_bloqueada??
                Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Espana_Bloqueada').getRecordTypeId();
                //'OPO_Ganada' OR developerName = 'OPO_Perdida' OR developerName = 'OPO_Cancelda_cliente' OR developerName = 'OPO_Desestimada' OR developerName = 'OPO_Parking_Lot']);
                //***************Final Everis 28/01
                boolean modifica = false;
                if(userInfo.getProfileId() == Label.ADMINISTRADOR_PROFILE_ID_2 || userInfo.getProfileId() == Label.SYSTEM_ADMINISTRATOR_PROFILE_ID_18) modifica = true; 
                for(Opportunity a: (List<Opportunity>) Trigger.new){
                    if(a.OPO_SEL_Canal_Entrada__c == 'Concesión'){
                        Account cuentaRelacionada = [SELECT Id,COM_FOR_Dominio__c,COM_SEL_Mercado__c FROM Account WHERE Id =: a.AccountId];
                        a.OPO_TXT_Dominio_Compania__c = cuentaRelacionada.COM_FOR_Dominio__c;
                        a.OPO_TXT_Mercado_Compania__c = cuentaRelacionada.COM_SEL_Mercado__c;
                    }
                    
                    if(modifica == false && EstadoEjecucionChange(newOppMap.get(a.Id), oldOppMap.get(a.Id)) ){
                        System.debug('Estoy dentro del if');
                        if(oldOppMap.get(a.Id).OPO_NUM_NumActividades__c == newOppMap.get(a.Id).OPO_NUM_NumActividades__c ){                            
                            if(a.RecordTypeId == recordTypeId && a.StageName!='Oportunidad detectada'){ 
                                if(oldOppMap.get(a.Id).RecordTypeId == newOppMap.get(a.Id).RecordTypeId){
                                    if(!((a.StageName == 'Desestimada') && ((a.OPO_SEL_Canal_Entrada__c == 'Concesión') || (a.OPO_SEL_Canal_Entrada__c == 'Licitación pública')) )){
                                        system.debug('MARC-ANTES');
                                        system.debug(' a.StageName:'+a.StageName);
                                        system.debug(' newOppMap.get(a.Id).RecordTypeId:'+newOppMap.get(a.Id).RecordTypeId);
                                        system.debug(' oldOppMap.get(a.Id).RecordTypeId:'+oldOppMap.get(a.Id).RecordTypeId);
                                        system.debug(' newOppMap.get(a.Id).OPO_NUM_NumActividades__c:'+newOppMap.get(a.Id).OPO_NUM_NumActividades__c);
                                        system.debug(' oldOppMap.get(a.Id).OPO_NUM_NumActividades__c:'+oldOppMap.get(a.Id).OPO_NUM_NumActividades__c);
                                        system.debug(' oldOppMap.get(a.Id).RecordTypeId:'+oldOppMap.get(a.Id).RecordTypeId);
                                        system.debug(' oldOppMap.get(a.Id).RecordTypeId:'+oldOppMap.get(a.Id).RecordTypeId);
                                        a.addError(label.No_modificar_oportunidad);
                                    }
                                    system.debug('MARC-DESPUES');
                                }
                            }
                        }
                    }
                }
            }        
        }
    }  
        
    //Método que nos deja modificar el "Estado de Ejecución" , "Contratada" , "Oportunidad recurrente" aunque la Oportunidad este ganada
    public static boolean EstadoEjecucionChange(Opportunity oppNew, Opportunity oppOld){
        
        System.debug('Estoy en el metodo');
        System.debug('MARC-ERROROPPORTUNIDAD-oppNew.OPO_PKL_Estado_de_ejecucion__c: '+oppNew.OPO_PKL_Estado_de_ejecucion__c);
        System.debug('MARC-ERROROPPORTUNIDAD-oppNew.oppOld.OPO_PKL_Estado_de_ejecucion__c: '+oppOld.OPO_PKL_Estado_de_ejecucion__c);
        if(oppNew.OPO_PKL_Estado_de_ejecucion__c !=oppOld.OPO_PKL_Estado_de_ejecucion__c){
            System.debug('Estoy en el primer if');
            return false;
        }
        
        if((oppOld.OPO_CHK_Oportunidad_ganada_recientemente__c != oppNew.OPO_CHK_Oportunidad_ganada_recientemente__c)){
            System.debug('Estoy en el tercer if');
            return false;
        }
        if((oppOld.OPO_BOL_Oportunidad_Recurrente__c != oppNew.OPO_BOL_Oportunidad_Recurrente__c)){
            System.debug('Estoy en el cuarto if');
            return false;
        }
        if (productUtil.EnableOppModify==True){
            System.debug('El old '+Trigger.old);
            System.debug('El new '+Trigger.new);
            return false;
        }
        if((oppOld.OPO_LKP_Empresa_Adjudicataria__c != oppNew.OPO_LKP_Empresa_Adjudicataria__c)||(oppOld.OPO_NUM_ImporteEmpresaAdjudicataria__c != oppNew.OPO_NUM_ImporteEmpresaAdjudicataria__c)
        ||(oppOld.OPO_URL_link_de_la_licitaci_n__c != oppNew.OPO_URL_link_de_la_licitaci_n__c)||(oppOld.OPO_TXT_Codigo_DIR__c != oppNew.OPO_TXT_Codigo_DIR__c)){
            System.debug('Estoy en el quinto if');
            return false;
        }
        System.debug('El metodo devuelve ');
        return true;
    }
}