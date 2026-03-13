global class Util{       
    public Util(){
    }
    
    public static boolean recursivo = false;
    /*
    @future
    public static void setDirectorCuenta(List<Id> idsHijas, Id director, String internoExterno) {
        List<Account> hijas = [SELECT Id,COM_BOL_Inactiva__c FROM Account WHERE Id =: idsHijas];
        for(Account hija : hijas){
            if(hija.COM_BOL_Inactiva__c == false){ 
                
                
            }
        }
        upsert hijas;
    }
    */
    /*@future
    public static void callAddOpportunities(list<Id> idsLsu){
        TriggerPOApexSharing permisos = new TriggerPOApexSharing();
        list<AQUA_Linea_de_Servicio_de_Usuario__c> lineas = [SELECT Id,LSU_LKP_Linea_de_Servicio__c,LSU_LKP_Usuario__c FROM AQUA_Linea_de_Servicio_de_Usuario__c WHERE Id IN: idsLsu];
        system.debug('Elimino permisos');
        permisos.delOpportunities(lineas);
        system.debug('Doy permisos');
        permisos.addOpportunities(lineas);
    }*/
    
    // Método que calcula el nombre único de Sub-Ámbito para buscador de productos. Debe llamarse After update/ after insert
    public static void calculoNombreUnicoProductoTec (list<Tecnologia__c> tec){
        list<SubAmbito__c> listSub = new list<SubAmbito__c>();
        for (SubAmbito__c sub : [SELECT id, SA_TXT_Nombre_unico__c, SA_LKP_Tecnologia__c, SA_LKP_Tecnologia__r.Name, 
                                SA_LKP_Tecnologia__r.Tec_NUM_Codigo__c, SA_LKP_Tecnologia__r.Tec_TXT_Codigo_SAP__c, 
                                LKP_Producto_Aqualogy__c, LKP_Producto_Aqualogy__r.Name, LKP_Producto_Aqualogy__r.PROD_IDENTIFICADOR_SAP__c, 
                                LKP_Producto_Aqualogy__r.Prod_TXT_Codigo_Salesforce__c 
                                FROM SubAmbito__c WHERE SA_LKP_Tecnologia__c IN: tec]){
            sub.SA_TXT_Nombre_unico__c = sub.LKP_Producto_Aqualogy__r.Name +' / '+ sub.LKP_Producto_Aqualogy__r.Prod_TXT_Codigo_Salesforce__c +' / '+sub.LKP_Producto_Aqualogy__r.PROD_IDENTIFICADOR_SAP__c+' / '+sub.SA_LKP_Tecnologia__r.Name+' / '+sub.SA_LKP_Tecnologia__r.Tec_NUM_Codigo__c+' / '+sub.SA_LKP_Tecnologia__r.Tec_TXT_Codigo_SAP__c;listSub.add(sub);
        }
        Util.recursivo = true;
        Database.saveResult[] results = Database.update(listSub,false);
    }
    
    // Método que calcula el nombre único de Sub-Ámbito para buscador de productos. Debe llamarse After update/ after insert
    public static void calculoNombreUnicoProductoAqProd (list<Producto__c> prod){
        list<SubAmbito__c> listSub = new list<SubAmbito__c>();
        for (SubAmbito__c sub : [SELECT id, SA_TXT_Nombre_unico__c, Name, SA_LKP_Tecnologia__c, SA_LKP_Tecnologia__r.Name, 
                                SA_LKP_Tecnologia__r.Tec_NUM_Codigo__c, SA_LKP_Tecnologia__r.Tec_TXT_Codigo_SAP__c, 
                                LKP_Producto_Aqualogy__c, LKP_Producto_Aqualogy__r.Name, LKP_Producto_Aqualogy__r.PROD_IDENTIFICADOR_SAP__c, 
                                LKP_Producto_Aqualogy__r.Prod_TXT_Codigo_Salesforce__c 
                                FROM SubAmbito__c WHERE LKP_Producto_Aqualogy__c IN: prod]){
            sub.SA_TXT_Nombre_unico__c = sub.LKP_Producto_Aqualogy__r.Name +' / '+ sub.LKP_Producto_Aqualogy__r.Prod_TXT_Codigo_Salesforce__c +' / '+sub.LKP_Producto_Aqualogy__r.PROD_IDENTIFICADOR_SAP__c+' / '+sub.SA_LKP_Tecnologia__r.Name+' / '+sub.SA_LKP_Tecnologia__r.Tec_NUM_Codigo__c+' / '+sub.SA_LKP_Tecnologia__r.Tec_TXT_Codigo_SAP__c;
            if (sub.Name != sub.LKP_Producto_Aqualogy__r.Name) sub.Name = sub.LKP_Producto_Aqualogy__r.Name;listSub.add(sub);
        }
        Util.recursivo = true;
        Database.saveResult[] results = Database.update(listSub,false);
    }
}