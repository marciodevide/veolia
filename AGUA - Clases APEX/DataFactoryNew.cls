@isTest
public class DataFactoryNew {

    //Variable estatica que se utiliza para hacer unico cada record.
    public static integer aux = 0;
    
    public static User createUser(){
        User usuario = [SELECT Id FROM User WHERE Id =:userinfo.getuserid()];
        return usuario;
    }

    public static User createUserPermission(){
        User usuarioPerm = [SELECT Id FROM user where Profile.Name='Comercial'AND IsActive=true AND Id NOT IN (SELECT AssigneeId FROM PermissionSetAssignment where PermissionSet.Name =:'Lider_Tecnico_NA_new') LIMIT 1];   
        return usuarioPerm;
    }

    public static AQUA_Provincia__c createProvincia(Id pais){
        AQUA_Provincia__c provincia = new AQUA_Provincia__c();
        provincia.Name = 'Madrid'+aux;
       	provincia.PRO_LKP_PAIS__c = pais;
        provincia.PRO_TXT_Codigo_Provincia_SAP__c = '1'+aux;
        provincia.AQUA_TXT_PROVxPAIS__c = 'SP'+provincia.PRO_TXT_Codigo_Provincia_SAP__c;
        System.debug('El valor de aux es: '+aux);
        aux = aux+1;
        
        return provincia;
    }
    
    public static AQUA_Pais__c createPais(){
        AQUA_Pais__c pais = new AQUA_Pais__c();
        pais.Name = 'Spain';
        pais.PA_TXT_Codigo__c = 'S'+aux;
        pais.PA_TXT_Codigo_Pais_SAP__c = '0'+aux;
        aux = aux+1;
        
        return pais;
    }
    
    public static AQUA_Municipio__c createMunicipio(AQUA_Pais__c pais, AQUA_Provincia__c provincia){
        AQUA_Municipio__c municipio = new AQUA_Municipio__c();
        municipio.Name = 'Madrid';
        municipio.MUN_LKP_Pais__c = pais.Id;
        municipio.MUN_TXT_Provincia__c = 'Madrid';
        municipio.MUN_LKP_Provincia2__c = provincia.Id;
        
        return municipio;
    }

    public static Case createCase(String reason, String subject, String description, Id accountId, Id opportunity){
        Case cs = new Case();
        cs.Reason = reason;
        cs.Subject = subject;
        cs.Description = description;
        cs.AccountId = accountId;
        cs.CASE_LKP_Opportunity__c = opportunity;

        return cs;
    }
    
    public static AQUA_Municipio__c createMunicipio(){
        AQUA_Municipio__c municipio = new AQUA_Municipio__c();
        municipio.Name = 'Madrid';
        municipio.MUN_LKP_Pais__c = DataFactoryNew.createPais().Id;
        municipio.MUN_TXT_Provincia__c = 'Madrid';
        municipio.MUN_LKP_Provincia2__c = DataFactoryNew.createProvincia(municipio.MUN_LKP_Pais__c).Id;

        return municipio;
    }

    public static AQUA_Nodos__c createNodo(){
        AQUA_Nodos__c nodo = new AQUA_Nodos__c();
        nodo.NOD_TXT_Nodo_Dominio_Alto_Nivel__c= 'South Europe';
        nodo.NOD_TXT_Nodo_Dominio__c= 'Iberia';
        nodo.NOD_TXT_Nodo_DSyT__c= 'Spain';
        nodo.NOD_TXT_Nodo_DCG__c= 'Madrid';
        nodo.NOD_TXT_NodoAC__c = 'Madrid';

        return nodo;
    }

    static public Listado_Elaborador_de_oferta__c createListadoElaboradorOferta(){
        Listado_Elaborador_de_oferta__c  listado =new Listado_Elaborador_de_oferta__c();
        listado.LEO_BOL_Responsable_de_Proyecto__c =true;
        listado.LEO_BOL_Responsable_Elaborador_de_Oferta__c = true;
        listado.LEO_BOL_Equipo_de_Cuentas__c =true;
        listado.LEO_BOL_Activo__c=true;
        listado.Name='Usuario SAP';
        listado.LEO_TXTEmail__c='email@text.com';

        return listado;
    }
    
    public static Account createAccount(User usuario,AQUA_Pais__c pais,AQUA_Provincia__c provincia,AQUA_Municipio__c municipio){
        Account acc = new Account();
        acc.RecordTypeId = label.compania_hija_id;
        acc.Name = 'Account test';
        acc.Nombre_2__c = '666';
        acc.COM_BOL_Compania_fiscal__c = true;
        acc.COM_LKP_Director_de_Cuenta_KAM__c = DataFactoryNew.createListadoElaboradorOferta().Id;
        acc.COM_SEL_Estado__c = 'Completado';
        acc.ACC_TXT_OPERA_HIDDEN__c = 'I';
        acc.COM_TXT_NIFCIF__c = 'P1304529I';
        acc.COM_BOL_NoValidarNIFCIF__c = false;
        acc.COM_TXT_CodigoRamo1_HIDDEN__c = '010101';
        acc.COM_LKP_Pais__c = pais.Id;
        acc.COM_TXT_Nombre_Poblacion__c = 'Madrid';
        System.debug(acc.COM_LKP_Municipio__c);
        acc.COM_TXT_Domicilio2__c = 'prueba';
        acc.COM_LKP_Provincia__c = provincia.Id;
        acc.COM_LKP_Municipio__c = municipio.Id;
        acc.COM_TXT_Domicilio__c='Paque Empresarial';
        acc.COM_TXT_Codigo_Postal__c='28046';
        acc.COM_BOL_Compania_bloqueado__c =false;
        acc.CurrencyIsoCode = 'EUR';
        acc.COM_SEL_Idioma__c = 'Español';
        acc.COM_BOL_Inactiva__c = false;

        return acc;
    }

    public static AQUA_Sociedad_Ofertante__c createSociedad(){
        AQUA_Sociedad_Ofertante__c sociedad = new AQUA_Sociedad_Ofertante__c();
        sociedad.COM_BOL_Sociedad_SASE__c = true;
        sociedad.EMP_BOL_Empresa_Adjudicataria_del__c =true;
        sociedad.EMP_BOL_Notificacion_SAP__c = true;
        sociedad.EMP_BOL_Sociedad_Ofertante_del__c = true;

        return sociedad;
    }
    
    
    public static AQUA_Configuracion__c createConfiguracion(){
        Integer anno = date.today().year() - 2000;
        string annoTxt = string.valueof(anno);
        AQUA_Configuracion__c conf = new AQUA_Configuracion__c();
        conf.CON_TXT_Anio__c=annoTxt;
        conf.CON_TXT_Contador__c='099999';

        return conf;
    }

    public static AQUA_Linea_de_Servicio__c createLineaServicio(){
        AQUA_Linea_de_Servicio__c linea = new AQUA_Linea_de_Servicio__c();
        linea.LS_SEL_Division__c='ENVIRONMENTAL QUALITY MONITORING';
        linea.LS_SEL_Linea_de_Servicio__c='ENVIRONMENTAL QUALITY MONITORING';

        return linea;
    }
    
    public static Ambito__c createAmbito(AQUA_Linea_de_Servicio__c linea){
        Ambito__c ambito =new Ambito__c();
        ambito.Name='Environmental Quality Monitoring';
        ambito.Linea_de_Servicio__c= linea.Id;

        return ambito;
    }
    
    public static Producto__c createPortfolio(Ambito__c ambito,AQUA_Linea_de_Servicio__c linea){
        Producto__c portfolio =new Producto__c();
        portfolio.Name='Hygiene Solutions';
        portfolio.MD_Ambito__c= ambito.Id;
        portfolio.PROD_LK_Linea_de_Servicio__c=linea.Id;
        portfolio.PROD_SEL_Linea_de_Servicio__c='ENVIRONMENTAL QUALITY MONITORING';
        portfolio.Prod_TXT_Codigo_Salesforce__c='PR27';

        return portfolio;
    }

    public static Producto__c createPortfolio2(Ambito__c ambito,AQUA_Linea_de_Servicio__c linea){
        Producto__c portfolio =new Producto__c();
        portfolio.Name='Environmental Testing Services';
        portfolio.MD_Ambito__c= ambito.Id;
        portfolio.PROD_LK_Linea_de_Servicio__c=linea.Id;
        portfolio.PROD_SEL_Linea_de_Servicio__c='ENVIRONMENTAL QUALITY MONITORING';
        portfolio.Prod_TXT_Codigo_Salesforce__c='PR31';

        return portfolio;
    }

    public static Tecnologia__c createTecnologia(){
        Tecnologia__c tecn =new Tecnologia__c();
        tecn.Name='Services';

        return tecn;
    }
   
    public static SubAmbito__c createSubAmbito(Producto__c portfolio,Tecnologia__c tecn){
        SubAmbito__c subambito =new SubAmbito__c();
        subambito.Name='Hygiene Solutions';
        subambito.LKP_Producto_Aqualogy__c=portfolio.Id;
        subambito.SA_LKP_Tecnologia__c=tecn.Id;

        return subambito;
    }

    public static SubAmbito__c  createSubAmbito2(Producto__c portfolio,Tecnologia__c tecn){
        SubAmbito__c subambito =new SubAmbito__c();
        subambito.Name='Environmental Testing Services';
        subambito.LKP_Producto_Aqualogy__c=portfolio.Id;
        subambito.SA_LKP_Tecnologia__c=tecn.Id;

        return subambito;
    }
    
    public static Departamento__c  createDepartamento(){
        Departamento__c departamento =new Departamento__c();
        departamento.DP_MPKL_Dominios__c='Iberia';
        departamento.DP_TXT_Dom_Sel__c='Iberia';
        departamento.DP_TXT_Nombre__c='AQUATEC - [Cambio Climático]'; 
        departamento.Name='AQUATEC - [Cambio Climático]';

        return departamento;
    }
    
    public static Departamento__c  createDepartamentoDominio(String dominio){
        Departamento__c departamento =new Departamento__c();
        departamento.DP_CHK_Sase__c = true;  
        departamento.DP_MPKL_Dominios__c=dominio;
        departamento.DP_TXT_Dom_Sel__c=dominio;
        departamento.DP_TXT_Nombre__c='AQUATEC - [Cambio Climático]'; 
        departamento.Name='AQUATEC - [Cambio Climático]';

        return departamento;
    }
    
    public static Opportunity createOpportunity(Account acc,AQUA_Sociedad_Ofertante__c sociedad,User usuario,Listado_Elaborador_de_oferta__c gerente){
        Opportunity oportunidad = new Opportunity();
        oportunidad.Name = 'Oportunidad'+aux;
        oportunidad.AccountId = acc.Id;
        oportunidad.StageName = 'Oportunidad detectada';
        oportunidad.OPO_LKP_Sociedad_Ofertante__c = sociedad.Id;
        oportunidad.COM_LKP_Lider_oferta__c = usuario.Id;
        oportunidad.OPO_LKP_Gerente_Cuenta__c = gerente.Id;
        oportunidad.OPO_SEL_Canal_Entrada__c = 'Directa';
        oportunidad.OPO_BOL_Seguimiento_de_Costes__c = true;
        oportunidad.OPO_SEL_Via_Pago__c = 'Transferencia Cobro';
        oportunidad.OPO_SEL_Condicion_Pago__c = 'COBRO A 30 DIAS FECHA FACTURA';
        Date date1 = Date.today();
        Date date2 = Date.today();
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
        oportunidad.OPO_SEL_Territorio_Oportunidad__c = 'Madrid';
        aux = aux + 1;
        
        return oportunidad;
    }
    
    public static Opportunity createOpportunityApprovalNote(Account acc,AQUA_Sociedad_Ofertante__c sociedad,User usuario,Listado_Elaborador_de_oferta__c gerente){
        Opportunity oportunidad = new Opportunity();
        oportunidad.Name = 'Oportunidad_Approval'+aux;
        oportunidad.AccountId = acc.Id;
        oportunidad.StageName = 'En elaboración oferta';
        oportunidad.OPO_LKP_Sociedad_Ofertante__c = sociedad.Id;
        oportunidad.OPO_SEL_Canal_Entrada__c = 'Directa';
        oportunidad.OPO_BOL_Seguimiento_de_Costes__c = true;
        oportunidad.OPO_SEL_Via_Pago__c = 'Transferencia Cobro';
        oportunidad.OPO_SEL_Condicion_Pago__c = 'COBRO A 30 DIAS FECHA FACTURA';
        Date date1 = Date.today();
        Date date2 = Date.today();
        oportunidad.OPO_DAT_Fecha_Deteccion_Oportunidad__c = date1;
        oportunidad.OPO_DAT_Fecha_Fin_Proyecto__c = date1;
        oportunidad.OPO_DAT_Fecha_Inicio_Proyecto__c = date1;
        oportunidad.CloseDate = date1;
        oportunidad.CurrencyIsoCode = 'EUR';
        oportunidad.Probability = 10;
        oportunidad.OCUL_BOOL_OrigenPeticion__c = true;
        oportunidad.COM_SEL_estrategia__c = 'estra';
        oportunidad.COM_DATE_limite_de_aprobacion_N_A__c = date1;
        oportunidad.COM_DATE_Limite_entrega_N_A__c = date1;
        oportunidad.Aprobacion_en_curso__c=true;
        oportunidad.COM_LKP_Lider_oferta__c = usuario.Id;
        oportunidad.OPO_LKP_Gerente_Cuenta__c = gerente.Id;
        //oportunidad.COM_LKP_Producto_Lider__c = producto;
        oportunidad.COM_SEL_estrategia__c = 'Estrategia';
        oportunidad.COM_SEL_Oportunidad_Mono_Multi__c = 'Mono';
        oportunidad.OCUL_BOOL_OrigenPeticion__c = true;
        oportunidad.OPO_BOL_NotaNecesaria__c = true;
        oportunidad.OPO_BOL_OK_ADJUNTO_NOTA_RIESGOS__c=true;
        oportunidad.OPO_SEL_ComplianceVal__c='Si';
        oportunidad.OPO_BOL_OK_ECOFIN__c=true;
        oportunidad.OPO_BOL_OK_Lider__c=true;
        oportunidad.OPO_BOL_Tecnico_SSJJ__c=true;
        oportunidad.OPO_NUM_Posible_Prroroga_Meses__c = '2';
        oportunidad.OPO_SEL_Estado_Proceso__c = 'En aprobación';
        oportunidad.OPO_TXT_Alcance__c = 'alcance';
        oportunidad.OPO_TXT_Analisis_del_socio__c = 'analisis';
        oportunidad.OPO_TXT_Competencia__c = 'competencia';
        oportunidad.OPO_NUM_Margen_Bruto__c = 1;
        oportunidad.OPO_TXT_Principal_Subcontratacion__c = 'principal subtont';
        oportunidad.OPO_TXT_Criterios_Decision__c  = 'criterios adj';
        oportunidad.OPO_CUR_Volumen_Total__c  = 5000000;
        oportunidad.OPO_SEL_Cualificacion__c = 'Beta';
        oportunidad.Opp_TXT_negocio__c = 'Infraestructuras';
        oportunidad.OPO_TXT_Contexto_Cliente__c = 'contexto';
        oportunidad.OPO_TXT_Riesgo__c = 'asdf';
        oportunidad.OPO_NUM_Desviacion__c = 6;
        oportunidad.OPO_TXT_Criterios_Adicionales__c = 'coment adic';
        oportunidad.OPO_TXT_Garantia__c = 'provisional';
        oportunidad.OPO_TXT_Garantia_Definitiva__c = 'definitiva';
        oportunidad.OPO_TXT_Limite_Subcontratacion__c  = 'limite';
        oportunidad.OPO_TXT_Limite_Responsabilidad__c  = 'limit';
        oportunidad.OPO_TXT_Causas_Excepcionales_Resolucion__c  = 'causas_excep';
        oportunidad.OPO_TXT_Tratamiento_Masivo__c = 'tratam';
        oportunidad.OPO_NUM_Penalizacion__c = 'penal';
        oportunidad.OPO_PER_Reduccion_del_presupuesto__c = 1;
        oportunidad.OPO_TXT_Subrogacion__c = 'subrog';
        oportunidad.OPO_TXT_Temeridad__c = 'temeridad';
        oportunidad.OPO_LKP_Aprobador_adicional__c = null;
        oportunidad.OPO_LKP_Aprobador_adicional__c = null;
        oportunidad.OPO_LKP_Aprobador_DC_Territorio__c = null;
        oportunidad.Aprobador_Delivery_Center__c =usuario.Id;
        oportunidad.OPO_LKP_Aprobador_Ecofin__c =usuario.Id;
        oportunidad.OPO_LKP_Aprobador_DC__c =usuario.Id;
        oportunidad.OPO_LKP_Aprobador_Dir_Gen_Agua_Cat__c =usuario.Id;
        oportunidad.OwnerId = usuario.Id;
        oportunidad.OPO_SEL_Territorio_Oportunidad__c = 'Madrid';
        oportunidad.OPO_LKP_Tecnico_ECOFIN__c=usuario.Id;
        oportunidad.OPO_LKP_Tecnico_SSJJ__c=usuario.Id;

        aux = aux + 1;
       
        return oportunidad;
    }

    public static Opportunity createOpportunityGanada(Account acc,AQUA_Sociedad_Ofertante__c sociedad,User usuario,Listado_Elaborador_de_oferta__c gerente ){
        Opportunity oportunidad = new Opportunity();
        oportunidad.Name = 'Oportunidad_'+aux;
        oportunidad.AccountId = acc.Id;
        oportunidad.StageName = 'Ganada';
        oportunidad.OPO_LKP_Sociedad_Ofertante__c = sociedad.Id;
        oportunidad.OPO_SEL_Canal_Entrada__c = 'Directa';
        oportunidad.OPO_BOL_Seguimiento_de_Costes__c = true;
        oportunidad.OPO_SEL_Via_Pago__c = 'Transferencia Cobro';
        oportunidad.OPO_SEL_Condicion_Pago__c = 'COBRO A 30 DIAS FECHA FACTURA';
        Date date1 = Date.newInstance(2015, 7, 8);
        Date date2 = Date.newInstance(2015, 7, 13);
        oportunidad.OPO_DAT_Fecha_Deteccion_Oportunidad__c = date1;
        oportunidad.OPO_DAT_Fecha_Fin_Proyecto__c = date1;
        oportunidad.OPO_DAT_Fecha_Inicio_Proyecto__c = date1;
        oportunidad.CloseDate = date1;
        oportunidad.OPO_DAT_Fecha_Adjudicacion__c=date1;
        oportunidad.OPO_DAT_Fecha_Presentacion_Oferta__c=date1;
        oportunidad.CurrencyIsoCode = 'EUR';
        oportunidad.Probability = 10;
        oportunidad.OCUL_BOOL_OrigenPeticion__c = true;
        oportunidad.COM_SEL_estrategia__c = 'estra';
        oportunidad.COM_DATE_limite_de_aprobacion_N_A__c = date1;
        oportunidad.COM_DATE_Limite_entrega_N_A__c = date1;
        oportunidad.Aprobacion_en_curso__c=true;
        oportunidad.COM_LKP_Lider_oferta__c = usuario.Id;
        //oportunidad.COM_LKP_Producto_Lider__c = producto;
        oportunidad.COM_SEL_estrategia__c = 'Estrategia';
        oportunidad.COM_SEL_Oportunidad_Mono_Multi__c = 'Mono';
        oportunidad.OCUL_BOOL_OrigenPeticion__c = true;
        oportunidad.OPO_BOL_NotaNecesaria__c = false;
        oportunidad.OPO_SEL_Territorio_Oportunidad__c = 'Madrid';
        oportunidad.OPO_NUM_Posible_Prroroga_Meses__c = '2';
        oportunidad.OPO_LKP_Gerente_Cuenta__c = gerente.Id;
        oportunidad.OPO_TXT_Alcance__c = 'alcance';
        oportunidad.OPO_TXT_Competencia__c = 'competencia';
        oportunidad.OPO_NUM_Margen_Bruto__c = 1;
        oportunidad.OPO_TXT_Principal_Subcontratacion__c = 'principal subtont';
        oportunidad.OPO_TXT_Criterios_Decision__c  = 'criterios adj';
        oportunidad.OPO_CUR_Volumen_Total__c  = 5000000;
        oportunidad.OPO_SEL_Cualificacion__c = 'Beta';
        oportunidad.Opp_TXT_negocio__c = 'Infraestructuras';
        oportunidad.OPO_TXT_Contexto_Cliente__c = 'contexto';
        oportunidad.OPO_NUM_Desviacion__c = 6;
        oportunidad.OPO_TXT_Criterios_Adicionales__c = 'coment adic';
        oportunidad.OPO_TXT_Garantia__c = 'provisional';
        oportunidad.OPO_TXT_Garantia_Definitiva__c = 'definitiva';
        oportunidad.OPO_TXT_Limite_Subcontratacion__c  = 'limite';
        oportunidad.OPO_TXT_Limite_Responsabilidad__c  = 'limit';
        oportunidad.OPO_TXT_Causas_Excepcionales_Resolucion__c  = 'causas_excep';
        oportunidad.OPO_TXT_Tratamiento_Masivo__c = 'tratam';
        oportunidad.OPO_NUM_Penalizacion__c = 'penal';
        oportunidad.OPO_TXT_Subrogacion__c = 'subrog';
        oportunidad.OPO_TXT_Temeridad__c = 'temeridad';
        oportunidad.OwnerId = usuario.Id;
        oportunidad.Probability = 100;

        aux = aux+1;

        return oportunidad;
    }
    
	public static Opportunity createOpportunitySASE(Account acc,AQUA_Sociedad_Ofertante__c sociedad,User usuario,Listado_Elaborador_de_oferta__c gerente, Oportunidad_Producto__c productoLider, User contactoAdmin){
        Opportunity oportunidad = new Opportunity();
        oportunidad.Name = 'Oportunidad'+aux;
        oportunidad.AccountId = acc.Id;
        oportunidad.StageName = 'Oportunidad detectada';
        if(productoLider != null) oportunidad.COM_LKP_Producto_Lider__c = productoLider.id;
        else oportunidad.COM_LKP_Producto_Lider__c = null;
        
        //oportunidad.recordTypeId = null;
        if(contactoAdmin != null) oportunidad.OPO_LKP_Contacto_Administrativo__c =contactoAdmin.Id;
        else oportunidad.OPO_LKP_Contacto_Administrativo__c = null;
        
        oportunidad.OPO_LKP_Sociedad_Ofertante__c = sociedad.Id;
        oportunidad.COM_LKP_Lider_oferta__c = usuario.Id;
        oportunidad.OPO_LKP_Gerente_Cuenta__c = gerente.Id;
        oportunidad.OPO_SEL_Canal_Entrada__c = 'Licitación pública';
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
        oportunidad.OPO_SEL_Territorio_Oportunidad__c = 'Madrid';

        aux = aux + 1;
        
        return oportunidad;
    }    
    
    public static Oportunidad_Producto__c createProducto(Opportunity oportunidad,SubAmbito__c subambito, Departamento__c departamento,Listado_Elaborador_de_oferta__c listado){
        Oportunidad_Producto__c producto = new Oportunidad_Producto__c();
        producto.OP_MD_Oportunidad__c = oportunidad.Id;
        producto.OP_DIV_PrecioSinIVA__c = 3000000;
        //producto.OpProd_LKP_SubAmbito__c = label.subambito_sita; 
        //producto.OP_NUM_Cantidad__c= 1;
        producto.OpProd_LKP_ResponsableElaboracionOferta__c = listado.Id;
        producto.OpProd_LKP_Responsable_de_Proyecto_NEW__c = listado.Id;
        //producto.OP_DAT_FechaSolicitudOferta__c = System.today();
        producto.OpProd_SEL_Nodo_Dominio__c = 'Iberia';
        producto.OP_TXT_DescripcionAmpliada__c = 'test';
        producto.CurrencyIsoCode = 'EUR';
        producto.OP_POR_PorcentajeDescuento__c=0;
        producto.OpProd_LKP_SubAmbito__c = subambito.Id;
        producto.Departamento__c = departamento.Id;
        producto.Name = 'PRoducto_'+aux;

        aux = aux+1;
        
        return producto;
    }
}