global class cloneCircuito {
    
    webservice static String cloneCircuito(Id opportunityId) {
        String resultMessages= 'SUCCESS';
        /*  AQUA_CIRCUITO_APROBACION_OFERTAS__c copyCircuito = new AQUA_CIRCUITO_APROBACION_OFERTAS__c();
        AQUA_Sociedad_Ofertante__c sociedadOfertante;
        Oportunidad_Producto__c oppProd;
        Account cuenta;
        Aqua_Lista_Aprobador__c liderOferta;
        AQUA_CIRCUITO_APROBACION_OFERTAS__c listaCircuitos;
        Opportunity opp;
       
        opp = [SELECT OPO_LKP_Sociedad_Ofertante__c, COM_LKP_Lider_oferta__c, AccountId, cloneCheck__c, StageName FROM Opportunity WHERE Id =:opportunityId];
        sociedadOfertante = [SELECT Id, COM_BOL_Sociedad_SASE__c FROM AQUA_Sociedad_Ofertante__c WHERE ID = :opp.OPO_LKP_Sociedad_Ofertante__c];
        cuenta = [SELECT Id, COM_SEL_Ramo__c, COM_SEL_Mercado_alto_nivel__c  FROM Account WHERE Id =:opp.AccountId];
        oppProd = [SELECT Id, OpProd_SEL_Nodo_Dominio__c, OP_TXT_Departamento__c FROM Oportunidad_Producto__c WHERE OP_MD_Oportunidad__c =:opportunityId LIMIT 1];
        listaCircuitos = [SELECT Id, Name, COM_SEL_Estado_Proceso__c, COM_SEL_Motivo_No_Necesaria__c FROM AQUA_CIRCUITO_APROBACION_OFERTAS__c WHERE COM_LKP_Opportunity__c =:opportunityId ORDER BY Name Desc LIMIT 1];
        if(opp.COM_LKP_Lider_oferta__c == null){
        //          liderOferta = [SELECT Id, Lider_de_Oferta__c FROM Aqua_Lista_Aprobador__c WHERE Departamento__c INCLUDES (:oppProd.OP_TXT_Departamento__c) AND Mercado_Alto_Nivel__c = 'Lider de Oferta'];
            liderOferta = [SELECT Id, Lider_de_Oferta__c FROM Aqua_Lista_Aprobador__c WHERE Departamento__c INCLUDES (:oppProd.OP_TXT_Departamento__c) AND Dominio_Lista_Aprobadores__c INCLUDES (:oppProd.OpProd_SEL_Nodo_Dominio__c) AND Mercado_Alto_Nivel__c INCLUDES ('Lider de Oferta')];
            //liderOferta = [SELECT Id, Lider_de_Oferta__c FROM Aqua_Lista_Aprobador__c WHERE Departamento__c INCLUDES (:oppProd.OP_TXT_Departamento__c) AND Dominio_Lista_Aprobadores__c INCLUDES (:oppProd.OpProd_SEL_Nodo_Dominio__c) AND Mercado_Multi__c INCLUDES ('Lider de Oferta')];
        }
        
        if(opp.StageName == 'En elaboración oferta' && (listaCircuitos.COM_SEL_Estado_Proceso__c == 'Rechazada' || listaCircuitos.COM_SEL_Estado_Proceso__c == 'No necesaria' || listaCircuitos.COM_SEL_Estado_Proceso__c == 'Aprobada')){
            if(opp.COM_LKP_Lider_oferta__c == null){
                opp.COM_LKP_Lider_oferta__c = liderOferta.Lider_de_Oferta__c;
            }
            if( opp.cloneCheck__c == false){
                opp.cloneCheck__c = true;
            }else if (opp.cloneCheck__c == true){
                opp.cloneCheck__c = false;
            }
            update opp;
            //resultMessages = 'El circuito se ha reiniciado de manera correcta';
            resultMessages = 'SUCCESS';
        }else {
            //resultMessages = 'El circuito actual se encuentra "Aprobado" o en un estado no compatible con su reinicio';
            //opp.addError('El circuito actual se encuentra "Aprobado" o en un estado no compatible con su reinicio');  
            resultMessages = 'ERROR';
        }*/
        
        
        return resultMessages;
    }

    @AuraEnabled
    webservice static String circuitoGeneraPdf(Id circuitoId) {
        String resultMessages;
        List<Attachment> listaPDF = new List<Attachment>();
        List<String> namePDF = new List<String>();
        AQUA_CIRCUITO_APROBACION_OFERTAS__c circuito = [SELECT Id, COM_SEL_Estado_Proceso__c, COM_SEL_Cualificacion__c, COM_LKP_Opportunity__c, Name, COM_LKP_Lider_Oferta__c FROM AQUA_CIRCUITO_APROBACION_OFERTAS__c WHERE Id =:circuitoId];

        //Obtención de la página que da el formato
        PageReference pdfGeneracion = new PageReference('/apex/PDF_Proceso_Aprobacion_1');
        pdfGeneracion.getParameters().put('id', circuito.Id);
        
        //variable para almacenar información del PDF
        Blob datosPDF;
        if(!Test.isRunningTest()) datosPDF = pdfGeneracion.getContentAsPDF();
        else datosPDF = Blob.valueOf('Test de la clase');
        
        AQUA_CIRCUITO_APROBACION_OFERTAS__c oppId = [SELECT COM_LKP_Opportunity__c FROM AQUA_CIRCUITO_APROBACION_OFERTAS__c WHERE Id =:circuitoId];
        System.debug('Marta: '+oppId.COM_LKP_Opportunity__c);
        Opportunity oppo = [SELECT Id, Name,OPO_SEL_Estado_Proceso__c FROM Opportunity WHERE Id =:oppId.COM_LKP_Opportunity__c];
        System.debug('Marta: '+oppo.Id);
        /*contador*/
        //String nombre = 'Nota Aprobación_'+circuito.Name,Opportunity__c = circuito.Id;
        Integer contador=1;
        List<Adjuntos_Aprobacion__c> cont=New List<Adjuntos_Aprobacion__c>([SELECT Id FROM Adjuntos_Aprobacion__c where name like 'PDF nota sistema antiguo_%' and Opportunity__c =: oppo.Id]);
        for (Adjuntos_Aprobacion__c adjapro : cont){contador++;}
        
        Adjuntos_Aprobacion__c  adjaprob = new Adjuntos_Aprobacion__c(Name='PDF nota sistema antiguo_'+contador,Opportunity__c = oppo.Id);
        System.debug('MArta: '+adjaprob);
        /*contador*/

        if (String.isNotEmpty(adjaprob.Name)){
            insert adjaprob; 
            System.debug('Marta: '+adjaprob.Id);
            resultMessages='SUCCESS';
        } else{
            resultMessages='ERROR';
            System.debug('Marta_no insert:' +resultMessages);
        }
        
        Id adjaprobId = adjaprob.ID;
        listaPDF = [SELECT Name FROM Attachment WHERE Parent.Type = 'Adjuntos_Aprobacion__c' AND Name =: adjaprob.Name+'.pdf' AND ParentId =:adjaprobId];
        
        for(Attachment att : listaPDF) namePDF.add(att.Name);
        //if(namePDF.contains(/*circuito.COM_SEL_Cualificacion__c+'_'+*/adjaprob.Opportunity__r.Name +'.pdf') && namePDF.size() >= 1){            delete listaPDF;
        //}
        Attachment adjPDF = new Attachment(
            ParentId = adjaprobId,
            Body = datosPDF,
            Name = adjaprob.Name +'.pdf'
        );
        //creación del adjunto
        try {
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            conVer.PathOnClient = adjaprob.Name +'.pdf'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = adjaprob.Name +'.pdf'; // Display name of the files
            conVer.VersionData = datosPDF; // converting your binary string to Blog
            insert conVer; //Insert ContentVersion

            // First get the Content Document Id from ContentVersion Object
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            //create ContentDocumentLink  record 
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = adjaprobId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
            conDocLink.shareType = 'V';
            insert conDocLink;
        } catch (Exception e) {
            System.debug(e.getMessage());
            //resultMessages='ERROR';
        }
     
        /*listaPDF = [SELECT Name FROM Attachment WHERE Parent.Type = 'AQUA_CIRCUITO_APROBACION_OFERTAS__c' AND Name =:circuito.COM_SEL_Cualificacion__c+'_'+circuito.Name+'.pdf' AND ParentId =:circuito.Id];
        for(Attachment att : listaPDF){namePDF.add(att.Name);
        }
        if(namePDF.contains(circuito.COM_SEL_Cualificacion__c+'_'+circuito.Name+'.pdf') && namePDF.size() >= 1){delete listaPDF;
        }
        //creación del adjunto
        Attachment adjPDF = new Attachment(
            ParentId = circuito.Id,
            Body = datosPDF,
            Name = circuito.COM_SEL_Cualificacion__c+'_'+circuito.Name +'.pdf'
        );
        
        //if(!Test.isRunningTest()){
            if(adjPDF != null){
                if(circuito.COM_SEL_Estado_Proceso__c!='Iniciada' && circuito.COM_SEL_Estado_Proceso__c!='En curso'){insert adjPDF;
                    resultMessages='SUCCESS';
                }else{
                    resultMessages='ERROR';
                }   
            }
        //}*/
        return resultMessages;
    } 

    @AuraEnabled
    webservice static String opportunityPfdToFile(Id circuitoId) {
        String resultMessages;
        List<Id> users = new List<Id>();
        for(User user : [SELECT Id FROM user where Profile.Name='Comercial' AND Id =:UserInfo.getUserId() AND Id NOT IN (SELECT AssigneeId FROM PermissionSetAssignment where PermissionSet.Name =:'Lider_Tecnico_NA_new')]){
            users.add(user.Id);
        }
        if (users.size() > 0)resultMessages = 'USERERROR';
        else {
            List<Attachment> listaPDF = new List<Attachment>();
            List<String> namePDF = new List<String>();
        
            Opportunity circuito = [SELECT Id, Name,OPO_SEL_Estado_Proceso__c FROM Opportunity WHERE Id =:circuitoId];
            /*contador*/
            //String nombre = 'Nota Aprobación_'+circuito.Name,Opportunity__c = circuito.Id;
            Integer contador=1;
            List<Adjuntos_Aprobacion__c> cont=New List<Adjuntos_Aprobacion__c>([SELECT Id FROM Adjuntos_Aprobacion__c WHERE Name LIKE 'Nota Aprobación_%' AND Opportunity__c =: circuito.Id]);
            
            for (Adjuntos_Aprobacion__c adjapro : cont) contador++;
            String circuitoName = '';

            if(circuito.Name.length() > 61) circuitoName = circuito.Name.substring(0,60);
            else circuitoName = circuito.Name;

            Adjuntos_Aprobacion__c  adjaprob = new Adjuntos_Aprobacion__c(Name='Nota Aprobación_'+circuitoName+'_'+contador,Opportunity__c = circuito.Id);
            /*contador*/

            if(String.isNotEmpty(circuito.OPO_SEL_Estado_Proceso__c)){
                insert adjaprob; 
                System.debug(resultMessages);
                resultMessages='SUCCESS';}else{resultMessages='ERROR';
                System.debug(resultMessages);
            }
            
            Id adjaprobId = adjaprob.ID;

            //Obtención de la página que da el formato
            PageReference pdfGeneracion = new PageReference('/apex/PDF_Opportunity');
            pdfGeneracion.getParameters().put('id', circuito.Id);
            
            //variable para almacenar información del PDF
            Blob datosPDF;
            if(!Test.isRunningTest()) datosPDF = pdfGeneracion.getContentAsPDF();
            else datosPDF = Blob.valueOf('Test de la clase');
            
            listaPDF = [SELECT Name FROM Attachment WHERE Parent.Type = 'Adjuntos_Aprobacion__c' AND Name =:/*circuito.COM_SEL_Cualificacion__c+'_'+*/adjaprob.Name+'.pdf' AND ParentId =:adjaprobId];
            
            for(Attachment att : listaPDF) namePDF.add(att.Name);

            if(namePDF.contains(adjaprob.Opportunity__r.Name +'.pdf') && namePDF.size() >= 1) delete listaPDF;

            Attachment adjPDF = new Attachment(
                ParentId = adjaprobId,
                Body = datosPDF,
                Name = adjaprob.Name +'.pdf'
            );

            //creación del adjunto
            try {
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
                conVer.PathOnClient = adjaprob.Name +'.pdf'; // The files name, extension is very important here which will help the file in preview.
                conVer.Title = adjaprob.Name +'.pdf'; // Display name of the files
                conVer.VersionData = datosPDF; // converting your binary string to Blog
                insert conVer;    //Insert ContentVersion


                // First get the Content Document Id from ContentVersion Object
                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                //create ContentDocumentLink  record 
                ContentDocumentLink conDocLink = New ContentDocumentLink();
                conDocLink.LinkedEntityId = adjaprobId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
                conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
                conDocLink.shareType = 'V';
                insert conDocLink;
            } catch (Exception e) {
                System.debug(e.getMessage());
                //resultMessages='ERROR';
            }
        }
        return resultMessages;
    }
}