/**
 * @description       : methods to execute large scope script
 * 
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   10/07/2023   marc.nacher@viewnext.com      	Initial Version 
 *                                                      GestionPreviaContratoSinDefinir; fill this field on all the opps that is needed to "Sin definir"
 **/
public with sharing class SM001_ExecuteScript {

    /*********************************************************************************************************
     * @name            processWorkOrders
     * @description     process wo to assign HasAttachments__c value to true
     * @param           woList      :   list of wo to process
    **********************************************************************************************************/
    public static void GestionPreviaContratoSinDefinir(List<Opportunity> opList){
        for (Opportunity op: opList){
            op.OPO_PKL_Origen_contrato__c = 'Sin definir';
        }
        
        if (!opList.isEmpty()){
            update opList;
        }        
    }
    
    /*********************************************************************************************************
     * @name            VaciarCampoIngresos
     * @description     process ac to assign COM_NUM_Ultimos_Ingresos_Explotacion__c value to true
     * @param           woList      :   list of wo to process
    **********************************************************************************************************/
    public static void VaciarCampoIngresos(List<Account> accList){
        for(Account acc : accList){
            acc.COM_NUM_Ultimos_Ingresos_Explotacion__c = NULL;
        }
        if(!accList.isEmpty()){
            update accList;
        }
    }

}