/***********************
Evolutivo: Petición BOS
Autor: Everis
Fecha creación: 25/04/2017

Incluye la lógica de los contadores BOS auxiliares
*****************************/
public class ContadorBOS implements Triggers.Handler{
    
    public boolean isChanged;
    public Map<String, CS_Contadores_BOS__c> contCSMap;
    
    public void handle(){
        /**************** Método creación petición BOS
        - Incluye la lógica de relación de la petición BOS con su contador BOS
        - Incluye valores iniciales necesarios del contador BOS relacionado
        ***************************************/
        if(Trigger.isInsert){
            List <Contador_BOS__c> createdContadorBOS = new List<Contador_BOS__c>();
            Map<String,Contador_BOS__c> mapContadorBOS = new Map<String,Contador_BOS__c>();
            List<AQUA_Peticion_BOe__c> listPetBOS= trigger.new;
            Map<String,Contador_BOS__c> mapContadorBOSOpProd = new Map<String,Contador_BOS__c>();
            List<Id> listProdOpIds= new List<Id>();

            for(AQUA_Peticion_BOe__c petBOS:listPetBOS) listProdOpIds.add(petBOS.BOE_LKP_Producto_de_oportunidad__c);

            List<Oportunidad_Producto__c> listProdOp = [SELECT Id,OP_LKP_Contador_BOS__c FROM Oportunidad_Producto__c WHERE Id IN: listProdOpIds];
            List<Oportunidad_Producto__c> listProdOpToUpdate = new List<Oportunidad_Producto__c>();
            Contador_BOS__c contBOS;
            // Recorro las peticiones BOS creadas para crear su registro Contador BOS correspondiente
            for(AQUA_Peticion_BOe__c petBOS:listPetBOS){
                contBOS = new Contador_BOS__c();
                contBOS.Name = petBOS.Name;
                contBOS.CBOS_LKP_Prod_Oport__c = petBOS.BOE_LKP_Producto_de_oportunidad__c;//Asocio el contador BOS al prod de la oport asociado. Para los contadores Muertos.
                if(petBOS.BOE_DAT_Fecha_Creacion__c!=null) contBOS.Date_CBOS_Inicio_creacion_peticion__c= petBOS.BOE_DAT_Fecha_Creacion__c;
                else contBOS.Date_CBOS_Inicio_creacion_peticion__c= system.today();
                contBOS.CBOS_PKL_Status_Aux__c = petBOS.BOE_SEL_Estado_BOe__c;
                createdContadorBOS.add(contBOS);
                mapContadorBOS.put(contBOS.Name,contBOS);
                mapContadorBOSOpProd.put(contBOS.CBOS_LKP_Prod_Oport__c,contBOS);
            }
            
            // Inserto contadores BOS
            try{
                if(createdContadorBOS!=null&&createdContadorBOS.size()>0) insert createdContadorBOS;
                // Relaciono la Peticion BOS con su correspondiente contador BOS
                for(AQUA_Peticion_BOe__c petBOS:listPetBOS){
                    petBOS.BOS_lkp_Contador_BOS__c = mapContadorBOS.get(petBOS.Name).Id; // Confirmar que el ID no es null aunque no se recupere en query y que lo guarda bien el mapa y q el mapa no es null
                }
                // Recorro los productos de la oportunidad asociados a las peticiones BOS creadas para asociarlos con su registro Contador BOS correspondiente
                for(Oportunidad_Producto__c opProd:listProdOp){
                    opProd.OP_LKP_Contador_BOS__c = mapContadorBOSOpProd.get(opProd.Id).Id;
                    listProdOpToUpdate.add(opProd);
                }
                update listProdOpToUpdate;
            }catch(DmlException e){
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }
        
        /**************** Método update de petición BOS
        - Incluye la lógica de todos los contadores actuales de petición BOS
        - La lógica de relleno de los contadores será siempre la misma.
            + Fecha iniciales del contador
            + Estado del contador actual (común a todos)
            + Campo numérico auxiliar que guarda el histórico del contador cuando se cierra
            + CONTADOR FINAL: Campo fórmula que guarda el valor del contador actual (si está en el status abierto utilizará la fecha actual - fecha inicial + histórico y si en el status cerrado utilizará el histórico únicamente)
        - La diferencia según contador será los campos que se rellenen (3 campos + el de status)
        ***************************************/
        // Entra en el update si hay un cambio en el "Estado" de la petición BOS
        if(Trigger.isUpdate){
            contCSMap = CS_Contadores_BOS__c.getAll();
            Map<Id,Id> petBOSCambioContador = new Map<Id,Id>();
            List<AQUA_Peticion_BOe__c> listPetBOS= trigger.newMap.values();
            List<Contador_BOS__c> cBOSToUpdate = new List<Contador_BOS__c>();
            string estadoNuevo;
            string estadoAntiguo;
            // Recorro las peticiones BOE
            for(AQUA_Peticion_BOe__c petBOS:listPetBOS){
                if(petBOS.BOS_lkp_Contador_BOS__c!=null) petBOSCambioContador.put(petBOS.BOS_lkp_Contador_BOS__c,petBOS.Id); // Relación entre contador BOS y petición BOS
            }
            //Recupero los contadores BOS asociados si existen cambios en estado BOS
            if(petBOSCambioContador!=null&&petBOSCambioContador.size()>0){
                /******************* INICIO LOGICA QUERY **********************************/
                // Indico los campos a recuperar en la query
                String query = 'SELECT ';
                Map <String, Schema.SObjectField> fieldMap = Schema.SObjectType.Contador_BOS__c.fields.getMap();
                Set<Id> listQuery = new Set<Id>();
                listQuery=petBOSCambioContador.keySet();
                
                for(Schema.SObjectField sOb:fieldMap.Values()){
                    if(query=='SELECT ') query+= String.ValueOf(sOb);
                    else query+= ','+String.ValueOf(sOb);
                }
                query+=' FROM Contador_BOS__c WHERE Id IN:listQuery'; // Comprobar que el IN: del key set funciona correctamente
                //Realizo la query
                List<Contador_BOS__c> listCont=new List<Contador_BOS__c>(); 
                listCont=Database.query(query);
                /******************** FIN LOGICA QUERY ****************************/
                     
                // Recorro los contadores BOS asociados
                for(Contador_BOS__c cBOS: listCont){
                    isChanged = false;
                    /************* Logica de contadores
                    Cada contador va a depender del estado y de los campos fecha de los que depende (incluirlos en los if)
                    ****************************/
                    /***************** Comprobar de forma empírica que utiliza el API name ****************************/
                    estadoNuevo = string.valueOf(trigger.newMap.get(petBOSCambioContador.get(cBOS.Id)).get('BOE_SEL_Estado_BOe__c'));
                    estadoAntiguo = string.valueOf(trigger.oldMap.get(petBOSCambioContador.get(cBOS.Id)).get('BOE_SEL_Estado_BOe__c'));
                    if(estadoNuevo!=estadoAntiguo){
                        cBOS.CBOS_PKL_Status_Aux__c = estadoNuevo;
                        isChanged=true;
                        List<CS_Contadores_BOS__c> listaCSAntiguo = new List<CS_Contadores_BOS__c>();
                        for(string key:contCSMap.keyset()){
                            if(key.equalsIgnoreCase(estadoAntiguo)) listaCSAntiguo.add(contCSMap.get(key));
                        }
                        List<CS_Contadores_BOS__c> listaCSNuevo = new List<CS_Contadores_BOS__c>();
                        for(string key:contCSMap.keyset()){
                            if(key.equalsIgnoreCase(estadoNuevo)) listaCSNuevo.add(contCSMap.get(key));
                        }                       
                        for(CS_Contadores_BOS__c csContAntiguo:listaCSAntiguo){
                            cBOS=cambioEstadoAntiguo(cBOS, petBOSCambioContador.get(cBOS.Id), csContAntiguo);
                        }
                        for(CS_Contadores_BOS__c csContNuevo:listaCSNuevo){
                            cBOS=cambioEstadoNuevo(cBOS, petBOSCambioContador.get(cBOS.Id), csContNuevo);
                        }
                    }
                        
                    /************************ Lógica implementada para el cambio de fechas que afectan a contadores **************************/
                    try{
                        if(petBOSCambioContador.get(cBOS.Id)!=null) cBOS = cambioFechas(cBOS,petBOSCambioContador.get(cBOS.Id)); // Pasamos por parámetro el ID de la petición BOS actual y el contador
                    }catch(Exception e){
                        System.debug('The following exception has occurred: ' + e.getMessage());
                        trigger.newMap.get(petBOSCambioContador.get(cBOS.Id)).addError(Label.Error_Cambio_Fechas);
                    }
                    /*********************** Fin lógica implementada para el cambio de fechas que afectan a contadores ***********************/
                    
                    /************************* Lógica para contadores de producto de la oportunidad *******************************************/
                    if(petBOSCambioContador.get(cBOS.Id)!=null) cBOS = contadoresOppProduct(cBOS,petBOSCambioContador.get(cBOS.Id));
                    /*********************** Fin lógica para contadores de producto de la oportunidad ******************************************/
                
                    /********************** INICIO update del contador BOS **************************/
                    // Si ha habido un update añado a la lista
                    if(isChanged=true) cBOSToUpdate.add(cBOS);
                }
               // Updateo contadores BOS
                try{
                    if(cBOSToUpdate!=null&&cBOSToUpdate.size()>0) update cBOSToUpdate;
                }catch(DmlException e){
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
                /********************** FIN update del contador BOS **************************/
            }
        }
    }

    public Contador_BOS__c cambioEstadoAntiguo(Contador_BOS__c contBOS, Id petBOSId, CS_Contadores_BOS__c cs){
        //Actualizo campos relacionados al contador del estado anterior
        System.debug('Contador actual: '+cs);
        contBOS.put(cs.ContBOS_Fecha_Inicio__c,(Date)Trigger.newMap.get(petBOSId).get(cs.PetBOS_Fecha_Inicio__c));
        if(Trigger.newMap.get(petBOSId).get(cs.Pet_BOS_Fecha_Fin__c)!=null) contBOS.put(cs.ContBOS_Historico__c,Integer.ValueOf(contBOS.get(cs.ContBOS_Historico__c))+1+(((Date)Trigger.newMap.get(petBOSId).get(cs.PetBOS_Fecha_Inicio__c)).daysBetween((Date)Trigger.newMap.get(petBOSId).get(cs.Pet_BOS_Fecha_Fin__c))));
        
        return contBOS;
    }
    
    public Contador_BOS__c cambioEstadoNuevo(Contador_BOS__c contBOS, Id petBOSId, CS_Contadores_BOS__c cs){    
        //Inicio el nuevo contador
        contBOS.put(cs.ContBOS_Fecha_Inicio__c,(Date)Trigger.newMap.get(petBOSId).get(cs.PetBOS_Fecha_Inicio__c));
        return contBOS;
    }
    
    /******************* Lógica para indicar las fechas que han cambiado de la petición BOS ***************************/
    public Contador_BOS__c cambioFechas(Contador_BOS__c contBOSParam,Id petBOSIDParam){
        ID petBOSID = petBOSIDParam;
        Contador_BOS__c cBOS = contBOSParam;
        boolean isAlreadyHistoricoChanged = false;
        // Recorro las fechas de petición BOS que recojo de la custom setting y compruebo si han cambiado
        for(CS_Contadores_BOS__c cs:contCSMap.Values()){
            // Cambio fecha inicio
            isAlreadyHistoricoChanged = false;
            // Una manera de comprobar esto es que la lógica de los if que tengo aquí debe ser justo la contraria de la que ha hecho lucía en su código
            if(trigger.newMap.get(petBOSID).get(cs.PetBOS_Fecha_Inicio__c)!=trigger.oldMap.get(petBOSID).get(cs.PetBOS_Fecha_Inicio__c)){
                // Cambio del histórico. Únicamete se va a tratar aquí que el cambio no es debido a un cambio en el estado de la petición BOS sino a un cambio en las fechas. 
                // Esto se traduce a que ejecutamos la lógica de recálculo de histórico si el estado es no es el estado activo del contador (esta lógica se trata en el método cambio de estado)
                System.debug('estado actual: '+trigger.newMap.get(petBOSID).get('BOE_SEL_Estado_BOe__c'));
                System.debug('estado antiguo: '+trigger.oldMap.get(petBOSID).get('BOE_SEL_Estado_BOe__c'));
                System.debug('estado cs: '+cs.Name);
                if(string.valueOf(trigger.newMap.get(petBOSID).get('BOE_SEL_Estado_BOe__c'))==string.valueOf(trigger.oldMap.get(petBOSID).get('BOE_SEL_Estado_BOe__c'))||(!cs.Name.equalsIgnoreCase(((String)trigger.newMap.get(petBOSID).get('BOE_SEL_Estado_BOe__c')))&&!cs.Name.equalsIgnoreCase(((String)trigger.oldMap.get(petBOSID).get('BOE_SEL_Estado_BOe__c'))))){
                    cBOS.put(cs.ContBOS_Fecha_Inicio__c,(Date)trigger.newMap.get(petBOSID).get(cs.PetBOS_Fecha_Inicio__c)); //Cambio la fecha de inicio relacionada
                    if((!cs.Name.equalsIgnoreCase(((String)trigger.newMap.get(petBOSID).get('BOE_SEL_Estado_BOe__c')))&&!cs.Name.equalsIgnoreCase(((String)trigger.oldMap.get(petBOSID).get('BOE_SEL_Estado_BOe__c'))))){
                        cBOS.put(cs.ContBOS_Historico__c,Integer.ValueOf(cBOS.get(cs.ContBOS_Historico__c))-(1+((date)trigger.oldMap.get(petBOSID).get(cs.PetBOS_Fecha_Inicio__c)).daysBetween((Date)trigger.oldMap.get(petBOSID).get(cs.Pet_BOS_Fecha_Fin__c)))); // Resto el valor antiguo del contador
                        cBOS.put(cs.ContBOS_Historico__c,Integer.ValueOf(cBOS.get(cs.ContBOS_Historico__c))+(1+((date)trigger.newMap.get(petBOSID).get(cs.PetBOS_Fecha_Inicio__c)).daysBetween((Date)trigger.newMap.get(petBOSID).get(cs.Pet_BOS_Fecha_Fin__c)))); // Sumo el valor actual del contador
                        isAlreadyHistoricoChanged = true; // No debe volverse a recalcular el histórico
                    }
                    isChanged = true;// Lógica para indicar que se ha cambiado el contador y debe añadirse a la lista
                }           
            }
            //Cambio fecha fin
            if(trigger.newMap.get(petBOSID).get(cs.Pet_BOS_Fecha_Fin__c)!=trigger.oldMap.get(petBOSID).get(cs.Pet_BOS_Fecha_Fin__c)){
                // Cambio del histórico. Únicamete se va a tratar aquí que el cambio no es debido a un cambio en el estado de la petición BOS sino a un cambio en las fechas. 
                // Esto se traduce a que ejecutamos la lógica de recálculo de histórico si el estado antiguo no es el estado activo del contador (esta lógica se trata en el método cambio de estado)
                if((!cs.Name.equalsIgnoreCase(((String)trigger.oldMap.get(petBOSID).get('BOE_SEL_Estado_BOe__c')))&&!cs.Name.equalsIgnoreCase(((String)trigger.newMap.get(petBOSID).get('BOE_SEL_Estado_BOe__c'))))){
                    //cBOS.put(cs.Pet_BOS_Fecha_Fin__c,(Date)trigger.newMap.get(petBOSID).get(cs.Pet_BOS_Fecha_Fin__c)); //Cambio la fecha de fin relacionada
                    if(!isAlreadyHistoricoChanged){
                        cBOS.put(cs.ContBOS_Historico__c,Integer.ValueOf(cBOS.get(cs.ContBOS_Historico__c))-(1+((date)trigger.oldMap.get(petBOSID).get(cs.PetBOS_Fecha_Inicio__c)).daysBetween((Date)trigger.oldMap.get(petBOSID).get(cs.Pet_BOS_Fecha_Fin__c)))); // Resto el valor antiguo del contador
                        cBOS.put(cs.ContBOS_Historico__c,Integer.ValueOf(cBOS.get(cs.ContBOS_Historico__c))+(1+((date)trigger.newMap.get(petBOSID).get(cs.PetBOS_Fecha_Inicio__c)).daysBetween((Date)trigger.newMap.get(petBOSID).get(cs.Pet_BOS_Fecha_Fin__c)))); // Sumo el valor actual del contador
                        isChanged=true;// Lógica para indicar que se ha cambiado el contador y debe añadirse a la lista
                    }
                }   
            }
        }

        return cBOS; // Devuelvo el nuevo contador BOS asociado
    }
    
    /************************************ Lógica para implementar los contadores de Producto de la oportunidad *************************************/
    public Contador_BOS__c contadoresOppProduct(Contador_BOS__c contBOSParam,Id petBOSIDParam){
        ID petBOSID = petBOSIDParam;
        Contador_BOS__c cBOS = contBOSParam;
        // Fecha de inicio de en curso
        if(trigger.newMap.get(petBOSID).get('BOE_DAT_Fecha_Inicio_en_curso__c')!=trigger.oldMap.get(petBOSID).get('BOE_DAT_Fecha_Inicio_en_curso__c')) {
            isChanged=true;
            cBOS.CBOS_Date_Ini_Periodo_Tiempo_Curso__c = (Date)trigger.newMap.get(petBOSID).get('BOE_DAT_Fecha_Inicio_en_curso__c');
        }
        // Fecha de fin en curso
        if(trigger.newMap.get(petBOSID).get('BOE_DAT_Fecha_Fin_en_curso__c')!=trigger.oldMap.get(petBOSID).get('BOE_DAT_Fecha_Fin_en_curso__c')) {
            isChanged=true;
            cBOS.CBOS_DATE_Fecha_de_fin_en_curso__c = (Date)trigger.newMap.get(petBOSID).get('BOE_DAT_Fecha_Fin_en_curso__c');
        }
        // Fecha de cancelación
        if(trigger.newMap.get(petBOSID).get('BOE_DAT_Fecha_de_Anulacion__c')!=trigger.oldMap.get(petBOSID).get('BOE_DAT_Fecha_de_Anulacion__c')) {
            isChanged=true;
            cBOS.CBOS_Date_Fecha_de_anulacion__c = (Date)trigger.newMap.get(petBOSID).get('BOE_DAT_Fecha_de_Anulacion__c');
        }
        // Fecha de finalización
        if(trigger.newMap.get(petBOSID).get('BOE_DAT_Fecha_de_recepcion_de_oferta__c')!=trigger.oldMap.get(petBOSID).get('BOE_DAT_Fecha_de_recepcion_de_oferta__c')) {
            isChanged=true;
            cBOS.CBOS_Date_Fecha_de_finalizacion__c = (Date)trigger.newMap.get(petBOSID).get('BOE_DAT_Fecha_de_recepcion_de_oferta__c');
        }

        return cBOS;
    }
}