/**
 * Author:      Miguel Artiaga
 * Company:     Everis
 * Description: Clase que sincroniza las cuentas con SAP
 * Inputs:      N/A
 * Test Class:  enviarSAP_Test
 * History:     2020/10 (Creación)
 */
public with sharing class enviarSap {

    @AuraEnabled
    public static String enviarCuentaSAP(Id objectId) {
        //String message; //Return
        List<Account> accList = [SELECT Id, COM_TXT_Numero_Compania_SAP__c,Sociedad_Ofertante__c,COM_SEL_Estado__c,COM_SEL_Estado_Solicitud_Modificacion__c FROM Account WHERE Id =: objectId LIMIT 1];
 
        String isValue,sociedadOfertante,estado,estadoModificacion;

        if (!accList.isEmpty()) {
            isValue = accList.get(0).COM_TXT_Numero_Compania_SAP__c;
            sociedadOfertante = accList.get(0).Sociedad_Ofertante__c;
            estado = accList.get(0).COM_SEL_Estado__c;
            estadoModificacion = accList.get(0).COM_SEL_Estado_Solicitud_Modificacion__c;
        }
 
        if ((Estado == 'Disponible en SAP') || (EstadoModificacion == 'Disponible en SAP')) return 'Ya existe una solicitud enviada SAP';
        else{
            if(String.isBlank(isValue)){        
                if(sociedadOfertante == null || sociedadOfertante =='') return 'Es necesario informar la sociedad ofertante';
                else{
                    String resultMessage = Z017vClientesWsSf_CreateCompaniaSAP.invokeSingle(accList.get(0).id,'I');
                    if (resultMessage == 'ERROR') return 'Se ha producido un error en la integración con SAP';
                    else return 'Solicitud enviada a SAP';       
                }
            }else{
                if(sociedadOfertante == null || sociedadOfertante =='') return 'Es necesario informar la sociedad ofertante';
                else{
                    String resultMessage = Z017vClientesWsSf_CreateCompaniaSAP.invokeModify(accList.get(0).id,'U');
                    if (resultMessage == 'ERROR') return 'Se ha producido un error en la integración con SAP';
                    else return 'Solicitud enviada a SAP';
                }
            }
        }
	}
}