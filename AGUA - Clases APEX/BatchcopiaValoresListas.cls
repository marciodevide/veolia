// El batch se encarga de rellenar los campos de "Oportunidad de producto" que dependen de los productos
global class BatchcopiaValoresListas implements Database.Batchable<sObject>,Database.Stateful{
    
    public String query;
    global Map<Id,Producto__c> mapProd, mapProdOld;
    global Set<Id> setProducto;
    global datetime fechaLimite;
    global Set<Oportunidad_Producto__c> opErrorOp;
    global Set<String> opError;
    global List<Oportunidad_Producto__c> oppToUpdate;
    global List<Oportunidad_Producto__c> listOpProducto;
    
    // Se pasan los siguientes parámetros: query inicial del batch, el mapa con los productos, los valores antiguos de estos productos, la fecha actual
    global BatchcopiaValoresListas (String queryAux, Map<Id,Producto__c> mapProdAux, Map<Id,Producto__c> mapProdOldAux, Datetime fechaLimiteAux) {
        query = queryAux;
        mapProd = mapProdAux;
        mapProdOld = mapProdOldAux;
        setProducto = mapProdAux.KeySet();
        fechaLimite = fechaLimiteAux;
        oppToUpdate = new List<Oportunidad_Producto__c>();
        opErrorOp = new Set<Oportunidad_Producto__c>();
        opError = new Set<String>();
    }
    
    // La query inicial va a devolver las Oportunidades de producto que se deben modificar filtrando por fecha y limitando a 2000 (es el batch size)
    // El límite a 2000 es debido a que Salesforce no permite lanzar otro batch desde un método "Execute", por eso de updatean los campos de oportunidade de producto desde el método "finish".
    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator(query);
    }
    
    // Se debe tener en cuenta los límites de Salesforce, por lo que se limita a que devuelva como mucho 2.000 registros el "execute" (es el máximo Batch Size posible) y si aun hay oportunidades de producto por procesar se vuelve a lanzar este mismo batch desde el método "finish"
    global void execute(Database.BatchableContext context, List<sObject> records){        
        listOpProducto = records;
        //System.debug ('El número de records, de oportunidades de producto a procesar es: '+listOpProducto.size());
        
        //oppToUpdate = new List<Oportunidad_Producto__c>();
        
        // Si se cambia la línea de producto, el nombre del producto o la línea de servicio a la que está ligada el producto a procesar se modificarán las oportunidades de producto relacionadas.
        // Además se modifica la fecha de filtrado de la query
        System.debug('ME-mapProd: ' + mapProd);
        System.debug('ME-mapProdOld: ' + mapProdOld);
        for(Oportunidad_Producto__c opProd: listOpProducto){
            fechaLimite = opProd.CreatedDate;
            if((mapProd.containsKey(opProd.OP_LKP_Producto__c) && mapProdOld.containsKey(opProd.OP_LKP_Producto__c)) &&
            ((mapProd.get(opProd.OP_LKP_Producto__c).PROD_SEL_LineaProducto__c != mapProdOld.get(opProd.OP_LKP_Producto__c).PROD_SEL_LineaProducto__c) ||
            mapProd.get(opProd.OP_LKP_Producto__c).PROD_SEL_Producto__c != mapProdOld.get(opProd.OP_LKP_Producto__c).PROD_SEL_Producto__c ||
            mapProd.get(opProd.OP_LKP_Producto__c).PROD_LK_Linea_de_Servicio__c != mapProdOld.get(opProd.OP_LKP_Producto__c).PROD_LK_Linea_de_Servicio__c)){
                opProd.OP_SEL_Division__c = mapProd.get(opProd.OP_LKP_Producto__c).PROD_SEL_Linea_de_Servicio__c;
                opProd.OP_SEL_LineaProducto__c = mapProd.get(opProd.OP_LKP_Producto__c).PROD_SEL_LineaProducto__c;
                opProd.OP_SEL_Producto__c = mapProd.get(opProd.OP_LKP_Producto__c).PROD_SEL_Producto__c;
                opProd.OP_SEL_LineaServicio__c = mapProd.get(opProd.OP_LKP_Producto__c).PROD_SEL_Linea_de_Servicio__c; // Si se modifica este último el trigger "calculoOpportunityShare" lanzará el batch "BatchProcesarOportunidadesCompleto" que recalcula la visibilidad
                oppToUpdate.add(opProd);
            }
        }    
    }
    
    // Desde el método finish se updatean las oportunidades de producto porque puede llamar a otro batch desde aquí.
    // Si hay más de 2000 oportunidades de producto se volverá a lanzar este mismo batch.
    global void finish (Database.BatchableContext context) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:context.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail;
        
        // Si falla el batch o el update se enviará un correo a Everis
        if (a.Status == 'Failed' || a.NumberOfErrors>0) {
            //List<String> toAddresses = new List<String>();
            //toAddresses.add(label.AdminEverisEmail);
            mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String> {label.AdminEverisEmail});
            mail.setSubject('El account to opportunityShare ha fallado: ' + context.getJobId());
            mail.setPlainTextBody ('The batch Apex job processed ' + a.TotalJobItems +
            ' batches with '+ a.NumberOfErrors + ' failures. La lista de productos es: '+setProducto);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } 
            
        //Updateo las nuevas oportunidades
        Database.SaveResult[] srAdd = database.update(oppToUpdate,false);
        integer numError = 0;
        for (Database.SaveResult sr : srAdd) {
            if (sr.IsSuccess()){
                //System.debug('Operación satisfactoria: '+sr.getId());
                //System.debug('Ver si coincide lo insertado con lo de la lista'+sr.getId()+' : '+oppToUpdate[numError]);
            } else{
                for (Database.Error err: sr.getErrors()) {
                    //System.debug('The following error has ocurried: '+err);
                    //System.debug('The following error has ocurried during the insert:'+err.getStatusCode() + ': ' + err.getMessage());
                    opErrorOp.add(oppToUpdate[numerror]);
                    opError.add('Update: '+err.getStatusCode() + ': ' + err.getMessage());
                    //System.debug('Ver si coincide lo insertado con lo de la lista'+err+' : '+oppToUpdate[numError]);
                }
            }
            numError++;
        }
        if ((opErrorOp != null && opErrorOp.isEmpty()==false)) {            
            mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String> {label.AdminEverisEmail});
            mail.setSubject('Fallo al procesar los productos al updatear las oportunidades de producto');
            mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
            '\n\n El job id es: '+context.getJobId() +
            '\n\n La lista de oportunidades de producto es: '+opErrorOp+
            '\n\n La lista con los errores dados es: '+opError);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
        // Si hay más de 2000 Oportunidades de producto relacionadas con los productos que se han modificado se vuelve a lanzar este batch con la nueva fecha para filtrar y recuperar nuevas oportunidades de producto.  
        if (listOpProducto != null && listOpProducto.size() == 2000) {
           if (!Test.isRunningTest()) Id batchInstanceId = Database.executeBatch (new BatchcopiaValoresListas(query,mapProd,mapProdOld,fechaLimite),2000);
        }
    }
}