public class UtilidadesAdminController {
    // Definimos variables
    public Date fechaRevisar {get;set;}
    public String respuesta {get;set;}
    
    //Definimos metodos
    //
    //
    //Este metodo recoge todas las oportunidades creadas o modificadas por Admin Sap durante el dia actual y en
    //caso de que algun campo fecha coincida con el dia de hoy lo modifica por la fecha introducida en la visualForce.
    public void revisarFechas(){
        UtilAcc.runOnce();
        try{
            List<Opportunity> oportunidadesSap = [SELECT id,OPO_DAT_Fecha_Presentacion_Oferta__c,OPO_DAT_Fecha_Inicio_Proyecto__c,
                                                  OPO_DAT_Fecha_Adjudicacion__c,
                                                  OPO_DAT_Fecha_Fin_Proyecto__c,COM_DATE_Limite_entrega_N_A__c,OPO_DAT_Fecha_Cierre__c
                                                  FROM Opportunity WHERE (CreatedBy.name = 'admin sap' OR LastModifiedBy.name = 'admin sap')
                                                  AND (LastModifiedDate = today OR CreatedDate = today )];
            Map<String, Schema.SobjectField> fields = //Generamos el mapa con los campos de oportunidad
            oportunidadesSap.getSObjectType().getDescribe().fields.getMap();
            for (SObject oportunidad: oportunidadesSap){ //Iteramos sobre las oportunidades
                for (Schema.SobjectField nombreCampo:fields.values()){ //Iteramos sobre los fields de opportunity
                    try{                    
                        if(String.valueOf(nombreCampo.getDescribe().getType()) == 'Date' &&//Si el campo es de tipo date
                            oportunidad.get(nombreCampo) == system.today()){// Y la fecha es hoy
                            oportunidad.put(nombreCampo.getDescribe().getSObjectField(),fechaRevisar);//Modificamos el valor del campo
                        }
                    } catch(Exception e){
                        System.debug('Ha ocurrido el siguiente error: '+e);
                        continue;
                    }
                }
            }
            update oportunidadesSap;
            respuesta = 'Se ha revisado correctamente';
        } catch(Exception e){
            System.debug('Se ha registrado un error: '+e);
            respuesta = 'Ha ocurrido un error inesperado';
        }
    }
    
    /*public void borrarTerritorioUserDupli(){//Elimina los territorio USER
        territory parent;
        String nombre;
        map<Id,territory> mapaTerritorios = new map<Id,territory>([select id, name, parentTerritoryId from Territory]);
        System.debug(mapaTerritorios);
        traspasaUsuarios(mapaTerritorios);
        for (territory t :mapaTerritorios.values()){
            parent = mapaTerritorios.get(t.parentTerritoryId);
            try{
                nombre = parent.name;
                system.debug(nombre);
            if(nombre.contains('USER')){
                //system.debug('Estoy en: '+t.Name+' su parant es :'+parent.Name+'Y el parent de su parent es: '+ mapaTerritorios.get(parent.parentTerritoryId).name);
            }
            }
            catch (Exception e){
                
            }
        }
    }
    
    public void traspasaUsuarios(map<Id,territory> mapaTerritorios){
        map<Id,Userterritory> mapUT = new map<Id,Userterritory>();
        for(Userterritory uT :[select TerritoryId,UserId from UserTerritory where TerritoryId in (select id from Territory where name like '%USER%' ) limit 1 offset 10]){
            mapUT.put(uT.TerritoryId,uT);
        }
        List<Userterritory> listUT = new List<Userterritory>();
        id pId;
        for (territory territorio : mapaTerritorios.values()){
            if (mapUT.containsKey(territorio.parentTerritoryId)){
                Userterritory uTtoInsert = new Userterritory();
                uTtoInsert.UserId = mapUT.get(territorio.parentTerritoryId).UserId;
            	uTtoInsert.TerritoryId = territorio.id;
            	listUT.add(uTtoInsert);
                
            }
        }
        Map<String, Object> params = new Map<String, Object>();
        System.debug('el contenido a insertar es: '+listUT);
        params.put('UserTerritoryInsert', listUT);
        Flow.Interview.Asigna_UserTerritory flowTerritory = new Flow.Interview.Asigna_UserTerritory(params);
        flowTerritory.start();
    }*/
}