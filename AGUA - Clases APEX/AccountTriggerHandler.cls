public class AccountTriggerHandler implements Triggers.Handler {
    public void handle(){
        AccountTriggerHelper ath = new AccountTriggerHelper();
        List<Account> newListAcc = Trigger.New;
        List<Account> oldListAcc = Trigger.Old;
        Map<Id, Account> mapNewAccById = (Map<Id, Account>)Trigger.newMap;
        Map<Id, Account> mapOldAccById = (Map<Id, Account>)Trigger.OldMap;
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                ath.ChangeOwner(newListAcc);
                ath.AccountProcess(oldListAcc,newListAcc);
            }
            else if(Trigger.isUpdate){
                ath.AccountProcess(oldListAcc,newListAcc);
                ath.AccountProcessSAP(oldListAcc,newListAcc);
            }
        }
        if(Trigger.isAfter){
            if(Trigger.isUpdate){
                //ath.AccountProcessSAP(oldListAcc,newListAcc);
            }
            if(Trigger.isInsert){
                //ath.AccountProcessAfter(newListAcc);
            }
        }
    }
}