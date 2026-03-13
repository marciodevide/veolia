global with sharing class Z017vUsuarioWsSf_CreateUserSAP { 

    private static  List<User> getUserSalesforce(list<Id> UserId)
    {
    
         return [SELECT ID, NAME, EMAIL, USER_NUM_Numero_Solicitud__c, USER_TXT_OPERA_HIDDEN__c FROM USER where ID IN :UserId];    
    }    
    
   private static sapCreateClientSoapFunctionsMcS.Z017vClientesWsSf UserClient (User UserSalesforce)
   {
    
        sapCreateClientSoapFunctionsMcS.Z017vClientesWsSf client = new sapCreateClientSoapFunctionsMcS.Z017vClientesWsSf();

        client.ZzsfdcAcc= UserSalesforce.ID;
        
        if(UserSalesforce.name!= null)
        {
          client.Name1=UserSalesforce.name;
        }
        
        if(UserSalesforce.email!= null)
        {
          client.SmtpAddr=UserSalesforce.email;
        }

        if(UserSalesforce.USER_NUM_Numero_Solicitud__c != null)
        {
          client.Solic=String.valueOf(UserSalesforce.USER_NUM_Numero_Solicitud__c.round());
        }     
        
        if(UserSalesforce.USER_TXT_OPERA_HIDDEN__c != null)
        {
          client.Upd=UserSalesforce.USER_TXT_OPERA_HIDDEN__c;
        }        
        
        
        client.Ktokd=Label.ZEMP;
        client.Brsch=Label.ZEMP;
        
        System.debug('Enviado a SAP el Usuario ==================================> ' + client);
        return client;
    }

    
    webservice static String invokeUser(List<Id> UserId) {
        
        
        if(UserId == null)
        {
            return 'error';
        }
          
        
        // create management object 
        sapCreateClientSoapFunctionsMcS sapElement = new sapCreateClientSoapFunctionsMcS(); 
        
        // Object response WS 
        sapCreateClientSoapFunctionsMcS.Z017vClientesWsSfResponse_element element = new sapCreateClientSoapFunctionsMcS.Z017vClientesWsSfResponse_element();  
        // Object in WS
        sapCreateClientSoapFunctionsMcS.TableOfZ017vClientesWsSf request = new sapCreateClientSoapFunctionsMcS.TableOfZ017vClientesWsSf();
       
        request.item = new list<sapCreateClientSoapFunctionsMcS.Z017vClientesWsSf>();
        
        for(User u :getUserSalesforce(UserId) )
        {
            request.item.add(UserClient(u));
        }
        
        if(request.item.size() == 0){
            return 'Error no se ha encontrado usuario';
        }
        
        sapCreateClientSoapFunctionsMcS.TableOfZ017vWsSfLog logSAP = new sapCreateClientSoapFunctionsMcS.TableOfZ017vWsSfLog();
        
        sapCreateClientSoapFunctionsMcS.Z017V_CLIENTES_SF invokeSAP =  new sapCreateClientSoapFunctionsMcS.Z017V_CLIENTES_SF();
        invokeSAP.inputHttpHeaders_x = new Map<String,String>();
        invokeSAP.inputHttpHeaders_x.put('Authorization', Label.InfAuthorization);
        invokeSAP.inputHttpHeaders_x.put('Content-Type',Label.UTF8);
       
        //   Invocamos a SAP
        System.debug('Enviamos la peticion USUARIO a SAP!!!!!!!!!!!!!!!!!!!!!!!!');
        try
        {
            if (Label.IntegracionSAPUser == '1')
        	{
            	element=invokeSAP.Z017vClientesWsSf( request, logSAP);
            }   
        }catch(Exception e)
        {
           System.debug(e);
        }
        System.debug('Fin de envío de la peticion a SAP!!!!!!!!!!!!!!!!!!!!!!!!');
       
        return null;
    }
}