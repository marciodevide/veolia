public class AccountCreationRequestTriggerHelper {
	public void accountCreationRequestWorkFlowRules(List<AQUA_PeticionAltaCompania__c> newMap,List<AQUA_PeticionAltaCompania__c> oldMap){      
        for (AQUA_PeticionAltaCompania__c acr :newMap){

            // Petición enviada 2/3
            // Pendiente revisión por solicitante 2/3
            if(acr.PET_SEL_ESTADOSolicitante__c=='Petición enviada' && oldMap.get(newMap.indexOf(acr)).PET_SEL_ESTADOSolicitante__c=='Petición no enviada'){
                acr.PET_SEL_ESTADOAdministrador__c='Pendiente validación';
            }
            if(acr.PET_SEL_ESTADOAdministrador__c=='Pendiente revisión por solicitante' && oldMap.get(newMap.indexOf(acr)).PET_SEL_ESTADOAdministrador__c!='Pendiente revisión por solicitante'){
                acr.PET_SEL_ESTADOSolicitante__c = 'Petición no enviada';
            }
        }
    }
}