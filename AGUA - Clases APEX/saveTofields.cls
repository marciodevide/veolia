public class saveTofields implements Triggers.Handler{ // Implementa la clase handler
    
    public void handle(){ // Utiliza la clase auxiliar para secuenciar el trigger
        String changedFieldSet;         
        // Clase creada a partir del antiguo trigger de cuentas "saveTofields"      
        //System.debug('Trigger saveToField----');
        for(Account a : (List<Account>) Trigger.new) {
            if ((UserInfo.getUserId() != Label.ADMIN_USER_SAP_ID) && (a.COM_SEL_Estado__c != '') && (a.COM_SEL_Estado__c != null) && (a.COM_SEL_Estado__c != Label.Estado_Borrador_SAP)) {
                if(a.Campos_pendiente_de_envio_SAP__c != null && a.Campos_pendiente_de_envio_SAP__c != '') changedFieldSet = a.Campos_pendiente_de_envio_SAP__c;
                else changedFieldSet = '';
                System.debug(a.Nombre_2__c);
                System.debug(Trigger.oldMap.get(a.Id).get('Nombre_2__c'));
                System.debug(changedFieldSet);
                
                if(a.Nombre_2__c != Trigger.oldMap.get(a.Id).get('Nombre_2__c') && !changedFieldSet.contains('Nombre_2__c')){
                    System.debug('FLOW 1');
                    if(changedFieldSet.length()>1) changedFieldSet = changedFieldSet+',';
                    changedFieldSet = changedFieldSet + 'Nombre_2__c';
                }
                if(a.COM_TXT_Domicilio__c != Trigger.oldMap.get(a.Id).get('COM_TXT_Domicilio__c') && !changedFieldSet.contains('COM_TXT_Domicilio__c')){
                    System.debug('FLOW 2');
                    if(changedFieldSet.length()>1) changedFieldSet = changedFieldSet+',';
                    changedFieldSet = changedFieldSet + 'COM_TXT_Domicilio__c';
                }
                if(a.COM_TXT_Calle_2__c != Trigger.oldMap.get(a.Id).get('COM_TXT_Calle_2__c') && !changedFieldSet.contains('COM_TXT_Calle_2__c')){
                    System.debug('FLOW 3');
                    if(changedFieldSet.length()>1) changedFieldSet = changedFieldSet+',';
                    changedFieldSet = changedFieldSet +  'COM_TXT_Calle_2__c';
                }
                if(a.COM_LKP_Municipio__c != Trigger.oldMap.get(a.Id).get('COM_LKP_Municipio__c') && !changedFieldSet.contains('COM_LKP_Municipio__c')) {
                    System.debug('FLOW 4');
                    if(changedFieldSet.length()>1) changedFieldSet = changedFieldSet+',';
                    changedFieldSet = changedFieldSet + 'COM_LKP_Municipio__c';
                }
                if(a.COM_FOR_Provincia__c != Trigger.oldMap.get(a.Id).get('COM_FOR_Provincia__c') && !changedFieldSet.contains('COM_FOR_Provincia__c')){
                    System.debug('FLOW 5');
                    if(changedFieldSet.length()>1) changedFieldSet = changedFieldSet+',';
                    changedFieldSet = changedFieldSet +  'COM_FOR_Provincia__c';
                }
                if(a.COM_LKP_Pais__c != Trigger.oldMap.get(a.Id).get('COM_LKP_Pais__c') && !changedFieldSet.contains('COM_LKP_Pais__c')){
                    System.debug('FLOW 6');
                    if(changedFieldSet.length()>1) changedFieldSet = changedFieldSet+',';
                    changedFieldSet = changedFieldSet + 'COM_LKP_Pais__c';
                }
                if(a.COM_TXT_Codigo_Postal__c != Trigger.oldMap.get(a.Id).get('COM_TXT_Codigo_Postal__c') && !changedFieldSet.contains('COM_TXT_Codigo_Postal__c')) {
                    System.debug('FLOW 7');
                    if(changedFieldSet.length()>1) changedFieldSet = changedFieldSet+',';
                    changedFieldSet = changedFieldSet + 'COM_TXT_Codigo_Postal__c';
                }
                if(a.COM_FOR_Divisa__c != Trigger.oldMap.get(a.Id).get('COM_FOR_Divisa__c') && !changedFieldSet.contains('COM_FOR_Divisa__c')) {
                    System.debug('FLOW 8');
                    if(changedFieldSet.length()>1) changedFieldSet = changedFieldSet+',';
                    changedFieldSet = changedFieldSet + 'COM_FOR_Divisa__c';
                }
                if(a.COM_FOR_NIF_CIF__c != Trigger.oldMap.get(a.Id).get('COM_FOR_NIF_CIF__c') && !changedFieldSet.contains('COM_FOR_NIF_CIF__c')) {
                    System.debug('FLOW 9');
                    if(changedFieldSet.length()>1) changedFieldSet = changedFieldSet+',';
                    changedFieldSet = changedFieldSet + 'COM_FOR_NIF_CIF__c';
                }
                if(a.COM_SEL_Ramo__c != Trigger.oldMap.get(a.Id).get('COM_SEL_Ramo__c') && !changedFieldSet.contains('COM_FOR_Ramo__c')){
                    System.debug('FLOW 10');
                    if(changedFieldSet.length()>1) changedFieldSet = changedFieldSet+',';
                    changedFieldSet = changedFieldSet + 'COM_FOR_Ramo__c';
                }
                if(a.COM_FOR_Codigo_ramo1__c != Trigger.oldMap.get(a.Id).get('COM_FOR_Codigo_ramo1__c') && !changedFieldSet.contains('COM_FOR_Codigo_ramo1__c')){
                    System.debug('FLOW 11');
                    if(changedFieldSet.length()>1) changedFieldSet = changedFieldSet+',';
                    changedFieldSet = changedFieldSet + 'COM_FOR_Codigo_ramo1__c';
                }
                if(a.phone!= Trigger.oldMap.get(a.Id).get('phone') && !changedFieldSet.contains('phone')){
                    System.debug('FLOW 12');
                    if(changedFieldSet.length()>1) changedFieldSet = changedFieldSet+',';
                    changedFieldSet = changedFieldSet + 'phone';
                }
                if(a.fax != Trigger.oldMap.get(a.Id).get('fax') && !changedFieldSet.contains('fax')){
                    System.debug('FLOW 13');
                    if(changedFieldSet.length()>1) changedFieldSet = changedFieldSet+',';
                    changedFieldSet = changedFieldSet + 'fax';  
                }
                if(a.COM_TXT_Correo_electronico__c != Trigger.oldMap.get(a.Id).get('COM_TXT_Correo_electronico__c') && !changedFieldSet.contains('COM_TXT_Correo_electronico__c')) {
                    System.debug('FLOW 14');
                    if(changedFieldSet.length()>1) changedFieldSet = changedFieldSet+',';
                    changedFieldSet = changedFieldSet + 'COM_TXT_Correo_electronico__c';
                }
                if(a.Sociedad_Ofertante__c != Trigger.oldMap.get(a.Id).get('Sociedad_Ofertante__c') && !changedFieldSet.contains('Sociedad_Ofertante__c')) {
                    System.debug('FLOW 16');
                    if(changedFieldSet.length()>1) changedFieldSet = changedFieldSet+',';
                    changedFieldSet = changedFieldSet + 'Sociedad_Ofertante__c';
                }
                if(a.COM_TXT_Solicitud_Modificacion__c != Trigger.oldMap.get(a.Id).get('COM_TXT_Solicitud_Modificacion__c') &&  !changedFieldSet.contains('COM_TXT_Solicitud_Modificacion__c')) {
                    System.debug('FLOW 19');
                    if(changedFieldSet.length()>1) changedFieldSet = changedFieldSet+',';
                    changedFieldSet = changedFieldSet + 'COM_TXT_Solicitud_Modificacion__c';
                }
                if(a.COM_FOR_Codigo_via_pago__c != Trigger.oldMap.get(a.Id).get('COM_FOR_Codigo_via_pago__c') && !changedFieldSet.contains('COM_FOR_Codigo_via_pago__c')) {
                    System.debug('FLOW 20');
                    if(changedFieldSet.length()>1) changedFieldSet = changedFieldSet+',';
                    changedFieldSet = changedFieldSet + 'COM_FOR_Codigo_via_pago__c';
                }
                if(a.COM_FOR_Condicion_pago__c != Trigger.oldMap.get(a.Id).get('COM_FOR_Condicion_pago__c') && !changedFieldSet.contains('COM_FOR_Condicion_pago__c')) {
                    System.debug('FLOW 21');
                    if(changedFieldSet.length()>1) changedFieldSet = changedFieldSet+',';
                    changedFieldSet = changedFieldSet + 'COM_FOR_Condicion_pago__c';
                }
                if(a.COM_BOL_Compania_bloqueado__c != Trigger.oldMap.get(a.Id).get('COM_BOL_Compania_bloqueado__c') && !changedFieldSet.contains('COM_BOL_Compania_bloqueado__c')) {
                    System.debug('FLOW 22');
                    if(changedFieldSet.length()>1) changedFieldSet = changedFieldSet+',';
                    changedFieldSet = changedFieldSet + 'COM_BOL_Compania_bloqueado__c';
                }
                if(a.COM_TXT_Motivo_Bloqueo__c != Trigger.oldMap.get(a.Id).get('COM_TXT_Motivo_Bloqueo__c') && !changedFieldSet.contains('COM_TXT_Motivo_Bloqueo__c')) {
                    System.debug('FLOW 23');
                    if(changedFieldSet.length()>1) changedFieldSet = changedFieldSet+',';
                    changedFieldSet = changedFieldSet+ 'COM_TXT_Motivo_Bloqueo__c';
                }              
                a.Campos_pendiente_de_envio_SAP__c = changedFieldSet;
			}
        }
    }
}