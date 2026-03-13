public class CreacionHija implements Triggers.Handler{ // Implementa la clase handler
    
    public void handle(){ // Utiliza la clase auxiliar para secuenciar el trigger

        /*Si se trata de una hija no se hace insert.Obtener el recod type de la hija*/
        //   if (!Test.isRunningTest()){
        String ObjectName = 'Account';
        String RTdevName = 'Compania_Hija';
        List<recordType> listaRT= new List<recordType>([SELECT Id FROM recordType WHERE developername=:RTdevName AND SobjectType=:ObjectName]);
        Id rtdid = null;

        if (listaRT.size() > 0) rtdid=listaRT.get(0).Id;

        List<AQUA_Pais__c> paisEspana = [SELECT Id FROM AQUA_Pais__c WHERE Name = 'Spain'];
        Id espana = paisEspana.get(0).Id;/*Creamos un lista de cuenta*/        
        List<Account> listaCuentas=Trigger.new;
        Map<String, String> mapeoCampos = new Map<String, String> {            
            'parentId' => 'id',                
            'name' => 'name',                
            'Nombre_2__c'=>'Nombre_2__c',  
            'COM_TXT_Grupo_de_cuentas_SAP__c'=>'COM_TXT_Grupo_de_cuentas_SAP__c',               
            'OCUL_BOOL_OrigenPeticion__c'=>'OCUL_BOOL_OrigenPeticion__c',                
            'ACC_TXT_OPERA_HIDDEN__c'=>'ACC_TXT_OPERA_HIDDEN__c',              
            'COM_TXT_NIFCIF__c' => 'COM_TXT_NIFCIF__c',              
            'COM_TXT_Nombre_comercial__c' => 'COM_TXT_Nombre_comercial__c',               
            'Description' => 'Description',                
            'COM_BOL_Inactiva__c' => 'COM_BOL_Inactiva__c',                
            'COM_SEL_Mercado_alto_nivel__c' => 'COM_SEL_Mercado_alto_nivel__c',                
            'COM_SEL_Mercado__c' => 'COM_SEL_Mercado__c',                
            'COM_SEL_Segmento__c' => 'COM_SEL_Segmento__c',                            
            'COM_SEL_Grupo__c' => 'COM_SEL_Grupo__c',  'Phone' => 'Phone',                
            'Fax' => 'Fax',                
            'COM_TXT_Correo_electronico__c' => 'COM_TXT_Correo_electronico__c',                
            'Website' => 'Website',
            'Codigo_INE__c' => 'Codigo_INE__c',
            'COM_LKP_Gerente_de_Cuenta__c' => 'COM_LKP_Gerente_de_Cuenta__c',
            'COM_LKP_Pais__c' => 'COM_LKP_Pais__c',                
            'COM_TXT_Domicilio__c' => 'COM_TXT_Domicilio__c', 
            'COM_TXT_Calle_2__c' => 'COM_TXT_Calle_2__c',               
            'COM_LKP_Municipio__c' => 'COM_LKP_Municipio__c',                  
            'COM_LKP_Provincia__c' => 'COM_LKP_Provincia__c',                   
            'COM_TXT_Codigo_Postal__c' => 'COM_TXT_Codigo_Postal__c',                
            'COM_TXT_Nombre_Poblacion__c' => 'COM_TXT_Nombre_Poblacion__c',    
            'COM_TXT_Domicilio2__c' => 'COM_TXT_Domicilio2__c',
            /*'COM_SEL_Divisa__c' => 'COM_SEL_Divisa__c',*/
            'CurrencyIsoCode' => 'CurrencyIsoCode',
            'COM_SEL_Idioma__c' => 'COM_SEL_Idioma__c',
            'COM_NUM_Ultimos_Ingresos_Explotacion__c' => 'COM_NUM_Ultimos_Ingresos_Explotacion__c',
            'COM_NUM_Ultimo_numero_de_empleados__c' => 'COM_NUM_Ultimo_numero_de_empleados__c',
            'COM_LKP_Codigo_CNAE__c' => 'COM_LKP_Codigo_CNAE__c',
            'COM_LKP_Director_de_Cuenta_KAM__c' => 'COM_LKP_Director_de_Cuenta_KAM__c',
            'COM_SEL_Ramo__c' => 'COM_SEL_Ramo__c',
            'COM_SEL_Tipo_de_cultivo_1__c' => 'COM_SEL_Tipo_de_cultivo_1__c', 
            'COM_SEL_Tipo_de_cultivo_2__c' => 'COM_SEL_Tipo_de_cultivo_2__c', 
            'COM_SEL_Tipo_de_cultivo_3__c' => 'COM_SEL_Tipo_de_cultivo_3__c', 
            'COM_SEL_Sub_tipo_de_cultivo_1__c' => 'COM_SEL_Sub_tipo_de_cultivo_1__c', 
            'COM_SEL_Sub_tipo_de_cultivo_2__c' => 'COM_SEL_Sub_tipo_de_cultivo_2__c', 
            'COM_SEL_Sub_tipo_de_cultivo_3__c' => 'COM_SEL_Sub_tipo_de_cultivo_3__c',
            'ACC_NUM_Superficie_total_de_produccion__c'=>'ACC_NUM_Superficie_total_de_produccion__c',
            'ACC_NUM_Dotacion_de_agua__c'=>'ACC_NUM_Dotacion_de_agua__c'
        };
        /*Creamos la lista de cuentas que vamos a insertar en el objeto account*/
        List<Account> listaInsertHija = new List<Account>();
        /*Recorremos el lista de cuentas y comprobamos si se trata de una hija o una cuenta matriz, en el caso de que sea matriz se inserta un registro en la lista de hijas*/
        for (Account acc:listaCuentas){
            if (acc.recordtypeId!=rtdid){
                Account accHija = new Account();
                acchija.recordTypeId=rtdid;
                acchija.COM_BOL_NoValidarNIFCIF__c = true;
                acchija.COM_BOL_Compania_fiscal__c = true;
                acchija.COM_SEL_Estado__c = Label.Estado_Borrador_SAP;
                for (String campoHija :mapeoCampos.keySet()) {
                    String campoAccount = mapeoCampos.get(campoHija);
                    acchija.put(campoHija, acc.get(campoAccount));
                }
                System.debug ('********************* El id del usuario es  ' + UserInfo.getUserId() +  'valor del label ' + Label.ADMIN_USER_SAP_ID + 'compara '+ (UserInfo.getUserId() == Label.ADMIN_USER_SAP_ID));
                if (UserInfo.getUserId() != Label.ADMIN_USER_SAP_ID){
                    if(acc.COM_LKP_Pais__c == espana) {
                        /*SI ES ESPAÑA*/
                        System.debug('El pais encontrado es España');
                        Id municipio = acc.COM_LKP_Municipio__c;
                        List<AQUA_Municipio__c> municipioNombre = new List<AQUA_Municipio__c>([SELECT name FROM AQUA_Municipio__c WHERE Id =:municipio LIMIT 1]);
                        String muni = municipioNombre.get(0).name;
                        List<AQUA_Municipio__c> municip = new List<AQUA_Municipio__c>([SELECT name, id, MUN_LKP_Estructura_Organizativa__c FROM AQUA_Municipio__c WHERE name =:muni LIMIT 1]);
                        System.debug('Este es el municipio encontrado : ' + municip + acc.COM_LKP_Municipio__c);
                        acchija.COM_LKP_EstructuraTerritorial__c = municip.get(0).MUN_LKP_Estructura_Organizativa__c;
                        System.debug('Estructura territorial asignada: ' + acc.COM_LKP_EstructuraTerritorial__c);
                    }else{
                        System.debug('El pais encontrado no es España');
                        List<AQUA_Municipio__c> pais = new List<AQUA_Municipio__c>([SELECT name, id, MUN_LKP_Estructura_Organizativa__c, MUN_LKP_Pais__c FROM AQUA_Municipio__c WHERE MUN_LKP_Pais__c =:acc.COM_LKP_Pais__c LIMIT 1]);
                        System.debug('Este es el pais encontrado : ' + pais);
                        acchija.COM_LKP_EstructuraTerritorial__c = pais.get(0).MUN_LKP_Estructura_Organizativa__c;
                        System.debug('Estructura territorial asignada: ' + acc.COM_LKP_EstructuraTerritorial__c);
                    }
                }
                listaInsertHija.add(acchija);
            }
        }

        /*insert lista hija. Si la lista hija no esta vacia se inserta lo que tenga en el objeto account.*/
        if (listaInsertHija.size() >0) insert listaInsertHija;
    }
}