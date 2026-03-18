/**
 * Trigger Handler for the Objetivo SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public class ObjetivoHandler implements ITrigger
{
    /*
    List & Maps must be always initialized here (the reference is lost when re-initializing)
    Map<Id, SObjectX> mapA = new Map<Id, SObjectX>();
    Map<Id, SObjectX> mapB = new Map<Id, SObjectX>();
    List<SObjectX> listA = new List<SObjectX>();
    */
    
    // Constructor
    public ObjetivoHandler() {}
 
    /**
     * bulkBefore
     *
     * These methods are called prior to execution of a BEFORE or AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     * Any new SOQL operation should be included in these methods (bulkBefore or bulkAfter)
     */
    public void bulkBefore(list<SObject> newList, map<Id,SObject> oldMap)
    {
        /*
        ObjetivoUtil.loadData(mapA, mapB, MapC...
                            listA, listB, newList, (Map<Id, Objetivo__c>)oldMap);
        */
        
    }
    
    public void bulkAfter(list<SObject> newList, map<Id,SObject> oldMap)
    {
        /*
        ObjetivoUtil.loadData(mapA, newList, (Map<Id, Objetivo__c>)oldMap);
        */
    }
    
    /**
     * These methods ara called for records to be processed during a BEFORE 
     * trigger.
     */
    public void beforeInsert(list<SObject> newList)
    {
        ObjetivoUtil.reiniciarClaveUnica(newList);
        ObjetivoUtil.updateAreaComercial( newList );
    }
    
    public void beforeUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {
       ObjetivoUtil.reiniciarClaveUnica(newList);
       ObjetivoUtil.updateAreaComercial( newList );
    }
    
    public void beforeDelete(map<Id,SObject> oldMap)
    {
        List<Objetivo__c> listaOb = oldMap.values();
        
        ObjetivoUtil.borrarActualizarObjetivoCalculado(listaOb);
        //ObjetivoUtil.borrarObjetivoCalculado(listaOb);
        /*
        ObjetivoUtil.methodA(null, (Map<Id, Objetivo__c>)oldMap, mapA);
        ObjetivoUtil.methodB(oldMap, mapC);
        ...
        */
    }
    
    /**
     * These methods ara called for records to be processed during a AFTER 
     * trigger.
     */ 
    public void afterInsert(list<SObject> newList)
    {
        /*
        ObjetivoUtil.methodA(newList, null, mapA);
        ObjetivoUtil.methodB(newList, mapC);
        ...
        */
    }
     
    public void afterUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {
        /**
        * Modificación -  Ante cambios en Servicio nivel Actividad, se crean nuevos objetivos calculados
        *                 y es posible que se generen duplicados; como los duplicados se quedan huerfanos,
        *                 borrarObjetivoCalculadoVacio busca y elimina TODOS los objetivos calculados huerfanos
        **
        * @Autor jmartinezpisson(24/06/2015)
        **/

        ObjetivoUtil.borrarObjetivoCalculadoVacio();

    }
     
    public void afterDelete(map<Id,SObject> oldMap)
    {
		ObjetivoUtil.borrarObjetivoCalculadoVacio();
        /*
        ObjetivoUtil.methodA(null, (Map<Id, Objetivo__c>)oldMap, mapA);
        ObjetivoUtil.methodB((Map<Id, Objetivo__c>)oldMap, mapC);
        ...
        */
    }
     
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     * Any new DML operation should be included in this method
     */
    public void andFinally()
    {
        /*
        ObjetivoUtil.methodA(mapA);
        ObjetivoUtil.methodB(mapC);
        ...
        */
    }
}