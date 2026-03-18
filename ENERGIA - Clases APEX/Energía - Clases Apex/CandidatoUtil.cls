public class CandidatoUtil {

	public CandidatoUtil() {}

	public static void copiarTipoCliente(list<Lead> newList, map<Id,Lead> oldMap)
	{

		List<Id> cuentasLead = new List<Id>();
		List<Lead> leadConCuenta = new List<Lead>();

		// recorremos la new list de candidatos

		for ( Lead l : newList )
		{
			Lead oldLead = oldMap.get(l.Id);

			if (l.ConvertedAccountId != null)
			{
				if (oldLead.ConvertedAccountId == null)
				{
					cuentasLead.add(l.ConvertedAccountId);
					leadConCuenta.add(l);
				}
			}

		} 


		List<Account> cuentas = [SELECT Id, Actividad_Nivel_1__c, Actividad_Nivel_2__c, Actividad_Nivel_3__c FROM Account WHERE Id in : cuentasLead];

		Map<Id, Account> mapaCuentas = new Map<Id, Account>();

		for (Account a : cuentas)
		{
			mapaCuentas.put(a.Id, a);
		}

		for ( Lead l : leadConCuenta ) 
		{
			Account a = mapaCuentas.get(l.ConvertedAccountId);

			a.Actividad_Nivel_1__c = l.Actividad_Nivel_1__c;
			a.Actividad_Nivel_2__c = l.Actividad_Nivel_2__c;
			a.Actividad_Nivel_3__c = l.Actividad_Nivel_3__c;
			a.NIF__c = l.NIF__c;
			a.AccountSource = l.LeadSource;
		}

		update cuentas;
	}
}