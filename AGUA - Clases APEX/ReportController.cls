public class ReportController {
	@auraEnabled
    public static String getApprover(String recordId){
        List<ProcessInstanceStep> approverList = [SELECT Id,ProcessInstance.TargetObject.name,StepStatus,Comments,CreatedDate FROM ProcessInstanceStep WHERE ProcessInstance.TargetObjectId = :recordId];
    	return JSON.serialize(approverList);
    }
}