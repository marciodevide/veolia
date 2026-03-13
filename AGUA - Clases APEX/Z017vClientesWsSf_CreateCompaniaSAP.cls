global with sharing class Z017vClientesWsSf_CreateCompaniaSAP {
    
    public class cifException extends Exception{}   
    
    @future (callout=true)
    webservice static void invokeFuturo(List<Id> accountId, String action) {
       invoke(accountId, action, false);
    }
    
    @future (callout=true)
    webservice static void invokeExtension(List<Id> accountId, String action) {
       invoke(accountId, action, true);
    }
    
    webservice static String invokeSingle(Id accountId , String action){
        List<Id> listId = new List<Id>();
        listId.add(accountId);

        System.debug('Recibida la invocacion Creacion Clientes desde JavaScript!!!!!!!!!!');
        String callback = invoke(listId, action, false);
        Account accInvoke=[Select ID, COM_SEL_Estado__c from Account where id =:accountId Limit 1];
        if (accInvoke.COM_SEL_Estado__c == Label.estado_error_enviado_a_sap) callback='ERROR';

        return callback;
     }
     

    
    webservice static String invokeModify(Id accountId, String action){
        Account acc =[Select Campos_pendiente_de_envio_SAP__c from account where id =:accountId Limit 1];
        String campos;
        //if(acc.Campos_pendiente_de_envio_SAP__c == null ||acc.Campos_pendiente_de_envio_SAP__c=='' ){
        //    campos = 'Select name,COM_TXT_Numero_Compania_SAP__c,COM_TXT_HIDDEN_SOCIEDAD__c,Sociedad_Ofertante__r.EMP_TXT_IdSAP__c, COM_BOL_Compania_fiscal__c,COM_NUM_Codigo__c from account where id =  :accountId';
        //}else{
        //    campos = 'Select ' + acc.Campos_pendiente_de_envio_SAP__c + ',name,COM_TXT_Numero_Compania_SAP__c, COM_TXT_HIDDEN_SOCIEDAD__c,Sociedad_Ofertante__r.EMP_TXT_IdSAP__c, COM_BOL_Compania_fiscal__c,COM_NUM_Codigo__c from account where id =  :accountId';
        //}
        //if(Test.isRunningTest()){
            campos = 'Select name,COM_TXT_Motivo_Bloqueo__c, COM_BOL_Compania_bloqueado__c, COM_SEL_Estado_Solicitud_Modificacion__c,COM_TXT_Solicitud_Modificacion__c,Nombre_2__c,COM_TXT_Correo_electronico__c,fax,phone,COM_FOR_Codigo_ramo1__c,COM_FOR_Ramo__c,COM_FOR_Divisa__c,COM_FOR_NIF_CIF__c,COM_LKP_Pais__c,COM_LKP_Pais__r.PA_TXT_Codigo_Pais_SAP__c,COM_TXT_Codigo_Postal__c,COM_FOR_Provincia__c,COM_LKP_Municipio__r.name,COM_TXT_Domicilio__c,COM_TXT_Calle_2__c,COM_TXT_Numero_Compania_SAP__c,COM_LKP_Municipio__c,COM_TXT_HIDDEN_SOCIEDAD__c,Sociedad_Ofertante__r.EMP_TXT_IdSAP__c, COM_BOL_Compania_fiscal__c,COM_NUM_Codigo__c,COM_SEL_Estado__c from account where id =  :accountId';
        //}
        System.debug('La select que lanzo es ' + campos);
        Account accInvoke = Database.query(campos);
        accInvoke.ACC_TXT_OPERA_HIDDEN__c='U'; 
        accInvoke.OCUL_BOOL_OrigenPeticion__c=false; 
        accInvoke.Campos_pendiente_de_envio_SAP__c='';
        accInvoke.COM_SEL_Estado_Solicitud_Modificacion__c = Label.Enviada_a_SAP;
        System.debug('La compañia que se quiere modificar tiene la siguiente pinta'+  accInvoke);
        
        String callback = invokeAcc(accInvoke);
          
        Account accError =[Select COM_SEL_Estado_Solicitud_Modificacion__c from Account where id =:accountId Limit 1];
        
        if (accError.COM_SEL_Estado_Solicitud_Modificacion__c == Label.estado_error_enviado_a_sap) callback='ERROR';
          
        return callback;
    }
        
    webservice static String invoke(List<Id> accountId, String action, Boolean isExtension) {        
        if(accountId == null) return 'error';
        
        // create management object 
        sapCreateClientSoapFunctionsMcS sapElement = new sapCreateClientSoapFunctionsMcS(); 
        
        // Object response WS 
        sapCreateClientSoapFunctionsMcS.Z017vClientesWsSfResponse_element element = new sapCreateClientSoapFunctionsMcS.Z017vClientesWsSfResponse_element();  
        // Object in WS
        sapCreateClientSoapFunctionsMcS.TableOfZ017vClientesWsSf request = new sapCreateClientSoapFunctionsMcS.TableOfZ017vClientesWsSf();
       
        request.item = new list<sapCreateClientSoapFunctionsMcS.Z017vClientesWsSf>();
        
        for(Account a :getClientSalesforce(accountId)){
            if(isExtension) request.item.add(accountExtension(a,action));
            else request.item.add(accountClient(a,action));
                
            System.debug('Preparo integracion para la cuenta' + a + ' La lista tiene el siguiente formato ' + request.item);
        }
        if(request.item.size() == 0) return 'Error no se ha encontrado cliente para ser modificado';
        
        sapCreateClientSoapFunctionsMcS.TableOfZ017vWsSfLog logSAP = new sapCreateClientSoapFunctionsMcS.TableOfZ017vWsSfLog();
        
        sapCreateClientSoapFunctionsMcS.Z017V_CLIENTES_SF invokeSAP =  new sapCreateClientSoapFunctionsMcS.Z017V_CLIENTES_SF();
        invokeSAP.inputHttpHeaders_x = new Map<String,String>();
        invokeSAP.inputHttpHeaders_x.put('Authorization', Label.InfAuthorization);
        invokeSAP.inputHttpHeaders_x.put('Content-Type',Label.UTF8);
       
        //   Invocamos a SAP
        System.debug('Enviamos la peticion a SAP!!!!!!!!!!!!!!!!!!!!!!!!');
        if (Label.IntegracionSAPComp == '1') {
            try {
                element=invokeSAP.Z017vClientesWsSf( request, logSAP);
                System.debug('************** invoke RESPUESTA SAP: '+ element);
            }catch(Exception e) {
                System.debug(e);
            }  
        }
        System.debug('Fin de envío de la peticion a SAP!!!!!!!!!!!!!!!!!!!!!!!!');
       
        return null;
    }




    webservice static String invokeListAcc(List<account> Listccount) {
        if(Listccount== null || Listccount.size()== 0) return 'error';
          
        
        // create management object 
        sapCreateClientSoapFunctionsMcS sapElement = new sapCreateClientSoapFunctionsMcS(); 
        
        // Object response WS 
        sapCreateClientSoapFunctionsMcS.Z017vClientesWsSfResponse_element element = new sapCreateClientSoapFunctionsMcS.Z017vClientesWsSfResponse_element();  
        // Object in WS
        sapCreateClientSoapFunctionsMcS.TableOfZ017vClientesWsSf request = new sapCreateClientSoapFunctionsMcS.TableOfZ017vClientesWsSf();
       
        request.item = new list<sapCreateClientSoapFunctionsMcS.Z017vClientesWsSf>();
        
        for(Account a :Listccount){
            request.item.add(accountClient(a,a.ACC_TXT_OPERA_HIDDEN__c));
            a.OCUL_BOOL_OrigenPeticion__c = false;
            System.debug('Preparo integracion para la cuenta' + a);
        }
        if(request.item.size() == 0) return 'Error no se ha encontrado cliente para ser modificado';
        
        sapCreateClientSoapFunctionsMcS.TableOfZ017vWsSfLog logSAP = new sapCreateClientSoapFunctionsMcS.TableOfZ017vWsSfLog();
        
        sapCreateClientSoapFunctionsMcS.Z017V_CLIENTES_SF invokeSAP =  new sapCreateClientSoapFunctionsMcS.Z017V_CLIENTES_SF();
        invokeSAP.inputHttpHeaders_x = new Map<String,String>();
        invokeSAP.inputHttpHeaders_x.put('Authorization', Label.InfAuthorization);
        
       
        // Invocamos a SAP
        try {
            if (Label.IntegracionSAPComp == '1') {
                element=invokeSAP.Z017vClientesWsSf( request, logSAP);
                System.debug('************** invokeListAcc RESPUESTA SAP: '+ element);
            }
        }catch(Exception e) {
            System.debug(e);
        }
       
        return null;
    } 
    
    private static List<Account> getClientSalesforce(list<Id> accountId){
         return [SELECT COM_NUM_Numero_Solicitud__c, COM_NUM_Codigo__c, COM_TXT_Numero_Compania_SAP__c, COM_SEL_Estado__c,
                 COM_TXT_Grupo_de_cuentas_SAP__c,name,Nombre_2__c,COM_TXT_Domicilio__c,COM_TXT_Calle_2__c,COM_LKP_Municipio__r.name,
                 COM_FOR_Provincia__c ,COM_LKP_Pais__r.PA_TXT_Codigo_Pais_SAP__c,COM_TXT_Codigo_Postal__c,
                 COM_FOR_Divisa__c,COM_FOR_NIF_CIF__c,COM_FOR_Ramo__c,COM_FOR_Codigo_ramo1__c,phone,fax,COM_TXT_Correo_electronico__c,
                 COM_TXT_Solicitud_Modificacion__c,COM_LKP_Responsable_comercial_Lab__r.USER_TXT_Identificador_SAP__c,
                 COM_SEL_Estado_Solicitud_Modificacion__c,COM_FOR_Codigo_via_pago__c, COM_FOR_Condicion_pago__c, COM_BOL_Compania_bloqueado__c,
                 COM_TXT_Motivo_Bloqueo__c,COM_BOL_Compania_fiscal__c,COM_TXT_HIDDEN_SOCIEDAD__c, Sociedad_Ofertante__r.EMP_TXT_IdSAP__c,id, COM_HIDDEN_TXT_Condicion_pago__c, 
                 COM_HIDDEN_TXT_Codigo_via_pago__c  FROM Account WHERE id IN :accountId];    
    }
    
    private static sapCreateClientSoapFunctionsMcS.Z017vClientesWsSf accountExtension(Account clientSalesforce, String action){
        
        sapCreateClientSoapFunctionsMcS.Z017vClientesWsSf client = new sapCreateClientSoapFunctionsMcS.Z017vClientesWsSf();
        if(action != null) client.Upd=action;
        
        System.debug('*********** client.Upd ' + client.Upd); 	
        
        if(clientSalesforce.COM_SEL_Estado_Solicitud_Modificacion__c!= null) client.StatusSf=Label.Enviada_SAP;  
        /*if(clientSalesforce.COM_NUM_Numero_Solicitud__c != null)
         client.Solic=String.valueOf(clientSalesforce.COM_NUM_Numero_Solicitud__c.round());*/
        Integer NumSol =UtilAcc.ObtenerMaxNumSolic();
        client.Solic=String.valueOf(NumSol);
        System.debug('*********** client.Solic ' + client.Solic); 	
        
        if(clientSalesforce.COM_TXT_HIDDEN_SOCIEDAD__c!= null) client.Vkorg=clientSalesforce.COM_TXT_HIDDEN_SOCIEDAD__c;  
        if(clientSalesforce.COM_NUM_Codigo__c != null) client.ZzsfdcAcc=clientSalesforce.COM_NUM_Codigo__c;  // Numero cliente Salesforce
        
        if(clientSalesforce.COM_BOL_Compania_fiscal__c!= null) {
           System.debug('*********** clientSalesforce.COM_BOL_Compania_fiscal__c ' + clientSalesforce.COM_BOL_Compania_fiscal__c);
         
            if(clientSalesforce.COM_BOL_Compania_fiscal__c == true) client.Ktokd='ZCEN';
            else client.Ktokd='ZSOL';
                    
            System.debug('*********** client.Ktokd' + client.Ktokd);        
        }
 
        if(clientSalesforce.name!= null) client.Name1=clientSalesforce.name;
        
        if(clientSalesforce.COM_TXT_Numero_Compania_SAP__c!= null) client.Kunnr=clientSalesforce.COM_TXT_Numero_Compania_SAP__c; 
        
        return client;
    }
    
    private static sapCreateClientSoapFunctionsMcS.Z017vClientesWsSf accountClient (Account clientSalesforce, String action){
        sapCreateClientSoapFunctionsMcS.Z017vClientesWsSf client = new sapCreateClientSoapFunctionsMcS.Z017vClientesWsSf();
        
        // indicamos que el origen de la peticion en Salesforce, para ello se pone el campo siguiente a true
        
        
        // mapping client
        //if(clientSalesforce.COM_NUM_Numero_Solicitud__c != null)
        //client.Solic=String.valueOf(clientSalesforce.COM_NUM_Numero_Solicitud__c.round());
        Integer NumSol =UtilAcc.ObtenerMaxNumSolic();
        client.Solic=String.valueOf(NumSol);
        System.debug('*********** client.Solic ' + client.Solic); 	

        if(action != null) client.Upd=action;
            
        if(clientSalesforce.COM_NUM_Codigo__c != null) client.ZzsfdcAcc=clientSalesforce.COM_NUM_Codigo__c;  // Numero cliente Salesforce
        System.debug('*********** client.ZzsfdcAcc ' + client.ZzsfdcAcc); 
            
        if(clientSalesforce.COM_TXT_Numero_Compania_SAP__c!= null) client.Kunnr=clientSalesforce.COM_TXT_Numero_Compania_SAP__c; // Numero de compañia SAP
        System.debug('*********** clientSalesforce '+ clientSalesforce);
        if(clientSalesforce.COM_SEL_Estado__c!= null) client.StatusSap=Label.Enviada_SAP;

        if(clientSalesforce.COM_BOL_Compania_fiscal__c!= null) {
           System.debug('*********** clientSalesforce.COM_BOL_Compania_fiscal__c ' + clientSalesforce.COM_BOL_Compania_fiscal__c);
        
            if(clientSalesforce.COM_BOL_Compania_fiscal__c == true) client.Ktokd='ZCEN';
            else client.Ktokd='ZSOL';
                    
            System.debug('*********** client.Ktokd' + client.Ktokd);        
        }
        System.debug('*********** clientSalesforce.name ' + clientSalesforce.name);  
        if(clientSalesforce.name!= null) client.Name1=clientSalesforce.name;
        
        if(clientSalesforce.Nombre_2__c!= null) client.Name2=clientSalesforce.Nombre_2__c;
    
        if(clientSalesforce.COM_TXT_Domicilio__c!= null) client.Stras=clientSalesforce.COM_TXT_Domicilio__c;
        
        if(clientSalesforce.COM_TXT_Calle_2__c!= null) client.Stras2=clientSalesforce.COM_TXT_Calle_2__c;
        
        
        if(clientSalesforce.COM_LKP_Municipio__c!=null && clientSalesforce.COM_LKP_Municipio__r.name!= null) {
          client.Ort01=clientSalesforce.COM_LKP_Municipio__r.name.left(40);
          client.Ort01 = clientSalesforce.COM_LKP_Municipio__r.name.replaceAll('\\P{InBasic_Latin}','?');
        }
        
        if (clientSalesforce.COM_LKP_Municipio__c!=null && clientSalesforce.COM_LKP_Municipio__r.name == null) {
            AQUA_Municipio__c Muni = [SELECT Name FROM AQUA_Municipio__c WHERE ID =: clientSalesforce.COM_LKP_Municipio__c]; 
            if (Muni.Name != null) {
            	client.Ort01=Muni.name.left(40);
                client.Ort01 = client.Ort01.replaceAll('\\P{InBasic_Latin}','?');
            }
        }    
        System.debug('El municipio es: '+client.Ort01);
        /* if(clientSalesforce.COM_LKP_Provincia__c!=null && clientSalesforce.COM_LKP_Provincia__r.PRO_TXT_Codigo_Provincia_SAP__c!= null)
         client.Regio=clientSalesforce.COM_LKP_Provincia__r.PRO_TXT_Codigo_Provincia_SAP__c;*/
        if(clientSalesforce.COM_FOR_Provincia__c!=null) {
            System.debug('*********** clientSalesforce.COM_FOR_Provincia__c: ' + clientSalesforce.COM_FOR_Provincia__c); 
            String Provincia = String.valueOf(clientSalesforce.COM_FOR_Provincia__c);
            provincia = provincia.replaceAll('\\P{InBasic_Latin}','');
            provincia = provincia.removeEnd(' ');
            System.debug('El provincia es: '+provincia);
            List <AQUA_Provincia__c> lsProv = [select ID, PRO_TXT_Codigo_Provincia_SAP__c from  AQUA_Provincia__c where name =: Provincia LIMIT 1];
            
            if (lsProv.size() > 0){
                if ((lsProv[0].PRO_TXT_Codigo_Provincia_SAP__c != null) && (lsProv[0].PRO_TXT_Codigo_Provincia_SAP__c != '')){
                    client.Regio=lsProv[0].PRO_TXT_Codigo_Provincia_SAP__c;
                    System.debug('*********** client.Regio: ' + client.Regio);  
                }
            }
        }
        
        if(clientSalesforce.COM_LKP_Pais__c!=null && clientSalesforce.COM_LKP_Pais__r.PA_TXT_Codigo_Pais_SAP__c!= null)
           client.Land1=clientSalesforce.COM_LKP_Pais__r.PA_TXT_Codigo_Pais_SAP__c;
        
        if(clientSalesforce.COM_TXT_Codigo_Postal__c!= null)
            client.Pstlz=clientSalesforce.COM_TXT_Codigo_Postal__c;
        
        if(clientSalesforce.COM_FOR_Divisa__c!= null)
            client.Waers=clientSalesforce.COM_FOR_Divisa__c;
        
        if(clientSalesforce.COM_FOR_NIF_CIF__c!= null)
            client.Stcd1=clientSalesforce.COM_FOR_NIF_CIF__c;
        
        if(clientSalesforce.COM_FOR_Ramo__c!= null)
          client.Brsch=clientSalesforce.COM_FOR_Ramo__c;
        
        if(clientSalesforce.COM_FOR_Codigo_ramo1__c!= null)
            client.Bran1=clientSalesforce.COM_FOR_Codigo_ramo1__c;
        
        if(clientSalesforce.phone!= null)
            client.Telf1=clientSalesforce.phone.left(16);
        
        if(clientSalesforce.fax!= null)
            client.Telfx=clientSalesforce.fax;
        
        if(clientSalesforce.COM_TXT_Correo_electronico__c!= null)
            client.SmtpAddr=clientSalesforce.COM_TXT_Correo_electronico__c;
        
        System.debug('*********** clientSalesforce.Sociedad_Ofertante__r.EMP_TXT_IdSAP__c ' + clientSalesforce.Sociedad_Ofertante__r.EMP_TXT_IdSAP__c);  
        
        if(clientSalesforce.COM_TXT_HIDDEN_SOCIEDAD__c != null) client.Vkorg=clientSalesforce.COM_TXT_HIDDEN_SOCIEDAD__c;
        else if(clientSalesforce.Sociedad_Ofertante__r.EMP_TXT_IdSAP__c != null) client.Vkorg=clientSalesforce.Sociedad_Ofertante__r.EMP_TXT_IdSAP__c;
        
        if(clientSalesforce.COM_TXT_Solicitud_Modificacion__c!= null)
            client.Notas=clientSalesforce.COM_TXT_Solicitud_Modificacion__c;
            
        if(clientSalesforce.COM_SEL_Estado_Solicitud_Modificacion__c!= null)
           client.StatusSf=Label.Enviada_SAP;  
        
        //if(clientSalesforce.COM_HIDDEN_TXT_Codigo_via_pago__c!= null) {
        //    System.debug(' Enviamos VIA PAGO OPORTUNIDAD' + clientSalesforce.COM_HIDDEN_TXT_Codigo_via_pago__c);
            //client.Zlsch=clientSalesforce.COM_HIDDEN_TXT_Codigo_via_pago__c;
        //}else { 
        //    if(clientSalesforce.COM_FOR_Codigo_via_pago__c!= null){
                //client.Zlsch=clientSalesforce.COM_FOR_Codigo_via_pago__c;
        //    } 
        //}
        
        //if(clientSalesforce.COM_HIDDEN_TXT_Condicion_pago__c!= null) {
        //    System.debug(' Enviamos CONDICION DE PAGO OPORTUNIDAD' + clientSalesforce.COM_HIDDEN_TXT_Condicion_pago__c);
            //client.Zterm=clientSalesforce.COM_HIDDEN_TXT_Condicion_pago__c;
        //}else {
        //    if(clientSalesforce.COM_FOR_Condicion_pago__c!= null){
                //client.Zterm=clientSalesforce.COM_FOR_Condicion_pago__c;
        //    }
        //}
        if(clientSalesforce.COM_BOL_Compania_bloqueado__c!= null){
            if(clientSalesforce.COM_BOL_Compania_bloqueado__c == true) client.Aufsd='0';
            else client.Aufsd='1';
        }
        
        if(clientSalesforce.COM_TXT_Motivo_Bloqueo__c!= null)
            client.Vtext=clientSalesforce.COM_TXT_Motivo_Bloqueo__c;
        
       if(clientSalesforce.COM_BOL_Compania_fiscal__c!= null) {
            if(clientSalesforce.COM_BOL_Compania_fiscal__c == true) client.Central='1';
            else client.Central='0';   /// Fiscal
            System.debug('*********** client.Central' + client.Central);
       }
        
        System.debug('Enviado a SAP el cliente ==================================> ' + client);
        return client;
    }
    
    

    webservice static String invokeAcc(Account AccountJS) {
        if(AccountJS== null) return 'error';
        
        // create management object 
        sapCreateClientSoapFunctionsMcS sapElement = new sapCreateClientSoapFunctionsMcS(); 
        
        // Object response WS 
        sapCreateClientSoapFunctionsMcS.Z017vClientesWsSfResponse_element element = new sapCreateClientSoapFunctionsMcS.Z017vClientesWsSfResponse_element();  
        // Object in WS
        sapCreateClientSoapFunctionsMcS.TableOfZ017vClientesWsSf request = new sapCreateClientSoapFunctionsMcS.TableOfZ017vClientesWsSf();
       
        request.item = new list<sapCreateClientSoapFunctionsMcS.Z017vClientesWsSf>();
        
        request.item.add(accountClient(AccountJS,AccountJS.ACC_TXT_OPERA_HIDDEN__c));
        AccountJS.OCUL_BOOL_OrigenPeticion__c = false;
        
        if(request.item.size() == 0) return 'Error no se ha encontrado cliente para ser modificado';
        
        sapCreateClientSoapFunctionsMcS.TableOfZ017vWsSfLog logSAP = new sapCreateClientSoapFunctionsMcS.TableOfZ017vWsSfLog();
        sapCreateClientSoapFunctionsMcS.Z017V_CLIENTES_SF invokeSAP =  new sapCreateClientSoapFunctionsMcS.Z017V_CLIENTES_SF();
        invokeSAP.inputHttpHeaders_x = new Map<String,String>();
        invokeSAP.inputHttpHeaders_x.put('Authorization', Label.InfAuthorization);
        
        //   Invocamos a SAP
        try {
            if (Label.IntegracionSAPComp == '1') {
                element=invokeSAP.Z017vClientesWsSf( request, logSAP);
                //update(Listccount);
                System.debug('************** invokeAcc RESPUESTA SAP: '+ element);
            }
        }catch(Exception e) {
            System.debug(e);
        }
       
        return null;
    }
}