public with sharing class TenderBoxV2Controller {

    private static final String endpoint = 'open-api/document';
    private static final String namedCredential = 'Tender_BOX_API';

    //Cannot cover this method with a test
    @AuraEnabled(cacheable=true)
    public static TenderBox_API__mdt getTenderBoxMetadata(){
        Boolean isSandbox = [SELECT Id, isSandbox FROM Organization LIMIT 1].isSandbox;    
        if(isSandbox){
            return [SELECT Tender_BOX_URL__c FROM TenderBox_API__mdt WHERE Environnement__c='UAT' WITH SECURITY_ENFORCED LIMIT 1];
        } else {
            return [SELECT Tender_BOX_URL__c FROM TenderBox_API__mdt WHERE Environnement__c='PROD' WITH SECURITY_ENFORCED LIMIT 1];
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getOrgCurrency(){
        return UserInfo.getDefaultCurrency();
    }
    
    @AuraEnabled(cacheable=true)
    public static List<TBOX_Criterion__c> getOpprtunityCriterions(){
        return [SELECT Id,
                Name, 
                TBOX_Matching_Field__c, 
                TBOX_Matching_Field_Object__c, 
                TBOX_Matching_Field_Type__c, 
                Tender_BOX_Api_Value__c, 
                TBOX_Matching_Field_Required__c, 
                (SELECT Name, 
                 Tender_BOX_Api_Value__c, 
                 (SELECT Name FROM Tender_BOX_Criterion_Value_Mappings__r) 
                 FROM Tender_BOX_Criterion_Values__r)
                FROM TBOX_Criterion__c 
                WHERE TBOX_Matching_Field_Object__c = 'Opportunity' ORDER BY Order__c];
    }

    @AuraEnabled
    public static String getTenderBoxId(String recordId) {
        return [SELECT Tender_Box_Id__c FROM Opportunity where Id = :recordId].Tender_Box_Id__c;
    }

    @AuraEnabled
    public static String updateTenderBoxId(String opportunityId, String tenderBoxId) {
        Opportunity opp = [SELECT Id, Tender_Box_Id__c FROM Opportunity where Id = :opportunityId];
        opp.Tender_Box_Id__c = tenderBoxId;
        update opp;
        return 'OK';
    }

    @AuraEnabled
    public static Opportunity getOpportunity(String recordId, List<String> fieldsNameList) {
        String queryFieldsName = '';
        for (String field : fieldsNameList) {
            queryFieldsName += ', ' + field;
        }
        String safeRecordId = String.escapeSingleQuotes(recordId);
        String safeQueryFields = String.escapeSingleQuotes(queryFieldsName);
        String queryString = 'SELECT Id' + safeQueryFields + ' FROM Opportunity WHERE Id = \'' + safeRecordId + '\'';
        return Database.query(queryString);
    }

    @AuraEnabled
    public static ServiceTenderBoxV2Response createDocument(String opportunityId, String tenderDatas) {
        List<TenderBoxField> tenderFieldDatas = (List<TenderBoxField>) JSON.deserialize(tenderDatas, List<TenderBoxField>.class);

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:' + namedCredential + '/' + endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);

        // Construire le corps de la requête JSON
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('emailUser', UserInfo.getUserEmail());
        requestBody.put('idSF', opportunityId);
        requestBody.put('data', tenderFieldDatas);
 
        req.setBody(JSON.serialize(requestBody, true)); //true Remove null data
        System.debug('req : '+JSON.serialize(requestBody, true));
         
        ServiceTenderBoxV2Response response = new ServiceTenderBoxV2Response();
        
        try {
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('res : '+res);
            response = (ServiceTenderBoxV2Response) JSON.deserialize(res.getBody(), ServiceTenderBoxV2Response.class);
            response.httpStatus = res.getStatusCode();
            if (response.code == 0 && response.idTB != null) {
                Opportunity opp = [
                  SELECT Id, Tender_Box_Id__c
                  FROM Opportunity
                  WHERE Id = :opportunityId
                ];
                opp.Tender_Box_Id__c = response.idTB;
                update opp;
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            response.message = 'Une erreur technique est survenue';
            response.except = e;
        }
        
        return response;
    }

    @AuraEnabled
    public static ServiceTenderBoxV2Response updateDocument(String opportunityId, string tenderBoxId, String tenderDatas){
        List<TenderBoxField> tenderFieldDatas = (List<TenderBoxField>) JSON.deserialize(tenderDatas, List<TenderBoxField>.class);

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:' + namedCredential + '/' + endpoint);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);
 
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('emailUser', UserInfo.getUserEmail());
        requestBody.put('idSF', opportunityId);
        requestBody.put('idTB', tenderBoxId);
        requestBody.put('data', tenderFieldDatas);
 
        req.setBody(JSON.serialize(requestBody, true)); //true Remove null data
        system.debug(JSON.serialize(requestBody, true));
        
        ServiceTenderBoxV2Response response = new ServiceTenderBoxV2Response();

        try {
            Http http = new Http();
            HttpResponse res = http.send(req);
            system.debug('res.getBody() : '+res.getBody());
            response = (ServiceTenderBoxV2Response) JSON.deserialize(res.getBody(), ServiceTenderBoxV2Response.class);
            response.httpStatus = res.getStatusCode();
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            response.message = 'Une erreur technique est survenue';
            response.except = e;
        }

        return response;
    }

    public with sharing class ServiceTenderBoxV2Response {
        
        @AuraEnabled
        public Integer httpStatus;
        @AuraEnabled
        public Integer code;
        @AuraEnabled
        public List<TenderBoxError> errors;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String stringCode;
        @AuraEnabled
        public String idTB;
        @AuraEnabled
        public String idSF;
        
        public Exception except;

        public ServiceTenderBoxV2Response() {}
    }
}