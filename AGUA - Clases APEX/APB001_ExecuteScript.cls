/**
 * @description       : Job to execute large scope script
 * 
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   10/07/2023   marc.nacher@viewnext.com      	Initial Version 
 *                                                      GestionPreviaContratoSinDefinir; fill this field on all the opps that is needed to "Sin definir"
 **/
public with sharing class APB001_ExecuteScript implements Database.Batchable<sObject>, Database.Stateful{
    
    /*********************************************************************************************************
     * @name            execute
     * @description     execute job
     * @param           bc      :   database context
     * @param           scope   :   list of sobjects to delete
    **********************************************************************************************************/
    public void execute (Database.BatchableContext bc, List<sObject> scope){  
    	SM001_ExecuteScript.VaciarCampoIngresos((List<Account>)scope);
    }
    
	public Database.QueryLocator start(Database.BatchableContext bc) {
        String valorVacio = '';
        return Database.getQueryLocator(
            'SELECT id, COM_NUM_Ultimos_Ingresos_Explotacion__c ' + 
            ' FROM Account' + 
            ' WHERE COM_NUM_Ultimos_Ingresos_Explotacion__c!=null'
        );
    }
    public void finish(Database.BatchableContext bc){
        
    }
}