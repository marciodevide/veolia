public class OpportunityTriggerHelper {
	public void opportunityWorkFlowRules(List<Opportunity> oldMap, List<Opportunity> newMap){      
        for (Opportunity opp :newMap){
            // Fecha de creación
            
            // Origen peticion oportunidad
            opp.OCUL_BOOL_OrigenPeticion__c = true;
            // AprobarIncompatible
            //if(opp.OPO_SEL_Estado_Proceso__c=='En aprobación' && opp.OPO_NUM_Contador_Steps__c>0){opp.OPO_NUM_Contador_Steps__c=opp.OPO_NUM_Contador_Steps__c+1;}
            system.debug('MARC-2: '+opp.OPO_NUM_Contador_Steps__c);
            // Update Nota No Necesaria
            system.debug('MARC-: '+oldMap);
            if(oldMap!=null){
                system.debug('MARC-:opp.OPO_SEL_Estado_Proceso__c '+opp.OPO_SEL_Estado_Proceso__c);
                if(opp.OPO_SEL_Estado_Proceso__c!=oldMap.get(newMap.indexOf(opp)).OPO_SEL_Estado_Proceso__c && opp.OPO_SEL_Estado_Proceso__c=='No necesaria'){
                    system.debug('MARC-:OPO_BOL_NotaNecesaria__c '+opp.OPO_BOL_NotaNecesaria__c);
                    opp.OPO_BOL_NotaNecesaria__c = false;
                }
            }
            // Fechas Cierre
            if(opp.LastModifiedById==Label.ADMIN_USER_SAP_ID && 
               (opp.StageName == 'Perdida' || opp.StageName=='Desestimada' || opp.StageName== 'Cancelada cliente')){
                opp.OPO_DAT_Fecha_Cierre__c=date.today();
            }
            // OPO_WF_Actualiza_F_ultimo_cambio_de_estado
            if(oldMap!=null){
                if(opp.StageName!=oldMap.get(newMap.indexOf(opp)).StageName){opp.OPO_DAT_F_ultimo_cambio_de_estado__c = date.today();}
                
                // Reinicio Nota aprobacion
                // AND(ISCHANGED(StageName), ISPICKVAL(PRIORVALUE(StageName),'Oferta presentada a cliente'), ISPICKVAL(StageName, 'En elaboración oferta'))
                if(opp.StageName!=oldMap.get(newMap.indexOf(opp)).StageName && oldMap.get(newMap.indexOf(opp)).StageName=='Oferta presentada a cliente' && opp.StageName == 'En elaboración oferta'){
                    opp.OPO_BOL_OK_ECOFIN__c = false;
                    opp.OPO_BOL_OK_Lider__c = false;
                    opp.OPO_BOL_Tecnico_SSJJ__c = false;
                    opp.OPO_BOL_Nota_aprobada__c = false;
                }
                // EnElaboracionOferta
                // AND(ISCHANGED([Opportunity].StageName ), ISPICKVAL([Opportunity].StageName, 'En elaboración oferta'))
                if(opp.StageName!=oldMap.get(newMap.indexOf(opp)).StageName && opp.StageName == 'En elaboración oferta'){
                    
                }
            }
        }
    }
    public void opportunityCreateWorkFlowRules(List< Opportunity> newMap){      
        for (Opportunity opp :newMap){
            opp.OPO_DAT_Fecha_Creacion__c = Date.Today();
            // Estado Borrador
            if(opp.LastModifiedBy.Id!=label.ADMIN_USER_SAP_ID2 && opp.OPO_LKP_Sociedad_Ofertante__c==null){opp.OPO_SEL_Estado_SAP__c = 'Borrador';}
            // Vía de pago por defecto
            if(opp.LastModifiedBy.Id==label.ADMIN_USER_SAP_ID2){opp.OPO_SEL_Via_Pago__c = 'Otras';}
        }
    }
    //En objeto OPORTUNIDAD tenemos 2 campos existente de Adjudicatarios
	//Son obligatorios cuando se pasa la situación a PERDIDA para informar de la empresa de la competencia quien ha ganado y con que importe.
	//Cuando la situación es GANADA, o sea ganamos nosotros, no son obligatorios

	//Nos piden, (si es posible) de que cuando se pase la oportunidad a Ganada esos campos se rellenen automáticamente con :
	//- Empresa Adjudicataria OPO_LKP_Empresa_Adjudicataria__c=> Si la Sociedad ofertante de la oportunidad es GESTIÓN DE UTE, 
	// entonces poner el valor del campo NOMBRE UTE, sino valor del campo sociedad ofertante de la oportunidad
	//- Importe Empresa Adjudicataria OPO_NUM_ImporteEmpresaAdjudicataria__c=> Volumen total

	//Habría que realizar una carga del histórico sobre las GANADAS
	//En situación Perdida se queda como esta
    public void actualizarDatosEmpresaAdjudicataria(List<Opportunity> oldList, List<Opportunity> newList){
        for(Opportunity opp : newList){
            if(opp.StageName!=oldList.get(newList.indexOf(opp)).StageName && opp.StageName=='Ganada'){
                if(opp.OPO_For_Sociedad_ofertante_name__c=='GESTIÓN DE UTE' || opp.OPO_For_Sociedad_ofertante_name__c=='GESTIÓN DE COLABORACIÓN'){
                    opp.OPO_LKP_Empresa_Adjudicataria__c = opp.OPO_LKP_Sociedad_Ofertante__c;
                    opp.OPO_NUM_ImporteEmpresaAdjudicataria__c = opp.OPO_NUM_Importe_total_ofertado__c;
                }else{
                    opp.OPO_LKP_Empresa_Adjudicataria__c = opp.OPO_LKP_Sociedad_Ofertante__c;
                    opp.OPO_NUM_ImporteEmpresaAdjudicataria__c = opp.OPO_CUR_Volumen_Total__c;
                }
            }
        }
    }
}