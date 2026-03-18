public class EventUtil {
	public EventUtil() {}

	public static void borrarEventoGoogle(map<Id,Event> oldMap)
    {
        list<Evento_borrado__c> deleteEvents = new list<Evento_borrado__c>();

        List<Event> oldEvent = new List<Event>();
        oldEvent = oldMap.values();
        
        for (Event e : oldEvent)
        {
            if (e.IsChild == false && e.Id_Evento_Google__c != null && e.Id_Evento_Google__c != '')
            {
                Evento_borrado__c eBC = new Evento_borrado__c (Id_Evento_Google__c = e.Id_Evento_Google__c);
                deleteEvents.add (eBC);
            }
        }
        
        if  (deleteEvents != null && !deleteEvents.isEmpty())
        {
            insert (deleteEvents);
        }
    }                

}