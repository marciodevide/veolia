/**
 * Trigger Handler for the Account SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public class CandidatoHandler implements ITrigger
{
	/*
	List & Maps must be always initialized here (the reference is lost when re-initializing)
	Map<Id, SObjectX> mapA = new Map<Id, SObjectX>();
	Map<Id, SObjectX> mapB = new Map<Id, SObjectX>();
	List<SObjectX> listA = new List<SObjectX>();
	*/
    
    // Constructor
    public CandidatoHandler() {}
 
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
    	AccountUtil.loadData(mapA, mapB, MapC...
    						listA, listB, newList, (Map<Id, Account>)oldMap);
    	*/
        
    }
    
    public void bulkAfter(list<SObject> newList, map<Id,SObject> oldMap)
    {
    	/*
    	AccountUtil.loadData(mapA, newList, (Map<Id, Account>)oldMap);
    	*/
    }
    
    /**
     * These methods ara called for records to be processed during a BEFORE 
     * trigger.
     */
    public void beforeInsert(list<SObject> newList)
    {
    	/*
    	AccountUtil.methodA(newList, null, mapA);
    	AccountUtil.methodB(newList, mapC);
    	...
    	*/
    }
    
    public void beforeUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {
    	/*
    	AccountUtil.methodA(newList, (Map<Id, Account>)oldMap, mapA);
    	AccountUtil.methodB(newList, mapC);
    	...
    	*/
    }
    
    public void beforeDelete(map<Id,SObject> oldMap)
    {
    	/*
    	AccountUtil.methodA(null, (Map<Id, Account>)oldMap, mapA);
    	AccountUtil.methodB(oldMap, mapC);
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
    	AccountUtil.methodA(newList, null, mapA);
    	AccountUtil.methodB(newList, mapC);
    	...
    	*/
    }
     
    public void afterUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {
    	CandidatoUtil.copiarTipoCliente(newList, (Map<Id, Lead>)oldMap);

    	/*
    	AccountUtil.methodA(newList, (Map<Id, Account>)oldMap, mapA);
    	AccountUtil.methodB(newList, mapC);
    	...
    	*/
    }
     
    public void afterDelete(map<Id,SObject> oldMap)
    {
    	/*
    	AccountUtil.methodA(null, (Map<Id, Account>)oldMap, mapA);
    	AccountUtil.methodB((Map<Id, Account>)oldMap, mapC);
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
    	AccountUtil.methodA(mapA);
    	AccountUtil.methodB(mapC);
    	...
    	*/
    }
}