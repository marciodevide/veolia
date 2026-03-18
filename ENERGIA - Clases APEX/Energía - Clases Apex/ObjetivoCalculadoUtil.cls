public class ObjetivoCalculadoUtil {
    public ObjetivoCalculadoUtil() {}

    public static void procesarOportunidades(list<Objetivo_Calculado__c> newList)
    {
        Date myDate = Date.today();
        Integer day = myDate.day();


       List<Opportunity> listaOp = [SELECT Anyo__c,Area_comercial__c,Cliente_nivel_actividad_1__c,Cliente_Nivel_Actividad_2__c,Cliente_Nivel_Actividad_3__c,Id,Linea_de_negocio__c,Objetivo_Calculado_Agrupado__c,Objetivo_individual__c,Servicio_nivel_actividad_1__c,Servicio_Nivel_Actividad_2__c,Servicio_nivel_actividad_3__c,Tipo__c FROM Opportunity WHERE CALENDAR_YEAR(LastModifiedDate) = :day];
        List<Objetivo_Calculado__c> ocHijas = [SELECT Id, Area_principal__c, rea_Comercial_Lista__c FROM Objetivo_Calculado__c WHERE Agrupado__c = false];
    
        for (Objetivo_Calculado__c oc : newList)
        {
            if (oc.Agrupado__c == true)
            {
                System.debug('entroif');

                String areaOC = oc.Area_Comercial__c;
                areaOC = areaOC.subString(0,15);
                            
                //List<Objetivo_Calculado__c> ocHijas = [SELECT Id, rea_Comercial_Lista__c FROM Objetivo_Calculado__c WHERE Area_principal__c =: areaOC];

                List<Objetivo_Calculado__c> ocHijasActual = new List<Objetivo_Calculado__c>();

                for (Objetivo_Calculado__c ochijo : ocHijas)
                {
                    if (ochijo.Area_principal__c == areaOC)
                    {
                        ocHijasActual.add(ochijo);
                    }
                }


                //listaOp =[SELECT Id,Anyo__c Objetivo_individual__c, Area_comercial__c, Objetivo_Calculado_Agrupado__c FROM Opportunity WHERE Anyo__c = : oc.Anyo__c AND Cliente_Nivel_Actividad_2__c = : oc.Cliente_Nivel_Actividad_2__c  AND  Cliente_Nivel_Actividad_3__c = : oc.Cliente_Nivel_Actividad_3__c AND Linea_de_negocio__c = : oc.L_nea_de_negocio__c AND Servicio_Nivel_Actividad_1__c = : oc.Servicio_Nivel_Actividad_1__c AND Servicio_Nivel_Actividad_2__c = : oc.Servicio_Nivel_Actividad_2__c AND Servicio_Nivel_Actividad_3__c = : oc.Servicio_Nivel_Actividad_3__c AND Tipo__c = : oc.Tipo__c];
                
                List<Opportunity> listaOpActual = new List<Opportunity>();

                for (Opportunity o : listaOp)
                {
                    if (o.Anyo__c == oc.Anyo__c && o.Cliente_Nivel_Actividad_2__c == oc.Cliente_Nivel_Actividad_2__c  &&  o.Cliente_Nivel_Actividad_3__c == oc.Cliente_Nivel_Actividad_3__c && o.Linea_de_negocio__c == oc.L_nea_de_negocio__c && o.Servicio_Nivel_Actividad_1__c == oc.Servicio_Nivel_Actividad_1__c && o.Servicio_Nivel_Actividad_2__c == oc.Servicio_Nivel_Actividad_2__c && o.Servicio_Nivel_Actividad_3__c == oc.Servicio_Nivel_Actividad_3__c && o.Tipo__c == oc.Tipo__c)
                    {
                        listaOpActual.add(o);
                    }
                }
               
                for (Opportunity o : listaOpActual)
                {
                    Integer count = 0;
                    Boolean encontrado = false;
                    
                    if (ocHijasActual.size() > 0)
                    {
                        do 
                        {
                            Objetivo_Calculado__c ocHi = ocHijasActual[count];
                            
                            System.debug(ocHi.rea_Comercial_Lista__c);
                            System.debug(o.Area_Comercial__c);

                            if (ocHi.rea_Comercial_Lista__c == o.Area_Comercial__c)
                            {
                                o.Objetivo_Calculado_Agrupado__c = oc.Id;
                                encontrado = true;
                            }
                            
                            count++;
                        } 
                        while (encontrado == false && count < ocHijasActual.size());
                    }
 
                } 

            }

            else
            {
                System.debug('entroelse');

                //listaOp = [SELECT Id, Objetivo_individual__c, Objetivo_Calculado_Agrupado__c FROM Opportunity WHERE Anyo__c =: oc.Anyo__c AND Cliente_Nivel_Actividad_2__c =: oc.Cliente_Nivel_Actividad_2__c AND  Cliente_Nivel_Actividad_3__c =: oc.Cliente_Nivel_Actividad_3__c AND Linea_de_negocio__c =: oc.L_nea_de_negocio__c AND Area_Comercial__c =: oc.rea_Comercial_Lista__c AND Servicio_Nivel_Actividad_1__c =: oc.Servicio_Nivel_Actividad_1__c AND Servicio_Nivel_Actividad_2__c =: oc.Servicio_Nivel_Actividad_2__c AND Servicio_Nivel_Actividad_3__c =: oc.Servicio_Nivel_Actividad_3__c AND Tipo__c =: oc.Tipo__c];
                
                for (Opportunity opo : listaOp)
                {
                    if (opo.Anyo__c == oc.Anyo__c && opo.Cliente_Nivel_Actividad_2__c == oc.Cliente_Nivel_Actividad_2__c && opo.Cliente_Nivel_Actividad_3__c == oc.Cliente_Nivel_Actividad_3__c && opo.Linea_de_negocio__c == oc.L_nea_de_negocio__c && opo.Area_Comercial__c == oc.rea_Comercial_Lista__c && opo.Servicio_Nivel_Actividad_1__c == oc.Servicio_Nivel_Actividad_1__c && opo.Servicio_Nivel_Actividad_2__c == oc.Servicio_Nivel_Actividad_2__c && opo.Servicio_Nivel_Actividad_3__c == oc.Servicio_Nivel_Actividad_3__c && opo.Tipo__c == oc.Tipo__c)
                    {
                        opo.Objetivo_individual__c = oc.Id;
                    }
                    
                }
                
            }
        }
        
        update listaOp;
    }
}