public class OportunidadUtil {

    public static String log = '';
    public OportunidadUtil() { }

    public static void asociarObjetivoCalculadoNuevaOp(list<Opportunity> newList)
    {

        procesarOportunidades(newList);

    }

    public static void asociarAreaComercial(list<Opportunity> newList)
    {
        List<Area_Comercial__c> listaAreas = [SELECT Area_Comercial__c, TIpo__c FROM Area_Comercial__c];

        Area_Comercial__c ac;

        for (Opportunity o : newList)
        {
            Integer count = 0;
            Boolean encontrado = false;
            System.debug('----> OportunidadUtil asociarAreaComercial o.Area_comercial__c: ' + o.Area_comercial__c);
            System.debug('----> OportunidadUtil asociarAreaComercial o.Tipo__c: ' + o.Tipo__c);
            if (listaAreas.size() > 0)
            {
                do
                {
                    ac = listaAreas[count];
                    System.debug('----> OportunidadUtil asociarAreaComercial ac.Area_Comercial__c: ' + ac.Area_Comercial__c);
                    System.debug('----> OportunidadUtil asociarAreaComercial ac.TIpo__c: ' + ac.TIpo__c);
                    //if (oc.Anyo__c == o.Anyo__c && oc.Cliente_Nivel_Actividad_1__c == o.Cliente_Nivel_Actividad_1__c && oc.Cliente_Nivel_Actividad_2__c == o.Cliente_Nivel_Actividad_2__c && oc.Cliente_Nivel_Actividad_3__c == o.Cliente_Nivel_Actividad_3__c && oc.L_nea_de_negocio__c == o.Linea_de_negocio__c && oc.rea_Comercial_Lista__c == o.Area_Comercial__c && oc.Servicio_Nivel_Actividad_1__c == o.Servicio_Nivel_Actividad_1__c && oc.Servicio_Nivel_Actividad_2__c == o.Servicio_Nivel_Actividad_2__c && oc.Servicio_Nivel_Actividad_3__c == o.Servicio_Nivel_Actividad_3__c && oc.Tipo__c == o.Tipo__c)
                    if (o.Area_comercial__c == ac.Area_Comercial__c && o.Tipo__c == ac.TIpo__c)
                    {
                        o.Area_com_lkp__c = ac.Id;
                        encontrado = true;
                        System.debug('----> OportunidadUtil asociarAreaComercial encontrado: ' + encontrado);
                    }
                    else
                    {
                        count++;
                    }
                }
                while (encontrado == false && count < listaAreas.size());
            }
        }

    }

    public static void asociarObjetivoCalculadoActualizar(list<Opportunity> newList, map<Id, Opportunity> oldMap)
    {
        System.debug('----> OportunidadHandler asociarObjetivoCalculadoActualizar');
        List<Opportunity> listaOp = new List<Opportunity> ();

        for (Opportunity o : newList)
        {
            Opportunity oc = oldMap.get(o.Id);
			//if (oc.Anyo__c != o.Anyo__c || oc.Cliente_Nivel_Actividad_2__c != o.Cliente_Nivel_Actividad_2__c || oc.Cliente_Nivel_Actividad_3__c != o.Cliente_Nivel_Actividad_3__c || oc.Linea_de_negocio__c != o.Linea_de_negocio__c || oc.Area_Comercial__c != o.Area_Comercial__c || oc.Servicio_Nivel_Actividad_1__c != o.Servicio_Nivel_Actividad_1__c || oc.Servicio_Nivel_Actividad_2__c != o.Servicio_Nivel_Actividad_2__c || oc.Servicio_Nivel_Actividad_3__c != o.Servicio_Nivel_Actividad_3__c || oc.Tipo__c != o.Tipo__c)
            //New APC - Segmento__c/Subsegmento__c
            if (oc.Anyo__c != o.Anyo__c || oc.Cliente_Nivel_Actividad_2__c != o.Cliente_Nivel_Actividad_2__c || oc.Cliente_Nivel_Actividad_3__c != o.Cliente_Nivel_Actividad_3__c || oc.Area_Comercial__c != o.Area_Comercial__c || oc.Segmento__c != o.Segmento__c || oc.Subsegmento__c != o.Subsegmento__c || oc.Tipo__c != o.Tipo__c)
            {
                listaOp.add(o);
            }

        }


        procesarOportunidades(listaOp);
    }

    public static void procesarOportunidades(list<Opportunity> newList)
    {
        System.debug('----> OportunidadUtil procesarOportunidades: ' + newList);
        //buscar objetivos calculados
		
        //List<Objetivo_Calculado__c> ocalc = [SELECT Name, Area_Comercial__c, Anyo__c, Area_principal__c, Cliente_Nivel_Actividad_1__c, Cliente_Nivel_Actividad_2__c, Cliente_Nivel_Actividad_3__c, Id, L_nea_de_negocio__c, rea_Comercial_Lista__c, Servicio_Nivel_Actividad_1__c, Servicio_Nivel_Actividad_2__c, Servicio_Nivel_Actividad_3__c, Tipo__c FROM Objetivo_Calculado__c];
        //New APC - Segmento__c/Subsegmento__c
        List<Objetivo_Calculado__c> ocalc = [SELECT Name, Area_Comercial__c, Anyo__c, Area_principal__c, Cliente_Nivel_Actividad_1__c, Cliente_Nivel_Actividad_2__c, Cliente_Nivel_Actividad_3__c, Id, rea_Comercial_Lista__c, Segmento__c, Subsegmento__c, Tipo__c FROM Objetivo_Calculado__c];

        //si se corresponden asociar

        for (Opportunity o : newList)
        {
            System.debug('----> OportunidadUtil procesarOportunidades name:' + o.name);
            Integer count = 0;
            Boolean encontrado = false;

            Objetivo_Calculado__c oc;

            if (ocalc.size() > 0)
            {

                /*System.debug('----> OportunidadUtil procesarOportunidades: ' +
                            o.Anyo__c + '/' + 
                            o.Cliente_Nivel_Actividad_2__c + '/' + 
                            o.Cliente_Nivel_Actividad_3__c + '/' + 
                            o.Linea_de_negocio__c + '/' + 
                            o.Area_Comercial__c + '/' + 
                            o.Servicio_Nivel_Actividad_1__c + '/' + 
                            o.Servicio_Nivel_Actividad_2__c + '/' + 
                            o.Servicio_Nivel_Actividad_3__c + '/' + 
                            o.Tipo__c);*/
                //New APC - Segmento__c/Subsegmento__c
                System.debug('----> OportunidadUtil procesarOportunidades: ' +
                            o.Anyo__c + '/' + 
                            o.Cliente_Nivel_Actividad_2__c + '/' + 
                            o.Cliente_Nivel_Actividad_3__c + '/' + 
                            o.Area_Comercial__c + '/' + 
                            o.Segmento__c + '/' + 
                            o.Subsegmento__c + '/' + 
                            o.Tipo__c);
                do
                {
                    oc = ocalc[count];

                    /*System.debug('----> OportunidadUtil procesarOportunidades oc: ' +
                                oc.Name + '/' + 
                                oc.Anyo__c + '/' + 
                                oc.Cliente_Nivel_Actividad_2__c + '/' + 
                                oc.Cliente_Nivel_Actividad_3__c + '/' + 
                                oc.L_nea_de_negocio__c + '/' + 
                                oc.rea_Comercial_Lista__c + '/' + 
                                oc.Servicio_Nivel_Actividad_1__c + '/' + 
                                oc.Servicio_Nivel_Actividad_2__c + '/' + 
                                oc.Servicio_Nivel_Actividad_3__c + '/' + 
                                oc.Tipo__c );*/
                    //New APC - Segmento__c/Subsegmento__c
                    System.debug('----> OportunidadUtil procesarOportunidades oc: ' +
                                oc.Name + '/' + 
                                oc.Anyo__c + '/' + 
                                oc.Cliente_Nivel_Actividad_2__c + '/' + 
                                oc.Cliente_Nivel_Actividad_3__c + '/' + 
                                oc.rea_Comercial_Lista__c + '/' + 
                                oc.Segmento__c + '/' + 
                                oc.Subsegmento__c + '/' + 
                                oc.Tipo__c );

                    //if (oc.Anyo__c == o.Anyo__c && oc.Cliente_Nivel_Actividad_1__c == o.Cliente_Nivel_Actividad_1__c && oc.Cliente_Nivel_Actividad_2__c == o.Cliente_Nivel_Actividad_2__c && oc.Cliente_Nivel_Actividad_3__c == o.Cliente_Nivel_Actividad_3__c && oc.L_nea_de_negocio__c == o.Linea_de_negocio__c && oc.rea_Comercial_Lista__c == o.Area_Comercial__c && oc.Servicio_Nivel_Actividad_1__c == o.Servicio_Nivel_Actividad_1__c && oc.Servicio_Nivel_Actividad_2__c == o.Servicio_Nivel_Actividad_2__c && oc.Servicio_Nivel_Actividad_3__c == o.Servicio_Nivel_Actividad_3__c && oc.Tipo__c == o.Tipo__c)
                    //if (oc.Anyo__c == o.Anyo__c && oc.Cliente_Nivel_Actividad_2__c == o.Cliente_Nivel_Actividad_2__c && oc.Cliente_Nivel_Actividad_3__c == o.Cliente_Nivel_Actividad_3__c && oc.L_nea_de_negocio__c == o.Linea_de_negocio__c && oc.rea_Comercial_Lista__c == o.Area_Comercial__c && oc.Servicio_Nivel_Actividad_1__c == o.Servicio_Nivel_Actividad_1__c && oc.Servicio_Nivel_Actividad_2__c == o.Servicio_Nivel_Actividad_2__c && oc.Servicio_Nivel_Actividad_3__c == o.Servicio_Nivel_Actividad_3__c && oc.Tipo__c == o.Tipo__c)
                    //New APC - Segmento__c/Subsegmento__c
                    if (oc.Anyo__c == o.Anyo__c && oc.Cliente_Nivel_Actividad_2__c == o.Cliente_Nivel_Actividad_2__c && oc.Cliente_Nivel_Actividad_3__c == o.Cliente_Nivel_Actividad_3__c && oc.rea_Comercial_Lista__c == o.Area_Comercial__c && oc.Segmento__c == o.Segmento__c && oc.Subsegmento__c == o.Subsegmento__c && oc.Tipo__c == o.Tipo__c)    
                    {
                        System.debug('----> OportunidadUtil procesarOportunidades encontrado: ' + oc.Name );
                        o.Objetivo_individual__c = oc.Id;
                        encontrado = true;
                    }
                    else
                    {
                        System.debug('----> OportunidadUtil procesarOportunidades no encontrado');
                        count++;
                    }
                }
                while (encontrado == false && count < ocalc.size());
            }

            if (encontrado == false)
            {
                o.Objetivo_individual__c = null;
            }


            count = 0;
            encontrado = false;


            if (ocalc.size() > 0)
            {
                do
                {
                    Objetivo_Calculado__c ocagr = ocalc[count];
                    //if (ocagr.Area_Comercial__c == oc.Area_principal__c && ocagr.Anyo__c == o.Anyo__c && ocagr.Cliente_Nivel_Actividad_1__c == o.Cliente_Nivel_Actividad_1__c && ocagr.Cliente_Nivel_Actividad_2__c == o.Cliente_Nivel_Actividad_2__c && ocagr.Cliente_Nivel_Actividad_3__c == o.Cliente_Nivel_Actividad_3__c && ocagr.L_nea_de_negocio__c == o.Linea_de_negocio__c && ocagr.rea_Comercial_Lista__c == o.Area_Comercial__c && ocagr.Servicio_Nivel_Actividad_1__c == o.Servicio_Nivel_Actividad_1__c && ocagr.Servicio_Nivel_Actividad_2__c == o.Servicio_Nivel_Actividad_2__c && ocagr.Servicio_Nivel_Actividad_3__c == o.Servicio_Nivel_Actividad_3__c && ocagr.Tipo__c == o.Tipo__c )
                    //if (ocagr.Area_Comercial__c == oc.Area_principal__c && oc.Anyo__c == o.Anyo__c && oc.Cliente_Nivel_Actividad_2__c == o.Cliente_Nivel_Actividad_2__c && oc.Cliente_Nivel_Actividad_3__c == o.Cliente_Nivel_Actividad_3__c && oc.L_nea_de_negocio__c == o.Linea_de_negocio__c && oc.rea_Comercial_Lista__c == o.Area_Comercial__c && oc.Servicio_Nivel_Actividad_1__c == o.Servicio_Nivel_Actividad_1__c && oc.Servicio_Nivel_Actividad_2__c == o.Servicio_Nivel_Actividad_2__c && oc.Servicio_Nivel_Actividad_3__c == o.Servicio_Nivel_Actividad_3__c && oc.Tipo__c == o.Tipo__c)
                    //New APC - Segmento__c/Subsegmento__c
                    if (ocagr.Area_Comercial__c == oc.Area_principal__c && oc.Anyo__c == o.Anyo__c && oc.Cliente_Nivel_Actividad_2__c == o.Cliente_Nivel_Actividad_2__c && oc.Cliente_Nivel_Actividad_3__c == o.Cliente_Nivel_Actividad_3__c && oc.rea_Comercial_Lista__c == o.Area_Comercial__c && oc.Segmento__c == o.Segmento__c && oc.Subsegmento__c == o.Subsegmento__c && oc.Tipo__c == o.Tipo__c)    
                    {
                        o.Objetivo_Calculado_Agrupado__c = ocagr.Id;
                        encontrado = true;
                    }
                    else
                    {
                        count++;
                    }
                }
                while (encontrado == false && count < ocalc.size());
            }

            if (encontrado == false)
            {
                o.Objetivo_Calculado_Agrupado__c = null;
            }

        }

    }

    /** 
     * generarCodigoOportunidad
     **
     * Genera el valor del código de la oportunidad en función de las distintas filiales. Actualmente solo se genera para GIROA y VSC.
     * Recupera el contador de registros (CustomSetting RecordCounter__c) para Oportunidades, aumentado el contador por cada oportunidad que se ha generado
     **
     * @Evento: BEFORE INSERT
     **
     * @Autor: jmartinezpisson (11/04/2016)
     **
     * @Modificaciones: jmartinezpisson (27/04/2016) Añadido el conteo por delegación VSC
     *                  Alfonso Rodríguez (20/12/2022) SF00007 - En lugar de emplear el Id del recordtype, empleamos el DeveloperName del Record Type
     **
     * @param: List<Opportunity> newList -> Lista de oportunidades a insertar/actualizar
     *        Map<Id, Account> cuentasMap -> Map de cuentas relacionadas con las oportunidades. Debe contener los distintos codigos Veolia
     **
     * @return: -
     **/
    public static void generarCodigoOportunidad(List<Opportunity> newList, Map<Id, Account> cuentasMap)
    {
        Map<String, RecordCounter__c> contadorMap = RecordCounterUtil.recuperaContadorOportunidad();
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Opportunity.getRecordTypeInfosById();

        String claveDivision = '';

        for (String key : contadorMap.keySet()) {
            System.debug('----> OportunidadUtil generarCodigoOportunidad contador: ' + key + ':' + contadorMap.get(key) );
            log = log + '----> OportunidadUtil generarCodigoOportunidad contador: ' + key + ':' + contadorMap.get(key);
        }

        for (Opportunity opp : newList)
        {
            String type = rtMap.get(opp.RecordTypeId).getDeveloperName();
            System.debug('----> OportunidadUtil generarCodigoOportunidad opp.RecordTypeId: ' + opp.RecordTypeId);
            System.debug('----> OportunidadUtil generarCodigoOportunidad type: ' + type);
            log = log + '----> OportunidadUtil generarCodigoOportunidad opp.RecordTypeId: ' + opp.RecordTypeId;
            log = log + '----> OportunidadUtil generarCodigoOportunidad type: ' + type;
            //if (contadorMap.containsKey(opp.RecordTypeId))
            if (contadorMap.containsKey(type))//SF00007
            {
                System.debug('----> OportunidadUtil generarCodigoOportunidad contadorMap.containsKey');
                log = log + '----> OportunidadUtil generarCodigoOportunidad contadorMap.containsKey';

                //contadorMap.get(opp.RecordTypeId).Value__c += 1;
                contadorMap.get(type).Value__c += 1;//SF00007
                
                //VSC - Contadores filial
                //if(opp.RecordTypeId == Constantes.RT_OPP_VSC)
                if(type == Constantes.RT_OPP_VSC)//SF00007
                {
                    //claveDivision = opp.RecordTypeId + Constantes.MAPA_VSC_DIVISIONES.get(opp.Area_comercial__c);
                    claveDivision = type + Constantes.MAPA_VSC_DIVISIONES.get(opp.Area_comercial__c);//SF00007
                    
                    if( contadorMap.containsKey(claveDivision) )
                    {
                        contadorMap.get(claveDivision).Value__c += 1;
                    }
                }
                
                //if(opp.RecordTypeId == Constantes.RT_OPP_CONTRACTING)
                if(type == Constantes.RT_OPP_CONTRACTING)//SF00007
                {
                    //claveDivision = opp.RecordTypeId + Constantes.MAPA_VSC_DIVISIONES.get(opp.Area_comercial__c);
                    claveDivision = type + Constantes.MAPA_VSC_DIVISIONES.get(opp.Area_comercial__c);//SF00007

                    if( contadorMap.containsKey(claveDivision) )
                    {
                        contadorMap.get(claveDivision).Value__c += 1;
                    }
                }
                System.debug('----> OportunidadUtil generarCodigoOportunidad claveDivision: ' + claveDivision);
                log = log + '----> OportunidadUtil generarCodigoOportunidad claveDivision: ' + claveDivision;

                generarCodigoOportunidad(opp, contadorMap, cuentasMap.get(opp.AccountId), type);
            }
            else {
                System.debug('----> OportunidadUtil generarCodigoOportunidad no se encontró contador');
                log = log + '----> OportunidadUtil generarCodigoOportunidad no se encontró contador';
            }
        }
    }

    /** 
     * generarCodigoOportunidad
     **
     * Genera el valor del código de la oportunidad en función de las distintas filiales VSC y GIROA
     * Formato: VSC -  VSC000341IND00025 - Código Veolia de la cuenta + siglas división + contador oportunidades/division
     *         GIROA - NOR201600035 - NOR + Año + Contador oportunidad GIROA
     *         VSL - Se mantienen los workflow actuales para la generación de su código
     *         CONTRACTING - VCONTRACT000341IND00025 - Código Contracting de la cuenta + siglas división + contador oportunidades/division
     **
     * @Evento: BEFORE INSERT
     **
     * @Autor: jmartinezpisson (11/04/2016)
     *         Alfonso Rodríguez (20/12/2022) SF00007 - En lugar de emplear el Id del recordtype, empleamos el DeveloperName del Record Type
     **
     * @Modificaciones: -
     **
     * @param: Opportunity opp -> Oportunidad de la que generar código de oportunidad (Paso por referencia)
     *        Map<String, RecordCounter__c> -> Mapa de contadores organizado por RecordType(DeveloperName) de oportunidad//SF00007
     *        Map<Id, Account> cuentasMap -> Map de cuentas organizado por Id. Debe contener el campo VSC_Codigo_Veolia__c
     **
     * @return: -
     **/
    private static void generarCodigoOportunidad(Opportunity opp, Map<String, RecordCounter__c> contadoresMap, Account cuenta, String type)
    {
        /*Integer valorContador = opp.RecordTypeId != Constantes.RT_OPP_VSC?
                                    Integer.valueOf(contadoresMap.get(opp.RecordTypeId).Value__c):
                                    Integer.valueOf(contadoresMap.get(opp.RecordTypeId + Constantes.MAPA_VSC_DIVISIONES.get(opp.Area_comercial__c)).Value__c);*/


        System.debug('----> OportunidadUtil generarCodigoOportunidad2 contadoresMap: ' + contadoresMap);
        System.debug('----> OportunidadUtil generarCodigoOportunidad2 type: ' + type);
        System.debug('----> OportunidadUtil generarCodigoOportunidad2 Constantes.MAPA_VSC_DIVISIONES: ' + Constantes.MAPA_VSC_DIVISIONES);
        System.debug('----> OportunidadUtil generarCodigoOportunidad2 opp.Area_comercial__c: ' + opp.Area_comercial__c);
        System.debug('----> OportunidadUtil generarCodigoOportunidad2 Constantes.MAPA_VSC_DIVISIONES.get(opp.Area_comercial__c): ' + Constantes.MAPA_VSC_DIVISIONES.get(opp.Area_comercial__c));
        log = log + '----> OportunidadUtil generarCodigoOportunidad2 contadoresMap: ' + contadoresMap;
        log = log + '----> OportunidadUtil generarCodigoOportunidad2 type: ' + type;
        log = log + '----> OportunidadUtil generarCodigoOportunidad2 Constantes.MAPA_VSC_DIVISIONES: ' + Constantes.MAPA_VSC_DIVISIONES;
        log = log + '----> OportunidadUtil generarCodigoOportunidad2 opp.Area_comercial__c: ' + opp.Area_comercial__c;
        log = log + '----> OportunidadUtil generarCodigoOportunidad2 Constantes.MAPA_VSC_DIVISIONES.get(opp.Area_comercial__c): ' + Constantes.MAPA_VSC_DIVISIONES.get(opp.Area_comercial__c);

        

        Integer valorContador = type != Constantes.RT_OPP_VSC?
                                    Integer.valueOf(contadoresMap.get(type).Value__c):
                                    Integer.valueOf(contadoresMap.get(type + Constantes.MAPA_VSC_DIVISIONES.get(opp.Area_comercial__c)).Value__c);//SF00007

        System.debug('----> OportunidadUtil generarCodigoOportunidad2 valorContador: ' + valorContador);
        System.debug('----> OportunidadUtil generarCodigoOportunidad2 type: ' + type);    
        log = log + '----> OportunidadUtil generarCodigoOportunidad2 valorContador: ' + valorContador;
        log = log + '----> OportunidadUtil generarCodigoOportunidad2 type: ' + type;

        //if (opp.RecordTypeId == Constantes.RT_OPP_VSC)
        if (type == Constantes.RT_OPP_VSC)//SF00007
        {
            System.debug('----> OportunidadUtil generarCodigoOportunidad2 Constantes.RT_OPP_VSC');
            log = log + '----> OportunidadUtil generarCodigoOportunidad2 Constantes.RT_OPP_VSC';
            opp.Codigo_de_oportunidad__c = cuenta.VSC_Codigo_Veolia__c
            + Constantes.MAPA_VSC_DIVISIONES.get(opp.Area_comercial__c)
            + padString(valorContador, 4, '0');
        }
        //else if (opp.RecordTypeId == Constantes.RT_OPP_GIROA)
        else if (type == Constantes.RT_OPP_GIROA)//SF00007
        {
            System.debug('----> OportunidadUtil generarCodigoOportunidad2 Constantes.RT_OPP_GIROA');
            log = log + '----> OportunidadUtil generarCodigoOportunidad2 Constantes.RT_OPP_GIROA';
            opp.Codigo_de_oportunidad__c = Constantes.TAG_GIROA
            + Date.today().year()
            + padString(valorContador, 4, '0');
        }
        //else if(opp.RecordTypeId == Constantes.RT_OPP_CONTRACTING)
        else if(type == Constantes.RT_OPP_CONTRACTING)//SF00007
        {
            System.debug('----> OportunidadUtil generarCodigoOportunidad2 Constantes.RT_OPP_CONTRACTING');
            log = log + '----> OportunidadUtil generarCodigoOportunidad2 Constantes.RT_OPP_CONTRACTING';
            opp.Codigo_de_oportunidad__c = cuenta.CONTRACTING_Codigo_Veolia__c 
            + padString(valorContador, 4, '0');
        }
        else if(type == Constantes.RT_OPP_VRM)
        {
            System.debug('----> OportunidadUtil generarCodigoOportunidad2 Constantes.RT_OPP_VRM');
            log = log + '----> OportunidadUtil generarCodigoOportunidad2 Constantes.RT_OPP_VRM';
            opp.Codigo_de_oportunidad__c = Constantes.TAG_VRM
            + Date.today().year()
            + padString(valorContador, 4, '0');
        }
        else if(type == Constantes.RT_OPP_VP_LR)
        {
            System.debug('----> OportunidadUtil generarCodigoOportunidad2 Constantes.RT_OPP_VP_LR');
            log = log + '----> OportunidadUtil generarCodigoOportunidad2 Constantes.RT_OPP_VP_LR';
            opp.Codigo_de_oportunidad__c = Constantes.TAG_VP_LR
            + Date.today().year()
            + padString(valorContador, 4, '0');
        }
        else if(type == Constantes.RT_OPP_VP_TP)
        {
            System.debug('----> OportunidadUtil generarCodigoOportunidad2 Constantes.RT_OPP_VP_TP');
            log = log + '----> OportunidadUtil generarCodigoOportunidad2 Constantes.RT_OPP_VP_TP';
            opp.Codigo_de_oportunidad__c = Constantes.TAG_VP_TP
            + Date.today().year()
            + padString(valorContador, 4, '0');
        }
        else if(type == Constantes.RT_OPP_VSOL)
        {
            System.debug('----> OportunidadUtil generarCodigoOportunidad2 Constantes.RT_OPP_VSOL');
            log = log + '----> OportunidadUtil generarCodigoOportunidad2 Constantes.RT_OPP_VSOL';
            opp.Codigo_de_oportunidad__c = Constantes.TAG_VSOL
            + Date.today().year()
            + padString(valorContador, 4, '0');
        }
        else if(type == Constantes.RT_OPP_ECOE)
        {
            System.debug('----> OportunidadUtil generarCodigoOportunidad2 Constantes.RT_OPP_ECOE');
            log = log + '----> OportunidadUtil generarCodigoOportunidad2 Constantes.RT_OPP_ECOE';
             // Mapear valor de Area Comercial
            String areaComercialAbreviada = '';
            if (opp.Area_comercial__c == 'ECO Energía') {
                areaComercialAbreviada = 'E';
            } else if (opp.Area_comercial__c == 'ECO Servicios') {
                areaComercialAbreviada = 'S';
    }
            opp.Codigo_de_oportunidad__c = Constantes.TAG_ECOE
            + Date.today().year()
            + areaComercialAbreviada
            + opp.ECO_n_subestaci_n__c
            + opp.ECO_Tipo_de_subestaci_n__c
            + opp.ECO_Tipo_servicio__c
            + padString(valorContador, 4, '0');
        }
        //JCD Oct 2025 Geotermia
        else if(type == Constantes.RT_OPP_GEO)
        {
            System.debug('----> OportunidadUtil generarCodigoOportunidad2 Constantes.RT_OPP_GEO');
            log = log + '----> OportunidadUtil generarCodigoOportunidad2 Constantes.RT_OPP_GEO';
             // Mapear valor de Area Comercial
            String areaComercialAbreviada = '';
            if (opp.Area_comercial__c == 'Groen') {
                areaComercialAbreviada = 'GROEN';
            } else if (opp.Area_comercial__c == 'Geoter') {
                areaComercialAbreviada = 'GEOTER';
    }
            opp.Codigo_de_oportunidad__c = Constantes.TAG_GEO
            + Date.today().year()
            + areaComercialAbreviada
            + padString(valorContador, 4, '0');
        }

        
        System.debug('----> OportunidadUtil generarCodigoOportunidad2 opp.Codigo_de_oportunidad__c: ' + opp.Codigo_de_oportunidad__c);
        log = log + '----> OportunidadUtil generarCodigoOportunidad2 opp.Codigo_de_oportunidad__c: ' + opp.Codigo_de_oportunidad__c;
        
        Integer maxSize = 131000;
        if(log.length() > maxSize ){
            log = log.substring(0, maxSize);
        }

        opp.VL_Log__c = log;
    }



    /** 
     * recuperaCuentasDeOportunidades
     **
     * Recupera las cuentas relacionadas con las oportunidades
     **
     * @Evento: BEFORE INSERT
     **
     * @Autor: jmartinezpisson (11/04/2016)
     **
     * @Modificaciones: -
     **
     * @param: List<Opportunity> opp -> Oportunidades relacionadas con las cuentas a recuperar
     **
     * @return: Map<Id, Account> Mapa de cuentas organizado por Id de oportunidad
     **/
    public static Map<Id, Account> recuperaCuentasDeOportunidades(List<Opportunity> oppList)
    {
        Set<Id> cuentasIdSet = new Set<Id> ();
        Map<Id, Account> cuentasMap = new Map<Id, Account> ();

        for (Opportunity opp : oppList)
        {
            cuentasIdSet.add(opp.AccountId);
        }

        List<Account> accList = [SELECT Id, C_digo_Veolia__c, GIROA_Codigo_Veolia__c, VSC_COdigo_Veolia__c, CONTRACTING_Codigo_Veolia__c FROM Account WHERE Id IN :cuentasIdSet];

        return new Map<Id, Account> (accList);
    }

    /** 
     * padString
     **
     * Añade a la izquierda de una cadenael string padChar tantas veces como sea neceario para igualar la longitud indicada
     **
     * @Autor: jmartinezpisson (11/04/2016)
     **
     * @Modificaciones: -
     **
     * @param: Object str => Valor ANY que se convertirá en texto
     *        Integer longitud => Longitud del texto resultante
     *        String padChar => Caracter a añadir
     **
     * @return: Atring Texto formateado
     **/
    private static String padString(Object str, Integer longitud, String padChar)
    {
        String cadena = String.valueOf(str);

        for (Integer i = (longitud - cadena.length()); i > 0; i--)
        {
            cadena = padChar + cadena;
        }

        return cadena;
    }
}