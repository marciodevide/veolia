public class NotesAttachmentsController {
    @AuraEnabled
    public static Id getOppId(Id approverNote) {
        List<ProcessInstanceWorkitem> piWorkitem = [SELECT Id, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE Id = :approverNote LIMIT 1];
        Id oppId;
        if (piWorkitem.size() != 0 && piWorkitem[0] != null) oppId = piWorkitem[0].ProcessInstance.TargetObjectId;
        else {
            List<ProcessInstanceStep> piStep = [SELECT Id, ProcessInstance.TargetObjectId FROM ProcessInstanceStep WHERE Id = :approverNote LIMIT 1];
            if (piStep.size() != 0 && piStep[0] != null) oppId = piStep[0].ProcessInstance.TargetObjectId;
        }
        return oppId;
    }

    /*@auraEnabled
    public static List<Adjuntos_Aprobacion__c> getNotes(Id oppId) {
        return [
            SELECT Id, Opportunity__c, (
                SELECT id, Title FROM notes
            ) FROM Adjuntos_Aprobacion__c WHERE Opportunity__c =  :oppId 
            LIMIT 1
        ];
    }

    @auraEnabled
    public static List<ContentDocumentLink> getAttachments(Id oppId) {
        return [
            SELECT ContentDocument.Id, ContentDocument.Title, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId in (
                SELECT Id FROM Adjuntos_Aprobacion__c 
                WHERE Opportunity__c = :oppId
            ) and LinkedEntity.Type='Adjuntos_Aprobacion__c'
        ];
    }*/

    @auraEnabled
    public static List<ContentDocumentLink> getContentDocumentLinks(Id oppId) {
        return [
            SELECT ContentDocument.FileType, ContentDocument.Id, ContentDocument.Title, LinkedEntityId,LinkedEntity.Name 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN (
                SELECT Id 
                FROM Adjuntos_Aprobacion__c 
                WHERE Opportunity__c = :oppId
            ) AND LinkedEntity.Type='Adjuntos_Aprobacion__c'
        ];
    }

    /*@AuraEnabled
    public static Map<String,List<Map<String,String>>> getInfo(Id approverNote) {
        Id oppId = getOppId(approverNote);

        Map<String,List<Map<String,String>>> info = new Map<String,List<Map<String,String>>>();

        List<Adjuntos_Aprobacion__c> adApr = getNotes(oppId);
        if (adApr.size() > 0) {
            List<Map<String,String>> noteList = new List<Map<String,String>>();
            for (Note note : adApr[0].notes) {
                noteList.add(new Map<String,String>{
                    'Id' => note.Id,
                    'Title' => note.Title,
                    'Url' => '/lightning/r/ContentDocument/'+note.Id+'/view'
                });
            }
            info.put('notes', noteList);
        }

        List<ContentDocumentLink> attachments = getAttachments(oppId);
        if (attachments.size() > 0) {
            List<Map<String,String>> attachmentList = new List<Map<String,String>>();
            for (ContentDocumentLink attachment : attachments) {
                attachmentList.add(new Map<String,String>{
                    'Id' => attachment.ContentDocument.Id,
                    'Title' => attachment.ContentDocument.Title,
                    'Url' => '/lightning/r/ContentDocument/'+attachment.ContentDocument.Id+'/view'
                });
            }
            info.put('attachments', attachmentList);
        }

        return info;
    }*/

    @AuraEnabled
    public static Map<String,List<Map<String,String>>> getInfo(Id approverNote) {
        Id oppId = getOppId(approverNote);

        Map<String,List<Map<String,String>>> info = new Map<String,List<Map<String,String>>>();

        List<ContentDocumentLink> notAndAtts = getContentDocumentLinks(oppId);
        if (notAndAtts.size() > 0) {
            List<Map<String,String>> noteList = new List<Map<String,String>>();
            List<Map<String,String>> attachmentList = new List<Map<String,String>>();
            for (ContentDocumentLink notOrAtt : notAndAtts) {
                if (notOrAtt.ContentDocument.FileType == 'SNOTE') {
                    noteList.add(new Map<String,String>{
                        'Id' => notOrAtt.ContentDocument.Id,
                        'Title' => notOrAtt.ContentDocument.Title,
                        'Carpeta'=>notOrAtt.LinkedEntity.Name,
                        'Url' => '/lightning/o/ContentNote/home?recordId='+notOrAtt.ContentDocument.Id+'/view',
                        'UrlCarpeta'=> '/lightning/r/Adjuntos_Aprobacion__c/'+notOrAtt.LinkedEntityId+'/view'
                    });
                } else {
                    attachmentList.add(new Map<String,String>{
                        'Id' => notOrAtt.ContentDocument.Id,
                        'Title' => notOrAtt.ContentDocument.Title,
                        'Carpeta'=>notOrAtt.LinkedEntity.Name,
                        'Url' => '/lightning/r/ContentDocument/'+notOrAtt.ContentDocument.Id+'/view',
                        'UrlCarpeta'=> '/lightning/r/Adjuntos_Aprobacion__c/'+notOrAtt.LinkedEntityId+'/view'
                    });
                }
            }
            info.put('notes', noteList);
            info.put('attachments', attachmentList);
        }
        return info;
    }
}