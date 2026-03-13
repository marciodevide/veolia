global with sharing class Z017V_OFERTAS_SF_CreateOportunidadSAP {
  
  webservice static String invokeSingle(Id Id){
    List<Id> listId = new List<Id>();
    listId.add(Id);
    return invoke(listId);
  }
      
  webservice static String invoke(List<Id> Id) {
    if(Id == null) return 'error';

    // create management object 
    sapComDocumentSapSoapFunctionsMcS sapElement = new sapComDocumentSapSoapFunctionsMcS(); 

    // Object response WS 
    sapComDocumentSapSoapFunctionsMcS.Z017vPeticOporSfResponse_element element = new sapComDocumentSapSoapFunctionsMcS.Z017vPeticOporSfResponse_element();  
    
    // Object in WS
    sapComDocumentSapSoapFunctionsMcS.TableOfZ017vOporWsSf request = new sapComDocumentSapSoapFunctionsMcS.TableOfZ017vOporWsSf();

    request.item = new list<sapComDocumentSapSoapFunctionsMcS.Z017vOporWsSf>();
                                                    
    for(Opportunity a :getOportunidadSalesforce(Id)){
      System.debug('****** Name ' + a.Name);
      request.item.add(OpportunityClient(a));
    }
    if(request.item.size() == 0) return 'Error no se ha encontrado Oportunidad para ser modificado';
    
    sapComDocumentSapSoapFunctionsMcS.TableOfZ017vOpoSfLog logSAP_Op = new sapComDocumentSapSoapFunctionsMcS.TableOfZ017vOpoSfLog();
    
    sapComDocumentSapSoapFunctionsMcS.Z017V_OFERTAS_SF invokeSAP =  new sapComDocumentSapSoapFunctionsMcS.Z017V_OFERTAS_SF();
    invokeSAP.inputHttpHeaders_x = new Map<String,String>();                                            
    invokeSAP.inputHttpHeaders_x.put('Authorization', Label.InfAuthorization);
    invokeSAP.inputHttpHeaders_x.put('Content-Type',Label.UTF8);
    
    // Invocamos a SAP
    System.debug('*************** Invocamos a SAP  ********************');
    if (Label.IntegracionSAPOport == '1') element=invokeSAP.Z017vPeticOporSf(request, logSAP_Op);

    return null;
  }
    
  @future (callout=true)
  webservice static void invokeFuturo(List<Id> Ids) {
    System.debug('*************** Dentro invokeFuturo -> invoke ********************');
    Opportunity opp = new Opportunity ();
    invoke(Ids);
  }

  private static  List<Opportunity> getOportunidadSalesforce(list<Id> Id){
  
    return [SELECT ActSap__c,OPO_TXT_Codigo_Oportunidad__c,Account.COM_NUM_Codigo__c,Account.COM_TXT_Numero_Compania_SAP__c,
            OPO_LKP_Sociedad_Ofertante__r.EMP_TXT_IdSAP__c, OPO_RUS_Volumen_Total__c, OPO_BOL_Seguimiento_de_Costes__c, 
            OPO_FOR_Condicion_pago__c, OPO_FOR_Codigo_via_pago__c, CurrencyIsoCode, Name, StageName,
            Account.COM_LKP_Responsable_comercial_Lab__c  FROM Opportunity WHERE id IN :Id];
  }

  private static sapComDocumentSapSoapFunctionsMcS.Z017vOporWsSf OpportunityClient (Opportunity OportunidadSalesforce){
    sapComDocumentSapSoapFunctionsMcS.Z017vOporWsSf Opport = new sapComDocumentSapSoapFunctionsMcS.Z017vOporWsSf();
    
    if(OportunidadSalesforce.ActSap__c!=null){
      System.debug('****** OportunidadSalesforce.ActSap__c ' + OportunidadSalesforce.ActSap__c);
      if(OportunidadSalesforce.ActSap__c) Opport.ActSap = '1';
      else Opport.ActSap = '0';
    }
    
    if(OportunidadSalesforce.OPO_TXT_Codigo_Oportunidad__c != null) {
      System.debug('****** OPO_TXT_Codigo_Oportunidad__c  ' + OportunidadSalesforce.OPO_TXT_Codigo_Oportunidad__c);
      Opport.Zzoportunidad=OportunidadSalesforce.OPO_TXT_Codigo_Oportunidad__c;
    }
    
    if(OportunidadSalesforce.Account.COM_NUM_Codigo__c != null) {
      System.debug('****** COM_NUM_Codigo__c ' + OportunidadSalesforce.Account.COM_NUM_Codigo__c );
      Opport.ZzsfdcAcc=OportunidadSalesforce.Account.COM_NUM_Codigo__c;
    }

    if(OportunidadSalesforce.Account.COM_TXT_Numero_Compania_SAP__c != null) Opport.Kunnr=OportunidadSalesforce.Account.COM_TXT_Numero_Compania_SAP__c;
      
    if(OportunidadSalesforce.OPO_LKP_Sociedad_Ofertante__r.EMP_TXT_IdSAP__c != null) {
      System.debug('****** EMP_TXT_IdSAP__c ' + OportunidadSalesforce.OPO_LKP_Sociedad_Ofertante__r.EMP_TXT_IdSAP__c );  
      Opport.Vkorg=OportunidadSalesforce.OPO_LKP_Sociedad_Ofertante__r.EMP_TXT_IdSAP__c; 
    }
    
    if(OportunidadSalesforce.OPO_RUS_Volumen_Total__c != null) {
      System.debug('****** OPO_RUS_Volumen_Total__c ' + OportunidadSalesforce.OPO_RUS_Volumen_Total__c ); 
      Decimal toround = OportunidadSalesforce.OPO_RUS_Volumen_Total__c;
      Decimal rounded = toround.setScale(2);
      Opport.Netwr = String.valueOf(rounded);
    }
    
    if(OportunidadSalesforce.OPO_BOL_Seguimiento_de_Costes__c != null) {
      System.debug('****** OPO_BOL_Seguimiento_de_Costes__c' + OportunidadSalesforce.OPO_BOL_Seguimiento_de_Costes__c ); 
      if(OportunidadSalesforce.OPO_BOL_Seguimiento_de_Costes__c == true) Opport.Costes='0';
      else Opport.Costes='1';
    }

    if(OportunidadSalesforce.OPO_FOR_Condicion_pago__c != null) Opport.Zterm=OportunidadSalesforce.OPO_FOR_Condicion_pago__c;
    
    if(OportunidadSalesforce.OPO_FOR_Codigo_via_pago__c != null) Opport.Zlsch=OportunidadSalesforce.OPO_FOR_Codigo_via_pago__c;
    
    if(OportunidadSalesforce.CurrencyIsoCode != null) Opport.Waers=OportunidadSalesforce.CurrencyIsoCode;

    if(OportunidadSalesforce.Name != null) Opport.Zdescripcion=OportunidadSalesforce.Name;

    if(OportunidadSalesforce.StageName != null) {
      String sStageName;
      if(OportunidadSalesforce.StageName == Label.stage1SAP || OportunidadSalesforce.StageName == Label.stage2SAP)
        sStageName= Label.Oportunidad_SAP;
      else if (OportunidadSalesforce.StageName == Label.stage3SAP)
        sStageName= Label.ELABORACION_SAP;
      else if (OportunidadSalesforce.StageName == Label.stage4SAP)
        sStageName= Label.Presentada_SAP;
      else if (OportunidadSalesforce.StageName == Label.stage5SAP)
        sStageName= Label.Ganada_SAP;
      else if (OportunidadSalesforce.StageName == Label.stage6SAP)
        sStageName= Label.Perdida_SAP;
      else if (OportunidadSalesforce.StageName == Label.stage7SAP)
        sStageName= Label.Cancelada_SAP;
      else if (OportunidadSalesforce.StageName == Label.stage8SAP)
        sStageName= Label.Desestimada_SAP;
      
      Opport.StatusSf=sStageName;
      System.debug('Enviado a SAP la Oportunidad ==================================> ' + Opport);
    }

    return Opport;
  }
    
  webservice static String invokeOppsinAcc(Opportunity OppSinACC) {

    if(OppSinACC== null) return 'error';
    
    // create management object 
    sapComDocumentSapSoapFunctionsMcS sapElement = new sapComDocumentSapSoapFunctionsMcS(); 
    
    // Object response WS 
    sapComDocumentSapSoapFunctionsMcS.Z017vPeticOporSfResponse_element element = new sapComDocumentSapSoapFunctionsMcS.Z017vPeticOporSfResponse_element();  
    
    // Object in WS
    sapComDocumentSapSoapFunctionsMcS.TableOfZ017vOporWsSf request = new sapComDocumentSapSoapFunctionsMcS.TableOfZ017vOporWsSf();
    
    request.item = new list<sapComDocumentSapSoapFunctionsMcS.Z017vOporWsSf>();
    request.item.add(OpportunityClient (OppSinACC));
    OppSinACC.OCUL_BOOL_OrigenPeticion__c = false;
    
    if(request.item.size() == 0) return 'Error no se ha encontrado cliente para ser modificado';
    
    sapComDocumentSapSoapFunctionsMcS.TableOfZ017vOpoSfLog logSAP_Op = new sapComDocumentSapSoapFunctionsMcS.TableOfZ017vOpoSfLog();
    sapComDocumentSapSoapFunctionsMcS.Z017V_OFERTAS_SF invokeSAP =  new sapComDocumentSapSoapFunctionsMcS.Z017V_OFERTAS_SF();
    invokeSAP.inputHttpHeaders_x = new Map<String,String>();                                            
    invokeSAP.inputHttpHeaders_x.put('Authorization', Label.InfAuthorization);
    invokeSAP.inputHttpHeaders_x.put('Content-Type',Label.UTF8);
    
    // Invocamos a SAP
    if (Label.IntegracionSAPOport == '1') {
      try{
        element=invokeSAP.Z017vPeticOporSf(request, logSAP_Op);
      }catch(Exception e){
        System.debug(e);
      }
    }
    return null;
  }
}