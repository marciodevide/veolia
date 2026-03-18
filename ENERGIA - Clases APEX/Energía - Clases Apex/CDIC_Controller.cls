public with sharing class CDIC_Controller {

    public static String CLASS_NAME='CDIC_Controller';

    @AuraEnabled
    public static List<CDIC_Search_Criteria__mdt> retrieveCriteria(){
        return [SELECT Id, Label, DeveloperName,CDIC_Field_Type__c,CDIC_FR_Label__c, CDIC_Min_Length__c, CDIC_Max_Length__c,CDIC_Required__c,CDIC_Display_Order__c,CDIC_Help__c,CDIC_FR_Help__c,
        (SELECT CDIC_Country_Code__c,CDIC_Country_Label__c FROM CDIC_Country_Code_Values__r ORDER BY CDIC_Country_Label__c) 
        FROM CDIC_Search_Criteria__mdt ORDER BY CDIC_Display_Order__c];
    }

    @AuraEnabled
    public static Boolean showLead(){
        CDIC_Settings__c settings =  CDIC_Settings__c.getInstance();
        return settings.Use_Leads__c;
    }

    public static String fetchAccessToken(){
        try{
            CDIC_API__mdt apiParam;
            Boolean isSandbox = [SELECT Id, isSandbox FROM Organization LIMIT 1].isSandbox;
            if(isSandbox){
                apiParam = [SELECT Id, Endpoint__c, Access_Method__c, Authorization_Username__c, Authorization_Password__c 
                    FROM CDIC_API__mdt WHERE DeveloperName = 'CDIC_Token_Demo' AND Environnement__c='UAT' WITH SECURITY_ENFORCED];
            } else {
                apiParam = [SELECT Id, Endpoint__c, Access_Method__c, Authorization_Username__c, Authorization_Password__c  
                    FROM CDIC_API__mdt WHERE DeveloperName = 'CDIC_Token_PROD' AND Environnement__c='PROD' WITH SECURITY_ENFORCED];
            }
            
            String grantType ='grant_type=client_credentials';
            Map<String, String> mapHeaders = new Map<String,String>();
            mapHeaders.put('Content-Type', 'application/x-www-form-urlencoded');
            WebServiceResponse vAPITokenRequest = executeHttpRequest(grantType,apiParam.Endpoint__c,apiParam.Access_Method__c,20000,apiParam.Authorization_Username__c,apiParam.Authorization_Password__c,mapHeaders);
            if (!vAPITokenRequest.status){
                throw vAPITokenRequest.excep;
            }
            if (vAPITokenRequest.response.getStatusCode()!=200){
                throw newMessageException(vAPITokenRequest.response.getBody());      
            }
            system.debug('vAPITokenRequest.response.statusCode:' + vAPITokenRequest.response.getstatusCode());
            system.debug('vAPITokenRequest .response.body:' + vAPITokenRequest.response.getBody());
            Map<String, Object> resultsToken = (Map<String, Object>) JSON.deserializeUntyped(vAPITokenRequest.response.getBody());
            System.debug('MAB in fetchAccessToken resultsToken = ' + resultsToken);
            System.debug('MAB in fetchAccessToken (String)resultsToken.get(access_token) = ' + (String)resultsToken.get('access_token'));
            return (String)resultsToken.get('access_token');
        } catch(Exception e){
            throw newMessageException(e.getMessage());
        }
    }


    @AuraEnabled
    public static String search(String body){
        System.debug('body:' + body);
        try {
            CDIC_API__mdt apiParam;
            Boolean isSandbox = [SELECT Id, isSandbox FROM Organization LIMIT 1].isSandbox;
            if(isSandbox){
                apiParam = [SELECT Id, Endpoint__c, Access_Method__c
                FROM CDIC_API__mdt WHERE DeveloperName = 'CDIC_SearchCriteria_Demo' AND Environnement__c='UAT' WITH SECURITY_ENFORCED];
            } else {
                apiParam = [SELECT Id, Endpoint__c, Access_Method__c 
                FROM CDIC_API__mdt WHERE DeveloperName = 'CDIC_SearchCriteria_PROD' AND Environnement__c='PROD' WITH SECURITY_ENFORCED];
            }
            String accessToken;
            if(Test.isRunningTest()){
                accessToken='DUMMY';
            }
            else{
                accessToken = fetchAccessToken();
            }

            Map<String, String> mapHeaders = new Map<String,String>();
            mapHeaders.put('Content-Type', 'application/json');
            mapHeaders.put('Authorization', 'Bearer ' + accessToken);
            System.debug('MAB in Search Authorization = Bearer ' + accessToken);

            WebServiceResponse vSearchRequest = executeHttpRequest(body,apiParam.Endpoint__c,apiParam.Access_Method__c,120000,'','',mapHeaders);

            if (!vSearchRequest.status){
                throw vSearchRequest.excep;
            }
            if (vSearchRequest.response.getStatusCode()!=200){
                throw newMessageException(vSearchRequest.response.getBody());     
            }
            System.debug(vSearchRequest.response.getBody());
            CDICSearchResults results=CDICSearchResults.parser(vSearchRequest.response.getBody());
            System.debug('MAB in Search CDICSearchResults.parse(vSearchRequest.response.getBody()) = ' + results);

            List<String> listeDuns = new List<String>();
            for (CDICSearchResults.CDICSearchResults_SearchCandidates sc : results.searchCandidates ){
                listeDuns.add(sc.organization.duns);
            }

            Map<String,Id> mapCdicAccountsIds = new Map<String,Id>();
            for(Account acc : [SELECT Id, CDIC_Id__c FROM Account WHERE CDIC_Id__c IN :listeDuns]){
                mapCdicAccountsIds.put(acc.CDIC_Id__c,acc.Id);
            }
            Map<String,Id> mapCdicLeadsIds = new Map<String,Id>();
            for(Lead iLead : [SELECT Id, CDIC_Id__c FROM Lead WHERE CDIC_Id__c IN :listeDuns]){
                mapCdicLeadsIds.put(iLead.CDIC_Id__c,iLead.Id);
            }
            
            for (CDICSearchResults.CDICSearchResults_SearchCandidates sc : results.searchCandidates ){
                sc.disableLea=true;
                sc.disableAcc=true;
                if(mapCdicAccountsIds.containsKey(sc.organization.duns)){
                    sc.accID = mapCdicAccountsIds.get(sc.organization.duns);
                    sc.disableAcc=false;
                }if (mapCdicLeadsIds.containsKey(sc.organization.duns)){
                    sc.leadID = mapCdicLeadsIds.get(sc.organization.duns);
                    sc.disableLea=false;
                }
            }      
            System.debug(results.searchCandidates[0].organization.duns + '||' + results.searchCandidates[0].accID);
            System.debug('cdicResults:' + results.toString());
            return JSON.serialize(results);      
        } catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }
    

    @AuraEnabled
    public static string preview(String duns){
        try {
            CDIC_API__mdt apiParam;
            Boolean isSandbox = [SELECT Id, isSandbox FROM Organization LIMIT 1].isSandbox;
            if(isSandbox){
                apiParam = [SELECT Id, Endpoint__c, Access_Method__c
                FROM CDIC_API__mdt WHERE DeveloperName = 'CDIC_Preview_Demo' AND Environnement__c='UAT' WITH SECURITY_ENFORCED];
            } else {
                apiParam = [SELECT Id, Endpoint__c, Access_Method__c
                FROM CDIC_API__mdt WHERE DeveloperName = 'CDIC_Preview_PROD' AND Environnement__c='PROD' WITH SECURITY_ENFORCED];
            }
            String accessToken;
            if(Test.isRunningTest()){
                accessToken='DUMMY';
            }
            else{
                accessToken = fetchAccessToken();
            }
            
            Map<String, String> mapHeaders = new Map<String,String>();
            mapHeaders.put('Content-Type', 'application/json');
            mapHeaders.put('Authorization', 'Bearer ' + accessToken);

            WebServiceResponse vPreviewRequest = executeHttpRequest(duns,apiParam.Endpoint__c+duns,apiParam.Access_Method__c,120000,'','',mapHeaders);

            if(!vPreviewRequest.status){
                throw vPreviewRequest.excep;
            }
            if(vPreviewRequest.response.getStatusCode()!=200){
                throw newMessageException(vPreviewRequest.response.getBody());
            }

            if(vPreviewRequest.response.getBody() == '{"errorCode": "10001", "errorMessage": "DUNS not found"}' && isSandbox){
                throw newMessageException('This account is not avalaible for import in sandboxes.');
            }

			System.debug('MAB vPreviewRequest.response.getBody :' + vPreviewRequest.response.getBody());
            System.debug('MAB vPreviewRequest.response.getBody().replace :' + vPreviewRequest.response.getBody().replace(': "',':"'));
            return vPreviewRequest.response.getBody().replace(': "',':"');
            
        } catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
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
                System.debug('MAB in executeHttpRequest req.setHeader Authorization = ' + authorizationHeader);
            }
            
            if (requestType != 'GET') {
                if (header != null) {
                    for (String key : header.keySet()) {
                        req.setHeader(key, header.get(key));
                    }
                }
                req.setBody(envelope);
                System.debug('MAB in executeHttpRequest req.setBody envelope = ' + envelope);
            } else {
                if (header != null){
                    for (String key : header.keySet()){
                        req.setHeader(key, header.get(key));
                    }
                }
            }
            System.debug('MAB in executeHttpRequest request req = ' + req);
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

    @AuraEnabled
    public static sObject retrieveAccount(Id accId){
        try{
            String importAsType = String.valueOf(accId).left(3) == '001' ? 'Account' : 'Lead';
            if(importAsType == 'Lead'){
                List<Lead> lLeads = [SELECT Id, Name, CDIC_IsoAlpha2Code__c, PostalCode, City FROM Lead WHERE Id = :accId LIMIT 1];
                if (lLeads.size()>0){
                    return lLeads[0];
                } else {
                    system.debug('ERROR: '+Label.CDIC_Exception_LeadNotFound);
                    throw newMessageException(Label.CDIC_Exception_LeadNotFound);
                }
            } else {
                List<Account> accL= [SELECT Id, Name, CDIC_IsoAlpha2Code__c, BillingPostalCode, BillingCity FROM Account WHERE Id = :accId LIMIT 1];
                if (accL.size()>0){
                    if(!(accL[0].BillingPostalCode!=null && accL[0].BillingPostalCode.length() >0)){
                        List<Account> accLb= [SELECT Id, Name, CDIC_IsoAlpha2Code__c, ShippingPostalCode, ShippingCity FROM Account WHERE Id = :accId LIMIT 1];
                        if(accLb.size()>0){
                            accL = accLb;
                        }
                    }
                    return accL[0];
                } else {
                    system.debug('ERROR: '+Label.CDIC_Exception_AccountNotFound);
                    throw newMessageException(Label.CDIC_Exception_AccountNotFound);
                }    
            }
        }catch(Exception e){
            throw newMessageException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Id quickImportAccount(String cdicId, String importAsType){
        try{            
            return importAccount(preview(cdicId), importAsType);
        }catch(Exception e){
            if (e.getMessage().contains('For input string:')&&e.getMessage().contains('.0')){
                try{  
                    return importAccount(preview(cdicId),importAsType);
                }catch(Exception e2){
                    throw newMessageException(e2.getMessage());
                }
            }
            throw newMessageException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Id importAccount(String company, String importAsType){
        try{
            System.debug('MAB in importAccount and company = ' + company);
            //System.debug('MAB in importAccount with company.replace = ' + company.replace('currency', 'curr').replace('\"{','{').replace('}\"','}').replace('\'','"').replace('"gender":"Male"','"gender":{"description":"Male"}').replace('"gender":"Female"','"gender":{"description":"Female"}'));
            //CDICData data = CDICData.parser(company.replace('currency', 'curr').replace('\"{','{').replace('}\"','}').replace('\'','"').replace('"gender":"Male"','"gender":{"description":"Male"}').replace('"gender":"Female"','"gender":{"description":"Female"}'));
            System.debug('MAB in importAccount with company.replace = ' + company.replace('currency', 'curr').replace('"date"','"datec"').replace('\"{\'','{\"').replace('\':','\":').replace('\',','\",').replace(': \'',': \"').replace(', \'',', \"').replace(':\'',':\"').replace(',\'',',\"').replace('\"{','{').replace('}\"','}').replace('"gender":"Male"','"gender":{"description":"Male"}').replace('"gender":"Female"','"gender":{"description":"Female"}').replace('None','"None"'));
            CDICData data = CDICData.parser(company.replace('currency', 'curr').replace('"date"','"datec"').replace('\"{\'','{\"').replace('\':','\":').replace('\',','\",').replace(': \'',': \"').replace(', \'',', \"').replace(':\'',':\"').replace(',\'',',\"').replace('\"{','{').replace('}\"','}').replace('"gender":"Male"','"gender":{"description":"Male"}').replace('"gender":"Female"','"gender":{"description":"Female"}').replace('None','null').replace(': \'',':"').replace('\'}','"}'));
            System.debug('MAB in importAccount and CDICData.parser data = ' + data);
            if(importAsType == 'Account'){
                Account vAcc;
                List<Account> la= [SELECT Id, Name, BillingCity, BillingCountry, BillingLatitude, BillingLongitude, BillingPostalCode, BillingState, BillingStreet, CDIC_Id__c,
                ShippingStreet, ShippingCity, ShippingCountry, ShippingLatitude, ShippingState, Phone, Website, Fax,
                CDIC_PrimaryAddress_Address1__c, CDIC_PrimaryAddress_Address2__c, CDIC_PrimaryAddress_City__c,CDIC_PrimaryAddress_Country__c, CDIC_PrimaryAddress_County__c,
                CDIC_PrimaryAddress_PostalCode__c, CDIC_PrimaryAddress_Region__c,
                CDIC_MailingAddress_Address1__c, CDIC_MailingAddress_Address2__c, CDIC_MailingAddress_City__c,CDIC_MailingAddress_Country__c, CDIC_MailingAddress_County__c,
                CDIC_MailingAddress_PostalCode__c, CDIC_MailingAddress_Region__c, CDIC_TECH_date_dernier_import__c
                FROM Account WHERE CDIC_Id__c = :data.duns LIMIT 1];
                if (la.size()>0){
                    vAcc = la[0];
                } else {
                    vAcc = new Account();
                }
                mapAccountFields(vAcc, data);
                upsert(vAcc);
                List<Account> insertedAccount = [SELECT Id FROM Account WHERE CDIC_Id__c = :data.duns LIMIT 1];
                if (insertedAccount.size()>0){
                    return insertedAccount[0].Id;
                }  
                else {
                    system.debug('ERROR: '+Label.CDIC_Exception_AccountUpsertFailed);
                    throw newMessageException(Label.CDIC_Exception_AccountUpsertFailed);
                }
            } else {
                Lead vLead;
                List<Lead> lLeads= [SELECT Id, LastName, Company, City, Country, Latitude, Longitude, PostalCode, State, Street, CDIC_Id__c,
                Phone, Website, Fax FROM Lead WHERE CDIC_Id__c = :data.duns LIMIT 1];
                if (lLeads.size()>0){
                    vLead = lLeads[0];
                } else {
                    vLead = new Lead();
                }
                mapLeadFields(vLead, data);
                upsert(vLead);
                List<Lead> insertedLead = [SELECT Id FROM Lead WHERE CDIC_Id__c = :data.duns LIMIT 1];
                if (insertedLead.size()>0){
                    return insertedLead[0].Id;
                }  
                else {
                    system.debug('ERROR: '+Label.CDIC_Exception_LeadUpsertFailed);
                    throw newMessageException(Label.CDIC_Exception_LeadUpsertFailed);
                }
            }
        }catch(Exception e){
            throw newMessageException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Id refreshAccount(Id accId){
        try{
            if(String.valueOf(accId).left(3) == '001'){
                system.debug('refresh Account');
                List<Account> accL= [SELECT Id,CDIC_Id__c FROM Account WHERE Id = :accId LIMIT 1];
                if (accL.size()>0){
                    if (accL[0].CDIC_Id__c!=null && accL[0].CDIC_Id__c.length() >0){
                        return importAccount(preview(accL[0].CDIC_Id__c), 'Account');
                    } else {
                        system.debug('ERROR: '+Label.CDIC_Exception_CDICNotFound);
                        throw newMessageException(Label.CDIC_Exception_CDICNotFound);
                    }
                } else {
                    system.debug('ERROR: '+Label.CDIC_Exception_AccountNotFound);
                    throw newMessageException(Label.CDIC_Exception_AccountNotFound);
                }    
            } else {
                system.debug('refresh Lead');
                List<Lead> leadsL= [SELECT Id,CDIC_Id__c FROM Lead WHERE Id = :accId LIMIT 1];
                if (leadsL.size()>0){
                    if (leadsL[0].CDIC_Id__c!=null && leadsL[0].CDIC_Id__c.length() >0){
                        return importAccount(preview(leadsL[0].CDIC_Id__c), 'Lead');
                    } else {
                        system.debug('ERROR: '+Label.CDIC_Exception_CDICNotFound);
                        throw newMessageException(Label.CDIC_Exception_CDICNotFound);
                    }
                } else {
                    system.debug('ERROR: '+Label.CDIC_Exception_LeadNotFound);
                    throw newMessageException(Label.CDIC_Exception_LeadNotFound);
                }    
            }

        }catch(Exception e){
            System.debug(e.getMessage());
            throw newMessageException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Id updateAccount(String cdicId, Id accId){
        try{
            String importAsType = String.valueOf(accId).left(3) == '001' ? 'Account' : 'Lead';
            system.debug('importAsType:' + importAsType);
            if(importAsType == 'Lead'){
                List<Lead> ll = [SELECT Id, CDIC_Id__c FROM Lead WHERE CDIC_Id__c =:cdicId LIMIT 1];
                Lead vLead = (ll.size()==0)?new Lead(Id = accId, CDIC_Id__c=cdicId):ll[0];
                update vLead;
                return vLead.Id;
            } else {
                List<Account> la = [SELECT Id, CDIC_Id__c FROM Account WHERE CDIC_Id__c =:cdicId LIMIT 1];
                Account vAcc = (la.size()==0)?new Account(Id = accId, CDIC_Id__c=cdicId):la[0];
                update vAcc;
                return vAcc.Id;
            }
        }catch(Exception e){
            system.debug('Error during Update DML Operation');
            throw newMessageException(e.getMessage());
        }
    }

    private static void mapAccountFields(Account vAcc, CDICData data){
        vAcc.CDIC_TECH_date_dernier_import__c = Datetime.now();
        vAcc.Name = data.primaryName;
        vAcc.CDIC_PrimaryAddress_Address1__c = data.primaryAddress.streetAddress.line1;
        vAcc.CDIC_PrimaryAddress_Address2__c = data.primaryAddress.streetAddress.line2;
        vAcc.BillingStreet = data.primaryAddress.streetAddress.line1;
        vAcc.CDIC_PrimaryAddress_City__c = data.primaryAddress.addressLocality.name;
        vAcc.BillingCity = data.primaryAddress.addressLocality.name;        
        vAcc.CDIC_PrimaryAddress_PostalCode__c = data.primaryAddress.postalCode;
        vAcc.BillingPostalCode = data.primaryAddress.postalCode;
        if(data.primaryAddress.addressCountry != null && String.isNotBlank(data.primaryAddress.addressCountry.name)){        
            vAcc.CDIC_PrimaryAddress_Country__c = data.primaryAddress.addressCountry.name;
            vAcc.BillingCountry = data.primaryAddress.addressCountry.name;
        } else {
            vAcc.CDIC_PrimaryAddress_Country__c = '_';
            vAcc.BillingCountry = '_';
        }
        if (data.primaryAddress.latitude != null && data.primaryAddress.longitude != null){
            vAcc.BillingLatitude = Decimal.valueOf(data.primaryAddress.latitude);
            vAcc.BillingLongitude = Decimal.valueOf(data.primaryAddress.longitude);
        }
        if(data.primaryAddress.addressRegion != null && String.isNotBlank(data.primaryAddress.addressRegion.name)){
            vAcc.CDIC_PrimaryAddress_Region__c = data.primaryAddress.addressRegion.name;
            vAcc.BillingState = data.primaryAddress.addressRegion.name;
        }
        if(data.primaryAddress.addressCounty != null && String.isNotBlank(data.primaryAddress.addressCounty.name))
            vAcc.CDIC_PrimaryAddress_County__c = data.primaryAddress.addressCounty.name;
        if (data.mailingAddress != null && (String.isNotBlank(data.mailingAddress.postalCode) && String.isNotBlank(data.mailingAddress.addressLocality.name) && (data.mailingAddress.addressCountry != null && String.isNotBlank(data.mailingAddress.addressCountry.name)))){
            vAcc.CDIC_MailingAddress_Address1__c = data.mailingAddress.streetAddress.line1;
            vAcc.CDIC_MailingAddress_Address2__c = data.mailingAddress.streetAddress.line2;
            vAcc.ShippingStreet = data.mailingAddress.streetAddress.line1;
            vAcc.CDIC_MailingAddress_City__c = data.mailingAddress.addressLocality.name;
            vAcc.ShippingCity = data.mailingAddress.addressLocality.name;
            vAcc.CDIC_MailingAddress_PostalCode__c = data.mailingAddress.postalCode;
            vAcc.ShippingPostalCode = data.mailingAddress.postalCode; 
            vAcc.CDIC_MailingAddress_Country__c = data.mailingAddress.addressCountry.name;
            vAcc.ShippingCountry = data.mailingAddress.addressCountry.name;
            if(data.mailingAddress.addressRegion != null && String.isNotBlank(data.mailingAddress.addressRegion.name)){
                vAcc.CDIC_MailingAddress_Region__c = data.mailingAddress.addressRegion.name;
                vAcc.ShippingState = data.mailingAddress.addressRegion.name;
            }
            if(data.mailingAddress.addressCounty != null && String.isNotBlank(data.mailingAddress.addressCounty.name))
                vAcc.CDIC_MailingAddress_County__c = data.mailingAddress.addressCounty.name;
        }else{
            vAcc.CDIC_MailingAddress_Address1__c = vAcc.CDIC_PrimaryAddress_Address1__c;
            vAcc.CDIC_MailingAddress_Address2__c = vAcc.CDIC_PrimaryAddress_Address2__c;
            vAcc.ShippingStreet = vAcc.CDIC_PrimaryAddress_Address1__c;
            vAcc.CDIC_MailingAddress_City__c = vAcc.CDIC_PrimaryAddress_City__c;
            vAcc.ShippingCity = vAcc.CDIC_PrimaryAddress_City__c;
            vAcc.CDIC_MailingAddress_PostalCode__c = vAcc.CDIC_PrimaryAddress_PostalCode__c;
            vAcc.ShippingPostalCode = vAcc.CDIC_PrimaryAddress_PostalCode__c;  
            vAcc.CDIC_MailingAddress_Country__c = vAcc.CDIC_PrimaryAddress_Country__c;
            vAcc.ShippingCountry = vAcc.CDIC_PrimaryAddress_Country__c;
            vAcc.CDIC_MailingAddress_Region__c = vAcc.CDIC_PrimaryAddress_Region__c;
            vAcc.ShippingState = vAcc.CDIC_PrimaryAddress_Region__c;
            vAcc.CDIC_MailingAddress_County__c = vAcc.CDIC_PrimaryAddress_County__c;
        }
        if (data.telephone.size()>0){
            vAcc.Phone = data.telephone[0].isdCode+data.telephone[0].telephoneNumber;
        }
        if (data.fax.size()>0){
            vAcc.Fax = data.fax[0].isdCode+data.fax[0].faxNumber;
        }
        if (data.websiteAddress.size()>0){
            vAcc.Website = data.websiteAddress[0].url;
        }
        vAcc.CDIC_Id__c = data.duns;
        vAcc.CDIC_StartDate__c = (data.startData != null) ? Date.valueOf(data.startData) : null;
        if (data.corporateLinkage.globalUltimate != null){
            vAcc.CDIC_GlobalUltimate_Id__c =data.corporateLinkage.globalUltimate.duns;
            vAcc.CDIC_GlobalUltimate_Name__c =data.corporateLinkage.globalUltimate.primaryName;
            if (data.corporateLinkage.globalUltimate.primaryAddress != null){
                vAcc.CDIC_GlobalUltimate_Street__c = (data.corporateLinkage.globalUltimate.primaryAddress.streetAddress != null) ? data.corporateLinkage.globalUltimate.primaryAddress.streetAddress.line1 : null;
                vAcc.CDIC_GlobalUltimate_City__c = (data.corporateLinkage.globalUltimate.primaryAddress.addressLocality != null) ? data.corporateLinkage.globalUltimate.primaryAddress.addressLocality.name : null;
                vAcc.CDIC_GlobalUltimate_Country__c = (data.corporateLinkage.globalUltimate.primaryAddress.addressCountry != null) ? data.corporateLinkage.globalUltimate.primaryAddress.addressCountry.name : null;
                vAcc.CDIC_GlobalUltimate_PostalCode__c = data.corporateLinkage.globalUltimate.primaryAddress.postalCode;
            }
        }
        if (data.corporateLinkage.domesticUltimate != null){
            vAcc.CDIC_DomesticUltimate_Id__c = data.corporateLinkage.domesticUltimate.duns;
            vAcc.CDIC_DomesticUltimate_Name__c = data.corporateLinkage.domesticUltimate.primaryName;
        }
        if (data.corporateLinkage.headquarter != null){
            vAcc.CDIC_Headquarter_Id__c = data.corporateLinkage.headquarter.duns;
            vAcc.CDIC_Headquarter_Name__c = data.corporateLinkage.headquarter.primaryName;
        }
        vAcc.CDIC_BusinessEntityType__c = (data.businessEntityType != null) ? data.businessEntityType.description : null;
        if (data.mostSeniorsPrincipals.size() > 0){
            vAcc.CDIC_Principal_Gender__c = data.mostSeniorsPrincipals[0].gender.description;
            vAcc.CDIC_Principal_FullName__c = data.mostSeniorsPrincipals[0].fullName;    
        }
        if (data.financials.size()>0 && data.financials[0].yearlyRevenue.size()==2){
            vAcc.CDIC_AccountFinancials_Local__c = data.financials[0].yearlyRevenue[0].value;
            vAcc.CDIC_AccountFinancials_Currency__c = data.financials[0].yearlyRevenue[0].curr;
            vAcc.CDIC_AccountFinancials_Global__c = data.financials[0].yearlyRevenue[1].value;
        }            
        vAcc.CDIC_FamilyTreeCount__c = data.corporateLinkage.globalUltimateFamilyTreeMembersCount;
        vAcc.CDIC_EmployeeCount__c = (data.numberOfEmployees.size()>0) ? data.numberOfEmployees[0].value : null;
        List<String> rnv = new List<String>();
        List<String> rnd = new List<String>();
        for (CDICData_RN rn : data.registrationNumbers){
            if (rn.typeDescription != 'SIREN'){
                rnv.add(rn.registrationNumber);
                rnd.add(rn.typeDescription);
            }
            if (rnv.size()>=3) break;
        }
        vAcc.CDIC_RegistrationNumber1__c = (rnv.size()>0) ? rnv[0] : null;
        vAcc.CDIC_RegistrationNumber2__c = (rnv.size()>1) ? rnv[1] : null;
        vAcc.CDIC_RegistrationNumber3__c = (rnv.size()>2) ? rnv[2] : null;
        vAcc.CDIC_RegistrationText1__c = (rnd.size()>0) ? rnd[0] : null;
        vAcc.CDIC_RegistrationText2__c = (rnd.size()>1) ? rnd[1] : null;
        vAcc.CDIC_RegistrationText3__c = (rnd.size()>2) ? rnd[2] : null;
        
        for (CDICData_IC ic : data.industryCodes){
            if (ic.priority == 1){
                switch on ic.typeDescription{
                    when 'US Standard Industry Code 1987 - 4 digit' {
                        vAcc.CDIC_SIC_Code__c = ic.code;
                        vAcc.CDIC_SIC_Description__c = ic.description;
                    }
                    when 'North American Industry Classification System 2017'{
                        vAcc.CDIC_NAICS_Code__c = ic.code;
                        vAcc.CDIC_NAICS_Description__c = ic.description;
                    }
                    when 'NACE Revision 2'{
                        vAcc.CDIC_NACE_Code__c = ic.code;
                        vAcc.CDIC_NACE_Description__c = ic.description;
                    }
                }
            }
        }
        vAcc.CDIC_IsoAlpha2Code__c = (data.primaryAddress.addressCountry != null) ? data.primaryAddress.addressCountry.isoAlpha2Code : null;
    }

    private static void mapLeadFields(Lead vLead, CDICData data){
        system.debug('data.primaryName: ' + data.primaryName);
        system.debug('data.primaryAddress: ' + data.primaryAddress);
        system.debug('data.mailingAddress: ' + data.mailingAddress);

        vLead.LastName = data.primaryName;
        vLead.Company = data.primaryName;
        vLead.Street = data.primaryAddress.streetAddress.line1;
        vLead.City = data.primaryAddress.addressLocality.name;
        vLead.PostalCode = data.primaryAddress.postalCode;
        if(data.primaryAddress.addressRegion != null && String.isNotBlank(data.primaryAddress.addressRegion.name))
            vLead.State = data.primaryAddress.addressRegion.name;
        if(data.primaryAddress.addressCountry != null && String.isNotBlank(data.primaryAddress.addressCountry.name))
            vLead.Country = data.primaryAddress.addressCountry.name;
        if (data.primaryAddress.latitude != null && data.primaryAddress.longitude != null){
            vLead.Latitude = Decimal.valueOf(data.primaryAddress.latitude);
            vLead.Longitude = Decimal.valueOf(data.primaryAddress.longitude);
        }
        if (data.telephone.size()>0){
            vLead.Phone = data.telephone[0].isdCode+data.telephone[0].telephoneNumber;
        }
        if (data.websiteAddress.size()>0){
            vLead.Website = data.websiteAddress[0].url;
        }
        vLead.CDIC_Id__c = data.duns;
        vLead.CDIC_StartDate__c = (data.startData != null) ? Date.valueOf(data.startData) : null;
        if (data.corporateLinkage.globalUltimate != null){
            vLead.CDIC_GlobalUltimate_Id__c =data.corporateLinkage.globalUltimate.duns;
            vLead.CDIC_GlobalUltimate_Name__c =data.corporateLinkage.globalUltimate.primaryName;
            if (data.corporateLinkage.globalUltimate.primaryAddress != null){
                vLead.CDIC_GlobalUltimate_Street__c = (data.corporateLinkage.globalUltimate.primaryAddress.streetAddress != null) ? data.corporateLinkage.globalUltimate.primaryAddress.streetAddress.line1 : null;
                vLead.CDIC_GlobalUltimate_City__c = (data.corporateLinkage.globalUltimate.primaryAddress.addressLocality != null) ? data.corporateLinkage.globalUltimate.primaryAddress.addressLocality.name : null;
                vLead.CDIC_GlobalUltimate_Country__c = (data.corporateLinkage.globalUltimate.primaryAddress.addressCountry != null) ? data.corporateLinkage.globalUltimate.primaryAddress.addressCountry.name : null;
                vLead.CDIC_GlobalUltimate_PostalCode__c = data.corporateLinkage.globalUltimate.primaryAddress.postalCode;
            }
        }
        if (data.corporateLinkage.domesticUltimate != null){
            vLead.CDIC_DomesticUltimate_Id__c = data.corporateLinkage.domesticUltimate.duns;
            vLead.CDIC_DomesticUltimate_Name__c = data.corporateLinkage.domesticUltimate.primaryName;
        }
        if (data.corporateLinkage.headquarter != null){
            vLead.CDIC_Headquarter_Id__c = data.corporateLinkage.headquarter.duns;
            vLead.CDIC_Headquarter_Name__c = data.corporateLinkage.headquarter.primaryName;
        }
        vLead.CDIC_BusinessEntityType__c = (data.businessEntityType != null) ? data.businessEntityType.description : null;
        if (data.mostSeniorsPrincipals.size() > 0){
            vLead.CDIC_Principal_Gender__c = data.mostSeniorsPrincipals[0].gender.description;
            vLead.CDIC_Principal_FullName__c = data.mostSeniorsPrincipals[0].fullName;    
        }
        if (data.financials.size()>0 && data.financials[0].yearlyRevenue.size()==2){
            vLead.CDIC_AccountFinancials_Local__c = data.financials[0].yearlyRevenue[0].value;
            vLead.CDIC_AccountFinancials_Currency__c = data.financials[0].yearlyRevenue[0].curr;
            vLead.CDIC_AccountFinancials_Global__c = data.financials[0].yearlyRevenue[1].value;
        }            
        vLead.CDIC_FamilyTreeCount__c = data.corporateLinkage.globalUltimateFamilyTreeMembersCount;
        vLead.CDIC_EmployeeCount__c = (data.numberOfEmployees.size()>0) ? data.numberOfEmployees[0].value : null;
        List<String> rnv = new List<String>();
        List<String> rnd = new List<String>();
        for (CDICData_RN rn : data.registrationNumbers){
            if (rn.typeDescription != 'SIREN'){
                rnv.add(rn.registrationNumber);
                rnd.add(rn.typeDescription);
            }
            if (rnv.size()>=3) break;
        }
        vLead.CDIC_RegistrationNumber1__c = (rnv.size()>0) ? rnv[0] : null;
        vLead.CDIC_RegistrationNumber2__c = (rnv.size()>1) ? rnv[1] : null;
        vLead.CDIC_RegistrationNumber3__c = (rnv.size()>2) ? rnv[2] : null;
        vLead.CDIC_RegistrationText1__c = (rnd.size()>0) ? rnd[0] : null;
        vLead.CDIC_RegistrationText2__c = (rnd.size()>1) ? rnd[1] : null;
        vLead.CDIC_RegistrationText3__c = (rnd.size()>2) ? rnd[2] : null;
        
        for (CDICData_IC ic : data.industryCodes){
            if (ic.priority == 1){
                switch on ic.typeDescription{
                    when 'US Standard Industry Code 1987 - 4 digit' {
                        vLead.CDIC_SIC_Code__c = ic.code;
                        vLead.CDIC_SIC_Description__c = ic.description;
                    }
                    when 'North American Industry Classification System 2017'{
                        vLead.CDIC_NAICS_Code__c = ic.code;
                        vLead.CDIC_NAICS_Description__c = ic.description;
                    }
                    when 'NACE Revision 2'{
                        vLead.CDIC_NACE_Code__c = ic.code;
                        vLead.CDIC_NACE_Description__c = ic.description;
                    }
                }
            }
        }
        vLead.CDIC_IsoAlpha2Code__c = (data.primaryAddress.addressCountry != null) ? data.primaryAddress.addressCountry.isoAlpha2Code : null;
    }

    private static AuraHandledException newMessageException(String message) {
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        return e;
    }

    public class WebServiceResponse{
        public HTTPResponse response;
        public Boolean status;
        public Exception excep;
    }
}