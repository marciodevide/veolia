public without sharing class CaseTriggerHandler {
    
	public static void beforeInsert(List<Case> caseList) {
        setInProgressStatus(caseList);
        fillAccountFromOpportunity(caseList);
    }
	public static void afterInsert(List<Case> caseList) {
    }
	public static void beforeUpdate(List<Case> caseList, Map<Id, Case> oldCaseMap) {
        fillAccountFromOpportunity(caseList);
        updateStatusAfterNotifyAdmin(caseList, oldCaseMap);
        updatePendingReview(caseList, oldCaseMap);
    }
	public static void afterUpdate(List<Case> caseList, Map<Id, Case> oldCaseMap) {
        caseShareMethod(caseList, oldCaseMap);
    }
    
    /**
    * @description  before insert
    *               Al crearse un caso el Status se pone = 'En curso' independientemente de 
    *               la opción elegida por el creador
    * @author       alejandro.torresa@viewnext.com | 2023-06-22 
    * @param        caseList 
    **/
    public static void setInProgressStatus(List<Case> caseList) {
        for (Case cs : caseList) cs.Status = '01';
    }
    
    /**
    * @description  before insert/update
    *               Al agregar una oportunidad a un caso, si el caso no tiene una compañía relacionada,
    *               se le relaciona la compañía relacionada con la oportunidad agregada
    * @author       alejandro.torresa@viewnext.com | 2023-06-22 
    * @param        caseList 
    **/
    public static void fillAccountFromOpportunity(List<Case> caseList) {
        Set<Id> oppIds = new Set<Id>();
        for (Case cs : caseList) {
            if (cs.CASE_LKP_Opportunity__c != null && cs.AccountId == null) {
                oppIds.add(cs.CASE_LKP_Opportunity__c);
            }
        }
        if (!oppIds.isEmpty()) {
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
                SELECT Id, AccountId
                FROM Opportunity
                WHERE Id IN: oppIds
            ]);
            for (Case cs : caseList) {
                if (oppMap.containsKey(cs.CASE_LKP_Opportunity__c)) {
                    cs.AccountId = oppMap.get(cs.CASE_LKP_Opportunity__c).AccountId;
                }
            }
        }
    }

    /**
    * @description  before insert
    *               Si se actualiza el campo "(Solicitante) Comentarios" y el caso se encuentra en estado
    *               "Pendiente de revisión por solicitante", se actualiza el estado a "En curso"
    * @author       alejandro.torresa@viewnext.com | 2023-06-22 
    * @param        caseList 
    * @param        oldCaseMap 
    **/
    public static void updateStatusAfterNotifyAdmin(List<Case> caseList, Map<Id, Case> oldCaseMap) {
        for (Case cs : caseList) {
            if (oldCaseMap.get(cs.Id).CASE_TXT_ApplicantComments__c != cs.CASE_TXT_ApplicantComments__c
            && cs.Status == '02') {
                cs.Status = '01';
            }
        }
    }

    /**
    * @description  before update
    *               Si se actualiza un caso y se modifica el estado:
    *               Si es estado pasa a "Pendiente de revisión por solicitante" ponemos CASE_BOL_PendingReview__c = true
    *               Sino ponemos CASE_BOL_PendingReview__c = false
    * @author       alejandro.torresa@viewnext.com | 2023-06-22 
    * @param        caseList 
    * @param        oldCaseMap 
    **/
    public static void updatePendingReview(List<Case> caseList, Map<Id, Case> oldCaseMap) {
        for (Case cs : caseList) {
            if (oldCaseMap.get(cs.Id).Status != cs.Status){
                if (cs.Status == '02') cs.CASE_BOL_PendingReview__c = true;
                else cs.CASE_BOL_PendingReview__c = false;
            }
        }
    }

    /**
    * @description  afterUpdate
    *               Este método permite al creador de un caso mantener la visibilidad de este una vez
    *               que el propietario del caso a cambiado. La visibilidad que tiene el creador es R/W
    * @author       alejandro.torresa@viewnext.com | 2023-06-22 
    * @param        caseList 
    * @param        oldCaseMap 
    **/
    public static void caseShareMethod(List<Case> caseList, Map<Id, Case> oldCaseMap) {
        System.debug('caseShareMethod');
        List<CaseShare> creatorAccessList = new List<CaseShare>();
        for(Case cs: caseList){
            if(cs.OwnerId != oldCaseMap.get(cs.Id).OwnerId) {
                CaseShare creatorShare = new CaseShare();
                creatorshare.CaseId = cs.Id;
                creatorshare.userOrGroupID = cs.createdbyID;
                creatorShare.CaseAccessLevel = 'Edit';
                creatorShare.RowCause = 'Manual';
    
                creatorAccessList.add(CreatorShare);
            }
        }
        System.debug('caseShareMethod-creatorAccessList: ' + creatorAccessList);
        Database.SaveResult[] assistRequestShareInsertResult = Database.insert(creatorAccessList,false);
        // Iterate through saveResultList based on isSuccess capture the failed records
        for (Database.SaveResult sr : assistRequestShareInsertResult) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
}