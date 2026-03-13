global class BatchEnviarCompanyModify implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts {
    public String queryAcc;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
      datetime LimitDateTime = datetime.now().addHours(-1);
		  System.debug(' LimitDateTime: '+ LimitDateTime);
      String IDUser = Label.ADMIN_USER_SAP_ID;
      queryAcc = 'SELECT Id FROM Account WHERE COM_BOL_Ind_camp_pend_SAP__c = true AND Sociedad_Ofertante__c != null AND LastModifiedById !=:IDUser AND LastModifiedDate <:LimitDateTime';
      System.debug(' queryAcc: '+ queryAcc);

      return Database.getQueryLocator(queryAcc);
    }
    
    global void execute(SchedulableContext sc) {
      BatchEnviarCompanyModify batch = new BatchEnviarCompanyModify();
      Database.executeBatch(batch,1);
  		/*String sch = '0 0 1,3,5,7,9,11,13,15,17,19,21,23 * * ?';
  		system.schedule('schedule BatchEnviarCompanyModify', sch, batch);*/
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
      for(sobject s : scope){
        System.debug(' ID Company SEND: '+ s.id);
        Z017vClientesWsSf_CreateCompaniaSAP.invokeModify(s.id, 'U'); 
      }
    }
    
    global void finish(Database.BatchableContext BC) {
    
    }    
    
}