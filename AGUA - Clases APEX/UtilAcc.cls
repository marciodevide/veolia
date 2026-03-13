global without sharing class UtilAcc {
  
  private static boolean run = true;
  private static boolean runApprovalIncompat = true;
  private static boolean runNote = true;
  private static boolean runNoteB = true;
  private static boolean runNoteB1 = true;
  private static boolean runNoteC = true;
  private static boolean runNoteD = true;
  private static boolean runNoteCreate = true;
  private static boolean runAfter = true;
  
  public static boolean runTriggers = true; 

  public static boolean runOnce(){
    System.debug('run antes de entrar vale: ' + run);
    if(run){
      run=false;
      return true;
    } else return run;
  }
  public static boolean runOnceApprovalIncompat(){
    System.debug('run antes de entrar vale: ' + runApprovalIncompat);
    if(runApprovalIncompat){
      runApprovalIncompat=false;
      return true;
    } else return runApprovalIncompat;
  }
  public static boolean runOnceNoteB(){
    System.debug('run antes de entrar vale: ' + run);
    if(runNoteB){
      runNoteB=false;
      return true;
    } else return runNoteB;
  }
  public static boolean runOnceNoteC(){
    System.debug('run antes de entrar vale: ' + run);
    if(runNoteC){
      runNoteC=false;
      return true;
    } else return runNoteC;
  }
  public static boolean runOnceNoteCreate(){
    System.debug('run antes de entrar vale: ' + run);
    if(runNoteCreate){
      runNoteCreate=false;
      return true;
    } else return runNoteCreate;
  }
      
  public static boolean runOnceAfter(){
    if(runAfter){
      runAfter=false;
      return true;
    } else return run;
  }
  
  @future 
  public static void DeleteProdOport(Set<Id> listProdOpportId){
    List<Oportunidad_Producto__c> listOporP = [SELECT Id FROM Oportunidad_Producto__c WHERE Id IN :listProdOpportId];  
    Database.delete(listOporP, false);
  }
  
  public static Integer ObtenerMaxNumSolic() {
    Integer Num_solic = 0; 
    Account AccNumSol = [SELECT COM_NUM_Numero_Solicitud__c FROM Account ORDER BY COM_NUM_Numero_Solicitud__c DESC NULLS LAST LIMIT 1];
    
    if (AccNumSol.COM_NUM_Numero_Solicitud__c != null) Num_solic = Integer.valueOf(AccNumSol.COM_NUM_Numero_Solicitud__c);
    System.debug('Obtenemos el numero de solicitud maximo' + Num_solic);

    return Num_solic+1;
  }
  
  public static Account getClient(Id idAccount){
    if(idAccount == null) return null;
    System.debug('MArta_Se ha creado la compañía');

    return [SELECT Id,COM_NUM_Numero_Solicitud__c,ACC_TXT_OPERA_HIDDEN__c,COM_NUM_Codigo__c,COM_TXT_Numero_Compania_SAP__c,COM_SEL_Estado__c,
      COM_TXT_Grupo_de_cuentas_SAP__c,name,Nombre_2__c,COM_TXT_Domicilio__c,COM_TXT_Calle_2__c,COM_LKP_Municipio__r.name, Sociedad_Ofertante__c,
      COM_LKP_Provincia__r.PRO_TXT_Codigo_Provincia_SAP__c ,COM_LKP_Pais__r.PA_TXT_Codigo_Pais_SAP__c,COM_TXT_Codigo_Postal__c,
      COM_FOR_Divisa__c,COM_FOR_NIF_CIF__c,COM_FOR_Ramo__c,COM_FOR_Codigo_ramo1__c,phone,fax,COM_TXT_Correo_electronico__c,
      COM_LKP_Responsable_comercial_Lab__r.USER_TXT_Identificador_SAP__c,COM_TXT_Solicitud_Modificacion__c,COM_SEL_Estado_Solicitud_Modificacion__c,
      OCUL_BOOL_OrigenPeticion__c,COM_FOR_Codigo_via_pago__c,COM_FOR_Condicion_pago__c,COM_BOL_Compania_bloqueado__c,COM_TXT_Motivo_Bloqueo__c,
      COM_BOL_Compania_fiscal__c,COM_TXT_HIDDEN_SOCIEDAD__c,COM_FOR_Cod_Matriz__c,COM_HIDDEN_TXT_Condicion_pago__c,COM_HIDDEN_TXT_Codigo_via_pago__c
      FROM Account WHERE Id =: idAccount LIMIT 1];   
  }

  public static List<Account> getClientMatriz(String idAccount){
    if(idAccount == null) return null;

    return [SELECT Id,COM_NUM_Numero_Solicitud__c,ACC_TXT_OPERA_HIDDEN__c, COM_NUM_Codigo__c, COM_TXT_Numero_Compania_SAP__c, COM_SEL_Estado__c,
      COM_TXT_Grupo_de_cuentas_SAP__c,name,Nombre_2__c,COM_TXT_Domicilio__c,COM_TXT_Calle_2__c,COM_LKP_Municipio__r.name,
      COM_LKP_Provincia__r.PRO_TXT_Codigo_Provincia_SAP__c ,COM_LKP_Pais__r.PA_TXT_Codigo_Pais_SAP__c,COM_TXT_Codigo_Postal__c,
      COM_FOR_Divisa__c,COM_FOR_NIF_CIF__c,COM_FOR_Ramo__c,Sociedad_Ofertante__c,COM_FOR_Codigo_ramo1__c,phone,fax,COM_TXT_Correo_electronico__c,
      COM_LKP_Responsable_comercial_Lab__r.USER_TXT_Identificador_SAP__c,COM_TXT_Solicitud_Modificacion__c,COM_SEL_Estado_Solicitud_Modificacion__c,
      OCUL_BOOL_OrigenPeticion__c,COM_FOR_Codigo_via_pago__c,COM_FOR_Condicion_pago__c,COM_BOL_Compania_bloqueado__c,COM_TXT_Motivo_Bloqueo__c,
      COM_BOL_Compania_fiscal__c,COM_TXT_HIDDEN_SOCIEDAD__c,COM_FOR_Cod_Matriz__c 
      FROM Account WHERE COM_FOR_Cod_Matriz__c =: idAccount];   
  }
  
  public static AQUA_Sociedad_Ofertante__c getSociedadOfertante(Id idSociedadOfertante){
    if(idSociedadOfertante == null) return null;
    return [SELECT Id,Name,EMP_TXT_IdSAP__c FROM AQUA_Sociedad_Ofertante__c WHERE Id =: idSociedadOfertante LIMIT 1]; 
  }
  
  public static Integer getNumOpportunity(Id idOppornity, Id idSociedadOfertante, Id IdOpp) {
    if(idSociedadOfertante == null || idSociedadOfertante == null) return 0;
    //System.debug('MArta_conut= '+[SELECT count() FROM Opportunity WHERE AccountId =: idOppornity AND OPO_LKP_Sociedad_Ofertante__c =: idSociedadOfertante AND ID !=: IdOpp]);
    return [SELECT COUNT() FROM Opportunity WHERE AccountId =: idOppornity AND OPO_LKP_Sociedad_Ofertante__c =: idSociedadOfertante AND Id !=: IdOpp];
  }
  
  public static List<Account> getListAccount(Id idAccount){
    if(idAccount == null) return null;
    return [SELECT Id,COM_BOL_Compania_fiscal__c,COM_SEL_Estado_Solicitud_Modificacion__c FROM Account WHERE COM_FOR_Cod_Matriz__c =: idAccount];
  }
     
  public static boolean needTriggerRun(){
    return runTriggers;
  }
}