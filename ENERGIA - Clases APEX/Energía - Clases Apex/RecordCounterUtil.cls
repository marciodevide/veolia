public class RecordCounterUtil 
{
    /** 
    * contadores - Mapa de CustomSetting RecordCounter__c
    **/
    private static Map<String, RecordCounter__c> contadores = RecordCounter__c.getAll().clone();

    /** 
    * recuperaContadorOportunidad
    **
    * Recupera los contadores de oportunidad reiniciando los correspondientes en cambio de ao
    **
    * @Autor: jmartinezpisson (11/04/2016)
    **
    * @Modificaciones: jmartinezpisson (27/04/2016) Añadido el conteo por delegación VSC
    **
    * @param: -
    **
    * @return:  Map<String, RecordCounter__c> Mapa de contadores organizado por RecordTypeId
    **/
    public static Map<String, RecordCounter__c> recuperaContadorOportunidad()
    {
        Map<String, RecordCounter__c> contadorMap = new Map<String, RecordCounter__c> ();

        for(RecordCounter__c contador : contadores.values()){
            System.debug('*************** contador: ' + contador);
        }

        // Se crean los contadores con los valores por defecto en caso de que no existan
        if ( !contadores.containsKey(Constantes.CONTADOR_OPP_GIROA) )
        {
            contadores.put ( 
                Constantes.CONTADOR_OPP_GIROA,
                new RecordCounter__c (
                    Name = Constantes.CONTADOR_OPP_GIROA,
                    SObject__c = 'Opportunity',
                    Description__c = 'Contador de oportunidades de la filial GIROA',
                    RecordType__c = Constantes.RT_OPP_GIROA,
                    Value__c = 0
                )
            );
        }

        if ( !contadores.containsKey(Constantes.CONTADOR_OPP_VSL) )
        {
            contadores.put ( 
                Constantes.CONTADOR_OPP_VSL,
                new RecordCounter__c (
                    Name = Constantes.CONTADOR_OPP_VSL,
                    SObject__c = 'Opportunity',
                    Description__c = 'Contador de oportunidades de la filial VSL',
                    RecordType__c = Constantes.RT_OPP_VSL,
                    Value__c = 0
                )
            );
        }

        if ( !contadores.containsKey(Constantes.CONTADOR_OPP_VSC) )
        {
            contadores.put ( 
                Constantes.CONTADOR_OPP_VSC,
                new RecordCounter__c (
                    Name = Constantes.CONTADOR_OPP_VSC,
                    SObject__c = 'Opportunity',
                    Description__c = 'Contador de oportunidades de la filial VSC',
                    RecordType__c = Constantes.RT_OPP_VSC,
                    Value__c = 0
                )
            );
            
            for(String k : Constantes.MAPA_VSC_DIVISIONES.values())
            {
                if ( !contadores.containsKey(Constantes.CONTADOR_OPP_VSC + k) )
                {
                    contadores.put ( 
                        Constantes.CONTADOR_OPP_VSC + '.' + k,
                        new RecordCounter__c (
                            Name = Constantes.CONTADOR_OPP_VSC + '.' + k,
                            SObject__c = 'Opportunity',
                            Description__c = 'Contador de oportunidades de la filial VSC para la delegación '+ k,
                            RecordType__c = Constantes.RT_OPP_VSC,
                            Division__c = k,
                            Value__c = 0
                        )
                    );
                 }               
            }       
        }

        if ( !contadores.containsKey(Constantes.CONTADOR_OPP_CONTRACTING) )
        {
            contadores.put ( 
                Constantes.CONTADOR_OPP_CONTRACTING,
                new RecordCounter__c (
                    Name = Constantes.CONTADOR_OPP_CONTRACTING,
                    SObject__c = 'Opportunity',
                    Description__c = 'Contador de oportunidades de la filial CONTRACTING',
                    RecordType__c = Constantes.RT_OPP_CONTRACTING,
                    Value__c = 0
                )
            );
            
        }

        if ( !contadores.containsKey(Constantes.CONTADOR_OPP_VRM) )
        {
            contadores.put ( 
                Constantes.CONTADOR_OPP_VRM,
                new RecordCounter__c (
                    Name = Constantes.CONTADOR_OPP_VRM,
                    SObject__c = 'Opportunity',
                    Description__c = 'Contador de oportunidades de la filial VRM',
                    RecordType__c = Constantes.RT_OPP_VRM,
                    Value__c = 0
                )
            );
            
        }

        if ( !contadores.containsKey(Constantes.CONTADOR_OPP_VP_LR) )
        {
            contadores.put ( 
                Constantes.CONTADOR_OPP_VP_LR,
                new RecordCounter__c (
                    Name = Constantes.CONTADOR_OPP_VP_LR,
                    SObject__c = 'Opportunity',
                    Description__c = 'Contador de oportunidades de la filial VP_LR',
                    RecordType__c = Constantes.RT_OPP_VP_LR,
                    Value__c = 0
                )
            );
            
        }

        if ( !contadores.containsKey(Constantes.CONTADOR_OPP_VP_TP) )
        {
            contadores.put ( 
                Constantes.CONTADOR_OPP_VP_TP,
                new RecordCounter__c (
                    Name = Constantes.CONTADOR_OPP_VP_TP,
                    SObject__c = 'Opportunity',
                    Description__c = 'Contador de oportunidades de la filial VP_TP',
                    RecordType__c = Constantes.RT_OPP_VP_TP,
                    Value__c = 0
                )
            );
            
        }

        if ( !contadores.containsKey(Constantes.CONTADOR_OPP_VSOL) )
        {
            contadores.put ( 
                Constantes.CONTADOR_OPP_VSOL,
                new RecordCounter__c (
                    Name = Constantes.CONTADOR_OPP_VSOL,
                    SObject__c = 'Opportunity',
                    Description__c = 'Contador de oportunidades de la filial VSOL',
                    RecordType__c = Constantes.RT_OPP_VSOL,
                    Value__c = 0
                )
            );
            
        }

        // Se genera un mapa ordenado por Record type de oportunidad
        contadorMap.put(Constantes.RT_OPP_VSL, contadores.get(Constantes.CONTADOR_OPP_VSL));
        contadorMap.put(Constantes.RT_OPP_VSC, contadores.get(Constantes.CONTADOR_OPP_VSC));
        contadorMap.put(Constantes.RT_OPP_CONTRACTING, contadores.get(Constantes.CONTADOR_OPP_CONTRACTING));
        contadorMap.put(Constantes.RT_OPP_VRM, contadores.get(Constantes.CONTADOR_OPP_VRM));
        
        contadorMap.put(Constantes.RT_OPP_VP_LR, contadores.get(Constantes.CONTADOR_OPP_VP_LR));
        contadorMap.put(Constantes.RT_OPP_VP_TP, contadores.get(Constantes.CONTADOR_OPP_VP_TP));
        contadorMap.put(Constantes.RT_OPP_VSOL, contadores.get(Constantes.CONTADOR_OPP_VSOL));
        contadorMap.put(Constantes.RT_OPP_ECOE, contadores.get(Constantes.CONTADOR_OPP_ECOE));
        //JCD Oct 2025 Geotermia
        contadorMap.put(Constantes.RT_OPP_GEO, contadores.get(Constantes.CONTADOR_OPP_GEO));
        
        //  Divisiones VSC y CONTRACTING
        for(String k : Constantes.MAPA_VSC_DIVISIONES.values())
        {
            contadorMap.put(Constantes.RT_OPP_VSC + k, contadores.get(Constantes.CONTADOR_OPP_VSC + '.' + k));
        }
        

        // Para GIROA, el contador debe reiniciarse cada año
        RecordCounter__c contadorGIROA = contadores.get(Constantes.CONTADOR_OPP_GIROA);

        if (contadorGIROA.LastModifiedDate != null && contadorGIROA.LastModifiedDate.year() != Date.today().year())
        {
            contadorGIROA.Value__c = 0;
        }

        contadorMap.put(Constantes.RT_OPP_GIROA, contadorGIROA);

        return contadorMap;
    }

    /** 
    * contadorCommit
    **
    * Actualiza en base de datos los valores de contadores
    **
    * @Autor: jmartinezpisson (11/04/2016)
    **
    * @Modificaciones: -
    **
    * @param: -
    **
    * @return: -
    **/
    public static void contadorCommit()
    {
        upsert contadores.values();
    }
}