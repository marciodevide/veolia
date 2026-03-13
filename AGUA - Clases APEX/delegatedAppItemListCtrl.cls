public class delegatedAppItemListCtrl {

    @AuraEnabled
    public static Map<String,List<Map<String,String>>> getApprovalItems() {
        Id usuario = UserInfo.getUserId();
        List <User> delegated = [SELECT Id, Name, DelegatedApproverId FROM User WHERE DelegatedApproverId !=null];
        List<ProcessInstance> approvers = [SELECT Id,  (SELECT Id, StepStatus,ActorId,Actor.Name,OriginalActorId,OriginalActor.Name,ProcessInstance.TargetObject.Name,ProcessInstance.TargetObjectId FROM StepsAndWorkitems WHERE  StepStatus='Pending' ORDER BY CreatedDate ASC) FROM ProcessInstance];
        Map<String,List<Map<String,String>>> info = new Map<String,List<Map<String,String>>>();
        List<Map<String,String>> app = new List<Map<String,String>>();
        for (ProcessInstance pr : approvers) {
            for(ProcessInstanceHistory  str : pr.StepsAndWorkitems) {
               for (User u:delegated){
                    if((u.Id == str.ActorId)&&(usuario==u.DelegatedApproverId)){
                        User appDEl=[SELECT Name FROM User WHERE Id =:u.DelegatedApproverId];
                        app.add(new Map<String,String>{'Id' => str.Id, 'Opportunity' =>str.ProcessInstance.TargetObject.Name,'ActualName'=> str.Actor.Name,'Asigned'=>str.OriginalActor.Name,'AprobadorDelegado' => appDEl.Name});
                    }
                }
            }
            info.put('approvers', app);
        }
        return info; 
    }
}