public class GoogleService {
    
    public static final String CONTENT_TYPE_URL = 'application/x-www-form-urlencoded';
    public static final String CONTENT_TYPE_JSON = 'application/json';
    
    public class ResultadoRequest
    {
        public String Id {get;set;}
        public String IdSF {get;set;}
        public Boolean Error{get;set;}
        public String TextoError{get;set;}
    }
    
    //Constructor, recibe el nombre del servicio de google que usamos. (Por ahora, sera siempre el calendar)
    public GoogleService(string serviceName ) { } 

    
    public ResultadoRequest  makePostRequest( string url, string body) {
        
        HttpResponse response = getFeedMethod('POST',url, body, CONTENT_TYPE_JSON);
    
        if(response != null)
        {
            return parsearRespuesta(response);
        }
        else
        {
            return null;
        }
    }
        
    public ResultadoRequest  makePutRequest( string url, string body) {
        
        HttpResponse response = getFeedMethod('PUT',url, body, CONTENT_TYPE_JSON);
        
        if(response != null)
        {
            return parsearRespuesta(response);
        }
        else
        {
            return null;
        }
    }   
    
    public ResultadoRequest  makeDeleteRequest( string url) {
        
        HttpResponse response = getFeedMethod('DELETE', url, '', CONTENT_TYPE_URL);
        
        if(response != null)
        {
            return parsearRespuesta(response);
        }
        else
        {
            return null;
        }
    }
        
    /* arodriguez(15/01/2014): La dejo comentada por si se necesita en un futuro.
    public ResultadoRequest makeGetRequest( string url ) {
        
        HttpResponse response = getFeedMethod('GET', url, null, CONTENT_TYPE_URL);
        
        if(response != null)
        {
            return parsearRespuesta(response);
        }
        else
        {
            return null;
        }
    }*/
    
    // Comprobamos el límite de callouts de salesforce
    public boolean canCallout { get { return Limits.getCallouts() < limits.getLimitCallouts() ; }}

    
    /*
     * Metodo princical que genera las peticiones a google
     */
    public HttpResponse getFeedMethod(string method, string url, string body, string contentType)  
    {   
        //Si hemos llegado al límite de callouts, nos salimos.
        if ( ! canCallout ) return null;
        
        //Una request necesita:
        //endpoint (URL a la que llamamos)
        //Header (Cabecera inficando el tipo de datos que lleva)
        //Method (Si la llamada es GET, POST, DELETE,...)
        //Body (Parametros que se le envían si fuesen necesarios)
        
        HttpRequest req = new HttpRequest();   
        HttpResponse response = null;
                
        req.setEndpoint(url); //En la URL esta el token de autenticación de la sesión.
            
        if (contentType != null) 
        { 
            req.setHeader('content-type', contentType );
        }
        
        if (body != null) 
        { 
            req.setBody(body);
        }       
        
        if(method!=null)
        {
            req.setMethod(method);          
        }
        
        //Una vez construida la petición, la enviamos.
        try 
        {
            Http http = new Http();
            if(!Test.isRunningTest())
            {
                response = http.send(req);
            }       
            else
            {
                response = new HttpResponse();
                response.setBody('{ "code" : "12341234", "message" : "Bearer", "id" : "tfruioqwyf97awey9fyaefy89qwfgy890fe" }');        
            }
        }
        catch(System.Exception e) 
        {
            System.debug('Error sending request');
            System.debug('ERROR: '+ e);
        }
        return response;
    }   
    
    public ResultadoRequest parsearRespuesta(HttpResponse respuesta)
    {
        try
        {
            System.debug('asiereiki respuesta: '+respuesta);
            
            String message = '';
            String code = '';
            String id = '';
            
            JSONParser parser = JSON.createParser(respuesta.getbody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                    String fieldName = parser.getText();
                    parser.nextToken();
                    if(fieldName == 'code') 
                    {
                        code = parser.getText();
                    } 
                    if(fieldName == 'message') 
                    {
                        message = parser.getText();
                    } 
                    if(fieldName == 'id') 
                    {
                        id = parser.getText();
                    } 
                }
            }
            
    
            ResultadoRequest respuestaFormateada = new ResultadoRequest();
            
            if(id != '')
            {
                respuestaFormateada.Error = false;
                respuestaFormateada.Id = Id;            
            } 
            else if(message!='' || code !='')
            {
                respuestaFormateada.Error = true;
                respuestaFormateada.TextoError = code+' '+message;
            }       
            
            return respuestaFormateada;
        }
        catch(Exception ex)
        {
            ResultadoRequest respuestaFormateada = new ResultadoRequest();
            respuestaFormateada.Error = true;
            if(respuesta!=null)
            {               
                respuestaFormateada.TextoError = 'Error Google: '+ respuesta.getbody() +' Error SF: '+ex.getMessage();
            }
            else
            {
                respuestaFormateada.TextoError = 'Error SF: '+ ex.getMessage();
            }
            return respuestaFormateada;
        }
    }
}