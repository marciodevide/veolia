public class ApproverCommentsController {

    @AuraEnabled
    public static Map<String,List<Map<String,String>>> getApproverCommentsOppId(Id approverNote) {
        List<ProcessInstanceWorkitem> piWorkitem = [SELECT Id, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE Id = :approverNote LIMIT 1];
        Id oppId;
        if (piWorkitem.size() != 0 && piWorkitem[0] != null) oppId = piWorkitem[0].ProcessInstance.TargetObjectId;
        else {
            List<ProcessInstanceStep> piStep = [SELECT Id, ProcessInstance.TargetObjectId FROM ProcessInstanceStep WHERE Id = :approverNote LIMIT 1];
            if (piStep.size() != 0 && piStep[0] != null) oppId = piStep[0].ProcessInstance.TargetObjectId;
        } 
        
        List<ProcessInstance> approvers = [SELECT Id, (SELECT Id, StepStatus,Actor.Name,OriginalActor.Name,Comments FROM StepsAndWorkitems ORDER BY CreatedDate ASC) FROM ProcessInstance WHERE TargetObjectId =: oppId ORDER BY CreatedDate ASC];
        Map<String,List<Map<String,String>>> info = new Map<String,List<Map<String,String>>>();
        List<Map<String,String>> app = new List<Map<String,String>>();
        for (ProcessInstance pr : approvers) {
            for(ProcessInstanceHistory  str : pr.StepsAndWorkitems) {
                app.add(new Map<String,String>{'Id' => str.Id,'ActualName'=> str.Actor.Name,'Asigned'=>str.OriginalActor.Name, 'Status' => str.StepStatus,'Comments'=>str.Comments});
            }
            info.put('approvers', app);
        }
        return info; 
    }
}