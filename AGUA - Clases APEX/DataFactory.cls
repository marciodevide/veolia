@isTest
public class DataFactory {

    //Variable estatica que se utiliza para hacer unico cada record.
    public static integer aux = 0;
    
    public static User createUser(){
        User usuario = new User();
        return usuario;
    }
    
    public static AQUA_Provincia__c createProvincia(id pais){
        AQUA_Provincia__c provincia = new AQUA_Provincia__c();
        provincia.Name = 'Madrid'+aux;
       	provincia.PRO_LKP_PAIS__c = pais;
        provincia.PRO_TXT_Codigo_Provincia_SAP__c = '1'+aux;
        provincia.AQUA_TXT_PROVxPAIS__c = 'SP'+provincia.PRO_TXT_Codigo_Provincia_SAP__c;
        System.debug('El valor de aux es: '+aux);
        insert provincia;
        
        aux = aux+1;

        return provincia;
    }
    
    public static AQUA_Pais__c createPais(){
        AQUA_Pais__c pais = new AQUA_Pais__c();
        pais.Name = 'Spain'+aux;
        pais.PA_TXT_Codigo__c = 'S'+aux;
        pais.PA_TXT_Codigo_Pais_SAP__c = '0'+aux;
        insert pais;
        
        aux = aux+1;

        return pais;
    }
    
    public static AQUA_Municipio__c createMunicipio(id pais, id provincia){
        AQUA_Municipio__c municipio = new AQUA_Municipio__c();
        municipio.Name = 'Madrid';
        municipio.MUN_LKP_Pais__c = pais;
        municipio.MUN_TXT_Provincia__c = 'Madrid';
        municipio.MUN_LKP_Provincia2__c = provincia;
        insert municipio;

        return municipio;
    }
    
    public static AQUA_Municipio__c createMunicipio(){
        AQUA_Municipio__c municipio = new AQUA_Municipio__c();
        municipio.Name = 'Madrid';
        municipio.MUN_LKP_Pais__c = DataFactory.createPais().Id;
        municipio.MUN_TXT_Provincia__c = 'Madrid';
        municipio.MUN_LKP_Provincia2__c = DataFactory.createProvincia(municipio.MUN_LKP_Pais__c).Id;
        insert municipio;

        return municipio;
    }
    
    public static Account createAccount(){
        Account acc = new Account();
        acc.RecordTypeId = label.compania_hija_id;
        acc.Name = 'Account test';
        acc.Nombre_2__c = '666';
        acc.COM_BOL_Compania_fiscal__c = true;
        acc.COM_SEL_Estado__c = 'Completado';
        acc.ACC_TXT_OPERA_HIDDEN__c = 'I';
        acc.COM_TXT_NIFCIF__c = 'P1304529I';
        acc.COM_BOL_NoValidarNIFCIF__c = false;
        acc.COM_TXT_CodigoRamo1_HIDDEN__c = '010101';
        acc.COM_LKP_Pais__c = DataFactory.createPais().Id;
        acc.COM_TXT_Nombre_Poblacion__c = 'Madrid';
        System.debug(acc.COM_LKP_Municipio__c);
        acc.COM_TXT_Domicilio2__c = 'prueba';
        acc.COM_LKP_Provincia__c = DataFactory.createProvincia(acc.COM_LKP_Pais__c).Id;
        acc.COM_LKP_Municipio__c = DataFactory.createMunicipio(acc.COM_LKP_Pais__c,acc.COM_LKP_Provincia__c).Id;
        acc.COM_TXT_Domicilio__c='Paque Empresarial';
        acc.COM_TXT_Codigo_Postal__c='28046';
        acc.COM_BOL_Compania_bloqueado__c =false;
        acc.CurrencyIsoCode = 'EUR';
        acc.COM_SEL_Idioma__c = 'Español';
        acc.COM_BOL_Inactiva__c = false;
        insert acc;

        return acc;
    }

    public static AQUA_Sociedad_Ofertante__c createSociedad(){
        AQUA_Sociedad_Ofertante__c sociedad = new AQUA_Sociedad_Ofertante__c();
        sociedad.COM_BOL_Sociedad_SASE__c = true;
        sociedad.EMP_BOL_Empresa_Adjudicataria_del__c =true;
        sociedad.EMP_BOL_Notificacion_SAP__c = true;
        sociedad.EMP_BOL_Sociedad_Ofertante_del__c = true;
        insert sociedad;

        return sociedad;
    }

    public static Opportunity createOpportunity(){
        Opportunity oportunidad = new Opportunity();
        oportunidad.Name = 'Oportunidad'+aux;
        oportunidad.StageName = 'Oportunidad detectada';
        oportunidad.OPO_LKP_Sociedad_Ofertante__c = DataFactory.createSociedad().Id;
        oportunidad.OPO_SEL_Canal_Entrada__c = 'Privado';
        oportunidad.OPO_BOL_Seguimiento_de_Costes__c = true;
        oportunidad.OPO_SEL_Via_Pago__c = 'Transferencia Cobro';
        oportunidad.OPO_SEL_Condicion_Pago__c = 'COBRO A 30 DIAS FECHA FACTURA';
        Date date1 = Date.newInstance(2015, 7, 8);
        Date date2 = Date.newInstance(2015, 7, 13);
        oportunidad.OPO_DAT_Fecha_Deteccion_Oportunidad__c = date1;
        oportunidad.CloseDate = date2;
        oportunidad.CurrencyIsoCode = 'EUR';
        oportunidad.Probability = 10;
        oportunidad.OCUL_BOOL_OrigenPeticion__c = true;
        oportunidad.COM_SEL_estrategia__c = 'estra';
        oportunidad.COM_DATE_limite_de_aprobacion_N_A__c = System.today() + 5;
        oportunidad.OPO_DAT_Fecha_Inicio_Proyecto__c = System.today();
        oportunidad.OPO_DAT_Fecha_Fin_Proyecto__c = System.today() + 5;
        oportunidad.COM_DATE_limite_de_aprobacion_N_A__c = Date.today();
        insert oportunidad;

        aux = aux + 1;

        return oportunidad;
    }
    
    public static Oportunidad_Producto__c createProducto(Opportunity oportunidad){
        Oportunidad_Producto__c producto = new Oportunidad_Producto__c();
        producto.OP_MD_Oportunidad__c = oportunidad.Id;
        producto.OP_DIV_PrecioSinIVA__c = 3000000;
        producto.OpProd_LKP_SubAmbito__c = label.subambito_sita; 
        //producto.OP_NUM_Cantidad__c= 1;
        producto.OpProd_LKP_ResponsableElaboracionOferta__c = label.User_Elaborador_Oferta_ID;
        //producto.OP_DAT_FechaSolicitudOferta__c = System.today() + 5;
        producto.OpProd_SEL_Nodo_Dominio__c = 'Iberia';
        //producto.OP_TXT_Departamento__c = 'LABORATORIOS - Air Quality';
        insert producto;
        
        aux = aux+1;

        return producto;
    }
}