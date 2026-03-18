public with sharing class TenderBoxController {
    @AuraEnabled
    public static string getUrl(){
        TenderBox_API__mdt apiParam;
        Boolean isSandbox = [SELECT Id, isSandbox FROM Organization LIMIT 1].isSandbox;
        if(isSandbox){
            apiParam = [SELECT Id, Endpoint__c FROM TenderBox_API__mdt WHERE Environnement__c='UAT' WITH SECURITY_ENFORCED LIMIT 1];
        } else {
            apiParam = [SELECT Id, Endpoint__c FROM TenderBox_API__mdt WHERE Environnement__c='PROD' WITH SECURITY_ENFORCED LIMIT 1];
        }
        return apiParam.Endpoint__c.replace('/open-api/search-count','');
    }
    @AuraEnabled
    public static String autoSearchAccount(String id){
        try{
            String duns = getAccountDuns(id);
            List<String> sectors = getAccountSector(id);
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            JSONGenerator genSec = JSON.createGenerator(true);
            JSONGenerator genDuns = JSON.createGenerator(true);
            List<Object> params = new List<Object>();
            
            gen.writeFieldName('fields');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('label','duns');

            if(String.isNotBlank(duns)){
                gen.writeStringField('value',duns);            

                genDuns.writeStartObject();
                genDuns.writeStringField('duns',duns);
                genDuns.writeObjectField('market',new List<String>());
                genDuns.writeObjectField('sector',new List<String>());
                genDuns.writeObjectField('segment',new List<String>());
                genDuns.writeObjectField('subSegment',new List<String>());
                genDuns.writeStringField('userMail','florian.lavaud.ext@veolia.com');
                genDuns.writeEndObject();
                params.add(JSON.deserializeUntyped(genDuns.getAsString()));
            }else{gen.writeStringField('value','');}
                gen.writeFieldName('values');
                gen.writeStartArray();
                gen.writeEndArray();
                gen.writeEndObject();
                gen.writeStartObject();
                gen.writeStringField('label','sector');
                gen.writeStringField('value','');
            if(sectors != null && !sectors.isEmpty()){
                gen.writeObjectField('values', getName(sectors));

                genSec.writeStartObject();
                genSec.writeStringField('duns','');
                genSec.writeObjectField('market',new List<String>());
                genSec.writeObjectField('sector',sectors);
                genSec.writeObjectField('segment',new List<String>());
                genSec.writeObjectField('subSegment',new List<String>());
                genSec.writeStringField('userMail','florian.lavaud.ext@veolia.com');
                genSec.writeEndObject();
                params.add(JSON.deserializeUntyped(genSec.getAsString()));
            }else{
                gen.writeFieldName('values');
                gen.writeStartArray();
                gen.writeEndArray();
            }
            gen.writeEndObject();
            gen.writeEndArray();

            gen.writeObjectField('params',params);

            /** TODO Appel API */
            Map<String,Object> dunsResult = new Map<String, Object>();
            if(String.isNotBlank(duns)){
                dunsResult =(Map<String,Object>) JSON.deserializeUntyped(callTenderbox(genDuns.getAsString()));
            }else{
                dunsResult.put('count',0);
                dunsResult.put('url','');
            }
            dunsResult.put('label',[SELECT Id, Name FROM Account WHERE Id = :id LIMIT 1].Name +' related content(s)');
            Map<String,Object> sectorResult = new Map<String, Object>();
            if(sectors != null && !sectors.isEmpty()){
                sectorResult = (Map<String,Object>) JSON.deserializeUntyped(callTenderbox(genSec.getAsString()));
            }else{
                sectorResult.put('count',0);
                sectorResult.put('url','');
            }
            sectorResult.put('label','Sector related content(s)');
            /** */

            gen.writeFieldName('results');
            gen.writeStartArray();
            gen.writeObject(dunsResult);
            gen.writeObject(sectorResult);
            gen.writeEndArray();

            gen.writeEndObject();
            return gen.getAsString();
        }catch(Exception e ){
            System.debug(e.getMessage());
            throw newMessageException(e.getMessage());
        }

    }
    @AuraEnabled
    public static String autoSearchOpportunity(String id){
        try{
            Map<String,List<String>> criterion = getOpportunityCriterion(id);
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            List<Object> params = new List<Object>();        
            JSONGenerator genOpp = JSON.createGenerator(true);

            gen.writeFieldName('fields');
            gen.writeStartArray();
            Boolean isEmpty = true;
            for(String c: criterion.keySet()){
                isEmpty = isEmpty && criterion.get(c).isEmpty();
                gen.writeStartObject();
                gen.writeStringField('label',c);
                gen.writeStringField('value','');
                gen.writeObjectField('values',getName(criterion.get(c)));
                gen.writeEndObject();
            }
            gen.writeEndArray();
            
            if(!isEmpty){
                genOpp.writeStartObject();
                genOpp.writeStringField('duns','');
                genOpp.writeObjectField('market',criterion.get('market'));
                genOpp.writeObjectField('sector',criterion.get('sector'));
                genOpp.writeObjectField('segment',criterion.get('segment'));
                genOpp.writeObjectField('subSegment',criterion.get('subsegment'));
                genOpp.writeStringField('userMail','florian.lavaud.ext@veolia.com');
                genOpp.writeEndObject();
                params.add(JSON.deserializeUntyped(genOpp.getAsString()));
            }

            gen.writeObjectField('params',params);

            /** TODO Appel API */
            Map<String,Object> result = new Map<String,Object>();
            if(!isEmpty){
                result =(Map<String,Object>) JSON.deserializeUntyped(callTenderbox(genOpp.getAsString()));
            }else{
                result.put('count',0);
                result.put('url','');
            }
            result.put('label','Available content(s) related on opportunity details');
            /** */

            gen.writeFieldName('results');
            gen.writeStartArray();
            gen.writeObject(result);
            gen.writeEndArray();

            gen.writeEndObject();
            return gen.getAsString();
        }catch(Exception e ){
            System.debug(e.getMessage());
            throw newMessageException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String manualSearch(String searchParams){
        try{
            Map<String,String> sp = (Map<String,String>)JSON.deserialize(searchParams,Map<String,String>.class); 
            JSONGenerator gen = JSON.createGenerator(true);
            JSONGenerator genCrit = JSON.createGenerator(true);            
            JSONGenerator genDuns = JSON.createGenerator(true);
            List<Object> params = new List<Object>();
            Boolean isAcc = false;
            Boolean isDunsBlank = false;
            Boolean isEmpty = true;
            gen.writeStartObject();
            gen.writeFieldName('fields');
            gen.writeStartArray();
            genCrit.writeStartObject();

            for(String c: sp.keySet()){            
                gen.writeStartObject();
                gen.writeStringField('label',c);
                switch on c{
                    when 'duns'{
                        gen.writeStringField('value',sp.get(c));
                        gen.writeFieldName('values');
                        gen.writeStartArray();
                        gen.writeEndArray();

                        genDuns.writeStartObject();
                        genDuns.writeStringField('duns',sp.get(c));
                        isDunsBlank = String.isBlank(sp.get(c));
                        genDuns.writeObjectField('market',new List<String>());
                        genDuns.writeObjectField('sector',new List<String>());
                        genDuns.writeObjectField('segment',new List<String>());
                        genDuns.writeObjectField('subSegment',new List<String>());
                        genDuns.writeStringField('userMail','florian.lavaud.ext@veolia.com');
                        genDuns.writeEndObject();
                        
                        genCrit.writeStringField(c,'');
                    }
                    when 'subsegment'{
                        isEmpty = isEmpty && String.isBlank(sp.get(c));
                        gen.writeStringField('value','');
                        gen.writeObjectField('values',sp.get(c).split(';'));

                        genCrit.writeObjectField('subSegment',getApiValues(sp.get(c)));
                    }
                    when 'sobjecttype'{
                        isAcc = (sp.get(c)=='001');
                    }
                    when else {
                        isEmpty = isEmpty && String.isBlank(sp.get(c));
                        gen.writeStringField('value','');
                        gen.writeObjectField('values',sp.get(c).split(';'));

                        genCrit.writeObjectField(c,getApiValues(sp.get(c)));

                    }
                }
                gen.writeEndObject();

            }
            genCrit.writeStringField('userMail','florian.lavaud.ext@veolia.com');
            genCrit.writeEndObject();
            gen.writeEndArray();   
            if(isAcc) params.add(JSON.deserializeUntyped(genDuns.getAsString()));
            params.add(JSON.deserializeUntyped(genCrit.getAsString()));
            gen.writeObjectField('params',params);     

            /** TODO Appel API */
            Map<String, Object> dunsResult = new Map<String,Object>();
            Map<String, Object> result = new Map<String,Object>();
            if(isAcc){
                if(!isDunsBlank){
                    dunsResult =(Map<String, Object>) JSON.deserializeUntyped(callTenderbox(genDuns.getAsString()));
                }else{
                    dunsResult.put('count',0);
                    dunsResult.put('url','');
                }                
                dunsResult.put('label','DUNS related content(s)');
            }
            if(!isEmpty){
                result =(Map<String, Object>) JSON.deserializeUntyped(callTenderbox(genCrit.getAsString()));
            }else{                
                result.put('count',0);
                result.put('url','');
            }
            result.put('label',(isAcc)?'Sector related content(s)':'Criteria related content(s)');
            /**  */

            gen.writeFieldName('results');
            gen.writeStartArray();
            if(isAcc) gen.writeObject(dunsResult);
            gen.writeObject(result);
            gen.writeEndArray();

            gen.writeEndObject();
            return gen.getAsString();
        }catch(Exception e ){
            System.debug(e.getMessage());
            throw newMessageException(e.getMessage());
        }
    }

    private static String callTenderbox(String body){
        try{
            TenderBox_API__mdt apiParam;
            Boolean isSandbox = [SELECT Id, isSandbox FROM Organization LIMIT 1].isSandbox;
            if(isSandbox){
                apiParam = [SELECT Id, Endpoint__c, Access_Method__c FROM TenderBox_API__mdt WHERE Environnement__c='UAT' WITH SECURITY_ENFORCED LIMIT 1];
            } else {
                apiParam = [SELECT Id, Endpoint__c, Access_Method__c FROM TenderBox_API__mdt WHERE Environnement__c='PROD' WITH SECURITY_ENFORCED LIMIT 1];
            }

            Map<String, String> mapHeaders = new Map<String,String>();
            mapHeaders.put('Content-Type', 'application/json');

            WebServiceResponse apiResponse = executeHttpRequest(body,apiParam.Endpoint__c,apiParam.Access_Method__c,20000,'','',mapHeaders);
            if (!apiResponse.status){
                throw apiResponse.excep;
            }
            if (apiResponse.response.getStatusCode()!=200){
                throw newMessageException(apiResponse.response.getBody());      
            }
            System.debug(apiResponse.response.getBody());
            return apiResponse.response.getBody();
        }catch(Exception e){
            System.debug(e.getMessage());
            throw newMessageException(e.getMessage());
        }
    }

    private static AuraHandledException newMessageException(String message) {
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        return e;
    }

    private static WebServiceResponse executeHttpRequest (String envelope, String endPoint, String requestType, Integer timeout, String userName, String password, Map<String, String> header){
        String methodName = 'executeHttpRequest';
        system.debug('### envelope : ' + envelope);
        if(!String.isEmpty(endPoint)){
            endPoint = EncodingUtil.urlEncode(endPoint, 'UTF-8');
            endPoint = EncodingUtil.urlDecode(endPoint, 'UTF-8');
        }

        WebServiceResponse wsResponse = new WebServiceResponse();
        try {
            HttpRequest req = new HttpRequest();
            
            req.setendPoint(endPoint);
            req.setMethod(requestType);
            req.setTimeout(timeout);
            
            if (userName != null && password != null && userName.length() > 0 && password.length() > 0) {
                Blob headerValue = Blob.valueOf(userName + ':' + password );
                String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                req.setHeader('Authorization', authorizationHeader);
            }
            
            if (requestType != 'GET') {
                if (header != null) {
                    for (String key : header.keySet()) {
                        req.setHeader(key, header.get(key));
                    }
                }
                req.setBody(envelope);
            } else {
                if (header != null){
                    for (String key : header.keySet()){
                        req.setHeader(key, header.get(key));
                    }
                }
            }
            
            HTTPResponse res = new Http().send(req);
            
            wsResponse.response=res;
            wsResponse.status=true;
            
            return wsResponse;
            
        } catch(Exception e) {
            wsResponse.status=false;
            wsResponse.excep=e;
            return wsResponse;
        }
    }

    private static Set<String> getName(List<String> criterion){
        Set<String> r = new Set<String>();
        for(TBOX_Criterion_Value__c mcv : [SELECT Id, Name FROM TBOX_Criterion_Value__c WHERE Tender_BOX_Api_Value__c IN :criterion]){
            r.add(mcv.Name);
        }
        return r;
    }

    private static Set<String> getApiValues(String criterion){
        Set<String> r = new Set<String>();
        for(TBOX_Criterion_Value__c mcv : [SELECT Id, Tender_BOX_Api_Value__c FROM TBOX_Criterion_Value__c WHERE Name IN :criterion.split(';')]){
            r.add(mcv.Tender_BOX_Api_Value__c);
        }
        return r;
    }

    private static Map<String,List<String>> getOpportunityCriterion(String id){
        Map<String,List<String>> r = new Map<String,List<String>>();
        r.put('market',new List<String>());
        r.put('sector',new List<String>());
        r.put('segment',new List<String>());
        r.put('subsegment',new List<String>());
        List<TBOX_Criterion__c> criterionL = [SELECT Id, Name, TBOX_Matching_Field__c, TBOX_Matching_Field_Object__c FROM TBOX_Criterion__c WHERE TBOX_Matching_Field_Object__c = 'Opportunity' AND (TBOX_Matching_Field_Type__c = 'Picklist' OR TBOX_Matching_Field_Type__c = 'Text')];
        if (criterionL.size()==0) return r;
        String fields = '';
        List<String> criterionIds = new List<String>();
        for(TBOX_Criterion__c c : criterionL){
            if (String.isNotBlank(c.TBOX_Matching_Field__c)) fields += ', '+c.TBOX_Matching_Field__c;
            criterionIds.add(c.Id);
        }

        List<Opportunity> oppL = DataBase.query('SELECT Id'+fields+' FROM Opportunity WHERE Id =\''+id+'\' LIMIT 1');
        if (oppL.size()==0) return r;
        Map<String,Object> opp = (Map<String,Object>)JSON.deserializeUntyped(JSON.serializePretty(oppL[0]));
        List<String> oppCriterionValue = new List<String>();
        for (TBOX_Criterion__c c : criterionL){
            if (String.isNotBlank(c.TBOX_Matching_Field__c)) oppCriterionValue.add((String)opp.get(c.TBOX_Matching_Field__c));
        }
        
        List<String> TMCVId = new List<String>();
        for(TBOX_Criterion_Value_Mapping__c cvm : [SELECT Id, TBOX_Matching_Criterion_Value__c, Name FROM TBOX_Criterion_Value_Mapping__c WHERE Name IN :oppCriterionValue]){
            TMCVId.add(cvm.TBOX_Matching_Criterion_Value__c);
        }
        if (TMCVId.size()==0) return r;
        Set<String> marketS = new Set<String>();
        Set<String> sectorS = new Set<String>();
        Set<String> segmentS = new Set<String>();
        Set<String> subsegmentS = new Set<String>();
        List<String> marketL = new List<String>();
        List<String> sectorL = new List<String>();
        List<String> segmentL = new List<String>();
        List<String> subsegmentL = new List<String>();

        for(TBOX_Criterion_Value__c mcv : [SELECT Id, Tender_BOX_Api_Value__c, TBOX_Criterion__c, TBOX_Criterion__r.Name FROM TBOX_Criterion_Value__c WHERE Id IN :TMCVId AND TBOX_Criterion__c IN :criterionIds]){
            switch on mcv.TBOX_Criterion__r.Name{
                when 'Market'{
                    marketS.add(mcv.Tender_BOX_Api_Value__c);
                }
                when 'Sector'{                
                    sectorS.add(mcv.Tender_BOX_Api_Value__c);
                }
                when 'Segment'{
                    segmentS.add(mcv.Tender_BOX_Api_Value__c);
                }
                when 'Sub-Segment'{
                    subsegmentS.add(mcv.Tender_BOX_Api_Value__c);
                }
            }
        }
        marketL.addAll(marketS);
        sectorL.addAll(sectorS);
        segmentL.addAll(segmentS);
        subsegmentL.addAll(subsegmentS);

        r.put('market',marketL);
        r.put('sector',sectorL);
        r.put('segment',segmentL);
        r.put('subsegment',subsegmentL);

        return r;
    }

    private static String getAccountDuns(String id){
        List<TBOX_Criterion__c> LTBC = [SELECT Id, Name, TBOX_Matching_Field__c, TBOX_Matching_Field_Object__c FROM TBOX_Criterion__c WHERE Name = 'DUNS' AND TBOX_Matching_Field_Object__c = 'Account' AND TBOX_Matching_Field__c != '' LIMIT 1];
        List<Account> accL;
        if (LTBC.size()>0){
            accL = DataBase.query('SELECT Id, Name,'+LTBC[0].TBOX_Matching_Field__c+' FROM Account WHERE Id =\''+id+'\' LIMIT 1');
            if(accL.size()>0){
                Map<String,Object> acc = (Map<String,Object>)JSON.deserializeUntyped(JSON.serializePretty(accL[0]));
                return (String.isNotBlank((String)acc.get(LTBC[0].TBOX_Matching_Field__c)))?(String)acc.get(LTBC[0].TBOX_Matching_Field__c):(String)acc.get('Name');
            } else{
                return null;
            }
        }else{
            accL = DataBase.query('SELECT Id, Name FROM Account WHERE Id =\''+id+'\' LIMIT 1');
            if(accL.size()>0){
                Map<String,Object> acc = (Map<String,Object>)JSON.deserializeUntyped(JSON.serializePretty(accL[0]));
                return (String)acc.get('Name');
            } else{
                return null;
            }
        }
    }

    private static List<String> getAccountSector(String id){
        List<TBOX_Criterion__c> LTBC = [SELECT Id, Name, TBOX_Matching_Field__c, TBOX_Matching_Field_Object__c FROM TBOX_Criterion__c WHERE Name = 'Sector' AND TBOX_Matching_Field_Object__c = 'Account' AND TBOX_Matching_Field__c != '' LIMIT 1];
        if (LTBC.size()==0 || String.isBlank(LTBC[0].TBOX_Matching_Field__c)) return null;
        TBOX_Criterion__c sectorCriterion = LTBC[0];
        List<Account> accL = DataBase.query('SELECT Id, '+sectorCriterion.TBOX_Matching_Field__c+' FROM Account WHERE Id =\''+id+'\' LIMIT 1');
        if (accL.size()==0) return null;
        Map<String,Object> acc = (Map<String,Object>)JSON.deserializeUntyped(JSON.serializePretty(accL[0]));
        String accSector = (String)acc.get(sectorCriterion.TBOX_Matching_Field__c);
        List<String> TMCVId = new List<String>();
        for(TBOX_Criterion_Value_Mapping__c cvm : [SELECT Id, TBOX_Matching_Criterion_Value__c, Name FROM TBOX_Criterion_Value_Mapping__c WHERE Name = :accSector]){
            TMCVId.add(cvm.TBOX_Matching_Criterion_Value__c);
        }
        if (TMCVId.size()==0) return null;
        List<String> r = new List<String>();
        for(TBOX_Criterion_Value__c mcv : [SELECT Id, Tender_BOX_Api_Value__c, TBOX_Criterion__c FROM TBOX_Criterion_Value__c WHERE Id IN :TMCVId AND TBOX_Criterion__c = :sectorCriterion.Id]){
            r.add(mcv.Tender_BOX_Api_Value__c);
        }
        return r;
    }

    public class WebServiceResponse{
        public HTTPResponse response;
        public Boolean status;
        public Exception excep;
    }
}