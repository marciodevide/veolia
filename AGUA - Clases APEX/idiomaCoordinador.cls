public class idiomaCoordinador implements Triggers.Handler{

    //Informa al campo auxiliar el idioma del coordinador BOS y del Creador de la petición
    public void handle(){
        list <string> ids = new list <string> ();             
        if(Trigger.isInsert){
            for (sObject petBOS:trigger.new) {
                if(UserInfo.getLanguage() != 'es') petBOS.put('BOS_SEL_Creador_Peticion_Idioma__c','English');
                else petBOS.put('BOS_SEL_Creador_Peticion_Idioma__c','Spanish');
            }
        }
        
        if(Trigger.isUpdate){
            for (sObject petBOS:trigger.new){
                if(petBOS.get('BOE_LKP_Coordinador_BOe__c')!=trigger.oldMap.get((Id)petBOS.get('Id')).get('BOE_LKP_Coordinador_BOe__c')) ids.add((String)petBOS.get('BOE_LKP_Coordinador_BOe__c'));         
                
                if((petBOS.get('BOE_SEL_Estado_BOe__c')=='Asignada')&&(petBOS.get('BOE_SEL_Estado_BOe__c'))!=trigger.oldMap.get((Id)petBOS.get('Id')).get('BOE_SEL_Estado_BOe__c')&&trigger.oldMap.get((Id)petBOS.get('Id')).get('BOE_SEL_Estado_BOe__c')=='Parada previa')petBOS.put('BOE_BOL_Parada_Previa_a_Asignada__c',TRUE);
                
                if((petBOS.get('BOE_SEL_Estado_BOe__c')!=trigger.oldMap.get((Id)petBOS.get('Id')).get('BOE_SEL_Estado_BOe__c'))&&trigger.oldMap.get((Id)petBOS.get('Id')).get('BOE_SEL_Estado_BOe__c')=='Asignada' && trigger.oldMap.get((Id)petBOS.get('Id')).get('BOE_BOL_Parada_Previa_a_Asignada__c') == FALSE )petBOS.put('BOS_Num_Contador_Respuesta_Coordinador__c',petBOS.get('FOR_Contador_Tiempo_de_Tratamiento__c'));//El contador sólo cuenta cuando el estado anterior de la petición es "Asignada"   
                
                if((petBOS.get('BOE_SEL_Estado_BOe__c')!=trigger.oldMap.get((Id)petBOS.get('Id')).get('BOE_SEL_Estado_BOe__c'))&&trigger.oldMap.get((Id)petBOS.get('Id')).get('BOE_SEL_Estado_BOe__c')=='Asignada'&&petBOS.get('Date_BOS_Fecha_fin_asignacion__c')==null){
                    //petBOS.put('BOS_Date_Fecha_inicio_asignacion__c',(DATE)petBOS.get('BOE_DAT_Fecha_asignacion_Coordinador__c'));
                    if(petBOS.get('BOE_SEL_Estado_BOe__c')=='Parada previa') petBOS.put('Date_BOS_Fecha_fin_asignacion__c',(DATE)petBOS.get('BOE_DAT_Inicio_Oferta_Parada__c'));
                    if(petBOS.get('BOE_SEL_Estado_BOe__c')=='GO / No GO') petBOS.put('Date_BOS_Fecha_fin_asignacion__c',(DATE)petBOS.get('BOE_DAT_Fecha_Inicio_Go__c'));
                    if(petBOS.get('BOE_SEL_Estado_BOe__c')=='En curso') petBOS.put('Date_BOS_Fecha_fin_asignacion__c',(DATE)petBOS.get('BOE_DAT_Fecha_Inicio_en_curso__c'));
                    if(petBOS.get('BOE_SEL_Estado_BOe__c')=='Petición anulada') petBOS.put('Date_BOS_Fecha_fin_asignacion__c',(DATE)petBOS.get('BOE_DAT_Fecha_de_Anulacion__c'));
                }
                if((petBOS.get('BOE_SEL_Estado_BOe__c')!=trigger.oldMap.get((Id)petBOS.get('Id')).get('BOE_SEL_Estado_BOe__c'))&&petBOS.get('BOE_SEL_Estado_BOe__c')=='Asignada'&&petBOS.get('Date_BOS_Fecha_fin_asignacion__c')!=null){
                    petBOS.put('Date_BOS_Fecha_fin_asignacion__c',null); 
                    if(trigger.oldMap.get((Id)petBOS.get('Id')).get('BOE_SEL_Estado_BOe__c')=='Parada previa') petBOS.put('BOS_Date_Fecha_inicio_asignacion__c',(DATE)petBOS.get('BOE_DAT_Fin_Oferta_Parada__c'));
                    if(trigger.oldMap.get((Id)petBOS.get('Id')).get('BOE_SEL_Estado_BOe__c')=='GO / No GO') petBOS.put('BOS_Date_Fecha_inicio_asignacion__c',(DATE)petBOS.get('BOE_DAT_Fecha_Fin_Go__c'));
                    if(trigger.oldMap.get((Id)petBOS.get('Id')).get('BOE_SEL_Estado_BOe__c')=='En curso') petBOS.put('BOS_Date_Fecha_inicio_asignacion__c',(DATE)petBOS.get('BOE_DAT_Fecha_Fin_en_curso__c'));
                    if(trigger.oldMap.get((Id)petBOS.get('Id')).get('BOE_SEL_Estado_BOe__c')=='Petición anulada') petBOS.put('BOS_Date_Fecha_inicio_asignacion__c',(DATE)petBOS.get('BOE_DAT_Fecha_de_Anulacion__c'));
                }
                if((petBOS.get('BOE_SEL_Estado_BOe__c')!=trigger.oldMap.get((Id)petBOS.get('Id')).get('BOE_SEL_Estado_BOe__c'))&&petBOS.get('BOE_SEL_Estado_BOe__c')=='Asignada'&&petBOS.get('BOS_Date_Fecha_inicio_asignacion__c')==null){
                    petBOS.put('BOS_Date_Fecha_inicio_asignacion__c',(DATE)petBOS.get('BOE_DAT_Fecha_asignacion_Coordinador__c'));
                }
            }
            map <Id,User> mapUser = new map <Id,User>([SELECT Id,LanguageLocaleKey FROM User WHERE Id IN: Ids]);
            for (SObject petBOS: trigger.new) {
                system.debug('petBos'+petBOS);
                system.debug('mapUser'+mapUser);
                if(petBOS.get('BOE_LKP_Coordinador_BOe__c') == null) continue;
                if(petBOS.get('BOE_LKP_Coordinador_BOe__c')==trigger.oldMap.get((Id)petBOS.get('Id')).get('BOE_LKP_Coordinador_BOe__c')) continue;           
                if(mapUser.get((Id)petBOS.get('BOE_LKP_Coordinador_BOe__c')).LanguageLocaleKey != 'es') petBOS.put('coordinador_BOS_Idioma__c','English');
                else petBOS.put('coordinador_BOS_Idioma__c','Spanish');   
            }
        }
    }
}