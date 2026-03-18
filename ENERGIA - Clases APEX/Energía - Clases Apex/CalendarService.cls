public class CalendarService {


public static final string ENDPOINT_INSERT='https://www.googleapis.com/calendar/v3/calendars/';
public static final string ENDPOINT_UPDATE='https://www.googleapis.com/calendar/v3/calendars/';
public static final string ENDPOINT_DELETE='https://www.googleapis.com/calendar/v3/calendars/';

private static String GOOGLE_USERNAME;
private static String GOOGLE_PASSWORD;
private static String GOOGLE_CALENDAR;  
private static Integer NUMBATCHRECORDS; 
private static String ACCESSTOKEN;
public static Integer HTTPREQTIMEOUT; //milisegundos
public static list<String> errorList = new list<String>(); //Errores producidos por el servicio
    
public class GoogleCalendarEvent 
{
    public String id;
    public String htmlLink;
    public DateTime created;
    public String summary;
    public String description;
    public String location;
    public String status;
    public Integer sequence;
    public GoogleEventTime start;
    public GoogleEventTime gEnd;
    public List<GoogleEventAttendee> attendees;
    public Boolean guestsCanInviteOthers;
}

public class GoogleEventAttendee 
{
    public String email;
    public String comment;
    public String displayName;
    public String responseStatus;
}

public class GoogleEventTime 
{
    public String dateg;
    public DateTime dateTimeg;
    public String timeZone; 
}
    GoogleService service = new GoogleService('Calendar');
    
    /*
     * Recibe el calendario, eventos e invitados a insertar y genera un JSON con el cuerpo de la petición.
     * La petición se envia a la clase GoogleService para que la envíe.
     */
    public List<GoogleService.ResultadoRequest> insertEvents( String IdCalendarioParam, list<Event> evtList, map <Id, list<EventRelation>> evtAttMap,string accessTokenParam,  Map<Id, String> mapaEmails) 
    {
        //Comprobamos si podemos hacer más callouts en esta ejecución.
        if(!service.canCallout) return null;
        
        //Variables auxiliares
        String body = null;
        List<GoogleService.ResultadoRequest> responses = new List<GoogleService.ResultadoRequest>();
        
        //Nos recorremos los eventos a insertar y por cada uno hacemos una petición a google de inserción y recogemos la respuesta
        for ( Event e: evtList) 
        {           
            //Rellenamos la clase GoogleCalendarEvent con los parametros que necesitamos del evento y los invitados para pasarla a JSON. 
            GoogleCalendarEvent evento = new GoogleCalendarEvent();

            Boolean loginOk = refreshtoken(e.CreatedById);

            if(!Test.isRunningTest())
                {
                    Config_CalendarSync__c configCS = Config_CalendarSync__c.getValues(e.CreatedById);
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

            //Parametros del evento.
            evento.description = e.Description;
            evento.guestsCanInviteOthers = false;
            evento.location = e.Location;
            evento.status = 'confirmed';
            evento.summary = e.Subject;
            if ( e.sequence__c == null )
            {
                e.sequence__c = 1;
            }
            evento.sequence = e.sequence__c.intValue();
                
            //Parametros de fecha de comienzo y fin.
            GoogleEventTime start = new GoogleEventTime();
            start.dateTimeg = e.StartDateTime;
            evento.start = start;

            GoogleEventTime endg = new GoogleEventTime();
            endg.dateTimeg = e.EndDateTime;
            evento.gEnd = endg;

            //Invitados
            if(evtAttMap != null && evtAttMap.containsKey(e.id))
            {
                List<GoogleEventAttendee> invitadosGoogle = new List<GoogleEventAttendee>();
                list<EventRelation> invitados = evtAttMap.get(e.id);
                for(EventRelation invitado : invitados)
                {
                    GoogleEventAttendee invitadoGoogle = new GoogleEventAttendee();
                    invitadoGoogle.displayName = invitado.Relation.Name;
                    //invitadoGoogle.email = invitado.Relation.Email;
                    invitadoGoogle.email = mapaEmails.get(invitado.RelationId);
                    
                    if(invitado.Status == 'New')
                    {
                        invitadoGoogle.responseStatus = 'needsAction';
                    }
                    else if(invitado.Status == 'Declined')
                    {
                        invitadoGoogle.responseStatus = 'declined';
                    }
                    else if(invitado.Status == 'Accepted')
                    {
                        invitadoGoogle.responseStatus = 'accepted';
                    }               
                    invitadosGoogle.add(invitadoGoogle);
                }    
    
                evento.attendees = invitadosGoogle;
            }
            
            //En este punto tenemos la clase GoogleCalendarEvent rellena con todos los datos necesarios.
            //La serializamos a JSON            
            body = generarBodyJSON(evento);
            System.debug(body);   
            
            //Generamos la URL a la que vamos a llamar con la URL de google + el id del calendario de google + el access token proporcionado por el Oauth 2.0
            String url = ENDPOINT_INSERT+GOOGLE_CALENDAR+'/events?access_token='+ACCESSTOKEN;
            
            //Por último, hacemos la petición POST con todos los datos y recogemnos la respuesta.
            GoogleService.ResultadoRequest response = null;
            
            GoogleService.ResultadoRequest response2 = null; //solo para el test
           
            response = service.makePostRequest( url, body );
            
            if(response != null)
            {
                response.IdSF = e.Id;
                responses.add(response);                
            }
        }
        
        //Una vez fuera del "for", habremos enviado todos los eventos a Insertar a Google y habremos recogido todas las respuestas (buenas y malas). Devolvemos todo.
        return responses;
    } 

    /*
     * Recibe el calendario, eventos e invitados a actualizar y genera un JSON con el cuerpo de la petición.
     * La petición se envia a la clase GoogleService para que la envíe.
     */
    //TODO: si falla uno, se debe tratar la excepción y el resto seguir con la ejecución.
    public List<GoogleService.ResultadoRequest> updateEvents(String IdCalendarioParam, list<Event> evtList , map <Id, list<EventRelation>> evtAttMap,string accessTokenParam, Map<Id, String> mapaEmails)
    {
        //Comprobamos si podemos hacer más callouts en esta ejecución.
        if(!service.canCallout) return null;
        
        String body = null;
        List<GoogleService.ResultadoRequest> responses = new List<GoogleService.ResultadoRequest>();



        //Nos recorremos los eventos a ACTUALIZAR y por cada uno hacemos una petición a google de inserción y recogemos la respuesta
        for ( Event e: evtList) 
        {           
            //Rellenamos la clase GoogleCalendarEvent con los parametros que necesitamos del evento y los invitados para pasarla a JSON. 
            GoogleCalendarEvent evento = new GoogleCalendarEvent();

            Boolean loginOk = refreshtoken(e.CreatedById);

            if(!Test.isRunningTest())
                {
                    Config_CalendarSync__c configCS = Config_CalendarSync__c.getValues(e.CreatedById);
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
            
            //Parametros del evento.
            evento.description = e.Description;
            evento.guestsCanInviteOthers = false;
            evento.location = e.Location;
            evento.status = 'confirmed';
            evento.summary = e.Subject;
            //Aumento en uno el Sequence number del evento, que permite conocer las veces que un evento ha sido actualizado
            if ( e.sequence__c == null )
            {
                e.sequence__c = 5;
            }
            e.sequence__c++;
            evento.sequence = e.sequence__c.intValue();
            
            //Parametros de fecha de comienzo y fin.
            GoogleEventTime start = new GoogleEventTime();
            start.dateTimeg = e.StartDateTime;
            evento.start = start;

            GoogleEventTime endg = new GoogleEventTime();
            endg.dateTimeg = e.EndDateTime;
            evento.gEnd = endg;

            //Invitados
            if(evtAttMap != null && evtAttMap.containsKey(e.id))
            {
                List<GoogleEventAttendee> invitadosGoogle = new List<GoogleEventAttendee>();
                list<EventRelation> invitados = evtAttMap.get(e.id);
                for(EventRelation invitado : invitados)
                {
                    GoogleEventAttendee invitadoGoogle = new GoogleEventAttendee();
                    invitadoGoogle.displayName = invitado.Relation.Name;
                    //invitadoGoogle.email = invitado.Relation.Email;
                    invitadoGoogle.email = mapaEmails.get(invitado.RelationId);
                    
                    if(invitado.Status == 'New')
                    {
                        invitadoGoogle.responseStatus = 'needsAction';
                    }
                    else if(invitado.Status == 'Declined')
                    {
                        invitadoGoogle.responseStatus = 'declined';
                    }
                    else if(invitado.Status == 'Accepted')
                    {
                        invitadoGoogle.responseStatus = 'accepted';
                    }               
                    invitadosGoogle.add(invitadoGoogle);
                }    
    
                evento.attendees = invitadosGoogle;
            }
            
            //En este punto tenemos la clase GoogleCalendarEvent rellena con todos los datos necesarios.
            //La serializamos a JSON            
            body = generarBodyJSON(evento);
            System.debug(body);   
            
            //Generamos la URL a la que vamos a llamar con la URL de google + el id del calendario de google + el access token proporcionado por el Oauth 2.0
            String url = ENDPOINT_INSERT+GOOGLE_CALENDAR+'/events/'+ e.Id_Evento_Google__c +'?access_token='+ACCESSTOKEN;
                        
            //Por último, hacemos la petición POST con todos los datos y recogemos la respuesta.            
            GoogleService.ResultadoRequest response = null;
            
            response = service.makePutRequest( url, body );
                        
            if(response != null)
            {
                response.IdSF = e.Id;
                responses.add(response);
            }
        }
         
        
        return responses;        
    }       

    /*
     * Recibe el calendario y los eventos a borrar.
     * La petición se envia a la clase GoogleService para que la envíe.
     */
    public List<GoogleService.ResultadoRequest> deleteEvents( String IdCalendarioParam, list<Evento_borrado__c> evtList,string accessTokenParam)
    {
        //Comprobamos si podemos hacer más callouts en esta ejecución.
        if(!service.canCallout) return null;
        
        String body = null;
        List<GoogleService.ResultadoRequest> responses = new List<GoogleService.ResultadoRequest>();
        
        for ( Evento_borrado__c e: evtList) 
        {    

            Boolean loginOk = refreshtoken(e.CreatedById);

            if(!Test.isRunningTest())
                {
                    Config_CalendarSync__c configCS = Config_CalendarSync__c.getValues(e.CreatedById);
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


            String url = ENDPOINT_DELETE+GOOGLE_CALENDAR+'/events/'+e.Id_Evento_Google__c +'?access_token='+ACCESSTOKEN;
            
            GoogleService.ResultadoRequest response = null;
            response = service.makeDeleteRequest(url);
            
            if(response != null)
            {
                responses.add(response);
            }
        }
        return responses;       
    }          
    
    public String generarBodyJSON(GoogleCalendarEvent evento)
    {
        //instantiate the generator
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        if(evento.summary != null)
        {
            gen.writeStringField('summary', evento.summary);
        }
        if(evento.location != null)
        {
            gen.writeStringField('location', evento.location);
        }
        if(evento.status != null)
        {
            gen.writeStringField('status', evento.status);
        }
        if(evento.sequence != null)
        {
            gen.writeNumberField('sequence', evento.sequence);          
        }
        if(evento.description != null)
        {
            gen.writeStringField('description', evento.description);
        }
        if(evento.guestsCanInviteOthers != null)
        {
            gen.writeBooleanField('guestsCanInviteOthers', evento.guestsCanInviteOthers);
        }
        if(evento.start.dateTimeg != null)
        {
            gen.writeFieldName('start');
            gen.writeStartObject();        
            gen.writeObjectField('dateTime', evento.start.dateTimeg);   
            gen.writeEndObject();
        }
        if(evento.gEnd.dateTimeg != null)
        {
            gen.writeFieldName('end');
            gen.writeStartObject();        
            gen.writeDateTimeField('dateTime', evento.gEnd.dateTimeg);       
            gen.writeEndObject();   
        }
        if(evento.attendees != null)
        {
            gen.writeFieldName('attendees');
            gen.writeStartArray();
            for(GoogleEventAttendee gEventAttendee: evento.attendees){
                gen.writeStartObject();
                if(gEventAttendee.email != null)
                {
                    gen.writeStringField('email', gEventAttendee.email);   
                }
                if(gEventAttendee.displayName != null)
                {
                    gen.writeStringField('displayName', gEventAttendee.displayName);   
                }
                if(gEventAttendee.responseStatus != null)
                {               
                    gen.writeStringField('responseStatus', gEventAttendee.responseStatus);
                }
                gen.writeEndObject();
            }
            gen.writeEndArray();
        }
        gen.writeEndObject();
        
        return gen.getAsString();
    }




    public static final string CLIENT_SECRET='_0jtlHvtCU_E-cm5pHWuBzDI ';//Fill as per your registered app settings in google console
    public static final string CLIENT_ID='740455754586-9k7aec2bch4p792bnklc5tof1e2t9it7.apps.googleusercontent.com';//Fill as per your registered app settings in google console
    public static final string GRANT_TYPE_REFRESH='grant_type=refresh_token';
    public static final string OAUTH_TOKEN_URL='https://accounts.google.com/o/oauth2/token';
     
    public static boolean refreshtoken(Id idUser)
    {   

    Boolean resultado = false;
    DateTime ahora = System.now();

    Config_CalendarSync__c configCSLoad;
    ConfigPrueba__c configCSLoadPrueba;

    string REFRESH_TOKEN;

    if(!Test.isRunningTest())
    {

        configCSLoad = Config_CalendarSync__c.getValues(idUser);
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



}