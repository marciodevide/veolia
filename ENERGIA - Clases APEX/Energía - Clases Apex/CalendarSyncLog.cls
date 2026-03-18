public class CalendarSyncLog
{
    private static final Integer NUMMAXRECORDS = 5000;
    private static final Integer NUMDELETERECORDS = 500;
    
    public void escribirLog (String err)
    {
        Log_de_errores_de_calendario__c logErrores = new Log_de_errores_de_calendario__c();
        logErrores.Descripcion__c = err;
        insert logErrores;
        limpiarLog();
    }
    
    public void escribirLog (list<String> errList)
    {
        list<Log_de_errores_de_calendario__c> logErroresList = new list<Log_de_errores_de_calendario__c>();
        
        for (String err : errList)
        {
            logErroresList.add (new Log_de_errores_de_calendario__c(Descripcion__c = err)); 
        }
        
        if (logErroresList != null && !logErroresList.isEmpty())
        {
            insert logErroresList;
        }
        
        limpiarLog();
    }
    
    /*
    public void escribirLogINFO (list<Event> EventosInsertar,map<Id, list <EventAttendee>> evtAttMap)
    {
        Log_de_errores_de_calendario__c logInfoEventos = new Log_de_errores_de_calendario__c();
        Log_de_errores_de_calendario__c logInfoAsistentes = new Log_de_errores_de_calendario__c();
        
        for (Event evento : EventosInsertar)
        {
            List<EventAttendee> asistentes = evtAttMap.get(evento.Id);
            for(EventAttendee asis : asistentes)
            {
                if(logInfoAsistentes.Descripcion__c == null)
                {
                    logInfoAsistentes.Descripcion__c = asis.Attendee.Name;
                    
                }
                else
                {
                    logInfoAsistentes.Descripcion__c = logInfoAsistentes.Descripcion__c+', '+asis.Attendee.Name;                
                }
            }
            if(logInfoEventos.Descripcion__c == null)
            {
                logInfoEventos.Descripcion__c = evento.Id;
                
            }
            else
            {
                logInfoEventos.Descripcion__c = logInfoEventos.Descripcion__c+', '+evento.Id;               
            }
        }
        
        insert logInfoEventos;
        insert logInfoAsistentes;
        
        limpiarLog();
    }
     */
    private void limpiarLog ()
    {
        list<Log_de_errores_de_calendario__c> logErroresDeleteList = new list<Log_de_errores_de_calendario__c>();
        
        Integer numRecords = [select count() from Log_de_errores_de_calendario__c];
        
        if (numRecords > NUMMAXRECORDS)
        {
            logErroresDeleteList = [select Id from Log_de_errores_de_calendario__c order by CreatedDate asc limit :NUMDELETERECORDS];
            
            if (!logErroresDeleteList.isEmpty())
            {
                delete logErroresDeleteList;
            }   
        }
        
    }  
}