global class CalendarSyncv2 implements Schedulable
{
    //Variables estaticas de parametros de configuración de googleCalendar
    private static String GOOGLE_USERNAME;
    private static String GOOGLE_PASSWORD;
    private static String GOOGLE_CALENDAR;  
    private static Integer NUMBATCHRECORDS; 
    private static String ACCESSTOKEN;
    public static Integer HTTPREQTIMEOUT; //milisegundos
    public static list<String> errorList = new list<String>(); //Errores producidos por el servicio
    
    global void execute(SchedulableContext SC)
    {
        /*
            Seconds  Minutes  Hours  Day_of_month  Month  Day_of_week  optional_year
            
            String CRON_EXP = '0 0 * * * ?';    
            CalendarSyncv2 cS = new CalendarSyncv2();
            System.schedule('CalendarSync', CRON_EXP, cS);
                    
        */

        for(CronTrigger cronTr : [SELECT id, CronExpression, TimesTriggered, NextFireTime, State FROM CronTrigger WHERE NextFireTime = null])
        {
           System.abortJob(cronTr.Id);
        }

        if(!Test.isRunningTest())
        {
            //Programamos la siguiente ejecución
            Datetime now = System.now();
            now = now.addMinutes(5);
            String cron ='0 ' + now.minute() + ' ' + now.hour() + ' ' + now.day() + ' ' + now.month() + ' ? ' + now.year();
            CalendarSyncv2 eifpS = new CalendarSyncv2();
            System.schedule('Sincronizar Eventos ' + now, cron, eifpS);
        }
        
        syncAllEvents();    
    }
    
    @future(callout=true)
    public static void syncAllEvents()
    {
        
        CalendarSyncLog log = new CalendarSyncLog();
        //Boolean loginOK = refreshtoken();
        
        //Si no hemos conseguido hacer login, no hacemos nada más.
        //if(loginOK)
        //{

            list<Event> evtUpdateList = new list<Event>(); //Lista de eventos a updatear en googleCalendar
            list<Event> evtInsertList = new list<Event>(); //Lista de eventos nuevos a insertar en googleCalendar
            list<Evento_borrado__c> evtDeleteList = new list<Evento_borrado__c>(); //Lista de eventos a borrar en GoogleCalendar
            list<String> IDDeleteListSF = new list<String>(); //Lista de Id de Evento_borrado__c a borrar en Salesforce (Solo se borraran en SF los correctamente borrados en GoogleCalendar)
            
            //Variables auxiliares
            set<Id> evtIdSet = new set <Id>();
            map<Id, list <EventRelation>> evtAttMap = new map<Id, list <EventRelation>>();
            Boolean syncTotal = false;
            
            //Variables auxiliares para saber si debemos hacer DML
            boolean debemosInsertar = false;
            boolean debemosActualizar = false;
            boolean debemosBorrar = false;
            
            //Carga de parametros de configuración GoogleCalendar

             /*   if(!Test.isRunningTest())
                {
                    Config_CalendarSync__c configCS = Config_CalendarSync__c.getValues(UserInfo.getUserId());
                    GOOGLE_USERNAME = configCS.Usuario_Google__c;
                    GOOGLE_PASSWORD = configCS.Password_Google__c;
                    GOOGLE_CALENDAR = configCS.Calendario_Google__c;
                    NUMBATCHRECORDS = configCS.Num_Eventos_Batch__c.intValue();
                    HTTPREQTIMEOUT = configCS.Http_Req_Timeout__c.intValue();   
                }
                else
                {
                    ConfigPrueba__c configCS= ConfigPrueba__c.getValues('ConfigSync');
                    GOOGLE_USERNAME = configCS.Usuario_Google__c;
                    GOOGLE_PASSWORD = configCS.Password_Google__c;
                    GOOGLE_CALENDAR = configCS.Calendario_Google__c;
                    NUMBATCHRECORDS = configCS.Num_Eventos_Batch__c.intValue();
                    HTTPREQTIMEOUT = configCS.Http_Req_Timeout__c.intValue();   
                }
            
               */ 
            //Comenzamos la sincronización total.
            try
            {       
                CalendarService service = new CalendarService();                
                                        
                syncTotal = marcarTodosparaSincronizar();


                                
                if(!syncTotal)
                {      
                    /*for (Event e : [select Id, CreatedById, Marcar_para_sincronizar__c, Subject, ActivityDateTime, DurationInMinutes, Description,
                                    Id_Evento_Google__c, StartDateTime, sequence__c, EndDateTime, Location from Event where Marcar_para_sincronizar__c = true 
                                    and isChild = false limit :NUMBATCHRECORDS])*/

                    for (Event e : [select Id, CreatedById, Marcar_para_sincronizar__c, Subject, ActivityDateTime, DurationInMinutes, Description,
                                    Id_Evento_Google__c, StartDateTime, sequence__c, EndDateTime, Location from Event where Marcar_para_sincronizar__c = true 
                                    and isChild = false limit 200])
                    {                       
                        System.debug('Eventos Recogidos : '+e); 
                        //se clasifican los eventos recuperados en inserciones y en actualizaciones
                        if (e.Id_Evento_Google__c == null || e.Id_Evento_Google__c == '')
                        {
                            evtInsertList.add(e);   
                        }
                        else
                        {
                            evtUpdateList.add(e);
                        }
                        //Se añaden los ids de todos los eventos a un Set para recuperar sus invitados después
                        evtIdSet.add(e.Id);
                    }
                        
                    Integer limitRecords = 200 - evtInsertList.size() - evtUpdateList.size();
                        
                    if (limitRecords > 0)
                    {
                        evtDeleteList = [select Id, Id_Evento_Google__c,CreatedById from Evento_borrado__c limit :limitRecords];
                    }

                    //Procesamos los eventos recogidos.
                    if ((evtIdSet != null && !evtIdSet.isEmpty()) || !evtDeleteList.isEmpty())
                    {  
                        List<EventRelation> eatts = [Select Relation.Name, Relation.Email, RelationId, EventId, Status From EventRelation where EventId in :evtIdSet];
                    

                        List<Id> listaContactos = new List<Id>();
                        List<Id> listaUsuaros = new List<Id>();

                        for (EventRelation eAtt : eatts)
                        {  
                            String id = eAtt.RelationId;

                            if(id.substring(0,3) == '003')
                            {
                                listaContactos.add(eAtt.RelationId);
                            }
                            else
                            {
                                System.debug('llego');
                                listaUsuaros.add(eAtt.RelationId);
                            }
                        }

                        List<Contact> queryContactos = [SELECT Id, Email FROM Contact WHERE Id in : listaContactos];
                        List<User> queryUsers = [SELECT Id, Email FROM User Where Id in : listaUsuaros];

                        Map<Id, String> mapaEmails = new Map<Id, String>();

                        for (Contact c : queryContactos)
                        {
                            mapaEmails.put(c.Id, c.Email);
                        }

                        for (User u : queryUsers)
                        {
                            mapaEmails.put(u.Id, u.Email);
                        }
                        
                        //Se recuperan los invitados a los eventos y se insertar en un mapa agrupados por id de evento
                        for (EventRelation eAtt : eatts)
                        {     

                            if (evtAttMap.containsKey (eAtt.EventId))
                            {
                                list <EventRelation> attendeeTemp = evtAttMap.remove(eAtt.EventId);
                                attendeeTemp.add (eAtt);
                                evtAttMap.put (eAtt.EventId, attendeeTemp);
                            }
                            else
                            {
                                list <EventRelation> attendeeTemp = new list <EventRelation> ();
                                attendeeTemp.add(eAtt);
                                evtAttMap.put(eAtt.EventId, attendeeTemp);
                            }
                        }       
                        //Finalizamos de rellenar el mapa de Evento -> invitados
                        
                        /***************************************Empezamos la sincronización*****************************************************/
                        
                        
                        /**1º - Eventos a Insertar**/
                        if (evtInsertList != null && !evtInsertList.isEmpty())
                        {
                            List<GoogleService.ResultadoRequest> resultados = null;                     
                            resultados = service.insertEvents( GOOGLE_USERNAME, evtInsertList, evtAttMap,ACCESSTOKEN,mapaEmails);
                            if(resultados != null)
                            {
                                debemosInsertar = true;
                                for(GoogleService.ResultadoRequest resultado : resultados)
                                {   
                                    if (!resultado.Error)
                                    {       
                                        for(Integer i=0;i<evtInsertList.size();i++)
                                        {
                                            if(evtInsertList[i].Id == resultado.IdSF)
                                            {                   
                                                evtInsertList[i].Fecha_sincronizacion__c = System.today();
                                                evtInsertList[i].Marcar_para_sincronizar__c = false;    
                                                evtInsertList[i].Id_Evento_Google__c = resultado.Id;
                                                break;
                                            }
                                        }
                                        //Se actualizan los campos de sincronización del evento     
                                    }
                                    else
                                    {                           
                                        errorList.add ('Error al insertar el evento con id '+ resultado.IdSF + ': ' + resultado.TextoError);
                                    }                       
                                }
                            }
                        }
        
                        /**2º - Eventos a Updatear**/
                                                            
                        if (evtUpdateList != null && !evtUpdateList.isEmpty())
                        {                 
                            List<GoogleService.ResultadoRequest> resultados = null;
                            resultados = service.updateEvents( GOOGLE_USERNAME, evtUpdateList, evtAttMap,ACCESSTOKEN,mapaEmails);
                            
                            if(resultados != null)
                            {
                                debemosActualizar = true;
                                for(GoogleService.ResultadoRequest resultado : resultados)
                                {                       
                                    if (!resultado.Error)
                                    {
                                        for(Integer i=0;i<evtUpdateList.size();i++)
                                        {
                                            if(evtUpdateList[i].Id == resultado.IdSF)
                                            {   
                                                //Se actualizan los campos de sincronización del evento
                                                evtUpdateList[i].Fecha_sincronizacion__c = System.today();
                                                evtUpdateList[i].Marcar_para_sincronizar__c = false;    
                                                evtUpdateList[i].Id_Evento_Google__c = resultado.Id;
                                                break;
                                            }
                                        }
                                    }
                                    else
                                    {                           
                                        errorList.add ('Error al actualizar el evento con id '+ resultado.IdSF + ': ' + resultado.TextoError);
                                    }                       
                                }   
                            }
                        }
        
                        /**3º - Eventos a Borrar**/ 
                        if (evtDeleteList != null && !evtDeleteList.isEmpty())
                        {
                            List<GoogleService.ResultadoRequest> resultados = null;
                            resultados = service.deleteEvents( GOOGLE_USERNAME, evtDeleteList,ACCESSTOKEN );

                            for(GoogleService.ResultadoRequest resultado : resultados)
                            {
                                if (!resultado.Error)
                                {
                                    debemosBorrar = true;
                                    IDDeleteListSF.add(resultado.Id);
                                }
                                else
                                {                       
                                    errorList.add ('Error al borrar el evento con id '+ resultado.Id + ': ' + resultado.TextoError);
                                }                       
                            }               
                        }
                                        
                        if (evtInsertList != null &&  !evtInsertList.isEmpty() && debemosInsertar)
                        {
                            //se hace el update de los eventos SF
                            update evtInsertList;
                        }
                                            
                        if (evtUpdateList != null &&  !evtUpdateList.isEmpty() && debemosActualizar)
                        {
                            //se hace el update de los eventos SF
                            update evtUpdateList;
                        }
                        
                        if (IDDeleteListSF != null && !IDDeleteListSF.isEmpty() && debemosBorrar)
                        {
                            evtDeleteList = [Select Id from Evento_borrado__c where Id_Evento_Google__c IN :IDDeleteListSF];
                            
                            if(evtDeleteList != null && !evtDeleteList.isEmpty())
                            {
                                delete evtDeleteList;
                            }
                        }       
                    }
                }
            }
            catch (Exception e)
            {
                log.escribirLog ('Se ha producido una excepción:: ' + e + ' Línea: '+e.getLineNumber());
            }       
       // }
       // else
       // {       
        //    log.escribirLog('Error en login');
       // }
                    
                    
        if (errorList != null && !errorList.isEmpty())
        {
            log.escribirLog(errorList);
        }       
    }
    
    
    public static final string CLIENT_SECRET='_0jtlHvtCU_E-cm5pHWuBzDI ';//Fill as per your registered app settings in google console
    public static final string CLIENT_ID='740455754586-9k7aec2bch4p792bnklc5tof1e2t9it7.apps.googleusercontent.com';//Fill as per your registered app settings in google console
    public static final string GRANT_TYPE_REFRESH='grant_type=refresh_token';
    public static final string OAUTH_TOKEN_URL='https://accounts.google.com/o/oauth2/token';
     
    /*public static boolean refreshtoken()
    {   

    Boolean resultado = false;
    DateTime ahora = System.now();

    Config_CalendarSync__c configCSLoad;
    ConfigPrueba__c configCSLoadPrueba;

    string REFRESH_TOKEN;

    if(!Test.isRunningTest())
    {

        configCSLoad = Config_CalendarSync__c.getValues(UserInfo.getUserId());
        REFRESH_TOKEN = configCSLoad.RefreshToken__c;    
    }  
    else
    {
        configCSLoadPrueba = ConfigPrueba__c.getValues('ConfigSync');
        REFRESH_TOKEN = configCSLoadPrueba.RefreshToken__c;

    }
       
        if(ahora.minute() < 30)
        {       
            Http h = new Http();
            String body='client_id='+CLIENT_ID+'&client_secret='+CLIENT_SECRET+'&refresh_token='+REFRESH_TOKEN+'&'+GRANT_TYPE_REFRESH;
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(OAUTH_TOKEN_URL);
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setMethod('POST');
            req.setBody(body);
            system.debug('REQUEST BODY'+body);
             
            // Send the request, and return a response
            String refreshtoken = '';
            String expiresin = '';
            HttpResponse res = null;
            
            if(!Test.isRunningTest())
            {
                res = h.send(req);  
            }
            else
            {
                res = new HttpResponse();
                res.setBody('{ "access_token" : "ya29.HgH4ndFw6b8rIS9qghOt74OwDilZ_Jc0GSRWLv8bMVDb6QGjTySgfUgmoVFUFlOiVFXcf_lzFLp9OA", "token_type" : "Bearer", "expires_in" : 3598, "refresh_token" : "tfruioqwyf97awey9fyaefy89qwfgy890fe" }');
            }
                
            CalendarSyncLog log = new CalendarSyncLog();    
            errorList.add ('Respuesta Google Refresh Token: '+ res.getbody());      
                
            JSONParser parser = JSON.createParser(res.getbody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                    String fieldName = parser.getText();
                    parser.nextToken();
                    if(fieldName == 'access_token') 
                    {
                        resultado = true;
                        accesstoken = parser.getText();
                    } 
                    if(fieldName == 'expires_in') 
                    {
                        expiresin = parser.getText();
                    } 
                }
            }
        
            if(resultado)
            {
                ACCESSTOKEN = accesstoken;      
            }
        }
        else
        {
            if(!Test.isRunningTest())
            {
                if(configCSLoad.AccessToken__c != null)
                {
                    ACCESSTOKEN = configCSLoad.AccessToken__c;
                    resultado = true;
                }
                else
                {
                    Log_de_Errores__c log = new Log_de_Errores__c(Fuente__c='RefreshToken ',Descripcion__c='No hay Access Token');
                }
            }
            else
            {
                if(configCSLoadPrueba.AccessToken__c != null)
                {
                    ACCESSTOKEN = configCSLoadPrueba.AccessToken__c;
                    resultado = true;
                }
                else
                {
                    Log_de_Errores__c log = new Log_de_Errores__c(Fuente__c='RefreshToken ',Descripcion__c='No hay Access Token');
                }
            }

        }
        
        return resultado;
    
    }
    */
    public static Boolean marcarTodosparaSincronizar()
    {
        boolean HoraSync = false;
        DateTime ahora = System.now();
/*
            if(!Test.isRunningTest())
            {
                ahora = System.now();
            }
            else
            {
                ahora = DateTime.newInstance(1999, 2, 11, 11, 6, 16);
            }
        */
        if ((ahora.hour() == 11 || ahora.hour() == 18) && ahora.minute() < 30)
        {
            HoraSync = true;
            list <Event> eventUpdateList = new list <Event>();
                
            eventUpdateList = [select Id, Marcar_para_sincronizar__c from Event where IsGroupEvent = true and StartDateTime > :ahora 
                                    and Id_Evento_Google__c != null and IsChild = false];
                    
            if (eventUpdateList != null && !eventUpdateList.isEmpty())
            {
                for (Event e: eventUpdateList)
                {
                    e.Marcar_para_sincronizar__c = true;
                }
                
                Database.Saveresult[] result = Database.update(eventUpdateList, false);
                List<Log_de_Errores__c> errores = new List<Log_de_Errores__c>();
                    
                for(Integer i = 0; i < result.size(); i++)
                {                   
                    Database.SaveResult sr = result[i];
                    if(!sr.isSuccess())
                    {
                        Database.Error err = sr.getErrors()[0];
                        Log_de_Errores__c log = new Log_de_Errores__c(Fuente__c='Marcar Eventos Sync ',Descripcion__c='Ha ocurrido el siguiente error: '+ err +' para el evento '+eventUpdateList[i].Id);
                        errores.add(log);
                    }
                                
                }
                if(errores.size()>0)
                {
                    insert errores;
                }   
                else
                {                   
                    CalendarSyncLog log = new CalendarSyncLog();    
                    errorList.add ('Hora Sync Total '+ahora.hour()+':'+ahora.minute());
                }   
            }   
        }
        return HoraSync;        
    }
}