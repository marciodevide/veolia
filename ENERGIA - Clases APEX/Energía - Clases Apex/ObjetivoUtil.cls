public class ObjetivoUtil {
	
	public ObjetivoUtil() {}

	public static void reiniciarClaveUnica(list<Objetivo__c> newList)
	{

		List<Objetivo__c> listaOb = new List<Objetivo__c>();
		
		for(Objetivo__c o : newList)
		{
            System.debug(o);
			o.Clave_unica__c = o.Cliente_Nivel_Actividad_1__c.left(2)+'-' + o.Cliente_Nivel_Actividad_2__c.left(4) + '-' + o.Cliente_Nivel_Actividad_3__c.left(6) + '-' + o.Servicio_Nivel_Actividad_1__c.left(2) + '-' + o.Servicio_Nivel_Actividad_2__c.left(3) + '-' + o.Servicio_Nivel_Actividad_3__c.left(3) + '-' + o.L_nea_de_negocio__c.left(2) + '-' + o.Anyo__c +'-' + o.Tipo__c+ '-'+o.Area_comercial__c +'-' +o.Revision_objetivo__c; 
		}
	}

	/*public static void borrarObjetivoCalculado(list<Objetivo__c> newList)
	{
		List<Id> objetivosCalculadosId = new List<Id>();
		

		
		for(Objetivo__c o : newList)
		{
			objetivosCalculadosId.add(o.Objetivo_calculado__c);
		}

		List<Objetivo_calculado__c> listaOb = [SELECT Id FROM Objetivo_calculado__c WHERE Id in : objetivosCalculadosId];

		delete listaOb;
	}*/
    

    /**
    * borrarObjetivoCalculadoVacio
    * 	Busca y elimina TODOS los objetivos calculados que se hayam quedado huerfanos de objetivos( o lo que es lo mismo,
    *   que estén vacíos)
    **
    * @Autor jmartinezpisson(24/06/2015)
    **
    * @Modificaciones: -
    **
    * @param: -
    **
    * @return -
    **/
    public static void borrarObjetivoCalculadoVacio()
    {
        List<Objetivo_Calculado__c> cObj2Delete = [
            SELECT  Id 
			 FROM Objetivo_Calculado__c 
             WHERE Id NOT IN (
              	SELECT Objetivo_Calculado__c 
                 FROM Objetivo__c
             )
		];
        
        System.debug('Set cObjIds para borrar:' + cObj2Delete);
        
        delete cObj2Delete;
    }


	/**
    * borrarActualizarObjetivoCalculado
    * 	Al eliminar un objetivo actualiza los valores de la revisión afectada
	**
    * @Autor: lmartinez (xx/xx/2015)
    **
    * @Modificaciones: jmartinezpisson(02/05/2016) Modificada para actualizar valores  por prestaciones. Solo se cargan prestaciones hasta revision LE3
    **
    * @param: -
    **
    * @return -
    **/
	public static void borrarActualizarObjetivoCalculado(list<Objetivo__c> newList)
	{
		List<Id> objetivosCalculadosId = new List<Id>();
		
		for(Objetivo__c o : newList)
		{
			objetivosCalculadosId.add(o.Objetivo_calculado__c);
		}

		List<Objetivo_calculado__c> listaOb = [SELECT Id, CBudgetCom__c,CBudget__c,CLE0__c,CLE1__c,CLE2__c,CLE3__c,CM1__c,CM2__c,CM3__c,CM4__c,CM5__c,CM6__c,CM7__c,CM8__c,CM9__c,CM10__c,CM11__c,CM12__c,CNBudgetCom__c,CNBudget__c,CNLE0__c,CNLE1__c,CNLE2__c,CNLE3__c,CNM1__c,CNM2__c,CNM3__c,CNM4__c,CNM5__c,CNM6__c,CNM7__c,CNM8__c,CNM9__c,CNM10__c,CNM11__c,CNM12__c,CNR1__c,CNR2__c,CNR3__c,CNR4__c,CR1__c,CR2__c,CR3__c,CR4__c, OPBudgetcom__c,OPBudget__c,OPLE0__c,OPLE1__c,OPLE2__c,OPLE3__c,OPM1__c,OPM2__c,OPM3__c,OPM4__c,OPM5__c,OPM6__c,OPM7__c,OPM8__c,OPM9__c,OPM10__c,OPM11__c,OPM12__c,OPR1__c,OPR2__c,OPR3__c,OPR4__c,OptyBudgetCom__c,OptyBudget__c,OptyLE0__c,OptyLE1__c,OptyLE2__c,OptyLE3__c,OptyM1__c,OptyM2__c,OptyM3__c,OptyM4__c,OptyM5__c,OptyM6__c,OptyM7__c,OptyM8__c,OptyM9__c,OptyM10__c,OptyM11__c,OptyM12__c,OptyR1__c,OptyR2__c,OptyR3__c,OptyR4__c,
												CNP1LE1__c,CP1LE1__c,CNP2LE1__c,CP2LE1__c,CNP3LE1__c,CP3LE1__c,CNP4LE1__c,CP4LE1__c, CNP4IFRSLE1__c,CP4IFRSLE1__c,CNP6LE1__c,CP6LE1__c,
												CNP1LE2__c,CP1LE2__c,CNP2LE2__c,CP2LE2__c,CNP3LE2__c,CP3LE2__c,CNP4LE2__c,CP4LE2__c, CNP4IFRSLE2__c,CP4IFRSLE2__c,CNP6LE2__c,CP6LE2__c,
												CNP1LE3__c,CP1LE3__c,CNP2LE3__c,CP2LE3__c,CNP3LE3__c,CP3LE3__c,CNP4LE3__c,CP4LE3__c, CNP4IFRSLE3__c,CP4IFRSLE3__c,CNP6LE3__c,CP6LE3__c,
												CNP1LE0__c,CP1LE0__c,CNP2LE0__c,CP2LE0__c,CNP3LE0__c,CP3LE0__c,CNP4LE0__c,CP4LE0__c, CNP4IFRSLE0__c,CP4IFRSLE0__c,CNP6LE0__c,CP6LE0__c,
												CNP1Budget__c,CP1Budget__c,CNP2Budget__c,CP2Budget__c,CNP3Budget__c,CP3Budget__c,CNP4Budget__c,CP4Budget__c, CNP4IFRSBudget__c,CP4IFRSBudget__c,CNP6Budget__c,CP6Budget__c,
												CNP1Budgetcom__c,CP1Budgetcom__c,CNP2Budgetcom__c,CP2Budgetcom__c,CNP3Budgetcom__c,CP3Budgetcom__c,CNP4Budgetcom__c,CP4Budgetcom__c, CNP4IFRSBudgetcom__c,CP4IFRSBudgetcom__c,CNP6Budgetcom__c,CP6Budgetcom__c
												FROM Objetivo_calculado__c WHERE Id in : objetivosCalculadosId];

		Map<Id, Objetivo_calculado__c> mapaOc = new Map<Id, Objetivo_calculado__c>();

		for (Objetivo_calculado__c oc : listaOb)
		{
			mapaOc.put(oc.Id, oc);
		}

		List<Objetivo_calculado__c> listaActualizar = new List<Objetivo_calculado__c>();

		for(Objetivo__c o : newList)
		{

			Objetivo_calculado__c ocalc = mapaOc.get(o.Objetivo_calculado__c);

			if (o.Revision_objetivo__c == 'Budget')
			{
				if ((ocalc.CNBudget__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNBudget__c = ocalc.CNBudget__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CBudget__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CBudget__c = ocalc.CBudget__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyBudget__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyBudget__c = ocalc.OptyBudget__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPBudget__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPBudget__c = ocalc.OPBudget__c - o.Ofertas_presentadas__c;
				}				


				// MODIFICACIÓN 1: Prestaciones
				if ((ocalc.CNP1Budget__c != null) && (o.Cifra_de_negocio_P1__c != null))
				{
					ocalc.CNP1Budget__c = ocalc.CNP1Budget__c - o.Cifra_de_negocio_P1__c;
				}

				if ((ocalc.CP1Budget__c != null) && (o.Coste_P1__c != null))
				{
					ocalc.CP1Budget__c = ocalc.CP1Budget__c - o.Coste_P1__c;
				}	

				if ((ocalc.CNP2Budget__c != null) && (o.Cifra_de_negocio_P2__c != null))
				{
					ocalc.CNP2Budget__c = ocalc.CNP2Budget__c - o.Cifra_de_negocio_P2__c;
				}

				if ((ocalc.CP2Budget__c != null) && (o.Coste_P2__c != null))
				{
					ocalc.CP2Budget__c = ocalc.CP2Budget__c - o.Coste_P2__c;
				}
					
				if ((ocalc.CNP3Budget__c != null) && (o.Cifra_de_negocio_P3__c != null))
				{
					ocalc.CNP3Budget__c = ocalc.CNP3Budget__c - o.Cifra_de_negocio_P3__c;
				}

				if ((ocalc.CP3Budget__c != null) && (o.Coste_P3__c != null))
				{
					ocalc.CP3Budget__c = ocalc.CP3Budget__c - o.Coste_P3__c;
				}	

				if ((ocalc.CNP4Budget__c != null) && (o.Cifra_de_negocio_P4__c != null))
				{
					ocalc.CNP4Budget__c = ocalc.CNP4Budget__c - o.Cifra_de_negocio_P4__c;
				}

				if ((ocalc.CP4Budget__c != null) && (o.Coste_P4__c != null))
				{
					ocalc.CP4Budget__c = ocalc.CP4Budget__c - o.Cifra_de_negocio_P6__c;
				}	

				if ((ocalc.CNP4IFRSBudget__c != null) && (o.Cifra_de_negocio_P4_IFRS__c != null))
				{
					ocalc.CNP4IFRSBudget__c = ocalc.CNP4IFRSBudget__c - o.Cifra_de_negocio_P4_IFRS__c;
				}

				if ((ocalc.CNP4IFRSBudget__c != null) && (o.Coste_P4_IFRS__c != null))
				{
					ocalc.CNP4IFRSBudget__c = ocalc.CNP4IFRSBudget__c - o.Coste_P4_IFRS__c;
				}	

				if ((ocalc.CNP6Budget__c != null) && (o.Cifra_de_negocio_P6__c != null))
				{
					ocalc.CNP6Budget__c = ocalc.CNP6Budget__c - o.Cifra_de_negocio_P6__c;
				}

				if ((ocalc.CP6Budget__c != null) && (o.Coste_P6__c != null))
				{
					ocalc.CP6Budget__c = ocalc.CP6Budget__c - o.Coste_P6__c;
				}	
				// FIN MODIFICACIÓN

				listaActualizar.add(ocalc);

			}
			else if (o.Revision_objetivo__c == 'Budget comercial')
			{
				if ((ocalc.CNBudgetCom__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNBudgetCom__c = ocalc.CNBudgetCom__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CBudgetCom__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CBudgetCom__c = ocalc.CBudgetCom__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyBudgetCom__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyBudgetCom__c = ocalc.OptyBudgetCom__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPBudgetCom__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPBudgetCom__c = ocalc.OPBudgetCom__c - o.Ofertas_presentadas__c;
				}				

				// MODIFICACIÓN 1: Prestaciones
				if ((ocalc.CNP1Budgetcom__c != null) && (o.Cifra_de_negocio_P1__c != null))
				{
					ocalc.CNP1Budgetcom__c = ocalc.CNP1Budgetcom__c - o.Cifra_de_negocio_P1__c;
				}

				if ((ocalc.CP1Budgetcom__c != null) && (o.Coste_P1__c != null))
				{
					ocalc.CP1Budgetcom__c = ocalc.CP1Budgetcom__c - o.Coste_P1__c;
				}	

				if ((ocalc.CNP2Budgetcom__c != null) && (o.Cifra_de_negocio_P2__c != null))
				{
					ocalc.CNP2Budgetcom__c = ocalc.CNP2Budgetcom__c - o.Cifra_de_negocio_P2__c;
				}

				if ((ocalc.CP2Budgetcom__c != null) && (o.Coste_P2__c != null))
				{
					ocalc.CP2Budgetcom__c = ocalc.CP2Budgetcom__c - o.Coste_P2__c;
				}
					
				if ((ocalc.CNP3Budgetcom__c != null) && (o.Cifra_de_negocio_P3__c != null))
				{
					ocalc.CNP3Budgetcom__c = ocalc.CNP3Budgetcom__c - o.Cifra_de_negocio_P3__c;
				}

				if ((ocalc.CP3Budgetcom__c != null) && (o.Coste_P3__c != null))
				{
					ocalc.CP3Budgetcom__c = ocalc.CP3Budgetcom__c - o.Coste_P3__c;
				}	

				if ((ocalc.CNP4Budgetcom__c != null) && (o.Cifra_de_negocio_P4__c != null))
				{
					ocalc.CNP4Budgetcom__c = ocalc.CNP4Budgetcom__c - o.Cifra_de_negocio_P4__c;
				}

				if ((ocalc.CP4Budgetcom__c != null) && (o.Coste_P4__c != null))
				{
					ocalc.CP4Budgetcom__c = ocalc.CP4Budgetcom__c - o.Coste_P4__c;
				}	

				if ((ocalc.CNP4IFRSBudgetcom__c != null) && (o.Cifra_de_negocio_P4_IFRS__c != null))
				{
					ocalc.CNP4IFRSBudgetcom__c = ocalc.CNP4IFRSBudgetcom__c - o.Cifra_de_negocio_P4_IFRS__c;
				}

				if ((ocalc.CNP4IFRSBudgetcom__c != null) && (o.Coste_P4_IFRS__c != null))
				{
					ocalc.CNP4IFRSBudgetcom__c = ocalc.CNP4IFRSBudgetcom__c - o.Coste_P4_IFRS__c;
				}	

				if ((ocalc.CNP6Budgetcom__c != null) && (o.Cifra_de_negocio_P6__c != null))
				{
					ocalc.CNP6Budgetcom__c = ocalc.CNP6Budgetcom__c - o.Cifra_de_negocio_P6__c;
				}

				if ((ocalc.CP6Budgetcom__c != null) && (o.Coste_P6__c != null))
				{
					ocalc.CP6Budgetcom__c = ocalc.CP6Budgetcom__c - o.Coste_P6__c;
				}	
				// FIN MODIFICACIÓN

				listaActualizar.add(ocalc);

			}
			else if (o.Revision_objetivo__c == 'LE0')
			{
				if ((ocalc.CNLE0__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNLE0__c = ocalc.CNLE0__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CLE0__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CLE0__c = ocalc.CLE0__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyLE0__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyLE0__c = ocalc.OptyLE0__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPLE0__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPLE0__c = ocalc.OPLE0__c - o.Ofertas_presentadas__c;
				}	

				// MODIFICACIÓN 1: Prestaciones
				if ((ocalc.CNP1LE0__c != null) && (o.Cifra_de_negocio_P1__c != null))
				{
					ocalc.CNP1LE0__c = ocalc.CNP1LE0__c - o.Cifra_de_negocio_P1__c;
				}

				if ((ocalc.CP1LE0__c != null) && (o.Coste_P1__c != null))
				{
					ocalc.CP1LE0__c = ocalc.CP1LE0__c - o.Coste_P1__c;
				}	

				if ((ocalc.CNP2LE0__c != null) && (o.Cifra_de_negocio_P2__c != null))
				{
					ocalc.CNP2LE0__c = ocalc.CNP2LE0__c - o.Cifra_de_negocio_P2__c;
				}

				if ((ocalc.CP2LE0__c != null) && (o.Coste_P2__c != null))
				{
					ocalc.CP2LE0__c = ocalc.CP2LE0__c - o.Coste_P2__c;
				}
					
				if ((ocalc.CNP3LE0__c != null) && (o.Cifra_de_negocio_P3__c != null))
				{
					ocalc.CNP3LE0__c = ocalc.CNP3LE0__c - o.Cifra_de_negocio_P3__c;
				}

				if ((ocalc.CP3LE0__c != null) && (o.Coste_P3__c != null))
				{
					ocalc.CP3LE0__c = ocalc.CP3LE0__c - o.Coste_P3__c;
				}	

				if ((ocalc.CNP4LE0__c != null) && (o.Cifra_de_negocio_P4__c != null))
				{
					ocalc.CNP4LE0__c = ocalc.CNP4LE0__c - o.Cifra_de_negocio_P4__c;
				}

				if ((ocalc.CP4LE0__c != null) && (o.Coste_P4__c != null))
				{
					ocalc.CP4LE0__c = ocalc.CP4LE0__c - o.Coste_P4__c;
				}	

				if ((ocalc.CNP4IFRSLE0__c != null) && (o.Cifra_de_negocio_P4_IFRS__c != null))
				{
					ocalc.CNP4IFRSLE0__c = ocalc.CNP4IFRSLE0__c - o.Cifra_de_negocio_P4_IFRS__c;
				}

				if ((ocalc.CNP4IFRSLE0__c != null) && (o.Coste_P4_IFRS__c != null))
				{
					ocalc.CNP4IFRSLE0__c = ocalc.CNP4IFRSLE0__c - o.Coste_P4_IFRS__c;
				}	

				if ((ocalc.CNP6LE0__c != null) && (o.Cifra_de_negocio_P6__c != null))
				{
					ocalc.CNP6LE0__c = ocalc.CNP6LE0__c - o.Cifra_de_negocio_P6__c;
				}

				if ((ocalc.CP6LE0__c != null) && (o.Coste_P6__c != null))
				{
					ocalc.CP6LE0__c = ocalc.CP6LE0__c - o.Coste_P6__c;
				}	
				// FIN MODIFICACIÓN

				listaActualizar.add(ocalc);
				
			}
			else if (o.Revision_objetivo__c == 'LE1')
			{

				if ((ocalc.CNLE1__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNLE1__c = ocalc.CNLE1__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CLE1__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CLE1__c = ocalc.CLE1__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyLE1__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyLE1__c = ocalc.OptyLE1__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPLE1__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPLE1__c = ocalc.OPLE1__c - o.Ofertas_presentadas__c;
				}	

				// MODIFICACIÓN 1: Prestaciones
				if ((ocalc.CNP1LE1__c != null) && (o.Cifra_de_negocio_P1__c != null))
				{
					ocalc.CNP1LE1__c = ocalc.CNP1LE1__c - o.Cifra_de_negocio_P1__c;
				}

				if ((ocalc.CP1LE1__c != null) && (o.Coste_P1__c != null))
				{
					ocalc.CP1LE1__c = ocalc.CP1LE1__c - o.Coste_P1__c;
				}	

				if ((ocalc.CNP2LE1__c != null) && (o.Cifra_de_negocio_P2__c != null))
				{
					ocalc.CNP2LE1__c = ocalc.CNP2LE1__c - o.Cifra_de_negocio_P2__c;
				}

				if ((ocalc.CP2LE1__c != null) && (o.Coste_P2__c != null))
				{
					ocalc.CP2LE1__c = ocalc.CP2LE1__c - o.Coste_P2__c;
				}
					
				if ((ocalc.CNP3LE1__c != null) && (o.Cifra_de_negocio_P3__c != null))
				{
					ocalc.CNP3LE1__c = ocalc.CNP3LE1__c - o.Cifra_de_negocio_P3__c;
				}

				if ((ocalc.CP3LE1__c != null) && (o.Coste_P3__c != null))
				{
					ocalc.CP3LE1__c = ocalc.CP3LE1__c - o.Coste_P3__c;
				}	

				if ((ocalc.CNP4LE1__c != null) && (o.Cifra_de_negocio_P4__c != null))
				{
					ocalc.CNP4LE1__c = ocalc.CNP4LE1__c - o.Cifra_de_negocio_P4__c;
				}

				if ((ocalc.CP4LE1__c != null) && (o.Coste_P4__c != null))
				{
					ocalc.CP4LE1__c = ocalc.CP4LE1__c - o.Coste_P4__c;
				}	

				if ((ocalc.CNP4IFRSLE1__c != null) && (o.Cifra_de_negocio_P4_IFRS__c != null))
				{
					ocalc.CNP4IFRSLE1__c = ocalc.CNP4IFRSLE1__c - o.Cifra_de_negocio_P4_IFRS__c;
				}

				if ((ocalc.CNP4IFRSLE1__c != null) && (o.Coste_P4_IFRS__c != null))
				{
					ocalc.CNP4IFRSLE1__c = ocalc.CNP4IFRSLE1__c - o.Coste_P4_IFRS__c;
				}	

				if ((ocalc.CNP6LE1__c != null) && (o.Cifra_de_negocio_P6__c != null))
				{
					ocalc.CNP6LE1__c = ocalc.CNP6LE1__c - o.Cifra_de_negocio_P6__c;
				}

				if ((ocalc.CP6LE1__c != null) && (o.Coste_P6__c != null))
				{
					ocalc.CP6LE1__c = ocalc.CP6LE1__c - o.Coste_P6__c;
				}	
				// FIN MODIFICACIÓN

				listaActualizar.add(ocalc);
			}
			else if (o.Revision_objetivo__c == 'LE2')
			{

				if ((ocalc.CNLE2__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNLE2__c = ocalc.CNLE2__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CLE2__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CLE2__c = ocalc.CLE2__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyLE2__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyLE2__c = ocalc.OptyLE2__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPLE2__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPLE2__c = ocalc.OPLE2__c - o.Ofertas_presentadas__c;
				}

				// MODIFICACIÓN 1: Prestaciones
				if ((ocalc.CNP1LE2__c != null) && (o.Cifra_de_negocio_P1__c != null))
				{
					ocalc.CNP1LE2__c = ocalc.CNP1LE2__c - o.Cifra_de_negocio_P1__c;
				}

				if ((ocalc.CP1LE2__c != null) && (o.Coste_P1__c != null))
				{
					ocalc.CP1LE2__c = ocalc.CP1LE2__c - o.Coste_P1__c;
				}	

				if ((ocalc.CNP2LE2__c != null) && (o.Cifra_de_negocio_P2__c != null))
				{
					ocalc.CNP2LE2__c = ocalc.CNP2LE2__c - o.Cifra_de_negocio_P2__c;
				}

				if ((ocalc.CP2LE2__c != null) && (o.Coste_P2__c != null))
				{
					ocalc.CP2LE2__c = ocalc.CP2LE2__c - o.Coste_P2__c;
				}
					
				if ((ocalc.CNP3LE2__c != null) && (o.Cifra_de_negocio_P3__c != null))
				{
					ocalc.CNP3LE2__c = ocalc.CNP3LE2__c - o.Cifra_de_negocio_P3__c;
				}

				if ((ocalc.CP3LE2__c != null) && (o.Coste_P3__c != null))
				{
					ocalc.CP3LE2__c = ocalc.CP3LE2__c - o.Coste_P3__c;
				}	

				if ((ocalc.CNP4LE2__c != null) && (o.Cifra_de_negocio_P4__c != null))
				{
					ocalc.CNP4LE2__c = ocalc.CNP4LE2__c - o.Cifra_de_negocio_P4__c;
				}

				if ((ocalc.CP4LE2__c != null) && (o.Coste_P4__c != null))
				{
					ocalc.CP4LE2__c = ocalc.CP4LE2__c - o.Coste_P4__c;
				}	

				if ((ocalc.CNP4IFRSLE2__c != null) && (o.Cifra_de_negocio_P4_IFRS__c != null))
				{
					ocalc.CNP4IFRSLE2__c = ocalc.CNP4IFRSLE2__c - o.Cifra_de_negocio_P4_IFRS__c;
				}

				if ((ocalc.CNP4IFRSLE2__c != null) && (o.Coste_P4_IFRS__c != null))
				{
					ocalc.CNP4IFRSLE2__c = ocalc.CNP4IFRSLE2__c - o.Coste_P4_IFRS__c;
				}	

				if ((ocalc.CNP6LE2__c != null) && (o.Cifra_de_negocio_P6__c != null))
				{
					ocalc.CNP6LE2__c = ocalc.CNP6LE2__c - o.Cifra_de_negocio_P6__c;
				}

				if ((ocalc.CP6LE2__c != null) && (o.Coste_P6__c != null))
				{
					ocalc.CP6LE2__c = ocalc.CP6LE2__c - o.Coste_P6__c;
				}	
				// FIN MODIFICACIÓN

				listaActualizar.add(ocalc);
			}
			else if (o.Revision_objetivo__c == 'LE3')
			{

				if ((ocalc.CNLE3__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNLE3__c = ocalc.CNLE3__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CLE3__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CLE3__c = ocalc.CLE3__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyLE3__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyLE3__c = ocalc.OptyLE3__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPLE3__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPLE3__c = ocalc.OPLE3__c - o.Ofertas_presentadas__c;
				}

				// MODIFICACIÓN 1: Prestaciones
				if ((ocalc.CNP1LE3__c != null) && (o.Cifra_de_negocio_P1__c != null))
				{
					ocalc.CNP1LE3__c = ocalc.CNP1LE3__c - o.Cifra_de_negocio_P1__c;
				}

				if ((ocalc.CP1LE3__c != null) && (o.Coste_P1__c != null))
				{
					ocalc.CP1LE3__c = ocalc.CP1LE3__c - o.Coste_P1__c;
				}	

				if ((ocalc.CNP2LE3__c != null) && (o.Cifra_de_negocio_P2__c != null))
				{
					ocalc.CNP2LE3__c = ocalc.CNP2LE3__c - o.Cifra_de_negocio_P2__c;
				}

				if ((ocalc.CP2LE3__c != null) && (o.Coste_P2__c != null))
				{
					ocalc.CP2LE3__c = ocalc.CP2LE3__c - o.Coste_P2__c;
				}
					
				if ((ocalc.CNP3LE3__c != null) && (o.Cifra_de_negocio_P3__c != null))
				{
					ocalc.CNP3LE3__c = ocalc.CNP3LE3__c - o.Cifra_de_negocio_P3__c;
				}

				if ((ocalc.CP3LE3__c != null) && (o.Coste_P3__c != null))
				{
					ocalc.CP3LE3__c = ocalc.CP3LE3__c - o.Coste_P3__c;
				}	

				if ((ocalc.CNP4LE3__c != null) && (o.Cifra_de_negocio_P4__c != null))
				{
					ocalc.CNP4LE3__c = ocalc.CNP4LE3__c - o.Cifra_de_negocio_P4__c;
				}

				if ((ocalc.CP4LE3__c != null) && (o.Coste_P4__c != null))
				{
					ocalc.CP4LE3__c = ocalc.CP4LE3__c - o.Coste_P4__c;
				}	

				if ((ocalc.CNP4IFRSLE3__c != null) && (o.Cifra_de_negocio_P4_IFRS__c != null))
				{
					ocalc.CNP4IFRSLE3__c = ocalc.CNP4IFRSLE3__c - o.Cifra_de_negocio_P4_IFRS__c;
				}

				if ((ocalc.CNP4IFRSLE3__c != null) && (o.Coste_P4_IFRS__c != null))
				{
					ocalc.CNP4IFRSLE3__c = ocalc.CNP4IFRSLE3__c - o.Coste_P4_IFRS__c;
				}	

				if ((ocalc.CNP6LE3__c != null) && (o.Cifra_de_negocio_P6__c != null))
				{
					ocalc.CNP6LE3__c = ocalc.CNP6LE3__c - o.Cifra_de_negocio_P6__c;
				}

				if ((ocalc.CP6LE3__c != null) && (o.Coste_P6__c != null))
				{
					ocalc.CP6LE3__c = ocalc.CP6LE3__c - o.Coste_P6__c;
				}	
				// FIN MODIFICACIÓN

				listaActualizar.add(ocalc);
			}
			else if (o.Revision_objetivo__c == 'M1')
			{

				if ((ocalc.CNM1__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNM1__c = ocalc.CNM1__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CM1__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CM1__c = ocalc.CM1__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyM1__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyM1__c = ocalc.OptyM1__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPM1__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPM1__c = ocalc.OPM1__c - o.Ofertas_presentadas__c;
				}

				listaActualizar.add(ocalc);
			}
			else if (o.Revision_objetivo__c == 'M2')
			{

				if ((ocalc.CNM2__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNM2__c = ocalc.CNM2__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CM2__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CM2__c = ocalc.CM2__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyM2__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyM2__c = ocalc.OptyM2__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPM2__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPM2__c = ocalc.OPM2__c - o.Ofertas_presentadas__c;
				}

				listaActualizar.add(ocalc);
			}
			else if (o.Revision_objetivo__c == 'M3')
			{

				if ((ocalc.CNM3__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNM3__c = ocalc.CNM3__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CM3__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CM3__c = ocalc.CM3__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyM3__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyM3__c = ocalc.OptyM3__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPM3__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPM3__c = ocalc.OPM3__c - o.Ofertas_presentadas__c;
				}

				listaActualizar.add(ocalc);
			}
			else if (o.Revision_objetivo__c == 'M4')
			{

				if ((ocalc.CNM4__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNM4__c = ocalc.CNM4__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CM4__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CM4__c = ocalc.CM4__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyM4__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyM4__c = ocalc.OptyM4__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPM4__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPM4__c = ocalc.OPM4__c - o.Ofertas_presentadas__c;
				}

				listaActualizar.add(ocalc);
			}
			else if (o.Revision_objetivo__c == 'M5')
			{

				if ((ocalc.CNM5__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNM5__c = ocalc.CNM5__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CM5__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CM5__c = ocalc.CM5__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyM5__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyM5__c = ocalc.OptyM5__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPM5__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPM5__c = ocalc.OPM5__c - o.Ofertas_presentadas__c;
				}

				listaActualizar.add(ocalc);
			}
			else if (o.Revision_objetivo__c == 'M6')
			{

				if ((ocalc.CNM6__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNM6__c = ocalc.CNM6__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CM6__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CM6__c = ocalc.CM6__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyM6__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyM6__c = ocalc.OptyM6__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPM6__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPM6__c = ocalc.OPM6__c - o.Ofertas_presentadas__c;
				}

				listaActualizar.add(ocalc);
			}
			else if (o.Revision_objetivo__c == 'M7')
			{

				if ((ocalc.CNM7__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNM7__c = ocalc.CNM7__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CM7__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CM7__c = ocalc.CM7__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyM7__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyM7__c = ocalc.OptyM7__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPM7__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPM7__c = ocalc.OPM7__c - o.Ofertas_presentadas__c;
				}

				listaActualizar.add(ocalc);
			}
			else if (o.Revision_objetivo__c == 'M8')
			{

				if ((ocalc.CNM8__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNM8__c = ocalc.CNM8__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CM8__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CM8__c = ocalc.CM8__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyM8__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyM8__c = ocalc.OptyM8__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPM8__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPM8__c = ocalc.OPM8__c - o.Ofertas_presentadas__c;
				}

				listaActualizar.add(ocalc);
			}
			else if (o.Revision_objetivo__c == 'M9')
			{

				if ((ocalc.CNM9__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNM9__c = ocalc.CNM9__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CM9__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CM9__c = ocalc.CM9__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyM9__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyM9__c = ocalc.OptyM9__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPM9__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPM9__c = ocalc.OPM9__c - o.Ofertas_presentadas__c;
				}

				listaActualizar.add(ocalc);
			}
			else if (o.Revision_objetivo__c == 'M10')
			{

				if ((ocalc.CNM10__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNM10__c = ocalc.CNM10__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CM10__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CM10__c = ocalc.CM10__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyM10__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyM10__c = ocalc.OptyM10__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPM10__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPM10__c = ocalc.OPM10__c - o.Ofertas_presentadas__c;
				}

				listaActualizar.add(ocalc);
			}
			else if (o.Revision_objetivo__c == 'M11')
			{

				if ((ocalc.CNM11__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNM11__c = ocalc.CNM11__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CM11__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CM11__c = ocalc.CM11__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyM11__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyM11__c = ocalc.OptyM11__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPM11__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPM11__c = ocalc.OPM11__c - o.Ofertas_presentadas__c;
				}

				listaActualizar.add(ocalc);
			}
			else if (o.Revision_objetivo__c == 'M12')
			{

				if ((ocalc.CNM12__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNM12__c = ocalc.CNM12__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CM12__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CM12__c = ocalc.CM12__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyM12__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyM12__c = ocalc.OptyM12__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPM12__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPM12__c = ocalc.OPM12__c - o.Ofertas_presentadas__c;
				}

				listaActualizar.add(ocalc);
			}
			else if (o.Revision_objetivo__c == 'R1')
			{

				if ((ocalc.CNR1__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNR1__c = ocalc.CNR1__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CR1__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CR1__c = ocalc.CR1__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyR1__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyR1__c = ocalc.OptyR1__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPR1__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPR1__c = ocalc.OPR1__c - o.Ofertas_presentadas__c;
				}

				listaActualizar.add(ocalc);
			}
			else if (o.Revision_objetivo__c == 'R2')
			{
				if ((ocalc.CNR2__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNR2__c = ocalc.CNR2__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CR2__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CR2__c = ocalc.CR2__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyR2__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyR2__c = ocalc.OptyR2__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPR2__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPR2__c = ocalc.OPR2__c - o.Ofertas_presentadas__c;
				}

				listaActualizar.add(ocalc);
			}
			else if (o.Revision_objetivo__c == 'R3')
			{
				if ((ocalc.CNR3__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNR3__c = ocalc.CNR3__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CR3__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CR3__c = ocalc.CR3__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyR3__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyR3__c = ocalc.OptyR3__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPR3__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPR3__c = ocalc.OPR3__c - o.Ofertas_presentadas__c;
				}

				listaActualizar.add(ocalc);
			}
			else if (o.Revision_objetivo__c == 'R4')
			{

				if ((ocalc.CNR4__c != null) && (o.Cifra_de_negocio__c != null))
				{
					ocalc.CNR4__c = ocalc.CNR4__c - o.Cifra_de_negocio__c;
				}

				if ((ocalc.CR4__c != null) && (o.Coste_calculado__c != null))
				{
					ocalc.CR4__c = ocalc.CR4__c - o.Coste_calculado__c;
				}	

				if ((ocalc.OptyR4__c != null) && (o.Oportunidades_abiertas__c != null))
				{
					ocalc.OptyR4__c = ocalc.OptyR4__c - o.Oportunidades_abiertas__c;
				}	

				if ((ocalc.OPR4__c != null) && (o.Ofertas_presentadas__c != null))
				{
					ocalc.OPR4__c = ocalc.OPR4__c - o.Ofertas_presentadas__c;
				}

				listaActualizar.add(ocalc);
			}
		}

		update listaActualizar;
	}

	/** 
	* updateAreaComercial
	**
	* Actualiza el valor del lookup de la delegación asociada al objetivo (oculto en los layout de página) 
	* con el área comercial de la delegación asociada al objetivo( encampo texto Delegación. Así se crea una relación entre ambos
	**
	* @Evento: BEFORE INSERT, BEFORE UPDATE
	**
	* @Autor: jmartinezpisson (12/06/2015)
	**
	* @Modificaciones: -
	**
	* @param: list<Objetivo__c> newList -> Lista de objetivos a insertar/actualizar
	**
	* @return: -
	**/
	public static void updateAreaComercial(list<Objetivo__c> newList)
    {
    	List<Area_comercial__c> areaComercialList = 
    	[
    		SELECT Id, Name, Tipo__c, Area_Comercial__c FROM Area_comercial__c 
    			WHERE Area_comercial__c != ''
    				  AND Tipo__c != ''
    	];
    	Map<String,Area_comercial__c> areaComercialMap = new Map<String,Area_comercial__c> ();
    	
    	for(Area_comercial__c area : areaComercialList)
    	{

			areaComercialMap.put(
				area.Area_comercial__c +'_'+area.Tipo__c,
				area
			);
    	}

    	for(Objetivo__c o : newList)
    	{
    		String key = o.Area_comercial__c+'_'+o.Tipo__c;

    		if( areaComercialMap.containsKey(key) )
    		{
    			o.Area_Comercial_Lookup__c = areaComercialMap.get(key).Id;
    		}
    		else
    		{
    			o.addError(' El área comercial ' + o.Area_comercial__c + ' de tipo '+ o.Tipo__c +' no se encuentra registrada en la lista de áreas comerciales.');
    		}
    	}
    }
}