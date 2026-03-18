public class googleauthpruebas{
 
public string authtoken{get;set;}
public string refereshtoken{get;set;}
public string bodyprint{get;set;}
  
public static final string CLIENT_SECRET='_0jtlHvtCU_E-cm5pHWuBzDI';//Fill as per your registered app settings in google console
public static final string CLIENT_ID='740455754586-9k7aec2bch4p792bnklc5tof1e2t9it7.apps.googleusercontent.com';//Fill as per your registered app settings in google console
public static final string REDIRECT_URL='https://c.cs80.visual.force.com/apex/GoogleAuthPruebas';

//public static final string REDIRECT_URL='https://cs80.salesforce.com';
 
public static final string OAUTH_TOKEN_URL='https://accounts.google.com/o/oauth2/token';
public static final string OAUTH_CODE_END_POINT_URL='https://accounts.google.com/o/oauth2/auth';
 
public static final string GRANT_TYPE='grant_type=authorization_code';
public static final string GRANT_TYPE_REFRESH='grant_type=refresh_token';
 
//Scope URL as per oauth 2.0 guide of the google
public static final string SCOPE='https://www.googleapis.com/auth/calendar';
public static final string STATE='/profile';
 
//Approval Prompt Constant
public static final string APPROVAL_PROMPT='force';//'force';

//Access type constant
public static final string ACCESS_TYPE='offline';



//public pagereference connect(){
public string connect(){
    String x=OAUTH_CODE_END_POINT_URL+'?scope='+EncodingUtil.urlEncode(SCOPE,'UTF-8')+'&access_type='+ EncodingUtil.urlEncode(ACCESS_TYPE,'UTF-8') +'&state='+EncodingUtil.urlEncode(STATE,'UTF-8')+'&redirect_uri='+EncodingUtil.urlEncode(REDIRECT_URL,'UTF-8')+'&response_type=code&client_id='+CLIENT_ID+'&approval_prompt='+APPROVAL_PROMPT;   
    //pagereference p=new pagereference(x);
    return x;
}
 
 
public pagereference calendarList(){

    String accessToken;

    if(!Test.isRunningTest())
    {
        Config_CalendarSync__c configCS = Config_CalendarSync__c.getValues(UserInfo.getUserId());
        accessToken = configCS.AccessToken__c;
    }
    else
    {
        ConfigPrueba__c configCS = ConfigPrueba__c.getValues('ConfigSync');
        accessToken = configCS.AccessToken__c;
    }


    Http h = new Http();
    // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
    HttpRequest req = new HttpRequest();
    req.setEndpoint('https://www.googleapis.com/calendar/v3/users/me/calendarList?access_token='+accessToken);
    req.setHeader('Content-Type','application/x-www-form-urlencoded');
    req.setMethod('GET');
     
    // Send the request, and return a response
    if(!Test.isRunningTest())
    {
        HttpResponse res = h.send(req);
        bodyprint=res.getbody();
    }
    return null;
}


public pagereference marcarTodosparaSincronizar(){
    
        list <Event> eventUpdateList = new list <Event>();
        DateTime ahora = System.now();
            
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
        }   
    return null;
        
}

public pagereference syncEvents(){
    CalendarSyncv2.syncAllEvents();
    return null;
}

public pagereference refreshtoken(){
    
    Boolean resultado = false;
    string REFRESH_TOKEN;

    if(!Test.isRunningTest())
    {
        Config_CalendarSync__c configCSLoad = Config_CalendarSync__c.getValues(UserInfo.getUserId());
        REFRESH_TOKEN = configCSLoad.RefreshToken__c;   
    }
    else
    {
        ConfigPrueba__c configCSLoad = ConfigPrueba__c.getValues('ConfigSync');
        REFRESH_TOKEN = configCSLoad.RefreshToken__c;   
    }

    
    Http h = new Http();
    String body='client_id='+CLIENT_ID+'&client_secret='+CLIENT_SECRET+'&refresh_token='+REFRESH_TOKEN+'&'+GRANT_TYPE_REFRESH;
    
    HttpRequest req = new HttpRequest();
    req.setEndpoint(OAUTH_TOKEN_URL);
    req.setHeader('Content-Type','application/x-www-form-urlencoded');
    req.setMethod('POST');
    req.setBody(body);
    //system.debug('REQUEST BODY'+body);
     
    // Send the request, and return a response
    String accesstoken = '';
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
        res.setBody('{ "access_token" : "ya29.1.AADtN_WBVbS2DWkKUQuurIvbFj2LHOfvRjwUSiJ0gwyz92Ko2VpaXrideHaTOOMhiw", "token_type" : "Bearer", "expires_in" : 3598, "refresh_token" : "tfruioqwyf97awey9fyaefy89qwfgy890fe" }');
    }
    
    bodyprint=res.getbody();        
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
        if(!Test.isRunningTest())
            {
                Config_CalendarSync__c configCS = Config_CalendarSync__c.getValues(UserInfo.getUserId());
                configCS.AccessToken__c = accesstoken;
                configCS.ExpiresIn__c = expiresin;
                update configCS;    
            }
            else
            {
                ConfigPrueba__c configCS = ConfigPrueba__c.getValues('ConfigSync');
                configCS.AccessToken__c = accesstoken;
                configCS.ExpiresIn__c = expiresin;
                update configCS;    
            }


    }
    
    return null;
}

public pagereference showtoken(){
    string codeparam=apexpages.currentpage().getparameters().get('code');
    // Instantiate a new http object
    Http h = new Http();
    String body='code='+codeparam+'&client_id='+CLIENT_ID+'&client_secret='+CLIENT_SECRET+'&redirect_uri='+REDIRECT_URL+'&'+GRANT_TYPE;
    // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
    HttpRequest req = new HttpRequest();
    req.setEndpoint(OAUTH_TOKEN_URL);
    req.setHeader('Content-Type','application/x-www-form-urlencoded');
    req.setMethod('POST');
    req.setBody(body);
    system.debug('REQUEST BODY: '+body);
     
    // Send the request, and return a response
    String accesstoken = '';
    String refreshtoken = '';
    String expiresin = '';
    HttpResponse res = null;
    
    if(!Test.isRunningTest())
    {
        res = h.send(req);  
        System.debug('res: ' + res);
    }
    else
    {
        res = new HttpResponse();
        res.setBody('{ "access_token" : "ya29.HAEyW2A5HDWjA3BIsdMBvQxDYgFTn3KInEKA7eYIbcnGt8ut1rM0gwYgRkiF7sG1vQ282DYXRIzrSw", "token_type" : "Bearer", "expires_in" : 3598, "refresh_token" : "1/Gj2KZ6q0xW67dClPGHXQ6YeTzNNgK4fQf8BFKA5hds8" }');
    }
            
    JSONParser parser = JSON.createParser(res.getbody());
    while (parser.nextToken() != null) {
        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
            String fieldName = parser.getText();
            parser.nextToken();
            if(fieldName == 'access_token') 
            {
               accesstoken = parser.getText();
            } 
            if(fieldName == 'refresh_token') 
            {
               refreshtoken = parser.getText();
            } 
            if(fieldName == 'expires_in') 
            {
                expiresin = parser.getText();
            } 
        }
    }


        if(!Test.isRunningTest())
            {
                Config_CalendarSync__c configCS = Config_CalendarSync__c.getValues(UserInfo.getUserId());
                configCS.AccessToken__c = accesstoken;
                configCS.RefreshToken__c = refreshtoken;
                configCS.ExpiresIn__c = expiresin;
                update configCS;
            }
            else
            {
                ConfigPrueba__c configCS = ConfigPrueba__c.getValues('ConfigSync');
                configCS.AccessToken__c = accesstoken;
                configCS.RefreshToken__c = refreshtoken;
                configCS.ExpiresIn__c = expiresin;
                update configCS;
            }


    pagereference p = new pagereference('https://cs80.salesforce.com');
    
    return p;
}
}